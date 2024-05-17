vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if (VCPKG_TARGET_IS_WINDOWS)
	set(SLANG_EXE_SUFFIX ".exe")
	set(SLANG_LIB_PREFIX "")
	set(SLANG_LIB_SUFFIX ".lib")
	set(SLANG_DYNLIB_SUFFIX ".dll")
	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
		vcpkg_download_distfile(
			ARCHIVE
			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win64.zip"
			FILENAME "slang-${VERSION}-win64.zip"
			SHA512 c0878ea18e4ef8e9bfa37a3d2975b73dd3bce7c5ff117f5bb3b6fbf05b7cb95190fc253c03ccd8f17e377ab59bcab62cdaccaf00da5c1218a99dc84fffd4225a
		)
		set(SLANG_BIN_PATH "bin/windows-x64/release")
	# elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
	# 	vcpkg_download_distfile(
	# 		ARCHIVE
	# 		URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-win32.zip"
	# 		FILENAME "slang-${VERSION}-win32.zip"
	# 		SHA512 e64c8c5a46c2288ea51a768c525cbd79990c76f8a239e21fb0bcfa896e06437165a10d7dba9812485d934292aac7c173a6e7233369d77711f03c5eed4f6fd47a
	# 	)
	# 	set(SLANG_BIN_PATH "bin/windows-x86/release")
	else()
		message(FATAL_ERROR "Unsupported platform. Please implement me!")
	endif()
# elseif (VCPKG_TARGET_IS_OSX)
# 	set(SLANG_EXE_SUFFIX "")
# 	set(SLANG_LIB_PREFIX "lib")
# 	set(SLANG_LIB_SUFFIX ".a")
# 	set(SLANG_DYNLIB_SUFFIX ".dylib")
# 	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
# 		vcpkg_download_distfile(
# 			ARCHIVE
# 			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-x64.zip"
# 			FILENAME "slang-${VERSION}-macos-x64.zip"
# 			SHA512 fbf6994dab9afe0a20853d2417b11f0d7436a6ca96c9124c0239fe421bf697f970c0f28b1e5c67aa36b3a0b5b8f7260214aa6587bcc95a1d55ffeac8446c46d4
# 		)
# 		set(SLANG_BIN_PATH "bin/macos-x64/release")
# 	elseif (VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
# 		vcpkg_download_distfile(
# 			ARCHIVE
# 			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-macos-aarch64.zip"
# 			FILENAME "slang-${VERSION}-macos-aarch64.zip"
# 			SHA512 87025c2bd3537b4730cfac9f2c954b92d696b7cf71595cebe1199cd94baa4f90d80678efa440e56767a3a4d52d993301ffd9d54f27dc547094b136793331baa5
# 		)
# 		set(SLANG_BIN_PATH "bin/macos-aarch64/release")
# 	else()
# 		message(FATAL_ERROR "Unsupported platform. Please implement me!")
# 	endif()
# elseif(VCPKG_TARGET_IS_LINUX)
# 	set(SLANG_EXE_SUFFIX "")
# 	set(SLANG_LIB_PREFIX "lib")
# 	set(SLANG_LIB_SUFFIX ".a")
# 	set(SLANG_DYNLIB_SUFFIX ".so")
# 	if (VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
# 		vcpkg_download_distfile(
# 			ARCHIVE
# 			URLS "https://github.com/shader-slang/slang/releases/download/v${VERSION}/slang-${VERSION}-linux-x86_64.tar.gz"
# 			FILENAME "slang-${VERSION}-linux-x86_64.tar.gz"
# 			SHA512 b6ac7a41dc3278974887ebb21b7abc6df75df0da77dc36e64e71f1740ff34a8724ddda3cdc04f4c14569c4085586f7ea50de0859799658c5c3bf59b93de98e5e
# 		)
# 		set(SLANG_BIN_PATH "bin/linux-x64/release")
# 	else()
# 		message(FATAL_ERROR "Unsupported platform. Please implement me!")
# 	endif()
else()
	message(FATAL_ERROR "Unsupported platform. Please implement me!")
endif()

vcpkg_extract_source_archive(
	BINDIST_PATH
	ARCHIVE "${ARCHIVE}"
	NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-llvm${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang-glslang${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/slangc${SLANG_EXE_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

if (VCPKG_TARGET_IS_WINDOWS)
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/${SLANG_LIB_PREFIX}slang${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_LIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
	file(INSTALL "${BINDIST_PATH}/${SLANG_BIN_PATH}/gfx${SLANG_DYNLIB_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(CONFIGURE OUTPUT "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}Config.cmake" CONTENT [=[

if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 2.8)
   message(FATAL_ERROR "CMake >= 2.8.0 required")
endif()
if(CMAKE_VERSION VERSION_LESS "2.8.3")
   message(FATAL_ERROR "CMake >= 2.8.3 required")
endif()
cmake_policy(PUSH)
cmake_policy(VERSION 2.8.3...3.25)

set(CMAKE_IMPORT_FILE_VERSION 1)

# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
	set(_IMPORT_PREFIX "")
endif()

# Create imported target glfw
add_library(slang::slang SHARED IMPORTED)

set_target_properties(slang::slang PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
	LINKER_LANGUAGE CXX
)

set_property(TARGET slang::slang APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(slang::slang PROPERTIES
	IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib/slang.lib"
	IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin/slang.dll"
  )
list(APPEND _cmake_import_check_targets slang::slang)
list(APPEND _cmake_import_check_files_for_slang::slang "${_IMPORT_PREFIX}/debug/lib/slang.lib" "${_IMPORT_PREFIX}/debug/bin/slang.dll")

set_property(TARGET slang::slang APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(slang::slang PROPERTIES
	IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/slang.lib"
	IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/slang.dll"
  )
list(APPEND _cmake_import_check_targets slang::slang)
list(APPEND _cmake_import_check_files_for_slang::slang "${_IMPORT_PREFIX}/lib/slang.lib" "${_IMPORT_PREFIX}/bin/slang.dll")

add_library(slang::glslang MODULE IMPORTED)
set_target_properties(slang::glslang PROPERTIES
	IMPORTED_LOCATION "${_IMPORT_PREFIX}/bin/slang-glslang.dll"
	LINKER_LANGUAGE CXX
)
add_dependencies(slang::slang slang::glslang)

# Cleanup temporary variables.
set(_IMPORT_PREFIX)

# Loop over all imported files and verify that they actually exist
foreach(_cmake_target IN LISTS _cmake_import_check_targets)
  foreach(_cmake_file IN LISTS "_cmake_import_check_files_for_${_cmake_target}")
    if(NOT EXISTS "${_cmake_file}")
      message(FATAL_ERROR "The imported target \"${_cmake_target}\" references the file
   \"${_cmake_file}\"
but this file does not exist.  Possible reasons include:
* The file was deleted, renamed, or moved to another location.
* An install or uninstall procedure did not complete successfully.
* The installation package was faulty and contained
   \"${CMAKE_CURRENT_LIST_FILE}\"
but not all the files it references.
")
    endif()
  endforeach()
  unset(_cmake_file)
  unset("_cmake_import_check_files_for_${_cmake_target}")
endforeach()
unset(_cmake_target)
unset(_cmake_import_check_targets)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)
]=]
@ONLY)

file(GLOB HEADERS "${BINDIST_PATH}/*.h")
file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO shader-slang/slang
	REF v${VERSION}
	SHA512 f43a669fe6a79f1b5f38d3344ed14a057be9003d86a00dcea1f874825a1d3e2af3216d054b9a7170a861e22cedf8809cd5c06bc24adf3062d9fe813327ff4e7e
	HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
