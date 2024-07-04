#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "FISA081.CH"

#Define SAliasHead  4

//---------------------------------------------------------------------
/*/{Protheus.doc} FISA081

Edicao de impostos dos documentos fiscais por itens.
Obs: Nao utilizado para o Brasil.

@Param oList - Objeto com os impostos previamente calculados pelo
               documento fiscal

@Author Felipe C. Seolin
@Since 07/02/2014
@Version 1.0
/*/
/*/
³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                        ³
|Ivan Gomez  |30/08/17|DMICNS-46 |Actualiza el valor en la pestaña de Títulos |
|            |        |          |                                            |
|Roberto Glez|14/12/17|DMICNS-651|Se llama funcion de actualización de pestana|
|            |        |          |de impuestos, Argentina.                    |
/*/
//---------------------------------------------------------------------
Function FISA081( oList )

Local nI  := 0
Local lOk := .F.
Local lIncNFE  := .F.

Private oImpostos := oList
Private aAllTES   := {}
Private aAllImp   := {}
Private aItem     := aClone( aCols )
Private nPOSItem  := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_ITEM" } )
Private nPOSCod   := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_COD" } )
Private nPOSQuant := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_QUANT" } )
Private nPOSVUnit := IIf( aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_VUNIT" } ) > 0, aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_VUNIT" } ), aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_PRCVEN" } ) )
Private nPOSTotal := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_TOTAL" } )
Private nPOSTES   := aScan( aHeader, { |x| AllTrim( SubStr( x[2], At( "_", x[2] ) ) ) ==  "_TES" } )

IF Type( "lMetImpEdi" ) <> "U"
	lMetImpEdi:=.T. // Bandera edicion de impuestos para metrica 
ENDIF

FIniAlias()

For nI := 1 to Len( aItem )
	If !Empty( aItem[nI,nPOSTES] )
		aAdd( aAllTES, aItem[nI,nPOSTES] )
	EndIf
Next nI

aAllImp := FGetImp( aAllTES )

If  cPaisLoc == "ARG" .And. Valtype("INCLUI") <> "U"
	lIncNFE := INCLUI
Endif

lOk := FwExecView( STR0001, "FISA081", MODEL_OPERATION_UPDATE, , { || .T. } ) == 0 //"Edição de Impostos"

If  cPaisLoc == "ARG" .And. Valtype("INCLUI") <> "U"
	INCLUI := lIncNFE
Endif

If lOk
	Help( ,, "Help", , STR0002, 1, 0 ) //"Edição de impostos concluída."
EndIf

If aCfgNf[SAliasHead] == "SF1"
	LocXVal("F1_DOC")
Else
	LocXVal("F2_DOC")
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Estrutura do modelo MVC.

@Return oModel - Objeto do modelo MVC

@author Felipe C. Seolin
@since 07/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := MpFormModel():New( "FISA081",,, { |oModel| FCommit( oModel ) } )
Local oStruTRB  := FStrModel( "TRB" , "Documento Fiscal" )
Local oStruTRB1 := FStrModel( "TRB1", "Itens do Documento Fiscal" )
Local oStruTRB2 := FStrModel( "TRB2", "Impostos do Documento Fiscal" )
Local bLoadTRB  := { || FLoadField() }
Local bLoadTRB1 := { || FLoadGrid1() }
Local bLoadTRB2 := { |oGrid| FLoadGrid2( oGrid ) }     
Local bVldTRB2  := { |oGrid, nLine, cAction, cIDField, xValue, xCurrentValue| FVldGrid2( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue ) }

oModel:AddFields( "MODEL_TRB",, oStruTRB,,, bLoadTRB )
oModel:GetModel( "MODEL_TRB" ):SetOnlyView()

oModel:AddGrid( "MODEL_TRB1", "MODEL_TRB", oStruTRB1,,,,, bLoadTRB1 )
oModel:GetModel( "MODEL_TRB1" ):SetUniqueLine( { "TRB1_ITEM" } )
oModel:GetModel( "MODEL_TRB1" ):SetNoInsertLine()
oModel:GetModel( "MODEL_TRB1" ):SetNoUpdateLine()
oModel:GetModel( "MODEL_TRB1" ):SetNoDeleteLine()

oModel:AddGrid( "MODEL_TRB2", "MODEL_TRB1", oStruTRB2, bVldTRB2,,,, bLoadTRB2 )
oModel:GetModel( "MODEL_TRB2" ):SetOptional( .T. )
oModel:GetModel( "MODEL_TRB2" ):SetUniqueLine( { "TRB2_IMPOSTO" } )

oModel:SetRelation( "MODEL_TRB1", { { "TRB1_DOC", "TRB_DOC" }, { "TRB1_SERIE", "TRB_SERIE" } }, "1" )
oModel:SetRelation( "MODEL_TRB2", { { "TRB2_DOC", "TRB1_DOC" }, { "TRB2_SERIE", "TRB1_SERIE" }, { "TRB2_ITEM", "TRB1_ITEM" } }, "1" )

