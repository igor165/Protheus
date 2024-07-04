#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE COL_BRW_IDFIELD     01
#DEFINE COL_BRW_TITULO      02
#DEFINE COL_BRW_SETDATA     03
#DEFINE COL_BRW_TIPO        04
#DEFINE COL_BRW_TAMANHO     05
#DEFINE COL_BRW_DECIMAL     06
#DEFINE COL_BRW_PICT        07
#DEFINE COL_BRW_ALINHAMENTO 08
#DEFINE COL_BRW_COMBOVALUES 09

#DEFINE COL_TAB_IDFIELD     01
#DEFINE COL_TAB_TIPO        02
#DEFINE COL_TAB_TAMANHO     03
#DEFINE COL_TAB_DECIMAL     04

#DEFINE COL_FILTRO_IDFIELD     01
#DEFINE COL_FILTRO_TITULO      02
#DEFINE COL_FILTRO_TIPO        03
#DEFINE COL_FILTRO_TAMANHO     04
#DEFINE COL_FILTRO_DECIMAL     05
#DEFINE COL_FILTRO_PICT        06

Function OFBrowseStruct()
Return()


/*/{Protheus.doc} OFBrowseStruct

Classe auxiliar para facilitar a utilizacao de browse com tabela temporaria

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
Class OFBrowseStruct

	Data _aTables
	Data _aColBrw
	Data _aColTabTMP
	Data _aColFilter
	Data _aSeek
	Data _cAliasTmp
	Data _aIndex

	Data _cNomeBrowse

	Data _lTable
	Data _lArray
	Data _lQuery
	Data _cQuery

	Data _oTabTmp // FWTemporaryTable

	Data _oBrwOwner
	Data _aBrwColumns

	Method New() CONSTRUCTOR
	Method Clean()
	Method AddField()
	Method AddFieldManual()
	Method AddMarkField()
	Method AddTabStru()
	Method AddMultTabStru()
	Method AddBrwColumn()

	Method CriaTabTmp()
	Method LoadData(cQuery)
	Method DelTrabTmp()

	Method SetTable()
	Method SetArray()
	Method SetQuery()
	Method SetNomeBrowse()

	Method AddSeek()
	Method AddIndex()
	Method AddIndexArray()

	Method SetBrwOwner()

	Method GetAlias()
	Method GetRealName()
	Method GetSeek()
	Method GetColFilter()
	Method GetIndexes()
	Method GetColTabTMP()
	Method GetColBrw()

	Method _FindTable()
	Method _PosTable()
	Method _PosFieldModel()
	Method _PosFieldView()

EndClass

/*/{Protheus.doc} New
Metodo de inicializacao da classe

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param aParTables, array, Array com tabelas que serao utilizadas no browse
@type function
/*/
Method New(aParTables) Class OFBrowseStruct
	Default aParTables := {}

	self:_aTables := {}
	self:_aColBrw := {}
	self:_aColTabTMP := {}
	self:_aColFilter := {}
	self:_aBrwColumns := {}
	self:_aSeek := {}
	self:_aIndex := {}

	self:_cAliasTmp := ""

	self:_lTable := .t.
	self:_lArray := .f.
	self:_lQuery := .f.
	self:_cQuery := ""

	self:_cNomeBrowse := ""

	self:_oTabTmp := OFDMSTempTable():New()

	self:AddMultTabStru(aParTables)
	
Return self

Method Clean() Class OFBrowseStruct
	self:_aColBrw := {}
	self:_aColTabTMP := {}
	self:_aColFilter := {}
	self:_aBrwColumns := {}
	self:_aSeek := {}
	self:_aIndex := {}
	self:_oBrwOwner := NIL

	self:_cAliasTmp := ""

	self:_cQuery := ""
	
	self:_cNomeBrowse := ""
Return

/*/{Protheus.doc} CriaTabTmp
Cria tabela temporaria de acordo com os campos adicionados no browse
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method CriaTabTmp() Class OFBrowseStruct
	Local nPosIndex 

	//CriaTabTmp( self:_aColTabTMP , self:_aIndex , self:_cAliasTmp , @self:_oTabTmp )
	self:_oTabTmp:SetVetCampos( self:_aColTabTMP )
	For nPosIndex := 1 to Len(self:_aIndex)
		self:_oTabTmp:AddIndex(, self:_aIndex[nPosIndex] )
	Next nPosIndex
	self:_oTabTmp:CreateTable()
	If Empty(self:_cAliasTmp)
		//self:_cAliasTmp := GetNextAlias()
		self:_cAliasTmp := self:_oTabTmp:GetAlias()
	EndIf
