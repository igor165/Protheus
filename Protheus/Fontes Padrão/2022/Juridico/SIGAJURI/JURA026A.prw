#INCLUDE "JURA026A.CH"
#INCLUDE "PROTHEUS.CH"

//Formatação do campo de busca (oGetSearch)
#DEFINE CSSEdit "QLineEdit {" +;
  "border-width: 2px;" +;
  "border: 1px solid #C0C0C0;" +;
  "border-radius: 3px;" +;
  "border-color: #C0C0C0;"  +;
  "font: bold 12px Arial;" +;
  "}"

//Formatação dos botão Pesquisar
#DEFINE CSSButton "QPushButton {" +;
      "cursor: pointer; color: rgb(79, 84, 94);" +;
      "border: 1px solid rgb(216, 216, 216);" +;
      "border-radius: 3px;" +;
      "background-color: rgb(245, 245, 245);"+;
      "}" +;
      "QPushButton:hover:!pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(255, 255, 255), stop: 1 rgb(230, 230, 230));}"+;
      "QPushButton:hover:pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(230, 230, 230), stop: 1 rgb(255, 255, 255));}"

//-------------------------------------------------------------------
/*/{Protheus.doc} J026BasCon
Nova tela de base de conhecimento.

@param cEntidade	- Entidade que tera documento vinculados
@param nOperacao	- Tipo da operação
@param nRecno		- Recno do registro posicionado referente a entidade
@param cCajuri      - Cod Assunto juridico
@param cCodOri      - Código origem
@param cFilOrig     - Filial Origem

@author Rafael Tenorio da Costa
@since 29/08/16
/*/
//-------------------------------------------------------------------
Function J026aBaCon(cEntidade, nOperacao, nRecno, cCajuri, cCodOri, cFilOrig)

	Local aArea		:= GetArea()
	Local aAreaEnt	:= {}
	Local oModal 		:= Nil
	Local oPanel 		:= Nil
	Local oLayer 		:= Nil
	Local oTree	 	:= Nil
	Local oFont  		:= TFont():New( "Arial"/*cName*/, /*uPar2*/, 15/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/)
	Local oEntidades	:= Nil
	Local oPesquisa	:= Nil
	Local oDocumentos	:= Nil
	Local oBtnSearch	:= Nil
	Local oGetSearch	:= Nil
	Local oSelect	 	:= Nil
	Local aCampos	 	:= {}
	Local aColunas 	:= {}
	Local cMarca	 	:= GetMark()
	Local cPesquisa	:= Space( TamSx3("NUM_DOC")[1] )
	Local nI			:= 0

	Default cEntidade	:= "NSZ"
	Default nOperacao	:= 2		//Visualizar
	Default nRecno	:= 0
	Default cCajuri  	:= ""
	Default cCodOri 	:= ""
	Default cFilOrig    := xFilial(cEntidade)

	//Posiciona na entidade e registro
	If nRecno > 0
		aAreaEnt := (cEntidade)->( GetArea() )

		DbSelectArea(cEntidade)
		DbGoTo(nRecno)
	EndIf

	oModal := FWDialogModal():New()
	oModal:SetFreeArea(500, 230)
	oModal:SetEscClose(.T.)				//Permite fechar a tela com o ESC
	oModal:SetBackground(.T.)			//Escurece o fundo da janela
	oModal:SetTitle(STR0001)			//"Base de Conhecimento"
	oModal:EnableFormBar(.T.)
	oModal:CreateDialog()
	oModal:CreateFormBar()				//Cria barra de botoes


	//Inclui botoões
	If JA162AcRst('03',3)
		//"Importar"
		oModal:AddButton( STR0003, {|| Processa( {|| Importar(oTree, oSelect, cMarca, cPesquisa, cEntidade, cCajuri, cCodOri, cFilOrig)} , STR0051 /*Aguarde*/, STR0052/*Anexando...*/, .F. )	}, STR0003, , .T., .F., .T., )
	EndIf

	If JA162AcRst('03')
		//"Exportar"
		oModal:AddButton( STR0004, {|| Processa( {|| Exportar(oTree, oSelect, cMarca, cPesquisa, , cCajuri, cFilOrig)}, STR0051, , .F. ) }, STR0004, , .T., .F., .T., )
	EndIf

	If JA162AcRst('03',5)
		//"Excluir"
		oModal:AddButton( STR0005, {|| Excluir(oTree, oSelect, cMarca, cPesquisa, cEntidade, cCajuri, cCodOri, cFilOrig)}, STR0005, , .T., .F., .T., )
	EndIf

	//Fechar
	oModal:AddCloseButton()
	oModal:setInitBlock( {|| LimparMark(oSelect)} )

	oPanel := oModal:GetPanelMain()

	oLayer := FwLayer():New()
	oLayer:Init(oPanel, .F.)

	//Entidades
	oLayer:AddCollumn("COLUNA1", 30, .F., 	/*cIDLine*/)
	oLayer:AddWindow("COLUNA1", "WINDOW1", STR0006, 100, .F., .F., {|| .T.}, /*cIDLine*/, {|| .T.})	//"Entidades"

	oEntidades := oLayer:getWinPanel("COLUNA1", "WINDOW1")

	//Cria Arvore
	//New(nTop, nLeft, nBottom 				, nRight  	  	   , oWnd	   , bChange	  																									, bRClick	 , lCargo , lDisable    , oFont, cHeaders	 )
	oTree := DbTree():New(0	  , 0	 , oEntidades:nBottom	, oEntidades:nRight, oEntidades, {|| AtuGrid(oTree, oSelect, cMarca, , cCajuri, cCodOri, cFilOrig), cPesquisa:= Space(TamSx3("NUM_DOC")[1]), oTree:SetFocus()}	, /*bRClick*/, .T.	  , /*lDisable*/, oFont, /*cHeaders*/)

	If cEntidade == "NSZ"

		//AddItem( cPrompt			, cCargo			, cRes1	   	, cRes2	  	, cFile1	, cFile2	, nTipo)
		oTree:AddItem( PadR(STR0008, 50), PadR("RAIZ", 50)	, "FOLDER10", "FOLDER11", /*cFile1*/, /*cFile2*/, 1)	//"Raiz"
		oTree:AddItem( STR0007			, "NSZ"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Assunto Jurídico"

		//Adiciona pastas filhas da NSZ
		PastasNsz(oTree)

		oTree:AddItem( STR0009			, "NT4"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Andamentos"
		oTree:AddItem( STR0010			, "NTA"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Follow-ups"
		oTree:AddItem( STR0011			, "NT2"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Garantias"
		oTree:AddItem( STR0012			, "NT3"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Despesas"
		oTree:AddItem( STR0013			, "NUQ"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Instâncias"
		oTree:AddItem( STR0014			, "NSY"				, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 2)	//"Objetos"

	Else
		oTree:AddItem( JurX2Nome(cEntidade)	, cEntidade 		, "FOLDER5"	, "FOLDER6"	, /*cFile1*/, /*cFile2*/, 1)
	EndIf

	//Pesquisa
	oLayer:AddCollumn("COLUNA2", 70, .F., 	/*cIDLine*/)
	oLayer:AddWindow("COLUNA2", "WINDOW2", STR0015, 20, .F., .F., {|| .T.}, /*cIDLine*/, {|| .T.})	//"Pesquisa"

	oPesquisa := oLayer:getWinPanel("COLUNA2", "WINDOW2")

	//Cria campo de pesquisa
	AddCSSRule("TGet", CSSEdit)
	oGetSearch := TGet():Create(oPesquisa)
	oGetSearch:cName 	:= "oGetSearch"
	oGetSearch:bSetGet  := {|u| If( pCount() > 0, cPesquisa := u, cPesquisa)}
	oGetSearch:nTop 	:= 5
 	oGetSearch:nLeft 	:= 5
	oGetSearch:nHeight 	:= 32
 	oGetSearch:nWidth 	:= oPesquisa:nRight - 120
	oGetSearch:SetFocus()

	//Cria botão de pesquisa
	AddCSSRule("TButton", CSSButton)
	oBtnSearch := TButton():Create(oPesquisa)
	oBtnSearch:cName 	 := "oBtnSearch"
	oBtnSearch:cCaption  := STR0016	//"Pesquisar"
	oBtnSearch:blClicked := {|| AtuGrid(oTree, oSelect, cMarca, cPesquisa, cCajuri, cCodOri, cFilOrig) }
	oBtnSearch:nTop 	 := 5
	oBtnSearch:nLeft 	 := oGetSearch:nWidth + 10
	oBtnSearch:nHeight 	 := 32
	oBtnSearch:nWidth 	 := 90

	//Documentos
	oLayer:AddWindow("COLUNA2", "WINDOW3", STR0017, 80, .F., .F., {|| .T.}, /*cIDLine*/, {|| .T.})	//"Documentos"

	oDocumentos := oLayer:getWinPanel("COLUNA2", "WINDOW3")

	//Cria grid
	Aadd(aCampos, {"NUM_ENTIDA"	, JA160X3Des("NUM_ENTIDA")	, "C", TamSx3("NUM_ENTIDA")[1]	})
	Aadd(aCampos, {"NUM_DOC" 	, JA160X3Des("NUM_DOC")		, "C", 50 	/*"@!S80"*/			})
	Aadd(aCampos, {"NUM_EXTEN" 	, JA160X3Des("NUM_EXTEN")	, "C", 5 	/*"@!S5"*/			})

	For nI := 1 To Len( aCampos )
	    AAdd( aColunas, FWBrwColumn():New() )

	    aColunas[nI]:SetData( &( "{|| " + aCampos[nI][1] + " }" ) )
	    aColunas[nI]:SetTitle( aCampos[nI][2] )
	    aColunas[nI]:SetType(aCampos[nI][3] )
	    aColunas[nI]:SetSize( aCampos[nI][4] )
	    aColunas[nI]:SetAutoSize(.T.)
	Next nI

	oSelect := TJurBrowse():New(oDocumentos)
	oSelect:SetDataTable()
	oSelect:SetAlias("NUM")
	oSelect:AddMarkColumns( {|| IIF(!Empty(NUM->NUM_MARK), "LBOK", "LBNO")}, {|| SelectMark(oSelect, cMarca)}, {|| MarcaTudo(oSelect, cMarca)})
	oSelect:SetColumns( aColunas )
	oSelect:SetDoubleClick({|| Processa( {|| Exportar(oTree, oSelect, cMarca, cPesquisa, .T., cCajuri, cFilOrig)} , STR0051, , .F. )})	//Abre documento

	//Atualiza dados do grid
	AtuGrid(oTree, oSelect, cMarca, /*cPesquisa*/, cCajuri, cCodOri, cFilOrig)
	oSelect:Activate(.F.)

	oModal:Activate()

	//Limpa registros selecionados quando fechar tela
 	LimpaSel(cMarca)

	ASize(aCampos	, 0)
	ASize(aColunas	, 0)

	If Len(aAreaEnt) > 0
		RestArea(aAreaEnt)
	EndIf
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar
Faz a importação dos arquivos selecionado e gravação das tabelas ACB, AC9 e NUM.

@param  oTree     - Árvore da tela
@param  oSelect   - Grid da tela
@param  cMarca    - Marca utilizada no campo NUM_MARK
@param  cPesquisa - Filtro que será aplicado ao grid de anexos
@param  cEntiTela - Entidade
@param  cCajuri   - Cód Assunto Juridico
@param  cCodOri   - Cód Origem
@param  cFilOrig  - Filial Origem
@return lRetorno  - Boolean (.T./.F.)

@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function Importar(oTree, oSelect, cMarca, cPesquisa, cEntiTela, cCajuri, cCodOri, cFilOrig)

	Local lRetorno	:= .T.
	Local cArquivos := ""
	Local aArquivos := {}
	Local nArq		:= 0
	Local cArq		:= ""
	Local cCodObj	:= ""
	Local cCodEnt 	:= ""
	Local cDirArq	:= ""
	Local cDirVir	:= ""
	Local cDestino	:= ""
	Local cEntidade := AllTrim( oTree:GetCargo() )
	Local lHtml		:= ( GetRemoteType() == 5 )
	Local cCodEntSE2:= ""
	Local cArqEdit  := ""

	Default cCajuri := ""
	Default cCodOri := ""
	Default cFilOrig := xFilial(cEntidade)

	If Empty(cCodOri)
		cCodOri := cCajuri
	EndIf

	//Verifica se eh item RAIZ
	If cEntidade == "RAIZ"

		JurMsgErro(STR0022)	//"Não é possível importar arquivos para este item da árvore"

	//Entidade que abriu a tela é diferente da usada
	ElseIf !(cEntiTela == SubStr(cEntidade, 1, 3))

		JurMsgErro( I18n(STR0023, {JurX2Nome( SubStr(cEntidade, 1, 3) )}) )	//"Para importar arquivos para esta entidade utilize a rotina de #1"

	Else

		//Caso de entidades que foram criadas pelo usuario
		If Len(cEntidade) > 3
			cDirVir	  := cEntidade
			cEntidade := SubStr(cEntidade, 1, 3)
		EndIf

		//Retorna o codigo da entidade
		cCodEnt := cFilOrig + cCodOri

		//Verifica se tem chave unica
		If !Empty(cCodEnt)

			//Seleciona os arquivos que seram importados
			cArquivos := cGetFile(STR0024, STR0025, , "C:\", .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_MULTISELECT), ,.F.)	//"Todos os arquivos|*.*"	\\"Seleção de arquivo(s)"

			If !Empty(cArquivos)

				//Carrega destino de gravação dos arquivos
				cDestino := MsDocPath()

				//Tratamento porque quando era smartclient html retornava servidor quando importava multiplos arquivos
				If lHtml .And. At("servidor\", cArquivos) > 0
					cArquivos := StrTran(cArquivos, "servidor", "")
				EndIf

				//Pega todos os arquivos
				aArquivos := StrTokArr(cArquivos, "|")

				For nArq:=1 to Len(aArquivos)

					//Nome do arquivo no diretorio fisico e referencia na tabela
					cCodObj := ""

					//Pega arquivo
					cDirArq := AllTrim(aArquivos[nArq])
					cArq	:= RetArquivo(cDirArq, .T.)
					
					//Verifica se o arquivo já existe
					If !J26aExiNum(cEntidade, xFilial(cEntidade), cCodEnt, cDirArq)	

						//Cria codigo de base de conhecimento
						cCodObj	 := CriaVar("ACB_CODOBJ", .T.)
						
						//Copia arquivo
						If __CopyFile(cDirArq, cDestino + "\" +cCodObj)
								
							//Grava arquivo na base de conhecimento
							If J26aGrBaCo(3, /*cCodNum*/, cCodObj, cEntidade, cCodEnt, cDirArq, cDirVir,,,cFilOrig)
							
								If cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1' //caso a entidade seja a NT3 e tenha integração com o financeiro
									//obtemos as informações do contas a pagar (SE2)  
									cCodEntSE2 := SubStr(cCodEnt, At(cCajuri, cCodEnt)+10,10)
									aDadosSE2 := JurQryAlc(cEntidade, cCajuri, cCodEntSE2, IIF(cEntidade == 'NT2','2','3'), .T.)
									If Len(aDadosSE2) > 0
										cSE2Chave := PadR((AllTrim(aDadosSE2[5])),GetSx3Cache("E2_PREFIXO","X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[4])),GetSx3Cache("E2_NUM",    "X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[6])),GetSx3Cache("E2_PARCELA","X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[7])),GetSx3Cache("E2_TIPO",   "X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[8])),GetSx3Cache("E2_FORNECE","X3_TAMANHO"))
										cSE2Chave += PadR((AllTrim(aDadosSE2[9])),GetSx3Cache("E2_LOJA",   "X3_TAMANHO"))
										
										//gravamos o mesmo anexo na AC9 e ACB para o titulo gerado
										cArqEdit := cleanString( RetArquivo(cDirArq, .F.), .F. ) + SubStr(RetArquivo(cDirArq, .T.),Rat(".", RetArquivo(cDirArq, .T.))) //substitui os caracteres especiais para salvar na base de conhecimento do financeiro
										If __CopyFile(cDirArq, cDestino + "\" +cArqEdit)
											//Cria codigo de base de conhecimento
											cCodObj	 := CriaVar("ACB_CODOBJ", .T.)
											J26aGrBaCo(3, /*cCodNum*/, cCodObj, "SE2", cSE2Chave, cArqEdit, /*cDirVir*/,,,cFilOrig)
										EndIf
									EndIf
								EndIf
							Else		
								lRetorno := .F.
								JurMsgErro( I18n(STR0027, {cArq}) )	//"Erro ao registrar o documento na base de conhecimento: #1"
							EndIf
						Else
							lRetorno := .F.
							JurMsgErro( I18n(STR0026, {cArq}) )	//"Erro ao copiar o documento para a base de conhecimento: #1"
						EndIf
	
						If !lRetorno
							Exit
						EndIf
					EndIf

				Next nArq

				//Atualiza informações da tela
				AtuGrid(oTree, oSelect, cMarca, cPesquisa,  cCajuri, cCodOri, cFilOrig)

				If lRetorno
					MsgInfo(STR0028)	//"Documento(s) importado(s)"
				EndIf
			EndIf
		EndIf

	EndIf

	ASize(aArquivos, 0)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Exportar
Faz a exportação dos arquivos selecionados.

@param  oTree	  - Árvore da tela
@param  oSelect	  - Grid da tela
@param  cMarca	  - Código que define que o registro foi selecionado
@param  cPesquisa - Pesquisa que foi feita na tela
@param  lAbrir	  - Define se foi selecionada a opção de abrir o arquivo
@param  cCajuri   - Cód Assunto Juridico
@param  cFilOrig  - Filial Origem
@return lRetorno  - Boolean (.T./.F.)

@since  05/09/16
/*/
//-------------------------------------------------------------------
Static Function Exportar(oTree, oSelect, cMarca, cPesquisa, lAbrir, cCajuri, cFilOrig)

	Local lRetorno   := .T.
	Local aRegistros := {}
	Local cOrigem    := MsDocPath()
	Local cDestino   := ""
	Local lHtml      := ( GetRemoteType() == 5 )
	Local cArquivo   := ""
	Local aArquivos  := {}
	Local cArqZip    := ""
	Local cArqs      := ""
	Local nCont      := 0
	Local cTipo      := ""
	Local cArqComp   := "" //caminho completo da origem física do arquivo

	Default lAbrir   := .F.
	Default cCajuri  := ""

	If lAbrir
		cDestino := GetTempPath()
	EndIf

	aRegistros := RetRegsSel(cMarca, lAbrir, cFilOrig)

	//Verifica se foram preenchidos os registros
	If Len(aRegistros) > 0

		cArqs := cValToChar( Len(aRegistros) )

 		If lAbrir .Or. ApMsgYesNo( I18n(STR0029, {cArqs}) )	//"Será(ão) exportado(s) #1 arquivo(s), confirma exportação ?"

			If lAbrir
				cTipo := STR0030	//"Selecione a pasta para abertura do arquivo"
			Else
				cTipo := STR0031	//"Selecione a pasta para exportação"
			EndIf

			//Carrega destino dos arquivos (Html - destino temporario)
			If lHtml
				cDestino := cOrigem + "\"
			Else
				If Empty(cDestino)
					cDestino := cGetFile(STR0024, STR0032, 0, "C:\", .F., nOr(GETF_LOCALHARD,GETF_RETDIRECTORY), .F.)	//"Todos os arquivos|*.*"	//"Selecione uma pasta"
				EndIf
			EndIf

			//verifica se preencheu o destino
			If !Empty(cDestino)

				For nCont:=1 To Len(aRegistros)

					//Monta nome do arquivo
					//Quando for web retira os caracteres especiais para mandar o arquivo para download
					If lHtml
						cArquivo := StrTran( JurLmpCpo( AllTrim(aRegistros[nCont][4] ), .T.), "#", "_")
						cArquivo := cArquivo + AllTrim(aRegistros[nCont][5])
					Else
						cArquivo := AllTrim(aRegistros[nCont][4]) + AllTrim(aRegistros[nCont][5])
					EndIf
					
					cArqComp := GetCaminho(aRegistros[nCont][3], cFilOrig)

					//Copia arquivos (Html para pasta temporaria)
					If __CopyFile(cArqComp, cDestino + cArquivo)
						Aadd(aArquivos, cDestino + cArquivo)
					Else
						lRetorno := .F.
						JurMsgErro( I18n(STR0033, {cDestino + "\" + cArquivo}) )	//"Erro ao copiar o documento para: #1"
						Exit
					EndIf
				Next nCont

				If lRetorno

					//Quando for web manda os arquivos para download
					If lHtml
						For nCont:=1 To Len(aArquivos)

							//Envia via download
							If CpyS2TW(aArquivos[nCont], .T.) < 0
								lRetorno := .F.
								JurMsgErro( I18n(STR0034, {aArquivos[nCont]}) )	//"Erro ao efetuar download do arquivo: #1"
							EndIf
						Next nCont
					EndIf

					If lRetorno

						If lAbrir

							//Abre arquivo, sempre será aberto um arquivo por vez, por causa do duplo clique no registro
							If !lHtml
								ShellExecute("open", cDestino + cArquivo, "", cDestino, 1)
							EndIf
						Else

							MsgInfo(STR0036)	//"Documento(s) exportado(s)"
						EndIf
					EndIf
				EndIf

				//Apaga arquivos que foram copiados antes do erro
				//Apaga arquivos temporarios gerados antes de zipar
 				If !lRetorno .Or. lHtml

					//Deleta arquivos temporarios
					For nCont:=1 To Len(aArquivos)

					 	If File(aArquivos[nCont]) .And. FErase(aArquivos[nCont]) <> 0
							lRetorno := .F.
							JurMsgErro( I18n(STR0037, {J026aErrAr( FError() )}) )	//"Erro ao apagar arquivo: #1"
					 	EndIf
				 	Next nCont

				 	//Deleta arquivo zip se existir
				 	If File(cOrigem + "\" + cArqZip)
				 		FErase(cOrigem + "\" + cArqZip)
				 	EndIf
				EndIf

			EndIf
		EndIf
	EndIf

	ASize(aRegistros, 0)
	ASize(aArquivos, 0)

 Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Excluir
Faz a exclusão dos arquivos selecionados e também exclui as tabelas ACB, AC9 e NUM.

@param  oTree	- Árvore da tela
@param  oSelect	- Grid da tela
@param  cMarca    - Marca utilizada no campo NUM_MARK
@param  cPesquisa - Filtro que será aplicado ao grid de anexos
@param  cEntiTela - Entidade
@param  cCajuri   - Cód Assunto Juridico
@param  cCodOri   - Cód Origem
@param  cFilOrig  - Filial Origem
@return lRetorno  - Boolean (.T./.F.)

@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function Excluir(oTree, oSelect, cMarca, cPesquisa, cEntiTela, cCajuri, cCodOri, cFilOrig)

	Local aArea      := GetArea()
	Local aAreaNUM   := NUM->( GetArea() )
	Local lRetorno   := .T.
	Local cEntidade  := AllTrim( oTree:GetCargo() )
	Local aRegistros := {}
	Local nReg       := 0
	Local cCodNum    := ""
	Local cCodObj    := ""
	Local cDirArq    := ""
	Local cArqs      := ""
	Local lExisteDoc := .T.
	Local aPasta     := {}
	Local cOrigem    := ""

	Default cCajuri  := ""
	Default cCodOri  := ""

	//Verifica se é pasta filha da NSZ, para saber se deve excluir a pasta
	If cEntiTela == "NSZ" .And. "NSZ_" $ cEntidade
		lExisteDoc := ExisteDocs("NSZ", cEntidade)
	EndIf

	//Busca registros selecionados
	If lExisteDoc
		aRegistros := RetRegsSel(cMarca, ,cFilOrig)

	//Exclusão de pasta filha de NSZ
	Else

		If cEntiTela == "NSZ" .And. "NSZ_" $ cEntidade

			If ApMsgYesNo( I18n(STR0038, {SubStr(cEntidade, 5)}) )	//"Deseja excluir a pasta #1 ?"

				aPasta := JurSubPasta(cEntidade)

				If Len(aPasta) > 0

					DbSelectArea("NUM")
					NUM->( DbGoTo(aPasta[1][2]) )
					If !NUM->( Eof() )

						If oTree:TreeSeek(cEntidade)

							oTree:DelItem()

							Reclock("NUM", .F.)
								NUM->( DbDelete() )
							NUM->( MsUnLock() )

							oTree:TreeSeek("NSZ")
							oTree:Refresh()
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//Verifica se foram selecionados os registros
	If Len(aRegistros) > 0

		//Verifica se eh item RAIZ
		If cEntidade == "RAIZ"

			JurMsgErro(STR0039)	//"Não é possível excluir arquivos neste item da árvore"

		//Entidade que abriu a tela é diferente da usada
		ElseIf !(cEntiTela == SubStr(cEntidade, 1, 3))

			JurMsgErro( I18n(STR0040, {JurX2Nome( SubStr(cEntidade, 1, 3) )}) )	//"Para excluir arquivos desta entidade utilize a rotina de #1"

		Else

			cArqs := cValToChar( Len(aRegistros) )

			If ApMsgYesNo( I18n(STR0041, {cArqs}) )	//"Será(ão) excluído(s) #1 arquivo(s), confirma exclusão ?"

				For nReg:=1 To Len(aRegistros)

					cCodNum := aRegistros[nReg][2]

					//Excluir arquivo na base de conhecimento
					If J26aGrBaCo(5, cCodNum, @cCodObj, /*cEntidade*/, /*cCodEnt*/, @cDirArq, /*cDirVir*/, @cOrigem,,cFilOrig)

						//Verifica se arquivo existe
						If File(cOrigem)

							//Apaga arquivos
						 	If FErase(cOrigem) <> 0
								lRetorno := .F.
								JurMsgErro( I18n(STR0037, {J026aErrAr( FError() )}) )	//"Erro ao apagar arquivo: #1"
						 	EndIf
						Else
							lRetorno := .F.
							JurMsgErro( I18n(STR0042, {cDirArq}) )	//"Erro ao localizar arquivo: #1"
						EndIf
						If lRetorno .AND. cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1'								
							//deletamos o mesmo anexo na AC9 e ACB para o titulo gerado
							lRetorno := J26aGrBaCo(5, /*cCodNum*/, /*cCodObj*/, "SE2"/*cEntidade*/, /*cCodEnt*/, AllTrim(aRegistros[nReg][4])+AllTrim(aRegistros[nReg][5])/*cDirArq*/, /*cDirVir*/, /*@cOrigem*/, 2/*nACBIndex*/, cFilOrig)
							If !lRetorno
								JurMsgErro(STR0068) //"Erro na exclusão da Base de Conhecimento do Contas a Pagar."
							EndIf
						EndIf
					Else

						lRetorno := .F.
						JurMsgErro( I18n(STR0043, {cDirArq}) )	//"Erro ao excluir o documento na base de conhecimento: #1"
					EndIf

					If !lRetorno
						Exit
					EndIf

				Next nReg

				//Atualiza informações da tela
				AtuGrid(oTree, oSelect, cMarca, cPesquisa, cCajuri, cCodOri, cFilOrig )

				If lRetorno
					MsgInfo(STR0044)	//"Documento(s) excluído(s)"
				EndIf

			EndIf
		EndIf
	EndIf

	ASize(aPasta, 0)
	ASize(aRegistros, 0)

	RestArea(aAreaNUM)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J26aGrBaCo
Faz a gravação das tabelas ACB, AC9 e NUM.

@param  nOpc      - Operação
@param  cCodNum   - Codigo do Documento
@param  cCodObj   - Código do objeto
@param  cEntidade - Tabela da Entidade
@param  cCodEnt   - Cód da Entidade
@param  cDirArq   - Diretório do arquivo/doc
@param  cDirVir   - Nome do arquivo/doc
@param  cOrigem   - Caminho origem do arquivo/doc
@param  nACBIndex - índice da tabela ACB a ser utilizado
@param  cFilOrig  - Filial origem
@return lRetorno  - Boolean (.T./.F.)

@since 31/08/16
/*/
//-------------------------------------------------------------------
Function J26aGrBaCo(nOpc, cCodNum, cCodObj, cEntidade, cCodEnt, cDirArq, cDirVir, cOrigem, nACBIndex, cFilOrig)

	Local aArea 	:= GetArea()
	Local aAreaNUM 	:= NUM->( GetArea() )
	Local aAreaACB 	:= ACB->( GetArea()	)
	Local aAreaAC9 	:= AC9->( GetArea() )
	Local cArquivo	:= ""
	Local cChave   := ""
	Local lRetorno 	:= .F.
	Local lIntPFS  := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
	Local lFSinc   := SuperGetMV("MV_JFSINC", .F., '2') == "1" // Indica se utiliza a integração com o Legal Desk (SIGAPFS)
	Local oModel   := Nil
	Local cAlias   := ""
	Local cChvACB   := ""

	Default cOrigem	:= ""
	Default cCodObj := ""
	Default cEntidade := ""
	Default nACBIndex := 1 //ACB_FILIAL+ACB_CODOBJ
	Default cFilOrig := xFilial(cEntidade)

	//Inclusão
	If nOpc == 3
	
		//Retorna nome do arquivo
		cArquivo := RetArquivo(cDirArq, .F.)
	
		//Bancos de Conhecimentos
		lRetorno := Reclock("ACB", .T.)
			ACB->ACB_FILIAL :=  xFilial("ACB")
			ACB->ACB_CODOBJ := cCodObj
			If cEntidade <> "SE2"
				ACB->ACB_OBJETO := cCodObj
				ACB->ACB_DESCRI := cArquivo
			Else				
				ACB->ACB_OBJETO := SubStr(cDirArq,Rat("\", cDirArq)+1)
				ACB->ACB_DESCRI := cArquivo
			EndIf
		ACB->( MsUnLock() )

		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo

		//Relacao de Objetos x Entidades
		If lRetorno
			 lRetorno := Reclock("AC9", .T.)
				AC9->AC9_FILIAL := xFilial("AC9")
				AC9->AC9_FILENT := cFilOrig
				AC9->AC9_ENTIDA := cEntidade
				AC9->AC9_CODENT := cCodEnt
				AC9->AC9_CODOBJ := cCodObj
			AC9->( MsUnLock() )
		EndIf

		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo

		//Documentos Juridicos
		If lRetorno .AND. cEntidade <> "SE2"
			lRetorno := Reclock("NUM", .T.)
				NUM->NUM_FILIAL := cFilOrig
				NUM->NUM_COD    := GetSXENum("NUM","NUM_COD")
				NUM->NUM_FILENT := cFilOrig
				NUM->NUM_ENTIDA := cEntidade
				NUM->NUM_CENTID := cCodEnt
				NUM->NUM_DOC    := cArquivo
				NUM->NUM_NUMERO := cCodObj
				NUM->NUM_DESC   := cDirVir
				NUM->NUM_EXTEN  := SubStr(cDirArq, Rat(".", cDirArq), 4)
			NUM->( MsUnLock() )
		EndIf

		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo
		
		If lRetorno .And. lIntPFS .And. lFSinc
			oModel := FWModelActive()
			If oModel:GetOperation() == 1 // Visualização
				Do Case
				Case oModel:GetId() == "JURA241"
					cAlias := "OHB"
					cChave := oModel:GetValue("OHBMASTER", "OHB_CODIGO")
				Case "JURA235" $ oModel:GetId()
					cAlias := "NZQ"
					cChave := oModel:GetValue("NZQMASTER", "NZQ_COD")
				Case oModel:GetId() == "JURA246"
					cAlias := "OHF"
					cChave := oModel:GetValue("OHFDETAIL", "OHF_IDDOC") + oModel:GetValue("OHFDETAIL", "OHF_CITEM")
				Case oModel:GetId() == "JURA247"
					cAlias := "OHG"
					cChave := oModel:GetValue("OHGDETAIL", "OHG_IDDOC") + oModel:GetValue("OHGDETAIL", "OHG_CITEM")
				EndCase
				J170GRAVA(cAlias, xFilial(cAlias) + cChave, "3")
			Endif
		Endif
	//Exclusão
	Else

		//Documentos Juridicos
		If Empty(cEntidade)
			NUM->( DbSetOrder(1) )	//NUM_FILIAL+NUM_COD
			If NUM->( DbSeek(cFilOrig + cCodNum) )
	
				//Pega o nome do arquivo
				cCodObj := NUM->NUM_NUMERO
	
				//Carrega o caminho para excluir o arquivo fisicamente
				cOrigem := GetCaminho(cCodObj, cFilOrig)
	
				//Retorna o nome do arquivo
				cDirArq := AllTrim(NUM->NUM_DOC) + AllTrim(NUM->NUM_EXTEN)
	
				lRetorno := RecLock("NUM", .F.)
					NUM->( DbDelete() )
				NUM->( MsUnLock() )
				
				While __lSX8
					If lRetorno
						ConfirmSX8()
					Else
						RollBackSX8()
					EndIf
				EndDo
			EndIf
		EndIf

		//Bancos de Conhecimentos
		ACB->( DbSetOrder(nACBIndex) )	
		If Empty(cEntidade)
			cChvACB := cCodObj
		ElseIf cEntidade == "SE2"
			//Retorna nome do arquivo
			cChvACB := AllTrim(cDirArq)
		EndIf
		If ACB->( DbSeek(cFilOrig + cChvACB) )
			cCodObj := ACB->ACB_CODOBJ
			lRetorno := RecLock("ACB", .F.)
				ACB->( DbDelete() )
			ACB->( MsUnLock() )
		EndIf
		
		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo
		
		//Relacao de Objetos x Entidades
		AC9->( DbSetOrder(1) )	//AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
		If AC9->( DbSeek(cFilOrig + cCodObj) )

			lRetorno := RecLock("AC9", .F.)
				AC9->( DbDelete() )
			AC9->( MsUnLock() )
		EndIf
		
		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else
				RollBackSX8()
			EndIf
		EndDo
		
		If lRetorno .And. lIntPFS .And. lFSinc
			oModel := FWModelActive() 
			If oModel:GetOperation() == 1 // Visualização
				Do Case
				Case oModel:GetId() == "JURA241"
					cAlias := "OHB"
					cChave := oModel:GetValue("OHBMASTER", "OHB_CODIGO")
				Case "JURA235" $ oModel:GetId()
					cAlias := "NZQ"
					cChave := oModel:GetValue("NZQMASTER", "NZQ_COD")
				Case oModel:GetId() == "JURA246"
					cAlias := "OHF"
					cChave := oModel:GetValue("OHFDETAIL", "OHF_IDDOC") + oModel:GetValue("OHFDETAIL", "OHF_CITEM")
				Case oModel:GetId() == "JURA247"
					cAlias := "OHG"
					cChave := oModel:GetValue("OHGDETAIL", "OHG_IDDOC") + oModel:GetValue("OHGDETAIL", "OHG_CITEM")
				EndCase
				J170GRAVA(cAlias, xFilial(cAlias) + cChave, "5")
			Endif
		Endif
	EndIf

	RestArea(aAreaAC9)
	RestArea(aAreaACB)
	RestArea(aAreaNUM)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} RetArquivo
Retorna nome do arquivo.

@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function RetArquivo(cPatchArq, lExtensao)

	Local nPos 		:= 0
	Local cArquivo	:= ""

	Default lExtensao := .F.		//Define se sera retornada a extensao do arquivo

	If (nPos := Rat("\", cPatchArq)) > 0
		cArquivo := SubStr(cPatchArq, nPos + 1)
	Endif

	If (nPos := Rat("/",cPatchArq)) > 0
		cArquivo := SubStr(cPatchArq, nPos + 1)
	Endif

	If !lExtensao
		nPos 	 := Rat(".", cArquivo)
		cArquivo := SubStr(cArquivo, 1, nPos - 1)
	EndIf

Return cArquivo

//-------------------------------------------------------------------
/*/{Protheus.doc} SelectMark
Faz o controle da marcação ou não do campo NUM_MARK.

@param	oSelect - Grid da tela
@param 	cMarca	- Código que define que o registro foi selecionado.
@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function SelectMark(oSelect, cMarca)

	RecLock("NUM", .F.)

		If Empty(NUM->NUM_MARK)
			NUM->NUM_MARK := cMarca
		Else
			NUM->NUM_MARK := ""
		Endif

	NUM->( MsUnLock() )

	oSelect:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SelectMark
Faz o controle da marcação ou não do campo NUM_MARK.

@param	oSelect - Grid da tela
@param 	cMarca	- Código que define que o registro foi selecionado.
@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function MarcaTudo(oSelect, cMarca)

	oSelect:GoTop(.T.)

	While !NUM->( Eof() )

		RecLock("NUM", .F.)

			If Empty(NUM->NUM_MARK)
				NUM->NUM_MARK := cMarca
			Else
				NUM->NUM_MARK := ""
			Endif

		NUM->( MsUnLock() )

		NUM->( DbSkip() )
	EndDo

	oSelect:Refresh(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuGrid
Função utilizada para atualizar o grid a partir da entidade selecionada
na tela de base de conhecimento.

@param  oTree 	- Árvore da tela
@param  oSelect	- Grid da tela
@param  cMarca	- Código que define que o registro foi selecionado.
@param  cPesquisa - Filtro que será aplicado ao grid de anexos
@param  cCajuri   - Cód Assunto Juridico
@param  cCodOri   - Cód Origem
@param  cFilOrig  - Filial Origem
@return Nil

@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function AtuGrid(oTree, oSelect, cMarca, cPesquisa, cCajuri, cCodOri, cFilOrig)

Local cCargo   := AllTrim( oTree:GetCargo() )
Local cFiltro  := ""
Local nNivel   := oTree:Nivel()

Default cPesquisa := ""
Default cCajuri   := ""
Default cCodOri   := ""
Default cFilOrig  := xFilial("NUM")

	cFiltro  := "NUM->NUM_FILIAL == '" + cFilOrig + "' .And. !Empty(NUM->NUM_DOC)"

 	If Empty(cCodOri)
 		cCodOri := cCajuri
 	EndIf
	//Filtra demais entidade quando for acessada a base de conhecimento a partir do assunto juridico
 	If !("NSZ" $ cCargo)
 		cFiltro += FiltroNsz(cCargo, cCajuri, cCodOri, nNivel, cFilOrig)

 	//Filtra entidade pelo registro posicionado
 	Else

 		//É pasta filha da NSZ
 		If "NSZ_" $ cCargo
			cFiltro += " .And. AllTrim(NUM->NUM_DESC) == AllTrim('" + cCargo + "')"

		Else
			cFiltro += " .And. NUM->NUM_ENTIDA == '" + cCargo + "'

			If cCargo == "NSZ"
				cFiltro += " .And. !(NUM->NUM_DESC $ 'NSZ_')"
			EndIf
		EndIf

		//Inclui filtro do registro posicionado
 		cFiltro += " .And. AllTrim((NUM->NUM_CENTID)) == AllTrim('" + AllTrim(cFilOrig + cCodOri) + "')"
 	EndIf

 	//Inclui filtro
 	If !Empty(cPesquisa)
		//Prepara pesquisa
		cPesquisa := AllTrim( Lower( JurLmpCpo(cPesquisa) ) )

		//Carrega filtro que será aplicado ao grid
		cPesquisa := " .And. '" + cPesquisa + "' $ Lower( JurLmpCpo(NUM->NUM_DOC) )"

 		cFiltro += cPesquisa
 	EndIf

 	//Limpa registros selecionados
 	LimpaSel(cMarca)

 	//Executa filtro
 	oSelect:SetFilterDefault(cFiltro)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetRegsSel
Retorna os documentos jurídicos que foram selecionados.

@param  cMarca		- Código que define que o registro foi selecionado.
@param  lAbrir      - Indica se irá abrir o arquivo para visualização
@param  cFilOrig    - Filial origem
@return	aRegistros	- Registros da NUM selecionados

@since 31/08/16
/*/
//-------------------------------------------------------------------
Static Function RetRegsSel(cMarca, lAbrir, cFilOrig)

	Local aArea		 := GetArea()
	Local aRegistros := {}
	Local cQuery	 := ""

	Default lAbrir	 := .F.
	Default cFilOrig  := xFilial("NUM") 

	cQuery := " SELECT NUM_FILIAL, NUM_COD, NUM_NUMERO, NUM_DOC, NUM_EXTEN"
	cQuery += " FROM " + RetSqlName("NUM")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND NUM_FILIAL = '" + cFilOrig + "'"

	If lAbrir
		cQuery += " AND R_E_C_N_O_ = " + cValToChar( NUM->(Recno()) )
	Else
		cQuery += " AND NUM_MARK = '" + cMarca + "'"
	EndIf

	aRegistros := JurSQL(cQuery, {"NUM_FILIAL", "NUM_COD", "NUM_NUMERO", "NUM_DOC", "NUM_EXTEN"})

	If Len(aRegistros) == 0
		JurMsgErro(STR0046)	//"Não foram selecionado(s) documento(s)"
	EndIf

	RestArea(aArea)

Return aRegistros

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaSel
Tira seleção dos documentos.

@param 	cMarca	 - Código que define que o registro foi selecionado.
@return	lRetorno - Retorna se o update foi executado corretamente.
@author  Rafael Tenorio da Costa
@since 01/09/16
/*/
//-------------------------------------------------------------------
Static Function LimpaSel(cMarca)

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cUpdate 	:= ""

	cUpdate := " UPDATE " + RetSqlName("NUM")
	cUpdate	+= " SET NUM_MARK = '  '"
	cUpdate	+= " WHERE D_E_L_E_T_ = ' '"
	cUpdate	+= 	" AND NUM_FILIAL = '" + xFilial("NUM") + "'"
	cUpdate	+= 	" AND NUM_MARK = '" + cMarca + "'"

	If TcSqlExec(cUpdate) < 0
		lRetorno := .F.
	  	JurMsgErro( I18n(STR0047, {TcSqlError()}) )	//"Erro ao desvicular o arquivo: #1"
	EndIf

	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PastasNsz
Carrega as pastas na arvore que são filhas da NSZ.

@param oTree - Árvore da tela
@author Rafael Tenorio da Costa
@since 06/09/16
/*/
//-------------------------------------------------------------------
Static Function PastasNsz(oTree)

	Local aRegistros := JurSubPasta(/*cPasta*/)
	Local nCont		 := 0

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
/*/{Protheus.doc} FiltroNsz
Filtro a partir da NSZ que será aplicado as demais entidades.

@param  cCargo    - Entidade posicionada
@param  cCajuri   - Cód Assunto Juridico
@param  cCodOri   - Código Origem
@param  nNivel    - Nível da árvore
@param  cFilOrig  - Filial Origem
@return cFiltro   - Filtro utilizado no grid de anexos

@since  08/09/16
/*/
//-------------------------------------------------------------------
Static Function FiltroNsz(cCargo, cCajuri, cCodOri, nNivel, cFilOrig)

	Local cFiltro 	:= ""
	Local aEntidades 	:= {"NT4","NTA","NT2","NT3","NUQ","NSY"}
	Local cEntidade	:= ""
	Local nCont		:= 0
	Local cTemp		:= "" //variável que vai guardar o filtro
	Local cCodConsu  	:= ""

	Default cCodOri 	:= ""
	Default nNivel  	:= 1
	Default cFilOrig    := xFilial(cCargo)

	If Empty(cCodOri)
		cCodOri := cCajuri
	EndIf

	If cCargo == "RAIZ"

		cFiltro := " .And. ("

		For nCont:=1 To Len(aEntidades)
			cEntidade := aEntidades[nCont]
			cTemp := CodsEntida(cEntidade, cCajuri, cFilOrig)
			if !Empty(cTemp) //valida se existem códigos
				cFiltro	  += " (NUM->NUM_ENTIDA == '" + cEntidade + "' .And. AllTrim(NUM->NUM_CENTID) $ '" + cTemp + "') .Or."
			Endif
		Next nCont

		cFiltro += " (NUM->NUM_ENTIDA == 'NSZ' .And. AllTrim(NUM->NUM_CENTID) == '" + AllTrim(cFilOrig + cCodOri) + "')"
		cFiltro += " )"
	Else
		cFiltro := " .And. NUM->NUM_ENTIDA == '" + cCargo + "' .And. AllTrim(NUM->NUM_CENTID) "

		If cCargo == "O0N"
			cCodConsu := AllTrim(xFilial(cCargo) + cCodOri)
			cFiltro += " $ '" + cCodConsu + "'"
		Else
			If !Empty(cCodOri) .AND. (nNivel == 1)
				cCodConsu := AllTrim(xFilial(cCargo) + cCodOri)
				cFiltro += " == '" + cCodConsu + "'"
			Else
				cCodConsu := CodsEntida(cCargo, cCajuri, cFilOrig)
				cFiltro += " $ '" + cCodConsu + "'"
			EndIf
		EndIf
	EndIf

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} CodsEntida
Codigos da entidades filtrados a partir da NSZ.

@param  cEntidade - Entidade posicionada
@param  cCajuri   - Cód Assunto Juridico
@param  cFilOrig  - Filial Origem
@return cCodigos  - Codigos da entidades

@since  08/09/16
/*/
//-------------------------------------------------------------------
Static Function CodsEntida(cEntidade, cCajuri, cFilOrig)

	Local aArea  	:= GetArea()
	Local cQuery 	:= ""
	Local cUnico	:= ""
	Local aCodigos	:= {}
	Local cCodigos	:= ""
	Local nCont		:= 0

	//Carrega campos que compõe o codigo da entidade

	cUnico  := FWX2Unico(cEntidade)

	cQuery := " SELECT DISTINCT NUM_CENTID"
	cQuery += " FROM " + RetSqlName("NSZ") + " NSZ INNER JOIN " + RetSqlName(cEntidade) + " " + cEntidade + " "
	cQuery += 	" ON NSZ_FILIAL = " + cEntidade + "_FILIAL AND NSZ_COD = " + cEntidade + "_CAJURI"
	cQuery += " INNER JOIN " + RetSqlName("NUM") + " NUM"
	cQuery += 	" ON " + cEntidade + "_FILIAL = NUM_FILENT AND (" + Replace(cUnico,'+','||') + ") = NUM_CENTID AND NUM_ENTIDA = '" + cEntidade + "'"
	cQuery += " WHERE NSZ.D_E_L_E_T_ = ' '"
	cQuery += 	" AND " + cEntidade + ".D_E_L_E_T_ = ' '"
	cQuery += 	" AND NUM.D_E_L_E_T_ = ' '"
	cQuery += 	" AND NSZ_FILIAL = '" + cFilOrig + "'"
	cQuery += 	" AND NSZ_COD = '" + cCajuri + "'"

	aCodigos := JurSQL(cQuery, {"NUM_CENTID"})

	For nCont:=1 To Len(aCodigos)
		cCodigos += AllTrim(aCodigos[nCont][1]) + ","
	Next nCont

	RestArea(aArea)

Return cCodigos

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteDocs
Verifica se existe documento para uma determinada entidade.

@param 	cEntidade	- Entidade que será consultada
@param 	cEntiFilha	- Codigo da entidade filha
@return	lRetorno	- Define se existe
@author Rafael Tenorio da Costa
@since  09/09/16
/*/
//-------------------------------------------------------------------
Static Function ExisteDocs(cEntidade, cEntiFilha)

	Local aArea		:= GetArea()
	Local lRetorno	:= .F.
	Local aRegistros:= {}
	Local cQuery	:= ""

	Default cEntiFilha := ""

	cQuery := " SELECT NUM_FILIAL, NUM_COD"
	cQuery += " FROM " + RetSqlName("NUM")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND NUM_FILIAL = '" + xFilial("NUM") + "'"
	cQuery += " AND NUM_ENTIDA = '" + cEntidade + "'"
	cQuery += " AND RTRIM( LTRIM(NUM_CENTID) ) <> ''"

	If !Empty(cEntiFilha)
		cQuery += " AND NUM_DESC = '" + cEntiFilha + "'"
	EndIf

	aRegistros := JurSQL(cQuery, {"NUM_FILIAL", "NUM_COD"})

	If Len(aRegistros) > 0
		lRetorno := .T.
	EndIf

	Asize(aRegistros, 0)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCaminho
Retorna o caminho físico do arquivo. Pode ser através do código
ou nome por questões de compatibilidade

@param 	cCodObj	- Código do objeto
@param  cFilOrig  - Filial Origem
@return	lRetorno	- Define se existe

@since  10/02/17
/*/
//-------------------------------------------------------------------
Static Function GetCaminho(cCodObj, cFilOrig)

Local cArqACB := ""
Local cRet    := ""
Local cBase   := MsDocPath()

Default cFilOrig := xFilial("ACB")

//pega o conteúdo do campo do nome do arquivo na ACB
cArqACB := JurGetDados("ACB",1,cFilOrig + cCodObj,"ACB_OBJETO")

//valida se o código esta gravado no campo ACB_OBJETO ou o nome do arquivo
if (cArqACB == cCodObj) .OR. Empty(cArqACB)
	cRet := cBase + "\" + cCodObj
Else
	//compatibilidade com a base de conhecimento antiga
	cRet := cBase + "\" + cArqACB
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J26AWizard
Wizard para migração dos documentos da estrutura antiga da base de conhecimento
para a estrutura nova

@param 	cFiltro	- Filtro SQL para restringir os dados que serão migrados para teste

@author André Spirigoni Pinto
@since  10/02/17
/*/
//-------------------------------------------------------------------
Function J26AWizard(cFiltro)

Default cFiltro := ""

If ApMsgNoYes(I18N(STR0048,{CRLF,CRLF+CRLF,CRLF+CRLF})) //"Utilize esta rotina para atualizar o conteúdo da base de conhecimento (versões anteriores à 12.1.16) para o novo modelo ou para migração da base para o FLUIG.#1Se for utilizar o FLUIG, certifique-se de que a integração esteja habilitada.#2Faça backup da tabela NUM antes de prosseguir.#3Deseja continuar?"
	Processa({|| J26AMigra(cFiltro)})
Endif


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J26AMigra
Wizard para migração dos documentos da estrutura antiga da base de conhecimento
para a estrutura nova

@param 	cFiltro	- Filtro SQL para restringir os dados que serão migrados para teste
@return	lRetorno	- Define se existe
@author André Spirigoni Pinto
@since  10/02/17
/*/
//-------------------------------------------------------------------
Static Function J26AMigra(cFiltro)
Local aArea		:= GetArea()
Local lRetorno	:= .T.
Local aRegistros:= {}
Local cQuery	:= ""
Local nCt
Local nTam := 0
Local nQtd := 0

Default cFiltro := ""
Default lDebug := .F.

cQuery := " SELECT ACB_FILIAL, ACB_CODOBJ, ACB_OBJETO, AC9_ENTIDA, AC9_CODENT"
cQuery += " FROM " + RetSqlName("ACB") + " ACB, " + RetSqlName("AC9") + " AC9"
cQuery += " WHERE AC9_FILIAL = '" + xFilial("AC9") + "' AND AC9_ENTIDA IN ('NSZ','NT2','NT3','NT4','NTA','NUQ','NSY','SA2')"
cQuery += " AND AC9.AC9_CODOBJ = ACB.ACB_CODOBJ"
cQuery += " AND AC9.D_E_L_E_T_ = ' ' AND ACB_FILIAL = '" + xFilial("ACB") + "' AND ACB.D_E_L_E_T_ = ' ' "

if (!Empty(cFiltro))
	cQuery += cFiltro
Endif

aRegistros := JurSQL(cQuery, {"ACB_FILIAL", "ACB_CODOBJ", "ACB_OBJETO","AC9_ENTIDA","AC9_CODENT"})
nTam := Len(aRegistros)

ProcRegua(nTam) //atualiza a referência da barra de progresso

If nTam > 0
	//faz a migração
	For nCt := 1 to nTam
		IncProc(I18N(STR0049, { alltrim(str(nCt)), alltrim(str(nTam)) })) //"Migrando documento #1 de #2"
		if J26AMigraArq(aRegistros[nCt][2],aRegistros[nCt][4],aRegistros[nCt][5],SubStr(aRegistros[nCt][3],1, Rat(".", aRegistros[nCt][3])-1),SubStr(aRegistros[nCt][3], Rat(".", aRegistros[nCt][3]), 4))
			nQtd++
		Endif
	Next
EndIf

aSize(aRegistros, 0)
RestArea(aArea)

ApMsgInfo(I18N(STR0050, {AllTrim(str(nQtd))})) //"Foram migrados #1 documentos."

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J26AMigraArq
Cria os registros da base do formato antigo para o formato novo, na NUM

@param 	cCodObj	- Código do objeto
@param 	cEntidade	- Entidade
@param 	cCodEnt	- Código da entidade
@param 	cArquivo	- Nome do arquivo (sem extenção
@param 	cExten	- Extenção do arquivo
@return	lRetorno	- Define se existe
@author André Spirigoni Pinto
@since  10/02/17
/*/
//-------------------------------------------------------------------
Static function J26AMigraArq(cCodObj,cEntidade,cCodEnt,cArquivo,cExten)
Local lRet := .T.
Local lFluig := SuperGetMv('MV_JDOCUME',,'1') == '3'
Local cPastaFluig := "0"
Local cCaminho := ""
Local cIdDoc := ""

if (!lFluig) //valida se o destino é FLUIG
	//base de conhecimento
	DbSelectArea("NUM")
	DbSetOrder(4)
	//NUM_FILIAL+NUM_DOC+NUM_ENTIDA+NUM_CENTID
	if !(NUM->(dbSeek(xFilial("NUM") + PadR(cArquivo, 254) + cEntidade + PadR(cCodEnt, 50))))
		Reclock("NUM", .T.)
			NUM->NUM_FILIAL := xFilial("NUM")
			NUM->NUM_COD    := GetSXENum("NUM","NUM_COD")
			NUM->NUM_FILENT := xFilial(cEntidade)
			NUM->NUM_ENTIDA := cEntidade
			NUM->NUM_CENTID := cCodEnt
			NUM->NUM_DOC    := cArquivo
			NUM->NUM_NUMERO := cCodObj
			NUM->NUM_DESC   := ""
			NUM->NUM_EXTEN  := cExten
		NUM->( MsUnLock() )
		ConfirmSX8()
	Else
		lRet := .F.
	Endif
Else
	//FLUIG
	if (cEntidade=="NSZ")
		cPastaFluig := J26AGetPst(cCodEnt)
	Else
		cPastaFluig := J26AGetPst(xFilial(cEntidade) + JurGetDados(cEntidade,1,cCodEnt,cEntidade+"_CAJURI"))
	Endif

	if cPastaFluig != "0"
		//Envia o doc para o FLUIG
		cCaminho := GetCaminho(cCodObj)
		if File(cCaminho)
			if (cIdDoc := JDocFluig(cCaminho, cPastaFluig)) != "0" //Envia o documento para o fluig
				NUM->( dbSetOrder( 2 ) )
				If !NUM->( dbSeek( xFilial( 'NUM' ) + PadR( cIdDoc+";1000", TamSX3('NUM_DOC')[1]) ) )
					RecLock( 'NUM', .T. )  //Trava registro
						NUM->NUM_FILIAL := xFilial( 'NUM' )
						NUM->NUM_COD    := GetSXENum("NUM","NUM_COD")
						NUM->NUM_FILENT := xFilial(cEntidade)
						NUM->NUM_ENTIDA := cEntidade
						NUM->NUM_CENTID := cCodEnt
						NUM->NUM_DOC    := cIdDoc+";1000"
						NUM->NUM_NUMERO := ''
						NUM->NUM_DESC   := cArquivo
						NUM->NUM_EXTEN  := ''
					MsUnlock()     //Destrava registro
					ConfirmSX8()
				Endif
			Endif
		Else
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J26AWizard
Wizard para migração dos documentos da estrutura antiga da base de conhecimento
para a estrutura nova

@param 	cChvCaj	- Chave do processo, filial + código

@return	lRetorno	- Define se existe
@author André Spirigoni Pinto
@since  10/02/17
/*/
//-------------------------------------------------------------------
Static Function J26AGetPst(cChvCaj)
Local aArea		:= GetArea()
Local aRegistros:= {}
Local cQuery	:= ""
Local cIdFluig := "0"

cQuery := " SELECT NZ7_LINK"
cQuery += " FROM " + RetSqlName("NSZ") + " NSZ, " + RetSqlName("NZ7") + " NZ7 "
cQuery += " WHERE NSZ_CCLIEN = NZ7_CCLIEN AND NZ7_LCLIEN = NSZ_LCLIEN AND rtrim(ltrim((NSZ_FILIAL||NSZ_COD))) = '" + AllTrim(cChvCaj) + "'"
cQuery += " AND NZ7_STATUS='2' AND NZ7_NUMCAS = NSZ_NUMCAS"
cQuery += " AND NZ7_FILIAL = '" + xFilial("NZ7") + "'"
cQuery += " AND NSZ.D_E_L_E_T_ = ' ' AND NZ7.D_E_L_E_T_ = ' '"

aRegistros := JurSQL(cQuery, {"NZ7_LINK"})

If Len(aRegistros) > 0
	//faz a migração
	cIdFluig := SubStr(aRegistros[1][1],1,at(";",aRegistros[1][1])-1)
EndIf

aSize(aRegistros, 0)
RestArea(aArea)

Return cIdFluig

//-------------------------------------------------------------------
/*/{Protheus.doc} J026aErrAr
Retorna a descricao do erro que ocorreu na geracao do arquivo.

@param	nErro		- Codigo do erro retornado pela funcao FError()
@return cMsgErro	- Descricao do erro

@author Rafael Tenorio da Costa
@since 17/08/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J026aErrAr( nErro )

	Local cMsgErro := ""

	Do Case

		Case nErro == 0
			cMsgErro := STR0053 //"Operação bem-sucedida."
		Case nErro == 2
			cMsgErro := STR0054 //"Arquivo não encontrado."
		Case nErro == 3
			cMsgErro := STR0055 //"Diretório não encontrado."
		Case nErro == 4
			cMsgErro := STR0056 //"Muitos arquivos foram abertos. Verifique o parâmetro FILES."
		Case nErro == 5
			cMsgErro := STR0057 //"Impossível acessar o arquivo."
		Case nErro == 6
			cMsgErro := STR0058 //"Número de manipulação de arquivo inválido."
		Case nErro == 8
			cMsgErro := STR0059 //"Memória insuficiente."
		Case nErro == 15
			cMsgErro := STR0060 //"Acionador (Drive) de discos inválido."
		Case nErro == 19
			cMsgErro := STR0061 //"Tentativa de gravar sobre um disco protegido contra escrita."
		Case nErro == 21
			cMsgErro := STR0062 //"Acionador (Drive) de discos inoperante."
		Case nErro == 23
			cMsgErro := STR0063 //"Erro de dados no disco."
		Case nErro == 29
			cMsgErro := STR0064 //"Erro de gravação no disco."
		Case nErro == 30
			cMsgErro := STR0065 //"Erro de leitura no disco."
		Case nErro == 32
			cMsgErro := STR0066 //"Violação de compartilhamento."
		Case nErro == 33
			cMsgErro := STR0067 //"Violação de bloqueio."

	End Case

Return cMsgErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J26aExiNum
Verifica se o documento já existe na NUM para a entidade especifica.

@author Rafael Tenorio da Costa
@since  11/09/2018
/*/
//-------------------------------------------------------------------
Function J26aExiNum(cEntidade, cFilEnt, cCodEnt, cDirArq)

	Local aArea	  	:= GetArea()
	Local cQuery  	:= ""
	Local lExiste 	:= .F.
	Local cDoc	  	:= RetArquivo(cDirArq, .F.)
	Local cExtensao := SubStr(cDirArq, Rat(".", cDirArq))
	Local cTipDocs  := AllTrim( SuperGetMv("MV_JDOCUME", , "1") )	//1=WorkSite, 2=Base de conhecimento, 3=Fluig

	cQuery := " SELECT NUM_FILIAL, NUM_COD"
	cQuery += " FROM " + RetSqlName("NUM")
	cQuery += " WHERE NUM_FILIAL = '" + xFilial("NUM") + "'"
	cQuery += 	" AND NUM_ENTIDA = '" + cEntidade + "'"
	cQuery += 	" AND NUM_FILENT = '" + PadR(cFilEnt  , TamSx3("NUM_FILENT")[1]) + "'"
	cQuery += 	" AND NUM_EXTEN = '"  + PadR(cExtensao, TamSx3("NUM_EXTEN")[1])  + "'"
	
	If JurHasClas()
		cQuery += 	" AND NUM_CENTID = '" + PadR(cCodEnt  , TamSx3("NUM_CENTID")[1]) + "'"
	Else
		cQuery += 	" AND NUM_CENTID = '" + cFilEnt + PadR(cCodEnt  , TamSx3("NUM_CENTID")[1]) + "'"
	EndIf
	
	//Fluig
	If cTipDocs == "3"
		cQuery += 	" AND NUM_DESC = '"	  + PadR(cDoc , TamSx3("NUM_DESC")[1])	 + "'"	
	Else	
		cQuery += 	" AND NUM_DOC = '" 	  + PadR(cDoc , TamSx3("NUM_DOC")[1])	 + "'"
	EndIf
	
	cQuery += 	" AND D_E_L_E_T_ = ' '"

	aRetorno := JurSQL(cQuery, "*")

	If Len(aRetorno) > 0
		lExiste := .T.
	EndIf

	RestArea(aArea)

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvBaseCon
Faz a gravação das tabelas ACB, AC9 e NUM.

@author Rafael Tenorio da Costa
@since 31/08/16
/*/
//-------------------------------------------------------------------
Function GrvBaseCon(nOpc, cCodNum, cCodObj, cEntidade, cCodEnt, cDirArq, cDirVir, cOrigem)

	Local aArea 	:= GetArea()
	Local aAreaNUM 	:= NUM->( GetArea() )	
	Local aAreaACB 	:= ACB->( GetArea()	)
	Local aAreaAC9 	:= AC9->( GetArea() )
	Local cArquivo	:= ""
	Local lRetorno 	:= .F.
	
	Default cOrigem	:= ""
	
	//Inclusão
	If nOpc == 3

		//Retorna nome do arquivo
		cArquivo := RetArquivo(cDirArq, .F.)

		//Cria codigo de base de conhecimento		
		cCodObj	 := CriaVar("ACB_CODOBJ", .T.)
		
		//Bancos de Conhecimentos
		lRetorno := Reclock("ACB", .T.)
			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := cCodObj
			ACB->ACB_OBJETO := cCodObj
			ACB->ACB_DESCRI := cArquivo
		ACB->( MsUnLock() )
		
		//Relacao de Objetos x Entidades
		If lRetorno
			 lRetorno := Reclock("AC9", .T.)
				AC9->AC9_FILIAL := xFilial("AC9")
				AC9->AC9_FILENT := xFilial(cEntidade)
				AC9->AC9_ENTIDA := cEntidade
				AC9->AC9_CODENT := cCodEnt
				AC9->AC9_CODOBJ := cCodObj
			AC9->( MsUnLock() )
		EndIf

		//Documentos Juridicos
		If lRetorno
			lRetorno := Reclock("NUM", .T.)
				NUM->NUM_FILIAL := xFilial("NUM")
				NUM->NUM_COD    := GetSXENum("NUM","NUM_COD")
				NUM->NUM_FILENT := xFilial(cEntidade)
				NUM->NUM_ENTIDA := cEntidade
				NUM->NUM_CENTID := cCodEnt
				NUM->NUM_DOC    := cArquivo
				NUM->NUM_NUMERO := cCodObj
				NUM->NUM_DESC   := cDirVir
				NUM->NUM_EXTEN  := SubStr(cDirArq, Rat(".", cDirArq))
			NUM->( MsUnLock() )
		EndIf
		
		While __lSX8
			If lRetorno
				ConfirmSX8()
			Else	
				RollBackSX8()
			EndIf
		EndDo
	
	//Exclusão		 
	Else
	
		//Documentos Juridicos
		NUM->( DbSetOrder(1) )	//NUM_FILIAL+NUM_COD
		If NUM->( DbSeek(xFilial("NUM") + cCodNum) )
		
			//Pega o nome do arquivo
			cCodObj := NUM->NUM_NUMERO
			
			//Carrega o caminho para excluir o arquivo fisicamente 
			cOrigem := GetCaminho(cCodObj)
			
			//Retorna o nome do arquivo
			cDirArq := AllTrim(NUM->NUM_DOC) + AllTrim(NUM->NUM_EXTEN)
		
			lRetorno := RecLock("NUM", .F.)
				NUM->( DbDelete() )			
			NUM->( MsUnLock() )
		EndIf
		
		//Relacao de Objetos x Entidades
		AC9->( DbSetOrder(1) )	//AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
		If AC9->( DbSeek(xFilial("AC9") + cCodObj) )

			lRetorno := RecLock("AC9", .F.)
				AC9->( DbDelete() )			
			AC9->( MsUnLock() )
		EndIf
		
		//Bancos de Conhecimentos
		ACB->( DbSetOrder(1) )	//ACB_FILIAL+ACB_CODOBJ
		If ACB->( DbSeek(xFilial("ACB") + cCodObj) )
		
			lRetorno := RecLock("ACB", .F.)
				ACB->( DbDelete() )			
			ACB->( MsUnLock() )
		EndIf
	EndIf
		
	RestArea(aAreaAC9)
	RestArea(aAreaACB)
	RestArea(aAreaNUM)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} LimparMark
Limpar o mark do grid de anexos abrir a tela

@param oSelect - Objeto com dados do grid de anexos
@return .T.

@since 17/12/2020
/*/
//-------------------------------------------------------------------
Static Function LimparMark(oSelect)
	MarcaTudo(oSelect, "")
Return .T.
