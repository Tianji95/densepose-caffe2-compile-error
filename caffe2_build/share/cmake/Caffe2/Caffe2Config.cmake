# - Config file for the Caffe2 package
# It defines the following variable(s)
#   CAFFE2_INCLUDE_DIRS     - include directories for FooBar
# as well as Caffe2 targets for other cmake libraries to use.

# library version information

set(CAFFE2_VERSION_MAJOR 0)
set(CAFFE2_VERSION_MINOR 8)
set(CAFFE2_VERSION_PATCH 1)
set(CAFFE2_VERSION "0.8.1")

# Depending on whether Caffe2 uses gflags during compile time or
# not, invoke gflags.
if (ON)
  include("${CMAKE_CURRENT_LIST_DIR}/public/gflags.cmake")
  if (NOT TARGET gflags)
    message(FATAL_ERROR
        "Your installed Caffe2 version uses gflags but the gflags library "
        "cannot be found. Did you accidentally remove it, or have you set "
        "the right CMAKE_PREFIX_PATH and/or GFLAGS_ROOT_DIR? If you do not "
        "have gflags, you will need to install gflags and set the library "
        "path accordingly.")
  endif()
endif()

# Depending on whether Caffe2 uses glog during compile time or
# not, invoke glog.
if (ON)
  include("${CMAKE_CURRENT_LIST_DIR}/public/glog.cmake")
  if (NOT TARGET glog::glog)
    message(FATAL_ERROR
        "Your installed Caffe2 version uses glog but the glog library "
        "cannot be found. Did you accidentally remove it, or have you set "
        "the right CMAKE_PREFIX_PATH and/or GFLAGS_ROOT_DIR? If you do not "
        "have glog, you will need to install glog and set the library "
        "path accordingly.")
  endif()
endif()

# import targets
include ("${CMAKE_CURRENT_LIST_DIR}/Caffe2Targets.cmake")

# include directory.
#
# Newer versions of CMake set the INTERFACE_INCLUDE_DIRECTORIES property
# of the imported targets. It is hence not necessary to add this path
# manually to the include search path for targets which link to gflags.
# The following lines are here for backward compatibility, in case one
# would like to use the old-style include path.
get_filename_component(
    CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
# Note: the current list dir is _INSTALL_PREFIX/share/cmake/Gloo.
get_filename_component(
    _INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)
set(CAFFE2_INCLUDE_DIRS "${_INSTALL_PREFIX}/include")
