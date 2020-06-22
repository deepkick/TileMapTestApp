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

- (CLLocationCoordinate2D *)getPolygonCoords:(CGRect)targetRect;

@end
