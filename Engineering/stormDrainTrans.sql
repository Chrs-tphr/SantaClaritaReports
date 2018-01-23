SELECT
	b.B1_ALT_ID recordNbr
	,b.B1_SPECIAL_TEXT shortDesc
	,owner.ownerName
	,COALESCE(contra.B1_BUS_NAME,(contra.B1_CAE_FNAME||' '||contra.B1_CAE_LNAME)) eng
	,tsi.mtdpdNo
	,asitPiv.bondNo
	,asitPiv.bondStat
	,tsi.noticeCompl
	,tsi.accptLACFCD
	,tsi.gisFt
	,CASE WHEN gp1.SD_APP_DES = 'Issued'
		AND NOT NVL(gp2.SD_APP_DES,'X') IN ('Inspection not Required','Construction Finaled')
		AND NOT NVL(gp3.SD_APP_DES,'X') = 'Closed'
	THEN 'In Construction'
		WHEN gp2.SD_APP_DES IN ('Inspection not Required','Construction Finaled')
		AND NOT NVL(gp3.SD_APP_DES,'X') = 'Closed'
	THEN 'Pending Transfer'
		WHEN gp3.SD_APP_DES = 'Closed'
	THEN 'Transferred'
	END AS transferStatus	
FROM B1PERMIT b
LEFT OUTER JOIN (
	SELECT
		b3lp.SERV_PROV_CODE
		,b3lp.B1_PER_ID1
		,b3lp.B1_PER_ID2
		,b3lp.B1_PER_ID3
		,b3lp.B1_LICENSE_NBR
		,b3lp.B1_LICENSE_TYPE
		,b3lp.B1_LIC_EXPIR_DD
		,b3lp.B1_BUS_NAME
		,b3lp.B1_CAE_FNAME
		,b3lp.B1_CAE_LNAME
		,b3lp.B1_ADDRESS1
		,CASE WHEN NOT NULLIF(b3lp.B1_ADDRESS2,'') IS NULL THEN b3lp.B1_ADDRESS2
			ELSE LTRIM(RTRIM(b3lp.B1_CITY))||', '||b3lp.B1_STATE||' '||b3lp.B1_ZIP
		END AS addr2
		,CASE WHEN NULLIF(b3lp.B1_ADDRESS2,'') IS NULL THEN NULL
		WHEN NOT NULLIF(b3lp.B1_ADDRESS2,'') IS NULL 
			AND NOT NULLIF(b3lp.B1_ADDRESS3,'') IS NULL
			THEN b3lp.B1_ADDRESS3
		WHEN NOT NULLIF(b3lp.B1_ADDRESS2,'') IS NULL 
			AND NULLIF(b3lp.B1_ADDRESS3,'') IS NULL
			THEN LTRIM(RTRIM(b3lp.B1_CITY))||', '||b3lp.B1_STATE||' '||b3lp.B1_ZIP
		WHEN NULLIF(b3lp.B1_ADDRESS2,'') IS NULL 
			AND NULLIF(b3lp.B1_ADDRESS3,'') IS NULL THEN NULL
		END AS addr3	
		,CASE WHEN NOT NULLIF(b3lp.B1_ADDRESS3,'') IS NULL
			THEN LTRIM(RTRIM(b3lp.B1_CITY))||', '||b3lp.B1_STATE||' '||b3lp.B1_ZIP
		ELSE NULL END AS addr4
		,b3lp.B1_PHONE1
		,b3lp.B1_PHONE2
		,b3lp.B1_FAX
		,b3lp.B1_EMAIL
	FROM B3CONTRA b3lp
	WHERE
		2=2
		AND b3lp.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3lp.REC_STATUS = 'A'
		AND b3lp.B1_LICENSE_TYPE = 'Engineer' 
		AND b3lp.B1_LICENSE_NBR = (
			SELECT
				MIN(b3lpS.B1_LICENSE_NBR)
			FROM B3CONTRA b3lpS
			WHERE
				2=2
				AND b3lpS.SERV_PROV_CODE = b3lp.SERV_PROV_CODE
				AND b3lpS.B1_PER_ID1 = b3lp.B1_PER_ID1
				AND b3lpS.B1_PER_ID2 = b3lp.B1_PER_ID2
				AND b3lpS.B1_PER_ID3 = b3lp.B1_PER_ID3
				AND b3lpS.REC_STATUS = b3lp.REC_STATUS
				AND b3lpS.B1_LICENSE_TYPE = 'Engineer'
				AND COALESCE(b3lpS.B1_PRINT_FLAG,'N') = (
					SELECT
						MAX(COALESCE(b3lpS2.B1_PRINT_FLAG,'N'))
					FROM B3CONTRA b3lpS2
					WHERE
						3=3
						AND b3lpS2.SERV_PROV_CODE = b3lpS.SERV_PROV_CODE
						AND b3lpS2.B1_PER_ID1 = b3lpS.B1_PER_ID1
						AND b3lpS2.B1_PER_ID2 = b3lpS.B1_PER_ID2
						AND b3lpS2.B1_PER_ID3 = b3lpS.B1_PER_ID3
						AND b3lpS2.REC_STATUS = b3lpS.REC_STATUS
						AND b3lpS2.B1_LICENSE_TYPE = 'Engineer'
					)
				)
			) contra ON
	b.SERV_PROV_CODE = contra.SERV_PROV_CODE
	AND b.B1_PER_ID1 = contra.B1_PER_ID1
	AND b.B1_PER_ID2 = contra.B1_PER_ID2
	AND b.B1_PER_ID3 = contra.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		b5.SERV_PROV_CODE
		,b5.B1_PER_ID1
		,b5.B1_PER_ID2
		,b5.B1_PER_ID3
		,COALESCE(b3o.B1_OWNER_FULL_NAME,b3o.B1_OWNER_FNAME||' '||b3o.B1_OWNER_LNAME) ownerName
		,b3o.B1_MAIL_ADDRESS1 addr1
		,CASE WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL THEN b3o.B1_MAIL_ADDRESS2
			ELSE LTRIM(RTRIM(b3o.B1_MAIL_CITY))||', '||b3o.B1_MAIL_STATE||' '||b3o.B1_MAIL_ZIP
		END AS addr2
		,CASE WHEN NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL THEN NULL
		WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL 
			AND NOT NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL
			THEN b3o.B1_MAIL_ADDRESS3
		WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL 
			AND NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL
			THEN LTRIM(RTRIM(b3o.B1_MAIL_CITY))||', '||b3o.B1_MAIL_STATE||' '||b3o.B1_MAIL_ZIP
		WHEN NULLIF(b3o.B1_MAIL_ADDRESS2,'') IS NULL 
			AND NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL THEN NULL
		END AS addr3	
		,CASE WHEN NOT NULLIF(b3o.B1_MAIL_ADDRESS3,'') IS NULL
			THEN LTRIM(RTRIM(b3o.B1_MAIL_CITY))||', '||b3o.B1_MAIL_STATE||' '||b3o.B1_MAIL_ZIP
		ELSE NULL END AS addr4
		,COALESCE(b3o.B1_PHONE,'No Phone') phone
		,b3o.B1_EMAIL email
	FROM B1PERMIT b5
	INNER JOIN B3OWNERS b3o ON
		b5.SERV_PROV_CODE = b3o.SERV_PROV_CODE
		AND b5.B1_PER_ID1 = b3o.B1_PER_ID1
		AND b5.B1_PER_ID2 = b3o.B1_PER_ID2
		AND b5.B1_PER_ID3 = b3o.B1_PER_ID3
		AND b5.REC_STATUS = b3o.REC_STATUS
	WHERE
		2=2
		AND b5.SERV_PROV_CODE = 'SANTACLARITA'
		AND b5.REC_STATUS = 'A'
		AND b3o.B1_OWNER_NBR = (
			SELECT
				MIN(b3oS.B1_OWNER_NBR)
			FROM B3OWNERS b3oS
			WHERE
				3=3
				AND b3oS.SERV_PROV_CODE = b3o.SERV_PROV_CODE
				AND b3oS.B1_PER_ID1 = b3o.B1_PER_ID1
				AND b3oS.B1_PER_ID2 = b3o.B1_PER_ID2
				AND b3oS.B1_PER_ID3 = b3o.B1_PER_ID3
				AND b3oS.REC_STATUS = b3o.REC_STATUS
				AND COALESCE(b3oS.B1_PRIMARY_OWNER,'N') = (
					SELECT
						MAX(COALESCE(b3oS2.B1_PRIMARY_OWNER,'N'))
					FROM B3OWNERS b3oS2
					WHERE
						4=4
						AND b3oS2.SERV_PROV_CODE = b3oS.SERV_PROV_CODE
						AND b3oS2.B1_PER_ID1 = b3oS.B1_PER_ID1
						AND b3oS2.B1_PER_ID2 = b3oS.B1_PER_ID2
						AND b3oS2.B1_PER_ID3 = b3oS.B1_PER_ID3
						AND b3oS2.REC_STATUS = b3oS.REC_STATUS
					)
				)
	) owner ON
	b.SERV_PROV_CODE = owner.SERV_PROV_CODE
	AND b.B1_PER_ID1 = owner.B1_PER_ID1
	AND b.B1_PER_ID2 = owner.B1_PER_ID2
	AND b.B1_PER_ID3 = owner.B1_PER_ID3
