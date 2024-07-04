#INCLUDE "JURA215.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA215
Log Importação Publicações

@author Jorge Luis Branco Martins Junior
@since 24/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA215()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) // Log Importação Publicações
oBrowse:SetAlias( "NZV" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZV" )
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

@author Jorge Luis Branco Martins Junior
@since 24/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA215", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA215", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA215", 0, 8, 0, NIL } ) //"Imprimir"
aAdd( aRotina, { STR0006, "JA215Limpa"     , 0, 4, 0, NIL } ) //"Limpar Log"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Log de Importação de Publicações

@author Jorge Luis Branco Martins Junior
@since 24/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA215" )
Local oStruct := FWFormStruct( 2, "NZV" )

JurSetAgrp( 'NZV',, oStruct )

oStruct:RemoveField("NZV_COD")

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA215_VIEW", oStruct, "NZVMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA215_VIEW", "FORMFIELD" )
oView:SetDescription( STR0001 ) //"Log Importação Publicações"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Natureza Juridica

@author Jorge Luis Branco Martins Junior
@since 24/03/16
@version 1.0

@obs NZVMASTER - Dados do Natureza Juridica

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZV := FWFormStruct( 1, "NZV" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA215", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NZVMASTER", NIL, oStructNZV, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0007 ) //"Modelo de Dados de Log de importação de publicações"
oModel:GetModel( "NZVMASTER" ):SetDescription( STR0008 ) //"Dados de Log de importação de publicações"

JurSetRules( oModel, 'NZVMASTER',, 'NZV' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA215SetLog
Insere o registro com o Log de erro atual

@author Jorge Luis Branco Martins Junior
@since 24/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA215SetLog(cMensagem, cUser, cTime)
Local aArea    := GetArea()
Local lRet     := .T.
Local oModel
Local oModelOld := FWModelActive()

Default cUser := ""

If FWAliasInDic("NZV") //Verifica se existe a tabela NZV - Log Importação Publicações (Proteção)

	oModel := FWLoadModel("JURA215")
	oModel:SetOperation( 3 )
	oModel:Activate()
	
	IIF( lRet, lRet := oModel:SetValue("NZVMASTER","NZV_DATA" , Date()    ), )
	IIF( lRet, lRet := oModel:SetValue("NZVMASTER","NZV_HORA" , cTime     ), )
	IIF( lRet, lRet := oModel:SetValue("NZVMASTER","NZV_LOGIN", cUser     ), )
	IIF( lRet, lRet := oModel:SetValue("NZVMASTER","NZV_DESC" , cMensagem ), )	
	
	If !(lRet .And. oModel:VldData() .And. oModel:CommitData())
		If IsBlind()
			ConOut(STR0009)
		Else
			Alert(STR0009) // Houve um erro na geração do histórico de Log.
		EndIf
	EndIf
	
	oModel:DeActivate()
	oModel:Destroy()
	FwModelActive(oModelOld,.T.)	

EndIf

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA215Limpa
Exibe tela re filtro para limpeza de Log

@author Jorge Luis Branco Martins Junior
@since 28/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA215Limpa()
Local lRet    := .T.
Local aArea   := GetArea()
Local oDtIni, oDtFim, oDlg
Local dDtIni		:= CToD( '  /  /  ' )
Local dDtFim		:= CToD( '  /  /  ' )

	DEFINE MSDIALOG oDlg TITLE STR0010 FROM 233,200 TO 380,510 PIXEL // Limpeza de Log

	oDtIni	:= TJurPnlCampo():New(02,16,50,20,oDlg,STR0011,'NZV_DATA',{|| },{|| },CToD( '01/01/1900' ),,,,)//"Data Inicial"	
	oDtIni:oCampo:bValid     := {|| JA215VldDt(1,oDtIni:Valor,oDtFim:Valor)}

	oDtFim	:= TJurPnlCampo():New(02,95,50,20,oDlg,STR0012,'NZV_DATA',{|| },{|| },Date()-1,,,,)//"Data Final"
	oDtFim:oCampo:bValid	:= {|| JA215VldDt(2,oDtIni:Valor,oDtFim:Valor)}

	@ 032,016 Button STR0019 Size 050,015 PIXEL OF oDlg  Action ( IIf( APMsgYesNo(STR0020), lRet := JA215Del(1), ), oDlg:End()) //Limpar Tudo - Deseja realmente excluir todos os registros do log? 
	@ 032,095 Button STR0013 Size 050,015 PIXEL OF oDlg  Action ( lRet := JA215Del(2,oDtIni:Valor, oDtFim:Valor), oDlg:End()) //Limpar
 	@ 053,095 Button STR0014 Size 050,015 PIXEL OF oDlg  Action oDlg:End() //Sair
	
	ACTIVATE MSDIALOG oDlg CENTERED 

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA112VldDt
Valida a data

@author Jorge Luis Branco Martins Junior
@since 28/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA215VldDt(nData,dDtIni,dDtFim)
Local lRet := .T.

If nData = 1
	If dTos(dDtIni) > dTos(Date())
		lRet := .F.
		ApMsgAlert(STR0015) //'Data Inicial para limpeza do log não pode ser maior que a data atual!'
	EndIf
EndIf	

If lRet .And. !Empty(dTos(dDtIni)) .And. !Empty(dTos(dDtFim))
	If dTos(dDtFim) < dTos(dDtIni)
		lRet := .F.
		ApMsgAlert(STR0016) //'Data Final deve ser maior que a inicial. Verifique!'
	EndIf
EndIf

If lRet .And. nData = 2
	If dTos(dDtFim) > dTos(Date())
		lRet := .F.
		ApMsgAlert(STR0017) //'Data Final para limpeza do log não pode ser maior que a data atual'
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA215Del
Exclui registros do Log

@author Jorge Luis Branco Martins Junior
@since 28/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA215Del(nTipo, dDataIni, dDataFim)
Default dDataIni := CToD( '  /  /  ' )
Default dDataFim := CToD( '  /  /  ' )

dbSelectArea("NZV")
NZV->( dbSetOrder( 1 ) )

If nTipo == 1

	While !NZV->( EOF() )
	
		Reclock( 'NZV', .F. )
		dbDelete()
		MsUnlock()
	
		lRet := DELETED()
		
		If !lRet
			JurMsgErro(STR0018) // Erro ao excluir log
			Exit
		EndIf
	
		NZV->( dbSkip() )
	End

Else

	If Empty(dDataIni) .And. Empty(dDataFim)
		dDataIni := CToD( '01/01/1900' )
		dDataFim := Date()
	ElseIf !Empty(dDataIni) .And. Empty(dDataFim)
		dDataFim := Date()
	ElseIf Empty(dDataIni) .And. !Empty(dDataFim)
		dDataIni := CToD( '01/01/1900' )
	EndIf

	While !NZV->( EOF() ) .AND.;
		NZV->NZV_DATA >= dDataIni .And. NZV->NZV_DATA <= dDataFim
	
		Reclock( 'NZV', .F. )
		dbDelete()
		MsUnlock()
	
		lRet := DELETED()
		
		If !lRet
			JurMsgErro(STR0018) // Erro ao excluir log
			Exit
		EndIf
	
		NZV->( dbSkip() )
	End

EndIf

ApMsgInfo(STR0021) //"Limpeza efetuada com sucesso!"

Return