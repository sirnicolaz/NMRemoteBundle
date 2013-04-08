//
//  NMAppDelegate.m
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/22/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#import "NMAppDelegate.h"
#import "NMRemoteStringExampleViewController.h"

@implementation NMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    NMRemoteStringExampleViewController *example = [[NMRemoteStringExampleViewController alloc] initWithNibName:@"NMRemoteStringExampleViewController" bundle:nil];
    self.window.rootViewController = example;
    [self.window makeKeyAndVisible];
    
    // If bundle not set, retrieve it
    if (![NSBundle mainRemoteBundle]) {
        
        // NB: this method is asynchronous, so it won't block the app launch
        [NSBundle createWithRemoteURL:[NSURL URLWithString:@"http://www.ahitalia.com/Remote.zip"] completionBlock:^(NSBundle *remoteBundle){
            
            // Once bundle is retrieved, set it as the main one and reset the strings
            [NSBundle setMainRemoteBundle:remoteBundle];
            dispatch_async(dispatch_get_main_queue(), ^{
                [example setStrings];
            });
        }];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
