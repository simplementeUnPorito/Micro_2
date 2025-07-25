/*******************************************************************************
* File Name: VddZYBO.h  
* Version 2.20
*
* Description:
*  This file contains Pin function prototypes and register defines
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_PINS_VddZYBO_H) /* Pins VddZYBO_H */
#define CY_PINS_VddZYBO_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "VddZYBO_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 VddZYBO__PORT == 15 && ((VddZYBO__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    VddZYBO_Write(uint8 value);
void    VddZYBO_SetDriveMode(uint8 mode);
uint8   VddZYBO_ReadDataReg(void);
uint8   VddZYBO_Read(void);
void    VddZYBO_SetInterruptMode(uint16 position, uint16 mode);
uint8   VddZYBO_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the VddZYBO_SetDriveMode() function.
     *  @{
     */
        #define VddZYBO_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define VddZYBO_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define VddZYBO_DM_RES_UP          PIN_DM_RES_UP
        #define VddZYBO_DM_RES_DWN         PIN_DM_RES_DWN
        #define VddZYBO_DM_OD_LO           PIN_DM_OD_LO
        #define VddZYBO_DM_OD_HI           PIN_DM_OD_HI
        #define VddZYBO_DM_STRONG          PIN_DM_STRONG
        #define VddZYBO_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define VddZYBO_MASK               VddZYBO__MASK
#define VddZYBO_SHIFT              VddZYBO__SHIFT
#define VddZYBO_WIDTH              1u

/* Interrupt constants */
#if defined(VddZYBO__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in VddZYBO_SetInterruptMode() function.
     *  @{
     */
        #define VddZYBO_INTR_NONE      (uint16)(0x0000u)
        #define VddZYBO_INTR_RISING    (uint16)(0x0001u)
        #define VddZYBO_INTR_FALLING   (uint16)(0x0002u)
        #define VddZYBO_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define VddZYBO_INTR_MASK      (0x01u) 
#endif /* (VddZYBO__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define VddZYBO_PS                     (* (reg8 *) VddZYBO__PS)
/* Data Register */
#define VddZYBO_DR                     (* (reg8 *) VddZYBO__DR)
/* Port Number */
#define VddZYBO_PRT_NUM                (* (reg8 *) VddZYBO__PRT) 
/* Connect to Analog Globals */                                                  
#define VddZYBO_AG                     (* (reg8 *) VddZYBO__AG)                       
/* Analog MUX bux enable */
#define VddZYBO_AMUX                   (* (reg8 *) VddZYBO__AMUX) 
/* Bidirectional Enable */                                                        
#define VddZYBO_BIE                    (* (reg8 *) VddZYBO__BIE)
/* Bit-mask for Aliased Register Access */
#define VddZYBO_BIT_MASK               (* (reg8 *) VddZYBO__BIT_MASK)
/* Bypass Enable */
#define VddZYBO_BYP                    (* (reg8 *) VddZYBO__BYP)
/* Port wide control signals */                                                   
#define VddZYBO_CTL                    (* (reg8 *) VddZYBO__CTL)
/* Drive Modes */
#define VddZYBO_DM0                    (* (reg8 *) VddZYBO__DM0) 
#define VddZYBO_DM1                    (* (reg8 *) VddZYBO__DM1)
#define VddZYBO_DM2                    (* (reg8 *) VddZYBO__DM2) 
/* Input Buffer Disable Override */
#define VddZYBO_INP_DIS                (* (reg8 *) VddZYBO__INP_DIS)
/* LCD Common or Segment Drive */
#define VddZYBO_LCD_COM_SEG            (* (reg8 *) VddZYBO__LCD_COM_SEG)
/* Enable Segment LCD */
#define VddZYBO_LCD_EN                 (* (reg8 *) VddZYBO__LCD_EN)
/* Slew Rate Control */
#define VddZYBO_SLW                    (* (reg8 *) VddZYBO__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define VddZYBO_PRTDSI__CAPS_SEL       (* (reg8 *) VddZYBO__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define VddZYBO_PRTDSI__DBL_SYNC_IN    (* (reg8 *) VddZYBO__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define VddZYBO_PRTDSI__OE_SEL0        (* (reg8 *) VddZYBO__PRTDSI__OE_SEL0) 
#define VddZYBO_PRTDSI__OE_SEL1        (* (reg8 *) VddZYBO__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define VddZYBO_PRTDSI__OUT_SEL0       (* (reg8 *) VddZYBO__PRTDSI__OUT_SEL0) 
#define VddZYBO_PRTDSI__OUT_SEL1       (* (reg8 *) VddZYBO__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define VddZYBO_PRTDSI__SYNC_OUT       (* (reg8 *) VddZYBO__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(VddZYBO__SIO_CFG)
    #define VddZYBO_SIO_HYST_EN        (* (reg8 *) VddZYBO__SIO_HYST_EN)
    #define VddZYBO_SIO_REG_HIFREQ     (* (reg8 *) VddZYBO__SIO_REG_HIFREQ)
    #define VddZYBO_SIO_CFG            (* (reg8 *) VddZYBO__SIO_CFG)
    #define VddZYBO_SIO_DIFF           (* (reg8 *) VddZYBO__SIO_DIFF)
#endif /* (VddZYBO__SIO_CFG) */

/* Interrupt Registers */
#if defined(VddZYBO__INTSTAT)
    #define VddZYBO_INTSTAT            (* (reg8 *) VddZYBO__INTSTAT)
    #define VddZYBO_SNAP               (* (reg8 *) VddZYBO__SNAP)
    
	#define VddZYBO_0_INTTYPE_REG 		(* (reg8 *) VddZYBO__0__INTTYPE)
#endif /* (VddZYBO__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_VddZYBO_H */


/* [] END OF FILE */
