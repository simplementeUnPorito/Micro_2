/*******************************************************************************
* File Name: ZYBO.c
* Version 2.50
*
* Description:
*  This file provides all API functionality of the UART component
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "ZYBO.h"
#if (ZYBO_INTERNAL_CLOCK_USED)
    #include "ZYBO_IntClock.h"
#endif /* End ZYBO_INTERNAL_CLOCK_USED */


/***************************************
* Global data allocation
***************************************/

uint8 ZYBO_initVar = 0u;

#if (ZYBO_TX_INTERRUPT_ENABLED && ZYBO_TX_ENABLED)
    volatile uint8 ZYBO_txBuffer[ZYBO_TX_BUFFER_SIZE];
    volatile uint8 ZYBO_txBufferRead = 0u;
    uint8 ZYBO_txBufferWrite = 0u;
#endif /* (ZYBO_TX_INTERRUPT_ENABLED && ZYBO_TX_ENABLED) */

#if (ZYBO_RX_INTERRUPT_ENABLED && (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED))
    uint8 ZYBO_errorStatus = 0u;
    volatile uint8 ZYBO_rxBuffer[ZYBO_RX_BUFFER_SIZE];
    volatile uint8 ZYBO_rxBufferRead  = 0u;
    volatile uint8 ZYBO_rxBufferWrite = 0u;
    volatile uint8 ZYBO_rxBufferLoopDetect = 0u;
    volatile uint8 ZYBO_rxBufferOverflow   = 0u;
    #if (ZYBO_RXHW_ADDRESS_ENABLED)
        volatile uint8 ZYBO_rxAddressMode = ZYBO_RX_ADDRESS_MODE;
        volatile uint8 ZYBO_rxAddressDetected = 0u;
    #endif /* (ZYBO_RXHW_ADDRESS_ENABLED) */
#endif /* (ZYBO_RX_INTERRUPT_ENABLED && (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)) */


/*******************************************************************************
* Function Name: ZYBO_Start
********************************************************************************
*
* Summary:
*  This is the preferred method to begin component operation.
*  ZYBO_Start() sets the initVar variable, calls the
*  ZYBO_Init() function, and then calls the
*  ZYBO_Enable() function.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  The ZYBO_intiVar variable is used to indicate initial
*  configuration of this component. The variable is initialized to zero (0u)
*  and set to one (1u) the first time ZYBO_Start() is called. This
*  allows for component initialization without re-initialization in all
*  subsequent calls to the ZYBO_Start() routine.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void ZYBO_Start(void) 
{
    /* If not initialized then initialize all required hardware and software */
    if(ZYBO_initVar == 0u)
    {
        ZYBO_Init();
        ZYBO_initVar = 1u;
    }

    ZYBO_Enable();
}


/*******************************************************************************
* Function Name: ZYBO_Init
********************************************************************************
*
* Summary:
*  Initializes or restores the component according to the customizer Configure
*  dialog settings. It is not necessary to call ZYBO_Init() because
*  the ZYBO_Start() API calls this function and is the preferred
*  method to begin component operation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void ZYBO_Init(void) 
{
    #if(ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)

        #if (ZYBO_RX_INTERRUPT_ENABLED)
            /* Set RX interrupt vector and priority */
            (void) CyIntSetVector(ZYBO_RX_VECT_NUM, &ZYBO_RXISR);
            CyIntSetPriority(ZYBO_RX_VECT_NUM, ZYBO_RX_PRIOR_NUM);
            ZYBO_errorStatus = 0u;
        #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

        #if (ZYBO_RXHW_ADDRESS_ENABLED)
            ZYBO_SetRxAddressMode(ZYBO_RX_ADDRESS_MODE);
            ZYBO_SetRxAddress1(ZYBO_RX_HW_ADDRESS1);
            ZYBO_SetRxAddress2(ZYBO_RX_HW_ADDRESS2);
        #endif /* End ZYBO_RXHW_ADDRESS_ENABLED */

        /* Init Count7 period */
        ZYBO_RXBITCTR_PERIOD_REG = ZYBO_RXBITCTR_INIT;
        /* Configure the Initial RX interrupt mask */
        ZYBO_RXSTATUS_MASK_REG  = ZYBO_INIT_RX_INTERRUPTS_MASK;
    #endif /* End ZYBO_RX_ENABLED || ZYBO_HD_ENABLED*/

    #if(ZYBO_TX_ENABLED)
        #if (ZYBO_TX_INTERRUPT_ENABLED)
            /* Set TX interrupt vector and priority */
            (void) CyIntSetVector(ZYBO_TX_VECT_NUM, &ZYBO_TXISR);
            CyIntSetPriority(ZYBO_TX_VECT_NUM, ZYBO_TX_PRIOR_NUM);
        #endif /* (ZYBO_TX_INTERRUPT_ENABLED) */

        /* Write Counter Value for TX Bit Clk Generator*/
        #if (ZYBO_TXCLKGEN_DP)
            ZYBO_TXBITCLKGEN_CTR_REG = ZYBO_BIT_CENTER;
            ZYBO_TXBITCLKTX_COMPLETE_REG = ((ZYBO_NUMBER_OF_DATA_BITS +
                        ZYBO_NUMBER_OF_START_BIT) * ZYBO_OVER_SAMPLE_COUNT) - 1u;
        #else
            ZYBO_TXBITCTR_PERIOD_REG = ((ZYBO_NUMBER_OF_DATA_BITS +
                        ZYBO_NUMBER_OF_START_BIT) * ZYBO_OVER_SAMPLE_8) - 1u;
        #endif /* End ZYBO_TXCLKGEN_DP */

        /* Configure the Initial TX interrupt mask */
        #if (ZYBO_TX_INTERRUPT_ENABLED)
            ZYBO_TXSTATUS_MASK_REG = ZYBO_TX_STS_FIFO_EMPTY;
        #else
            ZYBO_TXSTATUS_MASK_REG = ZYBO_INIT_TX_INTERRUPTS_MASK;
        #endif /*End ZYBO_TX_INTERRUPT_ENABLED*/

    #endif /* End ZYBO_TX_ENABLED */

    #if(ZYBO_PARITY_TYPE_SW)  /* Write Parity to Control Register */
        ZYBO_WriteControlRegister( \
            (ZYBO_ReadControlRegister() & (uint8)~ZYBO_CTRL_PARITY_TYPE_MASK) | \
            (uint8)(ZYBO_PARITY_TYPE << ZYBO_CTRL_PARITY_TYPE0_SHIFT) );
    #endif /* End ZYBO_PARITY_TYPE_SW */
}


