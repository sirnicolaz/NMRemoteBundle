Introduction
---------------

**Background:**


- localized iOS app development
- 1 week time review for each app submission
- frivolous translators / testers

**Problem:**

- App approved and propagated in the stores -> 2 minutes later the typo/too long string/wrong translation is noticed

**Solution:**

- Keep the strings centralized


So, this small project mainly born to overcome the problem of localizations. By keeping the string files centralized in you server and loading them every once in a while, should fix the problem of resubmitting the app every time an issue of this sort is found.
But, given that Apple allows to dynamically load everything that is not *code*, the project has been extended support the remote dynamic loading of the complete bundle.


----

Setup
-------

The project is composed by a lightweight category on NSBundle.
In addition a macro for the remote localized strings has been provided.

To integrate the library just copy `NMRemoteBundle/Classes/*` in your project directory.

After that, you should create a bundle to place somewhere around the internet, with the following structure:
<pre><code>
Resources/
    en.lproj/
         Localizable.strings
    de.lproj/
         Localizable.strings
    Info.plist
</pre></code>

Of course you can add as many languages as you like. One important thing is to include a minimal `Info.plist` file, like this:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundlePackageType</key>
	<string>BNDL</string>
	<key>CFBundleIdentifier</key>
	<string>com.yourdomain.yourbundlename</string>
</dict>
</plist>
```

There is also a refresh mechanism the can be setup straight in the `Info.plist`, by setting this further key:

``` xml
       <key>NMBundleRefreshRate</key>
       <string>3</string> <!-- days -->
```

Zip the `Resources` directory and put it somewhere where you like in the cyberspace.<br/>
Finally, put this in your AppDelegate `appDidFinishLaunching`:

``` objective-c
// If bundle not set, retrieve it
    if (![NSBundle mainRemoteBundle]) {
        
        // NB: this method is asynchronous, so it won't block the app launch
        [NSBundle createWithRemoteURL:[NSURL URLWithString:@"http://www.yourdomain.com/YourRemoteBundle.zip"] completionBlock:^(NSBundle *remoteBundle){
            
            // Once bundle is retrieved, set it as the main one and reset the strings
            [NSBundle setMainRemoteBundle:remoteBundle];
            dispatch_async(dispatch_get_main_queue(), ^{
                [example setStrings];
            });
        }];
    }
```

You can look at the example and the code to have a better idea (maybe).

How it is supposed to work
------------

As soon as the app finishes launching, an asynchronous call is performed against the server where you are hosting the remote bundle. As soon as the download is done, the bundle is stored and setup locally, ready to be used.
You can at this point set this just downloaded bundle as you main remote bundle (that you can then easily access via

```objective-c
[NSBundle mainRemoteBundle];
```

Given that the bundle takes some time to be loaded, and that it might happen that the server doesn't respond, it's always better to have a local fallback copy of the bundle.

Throughout the app you can then use the handy macro

```objective-c
NSRemoteLocalizedString(@"String key", @"Comment");
```

that will:
- check whether a main remote bundle exists
- if it does, load the localized string from it
- if it doesn't, load the localized string from the fallback local bundle

If you really want to seamlessly add *remoteness* to your string, you can even redefine the macro

```objective-c
NSLocalizedString(@"String key", @"Comment");
```

to be replaced with the remote version. At your risk.

If a refresh rate is not set in the `Info.plist`ß, a default value of 1 (day) will be used.
Anyway, the refresh is triggered whenever the *mainRemoteBundle* is accessed: if the bundle is older than the specified amount of days, in background a call is performed to updated. As soon as it returns, the local bundle is overwritten and the new resources will be automatically used.

Future
-------

Probably add some utilities to easily access remote images/xibs/so on. And bug fixes. And other stuff, who knows...

License
-------

Licensed under the New BSD License.

Copyright (c) 2012, Nicola Miotto All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. * Neither the name of Nicola Miotto nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Nicola Miotto BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.