Return

/*/{Protheus.doc} LoadData
Carrega dados na tabela temporaria de acordo com a query utilizada no browse.
Atenção para que as colunas na retornem valores NULOS, quando necessário faca tratamento com COALESCE por exemplo.
Atenção para a ordem dos campos na query, como a função faz um INSERT from SELECT, a ordem dos campos no SELECT deve ser igual a ordem de crição dos campos na browse.

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cQuery, characters, Query utilizada para carregamento dos dados na tabela temporaria
@param lClearData, logical, Indica se deve limpar tabela antes da inclusao dos dados
@type function
/*/
Method LoadData(cQuery, lClearData) Class OFBrowseStruct

	//Local cAuxAlias := self:_oTabTmp:GetAlias()

	Default cQuery := self:_cQuery
	Default lClearData := .f.
	
	If lClearData
		//(cAuxAlias)->(__DBZap())
		self:_oTabTmp:ClearTable()
	EndIf

	self:_oTabTmp:InsertSQL(cQuery)
	
Return

Method SetTable() Class OFBrowseStruct
	self:_lTable := .t.
	self:_lArray := .f.
	self:_lQuery := .f.
Return

Method SetArray() Class OFBrowseStruct
	self:_lTable := .f.
	self:_lArray := .t.
	self:_lQuery := .f.
Return

Method SetQuery() Class OFBrowseStruct
	self:_lTable := .f.
	self:_lArray := .f.
	self:_lQuery := .t.
Return

Method SetNomeBrowse(cNome) Class OFBrowseStruct
	self:_cNomeBrowse := cNome
Return

