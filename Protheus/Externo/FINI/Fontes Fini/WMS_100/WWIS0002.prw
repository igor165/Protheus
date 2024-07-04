#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS0002

WMS 100% - Log Integraçãoes

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function WWIS0002()

Local aArea		:= GetArea()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("ZWH")
oBrowse:SetDescription("Ocorrências - Integração WIS")
oBrowse:DisableDetails()

oBrowse:AddLegend("EMPTY(ZWH_STATUS)"			, "BR_PRETO"		, "Erro Inderteminado")
oBrowse:AddLegend("VAL(ZWH_STATUS) > 50 "		, "BR_VERMELHO"	, "Integração com erro")
oBrowse:AddLegend("VAL(ZWH_STATUS) <= 50 "	, "BR_VERDE"		, "Integração concluída")
oBrowse:DisableDetails()
oBrowse:Activate()

RestArea(aArea)

Return         

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF

MenuDef - Padrão MVC

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function MENUDEF()

Local aRotina 	:= {} 

ADD OPTION aRotina TITLE "Pesquisar"	ACTION "PesqBrw"          	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.WWIS0002"	OPERATION 2 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.WWIS0002" 	OPERATION 3 ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.WWIS0002" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.WWIS0002" 	OPERATION 5 ACCESS 0
					
Return aRotina     

//-------------------------------------------------------------------
/*/{Protheus.doc} MODELDEF

ModelDef - Padrão MVC

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12
@return objeto, Objeto do Model

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION MODELDEF()

Local oStruct1
Local oModel

oModel	:= MPFormModel():New("WWIS02MOD") //,,,  /*bPreValidacao*/, {|oMdl| WWIS02OK(oMdl)}/*bPost*/, {|oMdl| WWIS02GRV(oMdl)}/*bCommit*/, /*bCancel*/))
oStruct1	:= FWFormStruct(1, "ZWH")

//Estrutura Model
oModel:AddFields("ZWH_LOG",,oStruct1)

oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} VIEWDEF

ViewDef - Padrão MVC

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12
@return objeto, Objeto da View

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION VIEWDEF()

Local oStruct1
Local oModel
Local oView

oModel  := FWLoadModel("WWIS0002") //Chamada do model utilizando o nome do fonte (PRW)
oStruct1	:= FWFormStruct(2, "ZWH")
oView    	:= FWFormView():New() //View da MVC

oView:SetModel(oModel)

//Estrutura View
oView:AddField("VIEW_ZWH", oStruct1, "ZWH_LOG")

