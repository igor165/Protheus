#INCLUDE "JURA073.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static lIntRevis    := (SuperGetMV("MV_JFSINC",.F.,'2') == '1') .And. (SuperGetMV("MV_JREVILD",.F.,'2') == '1' ) //Controla a integracao da revis�o de pr�-fatura com o Legal Desk

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA073
Situa��o de Cobran�a da Pr�

@author David Gon�alves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA073()
Local oBrowse

oBrowse := FWMBrowse():New()
If lIntRevis
	oBrowse:SetDescription( STR0010 ) //"Tipos de Retorno de Revis�o"
Else
	oBrowse:SetDescription( STR0007 ) //"Situa��o de Cobran�a da Pr�"
EndIf
oBrowse:SetAlias( "NSC" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NSC" )
JurSetBSize( oBrowse )
oBrowse:Activate()

If lIntRevis .And. NSC->( FieldPos( "NSC_RESTRI" )) > 0 
	Processa( {|| lRet := J073Carga() } , STR0011, STR0013, .F. ) // "Carga Inicial" "Aguarde..."
EndIf

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author David Gon�alves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA073", 0, 2, 0, NIL } ) // "Visualizar"
If lIntRevis
	aAdd( aRotina, { STR0011, "J073Carga(.T.)", 0, 3, 0, NIL } ) // "Carga Inicial"
EndIf
aAdd( aRotina, { STR0003, "VIEWDEF.JURA073", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA073", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA073", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA073", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Situa��o de Cobran�a da Pr�

@author David Gon�alves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA073" )
Local oStruct := FWFormStruct( 2, "NSC" )

If !lIntRevis .And. ( NSC->( FieldPos( "NSC_RESTRI" )) > 0 )
	oStruct:RemoveField( 'NSC_RESTRI' )
EndIf

JurSetAgrp( 'NSC',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA073_VIEW", oStruct, "NSCMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA073_VIEW", "FORMFIELD" )
If lIntRevis
	oView:SetDescription( STR0010 ) //"Tipos de Retorno de Revis�o"
Else
	oView:SetDescription( STR0007 ) // "Situa��o de Cobran�a da Pr�"
EndIf
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Situa��o de Cobran�a da Pr�

@author David Gon�alves Fernandes
@since 12/05/09
@version 1.0

@obs NSCMASTER - Dados do Situa��o de Cobran�a da Pr�

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NSC" )
Local oCommit    := JA073COMMIT():New()

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
oModel:= MPFormModel():New( "JURA073", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NSCMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Situa��o de Cobran�a da Pr�"
oModel:GetModel( "NSCMASTER" ):SetDescription( STR0009 ) // "Dados de Situa��o de Cobran�a da Pr�"

oModel:InstallEvent("JA073COMMIT", /*cOwner*/, oCommit)

JurSetRules( oModel, 'NSCMASTER',, 'NSC',, "JURA073" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J073Carga
Carga Inicial dos Tipos de Retorno de Revis�o. Utilizado apenas quando 
existe integra��o com a tela de Revis�o do Legal Desk, caso contr�rio 
permanece como Situa��o de Cobran�a da pr�-fatura.

@Param   lManual  Indica se a carga inicial foi chamada manualmente
                    pelo usu�rio (.T.) ou na abertura da tela.

@author Cristina Cintra
@since 16/02/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function J073Carga(lManual)
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaNSC    := NSC->( GetArea() )
Local aNSC        := {}
Local nCt         := 0
Local oModelNSC

Default lManual   := .F.

//Lista de Tipos de Retorno que devem ser inclu�dos por padr�o
aAdd( aNSC, {"0001", "Faturar", "2", "1"} )
aAdd( aNSC, {"0001", "Acumular", "1", "1"} )
aAdd( aNSC, {"0001", "Emitir Minuta", "2", "1"} )
aAdd( aNSC, {"0001", "Ajustes no Faturamento", "1", "1"} )

//Valida se existe algum tipo cadastrado, apenas se n�o existir faz a carga inicial
NSC->( dbSetOrder( 1 ) )
If !NSC->( dbSeek( xFilial( 'NSC' ) ) )

	For nCt := 1 To Len(aNSC)
	
		oModelNSC := FWLoadModel( 'JURA073' )
		oModelNSC:SetOperation( 3 )
		oModelNSC:Activate()
		oModelNSC:SetValue("NSCMASTER","NSC_COD",aNSC[nCt][1])
		oModelNSC:SetValue("NSCMASTER","NSC_DESC",aNSC[nCt][2])
		oModelNSC:SetValue("NSCMASTER","NSC_RESTRI",aNSC[nCt][3])
		oModelNSC:SetValue("NSCMASTER","NSC_ATIVO",aNSC[nCt][4])
		
		If oModelNSC:VldData()
			oModelNSC:CommitData()
		Else
			lRet := .F.	
		Endif
			
		oModelNSC:DeActivate()
	Next nCt
Else
	If lManual
		lRet := .F.
		ApMsgInfo(STR0012) //"N�o foi poss�vel executar a carga inicial pois j� existem dados cadastrados!"
	EndIf
EndIf

RestArea(aAreaNSC)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA073COMMIT
Classe interna implementando o FWModelEvent, para execu��o de fun��o 
durante o commit.

@author Cristina Cintra Santos
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA073COMMIT FROM FWModelEvent
    Method New()
    Method InTTS()
End Class

Method New() Class JA073COMMIT
Return

Method InTTS(oSubModel, cModelId) Class JA073COMMIT
	JFILASINC(oSubModel:GetModel(), "NSC", "NSCMASTER", "NSC_COD")
Return
