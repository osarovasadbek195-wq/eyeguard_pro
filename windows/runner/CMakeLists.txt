cmake_minimum_required(VERSION 3.14)
project(eyeguard_pro LANGUAGES CXX)

# The name of the executable created for the application
set(BINARY_NAME "eyeguard_pro")

# Explicitly opt in to modern CMake behaviors to avoid warnings
# with recent versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()

# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Custom plugins
add_library(autostart_plugin STATIC autostart_plugin.cpp)
add_library(filter_plugin STATIC filter_plugin.cpp)

target_include_directories(autostart_plugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(filter_plugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(${BINARY_NAME} PRIVATE autostart_plugin filter_plugin)

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
# Support files are copied into place next to the executable, so that it can
# run in place. This is done instead of making a separate bundle (as on Linux)
# so that building and running from within Visual Studio will work.
set(BUILD_BUNDLE true)
if(BUILD_BUNDLE)
    # Install the executable and ICU and plugin data into a subdirectory to
    # allow for a clean build with a clean bundle.
    set(INSTALL_BUNDLE_DIR "${PROJECT_BINARY_DIR}/runner/${CMAKE_INSTALL_CONFIG_NAME}")
    set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}")
    
    install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${INSTALL_BUNDLE_DIR}" COMPONENT Runtime)
    
    install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DIR}" COMPONENT Runtime)
    install(FILES "${FLUTTER_LIBRARY_OUTPUT_PATH}" DESTINATION "${INSTALL_BUNDLE_DIR}" COMPONENT Runtime)
    
    if(PLUGIN_BUNDLED_LIBRARIES)
      install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
        DESTINATION "${INSTALL_BUNDLE_DIR}"
        COMPONENT Runtime)
    endif()
    
    # Collect all assets that will be installed.
    set(ASSET_FILES_NAME ".flutter-plugins-assets")
    set(ASSET_FILES_PATH "${CMAKE_CURRENT_BINARY_DIR}/${ASSET_FILES_NAME}")
    
    # These reconfiguration commands are only necessary when building from
    # source, but they are safe to run regardless.
    file(WRITE "${ASSET_FILES_PATH}" "")
    foreach(PLUGIN ${FLUTTER_PLUGIN_LIST})
        foreach(ASSET ${${PLUGIN}_ASSETS})
            file(APPEND "${ASSET_FILES_PATH}" "${ASSET}\n")
        endforeach()
    endforeach()
    
    # Reconfigure the build to add the newly discovered assets.
    include(${ASSET_FILES_PATH})
    
    install(FILES ${ASSET_FILES} DESTINATION "${INSTALL_BUNDLE_DIR}/data" COMPONENT Runtime)
    
    # Install the AOT library on non-Debug builds only.
    install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DIR}" CONFIGURATIONS Profile;Release
            COMPONENT Runtime)
    
    # Fully re-copy the assets directory on each build to avoid having stale files
    # from a previous install.
    set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
    set(FLUTTER_ASSET_DIR "${CMAKE_CURRENT_BINARY_DIR}/${FLUTTER_ASSET_DIR_NAME}")
    
    # Make the ${FLUTTER_ASSET_DIR} directory which will contain the assets.
    make_directory(${FLUTTER_ASSET_DIR})
    
    # Copy all the assets.
    foreach(ASSET ${FLUTTER_LIBRARY_ASSETS})
        file(COPY ${ASSET} DESTINATION ${FLUTTER_ASSET_DIR})
    endforeach()
    
    # Copy the assets into the build directory on each build.
    add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${FLUTTER_ASSET_DIR}
        ${INSTALL_BUNDLE_DIR}/data/${FLUTTER_ASSET_DIR_NAME})
endif()
