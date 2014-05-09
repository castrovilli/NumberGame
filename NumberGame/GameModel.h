//
//  GameModel.h
//  NumberGame
//
//  Created by Alen Chang on 14-4-25.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <Foundation/Foundation.h>

// 定义移动方向的枚举类型
typedef enum {
    MoveDirectionUp = 0,
    MoveDirectionDown,
    MoveDirectionLeft,
    MoveDirectionRight
} MoveDirection;

@protocol GameModelProtocol <NSObject>

- (void)playerLost;
- (void)playerWonWithTile:(NSIndexPath*)tilePath;
- (void)moveTileFromIndexPath:(NSIndexPath*)fromPath
                  toIndexPath:(NSIndexPath*)toPath
                     newValue:(NSUInteger)value;
- (void)moveTileOne:(NSIndexPath*)startA
            tileTwo:(NSIndexPath*)startB
        toIndexPath:(NSIndexPath*)end
           newValue:(NSUInteger)value;
- (void)insertTileAtIndexPath:(NSIndexPath*)path
                        value:(NSUInteger)value;
- (void)newScore:(NSInteger)score;

@end

@interface GameModel : NSObject

@property (nonatomic, strong) NSMutableArray* gameState;

+ (instancetype)gameModelWithDimension:(NSUInteger)dimension
                              winValue:(NSUInteger)value
                              delegate:(id<GameModelProtocol>)delegate;

- (void)insertAtRandomLocationTileWithValue:(NSUInteger)value;

- (void)insertTileWithValue:(NSUInteger)value
                atIndexPath:(NSIndexPath*)path;

- (BOOL)performMoveInDirection:(MoveDirection)direction;

- (BOOL)userHasLost;
- (BOOL)userHasWon;
- (NSUInteger)currentBiggestNumber;

#pragma mark - Test

- (NSArray*)mergeGroup:(NSArray*)group;

@end

@interface MoveOrder : NSObject

@property (nonatomic) NSInteger source1;
@property (nonatomic) NSInteger source2;
@property (nonatomic) NSInteger destination;
@property (nonatomic) BOOL doubleMove;
@property (nonatomic) NSInteger value;

@end
