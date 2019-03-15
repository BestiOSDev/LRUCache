//
//  HashMap.h
//  HashTable
//
//  Created by dzb on 2018/7/9.
//  Copyright © 2018 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 封装了缓存查找 添加 删除
 */
@interface HashMap <KeyType,ObjectType> : NSObject

- (HashMap *) initWithCapacity:(NSUInteger)numItems;

- (void) setObject:(ObjectType)obj forKey:(KeyType)key;

- (ObjectType) objectForKey:(KeyType)key;

- (void) removeObjectsForKey:(KeyType)key;

- (NSInteger) count;


@end
