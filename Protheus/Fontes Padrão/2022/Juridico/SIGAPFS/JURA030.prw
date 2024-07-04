#INCLUDE "JURA030.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA030
Fechamento de Período

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA030()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NVQ" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NVQ" )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [[n,2] Nome da Rotina associada            
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

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local aUserButt := {}

	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA030", 0, 2, 0, NIL } ) // "Visualizar"
	aAdd( aRotina, { STR0010, "JA030SET('1')"  , 0, 4, 0, NIL } ) // "Abrir Período"
	aAdd( aRotina, { STR0011, "JA030SET('2')"  , 0, 4, 0, NIL } ) // "Fechar Período"
	
	If ExistBlock("JURA030")
		aUserButt := ExecBlock("JURA030", .F., .F., {NIL, "MENUDEF", "JURA030"})
		If ValType(aUserButt) == 'A'
			aEval(aUserButt, {|aX|aAdd(aRotina, aX)})
		EndIf
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Historico Tab Honor Padrao

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA030" )
Local oStruct := FWFormStruct( 2, "NVQ" )

	If NVQ->(ColumnPos("NVQ_RECALC")) > 0
		oStruct:RemoveField( 'NVQ_RECALC' )
	EndIf

	JurSetAgrp( "NVQ",, oStruct )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA030_VIEW", oStruct, "NVQMASTER" )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA030_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) // "Historico Tab Honor Padrao"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Historico Tab Honor Padrao

@author David Gonçalves Fernandes
@since 10/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NVQ" )
Local oCommit    := JA030COMMIT():New()

	oStruct:SetProperty( '*'      , MODEL_FIELD_NOUPD, .T. )
	oStruct:SetProperty( 'NVQ_OBS', MODEL_FIELD_NOUPD, .F. )
	If NVQ->(ColumnPos("NVQ_RECALC")) > 0 // @12.1.33
		oStruct:SetProperty( 'NVQ_RECALC', MODEL_FIELD_NOUPD, .F. )
	EndIf

	oModel:= MPFormModel():New( "JURA030", /*Pre-Validacao*/, { | oX | JA030TUDOK( oX ) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "NVQMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Historico Tab Honor Padrao"
	oModel:GetModel( "NVQMASTER" ):SetDescription( STR0009 ) // "Dados de Historico Tab Honor Padrao"
	JurSetRules( oModel, "NVQMASTER",, "NVQ",, "JURA030" )
	
	oModel:InstallEvent("JA030COMMIT", /*cOwner*/, oCommit)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA030TUDOK
Valida as regras do cadastro.

@return lRet       - retorna se as validações foram bem sucedidas ou não

@author David Gonçalves Fernandes
@since 01/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA030TUDOK(oModel)
	Local lRet := .T.
	
	lRet := !Empty(oModel:GetValue("NVQMASTER", "NVQ_OBS"))

	If !lRet
		JurMsgErro(STR0014)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA030SET
Abre ou Fecha o Período de Faturamento

@return lRet       - retorna se as validações foram bem sucedidas ou não
@params cOperation - indica se o período será aberto (1) ou fechado (2)

@author David Gonçalves Fernandes
@since 01/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA030SET(cOperation)
Local lRet     := .T.
Local lConfirm := .F.
Local aArea    :=  GetArea()
Local aAreaNVQ :=  NVQ->( GetArea() )
Local cQuery   := ''
Local cResQRY  := Nil
Local cMsg     := ''

	If cOperation == NVQ->NVQ_SITUAC
		lRet := .F.
		cMsg := IIF(cOperation == "1", STR0012, STR0013) //"Período já está aberto" # "Período já está fechado"
	EndIf

	If lRet
		cQuery := "SELECT COUNT(NVQ.NVQ_COD) QTDNVQ "
		cQuery +=   "FROM " + RetSqlName("NVQ") + " NVQ "
		cQuery +=  "WHERE NVQ.NVQ_MODULO = '" + NVQ->NVQ_MODULO + "' "
		
		If cOperation == "1"
			cQuery += "AND NVQ.NVQ_ANOMES > '" + NVQ->NVQ_ANOMES + "' "
			cQuery += "AND NVQ.NVQ_SITUAC = '2' "
		ElseIf cOperation == '2'
			cQuery += "AND NVQ.NVQ_ANOMES < '" + NVQ->NVQ_ANOMES + "' "
			cQuery += "AND NVQ.NVQ_SITUAC = '1' "
		EndIf

		cQuery += "AND NVQ.D_E_L_E_T_ = ' ' "
		
		cResQRY := GetNextAlias()
		DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

		If (cResQRY)->QTDNVQ > 0
			lRet := .F.
			cMsg := IIF(cOperation == "1", STR0015, STR0016) //"É necessário abrir o período mais recente antes deste." # "É necessário fechar o período mais antigo antes deste"
		EndIf

		(cResQRY)->(DbCloseArea())

	EndIf

	If lRet
		lConfirm := FWExecView(IIf(cOperation == '1', STR0010 /*"Abrir Período"*/, STR0011 /*"Fechar Período"*/), 'JURA030', 4,, {|| .T.}) == 0
	Else
		JurMsgErro(cMsg)
	EndIf

	If lConfirm
		RecLock( 'NVQ', .F. )
		NVQ->NVQ_SITUAC := cOperation
		NVQ->NVQ_USER   := __cUserId
		NVQ->NVQ_DATA   := Date()
		If NVQ->(ColumnPos("NVQ_RECALC")) > 0
			NVQ->NVQ_RECALC := cOperation
		EndIf
		NVQ->(MsUnlock())
		//Grava na fila de sincronização a alteração
		J170GRAVA("NVQ", xFilial("NVQ") + NVQ->NVQ_COD, "4")
		If cOperation == "2" //Quando o período estiver sendo fechado, o sistema deverá criar o subsequente fechado
			JURA203G("FT", Date(), NVQ->NVQ_MODULO, .T.)
		EndIf
	EndIf

	RestArea(aAreaNVQ)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA030COMMIT
Classe interna implementando o FWModelEvent, para execução de função 
durante o commit.

@author Jorge Luis Branco Martins Junior
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA030COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

Method New() Class JA030COMMIT
Return

Method InTTS(oModel, cModelId) Class JA030COMMIT
	JFILASINC(oModel:GetModel(), "NVQ", "NVQMASTER", "NVQ_COD")
Return
