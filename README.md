# ![Godot](https://raw.githubusercontent.com/hlfstr/gdnative-project/master/icon.png) GDNative Project
A base to start a new Godot Project and have a coherent file structure.

## Getting Started
Run the `setup.sh` script in a new directory.
```sh
$ mkdir project-name
$ cd project-name
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/hlfstr/gdnative-project/master/gdnative-init)"
```
Once completed, simply import the **project-name** directory in Godot.

For a full example, see the **[example](https://github.com/hlfstr/gdnative-project/tree/master/example)** directory in this repository.  This `example` directory also reimplements the **[GDNative C++ Example](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html)** using this setup as well as **[GDRegistry](https://github.com/hlfstr/gdregistry)**

## Editing your source:
To edit the source, open the **project-name** folder in your IDE of choice. You will need to use an IDE that works with CMake to setup your project and all of the necessary bindings.  If you are using Mac or Linux, I highly recommend using **[Visual Studio Code](https://code.visualstudio.com/)**. If you are on Windows, **[Visual Studio](https://visualstudio.microsoft.com/vs/)** is the go-to.

The main configuration that is needed for this to work properly is to have CMake see `source/` as the project's directory.  If you are using a different editor, please consult your documentation for this.

#### Visual Studio Code setup - MacOS/Linux

In order for this to work you must change your `cmake.buildDirectory` and `cmake.sourceDirectory` settings to the `source/build` directory and `source/` respectively.

**Extensions required:**
**[CMake-Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools)** by Microsoft
**[C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)** by Microsoft

**Recommended:**
**[Godot-Tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools)** by Geequlim

The following is the required `.vscode/settings.json`
```json
{
    "cmake.buildDirectory": "${workspaceFolder}/source/build",
    "cmake.sourceDirectory": "${workspaceFolder}/source",
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools"
}
```
You may then issue builds using VSCode as you would any CMake project!  If you include **[Godot-Tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools)**, it becomes a very nice setup as everything is controlled and edited in VSCode.

**Note:** The `.vscode` folder is excluded from the git repository, so this will need to be setup on every computer that will be editing the project. The only way to not have to do this step is to change your global settings to the above, which I don't recommend.

#### On Windows
You will need to have a Unix environment setup to get this to work.  I recommend Git Bash from here: https://gitforwindows.org/

You can then run the script as-is in **[Getting Started](https://github.com/hlfstr/gdnative-project#getting-started)** and follow the above instructions to setup the project.

Visual Studio can simply import the project at **project-name** and will configure to the `source/` directly automatically.

## Features

* Nice file structure for easy project organization
* Includes .gitignore that should cover everything
* Uses CMake to build the project, also builds the `godot-cpp` bindings
* Defines `_DEBUG` constant for easy debugging when compiling for debug target

    Usage:
    ```cpp
    #ifdef _DEBUG
        //do debug something
    #endif
    ```

### Versioning

Included in the `source/` directory is a file called `version.txt`.  When CMake is built, this file is read and a header is produced allowing you to set a version number to your project.  To increase the build number, simply edit these lines in the files and have CMake reconfigure.
```cmake
# Set version number
set (_VERSION_MAJOR 0)
set (_VERSION_MINOR 0)
set (_VERSION_REVISION 0)
```

If you are building to the Debug target, then the Git tag will be included in the Version string available.  For an implementation of the versioning, it is recommended that **[GDRegistry](https://github.com/hlfstr/gdregistry)** is included on setup.

The Version Strings available to you depends on the name of the project to avoid any conflicts.  For example, a project named `example` would have the following:
```cpp
// Pretty print name and version
#define _EXAMPLE_INFO ("example v0.0.0")
// Get version raw
#define _EXAMPLE_VERSION ("0.0.0")
```

## Organization

After the setup script is completed, a project directory will have been created with the intention to be used in the following way:

```
project-name/
├── assets/ # Assets for your project
├── default_env.tres
├── gdns/ # Native Scripts
├── .gitignore
├── icon.png
├── lib/ # Compiled library
│   └── libexample.gdnlib
├── out/ # Exported projects
│   └── .gdignore
├── project.godot
├── README.md
├── scenes/ # Scenes
├── scripts/ # Scripts
└── source/ # C++ Source
    ├── build/
    ├── CMakeLists.txt
    ├── CMakeSettings.json
    ├── .gdignore
    ├── include/
    │   ├── godot-cpp/ # godot-cpp bindings as a submodule
    │   └── gdregistry/ # gdregistry bindings as a submodule, if selected
    ├── src/
    ├── version.hpp.in # version template
    └── version.txt # version file
```

## Building Projects
### Linux/MacOS

Create a folder in the `project-name/source` folder called `build` and run cmake from this directory.

```sh
$ mkdir source/build
$ cd source/build
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
$ mkdir source/build
$ cd source/build
$ CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..
$ make
```

### Windows

For Windows, open the `project_name` directory in Visual Studio.  Visual Studio will setup the `cmake` project, and the included `CMakeSettings.json` gives you rules to build a `Debug` or `Release` build already.  Simply issue a Build using Visual Studio and the project will be built.

### Android

To build for Android, you must have the Android NDK installed.  Please see the documentation for your respective platform. **NOTE:** This has only been tested on Linux.  It is recommended that you start with clean `build` folder.  The following example will build a project for Android for `arm64-v8a`, and assumes the variable `$ANDROID_NDK` is defined to your Android NDK folder.

```sh
$ mkdir source/build
$ cd source/build
$ cmake -DANDROID_NDK=$ANDROID_NDK \
-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
-DANDROID_PLATFORM=android-23 \
-DANDROID_ABI=arm64-v8a \
-DCMAKE_BUILD_TYPE=Debug ..
$ make
```
**Required Flags**
* `-DANDROID_NDK=$ANDROID_NDK`
    * Defines the Android NDK Path to CMake
    * You should have `$ANDROID_NDK` set as an environment variable to point to your NDK installation.
* `-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake`
    * By default always required as-is, as this is included in the NDK; unless you have these files outside of `$ANDROID_NDK`
* `-DANDROID_PLATFORM=android-23`
    * Sets the minimum platform for the NDK.  `android-23` is the lowest for Godot, and perfectly acceptable to use normally.
* `-DANDROID_ABI=arm64-v8a`
    * Sets the ABI target.  Acceptable targets are: `armeabi-v7a`, `arm64-v8a`, `x86`, `x86_64`
## Notes

* The included `CMakeLists.txt` is set to recursively scan the source folders, but this requires CMake to rebuild any time that a new file is added.  If you get errors when adding a new file, or the auto-completion is not working, rebuild `cmake` using your IDE and everything will work again.
* The project sets up the `*.gdnlib` file for you as well based on the **project-name** for the **Linux**, **Windows**, and **Android** platforms.
