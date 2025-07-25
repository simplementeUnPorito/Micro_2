#include "project.h"

// Banderas globales
volatile uint8_t flag_change_bps = 0;
volatile uint8_t flag_rx_from_pc = 0;
volatile uint8_t flag_rx_from_zybo = 0;
uint8_t LED_STATE = 0;

#define toggleLED   LED_STATE = ~LED_STATE; LED_Write(LED_STATE);   

CY_ISR(isrRxPC_Handler) {
    flag_rx_from_pc = 1;
    isrRxPC_ClearPending();
}

CY_ISR(isrRxZYBO_Handler) {
    flag_rx_from_zybo = 1;
    isrRxZYBO_ClearPending();
}

int main(void)
{
    CyGlobalIntEnable;

    // Inicialización UARTs
    PC_Start();
    ZYBO_Start();

    // Configurar velocidad inicial
    LED_Write(LED_STATE);

    // ISRs
    isrRxPC_StartEx(isrRxPC_Handler);
    isrRxZYBO_StartEx(isrRxZYBO_Handler);

    for(;;)
    {
        // Redirigir datos de PC -> Zybo
        if (flag_rx_from_pc) {
            flag_rx_from_pc = 0;
            toggleLED;
            while (PC_GetRxBufferSize() > 0)
                ZYBO_PutChar(PC_GetChar());
        }

        // Redirigir datos de Zybo -> PC
        if (flag_rx_from_zybo) {
            flag_rx_from_zybo = 0;
            toggleLED;
            while (ZYBO_GetRxBufferSize() > 0)
                PC_PutChar(ZYBO_GetChar());
        }
    }
}
