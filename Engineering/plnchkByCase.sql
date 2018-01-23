SELECT
	b.B1_ALT_ID recordNbr
	,b.B1_APP_TYPE_ALIAS recordType
	,inDates.inSeqNbr
	,inDates.inDate
	,outDates.outDate
	,outDates.outDate-inDates.inDate turnAround
FROM B1PERMIT b
INNER JOIN(
	SELECT
		gph.SERV_PROV_CODE
		,gph.B1_PER_ID1
		,gph.B1_PER_ID2
		,gph.B1_PER_ID3
		,gph.SD_APP_DD inDate
		,ROW_NUMBER() OVER(PARTITION BY gph.SERV_PROV_CODE ORDER BY gph.GPROCESS_HISTORY_SEQ_NBR) inSeqNbr
	FROM GPROCESS_HISTORY gph
	WHERE
		2=2
		AND gph.SERV_PROV_CODE = 'SANTACLARITA'
		AND gph.REC_STATUS = 'A'
		AND gph.SD_PRO_DES = 'Plan Checker Review'
		AND gph.SD_APP_DES = 'Received for Review'
		AND NOT gph.SD_APP_DD IS NULL
		AND (
				gph.SD_APP_DD >= {?startDate}
				AND gph.SD_APP_DD <= {?endDate}
				)
		) inDates ON
	b.SERV_PROV_CODE = inDates.SERV_PROV_CODE
	AND b.B1_PER_ID1 = inDates.B1_PER_ID1
	AND b.B1_PER_ID2 = inDates.B1_PER_ID2
	AND b.B1_PER_ID3 = inDates.B1_PER_ID3
	INNER JOIN(
		SELECT
			gph2.SERV_PROV_CODE
			,gph2.B1_PER_ID1
			,gph2.B1_PER_ID2
			,gph2.B1_PER_ID3
			,gph2.SD_APP_DD outDate
			,ROW_NUMBER() OVER(PARTITION BY gph2.SERV_PROV_CODE ORDER BY gph2.GPROCESS_HISTORY_SEQ_NBR) outSeqNbr
		FROM GPROCESS_HISTORY gph2
		WHERE
			2=2
			AND gph2.SERV_PROV_CODE = 'SANTACLARITA'
			AND gph2.REC_STATUS = 'A'
			AND gph2.SD_PRO_DES = 'Plan Checker Review'
			AND gph2.SD_APP_DES IN ('Returned for Corrections','Plan Check Complete'
				,'Plan Check Complete/Request Mylars')
			AND NOT gph2.SD_APP_DD IS NULL
			AND gph2.SD_APP_DD >= {?startDate}
			) outDates ON
		inDates.SERV_PROV_CODE = outDates.SERV_PROV_CODE
		AND inDates.B1_PER_ID1 = outDates.B1_PER_ID1
		AND inDates.B1_PER_ID2 = outDates.B1_PER_ID2
		AND inDates.B1_PER_ID3 = outDates.B1_PER_ID3
		AND inDates.inSeqNbr = outDates.outSeqNbr
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND b.B1_APP_TYPE_ALIAS IN {?caseType}

