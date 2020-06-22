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
    [self mainThread_insertOverlay:self.mapBackgroundPolygon atIndex:0];
    
    self.dkStdMarker = [MKPolygon polygonWithCoordinates:[self.map getPolygonCoords:self.view.frame] count:4];
    [self mainThread_insertOverlay:self.dkStdMarker atIndex:1];
    
    self.dkSubAlphaMarker = [MKPolygon polygonWithCoordinates:[self.map getPolygonCoords:self.view.frame] count:4];
    [self mainThread_insertOverlay:self.dkSubAlphaMarker atIndex:2];
    
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
    
    //self.dkTileOverlay = [[DKTileOverlay alloc] initOverlay];
    self.dkTileOverlay = [[DKTileOverlay alloc] initWithURLTemplate:template];
    self.dkTileOverlay.canReplaceMapContent = YES;
    
    //[self mainThread_insertOverlay:self.dkTileOverlay aboveOverlay:self.dkSubAlphaMarker];
    //[self mainThread_insertOverlay:self.dkTileOverlay belowOverlay:self.mapBackgroundPolygon];
    
    [self.map addOverlay:self.dkTileOverlay level:MKOverlayLevelAboveRoads];
    
    //tileRenderer = DKTileOverlayRenderer(tileOverlay: overlay)
}

  
-(MKOverlayRenderer *)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    LOG_CURRENT_METHOD;
    LOG(@"overlay = %@", overlay);
    
    if([overlay isKindOfClass:[DKTileOverlay class]]) {
        LOG(@"dkTileSubAlphaOverlay : ");

        self.dkTileOverlayRenderer = nil;
        self.dkTileOverlayRenderer = [[DKTileOverlayRenderer alloc] initWithTileOverlay:self.dkTileOverlay];
        //self.dkTileSubAlphaOverlayRenderer_A.alpha = self.overlaySubAlpha;
        return self.dkTileOverlayRenderer;

    }
    
    return nil;
    
//    //dkSubAlphaMarker
//    if (overlay == self.dkSubAlphaMarker) {
//        //LOG(@"dkSubAlphaMarker : ");
//        self.dkSubAlphaMarkerRenderer = [[DKPolylineMarkerRenderer alloc] initWithPolygon:self.dkSubAlphaMarker];
//        self.dkSubAlphaMarkerRenderer.fillColor = kDefaultTintBaseColor;
//        return self.dkSubAlphaMarkerRenderer;
//    }
}

