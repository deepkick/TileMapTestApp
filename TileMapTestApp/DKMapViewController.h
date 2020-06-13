//
//  DKMapViewController.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AppDelegate;

@interface DKMapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate> {
    
}

@property (strong, nonatomic) AppDelegate                   *appDelegate;

@property (strong, nonatomic) MKMapView                         *map;
@property (assign, nonatomic) CGFloat                           map_visibleRect_padding_left;
@property (assign, nonatomic) CGFloat                           map_visibleRect_padding_top;

@end

NS_ASSUME_NONNULL_END
