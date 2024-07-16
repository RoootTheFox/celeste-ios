#!/bin/bash
# colors
RESET="\033[0m"
RED="\033[0;31m"
BOLD_RED="\033[1;31m"
PINK="\033[0;95m"
BOLD_PINK="\033[1;95m"
CYAN="\033[0;96m"
BOLD_CYAN="\033[1;96m"
LIME="\033[0;92m"
BOLD_LIME="\033[1;92m"


# logging functions
error() {
	if [ "$2" == "1" ]; then
		echo -e "        ${RED}$1${RESET}"
	else
		echo -e "${BOLD_RED}(error)${RED} $1${RESET}"
	fi
}

unhandled_error() {
	error "unhandled error at line $1!"
	error "THIS IS MOST LIKELY A BUG"
	exit 1
}

warn() {
	echo -e "${BOLD_YELLOW}(warn)${YELLOW} $1${RESET}"
}

info() {
	echo -e "${BOLD_CYAN}(info)${CYAN} $1${RESET}"
}

info2() {
	echo -e "(info) $1${RESET}"
}

cd_fail() {
	error "failed to change directory - line $(caller)"
	exit 1
}

success() {
	if [ "$2" == "1" ]; then
		echo -e "          ${LIME}$1${RESET}"
	else
		echo -e "${BOLD_LIME}(success)${LIME} $1${RESET}"
	fi
}

# misc functions
update_submodules() {
	if [ "$1" == "1" ]; then
		if ! git submodule update --init --recursive; then error "failed to recursively update submodules"; exit 1; fi
	else
		if ! git submodule update --init; then error "failed to update submodules"; exit 1; fi
	fi
}

clone_repo() {
	local repo=$1
	local dir=$2

	if [ -d "${dir}/.git" ]; then
		info2 "$repo already cloned in $dir"
	else
		if ! git clone "$repo" "${@:2}"; then error "failed to clone git repo $repo with ${*:2}"; exit 1; fi
	fi
}

# trap all other errors
trap 'unhandled_error $LINENO' ERR

script_real_path=$(realpath -- "${BASH_SOURCE[0]}")
script_dir=$(dirname -- "$script_real_path")
cd "$script_dir" || cd_fail # make sure we're running in the script directory in case we get invoked from another directory
mv "$script_dir/.git-tmp" "$script_dir/.git" 2>/dev/null || echo a >/dev/null # in case the script got killed while applying patches

echo -e " ~ ${BOLD_PINK}Celeste ${RESET}${BOLD_CYAN}iOS${RESET} build script ~"
echo -e "  written by ${BOLD_PINK}rooot${RESET}"
echo -e "  https://github.com/RoootTheFox/celeste-ios"
echo -e "\n"

echo -e "This project has been tested on the ${BOLD_CYAN}Linux Steam build of Celeste 1.4.0.0${RESET} but SHOULD work on any other FNA-based Celeste build"
echo -e "Enter the full path to an ${BOLD_RED}UNMODIFIED${RESET}, ${BOLD_RED}FNA-based (!)${RESET} Celeste install: \c"
read -r celeste_path

# for some reason bash fails to check for relative paths, that's why we need to do this
#if ! [ -d "$celeste_path" ]; then
#	celeste_path="$(realpath $celeste_path)" # nvm this doesn't work either wtf (just gonna fail at relative paths then ig)
#fi

