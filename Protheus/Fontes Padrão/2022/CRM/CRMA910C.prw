#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWBROWSE.CH"
#INCLUDE "CRMA910.CH"

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910C
Consulta espec�fica de Usu�rios do CRM/Unidade de Neg�cio, com m�ltipla sele��o

@param		Nenhum

@return		lRet, Logico, Verdadeiro/Falso

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//-----------------------------------------------------------------------------
Function CRMA910C()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local lCheck	:= .F.
Local lPEColUnd	:= ExistBlock("CRM910Col")
Local cMarkAll	:= ""

//----Paineis--------
Local oDlg      := Nil
Local oPanel    := Nil

//----Abas------------	
Local oFolder	:= Nil
Local aTFolder	:= { STR0043, STR0044 } //Usu�rio - Unidade

//--Browse Usu�rio----
Local oBrwUsr 	:= Nil
Local oColUsr   := Nil
Local aCpoUsr	:= CRM910CAO3Qry() // Cria array com registros de usu�rio
Local aOrderUsr	:= {}

//--Browse Unidade----
Local oBrwUnd 	:= Nil
Local oColUnd   := Nil
Local aCpoUnd	:= CRM910CADKQry() // Cria array com registros da unidade
Local aOrderUnd	:= {}	

//----------------------------------------
// Monta tela da consulta 
//----------------------------------------
oDlg := FWDialogModal():New()
oDlg:SetBackground(.F.)					//.T. -> escurece o fundo da janela 
oDlg:SetTitle(STR0039)					//"Vincular Usu�rio/Unidade"
oDlg:SetEscClose(.T.)					//permite fechar a tela com o ESC
oDlg:SetSize(200,300) 					//cria a tela maximizada (chamar sempre antes do CreateDialog)
oDlg:EnableFormBar(.T.) 				//Habilita barra de bot�es
oDlg:CreateDialog() 					//cria a janela (cria os paineis)

oPanel := oDlg:getPanelMain()			//Captura o panel principal
oDlg:createFormBar()					//cria barra de botoes

//--------------------
// Cria bot�es 
//--------------------
oDlg:AddButton( STR0040 , {||  &cMarkAll }, STR0040 , , .T., .F., .T., )														//"Marcar Todos"
oDlg:AddButton( STR0020 , {|| lRet := CRM910CLdGrid( aCpoUsr, aCpoUnd ) , oDlg:Deactivate() }, STR0020, , .T., .F., .T., )	//"Ok"
oDlg:AddButton( STR0021 , {|| lRet := .F. , oDlg:Deactivate() }, STR0021 , , .T., .F., .T., )								//"Cancelar"

//---------------------------------
// Cria abas Unidade/Usu�rio
//---------------------------------
oFolder := TFolder():New( 0,0,aTFolder,,oPanel,,,,.T.,,300,176 )

//------------------------------------------------
// Monta fun��o para marcar todos os registros
//------------------------------------------------
oFolder:bSetOption := { |nFolSel| IIF( nFolSel == 1							,; 
							cMarkAll := "CRM910ChkAll( @aCpoUsr, oBrwUsr )" ,;
							cMarkAll := "CRM910ChkAll( @aCpoUnd, oBrwUnd )"	)} 

//----------------------------------
// Cria browse de Usu�rios
//----------------------------------
DEFINE FWBROWSE oBrwUsr  DATA ARRAY ARRAY aCpoUsr LINE BEGIN 1 OF oFolder:aDialogs[1]
	ADD COLUMN oColUsr DATA &("{ || IIF(aCpoUsr[oBrwUsr:At()][1],'LBOK','LBNO')}") TITLE "" SIZE 1 IMAGE DOUBLECLICK {|| CRM910ChkReg( @aCpoUsr, oBrwUsr ) } OF oBrwUsr
	ADD COLUMN oColUsr DATA &("{ || aCpoUsr[oBrwUsr:At()][2] }") TITLE STR0041	TYPE "C" SIZE TamSX3("AO3_CODUSR")[1] OF oBrwUsr	//"C�digo"
	ADD COLUMN oColUsr DATA &("{ || aCpoUsr[oBrwUsr:At()][3] }") TITLE STR0042	TYPE "C" SIZE 30 OF oBrwUsr							//"Nome"		
		
	Aadd( aOrderUsr, { STR0041, {{"","C",TamSX3("AO3_CODUSR")[1],0,STR0041,,}} } ) //"C�digo"
	
	oBrwUsr:DisableReport()
	oBrwUsr:DisableConfig(.T.)
	oBrwUsr:SetSeek( , aOrderUsr )
ACTIVATE FWBROWSE oBrwUsr

