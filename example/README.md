# example

This is an example project made using **[gdnative-project](https://github.com/hlfstr/gdnative-project)**


This also acts as a basic example to **[GDRegistry](https://github.com/hlfstr/gdregistry)** as a reimplementation of **[GDNative C++ Example](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html)**.  See the `source/src/` directory

## Building

Clone the **[gdnative-project](https://github.com/hlfstr/gdnative-project)** repository to a folder of your choosing:
```sh
$ git clone --recursive https://github.com/hlfstr/gdnative-project
```

It is important that you use the `--recursive` flag to download all of the submodules.

### Linux/MacOS

Make sure that you have CMake installed.  Issue a build using:
```sh
$ mkdir source/build
$ cd source/build
$ cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
$ make
```
Alternatively, use an IDE of your choice to load the `example/` directory of **gdnative-project** and issue a build using the instructions found on that repo.

### Windows

Simply open the `example/` directory in Visual Studio and issue a build; Visual Studio will configure the CMake project.

## Godot

Import the `example/` directory in Godot.  From here, you should see the default scene and the objects.  After you have built the GDNative Library, press play and watch that sprite move!