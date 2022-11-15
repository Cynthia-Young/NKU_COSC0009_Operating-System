
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
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
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 a0 5d 00 00       	call   c0105e02 <memset>

    cons_init();                // init the console
c0100062:	e8 8d 15 00 00       	call   c01015f4 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 a0 5f 10 c0 	movl   $0xc0105fa0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 bc 5f 10 c0 	movl   $0xc0105fbc,(%esp)
c010007c:	e8 d2 02 00 00       	call   c0100353 <cprintf>

    print_kerninfo();
c0100081:	e8 01 08 00 00       	call   c0100887 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 dd 42 00 00       	call   c010436d <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 c8 16 00 00       	call   c010175d <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 40 18 00 00       	call   c01018da <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 0b 0d 00 00       	call   c0100daa <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 27 16 00 00       	call   c01016cb <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 03 0c 00 00       	call   c0100ccb <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 c1 5f 10 c0 	movl   $0xc0105fc1,(%esp)
c0100168:	e8 e6 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 cf 5f 10 c0 	movl   $0xc0105fcf,(%esp)
c0100188:	e8 c6 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 dd 5f 10 c0 	movl   $0xc0105fdd,(%esp)
c01001a8:	e8 a6 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 eb 5f 10 c0 	movl   $0xc0105feb,(%esp)
c01001c8:	e8 86 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 f9 5f 10 c0 	movl   $0xc0105ff9,(%esp)
c01001e8:	e8 66 01 00 00       	call   c0100353 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
asm volatile(
c01001ff:	83 ec 08             	sub    $0x8,%esp
c0100202:	cd 78                	int    $0x78
c0100204:	89 ec                	mov    %ebp,%esp
    "int %0 \n"                    //中断
    "movl %%ebp,%%esp"             //恢复栈指针
    :
    :"i"(T_SWITCH_TOU)             //中断号
    );
}
c0100206:	5d                   	pop    %ebp
c0100207:	c3                   	ret    

c0100208 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100208:	55                   	push   %ebp
c0100209:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
asm volatile (
c010020b:	cd 79                	int    $0x79
c010020d:	89 ec                	mov    %ebp,%esp
     "int %0 \n"
     "movl %%ebp, %%esp \n"
     :
     : "i"(T_SWITCH_TOK)
     );
}
c010020f:	5d                   	pop    %ebp
c0100210:	c3                   	ret    

c0100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
c0100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100217:	e8 1a ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021c:	c7 04 24 08 60 10 c0 	movl   $0xc0106008,(%esp)
c0100223:	e8 2b 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_user();
c0100228:	e8 cf ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c010022d:	e8 04 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100232:	c7 04 24 28 60 10 c0 	movl   $0xc0106028,(%esp)
c0100239:	e8 15 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_kernel();
c010023e:	e8 c5 ff ff ff       	call   c0100208 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100243:	e8 ee fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100250:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100254:	74 13                	je     c0100269 <readline+0x1f>
        cprintf("%s", prompt);
c0100256:	8b 45 08             	mov    0x8(%ebp),%eax
c0100259:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025d:	c7 04 24 47 60 10 c0 	movl   $0xc0106047,(%esp)
c0100264:	e8 ea 00 00 00       	call   c0100353 <cprintf>
    }
    int i = 0, c;
c0100269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100270:	e8 66 01 00 00       	call   c01003db <getchar>
c0100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010027c:	79 07                	jns    c0100285 <readline+0x3b>
            return NULL;
c010027e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100283:	eb 79                	jmp    c01002fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100285:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100289:	7e 28                	jle    c01002b3 <readline+0x69>
c010028b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100292:	7f 1f                	jg     c01002b3 <readline+0x69>
            cputchar(c);
c0100294:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100297:	89 04 24             	mov    %eax,(%esp)
c010029a:	e8 da 00 00 00       	call   c0100379 <cputchar>
            buf[i ++] = c;
c010029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a2:	8d 50 01             	lea    0x1(%eax),%edx
c01002a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ab:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002b1:	eb 46                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b7:	75 17                	jne    c01002d0 <readline+0x86>
c01002b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002bd:	7e 11                	jle    c01002d0 <readline+0x86>
            cputchar(c);
c01002bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c2:	89 04 24             	mov    %eax,(%esp)
c01002c5:	e8 af 00 00 00       	call   c0100379 <cputchar>
            i --;
c01002ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002ce:	eb 29                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d4:	74 06                	je     c01002dc <readline+0x92>
c01002d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002da:	75 1d                	jne    c01002f9 <readline+0xaf>
            cputchar(c);
c01002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002df:	89 04 24             	mov    %eax,(%esp)
c01002e2:	e8 92 00 00 00       	call   c0100379 <cputchar>
            buf[i] = '\0';
c01002e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ea:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f2:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002f7:	eb 05                	jmp    c01002fe <readline+0xb4>
        }
    }
c01002f9:	e9 72 ff ff ff       	jmp    c0100270 <readline+0x26>
}
c01002fe:	c9                   	leave  
c01002ff:	c3                   	ret    

c0100300 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100300:	55                   	push   %ebp
c0100301:	89 e5                	mov    %esp,%ebp
c0100303:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100306:	8b 45 08             	mov    0x8(%ebp),%eax
c0100309:	89 04 24             	mov    %eax,(%esp)
c010030c:	e8 0f 13 00 00       	call   c0101620 <cons_putc>
    (*cnt) ++;
c0100311:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100314:	8b 00                	mov    (%eax),%eax
c0100316:	8d 50 01             	lea    0x1(%eax),%edx
c0100319:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031c:	89 10                	mov    %edx,(%eax)
}
c010031e:	c9                   	leave  
c010031f:	c3                   	ret    

c0100320 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100320:	55                   	push   %ebp
c0100321:	89 e5                	mov    %esp,%ebp
c0100323:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100330:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100334:	8b 45 08             	mov    0x8(%ebp),%eax
c0100337:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100342:	c7 04 24 00 03 10 c0 	movl   $0xc0100300,(%esp)
c0100349:	e8 cd 52 00 00       	call   c010561b <vprintfmt>
    return cnt;
c010034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100351:	c9                   	leave  
c0100352:	c3                   	ret    

c0100353 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100353:	55                   	push   %ebp
c0100354:	89 e5                	mov    %esp,%ebp
c0100356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100359:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010035f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100362:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100366:	8b 45 08             	mov    0x8(%ebp),%eax
c0100369:	89 04 24             	mov    %eax,(%esp)
c010036c:	e8 af ff ff ff       	call   c0100320 <vcprintf>
c0100371:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100377:	c9                   	leave  
c0100378:	c3                   	ret    

c0100379 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100379:	55                   	push   %ebp
c010037a:	89 e5                	mov    %esp,%ebp
c010037c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010037f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100382:	89 04 24             	mov    %eax,(%esp)
c0100385:	e8 96 12 00 00       	call   c0101620 <cons_putc>
}
c010038a:	c9                   	leave  
c010038b:	c3                   	ret    

c010038c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010038c:	55                   	push   %ebp
c010038d:	89 e5                	mov    %esp,%ebp
c010038f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100399:	eb 13                	jmp    c01003ae <cputs+0x22>
        cputch(c, &cnt);
c010039b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010039f:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003a6:	89 04 24             	mov    %eax,(%esp)
c01003a9:	e8 52 ff ff ff       	call   c0100300 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b1:	8d 50 01             	lea    0x1(%eax),%edx
c01003b4:	89 55 08             	mov    %edx,0x8(%ebp)
c01003b7:	0f b6 00             	movzbl (%eax),%eax
c01003ba:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003bd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c1:	75 d8                	jne    c010039b <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d1:	e8 2a ff ff ff       	call   c0100300 <cputch>
    return cnt;
c01003d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003d9:	c9                   	leave  
c01003da:	c3                   	ret    

c01003db <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003db:	55                   	push   %ebp
c01003dc:	89 e5                	mov    %esp,%ebp
c01003de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e1:	e8 76 12 00 00       	call   c010165c <cons_getc>
c01003e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003ed:	74 f2                	je     c01003e1 <getchar+0x6>
        /* do nothing */;
    return c;
c01003ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f2:	c9                   	leave  
c01003f3:	c3                   	ret    

c01003f4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003fd:	8b 00                	mov    (%eax),%eax
c01003ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100402:	8b 45 10             	mov    0x10(%ebp),%eax
c0100405:	8b 00                	mov    (%eax),%eax
c0100407:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100411:	e9 d2 00 00 00       	jmp    c01004e8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0100416:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100419:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010041c:	01 d0                	add    %edx,%eax
c010041e:	89 c2                	mov    %eax,%edx
c0100420:	c1 ea 1f             	shr    $0x1f,%edx
c0100423:	01 d0                	add    %edx,%eax
c0100425:	d1 f8                	sar    %eax
c0100427:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010042d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100430:	eb 04                	jmp    c0100436 <stab_binsearch+0x42>
            m --;
c0100432:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100436:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100439:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010043c:	7c 1f                	jl     c010045d <stab_binsearch+0x69>
c010043e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100441:	89 d0                	mov    %edx,%eax
c0100443:	01 c0                	add    %eax,%eax
c0100445:	01 d0                	add    %edx,%eax
c0100447:	c1 e0 02             	shl    $0x2,%eax
c010044a:	89 c2                	mov    %eax,%edx
c010044c:	8b 45 08             	mov    0x8(%ebp),%eax
c010044f:	01 d0                	add    %edx,%eax
c0100451:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100455:	0f b6 c0             	movzbl %al,%eax
c0100458:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045b:	75 d5                	jne    c0100432 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010045d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100460:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100463:	7d 0b                	jge    c0100470 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100468:	83 c0 01             	add    $0x1,%eax
c010046b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010046e:	eb 78                	jmp    c01004e8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100470:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047a:	89 d0                	mov    %edx,%eax
c010047c:	01 c0                	add    %eax,%eax
c010047e:	01 d0                	add    %edx,%eax
c0100480:	c1 e0 02             	shl    $0x2,%eax
c0100483:	89 c2                	mov    %eax,%edx
c0100485:	8b 45 08             	mov    0x8(%ebp),%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	8b 40 08             	mov    0x8(%eax),%eax
c010048d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100490:	73 13                	jae    c01004a5 <stab_binsearch+0xb1>
            *region_left = m;
c0100492:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100495:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100498:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010049d:	83 c0 01             	add    $0x1,%eax
c01004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a3:	eb 43                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a8:	89 d0                	mov    %edx,%eax
c01004aa:	01 c0                	add    %eax,%eax
c01004ac:	01 d0                	add    %edx,%eax
c01004ae:	c1 e0 02             	shl    $0x2,%eax
c01004b1:	89 c2                	mov    %eax,%edx
c01004b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01004b6:	01 d0                	add    %edx,%eax
c01004b8:	8b 40 08             	mov    0x8(%eax),%eax
c01004bb:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004be:	76 16                	jbe    c01004d6 <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ce:	83 e8 01             	sub    $0x1,%eax
c01004d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d4:	eb 12                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004dc:	89 10                	mov    %edx,(%eax)
            l = m;
c01004de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004ee:	0f 8e 22 ff ff ff    	jle    c0100416 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004f8:	75 0f                	jne    c0100509 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fd:	8b 00                	mov    (%eax),%eax
c01004ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100502:	8b 45 10             	mov    0x10(%ebp),%eax
c0100505:	89 10                	mov    %edx,(%eax)
c0100507:	eb 3f                	jmp    c0100548 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0100509:	8b 45 10             	mov    0x10(%ebp),%eax
c010050c:	8b 00                	mov    (%eax),%eax
c010050e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100511:	eb 04                	jmp    c0100517 <stab_binsearch+0x123>
c0100513:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100517:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051a:	8b 00                	mov    (%eax),%eax
c010051c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051f:	7d 1f                	jge    c0100540 <stab_binsearch+0x14c>
c0100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100524:	89 d0                	mov    %edx,%eax
c0100526:	01 c0                	add    %eax,%eax
c0100528:	01 d0                	add    %edx,%eax
c010052a:	c1 e0 02             	shl    $0x2,%eax
c010052d:	89 c2                	mov    %eax,%edx
c010052f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100532:	01 d0                	add    %edx,%eax
c0100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100538:	0f b6 c0             	movzbl %al,%eax
c010053b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010053e:	75 d3                	jne    c0100513 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100546:	89 10                	mov    %edx,(%eax)
    }
}
c0100548:	c9                   	leave  
c0100549:	c3                   	ret    

c010054a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054a:	55                   	push   %ebp
c010054b:	89 e5                	mov    %esp,%ebp
c010054d:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100553:	c7 00 4c 60 10 c0    	movl   $0xc010604c,(%eax)
    info->eip_line = 0;
c0100559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	c7 40 08 4c 60 10 c0 	movl   $0xc010604c,0x8(%eax)
    info->eip_fn_namelen = 9;
c010056d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100570:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100577:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057a:	8b 55 08             	mov    0x8(%ebp),%edx
c010057d:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100583:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010058a:	c7 45 f4 e0 72 10 c0 	movl   $0xc01072e0,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100591:	c7 45 f0 e8 1e 11 c0 	movl   $0xc0111ee8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100598:	c7 45 ec e9 1e 11 c0 	movl   $0xc0111ee9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010059f:	c7 45 e8 11 49 11 c0 	movl   $0xc0114911,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005ac:	76 0d                	jbe    c01005bb <debuginfo_eip+0x71>
c01005ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b1:	83 e8 01             	sub    $0x1,%eax
c01005b4:	0f b6 00             	movzbl (%eax),%eax
c01005b7:	84 c0                	test   %al,%al
c01005b9:	74 0a                	je     c01005c5 <debuginfo_eip+0x7b>
        return -1;
c01005bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c0:	e9 c0 02 00 00       	jmp    c0100885 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d2:	29 c2                	sub    %eax,%edx
c01005d4:	89 d0                	mov    %edx,%eax
c01005d6:	c1 f8 02             	sar    $0x2,%eax
c01005d9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005df:	83 e8 01             	sub    $0x1,%eax
c01005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e8:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005ec:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f3:	00 
c01005f4:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100602:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100605:	89 04 24             	mov    %eax,(%esp)
c0100608:	e8 e7 fd ff ff       	call   c01003f4 <stab_binsearch>
    if (lfile == 0)
c010060d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100610:	85 c0                	test   %eax,%eax
c0100612:	75 0a                	jne    c010061e <debuginfo_eip+0xd4>
        return -1;
c0100614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100619:	e9 67 02 00 00       	jmp    c0100885 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100621:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100624:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100627:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010062a:	8b 45 08             	mov    0x8(%ebp),%eax
c010062d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100631:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100638:	00 
c0100639:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100640:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100643:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100647:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064a:	89 04 24             	mov    %eax,(%esp)
c010064d:	e8 a2 fd ff ff       	call   c01003f4 <stab_binsearch>

    if (lfun <= rfun) {
c0100652:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100655:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100658:	39 c2                	cmp    %eax,%edx
c010065a:	7f 7c                	jg     c01006d8 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	89 d0                	mov    %edx,%eax
c0100663:	01 c0                	add    %eax,%eax
c0100665:	01 d0                	add    %edx,%eax
c0100667:	c1 e0 02             	shl    $0x2,%eax
c010066a:	89 c2                	mov    %eax,%edx
c010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066f:	01 d0                	add    %edx,%eax
c0100671:	8b 10                	mov    (%eax),%edx
c0100673:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100676:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100679:	29 c1                	sub    %eax,%ecx
c010067b:	89 c8                	mov    %ecx,%eax
c010067d:	39 c2                	cmp    %eax,%edx
c010067f:	73 22                	jae    c01006a3 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100681:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	89 d0                	mov    %edx,%eax
c0100688:	01 c0                	add    %eax,%eax
c010068a:	01 d0                	add    %edx,%eax
c010068c:	c1 e0 02             	shl    $0x2,%eax
c010068f:	89 c2                	mov    %eax,%edx
c0100691:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100694:	01 d0                	add    %edx,%eax
c0100696:	8b 10                	mov    (%eax),%edx
c0100698:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010069b:	01 c2                	add    %eax,%edx
c010069d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	89 d0                	mov    %edx,%eax
c01006aa:	01 c0                	add    %eax,%eax
c01006ac:	01 d0                	add    %edx,%eax
c01006ae:	c1 e0 02             	shl    $0x2,%eax
c01006b1:	89 c2                	mov    %eax,%edx
c01006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b6:	01 d0                	add    %edx,%eax
c01006b8:	8b 50 08             	mov    0x8(%eax),%edx
c01006bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006be:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c4:	8b 40 10             	mov    0x10(%eax),%eax
c01006c7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d6:	eb 15                	jmp    c01006ed <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006db:	8b 55 08             	mov    0x8(%ebp),%edx
c01006de:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f0:	8b 40 08             	mov    0x8(%eax),%eax
c01006f3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006fa:	00 
c01006fb:	89 04 24             	mov    %eax,(%esp)
c01006fe:	e8 73 55 00 00       	call   c0105c76 <strfind>
c0100703:	89 c2                	mov    %eax,%edx
c0100705:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100708:	8b 40 08             	mov    0x8(%eax),%eax
c010070b:	29 c2                	sub    %eax,%edx
c010070d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100710:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100713:	8b 45 08             	mov    0x8(%ebp),%eax
c0100716:	89 44 24 10          	mov    %eax,0x10(%esp)
c010071a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100721:	00 
c0100722:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100725:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100729:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010072c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100733:	89 04 24             	mov    %eax,(%esp)
c0100736:	e8 b9 fc ff ff       	call   c01003f4 <stab_binsearch>
    if (lline <= rline) {
c010073b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010073e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100741:	39 c2                	cmp    %eax,%edx
c0100743:	7f 24                	jg     c0100769 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100745:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	89 d0                	mov    %edx,%eax
c010074c:	01 c0                	add    %eax,%eax
c010074e:	01 d0                	add    %edx,%eax
c0100750:	c1 e0 02             	shl    $0x2,%eax
c0100753:	89 c2                	mov    %eax,%edx
c0100755:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100758:	01 d0                	add    %edx,%eax
c010075a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010075e:	0f b7 d0             	movzwl %ax,%edx
c0100761:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100764:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100767:	eb 13                	jmp    c010077c <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010076e:	e9 12 01 00 00       	jmp    c0100885 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100773:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100776:	83 e8 01             	sub    $0x1,%eax
c0100779:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010077c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010077f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100782:	39 c2                	cmp    %eax,%edx
c0100784:	7c 56                	jl     c01007dc <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0100786:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	89 d0                	mov    %edx,%eax
c010078d:	01 c0                	add    %eax,%eax
c010078f:	01 d0                	add    %edx,%eax
c0100791:	c1 e0 02             	shl    $0x2,%eax
c0100794:	89 c2                	mov    %eax,%edx
c0100796:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100799:	01 d0                	add    %edx,%eax
c010079b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010079f:	3c 84                	cmp    $0x84,%al
c01007a1:	74 39                	je     c01007dc <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	89 d0                	mov    %edx,%eax
c01007aa:	01 c0                	add    %eax,%eax
c01007ac:	01 d0                	add    %edx,%eax
c01007ae:	c1 e0 02             	shl    $0x2,%eax
c01007b1:	89 c2                	mov    %eax,%edx
c01007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007b6:	01 d0                	add    %edx,%eax
c01007b8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007bc:	3c 64                	cmp    $0x64,%al
c01007be:	75 b3                	jne    c0100773 <debuginfo_eip+0x229>
c01007c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	89 d0                	mov    %edx,%eax
c01007c7:	01 c0                	add    %eax,%eax
c01007c9:	01 d0                	add    %edx,%eax
c01007cb:	c1 e0 02             	shl    $0x2,%eax
c01007ce:	89 c2                	mov    %eax,%edx
c01007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d3:	01 d0                	add    %edx,%eax
c01007d5:	8b 40 08             	mov    0x8(%eax),%eax
c01007d8:	85 c0                	test   %eax,%eax
c01007da:	74 97                	je     c0100773 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e2:	39 c2                	cmp    %eax,%edx
c01007e4:	7c 46                	jl     c010082c <debuginfo_eip+0x2e2>
c01007e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	89 d0                	mov    %edx,%eax
c01007ed:	01 c0                	add    %eax,%eax
c01007ef:	01 d0                	add    %edx,%eax
c01007f1:	c1 e0 02             	shl    $0x2,%eax
c01007f4:	89 c2                	mov    %eax,%edx
c01007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f9:	01 d0                	add    %edx,%eax
c01007fb:	8b 10                	mov    (%eax),%edx
c01007fd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100800:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100803:	29 c1                	sub    %eax,%ecx
c0100805:	89 c8                	mov    %ecx,%eax
c0100807:	39 c2                	cmp    %eax,%edx
c0100809:	73 21                	jae    c010082c <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	89 d0                	mov    %edx,%eax
c0100812:	01 c0                	add    %eax,%eax
c0100814:	01 d0                	add    %edx,%eax
c0100816:	c1 e0 02             	shl    $0x2,%eax
c0100819:	89 c2                	mov    %eax,%edx
c010081b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081e:	01 d0                	add    %edx,%eax
c0100820:	8b 10                	mov    (%eax),%edx
c0100822:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100825:	01 c2                	add    %eax,%edx
c0100827:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010082c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010082f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100832:	39 c2                	cmp    %eax,%edx
c0100834:	7d 4a                	jge    c0100880 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c0100836:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100839:	83 c0 01             	add    $0x1,%eax
c010083c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010083f:	eb 18                	jmp    c0100859 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100841:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100844:	8b 40 14             	mov    0x14(%eax),%eax
c0100847:	8d 50 01             	lea    0x1(%eax),%edx
c010084a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010084d:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100853:	83 c0 01             	add    $0x1,%eax
c0100856:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100859:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010085c:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010085f:	39 c2                	cmp    %eax,%edx
c0100861:	7d 1d                	jge    c0100880 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	89 d0                	mov    %edx,%eax
c010086a:	01 c0                	add    %eax,%eax
c010086c:	01 d0                	add    %edx,%eax
c010086e:	c1 e0 02             	shl    $0x2,%eax
c0100871:	89 c2                	mov    %eax,%edx
c0100873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100876:	01 d0                	add    %edx,%eax
c0100878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010087c:	3c a0                	cmp    $0xa0,%al
c010087e:	74 c1                	je     c0100841 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100880:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100885:	c9                   	leave  
c0100886:	c3                   	ret    

c0100887 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100887:	55                   	push   %ebp
c0100888:	89 e5                	mov    %esp,%ebp
c010088a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010088d:	c7 04 24 56 60 10 c0 	movl   $0xc0106056,(%esp)
c0100894:	e8 ba fa ff ff       	call   c0100353 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100899:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a0:	c0 
c01008a1:	c7 04 24 6f 60 10 c0 	movl   $0xc010606f,(%esp)
c01008a8:	e8 a6 fa ff ff       	call   c0100353 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008ad:	c7 44 24 04 8b 5f 10 	movl   $0xc0105f8b,0x4(%esp)
c01008b4:	c0 
c01008b5:	c7 04 24 87 60 10 c0 	movl   $0xc0106087,(%esp)
c01008bc:	e8 92 fa ff ff       	call   c0100353 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c1:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008c8:	c0 
c01008c9:	c7 04 24 9f 60 10 c0 	movl   $0xc010609f,(%esp)
c01008d0:	e8 7e fa ff ff       	call   c0100353 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d5:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c01008dc:	c0 
c01008dd:	c7 04 24 b7 60 10 c0 	movl   $0xc01060b7,(%esp)
c01008e4:	e8 6a fa ff ff       	call   c0100353 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008e9:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01008ee:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f4:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008f9:	29 c2                	sub    %eax,%edx
c01008fb:	89 d0                	mov    %edx,%eax
c01008fd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100903:	85 c0                	test   %eax,%eax
c0100905:	0f 48 c2             	cmovs  %edx,%eax
c0100908:	c1 f8 0a             	sar    $0xa,%eax
c010090b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010090f:	c7 04 24 d0 60 10 c0 	movl   $0xc01060d0,(%esp)
c0100916:	e8 38 fa ff ff       	call   c0100353 <cprintf>
}
c010091b:	c9                   	leave  
c010091c:	c3                   	ret    

c010091d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010091d:	55                   	push   %ebp
c010091e:	89 e5                	mov    %esp,%ebp
c0100920:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100926:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100929:	89 44 24 04          	mov    %eax,0x4(%esp)
c010092d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100930:	89 04 24             	mov    %eax,(%esp)
c0100933:	e8 12 fc ff ff       	call   c010054a <debuginfo_eip>
c0100938:	85 c0                	test   %eax,%eax
c010093a:	74 15                	je     c0100951 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010093c:	8b 45 08             	mov    0x8(%ebp),%eax
c010093f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100943:	c7 04 24 fa 60 10 c0 	movl   $0xc01060fa,(%esp)
c010094a:	e8 04 fa ff ff       	call   c0100353 <cprintf>
c010094f:	eb 6d                	jmp    c01009be <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100958:	eb 1c                	jmp    c0100976 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010095a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100960:	01 d0                	add    %edx,%eax
c0100962:	0f b6 00             	movzbl (%eax),%eax
c0100965:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010096e:	01 ca                	add    %ecx,%edx
c0100970:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100972:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100976:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100979:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010097c:	7f dc                	jg     c010095a <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c010097e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100984:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100987:	01 d0                	add    %edx,%eax
c0100989:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c010098c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010098f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100992:	89 d1                	mov    %edx,%ecx
c0100994:	29 c1                	sub    %eax,%ecx
c0100996:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100999:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010099c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b2:	c7 04 24 16 61 10 c0 	movl   $0xc0106116,(%esp)
c01009b9:	e8 95 f9 ff ff       	call   c0100353 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009be:	c9                   	leave  
c01009bf:	c3                   	ret    

c01009c0 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c0:	55                   	push   %ebp
c01009c1:	89 e5                	mov    %esp,%ebp
c01009c3:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009c6:	8b 45 04             	mov    0x4(%ebp),%eax
c01009c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009cf:	c9                   	leave  
c01009d0:	c3                   	ret    

c01009d1 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d1:	55                   	push   %ebp
c01009d2:	89 e5                	mov    %esp,%ebp
c01009d4:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009d7:	89 e8                	mov    %ebp,%eax
c01009d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c01009df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009e2:	e8 d9 ff ff ff       	call   c01009c0 <read_eip>
c01009e7:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009ea:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f1:	e9 88 00 00 00       	jmp    c0100a7e <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009f9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a04:	c7 04 24 28 61 10 c0 	movl   $0xc0106128,(%esp)
c0100a0b:	e8 43 f9 ff ff       	call   c0100353 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a13:	83 c0 08             	add    $0x8,%eax
c0100a16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a19:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a20:	eb 25                	jmp    c0100a47 <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0100a22:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a2f:	01 d0                	add    %edx,%eax
c0100a31:	8b 00                	mov    (%eax),%eax
c0100a33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a37:	c7 04 24 44 61 10 c0 	movl   $0xc0106144,(%esp)
c0100a3e:	e8 10 f9 ff ff       	call   c0100353 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100a43:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a47:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a4b:	7e d5                	jle    c0100a22 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100a4d:	c7 04 24 4c 61 10 c0 	movl   $0xc010614c,(%esp)
c0100a54:	e8 fa f8 ff ff       	call   c0100353 <cprintf>
        print_debuginfo(eip - 1);
c0100a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a5c:	83 e8 01             	sub    $0x1,%eax
c0100a5f:	89 04 24             	mov    %eax,(%esp)
c0100a62:	e8 b6 fe ff ff       	call   c010091d <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6a:	83 c0 04             	add    $0x4,%eax
c0100a6d:	8b 00                	mov    (%eax),%eax
c0100a6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a75:	8b 00                	mov    (%eax),%eax
c0100a77:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a7a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a82:	74 0a                	je     c0100a8e <print_stackframe+0xbd>
c0100a84:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a88:	0f 8e 68 ff ff ff    	jle    c01009f6 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100a8e:	c9                   	leave  
c0100a8f:	c3                   	ret    

c0100a90 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a90:	55                   	push   %ebp
c0100a91:	89 e5                	mov    %esp,%ebp
c0100a93:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a9d:	eb 0c                	jmp    c0100aab <parse+0x1b>
            *buf ++ = '\0';
c0100a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa2:	8d 50 01             	lea    0x1(%eax),%edx
c0100aa5:	89 55 08             	mov    %edx,0x8(%ebp)
c0100aa8:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aae:	0f b6 00             	movzbl (%eax),%eax
c0100ab1:	84 c0                	test   %al,%al
c0100ab3:	74 1d                	je     c0100ad2 <parse+0x42>
c0100ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab8:	0f b6 00             	movzbl (%eax),%eax
c0100abb:	0f be c0             	movsbl %al,%eax
c0100abe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac2:	c7 04 24 d0 61 10 c0 	movl   $0xc01061d0,(%esp)
c0100ac9:	e8 75 51 00 00       	call   c0105c43 <strchr>
c0100ace:	85 c0                	test   %eax,%eax
c0100ad0:	75 cd                	jne    c0100a9f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad5:	0f b6 00             	movzbl (%eax),%eax
c0100ad8:	84 c0                	test   %al,%al
c0100ada:	75 02                	jne    c0100ade <parse+0x4e>
            break;
c0100adc:	eb 67                	jmp    c0100b45 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ade:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ae2:	75 14                	jne    c0100af8 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ae4:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100aeb:	00 
c0100aec:	c7 04 24 d5 61 10 c0 	movl   $0xc01061d5,(%esp)
c0100af3:	e8 5b f8 ff ff       	call   c0100353 <cprintf>
        }
        argv[argc ++] = buf;
c0100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afb:	8d 50 01             	lea    0x1(%eax),%edx
c0100afe:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b0b:	01 c2                	add    %eax,%edx
c0100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b10:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b12:	eb 04                	jmp    c0100b18 <parse+0x88>
            buf ++;
c0100b14:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b18:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1b:	0f b6 00             	movzbl (%eax),%eax
c0100b1e:	84 c0                	test   %al,%al
c0100b20:	74 1d                	je     c0100b3f <parse+0xaf>
c0100b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b25:	0f b6 00             	movzbl (%eax),%eax
c0100b28:	0f be c0             	movsbl %al,%eax
c0100b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b2f:	c7 04 24 d0 61 10 c0 	movl   $0xc01061d0,(%esp)
c0100b36:	e8 08 51 00 00       	call   c0105c43 <strchr>
c0100b3b:	85 c0                	test   %eax,%eax
c0100b3d:	74 d5                	je     c0100b14 <parse+0x84>
            buf ++;
        }
    }
c0100b3f:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b40:	e9 66 ff ff ff       	jmp    c0100aab <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b48:	c9                   	leave  
c0100b49:	c3                   	ret    

c0100b4a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b4a:	55                   	push   %ebp
c0100b4b:	89 e5                	mov    %esp,%ebp
c0100b4d:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b50:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b57:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5a:	89 04 24             	mov    %eax,(%esp)
c0100b5d:	e8 2e ff ff ff       	call   c0100a90 <parse>
c0100b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b69:	75 0a                	jne    c0100b75 <runcmd+0x2b>
        return 0;
c0100b6b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b70:	e9 85 00 00 00       	jmp    c0100bfa <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b7c:	eb 5c                	jmp    c0100bda <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b7e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b84:	89 d0                	mov    %edx,%eax
c0100b86:	01 c0                	add    %eax,%eax
c0100b88:	01 d0                	add    %edx,%eax
c0100b8a:	c1 e0 02             	shl    $0x2,%eax
c0100b8d:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100b92:	8b 00                	mov    (%eax),%eax
c0100b94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b98:	89 04 24             	mov    %eax,(%esp)
c0100b9b:	e8 04 50 00 00       	call   c0105ba4 <strcmp>
c0100ba0:	85 c0                	test   %eax,%eax
c0100ba2:	75 32                	jne    c0100bd6 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100ba4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ba7:	89 d0                	mov    %edx,%eax
c0100ba9:	01 c0                	add    %eax,%eax
c0100bab:	01 d0                	add    %edx,%eax
c0100bad:	c1 e0 02             	shl    $0x2,%eax
c0100bb0:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100bb5:	8b 40 08             	mov    0x8(%eax),%eax
c0100bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bbb:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bc1:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bc5:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bc8:	83 c2 04             	add    $0x4,%edx
c0100bcb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bcf:	89 0c 24             	mov    %ecx,(%esp)
c0100bd2:	ff d0                	call   *%eax
c0100bd4:	eb 24                	jmp    c0100bfa <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bdd:	83 f8 02             	cmp    $0x2,%eax
c0100be0:	76 9c                	jbe    c0100b7e <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100be2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100be5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be9:	c7 04 24 f3 61 10 c0 	movl   $0xc01061f3,(%esp)
c0100bf0:	e8 5e f7 ff ff       	call   c0100353 <cprintf>
    return 0;
c0100bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bfa:	c9                   	leave  
c0100bfb:	c3                   	ret    

c0100bfc <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bfc:	55                   	push   %ebp
c0100bfd:	89 e5                	mov    %esp,%ebp
c0100bff:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c02:	c7 04 24 0c 62 10 c0 	movl   $0xc010620c,(%esp)
c0100c09:	e8 45 f7 ff ff       	call   c0100353 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c0e:	c7 04 24 34 62 10 c0 	movl   $0xc0106234,(%esp)
c0100c15:	e8 39 f7 ff ff       	call   c0100353 <cprintf>

    if (tf != NULL) {
c0100c1a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c1e:	74 0b                	je     c0100c2b <kmonitor+0x2f>
        print_trapframe(tf);
c0100c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c23:	89 04 24             	mov    %eax,(%esp)
c0100c26:	e8 e8 0d 00 00       	call   c0101a13 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c2b:	c7 04 24 59 62 10 c0 	movl   $0xc0106259,(%esp)
c0100c32:	e8 13 f6 ff ff       	call   c010024a <readline>
c0100c37:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c3e:	74 18                	je     c0100c58 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c4a:	89 04 24             	mov    %eax,(%esp)
c0100c4d:	e8 f8 fe ff ff       	call   c0100b4a <runcmd>
c0100c52:	85 c0                	test   %eax,%eax
c0100c54:	79 02                	jns    c0100c58 <kmonitor+0x5c>
                break;
c0100c56:	eb 02                	jmp    c0100c5a <kmonitor+0x5e>
            }
        }
    }
c0100c58:	eb d1                	jmp    c0100c2b <kmonitor+0x2f>
}
c0100c5a:	c9                   	leave  
c0100c5b:	c3                   	ret    

c0100c5c <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c5c:	55                   	push   %ebp
c0100c5d:	89 e5                	mov    %esp,%ebp
c0100c5f:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c69:	eb 3f                	jmp    c0100caa <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c6e:	89 d0                	mov    %edx,%eax
c0100c70:	01 c0                	add    %eax,%eax
c0100c72:	01 d0                	add    %edx,%eax
c0100c74:	c1 e0 02             	shl    $0x2,%eax
c0100c77:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c7c:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c82:	89 d0                	mov    %edx,%eax
c0100c84:	01 c0                	add    %eax,%eax
c0100c86:	01 d0                	add    %edx,%eax
c0100c88:	c1 e0 02             	shl    $0x2,%eax
c0100c8b:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c90:	8b 00                	mov    (%eax),%eax
c0100c92:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c96:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9a:	c7 04 24 5d 62 10 c0 	movl   $0xc010625d,(%esp)
c0100ca1:	e8 ad f6 ff ff       	call   c0100353 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ca6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cad:	83 f8 02             	cmp    $0x2,%eax
c0100cb0:	76 b9                	jbe    c0100c6b <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100cb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cb7:	c9                   	leave  
c0100cb8:	c3                   	ret    

c0100cb9 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cb9:	55                   	push   %ebp
c0100cba:	89 e5                	mov    %esp,%ebp
c0100cbc:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cbf:	e8 c3 fb ff ff       	call   c0100887 <print_kerninfo>
    return 0;
c0100cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc9:	c9                   	leave  
c0100cca:	c3                   	ret    

c0100ccb <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ccb:	55                   	push   %ebp
c0100ccc:	89 e5                	mov    %esp,%ebp
c0100cce:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cd1:	e8 fb fc ff ff       	call   c01009d1 <print_stackframe>
    return 0;
c0100cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cdb:	c9                   	leave  
c0100cdc:	c3                   	ret    

c0100cdd <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cdd:	55                   	push   %ebp
c0100cde:	89 e5                	mov    %esp,%ebp
c0100ce0:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ce3:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100ce8:	85 c0                	test   %eax,%eax
c0100cea:	74 02                	je     c0100cee <__panic+0x11>
        goto panic_dead;
c0100cec:	eb 59                	jmp    c0100d47 <__panic+0x6a>
    }
    is_panic = 1;
c0100cee:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100cf5:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100cf8:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d01:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d0c:	c7 04 24 66 62 10 c0 	movl   $0xc0106266,(%esp)
c0100d13:	e8 3b f6 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d22:	89 04 24             	mov    %eax,(%esp)
c0100d25:	e8 f6 f5 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100d2a:	c7 04 24 82 62 10 c0 	movl   $0xc0106282,(%esp)
c0100d31:	e8 1d f6 ff ff       	call   c0100353 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d36:	c7 04 24 84 62 10 c0 	movl   $0xc0106284,(%esp)
c0100d3d:	e8 11 f6 ff ff       	call   c0100353 <cprintf>
    print_stackframe();
