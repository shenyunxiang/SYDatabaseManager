//
//  SYSqlBaseAPI.m
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import "SYSqlBaseAPI.h"
#import "YYClassInfo.h"
#import "NSObject+YYModel.h"


@interface SYSqlBaseAPI ()
{
    dispatch_semaphore_t _lock;
}

@property(nonatomic,strong) FMDatabaseQueue *dbQueue;

@property(nonatomic, strong) FMDatabase        *db;


@end

@implementation SYSqlBaseAPI

static SYSqlBaseAPI *shareInstance = nil;


#pragma mark - Public Method
+ (SYSqlBaseAPI *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SYSqlBaseAPI alloc] init];
    });
    
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}


- (void)createDBWithdbPath:(nonnull NSString *)dbPath {
    
    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
    if (dbPath == nil || dbPath.length == 0) {
        NSLog(@"数据库路径有问题");
    } else {
        self.db = [FMDatabase databaseWithPath:dbPath];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    dispatch_semaphore_signal(self->_lock);

}

- (void)createTableWithJsonFile:(NSString *)jsonFileName UpdateTable:(BOOL)update{
    //获取要建的表SQL的信息
    NSArray *mArr = [self getCreateTableSQLArrWith:jsonFileName];

    if (mArr.count > 0) {
        
        BOOL success = [self executeSQLInTransactionWithSQLArr:mArr Value:nil];
        //是否要去插入新的字段
        if (update && success && [self.db open]) {
            NSDictionary *addColmunInfo = [self getAddColumnFields:jsonFileName];
            NSArray *SQLArr = [self getAllAddColumnSQL:addColmunInfo];
            [self executeSQLInTransactionWithSQLArr:SQLArr Value:nil];
        }
        
    }
    
}

//dic --> {表的名字,model}
- (BOOL)insertDataWithDic:(NSDictionary *)dic {
    
    NSArray *insertArr = [self getAllInsertSQLInfo:dic];
    
    BOOL success = [self executeSQLInTransactionWithSQLArr:insertArr[0] Value:insertArr[1]];

    return success;
}


- (NSArray *)getAllInsertSQLInfo:(NSDictionary *)dic {
    
    NSArray *tableNameArr = [dic allKeys];
    NSMutableArray *sql = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *tableName in tableNameArr) {
        NSArray *models = [dic valueForKey:tableName];
        for (id model in models) {
            NSArray *insert = [self getInsertSQL:tableName Model:model];
            [sql addObject:insert[0]];
            [values addObject:insert[1]];
        }
    }
 
    return @[sql, values];
}

