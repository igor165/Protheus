#INCLUDE "JURA174.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA174
Integra��o tarifador.

@author Cristina Cintra
@since 02/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA174()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Configura��es tarifador"
oBrowse:SetAlias( "NYT" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NYT" )
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

@author Cristina Cintra
@since 02/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "VIEWDEF.JURA174", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "J174INCLUI()",    0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA174", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA174", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View das configura��es de integra��o com o tarifador.

@author Cristina Cintra
@since 02/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA174" )
Local oStructNYT := FWFormStruct( 2, "NYT" )
Local oStructNYU := FWFormStruct( 2, "NYU" )
Local oStructNYV := FWFormStruct( 2, "NYV" )
Local oStructNYY := FWFormStruct( 2, "NYY" )

oStructNYU:RemoveField( "NYU_COD" )
oStructNYU:RemoveField( "NYU_CODCFG" )
oStructNYV:RemoveField( "NYV_CODCFG" )
oStructNYY:RemoveField( "NYY_CODCFG" )
oStructNYY:RemoveField( "NYY_TIPO" )
oStructNYY:RemoveField( "NYY_DTIPO" )

JurSetAgrp( 'NYT',, oStructNYT )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA174_VIEW", oStructNYT, "NYTMASTER"  )
oView:AddGrid(  "JURA174_NYU" , oStructNYU, "NYUDETAIL"  )
oView:AddGrid(  "JURA174_NYV" , oStructNYV, "NYVDETAIL"  )
oView:AddGrid(  "JURA174_NYY" , oStructNYY, "NYYDETAIL"  )

oView:CreateFolder("FOLDER_01")

oView:AddSheet("FOLDER_01", "ABA_01_01", STR0006   ) //"Configura��es Gerais"
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0007   ) //"Configura��es dos Arquivos"

