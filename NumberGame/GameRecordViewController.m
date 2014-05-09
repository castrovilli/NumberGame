//
//  GameRecordViewController.m
//  NumberGame
//
//  Created by Alen on 14-5-4.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameRecordViewController.h"
#import "GameBoardView.h"

NSString* const kShareButtonHorizontal = @"H:|-50-[shareButton(220)]-50-|";
NSString* const kShareButtonVertical = @"V:[shareButton]-0-[_pageControl]";

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
            [NSString stringWithFormat:@"Photo-%d.jpg",
                                       [self.bestScoreRecord[i] integerValue]];
        NSString* photoPath =
            [documentsDirectory stringByAppendingPathComponent:filename];

        UIImage* recordImage = [UIImage imageWithContentsOfFile:photoPath];

        UIImageView* gamaBoardView =
            [[UIImageView alloc] initWithImage:recordImage];
        gamaBoardView.center = self.scrollView.center;
        [gameBoardBackgroundView addSubview:gamaBoardView];

        UILabel* scoreLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        scoreLabel.center = CGPointMake(self.scrollView.center.x, 45);
        scoreLabel.numberOfLines = 2;
        [scoreLabel setTextAlignment:NSTextAlignmentCenter];
        scoreLabel.text = [NSString
            stringWithFormat:@"Best\n%d", [self.bestScoreRecord[i] integerValue]];
        scoreLabel.backgroundColor = [UIColor colorWithRed:136.0f / 255
                                                     green:173.0f / 255
                                                      blue:182.0f / 255
                                                     alpha:1.0f];
        scoreLabel.textColor = [UIColor whiteColor];
        scoreLabel.layer.cornerRadius = 40.0f;
        scoreLabel.clipsToBounds = YES;
        scoreLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                          size:23];

        [gameBoardBackgroundView addSubview:scoreLabel];

        UIButton* shareButton =
            [[UIButton alloc] init];
        shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        shareButton.layer.cornerRadius = 20.0f;
        shareButton.titleLabel.font =
            [UIFont fontWithName:@"AvenirNext-Heavy"
                            size:23];
        shareButton.backgroundColor =
            [UIColor colorWithRed:0.0f
                            green:204.0f / 255
                             blue:1.0f
                            alpha:1];

        shareButton.titleLabel.textColor = [UIColor whiteColor];
        [shareButton setTitle:@"SHARE"
                     forState:UIControlStateNormal];
        shareButton.layer.cornerRadius = 20.0f;
        [shareButton addTarget:self
                        action:@selector(openShare)
              forControlEvents:UIControlEventTouchUpInside];
        [gameBoardBackgroundView addSubview:shareButton];

        gameBoardBackgroundView.backgroundColor = [UIColor colorWithRed:232.0f / 255
                                                                  green:251.0f / 255
                                                                   blue:1.0f
                                                                  alpha:1.0f];

        [self.scrollView addSubview:gameBoardBackgroundView];

        NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(shareButton, _pageControl);

        NSMutableArray* constraints = [[NSMutableArray alloc] init];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kShareButtonHorizontal
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:kShareButtonVertical
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDictionary]];
        [self.view addConstraints:constraints];
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
    titleLabel.text = @"Your High Scores";
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                      size:23];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.center = CGPointMake(self.scrollView.center.x, 50);
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
    NSString* tips = @"Swipe left to see your 3 latest scores.Share with your friends or keep going.";
    CGSize size = [tips sizeWithFont:tipsLabel.font
                   constrainedToSize:CGSizeMake(tipsLabel.frame.size.width, MAXFLOAT)
                       lineBreakMode:NSLineBreakByWordWrapping];
    [tipsLabel setFrame:CGRectMake(0, 0, 280, size.height)];
    tipsLabel.text = tips;
    tipsLabel.center = self.scrollView.center;
    [gameBoardBackgroundView addSubview:tipsLabel];

    UIButton* cotinueButton =
        [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 220, 50)];
    cotinueButton.center = CGPointMake(self.scrollView.center.x, 400);
    cotinueButton.layer.cornerRadius = 20.0f;
    cotinueButton.titleLabel.font =
        [UIFont fontWithName:@"AvenirNext-Heavy"
                        size:23];
    cotinueButton.backgroundColor =
        [UIColor colorWithRed:0.0f
                        green:204.0f / 255
                         blue:1.0f
                        alpha:1.0];
    cotinueButton.titleLabel.textColor = [UIColor whiteColor];
    [cotinueButton setTitle:@"KEEP GOING"
                   forState:UIControlStateNormal];
    cotinueButton.layer.cornerRadius = 20.0f;
    [cotinueButton addTarget:self
                      action:@selector(continueGame)
            forControlEvents:UIControlEventTouchUpInside];

    [gameBoardBackgroundView addSubview:cotinueButton];

    [self.scrollView addSubview:gameBoardBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)openShare
{
    //上架时添加产品ID
    self.activityViewController = [[UIActivityViewController alloc]
        initWithActivityItems:
            @[
               [NSString stringWithFormat:@"I scored %lu points at 2048, a game "
                                          @"where you join numbers to score "
                                          @"high! "
                                          @"https://itunes.apple.com/app/"
                                          @"2048-original-gameplay/id848513715",
                                          (long)self.score]
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
