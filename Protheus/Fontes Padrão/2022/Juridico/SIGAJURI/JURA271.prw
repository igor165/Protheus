#INCLUDE "JURA271.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA271
Hist�rico de Altera��es de Assuntos Jur�dicos / Processos

@since 13/11/2019
/*/
//-------------------------------------------------------------------
Function JURA271( cFilProc, cProcesso, cTabela )

Local oBrowse    := Nil
Local oColumn    := Nil
Local aTabela    := { 'NSZ', 'NSZ' }
Local aCpoLog    := {}
Local cFilterLog := ""
Local cAliasLog  := ""
Local nX         := 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001 ) //-- "Hist�rico de Altera��es de Assunto Jur�dico / Processos"
	oBrowse:SetLocate()	
	
	//-- Embedded Audit Trail - API de consulta
	If "_TTAT_LOG" $ cTabela
			
		cFilterLog := " TMP_UNQ = '" + cFilProc + cProcesso + "' AND OPERATI = 'U'  "		
		cAliasLog := FwATTViewLog( aTabela, cFilterLog )
		
		If !Empty( cAliasLog )		
		
			( cAliasLog )->( DbGotop() )			
				
			/* Colunas do Browse */ 	
			//-- Campos que ser�o apresentados na tela
			aAdd( aCpoLog, { "TMP_USER",    STR0003, 35  } )	//-- "Usuario"
			aAdd( aCpoLog, { "TMP_DTIME",   STR0004, 22  } )	//-- "Data / Horario"
			aAdd( aCpoLog, { "TMP_FIELD",   STR0005, 10  } )	//-- "Campo"
			aAdd( aCpoLog, { "TMP_COLD",    STR0006, 100 } )	//-- "Dado Antigo"
			aAdd( aCpoLog, { "TMP_CNEW" ,   STR0007, 100 } )	//-- "Dado Novo"
			
			For nX := 1 To Len( aCpoLog )
				oColumn := FWBrwColumn():New()
				oColumn:SetData( &( "{|| " + aCpoLog[nX][1] + " }" ) )
				oColumn:SetTitle( aCpoLog[nX][2] )
				oColumn:SetSize( aCpoLog[nX][3] )
				oBrowse:SetColumns( { oColumn } )				
			Next nX
			
			oBrowse:SetAlias( cAliasLog )			
			oBrowse:SetUseFilter( .F. )
		    oBrowse:AddButton( STR0008 ,,, 2 )	//-- Visualizar
			oBrowse:ForceQuitButton( .T. ) 
		EndIf
	
	//-- Tabela O0X
	Else
		oBrowse:SetAlias( cTabela )
		oBrowse:SetFilterDefault( " O0X_KEY == '" + cFilProc + cProcesso + "' " )
		oBrowse:SetMenuDef( 'JURA271' )
	EndIf
	
	oBrowse:SetDataTable()	
	oBrowse:Activate()
	
	 //-- Fechando alias da API de consulta ao Embedded Audit Trail
	FwATTDropLog(cAliasLog)	

Return .T.


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

@since 13/11/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw", 0, 1, 0, .T. } ) //"Pesquisar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Hist�rico de Altera��es de Assuntos Jur�dicos / Processos

@since 13/11/2019
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

Local oModel     := NIL
Local oStructO0X := FWFormStruct( 1, "O0X" )

	oModel:= MPFormModel():New( "JURA271", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:SetDescription( STR0001 ) //"Modelo de Dados de Hist�rico de Altera��es de Assunto Jur�dico"
	oModel:AddFields( "O0XMASTER", NIL, oStructO0X, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "O0XMASTER" ):SetDescription( STR0001 ) //"Dados de Log de Hist�rico de Altera��es de Assunto Jur�dico"
	oModel:SetPrimaryKey( { "O0X_FILIAL", "O0X_CODIGO" } )
	
	JurSetRules( oModel, 'O0XMASTER',, 'O0X' )	

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Log de Hist�rico de Altera��es de Assunto Jur�dico

@since 13/11/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel  := FWLoadModel( "JURA271" )
Local oStructO0X := FWFormStruct( 2, "O0X" )

	JurSetAgrp( 'O0X',, oStructO0X )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA271_VIEW", oStructO0X, "O0XMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA271_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0001 )
	oStructO0X:RemoveField( "O0X_CODIGO" ) 
	oView:EnableTitleView("JURA271_VIEW")
	oView:EnableControlBar( .T. )

Return oView
