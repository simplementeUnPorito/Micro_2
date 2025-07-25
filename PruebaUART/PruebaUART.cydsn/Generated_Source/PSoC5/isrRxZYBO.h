/*******************************************************************************
* File Name: isrRxZYBO.h
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
#if !defined(CY_ISR_isrRxZYBO_H)
#define CY_ISR_isrRxZYBO_H


#include <cytypes.h>
#include <cyfitter.h>

/* Interrupt Controller API. */
void isrRxZYBO_Start(void);
void isrRxZYBO_StartEx(cyisraddress address);
void isrRxZYBO_Stop(void);

CY_ISR_PROTO(isrRxZYBO_Interrupt);

void isrRxZYBO_SetVector(cyisraddress address);
cyisraddress isrRxZYBO_GetVector(void);

void isrRxZYBO_SetPriority(uint8 priority);
uint8 isrRxZYBO_GetPriority(void);

void isrRxZYBO_Enable(void);
uint8 isrRxZYBO_GetState(void);
void isrRxZYBO_Disable(void);

void isrRxZYBO_SetPending(void);
void isrRxZYBO_ClearPending(void);


/* Interrupt Controller Constants */

/* Address of the INTC.VECT[x] register that contains the Address of the isrRxZYBO ISR. */
#define isrRxZYBO_INTC_VECTOR            ((reg32 *) isrRxZYBO__INTC_VECT)

/* Address of the isrRxZYBO ISR priority. */
#define isrRxZYBO_INTC_PRIOR             ((reg8 *) isrRxZYBO__INTC_PRIOR_REG)

/* Priority of the isrRxZYBO interrupt. */
#define isrRxZYBO_INTC_PRIOR_NUMBER      isrRxZYBO__INTC_PRIOR_NUM

/* Address of the INTC.SET_EN[x] byte to bit enable isrRxZYBO interrupt. */
#define isrRxZYBO_INTC_SET_EN            ((reg32 *) isrRxZYBO__INTC_SET_EN_REG)

/* Address of the INTC.CLR_EN[x] register to bit clear the isrRxZYBO interrupt. */
#define isrRxZYBO_INTC_CLR_EN            ((reg32 *) isrRxZYBO__INTC_CLR_EN_REG)

/* Address of the INTC.SET_PD[x] register to set the isrRxZYBO interrupt state to pending. */
#define isrRxZYBO_INTC_SET_PD            ((reg32 *) isrRxZYBO__INTC_SET_PD_REG)

/* Address of the INTC.CLR_PD[x] register to clear the isrRxZYBO interrupt. */
#define isrRxZYBO_INTC_CLR_PD            ((reg32 *) isrRxZYBO__INTC_CLR_PD_REG)


#endif /* CY_ISR_isrRxZYBO_H */


/* [] END OF FILE */
