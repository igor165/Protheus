#INCLUDE "TOTVS.CH"
#INCLUDE "TJURANEXO.CH"

#DEFINE SW_SHOW	5	 // Mostra na posição mais recente da janela

//Function Dummy
Function __TJurAnexo()
	ApMsgInfo( I18n(STR0002, {"TJurAnexo"}) )	//"Utilizar Classe ao invés da função #1"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe de anexos

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
CLASS TJurAnexo

	// Propriedades Anexos - Elementos de Formulário
	Data oForm              // Formulário
	Data oSelect            // Objeto TJurBrowse da tela de anexos
	Data oFont              // Fonte
	Data oTreeFolder        // Arvore de pastas
	Data aButton            // Botões a serem utilizados
	Data aColunas           // Colunas do Grid
	Data aHeader            // Colunas obrigatórias que não estão na estrutura da tabela
	Data aReqCols           // Colunas obrigatórias que não são mostradas na tela
	Data aColsRem           // Colunas a serem removidas
	Data cEntidade          // Entidade que chama a tela de anexo
	Data cFilEnt            // Código da filial da entidade (NUM_FILENT)
	Data cCodEnt            // Código da entidade (NUM_CENTID)
	Data cCajuri            // Código do assunto jurídico
	Data cTitulo            // Titulo do Form
	Data cCSSEdit           // CSS dos Edits
	Data cCSSButton         // CSS dos Botões
	Data lShowUrl           // Mostra url (S/N)
	Data cHasSecRel         // String com as tabelas de relação secundária. Ex: O0N tem relacionamento com O0M,
	                        // que por sua vez tem relacionamento com a NSZ.
	                        // Estrutura: Tab2ºNivel[Tab1ºNivel]| Tab2ºNivel[Tab1ºNivel]|...
	Data cUsuario			   //Usuario para acesso ao Fluig
	Data cSenha			   //Senha para acesso ao Fluig
	Data cEmpresa			   //Empresa para acesso ao Fluig
	Data cUrl				   //Url para acesso ao Fluig
	Data cDocumento		   //Documento que esta sendo manipulado
	Data cLinkCaso		   //Link do caso do fluig NZ7_LINK
	Data cNUMCod           // Código do anexo que está sendo incluido/excluido

	// Propriedades Dados
	Data cFieldsSQL         // Campos do Select
	Data cFromSQL           // From
	Data cWhereSQL          // Where
	Data cCliLoja           // Código Cliente + Loja
	Data cCasoCliente       // Caso
	Data cTipoAsj           // Tipo de Assunto Juridico
	Data cMarca             // Marca do Grid
	Data cPesquisa          // Termo de pesquisa

	// Propriedades Arquivo
	Data aArquivos          // Arquivos selecionados
	Data nOperation         // Operação dos anexos
	Data lSalvaTemp         // Verifica se o anexo será salvo na pasta temporária

	Data cErro              // Descrição do erro
	Data nQtdDblClick       // Quantidade de duplo cliques em tela.
	                        // Variável utilizada para prevenir a ativação do duplo clique no primeiro clique duplo em tela.

	Data lHtml              // Verifica se a utilização é via HTML
	Data lInterface         // Verifica se demonstra a Interface
	Data lAnxLegalDesk      // Verifica se a utilização é via LegalDesk - SIGAPFS
	Data lEntPFS            // Indica se é uma entidade do SIGAPFS - Usado devido a integração com LEGALDESK

	Data cSubPasta          // Subpasta do anexo
	// Setters e Getters
	Method SetButton(aBtnPad)
	Method GetButton()
	Method SetShowUrl(lShow)
	Method RemoveColGrid(cNomField)
	Method TreeRightBtn()
	Method SetSecRelac(cTabSecRel)
	Method SetOperation(cOp)
	Method GetOperation()
	Method GetRegSelecionado()
	Method SetErro()
	Method GetErro()
	Method GetCajuri()
	Method SetUsuario(cUsuario)
	Method GetUsuario()
	Method SetSenha(cSenha)
	Method GetSenha()
	Method SetEmpresa(cEmpresa)
	Method GetEmpresa()
	Method SetUrl(cUrl)
	Method GetUrl()
	Method SetDocumento(cDocumento)
	Method GetDocumento()
	Method SetLinkCaso(cLinkCaso)
	Method GetLinkCaso(lVersao)
	Method GetCajuriSecRelac()
	Method SetNUMCod(cNUMCod)
	Method GetNUMCod()
	Method SetAnxLegalDesk(lAnexoLD)
	Method GetAnxLegalDesk()

	// Excluir antes de Commitar
	Method Inicializa()

	// Métodos básicos
	Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice) CONSTRUCTOR
	Method Activate()
	Method DeActivate()

	// Métodos inicializadores
	Method LoadCSS()
	Method LoadColsGrid()

	// Criação
	Method CreateForm()
	Method CreateTree()
	Method AtualizaGrid()

	// Processamento
	Method MontaSQL()
	Method FillGrid(aSelect)
	Method GridDoubleClick()
	Method MarcaLinha()
	Method MarcaTudo()
	Method LimpaMarca()
	Method VerTodos()
	Method Abrir()
	Method Importar()
	Method Exportar(lOpen)
	Method Anexar()
	Method Excluir()
	Method GetFrmJoin(cEntiTree)
	Method GetPosCmp(cCampo)
	Method GetValor(cCampo, nLinha)
	Method SetValor(cCampo, nLinha, cValor)
	Method GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta)
	Method DeleteNUM()
	Method ExisteDoc(cDoc, cExtensao)
	Method VerifyMark(cMark)
	Method ZipFileDownload()
	Method RetArquivo(cPatchArq, lExtensao)
	Method ManipulaDoc(nOp, cNomArq , cDirOrigem, cDirDestin, cNomEncrip)
	Method FSincAnexo(cOpc)

	Method AddArquivo(cArquivo)
	Method ClearArquivo()
	Method MontaExp(cChvTab, cChvTre, cFilTre)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Medod construtor da classe de anexos.

@param  cTitulo    - Título da tela
@param  cEntidade  - Entidade utilizada no anexo
@param  cFilEnt    - Filial da entidade
@param  cCodEnt    - Código da entidade
@param  nIndice    - Índice da entidade utilizado para buscar o XXX_CAJURI
@param  lInterface - Indica se demonstra a Interface
@param  lEntPFS    - Indica se é uma entidade do SIGAPFS
                     Necessário devido ao uso da fila de sincronização - LegalDesk

@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface, lEntPFS) CLASS TJurAnexo

	Default cTitulo     := STR0001	//"Anexos Jurídicos"
	Default cEntidade   := 'NSZ'
	Default lInterface  := .T.
	Default lEntPFS     := .F.

	//Inicializa as propriedades
	Self:aColunas      := {}
	Self:aHeader       := {}
	Self:aReqCols      := {}
	Self:lShowUrl      := .F.
	Self:cTitulo       := cTitulo
	Self:cEntidade     := Upper( AllTrim(cEntidade) )
	Self:cFilEnt       := cFilEnt
	Self:cCodEnt       := cCodEnt
	Self:cMarca        := GetMark()
	Self:cPesquisa     := Space( TamSx3("NUM_DOC")[1] )
	Self:cErro		   := ""
	Self:cUsuario	   := ""
	Self:cSenha        := ""
	Self:cEmpresa      := ""
	Self:cUrl          := ""
	Self:cDocumento    := ""
	Self:cLinkCaso     := ""
	Self:nOperation    := 2	//Visualizar
	Self:aArquivos     := {}
	Self:nQtdDblClick  := 0
	Self:lHtml         := ( GetRemoteType() == 5 )
	Self:lInterface    := lInterface
	Self:lSalvaTemp    := .F.
	Self:lAnxLegalDesk := .F.
	Self:cNUMCod       := ""
	Self:lEntPFS       := lEntPFS

	Self:SetSecRelac()

	If Self:cEntidade == "NSZ"
		Self:cCajuri := Self:cCodEnt
		
	Elseif Self:cEntidade $ Self:cHasSecRel
		Self:cCajuri := Self:GetCajuriSecRelac()
	ElseIf &(Self:cEntidade + "->(ColumnPos('" + Self:cEntidade + "_CAJURI'))")> 0
		Self:cCajuri := JurGetDados(Self:cEntidade, nIndice, Self:cFilEnt + Self:cCodEnt, Self:cEntidade + "_CAJURI")
	Else
		Self:cCajuri := ""
	EndIf

	// Inicializa os arrays para os forms
	Self:LoadColsGrid()
	Self:LoadCSS()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Ativação da Classe

@return Nil
@author Willian Yoshiaki Kazahaya
@since  19/04/2018
/*/
//-------------------------------------------------------------------
Method Activate() CLASS TJurAnexo
	Self:CreateForm()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DeActivate()
Desativação da Classe

@return Nil
@author Willian Yoshiaki Kazahaya
@since  19/04/2018
/*/
//-------------------------------------------------------------------
Method DeActivate() CLASS TJurAnexo
	Self:oForm:Sair()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCSS()
Define o CSS dos Botões

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method LoadCSS() CLASS TJurAnexo
	//Formatação do campo de busca (oGetSearch)
	Self:cCSSEdit := "QLineEdit {" +;
	            "border-width: 2px;" +;
	            "border: 1px solid #C0C0C0;" +;
	            "border-radius: 3px;" +;
	            "border-color: #C0C0C0;" +;
	            "font: bold 12px Arial;" +;
	            "}"

	//Formatação dos botão Pesquisar
	Self:cCSSButton := "QPushButton {" +;
	      			"cursor: pointer; color: rgb(79, 84, 94);" +;
	      			"border: 1px solid rgb(216, 216, 216);" +;
	      			"border-radius: 3px;" +;
	      			"background-color: rgb(245, 245, 245);"+;
	      			"}" +;
	      			"QPushButton:hover:!pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(255, 255, 255), stop: 1 rgb(230, 230, 230));}"+;
	      			"QPushButton:hover:pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(230, 230, 230), stop: 1 rgb(255, 255, 255));}"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadColsGrid()
