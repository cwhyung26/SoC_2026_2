#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define PWM_BASE     XPAR_MY_PWM_0_BASEADDR   /* Address Editor 에서 본 my_pwm_0 의 주소 */

/* my_pwm 레지스터 맵 - 1장 1.3절에서 정했다 */
#define PWM_CTRL     (PWM_BASE + 0x0)         /* 1 = 동작, 0 = 정지          */
#define PWM_PERIOD   (PWM_BASE + 0x4)         /* 한 주기의 길이 (클럭 수)     */
#define PWM_DUTY     (PWM_BASE + 0x8)         /* 한 주기 중 켜진 시간 (클럭 수) */

#define PERIOD       50000                    /* 50000 클럭 = 1 ms (1 kHz)
                                                 ILA로 볼 때는 200 (4 us) 으로 바꾼다 */

int main(void)
{
    print("my_pwm start\n\r");

    Xil_Out32(PWM_PERIOD, PERIOD);            /* 주기 정하기 */
    Xil_Out32(PWM_DUTY, 0);                   /* 처음에는 꺼진 상태 */
    Xil_Out32(PWM_CTRL, 1);                   /* PWM 시작 */

    while (1) {
        Xil_Out32(PWM_DUTY, 0);               /*   0 % : 꺼짐 */
        print("duty   0 %\n\r");
        sleep(1);

        Xil_Out32(PWM_DUTY, PERIOD / 4);      /*  25 % */
        print("duty  25 %\n\r");
        sleep(1);

        Xil_Out32(PWM_DUTY, PERIOD / 2);      /*  50 % */
        print("duty  50 %\n\r");
        sleep(1);

        Xil_Out32(PWM_DUTY, PERIOD * 3 / 4);  /*  75 % */
        print("duty  75 %\n\r");
        sleep(1);

        Xil_Out32(PWM_DUTY, PERIOD);          /* 100 % : 계속 켜짐 */
        print("duty 100 %\n\r");
        sleep(1);
    }

    return 0;
}
