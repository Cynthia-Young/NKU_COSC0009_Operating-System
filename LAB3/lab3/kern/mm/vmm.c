#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <x86.h>
#include <swap.h>

/* mm:内存管理   vma:虚拟内存区
  vmm design include two parts: mm_struct (mm) & vma_struct (vma)
  mm is the memory manager for the set of continuous virtual memory  
  area which have the same PDT页目录表. vma is a continuous virtual memory area.
  There a linear link list for vma & a redblack link list for vma in mm.
---------------
  mm related functions:
   golbal functions
     struct mm_struct * mm_create(void)
     void mm_destroy(struct mm_struct *mm)
     int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
--------------
  vma related functions:
   global functions
     struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)
     void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
     struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
   local functions
     inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
---------------
   check correctness functions
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
//新建一个内存管理器并初始化
struct mm_struct *
mm_create(void) {
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL) {
        list_init(&(mm->mmap_list));
        //以mmap_list建立双向链表头
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;

        if (swap_init_ok) swap_init_mm(mm);
        else mm->sm_priv = NULL;
    }
    return mm;
}

//新建vma并初始化
// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL) {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}

//根据地址找该地址所处的虚拟内存块
// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
    struct vma_struct *vma = NULL;
    if (mm != NULL) {//mm有效
        vma = mm->mmap_cache;//当前虚拟内存区
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
            //如果当前虚拟内存区是空 或者 它不是我们想要找的虚拟内存区
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list; //双向链表头
                while ((le = list_next(le)) != list) {//遍历链表
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = NULL;
                }
        }
        if (vma != NULL) {
            mm->mmap_cache = vma;//更新当前内存区
        }
    }
    return vma;
}

//check   确保前后两个内存区有效且不重叠
// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
}

//在mm中插入一片新的内存区
// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list); //list为双向链表头
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {//遍历链表寻找合适位置
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            //vma_struct靠的是list_link成员变量连接起来的 list_link成员与vma_struct的起始地址存在偏移量 
            //这里我们得到现在遍历到的这个项对应的vma_struct的起始地址
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
        //确定他们都严格start<end 并且两块区域不重合
    }
    if (le_next != list) {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    //插入到合适位置
    vma->vm_mm = mm; //设置它的内存管理器
    list_add_after(le_prev, &(vma->list_link)); 

    mm->map_count ++; //内存管理器的虚拟内存空间数量+1
}

//先释放链表项、vma，，，再释放mm
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
        list_del(le);
        //从双向链表中删除该项
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma 
        //释放掉该项对应的vma_struct结构       
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
    //释放虚拟内存管理器
    mm=NULL;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
    check_vmm();
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
    
    check_vma_struct();
    check_pgfault();

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();//获得当前的空闲内存的大小

    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i+1);
        assert(vma2 != NULL);
        struct vma_struct *vma3 = find_vma(mm, i+2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i+3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i+4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
        struct vma_struct *vma_below_5= find_vma(mm,i);
        if (vma_below_5 != NULL ) {
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
}

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
    assert(pgdir[0] == 0);

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
    free_page(pde2page(pgdir[0]));
    pgdir[0] = 0;

    mm->pgdir = NULL;
    mm_destroy(mm);
    check_mm_struct = NULL;

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_pgfault() succeeded!\n");
}
//page fault number
volatile unsigned int pgfault_num=0;

/* do_pgfault - interrupt中断 handler to process the page fault execption
 * @mm         : the control struct for a set of vma using the same PDT
 * @error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware   错误码
 * @addr       : the addr which causes a memory access exception, (the contents of the CR2 register) CR2寄存器的内容，出错的地址
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * ======================================================================================
 *  1. 当程序运行中访问内存产生page fault异常时，如何判定这个引起异常的虚拟地址内存访问是越界、写只读页的“非法地址”访问
 *     还是由于数据被临时换出到磁盘上或还没有分配内存的“合法地址”访问？ 
    2. 何时进行请求调页/页换入换出处理？ 
    3. 如何在现有ucore的基础上实现页替换算法？ 
 * The processor provides ucore's do_pgfault function with two items of information to aid in diagnosing诊断
 * the exception and recovering from it.
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation违反访问权限报错 or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */


