//
//  ViewController.m
//  GCDSample
//
//  Created by imaginedays on 2018/9/20.
//  Copyright © 2018年 Robin Wong. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //测试信号量
//    [self dispatchSignal];
    ///
    //测试sync和async
    [self testMainQAndAsync];
}

- (void)testMainQAndAsync {
    dispatch_queue_t mainQuene = dispatch_get_main_queue();
    NSLog(@"current thread name = %@",[NSThread currentThread]);
    
    dispatch_async(mainQuene, ^{
        NSLog(@"1_current thread name = %@",[NSThread currentThread]);
        NSLog(@"1");
    });
    NSLog(@"2");
    
    dispatch_async(mainQuene, ^{
        NSLog(@"2_current thread name = %@",[NSThread currentThread]);
        NSLog(@"3");
    });
    NSLog(@"4");
    
    dispatch_async(mainQuene, ^{
        NSLog(@"3_current thread name = %@",[NSThread currentThread]);
        NSLog(@"5");
    });
    NSLog(@"6");
    
}

- (void)dispatchSignal {
    //crate的value表示，最多几个资源可访问
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //任务1
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 1");
        sleep(1);
        NSLog(@"complete task 1");
        dispatch_semaphore_signal(semaphore);
    });
    
    //任务2
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 2");
        sleep(1);
        NSLog(@"complete task 2");
        dispatch_semaphore_signal(semaphore);
    });
    
    //任务3
    dispatch_async(quene, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"run task 3");
        sleep(1);
        NSLog(@"complete task 3");
        dispatch_semaphore_signal(semaphore);
    });
}

@end
