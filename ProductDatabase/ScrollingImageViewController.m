//
//  ScrollingImageViewController.m
//  ProductDatabase
//
//  Created by BrotoMan on 4/4/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import "ScrollingImageViewController.h"

@interface ScrollingImageViewController ()

@end

@implementation ScrollingImageViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:self.imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = self.scrollView.center;
    [self.scrollView addSubview:imageView];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
