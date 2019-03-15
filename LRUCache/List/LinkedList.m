//
//  LinkedList.m
//  ArrayList
//
//  Created by dzb on 2018/8/3.
//  Copyright © 2018 大兵布莱恩特. All rights reserved.
//

#import "LinkedList.h"



@interface LinkedList ()

///head
@property (nonatomic,assign) Node *dummyHead;
///size
@property (nonatomic,assign) NSInteger size;

@end

@implementation LinkedList

- (instancetype)init
{
	self = [super init];
	if (self) {
		Node * dummyHead = (Node*)malloc(sizeof(Node));
		dummyHead->data = nil;
		dummyHead->next = nil;
		self.dummyHead = dummyHead;
		self.size = 0;
	}
	return self;
}

- (void)addObjectAtFirst:(id)object forKey:(NSInteger)key {
	[self addObject:object atIndex:0 forKey:key];
}

- (void)addObjectAtLast:(id)object forKey:(NSInteger)key  {
	[self addObject:object atIndex:self.size forKey:key];
}

- (void)addObject:(id)object atIndex:(NSInteger)index forKey:(NSInteger)key {
	if (index < 0 || index > self.count) {
		@throw [NSException exceptionWithName:@"LinkedList is out of bounds" reason:@"Add failed. Illegal index." userInfo:nil];
		return;
	}
	Node *prev = self.dummyHead;
	for (int i = 0; i< index; i++) {
		prev = prev->next;
	}
	Node *cur = (Node*)malloc(sizeof(Node));
	cur->data = (__bridge_retained AnyObject)object;
	cur->key = key;
	cur->next = prev->next;
	prev->next = cur;
	self.size++;
}

- (Node *)objectAtIndex:(NSInteger)index {
	if (index < 0 || index >= self.count) {
		@throw [NSException exceptionWithName:@"LinkedList is out of bounds" reason:@"Add failed. Illegal index." userInfo:nil];
		return nil;
	}
	Node *cur = self.dummyHead->next;
	for (int i = 0; i<index; i++) {
		cur = cur->next;
	}
	return cur;
}

- (Node *)firstObject {
	return [self objectAtIndex:0];
}

- (Node *)lastObject {
	return [self objectAtIndex:self.count-1];
}

- (void)updateObject:(id)object atIndex:(NSInteger)index forKey:(NSInteger)key {
	if (index < 0 || index >= self.count) {
		@throw [NSException exceptionWithName:@"LinkedList is out of bounds" reason:@"Add failed. Illegal index." userInfo:nil];
		return;
	}
	Node *cur = self.dummyHead->next;
	for (int i = 0; i<index; i++) {
		cur = cur->next;
	}
	CFRelease(cur->data);
	cur->data = (__bridge_retained AnyObject)object;
	cur->key = key;
}

- (BOOL)containObject:(id)object {
	Node *cur = self.dummyHead->next;
	while (cur != NULL) {
		id data = (__bridge_transfer id)cur->data;
		if ([data isEqual:object])
			return YES;
		cur = cur->next;
	}
	return NO;
}

/**
 把数据插入到链表头部
 */
- (void) moveObjectToFront:(Node *)node preIndex:(NSInteger)index {
	if (index == 0) return;
	Node *pre = self.dummyHead;
	for (int i = 0; i<index; i++) {
		pre = pre->next;
	}
	pre->next = node->next;
	Node *first = self.dummyHead->next;
	self.dummyHead->next = node;
	node->next = first;
}

- (void) removeObjectAtIndex:(NSInteger)index {
	if (index < 0 || index >= self.count) {
		@throw [NSException exceptionWithName:@"LinkedList is out of bounds" reason:@"Add failed. Illegal index." userInfo:nil];
	}
	Node *prev = self.dummyHead;
	for (int i = 0; i<index; i++) {
		prev = prev->next;
	}
	Node *deleteNode = prev->next;
	prev->next = deleteNode->next;
	CFRelease(deleteNode->data);
	free(deleteNode);
	deleteNode = NULL;
	self.size--;
}

- (void) removeFirstObject {
	[self removeObjectAtIndex:0];
}

- (void) removeLastObject {
	[self removeObjectAtIndex:self.count-1];
}

- (void) removeAllObjects {
	while (self.count != 0) {
		[self removeFirstObject];
	}
}

- (NSInteger)count {
	return self.size;
}

- (NSString *)description {
	
	NSMutableString *string = [NSMutableString stringWithFormat:@"\nLinkedList %p : [ \n" ,self];
	Node *cur = self.dummyHead->next;
	while (cur != nil) {
		if (cur->data != (__bridge AnyObject)([NSNull null])) {
			[string appendFormat:@"%@ -> \n",cur->data];
		}
		cur = cur->next;
	}
	[string appendString:@"NULL\n"];
	[string appendString:@"]\n"];
	
	return string;
}

- (BOOL)isEmpty {
	return self.count == 0;
}

- (void)dealloc
{
	[self removeAllObjects];
}

@end
