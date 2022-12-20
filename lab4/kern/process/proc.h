#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>


// process's state in his life cycle
//进程状态 
enum proc_state {
    PROC_UNINIT = 0,  // 未初始状态
    PROC_SLEEPING,    // 睡眠（阻塞）状态
    PROC_RUNNABLE,    // 运行与就绪态
    PROC_ZOMBIE,      // 僵死状态
};

// Saved registers for kernel context switches.
// Don't need to save all the %fs etc. segment registers,
// because they are constant across kernel contexts.
// Save all the regular registers so we don't need to care
// which are caller save, but not the return register %eax.
// (Not saving %eax just simplifies the switching code.)
// The layout of context must match code in switch.S.
//上下文切换所涉及的寄存器
struct context {
    uint32_t eip;//指令寄存器
    uint32_t esp;//堆栈指针寄存器
    uint32_t ebx;//基址寄存器
    uint32_t ecx;//计数寄存器
    uint32_t edx;//数据寄存器
    uint32_t esi;//源变址寄存器
    uint32_t edi;//目的变址寄存器
    uint32_t ebp;//基址指针寄存器
};

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

extern list_entry_t proc_list;//线程链表

//线程控制块
struct proc_struct {
    enum proc_state state;          // 进程所处状态
    int pid;                        // 进程ID
    int runs;                       // 运行时间
    uintptr_t kstack;               // 记录了分配给该进程/线程的内核桟的位置  就是运行时的程序使用的栈
                                    // KSTACKSIZE = 2 PAGESIZE
    volatile bool need_resched;     // 是否需要调度？
    struct proc_struct *parent;     // 用户进程的父进程 （创建它的线程）
    struct mm_struct *mm;           // 虚拟内存管理器
    //由于内核线程常驻内存，不需要考虑swap page问题，所以mm不发挥作用
    //mm中的pgdir成员变量负责记录页目录表起始地址，在这里用cr3记录
    struct context context;         // 进程的上下文  用于进程切换
    struct trapframe *tf;           // 中断帧的指针，总是指向内核栈的某个位置。中断帧记录了进程在被中断前的状态。
    uintptr_t cr3;                  // PDT页表的物理地址
    //内核线程时，boot_cr3指向 了uCore启动时建立好的饿内核虚拟空间的页目录表首地址
    uint32_t flags;                 // Process flag
    char name[PROC_NAME_LEN + 1];   // 进程名字
    list_entry_t list_link;         // 进程控制块链表
    list_entry_t hash_link;         // 进程哈希表
};

//proc = le2proc(le, list_link);
#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)
/*
#define to_struct(ptr, type, member)                               \
    (   (type *)  ((char *)  (ptr) - offsetof(type, member)   )  )
*/

extern struct proc_struct *idleproc, *initproc, *current;
//idleproc : 0号内核线程 功能：查询可执行线程
//initproc ： 1号内核线程
//current ： 当前占用CPU且处于“运行”状态进程控制块指针

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);

#endif /* !__KERN_PROCESS_PROC_H__ */

