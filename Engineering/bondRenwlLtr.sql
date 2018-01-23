SELECT
	suretyHldr.busName shBusNam
	,suretyHldr.addr1 shAddr1
	,suretyHldr.addr2 shAddr2
	,suretyHldr.addr3 shAddr3
	,suretyHldr.addr4 shAddr4
	,b.B1_ALT_ID recordNbr
	,CASE asitPiv.bondStat
			WHEN 'Exonerated' THEN 'exonerated'
			ELSE 'reduced'
	END AS exoRedText
	,asitPiv.natureImprv
	,asitPiv.bondNo
	,CASE asitPiv.bondStat
		WHEN 'Exonerated' THEN asitPiv.bondStat
		WHEN 'Active' THEN asitPiv.reduxAmt
	END as redAmt
	,asitPiv.descImprv
	,asitPiv.origAmt
	,prncpl.busName prncplBusNam
	,prncpl.addr1 prncplAddr1
	,prncpl.addr2 prncplAddr2
	,prncpl.addr3 prncplAddr3
	,prncpl.addr4 prncplAddr4
	,rbz1.VALUE_DESC engOffNam
	,rbz2.VALUE_DESC engOffPhon
	,rbz3.VALUE_DESC engOffTitl
FROM B1PERMIT b
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz1 ON
	b.SERV_PROV_CODE = rbz1.SERV_PROV_CODE
	AND b.REC_STATUS = rbz1.REC_STATUS
	AND rbz1.BIZDOMAIN = 'REPORT_INFO'
	AND rbz1.BIZDOMAIN_VALUE = 'ENG_OFFICIAL'
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz2 ON
	b.SERV_PROV_CODE = rbz2.SERV_PROV_CODE
	AND b.REC_STATUS = rbz2.REC_STATUS
	AND rbz2.BIZDOMAIN = 'REPORT_INFO'
	AND rbz2.BIZDOMAIN_VALUE = 'ENG_OFFICIAL_PHONE'
LEFT OUTER JOIN RBIZDOMAIN_VALUE rbz3 ON
	b.SERV_PROV_CODE = rbz3.SERV_PROV_CODE
	AND b.REC_STATUS = rbz3.REC_STATUS
	AND rbz3.BIZDOMAIN = 'REPORT_INFO'
	AND rbz3.BIZDOMAIN_VALUE = 'ENG_OFFICIAL_TITLE'
INNER JOIN(
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
		2=2
		AND bastv.REC_STATUS = 'A'
		AND bastv.TABLE_NAME = 'Bond'
		AND bastv.COLUMN_NAME IN ('Nature of Covered Improvement'
				,'Description of Bonded Improvement','Bond/CD No.','Original Amount','Reduced $ Amount'
				,'Bond Status')
		AND bastv.ROW_INDEX = (
			SELECT
				MAX(bastv2.ROW_INDEX)
			FROM BAPPSPECTABLE_VALUE bastv2
			WHERE
				3=3
				AND bastv2.SERV_PROV_CODE = bastv.SERV_PROV_CODE
				AND bastv2.B1_PER_ID1 = bastv.B1_PER_ID1
				AND bastv2.B1_PER_ID2 = bastv.B1_PER_ID2
				AND bastv2.B1_PER_ID3 = bastv.B1_PER_ID3
				AND bastv2.REC_STATUS = 'A'
				AND bastv2.TABLE_NAME = 'Bond'
			)
	)c
