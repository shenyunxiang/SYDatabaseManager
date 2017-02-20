//
//  SYDatabaseManager.m
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import "SYDatabaseManager.h"
#import "SYSqlBaseAPI.h"
@implementation SYDatabaseManager

- (void)insertToTable:(NSString *)tableName Data:(NSDictionary *)dic{
    
    return;
    NSString *operationSQL = @"INSERT INTO";
    
    NSString *fieldsSQL    = @"(";
    NSString *valuesSQL = @"VALUES(";
    NSArray *fields       = [dic allKeys];
    NSMutableArray *valueArr = [NSMutableArray array];
    for (NSString *field in fields) {
        fieldsSQL = [fieldsSQL stringByAppendingFormat:@"%@,",field];
        valuesSQL = [valuesSQL stringByAppendingFormat:@"?,"];
        [valueArr addObject:[dic valueForKey:field]];
    }
    fieldsSQL = [fieldsSQL substringToIndex:fieldsSQL.length - 1];
    fieldsSQL = [fieldsSQL stringByAppendingString:@")"];
    
    valuesSQL = [valuesSQL substringToIndex:valuesSQL.length - 1];
    valuesSQL = [valuesSQL stringByAppendingString:@")"];
    
    NSString *finalSQL = [NSString stringWithFormat:@"%@ %@ %@ %@", operationSQL,tableName, fieldsSQL, valuesSQL];
    
    NSLog(@"\n数据库SQL语句>>>>>\n %@ \n<<<<<<<<<<", finalSQL);
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/1.db"];
//    FMDatabase *db = [FMDatabase databaseWithPath:path];
//    
//    BOOL success = [db open];
    
    
    [FMDatabaseQueue databaseQueueWithPath:path];
    
    NSLog(@"%@", path);
    
}


- (NSArray *)queryAllFrom:(NSString *)tableName {
    NSString *operationSQL = @"SELECT * FROM";
    
    return nil;
}

@end
