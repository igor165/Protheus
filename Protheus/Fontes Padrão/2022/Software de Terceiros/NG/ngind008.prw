#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND008.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND008
Cadastro de Pain�is de Indicadores.

@author Wagner Sobral de Lacerda
@since 13/04/2012

@return lExecute
/*/
//---------------------------------------------------------------------
Function NGIND008()

	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local lExecute := .T. // Vari�vel para identificar se pode ou n�o executar esta rotina
	Local oBrowse // Vari�vel do Browse

	// Log de Acesso LGPD
	If FindFunction( 'FWPDLogUser' )
		FWPDLogUser( 'NGIND008()' )
	EndIf

	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	lExecute := NGIND007OP()

	If lExecute
		// Declara as Vari�veis PRIVATE
		NGIND008VR()

		//----------------
		// Monta o Browse
		//----------------
		dbSelectArea("TZB")
		dbSetOrder(1)
		dbGoTop()

		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()

			// Defini��o da tabela do Browse
			oBrowse:SetAlias("TZB")

			// Defini��o da Legenda
			NGIND008LG(@oBrowse)

			// Defini��o do Filtro
			NGIND008FL(@oBrowse)

			// Descri��o do Browse
			oBrowse:SetDescription(cCadastro)

			// Menu Funcional relacionado ao Browse
			oBrowse:SetMenuDef("NGIND008")

		// Ativa��o da Classe
		oBrowse:Activate()
		//----------------
		// Fim do Browse
		//----------------
	EndIf

	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return lExecute

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 13/04/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	// Vari�vel do Menu
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.NGIND008" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.NGIND008" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.NGIND008" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.NGIND008" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DO < MODELO > * MVC                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 13/04/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTZB := FWFormStruct(1, "TZB", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZC := FWFormStruct(1, "TZC", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de dados que ser� constru�do
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("NGIND008", /*bPreValid*/, /*bPosValid*/, {|oModel| fMCommit(oModel) }/*bFormCommit*/, /*bFormCancel*/)

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formul�rio Principal
		oModel:AddFields("TZBMASTER"/*cID*/, /*cIDOwner*/, oStruTZB/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)

		// Adiciona ao modelo um componente de Grid, com o "TZBMASTER" como Owner
		oModel:AddGrid("TZCINDICS"/*cID*/, "TZBMASTER"/*cIDOwner*/, oStruTZC/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

			// Define a Rela��o do modelo das F�rmulas com o Principal (Indicador Gr�fico)
			oModel:SetRelation("TZCINDICS"/*cIDGrid*/,;
								{ {"TZC_FILIAL", 'xFilial("TZB")'}, {"TZC_CODPNL", "TZB_CODIGO"} }/*aConteudo*/,;
								TZC->( IndexKey(1) )/*cIndexOrd*/)

		// Adiciona a descri��o do Modelo de Dados (Geral)
		oModel:SetDescription(STR0005/*cDescricao*/) //"Pain�is de Indicadores"

			//--------------------------------------------------
			// Defini��es do Modelo do Indicador Gr�fico
			//--------------------------------------------------

			// Adiciona a descri��o do Modelo de Dados TZB
			oModel:GetModel("TZBMASTER"):SetDescription(STR0005/*cDescricao*/) //"Pain�is de Indicadores"

			//--------------------------------------------------
			// Defini��es do Modelo das F�rmulas
			//--------------------------------------------------

			// Adiciona a descri��o do Modelo de Dados TZC
			oModel:GetModel("TZCINDICS"):SetDescription(STR0006/*cDescricao*/) //"Indicadores do Painel"

				// Define que o Modelo n�o � obrigat�rio
				oModel:GetModel("TZCINDICS"):SetOptional(.T.)

				// Define qual a chave �nica por Linha no browse
				oModel:GetModel("TZCINDICS"):SetUniqueLine({"TZC_CODIND"})

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} fMCommit
Grava��o manual do Modelo de Dados.

@author Wagner Sobral de Lacerda
@since 02/03/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fMCommit(oModel)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Vari�veis do Modelo
	Local cFilial  := xFilial("TZB")
	Local cCodigo  := FWFldGet("TZB_CODIGO")
	Local cNome    := FWFldGet("TZB_NOME")
	Local cCodUser := FWFldGet("TZB_CODUSU")
	Local cNomUser := FWFldGet("TZB_NOMUSU")
	Local cCodModu := FWFldGet("TZB_MODULO")
	Local cNomModu := FWFldGet("TZB_NOMMOD")
	Local cAtivo   := FWFldGet("TZB_ATIVO")

	// Vari�veis do Painel
	Local aInfo := aClone( oTNGPanel:GetInfo() )

	// Vari�vel do Retorno
	Local lReturn := .T.

	//--------------------------------------------------
	// Grava��o do Modelo de Dados
	//--------------------------------------------------
