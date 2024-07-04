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

WSRESTFUL MOVCONTRACTASSIGNMENTS DESCRIPTION "Movimentos relacionados ao contrato" 

	WSDATA page 						AS INTEGER
	WSDATA pageSize						AS INTEGER
	WSDATA sourceApp 					AS STRING
	WSDATA companyId 					AS STRING
	WSDATA branchId 					AS STRING
	
	WSDATA contractInternalId 			AS STRING
	
	WSDATA GetCount      			AS Boolean
	
	WSDATA freightValueExcluded 		AS Boolean OPTIONAL
	WSDATA insuranceValueExcluded 		AS Boolean OPTIONAL
	WSDATA expenseValueExcluded 		AS Boolean OPTIONAL
	WSDATA IPIValueExcluded		 		AS Boolean OPTIONAL
	
	WSMETHOD GET DESCRIPTION STR0010 WSSYNTAX "/MOVCONTRACTASSIGNMENTS || /MOVCONTRACTASSIGNMENTS/{id}"
		
END WSRESTFUL

WSMETHOD GET WSRECEIVE page, sourceApp, companyId, branchId, contractInternalId, freightValueExcluded, insuranceValueExcluded, expenseValueExcluded, IPIValueExcluded WSSERVICE MOVCONTRACTASSIGNMENTS


Local lMetodo		:= .F.
Local lNew			:= .F.
Local lCompact		:= .F.

Local lFrete		:= .F.
Local lSegur		:= .F.
Local lDespe		:= .F.

Local lVaIPI        := .F.

Local nAcresc		:= 0

Local nPages		:= 0
Local nPSize		:= 0
Local nLenComp		:= 0
Local nCurReg		:= 0
Local nTotReg		:= 0
Local cTempTsk		:= ""
Local cMarca		:= ""
Local cEmpre		:= ""
Local cBranc		:= ""
Local strJs			:= ""
Local aEmpre		:= {}
Local aArrayMovim	:= {}
Local aArrayTask	:= {}
Local jsreturn		:= Nil
Local jsdata		:= Nil
Local jstask		:= Nil
Local jsMovim		:= Nil

Private bError		:= { |e| oError := e, Break(e) }
Private bErrorBlock	:= ErrorBlock( bError )
Private oError		:= Nil

DEFAULT ::page						:= 0
DEFAULT ::pageSize					:= 0
DEFAULT ::sourceApp					:= ""
DEFAULT ::companyId					:= ""
DEFAULT ::branchId					:= ""  

DEFAULT ::contractInternalId		:= ""
DEFAULT ::IPIValueExcluded          := .F.

