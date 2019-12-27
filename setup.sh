#! /bin/sh

NAME=$(basename $PWD)

yn() {
  while true; do
    printf "$1 [y/n] "
    read a
    if [ "$a" == "y" ]; then
      return 0
    elif [ "$a" == "n" ]; then
      return 1
    else
      echo "$a is not valid"
    fi
  done
}

echo 'Godot Init Script'
echo
echo 'Creating a new README file'
printf "# $NAME\n" > README.md

echo
echo 'Creating project directories'
mkdir -vp project/{assets,scripts,scenes,lib,gdns} source include out source/include

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
.import/
export.cfg
export_presets.cfg
.mono/
.sconsign.dblite
__pycache__
out/*
setup.sh
EOF

cat << EOF > project/default_env.tres
[gd_resource type="Environment" load_steps=2 format=2]
[sub_resource type="ProceduralSky" id=1]
[resource]
background_mode = 2
background_sky = SubResource( 1 )
EOF

cd project/
curl -sO https://raw.githubusercontent.com/hlfstr/gdnative-project/master/icon.png
cd ../
curl -sO https://raw.githubusercontent.com/hlfstr/gdnative-project/master/SConstruct

echo
echo 'Initializing Git'
git init
echo 'Adding README as an init commit'
git add README.md .gitignore SConstruct
git commit -m 'init'

echo
echo 'Adding the godot-cpp submodule'
git submodule add https://github.com/GodotNativeTools/godot-cpp.git include/godot-cpp
echo 'Populating...'
git submodule update --init --recursive

echo
echo 'Commiting current project'
git add .
git commit -m 'final init'

echo
yn "Build godot-cpp?"
if [ $? -eq 0 ]; then
  cd include/godot-cpp/
  scons platform=linux use_llvm=yes generate_bindings=yes -j4 bits=64 target=debug
  cd ../
else
  echo "Compile with the following:"
  echo 'Debug:   scons platform=linux use_llvm=yes generate_bindings=yes -j4 bits=64 target=debug'
  echo 'Release: scons platform=linux use_llvm=yes generate_bindings=yes -j4 bits=64 target=release'
fi

echo
echo "$NAME setup is complete!"
echo "To begin, import the \"project\" directory into Godot. :)"