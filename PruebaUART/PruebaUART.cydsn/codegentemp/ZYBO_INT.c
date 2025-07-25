/*******************************************************************************
* File Name: ZYBOINT.c
* Version 2.50
*
* Description:
*  This file provides all Interrupt Service functionality of the UART component
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "ZYBO.h"
#include "cyapicallbacks.h"


/***************************************
* Custom Declarations
***************************************/
/* `#START CUSTOM_DECLARATIONS` Place your declaration here */

/* `#END` */

#if (ZYBO_RX_INTERRUPT_ENABLED && (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED))
    /*******************************************************************************
    * Function Name: ZYBO_RXISR
    ********************************************************************************
    *
    * Summary:
    *  Interrupt Service Routine for RX portion of the UART
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_rxBuffer - RAM buffer pointer for save received data.
    *  ZYBO_rxBufferWrite - cyclic index for write to rxBuffer,
    *     increments after each byte saved to buffer.
    *  ZYBO_rxBufferRead - cyclic index for read from rxBuffer,
    *     checked to detect overflow condition.
    *  ZYBO_rxBufferOverflow - software overflow flag. Set to one
    *     when ZYBO_rxBufferWrite index overtakes
    *     ZYBO_rxBufferRead index.
    *  ZYBO_rxBufferLoopDetect - additional variable to detect overflow.
    *     Set to one when ZYBO_rxBufferWrite is equal to
    *    ZYBO_rxBufferRead
    *  ZYBO_rxAddressMode - this variable contains the Address mode,
    *     selected in customizer or set by UART_SetRxAddressMode() API.
    *  ZYBO_rxAddressDetected - set to 1 when correct address received,
    *     and analysed to store following addressed data bytes to the buffer.
    *     When not correct address received, set to 0 to skip following data bytes.
    *
    *******************************************************************************/
    CY_ISR(ZYBO_RXISR)
    {
        uint8 readData;
        uint8 readStatus;
        uint8 increment_pointer = 0u;

    #if(CY_PSOC3)
        uint8 int_en;
    #endif /* (CY_PSOC3) */

    #ifdef ZYBO_RXISR_ENTRY_CALLBACK
        ZYBO_RXISR_EntryCallback();
    #endif /* ZYBO_RXISR_ENTRY_CALLBACK */

        /* User code required at start of ISR */
        /* `#START ZYBO_RXISR_START` */

        /* `#END` */

    #if(CY_PSOC3)   /* Make sure nested interrupt is enabled */
        int_en = EA;
        CyGlobalIntEnable;
    #endif /* (CY_PSOC3) */

        do
        {
            /* Read receiver status register */
            readStatus = ZYBO_RXSTATUS_REG;
            /* Copy the same status to readData variable for backward compatibility support 
            *  of the user code in ZYBO_RXISR_ERROR` section. 
            */
            readData = readStatus;

            if((readStatus & (ZYBO_RX_STS_BREAK | 
                            ZYBO_RX_STS_PAR_ERROR |
                            ZYBO_RX_STS_STOP_ERROR | 
                            ZYBO_RX_STS_OVERRUN)) != 0u)
            {
                /* ERROR handling. */
                ZYBO_errorStatus |= readStatus & ( ZYBO_RX_STS_BREAK | 
                                                            ZYBO_RX_STS_PAR_ERROR | 
                                                            ZYBO_RX_STS_STOP_ERROR | 
                                                            ZYBO_RX_STS_OVERRUN);
                /* `#START ZYBO_RXISR_ERROR` */

                /* `#END` */
                
            #ifdef ZYBO_RXISR_ERROR_CALLBACK
                ZYBO_RXISR_ERROR_Callback();
            #endif /* ZYBO_RXISR_ERROR_CALLBACK */
            }
            
            if((readStatus & ZYBO_RX_STS_FIFO_NOTEMPTY) != 0u)
            {
                /* Read data from the RX data register */
                readData = ZYBO_RXDATA_REG;
            #if (ZYBO_RXHW_ADDRESS_ENABLED)
                if(ZYBO_rxAddressMode == (uint8)ZYBO__B_UART__AM_SW_DETECT_TO_BUFFER)
                {
                    if((readStatus & ZYBO_RX_STS_MRKSPC) != 0u)
                    {
                        if ((readStatus & ZYBO_RX_STS_ADDR_MATCH) != 0u)
                        {
                            ZYBO_rxAddressDetected = 1u;
                        }
                        else
                        {
                            ZYBO_rxAddressDetected = 0u;
                        }
                    }
                    if(ZYBO_rxAddressDetected != 0u)
                    {   /* Store only addressed data */
                        ZYBO_rxBuffer[ZYBO_rxBufferWrite] = readData;
                        increment_pointer = 1u;
                    }
                }
                else /* Without software addressing */
                {
                    ZYBO_rxBuffer[ZYBO_rxBufferWrite] = readData;
                    increment_pointer = 1u;
                }
            #else  /* Without addressing */
                ZYBO_rxBuffer[ZYBO_rxBufferWrite] = readData;
                increment_pointer = 1u;
            #endif /* (ZYBO_RXHW_ADDRESS_ENABLED) */

                /* Do not increment buffer pointer when skip not addressed data */
                if(increment_pointer != 0u)
                {
                    if(ZYBO_rxBufferLoopDetect != 0u)
                    {   /* Set Software Buffer status Overflow */
                        ZYBO_rxBufferOverflow = 1u;
                    }
                    /* Set next pointer. */
                    ZYBO_rxBufferWrite++;

                    /* Check pointer for a loop condition */
                    if(ZYBO_rxBufferWrite >= ZYBO_RX_BUFFER_SIZE)
                    {
                        ZYBO_rxBufferWrite = 0u;
                    }

                    /* Detect pre-overload condition and set flag */
                    if(ZYBO_rxBufferWrite == ZYBO_rxBufferRead)
                    {
                        ZYBO_rxBufferLoopDetect = 1u;
                        /* When Hardware Flow Control selected */
                        #if (ZYBO_FLOW_CONTROL != 0u)
                            /* Disable RX interrupt mask, it is enabled when user read data from the buffer using APIs */
                            ZYBO_RXSTATUS_MASK_REG  &= (uint8)~ZYBO_RX_STS_FIFO_NOTEMPTY;
                            CyIntClearPending(ZYBO_RX_VECT_NUM);
                            break; /* Break the reading of the FIFO loop, leave the data there for generating RTS signal */
                        #endif /* (ZYBO_FLOW_CONTROL != 0u) */
                    }
                }
            }
        }while((readStatus & ZYBO_RX_STS_FIFO_NOTEMPTY) != 0u);

        /* User code required at end of ISR (Optional) */
        /* `#START ZYBO_RXISR_END` */

        /* `#END` */

    #ifdef ZYBO_RXISR_EXIT_CALLBACK
        ZYBO_RXISR_ExitCallback();
    #endif /* ZYBO_RXISR_EXIT_CALLBACK */

    #if(CY_PSOC3)
        EA = int_en;
    #endif /* (CY_PSOC3) */
    }
    
