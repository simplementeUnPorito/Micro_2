/*******************************************************************************
* File Name: ZYBO_PM.c
* Version 2.50
*
* Description:
*  This file provides Sleep/WakeUp APIs functionality.
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


/***************************************
* Local data allocation
***************************************/

static ZYBO_BACKUP_STRUCT  ZYBO_backup =
{
    /* enableState - disabled */
    0u,
};



/*******************************************************************************
* Function Name: ZYBO_SaveConfig
********************************************************************************
*
* Summary:
*  This function saves the component nonretention control register.
*  Does not save the FIFO which is a set of nonretention registers.
*  This function is called by the ZYBO_Sleep() function.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  ZYBO_backup - modified when non-retention registers are saved.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void ZYBO_SaveConfig(void)
{
    #if(ZYBO_CONTROL_REG_REMOVED == 0u)
        ZYBO_backup.cr = ZYBO_CONTROL_REG;
    #endif /* End ZYBO_CONTROL_REG_REMOVED */
}


/*******************************************************************************
* Function Name: ZYBO_RestoreConfig
********************************************************************************
*
* Summary:
*  Restores the nonretention control register except FIFO.
*  Does not restore the FIFO which is a set of nonretention registers.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  ZYBO_backup - used when non-retention registers are restored.
*
* Reentrant:
*  No.
*
* Notes:
*  If this function is called without calling ZYBO_SaveConfig() 
*  first, the data loaded may be incorrect.
*
*******************************************************************************/
void ZYBO_RestoreConfig(void)
{
    #if(ZYBO_CONTROL_REG_REMOVED == 0u)
        ZYBO_CONTROL_REG = ZYBO_backup.cr;
    #endif /* End ZYBO_CONTROL_REG_REMOVED */
}


/*******************************************************************************
* Function Name: ZYBO_Sleep
********************************************************************************
*
* Summary:
*  This is the preferred API to prepare the component for sleep. 
*  The ZYBO_Sleep() API saves the current component state. Then it
*  calls the ZYBO_Stop() function and calls 
*  ZYBO_SaveConfig() to save the hardware configuration.
*  Call the ZYBO_Sleep() function before calling the CyPmSleep() 
*  or the CyPmHibernate() function. 
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  ZYBO_backup - modified when non-retention registers are saved.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void ZYBO_Sleep(void)
{
    #if(ZYBO_RX_ENABLED || ZYBO_HD_ENABLED)
        if((ZYBO_RXSTATUS_ACTL_REG  & ZYBO_INT_ENABLE) != 0u)
        {
            ZYBO_backup.enableState = 1u;
        }
        else
        {
            ZYBO_backup.enableState = 0u;
        }
    #else
        if((ZYBO_TXSTATUS_ACTL_REG  & ZYBO_INT_ENABLE) !=0u)
        {
            ZYBO_backup.enableState = 1u;
        }
        else
        {
            ZYBO_backup.enableState = 0u;
        }
    #endif /* End ZYBO_RX_ENABLED || ZYBO_HD_ENABLED*/

    ZYBO_Stop();
    ZYBO_SaveConfig();
}


/*******************************************************************************
* Function Name: ZYBO_Wakeup
********************************************************************************
*
* Summary:
*  This is the preferred API to restore the component to the state when 
*  ZYBO_Sleep() was called. The ZYBO_Wakeup() function
*  calls the ZYBO_RestoreConfig() function to restore the 
*  configuration. If the component was enabled before the 
*  ZYBO_Sleep() function was called, the ZYBO_Wakeup()
*  function will also re-enable the component.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  ZYBO_backup - used when non-retention registers are restored.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void ZYBO_Wakeup(void)
{
    ZYBO_RestoreConfig();
    #if( (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) )
        ZYBO_ClearRxBuffer();
    #endif /* End (ZYBO_RX_ENABLED) || (ZYBO_HD_ENABLED) */
    #if(ZYBO_TX_ENABLED || ZYBO_HD_ENABLED)
        ZYBO_ClearTxBuffer();
    #endif /* End ZYBO_TX_ENABLED || ZYBO_HD_ENABLED */

    if(ZYBO_backup.enableState != 0u)
    {
        ZYBO_Enable();
    }
}


/* [] END OF FILE */
