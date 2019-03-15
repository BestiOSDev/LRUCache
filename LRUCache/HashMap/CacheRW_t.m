//
//  CacheRW_t.m
//  LRUCache
//
//  Created by dzb on 2019/3/15.
//  Copyright © 2019 大兵布莱恩特. All rights reserved.
//

#import "CacheRW_t.h"
#import "LinkedList.h"

typedef NSUInteger MASK_T;

@interface CacheRW_t ()

///list
@property (nonatomic,strong) LinkedList *list;
///mask
@property (nonatomic,assign) MASK_T mask;
///occupied
@property (nonatomic,assign) MASK_T occupied;

@end

@implementation CacheRW_t

- (CacheRW_t *)initWithCapacity:(NSUInteger)numItems {
	if (self = [super init]) {
		self.list = [[LinkedList alloc] init];
		for (int i = 0; i<numItems; i++) {
			[self.list addObjectAtFirst:[NSNull null] forKey:0];
		}
		self.mask = numItems-1;
		self.occupied = 0;
	}
	return self;
}

- (void)setObject:(id)obj forKey:(id)key {
	if (!obj || !key) return;
	MASK_T hashType = getKey(key);
	MASK_T m = [self getIndexWith:hashType];
	if (m == NSNotFound) { ///已经满了 删除末尾元素 将新元素插入到链表头部
		[self.list removeLastObject];
		[self.list addObjectAtFirst:obj forKey:hashType];
	} else {
		[self.list updateObject:obj atIndex:m forKey:hashType];
	}
}

- (void)removeObjectsForKey:(id)key {
	if (!key) return ;
	MASK_T m = [self getIndexWith:getKey(key)];
	if (m == -1) return;
	Node *node = [self.list objectAtIndex:m];
	node->key = 0;
	CFRelease(node->data);
	node->data = (__bridge_retained AnyObject)([NSNull null]);
	self.occupied--;
}

- (id)objectForKey:(id)key {
	if (!key) return nil;
	MASK_T m = [self getIndexWith:getKey(key)];
	if (m == NSNotFound) return nil;
	Node *node = [self.list objectAtIndex:m];
	///将查找的节点移动到链表的最前边
	[self.list moveObjectToFront:node preIndex:m];
	id object = (__bridge_transfer id)(node->data);
	return object;
}

static inline MASK_T getKey(NSString *key) {
	return [key hash];
}

/**
 根据 key 生成一个索引 从_buckets取值
 */
- (MASK_T) getIndexWith:(MASK_T)hashType {
	MASK_T begin = cache_hash(hashType,self.mask);
	MASK_T i = begin;
	MASK_T m = self.mask; ///0 ... mask
	Node *temp;
	do {
		temp = [self.list objectAtIndex:i];
		if (temp->key == 0 || temp->key == hashType) {
			return i;
		}
	} while ((i = cache_next(i,m)) != begin);
	
	return NSNotFound;
}

/**
 根据 key 生产一个索引
 */
static inline MASK_T cache_hash(MASK_T key, MASK_T mask)
{
	MASK_T m = (MASK_T)(key % mask);
	return m;
}


/**
 生成下一个索引
 */
static inline MASK_T cache_next(MASK_T i, MASK_T mask) {
	return i ? i-1 : mask;
}

- (NSInteger)count {
	return self.occupied;
}

- (NSString *)description
{
	return self.list.description;
}

- (void)removeAllObjects {
	[self.list removeAllObjects];
}

@end
