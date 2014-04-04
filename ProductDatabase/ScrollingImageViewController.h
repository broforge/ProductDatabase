//
//  ScrollingImageViewController.h
//  ProductDatabase
//
//  Created by BrotoMan on 4/4/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollingImageViewController : UIViewController

@property (nonatomic, strong) NSString* imageName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)dismissButtonPressed:(id)sender;

@end
