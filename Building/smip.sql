SELECT
	cat1.cat1Fee
	,cat1.cat1Val
	,cat2.cat2Fee
	,cat2.cat2val
	,cat3.cat3Fee
	,rbz1.VALUE_DESC bldCont
	,rbz2.VALUE_DESC bldContPhne
FROM B1PERMIT b
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz1 ON
	b.SERV_PROV_CODE = rbz1.SERV_PROV_CODE
	AND b.REC_STATUS = rbz1.REC_STATUS
	AND rbz1.BIZDOMAIN = 'REPORT_INFO'
	AND rbz1.BIZDOMAIN_VALUE = 'BLD_CONTACT'
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz2 ON
	b.SERV_PROV_CODE = rbz2.SERV_PROV_CODE
	AND b.REC_STATUS = rbz2.REC_STATUS
	AND rbz2.BIZDOMAIN = 'REPORT_INFO'
	AND rbz2.BIZDOMAIN_VALUE = 'BLD_CONTACT_PHONE'	
LEFT OUTER JOIN (
	SELECT
		bR.SERV_PROV_CODE
		,bR.B1_PER_ID1
		,bR.B1_PER_ID2
		,bR.B1_PER_ID3
		,aat.TRAN_AMOUNT cat1Fee
		,bvalR.valuatn cat1Val
	FROM B1PERMIT bR
	INNER JOIN ACCOUNTING_AUDIT_TRAIL aat ON
		bR.SERV_PROV_CODE = aat.SERV_PROV_CODE
		AND bR.B1_PER_ID1 = aat.B1_PER_ID1
		AND bR.B1_PER_ID2 = aat.B1_PER_ID2
		AND bR.B1_PER_ID3 = aat.B1_PER_ID3
		AND bR.REC_STATUS = aat.REC_STATUS
		AND aat.ACTION IN ('Payment Applied','Void Payment Applied','Refund Applied')
		AND aat.GF_COD = 'SF100'
		AND (
			aat.TRAN_DATE >= {?startDate}
			AND aat.TRAN_DATE < {?endDate}+1
		)
	LEFT OUTER JOIN (
		SELECT
			bv1.SERV_PROV_CODE
			,bv1.B1_PER_ID1
			,bv1.B1_PER_ID2
			,bv1.B1_PER_ID3
			,CASE WHEN bv1.G3_VALUE_TTL > bv1.G3_CALC_VALUE THEN bv1.G3_VALUE_TTL
			ELSE bv1.G3_CALC_VALUE END AS valuatn
		FROM BVALUATN bv1
		WHERE
			3=3
			AND bv1.SERV_PROV_CODE = 'SANTACLARITA'
			AND bv1.REC_STATUS = 'A'
		) bvalR ON
		bR.SERV_PROV_CODE = bvalR.SERV_PROV_CODE
		AND bR.B1_PER_ID1 = bvalR.B1_PER_ID1
		AND bR.B1_PER_ID2 = bvalR.B1_PER_ID2
		AND bR.B1_PER_ID3 = bvalR.B1_PER_ID3
	INNER JOIN BCHCKBOX bc ON
		bR.SERV_PROV_CODE = bc.SERV_PROV_CODE
		AND bR.B1_PER_ID1 = bc.B1_PER_ID1	
		AND bR.B1_PER_ID2 = bc.B1_PER_ID2
		AND bR.B1_PER_ID3 = bc.B1_PER_ID3
		AND bR.REC_STATUS = bc.REC_STATUS
		AND bc.B1_CHECKBOX_TYPE = 'BUILDING INFO'
		AND bc.B1_CHECKBOX_DESC = 'Use Group'
	INNER JOIN BCHCKBOX bc2 ON 
		bR.SERV_PROV_CODE = bc2.SERV_PROV_CODE
		AND bR.B1_PER_ID1 = bc2.B1_PER_ID1	
		AND bR.B1_PER_ID2 = bc2.B1_PER_ID2
		AND bR.B1_PER_ID3 = bc2.B1_PER_ID3
		AND bR.REC_STATUS = bc2.REC_STATUS
		AND bc2.B1_CHECKBOX_TYPE = 'BUILDING INFO'
		AND bc2.B1_CHECKBOX_DESC = 'Number of Stories'
	WHERE
		2=2
		AND bR.SERV_PROV_CODE = 'SANTACLARITA'
		AND bR.REC_STATUS = 'A'
		AND bR.B1_PER_GROUP = 'Building'
		AND bR.B1_PER_TYPE = 'Permits'
		AND bvalR.valuatn > 3850
		AND bc.B1_CHECKLIST_COMMENT IN ('Residential - Live/Work','Residential - Multi Family'
			,'Residential - Single Family')
		AND TO_NUMBER(NVL(NULLIF(bc2.B1_CHECKLIST_COMMENT,''),0)) < 3
	) cat1 ON
	b.SERV_PROV_CODE = cat1.SERV_PROV_CODE
	AND b.B1_PER_ID1 = cat1.B1_PER_ID1
	AND b.B1_PER_ID2 = cat1.B1_PER_ID2
	AND b.B1_PER_ID3 = cat1.B1_PER_ID3

