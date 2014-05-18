//
//  GameSetUpViewController.m
//  NumberGame
//
//  Created by silence on 14-5-7.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameSetUpViewController.h"
extern BOOL shouldPlaySound;

@interface GameSetUpViewController ()
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UIButton* continueButton;
@property (weak, nonatomic) IBOutlet UIButton* replayButton;
@property (weak, nonatomic) IBOutlet UIButton* rateButton;
@property (weak, nonatomic) IBOutlet UIButton* tutorialButton;
@property (weak, nonatomic) IBOutlet UIButton* soundButton;

- (IBAction)continueGame:(id)sender;
- (IBAction)replayGame:(id)sender;
- (IBAction)rateApp:(id)sender;
- (IBAction)openTutorial:(id)sender;
- (IBAction)onSoundPress:(id)sender;

@end

@implementation GameSetUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                           size:23];
    self.titleLabel.textColor = [UIColor colorWithRed:136.0f / 255
                                                green:173.0f / 255
                                                 blue:182.0f / 255
                                                alpha:1.0f];
    self.titleLabel.layer.cornerRadius = 5.0f;

    self.continueButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                          size:23];
    self.continueButton.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                          green:173.0f / 255
                                                           blue:182.0f / 255
                                                          alpha:1.0f];
    self.continueButton.tintColor = [UIColor whiteColor];
    self.continueButton.layer.cornerRadius = 5.0f;

    self.replayButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                        size:23];
    self.replayButton.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                        green:173.0f / 255
                                                         blue:182.0f / 255
                                                        alpha:1.0f];
    self.replayButton.tintColor = [UIColor whiteColor];
    self.replayButton.layer.cornerRadius = 5.0f;

    self.rateButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                      size:23];
    self.rateButton.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                      green:173.0f / 255
                                                       blue:182.0f / 255
                                                      alpha:1.0f];
    self.rateButton.tintColor = [UIColor whiteColor];
    self.rateButton.layer.cornerRadius = 5.0f;

    self.tutorialButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                          size:23];
    self.tutorialButton.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                          green:173.0f / 255
                                                           blue:182.0f / 255
                                                          alpha:1.0f];
    self.tutorialButton.tintColor = [UIColor whiteColor];
    self.tutorialButton.layer.cornerRadius = 5.0f;

    self.soundButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                       size:23];
    [self.soundButton setBackgroundColor:[UIColor colorWithRed:136.0f / 255
                                                         green:173.0f / 255
                                                          blue:182.0f / 255
                                                         alpha:1.0f]];
    self.soundButton.layer.cornerRadius = 5.0f;
    self.soundButton.tintColor = [UIColor whiteColor];
    NSString* buttonTitle = shouldPlaySound ? NSLocalizedString(@"Sound On", @"声音开启") : NSLocalizedString(@"Sound Off",@"声音关闭");
    [self.soundButton setTitle:buttonTitle
                      forState:UIControlStateNormal];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)continueGame:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)replayGame:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
    [self.delegate shouldStartNewGame];
}

- (IBAction)rateApp:(id)sender
{
    //上架添加ID
    NSInteger appID = 848513715;
    NSString* ulrPath = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", appID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ulrPath]];
}

- (IBAction)openTutorial:(id)sender
{
}

- (IBAction)onSoundPress:(id)sender
{

    shouldPlaySound = !shouldPlaySound;
        NSString* buttonTitle = shouldPlaySound ? NSLocalizedString(@"Sound On", @"声音开启") : NSLocalizedString(@"Sound Off",@"声音关闭");
    [self.soundButton setTitle:buttonTitle
                      forState:UIControlStateNormal];
}
@end
