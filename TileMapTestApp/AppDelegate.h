//
//  AppDelegate.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//


#import "Common_header.h"

//#import <UIKit/UIKit.h>
//#import <Foundation/Foundation.h>
//#import <CoreLocation/CoreLocation.h>
//#import <MapKit/MapKit.h>
//
//#import "DKMapViewController.h"
//#import "Global.h"
//#import "AppDelegate.h"

@class DKMapViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow                  *window;

@property (assign, nonatomic) CLLocationCoordinate2D    WHOLE_OF_JAPAN_NW;
@property (assign, nonatomic) CLLocationCoordinate2D    WHOLE_OF_JAPAN_SE;

@property (assign, nonatomic) CGFloat                   WHOLE_OF_JAPAN_West_lon;
@property (assign, nonatomic) CGFloat                   WHOLE_OF_JAPAN_East_lon;
@property (assign, nonatomic) CGFloat                   WHOLE_OF_JAPAN_North_lat;
@property (assign, nonatomic) CGFloat                   WHOLE_OF_JAPAN_South_lat;

@property (strong, nonatomic) DKMapViewController               *dkMapViewController;


@end

