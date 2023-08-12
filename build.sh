set -ex
cmake -G 'CodeBlocks - Ninja' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. 
cmake --build . --target hello-opt
