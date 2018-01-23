SELECT
	b.B1_ALT_ID CaseNo
    ,(
    	SELECT
    		COUNT(gph.SD_APP_DD)
    	FROM GPROCESS_HISTORY gph
    	WHERE
    		2=2
    		AND gph.SERV_PROV_CODE = b.SERV_PROV_CODE
    		AND gph.B1_PER_ID1 = b.B1_PER_ID1
    		AND gph.B1_PER_ID2 = b.B1_PER_ID2
    		AND gph.B1_PER_ID3 = b.B1_PER_ID3
    		AND gph.REC_STATUS = 'A'
    		AND gph.SD_PRO_DES = 'Plan Checker Review'
    		AND gph.SD_APP_DES = 'Received for Review'
    ) subCount
    ,gphV.statDate DateIn
    ,TO_CHAR(TO_DATE(SYSDATE) - TO_DATE(gphV.statDate)) NbrDaysOpen
    ,bwd.B1_WORK_DESC Description
    ,g3s.GA_FNAME||' '||g3s.GA_LNAME asgnUser
    ,DECODE(NVL(bc.B1_CHECKLIST_COMMENT,'UNCHECKED'),'CHECKED','Y','UNCHECKED','N') expdYN
    ,b.B1_PER_ID1
    ,b.B1_PER_ID2
    ,b.B1_PER_ID3
from B1PERMIT b 
LEFT OUTER JOIN BPERMIT_DETAIL bpd ON
	b.SERV_PROV_CODE = bpd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bpd.B1_PER_ID1
	AND b.B1_PER_ID2 = bpd.B1_PER_ID2
	AND b.B1_PER_ID3 = bpd.B1_PER_ID3
	AND b.REC_STATUS = bpd.REC_STATUS
	LEFT OUTER JOIN G3STAFFS g3s ON
		bpd.SERV_PROV_CODE = g3s.SERV_PROV_CODE
		AND bpd.REC_STATUS = g3s.REC_STATUS
		AND bpd.B1_ASGN_STAFF = g3s.GA_USER_ID
LEFT OUTER JOIN BCHCKBOX bc ON
	b.SERV_PROV_CODE = bc.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bc.B1_PER_ID1
	AND b.B1_PER_ID2 = bc.B1_PER_ID2
	AND b.B1_PER_ID3 = bc.B1_PER_ID3
	AND b.REC_STATUS = bc.REC_STATUS
	AND bc.B1_CHECKBOX_TYPE = 'PROJECT INFORMATION'
	AND bc.B1_CHECKBOX_DESC = 'Pay Expedited Fees'
LEFT OUTER JOIN (
	SELECT
		gph.SERV_PROV_CODE
		,gph.B1_PER_ID1
		,gph.B1_PER_ID2
		,gph.B1_PER_ID3
		,gph.SD_APP_DD statDate
	FROM GPROCESS_HISTORY gph 
	WHERE
		2=2
		AND gph.SERV_PROV_CODE = 'SANTACLARITA'
		AND gph.REC_STATUS = 'A'
		AND gph.SD_PRO_DES = 'Plan Checker Review'
		AND gph.SD_APP_DES = 'Received for Review'
		AND gph.SD_APP_DD = (
			SELECT
				MAX(gphS.SD_APP_DD)
			FROM GPROCESS_HISTORY gphS
			WHERE
				2=2
				AND gphS.SERV_PROV_CODE = gph.SERV_PROV_CODE
				AND gphS.B1_PER_ID1 = gph.B1_PER_ID1
				AND gphS.B1_PER_ID2 = gph.B1_PER_ID2
				AND gphS.B1_PER_ID3 = gph.B1_PER_ID3
				AND gphS.REC_STATUS = gph.REC_STATUS
				AND gphS.SD_PRO_DES = 'Plan Checker Review'
				AND gphS.SD_APP_DES = 'Received for Review'
			)
) gphV ON
	b.SERV_PROV_CODE = gphV.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gphV.B1_PER_ID1
	AND b.B1_PER_ID2 = gphV.B1_PER_ID2
	AND b.B1_PER_ID3 = gphV.B1_PER_ID3
LEFT OUTER JOIN BWORKDES bwd ON
	b.SERV_PROV_CODE = bwd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bwd.B1_PER_ID1
	AND b.B1_PER_ID2 = bwd.B1_PER_ID2
	AND b.B1_PER_ID3 = bwd.B1_PER_ID3
	AND b.REC_STATUS = bwd.REC_STATUS
INNER JOIN GPROCESS gp ON
	b.SERV_PROV_CODE = gp.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp.B1_PER_ID1
	AND b.B1_PER_ID2 = gp.B1_PER_ID2
	AND b.B1_PER_ID3 = gp.B1_PER_ID3
	AND b.REC_STATUS = gp.REC_STATUS
	AND gp.SD_PRO_DES = 'Plan Checker Review'
	AND gp.SD_CHK_LV1 = 'Y'
	AND gp.SD_CHK_LV2 = 'N'
	
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP='Eng_Services'
