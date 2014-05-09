//
//  GameEndViewController.m
//  NumberGame
//
//  Created by Alen on 14-4-30.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameEndViewController.h"

@interface GameEndViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel* winLabel;
@property (weak, nonatomic) IBOutlet UILabel* scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton* replayButton;
@property (weak, nonatomic) IBOutlet UIButton* shareButton;
@property (nonatomic, strong) UIActivityViewController* activityViewController;

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
    self.winLabel.text = self.didWin ? @"You win!" : @"You lose!";
    self.winLabel.layer.cornerRadius = 20.0f;

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
    self.shareButton.layer.cornerRadius = 20.0f;

    self.replayButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                        size:23];
    self.replayButton.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                        green:173.0f / 255
                                                         blue:182.0f / 255
                                                        alpha:1.0f];
    self.replayButton.titleLabel.textColor = [UIColor whiteColor];
    self.replayButton.layer.cornerRadius = 20.0f;
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
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[
                                                                                             [NSString stringWithFormat:@"I scored %lu points at 2048, a game where you join numbers to score high! https://itunes.apple.com/app/2048-original-gameplay/id848513715", (long)self.score]
                                                                                          ]
                                                                    applicationActivities:nil];
    [self presentViewController:self.activityViewController
                       animated:YES
                     completion:^{
         [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                     }];
}
@end
