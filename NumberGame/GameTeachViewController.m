//
//  GameTeachViewController.m
//  NumberGame
//
//  Created by silence on 14-5-14.
//  Copyright (c) 2014年 AlenChang. All rights reserved.
//

#import "GameTeachViewController.h"

@interface GameTeachViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)playGame:(UIButton *)sender;



@end

@implementation GameTeachViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playButton.layer.cornerRadius = 5.0f;
    self.playButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy"
                                                        size:23];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playGame:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