c0100d42:	e8 8a fc ff ff       	call   c01009d1 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d47:	e8 85 09 00 00       	call   c01016d1 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d53:	e8 a4 fe ff ff       	call   c0100bfc <kmonitor>
    }
c0100d58:	eb f2                	jmp    c0100d4c <__panic+0x6f>

c0100d5a <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d5a:	55                   	push   %ebp
c0100d5b:	89 e5                	mov    %esp,%ebp
c0100d5d:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d60:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d63:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d69:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d74:	c7 04 24 96 62 10 c0 	movl   $0xc0106296,(%esp)
c0100d7b:	e8 d3 f5 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d87:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d8a:	89 04 24             	mov    %eax,(%esp)
c0100d8d:	e8 8e f5 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100d92:	c7 04 24 82 62 10 c0 	movl   $0xc0106282,(%esp)
c0100d99:	e8 b5 f5 ff ff       	call   c0100353 <cprintf>
    va_end(ap);
}
c0100d9e:	c9                   	leave  
c0100d9f:	c3                   	ret    

c0100da0 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100da0:	55                   	push   %ebp
c0100da1:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100da3:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100da8:	5d                   	pop    %ebp
c0100da9:	c3                   	ret    

c0100daa <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100daa:	55                   	push   %ebp
c0100dab:	89 e5                	mov    %esp,%ebp
c0100dad:	83 ec 28             	sub    $0x28,%esp
c0100db0:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100db6:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dba:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dbe:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc2:	ee                   	out    %al,(%dx)
c0100dc3:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dc9:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dcd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dd1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd5:	ee                   	out    %al,(%dx)
c0100dd6:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100ddc:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100de0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100de4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100de8:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100de9:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100df0:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df3:	c7 04 24 b4 62 10 c0 	movl   $0xc01062b4,(%esp)
c0100dfa:	e8 54 f5 ff ff       	call   c0100353 <cprintf>
    pic_enable(IRQ_TIMER);
c0100dff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e06:	e8 24 09 00 00       	call   c010172f <pic_enable>
}
c0100e0b:	c9                   	leave  
c0100e0c:	c3                   	ret    

c0100e0d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e0d:	55                   	push   %ebp
c0100e0e:	89 e5                	mov    %esp,%ebp
c0100e10:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e13:	9c                   	pushf  
c0100e14:	58                   	pop    %eax
c0100e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e1b:	25 00 02 00 00       	and    $0x200,%eax
c0100e20:	85 c0                	test   %eax,%eax
c0100e22:	74 0c                	je     c0100e30 <__intr_save+0x23>
        intr_disable();
c0100e24:	e8 a8 08 00 00       	call   c01016d1 <intr_disable>
        return 1;
c0100e29:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e2e:	eb 05                	jmp    c0100e35 <__intr_save+0x28>
    }
    return 0;
c0100e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e35:	c9                   	leave  
c0100e36:	c3                   	ret    

c0100e37 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e37:	55                   	push   %ebp
c0100e38:	89 e5                	mov    %esp,%ebp
c0100e3a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e41:	74 05                	je     c0100e48 <__intr_restore+0x11>
        intr_enable();
c0100e43:	e8 83 08 00 00       	call   c01016cb <intr_enable>
    }
}
c0100e48:	c9                   	leave  
c0100e49:	c3                   	ret    

c0100e4a <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e4a:	55                   	push   %ebp
c0100e4b:	89 e5                	mov    %esp,%ebp
c0100e4d:	83 ec 10             	sub    $0x10,%esp
c0100e50:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e56:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e5a:	89 c2                	mov    %eax,%edx
c0100e5c:	ec                   	in     (%dx),%al
c0100e5d:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e60:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e66:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e6a:	89 c2                	mov    %eax,%edx
c0100e6c:	ec                   	in     (%dx),%al
c0100e6d:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e70:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e76:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e7a:	89 c2                	mov    %eax,%edx
c0100e7c:	ec                   	in     (%dx),%al
c0100e7d:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e80:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e86:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e8a:	89 c2                	mov    %eax,%edx
c0100e8c:	ec                   	in     (%dx),%al
c0100e8d:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e90:	c9                   	leave  
c0100e91:	c3                   	ret    

c0100e92 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e92:	55                   	push   %ebp
c0100e93:	89 e5                	mov    %esp,%ebp
c0100e95:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e98:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea2:	0f b7 00             	movzwl (%eax),%eax
c0100ea5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ea9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eac:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb4:	0f b7 00             	movzwl (%eax),%eax
c0100eb7:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100ebb:	74 12                	je     c0100ecf <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ebd:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ec4:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ecb:	b4 03 
c0100ecd:	eb 13                	jmp    c0100ee2 <cga_init+0x50>
    } else {
        *cp = was;
c0100ecf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ed6:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ed9:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ee0:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ee2:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ee9:	0f b7 c0             	movzwl %ax,%eax
c0100eec:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ef0:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ef4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ef8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100efc:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100efd:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f04:	83 c0 01             	add    $0x1,%eax
c0100f07:	0f b7 c0             	movzwl %ax,%eax
c0100f0a:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f0e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f12:	89 c2                	mov    %eax,%edx
c0100f14:	ec                   	in     (%dx),%al
c0100f15:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f18:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f1c:	0f b6 c0             	movzbl %al,%eax
c0100f1f:	c1 e0 08             	shl    $0x8,%eax
c0100f22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f25:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f2c:	0f b7 c0             	movzwl %ax,%eax
c0100f2f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f33:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f37:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f3b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f3f:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f40:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f47:	83 c0 01             	add    $0x1,%eax
c0100f4a:	0f b7 c0             	movzwl %ax,%eax
c0100f4d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f51:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f55:	89 c2                	mov    %eax,%edx
c0100f57:	ec                   	in     (%dx),%al
c0100f58:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f5b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f5f:	0f b6 c0             	movzbl %al,%eax
c0100f62:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f65:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f68:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f70:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f76:	c9                   	leave  
c0100f77:	c3                   	ret    

c0100f78 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f78:	55                   	push   %ebp
c0100f79:	89 e5                	mov    %esp,%ebp
c0100f7b:	83 ec 48             	sub    $0x48,%esp
c0100f7e:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f84:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f88:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f8c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f90:	ee                   	out    %al,(%dx)
c0100f91:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f97:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f9b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f9f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fa3:	ee                   	out    %al,(%dx)
c0100fa4:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100faa:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fae:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fb2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fb6:	ee                   	out    %al,(%dx)
c0100fb7:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fbd:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fc1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fc5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fc9:	ee                   	out    %al,(%dx)
c0100fca:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fd0:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fd4:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fd8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fdc:	ee                   	out    %al,(%dx)
c0100fdd:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fe3:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fe7:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100feb:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fef:	ee                   	out    %al,(%dx)
c0100ff0:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100ff6:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100ffa:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ffe:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101002:	ee                   	out    %al,(%dx)
c0101003:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101009:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010100d:	89 c2                	mov    %eax,%edx
c010100f:	ec                   	in     (%dx),%al
c0101010:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101013:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101017:	3c ff                	cmp    $0xff,%al
c0101019:	0f 95 c0             	setne  %al
c010101c:	0f b6 c0             	movzbl %al,%eax
c010101f:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101024:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010102a:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c010102e:	89 c2                	mov    %eax,%edx
c0101030:	ec                   	in     (%dx),%al
c0101031:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101034:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010103a:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c010103e:	89 c2                	mov    %eax,%edx
c0101040:	ec                   	in     (%dx),%al
c0101041:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101044:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101049:	85 c0                	test   %eax,%eax
c010104b:	74 0c                	je     c0101059 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c010104d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101054:	e8 d6 06 00 00       	call   c010172f <pic_enable>
    }
}
c0101059:	c9                   	leave  
c010105a:	c3                   	ret    

c010105b <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010105b:	55                   	push   %ebp
c010105c:	89 e5                	mov    %esp,%ebp
c010105e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101061:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101068:	eb 09                	jmp    c0101073 <lpt_putc_sub+0x18>
        delay();
c010106a:	e8 db fd ff ff       	call   c0100e4a <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010106f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101073:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0101079:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010107d:	89 c2                	mov    %eax,%edx
c010107f:	ec                   	in     (%dx),%al
c0101080:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101083:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101087:	84 c0                	test   %al,%al
c0101089:	78 09                	js     c0101094 <lpt_putc_sub+0x39>
c010108b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101092:	7e d6                	jle    c010106a <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101094:	8b 45 08             	mov    0x8(%ebp),%eax
c0101097:	0f b6 c0             	movzbl %al,%eax
c010109a:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01010a0:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010a3:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010a7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010ab:	ee                   	out    %al,(%dx)
c01010ac:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010b2:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010b6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010ba:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010be:	ee                   	out    %al,(%dx)
c01010bf:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010c5:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010c9:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010cd:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010d1:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010d2:	c9                   	leave  
c01010d3:	c3                   	ret    

c01010d4 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010d4:	55                   	push   %ebp
c01010d5:	89 e5                	mov    %esp,%ebp
c01010d7:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010da:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010de:	74 0d                	je     c01010ed <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01010e3:	89 04 24             	mov    %eax,(%esp)
c01010e6:	e8 70 ff ff ff       	call   c010105b <lpt_putc_sub>
c01010eb:	eb 24                	jmp    c0101111 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010ed:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010f4:	e8 62 ff ff ff       	call   c010105b <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010f9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101100:	e8 56 ff ff ff       	call   c010105b <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101105:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010110c:	e8 4a ff ff ff       	call   c010105b <lpt_putc_sub>
    }
}
c0101111:	c9                   	leave  
c0101112:	c3                   	ret    

c0101113 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101113:	55                   	push   %ebp
c0101114:	89 e5                	mov    %esp,%ebp
c0101116:	53                   	push   %ebx
c0101117:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010111a:	8b 45 08             	mov    0x8(%ebp),%eax
c010111d:	b0 00                	mov    $0x0,%al
c010111f:	85 c0                	test   %eax,%eax
c0101121:	75 07                	jne    c010112a <cga_putc+0x17>
        c |= 0x0700;
c0101123:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010112a:	8b 45 08             	mov    0x8(%ebp),%eax
c010112d:	0f b6 c0             	movzbl %al,%eax
c0101130:	83 f8 0a             	cmp    $0xa,%eax
c0101133:	74 4c                	je     c0101181 <cga_putc+0x6e>
c0101135:	83 f8 0d             	cmp    $0xd,%eax
c0101138:	74 57                	je     c0101191 <cga_putc+0x7e>
c010113a:	83 f8 08             	cmp    $0x8,%eax
c010113d:	0f 85 88 00 00 00    	jne    c01011cb <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101143:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010114a:	66 85 c0             	test   %ax,%ax
c010114d:	74 30                	je     c010117f <cga_putc+0x6c>
            crt_pos --;
c010114f:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101156:	83 e8 01             	sub    $0x1,%eax
c0101159:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c010115f:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101164:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c010116b:	0f b7 d2             	movzwl %dx,%edx
c010116e:	01 d2                	add    %edx,%edx
c0101170:	01 c2                	add    %eax,%edx
c0101172:	8b 45 08             	mov    0x8(%ebp),%eax
c0101175:	b0 00                	mov    $0x0,%al
c0101177:	83 c8 20             	or     $0x20,%eax
c010117a:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010117d:	eb 72                	jmp    c01011f1 <cga_putc+0xde>
c010117f:	eb 70                	jmp    c01011f1 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101181:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101188:	83 c0 50             	add    $0x50,%eax
c010118b:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101191:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c0101198:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c010119f:	0f b7 c1             	movzwl %cx,%eax
c01011a2:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011a8:	c1 e8 10             	shr    $0x10,%eax
c01011ab:	89 c2                	mov    %eax,%edx
c01011ad:	66 c1 ea 06          	shr    $0x6,%dx
c01011b1:	89 d0                	mov    %edx,%eax
c01011b3:	c1 e0 02             	shl    $0x2,%eax
c01011b6:	01 d0                	add    %edx,%eax
c01011b8:	c1 e0 04             	shl    $0x4,%eax
c01011bb:	29 c1                	sub    %eax,%ecx
c01011bd:	89 ca                	mov    %ecx,%edx
c01011bf:	89 d8                	mov    %ebx,%eax
c01011c1:	29 d0                	sub    %edx,%eax
c01011c3:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011c9:	eb 26                	jmp    c01011f1 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011cb:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011d1:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011d8:	8d 50 01             	lea    0x1(%eax),%edx
c01011db:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011e2:	0f b7 c0             	movzwl %ax,%eax
c01011e5:	01 c0                	add    %eax,%eax
c01011e7:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ed:	66 89 02             	mov    %ax,(%edx)
        break;
c01011f0:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011f1:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011f8:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011fc:	76 5b                	jbe    c0101259 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011fe:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101203:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101209:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c010120e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101215:	00 
c0101216:	89 54 24 04          	mov    %edx,0x4(%esp)
c010121a:	89 04 24             	mov    %eax,(%esp)
c010121d:	e8 1f 4c 00 00       	call   c0105e41 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101222:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101229:	eb 15                	jmp    c0101240 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010122b:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101230:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101233:	01 d2                	add    %edx,%edx
c0101235:	01 d0                	add    %edx,%eax
c0101237:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010123c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101240:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101247:	7e e2                	jle    c010122b <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101249:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101250:	83 e8 50             	sub    $0x50,%eax
c0101253:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101259:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101260:	0f b7 c0             	movzwl %ax,%eax
c0101263:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101267:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010126b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010126f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101273:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101274:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010127b:	66 c1 e8 08          	shr    $0x8,%ax
c010127f:	0f b6 c0             	movzbl %al,%eax
c0101282:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c0101289:	83 c2 01             	add    $0x1,%edx
c010128c:	0f b7 d2             	movzwl %dx,%edx
c010128f:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101293:	88 45 ed             	mov    %al,-0x13(%ebp)
c0101296:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010129a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010129e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010129f:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c01012a6:	0f b7 c0             	movzwl %ax,%eax
c01012a9:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012ad:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012b1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012b5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012b9:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012ba:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012c1:	0f b6 c0             	movzbl %al,%eax
c01012c4:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012cb:	83 c2 01             	add    $0x1,%edx
c01012ce:	0f b7 d2             	movzwl %dx,%edx
c01012d1:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012d5:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012d8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012dc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012e0:	ee                   	out    %al,(%dx)
}
c01012e1:	83 c4 34             	add    $0x34,%esp
c01012e4:	5b                   	pop    %ebx
c01012e5:	5d                   	pop    %ebp
c01012e6:	c3                   	ret    

c01012e7 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012e7:	55                   	push   %ebp
c01012e8:	89 e5                	mov    %esp,%ebp
c01012ea:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012f4:	eb 09                	jmp    c01012ff <serial_putc_sub+0x18>
        delay();
c01012f6:	e8 4f fb ff ff       	call   c0100e4a <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012ff:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101305:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101309:	89 c2                	mov    %eax,%edx
c010130b:	ec                   	in     (%dx),%al
c010130c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010130f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101313:	0f b6 c0             	movzbl %al,%eax
c0101316:	83 e0 20             	and    $0x20,%eax
c0101319:	85 c0                	test   %eax,%eax
c010131b:	75 09                	jne    c0101326 <serial_putc_sub+0x3f>
c010131d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101324:	7e d0                	jle    c01012f6 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101326:	8b 45 08             	mov    0x8(%ebp),%eax
c0101329:	0f b6 c0             	movzbl %al,%eax
c010132c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101332:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101335:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101339:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010133d:	ee                   	out    %al,(%dx)
}
c010133e:	c9                   	leave  
c010133f:	c3                   	ret    

c0101340 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101340:	55                   	push   %ebp
c0101341:	89 e5                	mov    %esp,%ebp
c0101343:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101346:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010134a:	74 0d                	je     c0101359 <serial_putc+0x19>
        serial_putc_sub(c);
c010134c:	8b 45 08             	mov    0x8(%ebp),%eax
c010134f:	89 04 24             	mov    %eax,(%esp)
c0101352:	e8 90 ff ff ff       	call   c01012e7 <serial_putc_sub>
c0101357:	eb 24                	jmp    c010137d <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101359:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101360:	e8 82 ff ff ff       	call   c01012e7 <serial_putc_sub>
        serial_putc_sub(' ');
c0101365:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010136c:	e8 76 ff ff ff       	call   c01012e7 <serial_putc_sub>
        serial_putc_sub('\b');
c0101371:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101378:	e8 6a ff ff ff       	call   c01012e7 <serial_putc_sub>
    }
}
c010137d:	c9                   	leave  
c010137e:	c3                   	ret    

c010137f <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010137f:	55                   	push   %ebp
c0101380:	89 e5                	mov    %esp,%ebp
c0101382:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101385:	eb 33                	jmp    c01013ba <cons_intr+0x3b>
        if (c != 0) {
c0101387:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010138b:	74 2d                	je     c01013ba <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010138d:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101392:	8d 50 01             	lea    0x1(%eax),%edx
c0101395:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c010139b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010139e:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013a4:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c01013a9:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013ae:	75 0a                	jne    c01013ba <cons_intr+0x3b>
                cons.wpos = 0;
c01013b0:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013b7:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01013bd:	ff d0                	call   *%eax
c01013bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013c2:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013c6:	75 bf                	jne    c0101387 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013c8:	c9                   	leave  
c01013c9:	c3                   	ret    

c01013ca <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013ca:	55                   	push   %ebp
c01013cb:	89 e5                	mov    %esp,%ebp
c01013cd:	83 ec 10             	sub    $0x10,%esp
c01013d0:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013d6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013da:	89 c2                	mov    %eax,%edx
c01013dc:	ec                   	in     (%dx),%al
c01013dd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013e0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013e4:	0f b6 c0             	movzbl %al,%eax
c01013e7:	83 e0 01             	and    $0x1,%eax
c01013ea:	85 c0                	test   %eax,%eax
c01013ec:	75 07                	jne    c01013f5 <serial_proc_data+0x2b>
        return -1;
c01013ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013f3:	eb 2a                	jmp    c010141f <serial_proc_data+0x55>
c01013f5:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013fb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013ff:	89 c2                	mov    %eax,%edx
c0101401:	ec                   	in     (%dx),%al
c0101402:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101405:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101409:	0f b6 c0             	movzbl %al,%eax
c010140c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010140f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101413:	75 07                	jne    c010141c <serial_proc_data+0x52>
        c = '\b';
c0101415:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c010141c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010141f:	c9                   	leave  
c0101420:	c3                   	ret    

c0101421 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101421:	55                   	push   %ebp
c0101422:	89 e5                	mov    %esp,%ebp
c0101424:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101427:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010142c:	85 c0                	test   %eax,%eax
c010142e:	74 0c                	je     c010143c <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101430:	c7 04 24 ca 13 10 c0 	movl   $0xc01013ca,(%esp)
c0101437:	e8 43 ff ff ff       	call   c010137f <cons_intr>
    }
}
c010143c:	c9                   	leave  
c010143d:	c3                   	ret    

c010143e <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010143e:	55                   	push   %ebp
c010143f:	89 e5                	mov    %esp,%ebp
c0101441:	83 ec 38             	sub    $0x38,%esp
c0101444:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010144a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010144e:	89 c2                	mov    %eax,%edx
c0101450:	ec                   	in     (%dx),%al
c0101451:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101454:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101458:	0f b6 c0             	movzbl %al,%eax
c010145b:	83 e0 01             	and    $0x1,%eax
c010145e:	85 c0                	test   %eax,%eax
c0101460:	75 0a                	jne    c010146c <kbd_proc_data+0x2e>
        return -1;
c0101462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101467:	e9 59 01 00 00       	jmp    c01015c5 <kbd_proc_data+0x187>
c010146c:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101472:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101476:	89 c2                	mov    %eax,%edx
c0101478:	ec                   	in     (%dx),%al
c0101479:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010147c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101480:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101483:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101487:	75 17                	jne    c01014a0 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0101489:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010148e:	83 c8 40             	or     $0x40,%eax
c0101491:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c0101496:	b8 00 00 00 00       	mov    $0x0,%eax
c010149b:	e9 25 01 00 00       	jmp    c01015c5 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01014a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a4:	84 c0                	test   %al,%al
c01014a6:	79 47                	jns    c01014ef <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014a8:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014ad:	83 e0 40             	and    $0x40,%eax
c01014b0:	85 c0                	test   %eax,%eax
c01014b2:	75 09                	jne    c01014bd <kbd_proc_data+0x7f>
c01014b4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b8:	83 e0 7f             	and    $0x7f,%eax
c01014bb:	eb 04                	jmp    c01014c1 <kbd_proc_data+0x83>
c01014bd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c1:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014c4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c8:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014cf:	83 c8 40             	or     $0x40,%eax
c01014d2:	0f b6 c0             	movzbl %al,%eax
c01014d5:	f7 d0                	not    %eax
c01014d7:	89 c2                	mov    %eax,%edx
c01014d9:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014de:	21 d0                	and    %edx,%eax
c01014e0:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014e5:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ea:	e9 d6 00 00 00       	jmp    c01015c5 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014ef:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f4:	83 e0 40             	and    $0x40,%eax
c01014f7:	85 c0                	test   %eax,%eax
c01014f9:	74 11                	je     c010150c <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014fb:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014ff:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101504:	83 e0 bf             	and    $0xffffffbf,%eax
c0101507:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c010150c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101510:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c0101517:	0f b6 d0             	movzbl %al,%edx
c010151a:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010151f:	09 d0                	or     %edx,%eax
c0101521:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c0101526:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152a:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101531:	0f b6 d0             	movzbl %al,%edx
c0101534:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101539:	31 d0                	xor    %edx,%eax
c010153b:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101540:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101545:	83 e0 03             	and    $0x3,%eax
c0101548:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c010154f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101553:	01 d0                	add    %edx,%eax
c0101555:	0f b6 00             	movzbl (%eax),%eax
c0101558:	0f b6 c0             	movzbl %al,%eax
c010155b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010155e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101563:	83 e0 08             	and    $0x8,%eax
c0101566:	85 c0                	test   %eax,%eax
c0101568:	74 22                	je     c010158c <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010156a:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010156e:	7e 0c                	jle    c010157c <kbd_proc_data+0x13e>
c0101570:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101574:	7f 06                	jg     c010157c <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101576:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010157a:	eb 10                	jmp    c010158c <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010157c:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101580:	7e 0a                	jle    c010158c <kbd_proc_data+0x14e>
c0101582:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101586:	7f 04                	jg     c010158c <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101588:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010158c:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101591:	f7 d0                	not    %eax
c0101593:	83 e0 06             	and    $0x6,%eax
c0101596:	85 c0                	test   %eax,%eax
c0101598:	75 28                	jne    c01015c2 <kbd_proc_data+0x184>
c010159a:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015a1:	75 1f                	jne    c01015c2 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015a3:	c7 04 24 cf 62 10 c0 	movl   $0xc01062cf,(%esp)
c01015aa:	e8 a4 ed ff ff       	call   c0100353 <cprintf>
c01015af:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015b5:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015b9:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015bd:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015c1:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015c5:	c9                   	leave  
c01015c6:	c3                   	ret    

c01015c7 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015c7:	55                   	push   %ebp
c01015c8:	89 e5                	mov    %esp,%ebp
c01015ca:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015cd:	c7 04 24 3e 14 10 c0 	movl   $0xc010143e,(%esp)
c01015d4:	e8 a6 fd ff ff       	call   c010137f <cons_intr>
}
c01015d9:	c9                   	leave  
c01015da:	c3                   	ret    

c01015db <kbd_init>:

static void
kbd_init(void) {
c01015db:	55                   	push   %ebp
c01015dc:	89 e5                	mov    %esp,%ebp
c01015de:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015e1:	e8 e1 ff ff ff       	call   c01015c7 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015ed:	e8 3d 01 00 00       	call   c010172f <pic_enable>
}
c01015f2:	c9                   	leave  
c01015f3:	c3                   	ret    

c01015f4 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015f4:	55                   	push   %ebp
c01015f5:	89 e5                	mov    %esp,%ebp
c01015f7:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015fa:	e8 93 f8 ff ff       	call   c0100e92 <cga_init>
    serial_init();
c01015ff:	e8 74 f9 ff ff       	call   c0100f78 <serial_init>
    kbd_init();
c0101604:	e8 d2 ff ff ff       	call   c01015db <kbd_init>
    if (!serial_exists) {
c0101609:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010160e:	85 c0                	test   %eax,%eax
c0101610:	75 0c                	jne    c010161e <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101612:	c7 04 24 db 62 10 c0 	movl   $0xc01062db,(%esp)
c0101619:	e8 35 ed ff ff       	call   c0100353 <cprintf>
    }
}
c010161e:	c9                   	leave  
c010161f:	c3                   	ret    

c0101620 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101620:	55                   	push   %ebp
c0101621:	89 e5                	mov    %esp,%ebp
c0101623:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101626:	e8 e2 f7 ff ff       	call   c0100e0d <__intr_save>
c010162b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010162e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101631:	89 04 24             	mov    %eax,(%esp)
c0101634:	e8 9b fa ff ff       	call   c01010d4 <lpt_putc>
        cga_putc(c);
c0101639:	8b 45 08             	mov    0x8(%ebp),%eax
c010163c:	89 04 24             	mov    %eax,(%esp)
c010163f:	e8 cf fa ff ff       	call   c0101113 <cga_putc>
        serial_putc(c);
c0101644:	8b 45 08             	mov    0x8(%ebp),%eax
c0101647:	89 04 24             	mov    %eax,(%esp)
c010164a:	e8 f1 fc ff ff       	call   c0101340 <serial_putc>
    }
    local_intr_restore(intr_flag);
c010164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101652:	89 04 24             	mov    %eax,(%esp)
c0101655:	e8 dd f7 ff ff       	call   c0100e37 <__intr_restore>
}
c010165a:	c9                   	leave  
c010165b:	c3                   	ret    

c010165c <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010165c:	55                   	push   %ebp
c010165d:	89 e5                	mov    %esp,%ebp
c010165f:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101669:	e8 9f f7 ff ff       	call   c0100e0d <__intr_save>
c010166e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101671:	e8 ab fd ff ff       	call   c0101421 <serial_intr>
        kbd_intr();
c0101676:	e8 4c ff ff ff       	call   c01015c7 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010167b:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101681:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101686:	39 c2                	cmp    %eax,%edx
c0101688:	74 31                	je     c01016bb <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010168a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010168f:	8d 50 01             	lea    0x1(%eax),%edx
c0101692:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c0101698:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c010169f:	0f b6 c0             	movzbl %al,%eax
c01016a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016a5:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c01016aa:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016af:	75 0a                	jne    c01016bb <cons_getc+0x5f>
                cons.rpos = 0;
c01016b1:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016b8:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016be:	89 04 24             	mov    %eax,(%esp)
c01016c1:	e8 71 f7 ff ff       	call   c0100e37 <__intr_restore>
    return c;
c01016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016c9:	c9                   	leave  
c01016ca:	c3                   	ret    

c01016cb <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016cb:	55                   	push   %ebp
c01016cc:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016ce:	fb                   	sti    
    sti();
}
c01016cf:	5d                   	pop    %ebp
c01016d0:	c3                   	ret    

c01016d1 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016d1:	55                   	push   %ebp
c01016d2:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016d4:	fa                   	cli    
    cli();
}
c01016d5:	5d                   	pop    %ebp
c01016d6:	c3                   	ret    

c01016d7 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016d7:	55                   	push   %ebp
c01016d8:	89 e5                	mov    %esp,%ebp
c01016da:	83 ec 14             	sub    $0x14,%esp
c01016dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01016e0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016e4:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016e8:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016ee:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016f3:	85 c0                	test   %eax,%eax
c01016f5:	74 36                	je     c010172d <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016f7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016fb:	0f b6 c0             	movzbl %al,%eax
c01016fe:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101704:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101707:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010170b:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010170f:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101710:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101714:	66 c1 e8 08          	shr    $0x8,%ax
c0101718:	0f b6 c0             	movzbl %al,%eax
c010171b:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101721:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101724:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101728:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010172c:	ee                   	out    %al,(%dx)
    }
}
c010172d:	c9                   	leave  
c010172e:	c3                   	ret    

c010172f <pic_enable>:

void
pic_enable(unsigned int irq) {
c010172f:	55                   	push   %ebp
c0101730:	89 e5                	mov    %esp,%ebp
c0101732:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101735:	8b 45 08             	mov    0x8(%ebp),%eax
c0101738:	ba 01 00 00 00       	mov    $0x1,%edx
c010173d:	89 c1                	mov    %eax,%ecx
c010173f:	d3 e2                	shl    %cl,%edx
c0101741:	89 d0                	mov    %edx,%eax
c0101743:	f7 d0                	not    %eax
c0101745:	89 c2                	mov    %eax,%edx
c0101747:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010174e:	21 d0                	and    %edx,%eax
c0101750:	0f b7 c0             	movzwl %ax,%eax
c0101753:	89 04 24             	mov    %eax,(%esp)
c0101756:	e8 7c ff ff ff       	call   c01016d7 <pic_setmask>
}
c010175b:	c9                   	leave  
c010175c:	c3                   	ret    

c010175d <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c010175d:	55                   	push   %ebp
c010175e:	89 e5                	mov    %esp,%ebp
c0101760:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101763:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010176a:	00 00 00 
c010176d:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101773:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101777:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010177b:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010177f:	ee                   	out    %al,(%dx)
c0101780:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101786:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010178a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010178e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101792:	ee                   	out    %al,(%dx)
c0101793:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101799:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c010179d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01017a1:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017a5:	ee                   	out    %al,(%dx)
c01017a6:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017ac:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017b0:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017b4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017b8:	ee                   	out    %al,(%dx)
c01017b9:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017bf:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017c3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017c7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017cb:	ee                   	out    %al,(%dx)
c01017cc:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017d2:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017d6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017da:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017de:	ee                   	out    %al,(%dx)
c01017df:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017e5:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017e9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017ed:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017f1:	ee                   	out    %al,(%dx)
c01017f2:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017f8:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017fc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101800:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101804:	ee                   	out    %al,(%dx)
c0101805:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010180b:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c010180f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101813:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101817:	ee                   	out    %al,(%dx)
c0101818:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c010181e:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101822:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101826:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010182a:	ee                   	out    %al,(%dx)
c010182b:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101831:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0101835:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101839:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010183d:	ee                   	out    %al,(%dx)
c010183e:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101844:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c0101848:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010184c:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101850:	ee                   	out    %al,(%dx)
c0101851:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c0101857:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010185b:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010185f:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101863:	ee                   	out    %al,(%dx)
c0101864:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010186a:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c010186e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101872:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101876:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101877:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010187e:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101882:	74 12                	je     c0101896 <pic_init+0x139>
        pic_setmask(irq_mask);
c0101884:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c010188b:	0f b7 c0             	movzwl %ax,%eax
c010188e:	89 04 24             	mov    %eax,(%esp)
c0101891:	e8 41 fe ff ff       	call   c01016d7 <pic_setmask>
    }
}
c0101896:	c9                   	leave  
c0101897:	c3                   	ret    

c0101898 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101898:	55                   	push   %ebp
c0101899:	89 e5                	mov    %esp,%ebp
c010189b:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010189e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018a5:	00 
c01018a6:	c7 04 24 00 63 10 c0 	movl   $0xc0106300,(%esp)
c01018ad:	e8 a1 ea ff ff       	call   c0100353 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018b2:	c7 04 24 0a 63 10 c0 	movl   $0xc010630a,(%esp)
c01018b9:	e8 95 ea ff ff       	call   c0100353 <cprintf>
    panic("EOT: kernel seems ok.");
c01018be:	c7 44 24 08 18 63 10 	movl   $0xc0106318,0x8(%esp)
c01018c5:	c0 
c01018c6:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018cd:	00 
c01018ce:	c7 04 24 2e 63 10 c0 	movl   $0xc010632e,(%esp)
c01018d5:	e8 03 f4 ff ff       	call   c0100cdd <__panic>

c01018da <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018da:	55                   	push   %ebp
c01018db:	89 e5                	mov    %esp,%ebp
c01018dd:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018e7:	e9 c3 00 00 00       	jmp    c01019af <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ef:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018f6:	89 c2                	mov    %eax,%edx
c01018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fb:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c0101902:	c0 
c0101903:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101906:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c010190d:	c0 08 00 
c0101910:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101913:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010191a:	c0 
c010191b:	83 e2 e0             	and    $0xffffffe0,%edx
c010191e:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c0101925:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101928:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010192f:	c0 
c0101930:	83 e2 1f             	and    $0x1f,%edx
c0101933:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010193a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010193d:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101944:	c0 
c0101945:	83 e2 f0             	and    $0xfffffff0,%edx
c0101948:	83 ca 0e             	or     $0xe,%edx
c010194b:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101952:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101955:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010195c:	c0 
c010195d:	83 e2 ef             	and    $0xffffffef,%edx
c0101960:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101967:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101971:	c0 
c0101972:	83 e2 9f             	and    $0xffffff9f,%edx
c0101975:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010197c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197f:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101986:	c0 
c0101987:	83 ca 80             	or     $0xffffff80,%edx
c010198a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101994:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c010199b:	c1 e8 10             	shr    $0x10,%eax
c010199e:	89 c2                	mov    %eax,%edx
c01019a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a3:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c01019aa:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01019ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b2:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019b7:	0f 86 2f ff ff ff    	jbe    c01018ec <idt_init+0x12>
c01019bd:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01019c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01019c7:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c01019ca:	c9                   	leave  
c01019cb:	c3                   	ret    

c01019cc <trapname>:

static const char *
trapname(int trapno) {
c01019cc:	55                   	push   %ebp
c01019cd:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d2:	83 f8 13             	cmp    $0x13,%eax
c01019d5:	77 0c                	ja     c01019e3 <trapname+0x17>
        return excnames[trapno];
c01019d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01019da:	8b 04 85 80 66 10 c0 	mov    -0x3fef9980(,%eax,4),%eax
c01019e1:	eb 18                	jmp    c01019fb <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019e3:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019e7:	7e 0d                	jle    c01019f6 <trapname+0x2a>
c01019e9:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019ed:	7f 07                	jg     c01019f6 <trapname+0x2a>
        return "Hardware Interrupt";
c01019ef:	b8 3f 63 10 c0       	mov    $0xc010633f,%eax
c01019f4:	eb 05                	jmp    c01019fb <trapname+0x2f>
    }
    return "(unknown trap)";
c01019f6:	b8 52 63 10 c0       	mov    $0xc0106352,%eax
}
c01019fb:	5d                   	pop    %ebp
c01019fc:	c3                   	ret    

c01019fd <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019fd:	55                   	push   %ebp
c01019fe:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101a00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a03:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101a07:	66 83 f8 08          	cmp    $0x8,%ax
c0101a0b:	0f 94 c0             	sete   %al
c0101a0e:	0f b6 c0             	movzbl %al,%eax
}
c0101a11:	5d                   	pop    %ebp
c0101a12:	c3                   	ret    

c0101a13 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a13:	55                   	push   %ebp
c0101a14:	89 e5                	mov    %esp,%ebp
c0101a16:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a19:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a20:	c7 04 24 93 63 10 c0 	movl   $0xc0106393,(%esp)
c0101a27:	e8 27 e9 ff ff       	call   c0100353 <cprintf>
    print_regs(&tf->tf_regs);
