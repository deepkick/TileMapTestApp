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

@end