Configuração padrão dos campos.
Inclui todos os campos da estrutura da NUM

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method LoadColsGrid() CLASS TJurAnexo

	// Coluna de Marcação
	aAdd(Self:aHeader, {"","",,,,,,,,,,,,,,,,,;
						  {|| IIF(Self:VerifyMark(), "LBOK", "LBNO")},;
						  {|| Self:MarcaLinha()},;
						  {|| Self:MarcaTudo()} ;
	                   } )

	// Coluna obrigatória para pesquisa
	aAdd(Self:aReqCols, {"NUM_COD"   ,JA160X3Des("NUM_COD")   ,,,,,,"NUM_COD"})

	

	// Colunas para serem demonstradas
	aAdd(Self:aColunas, {"NUM_DESC"  ,JA160X3Des("NUM_DESC")  ,,,,,,"NUM_DESC"})
	aAdd(Self:aColunas, {"NUM_NUMERO",JA160X3Des("NUM_NUMERO"),,,,,,"NUM_NUMERO"})
	
	//Coluna de data de inclusão, se tiver o campo no dicionario
	DBSelectArea("NUM")
	If(NUM->(FieldPos('NUM_DTINCL')) > 0)
		aAdd(Self:aColunas, {"NUM_DTINCL",JA160X3Des("NUM_DTINCL"),,,,,,"NUM_DTINCL"})
	EndIf
	NUM->( DBCloseArea() )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateForm
Cria o formulário

@return oModal - Tela montada
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method CreateForm() CLASS TJurAnexo
Local oForm
Local oEntidades
Local oUrlWindow
Local oUrl
Local oLayer
Local oGetSearch
Local oBtnSearch
Local oPesquisa
Local nI          := 0
Local nLenUrl     := IIf(Self:lShowUrl, 15, 0)
Local aHeader     := aClone(Self:aHeader)

 	Self:oFont       := TFont():New( "Arial"/*cName*/, /*uPar2*/, 15/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/)

 	oForm := FWDialogModal():New()
	oForm:SetFreeArea(500, 230)
	oForm:SetEscClose(.T.)			//Permite fechar a tela com o ESC
	oForm:SetBackground(.T.)		//Escurece o fundo da janela
	oForm:SetTitle(Self:cTitulo)
	oForm:EnableFormBar(.T.)
	oForm:CreateDialog()
	oForm:CreateFormBar()			//Cria barra de botoes

	For nI := 1 to Len(Self:aButton)
		If JA162AcRst('03', Self:aButton[nI][3])
			oForm:AddButton( Self:aButton[nI][1], Self:aButton[nI][2], Self:aButton[nI][1], , .T., .F., .T.)
		EndIf
	Next

	//"Fechar"
	oForm:AddCloseButton()

	//==========================
	// Criação dos painéis
	//==========================
	oPanel := oForm:GetPanelMain()

	oLayer := FwLayer():New()
	oLayer:Init(oPanel, .F.)

	// Coluna esquerda
	oLayer:AddCollumn("COLUNA1", 30, .F., 	)
	oLayer:AddWindow("COLUNA1", "WINDOW1", STR0010, 100 - nLenUrl, .F., .F., {|| .T.},  , {|| .T.}) //"Entidades"
	oLayer:AddWindow("COLUNA1", "WINDOW4", STR0011, nLenUrl		 , .F., .F., {|| .T.},  , {|| .T.})	//"URL"

	oEntidades := oLayer:getWinPanel("COLUNA1", "WINDOW1", )
	Self:CreateTree(oEntidades)

	If nLenUrl > 0
		oUrlWindow := oLayer:getWinPanel("COLUNA1", "WINDOW4", )
		oUrl := TSay():Create(oUrlWindow)
		oUrl:setText(Self:cUrl)
		oUrl:nLeft := 0
		oUrl:nTop  := 0
		oUrl:nHeight := 32
		oUrl:nWidth  := 300
	EndIf

	//Pesquisa
	oLayer:AddCollumn("COLUNA2", 70, .F.,)
	oLayer:AddWindow("COLUNA2", "WINDOW2", STR0012, 20, .F., .F., {|| .T.},  , {|| .T.})	//"Pesquisa"

	oPesquisa := oLayer:getWinPanel("COLUNA2", "WINDOW2", )

	//Cria campo de pesquisa
	AddCSSRule("TGet", Self:cCSSEdit)
	oGetSearch            := TGet():Create(oPesquisa)
	oGetSearch:cName      := "oGetSearch"
	oGetSearch:bSetGet    := {|u| If( pCount() > 0, Self:cPesquisa := u, Self:cPesquisa)}
	oGetSearch:nTop       := 5
 	oGetSearch:nLeft      := 5
	oGetSearch:nHeight    := 32
 	oGetSearch:nWidth     := oPesquisa:nRight - 120
	oGetSearch:SetFocus()

	//Cria botão de pesquisa
	AddCSSRule("TButton", Self:cCSSButton)
	oBtnSearch             := TButton():Create(oPesquisa)
	oBtnSearch:cName       := "oBtnSearch"
	oBtnSearch:cCaption    := STR0013	//"Pesquisar"
	oBtnSearch:blClicked   := {|| Self:AtualizaGrid()}
	oBtnSearch:nTop        := 5
	oBtnSearch:nLeft       := oGetSearch:nWidth + 10
	oBtnSearch:nHeight     := 32
	oBtnSearch:nWidth      := 90

	//Documentos
	oLayer:AddWindow("COLUNA2", "WINDOW3", STR0014, 80, .F., .F., {|| .T.},  , {|| .T.})	//"Documentos"

	oDocumentos := oLayer:getWinPanel("COLUNA2", "WINDOW3", )

	// Monta o Grid.
	Self:oSelect := TJurBrowse():New(oDocumentos)
	Self:oSelect:SetDataArray()
	Self:oSelect:Activate(.F.)
	Self:oSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	Self:oSelect:SetHeaderSX3(Self:aColunas, aHeader)

	// Adiciona os campos obrigatórios
	aEval(Self:aReqCols,{|x| aAdd(Self:aColunas,{x[1],x[2],x[3]})})

	Self:oSelect:SetDoubleClick( {|| Self:GridDoubleClick()} )

	//Atualiza dados do grid
	Self:oSelect:Refresh()
	Self:AtualizaGrid()
	oForm:Activate()

	Self:LimpaMarca()


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateTree(oEntidades)
Cria a arvore de pastas