//----------------------------------
// Cria browse de Unidade
//----------------------------------
DEFINE FWBROWSE oBrwUnd  DATA ARRAY ARRAY aCpoUnd LINE BEGIN 1 OF oFolder:aDialogs[2]
	ADD COLUMN oColUnd DATA &("{ || IIF(aCpoUnd[oBrwUnd:At()][1],'LBOK','LBNO')}") TITLE "" SIZE 1 IMAGE DOUBLECLICK {|| CRM910ChkReg( @aCpoUnd, oBrwUnd ) } OF oBrwUnd
	ADD COLUMN oColUnd DATA &("{ || aCpoUnd[oBrwUnd:At()][2] }") TITLE STR0041	TYPE "C" SIZE TamSX3("ADK_COD")[1]  OF oBrwUnd	//"C�digo"
	ADD COLUMN oColUnd DATA &("{ || aCpoUnd[oBrwUnd:At()][3] }") TITLE STR0042	TYPE "C" SIZE TamSX3("ADK_NOME")[1] OF oBrwUnd	//"Nome"		
	
	//------------------------------------------
	// Ponto de entrada para adi��o de colunas 
	//------------------------------------------
	If lPEColUnd
		CRM910ColUnd( oBrwUnd, aCpoUnd )
	EndIf
		
	Aadd( aOrderUnd, { STR0041, {{"","C",TamSX3("ADK_COD")[1],0,STR0041,,}} } ) //"C�digo"
	
	oBrwUnd:DisableReport()
	oBrwUnd:DisableConfig(.T.)
	oBrwUnd:SetSeek( , aOrderUnd )
ACTIVATE FWBROWSE oBrwUnd

//------------------------------
// Seleciona a aba de usu�rio
//------------------------------
oFolder:SetOption(1)

oDlg:Activate()

RestArea( aArea )

oBrwUsr:Destroy()
oBrwUnd:Destroy()

Return ( lRet )

//------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910CADKQry
Fun��o que monta array com registros das Unidades de Neg�cio (ADK)

@param		Nenhum

@return		aDataADK, Array, Registros da tabela ADK

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------------
Static Function CRM910CADKQry()

Local aArea 	:= GetArea()
Local aDataADK	:= {}
Local lCheck	:= .F.
Local cAliasADK := GetNextAlias()

//----------------------------------------
// Monta da Unidade de Neg�cio
//----------------------------------------
BeginSQL Alias cAliasADK

	SELECT ADK_COD Codigo, ADK_NOME Nome
	FROM %Table:ADK%
	WHERE ADK_FILIAL = %xFilial:ADK%
		AND ADK_MSBLQL <> '1'
		AND %NotDel%	
	ORDER BY ADK_COD
EndSql  
	
//----------------------------------------
// Cria array de unidade
//----------------------------------------
While !(cAliasADK)->( Eof() )
  	aAdd( aDataADK, { lCheck, (cAliasADK)->Codigo, AllTrim((cAliasADK)->Nome) } )
	(cAliasADK)->( DbSkip() )  
EndDo
	
(cAliasADK)->(DbCloseArea())
RestArea(aArea)

Return ( aDataADK )

//------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910CAO3Qry
Fun��o que monta array com registros dos Usu�rios do CRM (AO3)

@param		Nenhum

@return		aDataAO3, Array, Registros da tabela AO3

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------------
Static Function CRM910CAO3Qry()

Local aArea		:= GetArea()
Local aDataAO3	:= {}
Local lCheck	:= .F.
Local cAliasAO3 := GetNextAlias()
Local cNomeUsr 	:= ""

//----------------------------------------
// Monta query de Usu�rio
//----------------------------------------
BeginSQL Alias cAliasAO3

	SELECT AO3_CODUSR Codigo
	FROM %Table:AO3%
	WHERE AO3_FILIAL = %xFilial:AO3%
		AND AO3_MSBLQL <> '1'
		AND %NotDel%	
	ORDER BY AO3_CODUSR
EndSql 

//----------------------------------------
// Cria array de usu�rio
//----------------------------------------
While !(cAliasAO3)->( Eof() )
	cNomeUsr := AllTrim( UsrRetName( (cAliasAO3)->Codigo ) )
	
  	aAdd( aDataAO3, { lCheck, (cAliasAO3)->Codigo, cNomeUsr } )
	(cAliasAO3)->( DbSkip() )  
EndDo

(cAliasAO3)->(DbCloseArea()) 

RestArea(aArea)

Return ( aDataAO3 )

//------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910ChkReg
Altera a sele��o do registro na linha do browse

@param		aCampos	, Array	, Registros do Browse
@param		oBrwMark, Objeto, Objeto com estrutura do FWBROWSE

@return		Nenhum

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------------
Static Function CRM910ChkReg( aCampos, oBrwMark )

Default aCampos 	:= {}
Default oBrwMark	:= Nil

If ValType( oBrwMark ) == "O" .And. ! Empty( aCampos )
	aCampos[oBrwMark:At()][1] := !aCampos[oBrwMark:At()][1]

	//oBrwMark:LineRefresh( oBrwMark:At() )
	oBrwMark:Refresh()
