//
//  Global.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Global.h"
#import "AppDelegate.h"
#import "DKMapViewController.h"



@implementation Global


#pragma mark - LocalMapInfo Methods
+ (NSDictionary *)getLocalMapInfoDic:(NSString *)path {
    //LOG_CURRENT_METHOD;
    //LOG(@"path = %@", path);
    
    if (path == nil) {
        return nil;
    }
    
    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
        return nil;
    }
    
    NSError *error;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:0 error:&error];
    NSDictionary *localMapDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    //LOG(@"localMapDic = %@", [localMapDic description]);
    return localMapDic;
}

@end
