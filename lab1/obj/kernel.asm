
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 64 33 00 00       	call   103390 <memset>

    cons_init();                // init the console
  10002c:	e8 5a 15 00 00       	call   10158b <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 20 35 10 00 	movl   $0x103520,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 3c 35 10 00 	movl   $0x10353c,(%esp)
  100046:	e8 d7 02 00 00       	call   100322 <cprintf>

    print_kerninfo();
  10004b:	e8 06 08 00 00       	call   100856 <print_kerninfo>

    grade_backtrace();
  100050:	e8 8b 00 00 00       	call   1000e0 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 7c 29 00 00       	call   1029d6 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 6f 16 00 00       	call   1016ce <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 e7 17 00 00       	call   10184b <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 15 0d 00 00       	call   100d7e <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 ce 15 00 00       	call   10163c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 6d 01 00 00       	call   1001e0 <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	55                   	push   %ebp
  100076:	89 e5                	mov    %esp,%ebp
  100078:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100082:	00 
  100083:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008a:	00 
  10008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100092:	e8 08 0c 00 00       	call   100c9f <mon_backtrace>
}
  100097:	c9                   	leave  
  100098:	c3                   	ret    

00100099 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100099:	55                   	push   %ebp
  10009a:	89 e5                	mov    %esp,%ebp
  10009c:	53                   	push   %ebx
  10009d:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000a6:	8d 55 08             	lea    0x8(%ebp),%edx
  1000a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000b8:	89 04 24             	mov    %eax,(%esp)
  1000bb:	e8 b5 ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c0:	83 c4 14             	add    $0x14,%esp
  1000c3:	5b                   	pop    %ebx
  1000c4:	5d                   	pop    %ebp
  1000c5:	c3                   	ret    

001000c6 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c6:	55                   	push   %ebp
  1000c7:	89 e5                	mov    %esp,%ebp
  1000c9:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d6:	89 04 24             	mov    %eax,(%esp)
  1000d9:	e8 bb ff ff ff       	call   100099 <grade_backtrace1>
}
  1000de:	c9                   	leave  
  1000df:	c3                   	ret    

001000e0 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e0:	55                   	push   %ebp
  1000e1:	89 e5                	mov    %esp,%ebp
  1000e3:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e6:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000eb:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f2:	ff 
  1000f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000fe:	e8 c3 ff ff ff       	call   1000c6 <grade_backtrace0>
}
  100103:	c9                   	leave  
  100104:	c3                   	ret    

00100105 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100105:	55                   	push   %ebp
  100106:	89 e5                	mov    %esp,%ebp
  100108:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10010e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100111:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100114:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100117:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011b:	0f b7 c0             	movzwl %ax,%eax
  10011e:	83 e0 03             	and    $0x3,%eax
  100121:	89 c2                	mov    %eax,%edx
  100123:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100128:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100130:	c7 04 24 41 35 10 00 	movl   $0x103541,(%esp)
  100137:	e8 e6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100140:	0f b7 d0             	movzwl %ax,%edx
  100143:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 4f 35 10 00 	movl   $0x10354f,(%esp)
  100157:	e8 c6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	0f b7 d0             	movzwl %ax,%edx
  100163:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100168:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100170:	c7 04 24 5d 35 10 00 	movl   $0x10355d,(%esp)
  100177:	e8 a6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100180:	0f b7 d0             	movzwl %ax,%edx
  100183:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100188:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100190:	c7 04 24 6b 35 10 00 	movl   $0x10356b,(%esp)
  100197:	e8 86 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019c:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001a0:	0f b7 d0             	movzwl %ax,%edx
  1001a3:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b0:	c7 04 24 79 35 10 00 	movl   $0x103579,(%esp)
  1001b7:	e8 66 01 00 00       	call   100322 <cprintf>
    round ++;
  1001bc:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001c1:	83 c0 01             	add    $0x1,%eax
  1001c4:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c9:	c9                   	leave  
  1001ca:	c3                   	ret    

001001cb <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001cb:	55                   	push   %ebp
  1001cc:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
asm volatile(
  1001ce:	83 ec 08             	sub    $0x8,%esp
  1001d1:	cd 78                	int    $0x78
  1001d3:	89 ec                	mov    %ebp,%esp
    "int %0 \n"                    //中断
    "movl %%ebp,%%esp"             //恢复栈指针
    :
    :"i"(T_SWITCH_TOU)             //中断号
    );
}
  1001d5:	5d                   	pop    %ebp
  1001d6:	c3                   	ret    

001001d7 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001d7:	55                   	push   %ebp
  1001d8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
asm volatile (
  1001da:	cd 79                	int    $0x79
  1001dc:	89 ec                	mov    %ebp,%esp
     "int %0 \n"
     "movl %%ebp, %%esp \n"
     :
     : "i"(T_SWITCH_TOK)
     );
}
  1001de:	5d                   	pop    %ebp
  1001df:	c3                   	ret    

001001e0 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001e0:	55                   	push   %ebp
  1001e1:	89 e5                	mov    %esp,%ebp
  1001e3:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001e6:	e8 1a ff ff ff       	call   100105 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001eb:	c7 04 24 88 35 10 00 	movl   $0x103588,(%esp)
  1001f2:	e8 2b 01 00 00       	call   100322 <cprintf>
    lab1_switch_to_user();
  1001f7:	e8 cf ff ff ff       	call   1001cb <lab1_switch_to_user>
    lab1_print_cur_status();
  1001fc:	e8 04 ff ff ff       	call   100105 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100201:	c7 04 24 a8 35 10 00 	movl   $0x1035a8,(%esp)
  100208:	e8 15 01 00 00       	call   100322 <cprintf>
    lab1_switch_to_kernel();
  10020d:	e8 c5 ff ff ff       	call   1001d7 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100212:	e8 ee fe ff ff       	call   100105 <lab1_print_cur_status>
}
  100217:	c9                   	leave  
  100218:	c3                   	ret    

00100219 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100219:	55                   	push   %ebp
  10021a:	89 e5                	mov    %esp,%ebp
  10021c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10021f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100223:	74 13                	je     100238 <readline+0x1f>
        cprintf("%s", prompt);
  100225:	8b 45 08             	mov    0x8(%ebp),%eax
  100228:	89 44 24 04          	mov    %eax,0x4(%esp)
  10022c:	c7 04 24 c7 35 10 00 	movl   $0x1035c7,(%esp)
  100233:	e8 ea 00 00 00       	call   100322 <cprintf>
    }
    int i = 0, c;
  100238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10023f:	e8 66 01 00 00       	call   1003aa <getchar>
  100244:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100247:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10024b:	79 07                	jns    100254 <readline+0x3b>
            return NULL;
  10024d:	b8 00 00 00 00       	mov    $0x0,%eax
  100252:	eb 79                	jmp    1002cd <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100254:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100258:	7e 28                	jle    100282 <readline+0x69>
  10025a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100261:	7f 1f                	jg     100282 <readline+0x69>
            cputchar(c);
  100263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100266:	89 04 24             	mov    %eax,(%esp)
  100269:	e8 da 00 00 00       	call   100348 <cputchar>
            buf[i ++] = c;
  10026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100271:	8d 50 01             	lea    0x1(%eax),%edx
  100274:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100277:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10027a:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100280:	eb 46                	jmp    1002c8 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  100282:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100286:	75 17                	jne    10029f <readline+0x86>
  100288:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10028c:	7e 11                	jle    10029f <readline+0x86>
            cputchar(c);
  10028e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100291:	89 04 24             	mov    %eax,(%esp)
  100294:	e8 af 00 00 00       	call   100348 <cputchar>
            i --;
  100299:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10029d:	eb 29                	jmp    1002c8 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  10029f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002a3:	74 06                	je     1002ab <readline+0x92>
  1002a5:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002a9:	75 1d                	jne    1002c8 <readline+0xaf>
            cputchar(c);
  1002ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002ae:	89 04 24             	mov    %eax,(%esp)
  1002b1:	e8 92 00 00 00       	call   100348 <cputchar>
            buf[i] = '\0';
  1002b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002b9:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1002be:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002c1:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1002c6:	eb 05                	jmp    1002cd <readline+0xb4>
        }
    }
  1002c8:	e9 72 ff ff ff       	jmp    10023f <readline+0x26>
}
  1002cd:	c9                   	leave  
  1002ce:	c3                   	ret    

001002cf <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002cf:	55                   	push   %ebp
  1002d0:	89 e5                	mov    %esp,%ebp
  1002d2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d8:	89 04 24             	mov    %eax,(%esp)
  1002db:	e8 d7 12 00 00       	call   1015b7 <cons_putc>
    (*cnt) ++;
  1002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002e3:	8b 00                	mov    (%eax),%eax
  1002e5:	8d 50 01             	lea    0x1(%eax),%edx
  1002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002eb:	89 10                	mov    %edx,(%eax)
}
  1002ed:	c9                   	leave  
  1002ee:	c3                   	ret    

001002ef <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  1002ef:	55                   	push   %ebp
  1002f0:	89 e5                	mov    %esp,%ebp
  1002f2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100303:	8b 45 08             	mov    0x8(%ebp),%eax
  100306:	89 44 24 08          	mov    %eax,0x8(%esp)
  10030a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100311:	c7 04 24 cf 02 10 00 	movl   $0x1002cf,(%esp)
  100318:	e8 8c 28 00 00       	call   102ba9 <vprintfmt>
    return cnt;
  10031d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100320:	c9                   	leave  
  100321:	c3                   	ret    

00100322 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100322:	55                   	push   %ebp
  100323:	89 e5                	mov    %esp,%ebp
  100325:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100328:	8d 45 0c             	lea    0xc(%ebp),%eax
  10032b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10032e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100331:	89 44 24 04          	mov    %eax,0x4(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 04 24             	mov    %eax,(%esp)
  10033b:	e8 af ff ff ff       	call   1002ef <vcprintf>
  100340:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10034e:	8b 45 08             	mov    0x8(%ebp),%eax
  100351:	89 04 24             	mov    %eax,(%esp)
  100354:	e8 5e 12 00 00       	call   1015b7 <cons_putc>
}
  100359:	c9                   	leave  
  10035a:	c3                   	ret    

0010035b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10035b:	55                   	push   %ebp
  10035c:	89 e5                	mov    %esp,%ebp
  10035e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100361:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100368:	eb 13                	jmp    10037d <cputs+0x22>
        cputch(c, &cnt);
  10036a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10036e:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100371:	89 54 24 04          	mov    %edx,0x4(%esp)
  100375:	89 04 24             	mov    %eax,(%esp)
  100378:	e8 52 ff ff ff       	call   1002cf <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  10037d:	8b 45 08             	mov    0x8(%ebp),%eax
  100380:	8d 50 01             	lea    0x1(%eax),%edx
  100383:	89 55 08             	mov    %edx,0x8(%ebp)
  100386:	0f b6 00             	movzbl (%eax),%eax
  100389:	88 45 f7             	mov    %al,-0x9(%ebp)
  10038c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100390:	75 d8                	jne    10036a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100395:	89 44 24 04          	mov    %eax,0x4(%esp)
  100399:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003a0:	e8 2a ff ff ff       	call   1002cf <cputch>
    return cnt;
  1003a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003a8:	c9                   	leave  
  1003a9:	c3                   	ret    

001003aa <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003aa:	55                   	push   %ebp
  1003ab:	89 e5                	mov    %esp,%ebp
  1003ad:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003b0:	e8 2b 12 00 00       	call   1015e0 <cons_getc>
  1003b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003bc:	74 f2                	je     1003b0 <getchar+0x6>
        /* do nothing */;
    return c;
  1003be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    

001003c3 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003cc:	8b 00                	mov    (%eax),%eax
  1003ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1003d4:	8b 00                	mov    (%eax),%eax
  1003d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1003e0:	e9 d2 00 00 00       	jmp    1004b7 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1003e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1003e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1003eb:	01 d0                	add    %edx,%eax
  1003ed:	89 c2                	mov    %eax,%edx
  1003ef:	c1 ea 1f             	shr    $0x1f,%edx
  1003f2:	01 d0                	add    %edx,%eax
  1003f4:	d1 f8                	sar    %eax
  1003f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1003f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1003ff:	eb 04                	jmp    100405 <stab_binsearch+0x42>
            m --;
  100401:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100408:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10040b:	7c 1f                	jl     10042c <stab_binsearch+0x69>
  10040d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100410:	89 d0                	mov    %edx,%eax
  100412:	01 c0                	add    %eax,%eax
  100414:	01 d0                	add    %edx,%eax
  100416:	c1 e0 02             	shl    $0x2,%eax
  100419:	89 c2                	mov    %eax,%edx
  10041b:	8b 45 08             	mov    0x8(%ebp),%eax
  10041e:	01 d0                	add    %edx,%eax
  100420:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100424:	0f b6 c0             	movzbl %al,%eax
  100427:	3b 45 14             	cmp    0x14(%ebp),%eax
  10042a:	75 d5                	jne    100401 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10042c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100432:	7d 0b                	jge    10043f <stab_binsearch+0x7c>
            l = true_m + 1;
  100434:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100437:	83 c0 01             	add    $0x1,%eax
  10043a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10043d:	eb 78                	jmp    1004b7 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  10043f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100446:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100449:	89 d0                	mov    %edx,%eax
  10044b:	01 c0                	add    %eax,%eax
  10044d:	01 d0                	add    %edx,%eax
  10044f:	c1 e0 02             	shl    $0x2,%eax
  100452:	89 c2                	mov    %eax,%edx
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	01 d0                	add    %edx,%eax
  100459:	8b 40 08             	mov    0x8(%eax),%eax
  10045c:	3b 45 18             	cmp    0x18(%ebp),%eax
  10045f:	73 13                	jae    100474 <stab_binsearch+0xb1>
            *region_left = m;
  100461:	8b 45 0c             	mov    0xc(%ebp),%eax
  100464:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100467:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100469:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10046c:	83 c0 01             	add    $0x1,%eax
  10046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100472:	eb 43                	jmp    1004b7 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100474:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100477:	89 d0                	mov    %edx,%eax
  100479:	01 c0                	add    %eax,%eax
  10047b:	01 d0                	add    %edx,%eax
  10047d:	c1 e0 02             	shl    $0x2,%eax
  100480:	89 c2                	mov    %eax,%edx
  100482:	8b 45 08             	mov    0x8(%ebp),%eax
  100485:	01 d0                	add    %edx,%eax
  100487:	8b 40 08             	mov    0x8(%eax),%eax
  10048a:	3b 45 18             	cmp    0x18(%ebp),%eax
  10048d:	76 16                	jbe    1004a5 <stab_binsearch+0xe2>
            *region_right = m - 1;
  10048f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100492:	8d 50 ff             	lea    -0x1(%eax),%edx
  100495:	8b 45 10             	mov    0x10(%ebp),%eax
  100498:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10049a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10049d:	83 e8 01             	sub    $0x1,%eax
  1004a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a3:	eb 12                	jmp    1004b7 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004ab:	89 10                	mov    %edx,(%eax)
            l = m;
  1004ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004b3:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004bd:	0f 8e 22 ff ff ff    	jle    1003e5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004c7:	75 0f                	jne    1004d8 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cc:	8b 00                	mov    (%eax),%eax
  1004ce:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d4:	89 10                	mov    %edx,(%eax)
  1004d6:	eb 3f                	jmp    100517 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1004db:	8b 00                	mov    (%eax),%eax
  1004dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1004e0:	eb 04                	jmp    1004e6 <stab_binsearch+0x123>
  1004e2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e9:	8b 00                	mov    (%eax),%eax
  1004eb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ee:	7d 1f                	jge    10050f <stab_binsearch+0x14c>
  1004f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004f3:	89 d0                	mov    %edx,%eax
  1004f5:	01 c0                	add    %eax,%eax
  1004f7:	01 d0                	add    %edx,%eax
  1004f9:	c1 e0 02             	shl    $0x2,%eax
  1004fc:	89 c2                	mov    %eax,%edx
  1004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100501:	01 d0                	add    %edx,%eax
  100503:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100507:	0f b6 c0             	movzbl %al,%eax
  10050a:	3b 45 14             	cmp    0x14(%ebp),%eax
  10050d:	75 d3                	jne    1004e2 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  10050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100512:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100515:	89 10                	mov    %edx,(%eax)
    }
}
  100517:	c9                   	leave  
  100518:	c3                   	ret    

00100519 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100519:	55                   	push   %ebp
  10051a:	89 e5                	mov    %esp,%ebp
  10051c:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10051f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100522:	c7 00 cc 35 10 00    	movl   $0x1035cc,(%eax)
    info->eip_line = 0;
  100528:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100532:	8b 45 0c             	mov    0xc(%ebp),%eax
  100535:	c7 40 08 cc 35 10 00 	movl   $0x1035cc,0x8(%eax)
    info->eip_fn_namelen = 9;
  10053c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10053f:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100546:	8b 45 0c             	mov    0xc(%ebp),%eax
  100549:	8b 55 08             	mov    0x8(%ebp),%edx
  10054c:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10054f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100552:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100559:	c7 45 f4 6c 3e 10 00 	movl   $0x103e6c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100560:	c7 45 f0 3c b6 10 00 	movl   $0x10b63c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100567:	c7 45 ec 3d b6 10 00 	movl   $0x10b63d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10056e:	c7 45 e8 35 d6 10 00 	movl   $0x10d635,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100575:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100578:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10057b:	76 0d                	jbe    10058a <debuginfo_eip+0x71>
  10057d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100580:	83 e8 01             	sub    $0x1,%eax
  100583:	0f b6 00             	movzbl (%eax),%eax
  100586:	84 c0                	test   %al,%al
  100588:	74 0a                	je     100594 <debuginfo_eip+0x7b>
        return -1;
  10058a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10058f:	e9 c0 02 00 00       	jmp    100854 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100594:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10059e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005a1:	29 c2                	sub    %eax,%edx
  1005a3:	89 d0                	mov    %edx,%eax
  1005a5:	c1 f8 02             	sar    $0x2,%eax
  1005a8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005ae:	83 e8 01             	sub    $0x1,%eax
  1005b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005bb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005c2:	00 
  1005c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005d4:	89 04 24             	mov    %eax,(%esp)
  1005d7:	e8 e7 fd ff ff       	call   1003c3 <stab_binsearch>
    if (lfile == 0)
  1005dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005df:	85 c0                	test   %eax,%eax
  1005e1:	75 0a                	jne    1005ed <debuginfo_eip+0xd4>
        return -1;
  1005e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005e8:	e9 67 02 00 00       	jmp    100854 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1005ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1005f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1005fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  100600:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100607:	00 
  100608:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10060f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100612:	89 44 24 04          	mov    %eax,0x4(%esp)
  100616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100619:	89 04 24             	mov    %eax,(%esp)
  10061c:	e8 a2 fd ff ff       	call   1003c3 <stab_binsearch>

    if (lfun <= rfun) {
  100621:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100627:	39 c2                	cmp    %eax,%edx
  100629:	7f 7c                	jg     1006a7 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10062b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10062e:	89 c2                	mov    %eax,%edx
  100630:	89 d0                	mov    %edx,%eax
  100632:	01 c0                	add    %eax,%eax
  100634:	01 d0                	add    %edx,%eax
  100636:	c1 e0 02             	shl    $0x2,%eax
  100639:	89 c2                	mov    %eax,%edx
  10063b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063e:	01 d0                	add    %edx,%eax
  100640:	8b 10                	mov    (%eax),%edx
  100642:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100645:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100648:	29 c1                	sub    %eax,%ecx
  10064a:	89 c8                	mov    %ecx,%eax
  10064c:	39 c2                	cmp    %eax,%edx
  10064e:	73 22                	jae    100672 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100650:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100653:	89 c2                	mov    %eax,%edx
  100655:	89 d0                	mov    %edx,%eax
  100657:	01 c0                	add    %eax,%eax
  100659:	01 d0                	add    %edx,%eax
  10065b:	c1 e0 02             	shl    $0x2,%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100663:	01 d0                	add    %edx,%eax
  100665:	8b 10                	mov    (%eax),%edx
  100667:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066a:	01 c2                	add    %eax,%edx
  10066c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10066f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100672:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100675:	89 c2                	mov    %eax,%edx
  100677:	89 d0                	mov    %edx,%eax
  100679:	01 c0                	add    %eax,%eax
  10067b:	01 d0                	add    %edx,%eax
  10067d:	c1 e0 02             	shl    $0x2,%eax
  100680:	89 c2                	mov    %eax,%edx
  100682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	8b 50 08             	mov    0x8(%eax),%edx
  10068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10068d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100690:	8b 45 0c             	mov    0xc(%ebp),%eax
  100693:	8b 40 10             	mov    0x10(%eax),%eax
  100696:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100699:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10069f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006a5:	eb 15                	jmp    1006bc <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006aa:	8b 55 08             	mov    0x8(%ebp),%edx
  1006ad:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 08             	mov    0x8(%eax),%eax
  1006c2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006c9:	00 
  1006ca:	89 04 24             	mov    %eax,(%esp)
  1006cd:	e8 32 2b 00 00       	call   103204 <strfind>
  1006d2:	89 c2                	mov    %eax,%edx
  1006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d7:	8b 40 08             	mov    0x8(%eax),%eax
  1006da:	29 c2                	sub    %eax,%edx
  1006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006df:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 b9 fc ff ff       	call   1003c3 <stab_binsearch>
    if (lline <= rline) {
  10070a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10070d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 24                	jg     100738 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100714:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10072d:	0f b7 d0             	movzwl %ax,%edx
  100730:	8b 45 0c             	mov    0xc(%ebp),%eax
  100733:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100736:	eb 13                	jmp    10074b <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10073d:	e9 12 01 00 00       	jmp    100854 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100742:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100745:	83 e8 01             	sub    $0x1,%eax
  100748:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10074b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10074e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100751:	39 c2                	cmp    %eax,%edx
  100753:	7c 56                	jl     1007ab <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100755:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100758:	89 c2                	mov    %eax,%edx
  10075a:	89 d0                	mov    %edx,%eax
  10075c:	01 c0                	add    %eax,%eax
  10075e:	01 d0                	add    %edx,%eax
  100760:	c1 e0 02             	shl    $0x2,%eax
  100763:	89 c2                	mov    %eax,%edx
  100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100768:	01 d0                	add    %edx,%eax
  10076a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10076e:	3c 84                	cmp    $0x84,%al
  100770:	74 39                	je     1007ab <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100772:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100775:	89 c2                	mov    %eax,%edx
  100777:	89 d0                	mov    %edx,%eax
  100779:	01 c0                	add    %eax,%eax
  10077b:	01 d0                	add    %edx,%eax
  10077d:	c1 e0 02             	shl    $0x2,%eax
  100780:	89 c2                	mov    %eax,%edx
  100782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100785:	01 d0                	add    %edx,%eax
  100787:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10078b:	3c 64                	cmp    $0x64,%al
  10078d:	75 b3                	jne    100742 <debuginfo_eip+0x229>
  10078f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100792:	89 c2                	mov    %eax,%edx
  100794:	89 d0                	mov    %edx,%eax
  100796:	01 c0                	add    %eax,%eax
  100798:	01 d0                	add    %edx,%eax
  10079a:	c1 e0 02             	shl    $0x2,%eax
  10079d:	89 c2                	mov    %eax,%edx
  10079f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007a2:	01 d0                	add    %edx,%eax
  1007a4:	8b 40 08             	mov    0x8(%eax),%eax
  1007a7:	85 c0                	test   %eax,%eax
  1007a9:	74 97                	je     100742 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007b1:	39 c2                	cmp    %eax,%edx
  1007b3:	7c 46                	jl     1007fb <debuginfo_eip+0x2e2>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 10                	mov    (%eax),%edx
  1007cc:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007d2:	29 c1                	sub    %eax,%ecx
  1007d4:	89 c8                	mov    %ecx,%eax
  1007d6:	39 c2                	cmp    %eax,%edx
  1007d8:	73 21                	jae    1007fb <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007dd:	89 c2                	mov    %eax,%edx
  1007df:	89 d0                	mov    %edx,%eax
  1007e1:	01 c0                	add    %eax,%eax
  1007e3:	01 d0                	add    %edx,%eax
  1007e5:	c1 e0 02             	shl    $0x2,%eax
  1007e8:	89 c2                	mov    %eax,%edx
  1007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ed:	01 d0                	add    %edx,%eax
  1007ef:	8b 10                	mov    (%eax),%edx
  1007f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f4:	01 c2                	add    %eax,%edx
  1007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1007fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1007fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100801:	39 c2                	cmp    %eax,%edx
  100803:	7d 4a                	jge    10084f <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  100805:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100808:	83 c0 01             	add    $0x1,%eax
  10080b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10080e:	eb 18                	jmp    100828 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100810:	8b 45 0c             	mov    0xc(%ebp),%eax
  100813:	8b 40 14             	mov    0x14(%eax),%eax
  100816:	8d 50 01             	lea    0x1(%eax),%edx
  100819:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081c:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  10081f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100822:	83 c0 01             	add    $0x1,%eax
  100825:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10082b:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10082e:	39 c2                	cmp    %eax,%edx
  100830:	7d 1d                	jge    10084f <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100835:	89 c2                	mov    %eax,%edx
  100837:	89 d0                	mov    %edx,%eax
  100839:	01 c0                	add    %eax,%eax
  10083b:	01 d0                	add    %edx,%eax
  10083d:	c1 e0 02             	shl    $0x2,%eax
  100840:	89 c2                	mov    %eax,%edx
  100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100845:	01 d0                	add    %edx,%eax
  100847:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10084b:	3c a0                	cmp    $0xa0,%al
  10084d:	74 c1                	je     100810 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100854:	c9                   	leave  
  100855:	c3                   	ret    

00100856 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100856:	55                   	push   %ebp
  100857:	89 e5                	mov    %esp,%ebp
  100859:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10085c:	c7 04 24 d6 35 10 00 	movl   $0x1035d6,(%esp)
  100863:	e8 ba fa ff ff       	call   100322 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100868:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10086f:	00 
  100870:	c7 04 24 ef 35 10 00 	movl   $0x1035ef,(%esp)
  100877:	e8 a6 fa ff ff       	call   100322 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10087c:	c7 44 24 04 19 35 10 	movl   $0x103519,0x4(%esp)
  100883:	00 
  100884:	c7 04 24 07 36 10 00 	movl   $0x103607,(%esp)
  10088b:	e8 92 fa ff ff       	call   100322 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100890:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100897:	00 
  100898:	c7 04 24 1f 36 10 00 	movl   $0x10361f,(%esp)
  10089f:	e8 7e fa ff ff       	call   100322 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008a4:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  1008ab:	00 
  1008ac:	c7 04 24 37 36 10 00 	movl   $0x103637,(%esp)
  1008b3:	e8 6a fa ff ff       	call   100322 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008b8:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  1008bd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008c3:	b8 00 00 10 00       	mov    $0x100000,%eax
  1008c8:	29 c2                	sub    %eax,%edx
  1008ca:	89 d0                	mov    %edx,%eax
  1008cc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008d2:	85 c0                	test   %eax,%eax
  1008d4:	0f 48 c2             	cmovs  %edx,%eax
  1008d7:	c1 f8 0a             	sar    $0xa,%eax
  1008da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008de:	c7 04 24 50 36 10 00 	movl   $0x103650,(%esp)
  1008e5:	e8 38 fa ff ff       	call   100322 <cprintf>
}
  1008ea:	c9                   	leave  
  1008eb:	c3                   	ret    

001008ec <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1008ec:	55                   	push   %ebp
  1008ed:	89 e5                	mov    %esp,%ebp
  1008ef:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1008f5:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1008ff:	89 04 24             	mov    %eax,(%esp)
  100902:	e8 12 fc ff ff       	call   100519 <debuginfo_eip>
  100907:	85 c0                	test   %eax,%eax
  100909:	74 15                	je     100920 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10090b:	8b 45 08             	mov    0x8(%ebp),%eax
  10090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100912:	c7 04 24 7a 36 10 00 	movl   $0x10367a,(%esp)
  100919:	e8 04 fa ff ff       	call   100322 <cprintf>
  10091e:	eb 6d                	jmp    10098d <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100927:	eb 1c                	jmp    100945 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  100929:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10092f:	01 d0                	add    %edx,%eax
  100931:	0f b6 00             	movzbl (%eax),%eax
  100934:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10093a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10093d:	01 ca                	add    %ecx,%edx
  10093f:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100945:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100948:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10094b:	7f dc                	jg     100929 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  10094d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100956:	01 d0                	add    %edx,%eax
  100958:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  10095b:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10095e:	8b 55 08             	mov    0x8(%ebp),%edx
  100961:	89 d1                	mov    %edx,%ecx
  100963:	29 c1                	sub    %eax,%ecx
  100965:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100968:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10096b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10096f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100975:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100979:	89 54 24 08          	mov    %edx,0x8(%esp)
  10097d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100981:	c7 04 24 96 36 10 00 	movl   $0x103696,(%esp)
  100988:	e8 95 f9 ff ff       	call   100322 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  10098d:	c9                   	leave  
  10098e:	c3                   	ret    

0010098f <read_eip>:

static __noinline uint32_t
read_eip(void) {
  10098f:	55                   	push   %ebp
  100990:	89 e5                	mov    %esp,%ebp
  100992:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100995:	8b 45 04             	mov    0x4(%ebp),%eax
  100998:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  10099b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10099e:	c9                   	leave  
  10099f:	c3                   	ret    

001009a0 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009a0:	55                   	push   %ebp
  1009a1:	89 e5                	mov    %esp,%ebp
  1009a3:	53                   	push   %ebx
  1009a4:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009a7:	89 e8                	mov    %ebp,%eax
  1009a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
  1009af:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
  1009b2:	e8 d8 ff ff ff       	call   10098f <read_eip>
  1009b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      int i=0;
  1009ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
      for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
  1009c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009c8:	e9 81 00 00 00       	jmp    100a4e <print_stackframe+0xae>
      {
            cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  1009cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009db:	c7 04 24 a8 36 10 00 	movl   $0x1036a8,(%esp)
  1009e2:	e8 3b f9 ff ff       	call   100322 <cprintf>
            uint32_t* ptr = (uint32_t *) (ebp + 8);
  1009e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ea:	83 c0 08             	add    $0x8,%eax
  1009ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
            cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x\n", ptr[0], ptr[1], ptr[2], ptr[3]);
  1009f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009f3:	83 c0 0c             	add    $0xc,%eax
  1009f6:	8b 18                	mov    (%eax),%ebx
  1009f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009fb:	83 c0 08             	add    $0x8,%eax
  1009fe:	8b 08                	mov    (%eax),%ecx
  100a00:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a03:	83 c0 04             	add    $0x4,%eax
  100a06:	8b 10                	mov    (%eax),%edx
  100a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a0b:	8b 00                	mov    (%eax),%eax
  100a0d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a11:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a15:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a19:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a1d:	c7 04 24 c4 36 10 00 	movl   $0x1036c4,(%esp)
  100a24:	e8 f9 f8 ff ff       	call   100322 <cprintf>
            print_debuginfo(eip - 1);
  100a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a2c:	83 e8 01             	sub    $0x1,%eax
  100a2f:	89 04 24             	mov    %eax,(%esp)
  100a32:	e8 b5 fe ff ff       	call   1008ec <print_debuginfo>
            eip = *((uint32_t *) (ebp + 4));
  100a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a3a:	83 c0 04             	add    $0x4,%eax
  100a3d:	8b 00                	mov    (%eax),%eax
  100a3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
            ebp = *((uint32_t *) ebp);
  100a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a45:	8b 00                	mov    (%eax),%eax
  100a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp=read_ebp();
      uint32_t eip=read_eip();
      int i=0;
      for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++)
  100a4a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a4e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a52:	7f 0a                	jg     100a5e <print_stackframe+0xbe>
  100a54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a58:	0f 85 6f ff ff ff    	jne    1009cd <print_stackframe+0x2d>
            cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x\n", ptr[0], ptr[1], ptr[2], ptr[3]);
            print_debuginfo(eip - 1);
            eip = *((uint32_t *) (ebp + 4));
            ebp = *((uint32_t *) ebp);
      }   
}
  100a5e:	83 c4 44             	add    $0x44,%esp
  100a61:	5b                   	pop    %ebx
  100a62:	5d                   	pop    %ebp
  100a63:	c3                   	ret    

