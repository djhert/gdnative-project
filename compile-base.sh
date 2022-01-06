#! /bin/bash

TLDIR="$PWD"
BASEDIR="base"

BOLD=$(tput bold)
GRN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
ET=$(tput sgr0)

compile() {
echo
echo $BOLD'-- '$BLUE'Compiling gdnative-init script'$ET

echo $GRN'Generating Script...'$ET
OUT=$(sed -n "1,$(grep -n -m1 '##### BEGIN PROJECT' $TLDIR/template.sh | cut -d: -f1)p" $TLDIR/template.sh)

for F in ${file_list[@]}
do
if grep -q "source/*" <<< "$F"; then continue; fi
FLE=$(gzip -c "$F" | base64)
OUT=$(cat <<EOF
$OUT
# $F
$(if [ "$(dirname $F)" != "." ]; then printf "mkdir -vp %s\n" "$(dirname $F)"; fi)
$(if [ "$F" == "project.godot" ]; then printf 'echo "%s"| base64 -d | gunzip | sed "s/BASETEMPLATE/$NAME/g" > %s\necho "created file: %s"' "$FLE" "$F" "$F"; 
elif [ "$F" == "lib/libbase.gdnlib" ]; then printf 'echo "%s"| base64 -d | gunzip | sed "s/libbase/lib$LIBNAME/g" > %s/lib$LIBNAME.gdnlib\necho "created file: %s/lib$LIBNAME.gdnlib"' "$FLE" "$(dirname $F)" "$(dirname $F)";
else printf 'echo "%s"| base64 -d | gunzip > %s\necho "created file: %s"' "$FLE" "$F" "$F";
fi)
EOF
)
done

OUT=$(cat <<EOF 
$OUT
$(sed -n "$(grep -n -m1 '##### END PROJECT' $TLDIR/template.sh | cut -d: -f1),$(grep -n -m1 '##### BEGIN GDNATIVE' $TLDIR/template.sh | cut -d: -f1)p" $TLDIR/template.sh)
EOF
)

for F in ${file_list[@]}
do
if ! grep -q "source/*" <<< "$F"; then continue; fi
FLE=$(gzip -c "$F" | base64)
OUT=$(cat <<EOF
$OUT
# $F
$(if [ "$(dirname $F)" != "." ]; then printf "mkdir -vp %s\n" "$(dirname $F)"; fi)
$(if [ "$F" == "source/src/base.cpp" ]; then printf 'echo "%s"| base64 -d | gunzip | sed "s|//GDREGHEADER|$GDHEAD|g;s|//GDREGRUN|$GDRUN|g" > %s/$LIBNAME.cpp\necho "created file: %s/$LIBNAME.cpp"' "$FLE" "$(dirname $F)" "$(dirname $F)";
else printf 'echo "%s"| base64 -d | gunzip > %s\necho "created file: %s"' "$FLE" "$F" "$F";
fi)
EOF
)
done

OUT=$(cat <<EOF 
$OUT
$(sed -n "$(grep -n -m1 '##### END GDNATIVE' $TLDIR/template.sh | cut -d: -f1),$ p" $TLDIR/template.sh)
EOF
)

echo "$OUT" > "$TLDIR/godot-init"
}

cd $BASEDIR
echo $GRN'Scanning files...'$ET

file_list=()
# This find is ridiculous and I absolutely hate it.
## But, this was the best I could come up with to gather everything
## and exclude the directories that aren't needed.
## This "fix" is only because i wanted to separate the processes (setup vs gdnative)
while IFS= read -d $'\0' -r file ; do
    file_list=("${file_list[@]}" "$file")
done < <(find . -iname "*.png" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.gd" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.tscn" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.tres" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "project.godot" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname ".gitignore" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.txt" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.json" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.in" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.gdnlib" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.hpp" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    -o -iname "*.cpp" -not \( -path "*/source/include/godot-cpp/*" -prune \) -not \( -path "*/source/include/gdregistry/*" -prune \) -print0 \
    | sed "s|\./||g" )
for F in ${file_list[@]}
do
echo " - $F"
done
compile
echo
echo $BOLD'-- '$BLUE'Done!'$ET