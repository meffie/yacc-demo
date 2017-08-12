#include <stdio.h>
int enable_debug = 0;

void debug(char *msg)
{
    if (enable_debug) {
        printf("%s\n", msg);
    }
}

void debug1(char *msg, char ch)
{
    if (enable_debug) {
        printf("%s='%c'\n", msg, ch);
    }
}
