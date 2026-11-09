#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define PWM_BASE     XPAR_MY_PWM_0_BASEADDR   /* Address Editor 에서 본 my_pwm_0 의 주소 */

/* my_pwm 레지스터 맵 - 1장 1.3절에서 정했다 */
#define PWM_CTRL     (PWM_BASE + 0x0)         /* 1 = 동작, 0 = 정지          */
#define PWM_PERIOD   (PWM_BASE + 0x4)         /* 한 주기의 길이 (클럭 수)     */
#define PWM_DUTY     (PWM_BASE + 0x8)         /* 한 주기 중 켜진 시간 (클럭 수) */

#define PERIOD       50000                    /* 50000 클럭 = 1 ms (1 kHz) */
#define STEP         500                      /* 한 번에 바꾸는 duty (1 %)   */

int main(void)
{
    u32 duty;

    print("my_pwm fade start\n\r");

    Xil_Out32(PWM_PERIOD, PERIOD);
    Xil_Out32(PWM_DUTY, 0);
    Xil_Out32(PWM_CTRL, 1);

    while (1) {
        /* 점점 밝게 : duty 0 -> PERIOD, 1 % 씩 100 번, 10 ms 씩 = 1 초 */
        for (duty = 0; duty <= PERIOD; duty = duty + STEP) {
            Xil_Out32(PWM_DUTY, duty);
            usleep(10000);
        }

        /* 점점 어둡게 : duty PERIOD -> 0 */
        for (duty = PERIOD; duty > 0; duty = duty - STEP) {
            Xil_Out32(PWM_DUTY, duty);
            usleep(10000);
        }
    }

    return 0;
}
