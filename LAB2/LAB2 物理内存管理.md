# LAB2 物理内存管理

## 探测系统物理内存布局

**物理内存管理：**

①探测可用的物理内存资源；了解到物理内存位于什么 地方，有多大之后，就以固定页面大小来划分整个物理内存空间，并准备以此为最小内存分配单位来管理整个物理内存，管理在内核运行过程中每页内存，设定其可用状态（free的， used的，还是reserved的），这其实就对应了我们在课本上讲到的连续内存分配概念和原理的具体实现

②接着ucore kernel就要建立页表， 启动分页机制，让CPU的MMU把预先建立好 的页表中的页表项读入到TLB中，根据页表项描述的虚拟页（Page）与物理页帧（Page Frame）的对应关系完成CPU对内存的读、写和执行操作。这一部分其实就对应了我们在课 本上讲到内存映射、页表、多级页表等概念和原理的具体实现。

### bootasm.S

两种方法：（1）BIOS中断调用 （实模式下完成）

​									三种方式（都是基于INT 15h）：88h, e801h, e820h

​					（2）直接探测 （保护模式下完成）

本次实验中我们通过e820h中断获取内存信息。

因为e820h中断必须在实模式下使用，所以我们在 bootloader 进入保护模式之前调用这个 BIOS 中断，并且把 e820 映射结构保存在物理地址0x8000处。

这些部分由 boot/bootasm.S中从probe_memory处到finish_probe处的代码部分完成完成。

![image-20221114161739223](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221114161739223.png)

![image-20221114161417579](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221114161417579.png)

通过BIOS中断获取内存**可调用参数为e820h的INT 15h BIOS中断**。BIOS通过**系统内存映射地址描述符**（Address Range Descriptor）格式来**表示系统物理内存布局**，其具体表示如下：(定义在memlayout.h中)

![image-20221114154937822](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221114154937822.png)

在0x8000地址处保存了从BIOS中获得的内存分布信息，此信息按照struct e820map的设置来进行填充。

### /kern/init/entry.S 中的kern_entry函数

**对照三个阶段来看**

bootloader调用位于lab2/kern/init/entry.S中的kern_entry函数，为执行kern_init建立一个良好的C语言运行环境（设置堆栈），而且临时建立了一个段映射关系，为之后建立分页 机制的过程做一个准备

### /kern/init/kern_init函数

```
extern char edata[], end[];
//ld根据kernel.ld链接脚本生成的全局变量，表示相应段的起始地址或结束地址等
    /*
    edata”表示数据段的结束地址，
    “.bss”表示数据段的结束地址和BSS段的起始地址
    而“end”表示BSS段的结束地址。
    */
```

调用kern_init函数，在完成一些输出并对lab1实验结果的检查后，进入物理内存管理初始化的工作，即调用pmm_init函数完成物理内存的管理。接着是执行中断和 异常相关的初始化工作，即调用pic_init函数和idt_init函数等。

### pmm_init函数

首先加载页目录虚拟地址，然后调用init_pmm_manager函数，初始化物理内存管理器，然后调用page_init函数，进行分页操作，根据通过e820中断得到的描述符对物理内存空间进行分页，并标记他们为空闲页或者已占用页。然后进行对页的检查。然后调用boot_map_segment进行物理内存与虚拟内存的映射。对于返回的页表项地址在其中填入对应的物理地址，并设置标记位。



接下来将按照实验的步骤进一步阐释如何完善这一部分功能的。

#### 练习0： 填写已有实验

使用meld工具对比LAB1和LAB2文件的区别，并且进行替换。

![image-20221109202851859](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109202851859.png)

#### 练习1：实现 first-fit 连续物理内存分配算法（需要编程）

先翻译default_pmm.c中的注释：

```
/* 
物理内存页管理器顺着双向链表进行搜索空闲内存区域，直到找到一个足够大的空闲区域，因为它尽可能少地搜索链表。如果空闲区域的大小和申请分配的大小正好一样，则把这个空闲区域分配出去，成功返回；否则将该空闲区分为两部分，一部分区域与申请分配的大小相等，把它分配出去，剩下的一部分区域形成新的空闲区。其释放内存的设计思路很简单，只需把这块区域重新放回双向链表中即可。
*/

// LAB2 练习 1：你的代码
// 你应该重写函数：`default_init`, `default_init_memmap`,`default_alloc_pages`，`default_free_pages`。
```