BEGIN SEQUENCE

	nPages := ::page
	nPSize := ::pageSize
	cMarca := ::sourceApp
	cEmpre := ::companyId
	cBranc := ::branchId 
		  
	cGetCount	   := ::GetCount
	cContractInternalId := ::contractInternalId
	
	lFrete := ::FreightValueExcluded
	lSegur := ::InsuranceValueExcluded
	lDespe := ::ExpenseValueExcluded
	lVaIPI := ::IPIValueExcluded
	
	aEmpre := {}
	
	aEmpre := FWEAIEMPFIL(cEmpre, cBranc, cMarca)

	If Len (aEmpre) < 2
		SetRestFault(400, STR0001 + cEmpre + STR0002 + cBranc + " - para marca " + cMarca + "' !")
		Return lMetodo
	EndIf 

	If Len (aEmpre) > 1
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA aEmpre[1] FILIAL aEmpre[2] TABLES "CTG", "CTO", "AFR", "SE2", "AFN", "SD1", "SD2", "SC1", "AFH", "SCP", "SD3", "SC1" MODULO "COM" 
	EndIf
	
	//Deixa setado o erro, caso ocorra
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
		
	//Reset o erro
	SUPRESERRHDL()
	
	//Valida informações obrigatorias .
	If !SUPCPOOBR(nPages,nPSize,cMarca,cEmpre,cBranc, cContractInternalId)
		Return lMetodo
	EndIf
	
	aContractTemp := SUPEAICONTRACT(cMarca, cContractInternalId)
	
	If Empty(aContractTemp)
		Return .F.
	Endif
	
	conout(aContractTemp)
	
	aContract = STRTOKARR(aContractTemp,"|")
	
	if(len(aContract) == 5)
		cCodPrj = aContract[3]
		cRev = aContract[4]
		cCodCont = aContract[5]
	Else   
		cCodPrj = aContract[2]
		cRev = aContract[3]
		cCodCont = aContract[4]
	Endif
	
	If !SUPREADSQL(cCodPrj, cRev, cCodCont, nPages, nPSize, cBanco)
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
	
	DBSelectArea("DAD")
	DAD->(DBGoTop())
	
	If(cGetCount == .T.)
		if(DAD->( !EOF() ))
			nTotReg	:= DAD->TOTALNUMBER
		EndIf
	Else
		Do While DAD->( !EOF() )
	    	nAcresc := 0
	    	
	    	If cTempTsk <> cEmpAnt+'|'+RTrim(xFilial("AF9"))+'|'+RTrim(DAD->PROJETO)+'|'+RTrim(DAD->REVISAO)+'|'+RTrim(DAD->TAREFA)   
	    		If Empty (cTempTsk)
	    			cTempTsk := cEmpAnt+'|'+RTrim(xFilial("AF9"))+'|'+RTrim(DAD->PROJETO)+'|'+RTrim(DAD->REVISAO)+'|'+RTrim(DAD->TAREFA) 
	    		Else
	    			jstask := JsonObject():new()
			    
		    		jstask['taskInternalId'] := cTempTsk
		    		
		    		jstask['taskCostAssignments'] := aArrayMovim
		    		
		    		AAdd(aArrayTask,jstask )
		    		
		    		aArrayMovim := {}
		    		
		    		cTempTsk := cEmpAnt+'|'+RTrim(xFilial("AF9"))+'|'+RTrim(DAD->PROJETO)+'|'+RTrim(DAD->REVISAO)+'|'+RTrim(DAD->TAREFA)   
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
			jsMovim['recno']					:= DAD->RECNO
			
			If !Empty(DAD->DOCUMENTO)
				jsMovim['documentNumber']	:= RTrim(DAD->DOCUMENTO)
			EndIf
			
			If !Empty(DAD->ITEM)
				jsMovim['itemNumber'] 		:= RTrim(DAD->ITEM)
			EndIf
			
			If !Empty(DAD->PRODUTO)
				jsMovim['itemInternalid'] 	:= IntProExt(cEmpAnt,RTrim(xFilial("SB1")),RTrim(DAD->PRODUTO))[2]
			EndIf
		    
			If !Empty(DAD->UNIDADE)
				jsMovim['unitOfMeasureInternalid']	:= IntUndExt(cEmpAnt,RTrim(xFilial("SAH")),RTrim(DAD->UNIDADE))[2]
			EndIf
		    
			jsMovim['quantity'] 				:= DAD->QUANTIDADE
			jsMovim['unitPrice'] 			:= DAD->UNITARIO
			jsMovim['increase'] 				:= nAcresc
			jsMovim['decrease'] 				:= DAD->DESCONTO + DAD->DEVOL
			jsMovim['totalPrice'] 			:= DAD->TOTAL + nAcresc - DAD->DESCONTO - DAD->DEVOL
	
			If !Empty(DAD->FORNECEDOR)
				jsMovim['customerVendorInternalId'] := IntForExt(cEmpAnt,RTrim(xFilial("SA2")),RTrim(DAD->FORNECEDOR),RTrim(DAD->LOJA))[2]
			EndIf
		    
			If !Empty(DAD->MOEDA)
				jsMovim['currencyInternalId'] := C40MontInt(,Iif((DAD->MOEDA<10),STrZero(DAD->MOEDA,TAMSx3("CTO_MOEDA")[1],0),cValtoChar(DAD->MOEDA)))
			EndIf
			
		    AAdd(aArrayMovim,jsMovim)
		    
		    nCurReg := DAD->ITEMNUMBER
		    
		    DAD->(DBSkip())
		Enddo
    EndIf
    
	jstask := JsonObject():new()
		    
	If Len(aArrayMovim) > 0
		jstask['taskInternalId'] 		:= cTempTsk
		jstask['taskCostAssignments'] 	:= aArrayMovim
	
		aArrayMovim := {}
	   	AAdd(aArrayTask, jstask )
	EndIf
		    		
	jsdata['tasks']						:= aArrayTask
	    
	jsreturn['total']					:= nTotReg
	jsreturn['hasNext']					:= Iif(nCurReg >= nTotReg,.F.,.T.)
	jsreturn['data'] 					:= jsdata  
    
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
	//SetRestFault(400, STR0019 + TAB + oError:Description + oError:ErrorStack)	
	lMetodo := .F.
	Return lMetodo

END SEQUENCE 

ErrorBlock( bErrorBlock )

Return lMetodo 

/*
{Protheus.doc} SUPCPOOBR
@Uso    Verifica os campos obrigatório no recebimento da mensagem REST
@Autor  Daniel de Paulo e Silva - TOTVS
@param  Campos recebidos da mensagem REST
@return	.T. -> Processo validado ; .F. -> Processo Interrompido
*/