LEFT OUTER JOIN (
	SELECT
		bC.SERV_PROV_CODE
		,bC.B1_PER_ID1
		,bC.B1_PER_ID2
		,bC.B1_PER_ID3
		,aatC.TRAN_AMOUNT cat2Fee
		,bvalC.valuatn cat2Val
	FROM B1PERMIT bC
	INNER JOIN ACCOUNTING_AUDIT_TRAIL aatC ON
		bC.SERV_PROV_CODE = aatC.SERV_PROV_CODE
		AND bC.B1_PER_ID1 = aatC.B1_PER_ID1
		AND bC.B1_PER_ID2 = aatC.B1_PER_ID2
		AND bC.B1_PER_ID3 = aatC.B1_PER_ID3
		AND bC.REC_STATUS = aatC.REC_STATUS
		AND aatC.ACTION IN ('Payment Applied','Void Payment Applied','Refund Applied')
		AND aatC.GF_COD = 'SF100'
		AND (
			aatC.TRAN_DATE >= {?startDate}
			AND aatC.TRAN_DATE < {?endDate}+1
		)
	LEFT OUTER JOIN (
		SELECT
			bv1.SERV_PROV_CODE
			,bv1.B1_PER_ID1
			,bv1.B1_PER_ID2
			,bv1.B1_PER_ID3
			,CASE WHEN bv1.G3_VALUE_TTL > bv1.G3_CALC_VALUE THEN bv1.G3_VALUE_TTL
			ELSE bv1.G3_CALC_VALUE END AS valuatn
		FROM BVALUATN bv1
		WHERE
			3=3
			AND bv1.SERV_PROV_CODE = 'SANTACLARITA'
			AND bv1.REC_STATUS = 'A'
		) bvalC ON
		bC.SERV_PROV_CODE = bvalC.SERV_PROV_CODE
		AND bC.B1_PER_ID1 = bvalC.B1_PER_ID1
		AND bC.B1_PER_ID2 = bvalC.B1_PER_ID2
		AND bC.B1_PER_ID3 = bvalC.B1_PER_ID3
	INNER JOIN BCHCKBOX bc2 ON
		bC.SERV_PROV_CODE = bc2.SERV_PROV_CODE
		AND bC.B1_PER_ID1 = bc2.B1_PER_ID1	
		AND bC.B1_PER_ID2 = bc2.B1_PER_ID2
		AND bC.B1_PER_ID3 = bc2.B1_PER_ID3
		AND bC.REC_STATUS = bc2.REC_STATUS
		AND bc2.B1_CHECKBOX_TYPE = 'BUILDING INFO'
		AND bc2.B1_CHECKBOX_DESC = 'Use Group'
	LEFT OUTER JOIN BCHCKBOX bc3 ON 
		bC.SERV_PROV_CODE = bc3.SERV_PROV_CODE
		AND bC.B1_PER_ID1 = bc3.B1_PER_ID1	
		AND bC.B1_PER_ID2 = bc3.B1_PER_ID2
		AND bC.B1_PER_ID3 = bc3.B1_PER_ID3
		AND bC.REC_STATUS = bc3.REC_STATUS
		AND bc3.B1_CHECKBOX_TYPE = 'BUILDING INFO'
		AND bc3.B1_CHECKBOX_DESC = 'Number of Stories'	
	WHERE
		2=2
		AND bC.SERV_PROV_CODE = 'SANTACLARITA'
		AND bC.REC_STATUS = 'A'
		AND bC.B1_PER_GROUP = 'Building'
		AND bC.B1_PER_TYPE = 'Permits'
		AND bvalC.valuatn > 1786
		AND bc2.B1_CHECKLIST_COMMENT IN ('Agriculture','Commercial','Educational','Government'
			,'Industrial','Institutional','Medical','Religious','Transportation'
			,'Residential - Live/Work','Residential - Multi Family','Residential - Single Family')
		AND TO_NUMBER(NVL(NULLIF(bc3.B1_CHECKLIST_COMMENT,''),0)) >= 
			CASE WHEN bc2.B1_CHECKLIST_COMMENT IN ('Residential - Live/Work','Residential - Multi Family'
			,'Residential - Single Family') THEN 3 ELSE 0 END
	) cat2 ON
	b.SERV_PROV_CODE = cat2.SERV_PROV_CODE
	AND b.B1_PER_ID1 = cat2.B1_PER_ID1
	AND b.B1_PER_ID2 = cat2.B1_PER_ID2
	AND b.B1_PER_ID3 = cat2.B1_PER_ID3
