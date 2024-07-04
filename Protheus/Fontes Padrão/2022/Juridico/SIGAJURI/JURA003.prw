#INCLUDE "JURA003.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA003
Cadastro de Relatórios

@author Clovis E. Teixeira dos Santos
@since 11/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA003()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias("NQR")
oBrowse:SetLocate()
oBrowse:DisableDetails()
JurSetLeg(oBrowse,"NQR")
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
@since 11/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA003", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA003", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA003", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA003", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA003", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0011, "JA003CONFG"     , 0, 3, 0, NIL } ) // "Config. Inicial"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Cadastro de Relatórios

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA003" )
Local oStruct := FWFormStruct( 2, "NQR" )

JurSetAgrp( 'NQR',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA003_VIEW", oStruct, "NQRMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA003_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Cadastro de Relatórios"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Cadastro de Relatórios

@author Clovis E. Teixeira dos Santos
@since 28/04/09
@version 1.0

@obs NQRMASTER - Dados de 	Cadastro de Relatórios

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NQR" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA003", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQRMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados Cadastro de Relatórios"
oModel:GetModel( "NQRMASTER" ):SetDescription( STR0009 ) // "Dados Cadastro de Relatórios"

JurSetRules( oModel, 'NQRMASTER',, 'NQR' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA003CONFG
Inclusão de configuração inicial de relatório

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 07/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA003CONFG()
Local aArea      := GetArea()
Local lRet       := .T.
Local lCadPadrao := .T.
Local oModel     := ModelDef()
Local aDados     := {}
Local nI         := 0

If ApMsgYesNo( STR0013 ) //"Serão incluídos novos relatórios padrão. Deseja continuar?"
	//Configuração dso relatórios     
	If lRet .And. !JA003EXREL("JURD001", '2')
		aAdd( aDados, { 'JURD001', '2' } )
	EndIf
	If lRet .And. !JA003EXREL("JURD002", '2')
		aAdd( aDados, { 'JURD002', '2' } )
	EndIf
	If lRet .And. !JA003EXREL("JURD003", '2')
		aAdd( aDados, { 'JURD003', '2' } )
	EndIf
	If lRet .And. !JA003EXREL("JURR095", '3')
		aAdd( aDados, { 'JURR095', '3' } )
	EndIf
	If lRet .And. !JA003EXREL("JURR095M", '3')
		aAdd( aDados, { 'JURR095M', '3' } )
	EndIf
	If lRet .And. !JA003EXREL("JURR095S", '3')
		aAdd( aDados, { 'JURR095S', '3' } )
	EndIf
	If lRet .And. !JA003EXREL("JURR124", '3')
		aAdd( aDados, { 'JURR124', '3' } )
	EndIf
	
	If Len(aDados) > 0
		oModel:SetOperation( 3 )
		For nI := 1 To Len( aDados )
			oModel:Activate()

			If !oModel:SetValue("NQRMASTER",'NQR_NOMRPT',aDados[nI][1]) .Or. ;
			   !oModel:SetValue("NQRMASTER",'NQR_EXTENS',aDados[nI][2])
				lRet := .F.
				JurMsgErro( STR0010 ) //Erro na carga da configuração inicial
				Exit
			Else
				lCadPadrao := .F.
			EndIf

			If	lRet
				JA003Grava(oModel, lRet)
			EndIf

		  oModel:DeActivate()
		Next
	EndIf

	If lCadPadrao	                 
		lRet := .F.
		JurMsgErro( STR0012 ) //Não é possível realizar a carga inicial, já existe configuração.
	EndIf

EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA003Grava
Grava a configuração de tabela

@Param oModel	Model ativo
@Param lRet		.T./.F. As informações são válidas ou não

@author Jorge Luis Branco Martins Junior
@since 07/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA003Grava(oModel, lRet) 
Local aErro:= {}

If lRet
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6])
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA003EXREL
Valida se o Relatório já está configurada na NQR

@Param cRelat	Relatório que será validado na NQR

@Return lRet	 	.T./.F. Se a tabela existe ou não na configuração.

@author Jorge Luis Branco Martins Junior
@since 07/02/14
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA003EXREL(cRelat, cExtens)
Local lRet := .F.
Local aArea    := GetArea()
Local aAreaNQR := NQR->( GetArea() )

dbSelectArea('NQR')
dbSetOrder(2)

//cRelat += Space( TamSX3('NQR_NOMRPT')[1] - Len( cRelat ))

If dbSeek(xFilial('NQR') + cRelat)
	If NQR->NQR_EXTENS == cExtens
		lRet := .T.
	EndIf
Endif

RestArea(aAreaNQR)
RestArea(aArea)
	
Return lRet