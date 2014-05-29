//
//  MMAppDelegate.m
//  PowerPointThumb
//
//  Created by Adam Wulf on 5/28/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMAppDelegate.h"

@implementation MMAppDelegate

@synthesize window;
@synthesize viewController;

// launch app and handle url if needed
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MMViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(url){
        [viewController generateThumbnailsForFile:url];
    }
    return YES;
}


// handle URL when app is already running
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    if (url != nil && [url isFileURL]) {
        [viewController generateThumbnailsForFile:url];
    }
    return YES;
}


@end
