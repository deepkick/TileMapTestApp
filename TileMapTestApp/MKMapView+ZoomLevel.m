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

#pragma mark -
#pragma mark Public methods

//- (void)checkMapZoomLevel {
//    //LOG_CURRENT_METHOD;
//    CGFloat zoomLevel = [self getZoomLevel];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    //LOG(@"zoomLevel = %f / currentMaxZoomLevel = %d", zoomLevel, appDelegate.currentMaxZoomLevel);
//    
//    if (zoomLevel > appDelegate.currentMaxZoomLevel) {
//        //LOG(@"ズーム縮小！！！！");
//        [self setCenterCoordinate:self.centerCoordinate
//                            zoomLevel:appDelegate.currentMaxZoomLevel
//                             animated:NO];
//    }
//}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSInteger)zoomLevel
                   animated:(BOOL)animated
{
    LOG_CURRENT_METHOD;
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    LOG(@"zoomLevel = %ld", (long)zoomLevel);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    //LOG(@"span.latitudeDelta = %f / span.longitudeDelta = %f", span.latitudeDelta, span.longitudeDelta);
    
//    MKCoordinateSpan span = MKCoordinateSpanMake(180 / pow(2, zoomLevel) * self.frame.size.height / 256, 0);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    LOG(@"region.center.latitude = %f / region.center.longitude = %f", region.center.latitude, region.center.longitude);
    LOG(@"region.span.latitudeDelta = %f / region.span.longitudeDelta = %f", region.span.latitudeDelta, region.span.longitudeDelta);
    
    // set the region like normal
    //[self setRegion:region animated:animated];
    [self setRegion:region animated:NO];
}

