//
//  GameBoardView.h
//  NumberGame
//
//  Created by Alen Chang on 14-4-28.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameBoardView : UIView

@property (nonatomic) CGFloat tileSideLength;

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                           cellPadding:(CGFloat)padding
                       backgroundColor:(UIColor*)backgroundColor
                       foregroundColor:(UIColor*)foregroundColor;

- (void)insertTileAtIndexPath:(NSIndexPath*)path
                    withValue:(NSUInteger)value;

- (void)moveTileOne:(NSIndexPath*)startA
            tileTwo:(NSIndexPath*)startB
        toIndexPath:(NSIndexPath*)end
          withValue:(NSUInteger)value;

- (void)moveTileAtIndexPath:(NSIndexPath*)start
                toIndexPath:(NSIndexPath*)end
                  withValue:(NSUInteger)value;

@end