c0101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a2f:	89 04 24             	mov    %eax,(%esp)
c0101a32:	e8 a1 01 00 00       	call   c0101bd8 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3a:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a3e:	0f b7 c0             	movzwl %ax,%eax
c0101a41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a45:	c7 04 24 a4 63 10 c0 	movl   $0xc01063a4,(%esp)
c0101a4c:	e8 02 e9 ff ff       	call   c0100353 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a54:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a58:	0f b7 c0             	movzwl %ax,%eax
c0101a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5f:	c7 04 24 b7 63 10 c0 	movl   $0xc01063b7,(%esp)
c0101a66:	e8 e8 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6e:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a72:	0f b7 c0             	movzwl %ax,%eax
c0101a75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a79:	c7 04 24 ca 63 10 c0 	movl   $0xc01063ca,(%esp)
c0101a80:	e8 ce e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a88:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a8c:	0f b7 c0             	movzwl %ax,%eax
c0101a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a93:	c7 04 24 dd 63 10 c0 	movl   $0xc01063dd,(%esp)
c0101a9a:	e8 b4 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aa2:	8b 40 30             	mov    0x30(%eax),%eax
c0101aa5:	89 04 24             	mov    %eax,(%esp)
c0101aa8:	e8 1f ff ff ff       	call   c01019cc <trapname>
c0101aad:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ab0:	8b 52 30             	mov    0x30(%edx),%edx
c0101ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101ab7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101abb:	c7 04 24 f0 63 10 c0 	movl   $0xc01063f0,(%esp)
c0101ac2:	e8 8c e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aca:	8b 40 34             	mov    0x34(%eax),%eax
c0101acd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad1:	c7 04 24 02 64 10 c0 	movl   $0xc0106402,(%esp)
c0101ad8:	e8 76 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101add:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae0:	8b 40 38             	mov    0x38(%eax),%eax
c0101ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae7:	c7 04 24 11 64 10 c0 	movl   $0xc0106411,(%esp)
c0101aee:	e8 60 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101afa:	0f b7 c0             	movzwl %ax,%eax
c0101afd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b01:	c7 04 24 20 64 10 c0 	movl   $0xc0106420,(%esp)
c0101b08:	e8 46 e8 ff ff       	call   c0100353 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b10:	8b 40 40             	mov    0x40(%eax),%eax
c0101b13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b17:	c7 04 24 33 64 10 c0 	movl   $0xc0106433,(%esp)
c0101b1e:	e8 30 e8 ff ff       	call   c0100353 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b2a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b31:	eb 3e                	jmp    c0101b71 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b33:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b36:	8b 50 40             	mov    0x40(%eax),%edx
c0101b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b3c:	21 d0                	and    %edx,%eax
c0101b3e:	85 c0                	test   %eax,%eax
c0101b40:	74 28                	je     c0101b6a <print_trapframe+0x157>
c0101b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b45:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b4c:	85 c0                	test   %eax,%eax
c0101b4e:	74 1a                	je     c0101b6a <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b53:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b5e:	c7 04 24 42 64 10 c0 	movl   $0xc0106442,(%esp)
c0101b65:	e8 e9 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101b6e:	d1 65 f0             	shll   -0x10(%ebp)
c0101b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b74:	83 f8 17             	cmp    $0x17,%eax
c0101b77:	76 ba                	jbe    c0101b33 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7c:	8b 40 40             	mov    0x40(%eax),%eax
c0101b7f:	25 00 30 00 00       	and    $0x3000,%eax
c0101b84:	c1 e8 0c             	shr    $0xc,%eax
c0101b87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b8b:	c7 04 24 46 64 10 c0 	movl   $0xc0106446,(%esp)
c0101b92:	e8 bc e7 ff ff       	call   c0100353 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b97:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9a:	89 04 24             	mov    %eax,(%esp)
c0101b9d:	e8 5b fe ff ff       	call   c01019fd <trap_in_kernel>
c0101ba2:	85 c0                	test   %eax,%eax
c0101ba4:	75 30                	jne    c0101bd6 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba9:	8b 40 44             	mov    0x44(%eax),%eax
c0101bac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bb0:	c7 04 24 4f 64 10 c0 	movl   $0xc010644f,(%esp)
c0101bb7:	e8 97 e7 ff ff       	call   c0100353 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbf:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101bc3:	0f b7 c0             	movzwl %ax,%eax
c0101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bca:	c7 04 24 5e 64 10 c0 	movl   $0xc010645e,(%esp)
c0101bd1:	e8 7d e7 ff ff       	call   c0100353 <cprintf>
    }
}
c0101bd6:	c9                   	leave  
c0101bd7:	c3                   	ret    

c0101bd8 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101bd8:	55                   	push   %ebp
c0101bd9:	89 e5                	mov    %esp,%ebp
c0101bdb:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101bde:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be1:	8b 00                	mov    (%eax),%eax
c0101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be7:	c7 04 24 71 64 10 c0 	movl   $0xc0106471,(%esp)
c0101bee:	e8 60 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf6:	8b 40 04             	mov    0x4(%eax),%eax
c0101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bfd:	c7 04 24 80 64 10 c0 	movl   $0xc0106480,(%esp)
c0101c04:	e8 4a e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101c09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0c:	8b 40 08             	mov    0x8(%eax),%eax
c0101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c13:	c7 04 24 8f 64 10 c0 	movl   $0xc010648f,(%esp)
c0101c1a:	e8 34 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c22:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c29:	c7 04 24 9e 64 10 c0 	movl   $0xc010649e,(%esp)
c0101c30:	e8 1e e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c38:	8b 40 10             	mov    0x10(%eax),%eax
c0101c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c3f:	c7 04 24 ad 64 10 c0 	movl   $0xc01064ad,(%esp)
c0101c46:	e8 08 e7 ff ff       	call   c0100353 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c4e:	8b 40 14             	mov    0x14(%eax),%eax
c0101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c55:	c7 04 24 bc 64 10 c0 	movl   $0xc01064bc,(%esp)
c0101c5c:	e8 f2 e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c64:	8b 40 18             	mov    0x18(%eax),%eax
c0101c67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c6b:	c7 04 24 cb 64 10 c0 	movl   $0xc01064cb,(%esp)
c0101c72:	e8 dc e6 ff ff       	call   c0100353 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c7d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c81:	c7 04 24 da 64 10 c0 	movl   $0xc01064da,(%esp)
c0101c88:	e8 c6 e6 ff ff       	call   c0100353 <cprintf>
}
c0101c8d:	c9                   	leave  
c0101c8e:	c3                   	ret    

c0101c8f <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c8f:	55                   	push   %ebp
c0101c90:	89 e5                	mov    %esp,%ebp
c0101c92:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c98:	8b 40 30             	mov    0x30(%eax),%eax
c0101c9b:	83 f8 2f             	cmp    $0x2f,%eax
c0101c9e:	77 21                	ja     c0101cc1 <trap_dispatch+0x32>
c0101ca0:	83 f8 2e             	cmp    $0x2e,%eax
c0101ca3:	0f 83 04 01 00 00    	jae    c0101dad <trap_dispatch+0x11e>
c0101ca9:	83 f8 21             	cmp    $0x21,%eax
c0101cac:	0f 84 81 00 00 00    	je     c0101d33 <trap_dispatch+0xa4>
c0101cb2:	83 f8 24             	cmp    $0x24,%eax
c0101cb5:	74 56                	je     c0101d0d <trap_dispatch+0x7e>
c0101cb7:	83 f8 20             	cmp    $0x20,%eax
c0101cba:	74 16                	je     c0101cd2 <trap_dispatch+0x43>
c0101cbc:	e9 b4 00 00 00       	jmp    c0101d75 <trap_dispatch+0xe6>
c0101cc1:	83 e8 78             	sub    $0x78,%eax
c0101cc4:	83 f8 01             	cmp    $0x1,%eax
c0101cc7:	0f 87 a8 00 00 00    	ja     c0101d75 <trap_dispatch+0xe6>
c0101ccd:	e9 87 00 00 00       	jmp    c0101d59 <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101cd2:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101cd7:	83 c0 01             	add    $0x1,%eax
c0101cda:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101cdf:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101ce5:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cea:	89 c8                	mov    %ecx,%eax
c0101cec:	f7 e2                	mul    %edx
c0101cee:	89 d0                	mov    %edx,%eax
c0101cf0:	c1 e8 05             	shr    $0x5,%eax
c0101cf3:	6b c0 64             	imul   $0x64,%eax,%eax
c0101cf6:	29 c1                	sub    %eax,%ecx
c0101cf8:	89 c8                	mov    %ecx,%eax
c0101cfa:	85 c0                	test   %eax,%eax
c0101cfc:	75 0a                	jne    c0101d08 <trap_dispatch+0x79>
            print_ticks();
c0101cfe:	e8 95 fb ff ff       	call   c0101898 <print_ticks>
        }
        break;
c0101d03:	e9 a6 00 00 00       	jmp    c0101dae <trap_dispatch+0x11f>
c0101d08:	e9 a1 00 00 00       	jmp    c0101dae <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d0d:	e8 4a f9 ff ff       	call   c010165c <cons_getc>
c0101d12:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d15:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d19:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d1d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d25:	c7 04 24 e9 64 10 c0 	movl   $0xc01064e9,(%esp)
c0101d2c:	e8 22 e6 ff ff       	call   c0100353 <cprintf>
        break;
c0101d31:	eb 7b                	jmp    c0101dae <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d33:	e8 24 f9 ff ff       	call   c010165c <cons_getc>
c0101d38:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d3b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d3f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d43:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d4b:	c7 04 24 fb 64 10 c0 	movl   $0xc01064fb,(%esp)
c0101d52:	e8 fc e5 ff ff       	call   c0100353 <cprintf>
        break;
c0101d57:	eb 55                	jmp    c0101dae <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d59:	c7 44 24 08 0a 65 10 	movl   $0xc010650a,0x8(%esp)
c0101d60:	c0 
c0101d61:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101d68:	00 
c0101d69:	c7 04 24 2e 63 10 c0 	movl   $0xc010632e,(%esp)
c0101d70:	e8 68 ef ff ff       	call   c0100cdd <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d78:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d7c:	0f b7 c0             	movzwl %ax,%eax
c0101d7f:	83 e0 03             	and    $0x3,%eax
c0101d82:	85 c0                	test   %eax,%eax
c0101d84:	75 28                	jne    c0101dae <trap_dispatch+0x11f>
            print_trapframe(tf);
c0101d86:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d89:	89 04 24             	mov    %eax,(%esp)
c0101d8c:	e8 82 fc ff ff       	call   c0101a13 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d91:	c7 44 24 08 1a 65 10 	movl   $0xc010651a,0x8(%esp)
c0101d98:	c0 
c0101d99:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101da0:	00 
c0101da1:	c7 04 24 2e 63 10 c0 	movl   $0xc010632e,(%esp)
c0101da8:	e8 30 ef ff ff       	call   c0100cdd <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101dad:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101dae:	c9                   	leave  
c0101daf:	c3                   	ret    

c0101db0 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101db0:	55                   	push   %ebp
c0101db1:	89 e5                	mov    %esp,%ebp
c0101db3:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db9:	89 04 24             	mov    %eax,(%esp)
c0101dbc:	e8 ce fe ff ff       	call   c0101c8f <trap_dispatch>
}
c0101dc1:	c9                   	leave  
c0101dc2:	c3                   	ret    

c0101dc3 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101dc3:	1e                   	push   %ds
    pushl %es
c0101dc4:	06                   	push   %es
    pushl %fs
c0101dc5:	0f a0                	push   %fs
    pushl %gs
c0101dc7:	0f a8                	push   %gs
    pushal
c0101dc9:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101dca:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101dcf:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101dd1:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101dd3:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101dd4:	e8 d7 ff ff ff       	call   c0101db0 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101dd9:	5c                   	pop    %esp

c0101dda <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101dda:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101ddb:	0f a9                	pop    %gs
    popl %fs
c0101ddd:	0f a1                	pop    %fs
    popl %es
c0101ddf:	07                   	pop    %es
    popl %ds
c0101de0:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101de1:	83 c4 08             	add    $0x8,%esp
    iret
c0101de4:	cf                   	iret   

c0101de5 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101de5:	6a 00                	push   $0x0
  pushl $0
c0101de7:	6a 00                	push   $0x0
  jmp __alltraps
c0101de9:	e9 d5 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101dee <vector1>:
.globl vector1
vector1:
  pushl $0
c0101dee:	6a 00                	push   $0x0
  pushl $1
c0101df0:	6a 01                	push   $0x1
  jmp __alltraps
c0101df2:	e9 cc ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101df7 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101df7:	6a 00                	push   $0x0
  pushl $2
c0101df9:	6a 02                	push   $0x2
  jmp __alltraps
c0101dfb:	e9 c3 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e00 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101e00:	6a 00                	push   $0x0
  pushl $3
c0101e02:	6a 03                	push   $0x3
  jmp __alltraps
c0101e04:	e9 ba ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e09 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101e09:	6a 00                	push   $0x0
  pushl $4
c0101e0b:	6a 04                	push   $0x4
  jmp __alltraps
c0101e0d:	e9 b1 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e12 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e12:	6a 00                	push   $0x0
  pushl $5
c0101e14:	6a 05                	push   $0x5
  jmp __alltraps
c0101e16:	e9 a8 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e1b <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e1b:	6a 00                	push   $0x0
  pushl $6
c0101e1d:	6a 06                	push   $0x6
  jmp __alltraps
c0101e1f:	e9 9f ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e24 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e24:	6a 00                	push   $0x0
  pushl $7
c0101e26:	6a 07                	push   $0x7
  jmp __alltraps
c0101e28:	e9 96 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e2d <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e2d:	6a 08                	push   $0x8
  jmp __alltraps
c0101e2f:	e9 8f ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e34 <vector9>:
.globl vector9
vector9:
  pushl $0
c0101e34:	6a 00                	push   $0x0
  pushl $9
c0101e36:	6a 09                	push   $0x9
  jmp __alltraps
c0101e38:	e9 86 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e3d <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e3d:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e3f:	e9 7f ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e44 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e44:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e46:	e9 78 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e4b <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e4b:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e4d:	e9 71 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e52 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e52:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e54:	e9 6a ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e59 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e59:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e5b:	e9 63 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e60 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e60:	6a 00                	push   $0x0
  pushl $15
c0101e62:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e64:	e9 5a ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e69 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $16
c0101e6b:	6a 10                	push   $0x10
  jmp __alltraps
c0101e6d:	e9 51 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e72 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e72:	6a 11                	push   $0x11
  jmp __alltraps
c0101e74:	e9 4a ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e79 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e79:	6a 00                	push   $0x0
  pushl $18
c0101e7b:	6a 12                	push   $0x12
  jmp __alltraps
c0101e7d:	e9 41 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e82 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e82:	6a 00                	push   $0x0
  pushl $19
c0101e84:	6a 13                	push   $0x13
  jmp __alltraps
c0101e86:	e9 38 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e8b <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e8b:	6a 00                	push   $0x0
  pushl $20
c0101e8d:	6a 14                	push   $0x14
  jmp __alltraps
c0101e8f:	e9 2f ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e94 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e94:	6a 00                	push   $0x0
  pushl $21
c0101e96:	6a 15                	push   $0x15
  jmp __alltraps
c0101e98:	e9 26 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101e9d <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e9d:	6a 00                	push   $0x0
  pushl $22
c0101e9f:	6a 16                	push   $0x16
  jmp __alltraps
c0101ea1:	e9 1d ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101ea6 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101ea6:	6a 00                	push   $0x0
  pushl $23
c0101ea8:	6a 17                	push   $0x17
  jmp __alltraps
c0101eaa:	e9 14 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101eaf <vector24>:
.globl vector24
vector24:
  pushl $0
c0101eaf:	6a 00                	push   $0x0
  pushl $24
c0101eb1:	6a 18                	push   $0x18
  jmp __alltraps
c0101eb3:	e9 0b ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101eb8 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101eb8:	6a 00                	push   $0x0
  pushl $25
c0101eba:	6a 19                	push   $0x19
  jmp __alltraps
c0101ebc:	e9 02 ff ff ff       	jmp    c0101dc3 <__alltraps>

c0101ec1 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101ec1:	6a 00                	push   $0x0
  pushl $26
c0101ec3:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101ec5:	e9 f9 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101eca <vector27>:
.globl vector27
vector27:
  pushl $0
c0101eca:	6a 00                	push   $0x0
  pushl $27
c0101ecc:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101ece:	e9 f0 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101ed3 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101ed3:	6a 00                	push   $0x0
  pushl $28
c0101ed5:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ed7:	e9 e7 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101edc <vector29>:
.globl vector29
vector29:
  pushl $0
c0101edc:	6a 00                	push   $0x0
  pushl $29
c0101ede:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101ee0:	e9 de fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101ee5 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101ee5:	6a 00                	push   $0x0
  pushl $30
c0101ee7:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101ee9:	e9 d5 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101eee <vector31>:
.globl vector31
vector31:
  pushl $0
c0101eee:	6a 00                	push   $0x0
  pushl $31
c0101ef0:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ef2:	e9 cc fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101ef7 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ef7:	6a 00                	push   $0x0
  pushl $32
c0101ef9:	6a 20                	push   $0x20
  jmp __alltraps
c0101efb:	e9 c3 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f00 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101f00:	6a 00                	push   $0x0
  pushl $33
c0101f02:	6a 21                	push   $0x21
  jmp __alltraps
c0101f04:	e9 ba fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f09 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101f09:	6a 00                	push   $0x0
  pushl $34
c0101f0b:	6a 22                	push   $0x22
  jmp __alltraps
c0101f0d:	e9 b1 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f12 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f12:	6a 00                	push   $0x0
  pushl $35
c0101f14:	6a 23                	push   $0x23
  jmp __alltraps
c0101f16:	e9 a8 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f1b <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f1b:	6a 00                	push   $0x0
  pushl $36
c0101f1d:	6a 24                	push   $0x24
  jmp __alltraps
c0101f1f:	e9 9f fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f24 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f24:	6a 00                	push   $0x0
  pushl $37
c0101f26:	6a 25                	push   $0x25
  jmp __alltraps
c0101f28:	e9 96 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f2d <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f2d:	6a 00                	push   $0x0
  pushl $38
c0101f2f:	6a 26                	push   $0x26
  jmp __alltraps
c0101f31:	e9 8d fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f36 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f36:	6a 00                	push   $0x0
  pushl $39
c0101f38:	6a 27                	push   $0x27
  jmp __alltraps
c0101f3a:	e9 84 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f3f <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f3f:	6a 00                	push   $0x0
  pushl $40
c0101f41:	6a 28                	push   $0x28
  jmp __alltraps
c0101f43:	e9 7b fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f48 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f48:	6a 00                	push   $0x0
  pushl $41
c0101f4a:	6a 29                	push   $0x29
  jmp __alltraps
c0101f4c:	e9 72 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f51 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f51:	6a 00                	push   $0x0
  pushl $42
c0101f53:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f55:	e9 69 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f5a <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f5a:	6a 00                	push   $0x0
  pushl $43
c0101f5c:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f5e:	e9 60 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f63 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f63:	6a 00                	push   $0x0
  pushl $44
c0101f65:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f67:	e9 57 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f6c <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f6c:	6a 00                	push   $0x0
  pushl $45
c0101f6e:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f70:	e9 4e fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f75 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f75:	6a 00                	push   $0x0
  pushl $46
c0101f77:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f79:	e9 45 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f7e <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f7e:	6a 00                	push   $0x0
  pushl $47
c0101f80:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f82:	e9 3c fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f87 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f87:	6a 00                	push   $0x0
  pushl $48
c0101f89:	6a 30                	push   $0x30
  jmp __alltraps
c0101f8b:	e9 33 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f90 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f90:	6a 00                	push   $0x0
  pushl $49
c0101f92:	6a 31                	push   $0x31
  jmp __alltraps
c0101f94:	e9 2a fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101f99 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f99:	6a 00                	push   $0x0
  pushl $50
c0101f9b:	6a 32                	push   $0x32
  jmp __alltraps
c0101f9d:	e9 21 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101fa2 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101fa2:	6a 00                	push   $0x0
  pushl $51
c0101fa4:	6a 33                	push   $0x33
  jmp __alltraps
c0101fa6:	e9 18 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101fab <vector52>:
.globl vector52
vector52:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $52
c0101fad:	6a 34                	push   $0x34
  jmp __alltraps
c0101faf:	e9 0f fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101fb4 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fb4:	6a 00                	push   $0x0
  pushl $53
c0101fb6:	6a 35                	push   $0x35
  jmp __alltraps
c0101fb8:	e9 06 fe ff ff       	jmp    c0101dc3 <__alltraps>

c0101fbd <vector54>:
.globl vector54
vector54:
  pushl $0
c0101fbd:	6a 00                	push   $0x0
  pushl $54
c0101fbf:	6a 36                	push   $0x36
  jmp __alltraps
c0101fc1:	e9 fd fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101fc6 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101fc6:	6a 00                	push   $0x0
  pushl $55
c0101fc8:	6a 37                	push   $0x37
  jmp __alltraps
c0101fca:	e9 f4 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101fcf <vector56>:
.globl vector56
vector56:
  pushl $0
c0101fcf:	6a 00                	push   $0x0
  pushl $56
c0101fd1:	6a 38                	push   $0x38
  jmp __alltraps
c0101fd3:	e9 eb fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101fd8 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101fd8:	6a 00                	push   $0x0
  pushl $57
c0101fda:	6a 39                	push   $0x39
  jmp __alltraps
c0101fdc:	e9 e2 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101fe1 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fe1:	6a 00                	push   $0x0
  pushl $58
c0101fe3:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101fe5:	e9 d9 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101fea <vector59>:
.globl vector59
vector59:
  pushl $0
c0101fea:	6a 00                	push   $0x0
  pushl $59
c0101fec:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fee:	e9 d0 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101ff3 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101ff3:	6a 00                	push   $0x0
  pushl $60
c0101ff5:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101ff7:	e9 c7 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0101ffc <vector61>:
.globl vector61
vector61:
  pushl $0
c0101ffc:	6a 00                	push   $0x0
  pushl $61
c0101ffe:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102000:	e9 be fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102005 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102005:	6a 00                	push   $0x0
  pushl $62
c0102007:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102009:	e9 b5 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010200e <vector63>:
.globl vector63
vector63:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $63
c0102010:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102012:	e9 ac fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102017 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $64
c0102019:	6a 40                	push   $0x40
  jmp __alltraps
c010201b:	e9 a3 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102020 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $65
c0102022:	6a 41                	push   $0x41
  jmp __alltraps
c0102024:	e9 9a fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102029 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $66
c010202b:	6a 42                	push   $0x42
  jmp __alltraps
c010202d:	e9 91 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102032 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $67
c0102034:	6a 43                	push   $0x43
  jmp __alltraps
c0102036:	e9 88 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010203b <vector68>:
.globl vector68
vector68:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $68
c010203d:	6a 44                	push   $0x44
  jmp __alltraps
c010203f:	e9 7f fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102044 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $69
c0102046:	6a 45                	push   $0x45
  jmp __alltraps
c0102048:	e9 76 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010204d <vector70>:
.globl vector70
vector70:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $70
c010204f:	6a 46                	push   $0x46
  jmp __alltraps
c0102051:	e9 6d fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102056 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102056:	6a 00                	push   $0x0
  pushl $71
c0102058:	6a 47                	push   $0x47
  jmp __alltraps
c010205a:	e9 64 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010205f <vector72>:
.globl vector72
vector72:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $72
c0102061:	6a 48                	push   $0x48
  jmp __alltraps
c0102063:	e9 5b fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102068 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $73
c010206a:	6a 49                	push   $0x49
  jmp __alltraps
c010206c:	e9 52 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102071 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102071:	6a 00                	push   $0x0
  pushl $74
c0102073:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102075:	e9 49 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010207a <vector75>:
.globl vector75
vector75:
  pushl $0
c010207a:	6a 00                	push   $0x0
  pushl $75
c010207c:	6a 4b                	push   $0x4b
  jmp __alltraps
c010207e:	e9 40 fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102083 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102083:	6a 00                	push   $0x0
  pushl $76
c0102085:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102087:	e9 37 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010208c <vector77>:
.globl vector77
vector77:
  pushl $0
c010208c:	6a 00                	push   $0x0
  pushl $77
c010208e:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102090:	e9 2e fd ff ff       	jmp    c0101dc3 <__alltraps>

c0102095 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102095:	6a 00                	push   $0x0
  pushl $78
c0102097:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102099:	e9 25 fd ff ff       	jmp    c0101dc3 <__alltraps>

c010209e <vector79>:
.globl vector79
vector79:
  pushl $0
c010209e:	6a 00                	push   $0x0
  pushl $79
c01020a0:	6a 4f                	push   $0x4f
  jmp __alltraps
c01020a2:	e9 1c fd ff ff       	jmp    c0101dc3 <__alltraps>

c01020a7 <vector80>:
.globl vector80
vector80:
  pushl $0
c01020a7:	6a 00                	push   $0x0
  pushl $80
c01020a9:	6a 50                	push   $0x50
  jmp __alltraps
c01020ab:	e9 13 fd ff ff       	jmp    c0101dc3 <__alltraps>

c01020b0 <vector81>:
.globl vector81
vector81:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $81
c01020b2:	6a 51                	push   $0x51
  jmp __alltraps
c01020b4:	e9 0a fd ff ff       	jmp    c0101dc3 <__alltraps>

c01020b9 <vector82>:
.globl vector82
vector82:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $82
c01020bb:	6a 52                	push   $0x52
  jmp __alltraps
c01020bd:	e9 01 fd ff ff       	jmp    c0101dc3 <__alltraps>

c01020c2 <vector83>:
.globl vector83
vector83:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $83
c01020c4:	6a 53                	push   $0x53
  jmp __alltraps
c01020c6:	e9 f8 fc ff ff       	jmp    c0101dc3 <__alltraps>

c01020cb <vector84>:
.globl vector84
vector84:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $84
c01020cd:	6a 54                	push   $0x54
  jmp __alltraps
c01020cf:	e9 ef fc ff ff       	jmp    c0101dc3 <__alltraps>

c01020d4 <vector85>:
.globl vector85
vector85:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $85
c01020d6:	6a 55                	push   $0x55
  jmp __alltraps
c01020d8:	e9 e6 fc ff ff       	jmp    c0101dc3 <__alltraps>

c01020dd <vector86>:
.globl vector86
vector86:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $86
c01020df:	6a 56                	push   $0x56
  jmp __alltraps
c01020e1:	e9 dd fc ff ff       	jmp    c0101dc3 <__alltraps>

c01020e6 <vector87>:
.globl vector87
vector87:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $87
c01020e8:	6a 57                	push   $0x57
  jmp __alltraps
c01020ea:	e9 d4 fc ff ff       	jmp    c0101dc3 <__alltraps>

c01020ef <vector88>:
.globl vector88
vector88:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $88
c01020f1:	6a 58                	push   $0x58
  jmp __alltraps
c01020f3:	e9 cb fc ff ff       	jmp    c0101dc3 <__alltraps>

c01020f8 <vector89>:
.globl vector89
vector89:
  pushl $0
c01020f8:	6a 00                	push   $0x0
  pushl $89
c01020fa:	6a 59                	push   $0x59
  jmp __alltraps
c01020fc:	e9 c2 fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102101 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102101:	6a 00                	push   $0x0
  pushl $90
c0102103:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102105:	e9 b9 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010210a <vector91>:
.globl vector91
vector91:
  pushl $0
c010210a:	6a 00                	push   $0x0
  pushl $91
c010210c:	6a 5b                	push   $0x5b
  jmp __alltraps
c010210e:	e9 b0 fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102113 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102113:	6a 00                	push   $0x0
  pushl $92
c0102115:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102117:	e9 a7 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010211c <vector93>:
.globl vector93
vector93:
  pushl $0
c010211c:	6a 00                	push   $0x0
  pushl $93
c010211e:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102120:	e9 9e fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102125 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102125:	6a 00                	push   $0x0
  pushl $94
c0102127:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102129:	e9 95 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010212e <vector95>:
.globl vector95
vector95:
  pushl $0
c010212e:	6a 00                	push   $0x0
  pushl $95
c0102130:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102132:	e9 8c fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102137 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102137:	6a 00                	push   $0x0
  pushl $96
c0102139:	6a 60                	push   $0x60
  jmp __alltraps
c010213b:	e9 83 fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102140 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102140:	6a 00                	push   $0x0
  pushl $97
c0102142:	6a 61                	push   $0x61
  jmp __alltraps
c0102144:	e9 7a fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102149 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102149:	6a 00                	push   $0x0
  pushl $98
c010214b:	6a 62                	push   $0x62
  jmp __alltraps
c010214d:	e9 71 fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102152 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102152:	6a 00                	push   $0x0
  pushl $99
c0102154:	6a 63                	push   $0x63
  jmp __alltraps
c0102156:	e9 68 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010215b <vector100>:
.globl vector100
vector100:
  pushl $0
c010215b:	6a 00                	push   $0x0
  pushl $100
c010215d:	6a 64                	push   $0x64
  jmp __alltraps
c010215f:	e9 5f fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102164 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102164:	6a 00                	push   $0x0
  pushl $101
c0102166:	6a 65                	push   $0x65
  jmp __alltraps
c0102168:	e9 56 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010216d <vector102>:
.globl vector102
vector102:
  pushl $0
c010216d:	6a 00                	push   $0x0
  pushl $102
c010216f:	6a 66                	push   $0x66
  jmp __alltraps
c0102171:	e9 4d fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102176 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102176:	6a 00                	push   $0x0
  pushl $103
c0102178:	6a 67                	push   $0x67
  jmp __alltraps
c010217a:	e9 44 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010217f <vector104>:
.globl vector104
vector104:
  pushl $0
c010217f:	6a 00                	push   $0x0
  pushl $104
c0102181:	6a 68                	push   $0x68
  jmp __alltraps
c0102183:	e9 3b fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102188 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102188:	6a 00                	push   $0x0
  pushl $105
c010218a:	6a 69                	push   $0x69
  jmp __alltraps
c010218c:	e9 32 fc ff ff       	jmp    c0101dc3 <__alltraps>

c0102191 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102191:	6a 00                	push   $0x0
  pushl $106
c0102193:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102195:	e9 29 fc ff ff       	jmp    c0101dc3 <__alltraps>

c010219a <vector107>:
.globl vector107
vector107:
  pushl $0
c010219a:	6a 00                	push   $0x0
  pushl $107
c010219c:	6a 6b                	push   $0x6b
  jmp __alltraps
c010219e:	e9 20 fc ff ff       	jmp    c0101dc3 <__alltraps>

c01021a3 <vector108>:
.globl vector108
vector108:
  pushl $0
c01021a3:	6a 00                	push   $0x0
  pushl $108
c01021a5:	6a 6c                	push   $0x6c
  jmp __alltraps
c01021a7:	e9 17 fc ff ff       	jmp    c0101dc3 <__alltraps>

c01021ac <vector109>:
.globl vector109
vector109:
  pushl $0
c01021ac:	6a 00                	push   $0x0
  pushl $109
c01021ae:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021b0:	e9 0e fc ff ff       	jmp    c0101dc3 <__alltraps>

c01021b5 <vector110>:
.globl vector110
vector110:
  pushl $0
c01021b5:	6a 00                	push   $0x0
  pushl $110
c01021b7:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021b9:	e9 05 fc ff ff       	jmp    c0101dc3 <__alltraps>

c01021be <vector111>:
.globl vector111
vector111:
  pushl $0
c01021be:	6a 00                	push   $0x0
  pushl $111
c01021c0:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021c2:	e9 fc fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021c7 <vector112>:
.globl vector112
vector112:
  pushl $0
c01021c7:	6a 00                	push   $0x0
  pushl $112
c01021c9:	6a 70                	push   $0x70
  jmp __alltraps
c01021cb:	e9 f3 fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021d0 <vector113>:
.globl vector113
vector113:
  pushl $0
c01021d0:	6a 00                	push   $0x0
  pushl $113
c01021d2:	6a 71                	push   $0x71
  jmp __alltraps
c01021d4:	e9 ea fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021d9 <vector114>:
.globl vector114
vector114:
  pushl $0
c01021d9:	6a 00                	push   $0x0
  pushl $114
c01021db:	6a 72                	push   $0x72
  jmp __alltraps
c01021dd:	e9 e1 fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021e2 <vector115>:
.globl vector115
vector115:
  pushl $0
c01021e2:	6a 00                	push   $0x0
  pushl $115
c01021e4:	6a 73                	push   $0x73
  jmp __alltraps
c01021e6:	e9 d8 fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021eb <vector116>:
.globl vector116
vector116:
  pushl $0
c01021eb:	6a 00                	push   $0x0
  pushl $116
c01021ed:	6a 74                	push   $0x74
  jmp __alltraps
c01021ef:	e9 cf fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021f4 <vector117>:
.globl vector117
vector117:
  pushl $0
c01021f4:	6a 00                	push   $0x0
  pushl $117
c01021f6:	6a 75                	push   $0x75
  jmp __alltraps
c01021f8:	e9 c6 fb ff ff       	jmp    c0101dc3 <__alltraps>

c01021fd <vector118>:
.globl vector118
vector118:
  pushl $0
c01021fd:	6a 00                	push   $0x0
  pushl $118
c01021ff:	6a 76                	push   $0x76
  jmp __alltraps
c0102201:	e9 bd fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102206 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $119
c0102208:	6a 77                	push   $0x77
  jmp __alltraps
c010220a:	e9 b4 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010220f <vector120>:
.globl vector120
vector120:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $120
c0102211:	6a 78                	push   $0x78
  jmp __alltraps
c0102213:	e9 ab fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102218 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102218:	6a 00                	push   $0x0
  pushl $121
c010221a:	6a 79                	push   $0x79
  jmp __alltraps
c010221c:	e9 a2 fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102221 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $122
c0102223:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102225:	e9 99 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010222a <vector123>:
.globl vector123
vector123:
  pushl $0
c010222a:	6a 00                	push   $0x0
  pushl $123
c010222c:	6a 7b                	push   $0x7b
  jmp __alltraps
c010222e:	e9 90 fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102233 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102233:	6a 00                	push   $0x0
  pushl $124
c0102235:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102237:	e9 87 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010223c <vector125>:
.globl vector125
vector125:
  pushl $0
c010223c:	6a 00                	push   $0x0
  pushl $125
c010223e:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102240:	e9 7e fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102245 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $126
c0102247:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102249:	e9 75 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010224e <vector127>:
.globl vector127
vector127:
  pushl $0
c010224e:	6a 00                	push   $0x0
  pushl $127
c0102250:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102252:	e9 6c fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102257 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102257:	6a 00                	push   $0x0
  pushl $128
c0102259:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010225e:	e9 60 fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102263 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102263:	6a 00                	push   $0x0
  pushl $129
c0102265:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010226a:	e9 54 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010226f <vector130>:
.globl vector130
vector130:
  pushl $0
c010226f:	6a 00                	push   $0x0
  pushl $130
c0102271:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102276:	e9 48 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010227b <vector131>:
.globl vector131
vector131:
  pushl $0
c010227b:	6a 00                	push   $0x0
  pushl $131
c010227d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102282:	e9 3c fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102287 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102287:	6a 00                	push   $0x0
  pushl $132
c0102289:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010228e:	e9 30 fb ff ff       	jmp    c0101dc3 <__alltraps>

c0102293 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102293:	6a 00                	push   $0x0
  pushl $133
c0102295:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010229a:	e9 24 fb ff ff       	jmp    c0101dc3 <__alltraps>

c010229f <vector134>:
.globl vector134
vector134:
  pushl $0
c010229f:	6a 00                	push   $0x0
  pushl $134
c01022a1:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01022a6:	e9 18 fb ff ff       	jmp    c0101dc3 <__alltraps>

c01022ab <vector135>:
.globl vector135
vector135:
  pushl $0
c01022ab:	6a 00                	push   $0x0
  pushl $135
c01022ad:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022b2:	e9 0c fb ff ff       	jmp    c0101dc3 <__alltraps>

c01022b7 <vector136>:
.globl vector136
vector136:
  pushl $0
c01022b7:	6a 00                	push   $0x0
  pushl $136
c01022b9:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022be:	e9 00 fb ff ff       	jmp    c0101dc3 <__alltraps>

c01022c3 <vector137>:
.globl vector137
vector137:
  pushl $0
c01022c3:	6a 00                	push   $0x0
  pushl $137
c01022c5:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01022ca:	e9 f4 fa ff ff       	jmp    c0101dc3 <__alltraps>

c01022cf <vector138>:
.globl vector138
vector138:
  pushl $0
c01022cf:	6a 00                	push   $0x0
  pushl $138
c01022d1:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022d6:	e9 e8 fa ff ff       	jmp    c0101dc3 <__alltraps>

c01022db <vector139>:
.globl vector139
vector139:
  pushl $0
c01022db:	6a 00                	push   $0x0
  pushl $139
c01022dd:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022e2:	e9 dc fa ff ff       	jmp    c0101dc3 <__alltraps>

c01022e7 <vector140>:
.globl vector140
vector140:
  pushl $0
c01022e7:	6a 00                	push   $0x0
  pushl $140
c01022e9:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022ee:	e9 d0 fa ff ff       	jmp    c0101dc3 <__alltraps>

c01022f3 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022f3:	6a 00                	push   $0x0
  pushl $141
c01022f5:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022fa:	e9 c4 fa ff ff       	jmp    c0101dc3 <__alltraps>

c01022ff <vector142>:
.globl vector142
vector142:
  pushl $0
c01022ff:	6a 00                	push   $0x0
  pushl $142
c0102301:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102306:	e9 b8 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010230b <vector143>:
.globl vector143
vector143:
  pushl $0
c010230b:	6a 00                	push   $0x0
  pushl $143
c010230d:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102312:	e9 ac fa ff ff       	jmp    c0101dc3 <__alltraps>

c0102317 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102317:	6a 00                	push   $0x0
  pushl $144
c0102319:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010231e:	e9 a0 fa ff ff       	jmp    c0101dc3 <__alltraps>

c0102323 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102323:	6a 00                	push   $0x0
  pushl $145
c0102325:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010232a:	e9 94 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010232f <vector146>:
.globl vector146
vector146:
  pushl $0
c010232f:	6a 00                	push   $0x0
  pushl $146
c0102331:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102336:	e9 88 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010233b <vector147>:
.globl vector147
vector147:
  pushl $0
c010233b:	6a 00                	push   $0x0
  pushl $147
c010233d:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102342:	e9 7c fa ff ff       	jmp    c0101dc3 <__alltraps>

c0102347 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102347:	6a 00                	push   $0x0
  pushl $148
c0102349:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010234e:	e9 70 fa ff ff       	jmp    c0101dc3 <__alltraps>

c0102353 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102353:	6a 00                	push   $0x0
  pushl $149
c0102355:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010235a:	e9 64 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010235f <vector150>:
.globl vector150
vector150:
  pushl $0
c010235f:	6a 00                	push   $0x0
  pushl $150
c0102361:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102366:	e9 58 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010236b <vector151>:
.globl vector151
vector151:
  pushl $0
c010236b:	6a 00                	push   $0x0
  pushl $151
c010236d:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102372:	e9 4c fa ff ff       	jmp    c0101dc3 <__alltraps>

c0102377 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102377:	6a 00                	push   $0x0
  pushl $152
c0102379:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010237e:	e9 40 fa ff ff       	jmp    c0101dc3 <__alltraps>

