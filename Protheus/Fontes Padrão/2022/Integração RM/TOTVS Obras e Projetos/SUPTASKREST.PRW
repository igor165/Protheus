#Include "RESTFUL.CH"
#Include "TOTVS.CH"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"  
#Include "COLORS.CH"                                                                                                     
#Include "TBICONN.CH"
#Include "COMMON.CH"
#Include "XMLXFUN.CH"
#Include "fileio.ch" 
#Include "SUPTASKREST.CH"  



#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )

WSRESTFUL TASKCOSTASSIGNMENTS DESCRIPTION STR0009 

	WSDATA page 					AS INTEGER
	WSDATA pageSize					AS INTEGER
	WSDATA sourceApp 				AS STRING
	WSDATA companyId 				AS STRING
	WSDATA branchId 				AS STRING
	WSDATA freightValueExcluded 	AS Boolean OPTIONAL
	WSDATA insuranceValueExcluded 	AS Boolean OPTIONAL
	WSDATA expenseValueExcluded 	AS Boolean OPTIONAL
	WSDATA IPIValueExcluded		 	AS Boolean OPTIONAL
	WSDATA initialTaskInternalId 	AS STRING
	WSDATA finishTaskInternalId 	AS STRING
	WSDATA initialDate 				AS STRING OPTIONAL
	WSDATA finishDate 				AS STRING OPTIONAL
	WSDATA datePurchase 			AS STRING OPTIONAL
	WSDATA dateStock 				AS STRING OPTIONAL
	WSDATA datePayment 				AS STRING OPTIONAL
	WSDATA log		 				AS Boolean OPTIONAL
	WSDATA currencyId			    AS STRING OPTIONAL
	WSDATA returnDeliveryAndPaid    AS Boolean OPTIONAL
	WSDATA deliveryType             AS INTEGER OPTIONAL
	WSMETHOD GET DESCRIPTION STR0010 WSSYNTAX "/TASKCOSTASSIGNMENTS || /TASKCOSTASSIGNMENTS/{id}"
		
END WSRESTFUL

WSMETHOD GET WSRECEIVE page, pageSize, sourceApp, companyId, branchId, FreightValueExcluded, InsuranceValueExcluded, ExpenseValueExcluded, IPIValueExcluded, initialTaskInternalId, finishTaskInternalId, initialDate, finishDate, DatePurchase, DateStock, DatePayment, log, currencyId, returnDeliveryAndPaid, deliveryType WSSERVICE TASKCOSTASSIGNMENTS

Local lMetodo		:= .F.
Local lNew			:= .F.
Local lFrete		:= .F.
Local lSegur		:= .F.
Local lDespe		:= .F.
Local lVaIPI        := .F.
Local lCompact	    := .F.
Local lPrim		    := .T.
Local nXi			:= 0
Local nTotal		:= 0
Local nPages		:= 0
Local nPSize		:= 0
Local nAcresc		:= 0
Local nLenComp		:= 0
Local nCurReg		:= 0
Local nTotReg		:= 0
Local cConDate		:= ""
Local cTempTsk		:= ""
Local cMarca		:= ""
Local cEmpre		:= ""
Local cBranc		:= ""
Local cITare		:= ""
Local cFTare		:= ""
Local cCurrencySimbol   := ""
Local cComp			:= ""
Local cBanco		:= ""
Local strJs			:= ""
Local dIDate		:= CtoD("//")
Local dFDate		:= CtoD("//")
Local aTpMov		:= {}
Local aEmpre		:= {}
Local aTarIn		:= {}
Local aTarFi		:= {}
Local aArrayTask	:= {}
Local aArrayMovim	:= {}
Local jsreturn		:= Nil
Local jsdata		:= Nil
Local jstask		:= Nil
Local jsMovim		:= Nil
Local cQry	        := "" 
Local sCampoMoeda   := 1
Local nTaxaMoeda	:= 0
Local dConvert	    := CtoD("//")

private bReturnDeliveryAndPaid := returnDeliveryAndPaid
private ideliveryType   := deliveryType

Private nPosOri		:= 1
Private nPosFil		:= 2 
Private nPosPro		:= 3
Private nPosRev		:= 4
Private nPosTaf		:= 5
Private bError		:= { |e| oError := e, Break(e) }
Private bErrorBlock	:= ErrorBlock( bError )
Private oError		:= Nil
Private pExistCustom		:= .F.

DEFAULT ::page						:= 0
DEFAULT ::pageSize					:= 0
DEFAULT ::sourceApp					:= ""
DEFAULT ::companyId					:= ""
DEFAULT ::branchId					:= ""  
DEFAULT ::FreightValueExcluded		:= .F.
DEFAULT ::insuranceValueExcluded	:= .F.
DEFAULT ::expenseValueExcluded		:= .F. 
DEFAULT ::IPIValueExcluded          := .F.
DEFAULT ::initialTaskInternalId		:= ""
DEFAULT ::finishTaskInternalId		:= ""
DEFAULT ::initialDate				:= ""
DEFAULT ::finishDate				:= ""
DEFAULT ::datePurchase				:= ""
DEFAULT ::dateStock					:= ""
DEFAULT ::datePayment				:= ""
DEFAULT ::log						:= .F.
DEFAULT ::currencyId				:= ""
DEFAULT ::returnDeliveryAndPaid     := .F.
DEFAULT ::deliveryType              := 0 // 0 Pré-Nota  1 Nota fiscal

