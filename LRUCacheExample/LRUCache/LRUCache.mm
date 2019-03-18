//
//  LRUCache.m
//  LRUCache
//
//  Created by dzb on 2019/3/18.
//  Copyright © 2019年 大兵布莱恩特. All rights reserved.
//

#include <map>
#include <unistd.h>
#include <pthread.h>
#import "LRUCache.h"
#include "LinkList.hpp"
#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif
#include <QuartzCore/QuartzCore.h>

#import <CoreFoundation/CoreFoundation.h>

using namespace std;

/// 任意类型指针
typedef void * AnyObject;
///链表数据节点
typedef  LinkList<AnyObject>::LinkNode  LinkNodeType;
typedef  multimap<NSString *, LinkNodeType *>::iterator MapIterator;

#define PointerBridge(obj) ((__bridge id)obj)
#define ObjectBridge(obj) ((__bridge_retained AnyObject)obj)

@interface LRUCache () <NSCopying,NSMutableCopying>

@property (nonatomic,assign) LinkList<AnyObject> *linkList; ///链表
@property (nonatomic,assign,readonly) pthread_mutex_t lock; ///线程同步锁
@property (nonatomic,assign) multimap<NSString *, LinkNodeType *> *dict;

@end

@implementation LRUCache

@dynamic shareCache;

+ (LRUCache *)shareCache {
    return [[super alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static LRUCache *_lru_cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lru_cache = [super allocWithZone:zone];
        _lru_cache.countLimit = NSUIntegerMax;
        _lru_cache.costLimit = NSUIntegerMax;
        _lru_cache.ageLimit = DBL_MAX;
        NSLog(@"%lu",(unsigned long)_lru_cache.ageLimit);
        _lru_cache->_autoTrimInterval = 5.0f;
        [_lru_cache _trimRecursively];
        pthread_mutex_init(&_lru_cache->_lock,NULL);
        _lru_cache->_shouldRemoveAllObjectsOnMemoryWarning = YES;
#if __has_include(<UIKit/UIKit.h>)
        [[NSNotificationCenter defaultCenter] addObserver:_lru_cache selector:@selector(_appDidReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    });
    return _lru_cache;
}

/**
 递归检查缓存情况
 */
- (void) _trimRecursively {
    
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf _trimInBackground];
        [strongSelf _trimRecursively];
    });
    
}

/**
 后台进程进行旧数据淘汰
 */
- (void) _trimInBackground {
    [self _trimToCount:self.countLimit];
    [self _trimToCost:self.costLimit];
    [self _trimToAge:self.ageLimit];
}

