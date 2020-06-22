//
//  Common_header.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static const CLLocationCoordinate2D EmptyLocationCoordinate = {-1000.0, -1000.0};

typedef enum {
    std,
    pale,
    blank,
    relief,
    ort,
    english,
    applemap,
    googlemap,
    openstreetmap,
    opencyclemap,
    mapBoxStreets,
    mapBoxOutdoors,
} kMapType;



// Categories
#import "MKMapView+ZoomLevel.h"

// TileOverlay
#import "DKTileOverlay.h"
#import "DKTileOverlayRenderer.h"

#import "DKNavigationController.h"
#import "DKMapViewController.h"
#import "Global.h"
#import "AppDelegate.h"

