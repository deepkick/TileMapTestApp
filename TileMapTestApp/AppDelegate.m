//
//  AppDelegate.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LOG_CURRENT_METHOD;
    
    CGRect frameForWindow = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frameForWindow];
    
    self.dkMapViewController = [[DKMapViewController alloc] init];
    self.window.rootViewController = self.dkMapViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    LOG_CURRENT_METHOD;
}

@end