check_celeste_install() {
	local celeste_path="$1"

	# check if the things we need exist
	if ! [ -f "$celeste_path/Celeste.exe" ];	then echo "no_celeste_exe";	return; fi
	if ! [ -f "$celeste_path/FNA.dll" ];		then echo "no_fna";		return; fi
	if ! [ -f "$celeste_path/System.Xml.dll" ];	then echo "no_system_xml_dll";	return; fi
	if ! [ -f "$celeste_path/System.Core.dll" ];	then echo "no_system_core_dll";	return; fi
	if ! [ -d "$celeste_path/Content" ];		then echo "no_content";		return; fi

	# check if everest is installed (we do NOT want everest installed!)
	if [ -f "$celeste_path/everest-launch.txt" ];		then echo "modded"; return; fi
	if [ -f "$celeste_path/MonoMod.RuntimeDetour.dll" ];	then echo "modded"; return; fi
	if [ -f "$celeste_path/MonoMod.exe" ];			then echo "modded"; return; fi
	if [ -f "$celeste_path/MonoMod.Utils.dll" ];		then echo "modded"; return; fi
	if [ -f "$celeste_path/MMHOOK_Celeste.dll" ];		then echo "modded"; return; fi
	if [ -f "$celeste_path/MiniInstaller.exe" ];		then echo "modded"; return; fi
	if [ -f "$celeste_path/NLua.dll" ];			then echo "modded"; return; fi
	if [ -f "$celeste_path/KeraLua.dll" ];			then echo "modded"; return; fi
	if [ -f "$celeste_path/lua53.dll" ];			then echo "modded"; return; fi
	if [ -f "$celeste_path/Celeste.Mod.mm.dll" ];		then echo "modded"; return; fi
	if [ -f "$celeste_path/discord-rpc.dll" ];		then echo "modded"; return; fi

	# check if it's a Steam install of Celeste or not
	if [ -f "$celeste_path/Steamworks.NET.dll" ]; then
		echo "ok_steam"
	else
		echo "ok"
	fi
}

if ! [ -d "$celeste_path" ]; then
	error "the path you specified doesn't exist"
	exit 1
fi

info "verifying celeste install"
celeste_install_status=$(check_celeste_install "$celeste_path")

celeste_is_steam=0

case $celeste_install_status in
	"no_celeste_exe")
		error "your game install seems to be invalid (no Celeste.exe was found)"
		error "please make sure you pointed to the correct directory." 1
		exit 1
		;;
	"no_fna")
		error "your celeste install seems to not be FNA-based, which is needed for ios compatibility."
		error "please download a version of the game that uses FNA." 1
		error "on steam:" 1
		error " - the linux build uses FNA by default" 1
		error " - on windows, you can get the FNA version by selecting the 'opengl' beta for celeste on steam" 1
		error "on itch.io:" 1
		error " - download either the celeste linux build or the windows FNA build" 1
		error "on epic games:" 1
		error " - you should already be on the FNA version by default" 1
		exit 1
		;;
	"no_system_xml_dll")
		error "your celeste install seems to be missing System.Xml.dll"
		exit 1
		;;
	"no_system_core_dll")
		error "your celeste install seems to be missing System.Core.dll"
		exit 1
		;;
	"no_content")
		error "your celeste install seems to be missing the Content directory"
		error "please try redownloading the game." 1
		exit 1
		;;
	"modded")
		error "your celeste install appears to be modded!"
		error "please try redownloading the game or specifying the path to an unmodified install." 1
		exit 1
		;;
	"ok_steam")
		celeste_is_steam=1
		info "found steam build of celeste"
		;;
	"ok")
		celeste_is_steam=0
		info "found non-steam build of celeste"
		;;

	*)
		error "congratulations, you got an error that isn't possible!"
		error "'$celeste_install_status'" 1
		error "this might be a bug in this script" 1
		exit 1
esac

function get_fmod() {
	# ask to download FMOD
	info "please download the iOS version \"FMOD Engine\" version 1.10.09 (click 'Older') from https://www.fmod.com/download?version=1.10.09#fmodengine and open the .dmg"
	info "before proceeding! this SPECIFIC version of FMOD is required to build the game! please note that you while you need an account, the download is not paid!"
	read -r

	_fmod_path=$(mount |grep "FMOD Programmers API iOS" |sed 's/ (.*//g')
	fmod_path="${_fmod_path#*on }"

	if ! [ -d "$fmod_path" ]; then
		error "FMOD not found, please download and mount the .dmg and try again."
		get_fmod
	fi

	if ! head -n 10 "$fmod_path/FMOD Programmers API/doc/revision.txt"|grep "1.10.09"; then
		error "the FMOD image you downloaded appears to be a different version than 1.10.09, please unmount the image and download the correct version."
		get_fmod
	fi

	info "copying FMOD libraries from $fmod_path"
	if ! cp "$fmod_path/FMOD Programmers API/api/lowlevel/lib/libfmod_iphoneos.a" "$script_dir/celestemeow/libfmod.a"; then
		error "failed to copy libfmod_iphoneos.a"; exit 1
	fi
	if ! cp "$fmod_path/FMOD Programmers API/api/studio/lib/libfmodstudio_iphoneos.a" "$script_dir/celestemeow/libfmodstudio.a"; then
		error "failed to copy libfmodstudio_iphoneos.a"; exit 1
	fi
}

