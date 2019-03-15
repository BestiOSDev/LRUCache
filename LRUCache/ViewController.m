//
//  ViewController.m
//  LRUCache
//
//  Created by dzb on 2019/3/15.
//  Copyright © 2019 大兵布莱恩特. All rights reserved.
//

#import "ViewController.h"

#import "LRUCache.h"

@interface ViewController ()

@end

@interface Person : NSObject

@end

@implementation Person

- (void)dealloc {
	NSLog(@"Person dealloc");
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	LRUCache *cache = LRUCache.shareCache;

	for (int i = 0; i<11; i++) {
		[cache setObject:@(i) forKey:[NSString stringWithFormat:@"number %d",i]];
	}
	NSLog(@"%@",cache);
	id obj = [cache objectForKey:@"number 2"];
	NSLog(@"%@",obj);
	[cache setObject:@100 forKey:@"number 13"];
	NSLog(@"%@",cache);
	[cache setObject:@130 forKey:@"number 14"];
	NSLog(@"%@",cache);

	{
		Person *p = [Person new];
		[cache setObject:p forKey:@"p1"];
	}
	[cache removeObjectForKey:@"p1"];
	NSLog(@"%@",cache);
	[cache removeAllObjects];
	NSLog(@"%@",cache);

}


@end
