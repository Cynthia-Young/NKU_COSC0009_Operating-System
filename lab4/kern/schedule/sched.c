#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    //设置为可运行
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    //关中断
    local_intr_save(intr_flag);
    {
        //当前线程设为不须调度
        current->need_resched = 0;
        //current是否为idle进程（0号进程）,如果是，则从表头开始搜索  否则从当前进程在链表中的位置开始搜索
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        //遍历链表
        do {
            if ((le = list_next(le)) != &proc_list) 
            {
                //找到下一个可调度的进程
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        //没找到的话 运行idle进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        //运行次数+1
        next->runs ++;
        //如果是当前运行的进程，不需要切换
        if (next != current) 
        {
            proc_run(next);
        }
    }
    //开中断
    local_intr_restore(intr_flag);
}

