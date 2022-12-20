#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <kmalloc.h>
#include <sync.h>
#include <pmm.h>
#include <stdio.h>

/*
 * SLOB Allocator: Simple List Of Blocks
 *
 * Matt Mackall <mpm@selenic.com> 12/30/03
 *
 * How SLOB works:
 *
 * The core of SLOB is a traditional K&R style heap allocator, with
 * support for returning aligned objects. The granularity of this
 * allocator is 8 bytes on x86, though it's perhaps possible to reduce
 * this to 4 if it's deemed worth the effort. The slob heap is a
 * singly-linked list of pages from __get_free_page, grown on demand
 * and allocation from the heap is currently first-fit.
 * 
 * slob堆是__get_free_page中的页面的单链接列表，按需增长，堆中的分配是当前最适合的。
 *
 * Above this is an implementation of kmalloc/kfree. Blocks returned
 * from kmalloc are 8-byte aligned and prepended with a 8-byte header.
 * If kmalloc is asked for objects of PAGE_SIZE or larger, it calls
 * __get_free_pages directly so that it can return page-aligned blocks
 * and keeps a linked list of such pages and their orders. These
 * objects are detected in kfree() by their page alignment.
 * 从kmalloc返回的块是8字节对齐的，并用一个8字节的头进行前缀。
 * 
 * 如果kmalloc被要求提供PAGE_SIZE或更大的对象
 * 它会直接调用__get_free_pages，以便返回页面对齐的块
 * 并保存此类页面及其顺序的链接列表。
 * 
 * 这些对象在kfree（）中通过其页面对齐方式进行检测。
 * 
 * SLAB is emulated on top of SLOB by simply calling constructors and
 * destructors for every SLAB allocation. Objects are returned with
 * the 8-byte alignment unless the SLAB_MUST_HWCACHE_ALIGN flag is
 * set, in which case the low-level allocator will fragment blocks to
 * create the proper alignment. Again, objects of page-size or greater
 * are allocated by calling __get_free_pages. As SLAB objects know
 * their size, no separate size bookkeeping is necessary and there is
 * essentially no allocation space overhead.
 * 
 * SLAB在SLOB之上通过简单地为每个SLAB分配调用构造函数和析构函数模拟。
 * 
 * 除非设置了SLAB_MUST_HWCACHE_ALIGN标志，否则对象将以8字节对齐方式返回，
 * 在这种情况下，低级分配器将分割块以创建正确的对齐方式。 
 * 同样，通过调用__get_free_pages来分配页面大小或更大的对象。
 * 
 * 由于SLAB对象知道它们的大小，因此不需要单独的大小记账，并且基本上没有分配空间开销。
 * 
 */
// SLOB 的工作原理：
// SLOB 的核心是传统的 K&R 风格的堆分配器，支持返回对齐的对象。 
// 这个分配器的粒度在 x86 上是 8 个字节，但如果认为值得努力的话，
// 也许可以将其减少到 4 个字节。 slob 堆是来自 __get_free_page 
// 的页面的单链表，按需增长，目前从堆中分配是最先适应的。
 
// 上面是 kmalloc/kfree 的实现。 从 kmalloc 返回的块是 8 字节对齐的
// ，并在前面加上一个 8 字节的标头。 如果要求 kmalloc 提供 PAGE_SIZE 
// 或更大的对象，它会直接调用 __get_free_pages 以便它可以返回页面对齐
// 的块并保留此类页面及其顺序的链接列表。 这些对象在 kfree() 中通过它
// 们的页面对齐来检测。

// SLAB 是在 SLOB 之上模拟的，只需为每个 SLAB 分配调用构造函数和析构
// 函数。 对象以 8 字节对齐方式返回，除非设置了 SLAB_MUST_HWCACHE_ALIGN
// 标志，在这种情况下，低级分配器将对块进行分段以创建正确的对齐方式。
// 同样，页面大小或更大的对象是通过调用 __get_free_pages 分配的。
// 由于 SLAB 对象知道它们的大小，因此不需要单独的大小簿记，并且基本
// 上没有分配空间开销。

