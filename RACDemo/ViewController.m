//
//  ViewController.m
//  RACDemo
//
//  Created by cy on 2017/2/9.
//  Copyright © 2017年 cy. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>
#import "Flag.h"
#import "RedView.h"

@interface ViewController ()

/**模型数组*/
@property(nonatomic,strong) NSMutableArray *modelArr;

@property (weak, nonatomic) IBOutlet RedView *mRedView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation ViewController

- (IBAction)onBtnClick:(id)sender {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testRACSignal];
//    [self testRACSubject];
//    [self testRACReplaySubject];
    
//    [self testRACSequence2];
    
//    [self testDelegate];
//    [self testKVO];
    
//    [self method1];
//    [self method2]; // 绑定后不能在绑定了,否则会报错
    
//    [self testBind];
//    [self map];
     [self flattenMap];
/*
#pragma mark - RACMulticastConnection  Multicast:多路传送
    
    //    1、创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //            发送网络请求，请求数据
        //            得到网络数据，通过信号发送
        [subscriber sendNext:@"网络的数据"];
        return nil;
    }];
    
    //    2、把信号转换成连接类
    RACMulticastConnection *connect = [signal publish];
    
    //    3、订阅连接类的信号
    //    注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    
     //订阅信号：创建订阅者；
     //将“处理数据的block”保存到订阅者；
     //从信号中取出 “didSubscribe block”，传入订阅者，执行 -- 取出订阅者的“sendNext block/处理数据”执行;
 
    //    第一次订阅信号
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"第一次获取到数据：%@",x);
    }];
    NSLog(@"第一次订阅");
    //    第二次订阅信号
    //    第一次订阅信号
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"第二次获取到数据：%@",x);
    }];
    NSLog(@"第二次订阅");
    
    //    4、连接激活信号
    NSLog(@"连接激活信号");
    [connect connect];
    */
}

#pragma mark - 信号发送类型一：一订阅就发送  RACSubscriber
/*
 RACSignal信号：一旦订阅就自动的发送数据;
 
 1、创建信号：保存block1到信号中（block1，里面使用订阅者发送信号）
 
 2、订阅信号：创建一个订阅者；
 保存block2到订阅者中（block2里面有处理信号操作）；
 从信号中取出block1，传入订阅者并执行-->发送信号；
 3、发送信号：
 拿到传入的订阅者，执行订阅者的block2;
 */
- (void)testRACSignal{
    //    1、创建信号
    /*
     block didSubscribe  
     参数：block - 参数：RACSubscriber订阅者
     返回值：RACDisposable
     */
    RACDisposable *(^didSubscribe)(id<RACSubscriber> subscriber) = ^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"信号被订阅，将自动发送...");
        
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好调用此方法，发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        // block调用时刻：当信号发送完成/错误，就会自动执行这个block,取消订阅信号,执行完Block后，当前信号就不再被订阅了。
        return [RACDisposable disposableWithBlock:^{
            
            NSLog(@"信号被销毁");
            
        }];
    };
    
    RACSignal *signal = [RACSignal createSignal:didSubscribe];
    
    //    2、订阅信号（冷信号->热信号;冷信号:值改变了也不会触发）
    [signal subscribeNext:^(id x) {
        NSLog(@"接收到信号,信号携带的数据是：%@",x);
    }];
}

#pragma mark - 信号发送类型二：手动发送信号 RACSubject
/*
 RACSignal信号：订阅，要手动发送
 
 1、创建信号：
 2、订阅信号：创建一个订阅者；
 保存block到订阅者中（接收到信号后对数据的处理，发送信号触发）；
 保存订阅者到信号的“订阅者数组”中；
 3、发送信号：遍历信号的“订阅者数组”，然后执行保存在订阅者中的block;
 (这里不是订阅者发送信号的，而是信号实现了 <RACSubscriber>协议 成为了一个订阅者)
 */
- (void)testRACSubject{
    //    1、创建信号提供者
    RACSubject *subject = [RACSubject subject];
    //    2、订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"接收到了数据%@，对数据进行处理",x);
    }];
    //    3、发送信号
    [subject sendNext:@"666"];
}