//Return an array of DKImageTile objects for the given MKMapRect and MKZoomScale
- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale
{
    LOG_CURRENT_METHOD;
    
    //// Convert an MKZoomScale to a zoom level where level 0 contains 4 256px square tiles
    NSInteger z = [self zoomScaleToZoomLevel:scale];
    
    LOG(@"level = %ld", z);
    LOG(@"scale = %f", scale);
    LOG(@"rect.origin.x = %f / rect.origin.y = %f", rect.origin.x, rect.origin.y);
    LOG(@"rect.size.w = %f / rect.size.h = %f", rect.size.width, rect.size.height);
    
    //rect.origin.x = 239075328.000000 / rect.origin.y = 106954752.000000
    //rect.size.w = 1048576.000000 / rect.size.h = 1048576.000000
    
    //LOG(@"MKMapRectGetMinX(rect) = %f", MKMapRectGetMinX(rect));
    //LOG(@"MKMapRectGetMaxX(rect) = %f", MKMapRectGetMaxX(rect));
    //LOG(@"MKMapRectGetMinY(rect) = %f", MKMapRectGetMinY(rect));
    //LOG(@"MKMapRectGetMaxY(rect) = %f", MKMapRectGetMaxY(rect));
    
    NSInteger minX = floor((MKMapRectGetMinX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger maxX = floor((MKMapRectGetMaxX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger minY = floor((MKMapRectGetMinY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger maxY = floor((MKMapRectGetMaxY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    
        //LOG(@"MKMapRectGetMinX(rect) * scale = %f", MKMapRectGetMinX(rect) * scale);
        //LOG(@"MKMapRectGetMaxX(rect) * scale = %f", MKMapRectGetMaxX(rect) * scale);
        //LOG(@"MKMapRectGetMinY(rect) * scale = %f", MKMapRectGetMinY(rect) * scale);
        //LOG(@"MKMapRectGetMaxY(rect) * scale = %f", MKMapRectGetMaxY(rect) * scale);
    
    //LOG(@"minX = %ld / maxX = %ld / minY = %ld / maxY = %ld", minX, maxX, minY, (long)maxY );
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *localImagePath = appDelegate.dkMapViewController.currentLocalImagesPath;
    
    NSMutableArray *tiles = [NSMutableArray new];
    NSString *mapType;
    NSInteger minZ = MinZoomLevel;
    NSInteger maxZ = MaxZoomLevel;
    
    mapType = String_MapType_pale;
    minZ = MinZoomLevel_pale;
    maxZ = MaxZoomLevel_pale;
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            
            NSString *extension = PNG_Extension;
            if ([mapType compare:String_MapType_ort] == NSOrderedSame) {
                extension = JPG_Extension;
            }
            
            NSString *tileURL = [[NSString alloc] initWithFormat:@"%@%@/%ld/%ld/%ld%@", CGSI_MAPS_BASE_URL, mapType, (long)z, (long)x, (long)y, extension];
            NSString *globalCashPath = [Global globalCashPathForURLinDocuments:tileURL];
            NSString *localTilePath;
            if (localImagePath == nil) {
                localTilePath = nil;
            } else {
                localTilePath = [Global localMapTilePathForURLinDocuments:tileURL];
            }
            
            MKMapRect frame = MKMapRectMake((double)(x * GSI_MAPS_TILE_SIZE) / scale,
                                            (double)(y * GSI_MAPS_TILE_SIZE) / scale,
                                            GSI_MAPS_TILE_SIZE / scale,
                                            GSI_MAPS_TILE_SIZE / scale);
            DKImageTile *tile = [[DKImageTile alloc] initWithFrame:frame tileURL:tileURL globalCashPath:globalCashPath localTilePath:localTilePath];
            [tiles addObject:tile];
            
            //LOG(@"x = %ld, y = %ld", (long)x, (long)y);
            //LOG(@"tileURL = %@", tileURL);
            //LOG(@"globalCashPath = %@", globalCashPath);
            //LOG(@"localTilePath = %@", localTilePath);
            //NSStringFromMKMapRect(frame);
        }
    }
    //LOG(@"tiles = %ld", tiles.count);
    //LOG(@"tiles = %@", [tiles description]);
    
    return tiles;
}


- (NSArray *)tilesInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level
{
    //LOG_CURRENT_METHOD;
    MKZoomScale scale = [self zoomLevelToZoomScale:level];
    
    //LOG(@"level = %ld", level);
    //LOG(@"scale = %f", scale);
    //LOG(@"rect.origin.x = %f / rect.origin.y = %f", rect.origin.x, rect.origin.y);
    //LOG(@"rect.size.w = %f / rect.size.h = %f", rect.size.width, rect.size.height);
    
    NSArray *tiles = [self tilesInMapRect:rect zoomScale:scale];
    return tiles;
}

- (NSInteger)tilesCountInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale {
    //LOG_CURRENT_METHOD;
    //NSInteger z = [self zoomScaleToZoomLevel:scale];
    NSInteger counter = 0;

    NSInteger minX = floor((MKMapRectGetMinX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger maxX = floor((MKMapRectGetMaxX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger minY = floor((MKMapRectGetMinY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger maxY = floor((MKMapRectGetMaxY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            counter++;
        }
    }
    
    return counter;
}

- (NSInteger)tilesCountInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level {
    //LOG_CURRENT_METHOD;
    MKZoomScale scale = [self zoomLevelToZoomScale:level];
    return [self tilesCountInMapRect:rect zoomScale:scale];
}

//Return an array of meshTile objects for the given MKMapRect and MKZoomScale
- (NSArray *)meshTilesInMapRect:(MKMapRect)rect zoomScale:(MKZoomScale)scale
{
    LOG_CURRENT_METHOD;
    
    //// Convert an MKZoomScale to a zoom level where level 0 contains 4 256px square tiles
    NSInteger z = [self zoomScaleToZoomLevel:scale];
    
    //LOG(@"level = %ld", z);
    //LOG(@"scale = %f", scale);
    //LOG(@"rect.origin.x = %f / rect.origin.y = %f", rect.origin.x, rect.origin.y);
    //LOG(@"rect.size.w = %f / rect.size.h = %f", rect.size.width, rect.size.height);
    
    //rect.origin.x = 239075328.000000 / rect.origin.y = 106954752.000000
    //rect.size.w = 1048576.000000 / rect.size.h = 1048576.000000
    
    //LOG(@"MKMapRectGetMinX(rect) = %f", MKMapRectGetMinX(rect));
    //LOG(@"MKMapRectGetMaxX(rect) = %f", MKMapRectGetMaxX(rect));
    //LOG(@"MKMapRectGetMinY(rect) = %f", MKMapRectGetMinY(rect));
    //LOG(@"MKMapRectGetMaxY(rect) = %f", MKMapRectGetMaxY(rect));
    
    NSInteger minX = floor((MKMapRectGetMinX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger maxX = floor((MKMapRectGetMaxX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger minY = floor((MKMapRectGetMinY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger maxY = floor((MKMapRectGetMaxY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    
    //LOG(@"MKMapRectGetMinX(rect) * scale = %f", MKMapRectGetMinX(rect) * scale);
    //LOG(@"MKMapRectGetMaxX(rect) * scale = %f", MKMapRectGetMaxX(rect) * scale);
    //LOG(@"MKMapRectGetMinY(rect) * scale = %f", MKMapRectGetMinY(rect) * scale);
    //LOG(@"MKMapRectGetMaxY(rect) * scale = %f", MKMapRectGetMaxY(rect) * scale);
    
    //LOG(@"minX = %ld / maxX = %ld / minY = %ld / maxY = %ld", minX, maxX, minY, (long)maxY );
    
    
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSString *localImagePath = appDelegate.menuViewController.dkMapViewController.currentLocalImagesPath;
    
    NSMutableArray *meshTiles = nil;
    NSString *map = @"dem";
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            
            NSString *meshTileURL = [[NSString alloc] initWithFormat:@"%@%@/%ld/%ld/%ld%@", CGSI_MAPS_BASE_URL, map, (long)z, (long)x, (long)y, Text_Extension];
            NSString *globalCashMeshPath = [Global meshPathForURLinDocuments:meshTileURL];
            
            if (!meshTiles) {
                meshTiles = [NSMutableArray array];
            }
            
            MKMapRect frame = MKMapRectMake((double)(x * GSI_MAPS_TILE_SIZE) / scale,
                                            (double)(y * GSI_MAPS_TILE_SIZE) / scale,
                                            GSI_MAPS_TILE_SIZE / scale,
                                            GSI_MAPS_TILE_SIZE / scale);
            
            DKMeshTile *tile = [[DKMeshTile alloc] initWithFrame:frame
                                                     meshTileURL:meshTileURL
                                              globalCashMeshPath:globalCashMeshPath];
                                               //localMeshTilePath:localMethTilePath];
            [meshTiles addObject:tile];
            
            //LOG(@"x = %ld, y = %ld", (long)x, (long)y);
            //LOG(@"meshTileURL = %@", meshTileURL);
            //LOG(@"globalCashMeshPath = %@", globalCashMeshPath);
            //LOG(@"localMethTilePath = %@", localMethTilePath);
            //NSStringFromMKMapRect(frame);
        }
    }
    
    //LOG(@"meshTiles.count = %ld", meshTiles.count);
    //LOG(@"meshTiles = %@", [meshTiles description]);
    
    return meshTiles;
}


- (NSArray *)meshTilesInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level
{
    LOG_CURRENT_METHOD;
    MKZoomScale scale = [self zoomLevelToZoomScale:level];
    
    //LOG(@"level = %ld", level);
    //LOG(@"scale = %f", scale);
    //LOG(@"rect.origin.x = %f / rect.origin.y = %f", rect.origin.x, rect.origin.y);
    //LOG(@"rect.size.w = %f / rect.size.h = %f", rect.size.width, rect.size.height);
    
    NSArray *tiles = [self meshTilesInMapRect:rect zoomScale:scale];
    return tiles;
}

+ (double)calcDistanceWithCoordinate:(CLLocationCoordinate2D)begin end:(CLLocationCoordinate2D)end {
    /*
     ヒュベニの距離計算式
     D=sqt((M*dP)^2+(N*cos(P)*dR)^2)
     D: ２点間の距離（弧）(m)
     P: ２点の平均緯度P[ラジアン]=(P1+P2)/2
     dP: ２点の緯度差dP[ラジアン]=P1-P2
     dR: ２点の経度差dR[ラジアン]=R1-R2
     M: 子午線曲率半径 M=6334834/sqrt((1-0.006674*sin(P)^2)^3)
     N: 卯酉線曲率半径 N=6377397/sqrt(1-0.006674*sin(P)^2)
     */
    
    const float   P = ( begin.latitude+end.latitude ) / 2 * MAP_DATA_PI / 180;
    const float   dP = ( begin.latitude-end.latitude ) * MAP_DATA_PI / 180;
    const float  dR = ( begin.longitude-end.longitude ) * MAP_DATA_PI / 180;
    const float   M = 6334834 / sqrt( ( 1-0.006674 * sin( P ) * sin( P ) ) * ( 1-0.006674 * sin( P ) * sin( P ) ) * ( 1-0.006674 * sin( P ) * sin( P ) ) );
    const float   N = 6377397 / sqrt( 1-0.006674 * sin( P ) * sin( P ) );
    double    D = sqrt( ( M * dP ) * ( M * dP ) + ( N * cos( P ) * dR ) * ( N * cos( P ) * dR ) ) / 1000;
    return D;
}

+ (BOOL)validCheckCLLocation:(CLLocation *)begin end:(CLLocation *)end {
    //LOG_CURRENT_METHOD;
    // 水平方向の精度
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //LOG(@"end = %@", end); //<+35.26229100,+135.90022300> +/- 5.00m (speed -1.00 mps / course -1.00) @ 2016/06/10 12時16分19秒 日本標準時
    
    if ((appDelegate.locationManager.desiredAccuracy == kCLLocationAccuracyBestForNavigation) ||
        (appDelegate.locationManager.desiredAccuracy == kCLLocationAccuracyBest) ||
        (appDelegate.locationManager.desiredAccuracy == kCLLocationAccuracyNearestTenMeters)) {
        if (end.horizontalAccuracy > GPS_horizontalAccuracy_threshold_30) {
            appDelegate.currentGPSAccuracy = invalid;
            return NO;
        }
    } else {
        if (end.horizontalAccuracy > GPS_horizontalAccuracy_threshold_100) {
            appDelegate.currentGPSAccuracy = invalid;
            return NO;
        }
    }
    
//    if (end.horizontalAccuracy > appDelegate.currentDistanceFilter) {
//        appDelegate.currentGPSAccuracy = invalid;
//        return NO;
//    }
    
    // ポイント間の速度
    double distance2points = [MKMapView calcDistanceWithCoordinate:end.coordinate
                                                               end:begin.coordinate] * 1000;
    float interval = [end.timestamp timeIntervalSinceDate:begin.timestamp];
    double speed = ((distance2points / 1000) / interval) * 60 * 60;
    
    if (appDelegate.currentGPSActivityType == CLActivityTypeFitness) {
        if (speed < GPS_SPEED_threshold_ActivityTypeFitness) {
            appDelegate.currentGPSAccuracy = valid;
            return YES;
        }
    } else if (appDelegate.currentGPSActivityType == CLActivityTypeAutomotiveNavigation) {
        if (speed < GPS_SPEED_threshold_ActivityTypeAutomotiveNavigation) {
            appDelegate.currentGPSAccuracy = valid;
            return YES;
        }
    } else {
        if (speed < GPS_SPEED_threshold_ActivityTypeOtherNavigation) {
            appDelegate.currentGPSAccuracy = valid;
            return YES;
        }
    }
    
    appDelegate.currentGPSAccuracy = invalid;
    return NO;
}

- (BOOL)checkMapRect:(MKMapRect)rect ContainsPoint:(MKMapPoint)point {
    if (MKMapRectContainsPoint(rect, point)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)checkJAPANMapRectContainsCoord:(CLLocationCoordinate2D)coord {
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    MKMapRect WHOLE_OF_JAPAN_MapRect = MKMapRectMake(WHOLE_OF_JAPAN_MKMapRect_X,
                                                     WHOLE_OF_JAPAN_MKMapRect_Y,
                                                     WHOLE_OF_JAPAN_MKMapRect_W,
                                                     WHOLE_OF_JAPAN_MKMapRect_H);
    return [self checkMapRect:WHOLE_OF_JAPAN_MapRect ContainsPoint:mapPoint];
}

- (BOOL)checkJAPANContainsMapRect:(MKMapRect)rect {
    MKMapRect WHOLE_OF_JAPAN_MapRect = MKMapRectMake(WHOLE_OF_JAPAN_MKMapRect_X,
                                                     WHOLE_OF_JAPAN_MKMapRect_Y,
                                                     WHOLE_OF_JAPAN_MKMapRect_W,
                                                     WHOLE_OF_JAPAN_MKMapRect_H);
    
    NSInteger minX = rect.origin.x;
    NSInteger minY = rect.origin.y;
    NSInteger maxX = rect.origin.x + rect.size.width;
    NSInteger maxY = rect.origin.y + rect.size.height;
    
    MKMapPoint NW = MKMapPointMake(minX, minY);
    MKMapPoint SW = MKMapPointMake(minX, maxY);
    MKMapPoint NE = MKMapPointMake(maxX, minY);
    MKMapPoint SE = MKMapPointMake(maxX, maxY);
    
    if (![self checkMapRect:WHOLE_OF_JAPAN_MapRect ContainsPoint:NW]) {
        return NO;
    }
    if (![self checkMapRect:WHOLE_OF_JAPAN_MapRect ContainsPoint:SW]) {
        return NO;
    }
    if (![self checkMapRect:WHOLE_OF_JAPAN_MapRect ContainsPoint:NE]) {
        return NO;
    }
    if (![self checkMapRect:WHOLE_OF_JAPAN_MapRect ContainsPoint:SE]) {
        return NO;
    }
    
    return YES;
}

- (void)getAltitudeFromGlobalCashMeshData:(CLLocationCoordinate2D)coord {
    //LOG_CURRENT_METHOD;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
    //double lat = coord.latitude;
    //double lon = coord.longitude;
    //LOG(@"lat = %f / lon = %f", lat, lon);
    
    if (!appDelegate.isShowingCenterCross) {
        appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
        return;
    }
    
    NSInteger zoomLevel = (NSInteger)[self getZoomLevel];
    if (zoomLevel >= GSI_MAPS_10mMESH_TILE_MAX_ZOOM_Level) {
        zoomLevel = GSI_MAPS_10mMESH_TILE_MAX_ZOOM_Level;
        
    } else if (zoomLevel < GSI_MAPS_10mMESH_TILE_MIN_ZOOM_Level) {
        //LOG(@"GSI_MAPS_10mMESH_TILE_MIN_ZOOM_Level 以下なので、return");
        appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
        return;
    }
    
    //MKZoomScale scale = [self zoomLevelToZoomScale:GSI_MAPS_10mMESH_TILE_MAX_ZOOM_Level];
    MKZoomScale scale = [self zoomLevelToZoomScale:zoomLevel];
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(coord);
    //CGPoint centerPoint = [self convertCoordinate:coord toPointToView:self];
    
    NSInteger x = floor((mapPoint.x * scale) / GSI_MAPS_TILE_SIZE);
    NSInteger y = floor((mapPoint.y * scale) / GSI_MAPS_TILE_SIZE);
    
    //LOG(@"mapRect = %@", NSStringFromCGRect(self.bounds));
    //LOG(@"centerPoint = %@", NSStringFromCGPoint(centerPoint));
    //LOG(@"mapPoint.x = %f / mapPoint.y = %f", mapPoint.x, mapPoint.y);
    //LOG(@"x = %d / y = %d", x, y); //x = 14376 / y = 6474
    
    //LOG(@"lat = %f / lon = %f", coord.latitude, coord.longitude);
    //LOG(@"mapPoint.x = %f / mapPoint.y = %f", mapPoint.x, mapPoint.y);
    
    // 求めたい緯度経度が含まれるmeshTileを特定
    NSString *map = @"dem";
    NSString *meshTileURL = [[NSString alloc] initWithFormat:@"%@%@/%ld/%ld/%ld%@", CGSI_MAPS_BASE_URL, map, (long)zoomLevel, (long)x, (long)y, Text_Extension];
    NSString *globalCashMeshPath = [Global meshPathForURLinDocuments:meshTileURL];
    
    //LOG(@"globalCashMeshPath = %@", globalCashMeshPath);
    
    // 特定されたmeshTileのMKMapRectを計算
    double minX = (x / scale) * GSI_MAPS_TILE_SIZE;
    double minY = (y / scale) * GSI_MAPS_TILE_SIZE;
    
    double maxX = ((x + 1) / scale) * GSI_MAPS_TILE_SIZE;
    double maxY = ((y + 1) / scale) * GSI_MAPS_TILE_SIZE;
    
    double mapRectWidth = maxX - minX;
    double mapRectHeight = maxY - minY;
    
    double widthPerPixel = mapRectWidth / 256;
    double heightPerPixel = mapRectHeight / 256;
    
//    LOG(@"widthPerPixel = %f / heightPerPixel = %f", widthPerPixel, heightPerPixel);
//    LOG(@"minX = %f", minX);
//    LOG(@"minY = %f", minY);
//    LOG(@"maxX = %f", maxX);
//    LOG(@"maxY = %f", maxY);
    
    //CLLocationCoordinate2D NW = MKCoordinateForMapPoint(MKMapPointMake(minX, minY));
    //CLLocationCoordinate2D SE = MKCoordinateForMapPoint(MKMapPointMake(maxX, maxY));
    //LOG(@"NW.lat = %f / NW.lon = %f", NW.latitude, NW.longitude);
    //LOG(@"SE.lat = %f / SE.lon = %f", SE.latitude, SE.longitude);
    
    int targetW = 0;
    int targetH = 0;
    
    for (int w = 0; w < 256; w++) {
        double fetchW = minX + (double)widthPerPixel * w;
        if (mapPoint.x < fetchW) {
            //LOG(@"fetchW = %f", fetchW);
            targetW = w;
            break;
        }
    }
    
    for (int h = 0; h < 256; h++) {
        double fetchH = minY + (double)heightPerPixel * h;
        if (mapPoint.y < fetchH) {
            //LOG(@"fetchH = %f", fetchH);
            targetH = h;
            break;
        }
    }
    
    //LOG(@"targetW = %d / targetH = %d", targetW, targetH);
    
    if ([Global hasLocalStorageCacheFile:globalCashMeshPath]) {
        //LOG(@"cccc- 標高データグローバルキャッシュあり : %@", globalCashMeshPath);
        
        NSFileManager* fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:globalCashMeshPath]) {
            NSString *textFileString = [[NSString alloc] initWithContentsOfFile:globalCashMeshPath encoding:NSUTF8StringEncoding error:NULL];
            //LOG(@"textFileString = %@", textFileString);
            
            NSMutableArray *tempMeshLineArray = [NSMutableArray new];
            
            // 複数行を保持するNSStringオブジェクト
            // \nのところで改行されています
            NSString *line;
            NSRange range, subRange;
            
            // 最初に文字列全範囲を示すRangeを作成する
            range = NSMakeRange(0, textFileString.length);
            
            
            
            // １行ずつ読み出す
            while (range.length > 0) {
                // １行分を示すRangeを取得します。
                subRange = [textFileString lineRangeForRange:NSMakeRange(range.location, 0)];
                // 1行分を示すRangeを用いて、文字列から１行抜き出す
                line = [textFileString substringWithRange:subRange];
                [tempMeshLineArray addObject:line];
                //LOG(@"line = %@", line);
                // 1行分を示すRangeの最終位置を、
                // 次の探索に使うRangeの最初として設定する
                range.location = NSMaxRange(subRange);
                // 文字列の終端を、次の探索に使うRangeの最終位置に登録します
                range.length -= subRange.length;
            }
            
            //NSArray *meshLineArray = [textFileString componentsSeparatedByString:@"\n"];
            NSArray *meshLineArray = (NSArray *)tempMeshLineArray;
            //LOG(@"meshLineArray.count = %d", meshLineArray.count);
            
            if (meshLineArray.count > 0) {
                NSString *meshLine = meshLineArray[targetH];
                NSArray *meshAltitudeArray = [meshLine componentsSeparatedByString:@","];
                NSString *meshAltitude = meshAltitudeArray[targetW];
                //meshAltitude = [NSString stringWithFormat:@"%d", [meshAltitude intValue]];
                if (![meshAltitude isEqualToString:@"e"]) {
                    appDelegate.currentAltitude = [meshAltitude intValue];
                    //LOG(@"cccc- 標高データグローバルキャッシュ：appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                    //self.crossCenterView.altitudeString = [NSString stringWithFormat:@"%dm", altitude];
                } else {
                    appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                    //LOG(@"cccc- 標高データグローバルキャッシュ：appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                    //self.crossCenterView.altitudeString = @"";
                }
            } else {
                
            }
        }
    } else {
        //LOG(@"dddd- 標高データキャッシュなし : %@", meshTileURL);
        NetworkStatus netStatus = [Global theNetworkStatus];
        if (netStatus != NotReachable) {
            
            //LOG(@"dddd- coordMapPointがWHOLE_OF_JAPAN_MapRect内にあるかどうか");
            if (![self checkJAPANMapRectContainsCoord:coord]) {
                //LOG(@"dddd- 日本国内でないのでreturn");
                appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                //LOG(@"appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                return;
            } else {
                //LOG(@"dddd- 日本国内です");
            }
            
            if (IfCashMeshNoGettingAltitudeAPI) {
                //LOG(@"****** 標高APIから取得 ********");
                double lat = coord.latitude;
                double lon = coord.longitude;
                //http://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?lon=140.08531&lat=36.103543&outtype=JSON
                
                NSString *altitude_api_URL = [[NSString alloc] initWithFormat:@"%@lon=%f&lat=%f&outtype=JSON",
                                              GSI_MAPS_ALTITUDE_API_BASE_URL,
                                              lon,
                                              lat];
                
                //LOG(@"dddd- 標高APIから取得：%@", altitude_api_URL);
                
                // *********** NSURLConnectionバージョン start *********** //
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:altitude_api_URL]
                                                                          cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                      timeoutInterval:TimeOutIntervalTileForMap]
                                                   queue:[[NSOperationQueue alloc] init]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               // メインスレッドでダウンロード完了時になにか処理を実行したいときや
                                               // 複数ダウンロードの途中経過をメインスレッドで通知したい時などはここに記述
                                               //LOG(@"tttt- NSURLConnection:成功したときの処理");
                                               
                                               if (error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       //LOG(@"NSURLConnection:失敗したときの処理");
                                                       //NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                                                       //LOG(@"Status code = %ldエラー", (long)response.statusCode); // 0エラー
                                                       //LOG(@"[error localizedDescription] = %@", [error localizedDescription]);
                                                       
                                                       appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                   });
                                               } else {
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       //LOG(@"NSURLConnection:成功したときの処理");
                                                       NSError *error;
                                                       NSDictionary *altitudeDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                                       //LOG(@"dddd- altitudeDic = %@", altitudeDic);
                                                       
                                                       if (error) {
                                                           appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                           return;
                                                       }
                                                       
                                                       if (altitudeDic != nil) {
                                                           
                                                           NSString *elevationString = (NSString *)altitudeDic[@"elevation"];
                                                           //LOG(@"dddd- elevationString = %@", elevationString);
                                                           
                                                           if([elevationString respondsToSelector:@selector(isEqualToString:)]) {
                                                               //LOG(@"dddd- isEqualToString:あり！　elevationString = %@", elevationString);
                                                               if ([elevationString isEqualToString:@"-----"]) {
                                                                   appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                                   //LOG(@"dddd- appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                                                               }
                                                               
                                                           } else if([elevationString respondsToSelector:@selector(intValue)]) {
                                                               //LOG(@"dddd- intValueあり！　elevationString = %@", elevationString);
                                                               appDelegate.currentAltitude = [elevationString intValue];
                                                               //LOG(@"dddd- appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                                                               
                                                           }
                                                           
                                                       } else {
                                                           appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                           //LOG(@"dddd- appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                                                           return;
                                                       }
                                                       
                                                   });
                                               }
                                           });
                                       }];
                
                // *********** NSURLConnectionバージョン end *********** //
            } else {
                //LOG(@"eeee- ****** 10mメッシュタイルから取得 ********");
                
                // *********** NSURLConnectionバージョン start *********** //
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:meshTileURL]
                                                                          cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                      timeoutInterval:TimeOutIntervalTileForMap]
                                                   queue:[[NSOperationQueue alloc] init]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               // メインスレッドでダウンロード完了時になにか処理を実行したいときや
                                               // 複数ダウンロードの途中経過をメインスレッドで通知したい時などはここに記述
                                               //LOG(@"tttt- NSURLConnection:成功したときの処理");
                                               
                                               if (error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       //LOG(@"NSURLConnection:失敗したときの処理");
                                                       //NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                                                       //LOG(@"Status code = %ldエラー", (long)response.statusCode); // 0エラー
                                                       //LOG(@"[error localizedDescription] = %@", [error localizedDescription]);
                                                       appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                   });
                                               } else {
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       //LOG(@"NSURLConnection:成功したときの処理");
                                                       AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                       appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                       // メインスレッドでダウンロード完了時になにか処理を実行したいときや
                                                       // 複数ダウンロードの途中経過をメインスレッドで通知したい時などはここに記述
                                                       
                                                       NSError *error = nil;
                                                       NSString *textFileString = [NSString stringWithContentsOfURL:[NSURL URLWithString:meshTileURL] encoding:NSUTF8StringEncoding error:&error];
                                                       
                                                       if ((error) || (textFileString == nil)) {
                                                           appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                           //LOG(@"eeee- (error) || (textFileString == nil)  appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                                                           return;
                                                       }
                                                       
                                                       NSMutableArray *tempMeshLineArray = [NSMutableArray new];
                                                       
                                                       // 複数行を保持するNSStringオブジェクト
                                                       // \nのところで改行されています
                                                       //NSString *multiLineString = @"aaaaaaaaa\nbbbbbbbb\ncccccccc";
                                                       NSString *line;
                                                       NSRange range, subRange;
                                                       
                                                       // 最初に文字列全範囲を示すRangeを作成する
                                                       range = NSMakeRange(0, textFileString.length);
                                                       
                                                       
                                                       // １行ずつ読み出す
                                                       while (range.length > 0) {
                                                           // １行分を示すRangeを取得します。
                                                           subRange = [textFileString lineRangeForRange:NSMakeRange(range.location, 0)];
                                                           // 1行分を示すRangeを用いて、文字列から１行抜き出す
                                                           line = [textFileString substringWithRange:subRange];
                                                           [tempMeshLineArray addObject:line];
                                                           //LOG(@"line = %@", line);
                                                           // 1行分を示すRangeの最終位置を、
                                                           // 次の探索に使うRangeの最初として設定する
                                                           range.location = NSMaxRange(subRange);
                                                           // 文字列の終端を、次の探索に使うRangeの最終位置に登録します
                                                           range.length -= subRange.length;
                                                       }
                                                       
                                                       //NSArray *meshLineArray = [textFileString componentsSeparatedByString:@"\n"];
                                                       NSArray *meshLineArray = (NSArray *)tempMeshLineArray;
                                                       NSString *meshLine = meshLineArray[targetH];
                                                       NSArray *meshAltitudeArray = [meshLine componentsSeparatedByString:@","];
                                                       NSString *meshAltitude = meshAltitudeArray[targetW];
                                                       
                                                       if (![meshAltitude isEqualToString:@"e"]) {
                                                           appDelegate.currentAltitude = [meshAltitude intValue];
                                                           //LOG(@"eeee- appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                                                       } else {
                                                           appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
                                                           //LOG(@"eeee- appDelegate.currentAltitude = %d", appDelegate.currentAltitude);
                                                       }
                                                   });
                                               }
                                           });
                                       }];
                
                // *********** NSURLConnectionバージョン end *********** //
            }
            
        } else {
            //LOG(@"ネットワーク未接続");
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.currentAltitude = GSI_MAPS_10mMESH_Error_Altitude;
        }
    }
}

