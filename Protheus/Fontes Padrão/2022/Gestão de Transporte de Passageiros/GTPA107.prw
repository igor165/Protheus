#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE 'gtpa107.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA107()
Browse da Tabela GQG
@sample		GTPA107()
@author		Inovação - Serviços
@since		15/09/15
@version	P12
/*/
//-------------------------------------------------------------------
Function GTPA107(lHist)
	
Local oBrowse 	:= FWMBrowse():New()
Local aLegAdic	:= {}
Default lHist := .F.

oBrowse:SetAlias('GQG')

If !lHist
	oBrowse:CleanFilter()
	oBrowse:SetFilterDefault ( "GQG_MOVTO == '1' .Or. GQG_MOVTO == '2' .Or. GQG_MOVTO == '3' .Or. GQG_MOVTO == '5'")
	//--------------------------------------
	// Adiciona as legendas no browse - Status da Remessa
	//--------------------------------------
	oBrowse:AddLegend( "GQG_MOVTO == '1'","GREEN"	,	OemToAnsi(STR0019) )	// "Remessa"
	oBrowse:AddLegend( "GQG_MOVTO == '2'","BLUE"	,	OemToAnsi(STR0020) )	// "Transferido"
	oBrowse:AddLegend( "GQG_MOVTO == '3'","RED"		,	OemToAnsi(STR0021) )	// "Cancelado"
	oBrowse:AddLegend( "GQG_MOVTO == '5'","ORANGE"		,	OemToAnsi(STR0097) )	// "Remessa Devolvida"

	//--------------------------------------
	// Legenda adicional no browse - Status do Protocolo
	//--------------------------------------
	aLegAdic := {"",{||TP107RegL()  },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| TP107LEG() },,,,.F.}
	oBrowse:AddColumn(aLegAdic)	
Else
	If GQG->GQG_MOVTO == '3'
		oBrowse:CleanFilter()
		oBrowse:SetFilterDefault ( "GQG_MOVTO == '4' .AND. GQG_LOTANT == " + "'" + GQG->GQG_LOTANT + "'" + ;
		".Or." + "'" + GQG->GQG_LOTE + "'" + " == GQG->GQG_LOTANT ")
	ElseIf GQG->GQG_MOVTO == '1' .OR. GQG->GQG_MOVTO == '2'
	    oBrowse:CleanFilter()
		oBrowse:SetFilterDefault ( "GQG_MOVTO == '4' .AND. GQG_LOTANT == " + "'" + GQG->GQG_LOTE + "'")
	EndIf 
	
Endif

//--------------------------------------
// Adiciona botões no browse
//--------------------------------------
If !FwIsInCall('GTPA107HIS')
	oBrowse:AddButton( STR0096	, {|| GTPA107HIS(),GA107Filt(oBrowse)}) // "Historico"
	oBrowse:AddButton(STR0022	, {|| TP107MNT(1), GA107Filt(oBrowse) }) // Baixa Protocolo
	oBrowse:AddButton(STR0023	, {|| TP107MNT(2), GA107Filt(oBrowse) }) // Estorno  Protocolo
	oBrowse:AddButton(STR0024	, {|| TP107MNT(3), GA107Filt(oBrowse) }) // Estorno Cancelamento
	oBrowse:AddButton(STR0025	, {|| GTPR107A() } ) // Imprimir Protocolo
EndIf

oBrowse:SetDescription(STR0001)
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@sample		ModelDef()

@return		oModel 		Objeto do Model

@author		Inovação
@since		13/03/2017
@version	P12

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	
Local oModel    := Nil
Local oStruGQG  := FWFormStruct(1,'GQG')

SetModelStruct(oStruGQG)

oModel	:= MPFormModel():New('GTPA107',/*PreValidacao*/,{ |oModel|TP107TDOK(oModel)},{|oModel|TP107GRV(oModel)})
oModel:AddFields('GQGMASTER',/*cOwner*/,oStruGQG)
oModel:SetPrimaryKey({"GQG_FILIAL","GQG_DATA"})
oModel:SetDescription(STR0001)
	
Return oModel


//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct
Função responsavel pela estrutura do modelo
@type Static Function
@author jacomo.fernandes
@since 12/08/2019
@version 1.0
@param oStrGI8, object, (Descrição do parâmetro)
@return nil, Retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGQG)
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