/*/{Protheus.doc} AddField
Adiciona um campo no browse
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cFieldName, characters, descricao
@param cFieldTitle, characters, descricao
@type function
/*/
Method AddField(cFieldName, cFieldTitle, lAddBrowse ) Class OFBrowseStruct

	Local oColumn

	Default cFieldTitle := "_"
	Default lAddBrowse := .t.

	cTableName := FWTabPref( cFieldName )

	nPosTable := self:_PosTable( cTableName )
	If nPosTable == 0
		nPosTable := self:AddTabStru(cTableName)
	EndIf

	nPosFieldModel := self:_PosFieldModel( nPosTable, cFieldName )
	nPosFieldView := self:_PosFieldView( nPosTable, cFieldName )

	If cFieldTitle == "_"
		cFieldTitle := self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL ][ nPosFieldModel ][ MVC_MODEL_TITULO ]
	EndIf

	If lAddBrowse

		Do Case
			Case self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL ][ nPosFieldModel ][ MVC_MODEL_TIPO ] = "N"
				nAlinhamento := COLUMN_ALIGN_RIGHT
			Otherwise
				nAlinhamento := COLUMN_ALIGN_LEFT
		EndCase

		If self:_lArray
			cSetData := "{ || " + self:_cNomeBrowse + ":oData:aArray[" + self:_cNomeBrowse + ":At()," + AllTrim(STR(Len(self:_aColTabTMP)+1,3)) + "] } "
		Else
			cSetData := "{ || " + self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_IDFIELD ] + " }"
		EndIf

		aOpt := self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL ][ nPosFieldModel ][ MVC_MODEL_VALUES ]

		aAdd( self:_aColBrw , {;
			self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_IDFIELD ] ,; // 01
			cFieldTitle ,; // 02
			cSetData ,; // 03
			self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_TIPO ] ,; // 04
			self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_TAMANHO ] ,; // 05
			self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_DECIMAL ] ,; // 06
			IIf( nPosFieldView == 0 , "" , self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_VIEW][ nPosFieldView ][ MVC_VIEW_PICT ] ) ,; // 07
			nAlinhamento ,; // 08
			aOpt }) // 09

	EndIf

	aAdd( self:_aColTabTMP , {;
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_IDFIELD ],; // 1
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_TIPO ],; // 2
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_TAMANHO ],; // 3
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_DECIMAL ] }) // 4

	aAdd( self:_aColFilter , {;
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_IDFIELD ],; // 1
		cFieldTitle,; // 2
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_TIPO ],; // 3
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_TAMANHO ],; // 4
		self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_MODEL][ nPosFieldModel ][ MVC_MODEL_DECIMAL ],; // 5
		IIf( nPosFieldView == 0 , "" , self:_aTables[ nPosTable ][2][ FORM_STRUCT_TABLE_VIEW][ nPosFieldView ][ MVC_VIEW_PICT ] ) } ) // 6

	If self:_oBrwOwner <> NIL .and. lAddBrowse
		nLinCol := Len(self:_aColBrw)

		ADD COLUMN oColumn ;
			DATA &(self:_aColBrw[nLinCol, COL_BRW_SETDATA ]) ;
			TYPE self:_aColBrw[nLinCol, COL_BRW_TIPO] ;
			TITLE self:_aColBrw[nLinCol, COL_BRW_TITULO] ;
			SIZE self:_aColBrw[nLinCol, COL_BRW_TAMANHO] ;
			DECIMAL self:_aColBrw[nLinCol, COL_BRW_DECIMAL] ;
			PICTURE self:_aColBrw[nLinCol, COL_BRW_PICT] ;
			OPTIONS self:_aColBrw[nLinCol, COL_BRW_COMBOVALUES] ;
			ALIGN self:_aColBrw[nLinCol, COL_BRW_ALINHAMENTO] ;
			ID self:_aColBrw[nLinCol, COL_BRW_IDFIELD];
			OF self:_oBrwOwner
	EndIf
Return


Method AddMarkField(cFieldName, lAddBrowse) Class OFBrowseStruct

	Local cSetData
	Default cFieldName := "MK_OK"
	Default lAddBrowse := .f.
	
	If lAddBrowse
		If self:_lArray
			cSetData := "{ || " + self:_cNomeBrowse + ":oData:aArray[" + self:_cNomeBrowse + ":At()," + AllTrim(STR(Len(self:_aColTabTMP)+1,3)) + "] } "
		Else
			cSetData := "{|| " + cFieldName + " }"
		EndIf

		aAdd( self:_aColBrw , {;
			cFieldName ,; // 01
			"" ,; // 02
			cSetData ,; // 03
			"C" ,; // 04
			1 ,; // 05
			0 ,; // 06
			"" ,; // 07
			COLUMN_ALIGN_LEFT ,; // 08
			{} }) // 09
	EndIf

	aAdd( self:_aColTabTMP , {;
		cFieldName,; // 1
		"C",; // 2
		1,; // 3
		0 }) // 4

	If self:_oBrwOwner <> NIL .and. lAddBrowse
		nLinCol := Len(self:_aColBrw)

		ADD COLUMN oColumn ;
			DATA &(self:_aColBrw[nLinCol, COL_BRW_SETDATA ]) ;
			TYPE self:_aColBrw[nLinCol, COL_BRW_TIPO] ;
			TITLE self:_aColBrw[nLinCol, COL_BRW_TITULO] ;
			SIZE self:_aColBrw[nLinCol, COL_BRW_TAMANHO] ;
			DECIMAL self:_aColBrw[nLinCol, COL_BRW_DECIMAL] ;
			PICTURE self:_aColBrw[nLinCol, COL_BRW_PICT] ;
			OPTIONS self:_aColBrw[nLinCol, COL_BRW_COMBOVALUES] ;
			ALIGN self:_aColBrw[nLinCol, COL_BRW_ALINHAMENTO] ;
			ID self:_aColBrw[nLinCol, COL_BRW_IDFIELD];
			OF self:_oBrwOwner
	EndIf
