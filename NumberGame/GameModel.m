//
//  GameModel.m
//  NumberGame
//
//  Created by Alen Chang on 14-4-25.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameModel.h"

typedef enum {
    MergeTileModeEmpty = 0,
    MergeTileModeNoAction,
    MergeTileModeMove,
    MergeTileModeSingleCombine,
    MergeTileModeDoubleCombine
} MergeTileMode;

@interface GameModel ()

@property (nonatomic, weak) id<GameModelProtocol> delegate;

@property (nonatomic) NSUInteger dimension;
@property (nonatomic) NSUInteger winValue;
@property (nonatomic) NSInteger score;

@end

@interface Tile : NSObject

@property (nonatomic) BOOL empty;
@property (nonatomic) NSUInteger value;

+ (instancetype)emptyTile;

@end

@interface MergeTile : NSObject

@property (nonatomic) MergeTileMode mode;
@property (nonatomic) NSInteger originalIndexA;
@property (nonatomic) NSInteger originalIndexB;
@property (nonatomic) NSInteger value;

+ (instancetype)mergeTile;

@end

@interface MoveOrder ()

+ (instancetype)singleMoveOrderWithSource:(NSInteger)source destination:(NSInteger)destination newValue:(NSInteger)value;
+ (instancetype)doubleMoveOrderWithFirstSource:(NSInteger)source1 secondSource:(NSInteger)source2 destination:(NSInteger)destination newValue:(NSInteger)value;

@end

@implementation GameModel

+ (instancetype)gameModelWithDimension:(NSUInteger)dimension winValue:(NSUInteger)value delegate:(id<GameModelProtocol>)delegate
{
    GameModel* model = [GameModel new];
    model.dimension = dimension;
    model.winValue = value;
    model.delegate = delegate;

    return model;
}

#pragma mark - Insertion API

- (void)insertAtRandomLocationTileWithValue:(NSUInteger)value
{
    //检查游戏板是否已满
    BOOL emptySpotFound = NO; //是否找到空位置
    for (NSInteger i = 0; i < [self.gameState count]; i++) {
        if (((Tile*)self.gameState[i]).empty) {
            emptySpotFound = YES;
            break;
        }
    }

    if (!emptySpotFound) {
        //游戏板已满,不能插入数字方块
        return;
    }

    NSInteger row = 0;
    BOOL shouldExit = NO;

    while (YES) {
        row = arc4random_uniform(self.dimension);
        //检查该行是否有空列
        for (NSInteger i = 0; i < self.dimension; i++) {
            if ([self tileForIndexPath:[NSIndexPath indexPathForRow:row
                                                          inSection:i]].empty) {
                shouldExit = YES;
                break;
            }
        }

        if (shouldExit) {
            break;
        }
    }

    NSInteger column = 0;
    shouldExit = NO;
    while (YES) {
        column = arc4random_uniform(self.dimension);
        if ([self tileForIndexPath:[NSIndexPath indexPathForRow:row
                                                      inSection:column]].empty) {
            shouldExit = YES;
            break;
        }
        if (shouldExit) {
            break;
        }
    }

    [self insertTileWithValue:value
                  atIndexPath:[NSIndexPath indexPathForRow:row
                                                 inSection:column]];
}

//插入一个数字方块
- (void)insertTileWithValue:(NSUInteger)value atIndexPath:(NSIndexPath*)path
{
    if (![self tileForIndexPath:path].empty) {
        return;
    }
    Tile* tile = [self tileForIndexPath:path];
    tile.value = value;
    tile.empty = NO;
    [self.delegate insertTileAtIndexPath:path
                                   value:value];
}

#pragma mark - Movement API

//从四个方向中运行一个用户移动
- (BOOL)performMoveInDirection:(MoveDirection)direction
{
    switch (direction) {
    case MoveDirectionUp:
        return [self performUpMove];
    case MoveDirectionDown:
        return [self performDownMove];
    case MoveDirectionLeft:
        return [self performLeftMove];
    case MoveDirectionRight:
        return [self performRightMove];
    }
}