@param oEntidades - Objeto que irá receber a árvore de pastas

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method CreateTree(oEntidades) CLASS TJurAnexo
	Self:oTreeFolder := DbTree():New(0 , 0, oEntidades:nBottom, oEntidades:nRight, oEntidades, {|| Self:cPesquisa := Space( TamSx3("NUM_DOC")[1] ), Self:AtualizaGrid()} 	, Self:TreeRightBtn(), .T., /*lDisable*/, Self:oFont, /*cHeaders*/)

	If Self:cEntidade == "NSZ"
		 	  		   //AddItem( cPrompt		 , cCargo			, cRes1	   	, cRes2	  	, cFile1	, cFile2	, nTipo)
	  //Self:oTreeFolder:AddItem(PadR("Raiz", 50), PadR("RAIZ", 50) , "FOLDER10", "FOLDER11", /*cFile1*/, /*cFile2*/, 1)	//"Raiz"
		Self:oTreeFolder:AddItem(STR0015		 , "NSZ"			, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Assunto Jurídico"

		//Adiciona pastas filhas da NSZ
		JAnxFldNsz(Self:oTreeFolder)

		Self:oTreeFolder:AddItem(STR0016		, "NT4"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Andamentos"
		Self:oTreeFolder:AddItem(STR0017		, "NTA"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Follow-ups"
		Self:oTreeFolder:AddItem(STR0018		, "NT2"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Garantias"
		Self:oTreeFolder:AddItem(STR0019		, "NT3"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Despesas"
		Self:oTreeFolder:AddItem(STR0020		, "NSY"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Objetos"
	  //Self:oTreeFolder:AddItem(STR0021		, "O0M"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Solic. Docs"
	  //Self:oTreeFolder:AddItem(STR0022		, ""				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)	//"Liminares"
	Else
		Self:oTreeFolder:AddItem( JurX2Nome(Self:cEntidade), Self:cEntidade, "FOLDER5", "FOLDER6", /*cFile1*/, /*cFile2*/, 1)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TreeRightBtn()
Botão direito da Arvore de Pastas

@return Nil
@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method TreeRightBtn() CLASS TJurAnexo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetButton(aButton)
Define os botões e seus métodos

@Param aButton - Botões a serem incluidos
				  [1] - Titulo do Botão
				  [2] - Comando do Botão
				  [3] - Numero da ação (2 = Visualizar; 3= Incluir; 4= Alterar; 5= Excluir)

@Sample aAdd(aListBtn, {"Importar", {|| Processa({ || JImpFluig(cClienteLoja, cCaso, , cAssJur, xFilial(cEntida), cEntida, cCodOri, oTree )}, '2')}

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method SetButton(aBtnPad) CLASS TJurAnexo
	Self:aButton := aBtnPad
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetButton()
Retorna os botões da tela

@return aButton - Botões a serem incluidos
				  [1] - Titulo do Botão
				  [2] - Comando do Botão
				  [3] - Numero da ação (2 = Visualizar; 3= Incluir; 4= Alterar; 5= Excluir)
@author Rafael Tenorio da Costa
@since  11/05/2018
/*/
//-------------------------------------------------------------------
Method GetButton() CLASS TJurAnexo
Return Self:aButton

//-------------------------------------------------------------------
/*/{Protheus.doc} SetShowUrl(lShow)
Define se irá mostrar a Url ou não

@Param lShow - Mostra Url S/N

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method SetShowUrl(lShow) CLASS TJurAnexo
	Self:lShowUrl := lShow
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RemoveColGrid(cNomField)
Remove coluna do Grid

@Param cNomField - Nome do campo a remover da tela

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method RemoveColGrid(cNomField) CLASS TJurAnexo
Local nIndField := Self:GetPosCmp(cNomField)
Local lRet := .F.

	If nIndField > 0 .AND. (cNomField != 'NUM_COD' .OR. cNomField != 'NUM_MARK')
		lRet := .T.
		aDel(Self:aColunas, nIndField)
		aSize(Self:aColunas, Len(Self:aColunas)-1)
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSecRelac(cTabSecRel)
Inclusão de tabelas com Relacionamento em segundo nivel com a NSZ

@Param cTabSecRel - Nome da tabela que contem relacionamento em segundo
                      Nivel. Montagem ( Tabela Segundo Grau [Tabela Primeiro Grau] | )
                      Separador entre vários item em "|"

@return Nil
@Sample SetSecRelac('O0N[O0M]|')
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method SetSecRelac(cTabSecRel) CLASS TJurAnexo
	Default cTabSecRel := 'O0N[O0M]|'
	Self:cHasSecRel  := cTabSecRel
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RemoveColGrid(cNomField)
Remove coluna do Grid

@Param cNomField - Nome do campo a remover da tela

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method MarcaLinha() CLASS TJurAnexo

	Local lRet := .T.

	NUM->( dbSetOrder( 1 ) )
	If NUM->(dbSeek(xFilial('NUM') + Self:GetValor('NUM_COD')))
		RecLock("NUM", .F.)

		If !Empty(NUM->NUM_MARK)	.AND. NUM->NUM_MARK == Self:cMarca
			NUM->NUM_MARK := ""
			Self:SetValor('NUM_MARK', , "")
		Else
			NUM->NUM_MARK := Self:cMarca
			Self:SetValor('NUM_MARK', , Self:cMarca)
		EndIf

		NUM->( MsUnLock() )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaTudo()
Marca todos os itens do Grid

@return Nil
@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method MarcaTudo() CLASS TJurAnexo
Local nLinha := 1

	For nLinha:=1 To Len(Self:oSelect:aCols)

		NUM->( dbSetOrder( 1 ) )
		If NUM->( dbSeek(xFilial('NUM') + Self:GetValor('NUM_COD', nLinha)) )

			RecLock("NUM", .F.)

				If Empty(NUM->NUM_MARK)
					NUM->NUM_MARK := Self:cMarca
					Self:SetValor('NUM_MARK', nLinha, Self:cMarca)
				Else
					NUM->NUM_MARK := ""
					Self:SetValor('NUM_MARK', nLinha, "")
				Endif

			NUM->( MsUnLock() )
		EndIf

		While __lSX8
			If lRet
				ConfirmSX8()
			Else
				RollBackSX8()
				Self:cErro := STR0027	//"Não foi possível efetuar a gravação da tabela NUM."
			EndIf
		EndDo
	Next nLinha

	Self:oSelect:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaMarca()
Tira seleção dos documentos

@return lRetorno
@author Rafael Tenorio da Costa
@since  16/05/2018
/*/
//-------------------------------------------------------------------
Method LimpaMarca() CLASS TJurAnexo

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cUpdate 	:= ""

	cUpdate := " UPDATE " + RetSqlName("NUM")
	cUpdate	+= " SET NUM_MARK = '  '"
	cUpdate	+= " WHERE D_E_L_E_T_ = ' '"
	cUpdate	+= 	" AND NUM_FILIAL = '" + xFilial("NUM") + "'"
	cUpdate	+= 	" AND NUM_MARK = '" + Self:cMarca + "'"

	If TcSqlExec(cUpdate) < 0
		lRetorno   := .F.
	  	Self:cErro := I18n(STR0029, { TcSqlError() } )	//"Erro ao desvincular o arquivo: #1"
	EndIf

	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GridDoubleClick()
Duplo clique do Grid

@return Nil

@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method GridDoubleClick() CLASS TJurAnexo
	Self:Abrir()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizaGrid()
Atualiza o Grid

@author Willian Yoshiaki Kazahaya
@since  13/04/2018
/*/
//-------------------------------------------------------------------
Method AtualizaGrid() CLASS TJurAnexo

	Local cQuery  := ""
	Local cFiltro := Self:cPesquisa
	Local cAlias  := GetNextAlias()

	cFiltro := Lower( StrTran(JurLmpCpo(cFiltro, .F.), '#', '') )

	Self:oSelect:SetArray({})
	cQuery := Self:MontaSQL()

	If Self:oTreeFolder:GetCargo() == "NSZ" .And. Self:oTreeFolder:GetPrompt() != "Assunto Jurídico"
		cQuery += "AND NUM_SUBPAS = '" + Self:oTreeFolder:GetCargo() + "_" + Self:oTreeFolder:GetPrompt() + "' "
	Endif

	If !Empty(cFiltro)
		cQuery += " AND ("
		cQuery += 		   " NUM_COD LIKE ('%" + cFiltro + "%')"
		cQuery += 		" OR "+ JurFormat("NUM_DESC"  , .T., .T.) + " LIKE ('%" + cFiltro + "%')"
		cQuery += 		" OR "+ JurFormat("NUM_EXTEN", .T., .T.) + " LIKE ('%" + cFiltro + "%')"
		cQuery += 		" OR NUM_NUMERO LIKE ('%" + cFiltro + "%')"
		cQuery += 	" )"
	EndIf

	cQuery := ChangeQuery(cQuery)
	//O change query está trocando '' por ' ', que está comprometendo a consulta
	cQuery := StrTran(cQuery,",' '",",''")
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F.)

	Self:oSelect:SetArray(Self:FillGrid(cAlias))

	(cAlias)->( DbCloseArea() )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValor(cCampo, nLinha)
Busca o valor do campo

@param cCampo - Campo
@param nLinha - Linha posicionada no Grid

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
METHOD GetValor(cCampo, nLinha) CLASS TJurAnexo
	Local nColuna  := 0
	Local cRet     := ""
	Default cCampo := "NUM_COD"

	Default nLinha := IIF(Valtype(Self:oSelect) <> "U",Self:oSelect:nAt,0)

	If Valtype(Self:oSelect) <> "U"

		nColuna := Self:GetPosCmp(cCampo)

		If nColuna > 0 .And. !Empty(Self:oSelect:aCols)
			cRet := Self:oSelect:aCols[nLinha][nColuna]
		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPosCmp(cCampo)
Busca a posição do Campo dentro do array de Campos

@param cCampo - Campo

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
METHOD GetPosCmp(cCampo) CLASS TJurAnexo
Local nRet       := 0
Local nReqColLen := Len(Self:aReqCols)
	nRet := aScan(Self:aColunas,{|aX| AllTrim(aX[1]) == AllTrim(cCampo)}) //Desconsidera a legenda
Return nRet + nReqColLen

//-------------------------------------------------------------------
/*/{Protheus.doc} SetValor(cCampo, nLinha, cValor)
Insere o valor no campo da linha determinada

@Param cCampo - Campo
@Param nLinha - Linha do grid
@Param cValor - Valor a ser inserido no campo

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
METHOD SetValor(cCampo, nLinha, cValor) CLASS TJurAnexo
	Local nColuna	:= 0
	Local lRet		:= .T.

	Default nLinha := IIF(Valtype(Self:oSelect) <> "U",Self:oSelect:nAt,0)

	If Valtype(Self:oSelect) <> "U" .And. nLinha > 0

		nColuna := Self:GetPosCmp(cCampo)

		If nColuna > 0 .And. !Empty(Self:oSelect:aCols)
			Self:oSelect:aCols[nLinha][nColuna] := cValor
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VerTodos()
Esqueleto para a função de Visualização de todos os registros. Existente no Fluig

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method VerTodos() CLASS TJurAnexo
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Abrir()
Esqueleto para a função de Abrir o documento. Existente na Base de Conhecimento e Fluig

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method Abrir() CLASS TJurAnexo

	If Empty(Self:cDocumento)
		Self:cErro := STR0030		//"Não foi selecionado o documento para abertura no Fluig"
		ApMsgInfo(Self:cErro)
	Else
		Self:cErro := ""
		ShellExecute("open", Self:cDocumento, "", "", SW_SHOW)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Exportar(lOpen)
Esqueleto para a função de Exportar o documento. Existente na Base de Conhecimento

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method Exportar(lOpen, aArquivos) CLASS TJurAnexo
Default lOpen     := .F.
Default aArquivos := {}
	
	If (Len(aArquivos) == 0)
		Self:aArquivos := Self:GetRegSelecionado()
	Else
		Self:aArquivos := aClone(aArquivos)
	EndIf

	If Len(Self:aArquivos) > 0
		ProcRegua(0)
		IncProc()
	EndIf

Return Len(Self:aArquivos) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar()
Metodo Importar utilizado por todas as clases, para fazer pré validações
e carregar os arquivos a serem importados.

@author  Rafael Tenorio da Costa
@version 2.0
@since   23/04/2018
/*/
//-------------------------------------------------------------------
Method Importar() CLASS TJurAnexo

	Local lRet 	    := .T.
	Local cEntiTree   := Upper( AllTrim( Self:oTreeFolder:GetCargo() ) )
	Local cArquivos   := ""
	Local cPath       := ""
	Local cTpAnxo     := AllTrim( SuperGetMv('MV_JDOCUME', ,'1') )
	Local aListArq    := {}
	Local nI          := 0
	Local cArqRet     := ""

	Self:cSubPasta    := AllTrim( Self:oTreeFolder:GetPrompt() )

	If self:cEntidade == "NSZ" .And.  Self:cSubPasta != "Assuntos Jurídicos"
		Self:cSubPasta := self:cEntidade + "_" + Self:cSubPasta
	else
		Self:cSubPasta = ""
	EndIf

	Self:cErro := ""
	Asize(Self:aArquivos, 0)

	//-- Guarda Path - Worksite
	If cTpAnxo == "1"
		cPath := IIf (!Empty(self:oGed:cPath),self:oGed:cPath,"C:\")
	Else
		cPath := "C:\"
	EndIf

	If cEntiTree == "RAIZ"
		Self:cErro := STR0023		//"Não é possível importar arquivos para este item da árvore"
		lRet 	   := .F.

	ElseIf !(Self:cEntidade == cEntiTree)
		Self:cErro := I18n(STR0024, {JurX2Nome( SubStr(cEntiTree, 1, 3) )})		//"Para importar arquivos para esta entidade utilize a rotina de #1"
		lRet 	   := .F.

	Else
		If Self:lHtml
			cArquivos := cGetFile(STR0025 + "|*.*", STR0026, , "C:\", .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), ,.F.)	//"Todos os arquivos"	//"Seleção de arquivo(s)"
			cArquivos := StrTran(cArquivos, "servidor\", "")
		Else
			cArquivos := cGetFile(STR0025 + "|*.*", STR0026, , cPath, .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_MULTISELECT), ,.F.)	//"Todos os arquivos"	//"Seleção de arquivo(s)"
		EndIf

		aListArq := StrTokArr2(cArquivos, " | ")

		Self:aArquivos := aClone(aListArq)

		For nI := 1 to Len(Self:aArquivos)
			cDirArq := Self:aArquivos[nI]
			cArqRet += Self:RetArquivo(cDirArq, .T.) + CRLF
		Next

		If Len(Self:aArquivos) > 0 .And. ApMsgYesNo(STR0031 + CRLF + cArqRet) //"Deseja importar o(s) seguinte(s) arquivo(s): "
			ProcRegua(0)
			IncProc()
		Else
			lRet := .F.
		EndIf
	EndIf

	If !lRet .And. !Empty(Self:cErro)
		JurMsgErro(Self:cErro)
	EndIf

	Self:LimpaMarca()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Anexar()
Esqueleto para a função de Anexar

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method Anexar() CLASS TJurAnexo

	Local lRet 		:= .T.
	Local cEntiTree := Upper( AllTrim( Self:oTreeFolder:GetCargo() ) )

	Self:cErro := ""

	If !(Self:cEntidade == cEntiTree)
		Self:cErro := I18n(STR0036, {JurX2Nome( SubStr(cEntiTree, 1, 3) )})		//"Para anexar arquivos para esta entidade utilize a rotina de #1"
		lRet 	   := .F.
	Else
		ProcRegua(0)
		IncProc(STR0032)		//"Anexando arquivo"
	EndIf

	If !lRet .And. !Empty(Self:cErro)
		JurMsgErro(Self:cErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Excluir()
Esqueleto para a função de Excluir

@param cCodNUM string Id do anexo

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method Excluir(cCodNUM) CLASS TJurAnexo

Local aArqDel   := {}
Local nI        := 0
Local lRet      := .T.
Local cEntiTree := ""
Local cMessage  := ""

Default cCodNUM := ""

	Self:cErro := ""

	If Empty(cCodNUM)
		cEntiTree := Upper( AllTrim( Self:oTreeFolder:GetCargo() ) )

		If !(Self:cEntidade == cEntiTree)
			Self:cErro := I18n(STR0037, {JurX2Nome( SubStr(cEntiTree, 1, 3) )})		//"Para excluir arquivos para esta entidade utilize a rotina de #1"
			lRet 	   := .F.
		Else
			aArqDel := Self:GetRegSelecionado()

			If Len(aArqDel) > 0

				cMessage := STR0041 + CRLF //"Deseja Excluir o(s) seguinte(s) anexo(s)?"

				For nI:=1 To Len(aArqDel)
					cMessage += aArqDel[nI][6] + CRLF
				Next nI

				nI := 0

				If JurAuto() .Or. ApMsgNoYes(cMessage, STR0009) // "Excluindo arquivos"

					For nI:=1 To Len(aArqDel)
						If !Self:DeleteNUM( aArqDel[nI][2] )
							Self:cErro := I18n(STR0033, {aArqDel[nI][2]}) + CRLF		//"Não foi possível excluir o documento #1 da tabela NUM"
						EndIf
					Next nI


					If !Empty(Self:cErro)
						JurErrLog(Self:cErro, STR0034) //"Documentos não excluídos"
					Else
						ApMsgInfo(STR0035) //"Documento(s) excluído(s) com sucesso!"
					EndIf

					Self:AtualizaGrid()
					
				EndIf
				
			EndIf
		EndIf
	Else //TOTVSLegal
		If !Self:DeleteNUM( cCodNUM )
				Self:cErro := I18n(STR0033, {cCodNUM}) + CRLF		//"Não foi possível excluir o documento #1 da tabela NUM"
		EndIf
		If !Empty(Self:cErro)
			JurErrLog(Self:cErro, STR0034) //"Documentos não excluídos"
		Else
			ApMsgInfo(STR0035) //"Documento(s) excluído(s) com sucesso!"
		EndIf
	EndIf

	If !lRet .And.  !Empty(Self:cErro)
		JurMsgErro(Self:cErro)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSQL()
Montagem do SQL para a montagem do Grid

@Return cQuery - Query montada

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method MontaSQL() CLASS TJurAnexo
Local cQuery  := ''
Local cQrySel := ''
Local nC

	For nC := 1 To Len(Self:aColunas)
		cQrySel += Self:aColunas[nC][1] + ','
	Next

	cQrySel  := " SELECT " + SUBSTR(cQrySel,1, Len(cQrySel) -1 )

	cQuery := cQrySel + Self:GetFrmJoin()
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} FillGrid(aSelect)
Preenche as linhas do grid com a lista do Select

@Param aSelect - Resultado do Select. Tipo um cAlias.

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method FillGrid(aSelect) CLASS TJurAnexo
Local aLines   := {}
Local nL       := 0
Local nC       := 0
Local nI       := Len(Self:aHeader)
	While(aSelect)->(!Eof())
		nL++
		aAdd(aLines, Array(Len(Self:aColunas)+1))

		For nC := 1 To Len(Self:aColunas)
			aLines[nL][nC+nI] := (aSelect)->(FieldGet(FieldPos(Self:aColunas[nC][1])))
		Next

		(aSelect)->(dbSkip())
	End

Return aLines

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFrmJoin()
Monta as clausulas From e Where do Select.

@author Willian Yoshiaki Kazahaya
@since  23/04/2018
/*/
//-------------------------------------------------------------------
Method GetFrmJoin() CLASS TJurAnexo
Local nS         := 0
Local cQryFrm    := ''
Local cIdxTre    := ''
Local cIdxEnt    := ''
Local cQryWhr    := ''
Local cFrmSx9    := ''
Local cReturn    := ''
Local cRelcDom   := ''
Local cRelDom    := ''
Local nA         := 0
Local nPosIni    := 0
Local nPosFim    := 0
Local aSx9       := {}
Local aSecRel    := {}
Local cBanco     := Upper(TcGetDb())
Local cEntiTree  := Self:oTreeFolder:GetCargo()
Local cChvTre    := ""
Local cFilTre    := ""
Local cWhrEnt    := ""

	cRelDom := Self:cEntidade
	cIdxTre := AllTrim(FwX2Unico(cEntiTree))

	If Self:lEntPFS .And. Self:cEntidade == cEntiTree
		cWhrEnt := Self:MonTaExp(cIdxTre, @cChvTre, @cFilTre) //Monta as expressões de filtro da entidade cWhrEnt e retorna os campos de relacionamento com a NUM
	Else
		cIdxEnt := AllTrim(FwX2Unico(cRelDom))

		If Self:cEntidade != cEntiTree

			If !Empty(Self:cHasSecRel) .And. cEntiTree+'[' $ Self:cHasSecRel
				aSecRel := JStrArrDst(Self:cHasSecRel, '|')
				nA := aScan(aSecRel,cEntiTree+'[')
				nPosIni := At('[',aSecRel[nA])
				nPosFim := At(']',aSecRel[nA])

				If nA > 0
					cRelcDom := Substring(aSecRel[nA],nPosIni+1, nPosFim-nPosIni-1)
					aSx9 := JURSX9(cRelDom, cRelcDom)
					For nS := 1 to Len(aSx9)
						cFrmSx9 += " INNER JOIN " + RetSqlName(cRelcDom) + " " + cRelcDom + " ON (" + aSx9[nS][1] + " = " + aSx9[nS][2] + ")"
						cFrmSx9 +=                                                         " AND (" + cRelDom + "_FILIAL = " + cRelCDom + "_FILIAL)"
					Next
				EndIf

				cRelDom  := cRelcDom
				cRelcDom := cEntiTree
			EndIf
			aSx9 := JURSX9(cRelDom, cEntiTree)
			
			For nS := 1 to Len(aSx9)
				cFrmSx9 += " INNER JOIN " + RetSqlName(cEntiTree) + " " + cEntiTree + " ON (" + aSx9[nS][1] + " = " + aSx9[nS][2] + ")"
				cFrmSx9 +=                                                           " AND (" + cRelDom + "_FILIAL = " + cEntiTree + "_FILIAL)"
			Next
			
		EndIf
	EndIf

	cQryFrm := ' FROM ' + RetSqlName(Self:cEntidade) + ' ' + Self:cEntidade
	cQryFrm += cFrmSx9

	If cBanco == "POSTGRES"
		cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(CONCAT(NUM.NUM_FILENT+NUM.NUM_CENTID)) = RTRIM(CONCAT(" + cIdxTre + ") )"
		cQryWhr := " WHERE RTRIM(CONCAT(" + cIdxEnt + ")) = RTRIM(CONCAT('" + Self:cFilEnt + Self:cCodEnt + "'))"
	ElseIf !Empty(cFilTre) .And. !Empty(cChvTre) .And. !Empty(cWhrEnt)
		cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM "
		cQryFrm +=         " ON ( NUM.NUM_FILENT = " + cFilTre
		cQryFrm +=        " AND  RTRIM(NUM.NUM_CENTID) = RTRIM(" + cChvTre + ") )"
		cQryWhr :=      " WHERE " + cWhrEnt
	Else
		cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON ( RTRIM(NUM.NUM_FILENT+NUM.NUM_CENTID) = RTRIM(" + cIdxTre + ") )"
		cQryWhr := " WHERE " + cIdxEnt + " = '" + Self:cFilEnt + Self:cCodEnt + "'"
	EndIf
	cQryWhr +=   " AND " + Self:cEntidade + ".D_E_L_E_T_ = ' ' "
	cQryWhr +=   " AND NUM.D_E_L_E_T_ = ' '"
	cQryWhr +=   " AND NUM.NUM_ENTIDA = '" + cEntiTree + "'"

	cReturn := cQryFrm + cQryWhr

	If cBanco $ "ORACLE|POSTGRES"
		cReturn := StrTran(cReturn, "+", "||")
	EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaNUM
Gravação de Dados na NUM - Documentos jurídico

@Param cNumero    	- Identificador
@Param cDoc       	- Link do Documento
@Param cDesc      	- Nome do Documento
@Param cExtensao	- Extensão do Arquivo
@param cSubPasta	- Nome da sub-pasta criada dentro da entidade NSZ

@author  Rafael Tenorio da Costa
@version 2.0
@since   23/04/2018
/*/
//-------------------------------------------------------------------
Method GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta) CLASS TJurAnexo

	Local aArea    := GetArea()
	Local lRet     := .T.
	Local cNumCod  := ""
	Self:cErro     := ""

	//Verifique se o documento existe
	If !Self:ExisteDoc(cDoc, cExtensao)

		DbSelectArea("NUM")
		cNumCod := GetSXENum("NUM", "NUM_COD")
		lRet := RecLock("NUM", .T.)

		NUM->NUM_FILIAL := xFilial("NUM")
		NUM->NUM_COD    := cNumCod
		NUM->NUM_FILENT := Self:cFilEnt
		NUM->NUM_ENTIDA := Self:cEntidade
		NUM->NUM_CENTID := Self:cCodEnt
		NUM->NUM_NUMERO := cNumero
		NUM->NUM_DOC    := cDoc
		NUM->NUM_DESC   := cDesc
		NUM->NUM_EXTEN  := cExtensao
		If (NUM->(FieldPos('NUM_DTINCL')) > 0)//Se o campo de data de inclusão estiver no dicionario, grava
			NUM->NUM_DTINCL := Date()
		EndIf

		// Proteção de pasta
		If NUM->( ColumnPos("NUM_SUBPAS") ) > 0
			NUM->NUM_SUBPAS := cSubPasta
		EndIf

		NUM->( MsUnlock() )

		While __lSX8
			If lRet
				ConfirmSX8()
			Else
				RollBackSX8()
				Self:cErro := STR0027	//"Não foi possível efetuar a gravação da tabela NUM."
			EndIf
		EndDo

		If lRet
			Self:SetNUMCod(cNumCod)
			Self:FSincAnexo("3") // Adiciona os anexos na fila de sincronização - SOMENTE SIGAPFS
		EndIf

	ElseIf Self:GetAnxLegalDesk() // Indica se o anexo foi feito pelo LegalDesk (Integração SIGAPFS)
		JAjustaNum(Self:GetNUMCod(), cNumero)
	Else
		lRet       := .F.
		Self:cErro := STR0028 + " " + cDoc + cExtensao	//"Documento já vinculado"
	EndIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteNUM(cNumCod)
Delete de registro da NUM

@Param cNumCod - ID do registro

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method DeleteNUM(cNumCod) CLASS TJurAnexo
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaNUM := NUM->( GetArea() )
Local cChvACB  := ""

	NUM->( DbSetOrder(1) )	//NUM_FILIAL+NUM_COD
	If NUM->( DbSeek(xFilial("NUM") + cNumCod))
		cChvACB := AllTrim(NUM->NUM_DESC) + AllTrim(NUM->NUM_EXTEN)
		lRet := RecLock("NUM", .F.)
			NUM->( DbDelete() )
		NUM->( MsUnLock() )
	EndIf

	While __lSX8
		If lRet
			ConfirmSX8()
		Else
			RollBackSX8()
			Self:cErro := STR0027	//"Não foi possível efetuar a gravação da tabela NUM."
		EndIf
	EndDo

	//deleção do anexo na base de conhecimento quando há integração com o financeiro
	If lRet .AND. Self:cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1'
		//deletamos o mesmo anexo na AC9 e ACB para o titulo gerado
		lRet := JAnxDlBaseCon( cChvACB, /*cChvAC9*/, 2/*nACBIndex*/) //ACB_FILIAL + ACB_OBJETO
		If !lRet
			JurMsgErro(STR0038) //"Erro na exclusão da Base de Conhecimento do Contas a Pagar."
		EndIf
	EndIf

	If lRet
		Self:SetNUMCod(cNumCod)
		Self:FSincAnexo("5") // Exclui os anexos na fila de sincronização - SOMENTE SIGAPFS
	EndIf

	RestArea(aAreaNUM)
	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JAnxDlBaseCon
Faz a deleção dos registros na Base de Conhecimento (AC9 e ACB).

@param  cChvACB     - Chave da ACB (Bancos de Conhecimentos)
@param  cChvAC9     - Chave da AC9 (Relacao de Objetos x Entidades)
@param  nACBIndex   - Indice de busca na ACB
@return lRet		- Indica se a deleção dos registros nas duas tabelas
					  foram executados com sucesso

@since 04/08/2019
/*/
//-------------------------------------------------------------------
Function JAnxDlBaseCon( cChvACB, cChvAC9, nACBIndex)

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaAC9 := AC9->( GetArea() )
Local aAreaACB := ACB->( GetArea() )
Local cCodObj  := ""

Default nACBIndex := 1 //ACB_FILIAL+ACB_CODOBJ
Default cChvAC9   := ""

	//Bancos de Conhecimentos
	ACB->( DbSetOrder(nACBIndex) )
	If ACB->( DbSeek(xFilial("ACB") + cChvACB) )
		cCodObj := ACB->ACB_CODOBJ
		lRet := RecLock("ACB", .F.)
				ACB->( DbDelete() )
		ACB->( MsUnLock() )
	EndIf
	While __lSX8
		If lRet
			ConfirmSX8()
		Else
			RollBackSX8()
		EndIf
	EndDo

	If lRet .AND. !Empty(cCodObj)
		//Relacao de Objetos x Entidades
		If nACBIndex == 2
			cChvAC9 := cCodObj
		EndIf
		AC9->( DbSetOrder(1) ) //ACB_FILIAL+ACB_CODOBJ
		If AC9->( DbSeek(xFilial("AC9") + cChvAC9) )
			lRet := RecLock("AC9", .F.)
				AC9->( DbDelete() )
			AC9->( MsUnLock() )
		EndIf
		While __lSX8
			If lRet
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo
	EndIf

	RestArea(aAreaACB)
	RestArea(aAreaAC9)
	RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SetOperation(cOp)
Seta o valor da operação a ser realizada

@Param cOp - Operação

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method SetOperation(nOp) CLASS TJurAnexo
	Self:nOperation := nOp
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOperation()
Pega a Operação a ser executada

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method GetOperation() CLASS TJurAnexo
Return Self:nOperation

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRegSelecionado()
Faz o select na tabela de NUM buscando os dados dos itens marcados

@Return aAliSel - Array com os valores de cada campo.
					[1] - NUM_FILIAL - Filial
					[2] - NUM_COD 	   - Código
					[3] - NUM_NUMERO - Numero de registro
					[4] - NUM_DOC 	   - Link do Documento
					[5] - NUM_EXTEN  - Extensão
					[6] - NUM_DESC   - Descrição do Documento
@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method GetRegSelecionado() CLASS TJurAnexo
Local aArea     := GetArea()
Local aFields   := {"NUM_FILIAL","NUM_COD","NUM_NUMERO","NUM_DOC","NUM_EXTEN", "NUM_DESC"}
Local cAlias    := GetNextAlias()
Local cAliasNum := ""
Local aAliSel   := {}
Local aAux      := {}
Local aCamposOld:= {}
Local nI        := 0
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cQuery    := ""
Local cCodNum   := ""

	cQrySel := " SELECT "

	For nI := 1 to Len(aFields)
		cQrySel += aFields[nI] + ","
	Next

	cQrySel := Substring(cQrySel,1, Len(cQrySel)-1)
	cQryFrm := " FROM " + RetSqlName("NUM")
	cQryWhr := " WHERE NUM_MARK = '" + Self:cMarca + "'"
	cQryWhr +=   " AND D_E_L_E_T_ = ' '"

	cQuery := cQrySel + cQryFrm + cQryWhr

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If (cAlias)->(Eof())
		cCodNum    := Self:GetValor("NUM_COD")
		aCamposOld := aClone(Self:aColunas)
		aSize(Self:aColunas,0)

		For nI := 1 to Len(aFields)
			aAdd(Self:aColunas, {aFields[nI]})
		Next

		cAliasNum := GetNextAlias()
		cQuery    := Self:MontaSQL()

		cQuery += " AND NUM_COD = '" + cCodNum + "'"
		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNum, .F., .F. )

		While !(cAliasNum)->(Eof())
			For nI := 1 to Len(aFields)
				aAdd(aAux, (cAliasNum)->(&(aFields[nI])))
			Next

			aAdd(aAliSel, aAux)
			(cAliasNum)->(DbSkip())
		End

		aSize(Self:aColunas,0)
		Self:aColunas := aClone(aCamposOld)

		(cAliasNum)->( dbCloseArea() )
	Else
		While !(cAlias)->( Eof() )
			For nI := 1 to Len(aFields)
				aAdd(aAux, (cAlias)->(&(aFields[nI])))
			Next

			aAdd(aAliSel, aAux)
			(cAlias)->(DbSkip())
			aAux := {}
		End
	EndIf
	(cAlias)->( dbCloseArea() )

	RestArea(aArea)
Return aAliSel

//-------------------------------------------------------------------
/*/{Protheus.doc} SetErro()
Atualiza a descrição do erro

@param	cErro - Descrição do erro
@author Rafael Tenorio da Costa
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method SetErro(cErro) CLASS TJurAnexo
	Self:cErro := cErro
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetErro()
Pega a descrição do erro

@author Rafael Tenorio da Costa
@return	Self:cErro - Descrição do erro
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method GetErro() CLASS TJurAnexo
Return Self:cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCajuri()
Retorna o código do assunto jurídico

@return Self:cCajuri - Código do assunto jurídico
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetCajuri() CLASS TJurAnexo
Return Self:cCajuri

//-------------------------------------------------------------------
/*/{Protheus.doc} SetUsuario()
Seta o usuario

@param  cUsuario - Código do usuario
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method SetUsuario(cUsuario) CLASS TJurAnexo
	Self:cUsuario := cUsuario
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUsuario()
Retorna o usuario

@return Self:cUsuario - Código do usuario
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetUsuario() CLASS TJurAnexo
Return Self:cUsuario

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSenha()
Seta a senha do usuario

@param  cSenha - Senha do usuario
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method SetSenha(cSenha) CLASS TJurAnexo
	Self:cSenha := cSenha
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSenha()
Retorna a senha do usuario

@return Self:cSenha - Senha do usuario
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetSenha() CLASS TJurAnexo
Return Self:cSenha

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEmpresa()
Seta o codigo da empresa

@param  cEmpresa - Código da empresa
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method SetEmpresa(cEmpresa) CLASS TJurAnexo
	Self:cEmpresa := cEmpresa
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEmpresa()
Retorna o codigo da empresa

@return Self:cEmpresa - Código da empresa
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetEmpresa() CLASS TJurAnexo
Return Self:cEmpresa

//-------------------------------------------------------------------
/*/{Protheus.doc} SetUrl()
Seta a URL para conexão

@param  cUrl - URL para conexão
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method SetUrl(cUrl) CLASS TJurAnexo
	Self:cUrl := cUrl
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUrl()
Retorna a URL para conexão

@return Self:cUrl - URL para conexão
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetUrl() CLASS TJurAnexo
Return Self:cUrl

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDocumento()
Seta o documento que esta sendo manipulado

@param  cDocumento - Documento que esta sendo manipulado
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method SetDocumento(cDocumento) CLASS TJurAnexo
	Self:cDocumento := cDocumento
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDocumento()
Retorna o documento que esta sendo manipulado

@return Self:cDocumento - Documento
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetDocumento() CLASS TJurAnexo
Return Self:cDocumento

//-------------------------------------------------------------------
/*/{Protheus.doc} SetLinkCaso()
Seta o link do caso do Fluig NZ7_LINK.

@param	cLinkCaso  	   - Link do caso no Fluig
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method SetLinkCaso(cLinkCaso) CLASS TJurAnexo
	Self:cLinkCaso := cLinkCaso
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLinkCaso()
Retorna o link do caso do Fluig NZ7_LINK, com ou sem versão.

@param	lVersao   	   - Define se ira retornar com o versão ou não
@return Self:cLinkCaso - Link do caso no Fluig
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetLinkCaso(lVersao) CLASS TJurAnexo
Return Self:cLinkCaso

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPasta
Verifica se o documento já existe na NUM, para a entidade.

@param  cDoc	  - Nome arquivo
@param  cExtensao - Extensão do arquivo
@return	lExiste   - Define se o documento existe para a entidade
@author Rafael Tenorio da Costa
@since  14/05/2018
/*/
//-------------------------------------------------------------------
Method ExisteDoc(cDoc, cExtensao) CLASS TJurAnexo

	Local aArea	   := GetArea()
	Local cQuery   := ""
	Local lExiste  := .F.
	Local lBaseCon := SuperGetMv('MV_JDOCUME', ,'1') == "2" // Base de Conhecimento

	Self:cErro := ""
	
	Self:SetAnxLegalDesk(.F.)

	cQuery := " SELECT NUM_FILIAL, NUM_COD, NUM_NUMERO"
	cQuery += " FROM " + RetSqlName("NUM")
	cQuery += " WHERE NUM_FILIAL = '" + xFilial("NUM") + "'"
	cQuery += 	" AND NUM_ENTIDA = '" + Self:cEntidade + "'"
	cQuery += 	" AND NUM_FILENT = '" + PadR(Self:cFilEnt, TamSx3("NUM_FILENT")[1]) + "'"
	cQuery += 	" AND NUM_CENTID = '" + PadR(Self:cCodEnt, TamSx3("NUM_CENTID")[1])	+ "'"
	cQuery += 	" AND " + JurFormat('NUM_DOC', .T./*lAcentua*/,.T./*lPontua*/) + " = "
	cQuery +=          "'" + PadR( Lower( StrTran( JurLmpCpo( cDoc, .F. ), '#', '' ) ), TamSx3("NUM_DOC")[1]) + "' "
	cQuery += 	" AND NUM_EXTEN = '"  + PadR(cExtensao	 , TamSx3("NUM_EXTEN")[1]) 	+ "'"
	cQuery += 	" AND D_E_L_E_T_ = ' '"

	aRetorno := JurSQL(cQuery, "*")

	If Len(aRetorno) > 0
		Self:cErro := STR0028 + " " + cDoc + cExtensao	//"Documento já vinculado"
		lExiste := .T.

		If lBaseCon .And. FwIsInCallStack("J290OpcAnx") .And. Empty(aRetorno[1][3]) // Somente SIGAPFS (Anexo via LegalDesk)
			Self:SetAnxLegalDesk(.T.)
			Self:SetNUMCod(aRetorno[1][2])
		EndIf
	EndIf

	RestArea(aArea)

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifyMark(cMark)
Verifica se está marcado

@param  cMark - Marca de Seleção

@author Willian Y. Kazahaya
@since  28/05/2018
/*/
//-------------------------------------------------------------------
Method VerifyMark(cMark) CLASS TJurAnexo
Local lRet    := .F.

	NUM->( dbSetOrder( 1 ) )
	NUM->(dbSeek(xFilial('NUM') + Self:GetValor('NUM_COD')))

	lRet := !Empty(NUM->NUM_MARK) .AND. NUM->NUM_MARK == Self:cMarca

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCajuriSecRelac
Busca o Cajuri de Tabelas com relação secundária a NSZ.

@author Willian Y. Kazahaya
@since  28/05/2018
/*/
//-------------------------------------------------------------------
Method GetCajuriSecRelac() CLASS TJurAnexo
Local cRet     := ""
Local aSecRel  := JStrArrDst(Self:cHasSecRel, '|')
Local nA       := aScan(aSecRel,Self:cEntidade +'[')
Local nPosIni  := At('[',aSecRel[nA])
Local nPosFim  := At(']',aSecRel[nA])
Local cRelDom  := Substring(aSecRel[nA],1,nPosIni-1)
Local cRelcDom := Substring(aSecRel[nA],nPosIni+1, nPosFim-nPosIni-1)
Local aSx9     := {}
Local cQrySel  := " SELECT "
Local cQryFrm  := " FROM "
Local cQryWhr  := " WHERE "
Local cUnico   := ""
Local cQuery   := ""
Local cAlias   := GetNextAlias()
Local aQryWhr  := {}
Local nI       := 0

	cUnico  := AllTrim(FwX2Unico(cRelDom))

	aQryWhr := STRTOKARR(cUnico, "+")

	aSx9 := JURSX9(cRelDom, cRelcDom)

	cQrySel += cRelcDom + "_CAJURI Cajuri "

	cQryFrm += RetSqlName(cRelDom) + " " + cRelDom
	cQryFrm += " INNER JOIN " + RetSqlName(cRelcDom) + " " + cRelcDom + " ON (" + aSx9[1][1] + " = " + aSx9[1][2] + ")"
	cQryFrm +=                                                         " AND (" + cRelDom + "_FILIAL = " + cRelCDom + "_FILIAL)"

	For nI := 1 to Len(aQryWhr)
		If (nI == Len(aQryWhr))
			cQryWhr += aQryWhr[nI]
		Else
			cQryWhr += aQryWhr[nI] + "||"
		EndIf
	next nI

	cQryWhr += " = '" + xFilial(cRelcDom) + Self:cCodEnt + "'"

	cQuery := cQrySel + cQryFrm + cQryWhr

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If (cAlias)->(!Eof())
		cRet := (cAlias)->Cajuri
	EndIf

	(cAlias)->(dbCloseArea())
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZipFileDownload(aArquivos)
Zipa e baixa os documentos

@Param aArquivos - Array com endereço de arquivos para serem zipados.
@author Willian Y. Kazahaya
@since  28/05/2018
/*/
//-------------------------------------------------------------------
Method ZipFileDownload(aArquivos, cOrigem, cArqZip, cCajuri) CLASS TJurAnexo

	Local lRet     := .T.
	Local nCont    := 0
	Local cArquivo := ""

	Default cCajuri := ""
	Default cOrigem := MsDocPath()
	Default cArqZip := ""

	//Quando for web manda os arquivos para download
	For nCont:=1 To Len(aArquivos)

		//Web retira os caracteres especiais para mandar o arquivo para download
		cArquivo := AllTrim(aArquivos[nCont])
		cArquivo := SubStr(cArquivo, 1, Rat(".", cArquivo) - 1)
		cArquivo := StrTran(JurLmpCpo(cArquivo, .T.), "#", "_")

		//Carrega nome do arquivo e extensão
		cArquivo := cArquivo + SubStr(aArquivos[nCont], Rat(".", aArquivos[nCont]))

		//Envia via download
		If CpyS2TW(aArquivos[nCont], .T.) < 0
			lRet := .F.
			JurMsgErro( I18n(STR0034, {aArquivos[nCont]}) )	//"Erro ao efetuar download do arquivo: #1"
		EndIf
	Next nCont

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetArquivo
Retorna nome do arquivo.

@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Method RetArquivo(cPatchArq, lExtensao) CLASS TJurAnexo
	Local nPos        := 0
	Local cArquivo    := ""

	Default lExtensao := .F. //Define se sera retornada a extensao do arquivo
	
	If (nPos := Rat('\',cPatchArq)) > 0
		cPatchArq := SubStr(cPatchArq, nPos + 1)
	Endif

	If (nPos := Rat('/',cPatchArq)) > 0
		cPatchArq := SubStr(cPatchArq, nPos + 1)
	Endif

	cArquivo := cPatchArq

	If !lExtensao
		nPos 	 := Rat(".", cArquivo)
		cArquivo := SubStr(cArquivo, 1, nPos - 1)
	EndIf

Return cArquivo

//-------------------------------------------------------------------
/*/{Protheus.doc} ManipulaDoc
Função para manipular um documento. Seja durante a inclusão ou exclusão
de um documento

@param nOp - Operação
@param cNomArq - Nome do arquivo
@param cDirOrigem - Diretório de origem
@param cDirDestin - Diretório de destino
@param cNomEncrip - Nome encriptografado

@author Willian Yoshiaki Kazahaya
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method ManipulaDoc(nOp, cNomArq, cDirOrigem, cDirDestin, cNomEncrip) CLASS TJurAnexo
Local lRet := .T.

Default cNomEncrip := cNomArq
Default cDirOrigem := ""
Default cDirDestin := ""
Default nOp        := Self:getOperation()

	// Gera uma cópia do arquivo na pasta de destino
	If nOp == 3
		lRet := _CopyFile(cDirOrigem + cNomArq, cDirDestin + cNomEncrip)
	Else
		//Verifica se arquivo existe
		If File(cDirOrigem + cNomArq)

			//Apaga arquivos
		 	If FErase(cDirOrigem + cNomArq) <> 0
				lRet := .F.
				cCamFile := ""
				JurMsgErro( I18n("Erro ao apagar arquivo: #1", {TJABError( FError() )}) )	//"Erro ao apagar arquivo: #1"
		 	EndIf
		Else
			lRet := .F.
			cCamFile := ""
			JurMsgErro( I18n("Erro ao localizar arquivo: #1", {cNomArq}) )	//"Erro ao localizar arquivo: #1"
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AddArquivo(cArquivo)
Adiciona arquivos ao Array de Arquivos

@param cArquivo - Caminho do arquivo a ser inserido

@author Willian Yoshiaki Kazahaya
@since  07/03/2019
/*/
//-------------------------------------------------------------------
Method AddArquivo(cArquivo) CLASS TJurAnexo
	aAdd(Self:aArquivos, cArquivo)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearArquivo
Limpa o array de arquivos

@author Willian Yoshiaki Kazahaya
@since  07/03/2019
/*/
//-------------------------------------------------------------------
Method ClearArquivo() CLASS TJurAnexo
	aSize(Self:aArquivos, 0)
Return

/*/--------------------------------------/*/
/*/--------------------------------------/*/
/*/              Functions               /*/
/*/--------------------------------------/*/
/*/--------------------------------------/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} PastasNsz
Carrega as pastas na arvore que são filhas da NSZ.Cópia do método da JURA026A

@param oTree - Árvore da tela
@author Willian Yoshiaki Kazahaya
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function JAnxFldNsz(oTree)
Local aRegistros := JurSubPasta(/*cPasta*/)
Local nCont      := 0

	If oTree:TreeSeek("NSZ")

		For nCont:=1 To Len(aRegistros)

			cPasta := SubStr(aRegistros[nCont][1], 5)
			cCargo := AllTrim(aRegistros[nCont][1])

			oTree:AddItem( cPasta, cCargo, "FOLDER5", "FOLDER6", /*cFile1*/, /*cFile2*/, 2)
		Next nCont

		//Volta para pasta raiz
		oTree:TreeSeek("RAIZ")

		oTree:Refresh()
	EndIf

	ASize(aRegistros, 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSubPasta
Retonar as subpastas de anexos são filhas da NSZ.

@param cPasta - id da pasta
@param cTpAssunto - Tipo de assunto jurídico

@since 11/10/2017
/*/
//-------------------------------------------------------------------
Function JurSubPasta(cPasta, cTpAssunto)
Local aArea      := GetArea()
Local aRegistros := {}
Local cSql       := ""
Local nPos       := 0

Default cPasta	 := ""
Default cTpAssunto := c162TipoAs

	cSql := " SELECT NUM_DESC, R_E_C_N_O_"
	cSql += " FROM " + RetSqlName("NUM")
	cSql += " WHERE D_E_L_E_T_ = ' '"
	cSql +=   " AND NUM_FILIAL = '" + xFilial("NUM") + "'"
	cSql +=   " AND NUM_CENTID = ' ' "

	If !Empty(cPasta)
		cSql += " AND NUM_DESC = '" + cPasta + "'"
	EndIf

	aRegistros := JurSQL(cSql, {"NUM_DESC", "R_E_C_N_O_"})

	nPos := Iif(Len(aRegistros) > 0, aScan(aRegistros, {|aX| "NSZ_Logomarca" $ aX[1] }), 0)

	If (nPos > 0) .And. !("011" $ cTpAssunto)
		aDel(aRegistros, nPos)
		aSize(aRegistros, Len(aRegistros) - 1)
	ElseIf (nPos == 0) .And. ("011" $ cTpAssunto)
		setSubPasta("NSZ_Logomarca")
		aRegistros := JurSQL(cSql, {"NUM_DESC", "R_E_C_N_O_"})
	EndIf

	RestArea(aArea)

Return aRegistros

//-------------------------------------------------------------------
/*/{Protheus.doc} setSubPasta
Retonar as subpastas de anexos são filhas da NSZ.

@param cPasta - id da pasta
@param cEntidade - Nome da entidade
@since 11/10/2017
/*/
//-------------------------------------------------------------------
Static Function setSubPasta(cPasta, cEntidade)
Local aArea      := GetArea()
Default cEntidade := "NSZ"

	NUM->(dbSetOrder(1))
	RecLock("NUM", .T.)
		NUM->NUM_FILIAL := xFilial("NUM")
		NUM->NUM_COD    := GetSxeNum("NUM")
		NUM->NUM_ENTIDA := cEntidade
		NUM->NUM_DESC   := cPasta
	NUM->( MsUnLock() )

	If __lSX8
		ConfirmSX8()
	EndIf

	RestArea(aArea)

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TJurDelAnx
Deleta documentos anexados por uma entidade.

@since 13/03/2020

@param cCajuri      - Código do Assunto jurídico
@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade
@return lRet        - Retorno booleano que informa se foi possivel 
                      realizar a exclusão dos documentos anexados na entidade
/*/
//-------------------------------------------------------------------
Function TJurDelAnx(cCajuri,cEntidade,cCodEnt)
Local lRet          := .T.
Local cTmpAlias     := ""
Local cCodDoc       := ""
Local oAnexo        := nil
Local cParam        := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))

Default cCajuri     := ""
Default cEntidade   := ""
Default cCodEnt     := ""

	Do Case
	Case cEntidade == "NT2"
		cCodEnt := cCajuri + cCodEnt
	Case cEntidade == "NT3"
		cCodEnt := cCajuri + cCodEnt
	Case cEntidade == "NSY"
		cCodEnt := cCodEnt + cCajuri
	End Case

	cTmpAlias   := GetListDoc(cCajuri,cEntidade,cCodEnt)

	oAnexo	  := getAnexo(cEntidade, cCodEnt,cCajuri,cParam)

	Begin Transaction

		While (cTmpAlias)->(!Eof())

			cCodDoc := (cTmpAlias)->NUM_COD

			If cParam <> '3' //Diferente de Fluig
				lRet :=  oAnexo:DeleteNUM(cCodDoc)
			Else //Se for fluig
				lRet :=  oAnexo:Excluir(cCodDoc)
			Endif

			If !lRet
				DisarmTransaction()
				Break
			Endif
			(cTmpAlias)->(DbSkip())
		End

	End Transaction

	(cTmpAlias)->(dbCloseArea())

	FwFreeObj(oAnexo)
	oAnexo := Nil

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAnexo
função responsavel pelo retorno do objeto de anexo conforme parametro definido
para realiar as operações necessárias

@since 13/03/2020

@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade
@param cCodProc     - Código do Assunto jurídico
@param cParam       - Informa qual o conteudo utilizado no parametro MV_JDOCUME
@return oAnexo      - Retorna o objeto de anexo conforme o parametro selecionado
/*/
//------------------------------------------------------------------------------
Static Function getAnexo(cEntidade, cCodEnt,cCodProc,cParam)
Local oAnexo  := Nil

Default cEntidade := ""
Default cCodEnt   := ""
Default cCodProc  := ""
Default cParam    := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))

	Do Case
	Case cParam == '1'
		oAnexo := TJurAnxWork():New(STR0039, cEntidade, xFilial(cEntidade), cCodEnt, 1,cCodProc) //"WorkSite"
	Case cParam == '2'
		oAnexo := TJurAnxBase():NewTHFInterface(cEntidade, cCodEnt, cCodProc) //"Base de Conhecimento"
	Case cParam == '3'
		oAnexo := TJurAnxFluig():New(STR0040, cEntidade, xFilial(cEntidade), cCodEnt, 1, .F. ) //"Documentos em Destaque - Fluig"
	EndCase


return oAnexo

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetListDoc
Função que realiza a busca dos documentos conforme os dados da entidade informada

@since 13/03/2020

@param cCajuri      - Código do Assunto jurídico
@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade
@return cTmpAlias   - Retorna uma consulta conforme os dados informados nos parametros
/*/
//------------------------------------------------------------------------------
static Function GetListDoc(cCajuri,cEntidade,cCodEnt)
Local cTmpAlias     := GetNextAlias()
Local cQuery        := ""
Local cQrySel       := ""
Local cQryFrm       := ""
Local cQryWhr       := ""
Local cIdxEnt       := ""
Local cEntDom       := "NSZ"
Local cIdxDom       := Replace(AllTrim(FwX2Unico(cEntDom)),'+','||')
Local cBanco        := Upper(TcGetDb())

Default cCajuri     := ""
Default cEntidade   := ""
Default cCodEnt     := ""

	cQrySel := " SELECT NUM_COD"
	
	If !Empty(cEntidade)

		cQryFrm := ' FROM ' + RetSqlName(cEntDom) + ' ' + cEntDom

		If cEntidade != cEntDom //Se a entidade for diferente gda NSZ é feito um INNER JOIN
			cQryFrm += " INNER JOIN " + RetSqlName(cEntidade) + " " + cEntidade + " ON (" + cEntDom + "_COD = " + cEntidade + "_CAJURI)"
			cQryFrm +=                                                           " AND (" + cEntDom + "_FILIAL = " + cEntidade + "_FILIAL)"
		EndIf

		cIdxEnt := Replace(AllTrim(FwX2Unico(cEntidade)),'+','||')

		If cBanco == "POSTGRES"
			If JurHasClas()
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(CONCAT(NUM.NUM_FILENT , NUM.NUM_CENTID)) = RTRIM(CONCAT(" + replace(cIdxEnt,"||",",") + ") )"
			Else
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(NUM.NUM_CENTID) = RTRIM(CONCAT(" + replace(cIdxEnt,"||",",") + ") )"
			EndIf

			If !Empty(cCodEnt)
				cQryWhr := " WHERE RTRIM(CONCAT(" + cIdxEnt + ")) = RTRIM('" + xFilial(cEntidade) + cCodEnt + "')"
			Else
				cQryWhr := " WHERE " + cIdxDom + " = '" + xFilial(cEntDom) + cCajuri + "'"
			EndIf

		Else
			If JurHasClas()
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(NUM.NUM_FILENT || NUM.NUM_CENTID) = RTRIM(" + cIdxEnt + ")"
			Else
				cQryFrm += " INNER JOIN " + RetSqlName('NUM') + " NUM ON RTRIM(NUM.NUM_CENTID) = RTRIM(" + cIdxEnt + " )"
			EndIf

			If !Empty(cCodEnt)
				cQryWhr := " WHERE " + cIdxEnt + " = '" + xFilial(cEntidade) + cCodEnt + "'"
			Else
				cQryWhr := " WHERE " + cIdxDom + " = '" + xFilial(cEntDom) + cCajuri + "'"
			EndIf
		EndIf

		cQryWhr +=   " AND " + cEntDom + ".D_E_L_E_T_ = ' ' "

		cQryWhr +=   " AND NUM.D_E_L_E_T_ = ' '"
		cQryWhr +=   " AND NUM.NUM_ENTIDA = '" + cEntidade + "'"
	Else
		cQryFrm := " FROM " + RetSqlName('NUM') + " NUM"

		cQryWhr := " WHERE (NUM.D_E_L_E_T_ = ' ') "

	EndIf

	cQuery := cQrySel + cQryFrm + cQryWhr

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cTmpAlias, .F., .F. )

Return cTmpAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} JAjustaNum
Ajusta o número do anexo (NUM_NUMERO).
Utilizado somente na inclusão de anexos via LegalDesk (Integração com SIGAPFS)

@param cNumCod, Código do anexo da NUM
@param cNumero, Número do anexo na base de conhecimento

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//------------------------------------------------------------------------------
Static Function JAjustaNum(cNumCod, cNumero)

	NUM->(dbSetOrder(1))
	If NUM->(dbSeek(xFilial('NUM') + cNumCod))
		RecLock("NUM", .F.)
			NUM->NUM_NUMERO := cNumero
		NUM->( MsUnLock() )
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetAnxLegalDesk
Define se é um anexo feito pelo LegalDesk (Integração SIGAPFS)

@Param lAnexoLD - Indica se o anexo foi incluído pelo LegalDesk

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//-------------------------------------------------------------------
Method SetAnxLegalDesk(lAnexoLD) CLASS TJurAnexo
	Self:lAnxLegalDesk := lAnexoLD
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAnxLegalDesk
Retorna se o anexo foi feito pelo LegalDesk (Integração SIGAPFS)

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//-------------------------------------------------------------------
Method GetAnxLegalDesk() CLASS TJurAnexo
Return Self:lAnxLegalDesk

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetNUMCod
Seta o código do anexo (NUM_COD)

@param cNumCod, Código do anexo da NUM

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//------------------------------------------------------------------------------
Method SetNUMCod(cNumCod) CLASS TJurAnexo
	Self:cNUMCod := cNumCod
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetNUMCod
Retorna o código do anexo (NUM_COD)

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//------------------------------------------------------------------------------
Method GetNUMCod() CLASS TJurAnexo
Return Self:cNUMCod

//------------------------------------------------------------------------------
/*/{Protheus.doc} FSincAnexo
Adiciona/Remove os anexos na fila de sincronização - SOMENTE SIGAPFS

@param cOpc, Operação realizada (3 = Inclusão, 5 = Exclusão)

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//------------------------------------------------------------------------------
Method FSincAnexo(cOpc) CLASS TJurAnexo
	
	If Self:lEntPFS // Entidades do SIGAPFS
		If FindFunction("JGrAnxFila") .And. JGrAnxFila(Self:cEntidade) // Verifica se os anexos dessa entidade serão gravados na fila
			J170GRAVA("NUM", xFilial("NUM") + Self:GetNUMCod(), cOpc) // Grava registro de anexo na fila
		EndIf
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MontaExp
Monta as expressões de filtro da entidade cWhrEnt e retorna os campos de relacionamento com a NUM

@param cChvTab    , Chave única (X2_UNICO) da tabela
@param cChvTre    , Chave da entidade a se relacionar com o NUM_CENTID
@param cFilTre    , filial da entidade a se relacionar com o NUM_FILENT

@return cWhereEnt , Expressão da Query da entidade

@author fabiana.silva
@since  11/01/2022
/*/
//------------------------------------------------------------------------------
Method MontaExp(cChvTab, cChvTre, cFilTre) CLASS TJurAnexo
Local nPosIni   := 1
Local nPosFim   := 0
Local nPos      := 0
Local aCposChv  := ""
Local cWhere    := ""
Local cDelimit  := "'"
Local cConteudo := ""
Local lFilial   := .F.

	aCposChv := StrtoArray(cChvTab, "+")
	For nPos := 1 to Len(aCposChv)
		nPosFim   := GetSx3Cache(aCposChv[nPos],"X3_TAMANHO")
		cConteudo := Self:cCodEnt
		If (lFilial := (nPos == 1 .And. "_FILIAL" $ aCposChv[nPos]))
			cFilTre   := aCposChv[nPos]
			cConteudo := Self:cFilEnt
		Else
			cChvTre += "+" + aCposChv[nPos]
		EndIf
		cWhere  += " AND " + aCposChv[nPos] + " = " + cDelimit + Substr(cConteudo, nPosIni, nPosFim) + cDelimit
		nPosIni += IIf(lFilial, 0, nPosFim)
	Next nPos

	If !Empty(cWhere)
		cWhere  := Substr(cWhere, 5)
		cChvTre := Substr(cChvTre, 2)
	EndIf
Return cWhere
