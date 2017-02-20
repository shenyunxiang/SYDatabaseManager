//
//  SYDatabaseManager.h
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYDatabaseManager : NSObject


- (void)insertToTable:(NSString *)tableName Data:(NSDictionary *)dic;

@end
