#INCLUDE	"Protheus.ch"
#INCLUDE	"FWMVCDEF.CH"
#INCLUDE	"MNTA616.ch"

//---------------------------------------------------------------------
/*/ MNTA616
Cadastro complementar da Integra��o ExcelBr.

TABELAS:
TQF - Postos
TQI - Tanques
TQJ - Bombas
TR0 - Integra��o ExcelBr

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA616()

	//------------------------------
	// Armazena as vari�veis
	//------------------------------
	Local aNGBEGINPRM := NGBEGINPRM()

	Local oBrowse // Vari�vel do Browse

	Private cCadastro := OemToAnsi(STR0001) // "Integra��o ExcelBr"

	Private aVCpoTQF := {} // Vari�vel de exce��o de campos na View da TQF
	Private aVCpoTR0 := {} // Vari�vel de exce��o de campos na View da TR0

	// Vari�veis Private utilizadas nas consultas SXB
	Private cPosto  := ""
	Private cLoja   := ""
	Private cTanque := ""

	//-------------------------------
	// Valida a execu��o do programa
	//-------------------------------
	If !MNTA616OP()
		Return .F.
	EndIf

	// Monta o array com a exce��o de campos
	fCposExcep()

	//----------------
	// Monta o Browse
	//----------------
	dbSelectArea("TQF")
	dbSetOrder(1)
	dbGoTop()

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()

		// Defini��o da tabela do Browse
		oBrowse:SetAlias("TQF")

		// Descri��o do Browse
		oBrowse:SetDescription(cCadastro)

		// Menu Funcional relacionado ao Browse
		oBrowse:SetMenuDef("MNTA616")

	// Ativa��o da Classe
	oBrowse:Activate()
	//----------------
	// Fim do Browse
	//----------------

	//------------------------------
	// Devolve as vari�veis armazenadas
	//------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	// Vari�vel do Menu
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MNTA616" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MNTA616" OPERATION 4 ACCESS 0 // "Convers�o DE/PARA"
	ADD OPTION aRotina TITLE STR0004 ACTION "MNTA616EXT" OPERATION 4 ACCESS 0 // "Informa��es Extras"

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616OP
Valida o programa, verificando se � poss�vel execut�-lo. (MNTA616Open)
* Est� fun��o pode ser utilizada por outras rotinas.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return .T. caso o programa possa ser executado; .F. no caso de uma falha e o programa n�o puder ser executado
/*/
//---------------------------------------------------------------------
Function MNTA616OP()

	Local aTables := {}

	Local lParam  := ( SuperGetMv("MV_NGDPST9",.F.,"0") == "2" )
	Local cMotTra := AllTrim(SuperGetMv("MV_NGMOTTR"))

	Private lHelp := .F. // Vari�vel private para o fun��o 'FWAliasInDic()' mostrar (.T.) ou nao (.F.) uma mensagem de Help caso a tabela nao exista

	DbSelectArea("TTX")
	DbSetOrder(01)
	If !DbSeek(xFilial("TTX")+(cMotTra))
		MsgInfo(STR0022+CRLF+CRLF+STR0023) //"N�o existe cadastrado um registro de Motivo de Transfer�ncia igual ao definido no parametro MV_NGMOTTR (C�digo do Motivo de Transfer�ncias de Combust�vel)."##"Configure corretamente o par�metro para continuar."
		Return .F.
	EndIf

	If !lParam
		MsgInfo(STR0024) //"Para o correto funcionamento do processo ExcelBr, o par�metro MV_NGDPST9 que indica se podera duplicar c�digo do Bem deve estar configurado com o valor 2(Por Filial)."
		Return .F.
	EndIf

	// Verifica se o compartilhamento dessas tabelas (TQF e TR0) est�o iguais.
	aTables := {"TQF", "TQI", "TQJ", "TR0"}
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

	//Exce��o de campos na View da tabela TR0
	aVCpoTQF := {}

	//Exce��o de campos na View da tabela TR0
	aVCpoTR0 := {}

	aAdd(aVCpoTR0, "TR0_FILIAL")
	aAdd(aVCpoTR0, "TR0_CODPOS")
	aAdd(aVCpoTR0, "TR0_LOJPOS")

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
@since 30/01/2012

