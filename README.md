# ![Godot](https://raw.githubusercontent.com/hlfstr/gdnative-project/master/icon.png) GDNative Project
A base to start a new Godot Project and have a coherent file structure.

## NOTICE
This has only been tested on Linux at this time, though theoretically it should work on Windows and Mac with a proper development environment.  If you can compile `godot-cpp` you should be able to use this.

## Getting Started
Run the `setup.sh` script in a new directory.  
```sh
mkdir project-name
cd project-name
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hlfstr/gdnative-project/master/setup.sh)"
```
Once completed, simply import the newly created **project** directory.

## Features

* Nice file structure for easy project organization
* Includes .gitignore that should cover what Godot is compatible with
* SConstruct File for easy building of GDNative Source
* Defines _DEBUG constant for easy debugging when compiling for debug target
    Usage:
    ```cpp
    #ifdef _DEBUG
        //do debug something
    #endif
    ```

## Organization
```bash
Name/
├── include/
|   ├── # C++ Bindings/3rd party libraries
│   └── godot-cpp/ # GDNative bindings
├── out/
|   └── # Exported projects
├── project/
│   ├── assets/
|       └── # Project Assets
│   ├── default_env.tres
│   ├── gdns/
|       └── # Godot NativeScripts
│   ├── icon.png
│   ├── lib/
|   |   └── # Compiled GDNative libraries
│   ├── project.godot
│   ├── scenes/
|   |   └── # Godot Scenes
│   └── scripts/
|       └── # Godot Scripts
├── README.md
├── SConstruct
└── source/
    └── # C++ GDNative Source goes here
```

## Building Projects
Included is a modified SConstruct file from [GDNative Example Project](https://github.com/BastiaanOlij/gdnative_cpp_example), with portions taken from [godot-cpp](https://github.com/GodotNativeTools/godot-cpp). 

* The compiled library's name is derived from the project folder's name.
* Forces 64 bits (sorry 32 bit users, but get gooder)
* Output set to "lib" folder in the project directory
* The parser for source files is  recursive, meaning you can have subfolders within the "source" directory of your GDNative source
* Recommended to use Clang for compilation by including `use_llvm=yes`, but not forced

#### Minor Notes
If you changed the name of the godot-cpp compiled library, you will also need to update the following line:
```python
cpp_library = "libgodot-cpp"
```

### Building Projects
To compile a GDNative project, you will need to use scons.  I almost exclusively build with the following command during development:
```sh
$ scons -j4 platform=x11 use_llvm=yes target=debug
```

> Change -j4 to be how many parallel operations you would like to occur.  For maximum efficiency, this should not exceed the amount of cores available on the system.

> Valid platforms are "x11/linux", "windows", "osx", "android"

> use_llvm flag is kept here for consistency with Godot source (recommended)

> use _target=release_ for final build

> Use the --clean flag to remove all compiled objects

Output of the GDNative library is placed in the "project/lib" folder under the appropriate platform.  Use Godot to then create the necessary .gdnlib files to link your GDNative Scripts to Godot.

### Building for Android
To begin, `godot-cpp` will need to be built for Android.  See the README of `godot-cpp` for information on this.   

```sh
$ scons platform=android use_llvm=yes -j4 target=debug android_arch=arm64v8
```

> Include `use_llvm=yes` for using clang++ (recommended)

> Change `target=release` to build a release build

> Change `android_arch=arm64v8` to your processor type for Android (currently, arm64v8 or armv7)

> The resulting library will be created in a subfolder of `lib/` depending on the arch used.

### Using for Android

Now that we have our library built, you can include it in your `.gdnlib` file.

**NOTE:** `libc++_shared.so` and `libgodot_android.so` will already be provided for you if you built the Godot Android Templates using the official instructions, or are using the official templates.

libexample.gdnlib:
```
[general]
singleton=false
load_once=true
symbol_prefix="godot_"
reloadable=true

[entry]
Android.arm64-v8a="res://lib/arm64-v8a/libexample.so"
X11.64="res://lib/linux/libexample.so"

[dependencies]
Android.arm64-v8a=[  ]
X11.64=[  ]
```

That's it!  Ensure that you have your Android Export Templates setup, and you can now export your project for Android.