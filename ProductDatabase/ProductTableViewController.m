//
//  ProductTableViewController.m
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import "ProductTableViewController.h"
#import "DatabaseManager.h"
#import "ProductDetailViewController.h"

@interface ProductTableViewController ()

@property (nonatomic,strong) NSArray *products;

@end

@implementation ProductTableViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DatabaseManager *databaseManager = [DatabaseManager sharedInstance];
    self.products = [databaseManager queryProducts];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *info = [self.products objectAtIndex:indexPath.row];
    UILabel *labelName = (UILabel *)[cell.contentView viewWithTag:1];
    labelName.text = [info objectForKey:@"name"];
    UILabel *labelImage = (UILabel *)[cell.contentView viewWithTag:2];
    labelImage.text = [info objectForKey:@"image"];
    UILabel *labelId = (UILabel *)[cell.contentView viewWithTag:3];
    labelId.text = [[info objectForKey:@"id"] stringValue];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddProduct"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"EditProduct"]) {
        NSDictionary *info = [self.products objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        NSUInteger identifier = [[info objectForKey:@"id"] unsignedIntegerValue];
        
        DatabaseManager *databaseManager = [DatabaseManager sharedInstance];
        NSDictionary *productDetails = [databaseManager queryProductWithIdentifier:identifier];
        
        ProductDetailViewController *detailViewController = [segue destinationViewController];
        [detailViewController loadProduct:productDetails];
    }
}

@end
