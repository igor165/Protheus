////////////////
// Versao 010 //
////////////////

#include "protheus.ch"

#DEFINE X3_USADO_EMUSO "€€€€€€€€€€€€€€ "	// TORNA USADO POR TODOS OS MODULOS

Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007106_1"

Function VEICLSAI()
Return()

/*/{Protheus.doc} DMS_InterfaceHelper

	Classe criada para auxiliar o desenvolvedor a criar Objetos de Interface.

	@author Rubens
	@since 10/08/2015
	@version 1.0

	@type class
/*/
Class DMS_InterfaceHelper From LongNameClass

	Data aCpoMsMGet
	Data aButtons
	Data aAuxHeader
	Data aHeaderObrigat
	Data aAlterNGDados
	Data aAuxLinACols
	Data cOwnerPvtVar
	Data cPrefixo
	Data nOpc
	Data cAlias
	Data oDefSize
	Data cNomObjDefSize
	Data oDialog

	Data nAlinhamento
	Data lSetPosicao
	Data nLININI
	Data nLINEND
	Data nCOLINI
	Data nCOLEND
	Data nXSIZE
	Data nYSIZE

	Method New() CONSTRUCTOR

	Method SetPrefixo()
	Method SetDefSize()
	Method SetNomeObjDefSize()
	Method SetOwnerPvt()
	Method SetDialog()

	Method RetPosicao()

	Method Clean()

	Method AddMGet()		// Adiciona MsMGet com base no dicioanrio (SX3)
	Method AddMGetTipo()	// Adiciona MsMGet com base no dicioanrio (SX3)
	Method AddMGetTAB()	// Adiciona MsMGet com base no dicioanrio (SX3)

	Method AddButton()		// Adiciona Botao

	Method AddColLBox()

	Method MGetRetCpo()
	Method MGetRetAAlter()
	Method MGetRetHeader()
	Method MGetRetObrigat()

	Method CreateMSMGet()
	Method CreateDefSize()
	Method CreateDialog()
	Method CreateLBox()
	Method CreateNewGetDados()
	Method CreateLinaCols()
	Method CreateTSay()
	Method CreateTGet()
	Method CreateTFolder()
	Method CreateTPanel()
	Method CreateTScroll()
	Method CreateMGroup()
	Method CreateGrpButton()

//	Method AddHeadX3()
//	Method AddHeadX3Manual()
//	Method AddHeadManual()

	Method AddWalkThru()

	Method AddHeader()
	Method AddHeaderOBJ()
	Method AddHeaderTAB()

	// Metodos Auxiliares
	//Method PesqSX3()

EndClass

/*/{Protheus.doc} New
	Construtor de Classe
	@author Rubens
	@since 10/08/2015
	@version 1.0
	@type function
/*/
Method New() Class DMS_InterfaceHelper
	Self:Clean()
Return Self

/*/{Protheus.doc} Clean
	Metodo para limpar todas as propriedades da classe. Necessário executar a cada criação de um objeto novo.
	@author Rubens
	@since 10/08/2015
	@version 1.0
	@type function
/*/
Method Clean() Class DMS_InterfaceHelper
	Self:cPrefixo := ""
	Self:aCpoMsMGet := {}
	Self:aButtons := {}
	Self:aAuxHeader := {}
	Self:aHeaderObrigat := {}
	Self:aAlterNGDados := {}
	Self:aAuxLinACols := {}
//	Self:nOpc := 0
	Self:cAlias := NIL
Return

/*/{Protheus.doc} SetPrefixo

	Define um prefixo que sera utilizado quando criado uma variavel de tela a partir do dicionario de dados

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param pPrefixo, character, String que sera utilizada como prefixo para a criacao de variáveis
	@type function

/*/
Method SetPrefixo(pPrefixo) Class DMS_InterfaceHelper
	Self:cPrefixo := pPrefixo
Return

/*/{Protheus.doc} SetDefSize

	Define o Objeto do tipo FWDefSize que será utilizado para a criação de um objeto de tela

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param oObjDefSize, objeto, Instancia da classe FWDefSize
	@param cNomeObj, character, Identificador do item da classe FWDefSize

/*/
Method SetDefSize(oObjDefSize,cNomeObj) Class DMS_InterfaceHelper
	Default cNomeObj := ""
	Self:oDefSize := oObjDefSize
	If !Empty(cNomeObj)
		Self:SetNomeObjDefSize(cNomeObj)
	EndIf
Return

/*/{Protheus.doc} SetNomeObjDefSize

	Define o identificador da classe FWDefSize que será utilizado

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param cNomeObj, character, Identificador do item da classe FWDefSize

/*/
Method SetNomeObjDefSize(cNomeObj) Class DMS_InterfaceHelper
	Self:cNomObjDefSize := cNomeObj
Return

/*/{Protheus.doc} SetOwnerPvt

	Define o nome do Owner das variaveis privates que serao criadas

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param cAuxOwner, character, Nome do Owner utilizado para a criacao de variaveis privates
	@type function

/*/
Method SetOwnerPvt(cAuxOwner) Class DMS_InterfaceHelper
	Self:cOwnerPvtVar := cAuxOwner
Return

/*/{Protheus.doc} SetDialog

	Define o objeto Dialog que será utilizado na criacao dos objetos.

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param poDialog, objeto, Define a instancia do tipo Dialog que sera utilizada na criacao dos objetos de tela

/*/
Method SetDialog(poDialog) Class DMS_InterfaceHelper
	Self:oDialog := poDialog
Return

