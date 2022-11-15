
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 80 11 40       	mov    $0x40118000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 80 11 00       	mov    %eax,0x118000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 70 11 00       	mov    $0x117000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 28 af 11 00       	mov    $0x11af28,%edx
  100041:	b8 36 7a 11 00       	mov    $0x117a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 7a 11 00 	movl   $0x117a36,(%esp)
  10005d:	e8 a0 5d 00 00       	call   105e02 <memset>

    cons_init();                // init the console
  100062:	e8 8d 15 00 00       	call   1015f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 a0 5f 10 00 	movl   $0x105fa0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 bc 5f 10 00 	movl   $0x105fbc,(%esp)
  10007c:	e8 d2 02 00 00       	call   100353 <cprintf>

    print_kerninfo();
  100081:	e8 01 08 00 00       	call   100887 <print_kerninfo>

    grade_backtrace();
  100086:	e8 86 00 00 00       	call   100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 dd 42 00 00       	call   10436d <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 c8 16 00 00       	call   10175d <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 40 18 00 00       	call   1018da <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 0b 0d 00 00       	call   100daa <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 27 16 00 00       	call   1016cb <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 03 0c 00 00       	call   100ccb <mon_backtrace>
}
  1000c8:	c9                   	leave  
  1000c9:	c3                   	ret    

001000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ca:	55                   	push   %ebp
  1000cb:	89 e5                	mov    %esp,%ebp
  1000cd:	53                   	push   %ebx
  1000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000d7:	8d 55 08             	lea    0x8(%ebp),%edx
  1000da:	8b 45 08             	mov    0x8(%ebp),%eax
  1000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000e9:	89 04 24             	mov    %eax,(%esp)
  1000ec:	e8 b5 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f1:	83 c4 14             	add    $0x14,%esp
  1000f4:	5b                   	pop    %ebx
  1000f5:	5d                   	pop    %ebp
  1000f6:	c3                   	ret    

001000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f7:	55                   	push   %ebp
  1000f8:	89 e5                	mov    %esp,%ebp
  1000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000fd:	8b 45 10             	mov    0x10(%ebp),%eax
  100100:	89 44 24 04          	mov    %eax,0x4(%esp)
  100104:	8b 45 08             	mov    0x8(%ebp),%eax
  100107:	89 04 24             	mov    %eax,(%esp)
  10010a:	e8 bb ff ff ff       	call   1000ca <grade_backtrace1>
}
  10010f:	c9                   	leave  
  100110:	c3                   	ret    

00100111 <grade_backtrace>:

void
grade_backtrace(void) {
  100111:	55                   	push   %ebp
  100112:	89 e5                	mov    %esp,%ebp
  100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  100117:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100123:	ff 
  100124:	89 44 24 04          	mov    %eax,0x4(%esp)
  100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10012f:	e8 c3 ff ff ff       	call   1000f7 <grade_backtrace0>
}
  100134:	c9                   	leave  
  100135:	c3                   	ret    

00100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100136:	55                   	push   %ebp
  100137:	89 e5                	mov    %esp,%ebp
  100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10014c:	0f b7 c0             	movzwl %ax,%eax
  10014f:	83 e0 03             	and    $0x3,%eax
  100152:	89 c2                	mov    %eax,%edx
  100154:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100159:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100161:	c7 04 24 c1 5f 10 00 	movl   $0x105fc1,(%esp)
  100168:	e8 e6 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100171:	0f b7 d0             	movzwl %ax,%edx
  100174:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 cf 5f 10 00 	movl   $0x105fcf,(%esp)
  100188:	e8 c6 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	0f b7 d0             	movzwl %ax,%edx
  100194:	a1 00 a0 11 00       	mov    0x11a000,%eax
  100199:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a1:	c7 04 24 dd 5f 10 00 	movl   $0x105fdd,(%esp)
  1001a8:	e8 a6 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 eb 5f 10 00 	movl   $0x105feb,(%esp)
  1001c8:	e8 86 01 00 00       	call   100353 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d1:	0f b7 d0             	movzwl %ax,%edx
  1001d4:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e1:	c7 04 24 f9 5f 10 00 	movl   $0x105ff9,(%esp)
  1001e8:	e8 66 01 00 00       	call   100353 <cprintf>
    round ++;
  1001ed:	a1 00 a0 11 00       	mov    0x11a000,%eax
  1001f2:	83 c0 01             	add    $0x1,%eax
  1001f5:	a3 00 a0 11 00       	mov    %eax,0x11a000
}
  1001fa:	c9                   	leave  
  1001fb:	c3                   	ret    

001001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fc:	55                   	push   %ebp
  1001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
asm volatile(
  1001ff:	83 ec 08             	sub    $0x8,%esp
  100202:	cd 78                	int    $0x78
  100204:	89 ec                	mov    %ebp,%esp
    "int %0 \n"                    //中断
    "movl %%ebp,%%esp"             //恢复栈指针
    :
    :"i"(T_SWITCH_TOU)             //中断号
    );
}
  100206:	5d                   	pop    %ebp
  100207:	c3                   	ret    

00100208 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100208:	55                   	push   %ebp
  100209:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
asm volatile (
  10020b:	cd 79                	int    $0x79
  10020d:	89 ec                	mov    %ebp,%esp
     "int %0 \n"
     "movl %%ebp, %%esp \n"
     :
     : "i"(T_SWITCH_TOK)
     );
}
  10020f:	5d                   	pop    %ebp
  100210:	c3                   	ret    

00100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100211:	55                   	push   %ebp
  100212:	89 e5                	mov    %esp,%ebp
  100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100217:	e8 1a ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10021c:	c7 04 24 08 60 10 00 	movl   $0x106008,(%esp)
  100223:	e8 2b 01 00 00       	call   100353 <cprintf>
    lab1_switch_to_user();
  100228:	e8 cf ff ff ff       	call   1001fc <lab1_switch_to_user>
    lab1_print_cur_status();
  10022d:	e8 04 ff ff ff       	call   100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100232:	c7 04 24 28 60 10 00 	movl   $0x106028,(%esp)
  100239:	e8 15 01 00 00       	call   100353 <cprintf>
    lab1_switch_to_kernel();
  10023e:	e8 c5 ff ff ff       	call   100208 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100243:	e8 ee fe ff ff       	call   100136 <lab1_print_cur_status>
}
  100248:	c9                   	leave  
  100249:	c3                   	ret    

0010024a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10024a:	55                   	push   %ebp
  10024b:	89 e5                	mov    %esp,%ebp
  10024d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100250:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100254:	74 13                	je     100269 <readline+0x1f>
        cprintf("%s", prompt);
  100256:	8b 45 08             	mov    0x8(%ebp),%eax
  100259:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025d:	c7 04 24 47 60 10 00 	movl   $0x106047,(%esp)
  100264:	e8 ea 00 00 00       	call   100353 <cprintf>
    }
    int i = 0, c;
  100269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100270:	e8 66 01 00 00       	call   1003db <getchar>
  100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10027c:	79 07                	jns    100285 <readline+0x3b>
            return NULL;
  10027e:	b8 00 00 00 00       	mov    $0x0,%eax
  100283:	eb 79                	jmp    1002fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100285:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100289:	7e 28                	jle    1002b3 <readline+0x69>
  10028b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100292:	7f 1f                	jg     1002b3 <readline+0x69>
            cputchar(c);
  100294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100297:	89 04 24             	mov    %eax,(%esp)
  10029a:	e8 da 00 00 00       	call   100379 <cputchar>
            buf[i ++] = c;
  10029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002a2:	8d 50 01             	lea    0x1(%eax),%edx
  1002a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002ab:	88 90 20 a0 11 00    	mov    %dl,0x11a020(%eax)
  1002b1:	eb 46                	jmp    1002f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  1002b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b7:	75 17                	jne    1002d0 <readline+0x86>
  1002b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002bd:	7e 11                	jle    1002d0 <readline+0x86>
            cputchar(c);
  1002bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002c2:	89 04 24             	mov    %eax,(%esp)
  1002c5:	e8 af 00 00 00       	call   100379 <cputchar>
            i --;
  1002ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1002ce:	eb 29                	jmp    1002f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  1002d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d4:	74 06                	je     1002dc <readline+0x92>
  1002d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002da:	75 1d                	jne    1002f9 <readline+0xaf>
            cputchar(c);
  1002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002df:	89 04 24             	mov    %eax,(%esp)
  1002e2:	e8 92 00 00 00       	call   100379 <cputchar>
            buf[i] = '\0';
  1002e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002ea:	05 20 a0 11 00       	add    $0x11a020,%eax
  1002ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002f2:	b8 20 a0 11 00       	mov    $0x11a020,%eax
  1002f7:	eb 05                	jmp    1002fe <readline+0xb4>
        }
    }
  1002f9:	e9 72 ff ff ff       	jmp    100270 <readline+0x26>
}
  1002fe:	c9                   	leave  
  1002ff:	c3                   	ret    

00100300 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100300:	55                   	push   %ebp
  100301:	89 e5                	mov    %esp,%ebp
  100303:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100306:	8b 45 08             	mov    0x8(%ebp),%eax
  100309:	89 04 24             	mov    %eax,(%esp)
  10030c:	e8 0f 13 00 00       	call   101620 <cons_putc>
    (*cnt) ++;
  100311:	8b 45 0c             	mov    0xc(%ebp),%eax
  100314:	8b 00                	mov    (%eax),%eax
  100316:	8d 50 01             	lea    0x1(%eax),%edx
  100319:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031c:	89 10                	mov    %edx,(%eax)
}
  10031e:	c9                   	leave  
  10031f:	c3                   	ret    

00100320 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100320:	55                   	push   %ebp
  100321:	89 e5                	mov    %esp,%ebp
  100323:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100330:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100334:	8b 45 08             	mov    0x8(%ebp),%eax
  100337:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100342:	c7 04 24 00 03 10 00 	movl   $0x100300,(%esp)
  100349:	e8 cd 52 00 00       	call   10561b <vprintfmt>
    return cnt;
  10034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100351:	c9                   	leave  
  100352:	c3                   	ret    

00100353 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100353:	55                   	push   %ebp
  100354:	89 e5                	mov    %esp,%ebp
  100356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100359:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10035f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100362:	89 44 24 04          	mov    %eax,0x4(%esp)
  100366:	8b 45 08             	mov    0x8(%ebp),%eax
  100369:	89 04 24             	mov    %eax,(%esp)
  10036c:	e8 af ff ff ff       	call   100320 <vcprintf>
  100371:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100377:	c9                   	leave  
  100378:	c3                   	ret    

00100379 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100379:	55                   	push   %ebp
  10037a:	89 e5                	mov    %esp,%ebp
  10037c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10037f:	8b 45 08             	mov    0x8(%ebp),%eax
  100382:	89 04 24             	mov    %eax,(%esp)
  100385:	e8 96 12 00 00       	call   101620 <cons_putc>
}
  10038a:	c9                   	leave  
  10038b:	c3                   	ret    

0010038c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10038c:	55                   	push   %ebp
  10038d:	89 e5                	mov    %esp,%ebp
  10038f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100399:	eb 13                	jmp    1003ae <cputs+0x22>
        cputch(c, &cnt);
  10039b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10039f:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003a6:	89 04 24             	mov    %eax,(%esp)
  1003a9:	e8 52 ff ff ff       	call   100300 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b1:	8d 50 01             	lea    0x1(%eax),%edx
  1003b4:	89 55 08             	mov    %edx,0x8(%ebp)
  1003b7:	0f b6 00             	movzbl (%eax),%eax
  1003ba:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003bd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c1:	75 d8                	jne    10039b <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1003c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d1:	e8 2a ff ff ff       	call   100300 <cputch>
    return cnt;
  1003d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003d9:	c9                   	leave  
  1003da:	c3                   	ret    

001003db <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003db:	55                   	push   %ebp
  1003dc:	89 e5                	mov    %esp,%ebp
  1003de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003e1:	e8 76 12 00 00       	call   10165c <cons_getc>
  1003e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003ed:	74 f2                	je     1003e1 <getchar+0x6>
        /* do nothing */;
    return c;
  1003ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003f2:	c9                   	leave  
  1003f3:	c3                   	ret    

001003f4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003f4:	55                   	push   %ebp
  1003f5:	89 e5                	mov    %esp,%ebp
  1003f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003fd:	8b 00                	mov    (%eax),%eax
  1003ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100402:	8b 45 10             	mov    0x10(%ebp),%eax
  100405:	8b 00                	mov    (%eax),%eax
  100407:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10040a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100411:	e9 d2 00 00 00       	jmp    1004e8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  100416:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100419:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10041c:	01 d0                	add    %edx,%eax
  10041e:	89 c2                	mov    %eax,%edx
  100420:	c1 ea 1f             	shr    $0x1f,%edx
  100423:	01 d0                	add    %edx,%eax
  100425:	d1 f8                	sar    %eax
  100427:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10042a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10042d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100430:	eb 04                	jmp    100436 <stab_binsearch+0x42>
            m --;
  100432:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100436:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100439:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10043c:	7c 1f                	jl     10045d <stab_binsearch+0x69>
  10043e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100441:	89 d0                	mov    %edx,%eax
  100443:	01 c0                	add    %eax,%eax
  100445:	01 d0                	add    %edx,%eax
  100447:	c1 e0 02             	shl    $0x2,%eax
  10044a:	89 c2                	mov    %eax,%edx
  10044c:	8b 45 08             	mov    0x8(%ebp),%eax
  10044f:	01 d0                	add    %edx,%eax
  100451:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100455:	0f b6 c0             	movzbl %al,%eax
  100458:	3b 45 14             	cmp    0x14(%ebp),%eax
  10045b:	75 d5                	jne    100432 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10045d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100460:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100463:	7d 0b                	jge    100470 <stab_binsearch+0x7c>
            l = true_m + 1;
  100465:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100468:	83 c0 01             	add    $0x1,%eax
  10046b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10046e:	eb 78                	jmp    1004e8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100470:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10047a:	89 d0                	mov    %edx,%eax
  10047c:	01 c0                	add    %eax,%eax
  10047e:	01 d0                	add    %edx,%eax
  100480:	c1 e0 02             	shl    $0x2,%eax
  100483:	89 c2                	mov    %eax,%edx
  100485:	8b 45 08             	mov    0x8(%ebp),%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	8b 40 08             	mov    0x8(%eax),%eax
  10048d:	3b 45 18             	cmp    0x18(%ebp),%eax
  100490:	73 13                	jae    1004a5 <stab_binsearch+0xb1>
            *region_left = m;
  100492:	8b 45 0c             	mov    0xc(%ebp),%eax
  100495:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100498:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10049a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10049d:	83 c0 01             	add    $0x1,%eax
  1004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a3:	eb 43                	jmp    1004e8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  1004a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a8:	89 d0                	mov    %edx,%eax
  1004aa:	01 c0                	add    %eax,%eax
  1004ac:	01 d0                	add    %edx,%eax
  1004ae:	c1 e0 02             	shl    $0x2,%eax
  1004b1:	89 c2                	mov    %eax,%edx
  1004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1004b6:	01 d0                	add    %edx,%eax
  1004b8:	8b 40 08             	mov    0x8(%eax),%eax
  1004bb:	3b 45 18             	cmp    0x18(%ebp),%eax
  1004be:	76 16                	jbe    1004d6 <stab_binsearch+0xe2>
            *region_right = m - 1;
  1004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004c3:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1004c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004ce:	83 e8 01             	sub    $0x1,%eax
  1004d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004d4:	eb 12                	jmp    1004e8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004dc:	89 10                	mov    %edx,(%eax)
            l = m;
  1004de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004ee:	0f 8e 22 ff ff ff    	jle    100416 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004f8:	75 0f                	jne    100509 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004fd:	8b 00                	mov    (%eax),%eax
  1004ff:	8d 50 ff             	lea    -0x1(%eax),%edx
  100502:	8b 45 10             	mov    0x10(%ebp),%eax
  100505:	89 10                	mov    %edx,(%eax)
  100507:	eb 3f                	jmp    100548 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  100509:	8b 45 10             	mov    0x10(%ebp),%eax
  10050c:	8b 00                	mov    (%eax),%eax
  10050e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100511:	eb 04                	jmp    100517 <stab_binsearch+0x123>
  100513:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  100517:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051a:	8b 00                	mov    (%eax),%eax
  10051c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10051f:	7d 1f                	jge    100540 <stab_binsearch+0x14c>
  100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100524:	89 d0                	mov    %edx,%eax
  100526:	01 c0                	add    %eax,%eax
  100528:	01 d0                	add    %edx,%eax
  10052a:	c1 e0 02             	shl    $0x2,%eax
  10052d:	89 c2                	mov    %eax,%edx
  10052f:	8b 45 08             	mov    0x8(%ebp),%eax
  100532:	01 d0                	add    %edx,%eax
  100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100538:	0f b6 c0             	movzbl %al,%eax
  10053b:	3b 45 14             	cmp    0x14(%ebp),%eax
  10053e:	75 d3                	jne    100513 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  100540:	8b 45 0c             	mov    0xc(%ebp),%eax
  100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100546:	89 10                	mov    %edx,(%eax)
    }
}
  100548:	c9                   	leave  
  100549:	c3                   	ret    

0010054a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10054a:	55                   	push   %ebp
  10054b:	89 e5                	mov    %esp,%ebp
  10054d:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100550:	8b 45 0c             	mov    0xc(%ebp),%eax
  100553:	c7 00 4c 60 10 00    	movl   $0x10604c,(%eax)
    info->eip_line = 0;
  100559:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100563:	8b 45 0c             	mov    0xc(%ebp),%eax
  100566:	c7 40 08 4c 60 10 00 	movl   $0x10604c,0x8(%eax)
    info->eip_fn_namelen = 9;
  10056d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100570:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100577:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057a:	8b 55 08             	mov    0x8(%ebp),%edx
  10057d:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100580:	8b 45 0c             	mov    0xc(%ebp),%eax
  100583:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10058a:	c7 45 f4 e0 72 10 00 	movl   $0x1072e0,-0xc(%ebp)
    stab_end = __STAB_END__;
  100591:	c7 45 f0 e8 1e 11 00 	movl   $0x111ee8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100598:	c7 45 ec e9 1e 11 00 	movl   $0x111ee9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10059f:	c7 45 e8 11 49 11 00 	movl   $0x114911,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005a9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005ac:	76 0d                	jbe    1005bb <debuginfo_eip+0x71>
  1005ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b1:	83 e8 01             	sub    $0x1,%eax
  1005b4:	0f b6 00             	movzbl (%eax),%eax
  1005b7:	84 c0                	test   %al,%al
  1005b9:	74 0a                	je     1005c5 <debuginfo_eip+0x7b>
        return -1;
  1005bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c0:	e9 c0 02 00 00       	jmp    100885 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005d2:	29 c2                	sub    %eax,%edx
  1005d4:	89 d0                	mov    %edx,%eax
  1005d6:	c1 f8 02             	sar    $0x2,%eax
  1005d9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005df:	83 e8 01             	sub    $0x1,%eax
  1005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005ec:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f3:	00 
  1005f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100602:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100605:	89 04 24             	mov    %eax,(%esp)
  100608:	e8 e7 fd ff ff       	call   1003f4 <stab_binsearch>
    if (lfile == 0)
  10060d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100610:	85 c0                	test   %eax,%eax
  100612:	75 0a                	jne    10061e <debuginfo_eip+0xd4>
        return -1;
  100614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100619:	e9 67 02 00 00       	jmp    100885 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100621:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100624:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100627:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10062a:	8b 45 08             	mov    0x8(%ebp),%eax
  10062d:	89 44 24 10          	mov    %eax,0x10(%esp)
  100631:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100638:	00 
  100639:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100640:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100643:	89 44 24 04          	mov    %eax,0x4(%esp)
  100647:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10064a:	89 04 24             	mov    %eax,(%esp)
  10064d:	e8 a2 fd ff ff       	call   1003f4 <stab_binsearch>

    if (lfun <= rfun) {
  100652:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100655:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100658:	39 c2                	cmp    %eax,%edx
  10065a:	7f 7c                	jg     1006d8 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065f:	89 c2                	mov    %eax,%edx
  100661:	89 d0                	mov    %edx,%eax
  100663:	01 c0                	add    %eax,%eax
  100665:	01 d0                	add    %edx,%eax
  100667:	c1 e0 02             	shl    $0x2,%eax
  10066a:	89 c2                	mov    %eax,%edx
  10066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066f:	01 d0                	add    %edx,%eax
  100671:	8b 10                	mov    (%eax),%edx
  100673:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100676:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100679:	29 c1                	sub    %eax,%ecx
  10067b:	89 c8                	mov    %ecx,%eax
  10067d:	39 c2                	cmp    %eax,%edx
  10067f:	73 22                	jae    1006a3 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100681:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100684:	89 c2                	mov    %eax,%edx
  100686:	89 d0                	mov    %edx,%eax
  100688:	01 c0                	add    %eax,%eax
  10068a:	01 d0                	add    %edx,%eax
  10068c:	c1 e0 02             	shl    $0x2,%eax
  10068f:	89 c2                	mov    %eax,%edx
  100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100694:	01 d0                	add    %edx,%eax
  100696:	8b 10                	mov    (%eax),%edx
  100698:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10069b:	01 c2                	add    %eax,%edx
  10069d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006a0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1006a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a6:	89 c2                	mov    %eax,%edx
  1006a8:	89 d0                	mov    %edx,%eax
  1006aa:	01 c0                	add    %eax,%eax
  1006ac:	01 d0                	add    %edx,%eax
  1006ae:	c1 e0 02             	shl    $0x2,%eax
  1006b1:	89 c2                	mov    %eax,%edx
  1006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b6:	01 d0                	add    %edx,%eax
  1006b8:	8b 50 08             	mov    0x8(%eax),%edx
  1006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006be:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006c4:	8b 40 10             	mov    0x10(%eax),%eax
  1006c7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d6:	eb 15                	jmp    1006ed <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006db:	8b 55 08             	mov    0x8(%ebp),%edx
  1006de:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006f0:	8b 40 08             	mov    0x8(%eax),%eax
  1006f3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006fa:	00 
  1006fb:	89 04 24             	mov    %eax,(%esp)
  1006fe:	e8 73 55 00 00       	call   105c76 <strfind>
  100703:	89 c2                	mov    %eax,%edx
  100705:	8b 45 0c             	mov    0xc(%ebp),%eax
  100708:	8b 40 08             	mov    0x8(%eax),%eax
  10070b:	29 c2                	sub    %eax,%edx
  10070d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100710:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100713:	8b 45 08             	mov    0x8(%ebp),%eax
  100716:	89 44 24 10          	mov    %eax,0x10(%esp)
  10071a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100721:	00 
  100722:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100725:	89 44 24 08          	mov    %eax,0x8(%esp)
  100729:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  10072c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100733:	89 04 24             	mov    %eax,(%esp)
  100736:	e8 b9 fc ff ff       	call   1003f4 <stab_binsearch>
    if (lline <= rline) {
  10073b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10073e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100741:	39 c2                	cmp    %eax,%edx
  100743:	7f 24                	jg     100769 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100745:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	89 d0                	mov    %edx,%eax
  10074c:	01 c0                	add    %eax,%eax
  10074e:	01 d0                	add    %edx,%eax
  100750:	c1 e0 02             	shl    $0x2,%eax
  100753:	89 c2                	mov    %eax,%edx
  100755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100758:	01 d0                	add    %edx,%eax
  10075a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10075e:	0f b7 d0             	movzwl %ax,%edx
  100761:	8b 45 0c             	mov    0xc(%ebp),%eax
  100764:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100767:	eb 13                	jmp    10077c <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10076e:	e9 12 01 00 00       	jmp    100885 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100773:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100776:	83 e8 01             	sub    $0x1,%eax
  100779:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10077c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100782:	39 c2                	cmp    %eax,%edx
  100784:	7c 56                	jl     1007dc <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100786:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100789:	89 c2                	mov    %eax,%edx
  10078b:	89 d0                	mov    %edx,%eax
  10078d:	01 c0                	add    %eax,%eax
  10078f:	01 d0                	add    %edx,%eax
  100791:	c1 e0 02             	shl    $0x2,%eax
  100794:	89 c2                	mov    %eax,%edx
  100796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100799:	01 d0                	add    %edx,%eax
  10079b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10079f:	3c 84                	cmp    $0x84,%al
  1007a1:	74 39                	je     1007dc <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1007a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007a6:	89 c2                	mov    %eax,%edx
  1007a8:	89 d0                	mov    %edx,%eax
  1007aa:	01 c0                	add    %eax,%eax
  1007ac:	01 d0                	add    %edx,%eax
  1007ae:	c1 e0 02             	shl    $0x2,%eax
  1007b1:	89 c2                	mov    %eax,%edx
  1007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007b6:	01 d0                	add    %edx,%eax
  1007b8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007bc:	3c 64                	cmp    $0x64,%al
  1007be:	75 b3                	jne    100773 <debuginfo_eip+0x229>
  1007c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	89 d0                	mov    %edx,%eax
  1007c7:	01 c0                	add    %eax,%eax
  1007c9:	01 d0                	add    %edx,%eax
  1007cb:	c1 e0 02             	shl    $0x2,%eax
  1007ce:	89 c2                	mov    %eax,%edx
  1007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007d3:	01 d0                	add    %edx,%eax
  1007d5:	8b 40 08             	mov    0x8(%eax),%eax
  1007d8:	85 c0                	test   %eax,%eax
  1007da:	74 97                	je     100773 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007e2:	39 c2                	cmp    %eax,%edx
  1007e4:	7c 46                	jl     10082c <debuginfo_eip+0x2e2>
  1007e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e9:	89 c2                	mov    %eax,%edx
  1007eb:	89 d0                	mov    %edx,%eax
  1007ed:	01 c0                	add    %eax,%eax
  1007ef:	01 d0                	add    %edx,%eax
  1007f1:	c1 e0 02             	shl    $0x2,%eax
  1007f4:	89 c2                	mov    %eax,%edx
  1007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f9:	01 d0                	add    %edx,%eax
  1007fb:	8b 10                	mov    (%eax),%edx
  1007fd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100800:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100803:	29 c1                	sub    %eax,%ecx
  100805:	89 c8                	mov    %ecx,%eax
  100807:	39 c2                	cmp    %eax,%edx
  100809:	73 21                	jae    10082c <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10080b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10080e:	89 c2                	mov    %eax,%edx
  100810:	89 d0                	mov    %edx,%eax
  100812:	01 c0                	add    %eax,%eax
  100814:	01 d0                	add    %edx,%eax
  100816:	c1 e0 02             	shl    $0x2,%eax
  100819:	89 c2                	mov    %eax,%edx
  10081b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10081e:	01 d0                	add    %edx,%eax
  100820:	8b 10                	mov    (%eax),%edx
  100822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100825:	01 c2                	add    %eax,%edx
  100827:	8b 45 0c             	mov    0xc(%ebp),%eax
  10082a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  10082c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10082f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100832:	39 c2                	cmp    %eax,%edx
  100834:	7d 4a                	jge    100880 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  100836:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100839:	83 c0 01             	add    $0x1,%eax
  10083c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10083f:	eb 18                	jmp    100859 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100841:	8b 45 0c             	mov    0xc(%ebp),%eax
  100844:	8b 40 14             	mov    0x14(%eax),%eax
  100847:	8d 50 01             	lea    0x1(%eax),%edx
  10084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10084d:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100853:	83 c0 01             	add    $0x1,%eax
  100856:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100859:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10085c:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10085f:	39 c2                	cmp    %eax,%edx
  100861:	7d 1d                	jge    100880 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	89 d0                	mov    %edx,%eax
  10086a:	01 c0                	add    %eax,%eax
  10086c:	01 d0                	add    %edx,%eax
  10086e:	c1 e0 02             	shl    $0x2,%eax
  100871:	89 c2                	mov    %eax,%edx
  100873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100876:	01 d0                	add    %edx,%eax
  100878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10087c:	3c a0                	cmp    $0xa0,%al
  10087e:	74 c1                	je     100841 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100885:	c9                   	leave  
  100886:	c3                   	ret    

00100887 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100887:	55                   	push   %ebp
  100888:	89 e5                	mov    %esp,%ebp
  10088a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10088d:	c7 04 24 56 60 10 00 	movl   $0x106056,(%esp)
  100894:	e8 ba fa ff ff       	call   100353 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100899:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  1008a0:	00 
  1008a1:	c7 04 24 6f 60 10 00 	movl   $0x10606f,(%esp)
  1008a8:	e8 a6 fa ff ff       	call   100353 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1008ad:	c7 44 24 04 8b 5f 10 	movl   $0x105f8b,0x4(%esp)
  1008b4:	00 
  1008b5:	c7 04 24 87 60 10 00 	movl   $0x106087,(%esp)
  1008bc:	e8 92 fa ff ff       	call   100353 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008c1:	c7 44 24 04 36 7a 11 	movl   $0x117a36,0x4(%esp)
  1008c8:	00 
  1008c9:	c7 04 24 9f 60 10 00 	movl   $0x10609f,(%esp)
  1008d0:	e8 7e fa ff ff       	call   100353 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008d5:	c7 44 24 04 28 af 11 	movl   $0x11af28,0x4(%esp)
  1008dc:	00 
  1008dd:	c7 04 24 b7 60 10 00 	movl   $0x1060b7,(%esp)
  1008e4:	e8 6a fa ff ff       	call   100353 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008e9:	b8 28 af 11 00       	mov    $0x11af28,%eax
  1008ee:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f4:	b8 36 00 10 00       	mov    $0x100036,%eax
  1008f9:	29 c2                	sub    %eax,%edx
  1008fb:	89 d0                	mov    %edx,%eax
  1008fd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100903:	85 c0                	test   %eax,%eax
  100905:	0f 48 c2             	cmovs  %edx,%eax
  100908:	c1 f8 0a             	sar    $0xa,%eax
  10090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10090f:	c7 04 24 d0 60 10 00 	movl   $0x1060d0,(%esp)
  100916:	e8 38 fa ff ff       	call   100353 <cprintf>
}
  10091b:	c9                   	leave  
  10091c:	c3                   	ret    

0010091d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10091d:	55                   	push   %ebp
  10091e:	89 e5                	mov    %esp,%ebp
  100920:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100926:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100929:	89 44 24 04          	mov    %eax,0x4(%esp)
  10092d:	8b 45 08             	mov    0x8(%ebp),%eax
  100930:	89 04 24             	mov    %eax,(%esp)
  100933:	e8 12 fc ff ff       	call   10054a <debuginfo_eip>
  100938:	85 c0                	test   %eax,%eax
  10093a:	74 15                	je     100951 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10093c:	8b 45 08             	mov    0x8(%ebp),%eax
  10093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100943:	c7 04 24 fa 60 10 00 	movl   $0x1060fa,(%esp)
  10094a:	e8 04 fa ff ff       	call   100353 <cprintf>
  10094f:	eb 6d                	jmp    1009be <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100958:	eb 1c                	jmp    100976 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  10095a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100960:	01 d0                	add    %edx,%eax
  100962:	0f b6 00             	movzbl (%eax),%eax
  100965:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10096b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10096e:	01 ca                	add    %ecx,%edx
  100970:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100972:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100976:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100979:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10097c:	7f dc                	jg     10095a <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  10097e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100987:	01 d0                	add    %edx,%eax
  100989:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  10098c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10098f:	8b 55 08             	mov    0x8(%ebp),%edx
  100992:	89 d1                	mov    %edx,%ecx
  100994:	29 c1                	sub    %eax,%ecx
  100996:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100999:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10099c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1009a0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1009aa:	89 54 24 08          	mov    %edx,0x8(%esp)
  1009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b2:	c7 04 24 16 61 10 00 	movl   $0x106116,(%esp)
  1009b9:	e8 95 f9 ff ff       	call   100353 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  1009be:	c9                   	leave  
  1009bf:	c3                   	ret    

001009c0 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009c0:	55                   	push   %ebp
  1009c1:	89 e5                	mov    %esp,%ebp
  1009c3:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009c6:	8b 45 04             	mov    0x4(%ebp),%eax
  1009c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009cf:	c9                   	leave  
  1009d0:	c3                   	ret    

001009d1 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009d1:	55                   	push   %ebp
  1009d2:	89 e5                	mov    %esp,%ebp
  1009d4:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009d7:	89 e8                	mov    %ebp,%eax
  1009d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  1009df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1009e2:	e8 d9 ff ff ff       	call   1009c0 <read_eip>
  1009e7:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  1009ea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009f1:	e9 88 00 00 00       	jmp    100a7e <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  1009f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a00:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a04:	c7 04 24 28 61 10 00 	movl   $0x106128,(%esp)
  100a0b:	e8 43 f9 ff ff       	call   100353 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
  100a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a13:	83 c0 08             	add    $0x8,%eax
  100a16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100a19:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a20:	eb 25                	jmp    100a47 <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
  100a22:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a2f:	01 d0                	add    %edx,%eax
  100a31:	8b 00                	mov    (%eax),%eax
  100a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a37:	c7 04 24 44 61 10 00 	movl   $0x106144,(%esp)
  100a3e:	e8 10 f9 ff ff       	call   100353 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
  100a43:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100a47:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a4b:	7e d5                	jle    100a22 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
  100a4d:	c7 04 24 4c 61 10 00 	movl   $0x10614c,(%esp)
  100a54:	e8 fa f8 ff ff       	call   100353 <cprintf>
        print_debuginfo(eip - 1);
  100a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a5c:	83 e8 01             	sub    $0x1,%eax
  100a5f:	89 04 24             	mov    %eax,(%esp)
  100a62:	e8 b6 fe ff ff       	call   10091d <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a6a:	83 c0 04             	add    $0x4,%eax
  100a6d:	8b 00                	mov    (%eax),%eax
  100a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a75:	8b 00                	mov    (%eax),%eax
  100a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a7a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a82:	74 0a                	je     100a8e <print_stackframe+0xbd>
  100a84:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a88:	0f 8e 68 ff ff ff    	jle    1009f6 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100a8e:	c9                   	leave  
  100a8f:	c3                   	ret    

00100a90 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a90:	55                   	push   %ebp
  100a91:	89 e5                	mov    %esp,%ebp
  100a93:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9d:	eb 0c                	jmp    100aab <parse+0x1b>
            *buf ++ = '\0';
  100a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa2:	8d 50 01             	lea    0x1(%eax),%edx
  100aa5:	89 55 08             	mov    %edx,0x8(%ebp)
  100aa8:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aab:	8b 45 08             	mov    0x8(%ebp),%eax
  100aae:	0f b6 00             	movzbl (%eax),%eax
  100ab1:	84 c0                	test   %al,%al
  100ab3:	74 1d                	je     100ad2 <parse+0x42>
  100ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab8:	0f b6 00             	movzbl (%eax),%eax
  100abb:	0f be c0             	movsbl %al,%eax
  100abe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac2:	c7 04 24 d0 61 10 00 	movl   $0x1061d0,(%esp)
  100ac9:	e8 75 51 00 00       	call   105c43 <strchr>
  100ace:	85 c0                	test   %eax,%eax
  100ad0:	75 cd                	jne    100a9f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  100ad5:	0f b6 00             	movzbl (%eax),%eax
  100ad8:	84 c0                	test   %al,%al
  100ada:	75 02                	jne    100ade <parse+0x4e>
            break;
  100adc:	eb 67                	jmp    100b45 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ade:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ae2:	75 14                	jne    100af8 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ae4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100aeb:	00 
  100aec:	c7 04 24 d5 61 10 00 	movl   $0x1061d5,(%esp)
  100af3:	e8 5b f8 ff ff       	call   100353 <cprintf>
        }
        argv[argc ++] = buf;
  100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100afb:	8d 50 01             	lea    0x1(%eax),%edx
  100afe:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b0b:	01 c2                	add    %eax,%edx
  100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100b10:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b12:	eb 04                	jmp    100b18 <parse+0x88>
            buf ++;
  100b14:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b18:	8b 45 08             	mov    0x8(%ebp),%eax
  100b1b:	0f b6 00             	movzbl (%eax),%eax
  100b1e:	84 c0                	test   %al,%al
  100b20:	74 1d                	je     100b3f <parse+0xaf>
  100b22:	8b 45 08             	mov    0x8(%ebp),%eax
  100b25:	0f b6 00             	movzbl (%eax),%eax
  100b28:	0f be c0             	movsbl %al,%eax
  100b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b2f:	c7 04 24 d0 61 10 00 	movl   $0x1061d0,(%esp)
  100b36:	e8 08 51 00 00       	call   105c43 <strchr>
  100b3b:	85 c0                	test   %eax,%eax
  100b3d:	74 d5                	je     100b14 <parse+0x84>
            buf ++;
        }
    }
  100b3f:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b40:	e9 66 ff ff ff       	jmp    100aab <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b48:	c9                   	leave  
  100b49:	c3                   	ret    

00100b4a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b4a:	55                   	push   %ebp
  100b4b:	89 e5                	mov    %esp,%ebp
  100b4d:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b50:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b57:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5a:	89 04 24             	mov    %eax,(%esp)
  100b5d:	e8 2e ff ff ff       	call   100a90 <parse>
  100b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b69:	75 0a                	jne    100b75 <runcmd+0x2b>
        return 0;
  100b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  100b70:	e9 85 00 00 00       	jmp    100bfa <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b7c:	eb 5c                	jmp    100bda <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b7e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b84:	89 d0                	mov    %edx,%eax
  100b86:	01 c0                	add    %eax,%eax
  100b88:	01 d0                	add    %edx,%eax
  100b8a:	c1 e0 02             	shl    $0x2,%eax
  100b8d:	05 00 70 11 00       	add    $0x117000,%eax
  100b92:	8b 00                	mov    (%eax),%eax
  100b94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b98:	89 04 24             	mov    %eax,(%esp)
  100b9b:	e8 04 50 00 00       	call   105ba4 <strcmp>
  100ba0:	85 c0                	test   %eax,%eax
  100ba2:	75 32                	jne    100bd6 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100ba4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ba7:	89 d0                	mov    %edx,%eax
  100ba9:	01 c0                	add    %eax,%eax
  100bab:	01 d0                	add    %edx,%eax
  100bad:	c1 e0 02             	shl    $0x2,%eax
  100bb0:	05 00 70 11 00       	add    $0x117000,%eax
  100bb5:	8b 40 08             	mov    0x8(%eax),%eax
  100bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100bbb:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  100bc1:	89 54 24 08          	mov    %edx,0x8(%esp)
  100bc5:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100bc8:	83 c2 04             	add    $0x4,%edx
  100bcb:	89 54 24 04          	mov    %edx,0x4(%esp)
  100bcf:	89 0c 24             	mov    %ecx,(%esp)
  100bd2:	ff d0                	call   *%eax
  100bd4:	eb 24                	jmp    100bfa <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bdd:	83 f8 02             	cmp    $0x2,%eax
  100be0:	76 9c                	jbe    100b7e <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100be2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be9:	c7 04 24 f3 61 10 00 	movl   $0x1061f3,(%esp)
  100bf0:	e8 5e f7 ff ff       	call   100353 <cprintf>
    return 0;
  100bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bfa:	c9                   	leave  
  100bfb:	c3                   	ret    

00100bfc <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bfc:	55                   	push   %ebp
  100bfd:	89 e5                	mov    %esp,%ebp
  100bff:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c02:	c7 04 24 0c 62 10 00 	movl   $0x10620c,(%esp)
  100c09:	e8 45 f7 ff ff       	call   100353 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c0e:	c7 04 24 34 62 10 00 	movl   $0x106234,(%esp)
  100c15:	e8 39 f7 ff ff       	call   100353 <cprintf>

    if (tf != NULL) {
  100c1a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c1e:	74 0b                	je     100c2b <kmonitor+0x2f>
        print_trapframe(tf);
  100c20:	8b 45 08             	mov    0x8(%ebp),%eax
  100c23:	89 04 24             	mov    %eax,(%esp)
  100c26:	e8 e8 0d 00 00       	call   101a13 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c2b:	c7 04 24 59 62 10 00 	movl   $0x106259,(%esp)
  100c32:	e8 13 f6 ff ff       	call   10024a <readline>
  100c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c3e:	74 18                	je     100c58 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c40:	8b 45 08             	mov    0x8(%ebp),%eax
  100c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c4a:	89 04 24             	mov    %eax,(%esp)
  100c4d:	e8 f8 fe ff ff       	call   100b4a <runcmd>
  100c52:	85 c0                	test   %eax,%eax
  100c54:	79 02                	jns    100c58 <kmonitor+0x5c>
                break;
  100c56:	eb 02                	jmp    100c5a <kmonitor+0x5e>
            }
        }
    }
  100c58:	eb d1                	jmp    100c2b <kmonitor+0x2f>
}
  100c5a:	c9                   	leave  
  100c5b:	c3                   	ret    

00100c5c <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c5c:	55                   	push   %ebp
  100c5d:	89 e5                	mov    %esp,%ebp
  100c5f:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c69:	eb 3f                	jmp    100caa <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c6e:	89 d0                	mov    %edx,%eax
  100c70:	01 c0                	add    %eax,%eax
  100c72:	01 d0                	add    %edx,%eax
  100c74:	c1 e0 02             	shl    $0x2,%eax
  100c77:	05 00 70 11 00       	add    $0x117000,%eax
  100c7c:	8b 48 04             	mov    0x4(%eax),%ecx
  100c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c82:	89 d0                	mov    %edx,%eax
  100c84:	01 c0                	add    %eax,%eax
  100c86:	01 d0                	add    %edx,%eax
  100c88:	c1 e0 02             	shl    $0x2,%eax
  100c8b:	05 00 70 11 00       	add    $0x117000,%eax
  100c90:	8b 00                	mov    (%eax),%eax
  100c92:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c96:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c9a:	c7 04 24 5d 62 10 00 	movl   $0x10625d,(%esp)
  100ca1:	e8 ad f6 ff ff       	call   100353 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ca6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cad:	83 f8 02             	cmp    $0x2,%eax
  100cb0:	76 b9                	jbe    100c6b <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100cb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cb7:	c9                   	leave  
  100cb8:	c3                   	ret    

00100cb9 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cb9:	55                   	push   %ebp
  100cba:	89 e5                	mov    %esp,%ebp
  100cbc:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cbf:	e8 c3 fb ff ff       	call   100887 <print_kerninfo>
    return 0;
  100cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cc9:	c9                   	leave  
  100cca:	c3                   	ret    

00100ccb <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100ccb:	55                   	push   %ebp
  100ccc:	89 e5                	mov    %esp,%ebp
  100cce:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cd1:	e8 fb fc ff ff       	call   1009d1 <print_stackframe>
    return 0;
  100cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cdb:	c9                   	leave  
  100cdc:	c3                   	ret    

00100cdd <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cdd:	55                   	push   %ebp
  100cde:	89 e5                	mov    %esp,%ebp
  100ce0:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ce3:	a1 20 a4 11 00       	mov    0x11a420,%eax
  100ce8:	85 c0                	test   %eax,%eax
  100cea:	74 02                	je     100cee <__panic+0x11>
        goto panic_dead;
  100cec:	eb 59                	jmp    100d47 <__panic+0x6a>
    }
    is_panic = 1;
  100cee:	c7 05 20 a4 11 00 01 	movl   $0x1,0x11a420
  100cf5:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cf8:	8d 45 14             	lea    0x14(%ebp),%eax
  100cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d01:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d05:	8b 45 08             	mov    0x8(%ebp),%eax
  100d08:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d0c:	c7 04 24 66 62 10 00 	movl   $0x106266,(%esp)
  100d13:	e8 3b f6 ff ff       	call   100353 <cprintf>
    vcprintf(fmt, ap);
  100d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d1f:	8b 45 10             	mov    0x10(%ebp),%eax
  100d22:	89 04 24             	mov    %eax,(%esp)
  100d25:	e8 f6 f5 ff ff       	call   100320 <vcprintf>
    cprintf("\n");
  100d2a:	c7 04 24 82 62 10 00 	movl   $0x106282,(%esp)
  100d31:	e8 1d f6 ff ff       	call   100353 <cprintf>
    
    cprintf("stack trackback:\n");
  100d36:	c7 04 24 84 62 10 00 	movl   $0x106284,(%esp)
  100d3d:	e8 11 f6 ff ff       	call   100353 <cprintf>
    print_stackframe();
  100d42:	e8 8a fc ff ff       	call   1009d1 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d47:	e8 85 09 00 00       	call   1016d1 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d53:	e8 a4 fe ff ff       	call   100bfc <kmonitor>
    }
  100d58:	eb f2                	jmp    100d4c <__panic+0x6f>

00100d5a <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d5a:	55                   	push   %ebp
  100d5b:	89 e5                	mov    %esp,%ebp
  100d5d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d60:	8d 45 14             	lea    0x14(%ebp),%eax
  100d63:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d69:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  100d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d74:	c7 04 24 96 62 10 00 	movl   $0x106296,(%esp)
  100d7b:	e8 d3 f5 ff ff       	call   100353 <cprintf>
    vcprintf(fmt, ap);
  100d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d87:	8b 45 10             	mov    0x10(%ebp),%eax
  100d8a:	89 04 24             	mov    %eax,(%esp)
  100d8d:	e8 8e f5 ff ff       	call   100320 <vcprintf>
    cprintf("\n");
  100d92:	c7 04 24 82 62 10 00 	movl   $0x106282,(%esp)
  100d99:	e8 b5 f5 ff ff       	call   100353 <cprintf>
    va_end(ap);
}
  100d9e:	c9                   	leave  
  100d9f:	c3                   	ret    

00100da0 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100da0:	55                   	push   %ebp
  100da1:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100da3:	a1 20 a4 11 00       	mov    0x11a420,%eax
}
  100da8:	5d                   	pop    %ebp
  100da9:	c3                   	ret    

00100daa <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100daa:	55                   	push   %ebp
  100dab:	89 e5                	mov    %esp,%ebp
  100dad:	83 ec 28             	sub    $0x28,%esp
  100db0:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100db6:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dba:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100dbe:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dc2:	ee                   	out    %al,(%dx)
  100dc3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dc9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100dcd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dd1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dd5:	ee                   	out    %al,(%dx)
  100dd6:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100ddc:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100de0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100de4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100de8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100de9:	c7 05 0c af 11 00 00 	movl   $0x0,0x11af0c
  100df0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df3:	c7 04 24 b4 62 10 00 	movl   $0x1062b4,(%esp)
  100dfa:	e8 54 f5 ff ff       	call   100353 <cprintf>
    pic_enable(IRQ_TIMER);
  100dff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e06:	e8 24 09 00 00       	call   10172f <pic_enable>
}
  100e0b:	c9                   	leave  
  100e0c:	c3                   	ret    

00100e0d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e0d:	55                   	push   %ebp
  100e0e:	89 e5                	mov    %esp,%ebp
  100e10:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e13:	9c                   	pushf  
  100e14:	58                   	pop    %eax
  100e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e1b:	25 00 02 00 00       	and    $0x200,%eax
  100e20:	85 c0                	test   %eax,%eax
  100e22:	74 0c                	je     100e30 <__intr_save+0x23>
        intr_disable();
  100e24:	e8 a8 08 00 00       	call   1016d1 <intr_disable>
        return 1;
  100e29:	b8 01 00 00 00       	mov    $0x1,%eax
  100e2e:	eb 05                	jmp    100e35 <__intr_save+0x28>
    }
    return 0;
  100e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e35:	c9                   	leave  
  100e36:	c3                   	ret    

00100e37 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e37:	55                   	push   %ebp
  100e38:	89 e5                	mov    %esp,%ebp
  100e3a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e41:	74 05                	je     100e48 <__intr_restore+0x11>
        intr_enable();
  100e43:	e8 83 08 00 00       	call   1016cb <intr_enable>
    }
}
  100e48:	c9                   	leave  
  100e49:	c3                   	ret    

00100e4a <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e4a:	55                   	push   %ebp
  100e4b:	89 e5                	mov    %esp,%ebp
  100e4d:	83 ec 10             	sub    $0x10,%esp
  100e50:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e56:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e5a:	89 c2                	mov    %eax,%edx
  100e5c:	ec                   	in     (%dx),%al
  100e5d:	88 45 fd             	mov    %al,-0x3(%ebp)
  100e60:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e66:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e6a:	89 c2                	mov    %eax,%edx
  100e6c:	ec                   	in     (%dx),%al
  100e6d:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e70:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e76:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e7a:	89 c2                	mov    %eax,%edx
  100e7c:	ec                   	in     (%dx),%al
  100e7d:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e80:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e86:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e8a:	89 c2                	mov    %eax,%edx
  100e8c:	ec                   	in     (%dx),%al
  100e8d:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e90:	c9                   	leave  
  100e91:	c3                   	ret    

00100e92 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e92:	55                   	push   %ebp
  100e93:	89 e5                	mov    %esp,%ebp
  100e95:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e98:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea2:	0f b7 00             	movzwl (%eax),%eax
  100ea5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100ea9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eac:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb4:	0f b7 00             	movzwl (%eax),%eax
  100eb7:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100ebb:	74 12                	je     100ecf <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ebd:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ec4:	66 c7 05 46 a4 11 00 	movw   $0x3b4,0x11a446
  100ecb:	b4 03 
  100ecd:	eb 13                	jmp    100ee2 <cga_init+0x50>
    } else {
        *cp = was;
  100ecf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ed2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ed6:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ed9:	66 c7 05 46 a4 11 00 	movw   $0x3d4,0x11a446
  100ee0:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ee2:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100ee9:	0f b7 c0             	movzwl %ax,%eax
  100eec:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100ef0:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ef4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100ef8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100efc:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100efd:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f04:	83 c0 01             	add    $0x1,%eax
  100f07:	0f b7 c0             	movzwl %ax,%eax
  100f0a:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f0e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f12:	89 c2                	mov    %eax,%edx
  100f14:	ec                   	in     (%dx),%al
  100f15:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f18:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f1c:	0f b6 c0             	movzbl %al,%eax
  100f1f:	c1 e0 08             	shl    $0x8,%eax
  100f22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f25:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f2c:	0f b7 c0             	movzwl %ax,%eax
  100f2f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100f33:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f37:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f3b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f3f:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f40:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  100f47:	83 c0 01             	add    $0x1,%eax
  100f4a:	0f b7 c0             	movzwl %ax,%eax
  100f4d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f51:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100f55:	89 c2                	mov    %eax,%edx
  100f57:	ec                   	in     (%dx),%al
  100f58:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100f5b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f5f:	0f b6 c0             	movzbl %al,%eax
  100f62:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f68:	a3 40 a4 11 00       	mov    %eax,0x11a440
    crt_pos = pos;
  100f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f70:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
}
  100f76:	c9                   	leave  
  100f77:	c3                   	ret    

00100f78 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f78:	55                   	push   %ebp
  100f79:	89 e5                	mov    %esp,%ebp
  100f7b:	83 ec 48             	sub    $0x48,%esp
  100f7e:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f84:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f88:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f8c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f90:	ee                   	out    %al,(%dx)
  100f91:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f97:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f9b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f9f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100fa3:	ee                   	out    %al,(%dx)
  100fa4:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100faa:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100fae:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fb2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fb6:	ee                   	out    %al,(%dx)
  100fb7:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fbd:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100fc1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100fc5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fc9:	ee                   	out    %al,(%dx)
  100fca:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100fd0:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100fd4:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100fd8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100fdc:	ee                   	out    %al,(%dx)
  100fdd:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100fe3:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100fe7:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100feb:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fef:	ee                   	out    %al,(%dx)
  100ff0:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100ff6:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100ffa:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100ffe:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101002:	ee                   	out    %al,(%dx)
  101003:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101009:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  10100d:	89 c2                	mov    %eax,%edx
  10100f:	ec                   	in     (%dx),%al
  101010:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  101013:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101017:	3c ff                	cmp    $0xff,%al
  101019:	0f 95 c0             	setne  %al
  10101c:	0f b6 c0             	movzbl %al,%eax
  10101f:	a3 48 a4 11 00       	mov    %eax,0x11a448
  101024:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10102a:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  10102e:	89 c2                	mov    %eax,%edx
  101030:	ec                   	in     (%dx),%al
  101031:	88 45 d5             	mov    %al,-0x2b(%ebp)
  101034:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  10103a:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  10103e:	89 c2                	mov    %eax,%edx
  101040:	ec                   	in     (%dx),%al
  101041:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101044:	a1 48 a4 11 00       	mov    0x11a448,%eax
  101049:	85 c0                	test   %eax,%eax
  10104b:	74 0c                	je     101059 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  10104d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101054:	e8 d6 06 00 00       	call   10172f <pic_enable>
    }
}
  101059:	c9                   	leave  
  10105a:	c3                   	ret    

0010105b <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10105b:	55                   	push   %ebp
  10105c:	89 e5                	mov    %esp,%ebp
  10105e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101061:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101068:	eb 09                	jmp    101073 <lpt_putc_sub+0x18>
        delay();
  10106a:	e8 db fd ff ff       	call   100e4a <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10106f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101073:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101079:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10107d:	89 c2                	mov    %eax,%edx
  10107f:	ec                   	in     (%dx),%al
  101080:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101083:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101087:	84 c0                	test   %al,%al
  101089:	78 09                	js     101094 <lpt_putc_sub+0x39>
  10108b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101092:	7e d6                	jle    10106a <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101094:	8b 45 08             	mov    0x8(%ebp),%eax
  101097:	0f b6 c0             	movzbl %al,%eax
  10109a:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  1010a0:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010a3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010a7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010ab:	ee                   	out    %al,(%dx)
  1010ac:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010b2:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010b6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010ba:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010be:	ee                   	out    %al,(%dx)
  1010bf:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  1010c5:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  1010c9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010cd:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010d1:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010d2:	c9                   	leave  
  1010d3:	c3                   	ret    

001010d4 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010d4:	55                   	push   %ebp
  1010d5:	89 e5                	mov    %esp,%ebp
  1010d7:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010da:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010de:	74 0d                	je     1010ed <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1010e3:	89 04 24             	mov    %eax,(%esp)
  1010e6:	e8 70 ff ff ff       	call   10105b <lpt_putc_sub>
  1010eb:	eb 24                	jmp    101111 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  1010ed:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010f4:	e8 62 ff ff ff       	call   10105b <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010f9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101100:	e8 56 ff ff ff       	call   10105b <lpt_putc_sub>
        lpt_putc_sub('\b');
  101105:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10110c:	e8 4a ff ff ff       	call   10105b <lpt_putc_sub>
    }
}
  101111:	c9                   	leave  
  101112:	c3                   	ret    

00101113 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101113:	55                   	push   %ebp
  101114:	89 e5                	mov    %esp,%ebp
  101116:	53                   	push   %ebx
  101117:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10111a:	8b 45 08             	mov    0x8(%ebp),%eax
  10111d:	b0 00                	mov    $0x0,%al
  10111f:	85 c0                	test   %eax,%eax
  101121:	75 07                	jne    10112a <cga_putc+0x17>
        c |= 0x0700;
  101123:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10112a:	8b 45 08             	mov    0x8(%ebp),%eax
  10112d:	0f b6 c0             	movzbl %al,%eax
  101130:	83 f8 0a             	cmp    $0xa,%eax
  101133:	74 4c                	je     101181 <cga_putc+0x6e>
  101135:	83 f8 0d             	cmp    $0xd,%eax
  101138:	74 57                	je     101191 <cga_putc+0x7e>
  10113a:	83 f8 08             	cmp    $0x8,%eax
  10113d:	0f 85 88 00 00 00    	jne    1011cb <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  101143:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10114a:	66 85 c0             	test   %ax,%ax
  10114d:	74 30                	je     10117f <cga_putc+0x6c>
            crt_pos --;
  10114f:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101156:	83 e8 01             	sub    $0x1,%eax
  101159:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10115f:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101164:	0f b7 15 44 a4 11 00 	movzwl 0x11a444,%edx
  10116b:	0f b7 d2             	movzwl %dx,%edx
  10116e:	01 d2                	add    %edx,%edx
  101170:	01 c2                	add    %eax,%edx
  101172:	8b 45 08             	mov    0x8(%ebp),%eax
  101175:	b0 00                	mov    $0x0,%al
  101177:	83 c8 20             	or     $0x20,%eax
  10117a:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10117d:	eb 72                	jmp    1011f1 <cga_putc+0xde>
  10117f:	eb 70                	jmp    1011f1 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101181:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101188:	83 c0 50             	add    $0x50,%eax
  10118b:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101191:	0f b7 1d 44 a4 11 00 	movzwl 0x11a444,%ebx
  101198:	0f b7 0d 44 a4 11 00 	movzwl 0x11a444,%ecx
  10119f:	0f b7 c1             	movzwl %cx,%eax
  1011a2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1011a8:	c1 e8 10             	shr    $0x10,%eax
  1011ab:	89 c2                	mov    %eax,%edx
  1011ad:	66 c1 ea 06          	shr    $0x6,%dx
  1011b1:	89 d0                	mov    %edx,%eax
  1011b3:	c1 e0 02             	shl    $0x2,%eax
  1011b6:	01 d0                	add    %edx,%eax
  1011b8:	c1 e0 04             	shl    $0x4,%eax
  1011bb:	29 c1                	sub    %eax,%ecx
  1011bd:	89 ca                	mov    %ecx,%edx
  1011bf:	89 d8                	mov    %ebx,%eax
  1011c1:	29 d0                	sub    %edx,%eax
  1011c3:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
        break;
  1011c9:	eb 26                	jmp    1011f1 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011cb:	8b 0d 40 a4 11 00    	mov    0x11a440,%ecx
  1011d1:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011d8:	8d 50 01             	lea    0x1(%eax),%edx
  1011db:	66 89 15 44 a4 11 00 	mov    %dx,0x11a444
  1011e2:	0f b7 c0             	movzwl %ax,%eax
  1011e5:	01 c0                	add    %eax,%eax
  1011e7:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1011ed:	66 89 02             	mov    %ax,(%edx)
        break;
  1011f0:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011f1:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1011f8:	66 3d cf 07          	cmp    $0x7cf,%ax
  1011fc:	76 5b                	jbe    101259 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011fe:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101203:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101209:	a1 40 a4 11 00       	mov    0x11a440,%eax
  10120e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101215:	00 
  101216:	89 54 24 04          	mov    %edx,0x4(%esp)
  10121a:	89 04 24             	mov    %eax,(%esp)
  10121d:	e8 1f 4c 00 00       	call   105e41 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101222:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101229:	eb 15                	jmp    101240 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  10122b:	a1 40 a4 11 00       	mov    0x11a440,%eax
  101230:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101233:	01 d2                	add    %edx,%edx
  101235:	01 d0                	add    %edx,%eax
  101237:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10123c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101240:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101247:	7e e2                	jle    10122b <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101249:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  101250:	83 e8 50             	sub    $0x50,%eax
  101253:	66 a3 44 a4 11 00    	mov    %ax,0x11a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101259:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  101260:	0f b7 c0             	movzwl %ax,%eax
  101263:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101267:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  10126b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10126f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101273:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101274:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  10127b:	66 c1 e8 08          	shr    $0x8,%ax
  10127f:	0f b6 c0             	movzbl %al,%eax
  101282:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  101289:	83 c2 01             	add    $0x1,%edx
  10128c:	0f b7 d2             	movzwl %dx,%edx
  10128f:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101293:	88 45 ed             	mov    %al,-0x13(%ebp)
  101296:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10129a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10129e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10129f:	0f b7 05 46 a4 11 00 	movzwl 0x11a446,%eax
  1012a6:	0f b7 c0             	movzwl %ax,%eax
  1012a9:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  1012ad:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  1012b1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012b5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012b9:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012ba:	0f b7 05 44 a4 11 00 	movzwl 0x11a444,%eax
  1012c1:	0f b6 c0             	movzbl %al,%eax
  1012c4:	0f b7 15 46 a4 11 00 	movzwl 0x11a446,%edx
  1012cb:	83 c2 01             	add    $0x1,%edx
  1012ce:	0f b7 d2             	movzwl %dx,%edx
  1012d1:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  1012d5:	88 45 e5             	mov    %al,-0x1b(%ebp)
  1012d8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012dc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012e0:	ee                   	out    %al,(%dx)
}
  1012e1:	83 c4 34             	add    $0x34,%esp
  1012e4:	5b                   	pop    %ebx
  1012e5:	5d                   	pop    %ebp
  1012e6:	c3                   	ret    

001012e7 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012e7:	55                   	push   %ebp
  1012e8:	89 e5                	mov    %esp,%ebp
  1012ea:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012f4:	eb 09                	jmp    1012ff <serial_putc_sub+0x18>
        delay();
  1012f6:	e8 4f fb ff ff       	call   100e4a <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1012ff:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101305:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101309:	89 c2                	mov    %eax,%edx
  10130b:	ec                   	in     (%dx),%al
  10130c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10130f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101313:	0f b6 c0             	movzbl %al,%eax
  101316:	83 e0 20             	and    $0x20,%eax
  101319:	85 c0                	test   %eax,%eax
  10131b:	75 09                	jne    101326 <serial_putc_sub+0x3f>
  10131d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101324:	7e d0                	jle    1012f6 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101326:	8b 45 08             	mov    0x8(%ebp),%eax
  101329:	0f b6 c0             	movzbl %al,%eax
  10132c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101332:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101335:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101339:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10133d:	ee                   	out    %al,(%dx)
}
  10133e:	c9                   	leave  
  10133f:	c3                   	ret    

00101340 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101340:	55                   	push   %ebp
  101341:	89 e5                	mov    %esp,%ebp
  101343:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101346:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10134a:	74 0d                	je     101359 <serial_putc+0x19>
        serial_putc_sub(c);
  10134c:	8b 45 08             	mov    0x8(%ebp),%eax
  10134f:	89 04 24             	mov    %eax,(%esp)
  101352:	e8 90 ff ff ff       	call   1012e7 <serial_putc_sub>
  101357:	eb 24                	jmp    10137d <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  101359:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101360:	e8 82 ff ff ff       	call   1012e7 <serial_putc_sub>
        serial_putc_sub(' ');
  101365:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10136c:	e8 76 ff ff ff       	call   1012e7 <serial_putc_sub>
        serial_putc_sub('\b');
  101371:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101378:	e8 6a ff ff ff       	call   1012e7 <serial_putc_sub>
    }
}
  10137d:	c9                   	leave  
  10137e:	c3                   	ret    

0010137f <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10137f:	55                   	push   %ebp
  101380:	89 e5                	mov    %esp,%ebp
  101382:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101385:	eb 33                	jmp    1013ba <cons_intr+0x3b>
        if (c != 0) {
  101387:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10138b:	74 2d                	je     1013ba <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10138d:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101392:	8d 50 01             	lea    0x1(%eax),%edx
  101395:	89 15 64 a6 11 00    	mov    %edx,0x11a664
  10139b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10139e:	88 90 60 a4 11 00    	mov    %dl,0x11a460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013a4:	a1 64 a6 11 00       	mov    0x11a664,%eax
  1013a9:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013ae:	75 0a                	jne    1013ba <cons_intr+0x3b>
                cons.wpos = 0;
  1013b0:	c7 05 64 a6 11 00 00 	movl   $0x0,0x11a664
  1013b7:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1013bd:	ff d0                	call   *%eax
  1013bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013c6:	75 bf                	jne    101387 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013c8:	c9                   	leave  
  1013c9:	c3                   	ret    

001013ca <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013ca:	55                   	push   %ebp
  1013cb:	89 e5                	mov    %esp,%ebp
  1013cd:	83 ec 10             	sub    $0x10,%esp
  1013d0:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013d6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013da:	89 c2                	mov    %eax,%edx
  1013dc:	ec                   	in     (%dx),%al
  1013dd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013e0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013e4:	0f b6 c0             	movzbl %al,%eax
  1013e7:	83 e0 01             	and    $0x1,%eax
  1013ea:	85 c0                	test   %eax,%eax
  1013ec:	75 07                	jne    1013f5 <serial_proc_data+0x2b>
        return -1;
  1013ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f3:	eb 2a                	jmp    10141f <serial_proc_data+0x55>
  1013f5:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013fb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1013ff:	89 c2                	mov    %eax,%edx
  101401:	ec                   	in     (%dx),%al
  101402:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101405:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101409:	0f b6 c0             	movzbl %al,%eax
  10140c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10140f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101413:	75 07                	jne    10141c <serial_proc_data+0x52>
        c = '\b';
  101415:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10141c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10141f:	c9                   	leave  
  101420:	c3                   	ret    

00101421 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101421:	55                   	push   %ebp
  101422:	89 e5                	mov    %esp,%ebp
  101424:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101427:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10142c:	85 c0                	test   %eax,%eax
  10142e:	74 0c                	je     10143c <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  101430:	c7 04 24 ca 13 10 00 	movl   $0x1013ca,(%esp)
  101437:	e8 43 ff ff ff       	call   10137f <cons_intr>
    }
}
  10143c:	c9                   	leave  
  10143d:	c3                   	ret    

0010143e <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10143e:	55                   	push   %ebp
  10143f:	89 e5                	mov    %esp,%ebp
  101441:	83 ec 38             	sub    $0x38,%esp
  101444:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10144a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10144e:	89 c2                	mov    %eax,%edx
  101450:	ec                   	in     (%dx),%al
  101451:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101454:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101458:	0f b6 c0             	movzbl %al,%eax
  10145b:	83 e0 01             	and    $0x1,%eax
  10145e:	85 c0                	test   %eax,%eax
  101460:	75 0a                	jne    10146c <kbd_proc_data+0x2e>
        return -1;
  101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101467:	e9 59 01 00 00       	jmp    1015c5 <kbd_proc_data+0x187>
  10146c:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101472:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101476:	89 c2                	mov    %eax,%edx
  101478:	ec                   	in     (%dx),%al
  101479:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10147c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101480:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101483:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101487:	75 17                	jne    1014a0 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101489:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10148e:	83 c8 40             	or     $0x40,%eax
  101491:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  101496:	b8 00 00 00 00       	mov    $0x0,%eax
  10149b:	e9 25 01 00 00       	jmp    1015c5 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  1014a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a4:	84 c0                	test   %al,%al
  1014a6:	79 47                	jns    1014ef <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014a8:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014ad:	83 e0 40             	and    $0x40,%eax
  1014b0:	85 c0                	test   %eax,%eax
  1014b2:	75 09                	jne    1014bd <kbd_proc_data+0x7f>
  1014b4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b8:	83 e0 7f             	and    $0x7f,%eax
  1014bb:	eb 04                	jmp    1014c1 <kbd_proc_data+0x83>
  1014bd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c1:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014c4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c8:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  1014cf:	83 c8 40             	or     $0x40,%eax
  1014d2:	0f b6 c0             	movzbl %al,%eax
  1014d5:	f7 d0                	not    %eax
  1014d7:	89 c2                	mov    %eax,%edx
  1014d9:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014de:	21 d0                	and    %edx,%eax
  1014e0:	a3 68 a6 11 00       	mov    %eax,0x11a668
        return 0;
  1014e5:	b8 00 00 00 00       	mov    $0x0,%eax
  1014ea:	e9 d6 00 00 00       	jmp    1015c5 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1014ef:	a1 68 a6 11 00       	mov    0x11a668,%eax
  1014f4:	83 e0 40             	and    $0x40,%eax
  1014f7:	85 c0                	test   %eax,%eax
  1014f9:	74 11                	je     10150c <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014fb:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014ff:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101504:	83 e0 bf             	and    $0xffffffbf,%eax
  101507:	a3 68 a6 11 00       	mov    %eax,0x11a668
    }

    shift |= shiftcode[data];
  10150c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101510:	0f b6 80 40 70 11 00 	movzbl 0x117040(%eax),%eax
  101517:	0f b6 d0             	movzbl %al,%edx
  10151a:	a1 68 a6 11 00       	mov    0x11a668,%eax
  10151f:	09 d0                	or     %edx,%eax
  101521:	a3 68 a6 11 00       	mov    %eax,0x11a668
    shift ^= togglecode[data];
  101526:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10152a:	0f b6 80 40 71 11 00 	movzbl 0x117140(%eax),%eax
  101531:	0f b6 d0             	movzbl %al,%edx
  101534:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101539:	31 d0                	xor    %edx,%eax
  10153b:	a3 68 a6 11 00       	mov    %eax,0x11a668

    c = charcode[shift & (CTL | SHIFT)][data];
  101540:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101545:	83 e0 03             	and    $0x3,%eax
  101548:	8b 14 85 40 75 11 00 	mov    0x117540(,%eax,4),%edx
  10154f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101553:	01 d0                	add    %edx,%eax
  101555:	0f b6 00             	movzbl (%eax),%eax
  101558:	0f b6 c0             	movzbl %al,%eax
  10155b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  10155e:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101563:	83 e0 08             	and    $0x8,%eax
  101566:	85 c0                	test   %eax,%eax
  101568:	74 22                	je     10158c <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  10156a:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10156e:	7e 0c                	jle    10157c <kbd_proc_data+0x13e>
  101570:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101574:	7f 06                	jg     10157c <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101576:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10157a:	eb 10                	jmp    10158c <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10157c:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101580:	7e 0a                	jle    10158c <kbd_proc_data+0x14e>
  101582:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101586:	7f 04                	jg     10158c <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101588:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10158c:	a1 68 a6 11 00       	mov    0x11a668,%eax
  101591:	f7 d0                	not    %eax
  101593:	83 e0 06             	and    $0x6,%eax
  101596:	85 c0                	test   %eax,%eax
  101598:	75 28                	jne    1015c2 <kbd_proc_data+0x184>
  10159a:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015a1:	75 1f                	jne    1015c2 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1015a3:	c7 04 24 cf 62 10 00 	movl   $0x1062cf,(%esp)
  1015aa:	e8 a4 ed ff ff       	call   100353 <cprintf>
  1015af:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  1015b5:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015b9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  1015bd:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1015c1:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015c5:	c9                   	leave  
  1015c6:	c3                   	ret    

001015c7 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015c7:	55                   	push   %ebp
  1015c8:	89 e5                	mov    %esp,%ebp
  1015ca:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015cd:	c7 04 24 3e 14 10 00 	movl   $0x10143e,(%esp)
  1015d4:	e8 a6 fd ff ff       	call   10137f <cons_intr>
}
  1015d9:	c9                   	leave  
  1015da:	c3                   	ret    

001015db <kbd_init>:

static void
kbd_init(void) {
  1015db:	55                   	push   %ebp
  1015dc:	89 e5                	mov    %esp,%ebp
  1015de:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015e1:	e8 e1 ff ff ff       	call   1015c7 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015ed:	e8 3d 01 00 00       	call   10172f <pic_enable>
}
  1015f2:	c9                   	leave  
  1015f3:	c3                   	ret    

001015f4 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015f4:	55                   	push   %ebp
  1015f5:	89 e5                	mov    %esp,%ebp
  1015f7:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015fa:	e8 93 f8 ff ff       	call   100e92 <cga_init>
    serial_init();
  1015ff:	e8 74 f9 ff ff       	call   100f78 <serial_init>
    kbd_init();
  101604:	e8 d2 ff ff ff       	call   1015db <kbd_init>
    if (!serial_exists) {
  101609:	a1 48 a4 11 00       	mov    0x11a448,%eax
  10160e:	85 c0                	test   %eax,%eax
  101610:	75 0c                	jne    10161e <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101612:	c7 04 24 db 62 10 00 	movl   $0x1062db,(%esp)
  101619:	e8 35 ed ff ff       	call   100353 <cprintf>
    }
}
  10161e:	c9                   	leave  
  10161f:	c3                   	ret    

00101620 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101620:	55                   	push   %ebp
  101621:	89 e5                	mov    %esp,%ebp
  101623:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101626:	e8 e2 f7 ff ff       	call   100e0d <__intr_save>
  10162b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10162e:	8b 45 08             	mov    0x8(%ebp),%eax
  101631:	89 04 24             	mov    %eax,(%esp)
  101634:	e8 9b fa ff ff       	call   1010d4 <lpt_putc>
        cga_putc(c);
  101639:	8b 45 08             	mov    0x8(%ebp),%eax
  10163c:	89 04 24             	mov    %eax,(%esp)
  10163f:	e8 cf fa ff ff       	call   101113 <cga_putc>
        serial_putc(c);
  101644:	8b 45 08             	mov    0x8(%ebp),%eax
  101647:	89 04 24             	mov    %eax,(%esp)
  10164a:	e8 f1 fc ff ff       	call   101340 <serial_putc>
    }
    local_intr_restore(intr_flag);
  10164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101652:	89 04 24             	mov    %eax,(%esp)
  101655:	e8 dd f7 ff ff       	call   100e37 <__intr_restore>
}
  10165a:	c9                   	leave  
  10165b:	c3                   	ret    

0010165c <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10165c:	55                   	push   %ebp
  10165d:	89 e5                	mov    %esp,%ebp
  10165f:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101669:	e8 9f f7 ff ff       	call   100e0d <__intr_save>
  10166e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101671:	e8 ab fd ff ff       	call   101421 <serial_intr>
        kbd_intr();
  101676:	e8 4c ff ff ff       	call   1015c7 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10167b:	8b 15 60 a6 11 00    	mov    0x11a660,%edx
  101681:	a1 64 a6 11 00       	mov    0x11a664,%eax
  101686:	39 c2                	cmp    %eax,%edx
  101688:	74 31                	je     1016bb <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  10168a:	a1 60 a6 11 00       	mov    0x11a660,%eax
  10168f:	8d 50 01             	lea    0x1(%eax),%edx
  101692:	89 15 60 a6 11 00    	mov    %edx,0x11a660
  101698:	0f b6 80 60 a4 11 00 	movzbl 0x11a460(%eax),%eax
  10169f:	0f b6 c0             	movzbl %al,%eax
  1016a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016a5:	a1 60 a6 11 00       	mov    0x11a660,%eax
  1016aa:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016af:	75 0a                	jne    1016bb <cons_getc+0x5f>
                cons.rpos = 0;
  1016b1:	c7 05 60 a6 11 00 00 	movl   $0x0,0x11a660
  1016b8:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016be:	89 04 24             	mov    %eax,(%esp)
  1016c1:	e8 71 f7 ff ff       	call   100e37 <__intr_restore>
    return c;
  1016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016c9:	c9                   	leave  
  1016ca:	c3                   	ret    

001016cb <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1016cb:	55                   	push   %ebp
  1016cc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  1016ce:	fb                   	sti    
    sti();
}
  1016cf:	5d                   	pop    %ebp
  1016d0:	c3                   	ret    

001016d1 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1016d1:	55                   	push   %ebp
  1016d2:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  1016d4:	fa                   	cli    
    cli();
}
  1016d5:	5d                   	pop    %ebp
  1016d6:	c3                   	ret    

001016d7 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016d7:	55                   	push   %ebp
  1016d8:	89 e5                	mov    %esp,%ebp
  1016da:	83 ec 14             	sub    $0x14,%esp
  1016dd:	8b 45 08             	mov    0x8(%ebp),%eax
  1016e0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016e4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016e8:	66 a3 50 75 11 00    	mov    %ax,0x117550
    if (did_init) {
  1016ee:	a1 6c a6 11 00       	mov    0x11a66c,%eax
  1016f3:	85 c0                	test   %eax,%eax
  1016f5:	74 36                	je     10172d <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  1016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016fb:	0f b6 c0             	movzbl %al,%eax
  1016fe:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101704:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101707:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10170b:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10170f:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101710:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101714:	66 c1 e8 08          	shr    $0x8,%ax
  101718:	0f b6 c0             	movzbl %al,%eax
  10171b:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101721:	88 45 f9             	mov    %al,-0x7(%ebp)
  101724:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101728:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10172c:	ee                   	out    %al,(%dx)
    }
}
  10172d:	c9                   	leave  
  10172e:	c3                   	ret    

0010172f <pic_enable>:

void
pic_enable(unsigned int irq) {
  10172f:	55                   	push   %ebp
  101730:	89 e5                	mov    %esp,%ebp
  101732:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101735:	8b 45 08             	mov    0x8(%ebp),%eax
  101738:	ba 01 00 00 00       	mov    $0x1,%edx
  10173d:	89 c1                	mov    %eax,%ecx
  10173f:	d3 e2                	shl    %cl,%edx
  101741:	89 d0                	mov    %edx,%eax
  101743:	f7 d0                	not    %eax
  101745:	89 c2                	mov    %eax,%edx
  101747:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10174e:	21 d0                	and    %edx,%eax
  101750:	0f b7 c0             	movzwl %ax,%eax
  101753:	89 04 24             	mov    %eax,(%esp)
  101756:	e8 7c ff ff ff       	call   1016d7 <pic_setmask>
}
  10175b:	c9                   	leave  
  10175c:	c3                   	ret    

0010175d <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  10175d:	55                   	push   %ebp
  10175e:	89 e5                	mov    %esp,%ebp
  101760:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101763:	c7 05 6c a6 11 00 01 	movl   $0x1,0x11a66c
  10176a:	00 00 00 
  10176d:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101773:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  101777:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10177b:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10177f:	ee                   	out    %al,(%dx)
  101780:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101786:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  10178a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10178e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101792:	ee                   	out    %al,(%dx)
  101793:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101799:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  10179d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1017a1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017a5:	ee                   	out    %al,(%dx)
  1017a6:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  1017ac:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  1017b0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1017b4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017b8:	ee                   	out    %al,(%dx)
  1017b9:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  1017bf:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  1017c3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1017c7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017cb:	ee                   	out    %al,(%dx)
  1017cc:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  1017d2:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  1017d6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1017da:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017de:	ee                   	out    %al,(%dx)
  1017df:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017e5:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  1017e9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1017ed:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017f1:	ee                   	out    %al,(%dx)
  1017f2:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  1017f8:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  1017fc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101800:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101804:	ee                   	out    %al,(%dx)
  101805:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  10180b:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  10180f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101813:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101817:	ee                   	out    %al,(%dx)
  101818:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  10181e:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101822:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101826:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10182a:	ee                   	out    %al,(%dx)
  10182b:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  101831:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  101835:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101839:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10183d:	ee                   	out    %al,(%dx)
  10183e:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101844:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  101848:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10184c:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101850:	ee                   	out    %al,(%dx)
  101851:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  101857:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  10185b:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10185f:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101863:	ee                   	out    %al,(%dx)
  101864:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  10186a:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  10186e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101872:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101876:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101877:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10187e:	66 83 f8 ff          	cmp    $0xffff,%ax
  101882:	74 12                	je     101896 <pic_init+0x139>
        pic_setmask(irq_mask);
  101884:	0f b7 05 50 75 11 00 	movzwl 0x117550,%eax
  10188b:	0f b7 c0             	movzwl %ax,%eax
  10188e:	89 04 24             	mov    %eax,(%esp)
  101891:	e8 41 fe ff ff       	call   1016d7 <pic_setmask>
    }
}
  101896:	c9                   	leave  
  101897:	c3                   	ret    

00101898 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101898:	55                   	push   %ebp
  101899:	89 e5                	mov    %esp,%ebp
  10189b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10189e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018a5:	00 
  1018a6:	c7 04 24 00 63 10 00 	movl   $0x106300,(%esp)
  1018ad:	e8 a1 ea ff ff       	call   100353 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  1018b2:	c7 04 24 0a 63 10 00 	movl   $0x10630a,(%esp)
  1018b9:	e8 95 ea ff ff       	call   100353 <cprintf>
    panic("EOT: kernel seems ok.");
  1018be:	c7 44 24 08 18 63 10 	movl   $0x106318,0x8(%esp)
  1018c5:	00 
  1018c6:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018cd:	00 
  1018ce:	c7 04 24 2e 63 10 00 	movl   $0x10632e,(%esp)
  1018d5:	e8 03 f4 ff ff       	call   100cdd <__panic>

001018da <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018da:	55                   	push   %ebp
  1018db:	89 e5                	mov    %esp,%ebp
  1018dd:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018e7:	e9 c3 00 00 00       	jmp    1019af <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ef:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  1018f6:	89 c2                	mov    %eax,%edx
  1018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018fb:	66 89 14 c5 80 a6 11 	mov    %dx,0x11a680(,%eax,8)
  101902:	00 
  101903:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101906:	66 c7 04 c5 82 a6 11 	movw   $0x8,0x11a682(,%eax,8)
  10190d:	00 08 00 
  101910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101913:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  10191a:	00 
  10191b:	83 e2 e0             	and    $0xffffffe0,%edx
  10191e:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  101925:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101928:	0f b6 14 c5 84 a6 11 	movzbl 0x11a684(,%eax,8),%edx
  10192f:	00 
  101930:	83 e2 1f             	and    $0x1f,%edx
  101933:	88 14 c5 84 a6 11 00 	mov    %dl,0x11a684(,%eax,8)
  10193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10193d:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101944:	00 
  101945:	83 e2 f0             	and    $0xfffffff0,%edx
  101948:	83 ca 0e             	or     $0xe,%edx
  10194b:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101952:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101955:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  10195c:	00 
  10195d:	83 e2 ef             	and    $0xffffffef,%edx
  101960:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101967:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196a:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101971:	00 
  101972:	83 e2 9f             	and    $0xffffff9f,%edx
  101975:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  10197c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197f:	0f b6 14 c5 85 a6 11 	movzbl 0x11a685(,%eax,8),%edx
  101986:	00 
  101987:	83 ca 80             	or     $0xffffff80,%edx
  10198a:	88 14 c5 85 a6 11 00 	mov    %dl,0x11a685(,%eax,8)
  101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101994:	8b 04 85 e0 75 11 00 	mov    0x1175e0(,%eax,4),%eax
  10199b:	c1 e8 10             	shr    $0x10,%eax
  10199e:	89 c2                	mov    %eax,%edx
  1019a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a3:	66 89 14 c5 86 a6 11 	mov    %dx,0x11a686(,%eax,8)
  1019aa:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1019ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1019af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019b7:	0f 86 2f ff ff ff    	jbe    1018ec <idt_init+0x12>
  1019bd:	c7 45 f8 60 75 11 00 	movl   $0x117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  1019c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019c7:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
  1019ca:	c9                   	leave  
  1019cb:	c3                   	ret    

001019cc <trapname>:

static const char *
trapname(int trapno) {
  1019cc:	55                   	push   %ebp
  1019cd:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1019d2:	83 f8 13             	cmp    $0x13,%eax
  1019d5:	77 0c                	ja     1019e3 <trapname+0x17>
        return excnames[trapno];
  1019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1019da:	8b 04 85 80 66 10 00 	mov    0x106680(,%eax,4),%eax
  1019e1:	eb 18                	jmp    1019fb <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019e3:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019e7:	7e 0d                	jle    1019f6 <trapname+0x2a>
  1019e9:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019ed:	7f 07                	jg     1019f6 <trapname+0x2a>
        return "Hardware Interrupt";
  1019ef:	b8 3f 63 10 00       	mov    $0x10633f,%eax
  1019f4:	eb 05                	jmp    1019fb <trapname+0x2f>
    }
    return "(unknown trap)";
  1019f6:	b8 52 63 10 00       	mov    $0x106352,%eax
}
  1019fb:	5d                   	pop    %ebp
  1019fc:	c3                   	ret    

001019fd <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019fd:	55                   	push   %ebp
  1019fe:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101a00:	8b 45 08             	mov    0x8(%ebp),%eax
  101a03:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101a07:	66 83 f8 08          	cmp    $0x8,%ax
  101a0b:	0f 94 c0             	sete   %al
  101a0e:	0f b6 c0             	movzbl %al,%eax
}
  101a11:	5d                   	pop    %ebp
  101a12:	c3                   	ret    

00101a13 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a13:	55                   	push   %ebp
  101a14:	89 e5                	mov    %esp,%ebp
  101a16:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a19:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a20:	c7 04 24 93 63 10 00 	movl   $0x106393,(%esp)
  101a27:	e8 27 e9 ff ff       	call   100353 <cprintf>
    print_regs(&tf->tf_regs);
  101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a2f:	89 04 24             	mov    %eax,(%esp)
  101a32:	e8 a1 01 00 00       	call   101bd8 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a37:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3a:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a3e:	0f b7 c0             	movzwl %ax,%eax
  101a41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a45:	c7 04 24 a4 63 10 00 	movl   $0x1063a4,(%esp)
  101a4c:	e8 02 e9 ff ff       	call   100353 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a51:	8b 45 08             	mov    0x8(%ebp),%eax
  101a54:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a58:	0f b7 c0             	movzwl %ax,%eax
  101a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5f:	c7 04 24 b7 63 10 00 	movl   $0x1063b7,(%esp)
  101a66:	e8 e8 e8 ff ff       	call   100353 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6e:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a72:	0f b7 c0             	movzwl %ax,%eax
  101a75:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a79:	c7 04 24 ca 63 10 00 	movl   $0x1063ca,(%esp)
  101a80:	e8 ce e8 ff ff       	call   100353 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a85:	8b 45 08             	mov    0x8(%ebp),%eax
  101a88:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a8c:	0f b7 c0             	movzwl %ax,%eax
  101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a93:	c7 04 24 dd 63 10 00 	movl   $0x1063dd,(%esp)
  101a9a:	e8 b4 e8 ff ff       	call   100353 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa2:	8b 40 30             	mov    0x30(%eax),%eax
  101aa5:	89 04 24             	mov    %eax,(%esp)
  101aa8:	e8 1f ff ff ff       	call   1019cc <trapname>
  101aad:	8b 55 08             	mov    0x8(%ebp),%edx
  101ab0:	8b 52 30             	mov    0x30(%edx),%edx
  101ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
  101ab7:	89 54 24 04          	mov    %edx,0x4(%esp)
  101abb:	c7 04 24 f0 63 10 00 	movl   $0x1063f0,(%esp)
  101ac2:	e8 8c e8 ff ff       	call   100353 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aca:	8b 40 34             	mov    0x34(%eax),%eax
  101acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad1:	c7 04 24 02 64 10 00 	movl   $0x106402,(%esp)
  101ad8:	e8 76 e8 ff ff       	call   100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101add:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae0:	8b 40 38             	mov    0x38(%eax),%eax
  101ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae7:	c7 04 24 11 64 10 00 	movl   $0x106411,(%esp)
  101aee:	e8 60 e8 ff ff       	call   100353 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101af3:	8b 45 08             	mov    0x8(%ebp),%eax
  101af6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101afa:	0f b7 c0             	movzwl %ax,%eax
  101afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b01:	c7 04 24 20 64 10 00 	movl   $0x106420,(%esp)
  101b08:	e8 46 e8 ff ff       	call   100353 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b10:	8b 40 40             	mov    0x40(%eax),%eax
  101b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b17:	c7 04 24 33 64 10 00 	movl   $0x106433,(%esp)
  101b1e:	e8 30 e8 ff ff       	call   100353 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b2a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b31:	eb 3e                	jmp    101b71 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b33:	8b 45 08             	mov    0x8(%ebp),%eax
  101b36:	8b 50 40             	mov    0x40(%eax),%edx
  101b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b3c:	21 d0                	and    %edx,%eax
  101b3e:	85 c0                	test   %eax,%eax
  101b40:	74 28                	je     101b6a <print_trapframe+0x157>
  101b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b45:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b4c:	85 c0                	test   %eax,%eax
  101b4e:	74 1a                	je     101b6a <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b53:	8b 04 85 80 75 11 00 	mov    0x117580(,%eax,4),%eax
  101b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5e:	c7 04 24 42 64 10 00 	movl   $0x106442,(%esp)
  101b65:	e8 e9 e7 ff ff       	call   100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b6e:	d1 65 f0             	shll   -0x10(%ebp)
  101b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b74:	83 f8 17             	cmp    $0x17,%eax
  101b77:	76 ba                	jbe    101b33 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b79:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7c:	8b 40 40             	mov    0x40(%eax),%eax
  101b7f:	25 00 30 00 00       	and    $0x3000,%eax
  101b84:	c1 e8 0c             	shr    $0xc,%eax
  101b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b8b:	c7 04 24 46 64 10 00 	movl   $0x106446,(%esp)
  101b92:	e8 bc e7 ff ff       	call   100353 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b97:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9a:	89 04 24             	mov    %eax,(%esp)
  101b9d:	e8 5b fe ff ff       	call   1019fd <trap_in_kernel>
  101ba2:	85 c0                	test   %eax,%eax
  101ba4:	75 30                	jne    101bd6 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba9:	8b 40 44             	mov    0x44(%eax),%eax
  101bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb0:	c7 04 24 4f 64 10 00 	movl   $0x10644f,(%esp)
  101bb7:	e8 97 e7 ff ff       	call   100353 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbf:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bc3:	0f b7 c0             	movzwl %ax,%eax
  101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bca:	c7 04 24 5e 64 10 00 	movl   $0x10645e,(%esp)
  101bd1:	e8 7d e7 ff ff       	call   100353 <cprintf>
    }
}
  101bd6:	c9                   	leave  
  101bd7:	c3                   	ret    

00101bd8 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bd8:	55                   	push   %ebp
  101bd9:	89 e5                	mov    %esp,%ebp
  101bdb:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bde:	8b 45 08             	mov    0x8(%ebp),%eax
  101be1:	8b 00                	mov    (%eax),%eax
  101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be7:	c7 04 24 71 64 10 00 	movl   $0x106471,(%esp)
  101bee:	e8 60 e7 ff ff       	call   100353 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf6:	8b 40 04             	mov    0x4(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 80 64 10 00 	movl   $0x106480,(%esp)
  101c04:	e8 4a e7 ff ff       	call   100353 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	8b 40 08             	mov    0x8(%eax),%eax
  101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c13:	c7 04 24 8f 64 10 00 	movl   $0x10648f,(%esp)
  101c1a:	e8 34 e7 ff ff       	call   100353 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c22:	8b 40 0c             	mov    0xc(%eax),%eax
  101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c29:	c7 04 24 9e 64 10 00 	movl   $0x10649e,(%esp)
  101c30:	e8 1e e7 ff ff       	call   100353 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c35:	8b 45 08             	mov    0x8(%ebp),%eax
  101c38:	8b 40 10             	mov    0x10(%eax),%eax
  101c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3f:	c7 04 24 ad 64 10 00 	movl   $0x1064ad,(%esp)
  101c46:	e8 08 e7 ff ff       	call   100353 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4e:	8b 40 14             	mov    0x14(%eax),%eax
  101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c55:	c7 04 24 bc 64 10 00 	movl   $0x1064bc,(%esp)
  101c5c:	e8 f2 e6 ff ff       	call   100353 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c61:	8b 45 08             	mov    0x8(%ebp),%eax
  101c64:	8b 40 18             	mov    0x18(%eax),%eax
  101c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6b:	c7 04 24 cb 64 10 00 	movl   $0x1064cb,(%esp)
  101c72:	e8 dc e6 ff ff       	call   100353 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c77:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7a:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c81:	c7 04 24 da 64 10 00 	movl   $0x1064da,(%esp)
  101c88:	e8 c6 e6 ff ff       	call   100353 <cprintf>
}
  101c8d:	c9                   	leave  
  101c8e:	c3                   	ret    

00101c8f <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c8f:	55                   	push   %ebp
  101c90:	89 e5                	mov    %esp,%ebp
  101c92:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c95:	8b 45 08             	mov    0x8(%ebp),%eax
  101c98:	8b 40 30             	mov    0x30(%eax),%eax
  101c9b:	83 f8 2f             	cmp    $0x2f,%eax
  101c9e:	77 21                	ja     101cc1 <trap_dispatch+0x32>
  101ca0:	83 f8 2e             	cmp    $0x2e,%eax
  101ca3:	0f 83 04 01 00 00    	jae    101dad <trap_dispatch+0x11e>
  101ca9:	83 f8 21             	cmp    $0x21,%eax
  101cac:	0f 84 81 00 00 00    	je     101d33 <trap_dispatch+0xa4>
  101cb2:	83 f8 24             	cmp    $0x24,%eax
  101cb5:	74 56                	je     101d0d <trap_dispatch+0x7e>
  101cb7:	83 f8 20             	cmp    $0x20,%eax
  101cba:	74 16                	je     101cd2 <trap_dispatch+0x43>
  101cbc:	e9 b4 00 00 00       	jmp    101d75 <trap_dispatch+0xe6>
  101cc1:	83 e8 78             	sub    $0x78,%eax
  101cc4:	83 f8 01             	cmp    $0x1,%eax
  101cc7:	0f 87 a8 00 00 00    	ja     101d75 <trap_dispatch+0xe6>
  101ccd:	e9 87 00 00 00       	jmp    101d59 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101cd2:	a1 0c af 11 00       	mov    0x11af0c,%eax
  101cd7:	83 c0 01             	add    $0x1,%eax
  101cda:	a3 0c af 11 00       	mov    %eax,0x11af0c
        if (ticks % TICK_NUM == 0) {
  101cdf:	8b 0d 0c af 11 00    	mov    0x11af0c,%ecx
  101ce5:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cea:	89 c8                	mov    %ecx,%eax
  101cec:	f7 e2                	mul    %edx
  101cee:	89 d0                	mov    %edx,%eax
  101cf0:	c1 e8 05             	shr    $0x5,%eax
  101cf3:	6b c0 64             	imul   $0x64,%eax,%eax
  101cf6:	29 c1                	sub    %eax,%ecx
  101cf8:	89 c8                	mov    %ecx,%eax
  101cfa:	85 c0                	test   %eax,%eax
  101cfc:	75 0a                	jne    101d08 <trap_dispatch+0x79>
            print_ticks();
  101cfe:	e8 95 fb ff ff       	call   101898 <print_ticks>
        }
        break;
  101d03:	e9 a6 00 00 00       	jmp    101dae <trap_dispatch+0x11f>
  101d08:	e9 a1 00 00 00       	jmp    101dae <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d0d:	e8 4a f9 ff ff       	call   10165c <cons_getc>
  101d12:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d15:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d19:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d1d:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d25:	c7 04 24 e9 64 10 00 	movl   $0x1064e9,(%esp)
  101d2c:	e8 22 e6 ff ff       	call   100353 <cprintf>
        break;
  101d31:	eb 7b                	jmp    101dae <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d33:	e8 24 f9 ff ff       	call   10165c <cons_getc>
  101d38:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d3b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d3f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d43:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d4b:	c7 04 24 fb 64 10 00 	movl   $0x1064fb,(%esp)
  101d52:	e8 fc e5 ff ff       	call   100353 <cprintf>
        break;
  101d57:	eb 55                	jmp    101dae <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d59:	c7 44 24 08 0a 65 10 	movl   $0x10650a,0x8(%esp)
  101d60:	00 
  101d61:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101d68:	00 
  101d69:	c7 04 24 2e 63 10 00 	movl   $0x10632e,(%esp)
  101d70:	e8 68 ef ff ff       	call   100cdd <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d75:	8b 45 08             	mov    0x8(%ebp),%eax
  101d78:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d7c:	0f b7 c0             	movzwl %ax,%eax
  101d7f:	83 e0 03             	and    $0x3,%eax
  101d82:	85 c0                	test   %eax,%eax
  101d84:	75 28                	jne    101dae <trap_dispatch+0x11f>
            print_trapframe(tf);
  101d86:	8b 45 08             	mov    0x8(%ebp),%eax
  101d89:	89 04 24             	mov    %eax,(%esp)
  101d8c:	e8 82 fc ff ff       	call   101a13 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d91:	c7 44 24 08 1a 65 10 	movl   $0x10651a,0x8(%esp)
  101d98:	00 
  101d99:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  101da0:	00 
  101da1:	c7 04 24 2e 63 10 00 	movl   $0x10632e,(%esp)
  101da8:	e8 30 ef ff ff       	call   100cdd <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101dad:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101dae:	c9                   	leave  
  101daf:	c3                   	ret    

00101db0 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101db0:	55                   	push   %ebp
  101db1:	89 e5                	mov    %esp,%ebp
  101db3:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101db6:	8b 45 08             	mov    0x8(%ebp),%eax
  101db9:	89 04 24             	mov    %eax,(%esp)
  101dbc:	e8 ce fe ff ff       	call   101c8f <trap_dispatch>
}
  101dc1:	c9                   	leave  
  101dc2:	c3                   	ret    

00101dc3 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101dc3:	1e                   	push   %ds
    pushl %es
  101dc4:	06                   	push   %es
    pushl %fs
  101dc5:	0f a0                	push   %fs
    pushl %gs
  101dc7:	0f a8                	push   %gs
    pushal
  101dc9:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101dca:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101dcf:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101dd1:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101dd3:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101dd4:	e8 d7 ff ff ff       	call   101db0 <trap>

    # pop the pushed stack pointer
    popl %esp
  101dd9:	5c                   	pop    %esp

00101dda <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101dda:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101ddb:	0f a9                	pop    %gs
    popl %fs
  101ddd:	0f a1                	pop    %fs
    popl %es
  101ddf:	07                   	pop    %es
    popl %ds
  101de0:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101de1:	83 c4 08             	add    $0x8,%esp
    iret
  101de4:	cf                   	iret   

00101de5 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101de5:	6a 00                	push   $0x0
  pushl $0
  101de7:	6a 00                	push   $0x0
  jmp __alltraps
  101de9:	e9 d5 ff ff ff       	jmp    101dc3 <__alltraps>

00101dee <vector1>:
.globl vector1
vector1:
  pushl $0
  101dee:	6a 00                	push   $0x0
  pushl $1
  101df0:	6a 01                	push   $0x1
  jmp __alltraps
  101df2:	e9 cc ff ff ff       	jmp    101dc3 <__alltraps>

00101df7 <vector2>:
.globl vector2
vector2:
  pushl $0
  101df7:	6a 00                	push   $0x0
  pushl $2
  101df9:	6a 02                	push   $0x2
  jmp __alltraps
  101dfb:	e9 c3 ff ff ff       	jmp    101dc3 <__alltraps>

00101e00 <vector3>:
.globl vector3
vector3:
  pushl $0
  101e00:	6a 00                	push   $0x0
  pushl $3
  101e02:	6a 03                	push   $0x3
  jmp __alltraps
  101e04:	e9 ba ff ff ff       	jmp    101dc3 <__alltraps>

00101e09 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e09:	6a 00                	push   $0x0
  pushl $4
  101e0b:	6a 04                	push   $0x4
  jmp __alltraps
  101e0d:	e9 b1 ff ff ff       	jmp    101dc3 <__alltraps>

00101e12 <vector5>:
.globl vector5
vector5:
  pushl $0
  101e12:	6a 00                	push   $0x0
  pushl $5
  101e14:	6a 05                	push   $0x5
  jmp __alltraps
  101e16:	e9 a8 ff ff ff       	jmp    101dc3 <__alltraps>

00101e1b <vector6>:
.globl vector6
vector6:
  pushl $0
  101e1b:	6a 00                	push   $0x0
  pushl $6
  101e1d:	6a 06                	push   $0x6
  jmp __alltraps
  101e1f:	e9 9f ff ff ff       	jmp    101dc3 <__alltraps>

00101e24 <vector7>:
.globl vector7
vector7:
  pushl $0
  101e24:	6a 00                	push   $0x0
  pushl $7
  101e26:	6a 07                	push   $0x7
  jmp __alltraps
  101e28:	e9 96 ff ff ff       	jmp    101dc3 <__alltraps>

00101e2d <vector8>:
.globl vector8
vector8:
  pushl $8
  101e2d:	6a 08                	push   $0x8
  jmp __alltraps
  101e2f:	e9 8f ff ff ff       	jmp    101dc3 <__alltraps>

00101e34 <vector9>:
.globl vector9
vector9:
  pushl $0
  101e34:	6a 00                	push   $0x0
  pushl $9
  101e36:	6a 09                	push   $0x9
  jmp __alltraps
  101e38:	e9 86 ff ff ff       	jmp    101dc3 <__alltraps>

00101e3d <vector10>:
.globl vector10
vector10:
  pushl $10
  101e3d:	6a 0a                	push   $0xa
  jmp __alltraps
  101e3f:	e9 7f ff ff ff       	jmp    101dc3 <__alltraps>

00101e44 <vector11>:
.globl vector11
vector11:
  pushl $11
  101e44:	6a 0b                	push   $0xb
  jmp __alltraps
  101e46:	e9 78 ff ff ff       	jmp    101dc3 <__alltraps>

00101e4b <vector12>:
.globl vector12
vector12:
  pushl $12
  101e4b:	6a 0c                	push   $0xc
  jmp __alltraps
  101e4d:	e9 71 ff ff ff       	jmp    101dc3 <__alltraps>

00101e52 <vector13>:
.globl vector13
vector13:
  pushl $13
  101e52:	6a 0d                	push   $0xd
  jmp __alltraps
  101e54:	e9 6a ff ff ff       	jmp    101dc3 <__alltraps>

00101e59 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e59:	6a 0e                	push   $0xe
  jmp __alltraps
  101e5b:	e9 63 ff ff ff       	jmp    101dc3 <__alltraps>

00101e60 <vector15>:
.globl vector15
vector15:
  pushl $0
  101e60:	6a 00                	push   $0x0
  pushl $15
  101e62:	6a 0f                	push   $0xf
  jmp __alltraps
  101e64:	e9 5a ff ff ff       	jmp    101dc3 <__alltraps>

00101e69 <vector16>:
.globl vector16
vector16:
  pushl $0
  101e69:	6a 00                	push   $0x0
  pushl $16
  101e6b:	6a 10                	push   $0x10
  jmp __alltraps
  101e6d:	e9 51 ff ff ff       	jmp    101dc3 <__alltraps>

00101e72 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e72:	6a 11                	push   $0x11
  jmp __alltraps
  101e74:	e9 4a ff ff ff       	jmp    101dc3 <__alltraps>

00101e79 <vector18>:
.globl vector18
vector18:
  pushl $0
  101e79:	6a 00                	push   $0x0
  pushl $18
  101e7b:	6a 12                	push   $0x12
  jmp __alltraps
  101e7d:	e9 41 ff ff ff       	jmp    101dc3 <__alltraps>

00101e82 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e82:	6a 00                	push   $0x0
  pushl $19
  101e84:	6a 13                	push   $0x13
  jmp __alltraps
  101e86:	e9 38 ff ff ff       	jmp    101dc3 <__alltraps>

00101e8b <vector20>:
.globl vector20
vector20:
  pushl $0
  101e8b:	6a 00                	push   $0x0
  pushl $20
  101e8d:	6a 14                	push   $0x14
  jmp __alltraps
  101e8f:	e9 2f ff ff ff       	jmp    101dc3 <__alltraps>

00101e94 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e94:	6a 00                	push   $0x0
  pushl $21
  101e96:	6a 15                	push   $0x15
  jmp __alltraps
  101e98:	e9 26 ff ff ff       	jmp    101dc3 <__alltraps>

00101e9d <vector22>:
.globl vector22
vector22:
  pushl $0
  101e9d:	6a 00                	push   $0x0
  pushl $22
  101e9f:	6a 16                	push   $0x16
  jmp __alltraps
  101ea1:	e9 1d ff ff ff       	jmp    101dc3 <__alltraps>

00101ea6 <vector23>:
.globl vector23
vector23:
  pushl $0
  101ea6:	6a 00                	push   $0x0
  pushl $23
  101ea8:	6a 17                	push   $0x17
  jmp __alltraps
  101eaa:	e9 14 ff ff ff       	jmp    101dc3 <__alltraps>

00101eaf <vector24>:
.globl vector24
vector24:
  pushl $0
  101eaf:	6a 00                	push   $0x0
  pushl $24
  101eb1:	6a 18                	push   $0x18
  jmp __alltraps
  101eb3:	e9 0b ff ff ff       	jmp    101dc3 <__alltraps>

00101eb8 <vector25>:
.globl vector25
vector25:
  pushl $0
  101eb8:	6a 00                	push   $0x0
  pushl $25
  101eba:	6a 19                	push   $0x19
  jmp __alltraps
  101ebc:	e9 02 ff ff ff       	jmp    101dc3 <__alltraps>

00101ec1 <vector26>:
.globl vector26
vector26:
  pushl $0
  101ec1:	6a 00                	push   $0x0
  pushl $26
  101ec3:	6a 1a                	push   $0x1a
  jmp __alltraps
  101ec5:	e9 f9 fe ff ff       	jmp    101dc3 <__alltraps>

00101eca <vector27>:
.globl vector27
vector27:
  pushl $0
  101eca:	6a 00                	push   $0x0
  pushl $27
  101ecc:	6a 1b                	push   $0x1b
  jmp __alltraps
  101ece:	e9 f0 fe ff ff       	jmp    101dc3 <__alltraps>

00101ed3 <vector28>:
.globl vector28
vector28:
  pushl $0
  101ed3:	6a 00                	push   $0x0
  pushl $28
  101ed5:	6a 1c                	push   $0x1c
  jmp __alltraps
  101ed7:	e9 e7 fe ff ff       	jmp    101dc3 <__alltraps>

00101edc <vector29>:
.globl vector29
vector29:
  pushl $0
  101edc:	6a 00                	push   $0x0
  pushl $29
  101ede:	6a 1d                	push   $0x1d
  jmp __alltraps
  101ee0:	e9 de fe ff ff       	jmp    101dc3 <__alltraps>

00101ee5 <vector30>:
.globl vector30
vector30:
  pushl $0
  101ee5:	6a 00                	push   $0x0
  pushl $30
  101ee7:	6a 1e                	push   $0x1e
  jmp __alltraps
  101ee9:	e9 d5 fe ff ff       	jmp    101dc3 <__alltraps>

00101eee <vector31>:
.globl vector31
vector31:
  pushl $0
  101eee:	6a 00                	push   $0x0
  pushl $31
  101ef0:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ef2:	e9 cc fe ff ff       	jmp    101dc3 <__alltraps>

00101ef7 <vector32>:
.globl vector32
vector32:
  pushl $0
  101ef7:	6a 00                	push   $0x0
  pushl $32
  101ef9:	6a 20                	push   $0x20
  jmp __alltraps
  101efb:	e9 c3 fe ff ff       	jmp    101dc3 <__alltraps>

00101f00 <vector33>:
.globl vector33
vector33:
  pushl $0
  101f00:	6a 00                	push   $0x0
  pushl $33
  101f02:	6a 21                	push   $0x21
  jmp __alltraps
  101f04:	e9 ba fe ff ff       	jmp    101dc3 <__alltraps>

00101f09 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f09:	6a 00                	push   $0x0
  pushl $34
  101f0b:	6a 22                	push   $0x22
  jmp __alltraps
  101f0d:	e9 b1 fe ff ff       	jmp    101dc3 <__alltraps>

00101f12 <vector35>:
.globl vector35
vector35:
  pushl $0
  101f12:	6a 00                	push   $0x0
  pushl $35
  101f14:	6a 23                	push   $0x23
  jmp __alltraps
  101f16:	e9 a8 fe ff ff       	jmp    101dc3 <__alltraps>

00101f1b <vector36>:
.globl vector36
vector36:
  pushl $0
  101f1b:	6a 00                	push   $0x0
  pushl $36
  101f1d:	6a 24                	push   $0x24
  jmp __alltraps
  101f1f:	e9 9f fe ff ff       	jmp    101dc3 <__alltraps>

00101f24 <vector37>:
.globl vector37
vector37:
  pushl $0
  101f24:	6a 00                	push   $0x0
  pushl $37
  101f26:	6a 25                	push   $0x25
  jmp __alltraps
  101f28:	e9 96 fe ff ff       	jmp    101dc3 <__alltraps>

00101f2d <vector38>:
.globl vector38
vector38:
  pushl $0
  101f2d:	6a 00                	push   $0x0
  pushl $38
  101f2f:	6a 26                	push   $0x26
  jmp __alltraps
  101f31:	e9 8d fe ff ff       	jmp    101dc3 <__alltraps>

00101f36 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f36:	6a 00                	push   $0x0
  pushl $39
  101f38:	6a 27                	push   $0x27
  jmp __alltraps
  101f3a:	e9 84 fe ff ff       	jmp    101dc3 <__alltraps>

00101f3f <vector40>:
.globl vector40
vector40:
  pushl $0
  101f3f:	6a 00                	push   $0x0
  pushl $40
  101f41:	6a 28                	push   $0x28
  jmp __alltraps
  101f43:	e9 7b fe ff ff       	jmp    101dc3 <__alltraps>

00101f48 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f48:	6a 00                	push   $0x0
  pushl $41
  101f4a:	6a 29                	push   $0x29
  jmp __alltraps
  101f4c:	e9 72 fe ff ff       	jmp    101dc3 <__alltraps>

00101f51 <vector42>:
.globl vector42
vector42:
  pushl $0
  101f51:	6a 00                	push   $0x0
  pushl $42
  101f53:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f55:	e9 69 fe ff ff       	jmp    101dc3 <__alltraps>

00101f5a <vector43>:
.globl vector43
vector43:
  pushl $0
  101f5a:	6a 00                	push   $0x0
  pushl $43
  101f5c:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f5e:	e9 60 fe ff ff       	jmp    101dc3 <__alltraps>

00101f63 <vector44>:
.globl vector44
vector44:
  pushl $0
  101f63:	6a 00                	push   $0x0
  pushl $44
  101f65:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f67:	e9 57 fe ff ff       	jmp    101dc3 <__alltraps>

00101f6c <vector45>:
.globl vector45
vector45:
  pushl $0
  101f6c:	6a 00                	push   $0x0
  pushl $45
  101f6e:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f70:	e9 4e fe ff ff       	jmp    101dc3 <__alltraps>

00101f75 <vector46>:
.globl vector46
vector46:
  pushl $0
  101f75:	6a 00                	push   $0x0
  pushl $46
  101f77:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f79:	e9 45 fe ff ff       	jmp    101dc3 <__alltraps>

00101f7e <vector47>:
.globl vector47
vector47:
  pushl $0
  101f7e:	6a 00                	push   $0x0
  pushl $47
  101f80:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f82:	e9 3c fe ff ff       	jmp    101dc3 <__alltraps>

00101f87 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $48
  101f89:	6a 30                	push   $0x30
  jmp __alltraps
  101f8b:	e9 33 fe ff ff       	jmp    101dc3 <__alltraps>

00101f90 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $49
  101f92:	6a 31                	push   $0x31
  jmp __alltraps
  101f94:	e9 2a fe ff ff       	jmp    101dc3 <__alltraps>

00101f99 <vector50>:
.globl vector50
vector50:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $50
  101f9b:	6a 32                	push   $0x32
  jmp __alltraps
  101f9d:	e9 21 fe ff ff       	jmp    101dc3 <__alltraps>

00101fa2 <vector51>:
.globl vector51
vector51:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $51
  101fa4:	6a 33                	push   $0x33
  jmp __alltraps
  101fa6:	e9 18 fe ff ff       	jmp    101dc3 <__alltraps>

00101fab <vector52>:
.globl vector52
vector52:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $52
  101fad:	6a 34                	push   $0x34
  jmp __alltraps
  101faf:	e9 0f fe ff ff       	jmp    101dc3 <__alltraps>

00101fb4 <vector53>:
.globl vector53
vector53:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $53
  101fb6:	6a 35                	push   $0x35
  jmp __alltraps
  101fb8:	e9 06 fe ff ff       	jmp    101dc3 <__alltraps>

00101fbd <vector54>:
.globl vector54
vector54:
  pushl $0
  101fbd:	6a 00                	push   $0x0
  pushl $54
  101fbf:	6a 36                	push   $0x36
  jmp __alltraps
  101fc1:	e9 fd fd ff ff       	jmp    101dc3 <__alltraps>

00101fc6 <vector55>:
.globl vector55
vector55:
  pushl $0
  101fc6:	6a 00                	push   $0x0
  pushl $55
  101fc8:	6a 37                	push   $0x37
  jmp __alltraps
  101fca:	e9 f4 fd ff ff       	jmp    101dc3 <__alltraps>

00101fcf <vector56>:
.globl vector56
vector56:
  pushl $0
  101fcf:	6a 00                	push   $0x0
  pushl $56
  101fd1:	6a 38                	push   $0x38
  jmp __alltraps
  101fd3:	e9 eb fd ff ff       	jmp    101dc3 <__alltraps>

00101fd8 <vector57>:
.globl vector57
vector57:
  pushl $0
  101fd8:	6a 00                	push   $0x0
  pushl $57
  101fda:	6a 39                	push   $0x39
  jmp __alltraps
  101fdc:	e9 e2 fd ff ff       	jmp    101dc3 <__alltraps>

00101fe1 <vector58>:
.globl vector58
vector58:
  pushl $0
  101fe1:	6a 00                	push   $0x0
  pushl $58
  101fe3:	6a 3a                	push   $0x3a
  jmp __alltraps
  101fe5:	e9 d9 fd ff ff       	jmp    101dc3 <__alltraps>

00101fea <vector59>:
.globl vector59
vector59:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $59
  101fec:	6a 3b                	push   $0x3b
  jmp __alltraps
  101fee:	e9 d0 fd ff ff       	jmp    101dc3 <__alltraps>

00101ff3 <vector60>:
.globl vector60
vector60:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $60
  101ff5:	6a 3c                	push   $0x3c
  jmp __alltraps
  101ff7:	e9 c7 fd ff ff       	jmp    101dc3 <__alltraps>

00101ffc <vector61>:
.globl vector61
vector61:
  pushl $0
  101ffc:	6a 00                	push   $0x0
  pushl $61
  101ffe:	6a 3d                	push   $0x3d
  jmp __alltraps
  102000:	e9 be fd ff ff       	jmp    101dc3 <__alltraps>

00102005 <vector62>:
.globl vector62
vector62:
  pushl $0
  102005:	6a 00                	push   $0x0
  pushl $62
  102007:	6a 3e                	push   $0x3e
  jmp __alltraps
  102009:	e9 b5 fd ff ff       	jmp    101dc3 <__alltraps>

0010200e <vector63>:
.globl vector63
vector63:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $63
  102010:	6a 3f                	push   $0x3f
  jmp __alltraps
  102012:	e9 ac fd ff ff       	jmp    101dc3 <__alltraps>

00102017 <vector64>:
.globl vector64
vector64:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $64
  102019:	6a 40                	push   $0x40
  jmp __alltraps
  10201b:	e9 a3 fd ff ff       	jmp    101dc3 <__alltraps>

00102020 <vector65>:
.globl vector65
vector65:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $65
  102022:	6a 41                	push   $0x41
  jmp __alltraps
  102024:	e9 9a fd ff ff       	jmp    101dc3 <__alltraps>

00102029 <vector66>:
.globl vector66
vector66:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $66
  10202b:	6a 42                	push   $0x42
  jmp __alltraps
  10202d:	e9 91 fd ff ff       	jmp    101dc3 <__alltraps>

00102032 <vector67>:
.globl vector67
vector67:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $67
  102034:	6a 43                	push   $0x43
  jmp __alltraps
  102036:	e9 88 fd ff ff       	jmp    101dc3 <__alltraps>

0010203b <vector68>:
.globl vector68
vector68:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $68
  10203d:	6a 44                	push   $0x44
  jmp __alltraps
  10203f:	e9 7f fd ff ff       	jmp    101dc3 <__alltraps>

00102044 <vector69>:
.globl vector69
vector69:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $69
  102046:	6a 45                	push   $0x45
  jmp __alltraps
  102048:	e9 76 fd ff ff       	jmp    101dc3 <__alltraps>

0010204d <vector70>:
.globl vector70
vector70:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $70
  10204f:	6a 46                	push   $0x46
  jmp __alltraps
  102051:	e9 6d fd ff ff       	jmp    101dc3 <__alltraps>

00102056 <vector71>:
.globl vector71
vector71:
  pushl $0
  102056:	6a 00                	push   $0x0
  pushl $71
  102058:	6a 47                	push   $0x47
  jmp __alltraps
  10205a:	e9 64 fd ff ff       	jmp    101dc3 <__alltraps>

0010205f <vector72>:
.globl vector72
vector72:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $72
  102061:	6a 48                	push   $0x48
  jmp __alltraps
  102063:	e9 5b fd ff ff       	jmp    101dc3 <__alltraps>

00102068 <vector73>:
.globl vector73
vector73:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $73
  10206a:	6a 49                	push   $0x49
  jmp __alltraps
  10206c:	e9 52 fd ff ff       	jmp    101dc3 <__alltraps>

00102071 <vector74>:
.globl vector74
vector74:
  pushl $0
  102071:	6a 00                	push   $0x0
  pushl $74
  102073:	6a 4a                	push   $0x4a
  jmp __alltraps
  102075:	e9 49 fd ff ff       	jmp    101dc3 <__alltraps>

0010207a <vector75>:
.globl vector75
vector75:
  pushl $0
  10207a:	6a 00                	push   $0x0
  pushl $75
  10207c:	6a 4b                	push   $0x4b
  jmp __alltraps
  10207e:	e9 40 fd ff ff       	jmp    101dc3 <__alltraps>

00102083 <vector76>:
.globl vector76
vector76:
  pushl $0
  102083:	6a 00                	push   $0x0
  pushl $76
  102085:	6a 4c                	push   $0x4c
  jmp __alltraps
  102087:	e9 37 fd ff ff       	jmp    101dc3 <__alltraps>

0010208c <vector77>:
.globl vector77
vector77:
  pushl $0
  10208c:	6a 00                	push   $0x0
  pushl $77
  10208e:	6a 4d                	push   $0x4d
  jmp __alltraps
  102090:	e9 2e fd ff ff       	jmp    101dc3 <__alltraps>

00102095 <vector78>:
.globl vector78
vector78:
  pushl $0
  102095:	6a 00                	push   $0x0
  pushl $78
  102097:	6a 4e                	push   $0x4e
  jmp __alltraps
  102099:	e9 25 fd ff ff       	jmp    101dc3 <__alltraps>

0010209e <vector79>:
.globl vector79
vector79:
  pushl $0
  10209e:	6a 00                	push   $0x0
  pushl $79
  1020a0:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020a2:	e9 1c fd ff ff       	jmp    101dc3 <__alltraps>

001020a7 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020a7:	6a 00                	push   $0x0
  pushl $80
  1020a9:	6a 50                	push   $0x50
  jmp __alltraps
  1020ab:	e9 13 fd ff ff       	jmp    101dc3 <__alltraps>

001020b0 <vector81>:
.globl vector81
vector81:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $81
  1020b2:	6a 51                	push   $0x51
  jmp __alltraps
  1020b4:	e9 0a fd ff ff       	jmp    101dc3 <__alltraps>

001020b9 <vector82>:
.globl vector82
vector82:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $82
  1020bb:	6a 52                	push   $0x52
  jmp __alltraps
  1020bd:	e9 01 fd ff ff       	jmp    101dc3 <__alltraps>

001020c2 <vector83>:
.globl vector83
vector83:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $83
  1020c4:	6a 53                	push   $0x53
  jmp __alltraps
  1020c6:	e9 f8 fc ff ff       	jmp    101dc3 <__alltraps>

001020cb <vector84>:
.globl vector84
vector84:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $84
  1020cd:	6a 54                	push   $0x54
  jmp __alltraps
  1020cf:	e9 ef fc ff ff       	jmp    101dc3 <__alltraps>

001020d4 <vector85>:
.globl vector85
vector85:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $85
  1020d6:	6a 55                	push   $0x55
  jmp __alltraps
  1020d8:	e9 e6 fc ff ff       	jmp    101dc3 <__alltraps>

001020dd <vector86>:
.globl vector86
vector86:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $86
  1020df:	6a 56                	push   $0x56
  jmp __alltraps
  1020e1:	e9 dd fc ff ff       	jmp    101dc3 <__alltraps>

001020e6 <vector87>:
.globl vector87
vector87:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $87
  1020e8:	6a 57                	push   $0x57
  jmp __alltraps
  1020ea:	e9 d4 fc ff ff       	jmp    101dc3 <__alltraps>

001020ef <vector88>:
.globl vector88
vector88:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $88
  1020f1:	6a 58                	push   $0x58
  jmp __alltraps
  1020f3:	e9 cb fc ff ff       	jmp    101dc3 <__alltraps>

001020f8 <vector89>:
.globl vector89
vector89:
  pushl $0
  1020f8:	6a 00                	push   $0x0
  pushl $89
  1020fa:	6a 59                	push   $0x59
  jmp __alltraps
  1020fc:	e9 c2 fc ff ff       	jmp    101dc3 <__alltraps>

00102101 <vector90>:
.globl vector90
vector90:
  pushl $0
  102101:	6a 00                	push   $0x0
  pushl $90
  102103:	6a 5a                	push   $0x5a
  jmp __alltraps
  102105:	e9 b9 fc ff ff       	jmp    101dc3 <__alltraps>

0010210a <vector91>:
.globl vector91
vector91:
  pushl $0
  10210a:	6a 00                	push   $0x0
  pushl $91
  10210c:	6a 5b                	push   $0x5b
  jmp __alltraps
  10210e:	e9 b0 fc ff ff       	jmp    101dc3 <__alltraps>

00102113 <vector92>:
.globl vector92
vector92:
  pushl $0
  102113:	6a 00                	push   $0x0
  pushl $92
  102115:	6a 5c                	push   $0x5c
  jmp __alltraps
  102117:	e9 a7 fc ff ff       	jmp    101dc3 <__alltraps>

0010211c <vector93>:
.globl vector93
vector93:
  pushl $0
  10211c:	6a 00                	push   $0x0
  pushl $93
  10211e:	6a 5d                	push   $0x5d
  jmp __alltraps
  102120:	e9 9e fc ff ff       	jmp    101dc3 <__alltraps>

00102125 <vector94>:
.globl vector94
vector94:
  pushl $0
  102125:	6a 00                	push   $0x0
  pushl $94
  102127:	6a 5e                	push   $0x5e
  jmp __alltraps
  102129:	e9 95 fc ff ff       	jmp    101dc3 <__alltraps>

0010212e <vector95>:
.globl vector95
vector95:
  pushl $0
  10212e:	6a 00                	push   $0x0
  pushl $95
  102130:	6a 5f                	push   $0x5f
  jmp __alltraps
  102132:	e9 8c fc ff ff       	jmp    101dc3 <__alltraps>

00102137 <vector96>:
.globl vector96
vector96:
  pushl $0
  102137:	6a 00                	push   $0x0
  pushl $96
  102139:	6a 60                	push   $0x60
  jmp __alltraps
  10213b:	e9 83 fc ff ff       	jmp    101dc3 <__alltraps>

00102140 <vector97>:
.globl vector97
vector97:
  pushl $0
  102140:	6a 00                	push   $0x0
  pushl $97
  102142:	6a 61                	push   $0x61
  jmp __alltraps
  102144:	e9 7a fc ff ff       	jmp    101dc3 <__alltraps>

00102149 <vector98>:
.globl vector98
vector98:
  pushl $0
  102149:	6a 00                	push   $0x0
  pushl $98
  10214b:	6a 62                	push   $0x62
  jmp __alltraps
  10214d:	e9 71 fc ff ff       	jmp    101dc3 <__alltraps>

00102152 <vector99>:
.globl vector99
vector99:
  pushl $0
  102152:	6a 00                	push   $0x0
  pushl $99
  102154:	6a 63                	push   $0x63
  jmp __alltraps
  102156:	e9 68 fc ff ff       	jmp    101dc3 <__alltraps>

0010215b <vector100>:
.globl vector100
vector100:
  pushl $0
  10215b:	6a 00                	push   $0x0
  pushl $100
  10215d:	6a 64                	push   $0x64
  jmp __alltraps
  10215f:	e9 5f fc ff ff       	jmp    101dc3 <__alltraps>

00102164 <vector101>:
.globl vector101
vector101:
  pushl $0
  102164:	6a 00                	push   $0x0
  pushl $101
  102166:	6a 65                	push   $0x65
  jmp __alltraps
  102168:	e9 56 fc ff ff       	jmp    101dc3 <__alltraps>

0010216d <vector102>:
.globl vector102
vector102:
  pushl $0
  10216d:	6a 00                	push   $0x0
  pushl $102
  10216f:	6a 66                	push   $0x66
  jmp __alltraps
  102171:	e9 4d fc ff ff       	jmp    101dc3 <__alltraps>

00102176 <vector103>:
.globl vector103
vector103:
  pushl $0
  102176:	6a 00                	push   $0x0
  pushl $103
  102178:	6a 67                	push   $0x67
  jmp __alltraps
  10217a:	e9 44 fc ff ff       	jmp    101dc3 <__alltraps>

0010217f <vector104>:
.globl vector104
vector104:
  pushl $0
  10217f:	6a 00                	push   $0x0
  pushl $104
  102181:	6a 68                	push   $0x68
  jmp __alltraps
  102183:	e9 3b fc ff ff       	jmp    101dc3 <__alltraps>

00102188 <vector105>:
.globl vector105
vector105:
  pushl $0
  102188:	6a 00                	push   $0x0
  pushl $105
  10218a:	6a 69                	push   $0x69
  jmp __alltraps
  10218c:	e9 32 fc ff ff       	jmp    101dc3 <__alltraps>

00102191 <vector106>:
.globl vector106
vector106:
  pushl $0
  102191:	6a 00                	push   $0x0
  pushl $106
  102193:	6a 6a                	push   $0x6a
  jmp __alltraps
  102195:	e9 29 fc ff ff       	jmp    101dc3 <__alltraps>

0010219a <vector107>:
.globl vector107
vector107:
  pushl $0
  10219a:	6a 00                	push   $0x0
  pushl $107
  10219c:	6a 6b                	push   $0x6b
  jmp __alltraps
  10219e:	e9 20 fc ff ff       	jmp    101dc3 <__alltraps>

001021a3 <vector108>:
.globl vector108
vector108:
  pushl $0
  1021a3:	6a 00                	push   $0x0
  pushl $108
  1021a5:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021a7:	e9 17 fc ff ff       	jmp    101dc3 <__alltraps>

001021ac <vector109>:
.globl vector109
vector109:
  pushl $0
  1021ac:	6a 00                	push   $0x0
  pushl $109
  1021ae:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021b0:	e9 0e fc ff ff       	jmp    101dc3 <__alltraps>

001021b5 <vector110>:
.globl vector110
vector110:
  pushl $0
  1021b5:	6a 00                	push   $0x0
  pushl $110
  1021b7:	6a 6e                	push   $0x6e
  jmp __alltraps
  1021b9:	e9 05 fc ff ff       	jmp    101dc3 <__alltraps>

001021be <vector111>:
.globl vector111
vector111:
  pushl $0
  1021be:	6a 00                	push   $0x0
  pushl $111
  1021c0:	6a 6f                	push   $0x6f
  jmp __alltraps
  1021c2:	e9 fc fb ff ff       	jmp    101dc3 <__alltraps>

001021c7 <vector112>:
.globl vector112
vector112:
  pushl $0
  1021c7:	6a 00                	push   $0x0
  pushl $112
  1021c9:	6a 70                	push   $0x70
  jmp __alltraps
  1021cb:	e9 f3 fb ff ff       	jmp    101dc3 <__alltraps>

001021d0 <vector113>:
.globl vector113
vector113:
  pushl $0
  1021d0:	6a 00                	push   $0x0
  pushl $113
  1021d2:	6a 71                	push   $0x71
  jmp __alltraps
  1021d4:	e9 ea fb ff ff       	jmp    101dc3 <__alltraps>

001021d9 <vector114>:
.globl vector114
vector114:
  pushl $0
  1021d9:	6a 00                	push   $0x0
  pushl $114
  1021db:	6a 72                	push   $0x72
  jmp __alltraps
  1021dd:	e9 e1 fb ff ff       	jmp    101dc3 <__alltraps>

001021e2 <vector115>:
.globl vector115
vector115:
  pushl $0
  1021e2:	6a 00                	push   $0x0
  pushl $115
  1021e4:	6a 73                	push   $0x73
  jmp __alltraps
  1021e6:	e9 d8 fb ff ff       	jmp    101dc3 <__alltraps>

001021eb <vector116>:
.globl vector116
vector116:
  pushl $0
  1021eb:	6a 00                	push   $0x0
  pushl $116
  1021ed:	6a 74                	push   $0x74
  jmp __alltraps
  1021ef:	e9 cf fb ff ff       	jmp    101dc3 <__alltraps>

001021f4 <vector117>:
.globl vector117
vector117:
  pushl $0
  1021f4:	6a 00                	push   $0x0
  pushl $117
  1021f6:	6a 75                	push   $0x75
  jmp __alltraps
  1021f8:	e9 c6 fb ff ff       	jmp    101dc3 <__alltraps>

001021fd <vector118>:
.globl vector118
vector118:
  pushl $0
  1021fd:	6a 00                	push   $0x0
  pushl $118
  1021ff:	6a 76                	push   $0x76
  jmp __alltraps
  102201:	e9 bd fb ff ff       	jmp    101dc3 <__alltraps>

00102206 <vector119>:
.globl vector119
vector119:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $119
  102208:	6a 77                	push   $0x77
  jmp __alltraps
  10220a:	e9 b4 fb ff ff       	jmp    101dc3 <__alltraps>

0010220f <vector120>:
.globl vector120
vector120:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $120
  102211:	6a 78                	push   $0x78
  jmp __alltraps
  102213:	e9 ab fb ff ff       	jmp    101dc3 <__alltraps>

00102218 <vector121>:
.globl vector121
vector121:
  pushl $0
  102218:	6a 00                	push   $0x0
  pushl $121
  10221a:	6a 79                	push   $0x79
  jmp __alltraps
  10221c:	e9 a2 fb ff ff       	jmp    101dc3 <__alltraps>

00102221 <vector122>:
.globl vector122
vector122:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $122
  102223:	6a 7a                	push   $0x7a
  jmp __alltraps
  102225:	e9 99 fb ff ff       	jmp    101dc3 <__alltraps>

0010222a <vector123>:
.globl vector123
vector123:
  pushl $0
  10222a:	6a 00                	push   $0x0
  pushl $123
  10222c:	6a 7b                	push   $0x7b
  jmp __alltraps
  10222e:	e9 90 fb ff ff       	jmp    101dc3 <__alltraps>

00102233 <vector124>:
.globl vector124
vector124:
  pushl $0
  102233:	6a 00                	push   $0x0
  pushl $124
  102235:	6a 7c                	push   $0x7c
  jmp __alltraps
  102237:	e9 87 fb ff ff       	jmp    101dc3 <__alltraps>

0010223c <vector125>:
.globl vector125
vector125:
  pushl $0
  10223c:	6a 00                	push   $0x0
  pushl $125
  10223e:	6a 7d                	push   $0x7d
  jmp __alltraps
  102240:	e9 7e fb ff ff       	jmp    101dc3 <__alltraps>

00102245 <vector126>:
.globl vector126
vector126:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $126
  102247:	6a 7e                	push   $0x7e
  jmp __alltraps
  102249:	e9 75 fb ff ff       	jmp    101dc3 <__alltraps>

0010224e <vector127>:
.globl vector127
vector127:
  pushl $0
  10224e:	6a 00                	push   $0x0
  pushl $127
  102250:	6a 7f                	push   $0x7f
  jmp __alltraps
  102252:	e9 6c fb ff ff       	jmp    101dc3 <__alltraps>

00102257 <vector128>:
.globl vector128
vector128:
  pushl $0
  102257:	6a 00                	push   $0x0
  pushl $128
  102259:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10225e:	e9 60 fb ff ff       	jmp    101dc3 <__alltraps>

00102263 <vector129>:
.globl vector129
vector129:
  pushl $0
  102263:	6a 00                	push   $0x0
  pushl $129
  102265:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10226a:	e9 54 fb ff ff       	jmp    101dc3 <__alltraps>

0010226f <vector130>:
.globl vector130
vector130:
  pushl $0
  10226f:	6a 00                	push   $0x0
  pushl $130
  102271:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102276:	e9 48 fb ff ff       	jmp    101dc3 <__alltraps>

0010227b <vector131>:
.globl vector131
vector131:
  pushl $0
  10227b:	6a 00                	push   $0x0
  pushl $131
  10227d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102282:	e9 3c fb ff ff       	jmp    101dc3 <__alltraps>

00102287 <vector132>:
.globl vector132
vector132:
  pushl $0
  102287:	6a 00                	push   $0x0
  pushl $132
  102289:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10228e:	e9 30 fb ff ff       	jmp    101dc3 <__alltraps>

00102293 <vector133>:
.globl vector133
vector133:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $133
  102295:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10229a:	e9 24 fb ff ff       	jmp    101dc3 <__alltraps>

0010229f <vector134>:
.globl vector134
vector134:
  pushl $0
  10229f:	6a 00                	push   $0x0
  pushl $134
  1022a1:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022a6:	e9 18 fb ff ff       	jmp    101dc3 <__alltraps>

001022ab <vector135>:
.globl vector135
vector135:
  pushl $0
  1022ab:	6a 00                	push   $0x0
  pushl $135
  1022ad:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022b2:	e9 0c fb ff ff       	jmp    101dc3 <__alltraps>

001022b7 <vector136>:
.globl vector136
vector136:
  pushl $0
  1022b7:	6a 00                	push   $0x0
  pushl $136
  1022b9:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1022be:	e9 00 fb ff ff       	jmp    101dc3 <__alltraps>

001022c3 <vector137>:
.globl vector137
vector137:
  pushl $0
  1022c3:	6a 00                	push   $0x0
  pushl $137
  1022c5:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1022ca:	e9 f4 fa ff ff       	jmp    101dc3 <__alltraps>

001022cf <vector138>:
.globl vector138
vector138:
  pushl $0
  1022cf:	6a 00                	push   $0x0
  pushl $138
  1022d1:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022d6:	e9 e8 fa ff ff       	jmp    101dc3 <__alltraps>

001022db <vector139>:
.globl vector139
vector139:
  pushl $0
  1022db:	6a 00                	push   $0x0
  pushl $139
  1022dd:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1022e2:	e9 dc fa ff ff       	jmp    101dc3 <__alltraps>

001022e7 <vector140>:
.globl vector140
vector140:
  pushl $0
  1022e7:	6a 00                	push   $0x0
  pushl $140
  1022e9:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022ee:	e9 d0 fa ff ff       	jmp    101dc3 <__alltraps>

001022f3 <vector141>:
.globl vector141
vector141:
  pushl $0
  1022f3:	6a 00                	push   $0x0
  pushl $141
  1022f5:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022fa:	e9 c4 fa ff ff       	jmp    101dc3 <__alltraps>

001022ff <vector142>:
.globl vector142
vector142:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $142
  102301:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102306:	e9 b8 fa ff ff       	jmp    101dc3 <__alltraps>

0010230b <vector143>:
.globl vector143
vector143:
  pushl $0
  10230b:	6a 00                	push   $0x0
  pushl $143
  10230d:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102312:	e9 ac fa ff ff       	jmp    101dc3 <__alltraps>

00102317 <vector144>:
.globl vector144
vector144:
  pushl $0
  102317:	6a 00                	push   $0x0
  pushl $144
  102319:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10231e:	e9 a0 fa ff ff       	jmp    101dc3 <__alltraps>

00102323 <vector145>:
.globl vector145
vector145:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $145
  102325:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10232a:	e9 94 fa ff ff       	jmp    101dc3 <__alltraps>

0010232f <vector146>:
.globl vector146
vector146:
  pushl $0
  10232f:	6a 00                	push   $0x0
  pushl $146
  102331:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102336:	e9 88 fa ff ff       	jmp    101dc3 <__alltraps>

0010233b <vector147>:
.globl vector147
vector147:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $147
  10233d:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102342:	e9 7c fa ff ff       	jmp    101dc3 <__alltraps>

00102347 <vector148>:
.globl vector148
vector148:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $148
  102349:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10234e:	e9 70 fa ff ff       	jmp    101dc3 <__alltraps>

00102353 <vector149>:
.globl vector149
vector149:
  pushl $0
  102353:	6a 00                	push   $0x0
  pushl $149
  102355:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10235a:	e9 64 fa ff ff       	jmp    101dc3 <__alltraps>

0010235f <vector150>:
.globl vector150
vector150:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $150
  102361:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102366:	e9 58 fa ff ff       	jmp    101dc3 <__alltraps>

0010236b <vector151>:
.globl vector151
vector151:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $151
  10236d:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102372:	e9 4c fa ff ff       	jmp    101dc3 <__alltraps>

00102377 <vector152>:
.globl vector152
vector152:
  pushl $0
  102377:	6a 00                	push   $0x0
  pushl $152
  102379:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10237e:	e9 40 fa ff ff       	jmp    101dc3 <__alltraps>

00102383 <vector153>:
.globl vector153
vector153:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $153
  102385:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10238a:	e9 34 fa ff ff       	jmp    101dc3 <__alltraps>

0010238f <vector154>:
.globl vector154
vector154:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $154
  102391:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102396:	e9 28 fa ff ff       	jmp    101dc3 <__alltraps>

0010239b <vector155>:
.globl vector155
vector155:
  pushl $0
  10239b:	6a 00                	push   $0x0
  pushl $155
  10239d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023a2:	e9 1c fa ff ff       	jmp    101dc3 <__alltraps>

001023a7 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $156
  1023a9:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023ae:	e9 10 fa ff ff       	jmp    101dc3 <__alltraps>

001023b3 <vector157>:
.globl vector157
vector157:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $157
  1023b5:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1023ba:	e9 04 fa ff ff       	jmp    101dc3 <__alltraps>

001023bf <vector158>:
.globl vector158
vector158:
  pushl $0
  1023bf:	6a 00                	push   $0x0
  pushl $158
  1023c1:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1023c6:	e9 f8 f9 ff ff       	jmp    101dc3 <__alltraps>

001023cb <vector159>:
.globl vector159
vector159:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $159
  1023cd:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1023d2:	e9 ec f9 ff ff       	jmp    101dc3 <__alltraps>

001023d7 <vector160>:
.globl vector160
vector160:
  pushl $0
  1023d7:	6a 00                	push   $0x0
  pushl $160
  1023d9:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1023de:	e9 e0 f9 ff ff       	jmp    101dc3 <__alltraps>

001023e3 <vector161>:
.globl vector161
vector161:
  pushl $0
  1023e3:	6a 00                	push   $0x0
  pushl $161
  1023e5:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1023ea:	e9 d4 f9 ff ff       	jmp    101dc3 <__alltraps>

001023ef <vector162>:
.globl vector162
vector162:
  pushl $0
  1023ef:	6a 00                	push   $0x0
  pushl $162
  1023f1:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023f6:	e9 c8 f9 ff ff       	jmp    101dc3 <__alltraps>

001023fb <vector163>:
.globl vector163
vector163:
  pushl $0
  1023fb:	6a 00                	push   $0x0
  pushl $163
  1023fd:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102402:	e9 bc f9 ff ff       	jmp    101dc3 <__alltraps>

00102407 <vector164>:
.globl vector164
vector164:
  pushl $0
  102407:	6a 00                	push   $0x0
  pushl $164
  102409:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10240e:	e9 b0 f9 ff ff       	jmp    101dc3 <__alltraps>

00102413 <vector165>:
.globl vector165
vector165:
  pushl $0
  102413:	6a 00                	push   $0x0
  pushl $165
  102415:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  10241a:	e9 a4 f9 ff ff       	jmp    101dc3 <__alltraps>

0010241f <vector166>:
.globl vector166
vector166:
  pushl $0
  10241f:	6a 00                	push   $0x0
  pushl $166
  102421:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102426:	e9 98 f9 ff ff       	jmp    101dc3 <__alltraps>

0010242b <vector167>:
.globl vector167
vector167:
  pushl $0
  10242b:	6a 00                	push   $0x0
  pushl $167
  10242d:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102432:	e9 8c f9 ff ff       	jmp    101dc3 <__alltraps>

00102437 <vector168>:
.globl vector168
vector168:
  pushl $0
  102437:	6a 00                	push   $0x0
  pushl $168
  102439:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10243e:	e9 80 f9 ff ff       	jmp    101dc3 <__alltraps>

00102443 <vector169>:
.globl vector169
vector169:
  pushl $0
  102443:	6a 00                	push   $0x0
  pushl $169
  102445:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10244a:	e9 74 f9 ff ff       	jmp    101dc3 <__alltraps>

0010244f <vector170>:
.globl vector170
vector170:
  pushl $0
  10244f:	6a 00                	push   $0x0
  pushl $170
  102451:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102456:	e9 68 f9 ff ff       	jmp    101dc3 <__alltraps>

0010245b <vector171>:
.globl vector171
vector171:
  pushl $0
  10245b:	6a 00                	push   $0x0
  pushl $171
  10245d:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102462:	e9 5c f9 ff ff       	jmp    101dc3 <__alltraps>

00102467 <vector172>:
.globl vector172
vector172:
  pushl $0
  102467:	6a 00                	push   $0x0
  pushl $172
  102469:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10246e:	e9 50 f9 ff ff       	jmp    101dc3 <__alltraps>

00102473 <vector173>:
.globl vector173
vector173:
  pushl $0
  102473:	6a 00                	push   $0x0
  pushl $173
  102475:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10247a:	e9 44 f9 ff ff       	jmp    101dc3 <__alltraps>

0010247f <vector174>:
.globl vector174
vector174:
  pushl $0
  10247f:	6a 00                	push   $0x0
  pushl $174
  102481:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102486:	e9 38 f9 ff ff       	jmp    101dc3 <__alltraps>

0010248b <vector175>:
.globl vector175
vector175:
  pushl $0
  10248b:	6a 00                	push   $0x0
  pushl $175
  10248d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102492:	e9 2c f9 ff ff       	jmp    101dc3 <__alltraps>

00102497 <vector176>:
.globl vector176
vector176:
  pushl $0
  102497:	6a 00                	push   $0x0
  pushl $176
  102499:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10249e:	e9 20 f9 ff ff       	jmp    101dc3 <__alltraps>

001024a3 <vector177>:
.globl vector177
vector177:
  pushl $0
  1024a3:	6a 00                	push   $0x0
  pushl $177
  1024a5:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024aa:	e9 14 f9 ff ff       	jmp    101dc3 <__alltraps>

001024af <vector178>:
.globl vector178
vector178:
  pushl $0
  1024af:	6a 00                	push   $0x0
  pushl $178
  1024b1:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1024b6:	e9 08 f9 ff ff       	jmp    101dc3 <__alltraps>

001024bb <vector179>:
.globl vector179
vector179:
  pushl $0
  1024bb:	6a 00                	push   $0x0
  pushl $179
  1024bd:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1024c2:	e9 fc f8 ff ff       	jmp    101dc3 <__alltraps>

001024c7 <vector180>:
.globl vector180
vector180:
  pushl $0
  1024c7:	6a 00                	push   $0x0
  pushl $180
  1024c9:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1024ce:	e9 f0 f8 ff ff       	jmp    101dc3 <__alltraps>

001024d3 <vector181>:
.globl vector181
vector181:
  pushl $0
  1024d3:	6a 00                	push   $0x0
  pushl $181
  1024d5:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024da:	e9 e4 f8 ff ff       	jmp    101dc3 <__alltraps>

001024df <vector182>:
.globl vector182
vector182:
  pushl $0
  1024df:	6a 00                	push   $0x0
  pushl $182
  1024e1:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1024e6:	e9 d8 f8 ff ff       	jmp    101dc3 <__alltraps>

001024eb <vector183>:
.globl vector183
vector183:
  pushl $0
  1024eb:	6a 00                	push   $0x0
  pushl $183
  1024ed:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024f2:	e9 cc f8 ff ff       	jmp    101dc3 <__alltraps>

001024f7 <vector184>:
.globl vector184
vector184:
  pushl $0
  1024f7:	6a 00                	push   $0x0
  pushl $184
  1024f9:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024fe:	e9 c0 f8 ff ff       	jmp    101dc3 <__alltraps>

00102503 <vector185>:
.globl vector185
vector185:
  pushl $0
  102503:	6a 00                	push   $0x0
  pushl $185
  102505:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10250a:	e9 b4 f8 ff ff       	jmp    101dc3 <__alltraps>

0010250f <vector186>:
.globl vector186
vector186:
  pushl $0
  10250f:	6a 00                	push   $0x0
  pushl $186
  102511:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102516:	e9 a8 f8 ff ff       	jmp    101dc3 <__alltraps>

0010251b <vector187>:
.globl vector187
vector187:
  pushl $0
  10251b:	6a 00                	push   $0x0
  pushl $187
  10251d:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102522:	e9 9c f8 ff ff       	jmp    101dc3 <__alltraps>

00102527 <vector188>:
.globl vector188
vector188:
  pushl $0
  102527:	6a 00                	push   $0x0
  pushl $188
  102529:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10252e:	e9 90 f8 ff ff       	jmp    101dc3 <__alltraps>

00102533 <vector189>:
.globl vector189
vector189:
  pushl $0
  102533:	6a 00                	push   $0x0
  pushl $189
  102535:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10253a:	e9 84 f8 ff ff       	jmp    101dc3 <__alltraps>

0010253f <vector190>:
.globl vector190
vector190:
  pushl $0
  10253f:	6a 00                	push   $0x0
  pushl $190
  102541:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102546:	e9 78 f8 ff ff       	jmp    101dc3 <__alltraps>

0010254b <vector191>:
.globl vector191
vector191:
  pushl $0
  10254b:	6a 00                	push   $0x0
  pushl $191
  10254d:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102552:	e9 6c f8 ff ff       	jmp    101dc3 <__alltraps>

00102557 <vector192>:
.globl vector192
vector192:
  pushl $0
  102557:	6a 00                	push   $0x0
  pushl $192
  102559:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10255e:	e9 60 f8 ff ff       	jmp    101dc3 <__alltraps>

00102563 <vector193>:
.globl vector193
vector193:
  pushl $0
  102563:	6a 00                	push   $0x0
  pushl $193
  102565:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10256a:	e9 54 f8 ff ff       	jmp    101dc3 <__alltraps>

0010256f <vector194>:
.globl vector194
vector194:
  pushl $0
  10256f:	6a 00                	push   $0x0
  pushl $194
  102571:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102576:	e9 48 f8 ff ff       	jmp    101dc3 <__alltraps>

0010257b <vector195>:
.globl vector195
vector195:
  pushl $0
  10257b:	6a 00                	push   $0x0
  pushl $195
  10257d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102582:	e9 3c f8 ff ff       	jmp    101dc3 <__alltraps>

00102587 <vector196>:
.globl vector196
vector196:
  pushl $0
  102587:	6a 00                	push   $0x0
  pushl $196
  102589:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10258e:	e9 30 f8 ff ff       	jmp    101dc3 <__alltraps>

00102593 <vector197>:
.globl vector197
vector197:
  pushl $0
  102593:	6a 00                	push   $0x0
  pushl $197
  102595:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10259a:	e9 24 f8 ff ff       	jmp    101dc3 <__alltraps>

0010259f <vector198>:
.globl vector198
vector198:
  pushl $0
  10259f:	6a 00                	push   $0x0
  pushl $198
  1025a1:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025a6:	e9 18 f8 ff ff       	jmp    101dc3 <__alltraps>

001025ab <vector199>:
.globl vector199
vector199:
  pushl $0
  1025ab:	6a 00                	push   $0x0
  pushl $199
  1025ad:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025b2:	e9 0c f8 ff ff       	jmp    101dc3 <__alltraps>

001025b7 <vector200>:
.globl vector200
vector200:
  pushl $0
  1025b7:	6a 00                	push   $0x0
  pushl $200
  1025b9:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1025be:	e9 00 f8 ff ff       	jmp    101dc3 <__alltraps>

001025c3 <vector201>:
.globl vector201
vector201:
  pushl $0
  1025c3:	6a 00                	push   $0x0
  pushl $201
  1025c5:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1025ca:	e9 f4 f7 ff ff       	jmp    101dc3 <__alltraps>

001025cf <vector202>:
.globl vector202
vector202:
  pushl $0
  1025cf:	6a 00                	push   $0x0
  pushl $202
  1025d1:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025d6:	e9 e8 f7 ff ff       	jmp    101dc3 <__alltraps>

001025db <vector203>:
.globl vector203
vector203:
  pushl $0
  1025db:	6a 00                	push   $0x0
  pushl $203
  1025dd:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1025e2:	e9 dc f7 ff ff       	jmp    101dc3 <__alltraps>

001025e7 <vector204>:
.globl vector204
vector204:
  pushl $0
  1025e7:	6a 00                	push   $0x0
  pushl $204
  1025e9:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025ee:	e9 d0 f7 ff ff       	jmp    101dc3 <__alltraps>

001025f3 <vector205>:
.globl vector205
vector205:
  pushl $0
  1025f3:	6a 00                	push   $0x0
  pushl $205
  1025f5:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025fa:	e9 c4 f7 ff ff       	jmp    101dc3 <__alltraps>

001025ff <vector206>:
.globl vector206
vector206:
  pushl $0
  1025ff:	6a 00                	push   $0x0
  pushl $206
  102601:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102606:	e9 b8 f7 ff ff       	jmp    101dc3 <__alltraps>

0010260b <vector207>:
.globl vector207
vector207:
  pushl $0
  10260b:	6a 00                	push   $0x0
  pushl $207
  10260d:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102612:	e9 ac f7 ff ff       	jmp    101dc3 <__alltraps>

00102617 <vector208>:
.globl vector208
vector208:
  pushl $0
  102617:	6a 00                	push   $0x0
  pushl $208
  102619:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10261e:	e9 a0 f7 ff ff       	jmp    101dc3 <__alltraps>

00102623 <vector209>:
.globl vector209
vector209:
  pushl $0
  102623:	6a 00                	push   $0x0
  pushl $209
  102625:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10262a:	e9 94 f7 ff ff       	jmp    101dc3 <__alltraps>

0010262f <vector210>:
.globl vector210
vector210:
  pushl $0
  10262f:	6a 00                	push   $0x0
  pushl $210
  102631:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102636:	e9 88 f7 ff ff       	jmp    101dc3 <__alltraps>

0010263b <vector211>:
.globl vector211
vector211:
  pushl $0
  10263b:	6a 00                	push   $0x0
  pushl $211
  10263d:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102642:	e9 7c f7 ff ff       	jmp    101dc3 <__alltraps>

00102647 <vector212>:
.globl vector212
vector212:
  pushl $0
  102647:	6a 00                	push   $0x0
  pushl $212
  102649:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10264e:	e9 70 f7 ff ff       	jmp    101dc3 <__alltraps>

00102653 <vector213>:
.globl vector213
vector213:
  pushl $0
  102653:	6a 00                	push   $0x0
  pushl $213
  102655:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10265a:	e9 64 f7 ff ff       	jmp    101dc3 <__alltraps>

0010265f <vector214>:
.globl vector214
vector214:
  pushl $0
  10265f:	6a 00                	push   $0x0
  pushl $214
  102661:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102666:	e9 58 f7 ff ff       	jmp    101dc3 <__alltraps>

0010266b <vector215>:
.globl vector215
vector215:
  pushl $0
  10266b:	6a 00                	push   $0x0
  pushl $215
  10266d:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102672:	e9 4c f7 ff ff       	jmp    101dc3 <__alltraps>

00102677 <vector216>:
.globl vector216
vector216:
  pushl $0
  102677:	6a 00                	push   $0x0
  pushl $216
  102679:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10267e:	e9 40 f7 ff ff       	jmp    101dc3 <__alltraps>

00102683 <vector217>:
.globl vector217
vector217:
  pushl $0
  102683:	6a 00                	push   $0x0
  pushl $217
  102685:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10268a:	e9 34 f7 ff ff       	jmp    101dc3 <__alltraps>

0010268f <vector218>:
.globl vector218
vector218:
  pushl $0
  10268f:	6a 00                	push   $0x0
  pushl $218
  102691:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102696:	e9 28 f7 ff ff       	jmp    101dc3 <__alltraps>

0010269b <vector219>:
.globl vector219
vector219:
  pushl $0
  10269b:	6a 00                	push   $0x0
  pushl $219
  10269d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026a2:	e9 1c f7 ff ff       	jmp    101dc3 <__alltraps>

001026a7 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026a7:	6a 00                	push   $0x0
  pushl $220
  1026a9:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026ae:	e9 10 f7 ff ff       	jmp    101dc3 <__alltraps>

001026b3 <vector221>:
.globl vector221
vector221:
  pushl $0
  1026b3:	6a 00                	push   $0x0
  pushl $221
  1026b5:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1026ba:	e9 04 f7 ff ff       	jmp    101dc3 <__alltraps>

001026bf <vector222>:
.globl vector222
vector222:
  pushl $0
  1026bf:	6a 00                	push   $0x0
  pushl $222
  1026c1:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1026c6:	e9 f8 f6 ff ff       	jmp    101dc3 <__alltraps>

001026cb <vector223>:
.globl vector223
vector223:
  pushl $0
  1026cb:	6a 00                	push   $0x0
  pushl $223
  1026cd:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1026d2:	e9 ec f6 ff ff       	jmp    101dc3 <__alltraps>

001026d7 <vector224>:
.globl vector224
vector224:
  pushl $0
  1026d7:	6a 00                	push   $0x0
  pushl $224
  1026d9:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1026de:	e9 e0 f6 ff ff       	jmp    101dc3 <__alltraps>

001026e3 <vector225>:
.globl vector225
vector225:
  pushl $0
  1026e3:	6a 00                	push   $0x0
  pushl $225
  1026e5:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1026ea:	e9 d4 f6 ff ff       	jmp    101dc3 <__alltraps>

001026ef <vector226>:
.globl vector226
vector226:
  pushl $0
  1026ef:	6a 00                	push   $0x0
  pushl $226
  1026f1:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026f6:	e9 c8 f6 ff ff       	jmp    101dc3 <__alltraps>

001026fb <vector227>:
.globl vector227
vector227:
  pushl $0
  1026fb:	6a 00                	push   $0x0
  pushl $227
  1026fd:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102702:	e9 bc f6 ff ff       	jmp    101dc3 <__alltraps>

00102707 <vector228>:
.globl vector228
vector228:
  pushl $0
  102707:	6a 00                	push   $0x0
  pushl $228
  102709:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10270e:	e9 b0 f6 ff ff       	jmp    101dc3 <__alltraps>

00102713 <vector229>:
.globl vector229
vector229:
  pushl $0
  102713:	6a 00                	push   $0x0
  pushl $229
  102715:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  10271a:	e9 a4 f6 ff ff       	jmp    101dc3 <__alltraps>

0010271f <vector230>:
.globl vector230
vector230:
  pushl $0
  10271f:	6a 00                	push   $0x0
  pushl $230
  102721:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102726:	e9 98 f6 ff ff       	jmp    101dc3 <__alltraps>

0010272b <vector231>:
.globl vector231
vector231:
  pushl $0
  10272b:	6a 00                	push   $0x0
  pushl $231
  10272d:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102732:	e9 8c f6 ff ff       	jmp    101dc3 <__alltraps>

00102737 <vector232>:
.globl vector232
vector232:
  pushl $0
  102737:	6a 00                	push   $0x0
  pushl $232
  102739:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10273e:	e9 80 f6 ff ff       	jmp    101dc3 <__alltraps>

00102743 <vector233>:
.globl vector233
vector233:
  pushl $0
  102743:	6a 00                	push   $0x0
  pushl $233
  102745:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10274a:	e9 74 f6 ff ff       	jmp    101dc3 <__alltraps>

0010274f <vector234>:
.globl vector234
vector234:
  pushl $0
  10274f:	6a 00                	push   $0x0
  pushl $234
  102751:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102756:	e9 68 f6 ff ff       	jmp    101dc3 <__alltraps>

0010275b <vector235>:
.globl vector235
vector235:
  pushl $0
  10275b:	6a 00                	push   $0x0
  pushl $235
  10275d:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102762:	e9 5c f6 ff ff       	jmp    101dc3 <__alltraps>

00102767 <vector236>:
.globl vector236
vector236:
  pushl $0
  102767:	6a 00                	push   $0x0
  pushl $236
  102769:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10276e:	e9 50 f6 ff ff       	jmp    101dc3 <__alltraps>

00102773 <vector237>:
.globl vector237
vector237:
  pushl $0
  102773:	6a 00                	push   $0x0
  pushl $237
  102775:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10277a:	e9 44 f6 ff ff       	jmp    101dc3 <__alltraps>

0010277f <vector238>:
.globl vector238
vector238:
  pushl $0
  10277f:	6a 00                	push   $0x0
  pushl $238
  102781:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102786:	e9 38 f6 ff ff       	jmp    101dc3 <__alltraps>

0010278b <vector239>:
.globl vector239
vector239:
  pushl $0
  10278b:	6a 00                	push   $0x0
  pushl $239
  10278d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102792:	e9 2c f6 ff ff       	jmp    101dc3 <__alltraps>

00102797 <vector240>:
.globl vector240
vector240:
  pushl $0
  102797:	6a 00                	push   $0x0
  pushl $240
  102799:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10279e:	e9 20 f6 ff ff       	jmp    101dc3 <__alltraps>

001027a3 <vector241>:
.globl vector241
vector241:
  pushl $0
  1027a3:	6a 00                	push   $0x0
  pushl $241
  1027a5:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027aa:	e9 14 f6 ff ff       	jmp    101dc3 <__alltraps>

001027af <vector242>:
.globl vector242
vector242:
  pushl $0
  1027af:	6a 00                	push   $0x0
  pushl $242
  1027b1:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1027b6:	e9 08 f6 ff ff       	jmp    101dc3 <__alltraps>

001027bb <vector243>:
.globl vector243
vector243:
  pushl $0
  1027bb:	6a 00                	push   $0x0
  pushl $243
  1027bd:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1027c2:	e9 fc f5 ff ff       	jmp    101dc3 <__alltraps>

001027c7 <vector244>:
.globl vector244
vector244:
  pushl $0
  1027c7:	6a 00                	push   $0x0
  pushl $244
  1027c9:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1027ce:	e9 f0 f5 ff ff       	jmp    101dc3 <__alltraps>

001027d3 <vector245>:
.globl vector245
vector245:
  pushl $0
  1027d3:	6a 00                	push   $0x0
  pushl $245
  1027d5:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027da:	e9 e4 f5 ff ff       	jmp    101dc3 <__alltraps>

001027df <vector246>:
.globl vector246
vector246:
  pushl $0
  1027df:	6a 00                	push   $0x0
  pushl $246
  1027e1:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1027e6:	e9 d8 f5 ff ff       	jmp    101dc3 <__alltraps>

001027eb <vector247>:
.globl vector247
vector247:
  pushl $0
  1027eb:	6a 00                	push   $0x0
  pushl $247
  1027ed:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027f2:	e9 cc f5 ff ff       	jmp    101dc3 <__alltraps>

001027f7 <vector248>:
.globl vector248
vector248:
  pushl $0
  1027f7:	6a 00                	push   $0x0
  pushl $248
  1027f9:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027fe:	e9 c0 f5 ff ff       	jmp    101dc3 <__alltraps>

00102803 <vector249>:
.globl vector249
vector249:
  pushl $0
  102803:	6a 00                	push   $0x0
  pushl $249
  102805:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10280a:	e9 b4 f5 ff ff       	jmp    101dc3 <__alltraps>

0010280f <vector250>:
.globl vector250
vector250:
  pushl $0
  10280f:	6a 00                	push   $0x0
  pushl $250
  102811:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102816:	e9 a8 f5 ff ff       	jmp    101dc3 <__alltraps>

0010281b <vector251>:
.globl vector251
vector251:
  pushl $0
  10281b:	6a 00                	push   $0x0
  pushl $251
  10281d:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102822:	e9 9c f5 ff ff       	jmp    101dc3 <__alltraps>

00102827 <vector252>:
.globl vector252
vector252:
  pushl $0
  102827:	6a 00                	push   $0x0
  pushl $252
  102829:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  10282e:	e9 90 f5 ff ff       	jmp    101dc3 <__alltraps>

00102833 <vector253>:
.globl vector253
vector253:
  pushl $0
  102833:	6a 00                	push   $0x0
  pushl $253
  102835:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10283a:	e9 84 f5 ff ff       	jmp    101dc3 <__alltraps>

0010283f <vector254>:
.globl vector254
vector254:
  pushl $0
  10283f:	6a 00                	push   $0x0
  pushl $254
  102841:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102846:	e9 78 f5 ff ff       	jmp    101dc3 <__alltraps>

0010284b <vector255>:
.globl vector255
vector255:
  pushl $0
  10284b:	6a 00                	push   $0x0
  pushl $255
  10284d:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102852:	e9 6c f5 ff ff       	jmp    101dc3 <__alltraps>

00102857 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102857:	55                   	push   %ebp
  102858:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10285a:	8b 55 08             	mov    0x8(%ebp),%edx
  10285d:	a1 24 af 11 00       	mov    0x11af24,%eax
  102862:	29 c2                	sub    %eax,%edx
  102864:	89 d0                	mov    %edx,%eax
  102866:	c1 f8 02             	sar    $0x2,%eax
  102869:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10286f:	5d                   	pop    %ebp
  102870:	c3                   	ret    

00102871 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102871:	55                   	push   %ebp
  102872:	89 e5                	mov    %esp,%ebp
  102874:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102877:	8b 45 08             	mov    0x8(%ebp),%eax
  10287a:	89 04 24             	mov    %eax,(%esp)
  10287d:	e8 d5 ff ff ff       	call   102857 <page2ppn>
  102882:	c1 e0 0c             	shl    $0xc,%eax
}
  102885:	c9                   	leave  
  102886:	c3                   	ret    

00102887 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102887:	55                   	push   %ebp
  102888:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10288a:	8b 45 08             	mov    0x8(%ebp),%eax
  10288d:	8b 00                	mov    (%eax),%eax
}
  10288f:	5d                   	pop    %ebp
  102890:	c3                   	ret    

00102891 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102891:	55                   	push   %ebp
  102892:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102894:	8b 45 08             	mov    0x8(%ebp),%eax
  102897:	8b 55 0c             	mov    0xc(%ebp),%edx
  10289a:	89 10                	mov    %edx,(%eax)
}
  10289c:	5d                   	pop    %ebp
  10289d:	c3                   	ret    

0010289e <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10289e:	55                   	push   %ebp
  10289f:	89 e5                	mov    %esp,%ebp
  1028a1:	83 ec 10             	sub    $0x10,%esp
  1028a4:	c7 45 fc 10 af 11 00 	movl   $0x11af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1028ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1028b1:	89 50 04             	mov    %edx,0x4(%eax)
  1028b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028b7:	8b 50 04             	mov    0x4(%eax),%edx
  1028ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1028bd:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  1028bf:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  1028c6:	00 00 00 
}
  1028c9:	c9                   	leave  
  1028ca:	c3                   	ret    

001028cb <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  1028cb:	55                   	push   %ebp
  1028cc:	89 e5                	mov    %esp,%ebp
  1028ce:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  1028d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1028d5:	75 24                	jne    1028fb <default_init_memmap+0x30>
  1028d7:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  1028de:	00 
  1028df:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1028e6:	00 
  1028e7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  1028ee:	00 
  1028ef:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1028f6:	e8 e2 e3 ff ff       	call   100cdd <__panic>
    struct Page *p = base;
  1028fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1028fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102901:	eb 7d                	jmp    102980 <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102903:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102906:	83 c0 04             	add    $0x4,%eax
  102909:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102910:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102913:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102916:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102919:	0f a3 10             	bt     %edx,(%eax)
  10291c:	19 c0                	sbb    %eax,%eax
  10291e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102921:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102925:	0f 95 c0             	setne  %al
  102928:	0f b6 c0             	movzbl %al,%eax
  10292b:	85 c0                	test   %eax,%eax
  10292d:	75 24                	jne    102953 <default_init_memmap+0x88>
  10292f:	c7 44 24 0c 01 67 10 	movl   $0x106701,0xc(%esp)
  102936:	00 
  102937:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10293e:	00 
  10293f:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  102946:	00 
  102947:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10294e:	e8 8a e3 ff ff       	call   100cdd <__panic>
        p->flags = p->property = 0;
  102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102956:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10295d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102960:	8b 50 08             	mov    0x8(%eax),%edx
  102963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102966:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102969:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102970:	00 
  102971:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102974:	89 04 24             	mov    %eax,(%esp)
  102977:	e8 15 ff ff ff       	call   102891 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  10297c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102980:	8b 55 0c             	mov    0xc(%ebp),%edx
  102983:	89 d0                	mov    %edx,%eax
  102985:	c1 e0 02             	shl    $0x2,%eax
  102988:	01 d0                	add    %edx,%eax
  10298a:	c1 e0 02             	shl    $0x2,%eax
  10298d:	89 c2                	mov    %eax,%edx
  10298f:	8b 45 08             	mov    0x8(%ebp),%eax
  102992:	01 d0                	add    %edx,%eax
  102994:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102997:	0f 85 66 ff ff ff    	jne    102903 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  10299d:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1029a3:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  1029a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a9:	83 c0 04             	add    $0x4,%eax
  1029ac:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1029b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1029b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1029b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1029bc:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  1029bf:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  1029c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029c8:	01 d0                	add    %edx,%eax
  1029ca:	a3 18 af 11 00       	mov    %eax,0x11af18
    list_add_before(&free_list, &(base->page_link));
  1029cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1029d2:	83 c0 0c             	add    $0xc,%eax
  1029d5:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
  1029dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1029df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1029e2:	8b 00                	mov    (%eax),%eax
  1029e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1029e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1029ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1029ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1029f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1029f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1029f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1029f9:	89 10                	mov    %edx,(%eax)
  1029fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1029fe:	8b 10                	mov    (%eax),%edx
  102a00:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a03:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102a06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a09:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102a0c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102a0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102a12:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102a15:	89 10                	mov    %edx,(%eax)
}
  102a17:	c9                   	leave  
  102a18:	c3                   	ret    

00102a19 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  102a19:	55                   	push   %ebp
  102a1a:	89 e5                	mov    %esp,%ebp
  102a1c:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  102a1f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102a23:	75 24                	jne    102a49 <default_alloc_pages+0x30>
  102a25:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  102a2c:	00 
  102a2d:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102a34:	00 
  102a35:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  102a3c:	00 
  102a3d:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102a44:	e8 94 e2 ff ff       	call   100cdd <__panic>
    if (n > nr_free) {
  102a49:	a1 18 af 11 00       	mov    0x11af18,%eax
  102a4e:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a51:	73 0a                	jae    102a5d <default_alloc_pages+0x44>
        return NULL;
  102a53:	b8 00 00 00 00       	mov    $0x0,%eax
  102a58:	e9 3d 01 00 00       	jmp    102b9a <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
  102a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102a64:	c7 45 f0 10 af 11 00 	movl   $0x11af10,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  102a6b:	eb 1c                	jmp    102a89 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  102a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a70:	83 e8 0c             	sub    $0xc,%eax
  102a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a79:	8b 40 08             	mov    0x8(%eax),%eax
  102a7c:	3b 45 08             	cmp    0x8(%ebp),%eax
  102a7f:	72 08                	jb     102a89 <default_alloc_pages+0x70>
            page = p;
  102a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102a87:	eb 18                	jmp    102aa1 <default_alloc_pages+0x88>
  102a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102a92:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
  102a95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a98:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102a9f:	75 cc                	jne    102a6d <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  102aa1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102aa5:	0f 84 ec 00 00 00    	je     102b97 <default_alloc_pages+0x17e>
       // list_del(&(page->page_link)); LAB2 comment here
        if (page->property > n) {
  102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102aae:	8b 40 08             	mov    0x8(%eax),%eax
  102ab1:	3b 45 08             	cmp    0x8(%ebp),%eax
  102ab4:	0f 86 8c 00 00 00    	jbe    102b46 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
  102aba:	8b 55 08             	mov    0x8(%ebp),%edx
  102abd:	89 d0                	mov    %edx,%eax
  102abf:	c1 e0 02             	shl    $0x2,%eax
  102ac2:	01 d0                	add    %edx,%eax
  102ac4:	c1 e0 02             	shl    $0x2,%eax
  102ac7:	89 c2                	mov    %eax,%edx
  102ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102acc:	01 d0                	add    %edx,%eax
  102ace:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
  102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ad4:	8b 40 08             	mov    0x8(%eax),%eax
  102ad7:	2b 45 08             	sub    0x8(%ebp),%eax
  102ada:	89 c2                	mov    %eax,%edx
  102adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102adf:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);//LAB2 change here
  102ae2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102ae5:	83 c0 04             	add    $0x4,%eax
  102ae8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102aef:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102af2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102af5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102af8:	0f ab 10             	bts    %edx,(%eax)
           // list_add(&free_list, &(p->page_link));
            list_add_after(&(page->page_link), &(p->page_link));//LAB2 change here
  102afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102afe:	83 c0 0c             	add    $0xc,%eax
  102b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b04:	83 c2 0c             	add    $0xc,%edx
  102b07:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102b0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102b0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b10:	8b 40 04             	mov    0x4(%eax),%eax
  102b13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102b16:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102b19:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102b1c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  102b1f:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102b22:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b25:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102b28:	89 10                	mov    %edx,(%eax)
  102b2a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102b2d:	8b 10                	mov    (%eax),%edx
  102b2f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102b32:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102b35:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b38:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102b3b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102b3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102b41:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102b44:	89 10                	mov    %edx,(%eax)

 }
        list_del(&(page->page_link));//LAB2 change here
  102b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b49:	83 c0 0c             	add    $0xc,%eax
  102b4c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102b4f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102b52:	8b 40 04             	mov    0x4(%eax),%eax
  102b55:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102b58:	8b 12                	mov    (%edx),%edx
  102b5a:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102b5d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102b60:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102b63:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102b66:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102b69:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102b6c:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102b6f:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  102b71:	a1 18 af 11 00       	mov    0x11af18,%eax
  102b76:	2b 45 08             	sub    0x8(%ebp),%eax
  102b79:	a3 18 af 11 00       	mov    %eax,0x11af18
        ClearPageProperty(page);
  102b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b81:	83 c0 04             	add    $0x4,%eax
  102b84:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102b8b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102b8e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102b91:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102b94:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  102b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102b9a:	c9                   	leave  
  102b9b:	c3                   	ret    

00102b9c <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  102b9c:	55                   	push   %ebp
  102b9d:	89 e5                	mov    %esp,%ebp
  102b9f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102ba5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102ba9:	75 24                	jne    102bcf <default_free_pages+0x33>
  102bab:	c7 44 24 0c d0 66 10 	movl   $0x1066d0,0xc(%esp)
  102bb2:	00 
  102bb3:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102bba:	00 
  102bbb:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  102bc2:	00 
  102bc3:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102bca:	e8 0e e1 ff ff       	call   100cdd <__panic>
    struct Page *p = base;
  102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102bd5:	e9 9d 00 00 00       	jmp    102c77 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bdd:	83 c0 04             	add    $0x4,%eax
  102be0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102be7:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102bea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102bed:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102bf0:	0f a3 10             	bt     %edx,(%eax)
  102bf3:	19 c0                	sbb    %eax,%eax
  102bf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102bf8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102bfc:	0f 95 c0             	setne  %al
  102bff:	0f b6 c0             	movzbl %al,%eax
  102c02:	85 c0                	test   %eax,%eax
  102c04:	75 2c                	jne    102c32 <default_free_pages+0x96>
  102c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c09:	83 c0 04             	add    $0x4,%eax
  102c0c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102c13:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102c16:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c19:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102c1c:	0f a3 10             	bt     %edx,(%eax)
  102c1f:	19 c0                	sbb    %eax,%eax
  102c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102c24:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102c28:	0f 95 c0             	setne  %al
  102c2b:	0f b6 c0             	movzbl %al,%eax
  102c2e:	85 c0                	test   %eax,%eax
  102c30:	74 24                	je     102c56 <default_free_pages+0xba>
  102c32:	c7 44 24 0c 14 67 10 	movl   $0x106714,0xc(%esp)
  102c39:	00 
  102c3a:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102c41:	00 
  102c42:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
  102c49:	00 
  102c4a:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102c51:	e8 87 e0 ff ff       	call   100cdd <__panic>
        p->flags = 0;
  102c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c59:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102c60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102c67:	00 
  102c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c6b:	89 04 24             	mov    %eax,(%esp)
  102c6e:	e8 1e fc ff ff       	call   102891 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  102c73:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102c77:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c7a:	89 d0                	mov    %edx,%eax
  102c7c:	c1 e0 02             	shl    $0x2,%eax
  102c7f:	01 d0                	add    %edx,%eax
  102c81:	c1 e0 02             	shl    $0x2,%eax
  102c84:	89 c2                	mov    %eax,%edx
  102c86:	8b 45 08             	mov    0x8(%ebp),%eax
  102c89:	01 d0                	add    %edx,%eax
  102c8b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102c8e:	0f 85 46 ff ff ff    	jne    102bda <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  102c94:	8b 45 08             	mov    0x8(%ebp),%eax
  102c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c9a:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102ca0:	83 c0 04             	add    $0x4,%eax
  102ca3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  102caa:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102cad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102cb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102cb3:	0f ab 10             	bts    %edx,(%eax)
  102cb6:	c7 45 cc 10 af 11 00 	movl   $0x11af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102cbd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102cc0:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  102cc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102cc6:	e9 08 01 00 00       	jmp    102dd3 <default_free_pages+0x237>
        p = le2page(le, page_link);
  102ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cce:	83 e8 0c             	sub    $0xc,%eax
  102cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cd7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102cda:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102cdd:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102ce0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
  102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce6:	8b 50 08             	mov    0x8(%eax),%edx
  102ce9:	89 d0                	mov    %edx,%eax
  102ceb:	c1 e0 02             	shl    $0x2,%eax
  102cee:	01 d0                	add    %edx,%eax
  102cf0:	c1 e0 02             	shl    $0x2,%eax
  102cf3:	89 c2                	mov    %eax,%edx
  102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf8:	01 d0                	add    %edx,%eax
  102cfa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102cfd:	75 5a                	jne    102d59 <default_free_pages+0x1bd>
            base->property += p->property;
  102cff:	8b 45 08             	mov    0x8(%ebp),%eax
  102d02:	8b 50 08             	mov    0x8(%eax),%edx
  102d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d08:	8b 40 08             	mov    0x8(%eax),%eax
  102d0b:	01 c2                	add    %eax,%edx
  102d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  102d10:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d16:	83 c0 04             	add    $0x4,%eax
  102d19:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102d20:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d23:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102d26:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102d29:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  102d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d2f:	83 c0 0c             	add    $0xc,%eax
  102d32:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102d35:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d38:	8b 40 04             	mov    0x4(%eax),%eax
  102d3b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d3e:	8b 12                	mov    (%edx),%edx
  102d40:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102d43:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102d46:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102d49:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d4c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102d4f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102d52:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102d55:	89 10                	mov    %edx,(%eax)
  102d57:	eb 7a                	jmp    102dd3 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
  102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d5c:	8b 50 08             	mov    0x8(%eax),%edx
  102d5f:	89 d0                	mov    %edx,%eax
  102d61:	c1 e0 02             	shl    $0x2,%eax
  102d64:	01 d0                	add    %edx,%eax
  102d66:	c1 e0 02             	shl    $0x2,%eax
  102d69:	89 c2                	mov    %eax,%edx
  102d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d6e:	01 d0                	add    %edx,%eax
  102d70:	3b 45 08             	cmp    0x8(%ebp),%eax
  102d73:	75 5e                	jne    102dd3 <default_free_pages+0x237>
            p->property += base->property;
  102d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d78:	8b 50 08             	mov    0x8(%eax),%edx
  102d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d7e:	8b 40 08             	mov    0x8(%eax),%eax
  102d81:	01 c2                	add    %eax,%edx
  102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d86:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102d89:	8b 45 08             	mov    0x8(%ebp),%eax
  102d8c:	83 c0 04             	add    $0x4,%eax
  102d8f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  102d96:	89 45 ac             	mov    %eax,-0x54(%ebp)
  102d99:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102d9c:	8b 55 b0             	mov    -0x50(%ebp),%edx
  102d9f:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  102da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102da5:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dab:	83 c0 0c             	add    $0xc,%eax
  102dae:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  102db1:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102db4:	8b 40 04             	mov    0x4(%eax),%eax
  102db7:	8b 55 a8             	mov    -0x58(%ebp),%edx
  102dba:	8b 12                	mov    (%edx),%edx
  102dbc:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102dbf:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102dc2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102dc5:	8b 55 a0             	mov    -0x60(%ebp),%edx
  102dc8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102dcb:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102dce:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102dd1:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  102dd3:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102dda:	0f 85 eb fe ff ff    	jne    102ccb <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  102de0:	8b 15 18 af 11 00    	mov    0x11af18,%edx
  102de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102de9:	01 d0                	add    %edx,%eax
  102deb:	a3 18 af 11 00       	mov    %eax,0x11af18
  102df0:	c7 45 9c 10 af 11 00 	movl   $0x11af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  102df7:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102dfa:	8b 40 04             	mov    0x4(%eax),%eax
    //LAB2 change here up
    le = list_next(&free_list);
  102dfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  102e00:	eb 76                	jmp    102e78 <default_free_pages+0x2dc>
        p = le2page(le, page_link);
  102e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e05:	83 e8 0c             	sub    $0xc,%eax
  102e08:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  102e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0e:	8b 50 08             	mov    0x8(%eax),%edx
  102e11:	89 d0                	mov    %edx,%eax
  102e13:	c1 e0 02             	shl    $0x2,%eax
  102e16:	01 d0                	add    %edx,%eax
  102e18:	c1 e0 02             	shl    $0x2,%eax
  102e1b:	89 c2                	mov    %eax,%edx
  102e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102e20:	01 d0                	add    %edx,%eax
  102e22:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e25:	77 42                	ja     102e69 <default_free_pages+0x2cd>
            assert(base + base->property != p);
  102e27:	8b 45 08             	mov    0x8(%ebp),%eax
  102e2a:	8b 50 08             	mov    0x8(%eax),%edx
  102e2d:	89 d0                	mov    %edx,%eax
  102e2f:	c1 e0 02             	shl    $0x2,%eax
  102e32:	01 d0                	add    %edx,%eax
  102e34:	c1 e0 02             	shl    $0x2,%eax
  102e37:	89 c2                	mov    %eax,%edx
  102e39:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3c:	01 d0                	add    %edx,%eax
  102e3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102e41:	75 24                	jne    102e67 <default_free_pages+0x2cb>
  102e43:	c7 44 24 0c 39 67 10 	movl   $0x106739,0xc(%esp)
  102e4a:	00 
  102e4b:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102e52:	00 
  102e53:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
  102e5a:	00 
  102e5b:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102e62:	e8 76 de ff ff       	call   100cdd <__panic>
            break;
  102e67:	eb 18                	jmp    102e81 <default_free_pages+0x2e5>
  102e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e6c:	89 45 98             	mov    %eax,-0x68(%ebp)
  102e6f:	8b 45 98             	mov    -0x68(%ebp),%eax
  102e72:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
  102e75:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    nr_free += n;
    //LAB2 change here up
    le = list_next(&free_list);
    while (le != &free_list) {
  102e78:	81 7d f0 10 af 11 00 	cmpl   $0x11af10,-0x10(%ebp)
  102e7f:	75 81                	jne    102e02 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
  102e81:	8b 45 08             	mov    0x8(%ebp),%eax
  102e84:	8d 50 0c             	lea    0xc(%eax),%edx
  102e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e8a:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102e8d:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  102e90:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102e93:	8b 00                	mov    (%eax),%eax
  102e95:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e98:	89 55 8c             	mov    %edx,-0x74(%ebp)
  102e9b:	89 45 88             	mov    %eax,-0x78(%ebp)
  102e9e:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102ea1:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102ea4:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102ea7:	8b 55 8c             	mov    -0x74(%ebp),%edx
  102eaa:	89 10                	mov    %edx,(%eax)
  102eac:	8b 45 84             	mov    -0x7c(%ebp),%eax
  102eaf:	8b 10                	mov    (%eax),%edx
  102eb1:	8b 45 88             	mov    -0x78(%ebp),%eax
  102eb4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102eb7:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102eba:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102ebd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102ec0:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102ec3:	8b 55 88             	mov    -0x78(%ebp),%edx
  102ec6:	89 10                	mov    %edx,(%eax)
//LAB2 change here bottom
}
  102ec8:	c9                   	leave  
  102ec9:	c3                   	ret    

00102eca <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  102eca:	55                   	push   %ebp
  102ecb:	89 e5                	mov    %esp,%ebp
    return nr_free;
  102ecd:	a1 18 af 11 00       	mov    0x11af18,%eax
}
  102ed2:	5d                   	pop    %ebp
  102ed3:	c3                   	ret    

00102ed4 <basic_check>:

static void
basic_check(void) {
  102ed4:	55                   	push   %ebp
  102ed5:	89 e5                	mov    %esp,%ebp
  102ed7:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  102eda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  102ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  102eed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102ef4:	e8 9d 0e 00 00       	call   103d96 <alloc_pages>
  102ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102efc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  102f00:	75 24                	jne    102f26 <basic_check+0x52>
  102f02:	c7 44 24 0c 54 67 10 	movl   $0x106754,0xc(%esp)
  102f09:	00 
  102f0a:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102f11:	00 
  102f12:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  102f19:	00 
  102f1a:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102f21:	e8 b7 dd ff ff       	call   100cdd <__panic>
    assert((p1 = alloc_page()) != NULL);
  102f26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f2d:	e8 64 0e 00 00       	call   103d96 <alloc_pages>
  102f32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f39:	75 24                	jne    102f5f <basic_check+0x8b>
  102f3b:	c7 44 24 0c 70 67 10 	movl   $0x106770,0xc(%esp)
  102f42:	00 
  102f43:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102f4a:	00 
  102f4b:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  102f52:	00 
  102f53:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102f5a:	e8 7e dd ff ff       	call   100cdd <__panic>
    assert((p2 = alloc_page()) != NULL);
  102f5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  102f66:	e8 2b 0e 00 00       	call   103d96 <alloc_pages>
  102f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102f72:	75 24                	jne    102f98 <basic_check+0xc4>
  102f74:	c7 44 24 0c 8c 67 10 	movl   $0x10678c,0xc(%esp)
  102f7b:	00 
  102f7c:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102f83:	00 
  102f84:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  102f8b:	00 
  102f8c:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102f93:	e8 45 dd ff ff       	call   100cdd <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  102f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f9b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  102f9e:	74 10                	je     102fb0 <basic_check+0xdc>
  102fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fa3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102fa6:	74 08                	je     102fb0 <basic_check+0xdc>
  102fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  102fae:	75 24                	jne    102fd4 <basic_check+0x100>
  102fb0:	c7 44 24 0c a8 67 10 	movl   $0x1067a8,0xc(%esp)
  102fb7:	00 
  102fb8:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  102fbf:	00 
  102fc0:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
  102fc7:	00 
  102fc8:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  102fcf:	e8 09 dd ff ff       	call   100cdd <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  102fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fd7:	89 04 24             	mov    %eax,(%esp)
  102fda:	e8 a8 f8 ff ff       	call   102887 <page_ref>
  102fdf:	85 c0                	test   %eax,%eax
  102fe1:	75 1e                	jne    103001 <basic_check+0x12d>
  102fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fe6:	89 04 24             	mov    %eax,(%esp)
  102fe9:	e8 99 f8 ff ff       	call   102887 <page_ref>
  102fee:	85 c0                	test   %eax,%eax
  102ff0:	75 0f                	jne    103001 <basic_check+0x12d>
  102ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ff5:	89 04 24             	mov    %eax,(%esp)
  102ff8:	e8 8a f8 ff ff       	call   102887 <page_ref>
  102ffd:	85 c0                	test   %eax,%eax
  102fff:	74 24                	je     103025 <basic_check+0x151>
  103001:	c7 44 24 0c cc 67 10 	movl   $0x1067cc,0xc(%esp)
  103008:	00 
  103009:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103010:	00 
  103011:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
  103018:	00 
  103019:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103020:	e8 b8 dc ff ff       	call   100cdd <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  103025:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103028:	89 04 24             	mov    %eax,(%esp)
  10302b:	e8 41 f8 ff ff       	call   102871 <page2pa>
  103030:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103036:	c1 e2 0c             	shl    $0xc,%edx
  103039:	39 d0                	cmp    %edx,%eax
  10303b:	72 24                	jb     103061 <basic_check+0x18d>
  10303d:	c7 44 24 0c 08 68 10 	movl   $0x106808,0xc(%esp)
  103044:	00 
  103045:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10304c:	00 
  10304d:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  103054:	00 
  103055:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10305c:	e8 7c dc ff ff       	call   100cdd <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  103061:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103064:	89 04 24             	mov    %eax,(%esp)
  103067:	e8 05 f8 ff ff       	call   102871 <page2pa>
  10306c:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  103072:	c1 e2 0c             	shl    $0xc,%edx
  103075:	39 d0                	cmp    %edx,%eax
  103077:	72 24                	jb     10309d <basic_check+0x1c9>
  103079:	c7 44 24 0c 25 68 10 	movl   $0x106825,0xc(%esp)
  103080:	00 
  103081:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103088:	00 
  103089:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
  103090:	00 
  103091:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103098:	e8 40 dc ff ff       	call   100cdd <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  10309d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030a0:	89 04 24             	mov    %eax,(%esp)
  1030a3:	e8 c9 f7 ff ff       	call   102871 <page2pa>
  1030a8:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  1030ae:	c1 e2 0c             	shl    $0xc,%edx
  1030b1:	39 d0                	cmp    %edx,%eax
  1030b3:	72 24                	jb     1030d9 <basic_check+0x205>
  1030b5:	c7 44 24 0c 42 68 10 	movl   $0x106842,0xc(%esp)
  1030bc:	00 
  1030bd:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1030c4:	00 
  1030c5:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
  1030cc:	00 
  1030cd:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1030d4:	e8 04 dc ff ff       	call   100cdd <__panic>

    list_entry_t free_list_store = free_list;
  1030d9:	a1 10 af 11 00       	mov    0x11af10,%eax
  1030de:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  1030e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1030ea:	c7 45 e0 10 af 11 00 	movl   $0x11af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1030f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1030f7:	89 50 04             	mov    %edx,0x4(%eax)
  1030fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030fd:	8b 50 04             	mov    0x4(%eax),%edx
  103100:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103103:	89 10                	mov    %edx,(%eax)
  103105:	c7 45 dc 10 af 11 00 	movl   $0x11af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  10310c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10310f:	8b 40 04             	mov    0x4(%eax),%eax
  103112:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103115:	0f 94 c0             	sete   %al
  103118:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10311b:	85 c0                	test   %eax,%eax
  10311d:	75 24                	jne    103143 <basic_check+0x26f>
  10311f:	c7 44 24 0c 5f 68 10 	movl   $0x10685f,0xc(%esp)
  103126:	00 
  103127:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10312e:	00 
  10312f:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  103136:	00 
  103137:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10313e:	e8 9a db ff ff       	call   100cdd <__panic>

    unsigned int nr_free_store = nr_free;
  103143:	a1 18 af 11 00       	mov    0x11af18,%eax
  103148:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  10314b:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  103152:	00 00 00 

    assert(alloc_page() == NULL);
  103155:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10315c:	e8 35 0c 00 00       	call   103d96 <alloc_pages>
  103161:	85 c0                	test   %eax,%eax
  103163:	74 24                	je     103189 <basic_check+0x2b5>
  103165:	c7 44 24 0c 76 68 10 	movl   $0x106876,0xc(%esp)
  10316c:	00 
  10316d:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103174:	00 
  103175:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  10317c:	00 
  10317d:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103184:	e8 54 db ff ff       	call   100cdd <__panic>

    free_page(p0);
  103189:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103190:	00 
  103191:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103194:	89 04 24             	mov    %eax,(%esp)
  103197:	e8 32 0c 00 00       	call   103dce <free_pages>
    free_page(p1);
  10319c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031a3:	00 
  1031a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031a7:	89 04 24             	mov    %eax,(%esp)
  1031aa:	e8 1f 0c 00 00       	call   103dce <free_pages>
    free_page(p2);
  1031af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1031b6:	00 
  1031b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031ba:	89 04 24             	mov    %eax,(%esp)
  1031bd:	e8 0c 0c 00 00       	call   103dce <free_pages>
    assert(nr_free == 3);
  1031c2:	a1 18 af 11 00       	mov    0x11af18,%eax
  1031c7:	83 f8 03             	cmp    $0x3,%eax
  1031ca:	74 24                	je     1031f0 <basic_check+0x31c>
  1031cc:	c7 44 24 0c 8b 68 10 	movl   $0x10688b,0xc(%esp)
  1031d3:	00 
  1031d4:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1031db:	00 
  1031dc:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
  1031e3:	00 
  1031e4:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1031eb:	e8 ed da ff ff       	call   100cdd <__panic>

    assert((p0 = alloc_page()) != NULL);
  1031f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031f7:	e8 9a 0b 00 00       	call   103d96 <alloc_pages>
  1031fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1031ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103203:	75 24                	jne    103229 <basic_check+0x355>
  103205:	c7 44 24 0c 54 67 10 	movl   $0x106754,0xc(%esp)
  10320c:	00 
  10320d:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103214:	00 
  103215:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  10321c:	00 
  10321d:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103224:	e8 b4 da ff ff       	call   100cdd <__panic>
    assert((p1 = alloc_page()) != NULL);
  103229:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103230:	e8 61 0b 00 00       	call   103d96 <alloc_pages>
  103235:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103238:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10323c:	75 24                	jne    103262 <basic_check+0x38e>
  10323e:	c7 44 24 0c 70 67 10 	movl   $0x106770,0xc(%esp)
  103245:	00 
  103246:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10324d:	00 
  10324e:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
  103255:	00 
  103256:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10325d:	e8 7b da ff ff       	call   100cdd <__panic>
    assert((p2 = alloc_page()) != NULL);
  103262:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103269:	e8 28 0b 00 00       	call   103d96 <alloc_pages>
  10326e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103271:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103275:	75 24                	jne    10329b <basic_check+0x3c7>
  103277:	c7 44 24 0c 8c 67 10 	movl   $0x10678c,0xc(%esp)
  10327e:	00 
  10327f:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103286:	00 
  103287:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
  10328e:	00 
  10328f:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103296:	e8 42 da ff ff       	call   100cdd <__panic>

    assert(alloc_page() == NULL);
  10329b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1032a2:	e8 ef 0a 00 00       	call   103d96 <alloc_pages>
  1032a7:	85 c0                	test   %eax,%eax
  1032a9:	74 24                	je     1032cf <basic_check+0x3fb>
  1032ab:	c7 44 24 0c 76 68 10 	movl   $0x106876,0xc(%esp)
  1032b2:	00 
  1032b3:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1032ba:	00 
  1032bb:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  1032c2:	00 
  1032c3:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1032ca:	e8 0e da ff ff       	call   100cdd <__panic>

    free_page(p0);
  1032cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1032d6:	00 
  1032d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032da:	89 04 24             	mov    %eax,(%esp)
  1032dd:	e8 ec 0a 00 00       	call   103dce <free_pages>
  1032e2:	c7 45 d8 10 af 11 00 	movl   $0x11af10,-0x28(%ebp)
  1032e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1032ec:	8b 40 04             	mov    0x4(%eax),%eax
  1032ef:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1032f2:	0f 94 c0             	sete   %al
  1032f5:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  1032f8:	85 c0                	test   %eax,%eax
  1032fa:	74 24                	je     103320 <basic_check+0x44c>
  1032fc:	c7 44 24 0c 98 68 10 	movl   $0x106898,0xc(%esp)
  103303:	00 
  103304:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10330b:	00 
  10330c:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  103313:	00 
  103314:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10331b:	e8 bd d9 ff ff       	call   100cdd <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103320:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103327:	e8 6a 0a 00 00       	call   103d96 <alloc_pages>
  10332c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10332f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103332:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  103335:	74 24                	je     10335b <basic_check+0x487>
  103337:	c7 44 24 0c b0 68 10 	movl   $0x1068b0,0xc(%esp)
  10333e:	00 
  10333f:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103346:	00 
  103347:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  10334e:	00 
  10334f:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103356:	e8 82 d9 ff ff       	call   100cdd <__panic>
    assert(alloc_page() == NULL);
  10335b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103362:	e8 2f 0a 00 00       	call   103d96 <alloc_pages>
  103367:	85 c0                	test   %eax,%eax
  103369:	74 24                	je     10338f <basic_check+0x4bb>
  10336b:	c7 44 24 0c 76 68 10 	movl   $0x106876,0xc(%esp)
  103372:	00 
  103373:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10337a:	00 
  10337b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
  103382:	00 
  103383:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10338a:	e8 4e d9 ff ff       	call   100cdd <__panic>

    assert(nr_free == 0);
  10338f:	a1 18 af 11 00       	mov    0x11af18,%eax
  103394:	85 c0                	test   %eax,%eax
  103396:	74 24                	je     1033bc <basic_check+0x4e8>
  103398:	c7 44 24 0c c9 68 10 	movl   $0x1068c9,0xc(%esp)
  10339f:	00 
  1033a0:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1033a7:	00 
  1033a8:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
  1033af:	00 
  1033b0:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1033b7:	e8 21 d9 ff ff       	call   100cdd <__panic>
    free_list = free_list_store;
  1033bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1033bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1033c2:	a3 10 af 11 00       	mov    %eax,0x11af10
  1033c7:	89 15 14 af 11 00    	mov    %edx,0x11af14
    nr_free = nr_free_store;
  1033cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1033d0:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_page(p);
  1033d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033dc:	00 
  1033dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1033e0:	89 04 24             	mov    %eax,(%esp)
  1033e3:	e8 e6 09 00 00       	call   103dce <free_pages>
    free_page(p1);
  1033e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033ef:	00 
  1033f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033f3:	89 04 24             	mov    %eax,(%esp)
  1033f6:	e8 d3 09 00 00       	call   103dce <free_pages>
    free_page(p2);
  1033fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103402:	00 
  103403:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103406:	89 04 24             	mov    %eax,(%esp)
  103409:	e8 c0 09 00 00       	call   103dce <free_pages>
}
  10340e:	c9                   	leave  
  10340f:	c3                   	ret    

00103410 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  103410:	55                   	push   %ebp
  103411:	89 e5                	mov    %esp,%ebp
  103413:	53                   	push   %ebx
  103414:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
  10341a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103421:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103428:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10342f:	eb 6b                	jmp    10349c <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
  103431:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103434:	83 e8 0c             	sub    $0xc,%eax
  103437:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
  10343a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10343d:	83 c0 04             	add    $0x4,%eax
  103440:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  103447:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10344a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10344d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103450:	0f a3 10             	bt     %edx,(%eax)
  103453:	19 c0                	sbb    %eax,%eax
  103455:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  103458:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  10345c:	0f 95 c0             	setne  %al
  10345f:	0f b6 c0             	movzbl %al,%eax
  103462:	85 c0                	test   %eax,%eax
  103464:	75 24                	jne    10348a <default_check+0x7a>
  103466:	c7 44 24 0c d6 68 10 	movl   $0x1068d6,0xc(%esp)
  10346d:	00 
  10346e:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103475:	00 
  103476:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  10347d:	00 
  10347e:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103485:	e8 53 d8 ff ff       	call   100cdd <__panic>
        count ++, total += p->property;
  10348a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  10348e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103491:	8b 50 08             	mov    0x8(%eax),%edx
  103494:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103497:	01 d0                	add    %edx,%eax
  103499:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10349c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10349f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1034a2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1034a5:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1034a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1034ab:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  1034b2:	0f 85 79 ff ff ff    	jne    103431 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  1034b8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  1034bb:	e8 40 09 00 00       	call   103e00 <nr_free_pages>
  1034c0:	39 c3                	cmp    %eax,%ebx
  1034c2:	74 24                	je     1034e8 <default_check+0xd8>
  1034c4:	c7 44 24 0c e6 68 10 	movl   $0x1068e6,0xc(%esp)
  1034cb:	00 
  1034cc:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1034d3:	00 
  1034d4:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
  1034db:	00 
  1034dc:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1034e3:	e8 f5 d7 ff ff       	call   100cdd <__panic>

    basic_check();
  1034e8:	e8 e7 f9 ff ff       	call   102ed4 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  1034ed:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1034f4:	e8 9d 08 00 00       	call   103d96 <alloc_pages>
  1034f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
  1034fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103500:	75 24                	jne    103526 <default_check+0x116>
  103502:	c7 44 24 0c ff 68 10 	movl   $0x1068ff,0xc(%esp)
  103509:	00 
  10350a:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103511:	00 
  103512:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
  103519:	00 
  10351a:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103521:	e8 b7 d7 ff ff       	call   100cdd <__panic>
    assert(!PageProperty(p0));
  103526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103529:	83 c0 04             	add    $0x4,%eax
  10352c:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  103533:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103536:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103539:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10353c:	0f a3 10             	bt     %edx,(%eax)
  10353f:	19 c0                	sbb    %eax,%eax
  103541:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  103544:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  103548:	0f 95 c0             	setne  %al
  10354b:	0f b6 c0             	movzbl %al,%eax
  10354e:	85 c0                	test   %eax,%eax
  103550:	74 24                	je     103576 <default_check+0x166>
  103552:	c7 44 24 0c 0a 69 10 	movl   $0x10690a,0xc(%esp)
  103559:	00 
  10355a:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103561:	00 
  103562:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  103569:	00 
  10356a:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103571:	e8 67 d7 ff ff       	call   100cdd <__panic>

    list_entry_t free_list_store = free_list;
  103576:	a1 10 af 11 00       	mov    0x11af10,%eax
  10357b:	8b 15 14 af 11 00    	mov    0x11af14,%edx
  103581:	89 45 80             	mov    %eax,-0x80(%ebp)
  103584:	89 55 84             	mov    %edx,-0x7c(%ebp)
  103587:	c7 45 b4 10 af 11 00 	movl   $0x11af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10358e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103591:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103594:	89 50 04             	mov    %edx,0x4(%eax)
  103597:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10359a:	8b 50 04             	mov    0x4(%eax),%edx
  10359d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1035a0:	89 10                	mov    %edx,(%eax)
  1035a2:	c7 45 b0 10 af 11 00 	movl   $0x11af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1035a9:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1035ac:	8b 40 04             	mov    0x4(%eax),%eax
  1035af:	39 45 b0             	cmp    %eax,-0x50(%ebp)
  1035b2:	0f 94 c0             	sete   %al
  1035b5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1035b8:	85 c0                	test   %eax,%eax
  1035ba:	75 24                	jne    1035e0 <default_check+0x1d0>
  1035bc:	c7 44 24 0c 5f 68 10 	movl   $0x10685f,0xc(%esp)
  1035c3:	00 
  1035c4:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1035cb:	00 
  1035cc:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  1035d3:	00 
  1035d4:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1035db:	e8 fd d6 ff ff       	call   100cdd <__panic>
    assert(alloc_page() == NULL);
  1035e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035e7:	e8 aa 07 00 00       	call   103d96 <alloc_pages>
  1035ec:	85 c0                	test   %eax,%eax
  1035ee:	74 24                	je     103614 <default_check+0x204>
  1035f0:	c7 44 24 0c 76 68 10 	movl   $0x106876,0xc(%esp)
  1035f7:	00 
  1035f8:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1035ff:	00 
  103600:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  103607:	00 
  103608:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10360f:	e8 c9 d6 ff ff       	call   100cdd <__panic>

    unsigned int nr_free_store = nr_free;
  103614:	a1 18 af 11 00       	mov    0x11af18,%eax
  103619:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  10361c:	c7 05 18 af 11 00 00 	movl   $0x0,0x11af18
  103623:	00 00 00 

    free_pages(p0 + 2, 3);
  103626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103629:	83 c0 28             	add    $0x28,%eax
  10362c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103633:	00 
  103634:	89 04 24             	mov    %eax,(%esp)
  103637:	e8 92 07 00 00       	call   103dce <free_pages>
    assert(alloc_pages(4) == NULL);
  10363c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  103643:	e8 4e 07 00 00       	call   103d96 <alloc_pages>
  103648:	85 c0                	test   %eax,%eax
  10364a:	74 24                	je     103670 <default_check+0x260>
  10364c:	c7 44 24 0c 1c 69 10 	movl   $0x10691c,0xc(%esp)
  103653:	00 
  103654:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10365b:	00 
  10365c:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  103663:	00 
  103664:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10366b:	e8 6d d6 ff ff       	call   100cdd <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  103670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103673:	83 c0 28             	add    $0x28,%eax
  103676:	83 c0 04             	add    $0x4,%eax
  103679:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  103680:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103683:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103686:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103689:	0f a3 10             	bt     %edx,(%eax)
  10368c:	19 c0                	sbb    %eax,%eax
  10368e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  103691:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  103695:	0f 95 c0             	setne  %al
  103698:	0f b6 c0             	movzbl %al,%eax
  10369b:	85 c0                	test   %eax,%eax
  10369d:	74 0e                	je     1036ad <default_check+0x29d>
  10369f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1036a2:	83 c0 28             	add    $0x28,%eax
  1036a5:	8b 40 08             	mov    0x8(%eax),%eax
  1036a8:	83 f8 03             	cmp    $0x3,%eax
  1036ab:	74 24                	je     1036d1 <default_check+0x2c1>
  1036ad:	c7 44 24 0c 34 69 10 	movl   $0x106934,0xc(%esp)
  1036b4:	00 
  1036b5:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1036bc:	00 
  1036bd:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
  1036c4:	00 
  1036c5:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1036cc:	e8 0c d6 ff ff       	call   100cdd <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1036d1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  1036d8:	e8 b9 06 00 00       	call   103d96 <alloc_pages>
  1036dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1036e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1036e4:	75 24                	jne    10370a <default_check+0x2fa>
  1036e6:	c7 44 24 0c 60 69 10 	movl   $0x106960,0xc(%esp)
  1036ed:	00 
  1036ee:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1036f5:	00 
  1036f6:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1036fd:	00 
  1036fe:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103705:	e8 d3 d5 ff ff       	call   100cdd <__panic>
    assert(alloc_page() == NULL);
  10370a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103711:	e8 80 06 00 00       	call   103d96 <alloc_pages>
  103716:	85 c0                	test   %eax,%eax
  103718:	74 24                	je     10373e <default_check+0x32e>
  10371a:	c7 44 24 0c 76 68 10 	movl   $0x106876,0xc(%esp)
  103721:	00 
  103722:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103729:	00 
  10372a:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  103731:	00 
  103732:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103739:	e8 9f d5 ff ff       	call   100cdd <__panic>
    assert(p0 + 2 == p1);
  10373e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103741:	83 c0 28             	add    $0x28,%eax
  103744:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103747:	74 24                	je     10376d <default_check+0x35d>
  103749:	c7 44 24 0c 7e 69 10 	movl   $0x10697e,0xc(%esp)
  103750:	00 
  103751:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103758:	00 
  103759:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  103760:	00 
  103761:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103768:	e8 70 d5 ff ff       	call   100cdd <__panic>

    p2 = p0 + 1;
  10376d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103770:	83 c0 14             	add    $0x14,%eax
  103773:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
  103776:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10377d:	00 
  10377e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103781:	89 04 24             	mov    %eax,(%esp)
  103784:	e8 45 06 00 00       	call   103dce <free_pages>
    free_pages(p1, 3);
  103789:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  103790:	00 
  103791:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103794:	89 04 24             	mov    %eax,(%esp)
  103797:	e8 32 06 00 00       	call   103dce <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10379c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10379f:	83 c0 04             	add    $0x4,%eax
  1037a2:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1037a9:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1037ac:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1037af:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1037b2:	0f a3 10             	bt     %edx,(%eax)
  1037b5:	19 c0                	sbb    %eax,%eax
  1037b7:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1037ba:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1037be:	0f 95 c0             	setne  %al
  1037c1:	0f b6 c0             	movzbl %al,%eax
  1037c4:	85 c0                	test   %eax,%eax
  1037c6:	74 0b                	je     1037d3 <default_check+0x3c3>
  1037c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1037cb:	8b 40 08             	mov    0x8(%eax),%eax
  1037ce:	83 f8 01             	cmp    $0x1,%eax
  1037d1:	74 24                	je     1037f7 <default_check+0x3e7>
  1037d3:	c7 44 24 0c 8c 69 10 	movl   $0x10698c,0xc(%esp)
  1037da:	00 
  1037db:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1037e2:	00 
  1037e3:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  1037ea:	00 
  1037eb:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1037f2:	e8 e6 d4 ff ff       	call   100cdd <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1037f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1037fa:	83 c0 04             	add    $0x4,%eax
  1037fd:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103804:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103807:	8b 45 90             	mov    -0x70(%ebp),%eax
  10380a:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10380d:	0f a3 10             	bt     %edx,(%eax)
  103810:	19 c0                	sbb    %eax,%eax
  103812:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103815:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103819:	0f 95 c0             	setne  %al
  10381c:	0f b6 c0             	movzbl %al,%eax
  10381f:	85 c0                	test   %eax,%eax
  103821:	74 0b                	je     10382e <default_check+0x41e>
  103823:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103826:	8b 40 08             	mov    0x8(%eax),%eax
  103829:	83 f8 03             	cmp    $0x3,%eax
  10382c:	74 24                	je     103852 <default_check+0x442>
  10382e:	c7 44 24 0c b4 69 10 	movl   $0x1069b4,0xc(%esp)
  103835:	00 
  103836:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10383d:	00 
  10383e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
  103845:	00 
  103846:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10384d:	e8 8b d4 ff ff       	call   100cdd <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103852:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103859:	e8 38 05 00 00       	call   103d96 <alloc_pages>
  10385e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103861:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103864:	83 e8 14             	sub    $0x14,%eax
  103867:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10386a:	74 24                	je     103890 <default_check+0x480>
  10386c:	c7 44 24 0c da 69 10 	movl   $0x1069da,0xc(%esp)
  103873:	00 
  103874:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10387b:	00 
  10387c:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  103883:	00 
  103884:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10388b:	e8 4d d4 ff ff       	call   100cdd <__panic>
    free_page(p0);
  103890:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103897:	00 
  103898:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10389b:	89 04 24             	mov    %eax,(%esp)
  10389e:	e8 2b 05 00 00       	call   103dce <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1038a3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1038aa:	e8 e7 04 00 00       	call   103d96 <alloc_pages>
  1038af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1038b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1038b5:	83 c0 14             	add    $0x14,%eax
  1038b8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1038bb:	74 24                	je     1038e1 <default_check+0x4d1>
  1038bd:	c7 44 24 0c f8 69 10 	movl   $0x1069f8,0xc(%esp)
  1038c4:	00 
  1038c5:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  1038cc:	00 
  1038cd:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
  1038d4:	00 
  1038d5:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  1038dc:	e8 fc d3 ff ff       	call   100cdd <__panic>

    free_pages(p0, 2);
  1038e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1038e8:	00 
  1038e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1038ec:	89 04 24             	mov    %eax,(%esp)
  1038ef:	e8 da 04 00 00       	call   103dce <free_pages>
    free_page(p2);
  1038f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038fb:	00 
  1038fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1038ff:	89 04 24             	mov    %eax,(%esp)
  103902:	e8 c7 04 00 00       	call   103dce <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103907:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10390e:	e8 83 04 00 00       	call   103d96 <alloc_pages>
  103913:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103916:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10391a:	75 24                	jne    103940 <default_check+0x530>
  10391c:	c7 44 24 0c 18 6a 10 	movl   $0x106a18,0xc(%esp)
  103923:	00 
  103924:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10392b:	00 
  10392c:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
  103933:	00 
  103934:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10393b:	e8 9d d3 ff ff       	call   100cdd <__panic>
    assert(alloc_page() == NULL);
  103940:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103947:	e8 4a 04 00 00       	call   103d96 <alloc_pages>
  10394c:	85 c0                	test   %eax,%eax
  10394e:	74 24                	je     103974 <default_check+0x564>
  103950:	c7 44 24 0c 76 68 10 	movl   $0x106876,0xc(%esp)
  103957:	00 
  103958:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10395f:	00 
  103960:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
  103967:	00 
  103968:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10396f:	e8 69 d3 ff ff       	call   100cdd <__panic>

    assert(nr_free == 0);
  103974:	a1 18 af 11 00       	mov    0x11af18,%eax
  103979:	85 c0                	test   %eax,%eax
  10397b:	74 24                	je     1039a1 <default_check+0x591>
  10397d:	c7 44 24 0c c9 68 10 	movl   $0x1068c9,0xc(%esp)
  103984:	00 
  103985:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  10398c:	00 
  10398d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  103994:	00 
  103995:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  10399c:	e8 3c d3 ff ff       	call   100cdd <__panic>
    nr_free = nr_free_store;
  1039a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1039a4:	a3 18 af 11 00       	mov    %eax,0x11af18

    free_list = free_list_store;
  1039a9:	8b 45 80             	mov    -0x80(%ebp),%eax
  1039ac:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1039af:	a3 10 af 11 00       	mov    %eax,0x11af10
  1039b4:	89 15 14 af 11 00    	mov    %edx,0x11af14
    free_pages(p0, 5);
  1039ba:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1039c1:	00 
  1039c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039c5:	89 04 24             	mov    %eax,(%esp)
  1039c8:	e8 01 04 00 00       	call   103dce <free_pages>

    le = &free_list;
  1039cd:	c7 45 ec 10 af 11 00 	movl   $0x11af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1039d4:	eb 1d                	jmp    1039f3 <default_check+0x5e3>
       // assert(le->next->prev == le && le->prev->next == le);
       //LAB2 comment here
   	 struct Page *p = le2page(le, page_link);
  1039d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039d9:	83 e8 0c             	sub    $0xc,%eax
  1039dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
  1039df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1039e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1039e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1039e9:	8b 40 08             	mov    0x8(%eax),%eax
  1039ec:	29 c2                	sub    %eax,%edx
  1039ee:	89 d0                	mov    %edx,%eax
  1039f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1039f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039f6:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1039f9:	8b 45 88             	mov    -0x78(%ebp),%eax
  1039fc:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1039ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103a02:	81 7d ec 10 af 11 00 	cmpl   $0x11af10,-0x14(%ebp)
  103a09:	75 cb                	jne    1039d6 <default_check+0x5c6>
       // assert(le->next->prev == le && le->prev->next == le);
       //LAB2 comment here
   	 struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  103a0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103a0f:	74 24                	je     103a35 <default_check+0x625>
  103a11:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  103a18:	00 
  103a19:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103a20:	00 
  103a21:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  103a28:	00 
  103a29:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103a30:	e8 a8 d2 ff ff       	call   100cdd <__panic>
    assert(total == 0);
  103a35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a39:	74 24                	je     103a5f <default_check+0x64f>
  103a3b:	c7 44 24 0c 41 6a 10 	movl   $0x106a41,0xc(%esp)
  103a42:	00 
  103a43:	c7 44 24 08 d6 66 10 	movl   $0x1066d6,0x8(%esp)
  103a4a:	00 
  103a4b:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  103a52:	00 
  103a53:	c7 04 24 eb 66 10 00 	movl   $0x1066eb,(%esp)
  103a5a:	e8 7e d2 ff ff       	call   100cdd <__panic>
}
  103a5f:	81 c4 94 00 00 00    	add    $0x94,%esp
  103a65:	5b                   	pop    %ebx
  103a66:	5d                   	pop    %ebp
  103a67:	c3                   	ret    

00103a68 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  103a68:	55                   	push   %ebp
  103a69:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  103a6e:	a1 24 af 11 00       	mov    0x11af24,%eax
  103a73:	29 c2                	sub    %eax,%edx
  103a75:	89 d0                	mov    %edx,%eax
  103a77:	c1 f8 02             	sar    $0x2,%eax
  103a7a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103a80:	5d                   	pop    %ebp
  103a81:	c3                   	ret    

00103a82 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  103a82:	55                   	push   %ebp
  103a83:	89 e5                	mov    %esp,%ebp
  103a85:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103a88:	8b 45 08             	mov    0x8(%ebp),%eax
  103a8b:	89 04 24             	mov    %eax,(%esp)
  103a8e:	e8 d5 ff ff ff       	call   103a68 <page2ppn>
  103a93:	c1 e0 0c             	shl    $0xc,%eax
}
  103a96:	c9                   	leave  
  103a97:	c3                   	ret    

00103a98 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  103a98:	55                   	push   %ebp
  103a99:	89 e5                	mov    %esp,%ebp
  103a9b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  103aa1:	c1 e8 0c             	shr    $0xc,%eax
  103aa4:	89 c2                	mov    %eax,%edx
  103aa6:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103aab:	39 c2                	cmp    %eax,%edx
  103aad:	72 1c                	jb     103acb <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103aaf:	c7 44 24 08 7c 6a 10 	movl   $0x106a7c,0x8(%esp)
  103ab6:	00 
  103ab7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103abe:	00 
  103abf:	c7 04 24 9b 6a 10 00 	movl   $0x106a9b,(%esp)
  103ac6:	e8 12 d2 ff ff       	call   100cdd <__panic>
    }
    return &pages[PPN(pa)];
  103acb:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  103ad4:	c1 e8 0c             	shr    $0xc,%eax
  103ad7:	89 c2                	mov    %eax,%edx
  103ad9:	89 d0                	mov    %edx,%eax
  103adb:	c1 e0 02             	shl    $0x2,%eax
  103ade:	01 d0                	add    %edx,%eax
  103ae0:	c1 e0 02             	shl    $0x2,%eax
  103ae3:	01 c8                	add    %ecx,%eax
}
  103ae5:	c9                   	leave  
  103ae6:	c3                   	ret    

00103ae7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  103ae7:	55                   	push   %ebp
  103ae8:	89 e5                	mov    %esp,%ebp
  103aea:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103aed:	8b 45 08             	mov    0x8(%ebp),%eax
  103af0:	89 04 24             	mov    %eax,(%esp)
  103af3:	e8 8a ff ff ff       	call   103a82 <page2pa>
  103af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103afe:	c1 e8 0c             	shr    $0xc,%eax
  103b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103b04:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  103b09:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103b0c:	72 23                	jb     103b31 <page2kva+0x4a>
  103b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b15:	c7 44 24 08 ac 6a 10 	movl   $0x106aac,0x8(%esp)
  103b1c:	00 
  103b1d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103b24:	00 
  103b25:	c7 04 24 9b 6a 10 00 	movl   $0x106a9b,(%esp)
  103b2c:	e8 ac d1 ff ff       	call   100cdd <__panic>
  103b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b34:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103b39:	c9                   	leave  
  103b3a:	c3                   	ret    

00103b3b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  103b3b:	55                   	push   %ebp
  103b3c:	89 e5                	mov    %esp,%ebp
  103b3e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103b41:	8b 45 08             	mov    0x8(%ebp),%eax
  103b44:	83 e0 01             	and    $0x1,%eax
  103b47:	85 c0                	test   %eax,%eax
  103b49:	75 1c                	jne    103b67 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103b4b:	c7 44 24 08 d0 6a 10 	movl   $0x106ad0,0x8(%esp)
  103b52:	00 
  103b53:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103b5a:	00 
  103b5b:	c7 04 24 9b 6a 10 00 	movl   $0x106a9b,(%esp)
  103b62:	e8 76 d1 ff ff       	call   100cdd <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  103b67:	8b 45 08             	mov    0x8(%ebp),%eax
  103b6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b6f:	89 04 24             	mov    %eax,(%esp)
  103b72:	e8 21 ff ff ff       	call   103a98 <pa2page>
}
  103b77:	c9                   	leave  
  103b78:	c3                   	ret    

00103b79 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  103b79:	55                   	push   %ebp
  103b7a:	89 e5                	mov    %esp,%ebp
  103b7c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  103b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b87:	89 04 24             	mov    %eax,(%esp)
  103b8a:	e8 09 ff ff ff       	call   103a98 <pa2page>
}
  103b8f:	c9                   	leave  
  103b90:	c3                   	ret    

00103b91 <page_ref>:

static inline int
page_ref(struct Page *page) {
  103b91:	55                   	push   %ebp
  103b92:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103b94:	8b 45 08             	mov    0x8(%ebp),%eax
  103b97:	8b 00                	mov    (%eax),%eax
}
  103b99:	5d                   	pop    %ebp
  103b9a:	c3                   	ret    

00103b9b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  103b9b:	55                   	push   %ebp
  103b9c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  103ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
  103ba4:	89 10                	mov    %edx,(%eax)
}
  103ba6:	5d                   	pop    %ebp
  103ba7:	c3                   	ret    

00103ba8 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103ba8:	55                   	push   %ebp
  103ba9:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103bab:	8b 45 08             	mov    0x8(%ebp),%eax
  103bae:	8b 00                	mov    (%eax),%eax
  103bb0:	8d 50 01             	lea    0x1(%eax),%edx
  103bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  103bb6:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  103bbb:	8b 00                	mov    (%eax),%eax
}
  103bbd:	5d                   	pop    %ebp
  103bbe:	c3                   	ret    

00103bbf <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103bbf:	55                   	push   %ebp
  103bc0:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  103bc5:	8b 00                	mov    (%eax),%eax
  103bc7:	8d 50 ff             	lea    -0x1(%eax),%edx
  103bca:	8b 45 08             	mov    0x8(%ebp),%eax
  103bcd:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  103bd2:	8b 00                	mov    (%eax),%eax
}
  103bd4:	5d                   	pop    %ebp
  103bd5:	c3                   	ret    

00103bd6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  103bd6:	55                   	push   %ebp
  103bd7:	89 e5                	mov    %esp,%ebp
  103bd9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103bdc:	9c                   	pushf  
  103bdd:	58                   	pop    %eax
  103bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103be4:	25 00 02 00 00       	and    $0x200,%eax
  103be9:	85 c0                	test   %eax,%eax
  103beb:	74 0c                	je     103bf9 <__intr_save+0x23>
        intr_disable();
  103bed:	e8 df da ff ff       	call   1016d1 <intr_disable>
        return 1;
  103bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  103bf7:	eb 05                	jmp    103bfe <__intr_save+0x28>
    }
    return 0;
  103bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103bfe:	c9                   	leave  
  103bff:	c3                   	ret    

00103c00 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  103c00:	55                   	push   %ebp
  103c01:	89 e5                	mov    %esp,%ebp
  103c03:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103c06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103c0a:	74 05                	je     103c11 <__intr_restore+0x11>
        intr_enable();
  103c0c:	e8 ba da ff ff       	call   1016cb <intr_enable>
    }
}
  103c11:	c9                   	leave  
  103c12:	c3                   	ret    

00103c13 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103c13:	55                   	push   %ebp
  103c14:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103c16:	8b 45 08             	mov    0x8(%ebp),%eax
  103c19:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103c1c:	b8 23 00 00 00       	mov    $0x23,%eax
  103c21:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103c23:	b8 23 00 00 00       	mov    $0x23,%eax
  103c28:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103c2a:	b8 10 00 00 00       	mov    $0x10,%eax
  103c2f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103c31:	b8 10 00 00 00       	mov    $0x10,%eax
  103c36:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103c38:	b8 10 00 00 00       	mov    $0x10,%eax
  103c3d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103c3f:	ea 46 3c 10 00 08 00 	ljmp   $0x8,$0x103c46
}
  103c46:	5d                   	pop    %ebp
  103c47:	c3                   	ret    

00103c48 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103c48:	55                   	push   %ebp
  103c49:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  103c4e:	a3 a4 ae 11 00       	mov    %eax,0x11aea4
}
  103c53:	5d                   	pop    %ebp
  103c54:	c3                   	ret    

00103c55 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103c55:	55                   	push   %ebp
  103c56:	89 e5                	mov    %esp,%ebp
  103c58:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103c5b:	b8 00 70 11 00       	mov    $0x117000,%eax
  103c60:	89 04 24             	mov    %eax,(%esp)
  103c63:	e8 e0 ff ff ff       	call   103c48 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103c68:	66 c7 05 a8 ae 11 00 	movw   $0x10,0x11aea8
  103c6f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103c71:	66 c7 05 28 7a 11 00 	movw   $0x68,0x117a28
  103c78:	68 00 
  103c7a:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c7f:	66 a3 2a 7a 11 00    	mov    %ax,0x117a2a
  103c85:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103c8a:	c1 e8 10             	shr    $0x10,%eax
  103c8d:	a2 2c 7a 11 00       	mov    %al,0x117a2c
  103c92:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103c99:	83 e0 f0             	and    $0xfffffff0,%eax
  103c9c:	83 c8 09             	or     $0x9,%eax
  103c9f:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103ca4:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103cab:	83 e0 ef             	and    $0xffffffef,%eax
  103cae:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103cb3:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103cba:	83 e0 9f             	and    $0xffffff9f,%eax
  103cbd:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103cc2:	0f b6 05 2d 7a 11 00 	movzbl 0x117a2d,%eax
  103cc9:	83 c8 80             	or     $0xffffff80,%eax
  103ccc:	a2 2d 7a 11 00       	mov    %al,0x117a2d
  103cd1:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cd8:	83 e0 f0             	and    $0xfffffff0,%eax
  103cdb:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103ce0:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103ce7:	83 e0 ef             	and    $0xffffffef,%eax
  103cea:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cef:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103cf6:	83 e0 df             	and    $0xffffffdf,%eax
  103cf9:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103cfe:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d05:	83 c8 40             	or     $0x40,%eax
  103d08:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d0d:	0f b6 05 2e 7a 11 00 	movzbl 0x117a2e,%eax
  103d14:	83 e0 7f             	and    $0x7f,%eax
  103d17:	a2 2e 7a 11 00       	mov    %al,0x117a2e
  103d1c:	b8 a0 ae 11 00       	mov    $0x11aea0,%eax
  103d21:	c1 e8 18             	shr    $0x18,%eax
  103d24:	a2 2f 7a 11 00       	mov    %al,0x117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103d29:	c7 04 24 30 7a 11 00 	movl   $0x117a30,(%esp)
  103d30:	e8 de fe ff ff       	call   103c13 <lgdt>
  103d35:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103d3b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103d3f:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  103d42:	c9                   	leave  
  103d43:	c3                   	ret    

00103d44 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103d44:	55                   	push   %ebp
  103d45:	89 e5                	mov    %esp,%ebp
  103d47:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103d4a:	c7 05 1c af 11 00 60 	movl   $0x106a60,0x11af1c
  103d51:	6a 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103d54:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d59:	8b 00                	mov    (%eax),%eax
  103d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  103d5f:	c7 04 24 fc 6a 10 00 	movl   $0x106afc,(%esp)
  103d66:	e8 e8 c5 ff ff       	call   100353 <cprintf>
    pmm_manager->init();
  103d6b:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d70:	8b 40 04             	mov    0x4(%eax),%eax
  103d73:	ff d0                	call   *%eax
}
  103d75:	c9                   	leave  
  103d76:	c3                   	ret    

00103d77 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  103d77:	55                   	push   %ebp
  103d78:	89 e5                	mov    %esp,%ebp
  103d7a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  103d7d:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103d82:	8b 40 08             	mov    0x8(%eax),%eax
  103d85:	8b 55 0c             	mov    0xc(%ebp),%edx
  103d88:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  103d8f:	89 14 24             	mov    %edx,(%esp)
  103d92:	ff d0                	call   *%eax
}
  103d94:	c9                   	leave  
  103d95:	c3                   	ret    

00103d96 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  103d96:	55                   	push   %ebp
  103d97:	89 e5                	mov    %esp,%ebp
  103d99:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  103da3:	e8 2e fe ff ff       	call   103bd6 <__intr_save>
  103da8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103dab:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103db0:	8b 40 0c             	mov    0xc(%eax),%eax
  103db3:	8b 55 08             	mov    0x8(%ebp),%edx
  103db6:	89 14 24             	mov    %edx,(%esp)
  103db9:	ff d0                	call   *%eax
  103dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103dc1:	89 04 24             	mov    %eax,(%esp)
  103dc4:	e8 37 fe ff ff       	call   103c00 <__intr_restore>
    return page;
  103dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103dcc:	c9                   	leave  
  103dcd:	c3                   	ret    

00103dce <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103dce:	55                   	push   %ebp
  103dcf:	89 e5                	mov    %esp,%ebp
  103dd1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  103dd4:	e8 fd fd ff ff       	call   103bd6 <__intr_save>
  103dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103ddc:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103de1:	8b 40 10             	mov    0x10(%eax),%eax
  103de4:	8b 55 0c             	mov    0xc(%ebp),%edx
  103de7:	89 54 24 04          	mov    %edx,0x4(%esp)
  103deb:	8b 55 08             	mov    0x8(%ebp),%edx
  103dee:	89 14 24             	mov    %edx,(%esp)
  103df1:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  103df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103df6:	89 04 24             	mov    %eax,(%esp)
  103df9:	e8 02 fe ff ff       	call   103c00 <__intr_restore>
}
  103dfe:	c9                   	leave  
  103dff:	c3                   	ret    

00103e00 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103e00:	55                   	push   %ebp
  103e01:	89 e5                	mov    %esp,%ebp
  103e03:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  103e06:	e8 cb fd ff ff       	call   103bd6 <__intr_save>
  103e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103e0e:	a1 1c af 11 00       	mov    0x11af1c,%eax
  103e13:	8b 40 14             	mov    0x14(%eax),%eax
  103e16:	ff d0                	call   *%eax
  103e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e1e:	89 04 24             	mov    %eax,(%esp)
  103e21:	e8 da fd ff ff       	call   103c00 <__intr_restore>
    return ret;
  103e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  103e29:	c9                   	leave  
  103e2a:	c3                   	ret    

00103e2b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  103e2b:	55                   	push   %ebp
  103e2c:	89 e5                	mov    %esp,%ebp
  103e2e:	57                   	push   %edi
  103e2f:	56                   	push   %esi
  103e30:	53                   	push   %ebx
  103e31:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  103e37:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  103e3e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  103e45:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  103e4c:	c7 04 24 13 6b 10 00 	movl   $0x106b13,(%esp)
  103e53:	e8 fb c4 ff ff       	call   100353 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103e58:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103e5f:	e9 15 01 00 00       	jmp    103f79 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  103e64:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e67:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e6a:	89 d0                	mov    %edx,%eax
  103e6c:	c1 e0 02             	shl    $0x2,%eax
  103e6f:	01 d0                	add    %edx,%eax
  103e71:	c1 e0 02             	shl    $0x2,%eax
  103e74:	01 c8                	add    %ecx,%eax
  103e76:	8b 50 08             	mov    0x8(%eax),%edx
  103e79:	8b 40 04             	mov    0x4(%eax),%eax
  103e7c:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103e7f:	89 55 bc             	mov    %edx,-0x44(%ebp)
  103e82:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103e85:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103e88:	89 d0                	mov    %edx,%eax
  103e8a:	c1 e0 02             	shl    $0x2,%eax
  103e8d:	01 d0                	add    %edx,%eax
  103e8f:	c1 e0 02             	shl    $0x2,%eax
  103e92:	01 c8                	add    %ecx,%eax
  103e94:	8b 48 0c             	mov    0xc(%eax),%ecx
  103e97:	8b 58 10             	mov    0x10(%eax),%ebx
  103e9a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103e9d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103ea0:	01 c8                	add    %ecx,%eax
  103ea2:	11 da                	adc    %ebx,%edx
  103ea4:	89 45 b0             	mov    %eax,-0x50(%ebp)
  103ea7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  103eaa:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103ead:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103eb0:	89 d0                	mov    %edx,%eax
  103eb2:	c1 e0 02             	shl    $0x2,%eax
  103eb5:	01 d0                	add    %edx,%eax
  103eb7:	c1 e0 02             	shl    $0x2,%eax
  103eba:	01 c8                	add    %ecx,%eax
  103ebc:	83 c0 14             	add    $0x14,%eax
  103ebf:	8b 00                	mov    (%eax),%eax
  103ec1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  103ec7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103eca:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103ecd:	83 c0 ff             	add    $0xffffffff,%eax
  103ed0:	83 d2 ff             	adc    $0xffffffff,%edx
  103ed3:	89 c6                	mov    %eax,%esi
  103ed5:	89 d7                	mov    %edx,%edi
  103ed7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103edd:	89 d0                	mov    %edx,%eax
  103edf:	c1 e0 02             	shl    $0x2,%eax
  103ee2:	01 d0                	add    %edx,%eax
  103ee4:	c1 e0 02             	shl    $0x2,%eax
  103ee7:	01 c8                	add    %ecx,%eax
  103ee9:	8b 48 0c             	mov    0xc(%eax),%ecx
  103eec:	8b 58 10             	mov    0x10(%eax),%ebx
  103eef:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  103ef5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  103ef9:	89 74 24 14          	mov    %esi,0x14(%esp)
  103efd:	89 7c 24 18          	mov    %edi,0x18(%esp)
  103f01:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103f04:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103f07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103f0b:	89 54 24 10          	mov    %edx,0x10(%esp)
  103f0f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103f13:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103f17:	c7 04 24 20 6b 10 00 	movl   $0x106b20,(%esp)
  103f1e:	e8 30 c4 ff ff       	call   100353 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  103f23:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103f26:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103f29:	89 d0                	mov    %edx,%eax
  103f2b:	c1 e0 02             	shl    $0x2,%eax
  103f2e:	01 d0                	add    %edx,%eax
  103f30:	c1 e0 02             	shl    $0x2,%eax
  103f33:	01 c8                	add    %ecx,%eax
  103f35:	83 c0 14             	add    $0x14,%eax
  103f38:	8b 00                	mov    (%eax),%eax
  103f3a:	83 f8 01             	cmp    $0x1,%eax
  103f3d:	75 36                	jne    103f75 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
  103f3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103f45:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f48:	77 2b                	ja     103f75 <page_init+0x14a>
  103f4a:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103f4d:	72 05                	jb     103f54 <page_init+0x129>
  103f4f:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103f52:	73 21                	jae    103f75 <page_init+0x14a>
  103f54:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f58:	77 1b                	ja     103f75 <page_init+0x14a>
  103f5a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103f5e:	72 09                	jb     103f69 <page_init+0x13e>
  103f60:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  103f67:	77 0c                	ja     103f75 <page_init+0x14a>
                maxpa = end;
  103f69:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103f6c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103f6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103f72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  103f75:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  103f79:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103f7c:	8b 00                	mov    (%eax),%eax
  103f7e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103f81:	0f 8f dd fe ff ff    	jg     103e64 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  103f87:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f8b:	72 1d                	jb     103faa <page_init+0x17f>
  103f8d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103f91:	77 09                	ja     103f9c <page_init+0x171>
  103f93:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  103f9a:	76 0e                	jbe    103faa <page_init+0x17f>
        maxpa = KMEMSIZE;
  103f9c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103fa3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  103faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103fad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103fb0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103fb4:	c1 ea 0c             	shr    $0xc,%edx
  103fb7:	a3 80 ae 11 00       	mov    %eax,0x11ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103fbc:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103fc3:	b8 28 af 11 00       	mov    $0x11af28,%eax
  103fc8:	8d 50 ff             	lea    -0x1(%eax),%edx
  103fcb:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103fce:	01 d0                	add    %edx,%eax
  103fd0:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103fd3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  103fd6:	ba 00 00 00 00       	mov    $0x0,%edx
  103fdb:	f7 75 ac             	divl   -0x54(%ebp)
  103fde:	89 d0                	mov    %edx,%eax
  103fe0:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103fe3:	29 c2                	sub    %eax,%edx
  103fe5:	89 d0                	mov    %edx,%eax
  103fe7:	a3 24 af 11 00       	mov    %eax,0x11af24

    for (i = 0; i < npage; i ++) {
  103fec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103ff3:	eb 2f                	jmp    104024 <page_init+0x1f9>
        SetPageReserved(pages + i);
  103ff5:	8b 0d 24 af 11 00    	mov    0x11af24,%ecx
  103ffb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103ffe:	89 d0                	mov    %edx,%eax
  104000:	c1 e0 02             	shl    $0x2,%eax
  104003:	01 d0                	add    %edx,%eax
  104005:	c1 e0 02             	shl    $0x2,%eax
  104008:	01 c8                	add    %ecx,%eax
  10400a:	83 c0 04             	add    $0x4,%eax
  10400d:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  104014:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104017:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10401a:	8b 55 90             	mov    -0x70(%ebp),%edx
  10401d:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  104020:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104024:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104027:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10402c:	39 c2                	cmp    %eax,%edx
  10402e:	72 c5                	jb     103ff5 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  104030:	8b 15 80 ae 11 00    	mov    0x11ae80,%edx
  104036:	89 d0                	mov    %edx,%eax
  104038:	c1 e0 02             	shl    $0x2,%eax
  10403b:	01 d0                	add    %edx,%eax
  10403d:	c1 e0 02             	shl    $0x2,%eax
  104040:	89 c2                	mov    %eax,%edx
  104042:	a1 24 af 11 00       	mov    0x11af24,%eax
  104047:	01 d0                	add    %edx,%eax
  104049:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10404c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  104053:	77 23                	ja     104078 <page_init+0x24d>
  104055:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104058:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10405c:	c7 44 24 08 50 6b 10 	movl   $0x106b50,0x8(%esp)
  104063:	00 
  104064:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10406b:	00 
  10406c:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104073:	e8 65 cc ff ff       	call   100cdd <__panic>
  104078:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10407b:	05 00 00 00 40       	add    $0x40000000,%eax
  104080:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104083:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10408a:	e9 74 01 00 00       	jmp    104203 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10408f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104092:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104095:	89 d0                	mov    %edx,%eax
  104097:	c1 e0 02             	shl    $0x2,%eax
  10409a:	01 d0                	add    %edx,%eax
  10409c:	c1 e0 02             	shl    $0x2,%eax
  10409f:	01 c8                	add    %ecx,%eax
  1040a1:	8b 50 08             	mov    0x8(%eax),%edx
  1040a4:	8b 40 04             	mov    0x4(%eax),%eax
  1040a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1040aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1040ad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040b3:	89 d0                	mov    %edx,%eax
  1040b5:	c1 e0 02             	shl    $0x2,%eax
  1040b8:	01 d0                	add    %edx,%eax
  1040ba:	c1 e0 02             	shl    $0x2,%eax
  1040bd:	01 c8                	add    %ecx,%eax
  1040bf:	8b 48 0c             	mov    0xc(%eax),%ecx
  1040c2:	8b 58 10             	mov    0x10(%eax),%ebx
  1040c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1040c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1040cb:	01 c8                	add    %ecx,%eax
  1040cd:	11 da                	adc    %ebx,%edx
  1040cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1040d2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1040d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1040d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040db:	89 d0                	mov    %edx,%eax
  1040dd:	c1 e0 02             	shl    $0x2,%eax
  1040e0:	01 d0                	add    %edx,%eax
  1040e2:	c1 e0 02             	shl    $0x2,%eax
  1040e5:	01 c8                	add    %ecx,%eax
  1040e7:	83 c0 14             	add    $0x14,%eax
  1040ea:	8b 00                	mov    (%eax),%eax
  1040ec:	83 f8 01             	cmp    $0x1,%eax
  1040ef:	0f 85 0a 01 00 00    	jne    1041ff <page_init+0x3d4>
            if (begin < freemem) {
  1040f5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1040f8:	ba 00 00 00 00       	mov    $0x0,%edx
  1040fd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104100:	72 17                	jb     104119 <page_init+0x2ee>
  104102:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  104105:	77 05                	ja     10410c <page_init+0x2e1>
  104107:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  10410a:	76 0d                	jbe    104119 <page_init+0x2ee>
                begin = freemem;
  10410c:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10410f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104112:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  104119:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  10411d:	72 1d                	jb     10413c <page_init+0x311>
  10411f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  104123:	77 09                	ja     10412e <page_init+0x303>
  104125:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  10412c:	76 0e                	jbe    10413c <page_init+0x311>
                end = KMEMSIZE;
  10412e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  104135:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  10413c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10413f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104142:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  104145:	0f 87 b4 00 00 00    	ja     1041ff <page_init+0x3d4>
  10414b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10414e:	72 09                	jb     104159 <page_init+0x32e>
  104150:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  104153:	0f 83 a6 00 00 00    	jae    1041ff <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
  104159:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  104160:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104163:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104166:	01 d0                	add    %edx,%eax
  104168:	83 e8 01             	sub    $0x1,%eax
  10416b:	89 45 98             	mov    %eax,-0x68(%ebp)
  10416e:	8b 45 98             	mov    -0x68(%ebp),%eax
  104171:	ba 00 00 00 00       	mov    $0x0,%edx
  104176:	f7 75 9c             	divl   -0x64(%ebp)
  104179:	89 d0                	mov    %edx,%eax
  10417b:	8b 55 98             	mov    -0x68(%ebp),%edx
  10417e:	29 c2                	sub    %eax,%edx
  104180:	89 d0                	mov    %edx,%eax
  104182:	ba 00 00 00 00       	mov    $0x0,%edx
  104187:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10418a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  10418d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104190:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104193:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104196:	ba 00 00 00 00       	mov    $0x0,%edx
  10419b:	89 c7                	mov    %eax,%edi
  10419d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  1041a3:	89 7d 80             	mov    %edi,-0x80(%ebp)
  1041a6:	89 d0                	mov    %edx,%eax
  1041a8:	83 e0 00             	and    $0x0,%eax
  1041ab:	89 45 84             	mov    %eax,-0x7c(%ebp)
  1041ae:	8b 45 80             	mov    -0x80(%ebp),%eax
  1041b1:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1041b4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1041b7:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  1041ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1041c0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041c3:	77 3a                	ja     1041ff <page_init+0x3d4>
  1041c5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  1041c8:	72 05                	jb     1041cf <page_init+0x3a4>
  1041ca:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1041cd:	73 30                	jae    1041ff <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1041cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  1041d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  1041d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1041d8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1041db:	29 c8                	sub    %ecx,%eax
  1041dd:	19 da                	sbb    %ebx,%edx
  1041df:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1041e3:	c1 ea 0c             	shr    $0xc,%edx
  1041e6:	89 c3                	mov    %eax,%ebx
  1041e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1041eb:	89 04 24             	mov    %eax,(%esp)
  1041ee:	e8 a5 f8 ff ff       	call   103a98 <pa2page>
  1041f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041f7:	89 04 24             	mov    %eax,(%esp)
  1041fa:	e8 78 fb ff ff       	call   103d77 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  1041ff:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  104203:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104206:	8b 00                	mov    (%eax),%eax
  104208:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  10420b:	0f 8f 7e fe ff ff    	jg     10408f <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  104211:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104217:	5b                   	pop    %ebx
  104218:	5e                   	pop    %esi
  104219:	5f                   	pop    %edi
  10421a:	5d                   	pop    %ebp
  10421b:	c3                   	ret    

0010421c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10421c:	55                   	push   %ebp
  10421d:	89 e5                	mov    %esp,%ebp
  10421f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  104222:	8b 45 14             	mov    0x14(%ebp),%eax
  104225:	8b 55 0c             	mov    0xc(%ebp),%edx
  104228:	31 d0                	xor    %edx,%eax
  10422a:	25 ff 0f 00 00       	and    $0xfff,%eax
  10422f:	85 c0                	test   %eax,%eax
  104231:	74 24                	je     104257 <boot_map_segment+0x3b>
  104233:	c7 44 24 0c 82 6b 10 	movl   $0x106b82,0xc(%esp)
  10423a:	00 
  10423b:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104242:	00 
  104243:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  10424a:	00 
  10424b:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104252:	e8 86 ca ff ff       	call   100cdd <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  104257:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10425e:	8b 45 0c             	mov    0xc(%ebp),%eax
  104261:	25 ff 0f 00 00       	and    $0xfff,%eax
  104266:	89 c2                	mov    %eax,%edx
  104268:	8b 45 10             	mov    0x10(%ebp),%eax
  10426b:	01 c2                	add    %eax,%edx
  10426d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104270:	01 d0                	add    %edx,%eax
  104272:	83 e8 01             	sub    $0x1,%eax
  104275:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104278:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10427b:	ba 00 00 00 00       	mov    $0x0,%edx
  104280:	f7 75 f0             	divl   -0x10(%ebp)
  104283:	89 d0                	mov    %edx,%eax
  104285:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104288:	29 c2                	sub    %eax,%edx
  10428a:	89 d0                	mov    %edx,%eax
  10428c:	c1 e8 0c             	shr    $0xc,%eax
  10428f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  104292:	8b 45 0c             	mov    0xc(%ebp),%eax
  104295:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104298:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10429b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1042a0:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1042a3:	8b 45 14             	mov    0x14(%ebp),%eax
  1042a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1042a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1042ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1042b1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1042b4:	eb 6b                	jmp    104321 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1042b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1042bd:	00 
  1042be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1042c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1042c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1042c8:	89 04 24             	mov    %eax,(%esp)
  1042cb:	e8 82 01 00 00       	call   104452 <get_pte>
  1042d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1042d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1042d7:	75 24                	jne    1042fd <boot_map_segment+0xe1>
  1042d9:	c7 44 24 0c ae 6b 10 	movl   $0x106bae,0xc(%esp)
  1042e0:	00 
  1042e1:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  1042e8:	00 
  1042e9:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1042f0:	00 
  1042f1:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1042f8:	e8 e0 c9 ff ff       	call   100cdd <__panic>
        *ptep = pa | PTE_P | perm;
  1042fd:	8b 45 18             	mov    0x18(%ebp),%eax
  104300:	8b 55 14             	mov    0x14(%ebp),%edx
  104303:	09 d0                	or     %edx,%eax
  104305:	83 c8 01             	or     $0x1,%eax
  104308:	89 c2                	mov    %eax,%edx
  10430a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10430d:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10430f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  104313:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10431a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104321:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104325:	75 8f                	jne    1042b6 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  104327:	c9                   	leave  
  104328:	c3                   	ret    

00104329 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  104329:	55                   	push   %ebp
  10432a:	89 e5                	mov    %esp,%ebp
  10432c:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  10432f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104336:	e8 5b fa ff ff       	call   103d96 <alloc_pages>
  10433b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  10433e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104342:	75 1c                	jne    104360 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  104344:	c7 44 24 08 bb 6b 10 	movl   $0x106bbb,0x8(%esp)
  10434b:	00 
  10434c:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104353:	00 
  104354:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  10435b:	e8 7d c9 ff ff       	call   100cdd <__panic>
    }
    return page2kva(p);
  104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104363:	89 04 24             	mov    %eax,(%esp)
  104366:	e8 7c f7 ff ff       	call   103ae7 <page2kva>
}
  10436b:	c9                   	leave  
  10436c:	c3                   	ret    

0010436d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  10436d:	55                   	push   %ebp
  10436e:	89 e5                	mov    %esp,%ebp
  104370:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  104373:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104378:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10437b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  104382:	77 23                	ja     1043a7 <pmm_init+0x3a>
  104384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104387:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10438b:	c7 44 24 08 50 6b 10 	movl   $0x106b50,0x8(%esp)
  104392:	00 
  104393:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  10439a:	00 
  10439b:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1043a2:	e8 36 c9 ff ff       	call   100cdd <__panic>
  1043a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043aa:	05 00 00 00 40       	add    $0x40000000,%eax
  1043af:	a3 20 af 11 00       	mov    %eax,0x11af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1043b4:	e8 8b f9 ff ff       	call   103d44 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1043b9:	e8 6d fa ff ff       	call   103e2b <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1043be:	e8 db 03 00 00       	call   10479e <check_alloc_page>

    check_pgdir();
  1043c3:	e8 f4 03 00 00       	call   1047bc <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1043c8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043cd:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  1043d3:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1043d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1043db:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1043e2:	77 23                	ja     104407 <pmm_init+0x9a>
  1043e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1043eb:	c7 44 24 08 50 6b 10 	movl   $0x106b50,0x8(%esp)
  1043f2:	00 
  1043f3:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1043fa:	00 
  1043fb:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104402:	e8 d6 c8 ff ff       	call   100cdd <__panic>
  104407:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10440a:	05 00 00 00 40       	add    $0x40000000,%eax
  10440f:	83 c8 03             	or     $0x3,%eax
  104412:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  104414:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104419:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  104420:	00 
  104421:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104428:	00 
  104429:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  104430:	38 
  104431:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  104438:	c0 
  104439:	89 04 24             	mov    %eax,(%esp)
  10443c:	e8 db fd ff ff       	call   10421c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  104441:	e8 0f f8 ff ff       	call   103c55 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  104446:	e8 0c 0a 00 00       	call   104e57 <check_boot_pgdir>

    print_pgdir();
  10444b:	e8 94 0e 00 00       	call   1052e4 <print_pgdir>

}
  104450:	c9                   	leave  
  104451:	c3                   	ret    

00104452 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  104452:	55                   	push   %ebp
  104453:	89 e5                	mov    %esp,%ebp
  104455:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
  104458:	8b 45 0c             	mov    0xc(%ebp),%eax
  10445b:	c1 e8 16             	shr    $0x16,%eax
  10445e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104465:	8b 45 08             	mov    0x8(%ebp),%eax
  104468:	01 d0                	add    %edx,%eax
  10446a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
  10446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104470:	8b 00                	mov    (%eax),%eax
  104472:	83 e0 01             	and    $0x1,%eax
  104475:	85 c0                	test   %eax,%eax
  104477:	0f 85 af 00 00 00    	jne    10452c <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  10447d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104481:	74 15                	je     104498 <get_pte+0x46>
  104483:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10448a:	e8 07 f9 ff ff       	call   103d96 <alloc_pages>
  10448f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104492:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104496:	75 0a                	jne    1044a2 <get_pte+0x50>
            return NULL;
  104498:	b8 00 00 00 00       	mov    $0x0,%eax
  10449d:	e9 e6 00 00 00       	jmp    104588 <get_pte+0x136>
        }
        set_page_ref(page, 1);
  1044a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1044a9:	00 
  1044aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044ad:	89 04 24             	mov    %eax,(%esp)
  1044b0:	e8 e6 f6 ff ff       	call   103b9b <set_page_ref>
        uintptr_t pa = page2pa(page);
  1044b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044b8:	89 04 24             	mov    %eax,(%esp)
  1044bb:	e8 c2 f5 ff ff       	call   103a82 <page2pa>
  1044c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
  1044c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1044c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044cc:	c1 e8 0c             	shr    $0xc,%eax
  1044cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1044d2:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1044d7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1044da:	72 23                	jb     1044ff <get_pte+0xad>
  1044dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1044df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1044e3:	c7 44 24 08 ac 6a 10 	movl   $0x106aac,0x8(%esp)
  1044ea:	00 
  1044eb:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
  1044f2:	00 
  1044f3:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1044fa:	e8 de c7 ff ff       	call   100cdd <__panic>
  1044ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104502:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104507:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10450e:	00 
  10450f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104516:	00 
  104517:	89 04 24             	mov    %eax,(%esp)
  10451a:	e8 e3 18 00 00       	call   105e02 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  10451f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104522:	83 c8 07             	or     $0x7,%eax
  104525:	89 c2                	mov    %eax,%edx
  104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10452a:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  10452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10452f:	8b 00                	mov    (%eax),%eax
  104531:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104536:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10453c:	c1 e8 0c             	shr    $0xc,%eax
  10453f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  104542:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104547:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  10454a:	72 23                	jb     10456f <get_pte+0x11d>
  10454c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10454f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104553:	c7 44 24 08 ac 6a 10 	movl   $0x106aac,0x8(%esp)
  10455a:	00 
  10455b:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  104562:	00 
  104563:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  10456a:	e8 6e c7 ff ff       	call   100cdd <__panic>
  10456f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104572:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104577:	8b 55 0c             	mov    0xc(%ebp),%edx
  10457a:	c1 ea 0c             	shr    $0xc,%edx
  10457d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  104583:	c1 e2 02             	shl    $0x2,%edx
  104586:	01 d0                	add    %edx,%eax
}
  104588:	c9                   	leave  
  104589:	c3                   	ret    

0010458a <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  10458a:	55                   	push   %ebp
  10458b:	89 e5                	mov    %esp,%ebp
  10458d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104590:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104597:	00 
  104598:	8b 45 0c             	mov    0xc(%ebp),%eax
  10459b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10459f:	8b 45 08             	mov    0x8(%ebp),%eax
  1045a2:	89 04 24             	mov    %eax,(%esp)
  1045a5:	e8 a8 fe ff ff       	call   104452 <get_pte>
  1045aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1045ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1045b1:	74 08                	je     1045bb <get_page+0x31>
        *ptep_store = ptep;
  1045b3:	8b 45 10             	mov    0x10(%ebp),%eax
  1045b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1045b9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1045bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1045bf:	74 1b                	je     1045dc <get_page+0x52>
  1045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c4:	8b 00                	mov    (%eax),%eax
  1045c6:	83 e0 01             	and    $0x1,%eax
  1045c9:	85 c0                	test   %eax,%eax
  1045cb:	74 0f                	je     1045dc <get_page+0x52>
        return pte2page(*ptep);
  1045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045d0:	8b 00                	mov    (%eax),%eax
  1045d2:	89 04 24             	mov    %eax,(%esp)
  1045d5:	e8 61 f5 ff ff       	call   103b3b <pte2page>
  1045da:	eb 05                	jmp    1045e1 <get_page+0x57>
    }
    return NULL;
  1045dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1045e1:	c9                   	leave  
  1045e2:	c3                   	ret    

001045e3 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1045e3:	55                   	push   %ebp
  1045e4:	89 e5                	mov    %esp,%ebp
  1045e6:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  1045e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1045ec:	8b 00                	mov    (%eax),%eax
  1045ee:	83 e0 01             	and    $0x1,%eax
  1045f1:	85 c0                	test   %eax,%eax
  1045f3:	74 4d                	je     104642 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  1045f5:	8b 45 10             	mov    0x10(%ebp),%eax
  1045f8:	8b 00                	mov    (%eax),%eax
  1045fa:	89 04 24             	mov    %eax,(%esp)
  1045fd:	e8 39 f5 ff ff       	call   103b3b <pte2page>
  104602:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
  104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104608:	89 04 24             	mov    %eax,(%esp)
  10460b:	e8 af f5 ff ff       	call   103bbf <page_ref_dec>
  104610:	85 c0                	test   %eax,%eax
  104612:	75 13                	jne    104627 <page_remove_pte+0x44>
            free_page(page);
  104614:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10461b:	00 
  10461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10461f:	89 04 24             	mov    %eax,(%esp)
  104622:	e8 a7 f7 ff ff       	call   103dce <free_pages>
        }
        *ptep = 0;
  104627:	8b 45 10             	mov    0x10(%ebp),%eax
  10462a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  104630:	8b 45 0c             	mov    0xc(%ebp),%eax
  104633:	89 44 24 04          	mov    %eax,0x4(%esp)
  104637:	8b 45 08             	mov    0x8(%ebp),%eax
  10463a:	89 04 24             	mov    %eax,(%esp)
  10463d:	e8 ff 00 00 00       	call   104741 <tlb_invalidate>
    }
}
  104642:	c9                   	leave  
  104643:	c3                   	ret    

00104644 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  104644:	55                   	push   %ebp
  104645:	89 e5                	mov    %esp,%ebp
  104647:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10464a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104651:	00 
  104652:	8b 45 0c             	mov    0xc(%ebp),%eax
  104655:	89 44 24 04          	mov    %eax,0x4(%esp)
  104659:	8b 45 08             	mov    0x8(%ebp),%eax
  10465c:	89 04 24             	mov    %eax,(%esp)
  10465f:	e8 ee fd ff ff       	call   104452 <get_pte>
  104664:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  104667:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10466b:	74 19                	je     104686 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10466d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104670:	89 44 24 08          	mov    %eax,0x8(%esp)
  104674:	8b 45 0c             	mov    0xc(%ebp),%eax
  104677:	89 44 24 04          	mov    %eax,0x4(%esp)
  10467b:	8b 45 08             	mov    0x8(%ebp),%eax
  10467e:	89 04 24             	mov    %eax,(%esp)
  104681:	e8 5d ff ff ff       	call   1045e3 <page_remove_pte>
    }
}
  104686:	c9                   	leave  
  104687:	c3                   	ret    

00104688 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104688:	55                   	push   %ebp
  104689:	89 e5                	mov    %esp,%ebp
  10468b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10468e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104695:	00 
  104696:	8b 45 10             	mov    0x10(%ebp),%eax
  104699:	89 44 24 04          	mov    %eax,0x4(%esp)
  10469d:	8b 45 08             	mov    0x8(%ebp),%eax
  1046a0:	89 04 24             	mov    %eax,(%esp)
  1046a3:	e8 aa fd ff ff       	call   104452 <get_pte>
  1046a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1046ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046af:	75 0a                	jne    1046bb <page_insert+0x33>
        return -E_NO_MEM;
  1046b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1046b6:	e9 84 00 00 00       	jmp    10473f <page_insert+0xb7>
    }
    page_ref_inc(page);
  1046bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046be:	89 04 24             	mov    %eax,(%esp)
  1046c1:	e8 e2 f4 ff ff       	call   103ba8 <page_ref_inc>
    if (*ptep & PTE_P) {
  1046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046c9:	8b 00                	mov    (%eax),%eax
  1046cb:	83 e0 01             	and    $0x1,%eax
  1046ce:	85 c0                	test   %eax,%eax
  1046d0:	74 3e                	je     104710 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  1046d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046d5:	8b 00                	mov    (%eax),%eax
  1046d7:	89 04 24             	mov    %eax,(%esp)
  1046da:	e8 5c f4 ff ff       	call   103b3b <pte2page>
  1046df:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1046e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1046e8:	75 0d                	jne    1046f7 <page_insert+0x6f>
            page_ref_dec(page);
  1046ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046ed:	89 04 24             	mov    %eax,(%esp)
  1046f0:	e8 ca f4 ff ff       	call   103bbf <page_ref_dec>
  1046f5:	eb 19                	jmp    104710 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046fe:	8b 45 10             	mov    0x10(%ebp),%eax
  104701:	89 44 24 04          	mov    %eax,0x4(%esp)
  104705:	8b 45 08             	mov    0x8(%ebp),%eax
  104708:	89 04 24             	mov    %eax,(%esp)
  10470b:	e8 d3 fe ff ff       	call   1045e3 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104710:	8b 45 0c             	mov    0xc(%ebp),%eax
  104713:	89 04 24             	mov    %eax,(%esp)
  104716:	e8 67 f3 ff ff       	call   103a82 <page2pa>
  10471b:	0b 45 14             	or     0x14(%ebp),%eax
  10471e:	83 c8 01             	or     $0x1,%eax
  104721:	89 c2                	mov    %eax,%edx
  104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104726:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  104728:	8b 45 10             	mov    0x10(%ebp),%eax
  10472b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10472f:	8b 45 08             	mov    0x8(%ebp),%eax
  104732:	89 04 24             	mov    %eax,(%esp)
  104735:	e8 07 00 00 00       	call   104741 <tlb_invalidate>
    return 0;
  10473a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10473f:	c9                   	leave  
  104740:	c3                   	ret    

00104741 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  104741:	55                   	push   %ebp
  104742:	89 e5                	mov    %esp,%ebp
  104744:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  104747:	0f 20 d8             	mov    %cr3,%eax
  10474a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10474d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
  104750:	89 c2                	mov    %eax,%edx
  104752:	8b 45 08             	mov    0x8(%ebp),%eax
  104755:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104758:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10475f:	77 23                	ja     104784 <tlb_invalidate+0x43>
  104761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104764:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104768:	c7 44 24 08 50 6b 10 	movl   $0x106b50,0x8(%esp)
  10476f:	00 
  104770:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
  104777:	00 
  104778:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  10477f:	e8 59 c5 ff ff       	call   100cdd <__panic>
  104784:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104787:	05 00 00 00 40       	add    $0x40000000,%eax
  10478c:	39 c2                	cmp    %eax,%edx
  10478e:	75 0c                	jne    10479c <tlb_invalidate+0x5b>
        invlpg((void *)la);
  104790:	8b 45 0c             	mov    0xc(%ebp),%eax
  104793:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  104796:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104799:	0f 01 38             	invlpg (%eax)
    }
}
  10479c:	c9                   	leave  
  10479d:	c3                   	ret    

0010479e <check_alloc_page>:

static void
check_alloc_page(void) {
  10479e:	55                   	push   %ebp
  10479f:	89 e5                	mov    %esp,%ebp
  1047a1:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1047a4:	a1 1c af 11 00       	mov    0x11af1c,%eax
  1047a9:	8b 40 18             	mov    0x18(%eax),%eax
  1047ac:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1047ae:	c7 04 24 d4 6b 10 00 	movl   $0x106bd4,(%esp)
  1047b5:	e8 99 bb ff ff       	call   100353 <cprintf>
}
  1047ba:	c9                   	leave  
  1047bb:	c3                   	ret    

001047bc <check_pgdir>:

static void
check_pgdir(void) {
  1047bc:	55                   	push   %ebp
  1047bd:	89 e5                	mov    %esp,%ebp
  1047bf:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1047c2:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  1047c7:	3d 00 80 03 00       	cmp    $0x38000,%eax
  1047cc:	76 24                	jbe    1047f2 <check_pgdir+0x36>
  1047ce:	c7 44 24 0c f3 6b 10 	movl   $0x106bf3,0xc(%esp)
  1047d5:	00 
  1047d6:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  1047dd:	00 
  1047de:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
  1047e5:	00 
  1047e6:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1047ed:	e8 eb c4 ff ff       	call   100cdd <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1047f2:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1047f7:	85 c0                	test   %eax,%eax
  1047f9:	74 0e                	je     104809 <check_pgdir+0x4d>
  1047fb:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104800:	25 ff 0f 00 00       	and    $0xfff,%eax
  104805:	85 c0                	test   %eax,%eax
  104807:	74 24                	je     10482d <check_pgdir+0x71>
  104809:	c7 44 24 0c 10 6c 10 	movl   $0x106c10,0xc(%esp)
  104810:	00 
  104811:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104818:	00 
  104819:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
  104820:	00 
  104821:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104828:	e8 b0 c4 ff ff       	call   100cdd <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  10482d:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104832:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104839:	00 
  10483a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104841:	00 
  104842:	89 04 24             	mov    %eax,(%esp)
  104845:	e8 40 fd ff ff       	call   10458a <get_page>
  10484a:	85 c0                	test   %eax,%eax
  10484c:	74 24                	je     104872 <check_pgdir+0xb6>
  10484e:	c7 44 24 0c 48 6c 10 	movl   $0x106c48,0xc(%esp)
  104855:	00 
  104856:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  10485d:	00 
  10485e:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
  104865:	00 
  104866:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  10486d:	e8 6b c4 ff ff       	call   100cdd <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104872:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104879:	e8 18 f5 ff ff       	call   103d96 <alloc_pages>
  10487e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  104881:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104886:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10488d:	00 
  10488e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104895:	00 
  104896:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104899:	89 54 24 04          	mov    %edx,0x4(%esp)
  10489d:	89 04 24             	mov    %eax,(%esp)
  1048a0:	e8 e3 fd ff ff       	call   104688 <page_insert>
  1048a5:	85 c0                	test   %eax,%eax
  1048a7:	74 24                	je     1048cd <check_pgdir+0x111>
  1048a9:	c7 44 24 0c 70 6c 10 	movl   $0x106c70,0xc(%esp)
  1048b0:	00 
  1048b1:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  1048b8:	00 
  1048b9:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  1048c0:	00 
  1048c1:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1048c8:	e8 10 c4 ff ff       	call   100cdd <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  1048cd:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1048d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048d9:	00 
  1048da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048e1:	00 
  1048e2:	89 04 24             	mov    %eax,(%esp)
  1048e5:	e8 68 fb ff ff       	call   104452 <get_pte>
  1048ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1048ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1048f1:	75 24                	jne    104917 <check_pgdir+0x15b>
  1048f3:	c7 44 24 0c 9c 6c 10 	movl   $0x106c9c,0xc(%esp)
  1048fa:	00 
  1048fb:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104902:	00 
  104903:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  10490a:	00 
  10490b:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104912:	e8 c6 c3 ff ff       	call   100cdd <__panic>
    assert(pte2page(*ptep) == p1);
  104917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10491a:	8b 00                	mov    (%eax),%eax
  10491c:	89 04 24             	mov    %eax,(%esp)
  10491f:	e8 17 f2 ff ff       	call   103b3b <pte2page>
  104924:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104927:	74 24                	je     10494d <check_pgdir+0x191>
  104929:	c7 44 24 0c c9 6c 10 	movl   $0x106cc9,0xc(%esp)
  104930:	00 
  104931:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104938:	00 
  104939:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  104940:	00 
  104941:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104948:	e8 90 c3 ff ff       	call   100cdd <__panic>
    assert(page_ref(p1) == 1);
  10494d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104950:	89 04 24             	mov    %eax,(%esp)
  104953:	e8 39 f2 ff ff       	call   103b91 <page_ref>
  104958:	83 f8 01             	cmp    $0x1,%eax
  10495b:	74 24                	je     104981 <check_pgdir+0x1c5>
  10495d:	c7 44 24 0c df 6c 10 	movl   $0x106cdf,0xc(%esp)
  104964:	00 
  104965:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  10496c:	00 
  10496d:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  104974:	00 
  104975:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  10497c:	e8 5c c3 ff ff       	call   100cdd <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104981:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104986:	8b 00                	mov    (%eax),%eax
  104988:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10498d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104990:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104993:	c1 e8 0c             	shr    $0xc,%eax
  104996:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104999:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  10499e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1049a1:	72 23                	jb     1049c6 <check_pgdir+0x20a>
  1049a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1049aa:	c7 44 24 08 ac 6a 10 	movl   $0x106aac,0x8(%esp)
  1049b1:	00 
  1049b2:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  1049b9:	00 
  1049ba:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1049c1:	e8 17 c3 ff ff       	call   100cdd <__panic>
  1049c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049c9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1049ce:	83 c0 04             	add    $0x4,%eax
  1049d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  1049d4:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1049d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1049e0:	00 
  1049e1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1049e8:	00 
  1049e9:	89 04 24             	mov    %eax,(%esp)
  1049ec:	e8 61 fa ff ff       	call   104452 <get_pte>
  1049f1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1049f4:	74 24                	je     104a1a <check_pgdir+0x25e>
  1049f6:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  1049fd:	00 
  1049fe:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104a05:	00 
  104a06:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  104a0d:	00 
  104a0e:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104a15:	e8 c3 c2 ff ff       	call   100cdd <__panic>

    p2 = alloc_page();
  104a1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104a21:	e8 70 f3 ff ff       	call   103d96 <alloc_pages>
  104a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104a29:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104a35:	00 
  104a36:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104a3d:	00 
  104a3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104a41:	89 54 24 04          	mov    %edx,0x4(%esp)
  104a45:	89 04 24             	mov    %eax,(%esp)
  104a48:	e8 3b fc ff ff       	call   104688 <page_insert>
  104a4d:	85 c0                	test   %eax,%eax
  104a4f:	74 24                	je     104a75 <check_pgdir+0x2b9>
  104a51:	c7 44 24 0c 1c 6d 10 	movl   $0x106d1c,0xc(%esp)
  104a58:	00 
  104a59:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104a60:	00 
  104a61:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  104a68:	00 
  104a69:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104a70:	e8 68 c2 ff ff       	call   100cdd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104a75:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104a7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104a81:	00 
  104a82:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104a89:	00 
  104a8a:	89 04 24             	mov    %eax,(%esp)
  104a8d:	e8 c0 f9 ff ff       	call   104452 <get_pte>
  104a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104a99:	75 24                	jne    104abf <check_pgdir+0x303>
  104a9b:	c7 44 24 0c 54 6d 10 	movl   $0x106d54,0xc(%esp)
  104aa2:	00 
  104aa3:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104aaa:	00 
  104aab:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  104ab2:	00 
  104ab3:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104aba:	e8 1e c2 ff ff       	call   100cdd <__panic>
    assert(*ptep & PTE_U);
  104abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ac2:	8b 00                	mov    (%eax),%eax
  104ac4:	83 e0 04             	and    $0x4,%eax
  104ac7:	85 c0                	test   %eax,%eax
  104ac9:	75 24                	jne    104aef <check_pgdir+0x333>
  104acb:	c7 44 24 0c 84 6d 10 	movl   $0x106d84,0xc(%esp)
  104ad2:	00 
  104ad3:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104ada:	00 
  104adb:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  104ae2:	00 
  104ae3:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104aea:	e8 ee c1 ff ff       	call   100cdd <__panic>
    assert(*ptep & PTE_W);
  104aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104af2:	8b 00                	mov    (%eax),%eax
  104af4:	83 e0 02             	and    $0x2,%eax
  104af7:	85 c0                	test   %eax,%eax
  104af9:	75 24                	jne    104b1f <check_pgdir+0x363>
  104afb:	c7 44 24 0c 92 6d 10 	movl   $0x106d92,0xc(%esp)
  104b02:	00 
  104b03:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104b0a:	00 
  104b0b:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  104b12:	00 
  104b13:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104b1a:	e8 be c1 ff ff       	call   100cdd <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104b1f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b24:	8b 00                	mov    (%eax),%eax
  104b26:	83 e0 04             	and    $0x4,%eax
  104b29:	85 c0                	test   %eax,%eax
  104b2b:	75 24                	jne    104b51 <check_pgdir+0x395>
  104b2d:	c7 44 24 0c a0 6d 10 	movl   $0x106da0,0xc(%esp)
  104b34:	00 
  104b35:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104b3c:	00 
  104b3d:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  104b44:	00 
  104b45:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104b4c:	e8 8c c1 ff ff       	call   100cdd <__panic>
    assert(page_ref(p2) == 1);
  104b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b54:	89 04 24             	mov    %eax,(%esp)
  104b57:	e8 35 f0 ff ff       	call   103b91 <page_ref>
  104b5c:	83 f8 01             	cmp    $0x1,%eax
  104b5f:	74 24                	je     104b85 <check_pgdir+0x3c9>
  104b61:	c7 44 24 0c b6 6d 10 	movl   $0x106db6,0xc(%esp)
  104b68:	00 
  104b69:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104b70:	00 
  104b71:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104b78:	00 
  104b79:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104b80:	e8 58 c1 ff ff       	call   100cdd <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104b85:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104b8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104b91:	00 
  104b92:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104b99:	00 
  104b9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ba1:	89 04 24             	mov    %eax,(%esp)
  104ba4:	e8 df fa ff ff       	call   104688 <page_insert>
  104ba9:	85 c0                	test   %eax,%eax
  104bab:	74 24                	je     104bd1 <check_pgdir+0x415>
  104bad:	c7 44 24 0c c8 6d 10 	movl   $0x106dc8,0xc(%esp)
  104bb4:	00 
  104bb5:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104bbc:	00 
  104bbd:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  104bc4:	00 
  104bc5:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104bcc:	e8 0c c1 ff ff       	call   100cdd <__panic>
    assert(page_ref(p1) == 2);
  104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bd4:	89 04 24             	mov    %eax,(%esp)
  104bd7:	e8 b5 ef ff ff       	call   103b91 <page_ref>
  104bdc:	83 f8 02             	cmp    $0x2,%eax
  104bdf:	74 24                	je     104c05 <check_pgdir+0x449>
  104be1:	c7 44 24 0c f4 6d 10 	movl   $0x106df4,0xc(%esp)
  104be8:	00 
  104be9:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104bf0:	00 
  104bf1:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  104bf8:	00 
  104bf9:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104c00:	e8 d8 c0 ff ff       	call   100cdd <__panic>
    assert(page_ref(p2) == 0);
  104c05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c08:	89 04 24             	mov    %eax,(%esp)
  104c0b:	e8 81 ef ff ff       	call   103b91 <page_ref>
  104c10:	85 c0                	test   %eax,%eax
  104c12:	74 24                	je     104c38 <check_pgdir+0x47c>
  104c14:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104c1b:	00 
  104c1c:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104c23:	00 
  104c24:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  104c2b:	00 
  104c2c:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104c33:	e8 a5 c0 ff ff       	call   100cdd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104c38:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104c3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c44:	00 
  104c45:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c4c:	00 
  104c4d:	89 04 24             	mov    %eax,(%esp)
  104c50:	e8 fd f7 ff ff       	call   104452 <get_pte>
  104c55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104c58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104c5c:	75 24                	jne    104c82 <check_pgdir+0x4c6>
  104c5e:	c7 44 24 0c 54 6d 10 	movl   $0x106d54,0xc(%esp)
  104c65:	00 
  104c66:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104c6d:	00 
  104c6e:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  104c75:	00 
  104c76:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104c7d:	e8 5b c0 ff ff       	call   100cdd <__panic>
    assert(pte2page(*ptep) == p1);
  104c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c85:	8b 00                	mov    (%eax),%eax
  104c87:	89 04 24             	mov    %eax,(%esp)
  104c8a:	e8 ac ee ff ff       	call   103b3b <pte2page>
  104c8f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104c92:	74 24                	je     104cb8 <check_pgdir+0x4fc>
  104c94:	c7 44 24 0c c9 6c 10 	movl   $0x106cc9,0xc(%esp)
  104c9b:	00 
  104c9c:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104ca3:	00 
  104ca4:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104cab:	00 
  104cac:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104cb3:	e8 25 c0 ff ff       	call   100cdd <__panic>
    assert((*ptep & PTE_U) == 0);
  104cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cbb:	8b 00                	mov    (%eax),%eax
  104cbd:	83 e0 04             	and    $0x4,%eax
  104cc0:	85 c0                	test   %eax,%eax
  104cc2:	74 24                	je     104ce8 <check_pgdir+0x52c>
  104cc4:	c7 44 24 0c 18 6e 10 	movl   $0x106e18,0xc(%esp)
  104ccb:	00 
  104ccc:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104cd3:	00 
  104cd4:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  104cdb:	00 
  104cdc:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104ce3:	e8 f5 bf ff ff       	call   100cdd <__panic>

    page_remove(boot_pgdir, 0x0);
  104ce8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ced:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104cf4:	00 
  104cf5:	89 04 24             	mov    %eax,(%esp)
  104cf8:	e8 47 f9 ff ff       	call   104644 <page_remove>
    assert(page_ref(p1) == 1);
  104cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d00:	89 04 24             	mov    %eax,(%esp)
  104d03:	e8 89 ee ff ff       	call   103b91 <page_ref>
  104d08:	83 f8 01             	cmp    $0x1,%eax
  104d0b:	74 24                	je     104d31 <check_pgdir+0x575>
  104d0d:	c7 44 24 0c df 6c 10 	movl   $0x106cdf,0xc(%esp)
  104d14:	00 
  104d15:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104d1c:	00 
  104d1d:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104d24:	00 
  104d25:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104d2c:	e8 ac bf ff ff       	call   100cdd <__panic>
    assert(page_ref(p2) == 0);
  104d31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d34:	89 04 24             	mov    %eax,(%esp)
  104d37:	e8 55 ee ff ff       	call   103b91 <page_ref>
  104d3c:	85 c0                	test   %eax,%eax
  104d3e:	74 24                	je     104d64 <check_pgdir+0x5a8>
  104d40:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104d47:	00 
  104d48:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104d4f:	00 
  104d50:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104d57:	00 
  104d58:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104d5f:	e8 79 bf ff ff       	call   100cdd <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104d64:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104d69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d70:	00 
  104d71:	89 04 24             	mov    %eax,(%esp)
  104d74:	e8 cb f8 ff ff       	call   104644 <page_remove>
    assert(page_ref(p1) == 0);
  104d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d7c:	89 04 24             	mov    %eax,(%esp)
  104d7f:	e8 0d ee ff ff       	call   103b91 <page_ref>
  104d84:	85 c0                	test   %eax,%eax
  104d86:	74 24                	je     104dac <check_pgdir+0x5f0>
  104d88:	c7 44 24 0c 2d 6e 10 	movl   $0x106e2d,0xc(%esp)
  104d8f:	00 
  104d90:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104d97:	00 
  104d98:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  104d9f:	00 
  104da0:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104da7:	e8 31 bf ff ff       	call   100cdd <__panic>
    assert(page_ref(p2) == 0);
  104dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104daf:	89 04 24             	mov    %eax,(%esp)
  104db2:	e8 da ed ff ff       	call   103b91 <page_ref>
  104db7:	85 c0                	test   %eax,%eax
  104db9:	74 24                	je     104ddf <check_pgdir+0x623>
  104dbb:	c7 44 24 0c 06 6e 10 	movl   $0x106e06,0xc(%esp)
  104dc2:	00 
  104dc3:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104dca:	00 
  104dcb:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  104dd2:	00 
  104dd3:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104dda:	e8 fe be ff ff       	call   100cdd <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  104ddf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104de4:	8b 00                	mov    (%eax),%eax
  104de6:	89 04 24             	mov    %eax,(%esp)
  104de9:	e8 8b ed ff ff       	call   103b79 <pde2page>
  104dee:	89 04 24             	mov    %eax,(%esp)
  104df1:	e8 9b ed ff ff       	call   103b91 <page_ref>
  104df6:	83 f8 01             	cmp    $0x1,%eax
  104df9:	74 24                	je     104e1f <check_pgdir+0x663>
  104dfb:	c7 44 24 0c 40 6e 10 	movl   $0x106e40,0xc(%esp)
  104e02:	00 
  104e03:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104e0a:	00 
  104e0b:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104e12:	00 
  104e13:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104e1a:	e8 be be ff ff       	call   100cdd <__panic>
    free_page(pde2page(boot_pgdir[0]));
  104e1f:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e24:	8b 00                	mov    (%eax),%eax
  104e26:	89 04 24             	mov    %eax,(%esp)
  104e29:	e8 4b ed ff ff       	call   103b79 <pde2page>
  104e2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104e35:	00 
  104e36:	89 04 24             	mov    %eax,(%esp)
  104e39:	e8 90 ef ff ff       	call   103dce <free_pages>
    boot_pgdir[0] = 0;
  104e3e:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104e43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104e49:	c7 04 24 67 6e 10 00 	movl   $0x106e67,(%esp)
  104e50:	e8 fe b4 ff ff       	call   100353 <cprintf>
}
  104e55:	c9                   	leave  
  104e56:	c3                   	ret    

00104e57 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104e57:	55                   	push   %ebp
  104e58:	89 e5                	mov    %esp,%ebp
  104e5a:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104e64:	e9 ca 00 00 00       	jmp    104f33 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e72:	c1 e8 0c             	shr    $0xc,%eax
  104e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e78:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104e7d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104e80:	72 23                	jb     104ea5 <check_boot_pgdir+0x4e>
  104e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104e89:	c7 44 24 08 ac 6a 10 	movl   $0x106aac,0x8(%esp)
  104e90:	00 
  104e91:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104e98:	00 
  104e99:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104ea0:	e8 38 be ff ff       	call   100cdd <__panic>
  104ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ea8:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104ead:	89 c2                	mov    %eax,%edx
  104eaf:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104eb4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ebb:	00 
  104ebc:	89 54 24 04          	mov    %edx,0x4(%esp)
  104ec0:	89 04 24             	mov    %eax,(%esp)
  104ec3:	e8 8a f5 ff ff       	call   104452 <get_pte>
  104ec8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104ecb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104ecf:	75 24                	jne    104ef5 <check_boot_pgdir+0x9e>
  104ed1:	c7 44 24 0c 84 6e 10 	movl   $0x106e84,0xc(%esp)
  104ed8:	00 
  104ed9:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104ee0:	00 
  104ee1:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104ee8:	00 
  104ee9:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104ef0:	e8 e8 bd ff ff       	call   100cdd <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ef8:	8b 00                	mov    (%eax),%eax
  104efa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104eff:	89 c2                	mov    %eax,%edx
  104f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f04:	39 c2                	cmp    %eax,%edx
  104f06:	74 24                	je     104f2c <check_boot_pgdir+0xd5>
  104f08:	c7 44 24 0c c1 6e 10 	movl   $0x106ec1,0xc(%esp)
  104f0f:	00 
  104f10:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104f17:	00 
  104f18:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  104f1f:	00 
  104f20:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104f27:	e8 b1 bd ff ff       	call   100cdd <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  104f2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  104f33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104f36:	a1 80 ae 11 00       	mov    0x11ae80,%eax
  104f3b:	39 c2                	cmp    %eax,%edx
  104f3d:	0f 82 26 ff ff ff    	jb     104e69 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104f43:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f48:	05 ac 0f 00 00       	add    $0xfac,%eax
  104f4d:	8b 00                	mov    (%eax),%eax
  104f4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104f54:	89 c2                	mov    %eax,%edx
  104f56:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104f5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104f5e:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104f65:	77 23                	ja     104f8a <check_boot_pgdir+0x133>
  104f67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104f6e:	c7 44 24 08 50 6b 10 	movl   $0x106b50,0x8(%esp)
  104f75:	00 
  104f76:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104f7d:	00 
  104f7e:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104f85:	e8 53 bd ff ff       	call   100cdd <__panic>
  104f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f8d:	05 00 00 00 40       	add    $0x40000000,%eax
  104f92:	39 c2                	cmp    %eax,%edx
  104f94:	74 24                	je     104fba <check_boot_pgdir+0x163>
  104f96:	c7 44 24 0c d8 6e 10 	movl   $0x106ed8,0xc(%esp)
  104f9d:	00 
  104f9e:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104fa5:	00 
  104fa6:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104fad:	00 
  104fae:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104fb5:	e8 23 bd ff ff       	call   100cdd <__panic>

    assert(boot_pgdir[0] == 0);
  104fba:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104fbf:	8b 00                	mov    (%eax),%eax
  104fc1:	85 c0                	test   %eax,%eax
  104fc3:	74 24                	je     104fe9 <check_boot_pgdir+0x192>
  104fc5:	c7 44 24 0c 0c 6f 10 	movl   $0x106f0c,0xc(%esp)
  104fcc:	00 
  104fcd:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  104fd4:	00 
  104fd5:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  104fdc:	00 
  104fdd:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  104fe4:	e8 f4 bc ff ff       	call   100cdd <__panic>

    struct Page *p;
    p = alloc_page();
  104fe9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ff0:	e8 a1 ed ff ff       	call   103d96 <alloc_pages>
  104ff5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104ff8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  104ffd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105004:	00 
  105005:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  10500c:	00 
  10500d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105010:	89 54 24 04          	mov    %edx,0x4(%esp)
  105014:	89 04 24             	mov    %eax,(%esp)
  105017:	e8 6c f6 ff ff       	call   104688 <page_insert>
  10501c:	85 c0                	test   %eax,%eax
  10501e:	74 24                	je     105044 <check_boot_pgdir+0x1ed>
  105020:	c7 44 24 0c 20 6f 10 	movl   $0x106f20,0xc(%esp)
  105027:	00 
  105028:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  10502f:	00 
  105030:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  105037:	00 
  105038:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  10503f:	e8 99 bc ff ff       	call   100cdd <__panic>
    assert(page_ref(p) == 1);
  105044:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105047:	89 04 24             	mov    %eax,(%esp)
  10504a:	e8 42 eb ff ff       	call   103b91 <page_ref>
  10504f:	83 f8 01             	cmp    $0x1,%eax
  105052:	74 24                	je     105078 <check_boot_pgdir+0x221>
  105054:	c7 44 24 0c 4e 6f 10 	movl   $0x106f4e,0xc(%esp)
  10505b:	00 
  10505c:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  105063:	00 
  105064:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  10506b:	00 
  10506c:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  105073:	e8 65 bc ff ff       	call   100cdd <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  105078:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  10507d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105084:	00 
  105085:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10508c:	00 
  10508d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105090:	89 54 24 04          	mov    %edx,0x4(%esp)
  105094:	89 04 24             	mov    %eax,(%esp)
  105097:	e8 ec f5 ff ff       	call   104688 <page_insert>
  10509c:	85 c0                	test   %eax,%eax
  10509e:	74 24                	je     1050c4 <check_boot_pgdir+0x26d>
  1050a0:	c7 44 24 0c 60 6f 10 	movl   $0x106f60,0xc(%esp)
  1050a7:	00 
  1050a8:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  1050af:	00 
  1050b0:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  1050b7:	00 
  1050b8:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1050bf:	e8 19 bc ff ff       	call   100cdd <__panic>
    assert(page_ref(p) == 2);
  1050c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1050c7:	89 04 24             	mov    %eax,(%esp)
  1050ca:	e8 c2 ea ff ff       	call   103b91 <page_ref>
  1050cf:	83 f8 02             	cmp    $0x2,%eax
  1050d2:	74 24                	je     1050f8 <check_boot_pgdir+0x2a1>
  1050d4:	c7 44 24 0c 97 6f 10 	movl   $0x106f97,0xc(%esp)
  1050db:	00 
  1050dc:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  1050e3:	00 
  1050e4:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  1050eb:	00 
  1050ec:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  1050f3:	e8 e5 bb ff ff       	call   100cdd <__panic>

    const char *str = "ucore: Hello world!!";
  1050f8:	c7 45 dc a8 6f 10 00 	movl   $0x106fa8,-0x24(%ebp)
    strcpy((void *)0x100, str);
  1050ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105102:	89 44 24 04          	mov    %eax,0x4(%esp)
  105106:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10510d:	e8 19 0a 00 00       	call   105b2b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  105112:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  105119:	00 
  10511a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105121:	e8 7e 0a 00 00       	call   105ba4 <strcmp>
  105126:	85 c0                	test   %eax,%eax
  105128:	74 24                	je     10514e <check_boot_pgdir+0x2f7>
  10512a:	c7 44 24 0c c0 6f 10 	movl   $0x106fc0,0xc(%esp)
  105131:	00 
  105132:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  105139:	00 
  10513a:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
  105141:	00 
  105142:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  105149:	e8 8f bb ff ff       	call   100cdd <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  10514e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105151:	89 04 24             	mov    %eax,(%esp)
  105154:	e8 8e e9 ff ff       	call   103ae7 <page2kva>
  105159:	05 00 01 00 00       	add    $0x100,%eax
  10515e:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  105161:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  105168:	e8 66 09 00 00       	call   105ad3 <strlen>
  10516d:	85 c0                	test   %eax,%eax
  10516f:	74 24                	je     105195 <check_boot_pgdir+0x33e>
  105171:	c7 44 24 0c f8 6f 10 	movl   $0x106ff8,0xc(%esp)
  105178:	00 
  105179:	c7 44 24 08 99 6b 10 	movl   $0x106b99,0x8(%esp)
  105180:	00 
  105181:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  105188:	00 
  105189:	c7 04 24 74 6b 10 00 	movl   $0x106b74,(%esp)
  105190:	e8 48 bb ff ff       	call   100cdd <__panic>

    free_page(p);
  105195:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10519c:	00 
  10519d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1051a0:	89 04 24             	mov    %eax,(%esp)
  1051a3:	e8 26 ec ff ff       	call   103dce <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  1051a8:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1051ad:	8b 00                	mov    (%eax),%eax
  1051af:	89 04 24             	mov    %eax,(%esp)
  1051b2:	e8 c2 e9 ff ff       	call   103b79 <pde2page>
  1051b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1051be:	00 
  1051bf:	89 04 24             	mov    %eax,(%esp)
  1051c2:	e8 07 ec ff ff       	call   103dce <free_pages>
    boot_pgdir[0] = 0;
  1051c7:	a1 e0 79 11 00       	mov    0x1179e0,%eax
  1051cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  1051d2:	c7 04 24 1c 70 10 00 	movl   $0x10701c,(%esp)
  1051d9:	e8 75 b1 ff ff       	call   100353 <cprintf>
}
  1051de:	c9                   	leave  
  1051df:	c3                   	ret    

001051e0 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1051e0:	55                   	push   %ebp
  1051e1:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1051e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1051e6:	83 e0 04             	and    $0x4,%eax
  1051e9:	85 c0                	test   %eax,%eax
  1051eb:	74 07                	je     1051f4 <perm2str+0x14>
  1051ed:	b8 75 00 00 00       	mov    $0x75,%eax
  1051f2:	eb 05                	jmp    1051f9 <perm2str+0x19>
  1051f4:	b8 2d 00 00 00       	mov    $0x2d,%eax
  1051f9:	a2 08 af 11 00       	mov    %al,0x11af08
    str[1] = 'r';
  1051fe:	c6 05 09 af 11 00 72 	movb   $0x72,0x11af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105205:	8b 45 08             	mov    0x8(%ebp),%eax
  105208:	83 e0 02             	and    $0x2,%eax
  10520b:	85 c0                	test   %eax,%eax
  10520d:	74 07                	je     105216 <perm2str+0x36>
  10520f:	b8 77 00 00 00       	mov    $0x77,%eax
  105214:	eb 05                	jmp    10521b <perm2str+0x3b>
  105216:	b8 2d 00 00 00       	mov    $0x2d,%eax
  10521b:	a2 0a af 11 00       	mov    %al,0x11af0a
    str[3] = '\0';
  105220:	c6 05 0b af 11 00 00 	movb   $0x0,0x11af0b
    return str;
  105227:	b8 08 af 11 00       	mov    $0x11af08,%eax
}
  10522c:	5d                   	pop    %ebp
  10522d:	c3                   	ret    

0010522e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  10522e:	55                   	push   %ebp
  10522f:	89 e5                	mov    %esp,%ebp
  105231:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  105234:	8b 45 10             	mov    0x10(%ebp),%eax
  105237:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10523a:	72 0a                	jb     105246 <get_pgtable_items+0x18>
        return 0;
  10523c:	b8 00 00 00 00       	mov    $0x0,%eax
  105241:	e9 9c 00 00 00       	jmp    1052e2 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
  105246:	eb 04                	jmp    10524c <get_pgtable_items+0x1e>
        start ++;
  105248:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  10524c:	8b 45 10             	mov    0x10(%ebp),%eax
  10524f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105252:	73 18                	jae    10526c <get_pgtable_items+0x3e>
  105254:	8b 45 10             	mov    0x10(%ebp),%eax
  105257:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10525e:	8b 45 14             	mov    0x14(%ebp),%eax
  105261:	01 d0                	add    %edx,%eax
  105263:	8b 00                	mov    (%eax),%eax
  105265:	83 e0 01             	and    $0x1,%eax
  105268:	85 c0                	test   %eax,%eax
  10526a:	74 dc                	je     105248 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
  10526c:	8b 45 10             	mov    0x10(%ebp),%eax
  10526f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105272:	73 69                	jae    1052dd <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  105274:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  105278:	74 08                	je     105282 <get_pgtable_items+0x54>
            *left_store = start;
  10527a:	8b 45 18             	mov    0x18(%ebp),%eax
  10527d:	8b 55 10             	mov    0x10(%ebp),%edx
  105280:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105282:	8b 45 10             	mov    0x10(%ebp),%eax
  105285:	8d 50 01             	lea    0x1(%eax),%edx
  105288:	89 55 10             	mov    %edx,0x10(%ebp)
  10528b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105292:	8b 45 14             	mov    0x14(%ebp),%eax
  105295:	01 d0                	add    %edx,%eax
  105297:	8b 00                	mov    (%eax),%eax
  105299:	83 e0 07             	and    $0x7,%eax
  10529c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10529f:	eb 04                	jmp    1052a5 <get_pgtable_items+0x77>
            start ++;
  1052a1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  1052a5:	8b 45 10             	mov    0x10(%ebp),%eax
  1052a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1052ab:	73 1d                	jae    1052ca <get_pgtable_items+0x9c>
  1052ad:	8b 45 10             	mov    0x10(%ebp),%eax
  1052b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1052b7:	8b 45 14             	mov    0x14(%ebp),%eax
  1052ba:	01 d0                	add    %edx,%eax
  1052bc:	8b 00                	mov    (%eax),%eax
  1052be:	83 e0 07             	and    $0x7,%eax
  1052c1:	89 c2                	mov    %eax,%edx
  1052c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052c6:	39 c2                	cmp    %eax,%edx
  1052c8:	74 d7                	je     1052a1 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
  1052ca:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1052ce:	74 08                	je     1052d8 <get_pgtable_items+0xaa>
            *right_store = start;
  1052d0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1052d3:	8b 55 10             	mov    0x10(%ebp),%edx
  1052d6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  1052d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1052db:	eb 05                	jmp    1052e2 <get_pgtable_items+0xb4>
    }
    return 0;
  1052dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1052e2:	c9                   	leave  
  1052e3:	c3                   	ret    

001052e4 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1052e4:	55                   	push   %ebp
  1052e5:	89 e5                	mov    %esp,%ebp
  1052e7:	57                   	push   %edi
  1052e8:	56                   	push   %esi
  1052e9:	53                   	push   %ebx
  1052ea:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1052ed:	c7 04 24 3c 70 10 00 	movl   $0x10703c,(%esp)
  1052f4:	e8 5a b0 ff ff       	call   100353 <cprintf>
    size_t left, right = 0, perm;
  1052f9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105300:	e9 fa 00 00 00       	jmp    1053ff <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  105305:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105308:	89 04 24             	mov    %eax,(%esp)
  10530b:	e8 d0 fe ff ff       	call   1051e0 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105310:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105313:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105316:	29 d1                	sub    %edx,%ecx
  105318:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10531a:	89 d6                	mov    %edx,%esi
  10531c:	c1 e6 16             	shl    $0x16,%esi
  10531f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105322:	89 d3                	mov    %edx,%ebx
  105324:	c1 e3 16             	shl    $0x16,%ebx
  105327:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10532a:	89 d1                	mov    %edx,%ecx
  10532c:	c1 e1 16             	shl    $0x16,%ecx
  10532f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  105332:	8b 55 e0             	mov    -0x20(%ebp),%edx
  105335:	29 d7                	sub    %edx,%edi
  105337:	89 fa                	mov    %edi,%edx
  105339:	89 44 24 14          	mov    %eax,0x14(%esp)
  10533d:	89 74 24 10          	mov    %esi,0x10(%esp)
  105341:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105345:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105349:	89 54 24 04          	mov    %edx,0x4(%esp)
  10534d:	c7 04 24 6d 70 10 00 	movl   $0x10706d,(%esp)
  105354:	e8 fa af ff ff       	call   100353 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  105359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10535c:	c1 e0 0a             	shl    $0xa,%eax
  10535f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105362:	eb 54                	jmp    1053b8 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105367:	89 04 24             	mov    %eax,(%esp)
  10536a:	e8 71 fe ff ff       	call   1051e0 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10536f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105372:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105375:	29 d1                	sub    %edx,%ecx
  105377:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  105379:	89 d6                	mov    %edx,%esi
  10537b:	c1 e6 0c             	shl    $0xc,%esi
  10537e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105381:	89 d3                	mov    %edx,%ebx
  105383:	c1 e3 0c             	shl    $0xc,%ebx
  105386:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105389:	c1 e2 0c             	shl    $0xc,%edx
  10538c:	89 d1                	mov    %edx,%ecx
  10538e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  105391:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105394:	29 d7                	sub    %edx,%edi
  105396:	89 fa                	mov    %edi,%edx
  105398:	89 44 24 14          	mov    %eax,0x14(%esp)
  10539c:	89 74 24 10          	mov    %esi,0x10(%esp)
  1053a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1053a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1053a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1053ac:	c7 04 24 8c 70 10 00 	movl   $0x10708c,(%esp)
  1053b3:	e8 9b af ff ff       	call   100353 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1053b8:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
  1053bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1053c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1053c3:	89 ce                	mov    %ecx,%esi
  1053c5:	c1 e6 0a             	shl    $0xa,%esi
  1053c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  1053cb:	89 cb                	mov    %ecx,%ebx
  1053cd:	c1 e3 0a             	shl    $0xa,%ebx
  1053d0:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
  1053d3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  1053d7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
  1053da:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  1053de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1053e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1053e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  1053ea:	89 1c 24             	mov    %ebx,(%esp)
  1053ed:	e8 3c fe ff ff       	call   10522e <get_pgtable_items>
  1053f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1053f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1053f9:	0f 85 65 ff ff ff    	jne    105364 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1053ff:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
  105404:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105407:	8d 4d dc             	lea    -0x24(%ebp),%ecx
  10540a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  10540e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
  105411:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  105415:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105419:	89 44 24 08          	mov    %eax,0x8(%esp)
  10541d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  105424:	00 
  105425:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10542c:	e8 fd fd ff ff       	call   10522e <get_pgtable_items>
  105431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105438:	0f 85 c7 fe ff ff    	jne    105305 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  10543e:	c7 04 24 b0 70 10 00 	movl   $0x1070b0,(%esp)
  105445:	e8 09 af ff ff       	call   100353 <cprintf>
}
  10544a:	83 c4 4c             	add    $0x4c,%esp
  10544d:	5b                   	pop    %ebx
  10544e:	5e                   	pop    %esi
  10544f:	5f                   	pop    %edi
  105450:	5d                   	pop    %ebp
  105451:	c3                   	ret    

00105452 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105452:	55                   	push   %ebp
  105453:	89 e5                	mov    %esp,%ebp
  105455:	83 ec 58             	sub    $0x58,%esp
  105458:	8b 45 10             	mov    0x10(%ebp),%eax
  10545b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10545e:	8b 45 14             	mov    0x14(%ebp),%eax
  105461:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105464:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105467:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10546a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10546d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105470:	8b 45 18             	mov    0x18(%ebp),%eax
  105473:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105476:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105479:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10547c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10547f:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105482:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105485:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105488:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10548c:	74 1c                	je     1054aa <printnum+0x58>
  10548e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105491:	ba 00 00 00 00       	mov    $0x0,%edx
  105496:	f7 75 e4             	divl   -0x1c(%ebp)
  105499:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10549c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10549f:	ba 00 00 00 00       	mov    $0x0,%edx
  1054a4:	f7 75 e4             	divl   -0x1c(%ebp)
  1054a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1054aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1054b0:	f7 75 e4             	divl   -0x1c(%ebp)
  1054b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1054b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  1054b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1054bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1054bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054c2:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1054c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054c8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  1054cb:	8b 45 18             	mov    0x18(%ebp),%eax
  1054ce:	ba 00 00 00 00       	mov    $0x0,%edx
  1054d3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054d6:	77 56                	ja     10552e <printnum+0xdc>
  1054d8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1054db:	72 05                	jb     1054e2 <printnum+0x90>
  1054dd:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1054e0:	77 4c                	ja     10552e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1054e2:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1054e5:	8d 50 ff             	lea    -0x1(%eax),%edx
  1054e8:	8b 45 20             	mov    0x20(%ebp),%eax
  1054eb:	89 44 24 18          	mov    %eax,0x18(%esp)
  1054ef:	89 54 24 14          	mov    %edx,0x14(%esp)
  1054f3:	8b 45 18             	mov    0x18(%ebp),%eax
  1054f6:	89 44 24 10          	mov    %eax,0x10(%esp)
  1054fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105500:	89 44 24 08          	mov    %eax,0x8(%esp)
  105504:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105508:	8b 45 0c             	mov    0xc(%ebp),%eax
  10550b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10550f:	8b 45 08             	mov    0x8(%ebp),%eax
  105512:	89 04 24             	mov    %eax,(%esp)
  105515:	e8 38 ff ff ff       	call   105452 <printnum>
  10551a:	eb 1c                	jmp    105538 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10551c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10551f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105523:	8b 45 20             	mov    0x20(%ebp),%eax
  105526:	89 04 24             	mov    %eax,(%esp)
  105529:	8b 45 08             	mov    0x8(%ebp),%eax
  10552c:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  10552e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  105532:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105536:	7f e4                	jg     10551c <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105538:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10553b:	05 64 71 10 00       	add    $0x107164,%eax
  105540:	0f b6 00             	movzbl (%eax),%eax
  105543:	0f be c0             	movsbl %al,%eax
  105546:	8b 55 0c             	mov    0xc(%ebp),%edx
  105549:	89 54 24 04          	mov    %edx,0x4(%esp)
  10554d:	89 04 24             	mov    %eax,(%esp)
  105550:	8b 45 08             	mov    0x8(%ebp),%eax
  105553:	ff d0                	call   *%eax
}
  105555:	c9                   	leave  
  105556:	c3                   	ret    

00105557 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105557:	55                   	push   %ebp
  105558:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10555a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10555e:	7e 14                	jle    105574 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105560:	8b 45 08             	mov    0x8(%ebp),%eax
  105563:	8b 00                	mov    (%eax),%eax
  105565:	8d 48 08             	lea    0x8(%eax),%ecx
  105568:	8b 55 08             	mov    0x8(%ebp),%edx
  10556b:	89 0a                	mov    %ecx,(%edx)
  10556d:	8b 50 04             	mov    0x4(%eax),%edx
  105570:	8b 00                	mov    (%eax),%eax
  105572:	eb 30                	jmp    1055a4 <getuint+0x4d>
    }
    else if (lflag) {
  105574:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105578:	74 16                	je     105590 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10557a:	8b 45 08             	mov    0x8(%ebp),%eax
  10557d:	8b 00                	mov    (%eax),%eax
  10557f:	8d 48 04             	lea    0x4(%eax),%ecx
  105582:	8b 55 08             	mov    0x8(%ebp),%edx
  105585:	89 0a                	mov    %ecx,(%edx)
  105587:	8b 00                	mov    (%eax),%eax
  105589:	ba 00 00 00 00       	mov    $0x0,%edx
  10558e:	eb 14                	jmp    1055a4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105590:	8b 45 08             	mov    0x8(%ebp),%eax
  105593:	8b 00                	mov    (%eax),%eax
  105595:	8d 48 04             	lea    0x4(%eax),%ecx
  105598:	8b 55 08             	mov    0x8(%ebp),%edx
  10559b:	89 0a                	mov    %ecx,(%edx)
  10559d:	8b 00                	mov    (%eax),%eax
  10559f:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  1055a4:	5d                   	pop    %ebp
  1055a5:	c3                   	ret    

001055a6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  1055a6:	55                   	push   %ebp
  1055a7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1055a9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1055ad:	7e 14                	jle    1055c3 <getint+0x1d>
        return va_arg(*ap, long long);
  1055af:	8b 45 08             	mov    0x8(%ebp),%eax
  1055b2:	8b 00                	mov    (%eax),%eax
  1055b4:	8d 48 08             	lea    0x8(%eax),%ecx
  1055b7:	8b 55 08             	mov    0x8(%ebp),%edx
  1055ba:	89 0a                	mov    %ecx,(%edx)
  1055bc:	8b 50 04             	mov    0x4(%eax),%edx
  1055bf:	8b 00                	mov    (%eax),%eax
  1055c1:	eb 28                	jmp    1055eb <getint+0x45>
    }
    else if (lflag) {
  1055c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1055c7:	74 12                	je     1055db <getint+0x35>
        return va_arg(*ap, long);
  1055c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1055cc:	8b 00                	mov    (%eax),%eax
  1055ce:	8d 48 04             	lea    0x4(%eax),%ecx
  1055d1:	8b 55 08             	mov    0x8(%ebp),%edx
  1055d4:	89 0a                	mov    %ecx,(%edx)
  1055d6:	8b 00                	mov    (%eax),%eax
  1055d8:	99                   	cltd   
  1055d9:	eb 10                	jmp    1055eb <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1055db:	8b 45 08             	mov    0x8(%ebp),%eax
  1055de:	8b 00                	mov    (%eax),%eax
  1055e0:	8d 48 04             	lea    0x4(%eax),%ecx
  1055e3:	8b 55 08             	mov    0x8(%ebp),%edx
  1055e6:	89 0a                	mov    %ecx,(%edx)
  1055e8:	8b 00                	mov    (%eax),%eax
  1055ea:	99                   	cltd   
    }
}
  1055eb:	5d                   	pop    %ebp
  1055ec:	c3                   	ret    

001055ed <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1055ed:	55                   	push   %ebp
  1055ee:	89 e5                	mov    %esp,%ebp
  1055f0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1055f3:	8d 45 14             	lea    0x14(%ebp),%eax
  1055f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1055f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1055fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105600:	8b 45 10             	mov    0x10(%ebp),%eax
  105603:	89 44 24 08          	mov    %eax,0x8(%esp)
  105607:	8b 45 0c             	mov    0xc(%ebp),%eax
  10560a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10560e:	8b 45 08             	mov    0x8(%ebp),%eax
  105611:	89 04 24             	mov    %eax,(%esp)
  105614:	e8 02 00 00 00       	call   10561b <vprintfmt>
    va_end(ap);
}
  105619:	c9                   	leave  
  10561a:	c3                   	ret    

0010561b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10561b:	55                   	push   %ebp
  10561c:	89 e5                	mov    %esp,%ebp
  10561e:	56                   	push   %esi
  10561f:	53                   	push   %ebx
  105620:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105623:	eb 18                	jmp    10563d <vprintfmt+0x22>
            if (ch == '\0') {
  105625:	85 db                	test   %ebx,%ebx
  105627:	75 05                	jne    10562e <vprintfmt+0x13>
                return;
  105629:	e9 d1 03 00 00       	jmp    1059ff <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  10562e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105631:	89 44 24 04          	mov    %eax,0x4(%esp)
  105635:	89 1c 24             	mov    %ebx,(%esp)
  105638:	8b 45 08             	mov    0x8(%ebp),%eax
  10563b:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10563d:	8b 45 10             	mov    0x10(%ebp),%eax
  105640:	8d 50 01             	lea    0x1(%eax),%edx
  105643:	89 55 10             	mov    %edx,0x10(%ebp)
  105646:	0f b6 00             	movzbl (%eax),%eax
  105649:	0f b6 d8             	movzbl %al,%ebx
  10564c:	83 fb 25             	cmp    $0x25,%ebx
  10564f:	75 d4                	jne    105625 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  105651:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105655:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10565c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10565f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105662:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105669:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10566c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10566f:	8b 45 10             	mov    0x10(%ebp),%eax
  105672:	8d 50 01             	lea    0x1(%eax),%edx
  105675:	89 55 10             	mov    %edx,0x10(%ebp)
  105678:	0f b6 00             	movzbl (%eax),%eax
  10567b:	0f b6 d8             	movzbl %al,%ebx
  10567e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105681:	83 f8 55             	cmp    $0x55,%eax
  105684:	0f 87 44 03 00 00    	ja     1059ce <vprintfmt+0x3b3>
  10568a:	8b 04 85 88 71 10 00 	mov    0x107188(,%eax,4),%eax
  105691:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105693:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105697:	eb d6                	jmp    10566f <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105699:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10569d:	eb d0                	jmp    10566f <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10569f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  1056a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1056a9:	89 d0                	mov    %edx,%eax
  1056ab:	c1 e0 02             	shl    $0x2,%eax
  1056ae:	01 d0                	add    %edx,%eax
  1056b0:	01 c0                	add    %eax,%eax
  1056b2:	01 d8                	add    %ebx,%eax
  1056b4:	83 e8 30             	sub    $0x30,%eax
  1056b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  1056ba:	8b 45 10             	mov    0x10(%ebp),%eax
  1056bd:	0f b6 00             	movzbl (%eax),%eax
  1056c0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1056c3:	83 fb 2f             	cmp    $0x2f,%ebx
  1056c6:	7e 0b                	jle    1056d3 <vprintfmt+0xb8>
  1056c8:	83 fb 39             	cmp    $0x39,%ebx
  1056cb:	7f 06                	jg     1056d3 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1056cd:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1056d1:	eb d3                	jmp    1056a6 <vprintfmt+0x8b>
            goto process_precision;
  1056d3:	eb 33                	jmp    105708 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  1056d5:	8b 45 14             	mov    0x14(%ebp),%eax
  1056d8:	8d 50 04             	lea    0x4(%eax),%edx
  1056db:	89 55 14             	mov    %edx,0x14(%ebp)
  1056de:	8b 00                	mov    (%eax),%eax
  1056e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1056e3:	eb 23                	jmp    105708 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  1056e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1056e9:	79 0c                	jns    1056f7 <vprintfmt+0xdc>
                width = 0;
  1056eb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1056f2:	e9 78 ff ff ff       	jmp    10566f <vprintfmt+0x54>
  1056f7:	e9 73 ff ff ff       	jmp    10566f <vprintfmt+0x54>

        case '#':
            altflag = 1;
  1056fc:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105703:	e9 67 ff ff ff       	jmp    10566f <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  105708:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10570c:	79 12                	jns    105720 <vprintfmt+0x105>
                width = precision, precision = -1;
  10570e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105711:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105714:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  10571b:	e9 4f ff ff ff       	jmp    10566f <vprintfmt+0x54>
  105720:	e9 4a ff ff ff       	jmp    10566f <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105725:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  105729:	e9 41 ff ff ff       	jmp    10566f <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  10572e:	8b 45 14             	mov    0x14(%ebp),%eax
  105731:	8d 50 04             	lea    0x4(%eax),%edx
  105734:	89 55 14             	mov    %edx,0x14(%ebp)
  105737:	8b 00                	mov    (%eax),%eax
  105739:	8b 55 0c             	mov    0xc(%ebp),%edx
  10573c:	89 54 24 04          	mov    %edx,0x4(%esp)
  105740:	89 04 24             	mov    %eax,(%esp)
  105743:	8b 45 08             	mov    0x8(%ebp),%eax
  105746:	ff d0                	call   *%eax
            break;
  105748:	e9 ac 02 00 00       	jmp    1059f9 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10574d:	8b 45 14             	mov    0x14(%ebp),%eax
  105750:	8d 50 04             	lea    0x4(%eax),%edx
  105753:	89 55 14             	mov    %edx,0x14(%ebp)
  105756:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105758:	85 db                	test   %ebx,%ebx
  10575a:	79 02                	jns    10575e <vprintfmt+0x143>
                err = -err;
  10575c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10575e:	83 fb 06             	cmp    $0x6,%ebx
  105761:	7f 0b                	jg     10576e <vprintfmt+0x153>
  105763:	8b 34 9d 48 71 10 00 	mov    0x107148(,%ebx,4),%esi
  10576a:	85 f6                	test   %esi,%esi
  10576c:	75 23                	jne    105791 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  10576e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105772:	c7 44 24 08 75 71 10 	movl   $0x107175,0x8(%esp)
  105779:	00 
  10577a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10577d:	89 44 24 04          	mov    %eax,0x4(%esp)
  105781:	8b 45 08             	mov    0x8(%ebp),%eax
  105784:	89 04 24             	mov    %eax,(%esp)
  105787:	e8 61 fe ff ff       	call   1055ed <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10578c:	e9 68 02 00 00       	jmp    1059f9 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  105791:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105795:	c7 44 24 08 7e 71 10 	movl   $0x10717e,0x8(%esp)
  10579c:	00 
  10579d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a7:	89 04 24             	mov    %eax,(%esp)
  1057aa:	e8 3e fe ff ff       	call   1055ed <printfmt>
            }
            break;
  1057af:	e9 45 02 00 00       	jmp    1059f9 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  1057b4:	8b 45 14             	mov    0x14(%ebp),%eax
  1057b7:	8d 50 04             	lea    0x4(%eax),%edx
  1057ba:	89 55 14             	mov    %edx,0x14(%ebp)
  1057bd:	8b 30                	mov    (%eax),%esi
  1057bf:	85 f6                	test   %esi,%esi
  1057c1:	75 05                	jne    1057c8 <vprintfmt+0x1ad>
                p = "(null)";
  1057c3:	be 81 71 10 00       	mov    $0x107181,%esi
            }
            if (width > 0 && padc != '-') {
  1057c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057cc:	7e 3e                	jle    10580c <vprintfmt+0x1f1>
  1057ce:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1057d2:	74 38                	je     10580c <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1057d4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  1057d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1057da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1057de:	89 34 24             	mov    %esi,(%esp)
  1057e1:	e8 15 03 00 00       	call   105afb <strnlen>
  1057e6:	29 c3                	sub    %eax,%ebx
  1057e8:	89 d8                	mov    %ebx,%eax
  1057ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057ed:	eb 17                	jmp    105806 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  1057ef:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1057f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057fa:	89 04 24             	mov    %eax,(%esp)
  1057fd:	8b 45 08             	mov    0x8(%ebp),%eax
  105800:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  105802:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105806:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10580a:	7f e3                	jg     1057ef <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10580c:	eb 38                	jmp    105846 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  10580e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105812:	74 1f                	je     105833 <vprintfmt+0x218>
  105814:	83 fb 1f             	cmp    $0x1f,%ebx
  105817:	7e 05                	jle    10581e <vprintfmt+0x203>
  105819:	83 fb 7e             	cmp    $0x7e,%ebx
  10581c:	7e 15                	jle    105833 <vprintfmt+0x218>
                    putch('?', putdat);
  10581e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105821:	89 44 24 04          	mov    %eax,0x4(%esp)
  105825:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  10582c:	8b 45 08             	mov    0x8(%ebp),%eax
  10582f:	ff d0                	call   *%eax
  105831:	eb 0f                	jmp    105842 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  105833:	8b 45 0c             	mov    0xc(%ebp),%eax
  105836:	89 44 24 04          	mov    %eax,0x4(%esp)
  10583a:	89 1c 24             	mov    %ebx,(%esp)
  10583d:	8b 45 08             	mov    0x8(%ebp),%eax
  105840:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105842:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  105846:	89 f0                	mov    %esi,%eax
  105848:	8d 70 01             	lea    0x1(%eax),%esi
  10584b:	0f b6 00             	movzbl (%eax),%eax
  10584e:	0f be d8             	movsbl %al,%ebx
  105851:	85 db                	test   %ebx,%ebx
  105853:	74 10                	je     105865 <vprintfmt+0x24a>
  105855:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105859:	78 b3                	js     10580e <vprintfmt+0x1f3>
  10585b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  10585f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105863:	79 a9                	jns    10580e <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  105865:	eb 17                	jmp    10587e <vprintfmt+0x263>
                putch(' ', putdat);
  105867:	8b 45 0c             	mov    0xc(%ebp),%eax
  10586a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10586e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105875:	8b 45 08             	mov    0x8(%ebp),%eax
  105878:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10587a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  10587e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105882:	7f e3                	jg     105867 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  105884:	e9 70 01 00 00       	jmp    1059f9 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105889:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10588c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105890:	8d 45 14             	lea    0x14(%ebp),%eax
  105893:	89 04 24             	mov    %eax,(%esp)
  105896:	e8 0b fd ff ff       	call   1055a6 <getint>
  10589b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10589e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1058a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058a7:	85 d2                	test   %edx,%edx
  1058a9:	79 26                	jns    1058d1 <vprintfmt+0x2b6>
                putch('-', putdat);
  1058ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058b2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  1058b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1058bc:	ff d0                	call   *%eax
                num = -(long long)num;
  1058be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1058c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1058c4:	f7 d8                	neg    %eax
  1058c6:	83 d2 00             	adc    $0x0,%edx
  1058c9:	f7 da                	neg    %edx
  1058cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1058d1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058d8:	e9 a8 00 00 00       	jmp    105985 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1058dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1058e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058e4:	8d 45 14             	lea    0x14(%ebp),%eax
  1058e7:	89 04 24             	mov    %eax,(%esp)
  1058ea:	e8 68 fc ff ff       	call   105557 <getuint>
  1058ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1058f5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1058fc:	e9 84 00 00 00       	jmp    105985 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105901:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105904:	89 44 24 04          	mov    %eax,0x4(%esp)
  105908:	8d 45 14             	lea    0x14(%ebp),%eax
  10590b:	89 04 24             	mov    %eax,(%esp)
  10590e:	e8 44 fc ff ff       	call   105557 <getuint>
  105913:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105916:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105919:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105920:	eb 63                	jmp    105985 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  105922:	8b 45 0c             	mov    0xc(%ebp),%eax
  105925:	89 44 24 04          	mov    %eax,0x4(%esp)
  105929:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105930:	8b 45 08             	mov    0x8(%ebp),%eax
  105933:	ff d0                	call   *%eax
            putch('x', putdat);
  105935:	8b 45 0c             	mov    0xc(%ebp),%eax
  105938:	89 44 24 04          	mov    %eax,0x4(%esp)
  10593c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105943:	8b 45 08             	mov    0x8(%ebp),%eax
  105946:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105948:	8b 45 14             	mov    0x14(%ebp),%eax
  10594b:	8d 50 04             	lea    0x4(%eax),%edx
  10594e:	89 55 14             	mov    %edx,0x14(%ebp)
  105951:	8b 00                	mov    (%eax),%eax
  105953:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10595d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105964:	eb 1f                	jmp    105985 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105966:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105969:	89 44 24 04          	mov    %eax,0x4(%esp)
  10596d:	8d 45 14             	lea    0x14(%ebp),%eax
  105970:	89 04 24             	mov    %eax,(%esp)
  105973:	e8 df fb ff ff       	call   105557 <getuint>
  105978:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10597b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10597e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105985:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105989:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10598c:	89 54 24 18          	mov    %edx,0x18(%esp)
  105990:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105993:	89 54 24 14          	mov    %edx,0x14(%esp)
  105997:	89 44 24 10          	mov    %eax,0x10(%esp)
  10599b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10599e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  1059a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1059a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1059b3:	89 04 24             	mov    %eax,(%esp)
  1059b6:	e8 97 fa ff ff       	call   105452 <printnum>
            break;
  1059bb:	eb 3c                	jmp    1059f9 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1059bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059c4:	89 1c 24             	mov    %ebx,(%esp)
  1059c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1059ca:	ff d0                	call   *%eax
            break;
  1059cc:	eb 2b                	jmp    1059f9 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1059ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059d5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1059dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1059df:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1059e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1059e5:	eb 04                	jmp    1059eb <vprintfmt+0x3d0>
  1059e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  1059eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1059ee:	83 e8 01             	sub    $0x1,%eax
  1059f1:	0f b6 00             	movzbl (%eax),%eax
  1059f4:	3c 25                	cmp    $0x25,%al
  1059f6:	75 ef                	jne    1059e7 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  1059f8:	90                   	nop
        }
    }
  1059f9:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1059fa:	e9 3e fc ff ff       	jmp    10563d <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1059ff:	83 c4 40             	add    $0x40,%esp
  105a02:	5b                   	pop    %ebx
  105a03:	5e                   	pop    %esi
  105a04:	5d                   	pop    %ebp
  105a05:	c3                   	ret    

00105a06 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105a06:	55                   	push   %ebp
  105a07:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a0c:	8b 40 08             	mov    0x8(%eax),%eax
  105a0f:	8d 50 01             	lea    0x1(%eax),%edx
  105a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a15:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a1b:	8b 10                	mov    (%eax),%edx
  105a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a20:	8b 40 04             	mov    0x4(%eax),%eax
  105a23:	39 c2                	cmp    %eax,%edx
  105a25:	73 12                	jae    105a39 <sprintputch+0x33>
        *b->buf ++ = ch;
  105a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a2a:	8b 00                	mov    (%eax),%eax
  105a2c:	8d 48 01             	lea    0x1(%eax),%ecx
  105a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a32:	89 0a                	mov    %ecx,(%edx)
  105a34:	8b 55 08             	mov    0x8(%ebp),%edx
  105a37:	88 10                	mov    %dl,(%eax)
    }
}
  105a39:	5d                   	pop    %ebp
  105a3a:	c3                   	ret    

00105a3b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105a3b:	55                   	push   %ebp
  105a3c:	89 e5                	mov    %esp,%ebp
  105a3e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105a41:	8d 45 14             	lea    0x14(%ebp),%eax
  105a44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105a4e:	8b 45 10             	mov    0x10(%ebp),%eax
  105a51:	89 44 24 08          	mov    %eax,0x8(%esp)
  105a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  105a5f:	89 04 24             	mov    %eax,(%esp)
  105a62:	e8 08 00 00 00       	call   105a6f <vsnprintf>
  105a67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105a6d:	c9                   	leave  
  105a6e:	c3                   	ret    

00105a6f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105a6f:	55                   	push   %ebp
  105a70:	89 e5                	mov    %esp,%ebp
  105a72:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105a75:	8b 45 08             	mov    0x8(%ebp),%eax
  105a78:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a7e:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a81:	8b 45 08             	mov    0x8(%ebp),%eax
  105a84:	01 d0                	add    %edx,%eax
  105a86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105a90:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105a94:	74 0a                	je     105aa0 <vsnprintf+0x31>
  105a96:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a9c:	39 c2                	cmp    %eax,%edx
  105a9e:	76 07                	jbe    105aa7 <vsnprintf+0x38>
        return -E_INVAL;
  105aa0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105aa5:	eb 2a                	jmp    105ad1 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  105aaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105aae:	8b 45 10             	mov    0x10(%ebp),%eax
  105ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
  105ab5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105abc:	c7 04 24 06 5a 10 00 	movl   $0x105a06,(%esp)
  105ac3:	e8 53 fb ff ff       	call   10561b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105acb:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105ad1:	c9                   	leave  
  105ad2:	c3                   	ret    

00105ad3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105ad3:	55                   	push   %ebp
  105ad4:	89 e5                	mov    %esp,%ebp
  105ad6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105ad9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105ae0:	eb 04                	jmp    105ae6 <strlen+0x13>
        cnt ++;
  105ae2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae9:	8d 50 01             	lea    0x1(%eax),%edx
  105aec:	89 55 08             	mov    %edx,0x8(%ebp)
  105aef:	0f b6 00             	movzbl (%eax),%eax
  105af2:	84 c0                	test   %al,%al
  105af4:	75 ec                	jne    105ae2 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  105af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105af9:	c9                   	leave  
  105afa:	c3                   	ret    

00105afb <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105afb:	55                   	push   %ebp
  105afc:	89 e5                	mov    %esp,%ebp
  105afe:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105b01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105b08:	eb 04                	jmp    105b0e <strnlen+0x13>
        cnt ++;
  105b0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b11:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105b14:	73 10                	jae    105b26 <strnlen+0x2b>
  105b16:	8b 45 08             	mov    0x8(%ebp),%eax
  105b19:	8d 50 01             	lea    0x1(%eax),%edx
  105b1c:	89 55 08             	mov    %edx,0x8(%ebp)
  105b1f:	0f b6 00             	movzbl (%eax),%eax
  105b22:	84 c0                	test   %al,%al
  105b24:	75 e4                	jne    105b0a <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  105b26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105b29:	c9                   	leave  
  105b2a:	c3                   	ret    

00105b2b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105b2b:	55                   	push   %ebp
  105b2c:	89 e5                	mov    %esp,%ebp
  105b2e:	57                   	push   %edi
  105b2f:	56                   	push   %esi
  105b30:	83 ec 20             	sub    $0x20,%esp
  105b33:	8b 45 08             	mov    0x8(%ebp),%eax
  105b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105b45:	89 d1                	mov    %edx,%ecx
  105b47:	89 c2                	mov    %eax,%edx
  105b49:	89 ce                	mov    %ecx,%esi
  105b4b:	89 d7                	mov    %edx,%edi
  105b4d:	ac                   	lods   %ds:(%esi),%al
  105b4e:	aa                   	stos   %al,%es:(%edi)
  105b4f:	84 c0                	test   %al,%al
  105b51:	75 fa                	jne    105b4d <strcpy+0x22>
  105b53:	89 fa                	mov    %edi,%edx
  105b55:	89 f1                	mov    %esi,%ecx
  105b57:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105b5a:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105b5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105b63:	83 c4 20             	add    $0x20,%esp
  105b66:	5e                   	pop    %esi
  105b67:	5f                   	pop    %edi
  105b68:	5d                   	pop    %ebp
  105b69:	c3                   	ret    

00105b6a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105b6a:	55                   	push   %ebp
  105b6b:	89 e5                	mov    %esp,%ebp
  105b6d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105b70:	8b 45 08             	mov    0x8(%ebp),%eax
  105b73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105b76:	eb 21                	jmp    105b99 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  105b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b7b:	0f b6 10             	movzbl (%eax),%edx
  105b7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b81:	88 10                	mov    %dl,(%eax)
  105b83:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b86:	0f b6 00             	movzbl (%eax),%eax
  105b89:	84 c0                	test   %al,%al
  105b8b:	74 04                	je     105b91 <strncpy+0x27>
            src ++;
  105b8d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  105b91:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105b95:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105b99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b9d:	75 d9                	jne    105b78 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105b9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ba2:	c9                   	leave  
  105ba3:	c3                   	ret    

00105ba4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105ba4:	55                   	push   %ebp
  105ba5:	89 e5                	mov    %esp,%ebp
  105ba7:	57                   	push   %edi
  105ba8:	56                   	push   %esi
  105ba9:	83 ec 20             	sub    $0x20,%esp
  105bac:	8b 45 08             	mov    0x8(%ebp),%eax
  105baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bbe:	89 d1                	mov    %edx,%ecx
  105bc0:	89 c2                	mov    %eax,%edx
  105bc2:	89 ce                	mov    %ecx,%esi
  105bc4:	89 d7                	mov    %edx,%edi
  105bc6:	ac                   	lods   %ds:(%esi),%al
  105bc7:	ae                   	scas   %es:(%edi),%al
  105bc8:	75 08                	jne    105bd2 <strcmp+0x2e>
  105bca:	84 c0                	test   %al,%al
  105bcc:	75 f8                	jne    105bc6 <strcmp+0x22>
  105bce:	31 c0                	xor    %eax,%eax
  105bd0:	eb 04                	jmp    105bd6 <strcmp+0x32>
  105bd2:	19 c0                	sbb    %eax,%eax
  105bd4:	0c 01                	or     $0x1,%al
  105bd6:	89 fa                	mov    %edi,%edx
  105bd8:	89 f1                	mov    %esi,%ecx
  105bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105bdd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105be0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105be6:	83 c4 20             	add    $0x20,%esp
  105be9:	5e                   	pop    %esi
  105bea:	5f                   	pop    %edi
  105beb:	5d                   	pop    %ebp
  105bec:	c3                   	ret    

00105bed <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105bed:	55                   	push   %ebp
  105bee:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bf0:	eb 0c                	jmp    105bfe <strncmp+0x11>
        n --, s1 ++, s2 ++;
  105bf2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  105bf6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105bfa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105bfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c02:	74 1a                	je     105c1e <strncmp+0x31>
  105c04:	8b 45 08             	mov    0x8(%ebp),%eax
  105c07:	0f b6 00             	movzbl (%eax),%eax
  105c0a:	84 c0                	test   %al,%al
  105c0c:	74 10                	je     105c1e <strncmp+0x31>
  105c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  105c11:	0f b6 10             	movzbl (%eax),%edx
  105c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c17:	0f b6 00             	movzbl (%eax),%eax
  105c1a:	38 c2                	cmp    %al,%dl
  105c1c:	74 d4                	je     105bf2 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105c1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105c22:	74 18                	je     105c3c <strncmp+0x4f>
  105c24:	8b 45 08             	mov    0x8(%ebp),%eax
  105c27:	0f b6 00             	movzbl (%eax),%eax
  105c2a:	0f b6 d0             	movzbl %al,%edx
  105c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c30:	0f b6 00             	movzbl (%eax),%eax
  105c33:	0f b6 c0             	movzbl %al,%eax
  105c36:	29 c2                	sub    %eax,%edx
  105c38:	89 d0                	mov    %edx,%eax
  105c3a:	eb 05                	jmp    105c41 <strncmp+0x54>
  105c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c41:	5d                   	pop    %ebp
  105c42:	c3                   	ret    

00105c43 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105c43:	55                   	push   %ebp
  105c44:	89 e5                	mov    %esp,%ebp
  105c46:	83 ec 04             	sub    $0x4,%esp
  105c49:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c4c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c4f:	eb 14                	jmp    105c65 <strchr+0x22>
        if (*s == c) {
  105c51:	8b 45 08             	mov    0x8(%ebp),%eax
  105c54:	0f b6 00             	movzbl (%eax),%eax
  105c57:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105c5a:	75 05                	jne    105c61 <strchr+0x1e>
            return (char *)s;
  105c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  105c5f:	eb 13                	jmp    105c74 <strchr+0x31>
        }
        s ++;
  105c61:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105c65:	8b 45 08             	mov    0x8(%ebp),%eax
  105c68:	0f b6 00             	movzbl (%eax),%eax
  105c6b:	84 c0                	test   %al,%al
  105c6d:	75 e2                	jne    105c51 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105c74:	c9                   	leave  
  105c75:	c3                   	ret    

00105c76 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105c76:	55                   	push   %ebp
  105c77:	89 e5                	mov    %esp,%ebp
  105c79:	83 ec 04             	sub    $0x4,%esp
  105c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105c82:	eb 11                	jmp    105c95 <strfind+0x1f>
        if (*s == c) {
  105c84:	8b 45 08             	mov    0x8(%ebp),%eax
  105c87:	0f b6 00             	movzbl (%eax),%eax
  105c8a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105c8d:	75 02                	jne    105c91 <strfind+0x1b>
            break;
  105c8f:	eb 0e                	jmp    105c9f <strfind+0x29>
        }
        s ++;
  105c91:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105c95:	8b 45 08             	mov    0x8(%ebp),%eax
  105c98:	0f b6 00             	movzbl (%eax),%eax
  105c9b:	84 c0                	test   %al,%al
  105c9d:	75 e5                	jne    105c84 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  105c9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ca2:	c9                   	leave  
  105ca3:	c3                   	ret    

00105ca4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105ca4:	55                   	push   %ebp
  105ca5:	89 e5                	mov    %esp,%ebp
  105ca7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105caa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105cb1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105cb8:	eb 04                	jmp    105cbe <strtol+0x1a>
        s ++;
  105cba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc1:	0f b6 00             	movzbl (%eax),%eax
  105cc4:	3c 20                	cmp    $0x20,%al
  105cc6:	74 f2                	je     105cba <strtol+0x16>
  105cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccb:	0f b6 00             	movzbl (%eax),%eax
  105cce:	3c 09                	cmp    $0x9,%al
  105cd0:	74 e8                	je     105cba <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  105cd5:	0f b6 00             	movzbl (%eax),%eax
  105cd8:	3c 2b                	cmp    $0x2b,%al
  105cda:	75 06                	jne    105ce2 <strtol+0x3e>
        s ++;
  105cdc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105ce0:	eb 15                	jmp    105cf7 <strtol+0x53>
    }
    else if (*s == '-') {
  105ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce5:	0f b6 00             	movzbl (%eax),%eax
  105ce8:	3c 2d                	cmp    $0x2d,%al
  105cea:	75 0b                	jne    105cf7 <strtol+0x53>
        s ++, neg = 1;
  105cec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105cf0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105cf7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105cfb:	74 06                	je     105d03 <strtol+0x5f>
  105cfd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105d01:	75 24                	jne    105d27 <strtol+0x83>
  105d03:	8b 45 08             	mov    0x8(%ebp),%eax
  105d06:	0f b6 00             	movzbl (%eax),%eax
  105d09:	3c 30                	cmp    $0x30,%al
  105d0b:	75 1a                	jne    105d27 <strtol+0x83>
  105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d10:	83 c0 01             	add    $0x1,%eax
  105d13:	0f b6 00             	movzbl (%eax),%eax
  105d16:	3c 78                	cmp    $0x78,%al
  105d18:	75 0d                	jne    105d27 <strtol+0x83>
        s += 2, base = 16;
  105d1a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105d1e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105d25:	eb 2a                	jmp    105d51 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  105d27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d2b:	75 17                	jne    105d44 <strtol+0xa0>
  105d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d30:	0f b6 00             	movzbl (%eax),%eax
  105d33:	3c 30                	cmp    $0x30,%al
  105d35:	75 0d                	jne    105d44 <strtol+0xa0>
        s ++, base = 8;
  105d37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105d3b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105d42:	eb 0d                	jmp    105d51 <strtol+0xad>
    }
    else if (base == 0) {
  105d44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105d48:	75 07                	jne    105d51 <strtol+0xad>
        base = 10;
  105d4a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105d51:	8b 45 08             	mov    0x8(%ebp),%eax
  105d54:	0f b6 00             	movzbl (%eax),%eax
  105d57:	3c 2f                	cmp    $0x2f,%al
  105d59:	7e 1b                	jle    105d76 <strtol+0xd2>
  105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5e:	0f b6 00             	movzbl (%eax),%eax
  105d61:	3c 39                	cmp    $0x39,%al
  105d63:	7f 11                	jg     105d76 <strtol+0xd2>
            dig = *s - '0';
  105d65:	8b 45 08             	mov    0x8(%ebp),%eax
  105d68:	0f b6 00             	movzbl (%eax),%eax
  105d6b:	0f be c0             	movsbl %al,%eax
  105d6e:	83 e8 30             	sub    $0x30,%eax
  105d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d74:	eb 48                	jmp    105dbe <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105d76:	8b 45 08             	mov    0x8(%ebp),%eax
  105d79:	0f b6 00             	movzbl (%eax),%eax
  105d7c:	3c 60                	cmp    $0x60,%al
  105d7e:	7e 1b                	jle    105d9b <strtol+0xf7>
  105d80:	8b 45 08             	mov    0x8(%ebp),%eax
  105d83:	0f b6 00             	movzbl (%eax),%eax
  105d86:	3c 7a                	cmp    $0x7a,%al
  105d88:	7f 11                	jg     105d9b <strtol+0xf7>
            dig = *s - 'a' + 10;
  105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8d:	0f b6 00             	movzbl (%eax),%eax
  105d90:	0f be c0             	movsbl %al,%eax
  105d93:	83 e8 57             	sub    $0x57,%eax
  105d96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d99:	eb 23                	jmp    105dbe <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  105d9e:	0f b6 00             	movzbl (%eax),%eax
  105da1:	3c 40                	cmp    $0x40,%al
  105da3:	7e 3d                	jle    105de2 <strtol+0x13e>
  105da5:	8b 45 08             	mov    0x8(%ebp),%eax
  105da8:	0f b6 00             	movzbl (%eax),%eax
  105dab:	3c 5a                	cmp    $0x5a,%al
  105dad:	7f 33                	jg     105de2 <strtol+0x13e>
            dig = *s - 'A' + 10;
  105daf:	8b 45 08             	mov    0x8(%ebp),%eax
  105db2:	0f b6 00             	movzbl (%eax),%eax
  105db5:	0f be c0             	movsbl %al,%eax
  105db8:	83 e8 37             	sub    $0x37,%eax
  105dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dc1:	3b 45 10             	cmp    0x10(%ebp),%eax
  105dc4:	7c 02                	jl     105dc8 <strtol+0x124>
            break;
  105dc6:	eb 1a                	jmp    105de2 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  105dc8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  105dcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105dcf:	0f af 45 10          	imul   0x10(%ebp),%eax
  105dd3:	89 c2                	mov    %eax,%edx
  105dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dd8:	01 d0                	add    %edx,%eax
  105dda:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105ddd:	e9 6f ff ff ff       	jmp    105d51 <strtol+0xad>

    if (endptr) {
  105de2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105de6:	74 08                	je     105df0 <strtol+0x14c>
        *endptr = (char *) s;
  105de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105deb:	8b 55 08             	mov    0x8(%ebp),%edx
  105dee:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105df0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105df4:	74 07                	je     105dfd <strtol+0x159>
  105df6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105df9:	f7 d8                	neg    %eax
  105dfb:	eb 03                	jmp    105e00 <strtol+0x15c>
  105dfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105e00:	c9                   	leave  
  105e01:	c3                   	ret    

00105e02 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105e02:	55                   	push   %ebp
  105e03:	89 e5                	mov    %esp,%ebp
  105e05:	57                   	push   %edi
  105e06:	83 ec 24             	sub    $0x24,%esp
  105e09:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e0c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105e0f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105e13:	8b 55 08             	mov    0x8(%ebp),%edx
  105e16:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105e19:	88 45 f7             	mov    %al,-0x9(%ebp)
  105e1c:	8b 45 10             	mov    0x10(%ebp),%eax
  105e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105e22:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105e25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105e29:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105e2c:	89 d7                	mov    %edx,%edi
  105e2e:	f3 aa                	rep stos %al,%es:(%edi)
  105e30:	89 fa                	mov    %edi,%edx
  105e32:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105e35:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105e3b:	83 c4 24             	add    $0x24,%esp
  105e3e:	5f                   	pop    %edi
  105e3f:	5d                   	pop    %ebp
  105e40:	c3                   	ret    

00105e41 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105e41:	55                   	push   %ebp
  105e42:	89 e5                	mov    %esp,%ebp
  105e44:	57                   	push   %edi
  105e45:	56                   	push   %esi
  105e46:	53                   	push   %ebx
  105e47:	83 ec 30             	sub    $0x30,%esp
  105e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  105e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e53:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e56:	8b 45 10             	mov    0x10(%ebp),%eax
  105e59:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e5f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105e62:	73 42                	jae    105ea6 <memmove+0x65>
  105e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105e6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105e6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e70:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e73:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105e76:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e79:	c1 e8 02             	shr    $0x2,%eax
  105e7c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105e7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e84:	89 d7                	mov    %edx,%edi
  105e86:	89 c6                	mov    %eax,%esi
  105e88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105e8a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105e8d:	83 e1 03             	and    $0x3,%ecx
  105e90:	74 02                	je     105e94 <memmove+0x53>
  105e92:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105e94:	89 f0                	mov    %esi,%eax
  105e96:	89 fa                	mov    %edi,%edx
  105e98:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105e9b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105e9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ea4:	eb 36                	jmp    105edc <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105ea6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ea9:	8d 50 ff             	lea    -0x1(%eax),%edx
  105eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105eaf:	01 c2                	add    %eax,%edx
  105eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105eb4:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105eba:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ec0:	89 c1                	mov    %eax,%ecx
  105ec2:	89 d8                	mov    %ebx,%eax
  105ec4:	89 d6                	mov    %edx,%esi
  105ec6:	89 c7                	mov    %eax,%edi
  105ec8:	fd                   	std    
  105ec9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105ecb:	fc                   	cld    
  105ecc:	89 f8                	mov    %edi,%eax
  105ece:	89 f2                	mov    %esi,%edx
  105ed0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105ed3:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105ed6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105edc:	83 c4 30             	add    $0x30,%esp
  105edf:	5b                   	pop    %ebx
  105ee0:	5e                   	pop    %esi
  105ee1:	5f                   	pop    %edi
  105ee2:	5d                   	pop    %ebp
  105ee3:	c3                   	ret    

00105ee4 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105ee4:	55                   	push   %ebp
  105ee5:	89 e5                	mov    %esp,%ebp
  105ee7:	57                   	push   %edi
  105ee8:	56                   	push   %esi
  105ee9:	83 ec 20             	sub    $0x20,%esp
  105eec:	8b 45 08             	mov    0x8(%ebp),%eax
  105eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ef8:	8b 45 10             	mov    0x10(%ebp),%eax
  105efb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105efe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105f01:	c1 e8 02             	shr    $0x2,%eax
  105f04:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105f06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105f0c:	89 d7                	mov    %edx,%edi
  105f0e:	89 c6                	mov    %eax,%esi
  105f10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105f12:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105f15:	83 e1 03             	and    $0x3,%ecx
  105f18:	74 02                	je     105f1c <memcpy+0x38>
  105f1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105f1c:	89 f0                	mov    %esi,%eax
  105f1e:	89 fa                	mov    %edi,%edx
  105f20:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105f23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105f26:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105f2c:	83 c4 20             	add    $0x20,%esp
  105f2f:	5e                   	pop    %esi
  105f30:	5f                   	pop    %edi
  105f31:	5d                   	pop    %ebp
  105f32:	c3                   	ret    

00105f33 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105f33:	55                   	push   %ebp
  105f34:	89 e5                	mov    %esp,%ebp
  105f36:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105f39:	8b 45 08             	mov    0x8(%ebp),%eax
  105f3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f42:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105f45:	eb 30                	jmp    105f77 <memcmp+0x44>
        if (*s1 != *s2) {
  105f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f4a:	0f b6 10             	movzbl (%eax),%edx
  105f4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f50:	0f b6 00             	movzbl (%eax),%eax
  105f53:	38 c2                	cmp    %al,%dl
  105f55:	74 18                	je     105f6f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105f57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105f5a:	0f b6 00             	movzbl (%eax),%eax
  105f5d:	0f b6 d0             	movzbl %al,%edx
  105f60:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105f63:	0f b6 00             	movzbl (%eax),%eax
  105f66:	0f b6 c0             	movzbl %al,%eax
  105f69:	29 c2                	sub    %eax,%edx
  105f6b:	89 d0                	mov    %edx,%eax
  105f6d:	eb 1a                	jmp    105f89 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  105f6f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  105f73:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105f77:	8b 45 10             	mov    0x10(%ebp),%eax
  105f7a:	8d 50 ff             	lea    -0x1(%eax),%edx
  105f7d:	89 55 10             	mov    %edx,0x10(%ebp)
  105f80:	85 c0                	test   %eax,%eax
  105f82:	75 c3                	jne    105f47 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105f89:	c9                   	leave  
  105f8a:	c3                   	ret    
