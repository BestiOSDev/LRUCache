//
//  ViewController.m
//  LRUCacheExample
//
//  Created by dzb on 2019/3/18.
//  Copyright © 2019年 大兵布莱恩特. All rights reserved.
//

#import "LRUCache.h"
#import "Person.h"
#import "ViewController.h"

@interface ViewController () <LRUCacheDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LRUCache *cache = [LRUCache shareCache];
    cache.countLimit = 10;
    cache.ageLimit = 10.0f;
    cache.delegate = self;
    
    for (int i = 0; i<10; i++) {
        NSString *key = [NSString stringWithFormat:@"key_%d",i];
        Person *p = [[Person alloc] initWithName:key];
        [cache setObject:p forKey:key];
    }
    
}

/**
 每次被淘汰的缓存 就会调用这个方法
 
 @param lru 缓存类
 @param obj 将要被淘汰的缓存对象
 */
- (void) lurcache:(LRUCache *_Nullable)lru willEvictObject:(id _Nullable )obj {
    
}

@end