/*/{Protheus.doc} AddMGet

	Adiciona um objeto GET

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param cCpoPadrao, character, Campo do dicionario utilizado de base para a criacao do GET
	@param aDataContainer, array, Matriz com parametros para a criacao de um objeto GET na MsMGet

/*/
Method AddMGet( cCpoPadrao , aDataContainer ) Class DMS_InterfaceHelper
	Local cAuxCpo
	Local cGerNCampo := ""
	Local uVar
	Local oCustomizacao
	Local cValPadr
	Local lObrigatorio
	Default aDataContainer := {}

	oCustomizacao := DMS_DataContainer():New(aDataContainer)

	SX3->(dbSetOrder(2))
	SX3->(dbSeek(cCpoPadrao))

	If Empty(Self:cPrefixo)
		cGerNCampo := cCpoPadrao
	Else
		cGerNCampo := Self:cPrefixo + SubStr( cCpoPadrao , At("_",cCpoPadrao))
	EndIf

	cAuxCpo    := oCustomizacao:GetValue("X3_CAMPO", oCustomizacao:GetValue("NOMECAMPO", cGerNCampo))
	lVisualiza := (oCustomizacao:GetValue("X3_VISUAL" , IIF(SX3->(Found()), SX3->X3_VISUAL, "V" )) == "V")
	cValidacao := oCustomizacao:GetValue("X3_VALID" , IIF(SX3->(Found()), AllTrim(SX3->X3_VALID), '.T.'))

	If lVisualiza
		lObrigatorio := .f.
	Else
		lObrigatorio := IIF(SX3->(Found()), X3Obrigat(cCpoPadrao), .F.)
		lObrigatorio := oCustomizacao:GetValue("X3_OBRIGAT", oCustomizacao:GetValue("OBRIGATORIO", lObrigatorio))
	EndIf

	cValPadr := oCustomizacao:GetValue("X3_RELACAO", oCustomizacao:GetValue("VALOR_PADRAO", '' ))

	If SX3->(FOUND())
		Aadd(Self:aAuxHeader, { ;
			oCustomizacao:GetValue( "X3_TITULO" , TRIM(X3Titulo()) ) , ;		// 01 - Título
			cAuxCpo , ;															// 02 - Campo
			oCustomizacao:GetValue("X3_TIPO"   , SX3->X3_TIPO ) , ;				// 03 - Tipo
			oCustomizacao:GetValue("X3_TAMANHO", SX3->X3_TAMANHO), ;			// 04 - Tamanho
			oCustomizacao:GetValue("X3_DECIMAL", SX3->X3_DECIMAL), ;			// 05 - Decimal
			oCustomizacao:GetValue("X3_PICTURE", AllTrim(SX3->X3_PICTURE)), ;	// 06 - Picture
			IIf( !Empty(cValidacao) , &("{ || " + cValidacao + " }") , "" ), ;	// 07 - Valid
			lObrigatorio, ;														// 08 - Obrigat
			1 , ;																// 09 - Nivel
			cValPadr, ;															// 10 - Inicializador Padrão
			oCustomizacao:GetValue("X3_F3", SX3->X3_F3), ;						// 11 - F3
			oCustomizacao:GetValue("X3_WHEN", SX3->X3_WHEN), ;					// 12 - When
			lVisualiza , ;														// 13 - Visual
			.F., ;																// 14 - Chave
			oCustomizacao:GetValue("X3_CBOX", SX3->(X3CBox())), ;				// 15 - Box - Opção do combo
			, ;																	// 16 - Folder (vazio por causa do parâmetro MV_ENCHOLD)
			lVisualiza, ;														// 17 - Não Alterável
			SX3->X3_PICTVAR, ;													// 18 - PictVar
			"N";																// 19 - Gatilho
		})

		AADD( Self:aCpoMsMGet , cAuxCpo )
		If !lVisualiza
			AADD(Self:aAlterNGDados,cAuxCpo)
		EndIf

		uVar := CriaVar(SX3->X3_CAMPO,.f.)
	Else
		Aadd(Self:aAuxHeader, { ;
			oCustomizacao:GetValue("X3_TITULO" , TRIM(X3Titulo()) ) , ;			// 01 - Título
			cAuxCpo , ;															// 02 - Campo
			oCustomizacao:GetValue("X3_TIPO"   , 'C') , ;						// 03 - Tipo
			oCustomizacao:GetValue("X3_TAMANHO", 10), ;							// 04 - Tamanho
			oCustomizacao:GetValue("X3_DECIMAL", 0), 				;			// 05 - Decimal
			oCustomizacao:GetValue("X3_PICTURE", ''), ;							// 06 - Picture
			IIf( !Empty(cValidacao) , &("{ || " + cValidacao + " }") , "" ), ;	// 07 - Valid
			lObrigatorio, ;														// 08 - Obrigat
			1 , ;																// 09 - Nivel
			cValPadr, ;															// 10 - Inicializador Padrão
			oCustomizacao:GetValue("X3_F3", ''), ;								// 11 - F3
			oCustomizacao:GetValue("X3_WHEN", ''), ;							// 12 - When
			lVisualiza, ;														// 13 - Visual
			.F., ;																// 14 - Chave
			oCustomizacao:GetValue("X3_CBOX", ''), ;							// 15 - Box - Opção do combo
			, ;																	// 16 - Folder (vazio por causa do parâmetro MV_ENCHOLD)
			lVisualiza, ;														// 17 - Não Alterável
			"", ;																// 18 - PictVar
			"N";																// 19 - Gatilho
		})

		AADD( Self:aCpoMsMGet , cAuxCpo )
		If !lVisualiza
			AADD(Self:aAlterNGDados,cAuxCpo)
		EndIf

		uVar := cValPadr
	EndIf

	CriaPrvVar( cCpoPadrao , uVar , Self:cOwnerPvtVar )
	CriaPrvVar( cAuxCpo    , uVar , Self:cOwnerPvtVar )

Return


/*/{Protheus.doc} AddMGetTipo

	Adiciona um objeto GET

	@author Vinicius
	@since 20/04/2017
	@version 1.0
	@param aData, array, Deverá contem dadaos obrigatórios:<br>

	X3_TIPO:    Tipo da variavel que será utilizada no MGET conforme X3_TIPO<br>
	X3_CAMPO: Nome do campo que sera criado na tela e será acessivel via M->
	X3_TAMANHO: Tamanho/Nro de caracteres do campo que será criado
	X3_XXX: N X3 gerais para customização.

	@type function
/*/
Method AddMGetTipo(aData) Class DMS_InterfaceHelper
	Local oParams   := DMS_DataContainer():New(aData)
	Local cTipo     := oParams:GetValue('X3_TIPO', 'C')
	Local oCol      := Nil
	Local aDadosCol := Nil
	Local nX        := 1
	Local oX3Data   := Nil

	// Esse array é um alias, pois nas classes ifcol usa sem X3_, e acho que o
	// padrao daqui pra frente deve ser usar X3_ pra tudo assim nem precisaria desse bloco
	aDadosCol := {;
		{'TITULO'     , oParams:GetValue('X3_TITULO'     , '')},;
		{'CAMPO'      , oParams:GetValue('X3_CAMPO'      , '')},;
		{'TAMANHO'    , oParams:GetValue('X3_TAMANHO'    ,  0)},;
		{'DECIMAL'    , oParams:GetValue('X3_DECIMAL'    ,  0)},;
		{'ALTERA'     , oParams:GetValue('X3_ALTERA'     ,.T.)},;
		{'TITULO'     , oParams:GetValue('X3_TITULO'     , '')},;
		{'OBRIGATORIO', oParams:GetValue('X3_OBRIGATORIO',.F.)} ;
	}

	Do Case
		Case cTipo == 'C' ; oCol := DMS_IFColString():New(aDadosCol)
		Case cTipo == 'M' ; oCol := DMS_IFColMemo():New(aDadosCol)
		Case cTipo == 'N' ; oCol := DMS_IFColNumero():New(aDadosCol)
		Case cTipo == 'D' ; oCol := DMS_IFColString():New(aDadosCol) // tentar trocar tipo pra D
		Case cTipo == 'L' ; oCol := DMS_IFColLogical():New(aDadosCol)
	End Case

	oX3Data := DMS_DataContainer():New(oCol:GetX3LikeParams())

	For nX := 1 to Len(aData)
		oX3Data:SetValue( aData[nX, 1], aData[nX, 2] )
	Next

	self:AddMGet(oParams:GetValue('X3_CAMPO'), oX3Data:aData ) //aData são os dados do datacontainer em formato array puro
Return .T.

/*/{Protheus.doc} AddMGetTAB
Seleciona os campos de uma determinada tabela a um objeto do tipo MSMGet
@author Rubens
@since 04/07/2017
@version undefined
@param cTabela, characters, descricao
@param aDataContainer, array, descricao
@type function
/*/
Method AddMGetTAB( cTabela , aDataContainer ) Class DMS_InterfaceHelper

	Local oParam := DMS_DataContainer():New(aDataContainer)

	Local cNaoMostra    := oParam:GetValue("NAOMOSTRA","")
	Local cMostra       := oParam:GetValue("MOSTRA","")
	Local lFilNaoMostra := !Empty(cNaoMostra)
	Local lFilMostra    := !Empty(cMostra)
	Local cCpoFilial    := IIF( Left(cTabela,1) == "S" , Right(cTabela,2) , cTabela ) + "_FILIAL"
	Local lNOUSER       := oParam:GetValue("NOUSER",.f.)

	SX3->(dbSetOrder(1))
	SX3->(dbSeek(cTabela))
	While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cTabela)
		If X3USO(SX3->X3_USADO) .And. ;
			cNivel >= SX3->X3_NIVEL .and. ;
			SX3->X3_CAMPO <> cCpoFilial .and. ;
			(!lFilNaoMostra .or. !SX3->X3_CAMPO $ cNaoMostra) .and. ;
			(!lFilMostra .or. SX3->X3_CAMPO $ cMostra)

//			AADD(Self:aAuxHeader,SX3->X3_CAMPO)
			AADD( Self:aCpoMsMGet , SX3->X3_CAMPO )

			CriaPrvVar( AllTrim(SX3->X3_CAMPO) , CriaVar(SX3->X3_CAMPO,.f.) , Self:cOwnerPvtVar )

			If SX3->X3_VISUAL  <> "V"// .and. (Self:nOpc == 3 .or. Self:nOpc == 4)
				Aadd(Self:aAlterNGDados,SX3->X3_CAMPO) 
			ENDIF

//			If cNomColuna <> SX3->X3_CAMPO
//				CriaPrvVar( AllTrim(cNomColuna) , CriaVar(SX3->X3_CAMPO,.f.) , Self:cOwnerPvtVar )
//			EndIf
		Endif
		SX3->(dbSkip())
	End

	If lNOUSER
		AADD( Self:aCpoMsMGet , "NOUSER" )
	EndIf