BEGIN SEQUENCE

	nPages := ::page
	nPSize := ::pageSize
	cMarca := ::sourceApp
	cEmpre := ::companyId
	cBranc := ::branchId 
	lFrete := ::FreightValueExcluded
	lSegur := ::InsuranceValueExcluded
	lDespe := ::ExpenseValueExcluded
	lVaIPI := ::IPIValueExcluded
	cITare := ::initialTaskInternalId
	cFTare := ::finishTaskInternalId
	cCurrencySimbol := ::currencyId
	dIDate := SToD(StrTran(::initialDate,"-",""))		  
	dFDate := SToD(StrTran(::finishDate,"-",""))
    
	bReturnDeliveryAndPaid := ::returnDeliveryAndPaid
    ideliveryType := ::deliveryType
	
	aTpMov := {}
	aEmpre := {}
	aTarIn := {}
	aTarFi := {}

	aEmpre := FWEAIEMPFIL(cEmpre, cBranc, cMarca)

	If Len (aEmpre) < 2
		SetRestFault(400, STR0001 + cEmpre + STR0002 + cBranc + "' !")
		Return lMetodo
	EndIf 

	If Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "CTG", "CTO", "AFR", "SE2", "AFN", "SD1", "SD2", "SC7", "SC1", "AFH", "SCP", "SD3", "SC1" MODULO "COM" 
	EndIf
	
	cPdCVer := RTrim(PmsMsgUVer('ORDER', 'MATA120')) //Vers?o do Pedido de Compra
    cSCoVer	:= RTrim(PmsMsgUVer('REQUEST', 'MATA110')) //Versão da Solicitação de Compra
    cSArVer	:= RTrim(PmsMsgUVer('REQUEST', 'MATA105')) //Versão da Solicitação de Armazém

	// Deixa setado o erro
	SUPSETERRHDL(STR0011)
		
	If AllTrim(TcGetDB()) == "ORACLE"
		cBanco := "ORACLE"
	Else
		cBanco := "MSSQL"
	EndIf
	
	//Reset o erro
	SUPRESERRHDL()
	
	//Deixa setado o erro, caso ocorra
	SUPSETERRHDL(STR0013)
	
	If SC7->(FieldPos("C7_APROPRM")) == 0
		SetRestFault(400, STR0005)
		Return (lMetodo)
	EndIf
	
	//Reset o erro
	SUPRESERRHDL()
	
	//Valida informações obrigatorias
	If !SUPCPOOBR(nPages,nPSize,cMarca,cEmpre,cBranc,cITare,cFTare)
		Return lMetodo
	EndIf
	
	//Verifica se os campos de data do movimento estão coerentes com as entidades
	aAdd(aTpMov, SUPVLDMOV("NFE",::datePurchase))
	aAdd(aTpMov, SUPVLDMOV("EST",::dateStock))
	aAdd(aTpMov, SUPVLDMOV("CPG",::datePayment))
	aAdd(aTpMov, SUPVLDMOV("DEV",::datePurchase))
	
	For nXi := 1 To Len (aTpMov) 
		If !Empty(aTpMov[nXi][3])
			SetRestFault(400, aTpMov[nXi][3])
			Return lMetodo
		EndIf			
	Next nXi

	aTarIn := SUPEAITASK("TAS",cMarca,cITare)
	aTarFi := SUPEAITASK("TAS",cMarca,cFTare)

	If !SUPVLDPRJ(aTarIn,aTarFi)
		Return lMetodo
	Endif

	aTarIn[nPosPro] := Padr(aTarIn[nPosPro],TamSX3("AF8_PROJET")[1])
	aTarIn[nPosRev] := Padr(aTarIn[nPosRev],TamSX3("AF9_REVISA")[1])
	aTarIn[nPosTaf] := Padr(aTarIn[nPosTaf],TamSX3("AF9_TAREFA")[1])
	
	aTarFi[nPosPro] := Padr(aTarFi[nPosPro],TamSX3("AF8_PROJET")[1])
	aTarFi[nPosRev] := Padr(aTarFi[nPosRev],TamSX3("AF9_REVISA")[1])
	aTarFi[nPosTaf] := Padr(aTarFi[nPosTaf],TamSX3("AF9_TAREFA")[1])
	
	//Retorna a menor data do periodo contabil que esta aberto
	cConDate := SUPCTBOPEN()

	
	if Upper(SuperGetMv("MV_SIMB2",,"")) == Upper(cCurrencySimbol)
		sCampoMoeda := 2 
	elseif Upper(SuperGetMv("MV_SIMB3",,"")) == Upper(cCurrencySimbol)
		sCampoMoeda := 3 
	elseif Upper(SuperGetMv("MV_SIMB4",,"")) == Upper(cCurrencySimbol)
		sCampoMoeda := 4 
	elseif Upper(SuperGetMv("MV_SIMB5",,"")) == Upper(cCurrencySimbol)
		sCampoMoeda := 5 
	else
		sCampoMoeda := 1 
	endif
	
	If !SUPREADSQL(aEmpre[1],aEmpre[2],aTarIn[nPosPro],aTarIn[nPosRev],aTarIn[nPosTaf],aTarFi[nPosTaf],dIDate,dFDate,aTpMov,nPages,nPSize,cBanco,@cQry,cCurrencySimbol, bReturnDeliveryAndPaid, ideliveryType)
		Return (lMetodo)
	EndIf

	/*
	RETORNO REST
	*/

	SUPSETERRHDL(STR0012)

	//define o tipo de retorno do método
	::SetContentType("application/json")
		
	jsreturn := JsonObject():new()
    
	jsdata := JsonObject():new()
       
	lNew := .F.
	nTotal := 0
	
	DBSelectArea("DAD")
	DAD->(DBGoTop())
	
	

	Do While DAD->( !EOF() )
    	nAcresc    := 0
		nTaxaMoeda := SUPTXMOEDAPRJ(sCampoMoeda)

		//Se a moeda do documento for diferente da Moeda 1, gera uma taxa de conversao para moeda 1 (divisão)
		if DAD->MOEDA <> 1
			nTaxaDivisao := 1 / SUPTXMOEDAPRJ(DAD->MOEDA)
			nTaxaMoeda := nTaxaMoeda * nTaxaDivisao
		Endif

    	If lPrim
    		lPrim		:= .F.
    		nTotReg	:= DAD->TOTALNUMBER    		
    	EndIf
    
    	If cTempTsk <> cEmpAnt+'|'+RTrim(aTarIn[nPosFil])+'|'+RTrim(DAD->PROJETO)+'|'+RTrim(DAD->REVISAO)+'|'+RTrim(DAD->TAREFA)   
    		If Empty (cTempTsk)
    			cTempTsk := cEmpAnt+'|'+RTrim(aTarIn[nPosFil])+'|'+RTrim(DAD->PROJETO)+'|'+RTrim(DAD->REVISAO)+'|'+RTrim(DAD->TAREFA) 
    		Else
    			jstask := JsonObject():new()
		    
	    		jstask['taskInternalId'] := cTempTsk
	    		
	    		jstask['taskCostAssignments'] := aArrayMovim
	    		
	    		AAdd(aArrayTask,jstask )
	    		
	    		aArrayMovim := {}
	    		
	    		cTempTsk := cEmpAnt+'|'+RTrim(aTarIn[nPosFil])+'|'+RTrim(DAD->PROJETO)+'|'+RTrim(DAD->REVISAO)+'|'+RTrim(DAD->TAREFA)   
		    EndIf
    	EndIf
	    
		If !lFrete
			nAcresc += DAD->FRETE
		EndIf
	    
		If !lSegur
			nAcresc += DAD->SEGURO
		EndIf
	    
		If !lDespe
			nAcresc += DAD->DESPESA
		EndIf
		
		If !lVaIPI
			nAcresc += DAD->VALIPI
		EndIf	
		
		jsMovim := JsonObject():new()
	    
		jsMovim['companyInternalid']	:= cEmpAnt+'|'+RTrim(DAD->FILIAL)
		jsMovim['documentType'] 			:= RTrim(DAD->ENTIDADE)
		jsMovim['recno']					:= DAD->RECNO
		
		If !Empty(DAD->DOCUMENTO)
			jsMovim['documentNumber']	:= RTrim(DAD->DOCUMENTO)
		EndIf
		
		If !Empty(DAD->ITEM)
			jsMovim['itemNumber'] 		:= RTrim(DAD->ITEM)
		EndIf
		
		jsMovim['apportionmentDate'] 	:= SubStr(DAD->DTMOV,1,4)+'-'+SubStr(DAD->DTMOV,5,2)+'-'+SubStr(DAD->DTMOV,7,2)
	    
		If !Empty(DAD->PRODUTO)
			jsMovim['itemInternalid'] 	:= IntProExt(cEmpAnt,RTrim(xFilial("SB1")),RTrim(DAD->PRODUTO))[2]
		EndIf
	    
		If !Empty(DAD->UNIDADE)
			jsMovim['unitOfMeasureInternalid']	:= IntUndExt(cEmpAnt,RTrim(xFilial("SAH")),RTrim(DAD->UNIDADE))[2]
		EndIf
	    
		jsMovim['quantity'] 				:= DAD->QUANTIDADE
		jsMovim['unitPrice'] 			    := DAD->UNITARIO * nTaxaMoeda
		
		jsMovim['deductionValue'] 			:= DAD->VRDEDUCAO * nTaxaMoeda
		jsMovim['retentionValue'] 			:= DAD->VRRETENCAO * nTaxaMoeda

		jsMovim['totalIncrease'] 			:= ( DAD->TOTAL_FRETE + DAD->TOTAL_SEGURO + DAD->TOTAL_DESPESA + DAD->TOTAL_VALIPI ) * nTaxaMoeda
		
		If !lVaIPI .and. DAD->VALIMP1 > 0
			jsMovim['totalDecrease'] 			:= (DAD->TOTAL_DESCONTO + DAD->TOTAL_VALIMP1)  * nTaxaMoeda
		else
			jsMovim['totalDecrease'] 			:= (DAD->TOTAL_DESCONTO)  * nTaxaMoeda
		EndIf
		
		jsMovim['totalQuant'] 			:= DAD->TOTAL_QUANT
		jsMovim['fil'] 					:= DAD->FIL
		jsMovim['ped'] 					:= DAD->PED
		jsMovim['itemped'] 			:= DAD->ITEMPED
		jsMovim['tipoped'] 			:= DAD->TIPOPED

		jsMovim['orderInternalid'] := IntPdCExt(/*Empresa*/, /*Filial*/, DAD->PED, Nil, cPdCVer)[2]

		jsMovim['increase'] 				:= nAcresc  * nTaxaMoeda
		
		If !Empty(DAD->C1_NUM)
			jsMovim['RequestInternalid'] := IntSCoExt(/*cEmpresa*/, DAD->C1_FILIAL, DAD->C1_NUM, DAD->C1_ITEM, cSCoVer)[2]
		EndIf

		If !Empty(DAD->CP_NUM)
            dConvert := SToD(DAD->CP_EMISSAO)
        	jsMovim['WarehouseRequestInternalid'] :=  IntSArExt(, DAD->CP_FILIAL, DAD->CP_NUM, DAD->CP_ITEM, dConvert, cSArVer)[2]
		EndIf

		nDesc := DAD->DESCONTO

		If !lVaIPI .and. DAD->VALIMP1 > 0
			nDesc += DAD->VALIMP1
		EndIf

		jsMovim['decrease'] 				:= nDesc  * nTaxaMoeda
		jsMovim['totalPrice'] 				:= (DAD->TOTAL + nAcresc - nDesc)  * nTaxaMoeda

		If !Empty(DAD->FORNECEDOR)
			jsMovim['customerVendorInternalId'] := IntForExt(cEmpAnt,RTrim(xFilial("SA2")),RTrim(DAD->FORNECEDOR),RTrim(DAD->LOJA))[2]
		EndIf
	    
		jsMovim['currencyProjectInternalId'] := C40MontInt(,Iif((sCampoMoeda<10),STrZero(sCampoMoeda,TAMSx3("CTO_MOEDA")[1],0),cValtoChar(sCampoMoeda)))

		jsMovim['currencyDocumentInternalId'] :=  C40MontInt(,Iif((DAD->MOEDA<10),STrZero(DAD->MOEDA,TAMSx3("CTO_MOEDA")[1],0),cValtoChar(DAD->MOEDA)))

		jsMovim['currencyRate'] := nTaxaMoeda

		//se nao tem taxa e a moeda é diferente, retorna a moeda da nota. 1 é por que não tem taxa de conversao
		If nTaxaMoeda == 1 .and. !Empty(DAD->MOEDA) .and. DAD->MOEDA <> sCampoMoeda
			jsMovim['currencyInternalId'] := jsMovim['currencyDocumentInternalId']
		else
			jsMovim['currencyInternalId'] := jsMovim['currencyProjectInternalId']
		EndIf
		
	    AAdd(aArrayMovim,jsMovim)
	    
	    nCurReg := DAD->ITEMNUMBER
	    
	    DAD->(DBSkip())
	Enddo
    
	jstask := JsonObject():new()
		    
	If Len(aArrayMovim) > 0
		jstask['taskInternalId'] 		:= cTempTsk
		jstask['taskCostAssignments'] 	:= aArrayMovim
	
		aArrayMovim := {}
	   	AAdd(aArrayTask, jstask )
	EndIf
		    		
	jsdata['accountingClosingDate']		:= cConDate
	jsdata['tasks']						:= aArrayTask
	    
	jsreturn['total']			:= nTotReg
	jsreturn['hasNext']		:= Iif(nCurReg >= nTotReg,.F.,.T.)
	jsreturn['data'] 			:= jsdata  

	If(pExistCustom)
		jsreturn['qryCustom']  := .T.
	EndIf

	If ::log 
	    jsreturn['returnDeliveryAndPaid']  := bReturnDeliveryAndPaid
		jsreturn['deliveryType']    := ideliveryType
	    jsreturn['command']			:=  cQry
		jsreturn['enviroment']		:= GetEnvServer()
		jsreturn['company']			:= aEmpre[1] 
		jsreturn['branch']			:= aEmpre[2]
	Endif

	strJs := FWJsonSerialize(jsreturn,.T.,.T.)
    
	If Type("::GetHeader('Accept-Encoding')") != "U" .And. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )        
		lCompact := .T.
	EndIf
    
	If lCompact    	
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(strJs,@cComp,@nLenComp)	        
	Else
		cComp := strJs
	Endif
    
    ::SetResponse(cComp)

	/*
	RETORNO REST
	*/

	SUPRESERRHDL()

	lMetodo := .T.

RECOVER 	
	
	ErrorBlock(bErrorBlock)
	SetRestFault(400, STR0019 + TAB + oError:Description)	
	lMetodo := .F.
	Return lMetodo

END SEQUENCE 

ErrorBlock( bErrorBlock )

Return lMetodo 


/*
{Protheus.doc} SUPTXMOEDAPRJ
@Uso    Busca 
@param  sCampoMoeda - Numero da moeda; 
@return	Decimal taxa da moeda do Projeto

@Autor  Daniel de Paulo e Silva - TOTVS
*/

Function SUPTXMOEDAPRJ(sCampoMoeda)

Local lTaxaMoeda := 0

if sCampoMoeda == 2
	lTaxaMoeda := DAD->TAXAMOEDA2
elseif sCampoMoeda == 3
	lTaxaMoeda := DAD->TAXAMOEDA3 
elseif sCampoMoeda == 4
	lTaxaMoeda := DAD->TAXAMOEDA4 
elseif sCampoMoeda == 5
	lTaxaMoeda := DAD->TAXAMOEDA5 
else
	lTaxaMoeda := 1
endif

if(lTaxaMoeda == 0)
   lTaxaMoeda :=  1
endif

Return lTaxaMoeda

/*
{Protheus.doc} SUPCPOOBR
@Uso    Verifica os campos obrigatório no recebimento da mensagem REST
@Autor  Wesley Alves Pereira - TOTVS
@param  Campos recebidos da mensagem REST
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
*/

Static Function SUPCPOOBR(nPages,nPSize,cMarca,cEmpre,cBranc,cITare,cFTare)				

Local lRet := .T.

If nPages <= 0
	SetRestFault(400, STR0003 + "nPage" + STR0004)
	lRet := .F.
EndIf

If nPSize <= 0
	SetRestFault(400, STR0003 + "pageSize" + STR0004)
	lRet := .F.
EndIf

If Empty(cMarca) 
	SetRestFault(400, STR0003 + "sourceApp" + STR0004)
	lRet := .F.
EndIf

If Empty(cEmpre) 
	SetRestFault(400, STR0003 + "companyId" + STR0004)
	lRet := .F.
EndIf

If Empty(cBranc) 
	SetRestFault(400, STR0003 + "branchId" + STR0004)
	lRet := .F.
EndIf

If Empty(cITare) 
	SetRestFault(400, STR0003 + "initialTaskInternalId" + STR0004)
	lRet := .F.
EndIf

If Empty(cFTare) 
	SetRestFault(400, STR0003 + "finishTaskInternalId" + STR0004)
	lRet := .F.
EndIf

Return lRet

