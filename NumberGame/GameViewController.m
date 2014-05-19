//
//  GameViewController.m
//  NumberGame
//
//  Created by Alen Chang on 14-4-25.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "GameViewController.h"
#import "GameboardView.h"
#import "GameModel.h"
#import "GameEndViewController.h"
#import "GameRecordViewController.h"
#import "GameCenterManager.h"
#import "GameSetUpViewController.h"
#import "UIView+saveImageWithScale.h"
#import "AppHelper.h"

#define LeaderBoardName @"com.self.NumberGame.leaderboard"
BOOL shouldPlaySound = YES;

@interface GameViewController () <GameModelProtocol, GameEndDelegate, GameCenterManagerDelegate> {
    SystemSoundID attachSound;
    SystemSoundID newTileSound;
    SystemSoundID lostSound;
    SystemSoundID winSound;
}

@property (weak, nonatomic) IBOutlet UIView* shareView;

@property (weak, nonatomic) IBOutlet UIView* gameBoardBackgroundView;
@property (nonatomic, strong) GameBoardView* gameboard;
@property (nonatomic, strong) GameModel* model;

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSInteger winValue;

@property (weak, nonatomic) IBOutlet UIButton* currentScore;
@property (weak, nonatomic) IBOutlet UIButton* bestScore;
@property (nonatomic, strong) NSMutableArray* bestScoreRecord;

@property (weak, nonatomic) IBOutlet UIView* recordView;

@property (weak, nonatomic) IBOutlet UILabel* nextGoalScore;
@property (weak, nonatomic) IBOutlet UIButton* appName;

@property (nonatomic) BOOL moveFlag;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];

    self.moveFlag = NO;

    [self _startNewGame];

    [self _setupGestureRecognizers];

    self.currentScore.titleLabel.font = [AppHelper isPhone] ? [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                              size:13]
                                                            : [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                              size:23];
    self.currentScore.layer.cornerRadius = [AppHelper isPhone] ? 37.5f : 60.0f;

    self.currentScore.titleLabel.textColor = [UIColor whiteColor];
    self.currentScore.titleLabel.numberOfLines = 2;
    self.currentScore.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                        green:173.0f / 255
                                                         blue:182.0f / 255
                                                        alpha:1.0];

    [self.currentScore.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self _setScore:0];

    self.appName.titleLabel.font = [AppHelper isPhone] ? [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                         size:23]
                                                       : [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                         size:27];

    self.appName.layer.cornerRadius = [AppHelper isPhone] ? 40.0f : 65.0f;
    self.appName.backgroundColor = [UIColor colorWithRed:93.0f / 255
                                                   green:223.0f / 255
                                                    blue:1.0f
                                                   alpha:1.0f];
    self.appName.tintColor = [UIColor whiteColor];

    self.bestScore.titleLabel.font = [AppHelper isPhone] ? [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                           size:13]
                                                         : [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                           size:23];
    self.bestScore.layer.cornerRadius = [AppHelper isPhone] ? 37.5f : 60.0f;

    self.bestScore.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                     green:173.0f / 255
                                                      blue:182.0f / 255
                                                     alpha:1.0];
    self.bestScore.titleLabel.numberOfLines = 2;
    self.bestScore.contentMode = UIViewContentModeScaleToFill;
    [self.bestScore.titleLabel setTextAlignment:NSTextAlignmentCenter];

    self.nextGoalScore.font = [AppHelper isPhone] ? [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                    size:13]
                                                  : [UIFont fontWithName:@"AvenirNext-Heavy"
                                                                    size:25];

    self.nextGoalScore.textColor = [UIColor colorWithRed:136.0f / 255
                                                   green:173.0f / 255
                                                    blue:182.0f / 255
                                                   alpha:1.0];

    [self.view setBackgroundColor:[UIColor colorWithRed:232.0f / 255
                                                  green:251.0f / 255
                                                   blue:1.0f
                                                  alpha:1.0]];

    NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"attach"
                                              withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL), &attachSound);

    NSURL* soundURL2 = [[NSBundle mainBundle] URLForResource:@"new_tile"
                                               withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL2), &newTileSound);

    NSURL* soundURL3 = [[NSBundle mainBundle] URLForResource:@"lost"
                                               withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL3), &lostSound);

    NSURL* soundURL4 = [[NSBundle mainBundle] URLForResource:@"win"
                                               withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID(CFBridgingRetain(soundURL4), &winSound);

    [[GameCenterManager sharedManager] setDelegate:self];

    if ([AppHelper isPhone]) {
        if (self.view.frame.size.height == 480) {
            self.currentScore.frame = CGRectMake(20, 10, 75, 75);
            self.appName.frame = CGRectMake(120, 5, 80, 80);
            self.bestScore.frame = CGRectMake(235, 10, 75, 75);
            self.nextGoalScore.frame = CGRectMake(20, 90, 280, 20);
            self.recordView.frame = CGRectMake(10, 114, 300, 366);
        }
    }
}