@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruTQF := FWFormStruct(1, "TQF", /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTR0 := FWFormStruct(1, "TR0", /*bAvalCampo*/, /*lViewUsado*/)

	// Modelo de dados que ser� constru�do
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA616", /*bPreValid*/, /*bPosValid*/, /*bFormCommit*/, /*bFormCancel*/)

		//--------------------------------------------------
		// Componentes do Modelo
		//--------------------------------------------------

		// Adiciona ao modelo um componente de Formul�rio Principal
		oModel:AddFields("TQFMASTER"/*cID*/, /*cIDOwner*/, oStruTQF/*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/) // Cadastro do Posto

		// Adiciona ao modelo um componente de Grid, com o "TQFMASTER" como Owner
		oModel:AddGrid("TR0TERMINAL"/*cID*/, "TQFMASTER"/*cIDOwner*/, oStruTR0/*oModelStruct*/, /*bLinePre*/, {|oModelGrid| fMLinTermi(oModelGrid) }/*bLinePost*/, /*bPre*/, {|oModelGrid| fMAllTermi(oModelGrid) }/*bPost*/, /*bLoad*/) // Rela��o Terminal x Bomba

			// Define a Rela��o do modelo do Terminal com o Principal (Postos)
			oModel:SetRelation("TR0TERMINAL"/*cIDGrid*/,;
								{ {"TR0_FILIAL", 'xFilial("TR0")'}, {"TR0_CODPOS", "TQF_CODIGO"}, {"TR0_LOJPOS", "TQF_LOJA"} }/*aConteudo*/,;
								TR0->( IndexKey(1) )/*cIndexOrd*/)

		// Adiciona a descri��o do Modelo de Dados (Geral)
		oModel:SetDescription(STR0001/*cDescricao*/) // "Integra��o ExcelBr"

			//--------------------------------------------------
			// Defini��es do Modelo do Posto
			//--------------------------------------------------

			// Adiciona a descri��o do Modelo de Dados TQF
			oModel:GetModel("TQFMASTER"):SetDescription("Posto"/*cDescricao*/)

				// Define que o modelo n�o ser� atualizado / gravado
				oModel:GetModel("TQFMASTER"):SetOnlyQuery(.T.)

				// Define que o Modelo � somente de visualiza��o
				oModel:GetModel("TQFMASTER"):SetOnlyView(.T.)

			//--------------------------------------------------
			// Defini��es do Modelo do Terminal X Bomba
			//--------------------------------------------------

			// Adiciona a descri��o do Modelo de Dados TR0
			oModel:GetModel("TR0TERMINAL"):SetDescription(STR0005/*cDescricao*/) // "Rela��o Terminal x Bomba"

				// Altera as propriedades do Modelo
				oStruTR0:SetProperty("*", MODEL_FIELD_WHEN, {|oModel, cCampo, xValue, nLine| fLoadVars(oModel, cCampo, xValue, nLine) })

				// Define que o Modelo n�o � obrigat�rio
				oModel:GetModel("TR0TERMINAL"):SetOptional(.T.)

				// Define qual a chave �nica por Linha no browse
				oModel:GetModel("TR0TERMINAL"):SetUniqueLine({"TR0_TERMIN", "TR0_BOMPOS"})

		//------------------------------
		// Defini��o de When dos Campos Empresa e Filial
		//------------------------------
		//oModel:AddRules( 'TR0TERMINAL', 'TR0_BOMPOS', 'TR0TERMINAL', 'TR0_TANPOS', 3 )

Return oModel

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
@since 30/01/2012

@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("MNTA616")

	// Cria a estrutura a ser usada na View
	Local oStruTQF := FWFormStruct(2, "TQF", {|cCampo| fStructCpo(cCampo, "TQF") }/*bAvalCampo*/, /*lViewUsado*/)
	Local oStruTR0 := FWFormStruct(2, "TR0", {|cCampo| fStructCpo(cCampo, "TR0") }/*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualiza��o constru�da
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados ser� utilizado na View
		oView:SetModel(oModel)

		//--------------------------------------------------
		// Componentes da View
		//--------------------------------------------------

		// Adiciona no View um controle do tipo formul�rio (antiga Enchoice)
		oView:AddField("VIEW_TQFMASTER"/*cFormModelID*/, oStruTQF/*oViewStruct*/, "TQFMASTER"/*cLinkID*/, /*bValid*/)

		// Adiciona no View um controle do tipo Grid (antiga Getdados)
		oView:AddGrid("VIEW_TR0TERMINAL"/*cFormModelID*/, oStruTR0/*oViewStruct*/, "TR0TERMINAL"/*cLinkID*/, /*bValid*/)

		// Cria os componentes "box" horizontais para receberem elementos da View
		oView:CreateHorizontalBox("BOX_POSTO"  /*cID*/, 040/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
		oView:CreateHorizontalBox("BOX_EXCELBR"/*cID*/, 060/*nPercHeight*/, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)

		// Relaciona o identificador (ID) da View com o "box" para exibi��o
		oView:SetOwnerView("VIEW_TQFMASTER"  /*cFormModelID*/, "BOX_POSTO"/*cIDUserView*/)
		oView:SetOwnerView("VIEW_TR0TERMINAL"/*cFormModelID*/, "BOX_EXCELBR"/*cIDUserView*/)

			// Define os T�tulos das Views
			oView:EnableTitleView("VIEW_TQFMASTER"  , /*cTitle*/, /*nColor*/)
			oView:EnableTitleView("VIEW_TR0TERMINAL", /*cTitle*/, /*nColor*/)

		//--------------------------------------------------
		// Defini��es finais da View
		//--------------------------------------------------

		// Retira da estrutura da View os campos de rela��o com o Pai ('SetRelation()')
		oStruTR0:RemoveField("TR0_FILIAL")
		oStruTR0:RemoveField("TR0_CODPOS")
		oStruTR0:RemoveField("TR0_LOJPOS")

		// A��es de P�s-Valida��o dos Campos da View
		oView:SetFieldAction("TR0_TANPOS"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)
		oView:SetFieldAction("TR0_BOMPOS"/*cIDField*/, {|oView, cIDView, cField, xValue| fFieldAction(oView, cIDView, cField, xValue) }/*bAction*/)

		// Define se pode inicializar a View
		oView:SetViewCanActivate({|| fVActivate() })

		//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
		NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} fFieldAction
Define uma a��o a ser executada quando um campo � Alterado/Validado
com sucesso.

@author Wagner Sobral de Lacerda
@since 29/02/2012

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

	Local oModelTR0 := oView:GetModel("TR0TERMINAL")

	If cField == "TR0_TANPOS"
		oModelTR0:LoadValue('TR0_BOMPOS',Space(TAMSX3("TR0_BOMPOS")[1]))
		oModelTR0:LoadValue('TR0_TERMIN',Space(TAMSX3("TR0_TERMIN")[1]))
	ElseIf cField == "TR0_BOMPOS"
		oModelTR0:LoadValue('TR0_TERMIN',Space(TAMSX3("TR0_TERMIN")[1]))
	EndIf

	oView:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fStructCpo
Valida os campos da estrutura do Modelo ou View.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param cCampo
	Campo atual sendo verificado na estrutura * Obrigat�rio
@param cEstrutura
	Tabela da estrutura sendo carregada * Obrigat�rio

@return .T. caso o campo seja valido; .F. se nao for valido
/*/
//---------------------------------------------------------------------
Static Function fStructCpo(cCampo, cEstrutura)

	Local aExcecao := {}

	// Recebe os campos de exce��o
	If cEstrutura == "TQF"
		aExcecao := aClone( aVCpoTQF )
	ElseIf cEstrutura == "TR0"
		aExcecao := aClone( aVCpoTR0 )
	EndIf

	// Valida o Campo
	If aScan(aExcecao, {|x| AllTrim(x) == AllTrim(cCampo) }) > 0
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadVars
Carrega as Vari�veis Private da rotina.

@author Wagner Sobral de Lacerda
@since 31/01/2012

@param oModelGrid
	Objeto do Grid * Opcional
	Default: Nil

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadVars(oModelGrid, cCampo, xValue, nLine)

	Default oModelGrid := Nil

	// Carrega as vari�veis padr�es da rotina
	cPosto  := TQF->TQF_CODIGO
	cLoja   := TQF->TQF_LOJA
	cTanque := ""

	// Carrega as vari�veis do Grid
	If ValType(oModelGrid) == "O"
		If oModelGrid:GetID() == "TR0TERMINAL"
			If oModelGrid:GetLine() > 0
				cTanque := oModelGrid:GetValue("TR0_TANPOS")
			EndIf
		EndIf
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
-> Se puder, j� carrega as vari�veis necess�rias.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@return .T./.F.
/*/
//---------------------------------------------------------------------
Static Function fVActivate()

	// Carrega Vari�veis
	fLoadVars()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fMLinTermi
P�s-valida��o da Linha do browse de Terminal X Bomba.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param oModelGrid
	Objeto do modelo de dados do browse * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMLinTermi(oModelGrid)

	Local aAreaTR0   := TR0->( GetArea() )
	Local aSaveLines := FWSaveRows()

	Local oModelTR0 := oModelGrid

	Local cTitBOMPOS := ""
	Local cTitTERMIN := ""

	Local cLinTanque := ""
	Local cLinBomba  := ""
	Local cLinTermin := ""

	Local cMsgErro  := ""
	Local nQtdPosto := 0
	Local nQtdDiff  := 0

	Local lRetorno := .T.

	//--------------------
	// Valida a Linha
	//--------------------
	If !oModelTR0:IsDeleted() .And. (oModelTR0:IsInserted() .Or. oModelTR0:IsUpdated())
		// Busca o t�tulo dos campos para a mensagem em tela
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek("TR0_BOMPOS")
			cTitBOMPOS := AllTrim( X3Titulo() )
		EndIf
		If dbSeek("TR0_TERMIN")
			cTitTERMIN := AllTrim( X3Titulo() )
		EndIf

		// Recebe os valores da linha
		cLinTanque := oModelTR0:GetValue("TR0_TANPOS")
		cLinBomba  := oModelTR0:GetValue("TR0_BOMPOS")
		cLinTermin := oModelTR0:GetValue("TR0_TERMIN")

		// Valida o tanque
		If lRetorno
			If !MNTA616TAN(2, cLinTanque)
				lRetorno := .F.
			EndIf
		EndIf

		// Valida a bomba
		If lRetorno
			If !MNTA616BOM(2, cLinBomba)
				lRetorno := .F.
			EndIf
		EndIf

		// Verifica duplicidade de registros na base
		If lRetorno
			If oModelTR0:IsInserted() .Or. oModelTR0:IsUpdated()
				dbSelectArea("TR0")
				dbSetOrder(1)
				dbSeek(xFilial("TR0") + cLinTermin + cLinBomba, .T.)
				While !Eof() .And. TR0->TR0_FILIAL == xFilial("TR0") .And. TR0->TR0_TERMIN == cLinTermin .And. TR0->TR0_BOMPOS == cLinBomba

					If TR0->TR0_CODPOS == M->TQF_CODIGO
						nQtdPosto++
					Else
						nQtdDiff++
					EndIf

					dbSelectArea("TR0")
					dbSkip()
				End

				If Empty(cMsgErro)
					// Se for um linha nova, n�o pode haver nenhum registro igual
					If oModelTR0:IsInserted()
						lRetorno := ( nQtdPosto == 0 .And. nQtdDiff == 0 )
					Else // Se for uma linha atualizada, s� pode haver um registro igual E PARA O MESMO POSTO, caso contr�rio, est� sendo duplicado
						lRetorno := ( nQtdPosto <= 1 .And. nQtdDiff == 0 )
					EndIf
				EndIf

				// Mostra a Mensagem de Erro
				If !lRetorno
					Help(" ", 1, STR0006, Nil,STR0007 + CRLF + cTitBOMPOS+": '" + cLinBomba + "'" + CRLF + cTitTERMIN+": '" + cLinTermin + "'",1, 0)
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaTR0)
	FWRestRows(aSaveLines)

