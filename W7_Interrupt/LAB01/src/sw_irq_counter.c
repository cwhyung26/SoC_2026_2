#include "xparameters.h"
#include "xil_io.h"
#include "xinterrupt_wrap.h"   /* XSetupInterruptSystem */
#include "xil_printf.h"

#define GPIO_BASE    XPAR_AXI_GPIO_0_BASEADDR   /* Address Editor 에서 본 axi_gpio_0 의 주소 */

/* AXI GPIO 레지스터 맵 - 1장 1.10절 (PG144) */
#define GPIO_DATA    (GPIO_BASE + 0x000)        /* 채널 1 = sw4  (읽기)            */
#define GPIO2_DATA   (GPIO_BASE + 0x008)        /* 채널 2 = led4 (쓰기)            */
#define GPIO_GIER    (GPIO_BASE + 0x11C)        /* bit 31 = IP 전체 인터럽트 허용  */
#define GPIO_IPISR   (GPIO_BASE + 0x120)        /* bit 0  = 채널 1 pending         */
#define GPIO_IPIER   (GPIO_BASE + 0x128)        /* bit 0  = 채널 1 인터럽트 허용   */

/* ISR 과 main 이 함께 쓰므로 셋 다 volatile */
volatile int flag  = 0;   /* 인터럽트가 생겼다는 표시 */
volatile int count = 0;   /* 4비트 카운터, 0~15       */
volatile int sw    = 0;   /* 그 순간의 스위치 값      */

/* sw4 가 바뀔 때마다 하드웨어가 부른다. 짧게 끝낸다. */
void sw_isr(void *ref)
{
    sw    = Xil_In32(GPIO_DATA);
    count = (count + 1) & 0xF;
    flag  = 1;

    Xil_Out32(GPIO_IPISR, Xil_In32(GPIO_IPISR));   /* pending 지우기 - 꼭 한다 */
}

int main(void)
{
    print("W7 LAB01: AXI GPIO interrupt start\n\r");

    Xil_Out32(GPIO_IPISR, Xil_In32(GPIO_IPISR));   /* (1) 남아 있던 pending 지우기 */

    XSetupInterruptSystem(NULL, (void *)sw_isr,    /* (2) "이 인터럽트가 오면 sw_isr" */
                          XPAR_AXI_GPIO_0_INTERRUPTS,
                          XPAR_AXI_GPIO_0_INTERRUPT_PARENT,
                          XINTERRUPT_DEFAULT_PRIORITY);

    Xil_Out32(GPIO_IPIER, 0x1);                    /* (3) 채널 1 허용 (개별 문) */
    Xil_Out32(GPIO_GIER,  0x80000000);             /* (4) IP 전체 허용 (대문)   */

    while (1) {
        if (flag == 1) {
            flag = 0;
            Xil_Out32(GPIO2_DATA, count);          /* 카운터 -> LED 4개 */
            xil_printf("count = %2d, sw = %d\n\r", count, sw);
        }
    }

    return 0;
}
