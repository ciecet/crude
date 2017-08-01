#include <stdio.h>
#include <stdarg.h>
#include "log.h"

void log_info (const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vprintf(fmt, args);
    va_end(args);
}