PIVOT(
	MAX(ATTRIBUTE_VALUE)
	FOR COLUMN_NAME IN ('Nature of Covered Improvement' AS natureImprv
				,'Description of Bonded Improvement' AS descImprv,'Bond/CD No.' AS bondNo
				,'Original Amount' AS origAmt,'Reduced $ Amount' AS reduxAmt,'Bond Status' AS bondStat)
)asitPiv ON
	b.SERV_PROV_CODE = asitPiv.SERV_PROV_CODE
	AND b.B1_PER_ID1 = asitPiv.B1_PER_ID1
	AND b.B1_PER_ID2 = asitPiv.B1_PER_ID2
	AND b.B1_PER_ID3 = asitPiv.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		b4.SERV_PROV_CODE
		,b4.B1_PER_ID1
		,b4.B1_PER_ID2
		,b4.B1_PER_ID3
		,b3cC.B1_FNAME fName
		,b3cC.B1_MNAME mName
		,b3cC.B1_LNAME lName
		,COALESCE(b3cC.B1_FULL_NAME,(b3cC.B1_FNAME||' '||b3cC.B1_LNAME)) fullName
		,b3cC.B1_BUSINESS_NAME busName
		,g7c.G7_ADDRESS1 addr1
		,CASE WHEN NULLIF(g7c.G7_ADDRESS2,'') IS NULL
			THEN g7c.G7_CITY||', '||g7c.G7_STATE||' '||g7c.G7_ZIP
			WHEN NOT NULLIF(g7c.G7_ADDRESS2,'') IS NULL THEN g7c.G7_ADDRESS2
		END AS addr2
		,CASE WHEN NOT NULLIF(g7c.G7_ADDRESS3,'') IS NULL THEN g7c.G7_ADDRESS3
			WHEN NULLIF(g7c.G7_ADDRESS2,'') IS NULL THEN NULL
			WHEN NOT NULLIF(g7c.G7_ADDRESS2,'') IS NULL AND NULLIF(g7c.G7_ADDRESS3,'') IS NULL
			THEN g7c.G7_CITY||', '||g7c.G7_STATE||' '||g7c.G7_ZIP
		END AS addr3
		,CASE WHEN NOT NULLIF(g7c.G7_ADDRESS3,'') IS NULL
			THEN g7c.G7_CITY||', '||g7c.G7_STATE||' '||g7c.G7_ZIP
		ELSE NULL END AS addr4
		,b3cC.B1_PHONE1 hmPhone
		,b3cC.B1_PHONE2	mobPhone
		,b3cC.B1_PHONE3 busPhone
		,b3cC.B1_EMAIL email
	FROM B1PERMIT b4
	INNER JOIN B3CONTACT b3cC ON
		b4.SERV_PROV_CODE = b3cC.SERV_PROV_CODE
		AND b4.B1_PER_ID1 = b3cC.B1_PER_ID1
		AND b4.B1_PER_ID2 = b3cC.B1_PER_ID2
		AND b4.B1_PER_ID3 = b3cC.B1_PER_ID3
		AND b4.REC_STATUS = b3cC.REC_STATUS
		LEFT OUTER JOIN G7CONTACT_ADDRESS g7c ON
			b3cC.SERV_PROV_CODE = g7c.SERV_PROV_CODE
			AND b3cC.REC_STATUS = g7c.REC_STATUS
			AND COALESCE(b3cC.G1_CONTACT_NBR,b3cC.B1_CONTACT_NBR) = g7c.G7_ENTITY_ID
			AND g7c.G7_ENTITY_TYPE IN ('CONTACT','CAP_CONTACT')
	WHERE
		2=2
		AND b4.SERV_PROV_CODE = 'SANTACLARITA'
		AND b4.REC_STATUS = 'A'
		AND b4.B1_ALT_ID = '{?altId}'
		AND g7c.G7_ADDRESS_TYPE = ( --ADJUST AS NEEDED
				SELECT
					MAX(g7c.G7_ADDRESS_TYPE)
				FROM G7CONTACT_ADDRESS g7cS
				WHERE
					3=3
					AND g7cS.SERV_PROV_CODE = g7c.SERV_PROV_CODE
					AND g7cS.REC_STATUS = g7c.REC_STATUS
					AND g7cS.G7_ENTITY_ID = g7c.G7_ENTITY_ID
					)
		AND b3cC.B1_CONTACT_TYPE = 'Surety Holder'
		AND b3cC.B1_CONTACT_NBR = (
			SELECT
				MAX(b3cCS.B1_CONTACT_NBR)
			FROM B3CONTACT b3cCS
			WHERE
				3=3
				AND b3cCS.SERV_PROV_CODE = b3cC.SERV_PROV_CODE
				AND b3cCS.B1_PER_ID1 = b3cC.B1_PER_ID1
				AND b3cCS.B1_PER_ID2 = b3cC.B1_PER_ID2
				AND b3cCS.B1_PER_ID3 = b3cC.B1_PER_ID3
				AND b3cCS.REC_STATUS = b3cC.REC_STATUS
				AND b3cCS.B1_CONTACT_TYPE = 'Surety Holder'
				AND COALESCE(b3cCS.B1_FLAG,'N') = ( 
					SELECT
						MAX(COALESCE(b3cCS2.B1_FLAG,'N'))
					FROM B3CONTACT b3cCS2
					WHERE
						4=4
						AND b3cCS2.SERV_PROV_CODE = b3cCS.SERV_PROV_CODE
						AND b3cCS2.B1_PER_ID1 = b3cCS.B1_PER_ID1
						AND b3cCS2.B1_PER_ID2 = b3cCS.B1_PER_ID2
						AND b3cCS2.B1_PER_ID3 = b3cCS.B1_PER_ID3
						AND b3cCS2.REC_STATUS = b3cCS.REC_STATUS
						AND b3cCS2.B1_CONTACT_TYPE = 'Surety Holder'
				)
		)
	) suretyHldr ON
	b.SERV_PROV_CODE = suretyHldr.SERV_PROV_CODE
	AND b.B1_PER_ID1 = suretyHldr.B1_PER_ID1
	AND b.B1_PER_ID2 = suretyHldr.B1_PER_ID2
	AND b.B1_PER_ID3 = suretyHldr.B1_PER_ID3