```
FFMA 的详细信息
(1) 准备工作：
为了实现 First-Fit Memory Allocation (FFMA)，我们应该使用列表管理空闲内存块。使用了结构 `free_area_t`用于管理空闲内存块。
首先，您应该熟悉 list.h 中的 struct `list`。结构`list` 是一个简单的双向链表实现。你应该知道如何使用`list_init`，`list_add`（`list_add_after`），`list_add_before`，`list_del`，
 *`list_next`，`list_prev`。
 有一个棘手的方法是将一般的 `list` 结构转换为特殊结构（例如结构`page`），使用以下宏：`le2page`（在 memlayout.h 中），（以及在未来的实验室中：`le2vma`（在 vmm.h 中），`le2proc`（在proc.h）等）。
```

首先进入/libs/list.h 查看：

```
/*简单的双向链表实现。
  一些内部函数（“__xxx”）在操作整个列表而不是单个条目时很有用，因为有时我们已经知道下一个/上一个条目，我们可以通过直接使用它们而不是使用通用的单条目例程来生成更好的代码 .
 */
```

类list_entry是双向链表的一个条目；

list_init初始化一个双向列表；

list_add是将该条目加在指定条目的后面，list_add_before是加在指定条目的前面；

list_del是删除该条目；

list_del_init用于将当前条目从当前双向链表中删除，并为他自己单独初始化一个双向链表。

List_empty用于判断当前双向列表是否只有一个条目（即他自己

list_next返回当前条目的下一个条目

list_prev返回当前条目的前一个条目；



在/kern/mm/memlayout.h中使用宏定义 将一般的 `list` 结构转换为特殊结构（例如结构`page`）

![image-20221109220208430](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109220208430.png)

------

我们在/kern/mm/memlayout.h中可以找到Page数据结构的定义：

![image-20221109211725517](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109211725517.png)

ref: ref表示的是，这个页被页表的引用记数，也就是映射此物理页的虚拟页个数。如果这个页被页表引用了即在某页表中有一个页表项设置了一个虚拟页到这个Page管理的物理页的映射关系，就会把Page的ref加一；反之，若页表项取消，即映射关系解除，就会把Page的ref减一。

flags：此物理页的状态标记，有两个标志位状态，为1的时候，代表这一页是free状态，可以被分配，但不能对它进行释放；如果为0，那么说明这个页已经分配了，不能被分配，但是可以被释放掉。简单地说，就是可不可以被分配的一个标志位。

*答案的说法 非连续空闲块的首页也置为0，连续空闲块首页置为1

property：记录某连续空闲页的数量，这里需要**注意的是用到此成员变量的这个Page一定是连续内存块的开始地址（第一页的地址**）。

page_link：便于把多个连续内存空闲块链接在一起的双向链表指针，连续内存空闲块利用这个页的成员变量page_link来链接比它地址小和大的其他连续内存空闲块，释放的时候只要将这个空间通过指针放回到双向链表中。



还在这个文件中，我们往下可以看到另一个结构：

![image-20221109212129967](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109212129967.png)

这里的数据结构定义让我觉得是个空闲列表，但是又有所不同。这里是由于随着内存的分配，导致出现了小的连续空闲内存即外部碎片。但是，我们应该利用这些小的连续空闲内存，但是每次的遍历带来的消耗不值得。所以这里定义了free_area_t的数据结构。

这里看一下里面的成员变量，首先就是一个list_entry结构的双向链表指针和**记录当前空闲页的个数的无符号整型变量nr_free**。其中的链表指针指向了空闲的物理页，也就是链表的头部。



在/kern/mm/default_pmm.h中我们可以看到如下外部定义：

![image-20221109213037687](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109213037687.png)

这个结构的具体定义如下：

![image-20221109213202671](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109213202671.png)

接下来对结构体中的各个部分的注释进行解释：

const char *name:某种**物理内存管理器**的名称（可根据算法等具体实现的不同自定义新的内存管理器)

*void (*init)(void):物理内存管理器初始化，包括生成内部描述和数据结构（空闲块链表和空闲页总数）

void (*init_memmap)(struct Page *base, size_t n):初始化空闲页，根据初始时的空闲物理内存区域将页映射到物理内存上

struct Page *(*alloc_pages)(size_t n):申请分配指定数量的物理页

