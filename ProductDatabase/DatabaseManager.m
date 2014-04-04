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

@property (nonatomic, strong) NSArray *mockDataArray;

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
    [self loadMockData];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent: DatabaseFilename];
        
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL newDatabase = ![fileManager fileExistsAtPath: databasePath];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSMutableString *instruction = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS products ("];
        [instruction appendString:@"id INTEGER PRIMARY KEY AUTOINCREMENT, "];
        [instruction appendString:@"name TEXT, "];
        [instruction appendString:@"description TEXT, "];
        [instruction appendString:@"price REAL, "];
        [instruction appendString:@"salePrice REAL, "];
        [instruction appendString:@"image TEXT)"];
        
        char *errMsg;
        if (sqlite3_exec(database, [instruction UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"create products table failed: %s", sqlite3_errmsg(database));
        }
        
        instruction = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS colors ("];
        [instruction appendString:@"id INTEGER NOT NULL, "];
        [instruction appendString:@"color TEXT)"];
        
        if (sqlite3_exec(database, [instruction UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"create colors table failed: %s", sqlite3_errmsg(database));
        }
        
        if (newDatabase) {
            [self insertProductsWithArray:self.mockDataArray];
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

#pragma mark - Public Methods

- (NSArray *)queryProducts {
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

- (NSDictionary *)queryProductDetailsWithId:(NSUInteger)productIdentifier {
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
            NSArray *colors = [self queryColorsWithId:identifier];
            
            retval = [NSDictionary dictionaryWithObjectsAndKeys:@(identifier), @"id",
                                                                name, @"name",
                                                                description, @"description",
                                                                @(price), @"price",
                                                                @(salePrice), @"salePrice",
                                                                image, @"image",
                                                                colors,@"colors", nil];
            break;
        }
        sqlite3_finalize(statement);
    }
    return retval;
}

- (void)insertProduct:(NSDictionary*)product {
    NSString *instruction = @"INSERT INTO products (name, description, price, salePrice, image) VALUES(?,?,?,?,?)";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [[product objectForKey:@"name"] UTF8String], -1, 0);
        sqlite3_bind_text(statement, 2, [[product objectForKey:@"description"] UTF8String], -1, 0);
        sqlite3_bind_double(statement, 3, [[product objectForKey:@"price"] doubleValue]);
        sqlite3_bind_double(statement, 4, [[product objectForKey:@"salePrice"] doubleValue]);
        sqlite3_bind_text(statement, 5, [[product objectForKey:@"image"] UTF8String], -1, 0);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSUInteger identifier = (NSUInteger)sqlite3_last_insert_rowid(database);
            NSArray *colorArray = [product objectForKey:@"colors"];
            [self insertColors:colorArray withId:identifier];
        }
        else {
            NSLog(@"insert product failed: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    }
}

- (void)insertProductsWithArray:(NSArray*)array {
    NSString *instruction = @"INSERT INTO products (name, description, price, salePrice, image) VALUES(?,?,?,?,?)";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        for (NSDictionary *product in array) {
            sqlite3_bind_text(statement, 1, [[product objectForKey:@"name"] UTF8String], -1, 0);
            sqlite3_bind_text(statement, 2, [[product objectForKey:@"description"] UTF8String], -1, 0);
            sqlite3_bind_double(statement, 3, [[product objectForKey:@"price"] doubleValue]);
            sqlite3_bind_double(statement, 4, [[product objectForKey:@"salePrice"] doubleValue]);
            sqlite3_bind_text(statement, 5, [[product objectForKey:@"image"] UTF8String], -1, 0);
            
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSUInteger identifier = (NSUInteger)sqlite3_last_insert_rowid(database);
                NSArray *colorArray = [product objectForKey:@"colors"];
                [self insertColors:colorArray withId:identifier];
            }
            else {
                NSLog(@"insert product from array failed: %s", sqlite3_errmsg(database));
            }
            sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
    }
}

- (void)deleteProduct:(NSDictionary *)product {
    NSUInteger identifier = [[product objectForKey:@"id"] unsignedIntegerValue];
    NSString *instruction = [NSString stringWithFormat:@"DELETE FROM products WHERE id=%u", identifier];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            [self deleteColorsWithId:identifier];
        }
        else {
            NSLog(@"delete product failed: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    }
}

- (void)updateProduct:(NSDictionary *)product {
    NSUInteger identifier = [[product objectForKey:@"id"] unsignedIntegerValue];

    NSMutableString *instruction = [NSMutableString stringWithString:@"UPDATE products SET "];
    [instruction appendFormat:@"name='%@', ",[product objectForKey:@"name"]];
    [instruction appendFormat:@"description='%@', ",[product objectForKey:@"description"]];
    [instruction appendFormat:@"price=%@, ",[product objectForKey:@"price"]];
    [instruction appendFormat:@"salePrice=%@, ",[product objectForKey:@"salePrice"]];
    [instruction appendFormat:@"image='%@' ",[product objectForKey:@"image"]];
    [instruction appendFormat:@"WHERE id=%u",identifier];
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSArray *colorArray = [product objectForKey:@"colors"];
            [self updateColors:colorArray withId:identifier];
        }
        else {
            NSLog(@"update product failed: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    }
}

- (NSDictionary *)mockData {
    if (self.mockDataArray) {
        return [self.mockDataArray objectAtIndex:0];
    }
    return nil;
}


#pragma mark - Private Methods

- (void)loadMockData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:MockDataFilename ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error;
    self.mockDataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!self.mockDataArray) {
        NSLog(@"error parsing mock data: %@", [error localizedDescription]);
    }
}

- (NSArray *)queryColorsWithId:(NSUInteger)identifier {
    NSMutableArray* queryResults = [NSMutableArray array];
    
    NSString *query = [NSString stringWithFormat:@"SELECT color FROM colors WHERE id=%u", identifier];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *color = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            [queryResults addObject:color];
        }
        sqlite3_finalize(statement);
    }
    return queryResults;
}

- (void)insertColors:(NSArray *)colorArray withId:(NSUInteger)identifier {
    sqlite3_stmt *statement;
    NSString *instruction = @"INSERT INTO colors (id, color) VALUES(?,?)";
    if (sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        for (NSString *color in colorArray) {
            sqlite3_bind_int(statement, 1, identifier);
            sqlite3_bind_text(statement, 2, [color UTF8String], -1, 0);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"insert color failed: %s", sqlite3_errmsg(database));
            }
            sqlite3_reset(statement);
        }
        sqlite3_finalize(statement);
    }
}

- (void)deleteColorsWithId:(NSUInteger)identifier {
    NSString *instruction = [NSString stringWithFormat:@"DELETE FROM colors WHERE id=%u", identifier];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [instruction UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"delete colors failed: %s", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    }
}

- (void)updateColors:(NSArray *)colorArray withId:(NSUInteger)identifier {
    [self deleteColorsWithId:identifier];
    [self insertColors:colorArray withId:identifier];
}

@end

