# ![Godot](https://raw.githubusercontent.com/hlfstr/gdnative-project/master/icon.png) GDNative Project 
A base to start a new Godot Project and have a coherent file structure.

## Getting Started
Run the `setup.sh` script in a new directory.
```sh
$ mkdir project-name
$ cd project-name
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/hlfstr/gdnative-project/master/setup.sh)"
```
Once completed, simply import the newly created **project** directory in Godot.

To edit the source, open the **project-name** folder in your IDE of choice (tested with `vscode` on Linux and `Visual Studio` on Windows), the CMakeLists.txt will be automatically parsed. 

### On Windows
You will need to have a Unix environment setup to get this to work.  I recommend Git Bash from here: https://gitforwindows.org/

You can then use that application to follow the above instructions to setup the project.

## Features

* Nice file structure for easy project organization
* Includes .gitignore that should cover everything
* Uses CMake to build the project, also builds the `godot-cpp` bindings
* Defines _DEBUG constant for easy debugging when compiling for debug target

    Usage:
    ```cpp
    #ifdef _DEBUG
        //do debug something
    #endif
    ```

## Organization

After the setup script is completed, a project directory will have been created with the intention to be used in the following way:  

```
Name/
├── include/
|   ├── # C++ Bindings/3rd party libraries
│   └── godot-cpp/ # GDNative bindings will be pulled in via CMake
├── out/
|   └── # Exported projects
├── project/
│   ├── assets/
|       └── # Project Assets
│   ├── gdns/
|       └── # Godot NativeScripts
│   ├── lib/
|   |   └── # Compiled GDNative libraries
│   ├── scenes/
|   |   └── # Godot Scenes
│   ├── scripts/
|       └── # Godot Scripts
│   ├── icon.png
│   ├── default_env.tres
│   └── project.godot
├── CMakeLists.txt
├── CMakeSettings.json
├── README.md
└── source/
    ├── include / # libraries that needs to be compiled with the library (ex. GDRegistry)
    └── # C++ GDNative Source goes here
```

## Building Projects
### Linux

Create a folder in the `project-name` folder called `build` and run cmake from this directory.

```sh
$ mkdir build
$ cd build
$ cmake ..
$ make
```

* Running the above will build a Release build.
* To build with debug, add `-DCMAKE_BUILD_TYPE=Debug`
* To build the `compile_commands.json` add `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
* The compiled library's name is derived from the project folder's name.
* Output set to "lib" folder in the project directory
* The parser for source files is  recursive, meaning you can have subfolders within the "source" directory of your GDNative source
* To use clang (recommended) set the `CC` and `CXX` variables before running `cmake`
```sh
$ mkdir build
$ cd build
$ CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
$ make
```

### Windows

For Windows, open the `project_name` directory in Visual Studio.  Visual Studio will setup the `cmake` project, and the included `CMakeSettings.json` gives you rules to build a `Debug` or `Release` build already.  Simply issue a Build using Visual Studio and the project will be built.

## Notes

* The included `CMakeLists.txt` is set to recursively scan the source folders, but this requires CMake to rebuild any time that a new file is added.  If you get errors when adding a new file, or the auto-completion is not working, rebuild `cmake` using your IDE and everything will work again.