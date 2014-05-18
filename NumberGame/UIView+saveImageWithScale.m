//
//  UIView+saveImageWithScale.m
//  NumberGame
//
//  Created by silence on 14-5-7.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "UIView+saveImageWithScale.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (saveImageWithScale)

- (UIImage*)saveImageWithScale:(float)scale
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, scale);

    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end
