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
//    [self testMainQAndAsync];
//
//    [self performSelectorInBackground:@selector(doWork) withObject:nil];
//
//    [self testGCDARC];
    
//    [self TestTargetQueue];
    
//    [self testAfter];
    
//    [self testGroupWait];
//    [self testDispatchApply];
        [self testSemaphore];
    
}

/**
 信号量
 */
- (void)testSemaphore {
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /**
    生成 dispatch semaphore
     保证可访问NSMutableArray 类对象的线程同时只能有1个
     */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 10000; ++i) {
        dispatch_async(queue, ^{
            /*
             等待dispatch semaphore
             一直等待，直到 dispatch semaphore 的计数值大于等于1
             */
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            /*
             由于dispatch semaphore 的计数值达到大于等于1
             所以将 dispatch semaphore 的计数值减去1，
             dispatch_semaphore_wait 函数返回
             即执行到此时的
             dispatch semaphore 的计数值恒为0
             由于可访问NSMutableArray类对象的线程只有一个，因此可安全的进行更新
             一直等待，直到 dispatch semaphore 的计数值大于等于1
             */
            
            [array addObject:[NSNumber numberWithInt:i]];
           
            /*
             排他控制处理结束，所以通过dispatch_semaphore_signal 将 dispatch_semaphore的计数值加1
             如果有通过dispatch_semaphore_wait 函数 等待dispatch_semaphore 的计数值增加的线程，就由最先等待的线程执行。
             */
            
            dispatch_semaphore_signal(semaphore);
            
        });
    }
}

- (void)testDispatchApply {
    NSArray *array = [NSArray arrayWithObjects:@"旧宫",@"新宫",@"太阳宫",@"雍和宫",@"北宫门",nil];
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply([array count], queue, ^(size_t index) {
        NSLog(@"%@",array[index]);
    });
    NSLog(@"done");
}

- (void)testGroupWait {
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk0");
        [NSThread sleepForTimeInterval:1.f];
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk1");
        [NSThread sleepForTimeInterval:1.f];
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"blk2");
        [NSThread sleepForTimeInterval:1.f];
    });
    
    //1ull * NSEC_PER_SEC
    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    if (result == 0) {
        NSLog(@"group 全部处理执行结束");
    }else {
        NSLog(@"group 还在执行");
    }
    
}

- (void)testAfter {
    NSLog(@"hehe");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"code to be executed after a specified delay");
    });
    NSLog(@"haha");
}

- (void)TestTargetQueue {
    // 优先级改变
//    dispatch_queue_t mySerialQueue = dispatch_queue_create("org.imaginedays", NULL);
//    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//    dispatch_set_target_queue(mySerialQueue, globalDispatchQueueBackground);
    
    
    //目标queue
    dispatch_queue_t targetQueue = dispatch_queue_create("test.target.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t queue1 = dispatch_queue_create("test.1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("test.2", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue2 = dispatch_queue_create("test.2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue3 = dispatch_queue_create("test.3", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    dispatch_set_target_queue(queue3, targetQueue);
    
    dispatch_async(queue1, ^{        NSLog(@"1 in");        [NSThread sleepForTimeInterval:3.f];        NSLog(@"1 out");    });
    dispatch_async(queue2, ^{        NSLog(@"2 in");        [NSThread sleepForTimeInterval:2.f];        NSLog(@"2 out");    });
    dispatch_async(queue3, ^{        NSLog(@"3 in");        [NSThread sleepForTimeInterval:1.f];        NSLog(@"3 out");    });

}

- (void)testGCDARC {
    dispatch_queue_t conqueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(conqueue, ^{
        NSLog(@"block on DISPATCH_QUEUE_CONCURRENT");
    });
}
- (void)doWork {
    //后台线程执行长时间任务
    
    //长时间任务执行结束
    [self performSelectorOnMainThread:@selector(doneWork) withObject:nil waitUntilDone:NO];
}

- (void)doneWork {
    //主线程执行任务
}

- (void)testMainQAndAsync {
    //DISPATCH_QUEUE_CONCURRENT DISPATCH_QUEUE_SERIAL
    dispatch_queue_t mainQuene = dispatch_queue_create("com.example.MySerialQueue", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t mainQuene = dispatch_get_main_queue();
    dispatch_async(mainQuene, ^{
        NSLog(@"1_current thread name = %@",[NSThread currentThread]);
    });
    NSLog(@"4");
    
    dispatch_sync(mainQuene, ^{
        NSLog(@"2_current thread name = %@",[NSThread currentThread]);
    });
    NSLog(@"5");
    
    dispatch_sync(mainQuene, ^{
        NSLog(@"3_current thread name = %@",[NSThread currentThread]);
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
