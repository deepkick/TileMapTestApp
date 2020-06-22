//
//  DKTileOverlayRenderer.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "DKTileOverlayRenderer.h"

@implementation DKTileOverlayRenderer

- (id)initWithTileOverlay:(MKTileOverlay *)overlay {
    //LOG_CURRENT_METHOD;
    if (self = [super initWithTileOverlay:overlay]) {
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //LOG(@"self.appDelegate = %@", self.appDelegate);
        self.tileAlpha = 1.0; // 0.75 // base map alpha
        self.blendMode = kCGBlendModeNormal;
    }
    return self;

}

@end