/*******************************************************************************
* Function Name: ZYBO_Enable
********************************************************************************
*
* Summary:
*  Activates the hardware and begins component operation. It is not necessary
*  to call ZYBO_Enable() because the ZYBO_Start() API
*  calls this function, which is the preferred method to begin component
*  operation.

* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  ZYBO_rxAddressDetected - set to initial state (0).
*
*******************************************************************************/
void ZYBO_Enable(void) 
{
    uint8 enableInterrupts;
    enableInterrupts = CyEnterCriticalSection();

    #if (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)
        /* RX Counter (Count7) Enable */
        ZYBO_RXBITCTR_CONTROL_REG |= ZYBO_CNTR_ENABLE;

        /* Enable the RX Interrupt */
        ZYBO_RXSTATUS_ACTL_REG  |= ZYBO_INT_ENABLE;

        #if (ZYBO_RX_INTERRUPT_ENABLED)
            ZYBO_EnableRxInt();

            #if (ZYBO_RXHW_ADDRESS_ENABLED)
                ZYBO_rxAddressDetected = 0u;
            #endif /* (ZYBO_RXHW_ADDRESS_ENABLED) */
        #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */
    #endif /* (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED) */

    #if(ZYBO_TX_ENABLED)
        /* TX Counter (DP/Count7) Enable */
        #if(!ZYBO_TXCLKGEN_DP)
            ZYBO_TXBITCTR_CONTROL_REG |= ZYBO_CNTR_ENABLE;
        #endif /* End ZYBO_TXCLKGEN_DP */

        /* Enable the TX Interrupt */
        ZYBO_TXSTATUS_ACTL_REG |= ZYBO_INT_ENABLE;
        #if (ZYBO_TX_INTERRUPT_ENABLED)
            ZYBO_ClearPendingTxInt(); /* Clear history of TX_NOT_EMPTY */
            ZYBO_EnableTxInt();
        #endif /* (ZYBO_TX_INTERRUPT_ENABLED) */
     #endif /* (ZYBO_TX_INTERRUPT_ENABLED) */

    #if (ZYBO_INTERNAL_CLOCK_USED)
        ZYBO_IntClock_Start();  /* Enable the clock */
    #endif /* (ZYBO_INTERNAL_CLOCK_USED) */

    CyExitCriticalSection(enableInterrupts);
}


/*******************************************************************************
* Function Name: ZYBO_Stop
********************************************************************************
*
* Summary:
*  Disables the UART operation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void ZYBO_Stop(void) 
{
    uint8 enableInterrupts;
    enableInterrupts = CyEnterCriticalSection();

    /* Write Bit Counter Disable */
    #if (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)
        ZYBO_RXBITCTR_CONTROL_REG &= (uint8) ~ZYBO_CNTR_ENABLE;
    #endif /* (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED) */

    #if (ZYBO_TX_ENABLED)
        #if(!ZYBO_TXCLKGEN_DP)
            ZYBO_TXBITCTR_CONTROL_REG &= (uint8) ~ZYBO_CNTR_ENABLE;
        #endif /* (!ZYBO_TXCLKGEN_DP) */
    #endif /* (ZYBO_TX_ENABLED) */

    #if (ZYBO_INTERNAL_CLOCK_USED)
        ZYBO_IntClock_Stop();   /* Disable the clock */
    #endif /* (ZYBO_INTERNAL_CLOCK_USED) */

    /* Disable internal interrupt component */
    #if (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)
        ZYBO_RXSTATUS_ACTL_REG  &= (uint8) ~ZYBO_INT_ENABLE;

        #if (ZYBO_RX_INTERRUPT_ENABLED)
            ZYBO_DisableRxInt();
        #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */
    #endif /* (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED) */

    #if (ZYBO_TX_ENABLED)
        ZYBO_TXSTATUS_ACTL_REG &= (uint8) ~ZYBO_INT_ENABLE;

        #if (ZYBO_TX_INTERRUPT_ENABLED)
            ZYBO_DisableTxInt();
        #endif /* (ZYBO_TX_INTERRUPT_ENABLED) */
    #endif /* (ZYBO_TX_ENABLED) */

    CyExitCriticalSection(enableInterrupts);
}


/*******************************************************************************
* Function Name: ZYBO_ReadControlRegister
********************************************************************************
*
* Summary:
*  Returns the current value of the control register.
*
* Parameters:
*  None.
*
* Return:
*  Contents of the control register.
*
*******************************************************************************/
uint8 ZYBO_ReadControlRegister(void) 
{
    #if (ZYBO_CONTROL_REG_REMOVED)
        return(0u);
    #else
        return(ZYBO_CONTROL_REG);
    #endif /* (ZYBO_CONTROL_REG_REMOVED) */
}


/*******************************************************************************
* Function Name: ZYBO_WriteControlRegister
********************************************************************************
*
* Summary:
*  Writes an 8-bit value into the control register
*
* Parameters:
*  control:  control register value
*
* Return:
*  None.
*
*******************************************************************************/
void  ZYBO_WriteControlRegister(uint8 control) 
{
    #if (ZYBO_CONTROL_REG_REMOVED)
        if(0u != control)
        {
            /* Suppress compiler warning */
        }
    #else
       ZYBO_CONTROL_REG = control;
    #endif /* (ZYBO_CONTROL_REG_REMOVED) */
}


