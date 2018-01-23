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
select  b.B1_ALT_ID CaseNo                            --F2
       ,b.B1_PER_SUB_TYPE Group_Header                --F3
       ,gph.SD_APP_DD DateIn                          --F5
        ,TO_CHAR(TO_DATE(SYSDATE) - TO_DATE(gph.SD_APP_DD)) NbrDaysOpen  --C1
       ,bwd.B1_WORK_DESC Description                  --F6 
       ,bc.B1_CHECKLIST_COMMENT CustomValue_Label     --F5
from B1PERMIT b 
--BCHCKBOX ASI
LEFT OUTER JOIN BCHCKBOX bc ON
	b.SERV_PROV_CODE = bc.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bc.B1_PER_ID1
	AND b.B1_PER_ID2 = bc.B1_PER_ID2
	AND b.B1_PER_ID3 = bc.B1_PER_ID3
	AND b.REC_STATUS = bc.REC_STATUS
	--AND bc.B1_ACT_STATUS = '' --ASI GROUP
	--AND bc.B1_CHECKBOX_TYPE = '' --ASI SUBGROUP
	AND bc.B1_CHECKBOX_DESC = 'Work Order Type' --ASI FIELD LABEL
--GPROCESS_HISTORY (WORKFLOW HISTORY)
LEFT OUTER JOIN GPROCESS_HISTORY gph ON
	b.SERV_PROV_CODE = gph.SERV_PROV_CODE
	AND b.B1_PER_ID1 = gph.B1_PER_ID1
	AND b.B1_PER_ID2 = gph.B1_PER_ID2
	AND b.B1_PER_ID3 = gph.B1_PER_ID3
	AND b.REC_STATUS = gph.REC_STATUS
	AND gph.SD_PRO_DES = 'Plan Checker Review' --TASK NAME
	AND gph.SD_APP_DES = 'Received for Review' --STATUS NAME
--OPTIONAL CODE TO GET THE FIRST INSTANCE OF A GIVEN TASK/STATUS
	AND gph.SD_APP_DD = (
		SELECT
			MAX(gphS.SD_APP_DD)
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
--BWORKDES
LEFT OUTER JOIN BWORKDES bwd ON
	b.SERV_PROV_CODE = bwd.SERV_PROV_CODE
	AND b.B1_PER_ID1 = bwd.B1_PER_ID1
	AND b.B1_PER_ID2 = bwd.B1_PER_ID2
	AND b.B1_PER_ID3 = bwd.B1_PER_ID3
	AND b.REC_STATUS = bwd.REC_STATUS
	
where b.B1_PER_GROUP='AMS' and b.B1_PER_TYPE='Street' 
  and b.B1_APPL_STATUS_DATE is not null --ALL 29 Recs returned...
  and b.B1_APPL_STATUS='Closed' --ONLY 15 Recs returned...
--vv Actual PARAMETER input statements!!
--	AND b.B1_APPL_STATUS_DATE >= ({?startdate})   --F1
--	AND b.B1_APPL_STATUS_DATE <= ({?enddate})     --F2

--vv Chose order by for testing SQL only...???...
order by b.B1_PER_SUB_TYPE, b.B1_APP_TYPE_ALIAS, 
         b.B1_ALT_ID, bc.B1_CHECKLIST_COMMENT ; --23 Recs returned...
--
--
/*
1. Agency Name = ‘SANTACLARITA’
2. Parent Record Type = AMS/Street/%/%
3. Status = ‘Closed’
4. Status Date between Start Date and End Date parameters
*/
--
