/*******************************************************************************
* File Name: isrRxPC.h
* Version 1.71
*
*  Description:
*   Provides the function definitions for the Interrupt Controller.
*
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/
#if !defined(CY_ISR_isrRxPC_H)
#define CY_ISR_isrRxPC_H


#include <cytypes.h>
#include <cyfitter.h>

/* Interrupt Controller API. */
void isrRxPC_Start(void);
void isrRxPC_StartEx(cyisraddress address);
void isrRxPC_Stop(void);

CY_ISR_PROTO(isrRxPC_Interrupt);

void isrRxPC_SetVector(cyisraddress address);
cyisraddress isrRxPC_GetVector(void);

void isrRxPC_SetPriority(uint8 priority);
uint8 isrRxPC_GetPriority(void);

void isrRxPC_Enable(void);
uint8 isrRxPC_GetState(void);
void isrRxPC_Disable(void);

void isrRxPC_SetPending(void);
void isrRxPC_ClearPending(void);


/* Interrupt Controller Constants */

/* Address of the INTC.VECT[x] register that contains the Address of the isrRxPC ISR. */
#define isrRxPC_INTC_VECTOR            ((reg32 *) isrRxPC__INTC_VECT)

/* Address of the isrRxPC ISR priority. */
#define isrRxPC_INTC_PRIOR             ((reg8 *) isrRxPC__INTC_PRIOR_REG)

/* Priority of the isrRxPC interrupt. */
#define isrRxPC_INTC_PRIOR_NUMBER      isrRxPC__INTC_PRIOR_NUM

/* Address of the INTC.SET_EN[x] byte to bit enable isrRxPC interrupt. */
#define isrRxPC_INTC_SET_EN            ((reg32 *) isrRxPC__INTC_SET_EN_REG)

/* Address of the INTC.CLR_EN[x] register to bit clear the isrRxPC interrupt. */
#define isrRxPC_INTC_CLR_EN            ((reg32 *) isrRxPC__INTC_CLR_EN_REG)

/* Address of the INTC.SET_PD[x] register to set the isrRxPC interrupt state to pending. */
#define isrRxPC_INTC_SET_PD            ((reg32 *) isrRxPC__INTC_SET_PD_REG)

/* Address of the INTC.CLR_PD[x] register to clear the isrRxPC interrupt. */
#define isrRxPC_INTC_CLR_PD            ((reg32 *) isrRxPC__INTC_CLR_PD_REG)


#endif /* CY_ISR_isrRxPC_H */


/* [] END OF FILE */
