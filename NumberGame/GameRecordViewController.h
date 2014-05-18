//
//  GameRecordViewController.h
//  NumberGame
//
//  Created by Alen on 14-5-4.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameRecordViewController : UIViewController

@property (nonatomic, strong) NSMutableArray* bestScoreRecord;
@property (nonatomic, assign) NSInteger score;

@end
