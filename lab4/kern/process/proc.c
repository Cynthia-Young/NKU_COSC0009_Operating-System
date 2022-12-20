#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
进程状态
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
状态转移
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
进程关系
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
进程相关系统调用
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list; //所有进程控制块的双向线性列表
//proc_struct中的成员变量list_link将 链接入这个链表中

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE]; //所有进程控制块的哈希表
//proc_struct中 的成员变量hash_link将基于pid链接入这个哈希表中

// idle proc
struct proc_struct *idleproc = NULL;

// init proc
struct proc_struct *initproc = NULL;//本实验中，指向一个内核线程

// current proc
struct proc_struct *current = NULL; //当前占用CPU且处于“运行”状态进程控制块指针
//通常只读，只在进程切换时修改，切换和修改需保证操作原子性，要屏蔽中断


static int nr_process = 0;//进程数

//汇编
void kernel_thread_entry(void);//entry.s
void forkrets(struct trapframe *tf);//trapentry.s
void switch_to(struct context *from, struct context *to);//switch.s

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
//分配进程空间 并 初始化
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));//获得proc_struct结构的一块内存块
    //把proc进行初步初始化（各个成员变量清零，个别除外）
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT; //设置进程为“初始”态
        proc->pid = -1; //设置进程pid的未初始化值
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3; //使用内核页目录表的基址
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);
    }
    return proc;
}

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    /*
    MAX_PID=2*MAX_PROCESS，
    ID的总数目是大于PROCESS的总数
    无ID可分的情况
    */
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        //遍历所有线程，现有线程号与last_pid相等时，则将last_pid+1
        while ((le = list_next(le)) != list) 
        {
            //通过le获取进程
            proc = le2proc(le, list_link);
            /*
            若proc的pid=last_pid，则last_pid=last_pid+1
                若last_pid>=MAX_PID，则last_pid=1
            确保没有一个进程的pid与last_pid重合且last_pid<MAX_PID
            */
            if (proc->pid == last_pid) 
            {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) 
                    {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else 
            /*
            若proc->pid > last_pid 且 next_safe > proc->pid，
            则next_safe = proc->pid  next_safe储存了 大于last_pid的最小的被占用的id
            确保没有一个进程的pid与last_pid重合且last_pid<MAX_PID
            */            
            if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) //不是当前正在运行的进程
    {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        /*
        保护进程切换不会被中断，以免进程切换时其他进程再进行调度，相当于互斥锁
        */
        //关中断
        local_intr_save(intr_flag);
        {
            //进程切换
            current = proc; //让current指向next内核线程initproc
            load_esp0(next->kstack + KSTACKSIZE);//加载待调度进程的内核栈地址
            //设置任务状态段ts中特权态0下的栈顶指针esp0为next内核线程initproc的内核栈的栈顶， 即next->kstack + KSTACKSIZE
            lcr3(next->cr3);//cr3寄存器改为需要运行进程的页目录表
            switch_to(&(prev->context), &(next->context));//上下文切换 switch.s
        }
        //开中断
        local_intr_restore(intr_flag);
    }
}

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
//借助哈希链表寻找进程
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        //遍历
        while ((le = list_next(le)) != list) 
        {
            struct proc_struct *proc = le2proc(le, hash_link);
            //找到
            if (proc->pid == pid) 
            {
                return proc;
            }
        }
    }
    return NULL;
}
//创建执行fn函数的线程
// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
//kernel_thread(init_main, "Hello world!!", 0)
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) 
{
    struct trapframe tf; //构造新进程的中断帧
    //设置trapframe
    memset(&tf, 0, sizeof(struct trapframe)); //给tf进行清零初始化
    tf.tf_cs = KERNEL_CS;
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
    //设置中断帧的代码段（tf.tf_cs）和数据段(tf.tf_ds/tf_es/tf_ss)为内核空间的段（KERNEL_CS/KERNEL_DS）
    //实际上也说明了initproc内核线程在内核空间中执行
    tf.tf_regs.reg_ebx = (uint32_t)fn; //函数指针放入ebx寄存器
    tf.tf_regs.reg_edx = (uint32_t)arg; //参数放入edx寄存器
    tf.tf_eip = (uint32_t)kernel_thread_entry;////entry.s 线程要执行的
    //kernel_thread_entry函数主要为内核线程的主体fn函数做了一个准备开始和结 束运行的“壳”
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    //给栈分配空间
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)//分配成功
    {
        proc->kstack = (uintptr_t)page2kva(page);//设置内核虚拟地址
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "复制"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    //因为线程页表共享内核地址空间
    return 0;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) 
{
    //在内核堆栈的顶部设置中断帧大小的一块栈空间
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf; //拷贝在kernel_thread函数建立的临时中断帧的初始值
    proc->tf->tf_regs.reg_eax = 0; //设置子进程/线程执行完do_fork后的返回值 
    proc->tf->tf_esp = esp;//设置中断帧中的栈指针esp
    proc->tf->tf_eflags |= FL_IF; //FL_IF标志表示此内核线程在执行过程中，能响应中 断，打断当前的执行
    //setup the kernel entry point and stack of process
    proc->context.eip = (uintptr_t)forkret; //上下文切换要执行的 trapentry.s
    proc->context.esp = (uintptr_t)(proc->tf); //于initproc的中断帧占用了实际给initproc分配的栈空间的顶部
}

