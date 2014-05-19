//
//  GameRecordViewController.m
//  NumberGame
//
//  Created by Alen on 14-5-4.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameRecordViewController.h"
#import "GameBoardView.h"
#import "AppHelper.h"

NSString* const kShareButtonHorizontal = @"H:|-50-[shareButton(220)]-50-|";
NSString* const kShareButtonVertical = @"V:[shareButton]-0-[_pageControl]";
NSString* const kContinueButtonHorizontal = @"H:|-50-[continueButton(220)]-50-|";
NSString* const kContinueButtonVertical = @"V:[continueButton]-0-[_pageControl]";

@interface GameRecordViewController () <UIScrollViewDelegate>

//@property (weak, nonatomic) IBOutlet UILabel* scoreLabel;

//@property (weak, nonatomic) IBOutlet UIButton* shareButton;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl* pageControl;

@property (nonatomic, strong) UIActivityViewController* activityViewController;
- (IBAction)pageChanged:(UIPageControl*)sender;

@end

@implementation GameRecordViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    // Do any additional setup after loading the view.
    self.scrollView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;

    self.pageControl.numberOfPages = [self.bestScoreRecord count] + 1;

    for (int i = 0; i < [self.bestScoreRecord count]; i++) {
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * (i + 2),
                                                 self.view.bounds.size.height);

        CGRect gameBoardBackgroundViewRect = CGRectMake(i * self.scrollView.bounds.size.width,
                                                        0,
                                                        self.view.bounds.size.width,
                                                        self.view.bounds.size.height);
        UIView* gameBoardBackgroundView =
            [[UIView alloc] initWithFrame:gameBoardBackgroundViewRect];

        NSArray* paths = NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths lastObject];
        NSString* filename =
            [NSString stringWithFormat:@"Photo-%ld.png",
                                       (long)[self.bestScoreRecord[i] integerValue]];
        NSString* photoPath =
            [documentsDirectory stringByAppendingPathComponent:filename];

        UIImage* recordImage = [UIImage imageWithContentsOfFile:photoPath];
        NSLog(@"图片高度为:%f",recordImage.size.height);

        UIImageView* gamaBoardView =
            [[UIImageView alloc] initWithImage:recordImage];
        [gamaBoardView sizeToFit];
        NSLog(@"gamaBoardView 的高为:%f",gamaBoardView.frame.size.height);
        
