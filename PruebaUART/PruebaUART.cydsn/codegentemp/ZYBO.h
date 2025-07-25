/*******************************************************************************
* File Name: ZYBO.h
* Version 2.50
*
* Description:
*  Contains the function prototypes and constants available to the UART
*  user module.
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/


#if !defined(CY_UART_ZYBO_H)
#define CY_UART_ZYBO_H

#include "cyfitter.h"
#include "cytypes.h"
#include "CyLib.h" /* For CyEnterCriticalSection() and CyExitCriticalSection() functions */


/***************************************
* Conditional Compilation Parameters
***************************************/

#define ZYBO_RX_ENABLED                     (1u)
#define ZYBO_TX_ENABLED                     (1u)
#define ZYBO_HD_ENABLED                     (0u)
#define ZYBO_RX_INTERRUPT_ENABLED           (1u)
#define ZYBO_TX_INTERRUPT_ENABLED           (1u)
#define ZYBO_INTERNAL_CLOCK_USED            (1u)
#define ZYBO_RXHW_ADDRESS_ENABLED           (0u)
#define ZYBO_OVER_SAMPLE_COUNT              (8u)
#define ZYBO_PARITY_TYPE                    (0u)
#define ZYBO_PARITY_TYPE_SW                 (0u)
#define ZYBO_BREAK_DETECT                   (0u)
#define ZYBO_BREAK_BITS_TX                  (13u)
#define ZYBO_BREAK_BITS_RX                  (13u)
#define ZYBO_TXCLKGEN_DP                    (1u)
#define ZYBO_USE23POLLING                   (1u)
#define ZYBO_FLOW_CONTROL                   (0u)
#define ZYBO_CLK_FREQ                       (0u)
#define ZYBO_TX_BUFFER_SIZE                 (16u)
#define ZYBO_RX_BUFFER_SIZE                 (16u)

/* Check to see if required defines such as CY_PSOC5LP are available */
/* They are defined starting with cy_boot v3.0 */
#if !defined (CY_PSOC5LP)
    #error Component UART_v2_50 requires cy_boot v3.0 or later
#endif /* (CY_PSOC5LP) */

#if defined(ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG)
    #define ZYBO_CONTROL_REG_REMOVED            (0u)
#else
    #define ZYBO_CONTROL_REG_REMOVED            (1u)
#endif /* End ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG */


/***************************************
*      Data Structure Definition
***************************************/

/* Sleep Mode API Support */
typedef struct ZYBO_backupStruct_
{
    uint8 enableState;

    #if(ZYBO_CONTROL_REG_REMOVED == 0u)
        uint8 cr;
    #endif /* End ZYBO_CONTROL_REG_REMOVED */

} ZYBO_BACKUP_STRUCT;


/***************************************
*       Function Prototypes
***************************************/

void ZYBO_Start(void) ;
void ZYBO_Stop(void) ;
uint8 ZYBO_ReadControlRegister(void) ;
void ZYBO_WriteControlRegister(uint8 control) ;

void ZYBO_Init(void) ;
void ZYBO_Enable(void) ;
void ZYBO_SaveConfig(void) ;
void ZYBO_RestoreConfig(void) ;
void ZYBO_Sleep(void) ;
void ZYBO_Wakeup(void) ;

/* Only if RX is enabled */
#if( (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) )

    #if (ZYBO_RX_INTERRUPT_ENABLED)
        #define ZYBO_EnableRxInt()  CyIntEnable (ZYBO_RX_VECT_NUM)
        #define ZYBO_DisableRxInt() CyIntDisable(ZYBO_RX_VECT_NUM)
        CY_ISR_PROTO(ZYBO_RXISR);
    #endif /* ZYBO_RX_INTERRUPT_ENABLED */

    void ZYBO_SetRxAddressMode(uint8 addressMode)
                                                           ;
    void ZYBO_SetRxAddress1(uint8 address) ;
    void ZYBO_SetRxAddress2(uint8 address) ;

    void  ZYBO_SetRxInterruptMode(uint8 intSrc) ;
    uint8 ZYBO_ReadRxData(void) ;
    uint8 ZYBO_ReadRxStatus(void) ;
    uint8 ZYBO_GetChar(void) ;
    uint16 ZYBO_GetByte(void) ;
    uint8 ZYBO_GetRxBufferSize(void)
                                                            ;
    void ZYBO_ClearRxBuffer(void) ;

    /* Obsolete functions, defines for backward compatible */
    #define ZYBO_GetRxInterruptSource   ZYBO_ReadRxStatus

#endif /* End (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) */

