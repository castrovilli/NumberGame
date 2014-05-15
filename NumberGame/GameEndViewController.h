//
//  GameEndViewController.h
//  NumberGame
//
//  Created by Alen on 14-4-30.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameBoardView;

@protocol GameEndDelegate <NSObject>

- (void)shouldStartNewGame;

@end

@interface GameEndViewController : UIViewController

@property (nonatomic, assign) id<GameEndDelegate> delegate;

@property (nonatomic, assign) BOOL didWin;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) UIView* shareView;
@property (nonatomic, strong) UIView* recordView;

@end
