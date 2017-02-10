//
//  ViewController2.m
//  RACDemo
//
//  Created by cy on 2017/2/10.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "ViewController2.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "MBProgressHUD+XMG.h"

/*
 2017-02-10 12:05:44.235 RACDemo[97216:2813500] 点击登录按钮
 2017-02-10 12:05:44.237 RACDemo[97216:2813500] 发送登录请求
 2017-02-10 12:05:44.238 RACDemo[97216:2813500] 正在执行
 2017-02-10 12:05:44.821 RACDemo[97216:2813500] 获取命令中信号源 请求登录的数据
 2017-02-10 12:05:44.823 RACDemo[97216:2813500] 执行完成
 */

@interface ViewController2 ()

@property (weak, nonatomic) IBOutlet UITextField *accountFiled;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 两个输入框都有值才按钮才可以点击
    RACSignal *loginEnableSiganl = [RACSignal combineLatest:@[_accountFiled.rac_textSignal,_pwdField.rac_textSignal] reduce:^id(NSString *account,NSString *pwd){
        return @(account.length && pwd.length);
    }];
    
    // 设置按钮能否点击
    RAC(_loginBtn,enabled) = loginEnableSiganl;
    
    
    // 创建登录命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // block:执行命令就会调用
        // block作用:事件处理
        // 发送登录请求
        NSLog(@"发送登录请求");
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                // 发送数据
                [subscriber sendNext:@"登录的数据"];
                [subscriber sendCompleted];
            });
            
            return nil;
            
        }];
    }];
    
    // 获取命令中信号源
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"信号： %@",x);
    }];
    
    // 监听命令执行过程
    [[command.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
            // 显示蒙版
            [MBProgressHUD showMessage:@"正在登录ing.."];
            
        }else{
            // 执行完成
            // 隐藏蒙版
            [MBProgressHUD hideHUD];
            
            NSLog(@"执行完成");
        }
        
    }];
    
    
    // 监听登录按钮点击
    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"点击登录按钮");
        // 处理登录事件
        [command execute:nil];
        
    }];
}


@end