oModel:GetModel( "MODEL_TRB" ):SetPrimaryKey( { "TRB_DOC", "TRB_SERIE" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} FStrModel

Cria a tabela de acordo com a estrutura do modelo MVC.

@Param cAlias     - Alias da tabela
       cDescricao - Descricao da tabela

@Return oStruct - Objeto com a estrutura da tabela para o modelo MVC

@author Felipe C. Seolin
@since 07/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FStrModel( cAlias, cDescricao )

Local oStruct := FwFormModelStruct():New()
Local aStruct := FGetStruct( cAlias )
Local bWhen   := Nil
Local bRelac  := Nil
Local nI      := 0
Local nPos    := 0
Local cUnico  := ""
Local lExit   := .F.

Default cDescricao := ""

If Empty( aStruct )
	lExit := .T.
EndIf

If !lExit

	nPos := aScan( aStruct[2], { |x| AllTrim( x[2] ) == "UNQ" .or. AllTrim( x[2] ) == "PK" } )

	If nPos > 0
		cUnico := aStruct[2,nPos,3]
	EndIf

	//-------------------------------------------------------------------
	// Tabela
	// [01] Alias da tabela
	// [02] Array com os campos que correspondem a primary key
	// [03] Descricao da tabela
	//-------------------------------------------------------------------
	oStruct:AddTable( cAlias, StrToKArr( cUnico, "+" ), cDescricao )

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	For nI := 1 to Len( aStruct[2] )

		oStruct:AddIndex( aStruct[2,nI,1],;	//[01] Ordem do indice
		                  aStruct[2,nI,2],;		//[02] ID
		                  aStruct[2,nI,3],;		//[03] Chave do indice
		                  aStruct[2,nI,4],;		//[04] Descricao do indice
		                  "",;					//[05] Expressao de lookUp dos campos de indice
		                  "",;					//[06] Nickname do indice
		                  .T. )					//[07] Indica se o indice pode ser utilizado pela interface
	
	Next nX

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aStruct[1] )

		bWhen  := FwBuildFeature( STRUCT_FEATURE_WHEN  , aStruct[1,nI,10] )
		bRelac := FwBuildFeature( STRUCT_FEATURE_INIPAD, aStruct[1,nI,9] )

		oStruct:AddField( aStruct[1,nI,1],;					//[01] Titulo do campo
		                  "",;									//[02] ToolTip do campo
		                  aStruct[1,nI,2],;						//[03] Campo
		                  aStruct[1,nI,6],;						//[04] Tipo do campo
		                  aStruct[1,nI,4],;						//[05] Tamanho do campo
		                  aStruct[1,nI,5],;						//[06] Decimal do campo
		                  Nil,;									//[07] Code-block de validacao do campo
		                  bWhen,;								//[08] Code-block de validacao When do campo
		                  StrToKArr( aStruct[1,nI,8], ";" ),;	//[09] Lista de valores permitido do campo
		                  .F.,;									//[10] Indica se o campo tem preenchimento obrigatorio
		                  bRelac,;								//[11] Code-block de inicializacao do campo
		                  .F.,;									//[12] Indica se trata-se de um campo chave
		                  .F.,;									//[13] Indica se o campo pode receber valor em uma operacao de update
		                  .F. )									//[14] Indica se o campo eh virtual
	Next nI

EndIf

Return( oStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Estrutura da interface MVC.

@Return oView - Objeto da interface MVC

@author Felipe C. Seolin
@since 07/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oView     := FwFormView():New()
Local oModel    := FwLoadModel( "FISA081" )
Local oStruTRB  := FStrView( "TRB" )
Local oStruTRB1 := FStrView( "TRB1" )
Local oStruTRB2 := FStrView( "TRB2" )

oView:SetModel( oModel )

/*-----------------------------------------------------------------------------------
							Esrutura da View
-------------------------------------------------------------------------------------*/
oView:AddField( "VIEW_TRB", oStruTRB, "MODEL_TRB" )

oView:AddGrid( "VIEW_TRB1", oStruTRB1, "MODEL_TRB1" )
oView:EnableTitleView( "VIEW_TRB1", STR0003 ) //"Itens"

oView:AddGrid( "VIEW_TRB2", oStruTRB2, "MODEL_TRB2" )
oView:EnableTitleView( "VIEW_TRB2", STR0004 ) //"Impostos do Item: "

/*-----------------------------------------------------------------------------------
							Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox( "PAINEL_PRINCIPAL", 100 )
oView:CreateFolder( "FOLDER_PRINCIPAL", "PAINEL_PRINCIPAL" )

oView:AddSheet( "FOLDER_PRINCIPAL", "ABA01", STR0001 ) //"Edição de Impostos"

oView:CreateHorizontalBox( "TRB", 10, , , "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateHorizontalBox( "TRB1", 45, , , "FOLDER_PRINCIPAL", "ABA01" )
oView:CreateHorizontalBox( "TRB2", 45, , , "FOLDER_PRINCIPAL", "ABA01" )

/*-----------------------------------------------------------------------------------
						Amarracao para exibicao das informacoes
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( "VIEW_TRB", "TRB" )
oView:SetOwnerView( "VIEW_TRB1", "TRB1" )
oView:SetOwnerView( "VIEW_TRB2", "TRB2" )

/*-----------------------------------------------------------------------------------
							Remover campos da interface
-------------------------------------------------------------------------------------*/
oStruTRB1:RemoveField( "TRB1_DOC" )
oStruTRB1:RemoveField( "TRB1_SERIE" )

oStruTRB2:RemoveField( "TRB2_DOC" )
oStruTRB2:RemoveField( "TRB2_SERIE" )
oStruTRB2:RemoveField( "TRB2_ITEM" )
oStruTRB2:RemoveField( "TRB2_BASIMP2" )
oStruTRB2:RemoveField( "TRB2_PUTSYS" )

/*-----------------------------------------------------------------------------------
							Manipulacoes na interface
-------------------------------------------------------------------------------------*/
//Metodo utilizado para marcar os itens deletados apos o Activate da tela, mas antes de apresenta-la ao usuario
oView:SetAfterViewActivate( { || FLoadDel( oModel ) } )

//Metodo utilizado para trocar o titulo da Grid Inferior ao navegar nos itens do Grid Superior
oView:SetViewProperty( "VIEW_TRB1", "CHANGELINE", { { || FChgLine( oView, oModel ) } } )

Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} FStrView

Cria a tabela de acordo com a estrutura da interface MVC.

@Param cAlias - Alias da tabela

@Return oStruct - Objeto com a estrutura da tabela para a interface MVC

@author Felipe C. Seolin
@since 07/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FStrView( cAlias )

Local oStruct := FwFormViewStruct():New()
Local aStruct := FGetStruct( cAlias )
Local nI      := 0
Local cGSC    := ""
Local lExit   := .F.

If Empty( aStruct )
	lExit := .T.
EndIf

If !lExit
	For nI := 1 to Len( aStruct[1] )

		cGSC := Iif( !Empty( aStruct[1,nI,8] ), Iif( aStruct[1,nI,6] == "L", "CHECK", "GET" ), "COMBO" )

		oStruct:AddField( aStruct[1,nI,2],;					//[01] Campo
		                  StrZero( nI, 2 ),;					//[02] Ordem
		                  aStruct[1,nI,1],;						//[03] Titulo
		                  aStruct[1,nI,1],;						//[04] Descricao
		                  aStruct[1,nI,12],;					//[05] Help
		                  cGSC,;								//[06] Tipo do campo Combo, Get ou Check
		                  aStruct[1,nI,3],;						//[07] Picture
		                  Nil,;									//[08] PictVar
		                  aStruct[1,nI,7],;						//[09] F3
		                  aStruct[1,nI,11],;					//[10] Editavel
		                  NIL,;									//[11] Folder
		                  NIL,;									//[12] Group
		                  StrToKArr( aStruct[1,nI,8], ";" ),;	//[13] Lista Combo
		                  0,;									//[14] Tam Max Combo
		                  NIL,;									//[15] Inic. Browse
		                  .F. )									//[16] Virtual
	Next nI