void (*free_pages)(struct Page *base, size_t n):申请释放若干指定物理页

size_t (*nr_free_pages)(void):查询当前空闲页总数

void (*check)(void):检查物理内存管理器的正确性



在/kern/mm/memlayout.h中可以看到上述定义的数据结构中会用到的宏定义：

![image-20221109213536306](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109213536306.png)

------

```
(2) `default_init`:
可以重用demo的`default_init`函数来初始化`free_list`，并将`nr_free`设置为0。`free_list`用于记录空闲内存块。`nr_free` 是空闲内存块的总数。
```

![image-20221109222057713](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109222057713.png)

声明free_area，将free_area里面的free_list初始化，并记录当前空闲块nr_free为0.

------



```
(3) `default_init_memmap`:
该函数的调用过程为: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager` --> `init_memmap`。
该函数用于初始化一个空闲块（带参数`addr_base`，`page_number`）。为了初始化一个空闲块，首先，你应该初始化这个空闲块中的每个页面（在 memlayout.h 中定义）。这个程序包括：
  - 设置 `p->flags` 的 `PG_property` 位，表示这个页面是有效的。附言在函数 `pmm_init` 中（在 pmm.c 中），位 `PG_reserved` 的`p->flags` 已经设置。
  - 如果这个页面是空闲的并且不是空闲块的第一页，`p->property` 应该设置为 0。
  - 如果这个页面是空闲的并且是空闲块的第一页，`p->property`应设置为块中的总页数。
  - `p->ref` 应该是 0，因为现在 `p` 是空闲的并且没有引用。
