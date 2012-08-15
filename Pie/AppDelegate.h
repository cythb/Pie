//
//  AppDelegate.h
//  Pie
//
//  Created by Haibo Tang on 12-8-14.
//  Copyright (c) 2012年 Haibo Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIWindow *_window;
    ViewController *_viewController;
}

@property (retain, nonatomic) UIWindow *window;

@property (retain, nonatomic) ViewController *viewController;

@end
