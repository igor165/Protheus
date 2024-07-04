#INCLUDE	"Protheus.ch"
#INCLUDE	"NGIND007.ch"
#INCLUDE	"FWBrowse.ch"
#INCLUDE	"FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007
Cadastro/Configura��o de Indicadores Gr�ficos.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007()

	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local lExecute := .T. // Vari�vel para identificar se pode ou n�o executar esta rotina
	Local oBrowse // Vari�vel do Browse

	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	lExecute := NGIND007OP()

	If lExecute
		// Declara as Vari�veis PRIVATE
		NGIND007VR()

		//----------------
		// Monta o Browse
		//----------------
		dbSelectArea("TZ9")
		dbSetOrder(1)
		dbGoTop()

		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()

			// Defini��o da tabela do Browse
			oBrowse:SetAlias("TZ9")

			// Defini��o da Legenda
			NGIND007LG(@oBrowse)

			// Defini��o do Filtro
			NGIND007FL(@oBrowse)

			// Descri��o do Browse
			oBrowse:SetDescription(cCadastro)

			// Menu Funcional relacionado ao Browse
			oBrowse:SetMenuDef("NGIND007")

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
@since 24/01/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	// Vari�vel do Menu
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.NGIND007" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.NGIND007" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.NGIND007" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.NGIND007" OPERATION 5 ACCESS 0 //"Excluir"
	//ADD OPTION aRotina TITLE "Imprimir"   ACTION "VIEWDEF.NGIND007" OPERATION 8 ACCESS 0 //Podemos permitir imprimir, num futuro pr�ximo

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007OP
Valida o programa, verificando se � poss�vel execut�-lo. (NGIND007Open)
* Est� fun��o pode ser utilizada por outras rotinas.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return lReturn .T. caso o programa possa ser executado; .F. no caso de uma falha e o programa n�o puder ser executado
/*/
//---------------------------------------------------------------------
Function NGIND007OP()

	// Vari�vel que armazena as tabelas para valida��o
	Local aTables := {"TZ1", "TZ2", "TZ3", "TZ4", "TZ5", "TZ6", "TZ7", "TZ9", "TZA", "TZB", "TZC", "TZD", "TZE", "TZF", "TZG", "TZH"}
	Local nTbl := 0

	// Vari�vel private para o fun��o 'FWAliasInDic()' mostrar (.T.) ou n�o (.F.) uma mensagem de Help caso a tabela n�o exista
	Private lHelp := .F.

	// Verifica se o Ambiente possui a atualiza��o dos Indicadores Gr�ficos
	For nTbl := 1 To Len(aTables)
		If !FWAliasInDic(aTables[nTbl])
			NGINCOMPDIC("UPDIND02", "SEM BOLETIM", .F.)
			Return .F.
		EndIf
	Next nTbl

	// Verifica se o compartilhamento dessas tabelas est�o iguais.
	If !NGCHKCOMP(aTables, .T.)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCposExcep
Monta o Array com a excecao de campos para o Modelo/View.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCposExcep()

	// Salva as �res atuais
	Local nTamTot 	:= 0
	Local nInd    	:= 0
	Local aNgHeader	:= {}

	dbSelectArea("SX3")
	dbSetOrder(2)

	//Exce��o de campos na View da tabela TZ9
	aVCpoTZ9 := {}

	aAdd(aVCpoTZ9, "TZ9_CODDES")

	aAdd(aVCpoTZ9, "TZ9_MODELO")
	aAdd(aVCpoTZ9, "TZ9_TIPCON")

	aAdd(aVCpoTZ9, "TZ9_SECMIN")
	aAdd(aVCpoTZ9, "TZ9_SECMAX")

	//Buscar os campos das tabela.
	aNgHeader := NGHeader("TZ9",,.F.)
	nTamTot := Len(aNgHeader)
	For nInd := 1 To nTamTot
		If "TZ9_VAL" $ AllTrim(aNgHeader[nInd,2]) .Or. "TZ9_LEG" $ AllTrim(aNgHeader[nInd,2]) .Or.;
			"TZ9_SOMB" $ AllTrim(aNgHeader[nInd,2]) .Or. "TZ9_COR" $ AllTrim(aNgHeader[nInd,2])
			aAdd(aVCpoTZ9, AllTrim(aNgHeader[nInd,2]))
		EndIf
	Next nInd

	//Exce��o de campos na View da tabela TZA
	aVCpoTZA := {}

	aAdd(aVCpoTZA, "TZA_CODGRA")

Return .T.

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
@since 24/01/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTZ9 := FWFormStruct(1, "TZ9", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZA := FWFormStruct(1, "TZA", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de dados que ser� constru�do
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("NGIND007", /*bPreValid*/, {|oModel| fMPosValid(oModel) }/*bPosValid*/, {|oModel| fMCommit(oModel) }/*bFormCommit*/, /*bFormCancel*/)

		// Valida a Ativa��o do Modelo
		oModel:SetVldActivate({|oModel| fMActivate(oModel) }/*bBloclVld*/)

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formul�rio Principal
		oModel:AddFields("TZ9MASTER"/*cID*/, /*cIDOwner*/, oStruTZ9/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/) // Cadastro do Indicador Gr�fico

		// Adiciona ao modelo um componente de Grid, com o "TZ9MASTER" como Owner
		oModel:AddGrid("TZAFORMULAS"/*cID*/, "TZ9MASTER"/*cIDOwner*/, oStruTZA/*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/) // F�rmulas relacionadas ao Indicador Gr�fico

			// Define a Rela��o do modelo das F�rmulas com o Principal (Indicador Gr�fico)
			oModel:SetRelation("TZAFORMULAS"/*cIDGrid*/,;
								{ {"TZA_FILIAL", 'xFilial("TZ9")'}, {"TZA_CODGRA", "TZ9_CODIGO"} }/*aConteudo*/,;
								TZA->( IndexKey(1) )/*cIndexOrd*/)

		// Adiciona a descri��o do Modelo de Dados (Geral)
		oModel:SetDescription(STR0005/*cDescricao*/) //"Indicadores Gr�ficos"

			//--------------------------------------------------
			// Defini��es do Modelo do Indicador Gr�fico
			//--------------------------------------------------

			// Adiciona a descri��o do Modelo de Dados TZ9
			oModel:GetModel("TZ9MASTER"):SetDescription(STR0006/*cDescricao*/) //"Indicador Gr�fico"

			//--------------------------------------------------
			// Defini��es do Modelo das F�rmulas
			//--------------------------------------------------

			// Adiciona a descri��o do Modelo de Dados TZA
			oModel:GetModel("TZAFORMULAS"):SetDescription(STR0007/*cDescricao*/) //"F�rmulas do Indicador Gr�fico"

				// Define que o Modelo n�o � obrigat�rio
				oModel:GetModel("TZAFORMULAS"):SetOptional(.T.)

				// Define qual a chave �nica por Linha no browse
				oModel:GetModel("TZAFORMULAS"):SetUniqueLine({"TZA_CODIND"})

		//------------------------------
		// Defini��o de campos MEMO VIRTUAIS
		//------------------------------

		FWMemoVirtual(oStruTZ9, { {"TZ9_CODDES", "TZ9_DESCRI"} } )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} fMCommit
Grava��o manual do Modelo de Dados.

@author Wagner Sobral de Lacerda
@since 02/03/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fMCommit(oModel)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Modelos
	Local oModelTZ9 := oModel:GetModel("TZ9MASTER")

	// Dados do Modelo
	Local cCodigo := oModelTZ9:GetValue("TZ9_CODIGO")

	//--------------------------------------------------
	// Grava��o do Modelo de Dados
	//--------------------------------------------------
	FWFormCommit(oModel)

	//--------------------------------------------------
	// Grava��o Personalizada
	//--------------------------------------------------

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		// Salva as Configura��es do Indicador Gr�fico
		NGI7SavCfg(oPreview, cCodigo, xFilial("TZ9"))
	EndIf