Return lRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fMAllTermi
P�s-valida��o da 'TudoOK' do browse de Terminal X Bomba.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param oModelGrid
	Objeto do modelo de dados do browse * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fMAllTermi(oModelGrid)

	Local aAreaTR0   := TR0->( GetArea() )
	Local aSaveLines := FWSaveRows()

	Local oModelTR0 := oModelGrid
	Local nQuantid  := oModelTR0:Length()
	Local nX := 0, nScan := 0
	Local aTerminal  := {} // Vari�vel para armazenar os Terminais e as quantidades de Bombas para cada terminal
	Local cTerminal  := ""
	Local nMaxBombas := 9
	Local nPosTERMIN := 1 // Posi��o do Terminal no array 'aTerminal'
	Local nPosQUANTI := 2 // Posi��o da Quantidade de Bombas no array 'aTerminal'

	Local lRetorno := .T.

	//------------------------------
	// Valida todas as linhas
	//------------------------------
	If lRetorno
		If nQuantid > 0
			For nX := 1 To nQuantid
				If !lRetorno
					Exit
				EndIf

				oModelTR0:GoLine(nX)

				If !oModelTR0:IsDeleted()
					cTerminal := oModelTR0:GetValue("TR0_TERMIN")

					// Valida a Linha
					If !fMLinTermi(oModelTR0)
						lRetorno := .F.
					EndIf

					// Adiciona o Terminal para valida��o posterior
					nScan := aScan(aTerminal, {|x| x[nPosTERMIN] == cTerminal })
					If nScan == 0
						aAdd(aTerminal, {cTerminal, 1})
					Else
						aTerminal[nScan][nPosQUANTI]++
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	//------------------------------
	// Valida a quantidade de Bombas por Terminal (cada terminal pode controlar no m�ximo 9 bombas)
	//------------------------------
	If lRetorno
		// Recebe os Terminais j� cadastrados na base de dados (filtrando pelos informados em tela), e a quantidade de bombas relacionadas
		For nX := 1 To Len(aTerminal)
			dbSelectArea("TR0")
			dbSetOrder(1)
			dbSeek(xFilial("TR0") + aTerminal[nX][nPosTERMIN])
			While !Eof() .And. TR0->TR0_FILIAL == xFilial("TR0") .And. TR0->TR0_TERMIN == aTerminal[nX][nPosTERMIN]

				aTerminal[nX][nPosQUANTI]++

				dbSelectArea("TR0")
				dbSkip()
			End
		Next nX

		nScan := aScan(aTerminal, {|x| x[nPosQUANTI] > nMaxBombas })
		If nScan > 0
			Help(" ", 1, STR0006, Nil,; // "Aten��o"
				STR0008 + " '" + AllTrim(aTerminal[nScan][nPosTERMIN]) + "'." + CRLF + ; // "Inconsist�ncia para o Terminal"
				STR0009 + " " + cValToChar(nMaxBombas) + ".",; // "Quantidade m�xima de bombas que cada terminal pode controlar:"
				1, 0)
			lRetorno := .F.
		EndIf
	EndIf

	RestArea(aAreaTR0)
	FWRestRows(aSaveLines)

