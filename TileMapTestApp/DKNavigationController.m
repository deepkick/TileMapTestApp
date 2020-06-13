//
//  DKNavigationController.m
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import "DKNavigationController.h"

@interface DKNavigationController ()

@end

@implementation DKNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    //LOG_CURRENT_METHOD;
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.title = rootViewController.title;
        
//        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarImage"] forBarMetrics:UIBarMetricsDefault];
//        self.navigationBar.translucent = YES;
//        
//        // ----- 左上のメニューボタンは、ここに記述する START ----- //
//        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]
//                                           initWithImage:[UIImage imageNamed:BTN_MENU_IMAGE]
//                                                   style:UIBarButtonItemStylePlain
//                                                  target:self.menuViewController
//                                                  action:@selector(slide:)
//        ];
//        rootViewController.navigationItem.leftBarButtonItem = menuButton;
//        // ----- 左上のメニューボタンは、ここに記述する END ----- //
        
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MapTest";
}



@end