Static Function SUPCPOOBR(nPages,nPSize,cMarca,cEmpre,cBranc,cContractInternalId)				

Local lRet := .T.



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

If Empty(cContractInternalId) 
	SetRestFault(400, STR0003 + "cContractInternalId" + STR0004)
	lRet := .F.
EndIf

Return lRet

/*
{Protheus.doc} SUPEAITASK
@Uso    Verifica as mensagem recebidas de acordo com a integração EAI para montagem de DE/PARA
@param  cEntidade = Entidade de Integracao;cMarca = Produto de Integracao; cOrigem = Campos recebidos da mensagem REST
@return	Array de informação de DE/PARA

@Autor  Daniel de Paulo e Silva - TOTVS
*/

Static Function SUPEAICONTRACT(cMarca, cContractInternalId)

Local   aIntegra	:= {}
Local   cAlias   := 'ANE'
Local   cField   := 'ANE_CONTRA'
	
SUPSETERRHDL(STR0015)

//Busca InternalId do contrato (PMSI203)
aIntegra := CFGA070Int(cMarca, cAlias, cField, cContractInternalId)

If Empty(aIntegra)
	SetRestFault(400,  "Contrato " + cContractInternalId + STR0007 + " Marca: " + cMarca)
End If

SUPRESERRHDL()

Return (aIntegra)

/*
{Protheus.doc} SUPREADSQL
@Uso    Prepara o arquivo de trabalho montado na query 
@param  Projeto, Revisao, Contrato
@return	Nenhum

@Autor  Wesley Alves Pereira - TOTVS
*/

Static Function SUPREADSQL(cCodProj, cCodRev, cCodContra, nPages, nPSize, cBanco)

Local nHandle := 0

Private cQry	:= ""  

SUPSETERRHDL(STR0017)

DBSelectArea("AFN")
AFN->(DBSetOrder(1))

DBSelectArea("SD1")
SD1->(DBSetOrder(1))

If Select("DAD") > 0
	DAD->(DbCloseArea())
Endif

cQry +=  " SELECT * " + TAB
cQry +=  " FROM " + TAB
cQry +=  " ( " + TAB  

If cBanco == "ORACLE"
	cQry +=  " SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  " + TAB
Else
	cQry +=  " 		SELECT ROW_NUMBER() OVER( ORDER BY PROJETO, REVISAO, TAREFA, FILIAL ) ITEMNUMBER, " + TAB 
	cQry +=  " 				COUNT(1) OVER() AS TOTALNUMBER, * " + TAB
EndIf

cQry +=  " 	FROM " + TAB  
cQry +=  "  	( " + TAB  