#if(ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)
    /*******************************************************************************
    * Function Name: ZYBO_SetRxInterruptMode
    ********************************************************************************
    *
    * Summary:
    *  Configures the RX interrupt sources enabled.
    *
    * Parameters:
    *  IntSrc:  Bit field containing the RX interrupts to enable. Based on the 
    *  bit-field arrangement of the status register. This value must be a 
    *  combination of status register bit-masks shown below:
    *      ZYBO_RX_STS_FIFO_NOTEMPTY    Interrupt on byte received.
    *      ZYBO_RX_STS_PAR_ERROR        Interrupt on parity error.
    *      ZYBO_RX_STS_STOP_ERROR       Interrupt on stop error.
    *      ZYBO_RX_STS_BREAK            Interrupt on break.
    *      ZYBO_RX_STS_OVERRUN          Interrupt on overrun error.
    *      ZYBO_RX_STS_ADDR_MATCH       Interrupt on address match.
    *      ZYBO_RX_STS_MRKSPC           Interrupt on address detect.
    *
    * Return:
    *  None.
    *
    * Theory:
    *  Enables the output of specific status bits to the interrupt controller
    *
    *******************************************************************************/
    void ZYBO_SetRxInterruptMode(uint8 intSrc) 
    {
        ZYBO_RXSTATUS_MASK_REG  = intSrc;
    }


    /*******************************************************************************
    * Function Name: ZYBO_ReadRxData
    ********************************************************************************
    *
    * Summary:
    *  Returns the next byte of received data. This function returns data without
    *  checking the status. You must check the status separately.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  Received data from RX register
    *
    * Global Variables:
    *  ZYBO_rxBuffer - RAM buffer pointer for save received data.
    *  ZYBO_rxBufferWrite - cyclic index for write to rxBuffer,
    *     checked to identify new data.
    *  ZYBO_rxBufferRead - cyclic index for read from rxBuffer,
    *     incremented after each byte has been read from buffer.
    *  ZYBO_rxBufferLoopDetect - cleared if loop condition was detected
    *     in RX ISR.
    *
    * Reentrant:
    *  No.
    *
    *******************************************************************************/
    uint8 ZYBO_ReadRxData(void) 
    {
        uint8 rxData;

    #if (ZYBO_RX_INTERRUPT_ENABLED)

        uint8 locRxBufferRead;
        uint8 locRxBufferWrite;

        /* Protect variables that could change on interrupt */
        ZYBO_DisableRxInt();

        locRxBufferRead  = ZYBO_rxBufferRead;
        locRxBufferWrite = ZYBO_rxBufferWrite;

        if( (ZYBO_rxBufferLoopDetect != 0u) || (locRxBufferRead != locRxBufferWrite) )
        {
            rxData = ZYBO_rxBuffer[locRxBufferRead];
            locRxBufferRead++;

            if(locRxBufferRead >= ZYBO_RX_BUFFER_SIZE)
            {
                locRxBufferRead = 0u;
            }
            /* Update the real pointer */
            ZYBO_rxBufferRead = locRxBufferRead;

            if(ZYBO_rxBufferLoopDetect != 0u)
            {
                ZYBO_rxBufferLoopDetect = 0u;
                #if ((ZYBO_RX_INTERRUPT_ENABLED) && (ZYBO_FLOW_CONTROL != 0u))
                    /* When Hardware Flow Control selected - return RX mask */
                    #if( ZYBO_HD_ENABLED )
                        if((ZYBO_CONTROL_REG & ZYBO_CTRL_HD_SEND) == 0u)
                        {   /* In Half duplex mode return RX mask only in RX
                            *  configuration set, otherwise
                            *  mask will be returned in LoadRxConfig() API.
                            */
                            ZYBO_RXSTATUS_MASK_REG  |= ZYBO_RX_STS_FIFO_NOTEMPTY;
                        }
                    #else
                        ZYBO_RXSTATUS_MASK_REG  |= ZYBO_RX_STS_FIFO_NOTEMPTY;
                    #endif /* end ZYBO_HD_ENABLED */
                #endif /* ((ZYBO_RX_INTERRUPT_ENABLED) && (ZYBO_FLOW_CONTROL != 0u)) */
            }
        }
        else
        {   /* Needs to check status for RX_STS_FIFO_NOTEMPTY bit */
            rxData = ZYBO_RXDATA_REG;
        }

        ZYBO_EnableRxInt();

    #else

        /* Needs to check status for RX_STS_FIFO_NOTEMPTY bit */
        rxData = ZYBO_RXDATA_REG;

    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

        return(rxData);
    }


    /*******************************************************************************
    * Function Name: ZYBO_ReadRxStatus
    ********************************************************************************
    *
    * Summary:
    *  Returns the current state of the receiver status register and the software
    *  buffer overflow status.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  Current state of the status register.
    *
    * Side Effect:
    *  All status register bits are clear-on-read except
    *  ZYBO_RX_STS_FIFO_NOTEMPTY.
    *  ZYBO_RX_STS_FIFO_NOTEMPTY clears immediately after RX data
    *  register read.
    *
    * Global Variables:
    *  ZYBO_rxBufferOverflow - used to indicate overload condition.
    *   It set to one in RX interrupt when there isn't free space in
    *   ZYBO_rxBufferRead to write new data. This condition returned
    *   and cleared to zero by this API as an
    *   ZYBO_RX_STS_SOFT_BUFF_OVER bit along with RX Status register
    *   bits.
    *
    *******************************************************************************/
    uint8 ZYBO_ReadRxStatus(void) 
    {
        uint8 status;

        status = ZYBO_RXSTATUS_REG & ZYBO_RX_HW_MASK;

    #if (ZYBO_RX_INTERRUPT_ENABLED)
        if(ZYBO_rxBufferOverflow != 0u)
        {
            status |= ZYBO_RX_STS_SOFT_BUFF_OVER;
            ZYBO_rxBufferOverflow = 0u;
        }
    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

        return(status);
    }


    /*******************************************************************************
    * Function Name: ZYBO_GetChar
    ********************************************************************************
    *
    * Summary:
    *  Returns the last received byte of data. ZYBO_GetChar() is
    *  designed for ASCII characters and returns a uint8 where 1 to 255 are values
    *  for valid characters and 0 indicates an error occurred or no data is present.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  Character read from UART RX buffer. ASCII characters from 1 to 255 are valid.
    *  A returned zero signifies an error condition or no data available.
    *
    * Global Variables:
    *  ZYBO_rxBuffer - RAM buffer pointer for save received data.
    *  ZYBO_rxBufferWrite - cyclic index for write to rxBuffer,
    *     checked to identify new data.
    *  ZYBO_rxBufferRead - cyclic index for read from rxBuffer,
    *     incremented after each byte has been read from buffer.
    *  ZYBO_rxBufferLoopDetect - cleared if loop condition was detected
    *     in RX ISR.
    *
    * Reentrant:
    *  No.
    *
    *******************************************************************************/
    uint8 ZYBO_GetChar(void) 
    {
        uint8 rxData = 0u;
        uint8 rxStatus;

    #if (ZYBO_RX_INTERRUPT_ENABLED)
        uint8 locRxBufferRead;
        uint8 locRxBufferWrite;

        /* Protect variables that could change on interrupt */
        ZYBO_DisableRxInt();

        locRxBufferRead  = ZYBO_rxBufferRead;
        locRxBufferWrite = ZYBO_rxBufferWrite;

        if( (ZYBO_rxBufferLoopDetect != 0u) || (locRxBufferRead != locRxBufferWrite) )
        {
            rxData = ZYBO_rxBuffer[locRxBufferRead];
            locRxBufferRead++;
            if(locRxBufferRead >= ZYBO_RX_BUFFER_SIZE)
            {
                locRxBufferRead = 0u;
            }
            /* Update the real pointer */
            ZYBO_rxBufferRead = locRxBufferRead;

            if(ZYBO_rxBufferLoopDetect != 0u)
            {
                ZYBO_rxBufferLoopDetect = 0u;
                #if( (ZYBO_RX_INTERRUPT_ENABLED) && (ZYBO_FLOW_CONTROL != 0u) )
                    /* When Hardware Flow Control selected - return RX mask */
                    #if( ZYBO_HD_ENABLED )
                        if((ZYBO_CONTROL_REG & ZYBO_CTRL_HD_SEND) == 0u)
                        {   /* In Half duplex mode return RX mask only if
                            *  RX configuration set, otherwise
                            *  mask will be returned in LoadRxConfig() API.
                            */
                            ZYBO_RXSTATUS_MASK_REG |= ZYBO_RX_STS_FIFO_NOTEMPTY;
                        }
                    #else
                        ZYBO_RXSTATUS_MASK_REG |= ZYBO_RX_STS_FIFO_NOTEMPTY;
                    #endif /* end ZYBO_HD_ENABLED */
                #endif /* ZYBO_RX_INTERRUPT_ENABLED and Hardware flow control*/
            }

        }
        else
        {   rxStatus = ZYBO_RXSTATUS_REG;
            if((rxStatus & ZYBO_RX_STS_FIFO_NOTEMPTY) != 0u)
            {   /* Read received data from FIFO */
                rxData = ZYBO_RXDATA_REG;
                /*Check status on error*/
                if((rxStatus & (ZYBO_RX_STS_BREAK | ZYBO_RX_STS_PAR_ERROR |
                                ZYBO_RX_STS_STOP_ERROR | ZYBO_RX_STS_OVERRUN)) != 0u)
                {
                    rxData = 0u;
                }
            }
        }

        ZYBO_EnableRxInt();

    #else

        rxStatus =ZYBO_RXSTATUS_REG;
        if((rxStatus & ZYBO_RX_STS_FIFO_NOTEMPTY) != 0u)
        {
            /* Read received data from FIFO */
            rxData = ZYBO_RXDATA_REG;

            /*Check status on error*/
            if((rxStatus & (ZYBO_RX_STS_BREAK | ZYBO_RX_STS_PAR_ERROR |
                            ZYBO_RX_STS_STOP_ERROR | ZYBO_RX_STS_OVERRUN)) != 0u)
            {
                rxData = 0u;
            }
        }
    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

        return(rxData);
    }


    /*******************************************************************************
    * Function Name: ZYBO_GetByte
    ********************************************************************************
    *
    * Summary:
    *  Reads UART RX buffer immediately, returns received character and error
    *  condition.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  MSB contains status and LSB contains UART RX data. If the MSB is nonzero,
    *  an error has occurred.
    *
    * Reentrant:
    *  No.
    *
    *******************************************************************************/
    uint16 ZYBO_GetByte(void) 
    {
        
    #if (ZYBO_RX_INTERRUPT_ENABLED)
        uint16 locErrorStatus;
        /* Protect variables that could change on interrupt */
        ZYBO_DisableRxInt();
        locErrorStatus = (uint16)ZYBO_errorStatus;
        ZYBO_errorStatus = 0u;
        ZYBO_EnableRxInt();
        return ( (uint16)(locErrorStatus << 8u) | ZYBO_ReadRxData() );
    #else
        return ( ((uint16)ZYBO_ReadRxStatus() << 8u) | ZYBO_ReadRxData() );
    #endif /* ZYBO_RX_INTERRUPT_ENABLED */
        
    }


    /*******************************************************************************
    * Function Name: ZYBO_GetRxBufferSize
    ********************************************************************************
    *
    * Summary:
    *  Returns the number of received bytes available in the RX buffer.
    *  * RX software buffer is disabled (RX Buffer Size parameter is equal to 4): 
    *    returns 0 for empty RX FIFO or 1 for not empty RX FIFO.
    *  * RX software buffer is enabled: returns the number of bytes available in 
    *    the RX software buffer. Bytes available in the RX FIFO do not take to 
    *    account.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  uint8: Number of bytes in the RX buffer. 
    *    Return value type depends on RX Buffer Size parameter.
    *
    * Global Variables:
    *  ZYBO_rxBufferWrite - used to calculate left bytes.
    *  ZYBO_rxBufferRead - used to calculate left bytes.
    *  ZYBO_rxBufferLoopDetect - checked to decide left bytes amount.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  Allows the user to find out how full the RX Buffer is.
    *
    *******************************************************************************/
    uint8 ZYBO_GetRxBufferSize(void)
                                                            
    {
        uint8 size;

    #if (ZYBO_RX_INTERRUPT_ENABLED)

        /* Protect variables that could change on interrupt */
        ZYBO_DisableRxInt();

        if(ZYBO_rxBufferRead == ZYBO_rxBufferWrite)
        {
            if(ZYBO_rxBufferLoopDetect != 0u)
            {
                size = ZYBO_RX_BUFFER_SIZE;
            }
            else
            {
                size = 0u;
            }
        }
        else if(ZYBO_rxBufferRead < ZYBO_rxBufferWrite)
        {
            size = (ZYBO_rxBufferWrite - ZYBO_rxBufferRead);
        }
        else
        {
            size = (ZYBO_RX_BUFFER_SIZE - ZYBO_rxBufferRead) + ZYBO_rxBufferWrite;
        }

        ZYBO_EnableRxInt();

    #else

        /* We can only know if there is data in the fifo. */
        size = ((ZYBO_RXSTATUS_REG & ZYBO_RX_STS_FIFO_NOTEMPTY) != 0u) ? 1u : 0u;

    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

        return(size);
    }


    /*******************************************************************************
    * Function Name: ZYBO_ClearRxBuffer
    ********************************************************************************
    *
    * Summary:
    *  Clears the receiver memory buffer and hardware RX FIFO of all received data.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_rxBufferWrite - cleared to zero.
    *  ZYBO_rxBufferRead - cleared to zero.
    *  ZYBO_rxBufferLoopDetect - cleared to zero.
    *  ZYBO_rxBufferOverflow - cleared to zero.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  Setting the pointers to zero makes the system believe there is no data to
    *  read and writing will resume at address 0 overwriting any data that may
    *  have remained in the RAM.
    *
    * Side Effects:
    *  Any received data not read from the RAM or FIFO buffer will be lost.
    *
    *******************************************************************************/
    void ZYBO_ClearRxBuffer(void) 
    {
        uint8 enableInterrupts;

        /* Clear the HW FIFO */
        enableInterrupts = CyEnterCriticalSection();
        ZYBO_RXDATA_AUX_CTL_REG |= (uint8)  ZYBO_RX_FIFO_CLR;
        ZYBO_RXDATA_AUX_CTL_REG &= (uint8) ~ZYBO_RX_FIFO_CLR;
        CyExitCriticalSection(enableInterrupts);

    #if (ZYBO_RX_INTERRUPT_ENABLED)

        /* Protect variables that could change on interrupt. */
        ZYBO_DisableRxInt();

        ZYBO_rxBufferRead = 0u;
        ZYBO_rxBufferWrite = 0u;
        ZYBO_rxBufferLoopDetect = 0u;
        ZYBO_rxBufferOverflow = 0u;

        ZYBO_EnableRxInt();

    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

    }


    /*******************************************************************************
    * Function Name: ZYBO_SetRxAddressMode
    ********************************************************************************
    *
    * Summary:
    *  Sets the software controlled Addressing mode used by the RX portion of the
    *  UART.
    *
    * Parameters:
    *  addressMode: Enumerated value indicating the mode of RX addressing
    *  ZYBO__B_UART__AM_SW_BYTE_BYTE -  Software Byte-by-Byte address
    *                                               detection
    *  ZYBO__B_UART__AM_SW_DETECT_TO_BUFFER - Software Detect to Buffer
    *                                               address detection
    *  ZYBO__B_UART__AM_HW_BYTE_BY_BYTE - Hardware Byte-by-Byte address
    *                                               detection
    *  ZYBO__B_UART__AM_HW_DETECT_TO_BUFFER - Hardware Detect to Buffer
    *                                               address detection
    *  ZYBO__B_UART__AM_NONE - No address detection
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_rxAddressMode - the parameter stored in this variable for
    *   the farther usage in RX ISR.
    *  ZYBO_rxAddressDetected - set to initial state (0).
    *
    *******************************************************************************/
    void ZYBO_SetRxAddressMode(uint8 addressMode)
                                                        
    {
        #if(ZYBO_RXHW_ADDRESS_ENABLED)
            #if(ZYBO_CONTROL_REG_REMOVED)
                if(0u != addressMode)
                {
                    /* Suppress compiler warning */
                }
            #else /* ZYBO_CONTROL_REG_REMOVED */
                uint8 tmpCtrl;
                tmpCtrl = ZYBO_CONTROL_REG & (uint8)~ZYBO_CTRL_RXADDR_MODE_MASK;
                tmpCtrl |= (uint8)(addressMode << ZYBO_CTRL_RXADDR_MODE0_SHIFT);
                ZYBO_CONTROL_REG = tmpCtrl;

                #if(ZYBO_RX_INTERRUPT_ENABLED && \
                   (ZYBO_RXBUFFERSIZE > ZYBO_FIFO_LENGTH) )
                    ZYBO_rxAddressMode = addressMode;
                    ZYBO_rxAddressDetected = 0u;
                #endif /* End ZYBO_RXBUFFERSIZE > ZYBO_FIFO_LENGTH*/
            #endif /* End ZYBO_CONTROL_REG_REMOVED */
        #else /* ZYBO_RXHW_ADDRESS_ENABLED */
            if(0u != addressMode)
            {
                /* Suppress compiler warning */
            }
        #endif /* End ZYBO_RXHW_ADDRESS_ENABLED */
    }


    /*******************************************************************************
    * Function Name: ZYBO_SetRxAddress1
    ********************************************************************************
    *
    * Summary:
    *  Sets the first of two hardware-detectable receiver addresses.
    *
    * Parameters:
    *  address: Address #1 for hardware address detection.
    *
    * Return:
    *  None.
    *
    *******************************************************************************/
    void ZYBO_SetRxAddress1(uint8 address) 
    {
        ZYBO_RXADDRESS1_REG = address;
    }


    /*******************************************************************************
    * Function Name: ZYBO_SetRxAddress2
    ********************************************************************************
    *
    * Summary:
    *  Sets the second of two hardware-detectable receiver addresses.
    *
    * Parameters:
    *  address: Address #2 for hardware address detection.
    *
    * Return:
    *  None.
    *
    *******************************************************************************/
    void ZYBO_SetRxAddress2(uint8 address) 
    {
        ZYBO_RXADDRESS2_REG = address;
    }

