//
//  TileView.h
//  NumberGame
//
//  Created by Alen Chang on 14-4-28.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileView : UIView

@property (nonatomic) NSInteger tileValue;

+ (instancetype)tileForPosition:(CGPoint)position
                     sideLength:(CGFloat)side
                          value:(NSUInteger)value;

@end
