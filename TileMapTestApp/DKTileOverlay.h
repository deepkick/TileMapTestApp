//
//  DKTileOverlay.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "Common_header.h"
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class AppDelegate;
@interface DKTileOverlay : MKTileOverlay {
    MKMapRect                   boundingMapRect;
    CLLocationCoordinate2D      coordinate;
}

//@property (assign, nonatomic) kMapType      mapType;
@property (assign, nonatomic) NSInteger     zoomLevel;
@property (strong, nonatomic) AppDelegate   *appDelegate;

- (id)initOverlay;
//- (BOOL)canReplaceMapContent;

@end

NS_ASSUME_NONNULL_END
