//
//  GameBoardView.m
//  NumberGame
//
//  Created by Alen Chang on 14-4-28.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameBoardView.h"

#import <QuartzCore/QuartzCore.h>
#import "TileView.h"

#define PER_SQUARE_SLIDE_DURATION 0.15
#define SHOW_SQUARE_DURATION 0.15

@interface GameBoardView ()

@property (nonatomic, strong) NSMutableDictionary* boardTiles;

@property (nonatomic) NSUInteger dimension;

@property (nonatomic) CGFloat padding;

@end

@implementation GameBoardView

+ (instancetype)gameboardWithDimension:(NSUInteger)dimension
                             cellWidth:(CGFloat)width
                           cellPadding:(CGFloat)padding
                       backgroundColor:(UIColor*)backgroundColor
                       foregroundColor:(UIColor*)foregroundColor
{

    CGFloat sideLength = padding + dimension * (width + padding);
    GameBoardView* view = [[[self class] alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         sideLength,
                                                                         sideLength)];
    view.dimension = dimension;
    view.padding = padding;
    view.tileSideLength = width;
    [view setupBackgroundWithBackgroundColor:backgroundColor
                             foregroundColor:foregroundColor];
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    return self;
}

- (void)setupBackgroundWithBackgroundColor:(UIColor*)background
                           foregroundColor:(UIColor*)foreground
{
    self.backgroundColor = background;
    CGFloat xCursor = self.padding;
    CGFloat yCursor;
    for (NSInteger i = 0; i < self.dimension; i++) {
        yCursor = self.padding;
        for (NSInteger j = 0; j < self.dimension; j++) {
            // TODO: round corners?
            UIView* bkgndTile = [[UIView alloc] initWithFrame:CGRectMake(xCursor,
                                                                         yCursor,
                                                                         self.tileSideLength,
                                                                         self.tileSideLength)];

            bkgndTile.layer.cornerRadius = self.tileSideLength / 2.0f;
            bkgndTile.backgroundColor = foreground;
            [self addSubview:bkgndTile];
            yCursor += self.padding + self.tileSideLength;
        }
        xCursor += self.padding + self.tileSideLength;
    }
}

- (void)insertTileAtIndexPath:(NSIndexPath*)path
                    withValue:(NSUInteger)value
{
    if (!path
        || path.row >= self.dimension
        || path.section >= self.dimension
        || self.boardTiles[path]) {
        // Index path out of bounds, or there already is a tile
        return;
    }

    CGFloat x = self.padding + path.section * (self.tileSideLength + self.padding);
    CGFloat y = self.padding + path.row * (self.tileSideLength + self.padding);
    CGPoint position = CGPointMake(x, y);
    TileView* tile = [TileView tileForPosition:position
                                    sideLength:self.tileSideLength
                                         value:value];
    [self addSubview:tile];
    self.layer.cornerRadius = 50;
    self.boardTiles[path] = tile;
    // TODO: Animation:
    CGRect originalTileFrame = tile.frame;

    tile.frame = CGRectMake(position.x + CGRectGetWidth(originalTileFrame) / 2,
                            position.y + CGRectGetWidth(originalTileFrame) / 2,
                            0, 0);
    tile.alpha = 0.0f;
    [UIView animateWithDuration:SHOW_SQUARE_DURATION
                     animations:^{
                         tile.frame = originalTileFrame;
                         tile.alpha = 1.0f;
                     }];
}

- (void)moveTileOne:(NSIndexPath*)startA
            tileTwo:(NSIndexPath*)startB
        toIndexPath:(NSIndexPath*)end
          withValue:(NSUInteger)value
{
    if (!startA || !startB || !self.boardTiles[startA] || !self.boardTiles[startB]
        || end.row >= self.dimension
        || end.section >= self.dimension) {
        NSAssert(NO, @"Invalid two-tile move and merge");
        return;
    }
    TileView* tileA = self.boardTiles[startA];
    TileView* tileB = self.boardTiles[startB];

    CGFloat x = self.padding + end.section * (self.tileSideLength + self.padding);
    CGFloat y = self.padding + end.row * (self.tileSideLength + self.padding);
    CGRect finalFrame = tileA.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;

    // Don't perform update after animation
    [self.boardTiles removeObjectForKey:startA];
    [self.boardTiles removeObjectForKey:startB];
    self.boardTiles[end] = tileA;

    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION * 1)
        animations:^{
                         tileA.frame = finalFrame;
                         tileB.frame = finalFrame;
                         tileB.alpha = 0.5f;
        }
        completion:^(BOOL finished) {
                         tileA.tileValue = value;
                         [tileB removeFromSuperview];
        }];
}

// Move a single tile onto another tile (that stays stationary), merging the two
- (void)moveTileAtIndexPath:(NSIndexPath*)start
                toIndexPath:(NSIndexPath*)end
                  withValue:(NSUInteger)value
{
    if (!start || !end || !self.boardTiles[start]
        || end.row >= self.dimension
        || end.section >= self.dimension) {
        NSAssert(NO, @"Invalid one-tile move and merge");
        return;
    }
    TileView* tile = self.boardTiles[start];
    TileView* endTile = self.boardTiles[end];
    //    NSInteger distance;
    //    if (start.row == end.row) {
    //        // Move up and down
    //        distance = abs(start.section - end.section);
    //    }
    //    else if (start.section == end.section) {
    //        // Move left and right
    //        distance = abs(start.row - end.row);
    //    }
    //    else {
    //        NSAssert(NO, @"Invalid tile movement. Tried to move from %@ to %@", start, end);
    //    }

    // TODO: finalize animation
    CGFloat x = self.padding + end.section * (self.tileSideLength + self.padding);
    CGFloat y = self.padding + end.row * (self.tileSideLength + self.padding);
    CGRect finalFrame = tile.frame;
    finalFrame.origin.x = x;
    finalFrame.origin.y = y;

    // Update board state
    [self.boardTiles removeObjectForKey:start];
    self.boardTiles[end] = tile;

    [UIView animateWithDuration:(PER_SQUARE_SLIDE_DURATION * 1)
        animations:^{
                         tile.frame = finalFrame;
        }
        completion:^(BOOL finished) {
                         tile.tileValue = value;
                         [endTile removeFromSuperview];
        }];
}

- (NSMutableDictionary*)boardTiles
{
    if (!_boardTiles) {
        _boardTiles = [NSMutableDictionary dictionary];
    }
    return _boardTiles;
}

@end