LEFT OUTER JOIN GPROCESS gp1 ON
	b.SERV_PROV_CODE = gp1.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp1.B1_PER_ID1
	AND b.B1_PER_ID2 = gp1.B1_PER_ID2
	AND b.B1_PER_ID3 = gp1.B1_PER_ID3
	AND b.REC_STATUS = gp1.REC_STATUS
	AND gp1.SD_PRO_DES = 'Permit Issuance' 
	AND gp1.SD_APP_DES = 'Issued' 
LEFT OUTER JOIN GPROCESS gp2 ON
	b.SERV_PROV_CODE = gp2.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp2.B1_PER_ID1
	AND b.B1_PER_ID2 = gp2.B1_PER_ID2
	AND b.B1_PER_ID3 = gp2.B1_PER_ID3
	AND b.REC_STATUS = gp2.REC_STATUS
	AND gp2.SD_PRO_DES = 'Inspection' 
	AND gp2.SD_APP_DES IN ('Inspection not Required','Construction Finaled') 
LEFT OUTER JOIN GPROCESS gp3 ON
	b.SERV_PROV_CODE = gp3.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp3.B1_PER_ID1
	AND b.B1_PER_ID2 = gp3.B1_PER_ID2
	AND b.B1_PER_ID3 = gp3.B1_PER_ID3
	AND b.REC_STATUS = gp3.REC_STATUS
	AND gp3.SD_PRO_DES = 'Case Archive' 
	AND gp3.SD_APP_DES = 'Closed' 	
