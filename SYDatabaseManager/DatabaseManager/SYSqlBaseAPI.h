//
//  SYSqlBaseAPI.h
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

typedef NS_ENUM(NSInteger,SY_DB_ActionType) {
    SY_DB_SELECT = 0,//查询操作
    SY_DB_INSERT,	 //插入操作
    SY_DB_UPDATE,	 //更新操作
    SY_DB_DELETE,	 //删除操作
    SY_DB_ADDUPDATE	 //更新或者插入操作
};

@interface SYSqlBaseAPI : NSObject

@end