- (BOOL)performUpMove
{
    BOOL atLeastOneMove = NO;

    //从左至右检查每列 ([]-->[]-->[])
    for (NSInteger column = 0; column < self.dimension; column++) {
        NSMutableArray* thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = 0; row < self.dimension; row++) {
            [thisColumnTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row
                                                                                 inSection:column]]];
        }
        NSArray* ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i = 0; i < [ordersArray count]; i++) {
                MoveOrder* order = ordersArray[i];
                if (order.doubleMove) {
                    //更新里面的模型
                    NSIndexPath* source1Path = [NSIndexPath indexPathForRow:order.source1
                                                                  inSection:column];
                    NSIndexPath* source2Path = [NSIndexPath indexPathForRow:order.source2
                                                                  inSection:column];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:order.destination
                                                                      inSection:column];

                    Tile* source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    Tile* source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == source1Tile.value * 2
                        && order.value == source2Tile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                } else {
                    //更新里面的模型
                    NSIndexPath* sourcePath = [NSIndexPath indexPathForRow:order.source1
                                                                 inSection:column];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:order.destination
                                                                      inSection:column];

                    Tile* sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == sourceTile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performDownMove
{
    BOOL atLeastOneMove = NO;

    //从左至右检查每列 ([]-->[]-->[])
    for (NSInteger column = 0; column < self.dimension; column++) {
        NSMutableArray* thisColumnTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger row = (self.dimension - 1); row >= 0; row--) {
            [thisColumnTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row
                                                                                 inSection:column]]];
        }
        NSArray* ordersArray = [self mergeGroup:thisColumnTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i = 0; i < [ordersArray count]; i++) {
                MoveOrder* order = ordersArray[i];
                NSInteger dim = self.dimension - 1;
                if (order.doubleMove) {
                    //更新里面的模型
                    NSIndexPath* source1Path = [NSIndexPath indexPathForRow:(dim - order.source1)
                                                                  inSection:column];
                    NSIndexPath* source2Path = [NSIndexPath indexPathForRow:(dim - order.source2)
                                                                  inSection:column];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination)
                                                                      inSection:column];

                    Tile* source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    Tile* source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == source1Tile.value * 2
                        && order.value == source2Tile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                } else {
                    //更新里面的模型
                    NSIndexPath* sourcePath = [NSIndexPath indexPathForRow:(dim - order.source1)
                                                                 inSection:column];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:(dim - order.destination)
                                                                      inSection:column];

                    Tile* sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == sourceTile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performLeftMove
{
    BOOL atLeastOneMove = NO;

    //从上到下检查每行 ([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row < self.dimension; row++) {
        NSMutableArray* thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = 0; column < self.dimension; column++) {
            [thisRowTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row
                                                                              inSection:column]]];
        }
        NSArray* ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            atLeastOneMove = YES;
            for (NSInteger i = 0; i < [ordersArray count]; i++) {
                MoveOrder* order = ordersArray[i];
                if (order.doubleMove) {
                    //更新里面的模型
                    NSIndexPath* source1Path = [NSIndexPath indexPathForRow:row
                                                                  inSection:order.source1];
                    NSIndexPath* source2Path = [NSIndexPath indexPathForRow:row
                                                                  inSection:order.source2];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:row
                                                                      inSection:order.destination];

                    Tile* source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    Tile* source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == source1Tile.value * 2
                        && order.value == source2Tile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                } else {
                    //更新里面的模型
                    NSIndexPath* sourcePath = [NSIndexPath indexPathForRow:row
                                                                 inSection:order.source1];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:row
                                                                      inSection:order.destination];

                    Tile* sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == sourceTile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