c0102383 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102383:	6a 00                	push   $0x0
  pushl $153
c0102385:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010238a:	e9 34 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010238f <vector154>:
.globl vector154
vector154:
  pushl $0
c010238f:	6a 00                	push   $0x0
  pushl $154
c0102391:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102396:	e9 28 fa ff ff       	jmp    c0101dc3 <__alltraps>

c010239b <vector155>:
.globl vector155
vector155:
  pushl $0
c010239b:	6a 00                	push   $0x0
  pushl $155
c010239d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01023a2:	e9 1c fa ff ff       	jmp    c0101dc3 <__alltraps>

c01023a7 <vector156>:
.globl vector156
vector156:
  pushl $0
c01023a7:	6a 00                	push   $0x0
  pushl $156
c01023a9:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023ae:	e9 10 fa ff ff       	jmp    c0101dc3 <__alltraps>

c01023b3 <vector157>:
.globl vector157
vector157:
  pushl $0
c01023b3:	6a 00                	push   $0x0
  pushl $157
c01023b5:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023ba:	e9 04 fa ff ff       	jmp    c0101dc3 <__alltraps>

c01023bf <vector158>:
.globl vector158
vector158:
  pushl $0
c01023bf:	6a 00                	push   $0x0
  pushl $158
c01023c1:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01023c6:	e9 f8 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01023cb <vector159>:
.globl vector159
vector159:
  pushl $0
c01023cb:	6a 00                	push   $0x0
  pushl $159
c01023cd:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023d2:	e9 ec f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01023d7 <vector160>:
.globl vector160
vector160:
  pushl $0
c01023d7:	6a 00                	push   $0x0
  pushl $160
c01023d9:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023de:	e9 e0 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01023e3 <vector161>:
.globl vector161
vector161:
  pushl $0
c01023e3:	6a 00                	push   $0x0
  pushl $161
c01023e5:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023ea:	e9 d4 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01023ef <vector162>:
.globl vector162
vector162:
  pushl $0
c01023ef:	6a 00                	push   $0x0
  pushl $162
c01023f1:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023f6:	e9 c8 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01023fb <vector163>:
.globl vector163
vector163:
  pushl $0
c01023fb:	6a 00                	push   $0x0
  pushl $163
c01023fd:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102402:	e9 bc f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102407 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102407:	6a 00                	push   $0x0
  pushl $164
c0102409:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010240e:	e9 b0 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102413 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102413:	6a 00                	push   $0x0
  pushl $165
c0102415:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010241a:	e9 a4 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c010241f <vector166>:
.globl vector166
vector166:
  pushl $0
c010241f:	6a 00                	push   $0x0
  pushl $166
c0102421:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102426:	e9 98 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c010242b <vector167>:
.globl vector167
vector167:
  pushl $0
c010242b:	6a 00                	push   $0x0
  pushl $167
c010242d:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102432:	e9 8c f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102437 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102437:	6a 00                	push   $0x0
  pushl $168
c0102439:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010243e:	e9 80 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102443 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102443:	6a 00                	push   $0x0
  pushl $169
c0102445:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010244a:	e9 74 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c010244f <vector170>:
.globl vector170
vector170:
  pushl $0
c010244f:	6a 00                	push   $0x0
  pushl $170
c0102451:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102456:	e9 68 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c010245b <vector171>:
.globl vector171
vector171:
  pushl $0
c010245b:	6a 00                	push   $0x0
  pushl $171
c010245d:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102462:	e9 5c f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102467 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102467:	6a 00                	push   $0x0
  pushl $172
c0102469:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010246e:	e9 50 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102473 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102473:	6a 00                	push   $0x0
  pushl $173
c0102475:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010247a:	e9 44 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c010247f <vector174>:
.globl vector174
vector174:
  pushl $0
c010247f:	6a 00                	push   $0x0
  pushl $174
c0102481:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102486:	e9 38 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c010248b <vector175>:
.globl vector175
vector175:
  pushl $0
c010248b:	6a 00                	push   $0x0
  pushl $175
c010248d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102492:	e9 2c f9 ff ff       	jmp    c0101dc3 <__alltraps>

c0102497 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102497:	6a 00                	push   $0x0
  pushl $176
c0102499:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010249e:	e9 20 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01024a3 <vector177>:
.globl vector177
vector177:
  pushl $0
c01024a3:	6a 00                	push   $0x0
  pushl $177
c01024a5:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01024aa:	e9 14 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01024af <vector178>:
.globl vector178
vector178:
  pushl $0
c01024af:	6a 00                	push   $0x0
  pushl $178
c01024b1:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024b6:	e9 08 f9 ff ff       	jmp    c0101dc3 <__alltraps>

c01024bb <vector179>:
.globl vector179
vector179:
  pushl $0
c01024bb:	6a 00                	push   $0x0
  pushl $179
c01024bd:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024c2:	e9 fc f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01024c7 <vector180>:
.globl vector180
vector180:
  pushl $0
c01024c7:	6a 00                	push   $0x0
  pushl $180
c01024c9:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01024ce:	e9 f0 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01024d3 <vector181>:
.globl vector181
vector181:
  pushl $0
c01024d3:	6a 00                	push   $0x0
  pushl $181
c01024d5:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024da:	e9 e4 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01024df <vector182>:
.globl vector182
vector182:
  pushl $0
c01024df:	6a 00                	push   $0x0
  pushl $182
c01024e1:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024e6:	e9 d8 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01024eb <vector183>:
.globl vector183
vector183:
  pushl $0
c01024eb:	6a 00                	push   $0x0
  pushl $183
c01024ed:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024f2:	e9 cc f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01024f7 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024f7:	6a 00                	push   $0x0
  pushl $184
c01024f9:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024fe:	e9 c0 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102503 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102503:	6a 00                	push   $0x0
  pushl $185
c0102505:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010250a:	e9 b4 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010250f <vector186>:
.globl vector186
vector186:
  pushl $0
c010250f:	6a 00                	push   $0x0
  pushl $186
c0102511:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102516:	e9 a8 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010251b <vector187>:
.globl vector187
vector187:
  pushl $0
c010251b:	6a 00                	push   $0x0
  pushl $187
c010251d:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102522:	e9 9c f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102527 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102527:	6a 00                	push   $0x0
  pushl $188
c0102529:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010252e:	e9 90 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102533 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102533:	6a 00                	push   $0x0
  pushl $189
c0102535:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010253a:	e9 84 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010253f <vector190>:
.globl vector190
vector190:
  pushl $0
c010253f:	6a 00                	push   $0x0
  pushl $190
c0102541:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102546:	e9 78 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010254b <vector191>:
.globl vector191
vector191:
  pushl $0
c010254b:	6a 00                	push   $0x0
  pushl $191
c010254d:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102552:	e9 6c f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102557 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102557:	6a 00                	push   $0x0
  pushl $192
c0102559:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010255e:	e9 60 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102563 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102563:	6a 00                	push   $0x0
  pushl $193
c0102565:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010256a:	e9 54 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010256f <vector194>:
.globl vector194
vector194:
  pushl $0
c010256f:	6a 00                	push   $0x0
  pushl $194
c0102571:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102576:	e9 48 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010257b <vector195>:
.globl vector195
vector195:
  pushl $0
c010257b:	6a 00                	push   $0x0
  pushl $195
c010257d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102582:	e9 3c f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102587 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102587:	6a 00                	push   $0x0
  pushl $196
c0102589:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010258e:	e9 30 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c0102593 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102593:	6a 00                	push   $0x0
  pushl $197
c0102595:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010259a:	e9 24 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c010259f <vector198>:
.globl vector198
vector198:
  pushl $0
c010259f:	6a 00                	push   $0x0
  pushl $198
c01025a1:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01025a6:	e9 18 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01025ab <vector199>:
.globl vector199
vector199:
  pushl $0
c01025ab:	6a 00                	push   $0x0
  pushl $199
c01025ad:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025b2:	e9 0c f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01025b7 <vector200>:
.globl vector200
vector200:
  pushl $0
c01025b7:	6a 00                	push   $0x0
  pushl $200
c01025b9:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025be:	e9 00 f8 ff ff       	jmp    c0101dc3 <__alltraps>

c01025c3 <vector201>:
.globl vector201
vector201:
  pushl $0
c01025c3:	6a 00                	push   $0x0
  pushl $201
c01025c5:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01025ca:	e9 f4 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01025cf <vector202>:
.globl vector202
vector202:
  pushl $0
c01025cf:	6a 00                	push   $0x0
  pushl $202
c01025d1:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025d6:	e9 e8 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01025db <vector203>:
.globl vector203
vector203:
  pushl $0
c01025db:	6a 00                	push   $0x0
  pushl $203
c01025dd:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025e2:	e9 dc f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01025e7 <vector204>:
.globl vector204
vector204:
  pushl $0
c01025e7:	6a 00                	push   $0x0
  pushl $204
c01025e9:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025ee:	e9 d0 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01025f3 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025f3:	6a 00                	push   $0x0
  pushl $205
c01025f5:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025fa:	e9 c4 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01025ff <vector206>:
.globl vector206
vector206:
  pushl $0
c01025ff:	6a 00                	push   $0x0
  pushl $206
c0102601:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102606:	e9 b8 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010260b <vector207>:
.globl vector207
vector207:
  pushl $0
c010260b:	6a 00                	push   $0x0
  pushl $207
c010260d:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102612:	e9 ac f7 ff ff       	jmp    c0101dc3 <__alltraps>

c0102617 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102617:	6a 00                	push   $0x0
  pushl $208
c0102619:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010261e:	e9 a0 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c0102623 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102623:	6a 00                	push   $0x0
  pushl $209
c0102625:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010262a:	e9 94 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010262f <vector210>:
.globl vector210
vector210:
  pushl $0
c010262f:	6a 00                	push   $0x0
  pushl $210
c0102631:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102636:	e9 88 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010263b <vector211>:
.globl vector211
vector211:
  pushl $0
c010263b:	6a 00                	push   $0x0
  pushl $211
c010263d:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102642:	e9 7c f7 ff ff       	jmp    c0101dc3 <__alltraps>

c0102647 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102647:	6a 00                	push   $0x0
  pushl $212
c0102649:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010264e:	e9 70 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c0102653 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102653:	6a 00                	push   $0x0
  pushl $213
c0102655:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010265a:	e9 64 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010265f <vector214>:
.globl vector214
vector214:
  pushl $0
c010265f:	6a 00                	push   $0x0
  pushl $214
c0102661:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102666:	e9 58 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010266b <vector215>:
.globl vector215
vector215:
  pushl $0
c010266b:	6a 00                	push   $0x0
  pushl $215
c010266d:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102672:	e9 4c f7 ff ff       	jmp    c0101dc3 <__alltraps>

c0102677 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102677:	6a 00                	push   $0x0
  pushl $216
c0102679:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010267e:	e9 40 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c0102683 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102683:	6a 00                	push   $0x0
  pushl $217
c0102685:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010268a:	e9 34 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010268f <vector218>:
.globl vector218
vector218:
  pushl $0
c010268f:	6a 00                	push   $0x0
  pushl $218
c0102691:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102696:	e9 28 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c010269b <vector219>:
.globl vector219
vector219:
  pushl $0
c010269b:	6a 00                	push   $0x0
  pushl $219
c010269d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01026a2:	e9 1c f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01026a7 <vector220>:
.globl vector220
vector220:
  pushl $0
c01026a7:	6a 00                	push   $0x0
  pushl $220
c01026a9:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026ae:	e9 10 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01026b3 <vector221>:
.globl vector221
vector221:
  pushl $0
c01026b3:	6a 00                	push   $0x0
  pushl $221
c01026b5:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026ba:	e9 04 f7 ff ff       	jmp    c0101dc3 <__alltraps>

c01026bf <vector222>:
.globl vector222
vector222:
  pushl $0
c01026bf:	6a 00                	push   $0x0
  pushl $222
c01026c1:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01026c6:	e9 f8 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01026cb <vector223>:
.globl vector223
vector223:
  pushl $0
c01026cb:	6a 00                	push   $0x0
  pushl $223
c01026cd:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026d2:	e9 ec f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01026d7 <vector224>:
.globl vector224
vector224:
  pushl $0
c01026d7:	6a 00                	push   $0x0
  pushl $224
c01026d9:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026de:	e9 e0 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01026e3 <vector225>:
.globl vector225
vector225:
  pushl $0
c01026e3:	6a 00                	push   $0x0
  pushl $225
c01026e5:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026ea:	e9 d4 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01026ef <vector226>:
.globl vector226
vector226:
  pushl $0
c01026ef:	6a 00                	push   $0x0
  pushl $226
c01026f1:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026f6:	e9 c8 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01026fb <vector227>:
.globl vector227
vector227:
  pushl $0
c01026fb:	6a 00                	push   $0x0
  pushl $227
c01026fd:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102702:	e9 bc f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102707 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102707:	6a 00                	push   $0x0
  pushl $228
c0102709:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010270e:	e9 b0 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102713 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102713:	6a 00                	push   $0x0
  pushl $229
c0102715:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010271a:	e9 a4 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c010271f <vector230>:
.globl vector230
vector230:
  pushl $0
c010271f:	6a 00                	push   $0x0
  pushl $230
c0102721:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102726:	e9 98 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c010272b <vector231>:
.globl vector231
vector231:
  pushl $0
c010272b:	6a 00                	push   $0x0
  pushl $231
c010272d:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102732:	e9 8c f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102737 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102737:	6a 00                	push   $0x0
  pushl $232
c0102739:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010273e:	e9 80 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102743 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102743:	6a 00                	push   $0x0
  pushl $233
c0102745:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010274a:	e9 74 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c010274f <vector234>:
.globl vector234
vector234:
  pushl $0
c010274f:	6a 00                	push   $0x0
  pushl $234
c0102751:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102756:	e9 68 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c010275b <vector235>:
.globl vector235
vector235:
  pushl $0
c010275b:	6a 00                	push   $0x0
  pushl $235
c010275d:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102762:	e9 5c f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102767 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102767:	6a 00                	push   $0x0
  pushl $236
c0102769:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010276e:	e9 50 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102773 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102773:	6a 00                	push   $0x0
  pushl $237
c0102775:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010277a:	e9 44 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c010277f <vector238>:
.globl vector238
vector238:
  pushl $0
c010277f:	6a 00                	push   $0x0
  pushl $238
c0102781:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102786:	e9 38 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c010278b <vector239>:
.globl vector239
vector239:
  pushl $0
c010278b:	6a 00                	push   $0x0
  pushl $239
c010278d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102792:	e9 2c f6 ff ff       	jmp    c0101dc3 <__alltraps>

c0102797 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102797:	6a 00                	push   $0x0
  pushl $240
c0102799:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010279e:	e9 20 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01027a3 <vector241>:
.globl vector241
vector241:
  pushl $0
c01027a3:	6a 00                	push   $0x0
  pushl $241
c01027a5:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01027aa:	e9 14 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01027af <vector242>:
.globl vector242
vector242:
  pushl $0
c01027af:	6a 00                	push   $0x0
  pushl $242
c01027b1:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027b6:	e9 08 f6 ff ff       	jmp    c0101dc3 <__alltraps>

c01027bb <vector243>:
.globl vector243
vector243:
  pushl $0
c01027bb:	6a 00                	push   $0x0
  pushl $243
c01027bd:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027c2:	e9 fc f5 ff ff       	jmp    c0101dc3 <__alltraps>

c01027c7 <vector244>:
.globl vector244
vector244:
  pushl $0
c01027c7:	6a 00                	push   $0x0
  pushl $244
c01027c9:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01027ce:	e9 f0 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c01027d3 <vector245>:
.globl vector245
vector245:
  pushl $0
c01027d3:	6a 00                	push   $0x0
  pushl $245
c01027d5:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027da:	e9 e4 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c01027df <vector246>:
.globl vector246
vector246:
  pushl $0
c01027df:	6a 00                	push   $0x0
  pushl $246
c01027e1:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027e6:	e9 d8 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c01027eb <vector247>:
.globl vector247
vector247:
  pushl $0
c01027eb:	6a 00                	push   $0x0
  pushl $247
c01027ed:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027f2:	e9 cc f5 ff ff       	jmp    c0101dc3 <__alltraps>

c01027f7 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027f7:	6a 00                	push   $0x0
  pushl $248
c01027f9:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027fe:	e9 c0 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c0102803 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102803:	6a 00                	push   $0x0
  pushl $249
c0102805:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010280a:	e9 b4 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c010280f <vector250>:
.globl vector250
vector250:
  pushl $0
c010280f:	6a 00                	push   $0x0
  pushl $250
c0102811:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102816:	e9 a8 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c010281b <vector251>:
.globl vector251
vector251:
  pushl $0
c010281b:	6a 00                	push   $0x0
  pushl $251
c010281d:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102822:	e9 9c f5 ff ff       	jmp    c0101dc3 <__alltraps>

c0102827 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102827:	6a 00                	push   $0x0
  pushl $252
c0102829:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010282e:	e9 90 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c0102833 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102833:	6a 00                	push   $0x0
  pushl $253
c0102835:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010283a:	e9 84 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c010283f <vector254>:
.globl vector254
vector254:
  pushl $0
c010283f:	6a 00                	push   $0x0
  pushl $254
c0102841:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102846:	e9 78 f5 ff ff       	jmp    c0101dc3 <__alltraps>

c010284b <vector255>:
.globl vector255
vector255:
  pushl $0
c010284b:	6a 00                	push   $0x0
  pushl $255
c010284d:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102852:	e9 6c f5 ff ff       	jmp    c0101dc3 <__alltraps>

c0102857 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102857:	55                   	push   %ebp
c0102858:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010285a:	8b 55 08             	mov    0x8(%ebp),%edx
c010285d:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0102862:	29 c2                	sub    %eax,%edx
c0102864:	89 d0                	mov    %edx,%eax
c0102866:	c1 f8 02             	sar    $0x2,%eax
c0102869:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010286f:	5d                   	pop    %ebp
c0102870:	c3                   	ret    

c0102871 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102871:	55                   	push   %ebp
c0102872:	89 e5                	mov    %esp,%ebp
c0102874:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102877:	8b 45 08             	mov    0x8(%ebp),%eax
c010287a:	89 04 24             	mov    %eax,(%esp)
c010287d:	e8 d5 ff ff ff       	call   c0102857 <page2ppn>
c0102882:	c1 e0 0c             	shl    $0xc,%eax
}
c0102885:	c9                   	leave  
c0102886:	c3                   	ret    

c0102887 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102887:	55                   	push   %ebp
c0102888:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010288a:	8b 45 08             	mov    0x8(%ebp),%eax
c010288d:	8b 00                	mov    (%eax),%eax
}
c010288f:	5d                   	pop    %ebp
c0102890:	c3                   	ret    

c0102891 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102891:	55                   	push   %ebp
c0102892:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102894:	8b 45 08             	mov    0x8(%ebp),%eax
c0102897:	8b 55 0c             	mov    0xc(%ebp),%edx
c010289a:	89 10                	mov    %edx,(%eax)
}
c010289c:	5d                   	pop    %ebp
c010289d:	c3                   	ret    

c010289e <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010289e:	55                   	push   %ebp
c010289f:	89 e5                	mov    %esp,%ebp
c01028a1:	83 ec 10             	sub    $0x10,%esp
c01028a4:	c7 45 fc 10 af 11 c0 	movl   $0xc011af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01028ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01028b1:	89 50 04             	mov    %edx,0x4(%eax)
c01028b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028b7:	8b 50 04             	mov    0x4(%eax),%edx
c01028ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028bd:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01028bf:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01028c6:	00 00 00 
}
c01028c9:	c9                   	leave  
c01028ca:	c3                   	ret    

c01028cb <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01028cb:	55                   	push   %ebp
c01028cc:	89 e5                	mov    %esp,%ebp
c01028ce:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01028d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01028d5:	75 24                	jne    c01028fb <default_init_memmap+0x30>
c01028d7:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c01028de:	c0 
c01028df:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01028e6:	c0 
c01028e7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01028ee:	00 
c01028ef:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01028f6:	e8 e2 e3 ff ff       	call   c0100cdd <__panic>
    struct Page *p = base;
c01028fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01028fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102901:	eb 7d                	jmp    c0102980 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102903:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102906:	83 c0 04             	add    $0x4,%eax
c0102909:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102910:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102913:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102916:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102919:	0f a3 10             	bt     %edx,(%eax)
c010291c:	19 c0                	sbb    %eax,%eax
c010291e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102921:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102925:	0f 95 c0             	setne  %al
c0102928:	0f b6 c0             	movzbl %al,%eax
c010292b:	85 c0                	test   %eax,%eax
c010292d:	75 24                	jne    c0102953 <default_init_memmap+0x88>
c010292f:	c7 44 24 0c 01 67 10 	movl   $0xc0106701,0xc(%esp)
c0102936:	c0 
c0102937:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010293e:	c0 
c010293f:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0102946:	00 
c0102947:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010294e:	e8 8a e3 ff ff       	call   c0100cdd <__panic>
        p->flags = p->property = 0;
c0102953:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102956:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010295d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102960:	8b 50 08             	mov    0x8(%eax),%edx
c0102963:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102966:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0102969:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102970:	00 
c0102971:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102974:	89 04 24             	mov    %eax,(%esp)
c0102977:	e8 15 ff ff ff       	call   c0102891 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010297c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102980:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102983:	89 d0                	mov    %edx,%eax
c0102985:	c1 e0 02             	shl    $0x2,%eax
c0102988:	01 d0                	add    %edx,%eax
c010298a:	c1 e0 02             	shl    $0x2,%eax
c010298d:	89 c2                	mov    %eax,%edx
c010298f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102992:	01 d0                	add    %edx,%eax
c0102994:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102997:	0f 85 66 ff ff ff    	jne    c0102903 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010299d:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029a3:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01029a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a9:	83 c0 04             	add    $0x4,%eax
c01029ac:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01029b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01029b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01029b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01029bc:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c01029bf:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c01029c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029c8:	01 d0                	add    %edx,%eax
c01029ca:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    list_add_before(&free_list, &(base->page_link));
c01029cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01029d2:	83 c0 0c             	add    $0xc,%eax
c01029d5:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
c01029dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01029df:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029e2:	8b 00                	mov    (%eax),%eax
c01029e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01029e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01029ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01029ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029f0:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01029f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029f6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01029f9:	89 10                	mov    %edx,(%eax)
c01029fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029fe:	8b 10                	mov    (%eax),%edx
c0102a00:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102a03:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102a06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a09:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102a0c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102a0f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102a12:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102a15:	89 10                	mov    %edx,(%eax)
}
c0102a17:	c9                   	leave  
c0102a18:	c3                   	ret    

c0102a19 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102a19:	55                   	push   %ebp
c0102a1a:	89 e5                	mov    %esp,%ebp
c0102a1c:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102a1f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a23:	75 24                	jne    c0102a49 <default_alloc_pages+0x30>
c0102a25:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c0102a2c:	c0 
c0102a2d:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102a34:	c0 
c0102a35:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0102a3c:	00 
c0102a3d:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102a44:	e8 94 e2 ff ff       	call   c0100cdd <__panic>
    if (n > nr_free) {
c0102a49:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102a4e:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a51:	73 0a                	jae    c0102a5d <default_alloc_pages+0x44>
        return NULL;
c0102a53:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a58:	e9 3d 01 00 00       	jmp    c0102b9a <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c0102a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102a64:	c7 45 f0 10 af 11 c0 	movl   $0xc011af10,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0102a6b:	eb 1c                	jmp    c0102a89 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102a6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a70:	83 e8 0c             	sub    $0xc,%eax
c0102a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a79:	8b 40 08             	mov    0x8(%eax),%eax
c0102a7c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a7f:	72 08                	jb     c0102a89 <default_alloc_pages+0x70>
            page = p;
c0102a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102a87:	eb 18                	jmp    c0102aa1 <default_alloc_pages+0x88>
c0102a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102a92:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0102a95:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102a98:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102a9f:	75 cc                	jne    c0102a6d <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0102aa1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102aa5:	0f 84 ec 00 00 00    	je     c0102b97 <default_alloc_pages+0x17e>
       // list_del(&(page->page_link)); LAB2 comment here
        if (page->property > n) {
c0102aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102aae:	8b 40 08             	mov    0x8(%eax),%eax
c0102ab1:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102ab4:	0f 86 8c 00 00 00    	jbe    c0102b46 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
c0102aba:	8b 55 08             	mov    0x8(%ebp),%edx
c0102abd:	89 d0                	mov    %edx,%eax
c0102abf:	c1 e0 02             	shl    $0x2,%eax
c0102ac2:	01 d0                	add    %edx,%eax
c0102ac4:	c1 e0 02             	shl    $0x2,%eax
c0102ac7:	89 c2                	mov    %eax,%edx
c0102ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102acc:	01 d0                	add    %edx,%eax
c0102ace:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0102ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ad4:	8b 40 08             	mov    0x8(%eax),%eax
c0102ad7:	2b 45 08             	sub    0x8(%ebp),%eax
c0102ada:	89 c2                	mov    %eax,%edx
c0102adc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102adf:	89 50 08             	mov    %edx,0x8(%eax)
	    SetPageProperty(p);//LAB2 change here
c0102ae2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102ae5:	83 c0 04             	add    $0x4,%eax
c0102ae8:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102aef:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102af2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102af5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102af8:	0f ab 10             	bts    %edx,(%eax)
           // list_add(&free_list, &(p->page_link));
            list_add_after(&(page->page_link), &(p->page_link));//LAB2 change here
c0102afb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102afe:	83 c0 0c             	add    $0xc,%eax
c0102b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102b04:	83 c2 0c             	add    $0xc,%edx
c0102b07:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102b0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102b0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102b10:	8b 40 04             	mov    0x4(%eax),%eax
c0102b13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102b16:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102b19:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102b1c:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0102b1f:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102b22:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b25:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102b28:	89 10                	mov    %edx,(%eax)
c0102b2a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102b2d:	8b 10                	mov    (%eax),%edx
c0102b2f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102b32:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102b35:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b38:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102b3b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102b3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102b41:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102b44:	89 10                	mov    %edx,(%eax)

 }
        list_del(&(page->page_link));//LAB2 change here
c0102b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b49:	83 c0 0c             	add    $0xc,%eax
c0102b4c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102b4f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102b52:	8b 40 04             	mov    0x4(%eax),%eax
c0102b55:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102b58:	8b 12                	mov    (%edx),%edx
c0102b5a:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102b5d:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102b60:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102b63:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102b66:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102b69:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102b6c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102b6f:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0102b71:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102b76:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b79:	a3 18 af 11 c0       	mov    %eax,0xc011af18
        ClearPageProperty(page);
c0102b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b81:	83 c0 04             	add    $0x4,%eax
c0102b84:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102b8b:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b8e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102b91:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102b94:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0102b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b9a:	c9                   	leave  
c0102b9b:	c3                   	ret    

c0102b9c <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102b9c:	55                   	push   %ebp
c0102b9d:	89 e5                	mov    %esp,%ebp
c0102b9f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102ba5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102ba9:	75 24                	jne    c0102bcf <default_free_pages+0x33>
c0102bab:	c7 44 24 0c d0 66 10 	movl   $0xc01066d0,0xc(%esp)
c0102bb2:	c0 
c0102bb3:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102bba:	c0 
c0102bbb:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c0102bc2:	00 
c0102bc3:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102bca:	e8 0e e1 ff ff       	call   c0100cdd <__panic>
    struct Page *p = base;
c0102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102bd5:	e9 9d 00 00 00       	jmp    c0102c77 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bdd:	83 c0 04             	add    $0x4,%eax
c0102be0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102be7:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102bea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102bf0:	0f a3 10             	bt     %edx,(%eax)
c0102bf3:	19 c0                	sbb    %eax,%eax
c0102bf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102bf8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102bfc:	0f 95 c0             	setne  %al
c0102bff:	0f b6 c0             	movzbl %al,%eax
c0102c02:	85 c0                	test   %eax,%eax
c0102c04:	75 2c                	jne    c0102c32 <default_free_pages+0x96>
c0102c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c09:	83 c0 04             	add    $0x4,%eax
c0102c0c:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102c13:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102c16:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c19:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102c1c:	0f a3 10             	bt     %edx,(%eax)
c0102c1f:	19 c0                	sbb    %eax,%eax
c0102c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102c24:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102c28:	0f 95 c0             	setne  %al
c0102c2b:	0f b6 c0             	movzbl %al,%eax
c0102c2e:	85 c0                	test   %eax,%eax
c0102c30:	74 24                	je     c0102c56 <default_free_pages+0xba>
c0102c32:	c7 44 24 0c 14 67 10 	movl   $0xc0106714,0xc(%esp)
c0102c39:	c0 
c0102c3a:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102c41:	c0 
c0102c42:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0102c49:	00 
c0102c4a:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102c51:	e8 87 e0 ff ff       	call   c0100cdd <__panic>
        p->flags = 0;
c0102c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c59:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102c60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c67:	00 
c0102c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c6b:	89 04 24             	mov    %eax,(%esp)
c0102c6e:	e8 1e fc ff ff       	call   c0102891 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0102c73:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102c77:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c7a:	89 d0                	mov    %edx,%eax
c0102c7c:	c1 e0 02             	shl    $0x2,%eax
c0102c7f:	01 d0                	add    %edx,%eax
c0102c81:	c1 e0 02             	shl    $0x2,%eax
c0102c84:	89 c2                	mov    %eax,%edx
c0102c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c89:	01 d0                	add    %edx,%eax
c0102c8b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102c8e:	0f 85 46 ff ff ff    	jne    c0102bda <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0102c94:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c97:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c9a:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102c9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca0:	83 c0 04             	add    $0x4,%eax
c0102ca3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0102caa:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102cad:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102cb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102cb3:	0f ab 10             	bts    %edx,(%eax)
c0102cb6:	c7 45 cc 10 af 11 c0 	movl   $0xc011af10,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102cbd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102cc0:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0102cc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102cc6:	e9 08 01 00 00       	jmp    c0102dd3 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0102ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cce:	83 e8 0c             	sub    $0xc,%eax
c0102cd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cd7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102cda:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102cdd:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102ce0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ce6:	8b 50 08             	mov    0x8(%eax),%edx
c0102ce9:	89 d0                	mov    %edx,%eax
c0102ceb:	c1 e0 02             	shl    $0x2,%eax
c0102cee:	01 d0                	add    %edx,%eax
c0102cf0:	c1 e0 02             	shl    $0x2,%eax
c0102cf3:	89 c2                	mov    %eax,%edx
c0102cf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cf8:	01 d0                	add    %edx,%eax
c0102cfa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102cfd:	75 5a                	jne    c0102d59 <default_free_pages+0x1bd>
            base->property += p->property;
c0102cff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d02:	8b 50 08             	mov    0x8(%eax),%edx
c0102d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d08:	8b 40 08             	mov    0x8(%eax),%eax
c0102d0b:	01 c2                	add    %eax,%edx
c0102d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d10:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d16:	83 c0 04             	add    $0x4,%eax
c0102d19:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102d20:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d23:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102d26:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102d29:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0102d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d2f:	83 c0 0c             	add    $0xc,%eax
c0102d32:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102d35:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d38:	8b 40 04             	mov    0x4(%eax),%eax
c0102d3b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d3e:	8b 12                	mov    (%edx),%edx
c0102d40:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102d43:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102d46:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d49:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d4c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102d4f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102d52:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102d55:	89 10                	mov    %edx,(%eax)
c0102d57:	eb 7a                	jmp    c0102dd3 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d5c:	8b 50 08             	mov    0x8(%eax),%edx
c0102d5f:	89 d0                	mov    %edx,%eax
c0102d61:	c1 e0 02             	shl    $0x2,%eax
c0102d64:	01 d0                	add    %edx,%eax
c0102d66:	c1 e0 02             	shl    $0x2,%eax
c0102d69:	89 c2                	mov    %eax,%edx
c0102d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d6e:	01 d0                	add    %edx,%eax
c0102d70:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102d73:	75 5e                	jne    c0102dd3 <default_free_pages+0x237>
            p->property += base->property;
c0102d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d78:	8b 50 08             	mov    0x8(%eax),%edx
c0102d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d7e:	8b 40 08             	mov    0x8(%eax),%eax
c0102d81:	01 c2                	add    %eax,%edx
c0102d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d86:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102d89:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d8c:	83 c0 04             	add    $0x4,%eax
c0102d8f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0102d96:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0102d99:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102d9c:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0102d9f:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0102da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102da5:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dab:	83 c0 0c             	add    $0xc,%eax
c0102dae:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102db1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102db4:	8b 40 04             	mov    0x4(%eax),%eax
c0102db7:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0102dba:	8b 12                	mov    (%edx),%edx
c0102dbc:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102dbf:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102dc2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102dc5:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0102dc8:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102dcb:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102dce:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102dd1:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0102dd3:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102dda:	0f 85 eb fe ff ff    	jne    c0102ccb <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0102de0:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102de6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102de9:	01 d0                	add    %edx,%eax
c0102deb:	a3 18 af 11 c0       	mov    %eax,0xc011af18
c0102df0:	c7 45 9c 10 af 11 c0 	movl   $0xc011af10,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102df7:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102dfa:	8b 40 04             	mov    0x4(%eax),%eax
    //LAB2 change here up
    le = list_next(&free_list);
c0102dfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0102e00:	eb 76                	jmp    c0102e78 <default_free_pages+0x2dc>
        p = le2page(le, page_link);
c0102e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e05:	83 e8 0c             	sub    $0xc,%eax
c0102e08:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0102e0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e0e:	8b 50 08             	mov    0x8(%eax),%edx
c0102e11:	89 d0                	mov    %edx,%eax
c0102e13:	c1 e0 02             	shl    $0x2,%eax
c0102e16:	01 d0                	add    %edx,%eax
c0102e18:	c1 e0 02             	shl    $0x2,%eax
c0102e1b:	89 c2                	mov    %eax,%edx
c0102e1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e20:	01 d0                	add    %edx,%eax
c0102e22:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e25:	77 42                	ja     c0102e69 <default_free_pages+0x2cd>
            assert(base + base->property != p);
c0102e27:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e2a:	8b 50 08             	mov    0x8(%eax),%edx
c0102e2d:	89 d0                	mov    %edx,%eax
c0102e2f:	c1 e0 02             	shl    $0x2,%eax
c0102e32:	01 d0                	add    %edx,%eax
c0102e34:	c1 e0 02             	shl    $0x2,%eax
c0102e37:	89 c2                	mov    %eax,%edx
c0102e39:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e3c:	01 d0                	add    %edx,%eax
c0102e3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102e41:	75 24                	jne    c0102e67 <default_free_pages+0x2cb>
c0102e43:	c7 44 24 0c 39 67 10 	movl   $0xc0106739,0xc(%esp)
c0102e4a:	c0 
c0102e4b:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102e52:	c0 
c0102e53:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0102e5a:	00 
c0102e5b:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102e62:	e8 76 de ff ff       	call   c0100cdd <__panic>
            break;
c0102e67:	eb 18                	jmp    c0102e81 <default_free_pages+0x2e5>
c0102e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e6c:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102e6f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102e72:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0102e75:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    nr_free += n;
    //LAB2 change here up
    le = list_next(&free_list);
    while (le != &free_list) {
c0102e78:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102e7f:	75 81                	jne    c0102e02 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0102e81:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e84:	8d 50 0c             	lea    0xc(%eax),%edx
c0102e87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e8a:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102e8d:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102e90:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102e93:	8b 00                	mov    (%eax),%eax
c0102e95:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e98:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0102e9b:	89 45 88             	mov    %eax,-0x78(%ebp)
c0102e9e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102ea1:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102ea4:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102ea7:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0102eaa:	89 10                	mov    %edx,(%eax)
c0102eac:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0102eaf:	8b 10                	mov    (%eax),%edx
c0102eb1:	8b 45 88             	mov    -0x78(%ebp),%eax
c0102eb4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102eb7:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102eba:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102ebd:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102ec0:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102ec3:	8b 55 88             	mov    -0x78(%ebp),%edx
c0102ec6:	89 10                	mov    %edx,(%eax)
//LAB2 change here bottom
}
c0102ec8:	c9                   	leave  
c0102ec9:	c3                   	ret    

c0102eca <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102eca:	55                   	push   %ebp
c0102ecb:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102ecd:	a1 18 af 11 c0       	mov    0xc011af18,%eax
}
c0102ed2:	5d                   	pop    %ebp
c0102ed3:	c3                   	ret    

c0102ed4 <basic_check>:

