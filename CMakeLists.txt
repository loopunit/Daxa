cmake_minimum_required(VERSION 3.28)

include("${CMAKE_CURRENT_LIST_DIR}/cmake/warnings.cmake")

if(DAXA_ENABLE_UTILS_TASK_GRAPH)
set(DAXA_ENABLE_UTILS_MEM true)
endif()

project(daxa VERSION 3.0.2)

include(FetchContent)
#include("${CMAKE_CURRENT_LIST_DIR}/cmake/deps.cmake")

if(DAXA_ENABLE_STATIC_ANALYSIS)
    set(CPPCHECK_TEMPLATE "gcc")
    find_program(CPPCHECK cppcheck)
    find_program(CLANG_TIDY clang-tidy)
    if(CPPCHECK)
        set(CMAKE_CXX_CPPCHECK
            ${CPPCHECK}
            --template=${CPPCHECK_TEMPLATE}
            --enable=style,performance,warning,portability
            --inline-suppr
            --suppress=cppcheckError
            --suppress=internalAstError
            --suppress=unmatchedSuppression
            --suppress=preprocessorErrorDirective
            --suppress=exceptThrowInDestructor
            --suppress=functionStatic
            --inconclusive)
    endif()
    if(CLANG_TIDY)
        set(CMAKE_CXX_CLANG_TIDY
            ${CLANG_TIDY}
            --fix)
    endif()
else()
    # TODO(capi): re-enable when not dealing with the compile errors.
    # Also, the features in the CMakePresets are disabled for now
    set(CMAKE_UNITY_BUILD true)
endif()

add_library(daxa
    "src/cpp_wrapper.cpp"

    "src/impl_device.cpp"
    "src/impl_features.cpp"
    "src/impl_instance.cpp"
    "src/impl_core.cpp"
    "src/impl_pipeline.cpp"
    "src/impl_swapchain.cpp"
    "src/impl_command_recorder.cpp"
    "src/impl_gpu_resources.cpp"
    "src/impl_sync.cpp"
    "src/impl_dependencies.cpp"
    "src/impl_timeline_query.cpp"

    "src/utils/impl_task_graph_ui.cpp"
    "src/utils/impl_resource_viewer.cpp"
    "src/utils/impl_task_graph.cpp"
    "src/utils/impl_imgui.cpp"
    "src/utils/impl_fsr2.cpp"
    "src/utils/impl_mem.cpp"
    "src/utils/impl_pipeline_manager.cpp"
)

add_library(daxa::daxa ALIAS daxa)

if(BUILD_SHARED_LIBS)
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        target_compile_definitions(${PROJECT_NAME}
            PRIVATE "$<IF:$<CXX_COMPILER_ID:Clang>,DAXA_CMAKE_EXPORT=[[gnu::dllexport]],DAXA_CMAKE_EXPORT=__declspec(dllexport)>"
            INTERFACE "$<IF:$<CXX_COMPILER_ID:Clang>,DAXA_CMAKE_EXPORT=[[gnu::dllimport]],DAXA_CMAKE_EXPORT=__declspec(dllimport)>")
    else()
        target_compile_definitions(${PROJECT_NAME}
            PUBLIC "DAXA_CMAKE_EXPORT=")
    endif()
else()
    target_compile_definitions(${PROJECT_NAME}
        PUBLIC "DAXA_CMAKE_EXPORT=")
endif()

target_compile_features(daxa PUBLIC cxx_std_20)

target_compile_definitions(daxa
    PUBLIC
    $<BUILD_INTERFACE:DAXA_SHADER_INCLUDE_DIR="${CMAKE_CURRENT_LIST_DIR}/include">
)

if(DAXA_USE_STATIC_CRT AND CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

if(DAXA_ENABLE_UTILS_FSR2)
    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_FSR2=true
    )
    target_link_libraries(daxa
        PRIVATE
        ffx_sdk::ffx_sdk
    )
endif()

if(DAXA_ENABLE_UTILS_IMGUI)
    FetchContent_Declare(
        imgui
        GIT_REPOSITORY https://github.com/ocornut/imgui
        GIT_TAG        v1.92.6-docking
    )

    FetchContent_GetProperties(imgui)
    if(NOT imgui_POPULATED)
        FetchContent_MakeAvailable(imgui)

        target_sources(daxa
        PRIVATE
            ${imgui_SOURCE_DIR}/imgui.cpp
            ${imgui_SOURCE_DIR}/imgui_demo.cpp
            ${imgui_SOURCE_DIR}/imgui_draw.cpp
            ${imgui_SOURCE_DIR}/imgui_widgets.cpp
            ${imgui_SOURCE_DIR}/imgui_tables.cpp)

        target_include_directories(daxa SYSTEM
        PRIVATE
            ${imgui_SOURCE_DIR}
            ${imgui_SOURCE_DIR}/backends
            ${Vulkan_INCLUDE_DIRS})
        if(NOT (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"))
            target_compile_options(daxa PRIVATE -Wno-nontrivial-memcall)
        endif()

        if(DAXA_ENABLE_GLFW)
            if(TARGET glfw)
                target_sources(daxa PRIVATE ${imgui_SOURCE_DIR}/backends/imgui_impl_glfw.cpp)
                target_link_libraries(daxa PRIVATE glfw)
                target_include_directories(daxa SYSTEM PUBLIC ${glfw_SOURCE_DIR}/include)
            endif()
        endif()

        if(DAXA_ENABLE_SDL3)
            find_package(SDL3 CONFIG REQUIRED)
            target_sources(daxa PRIVATE ${imgui_SOURCE_DIR}/backends/imgui_impl_sdl3.cpp)
            target_link_libraries(daxa PRIVATE SDL3::SDL3)
            target_include_directories(daxa SYSTEM PUBLIC ${SDL_INCLUDE_DIR})
        endif()
    endif()

    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_IMGUI=true
    )
endif()
if(DAXA_ENABLE_UTILS_MEM)
    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_MEM=true
    )
