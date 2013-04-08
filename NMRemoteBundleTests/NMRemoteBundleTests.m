//
//  NMRemoteBundleTests.m
//  NMRemoteBundleTests
//
//  Created by Nicola Miotto on 3/22/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#import "Kiwi.h"
#import "NSBundle+Remote.h"
#import "NMRemoteStrings.h"
#import "NMBundleUpdateObserver.h"

SPEC_BEGIN(RemoteBundle)

describe(@"Remte NSBundle", ^{
    
    NSURL *remoteBundleURL = [NSURL URLWithString:@"http://www.ahitalia.com/Remote.zip"];
    
    context(@"given a bundle stored remotely", ^{
       
        it(@"should initialize the remote bundle sinchronously", ^{
            
            NSBundle *remoteBundle = [[NSBundle alloc] initWithRemoteURL:remoteBundleURL];
            
            [[expectFutureValue(remoteBundle) shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
            
        });
        
        it(@"should initialize the remote bundle asynchronously", ^{
            __block NSBundle *remoteBundle = nil;
            [NSBundle createWithRemoteURL:remoteBundleURL completionBlock:^(NSBundle *aRemoteBundle) {
                remoteBundle = aRemoteBundle;
            }];
            
            [[expectFutureValue(remoteBundle) shouldEventuallyBeforeTimingOutAfter(10.0)] beNonNil];
        });
    });
    
    context(@"given a loaded remote bundle", ^{
        
        // Retrieve the remote bundle and make it the main one
        NSBundle *remoteBundle = [[NSBundle alloc] initWithRemoteURL:remoteBundleURL];;
        [NSBundle setMainRemoteBundle:remoteBundle];
        
        // Test strings
        NSString *testString = @"Time is an illusion...";
        NSString *expectedTranslation = @"...lunch time doubly so.";
        
        it(@"can load strings from the bundle", ^{
            NSString *translation = [remoteBundle localizedStringForKey:testString value:@"" table:nil];
            [[translation should] equal:expectedTranslation];
        });
        
        it(@"can load strings from the bundle, the short way", ^{
            NSString *translation = NMRemoteLocalizedString(testString, nil);
            [[translation should] equal:expectedTranslation];
        });
        
        it(@"gets updated on background if necessary", ^{
            SEL selector = @selector(handleBundleDidUpdate:);
            
            NMBundleUpdateObserver *observer = [NMBundleUpdateObserver new];
            
            [[NSNotificationCenter defaultCenter] addObserver:observer
                                                     selector:selector
                                                         name:NMRemoteBundleDidUpdateNotification
                                                       object:nil];
            
            [remoteBundle performSelector:@selector(setLastUpdated:) withObject:[NSDate distantPast]];
            [NSBundle mainRemoteBundle]; // should fire the update
            
            [[expectFutureValue(theValue(observer.didReceiveNotification)) shouldEventuallyBeforeTimingOutAfter(10.0)] beYes];
            
        });
    });
});

SPEC_END