#include <unistd.h>

int main(void)
{
    char msg[] = "hello, world!\n";
    write(1, msg, sizeof(msg)-1);
    sleep(1);

    return 0;
}
