#! /bin/sh

NAME=$(basename $PWD)
LIBNAME=$(echo $NAME | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')

BOLD=$(tput bold)
GRN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
ET=$(tput sgr0)

GDHEAD=""
GDRUN=""

yn() {
    while printf $BOLD"$1 [y/n] " && read a
    do
        case $a in
            ([yY]) printf "$ET" && return 0;;
            ([nN]) printf "$ET" && return 1;;
            (*) printf $RED"$a is not valid\n"$ET;;
        esac
    done
}

gdproject() {
if [ -d "$PWD/.git" ]; then
    echo $RED$BOLD"ERROR:$BLUE .git$RED directory already exists.  Exiting..."$ET
    return 1
fi

echo $BOLD'-- '$BLUE'Godot Project Init'$ET
echo $BOLD$GRN"Creating Project $ET$BOLD'$NAME'"$ET
echo

echo
printf "# $NAME\n" > README.md
echo "created file: 'README.md'"

mkdir -vp "out"
printf "#Godot Ignore\n" > out/.gdignore

##### BEGIN PROJECT #####
##### END PROJECT #####

echo
echo $BOLD"--$GRN Initializing Git"$ET
git init

echo
yn "Add$BLUE GDNative$(tput setaf 7) support?"
if [ $? -eq 0 ]; then
    gdnative
fi

echo
echo $BOLD"--$GRN Commiting current project"$ET
git add .
git commit -m "hello $NAME"

echo
echo $BOLD"$BLUE$NAME$GRN setup is complete!"$ET
echo $BOLD"Set the Workspace Folder to \"$NAME\" in your IDE to edit source."
echo "To begin working in Godot, import the \"$NAME\" directory. :)$ET"
}

gdnative() {
if [ ! -d "$PWD/.git" ] || [ ! -f "$PWD/project.godot" ]; then
    echo $RED$BOLD"ERROR:$BLUE $NAME$RED does not appear to be a Godot project.  Exiting..."$ET
    return 1
fi
echo $BOLD'-- '$BLUE'GDNative'$ET

mkdir -vp "lib" "gdns" "source" "source/include" "source/src"
printf "#Godot Ignore\n" > source/.gdignore
echo
echo $BOLD"-- $GRN Adding the$BLUE godot-cpp$GRN submodule"$ET
git submodule add https://github.com/GodotNativeTools/godot-cpp.git source/include/godot-cpp

echo
yn "Add$BLUE gdregistry$(tput setaf 7) as a submodule?"
if [ $? -eq 0 ]; then
    echo $BOLD"--$GRN Adding the$BLUE gdregistry$GRN submodule"$ET
    git submodule add https://github.com/hlfstr/gdregistry.git source/include/gdregistry
    GDHEAD="#include <gdregistry/gdregistry.hpp>"
    GDRUN="godot::GDRegistry::Run();"
fi

echo
echo $BOLD"--$GRN Init git submodules"$ET
git submodule update --init --recursive
##### BEGIN GDNATIVE #####
##### END GDNATIVE #####
}

if [ $# -eq 0 ]; then
    gdproject
else
case $1 in
    "-c") # Setup GDNative in the current directory.
        gdnative
        ;;
    "-h") # Display this help.
        cat <<EBF
USAGE: $0 [OPTION]
$(grep "....)\ #" $0 | sed 's/)//g;s/"//g;s/#/\t\t/g')

Creates a new Godot project in the current directory if no flag passed
EBF
        exit 0
        ;;
    *)
      printf "%s: invalid option -- '%s'\nTry '%s -h' for more information.\n" "$0" "$1" "$0"
      exit 1
      ;;
esac
fi