Return

/*/{Protheus.doc} AddFieldManual
Adiciona um campo no browse
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param oFieldData, object, Objeto do tipo DataContainer com os dados do campo a ser criado
@param lAddBrowse, logical, Indica se o campo deve ser adicionado no browse
@type function
/*/
Method AddFieldManual(oFieldData, lAddBrowse) Class OFBrowseStruct

	Local oColumn

	Default lAddBrowse := .t.

	If lAddBrowse

		Do Case
			Case oFieldData:GV('cTipo') == "N"
				nAlinhamento := COLUMN_ALIGN_RIGHT
			Otherwise
				nAlinhamento := COLUMN_ALIGN_LEFT
		EndCase

		If self:_lArray
			cSetData := "{ || " + self:_cNomeBrowse + ":oData:aArray[" + self:_cNomeBrowse + ":At()," + AllTrim(STR(Len(self:_aColTabTMP)+1,3)) + "] } "
		Else
			cSetData := "{ || " + oFieldData:GV('cIdField') + " }"
		EndIf

		aOpt := oFieldData:GV('aComboValues', {} )

		aAdd( self:_aColBrw , {;
			oFieldData:GV('cIdField') ,; // 01
			oFieldData:GV('cTitulo') ,; // 02
			cSetData ,; // 03
			oFieldData:GV('cTipo') ,; // 04
			oFieldData:GV('nTamanho') ,;// 05
			oFieldData:GV('nDecimal',0) ,;// 06
			oFieldData:GV('cPicture') ,; // 07
			nAlinhamento ,; // 08
			aOpt }) // 09

	EndIf

	aAdd( self:_aColTabTMP , {;
		oFieldData:GV('cIdField'),; // 1
		oFieldData:GV('cTipo'),; // 2
		oFieldData:GV('nTamanho'),; // 3
		oFieldData:GV('nDecimal',0) }) // 4

	aAdd( self:_aColFilter , {;
		oFieldData:GV('cIdField'),; // 1
		oFieldData:GV('cTitulo'),; // 2
		oFieldData:GV('cTipo'),; // 3
		oFieldData:GV('nTamanho'),; // 4
		oFieldData:GV('nDecimal',0),; // 5
		oFieldData:GV('cPicture') }) // 6

	If self:_oBrwOwner <> NIL .and. lAddBrowse
		nLinCol := Len(self:_aColBrw)

		ADD COLUMN oColumn ;
			DATA &(self:_aColBrw[nLinCol, COL_BRW_SETDATA ]) ;
			TYPE self:_aColBrw[nLinCol, COL_BRW_TIPO] ;
			TITLE self:_aColBrw[nLinCol, COL_BRW_TITULO] ;
			SIZE self:_aColBrw[nLinCol, COL_BRW_TAMANHO] ;
			DECIMAL self:_aColBrw[nLinCol, COL_BRW_DECIMAL] ;
			PICTURE self:_aColBrw[nLinCol, COL_BRW_PICT] ;
			OPTIONS self:_aColBrw[nLinCol, COL_BRW_COMBOVALUES] ;
			ALIGN self:_aColBrw[nLinCol, COL_BRW_ALINHAMENTO] ;
			ID self:_aColBrw[nLinCol, COL_BRW_IDFIELD];
			OF self:_oBrwOwner
	EndIf

Return

