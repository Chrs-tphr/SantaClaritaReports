/*
MasterCase    DateSubmitted  Entitlements  ProjectName                     Applicant        ProjectAddress                ProjectAPN   ElapsedTime  PlannerName
16TMP-000007  16-MAY-16      (null)        (null)                          (null)           (null)                        (null)       18           (null)
MC16-00001    12-APR-16      (null)        Report Analysis                 Joe Trap         22124 SIERRA HIGHWAY HIGHWAY  2581001009   66           Patrick LeClaire
. . .
MC#03-00025   24-JAN-03      DR03-00001,   A24355                          CRC ENTERPRISES  24355 LYONS AVENUE	           2851014007  4893         (null)
                             LPR04-00007
. . .
MC#03-00042   24-JAN-03      DR03-00003    A24329                          KIM-DUYEN TRAN   24329 MAIN STREET             2831012034   4893         (null)
. . .
MC#03-00091   04-MAR-03      IS03-00001,   Centre Ponite Collision Center  RICK JACKSON     42670 TRACT 42670-02          2836068007   4854         (null)
                             LPR04-00029, 
                             MUP03-00010
*/
--
SELECT   b.B1_ALT_ID MasterCase                   --F2
        ,b.B1_FILE_DD DateSubmitted               --F3
        ,(SELECT LISTAGG(b2.B1_ALT_ID,', ') 
                 WITHIN GROUP (ORDER BY b2.B1_ALT_ID)
          FROM XAPP2REF xa 
          LEFT JOIN B1PERMIT b2 ON xa.SERV_PROV_CODE = b2.SERV_PROV_CODE
            AND xa.B1_PER_ID1 = b2.B1_PER_ID1 --CHILD IS IDENTIFIED WITH THE PER IDS
            AND xa.B1_PER_ID2 = b2.B1_PER_ID2
            AND xa.B1_PER_ID3 = b2.B1_PER_ID3
            AND xa.REC_STATUS = b2.REC_STATUS
            and b2.B1_PER_GROUP='Planning' 
            and b2.B1_PER_TYPE='Master Case' 
            and b2.B1_PER_SUB_TYPE != 'Master Case' 
            and b2.B1_PER_CATEGORY='NA'
          WHERE b.SERV_PROV_CODE = xa.SERV_PROV_CODE
            AND b.B1_PER_ID1 = xa.B1_MASTER_ID1 --PARENT IS IDENTIFIED WITH THE MASTER IDS
            AND b.B1_PER_ID2 = xa.B1_MASTER_ID2
            AND b.B1_PER_ID3 = xa.B1_MASTER_ID3
            AND b.REC_STATUS = xa.REC_STATUS
         ) AS Entitlements                        --F4
        ,b.B1_SPECIAL_TEXT ProjectName            --F5
        ,ltrim(rtrim(contct.contName)) Applicant  --F6
        ,NVL(TO_CHAR(b3aV.B1_HSE_NBR_START),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_DIR),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_NAME),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_SUFFIX),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_TYPE),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_START),' '),'') ProjectAddress  --F7
        ,b3pV.B1_PARCEL_NBR ProjectAPN            --F8
        ,TO_CHAR(TO_DATE(SYSDATE) - TO_DATE(b.B1_FILE_DD)) ElapsedTime  --C1
        ,ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)) PlannerName  --F1

