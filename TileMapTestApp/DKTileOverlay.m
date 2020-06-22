//
//  DKTileOverlay.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "DKTileOverlay.h"

@implementation DKTileOverlay

- (id)initOverlay
{
    //LOG_CURRENT_METHOD;
    if (self = [super init]) {
        //boundingMapRect = MKMapRectMake(-180, -90, MKMapSizeWorld.width, MKMapSizeWorld.height);
        
        //LOG(@"******** boundingMapRect WHOLE_OF_JAPAN ********");
        boundingMapRect = MKMapRectMake(WHOLE_OF_JAPAN_MKMapRect_X,
                                        WHOLE_OF_JAPAN_MKMapRect_Y,
                                        WHOLE_OF_JAPAN_MKMapRect_W,
                                        WHOLE_OF_JAPAN_MKMapRect_H);
        
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //self.mapType = self.appDelegate.currentMapType;
        self.tileSize = CGSizeMake(GSI_MAPS_TILE_SIZE * pow(2, GSI_MAPS_TILE_SIZE_Power), GSI_MAPS_TILE_SIZE * pow(2, GSI_MAPS_TILE_SIZE_Power));
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    //LOG_CURRENT_METHOD;
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(boundingMapRect),
                                                  MKMapRectGetMidY(boundingMapRect)));
}

#pragma mark - MKTileOverlay implementation
//- (MKMapRect)boundingMapRect
//{
//    //LOG_CURRENT_METHOD;
//    //LOG(@"boundingMapRect.origin.x = %f / boundingMapRect.origin.y = %f", boundingMapRect.origin.x, boundingMapRect.origin.y);
//    //boundingMapRect.origin.x = -180.000000 / boundingMapRect.origin.y = -90.000000
//    //LOG(@"boundingMapRect.size.w = %f / boundingMapRect.size.h = %f", boundingMapRect.size.width, boundingMapRect.size.height);
//    //boundingMapRect.size.w = 268435456.000000 / boundingMapRect.size.h = 268435456.000000
//    return boundingMapRect;
//}

#pragma mark - MKOverlay Protocol
//- (BOOL)canReplaceMapContent
//{
//    LOG_CURRENT_METHOD;
//    LOG(@"bbbb - coordinate.latitude = %f / coordinate.longitude = %f", coordinate.latitude, coordinate.longitude);
//    // return NO; だと、MapView が表示される
//    // return YES; だと、MapView が表示されない。（画像が取得できない場合、グレー表示）
//    // 2016.05.07 return NO でAppleMap表示にすると、負荷がかかることが判明。GSI表示時は、AppleMap表示をオフにするために return YESに変更。
//    return YES;
//    //return !self.appDelegate.mapViewDisplayed;
//}

@end
