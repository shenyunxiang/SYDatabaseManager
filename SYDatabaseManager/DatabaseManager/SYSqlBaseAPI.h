//
//  SYSqlBaseAPI.h
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^completionBlock)(BOOL bRet, FMResultSet *rs, NSString  * _Nullable msg);

typedef NS_ENUM(NSInteger,SY_DB_ActionType) {
    SY_DB_SELECT = 0,//查询操作
    SY_DB_INSERT,	 //插入操作
    SY_DB_UPDATE,	 //更新操作
    SY_DB_DELETE,	 //删除操作
    SY_DB_ADDUPDATE	 //更新或者插入操作
};

@interface SYSqlBaseAPI : NSObject


+ (SYSqlBaseAPI *)shareInstance;


/**
 创建数据库

 @param dbPath 数据库的全路径
 */
- (void)createDBWithdbPath:(nonnull NSString *)dbPath;

/**
 创建数据库

 @param jsonFileName json文件名字(必须带上后缀(database.json))
 @param update 是否更新数据表(增加新字段)
 */
- (void)createTableWithJsonFile:(NSString *)jsonFileName UpdateTable:(BOOL)update;


- (BOOL)insertDataWithDic:(NSDictionary *)dic;

/**
 同步 事务 处理

 @param sqlArr SQL语句(传入的SQL语句不能为查询SQL语句)
 @return YES/NO
 */
- (BOOL)executeSQLInTransactionWithSQLArr:(NSArray *)sqlArr;

/**
 同步 事务 处理

 @param sqlArr SQL语句(传入的SQL语句不能为查询SQL语句)
 @param value 需要修改的的值
 @return YES/NO
 */
- (BOOL)executeSQLInTransactionWithSQLArr:(NSArray *)sqlArr Value:(nullable NSArray *)value;

/**
 使用 线程 执行单个sql语句 不需要使用事务处理 根据类型确定是否返回记录集

 @param sqlStr sql语句
 @param actionType 操作类型
 @param block 返回操作状态， FMResultSet， msg:错误信息
 */
- (void)excuteSQL:(NSString *)sqlStr ActionType:(SY_DB_ActionType)actionType Completion:(completionBlock)block;

/**
 使用 线程,事务 处理

 @param block  (FMDatabase,rollback)
 */
- (void)executeTransactionWithBlock:(void(^)(FMDatabase *db, BOOL *rollback))block;

/**
 使用 线程,事务 处理 查询语句(如果有一个出错,会中断查询)

 @param sqlStrArr 数组必须为全为查询语句
 @param block  (FMResultSet数组, *rollback:是否回滚)
 */
- (void)queryIntransationWith:(NSArray *)sqlStrArr Completion:(void(^)(NSArray *rsArr, BOOL *rollback))block;

/**
 使用 线程,事务 处理 修改,插入,删除操作(如果有一个出错,会中断)

 @param sqlArr SQL语句的数组
 @param block (所有操作是否成功，*rollback:是否回滚)
 */
- (void)executeUpdataTransactionWith:(NSArray *)sqlArr Completion:(void(^)(BOOL success, BOOL *rollback))block;

@end

NS_ASSUME_NONNULL_END
