//
//  Product.h
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property NSUInteger identifier;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *description;
@property CGFloat price;
@property CGFloat salePrice;
@property (nonatomic,strong) NSString *image;
//@property (nonatomic,strong) NSArray *colors;
//@property (nonatomic,strong) NSDictionary *stores;

@end