oView:createHorizontalBox("BOX_01_F01_A01",30,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("BOX_02_F01_A01",40,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("BOX_03_F01_A01",30,,,"FOLDER_01","ABA_01_01")

oView:createHorizontalBox("BOX_01_F01_A02",100,,,"FOLDER_01","ABA_01_02")

oView:SetOwnerView( "JURA174_VIEW" , "BOX_01_F01_A01" )
oView:SetOwnerView( "JURA174_NYV"  , "BOX_02_F01_A01" )
oView:SetOwnerView( "JURA174_NYY"  , "BOX_03_F01_A01" )

oView:SetOwnerView( "JURA174_NYU"  , "BOX_01_F01_A02" )

oView:EnableTitleView( "JURA174_NYV" )
oView:EnableTitleView( "JURA174_NYY" )

oView:SetDescription( STR0001 ) // "Configura��es tarifador"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados da Integra��o com o tarifador.

@author Cristina Cintra
@since 02/05/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNYT := FWFormStruct( 1, "NYT" )
Local oStructNYU := FWFormStruct( 1, "NYU" )
Local oStructNYV := FWFormStruct( 1, "NYV" )
Local oStructNYY := FWFormStruct( 1, "NYY" )

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
oModel:= MPFormModel():New( "JURA174",/*Pre-Validacao*/, { |oX| JA174TUDOK( oX )} /*Pos-Validacao*/, /*{|oX| J174COMMIT(oX)}*//*Commit*/,/*Cancel*/)

oModel:AddFields( "NYTMASTER", NIL, oStructNYT, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid  ( "NYUDETAIL", "NYTMASTER" /*cOwner*/, oStructNYU, /*bLinePre*/, { || J174VLLINE( oModel:GetModel('NYUDETAIL') , 'NYUDETAIL' ) } /*bLinePost*/, /*bPre*/,  /*bPost*/ )

oModel:AddGrid( "NYVDETAIL", "NYTMASTER" /*cOwner*/, oStructNYV, /*bLinePre*/, { || J174VLLINE( oModel:GetModel('NYVDETAIL') , 'NYVDETAIL' ) }  /*bLinePost*/, ;
							  /*bPre*/, /*bPost*/,  )
oModel:AddGrid( "NYYDETAIL", "NYVDETAIL" /*cOwner*/, oStructNYY, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/,  )

oModel:GetModel( "NYUDETAIL" ):SetUniqueLine( { "NYU_CAMPO", "NYU_DESCR", "NYU_ARQUI", "NYU_ATIVO" } )
oModel:SetRelation( "NYUDETAIL", { { "NYU_FILIAL", "xFilial('NYU')" }, {'NYU_CODCFG', 'NYT_COD'}  } , NYU->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0008 ) // "Modelo de Dados das Configura��es tarifador"
oModel:GetModel( "NYTMASTER" ):SetDescription( STR0009 ) // "Dados de Configura��es Gerais tarifador"
oModel:GetModel( "NYUDETAIL" ):SetDescription( STR0010 ) // "Configura��es Por Tipo de Despesa"
oModel:GetModel( "NYVDETAIL" ):SetDescription( STR0011 ) // "Configura��es por Tipo de Despesa"
oModel:GetModel( "NYYDETAIL" ):SetDescription( STR0031 ) // "Descri��o Por Idioma"

oModel:GetModel( "NYUDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NYVDETAIL" ):SetDelAllLine( .F. )
oModel:GetModel( "NYYDETAIL" ):SetDelAllLine( .F. )

oModel:GetModel( "NYVDETAIL" ):SetUniqueLine( { "NYV_TIPO" } )
oModel:SetRelation( "NYVDETAIL", { { "NYV_FILIAL", "xFilial('NYV')" }, {'NYV_CODCFG', 'NYT_COD'} } , NYV->( IndexKey( 1 ) ) )

oModel:GetModel( "NYYDETAIL" ):SetUniqueLine( { "NYY_CODCFG", "NYY_TIPO", "NYY_CIDIOM" } )
oModel:SetRelation( "NYYDETAIL", { { "NYY_FILIAL", "xFilial('NYY')" }, {'NYY_CODCFG', 'NYT_COD'}, {'NYY_TIPO', 'NYV_TIPO'} } , NYY->( IndexKey( 1 ) ) )

oModel:SetOptional( "NYUDETAIL", .T.)
oModel:SetOptional( "NYVDETAIL", .F.)
oModel:SetOptional( "NYYDETAIL", .F.)

JurSetRules( oModel, 'NYTMASTER',, 'NYT' )
JurSetRules( oModel, 'NYUDETAIL',, 'NYU' )
JurSetRules( oModel, 'NYVDETAIL',, 'NYV' )
JurSetRules( oModel, 'NYYDETAIL',, 'NYY' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J174INCLUI
Fun��o para verificar se h� registro existente na NYT como Ativo, pois 
s� pode existir um registro de configura��o ativo. Quando j� existir 
registro, dar mensagem ao usu�rio, caso contr�rio abrir EXECVIEW em modo
de inclus�o.

@author Cristina Cintra
@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J174INCLUI()
Local aArea      := GetArea()
Local lTemConfig := .F.

	NYT->(DbSetOrder(1))
	NYT->(DbSeek(xFilial('NYT')))
	While !NYT->(EOF())
		If NYT->NYT_ATIVO == '1'
			lTemConfig := .T.
			Exit
		EndIf
		NYT->( dbSkip() )
	End	

	If lTemConfig
		JurMsgErro(STR0028) //"S� � permitida a exist�ncia de uma Configura��o tarifador ativa. Para fazer a inclus�o de uma nova, inative a existente."	
	Else
		FWExecView( STR0001, 'JURA174', 3,, { || .T. } )
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J174VLLINE
Valida��o das grids de Configura��es por tipo de despesa (NYU) e 
Configura��es de arquivos (NYV).

@Param  oGrid				Grid a ser validada.
@Param  cIdModel		Model a ser validado (NYU ou NYV).

@Return lRet					.T./.F. As informa��es s�o v�lidas ou n�o

@author Cristina Cintra
@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J174VLLINE(oGrid, cIdModel)
Local lRet     := .T.
Local cMsg     := "" 

Default cIdModel := ""

	If !oGrid:IsDeleted()

		If cIdModel == "NYVDETAIL"

			If Empty(oGrid:GetValue("NYV_DIAIMP")) .Or. Empty(oGrid:GetValue("NYV_ARQIMP")) .Or. Empty(oGrid:GetValue("NYV_ARQERR")); 
					.Or. Empty(oGrid:GetValue("NYV_DIRIMP")) .Or. Empty(oGrid:GetValue("NYV_PICTDT"))
				cMsg += STR0013 + CRLF //"Os campos com o diret�rio de importa��o, arquivo a importar, arquivo com erros, diret�rio do arquivo com erros e formato da data devem ser preenchidos!" 
				lRet := .F.
			EndIf
			
			If (oGrid:GetValue("NYV_INICLI") > oGrid:GetValue("NYV_FIMCLI"))
				cMsg += STR0014 + CRLF //"O valor do campo In�cio Clien n�o pode ser maior do que o Fim Clien. Verifique!"
				lRet := .F.	
			EndIf
			
			If (oGrid:GetValue("NYV_INILOJ") > oGrid:GetValue("NYV_FIMLOJ"))
				cMsg += STR0015 + CRLF //"O valor do campo In�cio Loja n�o pode ser maior do que o Fim Loja. Verifique!"	
				lRet := .F.
			EndIf

			If (oGrid:GetValue("NYV_INICAS") > oGrid:GetValue("NYV_FIMCAS"))
				cMsg += STR0016 + CRLF //"O valor do campo In�cio Caso n�o pode ser maior do que o Fim Caso. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INISIG") > oGrid:GetValue("NYV_FIMSIG"))
				cMsg += STR0017 + CRLF //"O valor do campo In�cio Sigla n�o pode ser maior do que o Fim Sigla. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INIRAM") > oGrid:GetValue("NYV_FIMRAM"))
				cMsg += STR0018 + CRLF //"O valor do campo In�cio Ramal n�o pode ser maior do que o Fim Ramal. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INITEL") > oGrid:GetValue("NYV_FIMTEL"))
				cMsg += STR0019 + CRLF //"O valor do campo In�cio Fone n�o pode ser maior do que o Fim Fone. Verifique!"
				lRet := .F.	
			EndIf
			
			If (oGrid:GetValue("NYV_INIDTA") > oGrid:GetValue("NYV_FIMDTA"))
				cMsg += STR0020 + CRLF //"O valor do campo In�cio Data n�o pode ser maior do que o Fim Data. Verifique!"
				lRet := .F.	
			EndIf
			
			If (oGrid:GetValue("NYV_INIVAL") > oGrid:GetValue("NYV_FIMVAL"))
				cMsg += STR0021 + CRLF //"O valor do campo In�cio Valor n�o pode ser maior do que o Fim Valor. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INIHOR") > oGrid:GetValue("NYV_FIMHOR"))
				cMsg += STR0022 + CRLF //"O valor do campo In�cio Hora n�o pode ser maior do que o Fim Hora. Verifique!"
				lRet := .F.	
			EndIf
			
			If (oGrid:GetValue("NYV_INIDES") > oGrid:GetValue("NYV_FIMDES"))
				cMsg += STR0023 + CRLF //"O valor do campo In�cio Descri��o n�o pode ser maior do que o Fim Descri��o. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INIESC") > oGrid:GetValue("NYV_FIMESC"))
				cMsg += STR0024 + CRLF //"O valor do campo In�cio Escrit�rio n�o pode ser maior do que o Fim Escrit�rio. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INIQTD") > oGrid:GetValue("NYV_FIMQTD"))
				cMsg += STR0025 + CRLF //"O valor do campo In�cio Quantidade n�o pode ser maior do que o Fim Quantidade. Verifique!"
				lRet := .F.	
			EndIf

			If (oGrid:GetValue("NYV_INIDUR") > oGrid:GetValue("NYV_FIMDUR"))
				cMsg += STR0027 + CRLF//"O valor do campo In�cio Dura��o n�o pode ser maior do que o Fim Dura��o. Verifique!"
				lRet := .F.	
			EndIf
		
		ElseIf cIdModel == "NYUDETAIL"
				
			If lRet .And. Empty(oGrid:GetValue("NYU_ARQUI")) .Or. Empty(oGrid:GetValue("NYU_SQL"))
				cMsg := STR0012 + CRLF//"Os campos com o nome do Arquivo e com a Instru��o SQL devem ser preenchidos!" 
				lRet := .F.
			EndIf
		
		EndIf
		
		If !lRet
			JurMsgErro(cMsg)
	  Endif
	  
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA174TUDOK
Valida��o da tela de Configura��es do tarifador.

@Return lRet					.T./.F. As informa��es s�o v�lidas ou n�o

@author Cristina Cintra
@since 06/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA174TUDOK(oModel)
Local lRet       := .T.
Local aArea      := GetArea()
Local oModelNYT  := oModel:GetModel('NYTMASTER')
Local oModelNYV  := oModel:GetModel('NYVDETAIL')
Local oModelNYY  := oModel:GetModel('NYYDETAIL')
Local nQtdLnNYV  := oModelNYV:GetQtdLine()
Local nQtdLnNYY  := oModelNYY:GetQtdLine()
Local nQtdLnNR1  := JurQtdReg('NR1')
Local lTemConfig := .F.
Local nI         := 0

	If oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR

		//Valida a exist�ncia de apenas uma configura��o ativa  
		If oModelNYT:GetValue("NYT_ATIVO") == "1"

			NYT->(DbSetOrder(1))
			NYT->(DbSeek(xFilial('NYT')))
			While !NYT->(EOF()) 
				If NYT->NYT_ATIVO == '1' .And. NYT->NYT_COD <> oModelNYT:GetValue("NYT_COD")
					lTemConfig := .T.
					Exit
				EndIf
				NYT->( dbSkip() )
			End			
			
			If lTemConfig
				JurMsgErro(STR0029) //"S� � permitida a exist�ncia de uma Configura��o tarifador ativa. Para tornar esta ativa, inative a existente."
				lRet := .F.
			EndIf 

		EndIf

		//Valida a exist�ncia de todos os idiomas na NYY para cada configura��o NYV
		For nI := 1 to nQtdLnNYV
			oModelNYV:GoLine(nI)
			If nQtdLnNYY < nQtdLnNR1
				JurMsgErro(STR0032)// "� preciso incluir todos os idiomas para cada configura��o por tipo de despesa."
				lRet := .F.
			EndIf
		Next

	EndIf
	
	RestArea( aArea )

Return lRet