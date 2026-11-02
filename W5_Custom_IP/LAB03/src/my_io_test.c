#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define MY_IO_BASE   XPAR_MY_IO_0_BASEADDR   /* Address Editor 에서 본 my_io_0 의 주소 */

/* my_io 레지스터 맵 - 우리가 직접 정했다 (1.2절) */
#define REG_LED4     (MY_IO_BASE + 0x0)      /* 쓰기: shield LED  [3:0] */
#define REG_LED3     (MY_IO_BASE + 0x4)      /* 쓰기: RGB LED1    [2:0] */
#define REG_SW4      (MY_IO_BASE + 0x8)      /* 읽기: shield 스위치 [3:0] */
#define REG_BTN2     (MY_IO_BASE + 0xC)      /* 읽기: BTN0, BTN1  [1:0] */

int main(void)
{
    u32 sw, btn;

    print("my_io start\n\r");

    while (1) {
        sw  = Xil_In32(REG_SW4);
        btn = Xil_In32(REG_BTN2);

        Xil_Out32(REG_LED4, sw);    /* 스위치 -> shield LED */
        Xil_Out32(REG_LED3, btn);   /* BTN0 -> R, BTN1 -> G */

        xil_printf("sw = %d  btn = %d\n\r", sw, btn);
        usleep(200000);
    }

    return 0;
}
