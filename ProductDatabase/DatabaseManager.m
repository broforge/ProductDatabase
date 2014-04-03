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

@property (nonatomic,strong) NSString *databasePath;

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
    self.databasePath = [documentsDirectory stringByAppendingPathComponent: DatabaseFilename];
    
    NSLog(@"database path: %@", self.databasePath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: self.databasePath]) {
        const char *dbpath = [self.databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            NSMutableString *sqlString = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS products ("];
            [sqlString appendString:@"id INTEGER PRIMARY KEY AUTOINCREMENT, "];
            [sqlString appendString:@"name TEXT, "];
            [sqlString appendString:@"description TEXT, "];
            [sqlString appendString:@"price REAL, "];
            [sqlString appendString:@"salePrice REAL, "];
            [sqlString appendString:@"image TEXT)"];
            
            NSLog(@"sql statement: %@", sqlString);
            
            const char *sql_stmt = [sqlString cStringUsingEncoding:NSASCIIStringEncoding];
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to create table");
            }
            
            [self loadMockData];
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }
    else {
        const char *dbpath = [self.databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) != SQLITE_OK) {
            NSLog(@"Failed to open/create database");

        }
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
    
- (void)insertProductWithDictionary:(NSDictionary*)dictionary {
    
}
    
- (void)insertProductsWithArray:(NSArray*)array {
    sqlite3_stmt *insert_statement;
    const char *sql = "INSERT INTO products (id, name, description, price, salePrice, image) VALUES(?,?,?,?,?,?)";
    sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL);
    for (NSDictionary *item in array) {
        int identifier = [[item objectForKey:@"id"] integerValue];
        sqlite3_bind_int(insert_statement, 1, identifier);
        const char *name = [[item objectForKey:@"name"] UTF8String];
        sqlite3_bind_text(insert_statement, 2, name, -1, 0);
        const char *description = [[item objectForKey:@"description"] UTF8String];
        sqlite3_bind_text(insert_statement, 3, description, -1, 0);
        double price = [[item objectForKey:@"price"] doubleValue];
        sqlite3_bind_double(insert_statement, 4, price);
        double salePrice = [[item objectForKey:@"salePrice"] doubleValue];
        sqlite3_bind_double(insert_statement, 5, salePrice);
        const char *image = [[item objectForKey:@"image"] UTF8String];
        sqlite3_bind_text(insert_statement, 6, image, -1, 0);
        
        if (sqlite3_step(insert_statement) != SQLITE_DONE) {
            NSLog(@"Insert failed: %s", sqlite3_errmsg(database));
        }
        sqlite3_reset(insert_statement);
    }
    
    sqlite3_finalize(insert_statement);
}

- (NSArray*)queryProducts {
    NSMutableArray* queryResults = [NSMutableArray array];
    
    const char *sql = "SELECT id, name, image FROM products ORDER BY name ASC";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int identifier = sqlite3_column_int(statement, 0);
            NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            NSString *image = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];

            NSDictionary* entry = [NSDictionary dictionaryWithObjectsAndKeys:@(identifier), @"id",
                                                                            name, @"name",
                                                                            image, @"image", nil];

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

@end

