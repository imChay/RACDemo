
//
//  ViewController2.m
//  ReactiveCocoa
//
//  Created by cy on 15/10/27.
//  Copyright © 2015年 cy. All rights reserved.
//

#import "ViewController2.h"

@implementation ViewController2

- (void)viewDidLoad{
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc{
    NSLog(@"控制器销毁了");
}

@end
