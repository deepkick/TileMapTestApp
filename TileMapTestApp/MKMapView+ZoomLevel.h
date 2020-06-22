//
//  MKMapView+ZoomLevel.h
//  GSI_Maps
//
//  Created by Kaoru Honda on 2014/08/26.
//  Copyright (c) 2014 Kaoru Honda. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Common_header.h"

@class DKCrossCenterView;
@interface MKMapView (ZoomLevel)

//@property (assign, nonatomic) CLLocationCoordinate2D    nwCoord;
//@property (assign, nonatomic) CLLocationCoordinate2D    swCoord;
//@property (assign, nonatomic) CLLocationCoordinate2D    seCoord;
//@property (assign, nonatomic) CLLocationCoordinate2D    neCoord;

//@property (strong, nonatomic) NSString     *currentLocalMapFile;

//@property (strong, nonatomic) DKCrossCenterView         *crossCenterView;


//- (void)checkMapZoomLevel;

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSInteger)zoomLevel
                   animated:(BOOL)animated;

- (NSInteger)zoomScaleToZoomLevel:(MKZoomScale)scale;
- (MKZoomScale)zoomLevelToZoomScale:(NSInteger)level;
- (NSInteger)getZoomLevel;
- (MKZoomScale)getZoomScale;
- (double)getSouthWestSouthEastDistance; //返り値の単位はメートル
- (double)getDistancePerOnePixel; //1pixelあたりの地図上の距離。単位はメートル
- (CLLocationCoordinate2D *)getPolygonCoords:(CGRect)targetRect;

- (CLLocationCoordinate2D *)getPolygonCoordsMapData:(NSString *)path;

- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level;
- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;

- (NSInteger)tilesCountInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level;
- (NSInteger)tilesCountInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;

- (NSArray *)meshTilesInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level;
- (NSArray *)meshTilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale;

- (BOOL)checkMapRect:(MKMapRect)rect ContainsPoint:(MKMapPoint)point;
- (BOOL)checkJAPANMapRectContainsCoord:(CLLocationCoordinate2D)coord;
- (BOOL)checkJAPANContainsMapRect:(MKMapRect)rect;

- (void)getAltitudeFromGlobalCashMeshData:(CLLocationCoordinate2D)coord;

- (NSArray *)geoJSONEmergencySheltersInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level;

#pragma mark Map conversion methods
- (double)longitudeToPixelSpaceX:(double)longitude;
- (double)latitudeToPixelSpaceY:(double)latitude;
- (double)pixelSpaceXToLongitude:(double)pixelX;
- (double)pixelSpaceYToLatitude:(double)pixelY;

//------------------------------------------------------------------------------
//  2点の経緯度から距離を求める[km]
//------------------------------------------------------------------------------
+ (double)calcDistanceWithCoordinate:(CLLocationCoordinate2D)begin end:(CLLocationCoordinate2D)end;

//------------------------------------------------------------------------------
//  2点のCLLocationから速度とhorizontalAccuracyをもとめてしきい値と比較し、validチェック
//------------------------------------------------------------------------------
+ (BOOL)validCheckCLLocation:(CLLocation *)begin end:(CLLocation *)end;

+ (UIImage *)capturedImageWithView:(UIView *)aView;

@end