- (BOOL)performRightMove
{
    BOOL atLeastOneMove = NO;

    //从上至下检查每行([TTT] --> [---] --> [____])
    for (NSInteger row = 0; row < self.dimension; row++) {
        NSMutableArray* thisRowTiles = [NSMutableArray arrayWithCapacity:self.dimension];
        for (NSInteger column = (self.dimension - 1); column >= 0; column--) {
            [thisRowTiles addObject:[self tileForIndexPath:[NSIndexPath indexPathForRow:row
                                                                              inSection:column]]];
        }
        NSArray* ordersArray = [self mergeGroup:thisRowTiles];
        if ([ordersArray count] > 0) {
            NSInteger dim = self.dimension - 1;
            atLeastOneMove = YES;
            for (NSInteger i = 0; i < [ordersArray count]; i++) {
                MoveOrder* order = ordersArray[i];
                if (order.doubleMove) {
                    //更新里面的模型
                    NSIndexPath* source1Path = [NSIndexPath indexPathForRow:row
                                                                  inSection:(dim - order.source1)];
                    NSIndexPath* source2Path = [NSIndexPath indexPathForRow:row
                                                                  inSection:(dim - order.source2)];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:row
                                                                      inSection:(dim - order.destination)];

                    Tile* source1Tile = [self tileForIndexPath:source1Path];
                    source1Tile.empty = YES;
                    Tile* source2Tile = [self tileForIndexPath:source2Path];
                    source2Tile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == source1Tile.value * 2
                        && order.value == source2Tile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileOne:source1Path
                                       tileTwo:source2Path
                                   toIndexPath:destinationPath
                                      newValue:order.value];
                } else {
                    //更新里面的模型
                    NSIndexPath* sourcePath = [NSIndexPath indexPathForRow:row
                                                                 inSection:(dim - order.source1)];
                    NSIndexPath* destinationPath = [NSIndexPath indexPathForRow:row
                                                                      inSection:(dim - order.destination)];

                    Tile* sourceTile = [self tileForIndexPath:sourcePath];
                    sourceTile.empty = YES;
                    Tile* destinationTile = [self tileForIndexPath:destinationPath];
                    destinationTile.empty = NO;
                    destinationTile.value = order.value;

                    if (order.value == sourceTile.value * 2) {
                        self.score = self.score + order.value;
                        [self.delegate newScore:self.score];
                    }

                    //更新委托
                    [self.delegate moveTileFromIndexPath:sourcePath
                                             toIndexPath:destinationPath
                                                newValue:order.value];
                }
            }
        }
    }
    return atLeastOneMove;
}

#pragma mark - Game State API

- (BOOL)userHasLost
{
    for (NSInteger i = 0; i < [self.gameState count]; i++) {
        if (((Tile*)self.gameState[i]).empty) {
            //如果用户输了游戏板必须填满
            return NO;
        }
    }
    //每个数字方块和它右边和下边的方块比较值(如果存在的话)
    for (NSInteger i = 0; i < self.dimension; i++) {
        for (NSInteger j = 0; j < self.dimension; j++) {
            Tile* tile = [self tileForIndexPath:[NSIndexPath indexPathForRow:i
                                                                   inSection:j]];
            if (j != (self.dimension - 1)
                && tile.value == [self tileForIndexPath:[NSIndexPath indexPathForRow:i
                                                                           inSection:j + 1]].value) {
                return NO;
            }
            if (i != (self.dimension - 1)
                && tile.value == [self tileForIndexPath:[NSIndexPath indexPathForRow:i + 1
                                                                           inSection:j]].value) {
                return NO;
            }
        }
    }
    return YES;
}

//根据游戏板上已有数字判断下一次目标,然后设置对应label文字提示

//- (NSUInteger)currentBiggestNumber
//{
//    NSInteger goalScore = 0;
//    NSUInteger biggestNumber = 0;
//    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.gameState];
//    for (NSInteger j = 1; j <= [tempArray count]; j++) {
//
//        for (NSInteger i = 0; i < j; i++) {
//            if (i == [tempArray count] - 1) {
//                break;
//            }
//
//            NSUInteger v1 = ((Tile*)tempArray[i]).value;
//            NSUInteger v2 = ((Tile*)tempArray[i + 1]).value;
//
//            if (v1 > v2) {
//                [tempArray exchangeObjectAtIndex:i
//                               withObjectAtIndex:i + 1];
//            }
//        }
//    }
//    biggestNumber = ((Tile*)[tempArray lastObject]).value;
//
//    //    if (biggestNumber < 48) {
//    //        goalScore = 48;
//    //    }
//    //    else if (biggestNumber < 96) {
//    //        goalScore = 96;
//    //    }
//    //    else if (biggestNumber < 192) {
//    //        goalScore = 192;
//    //    }
//    //    else if (biggestNumber < 384) {
//    //        goalScore = 384;
//    //    }
//    //    else if (biggestNumber < 768) {
//    //        goalScore = 768;
//    //    }
//    //    else
//    if (biggestNumber < 1536) {
//        goalScore = 1536;
//    } else if (biggestNumber < 3072) {
//        goalScore = 3072;
//    } else if (biggestNumber < 6144) {
//        goalScore = 6144;
//    } else if (biggestNumber < 12288) {
//        goalScore = 12288;
//    }
//
//    return goalScore;
//}

