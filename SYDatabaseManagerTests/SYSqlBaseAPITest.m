//
//  SYSqlBaseAPITest.m
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2017/2/17.
//  Copyright © 2017年 shenyunxiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SYSqlBaseAPI.h"
#import "NSObject+YYModel.h"
#import "SmartDeviceModel.h"
@interface SYSqlBaseAPITest : XCTestCase

@end

@implementation SYSqlBaseAPITest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    
    
    SYSqlBaseAPI *manager = [SYSqlBaseAPI shareInstance];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/test.db"];
    NSLog(@"%@", path);
    [manager createDBWithdbPath:path];
//    [manager createTableWithJsonFile:@"databaseJson.json" UpdateTable:YES];
    
    
    SmartDeviceModel *model = [[SmartDeviceModel alloc] init];
    model.deviceMac = @"ee";
    
    
    [manager insertDataWithDic:@{@"device":@[model]}];
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