#pragma mark - 信号发送类型二：手动发送信号（可以重复发送） RACReplaySubject
/*
 RACReplaySubject信号:
 
 1、创建信号：
 2、订阅信号：创建订阅者；
 保存block到订阅者中（接收到信号后对数据的处理，发送信号触发）；
 遍历信号中“存储值的数组” + 遍历"订阅者数组"，一个一个调用订阅者的nextBlock；
 
 3、发送信号：把值保存起来；
 遍历信号中“存储值的数组” + 遍历"订阅者数组"，一个一个调用订阅者的nextBlock；
 (这里不是订阅者发送信号的，而是信号实现了 <RACSubscriber>协议 成为了一个订阅者)
 2、3步可以交换位置：先订阅再发送：值为空，
 先发送再订阅：订阅者为空
 */
- (void)testRACReplaySubject{
    // 1.创建信号提供者
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
}

#pragma mark -
#pragma mark - RACTuple（元组类）

- (void)testRACTuple{
    NSArray *arr = @[@"哈哈",@"呵呵",@666];
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:arr];
    NSString *str = tuple[0];
    NSLog(@"%@",str);
}

#pragma mark - RACSequence（集合类）
/*
 RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
 */
// 遍历数组
- (void)testRACSequence1{
    NSArray *arr = @[@"哈哈",@"呵呵",@"嘿嘿",@"额额",@"恩恩"];
    
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [arr.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

// 遍历字典
- (void)testRACSequence2{
    
    NSDictionary *dict = @{
                           @"name" : @"李明",
                           @"num" : @13234345555,
                           @"address" : @"北京"};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple* x) {
        //元组 -> 值
        /*
         宏里面的参数:传需要解析出来的变量名
         等号右边:放需要解析的元组
         */
        RACTupleUnpack(NSString* key,NSString* value) = x;
        NSLog(@"%@ %@",key,value);
    }];
}

// 字典转模型1
- (void)testRACSequence3{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:path];
    
    _modelArr = [NSMutableArray array];
    
    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会
    [dictArr.rac_sequence.signal subscribeNext:^(NSDictionary *x) { // id x --> NSDictionary* x
        Flag *flag = [Flag flagWithDict:x];
        [_modelArr addObject:flag];
    }];
    NSLog(@"%@",_modelArr);
}

//字典转模型2-高级用法
- (void)testRACSequence4{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:path];
    
    _modelArr = [NSMutableArray array];
    
    /*
     map:映射的意思，目的：把原始值value映射成一个新值
     array: 把集合转换成数组
     底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
     映射 需要有什么条件吗？ 比如 字典key和模型的属性名一致？？？
     */
    NSArray *flags = [[dictArr.rac_sequence map:^id(id value) {
        
        return [Flag flagWithDict:value];
        
    }] array];
    
    NSLog(@"%@",flags);
}

#pragma mark -
#pragma mark - 代替代理
/*
 需求：自定义redView，向redView中添加一个按钮,监听按钮点击，通知外界做事情
 
 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
 
 rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
 
 代替代理:
 1.RACSubject；只要传值,就必须使用RACSubject
 2.rac_signalForSelector
 
 */
- (void)testDelegate{
    //    subscribeNext / nextblock： 当订阅信号的时候执行的block,用于存放处理数据的代码
    [[_mRedView rac_signalForSelector:@selector(onBtnClick:)] subscribeNext:^(id x) {
        NSLog(@"外界知道了按钮被点击");
    }];
}

#pragma mark - 代替KVO
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _mRedView.frame = CGRectMake(0, 0, 100, 100);
}
/*
 rac_valuesAndChangesForKeyPath：用于监听某个对象的属性改变。
 */
- (void)testKVO{
    
    [[_mRedView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //    ???
    //    [_mRedView rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
    //        //
    //
    //    }];
}

#pragma mark - 监听事件
/*
 rac_signalForControlEvents：用于监听某个事件。
 */
- (void)testEvent{
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮点击了%@",x);
    }];
}


#pragma mark - 代替通知
/*
 rac_addObserverForName:用于监听某个通知
 */
- (void)testNotification{
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出了");
    }];
}

#pragma mark - 监听文本框文字改变
/*
 rac_textSignal:只要文本框发出改变就会发出这个信号。
 */