00100a64 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a64:	55                   	push   %ebp
  100a65:	89 e5                	mov    %esp,%ebp
  100a67:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a71:	eb 0c                	jmp    100a7f <parse+0x1b>
            *buf ++ = '\0';
  100a73:	8b 45 08             	mov    0x8(%ebp),%eax
  100a76:	8d 50 01             	lea    0x1(%eax),%edx
  100a79:	89 55 08             	mov    %edx,0x8(%ebp)
  100a7c:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  100a82:	0f b6 00             	movzbl (%eax),%eax
  100a85:	84 c0                	test   %al,%al
  100a87:	74 1d                	je     100aa6 <parse+0x42>
  100a89:	8b 45 08             	mov    0x8(%ebp),%eax
  100a8c:	0f b6 00             	movzbl (%eax),%eax
  100a8f:	0f be c0             	movsbl %al,%eax
  100a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a96:	c7 04 24 68 37 10 00 	movl   $0x103768,(%esp)
  100a9d:	e8 2f 27 00 00       	call   1031d1 <strchr>
  100aa2:	85 c0                	test   %eax,%eax
  100aa4:	75 cd                	jne    100a73 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa9:	0f b6 00             	movzbl (%eax),%eax
  100aac:	84 c0                	test   %al,%al
  100aae:	75 02                	jne    100ab2 <parse+0x4e>
            break;
  100ab0:	eb 67                	jmp    100b19 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100ab2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ab6:	75 14                	jne    100acc <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ab8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100abf:	00 
  100ac0:	c7 04 24 6d 37 10 00 	movl   $0x10376d,(%esp)
  100ac7:	e8 56 f8 ff ff       	call   100322 <cprintf>
        }
        argv[argc ++] = buf;
  100acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100acf:	8d 50 01             	lea    0x1(%eax),%edx
  100ad2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ad5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  100adf:	01 c2                	add    %eax,%edx
  100ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  100ae4:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ae6:	eb 04                	jmp    100aec <parse+0x88>
            buf ++;
  100ae8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100aec:	8b 45 08             	mov    0x8(%ebp),%eax
  100aef:	0f b6 00             	movzbl (%eax),%eax
  100af2:	84 c0                	test   %al,%al
  100af4:	74 1d                	je     100b13 <parse+0xaf>
  100af6:	8b 45 08             	mov    0x8(%ebp),%eax
  100af9:	0f b6 00             	movzbl (%eax),%eax
  100afc:	0f be c0             	movsbl %al,%eax
  100aff:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b03:	c7 04 24 68 37 10 00 	movl   $0x103768,(%esp)
  100b0a:	e8 c2 26 00 00       	call   1031d1 <strchr>
  100b0f:	85 c0                	test   %eax,%eax
  100b11:	74 d5                	je     100ae8 <parse+0x84>
            buf ++;
        }
    }
  100b13:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b14:	e9 66 ff ff ff       	jmp    100a7f <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b1c:	c9                   	leave  
  100b1d:	c3                   	ret    

00100b1e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b1e:	55                   	push   %ebp
  100b1f:	89 e5                	mov    %esp,%ebp
  100b21:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b24:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b2e:	89 04 24             	mov    %eax,(%esp)
  100b31:	e8 2e ff ff ff       	call   100a64 <parse>
  100b36:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b39:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b3d:	75 0a                	jne    100b49 <runcmd+0x2b>
        return 0;
  100b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  100b44:	e9 85 00 00 00       	jmp    100bce <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b50:	eb 5c                	jmp    100bae <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b52:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b58:	89 d0                	mov    %edx,%eax
  100b5a:	01 c0                	add    %eax,%eax
  100b5c:	01 d0                	add    %edx,%eax
  100b5e:	c1 e0 02             	shl    $0x2,%eax
  100b61:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b66:	8b 00                	mov    (%eax),%eax
  100b68:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b6c:	89 04 24             	mov    %eax,(%esp)
  100b6f:	e8 be 25 00 00       	call   103132 <strcmp>
  100b74:	85 c0                	test   %eax,%eax
  100b76:	75 32                	jne    100baa <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b7b:	89 d0                	mov    %edx,%eax
  100b7d:	01 c0                	add    %eax,%eax
  100b7f:	01 d0                	add    %edx,%eax
  100b81:	c1 e0 02             	shl    $0x2,%eax
  100b84:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b89:	8b 40 08             	mov    0x8(%eax),%eax
  100b8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100b8f:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100b92:	8b 55 0c             	mov    0xc(%ebp),%edx
  100b95:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b99:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100b9c:	83 c2 04             	add    $0x4,%edx
  100b9f:	89 54 24 04          	mov    %edx,0x4(%esp)
  100ba3:	89 0c 24             	mov    %ecx,(%esp)
  100ba6:	ff d0                	call   *%eax
  100ba8:	eb 24                	jmp    100bce <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100baa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bb1:	83 f8 02             	cmp    $0x2,%eax
  100bb4:	76 9c                	jbe    100b52 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bb6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bbd:	c7 04 24 8b 37 10 00 	movl   $0x10378b,(%esp)
  100bc4:	e8 59 f7 ff ff       	call   100322 <cprintf>
    return 0;
  100bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bce:	c9                   	leave  
  100bcf:	c3                   	ret    

00100bd0 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bd0:	55                   	push   %ebp
  100bd1:	89 e5                	mov    %esp,%ebp
  100bd3:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bd6:	c7 04 24 a4 37 10 00 	movl   $0x1037a4,(%esp)
  100bdd:	e8 40 f7 ff ff       	call   100322 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100be2:	c7 04 24 cc 37 10 00 	movl   $0x1037cc,(%esp)
  100be9:	e8 34 f7 ff ff       	call   100322 <cprintf>

    if (tf != NULL) {
  100bee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100bf2:	74 0b                	je     100bff <kmonitor+0x2f>
        print_trapframe(tf);
  100bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf7:	89 04 24             	mov    %eax,(%esp)
  100bfa:	e8 09 0e 00 00       	call   101a08 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100bff:	c7 04 24 f1 37 10 00 	movl   $0x1037f1,(%esp)
  100c06:	e8 0e f6 ff ff       	call   100219 <readline>
  100c0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c0e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c12:	74 18                	je     100c2c <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c14:	8b 45 08             	mov    0x8(%ebp),%eax
  100c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c1e:	89 04 24             	mov    %eax,(%esp)
  100c21:	e8 f8 fe ff ff       	call   100b1e <runcmd>
  100c26:	85 c0                	test   %eax,%eax
  100c28:	79 02                	jns    100c2c <kmonitor+0x5c>
                break;
  100c2a:	eb 02                	jmp    100c2e <kmonitor+0x5e>
            }
        }
    }
  100c2c:	eb d1                	jmp    100bff <kmonitor+0x2f>
}
  100c2e:	c9                   	leave  
  100c2f:	c3                   	ret    

00100c30 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c30:	55                   	push   %ebp
  100c31:	89 e5                	mov    %esp,%ebp
  100c33:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c3d:	eb 3f                	jmp    100c7e <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c42:	89 d0                	mov    %edx,%eax
  100c44:	01 c0                	add    %eax,%eax
  100c46:	01 d0                	add    %edx,%eax
  100c48:	c1 e0 02             	shl    $0x2,%eax
  100c4b:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c50:	8b 48 04             	mov    0x4(%eax),%ecx
  100c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c56:	89 d0                	mov    %edx,%eax
  100c58:	01 c0                	add    %eax,%eax
  100c5a:	01 d0                	add    %edx,%eax
  100c5c:	c1 e0 02             	shl    $0x2,%eax
  100c5f:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c64:	8b 00                	mov    (%eax),%eax
  100c66:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c6e:	c7 04 24 f5 37 10 00 	movl   $0x1037f5,(%esp)
  100c75:	e8 a8 f6 ff ff       	call   100322 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c81:	83 f8 02             	cmp    $0x2,%eax
  100c84:	76 b9                	jbe    100c3f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c8b:	c9                   	leave  
  100c8c:	c3                   	ret    

00100c8d <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100c8d:	55                   	push   %ebp
  100c8e:	89 e5                	mov    %esp,%ebp
  100c90:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100c93:	e8 be fb ff ff       	call   100856 <print_kerninfo>
    return 0;
  100c98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c9d:	c9                   	leave  
  100c9e:	c3                   	ret    

00100c9f <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100c9f:	55                   	push   %ebp
  100ca0:	89 e5                	mov    %esp,%ebp
  100ca2:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100ca5:	e8 f6 fc ff ff       	call   1009a0 <print_stackframe>
    return 0;
  100caa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100caf:	c9                   	leave  
  100cb0:	c3                   	ret    

00100cb1 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cb1:	55                   	push   %ebp
  100cb2:	89 e5                	mov    %esp,%ebp
  100cb4:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cb7:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  100cbc:	85 c0                	test   %eax,%eax
  100cbe:	74 02                	je     100cc2 <__panic+0x11>
        goto panic_dead;
  100cc0:	eb 59                	jmp    100d1b <__panic+0x6a>
    }
    is_panic = 1;
  100cc2:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  100cc9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100ccc:	8d 45 14             	lea    0x14(%ebp),%eax
  100ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  100cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ce0:	c7 04 24 fe 37 10 00 	movl   $0x1037fe,(%esp)
  100ce7:	e8 36 f6 ff ff       	call   100322 <cprintf>
    vcprintf(fmt, ap);
  100cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  100cf6:	89 04 24             	mov    %eax,(%esp)
  100cf9:	e8 f1 f5 ff ff       	call   1002ef <vcprintf>
    cprintf("\n");
  100cfe:	c7 04 24 1a 38 10 00 	movl   $0x10381a,(%esp)
  100d05:	e8 18 f6 ff ff       	call   100322 <cprintf>
    
    cprintf("stack trackback:\n");
  100d0a:	c7 04 24 1c 38 10 00 	movl   $0x10381c,(%esp)
  100d11:	e8 0c f6 ff ff       	call   100322 <cprintf>
    print_stackframe();
  100d16:	e8 85 fc ff ff       	call   1009a0 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d1b:	e8 22 09 00 00       	call   101642 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d27:	e8 a4 fe ff ff       	call   100bd0 <kmonitor>
    }
  100d2c:	eb f2                	jmp    100d20 <__panic+0x6f>

00100d2e <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d2e:	55                   	push   %ebp
  100d2f:	89 e5                	mov    %esp,%ebp
  100d31:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d34:	8d 45 14             	lea    0x14(%ebp),%eax
  100d37:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d41:	8b 45 08             	mov    0x8(%ebp),%eax
  100d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d48:	c7 04 24 2e 38 10 00 	movl   $0x10382e,(%esp)
  100d4f:	e8 ce f5 ff ff       	call   100322 <cprintf>
    vcprintf(fmt, ap);
  100d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d5b:	8b 45 10             	mov    0x10(%ebp),%eax
  100d5e:	89 04 24             	mov    %eax,(%esp)
  100d61:	e8 89 f5 ff ff       	call   1002ef <vcprintf>
    cprintf("\n");
  100d66:	c7 04 24 1a 38 10 00 	movl   $0x10381a,(%esp)
  100d6d:	e8 b0 f5 ff ff       	call   100322 <cprintf>
    va_end(ap);
}
  100d72:	c9                   	leave  
  100d73:	c3                   	ret    

00100d74 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d74:	55                   	push   %ebp
  100d75:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d77:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100d7c:	5d                   	pop    %ebp
  100d7d:	c3                   	ret    

00100d7e <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d7e:	55                   	push   %ebp
  100d7f:	89 e5                	mov    %esp,%ebp
  100d81:	83 ec 28             	sub    $0x28,%esp
  100d84:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d8a:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d8e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d92:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d96:	ee                   	out    %al,(%dx)
  100d97:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d9d:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100da1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100da5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100da9:	ee                   	out    %al,(%dx)
  100daa:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100db0:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100db4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100db8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dbc:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dbd:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100dc4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dc7:	c7 04 24 4c 38 10 00 	movl   $0x10384c,(%esp)
  100dce:	e8 4f f5 ff ff       	call   100322 <cprintf>
    pic_enable(IRQ_TIMER);
  100dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dda:	e8 c1 08 00 00       	call   1016a0 <pic_enable>
}
  100ddf:	c9                   	leave  
  100de0:	c3                   	ret    

00100de1 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100de1:	55                   	push   %ebp
  100de2:	89 e5                	mov    %esp,%ebp
  100de4:	83 ec 10             	sub    $0x10,%esp
  100de7:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ded:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100df1:	89 c2                	mov    %eax,%edx
  100df3:	ec                   	in     (%dx),%al
  100df4:	88 45 fd             	mov    %al,-0x3(%ebp)
  100df7:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100dfd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e01:	89 c2                	mov    %eax,%edx
  100e03:	ec                   	in     (%dx),%al
  100e04:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e07:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e0d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e11:	89 c2                	mov    %eax,%edx
  100e13:	ec                   	in     (%dx),%al
  100e14:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e17:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e1d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e21:	89 c2                	mov    %eax,%edx
  100e23:	ec                   	in     (%dx),%al
  100e24:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e27:	c9                   	leave  
  100e28:	c3                   	ret    

00100e29 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e29:	55                   	push   %ebp
  100e2a:	89 e5                	mov    %esp,%ebp
  100e2c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e2f:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e39:	0f b7 00             	movzwl (%eax),%eax
  100e3c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e43:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e48:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e4b:	0f b7 00             	movzwl (%eax),%eax
  100e4e:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e52:	74 12                	je     100e66 <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e54:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e5b:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e62:	b4 03 
  100e64:	eb 13                	jmp    100e79 <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e66:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e69:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e6d:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e70:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e77:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e79:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e80:	0f b7 c0             	movzwl %ax,%eax
  100e83:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e87:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e8b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e8f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e93:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e94:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e9b:	83 c0 01             	add    $0x1,%eax
  100e9e:	0f b7 c0             	movzwl %ax,%eax
  100ea1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ea5:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ea9:	89 c2                	mov    %eax,%edx
  100eab:	ec                   	in     (%dx),%al
  100eac:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100eaf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eb3:	0f b6 c0             	movzbl %al,%eax
  100eb6:	c1 e0 08             	shl    $0x8,%eax
  100eb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100ebc:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ec3:	0f b7 c0             	movzwl %ax,%eax
  100ec6:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100eca:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ece:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ed2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100ed6:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ed7:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ede:	83 c0 01             	add    $0x1,%eax
  100ee1:	0f b7 c0             	movzwl %ax,%eax
  100ee4:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ee8:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100eec:	89 c2                	mov    %eax,%edx
  100eee:	ec                   	in     (%dx),%al
  100eef:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100ef2:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ef6:	0f b6 c0             	movzbl %al,%eax
  100ef9:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100efc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eff:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f07:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100f0d:	c9                   	leave  
  100f0e:	c3                   	ret    

00100f0f <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f0f:	55                   	push   %ebp
  100f10:	89 e5                	mov    %esp,%ebp
  100f12:	83 ec 48             	sub    $0x48,%esp
  100f15:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f1b:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f1f:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f23:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f27:	ee                   	out    %al,(%dx)
  100f28:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f2e:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f32:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f36:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f3a:	ee                   	out    %al,(%dx)
  100f3b:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f41:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f45:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f49:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f4d:	ee                   	out    %al,(%dx)
  100f4e:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f54:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100f58:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f5c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f60:	ee                   	out    %al,(%dx)
  100f61:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f67:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f6b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f6f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f73:	ee                   	out    %al,(%dx)
  100f74:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f7a:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f7e:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f82:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f86:	ee                   	out    %al,(%dx)
  100f87:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f8d:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f91:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f95:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f99:	ee                   	out    %al,(%dx)
  100f9a:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fa0:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100fa4:	89 c2                	mov    %eax,%edx
  100fa6:	ec                   	in     (%dx),%al
  100fa7:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100faa:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fae:	3c ff                	cmp    $0xff,%al
  100fb0:	0f 95 c0             	setne  %al
  100fb3:	0f b6 c0             	movzbl %al,%eax
  100fb6:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fbb:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fc1:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100fc5:	89 c2                	mov    %eax,%edx
  100fc7:	ec                   	in     (%dx),%al
  100fc8:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100fcb:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100fd1:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100fd5:	89 c2                	mov    %eax,%edx
  100fd7:	ec                   	in     (%dx),%al
  100fd8:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fdb:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fe0:	85 c0                	test   %eax,%eax
  100fe2:	74 0c                	je     100ff0 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fe4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100feb:	e8 b0 06 00 00       	call   1016a0 <pic_enable>
    }
}
  100ff0:	c9                   	leave  
  100ff1:	c3                   	ret    

00100ff2 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100ff2:	55                   	push   %ebp
  100ff3:	89 e5                	mov    %esp,%ebp
  100ff5:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ff8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fff:	eb 09                	jmp    10100a <lpt_putc_sub+0x18>
        delay();
  101001:	e8 db fd ff ff       	call   100de1 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101006:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10100a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101010:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101014:	89 c2                	mov    %eax,%edx
  101016:	ec                   	in     (%dx),%al
  101017:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10101a:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10101e:	84 c0                	test   %al,%al
  101020:	78 09                	js     10102b <lpt_putc_sub+0x39>
  101022:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101029:	7e d6                	jle    101001 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  10102b:	8b 45 08             	mov    0x8(%ebp),%eax
  10102e:	0f b6 c0             	movzbl %al,%eax
  101031:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101037:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10103a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10103e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101042:	ee                   	out    %al,(%dx)
  101043:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101049:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  10104d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101051:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101055:	ee                   	out    %al,(%dx)
  101056:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  10105c:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  101060:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101064:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101068:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101069:	c9                   	leave  
  10106a:	c3                   	ret    

0010106b <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  10106b:	55                   	push   %ebp
  10106c:	89 e5                	mov    %esp,%ebp
  10106e:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101071:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101075:	74 0d                	je     101084 <lpt_putc+0x19>
        lpt_putc_sub(c);
  101077:	8b 45 08             	mov    0x8(%ebp),%eax
  10107a:	89 04 24             	mov    %eax,(%esp)
  10107d:	e8 70 ff ff ff       	call   100ff2 <lpt_putc_sub>
  101082:	eb 24                	jmp    1010a8 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  101084:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10108b:	e8 62 ff ff ff       	call   100ff2 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101090:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101097:	e8 56 ff ff ff       	call   100ff2 <lpt_putc_sub>
        lpt_putc_sub('\b');
  10109c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010a3:	e8 4a ff ff ff       	call   100ff2 <lpt_putc_sub>
    }
}
  1010a8:	c9                   	leave  
  1010a9:	c3                   	ret    