/* Only if TX is enabled */
#if(ZYBO_TX_ENABLED || ZYBO_HD_ENABLED)

    #if(ZYBO_TX_INTERRUPT_ENABLED)
        #define ZYBO_EnableTxInt()  CyIntEnable (ZYBO_TX_VECT_NUM)
        #define ZYBO_DisableTxInt() CyIntDisable(ZYBO_TX_VECT_NUM)
        #define ZYBO_SetPendingTxInt() CyIntSetPending(ZYBO_TX_VECT_NUM)
        #define ZYBO_ClearPendingTxInt() CyIntClearPending(ZYBO_TX_VECT_NUM)
        CY_ISR_PROTO(ZYBO_TXISR);
    #endif /* ZYBO_TX_INTERRUPT_ENABLED */

    void ZYBO_SetTxInterruptMode(uint8 intSrc) ;
    void ZYBO_WriteTxData(uint8 txDataByte) ;
    uint8 ZYBO_ReadTxStatus(void) ;
    void ZYBO_PutChar(uint8 txDataByte) ;
    void ZYBO_PutString(const char8 string[]) ;
    void ZYBO_PutArray(const uint8 string[], uint8 byteCount)
                                                            ;
    void ZYBO_PutCRLF(uint8 txDataByte) ;
    void ZYBO_ClearTxBuffer(void) ;
    void ZYBO_SetTxAddressMode(uint8 addressMode) ;
    void ZYBO_SendBreak(uint8 retMode) ;
    uint8 ZYBO_GetTxBufferSize(void)
                                                            ;
    /* Obsolete functions, defines for backward compatible */
    #define ZYBO_PutStringConst         ZYBO_PutString
    #define ZYBO_PutArrayConst          ZYBO_PutArray
    #define ZYBO_GetTxInterruptSource   ZYBO_ReadTxStatus

#endif /* End ZYBO_TX_ENABLED || ZYBO_HD_ENABLED */

#if(ZYBO_HD_ENABLED)
    void ZYBO_LoadRxConfig(void) ;
    void ZYBO_LoadTxConfig(void) ;
#endif /* End ZYBO_HD_ENABLED */


/* Communication bootloader APIs */
#if defined(CYDEV_BOOTLOADER_IO_COMP) && ((CYDEV_BOOTLOADER_IO_COMP == CyBtldr_ZYBO) || \
                                          (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_Custom_Interface))
    /* Physical layer functions */
    void    ZYBO_CyBtldrCommStart(void) CYSMALL ;
    void    ZYBO_CyBtldrCommStop(void) CYSMALL ;
    void    ZYBO_CyBtldrCommReset(void) CYSMALL ;
    cystatus ZYBO_CyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut) CYSMALL
             ;
    cystatus ZYBO_CyBtldrCommRead(uint8 pData[], uint16 size, uint16 * count, uint8 timeOut) CYSMALL
             ;

    #if (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_ZYBO)
        #define CyBtldrCommStart    ZYBO_CyBtldrCommStart
        #define CyBtldrCommStop     ZYBO_CyBtldrCommStop
        #define CyBtldrCommReset    ZYBO_CyBtldrCommReset
        #define CyBtldrCommWrite    ZYBO_CyBtldrCommWrite
        #define CyBtldrCommRead     ZYBO_CyBtldrCommRead
    #endif  /* (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_ZYBO) */

    /* Byte to Byte time out for detecting end of block data from host */
    #define ZYBO_BYTE2BYTE_TIME_OUT (25u)
    #define ZYBO_PACKET_EOP         (0x17u) /* End of packet defined by bootloader */
    #define ZYBO_WAIT_EOP_DELAY     (5u)    /* Additional 5ms to wait for End of packet */
    #define ZYBO_BL_CHK_DELAY_MS    (1u)    /* Time Out quantity equal 1mS */

#endif /* CYDEV_BOOTLOADER_IO_COMP */


/***************************************
*          API Constants
***************************************/
/* Parameters for SetTxAddressMode API*/
#define ZYBO_SET_SPACE      (0x00u)
#define ZYBO_SET_MARK       (0x01u)

