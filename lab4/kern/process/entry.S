.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg 参数入栈
    call *%ebx              # call fn 调用函数

    pushl %eax              # save the return value of fn(arg) 返回值eax寄存器内容压栈
    call do_exit            # call do_exit to terminate current thread 调用do_exit函数退出线程执行