//获取插入的SQL语句 和 插入的值
- (NSArray *)getInsertSQL:(NSString *)tableName Model:(id)model {
    
    NSString *operationSQL = @"INSERT INTO";
    NSString *fieldsSQL    = @"(";
    NSString *valuesSQL = @"VALUES(";
        
    NSDictionary *dic = [model modelToJSONObject];
    NSArray *fields       = [dic allKeys];
    NSArray *filterArr    = [NSArray array];
    if ([model respondsToSelector:@selector(modelContainerPropertyGenericClass)]) {
        NSDictionary *genericMapper = [model modelContainerPropertyGenericClass];
        filterArr = [genericMapper allKeys];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", filterArr];
    fields = [fields filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *valueArr = [NSMutableArray arrayWithCapacity:fields.count];
    for (NSString *field in fields) {
        
        NSInteger value = [[dic valueForKey:field] integerValue];
        if (value < 0) {
            continue;
        }
        
        fieldsSQL = [fieldsSQL stringByAppendingFormat:@"%@,",field];
        valuesSQL = [valuesSQL stringByAppendingFormat:@"?,"];
        [valueArr addObject:[dic valueForKey:field]];
    }
    fieldsSQL = [fieldsSQL substringToIndex:fieldsSQL.length - 1];
    fieldsSQL = [fieldsSQL stringByAppendingString:@")"];
    
    valuesSQL = [valuesSQL substringToIndex:valuesSQL.length - 1];
    valuesSQL = [valuesSQL stringByAppendingString:@")"];
    
    NSString *finalSQL = [NSString stringWithFormat:@"%@ %@ %@ %@", operationSQL,tableName, fieldsSQL, valuesSQL];
    NSLog(@"%@", finalSQL);
    return @[finalSQL,valueArr];
    
}


- (BOOL)executeSQLInTransactionWithSQLArr:(NSArray *)sqlArr {
    return [self executeSQLInTransactionWithSQLArr:sqlArr Value:nil];
}

//同步 事务 处理(传入的SQL语句不能为查询SQL语句)
- (BOOL)executeSQLInTransactionWithSQLArr:(NSArray *)sqlArr Value:(nullable NSArray *)value{
    
    if (sqlArr.count == 0) {
        return NO;
    }
    
    BOOL success = NO;
    success = [self transactionWithBlock:^BOOL(FMDatabase *db) {
        BOOL rollBack = NO;
        
        if (value) {
            for (int i = 0; i < sqlArr.count; i++) {
                NSString *sql = sqlArr[i];
                NSArray *valueAr = value[i];
                rollBack = [db executeQuery:sql values:valueAr error:nil];
                if (rollBack == NO) {
                    return YES;
                }
            }
            return NO;
        } else {
            for (NSString *sql in sqlArr) {
                rollBack = [db executeUpdate:sql];
                if (rollBack == NO) {
                    return YES;
                }
            }
            return NO;
        }
 
    }];
    
    return success;
}


//获取所有表的添加字段的SQL语句
- (NSArray *)getAllAddColumnSQL:(NSDictionary *)allAddColmunInfo {
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[allAddColmunInfo count]];
    NSArray *keys = [allAddColmunInfo allKeys];
    for (NSString *tableName in keys) {
        NSString *addSQL = [self getAddColumnSQL:[allAddColmunInfo valueForKey:tableName] TableName:tableName];
        [arr addObject:addSQL];
        NSLog(@"%@", addSQL);
    }
    
    return arr;
}

//获取添加字段的SQL语句
- (NSString *)getAddColumnSQL:(NSDictionary *)addColumnInfo TableName:(NSString *)tableName{
//    ALTER TABLE table_name(表名)﻿ ADD column_name(列名) datatype(数据类型)﻿
    
    NSString *operationSQL = @"ALTER TABLE";
    
    NSArray *fields = [addColumnInfo allKeys];
    
    NSString *fieldSQL = @"";
    for (NSString *field in fields) {
        NSString *value = [addColumnInfo valueForKey:field];
        NSString *final = [NSString stringWithFormat:@"%@ %@,",field, value];
        fieldSQL = [fieldSQL stringByAppendingString:final];
    }
    fieldSQL = [fieldSQL substringToIndex:fieldSQL.length - 1];
    NSString *finalSQL = [NSString stringWithFormat:@"%@ %@ ADD %@", operationSQL, tableName, fieldSQL];
    
    return finalSQL;
}

//获取要添加的字段
- (NSDictionary *)getAddColumnFields:(NSString *)jsonFileName {
    NSDictionary *dic = [self getCreateTableInfoWithJsonFile:jsonFileName];
    
    NSArray *tableNameArr = [dic allKeys];
     NSMutableDictionary *addColumDic = [NSMutableDictionary dictionary];
    for (NSString *tableName in tableNameArr) {
        NSDictionary *tableInfo = [dic valueForKey:tableName];
        NSArray *columnArr = [self getTableFields:self.db TableName:tableName];
        NSArray *jsonFieldArr = [tableInfo allKeys];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", columnArr];
        NSArray *addFieldArr = [jsonFieldArr filteredArrayUsingPredicate:predicate];
        
        if (addFieldArr.count != 0) {
           
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:addFieldArr.count];
            for (NSString *field in addFieldArr) {
                [mDic setObject:[tableInfo valueForKey:field] forKey:field];
            }
            [addColumDic setObject:mDic forKey:tableName];
        }
        
        
    }
    
    return addColumDic;
}