//do_pgfault(check_mm_struct, tf->tf_err, rcr2())
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
    //addr保存最后一次出现页故障的全32位线性地址

    int ret = -E_INVAL;// Invalid parameter =====处理不了直接返回
    //非法地址访问

    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
    //找到要用的虚拟地址所在的虚拟内存空间

    pgfault_num++;

    //If the addr is in the range of a mm's vma?
    //如果地址超出范围，那就直接报错，不进行处理
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    //check the error_code
    //检查是否目标访问页权限问题
    switch (error_code & 3) {//对11求模，即只判断低2位的情况
    /*页访问异常错误码有32位。
    位0为１表示对应物理页不存在；
    位１为１表示写异常 比如写了只读页；
    位２为１表示访问权限异常（比如用户态程序访问内核空间的数据） */
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
            //缺页异常page fault，下面要进行处理的
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
    //写操作 物理页不存在 如果不让写则非法
        if (!(vma->vm_flags & VM_WRITE)) {//vma对应的虚拟内存空间不可写
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        //还是缺页异常
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
    //读操作 存在 但触发了异常 猜测是权限不足
        cprintf("do_pgfault failed: error code flag = read AND present\n");
        goto failed;
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
    //读操作 物理页不存在 如果不允许被读或被加载则非法
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
            goto failed;
        }
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */

    // 构造需要设置的缺页页表项的perm权限
    uint32_t perm = PTE_U; //用户态 user
    if (vma->vm_flags & VM_WRITE) {
         //如果对应的虚拟内存空间可写 那么设置页表项为可写
        perm |= PTE_W;
    }

    // 构造页表项的线性地址(包括页面对齐)
    addr = ROUNDDOWN(addr, PGSIZE);
    ret = -E_NO_MEM;    //内存不足

    //声明一个页表项指针
    pte_t *ptep=NULL;
    /*LAB3 EXERCISE 1: YOUR CODE
    //给未被映射的地址映射上物理页
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : 获取一个线性地址对应的页表项地址 
    *             如果此二级页表项不存在,则分配一个包含此项的二级页表
    *   pgdir_alloc_page : 调用alloc_page和page_insert函数来分配页面大小的内存，
    *                       并且实现物理地址到线性地址的映射
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma 该虚拟内存空间的页目录表
    *
    */
#if 0
    /*LAB3 EXERCISE 1: YOUR CODE*/
    ptep = ???              //(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    if (*ptep == 0) {
                            //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr

    }
    else {
    /*LAB3 EXERCISE 2: YOUR CODE
    * Now we think this pte is a  swap entry, we should load data from disk to a page with phy addr,
    * and map the phy addr with logical addr, trigger swap manager to record the access situation of this page.
    *
    *  Some Useful MACROs and DEFINEs, you can use them in below implementation.
    *  MACROs or Functions:
    *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据PTE中的addr交换条目
    *                               找到磁盘页的addr，将磁盘页的内容读入该内存页
    *                               alloc a memory page, then according to the swap entry in PTE for addr,
    *                               find the addr of disk page, read the content of disk page into this memroy page
    *    page_insert ： 使用线性地址la建立到该页物理地址的映射
    *    swap_map_swappable ： 设置该页为可交换的
    */
        if(swap_init_ok) {
            struct Page *page=NULL;
                                    //(1）According to the mm AND addr, try to load the content of right disk page
                                    //    into the memory which page managed.
                                    //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
                                    //(3) make the page swappable.
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    ptep=get_pte(mm->pgdir,addr,1);  //并且此时已经设置了PTE_P
    //尝试找到该线性地址对应的页表项，如果页表项不存在，则创建包含该页表项的二级页表
    if(ptep==NULL){//(1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
        cprintf("get_pte failed.\n");
        goto failed;
    }
    //如果ptep是0，则说明是新创建的，需要进行线性地址与物理地址的映射
    if(*ptep==0){ // 如果是新创建的二级页表。
    //页表项全为0，即该线性地址与物理地址尚未建立映射或者已经撤销
        if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL){
            //调用alloc_page和page_insert函数来分配页面大小的内存，并且实现物理地址到线性地址的映射
            cprintf("pgdir_alloc_page failed.\n");
            goto failed;
        }
    }
    else{//如果不为0，说明可能是之前被交换到了swap磁盘中
    //相应的物理页面不在内存中（页表项非空，但Present标志位=0，比如在swap分区或磁盘文件上
        if(swap_init_ok){//开启了swap磁盘虚拟内存交换机制
            struct Page *page=NULL;
            // 将addr线性地址对应的物理页数据从磁盘交换到物理内存中
            ret=swap_in(mm,addr,&page);
            if(ret!=0){
                cprintf("swap_in failede");
                goto failed;
            }
            // 将交换进来的page页与mm->padir页表中对应addr的二级页表项建立映射关系
            page_insert(mm->pgdir,page,addr,perm);
            //map a swappable page into the mm_struct,当前page是可交换的
            swap_map_swappable(mm,addr,page,1);
            page->pra_vaddr=addr;//设置页对应的虚拟地址
        }
        else{//没有开启swap磁盘虚拟内存交换机制
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
    }
    ret = 0;
failed:
    return ret;
}

// 1.请描述页目录项（Pag Director Entry）和页表（Page Table Entry）中组成部分
// 对ucore实现页替换算法的潜在用处。

// 分页机制的实现，确保了虚拟地址和物理地址之间的对应关系，
// 一方面，通过查找虚拟地址是否存在于一二级页表中，可以容易发现该地址是否是合法的，
// 同时可以通过修改映射关系即可实现页替换操作。
// 另一方面，在实现页替换时涉及到换入换出：
// 换入时需要将某个虚拟地址对应的磁盘的一页内容读入到内存中，
// 换出时需要将某个虚拟页的内容写到磁盘中的某个位置。
// 另外，基于页表实现了地址的分段操作，
// 在这里，一个物理地址不同的位数上，
// 会存储一系列不同的信息，比如，pg_fault函数中的权限判断就用到了这方面的操作


// 2.如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
// CPU会把产生异常的线性地址存储在CR2寄存器中，
// 并且把表示页访问异常类型的error Code保存在中断栈中。
// 之后通过上述分析的trap–> trap_dispatch–>pgfault_handler–>do_pgfault调用关系，
// 一步步做出处理。

// 3.如果要在ucore上实现"extended clock页替换算法"请给你的设计方案，
// 现有的swap_manager框架是否足以支持在ucore中实现此算法？
// 如果是，请给你的设计方案。
// 如果不是，请给出你的新的扩展和基此扩展的设计方案。并需要回答如下问题
// 需要被换出的页的特征是什么？
// 在ucore中如何判断具有这样特征的页？
// 何时进行换入和换出操作？

// 在时钟置换算法中，淘汰一个页面时只考虑了页面是否被访问过，
// 但在实际情况中，还应考虑被淘汰的页面是否被修改过。
// 因为淘汰修改过的页面还需要写回硬盘，使得其置换代价大于未修改过的页面，
// 所以优先淘汰没有修改的页，减少磁盘操作次数。
// 这需要为每一页的对应页表项内容中增加一位引用位和一位修改位。

// 当该页被访问时，CPU中的MMU硬件将把访问位置“1”。当该页被“写”时，CPU中的MMU硬件将把修改位置“1”。这样这两位就存在四种可能的组合情况：

// （0，0）表示最近未被引用也未被修改，首先选择此页淘汰；
// （0，1）最近未被使用，但被修改，其次选择；
// （1，0）最近使用而未修改，再次选择；
// （1，1）最近使用且修改，最后选择。

// 该算法与时钟算法相比，可进一步减少磁盘的I/O操作次数，
// 但为了查找到一个尽可能适合淘汰的页面，可能需要经过多次扫描，增加了算法本身的执行开销。