- (BOOL)userHasWon
{
    for (NSInteger i = 0; i < [self.gameState count]; i++) {
        if (((Tile*)self.gameState[i]).value == self.winValue) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private Methods

- (Tile*)tileForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger idx = (indexPath.row * self.dimension + indexPath.section);
    if (idx >= [self.gameState count]) {
        return nil;
    }
    return self.gameState[idx];
}

- (void)setTile:(Tile*)tile forIndexPath:(NSIndexPath*)indexPath
{
    NSInteger idx = (indexPath.row * self.dimension + indexPath.section);
    if (!tile || idx >= [self.gameState count]) {
        return;
    }
    self.gameState[idx] = tile;
}

- (NSMutableArray*)gameState
{
    if (!_gameState) {
        _gameState = [NSMutableArray array];
        for (NSInteger i = 0; i < (self.dimension * self.dimension); i++) {
            [_gameState addObject:[Tile emptyTile]];
        }
    }
    return _gameState;
}

//从左合并一些目标,"Group"是一个包含数字块的数组
- (NSArray*)mergeGroup:(NSArray*)group
{
    NSInteger ctr = 0;
    //STEP 1:折叠所有数字块
    // e.g. |[2] [ ] [ ] [4]| 变成 [[2] [4]|
    //此时,数字块要么移动要么不移动,并且它们的值保持不变
    NSMutableArray* stack1 = [NSMutableArray array];
    for (NSInteger i = 0; i < self.dimension; i++) {
        Tile* tile = group[i];
        if (tile.empty) {
            //空的数字块,什么也不做
            continue;
        }
        MergeTile* mergeTile = [MergeTile mergeTile];
        mergeTile.originalIndexA = i;
        mergeTile.value = tile.value;
        if (i == ctr) {
            mergeTile.mode = MergeTileModeNoAction;
        } else {
            mergeTile.mode = MergeTileModeMove;
        }
        [stack1 addObject:mergeTile];
        ctr++;
    }
    if ([stack1 count] == 0) {
        //这个组没有数字块,什么也不做
        return nil;
    } else if ([stack1 count] == 1) {
        //这个组只有一个数字块,要么移动,要么不移动
        if (((MergeTile*)stack1[0]).mode == MergeTileModeMove) {
            // Tile moved. Add one move order.
            //数字块移动了,添加一个MoveOrder
            MergeTile* mTile = (MergeTile*)stack1[0];
            return @[
                [MoveOrder singleMoveOrderWithSource:mTile.originalIndexA
                                         destination:0
                                            newValue:mTile.value]
            ];
        } else {
            return nil;
        }
    }

    //STEP 2:从左开始,移动到右边,折叠数字块
    // e.g. |[8][8][4][2][2]| should become |[16][4][4]|
    // e.g. |[2][2][2]| should become |[4][2]|
    //此时,数字块可能是单独或者成双合并

    ctr = 0;
    BOOL priorMergeHasHappened = NO;
    NSMutableArray* stack2 = [NSMutableArray array];
    while (ctr < ([stack1 count] - 1)) {
        MergeTile* t1 = (MergeTile*)stack1[ctr];
        MergeTile* t2 = (MergeTile*)stack1[ctr + 1];
        if (t1.value == t2.value) {
            //合并这两个
            if (t1.mode == MergeTileModeNoAction && !priorMergeHasHappened) {
                priorMergeHasHappened = YES;
                //t1没有移动,但是t2合并到t1
                MergeTile* newT = [MergeTile mergeTile];
                newT.mode = MergeTileModeSingleCombine;
                newT.originalIndexA = t2.originalIndexA;
                newT.value = t1.value * 2;
                [stack2 addObject:newT];
            } else {
                //t1移动在先
                MergeTile* newT = [MergeTile mergeTile];
                newT.mode = MergeTileModeDoubleCombine;
                newT.originalIndexA = t1.originalIndexA;
                newT.originalIndexB = t2.originalIndexA;
                newT.value = t1.value * 2;
                [stack2 addObject:newT];
            }
            ctr += 2;
        } else {
            //t1被压入stack2中，无论是移动或无操作,该指针递增
            [stack2 addObject:t1];
            if ([stack2 count] - 1 != ctr) {
                t1.mode = MergeTileModeMove;
            }
            ctr++;
        }
        //补遗:
        if (ctr == [stack1 count] - 1) {
            //t1结束,需要像t1一样添加t2
            MergeTile* item = stack1[ctr];
            [stack2 addObject:item];
            if ([stack2 count] - 1 != ctr) {
                item.mode = MergeTileModeMove;
            }
        }
    }

    // STEP 3: 为这一回合改变的每个mergeTile创建移动move orders
    NSMutableArray* stack3 = [NSMutableArray new];
    for (NSInteger i = 0; i < [stack2 count]; i++) {
        MergeTile* mTile = stack2[i];
        switch (mTile.mode) {
        case MergeTileModeEmpty:
        case MergeTileModeNoAction:
            continue;
        case MergeTileModeMove:
        case MergeTileModeSingleCombine:
            //单独合并
            [stack3 addObject:[MoveOrder singleMoveOrderWithSource:mTile.originalIndexA
                                                       destination:i
                                                          newValue:mTile.value]];
            break;
        case MergeTileModeDoubleCombine:
            //双合并
            [stack3 addObject:[MoveOrder doubleMoveOrderWithFirstSource:mTile.originalIndexA
                                                           secondSource:mTile.originalIndexB
                                                            destination:i
                                                               newValue:mTile.value]];
            break;
        }
    }
    //返回最终的数组
    return [NSArray arrayWithArray:stack3];
}

@end

#pragma mark - MergeTile

@implementation MergeTile

+ (instancetype)mergeTile
{
    return [[self class] new];
}

- (NSString*)description
{
    NSString* modeStr;
    switch (self.mode) {
    case MergeTileModeEmpty:
        modeStr = @"Empty";
        break;
    case MergeTileModeNoAction:
        modeStr = @"NoAction";
        break;
    case MergeTileModeMove:
        modeStr = @"Move";
        break;
    case MergeTileModeSingleCombine:
        modeStr = @"SingleCombine";
        break;
    case MergeTileModeDoubleCombine:
        modeStr = @"DoubleCombine";
    }
    return [NSString stringWithFormat:@"MergeTile (mode: %@, source1: %d, source2: %d, value: %d)",
                                      modeStr, self.originalIndexA, self.originalIndexB, self.value];
}

@end

#pragma mark - MoveOrder

@implementation MoveOrder

+ (instancetype)singleMoveOrderWithSource:(NSInteger)source destination:(NSInteger)destination newValue:(NSInteger)value
{
    MoveOrder* order = [[self class] new];
    order.doubleMove = NO;
    order.source1 = source;
    order.destination = destination;
    order.value = value;
    return order;
}

+ (instancetype)doubleMoveOrderWithFirstSource:(NSInteger)source1
                                  secondSource:(NSInteger)source2
                                   destination:(NSInteger)destination
                                      newValue:(NSInteger)value
{
    MoveOrder* order = [[self class] new];
    order.doubleMove = YES;
    order.source1 = source1;
    order.source2 = source2;
    order.destination = destination;
    order.value = value;
    return order;
}

- (NSString*)description
{
    if (self.doubleMove) {
        return [NSString stringWithFormat:@"MoveOrder (double, source1: %d, source2: %d, destination: %d, value: %d)",
                                          self.source1, self.source2, self.destination, self.value];
    }
    return [NSString stringWithFormat:@"MoveOrder (single, source: %d, destination: %d, value: %d)",
                                      self.source1, self.destination, self.value];
}

@end

#pragma mark - Tile

//帮助类
@implementation Tile

+ (instancetype)emptyTile
{
    Tile* tile = [[self class] new];
    tile.empty = YES;
    tile.value = 0;
    return tile;
}

- (NSString*)description
{
    if (self.empty) {
        return @"Tile (empty)";
    }
    return [NSString stringWithFormat:@"Tile (value: %d)", self.value];
}

@end
