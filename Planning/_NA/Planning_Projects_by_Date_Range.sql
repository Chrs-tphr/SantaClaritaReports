/*
MasterCase    PlannerName       ApplStatusDate  Entitlements  Applicant        ProjectName                     ProjectAddress                ProjectAPN  ActingBody    ApplStatus
MC16-00001    Patrick LeClaire  12-APR-16       (null)        Joe Trap         Report Analysis                 22124 SIERRA HIGHWAY HIGHWAY  2581001009  City Council  (null)
16TMP-000007  (null)            16-MAY-16       (null)        (null)           (null)                          (null)                        (null)      City Council  (null)
. . .
MC#03-00025   (null)            (null)          DR03-00001,   CRC ENTERPRISES  A24355                          24355 LYONS AVENUE            2851014007  City Council  Withdrawn
                                                LPR04-00007
. . .
MC#03-00091   (null)            (null)          IS03-00001,   RICK JACKSON     Centre Ponite Collision Center  42670 TRACT 42670-02          2836068007  City Council  Approved
                                                LPR04-00029, 
                                                MUP03-00010
. . .
MC#03-00153   (null)            (null)          TEX03-00007,  SAM HINDSMAN     A16520                          16520 SOLEDAD CANYON ROAD     2839007032  City Council  Approved
                                                TEX03-00008
. . .
MC#03-00160   (null)            (null)          CUP03-00005,  (null)           A24041                          24041 VALENCIA BOULEVARD      2861058024  City Council  Submitted
                                                EIR04-00001, 
                                                IS03-00004
*/
--
SELECT   b.B1_ALT_ID MasterCase                   --F4
        ,ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)) Planner  --F5
        ,b.B1_APPL_STATUS_DATE ApplStatusDate     --F6
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
         ) AS Entitlements                        --F7
        ,ltrim(rtrim(contct.contName)) Applicant  --F8
        ,b.B1_SPECIAL_TEXT ProjectName            --F9
        ,NVL(TO_CHAR(b3aV.B1_HSE_NBR_START),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_DIR),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_NAME),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_SUFFIX),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_TYPE),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_START),' '),'') ProjectAddress  --F10
        ,b3pV.B1_PARCEL_NBR ProjectAPN            --F11
        ,CASE
           WHEN b.B1_ALT_ID='1' THEN 'Staff'
           WHEN b.B1_ALT_ID='2' THEN 'Planning Commission' 
           ELSE 'City Council' 
         END ActingBody                           --F12
        ,b.B1_APPL_STATUS ApplStatus              --F3

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
/*
--GPROCESS (WORKFLOW)	
--LEFT JOIN GPROCESS gp ON
inner JOIN GPROCESS gp ON
	b.SERV_PROV_CODE = gp.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp.B1_PER_ID1
	AND b.B1_PER_ID2 = gp.B1_PER_ID2
	AND b.B1_PER_ID3 = gp.B1_PER_ID3
	AND b.REC_STATUS = gp.REC_STATUS
	AND gp.R1_PROCESS_CODE like 'P_CLASS%' --TASK NAME
--OPTIONAL CODE TO GET THE LAST INSTANCE OF A GIVEN TASK/STATUS
	AND gp.RELATION_SEQ_ID = (
		SELECT
			MAX(gpS.RELATION_SEQ_ID)
		FROM GPROCESS gpS
		WHERE
			2=2
			AND gpS.SERV_PROV_CODE = gp.SERV_PROV_CODE
			AND gpS.B1_PER_ID1 = gp.B1_PER_ID1
			AND gpS.B1_PER_ID2 = gp.B1_PER_ID2
			AND gpS.B1_PER_ID3 = gp.B1_PER_ID3
			AND gpS.REC_STATUS = gp.REC_STATUS
			AND gpS.R1_PROCESS_CODE = gp.R1_PROCESS_CODE
--			AND gpS.R1_PROCESS_CODE like 'P_CLASS%' 
		)
*/
/*
--OPTIONAL CODE TO GET THE LAST INSTANCE OF A GIVEN TASK/STATUS
	AND gp.G6_APP_DD = (
		SELECT
			MAX(gpS.G6_APP_DD)
		FROM GPROCESS gpS
		WHERE
			2=2
			AND gpS.SERV_PROV_CODE = gp.SERV_PROV_CODE
			AND gpS.B1_PER_ID1 = gp.B1_PER_ID1
			AND gpS.B1_PER_ID2 = gp.B1_PER_ID2
			AND gpS.B1_PER_ID3 = gp.B1_PER_ID3
			AND gpS.REC_STATUS = gp.REC_STATUS
			AND gpS.R1_PROCESS_CODE like 'P_CLASS_%' 
		)
*/

