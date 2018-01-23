SELECT
	(g6a.GA_FNAME||' '||g6a.GA_LNAME) asgnInsp
	,b.B1_APP_TYPE_ALIAS recType
	,g6a.G6_COMPL_DD inspDate
	,g6a.G6_ACT_TT inspTime
	,g6a.G6_ACT_NUM inspNbr
FROM B1PERMIT b
INNER JOIN G6ACTION g6a ON
	b.SERV_PROV_CODE = g6a.SERV_PROV_CODE
	AND b.B1_PER_ID1 = g6a.B1_PER_ID1
	AND b.B1_PER_ID2 = g6a.B1_PER_ID2
	AND b.B1_PER_ID3 = g6a.B1_PER_ID3
	AND b.REC_STATUS = g6a.REC_STATUS
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND (
			g6a.G6_COMPL_DD >= {?startDate}
			AND g6a.G6_COMPL_DD <= {?endDate}
			)