#pragma mark — IBActions

- (IBAction)onGameCenterPress:(id)sender
{
    if ([[GameCenterManager sharedManager] checkGameCenterAvailability]) {
        [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self];
    }
    NSLog(@"点击排行榜");
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)_showGameEndScreenWitnWin:(BOOL)didWin
{
    GameEndViewController* gameEndVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GameEndVC"];

    gameEndVC.delegate = self;
    gameEndVC.score = self.score;
    gameEndVC.didWin = didWin;
    gameEndVC.shareView = self.shareView;
    gameEndVC.recordView = self.recordView;

    [self presentViewController:gameEndVC
                       animated:YES
                     completion:nil];
}

- (void)_setScore:(NSInteger)score
{

    self.score = score;
    NSString* str = NSLocalizedString(@"Score", @"得分");
    [self.currentScore setTitle:[NSString stringWithFormat:@"%li\n%@", (long)score, str]
                       forState:UIControlStateNormal];

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]) {

        [[NSUserDefaults standardUserDefaults] setInteger:self.score
                                                   forKey:@"highscore"];

        [[NSUserDefaults standardUserDefaults] synchronize];

    } else {

        NSInteger pastScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];

        if (self.score > pastScore) {

            [[NSUserDefaults standardUserDefaults] setInteger:self.score
                                                       forKey:@"highscore"];

            [[NSUserDefaults standardUserDefaults] synchronize];
            [self _reportScoreToGameCenter]; // ADD THIS LINE
        }
    }

    NSInteger bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
    NSString* str1 = NSLocalizedString(@"Best", @"最高分");
    [self.bestScore setTitle:[NSString stringWithFormat:@"%li\n%@", (long)bestScore, str1]
                    forState:UIControlStateNormal];
    [self.bestScore setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];

    NSLog(@"现在的分数是%@", self.currentScore.titleLabel.text);
}

- (void)_reportScoreToGameCenter
{
    [[GameCenterManager sharedManager] saveAndReportScore:self.score
                                              leaderboard:LeaderBoardName
                                                sortOrder:GameCenterSortOrderHighToLow];
}

- (void)_setupGestureRecognizers
{
    UISwipeGestureRecognizer* swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(moveLeft)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeftRecognizer];

    UISwipeGestureRecognizer* swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(moveRight)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRightRecognizer];

    UISwipeGestureRecognizer* swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(moveUp)];
    [swipeUpRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUpRecognizer];

    UISwipeGestureRecognizer* swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(moveDown)];
    [swipeDownRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDownRecognizer];
}

- (void)_playSound:(SystemSoundID)soundID
{
    if (shouldPlaySound) {
        AudioServicesPlaySystemSound(soundID);
    }
}

#pragma mark — Move Methods

- (void)moveUp
{
    if ([self.model performMoveInDirection:MoveDirectionUp]) {
        [self _playSound:newTileSound];
        [self followUp];
    }
}

- (void)moveDown
{
    if ([self.model performMoveInDirection:MoveDirectionDown]) {
        [self _playSound:newTileSound];
        [self followUp];
    }
}

- (void)moveLeft
{
    if ([self.model performMoveInDirection:MoveDirectionLeft]) {
        [self _playSound:newTileSound];
        [self followUp];
    }
}

- (void)moveRight
{
    if ([self.model performMoveInDirection:MoveDirectionRight]) {
        [self _playSound:newTileSound];
        [self followUp];
    }
}

- (void)followUp
{

    // This is the earliest point the user can win

    if ([self.model userHasWon]) {
        [self _showGameEndScreenWitnWin:YES];
        [self _playSound:winSound];

        [self configureWinValue:self.winValue];
    } else {
        NSInteger rand = arc4random_uniform(10);
        if (rand == 1) {
            [self.model insertAtRandomLocationTileWithValue:6];
        } else {
            [self.model insertAtRandomLocationTileWithValue:3];
        }
        // At this point, the user may lose
        if ([self.model userHasLost]) {
            [self _showGameEndScreenWitnWin:NO];
            [self _playSound:lostSound];
            //            [self saveBestScoreRecord];
        }
    }
}

#pragma mark — GameEndDelegate

- (void)shouldStartNewGame
{
    [self _startNewGame];
    [self _setScore:0];
}

#pragma mark - Protocol

- (void)moveTileFromIndexPath:(NSIndexPath*)fromPath toIndexPath:(NSIndexPath*)toPath newValue:(NSUInteger)value
{
    [self.gameboard moveTileAtIndexPath:fromPath
                            toIndexPath:toPath
                              withValue:value];
}

