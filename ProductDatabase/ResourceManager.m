//
//  ResourceManager.m
//  ProductDatabase
//
//  Created by BrotoMan on 4/4/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import "ResourceManager.h"

@interface ResourceManager()

@end

@implementation ResourceManager

+ (id)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    NSMutableSet *set = [NSMutableSet set];
    NSArray *filePaths = [NSBundle pathsForResourcesOfType:@"png" inDirectory:[[NSBundle mainBundle] bundlePath]];
    for (NSString *path in filePaths) {
        NSString *fileName = [path lastPathComponent];
        if ([fileName hasPrefix:@"LaunchImage"]) {
            continue;
        }
        
        fileName = [[fileName stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        if (![set containsObject:fileName]) {
            [set addObject:fileName];
        }
    }
    self.imageNames = [set allObjects];
    
    return self;
}



@end
