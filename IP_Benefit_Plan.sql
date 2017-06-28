
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


SELECT
 t1.BILL_ACCT_NO as acctno,
  t2.BENE_PLN_ID paycode,
  t2.BENE_PLN_DESC as paydesc,
  t3.CVRG_ID as coverage_id,
  t1.PAYOR_RANK as payprior,
  t1.POLICY_NO as groupno,
  t4.EMPER_NM as employer,
  t5.SUBSCR_ID as subno,
  t4.EMPER_CD as employer_code_groupno,
  t1.ENC_BILL_PAYOR_AUTH_INFO as authorization,
  Sum(t1.TOT_PAY_AMT) payment_amount,
  t2.FIN_CLASS as finclass,
  t2.FIN_CLASS_DESC as finname
FROM
  APPL_STAR.ENC_BILL_PAYOR_FACT            t1,
  APPL_STAR.BENE_PLN_DIM                             t2,
  APPL_STAR.CVRG_DIM                                      t3,
  APPL_STAR.EMPER_DIM                                    t4,
  APPL_STAR.SUBSCR_DIM                                 t5
WHERE
EXISTS(SELECT NULL
     from
	  APPL_STAR.ENC_BILL_FACT    z1,
       APPL_STAR.PT_TYP_DIM            z2,
       APPL_STAR.DT_DIM                     z3
   WHERE 
        z1.DSCH_DT_SK=z3.DT_SK    and
       z1.PT_TYP_SK=z2.PT_TYP_SK      AND  
       z2.PT_TYP   IN  ( '1'  )        AND
        z3.CAL_DT  BETWEEN  &sqldate1 and &sqldate2    and
		z1.TOT_CHG  >=  1                                                 and
         t1.BILL_ACCT_NO=z1.BILL_ACCT_NO )                           and
   t1.BENE_PLN_SK=t2.BENE_PLN_SK                            AND 
   t2.BENE_PLN_SRC_SYS <> 'IDX'    AND 
    t1.LOGICAL_DEL_REC_FLAG<> 'Y'  AND
   t5.SUBSCR_SK=t1.SUBSCR_SK  AND 
  t5.SUBSCR_EMPER_SK=t4.EMPER_SK    AND 
  t5.CVRG_SK=t3.CVRG_SK
 group by
 t1.BILL_ACCT_NO,t2.BENE_PLN_ID,t2.BENE_PLN_DESC,
  t3.CVRG_ID,t1.PAYOR_RANK,t1.POLICY_NO,t4.EMPER_NM,
  t5.SUBSCR_ID,t4.EMPER_CD,t1.ENC_BILL_PAYOR_AUTH_INFO,
  t2.FIN_CLASS,t2.FIN_CLASS_DESC   