Return


/*/{Protheus.doc} MGetRetCpo

Retorna campos da MsMGet

@author Rubens
@since 28/06/2016
@version 1.0

@type function
/*/
Method MGetRetCpo() Class DMS_InterfaceHelper
Return aClone(Self:aCpoMsMGet)

/*/{Protheus.doc} MGetRetAAlter

Retorna os campos da GetDados que poderão ser alterados

@author Rubens
@since 28/06/2016
@version 1.0

@type function
/*/
Method MGetRetAAlter() Class DMS_InterfaceHelper
Return aClone(Self:aAlterNGDados)

/*/{Protheus.doc} MGetRetHeader
Retorna aHeader
@author Rubens
@since 28/06/2016
@version 1.0

@type function
/*/
Method MGetRetHeader() Class DMS_InterfaceHelper
Return aClone(Self:aAuxHeader)

/*/{Protheus.doc} MGetRetObrigat

Retorna campos que serão obrigatorios

@author Rubens
@since 28/06/2016
@version 1.0

@type function
/*/
Method MGetRetObrigat() Class DMS_InterfaceHelper
//	Local nPos
//	For nPos := 1 to Len(Self:aAuxHeader)
//		If PesqSX3(Self:aAuxHeader[2])
//		EndIf
//	Next nPos
//Return aClone(aRet)
Return aClone(Self:aHeaderObrigat)

/*/{Protheus.doc} CreateMSMGet

	Cria um objeto do tipo MsMGet com os campos definidos atraves da rotina AddMGet

	@author Rubens
	@since 10/08/2015
	@version 1.0
	@param lDicionario, booleano, Indica se o objeto MSMGet sera criado com base no dicionario ou criado com campos definidos manualmente

	@type function

/*/
Method CreateMSMGet(lDicionario, aDataContainer) Class DMS_InterfaceHelper

	Local oRetorno
	Local oCustomizacao := DMS_DataContainer():New(aDataContainer)
	Local aAuxHeader

	Local nAlinhamento := oCustomizacao:GetValue( "ALINHAMENTO" , -1 )
	Local lVisualiza   := oCustomizacao:GetValue( "VISUALIZA" , .F. )
	Local lSetPosicao  := ( nAlinhamento <> CONTROL_ALIGN_ALLCLIENT )

	Default lDicionario := .t.
	Default aDataContainer := {}

	oParam := DMS_DataContainer():New(aDataContainer)
	Self:RetPosicao(oParam)

	If lDicionario

		//(oAuxPanel:nClientHeight / 2) - 9 ,; // [ nHeight ]
		//(oAuxPanel:nClientWidth / 2) - 4 ,; // [ nWidth ]
		//TOP","LEFT","BOTTOM","RIGHT"

		oRetorno := MSMGet():New(;
				Self:cAlias,;
				,;
				Self:nOpc ,;
				/*aCRA*/,/*cLetras*/,/*cTexto*/,;
				Self:MGetRetCpo() ,;
				IIf( lSetPosicao , ;
					Self:oDefSize:GetObjectArea( Self:cNomObjDefSize ) , ;
					{IIf( Self:oDialog:nTop  < 0 , 0 , (Self:oDialog:nTop  / 2 ) ) ,;
					 IIf( Self:oDialog:nLeft < 0 , 0 , (Self:oDialog:nLeft / 2 ) ) ,;
					 Self:oDialog:nBottom / 2,;
					 Self:oDialog:nRight / 2} ) , ;
				  IIF( lVisualiza , {} , ) ,;
				3 /*nModelo*/,;
				/* nColMens */,;
				/* cMensagem */,;
				"AllwaysTrue()",;
				Self:oDialog ,;
				.t. /* lF3 */ ,;
				.t. /* lMemoria */ ,;
				oCustomizacao:GetValue( "COLUNA" , .F. ) /* lColumn */ ,;
				/* caTela */ ,;
				oCustomizacao:GetValue( "NOFOLDER" , .F. )/* lNoFolder */,;
				.t. /* lProperty */,;
				, ; // Self:MGetRetHeader()
				/* aFolder */ ,;
				.f. /* lCreate */ ,;
				.t. /*lNoMDIStretch*/,;
				;
				)

	Else

		aAuxHeader := Self:MGetRetHeader()
		aEval( aAuxHeader , { |x| x[12] := IIf( !Empty(x[12]) , &( "{ || " + AllTrim(x[12]) + "}" ) , "" ) } )

		oRetorno := MSMGet():New(;
				,;
				,;
				Self:nOpc ,;
				/*aCRA*/,/*cLetras*/,/*cTexto*/,;
				Self:MGetRetCpo() ,;
				IIf( lSetPosicao , ;
					Self:oDefSize:GetObjectArea( Self:cNomObjDefSize ) , ;
					{IIf( Self:oDialog:nTop  < 0 , 0 , (Self:oDialog:nTop  / 2 ) ) ,;
					 IIf( Self:oDialog:nLeft < 0 , 0 , (Self:oDialog:nLeft / 2 ) ) ,;
					 Self:oDialog:nBottom / 2,;
					 Self:oDialog:nRight / 2} ) ,;
				Self:MGetRetAAlter() ,;
				3 /*nModelo*/,;
				/* nColMens */,;
				/* cMensagem */,;
				"AllwaysTrue()",;
				Self:oDialog ,;
				.t. /* lF3 */ ,;
				.t. /* lMemoria */ ,;
				oCustomizacao:GetValue( "COLUNA" , .F. ) /* lColumn */ ,;
				/* caTela */ ,;
				oCustomizacao:GetValue( "NOFOLDER" , .T. )/* lNoFolder */,;
				.t. /* lProperty */,;
				aAuxHeader, ;
				/* aFolder */ ,;
				.t. /* lCreate */ ,;
				.t. /*lNoMDIStretch*/,;
				;
				)
	EndIf

	If nAlinhamento <> -1
		oRetorno:oBox:Align := nAlinhamento
	EndIf

Return oRetorno

/*/{Protheus.doc} CreateDefSize

Retorna objeto DefSize para montagem de tela

@author Rubens
@since 28/06/2016
@version undefined
@param lHasEnchoiceBar, logical, descricao
@param aInfObjetos, array, descricao
@param aWorkArea, array, descricao
@param nMargem, numeric, descricao
@type function
/*/
Method CreateDefSize(lHasEnchoiceBar , aInfObjetos , aWorkArea, nMargem, nPercRed ) Class DMS_InterfaceHelper
	Local oRetorno
	Local nPos

	Default lHasEnchoiceBar := .t.
	Default aInfObjetos := {}
	Default aWorkArea := {}
	Default nMargem := 2
	Default nPercRed := 0

	oRetorno := FWDefSize():New(lHasEnchoiceBar)
	oRetorno:aMargins := { nMargem, nMargem, nMargem, nMargem }

	if nPercRed > 0
		oRetorno:aWindSize[3] := Round(oRetorno:aWindSize[3] * nPercRed,0) // largura
		oRetorno:aWindSize[4] := Round(oRetorno:aWindSize[4] * nPercRed,0) // altura
		oRetorno:aWorkArea[3] := Round(oRetorno:aWorkArea[3] * nPercRed,0)
		oRetorno:aWorkArea[4] := Round(oRetorno:aWorkArea[4] * nPercRed,0)
	end

	If Len(aWorkArea) <> 0
		oRetorno:aWorkArea := aClone(aWorkArea)
	EndIf
	oRetorno:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis

	For nPos := 1 to Len(aInfObjetos)
		oRetorno:AddObject( aInfObjetos[ nPos, 1 ], aInfObjetos[ nPos, 2 ] , aInfObjetos[ nPos, 3 ] , aInfObjetos[ nPos, 4 ] , aInfObjetos[ nPos, 5 ] )
	Next nPos

Return oRetorno

