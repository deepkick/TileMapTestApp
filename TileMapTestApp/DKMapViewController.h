//
//  DKMapViewController.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "Common_header.h"

NS_ASSUME_NONNULL_BEGIN

@class AppDelegate, DKTileOverlay, DKTileOverlayRenderer;

@interface DKMapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate> {
    
}

@property (strong, nonatomic) AppDelegate                   *appDelegate;

@property (strong, nonatomic) MKMapView                         *map;
@property (assign, nonatomic) CGFloat                           map_visibleRect_padding_left;
@property (assign, nonatomic) CGFloat                           map_visibleRect_padding_top;

@property (strong, nonatomic) MKPolygon                         *mapBackgroundPolygon;
@property (strong, nonatomic) MKPolygon                         *dkStdMarker;
@property (strong, nonatomic) MKPolygonRenderer                *dkStdMarkerRenderer;
@property (strong, nonatomic) MKPolygon                         *dkSubAlphaMarker;
@property (strong, nonatomic) MKPolygonRenderer                *dkSubAlphaMarkerRenderer;

@property (strong, nonatomic) DKTileOverlay                     *dkTileOverlay;
@property (strong, nonatomic) DKTileOverlayRenderer             *dkTileOverlayRenderer;

//- (CLLocationCoordinate2D *)getPolygonCoords:(CGRect)targetRect;

@end

NS_ASSUME_NONNULL_END
