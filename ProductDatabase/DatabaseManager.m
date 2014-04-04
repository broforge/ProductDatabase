//
//  DatabaseManager.m
//  ProductDatabase
//
//  Created by BrotoMan on 4/3/14.
//  Copyright (c) 2014 BrotoMan. All rights reserved.
//

#import "DatabaseManager.h"
#import <sqlite3.h>

static NSString * const DatabaseFilename = @"Products.db";
static NSString * const MockDataFilename = @"MockData";

@interface DatabaseManager() {
    sqlite3 *database;
}

@end

@implementation DatabaseManager

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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent: DatabaseFilename];
    
    NSLog(@"database path: %@", databasePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL newDatabase = ![fileManager fileExistsAtPath: databasePath];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        if (newDatabase) {
            NSMutableString *instruction = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS products ("];
            [instruction appendString:@"id INTEGER PRIMARY KEY AUTOINCREMENT, "];
            [instruction appendString:@"name TEXT, "];
            [instruction appendString:@"description TEXT, "];
            [instruction appendString:@"price REAL, "];
            [instruction appendString:@"salePrice REAL, "];
            [instruction appendString:@"image TEXT)"];
            
            char *errMsg;
            if (sqlite3_exec(database, [instruction UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Create failed: %s", sqlite3_errmsg(database));
            }
            [self loadMockData];
        }
    }
    else {
        NSLog(@"Failed to open/create database");
    }
    
    return self;
}

- (void)dealloc {
    sqlite3_close(database);
}

- (void)loadMockData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:MockDataFilename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error;
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (jsonData) {
        [self insertProductsWithArray:jsonData];
    }
    else {
        NSLog(@"error parsing mock data: %@", [error localizedDescription]);
    }
}
    
- (void)insertProduct:(NSDictionary*)product {
    NSString *instruction = @"INSERT INTO products (name, description, price, salePrice, image) VALUES(?,?,?,?,?)";

    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL);
    sqlite3_bind_text(statement, 1, [[product objectForKey:@"name"] UTF8String], -1, 0);
    sqlite3_bind_text(statement, 2, [[product objectForKey:@"description"] UTF8String], -1, 0);
    sqlite3_bind_double(statement, 3, [[product objectForKey:@"price"] doubleValue]);
    sqlite3_bind_double(statement, 4, [[product objectForKey:@"salePrice"] doubleValue]);
    sqlite3_bind_text(statement, 5, [[product objectForKey:@"image"] UTF8String], -1, 0);
    
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"insert failed: %s", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);

}

- (void)insertProductsWithArray:(NSArray*)array {
    NSString *instruction = @"INSERT INTO products (name, description, price, salePrice, image) VALUES(?,?,?,?,?)";
    
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL);
    for (NSDictionary *product in array) {
        sqlite3_bind_text(statement, 1, [[product objectForKey:@"name"] UTF8String], -1, 0);
        sqlite3_bind_text(statement, 2, [[product objectForKey:@"description"] UTF8String], -1, 0);
        sqlite3_bind_double(statement, 3, [[product objectForKey:@"price"] doubleValue]);
        sqlite3_bind_double(statement, 4, [[product objectForKey:@"salePrice"] doubleValue]);
        sqlite3_bind_text(statement, 5, [[product objectForKey:@"image"] UTF8String], -1, 0);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Insert array failed: %s", sqlite3_errmsg(database));
        }
        sqlite3_reset(statement);
    }
    
    sqlite3_finalize(statement);
}

- (NSArray*)queryProducts {
    NSMutableArray* queryResults = [NSMutableArray array];
    
    NSString* query = @"SELECT id, name FROM products ORDER BY id ASC";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int identifier = sqlite3_column_int(statement, 0);
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];

            NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:@(identifier), @"id", name, @"name", nil];
            [queryResults addObject:entry];
        }
        sqlite3_finalize(statement);
    }
    return queryResults;
}

- (NSDictionary*)queryProductWithIdentifier:(NSUInteger)productIdentifier {
    NSDictionary *retval = nil;
    
    NSMutableString *query = [NSMutableString stringWithString:@"SELECT "];
    [query appendString:@"id, name, description, price, salePrice, image "];
    [query appendFormat:@"FROM products WHERE id=%u", productIdentifier];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int identifier = sqlite3_column_int(statement, 0);
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            NSString *description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
            double price = sqlite3_column_double(statement, 3);
            double salePrice = sqlite3_column_double(statement, 4);
            NSString *image = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];

            retval = [NSDictionary dictionaryWithObjectsAndKeys:@(identifier), @"id",
                                                                name, @"name",
                                                                description, @"description",
                                                                @(price), @"price",
                                                                @(salePrice), @"salePrice",
                                                                image, @"image", nil];
            break;
       }
       sqlite3_finalize(statement);
    }
    return retval;
}

- (void)updateProduct:(NSDictionary *)product {
    NSMutableString *instruction = [NSMutableString stringWithString:@"UPDATE products SET "];
    [instruction appendFormat:@"name='%@', ",[product objectForKey:@"name"]];
    [instruction appendFormat:@"description='%@', ",[product objectForKey:@"description"]];
    [instruction appendFormat:@"price=%@, ",[product objectForKey:@"price"]];
    [instruction appendFormat:@"salePrice=%@, ",[product objectForKey:@"salePrice"]];
    [instruction appendFormat:@"image='%@' ",[product objectForKey:@"image"]];
    [instruction appendFormat:@"WHERE id=%@",[product objectForKey:@"id"]];
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"update failed: %s", sqlite3_errmsg(database));
    }
    sqlite3_finalize(statement);
}

- (void)deleteProduct:(NSDictionary *)product {
    NSString *instruction = [NSString stringWithFormat:@"DELETE FROM products WHERE id=%@", [product objectForKey:@"id"]];
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"delete failed: %s", sqlite3_errmsg(database));
    }
    sqlite3_finalize(statement);
}

@end