static void
basic_check(void) {
c0102ed4:	55                   	push   %ebp
c0102ed5:	89 e5                	mov    %esp,%ebp
c0102ed7:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102eda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102eea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102eed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102ef4:	e8 9d 0e 00 00       	call   c0103d96 <alloc_pages>
c0102ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102efc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102f00:	75 24                	jne    c0102f26 <basic_check+0x52>
c0102f02:	c7 44 24 0c 54 67 10 	movl   $0xc0106754,0xc(%esp)
c0102f09:	c0 
c0102f0a:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102f11:	c0 
c0102f12:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0102f19:	00 
c0102f1a:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102f21:	e8 b7 dd ff ff       	call   c0100cdd <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102f26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f2d:	e8 64 0e 00 00       	call   c0103d96 <alloc_pages>
c0102f32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102f35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102f39:	75 24                	jne    c0102f5f <basic_check+0x8b>
c0102f3b:	c7 44 24 0c 70 67 10 	movl   $0xc0106770,0xc(%esp)
c0102f42:	c0 
c0102f43:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102f4a:	c0 
c0102f4b:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0102f52:	00 
c0102f53:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102f5a:	e8 7e dd ff ff       	call   c0100cdd <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102f5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102f66:	e8 2b 0e 00 00       	call   c0103d96 <alloc_pages>
c0102f6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f6e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f72:	75 24                	jne    c0102f98 <basic_check+0xc4>
c0102f74:	c7 44 24 0c 8c 67 10 	movl   $0xc010678c,0xc(%esp)
c0102f7b:	c0 
c0102f7c:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102f83:	c0 
c0102f84:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0102f8b:	00 
c0102f8c:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102f93:	e8 45 dd ff ff       	call   c0100cdd <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102f98:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f9b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102f9e:	74 10                	je     c0102fb0 <basic_check+0xdc>
c0102fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fa3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102fa6:	74 08                	je     c0102fb0 <basic_check+0xdc>
c0102fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fab:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102fae:	75 24                	jne    c0102fd4 <basic_check+0x100>
c0102fb0:	c7 44 24 0c a8 67 10 	movl   $0xc01067a8,0xc(%esp)
c0102fb7:	c0 
c0102fb8:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0102fbf:	c0 
c0102fc0:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102fc7:	00 
c0102fc8:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0102fcf:	e8 09 dd ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102fd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102fd7:	89 04 24             	mov    %eax,(%esp)
c0102fda:	e8 a8 f8 ff ff       	call   c0102887 <page_ref>
c0102fdf:	85 c0                	test   %eax,%eax
c0102fe1:	75 1e                	jne    c0103001 <basic_check+0x12d>
c0102fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102fe6:	89 04 24             	mov    %eax,(%esp)
c0102fe9:	e8 99 f8 ff ff       	call   c0102887 <page_ref>
c0102fee:	85 c0                	test   %eax,%eax
c0102ff0:	75 0f                	jne    c0103001 <basic_check+0x12d>
c0102ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ff5:	89 04 24             	mov    %eax,(%esp)
c0102ff8:	e8 8a f8 ff ff       	call   c0102887 <page_ref>
c0102ffd:	85 c0                	test   %eax,%eax
c0102fff:	74 24                	je     c0103025 <basic_check+0x151>
c0103001:	c7 44 24 0c cc 67 10 	movl   $0xc01067cc,0xc(%esp)
c0103008:	c0 
c0103009:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103010:	c0 
c0103011:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0103018:	00 
c0103019:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103020:	e8 b8 dc ff ff       	call   c0100cdd <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103025:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103028:	89 04 24             	mov    %eax,(%esp)
c010302b:	e8 41 f8 ff ff       	call   c0102871 <page2pa>
c0103030:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103036:	c1 e2 0c             	shl    $0xc,%edx
c0103039:	39 d0                	cmp    %edx,%eax
c010303b:	72 24                	jb     c0103061 <basic_check+0x18d>
c010303d:	c7 44 24 0c 08 68 10 	movl   $0xc0106808,0xc(%esp)
c0103044:	c0 
c0103045:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010304c:	c0 
c010304d:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103054:	00 
c0103055:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010305c:	e8 7c dc ff ff       	call   c0100cdd <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103061:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103064:	89 04 24             	mov    %eax,(%esp)
c0103067:	e8 05 f8 ff ff       	call   c0102871 <page2pa>
c010306c:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103072:	c1 e2 0c             	shl    $0xc,%edx
c0103075:	39 d0                	cmp    %edx,%eax
c0103077:	72 24                	jb     c010309d <basic_check+0x1c9>
c0103079:	c7 44 24 0c 25 68 10 	movl   $0xc0106825,0xc(%esp)
c0103080:	c0 
c0103081:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103088:	c0 
c0103089:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103090:	00 
c0103091:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103098:	e8 40 dc ff ff       	call   c0100cdd <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010309d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030a0:	89 04 24             	mov    %eax,(%esp)
c01030a3:	e8 c9 f7 ff ff       	call   c0102871 <page2pa>
c01030a8:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c01030ae:	c1 e2 0c             	shl    $0xc,%edx
c01030b1:	39 d0                	cmp    %edx,%eax
c01030b3:	72 24                	jb     c01030d9 <basic_check+0x205>
c01030b5:	c7 44 24 0c 42 68 10 	movl   $0xc0106842,0xc(%esp)
c01030bc:	c0 
c01030bd:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01030c4:	c0 
c01030c5:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c01030cc:	00 
c01030cd:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01030d4:	e8 04 dc ff ff       	call   c0100cdd <__panic>

    list_entry_t free_list_store = free_list;
c01030d9:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c01030de:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c01030e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01030ea:	c7 45 e0 10 af 11 c0 	movl   $0xc011af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01030f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01030f7:	89 50 04             	mov    %edx,0x4(%eax)
c01030fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030fd:	8b 50 04             	mov    0x4(%eax),%edx
c0103100:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103103:	89 10                	mov    %edx,(%eax)
c0103105:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010310c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010310f:	8b 40 04             	mov    0x4(%eax),%eax
c0103112:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103115:	0f 94 c0             	sete   %al
c0103118:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010311b:	85 c0                	test   %eax,%eax
c010311d:	75 24                	jne    c0103143 <basic_check+0x26f>
c010311f:	c7 44 24 0c 5f 68 10 	movl   $0xc010685f,0xc(%esp)
c0103126:	c0 
c0103127:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010312e:	c0 
c010312f:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0103136:	00 
c0103137:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010313e:	e8 9a db ff ff       	call   c0100cdd <__panic>

    unsigned int nr_free_store = nr_free;
c0103143:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103148:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010314b:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0103152:	00 00 00 

    assert(alloc_page() == NULL);
c0103155:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010315c:	e8 35 0c 00 00       	call   c0103d96 <alloc_pages>
c0103161:	85 c0                	test   %eax,%eax
c0103163:	74 24                	je     c0103189 <basic_check+0x2b5>
c0103165:	c7 44 24 0c 76 68 10 	movl   $0xc0106876,0xc(%esp)
c010316c:	c0 
c010316d:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103174:	c0 
c0103175:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c010317c:	00 
c010317d:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103184:	e8 54 db ff ff       	call   c0100cdd <__panic>

    free_page(p0);
c0103189:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103190:	00 
c0103191:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103194:	89 04 24             	mov    %eax,(%esp)
c0103197:	e8 32 0c 00 00       	call   c0103dce <free_pages>
    free_page(p1);
c010319c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031a3:	00 
c01031a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031a7:	89 04 24             	mov    %eax,(%esp)
c01031aa:	e8 1f 0c 00 00       	call   c0103dce <free_pages>
    free_page(p2);
c01031af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031b6:	00 
c01031b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01031ba:	89 04 24             	mov    %eax,(%esp)
c01031bd:	e8 0c 0c 00 00       	call   c0103dce <free_pages>
    assert(nr_free == 3);
c01031c2:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01031c7:	83 f8 03             	cmp    $0x3,%eax
c01031ca:	74 24                	je     c01031f0 <basic_check+0x31c>
c01031cc:	c7 44 24 0c 8b 68 10 	movl   $0xc010688b,0xc(%esp)
c01031d3:	c0 
c01031d4:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01031db:	c0 
c01031dc:	c7 44 24 04 e6 00 00 	movl   $0xe6,0x4(%esp)
c01031e3:	00 
c01031e4:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01031eb:	e8 ed da ff ff       	call   c0100cdd <__panic>

    assert((p0 = alloc_page()) != NULL);
c01031f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031f7:	e8 9a 0b 00 00       	call   c0103d96 <alloc_pages>
c01031fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01031ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103203:	75 24                	jne    c0103229 <basic_check+0x355>
c0103205:	c7 44 24 0c 54 67 10 	movl   $0xc0106754,0xc(%esp)
c010320c:	c0 
c010320d:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103214:	c0 
c0103215:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c010321c:	00 
c010321d:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103224:	e8 b4 da ff ff       	call   c0100cdd <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103229:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103230:	e8 61 0b 00 00       	call   c0103d96 <alloc_pages>
c0103235:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103238:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010323c:	75 24                	jne    c0103262 <basic_check+0x38e>
c010323e:	c7 44 24 0c 70 67 10 	movl   $0xc0106770,0xc(%esp)
c0103245:	c0 
c0103246:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010324d:	c0 
c010324e:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0103255:	00 
c0103256:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010325d:	e8 7b da ff ff       	call   c0100cdd <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103262:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103269:	e8 28 0b 00 00       	call   c0103d96 <alloc_pages>
c010326e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103271:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103275:	75 24                	jne    c010329b <basic_check+0x3c7>
c0103277:	c7 44 24 0c 8c 67 10 	movl   $0xc010678c,0xc(%esp)
c010327e:	c0 
c010327f:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103286:	c0 
c0103287:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c010328e:	00 
c010328f:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103296:	e8 42 da ff ff       	call   c0100cdd <__panic>

    assert(alloc_page() == NULL);
c010329b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01032a2:	e8 ef 0a 00 00       	call   c0103d96 <alloc_pages>
c01032a7:	85 c0                	test   %eax,%eax
c01032a9:	74 24                	je     c01032cf <basic_check+0x3fb>
c01032ab:	c7 44 24 0c 76 68 10 	movl   $0xc0106876,0xc(%esp)
c01032b2:	c0 
c01032b3:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01032ba:	c0 
c01032bb:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c01032c2:	00 
c01032c3:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01032ca:	e8 0e da ff ff       	call   c0100cdd <__panic>

    free_page(p0);
c01032cf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032d6:	00 
c01032d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032da:	89 04 24             	mov    %eax,(%esp)
c01032dd:	e8 ec 0a 00 00       	call   c0103dce <free_pages>
c01032e2:	c7 45 d8 10 af 11 c0 	movl   $0xc011af10,-0x28(%ebp)
c01032e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01032ec:	8b 40 04             	mov    0x4(%eax),%eax
c01032ef:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01032f2:	0f 94 c0             	sete   %al
c01032f5:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01032f8:	85 c0                	test   %eax,%eax
c01032fa:	74 24                	je     c0103320 <basic_check+0x44c>
c01032fc:	c7 44 24 0c 98 68 10 	movl   $0xc0106898,0xc(%esp)
c0103303:	c0 
c0103304:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010330b:	c0 
c010330c:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
c0103313:	00 
c0103314:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010331b:	e8 bd d9 ff ff       	call   c0100cdd <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103320:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103327:	e8 6a 0a 00 00       	call   c0103d96 <alloc_pages>
c010332c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010332f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103332:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103335:	74 24                	je     c010335b <basic_check+0x487>
c0103337:	c7 44 24 0c b0 68 10 	movl   $0xc01068b0,0xc(%esp)
c010333e:	c0 
c010333f:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103346:	c0 
c0103347:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c010334e:	00 
c010334f:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103356:	e8 82 d9 ff ff       	call   c0100cdd <__panic>
    assert(alloc_page() == NULL);
c010335b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103362:	e8 2f 0a 00 00       	call   c0103d96 <alloc_pages>
c0103367:	85 c0                	test   %eax,%eax
c0103369:	74 24                	je     c010338f <basic_check+0x4bb>
c010336b:	c7 44 24 0c 76 68 10 	movl   $0xc0106876,0xc(%esp)
c0103372:	c0 
c0103373:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010337a:	c0 
c010337b:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0103382:	00 
c0103383:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010338a:	e8 4e d9 ff ff       	call   c0100cdd <__panic>

    assert(nr_free == 0);
c010338f:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103394:	85 c0                	test   %eax,%eax
c0103396:	74 24                	je     c01033bc <basic_check+0x4e8>
c0103398:	c7 44 24 0c c9 68 10 	movl   $0xc01068c9,0xc(%esp)
c010339f:	c0 
c01033a0:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01033a7:	c0 
c01033a8:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c01033af:	00 
c01033b0:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01033b7:	e8 21 d9 ff ff       	call   c0100cdd <__panic>
    free_list = free_list_store;
c01033bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01033bf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01033c2:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01033c7:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    nr_free = nr_free_store;
c01033cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01033d0:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_page(p);
c01033d5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033dc:	00 
c01033dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01033e0:	89 04 24             	mov    %eax,(%esp)
c01033e3:	e8 e6 09 00 00       	call   c0103dce <free_pages>
    free_page(p1);
c01033e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033ef:	00 
c01033f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033f3:	89 04 24             	mov    %eax,(%esp)
c01033f6:	e8 d3 09 00 00       	call   c0103dce <free_pages>
    free_page(p2);
c01033fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103402:	00 
c0103403:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103406:	89 04 24             	mov    %eax,(%esp)
c0103409:	e8 c0 09 00 00       	call   c0103dce <free_pages>
}
c010340e:	c9                   	leave  
c010340f:	c3                   	ret    

c0103410 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103410:	55                   	push   %ebp
c0103411:	89 e5                	mov    %esp,%ebp
c0103413:	53                   	push   %ebx
c0103414:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c010341a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103421:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103428:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010342f:	eb 6b                	jmp    c010349c <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103431:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103434:	83 e8 0c             	sub    $0xc,%eax
c0103437:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010343a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010343d:	83 c0 04             	add    $0x4,%eax
c0103440:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103447:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010344a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010344d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103450:	0f a3 10             	bt     %edx,(%eax)
c0103453:	19 c0                	sbb    %eax,%eax
c0103455:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103458:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010345c:	0f 95 c0             	setne  %al
c010345f:	0f b6 c0             	movzbl %al,%eax
c0103462:	85 c0                	test   %eax,%eax
c0103464:	75 24                	jne    c010348a <default_check+0x7a>
c0103466:	c7 44 24 0c d6 68 10 	movl   $0xc01068d6,0xc(%esp)
c010346d:	c0 
c010346e:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103475:	c0 
c0103476:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c010347d:	00 
c010347e:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103485:	e8 53 d8 ff ff       	call   c0100cdd <__panic>
        count ++, total += p->property;
c010348a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010348e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103491:	8b 50 08             	mov    0x8(%eax),%edx
c0103494:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103497:	01 d0                	add    %edx,%eax
c0103499:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010349c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010349f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01034a2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034a5:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01034a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01034ab:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c01034b2:	0f 85 79 ff ff ff    	jne    c0103431 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01034b8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01034bb:	e8 40 09 00 00       	call   c0103e00 <nr_free_pages>
c01034c0:	39 c3                	cmp    %eax,%ebx
c01034c2:	74 24                	je     c01034e8 <default_check+0xd8>
c01034c4:	c7 44 24 0c e6 68 10 	movl   $0xc01068e6,0xc(%esp)
c01034cb:	c0 
c01034cc:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01034d3:	c0 
c01034d4:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c01034db:	00 
c01034dc:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01034e3:	e8 f5 d7 ff ff       	call   c0100cdd <__panic>

    basic_check();
c01034e8:	e8 e7 f9 ff ff       	call   c0102ed4 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01034ed:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01034f4:	e8 9d 08 00 00       	call   c0103d96 <alloc_pages>
c01034f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01034fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103500:	75 24                	jne    c0103526 <default_check+0x116>
c0103502:	c7 44 24 0c ff 68 10 	movl   $0xc01068ff,0xc(%esp)
c0103509:	c0 
c010350a:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103511:	c0 
c0103512:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103519:	00 
c010351a:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103521:	e8 b7 d7 ff ff       	call   c0100cdd <__panic>
    assert(!PageProperty(p0));
c0103526:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103529:	83 c0 04             	add    $0x4,%eax
c010352c:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103533:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103536:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103539:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010353c:	0f a3 10             	bt     %edx,(%eax)
c010353f:	19 c0                	sbb    %eax,%eax
c0103541:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103544:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103548:	0f 95 c0             	setne  %al
c010354b:	0f b6 c0             	movzbl %al,%eax
c010354e:	85 c0                	test   %eax,%eax
c0103550:	74 24                	je     c0103576 <default_check+0x166>
c0103552:	c7 44 24 0c 0a 69 10 	movl   $0xc010690a,0xc(%esp)
c0103559:	c0 
c010355a:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103561:	c0 
c0103562:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0103569:	00 
c010356a:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103571:	e8 67 d7 ff ff       	call   c0100cdd <__panic>

    list_entry_t free_list_store = free_list;
c0103576:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c010357b:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c0103581:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103584:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103587:	c7 45 b4 10 af 11 c0 	movl   $0xc011af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010358e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103591:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103594:	89 50 04             	mov    %edx,0x4(%eax)
c0103597:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010359a:	8b 50 04             	mov    0x4(%eax),%edx
c010359d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01035a0:	89 10                	mov    %edx,(%eax)
c01035a2:	c7 45 b0 10 af 11 c0 	movl   $0xc011af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01035a9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01035ac:	8b 40 04             	mov    0x4(%eax),%eax
c01035af:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01035b2:	0f 94 c0             	sete   %al
c01035b5:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01035b8:	85 c0                	test   %eax,%eax
c01035ba:	75 24                	jne    c01035e0 <default_check+0x1d0>
c01035bc:	c7 44 24 0c 5f 68 10 	movl   $0xc010685f,0xc(%esp)
c01035c3:	c0 
c01035c4:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01035cb:	c0 
c01035cc:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01035d3:	00 
c01035d4:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01035db:	e8 fd d6 ff ff       	call   c0100cdd <__panic>
    assert(alloc_page() == NULL);
c01035e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035e7:	e8 aa 07 00 00       	call   c0103d96 <alloc_pages>
c01035ec:	85 c0                	test   %eax,%eax
c01035ee:	74 24                	je     c0103614 <default_check+0x204>
c01035f0:	c7 44 24 0c 76 68 10 	movl   $0xc0106876,0xc(%esp)
c01035f7:	c0 
c01035f8:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01035ff:	c0 
c0103600:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0103607:	00 
c0103608:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010360f:	e8 c9 d6 ff ff       	call   c0100cdd <__panic>

    unsigned int nr_free_store = nr_free;
c0103614:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103619:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010361c:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0103623:	00 00 00 

    free_pages(p0 + 2, 3);
c0103626:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103629:	83 c0 28             	add    $0x28,%eax
c010362c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103633:	00 
c0103634:	89 04 24             	mov    %eax,(%esp)
c0103637:	e8 92 07 00 00       	call   c0103dce <free_pages>
    assert(alloc_pages(4) == NULL);
c010363c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103643:	e8 4e 07 00 00       	call   c0103d96 <alloc_pages>
c0103648:	85 c0                	test   %eax,%eax
c010364a:	74 24                	je     c0103670 <default_check+0x260>
c010364c:	c7 44 24 0c 1c 69 10 	movl   $0xc010691c,0xc(%esp)
c0103653:	c0 
c0103654:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010365b:	c0 
c010365c:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103663:	00 
c0103664:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010366b:	e8 6d d6 ff ff       	call   c0100cdd <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103673:	83 c0 28             	add    $0x28,%eax
c0103676:	83 c0 04             	add    $0x4,%eax
c0103679:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103680:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103683:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103686:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103689:	0f a3 10             	bt     %edx,(%eax)
c010368c:	19 c0                	sbb    %eax,%eax
c010368e:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103691:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103695:	0f 95 c0             	setne  %al
c0103698:	0f b6 c0             	movzbl %al,%eax
c010369b:	85 c0                	test   %eax,%eax
c010369d:	74 0e                	je     c01036ad <default_check+0x29d>
c010369f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036a2:	83 c0 28             	add    $0x28,%eax
c01036a5:	8b 40 08             	mov    0x8(%eax),%eax
c01036a8:	83 f8 03             	cmp    $0x3,%eax
c01036ab:	74 24                	je     c01036d1 <default_check+0x2c1>
c01036ad:	c7 44 24 0c 34 69 10 	movl   $0xc0106934,0xc(%esp)
c01036b4:	c0 
c01036b5:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01036bc:	c0 
c01036bd:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c01036c4:	00 
c01036c5:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01036cc:	e8 0c d6 ff ff       	call   c0100cdd <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01036d1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01036d8:	e8 b9 06 00 00       	call   c0103d96 <alloc_pages>
c01036dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01036e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01036e4:	75 24                	jne    c010370a <default_check+0x2fa>
c01036e6:	c7 44 24 0c 60 69 10 	movl   $0xc0106960,0xc(%esp)
c01036ed:	c0 
c01036ee:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01036f5:	c0 
c01036f6:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01036fd:	00 
c01036fe:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103705:	e8 d3 d5 ff ff       	call   c0100cdd <__panic>
    assert(alloc_page() == NULL);
c010370a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103711:	e8 80 06 00 00       	call   c0103d96 <alloc_pages>
c0103716:	85 c0                	test   %eax,%eax
c0103718:	74 24                	je     c010373e <default_check+0x32e>
c010371a:	c7 44 24 0c 76 68 10 	movl   $0xc0106876,0xc(%esp)
c0103721:	c0 
c0103722:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103729:	c0 
c010372a:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0103731:	00 
c0103732:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103739:	e8 9f d5 ff ff       	call   c0100cdd <__panic>
    assert(p0 + 2 == p1);
c010373e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103741:	83 c0 28             	add    $0x28,%eax
c0103744:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103747:	74 24                	je     c010376d <default_check+0x35d>
c0103749:	c7 44 24 0c 7e 69 10 	movl   $0xc010697e,0xc(%esp)
c0103750:	c0 
c0103751:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103758:	c0 
c0103759:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0103760:	00 
c0103761:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103768:	e8 70 d5 ff ff       	call   c0100cdd <__panic>

    p2 = p0 + 1;
c010376d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103770:	83 c0 14             	add    $0x14,%eax
c0103773:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103776:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010377d:	00 
c010377e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103781:	89 04 24             	mov    %eax,(%esp)
c0103784:	e8 45 06 00 00       	call   c0103dce <free_pages>
    free_pages(p1, 3);
c0103789:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103790:	00 
c0103791:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103794:	89 04 24             	mov    %eax,(%esp)
c0103797:	e8 32 06 00 00       	call   c0103dce <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010379c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010379f:	83 c0 04             	add    $0x4,%eax
c01037a2:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01037a9:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01037ac:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01037af:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01037b2:	0f a3 10             	bt     %edx,(%eax)
c01037b5:	19 c0                	sbb    %eax,%eax
c01037b7:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01037ba:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01037be:	0f 95 c0             	setne  %al
c01037c1:	0f b6 c0             	movzbl %al,%eax
c01037c4:	85 c0                	test   %eax,%eax
c01037c6:	74 0b                	je     c01037d3 <default_check+0x3c3>
c01037c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037cb:	8b 40 08             	mov    0x8(%eax),%eax
c01037ce:	83 f8 01             	cmp    $0x1,%eax
c01037d1:	74 24                	je     c01037f7 <default_check+0x3e7>
c01037d3:	c7 44 24 0c 8c 69 10 	movl   $0xc010698c,0xc(%esp)
c01037da:	c0 
c01037db:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01037e2:	c0 
c01037e3:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c01037ea:	00 
c01037eb:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01037f2:	e8 e6 d4 ff ff       	call   c0100cdd <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01037f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037fa:	83 c0 04             	add    $0x4,%eax
c01037fd:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103804:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103807:	8b 45 90             	mov    -0x70(%ebp),%eax
c010380a:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010380d:	0f a3 10             	bt     %edx,(%eax)
c0103810:	19 c0                	sbb    %eax,%eax
c0103812:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103815:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103819:	0f 95 c0             	setne  %al
c010381c:	0f b6 c0             	movzbl %al,%eax
c010381f:	85 c0                	test   %eax,%eax
c0103821:	74 0b                	je     c010382e <default_check+0x41e>
c0103823:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103826:	8b 40 08             	mov    0x8(%eax),%eax
c0103829:	83 f8 03             	cmp    $0x3,%eax
c010382c:	74 24                	je     c0103852 <default_check+0x442>
c010382e:	c7 44 24 0c b4 69 10 	movl   $0xc01069b4,0xc(%esp)
c0103835:	c0 
c0103836:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010383d:	c0 
c010383e:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0103845:	00 
c0103846:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010384d:	e8 8b d4 ff ff       	call   c0100cdd <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103852:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103859:	e8 38 05 00 00       	call   c0103d96 <alloc_pages>
c010385e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103861:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103864:	83 e8 14             	sub    $0x14,%eax
c0103867:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010386a:	74 24                	je     c0103890 <default_check+0x480>
c010386c:	c7 44 24 0c da 69 10 	movl   $0xc01069da,0xc(%esp)
c0103873:	c0 
c0103874:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010387b:	c0 
c010387c:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0103883:	00 
c0103884:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010388b:	e8 4d d4 ff ff       	call   c0100cdd <__panic>
    free_page(p0);
c0103890:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103897:	00 
c0103898:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010389b:	89 04 24             	mov    %eax,(%esp)
c010389e:	e8 2b 05 00 00       	call   c0103dce <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01038a3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01038aa:	e8 e7 04 00 00       	call   c0103d96 <alloc_pages>
c01038af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01038b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038b5:	83 c0 14             	add    $0x14,%eax
c01038b8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01038bb:	74 24                	je     c01038e1 <default_check+0x4d1>
c01038bd:	c7 44 24 0c f8 69 10 	movl   $0xc01069f8,0xc(%esp)
c01038c4:	c0 
c01038c5:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c01038cc:	c0 
c01038cd:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01038d4:	00 
c01038d5:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c01038dc:	e8 fc d3 ff ff       	call   c0100cdd <__panic>

    free_pages(p0, 2);
c01038e1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01038e8:	00 
c01038e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038ec:	89 04 24             	mov    %eax,(%esp)
c01038ef:	e8 da 04 00 00       	call   c0103dce <free_pages>
    free_page(p2);
c01038f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038fb:	00 
c01038fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038ff:	89 04 24             	mov    %eax,(%esp)
c0103902:	e8 c7 04 00 00       	call   c0103dce <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103907:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010390e:	e8 83 04 00 00       	call   c0103d96 <alloc_pages>
c0103913:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103916:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010391a:	75 24                	jne    c0103940 <default_check+0x530>
c010391c:	c7 44 24 0c 18 6a 10 	movl   $0xc0106a18,0xc(%esp)
c0103923:	c0 
c0103924:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010392b:	c0 
c010392c:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c0103933:	00 
c0103934:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010393b:	e8 9d d3 ff ff       	call   c0100cdd <__panic>
    assert(alloc_page() == NULL);
c0103940:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103947:	e8 4a 04 00 00       	call   c0103d96 <alloc_pages>
c010394c:	85 c0                	test   %eax,%eax
c010394e:	74 24                	je     c0103974 <default_check+0x564>
c0103950:	c7 44 24 0c 76 68 10 	movl   $0xc0106876,0xc(%esp)
c0103957:	c0 
c0103958:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010395f:	c0 
c0103960:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0103967:	00 
c0103968:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010396f:	e8 69 d3 ff ff       	call   c0100cdd <__panic>

    assert(nr_free == 0);
c0103974:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103979:	85 c0                	test   %eax,%eax
c010397b:	74 24                	je     c01039a1 <default_check+0x591>
c010397d:	c7 44 24 0c c9 68 10 	movl   $0xc01068c9,0xc(%esp)
c0103984:	c0 
c0103985:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c010398c:	c0 
c010398d:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0103994:	00 
c0103995:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c010399c:	e8 3c d3 ff ff       	call   c0100cdd <__panic>
    nr_free = nr_free_store;
c01039a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039a4:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_list = free_list_store;
c01039a9:	8b 45 80             	mov    -0x80(%ebp),%eax
c01039ac:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01039af:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01039b4:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    free_pages(p0, 5);
c01039ba:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01039c1:	00 
c01039c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039c5:	89 04 24             	mov    %eax,(%esp)
c01039c8:	e8 01 04 00 00       	call   c0103dce <free_pages>

    le = &free_list;
c01039cd:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01039d4:	eb 1d                	jmp    c01039f3 <default_check+0x5e3>
       // assert(le->next->prev == le && le->prev->next == le);
       //LAB2 comment here
   	 struct Page *p = le2page(le, page_link);
c01039d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039d9:	83 e8 0c             	sub    $0xc,%eax
c01039dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01039df:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01039e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01039e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01039e9:	8b 40 08             	mov    0x8(%eax),%eax
c01039ec:	29 c2                	sub    %eax,%edx
c01039ee:	89 d0                	mov    %edx,%eax
c01039f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039f6:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01039f9:	8b 45 88             	mov    -0x78(%ebp),%eax
c01039fc:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01039ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a02:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c0103a09:	75 cb                	jne    c01039d6 <default_check+0x5c6>
       // assert(le->next->prev == le && le->prev->next == le);
       //LAB2 comment here
   	 struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0103a0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103a0f:	74 24                	je     c0103a35 <default_check+0x625>
c0103a11:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c0103a18:	c0 
c0103a19:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103a20:	c0 
c0103a21:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0103a28:	00 
c0103a29:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103a30:	e8 a8 d2 ff ff       	call   c0100cdd <__panic>
    assert(total == 0);
c0103a35:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a39:	74 24                	je     c0103a5f <default_check+0x64f>
c0103a3b:	c7 44 24 0c 41 6a 10 	movl   $0xc0106a41,0xc(%esp)
c0103a42:	c0 
c0103a43:	c7 44 24 08 d6 66 10 	movl   $0xc01066d6,0x8(%esp)
c0103a4a:	c0 
c0103a4b:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0103a52:	00 
c0103a53:	c7 04 24 eb 66 10 c0 	movl   $0xc01066eb,(%esp)
c0103a5a:	e8 7e d2 ff ff       	call   c0100cdd <__panic>
}
c0103a5f:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103a65:	5b                   	pop    %ebx
c0103a66:	5d                   	pop    %ebp
c0103a67:	c3                   	ret    

c0103a68 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103a68:	55                   	push   %ebp
c0103a69:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103a6b:	8b 55 08             	mov    0x8(%ebp),%edx
c0103a6e:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103a73:	29 c2                	sub    %eax,%edx
c0103a75:	89 d0                	mov    %edx,%eax
c0103a77:	c1 f8 02             	sar    $0x2,%eax
c0103a7a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103a80:	5d                   	pop    %ebp
c0103a81:	c3                   	ret    

c0103a82 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103a82:	55                   	push   %ebp
c0103a83:	89 e5                	mov    %esp,%ebp
c0103a85:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103a88:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a8b:	89 04 24             	mov    %eax,(%esp)
c0103a8e:	e8 d5 ff ff ff       	call   c0103a68 <page2ppn>
c0103a93:	c1 e0 0c             	shl    $0xc,%eax
}
c0103a96:	c9                   	leave  
c0103a97:	c3                   	ret    

c0103a98 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0103a98:	55                   	push   %ebp
c0103a99:	89 e5                	mov    %esp,%ebp
c0103a9b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aa1:	c1 e8 0c             	shr    $0xc,%eax
c0103aa4:	89 c2                	mov    %eax,%edx
c0103aa6:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103aab:	39 c2                	cmp    %eax,%edx
c0103aad:	72 1c                	jb     c0103acb <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103aaf:	c7 44 24 08 7c 6a 10 	movl   $0xc0106a7c,0x8(%esp)
c0103ab6:	c0 
c0103ab7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103abe:	00 
c0103abf:	c7 04 24 9b 6a 10 c0 	movl   $0xc0106a9b,(%esp)
c0103ac6:	e8 12 d2 ff ff       	call   c0100cdd <__panic>
    }
    return &pages[PPN(pa)];
c0103acb:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ad4:	c1 e8 0c             	shr    $0xc,%eax
c0103ad7:	89 c2                	mov    %eax,%edx
c0103ad9:	89 d0                	mov    %edx,%eax
c0103adb:	c1 e0 02             	shl    $0x2,%eax
c0103ade:	01 d0                	add    %edx,%eax
c0103ae0:	c1 e0 02             	shl    $0x2,%eax
c0103ae3:	01 c8                	add    %ecx,%eax
}
c0103ae5:	c9                   	leave  
c0103ae6:	c3                   	ret    

c0103ae7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103ae7:	55                   	push   %ebp
c0103ae8:	89 e5                	mov    %esp,%ebp
c0103aea:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103aed:	8b 45 08             	mov    0x8(%ebp),%eax
c0103af0:	89 04 24             	mov    %eax,(%esp)
c0103af3:	e8 8a ff ff ff       	call   c0103a82 <page2pa>
c0103af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103afe:	c1 e8 0c             	shr    $0xc,%eax
c0103b01:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b04:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103b09:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103b0c:	72 23                	jb     c0103b31 <page2kva+0x4a>
c0103b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b11:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b15:	c7 44 24 08 ac 6a 10 	movl   $0xc0106aac,0x8(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103b24:	00 
c0103b25:	c7 04 24 9b 6a 10 c0 	movl   $0xc0106a9b,(%esp)
c0103b2c:	e8 ac d1 ff ff       	call   c0100cdd <__panic>
c0103b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b34:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103b39:	c9                   	leave  
c0103b3a:	c3                   	ret    

c0103b3b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103b3b:	55                   	push   %ebp
c0103b3c:	89 e5                	mov    %esp,%ebp
c0103b3e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b44:	83 e0 01             	and    $0x1,%eax
c0103b47:	85 c0                	test   %eax,%eax
c0103b49:	75 1c                	jne    c0103b67 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103b4b:	c7 44 24 08 d0 6a 10 	movl   $0xc0106ad0,0x8(%esp)
c0103b52:	c0 
c0103b53:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103b5a:	00 
c0103b5b:	c7 04 24 9b 6a 10 c0 	movl   $0xc0106a9b,(%esp)
c0103b62:	e8 76 d1 ff ff       	call   c0100cdd <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103b67:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b6f:	89 04 24             	mov    %eax,(%esp)
c0103b72:	e8 21 ff ff ff       	call   c0103a98 <pa2page>
}
c0103b77:	c9                   	leave  
c0103b78:	c3                   	ret    

c0103b79 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103b79:	55                   	push   %ebp
c0103b7a:	89 e5                	mov    %esp,%ebp
c0103b7c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103b7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b87:	89 04 24             	mov    %eax,(%esp)
c0103b8a:	e8 09 ff ff ff       	call   c0103a98 <pa2page>
}
c0103b8f:	c9                   	leave  
c0103b90:	c3                   	ret    

c0103b91 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103b91:	55                   	push   %ebp
c0103b92:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103b94:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b97:	8b 00                	mov    (%eax),%eax
}
c0103b99:	5d                   	pop    %ebp
c0103b9a:	c3                   	ret    

c0103b9b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103b9b:	55                   	push   %ebp
c0103b9c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103b9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103ba4:	89 10                	mov    %edx,(%eax)
}
c0103ba6:	5d                   	pop    %ebp
c0103ba7:	c3                   	ret    

c0103ba8 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103ba8:	55                   	push   %ebp
c0103ba9:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103bab:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bae:	8b 00                	mov    (%eax),%eax
c0103bb0:	8d 50 01             	lea    0x1(%eax),%edx
c0103bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bb6:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103bb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bbb:	8b 00                	mov    (%eax),%eax
}
c0103bbd:	5d                   	pop    %ebp
c0103bbe:	c3                   	ret    

c0103bbf <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103bbf:	55                   	push   %ebp
c0103bc0:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103bc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bc5:	8b 00                	mov    (%eax),%eax
c0103bc7:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bcd:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103bcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bd2:	8b 00                	mov    (%eax),%eax
}
c0103bd4:	5d                   	pop    %ebp
c0103bd5:	c3                   	ret    

c0103bd6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103bd6:	55                   	push   %ebp
c0103bd7:	89 e5                	mov    %esp,%ebp
c0103bd9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103bdc:	9c                   	pushf  
c0103bdd:	58                   	pop    %eax
c0103bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103be4:	25 00 02 00 00       	and    $0x200,%eax
c0103be9:	85 c0                	test   %eax,%eax
c0103beb:	74 0c                	je     c0103bf9 <__intr_save+0x23>
        intr_disable();
c0103bed:	e8 df da ff ff       	call   c01016d1 <intr_disable>
        return 1;
c0103bf2:	b8 01 00 00 00       	mov    $0x1,%eax
c0103bf7:	eb 05                	jmp    c0103bfe <__intr_save+0x28>
    }
    return 0;
c0103bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103bfe:	c9                   	leave  
c0103bff:	c3                   	ret    

c0103c00 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103c00:	55                   	push   %ebp
c0103c01:	89 e5                	mov    %esp,%ebp
c0103c03:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103c06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103c0a:	74 05                	je     c0103c11 <__intr_restore+0x11>
        intr_enable();
c0103c0c:	e8 ba da ff ff       	call   c01016cb <intr_enable>
    }
}
c0103c11:	c9                   	leave  
c0103c12:	c3                   	ret    

c0103c13 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103c13:	55                   	push   %ebp
c0103c14:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103c16:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c19:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103c1c:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c21:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103c23:	b8 23 00 00 00       	mov    $0x23,%eax
c0103c28:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103c2a:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c2f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103c31:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c36:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103c38:	b8 10 00 00 00       	mov    $0x10,%eax
c0103c3d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103c3f:	ea 46 3c 10 c0 08 00 	ljmp   $0x8,$0xc0103c46
}
c0103c46:	5d                   	pop    %ebp
c0103c47:	c3                   	ret    

c0103c48 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103c48:	55                   	push   %ebp
c0103c49:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c4e:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103c53:	5d                   	pop    %ebp
c0103c54:	c3                   	ret    