if ! [ -f "$script_dir/celestemeow/libfmod.a" ] || ! [ -f "$script_dir/celestemeow/libfmodstudio.a" ]; then
	info "fmod not found, prompting to download it"
	get_fmod
else
	info "fmod found"
fi

info "checking for required tools..."

if ! command -v git &>/dev/null; then missing_tool git "please install Xcode."; fi
if ! command -v dotnet &>/dev/null; then missing_tool dotnet "install Visual Studio for Mac and make sure the Xamarin.iOS and .NET workloads are selected"; fi
export PATH="$PATH:$HOME/.dotnet/tools"
if ! command -v ilspycmd &>/dev/null; then
	info "ilspycmd is not installed, attempting to install it using dotnet"
	if ! dotnet tool install --global ilspycmd --version 8.0.0.7246-preview3; then error "failed to install ilspycmd, please try installing it manually"; exit 1; fi

	if ! command -v ilspycmd &>/dev/null; then error "failed to invoke ilspycmd after installing, make sure it installed correctly"; exit 1; fi
fi

info "cloning submodules..."
update_submodules 0 # not doing --recursive because FNA's submodules are broken and will fail to clone

cd "$script_dir/FNA" || cd_fail
clone_repo https://github.com/FNA-XNA/FAudio lib/FAudio --branch 21.03.05 --single-branch --recursive # --single-branch makes cloning faster
clone_repo https://github.com/FNA-XNA/FNA3D lib/FNA3D --branch 21.03 --single-branch # this one fails to clone submodules, don't use --recursive
clone_repo https://github.com/flibitijibibo/SDL2-CS lib/SDL2-CS # we need to checkout a specific commit here so we can't use --branch
clone_repo https://github.com/FNA-XNA/Theorafile lib/Theorafile # ^ same thing here

cd "$script_dir/FNA/lib/SDL2-CS" || cd_fail
if ! git checkout 2b8d237fd4585d14ea837764ac247d4cd200158f; then error "failed to checkout SDL2-CS"; exit 1; fi
cd "$script_dir/FNA/lib/Theorafile" || cd_fail
if ! git checkout 0c5504658a3108919e53b625287786a87529de42; then error "failed to checkout Theorafile"; exit 1; fi

fna3d_path="$script_dir/FNA/lib/FNA3D"

cd "$fna3d_path" || cd_fail
clone_repo https://github.com/FNA-XNA/MojoShader MojoShader
clone_repo https://github.com/KhronosGroup/Vulkan-Headers Vulkan-Headers

cd "$fna3d_path/MojoShader" || cd_fail
git checkout c9037d90fa2f59b6be65d1391ca11d345356bad1
git submodule update --init --recursive

cd "$fna3d_path/Vulkan-Headers" || cd_fail
git checkout 85470b32ad5d0d7d67fdf411b6e7b502c09c9c52
git submodule update --init --recursive

cd "$fna3d_path" || cd_fail
git submodule update --init --recursive

cd "$script_dir/FNA" || cd_fail
# update submodules recursively to make sure we have everything we need
git submodule update --init --recursive

# apply required patches

apply_patch() {
	if [ "$2" == "1" ]; then mv "$script_dir/.git" "$script_dir/.git-tmp"; fi
	if git apply "$1" --reverse --check 2>/dev/null && ! git apply "$1" --check 2>/dev/null; then
		if [ "$2" == "1" ]; then mv "$script_dir/.git-tmp" "$script_dir/.git"; fi
		info2 "patch already applied"
	else
		if ! git apply "$1"; then
			if [ "$2" == "1" ]; then mv "$script_dir/.git-tmp" "$script_dir/.git"; fi
			error "failed to apply patch"
			exit 1
		fi
	fi
	if [ "$2" == "1" ]; then mv "$script_dir/.git-tmp" "$script_dir/.git"; fi
}