001010aa <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010aa:	55                   	push   %ebp
  1010ab:	89 e5                	mov    %esp,%ebp
  1010ad:	53                   	push   %ebx
  1010ae:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b4:	b0 00                	mov    $0x0,%al
  1010b6:	85 c0                	test   %eax,%eax
  1010b8:	75 07                	jne    1010c1 <cga_putc+0x17>
        c |= 0x0700;
  1010ba:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c4:	0f b6 c0             	movzbl %al,%eax
  1010c7:	83 f8 0a             	cmp    $0xa,%eax
  1010ca:	74 4c                	je     101118 <cga_putc+0x6e>
  1010cc:	83 f8 0d             	cmp    $0xd,%eax
  1010cf:	74 57                	je     101128 <cga_putc+0x7e>
  1010d1:	83 f8 08             	cmp    $0x8,%eax
  1010d4:	0f 85 88 00 00 00    	jne    101162 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  1010da:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010e1:	66 85 c0             	test   %ax,%ax
  1010e4:	74 30                	je     101116 <cga_putc+0x6c>
            crt_pos --;
  1010e6:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010ed:	83 e8 01             	sub    $0x1,%eax
  1010f0:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010f6:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010fb:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  101102:	0f b7 d2             	movzwl %dx,%edx
  101105:	01 d2                	add    %edx,%edx
  101107:	01 c2                	add    %eax,%edx
  101109:	8b 45 08             	mov    0x8(%ebp),%eax
  10110c:	b0 00                	mov    $0x0,%al
  10110e:	83 c8 20             	or     $0x20,%eax
  101111:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101114:	eb 72                	jmp    101188 <cga_putc+0xde>
  101116:	eb 70                	jmp    101188 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101118:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10111f:	83 c0 50             	add    $0x50,%eax
  101122:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101128:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  10112f:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101136:	0f b7 c1             	movzwl %cx,%eax
  101139:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10113f:	c1 e8 10             	shr    $0x10,%eax
  101142:	89 c2                	mov    %eax,%edx
  101144:	66 c1 ea 06          	shr    $0x6,%dx
  101148:	89 d0                	mov    %edx,%eax
  10114a:	c1 e0 02             	shl    $0x2,%eax
  10114d:	01 d0                	add    %edx,%eax
  10114f:	c1 e0 04             	shl    $0x4,%eax
  101152:	29 c1                	sub    %eax,%ecx
  101154:	89 ca                	mov    %ecx,%edx
  101156:	89 d8                	mov    %ebx,%eax
  101158:	29 d0                	sub    %edx,%eax
  10115a:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  101160:	eb 26                	jmp    101188 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101162:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101168:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10116f:	8d 50 01             	lea    0x1(%eax),%edx
  101172:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101179:	0f b7 c0             	movzwl %ax,%eax
  10117c:	01 c0                	add    %eax,%eax
  10117e:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101181:	8b 45 08             	mov    0x8(%ebp),%eax
  101184:	66 89 02             	mov    %ax,(%edx)
        break;
  101187:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101188:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10118f:	66 3d cf 07          	cmp    $0x7cf,%ax
  101193:	76 5b                	jbe    1011f0 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101195:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10119a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011a0:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011a5:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011ac:	00 
  1011ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011b1:	89 04 24             	mov    %eax,(%esp)
  1011b4:	e8 16 22 00 00       	call   1033cf <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011b9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011c0:	eb 15                	jmp    1011d7 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  1011c2:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011ca:	01 d2                	add    %edx,%edx
  1011cc:	01 d0                	add    %edx,%eax
  1011ce:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011d3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011d7:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011de:	7e e2                	jle    1011c2 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011e0:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011e7:	83 e8 50             	sub    $0x50,%eax
  1011ea:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011f0:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011f7:	0f b7 c0             	movzwl %ax,%eax
  1011fa:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011fe:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  101202:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101206:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10120a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  10120b:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101212:	66 c1 e8 08          	shr    $0x8,%ax
  101216:	0f b6 c0             	movzbl %al,%eax
  101219:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101220:	83 c2 01             	add    $0x1,%edx
  101223:	0f b7 d2             	movzwl %dx,%edx
  101226:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  10122a:	88 45 ed             	mov    %al,-0x13(%ebp)
  10122d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101231:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101235:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101236:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  10123d:	0f b7 c0             	movzwl %ax,%eax
  101240:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  101244:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  101248:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10124c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101250:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  101251:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101258:	0f b6 c0             	movzbl %al,%eax
  10125b:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101262:	83 c2 01             	add    $0x1,%edx
  101265:	0f b7 d2             	movzwl %dx,%edx
  101268:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  10126c:	88 45 e5             	mov    %al,-0x1b(%ebp)
  10126f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101273:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101277:	ee                   	out    %al,(%dx)
}
  101278:	83 c4 34             	add    $0x34,%esp
  10127b:	5b                   	pop    %ebx
  10127c:	5d                   	pop    %ebp
  10127d:	c3                   	ret    

0010127e <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  10127e:	55                   	push   %ebp
  10127f:	89 e5                	mov    %esp,%ebp
  101281:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101284:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10128b:	eb 09                	jmp    101296 <serial_putc_sub+0x18>
        delay();
  10128d:	e8 4f fb ff ff       	call   100de1 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101292:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101296:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10129c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1012a0:	89 c2                	mov    %eax,%edx
  1012a2:	ec                   	in     (%dx),%al
  1012a3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012a6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012aa:	0f b6 c0             	movzbl %al,%eax
  1012ad:	83 e0 20             	and    $0x20,%eax
  1012b0:	85 c0                	test   %eax,%eax
  1012b2:	75 09                	jne    1012bd <serial_putc_sub+0x3f>
  1012b4:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012bb:	7e d0                	jle    10128d <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1012c0:	0f b6 c0             	movzbl %al,%eax
  1012c3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012c9:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012cc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012d0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012d4:	ee                   	out    %al,(%dx)
}
  1012d5:	c9                   	leave  
  1012d6:	c3                   	ret    

001012d7 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012d7:	55                   	push   %ebp
  1012d8:	89 e5                	mov    %esp,%ebp
  1012da:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012dd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012e1:	74 0d                	je     1012f0 <serial_putc+0x19>
        serial_putc_sub(c);
  1012e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1012e6:	89 04 24             	mov    %eax,(%esp)
  1012e9:	e8 90 ff ff ff       	call   10127e <serial_putc_sub>
  1012ee:	eb 24                	jmp    101314 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  1012f0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012f7:	e8 82 ff ff ff       	call   10127e <serial_putc_sub>
        serial_putc_sub(' ');
  1012fc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101303:	e8 76 ff ff ff       	call   10127e <serial_putc_sub>
        serial_putc_sub('\b');
  101308:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10130f:	e8 6a ff ff ff       	call   10127e <serial_putc_sub>
    }
}
  101314:	c9                   	leave  
  101315:	c3                   	ret    

00101316 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101316:	55                   	push   %ebp
  101317:	89 e5                	mov    %esp,%ebp
  101319:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10131c:	eb 33                	jmp    101351 <cons_intr+0x3b>
        if (c != 0) {
  10131e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101322:	74 2d                	je     101351 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101324:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101329:	8d 50 01             	lea    0x1(%eax),%edx
  10132c:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  101332:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101335:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10133b:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101340:	3d 00 02 00 00       	cmp    $0x200,%eax
  101345:	75 0a                	jne    101351 <cons_intr+0x3b>
                cons.wpos = 0;
  101347:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  10134e:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  101351:	8b 45 08             	mov    0x8(%ebp),%eax
  101354:	ff d0                	call   *%eax
  101356:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101359:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10135d:	75 bf                	jne    10131e <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  10135f:	c9                   	leave  
  101360:	c3                   	ret    

00101361 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101361:	55                   	push   %ebp
  101362:	89 e5                	mov    %esp,%ebp
  101364:	83 ec 10             	sub    $0x10,%esp
  101367:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10136d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101371:	89 c2                	mov    %eax,%edx
  101373:	ec                   	in     (%dx),%al
  101374:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101377:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10137b:	0f b6 c0             	movzbl %al,%eax
  10137e:	83 e0 01             	and    $0x1,%eax
  101381:	85 c0                	test   %eax,%eax
  101383:	75 07                	jne    10138c <serial_proc_data+0x2b>
        return -1;
  101385:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10138a:	eb 2a                	jmp    1013b6 <serial_proc_data+0x55>
  10138c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101392:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101396:	89 c2                	mov    %eax,%edx
  101398:	ec                   	in     (%dx),%al
  101399:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  10139c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013a0:	0f b6 c0             	movzbl %al,%eax
  1013a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013a6:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013aa:	75 07                	jne    1013b3 <serial_proc_data+0x52>
        c = '\b';
  1013ac:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013b6:	c9                   	leave  
  1013b7:	c3                   	ret    

001013b8 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013b8:	55                   	push   %ebp
  1013b9:	89 e5                	mov    %esp,%ebp
  1013bb:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013be:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013c3:	85 c0                	test   %eax,%eax
  1013c5:	74 0c                	je     1013d3 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013c7:	c7 04 24 61 13 10 00 	movl   $0x101361,(%esp)
  1013ce:	e8 43 ff ff ff       	call   101316 <cons_intr>
    }
}
  1013d3:	c9                   	leave  
  1013d4:	c3                   	ret    

001013d5 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013d5:	55                   	push   %ebp
  1013d6:	89 e5                	mov    %esp,%ebp
  1013d8:	83 ec 38             	sub    $0x38,%esp
  1013db:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013e1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013e5:	89 c2                	mov    %eax,%edx
  1013e7:	ec                   	in     (%dx),%al
  1013e8:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013eb:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013ef:	0f b6 c0             	movzbl %al,%eax
  1013f2:	83 e0 01             	and    $0x1,%eax
  1013f5:	85 c0                	test   %eax,%eax
  1013f7:	75 0a                	jne    101403 <kbd_proc_data+0x2e>
        return -1;
  1013f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013fe:	e9 59 01 00 00       	jmp    10155c <kbd_proc_data+0x187>
  101403:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101409:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10140d:	89 c2                	mov    %eax,%edx
  10140f:	ec                   	in     (%dx),%al
  101410:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101413:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101417:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10141a:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  10141e:	75 17                	jne    101437 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  101420:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101425:	83 c8 40             	or     $0x40,%eax
  101428:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  10142d:	b8 00 00 00 00       	mov    $0x0,%eax
  101432:	e9 25 01 00 00       	jmp    10155c <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101437:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10143b:	84 c0                	test   %al,%al
  10143d:	79 47                	jns    101486 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10143f:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101444:	83 e0 40             	and    $0x40,%eax
  101447:	85 c0                	test   %eax,%eax
  101449:	75 09                	jne    101454 <kbd_proc_data+0x7f>
  10144b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10144f:	83 e0 7f             	and    $0x7f,%eax
  101452:	eb 04                	jmp    101458 <kbd_proc_data+0x83>
  101454:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101458:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  10145b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10145f:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101466:	83 c8 40             	or     $0x40,%eax
  101469:	0f b6 c0             	movzbl %al,%eax
  10146c:	f7 d0                	not    %eax
  10146e:	89 c2                	mov    %eax,%edx
  101470:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101475:	21 d0                	and    %edx,%eax
  101477:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  10147c:	b8 00 00 00 00       	mov    $0x0,%eax
  101481:	e9 d6 00 00 00       	jmp    10155c <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  101486:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10148b:	83 e0 40             	and    $0x40,%eax
  10148e:	85 c0                	test   %eax,%eax
  101490:	74 11                	je     1014a3 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101492:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101496:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10149b:	83 e0 bf             	and    $0xffffffbf,%eax
  10149e:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  1014a3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a7:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1014ae:	0f b6 d0             	movzbl %al,%edx
  1014b1:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014b6:	09 d0                	or     %edx,%eax
  1014b8:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014bd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c1:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014c8:	0f b6 d0             	movzbl %al,%edx
  1014cb:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d0:	31 d0                	xor    %edx,%eax
  1014d2:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014d7:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014dc:	83 e0 03             	and    $0x3,%eax
  1014df:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014e6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ea:	01 d0                	add    %edx,%eax
  1014ec:	0f b6 00             	movzbl (%eax),%eax
  1014ef:	0f b6 c0             	movzbl %al,%eax
  1014f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014f5:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014fa:	83 e0 08             	and    $0x8,%eax
  1014fd:	85 c0                	test   %eax,%eax
  1014ff:	74 22                	je     101523 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101501:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101505:	7e 0c                	jle    101513 <kbd_proc_data+0x13e>
  101507:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10150b:	7f 06                	jg     101513 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10150d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101511:	eb 10                	jmp    101523 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101513:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101517:	7e 0a                	jle    101523 <kbd_proc_data+0x14e>
  101519:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10151d:	7f 04                	jg     101523 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10151f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101523:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101528:	f7 d0                	not    %eax
  10152a:	83 e0 06             	and    $0x6,%eax
  10152d:	85 c0                	test   %eax,%eax
  10152f:	75 28                	jne    101559 <kbd_proc_data+0x184>
  101531:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101538:	75 1f                	jne    101559 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  10153a:	c7 04 24 67 38 10 00 	movl   $0x103867,(%esp)
  101541:	e8 dc ed ff ff       	call   100322 <cprintf>
  101546:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  10154c:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101550:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101554:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101558:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101559:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10155c:	c9                   	leave  
  10155d:	c3                   	ret    

0010155e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10155e:	55                   	push   %ebp
  10155f:	89 e5                	mov    %esp,%ebp
  101561:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101564:	c7 04 24 d5 13 10 00 	movl   $0x1013d5,(%esp)
  10156b:	e8 a6 fd ff ff       	call   101316 <cons_intr>
}
  101570:	c9                   	leave  
  101571:	c3                   	ret    

00101572 <kbd_init>:

static void
kbd_init(void) {
  101572:	55                   	push   %ebp
  101573:	89 e5                	mov    %esp,%ebp
  101575:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101578:	e8 e1 ff ff ff       	call   10155e <kbd_intr>
    pic_enable(IRQ_KBD);
  10157d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101584:	e8 17 01 00 00       	call   1016a0 <pic_enable>
}
  101589:	c9                   	leave  
  10158a:	c3                   	ret    

0010158b <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10158b:	55                   	push   %ebp
  10158c:	89 e5                	mov    %esp,%ebp
  10158e:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101591:	e8 93 f8 ff ff       	call   100e29 <cga_init>
    serial_init();
  101596:	e8 74 f9 ff ff       	call   100f0f <serial_init>
    kbd_init();
  10159b:	e8 d2 ff ff ff       	call   101572 <kbd_init>
    if (!serial_exists) {
  1015a0:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1015a5:	85 c0                	test   %eax,%eax
  1015a7:	75 0c                	jne    1015b5 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015a9:	c7 04 24 73 38 10 00 	movl   $0x103873,(%esp)
  1015b0:	e8 6d ed ff ff       	call   100322 <cprintf>
    }
}
  1015b5:	c9                   	leave  
  1015b6:	c3                   	ret    

001015b7 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015b7:	55                   	push   %ebp
  1015b8:	89 e5                	mov    %esp,%ebp
  1015ba:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1015c0:	89 04 24             	mov    %eax,(%esp)
  1015c3:	e8 a3 fa ff ff       	call   10106b <lpt_putc>
    cga_putc(c);
  1015c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1015cb:	89 04 24             	mov    %eax,(%esp)
  1015ce:	e8 d7 fa ff ff       	call   1010aa <cga_putc>
    serial_putc(c);
  1015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1015d6:	89 04 24             	mov    %eax,(%esp)
  1015d9:	e8 f9 fc ff ff       	call   1012d7 <serial_putc>
}
  1015de:	c9                   	leave  
  1015df:	c3                   	ret    

001015e0 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015e0:	55                   	push   %ebp
  1015e1:	89 e5                	mov    %esp,%ebp
  1015e3:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015e6:	e8 cd fd ff ff       	call   1013b8 <serial_intr>
    kbd_intr();
  1015eb:	e8 6e ff ff ff       	call   10155e <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015f0:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015f6:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015fb:	39 c2                	cmp    %eax,%edx
  1015fd:	74 36                	je     101635 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015ff:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101604:	8d 50 01             	lea    0x1(%eax),%edx
  101607:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  10160d:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101614:	0f b6 c0             	movzbl %al,%eax
  101617:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  10161a:	a1 80 f0 10 00       	mov    0x10f080,%eax
  10161f:	3d 00 02 00 00       	cmp    $0x200,%eax
  101624:	75 0a                	jne    101630 <cons_getc+0x50>
            cons.rpos = 0;
  101626:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  10162d:	00 00 00 
        }
        return c;
  101630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101633:	eb 05                	jmp    10163a <cons_getc+0x5a>
    }
    return 0;
  101635:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10163a:	c9                   	leave  
  10163b:	c3                   	ret    

0010163c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10163c:	55                   	push   %ebp
  10163d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  10163f:	fb                   	sti    
    sti();
}
  101640:	5d                   	pop    %ebp
  101641:	c3                   	ret    

00101642 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101642:	55                   	push   %ebp
  101643:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  101645:	fa                   	cli    
    cli();
}
  101646:	5d                   	pop    %ebp
  101647:	c3                   	ret    

00101648 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101648:	55                   	push   %ebp
  101649:	89 e5                	mov    %esp,%ebp
  10164b:	83 ec 14             	sub    $0x14,%esp
  10164e:	8b 45 08             	mov    0x8(%ebp),%eax
  101651:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101655:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101659:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  10165f:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101664:	85 c0                	test   %eax,%eax
  101666:	74 36                	je     10169e <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101668:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10166c:	0f b6 c0             	movzbl %al,%eax
  10166f:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101675:	88 45 fd             	mov    %al,-0x3(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101678:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10167c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101680:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101681:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101685:	66 c1 e8 08          	shr    $0x8,%ax
  101689:	0f b6 c0             	movzbl %al,%eax
  10168c:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  101692:	88 45 f9             	mov    %al,-0x7(%ebp)
  101695:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101699:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10169d:	ee                   	out    %al,(%dx)
    }
}
  10169e:	c9                   	leave  
  10169f:	c3                   	ret    

001016a0 <pic_enable>:

void
pic_enable(unsigned int irq) {
  1016a0:	55                   	push   %ebp
  1016a1:	89 e5                	mov    %esp,%ebp
  1016a3:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a9:	ba 01 00 00 00       	mov    $0x1,%edx
  1016ae:	89 c1                	mov    %eax,%ecx
  1016b0:	d3 e2                	shl    %cl,%edx
  1016b2:	89 d0                	mov    %edx,%eax
  1016b4:	f7 d0                	not    %eax
  1016b6:	89 c2                	mov    %eax,%edx
  1016b8:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016bf:	21 d0                	and    %edx,%eax
  1016c1:	0f b7 c0             	movzwl %ax,%eax
  1016c4:	89 04 24             	mov    %eax,(%esp)
  1016c7:	e8 7c ff ff ff       	call   101648 <pic_setmask>
}
  1016cc:	c9                   	leave  
  1016cd:	c3                   	ret    

001016ce <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016ce:	55                   	push   %ebp
  1016cf:	89 e5                	mov    %esp,%ebp
  1016d1:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016d4:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016db:	00 00 00 
  1016de:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016e4:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016e8:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016ec:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016f0:	ee                   	out    %al,(%dx)
  1016f1:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016f7:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  1016fb:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016ff:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101703:	ee                   	out    %al,(%dx)
  101704:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10170a:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  10170e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101712:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101716:	ee                   	out    %al,(%dx)
  101717:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  10171d:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  101721:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101725:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101729:	ee                   	out    %al,(%dx)
  10172a:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  101730:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  101734:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101738:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10173c:	ee                   	out    %al,(%dx)
  10173d:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  101743:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  101747:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10174b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10174f:	ee                   	out    %al,(%dx)
  101750:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101756:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  10175a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10175e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101762:	ee                   	out    %al,(%dx)
  101763:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101769:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  10176d:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101771:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101775:	ee                   	out    %al,(%dx)
  101776:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  10177c:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  101780:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101784:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101788:	ee                   	out    %al,(%dx)
  101789:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  10178f:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  101793:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101797:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10179b:	ee                   	out    %al,(%dx)
  10179c:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  1017a2:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  1017a6:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017aa:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017ae:	ee                   	out    %al,(%dx)
  1017af:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017b5:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  1017b9:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017bd:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017c1:	ee                   	out    %al,(%dx)
  1017c2:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  1017c8:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  1017cc:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017d0:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017d4:	ee                   	out    %al,(%dx)
  1017d5:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017db:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017df:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017e3:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017e7:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017e8:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017ef:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017f3:	74 12                	je     101807 <pic_init+0x139>
        pic_setmask(irq_mask);
  1017f5:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017fc:	0f b7 c0             	movzwl %ax,%eax
  1017ff:	89 04 24             	mov    %eax,(%esp)
  101802:	e8 41 fe ff ff       	call   101648 <pic_setmask>
    }
}
  101807:	c9                   	leave  
  101808:	c3                   	ret    

00101809 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101809:	55                   	push   %ebp
  10180a:	89 e5                	mov    %esp,%ebp
  10180c:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10180f:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101816:	00 
  101817:	c7 04 24 a0 38 10 00 	movl   $0x1038a0,(%esp)
  10181e:	e8 ff ea ff ff       	call   100322 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101823:	c7 04 24 aa 38 10 00 	movl   $0x1038aa,(%esp)
  10182a:	e8 f3 ea ff ff       	call   100322 <cprintf>
    panic("EOT: kernel seems ok.");
  10182f:	c7 44 24 08 b8 38 10 	movl   $0x1038b8,0x8(%esp)
  101836:	00 
  101837:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  10183e:	00 
  10183f:	c7 04 24 ce 38 10 00 	movl   $0x1038ce,(%esp)
  101846:	e8 66 f4 ff ff       	call   100cb1 <__panic>

0010184b <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10184b:	55                   	push   %ebp
  10184c:	89 e5                	mov    %esp,%ebp
  10184e:	83 ec 10             	sub    $0x10,%esp
