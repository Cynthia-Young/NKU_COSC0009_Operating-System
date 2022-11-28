#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>

//pre define
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end), 
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end 

struct vma_struct {
    struct mm_struct *vm_mm; //指向所属的内存管理器 （管理属于同一页目录表下的虚拟内存空间）

    uintptr_t vm_start;
    uintptr_t vm_end;      //not include the vm_end itself
    //一个连续地址的虚拟内存空间的起始位置和结束位置  PGSIZE 对齐  严格确保 vm_start < vm_end

    uint32_t vm_flags;
    //标志位包括可读、可写、可执行

    list_entry_t list_link;  // linear list link which sorted by start addr of vma  指向线性区对象的链表头
    //双向链表项 list_entry_t有前向指针和后向指针  按地址从小到大的虚拟内存空间连起来 （不相交）
};

#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

#define VM_READ 0x00000001 //只读
#define VM_WRITE 0x00000002 //可读写
#define VM_EXEC 0x00000004 //可执行

//虚拟内存管理器 管理所有属于同一页目录表的虚拟内存空间
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma  指向线性区对象的链表头
    //双向链表头 链接了所有属于同一页目录表的虚拟内存空间

    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose   
    //当前的虚拟内存区 (局部性原理)

    pde_t *pgdir;                  // the PDT of these vma   
    //页目录表地址 查找某虚拟地址对应的页表项是否存在以及页表项的属性

    int map_count;                 // the count of these vma   
    //mmap_list 里面链接的vma_struct的个数

    void *sm_priv;                   // the private data for swap manager
    //sm_priv指向用来链接记录页访问情况的链表头，这建立了mm_struct和后续要讲到的swap_manager之间的联系
};

/*vma_create函数根据输入参数vm_start、vm_end、vm_flags来创建并初始化描述一个虚拟内存空间的vma_struct结构变量。
insert_vma_struct函数完成把一个vma变量按照其空间位置[vma->vm_start,vma->vm_end]从小到大的顺序插入到所属的mm变量中的mmap_list双向链表中。
find_vma根据输入参数addr和mm变量，查找在mm变量中的mmap_list双向链表中某个vma包含此addr，即vma->vm_start<=addr */
struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);

int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;
#endif /* !__KERN_MM_VMM_H__ */