- (void)moveTileOne:(NSIndexPath*)startA tileTwo:(NSIndexPath*)startB toIndexPath:(NSIndexPath*)end newValue:(NSUInteger)value
{
    [self.gameboard moveTileOne:startA
                        tileTwo:startB
                    toIndexPath:end
                      withValue:value];
}

- (void)insertTileAtIndexPath:(NSIndexPath*)path value:(NSUInteger)value
{
    [self.gameboard insertTileAtIndexPath:path
                                withValue:value];
}

- (void)playerLost
{
    // TODO
}

- (void)playerWonWithTile:(NSIndexPath*)tilePath
{
    // TODO
}

- (void)newScore:(NSInteger)score
{

    [self _setScore:score];
    [self _playSound:attachSound];
}

#pragma mark - GameCenter Manager Delegate

#pragma mark - GameCenter Manager Delegate

- (void)gameCenterManager:(GameCenterManager*)manager authenticateUser:(UIViewController*)gameCenterLoginController
{
    [self presentViewController:gameCenterLoginController
                       animated:YES
                     completion:^{
                         NSLog(@"Finished Presenting Authentication Controller");
                     }];
}

- (void)gameCenterManager:(GameCenterManager*)manager reportedScore:(GKScore*)score withError:(NSError*)error
{
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager*)manager didSaveScore:(GKScore*)score2
{
    NSLog(@"Saved GCM Score with value: %lld", score2.value);
}

- (void)gameCenterManager:(GameCenterManager*)manager error:(NSError*)error
{
    NSLog(@"GCM Error: %@", error);
}

#pragma mark — Private Methods

- (void)_startNewGame
{
    [self.gameboard removeFromSuperview];

    UIColor* backgroundColor = [UIColor colorWithRed:136.0f / 255
                                               green:173.0f / 255
                                                blue:182.0f / 255
                                               alpha:1.0];
    CGFloat cellWidth = [AppHelper isPhone] ? 60 : 110;
    CGFloat cellPadding = [AppHelper isPhone] ? 12 : 24;
    GameBoardView* gameboard = [GameBoardView gameboardWithDimension:4
                                                           cellWidth:cellWidth
                                                         cellPadding:cellPadding
                                                     backgroundColor:backgroundColor
                                                     foregroundColor:[UIColor colorWithRed:162.0f / 255
                                                                                     green:195.0f / 255
                                                                                      blue:203.0f / 255
                                                                                     alpha:1.0]];
    gameboard.layer.cornerRadius = 50.0;
    [self.gameBoardBackgroundView addSubview:gameboard];
    if (![AppHelper isPhone]) {
        gameboard.center = CGPointMake(self.gameBoardBackgroundView.center.x, self.gameBoardBackgroundView.center.y - gameboard.frame.size.height / 2);
    }

    self.gameBoardBackgroundView.backgroundColor = [UIColor colorWithRed:232.0f / 255
                                                                   green:251.0f / 255
                                                                    blue:1.0f
                                                                   alpha:1.0f];

    self.gameboard = gameboard;
    if (![self getWinValue]) {
        self.winValue = 12;
    } else {
        self.winValue = [self getWinValue];
    }

    GameModel* model = [GameModel gameModelWithDimension:4
                                                winValue:self.winValue
                                                delegate:self];

    [model insertAtRandomLocationTileWithValue:3];
    [model insertAtRandomLocationTileWithValue:6];
    self.model = model;

    [self configNextGoalScore];
}

- (void)configNextGoalScore
{
    NSString* str = NSLocalizedString(@"Your goal is to get the ", @"你的目标是得到");
    NSString* str3 = NSLocalizedString(@" tile!", @" 数字块!");
    NSString* str4 = [str stringByAppendingFormat:@"%ld", (long)self.winValue];

    NSString* str1 = [str4 stringByAppendingString:str3];

    self.nextGoalScore.text = str1;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GameSetSegue"]) {
        GameSetUpViewController* gameSetVC = (GameSetUpViewController*)segue.destinationViewController;
        gameSetVC.delegate = self;
    }

    if ([segue.identifier isEqualToString:@"GameRecVC"]) {
        GameRecordViewController* gameRecord = (GameRecordViewController*)segue.destinationViewController;

        self.bestScoreRecord = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"bestScoreRecord"]];
        NSLog(@"从缓存读取的数据啊%@", self.bestScoreRecord);

        gameRecord.bestScoreRecord = self.bestScoreRecord;
    }
}

/**
 *  游戏结束时保存当前视图
 */

- (NSInteger)getWinValue
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"winvalue"];
}

- (void)configureWinValue:(NSInteger)nextValue
{
    self.winValue = nextValue * 2;
    [[NSUserDefaults standardUserDefaults] setInteger:self.winValue
                                               forKey:@"winvalue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