extern uintptr_t __vectors[];
 int gatenum=sizeof(idt)/sizeof(struct gatedesc);
  101851:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
 int i;
 for(i=0; i<gatenum; i++)
  101858:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10185f:	e9 c3 00 00 00       	jmp    101927 <idt_init+0xdc>
 {
 SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101864:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101867:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  10186e:	89 c2                	mov    %eax,%edx
  101870:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101873:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  10187a:	00 
  10187b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187e:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  101885:	00 08 00 
  101888:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10188b:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101892:	00 
  101893:	83 e2 e0             	and    $0xffffffe0,%edx
  101896:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  10189d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018a0:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  1018a7:	00 
  1018a8:	83 e2 1f             	and    $0x1f,%edx
  1018ab:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  1018b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b5:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018bc:	00 
  1018bd:	83 e2 f0             	and    $0xfffffff0,%edx
  1018c0:	83 ca 0e             	or     $0xe,%edx
  1018c3:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018cd:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018d4:	00 
  1018d5:	83 e2 ef             	and    $0xffffffef,%edx
  1018d8:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e2:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018e9:	00 
  1018ea:	83 e2 9f             	and    $0xffffff9f,%edx
  1018ed:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f7:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018fe:	00 
  1018ff:	83 ca 80             	or     $0xffffff80,%edx
  101902:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  101909:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190c:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101913:	c1 e8 10             	shr    $0x10,%eax
  101916:	89 c2                	mov    %eax,%edx
  101918:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191b:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  101922:	00 
void
idt_init(void) {
extern uintptr_t __vectors[];
 int gatenum=sizeof(idt)/sizeof(struct gatedesc);
 int i;
 for(i=0; i<gatenum; i++)
  101923:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101927:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  10192d:	0f 8c 31 ff ff ff    	jl     101864 <idt_init+0x19>
 {
 SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
 }
 SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101933:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101938:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  10193e:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  101945:	08 00 
  101947:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10194e:	83 e0 e0             	and    $0xffffffe0,%eax
  101951:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101956:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  10195d:	83 e0 1f             	and    $0x1f,%eax
  101960:	a2 6c f4 10 00       	mov    %al,0x10f46c
  101965:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10196c:	83 e0 f0             	and    $0xfffffff0,%eax
  10196f:	83 c8 0e             	or     $0xe,%eax
  101972:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101977:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10197e:	83 e0 ef             	and    $0xffffffef,%eax
  101981:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101986:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10198d:	83 c8 60             	or     $0x60,%eax
  101990:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101995:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10199c:	83 c8 80             	or     $0xffffff80,%eax
  10199f:	a2 6d f4 10 00       	mov    %al,0x10f46d
  1019a4:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1019a9:	c1 e8 10             	shr    $0x10,%eax
  1019ac:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  1019b2:	c7 45 f4 60 e5 10 00 	movl   $0x10e560,-0xc(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  1019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1019bc:	0f 01 18             	lidtl  (%eax)
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
}
  1019bf:	c9                   	leave  
  1019c0:	c3                   	ret    

001019c1 <trapname>:

static const char *
trapname(int trapno) {
  1019c1:	55                   	push   %ebp
  1019c2:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c7:	83 f8 13             	cmp    $0x13,%eax
  1019ca:	77 0c                	ja     1019d8 <trapname+0x17>
        return excnames[trapno];
  1019cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1019cf:	8b 04 85 20 3c 10 00 	mov    0x103c20(,%eax,4),%eax
  1019d6:	eb 18                	jmp    1019f0 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019d8:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019dc:	7e 0d                	jle    1019eb <trapname+0x2a>
  1019de:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019e2:	7f 07                	jg     1019eb <trapname+0x2a>
        return "Hardware Interrupt";
  1019e4:	b8 df 38 10 00       	mov    $0x1038df,%eax
  1019e9:	eb 05                	jmp    1019f0 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019eb:	b8 f2 38 10 00       	mov    $0x1038f2,%eax
}
  1019f0:	5d                   	pop    %ebp
  1019f1:	c3                   	ret    

001019f2 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019f2:	55                   	push   %ebp
  1019f3:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019fc:	66 83 f8 08          	cmp    $0x8,%ax
  101a00:	0f 94 c0             	sete   %al
  101a03:	0f b6 c0             	movzbl %al,%eax
}
  101a06:	5d                   	pop    %ebp
  101a07:	c3                   	ret    

00101a08 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a08:	55                   	push   %ebp
  101a09:	89 e5                	mov    %esp,%ebp
  101a0b:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a15:	c7 04 24 33 39 10 00 	movl   $0x103933,(%esp)
  101a1c:	e8 01 e9 ff ff       	call   100322 <cprintf>
    print_regs(&tf->tf_regs);
  101a21:	8b 45 08             	mov    0x8(%ebp),%eax
  101a24:	89 04 24             	mov    %eax,(%esp)
  101a27:	e8 a1 01 00 00       	call   101bcd <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a2f:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a33:	0f b7 c0             	movzwl %ax,%eax
  101a36:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a3a:	c7 04 24 44 39 10 00 	movl   $0x103944,(%esp)
  101a41:	e8 dc e8 ff ff       	call   100322 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a46:	8b 45 08             	mov    0x8(%ebp),%eax
  101a49:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a4d:	0f b7 c0             	movzwl %ax,%eax
  101a50:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a54:	c7 04 24 57 39 10 00 	movl   $0x103957,(%esp)
  101a5b:	e8 c2 e8 ff ff       	call   100322 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a60:	8b 45 08             	mov    0x8(%ebp),%eax
  101a63:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a67:	0f b7 c0             	movzwl %ax,%eax
  101a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6e:	c7 04 24 6a 39 10 00 	movl   $0x10396a,(%esp)
  101a75:	e8 a8 e8 ff ff       	call   100322 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a81:	0f b7 c0             	movzwl %ax,%eax
  101a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a88:	c7 04 24 7d 39 10 00 	movl   $0x10397d,(%esp)
  101a8f:	e8 8e e8 ff ff       	call   100322 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a94:	8b 45 08             	mov    0x8(%ebp),%eax
  101a97:	8b 40 30             	mov    0x30(%eax),%eax
  101a9a:	89 04 24             	mov    %eax,(%esp)
  101a9d:	e8 1f ff ff ff       	call   1019c1 <trapname>
  101aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  101aa5:	8b 52 30             	mov    0x30(%edx),%edx
  101aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  101aac:	89 54 24 04          	mov    %edx,0x4(%esp)
  101ab0:	c7 04 24 90 39 10 00 	movl   $0x103990,(%esp)
  101ab7:	e8 66 e8 ff ff       	call   100322 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101abc:	8b 45 08             	mov    0x8(%ebp),%eax
  101abf:	8b 40 34             	mov    0x34(%eax),%eax
  101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac6:	c7 04 24 a2 39 10 00 	movl   $0x1039a2,(%esp)
  101acd:	e8 50 e8 ff ff       	call   100322 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad5:	8b 40 38             	mov    0x38(%eax),%eax
  101ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101adc:	c7 04 24 b1 39 10 00 	movl   $0x1039b1,(%esp)
  101ae3:	e8 3a e8 ff ff       	call   100322 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  101aeb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aef:	0f b7 c0             	movzwl %ax,%eax
  101af2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af6:	c7 04 24 c0 39 10 00 	movl   $0x1039c0,(%esp)
  101afd:	e8 20 e8 ff ff       	call   100322 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101b02:	8b 45 08             	mov    0x8(%ebp),%eax
  101b05:	8b 40 40             	mov    0x40(%eax),%eax
  101b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0c:	c7 04 24 d3 39 10 00 	movl   $0x1039d3,(%esp)
  101b13:	e8 0a e8 ff ff       	call   100322 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b1f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b26:	eb 3e                	jmp    101b66 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b28:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2b:	8b 50 40             	mov    0x40(%eax),%edx
  101b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b31:	21 d0                	and    %edx,%eax
  101b33:	85 c0                	test   %eax,%eax
  101b35:	74 28                	je     101b5f <print_trapframe+0x157>
  101b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b3a:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b41:	85 c0                	test   %eax,%eax
  101b43:	74 1a                	je     101b5f <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b48:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b53:	c7 04 24 e2 39 10 00 	movl   $0x1039e2,(%esp)
  101b5a:	e8 c3 e7 ff ff       	call   100322 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b63:	d1 65 f0             	shll   -0x10(%ebp)
  101b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b69:	83 f8 17             	cmp    $0x17,%eax
  101b6c:	76 ba                	jbe    101b28 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b71:	8b 40 40             	mov    0x40(%eax),%eax
  101b74:	25 00 30 00 00       	and    $0x3000,%eax
  101b79:	c1 e8 0c             	shr    $0xc,%eax
  101b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b80:	c7 04 24 e6 39 10 00 	movl   $0x1039e6,(%esp)
  101b87:	e8 96 e7 ff ff       	call   100322 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8f:	89 04 24             	mov    %eax,(%esp)
  101b92:	e8 5b fe ff ff       	call   1019f2 <trap_in_kernel>
  101b97:	85 c0                	test   %eax,%eax
  101b99:	75 30                	jne    101bcb <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9e:	8b 40 44             	mov    0x44(%eax),%eax
  101ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba5:	c7 04 24 ef 39 10 00 	movl   $0x1039ef,(%esp)
  101bac:	e8 71 e7 ff ff       	call   100322 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb4:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bb8:	0f b7 c0             	movzwl %ax,%eax
  101bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbf:	c7 04 24 fe 39 10 00 	movl   $0x1039fe,(%esp)
  101bc6:	e8 57 e7 ff ff       	call   100322 <cprintf>
    }
}
  101bcb:	c9                   	leave  
  101bcc:	c3                   	ret    

00101bcd <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bcd:	55                   	push   %ebp
  101bce:	89 e5                	mov    %esp,%ebp
  101bd0:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd6:	8b 00                	mov    (%eax),%eax
  101bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdc:	c7 04 24 11 3a 10 00 	movl   $0x103a11,(%esp)
  101be3:	e8 3a e7 ff ff       	call   100322 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101be8:	8b 45 08             	mov    0x8(%ebp),%eax
  101beb:	8b 40 04             	mov    0x4(%eax),%eax
  101bee:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf2:	c7 04 24 20 3a 10 00 	movl   $0x103a20,(%esp)
  101bf9:	e8 24 e7 ff ff       	call   100322 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  101c01:	8b 40 08             	mov    0x8(%eax),%eax
  101c04:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c08:	c7 04 24 2f 3a 10 00 	movl   $0x103a2f,(%esp)
  101c0f:	e8 0e e7 ff ff       	call   100322 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c14:	8b 45 08             	mov    0x8(%ebp),%eax
  101c17:	8b 40 0c             	mov    0xc(%eax),%eax
  101c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1e:	c7 04 24 3e 3a 10 00 	movl   $0x103a3e,(%esp)
  101c25:	e8 f8 e6 ff ff       	call   100322 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2d:	8b 40 10             	mov    0x10(%eax),%eax
  101c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c34:	c7 04 24 4d 3a 10 00 	movl   $0x103a4d,(%esp)
  101c3b:	e8 e2 e6 ff ff       	call   100322 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c40:	8b 45 08             	mov    0x8(%ebp),%eax
  101c43:	8b 40 14             	mov    0x14(%eax),%eax
  101c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4a:	c7 04 24 5c 3a 10 00 	movl   $0x103a5c,(%esp)
  101c51:	e8 cc e6 ff ff       	call   100322 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c56:	8b 45 08             	mov    0x8(%ebp),%eax
  101c59:	8b 40 18             	mov    0x18(%eax),%eax
  101c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c60:	c7 04 24 6b 3a 10 00 	movl   $0x103a6b,(%esp)
  101c67:	e8 b6 e6 ff ff       	call   100322 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6f:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c72:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c76:	c7 04 24 7a 3a 10 00 	movl   $0x103a7a,(%esp)
  101c7d:	e8 a0 e6 ff ff       	call   100322 <cprintf>
}
  101c82:	c9                   	leave  
  101c83:	c3                   	ret    

00101c84 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c84:	55                   	push   %ebp
  101c85:	89 e5                	mov    %esp,%ebp
  101c87:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8d:	8b 40 30             	mov    0x30(%eax),%eax
  101c90:	83 f8 2f             	cmp    $0x2f,%eax
  101c93:	77 21                	ja     101cb6 <trap_dispatch+0x32>
  101c95:	83 f8 2e             	cmp    $0x2e,%eax
  101c98:	0f 83 59 01 00 00    	jae    101df7 <trap_dispatch+0x173>
  101c9e:	83 f8 21             	cmp    $0x21,%eax
  101ca1:	0f 84 8a 00 00 00    	je     101d31 <trap_dispatch+0xad>
  101ca7:	83 f8 24             	cmp    $0x24,%eax
  101caa:	74 5c                	je     101d08 <trap_dispatch+0x84>
  101cac:	83 f8 20             	cmp    $0x20,%eax
  101caf:	74 1c                	je     101ccd <trap_dispatch+0x49>
  101cb1:	e9 09 01 00 00       	jmp    101dbf <trap_dispatch+0x13b>
  101cb6:	83 f8 78             	cmp    $0x78,%eax
  101cb9:	0f 84 9b 00 00 00    	je     101d5a <trap_dispatch+0xd6>
  101cbf:	83 f8 79             	cmp    $0x79,%eax
  101cc2:	0f 84 c9 00 00 00    	je     101d91 <trap_dispatch+0x10d>
  101cc8:	e9 f2 00 00 00       	jmp    101dbf <trap_dispatch+0x13b>
    case IRQ_OFFSET + IRQ_TIMER:
ticks++;
  101ccd:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cd2:	83 c0 01             	add    $0x1,%eax
  101cd5:	a3 08 f9 10 00       	mov    %eax,0x10f908
 if(ticks%TICK_NUM==0)
  101cda:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101ce0:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101ce5:	89 c8                	mov    %ecx,%eax
  101ce7:	f7 e2                	mul    %edx
  101ce9:	89 d0                	mov    %edx,%eax
  101ceb:	c1 e8 05             	shr    $0x5,%eax
  101cee:	6b c0 64             	imul   $0x64,%eax,%eax
  101cf1:	29 c1                	sub    %eax,%ecx
  101cf3:	89 c8                	mov    %ecx,%eax
  101cf5:	85 c0                	test   %eax,%eax
  101cf7:	75 0a                	jne    101d03 <trap_dispatch+0x7f>
 { print_ticks();}        
  101cf9:	e8 0b fb ff ff       	call   101809 <print_ticks>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        break;
  101cfe:	e9 f5 00 00 00       	jmp    101df8 <trap_dispatch+0x174>
  101d03:	e9 f0 00 00 00       	jmp    101df8 <trap_dispatch+0x174>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d08:	e8 d3 f8 ff ff       	call   1015e0 <cons_getc>
  101d0d:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d10:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d14:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d18:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d20:	c7 04 24 89 3a 10 00 	movl   $0x103a89,(%esp)
  101d27:	e8 f6 e5 ff ff       	call   100322 <cprintf>
        break;
  101d2c:	e9 c7 00 00 00       	jmp    101df8 <trap_dispatch+0x174>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d31:	e8 aa f8 ff ff       	call   1015e0 <cons_getc>
  101d36:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d39:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d3d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d41:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d49:	c7 04 24 9b 3a 10 00 	movl   $0x103a9b,(%esp)
  101d50:	e8 cd e5 ff ff       	call   100322 <cprintf>
        break;
  101d55:	e9 9e 00 00 00       	jmp    101df8 <trap_dispatch+0x174>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
 tf->tf_cs = USER_CS;
  101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            tf->tf_ds = USER_DS;
  101d63:	8b 45 08             	mov    0x8(%ebp),%eax
  101d66:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
  101d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6f:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
  101d75:	8b 45 08             	mov    0x8(%ebp),%eax
  101d78:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
tf->tf_eflags|= FL_IOPL_MASK;
  101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d81:	8b 40 40             	mov    0x40(%eax),%eax
  101d84:	80 cc 30             	or     $0x30,%ah
  101d87:	89 c2                	mov    %eax,%edx
  101d89:	8b 45 08             	mov    0x8(%ebp),%eax
  101d8c:	89 50 40             	mov    %edx,0x40(%eax)
break;
  101d8f:	eb 67                	jmp    101df8 <trap_dispatch+0x174>
   case T_SWITCH_TOK:
         tf->tf_cs = KERNEL_CS;
  101d91:	8b 45 08             	mov    0x8(%ebp),%eax
  101d94:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = KERNEL_DS;
  101d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d9d:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
  101da3:	8b 45 08             	mov    0x8(%ebp),%eax
  101da6:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
tf->tf_eflags &= ~FL_IOPL_MASK;
  101dac:	8b 45 08             	mov    0x8(%ebp),%eax
  101daf:	8b 40 40             	mov    0x40(%eax),%eax
  101db2:	80 e4 cf             	and    $0xcf,%ah
  101db5:	89 c2                	mov    %eax,%edx
  101db7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dba:	89 50 40             	mov    %edx,0x40(%eax)
break;
  101dbd:	eb 39                	jmp    101df8 <trap_dispatch+0x174>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101dc6:	0f b7 c0             	movzwl %ax,%eax
  101dc9:	83 e0 03             	and    $0x3,%eax
  101dcc:	85 c0                	test   %eax,%eax
  101dce:	75 28                	jne    101df8 <trap_dispatch+0x174>
            print_trapframe(tf);
  101dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd3:	89 04 24             	mov    %eax,(%esp)
  101dd6:	e8 2d fc ff ff       	call   101a08 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101ddb:	c7 44 24 08 aa 3a 10 	movl   $0x103aaa,0x8(%esp)
  101de2:	00 
  101de3:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
  101dea:	00 
  101deb:	c7 04 24 ce 38 10 00 	movl   $0x1038ce,(%esp)
  101df2:	e8 ba ee ff ff       	call   100cb1 <__panic>
tf->tf_eflags &= ~FL_IOPL_MASK;
break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101df7:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101df8:	c9                   	leave  
  101df9:	c3                   	ret    

00101dfa <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101dfa:	55                   	push   %ebp
  101dfb:	89 e5                	mov    %esp,%ebp
  101dfd:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e00:	8b 45 08             	mov    0x8(%ebp),%eax
  101e03:	89 04 24             	mov    %eax,(%esp)
  101e06:	e8 79 fe ff ff       	call   101c84 <trap_dispatch>
}
  101e0b:	c9                   	leave  
  101e0c:	c3                   	ret    

00101e0d <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101e0d:	1e                   	push   %ds
    pushl %es
  101e0e:	06                   	push   %es
    pushl %fs
  101e0f:	0f a0                	push   %fs
    pushl %gs
  101e11:	0f a8                	push   %gs
    pushal
  101e13:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101e14:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101e19:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101e1b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101e1d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101e1e:	e8 d7 ff ff ff       	call   101dfa <trap>

    # pop the pushed stack pointer
    popl %esp
  101e23:	5c                   	pop    %esp

00101e24 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101e24:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101e25:	0f a9                	pop    %gs
    popl %fs
  101e27:	0f a1                	pop    %fs
    popl %es
  101e29:	07                   	pop    %es
    popl %ds
  101e2a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101e2b:	83 c4 08             	add    $0x8,%esp
    iret
  101e2e:	cf                   	iret   

00101e2f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101e2f:	6a 00                	push   $0x0
  pushl $0
  101e31:	6a 00                	push   $0x0
  jmp __alltraps
  101e33:	e9 d5 ff ff ff       	jmp    101e0d <__alltraps>

00101e38 <vector1>:
.globl vector1
vector1:
  pushl $0
  101e38:	6a 00                	push   $0x0
  pushl $1
  101e3a:	6a 01                	push   $0x1
  jmp __alltraps
  101e3c:	e9 cc ff ff ff       	jmp    101e0d <__alltraps>

00101e41 <vector2>:
.globl vector2
vector2:
  pushl $0
  101e41:	6a 00                	push   $0x0
  pushl $2
  101e43:	6a 02                	push   $0x2
  jmp __alltraps
  101e45:	e9 c3 ff ff ff       	jmp    101e0d <__alltraps>

00101e4a <vector3>:
.globl vector3
vector3:
  pushl $0
  101e4a:	6a 00                	push   $0x0
  pushl $3
  101e4c:	6a 03                	push   $0x3
  jmp __alltraps
  101e4e:	e9 ba ff ff ff       	jmp    101e0d <__alltraps>

00101e53 <vector4>:
.globl vector4
vector4:
  pushl $0
  101e53:	6a 00                	push   $0x0
  pushl $4
  101e55:	6a 04                	push   $0x4
  jmp __alltraps
  101e57:	e9 b1 ff ff ff       	jmp    101e0d <__alltraps>

00101e5c <vector5>:
.globl vector5
vector5:
  pushl $0
  101e5c:	6a 00                	push   $0x0
  pushl $5
  101e5e:	6a 05                	push   $0x5
  jmp __alltraps
  101e60:	e9 a8 ff ff ff       	jmp    101e0d <__alltraps>

00101e65 <vector6>:
.globl vector6
vector6:
  pushl $0
  101e65:	6a 00                	push   $0x0
  pushl $6
  101e67:	6a 06                	push   $0x6
  jmp __alltraps
  101e69:	e9 9f ff ff ff       	jmp    101e0d <__alltraps>

00101e6e <vector7>:
.globl vector7
vector7:
  pushl $0
  101e6e:	6a 00                	push   $0x0
  pushl $7
  101e70:	6a 07                	push   $0x7
  jmp __alltraps
  101e72:	e9 96 ff ff ff       	jmp    101e0d <__alltraps>

00101e77 <vector8>:
.globl vector8
vector8:
  pushl $8
  101e77:	6a 08                	push   $0x8
  jmp __alltraps
  101e79:	e9 8f ff ff ff       	jmp    101e0d <__alltraps>

00101e7e <vector9>:
.globl vector9
vector9:
  pushl $0
  101e7e:	6a 00                	push   $0x0
  pushl $9
  101e80:	6a 09                	push   $0x9
  jmp __alltraps
  101e82:	e9 86 ff ff ff       	jmp    101e0d <__alltraps>

00101e87 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e87:	6a 0a                	push   $0xa
  jmp __alltraps
  101e89:	e9 7f ff ff ff       	jmp    101e0d <__alltraps>

00101e8e <vector11>:
.globl vector11
vector11:
  pushl $11
  101e8e:	6a 0b                	push   $0xb
  jmp __alltraps
  101e90:	e9 78 ff ff ff       	jmp    101e0d <__alltraps>

00101e95 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e95:	6a 0c                	push   $0xc
  jmp __alltraps
  101e97:	e9 71 ff ff ff       	jmp    101e0d <__alltraps>

00101e9c <vector13>:
.globl vector13
vector13:
  pushl $13
  101e9c:	6a 0d                	push   $0xd
  jmp __alltraps
  101e9e:	e9 6a ff ff ff       	jmp    101e0d <__alltraps>

00101ea3 <vector14>:
.globl vector14
vector14:
  pushl $14
  101ea3:	6a 0e                	push   $0xe
  jmp __alltraps
  101ea5:	e9 63 ff ff ff       	jmp    101e0d <__alltraps>

00101eaa <vector15>:
.globl vector15
vector15:
  pushl $0
  101eaa:	6a 00                	push   $0x0
  pushl $15
  101eac:	6a 0f                	push   $0xf
  jmp __alltraps
  101eae:	e9 5a ff ff ff       	jmp    101e0d <__alltraps>

00101eb3 <vector16>:
.globl vector16
vector16:
  pushl $0
  101eb3:	6a 00                	push   $0x0
  pushl $16
  101eb5:	6a 10                	push   $0x10
  jmp __alltraps
  101eb7:	e9 51 ff ff ff       	jmp    101e0d <__alltraps>

00101ebc <vector17>:
.globl vector17
vector17:
  pushl $17
  101ebc:	6a 11                	push   $0x11
  jmp __alltraps
  101ebe:	e9 4a ff ff ff       	jmp    101e0d <__alltraps>

00101ec3 <vector18>:
.globl vector18
vector18:
  pushl $0
  101ec3:	6a 00                	push   $0x0
  pushl $18
  101ec5:	6a 12                	push   $0x12
  jmp __alltraps
  101ec7:	e9 41 ff ff ff       	jmp    101e0d <__alltraps>

00101ecc <vector19>:
.globl vector19
vector19:
  pushl $0
  101ecc:	6a 00                	push   $0x0
  pushl $19
  101ece:	6a 13                	push   $0x13
  jmp __alltraps
  101ed0:	e9 38 ff ff ff       	jmp    101e0d <__alltraps>

00101ed5 <vector20>:
.globl vector20
vector20:
  pushl $0
  101ed5:	6a 00                	push   $0x0
  pushl $20
  101ed7:	6a 14                	push   $0x14
  jmp __alltraps
  101ed9:	e9 2f ff ff ff       	jmp    101e0d <__alltraps>

00101ede <vector21>:
.globl vector21
vector21:
  pushl $0
  101ede:	6a 00                	push   $0x0
  pushl $21
  101ee0:	6a 15                	push   $0x15
  jmp __alltraps
  101ee2:	e9 26 ff ff ff       	jmp    101e0d <__alltraps>

00101ee7 <vector22>:
.globl vector22
vector22:
  pushl $0
  101ee7:	6a 00                	push   $0x0
  pushl $22
  101ee9:	6a 16                	push   $0x16
  jmp __alltraps
  101eeb:	e9 1d ff ff ff       	jmp    101e0d <__alltraps>

00101ef0 <vector23>:
.globl vector23
vector23:
  pushl $0
  101ef0:	6a 00                	push   $0x0
  pushl $23
  101ef2:	6a 17                	push   $0x17
  jmp __alltraps
  101ef4:	e9 14 ff ff ff       	jmp    101e0d <__alltraps>

00101ef9 <vector24>:
.globl vector24
vector24:
  pushl $0
  101ef9:	6a 00                	push   $0x0
  pushl $24
  101efb:	6a 18                	push   $0x18
  jmp __alltraps
  101efd:	e9 0b ff ff ff       	jmp    101e0d <__alltraps>

00101f02 <vector25>:
.globl vector25
vector25:
  pushl $0
  101f02:	6a 00                	push   $0x0
  pushl $25
  101f04:	6a 19                	push   $0x19
  jmp __alltraps
  101f06:	e9 02 ff ff ff       	jmp    101e0d <__alltraps>

00101f0b <vector26>:
.globl vector26
vector26:
  pushl $0
  101f0b:	6a 00                	push   $0x0
  pushl $26
  101f0d:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f0f:	e9 f9 fe ff ff       	jmp    101e0d <__alltraps>

00101f14 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f14:	6a 00                	push   $0x0
  pushl $27
  101f16:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f18:	e9 f0 fe ff ff       	jmp    101e0d <__alltraps>

00101f1d <vector28>:
.globl vector28
vector28:
  pushl $0
  101f1d:	6a 00                	push   $0x0
  pushl $28
  101f1f:	6a 1c                	push   $0x1c
  jmp __alltraps
  101f21:	e9 e7 fe ff ff       	jmp    101e0d <__alltraps>

00101f26 <vector29>:
.globl vector29
vector29:
  pushl $0
  101f26:	6a 00                	push   $0x0
  pushl $29
  101f28:	6a 1d                	push   $0x1d
  jmp __alltraps
  101f2a:	e9 de fe ff ff       	jmp    101e0d <__alltraps>

00101f2f <vector30>:
.globl vector30
vector30:
  pushl $0
  101f2f:	6a 00                	push   $0x0
  pushl $30
  101f31:	6a 1e                	push   $0x1e
  jmp __alltraps
  101f33:	e9 d5 fe ff ff       	jmp    101e0d <__alltraps>

00101f38 <vector31>:
.globl vector31
vector31:
  pushl $0
  101f38:	6a 00                	push   $0x0
  pushl $31
  101f3a:	6a 1f                	push   $0x1f
  jmp __alltraps
  101f3c:	e9 cc fe ff ff       	jmp    101e0d <__alltraps>

00101f41 <vector32>:
.globl vector32
vector32:
  pushl $0
  101f41:	6a 00                	push   $0x0
  pushl $32
  101f43:	6a 20                	push   $0x20
  jmp __alltraps
  101f45:	e9 c3 fe ff ff       	jmp    101e0d <__alltraps>

00101f4a <vector33>:
.globl vector33
vector33:
  pushl $0
  101f4a:	6a 00                	push   $0x0
  pushl $33
  101f4c:	6a 21                	push   $0x21
  jmp __alltraps
  101f4e:	e9 ba fe ff ff       	jmp    101e0d <__alltraps>

00101f53 <vector34>:
.globl vector34
vector34:
  pushl $0
  101f53:	6a 00                	push   $0x0
  pushl $34
  101f55:	6a 22                	push   $0x22
  jmp __alltraps
  101f57:	e9 b1 fe ff ff       	jmp    101e0d <__alltraps>

00101f5c <vector35>:
.globl vector35
vector35:
  pushl $0
  101f5c:	6a 00                	push   $0x0
  pushl $35
  101f5e:	6a 23                	push   $0x23
  jmp __alltraps
  101f60:	e9 a8 fe ff ff       	jmp    101e0d <__alltraps>

00101f65 <vector36>:
.globl vector36
vector36:
  pushl $0
  101f65:	6a 00                	push   $0x0
  pushl $36
  101f67:	6a 24                	push   $0x24
  jmp __alltraps
  101f69:	e9 9f fe ff ff       	jmp    101e0d <__alltraps>