#endif  /* ZYBO_RX_ENABLED || ZYBO_HD_ENABLED*/


#if( (ZYBO_TX_ENABLED) || (ZYBO_HD_ENABLED) )
    /*******************************************************************************
    * Function Name: ZYBO_SetTxInterruptMode
    ********************************************************************************
    *
    * Summary:
    *  Configures the TX interrupt sources to be enabled, but does not enable the
    *  interrupt.
    *
    * Parameters:
    *  intSrc: Bit field containing the TX interrupt sources to enable
    *   ZYBO_TX_STS_COMPLETE        Interrupt on TX byte complete
    *   ZYBO_TX_STS_FIFO_EMPTY      Interrupt when TX FIFO is empty
    *   ZYBO_TX_STS_FIFO_FULL       Interrupt when TX FIFO is full
    *   ZYBO_TX_STS_FIFO_NOT_FULL   Interrupt when TX FIFO is not full
    *
    * Return:
    *  None.
    *
    * Theory:
    *  Enables the output of specific status bits to the interrupt controller
    *
    *******************************************************************************/
    void ZYBO_SetTxInterruptMode(uint8 intSrc) 
    {
        ZYBO_TXSTATUS_MASK_REG = intSrc;
    }


    /*******************************************************************************
    * Function Name: ZYBO_WriteTxData
    ********************************************************************************
    *
    * Summary:
    *  Places a byte of data into the transmit buffer to be sent when the bus is
    *  available without checking the TX status register. You must check status
    *  separately.
    *
    * Parameters:
    *  txDataByte: data byte
    *
    * Return:
    * None.
    *
    * Global Variables:
    *  ZYBO_txBuffer - RAM buffer pointer for save data for transmission
    *  ZYBO_txBufferWrite - cyclic index for write to txBuffer,
    *    incremented after each byte saved to buffer.
    *  ZYBO_txBufferRead - cyclic index for read from txBuffer,
    *    checked to identify the condition to write to FIFO directly or to TX buffer
    *  ZYBO_initVar - checked to identify that the component has been
    *    initialized.
    *
    * Reentrant:
    *  No.
    *
    *******************************************************************************/
    void ZYBO_WriteTxData(uint8 txDataByte) 
    {
        /* If not Initialized then skip this function*/
        if(ZYBO_initVar != 0u)
        {
        #if (ZYBO_TX_INTERRUPT_ENABLED)

            /* Protect variables that could change on interrupt. */
            ZYBO_DisableTxInt();

            if( (ZYBO_txBufferRead == ZYBO_txBufferWrite) &&
                ((ZYBO_TXSTATUS_REG & ZYBO_TX_STS_FIFO_FULL) == 0u) )
            {
                /* Add directly to the FIFO. */
                ZYBO_TXDATA_REG = txDataByte;
            }
            else
            {
                if(ZYBO_txBufferWrite >= ZYBO_TX_BUFFER_SIZE)
                {
                    ZYBO_txBufferWrite = 0u;
                }

                ZYBO_txBuffer[ZYBO_txBufferWrite] = txDataByte;

                /* Add to the software buffer. */
                ZYBO_txBufferWrite++;
            }

            ZYBO_EnableTxInt();

        #else

            /* Add directly to the FIFO. */
            ZYBO_TXDATA_REG = txDataByte;

        #endif /*(ZYBO_TX_INTERRUPT_ENABLED) */
        }
    }


    /*******************************************************************************
    * Function Name: ZYBO_ReadTxStatus
    ********************************************************************************
    *
    * Summary:
    *  Reads the status register for the TX portion of the UART.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  Contents of the status register
    *
    * Theory:
    *  This function reads the TX status register, which is cleared on read.
    *  It is up to the user to handle all bits in this return value accordingly,
    *  even if the bit was not enabled as an interrupt source the event happened
    *  and must be handled accordingly.
    *
    *******************************************************************************/
    uint8 ZYBO_ReadTxStatus(void) 
    {
        return(ZYBO_TXSTATUS_REG);
    }


    /*******************************************************************************
    * Function Name: ZYBO_PutChar
    ********************************************************************************
    *
    * Summary:
    *  Puts a byte of data into the transmit buffer to be sent when the bus is
    *  available. This is a blocking API that waits until the TX buffer has room to
    *  hold the data.
    *
    * Parameters:
    *  txDataByte: Byte containing the data to transmit
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_txBuffer - RAM buffer pointer for save data for transmission
    *  ZYBO_txBufferWrite - cyclic index for write to txBuffer,
    *     checked to identify free space in txBuffer and incremented after each byte
    *     saved to buffer.
    *  ZYBO_txBufferRead - cyclic index for read from txBuffer,
    *     checked to identify free space in txBuffer.
    *  ZYBO_initVar - checked to identify that the component has been
    *     initialized.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  Allows the user to transmit any byte of data in a single transfer
    *
    *******************************************************************************/
    void ZYBO_PutChar(uint8 txDataByte) 
    {
    #if (ZYBO_TX_INTERRUPT_ENABLED)
        /* The temporary output pointer is used since it takes two instructions
        *  to increment with a wrap, and we can't risk doing that with the real
        *  pointer and getting an interrupt in between instructions.
        */
        uint8 locTxBufferWrite;
        uint8 locTxBufferRead;

        do
        { /* Block if software buffer is full, so we don't overwrite. */

        #if ((ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3))
            /* Disable TX interrupt to protect variables from modification */
            ZYBO_DisableTxInt();
        #endif /* (ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3) */

            locTxBufferWrite = ZYBO_txBufferWrite;
            locTxBufferRead  = ZYBO_txBufferRead;

        #if ((ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3))
            /* Enable interrupt to continue transmission */
            ZYBO_EnableTxInt();
        #endif /* (ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3) */
        }
        while( (locTxBufferWrite < locTxBufferRead) ? (locTxBufferWrite == (locTxBufferRead - 1u)) :
                                ((locTxBufferWrite - locTxBufferRead) ==
                                (uint8)(ZYBO_TX_BUFFER_SIZE - 1u)) );

        if( (locTxBufferRead == locTxBufferWrite) &&
            ((ZYBO_TXSTATUS_REG & ZYBO_TX_STS_FIFO_FULL) == 0u) )
        {
            /* Add directly to the FIFO */
            ZYBO_TXDATA_REG = txDataByte;
        }
        else
        {
            if(locTxBufferWrite >= ZYBO_TX_BUFFER_SIZE)
            {
                locTxBufferWrite = 0u;
            }
            /* Add to the software buffer. */
            ZYBO_txBuffer[locTxBufferWrite] = txDataByte;
            locTxBufferWrite++;

            /* Finally, update the real output pointer */
        #if ((ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3))
            ZYBO_DisableTxInt();
        #endif /* (ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3) */

            ZYBO_txBufferWrite = locTxBufferWrite;

        #if ((ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3))
            ZYBO_EnableTxInt();
        #endif /* (ZYBO_TX_BUFFER_SIZE > ZYBO_MAX_BYTE_VALUE) && (CY_PSOC3) */

            if(0u != (ZYBO_TXSTATUS_REG & ZYBO_TX_STS_FIFO_EMPTY))
            {
                /* Trigger TX interrupt to send software buffer */
                ZYBO_SetPendingTxInt();
            }
        }

    #else

        while((ZYBO_TXSTATUS_REG & ZYBO_TX_STS_FIFO_FULL) != 0u)
        {
            /* Wait for room in the FIFO */
        }

        /* Add directly to the FIFO */
        ZYBO_TXDATA_REG = txDataByte;

    #endif /* ZYBO_TX_INTERRUPT_ENABLED */
    }


    /*******************************************************************************
    * Function Name: ZYBO_PutString
    ********************************************************************************
    *
    * Summary:
    *  Sends a NULL terminated string to the TX buffer for transmission.
    *
    * Parameters:
    *  string[]: Pointer to the null terminated string array residing in RAM or ROM
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_initVar - checked to identify that the component has been
    *     initialized.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  If there is not enough memory in the TX buffer for the entire string, this
    *  function blocks until the last character of the string is loaded into the
    *  TX buffer.
    *
    *******************************************************************************/
    void ZYBO_PutString(const char8 string[]) 
    {
        uint16 bufIndex = 0u;

        /* If not Initialized then skip this function */
        if(ZYBO_initVar != 0u)
        {
            /* This is a blocking function, it will not exit until all data is sent */
            while(string[bufIndex] != (char8) 0)
            {
                ZYBO_PutChar((uint8)string[bufIndex]);
                bufIndex++;
            }
        }
    }


    /*******************************************************************************
    * Function Name: ZYBO_PutArray
    ********************************************************************************
    *
    * Summary:
    *  Places N bytes of data from a memory array into the TX buffer for
    *  transmission.
    *
    * Parameters:
    *  string[]: Address of the memory array residing in RAM or ROM.
    *  byteCount: Number of bytes to be transmitted. The type depends on TX Buffer
    *             Size parameter.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_initVar - checked to identify that the component has been
    *     initialized.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  If there is not enough memory in the TX buffer for the entire string, this
    *  function blocks until the last character of the string is loaded into the
    *  TX buffer.
    *
    *******************************************************************************/
    void ZYBO_PutArray(const uint8 string[], uint8 byteCount)
                                                                    
    {
        uint8 bufIndex = 0u;

        /* If not Initialized then skip this function */
        if(ZYBO_initVar != 0u)
        {
            while(bufIndex < byteCount)
            {
                ZYBO_PutChar(string[bufIndex]);
                bufIndex++;
            }
        }
    }


    /*******************************************************************************
    * Function Name: ZYBO_PutCRLF
    ********************************************************************************
    *
    * Summary:
    *  Writes a byte of data followed by a carriage return (0x0D) and line feed
    *  (0x0A) to the transmit buffer.
    *
    * Parameters:
    *  txDataByte: Data byte to transmit before the carriage return and line feed.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_initVar - checked to identify that the component has been
    *     initialized.
    *
    * Reentrant:
    *  No.
    *
    *******************************************************************************/
    void ZYBO_PutCRLF(uint8 txDataByte) 
    {
        /* If not Initialized then skip this function */
        if(ZYBO_initVar != 0u)
        {
            ZYBO_PutChar(txDataByte);
            ZYBO_PutChar(0x0Du);
            ZYBO_PutChar(0x0Au);
        }
    }


    /*******************************************************************************
    * Function Name: ZYBO_GetTxBufferSize
    ********************************************************************************
    *
    * Summary:
    *  Returns the number of bytes in the TX buffer which are waiting to be 
    *  transmitted.
    *  * TX software buffer is disabled (TX Buffer Size parameter is equal to 4): 
    *    returns 0 for empty TX FIFO, 1 for not full TX FIFO or 4 for full TX FIFO.
    *  * TX software buffer is enabled: returns the number of bytes in the TX 
    *    software buffer which are waiting to be transmitted. Bytes available in the
    *    TX FIFO do not count.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  Number of bytes used in the TX buffer. Return value type depends on the TX 
    *  Buffer Size parameter.
    *
    * Global Variables:
    *  ZYBO_txBufferWrite - used to calculate left space.
    *  ZYBO_txBufferRead - used to calculate left space.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  Allows the user to find out how full the TX Buffer is.
    *
    *******************************************************************************/
    uint8 ZYBO_GetTxBufferSize(void)
                                                            
    {
        uint8 size;

    #if (ZYBO_TX_INTERRUPT_ENABLED)

        /* Protect variables that could change on interrupt. */
        ZYBO_DisableTxInt();

        if(ZYBO_txBufferRead == ZYBO_txBufferWrite)
        {
            size = 0u;
        }
        else if(ZYBO_txBufferRead < ZYBO_txBufferWrite)
        {
            size = (ZYBO_txBufferWrite - ZYBO_txBufferRead);
        }
        else
        {
            size = (ZYBO_TX_BUFFER_SIZE - ZYBO_txBufferRead) +
                    ZYBO_txBufferWrite;
        }

        ZYBO_EnableTxInt();

    #else

        size = ZYBO_TXSTATUS_REG;

        /* Is the fifo is full. */
        if((size & ZYBO_TX_STS_FIFO_FULL) != 0u)
        {
            size = ZYBO_FIFO_LENGTH;
        }
        else if((size & ZYBO_TX_STS_FIFO_EMPTY) != 0u)
        {
            size = 0u;
        }
        else
        {
            /* We only know there is data in the fifo. */
            size = 1u;
        }

    #endif /* (ZYBO_TX_INTERRUPT_ENABLED) */

    return(size);
    }


    /*******************************************************************************
    * Function Name: ZYBO_ClearTxBuffer
    ********************************************************************************
    *
    * Summary:
    *  Clears all data from the TX buffer and hardware TX FIFO.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_txBufferWrite - cleared to zero.
    *  ZYBO_txBufferRead - cleared to zero.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  Setting the pointers to zero makes the system believe there is no data to
    *  read and writing will resume at address 0 overwriting any data that may have
    *  remained in the RAM.
    *
    * Side Effects:
    *  Data waiting in the transmit buffer is not sent; a byte that is currently
    *  transmitting finishes transmitting.
    *
    *******************************************************************************/
    void ZYBO_ClearTxBuffer(void) 
    {
        uint8 enableInterrupts;

        enableInterrupts = CyEnterCriticalSection();
        /* Clear the HW FIFO */
        ZYBO_TXDATA_AUX_CTL_REG |= (uint8)  ZYBO_TX_FIFO_CLR;
        ZYBO_TXDATA_AUX_CTL_REG &= (uint8) ~ZYBO_TX_FIFO_CLR;
        CyExitCriticalSection(enableInterrupts);

    #if (ZYBO_TX_INTERRUPT_ENABLED)

        /* Protect variables that could change on interrupt. */
        ZYBO_DisableTxInt();

        ZYBO_txBufferRead = 0u;
        ZYBO_txBufferWrite = 0u;

        /* Enable Tx interrupt. */
        ZYBO_EnableTxInt();

    #endif /* (ZYBO_TX_INTERRUPT_ENABLED) */
    }


    /*******************************************************************************
    * Function Name: ZYBO_SendBreak
    ********************************************************************************
    *
    * Summary:
    *  Transmits a break signal on the bus.
    *
    * Parameters:
    *  uint8 retMode:  Send Break return mode. See the following table for options.
    *   ZYBO_SEND_BREAK - Initialize registers for break, send the Break
    *       signal and return immediately.
    *   ZYBO_WAIT_FOR_COMPLETE_REINIT - Wait until break transmission is
    *       complete, reinitialize registers to normal transmission mode then return
    *   ZYBO_REINIT - Reinitialize registers to normal transmission mode
    *       then return.
    *   ZYBO_SEND_WAIT_REINIT - Performs both options: 
    *      ZYBO_SEND_BREAK and ZYBO_WAIT_FOR_COMPLETE_REINIT.
    *      This option is recommended for most cases.
    *
    * Return:
    *  None.
    *
    * Global Variables:
    *  ZYBO_initVar - checked to identify that the component has been
    *     initialized.
    *  txPeriod - static variable, used for keeping TX period configuration.
    *
    * Reentrant:
    *  No.
    *
    * Theory:
    *  SendBreak function initializes registers to send 13-bit break signal. It is
    *  important to return the registers configuration to normal for continue 8-bit
    *  operation.
    *  There are 3 variants for this API usage:
    *  1) SendBreak(3) - function will send the Break signal and take care on the
    *     configuration returning. Function will block CPU until transmission
    *     complete.
    *  2) User may want to use blocking time if UART configured to the low speed
    *     operation
    *     Example for this case:
    *     SendBreak(0);     - initialize Break signal transmission
    *         Add your code here to use CPU time
    *     SendBreak(1);     - complete Break operation
    *  3) Same to 2) but user may want to initialize and use the interrupt to
    *     complete break operation.
    *     Example for this case:
    *     Initialize TX interrupt with "TX - On TX Complete" parameter
    *     SendBreak(0);     - initialize Break signal transmission
    *         Add your code here to use CPU time
    *     When interrupt appear with ZYBO_TX_STS_COMPLETE status:
    *     SendBreak(2);     - complete Break operation
    *
    * Side Effects:
    *  The ZYBO_SendBreak() function initializes registers to send a
    *  break signal.
    *  Break signal length depends on the break signal bits configuration.
    *  The register configuration should be reinitialized before normal 8-bit
    *  communication can continue.
    *
    *******************************************************************************/
    void ZYBO_SendBreak(uint8 retMode) 
    {

        /* If not Initialized then skip this function*/
        if(ZYBO_initVar != 0u)
        {
            /* Set the Counter to 13-bits and transmit a 00 byte */
            /* When that is done then reset the counter value back */
            uint8 tmpStat;

        #if(ZYBO_HD_ENABLED) /* Half Duplex mode*/

            if( (retMode == ZYBO_SEND_BREAK) ||
                (retMode == ZYBO_SEND_WAIT_REINIT ) )
            {
                /* CTRL_HD_SEND_BREAK - sends break bits in HD mode */
                ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() |
                                                      ZYBO_CTRL_HD_SEND_BREAK);
                /* Send zeros */
                ZYBO_TXDATA_REG = 0u;

                do /* Wait until transmit starts */
                {
                    tmpStat = ZYBO_TXSTATUS_REG;
                }
                while((tmpStat & ZYBO_TX_STS_FIFO_EMPTY) != 0u);
            }

            if( (retMode == ZYBO_WAIT_FOR_COMPLETE_REINIT) ||
                (retMode == ZYBO_SEND_WAIT_REINIT) )
            {
                do /* Wait until transmit complete */
                {
                    tmpStat = ZYBO_TXSTATUS_REG;
                }
                while(((uint8)~tmpStat & ZYBO_TX_STS_COMPLETE) != 0u);
            }

            if( (retMode == ZYBO_WAIT_FOR_COMPLETE_REINIT) ||
                (retMode == ZYBO_REINIT) ||
                (retMode == ZYBO_SEND_WAIT_REINIT) )
            {
                ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() &
                                              (uint8)~ZYBO_CTRL_HD_SEND_BREAK);
            }

        #else /* ZYBO_HD_ENABLED Full Duplex mode */

            static uint8 txPeriod;

            if( (retMode == ZYBO_SEND_BREAK) ||
                (retMode == ZYBO_SEND_WAIT_REINIT) )
            {
                /* CTRL_HD_SEND_BREAK - skip to send parity bit at Break signal in Full Duplex mode */
                #if( (ZYBO_PARITY_TYPE != ZYBO__B_UART__NONE_REVB) || \
                                    (ZYBO_PARITY_TYPE_SW != 0u) )
                    ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() |
                                                          ZYBO_CTRL_HD_SEND_BREAK);
                #endif /* End ZYBO_PARITY_TYPE != ZYBO__B_UART__NONE_REVB  */

                #if(ZYBO_TXCLKGEN_DP)
                    txPeriod = ZYBO_TXBITCLKTX_COMPLETE_REG;
                    ZYBO_TXBITCLKTX_COMPLETE_REG = ZYBO_TXBITCTR_BREAKBITS;
                #else
                    txPeriod = ZYBO_TXBITCTR_PERIOD_REG;
                    ZYBO_TXBITCTR_PERIOD_REG = ZYBO_TXBITCTR_BREAKBITS8X;
                #endif /* End ZYBO_TXCLKGEN_DP */

                /* Send zeros */
                ZYBO_TXDATA_REG = 0u;

                do /* Wait until transmit starts */
                {
                    tmpStat = ZYBO_TXSTATUS_REG;
                }
                while((tmpStat & ZYBO_TX_STS_FIFO_EMPTY) != 0u);
            }

            if( (retMode == ZYBO_WAIT_FOR_COMPLETE_REINIT) ||
                (retMode == ZYBO_SEND_WAIT_REINIT) )
            {
                do /* Wait until transmit complete */
                {
                    tmpStat = ZYBO_TXSTATUS_REG;
                }
                while(((uint8)~tmpStat & ZYBO_TX_STS_COMPLETE) != 0u);
            }

            if( (retMode == ZYBO_WAIT_FOR_COMPLETE_REINIT) ||
                (retMode == ZYBO_REINIT) ||
                (retMode == ZYBO_SEND_WAIT_REINIT) )
            {

            #if(ZYBO_TXCLKGEN_DP)
                ZYBO_TXBITCLKTX_COMPLETE_REG = txPeriod;
            #else
                ZYBO_TXBITCTR_PERIOD_REG = txPeriod;
            #endif /* End ZYBO_TXCLKGEN_DP */

            #if( (ZYBO_PARITY_TYPE != ZYBO__B_UART__NONE_REVB) || \
                 (ZYBO_PARITY_TYPE_SW != 0u) )
                ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() &
                                                      (uint8) ~ZYBO_CTRL_HD_SEND_BREAK);
            #endif /* End ZYBO_PARITY_TYPE != NONE */
            }
        #endif    /* End ZYBO_HD_ENABLED */
        }
    }


    /*******************************************************************************
    * Function Name: ZYBO_SetTxAddressMode
    ********************************************************************************
    *
    * Summary:
    *  Configures the transmitter to signal the next bytes is address or data.
    *
    * Parameters:
    *  addressMode: 
    *       ZYBO_SET_SPACE - Configure the transmitter to send the next
    *                                    byte as a data.
    *       ZYBO_SET_MARK  - Configure the transmitter to send the next
    *                                    byte as an address.
    *
    * Return:
    *  None.
    *
    * Side Effects:
    *  This function sets and clears ZYBO_CTRL_MARK bit in the Control
    *  register.
    *
    *******************************************************************************/
    void ZYBO_SetTxAddressMode(uint8 addressMode) 
    {
        /* Mark/Space sending enable */
        if(addressMode != 0u)
        {
        #if( ZYBO_CONTROL_REG_REMOVED == 0u )
            ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() |
                                                  ZYBO_CTRL_MARK);
        #endif /* End ZYBO_CONTROL_REG_REMOVED == 0u */
        }
        else
        {
        #if( ZYBO_CONTROL_REG_REMOVED == 0u )
            ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() &
                                                  (uint8) ~ZYBO_CTRL_MARK);
        #endif /* End ZYBO_CONTROL_REG_REMOVED == 0u */
        }
    }

