//
//  LRUCache.m
//  LRUCache
//
//  Created by dzb on 2019/3/15.
//  Copyright © 2019 大兵布莱恩特. All rights reserved.
//

#import "LRUCache.h"
#import "LinkedList.h"
#import "HashMap.h"


@interface LRUCache () <NSCopying,NSMutableCopying>

///hashMap
@property (nonatomic,strong) HashMap *hashMap;

@end

@implementation LRUCache

@dynamic shareCache;

+ (instancetype) shareCache {
	return [[super alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
	static LRUCache *_cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_cache = [super allocWithZone:zone];
		_cache->_countLimit = 10;
	});
	return _cache;
}

- (HashMap *)hashMap {
	if (!_hashMap) {
		_hashMap = [[HashMap alloc] initWithCapacity:self.countLimit];
	}
	return _hashMap;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
	return self;
}

/**
 存储数据
 
 @param object 对象
 @param aKey key
 */
- (void) setObject:(id)object forKey:(NSString *)aKey {
	[self.hashMap setObject:object forKey:aKey];
}

/**
 获取存储的数据
 
 @param aKey 通过 key 查找
 @return 返回数据
 */
- (id) objectForKey:(NSString *)aKey {
	return [self.hashMap objectForKey:aKey];
}

/**
 移除存储的数据
 
 @param aKey 通过 key 方法
 */
- (void) removeObjectForKey:(NSString *)aKey {
	[self.hashMap removeObjectsForKey:aKey];
}

/**
 移除所有缓存数据
 */
- (void)removeAllObjects {
	if (self.hashMap) {
		self.hashMap = nil;
	}
}

- (void)setCountLimit:(NSUInteger)countLimit {
	_countLimit = countLimit;
	[self removeAllObjects];
}

- (NSString *)description {
	return self.hashMap.description;
}

- (void)dealloc
{
	
}

@end