#endif /* (ZYBO_RX_INTERRUPT_ENABLED && (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)) */


#if (ZYBO_TX_INTERRUPT_ENABLED && ZYBO_TX_ENABLED)
    /*******************************************************************************
    * Function Name: ZYBO_TXISR
    ********************************************************************************
    *
    * Summary:
    * Interrupt Service Routine for the TX portion of the UART
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_txBuffer - RAM buffer pointer for transmit data from.
    *  ZYBO_txBufferRead - cyclic index for read and transmit data
    *     from txBuffer, increments after each transmitted byte.
    *  ZYBO_rxBufferWrite - cyclic index for write to txBuffer,
    *     checked to detect available for transmission bytes.
    *
    *******************************************************************************/
    CY_ISR(ZYBO_TXISR)
    {
    #if(CY_PSOC3)
        uint8 int_en;
    #endif /* (CY_PSOC3) */

    #ifdef ZYBO_TXISR_ENTRY_CALLBACK
        ZYBO_TXISR_EntryCallback();
    #endif /* ZYBO_TXISR_ENTRY_CALLBACK */

        /* User code required at start of ISR */
        /* `#START ZYBO_TXISR_START` */

        /* `#END` */

    #if(CY_PSOC3)   /* Make sure nested interrupt is enabled */
        int_en = EA;
        CyGlobalIntEnable;
    #endif /* (CY_PSOC3) */

        while((ZYBO_txBufferRead != ZYBO_txBufferWrite) &&
             ((ZYBO_TXSTATUS_REG & ZYBO_TX_STS_FIFO_FULL) == 0u))
        {
            /* Check pointer wrap around */
            if(ZYBO_txBufferRead >= ZYBO_TX_BUFFER_SIZE)
            {
                ZYBO_txBufferRead = 0u;
            }

            ZYBO_TXDATA_REG = ZYBO_txBuffer[ZYBO_txBufferRead];

            /* Set next pointer */
            ZYBO_txBufferRead++;
        }

        /* User code required at end of ISR (Optional) */
        /* `#START ZYBO_TXISR_END` */

        /* `#END` */

    #ifdef ZYBO_TXISR_EXIT_CALLBACK
        ZYBO_TXISR_ExitCallback();
    #endif /* ZYBO_TXISR_EXIT_CALLBACK */

    #if(CY_PSOC3)
        EA = int_en;
    #endif /* (CY_PSOC3) */
   }
#endif /* (ZYBO_TX_INTERRUPT_ENABLED && ZYBO_TX_ENABLED) */


/* [] END OF FILE */
