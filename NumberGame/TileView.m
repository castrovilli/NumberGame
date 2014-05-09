//
//  TileView.m
//  NumberGame
//
//  Created by Alen Chang on 14-4-28.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "TileView.h"

@interface TileView ()

@property (nonatomic, readonly) UIColor* defaultNumberColor;
@property (nonatomic, strong) UILabel* numberLabel;

@property (nonatomic) NSUInteger value;

@end

@implementation TileView

+ (instancetype)tileForPosition:(CGPoint)position
                     sideLength:(CGFloat)side
                          value:(NSUInteger)value
{
    TileView* tile = [[[self class] alloc] initWithFrame:CGRectMake(position.x,
                                                                    position.y,
                                                                    side,
                                                                    side)];

    tile.tileValue = value;
    tile.value = value;
    return tile;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;

    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               frame.size.width,
                                                               frame.size.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                 size:22];
    ;
    label.layer.cornerRadius = frame.size.width / 2.0f;
    label.clipsToBounds = YES;

    [self addSubview:label];
    self.numberLabel = label;
    return self;
}

- (void)setTileValue:(NSInteger)tileValue
{
    _tileValue = tileValue;
    self.numberLabel.text = [@(tileValue) stringValue];

    self.numberLabel.backgroundColor = [self tileColorForValue:tileValue];
    self.numberLabel.textColor = [self numberColorForValue:tileValue];
    self.value = tileValue;
}

- (UIColor*)defaultNumberColor
{
    return [UIColor colorWithRed:0.0f / 255
                           green:114.0f / 255
                            blue:143.0f / 255
                           alpha:1.0];
}

- (UIColor*)tileColorForValue:(NSUInteger)value
{
    switch (value) {
    case 3:
        return [UIColor colorWithRed:232.0f / 255
                               green:251.0f / 255
                                blue:1.0f
                               alpha:1.0];
    case 6:
        return [UIColor colorWithRed:205.0f / 255
                               green:246.0f / 255
                                blue:1.0f
                               alpha:1.0f];
    case 12:
        return [UIColor colorWithRed:153.0f / 255
                               green:204.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    case 24:
        return [UIColor colorWithRed:131.0f / 255
                               green:174.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    case 48:
        return [UIColor colorWithRed:119.0f / 255
                               green:158.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    case 96:
        return [UIColor colorWithRed:82.0f / 255
                               green:109.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    case 192:
        return [UIColor colorWithRed:0.0f
                               green:114.0f / 255
                                blue:143.0f / 255
                               alpha:1.0f];
    case 384:
        return [UIColor colorWithRed:0.0f
                               green:143.0f / 255
                                blue:179.0f / 255
                               alpha:1.0f];
    case 768:
        return [UIColor colorWithRed:0.0f
                               green:182.0f / 255
                                blue:228.0f / 255
                               alpha:1.0f];
    case 1536:
        return [UIColor colorWithRed:0.0f
                               green:204.0f / 255
                                blue:1.0f
                               alpha:1.0f];
    case 3072:
        return [UIColor colorWithRed:141.0f / 255
                               green:47.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    case 6144:
        return [UIColor colorWithRed:1.0f
                               green:85.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    case 12288:
        return [UIColor colorWithRed:1.0f
                               green:150.0f / 255
                                blue:0.0f
                               alpha:1.0f];
    default:
        return [UIColor whiteColor];
    }
}

- (UIColor*)numberColorForValue:(NSUInteger)value
{
    switch (value) {
    case 3:
    case 6:
        return [self defaultNumberColor];
    default:
        return [UIColor whiteColor];
    }
}

@end
