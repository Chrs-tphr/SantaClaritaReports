/*
/*
EntitlementNo  MasterCase   ActionDate  Action     PlannerName  Applicant              ProjectDescription  ProjectAddress        ProjectAPN  OtherEntitlements                      (B1_PER_SUB_TYPE)
OS03-00007     MC#03-00022  (null)      Submitted  (null)       EDWARD BLANCO          A18055              18055 BENEDA LANE     2802004020  OS03-00007                             Development Review
. . .
IS03-00001     MC#03-00091  (null)      Approved   (null)       RICK JACKSON           TR42670             42670 TRACT 42670-02  2836066001  IS03-00001, LPR04-00029, MUP03-00010   Development Review
LPR04-00029    MC#03-00091  (null)      Approved   (null)       RICK JACKSON           TR42670             42670 TRACT 42670-02  2836066001  IS03-00001, LPR04-00029, MUP03-00010   Landscape Plan Review
MUP03-00010    MC#03-00091  (null)      Approved   (null)       RICK JACKSON           TR42670             42670 TRACT 42670-02  2836066001  IS03-00001, LPR04-00029, MUP03-00010   Minor Use Permit
. . .
CUP03-00010    MC#03-00287  (null)      Approved   (null)       ACE CIVIL ENGINEERING  TR60069             (null)                2829027030  CUP03-00010, MUP06-00003, TTM03-00001  Minor Use Permit
MUP06-00003    MC#03-00287  (null)      Submitted  (null)       ACE CIVIL ENGINEERING  TR60069	           (null)                2829027030  CUP03-00010, MUP06-00003, TTM03-00001  Minor Use Permit
TTM03-00001    MC#03-00287  (null)      Approved   (null)       ACE CIVIL ENGINEERING  A60069	           (null)                2829027030  CUP03-00010, MUP06-00003, TTM03-00001  Tentative Tract Map
*/
*/
--
SELECT   b.B1_ALT_ID EntitlementNo                    --F4
        ,b3.B1_ALT_ID MasterCase                      --F5
        ,b.B1_APPL_STATUS_DATE ActionDate             --F6
        ,b.B1_APPL_STATUS Action                      --F7
        ,ltrim(rtrim(g3s.GA_FNAME||' '||g3s.GA_LNAME)) PlannerName  --F8
        ,ltrim(rtrim(contct.contName)) Applicant      --F9
        ,b.B1_SPECIAL_TEXT  ProjectDescription        --F10
        ,NVL(TO_CHAR(b3aV.B1_HSE_NBR_START),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_DIR),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_NAME),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_STR_SUFFIX),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_TYPE),' '),'')
         ||NVL(NULLIF(' '||TRIM(b3aV.B1_UNIT_START),' '),'') ProjectAddress  --F11
        ,b3pV.B1_PARCEL_NBR ProjectAPN                --F12
        ,(SELECT LISTAGG(b4.B1_ALT_ID,', ') 
                 WITHIN GROUP (ORDER BY b4.B1_ALT_ID)
          FROM XAPP2REF xa3 
          LEFT JOIN B1PERMIT b4 ON xa3.SERV_PROV_CODE = b4.SERV_PROV_CODE
            AND xa3.B1_PER_ID1 = b4.B1_PER_ID1 --CHILD IS IDENTIFIED WITH THE PER IDS
            AND xa3.B1_PER_ID2 = b4.B1_PER_ID2
            AND xa3.B1_PER_ID3 = b4.B1_PER_ID3
            AND xa3.REC_STATUS = b4.REC_STATUS
            and b4.B1_PER_GROUP='Planning' 
            and b4.B1_PER_TYPE='Master Case' 
            and b4.B1_PER_SUB_TYPE != 'Master Case' --specifies it as "children only"
            and b4.B1_PER_CATEGORY='NA' 
          WHERE b3.SERV_PROV_CODE = xa3.SERV_PROV_CODE
            AND b3.B1_PER_ID1 = xa3.B1_MASTER_ID1 --PARENT IS IDENTIFIED WITH THE MASTER IDS
            AND b3.B1_PER_ID2 = xa3.B1_MASTER_ID2
            AND b3.B1_PER_ID3 = xa3.B1_MASTER_ID3
            AND b3.REC_STATUS = xa3.REC_STATUS
--            AND b.B1_PER_ID1 != xa3.B1_PER_ID1 --Record being Reported is NOT returned
--            AND b.B1_PER_ID2 != xa3.B1_PER_ID2 --Record being Reported is NOT returned
--            AND b.B1_PER_ID3 != xa3.B1_PER_ID3 --Record being Reported is NOT returned
         ) AS OtherEntitlements                       --F13
        ,b.b1_per_sub_type                            --F3 Parameter Type

FROM B1PERMIT b
--GET PARENT RECORD
LEFT OUTER JOIN XAPP2REF xa2 ON
	b.SERV_PROV_CODE = xa2.SERV_PROV_CODE
	AND b.B1_PER_ID1 = xa2.B1_PER_ID1  --Child is PER_IDs
	AND b.B1_PER_ID2 = xa2.B1_PER_ID2
	AND b.B1_PER_ID3 = xa2.B1_PER_ID3
	AND b.REC_STATUS = xa2.REC_STATUS
	LEFT OUTER JOIN B1PERMIT b3 ON
		xa2.SERV_PROV_CODE = b3.SERV_PROV_CODE
		AND xa2.B1_MASTER_ID1 = b3.B1_PER_ID1  --Parent is MASTER_IDs
		AND xa2.B1_MASTER_ID2 = b3.B1_PER_ID2
		AND xa2.B1_MASTER_ID3 = b3.B1_PER_ID3
		AND xa2.REC_STATUS = b3.REC_STATUS
    and b3.B1_PER_GROUP='Planning' 
    and b3.B1_PER_TYPE='Master Case' 
    and b3.B1_PER_SUB_TYPE='Master Case' --specifies it as "parent only"
    and b3.B1_PER_CATEGORY='NA' 
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
  and b.B1_PER_SUB_TYPE != 'Master Case' and b.B1_PER_CATEGORY='NA' 
  and b.REC_STATUS='A' 
--vv Actual input statements!!
--	AND b.B1_APPL_STATUS_DATE >= ({?startdate})
--	AND b.B1_APPL_STATUS_DATE <= ({?enddate})
--	AND b.B1_PER_SUB_TYPE IN ({?recordtype})

--vv Used for testing SQL only...
--  and b.b1_alt_id in ('CUP03-00010','MUP06-00003','TTM03-00001')
--  and b.b1_alt_id in ('IS03-00001','LPR04-00029','MUP03-00010')
--vv Used ORDER BY for testing SQL only...
--ORDER BY g3s.GA_FNAME||' '||g3s.GA_LNAME, b.b1_ALT_ID ; 
ORDER BY b3.b1_alt_id,b.b1_ALT_ID ; 
--
/*
1. Agency Name = ‘SANTACLARITA’
2. Parent Record Type = Planning/Master Case/Master Case/NA
3. Child Record Types = Planning/Master Case/%/NA (Exclude Master Case Sub Type)
4. Assigned to Staff = Planner Parameter
*/
--
--