info "applying patches to FNA"
apply_patch "$script_dir/patches/FNA.patch"
cd "$script_dir/FNA/lib/FNA3D" || cd_fail
apply_patch "$script_dir/patches/FNA-FNA3D-renderer.patch"

cd "$script_dir" || cd_fail
info "recursively copying celeste game directory"
cp -a "$celeste_path/." "$script_dir/_celeste_game/"

info "decompiling the game"
rm -rf _celeste_decomp 2>/dev/null
mkdir _celeste_decomp 2>/dev/null || echo a >/dev/null
if ! ilspycmd -o "_celeste_decomp" -p -d -r "_celeste_game" "$script_dir/_celeste_game/Celeste.exe"; then
	error "failed to decompile the game!"
	exit 1
fi

info "patching the game"

cd "$script_dir/_celeste_decomp" || cd_fail
if [ "$celeste_is_steam" == "1" ]; then
	info2 "applying steam-specific patches"
	apply_patch "$script_dir/patches/remove-steam.patch" 1 # the 1 at the end will make the function temporarily rename the .git folder so git doesn't stop us from applying the patch
	apply_patch "$script_dir/patches/remove-steam2.patch" 1 # (fuck you git)
fi
apply_patch "$script_dir/patches/crash-fixes.patch" 1 # fuck you git, again

info "building the patched game"
if ! dotnet publish --configuration Release; then error "failed to build the game!"; exit 1; fi

cd "$script_dir" || cd_fail

function copy_game_files() {
	if ! cp -r "$1" "$2"; then error "failed to copy '$1' to '$2'"; exit 1; fi
}

info "copying files"
mkdir "$script_dir/celeste" 2>/dev/null || echo a >/dev/null
copy_game_files "$script_dir/_celeste_decomp/bin/Release/net452/Celeste.exe" "$script_dir/celeste/Celeste.dll"
copy_game_files "$script_dir/_celeste_game/mscorlib.dll" "$script_dir/celeste"
copy_game_files "$script_dir/_celeste_game/Celeste.Content.dll" "$script_dir/celeste"
copy_game_files "$script_dir/_celeste_game/Content" "$script_dir/celestemeow/"
copy_game_files "$script_dir/misc/Celeste.dll.config" "$script_dir/celeste/"

info "building native libraries"
cd "$script_dir/fnalibs-ios-builder-celeste" || cd_fail

nativelib_build_err() {
	error "failed to build native libraries!"
	error "do you want to use the prebuilt libraries? [Y/n]\c" 1
	read -n 1 -r reply
	if [ "$reply" != "" ]; then echo; fi
	if [ "$reply" = "${reply#[Nn]}" ]; then
		if ! cp -r "$script_dir/fnalibs-ios-builder-celeste/prebuilt/." "$script_dir/celestemeow/"; then
			error "failed to copy prebuilt native libs!"
			exit 1
		fi
	else
		error "no native libraries, can't continue"
		exit 1
	fi
}

if ! ./updatelibs.sh; then nativelib_build_err; fi
if ! ./buildlibs.sh ios; then nativelib_build_err; fi
if ! cp -r "$script_dir/fnalibs-ios-builder-celeste/release/ios/device/." "$script_dir/celestemeow/"; then nativelib_build_err; fi

cd "$script_dir" || cd_fail
if ! msbuild /restore /p:Configuration="AppStore" /p:"Configuration=Release;Platform=iPhone" /target:celestemeow /p:EnableCodeSigning=false; then
	error "failed to build ios project"
	exit 1
fi

info "moving built ipa to $script_dir"
if ! mv "$script_dir/celestemeow/bin/iPhone/Release/celestemeow.ipa" "$script_dir/"; then error "failed to move ipa"; exit 1; fi

success "done building celeste for ios!"
success "the ipa is located in '$script_dir' and can be installed using something like TrollStore or AltStore" 1