Return lRetorno

/*/
############################################################################################
##                                                                                        ##
## FUN��ES UTILIZADAS NO DICION�RIO DE DADOS / MODELO DE DADOS                            ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616TAN
Fun��o para validar o Tanque do Posto.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param nTipo
	Indica se a valida��o �: * Obrigat�rio
	1 - Pela MEM�RIA
	2 - Pelo par�metro
@param cConteudo
	Conte�do da coluna Tanque.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function MNTA616TAN(nTipo, cConteudo)

	Default nTipo := 1
	//Default cConteudo := ""

	// Receba o conte�do do Tanque
	If nTipo == 1
		cTanque := M->TR0_TANPOS
	Else
		cTanque := cConteudo
	EndIf

	// Se for um Posto Interno
	If M->TQF_TIPPOS == "2"
		// Valida o conte�do do Tanque
		If !ExistCpo("TQI", M->TQF_CODIGO + M->TQF_LOJA + cTanque, 1)
			Return .F.
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616BOM
Fun��o para validar a Bomba do Posto.

@author Wagner Sobral de Lacerda
@since 30/01/2012

@param nTipo
	Indica se a valida��o �: * Obrigat�rio
	1 - Pela MEM�RIA
	2 - Pelo par�metro
@param cConteudo
	Conte�do da coluna Bomba.

@return .T./.F.
/*/
//---------------------------------------------------------------------
Function MNTA616BOM(nTipo, cConteudo)

	Local aBombas   := {"1", "2", "3", "4", "5", "6", "7", "8", "9"}
	Local cBomba    := ""
	Local cMsg      := ""
	Local nTamBomba := 1
	Local nX := 0

	Default nTipo := 1
	Default cConteudo := ""

	// Receba o conte�do da Bomba
	If nTipo == 1
		cBomba := PadR(M->TR0_BOMPOS,TAMSX3("TR0_BOMPOS")[1])
	Else
		cBomba := PadR(cConteudo,TAMSX3("TR0_BOMPOS")[1])
	EndIf


	// Se for um Posto Interno
	If M->TQF_TIPPOS == "2"
		// Valida o conte�do da Bomba
		If !ExistCpo("TQJ", PadR(M->TQF_CODIGO,TAMSX3("TQJ_CODPOS")[1]) + PadR(M->TQF_LOJA,TAMSX3("TQJ_LOJA")[1]) + PadR(cTanque,TAMSX3("TQJ_TANQUE")[1]) + cBomba, 1)
			Return .F.
		EndIf
	EndIf

	// Valida o tamanho (caractere) da Bomba de acordo com o sistema GTFrota
	If Len( AllTrim(cBomba) ) > nTamBomba
		cMsg := STR0010 + CRLF // "De acordo com o sistema GTFrota, a Bomba deve possuir apenas um d�gito."

		Help(" ", 1, STR0006, Nil, cMsg, 1, 0) // "Aten��o"
		Return .F.
	EndIf

	// Valida as bombas poss�veis de acordo com o sitema GTFrota
	If aScan(aBombas, {|x| x == AllTrim(cBomba) }) == 0
		cMsg := STR0011 + " " + CRLF // "De acordo com o sistema GTFrota, as Bombas poss�veis s�o:"
		For nX := 1 To Len(aBombas)
			cMsg += "'" + aBombas[nX] + "'"

			If nX < Len(aBombas)
				cMsg += ";"
			Else
				cMsg += "." + CRLF
			EndIf
		Next nX
			ShowHelpDlg(STR0006,{cMsg},1,;  //"Aten��o"
					  {STR0020,""},1) //"Informe uma bomba v�lida."
		Return .F.
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES DAS INFORMA��ES EXTRAS                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA616EXT
Fun��o para definir o conte�do das Informa��es Extras.