endif()
if(DAXA_ENABLE_UTILS_PIPELINE_MANAGER_GLSLANG)
    find_package(glslang CONFIG REQUIRED)
    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_PIPELINE_MANAGER_GLSLANG=true
    )
    target_link_libraries(daxa
        PRIVATE
        glslang::glslang
        glslang::SPIRV
    )
endif()
if(DAXA_ENABLE_UTILS_PIPELINE_MANAGER_SLANG)
    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_PIPELINE_MANAGER_SLANG=true
    )
    target_link_libraries(daxa PRIVATE slang::slang slang::glslang)
endif()
if(DAXA_ENABLE_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION)
    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_PIPELINE_MANAGER_SPIRV_VALIDATION=true
    )
    find_package(SPIRV-Tools CONFIG REQUIRED)
    target_link_libraries(daxa
        PRIVATE
        SPIRV-Tools-static
    )
endif()
if(DAXA_ENABLE_UTILS_TASK_GRAPH)
    target_compile_definitions(daxa
        PUBLIC
        DAXA_BUILT_WITH_UTILS_TASK_GRAPH=true
    )
endif()

find_package(Vulkan REQUIRED)

find_package(VulkanMemoryAllocator CONFIG REQUIRED)

target_link_libraries(daxa
    PRIVATE
    GPUOpen::VulkanMemoryAllocator
    Vulkan::Vulkan
)

target_include_directories(daxa
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if(NOT DAXA_FORCE_WAYLAND)
        find_package(X11)
        if(X11_FOUND)
            target_compile_definitions(daxa
                PUBLIC
                DAXA_BUILT_WITH_X11=true
            )
            target_link_libraries(daxa
                PRIVATE
                ${X11_LIBRARIES}
            )
        endif()
    endif()

    find_package(PkgConfig)
    if(PkgConfig_FOUND)
        pkg_check_modules(WAYLAND_CLIENT wayland-client)
        pkg_check_modules(WAYLAND_CURSOR wayland-cursor)
        pkg_check_modules(WAYLAND_EGL wayland-egl)
        pkg_check_modules(XKBCOMMON xkbcommon)

        if(WAYLAND_CLIENT_FOUND AND WAYLAND_CURSOR_FOUND AND WAYLAND_EGL_FOUND AND XKBCOMMON_FOUND)
            target_compile_definitions(daxa
                    PUBLIC
                    DAXA_BUILT_WITH_WAYLAND=true
            )
            target_include_directories(daxa
                    PRIVATE
                    ${WAYLAND_CLIENT_INCLUDE_DIRS}
                    ${WAYLAND_CURSOR_INCLUDE_DIRS}
                    ${WAYLAND_EGL_INCLUDE_DIRS}
                    ${XKBCOMMON_INCLUDE_DIRS}
            )
            target_link_libraries(daxa
                    PRIVATE
                    ${WAYLAND_CLIENT_LIBRARIES}
                    ${WAYLAND_CURSOR_LIBRARIES}
                    ${WAYLAND_EGL_LIBRARIES}
                    ${XKBCOMMON_LIBRARIES}
            )
            message(STATUS "Found wayland-client, version ${WAYLAND_CLIENT_VERSION}")
            message(STATUS "Found wayland-cursor, version ${WAYLAND_CURSOR_VERSION}")
            message(STATUS "Found wayland-egl, version ${WAYLAND_EGL_VERSION}")
            message(STATUS "Found xkbcommon, version ${XKBCOMMON_VERSION}")
        endif()
    endif()
endif()

set_project_warnings(daxa)

if(DAXA_ENABLE_TESTS)
    add_subdirectory(tests)
endif()

if(DAXA_ENABLE_TOOLS)
    add_executable(daxa_tools_compile_imgui_shaders "src/utils/impl_imgui.cpp")
    target_compile_definitions(daxa_tools_compile_imgui_shaders PRIVATE DAXA_COMPILE_IMGUI_SHADERS=true)
    target_link_libraries(daxa_tools_compile_imgui_shaders PRIVATE daxa::daxa GPUOpen::VulkanMemoryAllocator Vulkan::Vulkan)

    add_executable(daxa_tools_compile_resource_viewer_shaders "src/utils/impl_resource_viewer_compile_shaders.cpp")
    target_compile_definitions(daxa_tools_compile_resource_viewer_shaders PRIVATE DAXA_COMPILE_RESOURCE_VIEWER_SHADERS=true)
    target_link_libraries(daxa_tools_compile_resource_viewer_shaders PRIVATE daxa::daxa GPUOpen::VulkanMemoryAllocator Vulkan::Vulkan)
endif()

if (DAXA_ENABLE_INSTALL)
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)

    set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/daxa)

    install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/" DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

    install(TARGETS daxa EXPORT daxa-targets
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    install(EXPORT daxa-targets
        FILE daxaTargets.cmake
        NAMESPACE daxa::
        DESTINATION ${INSTALL_CONFIGDIR}
    )

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/daxaConfigVersion.cmake
        COMPATIBILITY AnyNewerVersion
    )

    configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/daxaConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/daxaConfig.cmake
        INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
    )

    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/daxaConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/daxaConfigVersion.cmake
        DESTINATION ${INSTALL_CONFIGDIR}
    )
endif()
