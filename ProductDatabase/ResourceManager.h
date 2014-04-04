//
//  ResourceManager.h
//  ProductDatabase
//
//  Created by BrotoMan on 4/4/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceManager : NSObject

@property (nonatomic, strong) NSArray *imageNames;

+ (id)sharedInstance;

@end
