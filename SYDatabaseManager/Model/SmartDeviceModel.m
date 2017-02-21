//
//  SmartDeviceModel.m
//  EpaiSmartRouter
//
//  Created by 沈云翔 on 2017/2/15.
//  Copyright © 2017年 epai. All rights reserved.
//

#import "SmartDeviceModel.h"

@implementation SmartDeviceModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _idFromServer = -1;
        _deviceId     = -1;
    }
    return self;
}

//返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"deviceName"              : @"deviceName",
             @"deviceType"              : @"deviceCd",
             @"deviceMac"               : @"mac",
             @"idFromServer"            : @"inDeviceInstId",
             @"deviceId"                : @"deviceId",
             @"providersName"           : @"providersName",
             @"userAcct"                : @"userAcct",
             @"Bolian_Lock"             : @"lockFlag",
             @"Bolian_Password"         : @"passwd",
             @"Bolian_communicationId"  : @"communicationId",
             @"Bolian_Key"              : @"keyValue",
             @"childDevice"             : @"ruleFile"
             };
}


// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"childDevice" : [SmartChildDevice class]};
}

@end


#pragma mark - SmartChildDevice
@implementation SmartChildDevice



@end