EndIf

Return( oStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetStruct

Definicao da estrutura do dicionario.

@Param cAlias - Alias da tabela

@Return aStruct - Array com a estrutura dos dicionarios:
                  [1] - Estrutura dos campos
                  [2] - Estrutura dos indices

@author Felipe C. Seolin
@since 10/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetStruct( cAlias )

Local aTRBCmp  := { { "SF1", "F1_DOC" }, { "SF1", "F1_SERIE" }, { "SF1", "F1_EMISSAO" } }
Local aTRB1Cmp := { { "SF1", "F1_DOC" }, { "SF1", "F1_SERIE" }, { "SD1", "D1_ITEM" }, { "SD1", "D1_COD" }, { "SD1", "D1_QUANT" }, { "SD1", "D1_VUNIT" }, { "SD1", "D1_TOTAL" }, { "SD1", "D1_TES" } }
Local aTRB2Cmp := { { "SF1", "F1_DOC" }, { "SF1", "F1_SERIE" }, { "SD1", "D1_ITEM" }, { "SFC", "FC_IMPOSTO" }, { "SD1", "D1_BASIMP1" }, { "SD1", "D1_BASIMP2" }, { "SD1", "D1_ALQIMP1" }, { "SD1", "D1_VALIMP1" }, { "SFC", "FC_BASE" } }
Local aStruct  := {}
Local aFields  := {}
Local aIndex   := {}
Local aHelp    := {}

Local nI       := 0
Local nPos     := 0

Local cCmp     := ""
Local cTitle   := ""
Local cF3      := ""
Local cWhen    := ""

Local lEdit    := .T.

If cAlias == "TRB"

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aTRBCmp )

		cTitle := AllTrim( TitSX3( aTRBCmp[nI,2] )[1] )

		cCmp := cCmp := cAlias + AllTrim( SubStr( aTRBCmp[nI,2], At( "_", aTRBCmp[nI,2] ) ) )

		If cCmp == "TRB_DOC"
			aHelp := { STR0012 } //"Documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB_SERIE"
			aHelp := { STR0013 } //"Série do documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB_EMISSAO"
			aHelp := { STR0014 } //"Data de emissão do documento fiscal utilizado para a edição dos impostos."
		EndIf

		aAdd( aFields, { cTitle,;														//[01] Titulo do campo
		                  cCmp,;														//[02] Campo
		                  PesqPict( aTRBCmp[nI,1], aTRBCmp[nI,2] ),;					//[03] Picture
		                  TamSX3( aTRBCmp[nI,2] )[1] + TamSX3( aTRBCmp[nI,2] )[2],;	//[04] Tamanho do campo
		                  TamSX3( aTRBCmp[nI,2] )[2],;									//[05] Decimal do campo
		                  TamSX3( aTRBCmp[nI,2] )[3],;									//[06] Tipo do campo
		                  cF3,;															//[07] F3
		                  "",;															//[08] Lista de Combo
		                  "",;															//[09] Inicializacao do Campo
		                  cWhen,;														//[10] When
		                  lEdit,;														//[11] Editavel
		                  aHelp } )														//[12] Help

		aHelp := {}

	Next nI

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	aAdd( aIndex, { 0,;										//[01] Ordem do indice
	                 "UNQ",;								//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2],;	//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 1,;										//[01] Ordem do indice
	                 "1",;									//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2],;	//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] } )	//[04] Descricao do indice

ElseIf cAlias == "TRB1"

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aTRB1Cmp )

		cTitle := AllTrim( TitSX3( aTRB1Cmp[nI,2] )[1] )

		cCmp := cAlias + StrTran( AllTrim( SubStr( aTRB1Cmp[nI,2], At( "_", aTRB1Cmp[nI,2] ) ) ), "1", "" )

		If cCmp == "TRB1_DOC"
			aHelp := { STR0012 } //"Documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB1_SERIE"
			aHelp := { STR0013 } //"Série do documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB1_ITEM"
			aHelp := { STR0015 } //"Item do documento fiscal."
		ElseIf cCmp == "TRB1_COD"
			aHelp := { STR0016 } //"Código identificador do produto."
			cF3 := "SB1"
		ElseIf cCmp == "TRB1_QUANT"
			aHelp := { STR0017 } //"Quantidade do produto."
		ElseIf cCmp == "TRB1_VUNIT"
			aHelp := { STR0018 } //"Valor unitário do produto."
		ElseIf cCmp == "TRB1_TOTAL"
			aHelp := { STR0019 } //"Valor total do produto."
		ElseIf cCmp == "TRB1_TES"
			aHelp := { STR0020 } //"Tipo de Entrada/Saída para o produto."
			cF3 := "SF4"
		EndIf

		aAdd( aFields, { cTitle,;														//[01] Titulo do campo
		                  cCmp,;														//[02] Campo
		                  PesqPict( aTRB1Cmp[nI,1], aTRB1Cmp[nI,2] ),;					//[03] Picture
		                  TamSX3( aTRB1Cmp[nI,2] )[1] + TamSX3( aTRB2Cmp[nI,2] )[2],;	//[04] Tamanho do campo
		                  TamSX3( aTRB1Cmp[nI,2] )[2],;								//[05] Decimal do campo
		                  TamSX3( aTRB1Cmp[nI,2] )[3],;								//[06] Tipo do campo
		                  cF3,;															//[07] F3
		                  "",;															//[08] Lista de Combo
		                  "",;															//[09] Inicializacao do Campo
		                  cWhen,;														//[10] When
		                  lEdit,;														//[11] Editavel
		                  aHelp } )														//[12] Help

		aHelp := {}
		cF3   := ""

	Next nI

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	aAdd( aIndex, { 0,;																//[01] Ordem do indice
	                 "UNQ",;														//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2] + "+" + aFields[3,2],;		//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] + "+" + aFields[3,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 1,;																//[01] Ordem do indice
	                 "1",;															//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2] + "+" + aFields[3,2],;		//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] + "+" + aFields[3,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 2,;					//[01] Ordem do indice
	                 "2",;				//[02] ID
	                 aFields[3,2],;		//[03] Chave do indice
	                 aFields[3,1] } )	//[04] Descricao do indice

ElseIf cAlias == "TRB2"

	//-------------------------------------------------------------------
	// Campos
	//-------------------------------------------------------------------
	For nI := 1 to Len( aTRB2Cmp )

		If ( nPos := At( "1", TitSX3( aTRB2Cmp[nI,2] )[1] ) - 1 ) > 0
			cTitle := AllTrim( SubStr( TitSX3( aTRB2Cmp[nI,2] )[1], 1, nPos ) )
		Else
			cTitle := AllTrim( TitSX3( aTRB2Cmp[nI,2] )[1] )
		EndIf

		cCmp := cAlias + StrTran( AllTrim( SubStr( aTRB2Cmp[nI,2], At( "_", aTRB2Cmp[nI,2] ) ) ), "1", "" )

		If cCmp == "TRB2_DOC"
			aHelp := { STR0012 } //"Documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB2_SERIE"
			aHelp := { STR0013 } //"Série do documento fiscal utilizado para a edição dos impostos."
		ElseIf cCmp == "TRB2_ITEM"
			aHelp := { STR0015 } //"Item do documento fiscal."
			lEdit := .F.
		ElseIf cCmp == "TRB2_IMPOSTO"
			aHelp := { STR0021 } //"Código identificador do imposto."
			cF3   := "SFBFIL"
			cWhen := "FwFldGet('TRB2_PUTSYS') == '2'"
		ElseIf cCmp == "TRB2_BASIMP"
			aHelp := { STR0022 } //"Valor de base de cálculo do imposto."
			cWhen := "FwFldGet('TRB2_PUTSYS') == '2'"
		ElseIf cCmp == "TRB2_BASIMP2"
			aHelp := { STR0023 } //"Valor original de base de cálculo do imposto."
		ElseIf cCmp == "TRB2_ALQIMP"
			aHelp := { STR0024 } //"Valor percentual de alíquota do imposto."
		ElseIf cCmp == "TRB2_VALIMP"
			aHelp := { STR0025 } //"Valor do imposto."
		ElseIf cCmp == "TRB2_BASE"
			aHelp := { STR0026 } //"Valor adicional de percentual de redução de base de cálculo do imposto."
		EndIf

		aAdd( aFields, { cTitle,;														//[01] Titulo do campo
		                  cCmp,;														//[02] Campo
		                  PesqPict( aTRB2Cmp[nI,1], aTRB2Cmp[nI,2] ),;					//[03] Picture
		                  TamSX3( aTRB2Cmp[nI,2] )[1] + TamSX3( aTRB2Cmp[nI,2] )[2],;	//[04] Tamanho do campo
		                  TamSX3( aTRB2Cmp[nI,2] )[2],;								//[05] Decimal do campo
		                  TamSX3( aTRB2Cmp[nI,2] )[3],;								//[06] Tipo do campo
		                  cF3,;															//[07] F3
		                  "",;															//[08] Lista de Combo
		                  "",;															//[09] Inicializacao do Campo
		                  cWhen,;														//[10] When
		                  lEdit,;														//[11] Editavel
		                  aHelp } )														//[12] Help

		aHelp := {}
		cF3   := ""
		cWhen := ""
		lEdit := .T.

	Next nI

	aHelp := { STR0027 } //"Identifica se o imposto foi previamente calculado no documento fiscal."

	aAdd( aFields, { "Imp. Sistema",;	//[01] Titulo do campo
	                  "TRB2_PUTSYS",;	//[02] Campo
	                  "@!",;			//[03] Picture
	                  1,;				//[04] Tamanho do campo
	                  0,;				//[05] Decimal do campo
	                  "C",;				//[06] Tipo do campo
	                  "",;				//[07] F3
	                  "1=Sim;2=Não",;	//[08] Lista de Combo
	                  "2",;				//[09] Inicializacao do Campo
	                  cWhen,;			//[10] When
	                  lEdit,;			//[11] Editavel
	                  aHelp } )			//[12] Help

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	aAdd( aIndex, { 0,;																					//[01] Ordem do indice
	                 "UNQ",;																			//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2] + "+" + aFields[3,2] + "+" + aFields[4,2],;	//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] + "+" + aFields[3,1] + "+" + aFields[4,1] } )	//[04] Descricao do indice

	aAdd( aIndex, { 1,;																					//[01] Ordem do indice
	                 "1",;																				//[02] ID
	                 aFields[1,2] + "+" + aFields[2,2] + "+" + aFields[3,2] + "+" + aFields[4,2],;	//[03] Chave do indice
	                 aFields[1,1] + "+" + aFields[2,1] + "+" + aFields[3,1] + "+" + aFields[4,1] } )	//[04] Descricao do indice


	aAdd( aIndex, { 2,;					//[01] Ordem do indice
	                 "2",;				//[02] ID
	                 aFields[4,2],;		//[03] Chave do indice
	                 aFields[4,1] } )	//[04] Descricao do indice
EndIf

aAdd( aStruct, aFields )
aAdd( aStruct, aIndex )

Return( aStruct )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadField

Carrega informacoes na Field.

@Return aLoad - Array com os conteudos da Field

@author Felipe C. Seolin
@since 14/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadField()

Local aLoad  := {}
Local nRecno := 1

aAdd( aLoad, { cNFIscal, cSerie, dDEmissao } )
aAdd( aLoad, nRecno )

Return( aLoad )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadGrid1

Carrega informacoes na Grid Superior, que contem os itens.

@Return aLoad - Array com os conteudos da Grid Superior, de Itens

@author Felipe C. Seolin
@since 14/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadGrid1()

Local aLoad  := {}
Local nI     := 0
Local nRecno := 1

For nI := 1 to Len( aItem )
	aAdd( aLoad, { nRecno, { cNFIscal, cSerie, aItem[nI,nPOSItem], aItem[nI,nPOSCod], aItem[nI,nPOSQuant], aItem[nI,nPOSVUnit], aItem[nI,nPOSTotal], aItem[nI,nPOSTES] } } )
	nRecno ++
Next nI

Return( aLoad )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadGrid2

Carrega informacoes na Grid Inferior, que contem os impostos.

@Param oGrid - Objeto de modelo da Grid Inferior, de Impostos

@Return aLoad - Array com os conteudos da Grid Inferior, de Impostos

@author Felipe C. Seolin
@since 14/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadGrid2( oGrid )

Local oGridOwner := oGrid:GetOwner()
Local aImp       := {}
Local aLoad      := {}
Local nLineOwner := oGridOwner:GetLine()
Local nRecno     := 1
Local nI         := 0
Local nBasImp    := 0
Local nAlqImp    := 0
Local nValImp    := 0
Local cTes       := oGridOwner:GetValue( "TRB1_TES", nLineOwner )
Local cLvrFiscal := ""

aImp := FGetImp(aAllTES)

For nI := 1 to Len( aImp )

	If aScan( oImpostos:aArray, { |x| AllTrim( x[1] ) == AllTrim( aImp[nI,1] ) } ) > 0

		cLvrFiscal := FGetLFis( aImp[nI,1] )

		If aItem[nLineOwner][nPOSTotal] > 0

			nBasImp := MaFisRet( nLineOwner, "IT_BASEIV" + cLvrFiscal )
			nAlqImp := MaFisRet( nLineOwner, "IT_ALIQIV" + cLvrFiscal )
			nValImp := MaFisRet( nLineOwner, "IT_VALIV" + cLvrFiscal )

			If !Empty( nBasImp + nAlqImp + nAlqImp )
				aAdd( aLoad, { nRecno, { oGridOwner:GetValue( "TRB1_DOC", nLineOwner ),;
										oGridOwner:GetValue( "TRB1_SERIE", nLineOwner ),;
										oGridOwner:GetValue( "TRB1_ITEM", nLineOwner ),;
										aImp[nI,1],;
										nBasImp,;
										nBasImp,;
										nAlqImp,;
										nValImp,;
										0,;
										"1" } } )
				nRecno ++
			EndIf
		
		EndIF

	EndIf

Next nI

Return( aLoad )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetImp

Verifica os impostos possiveis de acordo com a amarracao com o TES.

@Param cTes - TES utilizada

@Return aImp - Array contendo impostos, percentual de reducao de base
               e aliquota, montado de acordo com os TES's utilizados

@author Felipe C. Seolin
@since 18/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetImp( aAllTES )

Local aImp := {}
Local nI   := 0

For nI := 1 to Len( aAllTES )
	If SFC->( MsSeek( xFilial("SFC") + aAllTES[nI] ) )
		While SFC->( !Eof() ) .and. SFC->( FC_FILIAL + FC_TES ) == xFilial("SFC") + aAllTES[nI]
			If aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( SFC->FC_IMPOSTO ) } ) == 0
				If SFB->( MsSeek( xFilial("SFB") + SFC->FC_IMPOSTO ) )
					aAdd( aImp, { SFC->FC_IMPOSTO, SFC->FC_BASE, SFB->FB_ALIQ } )
				EndIf
			Endif	
			SFC->( DBSkip() )
		EndDo
	EndIf
Next nI

Return( aImp )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetLFis

Busca a posicao do Livro Fiscal do imposto utilizado.

@Param cImp - Imposto utilizado para busca do Livro Fiscal

@Return cLvrFiscal - Livro Fiscal referente ao imposto utilizado

@author Felipe C. Seolin
@since 18/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetLFis( cImp )

Local cLvrFiscal := ""

If SFB->( MsSeek( xFilial("SFB") + cImp ) )
	cLvrFiscal := SFB->FB_CPOLVRO
EndIf

Return( cLvrFiscal )

//---------------------------------------------------------------------
/*/{Protheus.doc} FVldGrid2

Validacao das informacoes do Grid Inferior, que contem os impostos.

@Param oGrid         - Objeto de modelo da Grid Inferior, de Impostos
       nLine         - Linha posicionada referente ao objeto oGrid
       cAction       - Acao tomada causadora da validacao
       cIDField      - Campo posicionado referente ao objeto oGrid
       xValue        - Valor inserido na acao
       xCurrentValue - Valor contido no atualmente no campo

@Return lRet - Informa se a acao foi validada

@author Felipe C. Seolin
@since 20/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FVldGrid2( oGrid, nLine, cAction, cIDField, xValue, xCurrentValue )

Local oGridOwner := oGrid:GetOwner()
Local aImp       := {}
Local aRmvWhen   := {}
Local nLineOwner := oGridOwner:GetLine()
Local nBasImp    := 0
Local nAlqImp    := 0
Local cTes       := oGridOwner:GetValue( "TRB1_TES", nLineOwner )
Local lRet       := .T.
Local nTotCal  	 := 0
Local nTotCalA   := 0
Local cImp	     := 0
Local cLvrFiscal := 0
Local nJ         := 0

If cAction == "SETVALUE"

	If cIDField == "TRB2_IMPOSTO"

		//----------------------
		cImposto := oGrid:GetValue( "TRB2_IMPOSTO", nLine )
		nImposto := aScan(oImpostos:aArray, {|x| x[1] == cImposto} )

		//----------------------
		IF cPaisLoc <> "ARG" .or. (cPaisLoc == "ARG" .and. nImposto > 0)

			aImp := FGetImp( aAllTES )

			If ( nPos := aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( xValue ) } ) ) == 0
				lRet := .F.
				Help( ,, "HELP",, STR0005, 1, 0) //"O imposto selecionado não pode ser utilizado, pois não está contido na amarração com a TES."   
			Else
				If !oGrid:CanSetValue( "TRB2_BASIMP" )
					aRmvWhen := FRmvWhen( oGrid, "TRB2_BASIMP" )
				EndIf

				oGrid:SetValue( "TRB2_BASIMP", oGridOwner:GetValue( "TRB1_TOTAL", nLineOwner ) )

				If !Empty( aRmvWhen )
					oGrid:oFormModelStruct:aFields[aRmvWhen[2],MODEL_FIELD_WHEN] := aRmvWhen[1]
				EndIf

				oGrid:SetValue( "TRB2_BASIMP2", oGrid:GetValue( "TRB2_BASIMP", nLine ) )

				If FExstImp( oGrid, nLine )
					nAlqImp := FGetAliq( oGrid, nLine )
					oGrid:LoadValue( "TRB2_ALQIMP", nAlqImp )
					nBasImp := oGrid:GetValue( "TRB2_BASIMP", nLine )
					oGrid:SetValue( "TRB2_VALIMP", nBasImp * ( nAlqImp / 100) )
				Else
					oGrid:SetValue( "TRB2_ALQIMP", aImp[nPos,3] )
				EndIf

			EndIf
		Else
			aImp := FGetImp( aAllTES )
			If ( nPos := aScan( aImp, { |x| AllTrim( x[1] ) == AllTrim( xValue ) } ) ) == 0
				lRet := .F.
				Help( ,, "HELP",, STR0005, 1, 0) //"O imposto selecionado não pode ser utilizado, pois não está contido na amarração com a TES."   
			Else
				oGrid:SetValue( "TRB2_BASIMP", oGridOwner:GetValue( "TRB1_TOTAL", nLineOwner ) )
				oGrid:SetValue( "TRB2_ALQIMP", 0 )
				oGrid:SetValue( "TRB2_VALIMP", 0 )
			EndIf


		EndIf

	ElseIf cIDField == "TRB2_BASIMP"
		nAlqImp := oGrid:GetValue( "TRB2_ALQIMP", nLine )
		oGrid:SetValue( "TRB2_VALIMP", xValue * ( nAlqImp / 100) )

	ElseIf cIDField == "TRB2_ALQIMP"
		nBasImp := oGrid:GetValue( "TRB2_BASIMP", nLine )
		cImp := oGrid:GetValue( "TRB2_IMPOSTO", nLine )
		nImposto := aScan(oImpostos:aArray, {|x| x[1] == cImp} )
	    cLvrFiscal := FGetLFis( cImp )
		If !Empty(cLvrFiscal)
			For nJ := 1 to Len( aItem )
				If !aItem[nJ,Len( aItem[nJ] )] .And. aItem[nJ][nPOSTotal] > 0 .And. MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal ) > 0
					nAlqImp := MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal )
					Exit
				EndIf
			Next nJ
		EndIf
		nTotCal	:= nBasImp*(nAlqImp)/100
		nTotCalA := nBasImp*(xValue)/100
		IF cPaisLoc <> "ARG" .or. (cPaisLoc == "ARG" .and. nImposto > 0 .and. SFB->FB_PERCALT <> 999999.99)	
			
				If !(ABS(nTotCalA- nTotCal) <= (nTotCal * (SFB->FB_PERCALT/100)) ) .Or. !(ABS(nTotCalA - nTotCal) <= SFB->FB_VLRALT)
					oGrid:LoadValue("TRB2_ALQIMP",SFB->FB_ALIQ)
					oGrid:LoadValue("TRB2_VALIMP",nTotCal)
					lRet  := .F.
					Help(, , "HELP", , STR0028, 1, 0) //STR0028: "El valor modificado es superior al valor máximo permitido"
				ElseIf xValue > 100 .Or. xValue < 0
					lRet  := .F.
				Else
					oGrid:SetValue( "TRB2_VALIMP", nBasImp * ( xValue / 100) )
				EndIF

			If FExstImp( oGrid, nLine )
				If Aviso( STR0007, STR0008, { STR0009, STR0010 }, 1 ) == 1 //##"Atenção!" ##"A alteração de alíquota deste item refletirá nas demais alíquotas deste imposto. Deseja realmente alterar?" ##"Sim" ##"Não"
					
					If !(ABS(nTotCalA- nTotCal) <= (nTotCal * (SFB->FB_PERCALT/100)) ) .Or. !(ABS(nTotCalA - nTotCal) <= SFB->FB_VLRALT)
						oGrid:LoadValue("TRB2_ALQIMP",SFB->FB_ALIQ)
						oGrid:LoadValue("TRB2_VALIMP",nTotCal)
						lRet  := .F.
						Help(, , "HELP", , STR0028, 1, 0) //STR0028:"El valor modificado es superior al valor máximo permitido"
					ElseIf xValue > 100 .Or. xValue < 0
						lRet  := .F.
					Else
						FChgAliq( oGrid, nLine, xValue )
					EndIf
				Else
					lRet := .F.
					Help( ,, "HELP",, STR0011, 1, 0) //"Alíquota não alterada."
				EndIf
			EndIf
		Else
			oGrid:LoadValue("TRB2_ALQIMP",xValue)
			oGrid:LoadValue("TRB2_VALIMP",nTotCalA)
		EndIF

	ElseIf cIDField == "TRB2_BASE"
		nAlqImp := oGrid:GetValue( "TRB2_ALQIMP", nLine )
		nBasImp := oGrid:GetValue( "TRB2_BASIMP2", nLine )
		If !oGrid:CanSetValue( "TRB2_BASIMP" )
			aRmvWhen := FRmvWhen( oGrid, "TRB2_BASIMP" )
		EndIf
		
			oGrid:SetValue( "TRB2_BASIMP", nBasImp - ( nBasImp * ( xValue / 100) ) )
			oGrid:SetValue( "TRB2_VALIMP", nBasImp * ( nAlqImp / 100) )
			
		If !Empty( aRmvWhen )
			oGrid:oFormModelStruct:aFields[aRmvWhen[2],MODEL_FIELD_WHEN] := aRmvWhen[1]
		EndIf
		
	ElseIf cIDField == "TRB2_VALIMP"
	    nBasImp := oGrid:GetValue( "TRB2_BASIMP", nLine )
	    cImp := oGrid:GetValue( "TRB2_IMPOSTO", nLine )
		nImposto := aScan(oImpostos:aArray, {|x| x[1] == cImp} )
	    cLvrFiscal := FGetLFis( cImp )
		If !Empty(cLvrFiscal)
			For nJ := 1 to Len( aItem )
				If !aItem[nJ,Len( aItem[nJ] )] .And. aItem[nJ][nPOSTotal] > 0 .and. MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal ) > 0
					nAlqImp := MaFisRet( nJ, "IT_ALIQIV" + cLvrFiscal )
					Exit
				EndIf
			Next nJ
		EndIf
		nTotCal	:= nBasImp*(nAlqImp)/100
		nTotCalA := nBasImp*(xValue)/100
		IF cPaisLoc <> "ARG" .or. (cPaisLoc == "ARG" .and. nImposto > 0 .and. SFB->FB_PERCALT <> 999999.99)
			
			If !(ABS(xValue - nTotCal) <= (nTotCal * (SFB->FB_PERCALT/100)) ) .Or. !(ABS(xValue - nTotCal) <= SFB->FB_VLRALT)
				oGrid:LoadValue("TRB2_ALQIMP",nAlqImp)
				oGrid:LoadValue("TRB2_VALIMP",nTotCal)
				lRet  := .F.
				Help(, , "HELP", , STR0028, 1, 0) //STR0028: "El valor modificado es superior al valor máximo permitido"
			ElseIf xValue > nBasImp .Or. xValue < 0
				Help(, , "HELP", , STR0024, 1, 0) //STR0024: "El valor imponible debe estar entre 0 y la base imponible."
				lRet := .F. 
			Else
				oGrid:LoadValue("TRB2_ALQIMP", (xValue * 100) / nBasImp)
			EndIf
			
		Else
			oGrid:LoadValue("TRB2_ALQIMP", (xValue * 100) / nBasImp)
			oGrid:LoadValue("TRB2_VALIMP",nTotCalA)
		EndIf
	EndIf

ElseIf cAction == "DELETE"

	If oGrid:GetValue( "TRB2_PUTSYS", nLine ) == "1"
		lRet := .F.
		Help( ,, "HELP",, STR0006, 1, 0) //"Impostos previamente calculados no documento não podem ser excluídos."
	EndIf

EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FRmvWhen

Utilizado para remover o conteudo do When do campo para permitir que
seja inserido valores calculados automaticamente.

@Param oObj - Objeto onde se encontra o campo a ser manipulado
       cCmp - Campo a ser manipulado

@Return aRet - Array com o conteudo a ser reposto no objeto:
               [1] - Conteudo do When do campo manipulado
               [2] - Identificador do campo na estrutura do objeto

@author Felipe C. Seolin
@since 05/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FRmvWhen( oObj, cCmp )

Local aStruct  := {}
Local aRet     := {}
Local bWhen    := Nil
Local nIdField := 0

aStruct := oObj:oFormModelStruct:GetFields()
nIdField := aScan( aStruct, { |x| AllTrim( x[MODEL_FIELD_IDFIELD] ) == cCmp } )
bWhen := oObj:oFormModelStruct:aFields[nIdField,MODEL_FIELD_WHEN]
oObj:oFormModelStruct:aFields[nIdField,MODEL_FIELD_WHEN] := Nil

aRet := { bWhen, nIdField }

Return( aRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FExstImp

Verifica se o imposto inserido ja existe em alguma dimensao da Grid.

@Param oGrid - Objeto de modelo da Grid Inferior, de Impostos
       nLine - Linha posicionada referente ao objeto oGrid

@Return lRet - Informa se existe o imposto inserido em alguma
               dimensao da Grid

@author Felipe C. Seolin
@since 06/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FExstImp( oGrid, nLine )

Local oGridOwner := oGrid:GetOwner()
Local nLineOwner := oGridOwner:GetLine()
Local nI         := 0
Local nJ         := 0
Local cImp       := ""
Local lRet       := .F.

cImp := FwFldGet( "TRB2_IMPOSTO" )

For nI := 1 to oGridOwner:Length()
	oGridOwner:GoLine( nI )
	If oGridOwner:GetLine() <> nLineOwner .and. !lRet
		For nJ := 1 to oGrid:Length()
			If oGrid:GetValue( "TRB2_IMPOSTO", nJ ) == cImp
				lRet := .T.
				Exit
			EndIf
		Next nJ
	EndIf
Next nI

oGridOwner:GoLine( nLineOwner )
oGrid:GoLine( nLine )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FGetAliq

Busca aliquota de imposto ja contido na Grid.

@Param oGrid - Objeto de modelo da Grid Inferior, de Impostos
       nLine - Linha posicionada referente ao objeto oGrid

@Return nAlqImp - Valor da aliquota de imposto ja contido na Grid

@author Felipe C. Seolin
@since 06/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FGetAliq( oGrid, nLine )

Local oGridOwner := oGrid:GetOwner()
Local nLineOwner := oGridOwner:GetLine()
Local nAlqImp    := 0
Local nI         := 0
Local nJ         := 0
Local cImp       := ""
Local lExit      := .F.

cImp := FwFldGet( "TRB2_IMPOSTO" )

For nI := 1 to oGridOwner:Length()
	oGridOwner:GoLine( nI )
	If oGridOwner:GetLine() <> nLineOwner .and. !lExit
		For nJ := 1 to oGrid:Length()
			If oGrid:GetValue( "TRB2_IMPOSTO", nJ ) == cImp
				nAlqImp := oGrid:GetValue( "TRB2_ALQIMP", nJ )
				lExit := .T.
				Exit
			EndIf
		Next nJ
	EndIf
Next nI

oGridOwner:GoLine( nLineOwner )
oGrid:GoLine( nLine )

Return( nAlqImp )

//---------------------------------------------------------------------
/*/{Protheus.doc} FChgAliq

Alimenta a aliquota de um determinado imposto em toda a dimensao da Grid.

@Param oGrid   - Objeto de modelo da Grid Inferior, de Impostos
       nLine   - Linha posicionada referente ao objeto oGrid
       nAlqImp - Valor da aliquota a ser inserido em todo Grid

@author Felipe C. Seolin
@since 06/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FChgAliq( oGrid, nLine, nAlqImp )

Local oGridOwner := oGrid:GetOwner()
Local nLineOwner := oGridOwner:GetLine()
Local nBasImp    := 0
Local nI         := 0
Local nJ         := 0
Local cImp       := ""
Local oView := FWViewActive()

cImp := FwFldGet( "TRB2_IMPOSTO" )

For nI := 1 to oGridOwner:Length()
	oGridOwner:GoLine( nI )
	If oGridOwner:GetLine() <> nLineOwner
		For nJ := 1 to oGrid:Length()
			If oGrid:GetValue( "TRB2_IMPOSTO", nJ ) == cImp
				oGrid:GoLine( nJ )
				oGrid:LoadValue( "TRB2_ALQIMP", nAlqImp )
				nBasImp := oGrid:GetValue( "TRB2_BASIMP", nJ )
				oGrid:SetValue( "TRB2_VALIMP", nBasImp * ( nAlqImp / 100) )
			EndIf
		Next nJ
	EndIf
Next nI

oGridOwner:GoLine( nLineOwner )
oGrid:GoLine( nLine )
oView:Refresh( "MODEL_TRB2" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FCommit

Realiza a manipulacao de informacoes na MatXFis.

@Param oModel - Objeto do modelo MVC

@Return lRet - Informa se a operacao foi realizada

@author Felipe C. Seolin
@since 06/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FCommit( oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local oModelTRB2 := oModel:GetModel( "MODEL_TRB2" )
Local nI         := 0
Local nJ         := 0
Local cLvrFiscal := ""
Local lRet       := .T.
Local cDupTes    := ""
Local cImposto   := ""

For nI := 1 to oModelTRB1:Length() 

	oModelTRB1:GoLine( nI )

	If !oModelTRB1:IsDeleted() .and. !Empty( oModelTRB1:GetValue("TRB1_ITEM", nI ) )
		
		For nJ := 1 to oModelTRB2:Length()

			cImposto := oModelTRB2:GetValue( "TRB2_IMPOSTO", nJ )
			
			If !Empty( oModelTRB2:GetValue( "TRB2_IMPOSTO", nJ ) )
				oModelTRB2:GoLine( nJ )
				
				cLvrFiscal := FGetLFis( oModelTRB2:GetValue( "TRB2_IMPOSTO", nJ )  )
				nvalorI:= MaFisRet(nI,"IT_TOTAL" ) - MaFisRet(nI, "IT_VALIV" + cLvrFiscal )
				MaFisAlt("IT_TOTAL", nvalorI, nI,,,,, .F. )				

				cDupTes := Posicione("SF4",1,xFilial("SF4")+aItem[nI,nPOSTES],"F4_DUPLIC")

				If cDupTes == "S"
					nvalor:= MaFisRet( ,"NF_BASEDUP" ) - MaFisRet(nI, "IT_VALIV" + cLvrFiscal )
					MaFisAlt('NF_BASEDUP',nvalor)
				EndIf
				
				If !oModelTRB2:IsDeleted()
					MaFisAlt( "IT_BASEIV" + cLvrFiscal, oModelTRB2:GetValue( "TRB2_BASIMP", nJ ), nI,,,,, .F. )
					MaFisAlt( "IT_ALIQIV" + cLvrFiscal, oModelTRB2:GetValue( "TRB2_ALQIMP", nJ ), nI,,,,, .F. )
					MaFisAlt( "IT_VALIV" + cLvrFiscal , oModelTRB2:GetValue( "TRB2_VALIMP", nJ ), nI,,,,, .F. )
				Else
					MaFisAlt( "IT_BASEIV" + cLvrFiscal, oModelTRB2:GetValue( "TRB2_BASIMP", nJ ), nI,,,,, .F. )
					MaFisAlt( "IT_ALIQIV" + cLvrFiscal, oModelTRB2:GetValue( "TRB2_ALQIMP", nJ ), nI,,,,, .F. )
					MaFisAlt( "IT_VALIV" + cLvrFiscal , oModelTRB2:GetValue( "TRB2_VALIMP", nJ ), nI,,,,, .F. )
				EndIf

				If(cDupTes $ ("S|N") .and. !Empty(cDupTes))
					DbSelectArea("SFC")
					SFC->(dbSetOrder(2))
					If SFC->(MsSeek(xFilial("SFC") + MaFisRet(nI,"IT_TES") + cImposto)) //FC_FILIAL+FC_TES+FC_IMPOSTO
						If !Empty(SFC->FC_INCDUPL) .And. cDupTes == "S"
							If SFC->FC_INCDUPL == '2' 
								nValor:=MaFisRet( ,"NF_BASEDUP" ) - MaFisRet( nI,"IT_VALIV" + cLvrFiscal )
								MaFisAlt('NF_BASEDUP',nValor)
							ElseIf SFC->FC_INCDUPL == '1'
								nValor:=MaFisRet( ,"NF_BASEDUP" ) + MaFisRet( nI,"IT_VALIV" + cLvrFiscal )
								MaFisAlt('NF_BASEDUP',nValor)
							EndIf
						EndIf
						If !Empty(SFC->FC_INCNOTA)
							If SFC->FC_INCNOTA == '2' 
								nvalorI:= MaFisRet(nI,"IT_TOTAL" ) - MaFisRet(nI, "IT_VALIV" + cLvrFiscal )
								MaFisAlt("IT_TOTAL", nvalorI, nI,,,,, .F. )
							ElseIf SFC->FC_INCNOTA == '1'
								nvalorI:= MaFisRet(nI,"IT_TOTAL" ) + MaFisRet(nI, "IT_VALIV" + cLvrFiscal )
								MaFisAlt("IT_TOTAL", nvalorI, nI,,,,, .F. )
							EndIf
						EndIf
					EndIf
					SFC->(DbCloseArea())
				EndIf
			EndIf
		Next nJ
	EndIf
Next nI

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} FLoadDel

Manipulacoes executadas antes da apresentacao da tela.

@Param oModel - Objeto do modelo MVC

@author Felipe C. Seolin
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FLoadDel( oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local nI         := 0

For nI := 1 to oModelTRB1:Length()
	If aItem[nI,Len( aItem[nI] )]
		oModelTRB1:GoLine( nI )
		oModelTRB1:DeleteLine( , .T. )
	EndIf
Next nI

oModelTRB1:GoLine( 1 )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FChgLine

Manipulacoes na troca de linha do Grid Superior.

@Param oView   - Objeto da interface MVC
       oModel  - Objeto do modelo MVC

@author Felipe C. Seolin
@since 14/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FChgLine( oView, oModel )

Local oModelTRB1 := oModel:GetModel( "MODEL_TRB1" )
Local oModelTRB2 := oModel:GetModel( "MODEL_TRB2" )
Local cItem      := oModelTRB1:GetValue( "TRB1_ITEM", oModelTRB1:GetLine() )

oView:EnableTitleView( "VIEW_TRB2", STR0004 + cItem ) //"Impostos do Item: "
oView:aViews[3,3]:cTitle := STR0004 + cItem //"Impostos do Item: "

oModelTRB2:GoLine( 1 )

oView:Refresh( "MODEL_TRB2" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FIniAlias

Inicializa Area de Trabalho utilizadas.

@author Felipe C. Seolin
@since 18/02/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function FIniAlias()

DBSelectArea( "SFC" )
SFC->( DBSetOrder(1) )

DBSelectArea( "SFB" )
SFB->( DBSetOrder(1) )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} xFilEdtImp

Define qual a chamada para o filtro da consulta padrao SFBFIL.

@author Felipe C. Seolin
@since 12/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function xFilEdtImp()

Local cRet := ""

If IsInCallStack( "FISA081" )
	cRet := xFilter081()
Else
	cRet := xFilter084()
EndIf

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} xFilter081

Filtro da consulta padrao SFBFIL para edicao de impostos por itens.

@author Felipe C. Seolin
@since 12/03/2014
@version 1.0
/*/
//---------------------------------------------------------------------
Function xFilter081()
Local aImp       := {}
Local nI         := 0
Local cImp       := ""
Local cRet       := ""

aImp := FGetImp( aAllTES  )

For nI := 1 to Len( aImp )
	cImp += aImp[nI,1] + "|"
Next nI

cRet := "@#FB_CODIGO $ '" + cImp + "'@#"

Return( cRet )  