- (void)testTextFiled{
    [_textField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - 处理当界面有多次请求时，需要都获取到数据时，才能展示界面
- (void)testLiftSelector{
    //    热销模块
    RACSignal *hotSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //        在此进行网络请求，一订阅就请求数据
        //        当请求到数据的时候，将数据传出去处理
        [subscriber sendNext:@"热销模块的数据"];
        NSLog(@"热销模块的数据已经获取");
        return nil;
    }];
    //    新品模块
    RACSignal *newSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"新品模块的数据已经获取");
            [subscriber sendNext:@"新品模块的数据"];
        });
        return nil;
    }];
    
    /*
     数组:存放信号
     当数组中的所有信号都发送数据的时候,才会执行Selector
     方法的参数:必须跟数组的信号一一对应,在从服务器获取数据后，通过信号发送我们的
     */
    [self rac_liftSelector:@selector(updateUI:and:) withSignalsFromArray:@[hotSignal,newSignal]];
    
}

// 更新UI
- (void)updateUI:(NSString*)hotData and:(NSString*)newData{
    NSLog(@"%@，%@ 已经都获取到，一起在UI上展示",hotData,newData);
}

#pragma mark -
#pragma mark - 常用宏

#pragma mark - RAC(TARGET, [KEYPATH, [NIL_VALUE]])
/*
 用于给某个对象的某个属性绑定。
 */
- (void)method1{
    // 只要文本框文字改变，就会修改label的文字
    RAC(self.label, text) = self.textField.rac_textSignal;
}


#pragma mark - RACObserve(self, name)
/*
 监听某个对象的某个属性,返回的是信号
 */
- (void)method2{
    
    RAC(self.label, text) = self.textField.rac_textSignal;
    
    [RACObserve(self.label, text) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - @weakify(Obj)和@strongify(Obj)
/*
 一般两个都是配套使用,解决循环引用问题.
 */
- (void)method3{
    
}

#pragma mark - RACTuplePack/RACTupleUnpack
/*
 元组类 就是一组数据
 RACTuplePack：把数据包装成RACTuple（元组类）
 RACTupleUnpack：把RACTuple（元组类）解包成对应的数据。
 */
- (void)method4{
    RACTuple *tuple = RACTuplePack(@10,@20);
    NSLog(@"%@",tuple[0]);
}

#pragma mark -
#pragma mark - 核心操作方法：绑定、映射、组合、过滤

- (void)testBind{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.绑定信号
    RACSignal *bindSignal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal *(id value, BOOL *stop){
            // block调用:只要源信号发送数据,就会调用block
            // block作用:处理源信号内容
            // value:源信号发送的内容

            NSLog(@"接收到原信号的内容:%@",value);

            value = [NSString stringWithFormat:@"xmg:%@",value];
            // 返回信号,不能传nil,返回空信号[RACSignal empty]
            return [RACReturnSignal return:value];
        };
    }];
    
// 早期写法：
//    RACSignal *bindSignal = [subject bind:^RACStreamBindBlock{
//        // block调用时刻:只要绑定信号被订阅就会调用
//        
//        
//        return ^RACSignal *(id value, BOOL *stop){
//            // block调用:只要源信号发送数据,就会调用block
//            // block作用:处理源信号内容
//            // value:源信号发送的内容
//            
//            NSLog(@"接收到原信号的内容:%@",value);
//            
//            value = [NSString stringWithFormat:@"xmg:%@",value];
//            // 返回信号,不能传nil,返回空信号[RACSignal empty]
//            return [RACReturnSignal return:value];
//        };
//    }];
    
    // 3.订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        // blcok:当处理完信号发送数据的时候,就会调用这个Block
        NSLog(@"接收到绑定信号处理完的信号%@",x);
    }];
    
    // 4.发送数据
    [subject sendNext:@"123"];
}

#pragma mark - 映射

- (void)map
{
    // @"123"
    // @"xmg:123"
    
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 绑定信号
    RACSignal *bindSignal = [subject map:^id(id value) {
        // 返回的类型,就是你需要映射的值
        return [NSString stringWithFormat:@"xmg:%@",value];
        
    }];
    
    // 订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"123"];
    [subject sendNext:@"321"];
}

- (void)flattenMap
{
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        // block:只要源信号发送内容就会调用
        // value:就是源信号发送内容
        
        value = [NSString stringWithFormat:@"xmg:%@",value];
        
        // 返回信号用来包装成修改内容值
        return [RACReturnSignal return:value];
    }];
    
//    早期写法
//    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
//        // block:只要源信号发送内容就会调用
//        // value:就是源信号发送内容
//        
//        value = [NSString stringWithFormat:@"xmg:%@",value];
//        
//        // 返回信号用来包装成修改内容值
//        return [RACReturnSignal return:value];
//        
//    }];
    
    // flattenMap中返回的是什么信号,订阅的就是什么信号
    
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    
    // 发送数据
    [subject sendNext:@"123"];
}

