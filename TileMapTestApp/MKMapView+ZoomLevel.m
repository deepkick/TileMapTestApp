//
//  MKMapView+ZoomLevel.m
//  GSI_Maps
//
//  Created by Kaoru Honda on 2014/08/26.
//  Copyright (c) 2014 Kaoru Honda. All rights reserved.
//


#import "Common_header.h"

@implementation MKMapView (ZoomLevel)
    
#pragma mark - Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude {
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude {
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX {
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY {
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSInteger)zoomLevel
{
    //LOG_CURRENT_METHOD;
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = ZoomExponentConstant - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    //double zoomScale = [self zoomLevelToZoomScale:zoomLevel];
    
    //LOG(@"zoomLevel = %d", zoomLevel);
    //LOG(@"zoomScale = %f", zoomScale);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

- (NSInteger)getZoomLevel
{
    //LOG_CURRENT_METHOD;
    return [self zoomScaleToZoomLevel:[self getZoomScale]] + 1;
}

- (NSInteger)zoomScaleToZoomLevel:(MKZoomScale)scale {
    //LOG_CURRENT_METHOD;
    //LOG(@"scale = %f", scale);
    double numTilesAt1_0 = MKMapSizeWorld.width / GSI_MAPS_TILE_SIZE; // numTilesAt1_0 = 1048576
    NSInteger zoomLevelAt1_0 = log2(numTilesAt1_0);  // add 1 because the convention skips a virtual level with 1 tile.
    // zoomLevelAt1_0 = 20
    NSInteger zoomLevel = MAX(0, zoomLevelAt1_0 + floor(log2(scale) + 0.5));
    return zoomLevel;
}

- (MKZoomScale)zoomLevelToZoomScale:(NSInteger)level {
    //LOG_CURRENT_METHOD;
    MKZoomScale zoomScale = 0.0f;
    double numTilesAt1_0 = MKMapSizeWorld.width / GSI_MAPS_TILE_SIZE; // numTilesAt1_0 = 1048576
    NSInteger zoomLevelAt1_0 = log2(numTilesAt1_0);  // add 1 because the convention skips a virtual level with 1 tile.
    // zoomLevelAt1_0 = 20
    NSInteger i = zoomLevelAt1_0 - level;
    zoomScale = pow(0.5, i);
    return zoomScale;
}

- (MKZoomScale)getZoomScale {
    //LOG_CURRENT_METHOD;
    return self.bounds.size.width / self.visibleMapRect.size.width;
}

- (double)getSouthWestSouthEastDistance {
    //LOG_CURRENT_METHOD;
    CGPoint southWest = CGPointMake(self.bounds.origin.x
                                    ,self.bounds.origin.y + self.bounds.size.height);
    CLLocationCoordinate2D swCoord = [self convertPoint:southWest toCoordinateFromView:self];
    
    CGPoint southEast = CGPointMake(self.bounds.origin.x + self.bounds.size.width
                                    ,self.bounds.origin.y + self.bounds.size.height);
    CLLocationCoordinate2D seCoord = [self convertPoint:southEast toCoordinateFromView:self];
    
    CLLocation *fromlocation = [[CLLocation alloc] initWithLatitude:swCoord.latitude longitude:swCoord.longitude];
    CLLocation *tolocation = [[CLLocation alloc] initWithLatitude:seCoord.latitude longitude:seCoord.longitude];
    CLLocationDistance distance = [fromlocation distanceFromLocation:tolocation];
    return distance;
}

- (double)getDistancePerOnePixel {
    //LOG_CURRENT_METHOD;
    double distanceOfSWtoSE = [self getSouthWestSouthEastDistance];
    double dpp = distanceOfSWtoSE / self.bounds.size.width;
    
    //LOG(@"self.bounds = %@", NSStringFromCGRect(self.bounds));
    //LOG(@"[UIScreen mainScreen].bounds.size = %@", NSStringFromCGSize([UIScreen mainScreen].bounds.size));

    return dpp;
}

- (CLLocationCoordinate2D *)getPolygonCoords:(CGRect)targetRect {
    //LOG_CURRENT_METHOD;
    
    CGPoint northWest = CGPointMake(targetRect.origin.x
                                    ,targetRect.origin.y);
    CLLocationCoordinate2D nwCoord = [self convertPoint:northWest toCoordinateFromView:self];
    
    CGPoint southWest = CGPointMake(targetRect.origin.x
                                    ,targetRect.origin.y + targetRect.size.height);
    CLLocationCoordinate2D swCoord = [self convertPoint:southWest toCoordinateFromView:self];
    
    CGPoint southEast = CGPointMake(targetRect.origin.x + targetRect.size.width
                                    ,targetRect.origin.y + targetRect.size.height);
    CLLocationCoordinate2D seCoord = [self convertPoint:southEast toCoordinateFromView:self];
    
    CGPoint northEast = CGPointMake(targetRect.origin.x + targetRect.size.width
                                    ,targetRect.origin.y);
    CLLocationCoordinate2D neCoord = [self convertPoint:northEast toCoordinateFromView:self];
    
    CLLocationCoordinate2D *polygonCoords = malloc(sizeof(CLLocationCoordinate2D) * 4);
    polygonCoords[0] = nwCoord;
    polygonCoords[1] = swCoord;
    polygonCoords[2] = seCoord;
    polygonCoords[3] = neCoord;
    
//    LOG(@"nwCoord:lat = %f, lon = %f", polygonCoords[0].latitude, polygonCoords[0].longitude);
//    LOG(@"swCoord:lat = %f, lon = %f", polygonCoords[1].latitude, polygonCoords[1].longitude);
//    LOG(@"seCoord:lat = %f, lon = %f", polygonCoords[2].latitude, polygonCoords[2].longitude);
//    LOG(@"neCoord:lat = %f, lon = %f", polygonCoords[3].latitude, polygonCoords[3].longitude);
    
    return polygonCoords;
}

- (CLLocationCoordinate2D *)getPolygonCoordsMapData:(NSString *)path; {
    
    //LOG_CURRENT_METHOD;
    
    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {

        CLLocationCoordinate2D *polygonCoords = malloc(sizeof(CLLocationCoordinate2D) * 4);
        polygonCoords[0] = EmptyLocationCoordinate;
        polygonCoords[1] = EmptyLocationCoordinate;
        polygonCoords[2] = EmptyLocationCoordinate;
        polygonCoords[3] = EmptyLocationCoordinate;
        return polygonCoords;
    } else {
        NSDictionary *localMapDic = [Global getLocalMapInfoDic:path];
        NSArray *coordinates = [[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"coordinates"] objectAtIndex:0];
        
        CLLocationCoordinate2D nwCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:0] doubleValue]);
        CLLocationCoordinate2D swCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:1] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:1] objectAtIndex:0] doubleValue]);
        CLLocationCoordinate2D seCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:0] doubleValue]);
        CLLocationCoordinate2D neCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:3] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:3] objectAtIndex:0] doubleValue]);
        
        CLLocationCoordinate2D *polygonCoords = malloc(sizeof(CLLocationCoordinate2D) * 4);
        polygonCoords[0] = nwCoord;
        polygonCoords[1] = swCoord;
        polygonCoords[2] = seCoord;
        polygonCoords[3] = neCoord;
        return polygonCoords;
    }
}

