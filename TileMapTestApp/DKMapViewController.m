//
//  DKMapViewController.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "DKMapViewController.h"
#import "Global.h"

@interface DKMapViewController ()

@property (assign, nonatomic) CGRect            defaultMapRect;

@end

@implementation DKMapViewController

- (id)init {
    LOG_CURRENT_METHOD;
    self = [super init];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.title = @"MapTest";
    //LOG(@"self.appDelegate = %@", self.appDelegate);
    
//    self.mapDataBorderFlag = NO;
//    self.isDraggingDKAltitudeGraphFlag = NO;
//    self.currentFlag2500 = NO;
//    
//    self.slideNavigationController = self.appDelegate.menuViewController.navigationForMap;
//    self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//    
//    self.appDelegate.localMapArea_NW_Coord = EmptyLocationCoordinate;
//    self.appDelegate.localMapArea_SW_Coord = EmptyLocationCoordinate;
//    self.appDelegate.localMapArea_SE_Coord = EmptyLocationCoordinate;
//    self.appDelegate.localMapArea_NE_Coord = EmptyLocationCoordinate;
//        
//    //self.currentLocalImagesPath = nil;
//    
//    self.dkTileSubAlphaOverlayArray = [NSMutableArray new];
//    self.dkTileSubAlphaOverlayRendererArray = [NSMutableArray new];
    
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    
    
    CGFloat mapWidth = CGRectGetWidth(self.view.bounds) * MAP_SIZE_RATIO_SCREEN;
    CGFloat mapHeight = CGRectGetHeight(self.view.bounds) * MAP_SIZE_RATIO_SCREEN;
    self.map_visibleRect_padding_left = (mapWidth - CGRectGetWidth(self.view.bounds)) * 0.5;
    self.map_visibleRect_padding_top = (mapHeight - CGRectGetHeight(self.view.bounds)) * 0.5;
    self.defaultMapRect = CGRectMake(self.map_visibleRect_padding_left * -1,
                                     self.map_visibleRect_padding_top * -1,
                                     CGRectGetWidth(self.view.bounds) * MAP_SIZE_RATIO_SCREEN,
                                     CGRectGetHeight(self.view.bounds) * MAP_SIZE_RATIO_SCREEN);
    self.map = [[MKMapView alloc] initWithFrame:self.defaultMapRect];
    
    LOG(@"self.defaultMapRect = %@", NSStringFromCGRect(self.defaultMapRect));
    LOG(@"self.view.bounds = %@", NSStringFromCGRect(self.view.bounds));
    
    self.map.delegate = self;
    self.map.mapType = MKMapTypeStandard;
    self.map.showsUserLocation = YES;
    self.map.pitchEnabled = YES;
    self.map.showsBuildings = YES;
    self.map.showsCompass = YES;
    
    [self.view addSubview:self.map];
    
    //目印となるOverlayとTileOverlayの階層構造
    // **** mapBackgroundPolygon **** //
    MKMapRect worldRect = MKMapRectMake(-180, -90, MKMapSizeWorld.width, MKMapSizeWorld.height);
    MKMapPoint point1 = MKMapRectWorld.origin;
    MKMapPoint point2 = MKMapPointMake(point1.x+worldRect.size.width,point1.y);
    MKMapPoint point3 = MKMapPointMake(point2.x, point2.y+worldRect.size.height);
    MKMapPoint point4 = MKMapPointMake(point1.x, point3.y);
    MKMapPoint points[4] = {point1,point2,point3,point4};
    
    self.mapBackgroundPolygon = [MKPolygon polygonWithPoints:points count:4];
    [self.map insertOverlay:self.mapBackgroundPolygon atIndex:0];
    
    self.dkStdMarker = [MKPolygon polygonWithCoordinates:[self.map getPolygonCoords:self.view.frame] count:4];
    [self.map insertOverlay:self.mapBackgroundPolygon atIndex:1];
    
    self.dkSubAlphaMarker = [MKPolygon polygonWithCoordinates:[self.map getPolygonCoords:self.view.frame] count:4];
    [self.map insertOverlay:self.mapBackgroundPolygon atIndex:2];
    
    [self setupTileRenderer];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
}

- (void)setupTileRenderer {
    LOG_CURRENT_METHOD;
    NSString *template = GSI_PALE_BASE_URL;
    
    self.dkTileOverlay = [[DKTileOverlay alloc] initWithURLTemplate:template];
    self.dkTileOverlay.canReplaceMapContent = NO;
    [self.map addOverlay:self.dkTileOverlay level:MKOverlayLevelAboveLabels];
    
    //tileRenderer = DKTileOverlayRenderer(tileOverlay: overlay)
}

- (CLLocationCoordinate2D *)getPolygonCoords:(CGRect)targetRect {
    //LOG_CURRENT_METHOD;
    
    CGPoint northWest = CGPointMake(targetRect.origin.x
                                    ,targetRect.origin.y);
    CLLocationCoordinate2D nwCoord = [self.map convertPoint:northWest toCoordinateFromView:self.map];
    
    CGPoint southWest = CGPointMake(targetRect.origin.x
                                    ,targetRect.origin.y + targetRect.size.height);
    CLLocationCoordinate2D swCoord = [self.map convertPoint:southWest toCoordinateFromView:self.map];
    
    CGPoint southEast = CGPointMake(targetRect.origin.x + targetRect.size.width
                                    ,targetRect.origin.y + targetRect.size.height);
    CLLocationCoordinate2D seCoord = [self.map convertPoint:southEast toCoordinateFromView:self.map];
    
    CGPoint northEast = CGPointMake(targetRect.origin.x + targetRect.size.width
                                    ,targetRect.origin.y);
    CLLocationCoordinate2D neCoord = [self.map convertPoint:northEast toCoordinateFromView:self.map];
    
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

-(MKOverlayRenderer *)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    LOG_CURRENT_METHOD;
    LOG(@"overlay = %@", overlay);
    
    if([overlay isKindOfClass:[DKTileOverlay class]]) {
        LOG(@"dkTileSubAlphaOverlay : ");

        //self.dkTileOverlayRenderer = nil;
        self.dkTileOverlayRenderer = [[DKTileOverlayRenderer alloc] initWithTileOverlay:self.dkTileOverlay];
        //self.dkTileOverlayRenderer.alpha = 0.2;
        return self.dkTileOverlayRenderer;

    }
    
    return nil;
    
}



@end