LEFT OUTER JOIN(
	SELECT
		gsi.SERV_PROV_CODE
		,gsi.B1_PER_ID1
		,gsi.B1_PER_ID2
		,gsi.B1_PER_ID3
		,gsi.B1_CHECKBOX_DESC
		,gsi.B1_CHECKLIST_COMMENT
	FROM GPROCESS_SPEC_INFO gsi
	WHERE
		2=2
		AND gsi.SERV_PROV_CODE = 'SANTACLARITA'
		AND gsi.REC_STATUS = 'A'
		AND gsi.B1_CHECKBOX_TYPE IN ('SD PLANCHECK','STORM DRAIN')
		AND gsi.B1_CHECKBOX_DESC IN ('MTD-PD No.','Notice of Completion - 95%'
				,'Acceptance LACFCD','GIS Feature Attached to Case')
		) a
PIVOT(
		MAX(B1_CHECKLIST_COMMENT)
		FOR B1_CHECKBOX_DESC IN ('MTD-PD No.' AS mtdpdNo,'Notice of Completion - 95%' AS noticeCompl
				,'Acceptance LACFCD' AS accptLACFCD,'GIS Feature Attached to Case' AS gisFt)
		) tsi ON
	b.SERV_PROV_CODE = tsi.SERV_PROV_CODE
	AND b.B1_PER_ID1 = tsi.B1_PER_ID1		
	AND b.B1_PER_ID2 = tsi.B1_PER_ID2
	AND b.B1_PER_ID3 = tsi.B1_PER_ID3
LEFT OUTER JOIN(
	SELECT
		bastv.SERV_PROV_CODE
		,bastv.B1_PER_ID1
		,bastv.B1_PER_ID2
		,bastv.B1_PER_ID3
		,bastv.ROW_INDEX
		,bastv.COLUMN_NAME
		,bastv.ATTRIBUTE_VALUE
	FROM BAPPSPECTABLE_VALUE bastv
	WHERE
		1=1
		AND bastv.REC_STATUS = 'A'
		AND bastv.TABLE_NAME = 'BOND' 
		AND bastv.COLUMN_NAME IN ('Bond/CD No.','Bond Status') 
	)c
PIVOT(
	MAX(ATTRIBUTE_VALUE)
	FOR COLUMN_NAME IN ('Bond/CD No.' AS bondNo,'Bond Status' AS bondStat)
	b.SERV_PROV_CODE = asitPiv.SERV_PROV_CODE
	AND b.B1_PER_ID1 = asitPiv.B1_PER_ID1
	AND b.B1_PER_ID2 = asitPiv.B1_PER_ID2
	AND b.B1_PER_ID3 = asitPiv.B1_PER_ID3
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND b.B1_PER_TYPE = 'Storm Drain'
	AND (
			(
				gp1.G6_STAT_DD >= {?startDate}
				AND gp1.G6_STAT_DD <= {?endDate}
				)
			OR
			(
				gp2.G6_STAT_DD >= {?startDate}
				AND gp2.G6_STAT_DD <= {?endDate}
				)
			OR
			(
				gp3.G6_STAT_DD >= {?startDate}
				AND gp3.G6_STAT_DD <= {?endDate}
				)
		)