//	FWFormCommit(oModel)//A grava��o � feita na classe TNGPanel

	//----------
	// Grava��o
	//----------
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		// Seta as novas Informa��es do Painel
		aInfo[1] := cFilial // 'Filial'
		aInfo[2] := cCodigo // 'C�digo do Painel'
		aInfo[3] := cNome // 'Nome do Painel'
		aInfo[4] := cCodUser // 'C�digo do Usu�rio'
		aInfo[5] := cNomUser // 'Nome do Usu�rio'
		aInfo[6] := cCodModu // 'M�dulo do Painel'
		aInfo[7] := cNomModu // 'Nome do M�dulo'
		aInfo[8] := cAtivo // 'Painel Ativo?' (1=Sim;2=N�o)

		oTNGPanel:SetInfo(aInfo) // Seta as informa��es

		// Salva o Painel de Indicadores
		lReturn := oTNGPanel:SavePanel()
		If !lReturn
			Help(Nil, Nil, STR0007, Nil, STR0008, 1, 0) //"Aten��o" ## "N�o foi poss�vel salvar o Painel de Indicadores."
		EndIf
	Else
		oTNGPanel:DelPanel(cCodigo, cFilial, cCodModu)
	EndIf

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DA < VIEW > * MVC                                                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Dimensionamento de Tela
	Local aScreen  := aClone( GetScreenRes() )
	Local nAltura  := aScreen[2]

	Local aPorcen := {}
	Local nPixels := 250 // Pixels para o cabe�alho

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("NGIND008")

	// Cria a estrutura a ser usada na View
	Local oStruTZB := FWFormStruct(2, "TZB", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZC := FWFormStruct(2, "TZC", /*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualiza��o constru�da
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados ser� utilizado na View
		oView:SetModel(oModel)

		// Valida a Inicializa��o da View
		oView:SetViewCanActivate({|oView| fVActivate(oView) }/*bBloclVld*/)

		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------

		// Adiciona no View um controle do tipo formul�rio (antiga Enchoice)
		oView:AddField("VIEW_TZBMASTER"/*cFormModelID*/, oStruTZB/*oViewStruct*/, "TZBMASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona um "outro" tipo de objeto, o qual n�o faz necessariamente parte do modelo
		oView:AddOtherObject("VIEW_PAINEL"/*cFormModelID*/, {|oPanel| fOtherPnl(oPanel) }/*bActivate*/, {|oPanel| fFreeOther(oPanel) }/*bDeActivate*/, /*bRefresh*/)

		//--------------------------------------------------
		// Layout
		//--------------------------------------------------

		// Cria os componentes "box" horizontais para receberem elementos da View
		aPorcen := Array(2)
		aPorcen[1] := ( (nPixels * 100) / nAltura ) // Quero 'nPixels' para a Altura
		aPorcen[2] := ( 100 - aPorcen[1] )
		oView:CreateHorizontalBox("BOX_SUPERIOR"/*cID*/, aPorcen[1]/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFERIOR"/*cID*/, aPorcen[2]/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

		// Relaciona o identificador (ID) da View com o "box" para exibi��o
		oView:SetOwnerView("VIEW_TZBMASTER"/*cFormModelID*/, "BOX_SUPERIOR"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_PAINEL"   /*cFormModelID*/, "BOX_INFERIOR"/*cIDUserView*/)

		// Adiciona um T�tulo para a View
		oView:EnableTitleView("VIEW_TZBMASTER"/*cFormModelID*/, "Cadastro"/*cTitle*/, /*nColor*/)
		oView:EnableTitleView("VIEW_PAINEL"   /*cFormModelID*/, "Painel"/*cTitle*/, /*nColor*/)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fViewModif
Atualiza a View, indicando que ela foi Modificada.

@author Wagner Sobral de Lacerda
@since 16/08/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fViewModif()

	// Modelos
	Local oView     := Nil
	Local oModelTZB := Nil

	// Dados do Modelo
	Local cOldTitulo := ""
	Local nOperation := 0

	// Apenas executa no cadastro de Pain�is de Indicadores
	If IsInCallStack("NGIND008")
		If Type("oBkpView") == "O"
			oView     := FWViewActive(oBkpView)
			oModelTZB := oView:GetModel("TZBMASTER")

			cOldTitulo := FWFldGet("TZB_NOME")
			nOperation := oView:GetOperation()

			If nOperation == MODEL_OPERATION_UPDATE .And. fPnlHasChang()
				// Se atualizou mas n�o houve altera��o no formul�rio
				If !oModelTZB:IsModified()
					oView:SetModified(.T./*lSet*/)
					// For�a uma atualiza��o no formul�rio
					oModelTZB:SetValue("TZB_NOME", "ZZZ")
					oModelTZB:SetValue("TZB_NOME", cOldTitulo)
				EndIf

				oView:Refresh()
			EndIf
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPnlHasChang
Verifica se o Painel de Indicadores em tela est� diferente do salvo na
base de dados.

@author Wagner Sobral de Lacerda
@since 16/08/2012

@return lHasChange
/*/
//---------------------------------------------------------------------
Static Function fPnlHasChang()

	// Dados do Modelo
	Local cFldCodPnl := FWFldGet("TZB_CODIGO")

	// Dados do Painel de Indicadores
	Local aPnlInds := aClone( oTNGPanel:GetIndics() )

	// Vari�vel do retorno
	Local lHasChange := .F.

	// Vari�veis auxiliares
	Local aAtuInds := {}
	Local nX := 0

	//--- Apenas verifica se o Painel foi modificado caso ele esteja criado
	If !oTNGPanel:IsCreated()
		Return lHasChange
	EndIf

	//------------------------------
	// Busca o Cadastro do Painel
	//------------------------------
	dbSelectArea("TZB")
	dbSetOrder(1)
	If dbSeek(xFilial("TZB") + cFldCodPnl)
		//------------------------------
		// Busca Indicadores do Painel
		//------------------------------
		dbSelectArea("TZC")
		dbSetOrder(1)
		dbSeek(xFilial("TZC", TZB->TZB_FILIAL) + TZB->TZB_CODIGO)
		While !Eof() .And. TZC->TZC_FILIAL == xFilial("TZC", TZB->TZB_FILIAL) .And. TZC->TZC_CODPNL == TZB->TZB_CODIGO

			If aScan(aAtuInds, {|x| x == TZC->TZC_CODIND }) == 0
				aAdd(aAtuInds, TZC->TZC_CODIND)
			EndIf

			dbSelectArea("TZC")
			dbSkip()
		End
	EndIf

	//------------------------------
	// Busca os Indicadores
	//------------------------------
	If Len(aAtuInds) <> Len(aPnlInds)
		lHasChange := .T.
	Else
		aSort(aAtuInds, , , {|x,y| x < y })
		aSort(aPnlInds, , , {|x,y| x < y })
		For nX := 1 To Len(aAtuInds)
			If AllTrim(aAtuInds[nX]) <> AllTrim(aPnlInds[nX])
				lHasChange := .T.
				Exit
			EndIf
		Next nX
	EndIf

Return lHasChange

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DOS "OTHER OBJECT" PARA A VIEW DO * MVC                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fOtherPnl
Monta a Preview (pr�-visualiza��o) do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 13/04/2012

@param oPanel
	Painel pai dos objetos * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fOtherPnl(oPanel)

	// Opera��o de a��o sobre o Modelo
	Local oModel     := FWModelActive()
	Local nOperation := oModel:GetOperation()

	// Vari�veis do Modelo
	Local cUsaFilial := xFilial("TZB")
	Local cUsaCodigo := FWFldGet("TZB_CODIGO")

	// Vari�veis de controle
	Local lEdicao := ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
	Local nMode := If(lEdicao, 2, 1)

	//--------------------
	// Monta Painel
	//--------------------
	// Atualiza Coordenadas do ojeto principal
	oPanel:CoorsUpdate()

		// Cria o Painel de Indicadores em Modo de Edi��o
		oTNGPanel := NGI8TNGPnl(oPanel, , , , nMode)
		If nOperation <> MODEL_OPERATION_INSERT
			oTNGPanel:LoadPanel(cUsaCodigo, cUsaFilial)
		EndIf
		oTNGPanel:SetOptions({}, {"NONE"}) // Define quais op��es dos bot�es est�o habilitadas
		//oTNGPanel:CanWait(.F.) // Define se pode apresentar a tela de espera, onde � poss�vel selecionar um Painel de Indicadores para ser carregado
		If lEdicao
			oTNGPanel:Enable()
		Else
			oTNGPanel:Disable()
		EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFreeOther
Destroi os objetos dos 'Other Objetcs'.

@author Wagner Sobral de Lacerda
@since 16/04/2012

@param oPanel
	Painel pai dos objetos * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFreeOther(oPanel)

	// Desativa o Painel de Indicadores
	If ValType(oTNGPanel) == "O"
		oTNGPanel:DeActivate()
		oTNGPanel:Destroy()
	EndIf
	// Libera os componentes Filhos do Painel
	If ValType(oPanel) == "O"
		oPanel:FreeChildren()
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DAS VALIDA��ES * MVC                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fVActivate
Valida se pode ativar a View.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param oView
	Objeto da View em MVC * Obrigat�rio

@return lReturn .T. pode inicializar; .F. n�o pode
/*/
//---------------------------------------------------------------------
Static Function fVActivate(oView)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oView:GetOperation()

	// Vari�vel do Retorno
	Local lReturn := .T.

	//------------------------------
	// Valida a Ativa��o da View
	//------------------------------
	If nOperation <> MODEL_OPERATION_INSERT .And. nOperation <> MODEL_OPERATION_VIEW // Diferente de Inclus�o e de Visualiza��o

		If RetCodUsr() <> TZB->TZB_CODUSU
			Help(Nil, Nil, STR0007, Nil, STR0009, 1, 0) //"Aten��o" ## "Este registro n�o pode ser manipulado porque � de autoria de outro usu�rio."
			lReturn := .F.
		EndIf

	EndIf

	// Armazena um backup da view
	oBkpView := oView

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## FUN��ES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND008VR
Declara as vari�veis Private utilizadas no Painel de Indicadores.
* Lembrando que essas vari�veis ficam declaradas somente para a fun��o
que � Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 16/04/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND008VR()

	//------------------------------
	// Declara as vari�veis
	//------------------------------

	_SetOwnerPrvt("oBkpView", Nil) // Objeto da View Atual do cadstro do Painel de Indicadores

	// Vari�vel do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0010)) //"Painel de Indicadores"

	// Vari�veis dos Objetos do Painel
	_SetOwnerPrvt("oTNGPanel", Nil)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND008LG
Fun��o para adicionar uma Legenda padronizada ao browse dos
Pain�s de Indicadores (tabela TZB)

@author Wagner Sobral de Lacerda
@since 16/04/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND008LG(oObjBrw)

	// Vari�vel do retorno
	Local lRetorno := .F.

	// Defaults
	Default oObjBrw := Nil

	//----------
	// Legenda
	//----------
	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TZB"
			oObjBrw:AddLegend("TZB_ATIVO == '1'", "GREEN", STR0011) //"Ativo"
			oObjBrw:AddLegend("TZB_ATIVO == '2'", "RED"  , STR0012) //"Inativo"

			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND008FL
Fun��o para adicionar um Filtro padronizado ao browse dos
Pain�s de Indicadores (tabela TZB)

@author Wagner Sobral de Lacerda
@since 16/04/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigat�rio

@return lRetorno
/*/
//---------------------------------------------------------------------
Function NGIND008FL(oObjBrw)

	// Vari�vel do retorno
	Local lRetorno := .F.

	// Vari�veis do Filtro
	Local cFiltro := ""

	// Defaults
	Default oObjBrw := Nil

	//----------
	// Legenda
	//----------
	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TZB"
			cFiltro := "TZB_MODULO == '" + Str(nModulo,2) + "'"
			If !FWIsAdmin()
				cFiltro += ".And. TZB_CODUSU == '" + RetCodUsr() + "'"
			EndIf
			oObjBrw:SetFilterDefault(cFiltro)


			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

/*/
############################################################################################
##                                                                                        ##
## FUN��ES PARA MANIPULA��O DA CLASSE 'TNGPanel'                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8TNGPnl
Executa a cria��o de um Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 09/08/2012

@param oParent
	Indica o objeto Pai da classe * Obrigat�rio
@param cSetPanel
	C�digo do Painel a ser carregado * Opcional
@param cSetFilial
	C�digo da Fiilial do Painel a ser carregado * Opcional
@param cSetModulo
	C�digo do M�dulo do Painel a ser carregado * Opcional
@param nSetMode
	N�mero do Modo de A��o sobre a classe * Opcioanl
	   1 - Consulta
	   2 - Edi��o

@return oTNGPanel
/*/
//---------------------------------------------------------------------
Function NGI8TNGPnl(oParent, cSetPanel, cSetFilial, cSetModulo, nSetMode)

	//------------------------------
	// Instancia a Classe
	//------------------------------
	oTNGPanel := TNGPanel():New(oParent/*oParent*/, cSetPanel/*cSetPanel*/, cSetFilial/*cSetFilial*/, cSetModulo/*cSetModulo*/, nSetMode/*nSetMode*/)

	//----------------------------------------------------------------------
	// Define os Blocos de C�digo necess�rios para manipular a classe
	//----------------------------------------------------------------------
	// M�todo relacionado: SetPanel
	oTNGPanel:SetCodeBlock(1, {|cSetPanel, cSetFilial, cSetModulo, aOutrosInds| NGI8SetPnl(cSetPanel, cSetFilial, cSetModulo, aOutrosInds) })
	oTNGPanel:SetCodeBlock(13, {|oTNGPanel,lIsCreated| NGI8EndPnl(oTNGPanel, lIsCreated) })

	// M�todo relacionado: Create
	oTNGPanel:SetCodeBlock(2, {|oObjIndic, cLoadFormu| NGI7LoaFrm(oObjIndic, cLoadFormu) })

	// M�todo relacionado: SelectInds
	oTNGPanel:SetCodeBlock(3, {|| NGI8SlcCha() })
	oTNGPanel:SetCodeBlock(4, {|oObjBrowse, oObjPreview, aInds| NGI8SlcChg(oObjBrowse, oObjPreview, aInds) })
	oTNGPanel:SetCodeBlock(5, {|oObjBrowse, aInds| NGI8SlcViw(oObjBrowse, aInds) })

	// M�todo relacionado: MakeCad
	oTNGPanel:SetCodeBlock(6, {|nOpcCad, aInfo| NGI8MakCad(nOpcCad, aInfo) })

	// M�todo relacionado: SavePanel
	oTNGPanel:SetCodeBlock(7, {|aInfo, aIndics| NGI8SavPnl(aInfo, aIndics) })

	// M�todo relacionado: SavePanel / LoadPanel
	oTNGPanel:SetCodeBlock(8, {|cCodPanel, cCodFilia, cCodModul| NGI8LoaPnl(cCodPanel, cCodFilia, cCodModul) })

	// M�todo relacionado: DelPanel
	oTNGPanel:SetCodeBlock(9, {|cCodPanel, cCodFilia, cCodModul| NGI8DelPnl(cCodPanel, cCodFilia, cCodModul) })

	// M�todo relacionado: SelectPanel
	oTNGPanel:SetCodeBlock(10, {|| NGI8ConPnl() })

	// M�todo relacionado: SaveConfig / LoadConfig
	oTNGPanel:SetCodeBlock(11, {|aCustom, nOption| NGI8Custom(aCustom, nOption) })

	// M�todo relacionado: Activate
	oTNGPanel:SetCodeBlock(12, {|nMode| NGI8Activa(nMode) })

	// M�todo relacionado: Fields
	oTNGPanel:SetCodeBlock(14, {|| NGI7Fields() })
	// M�todo relacionado: Information
	oTNGPanel:SetCodeBlock(15, {|oObjIndic| NGI7Info(oObjIndic) })
	// M�todo relacionado: Details
	oTNGPanel:SetCodeBlock(16, {|oObjIndic| NGI7Detail(oObjIndic) })
	// M�todo relacionado: Legend
	oTNGPanel:SetCodeBlock(17, {|oObjIndic| NGI7Legend(oObjIndic) })

	//----------------------------------------------------------------------
	// Define as especifica��es dos campos da classe
	//----------------------------------------------------------------------
	// Exemplo: Filial, C�digo, Nome, etc.
	oTNGPanel:SetFldInfo(NGI8FldInf())

	//------------------------------
	// Ativa a Classe
	//------------------------------
	oTNGPanel:Activate()

Return oTNGPanel

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8SetPnl
Executa o 'Set Panel' (Define o Painel) para o Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@param cSetPanel
	C�digo do Painel de Indicador para carregar * Opcional
	Default: ""
@param cSetFilial
	C�digo da Filial do Painel de Indicadores * Opcional
	Default: xFilial("TZB")
@param cSetModulo
	C�digo do M�dulo do Painel de Indicadores * Opcional
	Default: Str(nModulo,2)
@param cSetModulo
	Array com Indicadores espec�ficos a serem montados * Opcional
	   ATEN��O: se este par�metro for passado, os indicadores da base
	   n�o ser�o carregados; somente os do array ser�o!
	Default: {}

@return aRet
/*/
//---------------------------------------------------------------------
Function NGI8SetPnl(cSetPanel, cSetFilial, cSetModulo, aOutrosInds) // SetPanel

	// Salva as �res atuais
	Local aAreaTZ1 := TZ1->( GetArea() )
	Local aAreaTZ5 := TZ5->( GetArea() )
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZC := TZC->( GetArea() )

	// Vari�veis auxiliares
	Local aTempInds	:= {}
	Local aVerPars	:= {}
	Local nScan		:= 0, nOrder := 0, nX := 0, nY := 0

	Local cNomeForm	:= "", cNomeClass := "", cNomeParam := ""
	Local cMemoTZ5	:= "", cMemoTZ52 := ""

	Local lIndFromDB	:= .T.

	// Vari�vel do Retorno
	Local aRet			:= {}
	Local aInfo		:= {}
	Local aClassInds	:= {}
	Local aParams		:= {}

	// Defaults
	Default cSetPanel   := ""
	Default cSetFilial  := xFilial("TZB")
	Default cSetModulo  := Str(nModulo,2)
	Default aOutrosInds := {}

	// Vari�veis utilizadas em fun��es fora deste fonte (evite altera��es, pois devem estar de acordo com o fonte NGIND001, na fun��o NGIndParm())
	Private aIndParm := {}
	Private aVarParm := {}

	// Vari�veis utilizadas para verifica��o de Dicion�rio/Tabela
	Private lTZ5_ATIVO := NGCADICBASE("TZ5_ATIVO", "A", "TZ5", .F.)
	Private lTZ5_FORCO := NGCADICBASE("TZ5_FORCON","A", "TZ5",.F.)

	// Define o c�digo da filial
	cSetFilial := If(Empty(cSetFilial), xFilial("TZB"), cSetFilial)
	// Define o c�digo do M�dulo
	cSetModulo := If(Empty(cSetModulo), Str(nModulo,2), cSetModulo)
	// Define o c�digo do Painel de Indicadores
	cSetPanel := PADR(cSetPanel, TAMSX3("TZB_CODIGO")[1], " ")

	// Indica se carrega da Base de Dados ou do Array
	lIndFromDB := ( Len(aOutrosInds) == 0 )

	//--------------------
	// Seta da Tabela
	//--------------------
	dbSelectArea("TZB")
	dbSetOrder(1)
	If dbSeek(cSetFilial + cSetPanel)
		// Define as informa��es
		aInfo := Array(8)
		aInfo[1] := TZB->TZB_FILIAL // 'Filial'
		aInfo[2] := TZB->TZB_CODIGO // 'C�digo do Painel'
		aInfo[3] := TZB->TZB_NOME // 'Nome do Painel'
		aInfo[4] := TZB->TZB_CODUSU // 'C�digo do Usu�rio'
		aInfo[5] := UsrFullName(TZB->TZB_CODUSU) // 'Nome do Usu�rio'
		aInfo[6] := TZB->TZB_MODULO // 'M�dulo do Painel'
		aInfo[7] := PADR(NGRetModNa(TZB->TZB_MODULO), TAMSX3("TZB_NOMMOD")[1], " ") // 'Nome do M�dulo'
		aInfo[8] := TZB->TZB_ATIVO // 'Painel Ativo?' (1=Sim;2=N�o)

		//----------------------------------------
		// Define os Indicadores do Painel
		//----------------------------------------
		If lIndFromDB
			dbSelectArea("TZC")
			dbSetOrder(1)
			dbSeek(TZB->TZB_FILIAL + TZB->TZB_CODIGO, .T.)
			While !Eof() .And. TZC->TZC_FILIAL == TZB->TZB_FILIAL .And. TZC->TZC_CODPNL == TZB->TZB_CODIGO
				// Verifica se o Indicador est� ativo
				dbSelectArea("TZ5")
				dbSetOrder(1)
				If dbSeek(xFilial("TZ5", TZC->TZC_FILIAL) + TZB->TZB_MODULO + TZC->TZC_CODIND) .And. If(lTZ5_ATIVO, (TZ5->TZ5_ATIVO == "1"), .T.)
					aTempInds := aClone( fGetClsInd( aClone( aTempInds ) ) )
				EndIf

				dbSelectArea("TZC")
				dbSkip()
			End
		EndIf
	EndIf

	//--------------------
	// Seta do Array
	//--------------------
	For nX := 1 To Len(aOutrosInds)
		// Verifica se j� n�o est� adicionado
		nScan := 0
		For nY := 1 To Len(aTempInds)
			nScan := aScan(aTempInds[nY][3], {|x| AllTrim(x[1]) == AllTrim(aOutrosInds[nX]) })
			If nScan > 0
				Exit
			EndIf
		Next nY
		If nScan > 0
			Loop
		EndIf

		// Verifica se o Indicador est� ativo
		dbSelectArea("TZ5")
		dbSetOrder(1)
		If dbSeek(xFilial("TZ5") + Str(nModulo,2) + aOutrosInds[nX]) .And. If(lTZ5_ATIVO, (TZ5->TZ5_ATIVO == "1"), .T.)
			aTempInds := aClone( fGetClsInd( aClone( aTempInds ) ) )
		EndIf
	Next nX

	//------------------------------
	// Copia para o Array da Classe
	//------------------------------
	aSort(aTempInds, , , {|x,y| x[1] < y[1] })
	aClassInds := aClone( aTempInds )
	If Len(aClassInds) > 0
		//----------------------------------------
		// Define os Par�metros do Painel
		//----------------------------------------
		// Separa os par�metros para o Painel (n�o importa para qual vari�vel o par�metro �; o que importa � que ele � utilizada no Painel)
		aVerPars  := {}
		nOrder    := 0
		For nX := 1 To Len(aVarParm)
			nScan := aScan(aVerPars,{ | x | x[ 2 ] == aVarParm[nX][3] })
			If nScan == 0
				nOrder++
				aAdd(aVerPars, {PADL(nOrder, 3, "0"), aVarParm[nX][3], aVarParm[nX][4], aVarParm[nX][1]})
			EndIf
		Next nX

		// Busca o Cadastro dos Par�metros
		For nX := 1 To Len(aVerPars)
			nScan := aScan(aParams, {|x| x[2] == aVerPars[nX][2] })
			If nScan == 0
				dbSelectArea("TZ4")
				dbSetOrder(1)
				If dbSeek(xFilial("TZ4", TZB->TZB_FILIAL) + TZB->TZB_MODULO + aVerPars[nX][2])
					/* Tipos de Par�metros
						"1" - Caractere
						"2" - Num�rico
						"3" - L�gico
						"4" - Data
						"5" - Campo
						"6" - Lista de Op��es
					*/
					aAdd(aParams, Array(13))
					nScan := Len(aParams)

					aParams[nScan][1] := aVerPars[nX][1]
					aParams[nScan][2] := aVerPars[nX][2]
					aParams[nScan][3] := aVerPars[nX][3]
					aParams[nScan][4] := TZ4->TZ4_TIPO
					If aParams[nScan][4] == "5" // Campo
						dbSelectArea("SX3")
						dbSetOrder(2)
						If dbSeek(TZ4->TZ4_CAMPOS)
							aParams[nScan][5] := TamSX3(TZ4->TZ4_CAMPOS)[1]
							aParams[nScan][6] := Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_DECIMAL")
							aParams[nScan][7] := PesqPict(Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_ARQUIVO"), TZ4->TZ4_CAMPOS, )
							aParams[nScan][8] := AllTrim( Posicione("SX3",2,TZ4->TZ4_CAMPOS,"X3_ARQUIVO"))
							aParams[nScan][9] := AllTrim(TZ4->TZ4_CAMPOS)
							aParams[nScan][10] := AllTrim( TZ4->TZ4_F3 )
							aParams[nScan][11] := AllTrim( X3Cbox() )
						EndIf
					Else
						aParams[nScan][5] := TZ4->TZ4_TAMANH
						aParams[nScan][6] := TZ4->TZ4_DECIMA
						aParams[nScan][7] := AllTrim( TZ4->TZ4_PICTUR )
						aParams[nScan][8] := AllTrim( TZ4->TZ4_TABELA )
						aParams[nScan][9] := AllTrim( TZ4->TZ4_CAMPOS )
						aParams[nScan][10] := AllTrim( TZ4->TZ4_F3 )
						aParams[nScan][11] := AllTrim( TZ4->TZ4_OPCOES )
					EndIf

					// Inicializa em branco o Conte�do do par�metro
					Do Case
						Case (aParams[nScan][4] == "1" .Or. aParams[nScan][4] == "5") .And. Empty( aParams[nScan][12] ) // 1 = Caracter ou 5 = Campo
							If "ATE_" $ Alltrim(aParams[nScan][2])
								aParams[nScan][12] := Replicate("Z", aParams[nScan][5]) // Adiciona o 'ZZZZ' conforme o tamanho do campo.
							EndIf
						Case aParams[nScan][4] == "2" .And. Empty( aParams[nScan][12] )// 2 = Numerico
							aParams[nScan][12] := 0
						Case aParams[nScan][4] == "3" .And. Empty( aParams[nScan][12] ) // 3 = Logico
							aParams[nScan][12] := .T.
						Case aParams[nScan][4] == "4" .And. Empty( aParams[nScan][12] ) // 4 = Data
							If "ATE_" $ Alltrim(aParams[nScan][2])
								aParams[nScan][12] := dDataBase // Adiciona data da base
							Else
								aParams[nScan][12] := MonthSub(dDataBase, 1) // Adiciona uma data 1 mes a menos que a da base.
							EndIf
						Case aParams[nScan][4] == "6"  .And. Empty( aParams[nScan][12] )// 6 = Lista Opcoes
							aParams[nScan][12] := "1"
					EndCase

					// Define os campos obrigat�rios
					If "ATE_" $ Alltrim(aParams[nScan][2]) .Or. "_DATA" $ Alltrim(aParams[nScan][2])
						aParams[nScan][13] := .T. // Declara como obrigat�rio
					Else
						aParams[nScan][13] := Posicione("TZ7", 3, xFilial("TZ7") + TZ4->TZ4_CODPAR + aVerPars[nX][4],"TZ7_TIPO") == "2" // Verifica se � obrigat�rio
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf

	/* Defini��o do Retorno:
		[1] - aInfo: Informa��es cadastrais do Painel
		[2] - aClassInds: Classifica��es e seus respectivos Indicadores
		[3] - aParams: Par�metros do Painel
	*/
	aRet := Array(3)
	aRet[1] := aClone(aInfo)
	aRet[2] := aClone(aClassInds)
	aRet[3] := aClone(aParams)

	// Devolve as �reas
	RestArea(aAreaTZ1)
	RestArea(aAreaTZ5)
	RestArea(aAreaTZB)
	RestArea(aAreaTZC)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetClsInd
Fun��o para retornar a Classifica��o e seus Indicadores.
* � bem espec�fica, e as tabelas DEVEM estar posicionadas

@author Wagner Sobral de Lacerda
@since 21/05/2012

@param aClassInds
	Array com as Classifica��es e Indicadores * Obrigat�rio

@return aClassInds
/*/
//---------------------------------------------------------------------
Static Function fGetClsInd(aClassInds)

	// Vari�veis de Controle
	Local cNomeForm := "", cNomeClass := ""
	Local cMemoTZ5 := "", cMemoTZ52 := ""
	Local nScan := 0

	//----------
	// Conte�do
	//----------
	// Recebe o Nome da F�rmula
	cNomeForm := AllTrim(TZ5->TZ5_NOME)

	// Adiciona ao Array de Classifica��es & Indicadores
	nScan := aScan(aClassInds, {|x| x[1] == TZ5->TZ5_CODCLA })
	If nScan == 0
		// Nome da Classifica��o
		cNomeClass := "Undefined"
		dbSelectArea("TZ1")
		dbSetOrder(1)
		If dbSeek(xFilial("TZ1", TZ5->TZ5_FILIAL) + TZ5->TZ5_MODULO + TZ5->TZ5_CODCLA)
			cNomeClass := AllTrim(TZ1->TZ1_DESCRI)
		EndIf

		// Adiciona
		aAdd(aClassInds, Array(3))
		nScan := Len(aClassInds)
		aClassInds[nScan][1] := TZ5->TZ5_CODCLA
		aClassInds[nScan][2] := cNomeClass
		aClassInds[nScan][3] := {}
	EndIf
	aAdd(aClassInds[nScan][3], {TZ5->TZ5_CODIND, cNomeForm})

	// Armazena os par�metros
	cMemoTZ5  := Alltrim(TZ5->TZ5_FORMUL)
	cMemoTZ52 := If(lTZ5_FORCO, Alltrim(TZ5->TZ5_FORCON), "")
	NGIndParm(cMemoTZ5+cMemoTZ52, TZ5->TZ5_CODIND)

Return aClassInds

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8SlcCha
Executa o 'Charge' (carga) do Browse.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@return aRet
/*/
//---------------------------------------------------------------------
Function NGI8SlcCha()

	// Vari�vel do retorno
	Local aRet := {}

	// Vari�veis auxiliares
	Local aHeader    := {}
	Local aClassInds := {}
	Local nScan      := 0
	Local cBrchTZ5   := xFilial( 'TZ5' )
	Local cModule    := Str( nModulo, 2 )

	Local lTZ5_ATIVO := NGCADICBASE("TZ5_ATIVO", "A", "TZ5", .F.)

	//--------------------
	// Cabe�alho
	//--------------------
	aAdd(aHeader, {RetTitle("TZ5_CODIND"), "C", TAMSX3("TZ5_CODIND")[1], TAMSX3("TZ5_CODIND")[2], PesqPict("TZ5", "TZ5_CODIND", )})
	aAdd(aHeader, {RetTitle("TZ5_NOME")  , "C", TAMSX3("TZ5_NOME")[1]  , TAMSX3("TZ5_NOME")[2]  , PesqPict("TZ5", "TZ5_NOME"  , )})

	//--------------------
	// Conte�do
	//--------------------
	dbSelectArea("TZ5")
	dbSetOrder(1)
	dbSeek( cBrchTZ5 + cModule, .T.)
	While TZ5->( !EoF() ) .And. cBrchTZ5 == TZ5->TZ5_FILIAL .And. cModule == TZ5->TZ5_MODULO
		
		If If(lTZ5_ATIVO, (TZ5->TZ5_ATIVO == "1"), .T.) // Deve estar Ativo
			// Busca Classifica��o
			dbSelectArea("TZ1")
			dbSetOrder(1)
			If dbSeek(xFilial("TZ1", TZ5->TZ5_FILIAL) + TZ5->TZ5_MODULO + TZ5->TZ5_CODCLA)
				// Busca Indicadores (F�rmulas) relacionadas � um Indicador Gr�fico
				dbSelectArea("TZA")
				dbSetOrder(2)
				If dbSeek(xFilial("TZA", TZ5->TZ5_FILIAL) + TZ5->TZ5_CODIND)
					// Busca Indicador Gr�fica
					dbSelectArea("TZ9")
					dbSetOrder(1)
					If dbSeek(xFilial("TZ9", TZA->TZA_FILIAL) + TZA->TZA_CODGRA) .And. TZ9->TZ9_ATIVO == "1" // Deve estar Ativo
						// Adiciona a Classifica��o
						nScan := aScan(aClassInds, {|x| x[1] == TZ1->TZ1_CODCLA })
						If nScan == 0
							aAdd(aClassInds, {TZ1->TZ1_CODCLA, TZ1->TZ1_DESCRI, {}})
							nScan := Len(aClassInds)
						EndIf
							
						aAdd( aClassInds[nScan,3], { TZ5->TZ5_CODIND, TZ5->TZ5_NOME, TZ1->TZ1_CODCLA, TZ1->TZ1_DESCRI,;
							TZ9->TZ9_CODIGO, .F. } )

					EndIf

				EndIf

			EndIf
			
		EndIf

		dbSelectArea("TZ5")
		dbSkip()
	End

	/* Defini��o do Retorno:
		[1] - Cabe�alho
		[2] - Classifica�es
		[2][3] - Indicadores (F�rmulas)
	*/
	aRet := Array(2)
	aRet[1] := aClone(aHeader)
	aRet[2] := aClone(aClassInds)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8SlcChg
Executa o 'Change' (mudan�a de linha) do Browse.

@author Wagner Sobral de Lacerda
@since 27/04/2012

@param oObjBrowse
	Objeto do Browse de Sele��o de Indicadores * Obrigat�rio
@param oObjPreview
	Objeto do Indicador Gr�fico (TNGIndicator) * Obrigat�rio
@param aInds
	Array com a Classifica��o e seus respectivos Indicadores * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Function NGI8SlcChg(oObjBrowse, oObjPreview, aInds) // fSlcBrwChg

	// Vari�veis de controle
	Local nATBrw := oObjBrowse:AT()

	// Recarrega as Configura��es para o Preview
	If Len(aInds[3]) >= nATBrw
		NGI7LoaCfg(oObjPreview/*oObjIndic*/, aInds[3][nATBrw][5]/*cCodIndic*/, /*cCodFilial*/, /*lShowMsg*/)
		NGI7LoaFrm(oObjPreview/*oObjIndic*/, aInds[3][nATBrw][1]/*cCodFormul*/, /*cCodFilial*/, /*cCodModulo*/, .F./*lShowMsg*/)
		oObjPreview:SetValue( aTail(oObjPreview:GetVals()) )
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8SlcViw
Executa o 'View' (visualiza��o) do item do Browse.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@param oObjBrowse
	Objeto do Browse de Sele��o de Indicadores * Obrigat�rio
@param aInds
	Array com a Classifica��o e seus respectivos Indicadores * Obrigat�rio

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGI8SlcViw(oObjBrowse, aInds) // fSlcBrwVis

	// Vari�veis de controle
	Local nATBrw := oObjBrowse:AT()

	Local aLoadMenu := {}
	Local cLoadFunc := ""
	Local nScan := 0

	// Vari�veis de armazenamento de estado anterior
	Local aOldRotina := Nil
	Local cOldCadast := Nil
	Local lOldINCLUI := Nil
	Local lOldALTERA := Nil

	// Vari�vel do retorno
	Local lReturn := .T.

	// Armazena vari�veis anteriores
	If Type("aRotina") == "A"
		aOldRotina := aClone( aRotina )
	Else
		Private aRotina := {}
	EndIf
	If Type("cCadastro") == "C"
		cOldCadast := cCadastro
	Else
		Private cCadastro := ""
	EndIf
	If Type("INCLUI") == "L"
		lOldINCLUI := INCLUI
	Else
		Private INCLUI := .T.
	EndIf
	If Type("ALTERA") == "L"
		lOldALTERA := ALTERA
	Else
		Private ALTERA := .T.
	EndIf

	// Define 'cCadastro'
	cCadastro := OemToAnsi(STR0013) //"Cadastro do Indicador (F�rmula)"

	// Define 'aRotina'
	aAdd(aRotina, {"", "", 0, 1})
	aAdd(aRotina, {"", "", 0, 2})
	aAdd(aRotina, {"", "", 0, 3})
	aAdd(aRotina, {"", "", 0, 4})
	aAdd(aRotina, {"", "", 0, 5})

	// Define 'INCLUI' e 'ALTERA'
	INCLUI := .F.
	ALTERA := .F.

	// Busca o cadastro do Indicador (F�rmula)
	dbSelectArea("TZ5")
	dbSetOrder(1)
	If dbSeek(xFilial("TZ5") + Str(nModulo,2) + aInds[3][nATBrw][1])
		aLoadMenu := aClone( FWLoadMenu("NGIND005") )

		nScan := aScan(aLoadMenu, {|x| x[4] == 2 }) // Fun��o de Visualiza��o
		If nScan > 0
			cLoadFunc := aLoadMenu[nScan][2]
			If AT("(", cLoadFunc) == 0 .And. AT(")", cLoadFunc) == 0
				cLoadFunc += "('" + "TZ5" + "', " + cValToChar(RecNo()) + ", 2)"
			EndIf
			&(cLoadFunc) // Executa
		EndIf
	Else
		Help(,, STR0007,, STR0014, 1, 0) //"Aten��o" ## "N�o foi poss�vel encontrar o cadastro do item."
		lReturn := .F.
	EndIf

	// Devolve vari�veis
	If Type("aOldRotina") == "A"
		aRotina := aClone( aOldRotina )
	EndIf
	If Type("cOldCadast") == "C"
		cCadastro := cOldCadast
	EndIf
	If Type("lOldINCLUI") == "L"
		INCLUI := lOldINCLUI
	EndIf
	If Type("lOldALTERA") == "L"
		ALTERA := lOldALTERA
	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8MakCad
Executa o Cadastro do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@param nOpcCad
	N�mero da Op��o do Cadastro * Obrigat�rio
	   2 - Visualizar
	   3 - Incluir
	   4 - Alterar
	   5 - Excluir
@param aInfo
	Informa��es (Dados Cadastrais) do Painel * Obrigat�rio

@return aReturn
/*/
//---------------------------------------------------------------------
Function NGI8MakCad(nOpcCad, aInfo) // MakeCad

	// Vari�veis da Janela
	Local oDlgCad
	Local cDlgCad := OemToAnsi( If(nOpcCad == 3, STR0015, STR0016) ) //"Novo Cadastro" ## "Cadastro"
	Local lDlgCad
	Local oPnlCad

	Local oMsMGet

	// Vari�veis de Controle
	Local aCampos := {}
	Local lFound := .F.
	Local nCad := 0, nX := 0

	Local lCanMakeCad := ( !IsInCallStack("NGIND008") )

	// Vari�vel do Retorno
	Local aReturn := {.F., Array(8)}

	// Armazena vari�veis anteriores
	Local aOldRotina := Nil
	Local lOldINCLUI := Nil
	Local lOldALTERA := Nil


	If !lCanMakeCad
		//------------------------------
		// Define como est� o cadastro
		//------------------------------
		lDlgCad := .T.
	Else
		//------------------------------
		// Monta tela de Cadastro
		//------------------------------
		If Type("aRotina") == "A"
			aOldRotina := aClone( aRotina )
		Else
			Private aRotina := {}
		EndIf
		If Type("INCLUI") == "L"
			lOldINCLUI := INCLUI
		Else
			Private INCLUI := .T.
		EndIf
		If Type("ALTERA") == "L"
			lOldALTERA := ALTERA
		Else
			Private ALTERA := .T.
		EndIf

		// Define 'aRotina'
		aAdd(aRotina, {"", "", 0, 1})
		aAdd(aRotina, {"", "", 0, 2})
		aAdd(aRotina, {"", "", 0, 3})
		aAdd(aRotina, {"", "", 0, 4})
		aAdd(aRotina, {"", "", 0, 5})

		//----------
		// Monta
		//----------
		INCLUI := (nOpcCad == 3)
		ALTERA := (nOpcCad == 4)

		// Busca o Cadastro
		dbSelectArea("TZB")
		dbSetOrder(1)
		If !INCLUI
			lFound := dbSeek(xFilial("TZB") + aInfo[1])
		EndIf
		// Carrega para a mem�ria
		RegToMemory("TZB", INCLUI)

		// Se for inclus�o, apenas define alguns conte�dos de acordo com as informa��es do Painel
		If INCLUI
			M->TZB_NOME := aInfo[3]
			If !Empty(aInfo[4])
				M->TZB_CODUSU := aInfo[4]
			EndIf
			If !Empty(aInfo[5])
				M->TZB_NOMUSU := aInfo[5]
			EndIf
			If !Empty(aInfo[8])
				M->TZB_ATIVO := aInfo[8]
			EndIf
		Else
			// Campos que podem aparecer na edi��o
			//aCampos := aClone( NGCAMPNSX3("TZB", {"TZB_CODIGO", "TZB_ATIVO"}) )

			// Se n�o for inclus�o e n�o achou o registro, carrega as informa��es do Painel para a mem�ria
			If !lFound
				M->TZB_FILIAL := xFilial("TZB")
				M->TZB_CODIGO := aInfo[2]
				M->TZB_NOME   := aInfo[3]
				M->TZB_CODUSU := If(Empty(aInfo[4]), RetCodUsr(), aInfo[4])
				M->TZB_NOMUSU := If(Empty(aInfo[5]), UsrFullName(RetCodUsr()), aInfo[5])
				M->TZB_MODULO := If(Empty(aInfo[6]), Str(nModulo,2), aInfo[6])
				M->TZB_NOMMOD := If(Empty(aInfo[7]), NGRetModNa(nModulo), aInfo[7])
				M->TZB_ATIVO  := If(Empty(aInfo[8]), "1", aInfo[8])
			EndIf
		EndIf

		// Monta a Tela
		lDlgCad := .F.
		DEFINE MSDIALOG oDlgCad TITLE cDlgCad FROM 0,0 TO 400,600 OF GetWndDefault() PIXEL

			// Painel Principal do Dialog
			oPnlCad := TPanel():New(01, 01, , oDlgCad, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlCad:Align := CONTROL_ALIGN_ALLCLIENT

				oMsMGet := MsMGet():New("TZB",RecNo(),nOpcCad,/*aCRA*/,/*cLetras*/,/*cTexto*/,If(Len(aCampos) > 0, aCampos, Nil)/*aChoice*/,/*aPos*/,/*aCpos*/,;
									  		3/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oDlgCad/*oDlg*/,/*lF3*/,.T./*lMemoria*/,.F./*lColumn*/,;
											/*caTela*/,/*lNoFolder*/,/*lProperty*/, /*aField*/)
				oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgCad ON INIT EnchoiceBar(oDlgCad, {|| lDlgCad := .T., oDlgCad:End() }, {|| lDlgCad := .F., oDlgCad:End() }) CENTERED

		If lDlgCad
			If (nOpcCad == 3)
				ConfirmSX8()
			EndIf

			If nOpcCad == 4
				dbSelectArea("TZB")
				dbSetOrder(1)
				If dbSeek(M->TZB_FILIAL + M->TZB_CODIGO)
					BEGIN TRANSACTION
					RecLock("TZB", .F.)
					TZB->TZB_NOME  := M->TZB_NOME
					TZB->TZB_ATIVO := M->TZB_ATIVO
					MsUnlock("TZB")
					END TRANSACTION
				EndIf
			EndIf
		Else
			If (nOpcCad == 3)
				RollBackSX8()
			EndIf
		EndIf

		// Devolve vari�veis
		If Type("aOldRotina") == "A"
			aRotina := aClone( aOldRotina )
		EndIf
		If Type("lOldINCLUI") == "L"
			INCLUI := lOldINCLUI
		EndIf
		If Type("lOldALTERA") == "L"
			ALTERA := lOldALTERA
		EndIf

	EndIf

	aReturn[1] := lDlgCad
	If aReturn[1]
		// Atualiza as Informa��es do Pain�is
		aReturn[2][1] := xFilial("TZB") // 'Filial'
		aReturn[2][2] := M->TZB_CODIGO // 'C�digo do Painel'
		aReturn[2][3] := M->TZB_NOME // 'Nome do Painel'
		aReturn[2][4] := M->TZB_CODUSU // 'C�digo do Usu�rio'
		aReturn[2][5] := UsrFullName(M->TZB_CODUSU) // 'Nome do Usu�rio'
		aReturn[2][6] := M->TZB_MODULO // 'M�dulo do Painel'
		aReturn[2][7] := PADR(NGRetModNa(M->TZB_MODULO), TAMSX3("TZB_NOMMOD")[1], " ") // 'Nome do M�dulo'
		aReturn[2][8] := M->TZB_ATIVO // 'Painel Ativo?' (1=Sim;2=N�o)
	EndIf

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8SavPnl
Executa o 'Save' do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 08/08/2012

@param aInfo
	Informa��es (Dados Cadastrais) do Painel * Obrigat�rio
@param aIndics
	Indicadores do Painel * Obrigat�rio

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGI8SavPnl(aInfo, aIndics) // SavePanel

	// Vari�vel do retorno
	Local lReturn := .T.

	// Vari�veis dos Dados
	Local cSvFilial := ""
	Local cSvCodPnl := ""
	Local cSvNomPnl := ""
	Local cSvCodUsr := ""
	Local cSvNomUsr := ""
	Local cSvCodMod := ""
	Local cSvNomMod := ""
	Local cSvAtvPnl := ""

	// Salva as �reas atuais
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZC := TZC->( GetArea() )

	// Vari�veis auxiliares
	Local nX := 0

	//------------------------------------------------------------
	// Salva o Painel de Indicadores
	//------------------------------------------------------------
	// Coloca o cursor do mouse em estado de espera
	CursorWait()

	// Recebe os Dados
	cSvFilial := aInfo[1] // 'Filial'
	cSvCodPnl := aInfo[2] // 'C�digo do Painel'
	cSvNomPnl := aInfo[3] // 'Nome do Painel'
	cSvCodUsr := aInfo[4] // 'C�digo do Usu�rio'
	cSvNomUsr := aInfo[5] // 'Nome do Usu�rio'
	cSvCodMod := aInfo[6] // 'M�dulo do Painel'
	cSvNomMod := aInfo[7] // 'Nome do M�dulo'
	cSvAtvPnl := aInfo[8] // 'Painel Ativo?' (1=Sim;2=N�o)

	//--------------------
	// Inicia a Transa��o
	//--------------------
	BEGIN TRANSACTION

	//--------------------
	// Grava Cabe�alho
	//--------------------
	dbSelectArea("TZB")
	dbSetOrder(1)
	If !dbSeek(cSvFilial + cSvCodPnl)
		RecLock("TZB", .T.)
		TZB->TZB_FILIAL := cSvFilial
		TZB->TZB_CODIGO := cSvCodPnl
		TZB->TZB_CODUSU := cSvCodUsr
		TZB->TZB_MODULO := cSvCodMod
	Else
		RecLock("TZB", .F.)
	EndIf
	TZB->TZB_NOME   := cSvNomPnl
	TZB->TZB_ATIVO  := cSvAtvPnl
	MsUnlock("TZB")

	//------------------------------------------------------------
	// Insere/Atualiza os registros na TZC (Indicadores do Painel)
	//------------------------------------------------------------
	// Deleta registros que n�o est�o mais relacionados ao Painel
	dbSelectArea("TZC")
	dbSetOrder(1)
	dbSeek(cSvFilial + cSvCodPnl, .T.)
	While !Eof() .And. TZC->TZC_FILIAL == cSvFilial .And. TZC->TZC_CODPNL == cSvCodPnl
		If aScan(aIndics, {|x| AllTrim(x) == AllTrim(TZC->TZC_CODIND) }) == 0
			RecLock("TZC", .F.)
			dbDelete()
			MsUnlock("TZC")
		EndIf

		dbSelectArea("TZC")
		dbSkip()
	End
	// Grava registros que devem estar relacionados ao Painel
	For nX := 1 To Len(aIndics)
		// Busca Painel de Indicadores
		dbSelectArea("TZB")
		dbSetOrder(1)
		If dbSeek(xFilial("TZB", cSvFilial) + cSvCodPnl)
			// Busca Indicador (F�rmula)
			dbSelectArea("TZ5")
			dbSetOrder(1)
			If dbSeek(xFilial("TZ5", TZB->TZB_FILIAL) + TZB->TZB_MODULO + aIndics[nX])
				dbSelectArea("TZC")
				dbSetOrder(1)
				If !dbSeek(xFilial("TZC", TZB->TZB_FILIAL) + TZB->TZB_CODIGO + TZ5->TZ5_CODIND)
					RecLock("TZC", .T.)
					TZC->TZC_FILIAL := xFilial("TZC", TZB->TZB_FILIAL)
					TZC->TZC_CODPNL := TZB->TZB_CODIGO
					TZC->TZC_CODIND := TZ5->TZ5_CODIND
					MsUnlock("TZC")
				EndIf
			EndIf
		EndIf
	Next nX

	//--------------------
	// Encerra a Transa��o
	//--------------------
	END TRANSACTION

	// Coloca o cursor do mouse em estado normal
	CursorArrow()

	// Devolve as �reas
	RestArea(aAreaTZB)
	RestArea(aAreaTZC)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8LoaPnl
Executa o 'Load' do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 09/08/2012

@param cCodPanel
	C�digo do Painel de Indicadores * Obrigat�rio
@param cCodFilia
	Filial do Painel de Indicadores * Obrigat�rio
@param cCodModul
	M�dulo do Painel de Indicadores * Obrigat�rio

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGI8LoaPnl(cCodPanel, cCodFilia, cCodModul) // LoadPanel

	// Salva as �reas atuais
	Local aAreaTZB := TZB->( GetArea() )

	// Vari�vel do retorno
	lReturn := .F.

	//------------------------------------------------------------
	// Carrega o Painel de Indicadores
	//------------------------------------------------------------
	dbSelectArea("TZB")
	dbSetOrder(1)
	lReturn := dbSeek(cCodFilia + cCodPanel)
	If !lReturn
		Help(Nil, Nil, STR0007, Nil, STR0017, 1, 0) //"Aten��o" ## "N�o foi poss�vel carregar o Painel de Indicadores porque n�o foi encontrado o seu cadastro."
	EndIf

	// Devolve as �reas
	RestArea(aAreaTZB)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8DelPnl
Executa o 'Delete' do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 09/08/2012

@param cCodPanel
	C�digo do Painel de Indicadores * Obrigat�rio
@param cCodFilia
	Filial do Painel de Indicadores * Obrigat�rio
@param cCodModul
	M�dulo do Painel de Indicadores * Obrigat�rio

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGI8DelPnl(cCodPanel, cCodFilia, cCodModul) // DelPanel

	// Salva as �reas atuais
	Local aAreaTZB := TZB->( GetArea() )
	Local aAreaTZC := TZC->( GetArea() )

	// Vari�vel do retorno
	lReturn := .F.

	//------------------------------------------------------------
	// Deleta o Painel de Indicadores
	//------------------------------------------------------------
	// Inicia a Transa��o
	BEGIN TRANSACTION

	// Deleta o Cabe�alho
	dbSelectArea("TZB")
	dbSetOrder(1)
	If dbSeek(cCodFilia + cCodPanel)
		// Deleta o registro
		RecLock("TZB", .F.)
		dbDelete()
		MsUnlock("TZB")

		lReturn := .T.
	EndIf

	// Deleta os registros relacionados
	dbSelectArea("TZC")
	dbSetOrder(1)
	dbSeek(TZB->TZB_FILIAL + TZB->TZB_CODIGO, .T.)
	While !Eof() .And. TZC->TZC_FILIAL == TZB->TZB_FILIAL .And. TZC->TZC_CODPNL == TZB->TZB_CODIGO
		RecLock("TZC", .F.)
		dbDelete()
		MsUnlock("TZC")

		lReturn := .T.

		dbSelectArea("TZC")
		dbSkip()
	End

	// Encerra a Transa��o
	END TRANSACTION

	// Devolve as �reas
	RestArea(aAreaTZB)
	RestArea(aAreaTZC)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8ConPnl
Executa a 'Consula' dos Pain�is de Indicadores cadastrados no sistema.

@author Wagner Sobral de Lacerda
@since 09/08/2012

@return aReturn
/*/
//---------------------------------------------------------------------
Function NGI8ConPnl() // Consulta Pain�is cadastrados

	// Salva as �reas atuais
	Local aAreaSX3 := SX3->( GetArea() )
	Local aAreaTZB := TZB->( GetArea() )

	// Vari�vel do Retorno
	Local aReturn := {}

	// Vari�veis da janela
	Local oDlgCon
	Local cDlgCon := OemToAnsi(STR0018) //"Consulta de Pain�is de Indicadores"
	Local lDlgCon := .F.
	Local oPnlCon

	Local oPnlLeft
	Local oPnlAll
	Local oPnlBorda
	Local oPnlBrowse

	Local aNGColor := aClone( NGCOLOR() )

	Local oPPanel
	Local cShape := "", nIDShape := 0
	Local aBotao := {}, nBotao := 0
	Local nWidth := 0, nHeight := 0
	Local nTop := 0, nHeiBtn := 0
	Local aClique := {}
	Local cClrBack := "#F8F8F8"

	Local cArrTitulo := ""
	Local cArrTipo   := ""
	Local nArrTamanh := ""
	Local nArrDecima := ""
	Local cArrPictur := ""
	Local aColunas := {}, oColuna, nHeader

	Private aArrayTZB := {}
	Private oFWBrwCon, aFWBrwCon := {}, aFWHeader := {}
	Private aSelectTZB := Array(3) // Vari�vel do registro selecionado

	Private oSayMsg

	// Verifica se pode executar
	dbSelectArea("TZB")
	If NGIND007OP()
		cReturn := Space( TAMSX3("TZB_CODIGO")[1] )

		//-- Define os bot�es
		aAdd(aBotao, {STR0019, "selectall.png", {|| fConArray(1) } }) //"Todos os Pain�is"
		aAdd(aBotao, {STR0020, "cliente.png"  , {|| fConArray(2) } }) //"Meus Pain�is"

		//--- Define o Array do Browse
		fConArray()

		//--------------------
		// Monta Janela
		//--------------------
		DEFINE MSDIALOG oDlgCon TITLE cDlgCon FROM 0,0 TO 450,750 OF GetWndDefault() PIXEL

			// Painel principal do Dialog
			oPnlCon := TPanel():New(01, 01, , oDlgCon, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlCon:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel da Mensagem
				oPnlMensag := TPanel():New(01, 01, , oPnlCon, , , , aNGColor[1], aNGColor[2], 100, 015)
				oPnlMensag:Align := CONTROL_ALIGN_TOP

					// Mensagem
					oSayMsg := TSay():New(004, 036, {|| "" }, oPnlMensag, , TFont():New(, , 18, , .T.), , ;
											, ,.T., aNGColor[1], aNGColor[2], 400, 015)

				// Painel Lateral dos Bot�es
				oPnlLeft := TPanel():New(01, 01, , oPnlCon, , , , CLR_BLACK, CLR_WHITE, 035, 100)
				oPnlLeft:Align := CONTROL_ALIGN_LEFT

					// TPaintPanel dos Bot�es
					oPPanel := TPaintPanel():New(0/*nRow*/, 0/*nCol*/, 1/*nWidth*/, 1/*nHeight*/, oPnlLeft/*oWnd*/, /*lCentered*/, /*lRight*/)
					oPPanel:Align := CONTROL_ALIGN_ALLCLIENT
					oPPanel:blClicked := {|x,y,lInit| fModelClk(oPPanel, aBotao, aClique, lInit) }

						nWidth  := oPPanel:nClientWidth
						nHeight := oPPanel:nClientHeight

						//-- Fundo
						cShape := "ID=" + cValToChar(++nIDShape) + ";Type=1;"
						cShape += "Left=" + cValToChar(0) + ";"
						cShape += "Top=" + cValToChar(0) + ";"
						cShape += "Width=" + cValToChar(nWidth) + ";"
						cShape += "Height=" + cValToChar(nHeight) + ";"
						cShape += "Gradient=1,0,0,0,0,0.0," + cClrBack + ";"
						cShape += "Pen-Width=1;Pen-Color=" + cClrBack + ";"
						cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=1;"
						// Adiciona Shape
						oPPanel:AddShape(cShape)

						//-- Bot�es
						nTop    := 2
						nHeiBtn := 045
						For nBotao := 1 To Len(aBotao)
							//-- Fundo 1
							cShape := "ID=" + cValToChar(++nIDShape) + ";Type=6;"
							cShape += "From-Left=" + cValToChar(0) + ";From-Top=" + cValToChar(nTop) + ";"
							cShape += "To-Left=" + cValToChar(nWidth) + ";To-Top=" + cValToChar(nTop) + ";"
							cShape += "Gradient=1,0,0,0,0,0.0,#B3B3B3;"
							cShape += "Pen-Width=1;Pen-Color=#B3B3B3;"
							cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=0;"
							// Adiciona Shape
							oPPanel:AddShape(cShape)
							//-- Fundo 2
							cShape := "ID=" + cValToChar(++nIDShape) + ";Type=6;"
							cShape += "From-Left=" + cValToChar(0) + ";From-Top=" + cValToChar(nTop+nHeiBtn) + ";"
							cShape += "To-Left=" + cValToChar(nWidth) + ";To-Top=" + cValToChar(nTop+nHeiBtn) + ";"
							cShape += "Gradient=1,0,0,0,0,0.0,#B3B3B3;"
							cShape += "Pen-Width=1;Pen-Color=#B3B3B3;"
							cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=0;"
							// Adiciona Shape
							oPPanel:AddShape(cShape)
							//-- Fundo 3
							cShape := "ID=" + cValToChar(++nIDShape) + ";Type=1;"
							cShape += "Left=" + cValToChar(0) + ";"
							cShape += "Top=" + cValToChar(nTop) + ";"
							cShape += "Width=" + cValToChar(nWidth) + ";"
							cShape += "Height=" + cValToChar(nHeiBtn) + ";"
							cShape += "Gradient=1,0,0,0,0,0.0,#F2F2F2;"
							cShape += "Pen-Width=0;"
							cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
							cShape += "Can-Move=0;Can-Deform=0;Can-Mark=1;Is-Container=0;"
							// Adiciona Shape
							oPPanel:AddShape(cShape)
							aAdd(aClique, {nIDShape, nBotao, "EXECUTE"})
							//-- Container
							cShape := "ID=" + cValToChar(++nIDShape) + ";Type=1;"
							cShape += "Left=" + cValToChar(0) + ";"
							cShape += "Top=" + cValToChar(nTop) + ";"
							cShape += "Width=" + cValToChar(nWidth) + ";"
							cShape += "Height=" + cValToChar(nHeiBtn) + ";"
							cShape += "Gradient=1,0,0,0,0,0.0,#EBEBEB;"
							cShape += "Pen-Width=1;Pen-Color=#B3B3B3;"
							cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
							cShape += "Can-Move=0;Can-Deform=0;Can-Mark=1;Is-Container=0;"
							// Adiciona Shape
							oPPanel:AddShape(cShape)
							aAdd(aClique, {nIDShape, nBotao, "CONTAINER"})
							//-- Bot�o
							cShape := "ID=" + cValToChar(++nIDShape) + ";Type=8;"
							cShape += "Left=" + cValToChar((nWidth/2)-12) + ";"
							cShape += "Top=" + cValToChar(nTop+(nHeiBtn/2)-12) + ";"
							cShape += "Width=25;"
							cShape += "Height=25;"
							cShape += "Image-File=rpo:" + aBotao[nBotao][2] + ";"
							cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
							cShape += "Can-Move=0;Can-Deform=0;Can-Mark=1;Is-Container=0;"
							// Adiciona Shape
							oPPanel:AddShape(cShape)
							aAdd(aClique, {nIDShape, nBotao, "EXECUTE"})
								//-- Indica��o
								cShape := "ID=" + cValToChar(++nIDShape) + ";Type=5;"
								cShape += "Polygon=" + ; // Left:Top, Left:Top, Left:Top
													cValToChar(nWidth)+":"+cValToChar(nTop) + "," + ;
													cValToChar(nWidth)+":"+cValToChar(nTop+nHeiBtn) + "," + ;
													cValToChar(nWidth-012)+":"+cValToChar(nTop+(nHeiBtn/2)) + ";"
								cShape += "Gradient=1,0,0,0,0,0.0,#FFFFFF;"
								cShape += "Pen-Width=1;Pen-Color=#FFFFFF;"
								cShape += "Tooltip=" + aBotao[nBotao][1] + ";"
								cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=0;"
								// Adiciona Shape
								oPPanel:AddShape(cShape)
								aAdd(aClique, {nIDShape, nBotao, "INDICACAO"})

							nTop += ( nHeiBtn + 005 )
						Next nBotao

				// Painel TODO
				oPnlAll := TPanel():New(01, 01, , oPnlCon, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

					// Bordas
					oPnlBorda := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 002, 002)
					oPnlBorda:Align := CONTROL_ALIGN_TOP
					oPnlBorda := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 002, 002)
					oPnlBorda:Align := CONTROL_ALIGN_LEFT
					oPnlBorda := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 002, 002)
					oPnlBorda:Align := CONTROL_ALIGN_RIGHT
					oPnlBorda := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 002, 002)
					oPnlBorda:Align := CONTROL_ALIGN_BOTTOM

					// Painel do Browse
					oPnlBrowse := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 100)
					oPnlBrowse:Align := CONTROL_ALIGN_ALLCLIENT

						//----------
						// Browse
						//----------
						oFWBrwCon := FWBrowse():New()
						oFWBrwCon:SetOwner(oPnlBrowse)
						oFWBrwCon:SetDataArray()

						oFWBrwCon:SetLocate()
						oFWBrwCon:SetDelete(.F., {|| .F.})
						oFWBrwCon:SetSeek({|oSeek, oBrowse| fConSeek(oSeek, oBrowse) }, { {"TZB_CODIGO"}, {"TZB_NOME"} })
						oFWBrwCon:DisableConfig()

						// Colunas
						oFWBrwCon:SetDoubleClick({|| lDlgCon := .T., oDlgCon:End() })

						aColunas := {}
						For nHeader := 1 To Len(aFWHeader)
							cArrTitulo := aFWHeader[nHeader][1]
							cArrTipo   := aFWHeader[nHeader][3]
							nArrTamanh := aFWHeader[nHeader][4]
							nArrDecima := aFWHeader[nHeader][5]
							cArrPictur := aFWHeader[nHeader][6]

							oColuna := FWBrwColumn():New()
							oColuna:SetAlign( If(cArrTipo == "N", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT) )

							cSetData := "{|| aFWBrwCon[oFWBrwCon:AT()][" + cValToChar(nHeader) + "] }"
							oColuna:SetData( &(cSetData) )

							oColuna:SetEdit( .F. )
							oColuna:SetSize( nArrTamanh + nArrDecima )
							oColuna:SetTitle( cArrTitulo )
							oColuna:SetType( cArrTipo )
							oColuna:SetPicture( cArrPictur )

							aAdd(aColunas, oColuna)
						Next nHeader
						oFWBrwCon:SetColumns(aColunas)
						oFWBrwCon:Activate()
						oFWBrwCon:SetChange({|| fConChange() })
						oFWBrwCon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

			// Inicializa os Cliques do TPaintPanel
			Eval(oPPanel:blClicked, 0, 0, .T.)

			// Inicializa o bChange do Browse
			Eval(oFWBrwCon:bChange)

		ACTIVATE MSDIALOG oDlgCon ON INIT EnchoiceBar(oDlgCon, {|| lDlgCon := .T., oDlgCon:End() }, {|| lDlgCon := .F., oDlgCon:End() }) CENTERED

		// Se confirmou
		If lDlgCon
			aReturn := aClone(aSelectTZB)
		EndIf
	EndIf

	// Devolve as �reas
	RestArea(aAreaSX3)
	RestArea(aAreaTZB)