/*/{Protheus.doc} CreateDialog

Cria uma Dialog

@author Rubens
@since 28/06/2016
@version undefined
@param cTitulo, characters, descricao
@param aDimensao, array, descricao
@param lHasEnchoiceBar, logical, descricao
@type function
/*/
Method CreateDialog(cTitulo, aDimensao, lHasEnchoiceBar) Class DMS_InterfaceHelper
//	Local oSize
	Default lHasEnchoiceBar := .t.
	If aDimensao == NIL
		If Self:oDefSize == NIL
			Self:SetDefSize( Self:CreateDefSize(lHasEnchoiceBar) )
		EndIf

		DEFINE MSDIALOG Self:oDialog TITLE cTitulo OF oMainWnd PIXEL;
			FROM Self:oDefSize:aWindSize[1],Self:oDefSize:aWindSize[2] TO;
				 Self:oDefSize:aWindSize[3],Self:oDefSize:aWindSize[4]
	Else

		oDimensao := DMS_DataContainer():New(aDimensao)

		DEFINE MSDIALOG Self:oDialog TITLE cTitulo OF oMainWnd PIXEL;
			FROM oDimensao:GetValue("TOP",00) ,;
				 oDimensao:GetValue("LEFT",00) ;
			TO oDimensao:GetValue("BOTTOM") ,;
			   oDimensao:GetValue("RIGHT")

	EndIf
Return Self:oDialog

/*/{Protheus.doc} AddColLBox

Adiciona uma coluna a uma ListBox

@author Rubens
@since 28/06/2016
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method AddColLBox(aDataContainer) Class DMS_InterfaceHelper
	Local nColTam
	Local cCabec

	Local cTabela
	Local oColuna := DMS_DataContainer():New(aDataContainer)
	Local lColSelecao // Controla se a coluna é uma coluna de selecao
	Local cbDblClick
	Local cBlockAtu
	Local lImagem
	Local nPosCol := oColuna:GetValue( "POSICAO" , 0 )
	Local aTempHeader := {}

	cColSX3 := oColuna:GetValue( "X3" , "" )

	If Empty(cColSX3)

		lImagem := oColuna:GetValue( "IMAGEM"  , .f. )
		lColSelecao := oColuna:GetValue("SELECAO",.f.)
		If lColSelecao
			cValidacao := oColuna:GetValue("VALIDACAO","")
			cValidacao := " Len(NOME_OBJETO:aArray) > 0 " + IIf( Empty(cValidacao) , "" , " .AND. (" + cValidacao + ") ")
			cbDblClick := "{ || " + ;
				IIf( !Empty(cValidacao) , "IIF( " + cValidacao + " , ( " , "" ) +;
				IIf( oColuna:GetValue("SELECAO_UNICO",.f.) , "( aEval(NOME_OBJETO:aArray,{ |x,nPos| IIf( nPos <> NOME_OBJETO:nAt , x[ POSICAO_COLUNA ] := .f. , ) }) ) , " , "" ) +;
				" ( NOME_OBJETO:aArray[NOME_OBJETO:nAt,POSICAO_COLUNA] := !NOME_OBJETO:aArray[NOME_OBJETO:nAt,POSICAO_COLUNA] ) " +;
				IIf( oColuna:GetValue("SELECAO_UNICO",.f.) , " , NOME_OBJETO:Refresh() " , "" ) +;
				IIf( !Empty(cValidacao) , " ) , ) " , "" ) + " }"
			lImagem := .t.
		EndIf

		cBlockAtu := oColuna:GetValue("CODEBLOCK","")
		If Empty(cBlockAtu)
			If lColSelecao
				cBlockAtu := "{ || IIf( NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ] , " + ;
					oColuna:GetValue( "MARCADO"    , "oOk" ) + " , " + ;
					oColuna:GetValue( "DESMARCADO" , "oNo" ) + " ) }"
			Else
				cPicture := oColuna:GetValue( "PICTURE" , "" )
				If Empty( cPicture )
					cBlockAtu := "{ || NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ] }"
				Else
					cBlockAtu := "{ || Transform( NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ],'" + cPicture + "' ) }"
				EndIf
			EndIf
		EndIf


		aTempHeader := { ;
			oColuna:GetValue( "CABEC"   , ""     ),;
			cBlockAtu ,;
			oColuna:GetValue( "ALIGN"   , "LEFT" ),;
			oColuna:GetValue( "TAMANHO" , 10     ),;
			lImagem ,;
			cbDblClick }

	ElseIf PesqSX3( cColSX3 )
		cCabec := AllTrim(SX3->(X3Titulo()))
		nColTam := CalcFieldSize(;
			oColuna:GetValue("X3_TIPO"   , SX3->X3_TIPO   ),;
			oColuna:GetValue("TAMANHO"   , oColuna:GetValue("X3_TAMANHO", SX3->X3_TAMANHO) ),;
			oColuna:GetValue("X3_DECIMAL", SX3->X3_DECIMAL),;
			oColuna:GetValue("X3_PICTURE", SX3->X3_PICTURE),;
			cCabec ;
		) + 6

		cTabela := Left(SX3->X3_CAMPO, At("_",SX3->X3_CAMPO) - 1)
		cTabela += IIF( Len(cTabela) == 2 , "S" , "" )

		cBlockAtu := oColuna:GetValue("CODEBLOCK","")
		If Empty(cBlockAtu)
			cPicture := AllTrim( SX3->(X3Picture( SX3->X3_CAMPO )))
			If Empty( cPicture )
				cBlockAtu := "{ || NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ] }"
			Else
				cBlockAtu := "{ || Transform( NOME_OBJETO:aArray[ NOME_OBJETO:nAt, POSICAO_COLUNA ],'" + cPicture + "' ) }"
			EndIf
		EndIf

		aTempHeader := { ;
			cCabec,;
			cBlockAtu ,;
			IIF( SX3->X3_TIPO == 'N' , 'RIGHT' , 'LEFT' ) ,;
			nColTam,;
			.f. ,;
			"" }

	EndIf

	AADD( Self:aAuxHeader , {} )
	If nPosCol == 0
		nPosCol := Len(Self:aAuxHeader)
	Else
		AINS( Self:aAuxHeader , nPosCol)
	EndIf

	Self:aAuxHeader[ nPosCol ] := aClone(aTempHeader)


Return

/*/{Protheus.doc} CreateLBox

Cria um objeto do tipo ListBox

@author Rubens
@since 28/06/2016
@version undefined
@param cNomeObj, characters, descricao
@param aDataContainer, array, Matriz com parametros para a criacao da Listbox

@type function
/*/
Method CreateLBox( cNomeObj , aDataContainer ) Class DMS_InterfaceHelper
	Local oRetorno
	Local nPos
	Local cBlockAtu
	Local cbDblClick
	Local oParam
	Default aDataContainer := {}

	oParam := DMS_DataContainer():New(aDataContainer)
	Self:RetPosicao(oParam)

	oRetorno := TWBrowse():New(;
		Self:nLININI + 2,;
		Self:nCOLINI + 2,;
		Self:nXSIZE  - 4,;
		Self:nYSIZE  - 4 ,,,,Self:oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	If Self:nAlinhamento <> -1
		oRetorno:Align := Self:nAlinhamento
	EndIf

	For nPos := 1 to Len(Self:aAuxHeader)

		If !Empty( Self:aAuxHeader[ nPos , 06 ] ) .and. Empty(cbDblClick)
			cbDblClick := Self:aAuxHeader[ nPos , 06 ]
			cbDblClick := StrTran(cbDblClick,"NOME_OBJETO",cNomeObj)
			cbDblClick := StrTran(cbDblClick,"POSICAO_COLUNA",Str(nPos,3))
		EndIf

		cBlockAtu := Self:aAuxHeader[ nPos , 02 ]
		cBlockAtu := StrTran(cBlockAtu,"NOME_OBJETO",cNomeObj)
		cBlockAtu := StrTran(cBlockAtu,"POSICAO_COLUNA",Str(nPos,3))

		oRetorno:addColumn( TCColumn():New( Self:aAuxHeader[ nPos , 01 ] , &(cBlockAtu) ,,,,Self:aAuxHeader[ nPos , 03 ] , Self:aAuxHeader[ nPos , 04 ] ,Self:aAuxHeader[ nPos , 05 ],.F.,,,,.F.,) )
	Next nPos

	If !Empty(cbDblClick)
		oRetorno:bLDblClick := &(cbDblClick)
	EndIf
	oRetorno:nAt := 1

Return oRetorno

/*/{Protheus.doc} CreateNewGetDados

