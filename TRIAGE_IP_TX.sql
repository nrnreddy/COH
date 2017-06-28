


USE [Clarity_POC_Report]
GO


/* HB Extract for Triage file: IP TRANSACTION 
Developer: Raj Nandyala
Date: 06/20/2017 
Business Contact: Anup Parikh
Vendor Contact: Sam Adams [SamA@triageconsulting.com]*/


SELECT har.hsp_account_id    AS ACCTNO,
       HSP_TX.tx_type_ha_c   AS TXTYPE,
       TX_TYPE.NAME          AS TXDESC,
       EAP.proc_code         AS EAP,
       EAP.proc_name         AS EAP_DESC,
       HSP_TX.tx_amount      AS CHARGE,
       HSP_TX.quantity       AS QUANTITY,
       HSP_TX.service_date   AS SERVDATE,
       HSP_TX.tx_post_date   AS POSTDATE,
       HAR.disch_date_time   AS DISDATE,
       HAR.primary_plan_id   AS PLAN_ID,
       EPP.benefit_plan_name AS PLAN_DESC
FROM   dbo.hsp_account har
       INNER JOIN (SELECT HTR.hsp_account_id,
                          htr.tx_type_ha_c,
                          HTR.proc_id,
                          htr.cpt_code,
                          htr.procedure_desc,
                          htr.tx_amount,
                          htr.quantity,
                          htr.service_date,
                          htr.tx_post_date,
                          htr.primary_plan_id
                   FROM   dbo.hsp_transactions htr
                   WHERE  htr.tx_type_ha_c IN ( '2', '3', '4' ))HSP_TX
               ON HAR.hsp_account_id = HSP_TX.hsp_account_id
       LEFT JOIN dbo.zc_tx_type_ha TX_TYPE
              ON HSP_TX.tx_type_ha_c = TX_TYPE.tx_type_ha_c
       LEFT JOIN dbo.clarity_eap EAP
              ON HSP_TX.proc_id = EAP.proc_id
       LEFT JOIN dbo.clarity_epp EPP
              ON HAR.primary_plan_id = EPP.benefit_plan_id
	  
WHERE  HAR.acct_basecls_ha_c = 1
       AND HAR.tot_chgs > 1
	   AND HAR.DISCH_DATE_TIME >= EPIC_UTIL.EFN_DIN('MB-1') 
	   AND HAR.DISCH_DATE_TIME <= EPIC_UTIL.EFN_DIN('ME-1')

