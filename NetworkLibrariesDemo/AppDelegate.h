//
//  AppDelegate.h
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-10.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherEngine.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WeatherEngine *weatherEngine;

@end