/* Status Register definitions */
#if( (ZYBO_TX_ENABLED) || (ZYBO_HD_ENABLED) )
    #if(ZYBO_TX_INTERRUPT_ENABLED)
        #define ZYBO_TX_VECT_NUM            (uint8)ZYBO_TXInternalInterrupt__INTC_NUMBER
        #define ZYBO_TX_PRIOR_NUM           (uint8)ZYBO_TXInternalInterrupt__INTC_PRIOR_NUM
    #endif /* ZYBO_TX_INTERRUPT_ENABLED */

    #define ZYBO_TX_STS_COMPLETE_SHIFT          (0x00u)
    #define ZYBO_TX_STS_FIFO_EMPTY_SHIFT        (0x01u)
    #define ZYBO_TX_STS_FIFO_NOT_FULL_SHIFT     (0x03u)
    #if(ZYBO_TX_ENABLED)
        #define ZYBO_TX_STS_FIFO_FULL_SHIFT     (0x02u)
    #else /* (ZYBO_HD_ENABLED) */
        #define ZYBO_TX_STS_FIFO_FULL_SHIFT     (0x05u)  /* Needs MD=0 */
    #endif /* (ZYBO_TX_ENABLED) */

    #define ZYBO_TX_STS_COMPLETE            (uint8)(0x01u << ZYBO_TX_STS_COMPLETE_SHIFT)
    #define ZYBO_TX_STS_FIFO_EMPTY          (uint8)(0x01u << ZYBO_TX_STS_FIFO_EMPTY_SHIFT)
    #define ZYBO_TX_STS_FIFO_FULL           (uint8)(0x01u << ZYBO_TX_STS_FIFO_FULL_SHIFT)
    #define ZYBO_TX_STS_FIFO_NOT_FULL       (uint8)(0x01u << ZYBO_TX_STS_FIFO_NOT_FULL_SHIFT)
#endif /* End (ZYBO_TX_ENABLED) || (ZYBO_HD_ENABLED)*/

#if( (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) )
    #if(ZYBO_RX_INTERRUPT_ENABLED)
        #define ZYBO_RX_VECT_NUM            (uint8)ZYBO_RXInternalInterrupt__INTC_NUMBER
        #define ZYBO_RX_PRIOR_NUM           (uint8)ZYBO_RXInternalInterrupt__INTC_PRIOR_NUM
    #endif /* ZYBO_RX_INTERRUPT_ENABLED */
    #define ZYBO_RX_STS_MRKSPC_SHIFT            (0x00u)
    #define ZYBO_RX_STS_BREAK_SHIFT             (0x01u)
    #define ZYBO_RX_STS_PAR_ERROR_SHIFT         (0x02u)
    #define ZYBO_RX_STS_STOP_ERROR_SHIFT        (0x03u)
    #define ZYBO_RX_STS_OVERRUN_SHIFT           (0x04u)
    #define ZYBO_RX_STS_FIFO_NOTEMPTY_SHIFT     (0x05u)
    #define ZYBO_RX_STS_ADDR_MATCH_SHIFT        (0x06u)
    #define ZYBO_RX_STS_SOFT_BUFF_OVER_SHIFT    (0x07u)

    #define ZYBO_RX_STS_MRKSPC           (uint8)(0x01u << ZYBO_RX_STS_MRKSPC_SHIFT)
    #define ZYBO_RX_STS_BREAK            (uint8)(0x01u << ZYBO_RX_STS_BREAK_SHIFT)
    #define ZYBO_RX_STS_PAR_ERROR        (uint8)(0x01u << ZYBO_RX_STS_PAR_ERROR_SHIFT)
    #define ZYBO_RX_STS_STOP_ERROR       (uint8)(0x01u << ZYBO_RX_STS_STOP_ERROR_SHIFT)
    #define ZYBO_RX_STS_OVERRUN          (uint8)(0x01u << ZYBO_RX_STS_OVERRUN_SHIFT)
    #define ZYBO_RX_STS_FIFO_NOTEMPTY    (uint8)(0x01u << ZYBO_RX_STS_FIFO_NOTEMPTY_SHIFT)
    #define ZYBO_RX_STS_ADDR_MATCH       (uint8)(0x01u << ZYBO_RX_STS_ADDR_MATCH_SHIFT)
    #define ZYBO_RX_STS_SOFT_BUFF_OVER   (uint8)(0x01u << ZYBO_RX_STS_SOFT_BUFF_OVER_SHIFT)
    #define ZYBO_RX_HW_MASK                     (0x7Fu)
#endif /* End (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) */

/* Control Register definitions */
#define ZYBO_CTRL_HD_SEND_SHIFT                 (0x00u) /* 1 enable TX part in Half Duplex mode */
#define ZYBO_CTRL_HD_SEND_BREAK_SHIFT           (0x01u) /* 1 send BREAK signal in Half Duplez mode */
#define ZYBO_CTRL_MARK_SHIFT                    (0x02u) /* 1 sets mark, 0 sets space */
#define ZYBO_CTRL_PARITY_TYPE0_SHIFT            (0x03u) /* Defines the type of parity implemented */
#define ZYBO_CTRL_PARITY_TYPE1_SHIFT            (0x04u) /* Defines the type of parity implemented */
#define ZYBO_CTRL_RXADDR_MODE0_SHIFT            (0x05u)
#define ZYBO_CTRL_RXADDR_MODE1_SHIFT            (0x06u)
#define ZYBO_CTRL_RXADDR_MODE2_SHIFT            (0x07u)

