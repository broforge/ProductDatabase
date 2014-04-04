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
#import "ResourceManager.h"
@interface ProductTableViewController ()

@property (nonatomic,strong) NSArray *products;

@end

@implementation ProductTableViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.products = [[DatabaseManager sharedInstance] queryProducts];
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
    UILabel *labelId = (UILabel *)[cell.contentView viewWithTag:3];
    labelId.text = [[info objectForKey:@"id"] stringValue];
    
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditProduct"]) {
        NSDictionary *info = [self.products objectAtIndex:[self.tableView indexPathForSelectedRow].row];        
        ProductDetailViewController *detailViewController = [segue destinationViewController];
        [detailViewController loadProductDetails:info];
    }
}

@end
