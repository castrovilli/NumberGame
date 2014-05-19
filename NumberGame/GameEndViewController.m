//
//  GameEndViewController.m
//  NumberGame
//
//  Created by Alen on 14-4-30.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameEndViewController.h"
#import "UIView+saveImageWithScale.h"
#import "GameBoardView.h"

@interface GameEndViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel* winLabel;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton* replayButton;
@property (weak, nonatomic) IBOutlet UIButton* shareButton;
@property (nonatomic, strong) UIActivityViewController* activityViewController;
@property (nonatomic, strong) NSMutableArray* bestScoreRecord;


- (IBAction)replayGame:(id)sender;
- (IBAction)openShare:(id)sender;

@end

@implementation GameEndViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:232.0f / 255
                                                  green:251.0f / 255
                                                   blue:1.0f
                                                  alpha:1.0f]];

    self.winLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                         size:23];
    self.winLabel.textColor = [UIColor colorWithRed:136.0f / 255
                                              green:173.0f / 255
                                               blue:182.0f / 255
                                              alpha:1.0f];
    self.winLabel.text = self.didWin ? NSLocalizedString(@"You win!", @"您赢了!") : NSLocalizedString(@"You lose!", @"挑战失败!");
    self.winLabel.layer.cornerRadius = 5.0f;

    self.scoreLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                           size:23];
    self.scoreLabel.backgroundColor = [UIColor colorWithRed:0.0f
                                                      green:204.0f / 255
                                                       blue:1.0f
                                                      alpha:1.0];
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.text = [NSString stringWithFormat:@"%li", (long)self.score];
    self.scoreLabel.layer.cornerRadius = 60.0f;

    self.shareButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                       size:23];
    self.shareButton.backgroundColor = [UIColor colorWithRed:0.0f
                                                       green:204.0f / 255
                                                        blue:1.0f
                                                       alpha:1.0];
    self.shareButton.titleLabel.textColor = [UIColor whiteColor];
    self.shareButton.layer.cornerRadius = 5.0f;

    self.replayButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                        size:23];
    self.replayButton.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                        green:173.0f / 255
                                                         blue:182.0f / 255
                                                        alpha:1.0f];
    self.replayButton.titleLabel.textColor = [UIColor whiteColor];
    self.replayButton.layer.cornerRadius = 5.0f;
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)replayGame:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [self.delegate shouldStartNewGame];
}

- (IBAction)openShare:(id)sender
{

    //上架时添加产品ID
    UIImage* shareImage = [self.shareView saveImageWithScale:2.0f];
    NSString *str1 = NSLocalizedString(@"I scored", @"我在1536得了");
    NSString *str2 = NSLocalizedString(@"points at 1536, a game where you join numbers to score high! https://itunes.apple.com/app/2048-original-gameplay/id848513715",@"分,这个游戏规则为合并数字得到最高分! https://itunes.apple.com/app/2048-original-gameplay/id848513715");
    NSString *str3 = [str1 stringByAppendingFormat:@"%lu",(long)self.score];
    NSString *str4 = [str3 stringByAppendingString:str2];
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[
                                                                                             str4,
                                                                                             shareImage
                                                                                          ]
                                                                    applicationActivities:nil];
    [self presentViewController:self.activityViewController
                       animated:YES
                     completion:^{
         [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                     }];
}


- (void)saveBestScoreRecord
{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"bestScoreRecord"]) {
        self.bestScoreRecord = [[NSMutableArray alloc] init];
    } else {
        self.bestScoreRecord = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"bestScoreRecord"]];
        NSLog(@"从缓存初始化数组");
    }
    
    NSInteger pastScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
    UIImage* gameBoardImage = [self.recordView saveImageWithScale:2.0f];
    UIImage* shareImage = [self.shareView saveImageWithScale:2.0f];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths lastObject];
    NSData* gamedata = UIImagePNGRepresentation(gameBoardImage);
    NSData* sharedata = UIImagePNGRepresentation(shareImage);
    NSError* error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.score == pastScore) {
        
        NSString* boardname = [NSString stringWithFormat:@"Photo-%ld@2x.png", (long)self.score];
        NSString* sharename = [NSString stringWithFormat:@"Share-%ld@2x.png", (long)self.score];
        NSString* boardPath = [documentsDirectory stringByAppendingPathComponent:boardname];
        NSString* sharePath = [documentsDirectory stringByAppendingPathComponent:sharename];
        
        if ([self.bestScoreRecord count] < 3) {
            if (![gamedata writeToFile:boardPath
                               options:NSDataWritingAtomic
                                 error:&error]) {
                NSLog(@"Error writing file: %@", error);
            }
            
            if (![sharedata writeToFile:sharePath
                                options:NSDataWritingAtomic
                                  error:&error]) {
                NSLog(@"Error writing file: %@", error);
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } else {
            NSString* boardname = [NSString stringWithFormat:@"Photo-%ld@2x.png", (long)[self.bestScoreRecord[0] integerValue]];
            NSString* sharename = [NSString stringWithFormat:@"Share-%ld@2x.png", (long)[self.bestScoreRecord[0] integerValue]];
            NSString* boardPath = [documentsDirectory stringByAppendingPathComponent:boardname];
            NSString* sharePath = [documentsDirectory stringByAppendingPathComponent:sharename];
            
            if ([fileManager fileExistsAtPath:boardPath] && [fileManager fileExistsAtPath:sharePath]) {
                if (![fileManager removeItemAtPath:boardPath
                                             error:&error]) {
                    NSLog(@"Error removing file: %@", error);
                }
                if (![fileManager removeItemAtPath:sharePath
                                             error:&error]) {
                    NSLog(@"Error removing file: %@", error);
                }
            }
            
                 [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.bestScoreRecord removeObjectAtIndex:0];
            
            
            NSString* boardnameAdd = [NSString stringWithFormat:@"Photo-%ld@2x.png", (long)self.score];
            NSString* sharenameAdd = [NSString stringWithFormat:@"Share-%ld@2x.png", (long)self.score];
            NSString* boardPathAdd = [documentsDirectory stringByAppendingPathComponent:boardnameAdd];
            NSString* sharePathAdd = [documentsDirectory stringByAppendingPathComponent:sharenameAdd];
        
            
            if (![gamedata writeToFile:boardPathAdd
                               options:NSDataWritingAtomic
                                 error:&error]) {
                NSLog(@"Error writing file: %@", error);
            }
            
            if (![sharedata writeToFile:sharePathAdd
                                options:NSDataWritingAtomic
                                  error:&error]) {
                NSLog(@"Error writing file: %@", error);
            }
            
             [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self.bestScoreRecord addObject:@(self.score)];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.bestScoreRecord
                                                  forKey:@"bestScoreRecord"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self saveBestScoreRecord];
}

@end
