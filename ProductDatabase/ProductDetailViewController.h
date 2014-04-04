//
//  ProductDetailViewController.h
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDescription;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPrice;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSalePrice;
@property (weak, nonatomic) IBOutlet UITextField *textFieldImage;

@property (weak, nonatomic) IBOutlet UILabel *labelIdentifier;
- (void)loadProductDetails:(NSDictionary *)product;
- (IBAction)addButtonPressed:(id)sender;
- (IBAction)updateButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)textFieldTappedOutside:(id)sender;

@end