- (void)_trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        self.linkList->clear_by_completion(NULL);
        finish = YES;
    } else if (countLimit <= self.linkList->size()) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;

    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            int size = self.linkList->size();
            if (size > countLimit) { ///移除尾结点数据
                LinkNodeType *last = self.linkList->lastObject();
                self.dict->erase([NSString stringWithUTF8String:last->_key]);
                AnyObject obj = self->_linkList->remove_tail_node();
                if ([self.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
                    [self.delegate lurcache:self willEvictObject:PointerBridge(obj)];
                }
                CFRelease(obj);
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    

}

- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        self.linkList->clear_by_completion([](AnyObject obj){
            typeof(self)weakSelf = LRUCache.shareCache;
            if ([weakSelf.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
                [weakSelf.delegate lurcache:weakSelf willEvictObject:PointerBridge(obj)];
            }
            CFRelease(obj);
        });
        finish = YES;
    } else if (self.linkList->_totalCost <= costLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (self.linkList->_totalCost > costLimit) {
                LinkNodeType *last = self.linkList->lastObject();
                self.dict->erase([NSString stringWithUTF8String:last->_key]);
                AnyObject obj = self->_linkList->remove_tail_node();
                if ([self.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
                    [self.delegate lurcache:self willEvictObject:PointerBridge(obj)];
                }
                CFRelease(obj);
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
}

- (void)_trimToAge:(NSTimeInterval)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    LinkNodeType *lastNode = self.linkList->lastObject();
    if (ageLimit <= 0) {
        self.linkList->clear_by_completion([](AnyObject obj){
            typeof(self)weakSelf = LRUCache.shareCache;
            if ([weakSelf.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
                [weakSelf.delegate lurcache:weakSelf willEvictObject:PointerBridge(obj)];
            }
            CFRelease(obj);
        });
        finish = YES;
    } else if (lastNode == NULL || (now - lastNode->_time) <= ageLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            lastNode = self.linkList->lastObject();
            if (lastNode != NULL && (now - lastNode->_time) > ageLimit) {
                self.dict->erase([NSString stringWithUTF8String:lastNode->_key]);
                AnyObject obj = self->_linkList->remove_tail_node();
                if ([self.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
                    [self.delegate lurcache:self willEvictObject:PointerBridge(obj)];
                }
                CFRelease(obj);
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
  
}

#pragma mark - getter

- (multimap<NSString *, LinkNodeType *> *)dict {
    if (_dict == NULL) {
        _dict = new multimap<NSString *,LinkNodeType*>();
    }
    return _dict;
}

- (LinkList<AnyObject> *)linkList {
    if (_linkList == NULL) {
        _linkList = new LinkList<AnyObject>();
    }
    return _linkList;
}

- (NSUInteger)totalCount {
    pthread_mutex_lock(&_lock);
    NSInteger size = self.linkList->size();
    pthread_mutex_unlock(&_lock);
    return size;
}

- (NSUInteger)totalCost {
    pthread_mutex_lock(&_lock);
    NSInteger cost = self.linkList->_totalCost;
    pthread_mutex_unlock(&_lock);
    return cost;
}


- (void)setObject:(id)object forKey:(NSString *)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    pthread_mutex_lock(&_lock);
    NSTimeInterval now = CACurrentMediaTime();
    LinkNodeType *node = NULL;
    MapIterator ret = self.dict->find(key);
    if (ret != self.dict->end()) { ///查找当前key是否有添加到链表中的节点
        node = ret->second;
        self.linkList->_totalCost -= node->_cost;
        self.linkList->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_data = ObjectBridge(object);
        self.linkList->bring_node_to_head(node);
    } else {
        node = self.linkList->insert(ObjectBridge(object));
        node->_key = [key UTF8String];
        node->_time = now;
        node->_cost = cost;
        self.dict->insert(make_pair(key, node));
    }
    int size = self.linkList->size();
    if (size > _countLimit) { ///链表缓存数量已经超过最大缓存数量
        LinkNodeType *lastNode = self.linkList->lastObject();
        self.dict->erase([NSString stringWithUTF8String:lastNode->_key]);
        AnyObject data = self.linkList->remove_tail_node();
        if ([self.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
            [self.delegate lurcache:self willEvictObject:PointerBridge(data)];
        }
        CFRelease(data);
    }
    
    if (self.linkList->_totalCost > self.costLimit) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self _trimToCost:self->_costLimit];
        });
    }
    
    pthread_mutex_unlock(&_lock);
}

- (id)objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    id object = nil;
    LinkNodeType *node;
    MapIterator ret = self.dict->find(key);
    if (ret != self.dict->end()) {
        node = ret->second;
        node->_time = CACurrentMediaTime();
        AnyObject data = node->_data;
        object = PointerBridge(data);
        self.linkList->bring_node_to_head(node);
    }
    pthread_mutex_unlock(&_lock);
    return object;
}

- (void)removeObjectForKey:(id)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    LinkNodeType *node;
    MapIterator ret = self.dict->find(key);
    if (ret != self.dict->end()) {
        self.dict->erase(key);
        node = ret->second;
        AnyObject data = self.linkList->remove_by(node);
        if ([self.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
            [self.delegate lurcache:self willEvictObject:PointerBridge(data)];
        }
        CFRelease(data);
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    if (self.totalCount == 0) return;
    pthread_mutex_lock(&_lock);
    self.dict->clear();
    self.linkList->clear_by_completion([](AnyObject obj){
        typeof(self)weakSelf = LRUCache.shareCache;
        if ([weakSelf.delegate respondsToSelector:@selector(lurcache:willEvictObject:)]) {
            [weakSelf.delegate lurcache:weakSelf willEvictObject:PointerBridge(obj)];
        }
        CFRelease(obj);
    });
    ///清空指针操作
    delete self.dict;
    delete self.linkList;
    self.dict = NULL;
    self.linkList = NULL;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = NO;
    MapIterator ret = self.dict->find(key);
    if (ret != self.dict->end()) {
        contains = YES;
    }
    pthread_mutex_unlock(&_lock);
    return contains;
}

/**
 app收到内存警告清空内存
 */
- (void) _appDidReceiveMemoryWarningNotification:(NSNotification *)noti {
    if (!self.shouldRemoveAllObjectsOnMemoryWarning) return;
    [self removeAllObjects];
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)dealloc
{
    [self removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    pthread_mutex_destroy(&_lock);
}


@end
