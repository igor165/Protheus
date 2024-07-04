#INCLUDE "PROTHEUS.CH"
#INCLUDE "TJURANXFLUIG.CH"

//Function Dummy
Function __TJurAnxFluig()
	ApMsgInfo( I18n(STR0001, {"TJurAnxFluig"}) )	//"Utilizar Classe ao invés da função #1"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe de anexos do Fluig

@author Rafael Tenorio da Costa
@since  04/05/2018
/*/
//-------------------------------------------------------------------
CLASS TJurAnxFluig FROM TJurAnexo

	Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface) CONSTRUCTOR

	Method VerTodos()
	Method Abrir(lOpenFld)
	Method Importar()
	Method Anexar()
	Method GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta)
	Method GetLinkCaso(lVersao)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New(cTitulo, cEntidade, cCodEnt)
Inicializador da Classe

@author Rafael Tenorio da Costa
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface, cCodProc) CLASS TJurAnxFluig

	Local aArea     := GetArea()
	Local aDadosPro := {}
	Local aButtons  := {}

	Default lInterface := .T.
	Default cCodProc := ""

	_Super:New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface)

	Self:SetUsuario( AllTrim( SuperGetMV("MV_ECMUSER", ,"") ) )
	Self:SetEmpresa( AllTrim( SuperGetMV("MV_ECMEMP2", ,"") ) )
	Self:SetSenha(   AllTrim( SuperGetMV("MV_ECMPSW" , ,"") ) )
	Self:SetUrl(     AllTrim( JFlgUrl() ) )

	If Empty( Self:GetEmpresa() )
		Self:SetEmpresa( AllTrim( SuperGetMV("MV_ECMEMP", , "0") ) )
	EndIf

	If Empty(cCodProc)
		cCodProc := IIF( VALTYPE(Self:GetCajuri()) <> "U", Self:GetCajuri(), "")
	EndIf

	aDadosPro 	   := JurGetDados("NSZ", 1, xFilial("NSZ") + cCodProc, {"NSZ_CCLIEN", "NSZ_LCLIEN", "NSZ_NUMCAS"})	//NSZ_FILIAL+NSZ_COD

	If VALTYPE(aDadosPro) <> "U" .AND. Len(aDadosPro) == 3
		Self:SetLinkCaso( JurGetDados("NZ7", 1, xFilial("NZ7") + aDadosPro[1] + aDadosPro[2] + aDadosPro[3], "NZ7_LINK") )		//NZ7_FILIAL+NZ7_CCLIEN+NZ7_LCLIEN+NZ7_NUMCAS
	EndIf

	//Seta botões
	Aadd(aButtons, {STR0002, {|| Processa({|| Self:VerTodos()}	, STR0007, STR0008, .F.)}, 2})	//"Ver Todos"	"Aguarde"	"Abrindo arquivos"
	Aadd(aButtons, {STR0003, {|| Processa({|| Self:Abrir()}		, STR0007, STR0008, .F.)}, 2})	//"Abrir"		"Aguarde"	"Abrindo arquivos"
	Aadd(aButtons, {STR0004, {|| Processa({|| Self:Importar()} 	, STR0007, STR0009, .F.)}, 3})	//"Importar"	"Aguarde"	"Importando arquivos"
	Aadd(aButtons, {STR0005, {|| Processa({|| Self:Anexar()} 	, STR0007, STR0010, .F.)}, 3})	//"Anexar"		"Aguarde"	"Anexando arquivos"
	Aadd(aButtons, {STR0006, {|| Processa({|| Self:Excluir()}  	, STR0007, STR0011, .F.)}, 5})	//"Excluir"	"Aguarde"	"Excluindo arquivos"

	Self:SetButton(aButtons)

	Self:SetShowUrl(.T.)

	If lInterface
		Self:Activate()
	EndIf

	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VerTodos()
Visualiza de todos os registros. Existente no Fluig

@author Rafael Tenorio da Costa
@since  14/05/2018
/*/
//-------------------------------------------------------------------
Method VerTodos() CLASS TJurAnxFluig

	//Abre pasta do caso
	Self:Abrir(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Abrir()

@param  cDocumento - Código e versão do documento que será aberto no fluig.
@author Rafael Tenorio da Costa
@since  14/05/2018
/*/
//-------------------------------------------------------------------
Method Abrir(lOpenFld, cDocSel) CLASS TJurAnxFluig

Local cAux       := ""
Local cUrl       := StrTran( StrTran(Self:GetUrl(), "/webdesk", ""), "//", "/", 2)
Local cFullUrl   := ""
Local cDocumento := ""
Local cVersao	 := ""
Local nDocs      := 0
Local aDocsSel   := ""
Local aAux       := {}
Local cCodNSZ    := Self:cCajuri
Local cCodFili   := Self:cFilEnt
Local cGrpRest   := ""
Local cNumDoc    := ""
Local cNumNumero := ""

Default lOpenFld := .F.
Default cDocSel  := ""

	// Busca em qual Grupo de Acesso o usuário logado pertence
	cGrpRest := JurGrpRest(__CUSERID)

	// Verifica se o usuário é Correspondente
	If ('CORRESPONDENTES' $ cGrpRest)
		If SuperGetMV("MV_JFLXCOR", , 1) == 2
			// Atualiza a permissão de pasta antes de abrir o arquivo para Config. de Correspondente
			JUpPstCorr( cCodFili, cCodNSZ )
		EndIf
	// Verifica se o usuário é Cliente
	ElseIf ('CLIENTES' $ cGrpRest )
		// Atualiza a permissão de pasta para Config. de Cliente.
		JUpPstClie( cCodFili, cCodNSZ )
	EndIf

	If !lOpenFld
		If Empty(cDocSel)
			aDocsSel := Self:GetRegSelecionado()
			If Len(aDocsSel) > 0
				For nDocs := 1 to Len(aDocsSel)

					cNumNumero := AllTrim(aDocsSel[nDocs][3]) // NUM_NUMERO
					cNumDoc  := AllTrim(aDocsSel[nDocs][4])  // NUM_DOC

					//-- Valida da qtd de caracteres do campo NUM_NUMERO que será usado para montar o link do anexo.
					If (Len(cNumDoc) > 10) .AND. (Len(cNumNumero) < Len(cNumDoc)) .AND. (cNumNumero $ cNumDoc)
						cVersao   := SubStr(cNumDoc, At(";", cNumDoc) + 1, Len(cNumDoc))
						cDocumento:= SubStr(cNumDoc, 1, At(";", cNumDoc) - 1)
					Else
						cVersao   := SubStr(cNumNumero, At(";", cNumNumero) + 1, 4)
						cDocumento:= SubStr(cNumNumero, 1, At(";", cNumNumero) - 1)
					EndIf
					
					cFullUrl  := StrTran((cUrl +"/portal/p/"+Self:GetEmpresa()+"/ecmnavigation?app_ecm_navigation_doc="+cDocumento+"&app_ecm_navigation_docVersion="+cVersao),'//','/',2)

					Self:SetDocumento(cFullUrl)
					_Super:Abrir()
				Next
			Else
				aAux       := Self:GetLinkCaso(.T.)
				cDocumento := aAux[1] // Número do documento no Fluig
				cVersao    := aAux[2] // Versão do Documento no Fluig
				cFullUrl   := StrTran((cUrl +"/portal/p/"+Self:GetEmpresa()+"/ecmnavigation?app_ecm_navigation_doc="+cDocumento+"&app_ecm_navigation_docVersion="+cVersao),'//','/',2)

				Self:SetDocumento(cFullUrl)
				_Super:Abrir()
			EndIf
		Else
			cAux := cDocSel
			cDocumento := SubStr(cAux, 1, At(";", cAux) - 1)
			cVersao    := SubStr(cAux, At(";", cAux) + 1, 4)
			cFullUrl  := StrTran((cUrl +"/portal/p/"+Self:GetEmpresa()+"/ecmnavigation?app_ecm_navigation_doc="+cDocumento+"&app_ecm_navigation_docVersion="+cVersao),'//','/',2)
		EndIf
	Else
		aAux       := Self:GetLinkCaso(.T.)
		cDocumento := aAux[1] // Número do documento no Fluig
		cVersao    := aAux[2] // Versão do Documento no Fluig
		cFullUrl   := StrTran((cUrl +"/portal/p/"+Self:GetEmpresa()+"/ecmnavigation?app_ecm_navigation_doc="+cDocumento+"&app_ecm_navigation_docVersion="+cVersao),'//','/',2)

		Self:SetDocumento(cFullUrl)
		_Super:Abrir()
	EndIf

Return cFullUrl

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar()
Ação de importação do botão

@author Rafael Tenorio da Costa
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method Importar() CLASS TJurAnxFluig

	Local lContinua := .F.
	Local nQtdArqs  := 0
	Local aPasta    := {}
	Local cPathArq  := ""
	Local cArquivo  := ""
	Local cExtensao := ""
	Local cIdFluig  := ""
	Local cErro     := ""
	Local nArquivo  := 0
	Local aDadosSE2  := {}
	Local cSE2Chave  := ""
	Local cCodEnt    := ""
	Local cNameEncrp := ""
	Local cDestino   := MsDocPath()
	Local cArqEdit   := ""

	Self:SetOperation(3)

	If Self:lInterface
		//Chama a tela de seleção de arquivos
		lContinua := _Super:Importar()
	Else
		lContinua := .T.
	EndIf

 	If lContinua

 		nQtdArqs := Len(Self:aArquivos)

		//Busca o ID da pasta do Caso no Fluig
		aPasta  := Self:GetLinkCaso(.F.)

		If Empty(aPasta[1])
			cErro := STR0012	//"A pasta deste caso não esta configurada no Fluig"
		Else

	 		//Caso tenha selecionado itens
			For nArquivo := 1 To nQtdArqs
				If Self:lInterface
					IncProc( I18N(STR0013, {cValToChar(nArquivo), cValToChar(nQtdArqs)}) )		//"Importando arquivo(s) #1 de #2"
				EndIf

				cPathArq  := AllTrim( Self:aArquivos[nArquivo] )
				cArquivo  := SubStr(cPathArq, Rat("\", cPathArq) + 1)
				cArquivo  := SubStr(cArquivo, 1, RAt(".", cArquivo) - 1)
				cExtensao := SubStr(cPathArq, Rat(".", cPathArq))

				//Verifique se o documento existe
				If !Self:ExisteDoc(cArquivo, cExtensao)

					//Envia o arquivo para o Fluig
					cIdFluig := JDocFluig(cPathArq, aPasta[1])

					If ( cIdFluig != "0" .And. !Empty(cIdFluig) )

						//Grava o arquivo na tabela NUM
						If !Self:GravaNUM(cIdFluig + ";1000", cIdFluig + ";1000" , cArquivo/*cDesc*/, cExtensao, Self:cSubPasta)
							cErro += Self:GetErro() + " " + cArquivo + CRLF
						ElseIf Self:cEntidade $ "NT3|NT2" .AND. SuperGetMV('MV_JINTVAL',, '2') == '1' //caso a entidade seja a NT3 e tenha integração com o financeiro
							cNameEncrp := CriaVar("ACB_CODOBJ", .T.)
							cArqEdit := cleanString( cArquivo, .F. )//substitui os caracteres especiais para salvar na base de conhecimento do financeiro
						 	If Self:ManipulaDoc(Self:GetOperation(), cArquivo+cExtensao, StrTran(cPathArq,cArquivo+cExtensao,""), cDestino + "\" , cArqEdit+cExtensao)
								//obtemos as informações do contas a pagar (SE2)
								cCodEnt := SubStr(Self:cCodEnt, At(Self:cCajuri,Self:cCodEnt)+10,10)
								aDadosSE2 := JurQryAlc(Self:cEntidade, Self:cCajuri, cCodEnt, IIF(Self:cEntidade == 'NT2','2','3'), .T.)
								If Len(aDadosSE2) > 0
									cSE2Chave := PadR((AllTrim(aDadosSE2[5])),GetSx3Cache("E2_PREFIXO","X3_TAMANHO"))
									cSE2Chave += PadR((AllTrim(aDadosSE2[4])),GetSx3Cache("E2_NUM",    "X3_TAMANHO"))
									cSE2Chave += PadR((AllTrim(aDadosSE2[6])),GetSx3Cache("E2_PARCELA","X3_TAMANHO"))
									cSE2Chave += PadR((AllTrim(aDadosSE2[7])),GetSx3Cache("E2_TIPO",   "X3_TAMANHO"))
									cSE2Chave += PadR((AllTrim(aDadosSE2[8])),GetSx3Cache("E2_FORNECE","X3_TAMANHO"))
									cSE2Chave += PadR((AllTrim(aDadosSE2[9])),GetSx3Cache("E2_LOJA",   "X3_TAMANHO"))

									//gravamos o mesmo anexo na AC9 e ACB para o titulo gerado

									Self:GravaNUM(cNameEncrp, cArqEdit, ""/*cArq*/, cExtensao, ""/*cSubPasta*/,"SE2"/*cEntBasCon*/, cSE2Chave/*cCodEntBas*/)
								EndIf
							EndIf
						EndIf
					Else
						cErro += STR0014 + cArquivo + CRLF		//"Não foi possível enviar o arquivo para o Fluig: "
					EndIf

				Else
					cErro += Self:GetErro() + CRLF
				EndIf

			Next nArquivo

			If Self:lInterface
				Self:AtualizaGrid()
			EndIf
		EndIf

		If Self:lInterface
			If !Empty(cErro)
				lContinua := .F.
				JurMsgErro(STR0015 + ": " + cErro)		//"Arquivo(s) não importado(s)"
				Self:SetErro(cErro)
			Else
				ApMsgInfo(STR0016)		//"Documento(s) importado(s) com sucesso!"
			EndIf
		EndIf

	EndIf

Return lContinua

//-------------------------------------------------------------------
/*/{Protheus.doc} Anexar()
Ação do botão de anexar

@author Rafael Tenorio da Costa
@since  04/05/2018
/*/
//-------------------------------------------------------------------
Method Anexar() CLASS TJurAnxFluig
Local aArea      := GetArea()
Local cUsuario   := Self:GetUsuario()
Local cSenha     := Self:GetSenha()
Local cEmpresa   := Self:GetEmpresa()
Local cColId     := ""
Local cPstFil    := ""
Local ni         := 0
Local nj         := 0
Local cErro      := ""
Local cAviso     := ""
Local cEndEmail  := UsrRetMail(__CUSERID)
Local cPathCab   := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCHILDRENRESPONSE:_DOCUMENT:_ITEM"
Local nDoc       := 0
Local nVersao    := 0
Local nTipo      := "0"
Local cFile      := ""
Local aDocs      := {}
Local aPastas    := {}
Local oDlgTree   := Nil
Local oTree      := Nil
Local oBtnOk     := Nil
Local oBtnCanc   := Nil
Local oTela      := Nil
Local oPnlTree   := Nil
Local oPnlRoda   := Nil
Local lOk        := .F.
Local lMostraMsg := .T.
Local aNodes     := {}
Local cAux       := ""
Local cCodNSZ    := Self:cCajuri
Local cCodFili   := Self:cFilEnt
Local cGrpRest   := ""
Local bChange    := { ||}
Local bDblClick  := { || cAux:=oTree:GetPrompt(.T.), Self:GravaNUM(SubStr(cAux, 1, At(";", cAux) + 4), SubStr(cAux, 1, At(";", cAux) + 4), SubStr(cAux, At("-", cAux) + 2)/*cDesc*/, SubStr(cAux, Rat(".", cAux)), Self:cSubPasta), cErro :=Self:GetErro(), lOk:=.T., oDlgTree:End() }
Local nArvore    := 1
Local aCoord     := {0, 0, 400, 600}

	Self:SetOperation(3)

	If _Super:Anexar()

		// Busca em qual Grupo de Acesso o usuário logado pertence
		cGrpRest := JurGrpRest(__CUSERID)

		// Verifica se o usuário é Correspondente
		If ('CORRESPONDENTES' $ cGrpRest)
			If SuperGetMV("MV_JFLXCOR", , 1) == 2
				// Atualiza a permissão de pasta antes de abrir o arquivo para Config. de Correspondente
				JUpPstCorr( cCodFili, cCodNSZ)
				lMostraMsg := .F.
			EndIf
		// Verifica se o usuário é Cliente
		ElseIf ('CLIENTES' $ cGrpRest )
			// Atualiza a permissão de pasta para Config. de Cliente.
			JUpPstClie( cCodFili, cCodNSZ)
			lMostraMsg := .F.
		EndIf
		
		If !Empty(cEndEmail)
			cColId := JColId(cUsuario, cSenha, cEmpresa, cEndEmail, @cErro, lMostraMsg)
		EndIf

		//Busca o ID da pasta do Caso no Fluig
		aPasta := Self:GetLinkCaso(.F.)

		If !Empty(cColId)
			//Função para trazer os filhos de um diretorio no Fluig
			cPstFil	:= JGetChild(aPasta[1], cUsuario, cSenha, cEmpresa, cColid)

			oXmlgetChildren := XmlParser(cPstFil, "_", @cErro, @cAviso)

			If oXmlgetChildren <> Nil
				If "item" $ cPstFil

					If ValType(&("oXmlgetChildren" + cPathCab)) == "A"
						For ni:=1 to Len(&("oXmlgetChildren" + cPathCab))

							If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTID") <> Nil
								nDoc 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTID:TEXT")
								If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTTYPE") <> Nil
									nTipo 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTTYPE:TEXT")
								EndIf
								If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_VERSION") <> Nil
									nVersao 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_VERSION:TEXT")
								EndIf

								If nTipo == "1"
									If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
										cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
									EndIf

									aAdd(aPastas,{cFile,nDoc,nVersao,'01'})

								ElseIf nTipo == "2"
									If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
										cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(ni,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
									EndIf

									aAdd(aDocs,{cFile,nDoc,nVersao,'01',0})
								EndIf
							EndIf
						Next ni
					Else
						If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTID") <> Nil
							nDoc 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTID:TEXT")
							If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTTYPE") <> Nil
								nTipo 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTTYPE:TEXT")
							EndIf
							If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_VERSION") <> Nil
								nVersao 	:= &("oXmlgetChildren" + cPathCab + ":_VERSION:TEXT")
							EndIf

							If nTipo == "1"
								If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
									cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
								EndIf

								aAdd(aPastas,{cFile,nDoc,nVersao,'01'})

							ElseIf nTipo == "2"
								If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
									cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
								EndIf

								aAdd(aDocs,{cFile,nDoc,nVersao,'01',0})
							EndIf
						EndIf
					EndIf

					//Nivel 2
					For ni:=1 to Len(aPastas)
						cPstFil	:= JGetChild(aPastas[ni][2], cUsuario, cSenha, cEmpresa, cColid)

						oXmlgetChildren := XmlParser( cPstFil, "_", @cErro, @cAviso )

						If oXmlgetChildren <> Nil .AND. "item" $ cPstFil

							If ValType(&("oXmlgetChildren" + cPathCab)) == "A"

								For nj:=1 to Len(&("oXmlgetChildren" + cPathCab))

									If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTID") <> Nil
										nDoc 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTID:TEXT")
										If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTTYPE") <> Nil
											nTipo 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTTYPE:TEXT")
										EndIf
										If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_VERSION") <> Nil
											nVersao 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_VERSION:TEXT")
										EndIf

										If nTipo == "2"
											If XmlChildEx(&("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]"),"_DOCUMENTDESCRIPTION") <> Nil
												cFile 	:= &("oXmlgetChildren" + cPathCab + "[" + StrZero(nj,3) + "]:_DOCUMENTDESCRIPTION:TEXT")
											EndIf

											aAdd(aDocs,{cFile,nDoc,nVersao,'02',ni})

										EndIf
									EndIf
								Next nj
							Else
								If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTID") <> Nil
									nDoc 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTID:TEXT")
									If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTTYPE") <> Nil
										nTipo 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTTYPE:TEXT")
									EndIf
									If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_VERSION") <> Nil
										nVersao 	:= &("oXmlgetChildren" + cPathCab + ":_VERSION:TEXT")
									EndIf

									If nTipo == "2"
										If XmlChildEx(&("oXmlgetChildren" + cPathCab ),"_DOCUMENTDESCRIPTION") <> Nil
											cFile 	:= &("oXmlgetChildren" + cPathCab + ":_DOCUMENTDESCRIPTION:TEXT")
										EndIf

										aAdd(aDocs,{cFile,nDoc,nVersao,'02',ni})

									EndIf
								EndIf
							EndIf
						EndIf
					Next ni

					//Criação da tela com a Arvore
					nArvore:=1
					aadd(aNodes, {'00', StrZero(nArvore, 4), "", STR0018, "FOLDER5", "FOLDER6"})		//"Raiz"

					For ni:=1 to Len(aPastas)
						nArvore++
						aadd(aNodes,{aPastas[ni][4],StrZero(nArvore,4),"",aPastas[ni][1],"FOLDER5","FOLDER6"})
						For nj:=1 to Len(aDocs)
							If aDocs[nj][5] == ni
								nArvore++
								aadd(aNodes,{aDocs[nj][4],StrZero(nArvore,4),"",aDocs[nj][2]+";"+aDocs[nj][3]+" - "+aDocs[nj][1],"",""})
							EndIf
						Next nj
					Next ni

					For nj:=1 to Len(aDocs)
						If aDocs[nj][5] == 0
							nArvore++
							aadd(aNodes,{aDocs[nj][4],StrZero(nArvore,4),"",aDocs[nj][2]+";"+aDocs[nj][3]+" - "+aDocs[nj][1],"",""})
						EndIf
					Next nj

					DEFINE MSDIALOG oDlgTree TITLE STR0017 FROM aCoord[1], aCoord[2] To aCoord[3], aCoord[4] Pixel style DS_MODALFRAME		//"Arquivos no Fluig"

						oTela     := FWFormContainer():New( oDlgTree )
						cIdTree   := oTela:CreateHorizontalBox( 84 )
						cIdRodape := oTela:CreateHorizontalBox( 16 )
						oTela:Activate( oDlgTree, .F. )
						oPnlTree  := oTela:GeTPanel( cIdTree   )
						oPnlRoda  := oTela:GeTPanel( cIdRodape )

						@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 240 Button oBtnCanc Prompt STR0019 Size 25 , 12 Of oPnlRoda Pixel Action ( oDlgTree:End() )		//"Cancelar"

						@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 270 Button oBtnOk   Prompt STR0020 Size 25 , 12 Of oPnlRoda Pixel 								//"Salvar"
						oBtnOk:bAction  := bDblClick

						oTree := DbTree():New( 0, 0, 0, 0, oPnlTree,,, .T. )
						oTree:Align 	 := CONTROL_ALIGN_ALLCLIENT
						oTree:BCHANGE 	 := bChange
						oTree:BLDBLCLICK := bDblClick
						oTree:BLCLICKED  := {|| }

						oTree:PTSendTree( aNodes )
						oTree:SetFocus()

					Activate MsDialog oDlgTree Centered

					If lOk
						Self:AtualizaGrid()
					EndIf
				Else
					cErro := STR0025 + AllTrim(cErro) //"A pasta do caso está vazia. Não existem documentos a serem anexados."
				EndIf
			Else
				//³Retorna falha no parser do XML³
				cErro := STR0021 + AllTrim(cErro) //"Objeto XML não criado, verificar a estrutura do XML: "
			EndIf

			If !Empty(cErro)
				cErro := STR0022 + AllTrim(cErro) //"Não foi possível efetuar o anexo(s) do(s) documento(s) no Fluig: "
				JurMsgErro(cErro)
			Else
				If lOk
					ApMsgInfo(STR0023) //"Documento(s) anexado(s) com sucesso!"
				EndIf
			EndIf
		Else
			If lMostraMsg .And. Empty(cEndEmail)
				cEndEmail := UsrRetName( __cUserID )
				cErro     := I18n(STR0027, {cEndEmail}) + CRLF //"Usuário(s) não estão ativos no Fluig: #1"
				
				JurMsgErro('JColId: ' + cErro)
			EndIf
		EndIf
	EndIf

	FreeObj(oDlgTree)

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaNUM()
Gravação de Dados na NUM - Documentos jurídico

@Param cNumero    	- Identificador
@Param cDoc       	- Link do Documento
@Param cDesc      	- Nome do Documento
@Param cExtensao	- Extensão do Arquivo
@param cSubPasta	- Nome da sub-pasta criada dentro da entidade NSZ
@param cEntBasCon   - Entidade a ser gravada na base de conhecimento
@param cCodEntBas   - Código da entidade a ser gravada na base de conhecimento

@author  Rafael Tenorio da Costa
@version 2.0
@since   23/04/2018
/*/
//-------------------------------------------------------------------
Method GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta, cEntBasCon, cCodEntBas) CLASS TJurAnxFluig

	Local lRetorno := .T.
	Local aArea    := GetArea()
	Local aAreaACB := ACB->( GetArea() )
	Local aAreaAC9 := AC9->( GetArea() )

	Default cEntBasCon := ""
	Default cCodEntBas := ""

	Self:SetErro("")

	If At(";", cNumero) > 0

		If At(".", cDoc) > 0
			cDoc := SubStr(cDoc, 1, Rat(".", cDoc) - 1)
		EndIf

		lRetorno := _Super:GravaNUM(cNumero, cDoc, cDesc, cExtensao, cSubPasta)
	Else
		lRetorno := .F.
		Self:SetErro(STR0024) //"Não é possível vincular uma pasta"
	EndIf

	If !Empty(cEntBasCon)
		Begin Transaction
			//Bancos de Conhecimentos
			lRetorno := Reclock("ACB", .T.)
				ACB->ACB_FILIAL := xFilial("ACB")
				ACB->ACB_CODOBJ := cNumero
				ACB->ACB_OBJETO := cDoc + cExtensao
				ACB->ACB_DESCRI := cDoc
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
					AC9->AC9_FILENT := xFilial(cEntBasCon)
					AC9->AC9_ENTIDA := cEntBasCon
					AC9->AC9_CODENT := cCodEntBas
					AC9->AC9_CODOBJ := cNumero
				AC9->( MsUnLock() )
			EndIf

			While __lSX8
				If lRetorno
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf
			EndDo

		End Transaction
		If !lRetorno
			JurMsgErro( STR0026 ) //"Erro na gravação da Base de Conhecimento."
		EndIf
	EndIf

	RestArea(aAreaAC9)
	RestArea(aAreaACB)
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLinkCaso()
Retorna o link do caso do Fluig NZ7_LINK, com ou sem versão.

@param	lVersao   - Define se ira retornar com o versão ou não
@return cLinkCaso - Link do caso no Fluig
@author Rafael Tenorio da Costa
@since  15/05/2018
/*/
//-------------------------------------------------------------------
Method GetLinkCaso(lVersao) CLASS TJurAnxFluig
Local aDadosPro    := JurGetDados("NSZ", 1, xFilial("NSZ") + Self:GetCajuri(), {"NSZ_CCLIEN", "NSZ_LCLIEN", "NSZ_NUMCAS"}) //NSZ_FILIAL+NSZ_COD
Local cClienteLoja := aDadosPro[1] + aDadosPro[2]
Local cCaso        := aDadosPro[3]
Local cLinkCaso    := ""
Local cLkCaso      := ""

	cLinkCaso := JurGetDados("NZ7", 1, xFilial("NZ7") + aDadosPro[1] + aDadosPro[2] + aDadosPro[3], "NZ7_LINK")
	cLkCaso   := SubStr(cLinkCaso, 1, At(";", cLinkCaso) - 1)
	cVersao   := SubStr(cLinkCaso   , At(";", cLinkCaso)+1,4)

	If Empty(cLinkCaso) .and. Empty(cLkCaso + cVersao)
		cCriaPasta := J070PFluig(cClienteLoja   + cCaso, "")

		If cCriaPasta == "2"
			NZ7->(DbSetOrder(1))// Filial + Cliente Loja + Num. Caso

			If NZ7->( DBSeek(xFilial('NZ7') + cClienteLoja + cCaso ))
				cLkCaso := SubStr(NZ7->NZ7_LINK,1,at(";",NZ7->NZ7_LINK)-1  )
				cVersao   := SubStr(NZ7->NZ7_LINK  ,at(";",NZ7->NZ7_LINK)+1,4)
			EndIf
		EndIf
	EndIf

Return {cLkCaso,cVersao}
