//
//  DatabaseManager.h
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject

+ (id)sharedInstance;

- (NSArray*)queryProducts;
- (NSDictionary*)queryProductWithIdentifier:(NSUInteger)productIdentifier;

@end
