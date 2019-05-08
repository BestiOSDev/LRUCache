
LRUCache 是学习 [YYCache](https://github.com/ibireme/YYCache) 后自己动手写的一个缓存库 目前只把 YYMemoryCache 中的功能给实现了 , 其中部分代码是截取自 YYCache 中 ,本人根据其思路 进行适当的改进 纯属交流学习.


LRU 缓存的思想就是 将最近使用过的缓存 移动到链表头部 当超出限时后 将链表尾部缓存移除 ,内部提供了 Linklist做为保存缓存数据的容器


LRUCache 是接口类 对外提供了一下 API

```
@property (nonatomic,strong,class) LRUCache *shareCache;
/**
是否包含key
*/
- (BOOL)containsObjectForKey:(id)key;

/**
根据键取对应值
*/
- (nullable id)objectForKey:(id)key;

/**
通过键值来存储数据
*/
- (void)setObject:(nullable id)object forKey:(id)key;

/**
设置缓存中指定键的值，并将键值关联
与指定成本配对。

对象要存储在缓存中的对象。如果为nil，则调用`removeObjectForKey`。
key与值关联的键。如果为nil，则此方法无效。
cost与键值对关联的成本。
与NSMutableDictionary对象不同，缓存不会复制密钥
放入它的对象。
*/
- (void)setObject:(nullable id)object forKey:(id)key withCost:(NSUInteger)cost;

/**
删除缓存中指定键的值。

key标识要删除的值的键。如果为nil，则此方法无效。
*/
- (void)removeObjectForKey:(id)key;

/**
Empties the cache immediately.
*/
- (void)removeAllObjects;

/** 缓存数据总数 */
@property (readonly) NSUInteger totalCount;
/** 缓存数据总容量 */
@property (readonly) NSUInteger totalCost;

#pragma mark - Limit

/**
default is 10 最大缓存10个对象
*/
@property (nonatomic,assign) NSUInteger countLimit;
/**
按设定时间缓存
*/
@property (nonatomic,assign) NSUInteger ageLimit;

/**
按容量缓存
*/
@property (nonatomic,assign) NSUInteger costLimit;

/**
间隔多少秒检查缓存情况 默认5秒间隔
*/
@property NSTimeInterval autoTrimInterval;

/**
委托对象
*/
@property (nonatomic,weak) id<LRUCacheDelegate>delegate;

/**
收到内存警告时 是否清理缓存
*/
@property (nonatomic,assign) BOOL shouldRemoveAllObjectsOnMemoryWarning;

```

### LinkList 双向循环链表 负责插入和删除元素

并提供了 插入 查找 删除节点的操作

```
///头插法插入数据到链表头部位置
LinkNode * insert(T object);
///查找元素
LinkNode * find(T object);
///获取尾结点
LinkNode * lastObject();
///获取头结点
LinkNode * firstObject();
/// 移动结点到链表头部
void bring_node_to_head(LinkNode *pFind);
///遍历所有元素
void for_each_elements(void(*for_each)(T));
///按元素值进行删除
T remove_by(T obj);
///通过节点删除元素
T remove_by(LinkNode *pFind);
/// 移除尾结点
T remove_tail_node();
///销毁链表的元素
void clear_by_completion(void(*for_each)(T));

```

可以将节点移动到链表头部,删除尾节点 内部使用 C++数据类型 并对 OC 对象进行手动内存管理引用计数
