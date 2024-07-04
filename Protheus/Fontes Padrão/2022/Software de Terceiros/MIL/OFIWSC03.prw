#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    MIL_ScaniaARMS.xml
WSDL Location    MIL_ScaniaARMS.xml
Gerado em        10/02/17 13:02:36
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function OFIWSC03 ; Return

/* -------------------------------------------------------------------------------
WSDL Service WSMIL_ScaniaARMS
------------------------------------------------------------------------------- */

WSCLIENT WSMIL_ScaniaARMS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ClaimVerify
	WSMETHOD SetDebug
	WSMETHOD ExibeErro

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSClaimsRecReq           AS MIL_ScaniaARMS_ArrayOfClaimRecReq
	WSDATA   oWSClaimRecRes            AS MIL_ScaniaARMS_ArrayOfClaimRecRes

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSMIL_ScaniaARMS
	::Init()
	If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170519] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	EndIf

Return Self

WSMETHOD INIT WSCLIENT WSMIL_ScaniaARMS
	::oWSClaimsRecReq    := MIL_ScaniaARMS_ARRAYOFCLAIMRECREQ():New()
	::oWSClaimRecRes     := MIL_ScaniaARMS_ARRAYOFCLAIMRECRES():New()
	::_URL := GetNewPar("MV_MIL0118","http://192.168.1.12/ws/VerifyWorkShopInvoice.svc")
	
Return

WSMETHOD RESET WSCLIENT WSMIL_ScaniaARMS
	::oWSClaimsRecReq    := NIL 
	::oWSClaimRecRes     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSMIL_ScaniaARMS
Local oClone := WSMIL_ScaniaARMS
	oClone:oWSClaimsRecReq :=  IIF(::oWSClaimsRecReq = NIL , NIL ,::oWSClaimsRecReq:Clone() )
	oClone:oWSClaimRecRes :=  IIF(::oWSClaimRecRes = NIL , NIL ,::oWSClaimRecRes:Clone() )
Return oClone

// WSDL Method ClaimVerify of Service WSMIL_ScaniaARMS

WSMETHOD ClaimVerify WSSEND oWSClaimsRecReq WSRECEIVE oWSClaimRecRes WSCLIENT WSMIL_ScaniaARMS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ClaimRequest xmlns="http://xmlns.scania.com/BR/BS/v1">'
cSoap += WSSoapValue("ClaimsRecReq", ::oWSClaimsRecReq, oWSClaimsRecReq , "ArrayOfClaimRecReq", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ClaimRequest>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://xmlns.scania.com/BR/BS/v1/IVerifyWorkShopInvoice/ClaimVerify",; 
	"DOCUMENT","http://xmlns.scania.com/BR/BS/v1",,,; 
	::_URL)