//        gamaBoardView.center = self.scrollView.center;
        

        UILabel* scoreLabel =
            [[UILabel alloc] init];
        scoreLabel.frame = [AppHelper isPhone] ? CGRectMake(0, 0, 80, 80) : CGRectMake(0, 0, 120, 120);
        scoreLabel.center = [AppHelper isPhone] ? CGPointMake(self.scrollView.center.x, 45) : CGPointMake(self.scrollView.center.x, 70);
        scoreLabel.numberOfLines = 2;
        [scoreLabel setTextAlignment:NSTextAlignmentCenter];
        NSString* str1 = NSLocalizedString(@"Score", @"得分");
        scoreLabel.text = [str1 stringByAppendingFormat:@"\n%ld", (long)[self.bestScoreRecord[i] integerValue]];

        scoreLabel.contentMode = UIViewContentModeScaleAspectFit;

        scoreLabel.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                     green:173.0f / 255
                                                      blue:182.0f / 255
                                                     alpha:1.0f];
        scoreLabel.textColor = [UIColor whiteColor];
        
        scoreLabel.layer.cornerRadius = [AppHelper isPhone] ? 40.0f : 60.0f;
        scoreLabel.clipsToBounds = YES;
        scoreLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                          size:16];


        UIButton* shareButton =
            [[UIButton alloc] init];
        shareButton.layer.cornerRadius = 5.0f;
        shareButton.titleLabel.font =
            [UIFont fontWithName:@"AvenirNext-Heavy"
                            size:23];
        shareButton.backgroundColor =
            [UIColor colorWithRed:0.0f
                            green:204.0f / 255
                             blue:1.0f
                            alpha:1];

        shareButton.titleLabel.textColor = [UIColor whiteColor];
        [shareButton setTitle:NSLocalizedString(@"SHARE", @"分享")
                     forState:UIControlStateNormal];
        shareButton.layer.cornerRadius = 5.0f;
        [shareButton addTarget:self
                        action:@selector(openShare)
              forControlEvents:UIControlEventTouchUpInside];
        
        if ([AppHelper isPhone]) {
            if (self.view.frame.size.height == 480) {
                scoreLabel.frame = scoreLabel.frame = CGRectMake(120, 5, 80, 80);
                gamaBoardView.frame = CGRectMake(10, 95, 300, 316);
                shareButton.frame = CGRectMake(50, 410, 220, 40);
            } else {
                scoreLabel.frame = scoreLabel.frame = CGRectMake(120, 20, 80, 80);
                gamaBoardView.frame = CGRectMake(10, 135, 300, 316);
                shareButton.frame = CGRectMake(50, 480, 220, 40);
            }
        }
        [gameBoardBackgroundView addSubview:scoreLabel];
        [gameBoardBackgroundView addSubview:shareButton];
        [gameBoardBackgroundView addSubview:gamaBoardView];

        gameBoardBackgroundView.backgroundColor = [UIColor colorWithRed:232.0f / 255
                                                                  green:251.0f / 255
                                                                   blue:1.0f
                                                                  alpha:1.0f];

        [self.scrollView addSubview:gameBoardBackgroundView];
        NSLog(@"%f",shareButton.frame.size.height);
        NSLog(@"%f",shareButton.frame.size.width);

        NSLog(@"%f",shareButton.frame.origin.x);

        NSLog(@"%f",shareButton.frame.origin.y);

        
    }

    CGRect gameBoardBackgroundViewRect = CGRectMake([self.bestScoreRecord count] * self.scrollView.bounds.size.width,
                                                    0,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height);
    UIView* gameBoardBackgroundView =
        [[UIView alloc] initWithFrame:gameBoardBackgroundViewRect];

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 60)];
    titleLabel.textColor = [UIColor colorWithRed:136.0f / 255
                                           green:173.0f / 255
                                            blue:182.0f / 255
                                           alpha:1.0f];
    titleLabel.text = NSLocalizedString(@"Your High Scores", @"您的最高分");
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                      size:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.center = CGPointMake(self.scrollView.center.x, 50);
    titleLabel.backgroundColor = [UIColor colorWithRed:232.0f / 255
                                                 green:251.0f / 255
                                                  blue:1.0f
                                                 alpha:1.0f];
    [gameBoardBackgroundView addSubview:titleLabel];

    UILabel* tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    tipsLabel.textColor = [UIColor colorWithRed:136.0f / 255
                                          green:173.0f / 255
                                           blue:182.0f / 255
                                          alpha:1.0f];
    tipsLabel.numberOfLines = 0;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                     size:17];
    NSString* tips = NSLocalizedString(@"Swipe left to see your 3 latest scores.Share with your friends or keep going.", @"滑至左侧以查看您最近3次的最高分,分享给你的朋友或继续");
    CGSize size = [tips sizeWithFont:tipsLabel.font
                   constrainedToSize:CGSizeMake(tipsLabel.frame.size.width, MAXFLOAT)
                       lineBreakMode:NSLineBreakByWordWrapping];
    [tipsLabel setFrame:CGRectMake(0, 0, 280, size.height)];
    tipsLabel.backgroundColor = [UIColor colorWithRed:232.0f / 255
                                                green:251.0f / 255
                                                 blue:1.0f
                                                alpha:1.0f];
    tipsLabel.text = tips;
    tipsLabel.center = self.scrollView.center;


    UIButton* continueButton =
        [[UIButton alloc] init];
    continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    continueButton.center = CGPointMake(self.scrollView.center.x, 400);
   continueButton.layer.cornerRadius = 20.0f;
   continueButton.titleLabel.font =
        [UIFont fontWithName:@"AvenirNext-Heavy"
                        size:23];
    continueButton.backgroundColor =
        [UIColor colorWithRed:0.0f
                        green:204.0f / 255
                         blue:1.0f
                        alpha:1.0];
    continueButton.titleLabel.textColor = [UIColor whiteColor];
    [continueButton setTitle:NSLocalizedString(@"KEEP GOING", @"继续")
                   forState:UIControlStateNormal];
    continueButton.layer.cornerRadius = 5.0f;
    [continueButton addTarget:self
                      action:@selector(continueGame)
            forControlEvents:UIControlEventTouchUpInside];
    
    if ([AppHelper isPhone]) {
        if (self.view.frame.size.height == 480) {
//            scoreLabel.frame = scoreLabel.frame = CGRectMake(120, 5, 80, 80);
//            gamaBoardView.frame = CGRectMake(10, 95, 300, 316);
            continueButton.frame = CGRectMake(50, 410, 220, 40);
        } else {
            continueButton.frame = CGRectMake(50, 480, 220, 40);
        }
    }
    
    [gameBoardBackgroundView addSubview:tipsLabel];

    [gameBoardBackgroundView addSubview:continueButton];

    [self.scrollView addSubview:gameBoardBackgroundView];

   
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)openShare
{

    NSArray* paths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths lastObject];
    NSLog(@"%@", self.bestScoreRecord[self.pageControl.currentPage]);
    NSString* filename =
        [NSString stringWithFormat:@"Share-%ld@2x.png",
                                   (long)[self.bestScoreRecord[self.pageControl.currentPage] integerValue]];

    NSString* photoPath =
        [documentsDirectory stringByAppendingPathComponent:filename];

    UIImage* recordImage = [UIImage imageWithContentsOfFile:photoPath];

    //上架时添加产品ID

    NSString* str1 = NSLocalizedString(@"I scored", @"我在1536得了");
    NSString* str2 = NSLocalizedString(@"points at 1536, a game where you join numbers to score high! https://itunes.apple.com/app/2048-original-gameplay/id848513715", @"分,这个游戏规则为合并数字得到最高分! https://itunes.apple.com/app/2048-original-gameplay/id848513715");
    NSString* str3 = [str1 stringByAppendingFormat:@"%lu", (long)self.score];
    NSString* str4 = [str3 stringByAppendingString:str2];
    self.activityViewController = [[UIActivityViewController alloc]
        initWithActivityItems:
            @[
               str4,
               recordImage
            ]
        applicationActivities:nil];
    [self presentViewController:self.activityViewController
                       animated:YES
                     completion:^{
                       [[UIApplication sharedApplication]
                           setStatusBarHidden:YES
                                withAnimation:UIStatusBarAnimationNone];
                     }];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    int currentPage = (self.scrollView.contentOffset.x + width / 2.0f) / width;
    NSLog(@"当前所在页面%d", currentPage);
    self.pageControl.currentPage = currentPage;
}

- (IBAction)pageChanged:(UIPageControl*)sender
{

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.scrollView.contentOffset =
                           CGPointMake(self.scrollView.bounds.size.width *
                                           sender.currentPage,
                                       0);
                     }
                     completion:nil];
}

- (void)continueGame
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