c0103c55 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103c55:	55                   	push   %ebp
c0103c56:	89 e5                	mov    %esp,%ebp
c0103c58:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103c5b:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103c60:	89 04 24             	mov    %eax,(%esp)
c0103c63:	e8 e0 ff ff ff       	call   c0103c48 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103c68:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103c6f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103c71:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103c78:	68 00 
c0103c7a:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c7f:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103c85:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c8a:	c1 e8 10             	shr    $0x10,%eax
c0103c8d:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103c92:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103c99:	83 e0 f0             	and    $0xfffffff0,%eax
c0103c9c:	83 c8 09             	or     $0x9,%eax
c0103c9f:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103ca4:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103cab:	83 e0 ef             	and    $0xffffffef,%eax
c0103cae:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103cb3:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103cba:	83 e0 9f             	and    $0xffffff9f,%eax
c0103cbd:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103cc2:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103cc9:	83 c8 80             	or     $0xffffff80,%eax
c0103ccc:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103cd1:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cd8:	83 e0 f0             	and    $0xfffffff0,%eax
c0103cdb:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103ce0:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103ce7:	83 e0 ef             	and    $0xffffffef,%eax
c0103cea:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cef:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103cf6:	83 e0 df             	and    $0xffffffdf,%eax
c0103cf9:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103cfe:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d05:	83 c8 40             	or     $0x40,%eax
c0103d08:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d0d:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103d14:	83 e0 7f             	and    $0x7f,%eax
c0103d17:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103d1c:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103d21:	c1 e8 18             	shr    $0x18,%eax
c0103d24:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103d29:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103d30:	e8 de fe ff ff       	call   c0103c13 <lgdt>
c0103d35:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103d3b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103d3f:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103d42:	c9                   	leave  
c0103d43:	c3                   	ret    

c0103d44 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103d44:	55                   	push   %ebp
c0103d45:	89 e5                	mov    %esp,%ebp
c0103d47:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103d4a:	c7 05 1c af 11 c0 60 	movl   $0xc0106a60,0xc011af1c
c0103d51:	6a 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103d54:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d59:	8b 00                	mov    (%eax),%eax
c0103d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d5f:	c7 04 24 fc 6a 10 c0 	movl   $0xc0106afc,(%esp)
c0103d66:	e8 e8 c5 ff ff       	call   c0100353 <cprintf>
    pmm_manager->init();
c0103d6b:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d70:	8b 40 04             	mov    0x4(%eax),%eax
c0103d73:	ff d0                	call   *%eax
}
c0103d75:	c9                   	leave  
c0103d76:	c3                   	ret    

c0103d77 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103d77:	55                   	push   %ebp
c0103d78:	89 e5                	mov    %esp,%ebp
c0103d7a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103d7d:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d82:	8b 40 08             	mov    0x8(%eax),%eax
c0103d85:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103d88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d8c:	8b 55 08             	mov    0x8(%ebp),%edx
c0103d8f:	89 14 24             	mov    %edx,(%esp)
c0103d92:	ff d0                	call   *%eax
}
c0103d94:	c9                   	leave  
c0103d95:	c3                   	ret    

c0103d96 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103d96:	55                   	push   %ebp
c0103d97:	89 e5                	mov    %esp,%ebp
c0103d99:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103d9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103da3:	e8 2e fe ff ff       	call   c0103bd6 <__intr_save>
c0103da8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103dab:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103db0:	8b 40 0c             	mov    0xc(%eax),%eax
c0103db3:	8b 55 08             	mov    0x8(%ebp),%edx
c0103db6:	89 14 24             	mov    %edx,(%esp)
c0103db9:	ff d0                	call   *%eax
c0103dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103dbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103dc1:	89 04 24             	mov    %eax,(%esp)
c0103dc4:	e8 37 fe ff ff       	call   c0103c00 <__intr_restore>
    return page;
c0103dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103dcc:	c9                   	leave  
c0103dcd:	c3                   	ret    

c0103dce <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103dce:	55                   	push   %ebp
c0103dcf:	89 e5                	mov    %esp,%ebp
c0103dd1:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103dd4:	e8 fd fd ff ff       	call   c0103bd6 <__intr_save>
c0103dd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103ddc:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103de1:	8b 40 10             	mov    0x10(%eax),%eax
c0103de4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103de7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103deb:	8b 55 08             	mov    0x8(%ebp),%edx
c0103dee:	89 14 24             	mov    %edx,(%esp)
c0103df1:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103df6:	89 04 24             	mov    %eax,(%esp)
c0103df9:	e8 02 fe ff ff       	call   c0103c00 <__intr_restore>
}
c0103dfe:	c9                   	leave  
c0103dff:	c3                   	ret    

c0103e00 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103e00:	55                   	push   %ebp
c0103e01:	89 e5                	mov    %esp,%ebp
c0103e03:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103e06:	e8 cb fd ff ff       	call   c0103bd6 <__intr_save>
c0103e0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103e0e:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103e13:	8b 40 14             	mov    0x14(%eax),%eax
c0103e16:	ff d0                	call   *%eax
c0103e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e1e:	89 04 24             	mov    %eax,(%esp)
c0103e21:	e8 da fd ff ff       	call   c0103c00 <__intr_restore>
    return ret;
c0103e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103e29:	c9                   	leave  
c0103e2a:	c3                   	ret    

c0103e2b <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103e2b:	55                   	push   %ebp
c0103e2c:	89 e5                	mov    %esp,%ebp
c0103e2e:	57                   	push   %edi
c0103e2f:	56                   	push   %esi
c0103e30:	53                   	push   %ebx
c0103e31:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103e37:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103e3e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103e45:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103e4c:	c7 04 24 13 6b 10 c0 	movl   $0xc0106b13,(%esp)
c0103e53:	e8 fb c4 ff ff       	call   c0100353 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e58:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103e5f:	e9 15 01 00 00       	jmp    c0103f79 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103e64:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e67:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e6a:	89 d0                	mov    %edx,%eax
c0103e6c:	c1 e0 02             	shl    $0x2,%eax
c0103e6f:	01 d0                	add    %edx,%eax
c0103e71:	c1 e0 02             	shl    $0x2,%eax
c0103e74:	01 c8                	add    %ecx,%eax
c0103e76:	8b 50 08             	mov    0x8(%eax),%edx
c0103e79:	8b 40 04             	mov    0x4(%eax),%eax
c0103e7c:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103e7f:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103e82:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e85:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e88:	89 d0                	mov    %edx,%eax
c0103e8a:	c1 e0 02             	shl    $0x2,%eax
c0103e8d:	01 d0                	add    %edx,%eax
c0103e8f:	c1 e0 02             	shl    $0x2,%eax
c0103e92:	01 c8                	add    %ecx,%eax
c0103e94:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103e97:	8b 58 10             	mov    0x10(%eax),%ebx
c0103e9a:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103e9d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103ea0:	01 c8                	add    %ecx,%eax
c0103ea2:	11 da                	adc    %ebx,%edx
c0103ea4:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103ea7:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103eaa:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ead:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103eb0:	89 d0                	mov    %edx,%eax
c0103eb2:	c1 e0 02             	shl    $0x2,%eax
c0103eb5:	01 d0                	add    %edx,%eax
c0103eb7:	c1 e0 02             	shl    $0x2,%eax
c0103eba:	01 c8                	add    %ecx,%eax
c0103ebc:	83 c0 14             	add    $0x14,%eax
c0103ebf:	8b 00                	mov    (%eax),%eax
c0103ec1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103ec7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103eca:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103ecd:	83 c0 ff             	add    $0xffffffff,%eax
c0103ed0:	83 d2 ff             	adc    $0xffffffff,%edx
c0103ed3:	89 c6                	mov    %eax,%esi
c0103ed5:	89 d7                	mov    %edx,%edi
c0103ed7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103edd:	89 d0                	mov    %edx,%eax
c0103edf:	c1 e0 02             	shl    $0x2,%eax
c0103ee2:	01 d0                	add    %edx,%eax
c0103ee4:	c1 e0 02             	shl    $0x2,%eax
c0103ee7:	01 c8                	add    %ecx,%eax
c0103ee9:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103eec:	8b 58 10             	mov    0x10(%eax),%ebx
c0103eef:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103ef5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103ef9:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103efd:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103f01:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103f04:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103f07:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f0b:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103f0f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103f13:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103f17:	c7 04 24 20 6b 10 c0 	movl   $0xc0106b20,(%esp)
c0103f1e:	e8 30 c4 ff ff       	call   c0100353 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103f23:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f26:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f29:	89 d0                	mov    %edx,%eax
c0103f2b:	c1 e0 02             	shl    $0x2,%eax
c0103f2e:	01 d0                	add    %edx,%eax
c0103f30:	c1 e0 02             	shl    $0x2,%eax
c0103f33:	01 c8                	add    %ecx,%eax
c0103f35:	83 c0 14             	add    $0x14,%eax
c0103f38:	8b 00                	mov    (%eax),%eax
c0103f3a:	83 f8 01             	cmp    $0x1,%eax
c0103f3d:	75 36                	jne    c0103f75 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103f3f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103f45:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f48:	77 2b                	ja     c0103f75 <page_init+0x14a>
c0103f4a:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103f4d:	72 05                	jb     c0103f54 <page_init+0x129>
c0103f4f:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103f52:	73 21                	jae    c0103f75 <page_init+0x14a>
c0103f54:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f58:	77 1b                	ja     c0103f75 <page_init+0x14a>
c0103f5a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103f5e:	72 09                	jb     c0103f69 <page_init+0x13e>
c0103f60:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103f67:	77 0c                	ja     c0103f75 <page_init+0x14a>
                maxpa = end;
c0103f69:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f6c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103f72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103f75:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103f79:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103f7c:	8b 00                	mov    (%eax),%eax
c0103f7e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103f81:	0f 8f dd fe ff ff    	jg     c0103e64 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103f87:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f8b:	72 1d                	jb     c0103faa <page_init+0x17f>
c0103f8d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103f91:	77 09                	ja     c0103f9c <page_init+0x171>
c0103f93:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103f9a:	76 0e                	jbe    c0103faa <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103f9c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103fa3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103faa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103fad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103fb0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103fb4:	c1 ea 0c             	shr    $0xc,%edx
c0103fb7:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103fbc:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103fc3:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0103fc8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103fcb:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103fce:	01 d0                	add    %edx,%eax
c0103fd0:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103fd3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103fd6:	ba 00 00 00 00       	mov    $0x0,%edx
c0103fdb:	f7 75 ac             	divl   -0x54(%ebp)
c0103fde:	89 d0                	mov    %edx,%eax
c0103fe0:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103fe3:	29 c2                	sub    %eax,%edx
c0103fe5:	89 d0                	mov    %edx,%eax
c0103fe7:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    for (i = 0; i < npage; i ++) {
c0103fec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103ff3:	eb 2f                	jmp    c0104024 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103ff5:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103ffb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103ffe:	89 d0                	mov    %edx,%eax
c0104000:	c1 e0 02             	shl    $0x2,%eax
c0104003:	01 d0                	add    %edx,%eax
c0104005:	c1 e0 02             	shl    $0x2,%eax
c0104008:	01 c8                	add    %ecx,%eax
c010400a:	83 c0 04             	add    $0x4,%eax
c010400d:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0104014:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104017:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010401a:	8b 55 90             	mov    -0x70(%ebp),%edx
c010401d:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0104020:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104024:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104027:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010402c:	39 c2                	cmp    %eax,%edx
c010402e:	72 c5                	jb     c0103ff5 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104030:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0104036:	89 d0                	mov    %edx,%eax
c0104038:	c1 e0 02             	shl    $0x2,%eax
c010403b:	01 d0                	add    %edx,%eax
c010403d:	c1 e0 02             	shl    $0x2,%eax
c0104040:	89 c2                	mov    %eax,%edx
c0104042:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0104047:	01 d0                	add    %edx,%eax
c0104049:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010404c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104053:	77 23                	ja     c0104078 <page_init+0x24d>
c0104055:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104058:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010405c:	c7 44 24 08 50 6b 10 	movl   $0xc0106b50,0x8(%esp)
c0104063:	c0 
c0104064:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010406b:	00 
c010406c:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104073:	e8 65 cc ff ff       	call   c0100cdd <__panic>
c0104078:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010407b:	05 00 00 00 40       	add    $0x40000000,%eax
c0104080:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104083:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010408a:	e9 74 01 00 00       	jmp    c0104203 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010408f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104092:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104095:	89 d0                	mov    %edx,%eax
c0104097:	c1 e0 02             	shl    $0x2,%eax
c010409a:	01 d0                	add    %edx,%eax
c010409c:	c1 e0 02             	shl    $0x2,%eax
c010409f:	01 c8                	add    %ecx,%eax
c01040a1:	8b 50 08             	mov    0x8(%eax),%edx
c01040a4:	8b 40 04             	mov    0x4(%eax),%eax
c01040a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01040aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01040ad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040b3:	89 d0                	mov    %edx,%eax
c01040b5:	c1 e0 02             	shl    $0x2,%eax
c01040b8:	01 d0                	add    %edx,%eax
c01040ba:	c1 e0 02             	shl    $0x2,%eax
c01040bd:	01 c8                	add    %ecx,%eax
c01040bf:	8b 48 0c             	mov    0xc(%eax),%ecx
c01040c2:	8b 58 10             	mov    0x10(%eax),%ebx
c01040c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01040cb:	01 c8                	add    %ecx,%eax
c01040cd:	11 da                	adc    %ebx,%edx
c01040cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01040d2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01040d5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01040d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040db:	89 d0                	mov    %edx,%eax
c01040dd:	c1 e0 02             	shl    $0x2,%eax
c01040e0:	01 d0                	add    %edx,%eax
c01040e2:	c1 e0 02             	shl    $0x2,%eax
c01040e5:	01 c8                	add    %ecx,%eax
c01040e7:	83 c0 14             	add    $0x14,%eax
c01040ea:	8b 00                	mov    (%eax),%eax
c01040ec:	83 f8 01             	cmp    $0x1,%eax
c01040ef:	0f 85 0a 01 00 00    	jne    c01041ff <page_init+0x3d4>
            if (begin < freemem) {
c01040f5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01040f8:	ba 00 00 00 00       	mov    $0x0,%edx
c01040fd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104100:	72 17                	jb     c0104119 <page_init+0x2ee>
c0104102:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104105:	77 05                	ja     c010410c <page_init+0x2e1>
c0104107:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010410a:	76 0d                	jbe    c0104119 <page_init+0x2ee>
                begin = freemem;
c010410c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010410f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104112:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104119:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010411d:	72 1d                	jb     c010413c <page_init+0x311>
c010411f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104123:	77 09                	ja     c010412e <page_init+0x303>
c0104125:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010412c:	76 0e                	jbe    c010413c <page_init+0x311>
                end = KMEMSIZE;
c010412e:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104135:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010413c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010413f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104142:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104145:	0f 87 b4 00 00 00    	ja     c01041ff <page_init+0x3d4>
c010414b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010414e:	72 09                	jb     c0104159 <page_init+0x32e>
c0104150:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104153:	0f 83 a6 00 00 00    	jae    c01041ff <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0104159:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104160:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104163:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104166:	01 d0                	add    %edx,%eax
c0104168:	83 e8 01             	sub    $0x1,%eax
c010416b:	89 45 98             	mov    %eax,-0x68(%ebp)
c010416e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104171:	ba 00 00 00 00       	mov    $0x0,%edx
c0104176:	f7 75 9c             	divl   -0x64(%ebp)
c0104179:	89 d0                	mov    %edx,%eax
c010417b:	8b 55 98             	mov    -0x68(%ebp),%edx
c010417e:	29 c2                	sub    %eax,%edx
c0104180:	89 d0                	mov    %edx,%eax
c0104182:	ba 00 00 00 00       	mov    $0x0,%edx
c0104187:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010418a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010418d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104190:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104193:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104196:	ba 00 00 00 00       	mov    $0x0,%edx
c010419b:	89 c7                	mov    %eax,%edi
c010419d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01041a3:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01041a6:	89 d0                	mov    %edx,%eax
c01041a8:	83 e0 00             	and    $0x0,%eax
c01041ab:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01041ae:	8b 45 80             	mov    -0x80(%ebp),%eax
c01041b1:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01041b4:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01041b7:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01041ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01041c0:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041c3:	77 3a                	ja     c01041ff <page_init+0x3d4>
c01041c5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01041c8:	72 05                	jb     c01041cf <page_init+0x3a4>
c01041ca:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01041cd:	73 30                	jae    c01041ff <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01041cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01041d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01041d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01041d8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01041db:	29 c8                	sub    %ecx,%eax
c01041dd:	19 da                	sbb    %ebx,%edx
c01041df:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01041e3:	c1 ea 0c             	shr    $0xc,%edx
c01041e6:	89 c3                	mov    %eax,%ebx
c01041e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01041eb:	89 04 24             	mov    %eax,(%esp)
c01041ee:	e8 a5 f8 ff ff       	call   c0103a98 <pa2page>
c01041f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041f7:	89 04 24             	mov    %eax,(%esp)
c01041fa:	e8 78 fb ff ff       	call   c0103d77 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01041ff:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104203:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104206:	8b 00                	mov    (%eax),%eax
c0104208:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010420b:	0f 8f 7e fe ff ff    	jg     c010408f <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104211:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104217:	5b                   	pop    %ebx
c0104218:	5e                   	pop    %esi
c0104219:	5f                   	pop    %edi
c010421a:	5d                   	pop    %ebp
c010421b:	c3                   	ret    

c010421c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010421c:	55                   	push   %ebp
c010421d:	89 e5                	mov    %esp,%ebp
c010421f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104222:	8b 45 14             	mov    0x14(%ebp),%eax
c0104225:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104228:	31 d0                	xor    %edx,%eax
c010422a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010422f:	85 c0                	test   %eax,%eax
c0104231:	74 24                	je     c0104257 <boot_map_segment+0x3b>
c0104233:	c7 44 24 0c 82 6b 10 	movl   $0xc0106b82,0xc(%esp)
c010423a:	c0 
c010423b:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104242:	c0 
c0104243:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010424a:	00 
c010424b:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104252:	e8 86 ca ff ff       	call   c0100cdd <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104257:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010425e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104261:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104266:	89 c2                	mov    %eax,%edx
c0104268:	8b 45 10             	mov    0x10(%ebp),%eax
c010426b:	01 c2                	add    %eax,%edx
c010426d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104270:	01 d0                	add    %edx,%eax
c0104272:	83 e8 01             	sub    $0x1,%eax
c0104275:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104278:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010427b:	ba 00 00 00 00       	mov    $0x0,%edx
c0104280:	f7 75 f0             	divl   -0x10(%ebp)
c0104283:	89 d0                	mov    %edx,%eax
c0104285:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104288:	29 c2                	sub    %eax,%edx
c010428a:	89 d0                	mov    %edx,%eax
c010428c:	c1 e8 0c             	shr    $0xc,%eax
c010428f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104292:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104295:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104298:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010429b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042a0:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01042a3:	8b 45 14             	mov    0x14(%ebp),%eax
c01042a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01042a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01042b1:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01042b4:	eb 6b                	jmp    c0104321 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01042b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01042bd:	00 
c01042be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01042c8:	89 04 24             	mov    %eax,(%esp)
c01042cb:	e8 82 01 00 00       	call   c0104452 <get_pte>
c01042d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01042d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01042d7:	75 24                	jne    c01042fd <boot_map_segment+0xe1>
c01042d9:	c7 44 24 0c ae 6b 10 	movl   $0xc0106bae,0xc(%esp)
c01042e0:	c0 
c01042e1:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c01042e8:	c0 
c01042e9:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01042f0:	00 
c01042f1:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01042f8:	e8 e0 c9 ff ff       	call   c0100cdd <__panic>
        *ptep = pa | PTE_P | perm;
c01042fd:	8b 45 18             	mov    0x18(%ebp),%eax
c0104300:	8b 55 14             	mov    0x14(%ebp),%edx
c0104303:	09 d0                	or     %edx,%eax
c0104305:	83 c8 01             	or     $0x1,%eax
c0104308:	89 c2                	mov    %eax,%edx
c010430a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010430d:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010430f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104313:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010431a:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104321:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104325:	75 8f                	jne    c01042b6 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104327:	c9                   	leave  
c0104328:	c3                   	ret    

c0104329 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104329:	55                   	push   %ebp
c010432a:	89 e5                	mov    %esp,%ebp
c010432c:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010432f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104336:	e8 5b fa ff ff       	call   c0103d96 <alloc_pages>
c010433b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010433e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104342:	75 1c                	jne    c0104360 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104344:	c7 44 24 08 bb 6b 10 	movl   $0xc0106bbb,0x8(%esp)
c010434b:	c0 
c010434c:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104353:	00 
c0104354:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c010435b:	e8 7d c9 ff ff       	call   c0100cdd <__panic>
    }
    return page2kva(p);
c0104360:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104363:	89 04 24             	mov    %eax,(%esp)
c0104366:	e8 7c f7 ff ff       	call   c0103ae7 <page2kva>
}
c010436b:	c9                   	leave  
c010436c:	c3                   	ret    

c010436d <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010436d:	55                   	push   %ebp
c010436e:	89 e5                	mov    %esp,%ebp
c0104370:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104373:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104378:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010437b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104382:	77 23                	ja     c01043a7 <pmm_init+0x3a>
c0104384:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104387:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010438b:	c7 44 24 08 50 6b 10 	movl   $0xc0106b50,0x8(%esp)
c0104392:	c0 
c0104393:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010439a:	00 
c010439b:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01043a2:	e8 36 c9 ff ff       	call   c0100cdd <__panic>
c01043a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043aa:	05 00 00 00 40       	add    $0x40000000,%eax
c01043af:	a3 20 af 11 c0       	mov    %eax,0xc011af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01043b4:	e8 8b f9 ff ff       	call   c0103d44 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01043b9:	e8 6d fa ff ff       	call   c0103e2b <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01043be:	e8 db 03 00 00       	call   c010479e <check_alloc_page>

    check_pgdir();
c01043c3:	e8 f4 03 00 00       	call   c01047bc <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01043c8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043cd:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01043d3:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01043d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01043db:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01043e2:	77 23                	ja     c0104407 <pmm_init+0x9a>
c01043e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043eb:	c7 44 24 08 50 6b 10 	movl   $0xc0106b50,0x8(%esp)
c01043f2:	c0 
c01043f3:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01043fa:	00 
c01043fb:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104402:	e8 d6 c8 ff ff       	call   c0100cdd <__panic>
c0104407:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010440a:	05 00 00 00 40       	add    $0x40000000,%eax
c010440f:	83 c8 03             	or     $0x3,%eax
c0104412:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104414:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104419:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104420:	00 
c0104421:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104428:	00 
c0104429:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104430:	38 
c0104431:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104438:	c0 
c0104439:	89 04 24             	mov    %eax,(%esp)
c010443c:	e8 db fd ff ff       	call   c010421c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104441:	e8 0f f8 ff ff       	call   c0103c55 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104446:	e8 0c 0a 00 00       	call   c0104e57 <check_boot_pgdir>

    print_pgdir();
c010444b:	e8 94 0e 00 00       	call   c01052e4 <print_pgdir>

}
c0104450:	c9                   	leave  
c0104451:	c3                   	ret    

c0104452 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104452:	55                   	push   %ebp
c0104453:	89 e5                	mov    %esp,%ebp
c0104455:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104458:	8b 45 0c             	mov    0xc(%ebp),%eax
c010445b:	c1 e8 16             	shr    $0x16,%eax
c010445e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104465:	8b 45 08             	mov    0x8(%ebp),%eax
c0104468:	01 d0                	add    %edx,%eax
c010446a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104470:	8b 00                	mov    (%eax),%eax
c0104472:	83 e0 01             	and    $0x1,%eax
c0104475:	85 c0                	test   %eax,%eax
c0104477:	0f 85 af 00 00 00    	jne    c010452c <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c010447d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104481:	74 15                	je     c0104498 <get_pte+0x46>
c0104483:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010448a:	e8 07 f9 ff ff       	call   c0103d96 <alloc_pages>
c010448f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104492:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104496:	75 0a                	jne    c01044a2 <get_pte+0x50>
            return NULL;
c0104498:	b8 00 00 00 00       	mov    $0x0,%eax
c010449d:	e9 e6 00 00 00       	jmp    c0104588 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01044a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044a9:	00 
c01044aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044ad:	89 04 24             	mov    %eax,(%esp)
c01044b0:	e8 e6 f6 ff ff       	call   c0103b9b <set_page_ref>
        uintptr_t pa = page2pa(page);
c01044b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044b8:	89 04 24             	mov    %eax,(%esp)
c01044bb:	e8 c2 f5 ff ff       	call   c0103a82 <page2pa>
c01044c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01044c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01044c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044cc:	c1 e8 0c             	shr    $0xc,%eax
c01044cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044d2:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01044d7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01044da:	72 23                	jb     c01044ff <get_pte+0xad>
c01044dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044df:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044e3:	c7 44 24 08 ac 6a 10 	movl   $0xc0106aac,0x8(%esp)
c01044ea:	c0 
c01044eb:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c01044f2:	00 
c01044f3:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01044fa:	e8 de c7 ff ff       	call   c0100cdd <__panic>
c01044ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104502:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104507:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010450e:	00 
c010450f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104516:	00 
c0104517:	89 04 24             	mov    %eax,(%esp)
c010451a:	e8 e3 18 00 00       	call   c0105e02 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c010451f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104522:	83 c8 07             	or     $0x7,%eax
c0104525:	89 c2                	mov    %eax,%edx
c0104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010452a:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010452f:	8b 00                	mov    (%eax),%eax
c0104531:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104536:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104539:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010453c:	c1 e8 0c             	shr    $0xc,%eax
c010453f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104542:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104547:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010454a:	72 23                	jb     c010456f <get_pte+0x11d>
c010454c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010454f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104553:	c7 44 24 08 ac 6a 10 	movl   $0xc0106aac,0x8(%esp)
c010455a:	c0 
c010455b:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c0104562:	00 
c0104563:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c010456a:	e8 6e c7 ff ff       	call   c0100cdd <__panic>
c010456f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104572:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104577:	8b 55 0c             	mov    0xc(%ebp),%edx
c010457a:	c1 ea 0c             	shr    $0xc,%edx
c010457d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0104583:	c1 e2 02             	shl    $0x2,%edx
c0104586:	01 d0                	add    %edx,%eax
}
c0104588:	c9                   	leave  
c0104589:	c3                   	ret    

c010458a <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010458a:	55                   	push   %ebp
c010458b:	89 e5                	mov    %esp,%ebp
c010458d:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104590:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104597:	00 
c0104598:	8b 45 0c             	mov    0xc(%ebp),%eax
c010459b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010459f:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a2:	89 04 24             	mov    %eax,(%esp)
c01045a5:	e8 a8 fe ff ff       	call   c0104452 <get_pte>
c01045aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01045ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01045b1:	74 08                	je     c01045bb <get_page+0x31>
        *ptep_store = ptep;
c01045b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01045b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01045b9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01045bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045bf:	74 1b                	je     c01045dc <get_page+0x52>
c01045c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c4:	8b 00                	mov    (%eax),%eax
c01045c6:	83 e0 01             	and    $0x1,%eax
c01045c9:	85 c0                	test   %eax,%eax
c01045cb:	74 0f                	je     c01045dc <get_page+0x52>
        return pte2page(*ptep);
c01045cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d0:	8b 00                	mov    (%eax),%eax
c01045d2:	89 04 24             	mov    %eax,(%esp)
c01045d5:	e8 61 f5 ff ff       	call   c0103b3b <pte2page>
c01045da:	eb 05                	jmp    c01045e1 <get_page+0x57>
    }
    return NULL;
c01045dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045e1:	c9                   	leave  
c01045e2:	c3                   	ret    

c01045e3 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01045e3:	55                   	push   %ebp
c01045e4:	89 e5                	mov    %esp,%ebp
c01045e6:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c01045e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01045ec:	8b 00                	mov    (%eax),%eax
c01045ee:	83 e0 01             	and    $0x1,%eax
c01045f1:	85 c0                	test   %eax,%eax
c01045f3:	74 4d                	je     c0104642 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c01045f5:	8b 45 10             	mov    0x10(%ebp),%eax
c01045f8:	8b 00                	mov    (%eax),%eax
c01045fa:	89 04 24             	mov    %eax,(%esp)
c01045fd:	e8 39 f5 ff ff       	call   c0103b3b <pte2page>
c0104602:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104608:	89 04 24             	mov    %eax,(%esp)
c010460b:	e8 af f5 ff ff       	call   c0103bbf <page_ref_dec>
c0104610:	85 c0                	test   %eax,%eax
c0104612:	75 13                	jne    c0104627 <page_remove_pte+0x44>
            free_page(page);
c0104614:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010461b:	00 
c010461c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010461f:	89 04 24             	mov    %eax,(%esp)
c0104622:	e8 a7 f7 ff ff       	call   c0103dce <free_pages>
        }
        *ptep = 0;
c0104627:	8b 45 10             	mov    0x10(%ebp),%eax
c010462a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0104630:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104633:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104637:	8b 45 08             	mov    0x8(%ebp),%eax
c010463a:	89 04 24             	mov    %eax,(%esp)
c010463d:	e8 ff 00 00 00       	call   c0104741 <tlb_invalidate>
    }
}
c0104642:	c9                   	leave  
c0104643:	c3                   	ret    

c0104644 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0104644:	55                   	push   %ebp
c0104645:	89 e5                	mov    %esp,%ebp
c0104647:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010464a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104651:	00 
c0104652:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104655:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104659:	8b 45 08             	mov    0x8(%ebp),%eax
c010465c:	89 04 24             	mov    %eax,(%esp)
c010465f:	e8 ee fd ff ff       	call   c0104452 <get_pte>
c0104664:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0104667:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010466b:	74 19                	je     c0104686 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010466d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104670:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104674:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104677:	89 44 24 04          	mov    %eax,0x4(%esp)
c010467b:	8b 45 08             	mov    0x8(%ebp),%eax
c010467e:	89 04 24             	mov    %eax,(%esp)
c0104681:	e8 5d ff ff ff       	call   c01045e3 <page_remove_pte>
    }
}
c0104686:	c9                   	leave  
c0104687:	c3                   	ret    

c0104688 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104688:	55                   	push   %ebp
c0104689:	89 e5                	mov    %esp,%ebp
c010468b:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010468e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104695:	00 
c0104696:	8b 45 10             	mov    0x10(%ebp),%eax
c0104699:	89 44 24 04          	mov    %eax,0x4(%esp)
c010469d:	8b 45 08             	mov    0x8(%ebp),%eax
c01046a0:	89 04 24             	mov    %eax,(%esp)
c01046a3:	e8 aa fd ff ff       	call   c0104452 <get_pte>
c01046a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01046ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046af:	75 0a                	jne    c01046bb <page_insert+0x33>
        return -E_NO_MEM;
c01046b1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01046b6:	e9 84 00 00 00       	jmp    c010473f <page_insert+0xb7>
    }
    page_ref_inc(page);
c01046bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046be:	89 04 24             	mov    %eax,(%esp)
c01046c1:	e8 e2 f4 ff ff       	call   c0103ba8 <page_ref_inc>
    if (*ptep & PTE_P) {
c01046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c9:	8b 00                	mov    (%eax),%eax
c01046cb:	83 e0 01             	and    $0x1,%eax
c01046ce:	85 c0                	test   %eax,%eax
c01046d0:	74 3e                	je     c0104710 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01046d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d5:	8b 00                	mov    (%eax),%eax
c01046d7:	89 04 24             	mov    %eax,(%esp)
c01046da:	e8 5c f4 ff ff       	call   c0103b3b <pte2page>
c01046df:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01046e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046e5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01046e8:	75 0d                	jne    c01046f7 <page_insert+0x6f>
            page_ref_dec(page);
c01046ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046ed:	89 04 24             	mov    %eax,(%esp)
c01046f0:	e8 ca f4 ff ff       	call   c0103bbf <page_ref_dec>
c01046f5:	eb 19                	jmp    c0104710 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01046f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046fa:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0104701:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104705:	8b 45 08             	mov    0x8(%ebp),%eax
c0104708:	89 04 24             	mov    %eax,(%esp)
c010470b:	e8 d3 fe ff ff       	call   c01045e3 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104710:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104713:	89 04 24             	mov    %eax,(%esp)
c0104716:	e8 67 f3 ff ff       	call   c0103a82 <page2pa>
c010471b:	0b 45 14             	or     0x14(%ebp),%eax
c010471e:	83 c8 01             	or     $0x1,%eax
c0104721:	89 c2                	mov    %eax,%edx
c0104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104726:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104728:	8b 45 10             	mov    0x10(%ebp),%eax
c010472b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010472f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104732:	89 04 24             	mov    %eax,(%esp)
c0104735:	e8 07 00 00 00       	call   c0104741 <tlb_invalidate>
    return 0;
c010473a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010473f:	c9                   	leave  
c0104740:	c3                   	ret    

c0104741 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104741:	55                   	push   %ebp
c0104742:	89 e5                	mov    %esp,%ebp
c0104744:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0104747:	0f 20 d8             	mov    %cr3,%eax
c010474a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010474d:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0104750:	89 c2                	mov    %eax,%edx
c0104752:	8b 45 08             	mov    0x8(%ebp),%eax
c0104755:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104758:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010475f:	77 23                	ja     c0104784 <tlb_invalidate+0x43>
c0104761:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104764:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104768:	c7 44 24 08 50 6b 10 	movl   $0xc0106b50,0x8(%esp)
c010476f:	c0 
c0104770:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0104777:	00 
c0104778:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c010477f:	e8 59 c5 ff ff       	call   c0100cdd <__panic>
c0104784:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104787:	05 00 00 00 40       	add    $0x40000000,%eax
c010478c:	39 c2                	cmp    %eax,%edx
c010478e:	75 0c                	jne    c010479c <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104793:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104796:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104799:	0f 01 38             	invlpg (%eax)
    }
}
c010479c:	c9                   	leave  
c010479d:	c3                   	ret    

c010479e <check_alloc_page>:

static void
check_alloc_page(void) {
c010479e:	55                   	push   %ebp
c010479f:	89 e5                	mov    %esp,%ebp
c01047a1:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01047a4:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c01047a9:	8b 40 18             	mov    0x18(%eax),%eax
c01047ac:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01047ae:	c7 04 24 d4 6b 10 c0 	movl   $0xc0106bd4,(%esp)
c01047b5:	e8 99 bb ff ff       	call   c0100353 <cprintf>
}
c01047ba:	c9                   	leave  
c01047bb:	c3                   	ret    

c01047bc <check_pgdir>:

