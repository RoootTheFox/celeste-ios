# Celeste on iOS

# How to Build

This guide will walk you through building a Celeste IPA for iOS using macOS. Please note that **only macOS** is supported for this process. If you don't have a Mac you'll have to use a Virtual Machine.

## Prerequisites

1. **Install Xcode**  
   Make sure you have Xcode installed and set up correctly. You can download it from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835).

2. **Install Git**  
   If Git isn't already installed, running `git` from your terminal will often prompt to install it.

3. **Install FMOD Engine**  
   - Go to the FMOD download page: [FMOD v1.10.09](https://www.fmod.com/download?version=1.10.09#modengine).  
   - You will need to create a free FMOD account to download.
   - Make sure that the FMOD version is set to v1.10.09 (unsupported)
   - Download the **iOS** version of **FMOD Engine**
   - After downloading, mount the downloaded `fmodstudioapi11009ios-installer.dmg` file by double-clicking it. **No need to do anything further**; simply ensure it's mounted.

4. **Install Visual Studio for macOS**  
   - Download Visual Studio for macOS from [here](https://my.visualstudio.com/Downloads?q=visual%20studio%20for%20mac).
   - Follow the installation instructions.
   - When prompted during installation, make sure to select the following components:
     - `.NET`
     - `.Net Multi-Platform App UI`
     - `Android`
     - `iOS`
   - You do **not** need to sign into Visual Studio, but the installation will require your macOS password.
   - Once the installation is complete and you see the option to create or open a project, simply close the program. We won’t need to open Visual Studio after this.

## Installing Celeste (FNA Build)

### 1. **From itch.io**  
   - You can download/buy Celeste directly [here](https://mattmakesgames.itch.io/celeste).  
   - After purchase or login, download the **Celeste Linux** Version.

### 2. **From Steam**  
   - Make sure Steam is installed on your system.
   - Make sure Steam is not open.
   - Type `steam://open/console` into the URL bar of your browser, and allow it to open Steam.
   - Steam should open with a new **Console** Tab, go into it.
   - Type `download_depot 504230 504233 1505052356460012099` into the Steam console and wait for it to install (there won't be a progress bar).
   - Once complete, it will tell you where the files were installed. It will say something like this:
   
     ```bash
     Depot download complete: "/Users/username/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS\\steamapps\\content\\app_504230\\depot_504233" (1259 files, manifest 1505052356460012099)
     ```

   - In this case, `depot_504233` is your Celeste folder that you should give to the build script. *This may vary.*
   - Please move this folder to somewhere else, like your Downloads, or Documents folder, you can also rename it something like `Celeste-Linux`

Once you have installed Celeste, make sure the folder contains content such as `Celeste.exe`, `Content` (folder), `Backups` (folder), `lib` (folder), `lib64` (folder).


## Building the IPA

1. Open Terminal and navigate to where you'd like to install the build:
   ```bash
   cd Documents  # or your preferred directory
   ```

2. Clone the repository:
   ```bash
   git clone https://github.com/RoootTheFox/celeste-ios.git
   ```

3. Navigate to the cloned directory:
   ```bash
   cd celeste-ios
   ```

4. Run the build script:
   ```bash
   ./build.sh
   ```

5. When prompted, drag and drop your celeste folder you downloaded earlier into the Terminal and press **Enter**.

6. The build script will then ask:
   - **"Do you want to enable a virtual game controller if no other input devices are detected? iOS 15+ only! (y/n)"**  
     My recommendation is to type `n` for **no** unless you plan on using touch controls, as there could be issues with iOS 16 and above not auto-disabling the on-screen controller when a physical controller is connected.
   
   - **"Do you want to build MoltenVK as well? This is required for FNA3D, but building takes a while so it can be skipped on subsequent rebuilds. (y/n)"**  
     If this is your first time building this, type `y` for **yes**

## Completion

After a while, the script will generate an IPA file called **celestemeow.ipa**, located in the folder where you cloned the project.

You're now ready to install the IPA on your iOS device using something like TrollStore, AltStore or similar!
* *Please note if you're using purchased certs from someone like KravaSign or Signulous, it is advised to use the website [KravaSigner](http://kravasigner.com) to sign your ipa's even if you didn't purchase your certs through KravaSign, apps like esign, feather and others can cause issues to do with rendered screen size*

## credits
- **@TheSpydog** for demonstrating this being possible and for developing the fnalibs-ios-builder
- **@r58Playz** for adding touch controls(!) and fixing building on newer Xcode versions
- my friends for being supportive <3
<br><sub>i might have forgotten some people here, so this list is not exhaustive!!</sub>