Return .T.

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

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("NGIND007")

	// Cria a estrutura a ser usada na View
	Local oStruTZ9 := FWFormStruct(2, "TZ9", {|cCampo| fStructCpo(cCampo, "TZ9") }/*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTZA := FWFormStruct(2, "TZA", {|cCampo| fStructCpo(cCampo, "TZA") }/*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualiza��o constru�da
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados ser� utilizado na View
		oView:SetModel(oModel)

		// Valida a Inicializa��o da View
		oView:SetViewCanActivate({|oView| fVActivate(oView) }/*bBloclVld*/)

		//--------------------------------------------------
		// Estrutura da View
		//--------------------------------------------------
		// TZ9
		//oStruTZ9:RemoveField("TZ9_CODDES")

		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------

		// Adiciona no View um controle do tipo formul�rio (antiga Enchoice)
		oView:AddField("VIEW_TZ9MASTER"/*cFormModelID*/, oStruTZ9/*oViewStruct*/, "TZ9MASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TZAFORMULAS"/*cFormModelID*/, oStruTZA/*oViewStruct*/, "TZAFORMULAS"/*cLinkID*/, /*bValid*/)

		//--------------------------------------------------
		// Layout
		//--------------------------------------------------

		// Cria os componentes "box" horizontais para receberem elementos da View
		oView:CreateHorizontalBox("BOX_SUPERIOR"/*cID*/, 050/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_INFERIOR"/*cID*/, 050/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

			//Cria os componentes "box" verticais dentro do box horizontal
			oView:CreateVerticalBox("BOX_INFERIOR_ESQ"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
			oView:CreateVerticalBox("BOX_INFERIOR_DIR"/*cID*/, 050/*nPercHeight*/, "BOX_INFERIOR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

				// Cria os componentes "box" horizontais, dentro dos verticais
				oView:CreateHorizontalBox("BOX_IND_INFERIOR_FORMULA"/*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_ESQ"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
				oView:CreateHorizontalBox("BOX_IND_INFERIOR_PREVIEW"/*cID*/, 100/*nPercHeight*/, "BOX_INFERIOR_DIR"/*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

					// Adiciona um "outro" tipo de objeto, o qual n�o faz necessariamente parte do modelo
					oView:AddOtherObject("VIEW_INDIC"/*cFormModelID*/, {|oPanel| fOtherPrew(oPanel) }/*bActivate*/, {|oPanel| fFreeOther(oPanel) }/*bDeActivate*/, /*bRefresh*/)

		// Relaciona o identificador (ID) da View com o "box" para exibi��o
		oView:SetOwnerView("VIEW_TZ9MASTER"  /*cFormModelID*/, "BOX_SUPERIOR"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TZAFORMULAS"/*cFormModelID*/, "BOX_IND_INFERIOR_FORMULA"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_INDIC"      /*cFormModelID*/, "BOX_IND_INFERIOR_PREVIEW"/*cIDUserView*/)

		// Adiciona um T�tulo para a View
		oView:EnableTitleView("VIEW_TZ9MASTER"  /*cFormModelID*/, STR0006/*cTitle*/, /*nColor*/) //"Indicador Gr�fico"
		oView:EnableTitleView("VIEW_INDIC"      /*cFormModelID*/, STR0008/*cTitle*/, /*nColor*/) //"Pr�-Visualiza��o"
		oView:EnableTitleView("VIEW_TZAFORMULAS"/*cFormModelID*/, STR0009/*cTitle*/, /*nColor*/) //"F�rmulas"

		//--------------------------------------------------
		// A��es da View (n�o refletem no Modelo de Dados, logo, n�o interferem na regra de neg�cio)
		//--------------------------------------------------

		// Define uma a��o a ser executada na View quando a valida��o de um campo do Modelo for Efetuada
		oView:SetFieldAction("TZ9_TITULO"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TZ9_SUBTIT"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TZ9_DESCRI"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

		oView:SetFieldAction("TZ9_ATIVO" /*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructCpo
Valida os campos da estrutura do Modelo ou View.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param cCampo
	Campo atual sendo verificado na estrutura * Obrigat�rio
@param cEstrutura
	Tabela da estrutura sendo carregada * Obrigat�rio

@return .T. caso o campo seja valido; .F. se nao for valido
/*/
//---------------------------------------------------------------------
Static Function fStructCpo(cCampo, cEstrutura)

	// Vari�vel de c�pia do array de Exce��es
	Local aExcecao := {}

	// Recebe os campos de exce��o
	If cEstrutura == "TZ9"
		aExcecao := aClone( aVCpoTZ9 )
	ElseIf cEstrutura == "TZA"
		aExcecao := aClone( aVCpoTZA )
	EndIf

	// Valida o Campo
	If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(cCampo) }) > 0
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldAction
Define uma a��o a ser executada quando um campo � Alterado/Validado
com sucesso.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@param oView
	Objeto da View * Obrigat�rio
@param cIDView
	ID da da View * Obrigat�rio
@param cField
	Campo acionado * Obrigat�rio
@param xValue
	Valor atual do campo * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFieldAction(oView, cIDView, cField, xValue)

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Vari�veis de 'Action'
	Local aChgPreview := {}
	Local aChgOthers  := {}

	// Define os campos que devem atualizar o Preview
	aAdd(aChgPreview, "TZ9_TITULO")
	aAdd(aChgPreview, "TZ9_SUBTIT")
	aAdd(aChgPreview, "TZ9_DESCRI")
	aAdd(aChgPreview, "TZ9_ATIVO" )

	//------------------------------
	// Atualiza o objeto Preview
	//------------------------------
	If aScan(aChgPreview, {|x| x == cField }) > 0
		fPrewAtu(oView)
	EndIf

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## DEFINI��O DOS "OTHER OBJECT" PARA A VIEW DO * MVC                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fOtherPrew
Monta a Preview (pr�-visualiza��o) do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oPanel
	Painel pai dos objetos * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fOtherPrew(oPanel)

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Dados do Modelo
	Local cValCodigo := FWFldGet("TZ9_CODIGO")

	// Vari�veis para montar o Indicador Gr�fico
	Local oPnlPai := Nil

	// Painel Pai do Preview
	oPnlPai := TPanel():New(01, 01, , oPanel, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		// Monta o Preview do Indicador
		oPreview := TNGIndicator():New(/*nTop*/, /*nLeft*/, 1/*nZoom*/, oPnlPai/*oParent*/, /*nWidth*/, /*nHeight*/, ;
										/*nClrFooter*/, /*cContent*/, /*cStyle*/, /*lScroll*/, .T./*lCenter*/)
		oPreview:SetFields(NGI7Fields())
		oPreview:Indicator() // Cria o Indicador em Tela
		If INCLUI
			oPreview:SetRClick(.F.)
		Else
			// Carrega as Configura��es para o Indicador Gr�fico em tela
			NGI7LoaCfg(@oPreview, cValCodigo, xFilial("TZ9"), .F.)
			If !ALTERA
				oPreview:CanConfig(.F.)
			EndIf
		EndIf
		oPreview:SetCodeBlock(2, {|lOk| fPrewAfter(lOk) }) // Ap�s a tela de Configura��o do Indicador
		oPreview:SetValue( aTail(oPreview:GetVals()) )

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrewAtu
Atualiza o Preview do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 26/01/2012

@param oView
	Objeto da View * Opcional
@param cIDView
	Identificador (ID) da View * Opcional (Obrigat�rio quando passar o objeto oView)
@param cField
	Identificador (ID) do Campo * Opcional
@param xValue
	Conte�do do Campo * Opcional

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPrewAtu(oView)

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Modelos
	Local oModelTZ9 := oView:GetModel("TZ9MASTER")

	// Dados do Modelo
	Local cTitulo := oModelTZ9:GetValue("TZ9_TITULO")
	Local cSubtit := oModelTZ9:GetValue("TZ9_SUBTIT")

	// Vari�veis para atualiza��o do Indicador
	Local aDescricao := {}
	Local aTextos    := {}

	//----------------------------
	// Carrega Vari�veis
	//----------------------------
	// T�tulo e Subt�tulo
	aAdd(aTextos, cTitulo)
	aAdd(aTextos, cSubtit)

	// Descri��o
	aAdd(aDescricao, "")
	aAdd(aDescricao, "")
	aAdd(aDescricao, "")

	//----------------------------
	// Atualiza o objeto Preview
	//----------------------------
	oPreview:Refresh(.F.) // Desabilita o Refresh

	oPreview:SetTexts(aTextos)
	oPreview:SetDesc(aDescricao)

	oPreview:Refresh(.T.) // Habilita o Refresh, e j� o executa

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fPrewAfter
Personaliza��o ap�s a tela de Configura��o do Indicador.

@author Wagner Sobral de Lacerda
@since 11/04/2012

@param lOk
	Indica como a tela foi encerrada: * Obrigat�rio
	   .T. - atrav�s de Confirma��o
	   .F. - atrav�s de Cancelamento

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fPrewAfter(lOk)

	// Modelos
	Local oView     := FWViewActive(oBkpView)
	Local oModelTZ9 := oView:GetModel("TZ9MASTER")

	// Dados do Modelo
	Local cOldTitulo := FWFldGet("TZ9_TITULO")

	// Dados do Indicador
	Local aTextos := aClone( oPreview:GetTexts() )

	// Verifica se alterou o formul�rio
	If lOk
		// Atualiza os Textos
		oModelTZ9:SetValue("TZ9_TITULO", aTextos[1])
		oModelTZ9:SetValue("TZ9_SUBTIT", aTextos[2])

		// Se atualizou mas n�o houve altera��o no formul�rio
		If !oModelTZ9:IsModified()
			oView:SetModified(.T./*lSet*/)
			// For�a uma atualiza��o no formul�rio
			oModelTZ9:SetValue("TZ9_TITULO", "ZZZ")
			oModelTZ9:SetValue("TZ9_TITULO", cOldTitulo)
		EndIf
	EndIf

	oView:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fFreeOther
Destroi os objetos dos 'Other Objetcs'.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oPanel
	Painel pai dos objetos * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fFreeOther(oPanel)

	// Destr�i o Indicador
	If Type("oPreview") == "O" .And. oPreview:ClassName() == "TNGINDICATOR"
		oPreview:Destroy()
	EndIf

	// Libera os componentes Filhos do painel
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
/*/{Protheus.doc} fMActivate
Valida a ativa��o do modelo de dados.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oModel
	Objeto do modelo de dados * Obrigat�rio

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fMActivate(oModel)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Vari�veis auxiliares do Help
	Local cAuxHelp01 := ""

	// Vari�vel do Retorno
	Local lReturn := .T.

	//------------------------------
	// Valida a Ativa��o do Modelo
	//------------------------------
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE // Altera��o ou Exclus�o

		If nOperation == MODEL_OPERATION_UPDATE
			cAuxHelp01 := STR0011 //"Este registro n�o pode ser alterado porque n�o pertence a este m�dulo."
		Else
			cAuxHelp01 := STR0012 //"Este registro n�o pode ser exclu�do porque n�o pertence a este m�dulo."
		EndIf

		If TZ9->TZ9_MODULO <> Str(nModulo,2) // M�dulo
			Help(Nil, Nil, STR0013, Nil, cAuxHelp01, 1, 0) //"Aten��o"
			lReturn := .F.
		EndIf

	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fVActivate
Valida se pode ativar a View.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return lReturn .T. pode inicializar; .F. n�o pode
/*/
//---------------------------------------------------------------------
Static Function fVActivate(oView)

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oView:GetOperation()

	// Vari�veis auxiliares do Help
	Local cAuxHelp01 := ""

	// Vari�vel do Retorno
	Local lReturn := .T.

	//------------------------------
	// Valida a Ativa��o da View
	//------------------------------
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE // Altera��o ou Exclus�o

		cAuxHelp01 := STR0015 //"Este registro n�o pode ser exclu�do porque seu propriet�rio � o"
		cAuxHelp01 +=  " '" + AllTrim( NGRETSX3BOX("TZ9_PROPRI",TZ9->TZ9_PROPRI) ) + "'."

		If TZ9->TZ9_PROPRI == "1" // Protheus
			If nOperation == MODEL_OPERATION_DELETE // Impede a dele��o do indicador
				Help(Nil, Nil, STR0013, Nil, cAuxHelp01, 1, 0) // "Aten��o"
				lReturn := .F.
			EndIf
		EndIf

	EndIf

	// Armazena um backup da view
	oBkpView := oView

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
P�s-valida��o do modelo de dados.

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oModel
	Objeto do modelo de dados * Obrigat�rio

@return lReturn
/*/
//---------------------------------------------------------------------
Static Function fMPosValid(oModel)

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Opera��o de a��o sobre o Modelo
	Local nOperation := oModel:GetOperation()

	// Modelos
	Local oModelTZ9 := oModel:GetModel("TZ9MASTER")
	Local oModelTZA := oModel:GetModel("TZAFORMULAS")

	// Vari�vel do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If nOperation <> MODEL_OPERATION_DELETE // Diferente de Exclus�o

		If nOperation == MODEL_OPERATION_INSERT // Inclus�o

			// O C�digo do Usu�rio deve estar preenchido quando o Propriet�rio for 'Usu�rio'
			If oModelTZ9:GetValue("TZ9_PROPRI") == "2"
				If Empty(oModelTZ9:GetValue("TZ9_USCAD"))
					Help(Nil, Nil, STR0013, Nil,;
						STR0016 + " '" + AllTrim( NGRETSX3BOX("TZ9_PROPRI",TZ9->TZ9_PROPRI) ) + "'",; //"O Usu�rio � uma informa��o obrigat�ria quando o propriet�rio do Indicador �"
						1, 0) //"Aten��o"
					lReturn := .F.
				EndIf
			EndIf
		EndIf

		// Valida Modelo TZ9
		If !oModelTZ9:VldData()
			lReturn := .F.
		EndIf

		// Valida Modelo TZA
		If !oModelTZA:VldData()
			lReturn := .F.
		EndIf

	EndIf

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return lReturn

/*/
############################################################################################
##                                                                                        ##
## FUN��ES AUXILIARES DA ROTINA                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007LG
Fun��o para adicionar uma Legenda padronizada ao browse de
Indicadores Gr�ficos (tabela TZ9)

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007LG(oObjBrw)

	// Vari�vel do retorno
	Local lRetorno := .F.

	// Defaults
	Default oObjBrw := Nil

	//----------
	// Legenda
	//----------
	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TZ9"
			oObjBrw:AddLegend("TZ9_ATIVO == '1'", "GREEN", STR0017) //"Ativo"
			oObjBrw:AddLegend("TZ9_ATIVO == '2'", "RED"  , STR0018) //"Inativo"

			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007FL
Fun��o para adicionar um Filtro padronizado ao browse de
Indicadores Gr�ficos (tabela TZ9)

@author Wagner Sobral de Lacerda
@since 24/01/2012

@param oObjBrw
	Objeto do FWMBrowse * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007FL(oObjBrw)

	// Vari�vel do retorno
	Local lRetorno := .F.

	// Defaults
	Default oObjBrw := Nil

	//----------
	// Legenda
	//----------
	If ValType(oObjBrw) == "O" .And. MethIsMemberOf(oObjBrw,"ClassName")
		If Upper(oObjBrw:ClassName()) == "FWMBROWSE" .And. oObjBrw:Alias() == "TZ9"
			oObjBrw:SetFilterDefault("TZ9_MODULO == '" + Str(nModulo,2) + "'")

			lRetorno := .T.
		EndIf
	EndIf

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007VR
Declara as vari�veis Private utilizadas no Indicador Gr�fico.
* Lembrando que essas vari�veis ficam declaradas somente para a fun��o
que � Pai imediata desta.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@param lUseDefault
	Indica se deve definir os conte�dos default das vari�veis * Opcional
	   .T. - Define conte�dos Default
	   .F. - N�o define conte�dos Default
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007VR(lUseDefault)

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Defaults
	Default lUseDefault := .T.

	//------------------------------
	// Declara as vari�veis
	//------------------------------
	// Vari�vel do Cadastro
	_SetOwnerPrvt("cCadastro", OemToAnsi(STR0005)) //"Indicadores Gr�ficos"

	// Vari�vel da Consulta SXB Gen�rica
	_SetOwnerPrvt("cMntGenFun", "NGIND007M1()")
	_SetOwnerPrvt("cMntGenRet", "NGIND007M2()")
	_SetOwnerPrvt("cRetModulo", Str(nModulo,2))

	_SetOwnerPrvt("aVCpoTZ9", {}) // Vari�vel de exce��o de campos na View da TZ9
	_SetOwnerPrvt("aVCpoTZA", {}) // Vari�vel de exce��o de campos na View da TZA

	_SetOwnerPrvt("oPreview", Nil) // Objeto Preview (pr�-visualiza��o) do Indicador
	_SetOwnerPrvt("oBkpView", Nil) // Objeto da View Atual do cadstro do Indicador

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

	//------------------------------
	// Define conte�dos Default
	//------------------------------
	// Monta o array com a exce��o de campos
	fCposExcep()

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES UTILIZADAS NO DICION�RIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007M1
Fun��o para criar a Consulta de M�dulos.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function NGIND007M1()

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Vari�veis do Browse
	Local oDlgConMod := Nil, oPnlAll := Nil, oPnlBot  := Nil, oBtnConfir := Nil, oBtnCancel := Nil
	Local oBrwConMod := Nil, oColuna := Nil, aColunas := {}

	// Vari�veis de controlo dos m�dulos
	Local aInfoUser  := {}
	Local nNumModulo := 0
	Local nX := 0, nPos := 0

	Local aModUser := {}
	Local nRetOk   := 0

	//----------------------------------------
	// M�dulos que o usu�rio possui acesso
	//----------------------------------------
	aModUser := aClone( NGUserMod() )

	//----------------------------------------
	// Tela da Consulta
	//----------------------------------------
	nRetOk := 0
	DEFINE MSDIALOG oDlgConMod TITLE OemToAnsi(STR0019) FROM 0,0 TO 350,800 OF oMainWnd PIXEL //"M�dulos Acess�veis"

		// Painal ALL do Browse
		oPnlAll := TPanel():New(01, 01, , oDlgConMod, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

			// Monta o Browse
			oBrwConMod := FWBrowse():New(oPnlAll)

			oBrwConMod:SetDataArray()
			oBrwConMod:SetInsert(.F.) // Desabilita a Inser��o de registros
			oBrwConMod:DisableReport() // Desabilita a Impress�o
			oBrwConMod:SetLocate() // Habilita a Localiza��o de registros
			oBrwConMod:SetSeek() // Habilita a Pesquisa de registros

			//oBrwConMod:SetLineHeight(16)

			aColunas := {}
				// Coluna: N�mero do M�dulo (C�digo)
				oColuna := FWBrwColumn():New()
				oColuna:SetAlign(CONTROL_ALIGN_LEFT)
				oColuna:SetData({|| aModUser[oBrwConMod:AT()][1] })
				oColuna:SetEdit(.F.)
				oColuna:SetSize(10)
				oColuna:SetTitle(STR0020) //"C�digo"
				oColuna:SetType("N")

				aAdd(aColunas, oColuna)

				// Coluna: Nome do M�dulo
				oColuna := FWBrwColumn():New()
				oColuna:SetAlign(CONTROL_ALIGN_LEFT)
				oColuna:SetData({|| aModUser[oBrwConMod:AT()][2] })
				oColuna:SetEdit( .F. )
				oColuna:SetSize(15)
				oColuna:SetTitle(STR0021) //"Nome"
				oColuna:SetType("C")

				aAdd(aColunas, oColuna)

				// Coluna: Descri��o do M�dulo
				oColuna := FWBrwColumn():New()
				oColuna:SetAlign(CONTROL_ALIGN_LEFT)
				oColuna:SetData({|| aModUser[oBrwConMod:AT()][3] })
				oColuna:SetEdit( .F. )
				oColuna:SetSize(40)
				oColuna:SetTitle(STR0022) //"Descri��o"
				oColuna:SetType("C")

				aAdd(aColunas, oColuna)

			oBrwConMod:SetColumns(aColunas)
			oBrwConMod:SetArray(aModUser)

			oBrwConMod:Activate()
			oBrwConMod:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwConMod:SetDoubleClick({|| Eval(oBtnConfir:bAction) })

		// Painel BOT dos Bot�es
		oPnlBot := TPanel():New(01, 01, , oDlgConMod, , , , CLR_BLACK, CLR_WHITE, 100, 016, .F., .F.)
		oPnlBot:Align := CONTROL_ALIGN_BOTTOM

			// Bot�o de OK
			oBtnConfir := TButton():New(002, 010, "Ok", oPnlBot, {|| nRetOk := oBrwConMod:AT(), oDlgConMod:End() },;
											040, 012, , , .F., .T., .F., , .F., , , .F.)

			// Bot�o de Cancelar
			oBtnCancel := TButton():New(002, 060, STR0023, oPnlBot, {|| nRetOk := 0, oDlgConMod:End() },; //"Cancelar"
											040, 012, , , .F., .T., .F., , .F., , , .F.)


	ACTIVATE MSDIALOG oDlgConMod CENTER

	If nRetOk > 0
		cRetModulo := Str(aModUser[nRetOk][1],2)
	Else
		cRetModulo := Str(nModulo,2)
	EndIf

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007M2
Fun��o do retorno da Consulta de M�dulos.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@return cReturn Conte�do (em caractere) do M�dulo
/*/
//---------------------------------------------------------------------
Function NGIND007M2()

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Vari�vel do Retorno
	Local cReturn := Space(TAMSX3("TZ9_MODULO")[1])

	// Recebe o Retorno
	If ValType(cRetModulo) == "C"
		cReturn := cRetModulo
	EndIf

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return cReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007MD
Fun��o para validar o M�dulo do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 03/02/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGIND007MD()

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// M�dulos que o usu�rio possui acesso
	Local aModUser := aClone( NGUserMod() )

	// Dados do Modelo
	Local cValModulo := Str(nModulo,2)

	// Vari�vel do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If aScan(aModUser, {|x| Str(x[1],2) == cValModulo }) == 0
		Help(Nil, Nil, STR0013, Nil, STR0024, 1, 0) //"Aten��o" ## "O M�dulo selecionado � inv�lido porque ou n�o existe, ou voc� n�o possui permiss�o de acesso � ele."
		lReturn := .F.
	EndIf

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007FO
Fun��o para validar a F�rmula relacionada ao Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 09/04/2012

@return lReturn
/*/
//---------------------------------------------------------------------
Function NGIND007FO()

	// Salva as �res atuais
	Local aAreaTZ9 := TZ9->( GetArea() )
	Local aAreaTZA := TZA->( GetArea() )

	// Dados do Modelo
	Local cValCodigo := FWFldGet("TZ9_CODIGO")
	Local cValModulo := Str(nModulo,2)
	Local cValFormul := FWFldGet("TZA_CODIND")

	// Vari�veis da query
	Local cQryAlias := ""
	Local cQryDupli := ""

	// Vari�vel do Retorno
	Local lReturn := .T.

	//----------
	// Valida
	//----------
	If !ExistCpo("TZ5", cValModulo + cValFormul, 1)
		lReturn := .F.
	EndIf

	// Duplicidade com outros cadastros de Indicadores Gr�ficos
	If lReturn
		// Query de registros duplicados (f�rmulas j� cadastrados para outro Indicador Gr�fico)
		cQryAlias := GetNextAlias()

		// SELECT
		cQryDupli := "SELECT "
		cQryDupli += " TZA.TZA_CODGRA AS CODGRA, "
		cQryDupli += " COUNT(*) AS DUPLIC "
		// FROM
		cQryDupli += "FROM " + RetSQLName("TZA") + " TZA "
		//WHERE
		cQryDupli += "WHERE "
		cQryDupli += " TZA.TZA_CODIND = " + ValToSQL(cValFormul) + " "
		cQryDupli += " AND TZA.TZA_CODGRA <> " + ValToSQL(cValCodigo) + " "
		cQryDupli += " AND TZA.D_E_L_E_T_ <> '*' "
		// GROUP BY
		cQryDupli += "GROUP BY "
		cQryDupli += " TZA.TZA_CODGRA "

		// Executa a Query
		cQryDupli := ChangeQuery(cQryDupli)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryDupli), cQryAlias, .T., .T.)

		// Verifica se h� registro duplicados
		dbSelectArea(cQryAlias)
		dbGoTop()
		While !Eof()
			If (cQryAlias)->DUPLIC > 0
				Help(Nil, Nil, STR0013, Nil,;
					STR0025 + " '" + AllTrim( (cQryAlias)->CODGRA ) + "'.",; //"Esta F�rmula n�o pode ser vinculada a este Indicador Gr�fico porque ela j� est� relacionada a outro indicador, de c�digo"
					1, 0) //"Aten��o"
				lReturn := .F.
			EndIf

			dbSelectArea(cQryAlias)
			dbSkip()
		End
		dbSelectArea(cQryAlias)
		dbCloseArea()
	EndIf

	// Devolve as �res
	RestArea(aAreaTZ9)
	RestArea(aAreaTZA)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIND007FO
Fun��o para retornar o ComboBox do campo Modelo do Indicador Gr�fico.
("TZ9_MODELO")

@author Wagner Sobral de Lacerda
@since 29/08/2012

@return uReturn
/*/
//---------------------------------------------------------------------
Function NGIND007BX(nTypeRet)

	// Vari�vel do Retorno
	Local uReturn := Nil

	// Vari�veis do ComboBox
	Local cComboBox := STR0026
	Local aComboBox := StrTokArr(cComboBox, ";")

	// Defaults
	Default nTypeRet := 1

	// Define o retorno
	If nTypeRet == 1
		uReturn := cComboBox
	ElseIf nTypeRet == 2
		uReturn := aComboBox
	EndIf

Return uReturn

/*/
############################################################################################
##                                                                                        ##
## FUN��ES PARA MANIPULA��O DA CLASSE 'TNGIndicator'                                      ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7SavCfg
Fun��o que salva as Configura��es do Indicador.
* ATEN��O: apenas SALVA no Indicador que j� existe
(n�o cria um registro, somente altera)

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio
@param cCodIndic
	C�digo do Indicador Gr�fico para salvar o Indicador * Opcional
	Default: oObjIndic:cLoadIndic (C�digo do Indicador atualmente carregado)
@param cCodFilial
	C�digo da Filial para salvar o Indicador * Opcional
	Default: oObjIndic:cLoadFilia (Filial atualmente carregada para o Indicador)

@return .T. Configura��o salva; .F. caso n�o
/*/
//---------------------------------------------------------------------
Function NGI7SavCfg(oObjIndic, cCodIndic, cCodFilial) // SaveConfig

	// Salva as �res atuais
	Local aAreaTZ9 := {}

	// Vari�veis das defini��es do Indicador
	Local cStyle   := oObjIndic:GetStyle()
	Local cContent := oObjIndic:GetContent()

	Local aConfig    := aClone( oObjIndic:GetConfig()  )
	Local aCores     := aClone( oObjIndic:GetColors()  )
	Local aDescricao := aClone( oObjIndic:GetDesc()    )
	Local aSombras   := aClone( oObjIndic:GetShadows() )
	Local aTextos    := aClone( oObjIndic:GetTexts()   )
	Local aValores   := aClone( oObjIndic:GetVals()    )
	Local nQtdeVals  := oObjIndic:nMaxVals

	// Vari�vel do Retorno
	Local lReturn := .F.

	// Defaults
	Default cCodIndic  := oObjIndic:cLoadIndic
	Default cCodFilial := oObjIndic:cLoadFilia

	// Define o tamanho c�digo do Indicador Gr�fico
	cCodIndic := PADR(cCodIndic, TAMSX3("TZ9_CODIGO")[1], " ")

	// Armazena a �rea atual
	aAreaTZ9 := TZ9->( GetArea() )

	// Se o ambiente estiver aberto, atualiza o registro na tabela de Indicadores Gr�ficos
	dbSelectArea("TZ9")
	dbSetOrder(1)
	If dbSeek(cCodFilial+cCodIndic)

		BEGIN TRANSACTION //Inicializa a Transa��o

			// Trava o registro para altera��o
			RecLock("TZ9", .F.)

			// T�tulo e Subt�tulo
			TZ9->TZ9_TITULO := aTextos[1]
			TZ9->TZ9_SUBTIT := aTextos[2]

			// Legenda das Se��es
			TZ9->TZ9_LEGMIN := aDescricao[1]
			TZ9->TZ9_LEGMED := aDescricao[2]
			TZ9->TZ9_LEGMAX := aDescricao[3]

			// Estilo (modelo)
			TZ9->TZ9_MODELO := cStyle

			// Tipo de Conte�do
			TZ9->TZ9_TIPCON := cContent

			// Configura��es das Se��es
			TZ9->TZ9_SECMIN := aConfig[3][1][2] // Porcentagem
			TZ9->TZ9_SECMAX := aConfig[3][2][2] // Porcentagem

			// Valores
			TZ9->TZ9_VAL01 := If(nQtdeVals >= 1, aValores[1], 0)
			TZ9->TZ9_VAL02 := If(nQtdeVals >= 2, aValores[2], 0)
			TZ9->TZ9_VAL03 := If(nQtdeVals >= 3, aValores[3], 0)
			TZ9->TZ9_VAL04 := If(nQtdeVals >= 4, aValores[4], 0)
			TZ9->TZ9_VAL05 := If(nQtdeVals >= 5, aValores[5], 0)
			TZ9->TZ9_VAL06 := If(nQtdeVals >= 6, aValores[6], 0)
			TZ9->TZ9_VAL07 := If(nQtdeVals >= 7, aValores[7], 0)

			// Sombreamento ("1=Sim;2=N�o")
			TZ9->TZ9_SOMB01 := If(aSombras[1], "1", "2")
			TZ9->TZ9_SOMB02 := If(aSombras[2], "1", "2")
			TZ9->TZ9_SOMB03 := If(aSombras[3], "1", "2")

			// Cores
			TZ9->TZ9_COR01 := aCores[1]
			TZ9->TZ9_COR02 := aCores[2]
			TZ9->TZ9_COR03 := aCores[3]
			TZ9->TZ9_COR04 := aCores[4]
			TZ9->TZ9_COR05 := aCores[5]
			TZ9->TZ9_COR06 := aCores[6]
			TZ9->TZ9_COR07 := aCores[7]
			TZ9->TZ9_COR08 := aCores[8]
			TZ9->TZ9_COR09 := aCores[9]
			TZ9->TZ9_COR10 := aCores[10]
			TZ9->TZ9_COR11 := aCores[11]
			TZ9->TZ9_COR12 := aCores[12]
			TZ9->TZ9_COR13 := aCores[13]
			TZ9->TZ9_COR14 := aCores[14]

			// Libera o registro travado
			MsUnlock("TZ9")

		END TRANSACTION // Encerra a Transa��o

		lReturn := .T.

	EndIf

	// Devolve a �rea
	RestArea(aAreaTZ9)

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7LoaCfg
Fun��o que carrega as Configura��es do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio
@param cCodIndic
	C�digo do Indicador Gr�fico para carregar o Indicador * Obrigat�rio
@param cCodFilial
	C�digo da Filial para carregar o Indicador * Opcional
	Default: xFilial("TZ9")
@param lShowMsg
	Indica se deve mostrar mensagem em tela * Opcional
	   .T. - Mostra mensagem
	   .F. - N�o mostra
	Default: .T.

@return .T. Configura��o carregada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Function NGI7LoaCfg(oObjIndic, cCodIndic, cCodFilial, lShowMsg) // LoadConfig

	// Salva as �res atuais
	Local aAreaTZ9 := {}

	// Vari�veis das defini��es do Indicador (n�o carregar� caso n�o encontre o Indicador na base de dados)
	Local cStyle   := oObjIndic:GetStyle()
	Local cContent := oObjIndic:GetContent()
	Local cModLoad := ""

	Local aConfig    := aClone( oObjIndic:GetConfig()  )
	Local aCores     := {}
	Local aDescricao := {}
	Local aSombras   := {}
	Local aTextos    := {}
	Local aValores   := {}
	Local nQtdeVals  := 7 // Vamos utilizar a quantidade m�xima

	// Vari�vel do Retorno
	Local lReturn := .F.

	// Defaults
	Default cCodIndic  := ""
	Default cCodFilial := ""
	Default lShowMsg   := .T.

	// Define o c�digo da filial
	cCodFilial := If(Empty(cCodFilial), xFilial("TZ9"), cCodFilial)

	// Define o c�digo do Indicador Gr�fico
	cCodIndic := PADR(cCodIndic, TAMSX3("TZ9_CODIGO")[1], " ")

	// Armazena a �rea atual
	aAreaTZ9 := TZ9->( GetArea() )

	// Busca o indicador na tabela de Indicadores Gr�ficos
	dbSelectArea("TZ9")
	dbSetOrder(1)
	If dbSeek(cCodFilial + cCodIndic)

		// M�dulo
		cModLoad := TZ9->TZ9_MODULO

		// T�tulo e Subt�tulo
		aTextos := Array(3)
		aTextos[1] := TZ9->TZ9_TITULO
		aTextos[2] := TZ9->TZ9_SUBTIT
		// Descri��o
		aDescricao := Array(3)
		aDescricao[1] := TZ9->TZ9_LEGMIN
		aDescricao[2] := TZ9->TZ9_LEGMED
		aDescricao[3] := TZ9->TZ9_LEGMAX

		// Estilo (modelo)
		cStyle := TZ9->TZ9_MODELO

		// Tipo de Conte�do
		cContent := TZ9->TZ9_TIPCON

		// Configura��es das Se��es (este array j� est� pre-definido, n�o precisando cri�-lo ent�o com a fun��o 'Array()')
		aConfig[3][1][2] := Round(TZ9->TZ9_SECMIN,2) // Porcentagem
		aConfig[3][2][2] := Round(TZ9->TZ9_SECMAX,2) // Porcentagem

		// Valores
		aValores := Array(nQtdeVals)
		If Len(aValores) >= nQtdeVals
			aValores[1] := Round(TZ9->TZ9_VAL01,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[2] := Round(TZ9->TZ9_VAL02,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[3] := Round(TZ9->TZ9_VAL03,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[4] := Round(TZ9->TZ9_VAL04,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[5] := Round(TZ9->TZ9_VAL05,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[6] := Round(TZ9->TZ9_VAL06,2)
		EndIf
		If Len(aValores) >= nQtdeVals
			aValores[7] := Round(TZ9->TZ9_VAL07,2)
		EndIf

		// Sombreamento ("1=Sim;2=N�o")
		aSombras := Array(3)
		aSombras[1] := ( AllTrim(TZ9->TZ9_SOMB01) == "1" )
		aSombras[2] := ( AllTrim(TZ9->TZ9_SOMB02) == "1" )
		aSombras[3] := ( AllTrim(TZ9->TZ9_SOMB03) == "1" )

		// Cores
		aCores := Array(14)
		aCores[1] := SubStr(TZ9->TZ9_COR01, 1, 7)
		aCores[2] := SubStr(TZ9->TZ9_COR02, 1, 7)
		aCores[3] := SubStr(TZ9->TZ9_COR03, 1, 7)
		aCores[4] := SubStr(TZ9->TZ9_COR04, 1, 7)
		aCores[5] := SubStr(TZ9->TZ9_COR05, 1, 7)
		aCores[6] := SubStr(TZ9->TZ9_COR06, 1, 7)
		aCores[7] := SubStr(TZ9->TZ9_COR07, 1, 7)
		aCores[8] := SubStr(TZ9->TZ9_COR08, 1, 7)
		aCores[9] := SubStr(TZ9->TZ9_COR09, 1, 7)
		aCores[10] := SubStr(TZ9->TZ9_COR10, 1, 7)
		aCores[11] := SubStr(TZ9->TZ9_COR11, 1, 7)
		aCores[12] := SubStr(TZ9->TZ9_COR12, 1, 7)
		aCores[13] := SubStr(TZ9->TZ9_COR13, 1, 7)
		aCores[14] := SubStr(TZ9->TZ9_COR14, 1, 7)

		lReturn := .T.

	EndIf

	// Devolve a �rea
	RestArea(aAreaTZ9)

	// Atualiza o Indicador Gr�fico
	oObjIndic:cLoadFormu := ""
	If lReturn

		// Bloqueia a Atualia��o do Indicador
		oObjIndic:Refresh(.F.)

		// Vari�veis identificadores de que o Indicador foi carregado
		oObjIndic:cLoadIndic := cCodIndic
		oObjIndic:cLoadFilia := cCodFilial
		oObjIndic:cLoadModul := cModLoad

		// Inicializa o Indicador (ou Reinicializa) para poder prepar�-lo para as configura��es carregadas
		oObjIndic:Initialize()

		// Seta as defini��es do Indicador
		oObjIndic:SetStyle(cStyle)
		oObjIndic:SetContent(cContent)

		oObjIndic:SetConfig(aConfig)
		oObjIndic:SetColors(aCores)
		oObjIndic:SetShadows(aSombras)
		oObjIndic:SetTexts(aTextos)
		oObjIndic:SetDesc(aDescricao)
		oObjIndic:SetVals(aValores)

		// Atualiza o Indicador
		oObjIndic:Refresh(.T.)

	Else

		// Vari�veis identificadores de que o Indicador foi carregado
		oObjIndic:cLoadIndic := ""
		oObjIndic:cLoadFilia := ""
		oObjIndic:cLoadModul := ""

		// Mensagem
		If lShowMsg
			Help(Nil, Nil, STR0013, Nil, STR0027 + ":" + CRLF + ; //"Aten��o" ## "N�o foi poss�vel carregar o cadastro do Indicador Gr�fico"
					STR0028 + ": '" + cCodFilial + "'" + CRLF + ; //"Filial"
					STR0020 + ": '" + cCodIndic + "'", 1, 0) //"C�digo"
		EndIf

	EndIf

Return lReturn

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7LoaFrm
Fun��o que carrega uma F�rmula para o Indicador.

@author Wagner Sobral de Lacerda
@since 23/04/2012

@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio
@param cCodFormul
	C�digo da F�rmula para carregar no Indicador * Obrigat�rio
@param cCodFilial
	C�digo da Filial para carregar a F�rmula * Opcional
	Default: xFilial("TZA")
@param cCodModul
	C�digo do M�dulo da F�rmula para carregar no Indicador * Opcional
	Default: Str(nModulo,2)
@param lShowMsg
	Indica se deve mostrar mensagem em tela * Opcional
	   .T. - Mostra mensagem
	   .F. - N�o mostra
	Default: .T.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function NGI7LoaFrm(oObjIndic, cCodFormul, cCodFilial, cCodModul, lShowMsg) // LoadFormul

	// Salva as �res atuais
	Local aAreaTZ5 := {}
	Local aAreaTZ9 := {}
	Local aAreaTZA := {}

	// Vari�veis das defini��es do Indicador
	Local aDescricao := {}
	Local aTextos    := {}

	Local cNomeFormu := ""

	// Vari�vel do Retorno
	Local lReturn := .F.

	// Defaults
	Default cCodFormul := ""
	Default cCodFilial := ""
	Default cCodModul  := ""
	Default lShowMsg   := .T.

	// Se o Indicador Gr�fico n�o estiver carregado, carrega
	If Empty(oObjIndic:cLoadIndic)
		cCodFilial := If(Empty(cCodFilial), xFilial("TZA"), cCodFilial)
		cCodModul  := If(Empty(cCodModul), Str(nModulo,2), cCodModul)

		aAreaTZ9 := TZ9->( GetArea() )
		aAreaTZA := TZA->( GetArea() )
		dbSelectArea("TZA")
		dbSetOrder(2)
		dbSeek(cCodFilial + cCodFormul, .T.)
		While !Eof() .And. TZA->TZA_FILIAL == cCodFilial .And. TZA->TZA_CODIND == cCodFormul
			dbSelectArea("TZ9")
			dbSetOrder(1)
			If dbSeek(TZA->TZA_FILIAL + TZA->TZA_CODGRA) .And. TZ9->TZ9_MODULO == cCodModul
				NGI7LoaCfg(oObjIndic, TZA->TZA_CODGRA, TZA->TZA_FILIAL, lShowMsg)
				Exit
			EndIf

			dbSelectArea("TZA")
			dbSkip()
		End
		RestArea(aAreaTZ9)
		RestArea(aAreaTZA)
	EndIf

	// Se o Indicador Gr�fico estiver carregado
	If !Empty(oObjIndic:cLoadIndic)
		// Armazena a �rea atual
		aAreaTZ5 := TZ5->( GetArea() )

		// Vari�veis das defini��es do Indicador
		aDescricao := aClone( oObjIndic:GetDesc() )
		aTextos    := aClone( oObjIndic:GetTexts() )

		// Busca o indicador na tabela de Indicadores Gr�ficos
		dbSelectArea("TZ5")
		dbSetOrder(1)
		If dbSeek(oObjIndic:cLoadFilia + oObjIndic:cLoadModul + cCodFormul)
			// T�tulo e Subt�tulo
			aTextos[1] := TZ5->TZ5_CODIND

			lReturn := .T.
		EndIf

		// Devolve a �rea
		RestArea(aAreaTZ5)
	EndIf

	If lReturn

		// Bloqueia a Atualia��o do Indicador
		oObjIndic:Refresh(.F.)

		// Atualiza a vari�vel da F�rmula carregada
		oObjIndic:cLoadFormu := cCodFormul

		// Seta as defini��es do Indicador
		oObjIndic:SetTexts(aTextos)
		oObjIndic:SetDesc(aDescricao)
		oObjIndic:SetTooltip(cNomeFormu)

		// Atualiza o Indicador
		oObjIndic:Refresh(.T.)

	Else

		// Mensagem
		If lShowMsg
			Help(Nil, Nil, cCodFormul, Nil, STR0029 + ":" + CRLF + ; //"N�o foi poss�vel carregar o cadastro da F�rmula"
					STR0028 + ": '" + oObjIndic:cLoadFilia + "'" + CRLF + ; //"Filial"
					STR0020 + ": '" + cCodFormul + "'", 1, 0) //"C�digo"
		EndIf

		Return .F.

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Fields
Executa a 'SetFields' do Indicador Gr�fico.
* Define as especifica��es dos campos do array 'aFields', propriedade
da classe TNGIndicator.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@return aFields
/*/
//---------------------------------------------------------------------
Function NGI7Fields() // SetFields

	// Vari�vel do Retorno
	Local aFieldInfo := {}

	// Vari�veis dos campos para buscar
	Local aCposX3 := {}
	Local nCpo := 0

	// Vari�veis auxiliares
	Local cIDCampo := ""
	Local cTitulo  := ""

	//-- Define os campos
	aAdd(aCposX3, "TZ9_TITULO") // Posi��o '__nFldTitl'
	aAdd(aCposX3, "TZ9_SUBTIT") // Posi��o '__nFldSubt'
	aAdd(aCposX3, "TZ9_LEGMIN") // Posi��o '__nFldLeg1'
	aAdd(aCposX3, "TZ9_LEGMED") // Posi��o '__nFldLeg2'
	aAdd(aCposX3, "TZ9_LEGMAX") // Posi��o '__nFldLeg3'
	aAdd(aCposX3, "TZ9_MODELO") // Posi��o '__nFldModl'
	aAdd(aCposX3, "TZ9_TIPCON") // Posi��o '__nFldTipC'

	//----------------------------------------
	// Define os Tamanhos e Decimais
	//----------------------------------------
	For nCpo := 1 To Len(aCposX3)
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(aCposX3[nCpo])

		cIDCampo  := aCposX3[nCpo]
		cTitulo   := AllTrim( If("_LEG" $ cIDCampo, X3Descric(), X3Titulo()) )
		cAuxSoluc := AllTrim( StrTran(GetHlpSoluc(cIDCampo)[1],CRLF," ") )

		// Adiciona no array
		aAdd(aFieldInfo, {	cTitulo                 , ; // [1] - T�tulo
							Posicione("SX3",2,aCposX3[nCpo],"X3_TAMANHO")         , ; // [2] - Tamanho
							Posicione("SX3",2,aCposX3[nCpo],"X3_DECIMAL")         , ; // [3] - Decimal
							AllTrim(Posicione("SX3",2,aCposX3[nCpo],"X3_PICTURE")), ; // [4] - Picture
							AllTrim(X3CBox())        }) // [5] - ComboBox
	Next nCpo

Return aFieldInfo

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Info
Fun��o que carrega as Informa��es do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Function NGI7Info(oObjIndic) // Information

	// Vari�veis do objeto
	Local aInfo := aClone( oObjIndic:GetInfo() )
	Local nInfo := 0

	// Vari�veis da Janela
	Local oDlgInf
	Local cDlgInf := OemToAnsi(STR0030) //"Informa��es"

	Local oBackground
	Local oBtnFechar
	Local nFIM_LIN, nFIM_COL

	Local cAuxSay := ""
	Local cAuxGet := "", lIsChar := .F.
	Local nAuxSiz := 0, nMinSiz := 40
	Local nLin, nCol

	//--------------------
	// Monta as Informa��es
	//--------------------
	DEFINE MSDIALOG oDlgInf TITLE cDlgInf FROM 0,0 TO 340,450 OF oMainWnd STYLE WS_POPUPWINDOW PIXEL

		// Tamanhos Finais
		nFIM_LIN := ( oDlgInf:nClientHeight * 0.50 )
		nFIM_COL := ( oDlgInf:nClientWidth * 0.50 )

		// Background
		oBackground := fRClkBack(@oDlgInf)

			// Bot�o: Fechar
			oBtnFechar := TBtnBmp2():New(001, ((nFIM_COL*2)-020), 20, 20, "BR_CANCEL", , , , {|| oDlgInf:End() }, oBackground, OemToAnsi(STR0031)) //"Fechar"
			oBtnFechar:lCanGotFocus := .F.

			// GroupBox
			TGroup():New(010, 005, (nFIM_LIN-005), (nFIM_COL-005), STR0032, oBackground, , , .T., ) //"Informa��es sobre o Objeto"

				// Monta as Informa��es do Objeto
				nLin := 025
				nCol := 015
				For nInfo := 1 To Len(aInfo)
					//--- Mensagem
					cAuxSay := "{|| '" + aInfo[nInfo][1]+":" + "' }"
					TSay():New(nLin+001, nCol, &(cAuxSay), oBackground, , , , , , .T., CLR_BLACK, , 150, 012)

					//--- Conte�do
					lIsChar := ValType(aInfo[nInfo][2]) == "C"
					nAuxSiz := ( Len(aInfo[nInfo][2]) * 5 )
					If nAuxSiz < nMinSiz
						nAuxSiz := nMinSiz
					EndIf

					cAuxGet := "{|| " + If(lIsChar,"'","") + aInfo[nInfo][2] + If(lIsChar,"'","") + " }"
					TGet():New((nLin-001), (nCol+090), &(cAuxGet), oBackground, nAuxSiz, 008, "",;
								{|| .T. }, , , ,;
								.F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

					// Incrementa a linha
					nLin += 15
				Next nInfo

	ACTIVATE MSDIALOG oDlgInf CENTERED

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Detail
Fun��o que carrega os Detalhes do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function NGI7Detail(oObjIndic) // LoadFormul

	// Salva as �res atuais
	Local aAreaSX3 := SX3->( GetArea() )

	// Vari�veis do Objeto
	Local cCodIndic  := oObjIndic:cLoadIndic
	Local cCodFilial := oObjIndic:cLoadFilia
	Local cCodModulo := oObjIndic:cLoadModul
	Local cCodFormul := oObjIndic:cLoadFormu

	// Vari�veis da Query
	Local cQryAlias := ""
	Local cQryLegen := ""

	// Vari�veis da Janela
	Local oDlgDet
	Local cDlgDet := OemToAnsi(STR0033) //"Detalhamento"

	Local oBackground
	Local oBtnFechar
	Local nFIM_LIN, nFIM_COL

	Local cAuxSay, cAuxGet, cAuxPic, cAuxSiz, oAuxFnt
	Local nLin, nCol

	Local aFields
	Local aPosTZ9 := 0
	Local aPosTZ5 := 0
	Local lFirst := .F.
	Local nX := 0


	//--------------------
	// Busca os Detalhes
	//--------------------
	cQryAlias := GetNextAlias()

	// SELECT
	cQryLegen := "SELECT "
	cQryLegen += " TZ9.TZ9_CODIGO, "
	cQryLegen += " TZ9.TZ9_TITULO, "
	cQryLegen += " TZ9.TZ9_SUBTIT, "
	cQryLegen += " TZ5.TZ5_CODIND, "
	cQryLegen += " TZ5.TZ5_NOME, "
	cQryLegen += " TZ5.TZ5_UNIMED "
	// FROM 'TZ9'
	cQryLegen += "FROM " + RetSQLName("TZ9") + " TZ9 "
	// INNER JOIN 'TZA'
	cQryLegen += "INNER JOIN " + RetSQLName("TZA") + " TZA "
	cQryLegen += " ON ( "
	cQryLegen += "  TZA.TZA_CODGRA = TZ9.TZ9_CODIGO "
	cQryLegen += "  AND TZA.TZA_FILIAL = TZ9.TZ9_FILIAL "
	cQryLegen += "  AND TZA.TZA_CODIND = " + ValToSQL(cCodFormul) + " "
	cQryLegen += "  AND TZA.D_E_L_E_T_ <> '*' "
	cQryLegen += " ) "
	// INNER JOIN 'TZ5'
	cQryLegen += "INNER JOIN " + RetSQLName("TZ5") + " TZ5 "
	cQryLegen += " ON ( "
	cQryLegen += "  TZ5.TZ5_CODIND = TZA.TZA_CODIND "
	cQryLegen += "  AND TZ5.TZ5_MODULO = TZ9.TZ9_MODULO "
	cQryLegen += "  AND TZ5.TZ5_CODIND = " + ValToSQL(cCodFormul) + " "
	cQryLegen += "  AND TZ5.D_E_L_E_T_ <> '*' "
	cQryLegen += " ) "
	//WHERE
	cQryLegen += "WHERE "
	cQryLegen += " TZ9.TZ9_CODIGO = " + ValToSQL(cCodIndic) + " "
	cQryLegen += " AND TZ9.TZ9_FILIAL = " + ValToSQL(cCodFilial) + " "
	cQryLegen += " AND TZ9.TZ9_MODULO = " + ValToSQL(cCodModulo) + " "
	cQryLegen += " AND TZ9.D_E_L_E_T_ <> '*' "

	// Executa a Query
	cQryLegen := ChangeQuery(cQryLegen)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryLegen), cQryAlias, .T., .T.)

	//--------------------
	// Monta os Detalhes
	//--------------------
	dbSelectArea(cQryAlias)
	dbGoTop()
	If Eof()
		Help(Nil, Nil, STR0013, Nil, STR0034, 1, 0) //"Aten��o" ## "N�o foi encontrado nenhum detalhamento para este indicador."
		Return .F.
	Else
		//--------------------
		// Monta os Campos
		//--------------------
		// Define o array de campos (ID do campo ; T�tulo ; Picture ; Tamanho do objeto 'Get')
		aFields := {}
		aAdd(aFields, {"TZ9_CODIGO", "", "", 0})
		aAdd(aFields, {"TZ9_TITULO", "", "", 0})
		aAdd(aFields, {"TZ9_SUBTIT", "", "", 0})
		aAdd(aFields, {"TZ5_CODIND", "", "", 0})
		aAdd(aFields, {"TZ5_NOME"  , "", "", 0})
		aAdd(aFields, {"TZ5_UNIMED", "", "", 0})

		// Define at� qual posi��o corresponde a cade tabela no array 'aFields'
		aPosTZ9 := {1,3}
		aPosTZ5 := {4,6}

		// Calcula o tamanho dos objetos 'Get'
		For nX := 1 To Len(aFields)
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek(aFields[nX][1])
				aFields[nX][2] := AllTrim(X3Titulo())
				aFields[nX][3] := AllTrim(Posicione("SX3",2,aFields[nX][1],"X3_PICTURE"))

				aFields[nX][4] := CalcFieldSize( AllTrim(Posicione("SX3",2,aFields[nX][1],"X3_TIPO")), Posicione("SX3",2,aFields[nX][1],"X3_TAMANHO"),;
					Posicione("SX3",2,aFields[nX][1],"X3_DECIMAL"), aFields[nX][3], aFields[nX][2] )
			EndIf
		Next nX

		//--------------------
		// Monta a Janela
		//--------------------
		DEFINE MSDIALOG oDlgDet TITLE cDlgDet FROM 0,0 TO 350,600 OF oMainWnd STYLE WS_POPUPWINDOW PIXEL

			// Tamanhos Finais
			nFIM_LIN := Round( ( oDlgDet:nClientHeight * 0.50 ) ,0)
			nFIM_COL := Round( ( oDlgDet:nClientWidth * 0.50 ) ,0)

			// Background
			oBackground := fRClkBack(@oDlgDet)

				// Bot�o: Fechar
				oBtnFechar := TBtnBmp2():New(001, ((nFIM_COL*2)-020), 20, 20, "BR_CANCEL", , , , {|| oDlgDet:End() }, oBackground, OemToAnsi(STR0031)) //"Fechar"
				oBtnFechar:lCanGotFocus := .F.

				// GroupBox
				TGroup():New(010, 005, (nFIM_LIN-005), (nFIM_COL-005), STR0033, oBackground, , , .T., ) //"Detalhamento"

					oAuxFnt := TFont():New(,,,,.T.) // Fonte em Negrito
					nCol := 015 // Coluna Inicial

					//------------------------------
					// Indicador Gr�fico
					//------------------------------
					nLin := 025 // Linha Inicial
					// GroupBox
					TGroup():New(nLin, nCol, ((nFIM_LIN/2)-005), (nFIM_COL-015), STR0006, oBackground, , , .T., ) //"Indicador Gr�fico"

						// Bot�o: Visualizar o Cadastro
						TButton():New(((nFIM_LIN/2)-022), (nFIM_COL-060), STR0035, oBackground, {|| fRClkVCad("TZ9", oObjIndic) },; //"Ver Cadastro"
										040, 012, , , .F., .T., .F., , .F., , , .F.)

						// Monta os Campos
						lFirst := .T.
						For nX := aPosTZ9[1] To aPosTZ9[2]
							// Incrementa a Linha
							nLin += 015

							// SAY
							cAuxSay := "{|| '" + aFields[nX][2] + ":" + "' }"
							TSay():New(nLin, (nCol+010), &(cAuxSay), oBackground, , If(lFirst,oAuxFnt,Nil), , , , .T., CLR_BLACK, , 150, 012)

							// GET
							cAuxGet := "{|| (cQryAlias)->" + aFields[nX][1] + " }"
							cAuxPic := "'" + aFields[nX][3] + "'"
							cAuxSiz := cValToChar(aFields[nX][4])
							TGet():New((nLin-001), (nCol+050), &(cAuxGet), oBackground, &(cAuxSiz), 008, &(cAuxPic),;
										{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

							If lFirst
								lFirst := .F.
							EndIf
						Next nX

					//------------------------------
					// F�rmula
					//------------------------------
					nLin := ((nFIM_LIN/2)+005) // Linha Inicial
					// GroupBox
					TGroup():New(nLin, nCol, ((nFIM_LIN)-025), (nFIM_COL-015), "F�rmula", oBackground, , , .T., )

						// Bot�o: Visualizar o Cadastro
						TButton():New(((nFIM_LIN)-042), (nFIM_COL-060), STR0035, oBackground, {|| fRClkVCad("TZ5", oObjIndic) },; //"Ver Cadastro"
										040, 012, , , .F., .T., .F., , .F., , , .F.)

						// Monta os Campos
						lFirst := .T.
						For nX := aPosTZ5[1] To aPosTZ5[2]
							// Incrementa a Linha
							nLin += 015

							// SAY
							cAuxSay := "{|| '" + aFields[nX][2] + ":" + "' }"
							TSay():New(nLin, (nCol+010), &(cAuxSay), oBackground, , If(lFirst,oAuxFnt,Nil), , , , .T., CLR_BLACK, , 150, 012)

							// GET
							cAuxGet := "{|| (cQryAlias)->" + aFields[nX][1] + " }"
							cAuxPic := "'" + aFields[nX][3] + "'"
							cAuxSiz := cValToChar(aFields[nX][4])
							TGet():New((nLin-001), (nCol+050), &(cAuxGet), oBackground, &(cAuxSiz), 008, &(cAuxPic),;
										{|| .T. }, , , , .F., , .T./*lPixel*/, , .F., {|| .F. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "", , , , .T./*lHasButton*/)

							If lFirst
								lFirst := .F.
							EndIf
						Next nX

		ACTIVATE MSDIALOG oDlgDet CENTERED
	EndIf

	dbSelectArea(cQryAlias)
	dbCloseArea()

	// Devolve as �res
	RestArea(aAreaSX3)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} NGI7Legend
Fun��o que carrega a Legenda do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 27/08/2012

@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Function NGI7Legend(oObjIndic) // LoadFormul

	// Vari�veis do Objeto
	Local cCodIndic  := oObjIndic:cLoadIndic
	Local cCodFilial := oObjIndic:cLoadFilia
	Local cCodModulo := oObjIndic:cLoadModul
	Local cCodFormul := oObjIndic:cLoadFormu

	// Vari�veis da Legenda
	Local aLegenda := {}
	Local nLeg := 0

	// Vari�veis da Query
	Local cQryAlias := ""
	Local cQryLegen := ""

	// Vari�veis da Janela
	Local oDlgLeg
	Local cDlgLeg := OemToAnsi(STR0036) //"Legenda"
	Local oPnlLeg

	Local oPnlImg
	Local oObjImg

	Local oPnlAll
	Local oPnlMsg
	Local oPnlIte

	Local oPnlTmp
	Local cAuxSay
	Local aClrLeg

	Local nLin, nCol

	//--------------------
	// Busca a Legenda
	//--------------------
	cQryAlias := GetNextAlias()

	// SELECT
	cQryLegen := "SELECT "
	cQryLegen += " TZ9.TZ9_COR02 AS COR_SECMIN, "
	cQryLegen += " TZ9.TZ9_LEGMIN AS LEG_SECMIN, "
	cQryLegen += " TZ9.TZ9_COR03 AS COR_SECMED, "
	cQryLegen += " TZ9.TZ9_LEGMED AS LEG_SECMED, "
	cQryLegen += " TZ9.TZ9_COR04 AS COR_SECMAX, "
	cQryLegen += " TZ9.TZ9_LEGMAX AS LEG_SECMAX "
	// FROM 'TZ9'
	cQryLegen += "FROM " + RetSQLName("TZ9") + " TZ9 "
	// INNER JOIN 'TZA'
	cQryLegen += "INNER JOIN " + RetSQLName("TZA") + " TZA "
	cQryLegen += " ON ( "
	cQryLegen += "  TZA.TZA_CODGRA = TZ9.TZ9_CODIGO "
	cQryLegen += "  AND TZA.TZA_FILIAL = TZ9.TZ9_FILIAL "
	cQryLegen += "  AND TZA.TZA_CODIND = " + ValToSQL(cCodFormul) + " "
	cQryLegen += "  AND TZA.D_E_L_E_T_ <> '*' "
	cQryLegen += " ) "
	//WHERE
	cQryLegen += "WHERE "
	cQryLegen += " TZ9.TZ9_CODIGO = " + ValToSQL(cCodIndic) + " "
	cQryLegen += " AND TZ9.TZ9_FILIAL = " + ValToSQL(cCodFilial) + " "
	cQryLegen += " AND TZ9.TZ9_MODULO = " + ValToSQL(cCodModulo) + " "
	cQryLegen += " AND TZ9.D_E_L_E_T_ <> '*' "

	// Executa a Query
	cQryLegen := ChangeQuery(cQryLegen)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryLegen), cQryAlias, .T., .T.)

	dbSelectArea(cQryAlias)
	dbGoTop()
	If !Eof()
		// Armazena as Legendas
		aAdd(aLegenda, {AllTrim((cQryAlias)->COR_SECMIN), AllTrim((cQryAlias)->LEG_SECMIN)})
		aAdd(aLegenda, {AllTrim((cQryAlias)->COR_SECMED), AllTrim((cQryAlias)->LEG_SECMED)})
		aAdd(aLegenda, {AllTrim((cQryAlias)->COR_SECMAX), AllTrim((cQryAlias)->LEG_SECMAX)})

		// Se houver legenda em branco, definie um conte�do default
		aEval(aLegenda, {|x| If(Empty(x[2]), x[2] := STR0037,) }) //"N�o dispon�vel."
	End
	dbSelectArea(cQryAlias)
	dbCloseArea()

	//--------------------
	// Monta a Legenda
	//--------------------
	If Len(aLegenda) == 0
		Help(Nil, Nil, STR0013, Nil, STR0038, 1, 0) //"Aten��o" ## "N�o foi encontrado nenhuma legenda para este indicador."
		Return .F.
	Else
		//--------------------
		// Monta a Janela
		//--------------------
		DEFINE MSDIALOG oDlgLeg TITLE cDlgLeg FROM 0,0 TO 150,400 OF oMainWnd PIXEL

			// Painel pricipal do Dialog
			oPnlLeg := TPanel():New(01, 01, , oDlgLeg, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
			oPnlLeg:Align := CONTROL_ALIGN_ALLCLIENT

				// Painel da Imagem
				oPnlImg := TPanel():New(01, 01, , oPnlLeg, , , , CLR_BLACK, CLR_WHITE, 050, 100, .F., .F.)
				oPnlImg:Align := CONTROL_ALIGN_LEFT

					// Imagem
					oObjImg := TBitmap():New (0/*nTop*/, 0/*nLeft*/, 10/*nWidth*/, 10/*nHeight*/, "backgroundblacklotus"/*cResName*/, /*cBmpFile*/, ;
							   			.T./*lNoBorder*/, oPnlImg/*oWnd*/, /*bLClicked*/, /*bRClicked*/, .F./*lScroll*/, .T./*lStretch*/, ;
										/*oCursor*/, /*uParam14*/, /*uParam15*/, /*bWhen*/, .T./*lPixel*/, ;
										/*bValid*/, /*uParam19*/, /*uParam20*/, /*uParam21*/ )
					oObjImg:Align := CONTROL_ALIGN_ALLCLIENT


				// Painel da Legenda
				oPnlAll := TPanel():New(01, 01, , oPnlLeg, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
				oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT


					// Painel da Mensagem
					oPnlMsg := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 020, .F., .F.)
					oPnlMsg:Align := CONTROL_ALIGN_TOP

						// Mensagem
						@ 005,005 SAY OemToAnsi(STR0036) FONT TFont():New(,,18,,.T.) OF oPnlMsg PIXEL //"Legenda"
						@ 006.5,040 SAY "(" + OemToAnsi(STR0039 + " " + AllTrim(cCodFormul)) + ")" FONT TFont():New(,,12,,.F.) OF oPnlMsg PIXEL //"F�rmula:"
						TGroup():New(015, 01, 018, (oPnlMsg:nClientWidth*0.50), , oPnlMsg, , , .T., )

					// Painel os Itens
					oPnlIte := TPanel():New(01, 01, , oPnlAll, , , , CLR_BLACK, CLR_WHITE, 100, 020, .F., .F.)
					oPnlIte:Align := CONTROL_ALIGN_ALLCLIENT

						// Monta os Itens da Legenda
						nLin := 005
						nCol := 010
						For nLeg := 1 To Len(aLegenda)
							// Painel por tr�s da cor da se��o
							oPnlTmp := TPanel():New(nLin, nCol, , oPnlIte, , , , CLR_BLACK, CLR_BLACK, 015, 010, .F., .F.)
							// Painel da cor da se��o
							aClrLeg := NGHEXRGB( SubStr(aLegenda[nLeg][1],2) )
							TPanel():New(nLin+0.5, nCol+0.5, , oPnlIte, , , , CLR_BLACK, RGB(aClrLeg[1],aClrLeg[2],aClrLeg[3]), 014, 009, .F., .F.)

							// Descri��o da Legenda
							cAuxSay := "{|| OemToAnsi('" + aLegenda[nLeg][2] + "') }"
							TSay():New(nLin+001, nCol+020, &(cAuxSay), oPnlIte, , , , , , .T., CLR_BLACK, , 150, 012)

							// Incrementa a linha
							nLin += 015
						Next nLeg

		ACTIVATE MSDIALOG oDlgLeg CENTERED
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClkBack
Fun��o que retorna o BITMAP de fundo utilizado nos pain�is do
clique da direita sobre o Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param oPnlPai
	Objeto do Painel pai * Obrigat�rio

@return oBitmap
/*/
//---------------------------------------------------------------------
Static Function fRClkBack(oPnlPai)

	// Vari�vel do retorno
	Local oBitmap

	// Imagem do Background
	oBitmap := TBitmap():New(0/*nTop*/, 0/*nLeft*/, 10/*nWidth*/, 10/*nHeight*/, "fw_degrade_menu"/*cResName*/, /*cBmpFile*/, ;
					   			.T./*lNoBorder*/, oPnlPai/*oWnd*/, /*bLClicked*/, /*bRClicked*/, .F./*lScroll*/, .T./*lStretch*/, ;
								/*oCursor*/, /*uParam14*/, /*uParam15*/, /*bWhen*/, .T./*lPixel*/, ;
								/*bValid*/, /*uParam19*/, /*uParam20*/, /*uParam21*/ )
	oBitmap:Align := CONTROL_ALIGN_ALLCLIENT

Return oBitmap

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClkVCad
Fun��o que Visualiza o cadastro da tabela do clique da direita sobre o
Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 29/08/2012

@param cAliasCad
	Tabela do cadastro * Obrigat�rio
@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fRClkVCad(cAliasCad, oObjIndic)

	// Vari�veis de armazenamento de estado anterior
	Local aOldRotina := Nil
	Local cOldCadast := Nil
	Local lOldINCLUI := Nil
	Local lOldALTERA := Nil

	//------------------------------
	// Armazena vari�veis anteriores
	//------------------------------
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

	// Define 'aRotina'
	aAdd(aRotina, {"", "", 0, 1})
	aAdd(aRotina, {"", "", 0, 2})
	aAdd(aRotina, {"", "", 0, 3})
	aAdd(aRotina, {"", "", 0, 4})
	aAdd(aRotina, {"", "", 0, 5})

	// Define 'INCLUI' e 'ALTERA'
	INCLUI := .F.
	ALTERA := .F.

	//--------------------
	// Monta o Cadastro
	//--------------------
	MsgRun(STR0040, STR0041, {|| fRClkECad(cAliasCad, oObjIndic) }) //"Visualizando o cadastro..." ## "Por favor, aguarde..."

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

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fRClkECad
Fun��o que Executa a visualiza��o do cadastro da tabela do clique da
direita sobre o Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 29/08/2012

@param cAliasCad
	Tabela do cadastro * Obrigat�rio
@param oObjIndic
	Objeto do Indicador Gr�fico * Obrigat�rio

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fRClkECad(cAliasCad, oObjIndic)

	// Vari�veis do Objeto
	Local cCodIndic  := oObjIndic:cLoadIndic
	Local cCodFilial := oObjIndic:cLoadFilia
	Local cCodModulo := oObjIndic:cLoadModul
	Local cCodFormul := oObjIndic:cLoadFormu

	// Vari�veis da Busca do registro
	Local nIndice := 1
	Local cChave  := ""

	//------------------------------
	// Visualiza o Cadastro
	//------------------------------
	If cAliasCad == "TZ5"
		cChave := xFilial("TZ5",cCodFilial) + cCodModulo + cCodFormul

		cCadastro := OemToAnsi(STR0042) //"Cadastro da F�rmula"
	ElseIf cAliasCad == "TZ9"
		cChave := xFilial("TZ9",cCodFilial) + cCodIndic

		cCadastro := OemToAnsi(STR0043) //"Cadastro do Indicador Gr�fico"
	EndIf

	dbSelectArea(cAliasCad)
	dbSetOrder(nIndice)
	If !dbSeek(cChave)
		Help(Nil, Nil, STR0013, Nil, STR0010, 1, 0) //"Aten��o" ## "N�o foi poss�vel encontrar o cadastro."
		Return .F.
	Else
		If cAliasCad == "TZ5"
			//--- Executa a View
			NGIND5IN("TZ5", RecNo(), 2)
		ElseIf cAliasCad == "TZ9"
			// Declara as Vari�veis PRIVATE
			NGIND007VR()

			//--- Executa a View
			FWExecView(cCadastro/*cTitulo*/, "NGIND007"/*cPrograma*/, MODEL_OPERATION_VIEW/*nOperation*/, /*oDlg*/, /*bCloseOnOk*/, ;
						/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/)
		EndIf
	EndIf

Return .T.