--DATA FILTERS
WHERE b.SERV_PROV_CODE='SANTACLARITA' 
  and b.B1_PER_GROUP='Planning' and b.B1_PER_TYPE='Master Case' 
  and b.B1_PER_SUB_TYPE='Master Case' and b.B1_PER_CATEGORY='NA' 
  and b.REC_STATUS='A'
--vv Actual input statement!!
--	AND b.B1_APPL_STATUS_DATE >= ({?startdate})
--	AND b.B1_APPL_STATUS_DATE <= ({?enddate})
--	AND ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)) IN ({?planner})
--	AND ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)) IN ({?planner})
--      AND g.R1_PROCESS_CODE IN ({actingbody})

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
--
/*
--GPROCESS (WORKFLOW)	
LEFT OUTER JOIN GPROCESS gp ON
	b.SERV_PROV_CODE = gp.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gp.B1_PER_ID1
	AND b.B1_PER_ID2 = gp.B1_PER_ID2
	AND b.B1_PER_ID3 = gp.B1_PER_ID3
	AND b.REC_STATUS = gp.REC_STATUS
	AND gp.SD_PRO_DES = '' --TASK NAME
	AND gp.SD_APP_DES = '' --STATUS NAME
--OPTIONAL CODE TO GET THE LAST INSTANCE OF A GIVEN TASK/STATUS
	AND gp.SD_APP_DD = (
		SELECT
			MAX(gpS.SD_APP_DD)
		FROM GPROCESS gpS
		WHERE
			2=2
			AND gpS.SERV_PROV_CODE = gp.SERV_PROV_CODE
			AND gpS.B1_PER_ID1 = gp.B1_PER_ID1
			AND gpS.B1_PER_ID2 = gp.B1_PER_ID2
			AND gpS.B1_PER_ID3 = gp.B1_PER_ID3
			AND gpS.REC_STATUS = gp.REC_STATUS
			AND gpS.SD_PRO_DES = gp.SD_PRO_DES 
			AND gpS.SD_APP_DES = gp.SD_APP_DES 
		)
--GPROCESS_HISTORY (WORKFLOW HISTORY)
LEFT OUTER JOIN GPROCESS_HISTORY gph ON
	b.SERV_PROV_CODE = gph.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gph.B1_PER_ID1
	AND b.B1_PER_ID2 = gph.B1_PER_ID2
	AND b.B1_PER_ID3 = gph.B1_PER_ID3
	AND b.REC_STATUS = gph.REC_STATUS
	AND gph.SD_PRO_DES = '' --TASK NAME
	AND gph.SD_APP_DES = '' --STATUS NAME
--OPTIONAL CODE TO GET THE FIRST INSTANCE OF A GIVEN TASK/STATUS
	AND gph.SD_APP_DD = (
		SELECT
			MIN(gphS.SD_APP_DD)
		FROM GPROCESS_HISTORY gphS
		WHERE
			2=2
			AND gphS.SERV_PROV_CODE = gph.SERV_PROV_CODE
			AND gphS.B1_PER_ID1 = gph.B1_PER_ID1
			AND gphS.B1_PER_ID2 = gph.B1_PER_ID2
			AND gphS.B1_PER_ID3 = gph.B1_PER_ID3
			AND gphS.REC_STATUS = gph.REC_STATUS
			AND gphS.SD_STP_NUM = gph.SD_STP_NUM --WORKFLOW TASK PROCESS ORDER
		)
*/
--
