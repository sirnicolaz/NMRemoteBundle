//
//  NSBundle+Remote.m
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/22/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//


#import "NSBundle+Remote.h"
#import <objc/runtime.h>
#import "SSZipArchive.h"

static NSOperationQueue *myQueue;

/* User defaults keys */
#define kNMDefaultRemoteBundleId    @"kNMDefaultRemoteBundleId"

/* Info.plist custom keys */
#define kNMInfoPlistRefreshRateKey  @"NMBundleRefreshRate"
#define kNMInfoPlistLastUpdated     @"NMBundleLastUpdated"
#define kNMInfoPlistRemoteURLString @"NMBundleRemoteURLString"

/* Strings */
static NSString *NMDateFormat = @"yyyy-MM-dd";
static NSString *NMInfoPlistRelativePath = @"Resources/Info.plist";

@interface NSBundle (Remote_Private)

@property (nonatomic, strong) NSDate      *lastUpdated;
@property (nonatomic, strong) NSNumber   *isUpdating;

- (void)storePlistValue:(NSString *)value
                 forKey:(NSString *)key;
@end


@implementation NSBundle (Remote)

@dynamic refreshRate;
@dynamic remoteURL;

// Bundles need to be loaded (and cached) in order to be retrievable efficiently (and effectively)
// by bundleWithIdentifier
+ (void)initialize
{
    CFURLRef rootURL;
    CFArrayRef bundleArray;
    
    NSURL *docsURL = [NSURL fileURLWithPath:[NSBundle documentsDirectory] isDirectory:YES];
    rootURL = (__bridge CFURLRef)(docsURL);
    
    // Get the bundle objects.
    bundleArray = CFBundleCreateBundlesFromDirectory(kCFAllocatorDefault,
                                                     rootURL, NULL);
    CFRelease(bundleArray);
}

#pragma mark - Accessors

+ (id)mainRemoteBundle
{
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kNMDefaultRemoteBundleId];
    
    if (!identifier.length) {
        return nil;
    }
    
    NSBundle *remoteBundle = [NSBundle bundleWithIdentifier:identifier];
    
    @synchronized(self){
        if ([remoteBundle needsUpdate]) {
            [remoteBundle refresh];
        }
    }

    return remoteBundle;
}

+ (void)setMainRemoteBundle:(NSBundle *)bundle
{
    [[NSUserDefaults standardUserDefaults] setObject:bundle.bundleIdentifier forKey:kNMDefaultRemoteBundleId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)refreshRate
{
    NSString *infoPlist = [self pathForResource: @"Info" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:infoPlist];
    NSString *refRateStr = [dict objectForKey:kNMInfoPlistRefreshRateKey];
    NSInteger refreshRate = refRateStr ? [refRateStr intValue] : 1;
    return refreshRate;
}

- (NSURL *)remoteURL
{
    NSString *infoPlist = [self pathForResource: @"Info" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:infoPlist];
    return [NSURL URLWithString:[dict objectForKey:kNMInfoPlistRemoteURLString]];
}

- (void)setRemoteURL:(NSURL *)remoteURL
{
    [self storePlistValue:remoteURL.absoluteString forKey:kNMInfoPlistRemoteURLString];
}

#pragma mark - Utility

+ (NSString *)documentsDirectory
{
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    return documentsDirectory;
}

+ (BOOL)saveData:(NSData *)data
          atPath:(NSString *)path
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *zipPath = [self.documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp", path.lastPathComponent]];
    
    BOOL didWriteData = [data writeToFile:zipPath atomically:YES];
    if (didWriteData) {
        [fileMgr removeItemAtPath:path error:nil];
        BOOL success = [SSZipArchive unzipFileAtPath:zipPath toDestination:path];
        [fileMgr removeItemAtPath:zipPath error:nil];
        
        if (!success) {
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)needsUpdate
{
    NSDateComponents* deltaComps = [[NSDateComponents alloc] init];
    [deltaComps setDay:self.refreshRate];
    
    NSDate *lastUpdate = self.lastUpdated;
    
    NSDate* nextRefresh = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps
                                                                        toDate:lastUpdate
                                                                       options:0];
    
    return ([nextRefresh compare:[NSDate date]] == NSOrderedAscending ||
            [nextRefresh compare:[NSDate date]] == NSOrderedSame) &&
            !self.isUpdating;
}

- (void)refresh
{
    
    self.isUpdating = [NSNumber numberWithBool:YES];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myQueue = [[NSOperationQueue alloc] init];
        myQueue.name = @"Download Queue";
    });
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.remoteURL];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:myQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               
                               if (!error) {
                                   if ([httpResponse statusCode] == 404) {
                                       [[NSFileManager defaultManager] removeItemAtPath:self.bundlePath error:nil];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:NMRemoteBundleDidUpdateNotification
                                                                                           object:nil];
                                   }
                                   else if([NSBundle saveData:data atPath:self.bundlePath]) {
                                       self.lastUpdated = [NSDate date];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:NMRemoteBundleDidUpdateNotification
                                                                                           object:nil];
                                   }
                               }
                               
                               @synchronized(self){
                                   self.isUpdating = [NSNumber numberWithBool:NO];
                               }
                           }
     ];

}