Cria um objeto do tipo NewGetDados

@author Rubens
@since 28/06/2016
@version undefined
@param cNomeObj, characters, descricao
@param aDataContainer, array, descricao
@type function
/*/
Method CreateNewGetDados(cNomeObj, aDataContainer) Class DMS_InterfaceHelper
	Local oRetorno
	Local nPos
	Local cBlockAtu
	Local cbDblClick
	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local nMax := oParam:GetValue( "MAX" , 999 )
	Local nAlinhamento := oParam:GetValue( "ALINHAMENTO" , -1 )
	//Local lSetPosicao := ( nAlinhamento <> CONTROL_ALIGN_ALLCLIENT .and. nAlinhamento >= 0)
	Local lSetPosicao := ( nAlinhamento <> CONTROL_ALIGN_ALLCLIENT )

	Local aAuxACols := oParam:GetValue( "ACOLS" , { aClone( Self:CreateLinaCols() ) } )

	Local cLinhaOK := oParam:GetValue( "LINHAOK" , "AllwaysTrue()" )
	Local cTudoOK  := oParam:GetValue( "TUDOOK" , "AllwaysTrue()" )
	Local cFieldOk := oParam:GetValue( "FIELDOK" , "AllwaysTrue()" )

	If Len(aAuxACols) > nMax
		nMax := Len(aAuxACols)
	EndIf

	If lSetPosicao
		If Self:oDefSize == NIL
			nLININI := nCOLINI := nLINEND := nCOLEND := 0
		Else
			nLININI := Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"LININI" )
			nCOLINI := Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"COLINI" )
			nLINEND := Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"LINEND" )
			nCOLEND := Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"COLEND" )
		EndIf
	EndIf

	//cFieldOk := "OM020FOKVSJ()"

	oRetorno := MsNewGetDados():New(;
		IIf( lSetPosicao , oParam:GetValue( "LININI" , nLININI ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "COLINI" , nCOLINI ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "LINEND" , nLINEND ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "COLEND" , nCOLEND ) , 0 ),;
		oParam:GetValue( "OPERACAO" , RetGDOpc(Self:nOpc) ) ,; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		cLinhaOK,;
		cTudoOK,;
		,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
		Self:MGetRetAAlter() ,; 	// Campos alteraveis da GetDados
		oParam:GetValue( "FREEZE" , 0 ),;	// Campos estaticos da GetDados
		nMax,;
		cFieldOk,;
		/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		/* cDelOk */ ,; 		// Funcao executada para validar a exclusao de uma linha
		Self:oDialog,;
		Self:MGetRetHeader(),;
		/* aAuxACols */ )
	If nAlinhamento <> -1
		oRetorno:oBrowse:Align := nAlinhamento
	EndIf

	oRetorno:oBrowse:bChange := &("{ || FG_MEMVAR( " + cNomeObj + ":aHeader , " + cNomeObj + ":aCols , " + cNomeObj + ":nAt )" + oParam:GetValue( "BCHANGE_ADD" , "" ) + " }")

//	For	nPos := 5 to Len(Self:MGetRetHeader())
//		oRetorno:oBrowse:aColSizes[nPos] := 30
//		oRetorno:oBrowse:aColumns[nPos]:nWidth := 30
////		oRetorno:oBrowse:aColumns[nPos]:SetSize(15)
//	Next nPos
////	oRetorno:ForceRefresh()
//	oRetorno:oBrowse:CallRefresh()

//{|| If(Self:aCols[Iif( Len( Self:aCOLS ) >= Self:oBrowse:nAt, Self:oBrowse:nAt, Len( Self:aCOLS ) ),Len(Self:aCols[Iif( Len( Self:aCOLS ) >= Self:oBrowse:nAt, Self:oBrowse:nAt, Len( Self:aCOLS ) )])],              12632256,              16777215)}
Return oRetorno


/*/{Protheus.doc} CreateTFolder
Cria um objeto do tipo Folder
@author Rubens
@since 04/07/2017
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method CreateTFolder(aDataContainer) Class DMS_InterfaceHelper
	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local oRetorno
	Local nAlinhamento := oParam:GetValue( "ALINHAMENTO" , -1 )
	Local lSetPosicao := ( nAlinhamento <> CONTROL_ALIGN_ALLCLIENT )

	oRetorno := TFolder():New( ;
		IIf( lSetPosicao , oParam:GetValue( "LININI" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"LININI" ) ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "COLINI" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"COLINI" ) ) , 0 ),;
		oParam:GetValue( "ABAS" , NIL ) ,;
		, Self:oDialog , , , , .t. , ,;
		IIf( lSetPosicao , oParam:GetValue( "XSIZE" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"XSIZE" ) ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "YSIZE" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"YSIZE" ) ) , 0 ) )

	If nAlinhamento <> -1
		oRetorno:Align := nAlinhamento
	EndIf

Return oRetorno

/*/{Protheus.doc} CreateTPanel
Cria um objeto do tipo Panel
@author Rubens
@since 04/07/2017
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method CreateTPanel(aDataContainer) Class DMS_InterfaceHelper
	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local oRetorno
	//Local nAlinhamento := oParam:GetValue( "ALINHAMENTO" , -1 )
	//Local lSetPosicao := ( nAlinhamento <> CONTROL_ALIGN_ALLCLIENT )

	//RetPosicao(oParam, @nAlinhamento, @lSetPosicao, @nLININI, @nCOLINI, @nXSIZE, @nYSIZE)
	Self:RetPosicao(oParam)

	oRetorno := TPanel():New( ;
		Self:nLININI ,;
		Self:nCOLINI ,;
		oParam:GetValue( "TEXTO" , NIL ) ,;
		Self:oDialog ,;
		oParam:GetValue( "FONTE" , NIL ) ,;
		oParam:GetValue( "CENTRALIZADO"   , .T. ) ,;
		/* uParam7 */,;
		oParam:GetValue( "COR"   , NIL ) ,;
		oParam:GetValue( "FUNDO" , NIL ) ,;
		Self:nXSIZE,;
		Self:nYSIZE,;
		.f. ,; //[ lLowered]
		.f. ) // [ lRaised]

	If Self:nAlinhamento <> -1
		oRetorno:Align := Self:nAlinhamento
//		oRetorno:ReadClientCoors()
	EndIf

Return oRetorno

/*/{Protheus.doc} CreateTScroll
Cria um objeto do tipo Scroll
@author Rubens
@since 04/07/2017
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method CreateTScroll(aDataContainer) Class DMS_InterfaceHelper

	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local oRetorno
	Local nAlinhamento := oParam:GetValue( "ALINHAMENTO" , -1 )
	Local lSetPosicao := ( nAlinhamento <> CONTROL_ALIGN_ALLCLIENT )

	oRetorno := TScrollBox():New(;
		Self:oDialog ,;
		IIf( lSetPosicao , oParam:GetValue( "LININI" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"LININI" ) ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "COLINI" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"COLINI" ) ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "YSIZE" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"YSIZE" ) ) , 0 ),;
		IIf( lSetPosicao , oParam:GetValue( "XSIZE" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"XSIZE" ) ) , 0 ),;
		.t.,; // [ lVertical ]
		.t.,; // [ lHorizontal ]
		oParam:GetValue( "BORDA" , NIL )) // [ lBorder ]

Return oRetorno

/*/{Protheus.doc} CreateMGroup
Cria um container do tipo de objetos
@author Rubens
@since 04/07/2017
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method CreateMGroup(aDataContainer) Class DMS_InterfaceHelper
	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local oRetorno

	Local oAuxPanel := Self:CreateTPanel(aDataContainer)
	Local oAuxGroup

	oAuxPanel:ReadClientCoors()
	oAuxGroup := TGroup():New(;
		0 ,; //nTop
		0 ,; //nLeft
		0 ,; //nBottom
		0 ,; //nRight
		oParam:GetValue( "TEXTO" , NIL ) ,; //cCaption
		oAuxPanel,; //oWnd
		,; //nClrText
		,; //nClrPane
		.t.,; // lPixel
		)
	oAuxGroup:Align := CONTROL_ALIGN_ALLCLIENT

	oRetorno := TScrollBox():New(;
		oAuxPanel ,; // [ oWnd ]
		7,; // [ nTop ]
		2,; // [ nLeft ]
		(oAuxPanel:nClientHeight / 2) - 9 ,; // [ nHeight ]
		(oAuxPanel:nClientWidth / 2) - 4 ,; // [ nWidth ]
		.t.,; // [ lVertical ]
		.t.,; // [ lHorizontal ]
		oParam:GetValue( "BORDA" , NIL )) // [ lBorder ]
