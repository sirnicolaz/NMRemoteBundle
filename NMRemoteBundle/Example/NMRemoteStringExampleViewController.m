//
//  NMRemoteStringExampleViewController.m
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/25/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#import "NMRemoteStringExampleViewController.h"

@interface NMRemoteStringExampleViewController ()

@end

@implementation NMRemoteStringExampleViewController

@synthesize string1 = string1_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bundleDidUpdate:) name:NMRemoteBundleDidUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc
{NSLocalizedString(nil, nil)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NMRemoteBundleDidUpdateNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setStrings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setStrings {
    self.string1.text = NMRemoteLocalizedString(@"Time is an illusion...", @"Quote by Ford Prefect");
}

- (void)bundleDidUpdate:(NSNotification *)notification
{
    [self setStrings];
}

@end