#pragma mark - Iinitializer

- (id)initWithRemoteURL:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *name = [NSString stringWithFormat:@"%@.bundle", httpResponse.suggestedFilename];
    NSString *path = [[NSBundle documentsDirectory] stringByAppendingPathComponent:name];
    
    if ([httpResponse statusCode] == 404) {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:path error:nil];
        return nil;
    }
    else if (error) {
        return nil;
    }
    
    [NSBundle saveData:data atPath:path];
    self = [self initWithPath:path];
    
    if (self) {
        // Custom stuff
        self.isUpdating = [NSNumber numberWithBool:NO];
        self.lastUpdated = [NSDate date];
        self.remoteURL = url;
    }
    
    return self;
}

+ (void)createWithRemoteURL:(NSURL *)url  // Asynchronous
            completionBlock:(CompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSBundle *remoteBundle = [[NSBundle alloc] initWithRemoteURL:url];
        block(remoteBundle);
    });
}

@end

#pragma mark -
#pragma mark - Private


@implementation NSBundle (Remote_Private)

@dynamic lastUpdated;
@dynamic isUpdating;

- (void)storePlistValue:(NSString *)value
                 forKey:(NSString *)key
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *plistPath;
    if ((plistPath = [self.bundlePath stringByAppendingPathComponent:NMInfoPlistRelativePath])) {
        if ([manager isWritableFileAtPath:plistPath]) {
            NSMutableDictionary* infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            [infoDict setObject:value forKey:key];
            [infoDict writeToFile:plistPath atomically:NO];
            [manager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date]
                                                               forKey:NSFileModificationDate]
                      ofItemAtPath:self.bundlePath
                             error:nil];
        }
    }
}

- (void)setLastUpdated:(NSDate *)lastUpdated
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:NMDateFormat];
    NSString *lastUpdatedString = [df stringFromDate:lastUpdated];
    
    [self storePlistValue:lastUpdatedString forKey:kNMInfoPlistLastUpdated];
}

- (NSDate *)lastUpdated
{
    NSString *infoPlist = [self pathForResource: @"Info" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:infoPlist];
    NSString *lastUpdatedStr = [dict objectForKey:kNMInfoPlistLastUpdated];
    if (lastUpdatedStr) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:NMDateFormat];
        return [df dateFromString:lastUpdatedStr];
    }
    
    return nil;
}

- (void)setIsUpdating:(NSNumber *)isUpdating
{
    [self willChangeValueForKey:@"isUpdating"];
    objc_setAssociatedObject(self, "isUpdating", isUpdating, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"isUpdating"];
}

- (NSNumber *)isUpdating
{
    return objc_getAssociatedObject(self, @"isUpdating");
}

@end

