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
    //NSString *template = GSI_SEAMLESSPHOTO_BASE_URL;
    
    
    self.dkTileOverlay = [[DKTileOverlay alloc] initWithURLTemplate:template];
    self.dkTileOverlay.canReplaceMapContent = NO;
    [self.map addOverlay:self.dkTileOverlay level:MKOverlayLevelAboveLabels];
    
    //tileRenderer = DKTileOverlayRenderer(tileOverlay: overlay)
}

 - (NSURL *)URLForTilePath:(MKTileOverlayPath)path {
     LOG_CURRENT_METHOD;
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://cyberjapandata.gsi.go.jp/xyz/pale/{%ld}/{%ld}/{%ld}.png", (long)path.z, (long)path.x, (long)path.y]];
     return url;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData * _Nullable, NSError * _Nullable))result {
    LOG_CURRENT_METHOD;
    NSString *tilePath = [[self URLForTilePath:path] absoluteString];
    NSData *data = nil;

    if (![[NSFileManager defaultManager] fileExistsAtPath:tilePath]) {
        LOG(@"Z%ld/%ld/%ld does not exist!", path.z, path.x, path.y);
    } else {
        LOG(@"Z%ld/%ld/%ld exist", path.z, path.x, path.y);

        UIImage *image = [UIImage imageWithContentsOfFile:tilePath];
        data = UIImageJPEGRepresentation(image, 0.8);
        // Instead of: data = [NSData dataWithContentsOfFile:tilePath];

        if (data == nil) {
            LOG(@"Error!!! Unable to read an existing file!");
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        result(data, nil);
    });
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
