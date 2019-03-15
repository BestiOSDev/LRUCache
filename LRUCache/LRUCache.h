//
//  LRUCache.h
//  LRUCache
//
//  Created by dzb on 2019/3/15.
//  Copyright © 2019 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRUCache  <KeyType, ObjectType> : NSObject

///shareCache
@property (nonatomic,strong,class) LRUCache *shareCache;

/**
 存储数据

 @param object 对象
 @param aKey key
 */
- (void) setObject:(ObjectType)object forKey:(KeyType)aKey;

/**
 获取存储的数据

 @param aKey 通过 key 查找
 @return 返回数据
 */
- (nullable ObjectType) objectForKey:(KeyType)aKey;

/**
 移除存储的数据

 @param aKey 通过 key 方法
 */
- (void) removeObjectForKey:(KeyType)aKey;

/**
 移除所有缓存数据
 */
- (void)removeAllObjects;

/**
 缓存数量限制 默认是10 当重新设置改值时 旧的缓存会被清空
 */
@property (nonatomic,assign) NSUInteger countLimit;


@end

NS_ASSUME_NONNULL_END