#endif  /* EndZYBO_TX_ENABLED */

#if(ZYBO_HD_ENABLED)


    /*******************************************************************************
    * Function Name: ZYBO_LoadRxConfig
    ********************************************************************************
    *
    * Summary:
    *  Loads the receiver configuration in half duplex mode. After calling this
    *  function, the UART is ready to receive data.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    * Side Effects:
    *  Valid only in half duplex mode. You must make sure that the previous
    *  transaction is complete and it is safe to unload the transmitter
    *  configuration.
    *
    *******************************************************************************/
    void ZYBO_LoadRxConfig(void) 
    {
        ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() &
                                                (uint8)~ZYBO_CTRL_HD_SEND);
        ZYBO_RXBITCTR_PERIOD_REG = ZYBO_HD_RXBITCTR_INIT;

    #if (ZYBO_RX_INTERRUPT_ENABLED)
        /* Enable RX interrupt after set RX configuration */
        ZYBO_SetRxInterruptMode(ZYBO_INIT_RX_INTERRUPTS_MASK);
    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */
    }


    /*******************************************************************************
    * Function Name: ZYBO_LoadTxConfig
    ********************************************************************************
    *
    * Summary:
    *  Loads the transmitter configuration in half duplex mode. After calling this
    *  function, the UART is ready to transmit data.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    * Side Effects:
    *  Valid only in half duplex mode. You must make sure that the previous
    *  transaction is complete and it is safe to unload the receiver configuration.
    *
    *******************************************************************************/
    void ZYBO_LoadTxConfig(void) 
    {
    #if (ZYBO_RX_INTERRUPT_ENABLED)
        /* Disable RX interrupts before set TX configuration */
        ZYBO_SetRxInterruptMode(0u);
    #endif /* (ZYBO_RX_INTERRUPT_ENABLED) */

        ZYBO_WriteControlRegister(ZYBO_ReadControlRegister() | ZYBO_CTRL_HD_SEND);
        ZYBO_RXBITCTR_PERIOD_REG = ZYBO_HD_TXBITCTR_INIT;
    }

#endif  /* ZYBO_HD_ENABLED */


/* [] END OF FILE */