00101f6e <vector37>:
.globl vector37
vector37:
  pushl $0
  101f6e:	6a 00                	push   $0x0
  pushl $37
  101f70:	6a 25                	push   $0x25
  jmp __alltraps
  101f72:	e9 96 fe ff ff       	jmp    101e0d <__alltraps>

00101f77 <vector38>:
.globl vector38
vector38:
  pushl $0
  101f77:	6a 00                	push   $0x0
  pushl $38
  101f79:	6a 26                	push   $0x26
  jmp __alltraps
  101f7b:	e9 8d fe ff ff       	jmp    101e0d <__alltraps>

00101f80 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f80:	6a 00                	push   $0x0
  pushl $39
  101f82:	6a 27                	push   $0x27
  jmp __alltraps
  101f84:	e9 84 fe ff ff       	jmp    101e0d <__alltraps>

00101f89 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f89:	6a 00                	push   $0x0
  pushl $40
  101f8b:	6a 28                	push   $0x28
  jmp __alltraps
  101f8d:	e9 7b fe ff ff       	jmp    101e0d <__alltraps>

00101f92 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f92:	6a 00                	push   $0x0
  pushl $41
  101f94:	6a 29                	push   $0x29
  jmp __alltraps
  101f96:	e9 72 fe ff ff       	jmp    101e0d <__alltraps>

00101f9b <vector42>:
.globl vector42
vector42:
  pushl $0
  101f9b:	6a 00                	push   $0x0
  pushl $42
  101f9d:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f9f:	e9 69 fe ff ff       	jmp    101e0d <__alltraps>

00101fa4 <vector43>:
.globl vector43
vector43:
  pushl $0
  101fa4:	6a 00                	push   $0x0
  pushl $43
  101fa6:	6a 2b                	push   $0x2b
  jmp __alltraps
  101fa8:	e9 60 fe ff ff       	jmp    101e0d <__alltraps>

00101fad <vector44>:
.globl vector44
vector44:
  pushl $0
  101fad:	6a 00                	push   $0x0
  pushl $44
  101faf:	6a 2c                	push   $0x2c
  jmp __alltraps
  101fb1:	e9 57 fe ff ff       	jmp    101e0d <__alltraps>

00101fb6 <vector45>:
.globl vector45
vector45:
  pushl $0
  101fb6:	6a 00                	push   $0x0
  pushl $45
  101fb8:	6a 2d                	push   $0x2d
  jmp __alltraps
  101fba:	e9 4e fe ff ff       	jmp    101e0d <__alltraps>

00101fbf <vector46>:
.globl vector46
vector46:
  pushl $0
  101fbf:	6a 00                	push   $0x0
  pushl $46
  101fc1:	6a 2e                	push   $0x2e
  jmp __alltraps
  101fc3:	e9 45 fe ff ff       	jmp    101e0d <__alltraps>

00101fc8 <vector47>:
.globl vector47
vector47:
  pushl $0
  101fc8:	6a 00                	push   $0x0
  pushl $47
  101fca:	6a 2f                	push   $0x2f
  jmp __alltraps
  101fcc:	e9 3c fe ff ff       	jmp    101e0d <__alltraps>

00101fd1 <vector48>:
.globl vector48
vector48:
  pushl $0
  101fd1:	6a 00                	push   $0x0
  pushl $48
  101fd3:	6a 30                	push   $0x30
  jmp __alltraps
  101fd5:	e9 33 fe ff ff       	jmp    101e0d <__alltraps>

00101fda <vector49>:
.globl vector49
vector49:
  pushl $0
  101fda:	6a 00                	push   $0x0
  pushl $49
  101fdc:	6a 31                	push   $0x31
  jmp __alltraps
  101fde:	e9 2a fe ff ff       	jmp    101e0d <__alltraps>

00101fe3 <vector50>:
.globl vector50
vector50:
  pushl $0
  101fe3:	6a 00                	push   $0x0
  pushl $50
  101fe5:	6a 32                	push   $0x32
  jmp __alltraps
  101fe7:	e9 21 fe ff ff       	jmp    101e0d <__alltraps>

00101fec <vector51>:
.globl vector51
vector51:
  pushl $0
  101fec:	6a 00                	push   $0x0
  pushl $51
  101fee:	6a 33                	push   $0x33
  jmp __alltraps
  101ff0:	e9 18 fe ff ff       	jmp    101e0d <__alltraps>

00101ff5 <vector52>:
.globl vector52
vector52:
  pushl $0
  101ff5:	6a 00                	push   $0x0
  pushl $52
  101ff7:	6a 34                	push   $0x34
  jmp __alltraps
  101ff9:	e9 0f fe ff ff       	jmp    101e0d <__alltraps>

00101ffe <vector53>:
.globl vector53
vector53:
  pushl $0
  101ffe:	6a 00                	push   $0x0
  pushl $53
  102000:	6a 35                	push   $0x35
  jmp __alltraps
  102002:	e9 06 fe ff ff       	jmp    101e0d <__alltraps>

00102007 <vector54>:
.globl vector54
vector54:
  pushl $0
  102007:	6a 00                	push   $0x0
  pushl $54
  102009:	6a 36                	push   $0x36
  jmp __alltraps
  10200b:	e9 fd fd ff ff       	jmp    101e0d <__alltraps>

00102010 <vector55>:
.globl vector55
vector55:
  pushl $0
  102010:	6a 00                	push   $0x0
  pushl $55
  102012:	6a 37                	push   $0x37
  jmp __alltraps
  102014:	e9 f4 fd ff ff       	jmp    101e0d <__alltraps>

00102019 <vector56>:
.globl vector56
vector56:
  pushl $0
  102019:	6a 00                	push   $0x0
  pushl $56
  10201b:	6a 38                	push   $0x38
  jmp __alltraps
  10201d:	e9 eb fd ff ff       	jmp    101e0d <__alltraps>

00102022 <vector57>:
.globl vector57
vector57:
  pushl $0
  102022:	6a 00                	push   $0x0
  pushl $57
  102024:	6a 39                	push   $0x39
  jmp __alltraps
  102026:	e9 e2 fd ff ff       	jmp    101e0d <__alltraps>

0010202b <vector58>:
.globl vector58
vector58:
  pushl $0
  10202b:	6a 00                	push   $0x0
  pushl $58
  10202d:	6a 3a                	push   $0x3a
  jmp __alltraps
  10202f:	e9 d9 fd ff ff       	jmp    101e0d <__alltraps>

00102034 <vector59>:
.globl vector59
vector59:
  pushl $0
  102034:	6a 00                	push   $0x0
  pushl $59
  102036:	6a 3b                	push   $0x3b
  jmp __alltraps
  102038:	e9 d0 fd ff ff       	jmp    101e0d <__alltraps>

0010203d <vector60>:
.globl vector60
vector60:
  pushl $0
  10203d:	6a 00                	push   $0x0
  pushl $60
  10203f:	6a 3c                	push   $0x3c
  jmp __alltraps
  102041:	e9 c7 fd ff ff       	jmp    101e0d <__alltraps>

00102046 <vector61>:
.globl vector61
vector61:
  pushl $0
  102046:	6a 00                	push   $0x0
  pushl $61
  102048:	6a 3d                	push   $0x3d
  jmp __alltraps
  10204a:	e9 be fd ff ff       	jmp    101e0d <__alltraps>

0010204f <vector62>:
.globl vector62
vector62:
  pushl $0
  10204f:	6a 00                	push   $0x0
  pushl $62
  102051:	6a 3e                	push   $0x3e
  jmp __alltraps
  102053:	e9 b5 fd ff ff       	jmp    101e0d <__alltraps>

00102058 <vector63>:
.globl vector63
vector63:
  pushl $0
  102058:	6a 00                	push   $0x0
  pushl $63
  10205a:	6a 3f                	push   $0x3f
  jmp __alltraps
  10205c:	e9 ac fd ff ff       	jmp    101e0d <__alltraps>

00102061 <vector64>:
.globl vector64
vector64:
  pushl $0
  102061:	6a 00                	push   $0x0
  pushl $64
  102063:	6a 40                	push   $0x40
  jmp __alltraps
  102065:	e9 a3 fd ff ff       	jmp    101e0d <__alltraps>

0010206a <vector65>:
.globl vector65
vector65:
  pushl $0
  10206a:	6a 00                	push   $0x0
  pushl $65
  10206c:	6a 41                	push   $0x41
  jmp __alltraps
  10206e:	e9 9a fd ff ff       	jmp    101e0d <__alltraps>

00102073 <vector66>:
.globl vector66
vector66:
  pushl $0
  102073:	6a 00                	push   $0x0
  pushl $66
  102075:	6a 42                	push   $0x42
  jmp __alltraps
  102077:	e9 91 fd ff ff       	jmp    101e0d <__alltraps>

0010207c <vector67>:
.globl vector67
vector67:
  pushl $0
  10207c:	6a 00                	push   $0x0
  pushl $67
  10207e:	6a 43                	push   $0x43
  jmp __alltraps
  102080:	e9 88 fd ff ff       	jmp    101e0d <__alltraps>

00102085 <vector68>:
.globl vector68
vector68:
  pushl $0
  102085:	6a 00                	push   $0x0
  pushl $68
  102087:	6a 44                	push   $0x44
  jmp __alltraps
  102089:	e9 7f fd ff ff       	jmp    101e0d <__alltraps>

0010208e <vector69>:
.globl vector69
vector69:
  pushl $0
  10208e:	6a 00                	push   $0x0
  pushl $69
  102090:	6a 45                	push   $0x45
  jmp __alltraps
  102092:	e9 76 fd ff ff       	jmp    101e0d <__alltraps>

00102097 <vector70>:
.globl vector70
vector70:
  pushl $0
  102097:	6a 00                	push   $0x0
  pushl $70
  102099:	6a 46                	push   $0x46
  jmp __alltraps
  10209b:	e9 6d fd ff ff       	jmp    101e0d <__alltraps>

001020a0 <vector71>:
.globl vector71
vector71:
  pushl $0
  1020a0:	6a 00                	push   $0x0
  pushl $71
  1020a2:	6a 47                	push   $0x47
  jmp __alltraps
  1020a4:	e9 64 fd ff ff       	jmp    101e0d <__alltraps>

001020a9 <vector72>:
.globl vector72
vector72:
  pushl $0
  1020a9:	6a 00                	push   $0x0
  pushl $72
  1020ab:	6a 48                	push   $0x48
  jmp __alltraps
  1020ad:	e9 5b fd ff ff       	jmp    101e0d <__alltraps>

001020b2 <vector73>:
.globl vector73
vector73:
  pushl $0
  1020b2:	6a 00                	push   $0x0
  pushl $73
  1020b4:	6a 49                	push   $0x49
  jmp __alltraps
  1020b6:	e9 52 fd ff ff       	jmp    101e0d <__alltraps>

001020bb <vector74>:
.globl vector74
vector74:
  pushl $0
  1020bb:	6a 00                	push   $0x0
  pushl $74
  1020bd:	6a 4a                	push   $0x4a
  jmp __alltraps
  1020bf:	e9 49 fd ff ff       	jmp    101e0d <__alltraps>

001020c4 <vector75>:
.globl vector75
vector75:
  pushl $0
  1020c4:	6a 00                	push   $0x0
  pushl $75
  1020c6:	6a 4b                	push   $0x4b
  jmp __alltraps
  1020c8:	e9 40 fd ff ff       	jmp    101e0d <__alltraps>

001020cd <vector76>:
.globl vector76
vector76:
  pushl $0
  1020cd:	6a 00                	push   $0x0
  pushl $76
  1020cf:	6a 4c                	push   $0x4c
  jmp __alltraps
  1020d1:	e9 37 fd ff ff       	jmp    101e0d <__alltraps>

001020d6 <vector77>:
.globl vector77
vector77:
  pushl $0
  1020d6:	6a 00                	push   $0x0
  pushl $77
  1020d8:	6a 4d                	push   $0x4d
  jmp __alltraps
  1020da:	e9 2e fd ff ff       	jmp    101e0d <__alltraps>

001020df <vector78>:
.globl vector78
vector78:
  pushl $0
  1020df:	6a 00                	push   $0x0
  pushl $78
  1020e1:	6a 4e                	push   $0x4e
  jmp __alltraps
  1020e3:	e9 25 fd ff ff       	jmp    101e0d <__alltraps>

001020e8 <vector79>:
.globl vector79
vector79:
  pushl $0
  1020e8:	6a 00                	push   $0x0
  pushl $79
  1020ea:	6a 4f                	push   $0x4f
  jmp __alltraps
  1020ec:	e9 1c fd ff ff       	jmp    101e0d <__alltraps>

001020f1 <vector80>:
.globl vector80
vector80:
  pushl $0
  1020f1:	6a 00                	push   $0x0
  pushl $80
  1020f3:	6a 50                	push   $0x50
  jmp __alltraps
  1020f5:	e9 13 fd ff ff       	jmp    101e0d <__alltraps>

001020fa <vector81>:
.globl vector81
vector81:
  pushl $0
  1020fa:	6a 00                	push   $0x0
  pushl $81
  1020fc:	6a 51                	push   $0x51
  jmp __alltraps
  1020fe:	e9 0a fd ff ff       	jmp    101e0d <__alltraps>

00102103 <vector82>:
.globl vector82
vector82:
  pushl $0
  102103:	6a 00                	push   $0x0
  pushl $82
  102105:	6a 52                	push   $0x52
  jmp __alltraps
  102107:	e9 01 fd ff ff       	jmp    101e0d <__alltraps>

0010210c <vector83>:
.globl vector83
vector83:
  pushl $0
  10210c:	6a 00                	push   $0x0
  pushl $83
  10210e:	6a 53                	push   $0x53
  jmp __alltraps
  102110:	e9 f8 fc ff ff       	jmp    101e0d <__alltraps>

00102115 <vector84>:
.globl vector84
vector84:
  pushl $0
  102115:	6a 00                	push   $0x0
  pushl $84
  102117:	6a 54                	push   $0x54
  jmp __alltraps
  102119:	e9 ef fc ff ff       	jmp    101e0d <__alltraps>

0010211e <vector85>:
.globl vector85
vector85:
  pushl $0
  10211e:	6a 00                	push   $0x0
  pushl $85
  102120:	6a 55                	push   $0x55
  jmp __alltraps
  102122:	e9 e6 fc ff ff       	jmp    101e0d <__alltraps>

00102127 <vector86>:
.globl vector86
vector86:
  pushl $0
  102127:	6a 00                	push   $0x0
  pushl $86
  102129:	6a 56                	push   $0x56
  jmp __alltraps
  10212b:	e9 dd fc ff ff       	jmp    101e0d <__alltraps>

00102130 <vector87>:
.globl vector87
vector87:
  pushl $0
  102130:	6a 00                	push   $0x0
  pushl $87
  102132:	6a 57                	push   $0x57
  jmp __alltraps
  102134:	e9 d4 fc ff ff       	jmp    101e0d <__alltraps>

00102139 <vector88>:
.globl vector88
vector88:
  pushl $0
  102139:	6a 00                	push   $0x0
  pushl $88
  10213b:	6a 58                	push   $0x58
  jmp __alltraps
  10213d:	e9 cb fc ff ff       	jmp    101e0d <__alltraps>

00102142 <vector89>:
.globl vector89
vector89:
  pushl $0
  102142:	6a 00                	push   $0x0
  pushl $89
  102144:	6a 59                	push   $0x59
  jmp __alltraps
  102146:	e9 c2 fc ff ff       	jmp    101e0d <__alltraps>

0010214b <vector90>:
.globl vector90
vector90:
  pushl $0
  10214b:	6a 00                	push   $0x0
  pushl $90
  10214d:	6a 5a                	push   $0x5a
  jmp __alltraps
  10214f:	e9 b9 fc ff ff       	jmp    101e0d <__alltraps>

00102154 <vector91>:
.globl vector91
vector91:
  pushl $0
  102154:	6a 00                	push   $0x0
  pushl $91
  102156:	6a 5b                	push   $0x5b
  jmp __alltraps
  102158:	e9 b0 fc ff ff       	jmp    101e0d <__alltraps>

0010215d <vector92>:
.globl vector92
vector92:
  pushl $0
  10215d:	6a 00                	push   $0x0
  pushl $92
  10215f:	6a 5c                	push   $0x5c
  jmp __alltraps
  102161:	e9 a7 fc ff ff       	jmp    101e0d <__alltraps>

00102166 <vector93>:
.globl vector93
vector93:
  pushl $0
  102166:	6a 00                	push   $0x0
  pushl $93
  102168:	6a 5d                	push   $0x5d
  jmp __alltraps
  10216a:	e9 9e fc ff ff       	jmp    101e0d <__alltraps>

0010216f <vector94>:
.globl vector94
vector94:
  pushl $0
  10216f:	6a 00                	push   $0x0
  pushl $94
  102171:	6a 5e                	push   $0x5e
  jmp __alltraps
  102173:	e9 95 fc ff ff       	jmp    101e0d <__alltraps>

00102178 <vector95>:
.globl vector95
vector95:
  pushl $0
  102178:	6a 00                	push   $0x0
  pushl $95
  10217a:	6a 5f                	push   $0x5f
  jmp __alltraps
  10217c:	e9 8c fc ff ff       	jmp    101e0d <__alltraps>

00102181 <vector96>:
.globl vector96
vector96:
  pushl $0
  102181:	6a 00                	push   $0x0
  pushl $96
  102183:	6a 60                	push   $0x60
  jmp __alltraps
  102185:	e9 83 fc ff ff       	jmp    101e0d <__alltraps>

0010218a <vector97>:
.globl vector97
vector97:
  pushl $0
  10218a:	6a 00                	push   $0x0
  pushl $97
  10218c:	6a 61                	push   $0x61
  jmp __alltraps
  10218e:	e9 7a fc ff ff       	jmp    101e0d <__alltraps>

00102193 <vector98>:
.globl vector98
vector98:
  pushl $0
  102193:	6a 00                	push   $0x0
  pushl $98
  102195:	6a 62                	push   $0x62
  jmp __alltraps
  102197:	e9 71 fc ff ff       	jmp    101e0d <__alltraps>

0010219c <vector99>:
.globl vector99
vector99:
  pushl $0
  10219c:	6a 00                	push   $0x0
  pushl $99
  10219e:	6a 63                	push   $0x63
  jmp __alltraps
  1021a0:	e9 68 fc ff ff       	jmp    101e0d <__alltraps>

001021a5 <vector100>:
.globl vector100
vector100:
  pushl $0
  1021a5:	6a 00                	push   $0x0
  pushl $100
  1021a7:	6a 64                	push   $0x64
  jmp __alltraps
  1021a9:	e9 5f fc ff ff       	jmp    101e0d <__alltraps>

001021ae <vector101>:
.globl vector101
vector101:
  pushl $0
  1021ae:	6a 00                	push   $0x0
  pushl $101
  1021b0:	6a 65                	push   $0x65
  jmp __alltraps
  1021b2:	e9 56 fc ff ff       	jmp    101e0d <__alltraps>

001021b7 <vector102>:
.globl vector102
vector102:
  pushl $0
  1021b7:	6a 00                	push   $0x0
  pushl $102
  1021b9:	6a 66                	push   $0x66
  jmp __alltraps
  1021bb:	e9 4d fc ff ff       	jmp    101e0d <__alltraps>

001021c0 <vector103>:
.globl vector103
vector103:
  pushl $0
  1021c0:	6a 00                	push   $0x0
  pushl $103
  1021c2:	6a 67                	push   $0x67
  jmp __alltraps
  1021c4:	e9 44 fc ff ff       	jmp    101e0d <__alltraps>

001021c9 <vector104>:
.globl vector104
vector104:
  pushl $0
  1021c9:	6a 00                	push   $0x0
  pushl $104
  1021cb:	6a 68                	push   $0x68
  jmp __alltraps
  1021cd:	e9 3b fc ff ff       	jmp    101e0d <__alltraps>

001021d2 <vector105>:
.globl vector105
vector105:
  pushl $0
  1021d2:	6a 00                	push   $0x0
  pushl $105
  1021d4:	6a 69                	push   $0x69
  jmp __alltraps
  1021d6:	e9 32 fc ff ff       	jmp    101e0d <__alltraps>

001021db <vector106>:
.globl vector106
vector106:
  pushl $0
  1021db:	6a 00                	push   $0x0
  pushl $106
  1021dd:	6a 6a                	push   $0x6a
  jmp __alltraps
  1021df:	e9 29 fc ff ff       	jmp    101e0d <__alltraps>

001021e4 <vector107>:
.globl vector107
vector107:
  pushl $0
  1021e4:	6a 00                	push   $0x0
  pushl $107
  1021e6:	6a 6b                	push   $0x6b
  jmp __alltraps
  1021e8:	e9 20 fc ff ff       	jmp    101e0d <__alltraps>

001021ed <vector108>:
.globl vector108
vector108:
  pushl $0
  1021ed:	6a 00                	push   $0x0
  pushl $108
  1021ef:	6a 6c                	push   $0x6c
  jmp __alltraps
  1021f1:	e9 17 fc ff ff       	jmp    101e0d <__alltraps>

001021f6 <vector109>:
.globl vector109
vector109:
  pushl $0
  1021f6:	6a 00                	push   $0x0
  pushl $109
  1021f8:	6a 6d                	push   $0x6d
  jmp __alltraps
  1021fa:	e9 0e fc ff ff       	jmp    101e0d <__alltraps>

001021ff <vector110>:
.globl vector110
vector110:
  pushl $0
  1021ff:	6a 00                	push   $0x0
  pushl $110
  102201:	6a 6e                	push   $0x6e
  jmp __alltraps
  102203:	e9 05 fc ff ff       	jmp    101e0d <__alltraps>

00102208 <vector111>:
.globl vector111
vector111:
  pushl $0
  102208:	6a 00                	push   $0x0
  pushl $111
  10220a:	6a 6f                	push   $0x6f
  jmp __alltraps
  10220c:	e9 fc fb ff ff       	jmp    101e0d <__alltraps>

00102211 <vector112>:
.globl vector112
vector112:
  pushl $0
  102211:	6a 00                	push   $0x0
  pushl $112
  102213:	6a 70                	push   $0x70
  jmp __alltraps
  102215:	e9 f3 fb ff ff       	jmp    101e0d <__alltraps>

0010221a <vector113>:
.globl vector113
vector113:
  pushl $0
  10221a:	6a 00                	push   $0x0
  pushl $113
  10221c:	6a 71                	push   $0x71
  jmp __alltraps
  10221e:	e9 ea fb ff ff       	jmp    101e0d <__alltraps>

00102223 <vector114>:
.globl vector114
vector114:
  pushl $0
  102223:	6a 00                	push   $0x0
  pushl $114
  102225:	6a 72                	push   $0x72
  jmp __alltraps
  102227:	e9 e1 fb ff ff       	jmp    101e0d <__alltraps>

0010222c <vector115>:
.globl vector115
vector115:
  pushl $0
  10222c:	6a 00                	push   $0x0
  pushl $115
  10222e:	6a 73                	push   $0x73
  jmp __alltraps
  102230:	e9 d8 fb ff ff       	jmp    101e0d <__alltraps>

00102235 <vector116>:
.globl vector116
vector116:
  pushl $0
  102235:	6a 00                	push   $0x0
  pushl $116
  102237:	6a 74                	push   $0x74
  jmp __alltraps
  102239:	e9 cf fb ff ff       	jmp    101e0d <__alltraps>

0010223e <vector117>:
.globl vector117
vector117:
  pushl $0
  10223e:	6a 00                	push   $0x0
  pushl $117
  102240:	6a 75                	push   $0x75
  jmp __alltraps
  102242:	e9 c6 fb ff ff       	jmp    101e0d <__alltraps>

00102247 <vector118>:
.globl vector118
vector118:
  pushl $0
  102247:	6a 00                	push   $0x0
  pushl $118
  102249:	6a 76                	push   $0x76
  jmp __alltraps
  10224b:	e9 bd fb ff ff       	jmp    101e0d <__alltraps>

00102250 <vector119>:
.globl vector119
vector119:
  pushl $0
  102250:	6a 00                	push   $0x0
  pushl $119
  102252:	6a 77                	push   $0x77
  jmp __alltraps
  102254:	e9 b4 fb ff ff       	jmp    101e0d <__alltraps>

00102259 <vector120>:
.globl vector120
vector120:
  pushl $0
  102259:	6a 00                	push   $0x0
  pushl $120
  10225b:	6a 78                	push   $0x78
  jmp __alltraps
  10225d:	e9 ab fb ff ff       	jmp    101e0d <__alltraps>

00102262 <vector121>:
.globl vector121
vector121:
  pushl $0
  102262:	6a 00                	push   $0x0
  pushl $121
  102264:	6a 79                	push   $0x79
  jmp __alltraps
  102266:	e9 a2 fb ff ff       	jmp    101e0d <__alltraps>

0010226b <vector122>:
.globl vector122
vector122:
  pushl $0
  10226b:	6a 00                	push   $0x0
  pushl $122
  10226d:	6a 7a                	push   $0x7a
  jmp __alltraps
  10226f:	e9 99 fb ff ff       	jmp    101e0d <__alltraps>

00102274 <vector123>:
.globl vector123
vector123:
  pushl $0
  102274:	6a 00                	push   $0x0
  pushl $123
  102276:	6a 7b                	push   $0x7b
  jmp __alltraps
  102278:	e9 90 fb ff ff       	jmp    101e0d <__alltraps>

