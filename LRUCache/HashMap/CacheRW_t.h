//
//  CacheRW_t.h
//  LRUCache
//
//  Created by dzb on 2019/3/15.
//  Copyright © 2019 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CacheRW_t <KeyType,ObjectType> : NSObject

- (void) setObject:(ObjectType)obj forKey:(KeyType)key;

- (ObjectType) objectForKey:(KeyType)key;

- (void) removeObjectsForKey:(KeyType)key;

- (void) removeAllObjects;

- (CacheRW_t *)initWithCapacity:(NSUInteger)numItems;

///count
@property (nonatomic,assign) NSInteger count;

@end

NS_ASSUME_NONNULL_END