//NOTA FISCAL DE ENTRADA - NFE
	
	cQry +=  " SELECT AFN.AFN_FILIAL  FILIAL			, AFN.AFN_PROJET PROJETO  , " + TAB 
	cQry +=  " 		  AFN.AFN_REVISA REVISAO   , AFN.AFN_TAREFA TAREFA			, SD1.D1_COD PRODUTO      , " + TAB
	cQry +=  "        SD1.D1_UM UNIDADE        , SD1.R_E_C_N_O_ RECNO 			, SD1.D1_DOC DOCUMENTO    , " + TAB
	cQry +=  "        SD1.D1_ITEM ITEM         , AFN.AFN_QUANT QUANTIDADE, " + TAB
	cQry +=  "        (SD1.D1_VUNIT) UNITARIO, " + TAB	
	cQry +=  "        (AFN.AFN_QUANT * SD1.D1_VUNIT)  TOTAL, " + TAB
	cQry +=  " 	 	  SD1.D1_FORNECE FORNECEDOR, SD1.D1_LOJA LOJA               , SF1.F1_MOEDA MOEDA      , " + TAB
	cQry +=  " 		  (AFN.AFN_QUANT / SD1.D1_QUANT * SD1.D1_VALFRE ) FRETE                               ,	" + TAB
	cQry +=  " 		  (AFN.AFN_QUANT / SD1.D1_QUANT * SD1.D1_SEGURO ) SEGURO                              ,	" + TAB
	cQry +=  " 		  (AFN.AFN_QUANT /SD1.D1_QUANT * SD1.D1_DESPESA) DESPESA                              , " + TAB 
	cQry +=  " 		  (AFN.AFN_QUANT /SD1.D1_QUANT * SD1.D1_VALIPI) VALIPI 								  , " + TAB 
	cQry +=  " 		  (AFN.AFN_QUANT / SD1.D1_QUANT * COALESCE(SD2.D2_TOTAL,0)) DEVOL 					  ,	" + TAB
	cQry +=  " 		  (SD1.D1_VALDESC * ( AFN.AFN_QUANT / SD1.D1_QUANT))  DESCONTO  					  	" + TAB
	cQry +=  " FROM	"+ RetSqlName('AFN') + " AFN , "+ RetSqlName('SD1') + " SD1" + TAB 
	cQry +=  " INNER JOIN " + RetSqlName('SF1') + " SF1"  + TAB 
	cQry +=  " 		ON  SF1.F1_FILIAL	= SD1.D1_FILIAL"  + TAB 
	cQry +=  " 		AND SF1.F1_DOC      = SD1.D1_DOC" 	  + TAB 
	cQry +=  " 		AND SF1.F1_SERIE    = SD1.D1_SERIE"   + TAB 
	cQry +=  " 		AND SF1.F1_FORNECE  = SD1.D1_FORNECE" + TAB 
	cQry +=  " 		AND SF1.F1_LOJA		= SD1.D1_LOJA" 	  + TAB 
	cQry +=  " 		AND SF1.D_E_L_E_T_ <> '*'" 			  + TAB	
	cQry +=  " 	LEFT JOIN "+ RetSqlName('SD2') + " SD2 "  + TAB
	cQry +=  "		ON  SD2.D2_FILIAL	= SD1.D1_FILIAL " + TAB
	cQry +=  "		AND SD2.D2_NFORI    = SD1.D1_DOC "    + TAB
	cQry +=  "		AND SD2.D2_SERIORI  = SD1.D1_SERIE "  + TAB
	cQry +=  "		AND SD2.D2_ITEMORI  = SD1.D1_ITEM "   + TAB
	cQry +=  "		AND SD2.D2_CLIENTE  = SD1.D1_FORNECE "+ TAB
	cQry +=  "		AND SD2.D2_LOJA		= SD1.D1_LOJA "   + TAB
	cQry +=  "		AND SD2.D_E_L_E_T_ <> '*' "  		  + TAB
	cQry +=  " WHERE	AFN.AFN_FILIAL = '"+xFilial("AFN")+"'"   + TAB 
	cQry +=  " AND		AFN.AFN_PROJET = '"+cCodProj+"'"  + TAB
	
	cQry +=  " AND		AFN.AFN_CONTRA = '"+cCodContra+"'" + TAB
	
	cQry +=  " AND		AFN.AFN_REVISA = '"+cCodRev+"'"   + TAB
	cQry +=  " AND		AFN.AFN_FILIAL = SD1.D1_FILIAL "  + TAB
	cQry +=  " AND		AFN.AFN_DOC    = SD1.D1_DOC "     + TAB
	cQry +=  " AND		AFN.AFN_SERIE  = SD1.D1_SERIE "   + TAB
	cQry +=  " AND		AFN.AFN_ITEM   = SD1.D1_ITEM "    + TAB
	cQry +=  " AND		AFN.AFN_TIPONF = SD1.D1_TIPO "    + TAB
	cQry +=  " AND		AFN.AFN_FORNEC = SD1.D1_FORNECE " + TAB
	cQry +=  " AND		AFN.AFN_LOJA = SD1.D1_LOJA "      + TAB
	cQry +=  " AND		SD1.D1_TES <> '   ' "  			  + TAB
	
	cQry +=  " AND		SD1.D1_TIPO = 'N' "  			  + TAB
	cQry +=  " AND		SD1.D1_ITEMREM = '   ' "  			  + TAB
	cQry +=  " AND		SD1.D1_SERIREM = '   ' "  			  + TAB
	cQry +=  " AND		SD1.D1_REMITO = '   ' "  			  + TAB
	cQry +=  " AND		AFN.D_E_L_E_T_ <> '*' "  		  + TAB
	cQry +=  " AND		SD1.D_E_L_E_T_ <> '*' "  		  + TAB
	
	cQry +=  "		)  DADOS " + TAB
	cQry +=  " WHERE DADOS.RECNO > 0 " + TAB
	cQry +=  " ) FINAL " + TAB
	//cQry +=  " WHERE FINAL.ITEMNUMBER BETWEEN ("+ Alltrim(Str((nPages - 1) * nPSize + 1))+") AND (" + Alltrim(Str((nPages * nPSize))) + ')'
	cQry +=  " ORDER BY	PROJETO, REVISAO, TAREFA, FILIAL " + TAB 

	nHandle := FCreate("arq.ori.txt")
	IF nHandle == -1
		Return (.F.)    
	ELSE
		FWrite(nHandle, cQry)
		FClose(nHandle)
	ENDIF
	
	cQry := ChangeQuery(cQry)
	
	nHandle := FCreate("arq.mod.txt")
	IF nHandle == -1
	   Return (.F.)   
	ELSE
		FWrite(nHandle, cQry)
		FClose(nHandle)
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