+ (UIImage *)capturedImageWithView:(UIView *)aView {
    LOG_CURRENT_METHOD;
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = aView.layer.frame;
    CGPoint pt = aView.layer.frame.origin;
    
    CGContextSaveGState( context );
    CGContextSetFillColorWithColor(context, kCapturedImageColor.CGColor);
    CGContextFillRect(context, rect);
    CGContextRestoreGState( context );
    
    
    CGContextSaveGState( context );
    CGContextTranslateCTM( context, pt.x, pt.y);
    
    [[aView.layer presentationLayer] renderInContext:context]; //ココです！
    
    UIImage *tempImg = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState( context );
    UIGraphicsEndImageContext();
    return tempImg;
}

- (NSArray *)geoJSONEmergencySheltersInMapRect:(MKMapRect)rect zoomLevel:(NSInteger)level {
    LOG_CURRENT_METHOD;
    
    NSInteger z = 0;
    NSInteger minX = 0;
    NSInteger maxX = 0;
    NSInteger minY = 0;
    NSInteger maxY = 0;
    
    NSMutableArray *tiles = [NSMutableArray new];
    MKZoomScale scale = [self zoomLevelToZoomScale:level];
    
    //// Convert an MKZoomScale to a zoom level where level 0 contains 4 256px square tiles
    z = level;
    
//    LOG(@"level = %ld", z);
//    LOG(@"scale = %f", scale);
//    LOG(@"rect.origin.x = %f / rect.origin.y = %f", rect.origin.x, rect.origin.y);
//    LOG(@"rect.size.w = %f / rect.size.h = %f", rect.size.width, rect.size.height);
    
    //rect.origin.x = 239075328.000000 / rect.origin.y = 106954752.000000
    //rect.size.w = 1048576.000000 / rect.size.h = 1048576.000000
    
    //LOG(@"MKMapRectGetMinX(rect) = %f", MKMapRectGetMinX(rect));
    //LOG(@"MKMapRectGetMaxX(rect) = %f", MKMapRectGetMaxX(rect));
    //LOG(@"MKMapRectGetMinY(rect) = %f", MKMapRectGetMinY(rect));
    //LOG(@"MKMapRectGetMaxY(rect) = %f", MKMapRectGetMaxY(rect));
    
    minX = floor((MKMapRectGetMinX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    maxX = floor((MKMapRectGetMaxX(rect) * scale) / GSI_MAPS_TILE_SIZE);
    minY = floor((MKMapRectGetMinY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    maxY = floor((MKMapRectGetMaxY(rect) * scale) / GSI_MAPS_TILE_SIZE);
    
    // 指定緊急避難場所が取得可能な範囲かどうかチェック
    if ((minX < GSI_Shelter_MKMapRect_X_Min) &&
        (maxX > GSI_Shelter_MKMapRect_X_Max) &&
        (minY < GSI_Shelter_MKMapRect_Y_Min) &&
        (maxY > GSI_Shelter_MKMapRect_Y_Max)) {
        // 該当しない範囲のため、nil を返す
        return nil;
    }
    
    NSString *shelterType = [Global getCurrentShelterType];
    if ([shelterType compare:GSI_Shelter_Type_none] == NSOrderedSame) {
        return nil;
    }
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            
            //MKMapPoint mapPoint = MKMapPointMake(x, y);
            //NSString *tileURL = [self geoJSONEmergencySheltersInMapPoint:mapPoint zoomLevel:z];
            
            if ((x < GSI_Shelter_MKMapRect_X_Min) ||
                (x > GSI_Shelter_MKMapRect_X_Max) ||
                (y < GSI_Shelter_MKMapRect_Y_Min) ||
                (y > GSI_Shelter_MKMapRect_Y_Max)) {
                //LOG(@"該当しない範囲のため何もしない x = %ld / y = %ld / z = %ld", (long)x, (long)y, (long)z);
                
            } else {
                
                // 該当する範囲
                MKTileOverlayPath targetPath;
                targetPath.x = x;
                targetPath.y = y;
                targetPath.z = z;
                
                NSString *extension = geoJSON_Extension;
                NSString *tileURL = [[NSString alloc] initWithFormat:@"%@%@/%ld/%ld/%ld%@", CGSI_MAPS_BASE_URL, shelterType, (long)z, (long)x, (long)y, extension];
                if (tileURL != nil) {
                    [tiles addObject:tileURL];
                }
            }
        }
    }
    
    if (tiles.count > 0) {
        return (NSArray *)tiles;
    } else {
        return nil;
    }
    
}

- (NSString *)geoJSONEmergencySheltersInMapPoint:(MKMapPoint)mappoint zoomLevel:(NSInteger)level {
    LOG_CURRENT_METHOD;
    
    NSInteger z = 0;
    NSInteger x = 0;
    NSInteger y = 0;
    
    MKZoomScale scale = [self zoomLevelToZoomScale:level];
    NSString *tileURL;
    
    //// Convert an MKZoomScale to a zoom level where level 0 contains 4 256px square tiles
    z = level;
    
    x = floor((mappoint.x * scale) / GSI_MAPS_TILE_SIZE);
    y = floor((mappoint.y * scale) / GSI_MAPS_TILE_SIZE);
    
    if ((x == 0) || (y == 0)) {
        return nil;
    }
    
    NSString *extension = geoJSON_Extension;
    NSString *shelterType = [Global getCurrentShelterType];
    if ([shelterType compare:GSI_Shelter_Type_none] == NSOrderedSame) {
        return nil;
    }
    
    tileURL = [[NSString alloc] initWithFormat:@"%@%@/%ld/%ld/%ld%@", CGSI_MAPS_BASE_URL, shelterType, (long)z, (long)x, (long)y, extension];
    
    LOG(@"x = %ld, y = %ld", (long)x, (long)y);
    //LOG(@"tileURL = %@", tileURL);

    return tileURL;
}

- (MKTileOverlayPath)geoOverlayPathEmergencyShelters:(CLLocationCoordinate2D)coordinate zoomLevel:(NSInteger)level {
    
    NSInteger z = 0;
    NSInteger x = 0;
    NSInteger y = 0;
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    MKZoomScale scale = [self zoomLevelToZoomScale:level];
    z = level;
    x = floor((mapPoint.x * scale) / GSI_MAPS_TILE_SIZE);
    y = floor((mapPoint.y * scale) / GSI_MAPS_TILE_SIZE);

    MKTileOverlayPath path;
    path.z = z;
    path.x = x;
    path.y = y;
    return path;
}

@end
