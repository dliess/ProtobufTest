cmake_minimum_required(VERSION 3.15)
set(CMAKE_DEBUG_POSTFIX _g)

project(ProtobufTest)


find_package(Protobuf CONFIG REQUIRED)
message(STATUS "Using protobuf ${protobuf_VERSION}")

set(PROTO_GEN_SRC_DIR ${CMAKE_CURRENT_BINARY_DIR}/proto-src)
file(MAKE_DIRECTORY ${PROTO_GEN_SRC_DIR})

option(USE_PROTOBUF_GENERATE "Use the protobuf-provided method" "ON")
if(USE_PROTOBUF_GENERATE)
   add_library(GeneratedLib STATIC "dummy.cpp")
   target_include_directories(GeneratedLib PUBLIC ${PROTO_GEN_SRC_DIR})
   protobuf_generate(
      LANGUAGE cpp
      TARGET GeneratedLib 
      PROTOS ${CMAKE_CURRENT_SOURCE_DIR}/protos/BaseService.proto
      PROTOC_OUT_DIR "${PROTO_GEN_SRC_DIR}"
   )
else(USE_PROTOBUF_GENERATE)
   include_directories(${PROTO_GEN_SRC_DIR})

   # Proto file
   get_filename_component(hw_proto "${CMAKE_CURRENT_SOURCE_DIR}/protos/BaseService.proto" ABSOLUTE)
   get_filename_component(hw_proto_path "${hw_proto}" PATH)
   get_filename_component(hw_proto_basename "${hw_proto}" NAME_WE)

   set(hw_proto_srcs "${PROTO_GEN_SRC_DIR}/${hw_proto_basename}.pb.cc")
   set(hw_proto_hdrs "${PROTO_GEN_SRC_DIR}/${hw_proto_basename}.pb.h")
   
   add_library(GeneratedLib STATIC
   ${hw_proto_srcs}
   ${hw_proto_hdrs}
   )
   set(_PROTOBUF_PROTOC $<TARGET_FILE:protobuf::protoc>)
   add_custom_command(
      OUTPUT  "${hw_proto_srcs}" "${hw_proto_hdrs}"
      COMMAND ${_PROTOBUF_PROTOC}
      ARGS 
         --cpp_out "${PROTO_GEN_SRC_DIR}"
         -I "${hw_proto_path}"
         "${hw_proto}"
      DEPENDS "${hw_proto}"
      )
endif(USE_PROTOBUF_GENERATE)
      
target_include_directories(GeneratedLib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(GeneratedLib 
   PUBLIC protobuf::libprotobuf
)

include(GNUInstallDirs)
install(TARGETS GeneratedLib
   ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)