#pragma mark - 过滤

- (void)skip{
    // skip;跳跃几个值
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    [[subject skip:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
}

- (void)distinctUntilChanged
{
    // distinctUntilChanged:如果当前的值跟上一个值相同,就不会被订阅到
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"2"];
}

- (void)take
{
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    RACSubject *signal = [RACSubject subject];
    
    // take:取前面几个值
    // takeLast:取后面多少个值.必须要发送完成
    // takeUntil:只要传入信号发送完成或者发送任意数据,就不能在接收源信号的内容
    [[subject takeUntil:signal] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    
    //    [signal sendNext:@1];
    //    [signal sendCompleted];
    [signal sendError:nil];
    
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    
}

- (void)ignore
{
    
    // ignore:忽略一些值
    // ignoreValues:忽略所有的值
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.忽略一些
    RACSignal *ignoreSignal = [subject ignoreValues];
    
    // 3.订阅信号
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.发送数据
    [subject sendNext:@"13"];
    [subject sendNext:@"2"];
    [subject sendNext:@"44"];
    
}
- (void)filter
{
    // 只有当我们文本框的内容长度大于5,才想要获取文本框的内容
    [[_textField.rac_textSignal filter:^BOOL(id value) {
        // value:源信号的内容
        return  [value length] > 5;
        // 返回值,就是过滤条件,只有满足这个条件,才能能获取到内容
        
    }] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

#pragma mark - 组合

- (void)reduce{
    // reduce:聚合
    
//    // reduceBlock参数:根组合的信号有关,一一对应
//    RACSignal *comineSiganl = [RACSignal combineLatest:@[_accountFiled.rac_textSignal,_pwdField.rac_textSignal] reduce:^id(NSString *account,NSString *pwd){
//        // block:只要源信号发送内容就会调用,组合成新一个值
//        NSLog(@"%@ %@",account,pwd);
//        // 聚合的值就是组合信号的内容
//        
//        return @(account.length && pwd.length);
//    }];
//    
//    // 订阅组合信号
//    //    [comineSiganl subscribeNext:^(id x) {
//    //        _loginBtn.enabled = [x boolValue];
//    //    }];
//    
//    RAC(_loginBtn,enabled) = comineSiganl;
}

- (void)zip
{
    // zipWith:夫妻关系
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    
    // 压缩成一个信号
    // zipWith:当一个界面多个请求的时候,要等所有请求完成才能更新UI
    // zipWith:等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    // 订阅信号
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 发送信号
    [signalB sendNext:@2];
    [signalA sendNext:@1];
    
}

// 任意一个信号请求完成都会订阅到
- (void)merge
{
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    
    // 组合信号
    RACSignal *mergeSiganl = [signalA merge:signalB];
    
    // 订阅信号
    [mergeSiganl subscribeNext:^(id x) {
        // 任意一个信号发送内容都会来这个block
        NSLog(@"%@",x);
    }];
    
    // 发送数据
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}

- (void)then
{
    // 创建信号A
    RACSignal *siganlA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送上部分请求");
        // 发送信号
        [subscriber sendNext:@"上部分数据"];
        
        // 发送完成
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    // 创建信号B
    RACSignal *siganlB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送下部分请求");
        // 发送信号
        [subscriber sendNext:@"下部分数据"];
        
        return nil;
    }];
    
    // 创建组合信号
    // then:忽悠掉第一个信号所有值
    RACSignal *thenSiganl = [siganlA then:^RACSignal *{
        // 返回信号就是需要组合的信号
        return siganlB;
    }];
    
    // 订阅信号
    [thenSiganl subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
}

- (void)concat
{
    // 组合
    // concat:皇上,皇太子
    // 创建信号A
    RACSignal *siganlA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送上部分请求");
        // 发送信号
        [subscriber sendNext:@"上部分数据"];
        
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *siganlB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送下部分请求");
        // 发送信号
        [subscriber sendNext:@"下部分数据"];
        
        return nil;
    }];
    
    // concat:按顺序去连接
    // 注意:concat,第一个信号必须要调用sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [siganlA concat:siganlB];
    
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        
        // 既能拿到A信号的值,又能拿到B信号的值
        NSLog(@"%@",x);
        
    }];
    
}


@end
