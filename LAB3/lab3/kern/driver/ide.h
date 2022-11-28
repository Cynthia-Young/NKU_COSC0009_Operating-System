#ifndef __KERN_DRIVER_IDE_H__
#define __KERN_DRIVER_IDE_H__

#include <defs.h>
//内存页swap机制所需的磁盘扇区的读写操作支持
void ide_init(void);
bool ide_device_valid(unsigned short ideno);
size_t ide_device_size(unsigned short ideno);

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs);
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs);

#endif /* !__KERN_DRIVER_IDE_H__ */