0010227d <vector124>:
.globl vector124
vector124:
  pushl $0
  10227d:	6a 00                	push   $0x0
  pushl $124
  10227f:	6a 7c                	push   $0x7c
  jmp __alltraps
  102281:	e9 87 fb ff ff       	jmp    101e0d <__alltraps>

00102286 <vector125>:
.globl vector125
vector125:
  pushl $0
  102286:	6a 00                	push   $0x0
  pushl $125
  102288:	6a 7d                	push   $0x7d
  jmp __alltraps
  10228a:	e9 7e fb ff ff       	jmp    101e0d <__alltraps>

0010228f <vector126>:
.globl vector126
vector126:
  pushl $0
  10228f:	6a 00                	push   $0x0
  pushl $126
  102291:	6a 7e                	push   $0x7e
  jmp __alltraps
  102293:	e9 75 fb ff ff       	jmp    101e0d <__alltraps>

00102298 <vector127>:
.globl vector127
vector127:
  pushl $0
  102298:	6a 00                	push   $0x0
  pushl $127
  10229a:	6a 7f                	push   $0x7f
  jmp __alltraps
  10229c:	e9 6c fb ff ff       	jmp    101e0d <__alltraps>

001022a1 <vector128>:
.globl vector128
vector128:
  pushl $0
  1022a1:	6a 00                	push   $0x0
  pushl $128
  1022a3:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1022a8:	e9 60 fb ff ff       	jmp    101e0d <__alltraps>

001022ad <vector129>:
.globl vector129
vector129:
  pushl $0
  1022ad:	6a 00                	push   $0x0
  pushl $129
  1022af:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1022b4:	e9 54 fb ff ff       	jmp    101e0d <__alltraps>

001022b9 <vector130>:
.globl vector130
vector130:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $130
  1022bb:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  1022c0:	e9 48 fb ff ff       	jmp    101e0d <__alltraps>

001022c5 <vector131>:
.globl vector131
vector131:
  pushl $0
  1022c5:	6a 00                	push   $0x0
  pushl $131
  1022c7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1022cc:	e9 3c fb ff ff       	jmp    101e0d <__alltraps>

001022d1 <vector132>:
.globl vector132
vector132:
  pushl $0
  1022d1:	6a 00                	push   $0x0
  pushl $132
  1022d3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1022d8:	e9 30 fb ff ff       	jmp    101e0d <__alltraps>

001022dd <vector133>:
.globl vector133
vector133:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $133
  1022df:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1022e4:	e9 24 fb ff ff       	jmp    101e0d <__alltraps>

001022e9 <vector134>:
.globl vector134
vector134:
  pushl $0
  1022e9:	6a 00                	push   $0x0
  pushl $134
  1022eb:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1022f0:	e9 18 fb ff ff       	jmp    101e0d <__alltraps>

001022f5 <vector135>:
.globl vector135
vector135:
  pushl $0
  1022f5:	6a 00                	push   $0x0
  pushl $135
  1022f7:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1022fc:	e9 0c fb ff ff       	jmp    101e0d <__alltraps>

00102301 <vector136>:
.globl vector136
vector136:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $136
  102303:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102308:	e9 00 fb ff ff       	jmp    101e0d <__alltraps>

0010230d <vector137>:
.globl vector137
vector137:
  pushl $0
  10230d:	6a 00                	push   $0x0
  pushl $137
  10230f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102314:	e9 f4 fa ff ff       	jmp    101e0d <__alltraps>

00102319 <vector138>:
.globl vector138
vector138:
  pushl $0
  102319:	6a 00                	push   $0x0
  pushl $138
  10231b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102320:	e9 e8 fa ff ff       	jmp    101e0d <__alltraps>

00102325 <vector139>:
.globl vector139
vector139:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $139
  102327:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10232c:	e9 dc fa ff ff       	jmp    101e0d <__alltraps>

00102331 <vector140>:
.globl vector140
vector140:
  pushl $0
  102331:	6a 00                	push   $0x0
  pushl $140
  102333:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102338:	e9 d0 fa ff ff       	jmp    101e0d <__alltraps>

0010233d <vector141>:
.globl vector141
vector141:
  pushl $0
  10233d:	6a 00                	push   $0x0
  pushl $141
  10233f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102344:	e9 c4 fa ff ff       	jmp    101e0d <__alltraps>

00102349 <vector142>:
.globl vector142
vector142:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $142
  10234b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102350:	e9 b8 fa ff ff       	jmp    101e0d <__alltraps>

00102355 <vector143>:
.globl vector143
vector143:
  pushl $0
  102355:	6a 00                	push   $0x0
  pushl $143
  102357:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10235c:	e9 ac fa ff ff       	jmp    101e0d <__alltraps>

00102361 <vector144>:
.globl vector144
vector144:
  pushl $0
  102361:	6a 00                	push   $0x0
  pushl $144
  102363:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102368:	e9 a0 fa ff ff       	jmp    101e0d <__alltraps>

0010236d <vector145>:
.globl vector145
vector145:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $145
  10236f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102374:	e9 94 fa ff ff       	jmp    101e0d <__alltraps>

00102379 <vector146>:
.globl vector146
vector146:
  pushl $0
  102379:	6a 00                	push   $0x0
  pushl $146
  10237b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102380:	e9 88 fa ff ff       	jmp    101e0d <__alltraps>

00102385 <vector147>:
.globl vector147
vector147:
  pushl $0
  102385:	6a 00                	push   $0x0
  pushl $147
  102387:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10238c:	e9 7c fa ff ff       	jmp    101e0d <__alltraps>

00102391 <vector148>:
.globl vector148
vector148:
  pushl $0
  102391:	6a 00                	push   $0x0
  pushl $148
  102393:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102398:	e9 70 fa ff ff       	jmp    101e0d <__alltraps>

0010239d <vector149>:
.globl vector149
vector149:
  pushl $0
  10239d:	6a 00                	push   $0x0
  pushl $149
  10239f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1023a4:	e9 64 fa ff ff       	jmp    101e0d <__alltraps>

001023a9 <vector150>:
.globl vector150
vector150:
  pushl $0
  1023a9:	6a 00                	push   $0x0
  pushl $150
  1023ab:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1023b0:	e9 58 fa ff ff       	jmp    101e0d <__alltraps>

001023b5 <vector151>:
.globl vector151
vector151:
  pushl $0
  1023b5:	6a 00                	push   $0x0
  pushl $151
  1023b7:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1023bc:	e9 4c fa ff ff       	jmp    101e0d <__alltraps>

001023c1 <vector152>:
.globl vector152
vector152:
  pushl $0
  1023c1:	6a 00                	push   $0x0
  pushl $152
  1023c3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1023c8:	e9 40 fa ff ff       	jmp    101e0d <__alltraps>

001023cd <vector153>:
.globl vector153
vector153:
  pushl $0
  1023cd:	6a 00                	push   $0x0
  pushl $153
  1023cf:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1023d4:	e9 34 fa ff ff       	jmp    101e0d <__alltraps>

001023d9 <vector154>:
.globl vector154
vector154:
  pushl $0
  1023d9:	6a 00                	push   $0x0
  pushl $154
  1023db:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1023e0:	e9 28 fa ff ff       	jmp    101e0d <__alltraps>

001023e5 <vector155>:
.globl vector155
vector155:
  pushl $0
  1023e5:	6a 00                	push   $0x0
  pushl $155
  1023e7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1023ec:	e9 1c fa ff ff       	jmp    101e0d <__alltraps>

001023f1 <vector156>:
.globl vector156
vector156:
  pushl $0
  1023f1:	6a 00                	push   $0x0
  pushl $156
  1023f3:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1023f8:	e9 10 fa ff ff       	jmp    101e0d <__alltraps>

001023fd <vector157>:
.globl vector157
vector157:
  pushl $0
  1023fd:	6a 00                	push   $0x0
  pushl $157
  1023ff:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102404:	e9 04 fa ff ff       	jmp    101e0d <__alltraps>

00102409 <vector158>:
.globl vector158
vector158:
  pushl $0
  102409:	6a 00                	push   $0x0
  pushl $158
  10240b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102410:	e9 f8 f9 ff ff       	jmp    101e0d <__alltraps>

00102415 <vector159>:
.globl vector159
vector159:
  pushl $0
  102415:	6a 00                	push   $0x0
  pushl $159
  102417:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10241c:	e9 ec f9 ff ff       	jmp    101e0d <__alltraps>

00102421 <vector160>:
.globl vector160
vector160:
  pushl $0
  102421:	6a 00                	push   $0x0
  pushl $160
  102423:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102428:	e9 e0 f9 ff ff       	jmp    101e0d <__alltraps>

0010242d <vector161>:
.globl vector161
vector161:
  pushl $0
  10242d:	6a 00                	push   $0x0
  pushl $161
  10242f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102434:	e9 d4 f9 ff ff       	jmp    101e0d <__alltraps>

00102439 <vector162>:
.globl vector162
vector162:
  pushl $0
  102439:	6a 00                	push   $0x0
  pushl $162
  10243b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102440:	e9 c8 f9 ff ff       	jmp    101e0d <__alltraps>

00102445 <vector163>:
.globl vector163
vector163:
  pushl $0
  102445:	6a 00                	push   $0x0
  pushl $163
  102447:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10244c:	e9 bc f9 ff ff       	jmp    101e0d <__alltraps>

00102451 <vector164>:
.globl vector164
vector164:
  pushl $0
  102451:	6a 00                	push   $0x0
  pushl $164
  102453:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102458:	e9 b0 f9 ff ff       	jmp    101e0d <__alltraps>

0010245d <vector165>:
.globl vector165
vector165:
  pushl $0
  10245d:	6a 00                	push   $0x0
  pushl $165
  10245f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102464:	e9 a4 f9 ff ff       	jmp    101e0d <__alltraps>

00102469 <vector166>:
.globl vector166
vector166:
  pushl $0
  102469:	6a 00                	push   $0x0
  pushl $166
  10246b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102470:	e9 98 f9 ff ff       	jmp    101e0d <__alltraps>

00102475 <vector167>:
.globl vector167
vector167:
  pushl $0
  102475:	6a 00                	push   $0x0
  pushl $167
  102477:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10247c:	e9 8c f9 ff ff       	jmp    101e0d <__alltraps>

00102481 <vector168>:
.globl vector168
vector168:
  pushl $0
  102481:	6a 00                	push   $0x0
  pushl $168
  102483:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102488:	e9 80 f9 ff ff       	jmp    101e0d <__alltraps>

0010248d <vector169>:
.globl vector169
vector169:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $169
  10248f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102494:	e9 74 f9 ff ff       	jmp    101e0d <__alltraps>

00102499 <vector170>:
.globl vector170
vector170:
  pushl $0
  102499:	6a 00                	push   $0x0
  pushl $170
  10249b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1024a0:	e9 68 f9 ff ff       	jmp    101e0d <__alltraps>

001024a5 <vector171>:
.globl vector171
vector171:
  pushl $0
  1024a5:	6a 00                	push   $0x0
  pushl $171
  1024a7:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1024ac:	e9 5c f9 ff ff       	jmp    101e0d <__alltraps>

001024b1 <vector172>:
.globl vector172
vector172:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $172
  1024b3:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1024b8:	e9 50 f9 ff ff       	jmp    101e0d <__alltraps>

001024bd <vector173>:
.globl vector173
vector173:
  pushl $0
  1024bd:	6a 00                	push   $0x0
  pushl $173
  1024bf:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1024c4:	e9 44 f9 ff ff       	jmp    101e0d <__alltraps>

001024c9 <vector174>:
.globl vector174
vector174:
  pushl $0
  1024c9:	6a 00                	push   $0x0
  pushl $174
  1024cb:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1024d0:	e9 38 f9 ff ff       	jmp    101e0d <__alltraps>

001024d5 <vector175>:
.globl vector175
vector175:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $175
  1024d7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1024dc:	e9 2c f9 ff ff       	jmp    101e0d <__alltraps>

001024e1 <vector176>:
.globl vector176
vector176:
  pushl $0
  1024e1:	6a 00                	push   $0x0
  pushl $176
  1024e3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1024e8:	e9 20 f9 ff ff       	jmp    101e0d <__alltraps>

001024ed <vector177>:
.globl vector177
vector177:
  pushl $0
  1024ed:	6a 00                	push   $0x0
  pushl $177
  1024ef:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1024f4:	e9 14 f9 ff ff       	jmp    101e0d <__alltraps>

001024f9 <vector178>:
.globl vector178
vector178:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $178
  1024fb:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102500:	e9 08 f9 ff ff       	jmp    101e0d <__alltraps>

00102505 <vector179>:
.globl vector179
vector179:
  pushl $0
  102505:	6a 00                	push   $0x0
  pushl $179
  102507:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10250c:	e9 fc f8 ff ff       	jmp    101e0d <__alltraps>

00102511 <vector180>:
.globl vector180
vector180:
  pushl $0
  102511:	6a 00                	push   $0x0
  pushl $180
  102513:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102518:	e9 f0 f8 ff ff       	jmp    101e0d <__alltraps>

0010251d <vector181>:
.globl vector181
vector181:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $181
  10251f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102524:	e9 e4 f8 ff ff       	jmp    101e0d <__alltraps>

00102529 <vector182>:
.globl vector182
vector182:
  pushl $0
  102529:	6a 00                	push   $0x0
  pushl $182
  10252b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102530:	e9 d8 f8 ff ff       	jmp    101e0d <__alltraps>

00102535 <vector183>:
.globl vector183
vector183:
  pushl $0
  102535:	6a 00                	push   $0x0
  pushl $183
  102537:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10253c:	e9 cc f8 ff ff       	jmp    101e0d <__alltraps>

00102541 <vector184>:
.globl vector184
vector184:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $184
  102543:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102548:	e9 c0 f8 ff ff       	jmp    101e0d <__alltraps>

0010254d <vector185>:
.globl vector185
vector185:
  pushl $0
  10254d:	6a 00                	push   $0x0
  pushl $185
  10254f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102554:	e9 b4 f8 ff ff       	jmp    101e0d <__alltraps>

00102559 <vector186>:
.globl vector186
vector186:
  pushl $0
  102559:	6a 00                	push   $0x0
  pushl $186
  10255b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102560:	e9 a8 f8 ff ff       	jmp    101e0d <__alltraps>

00102565 <vector187>:
.globl vector187
vector187:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $187
  102567:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10256c:	e9 9c f8 ff ff       	jmp    101e0d <__alltraps>

00102571 <vector188>:
.globl vector188
vector188:
  pushl $0
  102571:	6a 00                	push   $0x0
  pushl $188
  102573:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102578:	e9 90 f8 ff ff       	jmp    101e0d <__alltraps>

0010257d <vector189>:
.globl vector189
vector189:
  pushl $0
  10257d:	6a 00                	push   $0x0
  pushl $189
  10257f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102584:	e9 84 f8 ff ff       	jmp    101e0d <__alltraps>

00102589 <vector190>:
.globl vector190
vector190:
  pushl $0
  102589:	6a 00                	push   $0x0
  pushl $190
  10258b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102590:	e9 78 f8 ff ff       	jmp    101e0d <__alltraps>

00102595 <vector191>:
.globl vector191
vector191:
  pushl $0
  102595:	6a 00                	push   $0x0
  pushl $191
  102597:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10259c:	e9 6c f8 ff ff       	jmp    101e0d <__alltraps>

001025a1 <vector192>:
.globl vector192
vector192:
  pushl $0
  1025a1:	6a 00                	push   $0x0
  pushl $192
  1025a3:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1025a8:	e9 60 f8 ff ff       	jmp    101e0d <__alltraps>

001025ad <vector193>:
.globl vector193
vector193:
  pushl $0
  1025ad:	6a 00                	push   $0x0
  pushl $193
  1025af:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1025b4:	e9 54 f8 ff ff       	jmp    101e0d <__alltraps>

001025b9 <vector194>:
.globl vector194
vector194:
  pushl $0
  1025b9:	6a 00                	push   $0x0
  pushl $194
  1025bb:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  1025c0:	e9 48 f8 ff ff       	jmp    101e0d <__alltraps>

001025c5 <vector195>:
.globl vector195
vector195:
  pushl $0
  1025c5:	6a 00                	push   $0x0
  pushl $195
  1025c7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1025cc:	e9 3c f8 ff ff       	jmp    101e0d <__alltraps>

001025d1 <vector196>:
.globl vector196
vector196:
  pushl $0
  1025d1:	6a 00                	push   $0x0
  pushl $196
  1025d3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1025d8:	e9 30 f8 ff ff       	jmp    101e0d <__alltraps>

001025dd <vector197>:
.globl vector197
vector197:
  pushl $0
  1025dd:	6a 00                	push   $0x0
  pushl $197
  1025df:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1025e4:	e9 24 f8 ff ff       	jmp    101e0d <__alltraps>

001025e9 <vector198>:
.globl vector198
vector198:
  pushl $0
  1025e9:	6a 00                	push   $0x0
  pushl $198
  1025eb:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1025f0:	e9 18 f8 ff ff       	jmp    101e0d <__alltraps>

001025f5 <vector199>:
.globl vector199
vector199:
  pushl $0
  1025f5:	6a 00                	push   $0x0
  pushl $199
  1025f7:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1025fc:	e9 0c f8 ff ff       	jmp    101e0d <__alltraps>

00102601 <vector200>:
.globl vector200
vector200:
  pushl $0
  102601:	6a 00                	push   $0x0
  pushl $200
  102603:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102608:	e9 00 f8 ff ff       	jmp    101e0d <__alltraps>

0010260d <vector201>:
.globl vector201
vector201:
  pushl $0
  10260d:	6a 00                	push   $0x0
  pushl $201
  10260f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102614:	e9 f4 f7 ff ff       	jmp    101e0d <__alltraps>

00102619 <vector202>:
.globl vector202
vector202:
  pushl $0
  102619:	6a 00                	push   $0x0
  pushl $202
  10261b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102620:	e9 e8 f7 ff ff       	jmp    101e0d <__alltraps>

00102625 <vector203>:
.globl vector203
vector203:
  pushl $0
  102625:	6a 00                	push   $0x0
  pushl $203
  102627:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10262c:	e9 dc f7 ff ff       	jmp    101e0d <__alltraps>

00102631 <vector204>:
.globl vector204
vector204:
  pushl $0
  102631:	6a 00                	push   $0x0
  pushl $204
  102633:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102638:	e9 d0 f7 ff ff       	jmp    101e0d <__alltraps>

0010263d <vector205>:
.globl vector205
vector205:
  pushl $0
  10263d:	6a 00                	push   $0x0
  pushl $205
  10263f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102644:	e9 c4 f7 ff ff       	jmp    101e0d <__alltraps>

00102649 <vector206>:
.globl vector206
vector206:
  pushl $0
  102649:	6a 00                	push   $0x0
  pushl $206
  10264b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102650:	e9 b8 f7 ff ff       	jmp    101e0d <__alltraps>

00102655 <vector207>:
.globl vector207
vector207:
  pushl $0
  102655:	6a 00                	push   $0x0
  pushl $207
  102657:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10265c:	e9 ac f7 ff ff       	jmp    101e0d <__alltraps>

00102661 <vector208>:
.globl vector208
vector208:
  pushl $0
  102661:	6a 00                	push   $0x0
  pushl $208
  102663:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102668:	e9 a0 f7 ff ff       	jmp    101e0d <__alltraps>

0010266d <vector209>:
.globl vector209
vector209:
  pushl $0
  10266d:	6a 00                	push   $0x0
  pushl $209
  10266f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102674:	e9 94 f7 ff ff       	jmp    101e0d <__alltraps>

00102679 <vector210>:
.globl vector210
vector210:
  pushl $0
  102679:	6a 00                	push   $0x0
  pushl $210
  10267b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102680:	e9 88 f7 ff ff       	jmp    101e0d <__alltraps>

00102685 <vector211>:
.globl vector211
vector211:
  pushl $0
  102685:	6a 00                	push   $0x0
  pushl $211
  102687:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10268c:	e9 7c f7 ff ff       	jmp    101e0d <__alltraps>

00102691 <vector212>:
.globl vector212
vector212:
  pushl $0
  102691:	6a 00                	push   $0x0
  pushl $212
  102693:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102698:	e9 70 f7 ff ff       	jmp    101e0d <__alltraps>

0010269d <vector213>:
.globl vector213
vector213:
  pushl $0
  10269d:	6a 00                	push   $0x0
  pushl $213
  10269f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1026a4:	e9 64 f7 ff ff       	jmp    101e0d <__alltraps>

001026a9 <vector214>:
.globl vector214
vector214:
  pushl $0
  1026a9:	6a 00                	push   $0x0
  pushl $214
  1026ab:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1026b0:	e9 58 f7 ff ff       	jmp    101e0d <__alltraps>

001026b5 <vector215>:
.globl vector215
vector215:
  pushl $0
  1026b5:	6a 00                	push   $0x0
  pushl $215
  1026b7:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1026bc:	e9 4c f7 ff ff       	jmp    101e0d <__alltraps>

001026c1 <vector216>:
.globl vector216
vector216:
  pushl $0
  1026c1:	6a 00                	push   $0x0
  pushl $216
  1026c3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1026c8:	e9 40 f7 ff ff       	jmp    101e0d <__alltraps>

001026cd <vector217>:
.globl vector217
vector217:
  pushl $0
  1026cd:	6a 00                	push   $0x0
  pushl $217
  1026cf:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1026d4:	e9 34 f7 ff ff       	jmp    101e0d <__alltraps>

001026d9 <vector218>:
.globl vector218
vector218:
  pushl $0
  1026d9:	6a 00                	push   $0x0
  pushl $218
  1026db:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1026e0:	e9 28 f7 ff ff       	jmp    101e0d <__alltraps>

001026e5 <vector219>:
.globl vector219
vector219:
  pushl $0
  1026e5:	6a 00                	push   $0x0
  pushl $219
  1026e7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1026ec:	e9 1c f7 ff ff       	jmp    101e0d <__alltraps>

001026f1 <vector220>:
.globl vector220
vector220:
  pushl $0
  1026f1:	6a 00                	push   $0x0
  pushl $220
  1026f3:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1026f8:	e9 10 f7 ff ff       	jmp    101e0d <__alltraps>

001026fd <vector221>:
.globl vector221
vector221:
  pushl $0
  1026fd:	6a 00                	push   $0x0
  pushl $221
  1026ff:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102704:	e9 04 f7 ff ff       	jmp    101e0d <__alltraps>

00102709 <vector222>:
.globl vector222
vector222:
  pushl $0
  102709:	6a 00                	push   $0x0
  pushl $222
  10270b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102710:	e9 f8 f6 ff ff       	jmp    101e0d <__alltraps>

00102715 <vector223>:
.globl vector223
vector223:
  pushl $0
  102715:	6a 00                	push   $0x0
  pushl $223
  102717:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10271c:	e9 ec f6 ff ff       	jmp    101e0d <__alltraps>

00102721 <vector224>:
.globl vector224
vector224:
  pushl $0
  102721:	6a 00                	push   $0x0
  pushl $224
  102723:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102728:	e9 e0 f6 ff ff       	jmp    101e0d <__alltraps>

0010272d <vector225>:
.globl vector225
vector225:
  pushl $0
  10272d:	6a 00                	push   $0x0
  pushl $225
  10272f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102734:	e9 d4 f6 ff ff       	jmp    101e0d <__alltraps>

00102739 <vector226>:
.globl vector226
vector226:
  pushl $0
  102739:	6a 00                	push   $0x0
  pushl $226
  10273b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102740:	e9 c8 f6 ff ff       	jmp    101e0d <__alltraps>

00102745 <vector227>:
.globl vector227
vector227:
  pushl $0
  102745:	6a 00                	push   $0x0
  pushl $227
  102747:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10274c:	e9 bc f6 ff ff       	jmp    101e0d <__alltraps>

00102751 <vector228>:
.globl vector228
vector228:
  pushl $0
  102751:	6a 00                	push   $0x0
  pushl $228
  102753:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102758:	e9 b0 f6 ff ff       	jmp    101e0d <__alltraps>

0010275d <vector229>:
.globl vector229
vector229:
  pushl $0
  10275d:	6a 00                	push   $0x0
  pushl $229
  10275f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102764:	e9 a4 f6 ff ff       	jmp    101e0d <__alltraps>

00102769 <vector230>:
.globl vector230
vector230:
  pushl $0
  102769:	6a 00                	push   $0x0
  pushl $230
  10276b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102770:	e9 98 f6 ff ff       	jmp    101e0d <__alltraps>

00102775 <vector231>:
.globl vector231
vector231:
  pushl $0
  102775:	6a 00                	push   $0x0
  pushl $231
  102777:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10277c:	e9 8c f6 ff ff       	jmp    101e0d <__alltraps>

00102781 <vector232>:
.globl vector232
vector232:
  pushl $0
  102781:	6a 00                	push   $0x0
  pushl $232
  102783:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102788:	e9 80 f6 ff ff       	jmp    101e0d <__alltraps>

0010278d <vector233>:
.globl vector233
vector233:
  pushl $0
  10278d:	6a 00                	push   $0x0
  pushl $233
  10278f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102794:	e9 74 f6 ff ff       	jmp    101e0d <__alltraps>

00102799 <vector234>:
.globl vector234
vector234:
  pushl $0
  102799:	6a 00                	push   $0x0
  pushl $234
  10279b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1027a0:	e9 68 f6 ff ff       	jmp    101e0d <__alltraps>

001027a5 <vector235>:
.globl vector235
vector235:
  pushl $0
  1027a5:	6a 00                	push   $0x0
  pushl $235
  1027a7:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1027ac:	e9 5c f6 ff ff       	jmp    101e0d <__alltraps>

