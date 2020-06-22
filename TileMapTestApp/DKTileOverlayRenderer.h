//
//  DKTileOverlayRenderer.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "Common_header.h"

NS_ASSUME_NONNULL_BEGIN

@class AppDelegate;
@interface DKTileOverlayRenderer : MKTileOverlayRenderer {
    
}

@property (assign, nonatomic) CGFloat                       tileAlpha;
@property (strong, nonatomic) AppDelegate                   *appDelegate;
@property (strong, nonatomic) NSOperationQueue              *operationQueue;
@property (nonatomic, assign) CGBlendMode                   blendMode;

@end

NS_ASSUME_NONNULL_END