oStruGQG:AddTrigger("GQG_NUMCOM"     ,"GQG_NUMCOM"      ,{||.T.}   ,bFldTrig)	 
oStruGQG:AddTrigger("GQG_NUMINI"     ,"GQG_NUMINI"      ,{||.T.}   ,bFldTrig)	 
oStruGQG:AddTrigger("GQG_NUMFIM"     ,"GQG_NUMFIM"      ,{||.T.}   ,bFldTrig)	 

oStruGQG:SetProperty('GQG_NUMINI'    ,MODEL_FIELD_VALID  ,bFldVld)
oStruGQG:SetProperty('GQG_NUMFIM'    ,MODEL_FIELD_VALID  ,bFldVld)

Return nil


//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldTrigger
Função responsavel pelas trigger do modelo
@type Static Function
@author jacomo.fernandes
@since 12/08/2019
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@return nil, Retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
    Case cField == "GQG_NUMCOM"
        oMdl:SetValue('GQG_NUMINI',TP107Prox(oMdl))
    Case cField == "GQG_NUMINI" .or. cField == "GQG_NUMFIM"
        uVal    := StrZero(Val(uVal), TamSx3(cField)[1])
        oMdl:LoadValue(cField,uVal)
EndCase

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
    Case Empty(uNewValue)
        lRet := .T.
    Case cField == "GQG_NUMINI" .or. cField == "GQG_NUMFIM"
        If Val(uNewValue) < 1
            lRet        := .F.
            cMsgErro    := STR0106//"Numero informado não é valido"
            cMsgSol     := STR0107//"Informe um numero acima de 1"
        Endif
        IF !Empty(oMdl:GetValue('GQG_NUMINI')) .and. !Empty(oMdl:GetValue('GQG_NUMFIM'))
            IF Val(oMdl:GetValue('GQG_NUMINI')) >  Val(oMdl:GetValue('GQG_NUMFIM'))
                lRet        := .F.
                cMsgErro    := STR0108//"Numero inicial informado é maior que o numero final"
                cMsgSol     := STR0109//"Informe um numero final maior que o numero inicial"
            Endif
        Endif
   
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@sample		ViewDef()
@return		oView		Retorna objeto da interface
@author		Inovação
@since		13/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	
Local oModel	:= FWLoadModel('GTPA107')
Local oStruGQG	:= FWFormStruct(2,'GQG', {|cCampo| AllTrim(cCampo) + '|' $ "GQG_LOTE|GQG_DTREM|GQG_TIPO|GQG_TPDESC|GQG_COMPLE|GQG_TIPPAS|GQG_PROTOC|" + ;
					"GQG_DTBXP|GQG_SERIE|GQG_SUBSER|GQG_NUMCOM|GQG_NUMINI|GQG_NUMFIM|GQG_QUANT|GQG_AGENCI|GQG_NAGENC|GQG_COLABO|GQG_NCOLAB|"})
Local oView
Local nX	:= 0

// Ordena os campos na tela

oStruGQG:SetProperty( 'GQG_LOTE'	, MVC_VIEW_ORDEM,	'01')
oStruGQG:SetProperty( 'GQG_DTREM'	, MVC_VIEW_ORDEM,	'02')
oStruGQG:SetProperty( 'GQG_TIPO'	, MVC_VIEW_ORDEM,	'03')
oStruGQG:SetProperty( 'GQG_TPDESC'	, MVC_VIEW_ORDEM,	'04')
oStruGQG:SetProperty( 'GQG_COMPLE'	, MVC_VIEW_ORDEM,	'05')
oStruGQG:SetProperty( 'GQG_TIPPAS'	, MVC_VIEW_ORDEM,	'06')
oStruGQG:SetProperty( 'GQG_PROTOC'	, MVC_VIEW_ORDEM,	'07')
oStruGQG:SetProperty( 'GQG_DTBXP'	, MVC_VIEW_ORDEM,	'08')

oStruGQG:SetProperty( 'GQG_SERIE'	, MVC_VIEW_ORDEM,	'10')
oStruGQG:SetProperty( 'GQG_SUBSER'	, MVC_VIEW_ORDEM,	'11')
oStruGQG:SetProperty( 'GQG_NUMCOM'	, MVC_VIEW_ORDEM,	'12')
oStruGQG:SetProperty( 'GQG_NUMINI'	, MVC_VIEW_ORDEM,	'13')
oStruGQG:SetProperty( 'GQG_NUMFIM'	, MVC_VIEW_ORDEM,	'14')		
oStruGQG:SetProperty( 'GQG_QUANT'	, MVC_VIEW_ORDEM,	'15')

