#Include 'protheus.ch'
#Include 'fileio.ch'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#Define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
	#define barra "\"
#ELSE
	#define CRLF Chr(10)
	#define barra "/"
#ENDIF
#DEFINE ARQ_LOG_CNX		"importacao_cnx.log"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIBCNX

Rotina para leitura e importação do arquivo CNX.

@author TOTVS PLS Team
@since 08/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBCNX(cTipo)

	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importacao de Beneficiarios ANS'
	Local cDesc1	:= 'Processamento do arquivo de Conferência do SIB (.CNX) '
	Local cDesc2	:= ''
	Local cDesc3	:= ''
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local  cCadastro	:= "Processamento do arquivo de conferência do SIB XML"

	DEFAULT cTipo := ""

	If cTipo == "2" //Sib

		aAdd( aSay, cDesc1 )
		aAdd( aSay, cDesc2 )
		aAdd( aSay, cDesc3 )

		aAdd( aButton, { 5, .T., { || nOpc := 5, Pergunte('PLSSIBCNX',.T.,Titulo,.F.) } } )
		aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
		aAdd( aButton, { 2, .T., { || FechaBatch()            } } )

		FormBatch( Titulo, aSay, aButton )

		If nOpc == 2

			cArqCNX	:= AllTrim(mv_par01)

			If !Empty(cArqCNX)

				if lHabMetric .and. lLibSupFw .and. lVrsAppSw
					FWMetrics():addMetrics("Impor Arq Conf CNX", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
				endif

				Processa( { || PLSIBCNXPRO(cArqCNX) },cCadastro,'Processando...',.F.)
			Else
				MsgInfo("Para confirmar o processamento selecione um arquivo.","TOTVS")
			EndIf

		EndIf
	Else

		Alert("Operação não disponível para este tipo de obrigação.")

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se as perguntas obrigatorias foram respondidas

@return lRet	Verdadeiro (.T.) se as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta()
	Local lRet	:= .T.
	Local cMsg	:= ""

	If Empty(mv_par01)
		lRet := .F.
		cMsg += "Qual arquivo deve ser importado ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIBCNXPRO

Rotina criada para processar o arquivo CNX

@param cArqCNX Arquivo CNX que será importado

@return lRet	Verdadeiro (.T.) se processou até o final. Falso (.F.) se encontrou algum erro.

@author PLS Team
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIBCNXPRO(cArqCNX, lBscServer,lAuto)
	Local cError	:= "" //Erros encontrados ao ler o xml
	Local cWarning	:= "" //Avisos encontrados ao ler o xml
	Local cPathTag	:= "" //Caminho do node ou child a ser procurado no xml
	Local aTmp		:= {} //Matriz para uso temporario durante o processamento
	Local aBen		:= {} //Matriz para uso temporario durante o processamento
	Local oXml		:= tXmlManager():NEW() //Instancia da classe tXmlManager
	Local nBenef 	:= 0
	Local cNomeArq	:= cArqCNX
	Local i			:= 0
	Local nRegua	:= 0
	Local cDrive, cDir, cNome, cExt
	Local cDirPrcSib	:= GetNewPar("MV_SIBDIRP","SIB")
	Local cPath     := "" //Caminho do arquivo cnx
	Local lCaepf	:= B3W->(FieldPos("B3W_CAEPF")) > 0
	Default lAuto   := .F.

	DEFAULT cArqCNX	:= AllTrim(mv_par01) //Arquivo de conferencia no formato CNX que sera processado
	Default lBscServer := ""

	If !Empty(lBscServer)
		If !File(cArqCNX, lBscServer)
			MsgInfo("Arquivo não encontrado: ","Aviso")
			PlsLogFil(CENDTHRL("E") + "Arquivo não encontrado: " + cArqCNX, ARQ_LOG_CNX)
			Return 0
		EndIf
	Else
		If !File(cArqCNX)
			MsgInfo("Arquivo não encontrado: ","Aviso")
			PlsLogFil(CENDTHRL("E") + "Arquivo não encontrado: " + cArqCNX, ARQ_LOG_CNX)
			Return 0
		EndIf
	EndIf

	SplitPath(cArqCNX, @cDrive, @cDir, @cNome, @cExt )

	PlsLogFil(CENDTHRL("I") + "Inicio do processamento do arquivo " +  cArqCNX, ARQ_LOG_CNX)

	For i:=1 to Len(Alltrim(cArqCNX))
		If (nPos := RAT(If(GETREMOTETYPE()==2,"/","\"), cArqCNX)) != 0
		nPosDirPt:=nPos
	Endif
	Next i

	If nPosDirPt > 0
		cNomeArq := Substr(cArqCNX,(nPosDirPt+1),(Len(Alltrim(cArqCNX))-nPosDirPt))
	Endif

	aDir := DIRECTORY(barra + cDirPrcSib,"D")
	IF Len(aDir) == 0
		MakeDir(GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())+ barra +cDirPrcSib) // Cria um diretório na estacao
	ENDIF

	If !lAuto
		If !Empty(AllTrim(cDirPrcSib))
			If Empty (cDrive)
				lCopied := CpyT2S(GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())+barra+cDirPrcSib + alltrim(cArqCNX), barra + cDirPrcSib,.F.)
			Else
				lCopied := CpyT2S(alltrim(cArqCNX), barra +cDirPrcSib,.F.)
			EndIf
		EndIf

		If !Empty(AllTrim(cDirPrcSib+"\"+cNomeArq))
			cNomeArq := cDirPrcSib+"\"+cNomeArq
		EndIf
	EndIf

	cPath := IIF(lAuto,"\sib\"+cNome+cExt,IIf (Empty(cDrive),alltrim(cArqCNX),alltrim(cNomeArq)) )

	If oXml:ReadFile(cPath,,oXml:Parse_noblanks)
		PlsLogFil(CENDTHRL("I") + "ReadFile realizado com sucesso", ARQ_LOG_CNX)
	Else
		cError := oXml:Error()
		cWarning := oXml:Warning()
		If !Empty(cWarning) .Or. !Empty(cError)
			MsgInfo("Nao foi possivel realizar a leitura do arquivo de conferência." + CRLF + "Aviso: " + AllTrim(cWarning) + CRLF + "Erro: " + AllTrim(cError),"Encerramento")
		Else
			MsgInfo("Nao foi possivel realizar a leitura do arquivo de conferência.","Encerramento")
		Endif
		PlsLogFil(CENDTHRL("W") + cWarning, ARQ_LOG_CNX)
		PlsLogFil(CENDTHRL("E") + cError, ARQ_LOG_CNX)
		Return 0
	EndIf

	cPathTag := "//mensagemSIB/cabecalho/destino"
	If oXml:XPathHasNode(cPathTag)
		aTmp := oXml:XPathGetChildArray(cPathTag)
		cRegANS := aTmp[1][3] //registroANS
		PlsLogFil(CENDTHRL("I") + " Operadora: " + cRegANS, ARQ_LOG_CNX)
	EndIf

	aTmp := {}
	/* Informacoes da mensagem */
	cPathTag := "//mensagemSIB/mensagem/ansParaOperadora/conferencia"
	If oXml:XPathHasNode(cPathTag)

		//Navego até a tag mensagem
		oXml:DOMChildNode() //Cabecalho
		oXml:DOMNextNode() //mensagem
		oXml:DOMChildNode() //ansParaOperadora
		oXml:DOMChildNode() //conferencia

		nRegua := oXml:DOMChildCount()
		ProcRegua(10)
		nIncremento := int(nRegua/10)

		If oXml:DOMChildNode() //Entro no primeiro beneficiário

			aBen := PLBENCNX(oXml)
			PLSINCTRAB(aBen, cRegANS, lCaepf)
			nBenef++
			Do While oXML:DOMNextNode()
				If nBenef == 1 .OR. nBenef % 1000 == 0
					PlsLogFil(CENDTHRL("I") + " Total de beneficiários: " + AllTrim(Str(nRegua)) + ". Total de processados: " + AllTrim(Str(nBenef)) ,ARQ_LOG_CNX)
				EndIf

				aBen := PLBENCNX(oXml)
				PLSINCTRAB(aBen, cRegANS)

				If nBenef == 500 .OR. nBenef % nIncremento == 0
					IncProc( "Total de beneficiários: " + AllTrim(Str(nRegua)) + ". Total de processados: " + AllTrim( Str(nBenef) ) )
				EndIf

				nBenef++

			EndDo
		EndIf
	Else
		MsgInfo("Mensagem do arquivo nao encontrada!","Encerramento")
		PlsLogFil(CENDTHRL("E") + "Nao foi possivel encontrar a mensagem do arquivo em: " + cPathTag, ARQ_LOG_CNX)
		Return 0
	EndIf

	PlsLogFil(CENDTHRL("I") + "Término do processamento do arquivo. " + cArqCNX, ARQ_LOG_CNX)
	MsgInfo("Importação do arquivo CNX finalizada.","Aviso")

Return nBenef

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLBENCNX

Rotina criada retornar os dados de um beneficiário de forma estruturada

@param oXml Objeto do arquivo CNX que está sendo importado
@param cArqLog Nome do arquivo de log

@return aRet Array formatado com os dados do beneficiário

@author PLS Team
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PLBENCNX(oXml)

	Local aBen := {} //dados temporario do usuario no arquivo
	Local aRet := {} //registro completo do usuario no arquivo
	Local nBen := 0  //contador para FOR...NEXT

	If oXML:cName == "beneficiario"
		//Atributos de beneficiario
		aBen := oXml:DomGetAttArray()
		For nBen := 1 To Len(aBen)
			If	aBen[nBen,1] <> "dataAtualizacao"
				aAdd(aRet,aBen[nBen])
			Endif
		Next nBen

		If oXml:DOMChildNode()
			If oXml:DOMHasChildNode() .And. oXML:cName == "identificacao"
				aBen := oXml:DomGetChildArray()
				For nBen := 1 To Len(aBen)
					aAdd(aRet,{aBen[nBen,1],aBen[nBen,2]})
				Next nBen
				oXml:DOMNextNode()
			EndIf
			If oXml:DOMHasChildNode() .And. oXML:cName == "endereco"
				aBen := oXml:DomGetChildArray()
				For nBen := 1 To Len(aBen)
					aAdd(aRet,{aBen[nBen,1],aBen[nBen,2]})
				Next nBen
				oXml:DOMNextNode()
			EndIf
			If oXml:DOMHasChildNode() .And. oXML:cName == "vinculo"
				aBen := oXml:DomGetChildArray()
				For nBen := 1 To Len(aBen)
					aAdd(aRet,{aBen[nBen,1],aBen[nBen,2]})
				Next nBen
				oXml:DOMNextNode()
			EndIf
			oXml:DOMParentNode()
		EndIf
	EndIf

Return aRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSINCTRAB

Função criada fazer o commit dos dados do CNX na central de obrigações.

@param aBen Array com os dados do beneficiário
@param cArqLog Nome do arquivo de LOG
@param cRegANS Registro da operadora na ANS

@author PLS Team
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PLSINCTRAB(aBen,cRegANS, lCaepf)

	Local cCCO := GetValor("cco",aBen)

	Local lInclui := !B3W->(MsSeek(xFilial("B3W")+cRegANS+cCCO))

	RecLock("B3W",lInclui)

	/* DADOS DO XML */

	/* Atributos */
	B3W->B3W_FILIAL := xFilial("B3W")
	B3W->B3W_CODOPE := cRegANS
	B3W->B3W_CODCCO := cCCO
	B3W->B3W_SITANS := GetValor("situacao",aBen)

	/* Identificacao */
	B3W->B3W_CPF 		:= GetValor("cpf",aBen)
	B3W->B3W_DN 		:= GetValor("dn",aBen)
	B3W->B3W_PISPAS 	:= GetValor("pisPasep",aBen)
	B3W->B3W_CNS 		:= GetValor("cns",aBen)
	B3W->B3W_NOMBEN 	:= GetValor("nome",aBen)
	B3W->B3W_SEXO   	:= GetValor("sexo",aBen)
	B3W->B3W_DATNAS 	:= GetValor("dataNascimento",aBen,'D')
	B3W->B3W_NOMMAE		:= GetValor("nomeMae",aBen)

	/* Endereco */
	B3W->B3W_ENDERE := GetValor("logradouro",aBen)
	B3W->B3W_NR_END := GetValor("numero",aBen)
	B3W->B3W_COMEND := GetValor("complemento",aBen)
	B3W->B3W_BAIRRO := GetValor("bairro",aBen)
	B3W->B3W_CODMUN := GetValor("codigoMunicipio",aBen)
	B3W->B3W_MUNICI := GetValor("codigoMunicipioResidencia",aBen)
	B3W->B3W_CEPUSR := GetValor("cep",aBen)
	B3W->B3W_TIPEND := GetValor("tipoEndereco",aBen)
	B3W->B3W_RESEXT := GetValor("resideExterior",aBen)

	/* Vinculo */
	B3W->B3W_MATRIC := GetValor("codigoBeneficiario",aBen)
	B3W->B3W_TIPDEP := GetValor("relacaoDependencia",aBen)
	B3W->B3W_CODTIT := GetValor("ccoBeneficiarioTitular",aBen)
	B3W->B3W_DATINC := GetValor("dataContratacao",aBen,'D')
	B3W->B3W_DATREA := GetValor("dataReativacao",aBen,'D')
	B3W->B3W_DATBLO := GetValor("dataCancelamento",aBen,'D')
	B3W->B3W_MOTBLO := GetValor("motivoCancelamento",aBen)
	B3W->B3W_SUSEP  := GetValor("numeroPlanoANS",aBen)
	B3W->B3W_PLAORI := GetValor("numeroPlanoPortabilidade",aBen)
	B3W->B3W_SCPA   := GetValor("numeroPlanoOperadora",aBen)
	B3W->B3W_COBPAR := GetValor("coberturaParcialTemporaria",aBen)
	B3W->B3W_ITEEXC := GetValor("itensExcluidosCobertura",aBen)
	B3W->B3W_CNPJCO := GetValor("cnpjEmpresaContratante",aBen)
	B3W->B3W_CEICON := GetValor("ceiEmpresaContratante",aBen)
	If lCaepf
		B3W->B3W_CAEPF := GetValor("caepfEmpresaContratante",aBen)
	EndIf

	B3W->(MsUnlock())

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetValor

Retorna o valor de uma matriz pelo nome do campo

@param cCampo Array com os dados do beneficiário
@param aDados Array com a estrutura 'aAdd(aMatriz,"num",1)'
@param cTipo Tido do dado. Utilizado para formatar um tipo de dado específico.

@return cValor Valor recuperado

@author PLS Team
@since 03/06/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetValor(cCampo,aDados,cTipo)
	Local cValor  := ""
	Local nPos    := 0
	Default cTipo := ""

	nPos := aScan(aDados, {|x| Upper(x[1]) == Upper(cCampo)})

	If nPos > 0
		cValor := aDados[nPos,2]
	EndIf

	Do Case
		Case cTipo == 'D'
			cValor := STOD(StrTran(cValor,"-",""))
	EndCase

Return cValor

