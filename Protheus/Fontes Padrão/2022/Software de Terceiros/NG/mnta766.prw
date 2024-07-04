#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "MNTA766.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA766
Programa de Cadastro de Notifica��es

@author  Guilherme Freudenburg
@since   30/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function MNTA766()

	Local aNGBEGINPRM := NGBEGINPRM() // Armazena as vari�veis
	Local oBrowse     := FWMBrowse():New()
	Local lRet        := .T.
	Local lRPORel17   := GetRPORelease() <= '12.1.017'

	Private lIntFin   := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S" // Verifica a integra��o com o Modulo Financeiro.

	If !lRPORel17 .And. Alltrim(Posicione("SX7",1,"TRX_CODINF"+"001","X7_REGRA")) <> 'MNT765GAT("TSH_ARTIGO")'
		ShowHelpDlg( STR0014 ,; // "Aten��o"
					{ STR0019 }, 2,; // "Essa rotina passou recentemente por uma atualiza��o importante."
					{ STR0020 }, 2 ) // "Solicita-se a aplica��o do pacote de dicion�rio indicado na FAQ MNT0124."
		lRet := .F.
	EndIf

	If lRet

		MNTA765VAR() // Realiza a cria��o das variaiveis utilizadas no dicion�rio de dados.

		oBrowse:SetAlias("TRX") // Alias da tabela utilizada
		oBrowse:SetMenuDef("MNTA766") // Nome do fonte onde esta a fun��o MenuDef
		oBrowse:SetDescription(STR0008) // "Notifica��es"
		oBrowse:SetFilterDefault("TRX_TPMULT == '" + Padr(STR0007,TAMSX3("TRX_TPMULT")[1]) + "'") // Filtra apenas Notifica��es.
		oBrowse:Activate()

	EndIf

	NGRETURNPRM(aNGBEGINPRM) // Devolve as vari�veis armazenadas

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Regras de Modelagem da gravacao, cria��o do modelo de dados padr�o
da rotina.

@author Guilherme Freudenburg
@since 30/01/2018
@version P12

@return oModel, Objeto, Modelo de dados (MVC)
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	// Cria um objeto de Modelo
	Local oModel

	// Cria a estrutura a ser usada na Model
	Local oStructTRX := FWFormStruct( 1, 'TRX', /*bAvalCampo*/,/*lViewUsado*/ )

	// Demais variaiveis.
	Local aCamposN := {} // Receber� campos que n�o ser�o apresentando em tela.
	Local lIntFin  := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S" // Indentifica a integra��o com o m�dulo Financeiro.
	Local nX       := 0

	If IsInCallStack( 'FWMileMvc' )

		cTPMT     := ' '
		cTRXMULTA := ' '
		cTPMULTA  := ' '
		cDesMulta := STR0007 //"NOTIFICACAO"
		Inclui    := .T.
		lGerMul   := .F.
		nOpc      := 3
		aParcelas := {}

	EndIf

	// Determina valor para o campo 'TRX_MULTA' ao entrar na rotina.
	oStructTRX:SetProperty( 'TRX_TPMULT' , MODEL_FIELD_INIT, {|| STR0007 } )//"NOTIFICACAO"
	// Realiza corre��o de dicion�rio ao entrar na rotina.
	oStructTRX:SetProperty( 'TRX_DTENRE' , MODEL_FIELD_VALUES, {} )

	// Retira campos da tela.
	aCamposN :=  MNT766NCPO() // Busca campos que n�o ser�o apresentando em tela.
	If Len(aCamposN) > 0
		For nX := 1 To Len(aCamposN)
			//Retira a obrigatoriedade dos campos que existe apenas no modelo.
			oStructTRX:SetProperty(Alltrim(aCamposN[nX]) , MODEL_FIELD_OBRIGAT, .F. )
		Next nX
	EndIf

	// Remove campos da tela caso n�o seja integrado ao Financeiro.
	If !lIntFin .Or. (!Inclui .And. (Empty(TRX->TRX_PREFIX) .And. Empty(TRX->TRX_TIPO) .And.;
		Empty(TRX->TRX_NUMSE2) .And. Empty(TRX->TRX_NATURE) .And. Empty(TRX->TRX_CONPAG)))
		oStructTRX:RemoveField('TRX_PREFIX')
		oStructTRX:RemoveField('TRX_TIPO')
		oStructTRX:RemoveField('TRX_NUMSE2')
		oStructTRX:RemoveField('TRX_NATURE')
		oStructTRX:RemoveField('TRX_CONPAG')
	Endif

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("MNTA766", /*bPreValid*/,  {|oModel| MNTA765TP(oModel) }/*bPosValid*/, {|oModel| MNT765GRA(oModel) }/*bFormCommit*/, /*bFormCancel*/)

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:AddFields('MULTAS', /*cOwner*/, oStructTRX, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription(STR0008) // "Notifica��es"

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('MULTAS'):SetDescription(STR0008) // "Notifica��es"

	// Defini��o de campos Memo Virtuais
	FWMemoVirtual(oStructTRX, {	{"TRX_MMSYP" , "TRX_OBS"}, {"TRX_MMCOND", "TRX_OBCOND"},{"TRX_MMRECU", "TRX_OBRECU"}} )

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).

