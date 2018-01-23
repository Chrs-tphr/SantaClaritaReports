SELECT
	b.B1_ALT_ID permitNbr
	,NVL(TO_CHAR(b3aV.B1_HSE_NBR_START),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_DIR),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_NAME),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_SUFFIX),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_TYPE),' '),'')
	||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_START),' '),'') addr
	,bwd.B1_WORK_DESC descOfWork
	,bpd.B1_SHORT_NOTES busNam
	,gp.G6_STAT_DD coIssueDate
	,asiPiv.totSqFoot
	,(
		SELECT
			LISTAGG(DECODE(bc.B1_CHECKBOX_DESC,'Other Description',bc.B1_CHECKLIST_COMMENT
					,bc.B1_CHECKBOX_DESC),', ') WITHIN GROUP (ORDER BY bc.B1_CHECKBOX_DESC)
		FROM BCHCKBOX bc
		WHERE
			2=2
			AND bc.SERV_PROV_CODE = b.SERV_PROV_CODE
			AND bc.B1_PER_ID1 = b.B1_PER_ID1
			AND bc.B1_PER_ID2 = b.B1_PER_ID2
			AND bc.B1_PER_ID3 = b.B1_PER_ID3
			AND bc.REC_STATUS = b.REC_STATUS
			AND bc.B1_CHECKBOX_TYPE = 'PROJECT INFORMATION'
			AND bc.B1_CHECKBOX_DESC IN ('Change of Use / Occupancy (for example: office to retail)'
				,'Change Type of Construction','New Building or Structure'
				,'Improvement / Alteration / Remodel (existing space)','Repair','Demolition'
				,'Temporary / Event','Addition','Other','Other Description')
			AND NOT NULLIF(bc.B1_CHECKLIST_COMMENT,'') IS NULL
			AND bc.B1_CHECKLIST_COMMENT LIKE 
				CASE WHEN bc.B1_CHECKBOX_DESC IN ('Addition','Other Description') THEN '%'
				ELSE 'CHECKED' END
		)natreWork
	,asiPiv.useGrp
	,asiPiv.useDetl
	,asiPiv.structType
	,g3s.GA_FNAME||' '||g3s.GA_LNAME inspName
FROM B1PERMIT b
LEFT OUTER JOIN BWORKDES bwd ON
	b.SERV_PROV_CODE = bwd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bwd.B1_PER_ID1
	AND b.B1_PER_ID2 = bwd.B1_PER_ID2
	AND b.B1_PER_ID3 = bwd.B1_PER_ID3
	AND b.REC_STATUS = bwd.REC_STATUS
LEFT OUTER JOIN BPERMIT_DETAIL bpd ON
	b.SERV_PROV_CODE = bpd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bpd.B1_PER_ID1
	AND b.B1_PER_ID2 = bpd.B1_PER_ID2
	AND b.B1_PER_ID3 = bpd.B1_PER_ID3
	AND b.REC_STATUS = bpd.REC_STATUS
	LEFT OUTER JOIN G3STAFFS g3s ON
		bpd.SERV_PROV_CODE = g3s.SERV_PROV_CODE
		AND bpd.REC_STATUS = g3s.REC_STATUS
		AND bpd.C6_INSPECTOR_NAME = g3s.GA_USER_ID
INNER JOIN GPROCESS gp ON
	b.SERV_PROV_CODE = gp.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp.B1_PER_ID1
	AND b.B1_PER_ID2 = gp.B1_PER_ID2
	AND b.B1_PER_ID3 = gp.B1_PER_ID3
	AND b.REC_STATUS = gp.REC_STATUS
	AND gp.SD_PRO_DES = 'C of O'
	AND gp.SD_APP_DES = 'Approved'
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
		AND bc1.B1_CHECKBOX_TYPE IN ('PROJECT INFORMATION','BUILDING INFO')
		AND bc1.B1_CHECKBOX_DESC IN ('Use Detail','Structure Type','Use Group','Total Square Footage')
	) a
PIVOT(
	MAX(B1_CHECKLIST_COMMENT)
	FOR B1_CHECKBOX_DESC IN ('Use Detail' AS useDetl,'Structure Type' AS structType, 'Use Group' AS useGrp
				,'Total Square Footage' AS totSqFoot)
)asiPiv ON
	b.SERV_PROV_CODE = asiPiv.SERV_PROV_CODE
	AND b.B1_PER_ID1 = asiPiv.B1_PER_ID1
	AND b.B1_PER_ID2 = asiPiv.B1_PER_ID2
	AND b.B1_PER_ID3 = asiPiv.B1_PER_ID3
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Building'
	AND (
			gp.G6_STAT_DD <= {?startDate}
			AND gp.G6_STAT_DD >= {?endDate}
		)