//#pragma mark - DKMapDataPolygon
//- (void)addMapDataPolygonFromNewToActiveByFilePath:(NSString *)newfilePath {
//    //LOG_CURRENT_METHOD;
//    //LOG(@"newfilePath = %@", newfilePath);
//    //LOG(@"currentLocalMapFile = %@", self.appDelegate.menuViewController.dkMapViewController.currentLocalMapFile);
//    //LOG(@"self.appDelegate.activeMapDatasArray = %@", [self.appDelegate.activeMapDatasArray description]);
//
//    // 有効な地図データが選択されていない場合
//    if ((([_currentLocalMapFile compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame)) || (_currentLocalMapFile == nil)) {
//
//    } else {
//
//    }
//
//    NSUInteger indexNum = [self.appDelegate indexOfOverlaidMapData:newfilePath];
//    //LOG(@"indexNum = %lu", (unsigned long)indexNum);
//
//
//    if (indexNum != NSNotFound) {
//        DKMapDataPolygon *selectMapDataPolygon = [self.appDelegate.overlaidMapDatasArray objectAtIndex:indexNum];
//
//        //LOG(@"選択された地図データは、表示中の地図データのひとつである");
//        if (self.appDelegate.activeMapDatasArray.count > 0) {
//            //LOG(@"アクティブな地図データが存在している");
//            DKMapDataPolygon *activeMapDataPolygon = [self.appDelegate.overlaidMapDatasArray lastObject];
//
//            if (([selectMapDataPolygon.filepath compare:activeMapDataPolygon.filepath] == NSOrderedSame)) {
//                //LOG(@"アクティブな地図データと同じ地図データなので、何もしない");
//                return;
//            } else {
//                //LOG(@"アクティブな地図データと異なるので、古いアクティブな地図データを通常に戻す。次に選択された地図データのアクティブ化処理をする");
//                [self removeMapDataPolygonByFilePath:activeMapDataPolygon.filepath];
//
//                //LOG(@"MMM 000");
//                self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//
//                //LOG(@"000");
//                [self addMapDataPolygonByFilePath:activeMapDataPolygon.filepath];
//
//                [self removeMapDataPolygonByFilePath:selectMapDataPolygon.filepath];
//                //self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//
//                self.currentLocalMapFile = selectMapDataPolygon.filepath;
//                return;
//            }
//
//
//        } else {
//            //LOG(@"アクティブな地図データが存在していないので、選択された地図データのアクティブ化処理のみでOK");
//
//            [self removeMapDataPolygonByFilePath:selectMapDataPolygon.filepath];
//
//            //LOG(@"MMM 111");
//            self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//
//            self.currentLocalMapFile = selectMapDataPolygon.filepath;
//            return;
//        }
//
//    } else {
//        //LOG(@"選択された地図データは、表示中の地図データではない。");
//
//        if (self.appDelegate.activeMapDatasArray.count > 0) {
//            DKMapDataPolygon *activeMapDataPolygon = [self.appDelegate.overlaidMapDatasArray lastObject];
//            //LOG(@"アクティブな地図データ %@ が存在しているので、通常表示に戻す。", activeMapDataPolygon.mapDataName);
//            [self removeMapDataPolygonByFilePath:activeMapDataPolygon.filepath];
//
//            //LOG(@"MMM 222");
//            self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//
//            //LOG(@"111");
//            [self addMapDataPolygonByFilePath:activeMapDataPolygon.filepath];
//        }
//
//        //LOG(@"選択された地図データのアクティブ化処理");
//        self.currentLocalMapFile = newfilePath;
//        return;
//    }
//}
//
//- (void)changeMapDataPolygonFromDisActiveToActiveByFilePath:(NSString *)filePath {
//    //LOG_CURRENT_METHOD;
//    //LOG(@" ********** changeMapDataPolygonFromDisActiveToActiveByFilePath START ********** ");
//
//    //LOG(@"filePath = %@", filePath);
//    //LOG(@"currentLocalMapFile = %@", self.appDelegate.menuViewController.dkMapViewController.currentLocalMapFile);
//
//    NSUInteger indexNum = [self.appDelegate indexOfOverlaidMapData:filePath];
//    //LOG(@"indexNum = %lu", (unsigned long)indexNum);
//
////    for (DKMapDataPolygon *activeMapDataPolygon in self.appDelegate.overlaidMapDatasArray) {
////        LOG(@"表示状態：activeMapDataPolygon.mapDataName = %@", activeMapDataPolygon.mapDataName);
////    }
////
////    for (DKMapDataPolygon *activeMapDataPolygon in self.appDelegate.activeMapDatasArray) {
////        LOG(@"選択状態：activeMapDataPolygon.mapDataName = %@", activeMapDataPolygon.mapDataName);
////    }
//
//    if (indexNum != NSNotFound) {
//
//        // 対象となるDKMapDataPolygon
//        DKMapDataPolygon *selectMapDataPolygon = [self.appDelegate.overlaidMapDatasArray objectAtIndex:indexNum];
//
//        //LOG(@"選択された地図データは、表示中の地図データのひとつである");
//        if (self.appDelegate.activeMapDatasArray.count > 0) {
//            //LOG(@"アクティブな地図データが存在している");
//            DKMapDataPolygon *activeLastObject = [self.appDelegate.activeMapDatasArray lastObject];
//            //LOG(@"activeLastObject = %@", activeLastObject.mapDataName);
//
//            if (([selectMapDataPolygon.filepath compare:activeLastObject.filepath] == NSOrderedSame)) {
//                //LOG(@"アクティブな地図データと同じ地図データなので、何もしない");
//                //LOG(@" ********** changeMapDataPolygonFromDisActiveToActiveByFilePath END ********** ");
//                return;
//            } else {
//                //LOG(@"アクティブな地図データと異なるので、古いアクティブな地図データを通常に戻す。次に選択された地図データのアクティブ化処理をする");
//                [self removeMapDataPolygonByFilePath:activeLastObject.filepath];
//
//                //LOG(@"MMM 333");
//                //self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//                [self addMapDataPolygonByFilePath:activeLastObject.filepath];
//
//                [self removeMapDataPolygonByFilePath:selectMapDataPolygon.filepath];
//                self.currentLocalMapFile = selectMapDataPolygon.filepath;
//                //LOG(@" ********** changeMapDataPolygonFromDisActiveToActiveByFilePath END ********** ");
//                return;
//            }
//
//
//        } else {
//            //LOG(@"アクティブな地図データが存在していないので、選択された地図データのアクティブ化処理のみでOK");
//
//            [self removeMapDataPolygonByFilePath:selectMapDataPolygon.filepath];
//
//            //LOG(@"MMM 444");
//            self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//            self.currentLocalMapFile = selectMapDataPolygon.filepath;
//            //LOG(@" ********** changeMapDataPolygonFromDisActiveToActiveByFilePath END ********** ");
//            return;
//        }
//
//    } else {
//        //LOG(@"選択された地図データは、表示中の地図データではない。");
//
//        if (self.appDelegate.activeMapDatasArray.count > 0) {
//
//            DKMapDataPolygon *activeLastObject = [self.appDelegate.activeMapDatasArray lastObject];
//            //LOG(@"activeLastObject = %@", activeLastObject.mapDataName);
//            //LOG(@"アクティブな地図データ %@ が存在しているので、通常表示に戻す。", activeLastObject.mapDataName);
//            [self removeMapDataPolygonByFilePath:activeLastObject.filepath];
//
//            //LOG(@"MMM 555");
//            self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//
//            //LOG(@"333");
//            [self addMapDataPolygonByFilePath:activeLastObject.filepath];
//        }
//
//        //LOG(@"選択された地図データのアクティブ化処理");
//        self.currentLocalMapFile = filePath;
//        //LOG(@" ********** changeMapDataPolygonFromDisActiveToActiveByFilePath END ********** ");
//        return;
//    }
//}
//
//- (void)changeMapDataPolygonFromActiveToDisActiveByFilePath:(NSString *)filePath {
//    //LOG_CURRENT_METHOD;
//    //LOG(@" ********** changeMapDataPolygonFromActiveToDisActiveByFilePath: START ********** ");
//    // 地図データを削除し、currentLocalMapFileを初期化し、再度追加。
//    [self removeMapDataPolygonByFilePath:filePath];
//
//    //LOG(@"MMM 666");
//    //self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//
//    //LOG(@"444");
//    [self addMapDataPolygonByFilePath:filePath];
//
//    //LOG(@" ********** changeMapDataPolygonFromActiveToDisActiveByFilePath: END ********** ");
//}
//
//- (void)showMapDataBorder:(BOOL)b {
//    //LOG_CURRENT_METHOD;
//
//    if (b) {
//
//        if (self.mapDataPolygon) {
//            [self removeMapDataPolygonByFilePath:self.currentLocalMapFile];
//        }
//
//        [self addMapDataPolygonByFilePath:self.currentLocalMapFile];
//
//        //LOG(@"self.appDelegate.overlaidMapDatasArray = %@", self.appDelegate.overlaidMapDatasArray);
//        //LOG(@"self.mapDataPolygon.filepath = %@", self.mapDataPolygon.filepath);
//
//        MKCoordinateRegion region = MKCoordinateRegionForMapRect([Global getMapRectOfLocalMapInfo:self.currentLocalMapFile
//                                                                                           margin:MAP_DATA_BORDER_MARGIN]);
//        [self.map setRegion:region animated:YES];
//
//    } else {
//
//        if (self.mapDataPolygon) {
//            if (([self.currentLocalMapFile compare:DEFAULT_CURRENT_LOCALMAP] != NSOrderedSame)) {
//                [self removeMapDataPolygonByFilePath:self.currentLocalMapFile];
//                self.mapDataPolygon = nil;
//            }
//        }
//    }
//}
//
//- (void)addMapDataPolygonByFilePath:(NSString *)filePath {
//    //LOG_CURRENT_METHOD;
//    //LOG(@" ********** addMapDataPolygonByFilePath: START ********** ");
//    self.mapDataPolygon = [DKMapDataPolygon polygonWithCoordinates:[self.map getPolygonCoordsMapData:filePath] count:4];
//    self.mapDataPolygon.activeFlag = NO;
//    self.mapDataPolygon.filepath = filePath;
//    self.mapDataPolygon.mapDataName = [Global getDocNameOfLocalMapInfo:self.mapDataPolygon.filepath];
//
//    if (([self.currentLocalMapFile compare:filePath] == NSOrderedSame)) {
//        //LOG(@"アクティブな地図データに格上げする処理");
//        self.mapDataPolygon.activeFlag = YES;
//        [self.appDelegate.activeMapDatasArray removeAllObjects];
//        [self.appDelegate.activeMapDatasArray addObject:self.mapDataPolygon];
//    } else {
//        //LOG(@"アクティブな地図データに格上げする処理はなし");
//    }
//
//    //LOG(@"%@ をOverlayに追加", self.mapDataPolygon.mapDataName);
//    [self mainThread_addOverlayTop:self.mapDataPolygon];
//
////    for (DKMapDataPolygon *activeMapDataPolygon in self.appDelegate.activeMapDatasArray) {
////        LOG(@"アクティブな地図データ：activeMapDataPolygon.mapDataName = %@", activeMapDataPolygon.mapDataName);
////    }
//
////    for (DKMapDataPolygon *visibleMapDataPolygon in self.appDelegate.overlaidMapDatasArray) {
////        LOG(@"表示状態AAA：visibleMapDataPolygon.mapDataName = %@", visibleMapDataPolygon.mapDataName);
////    }
//
//    [self.appDelegate.overlaidMapDatasArray addObject:self.mapDataPolygon];
//
//
////    for (DKMapDataPolygon *visibleMapDataPolygon in self.appDelegate.overlaidMapDatasArray) {
////        LOG(@"表示状態BBB：visibleMapDataPolygon.mapDataName = %@", visibleMapDataPolygon.mapDataName);
////    }
//
//    //DKMapDataPolygon *lastObjectoverlaidMapDatasArray = [self.appDelegate.overlaidMapDatasArray lastObject];
//    //LOG(@"LastObject：lastObjectoverlaidMapDatasArray.mapDataName = %@", lastObjectoverlaidMapDatasArray.mapDataName);
//
//
//    NSDictionary *localMapDic = [Global getLocalMapInfoDic:self.mapDataPolygon.filepath];
//
//    NSArray *coordinates = [[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"coordinates"] objectAtIndex:0];
//
//    CLLocationCoordinate2D coordinate_NW = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:0] doubleValue]);
//
//    DKMapDataNameAnnotation *dkMapDataAnnotation = [[DKMapDataNameAnnotation alloc] initWithCoordinate:coordinate_NW
//                                                                                                 title:self.mapDataPolygon.mapDataName
//                                                                                              filePath:self.mapDataPolygon.filepath];
//    dkMapDataAnnotation.activeFlag = self.mapDataPolygon.activeFlag;
//    self.mapDataPolygon.nameAnnotation = dkMapDataAnnotation;
//    [self mainThread_addAnnotation:self.mapDataPolygon.nameAnnotation];
//
//    //LOG(@" ********** addMapDataPolygonByFilePath: END ********** ");
//}
//
//- (void)removeMapDataPolygonByFilePath:(NSString *)filePath {
//    //LOG_CURRENT_METHOD;
//    //LOG(@" ********** removeMapDataPolygonByFilePath: START ********** ");
//
//    NSUInteger indexNum = [self.appDelegate indexOfOverlaidMapData:filePath];
//    //LOG(@"indexNum = %lu", (unsigned long)indexNum);
//
//    if (indexNum != NSNotFound) {
//
//        self.mapDataPolygon = [self.appDelegate.overlaidMapDatasArray objectAtIndex:indexNum];
//
//        if (self.mapDataPolygon == [self.appDelegate.activeMapDatasArray lastObject]) {
//            //LOG(@"アクティブな地図データを非アクティブにする処理");
//            self.mapDataPolygon.activeFlag = NO;
//            self.mapDataPolygon.nameAnnotation.activeFlag = self.mapDataPolygon.activeFlag;
//            [self.appDelegate.activeMapDatasArray removeAllObjects];
//
//            //LOG(@"MMM 777");
//            self.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//        }
//
//        [self.appDelegate.overlaidMapDatasArray removeObject:self.mapDataPolygon];
//        self.mapDataPolygon.nameAnnotation.mapDataNameAnnotationView.clearFlag = YES;
//
//        [self mainThread_removeAnnotation:self.mapDataPolygon.nameAnnotation];
//        [self mainThread_removeOverlay:self.mapDataPolygon];
//
//        self.mapDataPolygon.nameAnnotation.mapDataNameAnnotationView = nil;
//        self.mapDataPolygon.nameAnnotation = nil;
//        self.mapDataPolygon = nil;
//        //LOG(@"%@ の self.appDelegate.overlaidMapDatasArrayからの削除に成功", filePath);
//        //LOG(@" ********** removeMapDataPolygonByFilePath: END ********** ");
//    } else {
//        //LOG(@"filePathが見つからない");
//    }
//}