@author Guilherme Freudenburg
@since 30/01/2018
@version P12

@return oView,  Objeto, Objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel("MNTA766")

	// Cria a estrutura a ser usada na View
	Local oStructTRX := FWFormStruct(2, "TRX", /*bAvalCampo*/, /*lViewUsado*/)

	// Interface de visualiza��o constru�da
	Local oView

	// Demais variaiveis utilizadas.
	Local nX      := 0
	Local lIntFin := SuperGetMv("MV_NGMNTFI",.F.,"N") == "S" // Indentifica integra��o com o m�dulo Financeiro.

	// Retira campos da tela.
	aCamposN :=  MNT766NCPO()
	If Len(aCamposN) > 0
		For nX := 1 To Len(aCamposN)
			oStructTRX:RemoveField(Alltrim(aCamposN[nX])) // Realiza a remo��o dos campos.
		Next nX
	EndIf

	// Remove campos da tela caso n�o seja integrado ao Financeiro.
	If !lIntFin .Or. (!Inclui .And. (Empty(TRX->TRX_PREFIX) .And. Empty(TRX->TRX_TIPO) .And.;
		Empty(TRX->TRX_NUMSE2) .And. Empty(TRX->TRX_NATURE) .And. Empty(TRX->TRX_CONPAG)))
		oStructTRX:RemoveField('TRX_PREFIX')
		oStructTRX:RemoveField('TRX_TIPO')
		oStructTRX:RemoveField('TRX_NUMSE2')
		oStructTRX:RemoveField('TRX_NATURE')
		oStructTRX:RemoveField('TRX_CONPAG')
	Endif

	// Remove campos de c�digo do Memo.
	oStructTRX:RemoveField('TRX_MMSYP')
	oStructTRX:RemoveField('TRX_MMPAGA')
	oStructTRX:RemoveField('TRX_MMCOND')
	oStructTRX:RemoveField('TRX_MMRECU')
	oStructTRX:RemoveField('TRX_MMREST')

	// Realiza corre��o de dicion�rio ao entrar na rotina.
	oStructTRX:SetProperty( 'TRX_DTENRE' , MVC_VIEW_COMBOBOX, {} )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utilizado na View
	oView:SetModel(oModel)

	// Adiciona no View um controle do tipo formul�rio (antiga Enchoice)
	oView:AddField("VIEW_TRX"/*cFormModelID*/, oStructTRX/*oViewStruct*/, "MULTAS")

	// Cria os componentes "box" horizontais para receberem elementos da View
	oView:CreateHorizontalBox("BOX_TRX"/*cID*/, 100)

	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView("VIEW_TRX"/*cFormModelID*/, "BOX_TRX")

	//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Op��es de menu padr�o.

@author Guilherme Freudenburg
@since 30/01/2019
@version P12
@return aRotina - Estrutura
	[n,1] Nome a aparecer no cabecalho
	[n,2] Nome da Rotina associada
	[n,3] Reservado
	[n,4] Tipo de Transa��o a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro posicionado
		5 - Remove o registro posicionado do Banco de Dados
		6 - Altera��o sem inclus�o de registros
		7 - C�pia
		8 - Imprimir
	[n,5] Nivel de acesso
	[n,6] Habilita Menu Funcional
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0001 Action "AxPesqui"    OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina Title STR0002 Action "MNT766IN(1)" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina Title STR0003 Action "MNT766IN(3)" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina Title STR0004 Action "MNT766IN(4)" OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina Title STR0005 Action "MNT766IN(5)" OPERATION 5 ACCESS 0 // Excluir
	ADD OPTION aRotina Title STR0006 Action "MNT766IN(6)" OPERATION 6 ACCESS 0 // Gerar Multa

	//Ponto de Entrada para adicionar bot�es no A��es Relacionadas
	If ExistBlock("MNTA7662")
		aRotina := ExecBlock("MNTA7662",.F.,.F.,{aRotina})
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MNT766NCPO
Define os campos que n�o ser�o exibidos em tela.

