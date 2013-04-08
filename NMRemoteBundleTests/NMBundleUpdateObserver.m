//
//  NMBundleUpdateObserver.m
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/25/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#import "NMBundleUpdateObserver.h"

@implementation NMBundleUpdateObserver

@synthesize didReceiveNotification = didReceiveNotification_;

- (id)init
{
    self = [super init];
    self.didReceiveNotification = NO;
    return self;
}

- (void)handleBundleDidUpdate:(NSNotification *)notification
{
    self.didReceiveNotification = YES;
}

@end