oStruGQG:SetProperty( 'GQG_AGENCI'	, MVC_VIEW_ORDEM,	'21')
oStruGQG:SetProperty( 'GQG_NAGENC'	, MVC_VIEW_ORDEM,	'22')	
oStruGQG:SetProperty( 'GQG_COLABO'	, MVC_VIEW_ORDEM,	'23')
oStruGQG:SetProperty( 'GQG_NCOLAB'	, MVC_VIEW_ORDEM,	'24')

// Crio os Agrupamentos de Campos
oStruGQG:AddGroup( 'GRUPO1', '', '', 1 )
oStruGQG:AddGroup( 'GRUPO2', STR0095, '', 2 )  // "Lote"
oStruGQG:AddGroup( 'GRUPO3', STR0094, '', 3 ) //"Destinatário"

For nX := 1 To Len(oStruGQG:aFields) // Campos da tabela GQG
	
	//-- Define os campos para determinado grupo
	If oStruGQG:aFields[nX][VIEWS_VIEW_ID] $ "GQG_LOTE,GQG_DTREM,GQG_TIPO,GQG_TPDESC,GQG_COMPLE,GQG_TIPPAS,GQG_PROTOC,GQG_DTBXP"
		oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
	ElseIf oStruGQG:aFields[nX][VIEWS_VIEW_ID] $ "GQG_SERIE,GQG_SUBSER,GQG_NUMCOM,GQG_NUMINI,GQG_NUMFIM,GQG_QUANT"
		oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' )
	ElseIf oStruGQG:aFields[nX][VIEWS_VIEW_ID] $ "GQG_AGENCI,GQG_NAGENC,GQG_COLABO,GQG_NCOLAB"
		oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO3' )
	EndIf
	
Next nX

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW',oStruGQG,'GQGMASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW','TELA')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@sample		MenuDef()
@return		aRotina   Array contendo as opções do Menu
@author		Inovação
@since		13/03/2017
@version	P12
/*/
Static Function MenuDef()
	
Local aRotina := {}

ADD OPTION aRotina TITLE STR0008 	ACTION 'VIEWDEF.GTPA107'  OPERATION 2 ACCESS 0 // #Visualizar Remessa

If !FwIsInCall('GTPA107HIS')
	ADD OPTION aRotina TITLE STR0009	ACTION 'VIEWDEF.GTPA107'  OPERATION 3 ACCESS 0 // #Incluir Remessa
	ADD OPTION aRotina TITLE STR0010 	ACTION 'TP107MNU(1)'  OPERATION 3 ACCESS 0 // #Transferir Remessa
	ADD OPTION aRotina TITLE STR0027	ACTION 'TP107MNU(2)'  OPERATION 3 ACCESS 0 // #Cancelar Remessa
	ADD OPTION aRotina TITLE STR0093	ACTION 'TP107MNU(3)'  OPERATION 3 ACCESS 0 // #Devolução de Remessa
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107MNU
Realiza a execução da ExecView
@sample		TP107MNU()
@return		nOpc = 1 - Transferencia 2= Cancelamento
@author		Inovação
@since		13/03/2017
@version	P12
/*/
Function TP107MNU(nOpc)

Local lRet := .T.