Return aReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fModelClk
Clique do TPaintPanel do Modelo de Impress�o.

@author Wagner Sobral de Lacerda
@since 06/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fModelClk(oPPanel, aBotao, aClique, lInit)

	// Vari�veis auxiliares
	Local nShapeAtu := oPPanel:ShapeAtu
	Local nBotao := 0
	Local nX := 0, nScan := 0

	Local nExecute := 0

	// Defaults
	Default lInit := .F.

	// Busca o Bot�o
	If lInit
		nBotao := 1
	Else
		nScan := aScan(aClique, {|x| x[1] == nShapeAtu })
		nBotao := If(nScan > 0, aClique[nScan][2], 0)
	EndIf

	// Percorre todos os cliques poss�veis
	For nX := 1 To Len(aClique)
		If aClique[nX][2] == nBotao
			If aClique[nX][3] == "INDICACAO"
				oPPanel:SetVisible(aClique[nX][1], .T.)
			ElseIf aClique[nX][3] == "EXECUTE"
				nExecute := nBotao
			ElseIf aClique[nX][3] == "CONTAINER"
				oPPanel:SetVisible(aClique[nX][1], .T.)
			EndIf
		Else
			If aClique[nX][3] == "INDICACAO"
				oPPanel:SetVisible(aClique[nX][1], .F.)
			ElseIf aClique[nX][3] == "CONTAINER"
				oPPanel:SetVisible(aClique[nX][1], .F.)
			EndIf
		EndIf
	Next nX

	// Executa a a��o do Bot�o
	If nExecute > 0
		Eval(aBotao[nExecute][3])
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConArray
Fun��o o Array do Browse montado na consulta, com os Pain�is de Indicadores.

