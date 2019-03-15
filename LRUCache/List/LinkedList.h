//
//  LinkedList.h
//  ArrayList
//
//  Created by dzb on 2018/8/3.
//  Copyright © 2018 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void* AnyObject;
typedef struct node {
	NSInteger key;
	AnyObject data;
	struct node *next;
} Node;

@interface LinkedList <ObjectType> : NSObject

///头插法 将元素插入到链表头部
- (void) addObjectAtFirst:(ObjectType)object forKey:(NSInteger)key;
/// 更新元素
- (void) updateObject:(ObjectType)object atIndex:(NSInteger)index forKey:(NSInteger)key;
/// 根据 索引获取元素
- (Node *) objectAtIndex:(NSInteger)index;
///根据索引位置删除内容
- (void) removeObjectAtIndex:(NSInteger)index;

/**
 把数据插入到链表头部
 */
- (void) moveObjectToFront:(Node *)node preIndex:(NSInteger)index;
///移除链表头部元素
- (void) removeFirstObject;
/// 移除链表末尾元素
- (void) removeLastObject;
/// 移除所有元素
- (void) removeAllObjects;
/// count
@property (nonatomic,assign) NSInteger count;

@end