#pragma mark - MKPolyline Main Thread
- (void) mainThread_addOverlayTop:(id <MKOverlay>)overlay {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (overlay != nil) {
        [self.map addOverlay:overlay];
    }
    //});
    
}

- (void) mainThread_insertOverlay:(id <MKOverlay>)overlay aboveOverlay:(id <MKOverlay>)sibling {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ((overlay != nil) && (sibling != nil)) {
        [self.map insertOverlay:overlay aboveOverlay:sibling];
    }
    //});
}

- (void) mainThread_insertOverlay:(id <MKOverlay>)overlay belowOverlay:(id <MKOverlay>)sibling {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ((overlay != nil) && (sibling != nil)) {
        [self.map insertOverlay:overlay belowOverlay:sibling];
    }
    //});
}

- (void) mainThread_insertOverlay:(id <MKOverlay>)overlay atIndex:(NSUInteger)index {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (overlay != nil) {
        [self.map insertOverlay:overlay atIndex:(NSUInteger)index];
    }
    //});
}

- (void) mainThread_exchangeOverlay:(id <MKOverlay>)overlayA withOverlay:(id <MKOverlay>)overlayB {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ((overlayA != nil) && (overlayB != nil)) {
        [self.map exchangeOverlay:overlayA withOverlay:overlayB];
    }
    //});
}

- (void) mainThread_removeOverlay:(id <MKOverlay>)overlay {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (overlay != nil) {
        [self.map removeOverlay:overlay];
    }
    //});
}

- (void) mainThread_removeOverlays:(NSArray<id<MKOverlay>> *)overlays {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (overlays == nil) {
        return;
    }
    
    if (overlays.count == 0) {
        return;
    }
                                                      
    [self.map removeOverlays:overlays];
    //});
}

- (void) mainThread_addAnnotation:(id <MKAnnotation>)annotation {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (annotation != nil) {
        [self.map addAnnotation:annotation];
    }
    //});
}

- (void) mainThread_removeAnnotation:(id <MKAnnotation>)annotation {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (annotation != nil) {
        [self.map removeAnnotation:annotation];
    }
    //});
}

- (void)mainThread_removeAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    //LOG_CURRENT_METHOD;
    //dispatch_async(dispatch_get_main_queue(), ^{
    if (annotations == nil) {
        return;
    }
    
    if (annotations.count == 0) {
        return;
    }
    
    [self.map removeAnnotations:annotations];
    //});
}


@end
