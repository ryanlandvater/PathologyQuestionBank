QT += quick
QT += widgets
QT += quickcontrols2
QT += svg

CONFIG += c++17
CONFIG += app_bundle

#APPLICATION_NAME = "Michigan Pathology QBank"
VERSION_MAJOR = 0
VERSION_MINOR = 5
VERSION_BUILD = 2
#ORGANIZATION_NAME = "Michigan Medicine"

DEFINES +=  "APPLICATION_NAME=$$APPLICATION_NAME"\
            "VERSION_MAJOR=$$VERSION_MAJOR"\
            "VERSION_MINOR=$$VERSION_MINOR"\
            "VERSION_BUILD=$$VERSION_BUILD"\
            "ORGANIZATION_NAME=$$ORGANIZATION_NAME"

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

!wasm: TARGET = "PathologyQbank"

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
        src/qbclient.cpp \
        src/qbimageprovider.cpp \
        src/qbwebsocketsession.cpp

RESOURCES += \
    resources/qml.qrc

TRANSLATIONS += \
    QbankClient_en_US.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

macx: ICON = "resources/assets/QBankIcon_small.icns"
win32: RC_ICONS += resources/assets/icon.ico

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    src/UI/components/LoginFrame.qml \
    src/UI/components/UserPane.qml \
    src/UI/login.qml

HEADERS += \
    src/QB_jsonNodes.hpp \
    src/qbclient.h \
    src/qbimageprovider.h \
    src/qbwebsocketsession.h \
    src/QBBuffer_generated.h

macx:{
    INCLUDEPATH += $$PWD/library/boost/include
    DEPENDPATH += $$PWD/library/boost/include
    INCLUDEPATH += $$PWD/library/openssl/include
    DEPENDPATH += $$PWD/library/openssl/include
    INCLUDEPATH += $$PWD/library/flatbuffers/include
    DEPENDPATH += $$PWD/library/flatbuffers/include

    LIBS += -L$$PWD/library/boost/lib/ -lboost_thread
    LIBS += -L$$PWD/library/openssl/libs/ -lssl -lcrypto
    LIBS += -L$$PWD/library/flatbuffers/lib/ -lflatbuffers

    PRE_TARGETDEPS += $$PWD/library/boost/lib/libboost_serialization.a
    PRE_TARGETDEPS += $$PWD/library/boost/lib/libboost_thread.a
}

ios: {
#    QMAKE_IOS_DEPLOYMENT_TARGET = 12.0
#    QMAKE_INFO_PLIST+= "NSPhotoLibraryUsageDescription
    INCLUDEPATH += $$PWD/library/boost/include
    DEPENDPATH += $$PWD/library/boost/include
#    INCLUDEPATH += $$PWD/library/openssl/include
#    DEPENDPATH += $$PWD/library/openssl/include
    INCLUDEPATH +="/usr/local/Cellar/openssl\@1.1/1.1.1h/include/"
    DEPENDPATH  +="/usr/local/Cellar/openssl\@1.1/1.1.1h/include/"
    INCLUDEPATH += $$PWD/library/flatbuffers/include
    DEPENDPATH += $$PWD/library/flatbuffers/include

    LIBS += -L$$PWD/library/iOS/ -lcrypto_IOS
    LIBS += -L$$PWD/library/iOS/ -lssl_IOS
    LIBS += -L$$PWD/library/iOS/ -lBoost_4_IOS
    LIBS += -L$$PWD/library/iOS/ -lflatbuffers_iOS

    PRE_TARGETDEPS += $$PWD/library/iOS/libcrypto_IOS.a
    PRE_TARGETDEPS += $$PWD/library/iOS/libssl_IOS.a
    PRE_TARGETDEPS += $$PWD/library/iOS/libBoost_4_IOS.a
    PRE_TARGETDEPS += $$PWD/library/iOS/libflatbuffers_iOS.a
}

wasm: {
#    unix:!macx: LIBS += -L$$PWD/webassembly/WASM/ -lboost_wasm
#    unix:!macx: LIBS += -L$$PWD/library/WASM/ -lssl -lcrypto
    QMAKE_LFLAGS_RELEASE -= --shared-memory
    QMAKE_LFLAGS_DEBUG -= --shared-memory
    QMAKE_CFLAGS -= --shared-memory
    QMAKE_CFLAGS += --without-pthread
    QMAKE_LFLAGS += -s TOTAL_MEMORY=33554432 -s USE_PTHREADS=1 -s PTHREAD_POOL_SIZE=8 -s WASM_MEM_MAX=33554432

    INCLUDEPATH += $$PWD/webassembly/boost_wasm/include
    DEPENDPATH += $$PWD/webassembly/boost_wasm/include
    INCLUDEPATH += $$PWD/webassembly/flatbuffers_wasm/include
    DEPENDPATH += $$PWD/webassembly/flatbuffers_wasm/include
    INCLUDEPATH += $$PWD/webassembly/openssl_wasm/include
    DEPENDPATH += $$PWD/webassembly/openssl_wasm/include

    LIBS += -L$$PWD/webassembly/boost_wasm/lib/ -lboost_wasm
    LIBS += -L$$PWD/webassembly/flatbuffers_wasm/lib/ -lflatbuffers
    LIBS += -L$$PWD/webassembly/openssl_wasm/lib/ -lcrypto -lssl

    PRE_TARGETDEPS += $$PWD/webassembly/boost_wasm/lib/libboost_wasm.a
    PRE_TARGETDEPS += $$PWD/webassembly/flatbuffers_wasm/lib/libflatbuffers.a
    PRE_TARGETDEPS += $$PWD/webassembly/openssl_wasm/lib/libcrypto.a
    PRE_TARGETDEPS += $$PWD/webassembly/openssl_wasm/lib/libssl.a

}

win32: {
    INCLUDEPATH += $$PWD/dependencies/include
    DEPENDPATH += $$PWD/dependencies/include
    LIBS += -L$$PWD\dependencies\lib -llibssl -llibcrypto

    !win32-g++: QMAKE_CXXFLAGS += /bigobj -D_WIN32_WINNT_WIN10
    win32-g++:  QMAKE_CXXFLAGS += -g -m64 -Wa,-mbig-obj -DCMAKE_CXX_FLAGS=-O2

#    !win32-g++:CONFIG(release, debug|release): LIBS += -L'C:/Boost/lib/' -llibboost_thread-vc142-mt-x64-1_73
#    !win32-g++:CONFIG(debug, debug|release): LIBS +=  -L'C:/Boost/lib/'  -llibboost_thread-vc142-mt-gd-x64-1_73
#    win32-g++: LIBS += -LC:/Boost/lib/ -lboost_thread-mgw8-mt-x64-1_73 -lwsock32 -lws2_32
#    win32-g++: LIBS += -LC:/FlatBuffers/lib -lflatbuffers

#    !win32-g++: PRE_TARGETDEPS += C:/Boost/lib/libboost_thread-vc142-mt-x64-1_73.lib

#    win32: LIBS += -L'C:/Program Files/OpenSSL-Win64/lib/' -llibssl -llibcrypto

#    !win32-g++: PRE_TARGETDEPS += 'C:/Program Files/OpenSSL-Win64/lib/libssl.lib'
##    win32-g++: PRE_TARGETDEPS += 'C:/Program Files/OpenSSL-Win64/lib/liblibssl_static.a'
#    !win32-g++: PRE_TARGETDEPS += 'C:/Program Files/OpenSSL-Win64/lib/libcrypto.lib'
##    win32-g++: PRE_TARGETDEPS += 'C:/Program Files/OpenSSL-Win64/lib/liblibcrypto_static.a'

}
