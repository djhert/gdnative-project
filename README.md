# ![Godot](https://raw.githubusercontent.com/hlfstr/gdnative-project/master/icon.png) GDNative Project
A base to start a new Godot Project and have a coherent file structure.

## NOTICE
This has only been tested on Linux at this time, though theoretically the SConstruct file should work on any platform with a proper development environment.  If you can compile `godot-cpp` you should be able to use this.  Do not attempt to run the shell script on Windows, an actual Windows script will be released at some point.

## Getting Started
Run the `setup.sh` script in a new directory.
```sh
$ mkdir project-name
$ cd project-name
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/hlfstr/gdnative-project/master/setup.sh)"
```
Once completed, simply import the newly created **project** directory.

## Features

* Nice file structure for easy project organization
* Includes .gitignore that should cover everything
* SConstruct File for easy building of GDNative Source
* Defines _DEBUG constant for easy debugging when compiling for debug target

    Usage:
    ```cpp
    #ifdef _DEBUG
        //do debug something
    #endif
    ```

## Organization

After the setup script is completed, a project directory will have been created with the intention to be used in the following way:  

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
    ├── include / # Source that needs to be compiled with the library 
    └── # C++ GDNative Source goes here
```

## Building Projects
Included is a modified SConstruct file from [GDNative Example Project](https://github.com/BastiaanOlij/gdnative_cpp_example), with portions (mostly organization and Android support) taken from [godot-cpp](https://github.com/GodotNativeTools/godot-cpp).  **Thank you!**

* The compiled library's name is derived from the project folder's name.
* Forces 64 bits (sorry 32 bit users, but get gooder)
* Output set to "lib" folder in the project directory
* The parser for source files is  recursive, meaning you can have subfolders within the "source" directory of your GDNative source
* Recommended to use Clang for compilation by including `use_llvm=yes`, but not forced here to keep with **Godot**

### Building
To compile a GDNative project, you will need to use scons.  I almost exclusively build with the following command during development:
```sh
$ scons -j4 platform=linux use_llvm=yes target=debug
```

> Change -j4 to be how many parallel operations you would like to occur.  For maximum efficiency, this should not exceed the amount of cores available on the system.

> Valid platforms: "x11|linux", "windows", "osx", "android"

> use_llvm flag is kept here for consistency with Godot source (recommended)

> use _target=release_ for final build

> Add _full=true_ to rebuild the `godot-cpp` bindings as well using the same platform/settings

> Use the --clean flag to remove all compiled objects

Output of the GDNative library is placed in the "project/lib" folder under the appropriate platform.  Use **Godot** to then create the necessary .gdnlib files to link your GDNative Scripts to **Godot**.

### Building for Android
To begin, `godot-cpp` will need to be built for Android.  See the README of [godot-cpp](https://github.com/GodotNativeTools/godot-cpp) for information on this.

```sh
$ scons platform=android use_llvm=yes -j4 target=debug android_arch=arm64v8
```

> $ANDROID_NDK_ROOT Must be defined

> Include _use_llvm=yes_ for using clang++ (recommended)

> Change _target=release_ to build a release build

> Available arch: "armv7", "arm64v8", "x86"

The resulting library will be created in a subfolder of `lib/` int the project depending on the arch used.

### Using on Android

Now that we have our library built, you can include it in your `.gdnlib` file.

**NOTE:** `libc++_shared.so` and `libgodot_android.so` will already be provided for you if you built the Godot Android Templates using the [official build instructions](https://docs.godotengine.org/en/3.1/development/compiling/compiling_for_android.html), or are using the [official templates](https://docs.godotengine.org/en/3.1/getting_started/workflow/export/exporting_for_android.html).

libexample.gdnlib:
```ini
[general]
singleton=false
load_once=true
symbol_prefix="godot_"
reloadable=true

[entry]
Android.armeabi-v7a="res://lib/android/armv7/libexample.so"
Android.arm64-v8a="res://lib/android/arm64v8/libexample.so"
X11.64="res://lib/linux/libexample.so"

[dependencies]
Android.armeabi-v7a=[  ]
Android.arm64-v8a=[  ]
X11.64=[  ]
```

That's it!  Ensure that you have your Android Export Templates setup, and you can now export your project for Android.

 #### Optional/Additional parameters
 There are some optional and additional parameters available for the `scons` command.  For a full list:
 ```sh
 $ scons --help
 ```