- (CLLocationCoordinate2D *)getPolygonCoordsKMZData:(NSString *)path; {
    //LOG_CURRENT_METHOD;
    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
        
        CLLocationCoordinate2D *polygonCoords = malloc(sizeof(CLLocationCoordinate2D) * 4);
        polygonCoords[0] = EmptyLocationCoordinate;
        polygonCoords[1] = EmptyLocationCoordinate;
        polygonCoords[2] = EmptyLocationCoordinate;
        polygonCoords[3] = EmptyLocationCoordinate;
        return polygonCoords;
    } else {
        NSDictionary *localMapDic = [Global getLocalMapInfoDic:path];
        NSArray *coordinates = [[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"coordinates"] objectAtIndex:0];
        
        CLLocationCoordinate2D nwCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:0] doubleValue]);
        CLLocationCoordinate2D swCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:1] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:1] objectAtIndex:0] doubleValue]);
        CLLocationCoordinate2D seCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:0] doubleValue]);
        CLLocationCoordinate2D neCoord = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:3] objectAtIndex:1] doubleValue],
                                                                    [(NSString *)[[coordinates objectAtIndex:3] objectAtIndex:0] doubleValue]);
        
        CLLocationCoordinate2D *polygonCoords = malloc(sizeof(CLLocationCoordinate2D) * 4);
        polygonCoords[0] = nwCoord;
        polygonCoords[1] = swCoord;
        polygonCoords[2] = seCoord;
        polygonCoords[3] = neCoord;
        return polygonCoords;
    }
}

@end
