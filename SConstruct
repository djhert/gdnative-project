#!python
import os, subprocess, fnmatch
from subprocess import check_call
from sys import exit

## Recursive Glob function, used to get all source files
def GlobRecursive(pattern, node='.'):
    matches = []
    for root, dirnames, filenames in os.walk(node):
        for filename in fnmatch.filter(filenames, pattern):
            matches.append(os.path.join(root, filename))
    return matches

opts = Variables([], ARGUMENTS)

# Gets the standard flags CC, CCX, etc.
env = DefaultEnvironment()

# Define our options
opts.Add(EnumVariable(
    'target', 
    "Compilation target", 
    'debug',
    ['d', 'debug', 'r', 'release']
))
opts.Add(EnumVariable(
    'platform', 
    "Compilation platform", 
    '', 
    ['', 'android', 'windows', 'x11', 'linux', 'osx']
))
opts.Add(BoolVariable(
    'use_llvm', 
    "Use the LLVM / Clang compiler", 
    'no'
))
opts.Add(PathVariable(
    'target_name', 
    'The library name.', 
    os.path.basename(os.getcwd()), 
    PathVariable.PathAccept
))
opts.Add(EnumVariable(
    'android_arch',
    'Target Android architecture',
    'armv7',
    ['armv7','arm64v8','x86','x86_64']
))
opts.Add(
    'android_api_level',
    'Target Android API level',
    '18' if ARGUMENTS.get("android_arch", 'armv7') in ['armv7', 'x86'] else '21'
)
opts.Add(
    'ANDROID_NDK_ROOT',
    'Path to your Android NDK installation. By default, uses ANDROID_NDK_ROOT from your defined environment variables.',
    os.environ.get("ANDROID_NDK_ROOT", None)
)

# Local dependency paths, adapt them to your setup
include_path = "include/"
godot_headers_path = include_path + "godot-cpp/godot_headers/"
cpp_bindings_path = include_path + "godot-cpp/"
cpp_library = "libgodot-cpp"
target_path = "project/lib/"

# only support 64 bits
bits = 64

# Updates the environment with the option variables.
opts.Update(env)

# Process some arguments
if env['use_llvm']:
    env['CC'] = 'clang'
    env['CXX'] = 'clang++'

if env['platform'] == '':
    print("No valid target platform selected.")
    quit();

# Check our platform specifics
if env['platform'] == "osx":
    target_path += 'osx/'
    cpp_library += '.osx'
    env.Append(LINKFLAGS = ['-arch', 'x86_64'])
    env.Append(CCFLAGS = ['-arch', 'x86_64'])
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS = ['-g','-D_DEBUG'])      
    else:
        env.Append(CCFLAGS = ['-O3'])

elif env['platform'] in ('x11', 'linux'):
    target_path += 'linux/'
    cpp_library += '.linux'
    env.Append(CCFLAGS = ['-fPIC', '-std=c++17', '-Wwrite-strings'])
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS = ['-g', '-D_DEBUG'])
    else:
        env.Append(CCFLAGS = ['-O3'])

elif env['platform'] == "windows":
    target_path += 'win64/'
    cpp_library += '.windows'
    # This makes sure to keep the session environment variables on windows,
    # that way you can run scons in a vs 2017 prompt and it will find all the required tools
    env.Append(ENV = os.environ)

    env.Append(CCFLAGS = ['-DWIN32', '-D_WIN32', '-D_WINDOWS', '-W3', '-GR', '-D_CRT_SECURE_NO_WARNINGS'])
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS = ['-EHsc', '-D_DEBUG', '-MDd'])
    else:
        env.Append(CCFLAGS = ['-O2', '-EHsc', '-DNDEBUG', '-MD'])

elif env['platform'] == 'android':
    if host_platform == 'windows':
        env = env.Clone(tools=['mingw'])
        env["SPAWN"] = mySpawn
    
    # Verify NDK root
    if not 'ANDROID_NDK_ROOT' in env:
        raise ValueError("To build for Android, ANDROID_NDK_ROOT must be defined. Please set ANDROID_NDK_ROOT to the root folder of your Android NDK installation.")
    
    # Validate API level
    api_level = int(env['android_api_level'])
    if env['android_arch'] in ['x86_64', 'arm64v8'] and api_level < 21:
        print("WARN: 64-bit Android architectures require an API level of at least 21; setting android_api_level=21")
        env['android_api_level'] = '21'
        api_level = 21
    
    # Setup toolchain
    toolchain = env['ANDROID_NDK_ROOT'] + "/toolchains/llvm/prebuilt/"
    if host_platform == "windows":
        toolchain += "windows"
        import platform as pltfm
        if pltfm.machine().endswith("64"):
            toolchain += "-x86_64"
    elif host_platform == "linux":
        toolchain += "linux-x86_64"
    elif host_platform == "osx":
        toolchain += "darwin-x86_64"
    env.PrependENVPath('PATH', toolchain + "/bin")

    # Get architecture info
    arch_info_table = {
        "armv7" : {
            "march":"armv7-a", "target":"armv7a-linux-androideabi", "tool_path":"arm-linux-androideabi", "compiler_path":"armv7a-linux-androideabi",
            "ccflags" : ['-mfpu=neon']
            },
        "arm64v8" : {
            "march":"armv8-a", "target":"aarch64-linux-android", "tool_path":"aarch64-linux-android", "compiler_path":"aarch64-linux-android",
            "ccflags" : []
            },
        "x86" : {
            "march":"i686", "target":"i686-linux-android", "tool_path":"i686-linux-android", "compiler_path":"i686-linux-android",
            "ccflags" : ['-mstackrealign']
            },
        "x86_64" : {"march":"x86-64", "target":"x86_64-linux-android", "tool_path":"x86_64-linux-android", "compiler_path":"x86_64-linux-android",
            "ccflags" : []
        }
    }
    arch_info = arch_info_table[env['android_arch']]

    # Setup tools
    env['CC'] = toolchain + "/bin/clang"
    env['CXX'] = toolchain + "/bin/clang++"
    env['AR'] = toolchain + "/bin/" + arch_info['tool_path'] + "-ar"

    env.Append(CCFLAGS=['--target=' + arch_info['target'] + env['android_api_level'], '-march=' + arch_info['march']])

    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-D_DEBUG', '-g'])
    else:
        env.Append(CCFLAGS=['-03'])

    env.Append(CCFLAGS=arch_info['ccflags'])

if env['target'] in ('debug', 'd'):
    cpp_library += '.debug'
else:
    cpp_library += '.release'

cpp_library += '.' + str(bits)

# make sure our binding library is properly includes
env.Append(CPPPATH=[godot_headers_path, cpp_bindings_path + 'include/', cpp_bindings_path + 'include/core/', cpp_bindings_path + 'include/gen/', include_path])
env.Append(LIBPATH=[cpp_bindings_path + 'bin/'])
env.Append(LIBS=[cpp_library])

# Add the folder for the C++ source
env.Append(CPPPATH=['source/'])

# Use the recursive globber to compile all source in folder
sources = GlobRecursive('*.cpp', 'source')

library = env.SharedLibrary(target=target_path + env['target_name'] , source=sources)

Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))

