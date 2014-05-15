//
//  AppDelegate.h
//  NumberGame
//
//  Created by Alen Chang on 14-4-25.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CJPAdController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
     CJPAdController *_adController;
}

@property (strong, nonatomic) UIWindow *window;

@end