static void
check_pgdir(void) {
c01047bc:	55                   	push   %ebp
c01047bd:	89 e5                	mov    %esp,%ebp
c01047bf:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01047c2:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01047c7:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01047cc:	76 24                	jbe    c01047f2 <check_pgdir+0x36>
c01047ce:	c7 44 24 0c f3 6b 10 	movl   $0xc0106bf3,0xc(%esp)
c01047d5:	c0 
c01047d6:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c01047dd:	c0 
c01047de:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c01047e5:	00 
c01047e6:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01047ed:	e8 eb c4 ff ff       	call   c0100cdd <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01047f2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01047f7:	85 c0                	test   %eax,%eax
c01047f9:	74 0e                	je     c0104809 <check_pgdir+0x4d>
c01047fb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104800:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104805:	85 c0                	test   %eax,%eax
c0104807:	74 24                	je     c010482d <check_pgdir+0x71>
c0104809:	c7 44 24 0c 10 6c 10 	movl   $0xc0106c10,0xc(%esp)
c0104810:	c0 
c0104811:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104818:	c0 
c0104819:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0104820:	00 
c0104821:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104828:	e8 b0 c4 ff ff       	call   c0100cdd <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010482d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104832:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104839:	00 
c010483a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104841:	00 
c0104842:	89 04 24             	mov    %eax,(%esp)
c0104845:	e8 40 fd ff ff       	call   c010458a <get_page>
c010484a:	85 c0                	test   %eax,%eax
c010484c:	74 24                	je     c0104872 <check_pgdir+0xb6>
c010484e:	c7 44 24 0c 48 6c 10 	movl   $0xc0106c48,0xc(%esp)
c0104855:	c0 
c0104856:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c010485d:	c0 
c010485e:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0104865:	00 
c0104866:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c010486d:	e8 6b c4 ff ff       	call   c0100cdd <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104872:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104879:	e8 18 f5 ff ff       	call   c0103d96 <alloc_pages>
c010487e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104881:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104886:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010488d:	00 
c010488e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104895:	00 
c0104896:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104899:	89 54 24 04          	mov    %edx,0x4(%esp)
c010489d:	89 04 24             	mov    %eax,(%esp)
c01048a0:	e8 e3 fd ff ff       	call   c0104688 <page_insert>
c01048a5:	85 c0                	test   %eax,%eax
c01048a7:	74 24                	je     c01048cd <check_pgdir+0x111>
c01048a9:	c7 44 24 0c 70 6c 10 	movl   $0xc0106c70,0xc(%esp)
c01048b0:	c0 
c01048b1:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c01048b8:	c0 
c01048b9:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c01048c0:	00 
c01048c1:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01048c8:	e8 10 c4 ff ff       	call   c0100cdd <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01048cd:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048d9:	00 
c01048da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048e1:	00 
c01048e2:	89 04 24             	mov    %eax,(%esp)
c01048e5:	e8 68 fb ff ff       	call   c0104452 <get_pte>
c01048ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01048f1:	75 24                	jne    c0104917 <check_pgdir+0x15b>
c01048f3:	c7 44 24 0c 9c 6c 10 	movl   $0xc0106c9c,0xc(%esp)
c01048fa:	c0 
c01048fb:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104902:	c0 
c0104903:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c010490a:	00 
c010490b:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104912:	e8 c6 c3 ff ff       	call   c0100cdd <__panic>
    assert(pte2page(*ptep) == p1);
c0104917:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010491a:	8b 00                	mov    (%eax),%eax
c010491c:	89 04 24             	mov    %eax,(%esp)
c010491f:	e8 17 f2 ff ff       	call   c0103b3b <pte2page>
c0104924:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104927:	74 24                	je     c010494d <check_pgdir+0x191>
c0104929:	c7 44 24 0c c9 6c 10 	movl   $0xc0106cc9,0xc(%esp)
c0104930:	c0 
c0104931:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104938:	c0 
c0104939:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0104940:	00 
c0104941:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104948:	e8 90 c3 ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p1) == 1);
c010494d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104950:	89 04 24             	mov    %eax,(%esp)
c0104953:	e8 39 f2 ff ff       	call   c0103b91 <page_ref>
c0104958:	83 f8 01             	cmp    $0x1,%eax
c010495b:	74 24                	je     c0104981 <check_pgdir+0x1c5>
c010495d:	c7 44 24 0c df 6c 10 	movl   $0xc0106cdf,0xc(%esp)
c0104964:	c0 
c0104965:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c010496c:	c0 
c010496d:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0104974:	00 
c0104975:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c010497c:	e8 5c c3 ff ff       	call   c0100cdd <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104981:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104986:	8b 00                	mov    (%eax),%eax
c0104988:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010498d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104990:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104993:	c1 e8 0c             	shr    $0xc,%eax
c0104996:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104999:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010499e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01049a1:	72 23                	jb     c01049c6 <check_pgdir+0x20a>
c01049a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049aa:	c7 44 24 08 ac 6a 10 	movl   $0xc0106aac,0x8(%esp)
c01049b1:	c0 
c01049b2:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c01049b9:	00 
c01049ba:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01049c1:	e8 17 c3 ff ff       	call   c0100cdd <__panic>
c01049c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049c9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01049ce:	83 c0 04             	add    $0x4,%eax
c01049d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01049d4:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01049d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049e0:	00 
c01049e1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01049e8:	00 
c01049e9:	89 04 24             	mov    %eax,(%esp)
c01049ec:	e8 61 fa ff ff       	call   c0104452 <get_pte>
c01049f1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01049f4:	74 24                	je     c0104a1a <check_pgdir+0x25e>
c01049f6:	c7 44 24 0c f4 6c 10 	movl   $0xc0106cf4,0xc(%esp)
c01049fd:	c0 
c01049fe:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104a05:	c0 
c0104a06:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0104a0d:	00 
c0104a0e:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104a15:	e8 c3 c2 ff ff       	call   c0100cdd <__panic>

    p2 = alloc_page();
c0104a1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a21:	e8 70 f3 ff ff       	call   c0103d96 <alloc_pages>
c0104a26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104a29:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a2e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104a35:	00 
c0104a36:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104a3d:	00 
c0104a3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104a41:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a45:	89 04 24             	mov    %eax,(%esp)
c0104a48:	e8 3b fc ff ff       	call   c0104688 <page_insert>
c0104a4d:	85 c0                	test   %eax,%eax
c0104a4f:	74 24                	je     c0104a75 <check_pgdir+0x2b9>
c0104a51:	c7 44 24 0c 1c 6d 10 	movl   $0xc0106d1c,0xc(%esp)
c0104a58:	c0 
c0104a59:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104a60:	c0 
c0104a61:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104a68:	00 
c0104a69:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104a70:	e8 68 c2 ff ff       	call   c0100cdd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104a75:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104a81:	00 
c0104a82:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a89:	00 
c0104a8a:	89 04 24             	mov    %eax,(%esp)
c0104a8d:	e8 c0 f9 ff ff       	call   c0104452 <get_pte>
c0104a92:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104a99:	75 24                	jne    c0104abf <check_pgdir+0x303>
c0104a9b:	c7 44 24 0c 54 6d 10 	movl   $0xc0106d54,0xc(%esp)
c0104aa2:	c0 
c0104aa3:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104aaa:	c0 
c0104aab:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0104ab2:	00 
c0104ab3:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104aba:	e8 1e c2 ff ff       	call   c0100cdd <__panic>
    assert(*ptep & PTE_U);
c0104abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ac2:	8b 00                	mov    (%eax),%eax
c0104ac4:	83 e0 04             	and    $0x4,%eax
c0104ac7:	85 c0                	test   %eax,%eax
c0104ac9:	75 24                	jne    c0104aef <check_pgdir+0x333>
c0104acb:	c7 44 24 0c 84 6d 10 	movl   $0xc0106d84,0xc(%esp)
c0104ad2:	c0 
c0104ad3:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104ada:	c0 
c0104adb:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0104ae2:	00 
c0104ae3:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104aea:	e8 ee c1 ff ff       	call   c0100cdd <__panic>
    assert(*ptep & PTE_W);
c0104aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104af2:	8b 00                	mov    (%eax),%eax
c0104af4:	83 e0 02             	and    $0x2,%eax
c0104af7:	85 c0                	test   %eax,%eax
c0104af9:	75 24                	jne    c0104b1f <check_pgdir+0x363>
c0104afb:	c7 44 24 0c 92 6d 10 	movl   $0xc0106d92,0xc(%esp)
c0104b02:	c0 
c0104b03:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104b0a:	c0 
c0104b0b:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0104b12:	00 
c0104b13:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104b1a:	e8 be c1 ff ff       	call   c0100cdd <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104b1f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b24:	8b 00                	mov    (%eax),%eax
c0104b26:	83 e0 04             	and    $0x4,%eax
c0104b29:	85 c0                	test   %eax,%eax
c0104b2b:	75 24                	jne    c0104b51 <check_pgdir+0x395>
c0104b2d:	c7 44 24 0c a0 6d 10 	movl   $0xc0106da0,0xc(%esp)
c0104b34:	c0 
c0104b35:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104b3c:	c0 
c0104b3d:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104b44:	00 
c0104b45:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104b4c:	e8 8c c1 ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p2) == 1);
c0104b51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b54:	89 04 24             	mov    %eax,(%esp)
c0104b57:	e8 35 f0 ff ff       	call   c0103b91 <page_ref>
c0104b5c:	83 f8 01             	cmp    $0x1,%eax
c0104b5f:	74 24                	je     c0104b85 <check_pgdir+0x3c9>
c0104b61:	c7 44 24 0c b6 6d 10 	movl   $0xc0106db6,0xc(%esp)
c0104b68:	c0 
c0104b69:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104b70:	c0 
c0104b71:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104b78:	00 
c0104b79:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104b80:	e8 58 c1 ff ff       	call   c0100cdd <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104b85:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104b91:	00 
c0104b92:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104b99:	00 
c0104b9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b9d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ba1:	89 04 24             	mov    %eax,(%esp)
c0104ba4:	e8 df fa ff ff       	call   c0104688 <page_insert>
c0104ba9:	85 c0                	test   %eax,%eax
c0104bab:	74 24                	je     c0104bd1 <check_pgdir+0x415>
c0104bad:	c7 44 24 0c c8 6d 10 	movl   $0xc0106dc8,0xc(%esp)
c0104bb4:	c0 
c0104bb5:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104bbc:	c0 
c0104bbd:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0104bc4:	00 
c0104bc5:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104bcc:	e8 0c c1 ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p1) == 2);
c0104bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd4:	89 04 24             	mov    %eax,(%esp)
c0104bd7:	e8 b5 ef ff ff       	call   c0103b91 <page_ref>
c0104bdc:	83 f8 02             	cmp    $0x2,%eax
c0104bdf:	74 24                	je     c0104c05 <check_pgdir+0x449>
c0104be1:	c7 44 24 0c f4 6d 10 	movl   $0xc0106df4,0xc(%esp)
c0104be8:	c0 
c0104be9:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104bf0:	c0 
c0104bf1:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0104bf8:	00 
c0104bf9:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104c00:	e8 d8 c0 ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p2) == 0);
c0104c05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c08:	89 04 24             	mov    %eax,(%esp)
c0104c0b:	e8 81 ef ff ff       	call   c0103b91 <page_ref>
c0104c10:	85 c0                	test   %eax,%eax
c0104c12:	74 24                	je     c0104c38 <check_pgdir+0x47c>
c0104c14:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104c1b:	c0 
c0104c1c:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104c23:	c0 
c0104c24:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0104c2b:	00 
c0104c2c:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104c33:	e8 a5 c0 ff ff       	call   c0100cdd <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104c38:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c44:	00 
c0104c45:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c4c:	00 
c0104c4d:	89 04 24             	mov    %eax,(%esp)
c0104c50:	e8 fd f7 ff ff       	call   c0104452 <get_pte>
c0104c55:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c5c:	75 24                	jne    c0104c82 <check_pgdir+0x4c6>
c0104c5e:	c7 44 24 0c 54 6d 10 	movl   $0xc0106d54,0xc(%esp)
c0104c65:	c0 
c0104c66:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104c6d:	c0 
c0104c6e:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0104c75:	00 
c0104c76:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104c7d:	e8 5b c0 ff ff       	call   c0100cdd <__panic>
    assert(pte2page(*ptep) == p1);
c0104c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c85:	8b 00                	mov    (%eax),%eax
c0104c87:	89 04 24             	mov    %eax,(%esp)
c0104c8a:	e8 ac ee ff ff       	call   c0103b3b <pte2page>
c0104c8f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c92:	74 24                	je     c0104cb8 <check_pgdir+0x4fc>
c0104c94:	c7 44 24 0c c9 6c 10 	movl   $0xc0106cc9,0xc(%esp)
c0104c9b:	c0 
c0104c9c:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104ca3:	c0 
c0104ca4:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104cab:	00 
c0104cac:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104cb3:	e8 25 c0 ff ff       	call   c0100cdd <__panic>
    assert((*ptep & PTE_U) == 0);
c0104cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cbb:	8b 00                	mov    (%eax),%eax
c0104cbd:	83 e0 04             	and    $0x4,%eax
c0104cc0:	85 c0                	test   %eax,%eax
c0104cc2:	74 24                	je     c0104ce8 <check_pgdir+0x52c>
c0104cc4:	c7 44 24 0c 18 6e 10 	movl   $0xc0106e18,0xc(%esp)
c0104ccb:	c0 
c0104ccc:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104cd3:	c0 
c0104cd4:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0104cdb:	00 
c0104cdc:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104ce3:	e8 f5 bf ff ff       	call   c0100cdd <__panic>

    page_remove(boot_pgdir, 0x0);
c0104ce8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ced:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cf4:	00 
c0104cf5:	89 04 24             	mov    %eax,(%esp)
c0104cf8:	e8 47 f9 ff ff       	call   c0104644 <page_remove>
    assert(page_ref(p1) == 1);
c0104cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d00:	89 04 24             	mov    %eax,(%esp)
c0104d03:	e8 89 ee ff ff       	call   c0103b91 <page_ref>
c0104d08:	83 f8 01             	cmp    $0x1,%eax
c0104d0b:	74 24                	je     c0104d31 <check_pgdir+0x575>
c0104d0d:	c7 44 24 0c df 6c 10 	movl   $0xc0106cdf,0xc(%esp)
c0104d14:	c0 
c0104d15:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104d1c:	c0 
c0104d1d:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104d24:	00 
c0104d25:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104d2c:	e8 ac bf ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p2) == 0);
c0104d31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d34:	89 04 24             	mov    %eax,(%esp)
c0104d37:	e8 55 ee ff ff       	call   c0103b91 <page_ref>
c0104d3c:	85 c0                	test   %eax,%eax
c0104d3e:	74 24                	je     c0104d64 <check_pgdir+0x5a8>
c0104d40:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104d47:	c0 
c0104d48:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104d4f:	c0 
c0104d50:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0104d57:	00 
c0104d58:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104d5f:	e8 79 bf ff ff       	call   c0100cdd <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104d64:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d69:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d70:	00 
c0104d71:	89 04 24             	mov    %eax,(%esp)
c0104d74:	e8 cb f8 ff ff       	call   c0104644 <page_remove>
    assert(page_ref(p1) == 0);
c0104d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d7c:	89 04 24             	mov    %eax,(%esp)
c0104d7f:	e8 0d ee ff ff       	call   c0103b91 <page_ref>
c0104d84:	85 c0                	test   %eax,%eax
c0104d86:	74 24                	je     c0104dac <check_pgdir+0x5f0>
c0104d88:	c7 44 24 0c 2d 6e 10 	movl   $0xc0106e2d,0xc(%esp)
c0104d8f:	c0 
c0104d90:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104d97:	c0 
c0104d98:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0104d9f:	00 
c0104da0:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104da7:	e8 31 bf ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p2) == 0);
c0104dac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104daf:	89 04 24             	mov    %eax,(%esp)
c0104db2:	e8 da ed ff ff       	call   c0103b91 <page_ref>
c0104db7:	85 c0                	test   %eax,%eax
c0104db9:	74 24                	je     c0104ddf <check_pgdir+0x623>
c0104dbb:	c7 44 24 0c 06 6e 10 	movl   $0xc0106e06,0xc(%esp)
c0104dc2:	c0 
c0104dc3:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104dca:	c0 
c0104dcb:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0104dd2:	00 
c0104dd3:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104dda:	e8 fe be ff ff       	call   c0100cdd <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104ddf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104de4:	8b 00                	mov    (%eax),%eax
c0104de6:	89 04 24             	mov    %eax,(%esp)
c0104de9:	e8 8b ed ff ff       	call   c0103b79 <pde2page>
c0104dee:	89 04 24             	mov    %eax,(%esp)
c0104df1:	e8 9b ed ff ff       	call   c0103b91 <page_ref>
c0104df6:	83 f8 01             	cmp    $0x1,%eax
c0104df9:	74 24                	je     c0104e1f <check_pgdir+0x663>
c0104dfb:	c7 44 24 0c 40 6e 10 	movl   $0xc0106e40,0xc(%esp)
c0104e02:	c0 
c0104e03:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104e0a:	c0 
c0104e0b:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104e12:	00 
c0104e13:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104e1a:	e8 be be ff ff       	call   c0100cdd <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104e1f:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e24:	8b 00                	mov    (%eax),%eax
c0104e26:	89 04 24             	mov    %eax,(%esp)
c0104e29:	e8 4b ed ff ff       	call   c0103b79 <pde2page>
c0104e2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e35:	00 
c0104e36:	89 04 24             	mov    %eax,(%esp)
c0104e39:	e8 90 ef ff ff       	call   c0103dce <free_pages>
    boot_pgdir[0] = 0;
c0104e3e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e43:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104e49:	c7 04 24 67 6e 10 c0 	movl   $0xc0106e67,(%esp)
c0104e50:	e8 fe b4 ff ff       	call   c0100353 <cprintf>
}
c0104e55:	c9                   	leave  
c0104e56:	c3                   	ret    

c0104e57 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104e57:	55                   	push   %ebp
c0104e58:	89 e5                	mov    %esp,%ebp
c0104e5a:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e64:	e9 ca 00 00 00       	jmp    c0104f33 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e72:	c1 e8 0c             	shr    $0xc,%eax
c0104e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e78:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104e7d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104e80:	72 23                	jb     c0104ea5 <check_boot_pgdir+0x4e>
c0104e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e85:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e89:	c7 44 24 08 ac 6a 10 	movl   $0xc0106aac,0x8(%esp)
c0104e90:	c0 
c0104e91:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104e98:	00 
c0104e99:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104ea0:	e8 38 be ff ff       	call   c0100cdd <__panic>
c0104ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ea8:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104ead:	89 c2                	mov    %eax,%edx
c0104eaf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104eb4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ebb:	00 
c0104ebc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104ec0:	89 04 24             	mov    %eax,(%esp)
c0104ec3:	e8 8a f5 ff ff       	call   c0104452 <get_pte>
c0104ec8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104ecb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104ecf:	75 24                	jne    c0104ef5 <check_boot_pgdir+0x9e>
c0104ed1:	c7 44 24 0c 84 6e 10 	movl   $0xc0106e84,0xc(%esp)
c0104ed8:	c0 
c0104ed9:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104ee0:	c0 
c0104ee1:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104ee8:	00 
c0104ee9:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104ef0:	e8 e8 bd ff ff       	call   c0100cdd <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104ef5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ef8:	8b 00                	mov    (%eax),%eax
c0104efa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104eff:	89 c2                	mov    %eax,%edx
c0104f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f04:	39 c2                	cmp    %eax,%edx
c0104f06:	74 24                	je     c0104f2c <check_boot_pgdir+0xd5>
c0104f08:	c7 44 24 0c c1 6e 10 	movl   $0xc0106ec1,0xc(%esp)
c0104f0f:	c0 
c0104f10:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104f17:	c0 
c0104f18:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104f1f:	00 
c0104f20:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104f27:	e8 b1 bd ff ff       	call   c0100cdd <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104f2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104f33:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f36:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104f3b:	39 c2                	cmp    %eax,%edx
c0104f3d:	0f 82 26 ff ff ff    	jb     c0104e69 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104f43:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f48:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104f4d:	8b 00                	mov    (%eax),%eax
c0104f4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f54:	89 c2                	mov    %eax,%edx
c0104f56:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104f5e:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104f65:	77 23                	ja     c0104f8a <check_boot_pgdir+0x133>
c0104f67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f6e:	c7 44 24 08 50 6b 10 	movl   $0xc0106b50,0x8(%esp)
c0104f75:	c0 
c0104f76:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104f7d:	00 
c0104f7e:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104f85:	e8 53 bd ff ff       	call   c0100cdd <__panic>
c0104f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f8d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104f92:	39 c2                	cmp    %eax,%edx
c0104f94:	74 24                	je     c0104fba <check_boot_pgdir+0x163>
c0104f96:	c7 44 24 0c d8 6e 10 	movl   $0xc0106ed8,0xc(%esp)
c0104f9d:	c0 
c0104f9e:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104fa5:	c0 
c0104fa6:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104fad:	00 
c0104fae:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104fb5:	e8 23 bd ff ff       	call   c0100cdd <__panic>

    assert(boot_pgdir[0] == 0);
c0104fba:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104fbf:	8b 00                	mov    (%eax),%eax
c0104fc1:	85 c0                	test   %eax,%eax
c0104fc3:	74 24                	je     c0104fe9 <check_boot_pgdir+0x192>
c0104fc5:	c7 44 24 0c 0c 6f 10 	movl   $0xc0106f0c,0xc(%esp)
c0104fcc:	c0 
c0104fcd:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0104fd4:	c0 
c0104fd5:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104fdc:	00 
c0104fdd:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0104fe4:	e8 f4 bc ff ff       	call   c0100cdd <__panic>

    struct Page *p;
    p = alloc_page();
c0104fe9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ff0:	e8 a1 ed ff ff       	call   c0103d96 <alloc_pages>
c0104ff5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104ff8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ffd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105004:	00 
c0105005:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010500c:	00 
c010500d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105010:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105014:	89 04 24             	mov    %eax,(%esp)
c0105017:	e8 6c f6 ff ff       	call   c0104688 <page_insert>
c010501c:	85 c0                	test   %eax,%eax
c010501e:	74 24                	je     c0105044 <check_boot_pgdir+0x1ed>
c0105020:	c7 44 24 0c 20 6f 10 	movl   $0xc0106f20,0xc(%esp)
c0105027:	c0 
c0105028:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c010502f:	c0 
c0105030:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0105037:	00 
c0105038:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c010503f:	e8 99 bc ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p) == 1);
c0105044:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105047:	89 04 24             	mov    %eax,(%esp)
c010504a:	e8 42 eb ff ff       	call   c0103b91 <page_ref>
c010504f:	83 f8 01             	cmp    $0x1,%eax
c0105052:	74 24                	je     c0105078 <check_boot_pgdir+0x221>
c0105054:	c7 44 24 0c 4e 6f 10 	movl   $0xc0106f4e,0xc(%esp)
c010505b:	c0 
c010505c:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0105063:	c0 
c0105064:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c010506b:	00 
c010506c:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0105073:	e8 65 bc ff ff       	call   c0100cdd <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105078:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010507d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105084:	00 
c0105085:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010508c:	00 
c010508d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105090:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105094:	89 04 24             	mov    %eax,(%esp)
c0105097:	e8 ec f5 ff ff       	call   c0104688 <page_insert>
c010509c:	85 c0                	test   %eax,%eax
c010509e:	74 24                	je     c01050c4 <check_boot_pgdir+0x26d>
c01050a0:	c7 44 24 0c 60 6f 10 	movl   $0xc0106f60,0xc(%esp)
c01050a7:	c0 
c01050a8:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c01050af:	c0 
c01050b0:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c01050b7:	00 
c01050b8:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01050bf:	e8 19 bc ff ff       	call   c0100cdd <__panic>
    assert(page_ref(p) == 2);
c01050c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050c7:	89 04 24             	mov    %eax,(%esp)
c01050ca:	e8 c2 ea ff ff       	call   c0103b91 <page_ref>
c01050cf:	83 f8 02             	cmp    $0x2,%eax
c01050d2:	74 24                	je     c01050f8 <check_boot_pgdir+0x2a1>
c01050d4:	c7 44 24 0c 97 6f 10 	movl   $0xc0106f97,0xc(%esp)
c01050db:	c0 
c01050dc:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c01050e3:	c0 
c01050e4:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c01050eb:	00 
c01050ec:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c01050f3:	e8 e5 bb ff ff       	call   c0100cdd <__panic>

    const char *str = "ucore: Hello world!!";
c01050f8:	c7 45 dc a8 6f 10 c0 	movl   $0xc0106fa8,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01050ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105106:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010510d:	e8 19 0a 00 00       	call   c0105b2b <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105112:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105119:	00 
c010511a:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105121:	e8 7e 0a 00 00       	call   c0105ba4 <strcmp>
c0105126:	85 c0                	test   %eax,%eax
c0105128:	74 24                	je     c010514e <check_boot_pgdir+0x2f7>
c010512a:	c7 44 24 0c c0 6f 10 	movl   $0xc0106fc0,0xc(%esp)
c0105131:	c0 
c0105132:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0105139:	c0 
c010513a:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0105141:	00 
c0105142:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0105149:	e8 8f bb ff ff       	call   c0100cdd <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010514e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105151:	89 04 24             	mov    %eax,(%esp)
c0105154:	e8 8e e9 ff ff       	call   c0103ae7 <page2kva>
c0105159:	05 00 01 00 00       	add    $0x100,%eax
c010515e:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105161:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105168:	e8 66 09 00 00       	call   c0105ad3 <strlen>
c010516d:	85 c0                	test   %eax,%eax
c010516f:	74 24                	je     c0105195 <check_boot_pgdir+0x33e>
c0105171:	c7 44 24 0c f8 6f 10 	movl   $0xc0106ff8,0xc(%esp)
c0105178:	c0 
c0105179:	c7 44 24 08 99 6b 10 	movl   $0xc0106b99,0x8(%esp)
c0105180:	c0 
c0105181:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0105188:	00 
c0105189:	c7 04 24 74 6b 10 c0 	movl   $0xc0106b74,(%esp)
c0105190:	e8 48 bb ff ff       	call   c0100cdd <__panic>

    free_page(p);
c0105195:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010519c:	00 
c010519d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051a0:	89 04 24             	mov    %eax,(%esp)
c01051a3:	e8 26 ec ff ff       	call   c0103dce <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01051a8:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01051ad:	8b 00                	mov    (%eax),%eax
c01051af:	89 04 24             	mov    %eax,(%esp)
c01051b2:	e8 c2 e9 ff ff       	call   c0103b79 <pde2page>
c01051b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051be:	00 
c01051bf:	89 04 24             	mov    %eax,(%esp)
c01051c2:	e8 07 ec ff ff       	call   c0103dce <free_pages>
    boot_pgdir[0] = 0;
c01051c7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01051cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01051d2:	c7 04 24 1c 70 10 c0 	movl   $0xc010701c,(%esp)
c01051d9:	e8 75 b1 ff ff       	call   c0100353 <cprintf>
}
c01051de:	c9                   	leave  
c01051df:	c3                   	ret    

c01051e0 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01051e0:	55                   	push   %ebp
c01051e1:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01051e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01051e6:	83 e0 04             	and    $0x4,%eax
c01051e9:	85 c0                	test   %eax,%eax
c01051eb:	74 07                	je     c01051f4 <perm2str+0x14>
c01051ed:	b8 75 00 00 00       	mov    $0x75,%eax
c01051f2:	eb 05                	jmp    c01051f9 <perm2str+0x19>
c01051f4:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01051f9:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c01051fe:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105205:	8b 45 08             	mov    0x8(%ebp),%eax
c0105208:	83 e0 02             	and    $0x2,%eax
c010520b:	85 c0                	test   %eax,%eax
c010520d:	74 07                	je     c0105216 <perm2str+0x36>
c010520f:	b8 77 00 00 00       	mov    $0x77,%eax
c0105214:	eb 05                	jmp    c010521b <perm2str+0x3b>
c0105216:	b8 2d 00 00 00       	mov    $0x2d,%eax
c010521b:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0105220:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c0105227:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c010522c:	5d                   	pop    %ebp
c010522d:	c3                   	ret    

c010522e <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c010522e:	55                   	push   %ebp
c010522f:	89 e5                	mov    %esp,%ebp
c0105231:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105234:	8b 45 10             	mov    0x10(%ebp),%eax
c0105237:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010523a:	72 0a                	jb     c0105246 <get_pgtable_items+0x18>
        return 0;
c010523c:	b8 00 00 00 00       	mov    $0x0,%eax
c0105241:	e9 9c 00 00 00       	jmp    c01052e2 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105246:	eb 04                	jmp    c010524c <get_pgtable_items+0x1e>
        start ++;
c0105248:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c010524c:	8b 45 10             	mov    0x10(%ebp),%eax
c010524f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105252:	73 18                	jae    c010526c <get_pgtable_items+0x3e>
c0105254:	8b 45 10             	mov    0x10(%ebp),%eax
c0105257:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010525e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105261:	01 d0                	add    %edx,%eax
c0105263:	8b 00                	mov    (%eax),%eax
c0105265:	83 e0 01             	and    $0x1,%eax
c0105268:	85 c0                	test   %eax,%eax
c010526a:	74 dc                	je     c0105248 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c010526c:	8b 45 10             	mov    0x10(%ebp),%eax
c010526f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105272:	73 69                	jae    c01052dd <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105274:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105278:	74 08                	je     c0105282 <get_pgtable_items+0x54>
            *left_store = start;
c010527a:	8b 45 18             	mov    0x18(%ebp),%eax
c010527d:	8b 55 10             	mov    0x10(%ebp),%edx
c0105280:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105282:	8b 45 10             	mov    0x10(%ebp),%eax
c0105285:	8d 50 01             	lea    0x1(%eax),%edx
c0105288:	89 55 10             	mov    %edx,0x10(%ebp)
c010528b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105292:	8b 45 14             	mov    0x14(%ebp),%eax
c0105295:	01 d0                	add    %edx,%eax
c0105297:	8b 00                	mov    (%eax),%eax
c0105299:	83 e0 07             	and    $0x7,%eax
c010529c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010529f:	eb 04                	jmp    c01052a5 <get_pgtable_items+0x77>
            start ++;
c01052a1:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01052a5:	8b 45 10             	mov    0x10(%ebp),%eax
c01052a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01052ab:	73 1d                	jae    c01052ca <get_pgtable_items+0x9c>
c01052ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01052b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01052b7:	8b 45 14             	mov    0x14(%ebp),%eax
c01052ba:	01 d0                	add    %edx,%eax
c01052bc:	8b 00                	mov    (%eax),%eax
c01052be:	83 e0 07             	and    $0x7,%eax
c01052c1:	89 c2                	mov    %eax,%edx
c01052c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052c6:	39 c2                	cmp    %eax,%edx
c01052c8:	74 d7                	je     c01052a1 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01052ca:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01052ce:	74 08                	je     c01052d8 <get_pgtable_items+0xaa>
            *right_store = start;
c01052d0:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01052d3:	8b 55 10             	mov    0x10(%ebp),%edx
c01052d6:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01052d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052db:	eb 05                	jmp    c01052e2 <get_pgtable_items+0xb4>
    }
    return 0;
c01052dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01052e2:	c9                   	leave  
c01052e3:	c3                   	ret    

c01052e4 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01052e4:	55                   	push   %ebp
c01052e5:	89 e5                	mov    %esp,%ebp
c01052e7:	57                   	push   %edi
c01052e8:	56                   	push   %esi
c01052e9:	53                   	push   %ebx
c01052ea:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01052ed:	c7 04 24 3c 70 10 c0 	movl   $0xc010703c,(%esp)
c01052f4:	e8 5a b0 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
c01052f9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105300:	e9 fa 00 00 00       	jmp    c01053ff <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105305:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105308:	89 04 24             	mov    %eax,(%esp)
c010530b:	e8 d0 fe ff ff       	call   c01051e0 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105310:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105313:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105316:	29 d1                	sub    %edx,%ecx
c0105318:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010531a:	89 d6                	mov    %edx,%esi
c010531c:	c1 e6 16             	shl    $0x16,%esi
c010531f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105322:	89 d3                	mov    %edx,%ebx
c0105324:	c1 e3 16             	shl    $0x16,%ebx
c0105327:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010532a:	89 d1                	mov    %edx,%ecx
c010532c:	c1 e1 16             	shl    $0x16,%ecx
c010532f:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105332:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105335:	29 d7                	sub    %edx,%edi
c0105337:	89 fa                	mov    %edi,%edx
c0105339:	89 44 24 14          	mov    %eax,0x14(%esp)
c010533d:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105341:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105345:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105349:	89 54 24 04          	mov    %edx,0x4(%esp)
c010534d:	c7 04 24 6d 70 10 c0 	movl   $0xc010706d,(%esp)
c0105354:	e8 fa af ff ff       	call   c0100353 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105359:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010535c:	c1 e0 0a             	shl    $0xa,%eax
c010535f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105362:	eb 54                	jmp    c01053b8 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105364:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105367:	89 04 24             	mov    %eax,(%esp)
c010536a:	e8 71 fe ff ff       	call   c01051e0 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010536f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105372:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105375:	29 d1                	sub    %edx,%ecx
c0105377:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105379:	89 d6                	mov    %edx,%esi
c010537b:	c1 e6 0c             	shl    $0xc,%esi
c010537e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105381:	89 d3                	mov    %edx,%ebx
c0105383:	c1 e3 0c             	shl    $0xc,%ebx
c0105386:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105389:	c1 e2 0c             	shl    $0xc,%edx
c010538c:	89 d1                	mov    %edx,%ecx
c010538e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105391:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105394:	29 d7                	sub    %edx,%edi
c0105396:	89 fa                	mov    %edi,%edx
c0105398:	89 44 24 14          	mov    %eax,0x14(%esp)
c010539c:	89 74 24 10          	mov    %esi,0x10(%esp)
c01053a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01053a4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01053a8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01053ac:	c7 04 24 8c 70 10 c0 	movl   $0xc010708c,(%esp)
c01053b3:	e8 9b af ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01053b8:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01053bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01053c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01053c3:	89 ce                	mov    %ecx,%esi
c01053c5:	c1 e6 0a             	shl    $0xa,%esi
c01053c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01053cb:	89 cb                	mov    %ecx,%ebx
c01053cd:	c1 e3 0a             	shl    $0xa,%ebx
c01053d0:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01053d3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01053d7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01053da:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01053de:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01053e2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01053e6:	89 74 24 04          	mov    %esi,0x4(%esp)
c01053ea:	89 1c 24             	mov    %ebx,(%esp)
c01053ed:	e8 3c fe ff ff       	call   c010522e <get_pgtable_items>
c01053f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01053f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01053f9:	0f 85 65 ff ff ff    	jne    c0105364 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01053ff:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105404:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105407:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c010540a:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c010540e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105411:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105415:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105419:	89 44 24 08          	mov    %eax,0x8(%esp)
c010541d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105424:	00 
c0105425:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010542c:	e8 fd fd ff ff       	call   c010522e <get_pgtable_items>
c0105431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105438:	0f 85 c7 fe ff ff    	jne    c0105305 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c010543e:	c7 04 24 b0 70 10 c0 	movl   $0xc01070b0,(%esp)
c0105445:	e8 09 af ff ff       	call   c0100353 <cprintf>
}
c010544a:	83 c4 4c             	add    $0x4c,%esp
c010544d:	5b                   	pop    %ebx
c010544e:	5e                   	pop    %esi
c010544f:	5f                   	pop    %edi
c0105450:	5d                   	pop    %ebp
c0105451:	c3                   	ret    

c0105452 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105452:	55                   	push   %ebp
c0105453:	89 e5                	mov    %esp,%ebp
c0105455:	83 ec 58             	sub    $0x58,%esp
c0105458:	8b 45 10             	mov    0x10(%ebp),%eax
c010545b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010545e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105461:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105464:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105467:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010546a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010546d:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105470:	8b 45 18             	mov    0x18(%ebp),%eax
c0105473:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105476:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105479:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010547c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010547f:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105482:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105485:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105488:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010548c:	74 1c                	je     c01054aa <printnum+0x58>
c010548e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105491:	ba 00 00 00 00       	mov    $0x0,%edx
c0105496:	f7 75 e4             	divl   -0x1c(%ebp)
c0105499:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010549c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010549f:	ba 00 00 00 00       	mov    $0x0,%edx
c01054a4:	f7 75 e4             	divl   -0x1c(%ebp)
c01054a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01054aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054b0:	f7 75 e4             	divl   -0x1c(%ebp)
c01054b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01054b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01054b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01054bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01054bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054c2:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01054c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054c8:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01054cb:	8b 45 18             	mov    0x18(%ebp),%eax
c01054ce:	ba 00 00 00 00       	mov    $0x0,%edx
c01054d3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054d6:	77 56                	ja     c010552e <printnum+0xdc>
c01054d8:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054db:	72 05                	jb     c01054e2 <printnum+0x90>
c01054dd:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01054e0:	77 4c                	ja     c010552e <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01054e2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01054e5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01054e8:	8b 45 20             	mov    0x20(%ebp),%eax
c01054eb:	89 44 24 18          	mov    %eax,0x18(%esp)
c01054ef:	89 54 24 14          	mov    %edx,0x14(%esp)
c01054f3:	8b 45 18             	mov    0x18(%ebp),%eax
c01054f6:	89 44 24 10          	mov    %eax,0x10(%esp)
c01054fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105500:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105504:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105508:	8b 45 0c             	mov    0xc(%ebp),%eax
c010550b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010550f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105512:	89 04 24             	mov    %eax,(%esp)
c0105515:	e8 38 ff ff ff       	call   c0105452 <printnum>
c010551a:	eb 1c                	jmp    c0105538 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010551c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010551f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105523:	8b 45 20             	mov    0x20(%ebp),%eax
c0105526:	89 04 24             	mov    %eax,(%esp)
c0105529:	8b 45 08             	mov    0x8(%ebp),%eax
c010552c:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010552e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0105532:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105536:	7f e4                	jg     c010551c <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105538:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010553b:	05 64 71 10 c0       	add    $0xc0107164,%eax
c0105540:	0f b6 00             	movzbl (%eax),%eax
c0105543:	0f be c0             	movsbl %al,%eax
c0105546:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105549:	89 54 24 04          	mov    %edx,0x4(%esp)
c010554d:	89 04 24             	mov    %eax,(%esp)
c0105550:	8b 45 08             	mov    0x8(%ebp),%eax
c0105553:	ff d0                	call   *%eax
}
c0105555:	c9                   	leave  
c0105556:	c3                   	ret    