//	oScrool := TScrollBox():New( oPan1 , ;
//		7, 2, (oPan1:nClientHeight / 2) - 9 , (oPan1:nClientWidth / 2) - 4 , .t. , .t. , .f. )
	oRetorno:ReadClientCoors()

Return oRetorno

Method AddButton(aData) Class DMS_InterfaceHelper

	Local oParam   := DMS_DataContainer():New(aData)
	Local cNomeObj := oParam:GetValue("NOMEOBJ","")

	AADD( Self:aButtons , { ;
		cNomeObj ,; // 01
		oParam:GetValue("CAPTION","") ,;   // 02
		oParam:GetValue("COMANDO",".t."),; // 03
		oParam:GetValue("LARGURA",0),;     // 04
		oParam:GetValue("ALTURA", IIf( cNomeObj == "ESPACO" , 5 , 11 ) ),; // 05
		oParam:GetValue("WHEN", "" ) } ) // 06

Return

Method CreateGrpButton(aDataContainer) Class DMS_InterfaceHelper

	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local oRetorno
	Local nAuxLinha  := 1
	Local nAuxColuna := 2
	Local nAuxEspaco := 2
	Local nPadAltura
	Local nPadLargura
	Local cNomeObj
	Local nCont
	Local nCalcAltura := 0

	Local oAuxPanel := Self:CreateMGroup(aDataContainer)

	oAuxPanel:ReadClientCoors()

	// Calcula a necessaria para caber todos os botoes
	aEval( Self:aButtons , { |x| nCalcAltura += x[ 5 ] + nAuxEspaco })
	//

	nPadAltura  := ( ( oAuxPanel:nClientHeight ) / 2 )
	nPadLargura := ( ( oAuxPanel:nClientWidth  ) / 2 ) - IIf( nPadAltura > nCalcAltura , 4 , 14 )

	For nCont := 1 to Len(Self:aButtons)

		nAuxLargura := IIf( Self:aButtons[nCont,4] == 0 , nPadLargura , Self:aButtons[nCont,4] )
		cNomeObj := Self:aButtons[ nCont , 1 ]

		If cNomeObj <> "ESPACO"
			&(Self:aButtons[ nCont , 1 ]) := TButton():New( ;
				nAuxLinha ,; //nRow -> Indica a coordenada vertical em pixels ou caracteres.
				nAuxColuna,; //nCol -> Indica a coordenada horizontal em pixels ou caracteres.
				Self:aButtons[ nCont , 2 ] ,; //cCaption -> Indica o título do botão.
				oAuxPanel,; //oWnd -> Indica a janela ou controle visual onde o botão será criado.
				&('{ || ' + Self:aButtons[ nCont , 3 ] + ' }'),; //bAction -> Indica o bloco de código que será executado quando clicar, com o botão esquerdo do mouse, sobre o botão.
				nAuxLargura,; //nWidth -> Indica a largura em pixels do botão.
				Self:aButtons[ nCont , 5 ] ,; //nHeight -> Indica a altura em pixels do botão.
				,; //uParam8 -> Compatibilidade.
				,; //oFont -> Indica o objeto do tipo TFont utilizado para definir as características da fonte aplicada na exibição do conteúdo do controle visual.
				,; //uParam10 -> Compatibilidade.
				.t.,; //lPixel -> Indica se considera as coordenadas passadas em pixels (.T.) ou caracteres (.F.).
				,; //uParam12 -> Compatibilidade.
				,; //uParam13 -> Compatibilidade.
				,; //uParam14 -> Compatibilidade.
				&("{ || " + IIf( !Empty(Self:aButtons[ nCont , 6 ]) , Self:aButtons[ nCont , 6 ] , ".T." ) + " }" ),;	//bWhen -> Indica o bloco de código que será executado quando a mudança de foco da entrada de dados, na janela em que o controle foi criado, estiver sendo efetuada. Observação: O bloco de código retornará verdadeiro (.T.), se o controle permanecer habilitado; caso contrário, retornará falso (.F.).
				,; //uParam16 -> Compatibilidade.
				; //uParam17 -> Compatibilidade.
			)
		EndIf

		nAuxLinha += Self:aButtons[ nCont , 5 ] + nAuxEspaco

	Next nCont



Return oRetorno

/*/{Protheus.doc} CreateLinaCols

Retorna uma linha da aCols

@author Rubens
@since 28/06/2016
@version undefined

@type function
/*/
Method CreateLinaCols() Class DMS_InterfaceHelper
Return aClone(Self:aAuxLinACols)

/*/{Protheus.doc} AddHeaderTAB

Cria um aHeader com base em uma tabela do dicionario de dados.

@author Rubens
@since 28/06/2016
@version undefined
@param cTabela, characters, descricao
@param aDataContainer, array, descricao
@type function
/*/
Method AddHeaderTAB( cTabela , aDataContainer ) Class DMS_InterfaceHelper
	Local oParam := DMS_DataContainer():New(aDataContainer)

	Local cNaoMostra := oParam:GetValue("NAOMOSTRA","")
	Local cMostra := oParam:GetValue("MOSTRA","")
	Local lFilNaoMostra := !Empty(cNaoMostra)
	Local lFilMostra := !Empty(cMostra)

	SX3->(dbSetOrder(1))
	SX3->(dbSeek(cTabela))
	While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cTabela)
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .and. (!lFilNaoMostra .or. !SX3->X3_CAMPO $ cNaoMostra) .and. (!lFilMostra .or. SX3->X3_CAMPO $ cMostra)
			Self:AddHeader( { } )
		Endif
		SX3->(dbSkip())
	End

	If oParam:GetValue("WALKTHRU",.f.)
		Self:AddWalkThru()
	EndIf
Return

/*/{Protheus.doc} AddWalkThru
Adiciona colunas de walkthru na aHeader
@author Rubens
@since 28/06/2016
@version undefined
@param cTabela, characters, descricao
@type function
/*/
Method AddWalkThru(cTabela) Class DMS_InterfaceHelper
Return ADHeadRec(cTabela,Self:aAuxHeader)

/*/{Protheus.doc} AddHeader

Cria uma linha na aHeader

@author Rubens
@since 28/06/2016
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method AddHeader( aDataContainer ) Class DMS_InterfaceHelper

	Local uVar
	Local oColuna := DMS_DataContainer():New(aDataContainer)
	Local cNomColuna

	cColSX3 := oColuna:GetValue( "X3" , "" )
	If Empty(cColSX3) .or. PesqSX3( cColSX3 )
		cNomColuna := oColuna:GetValue("CAMPO" , SX3->X3_CAMPO )
		AADD( Self:aAuxHeader , { ;
			AllTrim(SX3->(X3Titulo())),;
			cNomColuna,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			oColuna:GetValue("X3_VALID" , SX3->X3_VALID ),;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			oColuna:GetValue("X3_F3" , SX3->X3_F3 ),;
			SX3->X3_CONTEXT,;
			SX3->(X3CBOX()),;
			oColuna:GetValue("X3_RELACAO", SX3->X3_RELACAO ) } )

		CriaPrvVar( AllTrim(SX3->X3_CAMPO) , CriaVar(SX3->X3_CAMPO,.f.) , Self:cOwnerPvtVar )

		If oColuna:GetValue( "X3_VISUAL" , SX3->X3_VISUAL ) <> "V"
			Aadd(Self:aAlterNGDados,SX3->X3_CAMPO)
		ENDIF

		If cNomColuna <> SX3->X3_CAMPO
			CriaPrvVar( AllTrim(cNomColuna) , CriaVar(SX3->X3_CAMPO,.f.) , Self:cOwnerPvtVar )
		EndIf

		If X3Obrigat(SX3->X3_CAMPO)
			AADD(Self:aHeaderObrigat,Len(Self:aAuxHeader))
		EndIf

		AADD( Self:aAuxLinACols , &(AllTrim(SX3->X3_CAMPO)) )

	EndIf

Return

/*/{Protheus.doc} AddHeaderOBJ