//some helper
#define spin_lock_irqsave(l, f) local_intr_save(f)
#define spin_unlock_irqrestore(l, f) local_intr_restore(f)
typedef unsigned int gfp_t; //GFP(Get Free Pages缩写)
#ifndef PAGE_SIZE
#define PAGE_SIZE PGSIZE
#endif

#ifndef L1_CACHE_BYTES
#define L1_CACHE_BYTES 64
#endif

#ifndef ALIGN
#define ALIGN(addr,size)   (((addr)+(size)-1)&(~((size)-1))) 
#endif

//slob单链表结构
struct slob_block {
	int units;
	struct slob_block *next;//指向下一个slob_block
};
typedef struct slob_block slob_t;

#define SLOB_UNIT sizeof(slob_t) //SLOB_UNIT 是slob单链表结构的大小
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT)
#define SLOB_ALIGN L1_CACHE_BYTES
//单向链表
struct bigblock {
	int order;
	void *pages;
	struct bigblock *next;
};
typedef struct bigblock bigblock_t;

static slob_t arena = { .next = &arena, .units = 1 };
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
  struct Page * page = alloc_pages(1 << order);//多少个页
  if(!page)
    return NULL;
  return page2kva(page);
}

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
  free_pages(kva2page(kva), 1 << order);
}

static void slob_free(void *b, int size);


//分配
//sizeof(bigblock_t), 0, 0
static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
  assert( (size + SLOB_UNIT) < PAGE_SIZE ); //不足一页大小

	slob_t *prev, *cur, *aligned = 0;
	int delta = 0, units = SLOB_UNITS(size); //units为可分为多少个sizeof(slob_t)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
		if (align) {
			aligned = (slob_t *)ALIGN((unsigned long)cur, align); //aligned为cur以align对齐的上界数
			delta = aligned - cur; //头部的碎片
		}
		if (cur->units >= units + delta) { /* room enough? */ //找到够大的节点
			if (delta) { /* need to fragment head to align? */ //如果要按aign对齐的话，就要把每个节点分成两部分 前面是头部碎片delta大小，后面是剩余部分大小
				aligned->units = cur->units - delta;
				aligned->next = cur->next;
				cur->next = aligned;
				cur->units = delta;
				prev = cur;
				cur = aligned;
			}

			if (cur->units == units) /* exact fit? */ //请求的和当前的正好相等
				prev->next = cur->next; /* unlink */  //把匹配的这块从链表中取出来
			else { /* fragment */ //没有正好匹配的情况？
				prev->next = cur + units;  //前一个节点的next指向cur加上分出来的units之后的地址
				prev->next->units = cur->units - units; //其大小为原大小减去分出去的大小
				prev->next->next = cur->next; //其Next指针依旧指向下一个节点
				cur->units = units; //同理在当前的链表减个出来
			}

			slobfree = prev;
			spin_unlock_irqrestore(&slob_lock, flags);
			return cur;
		}
		if (cur == slobfree) {
			spin_unlock_irqrestore(&slob_lock, flags);

			if (size == PAGE_SIZE) /* trying to shrink arena? */
				return 0;

			cur = (slob_t *)__slob_get_free_page(gfp);
			if (!cur)
				return 0;

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;

	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}



void
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}

size_t
slob_allocated(void) {
  return 0;
}

size_t
kallocated(void) {
   return slob_allocated();
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
		order++;
	return order;
}

//size = sizeof(struct proc_struct)  gfp = 0
static void *__kmalloc(size_t size, gfp_t gfp)
{
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) { //SLOB_UNIT = sizeof(slob_t)
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0); // 大于一个page的内存申请
	if (!bb)
		return 0;

	bb->order = find_order(size);
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);

	if (bb->pages) {
		spin_lock_irqsave(&block_lock, flags);
		bb->next = bigblocks;
		bigblocks = bb;
		spin_unlock_irqrestore(&block_lock, flags);
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}

//kmalloc
//size = sizeof(struct proc_struct)
void *
kmalloc(size_t size)
{
  return __kmalloc(size, 0);
}


void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) { //block低十二位不是全1就行
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
			if (bb->pages == block) {
				*last = bb->next;
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}


unsigned int ksize(const void *block)
{
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
}



