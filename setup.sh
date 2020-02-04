#! /bin/sh

NAME=$(basename $PWD)

yn() {
    while printf "$1 [y/n] " && read a
    do
        case $a in
            ([yY]) return 0;;
            ([nN]) return 1;;
            (*) printf "$a is not valid\n";;
        esac
    done
}


echo 'Godot Init Script'
echo
echo 'Creating a new README file'
printf "# $NAME\n" > README.md

echo
echo 'Creating project directories'
mkdir -vp project/{assets,scripts,scenes,lib,gdns} include out build source/include

echo
echo 'Creating project'
cat << EOF > project/project.godot
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters
config_version=4
_global_script_classes=[  ]
_global_script_class_icons={
}
[application]
config/name="$NAME"
config/icon="res://icon.png"
[rendering]
environment/default_environment="res://default_env.tres"
EOF

cat << EOF > .gitignore
*.d
*.slo
*.lo
*.o
*.obj
*.os
*.so
*.dll
*.a
*.lib
*.exe
*.out
*.app
*.x86_64
*.apk
*_i.c
*_p.c
*_h.h
*.ilk
*.obj
*.iobj
*.pch
*.pdb
*.ipdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*.manifest
*_wpftmp.csproj
*.log
*.vspscc
*.vssscc
.builds
*.pidb
*.svclog
*.scc
.import/
export.cfg
export_presets.cfg
.mono/
.sconsign.dblite
__pycache__
bin/*
*-prefix/
CMakeLists.txt.user
CMakeCache.txt
CMakeFiles
CMakeScripts
Testing
Makefile
cmake_install.cmake
install_manifest.txt
compile_commands.json
CTestTestfile.cmake
_deps
build/
out/
.vscode/
.vs/
setup.sh
EOF

cat << EOF > project/default_env.tres
[gd_resource type="Environment" load_steps=2 format=2]
[sub_resource type="ProceduralSky" id=1]
[resource]
background_mode = 2
background_sky = SubResource( 1 )
EOF

cat << EOF > source/version.hpp.in
#ifndef __MYVERSION_HPP__
#define __MYVERSION_HPP__

#define _PROJECT_NAME "@PROJECT_NAME@"
#define _VERSION_MAJOR "@_VERSION_MAJOR@"
#define _VERSION_MINOR "@_VERSION_MINOR@"
#define _VERSION_REVISION "@_VERSION_REVISION@"
#define _VERSION_STRING (_VERSION_MAJOR "." _VERSION_MINOR "." _VERSION_REVISION)

#endif
EOF

(cd project/ && curl -sO https://raw.githubusercontent.com/hlfstr/gdnative-project/master/icon.png)
curl -sO https://raw.githubusercontent.com/hlfstr/gdnative-project/master/CMakeLists.txt
curl -sO https://raw.githubusercontent.com/hlfstr/gdnative-project/master/CMakeSettings.json

echo
echo 'Initializing Git'
git init
echo 'Adding README as an init commit'
git add README.md .gitignore
git commit -m 'init'

echo
echo 'Adding the godot-cpp submodule'
git submodule add -b 3.2 https://github.com/GodotNativeTools/godot-cpp.git include/godot-cpp
echo 'Populating...'
git submodule update --init --recursive

echo
yn "Add gdregistry as a submodule?"
if [ $? -eq 0 ]; then
    echo 'Adding the gdregistry submodule'
    git submodule add https://github.com/hlfstr/gdregistry.git source/include/gdregistry
fi

echo
echo 'Commiting current project'
git add .
git commit -m "$NAME setup"

echo
echo "$NAME setup is complete!"
echo "Set the Workspace Folder to $NAME in your IDE to edit source."
echo "To begin working in Godot, import the \"project\" directory. :)"