@author Wagner Sobral de Lacerda
@since 14/06/2012

@param nType
	Indica como o Array deve ser montado * Opcional
	   1 - Array com todos os pain�is
	   2 - Array somente com os pain�is do usu�rio logado
	Default: 1

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConArray(nType)

	// Vari�veis de Controle
	Local lAddHeader := .T.
	Local nLen       := 0
	Local nHeader    := 0
	Local nX         := 0
	Local nTamTot    := 0
	Local nInd       := 0
	Local aNgHeader	 := {}
	Local cCodUser   := ""
	Local lHasAcesss := .F.
	Local lIsAdmin   := .F.
	Local aGroups    := {}
	Local cAliasB    := ""
	Local nGroups    := 0

	// Limpa o Array do Browse
	aFWBrwCon := {}

	// Defaults
	Default nType := 1

	// Cursor Em Espera
	CursorWait()

	//--------------------
	// Monta o Header
	//--------------------
	If Len(aFWHeader) == 0

		aNgHeader := NGHeader("TZB")
		nTamTot := Len(aNgHeader)
		For nInd := 1 To nTamTot

			lAddHeader :=	( X3Uso(aNgHeader[nInd,7]) .And. AllTrim(Posicione("SX3",2,aNgHeader[nInd,2],"X3_BROWSE")) == "S" ) .Or. ( "_FILIAL" $ aNgHeader[nInd,2])

			If lAddHeader
				aAdd(aFWHeader, {	AllTrim(aNgHeader[nInd,1]) ,; // 1 - T�tulo
									AllTrim(aNgHeader[nInd,2]) ,; // 2 - Campo
									AllTrim(aNgHeader[nInd,8]) ,; // 3 - Tipo
									aNgHeader[nInd,4] ,; // 4 - Tamanho
									aNgHeader[nInd,5] ,; // 5 - Decimal
									AllTrim(aNgHeader[nInd,3]) ,; // 6 - Picture
									AllTrim(aNgHeader[nInd,10]) == "V",; // 7 - Virtual?
									AllTrim(Posicione("SX3",2,aNgHeader[nInd,2],"X3_INIBRW"))}) // 8 - Inicializador do Browse
			EndIf
		Next nInd

	EndIf

	//------------------------------
	// Monta os Arrays da TZB
	//------------------------------
	If Len(aArrayTZB) == 0
		cCodUser := RetCodUsr()
		lIsAdmin := FWIsAdmin( cCodUser ) // se usu�rio � do grupo admin ( tem todas as permiss�es )
		aGroups  := FWSFUsrGrps( cCodUser ) //retorna os grupos do usu�rio

		aArrayTZB := { {}, {} }
		// Carrega os Arrays

		cAliasB := GetNextAlias()

		BeginSQL Alias cAliasB
			SELECT *
			FROM %table:TZB% TZB
			WHERE TZB.TZB_FILIAL = %xFilial:TZB%
				AND TZB.%NotDel%
				AND TZB.TZB_MODULO = %Exp:Str( nModulo, 2 )%
				AND TZB.TZB_ATIVO = '1'
		EndSql

		While !((cAliasB)->( Eof() ))

			lHasAcesss := lIsAdmin .Or. NGIND012AC( (cAliasB)->TZB_FILIAL, (cAliasB)->TZB_CODIGO, "1", cCodUser )

			If !lHasAcesss

				For nGroups := 1 to Len( aGroups )
					//Verifica permiss�o dos grupos do usu�rio
					lHasAcesss := NGIND012AC( (cAliasB)->TZB_FILIAL, (cAliasB)->TZB_CODIGO, "2", aGroups[ nGroups ] )
					If lHasAcesss
						Exit
					EndIf
				Next nGroups

			EndIf

			If lHasAcesss
				For nX := 1 To 2
					If nX == 2 .And. (cAliasB)->TZB_CODUSU <> cCodUser
						Loop
					EndIf
					aAdd(aArrayTZB[nX], Array(Len(aFWHeader)))
					nLen := Len(aArrayTZB[nX])

					For nHeader := 1 To Len(aFWHeader)
						If aFWHeader[nHeader][7]
							aArrayTZB[nX][nLen][nHeader] := &(aFWHeader[nHeader][8])
						Else
							aArrayTZB[nX][nLen][nHeader] := &( cAliasB + "->" + aFWHeader[nHeader][2] )
						EndIf
					Next nHeader
				Next nX
			EndIf

			(cAliasB)->( dbSkip() )
		EndDo

		(cAliasB)->( dbCloseArea() )

		// Define conte�do em branco caso n�o haja registros
		For nX := 1 To 2
			If Len(aArrayTZB[nX]) > 0
				Loop
			EndIf
			aAdd(aArrayTZB[nX], Array(Len(aFWHeader)))
			nLen := Len(aArrayTZB[nX])

			For nHeader := 1 To Len(aFWHeader)
				Do Case
					Case aFWHeader[nHeader][3] == "C"
						aArrayTZB[nX][nLen][nHeader] := Space(aFWHeader[nHeader][4])
					Case aFWHeader[nHeader][3] == "D"
						aArrayTZB[nX][nLen][nHeader] := CTOD("")
					Case aFWHeader[nHeader][3] == "N"
						aArrayTZB[nX][nLen][nHeader] := 0
				EndCase
			Next nHeader
		Next nX
	EndIf

	//------------------------------
	// Monta o Array do Browse
	//------------------------------
	aFWBrwCon := aClone( aArrayTZB[nType] )
	If ValType(oFWBrwCon) == "O"
		oFWBrwCon:SetArray(aFWBrwCon)
		oFWBrwCon:GoTop()
		oFWBrwCon:Refresh()
		oFWBrwCon:SetFocus()
	EndIf

	// Define a Mensagem
	If ValType(oSayMsg) == "O"
		If nType == 1
			oSayMsg:SetText(STR0019) //"Todos os Pain�is"
		Else
			oSayMsg:SetText(STR0020) //"Meus Pain�is"
		EndIf
		oSayMsg:CtrlRefresh()
	EndIf

	// Cursor Normal
	CursorArrow()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConSeek
