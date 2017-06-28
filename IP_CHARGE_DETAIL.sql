USE [Clarity_POC_Report]

GO

SET ANSI_NULLS ON;
SET NOCOUNT ON;
SET ANSI_WARNINGS ON;

/* HB Extract for Triage file: IP CHARGE DETAIL 
Developer: Raj Nandyala
Date: 06/20/2017 
Business Contact: Anup Parikh
Vendor Contact: Sam Adams [SamA@triageconsulting.com]*/
SELECT HSP_TX.HSP_ACCOUNT_ID  AS ACCTNO,
       HSP_TX.TX_TYPE_HA_C    AS TXTYPE,
       EAP.PROC_CODE          AS EAP,
       EAP.PROC_NAME          AS EAP_DESC,
       HSP_TX.COST_CNTR_ID    AS BCC,
       CCC.COST_CENTER_NAME   AS BCCDESC,
       HSP_TX.ERX_ID          AS MEDICATION_ID,
       CM.NAME                AS MEDICATION_DESC,
       HSP_TX.HCPCS_CODE      AS HCPCS_CD,
       HSP_TX.CPT_CODE        AS CPT_CD,
       HSP_TX.MODIFIERS       AS HMODIFIER_CODE,
       HSP_TX.SERVICE_DATE    AS SERVDATE,
       HSP_TX.TX_POST_DATE    AS POSTDATE,
       HSP_TX.ADM_DATE_TIME   AS ADMDATE,
       HSP_TX.UB_REV_CODE_ID  AS REVCODE,
       CURC.REVENUE_CODE_NAME AS REVDESC,
       HSP_TX.QUANTITY        AS QUANTITY,
       HSP_TX.TX_AMOUNT       AS CHARGE
FROM   (SELECT htr.HSP_ACCOUNT_ID,
               HAR.ADM_DATE_TIME,
               har.PRIMARY_PLAN_ID,
               htr.TX_TYPE_HA_C,
               htr.PROC_ID,
               htr.HCPCS_CODE,
               htr.CHG_ROUTER_SRC_ID,
               htr.COST_CNTR_ID,
               htr.ERX_ID,
               htr.UB_REV_CODE_ID,
               htr.CPT_CODE,
               HTR.MODIFIERS,
               htr.PROCEDURE_DESC,
               htr.TX_AMOUNT,
               htr.QUANTITY,
               htr.SERVICE_DATE,
               htr.TX_POST_DATE
        -- htr.PRIMARY_PLAN_ID
        FROM   dbo.HSP_TRANSACTIONS htr
               INNER JOIN dbo.HSP_ACCOUNT HAR
                       ON HTR.HSP_ACCOUNT_ID = HAR.HSP_ACCOUNT_ID
        WHERE  ( HAR.DISCH_DATE_TIME >= EPIC_UTIL.Efn_din('MB-1')
                 AND HAR.DISCH_DATE_TIME <= EPIC_UTIL.Efn_din('ME-1') )
               AND htr.TX_TYPE_HA_C IN ( '1' )
               AND HAR.ACCT_BASECLS_HA_C = 1
               AND HAR.TOT_CHGS > 1) HSP_TX
       LEFT JOIN dbo.ZC_TX_TYPE_HA TX_TYPE
              ON HSP_TX.TX_TYPE_HA_C = TX_TYPE.TX_TYPE_HA_C
       LEFT JOIN dbo.CLARITY_EAP EAP
              ON HSP_TX.PROC_ID = EAP.PROC_ID
       LEFT JOIN dbo.CLARITY_EPP EPP
              ON HSP_TX.PRIMARY_PLAN_ID = EPP.BENEFIT_PLAN_ID
       LEFT JOIN dbo.CL_COST_CNTR ccc
              ON HSP_TX.COST_CNTR_ID = ccc.COST_CNTR_ID
       LEFT JOIN dbo.clarity_medication cm
              ON hsp_tx.ERX_ID = cm.MEDICATION_ID
       LEFT JOIN dbo.CL_UB_REV_CODE curc
              ON HSP_TX.UB_REV_CODE_ID = curc.UB_REV_CODE_ID 