---------Category 3
LEFT OUTER JOIN (
	SELECT
		bx.SERV_PROV_CODE
		,bx.B1_PER_ID1
		,bx.B1_PER_ID2
		,bx.B1_PER_ID3
		,aatx.TRAN_AMOUNT cat3Fee
	FROM B1PERMIT bx
	INNER JOIN ACCOUNTING_AUDIT_TRAIL aatx ON
		bx.SERV_PROV_CODE = aatx.SERV_PROV_CODE
		AND bx.B1_PER_ID1 = aatx.B1_PER_ID1
		AND bx.B1_PER_ID2 = aatx.B1_PER_ID2
		AND bx.B1_PER_ID3 = aatx.B1_PER_ID3
		AND bx.REC_STATUS = aatx.REC_STATUS
		AND aatx.ACTION IN ('Payment Applied','Void Payment Applied','Refund Applied')
		AND aatx.GF_COD IN ('SF100')
		AND (
			aatx.TRAN_DATE >= {?startDate}
			AND aatx.TRAN_DATE < {?endDate}+1
		)
	LEFT OUTER JOIN (
		SELECT
			bv1.SERV_PROV_CODE
			,bv1.B1_PER_ID1
			,bv1.B1_PER_ID2
			,bv1.B1_PER_ID3
			,CASE WHEN bv1.G3_VALUE_TTL > bv1.G3_CALC_VALUE THEN bv1.G3_VALUE_TTL
			ELSE bv1.G3_CALC_VALUE END AS valuatn
		FROM BVALUATN bv1
		WHERE
			3=3
			AND bv1.SERV_PROV_CODE = 'SANTACLARITA'
			AND bv1.REC_STATUS = 'A'
		) bvalX ON
		bx.SERV_PROV_CODE = bvalX.SERV_PROV_CODE
		AND bx.B1_PER_ID1 = bvalX.B1_PER_ID1
		AND bx.B1_PER_ID2 = bvalX.B1_PER_ID2
		AND bx.B1_PER_ID3 = bvalX.B1_PER_ID3
	INNER JOIN BCHCKBOX bc ON
		bx.SERV_PROV_CODE = bc.SERV_PROV_CODE
		AND bx.B1_PER_ID1 = bc.B1_PER_ID1	
		AND bx.B1_PER_ID2 = bc.B1_PER_ID2
		AND bx.B1_PER_ID3 = bc.B1_PER_ID3
		AND bx.REC_STATUS = bc.REC_STATUS
		AND bc.B1_CHECKBOX_TYPE = 'BUILDING INFO'
		AND bc.B1_CHECKBOX_DESC = 'Use Group'
	LEFT OUTER JOIN BCHCKBOX bc2 ON 
		bx.SERV_PROV_CODE = bc2.SERV_PROV_CODE
		AND bx.B1_PER_ID1 = bc2.B1_PER_ID1	
		AND bx.B1_PER_ID2 = bc2.B1_PER_ID2
		AND bx.B1_PER_ID3 = bc2.B1_PER_ID3
		AND bx.REC_STATUS = bc2.REC_STATUS
		AND bc2.B1_CHECKBOX_TYPE = 'BUILDING INFO'
		AND bc2.B1_CHECKBOX_DESC = 'Number of Stories'		
	WHERE
		2=2
		AND bx.SERV_PROV_CODE = 'SANTACLARITA'
		AND bx.REC_STATUS = 'A'
		AND bx.B1_PER_GROUP = 'Building'
		AND bx.B1_PER_TYPE = 'Permits'
		AND bvalX.valuatn <= (
			CASE WHEN (bc.B1_CHECKLIST_COMMENT IN ('Agriculture','Commercial','Educational','Government'
					,'Industrial','Institutional','Medical','Religious','Transportation'
					,'Residential - Live/Work','Residential - Multi Family','Residential - Single Family')
				AND (TO_NUMBER(NVL(NULLIF(bc2.B1_CHECKLIST_COMMENT,''),0)) >= 
					(CASE WHEN bc.B1_CHECKLIST_COMMENT IN ('Residential - Live/Work','Residential - Multi Family'
						,'Residential - Single Family') THEN 3 ELSE 0 
					END)
					)
				)
				THEN 1786
					WHEN (bc.B1_CHECKLIST_COMMENT IN ('Residential - Live/Work','Residential - Multi Family'
						,'Residential - Single Family')
					AND TO_NUMBER(NVL(NULLIF(bc2.B1_CHECKLIST_COMMENT,''),0)) < 3)
				THEN 3850
			END
			)
	) cat3 ON
	b.SERV_PROV_CODE = cat3.SERV_PROV_CODE
	AND b.B1_PER_ID1 = cat3.B1_PER_ID1
	AND b.B1_PER_ID2 = cat3.B1_PER_ID2
	AND b.B1_PER_ID3 = cat3.B1_PER_ID3	
WHERE
  1=1
  AND b.SERV_PROV_CODE = 'SANTACLARITA'
  AND b.REC_STATUS = 'A'
  AND b.B1_PER_GROUP = 'Building'
  AND b.B1_PER_TYPE = 'Permits'