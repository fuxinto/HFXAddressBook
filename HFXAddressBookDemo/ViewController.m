//
//  ViewController.m
//  HFXAddressBookDemo
//
//  Created by fa_mac_one on 2017/9/1.
//  Copyright © 2017年 黄福鑫. All rights reserved.
//

#import "ViewController.h"
#import "AddressBookVC.h"


@interface ViewController ()<HFXAddressBookDelegate>{
    
    UILabel *label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"点我打开通讯录" forState:UIControlStateNormal];
    
    button.frame = CGRectMake(100, 150, 200, 30);
    [button setBackgroundColor:[UIColor orangeColor]];
    [button addTarget:self action:@selector(buttonActionClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [self.view addSubview:button];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 400, 30)];
    label.contentMode = UIViewContentModeCenter;
    label.text = @"未选择通讯录";
    [self.view addSubview:label];
}


- (void)buttonActionClick {
    
    AddressBookVC *VC = [[AddressBookVC alloc]init];
    
    VC.delegate = self;
    
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:VC];
    
    [self presentViewController:naVC animated:YES completion:nil];
    
}


- (void)currentSelectWithName:(NSString *)name phoneNumber:(NSString *)phoneNumber {
    label.text = [NSString stringWithFormat:@"名字：%@,电话:%@",name,phoneNumber];
    
    NSLog(@"选择的名字：%@,电话号码:%@",name,phoneNumber);
}



@end
