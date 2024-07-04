#INCLUDE "JURA022.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA022
Tipo de Acao do Processo

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA022()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQU" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQU" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA022", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA022", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA022", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA022", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA022", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0010, "Processa( {||  JA022Ws()}, 'Aguarde', 'Carregando...', .F. )" , 0, 3, 0, NIL } ) // "Config. Inicial"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Acao do Processo

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA022" )
Local oStruct := FWFormStruct( 2, "NQU" )

JurSetAgrp( 'NQU',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA022_VIEW", oStruct, "NQUMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA022_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Tipo de Acao do Processo"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Acao do Processo

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0

@obs NQUMASTER - Dados do Tipo de Acao do Processo

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NQU" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA022", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA022Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQUMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo de Acao do Processo"
oModel:GetModel( "NQUMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo de Acao do Processo"

JurSetRules( oModel, 'NQUMASTER',, 'NQU' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA022Commit
Commit de dados de Tipo de Ação

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA022Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQUMASTER","NQU_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3 .AND. !IsInCallStack("JA022Ws")
		lRet := JurSetRest('NQU',cCod)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA022Ws(oWs, nItemSeq, cHrqCNJ )
Carrega itens do Web Service tipo de ação CNJ

@author Wellington Coelho
@since 02/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA022Ws(oWs, nItemSeq, cHrqCNJ )
Local aNivel1 := {}
Local nI := 0
Local cTipoAcao := ""
Local lRet := .T.

Default oWs := WSsgt_ws_methodsService():New()
Default nItemSeq := 0
Default cHrqCNJ := ""

oWs:nseqItem := nItemSeq
oWs:ctipoItem := "C"

oWs:getArrayFilhosItemPublicoWS()//Carrega Array com primeiro nivel

aNivel1 := aClone(oWs:oWSgetArrayFilhosItemPublicoWSreturn:oWsArvoregenerica)//Copia do array para ser utilizado caso tenha chamada recursiva

If Len(aNivel1) > 0

	If Len(aNivel1) > 1 .OR. aNivel1[1]:nseq_elemento != Nil //Verifica é o ultimo nivel
		For nI := 1 To Len(aNivel1)
			If !EMPTY(cHrqCNJ)
				cHrqCNJ += " \ "
			EndIf
	
			cHrqCNJ += aNivel1[nI]:CDSC_ELEMENTO
			nItemSeq := aNivel1[nI]:nseq_elemento
	
			JA022Ws(oWs, nItemSeq, @cHrqCNJ )
		Next
	
		cHrqCNJ := subStr(cHrqCNJ,1,RAT(" \ ", cHrqCNJ)-1)//Volta um nivel a hierarquia
	
	Else
		JA022CFG(nItemSeq, @cHrqCNJ) //Grava os dados no modelo.
	EndIf
Else
	ApMsgInfo(STR0011)//"Verificar a conexão do servidor do Protheus com a Internet, para acesso ao servidor do CNJ."
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA022CFG(nItemSeq, cHrqCNJ )
Rotina que faz a chamada do processamento da carga inicial

@author Wellington Coelho
@since 02/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA022CFG(nItemSeq, cHrqCNJ )
Local oModel  := FWLoadModel("JURA022")
Local cCodCNJ := ""
Local aErro   := {}
Local cDesc   := ""

cDesc := subStr(cHrqCNJ,RAT(" \ ", cHrqCNJ)+2,length(cHrqCNJ)) //Guarda ultimo nivel da hierarquia, para que seja gravado no campos de descrição

cHrqCNJ := subStr(cHrqCNJ,1,RAT(" \ ", cHrqCNJ)-1) //Retira ultimo nivel da hierarquia

NQU->(DBSetOrder(3))
If !NQU->(DBSeek(xFILIAL('NQU') + CVALTOCHAR(nItemSeq))) //verifica se o tipo de ação já esta cadastrado

	oModel:SetOperation( 3 )
	oModel:Activate()
	
	oModel:SetValue("NQUMASTER",'NQU_DESC'  ,cDesc)
	oModel:SetValue("NQUMASTER",'NQU_CODCNJ',CVALTOCHAR(nItemSeq))
	oModel:SetValue("NQUMASTER",'NQU_HRQCNJ',cHrqCNJ)
	oModel:SetValue("NQUMASTER",'NQU_ORIGEM',"1")
	
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6])
	EndIf

	oModel:DeActivate()
	
EndIf

Return Nil