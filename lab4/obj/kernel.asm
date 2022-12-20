
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 12 00       	mov    $0x129000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 12 c0       	mov    %eax,0xc0129000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 12 c0       	mov    $0xc0128000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 54 e1 12 c0       	mov    $0xc012e154,%eax
c0100041:	2d 00 b0 12 c0       	sub    $0xc012b000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 b0 12 c0 	movl   $0xc012b000,(%esp)
c0100059:	e8 db 9e 00 00       	call   c0109f39 <memset>

    cons_init();                // init the console
c010005e:	e8 35 16 00 00       	call   c0101698 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 e0 a0 10 c0 	movl   $0xc010a0e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 fc a0 10 c0 	movl   $0xc010a0fc,(%esp)
c0100078:	e8 fb 02 00 00       	call   c0100378 <cprintf>

    print_kerninfo();
c010007d:	e8 19 08 00 00       	call   c010089b <print_kerninfo>

    grade_backtrace();
c0100082:	e8 a7 00 00 00       	call   c010012e <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 7d 55 00 00       	call   c0105609 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 e5 1f 00 00       	call   c0102076 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 6c 21 00 00       	call   c0102202 <idt_init>

    vmm_init();                 // init virtual memory management
c0100096:	e8 c4 7c 00 00       	call   c0107d5f <vmm_init>
    proc_init();                // init process table
c010009b:	e8 93 90 00 00       	call   c0109133 <proc_init>
    
    ide_init();                 // init ide devices
c01000a0:	e8 2d 17 00 00       	call   c01017d2 <ide_init>
    swap_init();                // init swap
c01000a5:	e8 ae 67 00 00       	call   c0106858 <swap_init>

    clock_init();               // init clock interrupt
c01000aa:	e8 48 0d 00 00       	call   c0100df7 <clock_init>
    intr_enable();              // enable irq interrupt
c01000af:	e8 20 1f 00 00       	call   c0101fd4 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b4:	e8 3b 92 00 00       	call   c01092f4 <cpu_idle>

c01000b9 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b9:	55                   	push   %ebp
c01000ba:	89 e5                	mov    %esp,%ebp
c01000bc:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c6:	00 
c01000c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ce:	00 
c01000cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d6:	e8 37 0c 00 00       	call   c0100d12 <mon_backtrace>
}
c01000db:	90                   	nop
c01000dc:	89 ec                	mov    %ebp,%esp
c01000de:	5d                   	pop    %ebp
c01000df:	c3                   	ret    

c01000e0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e0:	55                   	push   %ebp
c01000e1:	89 e5                	mov    %esp,%ebp
c01000e3:	83 ec 18             	sub    $0x18,%esp
c01000e6:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000ef:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100101:	89 04 24             	mov    %eax,(%esp)
c0100104:	e8 b0 ff ff ff       	call   c01000b9 <grade_backtrace2>
}
c0100109:	90                   	nop
c010010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010010d:	89 ec                	mov    %ebp,%esp
c010010f:	5d                   	pop    %ebp
c0100110:	c3                   	ret    

c0100111 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100117:	8b 45 10             	mov    0x10(%ebp),%eax
c010011a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100121:	89 04 24             	mov    %eax,(%esp)
c0100124:	e8 b7 ff ff ff       	call   c01000e0 <grade_backtrace1>
}
c0100129:	90                   	nop
c010012a:	89 ec                	mov    %ebp,%esp
c010012c:	5d                   	pop    %ebp
c010012d:	c3                   	ret    

c010012e <grade_backtrace>:

void
grade_backtrace(void) {
c010012e:	55                   	push   %ebp
c010012f:	89 e5                	mov    %esp,%ebp
c0100131:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100134:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100139:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100140:	ff 
c0100141:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010014c:	e8 c0 ff ff ff       	call   c0100111 <grade_backtrace0>
}
c0100151:	90                   	nop
c0100152:	89 ec                	mov    %ebp,%esp
c0100154:	5d                   	pop    %ebp
c0100155:	c3                   	ret    

c0100156 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100156:	55                   	push   %ebp
c0100157:	89 e5                	mov    %esp,%ebp
c0100159:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010015c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100162:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100165:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100168:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010016c:	83 e0 03             	and    $0x3,%eax
c010016f:	89 c2                	mov    %eax,%edx
c0100171:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100176:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017e:	c7 04 24 01 a1 10 c0 	movl   $0xc010a101,(%esp)
c0100185:	e8 ee 01 00 00       	call   c0100378 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010018a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018e:	89 c2                	mov    %eax,%edx
c0100190:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100195:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019d:	c7 04 24 0f a1 10 c0 	movl   $0xc010a10f,(%esp)
c01001a4:	e8 cf 01 00 00       	call   c0100378 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001ad:	89 c2                	mov    %eax,%edx
c01001af:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bc:	c7 04 24 1d a1 10 c0 	movl   $0xc010a11d,(%esp)
c01001c3:	e8 b0 01 00 00       	call   c0100378 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001cc:	89 c2                	mov    %eax,%edx
c01001ce:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001d3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001db:	c7 04 24 2b a1 10 c0 	movl   $0xc010a12b,(%esp)
c01001e2:	e8 91 01 00 00       	call   c0100378 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e7:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001eb:	89 c2                	mov    %eax,%edx
c01001ed:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fa:	c7 04 24 39 a1 10 c0 	movl   $0xc010a139,(%esp)
c0100201:	e8 72 01 00 00       	call   c0100378 <cprintf>
    round ++;
c0100206:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c010020b:	40                   	inc    %eax
c010020c:	a3 00 b0 12 c0       	mov    %eax,0xc012b000
}
c0100211:	90                   	nop
c0100212:	89 ec                	mov    %ebp,%esp
c0100214:	5d                   	pop    %ebp
c0100215:	c3                   	ret    

c0100216 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100216:	55                   	push   %ebp
c0100217:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile(
c0100219:	83 ec 08             	sub    $0x8,%esp
c010021c:	cd 78                	int    $0x78
c010021e:	89 ec                	mov    %ebp,%esp
    "int %0 \n"                    //中断
    "movl %%ebp,%%esp"             //恢复栈指针
    :
    :"i"(T_SWITCH_TOU)             //中断号
    );
}
c0100220:	90                   	nop
c0100221:	5d                   	pop    %ebp
c0100222:	c3                   	ret    

c0100223 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100223:	55                   	push   %ebp
c0100224:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
c0100226:	cd 79                	int    $0x79
c0100228:	89 ec                	mov    %ebp,%esp
     "int %0 \n"
     "movl %%ebp, %%esp \n"
     :
     : "i"(T_SWITCH_TOK)
     );
}
c010022a:	90                   	nop
c010022b:	5d                   	pop    %ebp
c010022c:	c3                   	ret    

c010022d <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010022d:	55                   	push   %ebp
c010022e:	89 e5                	mov    %esp,%ebp
c0100230:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100233:	e8 1e ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100238:	c7 04 24 48 a1 10 c0 	movl   $0xc010a148,(%esp)
c010023f:	e8 34 01 00 00       	call   c0100378 <cprintf>
    lab1_switch_to_user();
c0100244:	e8 cd ff ff ff       	call   c0100216 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100249:	e8 08 ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010024e:	c7 04 24 68 a1 10 c0 	movl   $0xc010a168,(%esp)
c0100255:	e8 1e 01 00 00       	call   c0100378 <cprintf>
    lab1_switch_to_kernel();
c010025a:	e8 c4 ff ff ff       	call   c0100223 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010025f:	e8 f2 fe ff ff       	call   c0100156 <lab1_print_cur_status>
}
c0100264:	90                   	nop
c0100265:	89 ec                	mov    %ebp,%esp
c0100267:	5d                   	pop    %ebp
c0100268:	c3                   	ret    

c0100269 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100269:	55                   	push   %ebp
c010026a:	89 e5                	mov    %esp,%ebp
c010026c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010026f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100273:	74 13                	je     c0100288 <readline+0x1f>
        cprintf("%s", prompt);
c0100275:	8b 45 08             	mov    0x8(%ebp),%eax
c0100278:	89 44 24 04          	mov    %eax,0x4(%esp)
c010027c:	c7 04 24 87 a1 10 c0 	movl   $0xc010a187,(%esp)
c0100283:	e8 f0 00 00 00       	call   c0100378 <cprintf>
    }
    int i = 0, c;
c0100288:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010028f:	e8 73 01 00 00       	call   c0100407 <getchar>
c0100294:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100297:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010029b:	79 07                	jns    c01002a4 <readline+0x3b>
            return NULL;
c010029d:	b8 00 00 00 00       	mov    $0x0,%eax
c01002a2:	eb 78                	jmp    c010031c <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01002a4:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01002a8:	7e 28                	jle    c01002d2 <readline+0x69>
c01002aa:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01002b1:	7f 1f                	jg     c01002d2 <readline+0x69>
            cputchar(c);
c01002b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b6:	89 04 24             	mov    %eax,(%esp)
c01002b9:	e8 e2 00 00 00       	call   c01003a0 <cputchar>
            buf[i ++] = c;
c01002be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002c1:	8d 50 01             	lea    0x1(%eax),%edx
c01002c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ca:	88 90 20 b0 12 c0    	mov    %dl,-0x3fed4fe0(%eax)
c01002d0:	eb 45                	jmp    c0100317 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002d2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002d6:	75 16                	jne    c01002ee <readline+0x85>
c01002d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002dc:	7e 10                	jle    c01002ee <readline+0x85>
            cputchar(c);
c01002de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e1:	89 04 24             	mov    %eax,(%esp)
c01002e4:	e8 b7 00 00 00       	call   c01003a0 <cputchar>
            i --;
c01002e9:	ff 4d f4             	decl   -0xc(%ebp)
c01002ec:	eb 29                	jmp    c0100317 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002ee:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002f2:	74 06                	je     c01002fa <readline+0x91>
c01002f4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002f8:	75 95                	jne    c010028f <readline+0x26>
            cputchar(c);
c01002fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002fd:	89 04 24             	mov    %eax,(%esp)
c0100300:	e8 9b 00 00 00       	call   c01003a0 <cputchar>
            buf[i] = '\0';
c0100305:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100308:	05 20 b0 12 c0       	add    $0xc012b020,%eax
c010030d:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100310:	b8 20 b0 12 c0       	mov    $0xc012b020,%eax
c0100315:	eb 05                	jmp    c010031c <readline+0xb3>
        c = getchar();
c0100317:	e9 73 ff ff ff       	jmp    c010028f <readline+0x26>
        }
    }
}
c010031c:	89 ec                	mov    %ebp,%esp
c010031e:	5d                   	pop    %ebp
c010031f:	c3                   	ret    

c0100320 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100320:	55                   	push   %ebp
c0100321:	89 e5                	mov    %esp,%ebp
c0100323:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100326:	8b 45 08             	mov    0x8(%ebp),%eax
c0100329:	89 04 24             	mov    %eax,(%esp)
c010032c:	e8 96 13 00 00       	call   c01016c7 <cons_putc>
    (*cnt) ++;
c0100331:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100334:	8b 00                	mov    (%eax),%eax
c0100336:	8d 50 01             	lea    0x1(%eax),%edx
c0100339:	8b 45 0c             	mov    0xc(%ebp),%eax
c010033c:	89 10                	mov    %edx,(%eax)
}
c010033e:	90                   	nop
c010033f:	89 ec                	mov    %ebp,%esp
c0100341:	5d                   	pop    %ebp
c0100342:	c3                   	ret    

c0100343 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100343:	55                   	push   %ebp
c0100344:	89 e5                	mov    %esp,%ebp
c0100346:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100349:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100350:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100353:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100357:	8b 45 08             	mov    0x8(%ebp),%eax
c010035a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010035e:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100361:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100365:	c7 04 24 20 03 10 c0 	movl   $0xc0100320,(%esp)
c010036c:	e8 1b 93 00 00       	call   c010968c <vprintfmt>
    return cnt;
c0100371:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100374:	89 ec                	mov    %ebp,%esp
c0100376:	5d                   	pop    %ebp
c0100377:	c3                   	ret    

c0100378 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100378:	55                   	push   %ebp
c0100379:	89 e5                	mov    %esp,%ebp
c010037b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010037e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100381:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100384:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100387:	89 44 24 04          	mov    %eax,0x4(%esp)
c010038b:	8b 45 08             	mov    0x8(%ebp),%eax
c010038e:	89 04 24             	mov    %eax,(%esp)
c0100391:	e8 ad ff ff ff       	call   c0100343 <vcprintf>
c0100396:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100399:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010039c:	89 ec                	mov    %ebp,%esp
c010039e:	5d                   	pop    %ebp
c010039f:	c3                   	ret    

c01003a0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01003a0:	55                   	push   %ebp
c01003a1:	89 e5                	mov    %esp,%ebp
c01003a3:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01003a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a9:	89 04 24             	mov    %eax,(%esp)
c01003ac:	e8 16 13 00 00       	call   c01016c7 <cons_putc>
}
c01003b1:	90                   	nop
c01003b2:	89 ec                	mov    %ebp,%esp
c01003b4:	5d                   	pop    %ebp
c01003b5:	c3                   	ret    

c01003b6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01003b6:	55                   	push   %ebp
c01003b7:	89 e5                	mov    %esp,%ebp
c01003b9:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01003bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003c3:	eb 13                	jmp    c01003d8 <cputs+0x22>
        cputch(c, &cnt);
c01003c5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003c9:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003cc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003d0:	89 04 24             	mov    %eax,(%esp)
c01003d3:	e8 48 ff ff ff       	call   c0100320 <cputch>
    while ((c = *str ++) != '\0') {
c01003d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01003db:	8d 50 01             	lea    0x1(%eax),%edx
c01003de:	89 55 08             	mov    %edx,0x8(%ebp)
c01003e1:	0f b6 00             	movzbl (%eax),%eax
c01003e4:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003e7:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003eb:	75 d8                	jne    c01003c5 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003f4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003fb:	e8 20 ff ff ff       	call   c0100320 <cputch>
    return cnt;
c0100400:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100403:	89 ec                	mov    %ebp,%esp
c0100405:	5d                   	pop    %ebp
c0100406:	c3                   	ret    

c0100407 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100407:	55                   	push   %ebp
c0100408:	89 e5                	mov    %esp,%ebp
c010040a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010040d:	90                   	nop
c010040e:	e8 f3 12 00 00       	call   c0101706 <cons_getc>
c0100413:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100416:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010041a:	74 f2                	je     c010040e <getchar+0x7>
        /* do nothing */;
    return c;
c010041c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010041f:	89 ec                	mov    %ebp,%esp
c0100421:	5d                   	pop    %ebp
c0100422:	c3                   	ret    

c0100423 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100423:	55                   	push   %ebp
c0100424:	89 e5                	mov    %esp,%ebp
c0100426:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100429:	8b 45 0c             	mov    0xc(%ebp),%eax
c010042c:	8b 00                	mov    (%eax),%eax
c010042e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100431:	8b 45 10             	mov    0x10(%ebp),%eax
c0100434:	8b 00                	mov    (%eax),%eax
c0100436:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100439:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100440:	e9 ca 00 00 00       	jmp    c010050f <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100445:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100448:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010044b:	01 d0                	add    %edx,%eax
c010044d:	89 c2                	mov    %eax,%edx
c010044f:	c1 ea 1f             	shr    $0x1f,%edx
c0100452:	01 d0                	add    %edx,%eax
c0100454:	d1 f8                	sar    %eax
c0100456:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100459:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045c:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010045f:	eb 03                	jmp    c0100464 <stab_binsearch+0x41>
            m --;
c0100461:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100464:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100467:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046a:	7c 1f                	jl     c010048b <stab_binsearch+0x68>
c010046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046f:	89 d0                	mov    %edx,%eax
c0100471:	01 c0                	add    %eax,%eax
c0100473:	01 d0                	add    %edx,%eax
c0100475:	c1 e0 02             	shl    $0x2,%eax
c0100478:	89 c2                	mov    %eax,%edx
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	01 d0                	add    %edx,%eax
c010047f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100483:	0f b6 c0             	movzbl %al,%eax
c0100486:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100489:	75 d6                	jne    c0100461 <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c010048b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010048e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100491:	7d 09                	jge    c010049c <stab_binsearch+0x79>
            l = true_m + 1;
c0100493:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100496:	40                   	inc    %eax
c0100497:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010049a:	eb 73                	jmp    c010050f <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010049c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c01004a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a6:	89 d0                	mov    %edx,%eax
c01004a8:	01 c0                	add    %eax,%eax
c01004aa:	01 d0                	add    %edx,%eax
c01004ac:	c1 e0 02             	shl    $0x2,%eax
c01004af:	89 c2                	mov    %eax,%edx
c01004b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01004b4:	01 d0                	add    %edx,%eax
c01004b6:	8b 40 08             	mov    0x8(%eax),%eax
c01004b9:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004bc:	76 11                	jbe    c01004cf <stab_binsearch+0xac>
            *region_left = m;
c01004be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004c4:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004c9:	40                   	inc    %eax
c01004ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004cd:	eb 40                	jmp    c010050f <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d2:	89 d0                	mov    %edx,%eax
c01004d4:	01 c0                	add    %eax,%eax
c01004d6:	01 d0                	add    %edx,%eax
c01004d8:	c1 e0 02             	shl    $0x2,%eax
c01004db:	89 c2                	mov    %eax,%edx
c01004dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01004e0:	01 d0                	add    %edx,%eax
c01004e2:	8b 40 08             	mov    0x8(%eax),%eax
c01004e5:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004e8:	73 14                	jae    c01004fe <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ed:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01004f3:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f8:	48                   	dec    %eax
c01004f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004fc:	eb 11                	jmp    c010050f <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100501:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100504:	89 10                	mov    %edx,(%eax)
            l = m;
c0100506:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100509:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c010050c:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c010050f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100512:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100515:	0f 8e 2a ff ff ff    	jle    c0100445 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c010051b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010051f:	75 0f                	jne    c0100530 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c0100521:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100524:	8b 00                	mov    (%eax),%eax
c0100526:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100529:	8b 45 10             	mov    0x10(%ebp),%eax
c010052c:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010052e:	eb 3e                	jmp    c010056e <stab_binsearch+0x14b>
        l = *region_right;
c0100530:	8b 45 10             	mov    0x10(%ebp),%eax
c0100533:	8b 00                	mov    (%eax),%eax
c0100535:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100538:	eb 03                	jmp    c010053d <stab_binsearch+0x11a>
c010053a:	ff 4d fc             	decl   -0x4(%ebp)
c010053d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100540:	8b 00                	mov    (%eax),%eax
c0100542:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100545:	7e 1f                	jle    c0100566 <stab_binsearch+0x143>
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 d0                	mov    %edx,%eax
c010054c:	01 c0                	add    %eax,%eax
c010054e:	01 d0                	add    %edx,%eax
c0100550:	c1 e0 02             	shl    $0x2,%eax
c0100553:	89 c2                	mov    %eax,%edx
c0100555:	8b 45 08             	mov    0x8(%ebp),%eax
c0100558:	01 d0                	add    %edx,%eax
c010055a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010055e:	0f b6 c0             	movzbl %al,%eax
c0100561:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100564:	75 d4                	jne    c010053a <stab_binsearch+0x117>
        *region_left = l;
c0100566:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100569:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010056c:	89 10                	mov    %edx,(%eax)
}
c010056e:	90                   	nop
c010056f:	89 ec                	mov    %ebp,%esp
c0100571:	5d                   	pop    %ebp
c0100572:	c3                   	ret    

c0100573 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100573:	55                   	push   %ebp
c0100574:	89 e5                	mov    %esp,%ebp
c0100576:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057c:	c7 00 8c a1 10 c0    	movl   $0xc010a18c,(%eax)
    info->eip_line = 0;
c0100582:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100585:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010058c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058f:	c7 40 08 8c a1 10 c0 	movl   $0xc010a18c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100596:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100599:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c01005a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a3:	8b 55 08             	mov    0x8(%ebp),%edx
c01005a6:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01005a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ac:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01005b3:	c7 45 f4 40 c4 10 c0 	movl   $0xc010c440,-0xc(%ebp)
    stab_end = __STAB_END__;
c01005ba:	c7 45 f0 38 f2 11 c0 	movl   $0xc011f238,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01005c1:	c7 45 ec 39 f2 11 c0 	movl   $0xc011f239,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005c8:	c7 45 e8 ce 56 12 c0 	movl   $0xc01256ce,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005d2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005d5:	76 0b                	jbe    c01005e2 <debuginfo_eip+0x6f>
c01005d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005da:	48                   	dec    %eax
c01005db:	0f b6 00             	movzbl (%eax),%eax
c01005de:	84 c0                	test   %al,%al
c01005e0:	74 0a                	je     c01005ec <debuginfo_eip+0x79>
        return -1;
c01005e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005e7:	e9 ab 02 00 00       	jmp    c0100897 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005f6:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005f9:	c1 f8 02             	sar    $0x2,%eax
c01005fc:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0100602:	48                   	dec    %eax
c0100603:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0100606:	8b 45 08             	mov    0x8(%ebp),%eax
c0100609:	89 44 24 10          	mov    %eax,0x10(%esp)
c010060d:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100614:	00 
c0100615:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0100618:	89 44 24 08          	mov    %eax,0x8(%esp)
c010061c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010061f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100623:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100626:	89 04 24             	mov    %eax,(%esp)
c0100629:	e8 f5 fd ff ff       	call   c0100423 <stab_binsearch>
    if (lfile == 0)
c010062e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100631:	85 c0                	test   %eax,%eax
c0100633:	75 0a                	jne    c010063f <debuginfo_eip+0xcc>
        return -1;
c0100635:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010063a:	e9 58 02 00 00       	jmp    c0100897 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010063f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100642:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100645:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100648:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010064b:	8b 45 08             	mov    0x8(%ebp),%eax
c010064e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100652:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100659:	00 
c010065a:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010065d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100661:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100664:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100668:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066b:	89 04 24             	mov    %eax,(%esp)
c010066e:	e8 b0 fd ff ff       	call   c0100423 <stab_binsearch>

    if (lfun <= rfun) {
c0100673:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100676:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100679:	39 c2                	cmp    %eax,%edx
c010067b:	7f 78                	jg     c01006f5 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010067d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100680:	89 c2                	mov    %eax,%edx
c0100682:	89 d0                	mov    %edx,%eax
c0100684:	01 c0                	add    %eax,%eax
c0100686:	01 d0                	add    %edx,%eax
c0100688:	c1 e0 02             	shl    $0x2,%eax
c010068b:	89 c2                	mov    %eax,%edx
c010068d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100690:	01 d0                	add    %edx,%eax
c0100692:	8b 10                	mov    (%eax),%edx
c0100694:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100697:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010069a:	39 c2                	cmp    %eax,%edx
c010069c:	73 22                	jae    c01006c0 <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	89 d0                	mov    %edx,%eax
c01006a5:	01 c0                	add    %eax,%eax
c01006a7:	01 d0                	add    %edx,%eax
c01006a9:	c1 e0 02             	shl    $0x2,%eax
c01006ac:	89 c2                	mov    %eax,%edx
c01006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	8b 10                	mov    (%eax),%edx
c01006b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01006b8:	01 c2                	add    %eax,%edx
c01006ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006bd:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c3:	89 c2                	mov    %eax,%edx
c01006c5:	89 d0                	mov    %edx,%eax
c01006c7:	01 c0                	add    %eax,%eax
c01006c9:	01 d0                	add    %edx,%eax
c01006cb:	c1 e0 02             	shl    $0x2,%eax
c01006ce:	89 c2                	mov    %eax,%edx
c01006d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d3:	01 d0                	add    %edx,%eax
c01006d5:	8b 50 08             	mov    0x8(%eax),%edx
c01006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006db:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e1:	8b 40 10             	mov    0x10(%eax),%eax
c01006e4:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006f3:	eb 15                	jmp    c010070a <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01006fb:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100701:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100704:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100707:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c010070a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070d:	8b 40 08             	mov    0x8(%eax),%eax
c0100710:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0100717:	00 
c0100718:	89 04 24             	mov    %eax,(%esp)
c010071b:	e8 91 96 00 00       	call   c0109db1 <strfind>
c0100720:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100723:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100726:	29 c8                	sub    %ecx,%eax
c0100728:	89 c2                	mov    %eax,%edx
c010072a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010072d:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100730:	8b 45 08             	mov    0x8(%ebp),%eax
c0100733:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100737:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010073e:	00 
c010073f:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100742:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100746:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100749:	89 44 24 04          	mov    %eax,0x4(%esp)
c010074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100750:	89 04 24             	mov    %eax,(%esp)
c0100753:	e8 cb fc ff ff       	call   c0100423 <stab_binsearch>
    if (lline <= rline) {
c0100758:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010075b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010075e:	39 c2                	cmp    %eax,%edx
c0100760:	7f 23                	jg     c0100785 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100762:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100765:	89 c2                	mov    %eax,%edx
c0100767:	89 d0                	mov    %edx,%eax
c0100769:	01 c0                	add    %eax,%eax
c010076b:	01 d0                	add    %edx,%eax
c010076d:	c1 e0 02             	shl    $0x2,%eax
c0100770:	89 c2                	mov    %eax,%edx
c0100772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100775:	01 d0                	add    %edx,%eax
c0100777:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010077b:	89 c2                	mov    %eax,%edx
c010077d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100780:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100783:	eb 11                	jmp    c0100796 <debuginfo_eip+0x223>
        return -1;
c0100785:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010078a:	e9 08 01 00 00       	jmp    c0100897 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010078f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100792:	48                   	dec    %eax
c0100793:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100796:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100799:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010079c:	39 c2                	cmp    %eax,%edx
c010079e:	7c 56                	jl     c01007f6 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c01007a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007a3:	89 c2                	mov    %eax,%edx
c01007a5:	89 d0                	mov    %edx,%eax
c01007a7:	01 c0                	add    %eax,%eax
c01007a9:	01 d0                	add    %edx,%eax
c01007ab:	c1 e0 02             	shl    $0x2,%eax
c01007ae:	89 c2                	mov    %eax,%edx
c01007b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007b3:	01 d0                	add    %edx,%eax
c01007b5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b9:	3c 84                	cmp    $0x84,%al
c01007bb:	74 39                	je     c01007f6 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c0:	89 c2                	mov    %eax,%edx
c01007c2:	89 d0                	mov    %edx,%eax
c01007c4:	01 c0                	add    %eax,%eax
c01007c6:	01 d0                	add    %edx,%eax
c01007c8:	c1 e0 02             	shl    $0x2,%eax
c01007cb:	89 c2                	mov    %eax,%edx
c01007cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d0:	01 d0                	add    %edx,%eax
c01007d2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007d6:	3c 64                	cmp    $0x64,%al
c01007d8:	75 b5                	jne    c010078f <debuginfo_eip+0x21c>
c01007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007dd:	89 c2                	mov    %eax,%edx
c01007df:	89 d0                	mov    %edx,%eax
c01007e1:	01 c0                	add    %eax,%eax
c01007e3:	01 d0                	add    %edx,%eax
c01007e5:	c1 e0 02             	shl    $0x2,%eax
c01007e8:	89 c2                	mov    %eax,%edx
c01007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ed:	01 d0                	add    %edx,%eax
c01007ef:	8b 40 08             	mov    0x8(%eax),%eax
c01007f2:	85 c0                	test   %eax,%eax
c01007f4:	74 99                	je     c010078f <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007fc:	39 c2                	cmp    %eax,%edx
c01007fe:	7c 42                	jl     c0100842 <debuginfo_eip+0x2cf>
c0100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	89 d0                	mov    %edx,%eax
c0100807:	01 c0                	add    %eax,%eax
c0100809:	01 d0                	add    %edx,%eax
c010080b:	c1 e0 02             	shl    $0x2,%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	01 d0                	add    %edx,%eax
c0100815:	8b 10                	mov    (%eax),%edx
c0100817:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010081a:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010081d:	39 c2                	cmp    %eax,%edx
c010081f:	73 21                	jae    c0100842 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100821:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100824:	89 c2                	mov    %eax,%edx
c0100826:	89 d0                	mov    %edx,%eax
c0100828:	01 c0                	add    %eax,%eax
c010082a:	01 d0                	add    %edx,%eax
c010082c:	c1 e0 02             	shl    $0x2,%eax
c010082f:	89 c2                	mov    %eax,%edx
c0100831:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100834:	01 d0                	add    %edx,%eax
c0100836:	8b 10                	mov    (%eax),%edx
c0100838:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010083b:	01 c2                	add    %eax,%edx
c010083d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100840:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100842:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100845:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100848:	39 c2                	cmp    %eax,%edx
c010084a:	7d 46                	jge    c0100892 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010084c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010084f:	40                   	inc    %eax
c0100850:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100853:	eb 16                	jmp    c010086b <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100855:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100858:	8b 40 14             	mov    0x14(%eax),%eax
c010085b:	8d 50 01             	lea    0x1(%eax),%edx
c010085e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100861:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100867:	40                   	inc    %eax
c0100868:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010086b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010086e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100871:	39 c2                	cmp    %eax,%edx
c0100873:	7d 1d                	jge    c0100892 <debuginfo_eip+0x31f>
c0100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100878:	89 c2                	mov    %eax,%edx
c010087a:	89 d0                	mov    %edx,%eax
c010087c:	01 c0                	add    %eax,%eax
c010087e:	01 d0                	add    %edx,%eax
c0100880:	c1 e0 02             	shl    $0x2,%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100888:	01 d0                	add    %edx,%eax
c010088a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010088e:	3c a0                	cmp    $0xa0,%al
c0100890:	74 c3                	je     c0100855 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100892:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100897:	89 ec                	mov    %ebp,%esp
c0100899:	5d                   	pop    %ebp
c010089a:	c3                   	ret    

c010089b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010089b:	55                   	push   %ebp
c010089c:	89 e5                	mov    %esp,%ebp
c010089e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c01008a1:	c7 04 24 96 a1 10 c0 	movl   $0xc010a196,(%esp)
c01008a8:	e8 cb fa ff ff       	call   c0100378 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01008ad:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008b4:	c0 
c01008b5:	c7 04 24 af a1 10 c0 	movl   $0xc010a1af,(%esp)
c01008bc:	e8 b7 fa ff ff       	call   c0100378 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008c1:	c7 44 24 04 c5 a0 10 	movl   $0xc010a0c5,0x4(%esp)
c01008c8:	c0 
c01008c9:	c7 04 24 c7 a1 10 c0 	movl   $0xc010a1c7,(%esp)
c01008d0:	e8 a3 fa ff ff       	call   c0100378 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008d5:	c7 44 24 04 00 b0 12 	movl   $0xc012b000,0x4(%esp)
c01008dc:	c0 
c01008dd:	c7 04 24 df a1 10 c0 	movl   $0xc010a1df,(%esp)
c01008e4:	e8 8f fa ff ff       	call   c0100378 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008e9:	c7 44 24 04 54 e1 12 	movl   $0xc012e154,0x4(%esp)
c01008f0:	c0 
c01008f1:	c7 04 24 f7 a1 10 c0 	movl   $0xc010a1f7,(%esp)
c01008f8:	e8 7b fa ff ff       	call   c0100378 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008fd:	b8 54 e1 12 c0       	mov    $0xc012e154,%eax
c0100902:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c0100907:	05 ff 03 00 00       	add    $0x3ff,%eax
c010090c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100912:	85 c0                	test   %eax,%eax
c0100914:	0f 48 c2             	cmovs  %edx,%eax
c0100917:	c1 f8 0a             	sar    $0xa,%eax
c010091a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091e:	c7 04 24 10 a2 10 c0 	movl   $0xc010a210,(%esp)
c0100925:	e8 4e fa ff ff       	call   c0100378 <cprintf>
}
c010092a:	90                   	nop
c010092b:	89 ec                	mov    %ebp,%esp
c010092d:	5d                   	pop    %ebp
c010092e:	c3                   	ret    

c010092f <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010092f:	55                   	push   %ebp
c0100930:	89 e5                	mov    %esp,%ebp
c0100932:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100938:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010093b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010093f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100942:	89 04 24             	mov    %eax,(%esp)
c0100945:	e8 29 fc ff ff       	call   c0100573 <debuginfo_eip>
c010094a:	85 c0                	test   %eax,%eax
c010094c:	74 15                	je     c0100963 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010094e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100951:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100955:	c7 04 24 3a a2 10 c0 	movl   $0xc010a23a,(%esp)
c010095c:	e8 17 fa ff ff       	call   c0100378 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100961:	eb 6c                	jmp    c01009cf <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100963:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010096a:	eb 1b                	jmp    c0100987 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010096c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010096f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100972:	01 d0                	add    %edx,%eax
c0100974:	0f b6 10             	movzbl (%eax),%edx
c0100977:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010097d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100980:	01 c8                	add    %ecx,%eax
c0100982:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100984:	ff 45 f4             	incl   -0xc(%ebp)
c0100987:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010098a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010098d:	7c dd                	jl     c010096c <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010098f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100995:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100998:	01 d0                	add    %edx,%eax
c010099a:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010099d:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c01009a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01009a3:	29 d0                	sub    %edx,%eax
c01009a5:	89 c1                	mov    %eax,%ecx
c01009a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01009aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009ad:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009b1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009b7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009bb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c3:	c7 04 24 56 a2 10 c0 	movl   $0xc010a256,(%esp)
c01009ca:	e8 a9 f9 ff ff       	call   c0100378 <cprintf>
}
c01009cf:	90                   	nop
c01009d0:	89 ec                	mov    %ebp,%esp
c01009d2:	5d                   	pop    %ebp
c01009d3:	c3                   	ret    

c01009d4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009d4:	55                   	push   %ebp
c01009d5:	89 e5                	mov    %esp,%ebp
c01009d7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009da:	8b 45 04             	mov    0x4(%ebp),%eax
c01009dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009e3:	89 ec                	mov    %ebp,%esp
c01009e5:	5d                   	pop    %ebp
c01009e6:	c3                   	ret    

c01009e7 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009e7:	55                   	push   %ebp
c01009e8:	89 e5                	mov    %esp,%ebp
c01009ea:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009ed:	89 e8                	mov    %ebp,%eax
c01009ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp();
c01009f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t eip = read_eip();
c01009f8:	e8 d7 ff ff ff       	call   c01009d4 <read_eip>
c01009fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++)
c0100a00:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100a07:	e9 ad 00 00 00       	jmp    c0100ab9 <print_stackframe+0xd2>
	{
		cprintf("ebp:0x%08x eip:0x%08x" , ebp, eip);
c0100a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a1a:	c7 04 24 68 a2 10 c0 	movl   $0xc010a268,(%esp)
c0100a21:	e8 52 f9 ff ff       	call   c0100378 <cprintf>
		uint32_t *arguments = (uint32_t *)ebp + 2;
c0100a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a29:	83 c0 08             	add    $0x8,%eax
c0100a2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (int j = 0; j < 4; j++)
c0100a2f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a36:	eb 4d                	jmp    c0100a85 <print_stackframe+0x9e>
		{
			if (j == 0) cprintf(" args:0x%08x" , arguments[j]);
c0100a38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0100a3c:	75 23                	jne    c0100a61 <print_stackframe+0x7a>
c0100a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a41:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a4b:	01 d0                	add    %edx,%eax
c0100a4d:	8b 00                	mov    (%eax),%eax
c0100a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a53:	c7 04 24 7e a2 10 c0 	movl   $0xc010a27e,(%esp)
c0100a5a:	e8 19 f9 ff ff       	call   c0100378 <cprintf>
c0100a5f:	eb 21                	jmp    c0100a82 <print_stackframe+0x9b>
			else cprintf(" 0x%08x" , arguments[j]);
c0100a61:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a64:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a6e:	01 d0                	add    %edx,%eax
c0100a70:	8b 00                	mov    (%eax),%eax
c0100a72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a76:	c7 04 24 8b a2 10 c0 	movl   $0xc010a28b,(%esp)
c0100a7d:	e8 f6 f8 ff ff       	call   c0100378 <cprintf>
		for (int j = 0; j < 4; j++)
c0100a82:	ff 45 e8             	incl   -0x18(%ebp)
c0100a85:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a89:	7e ad                	jle    c0100a38 <print_stackframe+0x51>
		}
		cprintf("\n");
c0100a8b:	c7 04 24 93 a2 10 c0 	movl   $0xc010a293,(%esp)
c0100a92:	e8 e1 f8 ff ff       	call   c0100378 <cprintf>
		print_debuginfo(eip-1);
c0100a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a9a:	48                   	dec    %eax
c0100a9b:	89 04 24             	mov    %eax,(%esp)
c0100a9e:	e8 8c fe ff ff       	call   c010092f <print_debuginfo>
		eip = ((uint32_t *)ebp)[1];
c0100aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa6:	83 c0 04             	add    $0x4,%eax
c0100aa9:	8b 00                	mov    (%eax),%eax
c0100aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
		ebp = ((uint32_t *)ebp)[0];
c0100aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab1:	8b 00                	mov    (%eax),%eax
c0100ab3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++)
c0100ab6:	ff 45 ec             	incl   -0x14(%ebp)
c0100ab9:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100abd:	7f 0a                	jg     c0100ac9 <print_stackframe+0xe2>
c0100abf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100ac3:	0f 85 43 ff ff ff    	jne    c0100a0c <print_stackframe+0x25>
	}     
}
c0100ac9:	90                   	nop
c0100aca:	89 ec                	mov    %ebp,%esp
c0100acc:	5d                   	pop    %ebp
c0100acd:	c3                   	ret    

c0100ace <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ace:	55                   	push   %ebp
c0100acf:	89 e5                	mov    %esp,%ebp
c0100ad1:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ad4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100adb:	eb 0c                	jmp    c0100ae9 <parse+0x1b>
            *buf ++ = '\0';
c0100add:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae0:	8d 50 01             	lea    0x1(%eax),%edx
c0100ae3:	89 55 08             	mov    %edx,0x8(%ebp)
c0100ae6:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aec:	0f b6 00             	movzbl (%eax),%eax
c0100aef:	84 c0                	test   %al,%al
c0100af1:	74 1d                	je     c0100b10 <parse+0x42>
c0100af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af6:	0f b6 00             	movzbl (%eax),%eax
c0100af9:	0f be c0             	movsbl %al,%eax
c0100afc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b00:	c7 04 24 18 a3 10 c0 	movl   $0xc010a318,(%esp)
c0100b07:	e8 71 92 00 00       	call   c0109d7d <strchr>
c0100b0c:	85 c0                	test   %eax,%eax
c0100b0e:	75 cd                	jne    c0100add <parse+0xf>
        }
        if (*buf == '\0') {
c0100b10:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b13:	0f b6 00             	movzbl (%eax),%eax
c0100b16:	84 c0                	test   %al,%al
c0100b18:	74 65                	je     c0100b7f <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b1a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b1e:	75 14                	jne    c0100b34 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b20:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b27:	00 
c0100b28:	c7 04 24 1d a3 10 c0 	movl   $0xc010a31d,(%esp)
c0100b2f:	e8 44 f8 ff ff       	call   c0100378 <cprintf>
        }
        argv[argc ++] = buf;
c0100b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b37:	8d 50 01             	lea    0x1(%eax),%edx
c0100b3a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b3d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b47:	01 c2                	add    %eax,%edx
c0100b49:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4c:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b4e:	eb 03                	jmp    c0100b53 <parse+0x85>
            buf ++;
c0100b50:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b56:	0f b6 00             	movzbl (%eax),%eax
c0100b59:	84 c0                	test   %al,%al
c0100b5b:	74 8c                	je     c0100ae9 <parse+0x1b>
c0100b5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b60:	0f b6 00             	movzbl (%eax),%eax
c0100b63:	0f be c0             	movsbl %al,%eax
c0100b66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b6a:	c7 04 24 18 a3 10 c0 	movl   $0xc010a318,(%esp)
c0100b71:	e8 07 92 00 00       	call   c0109d7d <strchr>
c0100b76:	85 c0                	test   %eax,%eax
c0100b78:	74 d6                	je     c0100b50 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b7a:	e9 6a ff ff ff       	jmp    c0100ae9 <parse+0x1b>
            break;
c0100b7f:	90                   	nop
        }
    }
    return argc;
c0100b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b83:	89 ec                	mov    %ebp,%esp
c0100b85:	5d                   	pop    %ebp
c0100b86:	c3                   	ret    

c0100b87 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b87:	55                   	push   %ebp
c0100b88:	89 e5                	mov    %esp,%ebp
c0100b8a:	83 ec 68             	sub    $0x68,%esp
c0100b8d:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b90:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9a:	89 04 24             	mov    %eax,(%esp)
c0100b9d:	e8 2c ff ff ff       	call   c0100ace <parse>
c0100ba2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100ba5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100ba9:	75 0a                	jne    c0100bb5 <runcmd+0x2e>
        return 0;
c0100bab:	b8 00 00 00 00       	mov    $0x0,%eax
c0100bb0:	e9 83 00 00 00       	jmp    c0100c38 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100bbc:	eb 5a                	jmp    c0100c18 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100bbe:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100bc1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100bc4:	89 c8                	mov    %ecx,%eax
c0100bc6:	01 c0                	add    %eax,%eax
c0100bc8:	01 c8                	add    %ecx,%eax
c0100bca:	c1 e0 02             	shl    $0x2,%eax
c0100bcd:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0100bd2:	8b 00                	mov    (%eax),%eax
c0100bd4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bd8:	89 04 24             	mov    %eax,(%esp)
c0100bdb:	e8 01 91 00 00       	call   c0109ce1 <strcmp>
c0100be0:	85 c0                	test   %eax,%eax
c0100be2:	75 31                	jne    c0100c15 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100be4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100be7:	89 d0                	mov    %edx,%eax
c0100be9:	01 c0                	add    %eax,%eax
c0100beb:	01 d0                	add    %edx,%eax
c0100bed:	c1 e0 02             	shl    $0x2,%eax
c0100bf0:	05 08 80 12 c0       	add    $0xc0128008,%eax
c0100bf5:	8b 10                	mov    (%eax),%edx
c0100bf7:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bfa:	83 c0 04             	add    $0x4,%eax
c0100bfd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c00:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c06:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c0e:	89 1c 24             	mov    %ebx,(%esp)
c0100c11:	ff d2                	call   *%edx
c0100c13:	eb 23                	jmp    c0100c38 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c15:	ff 45 f4             	incl   -0xc(%ebp)
c0100c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c1b:	83 f8 02             	cmp    $0x2,%eax
c0100c1e:	76 9e                	jbe    c0100bbe <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c20:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c27:	c7 04 24 3b a3 10 c0 	movl   $0xc010a33b,(%esp)
c0100c2e:	e8 45 f7 ff ff       	call   c0100378 <cprintf>
    return 0;
c0100c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100c38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c3b:	89 ec                	mov    %ebp,%esp
c0100c3d:	5d                   	pop    %ebp
c0100c3e:	c3                   	ret    

c0100c3f <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c3f:	55                   	push   %ebp
c0100c40:	89 e5                	mov    %esp,%ebp
c0100c42:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c45:	c7 04 24 54 a3 10 c0 	movl   $0xc010a354,(%esp)
c0100c4c:	e8 27 f7 ff ff       	call   c0100378 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c51:	c7 04 24 7c a3 10 c0 	movl   $0xc010a37c,(%esp)
c0100c58:	e8 1b f7 ff ff       	call   c0100378 <cprintf>

    if (tf != NULL) {
c0100c5d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c61:	74 0b                	je     c0100c6e <kmonitor+0x2f>
        print_trapframe(tf);
c0100c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c66:	89 04 24             	mov    %eax,(%esp)
c0100c69:	e8 4e 17 00 00       	call   c01023bc <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c6e:	c7 04 24 a1 a3 10 c0 	movl   $0xc010a3a1,(%esp)
c0100c75:	e8 ef f5 ff ff       	call   c0100269 <readline>
c0100c7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c81:	74 eb                	je     c0100c6e <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c83:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8d:	89 04 24             	mov    %eax,(%esp)
c0100c90:	e8 f2 fe ff ff       	call   c0100b87 <runcmd>
c0100c95:	85 c0                	test   %eax,%eax
c0100c97:	78 02                	js     c0100c9b <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c99:	eb d3                	jmp    c0100c6e <kmonitor+0x2f>
                break;
c0100c9b:	90                   	nop
            }
        }
    }
}
c0100c9c:	90                   	nop
c0100c9d:	89 ec                	mov    %ebp,%esp
c0100c9f:	5d                   	pop    %ebp
c0100ca0:	c3                   	ret    

c0100ca1 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100ca1:	55                   	push   %ebp
c0100ca2:	89 e5                	mov    %esp,%ebp
c0100ca4:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ca7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100cae:	eb 3d                	jmp    c0100ced <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100cb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cb3:	89 d0                	mov    %edx,%eax
c0100cb5:	01 c0                	add    %eax,%eax
c0100cb7:	01 d0                	add    %edx,%eax
c0100cb9:	c1 e0 02             	shl    $0x2,%eax
c0100cbc:	05 04 80 12 c0       	add    $0xc0128004,%eax
c0100cc1:	8b 10                	mov    (%eax),%edx
c0100cc3:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100cc6:	89 c8                	mov    %ecx,%eax
c0100cc8:	01 c0                	add    %eax,%eax
c0100cca:	01 c8                	add    %ecx,%eax
c0100ccc:	c1 e0 02             	shl    $0x2,%eax
c0100ccf:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0100cd4:	8b 00                	mov    (%eax),%eax
c0100cd6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cde:	c7 04 24 a5 a3 10 c0 	movl   $0xc010a3a5,(%esp)
c0100ce5:	e8 8e f6 ff ff       	call   c0100378 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cea:	ff 45 f4             	incl   -0xc(%ebp)
c0100ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf0:	83 f8 02             	cmp    $0x2,%eax
c0100cf3:	76 bb                	jbe    c0100cb0 <mon_help+0xf>
    }
    return 0;
c0100cf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cfa:	89 ec                	mov    %ebp,%esp
c0100cfc:	5d                   	pop    %ebp
c0100cfd:	c3                   	ret    

c0100cfe <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cfe:	55                   	push   %ebp
c0100cff:	89 e5                	mov    %esp,%ebp
c0100d01:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d04:	e8 92 fb ff ff       	call   c010089b <print_kerninfo>
    return 0;
c0100d09:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d0e:	89 ec                	mov    %ebp,%esp
c0100d10:	5d                   	pop    %ebp
c0100d11:	c3                   	ret    

c0100d12 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d12:	55                   	push   %ebp
c0100d13:	89 e5                	mov    %esp,%ebp
c0100d15:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d18:	e8 ca fc ff ff       	call   c01009e7 <print_stackframe>
    return 0;
c0100d1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d22:	89 ec                	mov    %ebp,%esp
c0100d24:	5d                   	pop    %ebp
c0100d25:	c3                   	ret    

c0100d26 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100d26:	55                   	push   %ebp
c0100d27:	89 e5                	mov    %esp,%ebp
c0100d29:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100d2c:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
c0100d31:	85 c0                	test   %eax,%eax
c0100d33:	75 5b                	jne    c0100d90 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100d35:	c7 05 20 b4 12 c0 01 	movl   $0x1,0xc012b420
c0100d3c:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d3f:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d48:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d53:	c7 04 24 ae a3 10 c0 	movl   $0xc010a3ae,(%esp)
c0100d5a:	e8 19 f6 ff ff       	call   c0100378 <cprintf>
    vcprintf(fmt, ap);
c0100d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d66:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d69:	89 04 24             	mov    %eax,(%esp)
c0100d6c:	e8 d2 f5 ff ff       	call   c0100343 <vcprintf>
    cprintf("\n");
c0100d71:	c7 04 24 ca a3 10 c0 	movl   $0xc010a3ca,(%esp)
c0100d78:	e8 fb f5 ff ff       	call   c0100378 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d7d:	c7 04 24 cc a3 10 c0 	movl   $0xc010a3cc,(%esp)
c0100d84:	e8 ef f5 ff ff       	call   c0100378 <cprintf>
    print_stackframe();
c0100d89:	e8 59 fc ff ff       	call   c01009e7 <print_stackframe>
c0100d8e:	eb 01                	jmp    c0100d91 <__panic+0x6b>
        goto panic_dead;
c0100d90:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d91:	e8 46 12 00 00       	call   c0101fdc <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d9d:	e8 9d fe ff ff       	call   c0100c3f <kmonitor>
c0100da2:	eb f2                	jmp    c0100d96 <__panic+0x70>

c0100da4 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100da4:	55                   	push   %ebp
c0100da5:	89 e5                	mov    %esp,%ebp
c0100da7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100daa:	8d 45 14             	lea    0x14(%ebp),%eax
c0100dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100db0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100db3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100db7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dbe:	c7 04 24 de a3 10 c0 	movl   $0xc010a3de,(%esp)
c0100dc5:	e8 ae f5 ff ff       	call   c0100378 <cprintf>
    vcprintf(fmt, ap);
c0100dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dd1:	8b 45 10             	mov    0x10(%ebp),%eax
c0100dd4:	89 04 24             	mov    %eax,(%esp)
c0100dd7:	e8 67 f5 ff ff       	call   c0100343 <vcprintf>
    cprintf("\n");
c0100ddc:	c7 04 24 ca a3 10 c0 	movl   $0xc010a3ca,(%esp)
c0100de3:	e8 90 f5 ff ff       	call   c0100378 <cprintf>
    va_end(ap);
}
c0100de8:	90                   	nop
c0100de9:	89 ec                	mov    %ebp,%esp
c0100deb:	5d                   	pop    %ebp
c0100dec:	c3                   	ret    

c0100ded <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100ded:	55                   	push   %ebp
c0100dee:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100df0:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
}
c0100df5:	5d                   	pop    %ebp
c0100df6:	c3                   	ret    

c0100df7 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100df7:	55                   	push   %ebp
c0100df8:	89 e5                	mov    %esp,%ebp
c0100dfa:	83 ec 28             	sub    $0x28,%esp
c0100dfd:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100e03:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e07:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e0b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e0f:	ee                   	out    %al,(%dx)
}
c0100e10:	90                   	nop
c0100e11:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e17:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e1b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e1f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e23:	ee                   	out    %al,(%dx)
}
c0100e24:	90                   	nop
c0100e25:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e2b:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e2f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e33:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e37:	ee                   	out    %al,(%dx)
}
c0100e38:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e39:	c7 05 24 b4 12 c0 00 	movl   $0x0,0xc012b424
c0100e40:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e43:	c7 04 24 fc a3 10 c0 	movl   $0xc010a3fc,(%esp)
c0100e4a:	e8 29 f5 ff ff       	call   c0100378 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e56:	e8 e6 11 00 00       	call   c0102041 <pic_enable>
}
c0100e5b:	90                   	nop
c0100e5c:	89 ec                	mov    %ebp,%esp
c0100e5e:	5d                   	pop    %ebp
c0100e5f:	c3                   	ret    

c0100e60 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e60:	55                   	push   %ebp
c0100e61:	89 e5                	mov    %esp,%ebp
c0100e63:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e66:	9c                   	pushf  
c0100e67:	58                   	pop    %eax
c0100e68:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e6e:	25 00 02 00 00       	and    $0x200,%eax
c0100e73:	85 c0                	test   %eax,%eax
c0100e75:	74 0c                	je     c0100e83 <__intr_save+0x23>
        intr_disable();
c0100e77:	e8 60 11 00 00       	call   c0101fdc <intr_disable>
        return 1;
c0100e7c:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e81:	eb 05                	jmp    c0100e88 <__intr_save+0x28>
    }
    return 0;
c0100e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e88:	89 ec                	mov    %ebp,%esp
c0100e8a:	5d                   	pop    %ebp
c0100e8b:	c3                   	ret    

c0100e8c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e8c:	55                   	push   %ebp
c0100e8d:	89 e5                	mov    %esp,%ebp
c0100e8f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e96:	74 05                	je     c0100e9d <__intr_restore+0x11>
        intr_enable();
c0100e98:	e8 37 11 00 00       	call   c0101fd4 <intr_enable>
    }
}
c0100e9d:	90                   	nop
c0100e9e:	89 ec                	mov    %ebp,%esp
c0100ea0:	5d                   	pop    %ebp
c0100ea1:	c3                   	ret    

c0100ea2 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100ea2:	55                   	push   %ebp
c0100ea3:	89 e5                	mov    %esp,%ebp
c0100ea5:	83 ec 10             	sub    $0x10,%esp
c0100ea8:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100eae:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100eb2:	89 c2                	mov    %eax,%edx
c0100eb4:	ec                   	in     (%dx),%al
c0100eb5:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100eb8:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100ebe:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ec2:	89 c2                	mov    %eax,%edx
c0100ec4:	ec                   	in     (%dx),%al
c0100ec5:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100ec8:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100ece:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ed2:	89 c2                	mov    %eax,%edx
c0100ed4:	ec                   	in     (%dx),%al
c0100ed5:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100ed8:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ede:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ee2:	89 c2                	mov    %eax,%edx
c0100ee4:	ec                   	in     (%dx),%al
c0100ee5:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ee8:	90                   	nop
c0100ee9:	89 ec                	mov    %ebp,%esp
c0100eeb:	5d                   	pop    %ebp
c0100eec:	c3                   	ret    

c0100eed <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100eed:	55                   	push   %ebp
c0100eee:	89 e5                	mov    %esp,%ebp
c0100ef0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100ef3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100efa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100efd:	0f b7 00             	movzwl (%eax),%eax
c0100f00:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f04:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f07:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f0f:	0f b7 00             	movzwl (%eax),%eax
c0100f12:	0f b7 c0             	movzwl %ax,%eax
c0100f15:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f1a:	74 12                	je     c0100f2e <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f1c:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f23:	66 c7 05 46 b4 12 c0 	movw   $0x3b4,0xc012b446
c0100f2a:	b4 03 
c0100f2c:	eb 13                	jmp    c0100f41 <cga_init+0x54>
    } else {
        *cp = was;
c0100f2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f31:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f35:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f38:	66 c7 05 46 b4 12 c0 	movw   $0x3d4,0xc012b446
c0100f3f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f41:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f48:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f4c:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f54:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f58:	ee                   	out    %al,(%dx)
}
c0100f59:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f5a:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f61:	40                   	inc    %eax
c0100f62:	0f b7 c0             	movzwl %ax,%eax
c0100f65:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f69:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f6d:	89 c2                	mov    %eax,%edx
c0100f6f:	ec                   	in     (%dx),%al
c0100f70:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f73:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f77:	0f b6 c0             	movzbl %al,%eax
c0100f7a:	c1 e0 08             	shl    $0x8,%eax
c0100f7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f80:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100f87:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f8b:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f8f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f93:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f97:	ee                   	out    %al,(%dx)
}
c0100f98:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f99:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0100fa0:	40                   	inc    %eax
c0100fa1:	0f b7 c0             	movzwl %ax,%eax
c0100fa4:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fa8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fac:	89 c2                	mov    %eax,%edx
c0100fae:	ec                   	in     (%dx),%al
c0100faf:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fb2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fb6:	0f b6 c0             	movzbl %al,%eax
c0100fb9:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fbf:	a3 40 b4 12 c0       	mov    %eax,0xc012b440
    crt_pos = pos;
c0100fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fc7:	0f b7 c0             	movzwl %ax,%eax
c0100fca:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
}
c0100fd0:	90                   	nop
c0100fd1:	89 ec                	mov    %ebp,%esp
c0100fd3:	5d                   	pop    %ebp
c0100fd4:	c3                   	ret    

c0100fd5 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fd5:	55                   	push   %ebp
c0100fd6:	89 e5                	mov    %esp,%ebp
c0100fd8:	83 ec 48             	sub    $0x48,%esp
c0100fdb:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fe1:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe5:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100fe9:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fed:	ee                   	out    %al,(%dx)
}
c0100fee:	90                   	nop
c0100fef:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100ff5:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff9:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100ffd:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101001:	ee                   	out    %al,(%dx)
}
c0101002:	90                   	nop
c0101003:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0101009:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010100d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101011:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101015:	ee                   	out    %al,(%dx)
}
c0101016:	90                   	nop
c0101017:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010101d:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101021:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101025:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101029:	ee                   	out    %al,(%dx)
}
c010102a:	90                   	nop
c010102b:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101031:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101035:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101039:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010103d:	ee                   	out    %al,(%dx)
}
c010103e:	90                   	nop
c010103f:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101045:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101049:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010104d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101051:	ee                   	out    %al,(%dx)
}
c0101052:	90                   	nop
c0101053:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101059:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010105d:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101061:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101065:	ee                   	out    %al,(%dx)
}
c0101066:	90                   	nop
c0101067:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010106d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101071:	89 c2                	mov    %eax,%edx
c0101073:	ec                   	in     (%dx),%al
c0101074:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101077:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010107b:	3c ff                	cmp    $0xff,%al
c010107d:	0f 95 c0             	setne  %al
c0101080:	0f b6 c0             	movzbl %al,%eax
c0101083:	a3 48 b4 12 c0       	mov    %eax,0xc012b448
c0101088:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010108e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101092:	89 c2                	mov    %eax,%edx
c0101094:	ec                   	in     (%dx),%al
c0101095:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101098:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010109e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a2:	89 c2                	mov    %eax,%edx
c01010a4:	ec                   	in     (%dx),%al
c01010a5:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01010a8:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01010ad:	85 c0                	test   %eax,%eax
c01010af:	74 0c                	je     c01010bd <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c01010b1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010b8:	e8 84 0f 00 00       	call   c0102041 <pic_enable>
    }
}
c01010bd:	90                   	nop
c01010be:	89 ec                	mov    %ebp,%esp
c01010c0:	5d                   	pop    %ebp
c01010c1:	c3                   	ret    

c01010c2 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010c2:	55                   	push   %ebp
c01010c3:	89 e5                	mov    %esp,%ebp
c01010c5:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010c8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010cf:	eb 08                	jmp    c01010d9 <lpt_putc_sub+0x17>
        delay();
c01010d1:	e8 cc fd ff ff       	call   c0100ea2 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010d6:	ff 45 fc             	incl   -0x4(%ebp)
c01010d9:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010df:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010e3:	89 c2                	mov    %eax,%edx
c01010e5:	ec                   	in     (%dx),%al
c01010e6:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010e9:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010ed:	84 c0                	test   %al,%al
c01010ef:	78 09                	js     c01010fa <lpt_putc_sub+0x38>
c01010f1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010f8:	7e d7                	jle    c01010d1 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01010fd:	0f b6 c0             	movzbl %al,%eax
c0101100:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101106:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101109:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010110d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101111:	ee                   	out    %al,(%dx)
}
c0101112:	90                   	nop
c0101113:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101119:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010111d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101121:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101125:	ee                   	out    %al,(%dx)
}
c0101126:	90                   	nop
c0101127:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010112d:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101131:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101135:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101139:	ee                   	out    %al,(%dx)
}
c010113a:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010113b:	90                   	nop
c010113c:	89 ec                	mov    %ebp,%esp
c010113e:	5d                   	pop    %ebp
c010113f:	c3                   	ret    

c0101140 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101140:	55                   	push   %ebp
c0101141:	89 e5                	mov    %esp,%ebp
c0101143:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101146:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010114a:	74 0d                	je     c0101159 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010114c:	8b 45 08             	mov    0x8(%ebp),%eax
c010114f:	89 04 24             	mov    %eax,(%esp)
c0101152:	e8 6b ff ff ff       	call   c01010c2 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101157:	eb 24                	jmp    c010117d <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c0101159:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101160:	e8 5d ff ff ff       	call   c01010c2 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101165:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010116c:	e8 51 ff ff ff       	call   c01010c2 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101171:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101178:	e8 45 ff ff ff       	call   c01010c2 <lpt_putc_sub>
}
c010117d:	90                   	nop
c010117e:	89 ec                	mov    %ebp,%esp
c0101180:	5d                   	pop    %ebp
c0101181:	c3                   	ret    

c0101182 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101182:	55                   	push   %ebp
c0101183:	89 e5                	mov    %esp,%ebp
c0101185:	83 ec 38             	sub    $0x38,%esp
c0101188:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c010118b:	8b 45 08             	mov    0x8(%ebp),%eax
c010118e:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101193:	85 c0                	test   %eax,%eax
c0101195:	75 07                	jne    c010119e <cga_putc+0x1c>
        c |= 0x0700;
c0101197:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010119e:	8b 45 08             	mov    0x8(%ebp),%eax
c01011a1:	0f b6 c0             	movzbl %al,%eax
c01011a4:	83 f8 0d             	cmp    $0xd,%eax
c01011a7:	74 72                	je     c010121b <cga_putc+0x99>
c01011a9:	83 f8 0d             	cmp    $0xd,%eax
c01011ac:	0f 8f a3 00 00 00    	jg     c0101255 <cga_putc+0xd3>
c01011b2:	83 f8 08             	cmp    $0x8,%eax
c01011b5:	74 0a                	je     c01011c1 <cga_putc+0x3f>
c01011b7:	83 f8 0a             	cmp    $0xa,%eax
c01011ba:	74 4c                	je     c0101208 <cga_putc+0x86>
c01011bc:	e9 94 00 00 00       	jmp    c0101255 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c01011c1:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01011c8:	85 c0                	test   %eax,%eax
c01011ca:	0f 84 af 00 00 00    	je     c010127f <cga_putc+0xfd>
            crt_pos --;
c01011d0:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01011d7:	48                   	dec    %eax
c01011d8:	0f b7 c0             	movzwl %ax,%eax
c01011db:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e4:	98                   	cwtl   
c01011e5:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011ea:	98                   	cwtl   
c01011eb:	83 c8 20             	or     $0x20,%eax
c01011ee:	98                   	cwtl   
c01011ef:	8b 0d 40 b4 12 c0    	mov    0xc012b440,%ecx
c01011f5:	0f b7 15 44 b4 12 c0 	movzwl 0xc012b444,%edx
c01011fc:	01 d2                	add    %edx,%edx
c01011fe:	01 ca                	add    %ecx,%edx
c0101200:	0f b7 c0             	movzwl %ax,%eax
c0101203:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101206:	eb 77                	jmp    c010127f <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c0101208:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c010120f:	83 c0 50             	add    $0x50,%eax
c0101212:	0f b7 c0             	movzwl %ax,%eax
c0101215:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010121b:	0f b7 1d 44 b4 12 c0 	movzwl 0xc012b444,%ebx
c0101222:	0f b7 0d 44 b4 12 c0 	movzwl 0xc012b444,%ecx
c0101229:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c010122e:	89 c8                	mov    %ecx,%eax
c0101230:	f7 e2                	mul    %edx
c0101232:	c1 ea 06             	shr    $0x6,%edx
c0101235:	89 d0                	mov    %edx,%eax
c0101237:	c1 e0 02             	shl    $0x2,%eax
c010123a:	01 d0                	add    %edx,%eax
c010123c:	c1 e0 04             	shl    $0x4,%eax
c010123f:	29 c1                	sub    %eax,%ecx
c0101241:	89 ca                	mov    %ecx,%edx
c0101243:	0f b7 d2             	movzwl %dx,%edx
c0101246:	89 d8                	mov    %ebx,%eax
c0101248:	29 d0                	sub    %edx,%eax
c010124a:	0f b7 c0             	movzwl %ax,%eax
c010124d:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
        break;
c0101253:	eb 2b                	jmp    c0101280 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101255:	8b 0d 40 b4 12 c0    	mov    0xc012b440,%ecx
c010125b:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0101262:	8d 50 01             	lea    0x1(%eax),%edx
c0101265:	0f b7 d2             	movzwl %dx,%edx
c0101268:	66 89 15 44 b4 12 c0 	mov    %dx,0xc012b444
c010126f:	01 c0                	add    %eax,%eax
c0101271:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101274:	8b 45 08             	mov    0x8(%ebp),%eax
c0101277:	0f b7 c0             	movzwl %ax,%eax
c010127a:	66 89 02             	mov    %ax,(%edx)
        break;
c010127d:	eb 01                	jmp    c0101280 <cga_putc+0xfe>
        break;
c010127f:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101280:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0101287:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c010128c:	76 5e                	jbe    c01012ec <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010128e:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c0101293:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101299:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c010129e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01012a5:	00 
c01012a6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01012aa:	89 04 24             	mov    %eax,(%esp)
c01012ad:	e8 c9 8c 00 00       	call   c0109f7b <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012b2:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012b9:	eb 15                	jmp    c01012d0 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c01012bb:	8b 15 40 b4 12 c0    	mov    0xc012b440,%edx
c01012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012c4:	01 c0                	add    %eax,%eax
c01012c6:	01 d0                	add    %edx,%eax
c01012c8:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012cd:	ff 45 f4             	incl   -0xc(%ebp)
c01012d0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012d7:	7e e2                	jle    c01012bb <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c01012d9:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01012e0:	83 e8 50             	sub    $0x50,%eax
c01012e3:	0f b7 c0             	movzwl %ax,%eax
c01012e6:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012ec:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c01012f3:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012f7:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012fb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012ff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101303:	ee                   	out    %al,(%dx)
}
c0101304:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101305:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c010130c:	c1 e8 08             	shr    $0x8,%eax
c010130f:	0f b7 c0             	movzwl %ax,%eax
c0101312:	0f b6 c0             	movzbl %al,%eax
c0101315:	0f b7 15 46 b4 12 c0 	movzwl 0xc012b446,%edx
c010131c:	42                   	inc    %edx
c010131d:	0f b7 d2             	movzwl %dx,%edx
c0101320:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101324:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101327:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010132b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010132f:	ee                   	out    %al,(%dx)
}
c0101330:	90                   	nop
    outb(addr_6845, 15);
c0101331:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0101338:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010133c:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101340:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101344:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101348:	ee                   	out    %al,(%dx)
}
c0101349:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010134a:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0101351:	0f b6 c0             	movzbl %al,%eax
c0101354:	0f b7 15 46 b4 12 c0 	movzwl 0xc012b446,%edx
c010135b:	42                   	inc    %edx
c010135c:	0f b7 d2             	movzwl %dx,%edx
c010135f:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101363:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101366:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010136a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010136e:	ee                   	out    %al,(%dx)
}
c010136f:	90                   	nop
}
c0101370:	90                   	nop
c0101371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101374:	89 ec                	mov    %ebp,%esp
c0101376:	5d                   	pop    %ebp
c0101377:	c3                   	ret    

c0101378 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101378:	55                   	push   %ebp
c0101379:	89 e5                	mov    %esp,%ebp
c010137b:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010137e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101385:	eb 08                	jmp    c010138f <serial_putc_sub+0x17>
        delay();
c0101387:	e8 16 fb ff ff       	call   c0100ea2 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010138c:	ff 45 fc             	incl   -0x4(%ebp)
c010138f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101395:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101399:	89 c2                	mov    %eax,%edx
c010139b:	ec                   	in     (%dx),%al
c010139c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010139f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013a3:	0f b6 c0             	movzbl %al,%eax
c01013a6:	83 e0 20             	and    $0x20,%eax
c01013a9:	85 c0                	test   %eax,%eax
c01013ab:	75 09                	jne    c01013b6 <serial_putc_sub+0x3e>
c01013ad:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013b4:	7e d1                	jle    c0101387 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c01013b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b9:	0f b6 c0             	movzbl %al,%eax
c01013bc:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013c2:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013c5:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013c9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013cd:	ee                   	out    %al,(%dx)
}
c01013ce:	90                   	nop
}
c01013cf:	90                   	nop
c01013d0:	89 ec                	mov    %ebp,%esp
c01013d2:	5d                   	pop    %ebp
c01013d3:	c3                   	ret    

c01013d4 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013d4:	55                   	push   %ebp
c01013d5:	89 e5                	mov    %esp,%ebp
c01013d7:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013da:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013de:	74 0d                	je     c01013ed <serial_putc+0x19>
        serial_putc_sub(c);
c01013e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01013e3:	89 04 24             	mov    %eax,(%esp)
c01013e6:	e8 8d ff ff ff       	call   c0101378 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013eb:	eb 24                	jmp    c0101411 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013ed:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013f4:	e8 7f ff ff ff       	call   c0101378 <serial_putc_sub>
        serial_putc_sub(' ');
c01013f9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101400:	e8 73 ff ff ff       	call   c0101378 <serial_putc_sub>
        serial_putc_sub('\b');
c0101405:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010140c:	e8 67 ff ff ff       	call   c0101378 <serial_putc_sub>
}
c0101411:	90                   	nop
c0101412:	89 ec                	mov    %ebp,%esp
c0101414:	5d                   	pop    %ebp
c0101415:	c3                   	ret    

c0101416 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010141c:	eb 33                	jmp    c0101451 <cons_intr+0x3b>
        if (c != 0) {
c010141e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101422:	74 2d                	je     c0101451 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101424:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0101429:	8d 50 01             	lea    0x1(%eax),%edx
c010142c:	89 15 64 b6 12 c0    	mov    %edx,0xc012b664
c0101432:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101435:	88 90 60 b4 12 c0    	mov    %dl,-0x3fed4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c010143b:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0101440:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101445:	75 0a                	jne    c0101451 <cons_intr+0x3b>
                cons.wpos = 0;
c0101447:	c7 05 64 b6 12 c0 00 	movl   $0x0,0xc012b664
c010144e:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101451:	8b 45 08             	mov    0x8(%ebp),%eax
c0101454:	ff d0                	call   *%eax
c0101456:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101459:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c010145d:	75 bf                	jne    c010141e <cons_intr+0x8>
            }
        }
    }
}
c010145f:	90                   	nop
c0101460:	90                   	nop
c0101461:	89 ec                	mov    %ebp,%esp
c0101463:	5d                   	pop    %ebp
c0101464:	c3                   	ret    

c0101465 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101465:	55                   	push   %ebp
c0101466:	89 e5                	mov    %esp,%ebp
c0101468:	83 ec 10             	sub    $0x10,%esp
c010146b:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101471:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101475:	89 c2                	mov    %eax,%edx
c0101477:	ec                   	in     (%dx),%al
c0101478:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010147b:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010147f:	0f b6 c0             	movzbl %al,%eax
c0101482:	83 e0 01             	and    $0x1,%eax
c0101485:	85 c0                	test   %eax,%eax
c0101487:	75 07                	jne    c0101490 <serial_proc_data+0x2b>
        return -1;
c0101489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010148e:	eb 2a                	jmp    c01014ba <serial_proc_data+0x55>
c0101490:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101496:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010149a:	89 c2                	mov    %eax,%edx
c010149c:	ec                   	in     (%dx),%al
c010149d:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014a0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014a4:	0f b6 c0             	movzbl %al,%eax
c01014a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014aa:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014ae:	75 07                	jne    c01014b7 <serial_proc_data+0x52>
        c = '\b';
c01014b0:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014ba:	89 ec                	mov    %ebp,%esp
c01014bc:	5d                   	pop    %ebp
c01014bd:	c3                   	ret    

c01014be <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014be:	55                   	push   %ebp
c01014bf:	89 e5                	mov    %esp,%ebp
c01014c1:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014c4:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01014c9:	85 c0                	test   %eax,%eax
c01014cb:	74 0c                	je     c01014d9 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01014cd:	c7 04 24 65 14 10 c0 	movl   $0xc0101465,(%esp)
c01014d4:	e8 3d ff ff ff       	call   c0101416 <cons_intr>
    }
}
c01014d9:	90                   	nop
c01014da:	89 ec                	mov    %ebp,%esp
c01014dc:	5d                   	pop    %ebp
c01014dd:	c3                   	ret    

c01014de <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014de:	55                   	push   %ebp
c01014df:	89 e5                	mov    %esp,%ebp
c01014e1:	83 ec 38             	sub    $0x38,%esp
c01014e4:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014ed:	89 c2                	mov    %eax,%edx
c01014ef:	ec                   	in     (%dx),%al
c01014f0:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014f3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014f7:	0f b6 c0             	movzbl %al,%eax
c01014fa:	83 e0 01             	and    $0x1,%eax
c01014fd:	85 c0                	test   %eax,%eax
c01014ff:	75 0a                	jne    c010150b <kbd_proc_data+0x2d>
        return -1;
c0101501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101506:	e9 56 01 00 00       	jmp    c0101661 <kbd_proc_data+0x183>
c010150b:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101511:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101514:	89 c2                	mov    %eax,%edx
c0101516:	ec                   	in     (%dx),%al
c0101517:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010151a:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010151e:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101521:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101525:	75 17                	jne    c010153e <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101527:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010152c:	83 c8 40             	or     $0x40,%eax
c010152f:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
        return 0;
c0101534:	b8 00 00 00 00       	mov    $0x0,%eax
c0101539:	e9 23 01 00 00       	jmp    c0101661 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c010153e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101542:	84 c0                	test   %al,%al
c0101544:	79 45                	jns    c010158b <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101546:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010154b:	83 e0 40             	and    $0x40,%eax
c010154e:	85 c0                	test   %eax,%eax
c0101550:	75 08                	jne    c010155a <kbd_proc_data+0x7c>
c0101552:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101556:	24 7f                	and    $0x7f,%al
c0101558:	eb 04                	jmp    c010155e <kbd_proc_data+0x80>
c010155a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010155e:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101561:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101565:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c010156c:	0c 40                	or     $0x40,%al
c010156e:	0f b6 c0             	movzbl %al,%eax
c0101571:	f7 d0                	not    %eax
c0101573:	89 c2                	mov    %eax,%edx
c0101575:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010157a:	21 d0                	and    %edx,%eax
c010157c:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
        return 0;
c0101581:	b8 00 00 00 00       	mov    $0x0,%eax
c0101586:	e9 d6 00 00 00       	jmp    c0101661 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c010158b:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c0101590:	83 e0 40             	and    $0x40,%eax
c0101593:	85 c0                	test   %eax,%eax
c0101595:	74 11                	je     c01015a8 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101597:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010159b:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015a0:	83 e0 bf             	and    $0xffffffbf,%eax
c01015a3:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
    }

    shift |= shiftcode[data];
c01015a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015ac:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c01015b3:	0f b6 d0             	movzbl %al,%edx
c01015b6:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015bb:	09 d0                	or     %edx,%eax
c01015bd:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
    shift ^= togglecode[data];
c01015c2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015c6:	0f b6 80 40 81 12 c0 	movzbl -0x3fed7ec0(%eax),%eax
c01015cd:	0f b6 d0             	movzbl %al,%edx
c01015d0:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015d5:	31 d0                	xor    %edx,%eax
c01015d7:	a3 68 b6 12 c0       	mov    %eax,0xc012b668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015dc:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015e1:	83 e0 03             	and    $0x3,%eax
c01015e4:	8b 14 85 40 85 12 c0 	mov    -0x3fed7ac0(,%eax,4),%edx
c01015eb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015ef:	01 d0                	add    %edx,%eax
c01015f1:	0f b6 00             	movzbl (%eax),%eax
c01015f4:	0f b6 c0             	movzbl %al,%eax
c01015f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015fa:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01015ff:	83 e0 08             	and    $0x8,%eax
c0101602:	85 c0                	test   %eax,%eax
c0101604:	74 22                	je     c0101628 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101606:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010160a:	7e 0c                	jle    c0101618 <kbd_proc_data+0x13a>
c010160c:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101610:	7f 06                	jg     c0101618 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101612:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101616:	eb 10                	jmp    c0101628 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101618:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010161c:	7e 0a                	jle    c0101628 <kbd_proc_data+0x14a>
c010161e:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101622:	7f 04                	jg     c0101628 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101624:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101628:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010162d:	f7 d0                	not    %eax
c010162f:	83 e0 06             	and    $0x6,%eax
c0101632:	85 c0                	test   %eax,%eax
c0101634:	75 28                	jne    c010165e <kbd_proc_data+0x180>
c0101636:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c010163d:	75 1f                	jne    c010165e <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c010163f:	c7 04 24 17 a4 10 c0 	movl   $0xc010a417,(%esp)
c0101646:	e8 2d ed ff ff       	call   c0100378 <cprintf>
c010164b:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101651:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101655:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101659:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010165c:	ee                   	out    %al,(%dx)
}
c010165d:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101661:	89 ec                	mov    %ebp,%esp
c0101663:	5d                   	pop    %ebp
c0101664:	c3                   	ret    

c0101665 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101665:	55                   	push   %ebp
c0101666:	89 e5                	mov    %esp,%ebp
c0101668:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c010166b:	c7 04 24 de 14 10 c0 	movl   $0xc01014de,(%esp)
c0101672:	e8 9f fd ff ff       	call   c0101416 <cons_intr>
}
c0101677:	90                   	nop
c0101678:	89 ec                	mov    %ebp,%esp
c010167a:	5d                   	pop    %ebp
c010167b:	c3                   	ret    

c010167c <kbd_init>:

static void
kbd_init(void) {
c010167c:	55                   	push   %ebp
c010167d:	89 e5                	mov    %esp,%ebp
c010167f:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101682:	e8 de ff ff ff       	call   c0101665 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101687:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010168e:	e8 ae 09 00 00       	call   c0102041 <pic_enable>
}
c0101693:	90                   	nop
c0101694:	89 ec                	mov    %ebp,%esp
c0101696:	5d                   	pop    %ebp
c0101697:	c3                   	ret    

c0101698 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101698:	55                   	push   %ebp
c0101699:	89 e5                	mov    %esp,%ebp
c010169b:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c010169e:	e8 4a f8 ff ff       	call   c0100eed <cga_init>
    serial_init();
c01016a3:	e8 2d f9 ff ff       	call   c0100fd5 <serial_init>
    kbd_init();
c01016a8:	e8 cf ff ff ff       	call   c010167c <kbd_init>
    if (!serial_exists) {
c01016ad:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01016b2:	85 c0                	test   %eax,%eax
c01016b4:	75 0c                	jne    c01016c2 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01016b6:	c7 04 24 23 a4 10 c0 	movl   $0xc010a423,(%esp)
c01016bd:	e8 b6 ec ff ff       	call   c0100378 <cprintf>
    }
}
c01016c2:	90                   	nop
c01016c3:	89 ec                	mov    %ebp,%esp
c01016c5:	5d                   	pop    %ebp
c01016c6:	c3                   	ret    

c01016c7 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016c7:	55                   	push   %ebp
c01016c8:	89 e5                	mov    %esp,%ebp
c01016ca:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016cd:	e8 8e f7 ff ff       	call   c0100e60 <__intr_save>
c01016d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d8:	89 04 24             	mov    %eax,(%esp)
c01016db:	e8 60 fa ff ff       	call   c0101140 <lpt_putc>
        cga_putc(c);
c01016e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01016e3:	89 04 24             	mov    %eax,(%esp)
c01016e6:	e8 97 fa ff ff       	call   c0101182 <cga_putc>
        serial_putc(c);
c01016eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01016ee:	89 04 24             	mov    %eax,(%esp)
c01016f1:	e8 de fc ff ff       	call   c01013d4 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016f9:	89 04 24             	mov    %eax,(%esp)
c01016fc:	e8 8b f7 ff ff       	call   c0100e8c <__intr_restore>
}
c0101701:	90                   	nop
c0101702:	89 ec                	mov    %ebp,%esp
c0101704:	5d                   	pop    %ebp
c0101705:	c3                   	ret    

c0101706 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101706:	55                   	push   %ebp
c0101707:	89 e5                	mov    %esp,%ebp
c0101709:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010170c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101713:	e8 48 f7 ff ff       	call   c0100e60 <__intr_save>
c0101718:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010171b:	e8 9e fd ff ff       	call   c01014be <serial_intr>
        kbd_intr();
c0101720:	e8 40 ff ff ff       	call   c0101665 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101725:	8b 15 60 b6 12 c0    	mov    0xc012b660,%edx
c010172b:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0101730:	39 c2                	cmp    %eax,%edx
c0101732:	74 31                	je     c0101765 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101734:	a1 60 b6 12 c0       	mov    0xc012b660,%eax
c0101739:	8d 50 01             	lea    0x1(%eax),%edx
c010173c:	89 15 60 b6 12 c0    	mov    %edx,0xc012b660
c0101742:	0f b6 80 60 b4 12 c0 	movzbl -0x3fed4ba0(%eax),%eax
c0101749:	0f b6 c0             	movzbl %al,%eax
c010174c:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010174f:	a1 60 b6 12 c0       	mov    0xc012b660,%eax
c0101754:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101759:	75 0a                	jne    c0101765 <cons_getc+0x5f>
                cons.rpos = 0;
c010175b:	c7 05 60 b6 12 c0 00 	movl   $0x0,0xc012b660
c0101762:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101765:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101768:	89 04 24             	mov    %eax,(%esp)
c010176b:	e8 1c f7 ff ff       	call   c0100e8c <__intr_restore>
    return c;
c0101770:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101773:	89 ec                	mov    %ebp,%esp
c0101775:	5d                   	pop    %ebp
c0101776:	c3                   	ret    

c0101777 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0101777:	55                   	push   %ebp
c0101778:	89 e5                	mov    %esp,%ebp
c010177a:	83 ec 14             	sub    $0x14,%esp
c010177d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101780:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101784:	90                   	nop
c0101785:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101788:	83 c0 07             	add    $0x7,%eax
c010178b:	0f b7 c0             	movzwl %ax,%eax
c010178e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101792:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101796:	89 c2                	mov    %eax,%edx
c0101798:	ec                   	in     (%dx),%al
c0101799:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010179c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017a0:	0f b6 c0             	movzbl %al,%eax
c01017a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01017a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017a9:	25 80 00 00 00       	and    $0x80,%eax
c01017ae:	85 c0                	test   %eax,%eax
c01017b0:	75 d3                	jne    c0101785 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c01017b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01017b6:	74 11                	je     c01017c9 <ide_wait_ready+0x52>
c01017b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017bb:	83 e0 21             	and    $0x21,%eax
c01017be:	85 c0                	test   %eax,%eax
c01017c0:	74 07                	je     c01017c9 <ide_wait_ready+0x52>
        return -1;
c01017c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01017c7:	eb 05                	jmp    c01017ce <ide_wait_ready+0x57>
    }
    return 0;
c01017c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01017ce:	89 ec                	mov    %ebp,%esp
c01017d0:	5d                   	pop    %ebp
c01017d1:	c3                   	ret    

c01017d2 <ide_init>:

void
ide_init(void) {
c01017d2:	55                   	push   %ebp
c01017d3:	89 e5                	mov    %esp,%ebp
c01017d5:	57                   	push   %edi
c01017d6:	53                   	push   %ebx
c01017d7:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01017dd:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c01017e3:	e9 bd 02 00 00       	jmp    c0101aa5 <ide_init+0x2d3>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c01017e8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017ec:	89 d0                	mov    %edx,%eax
c01017ee:	c1 e0 03             	shl    $0x3,%eax
c01017f1:	29 d0                	sub    %edx,%eax
c01017f3:	c1 e0 03             	shl    $0x3,%eax
c01017f6:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c01017fb:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c01017fe:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101802:	d1 e8                	shr    %eax
c0101804:	0f b7 c0             	movzwl %ax,%eax
c0101807:	8b 04 85 44 a4 10 c0 	mov    -0x3fef5bbc(,%eax,4),%eax
c010180e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101812:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101816:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010181d:	00 
c010181e:	89 04 24             	mov    %eax,(%esp)
c0101821:	e8 51 ff ff ff       	call   c0101777 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101826:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010182a:	c1 e0 04             	shl    $0x4,%eax
c010182d:	24 10                	and    $0x10,%al
c010182f:	0c e0                	or     $0xe0,%al
c0101831:	0f b6 c0             	movzbl %al,%eax
c0101834:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101838:	83 c2 06             	add    $0x6,%edx
c010183b:	0f b7 d2             	movzwl %dx,%edx
c010183e:	66 89 55 ca          	mov    %dx,-0x36(%ebp)
c0101842:	88 45 c9             	mov    %al,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101845:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101849:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010184d:	ee                   	out    %al,(%dx)
}
c010184e:	90                   	nop
        ide_wait_ready(iobase, 0);
c010184f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101853:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010185a:	00 
c010185b:	89 04 24             	mov    %eax,(%esp)
c010185e:	e8 14 ff ff ff       	call   c0101777 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0101863:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101867:	83 c0 07             	add    $0x7,%eax
c010186a:	0f b7 c0             	movzwl %ax,%eax
c010186d:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0101871:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101875:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101879:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010187d:	ee                   	out    %al,(%dx)
}
c010187e:	90                   	nop
        ide_wait_ready(iobase, 0);
c010187f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101883:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010188a:	00 
c010188b:	89 04 24             	mov    %eax,(%esp)
c010188e:	e8 e4 fe ff ff       	call   c0101777 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101893:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101897:	83 c0 07             	add    $0x7,%eax
c010189a:	0f b7 c0             	movzwl %ax,%eax
c010189d:	66 89 45 d2          	mov    %ax,-0x2e(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018a1:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01018a5:	89 c2                	mov    %eax,%edx
c01018a7:	ec                   	in     (%dx),%al
c01018a8:	88 45 d1             	mov    %al,-0x2f(%ebp)
    return data;
c01018ab:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018af:	84 c0                	test   %al,%al
c01018b1:	0f 84 e4 01 00 00    	je     c0101a9b <ide_init+0x2c9>
c01018b7:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01018c2:	00 
c01018c3:	89 04 24             	mov    %eax,(%esp)
c01018c6:	e8 ac fe ff ff       	call   c0101777 <ide_wait_ready>
c01018cb:	85 c0                	test   %eax,%eax
c01018cd:	0f 85 c8 01 00 00    	jne    c0101a9b <ide_init+0x2c9>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c01018d3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018d7:	89 d0                	mov    %edx,%eax
c01018d9:	c1 e0 03             	shl    $0x3,%eax
c01018dc:	29 d0                	sub    %edx,%eax
c01018de:	c1 e0 03             	shl    $0x3,%eax
c01018e1:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c01018e6:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c01018e9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018ed:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01018f0:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01018f6:	89 45 c0             	mov    %eax,-0x40(%ebp)
c01018f9:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
    asm volatile (
c0101900:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101903:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101906:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101909:	89 cb                	mov    %ecx,%ebx
c010190b:	89 df                	mov    %ebx,%edi
c010190d:	89 c1                	mov    %eax,%ecx
c010190f:	fc                   	cld    
c0101910:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101912:	89 c8                	mov    %ecx,%eax
c0101914:	89 fb                	mov    %edi,%ebx
c0101916:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101919:	89 45 bc             	mov    %eax,-0x44(%ebp)
}
c010191c:	90                   	nop

        unsigned char *ident = (unsigned char *)buffer;
c010191d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101923:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101929:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010192f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101932:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101935:	25 00 00 00 04       	and    $0x4000000,%eax
c010193a:	85 c0                	test   %eax,%eax
c010193c:	74 0e                	je     c010194c <ide_init+0x17a>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010193e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101941:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101947:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010194a:	eb 09                	jmp    c0101955 <ide_init+0x183>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c010194c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010194f:	8b 40 78             	mov    0x78(%eax),%eax
c0101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101955:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101959:	89 d0                	mov    %edx,%eax
c010195b:	c1 e0 03             	shl    $0x3,%eax
c010195e:	29 d0                	sub    %edx,%eax
c0101960:	c1 e0 03             	shl    $0x3,%eax
c0101963:	8d 90 84 b6 12 c0    	lea    -0x3fed497c(%eax),%edx
c0101969:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010196c:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c010196e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101972:	89 d0                	mov    %edx,%eax
c0101974:	c1 e0 03             	shl    $0x3,%eax
c0101977:	29 d0                	sub    %edx,%eax
c0101979:	c1 e0 03             	shl    $0x3,%eax
c010197c:	8d 90 88 b6 12 c0    	lea    -0x3fed4978(%eax),%edx
c0101982:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101985:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010198a:	83 c0 62             	add    $0x62,%eax
c010198d:	0f b7 00             	movzwl (%eax),%eax
c0101990:	25 00 02 00 00       	and    $0x200,%eax
c0101995:	85 c0                	test   %eax,%eax
c0101997:	75 24                	jne    c01019bd <ide_init+0x1eb>
c0101999:	c7 44 24 0c 4c a4 10 	movl   $0xc010a44c,0xc(%esp)
c01019a0:	c0 
c01019a1:	c7 44 24 08 8f a4 10 	movl   $0xc010a48f,0x8(%esp)
c01019a8:	c0 
c01019a9:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01019b0:	00 
c01019b1:	c7 04 24 a4 a4 10 c0 	movl   $0xc010a4a4,(%esp)
c01019b8:	e8 69 f3 ff ff       	call   c0100d26 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01019bd:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01019c1:	89 d0                	mov    %edx,%eax
c01019c3:	c1 e0 03             	shl    $0x3,%eax
c01019c6:	29 d0                	sub    %edx,%eax
c01019c8:	c1 e0 03             	shl    $0x3,%eax
c01019cb:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c01019d0:	83 c0 0c             	add    $0xc,%eax
c01019d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01019d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019d9:	83 c0 36             	add    $0x36,%eax
c01019dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c01019df:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c01019e6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01019ed:	eb 34                	jmp    c0101a23 <ide_init+0x251>
            model[i] = data[i + 1], model[i + 1] = data[i];
c01019ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019f2:	8d 50 01             	lea    0x1(%eax),%edx
c01019f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01019f8:	01 c2                	add    %eax,%edx
c01019fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01019fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a00:	01 c8                	add    %ecx,%eax
c0101a02:	0f b6 12             	movzbl (%edx),%edx
c0101a05:	88 10                	mov    %dl,(%eax)
c0101a07:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0101a0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a0d:	01 c2                	add    %eax,%edx
c0101a0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a12:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a15:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a18:	01 c8                	add    %ecx,%eax
c0101a1a:	0f b6 12             	movzbl (%edx),%edx
c0101a1d:	88 10                	mov    %dl,(%eax)
        for (i = 0; i < length; i += 2) {
c0101a1f:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a26:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101a29:	72 c4                	jb     c01019ef <ide_init+0x21d>
        }
        do {
            model[i] = '\0';
c0101a2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a31:	01 d0                	add    %edx,%eax
c0101a33:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101a36:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a39:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101a3c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101a3f:	85 c0                	test   %eax,%eax
c0101a41:	74 0f                	je     c0101a52 <ide_init+0x280>
c0101a43:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a46:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a49:	01 d0                	add    %edx,%eax
c0101a4b:	0f b6 00             	movzbl (%eax),%eax
c0101a4e:	3c 20                	cmp    $0x20,%al
c0101a50:	74 d9                	je     c0101a2b <ide_init+0x259>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101a52:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a56:	89 d0                	mov    %edx,%eax
c0101a58:	c1 e0 03             	shl    $0x3,%eax
c0101a5b:	29 d0                	sub    %edx,%eax
c0101a5d:	c1 e0 03             	shl    $0x3,%eax
c0101a60:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101a65:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101a68:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a6c:	89 d0                	mov    %edx,%eax
c0101a6e:	c1 e0 03             	shl    $0x3,%eax
c0101a71:	29 d0                	sub    %edx,%eax
c0101a73:	c1 e0 03             	shl    $0x3,%eax
c0101a76:	05 88 b6 12 c0       	add    $0xc012b688,%eax
c0101a7b:	8b 10                	mov    (%eax),%edx
c0101a7d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a81:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101a85:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a8d:	c7 04 24 b6 a4 10 c0 	movl   $0xc010a4b6,(%esp)
c0101a94:	e8 df e8 ff ff       	call   c0100378 <cprintf>
c0101a99:	eb 01                	jmp    c0101a9c <ide_init+0x2ca>
            continue ;
c0101a9b:	90                   	nop
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a9c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aa0:	40                   	inc    %eax
c0101aa1:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101aa5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101aa9:	83 f8 03             	cmp    $0x3,%eax
c0101aac:	0f 86 36 fd ff ff    	jbe    c01017e8 <ide_init+0x16>
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101ab2:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101ab9:	e8 83 05 00 00       	call   c0102041 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101abe:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101ac5:	e8 77 05 00 00       	call   c0102041 <pic_enable>
}
c0101aca:	90                   	nop
c0101acb:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101ad1:	5b                   	pop    %ebx
c0101ad2:	5f                   	pop    %edi
c0101ad3:	5d                   	pop    %ebp
c0101ad4:	c3                   	ret    

c0101ad5 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101ad5:	55                   	push   %ebp
c0101ad6:	89 e5                	mov    %esp,%ebp
c0101ad8:	83 ec 04             	sub    $0x4,%esp
c0101adb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ade:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101ae2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101ae6:	83 f8 03             	cmp    $0x3,%eax
c0101ae9:	77 21                	ja     c0101b0c <ide_device_valid+0x37>
c0101aeb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101aef:	89 d0                	mov    %edx,%eax
c0101af1:	c1 e0 03             	shl    $0x3,%eax
c0101af4:	29 d0                	sub    %edx,%eax
c0101af6:	c1 e0 03             	shl    $0x3,%eax
c0101af9:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101afe:	0f b6 00             	movzbl (%eax),%eax
c0101b01:	84 c0                	test   %al,%al
c0101b03:	74 07                	je     c0101b0c <ide_device_valid+0x37>
c0101b05:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b0a:	eb 05                	jmp    c0101b11 <ide_device_valid+0x3c>
c0101b0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b11:	89 ec                	mov    %ebp,%esp
c0101b13:	5d                   	pop    %ebp
c0101b14:	c3                   	ret    

c0101b15 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101b15:	55                   	push   %ebp
c0101b16:	89 e5                	mov    %esp,%ebp
c0101b18:	83 ec 08             	sub    $0x8,%esp
c0101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b1e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101b22:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b26:	89 04 24             	mov    %eax,(%esp)
c0101b29:	e8 a7 ff ff ff       	call   c0101ad5 <ide_device_valid>
c0101b2e:	85 c0                	test   %eax,%eax
c0101b30:	74 17                	je     c0101b49 <ide_device_size+0x34>
        return ide_devices[ideno].size;
c0101b32:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101b36:	89 d0                	mov    %edx,%eax
c0101b38:	c1 e0 03             	shl    $0x3,%eax
c0101b3b:	29 d0                	sub    %edx,%eax
c0101b3d:	c1 e0 03             	shl    $0x3,%eax
c0101b40:	05 88 b6 12 c0       	add    $0xc012b688,%eax
c0101b45:	8b 00                	mov    (%eax),%eax
c0101b47:	eb 05                	jmp    c0101b4e <ide_device_size+0x39>
    }
    return 0;
c0101b49:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101b4e:	89 ec                	mov    %ebp,%esp
c0101b50:	5d                   	pop    %ebp
c0101b51:	c3                   	ret    

c0101b52 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101b52:	55                   	push   %ebp
c0101b53:	89 e5                	mov    %esp,%ebp
c0101b55:	57                   	push   %edi
c0101b56:	53                   	push   %ebx
c0101b57:	83 ec 50             	sub    $0x50,%esp
c0101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5d:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101b61:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101b68:	77 23                	ja     c0101b8d <ide_read_secs+0x3b>
c0101b6a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b6e:	83 f8 03             	cmp    $0x3,%eax
c0101b71:	77 1a                	ja     c0101b8d <ide_read_secs+0x3b>
c0101b73:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101b77:	89 d0                	mov    %edx,%eax
c0101b79:	c1 e0 03             	shl    $0x3,%eax
c0101b7c:	29 d0                	sub    %edx,%eax
c0101b7e:	c1 e0 03             	shl    $0x3,%eax
c0101b81:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101b86:	0f b6 00             	movzbl (%eax),%eax
c0101b89:	84 c0                	test   %al,%al
c0101b8b:	75 24                	jne    c0101bb1 <ide_read_secs+0x5f>
c0101b8d:	c7 44 24 0c d4 a4 10 	movl   $0xc010a4d4,0xc(%esp)
c0101b94:	c0 
c0101b95:	c7 44 24 08 8f a4 10 	movl   $0xc010a48f,0x8(%esp)
c0101b9c:	c0 
c0101b9d:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101ba4:	00 
c0101ba5:	c7 04 24 a4 a4 10 c0 	movl   $0xc010a4a4,(%esp)
c0101bac:	e8 75 f1 ff ff       	call   c0100d26 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101bb1:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101bb8:	77 0f                	ja     c0101bc9 <ide_read_secs+0x77>
c0101bba:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101bbd:	8b 45 14             	mov    0x14(%ebp),%eax
c0101bc0:	01 d0                	add    %edx,%eax
c0101bc2:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101bc7:	76 24                	jbe    c0101bed <ide_read_secs+0x9b>
c0101bc9:	c7 44 24 0c fc a4 10 	movl   $0xc010a4fc,0xc(%esp)
c0101bd0:	c0 
c0101bd1:	c7 44 24 08 8f a4 10 	movl   $0xc010a48f,0x8(%esp)
c0101bd8:	c0 
c0101bd9:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101be0:	00 
c0101be1:	c7 04 24 a4 a4 10 c0 	movl   $0xc010a4a4,(%esp)
c0101be8:	e8 39 f1 ff ff       	call   c0100d26 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101bed:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101bf1:	d1 e8                	shr    %eax
c0101bf3:	0f b7 c0             	movzwl %ax,%eax
c0101bf6:	8b 04 85 44 a4 10 c0 	mov    -0x3fef5bbc(,%eax,4),%eax
c0101bfd:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c01:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c05:	d1 e8                	shr    %eax
c0101c07:	0f b7 c0             	movzwl %ax,%eax
c0101c0a:	0f b7 04 85 46 a4 10 	movzwl -0x3fef5bba(,%eax,4),%eax
c0101c11:	c0 
c0101c12:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101c16:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101c21:	00 
c0101c22:	89 04 24             	mov    %eax,(%esp)
c0101c25:	e8 4d fb ff ff       	call   c0101777 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c2d:	83 c0 02             	add    $0x2,%eax
c0101c30:	0f b7 c0             	movzwl %ax,%eax
c0101c33:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c37:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c3b:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c3f:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c43:	ee                   	out    %al,(%dx)
}
c0101c44:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101c45:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c48:	0f b6 c0             	movzbl %al,%eax
c0101c4b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c4f:	83 c2 02             	add    $0x2,%edx
c0101c52:	0f b7 d2             	movzwl %dx,%edx
c0101c55:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c59:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c5c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c60:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c64:	ee                   	out    %al,(%dx)
}
c0101c65:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101c66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c69:	0f b6 c0             	movzbl %al,%eax
c0101c6c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c70:	83 c2 03             	add    $0x3,%edx
c0101c73:	0f b7 d2             	movzwl %dx,%edx
c0101c76:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c7a:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c7d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c81:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c85:	ee                   	out    %al,(%dx)
}
c0101c86:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101c87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c8a:	c1 e8 08             	shr    $0x8,%eax
c0101c8d:	0f b6 c0             	movzbl %al,%eax
c0101c90:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c94:	83 c2 04             	add    $0x4,%edx
c0101c97:	0f b7 d2             	movzwl %dx,%edx
c0101c9a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c9e:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ca1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101ca5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101ca9:	ee                   	out    %al,(%dx)
}
c0101caa:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101cab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cae:	c1 e8 10             	shr    $0x10,%eax
c0101cb1:	0f b6 c0             	movzbl %al,%eax
c0101cb4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cb8:	83 c2 05             	add    $0x5,%edx
c0101cbb:	0f b7 d2             	movzwl %dx,%edx
c0101cbe:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101cc2:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cc5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101cc9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101ccd:	ee                   	out    %al,(%dx)
}
c0101cce:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101ccf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101cd2:	c0 e0 04             	shl    $0x4,%al
c0101cd5:	24 10                	and    $0x10,%al
c0101cd7:	88 c2                	mov    %al,%dl
c0101cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cdc:	c1 e8 18             	shr    $0x18,%eax
c0101cdf:	24 0f                	and    $0xf,%al
c0101ce1:	08 d0                	or     %dl,%al
c0101ce3:	0c e0                	or     $0xe0,%al
c0101ce5:	0f b6 c0             	movzbl %al,%eax
c0101ce8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101cec:	83 c2 06             	add    $0x6,%edx
c0101cef:	0f b7 d2             	movzwl %dx,%edx
c0101cf2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cf6:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cf9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cfd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101d01:	ee                   	out    %al,(%dx)
}
c0101d02:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d03:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d07:	83 c0 07             	add    $0x7,%eax
c0101d0a:	0f b7 c0             	movzwl %ax,%eax
c0101d0d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101d11:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101d15:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101d19:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101d1d:	ee                   	out    %al,(%dx)
}
c0101d1e:	90                   	nop

    int ret = 0;
c0101d1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d26:	eb 58                	jmp    c0101d80 <ide_read_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101d28:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d2c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101d33:	00 
c0101d34:	89 04 24             	mov    %eax,(%esp)
c0101d37:	e8 3b fa ff ff       	call   c0101777 <ide_wait_ready>
c0101d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101d43:	75 43                	jne    c0101d88 <ide_read_secs+0x236>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101d45:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d49:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101d4c:	8b 45 10             	mov    0x10(%ebp),%eax
c0101d4f:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101d52:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101d59:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101d5c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101d5f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101d62:	89 cb                	mov    %ecx,%ebx
c0101d64:	89 df                	mov    %ebx,%edi
c0101d66:	89 c1                	mov    %eax,%ecx
c0101d68:	fc                   	cld    
c0101d69:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101d6b:	89 c8                	mov    %ecx,%eax
c0101d6d:	89 fb                	mov    %edi,%ebx
c0101d6f:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101d72:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101d75:	90                   	nop
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101d76:	ff 4d 14             	decl   0x14(%ebp)
c0101d79:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101d80:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101d84:	75 a2                	jne    c0101d28 <ide_read_secs+0x1d6>
    }

out:
c0101d86:	eb 01                	jmp    c0101d89 <ide_read_secs+0x237>
            goto out;
c0101d88:	90                   	nop
    return ret;
c0101d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101d8c:	83 c4 50             	add    $0x50,%esp
c0101d8f:	5b                   	pop    %ebx
c0101d90:	5f                   	pop    %edi
c0101d91:	5d                   	pop    %ebp
c0101d92:	c3                   	ret    

c0101d93 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d93:	55                   	push   %ebp
c0101d94:	89 e5                	mov    %esp,%ebp
c0101d96:	56                   	push   %esi
c0101d97:	53                   	push   %ebx
c0101d98:	83 ec 50             	sub    $0x50,%esp
c0101d9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d9e:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101da2:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101da9:	77 23                	ja     c0101dce <ide_write_secs+0x3b>
c0101dab:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101daf:	83 f8 03             	cmp    $0x3,%eax
c0101db2:	77 1a                	ja     c0101dce <ide_write_secs+0x3b>
c0101db4:	0f b7 55 c4          	movzwl -0x3c(%ebp),%edx
c0101db8:	89 d0                	mov    %edx,%eax
c0101dba:	c1 e0 03             	shl    $0x3,%eax
c0101dbd:	29 d0                	sub    %edx,%eax
c0101dbf:	c1 e0 03             	shl    $0x3,%eax
c0101dc2:	05 80 b6 12 c0       	add    $0xc012b680,%eax
c0101dc7:	0f b6 00             	movzbl (%eax),%eax
c0101dca:	84 c0                	test   %al,%al
c0101dcc:	75 24                	jne    c0101df2 <ide_write_secs+0x5f>
c0101dce:	c7 44 24 0c d4 a4 10 	movl   $0xc010a4d4,0xc(%esp)
c0101dd5:	c0 
c0101dd6:	c7 44 24 08 8f a4 10 	movl   $0xc010a48f,0x8(%esp)
c0101ddd:	c0 
c0101dde:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101de5:	00 
c0101de6:	c7 04 24 a4 a4 10 c0 	movl   $0xc010a4a4,(%esp)
c0101ded:	e8 34 ef ff ff       	call   c0100d26 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101df2:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101df9:	77 0f                	ja     c0101e0a <ide_write_secs+0x77>
c0101dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101dfe:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e01:	01 d0                	add    %edx,%eax
c0101e03:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e08:	76 24                	jbe    c0101e2e <ide_write_secs+0x9b>
c0101e0a:	c7 44 24 0c fc a4 10 	movl   $0xc010a4fc,0xc(%esp)
c0101e11:	c0 
c0101e12:	c7 44 24 08 8f a4 10 	movl   $0xc010a48f,0x8(%esp)
c0101e19:	c0 
c0101e1a:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101e21:	00 
c0101e22:	c7 04 24 a4 a4 10 c0 	movl   $0xc010a4a4,(%esp)
c0101e29:	e8 f8 ee ff ff       	call   c0100d26 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101e2e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e32:	d1 e8                	shr    %eax
c0101e34:	0f b7 c0             	movzwl %ax,%eax
c0101e37:	8b 04 85 44 a4 10 c0 	mov    -0x3fef5bbc(,%eax,4),%eax
c0101e3e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101e42:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e46:	d1 e8                	shr    %eax
c0101e48:	0f b7 c0             	movzwl %ax,%eax
c0101e4b:	0f b7 04 85 46 a4 10 	movzwl -0x3fef5bba(,%eax,4),%eax
c0101e52:	c0 
c0101e53:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101e57:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101e5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101e62:	00 
c0101e63:	89 04 24             	mov    %eax,(%esp)
c0101e66:	e8 0c f9 ff ff       	call   c0101777 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e6e:	83 c0 02             	add    $0x2,%eax
c0101e71:	0f b7 c0             	movzwl %ax,%eax
c0101e74:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101e78:	c6 45 d5 00          	movb   $0x0,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e7c:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101e80:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101e84:	ee                   	out    %al,(%dx)
}
c0101e85:	90                   	nop
    outb(iobase + ISA_SECCNT, nsecs);
c0101e86:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e89:	0f b6 c0             	movzbl %al,%eax
c0101e8c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e90:	83 c2 02             	add    $0x2,%edx
c0101e93:	0f b7 d2             	movzwl %dx,%edx
c0101e96:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101e9a:	88 45 d9             	mov    %al,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e9d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101ea1:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101ea5:	ee                   	out    %al,(%dx)
}
c0101ea6:	90                   	nop
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101eaa:	0f b6 c0             	movzbl %al,%eax
c0101ead:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101eb1:	83 c2 03             	add    $0x3,%edx
c0101eb4:	0f b7 d2             	movzwl %dx,%edx
c0101eb7:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101ebb:	88 45 dd             	mov    %al,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ebe:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101ec2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101ec6:	ee                   	out    %al,(%dx)
}
c0101ec7:	90                   	nop
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ecb:	c1 e8 08             	shr    $0x8,%eax
c0101ece:	0f b6 c0             	movzbl %al,%eax
c0101ed1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ed5:	83 c2 04             	add    $0x4,%edx
c0101ed8:	0f b7 d2             	movzwl %dx,%edx
c0101edb:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101edf:	88 45 e1             	mov    %al,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101ee2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101ee6:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101eea:	ee                   	out    %al,(%dx)
}
c0101eeb:	90                   	nop
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101eec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101eef:	c1 e8 10             	shr    $0x10,%eax
c0101ef2:	0f b6 c0             	movzbl %al,%eax
c0101ef5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ef9:	83 c2 05             	add    $0x5,%edx
c0101efc:	0f b7 d2             	movzwl %dx,%edx
c0101eff:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f03:	88 45 e5             	mov    %al,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f06:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f0a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f0e:	ee                   	out    %al,(%dx)
}
c0101f0f:	90                   	nop
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101f10:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101f13:	c0 e0 04             	shl    $0x4,%al
c0101f16:	24 10                	and    $0x10,%al
c0101f18:	88 c2                	mov    %al,%dl
c0101f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f1d:	c1 e8 18             	shr    $0x18,%eax
c0101f20:	24 0f                	and    $0xf,%al
c0101f22:	08 d0                	or     %dl,%al
c0101f24:	0c e0                	or     $0xe0,%al
c0101f26:	0f b6 c0             	movzbl %al,%eax
c0101f29:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f2d:	83 c2 06             	add    $0x6,%edx
c0101f30:	0f b7 d2             	movzwl %dx,%edx
c0101f33:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f37:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f3a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f3e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f42:	ee                   	out    %al,(%dx)
}
c0101f43:	90                   	nop
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101f44:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f48:	83 c0 07             	add    $0x7,%eax
c0101f4b:	0f b7 c0             	movzwl %ax,%eax
c0101f4e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f52:	c6 45 ed 30          	movb   $0x30,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f56:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f5a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f5e:	ee                   	out    %al,(%dx)
}
c0101f5f:	90                   	nop

    int ret = 0;
c0101f60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f67:	eb 58                	jmp    c0101fc1 <ide_write_secs+0x22e>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101f69:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f6d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101f74:	00 
c0101f75:	89 04 24             	mov    %eax,(%esp)
c0101f78:	e8 fa f7 ff ff       	call   c0101777 <ide_wait_ready>
c0101f7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101f80:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f84:	75 43                	jne    c0101fc9 <ide_write_secs+0x236>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101f86:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101f8a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f8d:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f90:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f93:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile (
c0101f9a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f9d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101fa0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101fa3:	89 cb                	mov    %ecx,%ebx
c0101fa5:	89 de                	mov    %ebx,%esi
c0101fa7:	89 c1                	mov    %eax,%ecx
c0101fa9:	fc                   	cld    
c0101faa:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101fac:	89 c8                	mov    %ecx,%eax
c0101fae:	89 f3                	mov    %esi,%ebx
c0101fb0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101fb3:	89 45 c8             	mov    %eax,-0x38(%ebp)
}
c0101fb6:	90                   	nop
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101fb7:	ff 4d 14             	decl   0x14(%ebp)
c0101fba:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101fc1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101fc5:	75 a2                	jne    c0101f69 <ide_write_secs+0x1d6>
    }

out:
c0101fc7:	eb 01                	jmp    c0101fca <ide_write_secs+0x237>
            goto out;
c0101fc9:	90                   	nop
    return ret;
c0101fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fcd:	83 c4 50             	add    $0x50,%esp
c0101fd0:	5b                   	pop    %ebx
c0101fd1:	5e                   	pop    %esi
c0101fd2:	5d                   	pop    %ebp
c0101fd3:	c3                   	ret    

c0101fd4 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101fd4:	55                   	push   %ebp
c0101fd5:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101fd7:	fb                   	sti    
}
c0101fd8:	90                   	nop
    sti();
}
c0101fd9:	90                   	nop
c0101fda:	5d                   	pop    %ebp
c0101fdb:	c3                   	ret    

c0101fdc <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101fdc:	55                   	push   %ebp
c0101fdd:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101fdf:	fa                   	cli    
}
c0101fe0:	90                   	nop
    cli();
}
c0101fe1:	90                   	nop
c0101fe2:	5d                   	pop    %ebp
c0101fe3:	c3                   	ret    

c0101fe4 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101fe4:	55                   	push   %ebp
c0101fe5:	89 e5                	mov    %esp,%ebp
c0101fe7:	83 ec 14             	sub    $0x14,%esp
c0101fea:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fed:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ff4:	66 a3 50 85 12 c0    	mov    %ax,0xc0128550
    if (did_init) {
c0101ffa:	a1 60 b7 12 c0       	mov    0xc012b760,%eax
c0101fff:	85 c0                	test   %eax,%eax
c0102001:	74 39                	je     c010203c <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0102003:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102006:	0f b6 c0             	movzbl %al,%eax
c0102009:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c010200f:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102012:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102016:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010201a:	ee                   	out    %al,(%dx)
}
c010201b:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c010201c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102020:	c1 e8 08             	shr    $0x8,%eax
c0102023:	0f b7 c0             	movzwl %ax,%eax
c0102026:	0f b6 c0             	movzbl %al,%eax
c0102029:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c010202f:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102032:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102036:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010203a:	ee                   	out    %al,(%dx)
}
c010203b:	90                   	nop
    }
}
c010203c:	90                   	nop
c010203d:	89 ec                	mov    %ebp,%esp
c010203f:	5d                   	pop    %ebp
c0102040:	c3                   	ret    

c0102041 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102041:	55                   	push   %ebp
c0102042:	89 e5                	mov    %esp,%ebp
c0102044:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0102047:	8b 45 08             	mov    0x8(%ebp),%eax
c010204a:	ba 01 00 00 00       	mov    $0x1,%edx
c010204f:	88 c1                	mov    %al,%cl
c0102051:	d3 e2                	shl    %cl,%edx
c0102053:	89 d0                	mov    %edx,%eax
c0102055:	98                   	cwtl   
c0102056:	f7 d0                	not    %eax
c0102058:	0f bf d0             	movswl %ax,%edx
c010205b:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c0102062:	98                   	cwtl   
c0102063:	21 d0                	and    %edx,%eax
c0102065:	98                   	cwtl   
c0102066:	0f b7 c0             	movzwl %ax,%eax
c0102069:	89 04 24             	mov    %eax,(%esp)
c010206c:	e8 73 ff ff ff       	call   c0101fe4 <pic_setmask>
}
c0102071:	90                   	nop
c0102072:	89 ec                	mov    %ebp,%esp
c0102074:	5d                   	pop    %ebp
c0102075:	c3                   	ret    

c0102076 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0102076:	55                   	push   %ebp
c0102077:	89 e5                	mov    %esp,%ebp
c0102079:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010207c:	c7 05 60 b7 12 c0 01 	movl   $0x1,0xc012b760
c0102083:	00 00 00 
c0102086:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c010208c:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102090:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102094:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102098:	ee                   	out    %al,(%dx)
}
c0102099:	90                   	nop
c010209a:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c01020a0:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020a4:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020a8:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020ac:	ee                   	out    %al,(%dx)
}
c01020ad:	90                   	nop
c01020ae:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020b4:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020b8:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020bc:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020c0:	ee                   	out    %al,(%dx)
}
c01020c1:	90                   	nop
c01020c2:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c01020c8:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020cc:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020d0:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020d4:	ee                   	out    %al,(%dx)
}
c01020d5:	90                   	nop
c01020d6:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01020dc:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020e0:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01020e4:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020e8:	ee                   	out    %al,(%dx)
}
c01020e9:	90                   	nop
c01020ea:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01020f0:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020f4:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01020f8:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01020fc:	ee                   	out    %al,(%dx)
}
c01020fd:	90                   	nop
c01020fe:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0102104:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102108:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010210c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102110:	ee                   	out    %al,(%dx)
}
c0102111:	90                   	nop
c0102112:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c0102118:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010211c:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102120:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102124:	ee                   	out    %al,(%dx)
}
c0102125:	90                   	nop
c0102126:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c010212c:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102130:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102134:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102138:	ee                   	out    %al,(%dx)
}
c0102139:	90                   	nop
c010213a:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102140:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102144:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102148:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010214c:	ee                   	out    %al,(%dx)
}
c010214d:	90                   	nop
c010214e:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0102154:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102158:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010215c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102160:	ee                   	out    %al,(%dx)
}
c0102161:	90                   	nop
c0102162:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102168:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010216c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102170:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102174:	ee                   	out    %al,(%dx)
}
c0102175:	90                   	nop
c0102176:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c010217c:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102180:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102184:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102188:	ee                   	out    %al,(%dx)
}
c0102189:	90                   	nop
c010218a:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0102190:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102194:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102198:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010219c:	ee                   	out    %al,(%dx)
}
c010219d:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010219e:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c01021a5:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01021aa:	74 0f                	je     c01021bb <pic_init+0x145>
        pic_setmask(irq_mask);
c01021ac:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c01021b3:	89 04 24             	mov    %eax,(%esp)
c01021b6:	e8 29 fe ff ff       	call   c0101fe4 <pic_setmask>
    }
}
c01021bb:	90                   	nop
c01021bc:	89 ec                	mov    %ebp,%esp
c01021be:	5d                   	pop    %ebp
c01021bf:	c3                   	ret    

c01021c0 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01021c0:	55                   	push   %ebp
c01021c1:	89 e5                	mov    %esp,%ebp
c01021c3:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01021c6:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01021cd:	00 
c01021ce:	c7 04 24 40 a5 10 c0 	movl   $0xc010a540,(%esp)
c01021d5:	e8 9e e1 ff ff       	call   c0100378 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01021da:	c7 04 24 4a a5 10 c0 	movl   $0xc010a54a,(%esp)
c01021e1:	e8 92 e1 ff ff       	call   c0100378 <cprintf>
    panic("EOT: kernel seems ok.");
c01021e6:	c7 44 24 08 58 a5 10 	movl   $0xc010a558,0x8(%esp)
c01021ed:	c0 
c01021ee:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01021f5:	00 
c01021f6:	c7 04 24 6e a5 10 c0 	movl   $0xc010a56e,(%esp)
c01021fd:	e8 24 eb ff ff       	call   c0100d26 <__panic>

c0102202 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102202:	55                   	push   %ebp
c0102203:	89 e5                	mov    %esp,%ebp
c0102205:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];//存储了中断处理程序的入口地址

	for (int i = 0 ; i < 256; i++)  
c0102208:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010220f:	e9 c4 00 00 00       	jmp    c01022d8 <idt_init+0xd6>
		SETGATE(idt[i],0,GD_KTEXT,__vectors[i],DPL_KERNEL);
c0102214:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102217:	8b 04 85 e0 85 12 c0 	mov    -0x3fed7a20(,%eax,4),%eax
c010221e:	0f b7 d0             	movzwl %ax,%edx
c0102221:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102224:	66 89 14 c5 80 b7 12 	mov    %dx,-0x3fed4880(,%eax,8)
c010222b:	c0 
c010222c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010222f:	66 c7 04 c5 82 b7 12 	movw   $0x8,-0x3fed487e(,%eax,8)
c0102236:	c0 08 00 
c0102239:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010223c:	0f b6 14 c5 84 b7 12 	movzbl -0x3fed487c(,%eax,8),%edx
c0102243:	c0 
c0102244:	80 e2 e0             	and    $0xe0,%dl
c0102247:	88 14 c5 84 b7 12 c0 	mov    %dl,-0x3fed487c(,%eax,8)
c010224e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102251:	0f b6 14 c5 84 b7 12 	movzbl -0x3fed487c(,%eax,8),%edx
c0102258:	c0 
c0102259:	80 e2 1f             	and    $0x1f,%dl
c010225c:	88 14 c5 84 b7 12 c0 	mov    %dl,-0x3fed487c(,%eax,8)
c0102263:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102266:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c010226d:	c0 
c010226e:	80 e2 f0             	and    $0xf0,%dl
c0102271:	80 ca 0e             	or     $0xe,%dl
c0102274:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c010227b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227e:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c0102285:	c0 
c0102286:	80 e2 ef             	and    $0xef,%dl
c0102289:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c0102290:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102293:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c010229a:	c0 
c010229b:	80 e2 9f             	and    $0x9f,%dl
c010229e:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c01022a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022a8:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c01022af:	c0 
c01022b0:	80 ca 80             	or     $0x80,%dl
c01022b3:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c01022ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022bd:	8b 04 85 e0 85 12 c0 	mov    -0x3fed7a20(,%eax,4),%eax
c01022c4:	c1 e8 10             	shr    $0x10,%eax
c01022c7:	0f b7 d0             	movzwl %ax,%edx
c01022ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022cd:	66 89 14 c5 86 b7 12 	mov    %dx,-0x3fed487a(,%eax,8)
c01022d4:	c0 
	for (int i = 0 ; i < 256; i++)  
c01022d5:	ff 45 fc             	incl   -0x4(%ebp)
c01022d8:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01022df:	0f 8e 2f ff ff ff    	jle    c0102214 <idt_init+0x12>
	SETGATE(idt[T_SWITCH_TOK],0,GD_KTEXT,__vectors[T_SWITCH_TOK],DPL_USER);//kernel/mm/memlayout
c01022e5:	a1 c4 87 12 c0       	mov    0xc01287c4,%eax
c01022ea:	0f b7 c0             	movzwl %ax,%eax
c01022ed:	66 a3 48 bb 12 c0    	mov    %ax,0xc012bb48
c01022f3:	66 c7 05 4a bb 12 c0 	movw   $0x8,0xc012bb4a
c01022fa:	08 00 
c01022fc:	0f b6 05 4c bb 12 c0 	movzbl 0xc012bb4c,%eax
c0102303:	24 e0                	and    $0xe0,%al
c0102305:	a2 4c bb 12 c0       	mov    %al,0xc012bb4c
c010230a:	0f b6 05 4c bb 12 c0 	movzbl 0xc012bb4c,%eax
c0102311:	24 1f                	and    $0x1f,%al
c0102313:	a2 4c bb 12 c0       	mov    %al,0xc012bb4c
c0102318:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010231f:	24 f0                	and    $0xf0,%al
c0102321:	0c 0e                	or     $0xe,%al
c0102323:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102328:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010232f:	24 ef                	and    $0xef,%al
c0102331:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102336:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010233d:	0c 60                	or     $0x60,%al
c010233f:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102344:	0f b6 05 4d bb 12 c0 	movzbl 0xc012bb4d,%eax
c010234b:	0c 80                	or     $0x80,%al
c010234d:	a2 4d bb 12 c0       	mov    %al,0xc012bb4d
c0102352:	a1 c4 87 12 c0       	mov    0xc01287c4,%eax
c0102357:	c1 e8 10             	shr    $0x10,%eax
c010235a:	0f b7 c0             	movzwl %ax,%eax
c010235d:	66 a3 4e bb 12 c0    	mov    %ax,0xc012bb4e
c0102363:	c7 45 f8 60 85 12 c0 	movl   $0xc0128560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010236a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010236d:	0f 01 18             	lidtl  (%eax)
}
c0102370:	90                   	nop
	//args:(gate, istrap, sel, off, dpl) 1:trap(= exception)gate,0:interruptgate向量首地址 gate类型 段选择子 偏移地址 DPL
	//特权级不同
	//段选择子:.text的段选择子GD_KTEXT 中断处理函数属于.text vector.s  .text段基址为0 中断处理函数地址的偏移量=地址__vectors i 
	lidt(&idt_pd);//将IDT表的起始地址加载到IDTR寄存器中,
}
c0102371:	90                   	nop
c0102372:	89 ec                	mov    %ebp,%esp
c0102374:	5d                   	pop    %ebp
c0102375:	c3                   	ret    

c0102376 <trapname>:

static const char *
trapname(int trapno) {
c0102376:	55                   	push   %ebp
c0102377:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102379:	8b 45 08             	mov    0x8(%ebp),%eax
c010237c:	83 f8 13             	cmp    $0x13,%eax
c010237f:	77 0c                	ja     c010238d <trapname+0x17>
        return excnames[trapno];
c0102381:	8b 45 08             	mov    0x8(%ebp),%eax
c0102384:	8b 04 85 c0 a9 10 c0 	mov    -0x3fef5640(,%eax,4),%eax
c010238b:	eb 18                	jmp    c01023a5 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010238d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102391:	7e 0d                	jle    c01023a0 <trapname+0x2a>
c0102393:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102397:	7f 07                	jg     c01023a0 <trapname+0x2a>
        return "Hardware Interrupt";
c0102399:	b8 7f a5 10 c0       	mov    $0xc010a57f,%eax
c010239e:	eb 05                	jmp    c01023a5 <trapname+0x2f>
    }
    return "(unknown trap)";
c01023a0:	b8 92 a5 10 c0       	mov    $0xc010a592,%eax
}
c01023a5:	5d                   	pop    %ebp
c01023a6:	c3                   	ret    

c01023a7 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023a7:	55                   	push   %ebp
c01023a8:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ad:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023b1:	83 f8 08             	cmp    $0x8,%eax
c01023b4:	0f 94 c0             	sete   %al
c01023b7:	0f b6 c0             	movzbl %al,%eax
}
c01023ba:	5d                   	pop    %ebp
c01023bb:	c3                   	ret    

c01023bc <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023bc:	55                   	push   %ebp
c01023bd:	89 e5                	mov    %esp,%ebp
c01023bf:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023c9:	c7 04 24 d3 a5 10 c0 	movl   $0xc010a5d3,(%esp)
c01023d0:	e8 a3 df ff ff       	call   c0100378 <cprintf>
    print_regs(&tf->tf_regs);
c01023d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d8:	89 04 24             	mov    %eax,(%esp)
c01023db:	e8 8f 01 00 00       	call   c010256f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023e3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023eb:	c7 04 24 e4 a5 10 c0 	movl   $0xc010a5e4,(%esp)
c01023f2:	e8 81 df ff ff       	call   c0100378 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01023f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023fa:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01023fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102402:	c7 04 24 f7 a5 10 c0 	movl   $0xc010a5f7,(%esp)
c0102409:	e8 6a df ff ff       	call   c0100378 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010240e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102411:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102415:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102419:	c7 04 24 0a a6 10 c0 	movl   $0xc010a60a,(%esp)
c0102420:	e8 53 df ff ff       	call   c0100378 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102425:	8b 45 08             	mov    0x8(%ebp),%eax
c0102428:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010242c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102430:	c7 04 24 1d a6 10 c0 	movl   $0xc010a61d,(%esp)
c0102437:	e8 3c df ff ff       	call   c0100378 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010243c:	8b 45 08             	mov    0x8(%ebp),%eax
c010243f:	8b 40 30             	mov    0x30(%eax),%eax
c0102442:	89 04 24             	mov    %eax,(%esp)
c0102445:	e8 2c ff ff ff       	call   c0102376 <trapname>
c010244a:	8b 55 08             	mov    0x8(%ebp),%edx
c010244d:	8b 52 30             	mov    0x30(%edx),%edx
c0102450:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102454:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102458:	c7 04 24 30 a6 10 c0 	movl   $0xc010a630,(%esp)
c010245f:	e8 14 df ff ff       	call   c0100378 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102464:	8b 45 08             	mov    0x8(%ebp),%eax
c0102467:	8b 40 34             	mov    0x34(%eax),%eax
c010246a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246e:	c7 04 24 42 a6 10 c0 	movl   $0xc010a642,(%esp)
c0102475:	e8 fe de ff ff       	call   c0100378 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010247a:	8b 45 08             	mov    0x8(%ebp),%eax
c010247d:	8b 40 38             	mov    0x38(%eax),%eax
c0102480:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102484:	c7 04 24 51 a6 10 c0 	movl   $0xc010a651,(%esp)
c010248b:	e8 e8 de ff ff       	call   c0100378 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102490:	8b 45 08             	mov    0x8(%ebp),%eax
c0102493:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102497:	89 44 24 04          	mov    %eax,0x4(%esp)
c010249b:	c7 04 24 60 a6 10 c0 	movl   $0xc010a660,(%esp)
c01024a2:	e8 d1 de ff ff       	call   c0100378 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01024aa:	8b 40 40             	mov    0x40(%eax),%eax
c01024ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b1:	c7 04 24 73 a6 10 c0 	movl   $0xc010a673,(%esp)
c01024b8:	e8 bb de ff ff       	call   c0100378 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01024c4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01024cb:	eb 3d                	jmp    c010250a <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01024cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d0:	8b 50 40             	mov    0x40(%eax),%edx
c01024d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01024d6:	21 d0                	and    %edx,%eax
c01024d8:	85 c0                	test   %eax,%eax
c01024da:	74 28                	je     c0102504 <print_trapframe+0x148>
c01024dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024df:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c01024e6:	85 c0                	test   %eax,%eax
c01024e8:	74 1a                	je     c0102504 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c01024ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024ed:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c01024f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f8:	c7 04 24 82 a6 10 c0 	movl   $0xc010a682,(%esp)
c01024ff:	e8 74 de ff ff       	call   c0100378 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102504:	ff 45 f4             	incl   -0xc(%ebp)
c0102507:	d1 65 f0             	shll   -0x10(%ebp)
c010250a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010250d:	83 f8 17             	cmp    $0x17,%eax
c0102510:	76 bb                	jbe    c01024cd <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102512:	8b 45 08             	mov    0x8(%ebp),%eax
c0102515:	8b 40 40             	mov    0x40(%eax),%eax
c0102518:	c1 e8 0c             	shr    $0xc,%eax
c010251b:	83 e0 03             	and    $0x3,%eax
c010251e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102522:	c7 04 24 86 a6 10 c0 	movl   $0xc010a686,(%esp)
c0102529:	e8 4a de ff ff       	call   c0100378 <cprintf>

    if (!trap_in_kernel(tf)) {
c010252e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102531:	89 04 24             	mov    %eax,(%esp)
c0102534:	e8 6e fe ff ff       	call   c01023a7 <trap_in_kernel>
c0102539:	85 c0                	test   %eax,%eax
c010253b:	75 2d                	jne    c010256a <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010253d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102540:	8b 40 44             	mov    0x44(%eax),%eax
c0102543:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102547:	c7 04 24 8f a6 10 c0 	movl   $0xc010a68f,(%esp)
c010254e:	e8 25 de ff ff       	call   c0100378 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102553:	8b 45 08             	mov    0x8(%ebp),%eax
c0102556:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010255a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255e:	c7 04 24 9e a6 10 c0 	movl   $0xc010a69e,(%esp)
c0102565:	e8 0e de ff ff       	call   c0100378 <cprintf>
    }
}
c010256a:	90                   	nop
c010256b:	89 ec                	mov    %ebp,%esp
c010256d:	5d                   	pop    %ebp
c010256e:	c3                   	ret    

c010256f <print_regs>:

void
print_regs(struct pushregs *regs) {
c010256f:	55                   	push   %ebp
c0102570:	89 e5                	mov    %esp,%ebp
c0102572:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102575:	8b 45 08             	mov    0x8(%ebp),%eax
c0102578:	8b 00                	mov    (%eax),%eax
c010257a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010257e:	c7 04 24 b1 a6 10 c0 	movl   $0xc010a6b1,(%esp)
c0102585:	e8 ee dd ff ff       	call   c0100378 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010258a:	8b 45 08             	mov    0x8(%ebp),%eax
c010258d:	8b 40 04             	mov    0x4(%eax),%eax
c0102590:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102594:	c7 04 24 c0 a6 10 c0 	movl   $0xc010a6c0,(%esp)
c010259b:	e8 d8 dd ff ff       	call   c0100378 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a3:	8b 40 08             	mov    0x8(%eax),%eax
c01025a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025aa:	c7 04 24 cf a6 10 c0 	movl   $0xc010a6cf,(%esp)
c01025b1:	e8 c2 dd ff ff       	call   c0100378 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b9:	8b 40 0c             	mov    0xc(%eax),%eax
c01025bc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025c0:	c7 04 24 de a6 10 c0 	movl   $0xc010a6de,(%esp)
c01025c7:	e8 ac dd ff ff       	call   c0100378 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01025cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01025cf:	8b 40 10             	mov    0x10(%eax),%eax
c01025d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d6:	c7 04 24 ed a6 10 c0 	movl   $0xc010a6ed,(%esp)
c01025dd:	e8 96 dd ff ff       	call   c0100378 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01025e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e5:	8b 40 14             	mov    0x14(%eax),%eax
c01025e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ec:	c7 04 24 fc a6 10 c0 	movl   $0xc010a6fc,(%esp)
c01025f3:	e8 80 dd ff ff       	call   c0100378 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01025f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01025fb:	8b 40 18             	mov    0x18(%eax),%eax
c01025fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102602:	c7 04 24 0b a7 10 c0 	movl   $0xc010a70b,(%esp)
c0102609:	e8 6a dd ff ff       	call   c0100378 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010260e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102611:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102614:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102618:	c7 04 24 1a a7 10 c0 	movl   $0xc010a71a,(%esp)
c010261f:	e8 54 dd ff ff       	call   c0100378 <cprintf>
}
c0102624:	90                   	nop
c0102625:	89 ec                	mov    %ebp,%esp
c0102627:	5d                   	pop    %ebp
c0102628:	c3                   	ret    

c0102629 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102629:	55                   	push   %ebp
c010262a:	89 e5                	mov    %esp,%ebp
c010262c:	83 ec 38             	sub    $0x38,%esp
c010262f:	89 5d fc             	mov    %ebx,-0x4(%ebp)
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102632:	8b 45 08             	mov    0x8(%ebp),%eax
c0102635:	8b 40 34             	mov    0x34(%eax),%eax
c0102638:	83 e0 01             	and    $0x1,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010263b:	85 c0                	test   %eax,%eax
c010263d:	74 07                	je     c0102646 <print_pgfault+0x1d>
c010263f:	bb 29 a7 10 c0       	mov    $0xc010a729,%ebx
c0102644:	eb 05                	jmp    c010264b <print_pgfault+0x22>
c0102646:	bb 3a a7 10 c0       	mov    $0xc010a73a,%ebx
            (tf->tf_err & 2) ? 'W' : 'R',
c010264b:	8b 45 08             	mov    0x8(%ebp),%eax
c010264e:	8b 40 34             	mov    0x34(%eax),%eax
c0102651:	83 e0 02             	and    $0x2,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102654:	85 c0                	test   %eax,%eax
c0102656:	74 07                	je     c010265f <print_pgfault+0x36>
c0102658:	b9 57 00 00 00       	mov    $0x57,%ecx
c010265d:	eb 05                	jmp    c0102664 <print_pgfault+0x3b>
c010265f:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102664:	8b 45 08             	mov    0x8(%ebp),%eax
c0102667:	8b 40 34             	mov    0x34(%eax),%eax
c010266a:	83 e0 04             	and    $0x4,%eax
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010266d:	85 c0                	test   %eax,%eax
c010266f:	74 07                	je     c0102678 <print_pgfault+0x4f>
c0102671:	ba 55 00 00 00       	mov    $0x55,%edx
c0102676:	eb 05                	jmp    c010267d <print_pgfault+0x54>
c0102678:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010267d:	0f 20 d0             	mov    %cr2,%eax
c0102680:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102683:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102686:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010268a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010268e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102692:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102696:	c7 04 24 48 a7 10 c0 	movl   $0xc010a748,(%esp)
c010269d:	e8 d6 dc ff ff       	call   c0100378 <cprintf>
}
c01026a2:	90                   	nop
c01026a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01026a6:	89 ec                	mov    %ebp,%esp
c01026a8:	5d                   	pop    %ebp
c01026a9:	c3                   	ret    

c01026aa <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026aa:	55                   	push   %ebp
c01026ab:	89 e5                	mov    %esp,%ebp
c01026ad:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01026b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01026b3:	89 04 24             	mov    %eax,(%esp)
c01026b6:	e8 6e ff ff ff       	call   c0102629 <print_pgfault>
    if (check_mm_struct != NULL) {
c01026bb:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01026c0:	85 c0                	test   %eax,%eax
c01026c2:	74 26                	je     c01026ea <pgfault_handler+0x40>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026c4:	0f 20 d0             	mov    %cr2,%eax
c01026c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01026ca:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01026cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01026d0:	8b 50 34             	mov    0x34(%eax),%edx
c01026d3:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c01026d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01026dc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01026e0:	89 04 24             	mov    %eax,(%esp)
c01026e3:	e8 8a 5d 00 00       	call   c0108472 <do_pgfault>
c01026e8:	eb 1c                	jmp    c0102706 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c01026ea:	c7 44 24 08 6b a7 10 	movl   $0xc010a76b,0x8(%esp)
c01026f1:	c0 
c01026f2:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
c01026f9:	00 
c01026fa:	c7 04 24 6e a5 10 c0 	movl   $0xc010a56e,(%esp)
c0102701:	e8 20 e6 ff ff       	call   c0100d26 <__panic>
}
c0102706:	89 ec                	mov    %ebp,%esp
c0102708:	5d                   	pop    %ebp
c0102709:	c3                   	ret    

c010270a <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c010270a:	55                   	push   %ebp
c010270b:	89 e5                	mov    %esp,%ebp
c010270d:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102710:	8b 45 08             	mov    0x8(%ebp),%eax
c0102713:	8b 40 30             	mov    0x30(%eax),%eax
c0102716:	83 f8 79             	cmp    $0x79,%eax
c0102719:	0f 84 52 01 00 00    	je     c0102871 <trap_dispatch+0x167>
c010271f:	83 f8 79             	cmp    $0x79,%eax
c0102722:	0f 87 8a 01 00 00    	ja     c01028b2 <trap_dispatch+0x1a8>
c0102728:	83 f8 2f             	cmp    $0x2f,%eax
c010272b:	77 1e                	ja     c010274b <trap_dispatch+0x41>
c010272d:	83 f8 0e             	cmp    $0xe,%eax
c0102730:	0f 82 7c 01 00 00    	jb     c01028b2 <trap_dispatch+0x1a8>
c0102736:	83 e8 0e             	sub    $0xe,%eax
c0102739:	83 f8 21             	cmp    $0x21,%eax
c010273c:	0f 87 70 01 00 00    	ja     c01028b2 <trap_dispatch+0x1a8>
c0102742:	8b 04 85 dc a7 10 c0 	mov    -0x3fef5824(,%eax,4),%eax
c0102749:	ff e0                	jmp    *%eax
c010274b:	83 f8 78             	cmp    $0x78,%eax
c010274e:	0f 84 ca 00 00 00    	je     c010281e <trap_dispatch+0x114>
c0102754:	e9 59 01 00 00       	jmp    c01028b2 <trap_dispatch+0x1a8>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102759:	8b 45 08             	mov    0x8(%ebp),%eax
c010275c:	89 04 24             	mov    %eax,(%esp)
c010275f:	e8 46 ff ff ff       	call   c01026aa <pgfault_handler>
c0102764:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102767:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010276b:	0f 84 79 01 00 00    	je     c01028ea <trap_dispatch+0x1e0>
            print_trapframe(tf);
c0102771:	8b 45 08             	mov    0x8(%ebp),%eax
c0102774:	89 04 24             	mov    %eax,(%esp)
c0102777:	e8 40 fc ff ff       	call   c01023bc <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c010277c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010277f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102783:	c7 44 24 08 82 a7 10 	movl   $0xc010a782,0x8(%esp)
c010278a:	c0 
c010278b:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
c0102792:	00 
c0102793:	c7 04 24 6e a5 10 c0 	movl   $0xc010a56e,(%esp)
c010279a:	e8 87 e5 ff ff       	call   c0100d26 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	    ticks = ticks + 1;
c010279f:	a1 24 b4 12 c0       	mov    0xc012b424,%eax
c01027a4:	40                   	inc    %eax
c01027a5:	a3 24 b4 12 c0       	mov    %eax,0xc012b424
	    if(ticks == TICK_NUM) 
c01027aa:	a1 24 b4 12 c0       	mov    0xc012b424,%eax
c01027af:	83 f8 64             	cmp    $0x64,%eax
c01027b2:	0f 85 35 01 00 00    	jne    c01028ed <trap_dispatch+0x1e3>
	    {
		    print_ticks();
c01027b8:	e8 03 fa ff ff       	call   c01021c0 <print_ticks>
		    ticks=0;
c01027bd:	c7 05 24 b4 12 c0 00 	movl   $0x0,0xc012b424
c01027c4:	00 00 00 
	    }
        break;
c01027c7:	e9 21 01 00 00       	jmp    c01028ed <trap_dispatch+0x1e3>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01027cc:	e8 35 ef ff ff       	call   c0101706 <cons_getc>
c01027d1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01027d4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01027d8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01027dc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027e4:	c7 04 24 9d a7 10 c0 	movl   $0xc010a79d,(%esp)
c01027eb:	e8 88 db ff ff       	call   c0100378 <cprintf>
        break;
c01027f0:	e9 ff 00 00 00       	jmp    c01028f4 <trap_dispatch+0x1ea>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01027f5:	e8 0c ef ff ff       	call   c0101706 <cons_getc>
c01027fa:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01027fd:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0102801:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0102805:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102809:	89 44 24 04          	mov    %eax,0x4(%esp)
c010280d:	c7 04 24 af a7 10 c0 	movl   $0xc010a7af,(%esp)
c0102814:	e8 5f db ff ff       	call   c0100378 <cprintf>
        break;
c0102819:	e9 d6 00 00 00       	jmp    c01028f4 <trap_dispatch+0x1ea>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
c010281e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102821:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102825:	83 f8 1b             	cmp    $0x1b,%eax
c0102828:	0f 84 c2 00 00 00    	je     c01028f0 <trap_dispatch+0x1e6>
	    tf->tf_cs=USER_CS;
c010282e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102831:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
	    tf->tf_ds=tf->tf_es=tf->tf_ss=USER_DS;
c0102837:	8b 45 08             	mov    0x8(%ebp),%eax
c010283a:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c0102840:	8b 45 08             	mov    0x8(%ebp),%eax
c0102843:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c0102847:	8b 45 08             	mov    0x8(%ebp),%eax
c010284a:	66 89 50 28          	mov    %dx,0x28(%eax)
c010284e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102851:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102855:	8b 45 08             	mov    0x8(%ebp),%eax
c0102858:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        tf->tf_eflags |= FL_IOPL_MASK;
c010285c:	8b 45 08             	mov    0x8(%ebp),%eax
c010285f:	8b 40 40             	mov    0x40(%eax),%eax
c0102862:	0d 00 30 00 00       	or     $0x3000,%eax
c0102867:	89 c2                	mov    %eax,%edx
c0102869:	8b 45 08             	mov    0x8(%ebp),%eax
c010286c:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
c010286f:	eb 7f                	jmp    c01028f0 <trap_dispatch+0x1e6>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
c0102871:	8b 45 08             	mov    0x8(%ebp),%eax
c0102874:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102878:	83 f8 08             	cmp    $0x8,%eax
c010287b:	74 76                	je     c01028f3 <trap_dispatch+0x1e9>
            tf->tf_cs = KERNEL_CS;
c010287d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102880:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0102886:	8b 45 08             	mov    0x8(%ebp),%eax
c0102889:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c010288f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102892:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102896:	8b 45 08             	mov    0x8(%ebp),%eax
c0102899:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c010289d:	8b 45 08             	mov    0x8(%ebp),%eax
c01028a0:	8b 40 40             	mov    0x40(%eax),%eax
c01028a3:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c01028a8:	89 c2                	mov    %eax,%edx
c01028aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ad:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
c01028b0:	eb 41                	jmp    c01028f3 <trap_dispatch+0x1e9>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01028b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01028b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01028b9:	83 e0 03             	and    $0x3,%eax
c01028bc:	85 c0                	test   %eax,%eax
c01028be:	75 34                	jne    c01028f4 <trap_dispatch+0x1ea>
            print_trapframe(tf);
c01028c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01028c3:	89 04 24             	mov    %eax,(%esp)
c01028c6:	e8 f1 fa ff ff       	call   c01023bc <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01028cb:	c7 44 24 08 be a7 10 	movl   $0xc010a7be,0x8(%esp)
c01028d2:	c0 
c01028d3:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01028da:	00 
c01028db:	c7 04 24 6e a5 10 c0 	movl   $0xc010a56e,(%esp)
c01028e2:	e8 3f e4 ff ff       	call   c0100d26 <__panic>
        break;
c01028e7:	90                   	nop
c01028e8:	eb 0a                	jmp    c01028f4 <trap_dispatch+0x1ea>
        break;
c01028ea:	90                   	nop
c01028eb:	eb 07                	jmp    c01028f4 <trap_dispatch+0x1ea>
        break;
c01028ed:	90                   	nop
c01028ee:	eb 04                	jmp    c01028f4 <trap_dispatch+0x1ea>
        break;
c01028f0:	90                   	nop
c01028f1:	eb 01                	jmp    c01028f4 <trap_dispatch+0x1ea>
        break;
c01028f3:	90                   	nop
        }
    }
}
c01028f4:	90                   	nop
c01028f5:	89 ec                	mov    %ebp,%esp
c01028f7:	5d                   	pop    %ebp
c01028f8:	c3                   	ret    

c01028f9 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01028f9:	55                   	push   %ebp
c01028fa:	89 e5                	mov    %esp,%ebp
c01028fc:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01028ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102902:	89 04 24             	mov    %eax,(%esp)
c0102905:	e8 00 fe ff ff       	call   c010270a <trap_dispatch>
}
c010290a:	90                   	nop
c010290b:	89 ec                	mov    %ebp,%esp
c010290d:	5d                   	pop    %ebp
c010290e:	c3                   	ret    

c010290f <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010290f:	1e                   	push   %ds
    pushl %es
c0102910:	06                   	push   %es
    pushl %fs
c0102911:	0f a0                	push   %fs
    pushl %gs
c0102913:	0f a8                	push   %gs
    pushal
c0102915:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102916:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010291b:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010291d:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010291f:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102920:	e8 d4 ff ff ff       	call   c01028f9 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102925:	5c                   	pop    %esp

c0102926 <__trapret>:
    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    #中断恢复
    popal
c0102926:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102927:	0f a9                	pop    %gs
    popl %fs
c0102929:	0f a1                	pop    %fs
    popl %es
c010292b:	07                   	pop    %es
    popl %ds
c010292c:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010292d:	83 c4 08             	add    $0x8,%esp
    iret                              #从中断返回 到kernel_thread_entry
c0102930:	cf                   	iret   

c0102931 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp               #esp指向当前进程中断帧
c0102931:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102935:	eb ef                	jmp    c0102926 <__trapret>

c0102937 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102937:	6a 00                	push   $0x0
  pushl $0
c0102939:	6a 00                	push   $0x0
  jmp __alltraps
c010293b:	e9 cf ff ff ff       	jmp    c010290f <__alltraps>

c0102940 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102940:	6a 00                	push   $0x0
  pushl $1
c0102942:	6a 01                	push   $0x1
  jmp __alltraps
c0102944:	e9 c6 ff ff ff       	jmp    c010290f <__alltraps>

c0102949 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102949:	6a 00                	push   $0x0
  pushl $2
c010294b:	6a 02                	push   $0x2
  jmp __alltraps
c010294d:	e9 bd ff ff ff       	jmp    c010290f <__alltraps>

c0102952 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102952:	6a 00                	push   $0x0
  pushl $3
c0102954:	6a 03                	push   $0x3
  jmp __alltraps
c0102956:	e9 b4 ff ff ff       	jmp    c010290f <__alltraps>

c010295b <vector4>:
.globl vector4
vector4:
  pushl $0
c010295b:	6a 00                	push   $0x0
  pushl $4
c010295d:	6a 04                	push   $0x4
  jmp __alltraps
c010295f:	e9 ab ff ff ff       	jmp    c010290f <__alltraps>

c0102964 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102964:	6a 00                	push   $0x0
  pushl $5
c0102966:	6a 05                	push   $0x5
  jmp __alltraps
c0102968:	e9 a2 ff ff ff       	jmp    c010290f <__alltraps>

c010296d <vector6>:
.globl vector6
vector6:
  pushl $0
c010296d:	6a 00                	push   $0x0
  pushl $6
c010296f:	6a 06                	push   $0x6
  jmp __alltraps
c0102971:	e9 99 ff ff ff       	jmp    c010290f <__alltraps>

c0102976 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102976:	6a 00                	push   $0x0
  pushl $7
c0102978:	6a 07                	push   $0x7
  jmp __alltraps
c010297a:	e9 90 ff ff ff       	jmp    c010290f <__alltraps>

c010297f <vector8>:
.globl vector8
vector8:
  pushl $8
c010297f:	6a 08                	push   $0x8
  jmp __alltraps
c0102981:	e9 89 ff ff ff       	jmp    c010290f <__alltraps>

c0102986 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102986:	6a 00                	push   $0x0
  pushl $9
c0102988:	6a 09                	push   $0x9
  jmp __alltraps
c010298a:	e9 80 ff ff ff       	jmp    c010290f <__alltraps>

c010298f <vector10>:
.globl vector10
vector10:
  pushl $10
c010298f:	6a 0a                	push   $0xa
  jmp __alltraps
c0102991:	e9 79 ff ff ff       	jmp    c010290f <__alltraps>

c0102996 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102996:	6a 0b                	push   $0xb
  jmp __alltraps
c0102998:	e9 72 ff ff ff       	jmp    c010290f <__alltraps>

c010299d <vector12>:
.globl vector12
vector12:
  pushl $12
c010299d:	6a 0c                	push   $0xc
  jmp __alltraps
c010299f:	e9 6b ff ff ff       	jmp    c010290f <__alltraps>

c01029a4 <vector13>:
.globl vector13
vector13:
  pushl $13
c01029a4:	6a 0d                	push   $0xd
  jmp __alltraps
c01029a6:	e9 64 ff ff ff       	jmp    c010290f <__alltraps>

c01029ab <vector14>:
.globl vector14
vector14:
  pushl $14
c01029ab:	6a 0e                	push   $0xe
  jmp __alltraps
c01029ad:	e9 5d ff ff ff       	jmp    c010290f <__alltraps>

c01029b2 <vector15>:
.globl vector15
vector15:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $15
c01029b4:	6a 0f                	push   $0xf
  jmp __alltraps
c01029b6:	e9 54 ff ff ff       	jmp    c010290f <__alltraps>

c01029bb <vector16>:
.globl vector16
vector16:
  pushl $0
c01029bb:	6a 00                	push   $0x0
  pushl $16
c01029bd:	6a 10                	push   $0x10
  jmp __alltraps
c01029bf:	e9 4b ff ff ff       	jmp    c010290f <__alltraps>

c01029c4 <vector17>:
.globl vector17
vector17:
  pushl $17
c01029c4:	6a 11                	push   $0x11
  jmp __alltraps
c01029c6:	e9 44 ff ff ff       	jmp    c010290f <__alltraps>

c01029cb <vector18>:
.globl vector18
vector18:
  pushl $0
c01029cb:	6a 00                	push   $0x0
  pushl $18
c01029cd:	6a 12                	push   $0x12
  jmp __alltraps
c01029cf:	e9 3b ff ff ff       	jmp    c010290f <__alltraps>

c01029d4 <vector19>:
.globl vector19
vector19:
  pushl $0
c01029d4:	6a 00                	push   $0x0
  pushl $19
c01029d6:	6a 13                	push   $0x13
  jmp __alltraps
c01029d8:	e9 32 ff ff ff       	jmp    c010290f <__alltraps>

c01029dd <vector20>:
.globl vector20
vector20:
  pushl $0
c01029dd:	6a 00                	push   $0x0
  pushl $20
c01029df:	6a 14                	push   $0x14
  jmp __alltraps
c01029e1:	e9 29 ff ff ff       	jmp    c010290f <__alltraps>

c01029e6 <vector21>:
.globl vector21
vector21:
  pushl $0
c01029e6:	6a 00                	push   $0x0
  pushl $21
c01029e8:	6a 15                	push   $0x15
  jmp __alltraps
c01029ea:	e9 20 ff ff ff       	jmp    c010290f <__alltraps>

c01029ef <vector22>:
.globl vector22
vector22:
  pushl $0
c01029ef:	6a 00                	push   $0x0
  pushl $22
c01029f1:	6a 16                	push   $0x16
  jmp __alltraps
c01029f3:	e9 17 ff ff ff       	jmp    c010290f <__alltraps>

c01029f8 <vector23>:
.globl vector23
vector23:
  pushl $0
c01029f8:	6a 00                	push   $0x0
  pushl $23
c01029fa:	6a 17                	push   $0x17
  jmp __alltraps
c01029fc:	e9 0e ff ff ff       	jmp    c010290f <__alltraps>

c0102a01 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102a01:	6a 00                	push   $0x0
  pushl $24
c0102a03:	6a 18                	push   $0x18
  jmp __alltraps
c0102a05:	e9 05 ff ff ff       	jmp    c010290f <__alltraps>

c0102a0a <vector25>:
.globl vector25
vector25:
  pushl $0
c0102a0a:	6a 00                	push   $0x0
  pushl $25
c0102a0c:	6a 19                	push   $0x19
  jmp __alltraps
c0102a0e:	e9 fc fe ff ff       	jmp    c010290f <__alltraps>

c0102a13 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102a13:	6a 00                	push   $0x0
  pushl $26
c0102a15:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102a17:	e9 f3 fe ff ff       	jmp    c010290f <__alltraps>

c0102a1c <vector27>:
.globl vector27
vector27:
  pushl $0
c0102a1c:	6a 00                	push   $0x0
  pushl $27
c0102a1e:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102a20:	e9 ea fe ff ff       	jmp    c010290f <__alltraps>

c0102a25 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102a25:	6a 00                	push   $0x0
  pushl $28
c0102a27:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102a29:	e9 e1 fe ff ff       	jmp    c010290f <__alltraps>

c0102a2e <vector29>:
.globl vector29
vector29:
  pushl $0
c0102a2e:	6a 00                	push   $0x0
  pushl $29
c0102a30:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102a32:	e9 d8 fe ff ff       	jmp    c010290f <__alltraps>

c0102a37 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102a37:	6a 00                	push   $0x0
  pushl $30
c0102a39:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102a3b:	e9 cf fe ff ff       	jmp    c010290f <__alltraps>

c0102a40 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102a40:	6a 00                	push   $0x0
  pushl $31
c0102a42:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102a44:	e9 c6 fe ff ff       	jmp    c010290f <__alltraps>

c0102a49 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102a49:	6a 00                	push   $0x0
  pushl $32
c0102a4b:	6a 20                	push   $0x20
  jmp __alltraps
c0102a4d:	e9 bd fe ff ff       	jmp    c010290f <__alltraps>

c0102a52 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102a52:	6a 00                	push   $0x0
  pushl $33
c0102a54:	6a 21                	push   $0x21
  jmp __alltraps
c0102a56:	e9 b4 fe ff ff       	jmp    c010290f <__alltraps>

c0102a5b <vector34>:
.globl vector34
vector34:
  pushl $0
c0102a5b:	6a 00                	push   $0x0
  pushl $34
c0102a5d:	6a 22                	push   $0x22
  jmp __alltraps
c0102a5f:	e9 ab fe ff ff       	jmp    c010290f <__alltraps>

c0102a64 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102a64:	6a 00                	push   $0x0
  pushl $35
c0102a66:	6a 23                	push   $0x23
  jmp __alltraps
c0102a68:	e9 a2 fe ff ff       	jmp    c010290f <__alltraps>

c0102a6d <vector36>:
.globl vector36
vector36:
  pushl $0
c0102a6d:	6a 00                	push   $0x0
  pushl $36
c0102a6f:	6a 24                	push   $0x24
  jmp __alltraps
c0102a71:	e9 99 fe ff ff       	jmp    c010290f <__alltraps>

c0102a76 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102a76:	6a 00                	push   $0x0
  pushl $37
c0102a78:	6a 25                	push   $0x25
  jmp __alltraps
c0102a7a:	e9 90 fe ff ff       	jmp    c010290f <__alltraps>

c0102a7f <vector38>:
.globl vector38
vector38:
  pushl $0
c0102a7f:	6a 00                	push   $0x0
  pushl $38
c0102a81:	6a 26                	push   $0x26
  jmp __alltraps
c0102a83:	e9 87 fe ff ff       	jmp    c010290f <__alltraps>

c0102a88 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102a88:	6a 00                	push   $0x0
  pushl $39
c0102a8a:	6a 27                	push   $0x27
  jmp __alltraps
c0102a8c:	e9 7e fe ff ff       	jmp    c010290f <__alltraps>

c0102a91 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102a91:	6a 00                	push   $0x0
  pushl $40
c0102a93:	6a 28                	push   $0x28
  jmp __alltraps
c0102a95:	e9 75 fe ff ff       	jmp    c010290f <__alltraps>

c0102a9a <vector41>:
.globl vector41
vector41:
  pushl $0
c0102a9a:	6a 00                	push   $0x0
  pushl $41
c0102a9c:	6a 29                	push   $0x29
  jmp __alltraps
c0102a9e:	e9 6c fe ff ff       	jmp    c010290f <__alltraps>

c0102aa3 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102aa3:	6a 00                	push   $0x0
  pushl $42
c0102aa5:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102aa7:	e9 63 fe ff ff       	jmp    c010290f <__alltraps>

c0102aac <vector43>:
.globl vector43
vector43:
  pushl $0
c0102aac:	6a 00                	push   $0x0
  pushl $43
c0102aae:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102ab0:	e9 5a fe ff ff       	jmp    c010290f <__alltraps>

c0102ab5 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102ab5:	6a 00                	push   $0x0
  pushl $44
c0102ab7:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102ab9:	e9 51 fe ff ff       	jmp    c010290f <__alltraps>

c0102abe <vector45>:
.globl vector45
vector45:
  pushl $0
c0102abe:	6a 00                	push   $0x0
  pushl $45
c0102ac0:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102ac2:	e9 48 fe ff ff       	jmp    c010290f <__alltraps>

c0102ac7 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102ac7:	6a 00                	push   $0x0
  pushl $46
c0102ac9:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102acb:	e9 3f fe ff ff       	jmp    c010290f <__alltraps>

c0102ad0 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102ad0:	6a 00                	push   $0x0
  pushl $47
c0102ad2:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102ad4:	e9 36 fe ff ff       	jmp    c010290f <__alltraps>

c0102ad9 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102ad9:	6a 00                	push   $0x0
  pushl $48
c0102adb:	6a 30                	push   $0x30
  jmp __alltraps
c0102add:	e9 2d fe ff ff       	jmp    c010290f <__alltraps>

c0102ae2 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102ae2:	6a 00                	push   $0x0
  pushl $49
c0102ae4:	6a 31                	push   $0x31
  jmp __alltraps
c0102ae6:	e9 24 fe ff ff       	jmp    c010290f <__alltraps>

c0102aeb <vector50>:
.globl vector50
vector50:
  pushl $0
c0102aeb:	6a 00                	push   $0x0
  pushl $50
c0102aed:	6a 32                	push   $0x32
  jmp __alltraps
c0102aef:	e9 1b fe ff ff       	jmp    c010290f <__alltraps>

c0102af4 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102af4:	6a 00                	push   $0x0
  pushl $51
c0102af6:	6a 33                	push   $0x33
  jmp __alltraps
c0102af8:	e9 12 fe ff ff       	jmp    c010290f <__alltraps>

c0102afd <vector52>:
.globl vector52
vector52:
  pushl $0
c0102afd:	6a 00                	push   $0x0
  pushl $52
c0102aff:	6a 34                	push   $0x34
  jmp __alltraps
c0102b01:	e9 09 fe ff ff       	jmp    c010290f <__alltraps>

c0102b06 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102b06:	6a 00                	push   $0x0
  pushl $53
c0102b08:	6a 35                	push   $0x35
  jmp __alltraps
c0102b0a:	e9 00 fe ff ff       	jmp    c010290f <__alltraps>

c0102b0f <vector54>:
.globl vector54
vector54:
  pushl $0
c0102b0f:	6a 00                	push   $0x0
  pushl $54
c0102b11:	6a 36                	push   $0x36
  jmp __alltraps
c0102b13:	e9 f7 fd ff ff       	jmp    c010290f <__alltraps>

c0102b18 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102b18:	6a 00                	push   $0x0
  pushl $55
c0102b1a:	6a 37                	push   $0x37
  jmp __alltraps
c0102b1c:	e9 ee fd ff ff       	jmp    c010290f <__alltraps>

c0102b21 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102b21:	6a 00                	push   $0x0
  pushl $56
c0102b23:	6a 38                	push   $0x38
  jmp __alltraps
c0102b25:	e9 e5 fd ff ff       	jmp    c010290f <__alltraps>

c0102b2a <vector57>:
.globl vector57
vector57:
  pushl $0
c0102b2a:	6a 00                	push   $0x0
  pushl $57
c0102b2c:	6a 39                	push   $0x39
  jmp __alltraps
c0102b2e:	e9 dc fd ff ff       	jmp    c010290f <__alltraps>

c0102b33 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102b33:	6a 00                	push   $0x0
  pushl $58
c0102b35:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102b37:	e9 d3 fd ff ff       	jmp    c010290f <__alltraps>

c0102b3c <vector59>:
.globl vector59
vector59:
  pushl $0
c0102b3c:	6a 00                	push   $0x0
  pushl $59
c0102b3e:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102b40:	e9 ca fd ff ff       	jmp    c010290f <__alltraps>

c0102b45 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102b45:	6a 00                	push   $0x0
  pushl $60
c0102b47:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102b49:	e9 c1 fd ff ff       	jmp    c010290f <__alltraps>

c0102b4e <vector61>:
.globl vector61
vector61:
  pushl $0
c0102b4e:	6a 00                	push   $0x0
  pushl $61
c0102b50:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102b52:	e9 b8 fd ff ff       	jmp    c010290f <__alltraps>

c0102b57 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102b57:	6a 00                	push   $0x0
  pushl $62
c0102b59:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102b5b:	e9 af fd ff ff       	jmp    c010290f <__alltraps>

c0102b60 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102b60:	6a 00                	push   $0x0
  pushl $63
c0102b62:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102b64:	e9 a6 fd ff ff       	jmp    c010290f <__alltraps>

c0102b69 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102b69:	6a 00                	push   $0x0
  pushl $64
c0102b6b:	6a 40                	push   $0x40
  jmp __alltraps
c0102b6d:	e9 9d fd ff ff       	jmp    c010290f <__alltraps>

c0102b72 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102b72:	6a 00                	push   $0x0
  pushl $65
c0102b74:	6a 41                	push   $0x41
  jmp __alltraps
c0102b76:	e9 94 fd ff ff       	jmp    c010290f <__alltraps>

c0102b7b <vector66>:
.globl vector66
vector66:
  pushl $0
c0102b7b:	6a 00                	push   $0x0
  pushl $66
c0102b7d:	6a 42                	push   $0x42
  jmp __alltraps
c0102b7f:	e9 8b fd ff ff       	jmp    c010290f <__alltraps>

c0102b84 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102b84:	6a 00                	push   $0x0
  pushl $67
c0102b86:	6a 43                	push   $0x43
  jmp __alltraps
c0102b88:	e9 82 fd ff ff       	jmp    c010290f <__alltraps>

c0102b8d <vector68>:
.globl vector68
vector68:
  pushl $0
c0102b8d:	6a 00                	push   $0x0
  pushl $68
c0102b8f:	6a 44                	push   $0x44
  jmp __alltraps
c0102b91:	e9 79 fd ff ff       	jmp    c010290f <__alltraps>

c0102b96 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102b96:	6a 00                	push   $0x0
  pushl $69
c0102b98:	6a 45                	push   $0x45
  jmp __alltraps
c0102b9a:	e9 70 fd ff ff       	jmp    c010290f <__alltraps>

c0102b9f <vector70>:
.globl vector70
vector70:
  pushl $0
c0102b9f:	6a 00                	push   $0x0
  pushl $70
c0102ba1:	6a 46                	push   $0x46
  jmp __alltraps
c0102ba3:	e9 67 fd ff ff       	jmp    c010290f <__alltraps>

c0102ba8 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102ba8:	6a 00                	push   $0x0
  pushl $71
c0102baa:	6a 47                	push   $0x47
  jmp __alltraps
c0102bac:	e9 5e fd ff ff       	jmp    c010290f <__alltraps>

c0102bb1 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102bb1:	6a 00                	push   $0x0
  pushl $72
c0102bb3:	6a 48                	push   $0x48
  jmp __alltraps
c0102bb5:	e9 55 fd ff ff       	jmp    c010290f <__alltraps>

c0102bba <vector73>:
.globl vector73
vector73:
  pushl $0
c0102bba:	6a 00                	push   $0x0
  pushl $73
c0102bbc:	6a 49                	push   $0x49
  jmp __alltraps
c0102bbe:	e9 4c fd ff ff       	jmp    c010290f <__alltraps>

c0102bc3 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102bc3:	6a 00                	push   $0x0
  pushl $74
c0102bc5:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102bc7:	e9 43 fd ff ff       	jmp    c010290f <__alltraps>

c0102bcc <vector75>:
.globl vector75
vector75:
  pushl $0
c0102bcc:	6a 00                	push   $0x0
  pushl $75
c0102bce:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102bd0:	e9 3a fd ff ff       	jmp    c010290f <__alltraps>

c0102bd5 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102bd5:	6a 00                	push   $0x0
  pushl $76
c0102bd7:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102bd9:	e9 31 fd ff ff       	jmp    c010290f <__alltraps>

c0102bde <vector77>:
.globl vector77
vector77:
  pushl $0
c0102bde:	6a 00                	push   $0x0
  pushl $77
c0102be0:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102be2:	e9 28 fd ff ff       	jmp    c010290f <__alltraps>

c0102be7 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102be7:	6a 00                	push   $0x0
  pushl $78
c0102be9:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102beb:	e9 1f fd ff ff       	jmp    c010290f <__alltraps>

c0102bf0 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102bf0:	6a 00                	push   $0x0
  pushl $79
c0102bf2:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102bf4:	e9 16 fd ff ff       	jmp    c010290f <__alltraps>

c0102bf9 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102bf9:	6a 00                	push   $0x0
  pushl $80
c0102bfb:	6a 50                	push   $0x50
  jmp __alltraps
c0102bfd:	e9 0d fd ff ff       	jmp    c010290f <__alltraps>

c0102c02 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102c02:	6a 00                	push   $0x0
  pushl $81
c0102c04:	6a 51                	push   $0x51
  jmp __alltraps
c0102c06:	e9 04 fd ff ff       	jmp    c010290f <__alltraps>

c0102c0b <vector82>:
.globl vector82
vector82:
  pushl $0
c0102c0b:	6a 00                	push   $0x0
  pushl $82
c0102c0d:	6a 52                	push   $0x52
  jmp __alltraps
c0102c0f:	e9 fb fc ff ff       	jmp    c010290f <__alltraps>

c0102c14 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102c14:	6a 00                	push   $0x0
  pushl $83
c0102c16:	6a 53                	push   $0x53
  jmp __alltraps
c0102c18:	e9 f2 fc ff ff       	jmp    c010290f <__alltraps>

c0102c1d <vector84>:
.globl vector84
vector84:
  pushl $0
c0102c1d:	6a 00                	push   $0x0
  pushl $84
c0102c1f:	6a 54                	push   $0x54
  jmp __alltraps
c0102c21:	e9 e9 fc ff ff       	jmp    c010290f <__alltraps>

c0102c26 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102c26:	6a 00                	push   $0x0
  pushl $85
c0102c28:	6a 55                	push   $0x55
  jmp __alltraps
c0102c2a:	e9 e0 fc ff ff       	jmp    c010290f <__alltraps>

c0102c2f <vector86>:
.globl vector86
vector86:
  pushl $0
c0102c2f:	6a 00                	push   $0x0
  pushl $86
c0102c31:	6a 56                	push   $0x56
  jmp __alltraps
c0102c33:	e9 d7 fc ff ff       	jmp    c010290f <__alltraps>

c0102c38 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102c38:	6a 00                	push   $0x0
  pushl $87
c0102c3a:	6a 57                	push   $0x57
  jmp __alltraps
c0102c3c:	e9 ce fc ff ff       	jmp    c010290f <__alltraps>

c0102c41 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102c41:	6a 00                	push   $0x0
  pushl $88
c0102c43:	6a 58                	push   $0x58
  jmp __alltraps
c0102c45:	e9 c5 fc ff ff       	jmp    c010290f <__alltraps>

c0102c4a <vector89>:
.globl vector89
vector89:
  pushl $0
c0102c4a:	6a 00                	push   $0x0
  pushl $89
c0102c4c:	6a 59                	push   $0x59
  jmp __alltraps
c0102c4e:	e9 bc fc ff ff       	jmp    c010290f <__alltraps>

c0102c53 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102c53:	6a 00                	push   $0x0
  pushl $90
c0102c55:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102c57:	e9 b3 fc ff ff       	jmp    c010290f <__alltraps>

c0102c5c <vector91>:
.globl vector91
vector91:
  pushl $0
c0102c5c:	6a 00                	push   $0x0
  pushl $91
c0102c5e:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102c60:	e9 aa fc ff ff       	jmp    c010290f <__alltraps>

c0102c65 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102c65:	6a 00                	push   $0x0
  pushl $92
c0102c67:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102c69:	e9 a1 fc ff ff       	jmp    c010290f <__alltraps>

c0102c6e <vector93>:
.globl vector93
vector93:
  pushl $0
c0102c6e:	6a 00                	push   $0x0
  pushl $93
c0102c70:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102c72:	e9 98 fc ff ff       	jmp    c010290f <__alltraps>

c0102c77 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102c77:	6a 00                	push   $0x0
  pushl $94
c0102c79:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102c7b:	e9 8f fc ff ff       	jmp    c010290f <__alltraps>

c0102c80 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102c80:	6a 00                	push   $0x0
  pushl $95
c0102c82:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102c84:	e9 86 fc ff ff       	jmp    c010290f <__alltraps>

c0102c89 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102c89:	6a 00                	push   $0x0
  pushl $96
c0102c8b:	6a 60                	push   $0x60
  jmp __alltraps
c0102c8d:	e9 7d fc ff ff       	jmp    c010290f <__alltraps>

c0102c92 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102c92:	6a 00                	push   $0x0
  pushl $97
c0102c94:	6a 61                	push   $0x61
  jmp __alltraps
c0102c96:	e9 74 fc ff ff       	jmp    c010290f <__alltraps>

c0102c9b <vector98>:
.globl vector98
vector98:
  pushl $0
c0102c9b:	6a 00                	push   $0x0
  pushl $98
c0102c9d:	6a 62                	push   $0x62
  jmp __alltraps
c0102c9f:	e9 6b fc ff ff       	jmp    c010290f <__alltraps>

c0102ca4 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102ca4:	6a 00                	push   $0x0
  pushl $99
c0102ca6:	6a 63                	push   $0x63
  jmp __alltraps
c0102ca8:	e9 62 fc ff ff       	jmp    c010290f <__alltraps>

c0102cad <vector100>:
.globl vector100
vector100:
  pushl $0
c0102cad:	6a 00                	push   $0x0
  pushl $100
c0102caf:	6a 64                	push   $0x64
  jmp __alltraps
c0102cb1:	e9 59 fc ff ff       	jmp    c010290f <__alltraps>

c0102cb6 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102cb6:	6a 00                	push   $0x0
  pushl $101
c0102cb8:	6a 65                	push   $0x65
  jmp __alltraps
c0102cba:	e9 50 fc ff ff       	jmp    c010290f <__alltraps>

c0102cbf <vector102>:
.globl vector102
vector102:
  pushl $0
c0102cbf:	6a 00                	push   $0x0
  pushl $102
c0102cc1:	6a 66                	push   $0x66
  jmp __alltraps
c0102cc3:	e9 47 fc ff ff       	jmp    c010290f <__alltraps>

c0102cc8 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102cc8:	6a 00                	push   $0x0
  pushl $103
c0102cca:	6a 67                	push   $0x67
  jmp __alltraps
c0102ccc:	e9 3e fc ff ff       	jmp    c010290f <__alltraps>

c0102cd1 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102cd1:	6a 00                	push   $0x0
  pushl $104
c0102cd3:	6a 68                	push   $0x68
  jmp __alltraps
c0102cd5:	e9 35 fc ff ff       	jmp    c010290f <__alltraps>

c0102cda <vector105>:
.globl vector105
vector105:
  pushl $0
c0102cda:	6a 00                	push   $0x0
  pushl $105
c0102cdc:	6a 69                	push   $0x69
  jmp __alltraps
c0102cde:	e9 2c fc ff ff       	jmp    c010290f <__alltraps>

c0102ce3 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102ce3:	6a 00                	push   $0x0
  pushl $106
c0102ce5:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102ce7:	e9 23 fc ff ff       	jmp    c010290f <__alltraps>

c0102cec <vector107>:
.globl vector107
vector107:
  pushl $0
c0102cec:	6a 00                	push   $0x0
  pushl $107
c0102cee:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102cf0:	e9 1a fc ff ff       	jmp    c010290f <__alltraps>

c0102cf5 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102cf5:	6a 00                	push   $0x0
  pushl $108
c0102cf7:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102cf9:	e9 11 fc ff ff       	jmp    c010290f <__alltraps>

c0102cfe <vector109>:
.globl vector109
vector109:
  pushl $0
c0102cfe:	6a 00                	push   $0x0
  pushl $109
c0102d00:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102d02:	e9 08 fc ff ff       	jmp    c010290f <__alltraps>

c0102d07 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102d07:	6a 00                	push   $0x0
  pushl $110
c0102d09:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102d0b:	e9 ff fb ff ff       	jmp    c010290f <__alltraps>

c0102d10 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102d10:	6a 00                	push   $0x0
  pushl $111
c0102d12:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102d14:	e9 f6 fb ff ff       	jmp    c010290f <__alltraps>

c0102d19 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102d19:	6a 00                	push   $0x0
  pushl $112
c0102d1b:	6a 70                	push   $0x70
  jmp __alltraps
c0102d1d:	e9 ed fb ff ff       	jmp    c010290f <__alltraps>

c0102d22 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102d22:	6a 00                	push   $0x0
  pushl $113
c0102d24:	6a 71                	push   $0x71
  jmp __alltraps
c0102d26:	e9 e4 fb ff ff       	jmp    c010290f <__alltraps>

c0102d2b <vector114>:
.globl vector114
vector114:
  pushl $0
c0102d2b:	6a 00                	push   $0x0
  pushl $114
c0102d2d:	6a 72                	push   $0x72
  jmp __alltraps
c0102d2f:	e9 db fb ff ff       	jmp    c010290f <__alltraps>

c0102d34 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102d34:	6a 00                	push   $0x0
  pushl $115
c0102d36:	6a 73                	push   $0x73
  jmp __alltraps
c0102d38:	e9 d2 fb ff ff       	jmp    c010290f <__alltraps>

c0102d3d <vector116>:
.globl vector116
vector116:
  pushl $0
c0102d3d:	6a 00                	push   $0x0
  pushl $116
c0102d3f:	6a 74                	push   $0x74
  jmp __alltraps
c0102d41:	e9 c9 fb ff ff       	jmp    c010290f <__alltraps>

c0102d46 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102d46:	6a 00                	push   $0x0
  pushl $117
c0102d48:	6a 75                	push   $0x75
  jmp __alltraps
c0102d4a:	e9 c0 fb ff ff       	jmp    c010290f <__alltraps>

c0102d4f <vector118>:
.globl vector118
vector118:
  pushl $0
c0102d4f:	6a 00                	push   $0x0
  pushl $118
c0102d51:	6a 76                	push   $0x76
  jmp __alltraps
c0102d53:	e9 b7 fb ff ff       	jmp    c010290f <__alltraps>

c0102d58 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102d58:	6a 00                	push   $0x0
  pushl $119
c0102d5a:	6a 77                	push   $0x77
  jmp __alltraps
c0102d5c:	e9 ae fb ff ff       	jmp    c010290f <__alltraps>

c0102d61 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102d61:	6a 00                	push   $0x0
  pushl $120
c0102d63:	6a 78                	push   $0x78
  jmp __alltraps
c0102d65:	e9 a5 fb ff ff       	jmp    c010290f <__alltraps>

c0102d6a <vector121>:
.globl vector121
vector121:
  pushl $0
c0102d6a:	6a 00                	push   $0x0
  pushl $121
c0102d6c:	6a 79                	push   $0x79
  jmp __alltraps
c0102d6e:	e9 9c fb ff ff       	jmp    c010290f <__alltraps>

c0102d73 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102d73:	6a 00                	push   $0x0
  pushl $122
c0102d75:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102d77:	e9 93 fb ff ff       	jmp    c010290f <__alltraps>

c0102d7c <vector123>:
.globl vector123
vector123:
  pushl $0
c0102d7c:	6a 00                	push   $0x0
  pushl $123
c0102d7e:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102d80:	e9 8a fb ff ff       	jmp    c010290f <__alltraps>

c0102d85 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102d85:	6a 00                	push   $0x0
  pushl $124
c0102d87:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102d89:	e9 81 fb ff ff       	jmp    c010290f <__alltraps>

c0102d8e <vector125>:
.globl vector125
vector125:
  pushl $0
c0102d8e:	6a 00                	push   $0x0
  pushl $125
c0102d90:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102d92:	e9 78 fb ff ff       	jmp    c010290f <__alltraps>

c0102d97 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102d97:	6a 00                	push   $0x0
  pushl $126
c0102d99:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102d9b:	e9 6f fb ff ff       	jmp    c010290f <__alltraps>

c0102da0 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102da0:	6a 00                	push   $0x0
  pushl $127
c0102da2:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102da4:	e9 66 fb ff ff       	jmp    c010290f <__alltraps>

c0102da9 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102da9:	6a 00                	push   $0x0
  pushl $128
c0102dab:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102db0:	e9 5a fb ff ff       	jmp    c010290f <__alltraps>

c0102db5 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102db5:	6a 00                	push   $0x0
  pushl $129
c0102db7:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102dbc:	e9 4e fb ff ff       	jmp    c010290f <__alltraps>

c0102dc1 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $130
c0102dc3:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102dc8:	e9 42 fb ff ff       	jmp    c010290f <__alltraps>

c0102dcd <vector131>:
.globl vector131
vector131:
  pushl $0
c0102dcd:	6a 00                	push   $0x0
  pushl $131
c0102dcf:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102dd4:	e9 36 fb ff ff       	jmp    c010290f <__alltraps>

c0102dd9 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102dd9:	6a 00                	push   $0x0
  pushl $132
c0102ddb:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102de0:	e9 2a fb ff ff       	jmp    c010290f <__alltraps>

c0102de5 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $133
c0102de7:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102dec:	e9 1e fb ff ff       	jmp    c010290f <__alltraps>

c0102df1 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102df1:	6a 00                	push   $0x0
  pushl $134
c0102df3:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102df8:	e9 12 fb ff ff       	jmp    c010290f <__alltraps>

c0102dfd <vector135>:
.globl vector135
vector135:
  pushl $0
c0102dfd:	6a 00                	push   $0x0
  pushl $135
c0102dff:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102e04:	e9 06 fb ff ff       	jmp    c010290f <__alltraps>

c0102e09 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $136
c0102e0b:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102e10:	e9 fa fa ff ff       	jmp    c010290f <__alltraps>

c0102e15 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102e15:	6a 00                	push   $0x0
  pushl $137
c0102e17:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102e1c:	e9 ee fa ff ff       	jmp    c010290f <__alltraps>

c0102e21 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102e21:	6a 00                	push   $0x0
  pushl $138
c0102e23:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102e28:	e9 e2 fa ff ff       	jmp    c010290f <__alltraps>

c0102e2d <vector139>:
.globl vector139
vector139:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $139
c0102e2f:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102e34:	e9 d6 fa ff ff       	jmp    c010290f <__alltraps>

c0102e39 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102e39:	6a 00                	push   $0x0
  pushl $140
c0102e3b:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102e40:	e9 ca fa ff ff       	jmp    c010290f <__alltraps>

c0102e45 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102e45:	6a 00                	push   $0x0
  pushl $141
c0102e47:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102e4c:	e9 be fa ff ff       	jmp    c010290f <__alltraps>

c0102e51 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $142
c0102e53:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102e58:	e9 b2 fa ff ff       	jmp    c010290f <__alltraps>

c0102e5d <vector143>:
.globl vector143
vector143:
  pushl $0
c0102e5d:	6a 00                	push   $0x0
  pushl $143
c0102e5f:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102e64:	e9 a6 fa ff ff       	jmp    c010290f <__alltraps>

c0102e69 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102e69:	6a 00                	push   $0x0
  pushl $144
c0102e6b:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102e70:	e9 9a fa ff ff       	jmp    c010290f <__alltraps>

c0102e75 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $145
c0102e77:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102e7c:	e9 8e fa ff ff       	jmp    c010290f <__alltraps>

c0102e81 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102e81:	6a 00                	push   $0x0
  pushl $146
c0102e83:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102e88:	e9 82 fa ff ff       	jmp    c010290f <__alltraps>

c0102e8d <vector147>:
.globl vector147
vector147:
  pushl $0
c0102e8d:	6a 00                	push   $0x0
  pushl $147
c0102e8f:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102e94:	e9 76 fa ff ff       	jmp    c010290f <__alltraps>

c0102e99 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $148
c0102e9b:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102ea0:	e9 6a fa ff ff       	jmp    c010290f <__alltraps>

c0102ea5 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102ea5:	6a 00                	push   $0x0
  pushl $149
c0102ea7:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102eac:	e9 5e fa ff ff       	jmp    c010290f <__alltraps>

c0102eb1 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102eb1:	6a 00                	push   $0x0
  pushl $150
c0102eb3:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102eb8:	e9 52 fa ff ff       	jmp    c010290f <__alltraps>

c0102ebd <vector151>:
.globl vector151
vector151:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $151
c0102ebf:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102ec4:	e9 46 fa ff ff       	jmp    c010290f <__alltraps>

c0102ec9 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102ec9:	6a 00                	push   $0x0
  pushl $152
c0102ecb:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102ed0:	e9 3a fa ff ff       	jmp    c010290f <__alltraps>

c0102ed5 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102ed5:	6a 00                	push   $0x0
  pushl $153
c0102ed7:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102edc:	e9 2e fa ff ff       	jmp    c010290f <__alltraps>

c0102ee1 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $154
c0102ee3:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102ee8:	e9 22 fa ff ff       	jmp    c010290f <__alltraps>

c0102eed <vector155>:
.globl vector155
vector155:
  pushl $0
c0102eed:	6a 00                	push   $0x0
  pushl $155
c0102eef:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102ef4:	e9 16 fa ff ff       	jmp    c010290f <__alltraps>

c0102ef9 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102ef9:	6a 00                	push   $0x0
  pushl $156
c0102efb:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102f00:	e9 0a fa ff ff       	jmp    c010290f <__alltraps>

c0102f05 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $157
c0102f07:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102f0c:	e9 fe f9 ff ff       	jmp    c010290f <__alltraps>

c0102f11 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102f11:	6a 00                	push   $0x0
  pushl $158
c0102f13:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102f18:	e9 f2 f9 ff ff       	jmp    c010290f <__alltraps>

c0102f1d <vector159>:
.globl vector159
vector159:
  pushl $0
c0102f1d:	6a 00                	push   $0x0
  pushl $159
c0102f1f:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102f24:	e9 e6 f9 ff ff       	jmp    c010290f <__alltraps>

c0102f29 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $160
c0102f2b:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102f30:	e9 da f9 ff ff       	jmp    c010290f <__alltraps>

c0102f35 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102f35:	6a 00                	push   $0x0
  pushl $161
c0102f37:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102f3c:	e9 ce f9 ff ff       	jmp    c010290f <__alltraps>

c0102f41 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102f41:	6a 00                	push   $0x0
  pushl $162
c0102f43:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102f48:	e9 c2 f9 ff ff       	jmp    c010290f <__alltraps>

c0102f4d <vector163>:
.globl vector163
vector163:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $163
c0102f4f:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102f54:	e9 b6 f9 ff ff       	jmp    c010290f <__alltraps>

c0102f59 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102f59:	6a 00                	push   $0x0
  pushl $164
c0102f5b:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102f60:	e9 aa f9 ff ff       	jmp    c010290f <__alltraps>

c0102f65 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102f65:	6a 00                	push   $0x0
  pushl $165
c0102f67:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102f6c:	e9 9e f9 ff ff       	jmp    c010290f <__alltraps>

c0102f71 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $166
c0102f73:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102f78:	e9 92 f9 ff ff       	jmp    c010290f <__alltraps>

c0102f7d <vector167>:
.globl vector167
vector167:
  pushl $0
c0102f7d:	6a 00                	push   $0x0
  pushl $167
c0102f7f:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102f84:	e9 86 f9 ff ff       	jmp    c010290f <__alltraps>

c0102f89 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102f89:	6a 00                	push   $0x0
  pushl $168
c0102f8b:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102f90:	e9 7a f9 ff ff       	jmp    c010290f <__alltraps>

c0102f95 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $169
c0102f97:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102f9c:	e9 6e f9 ff ff       	jmp    c010290f <__alltraps>

c0102fa1 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102fa1:	6a 00                	push   $0x0
  pushl $170
c0102fa3:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102fa8:	e9 62 f9 ff ff       	jmp    c010290f <__alltraps>

c0102fad <vector171>:
.globl vector171
vector171:
  pushl $0
c0102fad:	6a 00                	push   $0x0
  pushl $171
c0102faf:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102fb4:	e9 56 f9 ff ff       	jmp    c010290f <__alltraps>

c0102fb9 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $172
c0102fbb:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102fc0:	e9 4a f9 ff ff       	jmp    c010290f <__alltraps>

c0102fc5 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102fc5:	6a 00                	push   $0x0
  pushl $173
c0102fc7:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102fcc:	e9 3e f9 ff ff       	jmp    c010290f <__alltraps>

c0102fd1 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102fd1:	6a 00                	push   $0x0
  pushl $174
c0102fd3:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102fd8:	e9 32 f9 ff ff       	jmp    c010290f <__alltraps>

c0102fdd <vector175>:
.globl vector175
vector175:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $175
c0102fdf:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102fe4:	e9 26 f9 ff ff       	jmp    c010290f <__alltraps>

c0102fe9 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102fe9:	6a 00                	push   $0x0
  pushl $176
c0102feb:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102ff0:	e9 1a f9 ff ff       	jmp    c010290f <__alltraps>

c0102ff5 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102ff5:	6a 00                	push   $0x0
  pushl $177
c0102ff7:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102ffc:	e9 0e f9 ff ff       	jmp    c010290f <__alltraps>

c0103001 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103001:	6a 00                	push   $0x0
  pushl $178
c0103003:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103008:	e9 02 f9 ff ff       	jmp    c010290f <__alltraps>

c010300d <vector179>:
.globl vector179
vector179:
  pushl $0
c010300d:	6a 00                	push   $0x0
  pushl $179
c010300f:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103014:	e9 f6 f8 ff ff       	jmp    c010290f <__alltraps>

c0103019 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103019:	6a 00                	push   $0x0
  pushl $180
c010301b:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103020:	e9 ea f8 ff ff       	jmp    c010290f <__alltraps>

c0103025 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103025:	6a 00                	push   $0x0
  pushl $181
c0103027:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010302c:	e9 de f8 ff ff       	jmp    c010290f <__alltraps>

c0103031 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103031:	6a 00                	push   $0x0
  pushl $182
c0103033:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0103038:	e9 d2 f8 ff ff       	jmp    c010290f <__alltraps>

c010303d <vector183>:
.globl vector183
vector183:
  pushl $0
c010303d:	6a 00                	push   $0x0
  pushl $183
c010303f:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0103044:	e9 c6 f8 ff ff       	jmp    c010290f <__alltraps>

c0103049 <vector184>:
.globl vector184
vector184:
  pushl $0
c0103049:	6a 00                	push   $0x0
  pushl $184
c010304b:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103050:	e9 ba f8 ff ff       	jmp    c010290f <__alltraps>

c0103055 <vector185>:
.globl vector185
vector185:
  pushl $0
c0103055:	6a 00                	push   $0x0
  pushl $185
c0103057:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010305c:	e9 ae f8 ff ff       	jmp    c010290f <__alltraps>

c0103061 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103061:	6a 00                	push   $0x0
  pushl $186
c0103063:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0103068:	e9 a2 f8 ff ff       	jmp    c010290f <__alltraps>

c010306d <vector187>:
.globl vector187
vector187:
  pushl $0
c010306d:	6a 00                	push   $0x0
  pushl $187
c010306f:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0103074:	e9 96 f8 ff ff       	jmp    c010290f <__alltraps>

c0103079 <vector188>:
.globl vector188
vector188:
  pushl $0
c0103079:	6a 00                	push   $0x0
  pushl $188
c010307b:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103080:	e9 8a f8 ff ff       	jmp    c010290f <__alltraps>

c0103085 <vector189>:
.globl vector189
vector189:
  pushl $0
c0103085:	6a 00                	push   $0x0
  pushl $189
c0103087:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010308c:	e9 7e f8 ff ff       	jmp    c010290f <__alltraps>

c0103091 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103091:	6a 00                	push   $0x0
  pushl $190
c0103093:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0103098:	e9 72 f8 ff ff       	jmp    c010290f <__alltraps>

c010309d <vector191>:
.globl vector191
vector191:
  pushl $0
c010309d:	6a 00                	push   $0x0
  pushl $191
c010309f:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01030a4:	e9 66 f8 ff ff       	jmp    c010290f <__alltraps>

c01030a9 <vector192>:
.globl vector192
vector192:
  pushl $0
c01030a9:	6a 00                	push   $0x0
  pushl $192
c01030ab:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01030b0:	e9 5a f8 ff ff       	jmp    c010290f <__alltraps>

c01030b5 <vector193>:
.globl vector193
vector193:
  pushl $0
c01030b5:	6a 00                	push   $0x0
  pushl $193
c01030b7:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01030bc:	e9 4e f8 ff ff       	jmp    c010290f <__alltraps>

c01030c1 <vector194>:
.globl vector194
vector194:
  pushl $0
c01030c1:	6a 00                	push   $0x0
  pushl $194
c01030c3:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01030c8:	e9 42 f8 ff ff       	jmp    c010290f <__alltraps>

c01030cd <vector195>:
.globl vector195
vector195:
  pushl $0
c01030cd:	6a 00                	push   $0x0
  pushl $195
c01030cf:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01030d4:	e9 36 f8 ff ff       	jmp    c010290f <__alltraps>

c01030d9 <vector196>:
.globl vector196
vector196:
  pushl $0
c01030d9:	6a 00                	push   $0x0
  pushl $196
c01030db:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01030e0:	e9 2a f8 ff ff       	jmp    c010290f <__alltraps>

c01030e5 <vector197>:
.globl vector197
vector197:
  pushl $0
c01030e5:	6a 00                	push   $0x0
  pushl $197
c01030e7:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01030ec:	e9 1e f8 ff ff       	jmp    c010290f <__alltraps>

c01030f1 <vector198>:
.globl vector198
vector198:
  pushl $0
c01030f1:	6a 00                	push   $0x0
  pushl $198
c01030f3:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01030f8:	e9 12 f8 ff ff       	jmp    c010290f <__alltraps>

c01030fd <vector199>:
.globl vector199
vector199:
  pushl $0
c01030fd:	6a 00                	push   $0x0
  pushl $199
c01030ff:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103104:	e9 06 f8 ff ff       	jmp    c010290f <__alltraps>

c0103109 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103109:	6a 00                	push   $0x0
  pushl $200
c010310b:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103110:	e9 fa f7 ff ff       	jmp    c010290f <__alltraps>

c0103115 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103115:	6a 00                	push   $0x0
  pushl $201
c0103117:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010311c:	e9 ee f7 ff ff       	jmp    c010290f <__alltraps>

c0103121 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103121:	6a 00                	push   $0x0
  pushl $202
c0103123:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103128:	e9 e2 f7 ff ff       	jmp    c010290f <__alltraps>

c010312d <vector203>:
.globl vector203
vector203:
  pushl $0
c010312d:	6a 00                	push   $0x0
  pushl $203
c010312f:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0103134:	e9 d6 f7 ff ff       	jmp    c010290f <__alltraps>

c0103139 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103139:	6a 00                	push   $0x0
  pushl $204
c010313b:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103140:	e9 ca f7 ff ff       	jmp    c010290f <__alltraps>

c0103145 <vector205>:
.globl vector205
vector205:
  pushl $0
c0103145:	6a 00                	push   $0x0
  pushl $205
c0103147:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010314c:	e9 be f7 ff ff       	jmp    c010290f <__alltraps>

c0103151 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103151:	6a 00                	push   $0x0
  pushl $206
c0103153:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0103158:	e9 b2 f7 ff ff       	jmp    c010290f <__alltraps>

c010315d <vector207>:
.globl vector207
vector207:
  pushl $0
c010315d:	6a 00                	push   $0x0
  pushl $207
c010315f:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0103164:	e9 a6 f7 ff ff       	jmp    c010290f <__alltraps>

c0103169 <vector208>:
.globl vector208
vector208:
  pushl $0
c0103169:	6a 00                	push   $0x0
  pushl $208
c010316b:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103170:	e9 9a f7 ff ff       	jmp    c010290f <__alltraps>

c0103175 <vector209>:
.globl vector209
vector209:
  pushl $0
c0103175:	6a 00                	push   $0x0
  pushl $209
c0103177:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010317c:	e9 8e f7 ff ff       	jmp    c010290f <__alltraps>

c0103181 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103181:	6a 00                	push   $0x0
  pushl $210
c0103183:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103188:	e9 82 f7 ff ff       	jmp    c010290f <__alltraps>

c010318d <vector211>:
.globl vector211
vector211:
  pushl $0
c010318d:	6a 00                	push   $0x0
  pushl $211
c010318f:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103194:	e9 76 f7 ff ff       	jmp    c010290f <__alltraps>

c0103199 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103199:	6a 00                	push   $0x0
  pushl $212
c010319b:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01031a0:	e9 6a f7 ff ff       	jmp    c010290f <__alltraps>

c01031a5 <vector213>:
.globl vector213
vector213:
  pushl $0
c01031a5:	6a 00                	push   $0x0
  pushl $213
c01031a7:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01031ac:	e9 5e f7 ff ff       	jmp    c010290f <__alltraps>

c01031b1 <vector214>:
.globl vector214
vector214:
  pushl $0
c01031b1:	6a 00                	push   $0x0
  pushl $214
c01031b3:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01031b8:	e9 52 f7 ff ff       	jmp    c010290f <__alltraps>

c01031bd <vector215>:
.globl vector215
vector215:
  pushl $0
c01031bd:	6a 00                	push   $0x0
  pushl $215
c01031bf:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01031c4:	e9 46 f7 ff ff       	jmp    c010290f <__alltraps>

c01031c9 <vector216>:
.globl vector216
vector216:
  pushl $0
c01031c9:	6a 00                	push   $0x0
  pushl $216
c01031cb:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01031d0:	e9 3a f7 ff ff       	jmp    c010290f <__alltraps>

c01031d5 <vector217>:
.globl vector217
vector217:
  pushl $0
c01031d5:	6a 00                	push   $0x0
  pushl $217
c01031d7:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01031dc:	e9 2e f7 ff ff       	jmp    c010290f <__alltraps>

c01031e1 <vector218>:
.globl vector218
vector218:
  pushl $0
c01031e1:	6a 00                	push   $0x0
  pushl $218
c01031e3:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01031e8:	e9 22 f7 ff ff       	jmp    c010290f <__alltraps>

c01031ed <vector219>:
.globl vector219
vector219:
  pushl $0
c01031ed:	6a 00                	push   $0x0
  pushl $219
c01031ef:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01031f4:	e9 16 f7 ff ff       	jmp    c010290f <__alltraps>

c01031f9 <vector220>:
.globl vector220
vector220:
  pushl $0
c01031f9:	6a 00                	push   $0x0
  pushl $220
c01031fb:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103200:	e9 0a f7 ff ff       	jmp    c010290f <__alltraps>

c0103205 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103205:	6a 00                	push   $0x0
  pushl $221
c0103207:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010320c:	e9 fe f6 ff ff       	jmp    c010290f <__alltraps>

c0103211 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103211:	6a 00                	push   $0x0
  pushl $222
c0103213:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103218:	e9 f2 f6 ff ff       	jmp    c010290f <__alltraps>

c010321d <vector223>:
.globl vector223
vector223:
  pushl $0
c010321d:	6a 00                	push   $0x0
  pushl $223
c010321f:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103224:	e9 e6 f6 ff ff       	jmp    c010290f <__alltraps>

c0103229 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103229:	6a 00                	push   $0x0
  pushl $224
c010322b:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103230:	e9 da f6 ff ff       	jmp    c010290f <__alltraps>

c0103235 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103235:	6a 00                	push   $0x0
  pushl $225
c0103237:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010323c:	e9 ce f6 ff ff       	jmp    c010290f <__alltraps>

c0103241 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103241:	6a 00                	push   $0x0
  pushl $226
c0103243:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103248:	e9 c2 f6 ff ff       	jmp    c010290f <__alltraps>

c010324d <vector227>:
.globl vector227
vector227:
  pushl $0
c010324d:	6a 00                	push   $0x0
  pushl $227
c010324f:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103254:	e9 b6 f6 ff ff       	jmp    c010290f <__alltraps>

c0103259 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103259:	6a 00                	push   $0x0
  pushl $228
c010325b:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103260:	e9 aa f6 ff ff       	jmp    c010290f <__alltraps>

c0103265 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103265:	6a 00                	push   $0x0
  pushl $229
c0103267:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010326c:	e9 9e f6 ff ff       	jmp    c010290f <__alltraps>

c0103271 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103271:	6a 00                	push   $0x0
  pushl $230
c0103273:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103278:	e9 92 f6 ff ff       	jmp    c010290f <__alltraps>

c010327d <vector231>:
.globl vector231
vector231:
  pushl $0
c010327d:	6a 00                	push   $0x0
  pushl $231
c010327f:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103284:	e9 86 f6 ff ff       	jmp    c010290f <__alltraps>

c0103289 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103289:	6a 00                	push   $0x0
  pushl $232
c010328b:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103290:	e9 7a f6 ff ff       	jmp    c010290f <__alltraps>

c0103295 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103295:	6a 00                	push   $0x0
  pushl $233
c0103297:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010329c:	e9 6e f6 ff ff       	jmp    c010290f <__alltraps>

c01032a1 <vector234>:
.globl vector234
vector234:
  pushl $0
c01032a1:	6a 00                	push   $0x0
  pushl $234
c01032a3:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01032a8:	e9 62 f6 ff ff       	jmp    c010290f <__alltraps>

c01032ad <vector235>:
.globl vector235
vector235:
  pushl $0
c01032ad:	6a 00                	push   $0x0
  pushl $235
c01032af:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01032b4:	e9 56 f6 ff ff       	jmp    c010290f <__alltraps>

c01032b9 <vector236>:
.globl vector236
vector236:
  pushl $0
c01032b9:	6a 00                	push   $0x0
  pushl $236
c01032bb:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01032c0:	e9 4a f6 ff ff       	jmp    c010290f <__alltraps>

c01032c5 <vector237>:
.globl vector237
vector237:
  pushl $0
c01032c5:	6a 00                	push   $0x0
  pushl $237
c01032c7:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01032cc:	e9 3e f6 ff ff       	jmp    c010290f <__alltraps>

c01032d1 <vector238>:
.globl vector238
vector238:
  pushl $0
c01032d1:	6a 00                	push   $0x0
  pushl $238
c01032d3:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01032d8:	e9 32 f6 ff ff       	jmp    c010290f <__alltraps>

c01032dd <vector239>:
.globl vector239
vector239:
  pushl $0
c01032dd:	6a 00                	push   $0x0
  pushl $239
c01032df:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01032e4:	e9 26 f6 ff ff       	jmp    c010290f <__alltraps>

c01032e9 <vector240>:
.globl vector240
vector240:
  pushl $0
c01032e9:	6a 00                	push   $0x0
  pushl $240
c01032eb:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01032f0:	e9 1a f6 ff ff       	jmp    c010290f <__alltraps>

c01032f5 <vector241>:
.globl vector241
vector241:
  pushl $0
c01032f5:	6a 00                	push   $0x0
  pushl $241
c01032f7:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01032fc:	e9 0e f6 ff ff       	jmp    c010290f <__alltraps>

c0103301 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103301:	6a 00                	push   $0x0
  pushl $242
c0103303:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103308:	e9 02 f6 ff ff       	jmp    c010290f <__alltraps>

c010330d <vector243>:
.globl vector243
vector243:
  pushl $0
c010330d:	6a 00                	push   $0x0
  pushl $243
c010330f:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103314:	e9 f6 f5 ff ff       	jmp    c010290f <__alltraps>

c0103319 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103319:	6a 00                	push   $0x0
  pushl $244
c010331b:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103320:	e9 ea f5 ff ff       	jmp    c010290f <__alltraps>

c0103325 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103325:	6a 00                	push   $0x0
  pushl $245
c0103327:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010332c:	e9 de f5 ff ff       	jmp    c010290f <__alltraps>

c0103331 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103331:	6a 00                	push   $0x0
  pushl $246
c0103333:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103338:	e9 d2 f5 ff ff       	jmp    c010290f <__alltraps>

c010333d <vector247>:
.globl vector247
vector247:
  pushl $0
c010333d:	6a 00                	push   $0x0
  pushl $247
c010333f:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103344:	e9 c6 f5 ff ff       	jmp    c010290f <__alltraps>

c0103349 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103349:	6a 00                	push   $0x0
  pushl $248
c010334b:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103350:	e9 ba f5 ff ff       	jmp    c010290f <__alltraps>

c0103355 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103355:	6a 00                	push   $0x0
  pushl $249
c0103357:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010335c:	e9 ae f5 ff ff       	jmp    c010290f <__alltraps>

c0103361 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103361:	6a 00                	push   $0x0
  pushl $250
c0103363:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103368:	e9 a2 f5 ff ff       	jmp    c010290f <__alltraps>

c010336d <vector251>:
.globl vector251
vector251:
  pushl $0
c010336d:	6a 00                	push   $0x0
  pushl $251
c010336f:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103374:	e9 96 f5 ff ff       	jmp    c010290f <__alltraps>

c0103379 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103379:	6a 00                	push   $0x0
  pushl $252
c010337b:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103380:	e9 8a f5 ff ff       	jmp    c010290f <__alltraps>

c0103385 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103385:	6a 00                	push   $0x0
  pushl $253
c0103387:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010338c:	e9 7e f5 ff ff       	jmp    c010290f <__alltraps>

c0103391 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103391:	6a 00                	push   $0x0
  pushl $254
c0103393:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103398:	e9 72 f5 ff ff       	jmp    c010290f <__alltraps>

c010339d <vector255>:
.globl vector255
vector255:
  pushl $0
c010339d:	6a 00                	push   $0x0
  pushl $255
c010339f:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01033a4:	e9 66 f5 ff ff       	jmp    c010290f <__alltraps>

c01033a9 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01033a9:	55                   	push   %ebp
c01033aa:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01033ac:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01033b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b5:	29 d0                	sub    %edx,%eax
c01033b7:	c1 f8 05             	sar    $0x5,%eax
}
c01033ba:	5d                   	pop    %ebp
c01033bb:	c3                   	ret    

c01033bc <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01033bc:	55                   	push   %ebp
c01033bd:	89 e5                	mov    %esp,%ebp
c01033bf:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01033c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01033c5:	89 04 24             	mov    %eax,(%esp)
c01033c8:	e8 dc ff ff ff       	call   c01033a9 <page2ppn>
c01033cd:	c1 e0 0c             	shl    $0xc,%eax
}
c01033d0:	89 ec                	mov    %ebp,%esp
c01033d2:	5d                   	pop    %ebp
c01033d3:	c3                   	ret    

c01033d4 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01033d4:	55                   	push   %ebp
c01033d5:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01033d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01033da:	8b 00                	mov    (%eax),%eax
}
c01033dc:	5d                   	pop    %ebp
c01033dd:	c3                   	ret    

c01033de <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01033de:	55                   	push   %ebp
c01033df:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01033e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01033e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01033e7:	89 10                	mov    %edx,(%eax)
}
c01033e9:	90                   	nop
c01033ea:	5d                   	pop    %ebp
c01033eb:	c3                   	ret    

c01033ec <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01033ec:	55                   	push   %ebp
c01033ed:	89 e5                	mov    %esp,%ebp
c01033ef:	83 ec 10             	sub    $0x10,%esp
c01033f2:	c7 45 fc 84 bf 12 c0 	movl   $0xc012bf84,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01033f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033fc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01033ff:	89 50 04             	mov    %edx,0x4(%eax)
c0103402:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103405:	8b 50 04             	mov    0x4(%eax),%edx
c0103408:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010340b:	89 10                	mov    %edx,(%eax)
}
c010340d:	90                   	nop
    list_init(&free_list);//空闲块链表
    nr_free = 0;//total number of the free memory blocks
c010340e:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0103415:	00 00 00 
}
c0103418:	90                   	nop
c0103419:	89 ec                	mov    %ebp,%esp
c010341b:	5d                   	pop    %ebp
c010341c:	c3                   	ret    

c010341d <default_init_memmap>:

static void//initialize a free block
default_init_memmap(struct Page *base, size_t n) {//参数：基地址、页数
c010341d:	55                   	push   %ebp
c010341e:	89 e5                	mov    %esp,%ebp
c0103420:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0103423:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103427:	75 24                	jne    c010344d <default_init_memmap+0x30>
c0103429:	c7 44 24 0c 10 aa 10 	movl   $0xc010aa10,0xc(%esp)
c0103430:	c0 
c0103431:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103438:	c0 
c0103439:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103440:	00 
c0103441:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103448:	e8 d9 d8 ff ff       	call   c0100d26 <__panic>
    struct Page *p = base;
c010344d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {//initialize each page
c0103453:	eb 7d                	jmp    c01034d2 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0103455:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103458:	83 c0 04             	add    $0x4,%eax
c010345b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0103462:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103468:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010346b:	0f a3 10             	bt     %edx,(%eax)
c010346e:	19 c0                	sbb    %eax,%eax
c0103470:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0103473:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103477:	0f 95 c0             	setne  %al
c010347a:	0f b6 c0             	movzbl %al,%eax
c010347d:	85 c0                	test   %eax,%eax
c010347f:	75 24                	jne    c01034a5 <default_init_memmap+0x88>
c0103481:	c7 44 24 0c 41 aa 10 	movl   $0xc010aa41,0xc(%esp)
c0103488:	c0 
c0103489:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103490:	c0 
c0103491:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0103498:	00 
c0103499:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c01034a0:	e8 81 d8 ff ff       	call   c0100d26 <__panic>
        /* - If this page is free and is not the first page of a free block,
        * `p->property` should be set to 0.*/
        p->flags = p->property = 0;//this page is valid
c01034a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034a8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01034af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b2:	8b 50 08             	mov    0x8(%eax),%edx
c01034b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b8:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);//p is free and has no reference
c01034bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01034c2:	00 
c01034c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034c6:	89 04 24             	mov    %eax,(%esp)
c01034c9:	e8 10 ff ff ff       	call   c01033de <set_page_ref>
    for (; p != base + n; p ++) {//initialize each page
c01034ce:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01034d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034d5:	c1 e0 05             	shl    $0x5,%eax
c01034d8:	89 c2                	mov    %eax,%edx
c01034da:	8b 45 08             	mov    0x8(%ebp),%eax
c01034dd:	01 d0                	add    %edx,%eax
c01034df:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01034e2:	0f 85 6d ff ff ff    	jne    c0103455 <default_init_memmap+0x38>
    }
    /*  - If this page is free and is the first page of a free block, `p->property`
    * should be set to be the total number of pages in the block.*/
    base->property = n;
c01034e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01034eb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01034ee:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);//the Page is the head page of a free memory block
c01034f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01034f4:	83 c0 04             	add    $0x4,%eax
c01034f7:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01034fe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103501:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103504:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0103507:	0f ab 10             	bts    %edx,(%eax)
}
c010350a:	90                   	nop
    nr_free += n;//update the sum of the free memory block
c010350b:	8b 15 8c bf 12 c0    	mov    0xc012bf8c,%edx
c0103511:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103514:	01 d0                	add    %edx,%eax
c0103516:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
    list_add(&free_list, &(base->page_link));//link this page into `free_list`
c010351b:	8b 45 08             	mov    0x8(%ebp),%eax
c010351e:	83 c0 0c             	add    $0xc,%eax
c0103521:	c7 45 e4 84 bf 12 c0 	movl   $0xc012bf84,-0x1c(%ebp)
c0103528:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010352b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010352e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103531:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103534:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103537:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010353a:	8b 40 04             	mov    0x4(%eax),%eax
c010353d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103540:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103543:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103546:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0103549:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010354c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010354f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103552:	89 10                	mov    %edx,(%eax)
c0103554:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103557:	8b 10                	mov    (%eax),%edx
c0103559:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010355c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010355f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103562:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103565:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010356b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010356e:	89 10                	mov    %edx,(%eax)
}
c0103570:	90                   	nop
}
c0103571:	90                   	nop
}
c0103572:	90                   	nop
}
c0103573:	90                   	nop
c0103574:	89 ec                	mov    %ebp,%esp
c0103576:	5d                   	pop    %ebp
c0103577:	c3                   	ret    

c0103578 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {//参数是页码数？
c0103578:	55                   	push   %ebp
c0103579:	89 e5                	mov    %esp,%ebp
c010357b:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c010357e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103582:	75 24                	jne    c01035a8 <default_alloc_pages+0x30>
c0103584:	c7 44 24 0c 10 aa 10 	movl   $0xc010aa10,0xc(%esp)
c010358b:	c0 
c010358c:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103593:	c0 
c0103594:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
c010359b:	00 
c010359c:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c01035a3:	e8 7e d7 ff ff       	call   c0100d26 <__panic>
    if (n > nr_free) {
c01035a8:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c01035ad:	39 45 08             	cmp    %eax,0x8(%ebp)
c01035b0:	76 0a                	jbe    c01035bc <default_alloc_pages+0x44>
        return NULL;
c01035b2:	b8 00 00 00 00       	mov    $0x0,%eax
c01035b7:	e9 56 01 00 00       	jmp    c0103712 <default_alloc_pages+0x19a>
    }
    struct Page *page = NULL;
c01035bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;//search the free list遍历（list是个双向循环链表）
c01035c3:	c7 45 f0 84 bf 12 c0 	movl   $0xc012bf84,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01035ca:	eb 1c                	jmp    c01035e8 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);// convert list entry to page 通过le2page宏可以由链表元素获得对应的Page指针p
c01035cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035cf:	83 e8 0c             	sub    $0xc,%eax
c01035d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {//找第一个空闲块数足够用的页，用page存起来
c01035d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035d8:	8b 40 08             	mov    0x8(%eax),%eax
c01035db:	39 45 08             	cmp    %eax,0x8(%ebp)
c01035de:	77 08                	ja     c01035e8 <default_alloc_pages+0x70>
            page = p;
c01035e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01035e6:	eb 18                	jmp    c0103600 <default_alloc_pages+0x88>
c01035e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01035ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035f1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01035f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01035f7:	81 7d f0 84 bf 12 c0 	cmpl   $0xc012bf84,-0x10(%ebp)
c01035fe:	75 cc                	jne    c01035cc <default_alloc_pages+0x54>
        }
    }
    if (page != NULL) {//If we find this `page`
c0103600:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103604:	0f 84 05 01 00 00    	je     c010370f <default_alloc_pages+0x197>
        if (page->property > n) {
c010360a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010360d:	8b 40 08             	mov    0x8(%eax),%eax
c0103610:	39 45 08             	cmp    %eax,0x8(%ebp)
c0103613:	0f 83 a2 00 00 00    	jae    c01036bb <default_alloc_pages+0x143>
            struct Page *p = page + n;//开辟n大小的块数来用(更新p的位置)
c0103619:	8b 45 08             	mov    0x8(%ebp),%eax
c010361c:	c1 e0 05             	shl    $0x5,%eax
c010361f:	89 c2                	mov    %eax,%edx
c0103621:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103624:	01 d0                	add    %edx,%eax
c0103626:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;//剩下的部分留给p(更新p->property)
c0103629:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010362c:	8b 40 08             	mov    0x8(%eax),%eax
c010362f:	2b 45 08             	sub    0x8(%ebp),%eax
c0103632:	89 c2                	mov    %eax,%edx
c0103634:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103637:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);//设置p的Page_property，表示是新的空闲块的起始页
c010363a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010363d:	83 c0 04             	add    $0x4,%eax
c0103640:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0103647:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010364a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010364d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103650:	0f ab 10             	bts    %edx,(%eax)
}
c0103653:	90                   	nop
            ClearPageReserved(p);
c0103654:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103657:	83 c0 04             	add    $0x4,%eax
c010365a:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c0103661:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103664:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103667:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010366a:	0f b3 10             	btr    %edx,(%eax)
}
c010366d:	90                   	nop
            list_add_after(&(page->page_link), &(p->page_link));//把剩下的p原位置链入空表
c010366e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103671:	83 c0 0c             	add    $0xc,%eax
c0103674:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103677:	83 c2 0c             	add    $0xc,%edx
c010367a:	89 55 e0             	mov    %edx,-0x20(%ebp)
c010367d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0103680:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103683:	8b 40 04             	mov    0x4(%eax),%eax
c0103686:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103689:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010368c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010368f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103692:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0103695:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103698:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010369b:	89 10                	mov    %edx,(%eax)
c010369d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01036a0:	8b 10                	mov    (%eax),%edx
c01036a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01036a5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01036a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01036ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01036ae:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01036b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01036b4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01036b7:	89 10                	mov    %edx,(%eax)
}
c01036b9:	90                   	nop
}
c01036ba:	90                   	nop
        }
        list_del(&(page->page_link));//用过的page从空表中删除
c01036bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036be:	83 c0 0c             	add    $0xc,%eax
c01036c1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01036c4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01036c7:	8b 40 04             	mov    0x4(%eax),%eax
c01036ca:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01036cd:	8b 12                	mov    (%edx),%edx
c01036cf:	89 55 b0             	mov    %edx,-0x50(%ebp)
c01036d2:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01036d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01036d8:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01036db:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01036de:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01036e1:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01036e4:	89 10                	mov    %edx,(%eax)
}
c01036e6:	90                   	nop
}
c01036e7:	90                   	nop
        nr_free -= n;//Re-caluclate `nr_free` 
c01036e8:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c01036ed:	2b 45 08             	sub    0x8(%ebp),%eax
c01036f0:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
        //SetPageReserved(page);
        ClearPageProperty(page);//`PG_property = 0`，page已被分配
c01036f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f8:	83 c0 04             	add    $0x4,%eax
c01036fb:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0103702:	89 45 b8             	mov    %eax,-0x48(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103705:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103708:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010370b:	0f b3 10             	btr    %edx,(%eax)
}
c010370e:	90                   	nop
    }
    return page;
c010370f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103712:	89 ec                	mov    %ebp,%esp
c0103714:	5d                   	pop    %ebp
c0103715:	c3                   	ret    

c0103716 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103716:	55                   	push   %ebp
c0103717:	89 e5                	mov    %esp,%ebp
c0103719:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010371f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103723:	75 24                	jne    c0103749 <default_free_pages+0x33>
c0103725:	c7 44 24 0c 10 aa 10 	movl   $0xc010aa10,0xc(%esp)
c010372c:	c0 
c010372d:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103734:	c0 
c0103735:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c010373c:	00 
c010373d:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103744:	e8 dd d5 ff ff       	call   c0100d26 <__panic>
    struct Page *p = base;
c0103749:	8b 45 08             	mov    0x8(%ebp),%eax
c010374c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010374f:	e9 9d 00 00 00       	jmp    c01037f1 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));//p是页表头地址，新开辟的空间，未被使用，
c0103754:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103757:	83 c0 04             	add    $0x4,%eax
c010375a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0103761:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103764:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103767:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010376a:	0f a3 10             	bt     %edx,(%eax)
c010376d:	19 c0                	sbb    %eax,%eax
c010376f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0103772:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103776:	0f 95 c0             	setne  %al
c0103779:	0f b6 c0             	movzbl %al,%eax
c010377c:	85 c0                	test   %eax,%eax
c010377e:	75 2c                	jne    c01037ac <default_free_pages+0x96>
c0103780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103783:	83 c0 04             	add    $0x4,%eax
c0103786:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010378d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103790:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103793:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103796:	0f a3 10             	bt     %edx,(%eax)
c0103799:	19 c0                	sbb    %eax,%eax
c010379b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010379e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01037a2:	0f 95 c0             	setne  %al
c01037a5:	0f b6 c0             	movzbl %al,%eax
c01037a8:	85 c0                	test   %eax,%eax
c01037aa:	74 24                	je     c01037d0 <default_free_pages+0xba>
c01037ac:	c7 44 24 0c 54 aa 10 	movl   $0xc010aa54,0xc(%esp)
c01037b3:	c0 
c01037b4:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c01037bb:	c0 
c01037bc:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
c01037c3:	00 
c01037c4:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c01037cb:	e8 56 d5 ff ff       	call   c0100d26 <__panic>
        //把p的内容都置零，后边进行整合
        p->flags = 0;//flags置零，可以分配
c01037d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037d3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);//ref置零，此页空闲
c01037da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01037e1:	00 
c01037e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037e5:	89 04 24             	mov    %eax,(%esp)
c01037e8:	e8 f1 fb ff ff       	call   c01033de <set_page_ref>
    for (; p != base + n; p ++) {
c01037ed:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01037f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037f4:	c1 e0 05             	shl    $0x5,%eax
c01037f7:	89 c2                	mov    %eax,%edx
c01037f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01037fc:	01 d0                	add    %edx,%eax
c01037fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103801:	0f 85 4d ff ff ff    	jne    c0103754 <default_free_pages+0x3e>
    }
    base->property = n;//base空闲页数
c0103807:	8b 45 08             	mov    0x8(%ebp),%eax
c010380a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010380d:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103810:	8b 45 08             	mov    0x8(%ebp),%eax
c0103813:	83 c0 04             	add    $0x4,%eax
c0103816:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010381d:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103820:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103823:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103826:	0f ab 10             	bts    %edx,(%eax)
}
c0103829:	90                   	nop
c010382a:	c7 45 d4 84 bf 12 c0 	movl   $0xc012bf84,-0x2c(%ebp)
    return listelm->next;
c0103831:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103834:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0103837:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {//遍历空表，查看能否进行块合并
c010383a:	e9 00 01 00 00       	jmp    c010393f <default_free_pages+0x229>
        p = le2page(le, page_link);
c010383f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103842:	83 e8 0c             	sub    $0xc,%eax
c0103845:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103848:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010384b:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010384e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103851:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103854:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {//合并高地址的块？
c0103857:	8b 45 08             	mov    0x8(%ebp),%eax
c010385a:	8b 40 08             	mov    0x8(%eax),%eax
c010385d:	c1 e0 05             	shl    $0x5,%eax
c0103860:	89 c2                	mov    %eax,%edx
c0103862:	8b 45 08             	mov    0x8(%ebp),%eax
c0103865:	01 d0                	add    %edx,%eax
c0103867:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010386a:	75 5d                	jne    c01038c9 <default_free_pages+0x1b3>
            base->property += p->property;//空页数相加更新
c010386c:	8b 45 08             	mov    0x8(%ebp),%eax
c010386f:	8b 50 08             	mov    0x8(%eax),%edx
c0103872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103875:	8b 40 08             	mov    0x8(%eax),%eax
c0103878:	01 c2                	add    %eax,%edx
c010387a:	8b 45 08             	mov    0x8(%ebp),%eax
c010387d:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);//p不再是空闲页起始块
c0103880:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103883:	83 c0 04             	add    $0x4,%eax
c0103886:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010388d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103890:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103893:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103896:	0f b3 10             	btr    %edx,(%eax)
}
c0103899:	90                   	nop
            list_del(&(p->page_link));//从链表中删除原来的页
c010389a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389d:	83 c0 0c             	add    $0xc,%eax
c01038a0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c01038a3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01038a6:	8b 40 04             	mov    0x4(%eax),%eax
c01038a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01038ac:	8b 12                	mov    (%edx),%edx
c01038ae:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01038b1:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c01038b4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01038b7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01038ba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01038bd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01038c0:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01038c3:	89 10                	mov    %edx,(%eax)
}
c01038c5:	90                   	nop
}
c01038c6:	90                   	nop
c01038c7:	eb 76                	jmp    c010393f <default_free_pages+0x229>
        }
        else if (p + p->property == base) {//合并低地址的块？
c01038c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038cc:	8b 40 08             	mov    0x8(%eax),%eax
c01038cf:	c1 e0 05             	shl    $0x5,%eax
c01038d2:	89 c2                	mov    %eax,%edx
c01038d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d7:	01 d0                	add    %edx,%eax
c01038d9:	39 45 08             	cmp    %eax,0x8(%ebp)
c01038dc:	75 61                	jne    c010393f <default_free_pages+0x229>
            p->property += base->property;
c01038de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038e1:	8b 50 08             	mov    0x8(%eax),%edx
c01038e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01038e7:	8b 40 08             	mov    0x8(%eax),%eax
c01038ea:	01 c2                	add    %eax,%edx
c01038ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038ef:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01038f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f5:	83 c0 04             	add    $0x4,%eax
c01038f8:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c01038ff:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103902:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103905:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103908:	0f b3 10             	btr    %edx,(%eax)
}
c010390b:	90                   	nop
            base = p;
c010390c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010390f:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103912:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103915:	83 c0 0c             	add    $0xc,%eax
c0103918:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c010391b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010391e:	8b 40 04             	mov    0x4(%eax),%eax
c0103921:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103924:	8b 12                	mov    (%edx),%edx
c0103926:	89 55 ac             	mov    %edx,-0x54(%ebp)
c0103929:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c010392c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010392f:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103932:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103935:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103938:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010393b:	89 10                	mov    %edx,(%eax)
}
c010393d:	90                   	nop
}
c010393e:	90                   	nop
    while (le != &free_list) {//遍历空表，查看能否进行块合并
c010393f:	81 7d f0 84 bf 12 c0 	cmpl   $0xc012bf84,-0x10(%ebp)
c0103946:	0f 85 f3 fe ff ff    	jne    c010383f <default_free_pages+0x129>
        }
    }
    nr_free += n;//Re-caluclate `nr_free`
c010394c:	8b 15 8c bf 12 c0    	mov    0xc012bf8c,%edx
c0103952:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103955:	01 d0                	add    %edx,%eax
c0103957:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
c010395c:	c7 45 9c 84 bf 12 c0 	movl   $0xc012bf84,-0x64(%ebp)
    return listelm->next;
c0103963:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103966:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0103969:	89 45 f0             	mov    %eax,-0x10(%ebp)
    //遍历链表，寻找合适的插入的位置
    while (le != &free_list) {
c010396c:	eb 2d                	jmp    c010399b <default_free_pages+0x285>
        p = le2page(le, page_link);
c010396e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103971:	83 e8 0c             	sub    $0xc,%eax
c0103974:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0103977:	8b 45 08             	mov    0x8(%ebp),%eax
c010397a:	8b 40 08             	mov    0x8(%eax),%eax
c010397d:	c1 e0 05             	shl    $0x5,%eax
c0103980:	89 c2                	mov    %eax,%edx
c0103982:	8b 45 08             	mov    0x8(%ebp),%eax
c0103985:	01 d0                	add    %edx,%eax
c0103987:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010398a:	73 1a                	jae    c01039a6 <default_free_pages+0x290>
c010398c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010398f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103992:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103995:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0103998:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010399b:	81 7d f0 84 bf 12 c0 	cmpl   $0xc012bf84,-0x10(%ebp)
c01039a2:	75 ca                	jne    c010396e <default_free_pages+0x258>
c01039a4:	eb 01                	jmp    c01039a7 <default_free_pages+0x291>
            break;
c01039a6:	90                   	nop
    }
    list_add_before(le, &(base->page_link));
c01039a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01039aa:	8d 50 0c             	lea    0xc(%eax),%edx
c01039ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039b0:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01039b3:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01039b6:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01039b9:	8b 00                	mov    (%eax),%eax
c01039bb:	8b 55 90             	mov    -0x70(%ebp),%edx
c01039be:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01039c1:	89 45 88             	mov    %eax,-0x78(%ebp)
c01039c4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01039c7:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c01039ca:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01039cd:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01039d0:	89 10                	mov    %edx,(%eax)
c01039d2:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01039d5:	8b 10                	mov    (%eax),%edx
c01039d7:	8b 45 88             	mov    -0x78(%ebp),%eax
c01039da:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01039dd:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01039e0:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01039e3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01039e6:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01039e9:	8b 55 88             	mov    -0x78(%ebp),%edx
c01039ec:	89 10                	mov    %edx,(%eax)
}
c01039ee:	90                   	nop
}
c01039ef:	90                   	nop
}
c01039f0:	90                   	nop
c01039f1:	89 ec                	mov    %ebp,%esp
c01039f3:	5d                   	pop    %ebp
c01039f4:	c3                   	ret    

c01039f5 <default_nr_free_pages>:
static size_t
default_nr_free_pages(void) {
c01039f5:	55                   	push   %ebp
c01039f6:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01039f8:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
}
c01039fd:	5d                   	pop    %ebp
c01039fe:	c3                   	ret    

c01039ff <basic_check>:

static void
basic_check(void) {
c01039ff:	55                   	push   %ebp
c0103a00:	89 e5                	mov    %esp,%ebp
c0103a02:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103a05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a15:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103a18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a1f:	e8 17 16 00 00       	call   c010503b <alloc_pages>
c0103a24:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a27:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103a2b:	75 24                	jne    c0103a51 <basic_check+0x52>
c0103a2d:	c7 44 24 0c 79 aa 10 	movl   $0xc010aa79,0xc(%esp)
c0103a34:	c0 
c0103a35:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103a3c:	c0 
c0103a3d:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0103a44:	00 
c0103a45:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103a4c:	e8 d5 d2 ff ff       	call   c0100d26 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103a51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a58:	e8 de 15 00 00       	call   c010503b <alloc_pages>
c0103a5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a64:	75 24                	jne    c0103a8a <basic_check+0x8b>
c0103a66:	c7 44 24 0c 95 aa 10 	movl   $0xc010aa95,0xc(%esp)
c0103a6d:	c0 
c0103a6e:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103a75:	c0 
c0103a76:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0103a7d:	00 
c0103a7e:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103a85:	e8 9c d2 ff ff       	call   c0100d26 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103a8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a91:	e8 a5 15 00 00       	call   c010503b <alloc_pages>
c0103a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a9d:	75 24                	jne    c0103ac3 <basic_check+0xc4>
c0103a9f:	c7 44 24 0c b1 aa 10 	movl   $0xc010aab1,0xc(%esp)
c0103aa6:	c0 
c0103aa7:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103aae:	c0 
c0103aaf:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103ab6:	00 
c0103ab7:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103abe:	e8 63 d2 ff ff       	call   c0100d26 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ac6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103ac9:	74 10                	je     c0103adb <basic_check+0xdc>
c0103acb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ace:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ad1:	74 08                	je     c0103adb <basic_check+0xdc>
c0103ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ad6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103ad9:	75 24                	jne    c0103aff <basic_check+0x100>
c0103adb:	c7 44 24 0c d0 aa 10 	movl   $0xc010aad0,0xc(%esp)
c0103ae2:	c0 
c0103ae3:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103aea:	c0 
c0103aeb:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103af2:	00 
c0103af3:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103afa:	e8 27 d2 ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b02:	89 04 24             	mov    %eax,(%esp)
c0103b05:	e8 ca f8 ff ff       	call   c01033d4 <page_ref>
c0103b0a:	85 c0                	test   %eax,%eax
c0103b0c:	75 1e                	jne    c0103b2c <basic_check+0x12d>
c0103b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b11:	89 04 24             	mov    %eax,(%esp)
c0103b14:	e8 bb f8 ff ff       	call   c01033d4 <page_ref>
c0103b19:	85 c0                	test   %eax,%eax
c0103b1b:	75 0f                	jne    c0103b2c <basic_check+0x12d>
c0103b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b20:	89 04 24             	mov    %eax,(%esp)
c0103b23:	e8 ac f8 ff ff       	call   c01033d4 <page_ref>
c0103b28:	85 c0                	test   %eax,%eax
c0103b2a:	74 24                	je     c0103b50 <basic_check+0x151>
c0103b2c:	c7 44 24 0c f4 aa 10 	movl   $0xc010aaf4,0xc(%esp)
c0103b33:	c0 
c0103b34:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103b3b:	c0 
c0103b3c:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103b43:	00 
c0103b44:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103b4b:	e8 d6 d1 ff ff       	call   c0100d26 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103b50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b53:	89 04 24             	mov    %eax,(%esp)
c0103b56:	e8 61 f8 ff ff       	call   c01033bc <page2pa>
c0103b5b:	8b 15 a4 bf 12 c0    	mov    0xc012bfa4,%edx
c0103b61:	c1 e2 0c             	shl    $0xc,%edx
c0103b64:	39 d0                	cmp    %edx,%eax
c0103b66:	72 24                	jb     c0103b8c <basic_check+0x18d>
c0103b68:	c7 44 24 0c 30 ab 10 	movl   $0xc010ab30,0xc(%esp)
c0103b6f:	c0 
c0103b70:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103b77:	c0 
c0103b78:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0103b7f:	00 
c0103b80:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103b87:	e8 9a d1 ff ff       	call   c0100d26 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b8f:	89 04 24             	mov    %eax,(%esp)
c0103b92:	e8 25 f8 ff ff       	call   c01033bc <page2pa>
c0103b97:	8b 15 a4 bf 12 c0    	mov    0xc012bfa4,%edx
c0103b9d:	c1 e2 0c             	shl    $0xc,%edx
c0103ba0:	39 d0                	cmp    %edx,%eax
c0103ba2:	72 24                	jb     c0103bc8 <basic_check+0x1c9>
c0103ba4:	c7 44 24 0c 4d ab 10 	movl   $0xc010ab4d,0xc(%esp)
c0103bab:	c0 
c0103bac:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103bb3:	c0 
c0103bb4:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103bbb:	00 
c0103bbc:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103bc3:	e8 5e d1 ff ff       	call   c0100d26 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bcb:	89 04 24             	mov    %eax,(%esp)
c0103bce:	e8 e9 f7 ff ff       	call   c01033bc <page2pa>
c0103bd3:	8b 15 a4 bf 12 c0    	mov    0xc012bfa4,%edx
c0103bd9:	c1 e2 0c             	shl    $0xc,%edx
c0103bdc:	39 d0                	cmp    %edx,%eax
c0103bde:	72 24                	jb     c0103c04 <basic_check+0x205>
c0103be0:	c7 44 24 0c 6a ab 10 	movl   $0xc010ab6a,0xc(%esp)
c0103be7:	c0 
c0103be8:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103bef:	c0 
c0103bf0:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103bf7:	00 
c0103bf8:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103bff:	e8 22 d1 ff ff       	call   c0100d26 <__panic>

    list_entry_t free_list_store = free_list;
c0103c04:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c0103c09:	8b 15 88 bf 12 c0    	mov    0xc012bf88,%edx
c0103c0f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103c12:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103c15:	c7 45 dc 84 bf 12 c0 	movl   $0xc012bf84,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103c1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c1f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103c22:	89 50 04             	mov    %edx,0x4(%eax)
c0103c25:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c28:	8b 50 04             	mov    0x4(%eax),%edx
c0103c2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c2e:	89 10                	mov    %edx,(%eax)
}
c0103c30:	90                   	nop
c0103c31:	c7 45 e0 84 bf 12 c0 	movl   $0xc012bf84,-0x20(%ebp)
    return list->next == list;
c0103c38:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c3b:	8b 40 04             	mov    0x4(%eax),%eax
c0103c3e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103c41:	0f 94 c0             	sete   %al
c0103c44:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103c47:	85 c0                	test   %eax,%eax
c0103c49:	75 24                	jne    c0103c6f <basic_check+0x270>
c0103c4b:	c7 44 24 0c 87 ab 10 	movl   $0xc010ab87,0xc(%esp)
c0103c52:	c0 
c0103c53:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103c5a:	c0 
c0103c5b:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0103c62:	00 
c0103c63:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103c6a:	e8 b7 d0 ff ff       	call   c0100d26 <__panic>

    unsigned int nr_free_store = nr_free;
c0103c6f:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103c74:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103c77:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0103c7e:	00 00 00 

    assert(alloc_page() == NULL);
c0103c81:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c88:	e8 ae 13 00 00       	call   c010503b <alloc_pages>
c0103c8d:	85 c0                	test   %eax,%eax
c0103c8f:	74 24                	je     c0103cb5 <basic_check+0x2b6>
c0103c91:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c0103c98:	c0 
c0103c99:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103ca0:	c0 
c0103ca1:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0103ca8:	00 
c0103ca9:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103cb0:	e8 71 d0 ff ff       	call   c0100d26 <__panic>

    free_page(p0);
c0103cb5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cbc:	00 
c0103cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103cc0:	89 04 24             	mov    %eax,(%esp)
c0103cc3:	e8 e0 13 00 00       	call   c01050a8 <free_pages>
    free_page(p1);
c0103cc8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ccf:	00 
c0103cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cd3:	89 04 24             	mov    %eax,(%esp)
c0103cd6:	e8 cd 13 00 00       	call   c01050a8 <free_pages>
    free_page(p2);
c0103cdb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103ce2:	00 
c0103ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ce6:	89 04 24             	mov    %eax,(%esp)
c0103ce9:	e8 ba 13 00 00       	call   c01050a8 <free_pages>
    assert(nr_free == 3);
c0103cee:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103cf3:	83 f8 03             	cmp    $0x3,%eax
c0103cf6:	74 24                	je     c0103d1c <basic_check+0x31d>
c0103cf8:	c7 44 24 0c b3 ab 10 	movl   $0xc010abb3,0xc(%esp)
c0103cff:	c0 
c0103d00:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103d07:	c0 
c0103d08:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0103d0f:	00 
c0103d10:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103d17:	e8 0a d0 ff ff       	call   c0100d26 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103d1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d23:	e8 13 13 00 00       	call   c010503b <alloc_pages>
c0103d28:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103d2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d2f:	75 24                	jne    c0103d55 <basic_check+0x356>
c0103d31:	c7 44 24 0c 79 aa 10 	movl   $0xc010aa79,0xc(%esp)
c0103d38:	c0 
c0103d39:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103d40:	c0 
c0103d41:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0103d48:	00 
c0103d49:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103d50:	e8 d1 cf ff ff       	call   c0100d26 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103d55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d5c:	e8 da 12 00 00       	call   c010503b <alloc_pages>
c0103d61:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d64:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d68:	75 24                	jne    c0103d8e <basic_check+0x38f>
c0103d6a:	c7 44 24 0c 95 aa 10 	movl   $0xc010aa95,0xc(%esp)
c0103d71:	c0 
c0103d72:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103d79:	c0 
c0103d7a:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0103d81:	00 
c0103d82:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103d89:	e8 98 cf ff ff       	call   c0100d26 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103d8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d95:	e8 a1 12 00 00       	call   c010503b <alloc_pages>
c0103d9a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103da1:	75 24                	jne    c0103dc7 <basic_check+0x3c8>
c0103da3:	c7 44 24 0c b1 aa 10 	movl   $0xc010aab1,0xc(%esp)
c0103daa:	c0 
c0103dab:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103db2:	c0 
c0103db3:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0103dba:	00 
c0103dbb:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103dc2:	e8 5f cf ff ff       	call   c0100d26 <__panic>

    assert(alloc_page() == NULL);
c0103dc7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dce:	e8 68 12 00 00       	call   c010503b <alloc_pages>
c0103dd3:	85 c0                	test   %eax,%eax
c0103dd5:	74 24                	je     c0103dfb <basic_check+0x3fc>
c0103dd7:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c0103dde:	c0 
c0103ddf:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103de6:	c0 
c0103de7:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0103dee:	00 
c0103def:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103df6:	e8 2b cf ff ff       	call   c0100d26 <__panic>

    free_page(p0);
c0103dfb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e02:	00 
c0103e03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e06:	89 04 24             	mov    %eax,(%esp)
c0103e09:	e8 9a 12 00 00       	call   c01050a8 <free_pages>
c0103e0e:	c7 45 d8 84 bf 12 c0 	movl   $0xc012bf84,-0x28(%ebp)
c0103e15:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e18:	8b 40 04             	mov    0x4(%eax),%eax
c0103e1b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103e1e:	0f 94 c0             	sete   %al
c0103e21:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103e24:	85 c0                	test   %eax,%eax
c0103e26:	74 24                	je     c0103e4c <basic_check+0x44d>
c0103e28:	c7 44 24 0c c0 ab 10 	movl   $0xc010abc0,0xc(%esp)
c0103e2f:	c0 
c0103e30:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103e37:	c0 
c0103e38:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103e3f:	00 
c0103e40:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103e47:	e8 da ce ff ff       	call   c0100d26 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103e4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e53:	e8 e3 11 00 00       	call   c010503b <alloc_pages>
c0103e58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e5e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103e61:	74 24                	je     c0103e87 <basic_check+0x488>
c0103e63:	c7 44 24 0c d8 ab 10 	movl   $0xc010abd8,0xc(%esp)
c0103e6a:	c0 
c0103e6b:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103e72:	c0 
c0103e73:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103e7a:	00 
c0103e7b:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103e82:	e8 9f ce ff ff       	call   c0100d26 <__panic>
    assert(alloc_page() == NULL);
c0103e87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e8e:	e8 a8 11 00 00       	call   c010503b <alloc_pages>
c0103e93:	85 c0                	test   %eax,%eax
c0103e95:	74 24                	je     c0103ebb <basic_check+0x4bc>
c0103e97:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c0103e9e:	c0 
c0103e9f:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103ea6:	c0 
c0103ea7:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0103eae:	00 
c0103eaf:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103eb6:	e8 6b ce ff ff       	call   c0100d26 <__panic>

    assert(nr_free == 0);
c0103ebb:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0103ec0:	85 c0                	test   %eax,%eax
c0103ec2:	74 24                	je     c0103ee8 <basic_check+0x4e9>
c0103ec4:	c7 44 24 0c f1 ab 10 	movl   $0xc010abf1,0xc(%esp)
c0103ecb:	c0 
c0103ecc:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103ed3:	c0 
c0103ed4:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0103edb:	00 
c0103edc:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103ee3:	e8 3e ce ff ff       	call   c0100d26 <__panic>
    free_list = free_list_store;
c0103ee8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103eeb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103eee:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
c0103ef3:	89 15 88 bf 12 c0    	mov    %edx,0xc012bf88
    nr_free = nr_free_store;
c0103ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103efc:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c

    free_page(p);
c0103f01:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f08:	00 
c0103f09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f0c:	89 04 24             	mov    %eax,(%esp)
c0103f0f:	e8 94 11 00 00       	call   c01050a8 <free_pages>
    free_page(p1);
c0103f14:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f1b:	00 
c0103f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f1f:	89 04 24             	mov    %eax,(%esp)
c0103f22:	e8 81 11 00 00       	call   c01050a8 <free_pages>
    free_page(p2);
c0103f27:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f2e:	00 
c0103f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f32:	89 04 24             	mov    %eax,(%esp)
c0103f35:	e8 6e 11 00 00       	call   c01050a8 <free_pages>
}
c0103f3a:	90                   	nop
c0103f3b:	89 ec                	mov    %ebp,%esp
c0103f3d:	5d                   	pop    %ebp
c0103f3e:	c3                   	ret    

c0103f3f <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103f3f:	55                   	push   %ebp
c0103f40:	89 e5                	mov    %esp,%ebp
c0103f42:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103f48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103f4f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103f56:	c7 45 ec 84 bf 12 c0 	movl   $0xc012bf84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103f5d:	eb 6a                	jmp    c0103fc9 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0103f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f62:	83 e8 0c             	sub    $0xc,%eax
c0103f65:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103f68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f6b:	83 c0 04             	add    $0x4,%eax
c0103f6e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103f75:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103f78:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103f7b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103f7e:	0f a3 10             	bt     %edx,(%eax)
c0103f81:	19 c0                	sbb    %eax,%eax
c0103f83:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103f86:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f8a:	0f 95 c0             	setne  %al
c0103f8d:	0f b6 c0             	movzbl %al,%eax
c0103f90:	85 c0                	test   %eax,%eax
c0103f92:	75 24                	jne    c0103fb8 <default_check+0x79>
c0103f94:	c7 44 24 0c fe ab 10 	movl   $0xc010abfe,0xc(%esp)
c0103f9b:	c0 
c0103f9c:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0103fa3:	c0 
c0103fa4:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0103fab:	00 
c0103fac:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0103fb3:	e8 6e cd ff ff       	call   c0100d26 <__panic>
        count ++, total += p->property;
c0103fb8:	ff 45 f4             	incl   -0xc(%ebp)
c0103fbb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103fbe:	8b 50 08             	mov    0x8(%eax),%edx
c0103fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fc4:	01 d0                	add    %edx,%eax
c0103fc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fcc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0103fcf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103fd2:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103fd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103fd8:	81 7d ec 84 bf 12 c0 	cmpl   $0xc012bf84,-0x14(%ebp)
c0103fdf:	0f 85 7a ff ff ff    	jne    c0103f5f <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103fe5:	e8 f3 10 00 00       	call   c01050dd <nr_free_pages>
c0103fea:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103fed:	39 d0                	cmp    %edx,%eax
c0103fef:	74 24                	je     c0104015 <default_check+0xd6>
c0103ff1:	c7 44 24 0c 0e ac 10 	movl   $0xc010ac0e,0xc(%esp)
c0103ff8:	c0 
c0103ff9:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104000:	c0 
c0104001:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104008:	00 
c0104009:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104010:	e8 11 cd ff ff       	call   c0100d26 <__panic>

    basic_check();
c0104015:	e8 e5 f9 ff ff       	call   c01039ff <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010401a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104021:	e8 15 10 00 00       	call   c010503b <alloc_pages>
c0104026:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0104029:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010402d:	75 24                	jne    c0104053 <default_check+0x114>
c010402f:	c7 44 24 0c 27 ac 10 	movl   $0xc010ac27,0xc(%esp)
c0104036:	c0 
c0104037:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c010403e:	c0 
c010403f:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104046:	00 
c0104047:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010404e:	e8 d3 cc ff ff       	call   c0100d26 <__panic>
    assert(!PageProperty(p0));
c0104053:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104056:	83 c0 04             	add    $0x4,%eax
c0104059:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104060:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104063:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104066:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104069:	0f a3 10             	bt     %edx,(%eax)
c010406c:	19 c0                	sbb    %eax,%eax
c010406e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104071:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104075:	0f 95 c0             	setne  %al
c0104078:	0f b6 c0             	movzbl %al,%eax
c010407b:	85 c0                	test   %eax,%eax
c010407d:	74 24                	je     c01040a3 <default_check+0x164>
c010407f:	c7 44 24 0c 32 ac 10 	movl   $0xc010ac32,0xc(%esp)
c0104086:	c0 
c0104087:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c010408e:	c0 
c010408f:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0104096:	00 
c0104097:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010409e:	e8 83 cc ff ff       	call   c0100d26 <__panic>

    list_entry_t free_list_store = free_list;
c01040a3:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c01040a8:	8b 15 88 bf 12 c0    	mov    0xc012bf88,%edx
c01040ae:	89 45 80             	mov    %eax,-0x80(%ebp)
c01040b1:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01040b4:	c7 45 b0 84 bf 12 c0 	movl   $0xc012bf84,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01040bb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040be:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01040c1:	89 50 04             	mov    %edx,0x4(%eax)
c01040c4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040c7:	8b 50 04             	mov    0x4(%eax),%edx
c01040ca:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01040cd:	89 10                	mov    %edx,(%eax)
}
c01040cf:	90                   	nop
c01040d0:	c7 45 b4 84 bf 12 c0 	movl   $0xc012bf84,-0x4c(%ebp)
    return list->next == list;
c01040d7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01040da:	8b 40 04             	mov    0x4(%eax),%eax
c01040dd:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01040e0:	0f 94 c0             	sete   %al
c01040e3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01040e6:	85 c0                	test   %eax,%eax
c01040e8:	75 24                	jne    c010410e <default_check+0x1cf>
c01040ea:	c7 44 24 0c 87 ab 10 	movl   $0xc010ab87,0xc(%esp)
c01040f1:	c0 
c01040f2:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c01040f9:	c0 
c01040fa:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0104101:	00 
c0104102:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104109:	e8 18 cc ff ff       	call   c0100d26 <__panic>
    assert(alloc_page() == NULL);
c010410e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104115:	e8 21 0f 00 00       	call   c010503b <alloc_pages>
c010411a:	85 c0                	test   %eax,%eax
c010411c:	74 24                	je     c0104142 <default_check+0x203>
c010411e:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c0104125:	c0 
c0104126:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c010412d:	c0 
c010412e:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104135:	00 
c0104136:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010413d:	e8 e4 cb ff ff       	call   c0100d26 <__panic>

    unsigned int nr_free_store = nr_free;
c0104142:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0104147:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c010414a:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0104151:	00 00 00 

    free_pages(p0 + 2, 3);
c0104154:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104157:	83 c0 40             	add    $0x40,%eax
c010415a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104161:	00 
c0104162:	89 04 24             	mov    %eax,(%esp)
c0104165:	e8 3e 0f 00 00       	call   c01050a8 <free_pages>
    assert(alloc_pages(4) == NULL);
c010416a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104171:	e8 c5 0e 00 00       	call   c010503b <alloc_pages>
c0104176:	85 c0                	test   %eax,%eax
c0104178:	74 24                	je     c010419e <default_check+0x25f>
c010417a:	c7 44 24 0c 44 ac 10 	movl   $0xc010ac44,0xc(%esp)
c0104181:	c0 
c0104182:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104189:	c0 
c010418a:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104191:	00 
c0104192:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104199:	e8 88 cb ff ff       	call   c0100d26 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010419e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041a1:	83 c0 40             	add    $0x40,%eax
c01041a4:	83 c0 04             	add    $0x4,%eax
c01041a7:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01041ae:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01041b1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01041b4:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01041b7:	0f a3 10             	bt     %edx,(%eax)
c01041ba:	19 c0                	sbb    %eax,%eax
c01041bc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01041bf:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01041c3:	0f 95 c0             	setne  %al
c01041c6:	0f b6 c0             	movzbl %al,%eax
c01041c9:	85 c0                	test   %eax,%eax
c01041cb:	74 0e                	je     c01041db <default_check+0x29c>
c01041cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041d0:	83 c0 40             	add    $0x40,%eax
c01041d3:	8b 40 08             	mov    0x8(%eax),%eax
c01041d6:	83 f8 03             	cmp    $0x3,%eax
c01041d9:	74 24                	je     c01041ff <default_check+0x2c0>
c01041db:	c7 44 24 0c 5c ac 10 	movl   $0xc010ac5c,0xc(%esp)
c01041e2:	c0 
c01041e3:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c01041ea:	c0 
c01041eb:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01041f2:	00 
c01041f3:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c01041fa:	e8 27 cb ff ff       	call   c0100d26 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01041ff:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104206:	e8 30 0e 00 00       	call   c010503b <alloc_pages>
c010420b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010420e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104212:	75 24                	jne    c0104238 <default_check+0x2f9>
c0104214:	c7 44 24 0c 88 ac 10 	movl   $0xc010ac88,0xc(%esp)
c010421b:	c0 
c010421c:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104223:	c0 
c0104224:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c010422b:	00 
c010422c:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104233:	e8 ee ca ff ff       	call   c0100d26 <__panic>
    assert(alloc_page() == NULL);
c0104238:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010423f:	e8 f7 0d 00 00       	call   c010503b <alloc_pages>
c0104244:	85 c0                	test   %eax,%eax
c0104246:	74 24                	je     c010426c <default_check+0x32d>
c0104248:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c010424f:	c0 
c0104250:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104257:	c0 
c0104258:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c010425f:	00 
c0104260:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104267:	e8 ba ca ff ff       	call   c0100d26 <__panic>
    assert(p0 + 2 == p1);
c010426c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010426f:	83 c0 40             	add    $0x40,%eax
c0104272:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104275:	74 24                	je     c010429b <default_check+0x35c>
c0104277:	c7 44 24 0c a6 ac 10 	movl   $0xc010aca6,0xc(%esp)
c010427e:	c0 
c010427f:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104286:	c0 
c0104287:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c010428e:	00 
c010428f:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104296:	e8 8b ca ff ff       	call   c0100d26 <__panic>

    p2 = p0 + 1;
c010429b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010429e:	83 c0 20             	add    $0x20,%eax
c01042a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01042a4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01042ab:	00 
c01042ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042af:	89 04 24             	mov    %eax,(%esp)
c01042b2:	e8 f1 0d 00 00       	call   c01050a8 <free_pages>
    free_pages(p1, 3);
c01042b7:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01042be:	00 
c01042bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01042c2:	89 04 24             	mov    %eax,(%esp)
c01042c5:	e8 de 0d 00 00       	call   c01050a8 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01042ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042cd:	83 c0 04             	add    $0x4,%eax
c01042d0:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01042d7:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042da:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01042dd:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01042e0:	0f a3 10             	bt     %edx,(%eax)
c01042e3:	19 c0                	sbb    %eax,%eax
c01042e5:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01042e8:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01042ec:	0f 95 c0             	setne  %al
c01042ef:	0f b6 c0             	movzbl %al,%eax
c01042f2:	85 c0                	test   %eax,%eax
c01042f4:	74 0b                	je     c0104301 <default_check+0x3c2>
c01042f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042f9:	8b 40 08             	mov    0x8(%eax),%eax
c01042fc:	83 f8 01             	cmp    $0x1,%eax
c01042ff:	74 24                	je     c0104325 <default_check+0x3e6>
c0104301:	c7 44 24 0c b4 ac 10 	movl   $0xc010acb4,0xc(%esp)
c0104308:	c0 
c0104309:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104310:	c0 
c0104311:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0104318:	00 
c0104319:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104320:	e8 01 ca ff ff       	call   c0100d26 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104325:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104328:	83 c0 04             	add    $0x4,%eax
c010432b:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104332:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104335:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104338:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010433b:	0f a3 10             	bt     %edx,(%eax)
c010433e:	19 c0                	sbb    %eax,%eax
c0104340:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104343:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0104347:	0f 95 c0             	setne  %al
c010434a:	0f b6 c0             	movzbl %al,%eax
c010434d:	85 c0                	test   %eax,%eax
c010434f:	74 0b                	je     c010435c <default_check+0x41d>
c0104351:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104354:	8b 40 08             	mov    0x8(%eax),%eax
c0104357:	83 f8 03             	cmp    $0x3,%eax
c010435a:	74 24                	je     c0104380 <default_check+0x441>
c010435c:	c7 44 24 0c dc ac 10 	movl   $0xc010acdc,0xc(%esp)
c0104363:	c0 
c0104364:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c010436b:	c0 
c010436c:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104373:	00 
c0104374:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010437b:	e8 a6 c9 ff ff       	call   c0100d26 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104380:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104387:	e8 af 0c 00 00       	call   c010503b <alloc_pages>
c010438c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010438f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104392:	83 e8 20             	sub    $0x20,%eax
c0104395:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104398:	74 24                	je     c01043be <default_check+0x47f>
c010439a:	c7 44 24 0c 02 ad 10 	movl   $0xc010ad02,0xc(%esp)
c01043a1:	c0 
c01043a2:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c01043a9:	c0 
c01043aa:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c01043b1:	00 
c01043b2:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c01043b9:	e8 68 c9 ff ff       	call   c0100d26 <__panic>
    free_page(p0);
c01043be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043c5:	00 
c01043c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043c9:	89 04 24             	mov    %eax,(%esp)
c01043cc:	e8 d7 0c 00 00       	call   c01050a8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01043d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01043d8:	e8 5e 0c 00 00       	call   c010503b <alloc_pages>
c01043dd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043e3:	83 c0 20             	add    $0x20,%eax
c01043e6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01043e9:	74 24                	je     c010440f <default_check+0x4d0>
c01043eb:	c7 44 24 0c 20 ad 10 	movl   $0xc010ad20,0xc(%esp)
c01043f2:	c0 
c01043f3:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c01043fa:	c0 
c01043fb:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0104402:	00 
c0104403:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010440a:	e8 17 c9 ff ff       	call   c0100d26 <__panic>

    free_pages(p0, 2);
c010440f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104416:	00 
c0104417:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010441a:	89 04 24             	mov    %eax,(%esp)
c010441d:	e8 86 0c 00 00       	call   c01050a8 <free_pages>
    free_page(p2);
c0104422:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104429:	00 
c010442a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010442d:	89 04 24             	mov    %eax,(%esp)
c0104430:	e8 73 0c 00 00       	call   c01050a8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104435:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010443c:	e8 fa 0b 00 00       	call   c010503b <alloc_pages>
c0104441:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104444:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104448:	75 24                	jne    c010446e <default_check+0x52f>
c010444a:	c7 44 24 0c 40 ad 10 	movl   $0xc010ad40,0xc(%esp)
c0104451:	c0 
c0104452:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104459:	c0 
c010445a:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0104461:	00 
c0104462:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104469:	e8 b8 c8 ff ff       	call   c0100d26 <__panic>
    assert(alloc_page() == NULL);
c010446e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104475:	e8 c1 0b 00 00       	call   c010503b <alloc_pages>
c010447a:	85 c0                	test   %eax,%eax
c010447c:	74 24                	je     c01044a2 <default_check+0x563>
c010447e:	c7 44 24 0c 9e ab 10 	movl   $0xc010ab9e,0xc(%esp)
c0104485:	c0 
c0104486:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c010448d:	c0 
c010448e:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0104495:	00 
c0104496:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010449d:	e8 84 c8 ff ff       	call   c0100d26 <__panic>

    assert(nr_free == 0);
c01044a2:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c01044a7:	85 c0                	test   %eax,%eax
c01044a9:	74 24                	je     c01044cf <default_check+0x590>
c01044ab:	c7 44 24 0c f1 ab 10 	movl   $0xc010abf1,0xc(%esp)
c01044b2:	c0 
c01044b3:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c01044ba:	c0 
c01044bb:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c01044c2:	00 
c01044c3:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c01044ca:	e8 57 c8 ff ff       	call   c0100d26 <__panic>
    nr_free = nr_free_store;
c01044cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044d2:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c

    free_list = free_list_store;
c01044d7:	8b 45 80             	mov    -0x80(%ebp),%eax
c01044da:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01044dd:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
c01044e2:	89 15 88 bf 12 c0    	mov    %edx,0xc012bf88
    free_pages(p0, 5);
c01044e8:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01044ef:	00 
c01044f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044f3:	89 04 24             	mov    %eax,(%esp)
c01044f6:	e8 ad 0b 00 00       	call   c01050a8 <free_pages>

    le = &free_list;
c01044fb:	c7 45 ec 84 bf 12 c0 	movl   $0xc012bf84,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104502:	eb 1c                	jmp    c0104520 <default_check+0x5e1>
        struct Page *p = le2page(le, page_link);
c0104504:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104507:	83 e8 0c             	sub    $0xc,%eax
c010450a:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c010450d:	ff 4d f4             	decl   -0xc(%ebp)
c0104510:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104513:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104516:	8b 48 08             	mov    0x8(%eax),%ecx
c0104519:	89 d0                	mov    %edx,%eax
c010451b:	29 c8                	sub    %ecx,%eax
c010451d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104520:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104523:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0104526:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104529:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010452c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010452f:	81 7d ec 84 bf 12 c0 	cmpl   $0xc012bf84,-0x14(%ebp)
c0104536:	75 cc                	jne    c0104504 <default_check+0x5c5>
    }
    assert(count == 0);
c0104538:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010453c:	74 24                	je     c0104562 <default_check+0x623>
c010453e:	c7 44 24 0c 5e ad 10 	movl   $0xc010ad5e,0xc(%esp)
c0104545:	c0 
c0104546:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c010454d:	c0 
c010454e:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0104555:	00 
c0104556:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c010455d:	e8 c4 c7 ff ff       	call   c0100d26 <__panic>
    assert(total == 0);
c0104562:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104566:	74 24                	je     c010458c <default_check+0x64d>
c0104568:	c7 44 24 0c 69 ad 10 	movl   $0xc010ad69,0xc(%esp)
c010456f:	c0 
c0104570:	c7 44 24 08 16 aa 10 	movl   $0xc010aa16,0x8(%esp)
c0104577:	c0 
c0104578:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c010457f:	00 
c0104580:	c7 04 24 2b aa 10 c0 	movl   $0xc010aa2b,(%esp)
c0104587:	e8 9a c7 ff ff       	call   c0100d26 <__panic>
}
c010458c:	90                   	nop
c010458d:	89 ec                	mov    %ebp,%esp
c010458f:	5d                   	pop    %ebp
c0104590:	c3                   	ret    

c0104591 <__intr_save>:
__intr_save(void) {
c0104591:	55                   	push   %ebp
c0104592:	89 e5                	mov    %esp,%ebp
c0104594:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104597:	9c                   	pushf  
c0104598:	58                   	pop    %eax
c0104599:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010459f:	25 00 02 00 00       	and    $0x200,%eax
c01045a4:	85 c0                	test   %eax,%eax
c01045a6:	74 0c                	je     c01045b4 <__intr_save+0x23>
        intr_disable();
c01045a8:	e8 2f da ff ff       	call   c0101fdc <intr_disable>
        return 1;
c01045ad:	b8 01 00 00 00       	mov    $0x1,%eax
c01045b2:	eb 05                	jmp    c01045b9 <__intr_save+0x28>
    return 0;
c01045b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045b9:	89 ec                	mov    %ebp,%esp
c01045bb:	5d                   	pop    %ebp
c01045bc:	c3                   	ret    

c01045bd <__intr_restore>:
__intr_restore(bool flag) {
c01045bd:	55                   	push   %ebp
c01045be:	89 e5                	mov    %esp,%ebp
c01045c0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01045c3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01045c7:	74 05                	je     c01045ce <__intr_restore+0x11>
        intr_enable();
c01045c9:	e8 06 da ff ff       	call   c0101fd4 <intr_enable>
}
c01045ce:	90                   	nop
c01045cf:	89 ec                	mov    %ebp,%esp
c01045d1:	5d                   	pop    %ebp
c01045d2:	c3                   	ret    

c01045d3 <page2ppn>:
page2ppn(struct Page *page) {
c01045d3:	55                   	push   %ebp
c01045d4:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01045d6:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01045dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01045df:	29 d0                	sub    %edx,%eax
c01045e1:	c1 f8 05             	sar    $0x5,%eax
}
c01045e4:	5d                   	pop    %ebp
c01045e5:	c3                   	ret    

c01045e6 <page2pa>:
page2pa(struct Page *page) {
c01045e6:	55                   	push   %ebp
c01045e7:	89 e5                	mov    %esp,%ebp
c01045e9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01045ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01045ef:	89 04 24             	mov    %eax,(%esp)
c01045f2:	e8 dc ff ff ff       	call   c01045d3 <page2ppn>
c01045f7:	c1 e0 0c             	shl    $0xc,%eax
}
c01045fa:	89 ec                	mov    %ebp,%esp
c01045fc:	5d                   	pop    %ebp
c01045fd:	c3                   	ret    

c01045fe <pa2page>:
pa2page(uintptr_t pa) {
c01045fe:	55                   	push   %ebp
c01045ff:	89 e5                	mov    %esp,%ebp
c0104601:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104604:	8b 45 08             	mov    0x8(%ebp),%eax
c0104607:	c1 e8 0c             	shr    $0xc,%eax
c010460a:	89 c2                	mov    %eax,%edx
c010460c:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104611:	39 c2                	cmp    %eax,%edx
c0104613:	72 1c                	jb     c0104631 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104615:	c7 44 24 08 a4 ad 10 	movl   $0xc010ada4,0x8(%esp)
c010461c:	c0 
c010461d:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104624:	00 
c0104625:	c7 04 24 c3 ad 10 c0 	movl   $0xc010adc3,(%esp)
c010462c:	e8 f5 c6 ff ff       	call   c0100d26 <__panic>
    return &pages[PPN(pa)];
c0104631:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104637:	8b 45 08             	mov    0x8(%ebp),%eax
c010463a:	c1 e8 0c             	shr    $0xc,%eax
c010463d:	c1 e0 05             	shl    $0x5,%eax
c0104640:	01 d0                	add    %edx,%eax
}
c0104642:	89 ec                	mov    %ebp,%esp
c0104644:	5d                   	pop    %ebp
c0104645:	c3                   	ret    

c0104646 <page2kva>:
page2kva(struct Page *page) {
c0104646:	55                   	push   %ebp
c0104647:	89 e5                	mov    %esp,%ebp
c0104649:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010464c:	8b 45 08             	mov    0x8(%ebp),%eax
c010464f:	89 04 24             	mov    %eax,(%esp)
c0104652:	e8 8f ff ff ff       	call   c01045e6 <page2pa>
c0104657:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010465a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010465d:	c1 e8 0c             	shr    $0xc,%eax
c0104660:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104663:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104668:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010466b:	72 23                	jb     c0104690 <page2kva+0x4a>
c010466d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104670:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104674:	c7 44 24 08 d4 ad 10 	movl   $0xc010add4,0x8(%esp)
c010467b:	c0 
c010467c:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104683:	00 
c0104684:	c7 04 24 c3 ad 10 c0 	movl   $0xc010adc3,(%esp)
c010468b:	e8 96 c6 ff ff       	call   c0100d26 <__panic>
c0104690:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104693:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104698:	89 ec                	mov    %ebp,%esp
c010469a:	5d                   	pop    %ebp
c010469b:	c3                   	ret    

c010469c <kva2page>:
kva2page(void *kva) {
c010469c:	55                   	push   %ebp
c010469d:	89 e5                	mov    %esp,%ebp
c010469f:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01046a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046a8:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01046af:	77 23                	ja     c01046d4 <kva2page+0x38>
c01046b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01046b8:	c7 44 24 08 f8 ad 10 	movl   $0xc010adf8,0x8(%esp)
c01046bf:	c0 
c01046c0:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01046c7:	00 
c01046c8:	c7 04 24 c3 ad 10 c0 	movl   $0xc010adc3,(%esp)
c01046cf:	e8 52 c6 ff ff       	call   c0100d26 <__panic>
c01046d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d7:	05 00 00 00 40       	add    $0x40000000,%eax
c01046dc:	89 04 24             	mov    %eax,(%esp)
c01046df:	e8 1a ff ff ff       	call   c01045fe <pa2page>
}
c01046e4:	89 ec                	mov    %ebp,%esp
c01046e6:	5d                   	pop    %ebp
c01046e7:	c3                   	ret    

c01046e8 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01046e8:	55                   	push   %ebp
c01046e9:	89 e5                	mov    %esp,%ebp
c01046eb:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);//多少个页
c01046ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046f1:	ba 01 00 00 00       	mov    $0x1,%edx
c01046f6:	88 c1                	mov    %al,%cl
c01046f8:	d3 e2                	shl    %cl,%edx
c01046fa:	89 d0                	mov    %edx,%eax
c01046fc:	89 04 24             	mov    %eax,(%esp)
c01046ff:	e8 37 09 00 00       	call   c010503b <alloc_pages>
c0104704:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104707:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010470b:	75 07                	jne    c0104714 <__slob_get_free_pages+0x2c>
    return NULL;
c010470d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104712:	eb 0b                	jmp    c010471f <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104714:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104717:	89 04 24             	mov    %eax,(%esp)
c010471a:	e8 27 ff ff ff       	call   c0104646 <page2kva>
}
c010471f:	89 ec                	mov    %ebp,%esp
c0104721:	5d                   	pop    %ebp
c0104722:	c3                   	ret    

c0104723 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104723:	55                   	push   %ebp
c0104724:	89 e5                	mov    %esp,%ebp
c0104726:	83 ec 18             	sub    $0x18,%esp
c0104729:	89 5d fc             	mov    %ebx,-0x4(%ebp)
  free_pages(kva2page(kva), 1 << order);
c010472c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010472f:	ba 01 00 00 00       	mov    $0x1,%edx
c0104734:	88 c1                	mov    %al,%cl
c0104736:	d3 e2                	shl    %cl,%edx
c0104738:	89 d0                	mov    %edx,%eax
c010473a:	89 c3                	mov    %eax,%ebx
c010473c:	8b 45 08             	mov    0x8(%ebp),%eax
c010473f:	89 04 24             	mov    %eax,(%esp)
c0104742:	e8 55 ff ff ff       	call   c010469c <kva2page>
c0104747:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010474b:	89 04 24             	mov    %eax,(%esp)
c010474e:	e8 55 09 00 00       	call   c01050a8 <free_pages>
}
c0104753:	90                   	nop
c0104754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0104757:	89 ec                	mov    %ebp,%esp
c0104759:	5d                   	pop    %ebp
c010475a:	c3                   	ret    

c010475b <slob_alloc>:


//分配
//sizeof(bigblock_t), 0, 0
static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c010475b:	55                   	push   %ebp
c010475c:	89 e5                	mov    %esp,%ebp
c010475e:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE ); //不足一页大小
c0104761:	8b 45 08             	mov    0x8(%ebp),%eax
c0104764:	83 c0 08             	add    $0x8,%eax
c0104767:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010476c:	76 24                	jbe    c0104792 <slob_alloc+0x37>
c010476e:	c7 44 24 0c 1c ae 10 	movl   $0xc010ae1c,0xc(%esp)
c0104775:	c0 
c0104776:	c7 44 24 08 3b ae 10 	movl   $0xc010ae3b,0x8(%esp)
c010477d:	c0 
c010477e:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
c0104785:	00 
c0104786:	c7 04 24 50 ae 10 c0 	movl   $0xc010ae50,(%esp)
c010478d:	e8 94 c5 ff ff       	call   c0100d26 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104792:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size); //units为可分为多少个sizeof(slob_t)
c0104799:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01047a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01047a3:	83 c0 07             	add    $0x7,%eax
c01047a6:	c1 e8 03             	shr    $0x3,%eax
c01047a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01047ac:	e8 e0 fd ff ff       	call   c0104591 <__intr_save>
c01047b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01047b4:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c01047b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01047bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047bf:	8b 40 04             	mov    0x4(%eax),%eax
c01047c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01047c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01047c9:	74 21                	je     c01047ec <slob_alloc+0x91>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align); //aligned为cur以align对齐的上界数
c01047cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01047ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01047d1:	01 d0                	add    %edx,%eax
c01047d3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01047d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01047d9:	f7 d8                	neg    %eax
c01047db:	21 d0                	and    %edx,%eax
c01047dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur; //头部的碎片
c01047e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047e3:	2b 45 f0             	sub    -0x10(%ebp),%eax
c01047e6:	c1 f8 03             	sar    $0x3,%eax
c01047e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */ //找到够大的节点
c01047ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047ef:	8b 00                	mov    (%eax),%eax
c01047f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01047f4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01047f7:	01 ca                	add    %ecx,%edx
c01047f9:	39 d0                	cmp    %edx,%eax
c01047fb:	0f 8c aa 00 00 00    	jl     c01048ab <slob_alloc+0x150>
			if (delta) { /* need to fragment head to align? */ //如果要按aign对齐的话，就要把每个节点分成两部分 前面是头部碎片delta大小，后面是剩余部分大小
c0104801:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104805:	74 38                	je     c010483f <slob_alloc+0xe4>
				aligned->units = cur->units - delta;
c0104807:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010480a:	8b 00                	mov    (%eax),%eax
c010480c:	2b 45 e8             	sub    -0x18(%ebp),%eax
c010480f:	89 c2                	mov    %eax,%edx
c0104811:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104814:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104816:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104819:	8b 50 04             	mov    0x4(%eax),%edx
c010481c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010481f:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104822:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104825:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104828:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c010482b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010482e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104831:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104833:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104836:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104839:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010483c:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */ //请求的和当前的正好相等
c010483f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104842:	8b 00                	mov    (%eax),%eax
c0104844:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104847:	75 0e                	jne    c0104857 <slob_alloc+0xfc>
				prev->next = cur->next; /* unlink */  //把匹配的这块从链表中取出来
c0104849:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010484c:	8b 50 04             	mov    0x4(%eax),%edx
c010484f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104852:	89 50 04             	mov    %edx,0x4(%eax)
c0104855:	eb 3c                	jmp    c0104893 <slob_alloc+0x138>
			else { /* fragment */ //没有正好匹配的情况？
				prev->next = cur + units;  //前一个节点的next指向cur加上分出来的units之后的地址
c0104857:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010485a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104861:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104864:	01 c2                	add    %eax,%edx
c0104866:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104869:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units; //其大小为原大小减去分出去的大小
c010486c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010486f:	8b 10                	mov    (%eax),%edx
c0104871:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104874:	8b 40 04             	mov    0x4(%eax),%eax
c0104877:	2b 55 e0             	sub    -0x20(%ebp),%edx
c010487a:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next; //其Next指针依旧指向下一个节点
c010487c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010487f:	8b 40 04             	mov    0x4(%eax),%eax
c0104882:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104885:	8b 52 04             	mov    0x4(%edx),%edx
c0104888:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units; //同理在当前的链表减个出来
c010488b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010488e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104891:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104896:	a3 e8 89 12 c0       	mov    %eax,0xc01289e8
			spin_unlock_irqrestore(&slob_lock, flags);
c010489b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010489e:	89 04 24             	mov    %eax,(%esp)
c01048a1:	e8 17 fd ff ff       	call   c01045bd <__intr_restore>
			return cur;
c01048a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048a9:	eb 7f                	jmp    c010492a <slob_alloc+0x1cf>
		}
		if (cur == slobfree) {
c01048ab:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c01048b0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01048b3:	75 61                	jne    c0104916 <slob_alloc+0x1bb>
			spin_unlock_irqrestore(&slob_lock, flags);
c01048b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048b8:	89 04 24             	mov    %eax,(%esp)
c01048bb:	e8 fd fc ff ff       	call   c01045bd <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c01048c0:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01048c7:	75 07                	jne    c01048d0 <slob_alloc+0x175>
				return 0;
c01048c9:	b8 00 00 00 00       	mov    $0x0,%eax
c01048ce:	eb 5a                	jmp    c010492a <slob_alloc+0x1cf>

			cur = (slob_t *)__slob_get_free_page(gfp);
c01048d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048d7:	00 
c01048d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048db:	89 04 24             	mov    %eax,(%esp)
c01048de:	e8 05 fe ff ff       	call   c01046e8 <__slob_get_free_pages>
c01048e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c01048e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048ea:	75 07                	jne    c01048f3 <slob_alloc+0x198>
				return 0;
c01048ec:	b8 00 00 00 00       	mov    $0x0,%eax
c01048f1:	eb 37                	jmp    c010492a <slob_alloc+0x1cf>

			slob_free(cur, PAGE_SIZE);
c01048f3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01048fa:	00 
c01048fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048fe:	89 04 24             	mov    %eax,(%esp)
c0104901:	e8 28 00 00 00       	call   c010492e <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104906:	e8 86 fc ff ff       	call   c0104591 <__intr_save>
c010490b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c010490e:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0104913:	89 45 f0             	mov    %eax,-0x10(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104916:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104919:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010491c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010491f:	8b 40 04             	mov    0x4(%eax),%eax
c0104922:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104925:	e9 9b fe ff ff       	jmp    c01047c5 <slob_alloc+0x6a>
		}
	}
}
c010492a:	89 ec                	mov    %ebp,%esp
c010492c:	5d                   	pop    %ebp
c010492d:	c3                   	ret    

c010492e <slob_free>:

static void slob_free(void *block, int size)
{
c010492e:	55                   	push   %ebp
c010492f:	89 e5                	mov    %esp,%ebp
c0104931:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104934:	8b 45 08             	mov    0x8(%ebp),%eax
c0104937:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010493a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010493e:	0f 84 01 01 00 00    	je     c0104a45 <slob_free+0x117>
		return;

	if (size)
c0104944:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104948:	74 10                	je     c010495a <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c010494a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010494d:	83 c0 07             	add    $0x7,%eax
c0104950:	c1 e8 03             	shr    $0x3,%eax
c0104953:	89 c2                	mov    %eax,%edx
c0104955:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104958:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c010495a:	e8 32 fc ff ff       	call   c0104591 <__intr_save>
c010495f:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104962:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0104967:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010496a:	eb 27                	jmp    c0104993 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c010496c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010496f:	8b 40 04             	mov    0x4(%eax),%eax
c0104972:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104975:	72 13                	jb     c010498a <slob_free+0x5c>
c0104977:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010497a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010497d:	77 27                	ja     c01049a6 <slob_free+0x78>
c010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104982:	8b 40 04             	mov    0x4(%eax),%eax
c0104985:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104988:	72 1c                	jb     c01049a6 <slob_free+0x78>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010498a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010498d:	8b 40 04             	mov    0x4(%eax),%eax
c0104990:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104993:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104996:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104999:	76 d1                	jbe    c010496c <slob_free+0x3e>
c010499b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010499e:	8b 40 04             	mov    0x4(%eax),%eax
c01049a1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01049a4:	73 c6                	jae    c010496c <slob_free+0x3e>
			break;

	if (b + b->units == cur->next) {
c01049a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049a9:	8b 00                	mov    (%eax),%eax
c01049ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01049b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049b5:	01 c2                	add    %eax,%edx
c01049b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ba:	8b 40 04             	mov    0x4(%eax),%eax
c01049bd:	39 c2                	cmp    %eax,%edx
c01049bf:	75 25                	jne    c01049e6 <slob_free+0xb8>
		b->units += cur->next->units;
c01049c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049c4:	8b 10                	mov    (%eax),%edx
c01049c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c9:	8b 40 04             	mov    0x4(%eax),%eax
c01049cc:	8b 00                	mov    (%eax),%eax
c01049ce:	01 c2                	add    %eax,%edx
c01049d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049d3:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c01049d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d8:	8b 40 04             	mov    0x4(%eax),%eax
c01049db:	8b 50 04             	mov    0x4(%eax),%edx
c01049de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049e1:	89 50 04             	mov    %edx,0x4(%eax)
c01049e4:	eb 0c                	jmp    c01049f2 <slob_free+0xc4>
	} else
		b->next = cur->next;
c01049e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049e9:	8b 50 04             	mov    0x4(%eax),%edx
c01049ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ef:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c01049f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f5:	8b 00                	mov    (%eax),%eax
c01049f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01049fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a01:	01 d0                	add    %edx,%eax
c0104a03:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104a06:	75 1f                	jne    c0104a27 <slob_free+0xf9>
		cur->units += b->units;
c0104a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a0b:	8b 10                	mov    (%eax),%edx
c0104a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a10:	8b 00                	mov    (%eax),%eax
c0104a12:	01 c2                	add    %eax,%edx
c0104a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a17:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a1c:	8b 50 04             	mov    0x4(%eax),%edx
c0104a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a22:	89 50 04             	mov    %edx,0x4(%eax)
c0104a25:	eb 09                	jmp    c0104a30 <slob_free+0x102>
	} else
		cur->next = b;
c0104a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104a2d:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a33:	a3 e8 89 12 c0       	mov    %eax,0xc01289e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0104a38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a3b:	89 04 24             	mov    %eax,(%esp)
c0104a3e:	e8 7a fb ff ff       	call   c01045bd <__intr_restore>
c0104a43:	eb 01                	jmp    c0104a46 <slob_free+0x118>
		return;
c0104a45:	90                   	nop
}
c0104a46:	89 ec                	mov    %ebp,%esp
c0104a48:	5d                   	pop    %ebp
c0104a49:	c3                   	ret    

c0104a4a <slob_init>:



void
slob_init(void) {
c0104a4a:	55                   	push   %ebp
c0104a4b:	89 e5                	mov    %esp,%ebp
c0104a4d:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104a50:	c7 04 24 62 ae 10 c0 	movl   $0xc010ae62,(%esp)
c0104a57:	e8 1c b9 ff ff       	call   c0100378 <cprintf>
}
c0104a5c:	90                   	nop
c0104a5d:	89 ec                	mov    %ebp,%esp
c0104a5f:	5d                   	pop    %ebp
c0104a60:	c3                   	ret    

c0104a61 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104a61:	55                   	push   %ebp
c0104a62:	89 e5                	mov    %esp,%ebp
c0104a64:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104a67:	e8 de ff ff ff       	call   c0104a4a <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104a6c:	c7 04 24 76 ae 10 c0 	movl   $0xc010ae76,(%esp)
c0104a73:	e8 00 b9 ff ff       	call   c0100378 <cprintf>
}
c0104a78:	90                   	nop
c0104a79:	89 ec                	mov    %ebp,%esp
c0104a7b:	5d                   	pop    %ebp
c0104a7c:	c3                   	ret    

c0104a7d <slob_allocated>:

size_t
slob_allocated(void) {
c0104a7d:	55                   	push   %ebp
c0104a7e:	89 e5                	mov    %esp,%ebp
  return 0;
c0104a80:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104a85:	5d                   	pop    %ebp
c0104a86:	c3                   	ret    

c0104a87 <kallocated>:

size_t
kallocated(void) {
c0104a87:	55                   	push   %ebp
c0104a88:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104a8a:	e8 ee ff ff ff       	call   c0104a7d <slob_allocated>
}
c0104a8f:	5d                   	pop    %ebp
c0104a90:	c3                   	ret    

c0104a91 <find_order>:

static int find_order(int size)
{
c0104a91:	55                   	push   %ebp
c0104a92:	89 e5                	mov    %esp,%ebp
c0104a94:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104a97:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104a9e:	eb 06                	jmp    c0104aa6 <find_order+0x15>
		order++;
c0104aa0:	ff 45 fc             	incl   -0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104aa3:	d1 7d 08             	sarl   0x8(%ebp)
c0104aa6:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104aad:	7f f1                	jg     c0104aa0 <find_order+0xf>
	return order;
c0104aaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104ab2:	89 ec                	mov    %ebp,%esp
c0104ab4:	5d                   	pop    %ebp
c0104ab5:	c3                   	ret    

c0104ab6 <__kmalloc>:

//size = sizeof(struct proc_struct)  gfp = 0
static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104ab6:	55                   	push   %ebp
c0104ab7:	89 e5                	mov    %esp,%ebp
c0104ab9:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) { //SLOB_UNIT = sizeof(slob_t)
c0104abc:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104ac3:	77 3b                	ja     c0104b00 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ac8:	8d 50 08             	lea    0x8(%eax),%edx
c0104acb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ad2:	00 
c0104ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ada:	89 14 24             	mov    %edx,(%esp)
c0104add:	e8 79 fc ff ff       	call   c010475b <slob_alloc>
c0104ae2:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104ae5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104ae9:	74 0b                	je     c0104af6 <__kmalloc+0x40>
c0104aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104aee:	83 c0 08             	add    $0x8,%eax
c0104af1:	e9 b0 00 00 00       	jmp    c0104ba6 <__kmalloc+0xf0>
c0104af6:	b8 00 00 00 00       	mov    $0x0,%eax
c0104afb:	e9 a6 00 00 00       	jmp    c0104ba6 <__kmalloc+0xf0>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0); // 大于一个page的内存申请
c0104b00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b07:	00 
c0104b08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b0f:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104b16:	e8 40 fc ff ff       	call   c010475b <slob_alloc>
c0104b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (!bb)
c0104b1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b22:	75 07                	jne    c0104b2b <__kmalloc+0x75>
		return 0;
c0104b24:	b8 00 00 00 00       	mov    $0x0,%eax
c0104b29:	eb 7b                	jmp    c0104ba6 <__kmalloc+0xf0>

	bb->order = find_order(size);
c0104b2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b2e:	89 04 24             	mov    %eax,(%esp)
c0104b31:	e8 5b ff ff ff       	call   c0104a91 <find_order>
c0104b36:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b39:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b3e:	8b 00                	mov    (%eax),%eax
c0104b40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b44:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b47:	89 04 24             	mov    %eax,(%esp)
c0104b4a:	e8 99 fb ff ff       	call   c01046e8 <__slob_get_free_pages>
c0104b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b52:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b58:	8b 40 04             	mov    0x4(%eax),%eax
c0104b5b:	85 c0                	test   %eax,%eax
c0104b5d:	74 2f                	je     c0104b8e <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c0104b5f:	e8 2d fa ff ff       	call   c0104591 <__intr_save>
c0104b64:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bb->next = bigblocks;
c0104b67:	8b 15 90 bf 12 c0    	mov    0xc012bf90,%edx
c0104b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b70:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b76:	a3 90 bf 12 c0       	mov    %eax,0xc012bf90
		spin_unlock_irqrestore(&block_lock, flags);
c0104b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b7e:	89 04 24             	mov    %eax,(%esp)
c0104b81:	e8 37 fa ff ff       	call   c01045bd <__intr_restore>
		return bb->pages;
c0104b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b89:	8b 40 04             	mov    0x4(%eax),%eax
c0104b8c:	eb 18                	jmp    c0104ba6 <__kmalloc+0xf0>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104b8e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104b95:	00 
c0104b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b99:	89 04 24             	mov    %eax,(%esp)
c0104b9c:	e8 8d fd ff ff       	call   c010492e <slob_free>
	return 0;
c0104ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104ba6:	89 ec                	mov    %ebp,%esp
c0104ba8:	5d                   	pop    %ebp
c0104ba9:	c3                   	ret    

c0104baa <kmalloc>:

//kmalloc
//size = sizeof(struct proc_struct)
void *
kmalloc(size_t size)
{
c0104baa:	55                   	push   %ebp
c0104bab:	89 e5                	mov    %esp,%ebp
c0104bad:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104bb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104bb7:	00 
c0104bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bbb:	89 04 24             	mov    %eax,(%esp)
c0104bbe:	e8 f3 fe ff ff       	call   c0104ab6 <__kmalloc>
}
c0104bc3:	89 ec                	mov    %ebp,%esp
c0104bc5:	5d                   	pop    %ebp
c0104bc6:	c3                   	ret    

c0104bc7 <kfree>:


void kfree(void *block)
{
c0104bc7:	55                   	push   %ebp
c0104bc8:	89 e5                	mov    %esp,%ebp
c0104bca:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104bcd:	c7 45 f0 90 bf 12 c0 	movl   $0xc012bf90,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104bd4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104bd8:	0f 84 a3 00 00 00    	je     c0104c81 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) { //block低十二位不是全1就行
c0104bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0104be1:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104be6:	85 c0                	test   %eax,%eax
c0104be8:	75 7f                	jne    c0104c69 <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104bea:	e8 a2 f9 ff ff       	call   c0104591 <__intr_save>
c0104bef:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104bf2:	a1 90 bf 12 c0       	mov    0xc012bf90,%eax
c0104bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104bfa:	eb 5c                	jmp    c0104c58 <kfree+0x91>
			if (bb->pages == block) {
c0104bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bff:	8b 40 04             	mov    0x4(%eax),%eax
c0104c02:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104c05:	75 3f                	jne    c0104c46 <kfree+0x7f>
				*last = bb->next;
c0104c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c0a:	8b 50 08             	mov    0x8(%eax),%edx
c0104c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c10:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c15:	89 04 24             	mov    %eax,(%esp)
c0104c18:	e8 a0 f9 ff ff       	call   c01045bd <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c20:	8b 10                	mov    (%eax),%edx
c0104c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c25:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c29:	89 04 24             	mov    %eax,(%esp)
c0104c2c:	e8 f2 fa ff ff       	call   c0104723 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104c31:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104c38:	00 
c0104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c3c:	89 04 24             	mov    %eax,(%esp)
c0104c3f:	e8 ea fc ff ff       	call   c010492e <slob_free>
				return;
c0104c44:	eb 3c                	jmp    c0104c82 <kfree+0xbb>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c49:	83 c0 08             	add    $0x8,%eax
c0104c4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c52:	8b 40 08             	mov    0x8(%eax),%eax
c0104c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104c5c:	75 9e                	jne    c0104bfc <kfree+0x35>
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c61:	89 04 24             	mov    %eax,(%esp)
c0104c64:	e8 54 f9 ff ff       	call   c01045bd <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104c69:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c6c:	83 e8 08             	sub    $0x8,%eax
c0104c6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104c76:	00 
c0104c77:	89 04 24             	mov    %eax,(%esp)
c0104c7a:	e8 af fc ff ff       	call   c010492e <slob_free>
	return;
c0104c7f:	eb 01                	jmp    c0104c82 <kfree+0xbb>
		return;
c0104c81:	90                   	nop
}
c0104c82:	89 ec                	mov    %ebp,%esp
c0104c84:	5d                   	pop    %ebp
c0104c85:	c3                   	ret    

c0104c86 <ksize>:


unsigned int ksize(const void *block)
{
c0104c86:	55                   	push   %ebp
c0104c87:	89 e5                	mov    %esp,%ebp
c0104c89:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104c8c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104c90:	75 07                	jne    c0104c99 <ksize+0x13>
		return 0;
c0104c92:	b8 00 00 00 00       	mov    $0x0,%eax
c0104c97:	eb 6b                	jmp    c0104d04 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104c99:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c9c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104ca1:	85 c0                	test   %eax,%eax
c0104ca3:	75 54                	jne    c0104cf9 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104ca5:	e8 e7 f8 ff ff       	call   c0104591 <__intr_save>
c0104caa:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104cad:	a1 90 bf 12 c0       	mov    0xc012bf90,%eax
c0104cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104cb5:	eb 31                	jmp    c0104ce8 <ksize+0x62>
			if (bb->pages == block) {
c0104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cba:	8b 40 04             	mov    0x4(%eax),%eax
c0104cbd:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104cc0:	75 1d                	jne    c0104cdf <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cc5:	89 04 24             	mov    %eax,(%esp)
c0104cc8:	e8 f0 f8 ff ff       	call   c01045bd <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cd0:	8b 00                	mov    (%eax),%eax
c0104cd2:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104cd7:	88 c1                	mov    %al,%cl
c0104cd9:	d3 e2                	shl    %cl,%edx
c0104cdb:	89 d0                	mov    %edx,%eax
c0104cdd:	eb 25                	jmp    c0104d04 <ksize+0x7e>
		for (bb = bigblocks; bb; bb = bb->next)
c0104cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ce2:	8b 40 08             	mov    0x8(%eax),%eax
c0104ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104ce8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104cec:	75 c9                	jne    c0104cb7 <ksize+0x31>
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cf1:	89 04 24             	mov    %eax,(%esp)
c0104cf4:	e8 c4 f8 ff ff       	call   c01045bd <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104cf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cfc:	83 e8 08             	sub    $0x8,%eax
c0104cff:	8b 00                	mov    (%eax),%eax
c0104d01:	c1 e0 03             	shl    $0x3,%eax
}
c0104d04:	89 ec                	mov    %ebp,%esp
c0104d06:	5d                   	pop    %ebp
c0104d07:	c3                   	ret    

c0104d08 <page2ppn>:
page2ppn(struct Page *page) {
c0104d08:	55                   	push   %ebp
c0104d09:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104d0b:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104d11:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d14:	29 d0                	sub    %edx,%eax
c0104d16:	c1 f8 05             	sar    $0x5,%eax
}
c0104d19:	5d                   	pop    %ebp
c0104d1a:	c3                   	ret    

c0104d1b <page2pa>:
page2pa(struct Page *page) {
c0104d1b:	55                   	push   %ebp
c0104d1c:	89 e5                	mov    %esp,%ebp
c0104d1e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104d21:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d24:	89 04 24             	mov    %eax,(%esp)
c0104d27:	e8 dc ff ff ff       	call   c0104d08 <page2ppn>
c0104d2c:	c1 e0 0c             	shl    $0xc,%eax
}
c0104d2f:	89 ec                	mov    %ebp,%esp
c0104d31:	5d                   	pop    %ebp
c0104d32:	c3                   	ret    

c0104d33 <pa2page>:
pa2page(uintptr_t pa) {
c0104d33:	55                   	push   %ebp
c0104d34:	89 e5                	mov    %esp,%ebp
c0104d36:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104d39:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d3c:	c1 e8 0c             	shr    $0xc,%eax
c0104d3f:	89 c2                	mov    %eax,%edx
c0104d41:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104d46:	39 c2                	cmp    %eax,%edx
c0104d48:	72 1c                	jb     c0104d66 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104d4a:	c7 44 24 08 94 ae 10 	movl   $0xc010ae94,0x8(%esp)
c0104d51:	c0 
c0104d52:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104d59:	00 
c0104d5a:	c7 04 24 b3 ae 10 c0 	movl   $0xc010aeb3,(%esp)
c0104d61:	e8 c0 bf ff ff       	call   c0100d26 <__panic>
    return &pages[PPN(pa)];
c0104d66:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104d6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d6f:	c1 e8 0c             	shr    $0xc,%eax
c0104d72:	c1 e0 05             	shl    $0x5,%eax
c0104d75:	01 d0                	add    %edx,%eax
}
c0104d77:	89 ec                	mov    %ebp,%esp
c0104d79:	5d                   	pop    %ebp
c0104d7a:	c3                   	ret    

c0104d7b <page2kva>:
page2kva(struct Page *page) {
c0104d7b:	55                   	push   %ebp
c0104d7c:	89 e5                	mov    %esp,%ebp
c0104d7e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104d81:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d84:	89 04 24             	mov    %eax,(%esp)
c0104d87:	e8 8f ff ff ff       	call   c0104d1b <page2pa>
c0104d8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d92:	c1 e8 0c             	shr    $0xc,%eax
c0104d95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d98:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0104d9d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104da0:	72 23                	jb     c0104dc5 <page2kva+0x4a>
c0104da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104da5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104da9:	c7 44 24 08 c4 ae 10 	movl   $0xc010aec4,0x8(%esp)
c0104db0:	c0 
c0104db1:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104db8:	00 
c0104db9:	c7 04 24 b3 ae 10 c0 	movl   $0xc010aeb3,(%esp)
c0104dc0:	e8 61 bf ff ff       	call   c0100d26 <__panic>
c0104dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dc8:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104dcd:	89 ec                	mov    %ebp,%esp
c0104dcf:	5d                   	pop    %ebp
c0104dd0:	c3                   	ret    

c0104dd1 <pte2page>:
pte2page(pte_t pte) {
c0104dd1:	55                   	push   %ebp
c0104dd2:	89 e5                	mov    %esp,%ebp
c0104dd4:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dda:	83 e0 01             	and    $0x1,%eax
c0104ddd:	85 c0                	test   %eax,%eax
c0104ddf:	75 1c                	jne    c0104dfd <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104de1:	c7 44 24 08 e8 ae 10 	movl   $0xc010aee8,0x8(%esp)
c0104de8:	c0 
c0104de9:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0104df0:	00 
c0104df1:	c7 04 24 b3 ae 10 c0 	movl   $0xc010aeb3,(%esp)
c0104df8:	e8 29 bf ff ff       	call   c0100d26 <__panic>
    return pa2page(PTE_ADDR(pte));
c0104dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e05:	89 04 24             	mov    %eax,(%esp)
c0104e08:	e8 26 ff ff ff       	call   c0104d33 <pa2page>
}
c0104e0d:	89 ec                	mov    %ebp,%esp
c0104e0f:	5d                   	pop    %ebp
c0104e10:	c3                   	ret    

c0104e11 <pde2page>:
pde2page(pde_t pde) {
c0104e11:	55                   	push   %ebp
c0104e12:	89 e5                	mov    %esp,%ebp
c0104e14:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104e17:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e1a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e1f:	89 04 24             	mov    %eax,(%esp)
c0104e22:	e8 0c ff ff ff       	call   c0104d33 <pa2page>
}
c0104e27:	89 ec                	mov    %ebp,%esp
c0104e29:	5d                   	pop    %ebp
c0104e2a:	c3                   	ret    

c0104e2b <page_ref>:
page_ref(struct Page *page) {
c0104e2b:	55                   	push   %ebp
c0104e2c:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104e2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e31:	8b 00                	mov    (%eax),%eax
}
c0104e33:	5d                   	pop    %ebp
c0104e34:	c3                   	ret    

c0104e35 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0104e35:	55                   	push   %ebp
c0104e36:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104e38:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104e3e:	89 10                	mov    %edx,(%eax)
}
c0104e40:	90                   	nop
c0104e41:	5d                   	pop    %ebp
c0104e42:	c3                   	ret    

c0104e43 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104e43:	55                   	push   %ebp
c0104e44:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104e46:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e49:	8b 00                	mov    (%eax),%eax
c0104e4b:	8d 50 01             	lea    0x1(%eax),%edx
c0104e4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e51:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104e53:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e56:	8b 00                	mov    (%eax),%eax
}
c0104e58:	5d                   	pop    %ebp
c0104e59:	c3                   	ret    

c0104e5a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104e5a:	55                   	push   %ebp
c0104e5b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104e5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e60:	8b 00                	mov    (%eax),%eax
c0104e62:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e68:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104e6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e6d:	8b 00                	mov    (%eax),%eax
}
c0104e6f:	5d                   	pop    %ebp
c0104e70:	c3                   	ret    

c0104e71 <__intr_save>:
__intr_save(void) {
c0104e71:	55                   	push   %ebp
c0104e72:	89 e5                	mov    %esp,%ebp
c0104e74:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104e77:	9c                   	pushf  
c0104e78:	58                   	pop    %eax
c0104e79:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104e7f:	25 00 02 00 00       	and    $0x200,%eax
c0104e84:	85 c0                	test   %eax,%eax
c0104e86:	74 0c                	je     c0104e94 <__intr_save+0x23>
        intr_disable();
c0104e88:	e8 4f d1 ff ff       	call   c0101fdc <intr_disable>
        return 1;
c0104e8d:	b8 01 00 00 00       	mov    $0x1,%eax
c0104e92:	eb 05                	jmp    c0104e99 <__intr_save+0x28>
    return 0;
c0104e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104e99:	89 ec                	mov    %ebp,%esp
c0104e9b:	5d                   	pop    %ebp
c0104e9c:	c3                   	ret    

c0104e9d <__intr_restore>:
__intr_restore(bool flag) {
c0104e9d:	55                   	push   %ebp
c0104e9e:	89 e5                	mov    %esp,%ebp
c0104ea0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104ea3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ea7:	74 05                	je     c0104eae <__intr_restore+0x11>
        intr_enable();
c0104ea9:	e8 26 d1 ff ff       	call   c0101fd4 <intr_enable>
}
c0104eae:	90                   	nop
c0104eaf:	89 ec                	mov    %ebp,%esp
c0104eb1:	5d                   	pop    %ebp
c0104eb2:	c3                   	ret    

c0104eb3 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104eb3:	55                   	push   %ebp
c0104eb4:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104eb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eb9:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104ebc:	b8 23 00 00 00       	mov    $0x23,%eax
c0104ec1:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104ec3:	b8 23 00 00 00       	mov    $0x23,%eax
c0104ec8:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104eca:	b8 10 00 00 00       	mov    $0x10,%eax
c0104ecf:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104ed1:	b8 10 00 00 00       	mov    $0x10,%eax
c0104ed6:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104ed8:	b8 10 00 00 00       	mov    $0x10,%eax
c0104edd:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104edf:	ea e6 4e 10 c0 08 00 	ljmp   $0x8,$0xc0104ee6
}
c0104ee6:	90                   	nop
c0104ee7:	5d                   	pop    %ebp
c0104ee8:	c3                   	ret    

c0104ee9 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104ee9:	55                   	push   %ebp
c0104eea:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104eec:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eef:	a3 c4 bf 12 c0       	mov    %eax,0xc012bfc4
}
c0104ef4:	90                   	nop
c0104ef5:	5d                   	pop    %ebp
c0104ef6:	c3                   	ret    

c0104ef7 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104ef7:	55                   	push   %ebp
c0104ef8:	89 e5                	mov    %esp,%ebp
c0104efa:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104efd:	b8 00 80 12 c0       	mov    $0xc0128000,%eax
c0104f02:	89 04 24             	mov    %eax,(%esp)
c0104f05:	e8 df ff ff ff       	call   c0104ee9 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104f0a:	66 c7 05 c8 bf 12 c0 	movw   $0x10,0xc012bfc8
c0104f11:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104f13:	66 c7 05 48 8a 12 c0 	movw   $0x68,0xc0128a48
c0104f1a:	68 00 
c0104f1c:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0104f21:	0f b7 c0             	movzwl %ax,%eax
c0104f24:	66 a3 4a 8a 12 c0    	mov    %ax,0xc0128a4a
c0104f2a:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0104f2f:	c1 e8 10             	shr    $0x10,%eax
c0104f32:	a2 4c 8a 12 c0       	mov    %al,0xc0128a4c
c0104f37:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104f3e:	24 f0                	and    $0xf0,%al
c0104f40:	0c 09                	or     $0x9,%al
c0104f42:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104f47:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104f4e:	24 ef                	and    $0xef,%al
c0104f50:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104f55:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104f5c:	24 9f                	and    $0x9f,%al
c0104f5e:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104f63:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0104f6a:	0c 80                	or     $0x80,%al
c0104f6c:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c0104f71:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104f78:	24 f0                	and    $0xf0,%al
c0104f7a:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104f7f:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104f86:	24 ef                	and    $0xef,%al
c0104f88:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104f8d:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104f94:	24 df                	and    $0xdf,%al
c0104f96:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104f9b:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104fa2:	0c 40                	or     $0x40,%al
c0104fa4:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104fa9:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0104fb0:	24 7f                	and    $0x7f,%al
c0104fb2:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0104fb7:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0104fbc:	c1 e8 18             	shr    $0x18,%eax
c0104fbf:	a2 4f 8a 12 c0       	mov    %al,0xc0128a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c0104fc4:	c7 04 24 50 8a 12 c0 	movl   $0xc0128a50,(%esp)
c0104fcb:	e8 e3 fe ff ff       	call   c0104eb3 <lgdt>
c0104fd0:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0104fd6:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0104fda:	0f 00 d8             	ltr    %ax
}
c0104fdd:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0104fde:	90                   	nop
c0104fdf:	89 ec                	mov    %ebp,%esp
c0104fe1:	5d                   	pop    %ebp
c0104fe2:	c3                   	ret    

c0104fe3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0104fe3:	55                   	push   %ebp
c0104fe4:	89 e5                	mov    %esp,%ebp
c0104fe6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0104fe9:	c7 05 ac bf 12 c0 88 	movl   $0xc010ad88,0xc012bfac
c0104ff0:	ad 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104ff3:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0104ff8:	8b 00                	mov    (%eax),%eax
c0104ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ffe:	c7 04 24 14 af 10 c0 	movl   $0xc010af14,(%esp)
c0105005:	e8 6e b3 ff ff       	call   c0100378 <cprintf>
    pmm_manager->init();
c010500a:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c010500f:	8b 40 04             	mov    0x4(%eax),%eax
c0105012:	ff d0                	call   *%eax
}
c0105014:	90                   	nop
c0105015:	89 ec                	mov    %ebp,%esp
c0105017:	5d                   	pop    %ebp
c0105018:	c3                   	ret    

c0105019 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0105019:	55                   	push   %ebp
c010501a:	89 e5                	mov    %esp,%ebp
c010501c:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010501f:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105024:	8b 40 08             	mov    0x8(%eax),%eax
c0105027:	8b 55 0c             	mov    0xc(%ebp),%edx
c010502a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010502e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105031:	89 14 24             	mov    %edx,(%esp)
c0105034:	ff d0                	call   *%eax
}
c0105036:	90                   	nop
c0105037:	89 ec                	mov    %ebp,%esp
c0105039:	5d                   	pop    %ebp
c010503a:	c3                   	ret    

c010503b <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010503b:	55                   	push   %ebp
c010503c:	89 e5                	mov    %esp,%ebp
c010503e:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0105041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0105048:	e8 24 fe ff ff       	call   c0104e71 <__intr_save>
c010504d:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0105050:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105055:	8b 40 0c             	mov    0xc(%eax),%eax
c0105058:	8b 55 08             	mov    0x8(%ebp),%edx
c010505b:	89 14 24             	mov    %edx,(%esp)
c010505e:	ff d0                	call   *%eax
c0105060:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0105063:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105066:	89 04 24             	mov    %eax,(%esp)
c0105069:	e8 2f fe ff ff       	call   c0104e9d <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c010506e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105072:	75 2d                	jne    c01050a1 <alloc_pages+0x66>
c0105074:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0105078:	77 27                	ja     c01050a1 <alloc_pages+0x66>
c010507a:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c010507f:	85 c0                	test   %eax,%eax
c0105081:	74 1e                	je     c01050a1 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0105083:	8b 55 08             	mov    0x8(%ebp),%edx
c0105086:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c010508b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105092:	00 
c0105093:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105097:	89 04 24             	mov    %eax,(%esp)
c010509a:	e8 cf 18 00 00       	call   c010696e <swap_out>
    {
c010509f:	eb a7                	jmp    c0105048 <alloc_pages+0xd>
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01050a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01050a4:	89 ec                	mov    %ebp,%esp
c01050a6:	5d                   	pop    %ebp
c01050a7:	c3                   	ret    

c01050a8 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01050a8:	55                   	push   %ebp
c01050a9:	89 e5                	mov    %esp,%ebp
c01050ab:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01050ae:	e8 be fd ff ff       	call   c0104e71 <__intr_save>
c01050b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01050b6:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c01050bb:	8b 40 10             	mov    0x10(%eax),%eax
c01050be:	8b 55 0c             	mov    0xc(%ebp),%edx
c01050c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01050c5:	8b 55 08             	mov    0x8(%ebp),%edx
c01050c8:	89 14 24             	mov    %edx,(%esp)
c01050cb:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01050cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050d0:	89 04 24             	mov    %eax,(%esp)
c01050d3:	e8 c5 fd ff ff       	call   c0104e9d <__intr_restore>
}
c01050d8:	90                   	nop
c01050d9:	89 ec                	mov    %ebp,%esp
c01050db:	5d                   	pop    %ebp
c01050dc:	c3                   	ret    

c01050dd <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01050dd:	55                   	push   %ebp
c01050de:	89 e5                	mov    %esp,%ebp
c01050e0:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01050e3:	e8 89 fd ff ff       	call   c0104e71 <__intr_save>
c01050e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01050eb:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c01050f0:	8b 40 14             	mov    0x14(%eax),%eax
c01050f3:	ff d0                	call   *%eax
c01050f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01050f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050fb:	89 04 24             	mov    %eax,(%esp)
c01050fe:	e8 9a fd ff ff       	call   c0104e9d <__intr_restore>
    return ret;
c0105103:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0105106:	89 ec                	mov    %ebp,%esp
c0105108:	5d                   	pop    %ebp
c0105109:	c3                   	ret    

c010510a <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010510a:	55                   	push   %ebp
c010510b:	89 e5                	mov    %esp,%ebp
c010510d:	57                   	push   %edi
c010510e:	56                   	push   %esi
c010510f:	53                   	push   %ebx
c0105110:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0105116:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010511d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105124:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010512b:	c7 04 24 2b af 10 c0 	movl   $0xc010af2b,(%esp)
c0105132:	e8 41 b2 ff ff       	call   c0100378 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105137:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010513e:	e9 0c 01 00 00       	jmp    c010524f <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105143:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105146:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105149:	89 d0                	mov    %edx,%eax
c010514b:	c1 e0 02             	shl    $0x2,%eax
c010514e:	01 d0                	add    %edx,%eax
c0105150:	c1 e0 02             	shl    $0x2,%eax
c0105153:	01 c8                	add    %ecx,%eax
c0105155:	8b 50 08             	mov    0x8(%eax),%edx
c0105158:	8b 40 04             	mov    0x4(%eax),%eax
c010515b:	89 45 a0             	mov    %eax,-0x60(%ebp)
c010515e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0105161:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105164:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105167:	89 d0                	mov    %edx,%eax
c0105169:	c1 e0 02             	shl    $0x2,%eax
c010516c:	01 d0                	add    %edx,%eax
c010516e:	c1 e0 02             	shl    $0x2,%eax
c0105171:	01 c8                	add    %ecx,%eax
c0105173:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105176:	8b 58 10             	mov    0x10(%eax),%ebx
c0105179:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010517c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010517f:	01 c8                	add    %ecx,%eax
c0105181:	11 da                	adc    %ebx,%edx
c0105183:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105186:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0105189:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010518c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010518f:	89 d0                	mov    %edx,%eax
c0105191:	c1 e0 02             	shl    $0x2,%eax
c0105194:	01 d0                	add    %edx,%eax
c0105196:	c1 e0 02             	shl    $0x2,%eax
c0105199:	01 c8                	add    %ecx,%eax
c010519b:	83 c0 14             	add    $0x14,%eax
c010519e:	8b 00                	mov    (%eax),%eax
c01051a0:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01051a6:	8b 45 98             	mov    -0x68(%ebp),%eax
c01051a9:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01051ac:	83 c0 ff             	add    $0xffffffff,%eax
c01051af:	83 d2 ff             	adc    $0xffffffff,%edx
c01051b2:	89 c6                	mov    %eax,%esi
c01051b4:	89 d7                	mov    %edx,%edi
c01051b6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01051b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01051bc:	89 d0                	mov    %edx,%eax
c01051be:	c1 e0 02             	shl    $0x2,%eax
c01051c1:	01 d0                	add    %edx,%eax
c01051c3:	c1 e0 02             	shl    $0x2,%eax
c01051c6:	01 c8                	add    %ecx,%eax
c01051c8:	8b 48 0c             	mov    0xc(%eax),%ecx
c01051cb:	8b 58 10             	mov    0x10(%eax),%ebx
c01051ce:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01051d4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01051d8:	89 74 24 14          	mov    %esi,0x14(%esp)
c01051dc:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01051e0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01051e3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01051e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01051ea:	89 54 24 10          	mov    %edx,0x10(%esp)
c01051ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01051f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01051f6:	c7 04 24 38 af 10 c0 	movl   $0xc010af38,(%esp)
c01051fd:	e8 76 b1 ff ff       	call   c0100378 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0105202:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105205:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105208:	89 d0                	mov    %edx,%eax
c010520a:	c1 e0 02             	shl    $0x2,%eax
c010520d:	01 d0                	add    %edx,%eax
c010520f:	c1 e0 02             	shl    $0x2,%eax
c0105212:	01 c8                	add    %ecx,%eax
c0105214:	83 c0 14             	add    $0x14,%eax
c0105217:	8b 00                	mov    (%eax),%eax
c0105219:	83 f8 01             	cmp    $0x1,%eax
c010521c:	75 2e                	jne    c010524c <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c010521e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105221:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105224:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0105227:	89 d0                	mov    %edx,%eax
c0105229:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c010522c:	73 1e                	jae    c010524c <page_init+0x142>
c010522e:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0105233:	b8 00 00 00 00       	mov    $0x0,%eax
c0105238:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c010523b:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010523e:	72 0c                	jb     c010524c <page_init+0x142>
                maxpa = end;
c0105240:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105243:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105246:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105249:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c010524c:	ff 45 dc             	incl   -0x24(%ebp)
c010524f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105252:	8b 00                	mov    (%eax),%eax
c0105254:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105257:	0f 8c e6 fe ff ff    	jl     c0105143 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010525d:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0105262:	b8 00 00 00 00       	mov    $0x0,%eax
c0105267:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c010526a:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c010526d:	73 0e                	jae    c010527d <page_init+0x173>
        maxpa = KMEMSIZE;
c010526f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0105276:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010527d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105280:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105283:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105287:	c1 ea 0c             	shr    $0xc,%edx
c010528a:	a3 a4 bf 12 c0       	mov    %eax,0xc012bfa4
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010528f:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0105296:	b8 54 e1 12 c0       	mov    $0xc012e154,%eax
c010529b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010529e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01052a1:	01 d0                	add    %edx,%eax
c01052a3:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01052a6:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01052a9:	ba 00 00 00 00       	mov    $0x0,%edx
c01052ae:	f7 75 c0             	divl   -0x40(%ebp)
c01052b1:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01052b4:	29 d0                	sub    %edx,%eax
c01052b6:	a3 a0 bf 12 c0       	mov    %eax,0xc012bfa0

    for (i = 0; i < npage; i ++) {
c01052bb:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01052c2:	eb 28                	jmp    c01052ec <page_init+0x1e2>
        SetPageReserved(pages + i);
c01052c4:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01052ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01052cd:	c1 e0 05             	shl    $0x5,%eax
c01052d0:	01 d0                	add    %edx,%eax
c01052d2:	83 c0 04             	add    $0x4,%eax
c01052d5:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01052dc:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01052df:	8b 45 90             	mov    -0x70(%ebp),%eax
c01052e2:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01052e5:	0f ab 10             	bts    %edx,(%eax)
}
c01052e8:	90                   	nop
    for (i = 0; i < npage; i ++) {
c01052e9:	ff 45 dc             	incl   -0x24(%ebp)
c01052ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052ef:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01052f4:	39 c2                	cmp    %eax,%edx
c01052f6:	72 cc                	jb     c01052c4 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01052f8:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01052fd:	c1 e0 05             	shl    $0x5,%eax
c0105300:	89 c2                	mov    %eax,%edx
c0105302:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0105307:	01 d0                	add    %edx,%eax
c0105309:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010530c:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0105313:	77 23                	ja     c0105338 <page_init+0x22e>
c0105315:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105318:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010531c:	c7 44 24 08 68 af 10 	movl   $0xc010af68,0x8(%esp)
c0105323:	c0 
c0105324:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c010532b:	00 
c010532c:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105333:	e8 ee b9 ff ff       	call   c0100d26 <__panic>
c0105338:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010533b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105340:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0105343:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010534a:	e9 53 01 00 00       	jmp    c01054a2 <page_init+0x398>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010534f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105352:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105355:	89 d0                	mov    %edx,%eax
c0105357:	c1 e0 02             	shl    $0x2,%eax
c010535a:	01 d0                	add    %edx,%eax
c010535c:	c1 e0 02             	shl    $0x2,%eax
c010535f:	01 c8                	add    %ecx,%eax
c0105361:	8b 50 08             	mov    0x8(%eax),%edx
c0105364:	8b 40 04             	mov    0x4(%eax),%eax
c0105367:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010536a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010536d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105370:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105373:	89 d0                	mov    %edx,%eax
c0105375:	c1 e0 02             	shl    $0x2,%eax
c0105378:	01 d0                	add    %edx,%eax
c010537a:	c1 e0 02             	shl    $0x2,%eax
c010537d:	01 c8                	add    %ecx,%eax
c010537f:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105382:	8b 58 10             	mov    0x10(%eax),%ebx
c0105385:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105388:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010538b:	01 c8                	add    %ecx,%eax
c010538d:	11 da                	adc    %ebx,%edx
c010538f:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105392:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0105395:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105398:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010539b:	89 d0                	mov    %edx,%eax
c010539d:	c1 e0 02             	shl    $0x2,%eax
c01053a0:	01 d0                	add    %edx,%eax
c01053a2:	c1 e0 02             	shl    $0x2,%eax
c01053a5:	01 c8                	add    %ecx,%eax
c01053a7:	83 c0 14             	add    $0x14,%eax
c01053aa:	8b 00                	mov    (%eax),%eax
c01053ac:	83 f8 01             	cmp    $0x1,%eax
c01053af:	0f 85 ea 00 00 00    	jne    c010549f <page_init+0x395>
            if (begin < freemem) {
c01053b5:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053b8:	ba 00 00 00 00       	mov    $0x0,%edx
c01053bd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01053c0:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01053c3:	19 d1                	sbb    %edx,%ecx
c01053c5:	73 0d                	jae    c01053d4 <page_init+0x2ca>
                begin = freemem;
c01053c7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01053cd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01053d4:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01053d9:	b8 00 00 00 00       	mov    $0x0,%eax
c01053de:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c01053e1:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01053e4:	73 0e                	jae    c01053f4 <page_init+0x2ea>
                end = KMEMSIZE;
c01053e6:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01053ed:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01053f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01053f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053fa:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01053fd:	89 d0                	mov    %edx,%eax
c01053ff:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105402:	0f 83 97 00 00 00    	jae    c010549f <page_init+0x395>
                begin = ROUNDUP(begin, PGSIZE);
c0105408:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c010540f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105412:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105415:	01 d0                	add    %edx,%eax
c0105417:	48                   	dec    %eax
c0105418:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010541b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010541e:	ba 00 00 00 00       	mov    $0x0,%edx
c0105423:	f7 75 b0             	divl   -0x50(%ebp)
c0105426:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105429:	29 d0                	sub    %edx,%eax
c010542b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105430:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105433:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0105436:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105439:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010543c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010543f:	ba 00 00 00 00       	mov    $0x0,%edx
c0105444:	89 c7                	mov    %eax,%edi
c0105446:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010544c:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010544f:	89 d0                	mov    %edx,%eax
c0105451:	83 e0 00             	and    $0x0,%eax
c0105454:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0105457:	8b 45 80             	mov    -0x80(%ebp),%eax
c010545a:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010545d:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105460:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0105463:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105466:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105469:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010546c:	89 d0                	mov    %edx,%eax
c010546e:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0105471:	73 2c                	jae    c010549f <page_init+0x395>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0105473:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105476:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105479:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010547c:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010547f:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105483:	c1 ea 0c             	shr    $0xc,%edx
c0105486:	89 c3                	mov    %eax,%ebx
c0105488:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010548b:	89 04 24             	mov    %eax,(%esp)
c010548e:	e8 a0 f8 ff ff       	call   c0104d33 <pa2page>
c0105493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0105497:	89 04 24             	mov    %eax,(%esp)
c010549a:	e8 7a fb ff ff       	call   c0105019 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010549f:	ff 45 dc             	incl   -0x24(%ebp)
c01054a2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01054a5:	8b 00                	mov    (%eax),%eax
c01054a7:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01054aa:	0f 8c 9f fe ff ff    	jl     c010534f <page_init+0x245>
                }
            }
        }
    }
}
c01054b0:	90                   	nop
c01054b1:	90                   	nop
c01054b2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01054b8:	5b                   	pop    %ebx
c01054b9:	5e                   	pop    %esi
c01054ba:	5f                   	pop    %edi
c01054bb:	5d                   	pop    %ebp
c01054bc:	c3                   	ret    

c01054bd <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01054bd:	55                   	push   %ebp
c01054be:	89 e5                	mov    %esp,%ebp
c01054c0:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01054c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054c6:	33 45 14             	xor    0x14(%ebp),%eax
c01054c9:	25 ff 0f 00 00       	and    $0xfff,%eax
c01054ce:	85 c0                	test   %eax,%eax
c01054d0:	74 24                	je     c01054f6 <boot_map_segment+0x39>
c01054d2:	c7 44 24 0c 9a af 10 	movl   $0xc010af9a,0xc(%esp)
c01054d9:	c0 
c01054da:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01054e1:	c0 
c01054e2:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01054e9:	00 
c01054ea:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01054f1:	e8 30 b8 ff ff       	call   c0100d26 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01054f6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01054fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105500:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105505:	89 c2                	mov    %eax,%edx
c0105507:	8b 45 10             	mov    0x10(%ebp),%eax
c010550a:	01 c2                	add    %eax,%edx
c010550c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010550f:	01 d0                	add    %edx,%eax
c0105511:	48                   	dec    %eax
c0105512:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105515:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105518:	ba 00 00 00 00       	mov    $0x0,%edx
c010551d:	f7 75 f0             	divl   -0x10(%ebp)
c0105520:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105523:	29 d0                	sub    %edx,%eax
c0105525:	c1 e8 0c             	shr    $0xc,%eax
c0105528:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010552b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010552e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105531:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105534:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105539:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010553c:	8b 45 14             	mov    0x14(%ebp),%eax
c010553f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105542:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105545:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010554a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010554d:	eb 68                	jmp    c01055b7 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010554f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105556:	00 
c0105557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010555a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010555e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105561:	89 04 24             	mov    %eax,(%esp)
c0105564:	e8 8d 01 00 00       	call   c01056f6 <get_pte>
c0105569:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010556c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105570:	75 24                	jne    c0105596 <boot_map_segment+0xd9>
c0105572:	c7 44 24 0c c6 af 10 	movl   $0xc010afc6,0xc(%esp)
c0105579:	c0 
c010557a:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105581:	c0 
c0105582:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0105589:	00 
c010558a:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105591:	e8 90 b7 ff ff       	call   c0100d26 <__panic>
        *ptep = pa | PTE_P | perm;
c0105596:	8b 45 14             	mov    0x14(%ebp),%eax
c0105599:	0b 45 18             	or     0x18(%ebp),%eax
c010559c:	83 c8 01             	or     $0x1,%eax
c010559f:	89 c2                	mov    %eax,%edx
c01055a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055a4:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01055a6:	ff 4d f4             	decl   -0xc(%ebp)
c01055a9:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01055b0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01055b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01055bb:	75 92                	jne    c010554f <boot_map_segment+0x92>
    }
}
c01055bd:	90                   	nop
c01055be:	90                   	nop
c01055bf:	89 ec                	mov    %ebp,%esp
c01055c1:	5d                   	pop    %ebp
c01055c2:	c3                   	ret    

c01055c3 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01055c3:	55                   	push   %ebp
c01055c4:	89 e5                	mov    %esp,%ebp
c01055c6:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01055c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01055d0:	e8 66 fa ff ff       	call   c010503b <alloc_pages>
c01055d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01055d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01055dc:	75 1c                	jne    c01055fa <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01055de:	c7 44 24 08 d3 af 10 	movl   $0xc010afd3,0x8(%esp)
c01055e5:	c0 
c01055e6:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01055ed:	00 
c01055ee:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01055f5:	e8 2c b7 ff ff       	call   c0100d26 <__panic>
    }
    return page2kva(p);
c01055fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055fd:	89 04 24             	mov    %eax,(%esp)
c0105600:	e8 76 f7 ff ff       	call   c0104d7b <page2kva>
}
c0105605:	89 ec                	mov    %ebp,%esp
c0105607:	5d                   	pop    %ebp
c0105608:	c3                   	ret    

c0105609 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0105609:	55                   	push   %ebp
c010560a:	89 e5                	mov    %esp,%ebp
c010560c:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010560f:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105614:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105617:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010561e:	77 23                	ja     c0105643 <pmm_init+0x3a>
c0105620:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105623:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105627:	c7 44 24 08 68 af 10 	movl   $0xc010af68,0x8(%esp)
c010562e:	c0 
c010562f:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0105636:	00 
c0105637:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c010563e:	e8 e3 b6 ff ff       	call   c0100d26 <__panic>
c0105643:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105646:	05 00 00 00 40       	add    $0x40000000,%eax
c010564b:	a3 a8 bf 12 c0       	mov    %eax,0xc012bfa8
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0105650:	e8 8e f9 ff ff       	call   c0104fe3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0105655:	e8 b0 fa ff ff       	call   c010510a <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010565a:	e8 c9 04 00 00       	call   c0105b28 <check_alloc_page>

    check_pgdir();
c010565f:	e8 e5 04 00 00       	call   c0105b49 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0105664:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105669:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010566c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0105673:	77 23                	ja     c0105698 <pmm_init+0x8f>
c0105675:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105678:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010567c:	c7 44 24 08 68 af 10 	movl   $0xc010af68,0x8(%esp)
c0105683:	c0 
c0105684:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010568b:	00 
c010568c:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105693:	e8 8e b6 ff ff       	call   c0100d26 <__panic>
c0105698:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010569b:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01056a1:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01056a6:	05 ac 0f 00 00       	add    $0xfac,%eax
c01056ab:	83 ca 03             	or     $0x3,%edx
c01056ae:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01056b0:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01056b5:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01056bc:	00 
c01056bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01056c4:	00 
c01056c5:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01056cc:	38 
c01056cd:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01056d4:	c0 
c01056d5:	89 04 24             	mov    %eax,(%esp)
c01056d8:	e8 e0 fd ff ff       	call   c01054bd <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01056dd:	e8 15 f8 ff ff       	call   c0104ef7 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01056e2:	e8 00 0b 00 00       	call   c01061e7 <check_boot_pgdir>

    print_pgdir();
c01056e7:	e8 7d 0f 00 00       	call   c0106669 <print_pgdir>
    
    kmalloc_init();
c01056ec:	e8 70 f3 ff ff       	call   c0104a61 <kmalloc_init>

}
c01056f1:	90                   	nop
c01056f2:	89 ec                	mov    %ebp,%esp
c01056f4:	5d                   	pop    %ebp
c01056f5:	c3                   	ret    

c01056f6 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01056f6:	55                   	push   %ebp
c01056f7:	89 e5                	mov    %esp,%ebp
c01056f9:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];//PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
c01056fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056ff:	c1 e8 16             	shr    $0x16,%eax
c0105702:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105709:	8b 45 08             	mov    0x8(%ebp),%eax
c010570c:	01 d0                	add    %edx,%eax
c010570e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {       //PTE_P           0x001                   // page table/directory entry flags bit : Present
c0105711:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105714:	8b 00                	mov    (%eax),%eax
c0105716:	83 e0 01             	and    $0x1,%eax
c0105719:	85 c0                	test   %eax,%eax
c010571b:	0f 85 b9 00 00 00    	jne    c01057da <get_pte+0xe4>
        if(!create){                //check if creating is needed
c0105721:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105725:	75 0a                	jne    c0105731 <get_pte+0x3b>
            return NULL;
c0105727:	b8 00 00 00 00       	mov    $0x0,%eax
c010572c:	e9 06 01 00 00       	jmp    c0105837 <get_pte+0x141>
        }   
        struct Page *page=alloc_page();    
c0105731:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105738:	e8 fe f8 ff ff       	call   c010503b <alloc_pages>
c010573d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if(page==NULL){
c0105740:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105744:	75 0a                	jne    c0105750 <get_pte+0x5a>
            return NULL;
c0105746:	b8 00 00 00 00       	mov    $0x0,%eax
c010574b:	e9 e7 00 00 00       	jmp    c0105837 <get_pte+0x141>
        } 
        set_page_ref(page,1);  //set page reference 物理页被引用一次
c0105750:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105757:	00 
c0105758:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010575b:	89 04 24             	mov    %eax,(%esp)
c010575e:	e8 d2 f6 ff ff       	call   c0104e35 <set_page_ref>
        uintptr_t pa=page2pa(page);//page2pa(page): get the physical address of memory which this (struct Page *) page  manages
c0105763:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105766:	89 04 24             	mov    %eax,(%esp)
c0105769:	e8 ad f5 ff ff       	call   c0104d1b <page2pa>
c010576e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa),0,PGSIZE);//clear page content using memset 新申请的页必须全部设定为零，因为这个页所代表的虚拟地址都没有被映射。
c0105771:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105774:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105777:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010577a:	c1 e8 0c             	shr    $0xc,%eax
c010577d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105780:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0105785:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0105788:	72 23                	jb     c01057ad <get_pte+0xb7>
c010578a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010578d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105791:	c7 44 24 08 c4 ae 10 	movl   $0xc010aec4,0x8(%esp)
c0105798:	c0 
c0105799:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c01057a0:	00 
c01057a1:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01057a8:	e8 79 b5 ff ff       	call   c0100d26 <__panic>
c01057ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01057b0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01057b5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01057bc:	00 
c01057bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01057c4:	00 
c01057c5:	89 04 24             	mov    %eax,(%esp)
c01057c8:	e8 6c 47 00 00       	call   c0109f39 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;//set page directory entry's permission   ???存疑
c01057cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057d0:	83 c8 07             	or     $0x7,%eax
c01057d3:	89 c2                	mov    %eax,%edx
c01057d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057d8:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01057da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057dd:	8b 00                	mov    (%eax),%eax
c01057df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01057e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01057e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057ea:	c1 e8 0c             	shr    $0xc,%eax
c01057ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01057f0:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01057f5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01057f8:	72 23                	jb     c010581d <get_pte+0x127>
c01057fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105801:	c7 44 24 08 c4 ae 10 	movl   $0xc010aec4,0x8(%esp)
c0105808:	c0 
c0105809:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0105810:	00 
c0105811:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105818:	e8 09 b5 ff ff       	call   c0100d26 <__panic>
c010581d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105820:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105825:	89 c2                	mov    %eax,%edx
c0105827:	8b 45 0c             	mov    0xc(%ebp),%eax
c010582a:	c1 e8 0c             	shr    $0xc,%eax
c010582d:	25 ff 03 00 00       	and    $0x3ff,%eax
c0105832:	c1 e0 02             	shl    $0x2,%eax
c0105835:	01 d0                	add    %edx,%eax
}
c0105837:	89 ec                	mov    %ebp,%esp
c0105839:	5d                   	pop    %ebp
c010583a:	c3                   	ret    

c010583b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010583b:	55                   	push   %ebp
c010583c:	89 e5                	mov    %esp,%ebp
c010583e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105841:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105848:	00 
c0105849:	8b 45 0c             	mov    0xc(%ebp),%eax
c010584c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105850:	8b 45 08             	mov    0x8(%ebp),%eax
c0105853:	89 04 24             	mov    %eax,(%esp)
c0105856:	e8 9b fe ff ff       	call   c01056f6 <get_pte>
c010585b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010585e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105862:	74 08                	je     c010586c <get_page+0x31>
        *ptep_store = ptep;
c0105864:	8b 45 10             	mov    0x10(%ebp),%eax
c0105867:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010586a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010586c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105870:	74 1b                	je     c010588d <get_page+0x52>
c0105872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105875:	8b 00                	mov    (%eax),%eax
c0105877:	83 e0 01             	and    $0x1,%eax
c010587a:	85 c0                	test   %eax,%eax
c010587c:	74 0f                	je     c010588d <get_page+0x52>
        return pte2page(*ptep);
c010587e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105881:	8b 00                	mov    (%eax),%eax
c0105883:	89 04 24             	mov    %eax,(%esp)
c0105886:	e8 46 f5 ff ff       	call   c0104dd1 <pte2page>
c010588b:	eb 05                	jmp    c0105892 <get_page+0x57>
    }
    return NULL;
c010588d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105892:	89 ec                	mov    %ebp,%esp
c0105894:	5d                   	pop    %ebp
c0105895:	c3                   	ret    

c0105896 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105896:	55                   	push   %ebp
c0105897:	89 e5                	mov    %esp,%ebp
c0105899:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {                        //(1) check if this page table entry is present
c010589c:	8b 45 10             	mov    0x10(%ebp),%eax
c010589f:	8b 00                	mov    (%eax),%eax
c01058a1:	83 e0 01             	and    $0x1,%eax
c01058a4:	85 c0                	test   %eax,%eax
c01058a6:	74 4d                	je     c01058f5 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c01058a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01058ab:	8b 00                	mov    (%eax),%eax
c01058ad:	89 04 24             	mov    %eax,(%esp)
c01058b0:	e8 1c f5 ff ff       	call   c0104dd1 <pte2page>
c01058b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c01058b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058bb:	89 04 24             	mov    %eax,(%esp)
c01058be:	e8 97 f5 ff ff       	call   c0104e5a <page_ref_dec>
c01058c3:	85 c0                	test   %eax,%eax
c01058c5:	75 13                	jne    c01058da <page_remove_pte+0x44>
            free_page(page);
c01058c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01058ce:	00 
c01058cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058d2:	89 04 24             	mov    %eax,(%esp)
c01058d5:	e8 ce f7 ff ff       	call   c01050a8 <free_pages>
        }
        *ptep = 0;
c01058da:	8b 45 10             	mov    0x10(%ebp),%eax
c01058dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01058e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01058ed:	89 04 24             	mov    %eax,(%esp)
c01058f0:	e8 07 01 00 00       	call   c01059fc <tlb_invalidate>
    }
}
c01058f5:	90                   	nop
c01058f6:	89 ec                	mov    %ebp,%esp
c01058f8:	5d                   	pop    %ebp
c01058f9:	c3                   	ret    

c01058fa <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01058fa:	55                   	push   %ebp
c01058fb:	89 e5                	mov    %esp,%ebp
c01058fd:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105900:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105907:	00 
c0105908:	8b 45 0c             	mov    0xc(%ebp),%eax
c010590b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010590f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105912:	89 04 24             	mov    %eax,(%esp)
c0105915:	e8 dc fd ff ff       	call   c01056f6 <get_pte>
c010591a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010591d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105921:	74 19                	je     c010593c <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105923:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105926:	89 44 24 08          	mov    %eax,0x8(%esp)
c010592a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010592d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105931:	8b 45 08             	mov    0x8(%ebp),%eax
c0105934:	89 04 24             	mov    %eax,(%esp)
c0105937:	e8 5a ff ff ff       	call   c0105896 <page_remove_pte>
    }
}
c010593c:	90                   	nop
c010593d:	89 ec                	mov    %ebp,%esp
c010593f:	5d                   	pop    %ebp
c0105940:	c3                   	ret    

c0105941 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105941:	55                   	push   %ebp
c0105942:	89 e5                	mov    %esp,%ebp
c0105944:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105947:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010594e:	00 
c010594f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105952:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105956:	8b 45 08             	mov    0x8(%ebp),%eax
c0105959:	89 04 24             	mov    %eax,(%esp)
c010595c:	e8 95 fd ff ff       	call   c01056f6 <get_pte>
c0105961:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105964:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105968:	75 0a                	jne    c0105974 <page_insert+0x33>
        return -E_NO_MEM;
c010596a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010596f:	e9 84 00 00 00       	jmp    c01059f8 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105974:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105977:	89 04 24             	mov    %eax,(%esp)
c010597a:	e8 c4 f4 ff ff       	call   c0104e43 <page_ref_inc>
    if (*ptep & PTE_P) {
c010597f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105982:	8b 00                	mov    (%eax),%eax
c0105984:	83 e0 01             	and    $0x1,%eax
c0105987:	85 c0                	test   %eax,%eax
c0105989:	74 3e                	je     c01059c9 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010598b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010598e:	8b 00                	mov    (%eax),%eax
c0105990:	89 04 24             	mov    %eax,(%esp)
c0105993:	e8 39 f4 ff ff       	call   c0104dd1 <pte2page>
c0105998:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010599b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010599e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01059a1:	75 0d                	jne    c01059b0 <page_insert+0x6f>
            page_ref_dec(page);
c01059a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059a6:	89 04 24             	mov    %eax,(%esp)
c01059a9:	e8 ac f4 ff ff       	call   c0104e5a <page_ref_dec>
c01059ae:	eb 19                	jmp    c01059c9 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01059b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059b7:	8b 45 10             	mov    0x10(%ebp),%eax
c01059ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059be:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c1:	89 04 24             	mov    %eax,(%esp)
c01059c4:	e8 cd fe ff ff       	call   c0105896 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01059c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059cc:	89 04 24             	mov    %eax,(%esp)
c01059cf:	e8 47 f3 ff ff       	call   c0104d1b <page2pa>
c01059d4:	0b 45 14             	or     0x14(%ebp),%eax
c01059d7:	83 c8 01             	or     $0x1,%eax
c01059da:	89 c2                	mov    %eax,%edx
c01059dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059df:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01059e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01059e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01059eb:	89 04 24             	mov    %eax,(%esp)
c01059ee:	e8 09 00 00 00       	call   c01059fc <tlb_invalidate>
    return 0;
c01059f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01059f8:	89 ec                	mov    %ebp,%esp
c01059fa:	5d                   	pop    %ebp
c01059fb:	c3                   	ret    

c01059fc <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01059fc:	55                   	push   %ebp
c01059fd:	89 e5                	mov    %esp,%ebp
c01059ff:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105a02:	0f 20 d8             	mov    %cr3,%eax
c0105a05:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105a08:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0105a0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a11:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105a18:	77 23                	ja     c0105a3d <tlb_invalidate+0x41>
c0105a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a21:	c7 44 24 08 68 af 10 	movl   $0xc010af68,0x8(%esp)
c0105a28:	c0 
c0105a29:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0105a30:	00 
c0105a31:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105a38:	e8 e9 b2 ff ff       	call   c0100d26 <__panic>
c0105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a40:	05 00 00 00 40       	add    $0x40000000,%eax
c0105a45:	39 d0                	cmp    %edx,%eax
c0105a47:	75 0d                	jne    c0105a56 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0105a49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a52:	0f 01 38             	invlpg (%eax)
}
c0105a55:	90                   	nop
    }
}
c0105a56:	90                   	nop
c0105a57:	89 ec                	mov    %ebp,%esp
c0105a59:	5d                   	pop    %ebp
c0105a5a:	c3                   	ret    

c0105a5b <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105a5b:	55                   	push   %ebp
c0105a5c:	89 e5                	mov    %esp,%ebp
c0105a5e:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0105a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a68:	e8 ce f5 ff ff       	call   c010503b <alloc_pages>
c0105a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105a70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a74:	0f 84 a7 00 00 00    	je     c0105b21 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105a7a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a84:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a92:	89 04 24             	mov    %eax,(%esp)
c0105a95:	e8 a7 fe ff ff       	call   c0105941 <page_insert>
c0105a9a:	85 c0                	test   %eax,%eax
c0105a9c:	74 1a                	je     c0105ab8 <pgdir_alloc_page+0x5d>
            free_page(page);
c0105a9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105aa5:	00 
c0105aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa9:	89 04 24             	mov    %eax,(%esp)
c0105aac:	e8 f7 f5 ff ff       	call   c01050a8 <free_pages>
            return NULL;
c0105ab1:	b8 00 00 00 00       	mov    $0x0,%eax
c0105ab6:	eb 6c                	jmp    c0105b24 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0105ab8:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c0105abd:	85 c0                	test   %eax,%eax
c0105abf:	74 60                	je     c0105b21 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0105ac1:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c0105ac6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105acd:	00 
c0105ace:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ad1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ad8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105adc:	89 04 24             	mov    %eax,(%esp)
c0105adf:	e8 3a 0e 00 00       	call   c010691e <swap_map_swappable>
            page->pra_vaddr=la;
c0105ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105aea:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0105aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105af0:	89 04 24             	mov    %eax,(%esp)
c0105af3:	e8 33 f3 ff ff       	call   c0104e2b <page_ref>
c0105af8:	83 f8 01             	cmp    $0x1,%eax
c0105afb:	74 24                	je     c0105b21 <pgdir_alloc_page+0xc6>
c0105afd:	c7 44 24 0c ec af 10 	movl   $0xc010afec,0xc(%esp)
c0105b04:	c0 
c0105b05:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105b0c:	c0 
c0105b0d:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0105b14:	00 
c0105b15:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105b1c:	e8 05 b2 ff ff       	call   c0100d26 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0105b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b24:	89 ec                	mov    %ebp,%esp
c0105b26:	5d                   	pop    %ebp
c0105b27:	c3                   	ret    

c0105b28 <check_alloc_page>:

static void
check_alloc_page(void) {
c0105b28:	55                   	push   %ebp
c0105b29:	89 e5                	mov    %esp,%ebp
c0105b2b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105b2e:	a1 ac bf 12 c0       	mov    0xc012bfac,%eax
c0105b33:	8b 40 18             	mov    0x18(%eax),%eax
c0105b36:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0105b38:	c7 04 24 00 b0 10 c0 	movl   $0xc010b000,(%esp)
c0105b3f:	e8 34 a8 ff ff       	call   c0100378 <cprintf>
}
c0105b44:	90                   	nop
c0105b45:	89 ec                	mov    %ebp,%esp
c0105b47:	5d                   	pop    %ebp
c0105b48:	c3                   	ret    

c0105b49 <check_pgdir>:

static void
check_pgdir(void) {
c0105b49:	55                   	push   %ebp
c0105b4a:	89 e5                	mov    %esp,%ebp
c0105b4c:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105b4f:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0105b54:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0105b59:	76 24                	jbe    c0105b7f <check_pgdir+0x36>
c0105b5b:	c7 44 24 0c 1f b0 10 	movl   $0xc010b01f,0xc(%esp)
c0105b62:	c0 
c0105b63:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105b6a:	c0 
c0105b6b:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0105b72:	00 
c0105b73:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105b7a:	e8 a7 b1 ff ff       	call   c0100d26 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105b7f:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105b84:	85 c0                	test   %eax,%eax
c0105b86:	74 0e                	je     c0105b96 <check_pgdir+0x4d>
c0105b88:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105b8d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b92:	85 c0                	test   %eax,%eax
c0105b94:	74 24                	je     c0105bba <check_pgdir+0x71>
c0105b96:	c7 44 24 0c 3c b0 10 	movl   $0xc010b03c,0xc(%esp)
c0105b9d:	c0 
c0105b9e:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105ba5:	c0 
c0105ba6:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0105bad:	00 
c0105bae:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105bb5:	e8 6c b1 ff ff       	call   c0100d26 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0105bba:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105bbf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105bc6:	00 
c0105bc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105bce:	00 
c0105bcf:	89 04 24             	mov    %eax,(%esp)
c0105bd2:	e8 64 fc ff ff       	call   c010583b <get_page>
c0105bd7:	85 c0                	test   %eax,%eax
c0105bd9:	74 24                	je     c0105bff <check_pgdir+0xb6>
c0105bdb:	c7 44 24 0c 74 b0 10 	movl   $0xc010b074,0xc(%esp)
c0105be2:	c0 
c0105be3:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105bea:	c0 
c0105beb:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0105bf2:	00 
c0105bf3:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105bfa:	e8 27 b1 ff ff       	call   c0100d26 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105bff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105c06:	e8 30 f4 ff ff       	call   c010503b <alloc_pages>
c0105c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0105c0e:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105c13:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105c1a:	00 
c0105c1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c22:	00 
c0105c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c2a:	89 04 24             	mov    %eax,(%esp)
c0105c2d:	e8 0f fd ff ff       	call   c0105941 <page_insert>
c0105c32:	85 c0                	test   %eax,%eax
c0105c34:	74 24                	je     c0105c5a <check_pgdir+0x111>
c0105c36:	c7 44 24 0c 9c b0 10 	movl   $0xc010b09c,0xc(%esp)
c0105c3d:	c0 
c0105c3e:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105c45:	c0 
c0105c46:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0105c4d:	00 
c0105c4e:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105c55:	e8 cc b0 ff ff       	call   c0100d26 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0105c5a:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105c5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105c66:	00 
c0105c67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105c6e:	00 
c0105c6f:	89 04 24             	mov    %eax,(%esp)
c0105c72:	e8 7f fa ff ff       	call   c01056f6 <get_pte>
c0105c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105c7e:	75 24                	jne    c0105ca4 <check_pgdir+0x15b>
c0105c80:	c7 44 24 0c c8 b0 10 	movl   $0xc010b0c8,0xc(%esp)
c0105c87:	c0 
c0105c88:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105c8f:	c0 
c0105c90:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0105c97:	00 
c0105c98:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105c9f:	e8 82 b0 ff ff       	call   c0100d26 <__panic>
    assert(pte2page(*ptep) == p1);
c0105ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ca7:	8b 00                	mov    (%eax),%eax
c0105ca9:	89 04 24             	mov    %eax,(%esp)
c0105cac:	e8 20 f1 ff ff       	call   c0104dd1 <pte2page>
c0105cb1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0105cb4:	74 24                	je     c0105cda <check_pgdir+0x191>
c0105cb6:	c7 44 24 0c f5 b0 10 	movl   $0xc010b0f5,0xc(%esp)
c0105cbd:	c0 
c0105cbe:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105cc5:	c0 
c0105cc6:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0105ccd:	00 
c0105cce:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105cd5:	e8 4c b0 ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p1) == 1);
c0105cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cdd:	89 04 24             	mov    %eax,(%esp)
c0105ce0:	e8 46 f1 ff ff       	call   c0104e2b <page_ref>
c0105ce5:	83 f8 01             	cmp    $0x1,%eax
c0105ce8:	74 24                	je     c0105d0e <check_pgdir+0x1c5>
c0105cea:	c7 44 24 0c 0b b1 10 	movl   $0xc010b10b,0xc(%esp)
c0105cf1:	c0 
c0105cf2:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105cf9:	c0 
c0105cfa:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105d01:	00 
c0105d02:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105d09:	e8 18 b0 ff ff       	call   c0100d26 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0105d0e:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105d13:	8b 00                	mov    (%eax),%eax
c0105d15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105d1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d20:	c1 e8 0c             	shr    $0xc,%eax
c0105d23:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d26:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0105d2b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105d2e:	72 23                	jb     c0105d53 <check_pgdir+0x20a>
c0105d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d33:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d37:	c7 44 24 08 c4 ae 10 	movl   $0xc010aec4,0x8(%esp)
c0105d3e:	c0 
c0105d3f:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0105d46:	00 
c0105d47:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105d4e:	e8 d3 af ff ff       	call   c0100d26 <__panic>
c0105d53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d56:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105d5b:	83 c0 04             	add    $0x4,%eax
c0105d5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105d61:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105d66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d6d:	00 
c0105d6e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105d75:	00 
c0105d76:	89 04 24             	mov    %eax,(%esp)
c0105d79:	e8 78 f9 ff ff       	call   c01056f6 <get_pte>
c0105d7e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105d81:	74 24                	je     c0105da7 <check_pgdir+0x25e>
c0105d83:	c7 44 24 0c 20 b1 10 	movl   $0xc010b120,0xc(%esp)
c0105d8a:	c0 
c0105d8b:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105d92:	c0 
c0105d93:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0105d9a:	00 
c0105d9b:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105da2:	e8 7f af ff ff       	call   c0100d26 <__panic>

    p2 = alloc_page();
c0105da7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105dae:	e8 88 f2 ff ff       	call   c010503b <alloc_pages>
c0105db3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0105db6:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105dbb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0105dc2:	00 
c0105dc3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105dca:	00 
c0105dcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105dce:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105dd2:	89 04 24             	mov    %eax,(%esp)
c0105dd5:	e8 67 fb ff ff       	call   c0105941 <page_insert>
c0105dda:	85 c0                	test   %eax,%eax
c0105ddc:	74 24                	je     c0105e02 <check_pgdir+0x2b9>
c0105dde:	c7 44 24 0c 48 b1 10 	movl   $0xc010b148,0xc(%esp)
c0105de5:	c0 
c0105de6:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105ded:	c0 
c0105dee:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105df5:	00 
c0105df6:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105dfd:	e8 24 af ff ff       	call   c0100d26 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105e02:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105e07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e0e:	00 
c0105e0f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105e16:	00 
c0105e17:	89 04 24             	mov    %eax,(%esp)
c0105e1a:	e8 d7 f8 ff ff       	call   c01056f6 <get_pte>
c0105e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e26:	75 24                	jne    c0105e4c <check_pgdir+0x303>
c0105e28:	c7 44 24 0c 80 b1 10 	movl   $0xc010b180,0xc(%esp)
c0105e2f:	c0 
c0105e30:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105e37:	c0 
c0105e38:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0105e3f:	00 
c0105e40:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105e47:	e8 da ae ff ff       	call   c0100d26 <__panic>
    assert(*ptep & PTE_U);
c0105e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e4f:	8b 00                	mov    (%eax),%eax
c0105e51:	83 e0 04             	and    $0x4,%eax
c0105e54:	85 c0                	test   %eax,%eax
c0105e56:	75 24                	jne    c0105e7c <check_pgdir+0x333>
c0105e58:	c7 44 24 0c b0 b1 10 	movl   $0xc010b1b0,0xc(%esp)
c0105e5f:	c0 
c0105e60:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105e67:	c0 
c0105e68:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0105e6f:	00 
c0105e70:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105e77:	e8 aa ae ff ff       	call   c0100d26 <__panic>
    assert(*ptep & PTE_W);
c0105e7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e7f:	8b 00                	mov    (%eax),%eax
c0105e81:	83 e0 02             	and    $0x2,%eax
c0105e84:	85 c0                	test   %eax,%eax
c0105e86:	75 24                	jne    c0105eac <check_pgdir+0x363>
c0105e88:	c7 44 24 0c be b1 10 	movl   $0xc010b1be,0xc(%esp)
c0105e8f:	c0 
c0105e90:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105e97:	c0 
c0105e98:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0105e9f:	00 
c0105ea0:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105ea7:	e8 7a ae ff ff       	call   c0100d26 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0105eac:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105eb1:	8b 00                	mov    (%eax),%eax
c0105eb3:	83 e0 04             	and    $0x4,%eax
c0105eb6:	85 c0                	test   %eax,%eax
c0105eb8:	75 24                	jne    c0105ede <check_pgdir+0x395>
c0105eba:	c7 44 24 0c cc b1 10 	movl   $0xc010b1cc,0xc(%esp)
c0105ec1:	c0 
c0105ec2:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105ec9:	c0 
c0105eca:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105ed1:	00 
c0105ed2:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105ed9:	e8 48 ae ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p2) == 1);
c0105ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ee1:	89 04 24             	mov    %eax,(%esp)
c0105ee4:	e8 42 ef ff ff       	call   c0104e2b <page_ref>
c0105ee9:	83 f8 01             	cmp    $0x1,%eax
c0105eec:	74 24                	je     c0105f12 <check_pgdir+0x3c9>
c0105eee:	c7 44 24 0c e2 b1 10 	movl   $0xc010b1e2,0xc(%esp)
c0105ef5:	c0 
c0105ef6:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105efd:	c0 
c0105efe:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105f05:	00 
c0105f06:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105f0d:	e8 14 ae ff ff       	call   c0100d26 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105f12:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105f17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105f1e:	00 
c0105f1f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105f26:	00 
c0105f27:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f2a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f2e:	89 04 24             	mov    %eax,(%esp)
c0105f31:	e8 0b fa ff ff       	call   c0105941 <page_insert>
c0105f36:	85 c0                	test   %eax,%eax
c0105f38:	74 24                	je     c0105f5e <check_pgdir+0x415>
c0105f3a:	c7 44 24 0c f4 b1 10 	movl   $0xc010b1f4,0xc(%esp)
c0105f41:	c0 
c0105f42:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105f49:	c0 
c0105f4a:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0105f51:	00 
c0105f52:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105f59:	e8 c8 ad ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p1) == 2);
c0105f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f61:	89 04 24             	mov    %eax,(%esp)
c0105f64:	e8 c2 ee ff ff       	call   c0104e2b <page_ref>
c0105f69:	83 f8 02             	cmp    $0x2,%eax
c0105f6c:	74 24                	je     c0105f92 <check_pgdir+0x449>
c0105f6e:	c7 44 24 0c 20 b2 10 	movl   $0xc010b220,0xc(%esp)
c0105f75:	c0 
c0105f76:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105f7d:	c0 
c0105f7e:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0105f85:	00 
c0105f86:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105f8d:	e8 94 ad ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p2) == 0);
c0105f92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f95:	89 04 24             	mov    %eax,(%esp)
c0105f98:	e8 8e ee ff ff       	call   c0104e2b <page_ref>
c0105f9d:	85 c0                	test   %eax,%eax
c0105f9f:	74 24                	je     c0105fc5 <check_pgdir+0x47c>
c0105fa1:	c7 44 24 0c 32 b2 10 	movl   $0xc010b232,0xc(%esp)
c0105fa8:	c0 
c0105fa9:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105fb0:	c0 
c0105fb1:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0105fb8:	00 
c0105fb9:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0105fc0:	e8 61 ad ff ff       	call   c0100d26 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105fc5:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0105fca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105fd1:	00 
c0105fd2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105fd9:	00 
c0105fda:	89 04 24             	mov    %eax,(%esp)
c0105fdd:	e8 14 f7 ff ff       	call   c01056f6 <get_pte>
c0105fe2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fe5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105fe9:	75 24                	jne    c010600f <check_pgdir+0x4c6>
c0105feb:	c7 44 24 0c 80 b1 10 	movl   $0xc010b180,0xc(%esp)
c0105ff2:	c0 
c0105ff3:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0105ffa:	c0 
c0105ffb:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0106002:	00 
c0106003:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c010600a:	e8 17 ad ff ff       	call   c0100d26 <__panic>
    assert(pte2page(*ptep) == p1);
c010600f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106012:	8b 00                	mov    (%eax),%eax
c0106014:	89 04 24             	mov    %eax,(%esp)
c0106017:	e8 b5 ed ff ff       	call   c0104dd1 <pte2page>
c010601c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010601f:	74 24                	je     c0106045 <check_pgdir+0x4fc>
c0106021:	c7 44 24 0c f5 b0 10 	movl   $0xc010b0f5,0xc(%esp)
c0106028:	c0 
c0106029:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106030:	c0 
c0106031:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0106038:	00 
c0106039:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106040:	e8 e1 ac ff ff       	call   c0100d26 <__panic>
    assert((*ptep & PTE_U) == 0);
c0106045:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106048:	8b 00                	mov    (%eax),%eax
c010604a:	83 e0 04             	and    $0x4,%eax
c010604d:	85 c0                	test   %eax,%eax
c010604f:	74 24                	je     c0106075 <check_pgdir+0x52c>
c0106051:	c7 44 24 0c 44 b2 10 	movl   $0xc010b244,0xc(%esp)
c0106058:	c0 
c0106059:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106060:	c0 
c0106061:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0106068:	00 
c0106069:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106070:	e8 b1 ac ff ff       	call   c0100d26 <__panic>

    page_remove(boot_pgdir, 0x0);
c0106075:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010607a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106081:	00 
c0106082:	89 04 24             	mov    %eax,(%esp)
c0106085:	e8 70 f8 ff ff       	call   c01058fa <page_remove>
    assert(page_ref(p1) == 1);
c010608a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010608d:	89 04 24             	mov    %eax,(%esp)
c0106090:	e8 96 ed ff ff       	call   c0104e2b <page_ref>
c0106095:	83 f8 01             	cmp    $0x1,%eax
c0106098:	74 24                	je     c01060be <check_pgdir+0x575>
c010609a:	c7 44 24 0c 0b b1 10 	movl   $0xc010b10b,0xc(%esp)
c01060a1:	c0 
c01060a2:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01060a9:	c0 
c01060aa:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01060b1:	00 
c01060b2:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01060b9:	e8 68 ac ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p2) == 0);
c01060be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060c1:	89 04 24             	mov    %eax,(%esp)
c01060c4:	e8 62 ed ff ff       	call   c0104e2b <page_ref>
c01060c9:	85 c0                	test   %eax,%eax
c01060cb:	74 24                	je     c01060f1 <check_pgdir+0x5a8>
c01060cd:	c7 44 24 0c 32 b2 10 	movl   $0xc010b232,0xc(%esp)
c01060d4:	c0 
c01060d5:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01060dc:	c0 
c01060dd:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c01060e4:	00 
c01060e5:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01060ec:	e8 35 ac ff ff       	call   c0100d26 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01060f1:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01060f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01060fd:	00 
c01060fe:	89 04 24             	mov    %eax,(%esp)
c0106101:	e8 f4 f7 ff ff       	call   c01058fa <page_remove>
    assert(page_ref(p1) == 0);
c0106106:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106109:	89 04 24             	mov    %eax,(%esp)
c010610c:	e8 1a ed ff ff       	call   c0104e2b <page_ref>
c0106111:	85 c0                	test   %eax,%eax
c0106113:	74 24                	je     c0106139 <check_pgdir+0x5f0>
c0106115:	c7 44 24 0c 59 b2 10 	movl   $0xc010b259,0xc(%esp)
c010611c:	c0 
c010611d:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106124:	c0 
c0106125:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c010612c:	00 
c010612d:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106134:	e8 ed ab ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p2) == 0);
c0106139:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010613c:	89 04 24             	mov    %eax,(%esp)
c010613f:	e8 e7 ec ff ff       	call   c0104e2b <page_ref>
c0106144:	85 c0                	test   %eax,%eax
c0106146:	74 24                	je     c010616c <check_pgdir+0x623>
c0106148:	c7 44 24 0c 32 b2 10 	movl   $0xc010b232,0xc(%esp)
c010614f:	c0 
c0106150:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106157:	c0 
c0106158:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c010615f:	00 
c0106160:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106167:	e8 ba ab ff ff       	call   c0100d26 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010616c:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106171:	8b 00                	mov    (%eax),%eax
c0106173:	89 04 24             	mov    %eax,(%esp)
c0106176:	e8 96 ec ff ff       	call   c0104e11 <pde2page>
c010617b:	89 04 24             	mov    %eax,(%esp)
c010617e:	e8 a8 ec ff ff       	call   c0104e2b <page_ref>
c0106183:	83 f8 01             	cmp    $0x1,%eax
c0106186:	74 24                	je     c01061ac <check_pgdir+0x663>
c0106188:	c7 44 24 0c 6c b2 10 	movl   $0xc010b26c,0xc(%esp)
c010618f:	c0 
c0106190:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106197:	c0 
c0106198:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c010619f:	00 
c01061a0:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01061a7:	e8 7a ab ff ff       	call   c0100d26 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01061ac:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01061b1:	8b 00                	mov    (%eax),%eax
c01061b3:	89 04 24             	mov    %eax,(%esp)
c01061b6:	e8 56 ec ff ff       	call   c0104e11 <pde2page>
c01061bb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01061c2:	00 
c01061c3:	89 04 24             	mov    %eax,(%esp)
c01061c6:	e8 dd ee ff ff       	call   c01050a8 <free_pages>
    boot_pgdir[0] = 0;
c01061cb:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01061d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01061d6:	c7 04 24 93 b2 10 c0 	movl   $0xc010b293,(%esp)
c01061dd:	e8 96 a1 ff ff       	call   c0100378 <cprintf>
}
c01061e2:	90                   	nop
c01061e3:	89 ec                	mov    %ebp,%esp
c01061e5:	5d                   	pop    %ebp
c01061e6:	c3                   	ret    

c01061e7 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01061e7:	55                   	push   %ebp
c01061e8:	89 e5                	mov    %esp,%ebp
c01061ea:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01061ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01061f4:	e9 ca 00 00 00       	jmp    c01062c3 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01061f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01061ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106202:	c1 e8 0c             	shr    $0xc,%eax
c0106205:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106208:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c010620d:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0106210:	72 23                	jb     c0106235 <check_boot_pgdir+0x4e>
c0106212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106215:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106219:	c7 44 24 08 c4 ae 10 	movl   $0xc010aec4,0x8(%esp)
c0106220:	c0 
c0106221:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0106228:	00 
c0106229:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106230:	e8 f1 aa ff ff       	call   c0100d26 <__panic>
c0106235:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106238:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010623d:	89 c2                	mov    %eax,%edx
c010623f:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106244:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010624b:	00 
c010624c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106250:	89 04 24             	mov    %eax,(%esp)
c0106253:	e8 9e f4 ff ff       	call   c01056f6 <get_pte>
c0106258:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010625b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010625f:	75 24                	jne    c0106285 <check_boot_pgdir+0x9e>
c0106261:	c7 44 24 0c b0 b2 10 	movl   $0xc010b2b0,0xc(%esp)
c0106268:	c0 
c0106269:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106270:	c0 
c0106271:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0106278:	00 
c0106279:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106280:	e8 a1 aa ff ff       	call   c0100d26 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0106285:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106288:	8b 00                	mov    (%eax),%eax
c010628a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010628f:	89 c2                	mov    %eax,%edx
c0106291:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106294:	39 c2                	cmp    %eax,%edx
c0106296:	74 24                	je     c01062bc <check_boot_pgdir+0xd5>
c0106298:	c7 44 24 0c ed b2 10 	movl   $0xc010b2ed,0xc(%esp)
c010629f:	c0 
c01062a0:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01062a7:	c0 
c01062a8:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c01062af:	00 
c01062b0:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01062b7:	e8 6a aa ff ff       	call   c0100d26 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01062bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01062c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01062c6:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01062cb:	39 c2                	cmp    %eax,%edx
c01062cd:	0f 82 26 ff ff ff    	jb     c01061f9 <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01062d3:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01062d8:	05 ac 0f 00 00       	add    $0xfac,%eax
c01062dd:	8b 00                	mov    (%eax),%eax
c01062df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01062e4:	89 c2                	mov    %eax,%edx
c01062e6:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01062eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062ee:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01062f5:	77 23                	ja     c010631a <check_boot_pgdir+0x133>
c01062f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01062fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01062fe:	c7 44 24 08 68 af 10 	movl   $0xc010af68,0x8(%esp)
c0106305:	c0 
c0106306:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c010630d:	00 
c010630e:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106315:	e8 0c aa ff ff       	call   c0100d26 <__panic>
c010631a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010631d:	05 00 00 00 40       	add    $0x40000000,%eax
c0106322:	39 d0                	cmp    %edx,%eax
c0106324:	74 24                	je     c010634a <check_boot_pgdir+0x163>
c0106326:	c7 44 24 0c 04 b3 10 	movl   $0xc010b304,0xc(%esp)
c010632d:	c0 
c010632e:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106335:	c0 
c0106336:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c010633d:	00 
c010633e:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106345:	e8 dc a9 ff ff       	call   c0100d26 <__panic>

    assert(boot_pgdir[0] == 0);
c010634a:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010634f:	8b 00                	mov    (%eax),%eax
c0106351:	85 c0                	test   %eax,%eax
c0106353:	74 24                	je     c0106379 <check_boot_pgdir+0x192>
c0106355:	c7 44 24 0c 38 b3 10 	movl   $0xc010b338,0xc(%esp)
c010635c:	c0 
c010635d:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106364:	c0 
c0106365:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c010636c:	00 
c010636d:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106374:	e8 ad a9 ff ff       	call   c0100d26 <__panic>

    struct Page *p;
    p = alloc_page();
c0106379:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106380:	e8 b6 ec ff ff       	call   c010503b <alloc_pages>
c0106385:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106388:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010638d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106394:	00 
c0106395:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010639c:	00 
c010639d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01063a0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063a4:	89 04 24             	mov    %eax,(%esp)
c01063a7:	e8 95 f5 ff ff       	call   c0105941 <page_insert>
c01063ac:	85 c0                	test   %eax,%eax
c01063ae:	74 24                	je     c01063d4 <check_boot_pgdir+0x1ed>
c01063b0:	c7 44 24 0c 4c b3 10 	movl   $0xc010b34c,0xc(%esp)
c01063b7:	c0 
c01063b8:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01063bf:	c0 
c01063c0:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01063c7:	00 
c01063c8:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01063cf:	e8 52 a9 ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p) == 1);
c01063d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063d7:	89 04 24             	mov    %eax,(%esp)
c01063da:	e8 4c ea ff ff       	call   c0104e2b <page_ref>
c01063df:	83 f8 01             	cmp    $0x1,%eax
c01063e2:	74 24                	je     c0106408 <check_boot_pgdir+0x221>
c01063e4:	c7 44 24 0c 7a b3 10 	movl   $0xc010b37a,0xc(%esp)
c01063eb:	c0 
c01063ec:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01063f3:	c0 
c01063f4:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c01063fb:	00 
c01063fc:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106403:	e8 1e a9 ff ff       	call   c0100d26 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0106408:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010640d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106414:	00 
c0106415:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010641c:	00 
c010641d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106420:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106424:	89 04 24             	mov    %eax,(%esp)
c0106427:	e8 15 f5 ff ff       	call   c0105941 <page_insert>
c010642c:	85 c0                	test   %eax,%eax
c010642e:	74 24                	je     c0106454 <check_boot_pgdir+0x26d>
c0106430:	c7 44 24 0c 8c b3 10 	movl   $0xc010b38c,0xc(%esp)
c0106437:	c0 
c0106438:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c010643f:	c0 
c0106440:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c0106447:	00 
c0106448:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c010644f:	e8 d2 a8 ff ff       	call   c0100d26 <__panic>
    assert(page_ref(p) == 2);
c0106454:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106457:	89 04 24             	mov    %eax,(%esp)
c010645a:	e8 cc e9 ff ff       	call   c0104e2b <page_ref>
c010645f:	83 f8 02             	cmp    $0x2,%eax
c0106462:	74 24                	je     c0106488 <check_boot_pgdir+0x2a1>
c0106464:	c7 44 24 0c c3 b3 10 	movl   $0xc010b3c3,0xc(%esp)
c010646b:	c0 
c010646c:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106473:	c0 
c0106474:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c010647b:	00 
c010647c:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106483:	e8 9e a8 ff ff       	call   c0100d26 <__panic>

    const char *str = "ucore: Hello world!!";
c0106488:	c7 45 e8 d4 b3 10 c0 	movl   $0xc010b3d4,-0x18(%ebp)
    strcpy((void *)0x100, str);
c010648f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106492:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106496:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010649d:	e8 c7 37 00 00       	call   c0109c69 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01064a2:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01064a9:	00 
c01064aa:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01064b1:	e8 2b 38 00 00       	call   c0109ce1 <strcmp>
c01064b6:	85 c0                	test   %eax,%eax
c01064b8:	74 24                	je     c01064de <check_boot_pgdir+0x2f7>
c01064ba:	c7 44 24 0c ec b3 10 	movl   $0xc010b3ec,0xc(%esp)
c01064c1:	c0 
c01064c2:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c01064c9:	c0 
c01064ca:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c01064d1:	00 
c01064d2:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c01064d9:	e8 48 a8 ff ff       	call   c0100d26 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01064de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01064e1:	89 04 24             	mov    %eax,(%esp)
c01064e4:	e8 92 e8 ff ff       	call   c0104d7b <page2kva>
c01064e9:	05 00 01 00 00       	add    $0x100,%eax
c01064ee:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01064f1:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01064f8:	e8 12 37 00 00       	call   c0109c0f <strlen>
c01064fd:	85 c0                	test   %eax,%eax
c01064ff:	74 24                	je     c0106525 <check_boot_pgdir+0x33e>
c0106501:	c7 44 24 0c 24 b4 10 	movl   $0xc010b424,0xc(%esp)
c0106508:	c0 
c0106509:	c7 44 24 08 b1 af 10 	movl   $0xc010afb1,0x8(%esp)
c0106510:	c0 
c0106511:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0106518:	00 
c0106519:	c7 04 24 8c af 10 c0 	movl   $0xc010af8c,(%esp)
c0106520:	e8 01 a8 ff ff       	call   c0100d26 <__panic>

    free_page(p);
c0106525:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010652c:	00 
c010652d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106530:	89 04 24             	mov    %eax,(%esp)
c0106533:	e8 70 eb ff ff       	call   c01050a8 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106538:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010653d:	8b 00                	mov    (%eax),%eax
c010653f:	89 04 24             	mov    %eax,(%esp)
c0106542:	e8 ca e8 ff ff       	call   c0104e11 <pde2page>
c0106547:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010654e:	00 
c010654f:	89 04 24             	mov    %eax,(%esp)
c0106552:	e8 51 eb ff ff       	call   c01050a8 <free_pages>
    boot_pgdir[0] = 0;
c0106557:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010655c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106562:	c7 04 24 48 b4 10 c0 	movl   $0xc010b448,(%esp)
c0106569:	e8 0a 9e ff ff       	call   c0100378 <cprintf>
}
c010656e:	90                   	nop
c010656f:	89 ec                	mov    %ebp,%esp
c0106571:	5d                   	pop    %ebp
c0106572:	c3                   	ret    

c0106573 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106573:	55                   	push   %ebp
c0106574:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106576:	8b 45 08             	mov    0x8(%ebp),%eax
c0106579:	83 e0 04             	and    $0x4,%eax
c010657c:	85 c0                	test   %eax,%eax
c010657e:	74 04                	je     c0106584 <perm2str+0x11>
c0106580:	b0 75                	mov    $0x75,%al
c0106582:	eb 02                	jmp    c0106586 <perm2str+0x13>
c0106584:	b0 2d                	mov    $0x2d,%al
c0106586:	a2 28 c0 12 c0       	mov    %al,0xc012c028
    str[1] = 'r';
c010658b:	c6 05 29 c0 12 c0 72 	movb   $0x72,0xc012c029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106592:	8b 45 08             	mov    0x8(%ebp),%eax
c0106595:	83 e0 02             	and    $0x2,%eax
c0106598:	85 c0                	test   %eax,%eax
c010659a:	74 04                	je     c01065a0 <perm2str+0x2d>
c010659c:	b0 77                	mov    $0x77,%al
c010659e:	eb 02                	jmp    c01065a2 <perm2str+0x2f>
c01065a0:	b0 2d                	mov    $0x2d,%al
c01065a2:	a2 2a c0 12 c0       	mov    %al,0xc012c02a
    str[3] = '\0';
c01065a7:	c6 05 2b c0 12 c0 00 	movb   $0x0,0xc012c02b
    return str;
c01065ae:	b8 28 c0 12 c0       	mov    $0xc012c028,%eax
}
c01065b3:	5d                   	pop    %ebp
c01065b4:	c3                   	ret    

c01065b5 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01065b5:	55                   	push   %ebp
c01065b6:	89 e5                	mov    %esp,%ebp
c01065b8:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01065bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01065be:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01065c1:	72 0d                	jb     c01065d0 <get_pgtable_items+0x1b>
        return 0;
c01065c3:	b8 00 00 00 00       	mov    $0x0,%eax
c01065c8:	e9 98 00 00 00       	jmp    c0106665 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01065cd:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01065d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01065d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01065d6:	73 18                	jae    c01065f0 <get_pgtable_items+0x3b>
c01065d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01065db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01065e2:	8b 45 14             	mov    0x14(%ebp),%eax
c01065e5:	01 d0                	add    %edx,%eax
c01065e7:	8b 00                	mov    (%eax),%eax
c01065e9:	83 e0 01             	and    $0x1,%eax
c01065ec:	85 c0                	test   %eax,%eax
c01065ee:	74 dd                	je     c01065cd <get_pgtable_items+0x18>
    }
    if (start < right) {
c01065f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01065f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01065f6:	73 68                	jae    c0106660 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01065f8:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01065fc:	74 08                	je     c0106606 <get_pgtable_items+0x51>
            *left_store = start;
c01065fe:	8b 45 18             	mov    0x18(%ebp),%eax
c0106601:	8b 55 10             	mov    0x10(%ebp),%edx
c0106604:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106606:	8b 45 10             	mov    0x10(%ebp),%eax
c0106609:	8d 50 01             	lea    0x1(%eax),%edx
c010660c:	89 55 10             	mov    %edx,0x10(%ebp)
c010660f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106616:	8b 45 14             	mov    0x14(%ebp),%eax
c0106619:	01 d0                	add    %edx,%eax
c010661b:	8b 00                	mov    (%eax),%eax
c010661d:	83 e0 07             	and    $0x7,%eax
c0106620:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106623:	eb 03                	jmp    c0106628 <get_pgtable_items+0x73>
            start ++;
c0106625:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106628:	8b 45 10             	mov    0x10(%ebp),%eax
c010662b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010662e:	73 1d                	jae    c010664d <get_pgtable_items+0x98>
c0106630:	8b 45 10             	mov    0x10(%ebp),%eax
c0106633:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010663a:	8b 45 14             	mov    0x14(%ebp),%eax
c010663d:	01 d0                	add    %edx,%eax
c010663f:	8b 00                	mov    (%eax),%eax
c0106641:	83 e0 07             	and    $0x7,%eax
c0106644:	89 c2                	mov    %eax,%edx
c0106646:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106649:	39 c2                	cmp    %eax,%edx
c010664b:	74 d8                	je     c0106625 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c010664d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106651:	74 08                	je     c010665b <get_pgtable_items+0xa6>
            *right_store = start;
c0106653:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106656:	8b 55 10             	mov    0x10(%ebp),%edx
c0106659:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010665b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010665e:	eb 05                	jmp    c0106665 <get_pgtable_items+0xb0>
    }
    return 0;
c0106660:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106665:	89 ec                	mov    %ebp,%esp
c0106667:	5d                   	pop    %ebp
c0106668:	c3                   	ret    

c0106669 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106669:	55                   	push   %ebp
c010666a:	89 e5                	mov    %esp,%ebp
c010666c:	57                   	push   %edi
c010666d:	56                   	push   %esi
c010666e:	53                   	push   %ebx
c010666f:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106672:	c7 04 24 68 b4 10 c0 	movl   $0xc010b468,(%esp)
c0106679:	e8 fa 9c ff ff       	call   c0100378 <cprintf>
    size_t left, right = 0, perm;
c010667e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106685:	e9 f2 00 00 00       	jmp    c010677c <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010668a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010668d:	89 04 24             	mov    %eax,(%esp)
c0106690:	e8 de fe ff ff       	call   c0106573 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106695:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106698:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010669b:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010669d:	89 d6                	mov    %edx,%esi
c010669f:	c1 e6 16             	shl    $0x16,%esi
c01066a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066a5:	89 d3                	mov    %edx,%ebx
c01066a7:	c1 e3 16             	shl    $0x16,%ebx
c01066aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01066ad:	89 d1                	mov    %edx,%ecx
c01066af:	c1 e1 16             	shl    $0x16,%ecx
c01066b2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066b5:	8b 7d e0             	mov    -0x20(%ebp),%edi
c01066b8:	29 fa                	sub    %edi,%edx
c01066ba:	89 44 24 14          	mov    %eax,0x14(%esp)
c01066be:	89 74 24 10          	mov    %esi,0x10(%esp)
c01066c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01066c6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01066ca:	89 54 24 04          	mov    %edx,0x4(%esp)
c01066ce:	c7 04 24 99 b4 10 c0 	movl   $0xc010b499,(%esp)
c01066d5:	e8 9e 9c ff ff       	call   c0100378 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01066da:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01066dd:	c1 e0 0a             	shl    $0xa,%eax
c01066e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01066e3:	eb 50                	jmp    c0106735 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01066e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066e8:	89 04 24             	mov    %eax,(%esp)
c01066eb:	e8 83 fe ff ff       	call   c0106573 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01066f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01066f3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01066f6:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01066f8:	89 d6                	mov    %edx,%esi
c01066fa:	c1 e6 0c             	shl    $0xc,%esi
c01066fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106700:	89 d3                	mov    %edx,%ebx
c0106702:	c1 e3 0c             	shl    $0xc,%ebx
c0106705:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106708:	89 d1                	mov    %edx,%ecx
c010670a:	c1 e1 0c             	shl    $0xc,%ecx
c010670d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106710:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0106713:	29 fa                	sub    %edi,%edx
c0106715:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106719:	89 74 24 10          	mov    %esi,0x10(%esp)
c010671d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106721:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106725:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106729:	c7 04 24 b8 b4 10 c0 	movl   $0xc010b4b8,(%esp)
c0106730:	e8 43 9c ff ff       	call   c0100378 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106735:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010673a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010673d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106740:	89 d3                	mov    %edx,%ebx
c0106742:	c1 e3 0a             	shl    $0xa,%ebx
c0106745:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106748:	89 d1                	mov    %edx,%ecx
c010674a:	c1 e1 0a             	shl    $0xa,%ecx
c010674d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0106750:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106754:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0106757:	89 54 24 10          	mov    %edx,0x10(%esp)
c010675b:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010675f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106763:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0106767:	89 0c 24             	mov    %ecx,(%esp)
c010676a:	e8 46 fe ff ff       	call   c01065b5 <get_pgtable_items>
c010676f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106772:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106776:	0f 85 69 ff ff ff    	jne    c01066e5 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010677c:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0106781:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106784:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0106787:	89 54 24 14          	mov    %edx,0x14(%esp)
c010678b:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010678e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106792:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0106796:	89 44 24 08          	mov    %eax,0x8(%esp)
c010679a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01067a1:	00 
c01067a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01067a9:	e8 07 fe ff ff       	call   c01065b5 <get_pgtable_items>
c01067ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01067b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01067b5:	0f 85 cf fe ff ff    	jne    c010668a <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01067bb:	c7 04 24 dc b4 10 c0 	movl   $0xc010b4dc,(%esp)
c01067c2:	e8 b1 9b ff ff       	call   c0100378 <cprintf>
}
c01067c7:	90                   	nop
c01067c8:	83 c4 4c             	add    $0x4c,%esp
c01067cb:	5b                   	pop    %ebx
c01067cc:	5e                   	pop    %esi
c01067cd:	5f                   	pop    %edi
c01067ce:	5d                   	pop    %ebp
c01067cf:	c3                   	ret    

c01067d0 <pa2page>:
pa2page(uintptr_t pa) {
c01067d0:	55                   	push   %ebp
c01067d1:	89 e5                	mov    %esp,%ebp
c01067d3:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01067d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d9:	c1 e8 0c             	shr    $0xc,%eax
c01067dc:	89 c2                	mov    %eax,%edx
c01067de:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01067e3:	39 c2                	cmp    %eax,%edx
c01067e5:	72 1c                	jb     c0106803 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01067e7:	c7 44 24 08 10 b5 10 	movl   $0xc010b510,0x8(%esp)
c01067ee:	c0 
c01067ef:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01067f6:	00 
c01067f7:	c7 04 24 2f b5 10 c0 	movl   $0xc010b52f,(%esp)
c01067fe:	e8 23 a5 ff ff       	call   c0100d26 <__panic>
    return &pages[PPN(pa)];
c0106803:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0106809:	8b 45 08             	mov    0x8(%ebp),%eax
c010680c:	c1 e8 0c             	shr    $0xc,%eax
c010680f:	c1 e0 05             	shl    $0x5,%eax
c0106812:	01 d0                	add    %edx,%eax
}
c0106814:	89 ec                	mov    %ebp,%esp
c0106816:	5d                   	pop    %ebp
c0106817:	c3                   	ret    

c0106818 <pte2page>:
pte2page(pte_t pte) {
c0106818:	55                   	push   %ebp
c0106819:	89 e5                	mov    %esp,%ebp
c010681b:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010681e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106821:	83 e0 01             	and    $0x1,%eax
c0106824:	85 c0                	test   %eax,%eax
c0106826:	75 1c                	jne    c0106844 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106828:	c7 44 24 08 40 b5 10 	movl   $0xc010b540,0x8(%esp)
c010682f:	c0 
c0106830:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0106837:	00 
c0106838:	c7 04 24 2f b5 10 c0 	movl   $0xc010b52f,(%esp)
c010683f:	e8 e2 a4 ff ff       	call   c0100d26 <__panic>
    return pa2page(PTE_ADDR(pte));
c0106844:	8b 45 08             	mov    0x8(%ebp),%eax
c0106847:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010684c:	89 04 24             	mov    %eax,(%esp)
c010684f:	e8 7c ff ff ff       	call   c01067d0 <pa2page>
}
c0106854:	89 ec                	mov    %ebp,%esp
c0106856:	5d                   	pop    %ebp
c0106857:	c3                   	ret    

c0106858 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106858:	55                   	push   %ebp
c0106859:	89 e5                	mov    %esp,%ebp
c010685b:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010685e:	e8 a7 1e 00 00       	call   c010870a <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106863:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c0106868:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c010686d:	76 0c                	jbe    c010687b <swap_init+0x23>
c010686f:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c0106874:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106879:	76 25                	jbe    c01068a0 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c010687b:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c0106880:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106884:	c7 44 24 08 61 b5 10 	movl   $0xc010b561,0x8(%esp)
c010688b:	c0 
c010688c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0106893:	00 
c0106894:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c010689b:	e8 86 a4 ff ff       	call   c0100d26 <__panic>
     }
     

     sm = &swap_manager_fifo;
c01068a0:	c7 05 00 c1 12 c0 60 	movl   $0xc0128a60,0xc012c100
c01068a7:	8a 12 c0 
     int r = sm->init();
c01068aa:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c01068af:	8b 40 04             	mov    0x4(%eax),%eax
c01068b2:	ff d0                	call   *%eax
c01068b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01068b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01068bb:	75 26                	jne    c01068e3 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c01068bd:	c7 05 44 c0 12 c0 01 	movl   $0x1,0xc012c044
c01068c4:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c01068c7:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c01068cc:	8b 00                	mov    (%eax),%eax
c01068ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068d2:	c7 04 24 8b b5 10 c0 	movl   $0xc010b58b,(%esp)
c01068d9:	e8 9a 9a ff ff       	call   c0100378 <cprintf>
          check_swap();
c01068de:	e8 b0 04 00 00       	call   c0106d93 <check_swap>
     }

     return r;
c01068e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01068e6:	89 ec                	mov    %ebp,%esp
c01068e8:	5d                   	pop    %ebp
c01068e9:	c3                   	ret    

c01068ea <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c01068ea:	55                   	push   %ebp
c01068eb:	89 e5                	mov    %esp,%ebp
c01068ed:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c01068f0:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c01068f5:	8b 40 08             	mov    0x8(%eax),%eax
c01068f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01068fb:	89 14 24             	mov    %edx,(%esp)
c01068fe:	ff d0                	call   *%eax
}
c0106900:	89 ec                	mov    %ebp,%esp
c0106902:	5d                   	pop    %ebp
c0106903:	c3                   	ret    

c0106904 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106904:	55                   	push   %ebp
c0106905:	89 e5                	mov    %esp,%ebp
c0106907:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c010690a:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c010690f:	8b 40 0c             	mov    0xc(%eax),%eax
c0106912:	8b 55 08             	mov    0x8(%ebp),%edx
c0106915:	89 14 24             	mov    %edx,(%esp)
c0106918:	ff d0                	call   *%eax
}
c010691a:	89 ec                	mov    %ebp,%esp
c010691c:	5d                   	pop    %ebp
c010691d:	c3                   	ret    

c010691e <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010691e:	55                   	push   %ebp
c010691f:	89 e5                	mov    %esp,%ebp
c0106921:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106924:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106929:	8b 40 10             	mov    0x10(%eax),%eax
c010692c:	8b 55 14             	mov    0x14(%ebp),%edx
c010692f:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106933:	8b 55 10             	mov    0x10(%ebp),%edx
c0106936:	89 54 24 08          	mov    %edx,0x8(%esp)
c010693a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010693d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106941:	8b 55 08             	mov    0x8(%ebp),%edx
c0106944:	89 14 24             	mov    %edx,(%esp)
c0106947:	ff d0                	call   *%eax
}
c0106949:	89 ec                	mov    %ebp,%esp
c010694b:	5d                   	pop    %ebp
c010694c:	c3                   	ret    

c010694d <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010694d:	55                   	push   %ebp
c010694e:	89 e5                	mov    %esp,%ebp
c0106950:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106953:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106958:	8b 40 14             	mov    0x14(%eax),%eax
c010695b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010695e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106962:	8b 55 08             	mov    0x8(%ebp),%edx
c0106965:	89 14 24             	mov    %edx,(%esp)
c0106968:	ff d0                	call   *%eax
}
c010696a:	89 ec                	mov    %ebp,%esp
c010696c:	5d                   	pop    %ebp
c010696d:	c3                   	ret    

c010696e <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c010696e:	55                   	push   %ebp
c010696f:	89 e5                	mov    %esp,%ebp
c0106971:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106974:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010697b:	e9 53 01 00 00       	jmp    c0106ad3 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106980:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106985:	8b 40 18             	mov    0x18(%eax),%eax
c0106988:	8b 55 10             	mov    0x10(%ebp),%edx
c010698b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010698f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106992:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106996:	8b 55 08             	mov    0x8(%ebp),%edx
c0106999:	89 14 24             	mov    %edx,(%esp)
c010699c:	ff d0                	call   *%eax
c010699e:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01069a1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01069a5:	74 18                	je     c01069bf <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01069a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01069ae:	c7 04 24 a0 b5 10 c0 	movl   $0xc010b5a0,(%esp)
c01069b5:	e8 be 99 ff ff       	call   c0100378 <cprintf>
c01069ba:	e9 20 01 00 00       	jmp    c0106adf <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01069bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069c2:	8b 40 1c             	mov    0x1c(%eax),%eax
c01069c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01069c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069cb:	8b 40 0c             	mov    0xc(%eax),%eax
c01069ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01069d5:	00 
c01069d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01069d9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069dd:	89 04 24             	mov    %eax,(%esp)
c01069e0:	e8 11 ed ff ff       	call   c01056f6 <get_pte>
c01069e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c01069e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069eb:	8b 00                	mov    (%eax),%eax
c01069ed:	83 e0 01             	and    $0x1,%eax
c01069f0:	85 c0                	test   %eax,%eax
c01069f2:	75 24                	jne    c0106a18 <swap_out+0xaa>
c01069f4:	c7 44 24 0c cd b5 10 	movl   $0xc010b5cd,0xc(%esp)
c01069fb:	c0 
c01069fc:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106a03:	c0 
c0106a04:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0106a0b:	00 
c0106a0c:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106a13:	e8 0e a3 ff ff       	call   c0100d26 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a1e:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106a21:	c1 ea 0c             	shr    $0xc,%edx
c0106a24:	42                   	inc    %edx
c0106a25:	c1 e2 08             	shl    $0x8,%edx
c0106a28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a2c:	89 14 24             	mov    %edx,(%esp)
c0106a2f:	e8 95 1d 00 00       	call   c01087c9 <swapfs_write>
c0106a34:	85 c0                	test   %eax,%eax
c0106a36:	74 34                	je     c0106a6c <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0106a38:	c7 04 24 f7 b5 10 c0 	movl   $0xc010b5f7,(%esp)
c0106a3f:	e8 34 99 ff ff       	call   c0100378 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106a44:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106a49:	8b 40 10             	mov    0x10(%eax),%eax
c0106a4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106a4f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106a56:	00 
c0106a57:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106a5b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a62:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a65:	89 14 24             	mov    %edx,(%esp)
c0106a68:	ff d0                	call   *%eax
c0106a6a:	eb 64                	jmp    c0106ad0 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0106a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a6f:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a72:	c1 e8 0c             	shr    $0xc,%eax
c0106a75:	40                   	inc    %eax
c0106a76:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106a7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a7d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a88:	c7 04 24 10 b6 10 c0 	movl   $0xc010b610,(%esp)
c0106a8f:	e8 e4 98 ff ff       	call   c0100378 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0106a94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a97:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106a9a:	c1 e8 0c             	shr    $0xc,%eax
c0106a9d:	40                   	inc    %eax
c0106a9e:	c1 e0 08             	shl    $0x8,%eax
c0106aa1:	89 c2                	mov    %eax,%edx
c0106aa3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106aa6:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0106aa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106aab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ab2:	00 
c0106ab3:	89 04 24             	mov    %eax,(%esp)
c0106ab6:	e8 ed e5 ff ff       	call   c01050a8 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0106abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106abe:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ac1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ac4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ac8:	89 04 24             	mov    %eax,(%esp)
c0106acb:	e8 2c ef ff ff       	call   c01059fc <tlb_invalidate>
     for (i = 0; i != n; ++ i)
c0106ad0:	ff 45 f4             	incl   -0xc(%ebp)
c0106ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ad6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106ad9:	0f 85 a1 fe ff ff    	jne    c0106980 <swap_out+0x12>
     }
     return i;
c0106adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106ae2:	89 ec                	mov    %ebp,%esp
c0106ae4:	5d                   	pop    %ebp
c0106ae5:	c3                   	ret    

c0106ae6 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106ae6:	55                   	push   %ebp
c0106ae7:	89 e5                	mov    %esp,%ebp
c0106ae9:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0106aec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106af3:	e8 43 e5 ff ff       	call   c010503b <alloc_pages>
c0106af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0106afb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106aff:	75 24                	jne    c0106b25 <swap_in+0x3f>
c0106b01:	c7 44 24 0c 50 b6 10 	movl   $0xc010b650,0xc(%esp)
c0106b08:	c0 
c0106b09:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106b10:	c0 
c0106b11:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0106b18:	00 
c0106b19:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106b20:	e8 01 a2 ff ff       	call   c0100d26 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106b25:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b28:	8b 40 0c             	mov    0xc(%eax),%eax
c0106b2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106b32:	00 
c0106b33:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106b36:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b3a:	89 04 24             	mov    %eax,(%esp)
c0106b3d:	e8 b4 eb ff ff       	call   c01056f6 <get_pte>
c0106b42:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b48:	8b 00                	mov    (%eax),%eax
c0106b4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b4d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106b51:	89 04 24             	mov    %eax,(%esp)
c0106b54:	e8 fc 1b 00 00       	call   c0108755 <swapfs_read>
c0106b59:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106b5c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106b60:	74 2a                	je     c0106b8c <swap_in+0xa6>
     {
        assert(r!=0);
c0106b62:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106b66:	75 24                	jne    c0106b8c <swap_in+0xa6>
c0106b68:	c7 44 24 0c 5d b6 10 	movl   $0xc010b65d,0xc(%esp)
c0106b6f:	c0 
c0106b70:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106b77:	c0 
c0106b78:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0106b7f:	00 
c0106b80:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106b87:	e8 9a a1 ff ff       	call   c0100d26 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0106b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b8f:	8b 00                	mov    (%eax),%eax
c0106b91:	c1 e8 08             	shr    $0x8,%eax
c0106b94:	89 c2                	mov    %eax,%edx
c0106b96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b99:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106ba1:	c7 04 24 64 b6 10 c0 	movl   $0xc010b664,(%esp)
c0106ba8:	e8 cb 97 ff ff       	call   c0100378 <cprintf>
     *ptr_result=result;
c0106bad:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106bb3:	89 10                	mov    %edx,(%eax)
     return 0;
c0106bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106bba:	89 ec                	mov    %ebp,%esp
c0106bbc:	5d                   	pop    %ebp
c0106bbd:	c3                   	ret    

c0106bbe <check_content_set>:



static inline void
check_content_set(void)
{
c0106bbe:	55                   	push   %ebp
c0106bbf:	89 e5                	mov    %esp,%ebp
c0106bc1:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106bc4:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106bc9:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106bcc:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106bd1:	83 f8 01             	cmp    $0x1,%eax
c0106bd4:	74 24                	je     c0106bfa <check_content_set+0x3c>
c0106bd6:	c7 44 24 0c a2 b6 10 	movl   $0xc010b6a2,0xc(%esp)
c0106bdd:	c0 
c0106bde:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106be5:	c0 
c0106be6:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0106bed:	00 
c0106bee:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106bf5:	e8 2c a1 ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106bfa:	b8 10 10 00 00       	mov    $0x1010,%eax
c0106bff:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106c02:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106c07:	83 f8 01             	cmp    $0x1,%eax
c0106c0a:	74 24                	je     c0106c30 <check_content_set+0x72>
c0106c0c:	c7 44 24 0c a2 b6 10 	movl   $0xc010b6a2,0xc(%esp)
c0106c13:	c0 
c0106c14:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106c1b:	c0 
c0106c1c:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0106c23:	00 
c0106c24:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106c2b:	e8 f6 a0 ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0106c30:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106c35:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106c38:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106c3d:	83 f8 02             	cmp    $0x2,%eax
c0106c40:	74 24                	je     c0106c66 <check_content_set+0xa8>
c0106c42:	c7 44 24 0c b1 b6 10 	movl   $0xc010b6b1,0xc(%esp)
c0106c49:	c0 
c0106c4a:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106c51:	c0 
c0106c52:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0106c59:	00 
c0106c5a:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106c61:	e8 c0 a0 ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0106c66:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106c6b:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106c6e:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106c73:	83 f8 02             	cmp    $0x2,%eax
c0106c76:	74 24                	je     c0106c9c <check_content_set+0xde>
c0106c78:	c7 44 24 0c b1 b6 10 	movl   $0xc010b6b1,0xc(%esp)
c0106c7f:	c0 
c0106c80:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106c87:	c0 
c0106c88:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106c8f:	00 
c0106c90:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106c97:	e8 8a a0 ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106c9c:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106ca1:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106ca4:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106ca9:	83 f8 03             	cmp    $0x3,%eax
c0106cac:	74 24                	je     c0106cd2 <check_content_set+0x114>
c0106cae:	c7 44 24 0c c0 b6 10 	movl   $0xc010b6c0,0xc(%esp)
c0106cb5:	c0 
c0106cb6:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106cbd:	c0 
c0106cbe:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106cc5:	00 
c0106cc6:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106ccd:	e8 54 a0 ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106cd2:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106cd7:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106cda:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106cdf:	83 f8 03             	cmp    $0x3,%eax
c0106ce2:	74 24                	je     c0106d08 <check_content_set+0x14a>
c0106ce4:	c7 44 24 0c c0 b6 10 	movl   $0xc010b6c0,0xc(%esp)
c0106ceb:	c0 
c0106cec:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106cf3:	c0 
c0106cf4:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106cfb:	00 
c0106cfc:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106d03:	e8 1e a0 ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106d08:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106d0d:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106d10:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106d15:	83 f8 04             	cmp    $0x4,%eax
c0106d18:	74 24                	je     c0106d3e <check_content_set+0x180>
c0106d1a:	c7 44 24 0c cf b6 10 	movl   $0xc010b6cf,0xc(%esp)
c0106d21:	c0 
c0106d22:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106d29:	c0 
c0106d2a:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0106d31:	00 
c0106d32:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106d39:	e8 e8 9f ff ff       	call   c0100d26 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0106d3e:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106d43:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106d46:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0106d4b:	83 f8 04             	cmp    $0x4,%eax
c0106d4e:	74 24                	je     c0106d74 <check_content_set+0x1b6>
c0106d50:	c7 44 24 0c cf b6 10 	movl   $0xc010b6cf,0xc(%esp)
c0106d57:	c0 
c0106d58:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106d5f:	c0 
c0106d60:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0106d67:	00 
c0106d68:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106d6f:	e8 b2 9f ff ff       	call   c0100d26 <__panic>
}
c0106d74:	90                   	nop
c0106d75:	89 ec                	mov    %ebp,%esp
c0106d77:	5d                   	pop    %ebp
c0106d78:	c3                   	ret    

c0106d79 <check_content_access>:

static inline int
check_content_access(void)
{
c0106d79:	55                   	push   %ebp
c0106d7a:	89 e5                	mov    %esp,%ebp
c0106d7c:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106d7f:	a1 00 c1 12 c0       	mov    0xc012c100,%eax
c0106d84:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106d87:	ff d0                	call   *%eax
c0106d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d8f:	89 ec                	mov    %ebp,%esp
c0106d91:	5d                   	pop    %ebp
c0106d92:	c3                   	ret    

c0106d93 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106d93:	55                   	push   %ebp
c0106d94:	89 e5                	mov    %esp,%ebp
c0106d96:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0106d99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106da0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0106da7:	c7 45 e8 84 bf 12 c0 	movl   $0xc012bf84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106dae:	eb 6a                	jmp    c0106e1a <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0106db0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106db3:	83 e8 0c             	sub    $0xc,%eax
c0106db6:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(PageProperty(p));
c0106db9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106dbc:	83 c0 04             	add    $0x4,%eax
c0106dbf:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106dc6:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106dc9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106dcc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106dcf:	0f a3 10             	bt     %edx,(%eax)
c0106dd2:	19 c0                	sbb    %eax,%eax
c0106dd4:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106dd7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106ddb:	0f 95 c0             	setne  %al
c0106dde:	0f b6 c0             	movzbl %al,%eax
c0106de1:	85 c0                	test   %eax,%eax
c0106de3:	75 24                	jne    c0106e09 <check_swap+0x76>
c0106de5:	c7 44 24 0c de b6 10 	movl   $0xc010b6de,0xc(%esp)
c0106dec:	c0 
c0106ded:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106df4:	c0 
c0106df5:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0106dfc:	00 
c0106dfd:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106e04:	e8 1d 9f ff ff       	call   c0100d26 <__panic>
        count ++, total += p->property;
c0106e09:	ff 45 f4             	incl   -0xc(%ebp)
c0106e0c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106e0f:	8b 50 08             	mov    0x8(%eax),%edx
c0106e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e15:	01 d0                	add    %edx,%eax
c0106e17:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106e1d:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106e20:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106e23:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c0106e26:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106e29:	81 7d e8 84 bf 12 c0 	cmpl   $0xc012bf84,-0x18(%ebp)
c0106e30:	0f 85 7a ff ff ff    	jne    c0106db0 <check_swap+0x1d>
     }
     assert(total == nr_free_pages());
c0106e36:	e8 a2 e2 ff ff       	call   c01050dd <nr_free_pages>
c0106e3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106e3e:	39 d0                	cmp    %edx,%eax
c0106e40:	74 24                	je     c0106e66 <check_swap+0xd3>
c0106e42:	c7 44 24 0c ee b6 10 	movl   $0xc010b6ee,0xc(%esp)
c0106e49:	c0 
c0106e4a:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106e51:	c0 
c0106e52:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0106e59:	00 
c0106e5a:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106e61:	e8 c0 9e ff ff       	call   c0100d26 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0106e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e69:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e74:	c7 04 24 08 b7 10 c0 	movl   $0xc010b708,(%esp)
c0106e7b:	e8 f8 94 ff ff       	call   c0100378 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106e80:	e8 1e 0b 00 00       	call   c01079a3 <mm_create>
c0106e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
     assert(mm != NULL);
c0106e88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e8c:	75 24                	jne    c0106eb2 <check_swap+0x11f>
c0106e8e:	c7 44 24 0c 2e b7 10 	movl   $0xc010b72e,0xc(%esp)
c0106e95:	c0 
c0106e96:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106e9d:	c0 
c0106e9e:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0106ea5:	00 
c0106ea6:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106ead:	e8 74 9e ff ff       	call   c0100d26 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106eb2:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c0106eb7:	85 c0                	test   %eax,%eax
c0106eb9:	74 24                	je     c0106edf <check_swap+0x14c>
c0106ebb:	c7 44 24 0c 39 b7 10 	movl   $0xc010b739,0xc(%esp)
c0106ec2:	c0 
c0106ec3:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106eca:	c0 
c0106ecb:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c0106ed2:	00 
c0106ed3:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106eda:	e8 47 9e ff ff       	call   c0100d26 <__panic>

     check_mm_struct = mm;
c0106edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ee2:	a3 0c c1 12 c0       	mov    %eax,0xc012c10c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106ee7:	8b 15 00 8a 12 c0    	mov    0xc0128a00,%edx
c0106eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ef0:	89 50 0c             	mov    %edx,0xc(%eax)
c0106ef3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ef6:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ef9:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(pgdir[0] == 0);
c0106efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106eff:	8b 00                	mov    (%eax),%eax
c0106f01:	85 c0                	test   %eax,%eax
c0106f03:	74 24                	je     c0106f29 <check_swap+0x196>
c0106f05:	c7 44 24 0c 51 b7 10 	movl   $0xc010b751,0xc(%esp)
c0106f0c:	c0 
c0106f0d:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106f14:	c0 
c0106f15:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106f1c:	00 
c0106f1d:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106f24:	e8 fd 9d ff ff       	call   c0100d26 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106f29:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0106f30:	00 
c0106f31:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106f38:	00 
c0106f39:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0106f40:	e8 d9 0a 00 00       	call   c0107a1e <vma_create>
c0106f45:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(vma != NULL);
c0106f48:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106f4c:	75 24                	jne    c0106f72 <check_swap+0x1df>
c0106f4e:	c7 44 24 0c 5f b7 10 	movl   $0xc010b75f,0xc(%esp)
c0106f55:	c0 
c0106f56:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106f5d:	c0 
c0106f5e:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0106f65:	00 
c0106f66:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106f6d:	e8 b4 9d ff ff       	call   c0100d26 <__panic>

     insert_vma_struct(mm, vma);
c0106f72:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f7c:	89 04 24             	mov    %eax,(%esp)
c0106f7f:	e8 31 0c 00 00       	call   c0107bb5 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0106f84:	c7 04 24 6c b7 10 c0 	movl   $0xc010b76c,(%esp)
c0106f8b:	e8 e8 93 ff ff       	call   c0100378 <cprintf>
     pte_t *temp_ptep=NULL;
c0106f90:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0106f97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f9a:	8b 40 0c             	mov    0xc(%eax),%eax
c0106f9d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106fa4:	00 
c0106fa5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106fac:	00 
c0106fad:	89 04 24             	mov    %eax,(%esp)
c0106fb0:	e8 41 e7 ff ff       	call   c01056f6 <get_pte>
c0106fb5:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(temp_ptep!= NULL);
c0106fb8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106fbc:	75 24                	jne    c0106fe2 <check_swap+0x24f>
c0106fbe:	c7 44 24 0c a0 b7 10 	movl   $0xc010b7a0,0xc(%esp)
c0106fc5:	c0 
c0106fc6:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0106fcd:	c0 
c0106fce:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106fd5:	00 
c0106fd6:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0106fdd:	e8 44 9d ff ff       	call   c0100d26 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106fe2:	c7 04 24 b4 b7 10 c0 	movl   $0xc010b7b4,(%esp)
c0106fe9:	e8 8a 93 ff ff       	call   c0100378 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106fee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106ff5:	e9 a2 00 00 00       	jmp    c010709c <check_swap+0x309>
          check_rp[i] = alloc_page();
c0106ffa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107001:	e8 35 e0 ff ff       	call   c010503b <alloc_pages>
c0107006:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107009:	89 04 95 cc c0 12 c0 	mov    %eax,-0x3fed3f34(,%edx,4)
          assert(check_rp[i] != NULL );
c0107010:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107013:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c010701a:	85 c0                	test   %eax,%eax
c010701c:	75 24                	jne    c0107042 <check_swap+0x2af>
c010701e:	c7 44 24 0c d8 b7 10 	movl   $0xc010b7d8,0xc(%esp)
c0107025:	c0 
c0107026:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c010702d:	c0 
c010702e:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0107035:	00 
c0107036:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c010703d:	e8 e4 9c ff ff       	call   c0100d26 <__panic>
          assert(!PageProperty(check_rp[i]));
c0107042:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107045:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c010704c:	83 c0 04             	add    $0x4,%eax
c010704f:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0107056:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107059:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010705c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010705f:	0f a3 10             	bt     %edx,(%eax)
c0107062:	19 c0                	sbb    %eax,%eax
c0107064:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c0107067:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c010706b:	0f 95 c0             	setne  %al
c010706e:	0f b6 c0             	movzbl %al,%eax
c0107071:	85 c0                	test   %eax,%eax
c0107073:	74 24                	je     c0107099 <check_swap+0x306>
c0107075:	c7 44 24 0c ec b7 10 	movl   $0xc010b7ec,0xc(%esp)
c010707c:	c0 
c010707d:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0107084:	c0 
c0107085:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010708c:	00 
c010708d:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0107094:	e8 8d 9c ff ff       	call   c0100d26 <__panic>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107099:	ff 45 ec             	incl   -0x14(%ebp)
c010709c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01070a0:	0f 8e 54 ff ff ff    	jle    c0106ffa <check_swap+0x267>
     }
     list_entry_t free_list_store = free_list;
c01070a6:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c01070ab:	8b 15 88 bf 12 c0    	mov    0xc012bf88,%edx
c01070b1:	89 45 98             	mov    %eax,-0x68(%ebp)
c01070b4:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01070b7:	c7 45 a4 84 bf 12 c0 	movl   $0xc012bf84,-0x5c(%ebp)
    elm->prev = elm->next = elm;
c01070be:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01070c1:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01070c4:	89 50 04             	mov    %edx,0x4(%eax)
c01070c7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01070ca:	8b 50 04             	mov    0x4(%eax),%edx
c01070cd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01070d0:	89 10                	mov    %edx,(%eax)
}
c01070d2:	90                   	nop
c01070d3:	c7 45 a8 84 bf 12 c0 	movl   $0xc012bf84,-0x58(%ebp)
    return list->next == list;
c01070da:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01070dd:	8b 40 04             	mov    0x4(%eax),%eax
c01070e0:	39 45 a8             	cmp    %eax,-0x58(%ebp)
c01070e3:	0f 94 c0             	sete   %al
c01070e6:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01070e9:	85 c0                	test   %eax,%eax
c01070eb:	75 24                	jne    c0107111 <check_swap+0x37e>
c01070ed:	c7 44 24 0c 07 b8 10 	movl   $0xc010b807,0xc(%esp)
c01070f4:	c0 
c01070f5:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c01070fc:	c0 
c01070fd:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c0107104:	00 
c0107105:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c010710c:	e8 15 9c ff ff       	call   c0100d26 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c0107111:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0107116:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     nr_free = 0;
c0107119:	c7 05 8c bf 12 c0 00 	movl   $0x0,0xc012bf8c
c0107120:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107123:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010712a:	eb 1d                	jmp    c0107149 <check_swap+0x3b6>
        free_pages(check_rp[i],1);
c010712c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010712f:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c0107136:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010713d:	00 
c010713e:	89 04 24             	mov    %eax,(%esp)
c0107141:	e8 62 df ff ff       	call   c01050a8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107146:	ff 45 ec             	incl   -0x14(%ebp)
c0107149:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010714d:	7e dd                	jle    c010712c <check_swap+0x399>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010714f:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c0107154:	83 f8 04             	cmp    $0x4,%eax
c0107157:	74 24                	je     c010717d <check_swap+0x3ea>
c0107159:	c7 44 24 0c 20 b8 10 	movl   $0xc010b820,0xc(%esp)
c0107160:	c0 
c0107161:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0107168:	c0 
c0107169:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107170:	00 
c0107171:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0107178:	e8 a9 9b ff ff       	call   c0100d26 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010717d:	c7 04 24 44 b8 10 c0 	movl   $0xc010b844,(%esp)
c0107184:	e8 ef 91 ff ff       	call   c0100378 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0107189:	c7 05 10 c1 12 c0 00 	movl   $0x0,0xc012c110
c0107190:	00 00 00 
     
     check_content_set();
c0107193:	e8 26 fa ff ff       	call   c0106bbe <check_content_set>
     assert( nr_free == 0);         
c0107198:	a1 8c bf 12 c0       	mov    0xc012bf8c,%eax
c010719d:	85 c0                	test   %eax,%eax
c010719f:	74 24                	je     c01071c5 <check_swap+0x432>
c01071a1:	c7 44 24 0c 6b b8 10 	movl   $0xc010b86b,0xc(%esp)
c01071a8:	c0 
c01071a9:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c01071b0:	c0 
c01071b1:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01071b8:	00 
c01071b9:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c01071c0:	e8 61 9b ff ff       	call   c0100d26 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01071c5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01071cc:	eb 25                	jmp    c01071f3 <check_swap+0x460>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01071ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071d1:	c7 04 85 60 c0 12 c0 	movl   $0xffffffff,-0x3fed3fa0(,%eax,4)
c01071d8:	ff ff ff ff 
c01071dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071df:	8b 14 85 60 c0 12 c0 	mov    -0x3fed3fa0(,%eax,4),%edx
c01071e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071e9:	89 14 85 a0 c0 12 c0 	mov    %edx,-0x3fed3f60(,%eax,4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01071f0:	ff 45 ec             	incl   -0x14(%ebp)
c01071f3:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01071f7:	7e d5                	jle    c01071ce <check_swap+0x43b>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01071f9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107200:	e9 e8 00 00 00       	jmp    c01072ed <check_swap+0x55a>
         check_ptep[i]=0;
c0107205:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107208:	c7 04 85 dc c0 12 c0 	movl   $0x0,-0x3fed3f24(,%eax,4)
c010720f:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0107213:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107216:	40                   	inc    %eax
c0107217:	c1 e0 0c             	shl    $0xc,%eax
c010721a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107221:	00 
c0107222:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107226:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107229:	89 04 24             	mov    %eax,(%esp)
c010722c:	e8 c5 e4 ff ff       	call   c01056f6 <get_pte>
c0107231:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107234:	89 04 95 dc c0 12 c0 	mov    %eax,-0x3fed3f24(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c010723b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010723e:	8b 04 85 dc c0 12 c0 	mov    -0x3fed3f24(,%eax,4),%eax
c0107245:	85 c0                	test   %eax,%eax
c0107247:	75 24                	jne    c010726d <check_swap+0x4da>
c0107249:	c7 44 24 0c 78 b8 10 	movl   $0xc010b878,0xc(%esp)
c0107250:	c0 
c0107251:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0107258:	c0 
c0107259:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107260:	00 
c0107261:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0107268:	e8 b9 9a ff ff       	call   c0100d26 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c010726d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107270:	8b 04 85 dc c0 12 c0 	mov    -0x3fed3f24(,%eax,4),%eax
c0107277:	8b 00                	mov    (%eax),%eax
c0107279:	89 04 24             	mov    %eax,(%esp)
c010727c:	e8 97 f5 ff ff       	call   c0106818 <pte2page>
c0107281:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107284:	8b 14 95 cc c0 12 c0 	mov    -0x3fed3f34(,%edx,4),%edx
c010728b:	39 d0                	cmp    %edx,%eax
c010728d:	74 24                	je     c01072b3 <check_swap+0x520>
c010728f:	c7 44 24 0c 90 b8 10 	movl   $0xc010b890,0xc(%esp)
c0107296:	c0 
c0107297:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c010729e:	c0 
c010729f:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01072a6:	00 
c01072a7:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c01072ae:	e8 73 9a ff ff       	call   c0100d26 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01072b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072b6:	8b 04 85 dc c0 12 c0 	mov    -0x3fed3f24(,%eax,4),%eax
c01072bd:	8b 00                	mov    (%eax),%eax
c01072bf:	83 e0 01             	and    $0x1,%eax
c01072c2:	85 c0                	test   %eax,%eax
c01072c4:	75 24                	jne    c01072ea <check_swap+0x557>
c01072c6:	c7 44 24 0c b8 b8 10 	movl   $0xc010b8b8,0xc(%esp)
c01072cd:	c0 
c01072ce:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c01072d5:	c0 
c01072d6:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01072dd:	00 
c01072de:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c01072e5:	e8 3c 9a ff ff       	call   c0100d26 <__panic>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01072ea:	ff 45 ec             	incl   -0x14(%ebp)
c01072ed:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01072f1:	0f 8e 0e ff ff ff    	jle    c0107205 <check_swap+0x472>
     }
     cprintf("set up init env for check_swap over!\n");
c01072f7:	c7 04 24 d4 b8 10 c0 	movl   $0xc010b8d4,(%esp)
c01072fe:	e8 75 90 ff ff       	call   c0100378 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0107303:	e8 71 fa ff ff       	call   c0106d79 <check_content_access>
c0107308:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(ret==0);
c010730b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010730f:	74 24                	je     c0107335 <check_swap+0x5a2>
c0107311:	c7 44 24 0c fa b8 10 	movl   $0xc010b8fa,0xc(%esp)
c0107318:	c0 
c0107319:	c7 44 24 08 e2 b5 10 	movl   $0xc010b5e2,0x8(%esp)
c0107320:	c0 
c0107321:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0107328:	00 
c0107329:	c7 04 24 7c b5 10 c0 	movl   $0xc010b57c,(%esp)
c0107330:	e8 f1 99 ff ff       	call   c0100d26 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107335:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010733c:	eb 1d                	jmp    c010735b <check_swap+0x5c8>
         free_pages(check_rp[i],1);
c010733e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107341:	8b 04 85 cc c0 12 c0 	mov    -0x3fed3f34(,%eax,4),%eax
c0107348:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010734f:	00 
c0107350:	89 04 24             	mov    %eax,(%esp)
c0107353:	e8 50 dd ff ff       	call   c01050a8 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107358:	ff 45 ec             	incl   -0x14(%ebp)
c010735b:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010735f:	7e dd                	jle    c010733e <check_swap+0x5ab>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0107361:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107364:	89 04 24             	mov    %eax,(%esp)
c0107367:	e8 7f 09 00 00       	call   c0107ceb <mm_destroy>
         
     nr_free = nr_free_store;
c010736c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010736f:	a3 8c bf 12 c0       	mov    %eax,0xc012bf8c
     free_list = free_list_store;
c0107374:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107377:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010737a:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
c010737f:	89 15 88 bf 12 c0    	mov    %edx,0xc012bf88

     
     le = &free_list;
c0107385:	c7 45 e8 84 bf 12 c0 	movl   $0xc012bf84,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010738c:	eb 1c                	jmp    c01073aa <check_swap+0x617>
         struct Page *p = le2page(le, page_link);
c010738e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107391:	83 e8 0c             	sub    $0xc,%eax
c0107394:	89 45 cc             	mov    %eax,-0x34(%ebp)
         count --, total -= p->property;
c0107397:	ff 4d f4             	decl   -0xc(%ebp)
c010739a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010739d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01073a0:	8b 48 08             	mov    0x8(%eax),%ecx
c01073a3:	89 d0                	mov    %edx,%eax
c01073a5:	29 c8                	sub    %ecx,%eax
c01073a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01073aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01073ad:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return listelm->next;
c01073b0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01073b3:	8b 40 04             	mov    0x4(%eax),%eax
     while ((le = list_next(le)) != &free_list) {
c01073b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01073b9:	81 7d e8 84 bf 12 c0 	cmpl   $0xc012bf84,-0x18(%ebp)
c01073c0:	75 cc                	jne    c010738e <check_swap+0x5fb>
     }
     cprintf("count is %d, total is %d\n",count,total);
c01073c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073c5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01073c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01073d0:	c7 04 24 01 b9 10 c0 	movl   $0xc010b901,(%esp)
c01073d7:	e8 9c 8f ff ff       	call   c0100378 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01073dc:	c7 04 24 1b b9 10 c0 	movl   $0xc010b91b,(%esp)
c01073e3:	e8 90 8f ff ff       	call   c0100378 <cprintf>
}
c01073e8:	90                   	nop
c01073e9:	89 ec                	mov    %ebp,%esp
c01073eb:	5d                   	pop    %ebp
c01073ec:	c3                   	ret    

c01073ed <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c01073ed:	55                   	push   %ebp
c01073ee:	89 e5                	mov    %esp,%ebp
c01073f0:	83 ec 10             	sub    $0x10,%esp
c01073f3:	c7 45 fc 04 c1 12 c0 	movl   $0xc012c104,-0x4(%ebp)
    elm->prev = elm->next = elm;
c01073fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01073fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107400:	89 50 04             	mov    %edx,0x4(%eax)
c0107403:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107406:	8b 50 04             	mov    0x4(%eax),%edx
c0107409:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010740c:	89 10                	mov    %edx,(%eax)
}
c010740e:	90                   	nop
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c010740f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107412:	c7 40 14 04 c1 12 c0 	movl   $0xc012c104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107419:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010741e:	89 ec                	mov    %ebp,%esp
c0107420:	5d                   	pop    %ebp
c0107421:	c3                   	ret    

c0107422 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107422:	55                   	push   %ebp
c0107423:	89 e5                	mov    %esp,%ebp
c0107425:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107428:	8b 45 08             	mov    0x8(%ebp),%eax
c010742b:	8b 40 14             	mov    0x14(%eax),%eax
c010742e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107431:	8b 45 10             	mov    0x10(%ebp),%eax
c0107434:	83 c0 14             	add    $0x14,%eax
c0107437:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c010743a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010743e:	74 06                	je     c0107446 <_fifo_map_swappable+0x24>
c0107440:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107444:	75 24                	jne    c010746a <_fifo_map_swappable+0x48>
c0107446:	c7 44 24 0c 34 b9 10 	movl   $0xc010b934,0xc(%esp)
c010744d:	c0 
c010744e:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107455:	c0 
c0107456:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c010745d:	00 
c010745e:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107465:	e8 bc 98 ff ff       	call   c0100d26 <__panic>
c010746a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010746d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107470:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107473:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107476:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107479:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010747c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010747f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107485:	8b 40 04             	mov    0x4(%eax),%eax
c0107488:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010748b:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010748e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107491:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    prev->next = next->prev = elm;
c0107497:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010749a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010749d:	89 10                	mov    %edx,(%eax)
c010749f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01074a2:	8b 10                	mov    (%eax),%edx
c01074a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01074a7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01074aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01074b0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01074b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01074b9:	89 10                	mov    %edx,(%eax)
}
c01074bb:	90                   	nop
}
c01074bc:	90                   	nop
}
c01074bd:	90                   	nop
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c01074be:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01074c3:	89 ec                	mov    %ebp,%esp
c01074c5:	5d                   	pop    %ebp
c01074c6:	c3                   	ret    

c01074c7 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c01074c7:	55                   	push   %ebp
c01074c8:	89 e5                	mov    %esp,%ebp
c01074ca:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01074cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01074d0:	8b 40 14             	mov    0x14(%eax),%eax
c01074d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c01074d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01074da:	75 24                	jne    c0107500 <_fifo_swap_out_victim+0x39>
c01074dc:	c7 44 24 0c 7b b9 10 	movl   $0xc010b97b,0xc(%esp)
c01074e3:	c0 
c01074e4:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c01074eb:	c0 
c01074ec:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c01074f3:	00 
c01074f4:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c01074fb:	e8 26 98 ff ff       	call   c0100d26 <__panic>
     assert(in_tick==0);
c0107500:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107504:	74 24                	je     c010752a <_fifo_swap_out_victim+0x63>
c0107506:	c7 44 24 0c 88 b9 10 	movl   $0xc010b988,0xc(%esp)
c010750d:	c0 
c010750e:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107515:	c0 
c0107516:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c010751d:	00 
c010751e:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107525:	e8 fc 97 ff ff       	call   c0100d26 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
         list_entry_t *le = head->prev;
c010752a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010752d:	8b 00                	mov    (%eax),%eax
c010752f:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0107532:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107535:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107538:	75 24                	jne    c010755e <_fifo_swap_out_victim+0x97>
c010753a:	c7 44 24 0c 93 b9 10 	movl   $0xc010b993,0xc(%esp)
c0107541:	c0 
c0107542:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107549:	c0 
c010754a:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0107551:	00 
c0107552:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107559:	e8 c8 97 ff ff       	call   c0100d26 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c010755e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107561:	83 e8 14             	sub    $0x14,%eax
c0107564:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107567:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010756a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_del(listelm->prev, listelm->next);
c010756d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107570:	8b 40 04             	mov    0x4(%eax),%eax
c0107573:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107576:	8b 12                	mov    (%edx),%edx
c0107578:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010757b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    prev->next = next;
c010757e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107581:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107584:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107587:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010758a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010758d:	89 10                	mov    %edx,(%eax)
}
c010758f:	90                   	nop
}
c0107590:	90                   	nop
     list_del(le);
     assert(p !=NULL);
c0107591:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107595:	75 24                	jne    c01075bb <_fifo_swap_out_victim+0xf4>
c0107597:	c7 44 24 0c 9c b9 10 	movl   $0xc010b99c,0xc(%esp)
c010759e:	c0 
c010759f:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c01075a6:	c0 
c01075a7:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c01075ae:	00 
c01075af:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c01075b6:	e8 6b 97 ff ff       	call   c0100d26 <__panic>
     *ptr_page = p; 
c01075bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01075be:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01075c1:	89 10                	mov    %edx,(%eax)
     return 0;
c01075c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075c8:	89 ec                	mov    %ebp,%esp
c01075ca:	5d                   	pop    %ebp
c01075cb:	c3                   	ret    

c01075cc <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c01075cc:	55                   	push   %ebp
c01075cd:	89 e5                	mov    %esp,%ebp
c01075cf:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01075d2:	c7 04 24 a8 b9 10 c0 	movl   $0xc010b9a8,(%esp)
c01075d9:	e8 9a 8d ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01075de:	b8 00 30 00 00       	mov    $0x3000,%eax
c01075e3:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01075e6:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01075eb:	83 f8 04             	cmp    $0x4,%eax
c01075ee:	74 24                	je     c0107614 <_fifo_check_swap+0x48>
c01075f0:	c7 44 24 0c ce b9 10 	movl   $0xc010b9ce,0xc(%esp)
c01075f7:	c0 
c01075f8:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c01075ff:	c0 
c0107600:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0107607:	00 
c0107608:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c010760f:	e8 12 97 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107614:	c7 04 24 e0 b9 10 c0 	movl   $0xc010b9e0,(%esp)
c010761b:	e8 58 8d ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107620:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107625:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107628:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010762d:	83 f8 04             	cmp    $0x4,%eax
c0107630:	74 24                	je     c0107656 <_fifo_check_swap+0x8a>
c0107632:	c7 44 24 0c ce b9 10 	movl   $0xc010b9ce,0xc(%esp)
c0107639:	c0 
c010763a:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107641:	c0 
c0107642:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0107649:	00 
c010764a:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107651:	e8 d0 96 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107656:	c7 04 24 08 ba 10 c0 	movl   $0xc010ba08,(%esp)
c010765d:	e8 16 8d ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107662:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107667:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010766a:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010766f:	83 f8 04             	cmp    $0x4,%eax
c0107672:	74 24                	je     c0107698 <_fifo_check_swap+0xcc>
c0107674:	c7 44 24 0c ce b9 10 	movl   $0xc010b9ce,0xc(%esp)
c010767b:	c0 
c010767c:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107683:	c0 
c0107684:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c010768b:	00 
c010768c:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107693:	e8 8e 96 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107698:	c7 04 24 30 ba 10 c0 	movl   $0xc010ba30,(%esp)
c010769f:	e8 d4 8c ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01076a4:	b8 00 20 00 00       	mov    $0x2000,%eax
c01076a9:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c01076ac:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01076b1:	83 f8 04             	cmp    $0x4,%eax
c01076b4:	74 24                	je     c01076da <_fifo_check_swap+0x10e>
c01076b6:	c7 44 24 0c ce b9 10 	movl   $0xc010b9ce,0xc(%esp)
c01076bd:	c0 
c01076be:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c01076c5:	c0 
c01076c6:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c01076cd:	00 
c01076ce:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c01076d5:	e8 4c 96 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01076da:	c7 04 24 58 ba 10 c0 	movl   $0xc010ba58,(%esp)
c01076e1:	e8 92 8c ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01076e6:	b8 00 50 00 00       	mov    $0x5000,%eax
c01076eb:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01076ee:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01076f3:	83 f8 05             	cmp    $0x5,%eax
c01076f6:	74 24                	je     c010771c <_fifo_check_swap+0x150>
c01076f8:	c7 44 24 0c 7e ba 10 	movl   $0xc010ba7e,0xc(%esp)
c01076ff:	c0 
c0107700:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107707:	c0 
c0107708:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c010770f:	00 
c0107710:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107717:	e8 0a 96 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010771c:	c7 04 24 30 ba 10 c0 	movl   $0xc010ba30,(%esp)
c0107723:	e8 50 8c ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107728:	b8 00 20 00 00       	mov    $0x2000,%eax
c010772d:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107730:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107735:	83 f8 05             	cmp    $0x5,%eax
c0107738:	74 24                	je     c010775e <_fifo_check_swap+0x192>
c010773a:	c7 44 24 0c 7e ba 10 	movl   $0xc010ba7e,0xc(%esp)
c0107741:	c0 
c0107742:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107749:	c0 
c010774a:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0107751:	00 
c0107752:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107759:	e8 c8 95 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010775e:	c7 04 24 e0 b9 10 c0 	movl   $0xc010b9e0,(%esp)
c0107765:	e8 0e 8c ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010776a:	b8 00 10 00 00       	mov    $0x1000,%eax
c010776f:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107772:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0107777:	83 f8 06             	cmp    $0x6,%eax
c010777a:	74 24                	je     c01077a0 <_fifo_check_swap+0x1d4>
c010777c:	c7 44 24 0c 8d ba 10 	movl   $0xc010ba8d,0xc(%esp)
c0107783:	c0 
c0107784:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c010778b:	c0 
c010778c:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0107793:	00 
c0107794:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c010779b:	e8 86 95 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01077a0:	c7 04 24 30 ba 10 c0 	movl   $0xc010ba30,(%esp)
c01077a7:	e8 cc 8b ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01077ac:	b8 00 20 00 00       	mov    $0x2000,%eax
c01077b1:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01077b4:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01077b9:	83 f8 07             	cmp    $0x7,%eax
c01077bc:	74 24                	je     c01077e2 <_fifo_check_swap+0x216>
c01077be:	c7 44 24 0c 9c ba 10 	movl   $0xc010ba9c,0xc(%esp)
c01077c5:	c0 
c01077c6:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c01077cd:	c0 
c01077ce:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01077d5:	00 
c01077d6:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c01077dd:	e8 44 95 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01077e2:	c7 04 24 a8 b9 10 c0 	movl   $0xc010b9a8,(%esp)
c01077e9:	e8 8a 8b ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01077ee:	b8 00 30 00 00       	mov    $0x3000,%eax
c01077f3:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01077f6:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01077fb:	83 f8 08             	cmp    $0x8,%eax
c01077fe:	74 24                	je     c0107824 <_fifo_check_swap+0x258>
c0107800:	c7 44 24 0c ab ba 10 	movl   $0xc010baab,0xc(%esp)
c0107807:	c0 
c0107808:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c010780f:	c0 
c0107810:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0107817:	00 
c0107818:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c010781f:	e8 02 95 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107824:	c7 04 24 08 ba 10 c0 	movl   $0xc010ba08,(%esp)
c010782b:	e8 48 8b ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107830:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107835:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107838:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010783d:	83 f8 09             	cmp    $0x9,%eax
c0107840:	74 24                	je     c0107866 <_fifo_check_swap+0x29a>
c0107842:	c7 44 24 0c ba ba 10 	movl   $0xc010baba,0xc(%esp)
c0107849:	c0 
c010784a:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107851:	c0 
c0107852:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0107859:	00 
c010785a:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107861:	e8 c0 94 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107866:	c7 04 24 58 ba 10 c0 	movl   $0xc010ba58,(%esp)
c010786d:	e8 06 8b ff ff       	call   c0100378 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107872:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107877:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010787a:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c010787f:	83 f8 0a             	cmp    $0xa,%eax
c0107882:	74 24                	je     c01078a8 <_fifo_check_swap+0x2dc>
c0107884:	c7 44 24 0c c9 ba 10 	movl   $0xc010bac9,0xc(%esp)
c010788b:	c0 
c010788c:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107893:	c0 
c0107894:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010789b:	00 
c010789c:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c01078a3:	e8 7e 94 ff ff       	call   c0100d26 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01078a8:	c7 04 24 e0 b9 10 c0 	movl   $0xc010b9e0,(%esp)
c01078af:	e8 c4 8a ff ff       	call   c0100378 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01078b4:	b8 00 10 00 00       	mov    $0x1000,%eax
c01078b9:	0f b6 00             	movzbl (%eax),%eax
c01078bc:	3c 0a                	cmp    $0xa,%al
c01078be:	74 24                	je     c01078e4 <_fifo_check_swap+0x318>
c01078c0:	c7 44 24 0c dc ba 10 	movl   $0xc010badc,0xc(%esp)
c01078c7:	c0 
c01078c8:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c01078cf:	c0 
c01078d0:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01078d7:	00 
c01078d8:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c01078df:	e8 42 94 ff ff       	call   c0100d26 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01078e4:	b8 00 10 00 00       	mov    $0x1000,%eax
c01078e9:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01078ec:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c01078f1:	83 f8 0b             	cmp    $0xb,%eax
c01078f4:	74 24                	je     c010791a <_fifo_check_swap+0x34e>
c01078f6:	c7 44 24 0c fd ba 10 	movl   $0xc010bafd,0xc(%esp)
c01078fd:	c0 
c01078fe:	c7 44 24 08 52 b9 10 	movl   $0xc010b952,0x8(%esp)
c0107905:	c0 
c0107906:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c010790d:	00 
c010790e:	c7 04 24 67 b9 10 c0 	movl   $0xc010b967,(%esp)
c0107915:	e8 0c 94 ff ff       	call   c0100d26 <__panic>
    return 0;
c010791a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010791f:	89 ec                	mov    %ebp,%esp
c0107921:	5d                   	pop    %ebp
c0107922:	c3                   	ret    

c0107923 <_fifo_init>:


static int
_fifo_init(void)
{
c0107923:	55                   	push   %ebp
c0107924:	89 e5                	mov    %esp,%ebp
    return 0;
c0107926:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010792b:	5d                   	pop    %ebp
c010792c:	c3                   	ret    

c010792d <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010792d:	55                   	push   %ebp
c010792e:	89 e5                	mov    %esp,%ebp
    return 0;
c0107930:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107935:	5d                   	pop    %ebp
c0107936:	c3                   	ret    

c0107937 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107937:	55                   	push   %ebp
c0107938:	89 e5                	mov    %esp,%ebp
c010793a:	b8 00 00 00 00       	mov    $0x0,%eax
c010793f:	5d                   	pop    %ebp
c0107940:	c3                   	ret    

c0107941 <pa2page>:
pa2page(uintptr_t pa) {
c0107941:	55                   	push   %ebp
c0107942:	89 e5                	mov    %esp,%ebp
c0107944:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107947:	8b 45 08             	mov    0x8(%ebp),%eax
c010794a:	c1 e8 0c             	shr    $0xc,%eax
c010794d:	89 c2                	mov    %eax,%edx
c010794f:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c0107954:	39 c2                	cmp    %eax,%edx
c0107956:	72 1c                	jb     c0107974 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107958:	c7 44 24 08 20 bb 10 	movl   $0xc010bb20,0x8(%esp)
c010795f:	c0 
c0107960:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0107967:	00 
c0107968:	c7 04 24 3f bb 10 c0 	movl   $0xc010bb3f,(%esp)
c010796f:	e8 b2 93 ff ff       	call   c0100d26 <__panic>
    return &pages[PPN(pa)];
c0107974:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c010797a:	8b 45 08             	mov    0x8(%ebp),%eax
c010797d:	c1 e8 0c             	shr    $0xc,%eax
c0107980:	c1 e0 05             	shl    $0x5,%eax
c0107983:	01 d0                	add    %edx,%eax
}
c0107985:	89 ec                	mov    %ebp,%esp
c0107987:	5d                   	pop    %ebp
c0107988:	c3                   	ret    

c0107989 <pde2page>:
pde2page(pde_t pde) {
c0107989:	55                   	push   %ebp
c010798a:	89 e5                	mov    %esp,%ebp
c010798c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010798f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107992:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107997:	89 04 24             	mov    %eax,(%esp)
c010799a:	e8 a2 ff ff ff       	call   c0107941 <pa2page>
}
c010799f:	89 ec                	mov    %ebp,%esp
c01079a1:	5d                   	pop    %ebp
c01079a2:	c3                   	ret    

c01079a3 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01079a3:	55                   	push   %ebp
c01079a4:	89 e5                	mov    %esp,%ebp
c01079a6:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01079a9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01079b0:	e8 f5 d1 ff ff       	call   c0104baa <kmalloc>
c01079b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01079b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01079bc:	74 59                	je     c0107a17 <mm_create+0x74>
        list_init(&(mm->mmap_list));
c01079be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    elm->prev = elm->next = elm;
c01079c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01079ca:	89 50 04             	mov    %edx,0x4(%eax)
c01079cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079d0:	8b 50 04             	mov    0x4(%eax),%edx
c01079d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079d6:	89 10                	mov    %edx,(%eax)
}
c01079d8:	90                   	nop
        mm->mmap_cache = NULL;
c01079d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079e6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01079ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079f0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01079f7:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c01079fc:	85 c0                	test   %eax,%eax
c01079fe:	74 0d                	je     c0107a0d <mm_create+0x6a>
c0107a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a03:	89 04 24             	mov    %eax,(%esp)
c0107a06:	e8 df ee ff ff       	call   c01068ea <swap_init_mm>
c0107a0b:	eb 0a                	jmp    c0107a17 <mm_create+0x74>
        else mm->sm_priv = NULL;
c0107a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a10:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107a1a:	89 ec                	mov    %ebp,%esp
c0107a1c:	5d                   	pop    %ebp
c0107a1d:	c3                   	ret    

c0107a1e <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107a1e:	55                   	push   %ebp
c0107a1f:	89 e5                	mov    %esp,%ebp
c0107a21:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0107a24:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107a2b:	e8 7a d1 ff ff       	call   c0104baa <kmalloc>
c0107a30:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0107a33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a37:	74 1b                	je     c0107a54 <vma_create+0x36>
        vma->vm_start = vm_start;
c0107a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a3c:	8b 55 08             	mov    0x8(%ebp),%edx
c0107a3f:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0107a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a45:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107a48:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a4e:	8b 55 10             	mov    0x10(%ebp),%edx
c0107a51:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107a57:	89 ec                	mov    %ebp,%esp
c0107a59:	5d                   	pop    %ebp
c0107a5a:	c3                   	ret    

c0107a5b <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107a5b:	55                   	push   %ebp
c0107a5c:	89 e5                	mov    %esp,%ebp
c0107a5e:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0107a61:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0107a68:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107a6c:	0f 84 95 00 00 00    	je     c0107b07 <find_vma+0xac>
        vma = mm->mmap_cache;
c0107a72:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a75:	8b 40 08             	mov    0x8(%eax),%eax
c0107a78:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0107a7b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107a7f:	74 16                	je     c0107a97 <find_vma+0x3c>
c0107a81:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a84:	8b 40 04             	mov    0x4(%eax),%eax
c0107a87:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107a8a:	72 0b                	jb     c0107a97 <find_vma+0x3c>
c0107a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a8f:	8b 40 08             	mov    0x8(%eax),%eax
c0107a92:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107a95:	72 61                	jb     c0107af8 <find_vma+0x9d>
                bool found = 0;
c0107a97:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0107a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107aa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0107aaa:	eb 28                	jmp    c0107ad4 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0107aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107aaf:	83 e8 10             	sub    $0x10,%eax
c0107ab2:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0107ab5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ab8:	8b 40 04             	mov    0x4(%eax),%eax
c0107abb:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107abe:	72 14                	jb     c0107ad4 <find_vma+0x79>
c0107ac0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ac3:	8b 40 08             	mov    0x8(%eax),%eax
c0107ac6:	39 45 0c             	cmp    %eax,0xc(%ebp)
c0107ac9:	73 09                	jae    c0107ad4 <find_vma+0x79>
                        found = 1;
c0107acb:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0107ad2:	eb 17                	jmp    c0107aeb <find_vma+0x90>
c0107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return listelm->next;
c0107ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107add:	8b 40 04             	mov    0x4(%eax),%eax
                while ((le = list_next(le)) != list) {
c0107ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ae6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107ae9:	75 c1                	jne    c0107aac <find_vma+0x51>
                    }
                }
                if (!found) {
c0107aeb:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0107aef:	75 07                	jne    c0107af8 <find_vma+0x9d>
                    vma = NULL;
c0107af1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0107af8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107afc:	74 09                	je     c0107b07 <find_vma+0xac>
            mm->mmap_cache = vma;
c0107afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b01:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107b04:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0107b07:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107b0a:	89 ec                	mov    %ebp,%esp
c0107b0c:	5d                   	pop    %ebp
c0107b0d:	c3                   	ret    

c0107b0e <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0107b0e:	55                   	push   %ebp
c0107b0f:	89 e5                	mov    %esp,%ebp
c0107b11:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0107b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b17:	8b 50 04             	mov    0x4(%eax),%edx
c0107b1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b1d:	8b 40 08             	mov    0x8(%eax),%eax
c0107b20:	39 c2                	cmp    %eax,%edx
c0107b22:	72 24                	jb     c0107b48 <check_vma_overlap+0x3a>
c0107b24:	c7 44 24 0c 4d bb 10 	movl   $0xc010bb4d,0xc(%esp)
c0107b2b:	c0 
c0107b2c:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107b33:	c0 
c0107b34:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0107b3b:	00 
c0107b3c:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107b43:	e8 de 91 ff ff       	call   c0100d26 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0107b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b4b:	8b 50 08             	mov    0x8(%eax),%edx
c0107b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b51:	8b 40 04             	mov    0x4(%eax),%eax
c0107b54:	39 c2                	cmp    %eax,%edx
c0107b56:	76 24                	jbe    c0107b7c <check_vma_overlap+0x6e>
c0107b58:	c7 44 24 0c 90 bb 10 	movl   $0xc010bb90,0xc(%esp)
c0107b5f:	c0 
c0107b60:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107b67:	c0 
c0107b68:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0107b6f:	00 
c0107b70:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107b77:	e8 aa 91 ff ff       	call   c0100d26 <__panic>
    assert(next->vm_start < next->vm_end);
c0107b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b7f:	8b 50 04             	mov    0x4(%eax),%edx
c0107b82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b85:	8b 40 08             	mov    0x8(%eax),%eax
c0107b88:	39 c2                	cmp    %eax,%edx
c0107b8a:	72 24                	jb     c0107bb0 <check_vma_overlap+0xa2>
c0107b8c:	c7 44 24 0c af bb 10 	movl   $0xc010bbaf,0xc(%esp)
c0107b93:	c0 
c0107b94:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107b9b:	c0 
c0107b9c:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0107ba3:	00 
c0107ba4:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107bab:	e8 76 91 ff ff       	call   c0100d26 <__panic>
}
c0107bb0:	90                   	nop
c0107bb1:	89 ec                	mov    %ebp,%esp
c0107bb3:	5d                   	pop    %ebp
c0107bb4:	c3                   	ret    

c0107bb5 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0107bb5:	55                   	push   %ebp
c0107bb6:	89 e5                	mov    %esp,%ebp
c0107bb8:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0107bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bbe:	8b 50 04             	mov    0x4(%eax),%edx
c0107bc1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107bc4:	8b 40 08             	mov    0x8(%eax),%eax
c0107bc7:	39 c2                	cmp    %eax,%edx
c0107bc9:	72 24                	jb     c0107bef <insert_vma_struct+0x3a>
c0107bcb:	c7 44 24 0c cd bb 10 	movl   $0xc010bbcd,0xc(%esp)
c0107bd2:	c0 
c0107bd3:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107bda:	c0 
c0107bdb:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107be2:	00 
c0107be3:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107bea:	e8 37 91 ff ff       	call   c0100d26 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0107bef:	8b 45 08             	mov    0x8(%ebp),%eax
c0107bf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0107bf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107bf8:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0107bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0107c01:	eb 1f                	jmp    c0107c22 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0107c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c06:	83 e8 10             	sub    $0x10,%eax
c0107c09:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0107c0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107c0f:	8b 50 04             	mov    0x4(%eax),%edx
c0107c12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c15:	8b 40 04             	mov    0x4(%eax),%eax
c0107c18:	39 c2                	cmp    %eax,%edx
c0107c1a:	77 1f                	ja     c0107c3b <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c0107c1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c25:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107c28:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107c2b:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) {
c0107c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c34:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107c37:	75 ca                	jne    c0107c03 <insert_vma_struct+0x4e>
c0107c39:	eb 01                	jmp    c0107c3c <insert_vma_struct+0x87>
                break;
c0107c3b:	90                   	nop
c0107c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107c42:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c45:	8b 40 04             	mov    0x4(%eax),%eax
        }

    le_next = list_next(le_prev);
c0107c48:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c4e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107c51:	74 15                	je     c0107c68 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c56:	8d 50 f0             	lea    -0x10(%eax),%edx
c0107c59:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c60:	89 14 24             	mov    %edx,(%esp)
c0107c63:	e8 a6 fe ff ff       	call   c0107b0e <check_vma_overlap>
    }
    if (le_next != list) {
c0107c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c6b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107c6e:	74 15                	je     c0107c85 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0107c70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c73:	83 e8 10             	sub    $0x10,%eax
c0107c76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c7d:	89 04 24             	mov    %eax,(%esp)
c0107c80:	e8 89 fe ff ff       	call   c0107b0e <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0107c85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c88:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c8b:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0107c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c90:	8d 50 10             	lea    0x10(%eax),%edx
c0107c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c96:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107c99:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    __list_add(elm, listelm, listelm->next);
c0107c9c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c9f:	8b 40 04             	mov    0x4(%eax),%eax
c0107ca2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107ca5:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107ca8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107cab:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0107cae:	89 45 c8             	mov    %eax,-0x38(%ebp)
    prev->next = next->prev = elm;
c0107cb1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107cb4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107cb7:	89 10                	mov    %edx,(%eax)
c0107cb9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107cbc:	8b 10                	mov    (%eax),%edx
c0107cbe:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107cc1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107cc4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107cc7:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107cca:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107ccd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107cd0:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107cd3:	89 10                	mov    %edx,(%eax)
}
c0107cd5:	90                   	nop
}
c0107cd6:	90                   	nop

    mm->map_count ++;
c0107cd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cda:	8b 40 10             	mov    0x10(%eax),%eax
c0107cdd:	8d 50 01             	lea    0x1(%eax),%edx
c0107ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ce3:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107ce6:	90                   	nop
c0107ce7:	89 ec                	mov    %ebp,%esp
c0107ce9:	5d                   	pop    %ebp
c0107cea:	c3                   	ret    

c0107ceb <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0107ceb:	55                   	push   %ebp
c0107cec:	89 e5                	mov    %esp,%ebp
c0107cee:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0107cf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0107cf7:	eb 38                	jmp    c0107d31 <mm_destroy+0x46>
c0107cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107cfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    __list_del(listelm->prev, listelm->next);
c0107cff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d02:	8b 40 04             	mov    0x4(%eax),%eax
c0107d05:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d08:	8b 12                	mov    (%edx),%edx
c0107d0a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0107d0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    prev->next = next;
c0107d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d13:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d16:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d1c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107d1f:	89 10                	mov    %edx,(%eax)
}
c0107d21:	90                   	nop
}
c0107d22:	90                   	nop
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0107d23:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d26:	83 e8 10             	sub    $0x10,%eax
c0107d29:	89 04 24             	mov    %eax,(%esp)
c0107d2c:	e8 96 ce ff ff       	call   c0104bc7 <kfree>
c0107d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d34:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return listelm->next;
c0107d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d3a:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(list)) != list) {
c0107d3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107d43:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107d46:	75 b1                	jne    c0107cf9 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
c0107d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d4b:	89 04 24             	mov    %eax,(%esp)
c0107d4e:	e8 74 ce ff ff       	call   c0104bc7 <kfree>
    mm=NULL;
c0107d53:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107d5a:	90                   	nop
c0107d5b:	89 ec                	mov    %ebp,%esp
c0107d5d:	5d                   	pop    %ebp
c0107d5e:	c3                   	ret    

c0107d5f <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0107d5f:	55                   	push   %ebp
c0107d60:	89 e5                	mov    %esp,%ebp
c0107d62:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0107d65:	e8 05 00 00 00       	call   c0107d6f <check_vmm>
}
c0107d6a:	90                   	nop
c0107d6b:	89 ec                	mov    %ebp,%esp
c0107d6d:	5d                   	pop    %ebp
c0107d6e:	c3                   	ret    

c0107d6f <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0107d6f:	55                   	push   %ebp
c0107d70:	89 e5                	mov    %esp,%ebp
c0107d72:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107d75:	e8 63 d3 ff ff       	call   c01050dd <nr_free_pages>
c0107d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0107d7d:	e8 16 00 00 00       	call   c0107d98 <check_vma_struct>
    check_pgfault();
c0107d82:	e8 a5 04 00 00       	call   c010822c <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0107d87:	c7 04 24 e9 bb 10 c0 	movl   $0xc010bbe9,(%esp)
c0107d8e:	e8 e5 85 ff ff       	call   c0100378 <cprintf>
}
c0107d93:	90                   	nop
c0107d94:	89 ec                	mov    %ebp,%esp
c0107d96:	5d                   	pop    %ebp
c0107d97:	c3                   	ret    

c0107d98 <check_vma_struct>:

static void
check_vma_struct(void) {
c0107d98:	55                   	push   %ebp
c0107d99:	89 e5                	mov    %esp,%ebp
c0107d9b:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107d9e:	e8 3a d3 ff ff       	call   c01050dd <nr_free_pages>
c0107da3:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107da6:	e8 f8 fb ff ff       	call   c01079a3 <mm_create>
c0107dab:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107dae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107db2:	75 24                	jne    c0107dd8 <check_vma_struct+0x40>
c0107db4:	c7 44 24 0c 01 bc 10 	movl   $0xc010bc01,0xc(%esp)
c0107dbb:	c0 
c0107dbc:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107dc3:	c0 
c0107dc4:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0107dcb:	00 
c0107dcc:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107dd3:	e8 4e 8f ff ff       	call   c0100d26 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0107dd8:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107ddf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107de2:	89 d0                	mov    %edx,%eax
c0107de4:	c1 e0 02             	shl    $0x2,%eax
c0107de7:	01 d0                	add    %edx,%eax
c0107de9:	01 c0                	add    %eax,%eax
c0107deb:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107df1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107df4:	eb 6f                	jmp    c0107e65 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107df6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107df9:	89 d0                	mov    %edx,%eax
c0107dfb:	c1 e0 02             	shl    $0x2,%eax
c0107dfe:	01 d0                	add    %edx,%eax
c0107e00:	83 c0 02             	add    $0x2,%eax
c0107e03:	89 c1                	mov    %eax,%ecx
c0107e05:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e08:	89 d0                	mov    %edx,%eax
c0107e0a:	c1 e0 02             	shl    $0x2,%eax
c0107e0d:	01 d0                	add    %edx,%eax
c0107e0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e16:	00 
c0107e17:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107e1b:	89 04 24             	mov    %eax,(%esp)
c0107e1e:	e8 fb fb ff ff       	call   c0107a1e <vma_create>
c0107e23:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma != NULL);
c0107e26:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107e2a:	75 24                	jne    c0107e50 <check_vma_struct+0xb8>
c0107e2c:	c7 44 24 0c 0c bc 10 	movl   $0xc010bc0c,0xc(%esp)
c0107e33:	c0 
c0107e34:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107e3b:	c0 
c0107e3c:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0107e43:	00 
c0107e44:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107e4b:	e8 d6 8e ff ff       	call   c0100d26 <__panic>
        insert_vma_struct(mm, vma);
c0107e50:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107e53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e57:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e5a:	89 04 24             	mov    %eax,(%esp)
c0107e5d:	e8 53 fd ff ff       	call   c0107bb5 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
c0107e62:	ff 4d f4             	decl   -0xc(%ebp)
c0107e65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e69:	7f 8b                	jg     c0107df6 <check_vma_struct+0x5e>
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107e6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e6e:	40                   	inc    %eax
c0107e6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107e72:	eb 6f                	jmp    c0107ee3 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e77:	89 d0                	mov    %edx,%eax
c0107e79:	c1 e0 02             	shl    $0x2,%eax
c0107e7c:	01 d0                	add    %edx,%eax
c0107e7e:	83 c0 02             	add    $0x2,%eax
c0107e81:	89 c1                	mov    %eax,%ecx
c0107e83:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e86:	89 d0                	mov    %edx,%eax
c0107e88:	c1 e0 02             	shl    $0x2,%eax
c0107e8b:	01 d0                	add    %edx,%eax
c0107e8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e94:	00 
c0107e95:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0107e99:	89 04 24             	mov    %eax,(%esp)
c0107e9c:	e8 7d fb ff ff       	call   c0107a1e <vma_create>
c0107ea1:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma != NULL);
c0107ea4:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0107ea8:	75 24                	jne    c0107ece <check_vma_struct+0x136>
c0107eaa:	c7 44 24 0c 0c bc 10 	movl   $0xc010bc0c,0xc(%esp)
c0107eb1:	c0 
c0107eb2:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107eb9:	c0 
c0107eba:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0107ec1:	00 
c0107ec2:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107ec9:	e8 58 8e ff ff       	call   c0100d26 <__panic>
        insert_vma_struct(mm, vma);
c0107ece:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ed5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ed8:	89 04 24             	mov    %eax,(%esp)
c0107edb:	e8 d5 fc ff ff       	call   c0107bb5 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
c0107ee0:	ff 45 f4             	incl   -0xc(%ebp)
c0107ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ee6:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107ee9:	7e 89                	jle    c0107e74 <check_vma_struct+0xdc>
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107eeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107eee:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107ef1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107ef4:	8b 40 04             	mov    0x4(%eax),%eax
c0107ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107efa:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107f01:	e9 96 00 00 00       	jmp    c0107f9c <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0107f06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107f09:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107f0c:	75 24                	jne    c0107f32 <check_vma_struct+0x19a>
c0107f0e:	c7 44 24 0c 18 bc 10 	movl   $0xc010bc18,0xc(%esp)
c0107f15:	c0 
c0107f16:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107f1d:	c0 
c0107f1e:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0107f25:	00 
c0107f26:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107f2d:	e8 f4 8d ff ff       	call   c0100d26 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f35:	83 e8 10             	sub    $0x10,%eax
c0107f38:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0107f3b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107f3e:	8b 48 04             	mov    0x4(%eax),%ecx
c0107f41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f44:	89 d0                	mov    %edx,%eax
c0107f46:	c1 e0 02             	shl    $0x2,%eax
c0107f49:	01 d0                	add    %edx,%eax
c0107f4b:	39 c1                	cmp    %eax,%ecx
c0107f4d:	75 17                	jne    c0107f66 <check_vma_struct+0x1ce>
c0107f4f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107f52:	8b 48 08             	mov    0x8(%eax),%ecx
c0107f55:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107f58:	89 d0                	mov    %edx,%eax
c0107f5a:	c1 e0 02             	shl    $0x2,%eax
c0107f5d:	01 d0                	add    %edx,%eax
c0107f5f:	83 c0 02             	add    $0x2,%eax
c0107f62:	39 c1                	cmp    %eax,%ecx
c0107f64:	74 24                	je     c0107f8a <check_vma_struct+0x1f2>
c0107f66:	c7 44 24 0c 30 bc 10 	movl   $0xc010bc30,0xc(%esp)
c0107f6d:	c0 
c0107f6e:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107f75:	c0 
c0107f76:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0107f7d:	00 
c0107f7e:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107f85:	e8 9c 8d ff ff       	call   c0100d26 <__panic>
c0107f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f8d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0107f90:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107f93:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0107f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (i = 1; i <= step2; i ++) {
c0107f99:	ff 45 f4             	incl   -0xc(%ebp)
c0107f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f9f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107fa2:	0f 8e 5e ff ff ff    	jle    c0107f06 <check_vma_struct+0x16e>
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107fa8:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107faf:	e9 cb 01 00 00       	jmp    c010817f <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0107fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107fbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fbe:	89 04 24             	mov    %eax,(%esp)
c0107fc1:	e8 95 fa ff ff       	call   c0107a5b <find_vma>
c0107fc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma1 != NULL);
c0107fc9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107fcd:	75 24                	jne    c0107ff3 <check_vma_struct+0x25b>
c0107fcf:	c7 44 24 0c 65 bc 10 	movl   $0xc010bc65,0xc(%esp)
c0107fd6:	c0 
c0107fd7:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0107fde:	c0 
c0107fdf:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107fe6:	00 
c0107fe7:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0107fee:	e8 33 8d ff ff       	call   c0100d26 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0107ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ff6:	40                   	inc    %eax
c0107ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ffb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ffe:	89 04 24             	mov    %eax,(%esp)
c0108001:	e8 55 fa ff ff       	call   c0107a5b <find_vma>
c0108006:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(vma2 != NULL);
c0108009:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010800d:	75 24                	jne    c0108033 <check_vma_struct+0x29b>
c010800f:	c7 44 24 0c 72 bc 10 	movl   $0xc010bc72,0xc(%esp)
c0108016:	c0 
c0108017:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c010801e:	c0 
c010801f:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0108026:	00 
c0108027:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c010802e:	e8 f3 8c ff ff       	call   c0100d26 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0108033:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108036:	83 c0 02             	add    $0x2,%eax
c0108039:	89 44 24 04          	mov    %eax,0x4(%esp)
c010803d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108040:	89 04 24             	mov    %eax,(%esp)
c0108043:	e8 13 fa ff ff       	call   c0107a5b <find_vma>
c0108048:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma3 == NULL);
c010804b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010804f:	74 24                	je     c0108075 <check_vma_struct+0x2dd>
c0108051:	c7 44 24 0c 7f bc 10 	movl   $0xc010bc7f,0xc(%esp)
c0108058:	c0 
c0108059:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0108060:	c0 
c0108061:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0108068:	00 
c0108069:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0108070:	e8 b1 8c ff ff       	call   c0100d26 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0108075:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108078:	83 c0 03             	add    $0x3,%eax
c010807b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010807f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108082:	89 04 24             	mov    %eax,(%esp)
c0108085:	e8 d1 f9 ff ff       	call   c0107a5b <find_vma>
c010808a:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma4 == NULL);
c010808d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0108091:	74 24                	je     c01080b7 <check_vma_struct+0x31f>
c0108093:	c7 44 24 0c 8c bc 10 	movl   $0xc010bc8c,0xc(%esp)
c010809a:	c0 
c010809b:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c01080a2:	c0 
c01080a3:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01080aa:	00 
c01080ab:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c01080b2:	e8 6f 8c ff ff       	call   c0100d26 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01080b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080ba:	83 c0 04             	add    $0x4,%eax
c01080bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080c4:	89 04 24             	mov    %eax,(%esp)
c01080c7:	e8 8f f9 ff ff       	call   c0107a5b <find_vma>
c01080cc:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma5 == NULL);
c01080cf:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01080d3:	74 24                	je     c01080f9 <check_vma_struct+0x361>
c01080d5:	c7 44 24 0c 99 bc 10 	movl   $0xc010bc99,0xc(%esp)
c01080dc:	c0 
c01080dd:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c01080e4:	c0 
c01080e5:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01080ec:	00 
c01080ed:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c01080f4:	e8 2d 8c ff ff       	call   c0100d26 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01080f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01080fc:	8b 50 04             	mov    0x4(%eax),%edx
c01080ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108102:	39 c2                	cmp    %eax,%edx
c0108104:	75 10                	jne    c0108116 <check_vma_struct+0x37e>
c0108106:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108109:	8b 40 08             	mov    0x8(%eax),%eax
c010810c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010810f:	83 c2 02             	add    $0x2,%edx
c0108112:	39 d0                	cmp    %edx,%eax
c0108114:	74 24                	je     c010813a <check_vma_struct+0x3a2>
c0108116:	c7 44 24 0c a8 bc 10 	movl   $0xc010bca8,0xc(%esp)
c010811d:	c0 
c010811e:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0108125:	c0 
c0108126:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c010812d:	00 
c010812e:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0108135:	e8 ec 8b ff ff       	call   c0100d26 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c010813a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010813d:	8b 50 04             	mov    0x4(%eax),%edx
c0108140:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108143:	39 c2                	cmp    %eax,%edx
c0108145:	75 10                	jne    c0108157 <check_vma_struct+0x3bf>
c0108147:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010814a:	8b 40 08             	mov    0x8(%eax),%eax
c010814d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108150:	83 c2 02             	add    $0x2,%edx
c0108153:	39 d0                	cmp    %edx,%eax
c0108155:	74 24                	je     c010817b <check_vma_struct+0x3e3>
c0108157:	c7 44 24 0c d8 bc 10 	movl   $0xc010bcd8,0xc(%esp)
c010815e:	c0 
c010815f:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0108166:	c0 
c0108167:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c010816e:	00 
c010816f:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0108176:	e8 ab 8b ff ff       	call   c0100d26 <__panic>
    for (i = 5; i <= 5 * step2; i +=5) {
c010817b:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010817f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108182:	89 d0                	mov    %edx,%eax
c0108184:	c1 e0 02             	shl    $0x2,%eax
c0108187:	01 d0                	add    %edx,%eax
c0108189:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010818c:	0f 8e 22 fe ff ff    	jle    c0107fb4 <check_vma_struct+0x21c>
    }

    for (i =4; i>=0; i--) {
c0108192:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108199:	eb 6f                	jmp    c010820a <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010819b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010819e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081a5:	89 04 24             	mov    %eax,(%esp)
c01081a8:	e8 ae f8 ff ff       	call   c0107a5b <find_vma>
c01081ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (vma_below_5 != NULL ) {
c01081b0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01081b4:	74 27                	je     c01081dd <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01081b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081b9:	8b 50 08             	mov    0x8(%eax),%edx
c01081bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01081bf:	8b 40 04             	mov    0x4(%eax),%eax
c01081c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01081c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081d1:	c7 04 24 08 bd 10 c0 	movl   $0xc010bd08,(%esp)
c01081d8:	e8 9b 81 ff ff       	call   c0100378 <cprintf>
        }
        assert(vma_below_5 == NULL);
c01081dd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01081e1:	74 24                	je     c0108207 <check_vma_struct+0x46f>
c01081e3:	c7 44 24 0c 2d bd 10 	movl   $0xc010bd2d,0xc(%esp)
c01081ea:	c0 
c01081eb:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c01081f2:	c0 
c01081f3:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c01081fa:	00 
c01081fb:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0108202:	e8 1f 8b ff ff       	call   c0100d26 <__panic>
    for (i =4; i>=0; i--) {
c0108207:	ff 4d f4             	decl   -0xc(%ebp)
c010820a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010820e:	79 8b                	jns    c010819b <check_vma_struct+0x403>
    }

    mm_destroy(mm);
c0108210:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108213:	89 04 24             	mov    %eax,(%esp)
c0108216:	e8 d0 fa ff ff       	call   c0107ceb <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c010821b:	c7 04 24 44 bd 10 c0 	movl   $0xc010bd44,(%esp)
c0108222:	e8 51 81 ff ff       	call   c0100378 <cprintf>
}
c0108227:	90                   	nop
c0108228:	89 ec                	mov    %ebp,%esp
c010822a:	5d                   	pop    %ebp
c010822b:	c3                   	ret    

c010822c <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c010822c:	55                   	push   %ebp
c010822d:	89 e5                	mov    %esp,%ebp
c010822f:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108232:	e8 a6 ce ff ff       	call   c01050dd <nr_free_pages>
c0108237:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c010823a:	e8 64 f7 ff ff       	call   c01079a3 <mm_create>
c010823f:	a3 0c c1 12 c0       	mov    %eax,0xc012c10c
    assert(check_mm_struct != NULL);
c0108244:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c0108249:	85 c0                	test   %eax,%eax
c010824b:	75 24                	jne    c0108271 <check_pgfault+0x45>
c010824d:	c7 44 24 0c 63 bd 10 	movl   $0xc010bd63,0xc(%esp)
c0108254:	c0 
c0108255:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c010825c:	c0 
c010825d:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0108264:	00 
c0108265:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c010826c:	e8 b5 8a ff ff       	call   c0100d26 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108271:	a1 0c c1 12 c0       	mov    0xc012c10c,%eax
c0108276:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108279:	8b 15 00 8a 12 c0    	mov    0xc0128a00,%edx
c010827f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108282:	89 50 0c             	mov    %edx,0xc(%eax)
c0108285:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108288:	8b 40 0c             	mov    0xc(%eax),%eax
c010828b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c010828e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108291:	8b 00                	mov    (%eax),%eax
c0108293:	85 c0                	test   %eax,%eax
c0108295:	74 24                	je     c01082bb <check_pgfault+0x8f>
c0108297:	c7 44 24 0c 7b bd 10 	movl   $0xc010bd7b,0xc(%esp)
c010829e:	c0 
c010829f:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c01082a6:	c0 
c01082a7:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c01082ae:	00 
c01082af:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c01082b6:	e8 6b 8a ff ff       	call   c0100d26 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01082bb:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c01082c2:	00 
c01082c3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c01082ca:	00 
c01082cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01082d2:	e8 47 f7 ff ff       	call   c0107a1e <vma_create>
c01082d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c01082da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01082de:	75 24                	jne    c0108304 <check_pgfault+0xd8>
c01082e0:	c7 44 24 0c 0c bc 10 	movl   $0xc010bc0c,0xc(%esp)
c01082e7:	c0 
c01082e8:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c01082ef:	c0 
c01082f0:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01082f7:	00 
c01082f8:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c01082ff:	e8 22 8a ff ff       	call   c0100d26 <__panic>

    insert_vma_struct(mm, vma);
c0108304:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108307:	89 44 24 04          	mov    %eax,0x4(%esp)
c010830b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010830e:	89 04 24             	mov    %eax,(%esp)
c0108311:	e8 9f f8 ff ff       	call   c0107bb5 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108316:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010831d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108320:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108324:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108327:	89 04 24             	mov    %eax,(%esp)
c010832a:	e8 2c f7 ff ff       	call   c0107a5b <find_vma>
c010832f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0108332:	74 24                	je     c0108358 <check_pgfault+0x12c>
c0108334:	c7 44 24 0c 89 bd 10 	movl   $0xc010bd89,0xc(%esp)
c010833b:	c0 
c010833c:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c0108343:	c0 
c0108344:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c010834b:	00 
c010834c:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c0108353:	e8 ce 89 ff ff       	call   c0100d26 <__panic>

    int i, sum = 0;
c0108358:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c010835f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108366:	eb 16                	jmp    c010837e <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0108368:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010836b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010836e:	01 d0                	add    %edx,%eax
c0108370:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108373:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108375:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108378:	01 45 f0             	add    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c010837b:	ff 45 f4             	incl   -0xc(%ebp)
c010837e:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108382:	7e e4                	jle    c0108368 <check_pgfault+0x13c>
    }
    for (i = 0; i < 100; i ++) {
c0108384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010838b:	eb 14                	jmp    c01083a1 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c010838d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108390:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108393:	01 d0                	add    %edx,%eax
c0108395:	0f b6 00             	movzbl (%eax),%eax
c0108398:	0f be c0             	movsbl %al,%eax
c010839b:	29 45 f0             	sub    %eax,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c010839e:	ff 45 f4             	incl   -0xc(%ebp)
c01083a1:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01083a5:	7e e6                	jle    c010838d <check_pgfault+0x161>
    }
    assert(sum == 0);
c01083a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01083ab:	74 24                	je     c01083d1 <check_pgfault+0x1a5>
c01083ad:	c7 44 24 0c a3 bd 10 	movl   $0xc010bda3,0xc(%esp)
c01083b4:	c0 
c01083b5:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c01083bc:	c0 
c01083bd:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c01083c4:	00 
c01083c5:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c01083cc:	e8 55 89 ff ff       	call   c0100d26 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01083d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01083d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01083d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01083da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01083df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01083e6:	89 04 24             	mov    %eax,(%esp)
c01083e9:	e8 0c d5 ff ff       	call   c01058fa <page_remove>
    free_page(pde2page(pgdir[0]));
c01083ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01083f1:	8b 00                	mov    (%eax),%eax
c01083f3:	89 04 24             	mov    %eax,(%esp)
c01083f6:	e8 8e f5 ff ff       	call   c0107989 <pde2page>
c01083fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108402:	00 
c0108403:	89 04 24             	mov    %eax,(%esp)
c0108406:	e8 9d cc ff ff       	call   c01050a8 <free_pages>
    pgdir[0] = 0;
c010840b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010840e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108414:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108417:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c010841e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108421:	89 04 24             	mov    %eax,(%esp)
c0108424:	e8 c2 f8 ff ff       	call   c0107ceb <mm_destroy>
    check_mm_struct = NULL;
c0108429:	c7 05 0c c1 12 c0 00 	movl   $0x0,0xc012c10c
c0108430:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108433:	e8 a5 cc ff ff       	call   c01050dd <nr_free_pages>
c0108438:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010843b:	74 24                	je     c0108461 <check_pgfault+0x235>
c010843d:	c7 44 24 0c ac bd 10 	movl   $0xc010bdac,0xc(%esp)
c0108444:	c0 
c0108445:	c7 44 24 08 6b bb 10 	movl   $0xc010bb6b,0x8(%esp)
c010844c:	c0 
c010844d:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0108454:	00 
c0108455:	c7 04 24 80 bb 10 c0 	movl   $0xc010bb80,(%esp)
c010845c:	e8 c5 88 ff ff       	call   c0100d26 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108461:	c7 04 24 d3 bd 10 c0 	movl   $0xc010bdd3,(%esp)
c0108468:	e8 0b 7f ff ff       	call   c0100378 <cprintf>
}
c010846d:	90                   	nop
c010846e:	89 ec                	mov    %ebp,%esp
c0108470:	5d                   	pop    %ebp
c0108471:	c3                   	ret    

c0108472 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108472:	55                   	push   %ebp
c0108473:	89 e5                	mov    %esp,%ebp
c0108475:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108478:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c010847f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108482:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108486:	8b 45 08             	mov    0x8(%ebp),%eax
c0108489:	89 04 24             	mov    %eax,(%esp)
c010848c:	e8 ca f5 ff ff       	call   c0107a5b <find_vma>
c0108491:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0108494:	a1 10 c1 12 c0       	mov    0xc012c110,%eax
c0108499:	40                   	inc    %eax
c010849a:	a3 10 c1 12 c0       	mov    %eax,0xc012c110
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c010849f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01084a3:	74 0b                	je     c01084b0 <do_pgfault+0x3e>
c01084a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084a8:	8b 40 04             	mov    0x4(%eax),%eax
c01084ab:	39 45 10             	cmp    %eax,0x10(%ebp)
c01084ae:	73 18                	jae    c01084c8 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01084b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01084b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084b7:	c7 04 24 f0 bd 10 c0 	movl   $0xc010bdf0,(%esp)
c01084be:	e8 b5 7e ff ff       	call   c0100378 <cprintf>
        goto failed;
c01084c3:	e9 ba 01 00 00       	jmp    c0108682 <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c01084c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084cb:	83 e0 03             	and    $0x3,%eax
c01084ce:	85 c0                	test   %eax,%eax
c01084d0:	74 34                	je     c0108506 <do_pgfault+0x94>
c01084d2:	83 f8 01             	cmp    $0x1,%eax
c01084d5:	74 1e                	je     c01084f5 <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c01084d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084da:	8b 40 0c             	mov    0xc(%eax),%eax
c01084dd:	83 e0 02             	and    $0x2,%eax
c01084e0:	85 c0                	test   %eax,%eax
c01084e2:	75 40                	jne    c0108524 <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01084e4:	c7 04 24 20 be 10 c0 	movl   $0xc010be20,(%esp)
c01084eb:	e8 88 7e ff ff       	call   c0100378 <cprintf>
            goto failed;
c01084f0:	e9 8d 01 00 00       	jmp    c0108682 <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c01084f5:	c7 04 24 80 be 10 c0 	movl   $0xc010be80,(%esp)
c01084fc:	e8 77 7e ff ff       	call   c0100378 <cprintf>
        goto failed;
c0108501:	e9 7c 01 00 00       	jmp    c0108682 <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108506:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108509:	8b 40 0c             	mov    0xc(%eax),%eax
c010850c:	83 e0 05             	and    $0x5,%eax
c010850f:	85 c0                	test   %eax,%eax
c0108511:	75 12                	jne    c0108525 <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108513:	c7 04 24 b8 be 10 c0 	movl   $0xc010beb8,(%esp)
c010851a:	e8 59 7e ff ff       	call   c0100378 <cprintf>
            goto failed;
c010851f:	e9 5e 01 00 00       	jmp    c0108682 <do_pgfault+0x210>
        break;
c0108524:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108525:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c010852c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010852f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108532:	83 e0 02             	and    $0x2,%eax
c0108535:	85 c0                	test   %eax,%eax
c0108537:	74 04                	je     c010853d <do_pgfault+0xcb>
        perm |= PTE_W;
c0108539:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c010853d:	8b 45 10             	mov    0x10(%ebp),%eax
c0108540:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108543:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108546:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010854b:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c010854e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108555:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c010855c:	8b 45 08             	mov    0x8(%ebp),%eax
c010855f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108562:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108569:	00 
c010856a:	8b 55 10             	mov    0x10(%ebp),%edx
c010856d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108571:	89 04 24             	mov    %eax,(%esp)
c0108574:	e8 7d d1 ff ff       	call   c01056f6 <get_pte>
c0108579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010857c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108580:	75 11                	jne    c0108593 <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c0108582:	c7 04 24 1b bf 10 c0 	movl   $0xc010bf1b,(%esp)
c0108589:	e8 ea 7d ff ff       	call   c0100378 <cprintf>
        goto failed;
c010858e:	e9 ef 00 00 00       	jmp    c0108682 <do_pgfault+0x210>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0108593:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108596:	8b 00                	mov    (%eax),%eax
c0108598:	85 c0                	test   %eax,%eax
c010859a:	75 35                	jne    c01085d1 <do_pgfault+0x15f>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c010859c:	8b 45 08             	mov    0x8(%ebp),%eax
c010859f:	8b 40 0c             	mov    0xc(%eax),%eax
c01085a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01085a5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01085a9:	8b 55 10             	mov    0x10(%ebp),%edx
c01085ac:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085b0:	89 04 24             	mov    %eax,(%esp)
c01085b3:	e8 a3 d4 ff ff       	call   c0105a5b <pgdir_alloc_page>
c01085b8:	85 c0                	test   %eax,%eax
c01085ba:	0f 85 bb 00 00 00    	jne    c010867b <do_pgfault+0x209>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01085c0:	c7 04 24 3c bf 10 c0 	movl   $0xc010bf3c,(%esp)
c01085c7:	e8 ac 7d ff ff       	call   c0100378 <cprintf>
            goto failed;
c01085cc:	e9 b1 00 00 00       	jmp    c0108682 <do_pgfault+0x210>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c01085d1:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c01085d6:	85 c0                	test   %eax,%eax
c01085d8:	0f 84 86 00 00 00    	je     c0108664 <do_pgfault+0x1f2>
            struct Page *page=NULL;
c01085de:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01085e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01085e8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01085ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01085ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01085f6:	89 04 24             	mov    %eax,(%esp)
c01085f9:	e8 e8 e4 ff ff       	call   c0106ae6 <swap_in>
c01085fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108601:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108605:	74 0e                	je     c0108615 <do_pgfault+0x1a3>
                cprintf("swap_in in do_pgfault failed\n");
c0108607:	c7 04 24 63 bf 10 c0 	movl   $0xc010bf63,(%esp)
c010860e:	e8 65 7d ff ff       	call   c0100378 <cprintf>
c0108613:	eb 6d                	jmp    c0108682 <do_pgfault+0x210>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0108615:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108618:	8b 45 08             	mov    0x8(%ebp),%eax
c010861b:	8b 40 0c             	mov    0xc(%eax),%eax
c010861e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108621:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108625:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010862c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108630:	89 04 24             	mov    %eax,(%esp)
c0108633:	e8 09 d3 ff ff       	call   c0105941 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0108638:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010863b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108642:	00 
c0108643:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108647:	8b 45 10             	mov    0x10(%ebp),%eax
c010864a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010864e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108651:	89 04 24             	mov    %eax,(%esp)
c0108654:	e8 c5 e2 ff ff       	call   c010691e <swap_map_swappable>
            page->pra_vaddr = addr;
c0108659:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010865c:	8b 55 10             	mov    0x10(%ebp),%edx
c010865f:	89 50 1c             	mov    %edx,0x1c(%eax)
c0108662:	eb 17                	jmp    c010867b <do_pgfault+0x209>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0108664:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108667:	8b 00                	mov    (%eax),%eax
c0108669:	89 44 24 04          	mov    %eax,0x4(%esp)
c010866d:	c7 04 24 84 bf 10 c0 	movl   $0xc010bf84,(%esp)
c0108674:	e8 ff 7c ff ff       	call   c0100378 <cprintf>
            goto failed;
c0108679:	eb 07                	jmp    c0108682 <do_pgfault+0x210>
        }
   }
   ret = 0;
c010867b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0108682:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108685:	89 ec                	mov    %ebp,%esp
c0108687:	5d                   	pop    %ebp
c0108688:	c3                   	ret    

c0108689 <page2ppn>:
page2ppn(struct Page *page) {
c0108689:	55                   	push   %ebp
c010868a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010868c:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0108692:	8b 45 08             	mov    0x8(%ebp),%eax
c0108695:	29 d0                	sub    %edx,%eax
c0108697:	c1 f8 05             	sar    $0x5,%eax
}
c010869a:	5d                   	pop    %ebp
c010869b:	c3                   	ret    

c010869c <page2pa>:
page2pa(struct Page *page) {
c010869c:	55                   	push   %ebp
c010869d:	89 e5                	mov    %esp,%ebp
c010869f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01086a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01086a5:	89 04 24             	mov    %eax,(%esp)
c01086a8:	e8 dc ff ff ff       	call   c0108689 <page2ppn>
c01086ad:	c1 e0 0c             	shl    $0xc,%eax
}
c01086b0:	89 ec                	mov    %ebp,%esp
c01086b2:	5d                   	pop    %ebp
c01086b3:	c3                   	ret    

c01086b4 <page2kva>:
page2kva(struct Page *page) {
c01086b4:	55                   	push   %ebp
c01086b5:	89 e5                	mov    %esp,%ebp
c01086b7:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01086ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01086bd:	89 04 24             	mov    %eax,(%esp)
c01086c0:	e8 d7 ff ff ff       	call   c010869c <page2pa>
c01086c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01086c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086cb:	c1 e8 0c             	shr    $0xc,%eax
c01086ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01086d1:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01086d6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01086d9:	72 23                	jb     c01086fe <page2kva+0x4a>
c01086db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086de:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086e2:	c7 44 24 08 ac bf 10 	movl   $0xc010bfac,0x8(%esp)
c01086e9:	c0 
c01086ea:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01086f1:	00 
c01086f2:	c7 04 24 cf bf 10 c0 	movl   $0xc010bfcf,(%esp)
c01086f9:	e8 28 86 ff ff       	call   c0100d26 <__panic>
c01086fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108701:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108706:	89 ec                	mov    %ebp,%esp
c0108708:	5d                   	pop    %ebp
c0108709:	c3                   	ret    

c010870a <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010870a:	55                   	push   %ebp
c010870b:	89 e5                	mov    %esp,%ebp
c010870d:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0108710:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108717:	e8 b9 93 ff ff       	call   c0101ad5 <ide_device_valid>
c010871c:	85 c0                	test   %eax,%eax
c010871e:	75 1c                	jne    c010873c <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0108720:	c7 44 24 08 dd bf 10 	movl   $0xc010bfdd,0x8(%esp)
c0108727:	c0 
c0108728:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010872f:	00 
c0108730:	c7 04 24 f7 bf 10 c0 	movl   $0xc010bff7,(%esp)
c0108737:	e8 ea 85 ff ff       	call   c0100d26 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c010873c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108743:	e8 cd 93 ff ff       	call   c0101b15 <ide_device_size>
c0108748:	c1 e8 03             	shr    $0x3,%eax
c010874b:	a3 40 c0 12 c0       	mov    %eax,0xc012c040
}
c0108750:	90                   	nop
c0108751:	89 ec                	mov    %ebp,%esp
c0108753:	5d                   	pop    %ebp
c0108754:	c3                   	ret    

c0108755 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108755:	55                   	push   %ebp
c0108756:	89 e5                	mov    %esp,%ebp
c0108758:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010875b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010875e:	89 04 24             	mov    %eax,(%esp)
c0108761:	e8 4e ff ff ff       	call   c01086b4 <page2kva>
c0108766:	8b 55 08             	mov    0x8(%ebp),%edx
c0108769:	c1 ea 08             	shr    $0x8,%edx
c010876c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010876f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108773:	74 0b                	je     c0108780 <swapfs_read+0x2b>
c0108775:	8b 15 40 c0 12 c0    	mov    0xc012c040,%edx
c010877b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010877e:	72 23                	jb     c01087a3 <swapfs_read+0x4e>
c0108780:	8b 45 08             	mov    0x8(%ebp),%eax
c0108783:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108787:	c7 44 24 08 08 c0 10 	movl   $0xc010c008,0x8(%esp)
c010878e:	c0 
c010878f:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0108796:	00 
c0108797:	c7 04 24 f7 bf 10 c0 	movl   $0xc010bff7,(%esp)
c010879e:	e8 83 85 ff ff       	call   c0100d26 <__panic>
c01087a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01087a6:	c1 e2 03             	shl    $0x3,%edx
c01087a9:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01087b0:	00 
c01087b1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01087b5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01087b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01087c0:	e8 8d 93 ff ff       	call   c0101b52 <ide_read_secs>
}
c01087c5:	89 ec                	mov    %ebp,%esp
c01087c7:	5d                   	pop    %ebp
c01087c8:	c3                   	ret    

c01087c9 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01087c9:	55                   	push   %ebp
c01087ca:	89 e5                	mov    %esp,%ebp
c01087cc:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01087cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087d2:	89 04 24             	mov    %eax,(%esp)
c01087d5:	e8 da fe ff ff       	call   c01086b4 <page2kva>
c01087da:	8b 55 08             	mov    0x8(%ebp),%edx
c01087dd:	c1 ea 08             	shr    $0x8,%edx
c01087e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01087e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01087e7:	74 0b                	je     c01087f4 <swapfs_write+0x2b>
c01087e9:	8b 15 40 c0 12 c0    	mov    0xc012c040,%edx
c01087ef:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01087f2:	72 23                	jb     c0108817 <swapfs_write+0x4e>
c01087f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01087f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01087fb:	c7 44 24 08 08 c0 10 	movl   $0xc010c008,0x8(%esp)
c0108802:	c0 
c0108803:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010880a:	00 
c010880b:	c7 04 24 f7 bf 10 c0 	movl   $0xc010bff7,(%esp)
c0108812:	e8 0f 85 ff ff       	call   c0100d26 <__panic>
c0108817:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010881a:	c1 e2 03             	shl    $0x3,%edx
c010881d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108824:	00 
c0108825:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108829:	89 54 24 04          	mov    %edx,0x4(%esp)
c010882d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108834:	e8 5a 95 ff ff       	call   c0101d93 <ide_write_secs>
}
c0108839:	89 ec                	mov    %ebp,%esp
c010883b:	5d                   	pop    %ebp
c010883c:	c3                   	ret    

c010883d <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg 参数入栈
c010883d:	52                   	push   %edx
    call *%ebx              # call fn 调用函数
c010883e:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg) 保存函数返回值
c0108840:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread 完成一些资源回收工作等
c0108841:	e8 73 08 00 00       	call   c01090b9 <do_exit>

c0108846 <__intr_save>:
__intr_save(void) {
c0108846:	55                   	push   %ebp
c0108847:	89 e5                	mov    %esp,%ebp
c0108849:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010884c:	9c                   	pushf  
c010884d:	58                   	pop    %eax
c010884e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0108851:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0108854:	25 00 02 00 00       	and    $0x200,%eax
c0108859:	85 c0                	test   %eax,%eax
c010885b:	74 0c                	je     c0108869 <__intr_save+0x23>
        intr_disable();
c010885d:	e8 7a 97 ff ff       	call   c0101fdc <intr_disable>
        return 1;
c0108862:	b8 01 00 00 00       	mov    $0x1,%eax
c0108867:	eb 05                	jmp    c010886e <__intr_save+0x28>
    return 0;
c0108869:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010886e:	89 ec                	mov    %ebp,%esp
c0108870:	5d                   	pop    %ebp
c0108871:	c3                   	ret    

c0108872 <__intr_restore>:
__intr_restore(bool flag) {
c0108872:	55                   	push   %ebp
c0108873:	89 e5                	mov    %esp,%ebp
c0108875:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0108878:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010887c:	74 05                	je     c0108883 <__intr_restore+0x11>
        intr_enable();
c010887e:	e8 51 97 ff ff       	call   c0101fd4 <intr_enable>
}
c0108883:	90                   	nop
c0108884:	89 ec                	mov    %ebp,%esp
c0108886:	5d                   	pop    %ebp
c0108887:	c3                   	ret    

c0108888 <page2ppn>:
page2ppn(struct Page *page) {
c0108888:	55                   	push   %ebp
c0108889:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010888b:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0108891:	8b 45 08             	mov    0x8(%ebp),%eax
c0108894:	29 d0                	sub    %edx,%eax
c0108896:	c1 f8 05             	sar    $0x5,%eax
}
c0108899:	5d                   	pop    %ebp
c010889a:	c3                   	ret    

c010889b <page2pa>:
page2pa(struct Page *page) {
c010889b:	55                   	push   %ebp
c010889c:	89 e5                	mov    %esp,%ebp
c010889e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01088a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a4:	89 04 24             	mov    %eax,(%esp)
c01088a7:	e8 dc ff ff ff       	call   c0108888 <page2ppn>
c01088ac:	c1 e0 0c             	shl    $0xc,%eax
}
c01088af:	89 ec                	mov    %ebp,%esp
c01088b1:	5d                   	pop    %ebp
c01088b2:	c3                   	ret    

c01088b3 <pa2page>:
pa2page(uintptr_t pa) {
c01088b3:	55                   	push   %ebp
c01088b4:	89 e5                	mov    %esp,%ebp
c01088b6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01088b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01088bc:	c1 e8 0c             	shr    $0xc,%eax
c01088bf:	89 c2                	mov    %eax,%edx
c01088c1:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c01088c6:	39 c2                	cmp    %eax,%edx
c01088c8:	72 1c                	jb     c01088e6 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01088ca:	c7 44 24 08 28 c0 10 	movl   $0xc010c028,0x8(%esp)
c01088d1:	c0 
c01088d2:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c01088d9:	00 
c01088da:	c7 04 24 47 c0 10 c0 	movl   $0xc010c047,(%esp)
c01088e1:	e8 40 84 ff ff       	call   c0100d26 <__panic>
    return &pages[PPN(pa)];
c01088e6:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c01088ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ef:	c1 e8 0c             	shr    $0xc,%eax
c01088f2:	c1 e0 05             	shl    $0x5,%eax
c01088f5:	01 d0                	add    %edx,%eax
}
c01088f7:	89 ec                	mov    %ebp,%esp
c01088f9:	5d                   	pop    %ebp
c01088fa:	c3                   	ret    

c01088fb <page2kva>:
page2kva(struct Page *page) {
c01088fb:	55                   	push   %ebp
c01088fc:	89 e5                	mov    %esp,%ebp
c01088fe:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108901:	8b 45 08             	mov    0x8(%ebp),%eax
c0108904:	89 04 24             	mov    %eax,(%esp)
c0108907:	e8 8f ff ff ff       	call   c010889b <page2pa>
c010890c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010890f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108912:	c1 e8 0c             	shr    $0xc,%eax
c0108915:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108918:	a1 a4 bf 12 c0       	mov    0xc012bfa4,%eax
c010891d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108920:	72 23                	jb     c0108945 <page2kva+0x4a>
c0108922:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108925:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108929:	c7 44 24 08 58 c0 10 	movl   $0xc010c058,0x8(%esp)
c0108930:	c0 
c0108931:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0108938:	00 
c0108939:	c7 04 24 47 c0 10 c0 	movl   $0xc010c047,(%esp)
c0108940:	e8 e1 83 ff ff       	call   c0100d26 <__panic>
c0108945:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108948:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010894d:	89 ec                	mov    %ebp,%esp
c010894f:	5d                   	pop    %ebp
c0108950:	c3                   	ret    

c0108951 <kva2page>:
kva2page(void *kva) {
c0108951:	55                   	push   %ebp
c0108952:	89 e5                	mov    %esp,%ebp
c0108954:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0108957:	8b 45 08             	mov    0x8(%ebp),%eax
c010895a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010895d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0108964:	77 23                	ja     c0108989 <kva2page+0x38>
c0108966:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108969:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010896d:	c7 44 24 08 7c c0 10 	movl   $0xc010c07c,0x8(%esp)
c0108974:	c0 
c0108975:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010897c:	00 
c010897d:	c7 04 24 47 c0 10 c0 	movl   $0xc010c047,(%esp)
c0108984:	e8 9d 83 ff ff       	call   c0100d26 <__panic>
c0108989:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010898c:	05 00 00 00 40       	add    $0x40000000,%eax
c0108991:	89 04 24             	mov    %eax,(%esp)
c0108994:	e8 1a ff ff ff       	call   c01088b3 <pa2page>
}
c0108999:	89 ec                	mov    %ebp,%esp
c010899b:	5d                   	pop    %ebp
c010899c:	c3                   	ret    

c010899d <alloc_proc>:
void switch_to(struct context *from, struct context *to);//switch.s

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
//分配进程空间 并 初始化
static struct proc_struct *
alloc_proc(void) {
c010899d:	55                   	push   %ebp
c010899e:	89 e5                	mov    %esp,%ebp
c01089a0:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));//分配空间
c01089a3:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c01089aa:	e8 fb c1 ff ff       	call   c0104baa <kmalloc>
c01089af:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c01089b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01089b6:	0f 84 a1 00 00 00    	je     c0108a5d <alloc_proc+0xc0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c01089bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c01089c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089c8:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c01089cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c01089d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089dc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c01089e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089e6:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c01089ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089f0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c01089f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089fa:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c0108a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a04:	83 c0 1c             	add    $0x1c,%eax
c0108a07:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0108a0e:	00 
c0108a0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108a16:	00 
c0108a17:	89 04 24             	mov    %eax,(%esp)
c0108a1a:	e8 1a 15 00 00       	call   c0109f39 <memset>
        proc->tf = NULL;
c0108a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a22:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c0108a29:	8b 15 a8 bf 12 c0    	mov    0xc012bfa8,%edx
c0108a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a32:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0108a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a38:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c0108a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a42:	83 c0 48             	add    $0x48,%eax
c0108a45:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108a4c:	00 
c0108a4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108a54:	00 
c0108a55:	89 04 24             	mov    %eax,(%esp)
c0108a58:	e8 dc 14 00 00       	call   c0109f39 <memset>
    }
    return proc;
c0108a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108a60:	89 ec                	mov    %ebp,%esp
c0108a62:	5d                   	pop    %ebp
c0108a63:	c3                   	ret    

c0108a64 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0108a64:	55                   	push   %ebp
c0108a65:	89 e5                	mov    %esp,%ebp
c0108a67:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0108a6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a6d:	83 c0 48             	add    $0x48,%eax
c0108a70:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108a77:	00 
c0108a78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108a7f:	00 
c0108a80:	89 04 24             	mov    %eax,(%esp)
c0108a83:	e8 b1 14 00 00       	call   c0109f39 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0108a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a8b:	8d 50 48             	lea    0x48(%eax),%edx
c0108a8e:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108a95:	00 
c0108a96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a9d:	89 14 24             	mov    %edx,(%esp)
c0108aa0:	e8 79 15 00 00       	call   c010a01e <memcpy>
}
c0108aa5:	89 ec                	mov    %ebp,%esp
c0108aa7:	5d                   	pop    %ebp
c0108aa8:	c3                   	ret    

c0108aa9 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0108aa9:	55                   	push   %ebp
c0108aaa:	89 e5                	mov    %esp,%ebp
c0108aac:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0108aaf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108ab6:	00 
c0108ab7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108abe:	00 
c0108abf:	c7 04 24 44 e1 12 c0 	movl   $0xc012e144,(%esp)
c0108ac6:	e8 6e 14 00 00       	call   c0109f39 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0108acb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ace:	83 c0 48             	add    $0x48,%eax
c0108ad1:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108ad8:	00 
c0108ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108add:	c7 04 24 44 e1 12 c0 	movl   $0xc012e144,(%esp)
c0108ae4:	e8 35 15 00 00       	call   c010a01e <memcpy>
}
c0108ae9:	89 ec                	mov    %ebp,%esp
c0108aeb:	5d                   	pop    %ebp
c0108aec:	c3                   	ret    

c0108aed <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0108aed:	55                   	push   %ebp
c0108aee:	89 e5                	mov    %esp,%ebp
c0108af0:	83 ec 10             	sub    $0x10,%esp
    ID的总数目是大于PROCESS的总数
    无ID可分的情况
    */
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0108af3:	c7 45 f8 20 c1 12 c0 	movl   $0xc012c120,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0108afa:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108aff:	40                   	inc    %eax
c0108b00:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0108b05:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108b0a:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108b0f:	7e 0c                	jle    c0108b1d <get_pid+0x30>
        last_pid = 1;
c0108b11:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0108b18:	00 00 00 
        goto inside;
c0108b1b:	eb 14                	jmp    c0108b31 <get_pid+0x44>
    }
    if (last_pid >= next_safe) {
c0108b1d:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0108b23:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108b28:	39 c2                	cmp    %eax,%edx
c0108b2a:	0f 8c ab 00 00 00    	jl     c0108bdb <get_pid+0xee>
    inside:
c0108b30:	90                   	nop
        next_safe = MAX_PID;
c0108b31:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0108b38:	20 00 00 
    repeat:
        le = list;
c0108b3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108b3e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        //遍历所有线程，现有线程号与last_pid相等时，则将last_pid+1
        while ((le = list_next(le)) != list) 
c0108b41:	eb 7d                	jmp    c0108bc0 <get_pid+0xd3>
        {
            //通过le获取进程
            proc = le2proc(le, list_link);
c0108b43:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108b46:	83 e8 58             	sub    $0x58,%eax
c0108b49:	89 45 f4             	mov    %eax,-0xc(%ebp)
            /*
            若proc的pid=last_pid，则last_pid=last_pid+1
                若last_pid>=MAX_PID，则last_pid=1
            确保没有一个进程的pid与last_pid重合且last_pid<MAX_PID
            */
            if (proc->pid == last_pid) 
c0108b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b4f:	8b 50 04             	mov    0x4(%eax),%edx
c0108b52:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108b57:	39 c2                	cmp    %eax,%edx
c0108b59:	75 3c                	jne    c0108b97 <get_pid+0xaa>
            {
                if (++ last_pid >= next_safe) {
c0108b5b:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108b60:	40                   	inc    %eax
c0108b61:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0108b66:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0108b6c:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108b71:	39 c2                	cmp    %eax,%edx
c0108b73:	7c 4b                	jl     c0108bc0 <get_pid+0xd3>
                    if (last_pid >= MAX_PID) 
c0108b75:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108b7a:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0108b7f:	7e 0a                	jle    c0108b8b <get_pid+0x9e>
                    {
                        last_pid = 1;
c0108b81:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0108b88:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0108b8b:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0108b92:	20 00 00 
                    goto repeat;
c0108b95:	eb a4                	jmp    c0108b3b <get_pid+0x4e>
            /*
            若proc->pid > last_pid 且 next_safe > proc->pid，
            则next_safe = proc->pid  next_safe储存了 大于last_pid的最小的被占用的id
            确保没有一个进程的pid与last_pid重合且last_pid<MAX_PID
            */            
            if (proc->pid > last_pid && next_safe > proc->pid) {
c0108b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b9a:	8b 50 04             	mov    0x4(%eax),%edx
c0108b9d:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0108ba2:	39 c2                	cmp    %eax,%edx
c0108ba4:	7e 1a                	jle    c0108bc0 <get_pid+0xd3>
c0108ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ba9:	8b 50 04             	mov    0x4(%eax),%edx
c0108bac:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0108bb1:	39 c2                	cmp    %eax,%edx
c0108bb3:	7d 0b                	jge    c0108bc0 <get_pid+0xd3>
                next_safe = proc->pid;
c0108bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bb8:	8b 40 04             	mov    0x4(%eax),%eax
c0108bbb:	a3 84 8a 12 c0       	mov    %eax,0xc0128a84
c0108bc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bc9:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) 
c0108bcc:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0108bcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108bd2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0108bd5:	0f 85 68 ff ff ff    	jne    c0108b43 <get_pid+0x56>
            }
        }
    }
    return last_pid;
c0108bdb:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
}
c0108be0:	89 ec                	mov    %ebp,%esp
c0108be2:	5d                   	pop    %ebp
c0108be3:	c3                   	ret    

c0108be4 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0108be4:	55                   	push   %ebp
c0108be5:	89 e5                	mov    %esp,%ebp
c0108be7:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) //不是当前正在运行的进程
c0108bea:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108bef:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108bf2:	74 64                	je     c0108c58 <proc_run+0x74>
    {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0108bf4:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108bf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108bfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
        /*
        保护进程切换不会被中断，以免进程切换时其他进程再进行调度，相当于互斥锁
        */
        //关中断
        local_intr_save(intr_flag);
c0108c02:	e8 3f fc ff ff       	call   c0108846 <__intr_save>
c0108c07:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            //进程切换
            current = proc;
c0108c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c0d:	a3 30 c1 12 c0       	mov    %eax,0xc012c130
            load_esp0(next->kstack + KSTACKSIZE);//加载待调度进程的内核栈地址
c0108c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c15:	8b 40 0c             	mov    0xc(%eax),%eax
c0108c18:	05 00 20 00 00       	add    $0x2000,%eax
c0108c1d:	89 04 24             	mov    %eax,(%esp)
c0108c20:	e8 c4 c2 ff ff       	call   c0104ee9 <load_esp0>
            lcr3(next->cr3);//cr3寄存器改为需要运行进程的页目录表
c0108c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c28:	8b 40 40             	mov    0x40(%eax),%eax
c0108c2b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108c2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c31:	0f 22 d8             	mov    %eax,%cr3
}
c0108c34:	90                   	nop
            switch_to(&(prev->context), &(next->context));//上下文切换 switch.s
c0108c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c38:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c3e:	83 c0 1c             	add    $0x1c,%eax
c0108c41:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108c45:	89 04 24             	mov    %eax,(%esp)
c0108c48:	e8 c0 06 00 00       	call   c010930d <switch_to>
        }
        //开中断
        local_intr_restore(intr_flag);
c0108c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c50:	89 04 24             	mov    %eax,(%esp)
c0108c53:	e8 1a fc ff ff       	call   c0108872 <__intr_restore>
    }
}
c0108c58:	90                   	nop
c0108c59:	89 ec                	mov    %ebp,%esp
c0108c5b:	5d                   	pop    %ebp
c0108c5c:	c3                   	ret    

c0108c5d <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0108c5d:	55                   	push   %ebp
c0108c5e:	89 e5                	mov    %esp,%ebp
c0108c60:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0108c63:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108c68:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108c6b:	89 04 24             	mov    %eax,(%esp)
c0108c6e:	e8 be 9c ff ff       	call   c0102931 <forkrets>
}
c0108c73:	90                   	nop
c0108c74:	89 ec                	mov    %ebp,%esp
c0108c76:	5d                   	pop    %ebp
c0108c77:	c3                   	ret    

c0108c78 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0108c78:	55                   	push   %ebp
c0108c79:	89 e5                	mov    %esp,%ebp
c0108c7b:	83 ec 38             	sub    $0x38,%esp
c0108c7e:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0108c81:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c84:	8d 58 60             	lea    0x60(%eax),%ebx
c0108c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c8a:	8b 40 04             	mov    0x4(%eax),%eax
c0108c8d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108c94:	00 
c0108c95:	89 04 24             	mov    %eax,(%esp)
c0108c98:	e8 ff 07 00 00       	call   c010949c <hash32>
c0108c9d:	c1 e0 03             	shl    $0x3,%eax
c0108ca0:	05 40 c1 12 c0       	add    $0xc012c140,%eax
c0108ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ca8:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0108cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    __list_add(elm, listelm, listelm->next);
c0108cb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108cba:	8b 40 04             	mov    0x4(%eax),%eax
c0108cbd:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108cc0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108cc3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108cc6:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0108cc9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    prev->next = next->prev = elm;
c0108ccc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108ccf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108cd2:	89 10                	mov    %edx,(%eax)
c0108cd4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108cd7:	8b 10                	mov    (%eax),%edx
c0108cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108cdc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ce2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108ce5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108ceb:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108cee:	89 10                	mov    %edx,(%eax)
}
c0108cf0:	90                   	nop
}
c0108cf1:	90                   	nop
}
c0108cf2:	90                   	nop
}
c0108cf3:	90                   	nop
c0108cf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0108cf7:	89 ec                	mov    %ebp,%esp
c0108cf9:	5d                   	pop    %ebp
c0108cfa:	c3                   	ret    

c0108cfb <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
//借助哈希链表寻找进程
struct proc_struct *
find_proc(int pid) {
c0108cfb:	55                   	push   %ebp
c0108cfc:	89 e5                	mov    %esp,%ebp
c0108cfe:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0108d01:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108d05:	7e 5f                	jle    c0108d66 <find_proc+0x6b>
c0108d07:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0108d0e:	7f 56                	jg     c0108d66 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108d10:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d13:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108d1a:	00 
c0108d1b:	89 04 24             	mov    %eax,(%esp)
c0108d1e:	e8 79 07 00 00       	call   c010949c <hash32>
c0108d23:	c1 e0 03             	shl    $0x3,%eax
c0108d26:	05 40 c1 12 c0       	add    $0xc012c140,%eax
c0108d2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
        //遍历
        while ((le = list_next(le)) != list) 
c0108d34:	eb 19                	jmp    c0108d4f <find_proc+0x54>
        {
            struct proc_struct *proc = le2proc(le, hash_link);
c0108d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d39:	83 e8 60             	sub    $0x60,%eax
c0108d3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            //找到
            if (proc->pid == pid) 
c0108d3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108d42:	8b 40 04             	mov    0x4(%eax),%eax
c0108d45:	39 45 08             	cmp    %eax,0x8(%ebp)
c0108d48:	75 05                	jne    c0108d4f <find_proc+0x54>
            {
                return proc;
c0108d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108d4d:	eb 1c                	jmp    c0108d6b <find_proc+0x70>
c0108d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d52:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return listelm->next;
c0108d55:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d58:	8b 40 04             	mov    0x4(%eax),%eax
        while ((le = list_next(le)) != list) 
c0108d5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d61:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108d64:	75 d0                	jne    c0108d36 <find_proc+0x3b>
            }
        }
    }
    return NULL;
c0108d66:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108d6b:	89 ec                	mov    %ebp,%esp
c0108d6d:	5d                   	pop    %ebp
c0108d6e:	c3                   	ret    

c0108d6f <kernel_thread>:
// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) 
{
c0108d6f:	55                   	push   %ebp
c0108d70:	89 e5                	mov    %esp,%ebp
c0108d72:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    //设置trapframe
    memset(&tf, 0, sizeof(struct trapframe));
c0108d75:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108d7c:	00 
c0108d7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108d84:	00 
c0108d85:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108d88:	89 04 24             	mov    %eax,(%esp)
c0108d8b:	e8 a9 11 00 00       	call   c0109f39 <memset>
    tf.tf_cs = KERNEL_CS;
c0108d90:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108d96:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108d9c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108da0:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108da4:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108da8:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108dac:	8b 45 08             	mov    0x8(%ebp),%eax
c0108daf:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0108db2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108db5:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;////entry.s 线程要执行的
c0108db8:	b8 3d 88 10 c0       	mov    $0xc010883d,%eax
c0108dbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0108dc0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108dc3:	0d 00 01 00 00       	or     $0x100,%eax
c0108dc8:	89 c2                	mov    %eax,%edx
c0108dca:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108dcd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108dd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108dd8:	00 
c0108dd9:	89 14 24             	mov    %edx,(%esp)
c0108ddc:	e8 90 01 00 00       	call   c0108f71 <do_fork>
}
c0108de1:	89 ec                	mov    %ebp,%esp
c0108de3:	5d                   	pop    %ebp
c0108de4:	c3                   	ret    

c0108de5 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0108de5:	55                   	push   %ebp
c0108de6:	89 e5                	mov    %esp,%ebp
c0108de8:	83 ec 28             	sub    $0x28,%esp
    //给栈分配空间
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108deb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108df2:	e8 44 c2 ff ff       	call   c010503b <alloc_pages>
c0108df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL)//分配成功
c0108dfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108dfe:	74 1a                	je     c0108e1a <setup_kstack+0x35>
    {
        proc->kstack = (uintptr_t)page2kva(page);//设置内核虚拟地址
c0108e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e03:	89 04 24             	mov    %eax,(%esp)
c0108e06:	e8 f0 fa ff ff       	call   c01088fb <page2kva>
c0108e0b:	89 c2                	mov    %eax,%edx
c0108e0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e10:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108e13:	b8 00 00 00 00       	mov    $0x0,%eax
c0108e18:	eb 05                	jmp    c0108e1f <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0108e1a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0108e1f:	89 ec                	mov    %ebp,%esp
c0108e21:	5d                   	pop    %ebp
c0108e22:	c3                   	ret    

c0108e23 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0108e23:	55                   	push   %ebp
c0108e24:	89 e5                	mov    %esp,%ebp
c0108e26:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108e29:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e2c:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e2f:	89 04 24             	mov    %eax,(%esp)
c0108e32:	e8 1a fb ff ff       	call   c0108951 <kva2page>
c0108e37:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0108e3e:	00 
c0108e3f:	89 04 24             	mov    %eax,(%esp)
c0108e42:	e8 61 c2 ff ff       	call   c01050a8 <free_pages>
}
c0108e47:	90                   	nop
c0108e48:	89 ec                	mov    %ebp,%esp
c0108e4a:	5d                   	pop    %ebp
c0108e4b:	c3                   	ret    

c0108e4c <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "复制"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0108e4c:	55                   	push   %ebp
c0108e4d:	89 e5                	mov    %esp,%ebp
c0108e4f:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0108e52:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0108e57:	8b 40 18             	mov    0x18(%eax),%eax
c0108e5a:	85 c0                	test   %eax,%eax
c0108e5c:	74 24                	je     c0108e82 <copy_mm+0x36>
c0108e5e:	c7 44 24 0c a0 c0 10 	movl   $0xc010c0a0,0xc(%esp)
c0108e65:	c0 
c0108e66:	c7 44 24 08 b4 c0 10 	movl   $0xc010c0b4,0x8(%esp)
c0108e6d:	c0 
c0108e6e:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0108e75:	00 
c0108e76:	c7 04 24 c9 c0 10 c0 	movl   $0xc010c0c9,(%esp)
c0108e7d:	e8 a4 7e ff ff       	call   c0100d26 <__panic>
    /* do nothing in this project */
    //因为线程页表共享内核地址空间
    return 0;
c0108e82:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e87:	89 ec                	mov    %ebp,%esp
c0108e89:	5d                   	pop    %ebp
c0108e8a:	c3                   	ret    

c0108e8b <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) 
{
c0108e8b:	55                   	push   %ebp
c0108e8c:	89 e5                	mov    %esp,%ebp
c0108e8e:	57                   	push   %edi
c0108e8f:	56                   	push   %esi
c0108e90:	53                   	push   %ebx
    //setup the trapframe on the  process's kernel stack top
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108e91:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e94:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e97:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108e9c:	89 c2                	mov    %eax,%edx
c0108e9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea1:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108ea4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ea7:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108eaa:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ead:	b9 4c 00 00 00       	mov    $0x4c,%ecx
c0108eb2:	89 c3                	mov    %eax,%ebx
c0108eb4:	83 e3 01             	and    $0x1,%ebx
c0108eb7:	85 db                	test   %ebx,%ebx
c0108eb9:	74 0c                	je     c0108ec7 <copy_thread+0x3c>
c0108ebb:	0f b6 1a             	movzbl (%edx),%ebx
c0108ebe:	88 18                	mov    %bl,(%eax)
c0108ec0:	8d 40 01             	lea    0x1(%eax),%eax
c0108ec3:	8d 52 01             	lea    0x1(%edx),%edx
c0108ec6:	49                   	dec    %ecx
c0108ec7:	89 c3                	mov    %eax,%ebx
c0108ec9:	83 e3 02             	and    $0x2,%ebx
c0108ecc:	85 db                	test   %ebx,%ebx
c0108ece:	74 0f                	je     c0108edf <copy_thread+0x54>
c0108ed0:	0f b7 1a             	movzwl (%edx),%ebx
c0108ed3:	66 89 18             	mov    %bx,(%eax)
c0108ed6:	8d 40 02             	lea    0x2(%eax),%eax
c0108ed9:	8d 52 02             	lea    0x2(%edx),%edx
c0108edc:	83 e9 02             	sub    $0x2,%ecx
c0108edf:	89 cf                	mov    %ecx,%edi
c0108ee1:	83 e7 fc             	and    $0xfffffffc,%edi
c0108ee4:	bb 00 00 00 00       	mov    $0x0,%ebx
c0108ee9:	8b 34 1a             	mov    (%edx,%ebx,1),%esi
c0108eec:	89 34 18             	mov    %esi,(%eax,%ebx,1)
c0108eef:	83 c3 04             	add    $0x4,%ebx
c0108ef2:	39 fb                	cmp    %edi,%ebx
c0108ef4:	72 f3                	jb     c0108ee9 <copy_thread+0x5e>
c0108ef6:	01 d8                	add    %ebx,%eax
c0108ef8:	01 da                	add    %ebx,%edx
c0108efa:	bb 00 00 00 00       	mov    $0x0,%ebx
c0108eff:	89 ce                	mov    %ecx,%esi
c0108f01:	83 e6 02             	and    $0x2,%esi
c0108f04:	85 f6                	test   %esi,%esi
c0108f06:	74 0b                	je     c0108f13 <copy_thread+0x88>
c0108f08:	0f b7 34 1a          	movzwl (%edx,%ebx,1),%esi
c0108f0c:	66 89 34 18          	mov    %si,(%eax,%ebx,1)
c0108f10:	83 c3 02             	add    $0x2,%ebx
c0108f13:	83 e1 01             	and    $0x1,%ecx
c0108f16:	85 c9                	test   %ecx,%ecx
c0108f18:	74 07                	je     c0108f21 <copy_thread+0x96>
c0108f1a:	0f b6 14 1a          	movzbl (%edx,%ebx,1),%edx
c0108f1e:	88 14 18             	mov    %dl,(%eax,%ebx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0108f21:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f24:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f27:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0108f2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f31:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f34:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108f37:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0108f3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f3d:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f40:	8b 50 40             	mov    0x40(%eax),%edx
c0108f43:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f46:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f49:	81 ca 00 02 00 00    	or     $0x200,%edx
c0108f4f:	89 50 40             	mov    %edx,0x40(%eax)
    //setup the kernel entry point and stack of process
    proc->context.eip = (uintptr_t)forkret; //上下文切换要执行的 trapentry.s
c0108f52:	ba 5d 8c 10 c0       	mov    $0xc0108c5d,%edx
c0108f57:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f5a:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0108f5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f60:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108f63:	89 c2                	mov    %eax,%edx
c0108f65:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f68:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108f6b:	90                   	nop
c0108f6c:	5b                   	pop    %ebx
c0108f6d:	5e                   	pop    %esi
c0108f6e:	5f                   	pop    %edi
c0108f6f:	5d                   	pop    %ebp
c0108f70:	c3                   	ret    

c0108f71 <do_fork>:
 * @stack:       the parent's user stack pointer. 
 *               if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
//clone_flags =clone_flags | CLONE_VM 虚拟内存在线程间共享
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0108f71:	55                   	push   %ebp
c0108f72:	89 e5                	mov    %esp,%ebp
c0108f74:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c0108f77:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108f7e:	a1 40 e1 12 c0       	mov    0xc012e140,%eax
c0108f83:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0108f88:	0f 8f 02 01 00 00    	jg     c0109090 <do_fork+0x11f>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0108f8e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    if ((proc = alloc_proc()) == NULL) {
c0108f95:	e8 03 fa ff ff       	call   c010899d <alloc_proc>
c0108f9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108fa1:	0f 84 ec 00 00 00    	je     c0109093 <do_fork+0x122>
        goto fork_out;
    }
    proc->parent = current;    
c0108fa7:	8b 15 30 c1 12 c0    	mov    0xc012c130,%edx
c0108fad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fb0:	89 50 14             	mov    %edx,0x14(%eax)
    //    2. call setup_kstack to allocate a kernel stack for child process
    if (setup_kstack(proc) != 0) 
c0108fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fb6:	89 04 24             	mov    %eax,(%esp)
c0108fb9:	e8 27 fe ff ff       	call   c0108de5 <setup_kstack>
c0108fbe:	85 c0                	test   %eax,%eax
c0108fc0:	0f 85 e1 00 00 00    	jne    c01090a7 <do_fork+0x136>
    {
        goto bad_fork_cleanup_proc;
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    if (copy_mm(clone_flags, proc) != 0) 
c0108fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fd0:	89 04 24             	mov    %eax,(%esp)
c0108fd3:	e8 74 fe ff ff       	call   c0108e4c <copy_mm>
c0108fd8:	85 c0                	test   %eax,%eax
c0108fda:	0f 85 b9 00 00 00    	jne    c0109099 <do_fork+0x128>
    {
        goto bad_fork_cleanup_kstack;
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf);
c0108fe0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ff1:	89 04 24             	mov    %eax,(%esp)
c0108ff4:	e8 92 fe ff ff       	call   c0108e8b <copy_thread>
    /*
    进程进入列表的时候，可能会发生一系列的调度事件，如抢断等，
     local_intr_save(intr_flag)可以确保进程执行不被打乱。
    */
    bool intr_flag;
    local_intr_save(intr_flag);
c0108ff9:	e8 48 f8 ff ff       	call   c0108846 <__intr_save>
c0108ffe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0109001:	e8 e7 fa ff ff       	call   c0108aed <get_pid>
c0109006:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109009:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010900c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010900f:	89 04 24             	mov    %eax,(%esp)
c0109012:	e8 61 fc ff ff       	call   c0108c78 <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c0109017:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010901a:	83 c0 58             	add    $0x58,%eax
c010901d:	c7 45 e8 20 c1 12 c0 	movl   $0xc012c120,-0x18(%ebp)
c0109024:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109027:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010902a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010902d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109030:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0109033:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109036:	8b 40 04             	mov    0x4(%eax),%eax
c0109039:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010903c:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010903f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109042:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109045:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0109048:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010904b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010904e:	89 10                	mov    %edx,(%eax)
c0109050:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109053:	8b 10                	mov    (%eax),%edx
c0109055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109058:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010905b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010905e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0109061:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109064:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109067:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010906a:	89 10                	mov    %edx,(%eax)
}
c010906c:	90                   	nop
}
c010906d:	90                   	nop
}
c010906e:	90                   	nop
        nr_process ++;
c010906f:	a1 40 e1 12 c0       	mov    0xc012e140,%eax
c0109074:	40                   	inc    %eax
c0109075:	a3 40 e1 12 c0       	mov    %eax,0xc012e140
    }
    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);
c010907a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010907d:	89 04 24             	mov    %eax,(%esp)
c0109080:	e8 01 03 00 00       	call   c0109386 <wakeup_proc>
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;
c0109085:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109088:	8b 40 04             	mov    0x4(%eax),%eax
c010908b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010908e:	eb 04                	jmp    c0109094 <do_fork+0x123>
        goto fork_out;
c0109090:	90                   	nop
c0109091:	eb 01                	jmp    c0109094 <do_fork+0x123>
        goto fork_out;
c0109093:	90                   	nop

fork_out:
    return ret;
c0109094:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109097:	eb 1c                	jmp    c01090b5 <do_fork+0x144>
        goto bad_fork_cleanup_kstack;
c0109099:	90                   	nop

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010909a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010909d:	89 04 24             	mov    %eax,(%esp)
c01090a0:	e8 7e fd ff ff       	call   c0108e23 <put_kstack>
c01090a5:	eb 01                	jmp    c01090a8 <do_fork+0x137>
        goto bad_fork_cleanup_proc;
c01090a7:	90                   	nop
bad_fork_cleanup_proc:
    kfree(proc);
c01090a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090ab:	89 04 24             	mov    %eax,(%esp)
c01090ae:	e8 14 bb ff ff       	call   c0104bc7 <kfree>
    goto fork_out;
c01090b3:	eb df                	jmp    c0109094 <do_fork+0x123>
}
c01090b5:	89 ec                	mov    %ebp,%esp
c01090b7:	5d                   	pop    %ebp
c01090b8:	c3                   	ret    

c01090b9 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c01090b9:	55                   	push   %ebp
c01090ba:	89 e5                	mov    %esp,%ebp
c01090bc:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c01090bf:	c7 44 24 08 dd c0 10 	movl   $0xc010c0dd,0x8(%esp)
c01090c6:	c0 
c01090c7:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
c01090ce:	00 
c01090cf:	c7 04 24 c9 c0 10 c0 	movl   $0xc010c0c9,(%esp)
c01090d6:	e8 4b 7c ff ff       	call   c0100d26 <__panic>

c01090db <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c01090db:	55                   	push   %ebp
c01090dc:	89 e5                	mov    %esp,%ebp
c01090de:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c01090e1:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c01090e6:	89 04 24             	mov    %eax,(%esp)
c01090e9:	e8 bb f9 ff ff       	call   c0108aa9 <get_proc_name>
c01090ee:	8b 15 30 c1 12 c0    	mov    0xc012c130,%edx
c01090f4:	8b 52 04             	mov    0x4(%edx),%edx
c01090f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01090fb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01090ff:	c7 04 24 f0 c0 10 c0 	movl   $0xc010c0f0,(%esp)
c0109106:	e8 6d 72 ff ff       	call   c0100378 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c010910b:	8b 45 08             	mov    0x8(%ebp),%eax
c010910e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109112:	c7 04 24 16 c1 10 c0 	movl   $0xc010c116,(%esp)
c0109119:	e8 5a 72 ff ff       	call   c0100378 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c010911e:	c7 04 24 23 c1 10 c0 	movl   $0xc010c123,(%esp)
c0109125:	e8 4e 72 ff ff       	call   c0100378 <cprintf>
    return 0;
c010912a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010912f:	89 ec                	mov    %ebp,%esp
c0109131:	5d                   	pop    %ebp
c0109132:	c3                   	ret    

c0109133 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
//建立 第0个线程 idleproc 创建 第1个线程 initproc
void
proc_init(void) {
c0109133:	55                   	push   %ebp
c0109134:	89 e5                	mov    %esp,%ebp
c0109136:	83 ec 28             	sub    $0x28,%esp
c0109139:	c7 45 ec 20 c1 12 c0 	movl   $0xc012c120,-0x14(%ebp)
    elm->prev = elm->next = elm;
c0109140:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109143:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109146:	89 50 04             	mov    %edx,0x4(%eax)
c0109149:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010914c:	8b 50 04             	mov    0x4(%eax),%edx
c010914f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109152:	89 10                	mov    %edx,(%eax)
}
c0109154:	90                   	nop
    int i;
    //初始化proc_list hash_list
    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109155:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010915c:	eb 26                	jmp    c0109184 <proc_init+0x51>
        list_init(hash_list + i);
c010915e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109161:	c1 e0 03             	shl    $0x3,%eax
c0109164:	05 40 c1 12 c0       	add    $0xc012c140,%eax
c0109169:	89 45 e8             	mov    %eax,-0x18(%ebp)
    elm->prev = elm->next = elm;
c010916c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010916f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109172:	89 50 04             	mov    %edx,0x4(%eax)
c0109175:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109178:	8b 50 04             	mov    0x4(%eax),%edx
c010917b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010917e:	89 10                	mov    %edx,(%eax)
}
c0109180:	90                   	nop
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109181:	ff 45 f4             	incl   -0xc(%ebp)
c0109184:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010918b:	7e d1                	jle    c010915e <proc_init+0x2b>
    }
    //设置idle_proc并进一步创建init_proc
    if ((idleproc = alloc_proc()) == NULL) {
c010918d:	e8 0b f8 ff ff       	call   c010899d <alloc_proc>
c0109192:	a3 28 c1 12 c0       	mov    %eax,0xc012c128
c0109197:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c010919c:	85 c0                	test   %eax,%eax
c010919e:	75 1c                	jne    c01091bc <proc_init+0x89>
        panic("cannot alloc idleproc.\n");
c01091a0:	c7 44 24 08 3f c1 10 	movl   $0xc010c13f,0x8(%esp)
c01091a7:	c0 
c01091a8:	c7 44 24 04 ac 01 00 	movl   $0x1ac,0x4(%esp)
c01091af:	00 
c01091b0:	c7 04 24 c9 c0 10 c0 	movl   $0xc010c0c9,(%esp)
c01091b7:	e8 6a 7b ff ff       	call   c0100d26 <__panic>
    }
    //设置idleproc
    idleproc->pid = 0;
c01091bc:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01091c1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c01091c8:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01091cd:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c01091d3:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01091d8:	ba 00 60 12 c0       	mov    $0xc0126000,%edx
c01091dd:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c01091e0:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01091e5:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c01091ec:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01091f1:	c7 44 24 04 57 c1 10 	movl   $0xc010c157,0x4(%esp)
c01091f8:	c0 
c01091f9:	89 04 24             	mov    %eax,(%esp)
c01091fc:	e8 63 f8 ff ff       	call   c0108a64 <set_proc_name>

    nr_process ++;
c0109201:	a1 40 e1 12 c0       	mov    0xc012e140,%eax
c0109206:	40                   	inc    %eax
c0109207:	a3 40 e1 12 c0       	mov    %eax,0xc012e140

    //设置当前运行线程为idleproc
    current = idleproc;
c010920c:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c0109211:	a3 30 c1 12 c0       	mov    %eax,0xc012c130

    //(init_main, "Hello world!!", 0)1号线程的工作
    //设置好initproc 并 获取initproc 的 pid
    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0109216:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010921d:	00 
c010921e:	c7 44 24 04 5c c1 10 	movl   $0xc010c15c,0x4(%esp)
c0109225:	c0 
c0109226:	c7 04 24 db 90 10 c0 	movl   $0xc01090db,(%esp)
c010922d:	e8 3d fb ff ff       	call   c0108d6f <kernel_thread>
c0109232:	89 45 f0             	mov    %eax,-0x10(%ebp)
   
    if (pid <= 0) {
c0109235:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109239:	7f 1c                	jg     c0109257 <proc_init+0x124>
        panic("create init_main failed.\n");
c010923b:	c7 44 24 08 6a c1 10 	movl   $0xc010c16a,0x8(%esp)
c0109242:	c0 
c0109243:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
c010924a:	00 
c010924b:	c7 04 24 c9 c0 10 c0 	movl   $0xc010c0c9,(%esp)
c0109252:	e8 cf 7a ff ff       	call   c0100d26 <__panic>
    }

    initproc = find_proc(pid);
c0109257:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010925a:	89 04 24             	mov    %eax,(%esp)
c010925d:	e8 99 fa ff ff       	call   c0108cfb <find_proc>
c0109262:	a3 2c c1 12 c0       	mov    %eax,0xc012c12c
    set_proc_name(initproc, "init");
c0109267:	a1 2c c1 12 c0       	mov    0xc012c12c,%eax
c010926c:	c7 44 24 04 84 c1 10 	movl   $0xc010c184,0x4(%esp)
c0109273:	c0 
c0109274:	89 04 24             	mov    %eax,(%esp)
c0109277:	e8 e8 f7 ff ff       	call   c0108a64 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010927c:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c0109281:	85 c0                	test   %eax,%eax
c0109283:	74 0c                	je     c0109291 <proc_init+0x15e>
c0109285:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c010928a:	8b 40 04             	mov    0x4(%eax),%eax
c010928d:	85 c0                	test   %eax,%eax
c010928f:	74 24                	je     c01092b5 <proc_init+0x182>
c0109291:	c7 44 24 0c 8c c1 10 	movl   $0xc010c18c,0xc(%esp)
c0109298:	c0 
c0109299:	c7 44 24 08 b4 c0 10 	movl   $0xc010c0b4,0x8(%esp)
c01092a0:	c0 
c01092a1:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
c01092a8:	00 
c01092a9:	c7 04 24 c9 c0 10 c0 	movl   $0xc010c0c9,(%esp)
c01092b0:	e8 71 7a ff ff       	call   c0100d26 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c01092b5:	a1 2c c1 12 c0       	mov    0xc012c12c,%eax
c01092ba:	85 c0                	test   %eax,%eax
c01092bc:	74 0d                	je     c01092cb <proc_init+0x198>
c01092be:	a1 2c c1 12 c0       	mov    0xc012c12c,%eax
c01092c3:	8b 40 04             	mov    0x4(%eax),%eax
c01092c6:	83 f8 01             	cmp    $0x1,%eax
c01092c9:	74 24                	je     c01092ef <proc_init+0x1bc>
c01092cb:	c7 44 24 0c b4 c1 10 	movl   $0xc010c1b4,0xc(%esp)
c01092d2:	c0 
c01092d3:	c7 44 24 08 b4 c0 10 	movl   $0xc010c0b4,0x8(%esp)
c01092da:	c0 
c01092db:	c7 44 24 04 c6 01 00 	movl   $0x1c6,0x4(%esp)
c01092e2:	00 
c01092e3:	c7 04 24 c9 c0 10 c0 	movl   $0xc010c0c9,(%esp)
c01092ea:	e8 37 7a ff ff       	call   c0100d26 <__panic>
}
c01092ef:	90                   	nop
c01092f0:	89 ec                	mov    %ebp,%esp
c01092f2:	5d                   	pop    %ebp
c01092f3:	c3                   	ret    

c01092f4 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c01092f4:	55                   	push   %ebp
c01092f5:	89 e5                	mov    %esp,%ebp
c01092f7:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        //current 为 idleproc 是 需要调度的
        if (current->need_resched) {
c01092fa:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c01092ff:	8b 40 10             	mov    0x10(%eax),%eax
c0109302:	85 c0                	test   %eax,%eax
c0109304:	74 f4                	je     c01092fa <cpu_idle+0x6>
            schedule();
c0109306:	e8 c7 00 00 00       	call   c01093d2 <schedule>
        if (current->need_resched) {
c010930b:	eb ed                	jmp    c01092fa <cpu_idle+0x6>

c010930d <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from  ： esp向上四个字节->参数from（idle_proc的context地址）
c010930d:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl  ： 把当前idle_proc的eip保存到swap_context
c0109311:	8f 00                	pop    (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c0109313:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c0109316:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c0109319:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c010931c:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c010931f:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c0109322:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c0109325:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already  ： esp再向上四个字节->参数to（init_proc的contex地址）
c0109328:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c010932c:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c010932f:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c0109332:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c0109335:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c0109338:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c010933b:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c010933e:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip  ： eip（forkret）压栈    copy_thread() : proc->context.eip = (uintptr_t)forkret; 
c0109341:	ff 30                	push   (%eax)

    ret                         # 切换到init_proc最开始的地方 forkret() trapentry.s
c0109343:	c3                   	ret    

c0109344 <__intr_save>:
__intr_save(void) {
c0109344:	55                   	push   %ebp
c0109345:	89 e5                	mov    %esp,%ebp
c0109347:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010934a:	9c                   	pushf  
c010934b:	58                   	pop    %eax
c010934c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010934f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109352:	25 00 02 00 00       	and    $0x200,%eax
c0109357:	85 c0                	test   %eax,%eax
c0109359:	74 0c                	je     c0109367 <__intr_save+0x23>
        intr_disable();
c010935b:	e8 7c 8c ff ff       	call   c0101fdc <intr_disable>
        return 1;
c0109360:	b8 01 00 00 00       	mov    $0x1,%eax
c0109365:	eb 05                	jmp    c010936c <__intr_save+0x28>
    return 0;
c0109367:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010936c:	89 ec                	mov    %ebp,%esp
c010936e:	5d                   	pop    %ebp
c010936f:	c3                   	ret    

c0109370 <__intr_restore>:
__intr_restore(bool flag) {
c0109370:	55                   	push   %ebp
c0109371:	89 e5                	mov    %esp,%ebp
c0109373:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109376:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010937a:	74 05                	je     c0109381 <__intr_restore+0x11>
        intr_enable();
c010937c:	e8 53 8c ff ff       	call   c0101fd4 <intr_enable>
}
c0109381:	90                   	nop
c0109382:	89 ec                	mov    %ebp,%esp
c0109384:	5d                   	pop    %ebp
c0109385:	c3                   	ret    

c0109386 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0109386:	55                   	push   %ebp
c0109387:	89 e5                	mov    %esp,%ebp
c0109389:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c010938c:	8b 45 08             	mov    0x8(%ebp),%eax
c010938f:	8b 00                	mov    (%eax),%eax
c0109391:	83 f8 03             	cmp    $0x3,%eax
c0109394:	74 0a                	je     c01093a0 <wakeup_proc+0x1a>
c0109396:	8b 45 08             	mov    0x8(%ebp),%eax
c0109399:	8b 00                	mov    (%eax),%eax
c010939b:	83 f8 02             	cmp    $0x2,%eax
c010939e:	75 24                	jne    c01093c4 <wakeup_proc+0x3e>
c01093a0:	c7 44 24 0c dc c1 10 	movl   $0xc010c1dc,0xc(%esp)
c01093a7:	c0 
c01093a8:	c7 44 24 08 17 c2 10 	movl   $0xc010c217,0x8(%esp)
c01093af:	c0 
c01093b0:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c01093b7:	00 
c01093b8:	c7 04 24 2c c2 10 c0 	movl   $0xc010c22c,(%esp)
c01093bf:	e8 62 79 ff ff       	call   c0100d26 <__panic>
    //设置为可运行
    proc->state = PROC_RUNNABLE;
c01093c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01093c7:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c01093cd:	90                   	nop
c01093ce:	89 ec                	mov    %ebp,%esp
c01093d0:	5d                   	pop    %ebp
c01093d1:	c3                   	ret    

c01093d2 <schedule>:

void
schedule(void) {
c01093d2:	55                   	push   %ebp
c01093d3:	89 e5                	mov    %esp,%ebp
c01093d5:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c01093d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    //关中断
    local_intr_save(intr_flag);
c01093df:	e8 60 ff ff ff       	call   c0109344 <__intr_save>
c01093e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        //当前线程设为不须调度
        current->need_resched = 0;
c01093e7:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c01093ec:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        //last是否为idle进行（0号进程）,如果是，则从表头开始搜索  否则获取下一链表
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c01093f3:	8b 15 30 c1 12 c0    	mov    0xc012c130,%edx
c01093f9:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c01093fe:	39 c2                	cmp    %eax,%edx
c0109400:	74 0a                	je     c010940c <schedule+0x3a>
c0109402:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c0109407:	83 c0 58             	add    $0x58,%eax
c010940a:	eb 05                	jmp    c0109411 <schedule+0x3f>
c010940c:	b8 20 c1 12 c0       	mov    $0xc012c120,%eax
c0109411:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c0109414:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109417:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010941a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010941d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0109420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109423:	8b 40 04             	mov    0x4(%eax),%eax
        //遍历链表
        do {
            if ((le = list_next(le)) != &proc_list) 
c0109426:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109429:	81 7d f4 20 c1 12 c0 	cmpl   $0xc012c120,-0xc(%ebp)
c0109430:	74 13                	je     c0109445 <schedule+0x73>
            {
                //找到下一个可调度的进程
                next = le2proc(le, list_link);
c0109432:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109435:	83 e8 58             	sub    $0x58,%eax
c0109438:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010943b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010943e:	8b 00                	mov    (%eax),%eax
c0109440:	83 f8 02             	cmp    $0x2,%eax
c0109443:	74 0a                	je     c010944f <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c0109445:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109448:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010944b:	75 cd                	jne    c010941a <schedule+0x48>
c010944d:	eb 01                	jmp    c0109450 <schedule+0x7e>
                    break;
c010944f:	90                   	nop
        //没找到的话 运行idle进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109450:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109454:	74 0a                	je     c0109460 <schedule+0x8e>
c0109456:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109459:	8b 00                	mov    (%eax),%eax
c010945b:	83 f8 02             	cmp    $0x2,%eax
c010945e:	74 08                	je     c0109468 <schedule+0x96>
            next = idleproc;
c0109460:	a1 28 c1 12 c0       	mov    0xc012c128,%eax
c0109465:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        //运行次数+1
        next->runs ++;
c0109468:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010946b:	8b 40 08             	mov    0x8(%eax),%eax
c010946e:	8d 50 01             	lea    0x1(%eax),%edx
c0109471:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109474:	89 50 08             	mov    %edx,0x8(%eax)
        //如果是当前运行的进程，不需要切换
        if (next != current) 
c0109477:	a1 30 c1 12 c0       	mov    0xc012c130,%eax
c010947c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010947f:	74 0b                	je     c010948c <schedule+0xba>
        {
            proc_run(next);
c0109481:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109484:	89 04 24             	mov    %eax,(%esp)
c0109487:	e8 58 f7 ff ff       	call   c0108be4 <proc_run>
        }
    }
    //开中断
    local_intr_restore(intr_flag);
c010948c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010948f:	89 04 24             	mov    %eax,(%esp)
c0109492:	e8 d9 fe ff ff       	call   c0109370 <__intr_restore>
}
c0109497:	90                   	nop
c0109498:	89 ec                	mov    %ebp,%esp
c010949a:	5d                   	pop    %ebp
c010949b:	c3                   	ret    

c010949c <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010949c:	55                   	push   %ebp
c010949d:	89 e5                	mov    %esp,%ebp
c010949f:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c01094a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01094a5:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c01094ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c01094ae:	b8 20 00 00 00       	mov    $0x20,%eax
c01094b3:	2b 45 0c             	sub    0xc(%ebp),%eax
c01094b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01094b9:	88 c1                	mov    %al,%cl
c01094bb:	d3 ea                	shr    %cl,%edx
c01094bd:	89 d0                	mov    %edx,%eax
}
c01094bf:	89 ec                	mov    %ebp,%esp
c01094c1:	5d                   	pop    %ebp
c01094c2:	c3                   	ret    

c01094c3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01094c3:	55                   	push   %ebp
c01094c4:	89 e5                	mov    %esp,%ebp
c01094c6:	83 ec 58             	sub    $0x58,%esp
c01094c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01094cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01094cf:	8b 45 14             	mov    0x14(%ebp),%eax
c01094d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01094d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01094d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01094db:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01094de:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01094e1:	8b 45 18             	mov    0x18(%ebp),%eax
c01094e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01094e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01094ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01094ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01094f0:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01094f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01094f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094f9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01094fd:	74 1c                	je     c010951b <printnum+0x58>
c01094ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109502:	ba 00 00 00 00       	mov    $0x0,%edx
c0109507:	f7 75 e4             	divl   -0x1c(%ebp)
c010950a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010950d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109510:	ba 00 00 00 00       	mov    $0x0,%edx
c0109515:	f7 75 e4             	divl   -0x1c(%ebp)
c0109518:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010951b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010951e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109521:	f7 75 e4             	divl   -0x1c(%ebp)
c0109524:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109527:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010952a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010952d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109530:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109533:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109536:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109539:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010953c:	8b 45 18             	mov    0x18(%ebp),%eax
c010953f:	ba 00 00 00 00       	mov    $0x0,%edx
c0109544:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0109547:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010954a:	19 d1                	sbb    %edx,%ecx
c010954c:	72 4c                	jb     c010959a <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c010954e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0109551:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109554:	8b 45 20             	mov    0x20(%ebp),%eax
c0109557:	89 44 24 18          	mov    %eax,0x18(%esp)
c010955b:	89 54 24 14          	mov    %edx,0x14(%esp)
c010955f:	8b 45 18             	mov    0x18(%ebp),%eax
c0109562:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109566:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109569:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010956c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109570:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109577:	89 44 24 04          	mov    %eax,0x4(%esp)
c010957b:	8b 45 08             	mov    0x8(%ebp),%eax
c010957e:	89 04 24             	mov    %eax,(%esp)
c0109581:	e8 3d ff ff ff       	call   c01094c3 <printnum>
c0109586:	eb 1b                	jmp    c01095a3 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0109588:	8b 45 0c             	mov    0xc(%ebp),%eax
c010958b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010958f:	8b 45 20             	mov    0x20(%ebp),%eax
c0109592:	89 04 24             	mov    %eax,(%esp)
c0109595:	8b 45 08             	mov    0x8(%ebp),%eax
c0109598:	ff d0                	call   *%eax
        while (-- width > 0)
c010959a:	ff 4d 1c             	decl   0x1c(%ebp)
c010959d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01095a1:	7f e5                	jg     c0109588 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01095a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01095a6:	05 c4 c2 10 c0       	add    $0xc010c2c4,%eax
c01095ab:	0f b6 00             	movzbl (%eax),%eax
c01095ae:	0f be c0             	movsbl %al,%eax
c01095b1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01095b4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01095b8:	89 04 24             	mov    %eax,(%esp)
c01095bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01095be:	ff d0                	call   *%eax
}
c01095c0:	90                   	nop
c01095c1:	89 ec                	mov    %ebp,%esp
c01095c3:	5d                   	pop    %ebp
c01095c4:	c3                   	ret    

c01095c5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01095c5:	55                   	push   %ebp
c01095c6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01095c8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01095cc:	7e 14                	jle    c01095e2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01095ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01095d1:	8b 00                	mov    (%eax),%eax
c01095d3:	8d 48 08             	lea    0x8(%eax),%ecx
c01095d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01095d9:	89 0a                	mov    %ecx,(%edx)
c01095db:	8b 50 04             	mov    0x4(%eax),%edx
c01095de:	8b 00                	mov    (%eax),%eax
c01095e0:	eb 30                	jmp    c0109612 <getuint+0x4d>
    }
    else if (lflag) {
c01095e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01095e6:	74 16                	je     c01095fe <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01095e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01095eb:	8b 00                	mov    (%eax),%eax
c01095ed:	8d 48 04             	lea    0x4(%eax),%ecx
c01095f0:	8b 55 08             	mov    0x8(%ebp),%edx
c01095f3:	89 0a                	mov    %ecx,(%edx)
c01095f5:	8b 00                	mov    (%eax),%eax
c01095f7:	ba 00 00 00 00       	mov    $0x0,%edx
c01095fc:	eb 14                	jmp    c0109612 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c01095fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109601:	8b 00                	mov    (%eax),%eax
c0109603:	8d 48 04             	lea    0x4(%eax),%ecx
c0109606:	8b 55 08             	mov    0x8(%ebp),%edx
c0109609:	89 0a                	mov    %ecx,(%edx)
c010960b:	8b 00                	mov    (%eax),%eax
c010960d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0109612:	5d                   	pop    %ebp
c0109613:	c3                   	ret    

c0109614 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0109614:	55                   	push   %ebp
c0109615:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109617:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010961b:	7e 14                	jle    c0109631 <getint+0x1d>
        return va_arg(*ap, long long);
c010961d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109620:	8b 00                	mov    (%eax),%eax
c0109622:	8d 48 08             	lea    0x8(%eax),%ecx
c0109625:	8b 55 08             	mov    0x8(%ebp),%edx
c0109628:	89 0a                	mov    %ecx,(%edx)
c010962a:	8b 50 04             	mov    0x4(%eax),%edx
c010962d:	8b 00                	mov    (%eax),%eax
c010962f:	eb 28                	jmp    c0109659 <getint+0x45>
    }
    else if (lflag) {
c0109631:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109635:	74 12                	je     c0109649 <getint+0x35>
        return va_arg(*ap, long);
c0109637:	8b 45 08             	mov    0x8(%ebp),%eax
c010963a:	8b 00                	mov    (%eax),%eax
c010963c:	8d 48 04             	lea    0x4(%eax),%ecx
c010963f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109642:	89 0a                	mov    %ecx,(%edx)
c0109644:	8b 00                	mov    (%eax),%eax
c0109646:	99                   	cltd   
c0109647:	eb 10                	jmp    c0109659 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0109649:	8b 45 08             	mov    0x8(%ebp),%eax
c010964c:	8b 00                	mov    (%eax),%eax
c010964e:	8d 48 04             	lea    0x4(%eax),%ecx
c0109651:	8b 55 08             	mov    0x8(%ebp),%edx
c0109654:	89 0a                	mov    %ecx,(%edx)
c0109656:	8b 00                	mov    (%eax),%eax
c0109658:	99                   	cltd   
    }
}
c0109659:	5d                   	pop    %ebp
c010965a:	c3                   	ret    

c010965b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010965b:	55                   	push   %ebp
c010965c:	89 e5                	mov    %esp,%ebp
c010965e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0109661:	8d 45 14             	lea    0x14(%ebp),%eax
c0109664:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0109667:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010966a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010966e:	8b 45 10             	mov    0x10(%ebp),%eax
c0109671:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109675:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109678:	89 44 24 04          	mov    %eax,0x4(%esp)
c010967c:	8b 45 08             	mov    0x8(%ebp),%eax
c010967f:	89 04 24             	mov    %eax,(%esp)
c0109682:	e8 05 00 00 00       	call   c010968c <vprintfmt>
    va_end(ap);
}
c0109687:	90                   	nop
c0109688:	89 ec                	mov    %ebp,%esp
c010968a:	5d                   	pop    %ebp
c010968b:	c3                   	ret    

c010968c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010968c:	55                   	push   %ebp
c010968d:	89 e5                	mov    %esp,%ebp
c010968f:	56                   	push   %esi
c0109690:	53                   	push   %ebx
c0109691:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109694:	eb 17                	jmp    c01096ad <vprintfmt+0x21>
            if (ch == '\0') {
c0109696:	85 db                	test   %ebx,%ebx
c0109698:	0f 84 bf 03 00 00    	je     c0109a5d <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010969e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096a5:	89 1c 24             	mov    %ebx,(%esp)
c01096a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01096ab:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01096ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01096b0:	8d 50 01             	lea    0x1(%eax),%edx
c01096b3:	89 55 10             	mov    %edx,0x10(%ebp)
c01096b6:	0f b6 00             	movzbl (%eax),%eax
c01096b9:	0f b6 d8             	movzbl %al,%ebx
c01096bc:	83 fb 25             	cmp    $0x25,%ebx
c01096bf:	75 d5                	jne    c0109696 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01096c1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01096c5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01096cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01096d2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01096d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01096dc:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01096df:	8b 45 10             	mov    0x10(%ebp),%eax
c01096e2:	8d 50 01             	lea    0x1(%eax),%edx
c01096e5:	89 55 10             	mov    %edx,0x10(%ebp)
c01096e8:	0f b6 00             	movzbl (%eax),%eax
c01096eb:	0f b6 d8             	movzbl %al,%ebx
c01096ee:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01096f1:	83 f8 55             	cmp    $0x55,%eax
c01096f4:	0f 87 37 03 00 00    	ja     c0109a31 <vprintfmt+0x3a5>
c01096fa:	8b 04 85 e8 c2 10 c0 	mov    -0x3fef3d18(,%eax,4),%eax
c0109701:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0109703:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0109707:	eb d6                	jmp    c01096df <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0109709:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010970d:	eb d0                	jmp    c01096df <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010970f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0109716:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109719:	89 d0                	mov    %edx,%eax
c010971b:	c1 e0 02             	shl    $0x2,%eax
c010971e:	01 d0                	add    %edx,%eax
c0109720:	01 c0                	add    %eax,%eax
c0109722:	01 d8                	add    %ebx,%eax
c0109724:	83 e8 30             	sub    $0x30,%eax
c0109727:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010972a:	8b 45 10             	mov    0x10(%ebp),%eax
c010972d:	0f b6 00             	movzbl (%eax),%eax
c0109730:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0109733:	83 fb 2f             	cmp    $0x2f,%ebx
c0109736:	7e 38                	jle    c0109770 <vprintfmt+0xe4>
c0109738:	83 fb 39             	cmp    $0x39,%ebx
c010973b:	7f 33                	jg     c0109770 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010973d:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0109740:	eb d4                	jmp    c0109716 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0109742:	8b 45 14             	mov    0x14(%ebp),%eax
c0109745:	8d 50 04             	lea    0x4(%eax),%edx
c0109748:	89 55 14             	mov    %edx,0x14(%ebp)
c010974b:	8b 00                	mov    (%eax),%eax
c010974d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0109750:	eb 1f                	jmp    c0109771 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0109752:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109756:	79 87                	jns    c01096df <vprintfmt+0x53>
                width = 0;
c0109758:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010975f:	e9 7b ff ff ff       	jmp    c01096df <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0109764:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010976b:	e9 6f ff ff ff       	jmp    c01096df <vprintfmt+0x53>
            goto process_precision;
c0109770:	90                   	nop

        process_precision:
            if (width < 0)
c0109771:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109775:	0f 89 64 ff ff ff    	jns    c01096df <vprintfmt+0x53>
                width = precision, precision = -1;
c010977b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010977e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109781:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0109788:	e9 52 ff ff ff       	jmp    c01096df <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010978d:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0109790:	e9 4a ff ff ff       	jmp    c01096df <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0109795:	8b 45 14             	mov    0x14(%ebp),%eax
c0109798:	8d 50 04             	lea    0x4(%eax),%edx
c010979b:	89 55 14             	mov    %edx,0x14(%ebp)
c010979e:	8b 00                	mov    (%eax),%eax
c01097a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01097a3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01097a7:	89 04 24             	mov    %eax,(%esp)
c01097aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ad:	ff d0                	call   *%eax
            break;
c01097af:	e9 a4 02 00 00       	jmp    c0109a58 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01097b4:	8b 45 14             	mov    0x14(%ebp),%eax
c01097b7:	8d 50 04             	lea    0x4(%eax),%edx
c01097ba:	89 55 14             	mov    %edx,0x14(%ebp)
c01097bd:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01097bf:	85 db                	test   %ebx,%ebx
c01097c1:	79 02                	jns    c01097c5 <vprintfmt+0x139>
                err = -err;
c01097c3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01097c5:	83 fb 06             	cmp    $0x6,%ebx
c01097c8:	7f 0b                	jg     c01097d5 <vprintfmt+0x149>
c01097ca:	8b 34 9d a8 c2 10 c0 	mov    -0x3fef3d58(,%ebx,4),%esi
c01097d1:	85 f6                	test   %esi,%esi
c01097d3:	75 23                	jne    c01097f8 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01097d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01097d9:	c7 44 24 08 d5 c2 10 	movl   $0xc010c2d5,0x8(%esp)
c01097e0:	c0 
c01097e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01097eb:	89 04 24             	mov    %eax,(%esp)
c01097ee:	e8 68 fe ff ff       	call   c010965b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c01097f3:	e9 60 02 00 00       	jmp    c0109a58 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c01097f8:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01097fc:	c7 44 24 08 de c2 10 	movl   $0xc010c2de,0x8(%esp)
c0109803:	c0 
c0109804:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109807:	89 44 24 04          	mov    %eax,0x4(%esp)
c010980b:	8b 45 08             	mov    0x8(%ebp),%eax
c010980e:	89 04 24             	mov    %eax,(%esp)
c0109811:	e8 45 fe ff ff       	call   c010965b <printfmt>
            break;
c0109816:	e9 3d 02 00 00       	jmp    c0109a58 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010981b:	8b 45 14             	mov    0x14(%ebp),%eax
c010981e:	8d 50 04             	lea    0x4(%eax),%edx
c0109821:	89 55 14             	mov    %edx,0x14(%ebp)
c0109824:	8b 30                	mov    (%eax),%esi
c0109826:	85 f6                	test   %esi,%esi
c0109828:	75 05                	jne    c010982f <vprintfmt+0x1a3>
                p = "(null)";
c010982a:	be e1 c2 10 c0       	mov    $0xc010c2e1,%esi
            }
            if (width > 0 && padc != '-') {
c010982f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109833:	7e 76                	jle    c01098ab <vprintfmt+0x21f>
c0109835:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0109839:	74 70                	je     c01098ab <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010983b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010983e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109842:	89 34 24             	mov    %esi,(%esp)
c0109845:	e8 ee 03 00 00       	call   c0109c38 <strnlen>
c010984a:	89 c2                	mov    %eax,%edx
c010984c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010984f:	29 d0                	sub    %edx,%eax
c0109851:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109854:	eb 16                	jmp    c010986c <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0109856:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010985a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010985d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109861:	89 04 24             	mov    %eax,(%esp)
c0109864:	8b 45 08             	mov    0x8(%ebp),%eax
c0109867:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0109869:	ff 4d e8             	decl   -0x18(%ebp)
c010986c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109870:	7f e4                	jg     c0109856 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109872:	eb 37                	jmp    c01098ab <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0109874:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109878:	74 1f                	je     c0109899 <vprintfmt+0x20d>
c010987a:	83 fb 1f             	cmp    $0x1f,%ebx
c010987d:	7e 05                	jle    c0109884 <vprintfmt+0x1f8>
c010987f:	83 fb 7e             	cmp    $0x7e,%ebx
c0109882:	7e 15                	jle    c0109899 <vprintfmt+0x20d>
                    putch('?', putdat);
c0109884:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109887:	89 44 24 04          	mov    %eax,0x4(%esp)
c010988b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0109892:	8b 45 08             	mov    0x8(%ebp),%eax
c0109895:	ff d0                	call   *%eax
c0109897:	eb 0f                	jmp    c01098a8 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0109899:	8b 45 0c             	mov    0xc(%ebp),%eax
c010989c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098a0:	89 1c 24             	mov    %ebx,(%esp)
c01098a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01098a6:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01098a8:	ff 4d e8             	decl   -0x18(%ebp)
c01098ab:	89 f0                	mov    %esi,%eax
c01098ad:	8d 70 01             	lea    0x1(%eax),%esi
c01098b0:	0f b6 00             	movzbl (%eax),%eax
c01098b3:	0f be d8             	movsbl %al,%ebx
c01098b6:	85 db                	test   %ebx,%ebx
c01098b8:	74 27                	je     c01098e1 <vprintfmt+0x255>
c01098ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01098be:	78 b4                	js     c0109874 <vprintfmt+0x1e8>
c01098c0:	ff 4d e4             	decl   -0x1c(%ebp)
c01098c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01098c7:	79 ab                	jns    c0109874 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c01098c9:	eb 16                	jmp    c01098e1 <vprintfmt+0x255>
                putch(' ', putdat);
c01098cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01098ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098d2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01098d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01098dc:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c01098de:	ff 4d e8             	decl   -0x18(%ebp)
c01098e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01098e5:	7f e4                	jg     c01098cb <vprintfmt+0x23f>
            }
            break;
c01098e7:	e9 6c 01 00 00       	jmp    c0109a58 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c01098ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01098ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01098f3:	8d 45 14             	lea    0x14(%ebp),%eax
c01098f6:	89 04 24             	mov    %eax,(%esp)
c01098f9:	e8 16 fd ff ff       	call   c0109614 <getint>
c01098fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109901:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0109904:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109907:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010990a:	85 d2                	test   %edx,%edx
c010990c:	79 26                	jns    c0109934 <vprintfmt+0x2a8>
                putch('-', putdat);
c010990e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109911:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109915:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010991c:	8b 45 08             	mov    0x8(%ebp),%eax
c010991f:	ff d0                	call   *%eax
                num = -(long long)num;
c0109921:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109924:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109927:	f7 d8                	neg    %eax
c0109929:	83 d2 00             	adc    $0x0,%edx
c010992c:	f7 da                	neg    %edx
c010992e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109931:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0109934:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010993b:	e9 a8 00 00 00       	jmp    c01099e8 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0109940:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109943:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109947:	8d 45 14             	lea    0x14(%ebp),%eax
c010994a:	89 04 24             	mov    %eax,(%esp)
c010994d:	e8 73 fc ff ff       	call   c01095c5 <getuint>
c0109952:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109955:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0109958:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010995f:	e9 84 00 00 00       	jmp    c01099e8 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109964:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109967:	89 44 24 04          	mov    %eax,0x4(%esp)
c010996b:	8d 45 14             	lea    0x14(%ebp),%eax
c010996e:	89 04 24             	mov    %eax,(%esp)
c0109971:	e8 4f fc ff ff       	call   c01095c5 <getuint>
c0109976:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109979:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010997c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0109983:	eb 63                	jmp    c01099e8 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0109985:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109988:	89 44 24 04          	mov    %eax,0x4(%esp)
c010998c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0109993:	8b 45 08             	mov    0x8(%ebp),%eax
c0109996:	ff d0                	call   *%eax
            putch('x', putdat);
c0109998:	8b 45 0c             	mov    0xc(%ebp),%eax
c010999b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010999f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01099a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01099a9:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01099ab:	8b 45 14             	mov    0x14(%ebp),%eax
c01099ae:	8d 50 04             	lea    0x4(%eax),%edx
c01099b1:	89 55 14             	mov    %edx,0x14(%ebp)
c01099b4:	8b 00                	mov    (%eax),%eax
c01099b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01099b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01099c0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01099c7:	eb 1f                	jmp    c01099e8 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01099c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01099cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099d0:	8d 45 14             	lea    0x14(%ebp),%eax
c01099d3:	89 04 24             	mov    %eax,(%esp)
c01099d6:	e8 ea fb ff ff       	call   c01095c5 <getuint>
c01099db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01099de:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01099e1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01099e8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01099ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099ef:	89 54 24 18          	mov    %edx,0x18(%esp)
c01099f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01099f6:	89 54 24 14          	mov    %edx,0x14(%esp)
c01099fa:	89 44 24 10          	mov    %eax,0x10(%esp)
c01099fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a04:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109a08:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a13:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a16:	89 04 24             	mov    %eax,(%esp)
c0109a19:	e8 a5 fa ff ff       	call   c01094c3 <printnum>
            break;
c0109a1e:	eb 38                	jmp    c0109a58 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0109a20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a27:	89 1c 24             	mov    %ebx,(%esp)
c0109a2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a2d:	ff d0                	call   *%eax
            break;
c0109a2f:	eb 27                	jmp    c0109a58 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0109a31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a38:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109a3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a42:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109a44:	ff 4d 10             	decl   0x10(%ebp)
c0109a47:	eb 03                	jmp    c0109a4c <vprintfmt+0x3c0>
c0109a49:	ff 4d 10             	decl   0x10(%ebp)
c0109a4c:	8b 45 10             	mov    0x10(%ebp),%eax
c0109a4f:	48                   	dec    %eax
c0109a50:	0f b6 00             	movzbl (%eax),%eax
c0109a53:	3c 25                	cmp    $0x25,%al
c0109a55:	75 f2                	jne    c0109a49 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0109a57:	90                   	nop
    while (1) {
c0109a58:	e9 37 fc ff ff       	jmp    c0109694 <vprintfmt+0x8>
                return;
c0109a5d:	90                   	nop
        }
    }
}
c0109a5e:	83 c4 40             	add    $0x40,%esp
c0109a61:	5b                   	pop    %ebx
c0109a62:	5e                   	pop    %esi
c0109a63:	5d                   	pop    %ebp
c0109a64:	c3                   	ret    

c0109a65 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109a65:	55                   	push   %ebp
c0109a66:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109a68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a6b:	8b 40 08             	mov    0x8(%eax),%eax
c0109a6e:	8d 50 01             	lea    0x1(%eax),%edx
c0109a71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a74:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109a77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a7a:	8b 10                	mov    (%eax),%edx
c0109a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a7f:	8b 40 04             	mov    0x4(%eax),%eax
c0109a82:	39 c2                	cmp    %eax,%edx
c0109a84:	73 12                	jae    c0109a98 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109a86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a89:	8b 00                	mov    (%eax),%eax
c0109a8b:	8d 48 01             	lea    0x1(%eax),%ecx
c0109a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109a91:	89 0a                	mov    %ecx,(%edx)
c0109a93:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a96:	88 10                	mov    %dl,(%eax)
    }
}
c0109a98:	90                   	nop
c0109a99:	5d                   	pop    %ebp
c0109a9a:	c3                   	ret    

c0109a9b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0109a9b:	55                   	push   %ebp
c0109a9c:	89 e5                	mov    %esp,%ebp
c0109a9e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109aa1:	8d 45 14             	lea    0x14(%ebp),%eax
c0109aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109aaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109aae:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109abc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109abf:	89 04 24             	mov    %eax,(%esp)
c0109ac2:	e8 0a 00 00 00       	call   c0109ad1 <vsnprintf>
c0109ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0109aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109acd:	89 ec                	mov    %ebp,%esp
c0109acf:	5d                   	pop    %ebp
c0109ad0:	c3                   	ret    

c0109ad1 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109ad1:	55                   	push   %ebp
c0109ad2:	89 e5                	mov    %esp,%ebp
c0109ad4:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ada:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109add:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ae0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109ae3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ae6:	01 d0                	add    %edx,%eax
c0109ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109aeb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109af2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109af6:	74 0a                	je     c0109b02 <vsnprintf+0x31>
c0109af8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109afe:	39 c2                	cmp    %eax,%edx
c0109b00:	76 07                	jbe    c0109b09 <vsnprintf+0x38>
        return -E_INVAL;
c0109b02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109b07:	eb 2a                	jmp    c0109b33 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0109b09:	8b 45 14             	mov    0x14(%ebp),%eax
c0109b0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109b10:	8b 45 10             	mov    0x10(%ebp),%eax
c0109b13:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109b17:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b1e:	c7 04 24 65 9a 10 c0 	movl   $0xc0109a65,(%esp)
c0109b25:	e8 62 fb ff ff       	call   c010968c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0109b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b2d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109b33:	89 ec                	mov    %ebp,%esp
c0109b35:	5d                   	pop    %ebp
c0109b36:	c3                   	ret    

c0109b37 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0109b37:	55                   	push   %ebp
c0109b38:	89 e5                	mov    %esp,%ebp
c0109b3a:	57                   	push   %edi
c0109b3b:	56                   	push   %esi
c0109b3c:	53                   	push   %ebx
c0109b3d:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109b40:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c0109b45:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c0109b4b:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109b51:	6b f0 05             	imul   $0x5,%eax,%esi
c0109b54:	01 fe                	add    %edi,%esi
c0109b56:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109b5b:	f7 e7                	mul    %edi
c0109b5d:	01 d6                	add    %edx,%esi
c0109b5f:	89 f2                	mov    %esi,%edx
c0109b61:	83 c0 0b             	add    $0xb,%eax
c0109b64:	83 d2 00             	adc    $0x0,%edx
c0109b67:	89 c7                	mov    %eax,%edi
c0109b69:	83 e7 ff             	and    $0xffffffff,%edi
c0109b6c:	89 f9                	mov    %edi,%ecx
c0109b6e:	0f b7 da             	movzwl %dx,%ebx
c0109b71:	89 0d 88 8a 12 c0    	mov    %ecx,0xc0128a88
c0109b77:	89 1d 8c 8a 12 c0    	mov    %ebx,0xc0128a8c
    unsigned long long result = (next >> 12);
c0109b7d:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c0109b82:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c0109b88:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109b8c:	c1 ea 0c             	shr    $0xc,%edx
c0109b8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109b92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109b95:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109ba2:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109ba5:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109ba8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109bae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109bb2:	74 1c                	je     c0109bd0 <rand+0x99>
c0109bb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109bb7:	ba 00 00 00 00       	mov    $0x0,%edx
c0109bbc:	f7 75 dc             	divl   -0x24(%ebp)
c0109bbf:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109bc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109bc5:	ba 00 00 00 00       	mov    $0x0,%edx
c0109bca:	f7 75 dc             	divl   -0x24(%ebp)
c0109bcd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109bd0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109bd3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109bd6:	f7 75 dc             	divl   -0x24(%ebp)
c0109bd9:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109bdc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109bdf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109be2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109be5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109be8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109beb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109bee:	83 c4 24             	add    $0x24,%esp
c0109bf1:	5b                   	pop    %ebx
c0109bf2:	5e                   	pop    %esi
c0109bf3:	5f                   	pop    %edi
c0109bf4:	5d                   	pop    %ebp
c0109bf5:	c3                   	ret    

c0109bf6 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109bf6:	55                   	push   %ebp
c0109bf7:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bfc:	ba 00 00 00 00       	mov    $0x0,%edx
c0109c01:	a3 88 8a 12 c0       	mov    %eax,0xc0128a88
c0109c06:	89 15 8c 8a 12 c0    	mov    %edx,0xc0128a8c
}
c0109c0c:	90                   	nop
c0109c0d:	5d                   	pop    %ebp
c0109c0e:	c3                   	ret    

c0109c0f <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109c0f:	55                   	push   %ebp
c0109c10:	89 e5                	mov    %esp,%ebp
c0109c12:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109c15:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109c1c:	eb 03                	jmp    c0109c21 <strlen+0x12>
        cnt ++;
c0109c1e:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0109c21:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c24:	8d 50 01             	lea    0x1(%eax),%edx
c0109c27:	89 55 08             	mov    %edx,0x8(%ebp)
c0109c2a:	0f b6 00             	movzbl (%eax),%eax
c0109c2d:	84 c0                	test   %al,%al
c0109c2f:	75 ed                	jne    c0109c1e <strlen+0xf>
    }
    return cnt;
c0109c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109c34:	89 ec                	mov    %ebp,%esp
c0109c36:	5d                   	pop    %ebp
c0109c37:	c3                   	ret    

c0109c38 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109c38:	55                   	push   %ebp
c0109c39:	89 e5                	mov    %esp,%ebp
c0109c3b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109c3e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109c45:	eb 03                	jmp    c0109c4a <strnlen+0x12>
        cnt ++;
c0109c47:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109c4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109c4d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109c50:	73 10                	jae    c0109c62 <strnlen+0x2a>
c0109c52:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c55:	8d 50 01             	lea    0x1(%eax),%edx
c0109c58:	89 55 08             	mov    %edx,0x8(%ebp)
c0109c5b:	0f b6 00             	movzbl (%eax),%eax
c0109c5e:	84 c0                	test   %al,%al
c0109c60:	75 e5                	jne    c0109c47 <strnlen+0xf>
    }
    return cnt;
c0109c62:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109c65:	89 ec                	mov    %ebp,%esp
c0109c67:	5d                   	pop    %ebp
c0109c68:	c3                   	ret    

c0109c69 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109c69:	55                   	push   %ebp
c0109c6a:	89 e5                	mov    %esp,%ebp
c0109c6c:	57                   	push   %edi
c0109c6d:	56                   	push   %esi
c0109c6e:	83 ec 20             	sub    $0x20,%esp
c0109c71:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c74:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c77:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0109c7d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c83:	89 d1                	mov    %edx,%ecx
c0109c85:	89 c2                	mov    %eax,%edx
c0109c87:	89 ce                	mov    %ecx,%esi
c0109c89:	89 d7                	mov    %edx,%edi
c0109c8b:	ac                   	lods   %ds:(%esi),%al
c0109c8c:	aa                   	stos   %al,%es:(%edi)
c0109c8d:	84 c0                	test   %al,%al
c0109c8f:	75 fa                	jne    c0109c8b <strcpy+0x22>
c0109c91:	89 fa                	mov    %edi,%edx
c0109c93:	89 f1                	mov    %esi,%ecx
c0109c95:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109c98:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109c9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0109c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0109ca1:	83 c4 20             	add    $0x20,%esp
c0109ca4:	5e                   	pop    %esi
c0109ca5:	5f                   	pop    %edi
c0109ca6:	5d                   	pop    %ebp
c0109ca7:	c3                   	ret    

c0109ca8 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109ca8:	55                   	push   %ebp
c0109ca9:	89 e5                	mov    %esp,%ebp
c0109cab:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0109cae:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109cb4:	eb 1e                	jmp    c0109cd4 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0109cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cb9:	0f b6 10             	movzbl (%eax),%edx
c0109cbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109cbf:	88 10                	mov    %dl,(%eax)
c0109cc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109cc4:	0f b6 00             	movzbl (%eax),%eax
c0109cc7:	84 c0                	test   %al,%al
c0109cc9:	74 03                	je     c0109cce <strncpy+0x26>
            src ++;
c0109ccb:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0109cce:	ff 45 fc             	incl   -0x4(%ebp)
c0109cd1:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0109cd4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109cd8:	75 dc                	jne    c0109cb6 <strncpy+0xe>
    }
    return dst;
c0109cda:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109cdd:	89 ec                	mov    %ebp,%esp
c0109cdf:	5d                   	pop    %ebp
c0109ce0:	c3                   	ret    

c0109ce1 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0109ce1:	55                   	push   %ebp
c0109ce2:	89 e5                	mov    %esp,%ebp
c0109ce4:	57                   	push   %edi
c0109ce5:	56                   	push   %esi
c0109ce6:	83 ec 20             	sub    $0x20,%esp
c0109ce9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109cef:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109cf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0109cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cfb:	89 d1                	mov    %edx,%ecx
c0109cfd:	89 c2                	mov    %eax,%edx
c0109cff:	89 ce                	mov    %ecx,%esi
c0109d01:	89 d7                	mov    %edx,%edi
c0109d03:	ac                   	lods   %ds:(%esi),%al
c0109d04:	ae                   	scas   %es:(%edi),%al
c0109d05:	75 08                	jne    c0109d0f <strcmp+0x2e>
c0109d07:	84 c0                	test   %al,%al
c0109d09:	75 f8                	jne    c0109d03 <strcmp+0x22>
c0109d0b:	31 c0                	xor    %eax,%eax
c0109d0d:	eb 04                	jmp    c0109d13 <strcmp+0x32>
c0109d0f:	19 c0                	sbb    %eax,%eax
c0109d11:	0c 01                	or     $0x1,%al
c0109d13:	89 fa                	mov    %edi,%edx
c0109d15:	89 f1                	mov    %esi,%ecx
c0109d17:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d1a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109d1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0109d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0109d23:	83 c4 20             	add    $0x20,%esp
c0109d26:	5e                   	pop    %esi
c0109d27:	5f                   	pop    %edi
c0109d28:	5d                   	pop    %ebp
c0109d29:	c3                   	ret    

c0109d2a <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0109d2a:	55                   	push   %ebp
c0109d2b:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109d2d:	eb 09                	jmp    c0109d38 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0109d2f:	ff 4d 10             	decl   0x10(%ebp)
c0109d32:	ff 45 08             	incl   0x8(%ebp)
c0109d35:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109d38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109d3c:	74 1a                	je     c0109d58 <strncmp+0x2e>
c0109d3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d41:	0f b6 00             	movzbl (%eax),%eax
c0109d44:	84 c0                	test   %al,%al
c0109d46:	74 10                	je     c0109d58 <strncmp+0x2e>
c0109d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d4b:	0f b6 10             	movzbl (%eax),%edx
c0109d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d51:	0f b6 00             	movzbl (%eax),%eax
c0109d54:	38 c2                	cmp    %al,%dl
c0109d56:	74 d7                	je     c0109d2f <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109d58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109d5c:	74 18                	je     c0109d76 <strncmp+0x4c>
c0109d5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d61:	0f b6 00             	movzbl (%eax),%eax
c0109d64:	0f b6 d0             	movzbl %al,%edx
c0109d67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d6a:	0f b6 00             	movzbl (%eax),%eax
c0109d6d:	0f b6 c8             	movzbl %al,%ecx
c0109d70:	89 d0                	mov    %edx,%eax
c0109d72:	29 c8                	sub    %ecx,%eax
c0109d74:	eb 05                	jmp    c0109d7b <strncmp+0x51>
c0109d76:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109d7b:	5d                   	pop    %ebp
c0109d7c:	c3                   	ret    

c0109d7d <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109d7d:	55                   	push   %ebp
c0109d7e:	89 e5                	mov    %esp,%ebp
c0109d80:	83 ec 04             	sub    $0x4,%esp
c0109d83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d86:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109d89:	eb 13                	jmp    c0109d9e <strchr+0x21>
        if (*s == c) {
c0109d8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d8e:	0f b6 00             	movzbl (%eax),%eax
c0109d91:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0109d94:	75 05                	jne    c0109d9b <strchr+0x1e>
            return (char *)s;
c0109d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d99:	eb 12                	jmp    c0109dad <strchr+0x30>
        }
        s ++;
c0109d9b:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0109d9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109da1:	0f b6 00             	movzbl (%eax),%eax
c0109da4:	84 c0                	test   %al,%al
c0109da6:	75 e3                	jne    c0109d8b <strchr+0xe>
    }
    return NULL;
c0109da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109dad:	89 ec                	mov    %ebp,%esp
c0109daf:	5d                   	pop    %ebp
c0109db0:	c3                   	ret    

c0109db1 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0109db1:	55                   	push   %ebp
c0109db2:	89 e5                	mov    %esp,%ebp
c0109db4:	83 ec 04             	sub    $0x4,%esp
c0109db7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109dba:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109dbd:	eb 0e                	jmp    c0109dcd <strfind+0x1c>
        if (*s == c) {
c0109dbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dc2:	0f b6 00             	movzbl (%eax),%eax
c0109dc5:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0109dc8:	74 0f                	je     c0109dd9 <strfind+0x28>
            break;
        }
        s ++;
c0109dca:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0109dcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd0:	0f b6 00             	movzbl (%eax),%eax
c0109dd3:	84 c0                	test   %al,%al
c0109dd5:	75 e8                	jne    c0109dbf <strfind+0xe>
c0109dd7:	eb 01                	jmp    c0109dda <strfind+0x29>
            break;
c0109dd9:	90                   	nop
    }
    return (char *)s;
c0109dda:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109ddd:	89 ec                	mov    %ebp,%esp
c0109ddf:	5d                   	pop    %ebp
c0109de0:	c3                   	ret    

c0109de1 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0109de1:	55                   	push   %ebp
c0109de2:	89 e5                	mov    %esp,%ebp
c0109de4:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109de7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0109dee:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109df5:	eb 03                	jmp    c0109dfa <strtol+0x19>
        s ++;
c0109df7:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0109dfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dfd:	0f b6 00             	movzbl (%eax),%eax
c0109e00:	3c 20                	cmp    $0x20,%al
c0109e02:	74 f3                	je     c0109df7 <strtol+0x16>
c0109e04:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e07:	0f b6 00             	movzbl (%eax),%eax
c0109e0a:	3c 09                	cmp    $0x9,%al
c0109e0c:	74 e9                	je     c0109df7 <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0109e0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e11:	0f b6 00             	movzbl (%eax),%eax
c0109e14:	3c 2b                	cmp    $0x2b,%al
c0109e16:	75 05                	jne    c0109e1d <strtol+0x3c>
        s ++;
c0109e18:	ff 45 08             	incl   0x8(%ebp)
c0109e1b:	eb 14                	jmp    c0109e31 <strtol+0x50>
    }
    else if (*s == '-') {
c0109e1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e20:	0f b6 00             	movzbl (%eax),%eax
c0109e23:	3c 2d                	cmp    $0x2d,%al
c0109e25:	75 0a                	jne    c0109e31 <strtol+0x50>
        s ++, neg = 1;
c0109e27:	ff 45 08             	incl   0x8(%ebp)
c0109e2a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0109e31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109e35:	74 06                	je     c0109e3d <strtol+0x5c>
c0109e37:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0109e3b:	75 22                	jne    c0109e5f <strtol+0x7e>
c0109e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e40:	0f b6 00             	movzbl (%eax),%eax
c0109e43:	3c 30                	cmp    $0x30,%al
c0109e45:	75 18                	jne    c0109e5f <strtol+0x7e>
c0109e47:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e4a:	40                   	inc    %eax
c0109e4b:	0f b6 00             	movzbl (%eax),%eax
c0109e4e:	3c 78                	cmp    $0x78,%al
c0109e50:	75 0d                	jne    c0109e5f <strtol+0x7e>
        s += 2, base = 16;
c0109e52:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0109e56:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0109e5d:	eb 29                	jmp    c0109e88 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0109e5f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109e63:	75 16                	jne    c0109e7b <strtol+0x9a>
c0109e65:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e68:	0f b6 00             	movzbl (%eax),%eax
c0109e6b:	3c 30                	cmp    $0x30,%al
c0109e6d:	75 0c                	jne    c0109e7b <strtol+0x9a>
        s ++, base = 8;
c0109e6f:	ff 45 08             	incl   0x8(%ebp)
c0109e72:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0109e79:	eb 0d                	jmp    c0109e88 <strtol+0xa7>
    }
    else if (base == 0) {
c0109e7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109e7f:	75 07                	jne    c0109e88 <strtol+0xa7>
        base = 10;
c0109e81:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0109e88:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e8b:	0f b6 00             	movzbl (%eax),%eax
c0109e8e:	3c 2f                	cmp    $0x2f,%al
c0109e90:	7e 1b                	jle    c0109ead <strtol+0xcc>
c0109e92:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e95:	0f b6 00             	movzbl (%eax),%eax
c0109e98:	3c 39                	cmp    $0x39,%al
c0109e9a:	7f 11                	jg     c0109ead <strtol+0xcc>
            dig = *s - '0';
c0109e9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e9f:	0f b6 00             	movzbl (%eax),%eax
c0109ea2:	0f be c0             	movsbl %al,%eax
c0109ea5:	83 e8 30             	sub    $0x30,%eax
c0109ea8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109eab:	eb 48                	jmp    c0109ef5 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0109ead:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eb0:	0f b6 00             	movzbl (%eax),%eax
c0109eb3:	3c 60                	cmp    $0x60,%al
c0109eb5:	7e 1b                	jle    c0109ed2 <strtol+0xf1>
c0109eb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eba:	0f b6 00             	movzbl (%eax),%eax
c0109ebd:	3c 7a                	cmp    $0x7a,%al
c0109ebf:	7f 11                	jg     c0109ed2 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0109ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ec4:	0f b6 00             	movzbl (%eax),%eax
c0109ec7:	0f be c0             	movsbl %al,%eax
c0109eca:	83 e8 57             	sub    $0x57,%eax
c0109ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ed0:	eb 23                	jmp    c0109ef5 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0109ed2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ed5:	0f b6 00             	movzbl (%eax),%eax
c0109ed8:	3c 40                	cmp    $0x40,%al
c0109eda:	7e 3b                	jle    c0109f17 <strtol+0x136>
c0109edc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109edf:	0f b6 00             	movzbl (%eax),%eax
c0109ee2:	3c 5a                	cmp    $0x5a,%al
c0109ee4:	7f 31                	jg     c0109f17 <strtol+0x136>
            dig = *s - 'A' + 10;
c0109ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee9:	0f b6 00             	movzbl (%eax),%eax
c0109eec:	0f be c0             	movsbl %al,%eax
c0109eef:	83 e8 37             	sub    $0x37,%eax
c0109ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0109ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ef8:	3b 45 10             	cmp    0x10(%ebp),%eax
c0109efb:	7d 19                	jge    c0109f16 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0109efd:	ff 45 08             	incl   0x8(%ebp)
c0109f00:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109f03:	0f af 45 10          	imul   0x10(%ebp),%eax
c0109f07:	89 c2                	mov    %eax,%edx
c0109f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f0c:	01 d0                	add    %edx,%eax
c0109f0e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0109f11:	e9 72 ff ff ff       	jmp    c0109e88 <strtol+0xa7>
            break;
c0109f16:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0109f17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109f1b:	74 08                	je     c0109f25 <strtol+0x144>
        *endptr = (char *) s;
c0109f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f20:	8b 55 08             	mov    0x8(%ebp),%edx
c0109f23:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0109f25:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0109f29:	74 07                	je     c0109f32 <strtol+0x151>
c0109f2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109f2e:	f7 d8                	neg    %eax
c0109f30:	eb 03                	jmp    c0109f35 <strtol+0x154>
c0109f32:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0109f35:	89 ec                	mov    %ebp,%esp
c0109f37:	5d                   	pop    %ebp
c0109f38:	c3                   	ret    

c0109f39 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0109f39:	55                   	push   %ebp
c0109f3a:	89 e5                	mov    %esp,%ebp
c0109f3c:	83 ec 28             	sub    $0x28,%esp
c0109f3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
c0109f42:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f45:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0109f48:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0109f4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f4f:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0109f52:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0109f55:	8b 45 10             	mov    0x10(%ebp),%eax
c0109f58:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0109f5b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109f5e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0109f62:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109f65:	89 d7                	mov    %edx,%edi
c0109f67:	f3 aa                	rep stos %al,%es:(%edi)
c0109f69:	89 fa                	mov    %edi,%edx
c0109f6b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109f6e:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0109f71:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0109f74:	8b 7d fc             	mov    -0x4(%ebp),%edi
c0109f77:	89 ec                	mov    %ebp,%esp
c0109f79:	5d                   	pop    %ebp
c0109f7a:	c3                   	ret    

c0109f7b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0109f7b:	55                   	push   %ebp
c0109f7c:	89 e5                	mov    %esp,%ebp
c0109f7e:	57                   	push   %edi
c0109f7f:	56                   	push   %esi
c0109f80:	53                   	push   %ebx
c0109f81:	83 ec 30             	sub    $0x30,%esp
c0109f84:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109f90:	8b 45 10             	mov    0x10(%ebp),%eax
c0109f93:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0109f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f99:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0109f9c:	73 42                	jae    c0109fe0 <memmove+0x65>
c0109f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fa1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109fa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109fa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109fad:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109fb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109fb3:	c1 e8 02             	shr    $0x2,%eax
c0109fb6:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0109fb8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109fbe:	89 d7                	mov    %edx,%edi
c0109fc0:	89 c6                	mov    %eax,%esi
c0109fc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109fc4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0109fc7:	83 e1 03             	and    $0x3,%ecx
c0109fca:	74 02                	je     c0109fce <memmove+0x53>
c0109fcc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109fce:	89 f0                	mov    %esi,%eax
c0109fd0:	89 fa                	mov    %edi,%edx
c0109fd2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0109fd5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109fd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0109fdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0109fde:	eb 36                	jmp    c010a016 <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0109fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109fe3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109fe6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109fe9:	01 c2                	add    %eax,%edx
c0109feb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109fee:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0109ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ff4:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0109ff7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109ffa:	89 c1                	mov    %eax,%ecx
c0109ffc:	89 d8                	mov    %ebx,%eax
c0109ffe:	89 d6                	mov    %edx,%esi
c010a000:	89 c7                	mov    %eax,%edi
c010a002:	fd                   	std    
c010a003:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a005:	fc                   	cld    
c010a006:	89 f8                	mov    %edi,%eax
c010a008:	89 f2                	mov    %esi,%edx
c010a00a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010a00d:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010a010:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010a013:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010a016:	83 c4 30             	add    $0x30,%esp
c010a019:	5b                   	pop    %ebx
c010a01a:	5e                   	pop    %esi
c010a01b:	5f                   	pop    %edi
c010a01c:	5d                   	pop    %ebp
c010a01d:	c3                   	ret    

c010a01e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010a01e:	55                   	push   %ebp
c010a01f:	89 e5                	mov    %esp,%ebp
c010a021:	57                   	push   %edi
c010a022:	56                   	push   %esi
c010a023:	83 ec 20             	sub    $0x20,%esp
c010a026:	8b 45 08             	mov    0x8(%ebp),%eax
c010a029:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a02c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a02f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a032:	8b 45 10             	mov    0x10(%ebp),%eax
c010a035:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a038:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a03b:	c1 e8 02             	shr    $0x2,%eax
c010a03e:	89 c1                	mov    %eax,%ecx
    asm volatile (
c010a040:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a043:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a046:	89 d7                	mov    %edx,%edi
c010a048:	89 c6                	mov    %eax,%esi
c010a04a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a04c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010a04f:	83 e1 03             	and    $0x3,%ecx
c010a052:	74 02                	je     c010a056 <memcpy+0x38>
c010a054:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a056:	89 f0                	mov    %esi,%eax
c010a058:	89 fa                	mov    %edi,%edx
c010a05a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010a05d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a060:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010a063:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010a066:	83 c4 20             	add    $0x20,%esp
c010a069:	5e                   	pop    %esi
c010a06a:	5f                   	pop    %edi
c010a06b:	5d                   	pop    %ebp
c010a06c:	c3                   	ret    

c010a06d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010a06d:	55                   	push   %ebp
c010a06e:	89 e5                	mov    %esp,%ebp
c010a070:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010a073:	8b 45 08             	mov    0x8(%ebp),%eax
c010a076:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010a079:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a07c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010a07f:	eb 2e                	jmp    c010a0af <memcmp+0x42>
        if (*s1 != *s2) {
c010a081:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a084:	0f b6 10             	movzbl (%eax),%edx
c010a087:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a08a:	0f b6 00             	movzbl (%eax),%eax
c010a08d:	38 c2                	cmp    %al,%dl
c010a08f:	74 18                	je     c010a0a9 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010a091:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a094:	0f b6 00             	movzbl (%eax),%eax
c010a097:	0f b6 d0             	movzbl %al,%edx
c010a09a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a09d:	0f b6 00             	movzbl (%eax),%eax
c010a0a0:	0f b6 c8             	movzbl %al,%ecx
c010a0a3:	89 d0                	mov    %edx,%eax
c010a0a5:	29 c8                	sub    %ecx,%eax
c010a0a7:	eb 18                	jmp    c010a0c1 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010a0a9:	ff 45 fc             	incl   -0x4(%ebp)
c010a0ac:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c010a0af:	8b 45 10             	mov    0x10(%ebp),%eax
c010a0b2:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a0b5:	89 55 10             	mov    %edx,0x10(%ebp)
c010a0b8:	85 c0                	test   %eax,%eax
c010a0ba:	75 c5                	jne    c010a081 <memcmp+0x14>
    }
    return 0;
c010a0bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a0c1:	89 ec                	mov    %ebp,%esp
c010a0c3:	5d                   	pop    %ebp
c010a0c4:	c3                   	ret    
