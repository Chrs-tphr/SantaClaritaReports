SELECT
	b.B1_APP_TYPE_ALIAS recType
	,b.B1_ALT_ID recordNbr
	,g3s.GA_FNAME||' '||g3s.GA_LNAME asgnStaff
	,b.B1_FILE_DD openDate
FROM B1PERMIT b
INNER JOIN BPERMIT_DETAIL bpd ON
	b.SERV_PROV_CODE = bpd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bpd.B1_PER_ID1
	AND b.B1_PER_ID2 = bpd.B1_PER_ID2
	AND b.B1_PER_ID3 = bpd.B1_PER_ID3
	AND b.REC_STATUS = bpd.REC_STATUS
	LEFT OUTER JOIN G3STAFFS g3s ON
		bpd.SERV_PROV_CODE = g3s.SERV_PROV_CODE
		AND bpd.REC_STATUS = g3s.REC_STATUS
		AND bpd.B1_ASGN_STAFF = g3s.GA_USER_ID
INNER JOIN GPROCESS gp ON
	b.SERV_PROV_CODE = gp.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp.B1_PER_ID1
	AND b.B1_PER_ID2 = gp.B1_PER_ID2
	AND b.B1_PER_ID3 = gp.B1_PER_ID3
	AND b.REC_STATUS = gp.REC_STATUS
	AND gp.SD_PRO_DES = 'Permit Issuance'
	AND gp.SD_APP_DES = 'Issued'
LEFT OUTER JOIN GPROCESS gp2 ON
	b.SERV_PROV_CODE = gp2.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp2.B1_PER_ID1
	AND b.B1_PER_ID2 = gp2.B1_PER_ID2
	AND b.B1_PER_ID3 = gp2.B1_PER_ID3
	AND b.REC_STATUS = gp2.REC_STATUS
	AND gp2.SD_PRO_DES = 'Construction Finaled'
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND b.B1_PER_TYPE IN ('Encroachment Permit','Grading and Associated Plans'
			,'Sanitary Sewer','Storm Drain Plan','Street Plan','Transportation Permit')
	AND b.B1_PER_SUB_TYPE IN ('Grading','NA')
	AND b.B1_PER_CATEGORY = 'NA'
	AND NOT NVL(gp2.SD_APP_DES,'X') = 'Complete'