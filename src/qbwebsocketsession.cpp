//
//  qbwebsocketsession.cpp
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.
#define _WIN32_WINNT_WIN10                  0x0A00 // Windows 10

#include "qbwebsocketsession.h"
#include "qbclient.h"

#include <chrono>

namespace http = beast::http;
namespace QBWebSocket{
void fail(beast::error_code ec, char const* description) {
    std::cerr << description << ": " << ec.message() << std::endl;
}
}


QBWebSocketSession::QBWebSocketSession(const std::string &host,
                                       const std::string &port) :
    _client(nullptr),
    _ioc(),
    _ssl(ssl::context::tlsv12_client),
    _resolver(net::make_strand(_ioc)),
    _ws(new WEBSOCKET(net::make_strand(_ioc), _ssl)),
    _host(host),
    _port(port),
    _connected(false)
{
}

void QBWebSocketSession::run()
{
    // Ensure it is flagged as disconnected
    disconnected();

    // Reinstantiate the websocket. New ones are necessary
    // for each connection.
    _ws.reset(new WEBSOCKET(net::make_strand(_ioc), _ssl));

    // Begin the ASIO IO context.
    _io_thread = std::thread([this]{
        _ioc.stop();
        _ioc.restart();
        _ioc.run();
    });
    
    // Create a domain resolver outstanding handler.
    _resolver.async_resolve(
        _host,
        _port,
        beast::bind_front_handler(
            &QBWebSocketSession::on_resolve,shared_from_this()));
}

void QBWebSocketSession::reset()
{
    // Wait for and ensure the safety thread
    // has already exited scope. Premature termination
    // will crash the program.
    if (_safety_thread.joinable())
        _safety_thread.join();

    // The safety thread provides a safe place to
    // sit an wait for the io_context thread to
    // exit all handlers before reconstructing.
    _safety_thread = std::thread([this]{
        // Cancel current operations
        beast::get_lowest_layer(*_ws).cancel();

        // Stop the ASIO IO context
        _ioc.stop();

        // Allow the handlers to exit scope
        if (_io_thread.joinable())
            _io_thread.join();

        // Wait a few seconds
        std::this_thread::sleep_for(std::chrono::seconds(5));

        // and start over
        run();
    });
}

void QBWebSocketSession::stop()
{
    // THIS IS CALLED FROM A NON-IO_CONTEXT->RUN THREAD.
    // THAT FACT IS VERY IMPORANT. DO NOT CALL IT FROM A HANDLER

    // Wait for and ensure the monitor thread
    // has already exited scope. Premature termination
    // will crash the program.
    if (_safety_thread.joinable())
        _safety_thread.join();

    // Null out the client
    _client = nullptr;

    // Set the connection status to false.
    disconnected();

    // Inform the server the connection is about to close.
    _ws->text(true);
    _ws->async_write(net::buffer("QB_CLOSE"),
                    beast::bind_front_handler(
                    &QBWebSocketSession::on_read,
                         shared_from_this()));

    // Allow the handlers to exit scope
    if (_io_thread.joinable())
        _io_thread.join();

    // Stop the IO context
    _ioc.stop();

}

void QBWebSocketSession::on_resolve(beast::error_code ec, tcp::resolver::results_type results)
{
    if(ec) {
        QBWebSocket::fail(ec, "Failed to resolve the host domain");
        // Give it a second and try to resolve again
        std::cout << "Trying again..." << std::endl;

        disconnected();

        // Reset
        reset();
        return;
    }

    // Set a timeout on the operation
    beast::get_lowest_layer(*_ws).expires_after(std::chrono::seconds(30));

    // Make the connection on the IP address we get from a lookup
    beast::get_lowest_layer(*_ws).async_connect(
        results,
        beast::bind_front_handler(
            &QBWebSocketSession::on_connect,
            shared_from_this()));
}

void QBWebSocketSession::on_connect(beast::error_code ec, tcp::resolver::results_type::endpoint_type ep)
{
    if(ec) {
        QBWebSocket::fail(ec, "connect");

        // Again, wait a couple seconds before trying again
        
        disconnected();
        reset();
        return;
    }

    // Update the host_ string. This will provide the value of the
    // Host HTTP header during the WebSocket handshake.
    // See https://tools.ietf.org/html/rfc7230#section-5.4
    _ep_port = std::to_string(ep.port());

    // Set a timeout on the operation
    beast::get_lowest_layer(*_ws).expires_after(std::chrono::seconds(30));

    // Perform the SSL handshake
    _ws->next_layer().async_handshake(
        ssl::stream_base::client,
        beast::bind_front_handler(
            &QBWebSocketSession::on_ssl_handshake,
            shared_from_this()));
}

