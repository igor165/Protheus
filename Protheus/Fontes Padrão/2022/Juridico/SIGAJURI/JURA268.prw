#INCLUDE "JURA268.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} J268Inic
Função responsável pela leitura de iniciais.
Essa função é chamada no BT18(Outras ações) no fonte JURA095.

@param oModel    - Estrutura do modelo de dados
@param aDados    - Dados da petição
@param lAutomato - Indica se a execução é teste automatizado
@param lTeste    - Indica se irá utilizar o robo python localmente

@since 10/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268Inic(oModel, aDados, lAutomato, lTeste)

	Local lRet
	Local nI
	Local aRetAPI  := {}
	Local cBody    := ""
	Local cNZ2Cod  := ""
	Local cDOC     := ""
	Local cDirPdf  := ""
	Local cArquivo := ""
	Local cMsg     := ""

	Default oModel    := FWModelActive()
	Default aDados    := {}
	Default lAutomato := .F.
	Default lTeste    := .F.

	If Len(aDados) == 0

		//Seleciona o arquivo PDF a ser convertido
		cDirPdf := cGetFile("Arquivos PDF|*.PDF","Escolha o arquivo",0,"C:\",.T.,GETF_LOCALHARD,.F.,.T.)

		//Faz a conversão do arquivo PDF para txt
		If !Empty(cDirPdf)
			cArquivo := J268RetArq(cDirPdf,.T.)
			cBody    := J268PdfTxt(cDirPdf)

			//Faz a requisição para a API Python com o TXT convertido no body
			If !Empty(cBody)
				Processa( {|| aRetAPI   := J268ReqApi(cBody, lTeste) } , STR0012, STR0013, .F. ) //"Carregando inicial." //"Aguarde..."
			EndIf
		Else
			ApMsgInfo(STR0014) //"Operação cancelada"
		EndIf
	
	Else
		aRetAPI := aClone(aDados)
	EndIf

	If Len(aRetAPI) > 0
		//Inclusão de de polo Ativo na NT9
		lRet := J268AdcNT9(oModel, aRetAPI[1], /*cNZ2Cod*/)

		//Se o CPF não for encontrado na SRA/NZ2 o autor será gravado na NZ2
		If !lRet
			cNZ2Cod := J268GrvNZ2(lRet, aRetAPI)
			lRet    := J268AdcNT9(oModel, aRetAPI[1], cNZ2Cod)
		Endif

		//Inclusão de polo passivo na NT9
		If Len(aRetAPI[4]) > 0  //Se houver dados no array de CNPJ(aRetAPI[4])
			For nI := 1 To Len(aRetAPI[4])
				cDOC := StrTran(JurLmpCpo(aRetAPI[4][nI]['CNPJ'],.F.),'#','')
				J268AdcNT9(oModel, cDOC, /*cNZ2Cod*/)
			Next
		Endif

		//Se houver número de processo será gravado na NUQ
		If !Empty(aRetAPI[5])
			cMsg := J268AdcNUQ(oModel, aRetAPI[5])
		Endif

		If (len(aRetAPI) > 5) .And. ! Empty(aRetAPI[6])
			oModel:SetValue("NSZMASTER","NSZ_VLCAUS",val(strtran(strtran(aRetAPI[6],".",""),",",".")))
		EndIf

		
		If Empty(cMsg) .OR. lAutomato
			ApMsgInfo(STR0011) //Inicial carregada com sucesso
		Else
			ApMsgInfo(STR0011 + CRLF + CRLF + cMsg) //Inicial carregada com sucesso //"Aviso: Não existe uma natureza Judicial que valida CNJ, a Comarca não foi preenchida automaticamente."
		Endif
		
		oModel:SetValue("NSZMASTER","NSZ__DIRPDF",cDirPdf) //Armazena o caminho do arquivo para ser gravado na NUM no Commit da JURA095
		
	Else
		JurMsgErro(STR0006,"JURA268") //"Não foi possível realizar conexão com a API SIGAJURI"
	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J268PdfTxt
Converte o arquivo PDF recebido via cGetFile em TXT.

@Return cInicTxt = Conteúdo do arquivo TXT

@since 10/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268PdfTxt(cDirPdf, lDecodeUTF8)

	Local cMarca    := GetMark()
	Local cParams    := "-raw -nopgbrk -enc UTF-8"
	Local cNomeTxt  := "inicial_" + Lower(cMarca) + ".txt"
	Local cSpool    := "/spool/"
	Local cFile     := ""
	Local aLinhas   := {}
	Local nI        := 0
	Local cRootPath := GetSrvProfString("RootPath","") //Pega o conteúdo da chave RootPath do arquivo appserver.ini
	Local cCmd      := ""
	Local cInicTxt  := ""
	Local cMsgErro  := ""
	Local oTxt      := Nil
	Local cArquivo  := ""

	Default lDecodeUTF8 := .F.
	
	//Pega o nome do arquivo
	If rAt('\',cDirPdf) == 0
		cArquivo := SubStr(cDirPdf,rAt('/',cDirPdf)+1)
	Else
		cArquivo := SubStr(cDirPdf,rAt('\',cDirPdf)+1)
	Endif

	If At(':\',cDirPdf) > 0//valida se a inicial ja esta no root do servidor
		If CpyT2S(cDirPdf,cSpool) //Faz a cópia do arquivo para o servidor
			cDirPdf   := cRootPath + cSpool + cArquivo
		Endif
	Else
		cDirPdf := cRootPath + Replace(cDirPdf,'/','\') //substitui / por \ pois o \spool pode ser escrito das duas formas
	Endif
	
	//Monta o comando para ser executado via terminal
	DO CASE
	CASE "Windows" $ GetSrvInfo()[2]
		cDirPdf := cRootPath + cSpool + cArquivo
		cCmd    := 'pdftotext.exe ' + cParams + ' "'+cDirPdf+'" ' + cNomeTxt
		cFile   := cSpool + cNomeTxt

	CASE "Linux" $ GetSrvInfo()[2]
		 cSpool  := "/spool/"
		cDirPdf := cRootPath + cSpool + cArquivo
		cCmd    := 'pdftotext ' + cParams + ' "'+cDirPdf+'" ' + cNomeTxt
		cFile   := cSpool + cNomeTxt
	END CASE

	If  WaitRunSrv(cCmd, .T., cRootPath + cSpool) //Executa o comando para converter o PDF em TXT
		If File(cFile)
			oTxt := FWFileReader():New(cFile) //Cria um objeto file para realizar a leitura do arquivo TXT convertido
			If (oTxt:Open())
				If oTxt:hasLine()
					aLinhas := oTxt:getAllLines() //Transforma todas as linhas do arquivo em um array
					For nI := 1 To Len(aLinhas)

						If !lDecodeUTF8
							cInicTxt += aLinhas[nI] + CRLF
						Else
							If VALTYPE(DecodeUtf8(aLinhas[nI], 'cp1252' )) <> "U"
								cInicTxt += DecodeUtf8(aLinhas[nI], 'cp1252' ) + CRLF
							else
								cInicTxt += aLinhas[nI] + CRLF
							EndIf
						EndIf

					Next
					oTxt:Close()
				Else
					cMsgErro := JurMsgErro(STR0001,"JURA268",STR0003) //"Não foi possível carregar o arquivo" //Verifique se o documento selecionado está correto
					ConOut(STR0002 + STR0009 + cFile) //"O arquivo foi gerado, porém seu conteúdo é inadequado para leitura" //"Caminho do arquivo:"
				Endif
			Endif
		Endif
	Else
		cMsgErro := JurMsgErro(STR0001,"JURA268",STR0004) //"Não foi possível carregar o arquivo"  //"Verifique se o executável pdftotext.exe se encontra na pasta do AppServer"
		ConOut(STR0005 + STR0010 + cCmd) //"Erro ao executar a função WaitRunSrv" //"Comando executado:"
	Endif

Return cInicTxt

//-------------------------------------------------------------------
/*/{Protheus.doc} J268ReqApi
Faz uma requisição POST para a API sigajuri.py passando o texto
convertido pela função ConvPdf no body.

@param	cBody - Conteúdo que será interpretado pela API
@param lTeste - Indica se irá utilizar o robo de leitura de petição local

@return aRetAPI = Informações que foram retornadas pela API Python
		aRetAPI[1] CPF do Autor
		aRetAPI[2] Nome do Autor
		aRetAPI[3] E-mail do Autor
		aRetAPI[4] Lista de CNPJs polo passivo
		aRetAPI[5] Número do processo
		aRetAPI[6] Valor da causa

@since 10/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268ReqApi(cBody, lTeste)
Local cEndpoint := ""
Local oRest     := Nil
Local oJson     := Nil
Local aHeadOut  := {}
Local aRetAPI   := {}
Local aCNPJ     := {}
Local cResult   := ""
Local cAutor    := ""
Local cCpfCnpj  := ""
Local cEmail    := ""
Local cNumPro   := ""
Local lRet      := .T.

Default lTeste  := .F.

	cEndpoint := IIF( lTeste, "http://127.0.0.1:5000", "http://iniciais.totvsjuridico.totvs.com.br" )

	If !JurAuto()
		ProcRegua(0)
	Endif

	//Monta o cabeçalho da requisição
	aAdd(aHeadOut,'Content-Type: text/plain; Charset=UTF-8')
	aAdd(aHeadOut,'Cache-Control: no-cache')
	aAdd(aHeadOut,'Accept: */*')
	aAdd(aHeadOut,'User-Agent: Mozilla/5.0 (Compatible)')

	oRest := FWRest():New(cEndpoint)
	oRest:SetPath("/inicial")
	oRest:SetPostParams(cBody) //Adiciona o TXT convertido no body da requisição

	If oRest:Post(aHeadOut) //Faz a requisição para o endpoint
		cResult := DecodeUTF8(oRest:GetResult())
		oJson   := JsonObject():new()
		oJson:fromJson(cResult) //Transforma o retorno em objeto JSON
	Else
		ConOut(STR0008 + oRest:GetLastError()) //"Retorno da requisição"
		lRet := .F.
	Endif

	If lRet 
		cAutor   := oJson['autor']
		cCpfCnpj := IIF( VALTYPE(oJson['cpfCnpj']) <> "U", oJson['cpfCnpj'], oJson['cpf'] )
		cCpfCnpj := StrTran(JurLmpCpo(cCpfCnpj,.F.),'#','')
		cEmail   := oJson['email']
		aCNPJ    := oJson['polopassivo']
		cNumPro  := oJson['processo']
		cValor   := oJson['valorCausa']

		aAdd(aRetAPI, cCpfCnpj)
		aAdd(aRetAPI, cAutor)
		aAdd(aRetAPI, cEmail)
		aAdd(aRetAPI, aCNPJ)
		aAdd(aRetAPI, cNumPro)
		aAdd(aRetAPI, cValor)
	Endif
	
Return aRetAPI

//-------------------------------------------------------------------
/*/{Protheus.doc} J268AdcNT9
Busca o envolvido através do CPF/CNPJ nas tabelas NZ2, SRA e SA1,
caso encontre, usa o registro para popular a grid de envolvidos(NT9).
Se o CPF não for encontrado na SRA/NZ2 retorna .F. para ser gravado
na NZ2.

@param	cDOC = Número do CPF ou CNPJ
@param	cNZ2Cod = Código do registro do envolvido na NZ2
@param	lPrinci = .T. ou .F. - .T. Caso o CNPJ for principal(NT9_PRINCI)

@Return lRet = .T. se encontrar - .F. se não encontrar

@since 10/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268AdcNT9(oModel,cDOC,cNZ2Cod)

	Local aAreaNZ2  := NZ2->(GetArea())
	Local aAreaSRA  := SRA->(GetArea())
	Local aAreaSA1  := SA1->(GetArea())
	Local lRet      := .F.
	Local cRAMat    := ""
	Local cA1Cod    := ""
	Local cA1Loj    := ""
	Local cTipoEnv  := ""
	Local oModelNT9 := oModel:GetModel("NT9DETAIL")
	Local oModelNSZ := oModel:GetModel("NSZMASTER")

	Default cNZ2Cod := ""

	//Quando for CPF
	If Len(cDOC) == 11
		//Pesquisa se o CPF encontrado na inicial existe na SRA(Funcionários)
		If Empty(cNZ2Cod)
			DbSelectArea("SRA")
			SRA->(DbSetOrder(5)) //RA_FILIAL+RA_CIC

			If dbSeek(xFilial("SRA") + cDOC) //Se encontrar, usa o registro para adicionar o envolvido na NT9
				cRAMat := SRA->RA_MAT
				J105SetDados("SRA",cRAMat)
				oModelNT9:AddLine()
				oModelNT9:SetValue("NT9_ENTIDA","SRA")
				oModelNT9:SetValue("NT9_CODENT",xFilial("SRA") + cRAMat)
				oModelNT9:SetValue("NT9_PRINCI","1")
				oModelNT9:SetValue("NT9_TIPOEN","1")
				cTipoEnv := J219GetNQA({"autor"},"1")
				oModelNT9:SetValue('NT9_CTPENV',cTipoEnv)
				lRet := .T.
			Endif
		Endif

		//Pesquisa se o CPF encontrado na inicial existe na NZ2(Parte contrária)
		If !lRet
			DbSelectArea("NZ2")
			NZ2->(DbSetOrder(3)) //NZ2_FILIAL+NZ2_CGC

			If dbSeek(xFilial("NZ2") + cDOC) //Se encontrar, usa o registro para adicionar o envolvido na NT9
				If Empty(cNZ2Cod) //Se o cNZ2Cod estiver preenchido significa que o envolvido acabou de ser cadastrado pela função J268GrvNZ2
					cNZ2Cod := NZ2->NZ2_COD
				Endif

				J105SetDados("NZ2",cNZ2Cod)
				oModelNT9:AddLine()
				oModelNT9:SetValue("NT9_ENTIDA","NZ2")
				oModelNT9:SetValue("NT9_CODENT",cNZ2Cod)
				oModelNT9:SetValue("NT9_PRINCI","1")
				oModelNT9:SetValue("NT9_TIPOEN","1")
				cTipoEnv := J219GetNQA({"autor"},"1")
				oModelNT9:SetValue('NT9_CTPENV',cTipoEnv)
				lRet := .T.
			Endif
		EndIf
	Elseif Len(cDOC) == 14 //Quando for CNPJ
		//Pesquisa se o CNPJ encontrado na inicial existe na SA1(Clientes)
		DbSelectArea("SA1")
		SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC

		If dbSeek(xFilial("SA1") + cDOC) //Se encontrar, usa o registro para adicionar o envolvido na NT9
			lExiste := oModelNT9:SeekLine({{"NT9_CGC",cDOC}}) //Se o CNPJ já estiver no grid, não adiciona a linha
			If !lExiste
				cA1Cod := SA1->A1_COD
				cA1Loj := SA1->A1_LOJA
				J105SetDados("SA1",cA1Cod)
				oModelNT9:AddLine()
				oModelNT9:SetValue("NT9_ENTIDA","SA1")
				oModelNT9:SetValue("NT9_CODENT",cA1Cod + cA1Loj)
				
				//Preenche o campo NSZ_CCLIEN com o primeiro CNPJ que encontrar e seta como principal no grid da NT9
				If Empty(oModelNSZ:GetValue("NSZ_CCLIEN"))
					oModelNSZ:SetValue("NSZ_CCLIEN",cA1Cod)
					oModelNSZ:SetValue("NSZ_LCLIEN",cA1Loj)
					oModelNT9:SetValue("NT9_PRINCI","1")
				Else
					oModelNT9:SetValue("NT9_PRINCI","2")
				Endif

				oModelNT9:SetValue("NT9_TIPOEN","2")
				cTipoEnv := J219GetNQA({"reu"},"2")
				oModelNT9:SetValue('NT9_CTPENV',cTipoEnv)
			Endif
		Endif
	Endif

	RestArea(aAreaNZ2)
	RestArea(aAreaSRA)
	RestArea(aAreaSA1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J268AdcNUQ
Adiciona uma linha no grid da NUQ para preencher o número do processo.

@param	cNumPro = Número do Processo

@since 10/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268AdcNUQ(oModel,cNumPro)

	Local aAreaNQ1  := NQ1->(GetArea())
	Local oModelNUQ := oModel:GetModel("NUQDETAIL")
	Local cTipoAss  := FwFldGet('NSZ_TIPOAS')
	Local cNatur    := ""
	Local cMsg      := ""
	
	DbSelectArea("NQ1")
	NQ1->(DbSetOrder(2)) //NQ1_FILIAL+NQ1_DESC
	
	//Caso encontre uma natureza com o nome de "Judicial" que valida CNJ e se o parametro MV_JNUMCNJ estiver ativo,
	//preenche os campos da NUQ retirando a pontuação do número do processo para preencher a Comarca automaticamente
	If dbSeek(xFilial("NQ1") + "Judicial") .and. NQ1->NQ1_TIPO == '1' .and. NQ1->NQ1_VALCNJ == '1' .and. JGetParTpa(cTipoAss,"MV_JNUMCNJ","2") == "1"
		cNatur := NQ1->NQ1_COD
		oModelNUQ:SetValue("NUQ_INSTAN","1")
		oModelNUQ:SetValue("NUQ_INSATU","1")
		oModelNUQ:SetValue("NUQ_CNATUR",cNatur)
		oModelNUQ:SetValue("NUQ_NUMPRO",StrTran(JurLmpCpo(cNumPro,.F.),'#',''))	
	Else //Caso contrário preenche apenas o número do processo mantendo a pontuação
		oModelNUQ:SetValue("NUQ_NUMPRO",cNumPro)
		cMsg := STR0015 //"Aviso: Não existe uma natureza Judicial que valida CNJ, a Comarca não foi preenchida automaticamente."
	Endif

	RestArea(aAreaNQ1)

Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} J268GrvNZ2
Grava o envolvido na NZ2 se ele não for encontrado na base.

@param	lRet = Recebe .F. caso precise gravar na NZ2
@param	aRetAPI = Informações que foram retornadas pela API Python
		aRetAPI[1] CPF do Autor
		aRetAPI[2] Nome do Autor
		aRetAPI[3] E-mail do Autor
		aRetAPI[4] Lista de CNPJs polo passivo
		aRetAPI[5] Número do processo

@Return cNZ2Cod = Código do registro do envolvido na NZ2

@since 10/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268GrvNZ2(lRet,aRetAPI,lAltera)

Local oModel184  := Nil
Local cNZ2Cod    := ""
Local cTipoPe    := ""
Local oModel     := FWModelActive()
Local aAreaNZ2   := NZ2->(GetArea())
Local nOperation := 3

Default lAltera  := .F.

	If !lRet
		If lAltera .AND. !Empty(aRetAPI[1])
			DbSelectArea("NZ2")

			NZ2->(DbSetOrder(3)) // NZ2_FILIAL+NZ2_CGC

			If DbSeek(xFilial("NZ2") + aRetAPI[1])
				nOperation := 4
			EndIf
		EndIf

		oModel184 := FWLoadModel("JURA184") // Partes Contrárias
		oModel184:SetOperation( nOperation ) // Inclusao ou alteração
		oModel184:Activate()

		If Len(aRetAPI) > 1 .AND. !Empty(aRetAPI[2])
			oModel184:SetValue("NZ2MASTER","NZ2_NOME" , aRetAPI[2])
		EndIf

		cTipoPe := IIF( Len(aRetAPI[1]) == 11, '1', '2' )
		oModel184:SetValue("NZ2MASTER","NZ2_TIPOP" , cTipoPe)
		oModel184:SetValue("NZ2MASTER","NZ2_CGC"   , aRetAPI[1])

		If Len(aRetAPI) > 2 .AND. !Empty(aRetAPI[3])
			oModel184:SetValue("NZ2MASTER","NZ2_EMAIL" , aRetAPI[3])
		EndIf
		
		cNZ2Cod := oModel184:GetValue( "NZ2MASTER","NZ2_COD")
	Endif

	If !( oModel184:VldData() ) .Or. !( oModel184:CommitData() )
		cNZ2Cod := ""
	EndIf

	oModel184:DeActivate()

	// Retorna o ModelActive para a JURA095
	FWModelActive(oModel,.T.)
	RestArea(aAreaNZ2)

Return cNZ2Cod

//-------------------------------------------------------------------
/*/{Protheus.doc} J268JSON
Função criada para retornar um JSON para o TOTVS LEGAL

@param	cDirPdf - Diretório do arquivo PDF que será convertido
@param lTeste   - Indica se irá utilizar o robo python localmente

@since 	27/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268JSON(cDirPdf, lTeste)

	Local aRetAPI   := {}
	Local cBody     := ""
	Local oResponse := JsonObject():New()

	Default cDirPdf := ""
	Default lTeste  := .F.

	If Empty(cDirPdf)
	//Seleciona o arquivo PDF a ser convertido
		cDirPdf := cGetFile("Arquivos PDF|*.PDF","Escolha o arquivo",0,"C:\",.T.,GETF_LOCALHARD,.F.,.T.)
	Endif

	//Faz a conversão do arquivo PDF para txt
	If !Empty(cDirPdf)
		cBody := J268PdfTxt(cDirPdf)

		//Faz a requisição para a API Python com o TXT convertido no body
		If !Empty(cBody)
			aRetAPI := J268ReqApi(cBody, lTeste)
			
			//Monta o JSON para ser utilizado no TOTVS LEGAL
			If Len(aRetAPI) > 0
				oResponse := J268GetNT9(aRetAPI)
			EndIf
		EndIf
	Endif

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} J268GetNT9
Monta o JSON que será enviado para o TOTVS LEGAL

@param	aRet = Informações que foram retornadas pela API Python
		aRet[1] CPF do Autor
		aRet[2] Nome do Autor
		aRet[3] E-mail do Autor
		aRet[4] Lista de CNPJs polo passivo
		aRet[5] Número do processo
		aRet[6] Valor da causa


@since 	27/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J268GetNT9(aRet)
Local aAreaNZ2   := NZ2->(GetArea())
Local aAreaSRA   := SRA->(GetArea())
Local aAreaSA1   := SA1->(GetArea())
Local aDadosNZ2  := {}
Local oNT9       := JsonObject():New()
Local oResponse  := JsonObject():New()
Local lRet       := .F.
Local cNZ2Cod    := ""
Local cCNPJ      := ""
Local cCnpjPPas  := ""
Local cRAMat     := ""
Local cA1Cod     := ""
Local cA1Loj     := ""
Local cTipoEnv   := ""
Local cPrincipal := "1"
Local nI         := 0

	oResponse['data'] := {}
	Aadd(oResponse['data'], JsonObject():New())
	oResponse['data'][1]['envolvidos'] := {}

	If !Empty(aRet[1])
	
		// Pesquisa se o CPF encontrado na inicial existe na SRA(Funcionários)
		DbSelectArea("SRA")
		SRA->(DbSetOrder(5)) //RA_FILIAL+RA_CIC

		If dbSeek(xFilial("SRA") + aRet[1]) //Se encontrar, usa o registro para adicionar o envolvido no JSON
			cRAMat := SRA->RA_MAT
			oNT9['NT9_ENTIDA'] := "SRA"
			oNT9['NT9_CODENT'] := xFilial("SRA") + cRAMat
			oNT9['NT9_NOMEEN'] := JurEncUTF8(AllTrim(SRA->RA_NOME))
			oNT9['NT9_DOCENV'] := AllTrim(SRA->RA_CIC)
			oNT9['NT9_PRINCI'] := "1"
			oNT9['NT9_TIPOEN'] := "1"
			cTipoEnv := J219GetNQA({"autor"},"1")
			oNT9['NT9_CTPENV'] := cTipoEnv
			oNT9['NT9_DESCEN'] := "Autor"
			aAdd(oResponse['data'][1]['envolvidos'],oNT9)
			lRet := .T.
			oNT9 := JsonObject():New()
		Endif

		// Pesquisa se o CNPJ encontrado na inicial existe na SA1 (Clientes)
		If !lRet
			DbSelectArea("SA1")
			SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
		
			If DbSeek(xFilial("SA1") + aRet[1]) // Se encontrar, usa o registro para adicionar o envolvido no JSON
				cA1Cod := SA1->A1_COD
				cA1Loj := SA1->A1_LOJA
				oNT9['NT9_ENTIDA'] := "SA1"
				oNT9['NT9_CODENT'] := cA1Cod + cA1Loj
				oNT9['NT9_NOMEEN'] := JurEncUTF8(AllTrim(SA1->A1_NOME))
				oNT9['NT9_DOCENV'] := AllTrim(SA1->A1_CGC)
				oNT9['NT9_PRINCI'] := "1"
				oNT9['NT9_TIPOEN'] := "1"
				cTipoEnv := J219GetNQA({"autor"}, "1")
				oNT9['NT9_CTPENV'] := cTipoEnv
				oNT9['NT9_DESCEN'] := "Autor"
				aAdd(oResponse['data'][1]['envolvidos'], oNT9)
				lRet := .T.
				oNT9 := JsonObject():New()
			EndIf
		Endif

		//Pesquisa se o CPF encontrado na inicial existe na NZ2(Parte contrária)
		If !lRet
			DbSelectArea("NZ2")
			NZ2->(DbSetOrder(3)) //NZ2_FILIAL+NZ2_CGC

			If Len(aRet) > 4 .AND. !Empty(aRet[5])
				cCnpjPPas := StrTran(JurLmpCpo(aRet[5]),'#','')
				aRet[5]   := cCnpjPPas
			EndIf

			If dbSeek(xFilial("NZ2") + aRet[1]) //Se encontrar, usa o registro para adicionar o envolvido no JSON
				cNZ2Cod := NZ2->NZ2_COD
			Else
				cNZ2Cod := J268GrvNZ2(lRet, aRet) //Caso contrário, cadastra como parte contrária
				dbSeek(xFilial("NZ2") + aRet[1])
			Endif

			oNT9['NT9_ENTIDA'] := "NZ2"
			oNT9['NT9_CODENT'] := cNZ2Cod
			oNT9['NT9_NOMEEN'] := JurEncUTF8(AllTrim(NZ2->NZ2_NOME))
			oNT9['NT9_DOCENV'] := AllTrim(NZ2->NZ2_CGC)
			oNT9['NT9_PRINCI'] := "1"
			oNT9['NT9_TIPOEN'] := "1"
			cTipoEnv := J219GetNQA({"autor"},"1")
			oNT9['NT9_CTPENV'] := cTipoEnv
			oNT9['NT9_DESCEN'] := "Autor"
			aAdd(oResponse['data'][1]['envolvidos'],oNT9)
			lRet := .T.
			oNT9 := JsonObject():New()
		EndIf
	EndIf

	//Inclusão de polo passivo na NT9
	If Len(aRet[4]) > 0  //Se houver dados no array de CNPJ(aRet[4])
		For nI := 1 To Len(aRet[4])
			cCNPJ := StrTran(JurLmpCpo(aRet[4][nI]['CNPJ'],.F.),'#','')

			If !Empty(cCNPJ)
				cA1Cod    := ""
				cA1Loj    := ""
				cNZ2Cod   := ""
				cCnpjPPas := ""
				aDadosNZ2 := {}
			
				//Pesquisa se o CNPJ encontrado na inicial existe na SA1(Clientes)
				DbSelectArea("SA1")
				SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
			
				If dbSeek(xFilial("SA1") + cCNPJ) //Se encontrar, usa o registro para adicionar o envolvido no JSON
					cA1Cod := SA1->A1_COD
					cA1Loj := SA1->A1_LOJA
					oNT9['NT9_ENTIDA'] := "SA1"
					oNT9['NT9_CODENT'] := cA1Cod + cA1Loj
					oNT9['NT9_NOMEEN'] := JurEncUTF8(AllTrim(SA1->A1_NOME))
					oNT9['NT9_DOCENV'] := AllTrim(SA1->A1_CGC)
					oNT9['NT9_PRINCI'] := cPrincipal
					oNT9['NT9_TIPOEN'] := "2"
					cTipoEnv := J219GetNQA({"reu"},"2")
					oNT9['NT9_CTPENV'] := cTipoEnv
					oNT9['NT9_DESCEN'] := "Reu"
					aAdd(oResponse['data'][1]['envolvidos'],oNT9)
					oNT9 := JsonObject():New()
					cPrincipal := "2"

				// Valida os dados para buscar / cadastrar na rotina de parte contrária (NZ2)
				Else
					If VALTYPE(aRet[4][nI]) == "J" .AND. VALTYPE(aRet[4][nI]['CNPJ']) == "C" .AND. !Empty(aRet[4][nI]['CNPJ'])
						cCnpjPPas := StrTran(JurLmpCpo(aRet[4][nI]['CNPJ']),'#','')
						aAdd( aDadosNZ2, cCnpjPPas )

						// Se recebeu o nome inclui no array para cadastrar na NZ2
						If (VALTYPE(aRet[4][nI]['nome']) == "C") .AND. !Empty(aRet[4][nI]['nome'])
							aAdd( aDadosNZ2, aRet[4][nI]['nome'] )
						EndIf

						cNZ2Cod = J268GrvNZ2(.F., aDadosNZ2, .T.)

						If !Empty(cNZ2Cod)
							DbSelectArea("NZ2")
							NZ2->(DbSetOrder(1)) // NZ2_FILIAL + NZ2_COD

							If DbSeek(xFilial("NZ2") + cNZ2Cod)
								oNT9['NT9_ENTIDA'] := "NZ2"
								oNT9['NT9_CODENT'] := cNZ2Cod
								oNT9['NT9_NOMEEN'] := JurEncUTF8(AllTrim(NZ2->NZ2_NOME))
								oNT9['NT9_DOCENV'] := AllTrim(NZ2->NZ2_CGC)
								oNT9['NT9_PRINCI'] := "1"
								oNT9['NT9_TIPOEN'] := "2"
								cTipoEnv := J219GetNQA({"reu"},"2")
								oNT9['NT9_CTPENV'] := cTipoEnv
								oNT9['NT9_DESCEN'] := "Reu"
								aAdd(oResponse['data'][1]['envolvidos'],oNT9)
								oNT9 := JsonObject():New()
								cPrincipal := "2"
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	
	//Se houver número de processo será adicionado no JSON
	If !Empty(aRet[5])
		oResponse['data'][1]['numprocesso'] := aRet[5]
	EndIf

	If (Len(aRet) > 5) .AND. !Empty(aRet[6])
		oResponse['data'][1]['valorCausa'] := aRet[6]
	EndIf

	RestArea(aAreaNZ2)
	RestArea(aAreaSRA)
	RestArea(aAreaSA1)
	aSize(aDadosNZ2, 0)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} J268RetArq
Retorna nome do arquivo.

@param  cPatchArq - Patch do arquivo com extensão
@param  lExtensao - Indica se deverá ser retornada a extensão
@return cArquivo  - Nome do arquivo
@since 31/08/16
/*/
//-------------------------------------------------------------------
Function J268RetArq(cPatchArq, lExtensao)
Local nPos     := 0
Local cArquivo := ""

	Default lExtensao := .F. //Define se sera retornada a extensao do arquivo

	nPos     := Rat("\", cPatchArq)
	cArquivo := SubStr(cPatchArq, nPos + 1)

	If !lExtensao
		nPos     := Rat(".", cArquivo)
		cArquivo := SubStr(cArquivo, 1, nPos - 1)
	EndIf

Return cArquivo