001027b1 <vector236>:
.globl vector236
vector236:
  pushl $0
  1027b1:	6a 00                	push   $0x0
  pushl $236
  1027b3:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1027b8:	e9 50 f6 ff ff       	jmp    101e0d <__alltraps>

001027bd <vector237>:
.globl vector237
vector237:
  pushl $0
  1027bd:	6a 00                	push   $0x0
  pushl $237
  1027bf:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1027c4:	e9 44 f6 ff ff       	jmp    101e0d <__alltraps>

001027c9 <vector238>:
.globl vector238
vector238:
  pushl $0
  1027c9:	6a 00                	push   $0x0
  pushl $238
  1027cb:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1027d0:	e9 38 f6 ff ff       	jmp    101e0d <__alltraps>

001027d5 <vector239>:
.globl vector239
vector239:
  pushl $0
  1027d5:	6a 00                	push   $0x0
  pushl $239
  1027d7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1027dc:	e9 2c f6 ff ff       	jmp    101e0d <__alltraps>

001027e1 <vector240>:
.globl vector240
vector240:
  pushl $0
  1027e1:	6a 00                	push   $0x0
  pushl $240
  1027e3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1027e8:	e9 20 f6 ff ff       	jmp    101e0d <__alltraps>

001027ed <vector241>:
.globl vector241
vector241:
  pushl $0
  1027ed:	6a 00                	push   $0x0
  pushl $241
  1027ef:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1027f4:	e9 14 f6 ff ff       	jmp    101e0d <__alltraps>

001027f9 <vector242>:
.globl vector242
vector242:
  pushl $0
  1027f9:	6a 00                	push   $0x0
  pushl $242
  1027fb:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102800:	e9 08 f6 ff ff       	jmp    101e0d <__alltraps>

00102805 <vector243>:
.globl vector243
vector243:
  pushl $0
  102805:	6a 00                	push   $0x0
  pushl $243
  102807:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10280c:	e9 fc f5 ff ff       	jmp    101e0d <__alltraps>

00102811 <vector244>:
.globl vector244
vector244:
  pushl $0
  102811:	6a 00                	push   $0x0
  pushl $244
  102813:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102818:	e9 f0 f5 ff ff       	jmp    101e0d <__alltraps>

0010281d <vector245>:
.globl vector245
vector245:
  pushl $0
  10281d:	6a 00                	push   $0x0
  pushl $245
  10281f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102824:	e9 e4 f5 ff ff       	jmp    101e0d <__alltraps>

00102829 <vector246>:
.globl vector246
vector246:
  pushl $0
  102829:	6a 00                	push   $0x0
  pushl $246
  10282b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102830:	e9 d8 f5 ff ff       	jmp    101e0d <__alltraps>

00102835 <vector247>:
.globl vector247
vector247:
  pushl $0
  102835:	6a 00                	push   $0x0
  pushl $247
  102837:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10283c:	e9 cc f5 ff ff       	jmp    101e0d <__alltraps>

00102841 <vector248>:
.globl vector248
vector248:
  pushl $0
  102841:	6a 00                	push   $0x0
  pushl $248
  102843:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102848:	e9 c0 f5 ff ff       	jmp    101e0d <__alltraps>

0010284d <vector249>:
.globl vector249
vector249:
  pushl $0
  10284d:	6a 00                	push   $0x0
  pushl $249
  10284f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102854:	e9 b4 f5 ff ff       	jmp    101e0d <__alltraps>

00102859 <vector250>:
.globl vector250
vector250:
  pushl $0
  102859:	6a 00                	push   $0x0
  pushl $250
  10285b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102860:	e9 a8 f5 ff ff       	jmp    101e0d <__alltraps>

00102865 <vector251>:
.globl vector251
vector251:
  pushl $0
  102865:	6a 00                	push   $0x0
  pushl $251
  102867:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  10286c:	e9 9c f5 ff ff       	jmp    101e0d <__alltraps>

00102871 <vector252>:
.globl vector252
vector252:
  pushl $0
  102871:	6a 00                	push   $0x0
  pushl $252
  102873:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102878:	e9 90 f5 ff ff       	jmp    101e0d <__alltraps>

0010287d <vector253>:
.globl vector253
vector253:
  pushl $0
  10287d:	6a 00                	push   $0x0
  pushl $253
  10287f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102884:	e9 84 f5 ff ff       	jmp    101e0d <__alltraps>

00102889 <vector254>:
.globl vector254
vector254:
  pushl $0
  102889:	6a 00                	push   $0x0
  pushl $254
  10288b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102890:	e9 78 f5 ff ff       	jmp    101e0d <__alltraps>

00102895 <vector255>:
.globl vector255
vector255:
  pushl $0
  102895:	6a 00                	push   $0x0
  pushl $255
  102897:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10289c:	e9 6c f5 ff ff       	jmp    101e0d <__alltraps>

001028a1 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1028a1:	55                   	push   %ebp
  1028a2:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1028a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1028a7:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1028aa:	b8 23 00 00 00       	mov    $0x23,%eax
  1028af:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1028b1:	b8 23 00 00 00       	mov    $0x23,%eax
  1028b6:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  1028b8:	b8 10 00 00 00       	mov    $0x10,%eax
  1028bd:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  1028bf:	b8 10 00 00 00       	mov    $0x10,%eax
  1028c4:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  1028c6:	b8 10 00 00 00       	mov    $0x10,%eax
  1028cb:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  1028cd:	ea d4 28 10 00 08 00 	ljmp   $0x8,$0x1028d4
}
  1028d4:	5d                   	pop    %ebp
  1028d5:	c3                   	ret    

001028d6 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  1028d6:	55                   	push   %ebp
  1028d7:	89 e5                	mov    %esp,%ebp
  1028d9:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  1028dc:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  1028e1:	05 00 04 00 00       	add    $0x400,%eax
  1028e6:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  1028eb:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  1028f2:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  1028f4:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  1028fb:	68 00 
  1028fd:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102902:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  102908:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10290d:	c1 e8 10             	shr    $0x10,%eax
  102910:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  102915:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10291c:	83 e0 f0             	and    $0xfffffff0,%eax
  10291f:	83 c8 09             	or     $0x9,%eax
  102922:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102927:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10292e:	83 c8 10             	or     $0x10,%eax
  102931:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102936:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10293d:	83 e0 9f             	and    $0xffffff9f,%eax
  102940:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102945:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10294c:	83 c8 80             	or     $0xffffff80,%eax
  10294f:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102954:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10295b:	83 e0 f0             	and    $0xfffffff0,%eax
  10295e:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102963:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  10296a:	83 e0 ef             	and    $0xffffffef,%eax
  10296d:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102972:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102979:	83 e0 df             	and    $0xffffffdf,%eax
  10297c:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102981:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102988:	83 c8 40             	or     $0x40,%eax
  10298b:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102990:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102997:	83 e0 7f             	and    $0x7f,%eax
  10299a:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  10299f:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029a4:	c1 e8 18             	shr    $0x18,%eax
  1029a7:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  1029ac:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029b3:	83 e0 ef             	and    $0xffffffef,%eax
  1029b6:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  1029bb:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  1029c2:	e8 da fe ff ff       	call   1028a1 <lgdt>
  1029c7:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  1029cd:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  1029d1:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  1029d4:	c9                   	leave  
  1029d5:	c3                   	ret    

001029d6 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  1029d6:	55                   	push   %ebp
  1029d7:	89 e5                	mov    %esp,%ebp
    gdt_init();
  1029d9:	e8 f8 fe ff ff       	call   1028d6 <gdt_init>
}
  1029de:	5d                   	pop    %ebp
  1029df:	c3                   	ret    

001029e0 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1029e0:	55                   	push   %ebp
  1029e1:	89 e5                	mov    %esp,%ebp
  1029e3:	83 ec 58             	sub    $0x58,%esp
  1029e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1029e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1029ec:	8b 45 14             	mov    0x14(%ebp),%eax
  1029ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1029f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1029f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1029f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1029fb:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1029fe:	8b 45 18             	mov    0x18(%ebp),%eax
  102a01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102a04:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102a07:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102a0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102a0d:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a16:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102a1a:	74 1c                	je     102a38 <printnum+0x58>
  102a1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  102a24:	f7 75 e4             	divl   -0x1c(%ebp)
  102a27:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  102a32:	f7 75 e4             	divl   -0x1c(%ebp)
  102a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102a38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102a3e:	f7 75 e4             	divl   -0x1c(%ebp)
  102a41:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102a44:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102a47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102a4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102a4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102a50:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102a53:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102a56:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102a59:	8b 45 18             	mov    0x18(%ebp),%eax
  102a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  102a61:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102a64:	77 56                	ja     102abc <printnum+0xdc>
  102a66:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102a69:	72 05                	jb     102a70 <printnum+0x90>
  102a6b:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102a6e:	77 4c                	ja     102abc <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102a70:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102a73:	8d 50 ff             	lea    -0x1(%eax),%edx
  102a76:	8b 45 20             	mov    0x20(%ebp),%eax
  102a79:	89 44 24 18          	mov    %eax,0x18(%esp)
  102a7d:	89 54 24 14          	mov    %edx,0x14(%esp)
  102a81:	8b 45 18             	mov    0x18(%ebp),%eax
  102a84:	89 44 24 10          	mov    %eax,0x10(%esp)
  102a88:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102a8b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102a8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  102a92:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a99:	89 44 24 04          	mov    %eax,0x4(%esp)
  102a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102aa0:	89 04 24             	mov    %eax,(%esp)
  102aa3:	e8 38 ff ff ff       	call   1029e0 <printnum>
  102aa8:	eb 1c                	jmp    102ac6 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  102aad:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ab1:	8b 45 20             	mov    0x20(%ebp),%eax
  102ab4:	89 04 24             	mov    %eax,(%esp)
  102ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  102aba:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  102abc:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102ac0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102ac4:	7f e4                	jg     102aaa <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102ac6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102ac9:	05 f0 3c 10 00       	add    $0x103cf0,%eax
  102ace:	0f b6 00             	movzbl (%eax),%eax
  102ad1:	0f be c0             	movsbl %al,%eax
  102ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ad7:	89 54 24 04          	mov    %edx,0x4(%esp)
  102adb:	89 04 24             	mov    %eax,(%esp)
  102ade:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae1:	ff d0                	call   *%eax
}
  102ae3:	c9                   	leave  
  102ae4:	c3                   	ret    

00102ae5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102ae5:	55                   	push   %ebp
  102ae6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102ae8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102aec:	7e 14                	jle    102b02 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102aee:	8b 45 08             	mov    0x8(%ebp),%eax
  102af1:	8b 00                	mov    (%eax),%eax
  102af3:	8d 48 08             	lea    0x8(%eax),%ecx
  102af6:	8b 55 08             	mov    0x8(%ebp),%edx
  102af9:	89 0a                	mov    %ecx,(%edx)
  102afb:	8b 50 04             	mov    0x4(%eax),%edx
  102afe:	8b 00                	mov    (%eax),%eax
  102b00:	eb 30                	jmp    102b32 <getuint+0x4d>
    }
    else if (lflag) {
  102b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b06:	74 16                	je     102b1e <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102b08:	8b 45 08             	mov    0x8(%ebp),%eax
  102b0b:	8b 00                	mov    (%eax),%eax
  102b0d:	8d 48 04             	lea    0x4(%eax),%ecx
  102b10:	8b 55 08             	mov    0x8(%ebp),%edx
  102b13:	89 0a                	mov    %ecx,(%edx)
  102b15:	8b 00                	mov    (%eax),%eax
  102b17:	ba 00 00 00 00       	mov    $0x0,%edx
  102b1c:	eb 14                	jmp    102b32 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b21:	8b 00                	mov    (%eax),%eax
  102b23:	8d 48 04             	lea    0x4(%eax),%ecx
  102b26:	8b 55 08             	mov    0x8(%ebp),%edx
  102b29:	89 0a                	mov    %ecx,(%edx)
  102b2b:	8b 00                	mov    (%eax),%eax
  102b2d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102b32:	5d                   	pop    %ebp
  102b33:	c3                   	ret    

00102b34 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102b34:	55                   	push   %ebp
  102b35:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102b37:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102b3b:	7e 14                	jle    102b51 <getint+0x1d>
        return va_arg(*ap, long long);
  102b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  102b40:	8b 00                	mov    (%eax),%eax
  102b42:	8d 48 08             	lea    0x8(%eax),%ecx
  102b45:	8b 55 08             	mov    0x8(%ebp),%edx
  102b48:	89 0a                	mov    %ecx,(%edx)
  102b4a:	8b 50 04             	mov    0x4(%eax),%edx
  102b4d:	8b 00                	mov    (%eax),%eax
  102b4f:	eb 28                	jmp    102b79 <getint+0x45>
    }
    else if (lflag) {
  102b51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b55:	74 12                	je     102b69 <getint+0x35>
        return va_arg(*ap, long);
  102b57:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5a:	8b 00                	mov    (%eax),%eax
  102b5c:	8d 48 04             	lea    0x4(%eax),%ecx
  102b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  102b62:	89 0a                	mov    %ecx,(%edx)
  102b64:	8b 00                	mov    (%eax),%eax
  102b66:	99                   	cltd   
  102b67:	eb 10                	jmp    102b79 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102b69:	8b 45 08             	mov    0x8(%ebp),%eax
  102b6c:	8b 00                	mov    (%eax),%eax
  102b6e:	8d 48 04             	lea    0x4(%eax),%ecx
  102b71:	8b 55 08             	mov    0x8(%ebp),%edx
  102b74:	89 0a                	mov    %ecx,(%edx)
  102b76:	8b 00                	mov    (%eax),%eax
  102b78:	99                   	cltd   
    }
}
  102b79:	5d                   	pop    %ebp
  102b7a:	c3                   	ret    

00102b7b <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102b7b:	55                   	push   %ebp
  102b7c:	89 e5                	mov    %esp,%ebp
  102b7e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102b81:	8d 45 14             	lea    0x14(%ebp),%eax
  102b84:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102b8e:	8b 45 10             	mov    0x10(%ebp),%eax
  102b91:	89 44 24 08          	mov    %eax,0x8(%esp)
  102b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b9f:	89 04 24             	mov    %eax,(%esp)
  102ba2:	e8 02 00 00 00       	call   102ba9 <vprintfmt>
    va_end(ap);
}
  102ba7:	c9                   	leave  
  102ba8:	c3                   	ret    

00102ba9 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102ba9:	55                   	push   %ebp
  102baa:	89 e5                	mov    %esp,%ebp
  102bac:	56                   	push   %esi
  102bad:	53                   	push   %ebx
  102bae:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102bb1:	eb 18                	jmp    102bcb <vprintfmt+0x22>
            if (ch == '\0') {
  102bb3:	85 db                	test   %ebx,%ebx
  102bb5:	75 05                	jne    102bbc <vprintfmt+0x13>
                return;
  102bb7:	e9 d1 03 00 00       	jmp    102f8d <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  102bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  102bc3:	89 1c 24             	mov    %ebx,(%esp)
  102bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc9:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102bcb:	8b 45 10             	mov    0x10(%ebp),%eax
  102bce:	8d 50 01             	lea    0x1(%eax),%edx
  102bd1:	89 55 10             	mov    %edx,0x10(%ebp)
  102bd4:	0f b6 00             	movzbl (%eax),%eax
  102bd7:	0f b6 d8             	movzbl %al,%ebx
  102bda:	83 fb 25             	cmp    $0x25,%ebx
  102bdd:	75 d4                	jne    102bb3 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  102bdf:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102be3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102bea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102bed:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102bf0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102bf7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102bfa:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102bfd:	8b 45 10             	mov    0x10(%ebp),%eax
  102c00:	8d 50 01             	lea    0x1(%eax),%edx
  102c03:	89 55 10             	mov    %edx,0x10(%ebp)
  102c06:	0f b6 00             	movzbl (%eax),%eax
  102c09:	0f b6 d8             	movzbl %al,%ebx
  102c0c:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102c0f:	83 f8 55             	cmp    $0x55,%eax
  102c12:	0f 87 44 03 00 00    	ja     102f5c <vprintfmt+0x3b3>
  102c18:	8b 04 85 14 3d 10 00 	mov    0x103d14(,%eax,4),%eax
  102c1f:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102c21:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102c25:	eb d6                	jmp    102bfd <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102c27:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102c2b:	eb d0                	jmp    102bfd <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102c2d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102c34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102c37:	89 d0                	mov    %edx,%eax
  102c39:	c1 e0 02             	shl    $0x2,%eax
  102c3c:	01 d0                	add    %edx,%eax
  102c3e:	01 c0                	add    %eax,%eax
  102c40:	01 d8                	add    %ebx,%eax
  102c42:	83 e8 30             	sub    $0x30,%eax
  102c45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102c48:	8b 45 10             	mov    0x10(%ebp),%eax
  102c4b:	0f b6 00             	movzbl (%eax),%eax
  102c4e:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102c51:	83 fb 2f             	cmp    $0x2f,%ebx
  102c54:	7e 0b                	jle    102c61 <vprintfmt+0xb8>
  102c56:	83 fb 39             	cmp    $0x39,%ebx
  102c59:	7f 06                	jg     102c61 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102c5b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  102c5f:	eb d3                	jmp    102c34 <vprintfmt+0x8b>
            goto process_precision;
  102c61:	eb 33                	jmp    102c96 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  102c63:	8b 45 14             	mov    0x14(%ebp),%eax
  102c66:	8d 50 04             	lea    0x4(%eax),%edx
  102c69:	89 55 14             	mov    %edx,0x14(%ebp)
  102c6c:	8b 00                	mov    (%eax),%eax
  102c6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102c71:	eb 23                	jmp    102c96 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  102c73:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102c77:	79 0c                	jns    102c85 <vprintfmt+0xdc>
                width = 0;
  102c79:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102c80:	e9 78 ff ff ff       	jmp    102bfd <vprintfmt+0x54>
  102c85:	e9 73 ff ff ff       	jmp    102bfd <vprintfmt+0x54>

        case '#':
            altflag = 1;
  102c8a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102c91:	e9 67 ff ff ff       	jmp    102bfd <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  102c96:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102c9a:	79 12                	jns    102cae <vprintfmt+0x105>
                width = precision, precision = -1;
  102c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102ca2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102ca9:	e9 4f ff ff ff       	jmp    102bfd <vprintfmt+0x54>
  102cae:	e9 4a ff ff ff       	jmp    102bfd <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102cb3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  102cb7:	e9 41 ff ff ff       	jmp    102bfd <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102cbc:	8b 45 14             	mov    0x14(%ebp),%eax
  102cbf:	8d 50 04             	lea    0x4(%eax),%edx
  102cc2:	89 55 14             	mov    %edx,0x14(%ebp)
  102cc5:	8b 00                	mov    (%eax),%eax
  102cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  102cca:	89 54 24 04          	mov    %edx,0x4(%esp)
  102cce:	89 04 24             	mov    %eax,(%esp)
  102cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  102cd4:	ff d0                	call   *%eax
            break;
  102cd6:	e9 ac 02 00 00       	jmp    102f87 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102cdb:	8b 45 14             	mov    0x14(%ebp),%eax
  102cde:	8d 50 04             	lea    0x4(%eax),%edx
  102ce1:	89 55 14             	mov    %edx,0x14(%ebp)
  102ce4:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102ce6:	85 db                	test   %ebx,%ebx
  102ce8:	79 02                	jns    102cec <vprintfmt+0x143>
                err = -err;
  102cea:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102cec:	83 fb 06             	cmp    $0x6,%ebx
  102cef:	7f 0b                	jg     102cfc <vprintfmt+0x153>
  102cf1:	8b 34 9d d4 3c 10 00 	mov    0x103cd4(,%ebx,4),%esi
  102cf8:	85 f6                	test   %esi,%esi
  102cfa:	75 23                	jne    102d1f <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  102cfc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102d00:	c7 44 24 08 01 3d 10 	movl   $0x103d01,0x8(%esp)
  102d07:	00 
  102d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  102d12:	89 04 24             	mov    %eax,(%esp)
  102d15:	e8 61 fe ff ff       	call   102b7b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102d1a:	e9 68 02 00 00       	jmp    102f87 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  102d1f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102d23:	c7 44 24 08 0a 3d 10 	movl   $0x103d0a,0x8(%esp)
  102d2a:	00 
  102d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d32:	8b 45 08             	mov    0x8(%ebp),%eax
  102d35:	89 04 24             	mov    %eax,(%esp)
  102d38:	e8 3e fe ff ff       	call   102b7b <printfmt>
            }
            break;
  102d3d:	e9 45 02 00 00       	jmp    102f87 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102d42:	8b 45 14             	mov    0x14(%ebp),%eax
  102d45:	8d 50 04             	lea    0x4(%eax),%edx
  102d48:	89 55 14             	mov    %edx,0x14(%ebp)
  102d4b:	8b 30                	mov    (%eax),%esi
  102d4d:	85 f6                	test   %esi,%esi
  102d4f:	75 05                	jne    102d56 <vprintfmt+0x1ad>
                p = "(null)";
  102d51:	be 0d 3d 10 00       	mov    $0x103d0d,%esi
            }
            if (width > 0 && padc != '-') {
  102d56:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d5a:	7e 3e                	jle    102d9a <vprintfmt+0x1f1>
  102d5c:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102d60:	74 38                	je     102d9a <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102d62:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  102d65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d6c:	89 34 24             	mov    %esi,(%esp)
  102d6f:	e8 15 03 00 00       	call   103089 <strnlen>
  102d74:	29 c3                	sub    %eax,%ebx
  102d76:	89 d8                	mov    %ebx,%eax
  102d78:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102d7b:	eb 17                	jmp    102d94 <vprintfmt+0x1eb>
                    putch(padc, putdat);
  102d7d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102d81:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d84:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d88:	89 04 24             	mov    %eax,(%esp)
  102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d8e:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  102d90:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102d94:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d98:	7f e3                	jg     102d7d <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102d9a:	eb 38                	jmp    102dd4 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  102d9c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102da0:	74 1f                	je     102dc1 <vprintfmt+0x218>
  102da2:	83 fb 1f             	cmp    $0x1f,%ebx
  102da5:	7e 05                	jle    102dac <vprintfmt+0x203>
  102da7:	83 fb 7e             	cmp    $0x7e,%ebx
  102daa:	7e 15                	jle    102dc1 <vprintfmt+0x218>
                    putch('?', putdat);
  102dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  102daf:	89 44 24 04          	mov    %eax,0x4(%esp)
  102db3:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102dba:	8b 45 08             	mov    0x8(%ebp),%eax
  102dbd:	ff d0                	call   *%eax
  102dbf:	eb 0f                	jmp    102dd0 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  102dc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dc8:	89 1c 24             	mov    %ebx,(%esp)
  102dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  102dce:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102dd0:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102dd4:	89 f0                	mov    %esi,%eax
  102dd6:	8d 70 01             	lea    0x1(%eax),%esi
  102dd9:	0f b6 00             	movzbl (%eax),%eax
  102ddc:	0f be d8             	movsbl %al,%ebx
  102ddf:	85 db                	test   %ebx,%ebx
  102de1:	74 10                	je     102df3 <vprintfmt+0x24a>
  102de3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102de7:	78 b3                	js     102d9c <vprintfmt+0x1f3>
  102de9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  102ded:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102df1:	79 a9                	jns    102d9c <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102df3:	eb 17                	jmp    102e0c <vprintfmt+0x263>
                putch(' ', putdat);
  102df5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102df8:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dfc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102e03:	8b 45 08             	mov    0x8(%ebp),%eax
  102e06:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102e08:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102e0c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e10:	7f e3                	jg     102df5 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  102e12:	e9 70 01 00 00       	jmp    102f87 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102e17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e1e:	8d 45 14             	lea    0x14(%ebp),%eax
  102e21:	89 04 24             	mov    %eax,(%esp)
  102e24:	e8 0b fd ff ff       	call   102b34 <getint>
  102e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e2c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e35:	85 d2                	test   %edx,%edx
  102e37:	79 26                	jns    102e5f <vprintfmt+0x2b6>
                putch('-', putdat);
  102e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e40:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  102e47:	8b 45 08             	mov    0x8(%ebp),%eax
  102e4a:	ff d0                	call   *%eax
                num = -(long long)num;
  102e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e52:	f7 d8                	neg    %eax
  102e54:	83 d2 00             	adc    $0x0,%edx
  102e57:	f7 da                	neg    %edx
  102e59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e5c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  102e5f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102e66:	e9 a8 00 00 00       	jmp    102f13 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  102e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e72:	8d 45 14             	lea    0x14(%ebp),%eax
  102e75:	89 04 24             	mov    %eax,(%esp)
  102e78:	e8 68 fc ff ff       	call   102ae5 <getuint>
  102e7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e80:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  102e83:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102e8a:	e9 84 00 00 00       	jmp    102f13 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  102e8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e92:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e96:	8d 45 14             	lea    0x14(%ebp),%eax
  102e99:	89 04 24             	mov    %eax,(%esp)
  102e9c:	e8 44 fc ff ff       	call   102ae5 <getuint>
  102ea1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ea4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  102ea7:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  102eae:	eb 63                	jmp    102f13 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  102eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eb7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  102ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec1:	ff d0                	call   *%eax
            putch('x', putdat);
  102ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eca:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  102ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed4:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  102ed6:	8b 45 14             	mov    0x14(%ebp),%eax
  102ed9:	8d 50 04             	lea    0x4(%eax),%edx
  102edc:	89 55 14             	mov    %edx,0x14(%ebp)
  102edf:	8b 00                	mov    (%eax),%eax
  102ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ee4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  102eeb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  102ef2:	eb 1f                	jmp    102f13 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  102ef4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ef7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102efb:	8d 45 14             	lea    0x14(%ebp),%eax
  102efe:	89 04 24             	mov    %eax,(%esp)
  102f01:	e8 df fb ff ff       	call   102ae5 <getuint>
  102f06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f09:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  102f0c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  102f13:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  102f17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f1a:	89 54 24 18          	mov    %edx,0x18(%esp)
  102f1e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102f21:	89 54 24 14          	mov    %edx,0x14(%esp)
  102f25:	89 44 24 10          	mov    %eax,0x10(%esp)
  102f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  102f33:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102f37:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f41:	89 04 24             	mov    %eax,(%esp)
  102f44:	e8 97 fa ff ff       	call   1029e0 <printnum>
            break;
  102f49:	eb 3c                	jmp    102f87 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  102f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f52:	89 1c 24             	mov    %ebx,(%esp)
  102f55:	8b 45 08             	mov    0x8(%ebp),%eax
  102f58:	ff d0                	call   *%eax
            break;
  102f5a:	eb 2b                	jmp    102f87 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  102f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f63:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  102f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f6d:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  102f6f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102f73:	eb 04                	jmp    102f79 <vprintfmt+0x3d0>
  102f75:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102f79:	8b 45 10             	mov    0x10(%ebp),%eax
  102f7c:	83 e8 01             	sub    $0x1,%eax
  102f7f:	0f b6 00             	movzbl (%eax),%eax
  102f82:	3c 25                	cmp    $0x25,%al
  102f84:	75 ef                	jne    102f75 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  102f86:	90                   	nop
        }
    }
  102f87:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102f88:	e9 3e fc ff ff       	jmp    102bcb <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  102f8d:	83 c4 40             	add    $0x40,%esp
  102f90:	5b                   	pop    %ebx
  102f91:	5e                   	pop    %esi
  102f92:	5d                   	pop    %ebp
  102f93:	c3                   	ret    