#define ZYBO_CTRL_HD_SEND               (uint8)(0x01u << ZYBO_CTRL_HD_SEND_SHIFT)
#define ZYBO_CTRL_HD_SEND_BREAK         (uint8)(0x01u << ZYBO_CTRL_HD_SEND_BREAK_SHIFT)
#define ZYBO_CTRL_MARK                  (uint8)(0x01u << ZYBO_CTRL_MARK_SHIFT)
#define ZYBO_CTRL_PARITY_TYPE_MASK      (uint8)(0x03u << ZYBO_CTRL_PARITY_TYPE0_SHIFT)
#define ZYBO_CTRL_RXADDR_MODE_MASK      (uint8)(0x07u << ZYBO_CTRL_RXADDR_MODE0_SHIFT)

/* StatusI Register Interrupt Enable Control Bits. As defined by the Register map for the AUX Control Register */
#define ZYBO_INT_ENABLE                         (0x10u)

/* Bit Counter (7-bit) Control Register Bit Definitions. As defined by the Register map for the AUX Control Register */
#define ZYBO_CNTR_ENABLE                        (0x20u)

/*   Constants for SendBreak() "retMode" parameter  */
#define ZYBO_SEND_BREAK                         (0x00u)
#define ZYBO_WAIT_FOR_COMPLETE_REINIT           (0x01u)
#define ZYBO_REINIT                             (0x02u)
#define ZYBO_SEND_WAIT_REINIT                   (0x03u)

#define ZYBO_OVER_SAMPLE_8                      (8u)
#define ZYBO_OVER_SAMPLE_16                     (16u)

#define ZYBO_BIT_CENTER                         (ZYBO_OVER_SAMPLE_COUNT - 2u)

#define ZYBO_FIFO_LENGTH                        (4u)
#define ZYBO_NUMBER_OF_START_BIT                (1u)
#define ZYBO_MAX_BYTE_VALUE                     (0xFFu)

/* 8X always for count7 implementation */
#define ZYBO_TXBITCTR_BREAKBITS8X   ((ZYBO_BREAK_BITS_TX * ZYBO_OVER_SAMPLE_8) - 1u)
/* 8X or 16X for DP implementation */
#define ZYBO_TXBITCTR_BREAKBITS ((ZYBO_BREAK_BITS_TX * ZYBO_OVER_SAMPLE_COUNT) - 1u)

#define ZYBO_HALF_BIT_COUNT   \
                            (((ZYBO_OVER_SAMPLE_COUNT / 2u) + (ZYBO_USE23POLLING * 1u)) - 2u)
#if (ZYBO_OVER_SAMPLE_COUNT == ZYBO_OVER_SAMPLE_8)
    #define ZYBO_HD_TXBITCTR_INIT   (((ZYBO_BREAK_BITS_TX + \
                            ZYBO_NUMBER_OF_START_BIT) * ZYBO_OVER_SAMPLE_COUNT) - 1u)

    /* This parameter is increased on the 2 in 2 out of 3 mode to sample voting in the middle */
    #define ZYBO_RXBITCTR_INIT  ((((ZYBO_BREAK_BITS_RX + ZYBO_NUMBER_OF_START_BIT) \
                            * ZYBO_OVER_SAMPLE_COUNT) + ZYBO_HALF_BIT_COUNT) - 1u)

#else /* ZYBO_OVER_SAMPLE_COUNT == ZYBO_OVER_SAMPLE_16 */
    #define ZYBO_HD_TXBITCTR_INIT   ((8u * ZYBO_OVER_SAMPLE_COUNT) - 1u)
    /* 7bit counter need one more bit for OverSampleCount = 16 */
    #define ZYBO_RXBITCTR_INIT      (((7u * ZYBO_OVER_SAMPLE_COUNT) - 1u) + \
                                                      ZYBO_HALF_BIT_COUNT)
#endif /* End ZYBO_OVER_SAMPLE_COUNT */

#define ZYBO_HD_RXBITCTR_INIT                   ZYBO_RXBITCTR_INIT


/***************************************
* Global variables external identifier
***************************************/

extern uint8 ZYBO_initVar;
#if (ZYBO_TX_INTERRUPT_ENABLED && ZYBO_TX_ENABLED)
    extern volatile uint8 ZYBO_txBuffer[ZYBO_TX_BUFFER_SIZE];
    extern volatile uint8 ZYBO_txBufferRead;
    extern uint8 ZYBO_txBufferWrite;