//Formatação da Tela
oView:CreateHorizontalBox("BOXZWH"	,100) //Uma barra horizontal com proporção de 35% da tela.
oView:SetOwnerView("VIEW_ZWH", "BOXZWH")
oView:SetCloseOnOk({|| .T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS02GRV

Rotina para gravação dos dados

@author  Allan Constantino Bonfim
@since   08/06/2018
@version P12
@param	[oModelTmp], objeto, Objeto do Model
		
@return lRet, variável lógica

/*/
//------------------------------------------------------------------- 
STATIC FUNCTION WWIS02GRV(oModelTmp)

Local aArea		:= GetArea()
Local lRet	 		:= .T.
Local nOper		:= oModelTmp:GetOperation() 
Local cQuery		:= ""  
Local cTmpQuery	:= GetNextAlias()

/*
If nOper == 5

	cQuery 	:= "SELECT COUNT(*) AS QTDZ01 FROM "+RETSQLNAME("SD3")+" SD3 (NOLOCK) "+CHR(13)+CHR(10)	
	cQuery 	+= "WHERE SD3.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	cQuery 	+= "AND D3_MOTEHFI = '"+oModelCab:GetValue('Z01_MOTIVO', 'Z01_CODIGO')+"' "+CHR(13)+CHR(10)
    
	If Select(cTmpQuery) > 0
		(cTmpQuery)->(DbCloseArea())
	EndIf
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTmpQuery, .T., .T.)
	      
	If (cTmpQuery)->QTDZ01 > 0
		HELP(,, 'Motivo HFI',, "O motivo não poderá ser excluído pois existem movimentações de envio para o HFI." , 1, 0)
		lRet := .F.	
	EndIf
	
Else

	cQuery 	:= "SELECT COUNT(*) AS QTDZ01 FROM "+RETSQLNAME("Z01")+" Z01 "+CHR(13)+CHR(10)	
	cQuery 	+= "WHERE Z01.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	cQuery 	+= "AND Z01_DESCRI = '"+oModelCab:GetValue('Z01_MOTIVO', 'Z01_DESCRI')+"' "+CHR(13)+CHR(10)
	cQuery	+= "AND Z01_CODIGO <> '"+oModelCab:GetValue('Z01_MOTIVO', 'Z01_CODIGO')+"' "+CHR(13)+CHR(10)

	If Select(cTmpQuery) > 0
		(cTmpQuery)->(DbCloseArea())
	EndIf

    If nOper == 3
	    cMsgRet	:= "O motivo não poderá ser incluído pois já existe um motivo cadastrado com esse nome." 
    ElseIf nOper == 4
	    cMsgRet	:= "O motivo não poderá ser alterado pois já existe um motivo cadastrado com esse nome."     
    EndIf

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTmpQuery, .T., .T.)
      
	If (cTmpQuery)->QTDZ01 > 0
		HELP(,, 'Motivo HFI',, cMsgRet, 1, 0)
		lRet := .F.
	EndIf
	
EndIf
*/

If Select(cTmpQuery) > 0
	(cTmpQuery)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS02OK

Validação final da rotina (Tudo Ok)

@author  Allan Constantino Bonfim
@since   08/06/2018
@version P12
@param	[oModelTmp], objeto, Objeto do Model
		
@return lRet, variável lógica

/*/
//------------------------------------------------------------------- 
STATIC FUNCTION WWIS02OK(oModelTmp)

Local aArea		:= GetArea()
Local lRet	 		:= .T.
Local nOper		:= oModelTmp:GetOperation() 
Local cQuery		:= ""  
Local cTmpQuery	:= GetNextAlias()

/*
If nOper == 5

	cQuery 	:= "SELECT COUNT(*) AS QTDZ01 FROM "+RETSQLNAME("SD3")+" SD3 (NOLOCK) "+CHR(13)+CHR(10)	
	cQuery 	+= "WHERE SD3.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	cQuery 	+= "AND D3_MOTEHFI = '"+oModelCab:GetValue('Z01_MOTIVO', 'Z01_CODIGO')+"' "+CHR(13)+CHR(10)
    
	If Select(cTmpQuery) > 0
		(cTmpQuery)->(DbCloseArea())
	EndIf
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTmpQuery, .T., .T.)
	      
	If (cTmpQuery)->QTDZ01 > 0
		HELP(,, 'Motivo HFI',, "O motivo não poderá ser excluído pois existem movimentações de envio para o HFI." , 1, 0)
		lRet := .F.	
	EndIf
	
Else

	cQuery 	:= "SELECT COUNT(*) AS QTDZ01 FROM "+RETSQLNAME("Z01")+" Z01 "+CHR(13)+CHR(10)	
	cQuery 	+= "WHERE Z01.D_E_L_E_T_ = '' "+CHR(13)+CHR(10)
	cQuery 	+= "AND Z01_DESCRI = '"+oModelCab:GetValue('Z01_MOTIVO', 'Z01_DESCRI')+"' "+CHR(13)+CHR(10)
	cQuery	+= "AND Z01_CODIGO <> '"+oModelCab:GetValue('Z01_MOTIVO', 'Z01_CODIGO')+"' "+CHR(13)+CHR(10)

	If Select(cTmpQuery) > 0
		(cTmpQuery)->(DbCloseArea())
	EndIf

    If nOper == 3
	    cMsgRet	:= "O motivo não poderá ser incluído pois já existe um motivo cadastrado com esse nome." 
    ElseIf nOper == 4
	    cMsgRet	:= "O motivo não poderá ser alterado pois já existe um motivo cadastrado com esse nome."     
    EndIf

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTmpQuery, .T., .T.)
      
	If (cTmpQuery)->QTDZ01 > 0
		HELP(,, 'Motivo HFI',, cMsgRet, 1, 0)
		lRet := .F.
	EndIf
	
EndIf
*/

If Select(cTmpQuery) > 0
	(cTmpQuery)->(DbCloseArea())
EndIf
	
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIIWLOG

Rotina para geração do Log da Interface de Integração Protheus x Wis.

@author Allan Constantino Bonfim
@since  06/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIIWLOG(nOper, aDadosLog, cAliasA, nRecOri, cEmpWis, cFilWis, cCodigo, cItem, cSituac, cFuncao, cInterf, cTpOcorr, cErro, cErroTec, cObserv, cSolucao, cStatus, cAcao, cUsrAcao, dDtAcao, cHrAcao)

Local aArea			:= GetArea()
Local lRet				:= .T.
Local aLog				:= {}
Local cModel			:= "WWIS0002"
Local cIdMdlId		:= "ZWH_LOG"

Private oMdlZWH
Private lMsErroAuto	:= .F.
Private aRotina		:= MENUDEF()

Default aDadosLog		:= {}
Default nOper 		:= 1
Default nRecOri		:= 0
Default cEmpWis		:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', '')) 
Default cFilWis		:= PADL(FWCodFil(), 3, "0") 
Default cCodigo		:= ""
Default cItem			:= ""
Default cSituac		:= ""
Default cFuncao		:= ""
Default cInterf		:= "" 
Default cTpOcorr		:= ""
Default cErro			:= ""
Default cErroTec		:= ""
Default cObserv		:= ""
Default cSolucao		:= ""
Default cStatus		:= ""
Default cAcao			:= ""
Default cUsrAcao		:= ""
Default dDtAcao		:= CTOD("")
Default cHrAcao		:= ""


If EMPTY(aDadosLog)
	AADD(aDadosLog, {"ZWH_FILIAL"	, xFilial("ZWH"), Nil})
	AADD(aDadosLog, {"ZWH_EMPRES"	, cEmpWis, Nil})
	AADD(aDadosLog, {"ZWH_DEPOSI"	, cFilWis, Nil})
	AADD(aDadosLog, {"ZWH_CODIGO"	, cCodigo, Nil})
	AADD(aDadosLog, {"ZWH_ITEM"		, cItem, Nil})
	AADD(aDadosLog, {"ZWH_SITUAC"	, cSituac, Nil})
	AADD(aDadosLog, {"ZWH_STATUS"	, cStatus, Nil})
	AADD(aDadosLog, {"ZWH_DATA"		, dDatabase, Nil})
	AADD(aDadosLog, {"ZWH_HORA"		, Substr(TIME(),1, TamSx3("ZWH_HORA")[01]), Nil})
	AADD(aDadosLog, {"ZWH_TPOCOR"	, cTpOcorr, Nil})			
	AADD(aDadosLog, {"ZWH_ERRO"		, cErro, Nil})
	AADD(aDadosLog, {"ZWH_ERRTEC"	, cErroTec, Nil})
   	AADD(aDadosLog, {"ZWH_OBSERV"	, cObserv, Nil})
	AADD(aDadosLog, {"ZWH_SOLUCA"	, cSolucao, Nil})	
	AADD(aDadosLog, {"ZWH_ACAO"		, cAcao, Nil})
	
	If !EMPTY(cAcao)
		AADD(aDadosLog, {"ZWH_USUARI"	, IIF (EMPTY(cUsrAcao), cUserName, cUsrAcao), Nil})
		AADD(aDadosLog, {"ZWH_DATACT"	, IIF (EMPTY(dDtAcao), dDatabase, dDtAcao) , Nil})
		AADD(aDadosLog, {"ZWH_HORACT"	, IIF (EMPTY(cHrAcao), Substr(TIME(),1, TamSx3("ZWH_HORA")[01]), cHrAcao), Nil}) 
	EndIf
	
	AADD(aDadosLog, {"ZWH_CALIAS"	, cAliasA, Nil})
	AADD(aDadosLog, {"ZWH_RECORI"	, nRecOri, Nil})		
	AADD(aDadosLog, {"ZWH_INTERF"	, cInterf, Nil})
	AADD(aDadosLog, {"ZWH_FUNAME"	, cFuncao, Nil})	  
EndIf

lRet := Len(aDadosLog) > 0

If lRet	
	oMdlZWH 	:= FWLoadModel(cModel)
	
	FWMVCRotAuto(oMdlZWH, "ZWH", nOper, {{cIdMdlId, aDadosLog}}, .T.) //Model //Alias //Operacao //Dados

    //Se houve erro no ExecAuto, mostra mensagem
    If lMsErroAuto     	
     	// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior
     	     	
     	aLog := oMdlZWH:GetErrorMessage()
     	//ConOut("WWIS0002 - Erro: "+AllToChar(aLog[6]+" "+AllToChar(aLog[4]+Dtoc(DATE())+" - "+Time())))   
     	/*
     	RecLock("ZWH", .T.)
     		ZWH->ZWH_FILIAL	:= xFilial("ZWH")
     		ZWH->ZWH_TABELA	:= cAliasA
     		ZWH->ZWH_RECNO	:= nRecOri
     		ZWH->ZWH_CODIGO	:= cCodigo
     		ZWH->ZWH_ITEM		:= cItem
     		ZWH->ZWH_FUNAME	:= cFuncao
     		ZWH->ZWH_INTERF	:= cInterf
     		ZWH->ZWH_ERRO		:= cErro
     		ZWH->ZWH_SOLUCA	:= cSolucao
     		ZWH->ZWH_OBSERV	:= cObserv
     		ZWH->ZWH_STATUS	:= cStatus 
     		ZWH->ZWH_DATA		:= dDatabase
     		ZWH->ZWH_HORA		:= Substr(TIME(),1, TamSx3("ZWH_HORA")[01])	   		     	
     	ZWH->(MsUnlock())
     	     	 
     	RecLock("ZWH", .T.)
     		ZWH->ZWH_FILIAL	:= xFilial("ZWH")
     		ZWH->ZWH_TABELA	:= "ZWH"
     		ZWH->ZWH_RECNO	:= 0
     		ZWH->ZWH_CODIGO	:= cCodigo
     		ZWH->ZWH_ITEM		:= ""
     		ZWH->ZWH_FUNAME	:= "WIIWLOG"
     		ZWH->ZWH_INTERF	:= ""
     		ZWH->ZWH_ERRO		:= AllToChar(aLog[6]+" "+AllToChar(aLog[4]+Dtoc(DATE())+" - "+Time()))
     		ZWH->ZWH_SOLUCA	:= AllToChar(aLog[7])
     		ZWH->ZWH_OBSERV	:= AllToChar(aLog[1]+" - "+aLog[2]+" - "+aLog[3]+" - "+aLog[4]+" - "+aLog[5]+" - "+aLog[6]+" - "+aLog[7]+" - "+aLog[8]+" - "+aLog[9])
     		ZWH->ZWH_STATUS	:= "00" 
     		ZWH->ZWH_DATA		:= dDatabase
     		ZWH->ZWH_HORA		:= Substr(TIME(),1, TamSx3("ZWH_HORA")[01])	   		     	
     	ZWH->(MsUnlock())    
     	*/ 	
    EndIf
    
	oMdlZWH:Deactivate()
	oMdlZWH:Destroy()	
	FreeObj(oMdlZWH)
	oMdlZWH 	:= NIL
	aSize(aDadosLog,0)
	aDadosLog	:= NIL
		
 EndIf
 
RestArea(aArea)

Return lRet