/*/{Protheus.doc} AddTabStru
Adiciona uma estrutura de tabela na classe para utilizacao no metodo AddField

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTableName, characters, descricao
@type function
/*/
Method AddTabStru(cTableName) Class OFBrowseStruct
	Local nPosTab := self:_PosTable( cTableName )
	If nPosTab > 0
		Return nPosTab
	EndIf

	AADD( self:_aTables , { cTableName , FWFormStruct( 3 , cTableName ,, .f. ) })
Return Len(self:_aTables)

/*/{Protheus.doc} AddMultTabStru
Adiciona multiplas estruturas de tabelas na classe para utilizacao no metodo AddField

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param aParTables, array, descricao
@type function
/*/
Method AddMultTabStru(aParTables) Class OFBrowseStruct
	Local nPosTable

	For nPosTable := 1 to Len(aParTables)
		self:AddTabStru( aParTables[nPosTable] )
	Next nPosTable
Return

/*/{Protheus.doc} SetBrwOwner
Permite adicionar a propriedade responsável por controlar o browse que será criado com a ajuda desta classe

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param oAuxBrowser, object, descricao
@type function
/*/
Method SetBrwOwner(oAuxBrowser, cNomeBrowse) Class OFBrowseStruct
	Default cNomeBrowse := ""
	self:_oBrwOwner := oAuxBrowser
	self:_cNomeBrowse := cNomeBrowse
Return

/*/{Protheus.doc} AddBrwColumn
Adiciona colunas (FWBrwColumn) no browse criado utilizando esta classe.
Se utilizado SetBrwOwner antes do AddField, nao é necessário chamar este metodo pois as colunas serao criadas no momento da execucao do AddField.

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method AddBrwColumn() Class OFBrowseStruct
	Local nLinCol
	Local cNomeColuna

	self:_aBrwColumns := {}

	For nLinCol := 1 to Len(self:_aColBrw)

		cNomeColuna := "oCol" + StrZero(nLinCol,3)

		&(cNomeColuna) := FWBrwColumn():New()
		&(cNomeColuna):SetID( self:_aColBrw[ nLinCol , COL_BRW_IDFIELD ] )
		&(cNomeColuna):SetData(&( self:_aColBrw[ nLinCol , COL_BRW_SETDATA ]) )
		&(cNomeColuna):SetType( self:_aColBrw[ nLinCol , COL_BRW_TIPO ] )
		&(cNomeColuna):SetSize( self:_aColBrw[ nLinCol , COL_BRW_TAMANHO ] )
		&(cNomeColuna):SetDecimal( self:_aColBrw[ nLinCol , COL_BRW_DECIMAL ] )
		&(cNomeColuna):SetPicture( self:_aColBrw[ nLinCol , COL_BRW_PICT ] )
		&(cNomeColuna):SetAlign( self:_aColBrw[ nLinCol , COL_BRW_ALINHAMENTO ] )
		&(cNomeColuna):SetOptions( self:_aColBrw[ nLinCol , COL_BRW_COMBOVALUES ] )
		&(cNomeColuna):SetTitle( self:_aColBrw[ nLinCol , COL_BRW_TITULO ] )

		AADD( self:_aBrwColumns , &(cNomeColuna) )

	Next nLinCol

	If self:_oBrwOwner <> NIL
		self:_oBrwOwner:SetColumns( self:_aBrwColumns )
	EndIf

Return

/*/{Protheus.doc} AddSeek
Adiciona uma opção de Seek de acordo com uma relacao de campos enviadas ao metodo
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param aColumns, array, Array contendo os campos que serao utilizado no seek, os campos devem exitir no browse.
@type function
/*/
Method AddSeek(aColumns) Class OFBrowseStruct

	Local nPosFiltro
	Local nPosCol
	Local aAuxColSeek := {}
	Local cNome := ""

	For nPosCol := 1 to Len(aColumns)

		nPosFiltro := aScan( self:_aColBrw , { |x| x[ COL_BRW_IDFIELD ] == aColumns[nPosCol] })

		cNome += AllTrim(self:_aColBrw[nPosFiltro, COL_BRW_TITULO ]) + IIF(nPosCol == Len(aColumns) , "" , " + ")

		AADD( aAuxColSeek , ;
			{;
				"",;
				"C",;
				self:_aColBrw[nPosFiltro, COL_BRW_TAMANHO ] ,;
				self:_aColBrw[nPosFiltro, COL_BRW_DECIMAL ] ,;
				self:_aColBrw[nPosFiltro, COL_BRW_TITULO ] ,;
				self:_aColBrw[nPosFiltro, COL_BRW_PICT ] ;
			};
		)
	Next nPosCol

	AAdd(self:_aSeek, { cNome, aAuxColSeek } )

Return 

/*/{Protheus.doc} AddIndex
Adiciona um indece ao browse
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cColumns, characters, descricao
@type function
/*/
Method AddIndex(cColumns) Class OFBrowseStruct
	//AADD( self:_aIndex , cColumns )
	self:AddIndexArray(Strtokarr2( cColumns, "+", .f.))
Return

Method AddIndexArray(aColumns) Class OFBrowseStruct
	AADD( self:_aIndex , aColumns )
Return

/*/{Protheus.doc} GetAlias
Retorna o Alias gerado para a tabela temporaria
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method GetAlias() Class OFBrowseStruct
Return self:_cAliasTmp