::Init()
::oWSClaimRecRes:SoapRecv( WSAdvValue( oXmlRet,"_CLAIMRESPONSE:_CLAIMRECRES","ArrayOfClaimRecRes",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

WSMETHOD SetDebug WSCLIENT WSMIL_ScaniaARMS
	WSDLDbgLevel(2)
	WSDLSaveXML(.t.)
	WSDLSetProfile(.t.) 
Return

WSMETHOD ExibeErro WSSEND cMensagem WSCLIENT WSMIL_ScaniaARMS

	Local cSvcError   := GetWSCError(1)		// Resumo do erro
	Local cSoapFCode  := GetWSCError(2)		// Soap Fault Code
	Local cSoapFDescr := GetWSCError(3)		// Soap Fault Description
	
	Default cMensagem := ""
	
	If !Empty(cSoapFCode)
		// Caso a ocorrência de erro esteja com o fault_code preenchido ,
		// a mesma teve relação com a chamada do serviço .
		MsgStop(cMensagem + chr(13) + chr(10) + cSoapFDescr,cSoapFCode)
	Else
		// Caso a ocorrência não tenha o soap_code preenchido
		// Ela está relacionada a uma outra falha ,
		// provavelmente local ou interna.
		MsgStop(cMensagem + chr(13) + chr(10) + cSvcError,"Falha Interna")
	Endif

Return

// WSDL Data Structure ArrayOfClaimRecReq

WSSTRUCT MIL_ScaniaARMS_ArrayOfClaimRecReq
	WSDATA   oWSClaimRecReq            AS MIL_ScaniaARMS_ClaimRecReq OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecReq
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecReq
	::oWSClaimRecReq       := {} // Array Of  MIL_ScaniaARMS_CLAIMRECREQ():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecReq
	Local oClone := MIL_ScaniaARMS_ArrayOfClaimRecReq():NEW()
	oClone:oWSClaimRecReq := NIL
	If ::oWSClaimRecReq <> NIL 
		oClone:oWSClaimRecReq := {}
		aEval( ::oWSClaimRecReq , { |x| aadd( oClone:oWSClaimRecReq , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecReq
	Local cSoap := ""
	aEval( ::oWSClaimRecReq , {|x| cSoap := cSoap  +  WSSoapValue("ClaimRecReq", x , x , "ClaimRecReq", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfClaimRecRes

WSSTRUCT MIL_ScaniaARMS_ArrayOfClaimRecRes
	WSDATA   oWSClaimRecRes            AS MIL_ScaniaARMS_ClaimRecRes OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecRes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecRes
	::oWSClaimRecRes       := {} // Array Of  MIL_ScaniaARMS_CLAIMRECRES():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecRes
	Local oClone := MIL_ScaniaARMS_ArrayOfClaimRecRes():NEW()
	oClone:oWSClaimRecRes := NIL
	If ::oWSClaimRecRes <> NIL 
		oClone:oWSClaimRecRes := {}
		aEval( ::oWSClaimRecRes , { |x| aadd( oClone:oWSClaimRecRes , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaARMS_ArrayOfClaimRecRes
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CLAIMRECRES","ClaimRecRes",{},NIL,.T.,"O",NIL,"xs") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSClaimRecRes , MIL_ScaniaARMS_ClaimRecRes():New() )
			::oWSClaimRecRes[len(::oWSClaimRecRes)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ClaimRecReq

WSSTRUCT MIL_ScaniaARMS_ClaimRecReq
	WSDATA   cSave                     AS string OPTIONAL
	WSDATA   nDealerCode               AS int
	WSDATA   nClaimNumber              AS int
	WSDATA   nClaimYear                AS int
	WSDATA   nFailureNumber            AS int
	WSDATA   cDealerRefNumber          AS string OPTIONAL
	WSDATA   cReconsiderationId        AS string OPTIONAL
	WSDATA   cModuleCommonVersionId    AS string OPTIONAL
	WSDATA   cPlanCommonCode           AS string OPTIONAL
	WSDATA   nChassiNumber             AS int
	WSDATA   nEngineNumber             AS int
	WSDATA   nProductType              AS int
	WSDATA   nWorkOrder                AS int
	WSDATA   nDamageCausingPart        AS int
	WSDATA   cFaultCode                AS string OPTIONAL
	WSDATA   nMainGroup                AS int
	WSDATA   nSubGroup                 AS int
	WSDATA   nNatureCode               AS int
	WSDATA   cDeliveryCodeId           AS string OPTIONAL
	WSDATA   cExportVehicleId          AS string OPTIONAL
	WSDATA   cRegistrationDate         AS dateTime
	WSDATA   cInvoiceDate              AS dateTime
	WSDATA   cDeliveryDate             AS dateTime
	WSDATA   cMileageId                AS string OPTIONAL
	WSDATA   cRepairDate               AS dateTime
	WSDATA   nRepairMileage            AS int
	WSDATA   cPreviousRepairDate       AS dateTime
	WSDATA   nPreviousMileage          AS int
	WSDATA   nPickUpMileage            AS int
	WSDATA   nRoadRideMileage          AS int
	WSDATA   cScaniaAssistanceCase     AS string OPTIONAL
	WSDATA   nFieldTestCode            AS int
	WSDATA   nCampaignCode             AS int
	WSDATA   cClaimReason              AS string OPTIONAL
	WSDATA   cModuleTypeCode           AS string OPTIONAL
	WSDATA   nPlannedMileage           AS int
	WSDATA   oWSParts                  AS MIL_ScaniaARMS_ArrayOfPartsType OPTIONAL
	WSDATA   oWSLabour                 AS MIL_ScaniaARMS_ArrayOfLabourType OPTIONAL
	WSDATA   oWSLabourU                AS MIL_ScaniaARMS_ArrayOfLabourUnsType OPTIONAL
	WSDATA   oWSSpecialCost            AS MIL_ScaniaARMS_ArrayOfSpecialCostType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ClaimRecReq
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ClaimRecReq
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ClaimRecReq
	Local oClone := MIL_ScaniaARMS_ClaimRecReq():NEW()
	oClone:cSave                := ::cSave
	oClone:nDealerCode          := ::nDealerCode
	oClone:nClaimNumber         := ::nClaimNumber
	oClone:nClaimYear           := ::nClaimYear
	oClone:nFailureNumber       := ::nFailureNumber
	oClone:cDealerRefNumber     := ::cDealerRefNumber
	oClone:cReconsiderationId   := ::cReconsiderationId
	oClone:cModuleCommonVersionId := ::cModuleCommonVersionId
	oClone:cPlanCommonCode      := ::cPlanCommonCode
	oClone:nChassiNumber        := ::nChassiNumber
	oClone:nEngineNumber        := ::nEngineNumber
	oClone:nProductType         := ::nProductType
	oClone:nWorkOrder           := ::nWorkOrder
	oClone:nDamageCausingPart   := ::nDamageCausingPart
	oClone:cFaultCode           := ::cFaultCode
	oClone:nMainGroup           := ::nMainGroup
	oClone:nSubGroup            := ::nSubGroup
	oClone:nNatureCode          := ::nNatureCode
	oClone:cDeliveryCodeId      := ::cDeliveryCodeId
	oClone:cExportVehicleId     := ::cExportVehicleId
	oClone:cRegistrationDate    := ::cRegistrationDate
	oClone:cInvoiceDate         := ::cInvoiceDate
	oClone:cDeliveryDate        := ::cDeliveryDate
	oClone:cMileageId           := ::cMileageId
	oClone:cRepairDate          := ::cRepairDate
	oClone:nRepairMileage       := ::nRepairMileage
	oClone:cPreviousRepairDate  := ::cPreviousRepairDate
	oClone:nPreviousMileage     := ::nPreviousMileage
	oClone:nPickUpMileage       := ::nPickUpMileage
	oClone:nRoadRideMileage     := ::nRoadRideMileage
	oClone:cScaniaAssistanceCase := ::cScaniaAssistanceCase
	oClone:nFieldTestCode       := ::nFieldTestCode
	oClone:nCampaignCode        := ::nCampaignCode
	oClone:cClaimReason         := ::cClaimReason
	oClone:cModuleTypeCode      := ::cModuleTypeCode
	oClone:nPlannedMileage      := ::nPlannedMileage
	oClone:oWSParts             := IIF(::oWSParts = NIL , NIL , ::oWSParts:Clone() )
	oClone:oWSLabour            := IIF(::oWSLabour = NIL , NIL , ::oWSLabour:Clone() )
	oClone:oWSLabourU           := IIF(::oWSLabourU = NIL , NIL , ::oWSLabourU:Clone() )
	oClone:oWSSpecialCost       := IIF(::oWSSpecialCost = NIL , NIL , ::oWSSpecialCost:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_ClaimRecReq
	Local cSoap := ""
	cSoap += WSSoapValue("Save", ::cSave, ::cSave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DealerCode", ::nDealerCode, ::nDealerCode , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ClaimNumber", ::nClaimNumber, ::nClaimNumber , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ClaimYear", ::nClaimYear, ::nClaimYear , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FailureNumber", ::nFailureNumber, ::nFailureNumber , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DealerRefNumber", ::cDealerRefNumber, ::cDealerRefNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ReconsiderationId", ::cReconsiderationId, ::cReconsiderationId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ModuleCommonVersionId", ::cModuleCommonVersionId, ::cModuleCommonVersionId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PlanCommonCode", ::cPlanCommonCode, ::cPlanCommonCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ChassiNumber", ::nChassiNumber, ::nChassiNumber , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EngineNumber", ::nEngineNumber, ::nEngineNumber , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ProductType", ::nProductType, ::nProductType , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("WorkOrder", ::nWorkOrder, ::nWorkOrder , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DamageCausingPart", ::nDamageCausingPart, ::nDamageCausingPart , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FaultCode", ::cFaultCode, ::cFaultCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MainGroup", ::nMainGroup, ::nMainGroup , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SubGroup", ::nSubGroup, ::nSubGroup , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NatureCode", ::nNatureCode, ::nNatureCode , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DeliveryCodeId", ::cDeliveryCodeId, ::cDeliveryCodeId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ExportVehicleId", ::cExportVehicleId, ::cExportVehicleId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RegistrationDate", ::cRegistrationDate, ::cRegistrationDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InvoiceDate", ::cInvoiceDate, ::cInvoiceDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DeliveryDate", ::cDeliveryDate, ::cDeliveryDate , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MileageId", ::cMileageId, ::cMileageId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RepairDate", ::cRepairDate, ::cRepairDate , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RepairMileage", ::nRepairMileage, ::nRepairMileage , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PreviousRepairDate", ::cPreviousRepairDate, ::cPreviousRepairDate , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PreviousMileage", ::nPreviousMileage, ::nPreviousMileage , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PickUpMileage", ::nPickUpMileage, ::nPickUpMileage , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RoadRideMileage", ::nRoadRideMileage, ::nRoadRideMileage , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ScaniaAssistanceCase", ::cScaniaAssistanceCase, ::cScaniaAssistanceCase , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FieldTestCode", ::nFieldTestCode, ::nFieldTestCode , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampaignCode", ::nCampaignCode, ::nCampaignCode , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ClaimReason", ::cClaimReason, ::cClaimReason , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ModuleTypeCode", ::cModuleTypeCode, ::cModuleTypeCode , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PlannedMileage", ::nPlannedMileage, ::nPlannedMileage , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Parts", ::oWSParts, ::oWSParts , "ArrayOfPartsType", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Labour", ::oWSLabour, ::oWSLabour , "ArrayOfLabourType", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LabourU", ::oWSLabourU, ::oWSLabourU , "ArrayOfLabourUnsType", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SpecialCost", ::oWSSpecialCost, ::oWSSpecialCost , "ArrayOfSpecialCostType", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ClaimRecRes

WSSTRUCT MIL_ScaniaARMS_ClaimRecRes
	WSDATA   nDealerCode               AS int
	WSDATA   nClaimNumber              AS int
	WSDATA   nClaimYear                AS int
	WSDATA   nFailureNumber            AS int
	WSDATA   cDealerRefNumber          AS string OPTIONAL
	WSDATA   cModuleCommonVersionId    AS string OPTIONAL
	WSDATA   cPlanCommonCode           AS string OPTIONAL
	WSDATA   nResultCode               AS int
	WSDATA   oWSFaultDescription       AS MIL_ScaniaARMS_ArrayOfFaultDescription OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ClaimRecRes
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ClaimRecRes
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ClaimRecRes
	Local oClone := MIL_ScaniaARMS_ClaimRecRes():NEW()
	oClone:nDealerCode          := ::nDealerCode
	oClone:nClaimNumber         := ::nClaimNumber
	oClone:nClaimYear           := ::nClaimYear
	oClone:nFailureNumber       := ::nFailureNumber
	oClone:cDealerRefNumber     := ::cDealerRefNumber
	oClone:cModuleCommonVersionId := ::cModuleCommonVersionId
	oClone:cPlanCommonCode      := ::cPlanCommonCode
	oClone:nResultCode          := ::nResultCode
	oClone:oWSFaultDescription  := IIF(::oWSFaultDescription = NIL , NIL , ::oWSFaultDescription:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaARMS_ClaimRecRes
	Local oNode9
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nDealerCode        :=  WSAdvValue( oResponse,"_DEALERCODE","int",NIL,"Property nDealerCode as xs:int on SOAP Response not found.",NIL,"N",NIL,"xs") 
	::nClaimNumber       :=  WSAdvValue( oResponse,"_CLAIMNUMBER","int",NIL,"Property nClaimNumber as xs:int on SOAP Response not found.",NIL,"N",NIL,"xs") 
	::nClaimYear         :=  WSAdvValue( oResponse,"_CLAIMYEAR","int",NIL,"Property nClaimYear as xs:int on SOAP Response not found.",NIL,"N",NIL,"xs") 
	::nFailureNumber     :=  WSAdvValue( oResponse,"_FAILURENUMBER","int",NIL,"Property nFailureNumber as xs:int on SOAP Response not found.",NIL,"N",NIL,"xs") 
	::cDealerRefNumber   :=  WSAdvValue( oResponse,"_DEALERREFNUMBER","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cModuleCommonVersionId :=  WSAdvValue( oResponse,"_MODULECOMMONVERSIONID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cPlanCommonCode    :=  WSAdvValue( oResponse,"_PLANCOMMONCODE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nResultCode        :=  WSAdvValue( oResponse,"_RESULTCODE","int",NIL,"Property nResultCode as xs:int on SOAP Response not found.",NIL,"N",NIL,"xs") 
	oNode9 :=  WSAdvValue( oResponse,"_FAULTDESCRIPTION","ArrayOfFaultDescription",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode9 != NIL
		::oWSFaultDescription := MIL_ScaniaARMS_ArrayOfFaultDescription():New()
		::oWSFaultDescription:SoapRecv(oNode9)
	EndIf
Return

// WSDL Data Structure ArrayOfPartsType

WSSTRUCT MIL_ScaniaARMS_ArrayOfPartsType
	WSDATA   oWSPartsType              AS MIL_ScaniaARMS_PartsType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfPartsType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfPartsType
	::oWSPartsType         := {} // Array Of  MIL_ScaniaARMS_PARTSTYPE():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfPartsType
	Local oClone := MIL_ScaniaARMS_ArrayOfPartsType():NEW()
	oClone:oWSPartsType := NIL
	If ::oWSPartsType <> NIL 
		oClone:oWSPartsType := {}
		aEval( ::oWSPartsType , { |x| aadd( oClone:oWSPartsType , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_ArrayOfPartsType
	Local cSoap := ""
	aEval( ::oWSPartsType , {|x| cSoap := cSoap  +  WSSoapValue("PartsType", x , x , "PartsType", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfLabourType

WSSTRUCT MIL_ScaniaARMS_ArrayOfLabourType
	WSDATA   oWSLabourType             AS MIL_ScaniaARMS_LabourType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfLabourType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfLabourType
	::oWSLabourType        := {} // Array Of  MIL_ScaniaARMS_LABOURTYPE():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfLabourType
	Local oClone := MIL_ScaniaARMS_ArrayOfLabourType():NEW()
	oClone:oWSLabourType := NIL
	If ::oWSLabourType <> NIL 
		oClone:oWSLabourType := {}
		aEval( ::oWSLabourType , { |x| aadd( oClone:oWSLabourType , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_ArrayOfLabourType
	Local cSoap := ""
	aEval( ::oWSLabourType , {|x| cSoap := cSoap  +  WSSoapValue("LabourType", x , x , "LabourType", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfLabourUnsType

WSSTRUCT MIL_ScaniaARMS_ArrayOfLabourUnsType
	WSDATA   oWSLabourUnsType          AS MIL_ScaniaARMS_LabourUnsType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfLabourUnsType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfLabourUnsType
	::oWSLabourUnsType     := {} // Array Of  MIL_ScaniaARMS_LABOURUNSTYPE():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfLabourUnsType
	Local oClone := MIL_ScaniaARMS_ArrayOfLabourUnsType():NEW()
	oClone:oWSLabourUnsType := NIL
	If ::oWSLabourUnsType <> NIL 
		oClone:oWSLabourUnsType := {}
		aEval( ::oWSLabourUnsType , { |x| aadd( oClone:oWSLabourUnsType , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_ArrayOfLabourUnsType
	Local cSoap := ""
	aEval( ::oWSLabourUnsType , {|x| cSoap := cSoap  +  WSSoapValue("LabourUnsType", x , x , "LabourUnsType", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfSpecialCostType

WSSTRUCT MIL_ScaniaARMS_ArrayOfSpecialCostType
	WSDATA   oWSSpecialCostType        AS MIL_ScaniaARMS_SpecialCostType OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfSpecialCostType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfSpecialCostType
	::oWSSpecialCostType   := {} // Array Of  MIL_ScaniaARMS_SPECIALCOSTTYPE():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfSpecialCostType
	Local oClone := MIL_ScaniaARMS_ArrayOfSpecialCostType():NEW()
	oClone:oWSSpecialCostType := NIL
	If ::oWSSpecialCostType <> NIL 
		oClone:oWSSpecialCostType := {}
		aEval( ::oWSSpecialCostType , { |x| aadd( oClone:oWSSpecialCostType , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_ArrayOfSpecialCostType
	Local cSoap := ""
	aEval( ::oWSSpecialCostType , {|x| cSoap := cSoap  +  WSSoapValue("SpecialCostType", x , x , "SpecialCostType", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfFaultDescription

WSSTRUCT MIL_ScaniaARMS_ArrayOfFaultDescription
	WSDATA   oWSFaultDescription       AS MIL_ScaniaARMS_FaultDescription OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_ArrayOfFaultDescription
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_ArrayOfFaultDescription
	::oWSFaultDescription  := {} // Array Of  MIL_ScaniaARMS_FAULTDESCRIPTION():New()
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_ArrayOfFaultDescription
	Local oClone := MIL_ScaniaARMS_ArrayOfFaultDescription():NEW()
	oClone:oWSFaultDescription := NIL
	If ::oWSFaultDescription <> NIL 
		oClone:oWSFaultDescription := {}
		aEval( ::oWSFaultDescription , { |x| aadd( oClone:oWSFaultDescription , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaARMS_ArrayOfFaultDescription
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FAULTDESCRIPTION","FaultDescription",{},NIL,.T.,"O",NIL,"xs") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFaultDescription , MIL_ScaniaARMS_FaultDescription():New() )
			::oWSFaultDescription[len(::oWSFaultDescription)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure PartsType

WSSTRUCT MIL_ScaniaARMS_PartsType
	WSDATA   cPartNumber               AS string OPTIONAL
	WSDATA   nQuantity                 AS int
	WSDATA   cExternalRowId            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_PartsType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_PartsType
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_PartsType
	Local oClone := MIL_ScaniaARMS_PartsType():NEW()
	oClone:cPartNumber          := ::cPartNumber
	oClone:nQuantity            := ::nQuantity
	oClone:cExternalRowId       := ::cExternalRowId
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_PartsType
	Local cSoap := ""
	cSoap += WSSoapValue("PartNumber", ::cPartNumber, ::cPartNumber , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Quantity", ::nQuantity, ::nQuantity , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ExternalRowId", ::cExternalRowId, ::cExternalRowId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure LabourType

WSSTRUCT MIL_ScaniaARMS_LabourType
	WSDATA   nOperationCode            AS int
	WSDATA   nNoOfHours                AS decimal
	WSDATA   nQuantity                 AS int
	WSDATA   cExternalRowId            AS string OPTIONAL
	WSDATA   cDescription              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_LabourType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_LabourType
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_LabourType
	Local oClone := MIL_ScaniaARMS_LabourType():NEW()
	oClone:nOperationCode       := ::nOperationCode
	oClone:nNoOfHours           := ::nNoOfHours
	oClone:nQuantity            := ::nQuantity
	oClone:cExternalRowId       := ::cExternalRowId
	oClone:cDescription         := ::cDescription
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_LabourType
	Local cSoap := ""
	cSoap += WSSoapValue("OperationCode", ::nOperationCode, ::nOperationCode , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NoOfHours", ::nNoOfHours, ::nNoOfHours , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Quantity", ::nQuantity, ::nQuantity , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ExternalRowId", ::cExternalRowId, ::cExternalRowId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure LabourUnsType

WSSTRUCT MIL_ScaniaARMS_LabourUnsType
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   nNoOfHours                AS decimal
	WSDATA   cCodeDescription          AS string OPTIONAL
	WSDATA   cExternalRowId            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_LabourUnsType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_LabourUnsType
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_LabourUnsType
	Local oClone := MIL_ScaniaARMS_LabourUnsType():NEW()
	oClone:cDescription         := ::cDescription
	oClone:nNoOfHours           := ::nNoOfHours
	oClone:cCodeDescription     := ::cCodeDescription
	oClone:cExternalRowId       := ::cExternalRowId
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_LabourUnsType
	Local cSoap := ""
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NoOfHours", ::nNoOfHours, ::nNoOfHours , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodeDescription", ::cCodeDescription, ::cCodeDescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ExternalRowId", ::cExternalRowId, ::cExternalRowId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure SpecialCostType

WSSTRUCT MIL_ScaniaARMS_SpecialCostType
	WSDATA   cDescription              AS string OPTIONAL
	WSDATA   nCostAmount               AS decimal
	WSDATA   cTypeSpc                  AS string OPTIONAL
	WSDATA   cCodeDescription          AS string OPTIONAL
	WSDATA   cExternalRowId            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_SpecialCostType
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_SpecialCostType
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_SpecialCostType
	Local oClone := MIL_ScaniaARMS_SpecialCostType():NEW()
	oClone:cDescription         := ::cDescription
	oClone:nCostAmount          := ::nCostAmount
	oClone:cTypeSpc             := ::cTypeSpc
	oClone:cCodeDescription     := ::cCodeDescription
	oClone:cExternalRowId       := ::cExternalRowId
Return oClone

WSMETHOD SOAPSEND WSCLIENT MIL_ScaniaARMS_SpecialCostType
	Local cSoap := ""
	cSoap += WSSoapValue("Description", ::cDescription, ::cDescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CostAmount", ::nCostAmount, ::nCostAmount , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TypeSpc", ::cTypeSpc, ::cTypeSpc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodeDescription", ::cCodeDescription, ::cCodeDescription , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ExternalRowId", ::cExternalRowId, ::cExternalRowId , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure FaultDescription

WSSTRUCT MIL_ScaniaARMS_FaultDescription
	WSDATA   cFaultDate                AS dateTime
	WSDATA   cFaultSource              AS string OPTIONAL
	WSDATA   cFaultColumn              AS string OPTIONAL
	WSDATA   cFaultValue               AS string OPTIONAL
	WSDATA   cFaultMessage             AS string OPTIONAL
	WSDATA   cExternalRowId            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MIL_ScaniaARMS_FaultDescription
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MIL_ScaniaARMS_FaultDescription
Return

WSMETHOD CLONE WSCLIENT MIL_ScaniaARMS_FaultDescription
	Local oClone := MIL_ScaniaARMS_FaultDescription():NEW()
	oClone:cFaultDate           := ::cFaultDate
	oClone:cFaultSource         := ::cFaultSource
	oClone:cFaultColumn         := ::cFaultColumn
	oClone:cFaultValue          := ::cFaultValue
	oClone:cFaultMessage        := ::cFaultMessage
	oClone:cExternalRowId       := ::cExternalRowId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MIL_ScaniaARMS_FaultDescription
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFaultDate         :=  WSAdvValue( oResponse,"_FAULTDATE","dateTime",NIL,"Property cFaultDate as xs:dateTime on SOAP Response not found.",NIL,"S",NIL,"xs") 
	::cFaultSource       :=  WSAdvValue( oResponse,"_FAULTSOURCE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cFaultColumn       :=  WSAdvValue( oResponse,"_FAULTCOLUMN","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cFaultValue        :=  WSAdvValue( oResponse,"_FAULTVALUE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cFaultMessage      :=  WSAdvValue( oResponse,"_FAULTMESSAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cExternalRowId     :=  WSAdvValue( oResponse,"_EXTERNALROWID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return


