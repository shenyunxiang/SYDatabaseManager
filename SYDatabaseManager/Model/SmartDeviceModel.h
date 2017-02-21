//
//  SmartDeviceModel.h
//  EpaiSmartRouter
//
//  Created by 沈云翔 on 2017/2/15.
//  Copyright © 2017年 epai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YYModel.h"

/**
 智能设备的模型
 */
@interface SmartDeviceModel : NSObject
//设备的名字
@property(nonatomic, copy) NSString     *deviceName;
//设备类型
@property(nonatomic, copy) NSString     *deviceType;
//设备Mac
@property(nonatomic, copy) NSString     *deviceMac;
//来自于服务器的ID（在删除，修改设备时必要的参数）
@property(nonatomic, assign) NSInteger    idFromServer;
//来自于服务器的deviceId（添加设备时必要的参数）
@property(nonatomic, assign) NSInteger    deviceId;
//厂商名字
@property(nonatomic, copy) NSString     *providersName;
//用户名字
@property(nonatomic, copy) NSString     *userAcct;

#pragma mark 博联设备需要的信息
//
@property(nonatomic, copy) NSString     *Bolian_Lock;
//设备的密码
@property(nonatomic, copy) NSString     *Bolian_Password;
//
@property(nonatomic, copy) NSString     *Bolian_communicationId;
//
@property(nonatomic, copy) NSString     *Bolian_Key;
//
@property(nonatomic, strong) NSArray        *childDevice;

#pragma mark 虎符设备需要的信息

@end

@interface SmartChildDevice : NSObject

@property(nonatomic, copy) NSString     *a;


@end
