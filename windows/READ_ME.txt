In order to deploy, dynamic libraries and QML files must be included. This is perfomred throgh the Qt/version/compiler_kit/bin/windeployqt.exe PASSING the arguments --qmldir xxxx with the root QML directory (PROJECT_DIR/resources)

TO IMPLEMENT IN VISUAL STUDIO (post build script):
$(QMake_QT_INSTALL_LIBEXECS_)\windeployqt.exe --qmldir $(ProjectDir)\resources $(TargetDir)\$(TargetFileName)