/*
{Protheus.doc} SUPVLDMOV
@Uso    Verifica se os campos de data do movimento estão coerentes com as entidades
@param  cDocType = Movimento ; cFilterField = Campo de Pesquisa 
@return	.T. -> Processo validado ; .F. -> Processo Interrompido

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPVLDMOV(cDocType,cFilterField)

Local cCampoRetorno	:= ""
Local cErro			:= ""
Local aResult			:= {}

SUPSETERRHDL(STR0014)

If cDocType == "CPG"
	If Empty(cFilterField)
		cCampoRetorno := ""        
	Elseif cFilterField == "00" 
		cErro := STR0020             
	Elseif cFilterField == "01" 
		cCampoRetorno :="E2_EMISSAO"
	Elseif cFilterField == "02" 
		cCampoRetorno := "E2_VENCTO"
	Elseif cFilterField == "03" 
		cCampoRetorno := "E2_VENCREA"
	Elseif cFilterField == "04" 
		cErro := STR0021
	Else
		cErro := STR0022
	Endif
Elseif cDocType == "NFE"
	If Empty(cFilterField)
		cCampoRetorno := ""
	Elseif cFilterField == "00" 
		cCampoRetorno := "D1_DTDIGIT"
	Elseif cFilterField == "01"        		
		cCampoRetorno :="D1_EMISSAO"
	Elseif cFilterField == "02" 
		cErro := STR0023
	Elseif cFilterField == "03" 
		cErro := STR0024
	Elseif cFilterField == "04" 
		cErro := STR0025
	Else
		cErro := STR0026
Endif
Elseif cDocType == "DEV"
		If Empty(cFilterField)
			cCampoRetorno := ""
		Elseif cFilterField == "00" 
			cCampoRetorno := "D2_DTDIGIT"
		Elseif cFilterField == "01"        		
			cCampoRetorno :="D2_EMISSAO"
		Elseif cFilterField == "02" 
			cErro := STR0023
		Elseif cFilterField == "03" 
			cErro := STR0024
		Elseif cFilterField == "04" 
			cErro := STR0025
		Else
			cErro := STR0026
Endif
	Elseif cDocType == "EST"
		If Empty(cFilterField)
			cCampoRetorno := ""
		Elseif cFilterField == "00"
			cErro := STR0027
		Elseif cFilterField == "01" 
			cCampoRetorno :="D3_EMISSAO"
		Elseif cFilterField == "02" 
			cErro := STR0028
		Elseif cFilterField == "03" 
			cErro := STR0029
		Elseif cFilterField == "04" 
			cCampoRetorno :="D3_DTLANC"
		Else
			cErro := STR0030       
	Endif
Endif

aAdd(aResult,cDocType)
aAdd(aResult,cCampoRetorno)
aAdd(aResult,cErro)

SUPRESERRHDL()

Return (aResult)

/*
{Protheus.doc} SUPEAITASK
@Uso    Verifica as mensagem recebidas de acordo com a integração EAI para montagem de DE/PARA
@param  cEntidade = Entidade de Integracao;cMarca = Produto de Integracao; cOrigem = Campos recebidos da mensagem REST
@return	Array de informação de DE/PARA

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPEAITASK(cEntidade,cMarca,cOrigem1)

Local aIntegra	:= {}
Local aPrjTask	:= {}

SUPSETERRHDL(STR0015)

If cEntidade == "TAS"
	//Busca InternalId da tarefa (PMSI203)
	aPrjTask := IntTrfInt(cOrigem1,cMarca)
	
	If aPrjTask[1]
		aAdd(aIntegra,AllTrim(cOrigem1))	//Origem
		aAdd(aIntegra,AllTrim(aPrjTask[2][2]))//Filial
		aAdd(aIntegra,AllTrim(aPrjTask[2][3]))//Projeto
		aAdd(aIntegra,AllTrim(aPrjTask[2][4]))//Revisão			
		aAdd(aIntegra,AllTrim(aPrjTask[2][5]))//Tarefa
	Else
		aIntegra := {AllTrim(cOrigem1),"","","",""} //Origem
	Endif          
Endif

SUPRESERRHDL()

Return (aIntegra)

/*
{Protheus.doc} SUPVLDPRJ
@Uso    Verifica as mensagens recebidas de acordo com a integração EAI para montagem de DE/PARA
@param  aTarIn - Array de Tarefa Inicial ; aTarFi - Array de Tarefa Final ; 
@return	.T. - Informação validada ; .F. Informação não validada

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPVLDPRJ(aTarIn,aTarFi)

Local lPost := .T.

If Empty(aTarIn[nPosTaf]) .Or. Empty(aTarIn[nPosPro])
	SetRestFault(400,  STR0006 + Alltrim(aTarIn[nPosOri]) + STR0007)
	lPost := .F.
EndIf

If lPost .And. ((Empty(aTarFi[nPosTaf]) .Or. Empty(aTarFi[nPosPro])))
	SetRestFault(400,  STR0008 + Alltrim(aTarFi[nPosOri]) + STR0007)
	lPost := .F.
EndIf

Return lPost

/*
{Protheus.doc} SUPCTBOPEN
@Uso    Retorna a menor data do periodo contabil que esta aberto
@param  Nenhum
@return	Data do periodo contabil

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPCTBOPEN()

Local cQry			:= ""
Local cDataCon	:= ""

SUPSETERRHDL(STR0016)

DBSelectArea("CTG")
CTG->(DBSetOrder(1))

If Select("TCTB") > 0
	TCTB->(DbCloseArea())
Endif

cQry := "	SELECT	COALESCE(MIN(CTG.CTG_DTINI),'18000101') INI_DATA"
cQry += " 	FROM	"+RetSqlName("CTG") + " CTG"
cQry += " 	WHERE 	CTG.D_E_L_E_T_ <> '*'"
cQry += " 	AND 	CTG.CTG_FILIAL = '"+xFilial("CTG") +"'"
cQry += " 	AND 	CTG.CTG_STATUS = '1'"
cQry += " 	AND 	CTG.CTG_EXERC >='" + Alltrim(Str(Year(dDatabase))) + "'"

cQry := ChangeQuery(cQry)
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TCTB", .T., .T. )

DbSelectArea("TCTB")

If !TCTB->(EOF())
	cDataCon := SubStr(TCTB->INI_DATA,1,4)+'-'+SubStr(TCTB->INI_DATA,5,2)+'-'+SubStr(TCTB->INI_DATA,7,2) 
EndIf

TCTB->(DbCloseArea())

SUPRESERRHDL()
	
Return cDataCon

/*
{Protheus.doc} SUPREADSQL
@Uso    Prepara o arquivo de trabalho montado na query 
@param  Projeto, Filial, Tarefa Inicial, Revisao, Tarefa Final
@return	Nenhum

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPREADSQL(cCompany, cBranch, cCodProj,cCodRev,cCodITsk,cCodFTsk,dIDate,dFDate,aTpMov,nPages,nPSize,cBanco,cQry,cCurrencySimbol, bRetDelAndPaid, ideliveryType)

Local nXi		:= 0
Local nPosCPG := 0
Local nPosNFE := 0
Local nPosDEV := 0
Local nPosREQ := 0
Local sCamposRetDed := " 0 VRDEDUCAO, 0 VRRETENCAO "
Local cCampoNota := "D1_EMISSAO"
Local cCampoDevolucao := "D2_EMISSAO"
Local cCampoPagto := "E2_EMISSAO"
Local aParam        := {}
Local cBranchId := cBranch

SUPSETERRHDL(STR0017)

DBSelectArea("AFR")
AFR->(DBSetOrder(1))

DBSelectArea("SE2")
SE2->(DBSetOrder(1))

DBSelectArea("SE5")
SE5->(DBSetOrder(1))

DBSelectArea("AFN")
AFN->(DBSetOrder(1))

DBSelectArea("AFR")
AFR->(DBSetOrder(1))

DBSelectArea("SD1")
SD1->(DBSetOrder(1))

If SD1->(FieldPos("D1_RETENCA")) > 0 .AND. SD1->(FieldPos("D1_DEDUCAO")) > 0
		sCamposRetDed := " SD1.D1_RETENCA VRDEDUCAO, SD1.D1_DEDUCAO VRRETENCAO "
end if
	
DBSelectArea("SD2")
SD2->(DBSetOrder(1))

DBSelectArea("SC7")
SC7->(DBSetOrder(1))

DBSelectArea("SC1")
SC1->(DBSetOrder(1))

DBSelectArea("AFH")
AFH->(DBSetOrder(1))

DBSelectArea("AFR")
AFR->(DBSetOrder(1))

DBSelectArea("SCP")
SCP->(DBSetOrder(1))  

DBSelectArea("SD3")
SD3->(DBSetOrder(1))

For nXi := 1 To Len (aTpMov)
	If !Empty(aTpMov[nXi][2])  
		If aTpMov[nXi][1] == "CPG" 
			nPosCPG := nXi	
		ElseIf	aTpMov[nXi][1] == "NFE"  
			nPosNFE := nXi
		ElseIf	aTpMov[nXi][1] == "EST"  
			nPosREQ := nXi
		ElseIf aTpMov[nXi][1] == "DEV" 
			nPosDEV := nXi
		EndIf
	EndIf
Next nXi


If Select("DAD") > 0
	DAD->(DbCloseArea())
Endif

cQry =  " SELECT * " + TAB
cQry +=  " FROM " + TAB
cQry +=  " ( " + TAB  

If cBanco == "ORACLE"
	cQry +=  " SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  " + TAB
Else
	cQry +=  " 		SELECT ROW_NUMBER() OVER( ORDER BY PROJETO, REVISAO, TAREFA, FILIAL, ENTIDADE,DTMOV ) ITEMNUMBER, " + TAB 
	cQry +=  " 				COUNT(1) OVER() AS TOTALNUMBER, * " + TAB
EndIf

cQry +=  " 	FROM " + TAB  
cQry +=  "  	( " + TAB  
cQry +=  "		SELECT	'' ENTIDADE, '' FILIAL , '' PROJETO   ," + TAB 
cQry +=  " 				'' REVISAO , '' TAREFA , '' PRODUTO   ," + TAB
cQry +=  "	 	  		'' UNIDADE , 0  RECNO  , '' DOCUMENTO ," + TAB
cQry +=  "				'' ITEM    , '' DTMOV  , 0  QUANTIDADE," + TAB
cQry +=  "		   		0 UNITARIO ,0 TOTAL_QUANT, '' FIL, '' PED, '' ITEMPED, " + TAB
cQry +=  "              '' C1_FILIAL,  '' C1_NUM,  '' C1_ITEM, '' CP_FILIAL,  '' CP_NUM,  '' CP_ITEM, '' CP_EMISSAO,"+ TAB
cQry +=  "              '' TIPOPED, 0  TOTAL  , '' FORNECEDOR," + TAB
cQry +=  "				'' LOJA    , 0  MOEDA  , 0  FRETE     ," + TAB
cQry +=  "  			0 SEGURO   , 0  DESPESA, 0  DEVOL	  , " + TAB
cQry +=  "  			0 DESCONTO , 0  VALIPI, 0  VALIMP1,0 TOTAL_FRETE,0 TOTAL_SEGURO,0 TOTAL_DESPESA,0 TOTAL_DESCONTO,0 TOTAL_VALIPI,0 TOTAL_VALIMP1,  0 VRDEDUCAO, 0 VRRETENCAO, 0 TAXAMOEDA2, 0 TAXAMOEDA3, 0 TAXAMOEDA4, 0 TAXAMOEDA5 " + TAB

If cBanco == "ORACLE"
	cQry +=  " FROM DUAL " + TAB  
Else
	cQry +=  " FROM "+RetSqlName("CTO") + TAB
	cQry +=  " WHERE 1 = 0 " + TAB
EndIf

//FINANCEIRO - CPG																			
If nPosCPG > 0

	cQry +=  " UNION ALL " + TAB
	
	cQry +=  " SELECT 'CPG' ENTIDADE         , AFR.AFR_FILIAL FILIAL			, AFR.AFR_PROJET PROJETO, " + TAB 
	cQry +=  " 		  AFR.AFR_REVISA REVISAO , AFR.AFR_TAREFA TAREFA			, '' PRODUTO            , " + TAB
	cQry +=  "        '' UNIDADE             , SE2.R_E_C_N_O_ RECNO 			, E2_NUM DOCUMENTO      , " + TAB
	cQry +=  "        E2_PARCELA ITEM        , SE2."+aTpMov[nPosCPG][2]+ " DTMOV, 1 QUANTIDADE          , " + TAB
	cQry +=  "        AFR.AFR_VALOR1 UNITARIO, 0 TOTAL_QUANT, '' FIL, '' PED, '' ITEMPED, "+ TAB
	cQry +=  "  '' C1_FILIAL,  '' C1_NUM,  '' C1_ITEM, '' CP_FILIAL,  '' CP_NUM,  '' CP_ITEM, '' CP_EMISSAO,"+ TAB
	cQry +=  " '' TIPOPED, AFR.AFR_VALOR1 TOTAL 			, E2_FORNECE FORNECEDOR , " + TAB
	cQry +=  " 		  E2_LOJA LOJA           , E2_MOEDA MOEDA       			, 0 FRETE               , " + TAB
	cQry +=  "        0 SEGURO               , " + TAB
	cQry +=  "        SE2.E2_ACRESC * ( AFR.AFR_VALOR1 / NULLIF(SE2.E2_VLCRUZ,0) )  DESPESA,						  " + TAB
	cQry +=  "	   	  0 DEVOL                , 															  " + TAB
	cQry +=  "        SE2.E2_DECRESC * ( AFR.AFR_VALOR1 / NULLIF(SE2.E2_VLCRUZ,0) ) DESCONTO,					      " + TAB
	cQry +=  "        0 VALIPI,0 VALIMP1, 0 TOTAL_FRETE,0 TOTAL_SEGURO,0 TOTAL_DESPESA,0 TOTAL_DESCONTO,0 TOTAL_VALIPI,0 TOTAL_VALIMP1, 0 VRDEDUCAO, 0 VRRETENCAO, 0 TAXAMOEDA2, 0 TAXAMOEDA3, 0 TAXAMOEDA4, 0 TAXAMOEDA5  " + TAB
	cQry +=  " FROM	"+RetSqlName("AFR") + " AFR , " 
	cQry +=    RetSqlName("SE2") + " SE2	" + TAB		
	cQry +=  " WHERE AFR.AFR_FILIAL = '"+xFilial("AFR")+"'" + TAB
	cQry +=  " AND	 AFR.AFR_PROJET = '"+cCodProj+"'"  + TAB
	cQry +=  " AND	 AFR.AFR_TAREFA >= '"+cCodITsk+"'" + TAB
	cQry +=  " AND	 AFR.AFR_TAREFA <= '"+cCodFTsk+"'" + TAB
	cQry +=  " AND	 AFR.AFR_REVISA = '"+cCodRev+"'"   + TAB
	
	If (! Empty (dIDate) )
		cQry +=  " AND	 SE2."+aTpMov[nPosCPG][2] + " >= '" +DtoS(dIDate) + "'" + TAB
	EndIf
	
	If (! Empty (dFDate) )
		cQry +=  " AND	 SE2."+aTpMov[nPosCPG][2] + " < '" +DtoS(dFDate) + "'" + TAB
	EndIf 	 
	
	cQry +=  " AND	 AFR.AFR_FILIAL = SE2.E2_FILIAL  "  + TAB
	cQry +=  " AND	 AFR.AFR_PREFIX = SE2.E2_PREFIXO "  + TAB
	cQry +=  " AND	 AFR.AFR_NUM	= SE2.E2_NUM 	 "  + TAB
	cQry +=  " AND	 AFR.AFR_PARCEL = SE2.E2_PARCELA "  + TAB
	cQry +=  " AND	 AFR.AFR_TIPO   = SE2.E2_TIPO    "  + TAB
	cQry +=  " AND	 AFR.AFR_FORNEC = SE2.E2_FORNECE "  + TAB
	cQry +=  " AND	 AFR.AFR_LOJA   = SE2.E2_LOJA    "  + TAB
	cQry +=  " AND	 SE2.E2_ORIGEM  = 'FINA050'      "  + TAB
	cQry +=  " AND	 AFR.D_E_L_E_T_ <> '*' 			 "  + TAB
	cQry +=  " AND	 SE2.D_E_L_E_T_ <> '*' 			 "  + TAB

EndIf

//NOTA FISCAL DE ENTRADA - NFE
If nPosNFE > 0	
	
	cQry +=  " UNION ALL " + TAB

	
			cQry +=  " SELECT 'NFE' ENTIDADE           , AFN.AFN_FILIAL  FILIAL			, AFN.AFN_PROJET PROJETO  , "   + TAB 
			cQry +=  " 		  AFN.AFN_REVISA REVISAO   , AFN.AFN_TAREFA TAREFA			, SD1.D1_COD PRODUTO      , "   + TAB
			cQry +=  "        SD1.D1_UM UNIDADE        , SD1.R_E_C_N_O_ RECNO 			, SD1.D1_DOC DOCUMENTO    , "   + TAB
			cQry +=  "        SD1.D1_ITEM ITEM         , SD1."+aTpMov[nPosNFE][2]+ " DTMOV, AFN.AFN_QUANT QUANTIDADE, " + TAB
			cQry +=  "        (SD1.D1_VUNIT) UNITARIO, " + TAB	
			cQry +=  "        SD1.D1_QUANT TOTAL_QUANT," + TAB	
			cQry +=  "        SD1.D1_FILIAL,  " + TAB	
			cQry +=  "        SD1.D1_PEDIDO, " + TAB	 
			cQry +=  "        SD1.D1_ITEMPC, " + TAB	

			cQry +=  "        '' C1_FILIAL,  " + TAB	
			cQry +=  "        '' C1_NUM,  " + TAB	
			cQry +=  "        '' C1_ITEM, " + TAB	
			cQry +=  "        '' CP_FILIAL, " + TAB	 
			cQry +=  "        '' CP_NUM,  " + TAB	
			cQry +=  "        '' CP_ITEM, '' CP_EMISSAO," + TAB	

			cQry +=  "        '' TIPOPED, " + TAB	
			cQry +=  "        (AFN.AFN_QUANT * SD1.D1_VUNIT)  TOTAL, " + TAB
			cQry +=  " 	 	  SD1.D1_FORNECE FORNECEDOR, SD1.D1_LOJA LOJA               , SF1.F1_MOEDA MOEDA      , " + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALFRE,0) ) FRETE                               ,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_SEGURO,0) ) SEGURO                              ,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_DESPESA,0)) DESPESA                              , " + TAB 
			cQry +=  " 		  0 DEVOL 					  ,	" + TAB
			cQry +=  " 		  (SD1.D1_VALDESC * ( AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT,0)))  DESCONTO  					  ,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALIPI,0)) VALIPI,   
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALIMP1,0)) VALIMP1,                                 " + TAB
			cQry +=  " 		  SD1.D1_VALFRE  TOTAL_FRETE                               ,	" + TAB
			cQry +=  " 		  SD1.D1_SEGURO  TOTAL_SEGURO                              ,	" + TAB
			cQry +=  " 		  SD1.D1_DESPESA TOTAL_DESPESA                              , " + TAB 
			cQry +=  " 		  SD1.D1_VALDESC TOTAL_DESCONTO  					  ,	" + TAB
			cQry +=  " 		  SD1.D1_VALIPI  TOTAL_VALIPI,   
			cQry +=  " 		  SD1.D1_VALIMP1 TOTAL_VALIMP1,                                 " + TAB
			cQry +=  sCamposRetDed + TAB
			cQry +=  " , (D1_CUSTO2 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA2, (D1_CUSTO3 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA3, (D1_CUSTO4 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA4, (D1_CUSTO5 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA5  "
			cQry +=  " FROM	"+ RetSqlName('AFN') + " AFN , "+ RetSqlName('SD1') + " SD1" + TAB 
			cQry +=  " INNER JOIN " + RetSqlName('SF1') + " SF1"  + TAB 
			cQry +=  " 		ON  SF1.F1_FILIAL	= SD1.D1_FILIAL"  + TAB 
			cQry +=  " 		AND SF1.F1_DOC      = SD1.D1_DOC" 	  + TAB 
			cQry +=  " 		AND SF1.F1_SERIE    = SD1.D1_SERIE"   + TAB 
			cQry +=  " 		AND SF1.F1_FORNECE  = SD1.D1_FORNECE" + TAB 
			cQry +=  " 		AND SF1.F1_LOJA		= SD1.D1_LOJA" 	  + TAB 
			cQry +=  " 		AND SF1.D_E_L_E_T_ <> '*'" 			  + TAB	
			cQry +=  " WHERE	AFN.AFN_FILIAL = '"+xFilial("AFN")+"'" + TAB 
			cQry +=  " AND		AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
			cQry +=  " AND		AFN.AFN_TAREFA >= '"+cCodITsk+"'" + TAB
			cQry +=  " AND		AFN.AFN_TAREFA <= '"+cCodFTsk+"'" + TAB
			cQry +=  " AND		AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
			cQry +=  " AND		AFN.AFN_FILIAL = SD1.D1_FILIAL "  + TAB
			cQry +=  " AND		AFN.AFN_DOC    = SD1.D1_DOC "     + TAB
			cQry +=  " AND		AFN.AFN_SERIE  = SD1.D1_SERIE "   + TAB
			cQry +=  " AND		AFN.AFN_ITEM   = SD1.D1_ITEM "    + TAB
			cQry +=  " AND		AFN.AFN_TIPONF = SD1.D1_TIPO "    + TAB
			cQry +=  " AND		AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB
			cQry +=  " AND		AFN.AFN_LOJA = SD1.D1_LOJA "      + TAB
			cQry +=  " AND		SD1.D1_TES <> '   ' AND SD1.D_E_L_E_T_ <> '*' "  			  + TAB
			
			If (! Empty (dIDate) )
				cQry +=  " AND	 SD1."+aTpMov[nPosNFE][2] + " >= '" +DtoS(dIDate) + "'" + TAB
			EndIf
			
			If (! Empty (dFDate) )
				cQry +=  " AND	 SD1."+aTpMov[nPosNFE][2] + " < '" +DtoS(dFDate) + "'" + TAB
			EndIf 	 
			
			cQry +=  " AND		SD1.D1_TIPO = 'N' "  			  + TAB
			cQry +=  " AND		SD1.D1_ITEMREM = '   ' "  			  + TAB
			cQry +=  " AND		SD1.D1_SERIREM = '   ' "  			  + TAB
			cQry +=  " AND		SD1.D1_REMITO = '   ' "  			  + TAB
			cQry +=  " AND		AFN.D_E_L_E_T_ <> '*' "  		  + TAB
			cQry +=  " AND		SD1.D_E_L_E_T_ <> '*' "  		  + TAB
			cQry +=  "	AND		NOT EXISTS " 						  + TAB  
			cQry +=  "	( "  
			cQry +=  "		SELECT 1									" + TAB 
			cQry +=  "		FROM "+ RetSqlName('SC7') + " SC7 			" + TAB
			cQry +=  "		LEFT JOIN "+ RetSqlName('SC1') + " SC1 ON 	" + TAB
			cQry +=  "			SC1.C1_FILIAL  = SC7.C7_FILIAL      	" + TAB
			cQry +=  "			AND		SC1.C1_NUM     = SC7.C7_NUMSC 	" + TAB
			cQry +=  "			AND		SC1.C1_ITEM	   = SC7.C7_ITEMSC  " + TAB
			cQry +=  "			AND		SC1.C1_PRODUTO = SC7.C7_PRODUTO " + TAB
			cQry +=  "			AND		SC1.C1_PEDIDO  = SC7.C7_NUM     " + TAB
			cQry +=  "			AND		SC1.C1_ITEMPED = SC7.C7_ITEM    " + TAB
			cQry +=  "			AND		SC1.D_E_L_E_T_ <> '*'        	" + TAB
			cQry +=  "		WHERE	                                    " + TAB
			cQry +=  "			SD1.D1_FILIAL  = SC7.C7_FILIAL          " + TAB
			cQry +=  "			AND		SD1.D1_PEDIDO  = SC7.C7_NUM     " + TAB
			cQry +=  "			AND		SD1.D1_ITEMPC  = SC7.C7_ITEM    " + TAB
			cQry +=  "			AND		SD1.D1_FORNECE = SC7.C7_FORNECE " + TAB
			cQry +=  "			AND		SD1.D1_LOJA	   = SC7.C7_LOJA	" + TAB
			
			cQry +=  " AND ( " + TAB
			cQry +=  " SC7.C7_APROPRM IN ('2','3') " + TAB //Pedidos marcados para apropriar na Medição ou para não apropriar
			cQry +=  " OR SC1.C1_ORIGEM ='MATA106'" + TAB  //Solicitações de compra originadas de Requisições de Armazém
			
			cQry +=  "		)	AND		SC7.D_E_L_E_T_ <> '*'	" + TAB
			cQry +=  "	)	" + TAB 
	
EndIf
if nPosDEV > 0

	cQry +=  " UNION ALL " + TAB
	
	cQry +=  " SELECT 'DEV' ENTIDADE           , AFN.AFN_FILIAL  FILIAL			, AFN.AFN_PROJET PROJETO  , "   + TAB 
	cQry +=  " 		  AFN.AFN_REVISA REVISAO   , AFN.AFN_TAREFA TAREFA			, SD2.D2_COD PRODUTO      , "   + TAB
	cQry +=  "        SD2.D2_UM UNIDADE        , SD2.R_E_C_N_O_ RECNO 			, SD2.D2_DOC DOCUMENTO    , SD2.D2_ITEM ITEM         ,"   + TAB
    cQry +=  "        COALESCE(NULLIF(SD2."+aTpMov[nPosDEV][2]+ ",''), SD2.D2_EMISSAO) DTMOV, " + TAB
	cQry +=  "        ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT) QUANTIDADE, " + TAB
	cQry +=  "        (SD2.D2_PRCVEN) UNITARIO, 0 TOTAL_QUANT, '' FIL, '' PED, '' ITEMPED, "+ TAB
    cQry +=  "        '' C1_FILIAL,  '' C1_NUM,  '' C1_ITEM, '' CP_FILIAL,  '' CP_NUM,  '' CP_ITEM, '' CP_EMISSAO,"+ TAB
    cQry +=  "        '' TIPOPED,  " + TAB	
	cQry +=  "        -1 * ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT * SD2.D2_PRCVEN)  TOTAL, " + TAB
	cQry +=  " 	 	  SD2.D2_CLIENTE FORNECEDOR, SD2.D2_LOJA LOJA               , SF2.F2_MOEDA MOEDA      , " + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_VALFRE,0) ) FRETE                               ,	" + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_SEGURO,0) ) SEGURO                              ,	" + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_DESPESA,0)) DESPESA                              , " + TAB 
	cQry +=  " 		  0 DEVOL 					  ,	" + TAB
	cQry +=  " 		  (SD2.D2_DESC * ( (SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT,0)))  DESCONTO  					  ,	" + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_VALIPI,0)) VALIPI," + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_VALIMP1,0)) VALIMP1,0 TOTAL_FRETE,0 TOTAL_SEGURO,0 TOTAL_DESPESA,0 TOTAL_DESCONTO,0 TOTAL_VALIPI,0 TOTAL_VALIMP1, 0 VRDEDUCAO, 0 VRRETENCAO  " + TAB                              
	cQry +=  " , (D2_CUSTO2 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA2, (D2_CUSTO3 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA3, (D2_CUSTO4 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA4, (D2_CUSTO5 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA5  " + TAB
	cQry +=  " FROM	" + RetSqlName('SD2') + " SD2" + TAB 
	cQry +=  " INNER JOIN "+ RetSqlName('SD1') + " SD1 "  + TAB
	cQry +=  "		ON  SD2.D2_FILIAL	= SD1.D1_FILIAL " + TAB
	cQry +=  "		AND SD2.D2_NFORI    = SD1.D1_DOC "    + TAB
	cQry +=  "		AND SD2.D2_SERIORI  = SD1.D1_SERIE "  + TAB
	cQry +=  "		AND SD2.D2_ITEMORI  = SD1.D1_ITEM "   + TAB
	cQry +=  "		AND SD2.D2_CLIENTE  = SD1.D1_FORNECE "+ TAB
	cQry +=  "		AND SD2.D2_LOJA		= SD1.D1_LOJA "   + TAB
	cQry +=  "		AND SD2.D_E_L_E_T_ <> '*' "  		  + TAB
	cQry +=  " INNER JOIN " +RetSqlName('AFN') + " AFN ON "
	cQry +=  " AFN.AFN_FILIAL = '"+xFilial("AFN")+"'" + TAB 
	cQry +=  " AND		AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
	cQry +=  " AND		AFN.AFN_TAREFA >= '"+cCodITsk+"'" + TAB
	cQry +=  " AND		AFN.AFN_TAREFA <= '"+cCodFTsk+"'" + TAB
	cQry +=  " AND		AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
	cQry +=  " AND		AFN.AFN_FILIAL = SD1.D1_FILIAL "  + TAB
	cQry +=  " AND		AFN.AFN_DOC    = SD1.D1_DOC "     + TAB
	cQry +=  " AND		AFN.AFN_SERIE  = SD1.D1_SERIE "   + TAB
	cQry +=  " AND		AFN.AFN_ITEM   = SD1.D1_ITEM "    + TAB
	cQry +=  " AND		AFN.AFN_TIPONF = SD1.D1_TIPO "    + TAB
	cQry +=  " AND		AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB
	cQry +=  " AND		AFN.AFN_LOJA = SD1.D1_LOJA "      + TAB
	cQry +=  " AND		SD1.D1_TES <> '   ' AND AFN.D_E_L_E_T_ <> '*' "  			  + TAB
	cQry +=  " INNER JOIN " + RetSqlName('SF2') + " SF2"  + TAB 
	cQry +=  " 		ON  SF2.F2_FILIAL	= SD2.D2_FILIAL"  + TAB 
	cQry +=  " 		AND SF2.F2_DOC      = SD2.D2_DOC" 	  + TAB 
	cQry +=  " 		AND SF2.F2_SERIE    = SD2.D2_SERIE"   + TAB 
	cQry +=  " 		AND SF2.F2_CLIENTE  = SD2.D2_CLIENTE" + TAB 
	cQry +=  " 		AND SF2.F2_LOJA		= SD2.D2_LOJA" 	  + TAB 
	cQry +=  " 		AND SF2.D_E_L_E_T_ <> '*'" 			  + TAB	
	cQry +=  " WHERE	
	
	cQry +=  " SD2.D2_TES <> '   ' "  			  + TAB
	
	If (! Empty (dIDate) )
		cQry +=  " AND	 SD2."+aTpMov[nPosDEV][2] + " >= '" +DtoS(dIDate) + "'" + TAB
	EndIf
	
	If (! Empty (dFDate) )
		cQry +=  " AND	 SD2."+aTpMov[nPosDEV][2] + " < '" +DtoS(dFDate) + "'" + TAB
	EndIf 	 
	
	
	cQry +=  " AND		SD2.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "  		  + TAB
	
EndIf

//REQUISIÇÃO AO ARMAZEM - REQ
If nPosREQ > 0

	cQry +=  "	UNION ALL " + TAB

	cQry +=  " SELECT 'REQ' ENTIDADE           , AFH.AFH_FILIAL FILIAL			  , AFH.AFH_PROJET PROJETO , " + TAB 
	cQry +=  " 		  AFH.AFH_REVISA REVISAO   , AFH.AFH_TAREFA TAREFA			  , SD3.D3_COD PRODUTO     , " + TAB
	cQry +=  "        SD3.D3_UM UNIDADE        , SD3.R_E_C_N_O_ RECNO  			  , SD3.D3_NUMSEQ DOCUMENTO, " + TAB
	cQry +=  "        CONCAT('00',SD3.D3_ITEMSA)  ITEM , SD3."+aTpMov[nPosREQ][2]+ " DTMOV, ((AFH.AFH_QUANT / NULLIF(SCP.CP_QUANT,0)) * SD3.D3_QUANT) QUANTIDADE, " + TAB
	cQry +=  "        (SD3.D3_CUSTO1 / NULLIF(SD3.D3_QUANT,0)) UNITARIO, 0 TOTAL_QUANT, '' FIL, '' PED, '' ITEMPED, "+ TAB
    cQry +=  "        '' C1_FILIAL,  '' C1_NUM,  '' C1_ITEM, '' CP_FILIAL,  '' CP_NUM,  '' CP_ITEM,  '' CP_EMISSAO, "+ TAB
	cQry +=  "        '' TIPOPED, (((AFH.AFH_QUANT / NULLIF(SCP.CP_QUANT,0)) * SD3.D3_QUANT) * (SD3.D3_CUSTO1 / NULLIF(SD3.D3_QUANT,0))) TOTAL  , '' FORNECEDOR, " + TAB
	cQry +=  " 		  '' LOJA                  , 1 MOEDA       			      , 0 FRETE                , " + TAB
	cQry +=  "        0 SEGURO                 , 0 DESPESA            			  , 0 DEVOL                , " + TAB
	cQry +=  "        0 DESCONTO			   , 0 VALIPI, 0 VALIMP1,0 TOTAL_FRETE,0 TOTAL_SEGURO,0 TOTAL_DESPESA,0 TOTAL_DESCONTO,0 TOTAL_VALIPI,0 TOTAL_VALIMP1,  0 VRDEDUCAO, 0 VRRETENCAO 													" + TAB
			 
	cQry +=  " , (D3_CUSTO2 / COALESCE(NULLIF(D3_CUSTO1,0),1)) TAXAMOEDA2, (D3_CUSTO3 / COALESCE(NULLIF(D3_CUSTO1,0),1)) TAXAMOEDA3, (D3_CUSTO4 / COALESCE(NULLIF(D3_CUSTO1,0),1)) TAXAMOEDA4, (D3_CUSTO5 / COALESCE(NULLIF(D3_CUSTO1,0),1)) TAXAMOEDA5  " + TAB
	cQry +=  "	FROM	"+ RetSqlName('SD3') + " SD3 " +  TAB
	
	cQry +=  "  LEFT JOIN 	"+ RetSqlName('SCP') + "  SCP " + TAB 
	cQry +=  "   ON SD3.D3_FILIAL = SCP.CP_FILIAL " + TAB 
    cQry +=  "    AND SD3.D3_NUMSA = SCP.CP_NUM AND SD3.D3_ITEMSA = SCP.CP_ITEM " + TAB 
    cQry +=  "    AND SCP.D_E_L_E_T_ <> '*' " + TAB 
	cQry +=  "  JOIN  	"+ RetSqlName('AFH') + " AFH ON AFH.D_E_L_E_T_ <> '*' " + TAB
    cQry +=  "  AND ( SD3.D3_ESTORNO <> 'S' AND SD3.D3_NUMSA <> '   ' AND  " + TAB
	cQry +=  "  AFH.AFH_FILIAL = SCP.CP_FILIAL AND AFH.AFH_NUMSA = SCP.CP_NUM " + TAB
    cQry +=  "  AND AFH.AFH_ITEMSA = SCP.CP_ITEM AND AFH.AFH_COD = SCP.CP_PRODUTO) " + TAB

	cQry +=  "	WHERE AFH.AFH_FILIAL = '"+xFilial("AFH")+"'" + TAB 
	cQry +=  "	AND	  AFH.AFH_PROJET = '"+cCodProj+"'"  + TAB
	cQry +=  "	AND	  AFH.AFH_TAREFA >= '"+cCodITsk+"'" + TAB
	cQry +=  "	AND	  AFH.AFH_TAREFA <= '"+cCodFTsk+"'" + TAB
	cQry +=  "	AND	  AFH.AFH_REVISA = '"+cCodRev+"'"   + TAB

	If (! Empty (dIDate) )
		cQry +=  " AND	 SD3."+aTpMov[nPosREQ][2] + " >= '" +DtoS(dIDate) + "'" + TAB
	EndIf
	
	If (! Empty (dFDate) )
		cQry +=  " AND	 SD3."+aTpMov[nPosREQ][2] + " < '" +DtoS(dFDate) + "'" + TAB
	EndIf 	 
	
	cQry +=  "	AND	  SD3.D_E_L_E_T_ <> '*'           " + TAB

EndIf


// Informações de entrega/devolução e pagamento
If (bRetDelAndPaid)

  If (nPosNFE > 0)
     cCampoNota = aTpMov[nPosNFE][2]
  EndIf	 

  If (nPosCPG > 0)
     cCampoPagto = aTpMov[nPosCPG][2]
  EndIf	

  If (nPosDEV> 0)
     cCampoDevolucao = aTpMov[nPosDEV][2]
  EndIf	
  

  if (ideliveryType == 0) 
     // Entrega na Pré-Nota (Considera todos os registros - Inclusive com TES preenchida, pois a pre-nota vira nota)
     cQry +=  " UNION ALL " + TAB
			cQry +=  " SELECT 'ENT_PRE' ENTIDADE       , '"+cBranchId+"'  FILIAL			, AFN.AFN_PROJET PROJETO  , "   + TAB
			cQry +=  " 		  AFN.AFN_REVISA REVISAO   , AFN.AFN_TAREFA TAREFA			, SD1.D1_COD PRODUTO      , "   + TAB
			cQry +=  "        SD1.D1_UM UNIDADE        , SD1.R_E_C_N_O_ RECNO 			, SD1.D1_DOC DOCUMENTO    , "   + TAB
			cQry +=  "        SD1.D1_ITEM ITEM         , SD1."+cCampoNota+ " DTMOV, AFN.AFN_QUANT QUANTIDADE, " + TAB
			cQry +=  "        (SD1.D1_VUNIT) UNITARIO, " + TAB
			cQry +=  "        SD1.D1_QUANT TOTAL_QUANT," + TAB
			cQry +=  "        SD1.D1_FILIAL, SD1.D1_PEDIDO, SD1.D1_ITEMPC, " + TAB
			cQry +=  "        SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_ITEM, " + TAB
			cQry +=  "        SCP.CP_FILIAL, SCP.CP_NUM, SCP.CP_ITEM, SCP.CP_EMISSAO, " + TAB
			cQry +=  "        '' TIPOPED, " + TAB
			cQry +=  "        (AFN.AFN_QUANT * SD1.D1_VUNIT)  TOTAL, " + TAB
			cQry +=  " 	 	  SD1.D1_FORNECE FORNECEDOR, SD1.D1_LOJA LOJA  , SF1.F1_MOEDA MOEDA , " + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALFRE,0)  ) FRETE,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_SEGURO,0)  ) SEGURO,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_DESPESA,0) ) DESPESA, 0 DEVOL,	" + TAB
			cQry +=  " 		  (SD1.D1_VALDESC * ( AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT,0)))  DESCONTO,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALIPI,0) ) VALIPI, " + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALIMP1,0) ) VALIMP1," + TAB
			cQry +=  " 		  SD1.D1_VALFRE  TOTAL_FRETE,	" + TAB
			cQry +=  " 		  SD1.D1_SEGURO  TOTAL_SEGURO,	" + TAB
			cQry +=  " 		  SD1.D1_DESPESA TOTAL_DESPESA, " + TAB
			cQry +=  " 		  SD1.D1_VALDESC TOTAL_DESCONTO,	" + TAB
			cQry +=  " 		  SD1.D1_VALIPI  TOTAL_VALIPI, " + TAB
			cQry +=  " 		  SD1.D1_VALIMP1 TOTAL_VALIMP1, " + TAB
			cQry +=  sCamposRetDed + TAB
			cQry +=  " , (D1_CUSTO2 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA2," + TAB
			cQry +=  " (D1_CUSTO3 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA3," + TAB
			cQry +=  " (D1_CUSTO4 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA4," + TAB
			cQry +=  " (D1_CUSTO5 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA5  " + TAB
			cQry +=  " FROM	"+ RetSqlName('AFN') + " AFN , "+ RetSqlName('SD1') + " SD1" + TAB
			cQry +=  " INNER JOIN " + RetSqlName('SF1') + " SF1"  + TAB
			cQry +=  " 		ON  SF1.F1_FILIAL	= SD1.D1_FILIAL"  + TAB
			cQry +=  " 		AND SF1.F1_DOC      = SD1.D1_DOC" 	  + TAB
			cQry +=  " 		AND SF1.F1_SERIE    = SD1.D1_SERIE"   + TAB
			cQry +=  " 		AND SF1.F1_FORNECE  = SD1.D1_FORNECE" + TAB
			cQry +=  " 		AND SF1.F1_LOJA		= SD1.D1_LOJA" 	  + TAB
			cQry +=  " 		AND SF1.D_E_L_E_T_ <> '*'" 			  + TAB

			cQry +=  " 		JOIN " + RetSqlName('SC7') + " SC7 " + TAB
    		cQry +=  " 		LEFT JOIN " + RetSqlName('SC1') + " SC1 " + TAB
			cQry +=  " 			      LEFT JOIN " + RetSqlName('SCP') + " SCP" + TAB
			cQry +=  " 				    ON SCP.CP_FILIAL = SC1.C1_FILIAL" + TAB
			cQry +=  "  				AND SCP.CP_NUMSC = SC1.C1_NUM" 			  + TAB
			cQry +=  " 					AND SCP.CP_ITSC = SC1.C1_ITEM" 			  + TAB
			cQry +=  " 					AND SCP.D_E_L_E_T_ <> '*' " 			  + TAB
			cQry +=  " 				ON  SC1.C1_NUM = SC7.C7_NUMSC"			  + TAB
			cQry +=  " 				AND SC1.C1_FILIAL = SC7.C7_FILIAL " 			  + TAB
			cQry +=  " 				AND SC1.C1_ITEM = SC7.C7_ITEMSC " 			  + TAB
			cQry +=  " 				AND SC1.C1_PRODUTO = SC7.C7_PRODUTO" 			  + TAB
			cQry +=  " 				AND SC1.C1_PEDIDO = SC7.C7_NUM " 			  + TAB
			cQry +=  " 				AND SC1.C1_ITEMPED = SC7.C7_ITEM " 			  + TAB	
			cQry +=  " 				AND SC1.D_E_L_E_T_ <> '*' " 			  + TAB
			cQry +=  " 		    ON  SD1.D1_FILIAL = SC7.C7_FILIAL " 			  + TAB
			cQry +=  " 		   AND SD1.D1_PEDIDO = SC7.C7_NUM " 			  + TAB
			cQry +=  " 		   AND SD1.D1_ITEMPC = SC7.C7_ITEM" 			  + TAB	
			cQry +=  " 		   AND SD1.D1_FORNECE = SC7.C7_FORNECE" 			  + TAB
			cQry +=  " 		   AND SD1.D1_LOJA = SC7.C7_LOJA" 			  + TAB
			cQry +=  " 		   AND SD1.D1_COD = SC7.C7_PRODUTO" 			  + TAB

			cQry +=  " WHERE	" + TAB
			cQry +=  " 		AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
			cQry +=  " AND		AFN.AFN_TAREFA >= '"+cCodITsk+"'" + TAB
			cQry +=  " AND		AFN.AFN_TAREFA <= '"+cCodFTsk+"'" + TAB
			cQry +=  " AND		AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
			cQry +=  " AND		AFN.AFN_FILIAL = SD1.D1_FILIAL "  + TAB
			cQry +=  " AND		AFN.AFN_DOC    = SD1.D1_DOC "     + TAB
			cQry +=  " AND		AFN.AFN_SERIE  = SD1.D1_SERIE "   + TAB
			cQry +=  " AND		AFN.AFN_ITEM   = SD1.D1_ITEM "    + TAB
			cQry +=  " AND		AFN.AFN_TIPONF = SD1.D1_TIPO "    + TAB
			cQry +=  " AND		AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB
			cQry +=  " AND		AFN.AFN_LOJA = SD1.D1_LOJA "      + TAB
			cQry +=  " AND      SD1.D_E_L_E_T_ <> '*' "  		  + TAB
			
			If (! Empty (dIDate) )
				cQry +=  " AND	 SD1."+cCampoNota + " >= '" +DtoS(dIDate) + "'" + TAB
			EndIf
			
			If (! Empty (dFDate) )
				cQry +=  " AND	 SD1."+cCampoNota + " < '" +DtoS(dFDate) + "'" + TAB
			EndIf
			
			cQry +=  " AND		SD1.D1_TIPO = 'N' "  			  + TAB
			cQry +=  " AND		SD1.D1_ITEMREM = '   ' "  			  + TAB
			cQry +=  " AND		SD1.D1_SERIREM = '   '  AND	SD1.D1_REMITO = '   ' AND	AFN.D_E_L_E_T_ <> '*' "  + TAB
			cQry +=  " AND		SD1.D_E_L_E_T_ <> '*' " + TAB

			
  else 
    // Entrega na Nota Fiscal (Considera registros com TES preenchida)
  	cQry +=  " UNION ALL " + TAB
			cQry +=  " SELECT 'ENT_NFE' ENTIDADE           , '"+cBranchId+"'  FILIAL			, AFN.AFN_PROJET PROJETO  , "   + TAB 
			cQry +=  " 		  AFN.AFN_REVISA REVISAO   , AFN.AFN_TAREFA TAREFA			, SD1.D1_COD PRODUTO      , "   + TAB
			cQry +=  "        SD1.D1_UM UNIDADE        , SD1.R_E_C_N_O_ RECNO 			, SD1.D1_DOC DOCUMENTO    , "   + TAB
			cQry +=  "        SD1.D1_ITEM ITEM         , SD1."+cCampoNota+ " DTMOV, AFN.AFN_QUANT QUANTIDADE, " + TAB
			cQry +=  "        (SD1.D1_VUNIT) UNITARIO, " + TAB	
			cQry +=  "        SD1.D1_QUANT TOTAL_QUANT," + TAB
			cQry +=  "        SD1.D1_FILIAL, SD1.D1_PEDIDO, SD1.D1_ITEMPC, " + TAB
			cQry +=  "        SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_ITEM, " + TAB
			cQry +=  "        SCP.CP_FILIAL, SCP.CP_NUM, SCP.CP_ITEM,  SCP.CP_EMISSAO," + TAB
			cQry +=  "        '' TIPOPED, " + TAB
			cQry +=  "        (AFN.AFN_QUANT * SD1.D1_VUNIT)  TOTAL, " + TAB
			cQry +=  " 	 	  SD1.D1_FORNECE FORNECEDOR, SD1.D1_LOJA LOJA               , SF1.F1_MOEDA MOEDA      , " + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALFRE,0)) FRETE                               ,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_SEGURO,0 )) SEGURO                              ,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_DESPESA,0)) DESPESA                              , " + TAB 
			cQry +=  " 		  0 DEVOL 					  ,	" + TAB
			cQry +=  " 		  (SD1.D1_VALDESC * ( AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT,0)))  DESCONTO  					  ,	" + TAB
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALIPI,0)) VALIPI,   
			cQry +=  " 		  (AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT * SD1.D1_VALIMP1,0)) VALIMP1,                                 " + TAB
			cQry +=  " 		  SD1.D1_VALFRE  TOTAL_FRETE                               ,	" + TAB
			cQry +=  " 		  SD1.D1_SEGURO  TOTAL_SEGURO                              ,	" + TAB
			cQry +=  " 		  SD1.D1_DESPESA TOTAL_DESPESA                              , " + TAB 
			cQry +=  " 		  SD1.D1_VALDESC TOTAL_DESCONTO  					  ,	" + TAB
			cQry +=  " 		  SD1.D1_VALIPI  TOTAL_VALIPI,   
			cQry +=  " 		  SD1.D1_VALIMP1 TOTAL_VALIMP1,                                 " + TAB
			cQry +=  sCamposRetDed + TAB
			cQry +=  " , (D1_CUSTO2 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA2, (D1_CUSTO3 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA3, (D1_CUSTO4 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA4, (D1_CUSTO5 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA5  "
			cQry +=  " FROM	"+ RetSqlName('AFN') + " AFN , "+ RetSqlName('SD1') + " SD1" + TAB 
			cQry +=  " INNER JOIN " + RetSqlName('SF1') + " SF1"  + TAB 
			cQry +=  " 		ON  SF1.F1_FILIAL	= SD1.D1_FILIAL"  + TAB 
			cQry +=  " 		AND SF1.F1_DOC      = SD1.D1_DOC" 	  + TAB 
			cQry +=  " 		AND SF1.F1_SERIE    = SD1.D1_SERIE"   + TAB 
			cQry +=  " 		AND SF1.F1_FORNECE  = SD1.D1_FORNECE" + TAB 
			cQry +=  " 		AND SF1.F1_LOJA		= SD1.D1_LOJA" 	  + TAB 
			cQry +=  " 		AND SF1.D_E_L_E_T_ <> '*'" 			  + TAB	
			cQry +=  " 		JOIN "+ RetSqlName('SC7')+" SC7 " 			  + TAB	
    		cQry +=  " 		LEFT JOIN "+ RetSqlName('SC1')+" SC1 " 			  + TAB	
			cQry +=  " 			      LEFT JOIN "+ RetSqlName('SCP')+" SCP" 			  + TAB	
			cQry +=  " 					    ON SCP.CP_FILIAL = SC1.C1_FILIAL" 			  + TAB	
			cQry +=  " 					AND SCP.CP_NUMSC = SC1.C1_NUM" 			  + TAB	
			cQry +=  " 					AND SCP.CP_ITSC = SC1.C1_ITEM" 			  + TAB	
			cQry +=  " 					AND SCP.D_E_L_E_T_ <> '*' " 			  + TAB	
			cQry +=  " 				ON SC1.C1_FILIAL = SC7.C7_FILIAL" 			  + TAB	 
			cQry +=  " 				AND SC1.C1_NUM = SC7.C7_NUMSC " 			  + TAB	
			cQry +=  " 				AND SC1.C1_ITEM = SC7.C7_ITEMSC " 			  + TAB	
			cQry +=  " 				AND SC1.C1_PRODUTO = SC7.C7_PRODUTO" 			  + TAB	 
			cQry +=  " 					AND SC1.C1_PEDIDO = SC7.C7_NUM " 			  + TAB	
			cQry +=  " 					AND SC1.C1_ITEMPED = SC7.C7_ITEM " 			  + TAB	
			cQry +=  " 					AND SC1.D_E_L_E_T_ <> '*' " 			  + TAB	
			cQry +=  " 		    ON  SD1.D1_FILIAL = SC7.C7_FILIAL " 			  + TAB	
			cQry +=  " 		   AND SD1.D1_PEDIDO = SC7.C7_NUM " 			  + TAB	
			cQry +=  " 		   AND SD1.D1_ITEMPC = SC7.C7_ITEM" 			  + TAB	
			cQry +=  " 		   AND SD1.D1_FORNECE = SC7.C7_FORNECE" 			  + TAB	
			cQry +=  " 		   AND SD1.D1_LOJA = SC7.C7_LOJA" 			  + TAB	
			cQry +=  " 		   AND SD1.D1_COD = SC7.C7_PRODUTO" 			  + TAB	
			cQry +=  " WHERE	" + TAB 
			cQry +=  " 		AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
			cQry +=  " AND		AFN.AFN_TAREFA >= '"+cCodITsk+"'" + TAB
			cQry +=  " AND		AFN.AFN_TAREFA <= '"+cCodFTsk+"'" + TAB
			cQry +=  " AND		AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
			cQry +=  " AND		AFN.AFN_FILIAL = SD1.D1_FILIAL "  + TAB
			cQry +=  " AND		AFN.AFN_DOC    = SD1.D1_DOC "     + TAB
			cQry +=  " AND		AFN.AFN_SERIE  = SD1.D1_SERIE "   + TAB
			cQry +=  " AND		AFN.AFN_ITEM   = SD1.D1_ITEM "    + TAB
			cQry +=  " AND		AFN.AFN_TIPONF = SD1.D1_TIPO "    + TAB
			cQry +=  " AND		AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB
			cQry +=  " AND		AFN.AFN_LOJA = SD1.D1_LOJA "      + TAB
			cQry +=  " AND		SD1.D1_TES <> '   ' AND SD1.D_E_L_E_T_ <> '*' "  			  + TAB
			
			If (! Empty (dIDate) )
				cQry +=  " AND	 SD1."+cCampoNota + " >= '" +DtoS(dIDate) + "'" + TAB
			EndIf
			
			If (! Empty (dFDate) )
				cQry +=  " AND	 SD1."+cCampoNota + " < '" +DtoS(dFDate) + "'" + TAB
			EndIf 	 
			
			cQry +=  " AND		SD1.D1_TIPO = 'N' " + TAB
			cQry +=  " AND		SD1.D1_ITEMREM = '   ' " + TAB
			cQry +=  " AND		SD1.D1_SERIREM = '   ' " + TAB
			cQry +=  " AND		SD1.D1_REMITO = '   ' " + TAB
			cQry +=  " AND		AFN.D_E_L_E_T_ <> '*' " + TAB
			cQry +=  " AND		SD1.D_E_L_E_T_ <> '*' " + TAB
  	Endif



  	// Devoluções de Notas Fiscais
  	cQry +=  " UNION ALL " + TAB
	
	cQry +=  " SELECT 'DEV_NFE' ENTIDADE           , AFN.AFN_FILIAL  FILIAL			, AFN.AFN_PROJET PROJETO  , "   + TAB 
	cQry +=  " 		  AFN.AFN_REVISA REVISAO   , AFN.AFN_TAREFA TAREFA			, SD2.D2_COD PRODUTO      , "   + TAB
	cQry +=  "        SD2.D2_UM UNIDADE        , SD2.R_E_C_N_O_ RECNO 			, SD2.D2_DOC DOCUMENTO    , "   + TAB
	cQry +=  "        SD2.D2_ITEM ITEM         , D2_EMISSAO DTMOV, ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT) QUANTIDADE, " + TAB
	cQry +=  "        (SD2.D2_PRCVEN) UNITARIO, 0 TOTAL_QUANT, '' FIL, '' PED, '' ITEMPED, "+ TAB
	cQry +=  "        SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_ITEM, " + TAB
	cQry +=  "        SCP.CP_FILIAL, SCP.CP_NUM, SCP.CP_ITEM, SCP.CP_EMISSAO, " + TAB
    cQry +=  "        '' TIPOPED,  " + TAB	
	cQry +=  "        -1 * ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT * SD2.D2_PRCVEN)  TOTAL, " + TAB
	cQry +=  " 	 	  SD2.D2_CLIENTE FORNECEDOR, SD2.D2_LOJA LOJA               , SF2.F2_MOEDA MOEDA      , " + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_VALFRE,0) ) FRETE                               ,	" + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_SEGURO,0) ) SEGURO                              ,	" + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_DESPESA,0)) DESPESA                              , " + TAB 
	cQry +=  " 		  0 DEVOL 					  ,	" + TAB
	cQry +=  " 		  (SD2.D2_DESC * ( (SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * NULLIF(AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT,0),0)))  DESCONTO  					  ,	" + TAB
	cQry +=  " 		  ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_VALIPI,0)) VALIPI, ((SD2.D2_QUANT / NULLIF(SD1.D1_QUANT,0)) * AFN.AFN_QUANT / NULLIF(SD2.D2_QUANT * SD2.D2_VALIMP1,0)) VALIMP1,0 TOTAL_FRETE,0 TOTAL_SEGURO,0 TOTAL_DESPESA,0 TOTAL_DESCONTO,0 TOTAL_VALIPI,0 TOTAL_VALIMP1, 0 VRDEDUCAO, 0 VRRETENCAO                                 " + TAB
	cQry +=  " , (D2_CUSTO2 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA2, (D2_CUSTO3 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA3, (D2_CUSTO4 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA4, (D2_CUSTO5 / COALESCE(NULLIF(D2_CUSTO1,0),1)) TAXAMOEDA5  "
	cQry +=  " FROM	" + RetSqlName('SD2') + " SD2" + TAB 
	cQry +=  " INNER JOIN "+ RetSqlName('SD1') + " SD1 "  + TAB
	cQry +=  "		ON  SD2.D2_FILIAL	= SD1.D1_FILIAL " + TAB
	cQry +=  "		AND SD2.D2_NFORI    = SD1.D1_DOC "    + TAB
	cQry +=  "		AND SD2.D2_SERIORI  = SD1.D1_SERIE "  + TAB
	cQry +=  "		AND SD2.D2_ITEMORI  = SD1.D1_ITEM "   + TAB
	cQry +=  "		AND SD2.D2_CLIENTE  = SD1.D1_FORNECE "+ TAB
	cQry +=  "		AND SD2.D2_LOJA		= SD1.D1_LOJA "   + TAB
	cQry +=  "		AND SD2.D_E_L_E_T_ <> '*' "  		  + TAB

    cQry +=  " 		JOIN " + RetSqlName('SC7') + " SC7 " + TAB
    cQry +=  " 		LEFT JOIN " + RetSqlName('SC1') + " SC1 " + TAB
	cQry +=  " 			      LEFT JOIN " + RetSqlName('SCP') + " SCP" + TAB
	cQry +=  " 				    ON SCP.CP_FILIAL = SC1.C1_FILIAL" + TAB
	cQry +=  "  				AND SCP.CP_NUMSC = SC1.C1_NUM" 			  + TAB
	cQry +=  " 					AND SCP.CP_ITSC = SC1.C1_ITEM" 			  + TAB
	cQry +=  " 					AND SCP.D_E_L_E_T_ <> '*' " 			  + TAB
	cQry +=  " 				ON SC1.C1_FILIAL = SC7.C7_FILIAL" 			  + TAB
	cQry +=  " 				AND SC1.C1_NUM = SC7.C7_NUMSC " 			  + TAB
	cQry +=  " 				AND SC1.C1_ITEM = SC7.C7_ITEMSC " 			  + TAB
	cQry +=  " 				AND SC1.C1_PRODUTO = SC7.C7_PRODUTO" 			  + TAB
	cQry +=  " 				AND SC1.C1_PEDIDO = SC7.C7_NUM " 			  + TAB
	cQry +=  " 				AND SC1.C1_ITEMPED = SC7.C7_ITEM " 			  + TAB	
	cQry +=  " 				AND SC1.D_E_L_E_T_ <> '*' " 			  + TAB
	cQry +=  " 		    ON  SD1.D1_FILIAL = SC7.C7_FILIAL " 			  + TAB
	cQry +=  " 		   AND SD1.D1_PEDIDO = SC7.C7_NUM " 			  + TAB
	cQry +=  " 		   AND SD1.D1_ITEMPC = SC7.C7_ITEM" 			  + TAB	
	cQry +=  " 		   AND SD1.D1_FORNECE = SC7.C7_FORNECE" 			  + TAB
	cQry +=  " 		   AND SD1.D1_LOJA = SC7.C7_LOJA" 			  + TAB
	cQry +=  " 		   AND SD1.D1_COD = SC7.C7_PRODUTO" 			  + TAB

	cQry +=  " INNER JOIN " +RetSqlName('AFN') + " AFN ON "
	cQry +=  " AFN.AFN_FILIAL = '"+xFilial("AFN")+"'" + TAB 
	cQry +=  " AND		AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
	cQry +=  " AND		AFN.AFN_TAREFA >= '"+cCodITsk+"'" + TAB
	cQry +=  " AND		AFN.AFN_TAREFA <= '"+cCodFTsk+"'" + TAB
	cQry +=  " AND		AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
	cQry +=  " AND		AFN.AFN_FILIAL = SD1.D1_FILIAL "  + TAB
	cQry +=  " AND		AFN.AFN_DOC    = SD1.D1_DOC "     + TAB
	cQry +=  " AND		AFN.AFN_SERIE  = SD1.D1_SERIE "   + TAB
	cQry +=  " AND		AFN.AFN_ITEM   = SD1.D1_ITEM "    + TAB
	cQry +=  " AND		AFN.AFN_TIPONF = SD1.D1_TIPO "    + TAB
	cQry +=  " AND		AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB
	cQry +=  " AND		AFN.AFN_LOJA = SD1.D1_LOJA "      + TAB
	cQry +=  " AND		SD1.D1_TES <> '   ' AND AFN.D_E_L_E_T_ <> '*' "  			  + TAB
	cQry +=  " INNER JOIN " + RetSqlName('SF2') + " SF2"  + TAB 
	cQry +=  " 		ON  SF2.F2_FILIAL	= SD2.D2_FILIAL"  + TAB 
	cQry +=  " 		AND SF2.F2_DOC      = SD2.D2_DOC" 	  + TAB 
	cQry +=  " 		AND SF2.F2_SERIE    = SD2.D2_SERIE"   + TAB 
	cQry +=  " 		AND SF2.F2_CLIENTE  = SD2.D2_CLIENTE" + TAB 
	cQry +=  " 		AND SF2.F2_LOJA		= SD2.D2_LOJA" 	  + TAB 
	cQry +=  " 		AND SF2.D_E_L_E_T_ <> '*'" 			  + TAB	
	cQry +=  " WHERE	
	
	cQry +=  " SD2.D2_TES <> '   ' "  			  + TAB
	
	If (! Empty (dIDate) )
		cQry +=  " AND	 SD2."+cCampoDevolucao + " >= '" +DtoS(dIDate) + "'" + TAB
	EndIf
	
	If (! Empty (dFDate) )
		cQry +=  " AND	 SD2."+cCampoDevolucao + " < '" +DtoS(dFDate) + "'" + TAB
	EndIf 	 
	
	
	cQry +=  " AND		SD2.D_E_L_E_T_ <> '*' AND SD1.D_E_L_E_T_ <> '*' "  		  + TAB


	// Pagamento 	
	cQry += " UNION ALL " + TAB
	cQry += " SELECT CASE   " + TAB 
	cQry += " 	WHEN SD1.D1_DOC IS NOT NULL THEN 'PGT_NF'  " + TAB 
	cQry += " 	WHEN SE2.E2_ORIGEM LIKE 'FINI050' THEN 'PGT_RETADT' " + TAB  
	cQry += "   ELSE 'PGT_BACKOFFICE' " + TAB 
	cQry += "   END ENTIDADE, '"+cBranchId+"'  FILIAL			, COALESCE(AFN.AFN_PROJET,AFR.AFR_PROJET) PROJETO  ,    " + TAB     
	cQry += " COALESCE(AFN.AFN_REVISA,AFR.AFR_REVISA) REVISAO   , COALESCE(AFN.AFN_TAREFA,AFR.AFR_TAREFA) TAREFA			, SD1.D1_COD PRODUTO      ,   " + TAB     
	cQry += "  SD1.D1_UM UNIDADE        , SE5.R_E_C_N_O_ RECNO 			, SE5.E5_NUMERO DOCUMENTO    ,   " + TAB     
	cQry += "  SD1.D1_ITEM ITEM         , SE5.E5_DATA   DTMOV, "  + TAB 
	cQry += "  1 QUANTIDADE,     " + TAB 
	cQry += "  COALESCE(((AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT,0)) * (SD1.D1_VUNIT / NULLIF(SD1TOTAL.VUNITTOTAL,0)) * SE5.E5_VALOR),E5_VALOR) UNITARIO,   	 " + TAB 
	cQry += "  1 TOTAL_QUANT,    " + TAB 
	cQry += "  SD1.D1_FILIAL, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_ITEM,     " + TAB    
	cQry += "  SCP.CP_FILIAL, SCP.CP_NUM, SCP.CP_ITEM,  SCP.CP_EMISSAO, '' TIPOPED,   " + TAB 
	cQry += "  COALESCE(((AFN.AFN_QUANT / NULLIF(SD1.D1_QUANT,0)) * (SD1.D1_VUNIT / NULLIF(SD1TOTAL.VUNITTOTAL,0)) * SE5.E5_VALOR), AFR.AFR_VALOR1) TOTAL,    " + TAB 
	cQry += "  SE5.E5_FORNECE FORNECEDOR, SE5.E5_LOJA LOJA               , SF1.F1_MOEDA MOEDA      ,     " + TAB 
	cQry += "  (0) FRETE ,	(0) SEGURO , (0) DESPESA , 0 DEVOL , (0)  DESCONTO , (0) VALIPI, (0) VALIMP1,    " + TAB 
	cQry += "  0  TOTAL_FRETE, 0  TOTAL_SEGURO, 0 TOTAL_DESPESA, SE5.E5_VLDESCO TOTAL_DESCONTO, 0  TOTAL_VALIPI, 0 TOTAL_VALIMP1,  	 " + TAB    
	cQry += sCamposRetDed + TAB
	cQry += " ,(D1_CUSTO2 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA2, (D1_CUSTO3 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA3, (D1_CUSTO4 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA4, (D1_CUSTO5 / COALESCE(NULLIF(D1_CUSTO,0),1)) TAXAMOEDA5    " + TAB 
	cQry += " FROM " + RetSqlName('SE5') + " SE5 " + TAB 
	cQry += " LEFT JOIN " + RetSqlName('SE2') + " SE2  " + TAB 
	cQry += " ON E2_FILIAL = SE5.E5_FILIAL AND E2_PREFIXO= SE5.E5_PREFIXO " + TAB 
	cQry += " AND E2_NUM= SE5.E5_NUMERO AND E2_PARCELA= SE5.E5_PARCELA " + TAB 
	cQry += " AND E2_TIPO= SE5.E5_TIPO AND E2_FORNECE= SE5.E5_FORNECE " + TAB 
	cQry += " AND E2_LOJA = SE5.E5_LOJA AND SE2.D_E_L_E_T_ = SE5.D_E_L_E_T_ " + TAB 
	cQry += " AND SE2.D_E_L_E_T_ <> '*' " + TAB 
	cQry += " LEFT JOIN " + RetSqlName('SD1') + " SD1  " + TAB 
	cQry += " ON D1_DOC = E5_NUMERO AND D1_SERIE = E5_PREFIXO " + TAB 
	cQry += " AND D1_FORNECE = E5_FORNECE AND D1_LOJA = E5_LOJA AND SD1.D_E_L_E_T_ <> '*' " + TAB 
	cQry += " LEFT JOIN (SELECT SUM(D1_VUNIT) VUNITTOTAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA FROM  " + RetSqlName('SD1') + " SD1 " + TAB 
    cQry += "   WHERE SD1.D_E_L_E_T_ <> '*' " + TAB 
	cQry += "   GROUP BY D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA) SD1TOTAL  " + TAB 
	cQry += " 	ON SD1TOTAL.D1_DOC = E5_NUMERO " + TAB 
    cQry += "   AND SD1TOTAL.D1_SERIE = E5_PREFIXO " + TAB 
    cQry += "   AND SD1TOTAL.D1_FORNECE = E5_FORNECE " + TAB 
    cQry += "   AND SD1TOTAL.D1_LOJA = E5_LOJA " + TAB 
    cQry += "   AND SD1.D_E_L_E_T_ <> '*' " + TAB 
	cQry += " LEFT JOIN  " + RetSqlName('SF1') + " SF1 " + TAB 
	cQry += " ON  SF1.F1_FILIAL	= SD1.D1_FILIAL AND SF1.F1_DOC      = SD1.D1_DOC " + TAB 
	cQry += " AND SF1.F1_SERIE    = SD1.D1_SERIE AND SF1.F1_FORNECE  = SD1.D1_FORNECE  " + TAB 
	cQry += " AND SF1.F1_LOJA		= SD1.D1_LOJA AND SF1.D_E_L_E_T_ <> '*'		  " + TAB 
	cQry += " LEFT JOIN "+ RetSqlName('AFNT10') +" AFN ON AFN.AFN_FILIAL = SD1.D1_FILIAL  " + TAB 
	cQry += " AND AFN.AFN_DOC    = SD1.D1_DOC AND	AFN.AFN_SERIE  = SD1.D1_SERIE  " + TAB  
	cQry += " AND AFN.AFN_ITEM   = SD1.D1_ITEM  " + TAB 
	cQry += " AND AFN.AFN_TIPONF = SD1.D1_TIPO  " + TAB 
	cQry += " AND AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB 
	cQry += " AND AFN.AFN_LOJA = SD1.D1_LOJA " + TAB 
	cQry += " AND AFN.D_E_L_E_T_ <> '*'" + TAB 
	cQry += " LEFT JOIN "+ RetSqlName('AFRT10') + " AFR" + TAB 
	cQry += " ON SD1.D1_DOC IS NULL AND E5_PREFIXO = AFR_PREFIX" + TAB 
	cQry += " AND E5_NUMERO = AFR_NUM AND E5_PARCELA = AFR_PARCEL" + TAB 
	cQry +=	" AND E5_TIPO = AFR_TIPO AND E5_FORNECE = AFR_FORNEC" + TAB 
	cQry += " AND E5_LOJA = AFR_LOJA AND AFR.D_E_L_E_T_ <> '*'" + TAB 
	cQry += " LEFT JOIN "+ RetSqlName('SC7T10') + " SC7 " + TAB 
	cQry += " 	  	ON  SD1.D1_FILIAL = SC7.C7_FILIAL AND  		" + TAB 	   
	cQry += " 	  	 SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM  	" + TAB 		   	
	cQry += " 	  	AND SD1.D1_FORNECE = SC7.C7_FORNECE AND SD1.D1_LOJA = SC7.C7_LOJA  " + TAB 			   
	cQry += " 	  	AND SD1.D1_COD = SC7.C7_PRODUTO AND SC7.D_E_L_E_T_ <> '*'" + TAB 
	cQry += " LEFT JOIN "+ RetSqlName('SC1T10') + " SC1 " + TAB 
	cQry += " 		ON  SC1.C1_NUM = SC7.C7_NUMSC 	AND SC1.C1_FILIAL = SC7.C7_FILIAL   " + TAB 			   
	cQry += " 			AND SC1.C1_ITEM = SC7.C7_ITEMSC AND SC1.C1_PRODUTO = SC7.C7_PRODUTO " + TAB  			   
	cQry += " 			AND SC1.C1_PEDIDO = SC7.C7_NUM  AND SC1.C1_ITEMPED = SC7.C7_ITEM  " + TAB  			   	
	cQry += " 			AND SC1.D_E_L_E_T_ <> '*'   " + TAB 
	cQry += " LEFT JOIN   " + RetSqlName('SCPT10') + " SCP " + TAB 
	cQry += " 		ON SCP.CP_FILIAL = SC1.C1_FILIAL AND SCP.CP_NUMSC = SC1.C1_NUM  	" + TAB 		   
	cQry += " 		AND SCP.CP_ITSC = SC1.C1_ITEM  	AND SCP.D_E_L_E_T_ <> '*' " + TAB   			   
	cQry += " WHERE SE5.D_E_L_E_T_ <> '*' AND SE5.E5_TIPODOC <> 'DC' AND " + TAB 
	cQry += " ((AFN.AFN_PROJET IS NOT NULL " + TAB 
	cQry += " AND AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
	cQry += " AND AFN.AFN_TAREFA >= '"+cCodITsk+"'" + TAB
	cQry += " AND AFN.AFN_TAREFA <= '"+cCodFTsk+"'" + TAB
	cQry += " AND AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
	cQry += " AND SD1.D1_TES <> '   ' AND SD1.D_E_L_E_T_ <> '*'    			   
	If (!Empty(dIDate))
		cQry +=  " AND SD1."+cCampoNota + " >= '" +DtoS(dIDate) + "'" + TAB
	EndIf
	
	If (!Empty(dFDate))
		cQry +=  " AND SD1."+cCampoNota + " < '" +DtoS(dFDate) + "'" + TAB
	EndIf 	 
	cQry += " AND SD1.D1_TIPO = 'N' AND SD1.D1_ITEMREM = '   '  " + TAB
	cQry += " AND SD1.D1_SERIREM = '   '  AND		SD1.D1_REMITO = '   '   AND		AFN.D_E_L_E_T_ <> '*' "  + TAB  
	cQry += " AND SD1.D_E_L_E_T_ <> '*'  ) "   + TAB
	cQry += " OR " + TAB
	cQry += " (AFR_PROJET <> '' " + TAB 
	cQry +=  " AND		AFR.AFR_PROJET = '"+cCodProj+"'"  + TAB
	cQry +=  " AND		AFR.AFR_TAREFA >= '"+cCodITsk+"'" + TAB
	cQry +=  " AND		AFR.AFR_TAREFA <= '"+cCodFTsk+"'" + TAB
	cQry +=  " AND		AFR.AFR_REVISA = '"+cCodRev+"'"   + TAB
	If (!Empty(dIDate))
		cQry +=  " AND	 SE2."+cCampoPagto + " >= '" +DtoS(dIDate) + "'" + TAB
	EndIf
	If (!Empty(dFDate))
		cQry +=  " AND	 SE2."+cCampoPagto + " < '" +DtoS(dFDate) + "'" + TAB
	EndIf
	cQry +=  " )) "
	
EndIf

cQry +=  "		)  DADOS " + TAB
cQry +=  " WHERE DADOS.RECNO > 0 " + TAB
cQry +=  " ) FINAL " + TAB
cQry +=  " WHERE FINAL.ITEMNUMBER BETWEEN ("+ Alltrim(Str((nPages - 1) * nPSize + 1))+") AND (" + Alltrim(Str((nPages * nPSize))) + ')'
cQry +=  " ORDER BY	PROJETO, REVISAO, TAREFA, FILIAL, ENTIDADE,DTMOV " + TAB 
cQry := ChangeQuery(cQry)

pExistCustom := ExistBlock("SUPTASKCPE")

If pExistCustom
	aParam			:= {cCodProj,cCodRev,cCodITsk,cCodFTsk,dIDate,dFDate,aTpMov,nPages,nPSize,cBanco,cCurrencySimbol,cQry}
	cQry := ExecBlock("SUPTASKCPE", .F., .F., aParam)
ENDIF

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "DAD", .T., .T. )

SUPRESERRHDL()

Return (.T.)

/*
{Protheus.doc} SUPSETERRHDL
@Uso    Seta código e mensagem de erro 
@param  Objeto de erro
@return	Nenhum

@Autor  Lucas Peixoto Sepe - TOTVS
*/
Static Function SUPSETERRHDL(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)

/*
{Protheus.doc} SUPRESERRHDL
@Uso    Seta código e mensagem de erro 
@param  Objeto de erro
@return	Nenhum

@Autor  Lucas Peixoto Sepe - TOTVS
*/
Static Function SUPRESERRHDL(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)