Fun��o de Busca do browse da Consulta.

@author Wagner Sobral de Lacerda
@since 14/06/2012

@return nReturn
/*/
//---------------------------------------------------------------------
Static Function fConSeek(oSeek, oBrowse)

	// Vari�veis da Busca
	Local aArray  := aClone( oBrowse:Data():GetArray() )
	Local cOrder  := oSeek:cOrder
	Local cSeek   := oSeek:cSeek
	Local nHeader := aScan(aFWHeader, {|x| Upper(AllTrim(x[2])) == Upper(AllTrim(cOrder)) })
	Local nScan   := 0

	// Vari�vel do retorno
	Local nReturn := oBrowse:AT() // Caso n�o encontre a busca, retornar� para o registro posicionado atualmente

	// Busca no Browse pelo 'Seek'
	If nHeader > 0
		nScan := aScan(aArray, {|x| Upper(AllTrim(cSeek)) $ Upper(AllTrim(x[nHeader])) })
		If nScan > 0
			nReturn := nScan
		EndIf
	EndIf

Return nReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fConChange
Fun��o do Change do browse da Consulta.

@author Wagner Sobral de Lacerda
@since 14/06/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConChange()

	// Vari�veis de Controle
	Local nPosCODIGO := 0
	Local nPosFILIAL := 0
	Local nPosMODULO := 0

	Local nATBrw := oFWBrwCon:AT()

	// Busca as posi��es do Aray
	nPosCODIGO := aScan(aFWHeader, {|x| Upper(AllTrim(x[2])) == "TZB_CODIGO" })
	nPosFILIAL := aScan(aFWHeader, {|x| Upper(AllTrim(x[2])) == "TZB_FILIAL" })
	nPosMODULO := aScan(aFWHeader, {|x| Upper(AllTrim(x[2])) == "TZB_MODULO" })

	// Atribui os dados
	If nPosCODIGO > 0
		aSelectTZB[1] := aFWBrwCon[nATBrw][nPosCODIGO] // C�digo do Painel
	EndIf
	If nPosFILIAL > 0
		aSelectTZB[2] := aFWBrwCon[nATBrw][nPosFILIAL] // Filial do Painel
	EndIf
	If nPosMODULO > 0
		aSelectTZB[3] := aFWBrwCon[nATBrw][nPosMODULO] // M�dulo do Painel
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8EndPnl
Executa uma personaliza��o quando o Painel de Indicadores est� criado.

@author Wagner Sobral de Lacerda
@since 05/12/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGI8EndPnl(oTNGPnl, lCreated)

	If IsInCallStack("NGIND008")
		If lCreated
			// Atualiza a View indicando que est� Modificada
			fViewModif()
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8FldInf
Executa a 'FieldsInfo' do Painel de Indicadores.
* Define as especifica��es dos campos do array 'aInfo', propriedade
da classe TNGPanel.

@author Wagner Sobral de Lacerda
@since 09/08/2012

@return aFieldInfo
/*/
//---------------------------------------------------------------------
Function NGI8FldInf() // FldInfo

	// Salva as �reas atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Vari�vel do Retorno
	Local aFieldInfo := {}

	// Vari�veis dos campos para buscar
	Local aCposX3 := {}
	Local nCpo := 0

	// Vari�veis auxiliares
	Local cIDCampo   := ""

	//-- Define os campos
	aAdd(aCposX3, "TZB_FILIAL") // Posi��o '__nInfFili'
	aAdd(aCposX3, "TZB_CODIGO") // Posi��o '__nInfCodi'
	aAdd(aCposX3, "TZB_NOME"  ) // Posi��o '__nInfNome'
	aAdd(aCposX3, "TZB_CODUSU") // Posi��o '__nInfUsCd'
	aAdd(aCposX3, "TZB_NOMUSU") // Posi��o '__nInfUsNo'
	aAdd(aCposX3, "TZB_MODULO") // Posi��o '__nInfMdCd'
	aAdd(aCposX3, "TZB_NOMMOD") // Posi��o '__nInfMdNo'
	aAdd(aCposX3, "TZB_ATIVO" ) // Posi��o '__nInfAtiv'

	//----------------------------------------
	// Define os Tamanhos e Decimais
	//----------------------------------------
	For nCpo := 1 To Len(aCposX3)
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(aCposX3[nCpo])

		cIDCampo  := aCposX3[nCpo]
		cAuxSoluc := AllTrim( StrTran(GetHlpSoluc(cIDCampo)[1],CRLF," ") )

		// Adiciona no array
		aAdd(aFieldInfo, {	AllTrim(X3Titulo())     , ; // [1] - T�tulo
							Posicione("SX3",2,aCposX3[nCpo],"X3_TIPO")            , ; // [2] - Tipo
							Posicione("SX3",2,aCposX3[nCpo],"X3_TAMANHO")         , ; // [3] - Tamanho
							Posicione("SX3",2,aCposX3[nCpo],"X3_DECIMAL")         , ; // [4] - Decimal
							AllTrim(Posicione("SX3",2,aCposX3[nCpo],"X3_PICTURE")), ; // [5] - Picture
							AllTrim(X3CBox())       							  , ; // [6] - ComboBox
							X3Obrigat(cIDCampo)                                   , ; // [7] - Obrigat�rio?
							cIDCampo                                              , ; // [8] - ID do Campo
							cAuxSoluc                                             }) // [9] - Help
	Next nCpo

	// Devolve as �reas
	RestArea(aAreaSX3)

