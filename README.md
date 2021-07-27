# University of Michigan Pathology Question Bank

---

This is the University of Michigan, Department of Pathology Education Question Bank System.\
Created by [Ryan Landvater, MD MEng](mailto:rylandva@med.umich.edu), and copyright 2020-2021.

The distributed application outlined here can be accessed on the [Apple App Store](https://apps.apple.com/us/app/michigan-pathology-qbank/id1538372884) for MacOS and iOS. 

Use of this system, modifications, and rebranding for your institution must adhere to the GNU Lesser General Public License v. 3 (“LGPL”) both with respect to the code provided here and with use of the underlying dependencies, including but not limited to the [Qt Framework LGPL](https://www.qt.io/licensing/open-source-lgpl-obligations#lgpl)(The Qt Company).

The Pathology education question bank client application ("the software") is provided as an open-source project and as such the software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. In no event shall the author(s) or any copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or use or other dealings in the software. *For more information regarding the license agreement, please see the **LICENSE** file within the repository.*

## Compiling the Client Application Source Code

The Pathology Education Question Bank System is designed to be an extremely light-weight and efficient application for use by Pathology Department Education Divisions. The source code is short, simple to understand, and has only a few dependencies. *A self contained shell and bat scripts will be provided to ease in installing these dependencies on your build machine in future releases.*\
\
**Question Bank Dependencies**:
- [Qt Framework](https://www.qt.io/cs/c/?cta_guid=074ddad0-fdef-4e53-8aa8-5e8a876d6ab4&signature=AAH58kGWPDMb4Vt-FpWM3pa4_ACvn9MZiQ&pageId=12602948080&placement_guid=99d9dd4f-5681-48d2-b096-470725510d34&click=5573bd8a-35f5-48ed-937f-f343d386e799&hsutk=6ac7991059b05733441880b12c807b49&canon=https%3A%2F%2Fwww.qt.io%2Fdownload-open-source&utm_referrer=https%3A%2F%2Fwww.qt.io%2Fdownload&portal_id=149513&contentType=standard-page&redirect_url=APefjpHQ3IUVCuwhIlY8v8wfyn4PkU_Go1o1gnYkDt3P9WhcCVFL_M8d1o8MW3sNlpwp2rQS2CUGomBHk7vo6Ir5ogi3MC6PIIMnHkO-_HMF_3pzg50wbiUb2UTGTjou1fW7fnze7M6vqgEINJkWp0dXJvQh2mCMENlH9ke9sPx1xRTVnqxXlz_0mbH-BLVft-Tt6DAp3gw-FO1AOH8l_iiHE3owOxR4eHExnxtra9VLo8PwerW7J04oddXsAl7LgMxap4bRwG4NAkV-3DUZU-tqa4rqTg-XZg&__hstc=152220518.6ac7991059b05733441880b12c807b49.1627262231051.1627262231051.1627262231051.1&__hssc=152220518.1.1627262231051&__hsfp=3820673171). By far the most significant (and onerous) dependency will be the Qt Framework. This framework is responsible for the user-interface markup language and any javascript interpretation, the compilation, and the cross-platform capabilities of the application.
- [Boost](https://www.boost.org). This project makes extensive use to the Boost peer-reviewed libraried including [Boost-Beast](https://www.boost.org/doc/libs/1_76_0/libs/beast/doc/html/index.html), developed by *Vinnie Falco*, for websocket communication. Most Boost dependencies are provided as header-only to avoid linking. There are only 2 non-header dependencies required (that must be pre-compiled prior to building):
    - system (used for a variety of reasons)
    - thread (used for mutithreaded routines involving image rendering)
- [Flat Buffers](https://google.github.io/flatbuffers/). The Flat-buffer serialization routine developed by Google (the Google game division) is used for high-speed serialization of question images for an optimum user experience.
- [OpenSSL](https://www.openssl.org). Used for the secure communication (secure websocket) / encryption.

**Dependencies *are by default* seached from within in the build folder with the following layout:**
> library
>>boost (include and lib)
>>
>>flatbuffers (include and lib)
>>
>>openssl (include and lib)

The coresponding lines that define the library search paths and header search paths within the *.pro* qmake file are defined in the following exerpts. 

**Custom dependency install locations are easy to integrate into your own build (especially if you have experience with cmake). Simply exchange the local search paths with the paths on your own build machine. *For example with the default OpenSSL install in C:/Program Files*:**\
`INCLUDEPATH += $$PWD/library/openssl/include`\
`DEPENDPATH += $$PWD/library/openssl/include`\
`LIBS += -L$$PWD/library/openssl/ -llibssl -llibcrypto`\
**becomes**\
`INCLUDEPATH += 'C:/Program Files/OpenSSL-Win64/include'`\
`DEPENDPATH += 'C:/Program Files/OpenSSL-Win64/include'`\
`LIBS += -L'C:/Program Files/OpenSSL-Win64/lib/' -llibssl -llibcrypto`


### Windows
```cmake
win32: {
    INCLUDEPATH += $$PWD/library/boost/include
    DEPENDPATH += $$PWD/library/boost/include
    INCLUDEPATH += $$PWD/library/openssl/include
    DEPENDPATH += $$PWD/library/openssl/include
    INCLUDEPATH += $$PWD/library/flatbuffers/include
    DEPENDPATH += $$PWD/library/flatbuffers/include
    #The following Qmake flags are required on windows builds due to large object files. Referencing the underlying methods of some objects due to use of large numbers template methods necessitates higher precision addresses (longs) when compiling with GCC for windows or MSVC:
    !win32-g++: QMAKE_CXXFLAGS += /bigobj -D_WIN32_WINNT_WIN10
    win32-g++:  QMAKE_CXXFLAGS += -Wa,-mbig-obj

    !win32-g++:CONFIG(release, debug|release): LIBS += -L$$PWD/library/boost/lib/ -llibboost_thread-vc142-mt-x64-1_73
    !win32-g++:CONFIG(debug, debug|release): LIBS +=  -L$$PWD/library/boost/lib/  -llibboost_thread-vc142-mt-gd-x64-1_73
    win32-g++: LIBS += -L$$PWD/library/boost/lib/ -lboost_thread-mgw8-mt-x64-1_73 -lwsock32 -lws2_32
    win32-g++: LIBS += -L$$PWD/library/lib -lflatbuffers
    !win32-g++: PRE_TARGETDEPS += C:/Boost/lib libboost_thread-vc142-mt-x64-1_73.lib

    win32: LIBS += -L'C:/Program Files/OpenSSL-Win64/lib/' -llibssl -llibcrypto

    !win32-g++: PRE_TARGETDEPS += 'C:/Program Files/OpenSSL-Win64/lib/libssl.lib'
    !win32-g++: PRE_TARGETDEPS += 'C:/Program Files/OpenSSL-Win64/lib/libcrypto.lib'
}
```

### MacOS

```cmake
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
```

### iOS

```cmake
ios: {
    INCLUDEPATH += $$PWD/library/boost/include
    DEPENDPATH += $$PWD/library/boost/include
    INCLUDEPATH += $$PWD/library/openssl/include
    DEPENDPATH += $$PWD/library/openssl/include
    INCLUDEPATH += $$PWD/library/flatbuffers/include
    DEPENDPATH += $$PWD/library/flatbuffers/include

    LIBS += -L$$PWD/library/iOS/ -lcrypto_IOS
    LIBS += -L$$PWD/library/iOS/ -lssl_IOS
    LIBS += -L$$PWD/library/iOS/ -lBoost_4_IOS
    LIBS += -L$$PWD/library/iOS/ -lflatbuffers_iOS

    #The following libraries are compiled specifically for the iOS operating system and can be used to distribute to Apple's Mobile Devices (iPad distribution).
    PRE_TARGETDEPS += $$PWD/library/iOS/libcrypto_IOS.a
    PRE_TARGETDEPS += $$PWD/library/iOS/libssl_IOS.a
    PRE_TARGETDEPS += $$PWD/library/iOS/libBoost_4_IOS.a
    PRE_TARGETDEPS += $$PWD/library/iOS/libflatbuffers_iOS.a
}
```

### Web Assembly (Enscripten)

You will likely notice that a **wasm** code block exists within the *.pro* file. While webassembly *(and thus browser support)* for a webapp version of the question bank is a future implementation, currently web assembly is not supported. 



## Defining the Build

For your department specific build, please modify the structure at the start of *main.cpp* to reflect your own version.

```cpp
#define DEBUG                   // UNCOMMENT FOR DEBUG BUILD (local server)
// Define application properties
struct properties {
    int majorVersion            = VERSION_MAJOR;
    int minorVersion            = VERSION_MINOR;
    int build                   = VERSION_BUILD;
    bool debug                  = false;
#ifdef DEBUG
    std::string IP              = "127.0.0.1";
    std::string port            = "8080";
    QString ApplicationName     = "Question Bank DEBUG BUILD";
#else
    std::string IP              = /*Your Unique server address*/;
    std::string port            = /*Your server's exposed port*/;
    QString ApplicationName     = "Michigan Pathology Question Bank";
#endif
    QString OrganizationName    = "Michigan Medicine Pathology";
    QString OrganizationDomain  = "pathology.med.umich.edu";
} properties;
```
