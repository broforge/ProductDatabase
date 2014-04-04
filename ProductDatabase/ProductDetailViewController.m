//
//  ProductDetailViewController.m
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ScrollingImageViewController.h"
#import "DatabaseManager.h"
#import "ResourceManager.h"

@interface ProductDetailViewController ()

@property (nonatomic, strong) NSDictionary *productDetails;
@property (nonatomic, strong) NSMutableArray *colorArray;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSString *currentImage;

@end

@implementation ProductDetailViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.colorArray = [NSMutableArray array];
    UIColor *borderColor = [UIColor colorWithRed:205.f/255.f green:205.f/255.f blue:205.f/255.f alpha:1];
    self.textViewDescription.layer.borderColor = [borderColor CGColor];
    self.tableView.layer.borderColor = [borderColor CGColor];
    self.imageView.layer.borderColor = [borderColor CGColor];
    self.imageNames = [[ResourceManager sharedInstance] imageNames];

    if (self.productDetails) {
        [self showProductDetails:self.productDetails];
    }
}

- (void)showProductDetails:(NSDictionary *)details {
    self.textFieldName.text = [details objectForKey:@"name"];
    self.textViewDescription.text = [details objectForKey:@"description"];
    self.textFieldPrice.text = [[details objectForKey:@"price"] stringValue];
    self.textFieldSalePrice.text = [[details objectForKey:@"salePrice"] stringValue];
    
    NSNumber *identifier = [details objectForKey:@"id"];
    if (identifier) {
        self.textFieldId.text = [identifier stringValue];
    }
    
    self.currentImage = [details objectForKey:@"image"];
    self.imageView.image = [UIImage imageNamed:self.currentImage];
    [self.colorArray removeAllObjects];
    [self.colorArray addObjectsFromArray:[details objectForKey:@"colors"]];
    [self.tableView reloadData];
    
    NSInteger row = [self.imageNames indexOfObject:self.currentImage];
    if (row != NSNotFound) {
        [self.pickerView selectRow:row inComponent:0 animated:NO];
    }
}

- (void)loadProductDetails:(NSDictionary *)product {
    NSUInteger identifier = [[product objectForKey:@"id"] unsignedIntegerValue];
    
    DatabaseManager *databaseManager = [DatabaseManager sharedInstance];
    self.productDetails = [databaseManager queryProductDetailsWithId:identifier];
}

- (NSDictionary *)updatedProductDetails {
    NSUInteger identifier = [self.textFieldId.text integerValue];
    NSString *name = self.textFieldName.text;
    NSString *description = self.textViewDescription.text;
    double price = [self.textFieldPrice.text doubleValue];
    double salePrice = [self.textFieldSalePrice.text doubleValue];
    NSString *image = self.currentImage;
    
    if(name.length > 0 && description.length > 0 && image.length > 0) {
        NSDictionary *details = [NSDictionary dictionaryWithObjectsAndKeys:@(identifier), @"id",
                                                                          name, @"name",
                                                                          description, @"description",
                                                                          @(price), @"price",
                                                                          @(salePrice), @"salePrice",
                                                                          image, @"image",
                                                                          self.colorArray, @"colors", nil];
        return details;
    }
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.colorArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row < [self.colorArray count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellColor" forIndexPath:indexPath];
        UILabel *labelColor = (UILabel *)[cell.contentView viewWithTag:1];
        labelColor.text = [self.colorArray objectAtIndex:indexPath.row];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAddColor" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.imageNames count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.imageNames objectAtIndex:row];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentImage = [self.imageNames objectAtIndex:row];
    self.imageView.image = [UIImage imageNamed:self.currentImage];
    self.pickerView.hidden = YES;
    self.backgroundView.backgroundColor = [UIColor clearColor];
}

#pragma mark - IB Actions

- (IBAction)addButtonPressed:(id)sender {
    NSDictionary *product = [self updatedProductDetails];
    if (product) {
        [[DatabaseManager sharedInstance] insertProduct:product];
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

- (IBAction)mockDataButtonPressed:(id)sender {
    [self showProductDetails:[[DatabaseManager sharedInstance] mockData]];
}

- (IBAction)updateButtonPressed:(id)sender {
    NSDictionary *product = [self updatedProductDetails];
    if (product) {
        [[DatabaseManager sharedInstance] updateProduct:product];
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

- (IBAction)screenTapped:(id)sender {
    [self.view endEditing:YES];
    if (!self.pickerView.hidden) {
        self.pickerView.hidden = YES;
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
}

- (IBAction)deleteColorButtonPressed:(id)sender {
    CGPoint pos = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];
    [self.colorArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

- (IBAction)addColorFieldEdited:(id)sender {
    UITextField *textFieldAddColor = sender;
    NSString *newColor = textFieldAddColor.text;
    textFieldAddColor.text = @"";

    if (newColor.length == 0) {
        return;
    }
    
    for (NSString *color in self.colorArray) {
        if ([newColor isEqualToString:color]) {
            return;
        }
    }
    [self.colorArray addObject:newColor];
    [self.tableView reloadData];
}

- (IBAction)editImageButtonPressed:(id)sender {
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.pickerView.hidden = NO;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowImage"]) {
        ScrollingImageViewController *scrollingImageViewController = [segue destinationViewController];
        scrollingImageViewController.imageName = self.currentImage;
    }
}

@end
