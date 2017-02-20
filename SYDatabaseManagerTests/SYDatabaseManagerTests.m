//
//  SYDatabaseManagerTests.m
//  SYDatabaseManagerTests
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SYSqlBaseAPI.h"
@interface SYDatabaseManagerTests : XCTestCase

@end

@implementation SYDatabaseManagerTests

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
    
    
    NSString *baseString = @"eyAiQ21kVHlwZSI6ICJHRVRfTEFOX05FVF9JTkZPIiwgIlNlcXVlbmNlSWQiOiAiNTA2NiIsICJTdGF0dXMiOiAiMCIgLCJJbmZvIjoitefE1DpQQzoyMGNmMzBkYjc2ZjY6MTkyLjE2OC4xLjg6MDoxOnVua25vd25AV2luZG93czc6d2luZG93czoxOTk1Ny+7+ralutA6UEM6MzhhMjhjMjk3Y2YxOjE5Mi4xNjguMS40OjE6MDp1bmtub3duQFdpbmRvd3M3OndpbmRvd3M6NTYzOCJ9";
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:baseString options:0];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (str == nil) {
        str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    
    NSLog(@"%@", str);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
