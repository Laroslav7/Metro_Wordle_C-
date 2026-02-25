# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appMetroWordleC_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appMetroWordleC_autogen.dir\\ParseCache.txt"
  "appMetroWordleC_autogen"
  )
endif()
