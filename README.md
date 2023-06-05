# Celeste on iOS

## what you'll need
- an **FNA** build of Celeste (this repo has been tested with the Steam version only, the itch.io version *should* work too)
- MacOS (if you don't have access to a MacOS machine, you can use a MacOS VM)
- XCode
- Visual Studio for Mac with the C#, .NET and Xamarin.iOS workloads
- patience

## caveats
- no touch support - you *need* a keyboard to play (if you want to implement touch support, feel free to make a PR!)

## how to build
- install the needed software mentioned above
- run `./build.sh`
- follow the instructions
- hope it works :3

these instructions might be slightly wrong or have missing information because i wrote this like 3 months ago and don't remember every detail - if you have issues feel free to open an issue :3

## installing
the script will tell you where the final .ipa file is located - just sideload it to your iOS device using something like TrollStore, AltStore or similar