If nOpc = 1 // Transferir Remessa

	lRet := FWExecView( STR0010 , "VIEWDEF.GTPA107B", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Transferencia"
					{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
ElseIf nOpc = 2 // Cancelar Remessa

	lRet := FWExecView( STR0027 , "VIEWDEF.GTPA107C", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Cancelamento"
					{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
					
ElseIf nOpc = 3 // Devolver Remessa

	lRet := FWExecView( STR0093, "VIEWDEF.GTPA107D", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Devolução de Remessa"
					{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107TDOK
@sample		TP107TDOK()
@return		
@author		Inovação
@since		13/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function TP107TDOK(oModel)

Local oMdlGQG       := oModel:GetModel('GQGMASTER')
Local lRet			:= .T.
Local cTpDoc		:= oMdlGQG:GetValue('GQG_TIPO')
Local cComple		:= oMdlGQG:GetValue('GQG_COMPLE')
Local cTipPas		:= oMdlGQG:GetValue('GQG_TIPPAS')
Local cSerie		:= oMdlGQG:GetValue('GQG_SERIE')
Local cSubSer		:= oMdlGQG:GetValue('GQG_SUBSER')
Local cNumCom		:= oMdlGQG:GetValue('GQG_NUMCOM')
Local cNumIni		:= oMdlGQG:GetValue('GQG_NUMINI')
Local cNumFim		:= oMdlGQG:GetValue('GQG_NUMFIM')
Local cStatus		:= "1,8" //-- Abertura
Local dDtEmiss      := oMdlGQG:GetValue('GQG_DTREM')

If oModel:GetOperation() == MODEL_OPERATION_INSERT	
	
//---------------------------------------------------	
// VERIFICA SE O RANGE INFORMADO ESTA APTO PARA REMESSA
//---------------------------------------------------	
	If !GTPDISPRANGE(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,cStatus)
		Help(" ",1,STR0079,,STR0028,1,0) 
		lRet := .F.
	EndIf

    If lRet .and. !G102DTVENC(cTpDoc, cSerie, cSubSer, cNumCom, cNumIni, cNumFim, dDtEmiss)
        lRet := .F.
        Help(" ",1,'G102DTVENC',,STR0110,1,0) //'Lote de documentos informados não se encontra dentro da validade dos registros'
    Endif

ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
//---------------------------------------------------	
// PERMITE A EXCLUSÃO DA REMESSA QUANDO STATUS = 1
//---------------------------------------------------	
	//-- Permite a exclusão da remessa, apenas com o status 1 - Remessa.
	If GQG->GQG_MOVTO != "1"
		Help(" ",1,STR0079,,STR0029,1,0) 
    lRet := .F.
	EndIf
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107GRV
Função para Commit do modelo

@sample		TP107GRV(oModel)

@return		lRet   Logico operação foi realizada com sucesso

@param      oModel oBjeto Model do Programa

@author		Inovação
@since		09/03/2017
@version	P12

/*/
//-------------------------------------------------------------------
Static Function TP107GRV(oModel)
	
Local aArea		:= GetArea()
Local oMdlGQG 	:= oModel:GetModel('GQGMASTER')
Local cLotRem 	:= oMdlGQG:GetValue('GQG_LOTE')
Local dDtRem   	:= oMdlGQG:GetValue('GQG_DTREM')
Local cAgenc  	:= oMdlGQG:GetValue('GQG_AGENCI')
Local cTipo   	:= oMdlGQG:GetValue('GQG_TIPO')
Local cComple  	:= oMdlGQG:GetValue('GQG_COMPLE')
Local cTipPas  	:= oMdlGQG:GetValue('GQG_TIPPAS')
Local cSerie  	:= oMdlGQG:GetValue('GQG_SERIE')
Local cSubSer 	:= oMdlGQG:GetValue('GQG_SUBSER')
Local cNumCom 	:= oMdlGQG:GetValue('GQG_NUMCOM')
Local cNumIni 	:= oMdlGQG:GetValue('GQG_NUMINI')
Local cNumFim 	:= oMdlGQG:GetValue('GQG_NUMFIM')
Local aUpdate  	:= {}
Local lRet		:= .T.

Begin Transaction 
//---------------------------------------------+
// BLOCO PARA EFETIVAR A REMESSA DE DOCUMENTOS |
//---------------------------------------------+
If oModel:VldData() .And. FwFormCommit(oModel)
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		
		AADD(aUpdate,{'GII_AGENCI',cAgenc})
		AADD(aUpdate,{'GII_LOTREM',cLotRem})
		AADD(aUpdate,{'GII_DTREM' ,dDtRem})
		AADD(aUpdate,{'GII_STATUS','2'})
	
		If !( lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate) )			
			DisarmTransaction()		 
		EndIf
		 
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
		
		AADD(aUpdate,{'GII_AGENCI',''})
		AADD(aUpdate,{'GII_DTREM' ,stod("")})
		AADD(aUpdate,{'GII_LOTREM',''})
		
		If !( lRet := GA102ALot(cTipo,cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate) )
			DisarmTransaction()	
		EndIf
	EndIf	

Else
	JurShowErro( oModel:GetModel():GetErrorMessage() )		
	DisarmTransaction()
	lRet	:= .F.
EndIf	

//---------------------------------------------+
// IMPRESSÃO DO RELATORIO PROTOCOLO DE REMESSA |
//---------------------------------------------+
If lRet 
	if !isBlind()
		If MsgYesNo(STR0030,STR0031 )//"Deseja imprimir o Protocolo de Controle de Documentos?" #"Impressão de Protocolo."
			Processa( {||GTPR107A()},STR0032,STR0033 ) //""Protocolo Controle de Documentos" #"Imprimindo..."
		EndIf
	endif
EndIf

RestArea(aArea)

End Transaction

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TP107MNT
Valida Baixa/Estorno e protocolo/cancelamento 	 
@sample	  TP107MNT(nOpc)
@param   
nOpc 	- Caracter - opção 

@return	 - Logico - lRet - Retorna .T. Valida Baixa/Estorno e protocolo/cancelamento 	 
@author		Inovação
@since		09/03/2017/
@version	P12
/*/
Function TP107MNT(nOpc)

Local cMsg	:= ""
Local cMsg2 := ""
Local lRet	:= .T.
Local nRecAtu := 0

//-- Se há remessa
If !Empty(GQG->GQG_LOTE)

	If nOpc == 1
		cMsg := STR0034//Tem certeza que deseja realizar a baixa do protocolo de remessa?
		cMsg2:= STR0035//Baixa do Protocolo
		//-----------------------------
		// VALIDA BAIXA DO PROTOCOLO
		//-----------------------------
		If ( lRet := FwAlertYesNo("",cMsg) )
			If GQG->GQG_PROTOC == "2"
				FwAlertWarning(STR0080,STR0035)//
				lRet := .F.
			EndIf
		EndIf
	ElseIf nOpc == 2
		cMsg := STR0036//Tem certeza que deseja realizar o estorno da baixa do protocolo?
		cMsg2:= STR0037//Estorno do Protocolo
		//-----------------------------
		// VALIDA ESTORNO DO PROTOCOLO
		//-----------------------------
		If ( lRet := FwAlertYesNo("",cMsg) )
			If GQG->GQG_PROTOC == "1"
				FwAlertWarning(STR0081,STR0037)//Estorno do Protocolo
				lRet := .F.
			EndIf
		EndIf
	ElseIf nOpc == 3	
		cMsg := STR0038//Tem certeza que deseja realizar o estorno do cancelamento?
		cMsg2:= STR0039//Estorno do Cancelamento
		//-----------------------------
		// VALIDA ESTORNO DO CANCELAMENTO
		//-----------------------------
		If ( lRet := FwAlertYesNo("",cMsg) )
			If GQG->GQG_MOVTO != "3"
				FwAlertWarning(STR0040,STR0041)//Estorno Cancelamento
				lRet := .F.
			EndIf
		
		EndIf
	EndIf
	
	//-- PROCESSA MANUTENCAO DA REMESSA
	If lRet 
		Processa({|lEnd| TPExecMnt(nOpc,@nRecAtu)  },cMsg2)
	EndIf		
Else
	HELP(" ",1,"ARQVAZIO")
	lRet := .T.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TPExecMnt
Realiza manutenção da remessa
@sample	  TPExecMnt(nOpc)
@param   
nOpc 	- Caracter - opção 

@return	 - Logico - lRet - Retorna .T. Valida Baixa/Estorno e protocolo/cancelamento 	 
@author		Inovação
@since		09/03/2017/
@version	P12
/*/
Static Function TPExecMnt(nOpc,nRecAtu)

Local cStatusAnt := ""
Local cTipo 	:= ""
Local cComple 	:= ""
Local cTipPas	:= ""
Local cSerie	:= ""
Local cSubSer	:= ""
Local cNumCom	:= ""
Local cNumIni	:= ""
Local cNumFim	:= ""	
Local oMdl107 	:= Nil
Local oSubMdl 	:= Nil
Local cLoteAnt	:= ""
Local aUpdate	:= {}
Local nRecAnt	:= 0
Local nQtdAtu	:= GQG->GQG_QUANT
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()		

If nOpc <= 2
	
	// ATUALIZA OS DADOS DA REMESSA PARA OPER. 1 E 2
	oMdl107 := FwLoadModel("GTPA107")	
	oMdl107:SetOperation(4)
	oMdl107:Activate()

	oSubMdl := oMdl107:GetModel("GQGMASTER")
	
	If nOpc == 1 
		//-- Baixa do protocolo
		If !( lRet := oSubMdl:SetValue("GQG_PROTOC","2") .And. ;
				oSubMdl:SetValue("GQG_USRBXP", __CUSERID ) .And. ;
				oSubMdl:SetValue("GQG_DTBXP", dDataBase ) )			
		EndIf
	ELseIf nOpc == 2
		//-- Estorno do protocolo
		If !( lRet := oSubMdl:SetValue("GQG_PROTOC","1") .And. ;
						oSubMdl:ClearField("GQG_USRBXP") .And. ;
						oSubMdl:ClearField("GQG_DTBXP")	)		
		EndIf								
	EndIf
	
	If lRet .And. oMdl107:VldData()
		If ( lRet := FwFormCommit(oMdl107) )
			MsgInfo(STR0042)//Procesamento concluido
		EndIf 
	Else
		JurShowErro( oMdl107:GetModel():GetErrormessage() )
		lRet := .F.
	EndIf
Else
	//---------------------------------------
	//-- ESTORNO DO CANCELAMENTO DA REMESSA;
	//---------------------------------------
	cTipo 	:= GQG->GQG_TIPO
	cComple := GQG->GQG_COMPLE
	cTipPas	:= GQG->GQG_TIPPAS
	cSerie	:= GQG->GQG_SERIE
	cSubSer	:= GQG->GQG_SUBSER
	cNumCom	:= GQG->GQG_NUMCOM
	cNumIni	:= GQG->GQG_NUMINI
	cNumFim	:= GQG->GQG_NUMFIM	
	cLoteAnt:= GQG->GQG_LOTANT  //Lote Anterior ao Cancelamento
	
	BeginSQL alias cAliasTmp
		SELECT GQG.R_E_C_N_O_ RECGQG FROM %Table:GQG% GQG
			WHERE GQG.GQG_FILIAL  = %xFilial:GQG%
				AND GQG.GQG_LOTE = %Exp:cLoteAnt%
				AND GQG.%NotDel%
	EndSQL
	
	If !(cAliasTmp)->(EOF())
		GQG->(DbGoTo((cAliasTmp)->RECGQG))
		//-- Atualiza Qtdade
		nQtdAtu += GQG->GQG_QUANT
		//-- Guarda dados do lote anterior
		nRecAnt	 := GQG->(Recno())
	
		If GQG->GQG_MOVTO == "4"
			If nQtdAtu > 0 .And. !Empty(GQG->GQG_AGEORI)
				cStatusAnt	:= "4" 
			ElseIf nQtdAtu > 0 .And. Empty(GQG->GQG_AGEORI)
				cStatusAnt	:= "2" 
			EndIf	
		Else								
			//------------------------------------------------------------------------------------------------		
			//Status do movimento Remessa GQG_MOVTO
			//1 = Remessa 2 = Transferência		
			//Status Documento GII_STATUS
			//1=Abertura Lote; 2=Remessa; 3=Cancelamento;4=Tranferência; 5=Alocação; 6=Baixa Alocação
			cStatusAnt := IIF( GQG->GQG_MOVTO == "1","2","4")	
		EndIf
		//-- Dados a serem atualizados na GII
		AADD(aUpdate,{'GII_LOTREM',cLoteAnt})
		AADD(aUpdate,{'GII_DTCANC',CTOD("")})
		AADD(aUpdate,{'GII_STATUS',cStatusAnt}) 
		lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate)
		//------------------------------------------------------------------------------------------------
		// NO ESTORNO DELETA A REMESSA DE CANCELAMENTO E RETORNA
		// A QUANTIDADE DA REMESSA DE ORIGEM
		If lRet
			//-- Forca o posicionamento da remessa anterior ao cancelamento.
			//-- Caso tenha desposicionado
			If nRecAnt != GQG->(Recno())
				DbgoTo(nRecAnt)
			EndIf
			
			RecLock("GQG",.F.)
			GQG->GQG_QUANT := nQtdAtu
			
			If nQtdAtu > 0 .And. !Empty(GQG->GQG_AGEORI)
				GQG->GQG_MOVTO	:= "2" 
			ElseIf nQtdAtu > 0 .And. Empty(GQG->GQG_AGEORI)
				GQG->GQG_MOVTO	:= "1" 
			EndIf
					
			GQG->(MsUnlock())
			
			//-- Retorna o posicionamento p/ Remessa cancelada
			DbGoTo(nRecAtu)
			RecLock("GQG",.F.)
			GQG->GQG_MOVTO	:= "4" 
			GQG->(MsUnlock())		
		EndIf
	EndIf

	(cAliasTmp)->(DbCloseArea())

EndIf
	
Return(lRet)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TP107RegL()
Regra da legenda adicional 
@return  cLegenda - Cor da legenda de cada registro do browse
@author	Lucas.Brustoin 
@since		22/03/2017
@version	12.0
/*/
Static Function TP107RegL()

Local cLegenda		:= ""

	Do Case
		Case GQG->GQG_PROTOC == "1"
			cLegenda := "BR_BRANCO"
		Case GQG->GQG_PROTOC == "2"
			cLegenda := "BR_PRETO"
	EndCase
			
Return(cLegenda)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TP107LEG()
Função para exibir a legenda adicional  
@return   	Nenhum
@author	Lucas.Brustoin 
@since		22/03/2017
@version	12.0
/*/
Static Function TP107LEG()

Local oLegenda  :=  FWLegend():New()
	
oLegenda:Add("" , "BR_BRANCO"	, STR0043) //"Protocolo Pendente"
oLegenda:Add("" , "BR_PRETO"  	, STR0044)//"Protocolo Baixado"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107Prox
Sugere numero de documento com base no tipo de documento informado.

@sample	TP107Prox(cTpDoc)

@param 	cTpDoc    Caracter Tipo do Documento

@author		Inovação
@since		07/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function TP107Prox(oMdl)

Local cAliasTmp     := GetNextAlias()
Local cNum			:= ""
Local cStatus       := "1,8"
Local cTpDoc 		:= oMdl:GetValue("GQG_TIPO")
Local cSerie 		:= oMdl:GetValue("GQG_SERIE")
Local cSubSer       := oMdl:GetValue("GQG_SUBSER")
Local cNumCom		:= oMdl:GetValue("GQG_NUMCOM")
Local cComple		:= oMdl:GetValue("GQG_COMPLE")
Local cTipPas		:= oMdl:GetValue("GQG_TIPPAS")
Local cWhere		:= ""

cWhere += "%  AND GII_STATUS IN " + FormatIn(cStatus,",") + "%"

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
Endif

//-- Busca o final da ultima remessa lançada e soma 1 
BeginSql Alias cAliasTmp

	SELECT MIN(GII_BILHET) AS GII_BILHET FROM %table:GII% GII
	WHERE
		GII_FILIAL		 = %xFilial:GII% 
		AND GII_TIPO   = %Exp:cTpDoc%	
		AND GII_SERIE  = %Exp:cSerie% 
		AND GII_SUBSER = %Exp:cSubSer% 
		AND GII_NUMCOM = %Exp:cNumCom%
		AND GII_COMPLE = %Exp:cComple%
		AND GII_TIPPAS = %Exp:cTipPas%
		AND GII.%NotDel%
		%Exp:cWhere%
		
EndSql

If !Empty((cAliasTmp)->GII_BILHET)

	cNum := (cAliasTmp)->GII_BILHET 
Else

	Help( ,, STR0092,"GTPA107", STR0091, 1, 0 ) // "Lote de Documentos não encontrado" // "Aviso"

Endif

(cAliasTmp)->(DbCloseArea())

Return(cNum)

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA107His
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
Realiza chamada do browse com lista de todos historico
/*/
//-------------------------------------------------------------------
Function GTPA107His()
Return GTPA107(.t.)         

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA107Filt()
Realiza a limpeza do filtro e adiciona novo filtro
 
@return	oModel - Objeto do Model
 
@author	Inovação
@since		20/06/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA107Filt(oBrowse)	
oBrowse:CleanFilter()
oBrowse:SetFilterDefault ( "GQG_MOVTO == '1' .Or. GQG_MOVTO == '2' .Or. GQG_MOVTO == '3'")
oBrowse:Refresh()
RETURN  