Cria uma linha na aHeader com base no objeto

@author Rubens
@since 28/06/2016
@version undefined
@param oAuxObj, object, descricao
@type function
/*/
Method AddHeaderOBJ( oAuxObj ) Class DMS_InterfaceHelper

	AADD( Self:aAuxHeader , { ;
		AllTrim(oAuxObj:Titulo) ,;
		oAuxObj:Campo     ,;
		oAuxObj:Picture   ,;
		oAuxObj:Tamanho   ,;
		oAuxObj:Decimal   ,;
		oAuxObj:Validacao ,;
		oAuxObj:Usado     ,;
		oAuxObj:Tipo      ,;
		oAuxObj:F3        ,;
		oAuxObj:Contexto  ,;
		oAuxObj:ComboBox  })

	If oAuxObj:Altera
		AADD(Self:aAlterNGDados,oAuxObj:Campo)
	EndIf

	IF oAuxObj:Obrigat
		AADD( Self:aHeaderObrigat , Len(Self:aAuxHeader) )
	EndIf

	CriaPrvVar(oAuxObj:Campo , oAuxObj:ValorInicial, Self:cOwnerPvtVar)

	AADD( Self:aAuxLinACols , &(oAuxObj:Campo) )

Return

/*/{Protheus.doc} CreateTSay
Cria um objeto do tipo TSay
@author Rubens
@since 28/06/2016
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method CreateTSay( aDataContainer ) Class DMS_InterfaceHelper
	Local oParam := DMS_DataContainer():New(aDataContainer)
	TSay():New(;
		oParam:GetValue("LINHA"),; // [ nRow ]
		oParam:GetValue("COLUNA"),; // [ nCol ]
		&("{ || '" + oParam:GetValue("TEXTO","") + "' }"),;
		Self:oDialog ,; // [ oWnd ]
		,; // [ cPicture ]
		oParam:GetValue("FONTE", NIL ),; // [ oFont ]
		,; // [ uParam7 ]
		,; // [ uParam8 ]
		,; // [ uParam9 ]
		.t. ,; // [ lPixels ]
		oParam:GetValue("LARGURA"),;
		oParam:GetValue("ALTURA"))
Return

/*/{Protheus.doc} CreateTGet
Cria um objeto do tipo TGet
@author Rubens
@since 28/06/2016
@version undefined
@param aDataContainer, array, descricao
@type function
/*/
Method CreateTGet( aDataContainer ) Class DMS_InterfaceHelper
	Local oParam := DMS_DataContainer():New(aDataContainer)
	Local cNomeObj := oParam:GetValue("NOMEOBJ","OBJ" + StrZero(Randomize(1,9999),4))
	Local uGetSet
	Local cNomeVar
	Local cValid := oParam:GetValue("VALID","") // VALID para ser executado
	Local cWhen  := oParam:GetValue("WHEN","") // WHEN para ser executado

	uGetSet := oParam:GetValue("GETSET",NIL)
	If uGetSet == NIL
		cNomeVar := oParam:GetValue("NOMEVAR","")
		uGetSet := &('{ | U | IF( PCOUNT() == 0, ' + cNomeVar + ' , ' + cNomeVar + ' := U ) }')
	EndIf

	cLabel := oParam:GetValue("LABEL","")
	If Empty(cLabel)
		cLabel := NIL
		nLabelPos := NIL
	Else
		nLabelPos := IIf( oParam:GetValue("LABELPOS", "ESQUERDA" ) == "ESQUERDA" , 2 , 1 )
	EndIf

	CriaPrvVar(cNomeObj , NIL, Self:cOwnerPvtVar)

	If oParam:GetValue("MULTIGET",.f.)
		&(cNomeObj) := TMultiGet():New(;
			oParam:GetValue("LINHA")  ,; // [ nRow ]
			oParam:GetValue("COLUNA") ,; // [ nCol ]
			uGetSet      ,; // [ bSetGet ]
			Self:oDialog ,; // [ oWnd ]
			oParam:GetValue("LARGURA",40) ,; // ( oSizeDemanda:GetDimension( "DEMANDA" , "XSIZE" ) ) - 24 ,; // [ nWidth ]
			oParam:GetValue("ALTURA",11),; // [ nHeight ]
			,; // [ oFont ]
			,; // [ uParam8 ]
			,; // [ uParam9 ]
			,; // [ uParam10 ]
			,; // [ uParam11 ]
			.t. ,; // [ lPixel ]
			,; // [ uParam13 ]
			,; // [ uParam14 ]
			IIf(!Empty(cWhen),&("{ || "+cWhen+" }"),NIL),; // [ bWhen ]
			,; // [ uParam16 ]
			,; // [ uParam17 ]
			oParam:GetValue("READONLY",.F.) ,; // [ lReadOnly ]
			IIf(!Empty(cValid),&("{ || "+cValid+" }"),NIL),; // [ bValid ]
			,; // [ uParam20 ]
			,; // [ uParam21 ]
			,; // [ lNoBorder ]
			,; // [ lVScroll ]
			cLabel    ,; // [ cLabelText ]
			nLabelPos ,; // [ nLabelPos ]
			,; // [ oLabelFont ]
			; // [ nLabelColor ]
			)

	Else
		&(cNomeObj) := TGet():New(;
			oParam:GetValue("LINHA")  ,; // [ nRow ]
			oParam:GetValue("COLUNA") ,; // [ nCol ]
			uGetSet      ,; // [ bSetGet ]
			Self:oDialog ,; // [ oWnd ]
			oParam:GetValue("LARGURA",40) ,; // ( oSizeDemanda:GetDimension( "DEMANDA" , "XSIZE" ) ) - 24 ,; // [ nWidth ]
			oParam:GetValue("ALTURA",11),; // [ nHeight ]
			oParam:GetValue("PICTURE","") ,; // [ cPict ]
			IIf(!Empty(cValid),&("{ || "+cValid+" }"),NIL),; // [ bValid ]
			,; // [ nClrFore ]
			,; // [ nClrBack ]
			oParam:GetValue("FONTE",NIL),; // [ oFont ]
			,; // [ uParam12 ]
			,; // [ uParam13 ]
			.t. ,; // [ lPixel ]
			,; // [ uParam15 ]
			,; // [ uParam16 ]
			IIf(!Empty(cWhen),&("{ || "+cWhen+" }"),NIL),; // [ bWhen ]
			,; // [ uParam18 ]
			,; // [ uParam19 ]
			,; // [ bChange ]
			oParam:GetValue("READONLY",.F.) ,; // [ lReadOnly ]
			.f. ,; // [ lPassword ]
			,; // [ uParam23 ]
			oParam:GetValue("NOMEVAR",NIL),; // [ cReadVar ]
			,; // [ uParam25 ]
			,; // [ uParam26 ]
			,; // [ uParam27 ]
			oParam:GetValue("HASBUTTON",.T.) ,; // [ lHasButton ]
			,; // .T. [ lNoButton ]
			,; // [ uParam30 ]
			cLabel    ,; // [ cLabelText ]
			nLabelPos ,; // [ nLabelPos ]
			,; // [ oLabelFont ]
			,; // [ nLabelColor ]
			; // [ cPlaceHold ] )
			)
	EndIf

Return

Method RetPosicao(oParam) Class DMS_InterfaceHelper

	Self:nAlinhamento := oParam:GetValue( "ALINHAMENTO" , -1 )
	Self:lSetPosicao := ( Self:nAlinhamento <> CONTROL_ALIGN_ALLCLIENT )
	Self:nLININI := Self:nLINEND := Self:nCOLINI := Self:nCOLEND := Self:nXSIZE := Self:nYSIZE := 0

	If Self:lSetPosicao
		Self:nLININI := oParam:GetValue( "LININI" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"LININI" ) )
		Self:nLINEND := oParam:GetValue( "LINEND" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"LINEND" ) )
		Self:nCOLINI := oParam:GetValue( "COLINI" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"COLINI" ) )
		Self:nCOLEND := oParam:GetValue( "COLEND" , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"COLEND" ) )
		If Self:nAlinhamento <> CONTROL_ALIGN_TOP .and. Self:nAlinhamento <> CONTROL_ALIGN_BOTTOM
			Self:nXSIZE  := oParam:GetValue( "XSIZE"  , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"XSIZE" ) )
		EndIf
		If Self:nAlinhamento <> CONTROL_ALIGN_LEFT .and. Self:nAlinhamento <> CONTROL_ALIGN_RIGHT
			Self:nYSIZE  := oParam:GetValue( "YSIZE"  , Self:oDefSize:GetDimension( Self:cNomObjDefSize ,"YSIZE" ) )
		EndIf
	EndIf

