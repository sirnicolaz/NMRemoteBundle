//
//  NSBundle+Remote.h
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/22/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock) (NSBundle *bundle);

#define NMRemoteBundleDidUpdateNotification @"NMRemoteBundleDidUpdate"

@interface NSBundle (Remote)

@property (nonatomic, assign, readonly) NSInteger refreshRate; // Days, default = 1
@property (nonatomic, strong) NSURL *remoteURL;

+ (id)mainRemoteBundle;
+ (void)setMainRemoteBundle:(NSBundle *)bundle;
+ (void)createWithRemoteURL:(NSURL *)url  // Asynchronous
            completionBlock:(CompletionBlock)block;
- (id)initWithRemoteURL:(NSURL *)url; // Synchronous


@end
