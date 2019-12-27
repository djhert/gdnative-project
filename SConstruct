#!python
import os, subprocess, fnmatch
from subprocess import check_call
from sys import exit, platform

## Recursive Glob function, used to get all source files
def GlobRecursive(pattern, node='.'):
    matches = []
    for root, dirnames, filenames in os.walk(node):
        for filename in fnmatch.filter(filenames, pattern):
            matches.append(os.path.join(root, filename))
    return matches

# Try to detect the host platform.
if platform.startswith('linux'):
    host_platform = 'linux'
elif platform == 'darwin':
    host_platform = 'osx'
elif platform == 'win32' or sys.platform == 'msys':
    host_platform = 'windows'
else:
    raise ValueError("Could not detect host platform")

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
    '21'
)
opts.Add(
    'ANDROID_NDK_ROOT',
    'Path to your Android NDK installation. By default, uses ANDROID_NDK_ROOT from your defined environment variables.',
    os.environ.get("ANDROID_NDK_ROOT", None)
)
opts.Add(BoolVariable(
    'full', 
    "Recompile godot-cpp for the target platform first", 
    'no'
))

# Local dependency paths, adapt them to your setup
include_path = "include/"
godot_headers_path = include_path + "godot-cpp/godot_headers/"
cpp_bindings_path = include_path + "godot-cpp/"
cpp_library = "libgodot-cpp"
target_path = "project/lib/"

## Add additional directories for includes here
INCLUDES = ["source/include"]

# 64 bit only
bits = 64

# Updates the environment with the option variables.
opts.Update(env)

# Check platform
if env['platform'] == '':
    print("No valid target platform selected.")
    raise ValueError("No target platform selected.  Try: platform=<platform>")

# Check our platform specifics
if env['platform'] == "osx":
    env.Append(LINKFLAGS = ['-arch', 'x86_64'])
    env.Append(CCFLAGS = ['-arch', 'x86_64'])
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS = ['-g','-D_DEBUG'])      
    else:
        env.Append(CCFLAGS = ['-O3'])

elif env['platform'] in ('x11', 'linux'):
    if env['use_llvm']:
        env['CC'] = 'clang'
        env['CXX'] = 'clang++'
    env.Append(LINKFLAGS = ['-m64'])
    env.Append(CCFLAGS = [
        '-m64',
        '-fPIC',
        '-std=c++17',
        '-Wwrite-strings'
    ]) 
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS = ['-g', '-D_DEBUG'])
    else:
        env.Append(CCFLAGS = ['-O3'])

elif env['platform'] == "windows":
    # This makes sure to keep the session environment variables on windows,
    # that way you can run scons in a vs 2017 prompt and it will find all the required tools
    env.Append(ENV = os.environ)
    env.Append(CCFLAGS = [
        '-DWIN32',
        '-D_WIN32',
        '-D_WINDOWS',
        '-W3',
        '-GR',
        '-D_CRT_SECURE_NO_WARNINGS'
    ])
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS = ['-EHsc', '-D_DEBUG', '-MDd'])
    else:
        env.Append(CCFLAGS = ['-O2', '-EHsc', '-DNDEBUG', '-MD'])

elif env['platform'] == 'android':    
    # Verify NDK root
    if not 'ANDROID_NDK_ROOT' in env:
        raise ValueError("To build for Android, ANDROID_NDK_ROOT must be defined. Please set ANDROID_NDK_ROOT to the root folder of your Android NDK installation.")
    # Validate API level
    api_level = int(env['android_api_level'])
    if api_level < 21:
        print("WARNING: 64-bit Android architectures require an API level of at least 21; setting android_api_level=21")
        env['android_api_level'] = '21'
        api_level = 21
    # Setup toolchain
    toolchain = env['ANDROID_NDK_ROOT'] + "/toolchains/llvm/prebuilt/"
    if host_platform == "windows":
        toolchain += "windows-x86_64"
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
    # Setup Tools
    env['CC'] = toolchain + "/bin/clang"
    env['CXX'] = toolchain + "/bin/clang++"
    env['AR'] = toolchain + "/bin/" + arch_info['tool_path'] + "-ar"
    env['RANLIB'] = toolchain + "/bin/" + arch_info['tool_path'] + "-ranlib"
    env['LINK'] = toolchain + "/bin/clang++"
    env.Append(CCFLAGS=[
        '--target=' + arch_info['target'] + env['android_api_level'],
        '-march=' + arch_info['march'], 
        arch_info['ccflags'],
        '-std=c++17' 
    ])
    env.Append(LINKFLAGS=[
        '--target=' + arch_info['target'] + env['android_api_level'],
        '-march=' + arch_info['march']
    ])
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-D_DEBUG', '-g', '-Og'])
    else:
        env.Append(CCFLAGS=['-03'])

# Compile the godot-cpp as well with the same settings
if env['full']:
    cur_dir = os.getcwd()
    os.chdir(cur_dir+'/include/godot-cpp')
    command = [
        "scons",
        "-j"+str(GetOption('num_jobs')),
        "platform=" + env['platform'],
        "target=" + env['target'],
        "generate_bindings=yes",
        "use_llvm=true" if env['use_llvm'] else "use_llvm=false",
        "" if env['platform'] != 'android' else "android_arch=" + env['android_arch'],
         "" if env['platform'] != 'android' else "android_api_level=" + env['android_api_level']
    ]
    retval = subprocess.call(command)
    if retval != 0:
        raise ValueError("Failed to build godot-cpp")
    os.chdir(cur_dir)

## Godot C++ Library Name
cpp_library+='.{}.{}.{}'.format(
        env['platform'],
        env['target'],
        bits if env['platform'] != 'android' else env['android_arch']
)

## Target path for lib
target_path+='{}/{}'.format(
    env['platform'],
    '' if env['platform'] != 'android' else env['android_arch'] + '/'
)

# make sure our binding library is properly included
env.Append(CPPPATH=[
    godot_headers_path, 
    cpp_bindings_path + 'include/', 
    cpp_bindings_path + 'include/core/', 
    cpp_bindings_path + 'include/gen/', 
    include_path] + INCLUDES 
)
env.Append(LIBPATH=[cpp_bindings_path + 'bin/'])
env.Append(LIBS=[cpp_library])

# Add the folder for the C++ source
env.Append(CPPPATH=['source/'])

# Use the recursive globber to compile all source in folder
sources = GlobRecursive('*.cpp', 'source')

library = env.SharedLibrary(
    target=target_path + env['target_name'] , 
    source=sources
)

Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))