//获取数据库的一张标表的字段
- (NSArray *)getTableFields:(FMDatabase *)db TableName:(NSString *)tableName {
    
    if ([db open]) {
        FMResultSet * result = [db executeQuery:@"select * from SmartDeviceTab limit 1"];
        NSInteger columnCount = [result columnCount];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:columnCount];
        for (int i = 0; i < columnCount; i++) {
            [arr addObject:[result columnNameForIndex:i]];
        }
        
        return arr;
        
    } else {
        return nil;
    }
    
}



- (NSArray *)getCreateTableSQLArrWith:(NSString *)jsonFileName {
    
    NSDictionary *dic = [self getCreateTableInfoWithJsonFile:jsonFileName];
    //获取所有的表的名字
    NSArray *tableNameArr = [dic allKeys];
    
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSString *tableName in tableNameArr) {
        NSDictionary *tableInfo = [dic valueForKey:tableName];
        NSString *sql = [self getCreateTableSQLWithTableName:tableName TableInfo:tableInfo];
        [mArr addObject:sql];
    }
    
    return mArr;
}

- (NSString *)getCreateTableSQLWithTableName:(NSString *)tableName TableInfo:(NSDictionary *)tableInfo {
    
    NSString *operationSQL = @"CREATE TABLE IF NOT EXISTS";
    NSString *fieldSQL = @"(";
    
    NSArray *fields = [tableInfo allKeys];
    NSString *primaryKey = nil;
    for (NSString *field in fields) {
        NSString *value = [tableInfo valueForKey:field];
        
        if ([value containsString:@":"]) {
            NSArray *arr = [value componentsSeparatedByString:@":"];
            primaryKey = [arr lastObject];
            value = [arr firstObject];
        }
        
        NSString *final = [NSString stringWithFormat:@"%@ %@,",field, value];
        fieldSQL = [fieldSQL stringByAppendingString:final];
    }
    fieldSQL = [fieldSQL stringByAppendingString:primaryKey];
//    fieldSQL = [fieldSQL substringToIndex:fieldSQL.length - 1];
    fieldSQL = [fieldSQL stringByAppendingString:@")"];
    
    NSString *finalSQL = [NSString stringWithFormat:@"%@ %@ %@", operationSQL, tableName, fieldSQL];
    NSLog(@"创建数据表的SQL语句>>> %@", finalSQL);
    return finalSQL;
    
    
}

//同步的事务处理
- (BOOL)transactionWithBlock:(BOOL (^)(FMDatabase * db))block {
    
    if ([self.db open]) {
        [self.db beginTransaction];
        BOOL isRoolBack = NO;
        
        @try {
            isRoolBack = block(self.db);
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
            isRoolBack = YES;
        } @finally {
            if (!isRoolBack) {
                //事务提交
                [self.db commit];
            } else {
                //事务回退
                [self.db rollback];
            }
        }
        //关闭数库
        [self.db close];
        if (isRoolBack) {
            return NO;
        } else {
            return YES;
        }
        
    } else {
        return NO;
    }
    
}


