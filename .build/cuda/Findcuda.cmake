set(TARGET_WITH_NAMESPACE "3rdParty::cuda")
if (TARGET ${TARGET_WITH_NAMESPACE})
	return()
endif()

set(MY_NAME "cuda")
set(${MY_NAME}_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/${MY_NAME}/include")
set(${MY_NAME}_LIBS_DIR ${CMAKE_CURRENT_LIST_DIR}/${MY_NAME}/lib)

set(CUAD_LIB_PATH ${${MY_NAME}_LIBS_DIR}/x64)
set(CUDA_LIBS
	#${CUAD_LIB_PATH}/cudart_static.lib
	${CUAD_LIB_PATH}/libcudart_static.a
)

add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${${MY_NAME}_INCLUDE_DIR})
target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${CUDA_LIBS})

set(${MY_NAME}_FOUND True)