Method GetRealName() Class OFBrowseStruct
Return self:_oTabTmp:GetRealName()

/*/{Protheus.doc} GetSeek
Retorna o array de seeks gerados
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method GetSeek() Class OFBrowseStruct
Return self:_aSeek

Method GetColFilter() Class OFBrowseStruct
Return self:_aColFilter

Method GetIndexes() Class OFBrowseStruct
Return self:_aIndex

Method GetColTabTMP() Class OFBrowseStruct
Return self:_aColTabTMP

Method GetColBrw() Class OFBrowseStruct
Return self:_aColBrw

/*/{Protheus.doc} DelTrabTmp
Exclui tabela temporaria.
Metodo deve ser chamado apos o fechamento do browse.

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method DelTrabTmp() Class OFBrowseStruct
	//DelTabTmp(self:_cAliasTmp , self:_oTabTmp)
	self:_oTabTmp:CloseTable()
Return

/*/{Protheus.doc} _FindTable
Metodo interno utilizado para verificar se uma tabela já foi adicionada na array de estruturas
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTableName, characters, descricao
@type function
/*/
Method _FindTable( cTableName ) Class OFBrowseStruct
Return (aScan( self:_aTables, { |x| x[1] == cTableName }) > 0)

/*/{Protheus.doc} _PosTable
Metodo interno utilizado para retornar a linha da tabela na array de estruturas
@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTableName, characters, descricao
@type function
/*/
Method _PosTable( cTableName ) Class OFBrowseStruct
Return (aScan( self:_aTables, { |x| x[1] == cTableName }))

/*/{Protheus.doc} _PosFieldModel
Retorna a linha da array de estruturas (MODEL) de um determinado campo

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param nPosTable, numeric, descricao
@param cFieldName, characters, descricao
@type function
/*/
Method _PosFieldModel( nPosTable, cFieldName ) Class OFBrowseStruct
Return (aScan(self:_aTables[nPosTable, 2, FORM_STRUCT_TABLE_MODEL] , { |x| x[MVC_MODEL_IDFIELD] == cFieldName } ))

/*/{Protheus.doc} _PosFieldView
Retorna a linha da array de estruturas (VIEW) de um determinado campo

@author Rubens
@since 22/04/2019
@version 1.0
@return ${return}, ${return_description}
@param nPosTable, numeric, descricao
@param cFieldName, characters, descricao
@type function
/*/
Method _PosFieldView( nPosTable, cFieldName ) Class OFBrowseStruct
Return (aScan(self:_aTables[nPosTable, 2, FORM_STRUCT_TABLE_VIEW] , { |x| x[MVC_VIEW_IDFIELD] == cFieldName } ))