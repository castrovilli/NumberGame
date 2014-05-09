//
//  GameEndViewController.h
//  NumberGame
//
//  Created by Alen on 14-4-30.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameEndDelegate <NSObject>

- (void)shouldStartNewGame;

@end

@interface GameEndViewController : UIViewController

@property (nonatomic, assign) id<GameEndDelegate> delegate;

@property (nonatomic, assign) BOOL didWin;
@property (nonatomic, assign) NSInteger score;

@end
