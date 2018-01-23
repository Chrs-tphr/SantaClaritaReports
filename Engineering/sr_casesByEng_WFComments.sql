SELECT
	gph.SD_COMMENT wfComment
FROM B1PERMIT b
INNER JOIN (
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
LEFT OUTER JOIN GPROCESS_HISTORY gph ON
	b.SERV_PROV_CODE = gph.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gph.B1_PER_ID1
	AND b.B1_PER_ID2 = gph.B1_PER_ID2
	AND b.B1_PER_ID3 = gph.B1_PER_ID3
	AND b.REC_STATUS = gph.REC_STATUS
	AND gph.SD_APP_DD >= gphV.statDate
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND b.B1_PER_ID1 = '{?perId1}'
	AND b.B1_PER_ID2 = '{?perId2}'
	AND b.B1_PER_ID3 = '{?perId3}'