Return

Static Function PesqSX3(cCpoNome)
	SX3->(dbSetOrder(2))
Return (SX3->(dbSeek(cCpoNome)))

Static Function CriaPrvVar(cNomeVar , uVar , cOwner)
	Default cOwner := ""
	If !Empty(cOwner)
		_SetNamedPrvt( AllTrim(cNomeVar) , uVar , cOwner )
	Else
		_SetOwnerPrvt( AllTrim(cNomeVar) , uVar )
	EndIf
Return

Static Function RetGDOpc(nOpc)
	Local nRetorno := 0
	Do Case
	Case nOpc == 3 // Inclusao
		nRetorno := GD_INSERT + GD_UPDATE + GD_DELETE
	Case nOpc == 4 // Alteracao
		nRetorno := GD_INSERT + GD_UPDATE + GD_DELETE
	End
Return nRetorno


Class DMS_IFCol
	Data Titulo
	Data Campo
	Data Picture
	Data Tamanho
	Data Decimal
	Data Validacao
	Data Usado
	Data Tipo
	Data F3
	Data Contexto
	Data ComboBox
	Data ValorInicial
	Data Altera
	Data Obrigat

	Method New() CONSTRUCTOR
	Method Clean()
	Method GetX3LikeParams()
EndClass

Method New() Class DMS_IFCol
	Self:Clean()
Return Self

Method Clean() Class DMS_IFCol
	Self:Titulo    := ""
	Self:Campo     := ""
	Self:Picture   := ""
	Self:Tamanho   := 0
	Self:Decimal   := 0
	Self:Validacao := ""
	Self:Usado     := X3_USADO_EMUSO
	Self:Tipo      := ""
	Self:F3        := ""
	Self:Contexto  := "V"
	Self:ComboBox  := ""
	Self:ValorInicial := NIL
	Self:Altera    := .t.
	Self:Obrigat   := .f.
Return

Method GetX3LikeParams() Class DMS_IFCol
Return {;
	{'X3_TITULO'  , self:Titulo},;
	{'X3_CAMPO'   , self:Campo},;
	{'X3_PICTURE' , self:Picture},;
	{'X3_TAMANHO' , self:Tamanho},;
	{'X3_DECIMAL' , self:Decimal},;
	{'X3_VALID'   , self:Validacao},;
	{'X3_USADO'   , self:Usado},;
	{'X3_TIPO'    , self:Tipo},;
	{'X3_F3'      , self:F3},;
	{'X3_CONTEXT' , self:Contexto},;
	{'X3_CBOX'    , self:ComboBox},;
	{'X3_RELACAO' , self:ValorInicial},;
	{'X3_VISUAL'  , IIF(self:Altera, "A", "V")},;
	{'X3_OBRIGAT' , self:Obrigat} ;
}

Class DMS_IFColNumero From DMS_IFCol
	Method New() CONSTRUCTOR
EndClass

Method New(aDataContainer) Class DMS_IFColNumero

	Local nAuxTam := 0

	Default aDataContainer := {}

	_Super:New()

	oInfCpo := DMS_DataContainer():New(aDataContainer)
	Self:Tipo := "N"
	Self:Titulo := oInfCpo:GetValue("TITULO","")
	Self:Campo := oInfCpo:GetValue("CAMPO","")
	Self:Tamanho := oInfCpo:GetValue("TAMANHO",0)
	Self:Decimal := oInfCpo:GetValue("DECIMAL",0)
	Self:ValorInicial := 0
	Self:Altera := oInfCpo:GetValue("ALTERA",.t.)
	Self:Obrigat := oInfCpo:GetValue("OBRIGATORIO",.f.)

	If Self:Tamanho <> 0
		nAuxTam := Self:Tamanho - IIf( Self:Decimal > 0 , Self:Decimal + 1 , 0 )
		nResto := MOD(nAuxTam , 3 )
		Self:Picture += "@E " + IIf( nResto == 0 , "" , Replicate("9", nResto ) + "," )
		Self:Picture += Replicate("999," , INT( nAuxTam / 3 ) )
		Self:Picture := Left( Self:Picture , Len(Self:Picture) - 1 )
		Self:Picture += IIf(Self:Decimal > 0 , "." + Replicate( "9" , Self:Decimal ) , "" )
	EndIf

Return Self

Class DMS_IFColString From DMS_IFCol
	Method New() CONSTRUCTOR
EndClass

Method New(aDataContainer) Class DMS_IFColString

	Default aDataContainer := {}

	_Super:New()

	Self:Picture := "@!"

	oInfCpo := DMS_DataContainer():New(aDataContainer)
	Self:Tipo := "C"
	Self:Titulo := oInfCpo:GetValue("TITULO","")
	Self:Campo := oInfCpo:GetValue("CAMPO","")
	Self:Tamanho := oInfCpo:GetValue("TAMANHO",0)
	Self:ValorInicial := ""
	Self:Altera := oInfCpo:GetValue("ALTERA",.t.)
	Self:Obrigat := oInfCpo:GetValue("OBRIGATORIO",.f.)

Return Self

Class DMS_IFColMemo From DMS_IFCol
	Method New() CONSTRUCTOR
EndClass

Method New(aDataContainer) Class DMS_IFColMemo

	Default aDataContainer := {}

	_Super:New()

	Self:Picture := "@!"

	oInfCpo := DMS_DataContainer():New(aDataContainer)
	Self:Tipo := "M"
	Self:Titulo := oInfCpo:GetValue("TITULO","")
	Self:Campo := oInfCpo:GetValue("CAMPO","")
	Self:Tamanho := oInfCpo:GetValue("TAMANHO",0)
	Self:ValorInicial := ""
	Self:Altera := oInfCpo:GetValue("ALTERA",.t.)
	Self:Obrigat := oInfCpo:GetValue("OBRIGATORIO",.f.)

Return Self


Class DMS_IFColObj From DMS_IFCol
	Method New() CONSTRUCTOR
EndClass

Method New(aDataContainer) Class DMS_IFColObj

	Default aDataContainer := {}

	_Super:New()

	oInfCpo := DMS_DataContainer():New(aDataContainer)
	Self:Tipo := "C"
	Self:Campo := "IMAGEM"
	Self:Tamanho := 3
	Self:Picture   := "@BMP"
	Self:Altera := .f.
	Self:Validacao := ".F."

//Aadd(aCabecalho, {;
//"",;//X3Titulo()
//"IMAGEM",;  //X3_CAMPO
//"@BMP",;		//X3_PICTURE
//3,;			//X3_TAMANHO
//0,;			//X3_DECIMAL
//".F.",;			//X3_VALID
//"",;			//X3_USADO
//"C",;			//X3_TIPO
//"",; 			//X3_F3
//"V",;			//X3_CONTEXT
//"",;			//X3_CBOX
//"",;			//X3_RELACAO
//"",;			//X3_WHEN
//"V"})			//
Return Self

/*/{Protheus.doc} DMS_IFColLogical
	Classe para criar campo tipo lógico

	@type class
	@author Vinicius Gati
	@since 18/07/2017
/*/
Class DMS_IFColLogical from DMS_IFCol
	Method New() CONSTRUCTOR
EndClass

/*/{Protheus.doc} New
	Metodo construtor

	@type function
	@author Vinicius Gati
	@since 18/07/2017
/*/
Method New(aDataContainer) Class DMS_IFColLogical
	_Super:New()
	Self:Tipo      := "L"
	Self:Tamanho   := 1
	Self:Validacao := ".T."
Return Self
