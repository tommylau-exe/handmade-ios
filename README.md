# Hand-making an iOS app

If you're an iOS developer, you likely use Xcode to do the vast majority of your
development work. Xcode makes it
as easy as possible to get an app up and running, especially for beginners.
Plus, with addition of tightly-integrated IDE features
like SwiftUI previews and inline macro expansion, you'd have little reason to want to
use anything else.

But have you ever stopped to consider *how* Xcode does some of
the things it does? I'm not talking about the aforementioned IDE
features, I mean the basic stuff, like:

1. How is the code that I write transformed into an app?
2. What *is* an app?
3. How does my app run in the simulator?

As someone who learned to code with Xcode, I never even considered
that you could develop for iOS without it. I'll demonstrate how simple it
can be to compile a simple iOS `.app` for the
simulator using nothing but Clang, the Xcode command-line tools, and
your shell.

### Prerequisites

We won't be using Xcode as a build system or IDE, however, we'll still be
dependent on the Xcode command-line tools and the iOS simulator. So make sure
you have Xcode downloaded, along with at least one iOS simulator runtime.

## The code

```c
// main.c
#include <unistd.h>

int main(void)
{
    char msg[] = "hello, world!\n";
    write(1, msg, sizeof(msg)-1);
    sleep(1);

    return 0;
}
```

If you've ever taken a low-level programming class, this will look
familiar. Just a basic hello world program with an additional delay before
exiting. I opted to not use the C standard library as a matter of personal
taste, but you may feel free to `printf` to your heart's content. The extra
delay is only there because the simulator will actually show a warning if your 
app exits too quickly (since apps are typically long-running processes).

You can, of course, run this file on your Mac right now with a quick little
`clang main.c && ./a.out`. However, obtaining a binary that can be run in the
iOS simulator requires an extra step.

### Cross-compilation

Don't run away just yet! I promise this isnt' as intimidating as it seems.

The Xcode command line tools actually make cross-compilation
pretty straightforward. By looking through Xcode build logs in a reference
project (plus some trial and error) it seems that we need to set the
`-isysroot` parameter to get a binary suitable for the iOS simulator.
`isysroot` essentially changes the base directory where Clang
will look for header files as well as help Clang infer some other important
parameters (like the target triple).

However, there's an easier way if we leverage `xcrun`. If you're not familiar,
`xcrun` is just a wrapper around the Xcode command-line tools to support
multiple toolchains and SDKs. Taking advantage of that, we can run `xcrun -sdk
iphonesimulator clang` and that will handle setting `-isysroot` for us.

So, put it all together and the magic incantation would look something like...

``` sh
#!/bin/sh
# build.sh
set -e

mkdir -p handmade-ios.app
xcrun -sdk iphonesimulator clang \
    -o handmade-ios.app/handmade-ios \
    main.c
```

You may have noticed I'm also creating a directory `handmade-ios.app`. Let's
get into that.

## The app

There are many different ways that you may have seen an iOS app represented on
your filesystem. Maybe you're familiar with `.xcarchive`, `.ipa`, or `.app`.
While each of these formats have their own uses, and are closely related, for
this post we're going to focus on the simplest one: `.app`. Conveniently, this
is also all the simulator needs.

A `.app` file is actually a directory, which is commonly referred to in Apple
documentation as the [Application Bundle][bundle].
According to the documentation, the only required contents in a Bundle are:

- The executable (`handmade-ios`)
- An `Info.plist` containing required app metadata

And that's it! I bet you thought it was more complicated, huh? With that
knowledge, let's drop some boilerplate into `handmade-ios.app/Info.plist` and
be on our way.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>handmade-ios</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.handmade-ios</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Handmade</string>
    <key>CFBundlePackageType</key>
    <string>AAPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>UILaunchScreen</key>
    <dict></dict>
</dict>
</plist>
```

*Note:* `UILaunchScreen` is not strictly necessary, but the iOS app's UI will
act strangely if that key is missing.

## The simulator

The easiest way to run our new app is by simply dragging the `.app` folder from
Finder to the simulator. This should install the app and put it on the home
screen. Just tap on it, and voila!

But where's our "hello, world?" For that, you'll have to launch the app from
your shell.
For example, if you're using an iPhone 15 simulator on iOS 17.4 you would run
`xcrun simctl launch --console 9340DADD-23AC-42E0-A6AF-BA720B728DD9
com.example.handmade-ios`. If you want to use a different simulator, find it's
corresponding device ID in `xcrun simctl list`.

And there's our message! In the console you should see `hello, world!`.

### Simulator automation

We can actually do a bit better when it comes to installing the
app. The `simctl` tool is quite robust, and I'm surprised I hadn't heard much
about it before I set out on this exploration. In order to automatically boot the
desired simulator, install the app, and launch the app in one go, you could do
something like the following:

```sh
#!/bin/sh
# run-simulator.sh
set -e

IPHONE_15_SIM_ID="9340DADD-23AC-42E0-A6AF-BA720B728DD9"
xcrun simctl bootstatus "$IPHONE_15_SIM_ID" -b > /dev/null
xcrun simctl install "$IPHONE_15_SIM_ID" ./handmade-ios.app
xcrun simctl launch --console "$IPHONE_15_SIM_ID" com.example.handmade-ios
```

With this, whenever you make changes you should be able to simply `./build.sh
&& ./run-simulator.sh` to compile and run any changes.

## Wrapping up

I hope this opened your eyes a bit as to what is really going on under-the-hood
of an iOS app. Sometimes in software it feels like we're building upon
foundations which are impossible fully comprehend. But in reality, once you
peek behind the curtain you may realize that what our tools hide from
us isn't that complicated after all. Although Xcode is quite complex, that
doesn't mean that our apps must be complex as well.

### Additional exercises

1. Show a UIKit component. [Solution][uikit-solution]
2. Compile a Swift program rather than C or Objective-C. [Solution][swift-solution]
3. Show a SwiftUI view. [Solution][swiftui-solution]

[bundle]: https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html
[uikit-solution]: https://github.com/tommylau-exe/handmade-ios/tree/uikit
[swift-solution]: https://github.com/tommylau-exe/handmade-ios/tree/swift
[swiftui-solution]: https://github.com/tommylau-exe/handmade-ios/tree/swiftui