@author  Hugo Rizzo Pereira
@since   20/08/2011
@version P12
/*/
//-------------------------------------------------------------------
Function MNT766NCPO(nOpc)

	Local aArea 	:= GetArea()
	Local nTamTot 	:= 0
	Local nInd		:= 0
	Local cCampo	:= ""
	Local cFolder	:= ""
	Local aNgHeader	:= {}
	Local aCAMPOSN  := {}

	//Caso a op��o n�o seja 'Gerar Multa', retira os campos de pagamento e restitui��o.
	If nOpc != 6

		aNgHeader := NGHeader("TRX")
		nTamTot := Len(aNgHeader)

		For nInd := 1 To nTamTot
			cCampo  := aNgHeader[nInd,2]
			cFolder	:= Posicione("SX3",2,cCampo,"X3_FOLDER")

			//Campos do Folder 02 - Pagamento
			//Campos do Folder 05 - Restitui��o
			If cFolder == "2" .Or. cFolder == "5"
				aAdd(aCAMPOSN,cCampo)
			EndIf

		Next nInd

	Endif

	RestArea(aArea)

Return aCAMPOSN

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT766IN
Fun��o respons�vel por montagem da tela, a qual chamara o model e view.

@author Guilherme Freudenburg
@since 30/01/2019
@version P12

@param nOpc, Numerico, Operacao sendo realizada

@return Sempre Verdadeiro.
/*/
//---------------------------------------------------------------------
Function MNT766IN(nOpc)

	// Objeto que ser� instanciado o Model.
	Local oModelEx

	// Demais vari�veis utilizadas.
	Private nOpcao     := nOpc
	Private cCHANGEKEY := ""
	Private cGerSeq    := ""
	Private aParcelas  := {}
	Private lPagAutFin := .T. //Tratamento para uso da fun��o MNT765CONF em integra��o com o financeiro (FINA090.PRX)

	//Vari�veis utilizadas na montagem da tela (MNTA765)
	If nOpcao == 6
		cTPMT := NGSEEK("TSH",TRX->TRX_CODINF,1,"TSH_FLGTPM")
	EndIf
	cDesMulta := STR0007 //"NOTIFICACAO"
	cTRXMULTA := "" // Limpa vari�vel de multas.

	oModelEx := FWViewExec():New() // Inst�ncia o modelo de dados.

	If nOpcao == 6 // Caso seja op��o 'Gerar Multa'

		cTRXMULTA  := TRX->TRX_MULTA  // Alimenta vari�vel com o valor da Multa.
		cOldCodInf := TRX->TRX_CODINF // Alimenta a vari�vel com o c�digo do tipo da Multa.
		cDesMulta  := If(cTPMT == "1", STR0011, STR0012) //"TRANSITO"####"PRODUTO PERIGOSO"
		nOpcao     := 4 // Caso seja op��o 'Gerar Multa' altera o nOpca para o valor correto 4 - Altera��o.
		lGerMul    := .T. // Determina que est� no processo de gera��o de multa.

		MNT765VARM(nOpcao) // Realiza a inicializa��o das variaiveis.

		oModelEx:SetTitle(STR0010) // "Gera��o de Multa"
		oModelEx:SetSource("MNTA765")

	Else // Caso seja 'Notifica��es'

		lGerMul := .F. // Determina que n�o est� no processo de gera��o de multa.
		
		oModelEx:SetTitle(STR0008) // 'Notifica��es'
		oModelEx:SetSource("MNTA766")

	EndIf

	oModelEx:SetModal(.F.)
	oModelEx:SetOperation(nOpcao) // Determina a op��o selecionada.
	oModelEx:OpenView(.T.)

Return .T.
