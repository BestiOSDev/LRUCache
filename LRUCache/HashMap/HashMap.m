//
//  HashMap.m
//  HashTable
//
//  Created by dzb on 2018/7/9.
//  Copyright © 2018 大兵布莱恩特. All rights reserved.
//

#import "HashMap.h"
#import "CacheRW_t.h"


@interface HashMap ()

/**
 缓存数量限制
 */
@property NSUInteger countLimit;

///cache_t
@property (nonatomic,strong) CacheRW_t *cache_t;

@end

@implementation HashMap

- (HashMap *)initWithCapacity:(NSUInteger)numItems {
	if (self =  [super init]) {
		self.cache_t = [[CacheRW_t alloc] initWithCapacity:numItems];
	}
	return self;
}

- (void)setObject:(id)obj forKey:(NSString *)key {
	[self.cache_t setObject:obj forKey:key];
}

- (id) objectForKey:(NSString *)key {
	return [self.cache_t objectForKey:key];
}

- (void)removeObjectsForKey:(NSString *)key {
	if (!key) return ;
	[self.cache_t removeObjectsForKey:key];
}


- (NSInteger)count {
	return self.cache_t.count;
}

- (NSString *)description {
	return self.cache_t.description;
}

- (void)removeAllObjects {
	[self.cache_t removeAllObjects];
}

- (void)dealloc
{
	[self removeAllObjects];
}

@end
