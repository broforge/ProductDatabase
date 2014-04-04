//
//  ProductDetailViewController.m
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "DatabaseManager.h"

@interface ProductDetailViewController ()

@property (nonatomic,strong) NSDictionary *productDetails;

@end

@implementation ProductDetailViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.productDetails) {
        self.textFieldName.text = [self.productDetails objectForKey:@"name"];
        self.textFieldDescription.text = [self.productDetails objectForKey:@"description"];
        self.textFieldPrice.text = [[self.productDetails objectForKey:@"price"] stringValue];
        self.textFieldSalePrice.text = [[self.productDetails objectForKey:@"salePrice"] stringValue];
        self.textFieldImage.text = [self.productDetails objectForKey:@"image"];
        self.labelIdentifier.text = [[self.productDetails objectForKey:@"id"] stringValue];
    }
}

- (void)loadProductDetails:(NSDictionary *)product {
    NSUInteger identifier = [[product objectForKey:@"id"] unsignedIntegerValue];
    
    DatabaseManager *databaseManager = [DatabaseManager sharedInstance];
    self.productDetails = [databaseManager queryProductWithIdentifier:identifier];
}

- (BOOL)updateProductDetails {
    
    NSUInteger identifier = [self.labelIdentifier.text integerValue];
    NSString *name = self.textFieldName.text;
    NSString *description = self.textFieldDescription.text;
    double price = [self.textFieldPrice.text doubleValue];
    double salePrice = [self.textFieldSalePrice.text doubleValue];
    NSString *image = self.textFieldImage.text;
    
    if(name.length > 0 && description.length > 0 && image.length > 0) {
        self.productDetails = [NSDictionary dictionaryWithObjectsAndKeys:@(identifier), @"id",
                                                                         name, @"name",
                                                                         description, @"description",
                                                                         @(price), @"price",
                                                                         @(salePrice), @"salePrice",
                                                                         image, @"image", nil];
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBActions

- (IBAction)addButtonPressed:(id)sender {
    if ([self updateProductDetails]) {
        [[DatabaseManager sharedInstance] updateProduct:self.productDetails];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:@"Please fill out all fields"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)updateButtonPressed:(id)sender {
    if ([self updateProductDetails]) {
        [[DatabaseManager sharedInstance] updateProduct:self.productDetails];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:@"Please fill out all fields"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
        [alert show];
    }
}
- (IBAction)deleteButtonPressed:(id)sender {
    [[DatabaseManager sharedInstance] deleteProduct:self.productDetails];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