EndIf

Return Nil

//------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910ChkAll
Fun��o para marcar/desmarcar todos registros do browse

@param		aCampos	, Array	, Registros do browse
@param		oBrwMark, Objeto, Objeto com estrutura do FWBROWSE

@return		Nenhum

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//-----------------------------------------------------------------------------
Static Function CRM910ChkAll( aCampos, oBrwMark )

Local nReg	:= 0
Local lMark	:= .F.

Default aCampos 	:= {}
Default oBrwMark	:= Nil

If ValType( oBrwMark ) == "O" .And. ! Empty( aCampos )
	lMark := !aCampos[oBrwMark:At()][1]
	
	For nReg := 1 To Len( aCampos )
		aCampos[nReg][1] := lMark
	Next nReg
	
	oBrwMark:Refresh( .T. )
EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910CLdGrid
Carrega grid de Usu�rio/Unidade com valores selecionados na consulta

@param		aCpoUsr	, Array	, Dados de usu�rio 
@param		aCpoUnd	, Array	, Dados de unidade

@return		lRet	, L�gico, Verdadeiro/Falso

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//-----------------------------------------------------------------------------------
Static Function CRM910CLdGrid( aCpoUsr, aCpoUnd )

Local oModel 	:= FwModelActive()
Local oMdlAZA	:= oModel:GetModel("FOL_NEG")
Local oMdlUsr	:= oModel:GetModel("FOL_USU")
Local oView		:= FwViewActive()
Local lRet		:= .T.
Local nReg		:= 0
Local nQtdLine	:= 0

//-------------------------------
// Carrega grid de Usu�rio
//-------------------------------
For nReg := 1 To Len( aCpoUsr )
	
	If aCpoUsr[nReg][1] .And. !oMdlUsr:SeekLine( { {"AZ2_CODENT",aCpoUsr[nReg][2]} } )
		//-------------------------------------
		// Verifica se o grid est� vazio
		//-------------------------------------	
		If oMdlUsr:IsEmpty() 
			lRet := oMdlUsr:SetValue("AZ2_CODENT",aCpoUsr[nReg][2])
		Else 
			nQtdLine := oMdlUsr:Length()
			//-------------------------------------
			// Adiciona linha no grid
			//-------------------------------------	
			If nQtdLine < oMdlUsr:AddLine()
				lRet := oMdlUsr:SetValue("AZ2_CODENT",aCpoUsr[nReg][2])
			EndIf
		EndIf		
	EndIf
	
Next nReg

//-------------------------------
// Carrega grid de Unidade
//-------------------------------
For nReg := 1 To Len( aCpoUnd )
	
	If aCpoUnd[nReg][1] .And. !oMdlAZA:SeekLine( { {"AZA_COD",aCpoUnd[nReg][2]} } )
		//-------------------------------------
		// Verifica se o grid est� vazio
		//-------------------------------------	
		If oMdlAZA:IsEmpty() 
			lRet := oMdlAZA:SetValue("AZA_COD",aCpoUnd[nReg][2])
		Else 
			nQtdLine := oMdlAZA:Length()
			//-------------------------------------
			// Adiciona linha no grid
			//-------------------------------------	
			If nQtdLine < oMdlAZA:AddLine()
				lRet := oMdlAZA:SetValue("AZA_COD",aCpoUnd[nReg][2])
			EndIf
		EndIf		
	EndIf
		
Next nReg

//-----------------------------------
// Posiciona na aba de Usu�rios 
//-----------------------------------
oView:SelectFolder("FOLDER",3,2) 

oMdlAZA:GoLine( 1 )
oMdlUsr:GoLine( 1 )
oView:Refresh()

Return ( lRet )

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910ColUnd
Carrega grid de Usu�rio/Unidade com valores selecionados na consulta

@param		oBrwUnd	, Objeto	, Estrutura do Browse da Unidade 
@param		aCpoUnd	, Array		, Registros da tabela (ADK) 

@return		lRet	, L�gico, Verdadeiro/Falso

@author		Jonatas Martins
@since		24/11/2015
@version	12.1.7
/*/
//-----------------------------------------------------------------------------------
Static Function CRM910ColUnd( oBrwUnd, aCpoUnd )

Local aColsPE 	:= {}

Default oBrwUnd := Nil

If ValType( oBrwUnd ) == "O"
	aColsPE := ExecBlock("CRM910Col",.F.,.F., { aCpoUnd } )
	
	//------------------------
	// Valida vari�vel
	//------------------------
	If ValType( aColsPE ) == "A"
		ADD COLUMN oColUnd DATA &("{ || aColsPE[oBrwUnd:At()][3] }") TITLE aColsPE[1][1] TYPE "C" SIZE aColsPE[1][1] OF oBrwUnd	//"Nome"
	EndIf
EndIf

Return Nil

//--------------------------------------------------------------------------------------