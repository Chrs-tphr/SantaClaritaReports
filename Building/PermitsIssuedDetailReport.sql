SELECT
	b.B1_ALT_ID permitNbr
	,NVL(TO_CHAR(b3aV.B1_HSE_NBR_START),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_DIR),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_NAME),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_SUFFIX),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_TYPE),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_START),' '),'') addr
	,asiPiv.useGroup
	,asiPiv.useDetail
	,asiPiv.valutnDeclr
	,asiPiv.valutnCalc
	,asiPiv.bldStrucTyp
	,asiPiv.sqft
	,(
		SELECT
			LISTAGG(bc.B1_CHECKBOX_DESC,', ') WITHIN GROUP (ORDER BY bc.B1_CHECKBOX_DESC)
		FROM BCHCKBOX bc
		WHERE
			2=2
			AND b.SERV_PROV_CODE = bc.SERV_PROV_CODE
			AND b.B1_PER_ID1 = bc.B1_PER_ID1	
			AND b.B1_PER_ID2 = bc.B1_PER_ID2
			AND b.B1_PER_ID3 = bc.B1_PER_ID3
			AND b.REC_STATUS = bc.REC_STATUS
			AND bc.B1_CHECKBOX_TYPE = 'PROJECT INFORMATION' --ASI SUBGROUP
			AND bc.B1_CHECKBOX_DESC IN ('Repair','New Building or Structure'
				,'Improvement / Alteration / Remodel (existing space)'
				,'Change of Use / Occupancy (for example: office to retail)'
				,'Demolition Only','Change Type of Construction','Temporary / Event '
				,'Other') --ASI FIELD LABEL
		) AS natrWork
	,bwd.B1_WORK_DESC descOfWork	
FROM B1PERMIT b
LEFT OUTER JOIN BWORKDES bwd ON
	b.SERV_PROV_CODE = bwd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bwd.B1_PER_ID1
	AND b.B1_PER_ID2 = bwd.B1_PER_ID2
	AND b.B1_PER_ID3 = bwd.B1_PER_ID3
	AND b.REC_STATUS = bwd.REC_STATUS
LEFT OUTER JOIN GPROCESS gp ON
	b.SERV_PROV_CODE = gp.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp.B1_PER_ID1
	AND b.B1_PER_ID2 = gp.B1_PER_ID2
	AND b.B1_PER_ID3 = gp.B1_PER_ID3
	AND b.REC_STATUS = gp.REC_STATUS
	AND gp.SD_PRO_DES = 'Permit Issuance' --TASK NAME
	AND gp.SD_APP_DES = 'Issued' --STATUS NAME
LEFT OUTER JOIN (
	SELECT
		b3a.SERV_PROV_CODE
		,b3a.B1_PER_ID1
		,b3a.B1_PER_ID2
		,b3a.B1_PER_ID3
		,b3a.B1_HSE_NBR_START
		,b3a.B1_STR_DIR
		,b3a.B1_STR_NAME
		,b3a.B1_STR_SUFFIX
		,b3a.B1_UNIT_START
		,b3a.B1_UNIT_TYPE
		,b3a.B1_SITUS_CITY
		,b3a.B1_SITUS_STATE
		,b3a.B1_SITUS_ZIP
	FROM B3ADDRES b3a
	WHERE
		2=2
		AND b3a.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3a.REC_STATUS = 'A'
		AND b3a.B1_ADDRESS_NBR = (
			SELECT
				MIN(b3aS.B1_ADDRESS_NBR)
			FROM B3ADDRES b3aS
			WHERE
				3=3
				AND b3aS.SERV_PROV_CODE = b3a.SERV_PROV_CODE
				AND b3aS.B1_PER_ID1 = b3a.B1_PER_ID1
				AND b3aS.B1_PER_ID2 = b3a.B1_PER_ID2
				AND b3aS.B1_PER_ID3 = b3a.B1_PER_ID3
				AND b3aS.REC_STATUS = b3a.REC_STATUS
				AND COALESCE(b3aS.B1_PRIMARY_ADDR_FLG,'N') = (
					SELECT
						MAX(COALESCE(b3aS2.B1_PRIMARY_ADDR_FLG,'N'))
					FROM B3ADDRES b3aS2
					WHERE
						4=4
						AND b3aS2.SERV_PROV_CODE = b3aS.SERV_PROV_CODE
						AND b3aS2.B1_PER_ID1 = b3aS.B1_PER_ID1
						AND b3aS2.B1_PER_ID2 = b3aS.B1_PER_ID2
						AND b3aS2.B1_PER_ID3 = b3aS.B1_PER_ID3
						AND b3aS2.REC_STATUS = b3aS.REC_STATUS
				)
			)
		) b3aV ON
	b.SERV_PROV_CODE = b3aV.SERV_PROV_CODE
	AND b.B1_PER_ID1 = b3aV.B1_PER_ID1
	AND b.B1_PER_ID2 = b3aV.B1_PER_ID2
	AND b.B1_PER_ID3 = b3aV.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		bc1.SERV_PROV_CODE
		,bc1.B1_PER_ID1
		,bc1.B1_PER_ID2
		,bc1.B1_PER_ID3
		,bc1.B1_CHECKBOX_DESC
		,bc1.B1_CHECKLIST_COMMENT
	FROM BCHCKBOX bc1
	WHERE
		1=1
		AND bc1.REC_STATUS = 'A'
		AND bc1.B1_CHECKBOX_TYPE IN ('BUILDING INFO','JOB VALUE','PROJECT INFORMATION') --ASI SUBGROUP
		AND bc1.B1_CHECKBOX_DESC IN ('Use Group','Use Detail','Valuation Declared'
			,'Valuation Calculated','Building/Structure Type','Square Footage') --ASI FIELD LABEL
	) a
PIVOT(
	MAX(B1_CHECKLIST_COMMENT)
	FOR B1_CHECKBOX_DESC IN ('Use Group' AS useGroup ,'Use Detail' AS useDetail
		,'Valuation Declared' AS valutnDeclr, 'Valuation Calculated' AS valutnCalc
		,'Building/Structure Type' AS bldStrucTyp,'Square Footage' AS sqft) --REPEAT FIELD LABELS IN QUOTES, ADD ALIAS'
)asiPiv ON
	b.SERV_PROV_CODE = asiPiv.SERV_PROV_CODE
	AND b.B1_PER_ID1 = asiPiv.B1_PER_ID1
	AND b.B1_PER_ID2 = asiPiv.B1_PER_ID2
	AND b.B1_PER_ID3 = asiPiv.B1_PER_ID3	
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND (
		gp.G6_STAT_DD >= {?startDate}
		AND gp.G6_STAT_DD <= {?endDate}
	)
