//
//  ViewController.m
//  SYDatabaseManager
//
//  Created by 沈云翔 on 2016/12/3.
//  Copyright © 2016年 shenyunxiang. All rights reserved.
//

#import "ViewController.h"
#import "SYDatabaseManager.h"
#import <FMDB.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *dic = @{@"name":@"s", @"sda": @"d"};
    SYDatabaseManager *mana = [[SYDatabaseManager alloc] init];
    [mana insertToTable:@"f" Data:dic];
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
