//
//  GameTeachViewController.h
//  NumberGame
//
//  Created by silence on 14-5-14.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameEndViewController.h"

@interface GameTeachViewController : UIViewController

@property (nonatomic, assign) id<GameEndDelegate> delegate;


@end
