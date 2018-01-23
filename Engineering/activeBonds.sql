SELECT
	b.B1_ALT_ID recordNbr
	,b.B1_APP_TYPE_ALIAS recordType
	,asitPiv.bondType
	,asitPiv.natureImprv
	,asitPiv.descImprv
	,asitPiv.princpl
	,asitPiv.princplAddr
	,asitPiv.suretyHldr
	,asitPiv.suretyAddr
	,asitPiv.suretyPhn
	,asitPiv.secType
	,asitPiv.bondNo
	,asitPiv.bondDate
	,asitPiv.expDate
	,asitPiv.origAmt
	,asitPiv.lastRedux
	,asitPiv.reduxPrcnt
	,asitPiv.reduxAmt
	,asitPiv.bondBal
	,asitPiv.bondStat
	,asitPiv.exonrDate
	,asitPiv.wrkCompl
	,asitPiv.follwUP
	,asitPiv.ntes
FROM B1PERMIT b
INNER JOIN(
	SELECT
		bastv.SERV_PROV_CODE
		,bastv.B1_PER_ID1
		,bastv.B1_PER_ID2
		,bastv.B1_PER_ID3
		,bastv.ROW_INDEX --MUST BE INCLUDED IN SELECT LIST FOR ROWS OF RETURNED DATA TO ALIGN
				--CAN BE USED IN AN AGGREGATE FUNCTION (MIN,MAX,ETC.) TO RETURN FIRST OR LAST ROW
		,bastv.COLUMN_NAME
		,bastv.ATTRIBUTE_VALUE
	FROM BAPPSPECTABLE_VALUE bastv
	WHERE
		1=1
		AND bastv.REC_STATUS = 'A'
		AND bastv.TABLE_NAME = 'Bond' --SUBGROUP
		AND bastv.COLUMN_NAME IN ('Type of Bond','Nature of Covered Improvement'
				,'Description of Bonded Improvement','Principal','Principal Address','Surety/Security Holder'
				,'Surety Address','Surety contact phone#','Security Type','Bond/CD No.'
				,'Original Date of Bond','Expiration Date','Original Amount','Last Reduction Date'
				,'Reduced % Amount','Reduced $ Amount','Bond Balance','Bond Status','Exoneration date'
				,'Work completed?','Follow-up required?','Notes') --COLUMN NAMES FROM ASI TABLE
	)c
PIVOT(
	MAX(ATTRIBUTE_VALUE)
	FOR COLUMN_NAME IN ('Type of Bond' AS bondType,'Nature of Covered Improvement' AS natureImprv
				,'Description of Bonded Improvement' AS descImprv,'Principal' AS princpl
				,'Principal Address' AS princplAddr,'Surety/Security Holder' AS suretyHldr
				,'Surety Address' AS suretyAddr,'Surety contact phone#' AS suretyPhn
				,'Security Type' AS secType,'Bond/CD No.' AS bondNo,'Original Date of Bond' AS bondDate
				,'Expiration Date' AS expDate,'Original Amount' AS origAmt,'Last Reduction Date' AS lastRedux
				,'Reduced % Amount' AS reduxPrcnt,'Reduced $ Amount' AS reduxAmt,'Bond Balance' AS bondBal
				,'Bond Status' AS bondStat,'Exoneration date' AS exonrDate,'Work completed?' AS wrkCompl
				,'Follow-up required?' AS follwUP,'Notes' AS ntes)
)asitPiv ON
	b.SERV_PROV_CODE = asitPiv.SERV_PROV_CODE
	AND b.B1_PER_ID1 = asitPiv.B1_PER_ID1
	AND b.B1_PER_ID2 = asitPiv.B1_PER_ID2
	AND b.B1_PER_ID3 = asitPiv.B1_PER_ID3
WHERE
	1=1
	AND b.SERV_PROV_CODE = 'SANTACLARITA'
	AND b.REC_STATUS = 'A'
	AND b.B1_PER_GROUP = 'Eng_Services'
	AND asitPiv.bondStat = 'Active'