Return aFieldInfo

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8Custom
Salva ou Carrega as configura��es (customiza��es) do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 06/09/2012

@param aCustom
	Array com as configura��es (customiza��es) do Painel * Obrigat�rio
@param nOPtion
	Indica se a fun��o deve: * Obrigat�rio
	  1 - Salvar as configura��es
	  2 - Carregas as configura��es da Base

@return uReturn
/*/
//---------------------------------------------------------------------
Function NGI8Custom(aCustom, nOption) // Customization

	// Vari�vel do Retorno
	Local uReturn := Nil

	// Vari�veis das Posi��es da Customiza��o
	Local nCodUsuari := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEUSER"  })
	Local nCodPainel := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEPANEL" })
	Local nCodFuncao := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEFUNC"  })
	Local nCodFilial := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEBRANCH"})
	//Local nCodModulo := aScan(aCustom, {|x| AllTrim(x[1]) == "CODEMODULE"}) // N�o utilizado
	Local nAllIndics := aScan(aCustom, {|x| AllTrim(x[1]) == "INDICATORS"})
	Local nAllParams := aScan(aCustom, {|x| AllTrim(x[1]) == "PARAMETERS"})
	Local nAllCustom := aScan(aCustom, {|x| AllTrim(x[1]) == "CUSTOM"    })

	// Vari�veis da estrutura da Tabela na Base
	Local aGravaTZD := {}
	Local lSeekTZD := .F.
	Local aArrays := {}, aAuxGrv := {}
	Local nX := 0, nY := 0, nAuxGrv := 0, nLenGrv := 0
	Local nScnCFGTIP := 0, nScnCFGAX1 := 0

	Local cTipoCfg := ""
	Local cCfgAux1 := ""
	Local cCfgData := ""
	Local cCfgResp := ""

	Local cSeekFil := "", nSeekFil := TAMSX3("TZD_FILIAL")[1]
	Local cSeekUsr := "", nSeekUsr := TAMSX3("TZD_CODUSR")[1]
	Local cSeekPnl := "", nSeekPnl := TAMSX3("TZD_CODPNL")[1]
	Local cSeekFun := "", nSeekFun := TAMSX3("TZD_FUNPAI")[1]
	Local cSeekTip := "", nSeekTip := TAMSX3("TZD_CFGTIP")[1]
	Local cSeekAx1 := "", nSeekAx1 := TAMSX3("TZD_CFGAX1")[1]

	// Vari�veis da Query
	Local cQryAlias := ""
	Local cQryDados := ""

	Local nScanCustom := 0

	// Defaults
	Default nOption := 0

	If nOption == 1
		//----------
		// Salva
		//----------
		// Define as Grava��es que ser�o efetuadas na Tabela
		aGravaTZD := {}

		// Array com as posi��es dos outros arrays que ser�o gravados
		aArrays := {nAllIndics, nAllParams, nAllCustom}
		// Percorre todos eles (arrasy acima)
		For nX := 1 To Len(aArrays)
			nAuxGrv := aArrays[nX]

			// Percorre o Array a ser gravado
			For nY := 1 To Len(aCustom[nAuxGrv][2])
				// "Cria" um novo registro
				aAdd(aGravaTZD, {})
				nLenGrv := Len(aGravaTZD)

				// "Define" as colunas
				cTipoCfg := aCustom[nAuxGrv][1]
				cCfgAux1 := aCustom[nAuxGrv][2][nY][1]
				cCfgData := aCustom[nAuxGrv][2][nY][3]
				cCfgResp := aCustom[nAuxGrv][2][nY][2]
					// Converta o Tipo de Dado para o formato de grava��o, o qual � em Caractere
					If cCfgData == "D"
						cCfgResp := DTOS(cCfgResp)
					ElseIf cCfgData == "L"
						cCfgResp := If(cCfgResp, "1", "0")
					ElseIf cCfgData == "N"
						cCfgResp := cValToChar(cCfgResp)
					EndIf

				aAdd(aGravaTZD[nLenGrv], {"TZD_CFGTIP", cTipoCfg})
				aAdd(aGravaTZD[nLenGrv], {"TZD_CFGAX1", cCfgAux1})
				aAdd(aGravaTZD[nLenGrv], {"TZD_CFGDAT", cCfgData})
				aAdd(aGravaTZD[nLenGrv], {"TZD_CFGRES", cCfgResp})
			Next nY
		Next nX

		//----------------------------------------
		// Grava na Tabela
		//----------------------------------------
		For nX := 1 To Len(aGravaTZD)
			// Recebe as colunas
			aAuxGrv := aClone( aGravaTZD[nX] )
			nScnCFGTIP := aScan(aAuxGrv, {|x| x[1] == "TZD_CFGTIP" })
			nScnCFGAX1 := aScan(aAuxGrv, {|x| x[1] == "TZD_CFGAX1" })

			// Procura o Registro
			cSeekFil := PADR(aCustom[nCodFilial][2], nSeekFil, " ")
			cSeekUsr := PADR(aCustom[nCodUsuari][2], nSeekUsr, " ")
			cSeekPnl := PADR(aCustom[nCodPainel][2], nSeekPnl, " ")
			cSeekFun := PADR(aCustom[nCodFuncao][2], nSeekFun, " ")
			cSeekTip := PADR(aAuxGrv[nScnCFGTIP][2], nSeekTip, " ")
			cSeekAx1 := PADR(aAuxGrv[nScnCFGAX1][2], nSeekAx1, " ")

			dbSelectArea("TZD")
			dbSetOrder(1)
			lSeekTZD := dbSeek(cSeekFil + cSeekUsr + cSeekPnl + cSeekFun + cSeekTip + cSeekAx1)

			// Inicia a Transa��o
			BEGIN TRANSACTION
			// Trava ou Cria o Registro
			RecLock("TZD", !lSeekTZD)

			// Grava as Colunas
			TZD->TZD_FILIAL := aCustom[nCodFilial][2]
			TZD->TZD_CODUSR := aCustom[nCodUsuari][2]
			TZD->TZD_CODPNL := aCustom[nCodPainel][2]
			TZD->TZD_FUNPAI := aCustom[nCodFuncao][2]
			For nAuxGrv := 1 To Len(aAuxGrv)
				&("TZD->"+aAuxGrv[nAuxGrv][1]) := aAuxGrv[nAuxGrv][2]
			Next nAuxGrv

			// Confirma/Libera o Registro
			MsUnlock("TZD")
			// Encerra a Transa��o
			END TRANSACTION
		Next nX

		//-- Define o Retorno
		uReturn := .T.
	ElseIf nOption == 2
		//----------
		// Carrega
		//----------
		// Recebe o Alias tempor�rio
		cQryAlias := GetNextAlias()

		//----------------------------------------
		// Busca as Configura��es da Base
		//----------------------------------------
		// SELECT
		cQryDados := "SELECT TZD.*, TZB.TZB_MODULO "
		// FROM 'TZD'
		cQryDados += "FROM " + RetSQLName("TZD") + " TZD "
		// INNER JOIN 'TZB'
		cQryDados += "INNER JOIN " + RetSQLName("TZB") + " TZB ON ( "
		cQryDados += " TZB.TZB_CODIGO = TZD.TZD_CODPNL "
		cQryDados += " AND TZB.D_E_L_E_T_ <> '*' ) "
		// WHERE
		cQryDados += "WHERE "
		cQryDados += " TZD.TZD_FILIAL  = " + ValToSQL( aCustom[nCodFilial][2] ) + " "
		cQryDados += " AND TZD.TZD_CODUSR  = " + ValToSQL( aCustom[nCodUsuari][2] ) + " "
		cQryDados += " AND TZD.TZD_CODPNL  = " + ValToSQL( aCustom[nCodPainel][2] ) + " "
		cQryDados += " AND TZD.TZD_FUNPAI  = " + ValToSQL( aCustom[nCodFuncao][2] ) + " "
		cQryDados += " AND TZD.D_E_L_E_T_ <> '*' "
		// ORDER BY
		cQryDados += "ORDER BY "
		cQryDados += " TZD.TZD_FILIAL, "
		cQryDados += " TZD.TZD_CODUSR, "
		cQryDados += " TZD.TZD_CODPNL, "
		cQryDados += " TZD.TZD_FUNPAI, "
		cQryDados += " TZD.TZD_CFGTIP, "
		cQryDados += " TZD.TZD_CFGAX1 "

		// Executa a Query
		cQryDados := ChangeQuery(cQryDados)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDados), cQryAlias, .F., .T.)

		//--------------------------------------------------
		// Repassa as Configura��es da Base para o Array
		//--------------------------------------------------
		dbSelectArea(cQryAlias)
		While !Eof()
			nAuxGrv := 0
			nScanCustom := 0

			// Posi��o da configura��o a carregar
			If AllTrim((cQryAlias)->TZD_CFGTIP) == "INDICATORS"
				nAuxGrv := nAllIndics
			ElseIf AllTrim((cQryAlias)->TZD_CFGTIP) == "PARAMETERS"
				nAuxGrv := nAllParams
			ElseIf AllTrim((cQryAlias)->TZD_CFGTIP) == "CUSTOM"
				nAuxGrv := nAllCustom
			EndIf
			If nAuxGrv > 0
				// Busca qual a configura��o a atualizar
				nScanCustom := aScan(aCustom[nAuxGrv][2], {|x| AllTrim(x[1]) == AllTrim((cQryAlias)->TZD_CFGAX1) })
			EndIf
			If nScanCustom > 0
				cCfgData := (cQryAlias)->TZD_CFGDAT
				cCfgResp := (cQryAlias)->TZD_CFGRES
					// Converta o Tipo de Dado para o formato de carregamentoo, o qual depende do tipo de dados salvo na base
					If cCfgData == "D"
						cCfgResp := STOD(cCfgResp)
					ElseIf cCfgData == "L"
						cCfgResp := ( cCfgResp == "1" )
					ElseIf cCfgData == "N"
						cCfgResp := Val(cCfgResp)
					Else
						cCfgResp := AllTrim(cCfgResp)
					EndIf
				aCustom[nAuxGrv][2][nScanCustom][2] := cCfgResp
			EndIf

			dbSelectArea(cQryAlias)
			dbSkip()
		End
		dbCloseArea()

		//-- Define o Retorno
		uReturn := aClone( aCustom )
	ElseIf nOption == 3
		//----------
		// Deleta
		//----------
		// Procura o Registro
		cSeekFil := PADR(aCustom[nCodFilial][2], nSeekFil, " ")
		cSeekUsr := PADR(aCustom[nCodUsuari][2], nSeekUsr, " ")
		cSeekPnl := PADR(aCustom[nCodPainel][2], nSeekPnl, " ")
		cSeekFun := PADR(aCustom[nCodFuncao][2], nSeekFun, " ")

		dbSelectArea("TZD")
		dbSetOrder(1)
		dbSeek(cSeekFil + cSeekUsr + cSeekPnl + cSeekFun, .T.)
		While !Eof() .And. TZD->TZD_FILIAL == cSeekFil .And. TZD->TZD_CODUSR == cSeekUsr .And. TZD->TZD_CODPNL == cSeekPnl .And. TZD->TZD_FUNPAI == cSeekFun
			RecLock("TZD", .F.)
			dbDelete()
			MsUnlock()
			dbSelectArea("TZD")
			dbSkip()
		End
		uReturn := .T.
	EndIf

Return uReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI8Activa
Ativa��o do Painel de Indicadores.

@author Wagner Sobral de Lacerda
@since 15/10/2012

@return aActivate
/*/
//---------------------------------------------------------------------
Function NGI8Activa(nMode)

	// Vari�vel do Retorno
	Local aActivate := {}

	// Vari�veis do Usu�rio e da Rotina atual
	Local cCodUser := RetCodUsr()
	Local cCodFunc := FunName()

	// Vari�vel do Painel para Carregar
	Local cLoadFilia := ""
	Local cLoadPanel := ""

	// Vari�veis da Query
	Local cQryAlias := ""
	Local cQryExec  := ""

	// Se for em Modo de Consulta
	If nMode == 1
		//----------------------------------------
		// Busca Painel de Indicadores
		//----------------------------------------
		//-- Tabela Tempor�ria
		cQryAlias := GetNextAlias()

		//-- Query
		// SELECT
		cQryExec := "SELECT TZD.TZD_FILIAL, TZD.TZD_CODUSR, TZD.TZD_FUNPAI, TZD.TZD_CODPNL "
		// FROM "TZD"
		cQryExec += "FROM " + RetSQLName("TZD") + " TZD "
		// INNER JOIN "TZB"
		cQryExec += "INNER JOIN " + RetSQLName("TZB") + " TZB ON ( "
		cQryExec += " TZB.TZB_FILIAL = TZD.TZD_FILIAL AND TZB.TZB_CODIGO = TZD.TZD_CODPNL AND TZB.D_E_L_E_T_ <> '*' "
		cQryExec += ") "
		// WHERE
		cQryExec += "WHERE TZD.TZD_CODUSR = " + ValToSQL(cCodUser) + " AND TZD.TZD_FUNPAI = " + ValToSQL(cCodFunc) + " AND TZD.D_E_L_E_T_ <> '*' "

		// Executa a Query
		cQryExec := ChangeQuery(cQryExec)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExec), cQryAlias, .F., .T.)

		// Recebe o Painel de Indicadores
		dbSelectArea(cQryAlias)
		dbGoTop()
		If !Eof()
			cLoadFilia := (cQryAlias)->TZD_FILIAL
			cLoadPanel := (cQryAlias)->TZD_CODPNL
		EndIf
		dbCloseArea()

		If !Empty(cLoadPanel)
			// 1      ; 2                ; 3       ; 4
			// Filial ; C�digo do Painel ; Usu�rio ; Fun��o Pai
			aActivate := {cLoadFilia, cLoadPanel, cCodUser, cCodFunc}
		EndIf
	EndIf

Return aActivate