00102f94 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  102f94:	55                   	push   %ebp
  102f95:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  102f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f9a:	8b 40 08             	mov    0x8(%eax),%eax
  102f9d:	8d 50 01             	lea    0x1(%eax),%edx
  102fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fa3:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  102fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fa9:	8b 10                	mov    (%eax),%edx
  102fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fae:	8b 40 04             	mov    0x4(%eax),%eax
  102fb1:	39 c2                	cmp    %eax,%edx
  102fb3:	73 12                	jae    102fc7 <sprintputch+0x33>
        *b->buf ++ = ch;
  102fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fb8:	8b 00                	mov    (%eax),%eax
  102fba:	8d 48 01             	lea    0x1(%eax),%ecx
  102fbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  102fc0:	89 0a                	mov    %ecx,(%edx)
  102fc2:	8b 55 08             	mov    0x8(%ebp),%edx
  102fc5:	88 10                	mov    %dl,(%eax)
    }
}
  102fc7:	5d                   	pop    %ebp
  102fc8:	c3                   	ret    

00102fc9 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  102fc9:	55                   	push   %ebp
  102fca:	89 e5                	mov    %esp,%ebp
  102fcc:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  102fcf:	8d 45 14             	lea    0x14(%ebp),%eax
  102fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  102fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  102fdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  102fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fea:	8b 45 08             	mov    0x8(%ebp),%eax
  102fed:	89 04 24             	mov    %eax,(%esp)
  102ff0:	e8 08 00 00 00       	call   102ffd <vsnprintf>
  102ff5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  102ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102ffb:	c9                   	leave  
  102ffc:	c3                   	ret    

00102ffd <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  102ffd:	55                   	push   %ebp
  102ffe:	89 e5                	mov    %esp,%ebp
  103000:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  103003:	8b 45 08             	mov    0x8(%ebp),%eax
  103006:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103009:	8b 45 0c             	mov    0xc(%ebp),%eax
  10300c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10300f:	8b 45 08             	mov    0x8(%ebp),%eax
  103012:	01 d0                	add    %edx,%eax
  103014:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103017:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10301e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103022:	74 0a                	je     10302e <vsnprintf+0x31>
  103024:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103027:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10302a:	39 c2                	cmp    %eax,%edx
  10302c:	76 07                	jbe    103035 <vsnprintf+0x38>
        return -E_INVAL;
  10302e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  103033:	eb 2a                	jmp    10305f <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103035:	8b 45 14             	mov    0x14(%ebp),%eax
  103038:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10303c:	8b 45 10             	mov    0x10(%ebp),%eax
  10303f:	89 44 24 08          	mov    %eax,0x8(%esp)
  103043:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103046:	89 44 24 04          	mov    %eax,0x4(%esp)
  10304a:	c7 04 24 94 2f 10 00 	movl   $0x102f94,(%esp)
  103051:	e8 53 fb ff ff       	call   102ba9 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103056:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103059:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  10305c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10305f:	c9                   	leave  
  103060:	c3                   	ret    

00103061 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  103061:	55                   	push   %ebp
  103062:	89 e5                	mov    %esp,%ebp
  103064:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  103067:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  10306e:	eb 04                	jmp    103074 <strlen+0x13>
        cnt ++;
  103070:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  103074:	8b 45 08             	mov    0x8(%ebp),%eax
  103077:	8d 50 01             	lea    0x1(%eax),%edx
  10307a:	89 55 08             	mov    %edx,0x8(%ebp)
  10307d:	0f b6 00             	movzbl (%eax),%eax
  103080:	84 c0                	test   %al,%al
  103082:	75 ec                	jne    103070 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  103084:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103087:	c9                   	leave  
  103088:	c3                   	ret    

00103089 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  103089:	55                   	push   %ebp
  10308a:	89 e5                	mov    %esp,%ebp
  10308c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10308f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  103096:	eb 04                	jmp    10309c <strnlen+0x13>
        cnt ++;
  103098:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  10309c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10309f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1030a2:	73 10                	jae    1030b4 <strnlen+0x2b>
  1030a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1030a7:	8d 50 01             	lea    0x1(%eax),%edx
  1030aa:	89 55 08             	mov    %edx,0x8(%ebp)
  1030ad:	0f b6 00             	movzbl (%eax),%eax
  1030b0:	84 c0                	test   %al,%al
  1030b2:	75 e4                	jne    103098 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  1030b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1030b7:	c9                   	leave  
  1030b8:	c3                   	ret    

001030b9 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1030b9:	55                   	push   %ebp
  1030ba:	89 e5                	mov    %esp,%ebp
  1030bc:	57                   	push   %edi
  1030bd:	56                   	push   %esi
  1030be:	83 ec 20             	sub    $0x20,%esp
  1030c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1030c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1030c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1030cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1030d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030d3:	89 d1                	mov    %edx,%ecx
  1030d5:	89 c2                	mov    %eax,%edx
  1030d7:	89 ce                	mov    %ecx,%esi
  1030d9:	89 d7                	mov    %edx,%edi
  1030db:	ac                   	lods   %ds:(%esi),%al
  1030dc:	aa                   	stos   %al,%es:(%edi)
  1030dd:	84 c0                	test   %al,%al
  1030df:	75 fa                	jne    1030db <strcpy+0x22>
  1030e1:	89 fa                	mov    %edi,%edx
  1030e3:	89 f1                	mov    %esi,%ecx
  1030e5:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1030e8:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1030eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  1030ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1030f1:	83 c4 20             	add    $0x20,%esp
  1030f4:	5e                   	pop    %esi
  1030f5:	5f                   	pop    %edi
  1030f6:	5d                   	pop    %ebp
  1030f7:	c3                   	ret    

001030f8 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1030f8:	55                   	push   %ebp
  1030f9:	89 e5                	mov    %esp,%ebp
  1030fb:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1030fe:	8b 45 08             	mov    0x8(%ebp),%eax
  103101:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  103104:	eb 21                	jmp    103127 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  103106:	8b 45 0c             	mov    0xc(%ebp),%eax
  103109:	0f b6 10             	movzbl (%eax),%edx
  10310c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10310f:	88 10                	mov    %dl,(%eax)
  103111:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103114:	0f b6 00             	movzbl (%eax),%eax
  103117:	84 c0                	test   %al,%al
  103119:	74 04                	je     10311f <strncpy+0x27>
            src ++;
  10311b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  10311f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  103123:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  103127:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10312b:	75 d9                	jne    103106 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  10312d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103130:	c9                   	leave  
  103131:	c3                   	ret    

00103132 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  103132:	55                   	push   %ebp
  103133:	89 e5                	mov    %esp,%ebp
  103135:	57                   	push   %edi
  103136:	56                   	push   %esi
  103137:	83 ec 20             	sub    $0x20,%esp
  10313a:	8b 45 08             	mov    0x8(%ebp),%eax
  10313d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103140:	8b 45 0c             	mov    0xc(%ebp),%eax
  103143:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  103146:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103149:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10314c:	89 d1                	mov    %edx,%ecx
  10314e:	89 c2                	mov    %eax,%edx
  103150:	89 ce                	mov    %ecx,%esi
  103152:	89 d7                	mov    %edx,%edi
  103154:	ac                   	lods   %ds:(%esi),%al
  103155:	ae                   	scas   %es:(%edi),%al
  103156:	75 08                	jne    103160 <strcmp+0x2e>
  103158:	84 c0                	test   %al,%al
  10315a:	75 f8                	jne    103154 <strcmp+0x22>
  10315c:	31 c0                	xor    %eax,%eax
  10315e:	eb 04                	jmp    103164 <strcmp+0x32>
  103160:	19 c0                	sbb    %eax,%eax
  103162:	0c 01                	or     $0x1,%al
  103164:	89 fa                	mov    %edi,%edx
  103166:	89 f1                	mov    %esi,%ecx
  103168:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10316b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10316e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  103171:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  103174:	83 c4 20             	add    $0x20,%esp
  103177:	5e                   	pop    %esi
  103178:	5f                   	pop    %edi
  103179:	5d                   	pop    %ebp
  10317a:	c3                   	ret    

0010317b <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  10317b:	55                   	push   %ebp
  10317c:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10317e:	eb 0c                	jmp    10318c <strncmp+0x11>
        n --, s1 ++, s2 ++;
  103180:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103184:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103188:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  10318c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103190:	74 1a                	je     1031ac <strncmp+0x31>
  103192:	8b 45 08             	mov    0x8(%ebp),%eax
  103195:	0f b6 00             	movzbl (%eax),%eax
  103198:	84 c0                	test   %al,%al
  10319a:	74 10                	je     1031ac <strncmp+0x31>
  10319c:	8b 45 08             	mov    0x8(%ebp),%eax
  10319f:	0f b6 10             	movzbl (%eax),%edx
  1031a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031a5:	0f b6 00             	movzbl (%eax),%eax
  1031a8:	38 c2                	cmp    %al,%dl
  1031aa:	74 d4                	je     103180 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1031ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1031b0:	74 18                	je     1031ca <strncmp+0x4f>
  1031b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1031b5:	0f b6 00             	movzbl (%eax),%eax
  1031b8:	0f b6 d0             	movzbl %al,%edx
  1031bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031be:	0f b6 00             	movzbl (%eax),%eax
  1031c1:	0f b6 c0             	movzbl %al,%eax
  1031c4:	29 c2                	sub    %eax,%edx
  1031c6:	89 d0                	mov    %edx,%eax
  1031c8:	eb 05                	jmp    1031cf <strncmp+0x54>
  1031ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1031cf:	5d                   	pop    %ebp
  1031d0:	c3                   	ret    

001031d1 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1031d1:	55                   	push   %ebp
  1031d2:	89 e5                	mov    %esp,%ebp
  1031d4:	83 ec 04             	sub    $0x4,%esp
  1031d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031da:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1031dd:	eb 14                	jmp    1031f3 <strchr+0x22>
        if (*s == c) {
  1031df:	8b 45 08             	mov    0x8(%ebp),%eax
  1031e2:	0f b6 00             	movzbl (%eax),%eax
  1031e5:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1031e8:	75 05                	jne    1031ef <strchr+0x1e>
            return (char *)s;
  1031ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ed:	eb 13                	jmp    103202 <strchr+0x31>
        }
        s ++;
  1031ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  1031f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1031f6:	0f b6 00             	movzbl (%eax),%eax
  1031f9:	84 c0                	test   %al,%al
  1031fb:	75 e2                	jne    1031df <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  1031fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103202:	c9                   	leave  
  103203:	c3                   	ret    

00103204 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  103204:	55                   	push   %ebp
  103205:	89 e5                	mov    %esp,%ebp
  103207:	83 ec 04             	sub    $0x4,%esp
  10320a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10320d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103210:	eb 11                	jmp    103223 <strfind+0x1f>
        if (*s == c) {
  103212:	8b 45 08             	mov    0x8(%ebp),%eax
  103215:	0f b6 00             	movzbl (%eax),%eax
  103218:	3a 45 fc             	cmp    -0x4(%ebp),%al
  10321b:	75 02                	jne    10321f <strfind+0x1b>
            break;
  10321d:	eb 0e                	jmp    10322d <strfind+0x29>
        }
        s ++;
  10321f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  103223:	8b 45 08             	mov    0x8(%ebp),%eax
  103226:	0f b6 00             	movzbl (%eax),%eax
  103229:	84 c0                	test   %al,%al
  10322b:	75 e5                	jne    103212 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  10322d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  103230:	c9                   	leave  
  103231:	c3                   	ret    

00103232 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  103232:	55                   	push   %ebp
  103233:	89 e5                	mov    %esp,%ebp
  103235:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  103238:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  10323f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  103246:	eb 04                	jmp    10324c <strtol+0x1a>
        s ++;
  103248:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10324c:	8b 45 08             	mov    0x8(%ebp),%eax
  10324f:	0f b6 00             	movzbl (%eax),%eax
  103252:	3c 20                	cmp    $0x20,%al
  103254:	74 f2                	je     103248 <strtol+0x16>
  103256:	8b 45 08             	mov    0x8(%ebp),%eax
  103259:	0f b6 00             	movzbl (%eax),%eax
  10325c:	3c 09                	cmp    $0x9,%al
  10325e:	74 e8                	je     103248 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  103260:	8b 45 08             	mov    0x8(%ebp),%eax
  103263:	0f b6 00             	movzbl (%eax),%eax
  103266:	3c 2b                	cmp    $0x2b,%al
  103268:	75 06                	jne    103270 <strtol+0x3e>
        s ++;
  10326a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10326e:	eb 15                	jmp    103285 <strtol+0x53>
    }
    else if (*s == '-') {
  103270:	8b 45 08             	mov    0x8(%ebp),%eax
  103273:	0f b6 00             	movzbl (%eax),%eax
  103276:	3c 2d                	cmp    $0x2d,%al
  103278:	75 0b                	jne    103285 <strtol+0x53>
        s ++, neg = 1;
  10327a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10327e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  103285:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103289:	74 06                	je     103291 <strtol+0x5f>
  10328b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10328f:	75 24                	jne    1032b5 <strtol+0x83>
  103291:	8b 45 08             	mov    0x8(%ebp),%eax
  103294:	0f b6 00             	movzbl (%eax),%eax
  103297:	3c 30                	cmp    $0x30,%al
  103299:	75 1a                	jne    1032b5 <strtol+0x83>
  10329b:	8b 45 08             	mov    0x8(%ebp),%eax
  10329e:	83 c0 01             	add    $0x1,%eax
  1032a1:	0f b6 00             	movzbl (%eax),%eax
  1032a4:	3c 78                	cmp    $0x78,%al
  1032a6:	75 0d                	jne    1032b5 <strtol+0x83>
        s += 2, base = 16;
  1032a8:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1032ac:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1032b3:	eb 2a                	jmp    1032df <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  1032b5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032b9:	75 17                	jne    1032d2 <strtol+0xa0>
  1032bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1032be:	0f b6 00             	movzbl (%eax),%eax
  1032c1:	3c 30                	cmp    $0x30,%al
  1032c3:	75 0d                	jne    1032d2 <strtol+0xa0>
        s ++, base = 8;
  1032c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1032c9:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  1032d0:	eb 0d                	jmp    1032df <strtol+0xad>
    }
    else if (base == 0) {
  1032d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1032d6:	75 07                	jne    1032df <strtol+0xad>
        base = 10;
  1032d8:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1032df:	8b 45 08             	mov    0x8(%ebp),%eax
  1032e2:	0f b6 00             	movzbl (%eax),%eax
  1032e5:	3c 2f                	cmp    $0x2f,%al
  1032e7:	7e 1b                	jle    103304 <strtol+0xd2>
  1032e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ec:	0f b6 00             	movzbl (%eax),%eax
  1032ef:	3c 39                	cmp    $0x39,%al
  1032f1:	7f 11                	jg     103304 <strtol+0xd2>
            dig = *s - '0';
  1032f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f6:	0f b6 00             	movzbl (%eax),%eax
  1032f9:	0f be c0             	movsbl %al,%eax
  1032fc:	83 e8 30             	sub    $0x30,%eax
  1032ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103302:	eb 48                	jmp    10334c <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  103304:	8b 45 08             	mov    0x8(%ebp),%eax
  103307:	0f b6 00             	movzbl (%eax),%eax
  10330a:	3c 60                	cmp    $0x60,%al
  10330c:	7e 1b                	jle    103329 <strtol+0xf7>
  10330e:	8b 45 08             	mov    0x8(%ebp),%eax
  103311:	0f b6 00             	movzbl (%eax),%eax
  103314:	3c 7a                	cmp    $0x7a,%al
  103316:	7f 11                	jg     103329 <strtol+0xf7>
            dig = *s - 'a' + 10;
  103318:	8b 45 08             	mov    0x8(%ebp),%eax
  10331b:	0f b6 00             	movzbl (%eax),%eax
  10331e:	0f be c0             	movsbl %al,%eax
  103321:	83 e8 57             	sub    $0x57,%eax
  103324:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103327:	eb 23                	jmp    10334c <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  103329:	8b 45 08             	mov    0x8(%ebp),%eax
  10332c:	0f b6 00             	movzbl (%eax),%eax
  10332f:	3c 40                	cmp    $0x40,%al
  103331:	7e 3d                	jle    103370 <strtol+0x13e>
  103333:	8b 45 08             	mov    0x8(%ebp),%eax
  103336:	0f b6 00             	movzbl (%eax),%eax
  103339:	3c 5a                	cmp    $0x5a,%al
  10333b:	7f 33                	jg     103370 <strtol+0x13e>
            dig = *s - 'A' + 10;
  10333d:	8b 45 08             	mov    0x8(%ebp),%eax
  103340:	0f b6 00             	movzbl (%eax),%eax
  103343:	0f be c0             	movsbl %al,%eax
  103346:	83 e8 37             	sub    $0x37,%eax
  103349:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10334c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10334f:	3b 45 10             	cmp    0x10(%ebp),%eax
  103352:	7c 02                	jl     103356 <strtol+0x124>
            break;
  103354:	eb 1a                	jmp    103370 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  103356:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10335a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10335d:	0f af 45 10          	imul   0x10(%ebp),%eax
  103361:	89 c2                	mov    %eax,%edx
  103363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103366:	01 d0                	add    %edx,%eax
  103368:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  10336b:	e9 6f ff ff ff       	jmp    1032df <strtol+0xad>

    if (endptr) {
  103370:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103374:	74 08                	je     10337e <strtol+0x14c>
        *endptr = (char *) s;
  103376:	8b 45 0c             	mov    0xc(%ebp),%eax
  103379:	8b 55 08             	mov    0x8(%ebp),%edx
  10337c:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10337e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  103382:	74 07                	je     10338b <strtol+0x159>
  103384:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103387:	f7 d8                	neg    %eax
  103389:	eb 03                	jmp    10338e <strtol+0x15c>
  10338b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10338e:	c9                   	leave  
  10338f:	c3                   	ret    

00103390 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  103390:	55                   	push   %ebp
  103391:	89 e5                	mov    %esp,%ebp
  103393:	57                   	push   %edi
  103394:	83 ec 24             	sub    $0x24,%esp
  103397:	8b 45 0c             	mov    0xc(%ebp),%eax
  10339a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10339d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1033a1:	8b 55 08             	mov    0x8(%ebp),%edx
  1033a4:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1033a7:	88 45 f7             	mov    %al,-0x9(%ebp)
  1033aa:	8b 45 10             	mov    0x10(%ebp),%eax
  1033ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1033b0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1033b3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1033b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1033ba:	89 d7                	mov    %edx,%edi
  1033bc:	f3 aa                	rep stos %al,%es:(%edi)
  1033be:	89 fa                	mov    %edi,%edx
  1033c0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1033c3:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  1033c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1033c9:	83 c4 24             	add    $0x24,%esp
  1033cc:	5f                   	pop    %edi
  1033cd:	5d                   	pop    %ebp
  1033ce:	c3                   	ret    

001033cf <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1033cf:	55                   	push   %ebp
  1033d0:	89 e5                	mov    %esp,%ebp
  1033d2:	57                   	push   %edi
  1033d3:	56                   	push   %esi
  1033d4:	53                   	push   %ebx
  1033d5:	83 ec 30             	sub    $0x30,%esp
  1033d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1033e4:	8b 45 10             	mov    0x10(%ebp),%eax
  1033e7:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1033ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1033f0:	73 42                	jae    103434 <memmove+0x65>
  1033f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1033f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1033fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103401:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103404:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103407:	c1 e8 02             	shr    $0x2,%eax
  10340a:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  10340c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10340f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103412:	89 d7                	mov    %edx,%edi
  103414:	89 c6                	mov    %eax,%esi
  103416:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  103418:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10341b:	83 e1 03             	and    $0x3,%ecx
  10341e:	74 02                	je     103422 <memmove+0x53>
  103420:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103422:	89 f0                	mov    %esi,%eax
  103424:	89 fa                	mov    %edi,%edx
  103426:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  103429:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10342c:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  10342f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103432:	eb 36                	jmp    10346a <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  103434:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103437:	8d 50 ff             	lea    -0x1(%eax),%edx
  10343a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10343d:	01 c2                	add    %eax,%edx
  10343f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103442:	8d 48 ff             	lea    -0x1(%eax),%ecx
  103445:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103448:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  10344b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10344e:	89 c1                	mov    %eax,%ecx
  103450:	89 d8                	mov    %ebx,%eax
  103452:	89 d6                	mov    %edx,%esi
  103454:	89 c7                	mov    %eax,%edi
  103456:	fd                   	std    
  103457:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103459:	fc                   	cld    
  10345a:	89 f8                	mov    %edi,%eax
  10345c:	89 f2                	mov    %esi,%edx
  10345e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  103461:	89 55 c8             	mov    %edx,-0x38(%ebp)
  103464:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  103467:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10346a:	83 c4 30             	add    $0x30,%esp
  10346d:	5b                   	pop    %ebx
  10346e:	5e                   	pop    %esi
  10346f:	5f                   	pop    %edi
  103470:	5d                   	pop    %ebp
  103471:	c3                   	ret    

00103472 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  103472:	55                   	push   %ebp
  103473:	89 e5                	mov    %esp,%ebp
  103475:	57                   	push   %edi
  103476:	56                   	push   %esi
  103477:	83 ec 20             	sub    $0x20,%esp
  10347a:	8b 45 08             	mov    0x8(%ebp),%eax
  10347d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103480:	8b 45 0c             	mov    0xc(%ebp),%eax
  103483:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103486:	8b 45 10             	mov    0x10(%ebp),%eax
  103489:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10348c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10348f:	c1 e8 02             	shr    $0x2,%eax
  103492:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  103494:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103497:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10349a:	89 d7                	mov    %edx,%edi
  10349c:	89 c6                	mov    %eax,%esi
  10349e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1034a0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1034a3:	83 e1 03             	and    $0x3,%ecx
  1034a6:	74 02                	je     1034aa <memcpy+0x38>
  1034a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1034aa:	89 f0                	mov    %esi,%eax
  1034ac:	89 fa                	mov    %edi,%edx
  1034ae:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1034b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1034b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  1034b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1034ba:	83 c4 20             	add    $0x20,%esp
  1034bd:	5e                   	pop    %esi
  1034be:	5f                   	pop    %edi
  1034bf:	5d                   	pop    %ebp
  1034c0:	c3                   	ret    

001034c1 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1034c1:	55                   	push   %ebp
  1034c2:	89 e5                	mov    %esp,%ebp
  1034c4:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1034c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1034ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1034cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1034d3:	eb 30                	jmp    103505 <memcmp+0x44>
        if (*s1 != *s2) {
  1034d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1034d8:	0f b6 10             	movzbl (%eax),%edx
  1034db:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1034de:	0f b6 00             	movzbl (%eax),%eax
  1034e1:	38 c2                	cmp    %al,%dl
  1034e3:	74 18                	je     1034fd <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1034e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1034e8:	0f b6 00             	movzbl (%eax),%eax
  1034eb:	0f b6 d0             	movzbl %al,%edx
  1034ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1034f1:	0f b6 00             	movzbl (%eax),%eax
  1034f4:	0f b6 c0             	movzbl %al,%eax
  1034f7:	29 c2                	sub    %eax,%edx
  1034f9:	89 d0                	mov    %edx,%eax
  1034fb:	eb 1a                	jmp    103517 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  1034fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  103501:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  103505:	8b 45 10             	mov    0x10(%ebp),%eax
  103508:	8d 50 ff             	lea    -0x1(%eax),%edx
  10350b:	89 55 10             	mov    %edx,0x10(%ebp)
  10350e:	85 c0                	test   %eax,%eax
  103510:	75 c3                	jne    1034d5 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  103512:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103517:	c9                   	leave  
  103518:	c3                   	ret    