//完成具体的内部线程控制块的初始化
/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. 
 *               if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
//clone_flags =clone_flags | CLONE_VM 虚拟内存在线程间共享
//调用：do_fork(clone_flags | CLONE_VM, 0, &tf)
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC; //超出最大线程数
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. 分配并初始化进程控制块（alloc_proc函数）
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out; //没有内存空间
    }
    proc->parent = current;    
    //    2. 分配并初始化内核栈（setup_stack函数）；
    if (setup_kstack(proc) != 0) 
    {
        goto bad_fork_cleanup_proc;
    }
    //    3. 根据clone_flag标志复制或共享进程内存管理结构（copy_mm函数）；
    if (copy_mm(clone_flags, proc) != 0) 
    {
        goto bad_fork_cleanup_kstack;
    } //目前只是把current->mm设置为NULL；这是由于目前在实验四中只能创建内核线程，proc->mm描述的是进程用户态空间的情况，所以目前mm还用不上
    
    //    4. 设置进程在内核正常运行和调度所需的中断帧和执行上下文（copy_thread函数）
    copy_thread(proc, stack, tf);
    //    5. 把设置好的进程控制块放入hash_list和proc_list两个全局进程链表中
    /*
    进程进入列表的时候，可能会发生一系列的调度事件，如抢断等，
     local_intr_save(intr_flag)可以确保进程执行不被打乱。
    */
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid(); //设置返回码为子进程的id号
        hash_proc(proc);
        list_add(&proc_list, &(proc->list_link));
        nr_process ++;
    }
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
//建立 第0个线程 idleproc 创建 第1个线程 initproc
void
proc_init(void) {
    int i;
    //初始化proc_list hash_list
    list_init(&proc_list); 
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i); //hash_list创建好了每一个链表项
    }
    //设置idle_proc并进一步创建init_proc
    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }
    //设置idleproc 进行进一步初始化
    idleproc->pid = 0; //第0个内核线程
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack; //以后的其他线程的内核 栈都需要通过分配获得，因为uCore启动时设置的内核栈直接分配给idleproc使用了
    idleproc->need_resched = 1; //要求调度器切换其他进程执行
    set_proc_name(idleproc, "idle");

    nr_process ++;

    //设置当前运行线程为idleproc
    current = idleproc;

    //(init_main, "Hello world!!", 0) 1号线程的工作
    //设置好initproc 并 获取initproc 的 pid
    int pid = kernel_thread(init_main, "Hello world!!", 0);
   
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
    while (1) {
        //current 为 idleproc 是 需要调度的
        if (current->need_resched) {
            schedule();
        }
    }
}

