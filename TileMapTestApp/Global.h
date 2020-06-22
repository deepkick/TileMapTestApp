//
//  Global.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>
#import "Common_header.h"

#pragma mark - ログ
// ログ
#ifdef DEBUG
# define LOG(...) NSLog(__VA_ARGS__)
# define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
# define LOGING(...) NSLog(@"【%@/%@】%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __VA_ARGS__)
# define LOGING_DIC(...) LOGING([Global descriptionWithNSDictionary:__VA_ARGS__])
#else
# define LOG(...);
# define LOG_CURRENT_METHOD;
# define LOGING(...);
# define LOGING_DIC(...);
#endif

#pragma mark -国土地理院地図　デフォルト設定」関連
#define OPENSTREETMAP_BASE_URL                  @"https://tile.openstreetmap.org/{z}/{x}/{y}.png"
#define GSI_PALE_BASE_URL                       @"https://cyberjapandata.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png"


#define MAP_SIZE_RATIO_SCREEN                   1.0f
#define MAP_STD_OVERLAY_DEFAULT_ALPHA           1.0f

#define WHOLE_OF_JAPAN_MKMapRect_X          224576257
#define WHOLE_OF_JAPAN_MKMapRect_Y          93590725
#define WHOLE_OF_JAPAN_MKMapRect_W          22287854
#define WHOLE_OF_JAPAN_MKMapRect_H          23206634

#define MERCATOR_OFFSET 268435456 //16384の2乗
#define MERCATOR_RADIUS 85445659.44705395

#define GSI_MAPS_TILE_SIZE                  256.0
//#define GSI_MAPS_TILE_SIZE                  512.0
#define GSI_MAPS_TILE_SIZE_iPad             512.0
//#define GSI_MAPS_TILE_SIZE              256.0 * 0.2
//#define GSI_MAPS_TILE_NUM_ROW           7 // 1 or 3 or 5 or 7 or 9. 奇数
//#define GSI_MAPS_VIEW_SIZE              256.0 * GSI_MAPS_TILE_NUM_ROW // view のサイズ
#define GSI_MAPS_TILE_SIZE_Power            1 // (pow(2, この値) * 256)で、GSI_Map のタイルサイズ。0 で等倍。


#define MinZoomLevel                        4
#define MaxZoomLevel                        19

#define ZoomExponentConstant                22
#define ZoomLevelPlus2D                     2

#define MinZoomLevel_std                    MinZoomLevel
#define MinZoomLevel_pale                   MinZoomLevel

// 汎用地図として取得可能な最大ズーム値を指定
#define MaxZoomLevel_apple                  MaxZoomLevel
#define MaxZoomLevel_google                 MaxZoomLevel
#define MaxZoomLevel_openstreetmap          18
#define MaxZoomLevel_opencyclemap           18
#define MaxZoomLevel_mapbox                 19

// タイル画像として取得可能な最大ズーム値を指定
#define MaxZoomLevel_std                    18
#define MaxZoomLevel_pale                   18

#define DEFAULT_CURRENT_LOCALMAP                    @"NOTHING"

#define String_MapType_std                  @"std"
#define String_MapType_pale                 @"pale"
#define String_MapType_blank                @"blank"

#define String_MapType_apple                @"applemap"
#define String_MapType_google               @"googlemap"
#define String_MapType_openstreetmap        @"openstreetmap"
#define String_MapType_opencyclemap         @"opencyclemap"
#define String_MapType_mapboxStreets        @"mapboxStreets"
#define String_MapType_mapboxOutdoors       @"mapboxOutdoors"

#define String_MapType_relief               @"relief"
#define String_MapType_english              @"english"
#define String_MapType_ort                  @"ort"

#define String_MapOverlay_none              @"overlay_none"

#define OVER_TILE_MAX_ZOOMLEVEL             @"OVER_TILE_MAX_ZOOMLEVEL" // タイル画像の最最大ズーム値を超えた時に返す文字列

#define PNG_Extension               @".png"
#define JPG_Extension               @".jpg"

NS_ASSUME_NONNULL_BEGIN

@interface Global : NSObject {
    
}

#pragma mark - LocalMapInfo Methods
+ (NSDictionary *)getLocalMapInfoDic:(NSString *)path;
+ (MKMapRect)getMapRectOfLocalMapInfo:(NSString *)path margin:(CGFloat)margin;
+ (MKMapRect)getMapRectCoordinate_NW:(CLLocationCoordinate2D)coordinate_NW
                       Coordinate_SE:(CLLocationCoordinate2D)coordinate_SE
                              margin:(CGFloat)margin;
+ (NSString *)getDocNameOfLocalMapInfo:(NSString *)path;
//+ (NSString *)getLocalImagesPathOfLocalMapInfo:(NSString *)path;
+ (kMapType)getMapTypeOfLocalMapInfo:(NSString *)path;
+ (NSString *)getStatusOfLocalMapInfo:(NSString *)path;
+ (BOOL)getFlag2500OfLocalMapInfo:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
