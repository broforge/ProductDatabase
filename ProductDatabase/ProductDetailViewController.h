//
//  ProductDetailViewController.h
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : UIViewController <UITextFieldDelegate,
                                                           UITableViewDataSource,
                                                           UIPickerViewDataSource,
                                                           UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldId;
@property (weak, nonatomic) IBOutlet UITextView *textViewDescription;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPrice;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSalePrice;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

- (void)loadProductDetails:(NSDictionary *)product;
- (IBAction)addButtonPressed:(id)sender;
- (IBAction)mockDataButtonPressed:(id)sender;
- (IBAction)updateButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)screenTapped:(id)sender;
- (IBAction)deleteColorButtonPressed:(id)sender;
- (IBAction)addColorFieldEdited:(id)sender;
- (IBAction)editImageButtonPressed:(id)sender;

@end