之后，我们可以使用 `p->page_link` 将该页面链接到 `free_list`。
（例如：`list_add_before(&free_list, &(p->page_link));`）最后，我们应该更新空闲内存块的总和：`nr_free += n`。
```

接下来我们从头跟踪调用过程：首先是/kern/init/init.c中的kern_init

![image-20221109223050876](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109223050876.png)

这个函数是进入ucore操作系统之后，第一个执行的函数，对于内核进行初始化。在其中，调用了初始化物理内存的函数pmm_init。

在kern/mm/pmm.h中可以找到对pmm_init函数的定义：

![image-20221109223311940](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109223311940.png)

这个函数主要是完成对于整个物理内存的初始化，页初始化只是其中的一部分，调用位置偏前，函数之后的部分可以不管，直接进入page_init函数。

在同一文件中前面可以找到page_init，page_init函数主要是完成了一个整体物理地址的初始化过程，包括设置标记位，探测物理内存布局等操作。但是，其中最关键的部分，也是和实验相关的页初始化，交给了init_memmap函数处理。

![image-20221109223529079](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109223529079.png)

同一文件再往前就能找到init_memmap函数的定义。

![image-20221109223816847](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109223816847.png)

到这里，我们自然而然就应该观察到输入的这两个参数，我们大致可以知道这两个参数是为了初始化：

第一个参数的类型是Page *:

我们知道在page_init函数中传给init_memmap的参数是pa2page(begin)和（end_begin）/PGSIZE，查看pa2page的定义可知

![image-20221109224447485](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109224447485.png)

此处是初始化以begin为参数开始的第一个物理页为基地址，物理页个数为（end_begin）/PGSIZE的空闲页。

综上，这个函数就是初始化一整个空闲物理内存块，将块内每一页对应的Page结构初始化，参数为基址和页数（因为相邻编号的页对应的Page结构在内存上是相邻的，所以可将第一个空闲物理页对应的Page结构地址作为基址，以基址+偏移量的方式访问所有空闲物理页的Page结构，根据指导书，这个空闲块链表正是将各个块首页的指针集合（由prev和next构成）的指针（或者说指针集合所在地址）相连，并以基址区分不同的连续内存物理块）。

**代码实现：**

第一种 也是result里面给出的：



![image-20221109222642094](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221109222642094.png)

首先，这里使用了一个页结构来存储传下来的base页面，之后使用循环判断后面n个页面是否为保留页（之前，因为防止初试化页面被分配或破坏，已经设置了保留页），如果该页不是保留页，那么就可以对它进行初始化。先将全部的page的flags位置为0，property位也置为0。最后将映射到此物理页的虚拟页数量置为0，调用set_page_ref函数来清空引用。跳出循环之后，设置连续空闲块的首页的property为n，将flags置为1.最后，将首页插入到双向列表中，其中free_list指的是free_area_t中的list结构，并且基地址的连续空闲页数量加n，空闲页数量也加n。

另一种实现方法如下：

![image-20221110155501946](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110155501946.png)

首先，这里使用了一个页结构来存储传下来的base页面，之后使用循环判断后面n个页面是否为保留页（之前，因为防止初试化页面被分配或破坏，已经设置了保留页），如果该页不是保留页，那么就可以对它进行初始化，这里调用SetPageProperty设置标志位，表示当前页为空。同时这里将连续空页数量设置为0，即p->property。最后将映射到此物理页的虚拟页数量置为0，调用set_page_ref函数来清空引用。最后，将其插入到双向列表中，其中free_list指的是free_area_t中的list结构，并且基地址的连续空闲页数量加n，空闲页数量也加n。

综上，具体流程为：遍历块内所有空闲物理页的Page结构，将各个flags置为0以标记物理页帧有效，将property成员置零，使用 SetPageProperty宏置PG_Property标志位来标记各个页有效（具体而言，如果一页的该位为1，则对应页应是一个空闲块的块首页；若为0，则对应页要么是一个已分配块的块首页，要么不是块中首页；另一个标志位PG_Reserved在pmm_init函数里已被置位，这里用于确认对应页不是被OS内核占用的保留页，因而可用于用户程序的分配和回收），清空各物理页的引用计数ref；最后再将首页Page结构的property置为块内总页数，将全局总页数nr_free加上块内总页数，并用page_link这个双链表结点指针集合将块首页连接到空闲块链表里。

------

```
(4) `default_alloc_pages`：
在空闲列表中搜索第一个空闲块（块大小> = n）并重新分配找到的块，返回该块的地址作为`malloc`所需的地址。
	(4.1)
		所以你应该像这样搜索空闲列表：
			list_entry_t le = &free_list;
			while((le=list_next(le)) != &free_list) {
			...
		(4.1.1)
			在while循环中，获取struct `page`并检查`p->property`（记录此块中空闲页面的数量）是否> = n。
			struct Page *p = le2page(le, page_link);
			if(p->property >= n){ ...
		(4.1.2)
			如果我们找到这个 `p`，这意味着我们找到了一个大小 >= n 的空闲块，它的前 `n` 页可以被分配。该页面的一些标志位应设置如下：`PG_reserved = 1`，`PG_property = 0`。然后，从 `free_list` 取消链接页面。
			(4.1.2.1)
				如果`p->property > n`，我们应该重新计算这个空闲块的剩余页数。 （例如：`le2page(le,page_link))->property= p-> property- n;`)
		(4.1.3)
			重新计算“nr_free”（剩余所有空闲块的数量）。
		(4.1.4)
			返回`p`。
	(4.2)
		如果我们找不到大小 >=n 的空闲块，则返回 NULL。
```

对于result中 代码实现如下：

![image-20221110145634941](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110145634941.png)

解释代码：首先，判断空闲页的总数是否足够分配所需要的内存大小，若是足够则继续向下执行，否则则返回NULL指针。然后声明page用于将来存储要使用的空闲块的首页，初始化list_entry_t类型的le用于遍历空闲链表。遍历整个空闲链表。如果找到合适的空闲页，即p->property >= n（从该页开始，连续的空闲页数量大于n），即可认为可分配，将当前页的指针赋给page来存放，跳出循环。如果找到了的话，如果当前空闲块的大小大于n，那么找到page+n的位置，将它的property设置为page->property-n，设置flags位为1，并将它加入到空闲链表中page节点的后面。然后从空闲链表中删除page，将链表的nr_free总空闲页数减n，清除page的property。最后返回page。

另一种实现方法如下：

![image-20221110155553319](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110155553319.png)

该函数分配指定页数的连续空闲物理内存空间，返回分配的空间中第一页的Page结构的指针。

首先说明一下该函数的代码过程：首先，判断空闲页的总数是否足够分配所需要的内存大小，若是足够则继续向下执行，否则则返回NULL指针。过了这一个检查之后，遍历整个空闲链表。如果找到合适的空闲页，即p->property >= n（从该页开始，连续的空闲页数量大于n），即可认为可分配，重新设置标志位。具体操作是调用ClearPageProperty(pp)，将分配出去的内存页标记为非空闲。然后从空闲链表，即free_area_t中，删除此项。如果当前空闲页的大小大于所需大小。则分割页块。具体操作就是，刚刚分配了n个页，如果分配完了，还有连续的空间，则在最后分配的那个页的下一个页（未分配），更新它的连续空闲页值。如果正好合适，则不进行操作。最后计算剩余空闲页个数并返回分配的页块地址。

流程：从起始位置开始顺序搜索空闲块链表，找到第一个页数不小于所申请页数n的块（只需检查每个Page的property成员，在其值>=n的第一个页停下），如果这个块的页数正好等于申请的页数，则可直接分配；如果页数比申请的页数多，要将块分成两半，将起始地址较低的一半分配出去，将起始地址较高的一半作为链表内新的块，分配完成后重新计算块内空闲页数和全局空闲页数；若遍历整个空闲链表仍找不到足够大的块，则返回NULL表示分配失败。

```
(5) `default_free_pages`:
	将页面重新链接到空闲列表中，并可能将小的空闲块合并到大的。
 (5.1)
	根据撤回区块的基地址，搜索空闲区块列出其正确位置（地址从低到高），并插入页面。 （可以使用`list_next`、`le2page`、`list_add_before`）
 (5.2)
	重置页面的字段，例如`p->ref`和`p->flags`（PageProperty）
 (5.3)
	尝试合并较低或较高地址的块。注意：这应该正确更改某些页面的 `p->property`。
 */
```

result的代码实现如下：

![image-20221110161520416](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110161520416.png)

#### **练习2：实现寻找虚拟地址对应的页表项（需要编程）**

PDT(页目录表),PDE(页目录项),PTT(页表),PTE(页表项)之间的关系:页表保存页表项，页表项被映射到物理内存地址；页目录表保存页目录项，页目录项映射到页表。

我们首先查看get_pte函数中的注释：

```
get_pte - 获取 pte 并返回这个 pte 的内核虚拟地址 for la
        - 如果 PT 包含此 pte 不存在，则为 PT 分配一个页面
范围：
pgdir：PDT的内核虚拟基地址
la: 需要映射的线性地址
create：一个逻辑值来决定是否为 PT 分配一个页面
返回值：这个 pte 的内核虚拟地址

pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {

/* LAB2 练习 2：你的代码
  如果需要访问物理地址，请使用 KADDR()
     * 请阅读 pmm.h 以获取有用的宏
     * 也许你需要帮助注释，下面的注释可以帮助你完成代码
     * 一些有用的 MACRO 和 DEFINE，你可以在下面的实现中使用它们。
     * 宏或函数：
    PDX(la)： 返回虚拟地址la的页目录索引
	KADDR(pa): 返回物理地址pa相关的内核虚拟地址
	set_page_ref(page,1): 设置此页被引用一次
	page2pa(page): 得到page管理的那一页的物理地址
	struct Page * alloc_page() : 分配一页出来
	memset(void * s, char c, size_t n) : 设置s指向地址的前面n个字节为字节‘c’
	* 定义：
	PTE_P 0x001 表示物理内存页存在
	PTE_W 0x002 表示物理内存页内容可写
	PTE_U 0x004 表示可以读取对应地址的物理内存页内容
     */

#if 0
    pde_t *pdep = NULL;  // (1) 查找页面目录入口PDE
    if (0) {             // (2) 检查条目是否不存在
                         // (3) 检查是否需要创建，然后为页表分配页面
                         // 注意：此页用于页表，不用于普通数据页
                         // (4) 设置页面引用
        uintptr_t pa = 0;//(5) 获取页面的线性地址
                         // (6) 使用memset清除页面内容
                         // (7) 设置页面目录入口的权限
       }
       return NULL;      // (8) 返回页表项
#endif
}
```

了解段页式管理的基本概念：

![在这里插入图片描述](https://img-blog.csdnimg.cn/702bdbd470964d8893bc2288b30db6dd.png)

如图在保护模式中，x86 体系结构将内存地址分成三种：逻辑地址（也称虚地址）、线性地址和物理地址。逻辑地址即是程序指令中使用的地址，物理地址是实际访问内存的地址。逻辑地址通过段式管理的地址映射可以得到线性地址，线性地址通过页式管理的地址映射得到物理地址。

但是该实验将逻辑地址不加转换直接映射成线性地址，所以我们在下面的讨论中可以对这两个地址不加区分（目前的 OS 实现也是不加区分的）。

如图所示，页式管理将线性地址分成三部分（图中的 Linear Address 的 Directory 部分、 Table 部分和 Offset 部分）。ucore 的页式管理通过一个二级的页表实现。一级页表的起始物理地址存放在 cr3 寄存器中，这个地址必须是一个页对齐的地址，也就是低 12 位必须为 0。目前，ucore 用boot_cr3（mm/pmm.c）记录这个值。

<img src="https://img-blog.csdnimg.cn/37a5ef5169f74ee1a3f0854b247d5e08.png" alt="在这里插入图片描述"  />

从图中我们可以看到一级页表存放在高10位中，二级页表存放于中间10位中，最后的12位表示偏移量，据此可以证明，页大小为4KB（2的12次方，4096）。

这里涉及到三个类型pte_t、pde_t和uintptr_t。通过查看定义：

![image-20221110165827915](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110165827915.png)

可知它们其实都是unsigned int类型。其中，pde_t 全称为page directory entry，也就是一级页表的表项，前10位；

pte_t 全称为page table entry，表示二级页表的表项，中10位。

从上述图中可以看到对于32位的线性地址，我们可以将它拆分成三部分，这里我们查看/kern/mm/mmu.h来查看这些部分的定义：

![image-20221110170042415](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110170042415.png)

la是线性地址，32位，需要提取出该字段内容，才能获取页表内容。

PDX函数：PDXSHIFT的值为22，右移22位，再与10个1与，就可以获取directory；

PTX函数：PTXSHIFT的值为12，右移12位，再与10个1与，由于地址对齐的原因，0x3FF的11位之前都是0，这样就能提取table部分。

PPN函数：获得当前数据所在页的地址（不包括后12位）

PGOFF函数：直接与12个1与，就可以得到偏移量部分。

PGADDR函数：通过提供的d,t,o，构造线性地址。

综上，页表保存页表项，页表项被映射到物理内存地址；页目录表保存页目录项，页目录项映射到页表。

**首先是PDE和PTE的各部分含义及用途：**

PDE和PTE都是4B大小的一个元素，其高20bit被用于保存索引，低12bit用于保存属性，但是由于用处不同，内部具有细小差异，如图所示：

![pde.png](https://img-blog.csdnimg.cn/img_convert/1962b6175400506743feaebef91e9dd8.png)

![image-20221110184745666](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110184745666.png)

**出现页访问异常时，硬件执行的工作：**
首先需要将发生错误的线性地址la保存在CR2寄存器中

这里说一下控制寄存器CR0-4的作用
CR0的0位是PE位，如果为1则启动保护模式，其余位也有自己的作用
CR1是未定义控制寄存器，留着以后用
CR2是页故障线性地址寄存器，保存最后一次出现页故障的全32位线性地址
CR3是页目录基址寄存器，保存PDT的物理地址
CR4在Pentium系列处理器中才实现，它处理的事务包括诸如何时启用虚拟8086模式等
之后需要往中断时的栈中压入EFLAGS,CS,EIP,ERROR CODE，如果这页访问异常很不巧发生在用户态，还需要先压入SS,ESP并切换到内核态

最后根据IDT表查询到对应的页访问异常的ISR，跳转过去并将剩下的部分交给软件处理。

![image-20221110190820709](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221110190820709.png)

首先尝试使用PDX函数，获取一级页表的位置，如果获取成功，可以直接返回一个东西。

如果获取不成功，那么需要根据create标记位来决定是否创建这一个二级页表（注意，一级页表中，存储的都是二级页表的起始地址）。如果create为0，那么不创建，否则创建。

既然需要查找这个页表，那么页表的引用次数就要加一。

之后，需要使用memset将新建的这个页表虚拟地址，全部设置为0，因为这个页所代表的虚拟地址都没有被映射。

接下来是设置控制位。这里应该设置同时设置上PTE_U、PTE_W和PTE_P，分别代表用户态的软件可以读取对应地址的物理内存页内容、物理内存页内容可写、物理内存页存在。



#### **练习3：释放某虚地址所在的页并取消对应二级页表项的映射（需要编程）**

![image-20221115224346280](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221115224346280.png)

![image-20221115224404983](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221115224404983.png)

![image-20221115224324484](C:\Users\vivia\AppData\Roaming\Typora\typora-user-images\image-20221115224324484.png)