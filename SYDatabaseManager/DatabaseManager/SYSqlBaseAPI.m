//
//  SYSqlBaseAPI.m
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import "SYSqlBaseAPI.h"

typedef void(^completionBlock)(BOOL bRet, FMResultSet *rs, NSString *msg);

@interface SYSqlBaseAPI ()
//数据库的全路径
@property(nonatomic, copy) NSString     *dbPath;

@property(nonatomic,strong) FMDatabaseQueue *dbQueue;


@end

@implementation SYSqlBaseAPI

static SYSqlBaseAPI *shareInstance = nil;

+ (SYSqlBaseAPI *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SYSqlBaseAPI alloc] init];
    });
    
    return shareInstance;
}


- (BOOL)createDatabaseAtPath:(NSString *)databasePath{
    NSFileManager * fmManger = [NSFileManager defaultManager];
    if ([fmManger fileExistsAtPath:databasePath]) {
        return YES;
    } else {
        BOOL success =  [fmManger createFileAtPath:databasePath
                                          contents:nil
                                        attributes:nil];
        if (success) {
            self.dbPath = databasePath;
            [self createFMDatabaseQueueWithPath:databasePath];
        } else {
            NSLog(@"创建数据库 %@ 失败",databasePath);
        }
        
        return success;
    }
}

- (void)createFMDatabaseQueueWithPath:(NSString *)dbPath{
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
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

- (void)queryIntransationWith:(NSArray *)sqlStrArr Completion:(void(^)(NSArray *rsArr, NSString *msg))block{
    
    [self executeTransactionWithBlock:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *msg = nil;
        NSMutableArray *mArr = [NSMutableArray array];
        for (NSString *sqlStr in sqlStrArr) {
            
            FMResultSet *rs = [db executeQuery:sqlStr];
            if ([db hadError]) {
                msg = [db lastErrorMessage];
                NSLog(@"executeSql Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                break;
            }
            [mArr addObject:rs];
        }
        block(mArr, msg);
        
    }];
    
    
}

- (void)executeTransactionWithBlock:(void(^)(FMDatabase *db, BOOL *rollback))block{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(db, rollback);
    }];
}






@end
