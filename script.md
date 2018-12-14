Things I want to talk about in episode 0:

1. installing modbuddy
2. installing amu
3. installing vscode
4. installing yeoman
5. generating mod
6. building mod
7. publishing mod

## 0. Introduction

Hello, I'm Aleosiss, author of the Rising Tides mod, and this is a tutorial, maybe even tutorial series, on how to set up and develop mods for XCOM2. 

You might ask yourself, wait, you idiot, isn't this like 3 years late? Well, no. As the community has cycled, more innovations have advanced what we're capable of and how we develop, so now is as good a time as any. In particular, the Community Highlander is pretty mature at this point, and there is a decent turn-around-time on pull requests and releases, which means that any kind of mod requiring overrides of base-game code are much easier to make these days. As stands, the tooling improvements that have allowed that to happen also benefit the rest of us. 

This video will focus on an approach that minimizes our exposure to ModBuddy; there are already plenty of content related to getting started with Modbuddy.


## 1. Installing Modbuddy

Okay, let's get started. This episode 0 is technically about setting up your mod tools, but I will also create and publish a mod to the Steam Workshop by the end of it to show how the whole setup works from end to end.

First, you're going to need to install the XCOM2 SDK. This isn't as simple as clicking install; there's several steps here. After the install completes, you have a decision to make: what kind of mod do you want to make?

Is it a simple edit to a script, or configuration? Something that doesn't require graphics? If that is the case, you are fine. But if not, you want to get the full_content release. Simply right-click on the SDK in the Steam tools section, navigate to betas, and select full_content from the dropdown. This will prompt Steam to download an additional 90gb of content to the XCOM2 Editor.

Next step. We need to additionally install modbuddy itself and binaries related to UE3. Navigate back to the Steam tools section and open up the SDK properties once again. This time, we need to open up the Local Files tab, then click on 'Browse Local Files' to open up an Explorer window.

Make note of this path, by the way. Copy it down somewhere, you will need it later. While we're here, we might as well also copy down the path for the XCOM2 game itself.

Now that we're here, we navigate to Binaries/Redist. In here are two installers with a .vdf. Install both.

Oh, yeah, we're done with Modbuddy at this point.

## 2. Installing AMU

Next, we're going to install the Alternate Mod Uploader. Navigate to the Steam Workshop and search for 'Mod Uploader', by, of course, Robojumper.

After you hit subscribe, navigate to the mod's folder, and extract the contents to somewhere else.

Mark down this path for later, and append the name of the `.exe` to it. Just like the SDK path, you will need this in the future.

## 3. Installing VSCode

Navigate to https://code.visualstudio.com and download the latest version of Visual Studio Code. If you use Atom, or another text-editor, be aware that the you will probably have to write your own runner file equivalent. If you don't know what that means, just download and install VSCode.

Open up VSCode.

## 4. Installing Yeoman

We are now about to taste the magic. Open up another web browser tab and navigate to nodejs.org.

<OOF> Yeah, I know.

Download and install node.js and npm, which are requirements for the XCOM2 project generator. I would note, again, the path given by the installer. This is less useful than the other paths we're noted, but in case you don't have access to the node binaries, you will have to add this path to the... PATH. Yeah.

Now go back to VSCode and create your project folder. Great. VSCode has almost too many great shortcuts for you to use-- Hit control-shift-p to open up the command pane, then look for 'toggle integrated terminal' to open up a Powershell window.

Now we can install the generator! type `npm -g i yo generator-x2mod` and get something to drink. This might take a while, and if you're not used to technical stuff, this might be a little brain-melting. But don't worry! We're frontloading the work here, remember. Once that's done, we can move to the next stage.

## 5. Generating mods

If you can believe it, we're almost done! The next steps are very easy on your end. I'll give timestamps to skip forward, past my rambling, because once I've shown you the step, I'm going to take a minute to talk about it.

In your VSCode window, type `yo x2mod`. This will begin the process of generating a mod. You should copy-paste the paths I told you to jot down earlier. Something important to note about yeoman is that if there is a default value, it will be captured in parenthesis. Just hit enter without typing anything if you approve of the value. MAKE SURE to chose the vscode option, when given. (Obviously, if you're using a different editor, just choose it or nothing).

Once the process is complete, you have a mod. Gaze at it. Open it up, look at the tree. Navigate to the src/modname/classes folder and take a look at the files inside. First, we have the X2DLCInfo. This is often the entry point for your mod. Of course, if you're just doing some simple config changes, feel free to delete some of these files.

Next is something you probably didn't expect, if you've made a mod in the past. The `extra_globals.uci`. If we open it up, we see a lot of commented code. This is where you can define your own macros, which are basically code snippets. Pretty nifty, especially when dealing with static method calls. You might be familiar `XCOMHISTORY, or `CREATE_X2TEMPLATE, which are used frequently in Firaxis code.

Next, go up a bit and take a look at the Config folder. This is the important one. These three `.ini`s tell XCOM2 to load your script package. Finally, you can check out the Localization folder, which has the localization files for the International, or English, version of your mod.

## 6. Building mods

Now we're going to build the mod. Hit Control-Shift-P to open up the Command Palette again. Type in Tasks: and select run build task. A new integrated terminal will pop up and your mod will start building. When it completes, You'll get a beep, and congrats, you just made a mod.

Let's take a closer look at the build process real quick. Navigate to the root of your project in VSCode and open up the `.scripts` folder.

Check out the `build.ps1`. This is where the magic happens. This script takes care of several modbuddy-related issues. First, it automatically patches the `.x2proj` file. If you used Modbuddy, you probably are familiar with the annoyances related to the `.x2proj` being out of sync with the actual mod; well, this handles all of that. It also can check if you need to recompile the shader cache, which can cut your build times down quite a bit. Finally, it patches the `globals.uci` with the `extra_globals.uci` from before, letting you compile with your macros. It even has nice audio-based build feedback. There are also simpler scripts related to launching the X2Editor, the Alternate Mod Uploader, and the game.

## 7. Publishing mods

Open up the Command Palette again, and this time select a generic 'Run Task'. Go to Open AMU and hit it. Go through each stage, which is pretty self-explanatory. Note the while the Description is populated from the Readme initially, further updates will pull it from the mod's steam workshop entry. And, we're done.

## 8. Outro



## The Video

The intro is 5 seconds long. The Program emblem glitches into the foreground. The background is white, with grey lines going across, similar to a crt. After the icon loads, text begins scrolling in the background, logging related to Phoenix. At 4 seconds, the log exits and the Program emblem glitches out of existance.