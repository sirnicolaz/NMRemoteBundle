//
//  NMBundleUpdateObserver.h
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/25/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NMBundleUpdateObserver : NSObject

@property (nonatomic, assign) BOOL didReceiveNotification;

- (void)handleBundleDidUpdate:(NSNotification *)notification;

@end