void QBWebSocketSession::on_ssl_handshake(beast::error_code ec)
{
    if(ec) {
        QBWebSocket::fail(ec, "The SSL handshake failed");

        disconnected();
        reset();
        return;
    }

    // Turn off the timeout on the tcp_stream, because
    // the websocket stream has its own timeout system.
    beast::get_lowest_layer(*_ws).expires_never();

    // Set suggested timeout settings for the websocket
    _ws->set_option(
        websocket::stream_base::timeout::suggested(
            beast::role_type::client));

    // Set a decorator to change the User-Agent of the handshake
    _ws->set_option(websocket::stream_base::decorator(
        [](websocket::request_type& req)
        {
            req.set(http::field::user_agent,
                std::string(BOOST_BEAST_VERSION_STRING) +
                    "MichiganPath_QBankClient");
        }));

    _ws->binary(true);

    // Perform the websocket handshake
    std::string host = _host + ":" + _ep_port;
    _ws->async_handshake(host, "/",
        beast::bind_front_handler(
            &QBWebSocketSession::on_handshake,
            shared_from_this()));
}

void QBWebSocketSession::on_handshake(beast::error_code ec)
{
    if(ec) {
        QBWebSocket::fail(ec, "The websocket handshake failed");

        disconnected();
        reset();
        return;
    }

    std::cout << "Websocket connection established with "
              << _host << " : " << _port << std::endl;

    // Assign the connected status
    connected();

    // Attempt to log in with stored credentials
    _client->attemptResume();

    // Begin listening
    _ws->async_read(
        _buffer,
        beast::bind_front_handler(
            &QBWebSocketSession::on_read,
            shared_from_this()));

    // Write out any outstanding requests and discard them
    for (auto&& write : _cachedWrites)
        sendRequest(write);
    _cachedWrites.clear();
}

void QBWebSocketSession::sendRequest(const std::string& request) {
    // Send a text-style request to the server

    _ws->text(true);
    try {
        if (_connected) _ws->write(net::buffer(request));
        else _cachedWrites.push_back(request);
    }  catch (...) {
        std::cout << "YIKES! Attempted to write without proper server connection." << std::endl;
        std::cout << "...clearly something went wrong. Okay, let's try that again." << std::endl;

        // Mark the WS as disconnected
        disconnected();

        // Okay let's do this again...
        // Cache the write. We will get to it in a moment if we can connect.
        _cachedWrites.push_back(request);

        reset();
        return;
    }

}

void QBWebSocketSession::sendObject(boost::shared_ptr<const std::string>& response) {

    // Send a binary style object to the server
    _ws->binary(true);
    _ws->write(net::buffer(response->c_str(),response->size()));
}

void QBWebSocketSession::connected()
{
    if (_connected) return;
    _connected = true;

    QJsonObject bin_protocol;

    if (_client) _client->connectionChanged();
}

void QBWebSocketSession::disconnected()
{
    if (!_connected) return;
    _connected = false;
    if (_client) _client->connectionChanged();
}

void QBWebSocketSession::on_write(beast::error_code ec,std::size_t bytes)
{
    boost::ignore_unused(bytes);
    if(ec)
        return QBWebSocket::fail(ec, "write");
}

inline
std::string
to_string(beast::flat_buffer const& buffer)
{
    return std::string(boost::asio::buffer_cast<char const*>(
        beast::buffers_front(buffer.data())),
            boost::asio::buffer_size(buffer.data()));
}

void QBWebSocketSession::on_read(beast::error_code ec, std::size_t bytes_transferred)
{
    boost::ignore_unused(bytes_transferred);
    if(ec) {
        QBWebSocket::fail(ec, "Failed to read the stream");

        // The connection has failed, we need to restart.
        reset();
        return;
    }

    // If binary is received, treat it as an object
    if (_ws->got_binary()) {
        const auto const_buf = beast::buffers_front(_buffer.data());
         objectReturned(const_buf.data(),const_buf.size());
    }

    // Otherwise, it is text... Look for a close signal from the server
    // If so, return without invoking a new handler to allow the system
    // to exit scope and _ioc.run() to return.
    else {
        const auto stream = beast::buffers_to_string(_buffer.data());
        // Check for the close signal; this will end the event handler
        if (stream.find("QB_CLOSE") == 0) {
            _buffer.consume(_buffer.size());
            return;
        }
        // Otherwise, interpret the JSON response
        responseReturned(QString::fromStdString(stream));
    }

    // And consume the buffer
    _buffer.consume(_buffer.size());

    // Begin listening again.
    if (_connected)
        _ws->async_read (_buffer,
                        beast::bind_front_handler(
                        &QBWebSocketSession::on_read,
                        shared_from_this()));
}

void QBWebSocketSession::setClient(QBClient *client) {_client = client;}
bool QBWebSocketSession::isConnected() const {return _connected;}

void QBWebSocketSession::responseReturned(const QString &response)
{
    if (_client) _client->onResponseReturned(response);
}

void QBWebSocketSession::objectReturned(const void* bytes, size_t size)
{
    // Websocket and client are built separately. This just ensures no seg-fault
    if (_client) _client->onObjectReturned(bytes, size);
}