c0105557 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105557:	55                   	push   %ebp
c0105558:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010555a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010555e:	7e 14                	jle    c0105574 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105560:	8b 45 08             	mov    0x8(%ebp),%eax
c0105563:	8b 00                	mov    (%eax),%eax
c0105565:	8d 48 08             	lea    0x8(%eax),%ecx
c0105568:	8b 55 08             	mov    0x8(%ebp),%edx
c010556b:	89 0a                	mov    %ecx,(%edx)
c010556d:	8b 50 04             	mov    0x4(%eax),%edx
c0105570:	8b 00                	mov    (%eax),%eax
c0105572:	eb 30                	jmp    c01055a4 <getuint+0x4d>
    }
    else if (lflag) {
c0105574:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105578:	74 16                	je     c0105590 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010557a:	8b 45 08             	mov    0x8(%ebp),%eax
c010557d:	8b 00                	mov    (%eax),%eax
c010557f:	8d 48 04             	lea    0x4(%eax),%ecx
c0105582:	8b 55 08             	mov    0x8(%ebp),%edx
c0105585:	89 0a                	mov    %ecx,(%edx)
c0105587:	8b 00                	mov    (%eax),%eax
c0105589:	ba 00 00 00 00       	mov    $0x0,%edx
c010558e:	eb 14                	jmp    c01055a4 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105590:	8b 45 08             	mov    0x8(%ebp),%eax
c0105593:	8b 00                	mov    (%eax),%eax
c0105595:	8d 48 04             	lea    0x4(%eax),%ecx
c0105598:	8b 55 08             	mov    0x8(%ebp),%edx
c010559b:	89 0a                	mov    %ecx,(%edx)
c010559d:	8b 00                	mov    (%eax),%eax
c010559f:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01055a4:	5d                   	pop    %ebp
c01055a5:	c3                   	ret    

c01055a6 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01055a6:	55                   	push   %ebp
c01055a7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01055a9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01055ad:	7e 14                	jle    c01055c3 <getint+0x1d>
        return va_arg(*ap, long long);
c01055af:	8b 45 08             	mov    0x8(%ebp),%eax
c01055b2:	8b 00                	mov    (%eax),%eax
c01055b4:	8d 48 08             	lea    0x8(%eax),%ecx
c01055b7:	8b 55 08             	mov    0x8(%ebp),%edx
c01055ba:	89 0a                	mov    %ecx,(%edx)
c01055bc:	8b 50 04             	mov    0x4(%eax),%edx
c01055bf:	8b 00                	mov    (%eax),%eax
c01055c1:	eb 28                	jmp    c01055eb <getint+0x45>
    }
    else if (lflag) {
c01055c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01055c7:	74 12                	je     c01055db <getint+0x35>
        return va_arg(*ap, long);
c01055c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01055cc:	8b 00                	mov    (%eax),%eax
c01055ce:	8d 48 04             	lea    0x4(%eax),%ecx
c01055d1:	8b 55 08             	mov    0x8(%ebp),%edx
c01055d4:	89 0a                	mov    %ecx,(%edx)
c01055d6:	8b 00                	mov    (%eax),%eax
c01055d8:	99                   	cltd   
c01055d9:	eb 10                	jmp    c01055eb <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01055db:	8b 45 08             	mov    0x8(%ebp),%eax
c01055de:	8b 00                	mov    (%eax),%eax
c01055e0:	8d 48 04             	lea    0x4(%eax),%ecx
c01055e3:	8b 55 08             	mov    0x8(%ebp),%edx
c01055e6:	89 0a                	mov    %ecx,(%edx)
c01055e8:	8b 00                	mov    (%eax),%eax
c01055ea:	99                   	cltd   
    }
}
c01055eb:	5d                   	pop    %ebp
c01055ec:	c3                   	ret    

c01055ed <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01055ed:	55                   	push   %ebp
c01055ee:	89 e5                	mov    %esp,%ebp
c01055f0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01055f3:	8d 45 14             	lea    0x14(%ebp),%eax
c01055f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01055f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105600:	8b 45 10             	mov    0x10(%ebp),%eax
c0105603:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105607:	8b 45 0c             	mov    0xc(%ebp),%eax
c010560a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010560e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105611:	89 04 24             	mov    %eax,(%esp)
c0105614:	e8 02 00 00 00       	call   c010561b <vprintfmt>
    va_end(ap);
}
c0105619:	c9                   	leave  
c010561a:	c3                   	ret    

c010561b <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010561b:	55                   	push   %ebp
c010561c:	89 e5                	mov    %esp,%ebp
c010561e:	56                   	push   %esi
c010561f:	53                   	push   %ebx
c0105620:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105623:	eb 18                	jmp    c010563d <vprintfmt+0x22>
            if (ch == '\0') {
c0105625:	85 db                	test   %ebx,%ebx
c0105627:	75 05                	jne    c010562e <vprintfmt+0x13>
                return;
c0105629:	e9 d1 03 00 00       	jmp    c01059ff <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010562e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105631:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105635:	89 1c 24             	mov    %ebx,(%esp)
c0105638:	8b 45 08             	mov    0x8(%ebp),%eax
c010563b:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010563d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105640:	8d 50 01             	lea    0x1(%eax),%edx
c0105643:	89 55 10             	mov    %edx,0x10(%ebp)
c0105646:	0f b6 00             	movzbl (%eax),%eax
c0105649:	0f b6 d8             	movzbl %al,%ebx
c010564c:	83 fb 25             	cmp    $0x25,%ebx
c010564f:	75 d4                	jne    c0105625 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105651:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105655:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010565c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010565f:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105662:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105669:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010566c:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010566f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105672:	8d 50 01             	lea    0x1(%eax),%edx
c0105675:	89 55 10             	mov    %edx,0x10(%ebp)
c0105678:	0f b6 00             	movzbl (%eax),%eax
c010567b:	0f b6 d8             	movzbl %al,%ebx
c010567e:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105681:	83 f8 55             	cmp    $0x55,%eax
c0105684:	0f 87 44 03 00 00    	ja     c01059ce <vprintfmt+0x3b3>
c010568a:	8b 04 85 88 71 10 c0 	mov    -0x3fef8e78(,%eax,4),%eax
c0105691:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105693:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105697:	eb d6                	jmp    c010566f <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105699:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010569d:	eb d0                	jmp    c010566f <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010569f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01056a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01056a9:	89 d0                	mov    %edx,%eax
c01056ab:	c1 e0 02             	shl    $0x2,%eax
c01056ae:	01 d0                	add    %edx,%eax
c01056b0:	01 c0                	add    %eax,%eax
c01056b2:	01 d8                	add    %ebx,%eax
c01056b4:	83 e8 30             	sub    $0x30,%eax
c01056b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01056ba:	8b 45 10             	mov    0x10(%ebp),%eax
c01056bd:	0f b6 00             	movzbl (%eax),%eax
c01056c0:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01056c3:	83 fb 2f             	cmp    $0x2f,%ebx
c01056c6:	7e 0b                	jle    c01056d3 <vprintfmt+0xb8>
c01056c8:	83 fb 39             	cmp    $0x39,%ebx
c01056cb:	7f 06                	jg     c01056d3 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01056cd:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01056d1:	eb d3                	jmp    c01056a6 <vprintfmt+0x8b>
            goto process_precision;
c01056d3:	eb 33                	jmp    c0105708 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01056d5:	8b 45 14             	mov    0x14(%ebp),%eax
c01056d8:	8d 50 04             	lea    0x4(%eax),%edx
c01056db:	89 55 14             	mov    %edx,0x14(%ebp)
c01056de:	8b 00                	mov    (%eax),%eax
c01056e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01056e3:	eb 23                	jmp    c0105708 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01056e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056e9:	79 0c                	jns    c01056f7 <vprintfmt+0xdc>
                width = 0;
c01056eb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01056f2:	e9 78 ff ff ff       	jmp    c010566f <vprintfmt+0x54>
c01056f7:	e9 73 ff ff ff       	jmp    c010566f <vprintfmt+0x54>

        case '#':
            altflag = 1;
c01056fc:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105703:	e9 67 ff ff ff       	jmp    c010566f <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0105708:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010570c:	79 12                	jns    c0105720 <vprintfmt+0x105>
                width = precision, precision = -1;
c010570e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105711:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105714:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010571b:	e9 4f ff ff ff       	jmp    c010566f <vprintfmt+0x54>
c0105720:	e9 4a ff ff ff       	jmp    c010566f <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105725:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105729:	e9 41 ff ff ff       	jmp    c010566f <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010572e:	8b 45 14             	mov    0x14(%ebp),%eax
c0105731:	8d 50 04             	lea    0x4(%eax),%edx
c0105734:	89 55 14             	mov    %edx,0x14(%ebp)
c0105737:	8b 00                	mov    (%eax),%eax
c0105739:	8b 55 0c             	mov    0xc(%ebp),%edx
c010573c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105740:	89 04 24             	mov    %eax,(%esp)
c0105743:	8b 45 08             	mov    0x8(%ebp),%eax
c0105746:	ff d0                	call   *%eax
            break;
c0105748:	e9 ac 02 00 00       	jmp    c01059f9 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010574d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105750:	8d 50 04             	lea    0x4(%eax),%edx
c0105753:	89 55 14             	mov    %edx,0x14(%ebp)
c0105756:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105758:	85 db                	test   %ebx,%ebx
c010575a:	79 02                	jns    c010575e <vprintfmt+0x143>
                err = -err;
c010575c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010575e:	83 fb 06             	cmp    $0x6,%ebx
c0105761:	7f 0b                	jg     c010576e <vprintfmt+0x153>
c0105763:	8b 34 9d 48 71 10 c0 	mov    -0x3fef8eb8(,%ebx,4),%esi
c010576a:	85 f6                	test   %esi,%esi
c010576c:	75 23                	jne    c0105791 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010576e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105772:	c7 44 24 08 75 71 10 	movl   $0xc0107175,0x8(%esp)
c0105779:	c0 
c010577a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010577d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105781:	8b 45 08             	mov    0x8(%ebp),%eax
c0105784:	89 04 24             	mov    %eax,(%esp)
c0105787:	e8 61 fe ff ff       	call   c01055ed <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010578c:	e9 68 02 00 00       	jmp    c01059f9 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105791:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105795:	c7 44 24 08 7e 71 10 	movl   $0xc010717e,0x8(%esp)
c010579c:	c0 
c010579d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a7:	89 04 24             	mov    %eax,(%esp)
c01057aa:	e8 3e fe ff ff       	call   c01055ed <printfmt>
            }
            break;
c01057af:	e9 45 02 00 00       	jmp    c01059f9 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01057b4:	8b 45 14             	mov    0x14(%ebp),%eax
c01057b7:	8d 50 04             	lea    0x4(%eax),%edx
c01057ba:	89 55 14             	mov    %edx,0x14(%ebp)
c01057bd:	8b 30                	mov    (%eax),%esi
c01057bf:	85 f6                	test   %esi,%esi
c01057c1:	75 05                	jne    c01057c8 <vprintfmt+0x1ad>
                p = "(null)";
c01057c3:	be 81 71 10 c0       	mov    $0xc0107181,%esi
            }
            if (width > 0 && padc != '-') {
c01057c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057cc:	7e 3e                	jle    c010580c <vprintfmt+0x1f1>
c01057ce:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01057d2:	74 38                	je     c010580c <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01057d4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01057d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057de:	89 34 24             	mov    %esi,(%esp)
c01057e1:	e8 15 03 00 00       	call   c0105afb <strnlen>
c01057e6:	29 c3                	sub    %eax,%ebx
c01057e8:	89 d8                	mov    %ebx,%eax
c01057ea:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057ed:	eb 17                	jmp    c0105806 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01057ef:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01057f3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057f6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057fa:	89 04 24             	mov    %eax,(%esp)
c01057fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105800:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105802:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105806:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010580a:	7f e3                	jg     c01057ef <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010580c:	eb 38                	jmp    c0105846 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010580e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105812:	74 1f                	je     c0105833 <vprintfmt+0x218>
c0105814:	83 fb 1f             	cmp    $0x1f,%ebx
c0105817:	7e 05                	jle    c010581e <vprintfmt+0x203>
c0105819:	83 fb 7e             	cmp    $0x7e,%ebx
c010581c:	7e 15                	jle    c0105833 <vprintfmt+0x218>
                    putch('?', putdat);
c010581e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105821:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105825:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010582c:	8b 45 08             	mov    0x8(%ebp),%eax
c010582f:	ff d0                	call   *%eax
c0105831:	eb 0f                	jmp    c0105842 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c0105833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105836:	89 44 24 04          	mov    %eax,0x4(%esp)
c010583a:	89 1c 24             	mov    %ebx,(%esp)
c010583d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105840:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105842:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105846:	89 f0                	mov    %esi,%eax
c0105848:	8d 70 01             	lea    0x1(%eax),%esi
c010584b:	0f b6 00             	movzbl (%eax),%eax
c010584e:	0f be d8             	movsbl %al,%ebx
c0105851:	85 db                	test   %ebx,%ebx
c0105853:	74 10                	je     c0105865 <vprintfmt+0x24a>
c0105855:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105859:	78 b3                	js     c010580e <vprintfmt+0x1f3>
c010585b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010585f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105863:	79 a9                	jns    c010580e <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105865:	eb 17                	jmp    c010587e <vprintfmt+0x263>
                putch(' ', putdat);
c0105867:	8b 45 0c             	mov    0xc(%ebp),%eax
c010586a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010586e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105875:	8b 45 08             	mov    0x8(%ebp),%eax
c0105878:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010587a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010587e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105882:	7f e3                	jg     c0105867 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c0105884:	e9 70 01 00 00       	jmp    c01059f9 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105889:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010588c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105890:	8d 45 14             	lea    0x14(%ebp),%eax
c0105893:	89 04 24             	mov    %eax,(%esp)
c0105896:	e8 0b fd ff ff       	call   c01055a6 <getint>
c010589b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010589e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01058a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058a7:	85 d2                	test   %edx,%edx
c01058a9:	79 26                	jns    c01058d1 <vprintfmt+0x2b6>
                putch('-', putdat);
c01058ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058b2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01058b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01058bc:	ff d0                	call   *%eax
                num = -(long long)num;
c01058be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058c4:	f7 d8                	neg    %eax
c01058c6:	83 d2 00             	adc    $0x0,%edx
c01058c9:	f7 da                	neg    %edx
c01058cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01058d1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058d8:	e9 a8 00 00 00       	jmp    c0105985 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01058dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01058e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e4:	8d 45 14             	lea    0x14(%ebp),%eax
c01058e7:	89 04 24             	mov    %eax,(%esp)
c01058ea:	e8 68 fc ff ff       	call   c0105557 <getuint>
c01058ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01058f5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01058fc:	e9 84 00 00 00       	jmp    c0105985 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105901:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105904:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105908:	8d 45 14             	lea    0x14(%ebp),%eax
c010590b:	89 04 24             	mov    %eax,(%esp)
c010590e:	e8 44 fc ff ff       	call   c0105557 <getuint>
c0105913:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105916:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105919:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105920:	eb 63                	jmp    c0105985 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0105922:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105925:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105929:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105930:	8b 45 08             	mov    0x8(%ebp),%eax
c0105933:	ff d0                	call   *%eax
            putch('x', putdat);
c0105935:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105938:	89 44 24 04          	mov    %eax,0x4(%esp)
c010593c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105943:	8b 45 08             	mov    0x8(%ebp),%eax
c0105946:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105948:	8b 45 14             	mov    0x14(%ebp),%eax
c010594b:	8d 50 04             	lea    0x4(%eax),%edx
c010594e:	89 55 14             	mov    %edx,0x14(%ebp)
c0105951:	8b 00                	mov    (%eax),%eax
c0105953:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105956:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010595d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105964:	eb 1f                	jmp    c0105985 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105966:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105969:	89 44 24 04          	mov    %eax,0x4(%esp)
c010596d:	8d 45 14             	lea    0x14(%ebp),%eax
c0105970:	89 04 24             	mov    %eax,(%esp)
c0105973:	e8 df fb ff ff       	call   c0105557 <getuint>
c0105978:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010597b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010597e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105985:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105989:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010598c:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105990:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105993:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105997:	89 44 24 10          	mov    %eax,0x10(%esp)
c010599b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010599e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059a1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01059a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01059b3:	89 04 24             	mov    %eax,(%esp)
c01059b6:	e8 97 fa ff ff       	call   c0105452 <printnum>
            break;
c01059bb:	eb 3c                	jmp    c01059f9 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01059bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059c4:	89 1c 24             	mov    %ebx,(%esp)
c01059c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059ca:	ff d0                	call   *%eax
            break;
c01059cc:	eb 2b                	jmp    c01059f9 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01059ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059d5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01059dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01059df:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01059e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01059e5:	eb 04                	jmp    c01059eb <vprintfmt+0x3d0>
c01059e7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01059eb:	8b 45 10             	mov    0x10(%ebp),%eax
c01059ee:	83 e8 01             	sub    $0x1,%eax
c01059f1:	0f b6 00             	movzbl (%eax),%eax
c01059f4:	3c 25                	cmp    $0x25,%al
c01059f6:	75 ef                	jne    c01059e7 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c01059f8:	90                   	nop
        }
    }
c01059f9:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01059fa:	e9 3e fc ff ff       	jmp    c010563d <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01059ff:	83 c4 40             	add    $0x40,%esp
c0105a02:	5b                   	pop    %ebx
c0105a03:	5e                   	pop    %esi
c0105a04:	5d                   	pop    %ebp
c0105a05:	c3                   	ret    

c0105a06 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105a06:	55                   	push   %ebp
c0105a07:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105a09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a0c:	8b 40 08             	mov    0x8(%eax),%eax
c0105a0f:	8d 50 01             	lea    0x1(%eax),%edx
c0105a12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a15:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a1b:	8b 10                	mov    (%eax),%edx
c0105a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a20:	8b 40 04             	mov    0x4(%eax),%eax
c0105a23:	39 c2                	cmp    %eax,%edx
c0105a25:	73 12                	jae    c0105a39 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105a27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a2a:	8b 00                	mov    (%eax),%eax
c0105a2c:	8d 48 01             	lea    0x1(%eax),%ecx
c0105a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a32:	89 0a                	mov    %ecx,(%edx)
c0105a34:	8b 55 08             	mov    0x8(%ebp),%edx
c0105a37:	88 10                	mov    %dl,(%eax)
    }
}
c0105a39:	5d                   	pop    %ebp
c0105a3a:	c3                   	ret    

c0105a3b <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105a3b:	55                   	push   %ebp
c0105a3c:	89 e5                	mov    %esp,%ebp
c0105a3e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105a41:	8d 45 14             	lea    0x14(%ebp),%eax
c0105a44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a4e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a51:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105a55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a5f:	89 04 24             	mov    %eax,(%esp)
c0105a62:	e8 08 00 00 00       	call   c0105a6f <vsnprintf>
c0105a67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105a6d:	c9                   	leave  
c0105a6e:	c3                   	ret    

c0105a6f <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105a6f:	55                   	push   %ebp
c0105a70:	89 e5                	mov    %esp,%ebp
c0105a72:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105a75:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a78:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a7e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a81:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a84:	01 d0                	add    %edx,%eax
c0105a86:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105a90:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a94:	74 0a                	je     c0105aa0 <vsnprintf+0x31>
c0105a96:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105a99:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a9c:	39 c2                	cmp    %eax,%edx
c0105a9e:	76 07                	jbe    c0105aa7 <vsnprintf+0x38>
        return -E_INVAL;
c0105aa0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105aa5:	eb 2a                	jmp    c0105ad1 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105aa7:	8b 45 14             	mov    0x14(%ebp),%eax
c0105aaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105aae:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ab1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ab5:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105abc:	c7 04 24 06 5a 10 c0 	movl   $0xc0105a06,(%esp)
c0105ac3:	e8 53 fb ff ff       	call   c010561b <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105acb:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105ad1:	c9                   	leave  
c0105ad2:	c3                   	ret    

c0105ad3 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105ad3:	55                   	push   %ebp
c0105ad4:	89 e5                	mov    %esp,%ebp
c0105ad6:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105ad9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105ae0:	eb 04                	jmp    c0105ae6 <strlen+0x13>
        cnt ++;
c0105ae2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae9:	8d 50 01             	lea    0x1(%eax),%edx
c0105aec:	89 55 08             	mov    %edx,0x8(%ebp)
c0105aef:	0f b6 00             	movzbl (%eax),%eax
c0105af2:	84 c0                	test   %al,%al
c0105af4:	75 ec                	jne    c0105ae2 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0105af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105af9:	c9                   	leave  
c0105afa:	c3                   	ret    

c0105afb <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105afb:	55                   	push   %ebp
c0105afc:	89 e5                	mov    %esp,%ebp
c0105afe:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105b01:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105b08:	eb 04                	jmp    c0105b0e <strnlen+0x13>
        cnt ++;
c0105b0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105b0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b11:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105b14:	73 10                	jae    c0105b26 <strnlen+0x2b>
c0105b16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b19:	8d 50 01             	lea    0x1(%eax),%edx
c0105b1c:	89 55 08             	mov    %edx,0x8(%ebp)
c0105b1f:	0f b6 00             	movzbl (%eax),%eax
c0105b22:	84 c0                	test   %al,%al
c0105b24:	75 e4                	jne    c0105b0a <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105b26:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105b29:	c9                   	leave  
c0105b2a:	c3                   	ret    

c0105b2b <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105b2b:	55                   	push   %ebp
c0105b2c:	89 e5                	mov    %esp,%ebp
c0105b2e:	57                   	push   %edi
c0105b2f:	56                   	push   %esi
c0105b30:	83 ec 20             	sub    $0x20,%esp
c0105b33:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b45:	89 d1                	mov    %edx,%ecx
c0105b47:	89 c2                	mov    %eax,%edx
c0105b49:	89 ce                	mov    %ecx,%esi
c0105b4b:	89 d7                	mov    %edx,%edi
c0105b4d:	ac                   	lods   %ds:(%esi),%al
c0105b4e:	aa                   	stos   %al,%es:(%edi)
c0105b4f:	84 c0                	test   %al,%al
c0105b51:	75 fa                	jne    c0105b4d <strcpy+0x22>
c0105b53:	89 fa                	mov    %edi,%edx
c0105b55:	89 f1                	mov    %esi,%ecx
c0105b57:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105b5a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105b5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105b63:	83 c4 20             	add    $0x20,%esp
c0105b66:	5e                   	pop    %esi
c0105b67:	5f                   	pop    %edi
c0105b68:	5d                   	pop    %ebp
c0105b69:	c3                   	ret    

c0105b6a <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105b6a:	55                   	push   %ebp
c0105b6b:	89 e5                	mov    %esp,%ebp
c0105b6d:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105b70:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b73:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105b76:	eb 21                	jmp    c0105b99 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105b78:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b7b:	0f b6 10             	movzbl (%eax),%edx
c0105b7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b81:	88 10                	mov    %dl,(%eax)
c0105b83:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b86:	0f b6 00             	movzbl (%eax),%eax
c0105b89:	84 c0                	test   %al,%al
c0105b8b:	74 04                	je     c0105b91 <strncpy+0x27>
            src ++;
c0105b8d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105b91:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105b95:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105b99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b9d:	75 d9                	jne    c0105b78 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105b9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ba2:	c9                   	leave  
c0105ba3:	c3                   	ret    

c0105ba4 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105ba4:	55                   	push   %ebp
c0105ba5:	89 e5                	mov    %esp,%ebp
c0105ba7:	57                   	push   %edi
c0105ba8:	56                   	push   %esi
c0105ba9:	83 ec 20             	sub    $0x20,%esp
c0105bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0105baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bbe:	89 d1                	mov    %edx,%ecx
c0105bc0:	89 c2                	mov    %eax,%edx
c0105bc2:	89 ce                	mov    %ecx,%esi
c0105bc4:	89 d7                	mov    %edx,%edi
c0105bc6:	ac                   	lods   %ds:(%esi),%al
c0105bc7:	ae                   	scas   %es:(%edi),%al
c0105bc8:	75 08                	jne    c0105bd2 <strcmp+0x2e>
c0105bca:	84 c0                	test   %al,%al
c0105bcc:	75 f8                	jne    c0105bc6 <strcmp+0x22>
c0105bce:	31 c0                	xor    %eax,%eax
c0105bd0:	eb 04                	jmp    c0105bd6 <strcmp+0x32>
c0105bd2:	19 c0                	sbb    %eax,%eax
c0105bd4:	0c 01                	or     $0x1,%al
c0105bd6:	89 fa                	mov    %edi,%edx
c0105bd8:	89 f1                	mov    %esi,%ecx
c0105bda:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105bdd:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105be0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105be3:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105be6:	83 c4 20             	add    $0x20,%esp
c0105be9:	5e                   	pop    %esi
c0105bea:	5f                   	pop    %edi
c0105beb:	5d                   	pop    %ebp
c0105bec:	c3                   	ret    

c0105bed <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105bed:	55                   	push   %ebp
c0105bee:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105bf0:	eb 0c                	jmp    c0105bfe <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105bf2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105bf6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105bfa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105bfe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c02:	74 1a                	je     c0105c1e <strncmp+0x31>
c0105c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c07:	0f b6 00             	movzbl (%eax),%eax
c0105c0a:	84 c0                	test   %al,%al
c0105c0c:	74 10                	je     c0105c1e <strncmp+0x31>
c0105c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c11:	0f b6 10             	movzbl (%eax),%edx
c0105c14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c17:	0f b6 00             	movzbl (%eax),%eax
c0105c1a:	38 c2                	cmp    %al,%dl
c0105c1c:	74 d4                	je     c0105bf2 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105c1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c22:	74 18                	je     c0105c3c <strncmp+0x4f>
c0105c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c27:	0f b6 00             	movzbl (%eax),%eax
c0105c2a:	0f b6 d0             	movzbl %al,%edx
c0105c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c30:	0f b6 00             	movzbl (%eax),%eax
c0105c33:	0f b6 c0             	movzbl %al,%eax
c0105c36:	29 c2                	sub    %eax,%edx
c0105c38:	89 d0                	mov    %edx,%eax
c0105c3a:	eb 05                	jmp    c0105c41 <strncmp+0x54>
c0105c3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c41:	5d                   	pop    %ebp
c0105c42:	c3                   	ret    

c0105c43 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105c43:	55                   	push   %ebp
c0105c44:	89 e5                	mov    %esp,%ebp
c0105c46:	83 ec 04             	sub    $0x4,%esp
c0105c49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c4c:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c4f:	eb 14                	jmp    c0105c65 <strchr+0x22>
        if (*s == c) {
c0105c51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c54:	0f b6 00             	movzbl (%eax),%eax
c0105c57:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105c5a:	75 05                	jne    c0105c61 <strchr+0x1e>
            return (char *)s;
c0105c5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c5f:	eb 13                	jmp    c0105c74 <strchr+0x31>
        }
        s ++;
c0105c61:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105c65:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c68:	0f b6 00             	movzbl (%eax),%eax
c0105c6b:	84 c0                	test   %al,%al
c0105c6d:	75 e2                	jne    c0105c51 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c74:	c9                   	leave  
c0105c75:	c3                   	ret    

c0105c76 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105c76:	55                   	push   %ebp
c0105c77:	89 e5                	mov    %esp,%ebp
c0105c79:	83 ec 04             	sub    $0x4,%esp
c0105c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105c82:	eb 11                	jmp    c0105c95 <strfind+0x1f>
        if (*s == c) {
c0105c84:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c87:	0f b6 00             	movzbl (%eax),%eax
c0105c8a:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105c8d:	75 02                	jne    c0105c91 <strfind+0x1b>
            break;
c0105c8f:	eb 0e                	jmp    c0105c9f <strfind+0x29>
        }
        s ++;
c0105c91:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c98:	0f b6 00             	movzbl (%eax),%eax
c0105c9b:	84 c0                	test   %al,%al
c0105c9d:	75 e5                	jne    c0105c84 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105c9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ca2:	c9                   	leave  
c0105ca3:	c3                   	ret    

c0105ca4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105ca4:	55                   	push   %ebp
c0105ca5:	89 e5                	mov    %esp,%ebp
c0105ca7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105caa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105cb1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105cb8:	eb 04                	jmp    c0105cbe <strtol+0x1a>
        s ++;
c0105cba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc1:	0f b6 00             	movzbl (%eax),%eax
c0105cc4:	3c 20                	cmp    $0x20,%al
c0105cc6:	74 f2                	je     c0105cba <strtol+0x16>
c0105cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ccb:	0f b6 00             	movzbl (%eax),%eax
c0105cce:	3c 09                	cmp    $0x9,%al
c0105cd0:	74 e8                	je     c0105cba <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd5:	0f b6 00             	movzbl (%eax),%eax
c0105cd8:	3c 2b                	cmp    $0x2b,%al
c0105cda:	75 06                	jne    c0105ce2 <strtol+0x3e>
        s ++;
c0105cdc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105ce0:	eb 15                	jmp    c0105cf7 <strtol+0x53>
    }
    else if (*s == '-') {
c0105ce2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce5:	0f b6 00             	movzbl (%eax),%eax
c0105ce8:	3c 2d                	cmp    $0x2d,%al
c0105cea:	75 0b                	jne    c0105cf7 <strtol+0x53>
        s ++, neg = 1;
c0105cec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105cf0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105cf7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105cfb:	74 06                	je     c0105d03 <strtol+0x5f>
c0105cfd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105d01:	75 24                	jne    c0105d27 <strtol+0x83>
c0105d03:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d06:	0f b6 00             	movzbl (%eax),%eax
c0105d09:	3c 30                	cmp    $0x30,%al
c0105d0b:	75 1a                	jne    c0105d27 <strtol+0x83>
c0105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d10:	83 c0 01             	add    $0x1,%eax
c0105d13:	0f b6 00             	movzbl (%eax),%eax
c0105d16:	3c 78                	cmp    $0x78,%al
c0105d18:	75 0d                	jne    c0105d27 <strtol+0x83>
        s += 2, base = 16;
c0105d1a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105d1e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105d25:	eb 2a                	jmp    c0105d51 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105d27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d2b:	75 17                	jne    c0105d44 <strtol+0xa0>
c0105d2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d30:	0f b6 00             	movzbl (%eax),%eax
c0105d33:	3c 30                	cmp    $0x30,%al
c0105d35:	75 0d                	jne    c0105d44 <strtol+0xa0>
        s ++, base = 8;
c0105d37:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105d3b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105d42:	eb 0d                	jmp    c0105d51 <strtol+0xad>
    }
    else if (base == 0) {
c0105d44:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105d48:	75 07                	jne    c0105d51 <strtol+0xad>
        base = 10;
c0105d4a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105d51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d54:	0f b6 00             	movzbl (%eax),%eax
c0105d57:	3c 2f                	cmp    $0x2f,%al
c0105d59:	7e 1b                	jle    c0105d76 <strtol+0xd2>
c0105d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5e:	0f b6 00             	movzbl (%eax),%eax
c0105d61:	3c 39                	cmp    $0x39,%al
c0105d63:	7f 11                	jg     c0105d76 <strtol+0xd2>
            dig = *s - '0';
c0105d65:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d68:	0f b6 00             	movzbl (%eax),%eax
c0105d6b:	0f be c0             	movsbl %al,%eax
c0105d6e:	83 e8 30             	sub    $0x30,%eax
c0105d71:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d74:	eb 48                	jmp    c0105dbe <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105d76:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d79:	0f b6 00             	movzbl (%eax),%eax
c0105d7c:	3c 60                	cmp    $0x60,%al
c0105d7e:	7e 1b                	jle    c0105d9b <strtol+0xf7>
c0105d80:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d83:	0f b6 00             	movzbl (%eax),%eax
c0105d86:	3c 7a                	cmp    $0x7a,%al
c0105d88:	7f 11                	jg     c0105d9b <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8d:	0f b6 00             	movzbl (%eax),%eax
c0105d90:	0f be c0             	movsbl %al,%eax
c0105d93:	83 e8 57             	sub    $0x57,%eax
c0105d96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d99:	eb 23                	jmp    c0105dbe <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105d9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d9e:	0f b6 00             	movzbl (%eax),%eax
c0105da1:	3c 40                	cmp    $0x40,%al
c0105da3:	7e 3d                	jle    c0105de2 <strtol+0x13e>
c0105da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da8:	0f b6 00             	movzbl (%eax),%eax
c0105dab:	3c 5a                	cmp    $0x5a,%al
c0105dad:	7f 33                	jg     c0105de2 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db2:	0f b6 00             	movzbl (%eax),%eax
c0105db5:	0f be c0             	movsbl %al,%eax
c0105db8:	83 e8 37             	sub    $0x37,%eax
c0105dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dc1:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105dc4:	7c 02                	jl     c0105dc8 <strtol+0x124>
            break;
c0105dc6:	eb 1a                	jmp    c0105de2 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105dc8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105dcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dcf:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105dd3:	89 c2                	mov    %eax,%edx
c0105dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dd8:	01 d0                	add    %edx,%eax
c0105dda:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105ddd:	e9 6f ff ff ff       	jmp    c0105d51 <strtol+0xad>

    if (endptr) {
c0105de2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105de6:	74 08                	je     c0105df0 <strtol+0x14c>
        *endptr = (char *) s;
c0105de8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105deb:	8b 55 08             	mov    0x8(%ebp),%edx
c0105dee:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105df0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105df4:	74 07                	je     c0105dfd <strtol+0x159>
c0105df6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105df9:	f7 d8                	neg    %eax
c0105dfb:	eb 03                	jmp    c0105e00 <strtol+0x15c>
c0105dfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105e00:	c9                   	leave  
c0105e01:	c3                   	ret    

c0105e02 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105e02:	55                   	push   %ebp
c0105e03:	89 e5                	mov    %esp,%ebp
c0105e05:	57                   	push   %edi
c0105e06:	83 ec 24             	sub    $0x24,%esp
c0105e09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e0c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105e0f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105e13:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e16:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105e19:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105e1c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105e22:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105e25:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105e29:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105e2c:	89 d7                	mov    %edx,%edi
c0105e2e:	f3 aa                	rep stos %al,%es:(%edi)
c0105e30:	89 fa                	mov    %edi,%edx
c0105e32:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105e35:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105e38:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105e3b:	83 c4 24             	add    $0x24,%esp
c0105e3e:	5f                   	pop    %edi
c0105e3f:	5d                   	pop    %ebp
c0105e40:	c3                   	ret    

c0105e41 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105e41:	55                   	push   %ebp
c0105e42:	89 e5                	mov    %esp,%ebp
c0105e44:	57                   	push   %edi
c0105e45:	56                   	push   %esi
c0105e46:	53                   	push   %ebx
c0105e47:	83 ec 30             	sub    $0x30,%esp
c0105e4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e53:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e56:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e59:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e5f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105e62:	73 42                	jae    c0105ea6 <memmove+0x65>
c0105e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e67:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105e70:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e73:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105e76:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e79:	c1 e8 02             	shr    $0x2,%eax
c0105e7c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105e7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105e81:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e84:	89 d7                	mov    %edx,%edi
c0105e86:	89 c6                	mov    %eax,%esi
c0105e88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e8a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105e8d:	83 e1 03             	and    $0x3,%ecx
c0105e90:	74 02                	je     c0105e94 <memmove+0x53>
c0105e92:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e94:	89 f0                	mov    %esi,%eax
c0105e96:	89 fa                	mov    %edi,%edx
c0105e98:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105e9b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105e9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105ea1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ea4:	eb 36                	jmp    c0105edc <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105ea6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ea9:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105eac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105eaf:	01 c2                	add    %eax,%edx
c0105eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105eb4:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eba:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105ebd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ec0:	89 c1                	mov    %eax,%ecx
c0105ec2:	89 d8                	mov    %ebx,%eax
c0105ec4:	89 d6                	mov    %edx,%esi
c0105ec6:	89 c7                	mov    %eax,%edi
c0105ec8:	fd                   	std    
c0105ec9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105ecb:	fc                   	cld    
c0105ecc:	89 f8                	mov    %edi,%eax
c0105ece:	89 f2                	mov    %esi,%edx
c0105ed0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105ed3:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105ed6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105edc:	83 c4 30             	add    $0x30,%esp
c0105edf:	5b                   	pop    %ebx
c0105ee0:	5e                   	pop    %esi
c0105ee1:	5f                   	pop    %edi
c0105ee2:	5d                   	pop    %ebp
c0105ee3:	c3                   	ret    

c0105ee4 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105ee4:	55                   	push   %ebp
c0105ee5:	89 e5                	mov    %esp,%ebp
c0105ee7:	57                   	push   %edi
c0105ee8:	56                   	push   %esi
c0105ee9:	83 ec 20             	sub    $0x20,%esp
c0105eec:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ef8:	8b 45 10             	mov    0x10(%ebp),%eax
c0105efb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105efe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f01:	c1 e8 02             	shr    $0x2,%eax
c0105f04:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105f06:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f0c:	89 d7                	mov    %edx,%edi
c0105f0e:	89 c6                	mov    %eax,%esi
c0105f10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105f12:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105f15:	83 e1 03             	and    $0x3,%ecx
c0105f18:	74 02                	je     c0105f1c <memcpy+0x38>
c0105f1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105f1c:	89 f0                	mov    %esi,%eax
c0105f1e:	89 fa                	mov    %edi,%edx
c0105f20:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105f23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105f26:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105f2c:	83 c4 20             	add    $0x20,%esp
c0105f2f:	5e                   	pop    %esi
c0105f30:	5f                   	pop    %edi
c0105f31:	5d                   	pop    %ebp
c0105f32:	c3                   	ret    

c0105f33 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105f33:	55                   	push   %ebp
c0105f34:	89 e5                	mov    %esp,%ebp
c0105f36:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105f39:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105f3f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f42:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105f45:	eb 30                	jmp    c0105f77 <memcmp+0x44>
        if (*s1 != *s2) {
c0105f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f4a:	0f b6 10             	movzbl (%eax),%edx
c0105f4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f50:	0f b6 00             	movzbl (%eax),%eax
c0105f53:	38 c2                	cmp    %al,%dl
c0105f55:	74 18                	je     c0105f6f <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105f57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105f5a:	0f b6 00             	movzbl (%eax),%eax
c0105f5d:	0f b6 d0             	movzbl %al,%edx
c0105f60:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105f63:	0f b6 00             	movzbl (%eax),%eax
c0105f66:	0f b6 c0             	movzbl %al,%eax
c0105f69:	29 c2                	sub    %eax,%edx
c0105f6b:	89 d0                	mov    %edx,%eax
c0105f6d:	eb 1a                	jmp    c0105f89 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105f6f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105f73:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105f77:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f7a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105f7d:	89 55 10             	mov    %edx,0x10(%ebp)
c0105f80:	85 c0                	test   %eax,%eax
c0105f82:	75 c3                	jne    c0105f47 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f89:	c9                   	leave  
c0105f8a:	c3                   	ret    