LEFT OUTER JOIN (
	SELECT
		b4.SERV_PROV_CODE
		,b4.B1_PER_ID1
		,b4.B1_PER_ID2
		,b4.B1_PER_ID3
		,b3cC.B1_FNAME fName
		,b3cC.B1_MNAME mName
		,b3cC.B1_LNAME lName
		,COALESCE(b3cC.B1_FULL_NAME,(b3cC.B1_FNAME||' '||b3cC.B1_LNAME)) fullName
		,b3cC.B1_BUSINESS_NAME busName
		,g7c.G7_ADDRESS1 addr1
		,CASE WHEN NULLIF(g7c.G7_ADDRESS2,'') IS NULL
			THEN g7c.G7_CITY||', '||g7c.G7_STATE||' '||g7c.G7_ZIP
			WHEN NOT NULLIF(g7c.G7_ADDRESS2,'') IS NULL THEN g7c.G7_ADDRESS2
		END AS addr2
		,CASE WHEN NOT NULLIF(g7c.G7_ADDRESS3,'') IS NULL THEN g7c.G7_ADDRESS3
			WHEN NULLIF(g7c.G7_ADDRESS2,'') IS NULL THEN NULL
			WHEN NOT NULLIF(g7c.G7_ADDRESS2,'') IS NULL AND NULLIF(g7c.G7_ADDRESS3,'') IS NULL
			THEN g7c.G7_CITY||', '||g7c.G7_STATE||' '||g7c.G7_ZIP
		END AS addr3
		,CASE WHEN NOT NULLIF(g7c.G7_ADDRESS3,'') IS NULL
			THEN g7c.G7_CITY||', '||g7c.G7_STATE||' '||g7c.G7_ZIP
		ELSE NULL END AS addr4
		,b3cC.B1_PHONE1 hmPhone
		,b3cC.B1_PHONE2	mobPhone
		,b3cC.B1_PHONE3 busPhone
		,b3cC.B1_EMAIL email
	FROM B1PERMIT b4
	INNER JOIN B3CONTACT b3cC ON
		b4.SERV_PROV_CODE = b3cC.SERV_PROV_CODE
		AND b4.B1_PER_ID1 = b3cC.B1_PER_ID1
		AND b4.B1_PER_ID2 = b3cC.B1_PER_ID2
		AND b4.B1_PER_ID3 = b3cC.B1_PER_ID3
		AND b4.REC_STATUS = b3cC.REC_STATUS
		LEFT OUTER JOIN G7CONTACT_ADDRESS g7c ON
			b3cC.SERV_PROV_CODE = g7c.SERV_PROV_CODE
			AND b3cC.REC_STATUS = g7c.REC_STATUS
			AND COALESCE(b3cC.G1_CONTACT_NBR,b3cC.B1_CONTACT_NBR) = g7c.G7_ENTITY_ID
			AND g7c.G7_ENTITY_TYPE IN ('CONTACT','CAP_CONTACT')
	WHERE
		2=2
		AND b4.SERV_PROV_CODE = 'SANTACLARITA'
		AND b4.REC_STATUS = 'A'
		AND b4.B1_ALT_ID = '{?altId}'
		AND g7c.G7_ADDRESS_TYPE = (
				SELECT
					MAX(g7c.G7_ADDRESS_TYPE)
				FROM G7CONTACT_ADDRESS g7cS
				WHERE
					3=3
					AND g7cS.SERV_PROV_CODE = g7c.SERV_PROV_CODE
					AND g7cS.REC_STATUS = g7c.REC_STATUS
					AND g7cS.G7_ENTITY_ID = g7c.G7_ENTITY_ID
					)
		AND b3cC.B1_CONTACT_TYPE = 'Principal'
		AND b3cC.B1_CONTACT_NBR = (
			SELECT
				MAX(b3cCS.B1_CONTACT_NBR)
			FROM B3CONTACT b3cCS
			WHERE
				3=3
				AND b3cCS.SERV_PROV_CODE = b3cC.SERV_PROV_CODE
				AND b3cCS.B1_PER_ID1 = b3cC.B1_PER_ID1
				AND b3cCS.B1_PER_ID2 = b3cC.B1_PER_ID2
				AND b3cCS.B1_PER_ID3 = b3cC.B1_PER_ID3
				AND b3cCS.REC_STATUS = b3cC.REC_STATUS
				AND b3cCS.B1_CONTACT_TYPE = 'Principal'
				AND COALESCE(b3cCS.B1_FLAG,'N') = ( 
					SELECT
						MAX(COALESCE(b3cCS2.B1_FLAG,'N'))
					FROM B3CONTACT b3cCS2
					WHERE
						4=4
						AND b3cCS2.SERV_PROV_CODE = b3cCS.SERV_PROV_CODE
						AND b3cCS2.B1_PER_ID1 = b3cCS.B1_PER_ID1
						AND b3cCS2.B1_PER_ID2 = b3cCS.B1_PER_ID2
						AND b3cCS2.B1_PER_ID3 = b3cCS.B1_PER_ID3
						AND b3cCS2.REC_STATUS = b3cCS.REC_STATUS
						AND b3cCS2.B1_CONTACT_TYPE = 'Principal'
					)	
				)
		) prncpl ON
	b.SERV_PROV_CODE = prncpl.SERV_PROV_CODE
	AND b.B1_PER_ID1 = prncpl.B1_PER_ID1
	AND b.B1_PER_ID2 = prncpl.B1_PER_ID2
	AND b.B1_PER_ID3 = prncpl.B1_PER_ID3	
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND b.B1_ALT_ID = '{?altId}'