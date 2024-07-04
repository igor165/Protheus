#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWcompositionAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA ccomposition	as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oArrayJson  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT
	
	DATA oRest				as OBJECT
	DATA aHeader			as OBJECT

	METHOD NEW()	
	METHOD Getcomposition()
	METHOD GetNames()
	METHOD GetNmsW()
	METHOD Includecomposition()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0

@type function
/*/
Method NEW() CLASS FWcompositionAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:ccomposition	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'Romaneio de Entrada'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson 		:= JsonObject():New()
	self:oRest 				:= FWRest():New("http://localhost:8080/rest/oga250api")
	self:aHeader 			:= {}
Return

/*/{Protheus.doc} Includecomposition
//Responsável por incluir o registro passado por parametro.
@author Silvana Vieira Torres Streit
@since 16/12/2019
@version 1.0
@return cCodId, código do romaneio incluído.

@type function
/*/
METHOD Includecomposition() CLASS FWcompositionAdapter
	Local lRet 		 	as LOGICAL
	Local oModel, oStruct
	Local oMldNJJ		as Object 
	Local oMldNJM 		as OBJECT 
	Local oMldNJK 		as OBJECT 
	Local cCodId		as CHARACTER
	Local nX, nJ, nI, nDesconto	as NUMERIC
	Local aArea      	as ARRAY
	Local aAux			:= {}	//Auxiliar
	Local aCposDet 		:= {}	//Vetor para receber dados dos itens do romaneio
	Local aCposNJK		:= {}
	Local oStruct
	Local nItErro 		:= 0 
	Local aNJK			:= {}
	Local cNumOP		:= ""
	Private lFilLog		as LOGICAL
	
	nDesconto		:= 0
	
	self:oRest:setPAth("/api/oga/v1/PackingSlipEntry")
	
	aArea := GetArea()
	
	cCodId 	:= ""
	lRet 	:= .T.
	nX := 1
		
	Self:oFieldsJson['EntityCode']		:= ''
	Self:oFieldsJson['EntityStore']		:= ''
	Self:oFieldsJson['PackingListCrop']	:= ''
	Self:oFieldsJson['LocationCode']	:= ''
	Self:oFieldsJson['DiscountsTable']	:= ''
	for nX := 1 To LEN(Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes'))
		if Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NJ0_CODENT'
			Self:oFieldsJson['EntityCode'] := Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value')
			
		elseif Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NJ0_LOJENT'
			Self:oFieldsJson['EntityStore'] := Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value')
			
		elseif Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NJU_CODSAF'
			Self:oFieldsJson['PackingListCrop'] := Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value')
			
		elseif Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('key') == 'NNR_CODIGO'
			Self:oFieldsJson['LocationCode'] := Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('attributes')[nX]:getPropValue('value')
		endif
	next
	
	if EMPTY(Self:oFieldsJson['EntityCode']) .or. EMPTY(Self:oFieldsJson['EntityStore']) .or. ;
	   EMPTY(Self:oFieldsJson['PackingListCrop']) .or. EMPTY(Self:oFieldsJson['LocationCode'])
	   Self:cError := 'Existem atributos não informados e/ou incorretos' + CRLF
	   Self:lOk := .F.
	   Return()
	endif	
		
	Self:oFieldsJson['DiscountsTable']	:= Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis')[1]:getPropValue('discountRange'):getPropValue('analysisHE'):getPropValue('cdAnalysis')
	Self:oFieldsJson['BranchId']		:= FwXFilial('NJM')
	Self:oFieldsJson['ProductCode']		:= Self:oEaiObjRec:getPropValue('product'):getPropValue('productCode')
	Self:oFieldsJson['ProdMeasureUnit']	:= Self:oEaiObjRec:getPropValue('product'):getPropValue('unitMeasurementCode')
	Self:oFieldsJson['Weight1Date']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),1,4);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),6,2);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),9,2)
										  
	Self:oFieldsJson['WeightTime1']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing1'),12,5)
	Self:oFieldsJson['FirstWeight']		:= Self:oEaiObjRec:getPropValue('weight1')
	if Self:oEaiObjRec:getPropValue('manualWeighing') == 'S'
		Self:oFieldsJson['WeightModel1']	:= 'M'
	elseif Self:oEaiObjRec:getPropValue('manualWeighing') == 'N'
		Self:oFieldsJson['WeightModel1']	:= 'A'
	endif
	Self:oFieldsJson['Weight2Date']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),1,4);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),6,2);
										  +SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),9,2)
										  
	Self:oFieldsJson['WeightTime2']		:= SUBSTR(Self:oEaiObjRec:getPropValue('dateTimeWeighing2'),12,5)
	Self:oFieldsJson['SecondWeight']	:= Self:oEaiObjRec:getPropValue('weight2')
	if Self:oEaiObjRec:getPropValue('manualWeighing') == 'S'
		Self:oFieldsJson['WeightModel2']	:= 'M'
	elseif Self:oEaiObjRec:getPropValue('manualWeighing') == 'N'
		Self:oFieldsJson['WeightModel2']	:= 'A'
	endif
	Self:oFieldsJson['VehiclePlate']	:= Self:oEaiObjRec:getPropValue('plateTruck')
	Self:oFieldsJson['CarrierCode']		:= ''
	Self:oFieldsJson['CNPJ/CPF']		:= ''
	
	
	Self:oFieldsJson['PackingSlipRating'] := {}
	For nX := 1 to LEN(Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis'))
		Aadd(self:oFieldsJson['PackingSlipRating'], JsonObject():New())
		nDesconto := Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis')[nX]:getPropValue('percDiscount')					   
		Self:oFieldsJson['PackingSlipRating'][nX]['DiscountPercentage']		:= nDesconto
		Self:oFieldsJson['PackingSlipRating'][nX]['InformedResult']			:= ''
		Self:oFieldsJson['PackingSlipRating'][nX]['BaseWeightForClassific']	:= Self:oEaiObjRec:getPropValue('netWeight')
		Self:oFieldsJson['PackingSlipRating'][nX]['ClassificationResult']	:= Self:oEaiObjRec:getPropValue('cargos')[1]:getPropValue('classificAnalysis')[nX]:getPropValue('value')
		Self:oFieldsJson['PackingSlipRating'][nX]['ClassificationType']		:= '2'
		Self:oFieldsJson['PackingSlipRating'][nX]['DiscountCode']			:= Self:oEaiObjRec:getPropValue('cargos')[1];
							:getPropValue('classificAnalysis')[nX]:getPropValue('analysisDe'):getPropValue('cdAnlDe')
		Self:oFieldsJson['PackingSlipRating'][nX]['Discountity']			:= Self:oEaiObjRec:getPropValue('netWeight') * nDesconto / 100
		Self:oFieldsJson['PackingSlipRating'][nX]['SequenceItem']			:= nX
		Self:oFieldsJson['PackingSlipRating'][nX]['ResultDescription']		:= ''
	next nX
	
	Self:oRest:SetPostParams(EncodeUTF8(FWJsonSerialize(Self:oFieldsJson, .F., .F., .T.)))
	Self:oRest:Post(self:aHeader)
	Self:lOk := .T.
	
Return