#endif /* (ZYBO_TX_INTERRUPT_ENABLED && ZYBO_TX_ENABLED) */
#if (ZYBO_RX_INTERRUPT_ENABLED && (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED))
    extern uint8 ZYBO_errorStatus;
    extern volatile uint8 ZYBO_rxBuffer[ZYBO_RX_BUFFER_SIZE];
    extern volatile uint8 ZYBO_rxBufferRead;
    extern volatile uint8 ZYBO_rxBufferWrite;
    extern volatile uint8 ZYBO_rxBufferLoopDetect;
    extern volatile uint8 ZYBO_rxBufferOverflow;
    #if (ZYBO_RXHW_ADDRESS_ENABLED)
        extern volatile uint8 ZYBO_rxAddressMode;
        extern volatile uint8 ZYBO_rxAddressDetected;
    #endif /* (ZYBO_RXHW_ADDRESS_ENABLED) */
#endif /* (ZYBO_RX_INTERRUPT_ENABLED && (ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)) */


/***************************************
* Enumerated Types and Parameters
***************************************/

#define ZYBO__B_UART__AM_SW_BYTE_BYTE 1
#define ZYBO__B_UART__AM_SW_DETECT_TO_BUFFER 2
#define ZYBO__B_UART__AM_HW_BYTE_BY_BYTE 3
#define ZYBO__B_UART__AM_HW_DETECT_TO_BUFFER 4
#define ZYBO__B_UART__AM_NONE 0

#define ZYBO__B_UART__NONE_REVB 0
#define ZYBO__B_UART__EVEN_REVB 1
#define ZYBO__B_UART__ODD_REVB 2
#define ZYBO__B_UART__MARK_SPACE_REVB 3



/***************************************
*    Initial Parameter Constants
***************************************/

/* UART shifts max 8 bits, Mark/Space functionality working if 9 selected */
#define ZYBO_NUMBER_OF_DATA_BITS    ((8u > 8u) ? 8u : 8u)
#define ZYBO_NUMBER_OF_STOP_BITS    (1u)

#if (ZYBO_RXHW_ADDRESS_ENABLED)
    #define ZYBO_RX_ADDRESS_MODE    (0u)
    #define ZYBO_RX_HW_ADDRESS1     (0u)
    #define ZYBO_RX_HW_ADDRESS2     (0u)
#endif /* (ZYBO_RXHW_ADDRESS_ENABLED) */

#define ZYBO_INIT_RX_INTERRUPTS_MASK \
                                  (uint8)((1 << ZYBO_RX_STS_FIFO_NOTEMPTY_SHIFT) \
                                        | (0 << ZYBO_RX_STS_MRKSPC_SHIFT) \
                                        | (0 << ZYBO_RX_STS_ADDR_MATCH_SHIFT) \
                                        | (0 << ZYBO_RX_STS_PAR_ERROR_SHIFT) \
                                        | (0 << ZYBO_RX_STS_STOP_ERROR_SHIFT) \
                                        | (0 << ZYBO_RX_STS_BREAK_SHIFT) \
                                        | (0 << ZYBO_RX_STS_OVERRUN_SHIFT))

#define ZYBO_INIT_TX_INTERRUPTS_MASK \
                                  (uint8)((0 << ZYBO_TX_STS_COMPLETE_SHIFT) \
                                        | (1 << ZYBO_TX_STS_FIFO_EMPTY_SHIFT) \
                                        | (0 << ZYBO_TX_STS_FIFO_FULL_SHIFT) \
                                        | (0 << ZYBO_TX_STS_FIFO_NOT_FULL_SHIFT))


/***************************************
*              Registers
***************************************/

#ifdef ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG
    #define ZYBO_CONTROL_REG \
                            (* (reg8 *) ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG )
    #define ZYBO_CONTROL_PTR \
                            (  (reg8 *) ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG )
#endif /* End ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG */

#if(ZYBO_TX_ENABLED)
    #define ZYBO_TXDATA_REG          (* (reg8 *) ZYBO_BUART_sTX_TxShifter_u0__F0_REG)
    #define ZYBO_TXDATA_PTR          (  (reg8 *) ZYBO_BUART_sTX_TxShifter_u0__F0_REG)
    #define ZYBO_TXDATA_AUX_CTL_REG  (* (reg8 *) ZYBO_BUART_sTX_TxShifter_u0__DP_AUX_CTL_REG)
    #define ZYBO_TXDATA_AUX_CTL_PTR  (  (reg8 *) ZYBO_BUART_sTX_TxShifter_u0__DP_AUX_CTL_REG)
    #define ZYBO_TXSTATUS_REG        (* (reg8 *) ZYBO_BUART_sTX_TxSts__STATUS_REG)
    #define ZYBO_TXSTATUS_PTR        (  (reg8 *) ZYBO_BUART_sTX_TxSts__STATUS_REG)
    #define ZYBO_TXSTATUS_MASK_REG   (* (reg8 *) ZYBO_BUART_sTX_TxSts__MASK_REG)
    #define ZYBO_TXSTATUS_MASK_PTR   (  (reg8 *) ZYBO_BUART_sTX_TxSts__MASK_REG)
    #define ZYBO_TXSTATUS_ACTL_REG   (* (reg8 *) ZYBO_BUART_sTX_TxSts__STATUS_AUX_CTL_REG)
    #define ZYBO_TXSTATUS_ACTL_PTR   (  (reg8 *) ZYBO_BUART_sTX_TxSts__STATUS_AUX_CTL_REG)

    /* DP clock */
    #if(ZYBO_TXCLKGEN_DP)
        #define ZYBO_TXBITCLKGEN_CTR_REG        \
                                        (* (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitClkGen__D0_REG)
        #define ZYBO_TXBITCLKGEN_CTR_PTR        \
                                        (  (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitClkGen__D0_REG)
        #define ZYBO_TXBITCLKTX_COMPLETE_REG    \
                                        (* (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitClkGen__D1_REG)
        #define ZYBO_TXBITCLKTX_COMPLETE_PTR    \
                                        (  (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitClkGen__D1_REG)
    #else     /* Count7 clock*/
        #define ZYBO_TXBITCTR_PERIOD_REG    \
                                        (* (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitCounter__PERIOD_REG)
        #define ZYBO_TXBITCTR_PERIOD_PTR    \
                                        (  (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitCounter__PERIOD_REG)
        #define ZYBO_TXBITCTR_CONTROL_REG   \
                                        (* (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitCounter__CONTROL_AUX_CTL_REG)
        #define ZYBO_TXBITCTR_CONTROL_PTR   \
                                        (  (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitCounter__CONTROL_AUX_CTL_REG)
        #define ZYBO_TXBITCTR_COUNTER_REG   \
                                        (* (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitCounter__COUNT_REG)
        #define ZYBO_TXBITCTR_COUNTER_PTR   \
                                        (  (reg8 *) ZYBO_BUART_sTX_sCLOCK_TxBitCounter__COUNT_REG)
    #endif /* ZYBO_TXCLKGEN_DP */

#endif /* End ZYBO_TX_ENABLED */

#if(ZYBO_HD_ENABLED)

    #define ZYBO_TXDATA_REG             (* (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__F1_REG )
    #define ZYBO_TXDATA_PTR             (  (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__F1_REG )
    #define ZYBO_TXDATA_AUX_CTL_REG     (* (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__DP_AUX_CTL_REG)
    #define ZYBO_TXDATA_AUX_CTL_PTR     (  (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__DP_AUX_CTL_REG)

    #define ZYBO_TXSTATUS_REG           (* (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_REG )
    #define ZYBO_TXSTATUS_PTR           (  (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_REG )
    #define ZYBO_TXSTATUS_MASK_REG      (* (reg8 *) ZYBO_BUART_sRX_RxSts__MASK_REG )
    #define ZYBO_TXSTATUS_MASK_PTR      (  (reg8 *) ZYBO_BUART_sRX_RxSts__MASK_REG )
    #define ZYBO_TXSTATUS_ACTL_REG      (* (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_AUX_CTL_REG )
    #define ZYBO_TXSTATUS_ACTL_PTR      (  (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_AUX_CTL_REG )
#endif /* End ZYBO_HD_ENABLED */

#if( (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) )
    #define ZYBO_RXDATA_REG             (* (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__F0_REG )
    #define ZYBO_RXDATA_PTR             (  (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__F0_REG )
    #define ZYBO_RXADDRESS1_REG         (* (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__D0_REG )
    #define ZYBO_RXADDRESS1_PTR         (  (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__D0_REG )
    #define ZYBO_RXADDRESS2_REG         (* (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__D1_REG )
    #define ZYBO_RXADDRESS2_PTR         (  (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__D1_REG )
    #define ZYBO_RXDATA_AUX_CTL_REG     (* (reg8 *) ZYBO_BUART_sRX_RxShifter_u0__DP_AUX_CTL_REG)

    #define ZYBO_RXBITCTR_PERIOD_REG    (* (reg8 *) ZYBO_BUART_sRX_RxBitCounter__PERIOD_REG )
    #define ZYBO_RXBITCTR_PERIOD_PTR    (  (reg8 *) ZYBO_BUART_sRX_RxBitCounter__PERIOD_REG )
    #define ZYBO_RXBITCTR_CONTROL_REG   \
                                        (* (reg8 *) ZYBO_BUART_sRX_RxBitCounter__CONTROL_AUX_CTL_REG )
    #define ZYBO_RXBITCTR_CONTROL_PTR   \
                                        (  (reg8 *) ZYBO_BUART_sRX_RxBitCounter__CONTROL_AUX_CTL_REG )
    #define ZYBO_RXBITCTR_COUNTER_REG   (* (reg8 *) ZYBO_BUART_sRX_RxBitCounter__COUNT_REG )
    #define ZYBO_RXBITCTR_COUNTER_PTR   (  (reg8 *) ZYBO_BUART_sRX_RxBitCounter__COUNT_REG )

    #define ZYBO_RXSTATUS_REG           (* (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_REG )
    #define ZYBO_RXSTATUS_PTR           (  (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_REG )
    #define ZYBO_RXSTATUS_MASK_REG      (* (reg8 *) ZYBO_BUART_sRX_RxSts__MASK_REG )
    #define ZYBO_RXSTATUS_MASK_PTR      (  (reg8 *) ZYBO_BUART_sRX_RxSts__MASK_REG )
    #define ZYBO_RXSTATUS_ACTL_REG      (* (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_AUX_CTL_REG )
    #define ZYBO_RXSTATUS_ACTL_PTR      (  (reg8 *) ZYBO_BUART_sRX_RxSts__STATUS_AUX_CTL_REG )
#endif /* End  (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) */

#if(ZYBO_INTERNAL_CLOCK_USED)
    /* Register to enable or disable the digital clocks */
    #define ZYBO_INTCLOCK_CLKEN_REG     (* (reg8 *) ZYBO_IntClock__PM_ACT_CFG)
    #define ZYBO_INTCLOCK_CLKEN_PTR     (  (reg8 *) ZYBO_IntClock__PM_ACT_CFG)

    /* Clock mask for this clock. */
    #define ZYBO_INTCLOCK_CLKEN_MASK    ZYBO_IntClock__PM_ACT_MSK
#endif /* End ZYBO_INTERNAL_CLOCK_USED */


/***************************************
*       Register Constants
***************************************/

#if(ZYBO_TX_ENABLED)
    #define ZYBO_TX_FIFO_CLR            (0x01u) /* FIFO0 CLR */
#endif /* End ZYBO_TX_ENABLED */

#if(ZYBO_HD_ENABLED)
    #define ZYBO_TX_FIFO_CLR            (0x02u) /* FIFO1 CLR */
#endif /* End ZYBO_HD_ENABLED */

#if( (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) )
    #define ZYBO_RX_FIFO_CLR            (0x01u) /* FIFO0 CLR */
#endif /* End  (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) */


/***************************************
* The following code is DEPRECATED and
* should not be used in new projects.
***************************************/

/* UART v2_40 obsolete definitions */
#define ZYBO_WAIT_1_MS      ZYBO_BL_CHK_DELAY_MS   

#define ZYBO_TXBUFFERSIZE   ZYBO_TX_BUFFER_SIZE
#define ZYBO_RXBUFFERSIZE   ZYBO_RX_BUFFER_SIZE

#if (ZYBO_RXHW_ADDRESS_ENABLED)
    #define ZYBO_RXADDRESSMODE  ZYBO_RX_ADDRESS_MODE
    #define ZYBO_RXHWADDRESS1   ZYBO_RX_HW_ADDRESS1
    #define ZYBO_RXHWADDRESS2   ZYBO_RX_HW_ADDRESS2
    /* Backward compatible define */
    #define ZYBO_RXAddressMode  ZYBO_RXADDRESSMODE
#endif /* (ZYBO_RXHW_ADDRESS_ENABLED) */

/* UART v2_30 obsolete definitions */
#define ZYBO_initvar                    ZYBO_initVar

#define ZYBO_RX_Enabled                 ZYBO_RX_ENABLED
#define ZYBO_TX_Enabled                 ZYBO_TX_ENABLED
#define ZYBO_HD_Enabled                 ZYBO_HD_ENABLED
#define ZYBO_RX_IntInterruptEnabled     ZYBO_RX_INTERRUPT_ENABLED
#define ZYBO_TX_IntInterruptEnabled     ZYBO_TX_INTERRUPT_ENABLED
#define ZYBO_InternalClockUsed          ZYBO_INTERNAL_CLOCK_USED
#define ZYBO_RXHW_Address_Enabled       ZYBO_RXHW_ADDRESS_ENABLED
#define ZYBO_OverSampleCount            ZYBO_OVER_SAMPLE_COUNT
#define ZYBO_ParityType                 ZYBO_PARITY_TYPE

#if( ZYBO_TX_ENABLED && (ZYBO_TXBUFFERSIZE > ZYBO_FIFO_LENGTH))
    #define ZYBO_TXBUFFER               ZYBO_txBuffer
    #define ZYBO_TXBUFFERREAD           ZYBO_txBufferRead
    #define ZYBO_TXBUFFERWRITE          ZYBO_txBufferWrite
#endif /* End ZYBO_TX_ENABLED */
#if( ( ZYBO_RX_ENABLED || ZYBO_HD_ENABLED ) && \
     (ZYBO_RXBUFFERSIZE > ZYBO_FIFO_LENGTH) )
    #define ZYBO_RXBUFFER               ZYBO_rxBuffer
    #define ZYBO_RXBUFFERREAD           ZYBO_rxBufferRead
    #define ZYBO_RXBUFFERWRITE          ZYBO_rxBufferWrite
    #define ZYBO_RXBUFFERLOOPDETECT     ZYBO_rxBufferLoopDetect
    #define ZYBO_RXBUFFER_OVERFLOW      ZYBO_rxBufferOverflow
#endif /* End ZYBO_RX_ENABLED */

#ifdef ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG
    #define ZYBO_CONTROL                ZYBO_CONTROL_REG
#endif /* End ZYBO_BUART_sCR_SyncCtl_CtrlReg__CONTROL_REG */

#if(ZYBO_TX_ENABLED)
    #define ZYBO_TXDATA                 ZYBO_TXDATA_REG
    #define ZYBO_TXSTATUS               ZYBO_TXSTATUS_REG
    #define ZYBO_TXSTATUS_MASK          ZYBO_TXSTATUS_MASK_REG
    #define ZYBO_TXSTATUS_ACTL          ZYBO_TXSTATUS_ACTL_REG
    /* DP clock */
    #if(ZYBO_TXCLKGEN_DP)
        #define ZYBO_TXBITCLKGEN_CTR        ZYBO_TXBITCLKGEN_CTR_REG
        #define ZYBO_TXBITCLKTX_COMPLETE    ZYBO_TXBITCLKTX_COMPLETE_REG
    #else     /* Count7 clock*/
        #define ZYBO_TXBITCTR_PERIOD        ZYBO_TXBITCTR_PERIOD_REG
        #define ZYBO_TXBITCTR_CONTROL       ZYBO_TXBITCTR_CONTROL_REG
        #define ZYBO_TXBITCTR_COUNTER       ZYBO_TXBITCTR_COUNTER_REG
    #endif /* ZYBO_TXCLKGEN_DP */
#endif /* End ZYBO_TX_ENABLED */

#if(ZYBO_HD_ENABLED)
    #define ZYBO_TXDATA                 ZYBO_TXDATA_REG
    #define ZYBO_TXSTATUS               ZYBO_TXSTATUS_REG
    #define ZYBO_TXSTATUS_MASK          ZYBO_TXSTATUS_MASK_REG
    #define ZYBO_TXSTATUS_ACTL          ZYBO_TXSTATUS_ACTL_REG
#endif /* End ZYBO_HD_ENABLED */

#if( (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) )
    #define ZYBO_RXDATA                 ZYBO_RXDATA_REG
    #define ZYBO_RXADDRESS1             ZYBO_RXADDRESS1_REG
    #define ZYBO_RXADDRESS2             ZYBO_RXADDRESS2_REG
    #define ZYBO_RXBITCTR_PERIOD        ZYBO_RXBITCTR_PERIOD_REG
    #define ZYBO_RXBITCTR_CONTROL       ZYBO_RXBITCTR_CONTROL_REG
    #define ZYBO_RXBITCTR_COUNTER       ZYBO_RXBITCTR_COUNTER_REG
    #define ZYBO_RXSTATUS               ZYBO_RXSTATUS_REG
    #define ZYBO_RXSTATUS_MASK          ZYBO_RXSTATUS_MASK_REG
    #define ZYBO_RXSTATUS_ACTL          ZYBO_RXSTATUS_ACTL_REG
#endif /* End  (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) */

#if(ZYBO_INTERNAL_CLOCK_USED)
    #define ZYBO_INTCLOCK_CLKEN         ZYBO_INTCLOCK_CLKEN_REG
#endif /* End ZYBO_INTERNAL_CLOCK_USED */

#define ZYBO_WAIT_FOR_COMLETE_REINIT    ZYBO_WAIT_FOR_COMPLETE_REINIT

#endif  /* CY_UART_ZYBO_H */


/* [] END OF FILE */