//获取要创建的表的信息
- (NSDictionary *)getCreateTableInfoWithJsonFile:(NSString *)fileName {
    NSArray *arr = [fileName componentsSeparatedByString:@"."];
    NSString *file = arr[0];
    NSString *fileType = arr[1];
    
    NSString *strPath = [[NSBundle mainBundle] pathForResource:file ofType:fileType];
    
    NSAssert(strPath, @"获取的json文件名有问题");
    
    NSString *parseJason = [[NSString alloc] initWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [parseJason dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    
    if (error) {
        NSLog(@"获取创建的数据表的信息失败>>> %@", error);
    }
    
    return dic;
}
//获取要创建的表的SQL语句
- (NSString *)getCreateTableSQLWithTableName:(NSString *)tableName DetailInfo:(NSArray *)detailInfo {
    
    NSString *operationSQL = @"CREATE TABLE IF NOT EXISTS";
    
    NSString *fieldSQL = @"(";
    for (NSString *tempStr in detailInfo) {
        NSString *final = [NSString stringWithFormat:@"%@,",tempStr];
        fieldSQL = [fieldSQL stringByAppendingString:final];
    }
    fieldSQL = [fieldSQL substringToIndex:fieldSQL.length - 1];
    fieldSQL = [fieldSQL stringByAppendingString:@")"];
    
    NSString *finalSQL = [NSString stringWithFormat:@"%@ %@ %@", operationSQL, tableName, fieldSQL];
    NSLog(@"创建数据表的SQL语句>>> %@", finalSQL);
    return finalSQL;
}


- (void)syncExecuteDBIntransation:(id)object FMDatabase:(FMDatabase *)db{
    
    if (![db open]) {
        return;
    }
    
    [db beginTransaction];
    BOOL isRoolBack = NO;
    
    @try {
        
    } @catch (NSException *exception) {
        isRoolBack = YES;
        //事务回退
        [db rollback];
    } @finally {
        if (!isRoolBack) {
            //事务提交
            [db commit];
        }
    }
    //关闭数库
    [db close];
    
    
}

- (void)transationWithFMDatabase:(FMDatabase *)db Completion:(BOOL(^)(FMDatabase *db))block{
    
    if (![db open]) {
        block(db);
        return;
    }
    
    
    
    [db beginTransaction];
    BOOL isRoolBack = NO;
    @try {
       isRoolBack = block(db);
    } @catch (NSException *exception) {
        isRoolBack = YES;
    } @finally {
        if (!isRoolBack) {
            //事务提交
            [db commit];
        } else {
            //事务回退
            [db rollback];
        }
    }
    //关闭数库
    [db close];
    
}


- (void)excuteSQL:(NSString *)sqlStr ActionType:(SY_DB_ActionType)actionType Completion:(completionBlock)block{
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = nil;
        BOOL bRet = YES;
        NSString *msg = nil;
        if (actionType == SY_DB_SELECT) {//查询语句 需要返回记录集
            
            rs = [db executeQuery:sqlStr];
            
            
        } else {//更新操作 只关心操作是否执行成功，不关心记录集  返回布尔值  无执行结果
            
            bRet = [db executeUpdate:sqlStr];
            
        }
        
        if ([db hadError]) {
            bRet = NO;
            msg = [db lastErrorMessage];
            NSLog(@"executeSQL error %d:  %@",[db lastErrorCode],[db lastErrorMessage]);
        }
        
        
        block(bRet, rs, msg);
        
    }];
}

- (void)executeTransactionWithBlock:(void(^)(FMDatabase *db, BOOL *rollback))block{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(db, rollback);
    }];
}

- (void)queryIntransationWith:(NSArray *)sqlStrArr Completion:(void(^)(NSArray *rsArr, BOOL *rollback))block{
    
    [self executeTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *msg = nil;
        NSMutableArray *mArr = [NSMutableArray array];
        for (NSString *sqlStr in sqlStrArr) {
            
            FMResultSet *rs = [db executeQuery:sqlStr];
            if ([db hadError]) {
                msg = [db lastErrorMessage];
                NSLog(@"executeSql Err %d: %@", [db lastErrorCode], msg);
                break;
            }
            [rs close];
            [mArr addObject:rs];
        }
        
        block(mArr, rollback);
        
    }];
    
    
}

- (void)executeUpdataTransactionWith:(NSArray *)sqlArr Completion:(void(^)(BOOL success, BOOL *rollback))block{
    
    [self executeTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL success = NO;
        for (NSString *sqlStr in sqlArr) {
            success = [db executeUpdate:sqlStr];
            if (!success) {
                break;
            }
        }
        
        if ([db hadError]) {
            NSLog(@"executeSql Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        block(success, rollback);
        
    }];
    
}

#pragma mark - Private Method
//查询，更新 操作
- (void)executeSQL:(NSString *)sqlStr
            Values:(NSArray *)values
        ActionType:(SY_DB_ActionType)actionType
        Completion:(completionBlock)block {
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        FMResultSet *rs = nil;
        
        if (SY_DB_SELECT == actionType) {//查询
            rs = [db executeQuery:sqlStr values:values error:&error];
        } else {//更新
            [db executeUpdate:sqlStr values:values error:&error];
        }
        
        if (error) {
            NSLog(@"数据库操作错误>>>>> %@", error);
            block(NO, rs, [db lastErrorMessage]);
        } else {
            block(YES, rs, nil);
        }
        
    }];
    
}





@end