FROM B1PERMIT b
--BPERMIT_DETAIL
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
--STANDARD CONTACT
LEFT OUTER JOIN(
	SELECT
		b3c.SERV_PROV_CODE
		,b3c.B1_PER_ID1
		,b3c.B1_PER_ID2
		,b3c.B1_PER_ID3
		,COALESCE(b3c.B1_FNAME||' '||b3c.B1_LNAME,b3c.B1_FULL_NAME) contName
	FROM B3CONTACT b3c
	WHERE
		1=1
		AND b3c.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3c.REC_STATUS = 'A'
		AND b3c.B1_CONTACT_TYPE = 'Applicant' --SPECIFY CONTACT TYPE
		AND b3c.B1_CONTACT_NBR = (
			SELECT
				MIN(b3cS.B1_CONTACT_NBR)
			FROM B3CONTACT b3cS
			WHERE
				2=2
				AND b3cS.SERV_PROV_CODE = b3c.SERV_PROV_CODE
				AND b3cS.B1_PER_ID1 = b3c.B1_PER_ID1
				AND b3cS.B1_PER_ID2 = b3c.B1_PER_ID2
				AND b3cS.B1_PER_ID3 = b3c.B1_PER_ID3
				AND b3cS.REC_STATUS = b3c.REC_STATUS
				AND b3cS.B1_CONTACT_TYPE = 'Applicant'
				AND COALESCE(b3cS.B1_FLAG,'N') = (
					SELECT
						MAX(COALESCE(b3cS2.B1_FLAG,'N'))
					FROM B3CONTACT b3cS2
					WHERE
						3=3
						AND b3cS2.SERV_PROV_CODE = b3cS.SERV_PROV_CODE
						AND b3cS2.B1_PER_ID1 = b3cS.B1_PER_ID1
						AND b3cS2.B1_PER_ID2 = b3cS.B1_PER_ID2
						AND b3cS2.B1_PER_ID3 = b3cS.B1_PER_ID3
						AND b3cS2.REC_STATUS = b3cS.REC_STATUS
						AND b3cS2.B1_CONTACT_TYPE = 'Applicant'
					)
				)
	) contct ON
	b.SERV_PROV_CODE = contct.SERV_PROV_CODE
	AND b.B1_PER_ID1 = contct.B1_PER_ID1
	AND b.B1_PER_ID2 = contct.B1_PER_ID2
	AND b.B1_PER_ID3 = contct.B1_PER_ID3
--B3ADDRES (RECORD ADDRESS)
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
--B3PARCEL
LEFT OUTER JOIN (
	SELECT
		b3p.SERV_PROV_CODE
		,b3p.B1_PER_ID1
		,b3p.B1_PER_ID2
		,b3p.B1_PER_ID3
		,b3p.B1_PARCEL_NBR
	FROM B3PARCEL b3p
	WHERE
		2=2
		AND b3p.SERV_PROV_CODE = 'SANTACLARITA'
		AND b3p.REC_STATUS = 'A'
		AND b3p.B1_PARCEL_NBR = (
		SELECT
			MIN(b3pS.B1_PARCEL_NBR)
		FROM B3PARCEL b3pS
		WHERE
			3=3
			AND b3pS.SERV_PROV_CODE = b3p.SERV_PROV_CODE
			AND b3pS.B1_PER_ID1 = b3p.B1_PER_ID1
			AND b3pS.B1_PER_ID2 = b3p.B1_PER_ID2
			AND b3pS.B1_PER_ID3 = b3p.B1_PER_ID3
			AND b3pS.REC_STATUS = b3p.REC_STATUS
			AND COALESCE(b3pS.B1_PRIMARY_PAR_FLG,'N') = (
				SELECT
					MAX(COALESCE(b3pS2.B1_PRIMARY_PAR_FLG,'N'))
				FROM B3PARCEL b3pS2
				WHERE
					4=4
					AND b3pS2.SERV_PROV_CODE = b3pS.SERV_PROV_CODE
					AND b3pS2.B1_PER_ID1 = b3pS.B1_PER_ID1
					AND b3pS2.B1_PER_ID2 = b3pS.B1_PER_ID2
					AND b3pS2.B1_PER_ID3 = b3pS.B1_PER_ID3
					AND b3pS2.REC_STATUS = b3pS.REC_STATUS
				)
			)
		) b3pV ON
	b.SERV_PROV_CODE = b3pV.SERV_PROV_CODE
	AND b.B1_PER_ID1 = b3pV.B1_PER_ID1
	AND b.B1_PER_ID2 = b3pV.B1_PER_ID2
	AND b.B1_PER_ID3 = b3pV.B1_PER_ID3

--DATA FILTERS
WHERE b.SERV_PROV_CODE='SANTACLARITA' 
  and b.B1_PER_GROUP='Planning' and b.B1_PER_TYPE='Master Case' 
  and b.B1_PER_SUB_TYPE='Master Case' and b.B1_PER_CATEGORY='NA' 
  and b.REC_STATUS='A'
--vv Actual input statement!!
	AND ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)) IN ({?planner})

--vv Chose order by for testing SQL only...
ORDER BY ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)), b.b1_ALT_ID ; 

--vv This was to be the input info...
--  and bpd.B1_ASGN_STAFF='RDRAKE' ; --'InputParameter' ; 
--
/*
1. Agency Name = ‘SANTACLARITA’
2. Parent Record Type = Planning/Master Case/Master Case/NA
3. Child Record Types = Planning/Master Case/%/NA (Exclude Master Case Sub Type)
4. Assigned to Staff = Planner Parameter
*/
--