@author Wagner Sobral de Lacerda
@since 05/06/2012

@return .T.
/*/
//---------------------------------------------------------------------
Function MNTA616EXT(nTipo, cConteudo)

	// Salva as �reas atuais
	Local aAreaSX3 := SX3->( GetArea() )
	Local aAreaTR0 := TR0->( GetArea() )

	// Vari�veis da janela
	Local oDlgExtra
	Local cDlgExtra := OemToAnsi(STR0004) // "Informa��es Extras"
	Local lDlgExtra := .F.
	Local oPnlExtra

	Local oPnlMsg
	Local oPnlDef

	Local oTmpGroup
	Local oTmpCombo
	Local aExtras := {}
	Local nExtra := 0

	Private cTerminalE := ""
	Private cBombalE   := ""

	//--- Define array de informa��es extras
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("TR0_EXTRA")
	aExtras := StrTokArr( AllTrim(X3CBox()), ";" )

	//--- Define cote�do inicial
	// Terminal
	dbSelectArea("TR0")
	dbSetOrder(1) // Filial + Terminal + Bomba
	If dbSeek(xFilial("TR0") + "#")
		cTerminalE := TR0->TR0_EXTRA
	Else
		cTerminalE := SubStr(aExtras[1],1,1)
	EndIf
	// Bomba
	dbSelectArea("TR0")
	dbSetOrder(2) // Filial + Bomba + Terminal
	If dbSeek(xFilial("TR0") + "#")
		cBombaE    := TR0->TR0_EXTRA
	Else
		cBombaE    := SubStr(aExtras[1],1,1)
	EndIf

	//----------
	// Monta
	//----------
	DEFINE MSDIALOG oDlgExtra TITLE cDlgExtra FROM 0,0 TO 300,600 OF oMainWnd PIXEL

		// Pain�l principal do Dialog
		oPnlExtra := TPanel():New(01, 01, , oDlgExtra, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlExtra:Align := CONTROL_ALIGN_ALLCLIENT

			// Pain�l da mensagem
			oPnlMsg := TPanel():New(01, 01, , oPnlExtra, , , , CLR_BLACK, CLR_WHITE, 100, 070)
			oPnlMsg:Align := CONTROL_ALIGN_TOP

				// Mensagem
				@ 010,015 SAY OemToAnsi(STR0012) COLOR CLR_GRAY OF oPnlMsg PIXEL // "Quando na importa��o de abastecimentos da ExcelBr via pain�l On-Line, s�o apresentadas 5 (cinco)"
				@ 020,005 SAY OemToAnsi(STR0013) COLOR CLR_GRAY OF oPnlMsg PIXEL // "informa��es extras para a digita��o do usu�rio."
				@ 030,015 SAY OemToAnsi(STR0014) COLOR CLR_GRAY OF oPnlMsg PIXEL // "Para o Protheus, � necess�rio saber em quais destas informa��es o usu�rio digitou o Terminal e a"
				@ 040,005 SAY OemToAnsi(STR0015) COLOR CLR_GRAY OF oPnlMsg PIXEL // "Bomba do posto de destino na realiza��o de uma Transfer�ncia de Combust�vel."
				@ 055,015 SAY OemToAnsi(STR0016) COLOR CLR_RED OF oPnlMsg PIXEL // "Favor informar a rela��o de Terminal e Bomba nas informa��es extras:"

			// Pain�l da defini��o da rela��o Terminal x Bomba com as Informa��es Extras
			oPnlDef := TPanel():New(01, 01, , oPnlExtra, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlDef:Align := CONTROL_ALIGN_ALLCLIENT

				// Group Box
				oTmpGroup := TGroup():New(01, 01, 10, 10, STR0017, oPnlDef, , , .T.) // "Terminal x Bomba nas Informa��es Extras"
				oTmpGroup:Align := CONTROL_ALIGN_ALLCLIENT

				// Terminal Destino
				@ 025,010 SAY OemToAnsi(STR0018) COLOR CLR_HBLUE OF oPnlDef PIXEL // "Terminal de Destino � representado pela coluna:"
				oTmpCombo := TComboBox():New(024, 135, {|u| If(PCount() > 0, cTerminalE := u, cTerminalE) }, aExtras, 080, 008, oPnlDef, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
				oTmpCombo:bHelp := {|| Help("TR0_TERMIN") }

				// Bomba Destino
				@ 040,010 SAY OemToAnsi(STR0019) COLOR CLR_HBLUE OF oPnlDef PIXEL // "Bomba de Destino � representado pela coluna:"
				oTmpCombo := TComboBox():New(039, 135, {|u| If(PCount() > 0, cBombaE := u, cBombaE) }, aExtras, 080, 008, oPnlDef, , /*bChange*/, /*bValid*/, , , .T./*lPixel*/, , , , {|| .T. }/*bWhen*/)
				oTmpCombo:bHelp := {|| Help("TR0_BOMPOS") }

	ACTIVATE MSDIALOG oDlgExtra ON INIT EnchoiceBar(oDlgExtra, {|| lDlgExtra := .T., oDlgExtra:End() }, {|| lDlgExtra := .F., oDlgExtra:End() }) CENTERED

	// Se confirmou
	If lDlgExtra
		//--- Grava a posi��o do Terminal
		dbSelectArea("TR0")
		dbSetOrder(1) // Filial + Terminal + Bomba
		If !dbSeek(xFilial("TR0") + "#")
			RecLock("TR0", .T.)
			TR0->TR0_FILIAL := xFilial("TR0")
			TR0->TR0_CODPOS := ""
			TR0->TR0_LOJPOS := ""
			TR0->TR0_TANPOS := ""
			TR0->TR0_BOMPOS := ""
			TR0->TR0_TERMIN := "#"
		Else
			RecLock("TR0", .F.)
		EndIf
		TR0->TR0_EXTRA := cTerminalE // Campo utilizada para indicar a Informa��o Extra
		MsUnlock("TR0")

		//--- Grava a posi��o da Bomba
		dbSelectArea("TR0")
		dbSetOrder(2) // Filial + Bomba + Terminal
		If !dbSeek(xFilial("TR0") + "#")
			RecLock("TR0", .T.)
			TR0->TR0_FILIAL := xFilial("TR0")
			TR0->TR0_CODPOS := ""
			TR0->TR0_LOJPOS := ""
			TR0->TR0_TANPOS := ""
			TR0->TR0_BOMPOS := "#"
			TR0->TR0_TERMIN := ""
		Else
			RecLock("TR0", .F.)
		EndIf
		TR0->TR0_EXTRA := cBombaE // Campo utilizada para indicar a Informa��o Extra
		MsUnlock("TR0")
	EndIf

	//Devolve as �reas
	RestArea(aAreaSX3)
	RestArea(aAreaTR0)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT616FILXB
Fun��o para definir o conte�do das Informa��es Extras.

@author Wagner Sobral de Lacerda
@since 05/06/2012

@return
/*/
//---------------------------------------------------------------------
Function MNT616FILXB()
Local lRet := .F.

cTanque := PadR(cTanque	,TAMSX3("TQJ_TANQUE")[1])
cPOSTO 	:= PadR(TQF->TQF_CODIGO	,TAMSX3("TQJ_CODPOS")[1])
cLOJA 	:= PadR(TQF->TQF_LOJA	,TAMSX3("TQJ_LOJA")[1])

lRet := TQJ->TQJ_CODPOS == cPOSTO .AND. TQJ->TQJ_LOJA == cLOJA .AND. TQJ->TQJ_TANQUE == cTANQUE
If lRet
	If  IsInCallStack( "MNTA616" )
		lRet := AllTrim( TQJ->TQJ_BOMBA ) $ "1/2/3/4/5/6/7/8/9"
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet
