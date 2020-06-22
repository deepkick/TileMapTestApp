//
//  Global.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Global.h"
#import "AppDelegate.h"
#import "DKMapViewController.h"



@implementation Global


#pragma mark - LocalMapInfo Methods
+ (NSDictionary *)getLocalMapInfoDic:(NSString *)path {
    //LOG_CURRENT_METHOD;
    //LOG(@"path = %@", path);
    
    if (path == nil) {
        return nil;
    }
    
    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
        return nil;
    }
    
    NSError *error;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path options:0 error:&error];
    NSDictionary *localMapDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    //LOG(@"localMapDic = %@", [localMapDic description]);
    return localMapDic;
}

//+ (MKMapRect)getMapRectOfLocalMapInfo:(NSString *)path margin:(CGFloat)margin {
//    //LOG_CURRENT_METHOD;
//    //LOG(@"path = %@", path);
//    
//    if (path == nil) {
//        return MKMapRectNull;
//    }
//    
//    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
//        return MKMapRectNull;
//    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//    
//    NSArray *coordinates = [[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"coordinates"] objectAtIndex:0];
//    
//    CLLocationCoordinate2D coordinate_NW = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:0] doubleValue]);
//    CLLocationCoordinate2D coordinate_SE = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:0] doubleValue]);
//    
//    //LOG(@"coordinate_NW.lat = %f / coordinate_NW.lon = %f", coordinate_NW.latitude, coordinate_NW.longitude);
//    //LOG(@"coordinate_SW.lat = %f / coordinate_SW.lon = %f", coordinate_SW.latitude, coordinate_SW.longitude);
//    //LOG(@"coordinate_SE.lat = %f / coordinate_SE.lon = %f", coordinate_SE.latitude, coordinate_SE.longitude);
//    //LOG(@"coordinate_NE.lat = %f / coordinate_NE.lon = %f", coordinate_NE.latitude, coordinate_NE.longitude);
//    
//    return [[Global class] getMapRectCoordinate_NW:coordinate_NW
//                                     Coordinate_SE:coordinate_SE
//                                            margin:margin];
//}
//
//+ (MKMapRect)getMapRectCoordinate_NW:(CLLocationCoordinate2D)coordinate_NW
//                       Coordinate_SE:(CLLocationCoordinate2D)coordinate_SE
//                              margin:(CGFloat)margin {
//    //LOG_CURRENT_METHOD;
//    // MKMapPoint を CGPointに変換
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    DKMapViewController *dkMapViewController = appDelegate.dkMapViewController;
//    
//    MKMapRect visibleRect = dkMapViewController.map.visibleMapRect;
//    //NSStringFromMKMapRect(visibleRect);
//    //{238460013.800523, 105670642.869680}, {w, h} = {16479.918384, 14110.929633},
//    // X : visibleRect.w = dkMapViewController.map_visibleRect_padding_left : CGRectGetWidth(dkMapViewController.map.frame)
//    CGFloat mapPoint_padding_left = (visibleRect.size.width * dkMapViewController.map_visibleRect_padding_left) / CGRectGetWidth(dkMapViewController.map.frame);
//    CGFloat mapPoint_padding_top = (visibleRect.size.height * dkMapViewController.map_visibleRect_padding_top) / CGRectGetHeight(dkMapViewController.map.frame);
//    CGFloat left_padding = mapPoint_padding_left + margin;
//    CGFloat top_padding = mapPoint_padding_top + margin;
//    
//    
////    MKMapPoint mapPoint = MKMapPointMake(margin, 0);
////    CLLocationCoordinate2D mapPointCoordinate = MKCoordinateForMapPoint(mapPoint);
////    CGPoint pointAsCGPoint = [dkMapViewController.map convertCoordinate: mapPointCoordinate toPointToView:dkMapViewController.map];
////    CGFloat marginPoint = pointAsCGPoint.x;
////    CGFloat left_padding = appDelegate.menuViewController.dkMapViewController.map_visibleRect_padding_left + marginPoint;
////    CGFloat top_padding = appDelegate.menuViewController.dkMapViewController.map_visibleRect_padding_top + marginPoint;
//    
//    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(coordinate_NW);
//    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(coordinate_SE);
////    MKMapRect targetMapRectWithMargin = MKMapRectMake(topLeftMapPoint.x - margin,
////                                                      topLeftMapPoint.y - margin,
////                                                      fabs(bottomRightMapPoint.x - topLeftMapPoint.x) + margin * 2,
////                                                      fabs(bottomRightMapPoint.y - topLeftMapPoint.y) + margin * 2);
//    
//    
//    MKMapPoint centerMapPoint = MKMapPointMake(topLeftMapPoint.x + (bottomRightMapPoint.x - topLeftMapPoint.x) * 0.5,
//                                               topLeftMapPoint.y + (bottomRightMapPoint.y - topLeftMapPoint.y) * 0.5);
//    //CLLocationCoordinate2D centerMap_coord = MKCoordinateForMapPoint(centerMapPoint);
//    
//    
//    CGFloat targetMapRectWidth = fabs(bottomRightMapPoint.x - topLeftMapPoint.x) + left_padding * 2;
//    CGFloat targetMapRectHeight = fabs(bottomRightMapPoint.y - topLeftMapPoint.y) + top_padding * 2;
//    CGFloat targetMapRectAspect = targetMapRectWidth / targetMapRectHeight;
//    CGFloat visibleRectAspect = visibleRect.size.width / visibleRect.size.height;
//    if (targetMapRectAspect > visibleRectAspect) {
//        // visibleRectより横長のため、targetMapRectWidth を採用する、targetMapRectHeightをもとめる
//        // targetMapRectWidth : H = visibleRect.size.width : visibleRect.size.height
//        // H = targetMapRectWidth * visibleRect.size.height / visibleRect.size.width;
//        targetMapRectHeight = targetMapRectWidth * visibleRect.size.height / visibleRect.size.width;
//    } else {
//        // visibleRectより縦長のため、targetMapRectHeight を採用するため、targetMapRectWidthをもとめる
//        // W : targetMapRectHeight = visibleRect.size.width : visibleRect.size.height
//        // W = targetMapRectHeight * visibleRect.size.width / visibleRect.size.height;
//        targetMapRectWidth = targetMapRectHeight * visibleRect.size.width / visibleRect.size.height;
//    }
//    
//    
//    MKMapRect targetMapRectWithMargin = MKMapRectMake(centerMapPoint.x - (targetMapRectWidth * 0.5),
//                                                      centerMapPoint.y - (targetMapRectHeight * 0.5),
//                                                      targetMapRectWidth,
//                                                      targetMapRectHeight);
//    
//    //NSStringFromMKMapRect(targetMapRectWithMargin);
//    //CLLocationCoordinate2D targetMap_coord_NW = MKCoordinateForMapPoint(MKMapPointMake(targetMapRectWithMargin.origin.x, targetMapRectWithMargin.origin.y));
//    //CLLocationCoordinate2D targetMap_coord_SE = MKCoordinateForMapPoint(MKMapPointMake(targetMapRectWithMargin.origin.x + targetMapRectWithMargin.size.width, targetMapRectWithMargin.origin.y + targetMapRectWithMargin.size.height));
//    //LOG(@"targetMap_coord_NW.latitude = %f / targetMap_coord_NW.longitude = %f", targetMap_coord_NW.latitude, targetMap_coord_NW.longitude);
//    //LOG(@"targetMap_coord_SE.latitude = %f / targetMap_coord_SE.longitude = %f", targetMap_coord_SE.latitude, targetMap_coord_SE.longitude);
//    
//    return targetMapRectWithMargin;
//    
//}
//
//+ (NSString *)getDocNameOfLocalMapInfo:(NSString *)path {
//    
//    if (path == nil) {
//        return nil;
//    }
//    
//    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
//        return nil;
//    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//    NSString *docName = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"docName"];
//    return docName;
//}
//
//+ (NSString *)getStatusOfLocalMapInfo:(NSString *)path {
//    
//    if (path == nil) {
//        return nil;
//    }
//    
//    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
//        return nil;
//    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//    NSString *status = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"status"];
//    return status;
//}
//
//+ (NSString *)getLocalImagesPathOfLocalMapInfo:(NSString *)path {
//    LOG_CURRENT_METHOD;
//    
//    if (path == nil) {
//        return nil;
//    }
//    
//    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
//        return nil;
//    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//    NSString *localImagesPath = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"localImagesPath"];
//    return localImagesPath;
//}
//
//+ (kMapType)getMapTypeOfLocalMapInfo:(NSString *)path {
//    if (path == nil) {
//        return nil;
//    }
//    
//    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
//        return nil;
//    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//    NSString *mapTypeString = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"mapType"];
//    kMapType mapType = std;
//    if ([mapTypeString compare:String_MapType_std] == NSOrderedSame) {
//        mapType = std;
//    } else if ([mapTypeString compare:String_MapType_pale] == NSOrderedSame) {
//        mapType = pale;
////    } else if ([mapTypeString compare:String_MapType_blank] == NSOrderedSame) {
////        mapType = blank;
////    } else if ([mapTypeString compare:String_MapType_relief] == NSOrderedSame) {
////        mapType = relief;
////    } else if ([mapTypeString compare:String_MapType_ort] == NSOrderedSame) {
////        mapType = ort;
////    } else if ([mapTypeString compare:String_MapType_english] == NSOrderedSame) {
////        mapType = english;
//    } else if ([mapTypeString compare:String_MapType_openstreetmap] == NSOrderedSame) {
//        mapType = openstreetmap;
//    } else {
//        mapType = std;
//    }
//    
//    return mapType;
//}
//
//+ (BOOL)getFlag2500OfLocalMapInfo:(NSString *)path {
//    if (path == nil) {
//        return NO;
//    }
//    
//    if ([path compare:DEFAULT_CURRENT_LOCALMAP] == NSOrderedSame) {
//        return NO;
//    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//    
//    NSString *flag2500 = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"flag2500"];
//    if ([flag2500 compare:@"YES"] == NSOrderedSame) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//+ (void)changeValueLocalMapInfo:(NSString *)path
//                        docName:(NSString *)newdocName
//                        status:(NSString *)newstatus
//{
//    //LOG_CURRENT_METHOD;
//    
//    if ((newdocName == nil) && (newstatus == nil)) {
//        return;
//    }
//    
////    NSFileManager* fm = [NSFileManager defaultManager];
////    if ( ![fm fileExistsAtPath:path] ) {
////        //LOG(@"path %@ が存在しない", path);
////        return;
////    } else {
////        //LOG(@"path %@ が存在する", path);
////    }
//    
//    NSDictionary *localMapDic = [[self class] getLocalMapInfoDic:path];
//
//    NSString *docName = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"docName"];
//    NSString *mapType = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"mapType"];
//    NSString *flag2500 = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"flag2500"];
//    NSString *localImagesPath = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"localImagesPath"];
//    NSString *status = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"status"];
//    NSString *creationDate = (NSString *)[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"creationDate"];
//    
//    NSArray *coordinates = (NSArray *)[[[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"coordinates"] objectAtIndex:0];
//    //LOG(@"coordinates = %@", [coordinates description]);
//    //LOG(@"coordinatesArray[0] = %@", [coordinatesArray objectAtIndex:0]);
//    
//    CLLocationCoordinate2D coordinate_NW = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:0] objectAtIndex:0] doubleValue]);
//    CLLocationCoordinate2D coordinate_SW = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:1] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:1] objectAtIndex:0] doubleValue]);
//    CLLocationCoordinate2D coordinate_SE = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:2] objectAtIndex:0] doubleValue]);
//    CLLocationCoordinate2D coordinate_NE = CLLocationCoordinate2DMake([(NSString *)[[coordinates objectAtIndex:3] objectAtIndex:1] doubleValue],
//                                                                      [(NSString *)[[coordinates objectAtIndex:3] objectAtIndex:0] doubleValue]);
//    
//    //LOG(@"coordinate_NW.lat = %f / coordinate_NW.lon = %f", coordinate_NW.latitude, coordinate_NW.longitude);
//    //LOG(@"coordinate_SW.lat = %f / coordinate_SW.lon = %f", coordinate_SW.latitude, coordinate_SW.longitude);
//    //LOG(@"coordinate_SE.lat = %f / coordinate_SE.lon = %f", coordinate_SE.latitude, coordinate_SE.longitude);
//    //LOG(@"coordinate_NE.lat = %f / coordinate_NE.lon = %f", coordinate_NE.latitude, coordinate_NE.longitude);
//    
//    
//    NSString *new_docName = newdocName;
//    NSString *new_mapType = mapType;
//    NSString *new_status = newstatus;
//    
//    if (new_docName == nil) {
//        new_docName = docName;
//    }
//    
//    if (new_status == nil) {
//        new_status = status;
//    }
//    
//    // lastModifiedDate更新のUTCを取得
//    
//    //NSString *newlastModifiedDate = [NSDate getUTCFromDate:[NSDate date] withFormat:NSLocalizedString(@"DateFormat.year.month.day.hour.minute.sec_UTC_Style", nil)];
//    NSString *templatePath = [[NSBundle mainBundle] pathForResource:DKMapDataJSON_Template ofType:@"txt"];
//    NSString *mapDataJSON_Template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSString *geoJSON = [[NSString alloc] initWithFormat:mapDataJSON_Template,
//                         new_docName,
//                         new_mapType,
//                         localImagesPath,
//                         flag2500,
//                         new_status,
//                         //newlastModifiedDate,
//                         creationDate,
//                         coordinate_NW.longitude,
//                         coordinate_NW.latitude,
//                         coordinate_SW.longitude,
//                         coordinate_SW.latitude,
//                         coordinate_SE.longitude,
//                         coordinate_SE.latitude,
//                         coordinate_NE.longitude,
//                         coordinate_NE.latitude,
//                         coordinate_NW.longitude,
//                         coordinate_NW.latitude
//                         ];
//    
//    NSFileManager* fm = [NSFileManager defaultManager];
//    if ([fm fileExistsAtPath:path]) {
//        //LOG(@"path %@ が存在する", path);
//        NSError *error;
//        BOOL result = [fm removeItemAtPath:path error:&error];
//        if (result) {
//            //LOG(@"ファイルの削除に成功：%@", path);
//        } else {
//            //LOG(@"ファイルの削除に失敗：%@", error.description);
//        }
//    }
//    
//    // 新規ファイル名のPath
//    if ( ![fm fileExistsAtPath:path] ) {
//        //LOG(@"重複なし");
//        // 空のファイルを作成する
//        BOOL result = [fm createFileAtPath:path contents:[NSData data] attributes:nil];
//        if (!result) {
//            //LOG(@"ファイルの作成に失敗");
//        } else {
//            //LOG(@"ファイルの作成に成功");
//        }
//    }
//    
//    // self.geoJSONFileStringを書き込む処理
//    // ファイルハンドルを作成する
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
//    if (!fileHandle) {
//        //LOG(@"ファイルハンドルの作成に失敗");
//        
//    }
//    
////    NSData *dataGeoJSON = [NSData dataWithBytes:geoJSON.UTF8String
////                                         length:[geoJSON lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
//    
//    NSData *dataGeoJSON = [geoJSON dataUsingEncoding:NSUTF8StringEncoding];
//    
//    // ファイルに書き込む
//    [fileHandle writeData:dataGeoJSON];
//    [fileHandle synchronizeFile];
//    
//    // ファイルを閉じる
//    [fileHandle closeFile];
//    //LOG(@"ファイルの書き込みが完了");
//}
//
//+ (void)deleteLocalMapData:(NSString *)filePath {
//    LOG_CURRENT_METHOD;
//
//    NSFileManager* fm = [NSFileManager defaultManager];
//    NSError *error;
//    //LOG(@"filePath = %@", filePath);
//    // /var/mobile/Containers/Data/Application/054EEA70-23C0-4F2D-ABCD-485237B6A0C5/Documents/UserDatas/地図データ/京都/あ.localmap
//    if ([fm fileExistsAtPath:filePath]) {
//        
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        
//        //LOG(@"地図データファイルが存在しているので、localImagesPath を取り出す");
//        NSDictionary *localMapDic = [Global getLocalMapInfoDic:filePath];
//        //LOG(@"localMapDic = %@", [localMapDic description]);
//        
//        // DKMapDataPolygon の削除処理
//        [appDelegate.dkMapViewController removeMapDataPolygonByFilePath:filePath];
//        
//        NSString *localImagesPath = [[[[localMapDic objectForKey:@"features"] objectAtIndex:0] objectForKey:@"properties"] objectForKey:@"localImagesPath"];
//        //LOG(@"localImagesPath = %@", localImagesPath);
//        ///Documents/Tiles/6B4E9307-9EA4-405C-AB81-2A409AD670B2/
//        
//        if (localImagesPath != nil) {
//            NSString *pathOflocalImagesTarget = [Global getLocalStorageLocalImagePath:[localImagesPath stringByReplacingOccurrencesOfString:@"/Documents/" withString:@""]];
//            // /var/mobile/Containers/Data/Application/CA8EBA1D-FEC0-4C89-9BBB-3621F345C35D/Documents
//            
//            //LOG(@"pathOflocalImagesTarget = %@", pathOflocalImagesTarget);
//            ///var/mobile/Containers/Data/Application/054EEA70-23C0-4F2D-ABCD-485237B6A0C5/Documents/Tiles/6B4E9307-9EA4-405C-AB81-2A409AD670B2
//            
//            BOOL isDirectory = NO;
//            if ([fm fileExistsAtPath:pathOflocalImagesTarget isDirectory:&isDirectory]) {
//                if (isDirectory) {
//                    //LOG(@"localImagesPathから取り出した%@ はタイル画像を保存するディレクトリなので削除", pathOflocalImagesTarget);
//                    BOOL resultOfLocalImagesTarget = [fm removeItemAtPath:pathOflocalImagesTarget error:&error];
//                    if (resultOfLocalImagesTarget) {
//                        //LOG(@"タイル画像を保存するディレクトリの削除に成功：%@", pathOflocalImagesTarget);
//                        
//                        BOOL result = [fm removeItemAtPath:filePath error:&error];
//                        if (result) {
//                            LOG(@"ファイルの削除に成功：%@", filePath);
//                        } else {
//                            LOG(@"ファイルの削除に失敗：%@", error.description);
//                        }
//                        
//                    } else {
//                        LOG(@"タイル画像を保存するディレクトリの削除に失敗：%@", error.description);
//                    }
//                }
//            } else {
//                //LOG(@"タイル画像を保存するディレクトリが存在していない");
//                BOOL result = [fm removeItemAtPath:filePath error:&error];
//                if (result) {
//                    LOG(@"ファイルの削除に成功：%@", filePath);
//                    [appDelegate updateAndSaveCashFileInfo];
//                } else {
//                    LOG(@"ファイルの削除に失敗：%@", error.description);
//                }
//            }
//        } else {
//            BOOL result = [fm removeItemAtPath:filePath error:&error];
//            if (result) {
//                LOG(@"ファイルの削除に成功：%@", filePath);
//                [appDelegate updateAndSaveCashFileInfo];
//            } else {
//                LOG(@"ファイルの削除に失敗：%@", error.description);
//            }
//        }
//        
//    }
//}
//
//+ (void)dataMapDataCheckAndRemove {
//    //LOG_CURRENT_METHOD;
//    //LOG(@" ********** dataMapDataCheckAndRemove START ********** ");
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    // overlaidMapDatas のファイル存在をチェック
//    NSMutableArray *targetArray = [NSMutableArray new];
//
//    //LOG(@"appDelegate.overlaidKMZsArray = %@", [appDelegate.overlaidKMZsArray description]);
//    //LOG(@"appDelegate.overlaidMapDatasArray = %@", [appDelegate.overlaidMapDatasArray description]);
//    
//    for (id obj in appDelegate.overlaidMapDatasArray) {
//        
//        if ([obj isKindOfClass:DKMapDataPolygon.class]) {
//            DKMapDataPolygon *mapDataPolygon = (DKMapDataPolygon *)obj;
//            
//            NSString *mapDataPath = [[[Global getDocumentPath] stringByReplacingOccurrencesOfString:@"/Documents" withString:@""] stringByAppendingString:[Global getFilePathFromDocumentsString:mapDataPolygon.filepath]];
//            
//            //LOG(@"mapDataPath = %@", mapDataPath);
//            
//            NSFileManager* fm = [NSFileManager defaultManager];
//            if ( ![fm fileExistsAtPath:mapDataPath] )
//            {
//                //LOG(@"mapDataPath = %@ がないぜよ！！！その場合は、remove", mapDataPath);
//                
//                if (mapDataPolygon == [appDelegate.activeMapDatasArray lastObject]) {
//                    //LOG(@"アクティブな地図データを非アクティブにする処理");
//                    mapDataPolygon.activeFlag = NO;
//                    mapDataPolygon.nameAnnotation.activeFlag = mapDataPolygon.activeFlag;
//                    [appDelegate.activeMapDatasArray removeAllObjects];
//                    
//                    //LOG(@"MMM 777");
//                    appDelegate.dkMapViewController.currentLocalMapFile = DEFAULT_CURRENT_LOCALMAP;
//                }
//                
//                //[appDelegate.overlaidMapDatasArray removeObject:mapDataPolygon];
//                mapDataPolygon.nameAnnotation.mapDataNameAnnotationView.clearFlag = YES;
//                
//                [appDelegate.dkMapViewController mainThread_removeAnnotation:mapDataPolygon.nameAnnotation];
//                [appDelegate.dkMapViewController mainThread_removeOverlay:mapDataPolygon];
//                
//                mapDataPolygon.nameAnnotation.mapDataNameAnnotationView = nil;
//                mapDataPolygon.nameAnnotation = nil;
//                //mapDataPolygon = nil;
//                
//                [targetArray addObject:mapDataPolygon];
//                
//                //[appDelegate.menuViewController.dkMapViewController removeMapDataPolygonByFilePath:mapDataPolygon.filepath];
//            } else {
//                //LOG(@"mapDataPath = %@ があるぜよ！！！その場合は、何もしない", mapDataPath);
//            }
//        }
//    }
//    
//    [appDelegate.overlaidMapDatasArray removeObjectsInArray:targetArray];
//    //LOG(@" ********** dataMapDataCheckAndRemove END ********** ");
//    
//    //LOG(@"appDelegate.overlaidKMZsArray = %@", [appDelegate.overlaidKMZsArray description]);
//    //LOG(@"appDelegate.overlaidMapDatasArray = %@", [appDelegate.overlaidMapDatasArray description]);
//    
//}

@end
