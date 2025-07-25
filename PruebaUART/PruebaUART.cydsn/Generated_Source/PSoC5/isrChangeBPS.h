/*******************************************************************************
* File Name: isrChangeBPS.h
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
#if !defined(CY_ISR_isrChangeBPS_H)
#define CY_ISR_isrChangeBPS_H


#include <cytypes.h>
#include <cyfitter.h>

/* Interrupt Controller API. */
void isrChangeBPS_Start(void);
void isrChangeBPS_StartEx(cyisraddress address);
void isrChangeBPS_Stop(void);

CY_ISR_PROTO(isrChangeBPS_Interrupt);

void isrChangeBPS_SetVector(cyisraddress address);
cyisraddress isrChangeBPS_GetVector(void);

void isrChangeBPS_SetPriority(uint8 priority);
uint8 isrChangeBPS_GetPriority(void);

void isrChangeBPS_Enable(void);
uint8 isrChangeBPS_GetState(void);
void isrChangeBPS_Disable(void);

void isrChangeBPS_SetPending(void);
void isrChangeBPS_ClearPending(void);


/* Interrupt Controller Constants */

/* Address of the INTC.VECT[x] register that contains the Address of the isrChangeBPS ISR. */
#define isrChangeBPS_INTC_VECTOR            ((reg32 *) isrChangeBPS__INTC_VECT)

/* Address of the isrChangeBPS ISR priority. */
#define isrChangeBPS_INTC_PRIOR             ((reg8 *) isrChangeBPS__INTC_PRIOR_REG)

/* Priority of the isrChangeBPS interrupt. */
#define isrChangeBPS_INTC_PRIOR_NUMBER      isrChangeBPS__INTC_PRIOR_NUM

/* Address of the INTC.SET_EN[x] byte to bit enable isrChangeBPS interrupt. */
#define isrChangeBPS_INTC_SET_EN            ((reg32 *) isrChangeBPS__INTC_SET_EN_REG)

/* Address of the INTC.CLR_EN[x] register to bit clear the isrChangeBPS interrupt. */
#define isrChangeBPS_INTC_CLR_EN            ((reg32 *) isrChangeBPS__INTC_CLR_EN_REG)

/* Address of the INTC.SET_PD[x] register to set the isrChangeBPS interrupt state to pending. */
#define isrChangeBPS_INTC_SET_PD            ((reg32 *) isrChangeBPS__INTC_SET_PD_REG)

/* Address of the INTC.CLR_PD[x] register to clear the isrChangeBPS interrupt. */
#define isrChangeBPS_INTC_CLR_PD            ((reg32 *) isrChangeBPS__INTC_CLR_PD_REG)


#endif /* CY_ISR_isrChangeBPS_H */


/* [] END OF FILE */
