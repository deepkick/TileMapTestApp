//
//  MKMapView+ZoomLevel.m
//  GSI_Maps
//
//  Created by Kaoru Honda on 2014/08/26.
//  Copyright (c) 2014 Kaoru Honda. All rights reserved.
//


#import "Common_header.h"

@implementation MKMapView (ZoomLevel)

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
    
    LOG(@"nwCoord:lat = %f, lon = %f", polygonCoords[0].latitude, polygonCoords[0].longitude);
    LOG(@"swCoord:lat = %f, lon = %f", polygonCoords[1].latitude, polygonCoords[1].longitude);
    LOG(@"seCoord:lat = %f, lon = %f", polygonCoords[2].latitude, polygonCoords[2].longitude);
    LOG(@"neCoord:lat = %f, lon = %f", polygonCoords[3].latitude, polygonCoords[3].longitude);
    
    return polygonCoords;
}

@end
