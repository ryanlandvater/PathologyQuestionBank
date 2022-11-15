#   init_repo.sh
#   Initialize the Iris Codec Repositiory
#   This pulls depenent git repos from their respective source repositories
#   to allow for building the Iris Codec.
#
#   Created 08/02/2022
#   Copyright 2022 Ryan Landvater, MD MEng

# Establish the static directory path and dependency path
# for the given platform.
if [ "$(uname)" == "Darwin" ]
then
  DIR_PATH=$(pwd)
  DEP_PATH=$DIR_PATH/dependencies
else
  set DIR_PATH=%CD%
  set DEP_PATH=%DIR_PATH%/dependencies

  cmake -B %DEP_PATH%\flatbuffers\build -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=%DEP_PATH% %DEP_PATH%\flatbuffers
  cmake --build %DEP_PATH%\flatbuffers\build
  cmake --install %DEP_PATH%\flatbuffers\build

  cd %DEP_PATH%\boost
  git submodule update --init ./libs/align/
  git submodule update --init ./libs/asio/
  git submodule update --init ./libs/assert/
  git submodule update --init ./libs/beast/
  git submodule update --init ./libs/bind/
  git submodule update --init ./libs/core
  git submodule update --init ./libs/config
  git submodule update --init ./libs/config
  git submodule update --init ./libs/date_time/
  git submodule update --init ./libs/endian/
  git submodule update --init ./libs/exception/
  git submodule update --init ./libs/filesystem/
  git submodule update --init ./libs/interprocess/
  git submodule update --init ./libs/intrusive/
  git submodule update --init ./libs/io/
  git submodule update --init ./libs/logic/
  git submodule update --init ./libs/move/
  git submodule update --init ./libs/mpl/
  git submodule update --init ./libs/mp11/
  git submodule update --init ./libs/numeric/
  git submodule update --init ./libs/optional/
  git submodule update --init ./libs/predef/
  git submodule update --init ./libs/preprocessor/
  git submodule update --init ./libs/program_options/
  git submodule update --init ./libs/smart_ptr/
  git submodule update --init ./libs/static_assert/
  git submodule update --init ./libs/system/
  git submodule update --init ./libs/throw_exception/
  git submodule update --init ./libs/type_traits/
  git submodule update --init ./libs/tuple/
  git submodule update --init ./libs/utility/
  git submodule update --init ./libs/winapi

  cd %DEP_PATH%
  xcopy -r ./boost/libs/align/ ./include/boost/align /E/H
  xcopy -r ./boost/libs/asio/ ./include/boost/asio /E/H
  xcopy -r ./boost/libs/assert/ ./include/boost/assert /E/H
  xcopy -r ./boost/libs/beast/ ./include/boost/beast /E/H
  xcopy -r ./boost/libs/bind/ ./include/boost/bind /E/H
  xcopy -r ./boost/libs/core ./include/boost/core /E/H
  xcopy -r ./boost/libs/config ./include/boost/config /E/H
  xcopy -r ./boost/libs/date_time/ ./include/boost/date_time /E/H
  xcopy -r ./boost/libs/endian/ ./include/boost/endian /E/H
  xcopy -r ./boost/libs/exception/ ./include/boost/exception /E/H
  xcopy -r ./boost/libs/filesystem/ ./include/boost/filesystem /E/H
  xcopy -r ./boost/libs/interprocess/ ./include/boost/interprocess /E/H
  xcopy -r ./boost/libs/intrusive/ ./include/boost/intrusive /E/H
  xcopy -r ./boost/libs/io/ ./include/boost/io /E/H
  xcopy -r ./boost/libs/logic/ ./include/boost/logic /E/H
  xcopy -r ./boost/libs/move/ ./include/boost/move /E/H
  xcopy -r ./boost/libs/mpl/ ./include/boost/mpl /E/H
  xcopy -r ./boost/libs/mp11/ ./include/boost/mp11 /E/H
  xcopy -r ./boost/libs/numeric/ ./include/boost/numeric /E/H
  xcopy -r ./boost/libs/optional/ ./include/boost/optional /E/H
  xcopy -r ./boost/libs/predef/ ./include/boost/predef /E/H
  xcopy -r ./boost/libs/preprocessor/ ./include/boost/preprocessor /E/H
  xcopy -r ./boost/libs/smart_ptr/ ./include/boost/smart_ptr /E/H
  xcopy -r ./boost/libs/static_assert/ ./include/boost/static_assert /E/H
  xcopy -r ./boost/libs/system/ ./include/boost/system /E/H
  xcopy -r ./boost/libs/throw_exception/ ./include/boost/throw_exception /E/H
  xcopy -r ./boost/libs/type_traits/ ./include/boost/type_traits /E/H
  xcopy -r ./boost/libs/tuple/ ./include/boost/tuple /E/H
  xcopy -r ./boost/libs/utility/ ./include/boost/utility /E/H
fi
