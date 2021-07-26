//
//  qbwebsocketsession.h
//  QbankClientApplication
//
//  Created by Ryan Landvater on 8/2/20.
//  Copyright © 2020-21 Ryan Landvater. All rights reserved.

#ifndef QBWEBSOCKETSESSION_H
#define QBWEBSOCKETSESSION_H

#include <QObject>
#include <iostream>
#include <thread>
#include <boost/asio/ip/tcp.hpp>
#include <boost/beast/core.hpp>
#include <boost/beast/websocket.hpp>
#include <boost/beast/ssl.hpp>
#include <boost/beast/websocket/ssl.hpp>
#include <boost/asio/strand.hpp>
#include <boost/shared_ptr.hpp>

namespace beast         = boost::beast;
namespace websocket     = beast::websocket;
namespace net           = boost::asio;
namespace ssl           = boost::asio::ssl;
using     tcp           = boost::asio::ip::tcp;

#define WEBSOCKET websocket::stream<beast::ssl_stream<beast::tcp_stream>>
class QBClient;
class QBWebSocketSession : public boost::enable_shared_from_this<QBWebSocketSession>
{
    friend class QBClient;

public:
    // Resolver and socket require an io_context
    explicit QBWebSocketSession(const std::string& host,
                                const std::string& port);
    /// Run begins the process of connecting. It should be called ONLY ONCE
    /// from within the main thread. Subsequent reconnections are self-invoked
    /// as errors arise and is called from within QWebSocket::reset
    void run                ();
    /// QWebsocketSession::reset is called from within a handler when
    /// an asio system error-code is invoked.
    void reset              ();
    /// QWebSocketSession::stop must be called from the main thread.
    /// It cannot be invoked by a handler. This fact is extremely important
    void stop               ();

    // The following are asynchronous beast methods. Don't worry about them.
    void on_resolve         (beast::error_code ec, tcp::resolver::results_type results);
    void on_connect         (beast::error_code ec, tcp::resolver::results_type::endpoint_type ep);
    void on_ssl_handshake   (beast::error_code ec);
    void on_handshake       (beast::error_code ec);
    void on_write           (beast::error_code ec,std::size_t bytes);
    void on_read            (beast::error_code ec, std::size_t bytes_transferred);
    void on_close           (beast::error_code ec);
    void on_disconnected    ();

    bool isConnected() const;

protected:

    void setClient      (QBClient* _client);
    //// These methods are NOT strand-safe. They have local variables that
    /// will be destroyed when they exit scope. I will modify them in the future
    /// to correct this.
    void sendRequest    (const std::string &request);
    void sendObject     (boost::shared_ptr<const std::string> &response);

//signals:
//    void connectionStatusChanged();

//public slots:
//    void onApplicationClosing();

private:
    void connected          ();
    void disconnected       ();
    void responseReturned   (const QString& response);
    void objectReturned     (const void* ptr, size_t size);

    QBClient*                               _client;
    net::io_context                         _ioc;
    ssl::context                            _ssl;
    tcp::resolver                           _resolver;
    boost::shared_ptr<WEBSOCKET>            _ws;
    beast::flat_buffer                      _buffer;
    std::string                             _host;
    std::string                             _port;
    std::string                             _ep_port;
    std::vector<std::string>                _cachedWrites;
    bool                                    _connected;

    // Threads
    std::thread                             _io_thread;
    std::thread                             _safety_thread;
};

#endif // QBWEBSOCKETSESSION_H
