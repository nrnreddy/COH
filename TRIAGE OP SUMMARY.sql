USE [Clarity_POC_Report]
GO


/* HB Extract for Triage file: IP Summary
Developer: Raj Nandyala
Date: 06/20/2017 
Business Contact: Anup Parikh
Vendor Contact: Sam Adams [SamA@triageconsulting.com]*/

WITH IP_SUMMARY
AS (SELECT har.ADM_DATE_TIME,
           har.DISCH_DATE_TIME,
           har.HSP_ACCOUNT_ID,
           DATEDIFF(DAY, har.ADM_DATE_TIME, har.DISCH_DATE_TIME) LOS,
           hadm.ADMIT_DX_ID,
           har.TOT_CHGS,
           har.TOT_ACCT_BAL,
           '' AS ACTREIMB,
           pat.PAT_NAME,
           pat.BIRTH_DATE,
           pat.SEX_C,
           pat.PAT_MRN_ID,
           har.ADMISSION_SOURCE_C,
           peh.DISP_C,
           har.ADMISSION_TYPE_C,
           har.ADM_DATE_TIME AS inp_adm_date,
           har.DISCH_DATE_TIME AS distime,
           har.CODING_STATUS_C,
           har.ACCT_CLASS_HA_C,
           pat.ADD_LINE_1,
           pat.CITY,
           pat.STATE_C,
           pat.ZIP,
           pat.SSN,
           'Minortype' AS Minortype,
           'MinorDesc' AS MinorDesc,
           hadm.ADMIT_DX_ID AS ADMITDX,
           hdd.DX_ID AS DISDX_CODE,
           PEH.HOSP_SERV_C,
           har.FINAL_DRG_ID,
           har.ACCT_FIN_CLASS_C,
           har.LOC_ID
    FROM dbo.HSP_ACCOUNT har
        INNER JOIN dbo.PATIENT pat
            ON har.PAT_ID = pat.PAT_ID
        LEFT JOIN
         (
             SELECT peh.HSP_ACCOUNT_ID,
                    MAX(ddisp.DISCH_DISP_C) DISP_C,
                    MAX(ddisp.NAME) AS disp_name,
					MAX(PEH.HOSP_SERV_C) HOSP_SERV_C
             FROM dbo.PAT_ENC_HSP peh
                 LEFT JOIN dbo.ZC_DISCH_DISP ddisp
                     ON peh.DISCH_DISP_C = ddisp.DISCH_DISP_C
             GROUP BY peh.HSP_ACCOUNT_ID
         ) peh
            ON har.HSP_ACCOUNT_ID = peh.HSP_ACCOUNT_ID
        LEFT JOIN dbo.HSP_ACCT_ADMIT_DX hadm
            ON har.HSP_ACCOUNT_ID = hadm.HSP_ACCOUNT_ID
               AND hadm.LINE = 1
        LEFT JOIN dbo.HSP_DISCH_DIAG hdd
            ON har.PRIM_ENC_CSN_ID = hdd.PAT_ENC_CSN_ID
               AND hdd.LINE = 1
	WHERE HAR.ACCT_BASECLS_HA_C NOT IN ('1')
   )
SELECT ips.*
 --   ROW_NUMBER() OVER (PARTITION BY IPS.HSP_ACCOUNT_ID ORDER BY IPS.PAT_NAME) AS rownum
FROM IP_SUMMARY IPS
WHERE 
      IPS.DISCH_DATE_TIME >= EPIC_UTIL.EFN_DIN('mb-1')
      AND IPS.DISCH_DATE_TIME <= EPIC_UTIL.EFN_DIN('me-1')





