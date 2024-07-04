#INCLUDE "plsa973.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMCCR.CH"

//Define de nome de arquivos
#DEFINE TISVERS GetNewPar("MV_TISSVER","2.02.03")
#define CRLF Chr(13) + Chr(10)
#define __aCdCri099 {"063","Participacao de servico informada invalida."}
#define __aCdCri163 {"091","Solicitacao nao encontrada para este usuario."}
#define __aCdCri180 {"09G","Nao existe vigencia ativa para esta rede de atendimento para a operadora informada"}
#define __aCdCri198 {"09Q","Habilita checagem DE/PARA TUSS!"}
#define __aCdCri014 {"511","Rede de atendimento nao permitida para a operadora informada."}
#define __aCdCri016 {"513","Rede de atendimento sem especialidade cadastrada"}
#define __aCdCri152 {"560","Para a solicitacao referente a esta internacao ja consta data de alta"}
#define __aCdCri153 {"561","Incompatibilidade de informacao entre tipo de faturamento e data de alta"}
#define __aCdCri175 {"581","Participacao informada nao existe para este procedimento ou o procedimento nao possui nenhum participacao cadastrada."}
#define __aCdCri128 {"554","Tipo de Atendimento Invalido" }

#define __aXMLCri00 {"X00","Nao foi possivel criar os diretorios padroes TISS"}
#define __aXMLCri01 {"X01","Arquivo(s) de Schemas nao encontrado(s)"}
#define __aXMLCri02 {"X02","Nao foi possivel encontrar o Cabecalho nos Schemas"}
#define __aXMLCri03 {"X03","Mensagens da operadora nao encontrada nos Schemas"}
#define __aXMLCri04 {"X04","Nao foi possivel encontrar as Mensagens do prestador no Schemas"}
#define __aXMLCri05 {"X05","Nao foi possivel encontrar o Epilogo no Schemas"}
#define __aXMLCri06 {"X06","Numero sequencial no nome do arquivo invalido"}
#define __aXMLCri07 {"X07","Delimitador nao encontrado no nome do arquivo"}
#define __aXMLCri08 {"X08","Tamanho do hash no nome do arquivo invalido"}
#define __aXMLCri09 {"X09","NameSpace definido incorreto com base nos Schemas"}
#define __aXMLCri10 {"X10","Especialidade nao encontrada no sistema, para este prestador, com base no CBOS informado no arquivo"}
#define __aXMLCri11 {"X11","Estrutura da TAG CABECALHO nao definida, ou definida de maneira incorreta, no arquivo submetido"}
#define __aXMLCri12 {"X12","Estrutura da TAG PRESTADORPARAOPERADORA nao definida, ou definida de maneira incorreta, no arquivo submetido"}
#define __aXMLCri13 {"X13","Estrutura da TAG EPILOGO nao definida, ou definida de maneira incorreta, no arquivo submetido"}
#define __aXMLCri14 {"X14","Versao do arquivo nao aceito pela operadora "}
#define __aXMLCri15 {"X15","Hash invalido, diferenca entre informado e a validacao do conteudo"}
#define __aXMLCri16 {"X16",'Tipo de guia enviada no arquivo nao permitida ou incorreta'}
#define __aXMLCri17 {"X17","Conteudo que identifica o prestador na operadora esta invalido"}
#define __aXMLCri18 {"X18","Tipo de transacao invalido para o tipo de guia "}
#define __aXMLCri19 {"X19","Codigo do numero de registo na ANS enviado invalido"}
#define __aXMLCri20 {"X20","Nao existe calendario de pagamento, cadastrado na operadora, para esta competencia"}
#define __aXMLCri21 {"X21","Matricula do beneficiario nao reconhecida pela operadora na data informada"}
#define __aXMLCri22 {"X22","CID informado invalido"}
#define __aXMLCri23 {"X23","Numero da senha de autorizacao enviada invalida"}
#define __aXMLCri24 {"X24","Codigo que identifica o contratado nao reconhecido pela operadora"}
#define __aXMLCri25 {"X25","Especialidade nao encontrada no sistema com base no CBOS informado no arquivo"}
#define __aXMLCri26 {"X26","Codigo que identifica o executante nao reconhecido pela operadora"}
#define __aXMLCri27 {"X27","Codigo de evento enviado invalido ou bloqueado pela operadora"}
#define __aXMLCri28 {"X28","Quantidade pre-autorizada menor do que a quantidade enviada"}
#define __aXMLCri29 {"X29","Local de atendimento nao encontrado com base no endereco enviado"}
#define __aXMLCri30 {"X30","Nao foi possivel localizar uma composicao para este evento"}
#define __aXMLCri31 {"X31","Nao foi possivel localizar uma tabela de pagamento valida para este evento"}
#define __aXMLCri32 {"X32","Problemas com o contrato do beneficiario na data informada"}
#define __aXMLCri33 {"X33","Operadora localizada com base no registro da ans enviado, diferente da operadora padrao"}
#define __aXMLCri34 {"X34","Executante nao informado na guia de consulta"}
#define __aXMLCri36 {"X36","Numero da senha nao autorizada pela operadora"}
#define __aXMLCri37 {"X37","Evento informado nao esta contido na guia de pre-autorizacao"}
#define __aXMLCri38 {"X38","Codigo que identifica o profissional executante complementar nao reconhecido pela operadora"}
#define __aXMLCri39 {"X39","Codigo que identifica o membro de equipe nao reconhecido pela operadora"}
#define __aXMLCri40 {"X40","Codigo de procedimento enviado em Guia de Consulta, nao reconhecido como uma consulta pela operadora"}
#define __aXMLCri41 {"X41","Tipo de Carater de Atendimento  Invalido" }
#define __aXMLCri42 {"X42","Data do procedimento superior a data do sistema" }
#define __aXMLCri43 {"X43","Regime de Internacao Invalido" }
#define __aXMLCri44 {"X44","Evento enviado no arquivo nao foi autorizado na senha enviada" }
#define __aXMLCri45 {"X45","Tempo Referido na Evolucao da Doenca esta Invalido" }
#define __aXMLCri46 {"X46","Beneficiario Bloqueado." }
#define __aXMLCri47 {"X47","O executante nao pode atender usuarios deste produto ." }
#define __aXMLCri48 {"X48","A Rede de atendimento nao pode atender usuarios deste produto ." }
#define __aXMLCri49 {"X49","Via de Acesso diferente da solicitada ." }
#define __aXMLCri52 {"X52","Procedimento com valor negativo." }
#define __aXMLCri53 {"X53","Apenas um procedimento pode ser executado para a mesma data de execucao, prestador e beneficiario." }
#define __aXMLCri54 {"X54","O valor apresentado e diferente do valor contratado." }
#define __aXMLCri55 {"X55","Procedimento bloqueado na especialidade do Prestador."}
#define __aXMLCri56 {"X56","RDA informada como origem divergente da RDA que submeteu o Arquivo." }
#define __aXMLCri57 {"X57","O valor total deve ser igual ao valor unitario X %red/acr X qtde, sendo que o %red/acr deve ser 1 caso nao haja red/acr." }
#define __aXMLCri58 {"X58","Data inferior a quantidade de dias definido no parâmetro MV_PLSDTAT." }
#define __aXMLCri59 {"X59","Especialidade bloqueada no cadastro do Prestador."}
#define __aXMLCri60 {"X60","Prestador Bloqueado/Nao Credenciado na data informada."}
#define __aXMLCri61 {"X61","Profissional de Saúde Bloqueado na data informada"}
#define __aXMLCri62 {"X62","Local de atendimento invalido com base no CNES informado no arquivo"}
#define __aXMLCri63 {"X63","Para o motivo de encerramento informado e necessario informar a declaracao de obito"}
#define __aXMLCri65 {"X65","Data do procedimento fora do periodo de internacao"}
#define __aXMLCri66 {"X66","CBO do executante inválido"}
#define __aXMLCri67 {"X67","Vigência do termo encerrada"}
#define __aXMLCri68 {"X68","Faturamento Inválido"}
#define __aXMLCri70 {"X70","Valor deve ser maior que zero."}

//ATENCAO ATENCAO!!-!!-!!-!!-!!-!!-!!-!!-!!-!!-!!-!!-!!
//  SEMPRE QUE FOR CRIADA UMA CRITICA NOVA AQUI ACIMA DEVE A MESMA
//  SER INCLUIDA NO VETOR __XACRITICAS  ABAIXO
STATIC __XACRITICAS := {__aCdCri099, __aCdCri163, __aCdCri180, __aCdCri198, __aCdCri014, __aCdCri016, __aCdCri152, __aCdCri153,;
	__aCdCri175, __aCdCri128, __aXMLCri00, __aXMLCri01, __aXMLCri02, __aXMLCri03, __aXMLCri04, __aXMLCri05, __aXMLCri06,;
	__aXMLCri07, __aXMLCri08, __aXMLCri09, __aXMLCri10, __aXMLCri11, __aXMLCri12, __aXMLCri13, __aXMLCri14, __aXMLCri15,;
	__aXMLCri16, __aXMLCri17, __aXMLCri18, __aXMLCri19, __aXMLCri20, __aXMLCri21, __aXMLCri22, __aXMLCri23, __aXMLCri24,;
	__aXMLCri25, __aXMLCri26, __aXMLCri27, __aXMLCri28, __aXMLCri29, __aXMLCri30, __aXMLCri31, __aXMLCri32, __aXMLCri33,;
	__aXMLCri34, __aXMLCri36, __aXMLCri37, __aXMLCri38, __aXMLCri39, __aXMLCri40, __aXMLCri41, __aXMLCri42, __aXMLCri43,;
	__aXMLCri44, __aXMLCri45, __aXMLCri46, __aXMLCri47, __aXMLCri48, __aXMLCri49, __aXMLCri52, __aXMLCri53, __aXMLCri54,;
	__aXMLCri55, __aXMLCri56, __aXMLCri57, __aXMLCri58, __aXMLCri59, __aXMLCri60, __aXMLCri61, __aXMLCri62, __aXMLCri63,;
	__aXMLCri65, __aXMLCri66, __aXMLCri67, __aXMLCri68, __aXMLCri70	}

STATIC __aCriCust 	:= {}
STATIC lLoadCli 	:= P973LDCLI()
STATIC cDirRaiz	   	:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
STATIC cDirCaiEn   	:= PLSMUDSIS( cDirRaiz+"CAIXAENTRADA\" )
STATIC cDirSchema  	:= PLSMUDSIS( cDirRaiz+"SCHEMAS\" )
STATIC cDirUpload  	:= PLSMUDSIS( cDirRaiz+"UPLOAD\")
STATIC cDirLog	   	:= PLSMUDSIS( cDirRaiz+"LOG\" )

//Matrizes do XML
STATIC aMatShema  := {}
STATIC aMatCab	  := {}
STATIC aMatPre	  := {}
STATIC aMatOpe	  := {}
STATIC aMatEpi	  := {}
STATIC aMatBWT	  := {}
STATIC aUnMed	  := {}
STATIC lVerTISS   := Iif( AllTrim(Upper(TISVERS)) $ "2.02.02,2.02.03",.T.,.F. )
STATIC cPrefANS   := Iif(TISVERS < "2.02.02" .OR. TISVERS >= "3.00.00" ,"ANS", "ANSTISS")
STATIC _aDadProc  := {}

Static _BTUFIlial := xFilial("BTU")
/*/{Protheus.doc} PLSA973L
Processamento xml
@type function
@author TOTVS
@since 22/03/12
@version 1.0
/*/
Function PLSA973L(cFileXml,cCodRda,lOnline,l974,cTipGui,cLotGui,nTotEve,nTotGui,nValTot,cSeqBXX,cDirAlt, cTisVerBXX,_oProcess)
	LOCAL lOk		:= .T.
	LOCAL cPathRda	:= ""
	LOCAL cExtensao := "" //Variaveis a serem utilizadas no split
	LOCAL cDrive	:= ""
	LOCAL cDiretorio:= ""
	LOCAL cNome		:= ""
	LOCAL aRet		:= {.F.,"",{}}
	LOCAL nx			:=0
	DEFAULT cTipGui	:= "08"
	DEFAULT cLotGui	:= ""
	DEFAULT nTotEve := 0
	DEFAULT nTotGui := 0
	DEFAULT nValTot	:= 0
	DEFAULT lOnline := .F.
	DEFAULT l974	:= .f.
	DEFAULT cSeqBXX	:= ""
	DEFAULT cDirAlt	:= cDirUpload
	DEFAULT cTisVerBXX	:= ""
	//Verifica diretorio
	If !lOnline
		If lOk
			If !p973cest()
				lOk 	:= .F.
				aRet[1] := .T.
				AaDd(aRet[3], "Nao foi possivel criar os diretorios padroes TISS.") //"Arquivo(s) de Schemas nao encontrado(s) ( "###" )"
			Endif
		EndIf
	EndIf
	//Valida
	If lOk
		aRet := PVldXML(cFileXml,@cCodRda,@cTipGui,@cLotGui,@nTotEve,@nTotGui,@nValTot,l974,cSeqBXX,cDirAlt,@cTisVerBXX,_oProcess)
		If Len(aRet) >= 2 .AND. ValType(aRet[2]) == "C"
			If !Empty(aRet[2])
				cCodRda := aRet[2]
				aRet[2] := ""
			EndIf
		EndIf
	Endif

	cPathRda := cDirCaiEn + cCodRda + "\"
	If lOk .And. !ExistDir(cPathRda)
		If MakeDir( cPathRda ) <> 0
			aRet := {.T.,"", { "Diretorio " + cPathRda + " nao encontrado e nao foi possivel cria-lo." } }
			lOk	 := .F.
		Else
			// copiando o arquivo xml para caixa de entrada para a futura importação via remote
			For nx:=Len(cFileXml) to 0 step -1
				If Substr(cFileXml,nx,1) ='\'
					cNome:=Substr(cFileXml,nx+1,Len(cFileXml))
					exit
				Endif
			Next
			__CopyFile( cFileXml , cPathRda+cNome )
		EndIf
	Else
		// copiando o arquivo xml para caixa de entrada para a futura importação via remote
		For nx:=Len(cFileXml) to 0 step -1
			If Substr(cFileXml,nx,1) ='\'
				cNome:=Substr(cFileXml,nx+1,Len(cFileXml))
				exit
			Endif
		Next
		__CopyFile( cFileXml , cPathRda+cNome )
	EndIf

	If !aRet[1] .And. lOk

		SplitPath(cFileXml,@cDrive,@cDiretorio,@cNome,@cExtensao)
		//Verifica se o arquivo existe e deleta
		If File(PLSMUDSIS( cPathRda+cNome+cExtensao ) )
			Erase(cPathRda+cNome+cExtensao)
		EndIf
		//Se processamento online ok (acatado) coloca na caixa de entrada do prestador
		__CopyFile( cFileXml , cPathRda+cNome+cExtensao )
		Erase(cFileXml)
	EndIf
Return aRet

/*/{Protheus.doc} PVldXML
Versao LIGHT de validacao do XML
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PVldXML(cFileXml,cCodRda,cTipGui,cLotGui,nTotEve,nTotGui,nValTot,l974,cSeqBXX,cDirAlt,cTisVerBXX,_oProcess,cXMLString)
	LOCAL nPos			:= 0
	LOCAL nI			:= 0
	LOCAL cErro		  	:= ""
	LOCAL cAviso	  	:= ""
	LOCAL aRet        	:= {.F.,'',{}}
	LOCAL aMatXCab		:= {}
	LOCAL aMatXPre		:= {}
	LOCAL aMatXEpi		:= {}
	LOCAL aDados  		:= {}
	LOCAL aItens   		:= {}
	LOCAL oXml			:= nil
	Local cTissVer 		:= ""
	LOCAL cCodPeg		:= ""
	LOCAL lLoteTissOnline:= .F.
	LOCAL nLines 		:= 0
	lOCAL cExpVld		:= ""

	Private aVarsAux	:= {	{"cCodRda","cRdaOri"},;
		{"cTipGui","cTipGui"},;
		{"cLotGui","cLotGui"},;
		{"nValTot","nValTotG"}}
	Private nSeqGui		:= 0
	DEFAULT cCodRda		:= ""
	DEFAULT nTotEve		:= 0
	DEFAULT nTotGui		:= 0
	DEFAULT nValTot     := 0
	DEFAULT cTipGui    	:= "08"
	DEFAULT cLotGui		:= ""
	DEFAULT l974		:= .f.
	DEFAULT cSeqBXX		:= ""
	DEFAULT cDirAlt     := cDirUpload
	DEFAULT cTisVerBXX	:= ""
	Default cXMLString	:= ""
	//Cria um objeto do arquivo XML
	if !empty(cXMLString)
		oXml := XmlParser(cXMLString, "_", @cErro, @cAviso)
	else
		oXml := XmlParserFile(cFileXml, "_", @cErro, @cAviso)
	ENDIF

	If !Empty(cErro)
		aRet[1] := .T.
		AaDd(aRet[3], "*** ERRO [ CRIACAO OBJETO XML ] ***")
		AaDd(aRet[3], cErro)
	Endif
	If !Empty(cAviso)
		aRet[1] := .T.
		AaDd(aRet[3], "*** AVISO [ CRIACAO OBJETO XML ] ***")
		AaDd(aRet[3], cAviso)
	Endif

	If (aRet[1] == .F.)

		If (PLSALIASEX("BVV")) .and. BVV->( Fieldpos("BVV_TISVER"))>0
			//Monta um array do arquivo XML com as tags seus caminhos e valores
			aDados := PXMLTOARR(classDataArr(oXml))

			// Apos montar o aDados pego a quantidade de guias
			If Type("nSeqGui") <> 'U'
				nTotGui := nSeqGui
			EndIf

			//Valida se esta sendo subemetido um arquivo no padrao TISS Online
			//Neste caso sera feito uma conversao para TISS padrao
			lLoteTissOnline := PXMLTISWS(@aDados)

			If cTipGui=="10"
				cCodPeg	:= PXMLGLSWS(@aDados)
				cTissVer := PXMLTISVER(aDados)
				BXX->( RecLock("BXX",.F.) )
				BXX->BXX_CODPEG := cCodPeg
				BXX->BXX_TISVER := cTissVer
				BXX->(MsUnLock())
			Else
				//Pega a versao do XML de acordo com as tags cadastradas na tabela BVP
				cTissVer := PXMLTISVER(aDados)
			Endif
		Else
			//se nao tiver a BVV realiza as validações que foram criadas antes da versao 3 da TISS
			cTissVer := "2.02.03"
		EndIf
		cTisVerBXX := cTissVer // Variavel de versao na BXX
		//Define diretorio dos arquivos
		_cTISTRAN:= "tissV"+StrTran(cTissVer,".","_")+".XSD"
		_cTISGUIA:= "tissGuiasV"+StrTran(cTissVer,".","_")+".XSD"
		_cTISCOMP:= "tissComplexTypesV"+StrTran(cTissVer,".","_")+".XSD"
		_cTISSIMP:= "tissSimpleTypesV"+StrTran(cTissVer,".","_")+".XSD"

		//Se nao encontrou a versao da TISS no XML
		If (Empty(cTissVer))
			aRet[1] := .T.
			AaDd(aRet[3], "** ERRO **")
			AaDd(aRet[3], "Versao TISS nao encontrada no XML")
		Else
			//libera o objeto oXml da memoria pois nao sera mais utilizado
			FreeObj(oXml)
			oXml := Nil
			DelClassInf()
			If cTipGui=="10"
				aRet := envRecGlXml(cFileXml,cSeqBXX,,cTissVer)
			Else
				//Cria a variavel para recupera-la
				For nI := 1 to Len(aVarsAux)
					_SetOwnerPrvt(aVarsAux[nI,1] + "3X", IIf(Substr(Upper(aVarsAux[nI,1]),1,1) == "N",0,"")) // _SetOwnerPrvt(aVarsAux[nI,1] + "30100", "")
				Next nI
				//Criação das variaveis - BVP
				// Ja crio a maioria das variaveis aqui para que as mesmas fiquem globais
				// (variaveis passadas pra ca e utilizadas nas expressoes sao utilizadas
				// em varias partes do processo
				//Posiciona a tabela das variaveis
				BVP->(DbSelectArea("BVP"))
				BVP->(DbSetOrder(1)) //BVP_FILIAL+BVP_TISVER
				//Verifica se encontrou alguma variavel para a versao TISS
				If(BVP->(MsSeek(xFilial("BVP")+cTissVer)))
					//Percorre a tabela para criar as variaveis
					While (!BVP->(Eof()) .And. BVP->(BVP_FILIAL+BVP_TISVER) == xFilial("BVP")+cTissVer)
						If Upper(Substr(	AllTrim(BVP->BVP_NOMVAR), 1,1)) == "C"
							_SetOwnerPrvt(AllTrim(BVP->BVP_NOMVAR), "")
						ElseIf Upper(Substr(	AllTrim(BVP->BVP_NOMVAR), 1,1)) == "N"
							_SetOwnerPrvt(AllTrim(BVP->BVP_NOMVAR), 0)
						ElseIf Upper(Substr(	AllTrim(BVP->BVP_NOMVAR), 1,1)) == "L"
							_SetOwnerPrvt(AllTrim(BVP->BVP_NOMVAR), .F.)
						ElseIf Upper(Substr(	AllTrim(BVP->BVP_NOMVAR), 1,1)) == "A"
							_SetOwnerPrvt(AllTrim(BVP->BVP_NOMVAR), {})
						ElseIf Upper(Substr(	AllTrim(BVP->BVP_NOMVAR), 1,1)) == "D"
							_SetOwnerPrvt(AllTrim(BVP->BVP_NOMVAR), CTOD(""))
						EndIf
						BVP->(DbSkip())
					EndDo
				EndIf

				aVarsUnic:={}
				aDadosUnic	:= PLDADOUNIC(aDados) //variavel que representa o aDados, porem sem repetir as tags

				//checa se esta chamando da mudanca em lote
				//If IsInCallStack("PLSUBLOT")
				// FOI NECESSARIO MODIFICAR OS TRECHOS ABAIXO DEVIDO A ROTINA DE SUBMISSAO EM LOTE NECESSITAR DA CRIAÇÃO DAS VARIAVEIS "3X" NESTE MOMENTO
				//transforma as variaveis em PRIVATE para ficarem visiveis na Macro Substituição(&)
				//	_SetOwnerPrvt("aDados",aDados)
				//	_SetOwnerPrvt("cFileXml",cFileXml)
				//	aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))

				//	PLSVARTISS(aDadosUnic, cTissVer, "" , , @aRet,nil,@aVarsUnic)
				//Else
				PLSVARTISS(aDadosUnic, cTissVer, 'CGUIA'     , , @aRet,nil,@aVarsUnic)
				//EndIf

				//Esse tratamento se da para que as guias ja vao com seu ctigui corretos e nao 08 como default assil calculando corretamente seus valores
				If(nPos:= aScan(aVarsUnic,{|x|ALLTRIM(x[1])=="CTPGUIAS"} ))>0
					nLines := MLCount( aVarsUnic[nPos,2])
					For nI := 1 to nLines
						if !(empty(memoLine(aVarsUnic[nPos,2],,nI)))
							cExpVld += alltrim(strTran(strTran(memoLine(aVarsUnic[nPos,2],,nI), chr(10), ""), chr(13),""))
						endIf
					next nI

					cTpGuias	:= &(cExpVld)
					cGuia		:= PLSTPGUIA(cTpGuias, aDadosUnic)

					If(nPos1:= aScan(aVarsUnic,{|x|ALLTRIM(x[1])=="CTIPGUI"} ))>0
						cTipGui	:= &(aVarsUnic[nPos1,2])
					Endif
				Endif

				//	If IsInCallStack("PLSUBLOT")
				//		aRet := PLSA973FST(cFileXml, aDados, cTissVer,l974,cSeqBXX,cTipGui,@aRet,_oProcess)
				//	Else
				aRet := PNewVldXML(cFileXml, aDados, cTissVer,l974,cSeqBXX,cTipGui,nil,nil,cXMLString)
				//	Endif

				// Tratamento da RDA do arquivo para CPF, CNPJ ou Codigo Prestador na operadora
				If Len(aRet) >= 2 .AND. valType(aRet[2]) == "C"
					If !Empty(aRet[2])
						cRdaOri := aRet[2]
						cCodRda := aRet[2]
					EndIf
				EndIf
			Endif
		EndIf
	EndIf

	//Recupera valor das variaveis dinamicas
	If cTipGui != "10"
		If Val(StrTran(cTissVer,".","")) >= 30000
			if !empty(cTipGui3X)
				cTipGui := cTipGui3X
			endif
			if !empty(cLotGui3X)
				cLotGui := cLotGui3X
			endif
			if !empty(cCodRda3X)
				cCodRda := cCodRda3X
			endif
			if !empty(nValTot3X)
				nValTot := nValTot3X
			endif
		EndIf
		//Ponto de entrada para manipular o retorno do pre-processamento de xml
		If ExistBlock("PLPREPRO")
			aRet := ExecBlock("PLPREPRO",.F.,.F.,{aRet,aMatXCab,aMatXPre,aMatXEpi} )
		EndIf
		//Pega o total de evento e o valor total apresentado
		nTotEve := len(aItens)
		//ErroBlock
		//ErrorBlock( bBlockXml )
	Endif
Return aRet

/*/{Protheus.doc} PLSTRCBOS
@type Function
@author PLS
@since 04/02/15
@version 1.0
@return Array, Retorna se a critica foi validada, o CBOS e Especialidade manipulada conforme De/Para. [1]-lRet/[2]-xcCBOS/[3]-cEspec
/*/
Function PLSTRCBOS(xcCBOS,uPar02,dData,cCodRda,cCodCrm,cUfCrm,aDadCbo,cSigCrm,cDatLo,cCpf,cVerTiss)
	Local cCodBB0		:= ""
	Local cEspec 		:= ""
	Local cEspAll 	:= GetNewPar("MV_PESPPLA","'094','055'") //Especialidades genericas a serem utilizadas quando a RDA nao possuir a especialidade enviada no XML.
	Local aRetEsp		:= {}
	Local aAreaBAQ	:= BAQ->(GetArea())
	Local aAreaBB0	:= BB0->(GetArea())
	Local aAreaBQ1	:= BQ1->(GetArea())
	Local aAreaBAX	:= BAX->(GetArea())
	Local nI			:= 0
	Local lRet	 		:= .F.

	Default cCodRda	:= ""
	Default cCodCrm 	:= ""
	Default cUfCrm 	:= ""
	Default xcCBOS	:= ""
	Default aDadCbo 	:= aClone(aDados)
	Default uPar02	:= NIL
	Default dData  	:= StoD("")
	Default cSigCrm	:= ""
	Default cDatLo 	:= ""
	Default cCpf		:= ""
	Default cVerTiss	:= '3.00.02'

	//Localizando a especialidade correspondente ao codigo enviado no XML.
	If !Empty(xcCBOS)
		BAQ->(DbSetORder(4))//BAQ_FILIAL+BAQ_CODINT+BAQ_CBOS
		If 	BAQ->(MsSeek(xFilial("BAQ") + PlsIntPad() + xcCBOS)) .Or.;
				BAQ->(MsSeek(xFilial("BAQ") + PlsIntPad() + SubStr(xcCBOS,1,4) + "." + SubStr(xcCBOS,5,2)))
			cEspec	:= AllTrim(BAQ->BAQ_CODESP)
		Endif
	Endif

	//Verificando se a especialidade e valida
	If Empty(cEspec)
		cSql := " SELECT BAX_CODESP, BAX_ESPPRI, R_E_C_N_O_ REC FROM "+RetSqlName("BAX")
		cSql += " WHERE BAX_FILIAL	= 	'" + xFilial("BAX") + "' "
		cSql += " AND BAX_CODINT 	= 	'" + PlsIntPad() +"' "
		cSql += " AND BAX_CODIGO   	= 	'" + cCodRda + "' "
		cSql += " AND BAX_CODESP 	IN 	(" + cEspAll + ") "
		cSql += " AND (BAX_DATBLO	= 	' ' OR (BAX_DATBLO <> ' ' and BAX_DATBLO > '" + Iif(ValType(dData) == "D",DtoC(dData),dData) + "'))"
		cSql += " AND D_E_L_E_T_   	= 	' ' "

		PlsQuery(cSql,"TrbBAX")
		//Verificando qual a principal especialidade dentre as informadas no parametro "MV_PESPPLA"
		If !TrbBAX->(Eof())
			While !TrbBAX->(Eof())
				aAdd(aRetEsp,{TrbBAX->BAX_CODESP,TrbBAX->BAX_ESPPRI})
				TrbBAX->(DbSkip())
			Enddo

			dbSelectArea("BAQ")
			BAQ->(dbSetOrder(1))//BAQ_FILIAL+BAQ_CODINT+BAQ_CODESP
			For nI := 1 to Len(aRetEsp)
				If BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+aRetEsp[nI][1]))
					cEspec 	:= AllTrim(BAQ->BAQ_CODESP)
					lRet 	:= .T.
					If aRetEsp[nI][2] == "1"
						Exit
					Endif
				Else
					lRet := .F.
				EndIf
			Next nI
		Endif

		TrbBAX->(DbCloseArea())
	Else

		PLSIVPRO(cCpf,cSigCrm,cCodCrm,cUfCrm,3,nil,aDadCbo,nil,xcCBOS)
		PLSXSCU("",cSigCrm,cCodCrm,cUfCrm,"",NIL,nil,nil,nil,xcCBOS,cDatLo,,cVerTiss)
		//eu sempre tenho que considerar o profissional que as funcoes acima acharam,
		//inclusive essas funcoes criam a bq1 tambem
		If BB0->( found() )

			cCodBB0 := BB0->BB0_CODIGO
			//Buscando a especialidade no Profissional de Saude
			dbSelectArea("BQ1")
			BQ1->(dbSetOrder(1))//BQ1_FILIAL + BQ1_CODIGO + BQ1_CODESP
			If BQ1->(MsSeek(xFilial("BQ1")+cCodBB0+cEspec))
				lRet := .T.
			Else
				//Buscando a especialidade na Rede de Atendimento
				dbSelectArea("BAX")
				BAX->(dbSetOrder(3))//BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO
				If  BAX->(MsSeek(xFilial("BAX")+PlsIntPad()+cEspec+cCodRda)) .And.;
						(BAX->BAX_DATBLO == StoD("") .Or. (BAX->BAX_DATBLO <> StoD("") .And. BAX->BAX_DATBLO > Iif(ValType(dData) == "D",dData,StoD(dData))))
					lRet := .T.
				Endif
			Endif
		Endif
	Endif

	RestArea(aAreaBAQ)
	RestArea(aAreaBB0)
	RestArea(aAreaBQ1)
	RestArea(aAreaBAX)

	If ExistBlock("PLTISESP")
		aRetPe := ExecBlock( "PLTISESP",.F.,.F.,{xcCBOS} )
		If ValType(aRetPe) == "A"
			cEspec  	:= aRetPe[1]
			xcCBOS 	:= aRetPe[2]
			lRet		:= aRetPe[3]
		Endif
	EndIf

Return {lRet,xcCBOS,cEspec}

/*/{Protheus.doc} PExErr
Criticas
@type function
@author TOTVS
@since 22/03/12
@version 1.0
/*/
Static Function PExErr(aArray,cCritica,cCri,nSeqGui,cCodPad,cCodPro,cSeqBXX,lGrCodGlo)
	DEFAULT cCri 	:= ""
	DEFAULT nSeqGui := 0
	DEFAULT cCodPad := ""
	DEFAULT cCodPro := ""
	DEFAULT cSeqBXX := ""
	DEFAULT lGrCodGlo := .f.

	If BCT->(FieldPos('BCT_ENVCOX')) == 0 .or. !PLsAliasExi("BXV") .or. (Empty(cCri) .and. !Empty(cCritica))
		aArray[1] := .T.
		AaDd(aArray[3],cCritica)
	Else
		If !Empty(cCri)
			BCT->(DbSetOrder(1))
			If BCT->( dbSeek(xFilial("BCT") + PlsIntPad() + cCri) ) .and. (BCT->BCT_ENVCOX == '0' .OR. Empty(BCT->BCT_ENVCOX))
				aArray[1] := .T.
				AaDd(aArray[3],cCritica)
			Else
				BXV->(Reclock('BXV',.T.))
				BXV->BXV_FILIAL := xFilial('BXV')
				BXV->BXV_ALIAS  := 'BXX'
				BXV->BXV_CHVALI := cSeqBXX
				BXV->BXV_CODOPE := PlsIntPad()
				If lGrCodGlo
					BXV->BXV_CODGLO := cCri
					BXV->BXV_DESGLO := BCT->BCT_DESCRI
				Else
					BXV->BXV_DESGLO := cCritica
				Endif
				If nSeqGui > 0
					BXV->BXV_SEQGUI := strzero(nSeqGui,3)
				Endif

				BXV->BXV_CODPAD := cCodPad
				BXV->BXV_CODPRO := cCodPro
				BXV->(MsUnlock())
			Endif
		Endif
	Endif
Return

/*/{Protheus.doc} PAddBXV
Adiciona as criticas no array a ser verificado na mudanca de fase
@type function
@author TOTVS
@since 28/05/2014
@version 1.0
/*/
Static Function PAddBXV(cCri, cDesCri, nSeqGui, cCodPad, cCodPro, cSeqBXX)
	DEFAULT cCri    := ""
	DEFAULT cDesCri := ""
	DEFAULT nSeqGui := 0
	DEFAULT cCodPad := ""
	DEFAULT cCodPro := ""
	DEFAULT cSeqBXX := ""

	cSeqBXX := PadR( cSeqBXX, TamSX3("BXV_CHVALI")[1] )
	If !(BXV->(MsSeek(xFilial("BXV")+'BXX'+cSeqBXX+strzero(nSeqGui,3))))

		BXV->(Reclock('BXV',.T.))
		BXV->BXV_FILIAL := xFilial('BXV')
		BXV->BXV_ALIAS  := 'BXX'
		BXV->BXV_CHVALI := cSeqBXX
		BXV->BXV_CODOPE := PlsIntPad()
		If !EMPTY(cCri)
			BXV->BXV_CODGLO := iif(BCT->BCT_ENVCOX == "1","X" + cCri,cCri)
			BXV->BXV_DESGLO := cDesCri
		Else
			BXV->BXV_DESGLO := cDesCri
		Endif
		If nSeqGui > 0
			BXV->BXV_SEQGUI := strzero(nSeqGui,3)
		Endif
		BXV->BXV_CODPAD := cCodPad
		BXV->BXV_CODPRO := cCodPro
		BXV->(MsUnlock())
	Endif

Return

/*/{Protheus.doc} PLSINALUP
Grava ou altera a tabela de upload de arquivo xml
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PLSINALUP(cUsrName,cCodRda,lOnline,lInc,cDirArqIn,aReturn,cChvHAT,lAuto)
	Local nI			:= 1
	Local cRet 			:= ""
	Local cCodInt		:= PLSINTPAD()
	Local cNomeArq		:= Space( TamSX3("BXX_ARQIN")[1] )
	Local cUpldPath		:= getWebDir("UPLOADPATH")
	Local nH			:= 0
	Local cTipGui		:= "08"
	Local cIDXML		:= ""
	Local cTipo			:= ""
	Local lIntHat    	:= 	GetNewPar("MV_PLSHAT","0") == "1"
	Local xChave		:= ""
	Local cTexto 		:= ""

	default cDirArqIn	:= ""
	default aReturn		:= {}
	default cChvHAT	:= ""
	default lAuto	:= .f.

	//Pega o nome do arquivo
	If !Empty(cDirArqIn)
		cNomeArq := Lower( AllTrim( SubStr( cDirArqIn, Rat(PLSMUDSIS('\'),cDirArqIn)+1) ) )
	EndIf
	//Index
	BXX->( DbSetOrder(1) ) //BXX_FILIAL + BXX_CODINT + BXX_CODRDA + BXX_ARQIN
	//chamada para inclusao
	If lInc
		If Empty(cNomeArq)
			cRet := "Falha ao submeter (Verifique se o arquivo ja foi submetido ou entre em contato com a operadora)"
			return cRet
		Endif

		If "ERROR" $ upper(alltrim(cUpldPath)) .AND. empty(cChvHAT) .and. !lAuto
			FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "LOG DE ERRO NO UPLOAD PATH:" + Upper( GetPvProfString( GetEnvHost(), "UPLOADPATH", "ERROR", GetADV97() ) ) , 0, 0, {})
			cRet := "Diretorio de upload nao informado no .INI do SERVER."
			return cRet
		Endif

		nH := fopen(cDirUpload+cNomeArq )
		nTam := fseek(nH,0,2)
		fseek(nH,0)
		nBuff := max(5000,nTam)
		cBuff := space(nBuff)
		nRead := fread(nH,@cBuff,nBuff)
		fclose(nH)
		xChave := alltrim( cBuff )

		If upper("GuiaSADT") $ upper(xChave) .OR. upper("GuiaSP-SADT") $ upper(xChave) .OR. upper("SP_SADT") $ upper(xChave)
			cTipo 	:= '1'
			cTipGui := "02"

		Elseif upper("GuiaHonorarioIndividual") $ upper(xChave) .OR. upper("GuiaHonorarios") $ upper(xChave)
			cTipo 	:= '2'
			cTipGui := "06"

		Elseif upper("GuiaConsulta") $ upper(xChave)
			cTipo 	:= '0'
			cTipGui := "01"

		Elseif upper("GuiaResumo") $ upper(xChave)
			cTipo := '3'
			cTipGui := "05"

		Elseif upper("Odonto") $ upper(xChave)
			cTipo := '4'
			cTipGui := "07"

		Elseif upper("guiaRecursoGlosa") $ upper(xChave)
			cTipo := '5'
			cTipGui := "10"

		Endif

		If upper("numeroLote") $ upper(xChave)
			cIDXML 	:= SubStr(xChave, AT("numeroLote>", xChave) + Len("numeroLote") + 1, RAT("</ans:numeroLote>", xChave) - AT("numeroLote>", xChave) - Len("numeroLote") - 1)
			if cIDXML==""
				cIDXML 	:= SubStr(xChave, AT("numeroLote>", xChave) + Len("numeroLote") + 1, RAT("</numeroLote>", xChave) - AT("numeroLote>", xChave) - Len("numeroLote") - 1)
			endif

		Endif

		If !(empTy(cIDXML))
			cIDXML := cIdXML + space( TamSX3("BXX_IDXML")[1] - Len(cIdXML) )
		EndIf

		BXX->( DbSetOrder(8) )//BXX_FILIAL+BXX_CODINT+BXX_CODRDA+BXX_IDXML
		If !BXX->( MsSeek( xFilial("BXX") + lower(cCodInt + cCodRda + cIDXML) ) ) .and. !BXX->( MsSeek( xFilial("BXX") + upper(cCodInt + cCodRda + cIDXML) ) )
			cSeqBXX := BXX->(getSx8Num("BXX",'BXX_SEQUEN',,7))

			BXX->(dbSetOrder(7)) //BXX_FILIAL+BXX_SEQUEN
			while BXX->( msSeek( xFilial("BXX") + cSeqBXX ) )
				cSeqBXX := BXX->(getSx8Num("BXX",'BXX_SEQUEN',,7))
			endDo

			BXX->(confirmSX8())
			BXX->( RecLock("BXX",.T.) )
			BXX->BXX_FILIAL	:= xFilial("BXX")
			BXX->BXX_DATMOV	:= Date()
			BXX->BXX_CODINT	:= cCodInt
			BXX->BXX_CODUSR	:= cUsrName
			BXX->BXX_ARQIN 	:= cNomeArq
			BXX->BXX_CODRDA	:= cCodRda
			BXX->BXX_TPNFS	:= Iif( lOnline,'1','0')
			BXX->BXX_STATUS	:= Iif( Empty(cNomeArq),'3','0' )
			BXX->BXX_TPARQU	:= cTipo //a tendencia eh que este campo caia em desuso, ele so esta aqui pois ele nasceu primeiro que o TIPGUI, mas tem q ser assim por causa do legado
			BXX->BXX_TIPGUI	:= cTipGui
			BXX->BXX_SEQUEN	:= cSeqBXX
			If GetNewPar("MV_BLOQBAR","0") == "1"
				BXX->BXX_BLOQUE	:= Iif ( lOnline,'1','0')
			EndIf
			BXX->BXX_IDXML	:= cIDXML //Campo criado para que possamos submeter aruqivos independente do nome e controlar duplicidade
			//0=Consulta;1=SpSadt;2=Hono.Ind.;3=Resmo Int.;4=Odonto
			If BXX->(fieldPos("BXX_PLSHAT")) > 0 .AND. !(empTy(cChvHAT))
				BXX->BXX_PLSHAT := cChvHAT
			endIf
			BXX->( MsUnLock() )

			//Grava no Banco de Conhecimento
			PLSINCONH(cDirUpload+cNomeArq, "BXX", xFilial("BXX") + cSeqBXX, .T.)



			If lOnline
				cRet := "Upload terminado com SUCESSO"
			EndIf
			if cTipGui == "10"
				cRet := procRecGlo(cSeqBXX)
			endif

			//Ponto de entrada para atribuir outras informações ao registro da BXX - Submissão via Portal
			//Parametro: 1 - Para diferenciar onde o PE é chamado, neste caso na inclusão do protocolo pela submissão
			If ExistBlock("PL974BXX")
				ExecBlock("PL974BXX", .F., .F., {"1"})
			EndIf

			//existe 0=Em processamento;1=Acatado;2=Nao acatado
		Else
			Do Case

				Case EmpTy(cIDXML) .and. 'RESOURCENOTFOUND' $ UPPER(xChave)
					cRet := "Houve um erro na leitura do arquivo, reenvie o lote novamente. Caso o erro persista entre em contato com o suporte"
				Case EmpTy(cIDXML) //Retirar esse Case depois
					cRet := "Erro no na estrutura do arquivo, não foi possível localizar a TAG [numeroLote]"
				Case BXX->BXX_STATUS == '0'
					cRet := "Este arquivo já foi importado e ainda não foi processado"
				Case BXX->BXX_STATUS == '1'
					cRet := "Este arquivo já foi importado e foi acatado " + IIF(!EMPTY(BXX->BXX_IDXML),"no lote de guias " + BXX->BXX_IDXML,"")
				Case BXX->BXX_STATUS == '2'
					cRet := "Este arquivo já foi importado e não foi acatado"
				Case BXX->BXX_STATUS == '3'
					cRet := "Este arquivo já foi importado e já foi processado " + IIF(!EMPTY(BXX->BXX_IDXML),"no lote de guias " + BXX->BXX_IDXML,"")
			EndCase
			If !lOnline
				cRet += " [" + AllTrim(cNomeArq) + "]"
			EndIf
		EndIf
		//Processamento
	Else
		//e existe 0=Nao Processado;1=Acatado;2=Nao acatado;3=Processado
		If BXX->( MsSeek( xFilial("BXX") + lower(cCodInt + cCodRda + cNomeArq) ) ) .or. BXX->( MsSeek( xFilial("BXX") + upper(cCodInt + cCodRda + cNomeArq) ) )
			//Nao tem erros
			cTipGui := BXX->BXX_TIPGUI
			If Len(aReturn) == 0 .Or. (Len(aReturn) > 0 .And. !aReturn[1]) .or. (Len(aReturn) > 0 .And. aReturn[1] .and. Len(aReturn[3]) == 0 )
				//Online
				If lOnline
					if cTipGui != "10"
						cRet := "true|Arquivo "
					else
						cRet := "Arquivo "
					endif
				EndIf
				cRet += "acatado - Numero protocolo [ " + AllTrim(BXX->BXX_CODPEG) + "] "
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cRet , 0, 0, {})

				//Online
				If lOnline
					cRet += "|"
				EndIf

				//Monta informacoes q serao exibidas em tela
				If Len(aReturn[3]) > 0
					For nI:=1 to Len(aReturn[3])
						cRet += aReturn[3][nI] + Chr(13) + Chr(10)
					Next
				EndIf
				BXX->( RecLock("BXX",.F.) )
				if cTipGui!="10"
					if !empty(BXX->BXX_PLSHAT) .and. BAU->(fieldpos("BAU_GUICAR")) > 0 .and. BXX->BXX_TIPGUI $ BAU->BAU_GUICAR
						BXX->BXX_STATUS := "6"
					else
						BXX->BXX_STATUS := "1"
					endif
				else
					BXX->BXX_STATUS := "3"
				endif
				BXX->( MsUnLock() )

				if lIntHat .AND. !(empTy(BXX->BXX_PLSHAT))
					MontRetHAT(aReturn)
				endIf
			Else
				//Online
				If lOnline
					cRet := "true|"
				EndIf
				cRet += "Arquivo nao acatado devido a inconsistencias detectadas."
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cRet , 0, 0, {})

				If lOnline
					cRet += "|"
				EndIf
				//Erros
				If Len(aReturn[3]) > 0
					For nI:=1 to Len(aReturn[3])
						cRet += aReturn[3][nI] + Chr(13) + Chr(10)
					Next
				EndIf
				//Grava o nome do arquivo para possivel download
				BXX->( RecLock("BXX",.F.) )
				BXX->BXX_STATUS := "2"

				if cTipGui == "10"
					cTexto := staticcall(PLSA974, PLSREGT, aReturn)
					MSMM(,TamSX3("BXX_DETREG")[1],,ansiToOem(cTexto),1,,,"BXX","BXX_CODREG")
					cRet := aReturn[3][1] + " "
					If Len(aReturn[3]) > 1
						For nI:=2 to Len(aReturn[3])
							cRet += aReturn[3][nI] + " "
						Next
					EndIf
				endif

				BXX->( MsUnLock() )
				if lIntHat .AND. !(empTy(BXX->BXX_PLSHAT))
					MontRetHAT(aReturn)
				endIf
			EndIf
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'nao achou a bxx ['+cCodInt + cCodRda + cNomeArq+"]" , 0, 0, {})

		Endif

	EndIf

Return(cRet)


/*/{Protheus.doc} PLSXMLPRO
Atualiza o BXX_STATUS para 3 = XML processado
Com este status o link do relatorio de processamento estara disponivel no portal
@type function
@author TOTVS
@since 16/04/12
@version 1.0
/*/
Function PLSXMLPRO(cCodRda,cArqIn,lOnline)
	LOCAL cArqLog	:= "XMLLOG"
	LOCAL cArqExt	:= ".TXT"
	DEFAULT lOnline := .T.
	//Procura registro do prestador/arquivo
	BXX->( DbSetOrder(1) ) //BXX_FILIAL + BXX_CODINT + BXX_CODRDA + BXX_ARQIN
	If BXX->(MsSeek(xFilial("BXX") + Lower(PLSINTPAD() + cCodRda + cArqIn) ) )
		//Processado
		BXX->( RecLock("BXX",.F.) )
		BXX->BXX_STATUS := "3"
		BXX->( MsUnLock() )
		//Renomeia o arquivo
		If FRename(cDirLog + cArqLog + cArqExt , cDirLog + cArqLog + BXX->(BXX_CODINT+BXX_CODPEG) + cArqExt ) == -1

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Impossivel renomear arquivo de LOG ( XMLLOG.TXT )" , 0, 0, {})

		EndIf

	EndIf

Return Nil

/*/{Protheus.doc} xTemChar
@type function
@author TOTVS
@since 16/04/12
@version 1.0
/*/
static Function xTemChar(cChave)
	LOCAL cChv2 := alltrim(cChave)
	LOCAL lRet  := IsDigit(cChv2)

	While lRet .and. !Empty(cChv2)
		cChv2 := right(cChv2,len(cChv2)-1)
		If !Empty(cChv2)
			lRet  := IsDigit(cChv2)
		Endif
	Enddo

Return !lRet

/*/{Protheus.doc} plIsntPrd
@type function
@author Daher
@since  1/09/2012
@version 1.0
/*/
Function plIsntPrd(aPred,aRet)
	LOCAL lRet  := .T.
	LOCAL nI	:=	1
	DEFAULT aPred := {}
	DEFAULT aRet  := {}

	For nI:=1 to Len(aPred)
		If aScan(aRet,{|x| aPred[nI] $ x }) > 0
			lRet := .F.
		Endif
	Next

return lRet

/*/{Protheus.doc} _pRETAULI
Verifica os itens na liberacao da guia enviada
@type function
@author Daher
@since  8/06/2013
@version 1.0
/*/
static Function _pRETAULI(cNumAut)
	LOCAL nI		 := 0
	LOCAL lFound   	 := .F.
	LOCAL cMacroIte  := ""
	LOCAL cBE2Valid  := "1"
	LOCAL cMacro     := "BEA->BEA_STATUS <> '5' .And. BEA->BEA_ORIGEM == '2'"
	LOCAL aItens   	 := {}

	cMacroIte 	:= "BE2->BE2_STATUS == '1'"
	nIndex 		:= 1
	cChave 		:= cNumAut

	//Posiciona no cabecalho
	BEA->( DbSetOrder(nIndex) ) //BEA_FILIAL+BEA_OPEMOV+BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO+BEA_ORIGEM
	If BEA->( MsSeek(xFilial("BEA") + cChave) ) .And. &cMacro

		BAU->( DbSetOrder(1) )
		BB0->( DbSetOrder(1) )
		BR8->( DbSetOrder(1) )
		BE2->( DbSetOrder(1) )

		//Itens
		If BE2->( MsSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)) )

			While ! BE2->( Eof() ) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == ;
					xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

				BR8->(MsSeek(xFilial("BR8")+BE2->(BE2_CODPAD+BE2_CODPRO)))

				//Validacao de itens
				If &cMacroIte

					//Adicao na aitens
					AaDd(aItens,{	If(BR8->BR8_TPPROC=="5","O","S"),;							//1  - Tipo de Servico (Servico ou OPM)
						BE2->BE2_SEQUEN,; 				   							//2  - Sequencia
						BE2->BE2_CODPAD,; 				   							//3  - Tabela
						AllTrim(BE2->BE2_CODPRO),;   	   							//4  - Procedimento
						AllTrim(BE2->BE2_DESPRO),; 									//5  - Descricao
						AllTrim(Str(Iif(BE2->BE2_QTDSOL==0,BE2->BE2_QTDPRO,BE2->BE2_QTDSOL))),;//6  - Qtd Solicitada
						AllTrim(Str(BE2->BE2_QTDPRO)),;								//7  - Qtd Autorizada
						If(BR8->(FieldPos("BR8_FABRIC"))>0,BR8->BR8_FABRIC,""),; 	//8  - Fabricante...
						BE2->BE2_VLRAPR,;											//9  - Vlr Unitario
						cBE2Valid,;                                                 //10 - podera ser exibido sim ou nao
						BE2->BE2_NUMINT,;											//11 - Se e item de uma internacao
						BE2->(Recno()),;											//12 - Recno
						BE2->BE2_SALDO,;											//13 - Saldo
						{},;														//14 - Matriz de tratamento do executante
						BE2->BE2_NIVAUT,;											//15 - Nivel da Autorizacao
						BE2->BE2_NIVCRI,;											//16 - Nivel da Critica
						BE2->BE2_CHVNIV,;                                        	//17 - Chave do Nivel
						AllTrim(BE2->BE2_DENREG)+'-'+AllTrim(BE2->BE2_DESREG),;   	//18 - Dente - Descricao
						AllTrim(BE2->BE2_FADENT)+'-'+AllTrim(BE2->BE2_FACDES),;   	//19 - Face - Descricao
						0,; 		                                       			//20 - Valor Us
						0,; 														//21 - Valor Contratado
						0,;                                        					//22 - Valor Participacao
						Iif(BE2->BE2_STATUS=='1','S','N'),; 						//23 - Autorizado sim ou nao
						AllTrim(BE2->BE2_DENREG),;    								//24 - Dente
						AllTrim(BE2->BE2_FADENT),;    								//25 - Face
						BE2->BE2_DATPRO,; 											//26 - Data do Evento
						"",;    													//27
						"",;    													//28
						"",;														//29 - Grau de Participacao
						"",;														//30 - Hora Inicio
						"",;                                           				//31 - Hora Fim
						"",;                                           				//32 - Via
						"",;                                           				//33 - Tec
						0,;                                           				//34 - Red Acre
						Iif( BE2->BE2_QTDSOL==0,BE2->BE2_QTDPRO,BE2->BE2_QTDSOL )*BE2->BE2_VLRAPR} )//35 - Valor apr total
				EndIf

				BE2->( DbSkip() )
			Enddo

		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para que os procedimentos que não precisam de autorização não podem apresentar criticas de senhas³
	//³Ha itens que o procedimento não precisam de autorização então a critica X23 não pode parar.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lProcLib	:=	PlChkProc(cChave)
	lFound 		:= Len(aItens) > 0

Return( {lFound, aItens ,lProcLib} )

/*/{Protheus.doc} PXMLTISVER
Retorna a versao do XML de acordo com o aDados
@type function
@author Bruno Iserhardt
@since  3/07/2013
@version 1.0
/*/
Function PXMLTISVER(aDados)
	Local cTissVer := ""
	DEFAULT aDados := {}

	//Percorre a tabela de versoes TISS
	BVV->(DbSelectArea("BVV"))
	BVV->(DbSetOrder(1))
	If(BVV->(MsSeek(xFilial("BVV"))))

		//enquanto nao encontrar a versao da tiss
		While (!BVV->(Eof()) .And. Empty(cTissVer))

			//procura a tag da versao no array de dados do XML
			cTissVer := PVLRTAGXML(aDados, Alltrim(BVV->BVV_CAMTAG)+Alltrim(BVV->BVV_TAG))

			//verifica se a versao encontrada no XML e igual a que esta cadastrada na BVV
			//porque o caminho pode ser o mesmo para versoes diferentes
			If (cTissVer == BVV->BVV_TISVER)
				EXIT
			Else
				BVV->(DbSkip())
			EndIF
		EndDo

	EndIf

Return cTissVer

/*/{Protheus.doc} P973MONEXP
Monta a expressao inserindo os dados das TAGs
Utilizado na funcao PLSTPTRAN
@type function
@author Bruno Iserhardt
@since  3/07/2013
@version 1.0
@param nTagIdx, numerico, Indica qual a tag deve ser retornada caso exista mais de uma ocorrencia
/*/
Function P973MONEXP(cExpressao, aDadosUnic, nTagIdx)
	Local cPathTag 	:= ""
	Local nBegin 		:= 0
	Local nEnd 		:= 0
	Local cTagValue	:= ""
	DEFAULT nTagIdx 	:= 1

	//percorre a expressao ate nao encontrar mais o separador de tags "[%"
	While (At("[%" ,cExpressao) > 0)
		//seleciona os indices do inicio e fim da tag
		nBegin := At("[%",cExpressao)
		nEnd := At("%]",cExpressao)
		//seleciona na expressao o caminho e a tag
		cPathTag := SubStr(cExpressao, nBegin+2, nEnd-nBegin-2)

		If (At(",", cPathTag) <= 0)
			//pega o valor da tag e insere aspas nas extremidades para passar o dado como string na expressao
			//cTagValue := "'" + PVLRTAGXML(aDadosUnic, cPathTag, nTagIdx) + "'"
			// enverti entre aspas simples e aspas duplas pq tem XML que vem com ' no nome ex: JOANA D'ARC, tbm pode aparecer ' em nome de medicamento, medico, etc. ai da error log
			cTagValue := '"' + PVLRTAGXML(aDadosUnic, cPathTag, nTagIdx) + '"'

			//substitui possíveis aspas duplas no meio do XML
			if '"' $ cTagValue
				cTagValue := '"' + STRTRAN(cTagValue, '"', '') + '"'
			endif

			//substitui a tag pelo valor da tag na expressao
			cExpressao := StrTran(cExpressao, "[%" + cPathTag + "%]", cTagValue)
		Else
			//somente remove os caracteres "[%" e "%]"
			cExpressao := StrTran(cExpressao, "[%" + cPathTag + "%]", cPathTag)
		EndIf
	EndDo

Return cExpressao

/*/{Protheus.doc} PVLRTAGXML
Recebe um array do XML gerado pela funcao PXMLTOARR e retorna o valor da tag enviada por parametro
@type function
@author Bruno Iserhardt
@since  6/08/2013
@version 1.0
@param aDados, array, Dados do XML em array
@param cCamTag, caracter, Caminho e TAG para busca
				Tambem pode ser enviado somente o final do caminho da tag
				E possivel informar mais de um caminho separados por virgula,
				assim a funcao retorna a primeira tag que encontrar
@param nTagIdx, numerico, Indica qual a tag deve ser retornada caso exista mais de uma ocorrencia
/*/
Function PVLRTAGXML(aDados, cCamTag, nTagIdx)
	Local cTagValue	:= ""
	Local cTagUn		:= ""
	Local nI			:= 0
	Local nC			:= 0
	Local nC2			:= 0
	Local aCamTag		:= StrTokArr(cCamTag, ",")
	Local aTagUn		:= {}
	Default aDados	:= {}
	Default nTagIdx	:= 1

	For nC:=1 To Len(aCamTag)

		//Utilizado para prevenir o erro em arquivos que possuam a TAG "SENHAPRESTADOR". Ao validar a TAG "SENHAPRESTADOR", o sistema estava se perdendo pois "SENHA" esta contido em "SENHAPRESTADOR", gerando a critica X23 incorretamente.
		aTagUn	:= StrTokArr(aCamTag[nC], "\")
		cTagUn	:= aTagUn[Len(aTagUn)]

		For nC2 := 1 To nTagIdx
			nI := aScan(aDados, {|x| UPPER(aCamTag[nC]) $ UPPER(StrTran(x[2], "\\", "\")+x[1]) .And. UPPER(cTagUn) == UPPER(x[1])}, IIF(nC2 == 1, 1, nI+1))
		Next
		//se nao achou e passou mais de uma vez no for pesquisa de novo percorrendo todo o aDados novamente
		If (nI <= 0 .AND. nTagIdx > 1)
			nI := aScan(aDados, {|x| UPPER(aCamTag[nC]) $ UPPER(StrTran(x[2], "\\", "\")+x[1]) .And. UPPER(cTagUn) == UPPER(x[1])})
		EndIf

		If (nI > 0)
			cTagValue := StrTran( StrTran( strTran( aDados[nI,3], chr(9), ""), chr(10), ""), chr(13), "")
			EXIT
		EndIf
	Next

Return cTagValue

/*/{Protheus.doc} PNewVldXML
Valida os XMLs da TISS a partir da versao 3.00.01
@type function
@author Bruno Iserhardt
@since 01/06/2013
@version 1.0
/*/
Function PNewVldXML(cFileXml,aDados,cTissVer,l974,cSeqBXX,cTipGui,__lOnline,aDadosGer,cXMLString)
	Local cErro			:= ""
	Local cAviso	  	:= ""
	Local cCdItem		:= ""
	Local cTag 			:= ""
	Local cPathTag		:= ""
	Local cTagValue 	:= ""
	Local cTpVld 		:= ""
	Local cAlias		:= ""
	Local nIndice		:= 0
	Local cCdTermi		:= ""
	Local cDadExp		:= ""
	Local cBlcPre		:= ""
	Local cBlcPos		:= ""
	Local cCodOpe		:= ""
	Local cPropri		:= ""
	Local cCodGlo		:= ""
	Local cLocalExec    := '5'
	Local cTipoGrv		:= '1'
	Local cTagExc		:= "CBOS/CBO"
	Local cOpeMov		:= PLSINTPAD()
	Local lCriticOk	:= .T. //indica se a critica esta OK
	Local nI			:= 0
	Local nC			:= 0
	Local nC2			:= 0
	Local nC3			:= 0
	Local nindex		:= 0
	Local nRecGlo		:= 0
	Local aXSD			:= {}
	Local aRetExec		:= {}
	Local aMacros 		:= {}
	Local aCrit			:= {}
	Local lSeekBCT		:= .F.
	Local lBenef		:= .f. //informa se ja passou pela tag beneficiarios
	Local lDebug		:= .F. //CRIAR UM MV_PAR LA NO PLSA974 PARA O CARA HABILITAR ESSAS MENSAGENS DE DEBUG - PENDENTE DAHER 20/05/14
	Local aTags			:= {}
	LOCAL aEvErros  	:= {}
	Local aVarsUnic		:= {} // Array que mantem(backup) a estrutura unica das variaveis para o sistema nao precisar ir sempre na BVP
	Local nMsgAux		:= 0
	Local cMsgAux		:= ""
	Local aMsgAux		:= {}
	Local nQtdX		:= 0
	Local nValX		:= 0
	Local nValTotX	:= 0
	Local nAcrX		:= 0
	//array com as criticas que nao podem ir para conferencia(BXV)
	Local aCritNConf	:= {"X17","X18","X19","X20","X24","X33"}
	Local nTp4			:= 0
	Local aTgsTp4		:= {}
	Local aBkpTp4		:= {}
	Local lVldTp4		:= .F.
	Local cTagVld4	:= ""
	Local cPathVld4	:= ""
	Local cGloVld4	:= ""
	Local nSeqTp4		:= ""
	Local nCompCri	:= 0
	Local nX := 1
	Local cIdenPres	:= ""
	Local carqPres	:= ""
	Local cCodRDAx	:= ""
	local aAlerta   := {}
	Local cCodTUSS    := ""
	Local cDesTUSS    := ""
	Local aAreaBAU	:= BAU->(GetArea())
	Local y := 0
	Local lIntHat	:= 	GetNewPar("MV_PLSHAT","0") == "1"
	Local lstringOk	:= .F.

	PRIVATE aBkpDad := aClone(aDados)
	PRIVATE aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
	PRIVATE aDadosCrm := PLDADCRM(aDados)
	PRIVATE aDadosUnic	:= PLDADOUNIC(aDados) //variavel que representa o aDados, porem sem repetir as tags
	PRIVATE aTagsBVN	:= {} //array com todos os caminhos+tags e o recno da BVN
	PRIVATE aCrTp4			:= {}
	PRIVATE aDadosThd	:=  aClone(aDadosGer) // dados que vem da threads como vem particionado por Guia ao calcular o hash ira apresentar erro.
	PRIVATE aRet 		:= {.F., "", {}}
	PRIVATE _cPathTag		:= ""
	PRIVATE nZaDados	:= 0
	Private aMapGuia	:= {}

	Default aDados 		:= {}
	Default l974		:= .f.
	Default __lOnline	:= .f.
	Default cTipGui		:= "08"
	Default cXMLString	:= ""	

	nSeqGui := 0

	lOnline := __lOnline

	DbSelectArea("BVV")
	BVV->(DbSetOrder(1)) //BVV_FILIAL+BVV_TISVER
	If BVV->(MSSeek(xFilial("BVV")+cTissVer ))
		aXSD := StrTokArr(BVV->BVV_XSD, '|') //array com todos os XSDs da versao.
	Endif

	//transforma as variaveis em PRIVATE para ficarem visiveis na Macro Substituicao(&)
	// A DECLARAÇÃO TAMBEM ESTA NA FUNÇÃO QUE CHAMA DE FORMA PROPOSITAL
	// A ROTINA DE LOTES PRECISA DELA
	_SetOwnerPrvt("aDados",aDados)
	_SetOwnerPrvt("cFileXml",cFileXml)

	If (Len(aXSD) <= 0)
		aRet[1] := .T.
		AaDd(aRet[3], "** ERRO [ Arquivos XSD ] **")
		AaDd(aRet[3], "Arquivos XSD nao cadastrados na versao " + cTissVer + ".")
	Else
		
		if !empty(cXMLString)
			lstringOk := .T. ///(XmlSVldSch(cXMLString, cDirSchema+aXSD[1], @cErro,@cAviso) .or. XmlSVldSch(cXMLString, cDirSchema+aXSD[8], @cErro,@cAviso))
		endif
		//Realiza a validação da estrutura do XML com o XSD
		// O arquivo podera estar no formato de Lote Guia ou TISS Online
		If lstringOk .OR. (XmlFVldSch(cFileXml, cDirSchema+aXSD[1], @cErro,@cAviso) .or. XmlFVldSch(cFileXml, cDirSchema+aXSD[8], @cErro,@cAviso))

			//Valida se o arquivo enviado pertence a RDA que enviou
			For nX := 1 To Len(aDados)
				if AllTrim(aDados[nX, 2]) == "\MENSAGEMTISS\CABECALHO\ORIGEM\IDENTIFICACAOPRESTADOR\"
					cCodRDAx := PLS973VRDA(aDados[nX, 3])
					Exit
				EndIf
			Next

			cIdenPres := PLS973VRDA(cCodRDAx)

			if !(EmpTy(cIdenPres))

				carqPres := Substr(cFileXml,  RAT("\", AllTrim(cfileXml)) + 1)

				if !lstringOk
					BXX->( DbSetOrder(4) ) //BXX_FILIAL + BXX_CODINT + BXX_ARQIN
					If (BXX->( MsSeek( xFilial("BXX") + lower(cOpeMov + carqPres) ) ) .or. BXX->( MsSeek( xFilial("BXX") + upper(cOpeMov + carqPres) ) )) .AND. (Right("000000"+ cIdenPres,6) <> BXX->BXX_CODRDA)//BXX->(MsSeek(xfilial("BXX").T. //(cCodRDA <> cCodRDAX)
						If PLSPOSGLO(cOpeMov,__aXMLCri56[1],__aXMLCri56[2],cLocalExec,"1",cTipoGrv)
							aRet[1] := .T.
							AaDd(aRet[3], "** ERRO ["+__aXMLCri56[1]+"] **")
							AaDd(aRet[3], "Erro: " + PLSBCTDESC())
							Aadd(aRet[3], "RDA Submissao: " + 	BXX->BXX_CODRDA)
							Aadd(aRet[3], "RDA Origem XML: " + Right("000000"+ cIdenPres,6))
							Aadd(aRet[3], "")
							Erase(PLSMUDSIS( cDirRaiz+"UPLOAD\BACKUP\") + carqPres )
						Endif
					EndIf
				endif
				BXX->( DbSetOrder(1) ) //BXX_FILIAL + BXX_CODINT + BXX_CODRDA + BXX_ARQIN


				BAU->( DbSetOrder(1) ) //BAU_FILIAL+BAU_CODIGO
				if !BAU->( MsSeek( xFilial("BAU") + cIdenPres ) )
					aRet[1] := .T.
					AaDd(aRet[3], "** ERRO **")
					AaDd(aRet[3], "Erro: Codigo da RDA do arquivo XML nao esta cadastrada no sistema. ")
					Aadd(aRet[3], "Codigo da RDA: " + cIdenPres)
					Aadd(aRet[3], "")
					Erase(PLSMUDSIS( cDirRaiz+"UPLOAD\BACKUP\") + carqPres )
					RestArea(aAreaBAU)
				EndIf

			EndIf

			//Criação das variaveis - BVP
			If (aRet[1] == .F. .AND. PLSVARTISS(aDadosUnic, cTissVer, "", , @aRet,nil,@aVarsUnic) )

				//popula o array com os dados da BVN para ser utilizado na função PLSGETCRIT
				PLSBVNTAGS(cTissVer)

				For nI := 1 To Len(adados) //nI é a posição do aDados

					//a primeira posição do aMapGuia é o valor, que vai ser a posição do adados que tem o 'nSeqGui=X'
					If "nSeqGui" $ AllTrim(aDados[nI][2])
						aadd(aMapGuia, {nI, .F.})
					elseIf "\" $ aDados[nI][2] .AND. "nSeqGui" $ AllTrim(aDados[nI][3])
						aadd(aMapGuia, {nI, .F.})
					EndIf

					//vai ver se tem a tag de senha nessa guia
					//Se tiver, muda a posição 2 do array pra .T., pra usar nas validações lá da BVN
					If AllTrim(aDados[nI][1]) == "SENHA" .OR. AllTrim(aDados[nI][1]) == "*SENHA"
						aMapGuia[Len(aMapGuia)][2] := .T.
					EndIf

				Next

				//Validação dinamica das criticas TISS - BVN
				//Percorre as TAGs do XML
				For nI:=1 To Len(aDados)

					nZaDados := nI //Isso pode salvar vidas

					//TAG
					cTag := aDados[nI,1]

					//CAMINHO DA TAG
					cPathTag := StrTran(aDados[nI,2], "\\", "\")
					_cPathTag	:= cPathTag

					//VALOR DA TAG
					cTagValue := aDados[nI,3]

					//Se for o inicio de outra guia, pega a sequencia da guia
					if ("nSeqGui=" $ cTagValue)
						nSeqGui = Val(StrTokArr(cTagValue, "=")[2])
					endif

					if nI == Len(aDados) .Or. ("nSeqGui=" $ cTagValue)
						//indica que deve validar a existencia da tag
						lVldTp4	:= .T.
						aTgsTp4	:= aClone(aBkpTp4)
						nSeqTp4	:= iif(nI == Len(aDados) .And. nSeqGui == 1,nSeqGui,nSeqGui - 1)
					endif

					//Validacao de existencia de tag
					aAdd(aBkpTp4,{AllTrim(cPathTag),AllTrim(cTag)})

					//ATENCAO, EVITAR UTILIZAR ***CHUMBAR*** AQUI NO PROGRAMA ESTE TIPO DE SITUACAO, SO USAR QUANDO FOR ESTRITAMENTE NECESSARIO
					If UPPER('atendimentoRN') $ UPPER(cTag)
						lBenef := .t.
						aEvErros := {}//se eu to na tag de beneficiario siginifica que eu ja estou em outra guia entao eu limpo os eventos
					Endif

					If UPPER('registroANS') $ UPPER(cTag)//limpo a variavel pois quando chega nessa tag significa que entrei em outra guia
						lBenef := .f.
					Endif

					//Procura a TAG no aDadosUnic
					If !(cTag $ cTagExc)
						//Tratamento criado no CHANGESET 254909
						//Problema ao validar a TAG de procedimento, quando alguns arquivos
						//tinham 2 procedimentos, o segundo procedimento nunca era tratado
						nIndex := aScan( aDadosUnic, {|x| x[1]==cTag})
					Else
						//Somente as TAGs definidas na variavel 'cTagExc' deve trazer mais de uma ocorrencia
						//sendo assim o caminho tambem deve ser validado (PADRAO)
						nIndex := aScan( aDadosUnic, {|x| x[2] + x[1] == cPathTag + cTag})
					EndIf

					//Verifica no aDadosUnic se esta indicado que a TAG existe mais de uma vez no aDados antes de atualizar
					If (nIndex > 0 .And. aDadosUnic[nIndex, 4])

						//Ajuste do aDadosUnic
						aDadosUnic[nIndex, 3] := cTagValue
						PAjustUnic(@aDadosUnic,cPathTag, cTag, cTagValue)

						//Variavel de controle para duplicidade de criticas e variaveis
						aSize(aMacros,0)
						aMacros := Nil
						aMacros := {}

						//Atualiza somente as VARIAVEIS DINAMICAS que utilizam a TAG em validacao.
						If !PLSVARTISS(aDadosUnic, cTissVer, cPathTag+cTag, , @aRet,@aMacros,aVarsUnic)
							//Erro controlado: Caso encontre, sai do loop e exibe a mensagem informando o motivo.
							LOOP
						Else
							If Len(aMacros) > 0
								pExecMacro(@aMacros,@aRet,cPathTag+cTag)
							Endif
						Endif
					EndIf

					//seleciona todas as criticas da referente a tag agrupadas pelo BVN_GRPCND
					//Abaixo o comentario da Coluna e o seus indice no array aCrit
					//BVN_CDITEM=1 BVN_TAG=2 BVN_CAMTAG=3 BVN_TPVLD=4 BVN_ALIA=5 BVN_INDICE=6 BVN_DADEXP=7 BVN_CODTAB=8 BVN_BLCPRE=9 BVN_BLCPOS=10
					//BVN_GRPCND=11 BVN_CODOPE=12 BVN_PROPRI=13 BVN_CODGLO=14 BVN_TAGMSG=15 BVN_MSGAUX=16
					aCrit := PLSGETCRIT(cTag, cPathTag)

					If (Len(aCrit) > 0)
						//Percorre todas as criticas da BVN
						For nC := 1 To Len(aCrit)

							//Reinicia o valor das variaveis
							lCriticOk	:= .T.
							cDescriGlo 	:= ""

							//Dados BCT
							cCodOpe := aCrit[nC, 1, 12]
							cPropri := aCrit[nC, 1, 13]
							cCodGlo := aCrit[nC, 1, 14]

							//seleciona a descrição da critica para guardar e caso necessario ser utilziada na chamada da função PL973ADDER
							BCT->(DbSelectArea("BCT"))
							BCT->(DbSetOrder(1))
							lSeekBCT := BCT->(MSSeek(xFilial("BCT")+cCodOpe+cPropri+cCodGlo))
							If (lSeekBCT)
								cDescriGlo 	:= BCT->BCT_DESCRI
							EndIf

							//percorre o grupo de criticas, se epenas uma estiver OK entao nao deve exibir a critica
							For nC2 := 1 To Len(aCrit[nC])

								If (nC2 > 1 .And. lCriticOk == .T.)
									EXIT //sai do loop pois e necessario apenas uma das validações do mesmo grupo(BVN_GRPCND) estar ok para nao emitir a critica
								EndIF

								//Codigo Item
								cCdItem := aCrit[nC, nC2, 1]
								//Tipo Validação
								cTpVld := aCrit[nC, nC2, 4]
								//Alias e Indice
								cAlias := aCrit[nC, nC2, 5]
								nIndice := aCrit[nC, nC2, 6]
								//Dado/Expressao
								cDadExp := aCrit[nC, nC2, 7]
								//Bloco de Pre Execução
								cBlcPre := aCrit[nC, nC2, 9]
								//Bloco de Pos Execução
								cBlcPos := aCrit[nC, nC2, 10]

								//verifica se foi informado o bloco de codigo que deve ser executado no comeco da validação
								If (!Empty(AllTrim(cBlcPre)))
									//Executa a expressao, so verifica se executou sem erro
									If (!PLSEXECEXP(cBlcPre, cCodGlo, cDescriGlo, cCdItem, aDadosUnic, @aRet)[1])
										//se ocorreu erro volta o loop
										LOOP
									EndIF
								EndIf

								//Busca Registro
								If (cTpVld == "1")

									//seleciona o alias e seu indice
									&(cAlias)->(DbSelectArea(cAlias))
									&(cAlias)->(DbSetOrder(nIndice))

									//se a expressao nao foi informada
									If (Empty(AllTrim(cDadExp)))
										lCriticOk := &(cAlias)->(MsSeek(xFilial(cAlias)+cTagValue))
										//expressao informada, entao apenas executa o seek, e se executou ok executa a expressao
									ElseIf (&(cAlias)->(MsSeek(xFilial(cAlias)+cTagValue)))
										//Executa a expressao
										aRetExec := PLSEXECEXP(cDadExp, cCodGlo, cDescriGlo, cCdItem, aDadosUnic, @aRet)

										//verifica se a expressao foi executada sem erro
										If (!aRetExec[1])
											//se ocorreu erro volta o loop
											LOOP
										EndIF

										//pega o retorno da critica
										lCriticOk := aRetExec[2]
									Else
										//informa que ocorreu um erro
										lCriticOk := .F.
									EndIF
									//1
									//Valida Terminologia
								ElseIf (cTpVld == "2")

									//seta o codigo da terminologia
									cCdTermi := aCrit[nC, nC2, 8]

									BTQ->(DbSelectArea("BTQ"))
									BTQ->(DbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM

									lCriticOk := BTQ->(MsSeek(xFilial("BTQ")+cCdTermi+AllTrim(cTagValue)))

									//se o seek acima foi bem sucedido entao verifica se o item da terminologia tem alguma relação na tabela de De/Para(BTU)
									If lCriticOk  .and. BCT->(FieldPos('BCT_ENVCOX')) > 0 .and. BCT->BCT_ENVCOX <> "1"  // se tiver habilitado nao posso criticar na submissao do arquivo
										BTU->(DbSelectArea("BTU"))
										BTU->(DbSetOrder(3)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_CDTERM
										If !BTU->(MsSeek(_BTUFIlial+cCdTermi+cAlias+cTagValue)) ///.And. cCdTermi <> "24"
											//Adiciona a critica no array de erros					  // neste fonte nao deve existir este tipo de situacao
											aRet[1] := .T.											  // sempre que for necessario implementar isso, deve ser feito no load3
											If (lSeekBCT)
												aAdd(aRet[3], "** ERRO ["+cCodGlo+"] **")
											Else
												aAdd(aRet[3], "** ERRO **")
											EndIf
											aAdd(aRet[3],"Cadastro de-para invalido para o item")
											aAdd(aRet[3],"Terminologia : "+cCdTermi)
											If Empty(aCrit[nC, nC2, 15])
												aAdd(aRet[3],"Tag : "+cPathTag+cTag)
												aAdd(aRet[3],"Valor no XML : "+cTagValue)
											Else
												If ("," $ aCrit[nC, nC2-1, 15])
												aTags := StrTokArr ( aCrit[nC, nC2-1, 15], "," )
												For nC3 := 1 To Len(aTags)
													If (!EMPTY(PVLRTAGXML(aDadosUnic, AllTrim(aTags[nC3]))))
														aAdd(aRet[3],"Tag : "+aTags[nC3])
														aAdd(aRet[3],"Valor no XML : "+PVLRTAGXML(aDadosUnic, AllTrim(aTags[nC3])))
														EXIT
													EndIf
												Next
											Elseif aCrit[nC, nC2-1, 15] <> "*"
												aAdd(aRet[3],"Tag XML: "+aCrit[nC, nC2-1, 15])
												aAdd(aRet[3],"Valor no XML : "+PVLRTAGXML(aDadosUnic, AllTrim(aCrit[nC, nC2-1, 15])))
											EndIf
										EndIf
										aAdd(aRet[3],"Alias : "+cAlias)
										aAdd(aRet[3],"")
									EndIF
								EndIf

								//Expressao
							ElseIf (cTpVld == "3")

								//verifica se tem alias cadastrado para realizar um Seek antes da expressao
								If (!Empty(AllTrim(cAlias)) .And. nIndice > 0)
									&(cAlias)->(DbSelectArea(cAlias))
									&(cAlias)->(DbSetOrder(nIndice))

									//executa o Seek
									//caso o seek nao seja realizado com sucesso, volta para o topo pois a expressao pode ser um seek tambem
									If !(&(cAlias)->(MsSeek(xFilial(cAlias)+cTagValue)))
										&(cAlias)->(DbGoTop())
									EndIf
								EndIf

								//Tratativa para manter o registro da Glosa salva, caso a expressao cadastrada da BVN execute uma funcao que perca o registro
								nRecGlo := BCT->(RecNo())

								//Executa a expressao
								aRetExec := PLSEXECEXP(cDadExp, cCodGlo, cDescriGlo, cCdItem, aDadosUnic, @aRet)

								//Retornando ao registro
								BCT->(dbGoTo(nRecGlo))

								//pega o retorno da critica
								lCriticOk := aRetExec[2]

								//verifica se a expressao foi executada sem erro
								If (!aRetExec[1])
									//se ocorreu erro volta o loop
									LOOP
								EndIF

							EndIf

							//verifica se foi informado o bloco de codigo que deve ser executado no final da validação
							If (lCriticOk .And. !Empty(AllTrim(cBlcPos)))
								//Executa a expressao, so verifica se executou sem erro
								If (!PLSEXECEXP(cBlcPos, cCodGlo, cDescriGlo, cCdItem, aDadosUnic, @aRet)[1])
									//se ocorreu erro volta o loop
									LOOP
								EndIF
							EndIf
						Next

						//Se ocorreu algum erro
						If !lCriticOk

							//Verificar se a crítica é uma exceção do prestador
							If !PLSCHKCRI( {'BAU',cIdenPres,cPropri+cCodGlo} )
								loop
							Endif

							If aScan(aEvErros,{|x| x == cSlvPad+cSlvPro}) > 0
								loop
							Endif

							If  !plIsntPrd({__aXMLCri17[1],__aXMLCri16[1],__aXMLCri29[1],__aXMLCri10[1]},aRet[3]) .and. ;
									cCodGlo $__aXMLCri37[1]+__aXMLCri28[1]+__aXMLCri31[1]+__aXMLCri30[1]+__aCdCri175[1]+__aXMLCri44[1]
								loop
							Endif

							//se a critica estiver no array aCritNConf ou BCT->BCT_ENVCOX == '0' entao a critica nao pode ir para conferencia
							//e o XML deve ser criticado
							If aScan(aCritNConf, {|x| x==BCT->(BCT_PROPRI+BCT_CODGLO)}) > 0 .OR. ;
									BCT->(FieldPos('BCT_ENVCOX')) == 0 .or. !PLsAliasExi("BXV") .or. (BCT->BCT_ENVCOX == '0' .OR. Empty(BCT->BCT_ENVCOX))

								If BCT->(FieldPos('BCT_ALERTA')) > 0 .AND. BCT->BCT_ALERTA == "1"
									aAdd(aAlerta, "*** ALERTA ["+cCodGlo+"] ***")

									If cCodGlo $ __aXMLCri27[1]
										aadd(aEvErros,cSlvPad+cSlvPro)
									Endif

									If (lSeekBCT)
										aAdd(aAlerta,BCT->BCT_DESCRI)
									EndIf

									If !EMPTY(aCrit[nC, nC2-1, 16])
										aAdd(aAlerta,&(aCrit[nC, nC2-1, 16]))
									EndIf

									If Empty(aCrit[nC, nC2-1, 15])
										aAdd(aAlerta,"Tag XML: "+cPathTag+cTag)
										aAdd(aAlerta,"Valor no XML : "+cTagValue)
									Else
										If ("," $ aCrit[nC, nC2-1, 15])
										aTags := StrTokArr ( aCrit[nC, nC2-1, 15], "," )
										For nC3 := 1 To Len(aTags)
											If (!EMPTY(PVLRTAGXML(aDadosUnic, AllTrim(aTags[nC3]))))
												aAdd(aAlerta,"Tag : "+aTags[nC3])
												aAdd(aAlerta,"Valor no XML : "+PVLRTAGXML(aDadosUnic, AllTrim(aTags[nC3])))
												EXIT
											EndIf
										Next
									Elseif alltrim(aCrit[nC, nC2-1, 15]) <> "*"
										aAdd(aAlerta,"Tag XML: "+aCrit[nC, nC2-1, 15])
										aAdd(aAlerta,"Valor no XML : "+PVLRTAGXML(aDadosUnic, AllTrim(aCrit[nC, nC2-1, 15])))
									EndIf
								EndIf
								If !("PLVLDCHSH" $ cDadExp) .and. lBenef
									aAdd(aAlerta,"Beneficiario: "+ aDadosUnic[aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NUMEROCARTEIRA'  })][3])
								Endif

								If (cTpVld $ "1,3")
									If l974 .and. lDebug
										If !Empty(cAlias)
											aAdd(aAlerta,"Alias: "+cAlias)
										Endif
										If nIndice > 0
											aAdd(aAlerta,"Indice: "+cValToChar(nIndice))
										Endif
										aAdd(aAlerta,"Dado/Expressao: "+cDadExp)
										aAdd(aAlerta,"Dado/Expressao Executado: "+P973MONEXP(cDadExp, aDadosUnic))
									Endif
									If "PLVLDCHSH" $ cDadExp // Necessario exibir o Hash correto do arquivo
										aAdd(aAlerta,"Hash do conteudo: "+PLVLDCHSH())
									EndIf
								ElseIf (cTpVld == "2")
									If l974 .and. lDebug
										If !Empty(cAlias)
											aAdd(aAlerta,"Alias: "+cAlias)
										Endif
										aAdd(aAlerta,"Terminologia: "+cCdTermi)
									Endif
								EndIf
								If l974 .and. lDebug
									If (!EMPTY(cBlcPre))
										aAdd(aAlerta,"Bloco Pre: "+cBlcPre)
									EndIF
									If (!EMPTY(cBlcPos))
										aAdd(aAlerta,"Bloco Pos: "+cBlcPos)
									EndIF
								Endif
								aAdd(aAlerta,"")
							Else
								aRet[1] := .T.

								aAdd(aRet[3], "** ERRO ["+ IIf( Len(cCodGlo) == 2, cPropri+cCodGlo, cCodGlo)+"] **")

								If cCodGlo $ __aXMLCri27[1]
									aadd(aEvErros,cSlvPad+cSlvPro)
								Endif

								If (lSeekBCT)
									aAdd(aRet[3],BCT->BCT_DESCRI)
								EndIf

								//Buscando o código e descrição da TUSS referente à essa glosa.
								BTU->(dbSetOrder(4)) //BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_ALIAS

								cCodTUSS := ""
								cDesTUSS := ""

								If BTU->(MsSeek(_BTUFIlial+"38"+xFilial("BCT")+cPropri+cCodGlo))
									cCodTUSS := BTU->BTU_CDTERM
									BTQ->(dbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
									if BTQ->(MsSeek(xFilial("BTQ")+"38"+BTU->BTU_CDTERM))
										cDesTUSS := BTQ->BTQ_DESTER
									EndIf
									aAdd(aRet[3], "Critica TUSS: " + AllTrim(cCodTUSS) + " - " + AllTrim(cDesTUSS) + ".")
								EndIf

								If !EMPTY(aCrit[nC, nC2-1, 16])
									//Desenvolvido para utilizar o caracter "#" como token de quebra
									//de linha para mensagem auxiliar
									If At("#",aCrit[nC, nC2-1, 16]) > 0
										aMsgAux:= StrTokArr(aCrit[nC, nC2-1, 16],"#")
										For nMsgAux := 1 to Len(aMsgAux)
											cMsgAux := &(aMsgAux[nMsgAux])
											Iif(!Empty(cMsgAux),aAdd(aRet[3],cMsgAux),NIL)
										Next
									Else
										aAdd(aRet[3],&(aCrit[nC, nC2-1, 16]))
									EndIf
								EndIf

								If Empty(aCrit[nC, nC2-1, 15])
									aAdd(aRet[3],"Tag XML: "+cPathTag+cTag)
									aAdd(aRet[3],"Valor no XML : "+cTagValue)
								Else
									If ("," $ aCrit[nC, nC2-1, 15])
									aTags := StrTokArr ( aCrit[nC, nC2-1, 15], "," )
									For nC3 := 1 To Len(aTags)
										If (!EMPTY(PVLRTAGXML(aDadosUnic, AllTrim(aTags[nC3]))))
											aAdd(aRet[3],"Tag : "+aTags[nC3])
											aAdd(aRet[3],"Valor no XML : "+PVLRTAGXML(aDadosUnic, AllTrim(aTags[nC3])))
											EXIT
										EndIf
									Next
								Elseif alltrim(aCrit[nC, nC2-1, 15]) <> "*"
									aAdd(aRet[3],"Tag XML: "+aCrit[nC, nC2-1, 15])
									aAdd(aRet[3],"Valor no XML : "+PVLRTAGXML(aDadosUnic, AllTrim(aCrit[nC, nC2-1, 15])))
								EndIf
							EndIf

							If !("PLVLDCHSH" $ cDadExp) .and. lBenef
								aAdd(aRet[3],"Beneficiario: "+ aDadosUnic[aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NUMEROCARTEIRA'  })][3])
								If aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NUMEROGUIAPRESTADOR'  }) > 0
									aAdd(aRet[3],"Numero da Guia do Prestador: "+ aDadosUnic[aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NUMEROGUIAPRESTADOR'  })][3])
								Endif

								//Verifica se existe conteudo na variavel de complemento das criticas
								If !Empty(CCOMPCRI)
									nCompCri := 1
									While !Empty(MemoLine(CCOMPCRI,254,nCompCri))
										aAdd(aRet[3],AllTrim(MemoLine(CCOMPCRI,254,nCompCri)))
										nCompCri++
									EndDo
								ElseIf RAT(cPathTag,'EQUIPESADT\') > 0//Dentro de EQUIPESADT o nome da tag e NOMEPROF
									If aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NOMEPROF' }) > 0
										aAdd(aRet[3],"Nome do Profissional: "+ aDadosUnic[aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NOMEPROF' })][3])
									Endif
								Else//fora de EQUIPESADT o nome da tag e NOMEPROFISSIONAL
									If aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NOMEPROFISSIONAL' }) > 0
										aAdd(aRet[3],"Nome do Profissional: "+ aDadosUnic[aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NOMEPROFISSIONAL' })][3])
									Endif
								EndIf

								CCOMPCRI := ""

							Endif

							If (cTpVld $ "1,3")
								If l974 .and. lDebug
									If !Empty(cAlias)
										aAdd(aRet[3],"Alias: "+cAlias)
									Endif
									If nIndice > 0
										aAdd(aRet[3],"Indice: "+cValToChar(nIndice))
									Endif
									aAdd(aRet[3],"Dado/Expressao: "+cDadExp)
									aAdd(aRet[3],"Dado/Expressao Executado: "+P973MONEXP(cDadExp, aDadosUnic))
								Endif
								If "PLVLDCHSH" $ cDadExp // Necessario exibir o Hash correto do arquivo
									aAdd(aRet[3],"Hash do conteudo: "+PLVLDCHSH())
								EndIf
							ElseIf (cTpVld == "2")
								If l974 .and. lDebug
									If !Empty(cAlias)
										aAdd(aRet[3],"Alias: "+cAlias)
									Endif
									aAdd(aRet[3],"Terminologia: "+cCdTermi)
								Endif
							EndIf


							If l974 .and. lDebug
								If (!EMPTY(cBlcPre))
									aAdd(aRet[3],"Bloco Pre: "+cBlcPre)
								EndIF
								If (!EMPTY(cBlcPos))
									aAdd(aRet[3],"Bloco Pos: "+cBlcPos)
								EndIF
							Endif
							aAdd(aRet[3],"")
						EndIf
					Else
						If (lSeekBCT)
							PAddBXV(cCodGlo, BCT->BCT_DESCRI, nSeqGui, cCodPad, cCodPro, cSeqBXX)
						Else
							PAddBXV(cCodGlo, "", nSeqGui, cCodPad, cCodPro, cSeqBXX)
						EndIf
						If !EMPTY(aCrit[nC, nC2-1, 16])
							//Desenvolvido para utilizar o caracter "#" como token de quebra
							//de linha para mensagem auxiliar
							If At("#",aCrit[nC, nC2-1, 16]) > 0
								aMsgAux:= StrTokArr(aCrit[nC, nC2-1, 16],"#")
								For nMsgAux := 1 to Len(aMsgAux)
									cMsgAux := &(aMsgAux[nMsgAux])
									Iif(!Empty(cMsgAux),PAddBXV("",cMsgAux, nSeqGui, cCodPad, cCodPro, cSeqBXX),NIL)
								Next
							Else
								PAddBXV("",&(aCrit[nC, nC2-1, 16]), nSeqGui, cCodPad, cCodPro, cSeqBXX)
							EndIf
						EndIf
						If EMPTY(aCrit[nC, nC2-1, 15])
							PAddBXV("", "Tag XML: "+cPathTag+cTag, nSeqGui, cCodPad, cCodPro, cSeqBXX)
							PAddBXV("", "Valor no XML : "+cTagValue, nSeqGui, cCodPad, cCodPro, cSeqBXX)
						ElseIf ("," $ aCrit[nC, nC2-1, 15])
							aTags := StrTokArr ( aCrit[nC, nC2-1, 15], "," )
							For nC3 := 1 To Len(aTags)
								If (!EMPTY(PVLRTAGXML(aDadosUnic, aTags[nC3])))
									aAdd(aRet[3],"Tag : "+aTags[nC3])
									aAdd(aRet[3],"Valor no XML : "+PVLRTAGXML(aDadosUnic, aTags[nC3]))
									EXIT
								EndIf
							Next
						Elseif aCrit[nC, nC2-1, 15] <> "*"
							PAddBXV("", "Tag XML: "+aCrit[nC, nC2-1, 15], nSeqGui, cCodPad, cCodPro, cSeqBXX)
							PAddBXV("", "Valor no XML : "+PVLRTAGXML(aDadosUnic, aCrit[nC, nC2-1, 15]), nSeqGui, cCodPad, cCodPro, cSeqBXX)
						EndIf
						If !("PLVLDCHSH" $ cDadExp ) .and. lBenef
							PAddBXV("", "Beneficiario: "+ aDadosUnic[aScan(aDadosUnic,{|x| alltrim(x[1]) == 'NUMEROCARTEIRA'  })][3], nSeqGui, cCodPad, cCodPro, cSeqBXX)
						Endif

						PAddBXV("","", nSeqGui, cCodPad, cCodPro, cSeqBXX)
					EndIf
				EndIF
				Next
			EndIf

			//percorre as validacoes Existencia da TAG
			if lVldTp4

				//Zera para alimentar a referencia da proxima guia
				aSize(aBkpTp4,0)
				aBkpTp4 := Nil
				aBkpTp4 := {}

				lVldTp4	:= .F.

				for nTp4 := 1 to Len(aCrTp4)
					//Armazena caminho e TAG
					cTagVld4	:= StrTran(aCrTp4[nTp4][1],'-','_')
					cPathVld4	:= StrTran(aCrTp4[nTp4][2],'-','_')
					cGloVld4	:= aCrTp4[nTp4][4] + aCrTp4[nTp4][5]

					//Posiciona na critica
					BCT->(DbSelectArea("BCT"))
					BCT->(DbSetOrder(1))
					BCT->(MSSeek(xFilial("BCT") + PLSIntPad() + cGloVld4))

					//Se foi informado o caminho da TAG e o mesmo nao existe, pode ser que sejam criticas especificas para um tipo de guia.
					//Sendo assim, primeiro devo avaliar se o caminho existe. Para diferenciar os tipos de guia, o campo BVN_CAMTAG
					//deve conter alguma TAG que defina o tipo de guia (ex.: \LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\).
					If !Empty(cPathVld4) .And. (aScan( aTgsTp4,{|x| cPathVld4 $ Upper(x[1])} ) > 0)
						If (aScan( aTgsTp4,{|x| Upper(cPathVld4 + cTagVld4) $ x[1] + x[2]} ) <= 0)

							lgoT4xx := .T.

							x := Len(aMapGuia)
							While x > 0
								If nZaDados >= aMapGuia[x][1]
									Exit
								EndIf
								x--
							EndDo

							for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
								If aDados[y][1] == cTagVld4
									lgoT4xx := .F.
								EndIf
							Next

							If lgoT4xx
								If nSeqTp4	 == 0 .Or. (aScan(aCritNConf, {|x| x==BCT->(BCT_PROPRI+BCT_CODGLO)}) > 0 .Or. ;
										BCT->(FieldPos('BCT_ENVCOX')) == 0 .or. !PLsAliasExi("BXV") .or. (BCT->BCT_ENVCOX == '0' .Or. Empty(BCT->BCT_ENVCOX)))


									//Adiciona a critica no array de erros
									aRet[1] := .T.
									aAdd(aRet[3], "** ERRO [" + cGloVld4 + "] **")
									aAdd(aRet[3],"Tag nao encontrada no XML.")
									aAdd(aRet[3],"Arquivo: " + cFileXml)
									aAdd(aRet[3],"Caminho da Tag: " + cPathVld4)
									aAdd(aRet[3],"Tag XML: " + cTagVld4)
									aAdd(aRet[3],"")

									//Mensagem auxiliar
									If !EMPTY(aCrTp4[nTp4][8])
										//Desenvolvido para utilizar o caracter "#" como token de quebra
										//de linha para mensagem auxiliar
										If At("#",aCrTp4[nTp4][8]) > 0
											aMsgAux:= StrTokArr(aCrTp4[nTp4][8],"#")
											For nMsgAux := 1 to Len(aMsgAux)
												cMsgAux := &(aMsgAux[nMsgAux])
												Iif(!Empty(cMsgAux),aAdd(aRet[3],cMsgAux),NIL)
											Next
										Else
											aAdd(aRet[3],&(aCrTp4[nTp4][8]))
										EndIf
									EndIf
								Else
									PAddBXV(cGloVld4, BCT->BCT_DESCRI, nSeqTp4, , , cSeqBXX)
									PAddBXV("", "Tag nao encontrada no XML.", nSeqTp4, , , cSeqBXX)
									PAddBXV("", "Caminho da Tag: " + cPathVld4, nSeqTp4, , , cSeqBXX)
									PAddBXV("", "Arquivo: " + cFileXml, nSeqTp4, , , cSeqBXX)
									PAddBXV("", "Tag XML: " + cTagVld4, nSeqTp4, , , cSeqBXX)
									If !EMPTY(aCrTp4[nTp4][8])
										//Desenvolvido para utilizar o caracter "#" como token de quebra
										//de linha para mensagem auxiliar
										If At("#",aCrTp4[nTp4][8]) > 0
											aMsgAux:= StrTokArr(aCrTp4[nTp4][8],"#")
											For nMsgAux := 1 to Len(aMsgAux)
												cMsgAux := &(aMsgAux[nMsgAux])
												Iif(!Empty(cMsgAux),PAddBXV("",cMsgAux, nSeqTp4, , , cSeqBXX),NIL)
											Next
										Else
											PAddBXV("",&(aCrTp4[nTp4][8]), nSeqTp4, , , cSeqBXX)
										EndIf
									EndIf
								EndIf
							endIf
						EndIf
						//Caso contratio, verifico a existencia da TAG de modo geral desprezando o caminho
					ElseIf Empty(cPathVld4) .And. (aScan( aTgsTp4,{|x| cTagVld4 $ Upper(x[2])} ) <= 0)

						lgoT4xx := .T.

						x := Len(aMapGuia)
						While x > 0
							If nZaDados >= aMapGuia[x][1]
								Exit
							EndIf
							x--
						EndDo

						for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
							If aDados[y][1] == cTagVld4
								lgoT4xx := .F.
							EndIf
						Next

						If lgoT4xx
							If aScan(aCritNConf, {|x| x==BCT->(BCT_PROPRI+BCT_CODGLO)}) > 0 .OR. ;
									BCT->(FieldPos('BCT_ENVCOX')) == 0 .or. !PLsAliasExi("BXV") .or. (BCT->BCT_ENVCOX == '0' .OR. Empty(BCT->BCT_ENVCOX))

								//Adiciona a critica no array de erros
								aRet[1] := .T.
								aAdd(aRet[3], "** ERRO [" + cGloVld4 + "] **")
								aAdd(aRet[3],"Tag nao encontrada no XML.")
								aAdd(aRet[3],"Arquivo: " + cFileXml)
								aAdd(aRet[3],"Caminho da Tag: " + cPathVld4)
								aAdd(aRet[3],"Tag XML: " + cTagVld4)
								aAdd(aRet[3],"")

								//Mensagem auxiliar
								If !EMPTY(aCrTp4[nTp4][8])
									//Desenvolvido para utilizar o caracter "#" como token de quebra
									//de linha para mensagem auxiliar
									If At("#",aCrTp4[nTp4][8]) > 0
										aMsgAux:= StrTokArr(aCrTp4[nTp4][8],"#")
										For nMsgAux := 1 to Len(aMsgAux)
											cMsgAux := &(aMsgAux[nMsgAux])
											Iif(!Empty(cMsgAux),aAdd(aRet[3],cMsgAux),NIL)
										Next
									Else
										aAdd(aRet[3],&(aCrTp4[nTp4][8]))
									EndIf
								EndIf
							Else
								PAddBXV(cGloVld4, BCT->BCT_DESCRI, nSeqTp4, , , cSeqBXX)
								PAddBXV("", "Tag nao encontrada no XML.", nSeqTp4, , , cSeqBXX)
								PAddBXV("", "Caminho da Tag: " + cPathVld4, nSeqTp4, , , cSeqBXX)
								PAddBXV("", "Arquivo: " + cFileXml, nSeqTp4, , , cSeqBXX)
								PAddBXV("", "Tag XML: " + cTagVld4, nSeqTp4, , , cSeqBXX)
								If !EMPTY(aCrTp4[nTp4][8])
									//Desenvolvido para utilizar o caracter "#" como token de quebra
									//de linha para mensagem auxiliar
									If At("#",aCrTp4[nTp4][8]) > 0
										aMsgAux:= StrTokArr(aCrTp4[nTp4][8],"#")
										For nMsgAux := 1 to Len(aMsgAux)
											cMsgAux := &(aMsgAux[nMsgAux])
											Iif(!Empty(cMsgAux),PAddBXV("",cMsgAux, nSeqTp4, , , cSeqBXX),NIL)
										Next
									Else
										PAddBXV("",&(aCrTp4[nTp4][8]), nSeqTp4, , , cSeqBXX)
									EndIf
								EndIf
							EndIf
						endIf
					EndIf
				next

				//Zera para pegar a referencia da proxima guia
				aSize(aTgsTp4,0)
				aTgsTp4 := Nil
				aTgsTp4 := {}

			endif
			Next
		EndIf
	Else
		aRet[1] := .T.
		AaDd(aRet[3], "** ERRO [ Estrutura XML ] **")
		AaDd(aRet[3], cErro)
		if lIntHat .AND. !(empTy(BXX->BXX_PLSHAT))
			MontRetHAT(, cErro,,, { '' , BXX->BXX_PLSHAT, BXX->BXX_CODRDA })
		endIf
	EndIf
	EndIf

	//Percorrendo todo o XML em busca de valores para alimentar na BXX e BCI
	nValTotG  := 0
	If cTipgui == '01'
		//Tratamento especifico para guia de consulta. Nao existe a tag QUANTIDADEEXECUTADA, apenas a tag VALORPROCEDIMENTO
		While (nI := aScan(aDados,{|x| AllTrim(x[1]) == 'VALORPROCEDIMENTO'  })) > 0
			nValTotG += val(aDados[nI][3])
			//Removendo a chave para nao ficar em looop infinito
			aDados[nI][1] := ''
		Enddo
	ElseIf !PLSPOSGLO(cOpeMov,__aXMLCri54[1],__aXMLCri54[2],cLocalExec,"1",cTipoGrv)
		While (nQtdX := aScan(aDados,{|x| alltrim(x[1]) == 'QUANTIDADEEXECUTADA' })) > 0 .And. (nValX := aScan(aDados,{|x| alltrim(x[1]) == 'VALORUNITARIO' })) > 0 .And. (nAcrX := aScan(aDados,{|x| alltrim(x[1]) == 'REDUCAOACRESCIMO' })) > 0  .And. (nValTotX := aScan(aDados,{|x| alltrim(x[1]) == 'VALORTOTAL' })) > 0
			//A Regra para o valor otal da guia deve ser dada pelo valor total do procedimento. Todos os acréscimos/reduções que um prestador informar estarão embutidos no valor total que ele está cobrando.
			nValTotG += (val(aDados[nValTotX][3]))
			//Removendo a chave para nao ficar em looop infinito
			aDados[nValX][1] 		:= ''
			aDados[nQtdX][1] 		:= ''
			aDados[nAcrX][1] 		:= ''
			aDados[nValTotX][1] 	:= ''
		Enddo
	Else
		While (nI := aScan(aDados,{|x| alltrim(x[1]) == 'VALORTOTAL' })) > 0
			nValTotG += val(aDados[nI][3])
			//Removendo a chave para nao ficar em looop infinito
			aDados[nI][1] := ''
		Enddo
	EndIf

	If nValTotG = 0 .AND. cTipgui == '07'
		While (nI := aScan(aDados,{|x| alltrim(x[1]) == 'VALORTOTALPROC' })) > 0
			nValTotG += val(aDados[nI][3])
			//Removendo a chave para nao ficar em looop infinito
			aDados[nI][1] := ''
		Enddo
	EndIf

	nValTot3X := nValTotG

	If IsInCallStack("PLSXMLBATCH")
		aRet[2] := BAU->BAU_CODIGO
	Else
		aRet[2] := cCodRDAx
	EndIf

	If LEN(aAlerta) > 0

		If LEN(aRet[3]) == 0
			aRet[1] := .F.
		EndIf

		For nI := 1 To LEN(aAlerta)
			AADD(aRet[3], aAlerta[nI])
		Next

	EndIf

Return aRet

/*/{Protheus.doc} PLSBVNTAGS
Retorna um array com o recno e o Caminho+TAG de todas as criticas da BVN.
@type function
@author Bruno Iserhardt
@since 03/09/13
@version 1.0
/*/
Function PLSBVNTAGS(cTissVer)
	LOCAL cLocalExec := '5'
	LOCAL cOpeMov 	 := PlsIntPad()
	LOCAL cTipoGrv	 := '1'
	LOCAL nI		 := 1

	BVN->(DbSelectArea("BVN"))
	BVN->(DbSetOrder(1)) //BVN_FILIAL+BVN_TISVER+BVN_TAG+BVN_CAMTAG

	If (BVN->(MsSeek(xFilial("BVN")+cTissVer)))

		While (!BVN->(Eof()) .And. BVN->(BVN_FILIAL+BVN_TISVER) == xFilial("BVN")+cTissVer) .and. BVN->BVN_CODOPE == cOpeMov
			//esta função so retorna criticas que nao sao do tipo Existencia de TAG, esse tipo de validação realizado de outra forma
			If (BVN->BVN_TPVLD != "4")
				//verifica se existe a critica da validação e se ela esta ativa
				If (nI:= aScan(__XACRITICAS,{|x| alltrim(x[1]) == alltrim(BVN->(BVN_PROPRI+BVN_CODGLO)) })) > 0
					//Esta critica em especifico eu crio ela INATIVA pois em autogestoes e medicinas de grupos
					//o prestador vai sempre mandar o xml e eles sempre vao pagar com base no xml, ja em unimeds
					//se o cara ja executou no portal ele nao pode mandar denovo no XML
					If __XACRITICAS[nI][1] == __aXMLCri28[1]
						cTp := '0'
					Else
						cTp := '1'
					Endif
					//eu tenho que fazer o PLSPOSGLO para criar a critica caso ela nao exista e tb para tratar o caso
					//em que eu quero acatar o arquivo mais eu vou critica-lo depois na mudanca de fase
					If PLSPOSGLO(cOpeMov,__XACRITICAS[nI][1],__XACRITICAS[nI][2],cLocalExec,cTp,cTipoGrv)
						cCanTag := alltrim(strtran(strtran(alltrim(BVN->BVN_CAMTAG),chr(09),''),chr(11),''))//tiro o tab
						cTag    := alltrim(strtran(strtran(alltrim(BVN->BVN_TAG),chr(09),''),chr(11),''))//tiro o tab
						aAdd(aTagsBVN, {cCanTag+cTag, BVN->(Recno())})
					EndIf
				Endif
			Else
				If (nI:= aScan(__XACRITICAS,{|x| alltrim(x[1]) == alltrim(BVN->(BVN_PROPRI+BVN_CODGLO)) })) > 0
					cTag    := alltrim(strtran(strtran(alltrim(BVN->BVN_TAG),chr(09),''),chr(11),''))//tiro o tab
					cCanTag := alltrim(strtran(strtran(alltrim(BVN->BVN_CAMTAG),chr(09),''),chr(11),''))//tiro o tab

					aAdd(aCrTp4, {	cTag,;     														// [1]
						cCanTag,;  														// [2]
						BVN->BVN_DADEXP,; 												// [3]
						BVN->BVN_PROPRI,; 												// [4]
						BVN->BVN_CODGLO,; 												// [5]
						BVN->BVN_CODOPE,;												// [6]
						IIf(BVN->( FieldPos("BVN_MSGAUX") ) > 0, BVN->BVN_TAGMSG,""),;	// [7]
						IIf(BVN->( FieldPos("BVN_MSGAUX") ) > 0, BVN->BVN_MSGAUX,"")})	// [8]
				Endif
			Endif
			BVN->(DbSkip())
		EndDo
	EndIF
Return aTagsBVN

/*/{Protheus.doc} PLSGETCRIT
Retorna todas as criticas existentes para a mesma TAG
@type function
@author Bruno Iserhardt
@since 28/08/13
@version 1.0
/*/
Function PLSGETCRIT(cTag, cPathTag)
	Local nIGroup 	:= 0
	Local nI 		:= 1
	Local aCrit 	:= {}

	BVN->(DbSelectArea("BVN"))

	//aTagsBVN gerado pela funcao PLSBVNTAGS
	For nI := 1 To Len(aTagsBVN)

		If (alltrim(aTagsBVN[nI,1]) $ cPathTag+cTag)

			//posiciona a BVN na critica pelo RECNO
			BVN->(DbGoTo(aTagsBVN[nI, 2]))

			//veririfca se a critica tem algum grupo
			nIGroup := 0
			If (!Empty(AllTrim(BVN->BVN_GRPCND)))
				//procura se o grupo ja esta adicionado no array de criticas
				nIGroup := aScan(aCrit, {|x| x[1, 11] == BVN->BVN_GRPCND})
			EndIF

			If (nIGroup > 0)
				//adiociona a critica no array do seu grupo correspondente
				cCanTag := alltrim(strtran(strtran(alltrim(BVN->BVN_CAMTAG),chr(09),''),chr(11),''))//tiro o tab
				cTag    := alltrim(strtran(strtran(alltrim(BVN->BVN_TAG),chr(09),''),chr(11),''))//tiro o tab
				aAdd(aCrit[nIGroup], {BVN->BVN_CDITEM,;  //1
					cTag,;     //2
					cCanTag,;  //3
					BVN->BVN_TPVLD,;   //4
					BVN->BVN_ALIAS,;   //5
					BVN->BVN_INDICE,;  //6
					BVN->BVN_DADEXP,;  //7
					BVN->BVN_CODTAB,;  //8
					BVN->BVN_BLCPRE,;  //9
					BVN->BVN_BLCPOS,;  //10
					BVN->BVN_GRPCND,;  //11
					BVN->BVN_CODOPE,;  //12
					BVN->BVN_PROPRI,;  //13
					BVN->BVN_CODGLO,;  //14
					IIf(BVN->( FieldPos("BVN_MSGAUX") ) > 0, BVN->BVN_TAGMSG,""),; //15 BVN->( FieldPos("BVN_VIGINI") ) > 0
					IIf(BVN->( FieldPos("BVN_MSGAUX") ) > 0, BVN->BVN_MSGAUX,"")}) //16
			Else
				//adiociona a critica no array
				cCanTag := alltrim(strtran(strtran(alltrim(BVN->BVN_CAMTAG),chr(09),''),chr(11),''))//tiro o tab
				cTag    := alltrim(strtran(strtran(alltrim(BVN->BVN_TAG),chr(09),''),chr(11),''))//tiro o tab
				aAdd(aCrit, {{BVN->BVN_CDITEM,;  //1
					cTag,;     //2
					cCanTag,;  //3
					BVN->BVN_TPVLD,;   //4
					BVN->BVN_ALIAS,;   //5
					BVN->BVN_INDICE,;  //6
					BVN->BVN_DADEXP,;  //7
					BVN->BVN_CODTAB,;  //8
					BVN->BVN_BLCPRE,;  //9
					BVN->BVN_BLCPOS,;  //10
					BVN->BVN_GRPCND,;  //11
					BVN->BVN_CODOPE,;  //12
					BVN->BVN_PROPRI,;  //13
					BVN->BVN_CODGLO,;  //14
					IIf(BVN->( FieldPos("BVN_MSGAUX") ) > 0, BVN->BVN_TAGMSG,""),; //15 BVN->( FieldPos("BVN_VIGINI") ) > 0
					IIf(BVN->( FieldPos("BVN_MSGAUX") ) > 0, BVN->BVN_MSGAUX,"")}}) //16
			EndIf
		EndIf
	Next

Return aCrit

/*/{Protheus.doc} PLSVARTISS
Cria as variaveis de acordo com o array unico criado pela funcao PLDADOUNIC
@type function
@author Bruno Iserhardt
@since 14/08/13
@version 1.0
@return lOk , logico, .T. caso nao ocorra erro na criacao de nenhuma variavel.
/*/
Function PLSVARTISS(aDadosUnic, cTissVer, cCamTag, aVars, aRet,aMacros,aManBVP)
	Local lOk 			:= .T.
	Local cNomVar		:= ""
	Local cExpressao	:= ""
	Local cExpMontad	:= ""
	Local aVarsCri		:= {} //array de variaveis que foram criadas/alteradas
	Local nPos,nI		:= 0
	Local laVarsAux	:= Type("aVarsAux") <> "U"

	PRIVATE aErrVarVin := {.F., "", "", ""}
	PRIVATE cCamTagGen := cCamTag // FOI NECESSARIA a criacao dessa variavel (SE NAO FOR PRIVATE A MACRO NAO ENXERGA) para que a estrutura dinamica fosse possivel validar corretamente nos niveis corretos do XML
	Default cCamTag 	:= ""
	Default aVars		:= {}
	Default aManBVP	:= {} // [1] Nome da Variavel, [2] Expressao [3] Dado Seek [4] Alias Seek [5] Indice Seek [6] tem dependencia .T. OU .F. [7] VALOR ANTERIOR - se tem dependencia qual Valor anterior para nao executar desnecessariamente

	//Criacao das variaveis - BVP
	If aManBVP <> Nil .AND. Len(aManBVP) > 0// Se foi passado o array por parametro eh porque ja tem as configuracoes e nao precisa acessar a base
		For nI := 1 To Len(aManBVP) // Faco a mesma soh que fora do Alias BVP e com os controles do Array
			//se o cCamTag estiver vazio entao deve fazer para todas as variaveis
			//caso contrario deve criar somente as variaveis que utilizam a tag enviada em suas expressoes
			//ou tambem deve recriar a variavel caso ela tenha sido enviada do array aVars
			If ((Empty(AllTrim(cCamTag)) .And. Len(aVars) <= 0) .OR. ;
					PLTAGINEXP(cCamTag, aManBVP[nI][3]) .OR. ;
					PLTAGINEXP(cCamTag, aManBVP[nI][2]) .OR. ;
					(Len(aVars) > 0 .And. aScan(aVars, {|x| x $ aManBVP[nI][3] .Or. x $ aManBVP[nI][2]}) > 0))

				cNomVar := AllTrim(aManBVP[nI][1])

				//se tem algum alias cadastrado realiza o Seek no mesmo
				If (!Empty(AllTrim(aManBVP[nI][4])))
					cAlias := aManBVP[nI][4]
					//seta o alias cadastrado
					&(cAlias)->(DbSelectArea(cAlias))
					//seta o indice cadastrado
					&(cAlias)->(DbSetOrder(aManBVP[nI][5]))

					//expressao informada
					cExpressao := AllTrim(aManBVP[nI][3])
					//chama a função P973MONEXP para substituir as tags necessarias caso haja alguma na expressao
					cExpMontad := P973MONEXP(aManBVP[nI][3], aDadosUnic)
					//realiza o seek
					&(cAlias)->(MsSeek(&(cExpMontad)))
				ElseIf (!Empty(AllTrim(aManBVP[nI][3])))
					//expressao informada
					cExpressao := AllTrim(aManBVP[nI][3])
					//chama a função P973MONEXP para substituir as tags necessarias caso haja alguma na expressao
					cExpMontad := P973MONEXP(aManBVP[nI][3], aDadosUnic)
					//executa a expressao
					&(cExpMontad)
				EndIf

				//expressao informada
				cExpressao := AllTrim(aManBVP[nI][2])
				//chama a função P973MONEXP para substituir as tags necessarias caso haja alguma na expressao
				cExpMontad := P973MONEXP(cExpressao, aDadosUnic)
				//realiza a criação da variavel
				If aMacros <> nil
					aadd(aMacros,{cNomVar,cExpMontad})
				Else

					If Type(cNomVar) <> "U"
						&(cNomVar) :=  &(cExpMontad)
					Else
						_SetOwnerPrvt(cNomVar, &(cExpMontad))
					EndIf

					If laVarsAux
						If (nPos := aScan(aVarsAux, {|x| Upper(x[2]) == Upper(cNomVar)} )) > 0
							&(aVarsAux[nPos,1] + "3X") := &(cNomVar)
						EndIf
					EndIf

					//verifica se ocorreu erro na função PLSVARVINC aqui pois nao foi possivel passar o aRet para a mesma
					If (aErrVarVin[1])

						//reinicia o vetor que indica que deu erro na PLSVARVINC
						aErrVarVin[1] := .F.

						//indica que ocorreu erro na criação das variaveis
						lOk := .F.
						//Adiciona a critica no array de erros
						aRet[1] := .T.

						aAdd(aRet[3],"** [ ERRO DE CONFIGURACAO ] **")
						aAdd(aRet[3],"Dado enviado no arquivo nao possui vinculo (De-Para)")
						//aAdd(aRet[3],"Nome variavel: " + cNomVar)
						aAdd(aRet[3],"Dado enviado: "+AllTrim(aErrVarVin[3]))
						aAdd(aRet[3],"Tabela Terminologia TISS: "+AllTrim(aErrVarVin[2]))
						If !Empty(AllTrim(aErrVarVin[4]))
							aAdd(aRet[3],"Tabela PLS : "+AllTrim(aErrVarVin[4]) + "-" + AllTrim(Posicione("SX2",1,AllTrim(aErrVarVin[4]),"SX2->X2_NOME")) )
						EndIf
						aAdd(aRet[3],"")
					EndIf
				Endif
				//adiciona a variavel que foi criada/alterada para poder recriar as variaveis que a utiliza na composição do seu valor
				//somente se nao for pra criar todas as variavels (AQUI EU OLHO SE TEM DEPENDENCIA E SE O VALOR ANTERIOR NAO EH IGUAL AO NOVO)
				If ((!Empty(cCamTag) .Or. Len(aVars) > 0) .AND. lOk .AND. aManBVP[nI][6] .AND. (&(cNomVar) <> aManBVP[nI][7]))

					aManBVP[nI][7] := &(cNomVar) // ATUALIZO O VALOR ATUAL DA VARIAVEL
					aAdd(aVarsCri, cNomVar)

				EndIf
			EndIf
		Next nI
	Else // Caso nao tenha o Bckup ainda da BVP e passou o Array vazio ele sera alimentado para as proximas
		//Criação das variaveis - BVP
		//Posiciona a tabela das variaveis
		lCriaBVP := (aManBVP <> Nil .AND. Len(aManBVP) == 0) // retirado do While pois nao estava olhando todas as criticas
		BVP->(DbSelectArea("BVP"))
		BVP->(DbSetOrder(1)) //BVP_FILIAL+BVP_TISVER
		//Verifica se encontrou alguma variavel para a versao TISS
		If(BVP->(MsSeek(xFilial("BVP")+cTissVer)))
			//Percorre a tabela para criar as variaveis
			While (!BVP->(Eof()) .And. BVP->(BVP_FILIAL+BVP_TISVER) == xFilial("BVP")+cTissVer)
				If lCriaBVP
					//[1] Nome da Variavel, [2] Expressao [3] Dado Seek [4] Alias Seek [5] Indice Seek [6] tem dependencia .T. OU .F. [7] VALOR ANTERIOR
					AADD(aManBVP, {BVP->BVP_NOMVAR,BVP->BVP_VLREXP,BVP->BVP_DADSEK,BVP->BVP_ALIAS,BVP->BVP_INDICE,.F.,Nil})
				EndIf
				//se o cCamTag estiver vazio entao deve fazer para todas as variaveis
				//caso contrario deve criar somente as variaveis que utilizam a tag enviada em suas expressaos
				//ou tambem deve recriar a variavel caso ela tenha sido enviada do array aVars
				If ((Empty(AllTrim(cCamTag)) .And. Len(aVars) <= 0) .OR. ;
						PLTAGINEXP(cCamTag, BVP->BVP_DADSEK) .OR. ;
						PLTAGINEXP(cCamTag, BVP->BVP_VLREXP) .OR. ;
						(Len(aVars) > 0 .And. aScan(aVars, {|x| x $ BVP->BVP_DADSEK .Or. x $ BVP->BVP_VLREXP}) > 0))

					cNomVar := AllTrim(BVP->BVP_NOMVAR)

					//se tem algum alias cadastrado realiza o Seek no mesmo
					If (!Empty(AllTrim(BVP->BVP_ALIAS)))
						cAlias := BVP->BVP_ALIAS
						//seta o alias cadastrado
						&(cAlias)->(DbSelectArea(cAlias))
						//seta o indice cadastrado
						&(cAlias)->(DbSetOrder(BVP->BVP_INDICE))

						//expressao informada
						cExpressao := AllTrim(BVP->BVP_DADSEK)
						//chama a função P973MONEXP para substituir as tags necessarias caso haja alguma na expressao
						cExpMontad := P973MONEXP(BVP->BVP_DADSEK, aDadosUnic)
						//realiza o seek
						&(cAlias)->(MsSeek(&(cExpMontad)))
					ElseIf (!Empty(AllTrim(BVP->BVP_DADSEK)))
						//expressao informada
						cExpressao := AllTrim(BVP->BVP_DADSEK)
						//chama a função P973MONEXP para substituir as tags necessarias caso haja alguma na expressao
						cExpMontad := P973MONEXP(BVP->BVP_DADSEK, aDadosUnic)
						//executa a expressao
						&(cExpMontad)
					EndIf

					//expressao informada
					cExpressao := AllTrim(BVP->BVP_VLREXP)
					//chama a função P973MONEXP para substituir as tags necessarias caso haja alguma na expressao
					cExpMontad := P973MONEXP(cExpressao, aDadosUnic)
					//realiza a criação da variavel
					If aMacros <> nil
						aadd(aMacros,{cNomVar,cExpMontad})
					Else
						If Type(cNomVar) <> "U"
							if( ! empty( cExpMontad ) )
								&(cNomVar) :=  &(cExpMontad)
							endIf
						Else
							_SetOwnerPrvt(cNomVar, &(cExpMontad))
						EndIf

						If laVarsAux
							If (nPos := aScan(aVarsAux, {|x| Upper(x[2]) == Upper(cNomVar)} )) > 0
								&(aVarsAux[nPos,1] + "3X") := &(cNomVar)
							EndIf
						EndIf

						//verifica se ocorreu erro na função PLSVARVINC aqui pois nao foi possivel passar o aRet para a mesma
						If (aErrVarVin[1])
							//reinicia o vetor que indica que deu erro na PLSVARVINC
							aErrVarVin[1] := .F.
							//indica que ocorreu erro na criação das variaveis
							lOk := .F.
							//Adiciona a critica no array de erros
							aRet[1] := .T.

							aAdd(aRet[3],"** [ ERRO DE CONFIGURACAO ] **")
							aAdd(aRet[3],"Dado enviado no arquivo nao possui vinculo (De-Para)")
							//aAdd(aRet[3],"Nome variavel: " + cNomVar)
							aAdd(aRet[3],"Dado enviado: "+AllTrim(aErrVarVin[3]))
							aAdd(aRet[3],"Tabela Terminologia TISS: "+AllTrim(aErrVarVin[2]))
							If !Empty(AllTrim(aErrVarVin[4]))
								aAdd(aRet[3],"Tabela PLS : "+AllTrim(aErrVarVin[4]) + "-" + AllTrim(Posicione("SX2",1,AllTrim(aErrVarVin[4]),"SX2->X2_NOME")) )
							EndIf
							aAdd(aRet[3],"")
						EndIf
					Endif
					//adiciona a variavel que foi criada/alterada para poder recriar as variaveis que a utiliza na composição do seu valor
					//somente se nao for pra criar todas as variavels
					If ((!Empty(cCamTag) .Or. Len(aVars) > 0) .AND. lOk)
						aAdd(aVarsCri, cNomVar)
					EndIf
				EndIf
				//proximo registro
				BVP->(DbSkip())
			EndDo
		EndIf
	Endif
	//se estiver variaveis que foram alteradas
	If (Len(aVarsCri) > 0 .AND. lOk)
		//chama novamente a função para verificar se alguma outra variavel utiliza o valor das variaveis alteradas para serem recriadas
		lOk := PLSVARTISS(aDadosUnic, cTissVer, "", aVarsCri, @aRet,@aMacros,aManBVP)
	EndIf

Return lOk

/*/{Protheus.doc} pExecMacro

@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
static function pExecMacro(aMacros,aRet,cCamTag)

	LOCAL aArray := {}
	LOCAL nI	 := 1
	LOCAL cNomVar 	  := ""
	LOCAL cExpMontad  := ""
	Local lAVarsAux	:= Type("aVarsAux") <> "U"
	PRIVATE aErrVarVin := {.F., "", "", ""}
	PRIVATE cCamTagGen := cCamTag // FOI NECESSARIA a criacao dessa variavel (SE NAO FOR PRIVATE A MACRO NAO ENXERGA) para que a estrutura dinamica fosse possivel validar corretamente nos niveis corretos do XML

	For nI:=1 to Len(aMacros)
		if aScan(aArray,{|x| x[1] == aMacros[nI][1] .and. x[2] == aMacros[nI][2] }) == 0
			aadd(aArray,aMacros[nI])
		Endif
	Next

	For nI:=1 to Len(aArray)
		cNomVar 	:= aArray[nI][1]
		cExpMontad  := aArray[nI][2]

		If Type(cNomVar) <> "U"
			&(cNomVar) :=  &(cExpMontad)
		Else
			_SetOwnerPrvt(cNomVar, &(cExpMontad))
		EndIf

		If lAVarsAux
			If (nPos := aScan(aVarsAux, {|x| Upper(x[2]) == Upper(cNomVar)} )) > 0
				&(aVarsAux[nPos,1] + "3X") := &(cNomVar)
			EndIf
		EndIf

		//verifica se ocorreu erro na função PLSVARVINC aqui pois nao foi possivel passar o aRet para a mesma
		If (aErrVarVin[1])
			//reinicia o vetor que indica que deu erro na PLSVARVINC
			aErrVarVin[1] := .F.

			//indica que ocorreu erro na criação das variaveis
			lOk := .F.
			//Adiciona a critica no array de erros
			aRet[1] := .T.

			aAdd(aRet[3],"** [ ERRO DE CONFIGURACAO ] **")
			aAdd(aRet[3],"Dado enviado no arquivo nao possui vinculo (De-Para)")
			aAdd(aRet[3],"Dado enviado: "+AllTrim(aErrVarVin[3]))
			aAdd(aRet[3],"Tabela Terminologia TISS: "+AllTrim(aErrVarVin[2]))
			If !Empty(AllTrim(aErrVarVin[4]))
				aAdd(aRet[3],"Tabela PLS : "+AllTrim(aErrVarVin[4]) + "-" + AllTrim(Posicione("SX2",1,AllTrim(aErrVarVin[4]),"SX2->X2_NOME")) )
			EndIf
			aAdd(aRet[3],"")
		EndIf
	Next

return

/*/{Protheus.doc} PLSVARVINC
Retorna o valor do PLS para um item de uma terminologia. Utilizada somente para a funcao PLSVARTISS.
@type function
@author Bruno Iserhardt
@since 09/09/13
@version 1.0
/*/
Function PLSVARVINC(cCodTab, cAlias, cCdTerm, cDireto, cTagCrit, aTabDup, cAtuTab)
	local aArea			:= {}
	local cVlrBus 		:= ""
	local lCrit			:= .F.
	local nCT 			:= 0
	local lDireto		:= .F.
	local cChvBusDir	:= ""
	local laTabDup  	:= .f.
	local lcAtuTab  	:= .f.
	local lBr8  		:= .f.

	default cAlias 		:= ""
	default cDireto 	:= "" // Variavel passada no cadastro de variaveis BVP para informar o conteudo do seek para buscar diretamente no alias caso nao encontre o de-para
	default cTagCrit	:= "" // Variavel que informa a tag que a somente quando estiver validando a mesma o sistema ira criticar (para o caso de criticas de de-para com valores inconsistencias, o sistema estava criticando sem estar atualizado o valor da variavel correta)
	default aTabDup 	:= {}
	default cAtuTab		:= ""

	if type("aErrVarVin") == 'U'
		private aErrVarVin := {.F., "", "", ""}
	endIf

	//Verificação rápida do busca direta
	//consideração importante sobre o Busca Direta:
	//Para funcionar deve haver alias vinculado à BTP e o campo BTP_CHVTAB deve conter um índice existente (e utilizável)
	//para fazermos uma busca na base. No geral a ideia é bem simples, busca direta igual Sim, faz seek na tabela usando
	//ordenando ela pelo BTP_CHVBUS, usando o conteúdo da variável cChvBusDir (alimenta ali embaixo) pra buscar.
	BTP->(DbSetOrder(1))
	If BTP->(MsSeek(xFilial("BTP")+cCodTab)) .AND. BTP->BTP_BUSDIR == "1"

		If ! Empty(cAlias) .and. (nIndUt := PLSBUIND(cAlias,(cAlias+"_FILIAL+") + alltrim(BTP->BTP_CHVTAB) ) ) > 0

			aArea := &(cAlias + "->(getArea())" )

			&(cAlias+"->(DbSetOrder(" + alltrim(str(nIndUt)) + "))")

			If ! EmpTy(cDireto)

				cChvBusDir := cDireto

			elseif cAlias == "BR8"

				cChvBusDir := cCodTab + cCdTerm

			else
				cChvBusDir := cCdTerm
			endIf

			If &( cAlias + "->( MsSeek( '" + xFilial(cAlias) + strTran(cChvBusDir, "'", "") + "' ))" )
				If cCodTab=="24" .and. cAlias=="BAQ"
					cCdTerm := BAQ->BAQ_CODESP
				Endif
				lDireto := .T.
			Endif

			restArea(aArea)

		Endif

		If lDireto == .T. .and. aErrVarVin[1]== .F.
			Return cCdTerm
		endIf

	EndIf

	If ! Empty(cAlias)

		BTP->( DbSetOrder(1) )
		BTP->( MsSeek( xFilial("BTP") + cCodTab ) )

		BTU->(DbSetOrder(3)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_CDTERM
		If BTU->(MsSeek(_BTUFIlial + cCodTab + cAlias + padr(cCdTerm, tamsx3("BTU_CDTERM")[1])))
			lBr8 	 := (cAlias == "BR8")
			lcAtuTab := !(empty(cAtuTab))
			laTabDup := !(empty(aTabDup))

			cVlrBus 		:= BTU->BTU_VLRBUS
			aErrVarVin[1] 	:= .F.

			// validação em casos de duas tabelas padroes vinculadas a uma unica terminologia
			// na chamada da função a variavel cAtuTab é utilizada com @, sendo possível trocar a tabela caso necessário
			if laTabDup .and. lBr8 .and. lcAtuTab
				BTU->(dbSetOrder(4)) // BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_ALIAS
				for nCT := 1 to Len(aTabDup)
					// se encontrado registro, verifica se o de-para (cCodTab) é referente a mesma tabela na posição atual do aTabDup
					if BTU->(msSeek(_BTUFIlial+cCodTab+xFilial("BR8")+aTabDup[nCt,2]+cCdTerm))
						if allTrim(aTabDup[nCt,1]) == allTrim(cCodTab)
							cAtuTab := aTabDup[nCt,2]
							cVlrBus := BTU->BTU_VLRBUS
							aErrVarVin[1] 	:= .F.
							exit
						endif
					endif
				next
			endif

		Else

			If ! Empty(aTabDup) // estrutura para que seja possivel verificar duas tabelas padroes vinculadas a uma unica terminologia

				For nCT := 1 to Len(aTabDup)

					If Alltrim(aTabDup[nCt,1]) == cCodTab

						//implementei a regra de busca direto aqui tambem - daher (under validation)
						If BTP->BTP_BUSDIR == '1'

							nIndUt := PLSBUIND(cAlias,(cAlias+"_FILIAL+")+alltrim(BTP->BTP_CHVTAB))

							If nIndUt > 0 .and. ! Empty(cDireto)

								nSlvOrd := &(cAlias+"->(IndexOrd())")   //tenho que salvar o indice pois ele nao pode despoicionar uma tabela que esta la fora por exemplo

								&(cAlias + "->(DbSetOrder(" + alltrim(str(nIndUt)) + "))" )

								If &(cAlias+"->(MsSeek('" + xFilial(cAlias) + Alltrim(aTabDup[nCT,2] + Substr(cDireto,3,Len(cDireto))) + "'))")

									cVlrBus 		:= cCdTerm
									cAtuTab 		:= aTabDup[nCT,2] //alimento o aTabDup encontrado para ser usado fora desta funcao, por exemplo
									aErrVarVin[1] 	:= .F.

									&(cAlias+"->(DbSetOrder("+alltrim(str(nSlvOrd))+"))")

									Return cVlrBus

								Else
									lCrit := .T.
								Endif

								&(cAlias+"->(DbSetOrder("+alltrim(str(nSlvOrd))+"))")

							Else
								lCrit := .T.
							Endif

						Else

							BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
							If (BTU->(MsSeek(_BTUFIlial + cCodTab + cAlias + padr(Alltrim(aTabDup[nCT,2] + Substr(cCdTerm,3,Len(cCdTerm))), tamsx3("BTU_CDTERM")[1]))))

								cVlrBus := BTU->BTU_VLRBUS
								lCrit 	:= .F.

								Return cVlrBus

							EndIf

						Endif

					EndIf

					lCrit := .T. // Se nao achou nenhuma ai critica

				Next nCT

			ElseIf BTP->BTP_BUSDIR == '1'

				nIndUt := PLSBUIND(cAlias,(cAlias+"_FILIAL+") + alltrim(BTP->BTP_CHVTAB))

				If nIndUt > 0 .and. ! Empty(cDireto)

					nSlvOrd := &(cAlias+"->(IndexOrd())")   //tenho que salvar o indice pois ele nao pode despoicionar uma tabela que esta la fora por exemplo

					&(cAlias + "->(DbSetOrder(" + alltrim(str(nIndUt)) + "))")

					If &(cAlias + "->(MsSeek('" + xFilial(cAlias) + cDireto + "'))")

						cVlrBus 		:= cCdTerm
						aErrVarVin[1] 	:= .F.

					Else
						lCrit := .T.
					Endif

					&(cAlias+"->(DbSetOrder("+alltrim(str(nSlvOrd))+"))")

				Else
					lCrit := .T.
				Endif

			Else
				lCrit := .T.
			Endif

		EndIf

	Else

		BTU->(DbSetOrder(5)) //BTU_FILIAL, BTU_CODTAB, BTU_CDTERM, BTU_ALIAS
		If (BTU->(MsSeek(_BTUFIlial+cCodTab+padr(cCdTerm, tamsx3("BTU_CDTERM")[1]))))

			cVlrBus 		:= BTU->BTU_VLRBUS
			aErrVarVin[1] 	:= .F.

		Else
			lCrit := .T.
		EndIf

	Endif

	If lCrit .AND. ! Empty(cTagCrit)

		// VERIFICACAO NECESSARIA PARA CONTINUAR DINAMICO A VALIDACAO EM NIVEIS DO XML, SE NAO FOR PRIVATE A MACRO NAO ENXERGA
		If Type("cCamTagGen") <> 'U'
			lCrit := ( Upper(Alltrim(cTagCrit)) $ Upper(cCamTagGen))
		EndIf

	EndIf

	If lCrit

		//Ponto de entrada para manipular a tabela de-para, haiente que importa e dentro do sistema analisa
		If ExistBlock("PLIMPTDO")

			aErrVarVin := ExecBlock("PLIMPTDO",.F.,.F.,{aErrVarVin,cCodTab, cAlias, cCdTerm} )

			If Empty (cVlrBus) .And. aErrVarVin[1] .And. Len(aErrVarVin[4])>=1
				cVlrBus    := aErrVarVin[4]
			Else
				cVlrBus    := cCdTerm
			EndIf

		Else
			aErrVarVin[1] := .T.
			aErrVarVin[2] := cCodTab
			aErrVarVin[3] := cCdTerm
			aErrVarVin[4] := cAlias
			cVlrBus := cCdTerm
		Endif

	EndIf

	If ExistBlock("PLCODPAD")
		cVlrBus := ExecBlock("PLCODPAD",.F.,.F.,{cCodTab, cAlias, cCdTerm,cDireto, cTagCrit, aTabDup,cAtuTab,cVlrBus} )
	Endif

Return cVlrBus

/*/{Protheus.doc} PLTAGINEXP
Verifica se a tag estao sendo utilizada em uma expressao
@type function
@author Bruno Iserhardt
@since 14/08/13
@version 1.0
/*/
Function PLTAGINEXP(cCamTag, cExpressao)
	Local lRet := .F.
	Local nI := 1
	Local nBegin := 0
	Local nEnd := 0
	Local cPathTag := ""
	Local aPathTag := {}

	//loop para varrer todas as tags da expressao
	For nI := 1 To Len(StrTokArr ( cExpressao, "[%" ))-1
		//seleciona os indices do inicio e fim da tag
		nBegin := At("[%",cExpressao)
		nEnd := At("%]",cExpressao)
		//seleciona na expressao o caminho e a tag
		cPathTag := SubStr(cExpressao, nBegin+2, nEnd-nBegin-2)
		//cria um array de todos os caminhos existentes na expressao
		aPathTag := StrTokarr(cPathTag, ",")

		//verifica se esta contida pois na expressao pode estar somente uma parte do caminho da tag
		//Ex.: a tag no xml e \MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIACONSULTA\CABECALHOCONSULTA\REGISTROANS
		//porem o cPathTag pode ter somente parte do caminho \CABECALHOCONSULTA\REGISTROANS
		If (aScan(aPathTag, {|x| x $ cCamTag} ) > 0)
			lRet := .T.
			EXIT
		EndIF
		//remove a tag da expressao
		cExpressao := StrTran(cExpressao, "[%" + cPathTag + "%]", "")
	Next
Return lRet

/*/{Protheus.doc} PLSEXECEXP
Executa a expressao enviada utilizando Macro Substituicao.
@type function
@author Bruno Iserhardt
@since 13/08/13
@version 1.0
@return aReturn, array,	[1] = Indica se a expressao foi executada sem erro/[2] = Valor retornado da expressao
/*/
Function PLSEXECEXP(cExpressao, cCodGlo, cDescriGlo, cCdItem, aDadosUnic, aRet)
	Local aReturn		:= {.T., .T.}
	Local cExpMontad	:= ""
	Local oError		:= ErrorBlock({|e| PL973ADDER(cCodGlo, cDescriGlo, cExpressao, cExpMontad, cCdItem, e:Description, @aRet,e:ErrorStack), ;
		aReturn[1] := .F. })
	//expressao da validação
	cExpressao := AllTrim(fwcutoff(cExpressao))
	//monta a expressao substituindo os valores das tag do XMl
	cExpMontad := P973MONEXP(cExpressao, aDadosUnic)
	//Tratamento realizado para um possivel erro na expressao
	Begin Sequence
		//Se a expressao retornou false, inclui a critica no array de erros
		aReturn[2] := &(cExpMontad)
	End Sequence
	ErrorBlock(oError)
Return aReturn

/*/{Protheus.doc} PL973ADDER
Adiciona um erro ocorrido no array enviado
@type function
@author Bruno Iserhardt
@since 23/07/13
@version 1.0
/*/
Function PL973ADDER(cCodGlo, cDescriGlo, cExpressao, cExpMontad, cCdItem, cErrorDesc, aRet, cStack)
	aRet[1] := .T.
	aAdd(aRet[3], "** [ ERRO NA EXPRESSAO ] **")
	aAdd(aRet[3], "Falha na execucao da expressao da critica " + cCodGlo + "-" + cDescriGlo)
	aAdd(aRet[3], "Item: " + cCdItem)
	aAdd(aRet[3], "Expressao cadastrada: " + cExpressao)
	aAdd(aRet[3], "Expressao executada: " + cExpMontad)
	aAdd(aRet[3], "Erro: " + cErrorDesc)
	aAdd(aRet[3], "")
Return

/*/{Protheus.doc} PLDADOUNIC
Retorna um array sem repetir a TAGS
@type function
@author Bruno Iserhardt
@since 14/08/13
@version 1.0
@param aDados, Array, Array com todos os dados do XML em validação
@return aUnic, Array, Replica do aDados sem a repetição de TAGS
/*/
Function PLDADOUNIC(aDados)
	Local aUnic 	:= {}
	Local nIndex	:= 0
	Local nI 		:= 1
	Local cTagExc		:= "CBOS/CBO/"
	Default aDados := {}

	For nI := 1 To Len(aDados)
		//Verifica se a TAG ja foi replicada para o aDadosUnic.
		If !(aDados[nI, 1] $ cTagExc)
			nIndex := aScan( aUnic,{|x|Upper(x[1])==aDados[nI, 1]} )
		Else
			//Somente as TAGs definidas na variavel 'cTagExc' deve trazer mais de uma ocorrencia
			//sendo assim o caminho deve ser validado
			nIndex := aScan(aUnic, {|x|Upper(x[2] + x[1]	) == aDados[nI, 2] + aDados[nI,1]})
		EndIf

		//Caso nao encontre
		If (nIndex <= 0)
			//Adiciona a TAG e insere um posicao com um FLAG informando que existe apenas uma ocorrencia
			aAdd(aUnic, aClone(aDados[nI]))
			aAdd(aUnic[Len(aUnic)], .F.)
		Else
			//Caso entre nessa condicao, significa que a TAG foi espelhada no bloco acima,
			//e abaixo o FLAG muda o STATUS para indicar que encontrou uma nova ocorrencia.
			aUnic[nIndex, 4] := .T.
		EndIF
	Next
Return aUnic

/*/{Protheus.doc} PLDADCRM
Caso exista RDAs com o mesmo codigo profissional saude
@type function
@author TOTVS
@since 14/08/13
@version 1.0
/*/
Function PLDADCRM(aDados)
	Local aCrm 	:= {}
	Local nIndex	:=  aScan(aDados,{|x| alltrim(x[1]) == "NUMEROCONSELHOPROFISSIONAL"  })
	Local nI 		:= 1
	Default aDados := {}

	If (nIndex > 0)
		nI := nIndex
		aAdd(aCrm, aClone(aDados[nI]))
	EndIF

	For nI := nI+1 To Len(aDados)
		nPos3 := aScan( aCrm,{|x|Upper(x[1])== aDados[nI, 1]} )
		If nPos3 > 0
			aAdd(aCrm, aClone(aDados[nI]))
		EndIf
	Next
Return aCrm

/*/{Protheus.doc} PLSTPGUIA
Retorna o tipo de guia do XML entre os tipos enviados.
@type function
@author Bruno Iserhardt
@since 19/08/13
@version 1.0
/*/
Function PLSTPGUIA(cTpGuias, aDadosUnic)
	Local cRet		:= ""
	Local nI		:= 0
	Local aTpGuias	:={}
	Local cAuxCtpGui:=cTpGuias

	cAuxCtpGui:=STRTRAN(cAuxCtpGui, "'", "")
	aTpGuias:=StrTokarr(cAuxCtpGui, ",")

	If (Len(aTpGuias) > 0)
		For nI := 1 To Len(aTpGuias)
			If (aScan(aDadosUnic,{|x| aTpGuias[nI] $ AllTrim(x[2]) }) > 0)
				cRet := aTpGuias[nI]
				EXIT
			EndIf
		Next
	EndIf

Return cRet

/*/{Protheus.doc} _PFoundPro
Utilizada pela critica X28
@type function
@author Daher
@since 13/09/14
@version 1.0
/*/
Function _PFoundPro(xTipGui,xCodPad,xCodPro,lValStatus,xRecnoAut,xTpProc)
	LOCAL lRet := .f.
	LOCAL aStats := {}
	LOCAL lEntrou := .f.
	Local cBkpNumgui := ""

	if !LPLHAT
		If xTipGui $ '02|13'
			If xRecnoAut > 0
				BEA->(DbGoTo(xRecnoAut))
			Endif
			cNumGuia := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
			BE2->(DbSetOrder(6))//BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO
			lRet := BE2->(MsSeek(xFilial("BE2")+cNumGuia+Alltrim(xCodPad+xCodPro)))
			If lValStatus .and. lRet
				lRet := BE2->BE2_STATUS == '1' // foi autorizado
				lEntrou := .t.//aqui eu indico que o procedimento esta na pre-autorizaca.. se ele ta na pre autorizacao eu nao vou checar os parametros opmm
			Endif
			BR8->(DbSetOrder(1))
			BR8->(MsSeek(xFilial('BR8')+xCodPad+xCodPro))
			//se eu nao achei o cara eu ainda assim vou ver no parametro se eu tenho que criticar
			If !lRet .and. !Empty(BR8->BR8_TPPROC) .and. !lEntrou
				xTpProc := BR8->BR8_TPPROC
				lRet := (AllTrim(xTpProc) $ AllTrim( GetNewPar("MV_PLSOPMM","0,1,2,3,4,5,6,7,8,9")))
			Endif

		Else
			If xRecnoAut > 0
				BE4->(DbGoTo(xRecnoAut))
			Endif
			cNumGuia := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			nQtdPre	 := 0
			BEJ->(DbSetOrder(1))
			BEJ->(MsSeek(xFilial("BEJ")+cNumGuia))
			nRecBEJ := 0
			while !BEJ->(Eof()) .and.  BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == ;
					xFilial("BEJ")+cNumGuia

				If alltrim(BEJ->(BEJ_CODPAD+BEJ_CODPRO)) == Alltrim(xCodPad+xCodPro)
					lRet := .T.
					aadd(aStats,BEJ->BEJ_STATUS)
				Endif
				BEJ->(DbSkip())
			Enddo
			//PROCURO NAS PRORROGACOES
			B4Q->(DbSetOrder(4))
			BQV->(DbSetOrder(1))
			If B4Q->(MsSeek(xFilial("B4Q") + cNumGuia)) //Cabeçalho da prorrogação de internação
				While !(B4Q->(EoF())) .AND. B4Q->(B4Q_FILIAL + B4Q_GUIREF) == xFilial("BQV")+cNumGuia
					cBkpNumgui := B4Q->(B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT)
					BQV->(MsSeek(xFilial("BQV")+cBkpNumgui))
					while !BQV->(Eof()) .and.  BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == ;
							xFilial("BQV")+cBkpNumgui

						If alltrim(BQV->(BQV_CODPAD+BQV_CODPRO)) == Alltrim(xCodPad+xCodPro)
							lRet := .T.
							aadd(aStats,BQV->BQV_STATUS)
						Endif
						BQV->(DbSkip())
					Enddo
					B4Q->(DbSkip())
				enddo
			endIf
			BQV->(MsSeek(xFilial("BQV")+cNumGuia)) //Mantido pela prorrogação de internação antiga, que não tinha B4Q, deve ser removido no futuro
			while !BQV->(Eof()) .and.  BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == ;
					xFilial("BQV")+cNumGuia

				If alltrim(BQV->(BQV_CODPAD+BQV_CODPRO)) == Alltrim(xCodPad+xCodPro)
					lRet := .T.
					aadd(aStats,BQV->BQV_STATUS)
				Endif
				BQV->(DbSkip())
			Enddo
			If lValStatus .and. lRet
				lRet := aScan(aStats,{|x| x == '1'}) > 0 // se tem pelo menos um autorizado.. isso eh necessario pois existem casos q o evento eh negado na autorizacao mas eh liberado na prorrogacao
				lEntrou := .t.//aqui eu indico que o procedimento esta na pre-autorizaca.. se ele ta na pre autorizacao eu nao vou checar os parametros opmm
			Endif
			//se eu nao achei o cara eu ainda assim vou ver no parametro se eu tenho que criticar
			BR8->(DbSetOrder(1))
			BR8->(MsSeek(xFilial('BR8')+xCodPad+xCodPro))
			//se eu nao achei o cara eu ainda assim vou ver no parametro se eu tenho que criticar
			If !lRet .and. !Empty(BR8->BR8_TPPROC) .and. !lEntrou
				xTpProc := BR8->BR8_TPPROC
				lRet := (AllTrim(xTpProc) $ AllTrim( GetNewPar("MV_PLSICRE","0,1,2,3,4,5,6,7,8,9")))
			Endif
		Endif

		//Caso nao encontre, procura nas guias de Anexos Clinicos
		If !lRet
			B4A->(DbSetOrder(4))//B4A_FILIAL + B4A_GUIREF
			If B4A->(MsSeek(xFilial("B4A") + cNumGuia))
				//Chave da guia alterada conforme o alias em analise
				cChave := B4A->( B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT) + AllTrim(xCodPad+xCodPro)
				//Verifica qual o B4C corresponde ao procedimento analisado e se foi liberado
				B4C->(DbSetOrder(3))//B4C_FILIAL + B4C_OPEMOV + B4C_ANOAUT + B4C_MESAUT + B4C_NUMAUT + B4C_CODPAD + B4C_CODPRO
				If B4C->(MsSeek(xFilial("B4C")+cChave)) .And. B4C->B4C_STATUS == '1'
					lRet := .T.
				EndIf
			EndIf
		EndIf

		//Consulta HAT B2Z
	else
		if xRecnoAut > 0
			lRet := PLSRTB2Z(COPEMOV, "", CMATRIC, xCodPad, xCodPro)[1]
		endif

	endif

Return lRet

/*/{Protheus.doc} PLQTDPRE
Utilizada pela critica X28
@type function
@author Bruno Iserhardt
@since 13/09/13
@version 1.0
/*/
Function PLQTDPRE()
	Local cNumGuia	:= ""
	Local nQtdPre	:= 0
	local aReslt		:= {}
	Local lRet := .F.

	if cTipGui <> '02' .OR. nRecnoAut == 0 //A validação não será processada se não houver autorização encontrada
					  						//Essa variável é preenchida na validação da crítica X23
											//Essa validação é somente para guias SADT!!
		lRet := .T.
	else
		if !lPLHAT
			BEA->( dbGoTo(nRecnoAut) )
			cNumGuia:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

			nQtdPre	 := 0
			BE2->(DbSetOrder(6))//BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO
			If BE2->(MsSeek(xFilial("BE2")+cNumGuia+Alltrim(cCodPad+cCodPro)))
				nRecBE2 := 0
				while !BE2->(Eof()) .and.  BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+alltrim(BE2_CODPAD+BE2_CODPRO)) == xFilial("BE2")+cNumGuia+Alltrim(cCodPad+cCodPro)
					nQtdPre += BE2->BE2_SALDO
					nRecBE2 := BE2->(Recno())
					BE2->(DbSkip())
				Enddo
			EndIF

			If nRecBE2 > 0
				BE2->(DbGoTo(nRecBE2))
			Endif

		else

			aReslt	 := PLSRTB2Z(COPEMOV, cNumGuia, CMATRIC, cCodPad, cCodPro)
			nQtdPre := aReslt[2] //{lRet, nQtdPre, nRecB2Z}
			nRecBE2 := aReslt[3]

			If nRecBE2 > 0
				B2Z->(DbGoTo(nRecBE2))
			Endif
		endif

		lret := nQtdPro <= nQtdPre
	endif

Return lRet

/*/{Protheus.doc} PCHKVIGOPE
Utilizada pela critica 09G
@type function
@author Bruno Iserhardt
@since 19/08/13
@version 1.0
/*/
Function PCHKVIGOPE()
	Local lCri := .F.

	If BAW->( FieldPos("BAW_VIGINI") ) > 0 .And. BAW->( FieldPos("BAW_VIGFIN") ) > 0

		If BAW->(MsSeek(xFilial("BAW")+cRdaOri+cOpeMov))

			While BAW->BAW_CODIGO ==  cRdaOri .And. BAW->BAW_CODINT == cOpeMov

				If BAW->BAW_VIGINI <> CTOD(" / / ") .And. BAW->BAW_VIGINI <= dDataBase .And.;
						(BAW->BAW_VIGFIN == CTOD(" / / ") .Or. BAW->BAW_VIGFIN >= dDataBase)
					lCri := .T.
				EndIf

				BAW->(dbSkip())
			EndDo

		Endif

	Endif

Return lCri

/*/{Protheus.doc} PLSEXECDAD
Retorna CNPJ, CPF ou CODIGONAOPERADORA do executante.
@type function
@author Bruno Iserhardt
@since 19/08/13
@version 1.0
/*/
Function PLSEXECDAD()
	Local cRet := PVLRTAGXML(aDadosUnic, "\contratadoExecutante\cpfContratado,\contratadoExecutante\cnpjContratado,\contratadoExecutante\codigoPrestadorNaOperadora,\dadosContratadoExecutante\codigonaOperadora")

	If 	(Empty(AllTrim(cRet)))
		cRet := cRdaOri
	EndIf

	If (Len(Alltrim(cRet)) != 11 .AND. Len(Alltrim(cRet)) != 14)
		cRet := StrZero( val(cRet), TamSX3("BAU_CODIGO")[1])
	Else
		cRet := PRDARight(cRet)
	EndIf

Return cRet

/*/{Protheus.doc} PLAJUSTRDA
Ajusta o conteudo da variavel cRdaOri.
@type function
@author Bruno Iserhardt
@since 10/09/13
@version 1.0
/*/
Function PLAJUSTRDA(cRda)
	If (Len(Alltrim(cRda)) != 14 .AND. Len(Alltrim(cRda)) != 11)
		cRda := Right("000000" + cRda, 6)
	Else
		cRda := PRDARight(cRda)
	EndIf
Return cRda

/*/{Protheus.doc} PLVLDCHSH
Retorna o Hash do arquivo XML que esta sendo validado.
@type function
@author Bruno Iserhardt
@since 29/08/13
@version 1.0
/*/
Function PLVLDCHSH()
	Local cContHash := ""
	Local nI := 1

	If GetNewPar("MV_PLTHRE",.F.) .AND.  IsInCallStack("PLSXMLBATCH") // Roda processo de submissao em theard.
		for nI := 1 To Len(aDadosThd)
			If !(aDadosThd[nI][1] == "HASH" .OR. Left(aDadosThd[nI][3], 7) ==  "nSeqGui")
				cContHash += aDadosThd[nI][3]
			EndIf
		Next
	Else
		//insere todo o conteudo do xml na variavel cContHash, exceto o conteudo do proprio hash
		//aqui nao pode ser utilizado o aDadosUnic porque deve utilizar TODOS os valores de TODAS as tags do XML
		For nI := 1 To Len(aDados)
			//Alem do elemento do HASH, devemos desconsiderar os elementos que vem com o valor nSeqGui, que utilizado
			//para poder contar quantas guias estao dentro do XML. Os demais compoe a String que iremos usar para gerar o Hash.
			If !(aDados[nI][1] == "HASH" .OR. Left(aDados[nI][3], 7) ==  "nSeqGui")
				cContHash += aDados[nI][3]
			EndIf
		Next

	Endif
	//calcula o hash dos dados do xml e retorna o mesmo
Return Upper( MD5(cContHash,2) )

/*/{Protheus.doc} PLVLDCHSH2
Valida o Hash do arquivo XML se esta correto
@type function
@author TOTVS
@since 13/08/15
@version 1.0
/*/
Function PLVLDCHSH2(cHasValid)

	Local 	cContHash	:= ""
	Local   lRet		:=.T.
	Local 	i			:=1
	Default cHasValid	:= ""

	//insere todo o conteudo do xml na variavel cContHash, exceto o conteudo do proprio hash
	//aqui nao pode ser utilizado o aDadosUnic porque deve utilizar TODOS os valores de TODAS as tags do XML

	If  GetNewPar("MV_PLTHRE",.F.) .AND.  IsInCallStack("PLSXMLBATCH") // Roda processo de submissao em theard.

		cContHash:=""
		For i:=1 to Len(aDadosThd)
			If !("HASH" $ aDadosThd[i,1]) .and. !("nSeqGui" $ aDadosThd[i,3] )
				cContHash += aDadosThd[i,3]
			Endif
		Next

		If GetGlbValue("X15CONT") == "0"
			PutGlbValue("X15CONT","1")
			//calcula o hash dos dados do xml e retorna o mesmo
			lRet:= Upper(cHasValid) == Upper( MD5(cContHash,2) )
		Else
			lRet:= .T.
		Endif

	Else
		cContHash:=""
		For i:=1 to Len(aDados)
			If !("HASH" $ aDados[i,1]) .and. !("nSeqGui" $ aDados[i,3] )
				cContHash += aDados[i,3]
			Endif
		Next

		//calcula o hash dos dados do xml e retorna o mesmo
		lRet:= Upper(cHasValid) == Upper( MD5(cContHash,2) )
	Endif


Return lRet

/*/{Protheus.doc} PXMLTOARR
Converte um xml em um array utilizando metodo de recursividade
@type Function
@author PLS
@since 23/07/13
/*/
function PXMLTOARR(aXML, cPath, cTag, aDados)
	Local nI			:= 0
	Local nC			:= 0
	Local cNextPath
	Local cPref1		:= "_ANS_"
	Local cPref2		:= "_ANSTISS_"
	Local cPref3		:= "ANS:"
	Local cPref4		:= "ANSTISS:"
	Local cPref5		:= "_"
	Local cTpGuias		:= ""
	Local nForDin		:= 0
	Local aBkpXml		:= {}
	Local cVarAux		:= ""
	DEFAULT aDados	:= {}
	DEFAULT cPath		:= ""
	DEFAULT cTag		:= ""

	If Type("nSeqGui") == 'U'
		Private nSeqGui := 0
	EndIf

	//NAO RETIRAR ISSO DAQUI EM NENHUMA HIPOTESE - INICIO (estava ocorrendo sobrecarga de memoria com a recursividade usando o vetor)
	aBkpXml := aClone(aXML)
	aSize(aXml,0)
	aXml := Nil
	aXml := aClone(aBkpXml)
	aBkpXml := nil
	//NAO RETIRAR ISSO DAQUI EM NENHUMA HIPOTESE - FIM

	// Tipos de Guias Prestador para Operadora TISS
	cTpGuias :=	P973TpGui()

	If (Empty(AllTrim(cTag)))
		cNextPath := cPath
	ElseIf (Empty(AllTrim(cPath)))
		cNextPath := cTag
	Else
		cNextPath := cPath + "\" + cTag
	EndIF

	If (ValType(aXML) == "A")
		// Aqui eu separo as guias pois pode haver mais de uma de acordo com o seu tipo, esse controle agrupara cada guia para ser importada separada no PLSA973
		If Len(aXML) > 3 .AND. Len(aXML[2]) > 1 .AND. Valtype(aXml[2,2]) == "C"
			cVarAux := A973LTran(Upper(aXML[2,2]),Upper(aXML[2,1]),{cPref1,cPref2,cPref3,cPref4,cPref5},cTpGuias)
			If cVarAux $ cTpGuias
				//TRATAMENTO PARA QUE NÃO PASE POR ESSE PONTO QUANDO HOUVER NO XML A TAG ansTISSguias, pois se passar por esse TAG O ALTERA A QTD DE GUIAS, FICANDO ERRADO
				If aXml[2,2] <> "ansTISS:guias"
					nSeqGui++
					aAdd(aDados, {cVarAux, "\"+cPath+"\", "nSeqGui="+AllTrim(str(nSeqGui))})
				EndIf
			EndIf
		EndIf
		nForDin := IIf(Len(aXML) > 3, 4, 1)
		For nI := nForDin To Len(aXML)
			If (ValType(aXML[nI]) == "A")
				If (ValType(aXML[nI, 1]) == "C")  // aXML[nI, 1] = Nome da TAG
					If (ValType(aXML[nI, 2]) == "O")
						//ordena o array na terceira posição que é onde fica a ondem dos elementos após transformar o objeto em um array
						cVarAux := A973LTran(Upper(aXML[nI,1]),"",{cPref1,cPref2,cPref5},cTpGuias)
						aDados := PXMLTOARR(ASORT(classDataArr(aXML[nI, 2]),,,{|x,y| x[3]<y[3]}), cNextPath, cVarAux, aDados)
					ElseIf (ValType(aXML[nI, 2]) == "A")
						//cai aqui quando chega na parte dos dados da guia própriamente dita(prestadorParaOperadora)
						For nC := 1 To Len(aXML[nI, 2])
							If (ValType(aXML[nI, 2, nC]) == "O")
								//ordena o array na terceira posição que é onde fica a ondem dos elementos após transformar o objeto em um array
								cVarAux := A973LTran(Upper(aXML[nI,1]),"",{cPref1,cPref2,cPref5},cTpGuias)
								aDados := PXMLTOARR(ASORT(classDataArr(aXML[nI, 2, nC]),,,{|x,y| x[3]<y[3]}), cNextPath, cVarAux, aDados)
							EndIf
						Next nC
						//o valor sempre estara na terceira posição do array que tem a primeira posição com valor TEXT
					ElseIf (aXML[3, 1] == "TEXT" .AND. aXML[1, 1] == "TYPE" .AND. aXML[1, 2] == "NOD")
						//adiciona a tag
						//no path é inserido uma contra barra antes e depois do path
						aAdd(aDados, {cTag, "\"+cPath+"\", aXML[3, 2]})
						Return aDados
					EndIf
				EndIf
			EndIf
		Next nI
	EndIf
Return aDados

/*/{Protheus.doc} PGETTISVER
Retorna a versao da TISS utilizada pela operadora
@type function
@author Bruno Iserhardt
@since 15/10/13
@version 1.0
/*/
Function PGETTISVER()
	Local cTissVer := GetNewPar("MV_TISSVER","2.02.03")

	BA0->(DbSelectArea("BA0"))
	BA0->(DbSetOrder(1))
	If (BA0->(MsSeek(xFilial("BA0")+PLSINTPAD())))
		cTissVer := BA0->BA0_TISVER
	EndIf

Return cTissVer

/*/{Protheus.doc} PLSTAGSEXP
Retorna todas as tags informadas em uma expressao
@type function
@author Bruno Iserhardt
@since 16/10/13
@version 1.0
/*/
Function PLSTAGSEXP(cExp)
	Local aTags := {}
	Local nI := 1
	//loop para varrer todas as tags da expressao
	For nI := 1 To Len(StrTokArr ( cExpressao, "[%" ))-1
		//seleciona os indices do inicio e fim da tag
		nBegin := At("[%",cExpressao)
		nEnd := At("%]",cExpressao)
		//seleciona na expressao o caminho e a tag
		cPathTag := SubStr(cExpressao, nBegin+2, nEnd-nBegin-2)
		//adiciona a tag no array de retorno
		aAdd(aTags, cPathTag)
		//remove a tag da expressao
		cExpressao := StrTran(cExpressao, "[%" + cPathTag + "%]", "")
	Next
Return aTags

/*/{Protheus.doc} PLCOUNTTAG
Recebe um array de tags e retorna a maior quantidade de vezes que uma das TAGS se encontra no XML.
@type function
@author Bruno Iserhardt
@since 16/10/13
@version 1.0
/*/
Function PLCOUNTTAG(aTagsExp, aDados)
	Local nI	:= 1
	Local nI2	:= 1
	Local nCount := 0
	Local nCountAux := 0
	//percorre as tags enviadas
	For nI := 1 To Len(aTagsExp)
		//calcula quantas vezes a tag existe no XML
		For nI2 := 1 To Len(aDados)
			If (aTagsExp[nI] $ aDados[nI2, 2]+aDados[nI2, 1])
			nCountAux++
		EndIf
	Next
	If (nCountAux > nCount)
		nCount := nCountAux
	EndIf
	Next
Return nCount

/*/{Protheus.doc} PlChkProc
Tratamento para que os procedimentos que nao precisam de autorizacao
nao apresentem criticas de senhas
@type function
@author TOTVS
@since 11/13/13
@version 1.0
/*/
Static Function PlChkProc(cChave)
	Local lRet		:= .F.
	Local aMatMCpBk	:= {} //aClone(aMatMCp) // Comentado pois ocorria erro na TISS 3.0 que nao possui o array aMatMCp
	Local aMatProBk := {} //PLSPCONGR("CODIGO",cGuia+"\PROCEDIMENTOSREALIZADOS",aMatMCpBk,,.F.,,.T.) // Comentado pois ocorria erro na TISS 3.0 que nao possui o array aMatMCp
	Local cCodProBk := {} // aMatProBk[1] // Comentado pois ocorria erro na TISS 3.0 que nao possui o array aMatMCp
	Local cCodPadBk := {} //PLSPCONGR("TIPOTABELA",cGuia+"\PROCEDIMENTOSREALIZADOS",aMatMCpBk,,.T.,.F.) // Comentado pois ocorria erro na TISS 3.0 que nao possui o array aMatMCp

	If Type("aMatMCp") == "A"

		aMatMCpBk := aClone(aMatMCp)
		aMatProBk := PLSPCONGR("CODIGO",cGuia+"\PROCEDIMENTOSREALIZADOS",aMatMCpBk,,.F.,,.T.)
		cCodProBk := aMatProBk[1]
		cCodPadBk := PLSPCONGR("TIPOTABELA",cGuia+"\PROCEDIMENTOSREALIZADOS",aMatMCpBk,,.T.,.F.)

	Else
		If Type("cCodPro") == "C"
			cCodProBk := cCodPro
			cCodPadBk := cCodPad
		EndIf
	EndIf

	BR8->( DbSetOrder(1) )
	BR8->(DbGoTop())

	If BR8->(DbSeek(xFilial("BR8") + cCodPadBk + cCodProBk ) )

		If BR8->BR8_AUTORI == "0"
			lRet := .T. // Dispensa autorizacao mesmo que a senha nao esteja presente.
		Else
			lRet := .F. // Autorizacao e necessaria.
		Endif

	Endif

Return lRet

/*/{Protheus.doc} PRDARight
Tratamento para atribuir o valor do CodRda mesmo na funcao de validacao dinamica vir CPF ou CNPJ colocar o CODRDA
@type function
@author rogerio.tabosa
@since 11/13/13
@version 1.0
/*/
Function PRDARight(cCodRda, cOpeRda)
	Local aArea 	:= GetArea()
	Local cNewRDA	:= cCodRda
	Local cRdaAnt	:= ""
	DEFAULT cOpeRda := ""

	If Empty(cOpeRda)
		cOpeRda := PlsIntPad()
	EndIf

	If Len(alltrim(cNewRDA)) > TamSX3("BAU_CODIGO")[1]//se eh maior significa que o prestador mandou o cnpj na TAG  de codigo
		nIdx 	 := 4
	Else
		cNewRDA := padr(cNewRDA,6)
		nIdx 	 := 1
	Endif

	If !Empty(cNewRDA)
		BAW->(DbSetOrder(3))
		cRdaAnt := cNewRDA+Space( TamSX3("BAW_CODANT")[1]-Len(cNewRDA) )
		If BAW->(MsSeek(xFilial("BAW")+cOpeRda+cRdaAnt))
			cNewRDA := BAW->BAW_CODIGO
			nIdx 	:= 1
		Endif
	Endif


	BAU->( DbSetOrder( nIdx ) ) //BAU_FILIAL + BAU_CPFCGC ou  BAU_CODIGO ou BAU_CODBB0
	if !BAU->( MsSeek( xFilial("BAU")+cNewRDA ) )
		cNewRDA := cCodRda
	else
		cNewRDA	  := BAU->BAU_CODIGO
		nIdx 	  := 1
	endif

	RestArea(aArea)
Return(cNewRDA)

/*/{Protheus.doc} PAjustUnic
Ajusta o array unico para TAG iguais com caminhos diferentes
@type function
@author rogerio.tabosa
@since 11/13/13
@version 1.0
/*/
Static Function PAjustUnic(aDUnic,cPthTag, cTag, cValue)
	Local nI 	:= 0
	Local nPos := 0
	Local cTagExc	:= "\CBOS\CBO\"
	Local lTagExc	:= StrTran(cTag,"\","") $ cTagExc

	cTag := IIf(SubStr(Alltrim(cTag),1,1) == "\",Alltrim(cTag),"\" + Alltrim(cTag))

	nPos := aScan(aDUnic,{|x| Upper(StrTRan(cTag,"\\","\")) $ Upper(StrTran(x[2], "\\", "\") + x[1])})

	If nPos > 0
		For nI := nPos+1 To Len(aDUnic)
			If (StrTran(Iif(lTagExc,cPthTag,"") + Upper(cTag),"\\","\"))  $ UPPER(StrTran(aDUnic[nI,2], "\\", "\") + aDUnic[nI,1])
			aDUnic[nPos, 3] := cValue
		EndIf
		Next
	EndIf

Return

/*/{Protheus.doc} PlsBusTerDup
Busca tabelas com DE_PARA para a mesma terminologia
@type function
@author rogerio.tabosa
@since 11/13/13
@version 1.0
/*/
Function PlsBusTerDup(cTabDup)
	Local aArea 	:= getArea()
	Local aTabDup 	:= {}
	Local cSql		:= ""

	cSql += " Select X.BTU_CDTERM CDTERM, Y.BTU_VLRBUS VLRBUS From " + retSqlName("BTU") + " Y "
	cSql += " Inner Join ( "
	cSql += " Select * from ("
	cSql += " SELECT BTU_CDTERM, COUNT(1) QTD FROM " + RetSqlName("BTU")
	cSql += "  WHERE BTU_FILIAL = '" + _BTUFIlial + "' "
	cSql += "    AND BTU_CODTAB = '" + cTabDup + "' "
	cSql += "    AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BTU_CDTERM ) L "
	cSql += " Where L.QTD >= 1 "
	cSql += " ) X "
	cSql += " On "
	cSql += " Y.BTU_FILIAL = '" + _BTUFIlial + "' AND "
	cSql += " Y.BTU_CODTAB = '" + cTabDup + "' AND "
	cSql += " Y.BTU_ALIAS = 'BR4' AND "
	cSql += " Y.BTU_CDTERM = X.BTU_CDTERM "
	cSql += " Where "
	cSql += " Y.D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"trbBTU",.f.,.t.)

	If ! trbBTU->( eof() )

		While ! trbBTU->(eof())

			AaDd(aTabDup, { trbBTU->CDTERM, Alltrim(trbBTU->VLRBUS) }	)

			trbBTU->( dbSkip() )
		endDo

	endIf

	trbBTU->(DbCloseArea())
	RestArea(aArea)

Return aTabDup

/*/{Protheus.doc} PChkTabDup
Criado para caso de mais de uma tabela vinculada Termi Ex.22
Caso nao encontre o procedimento eu tento com outra tabela
@type function
@author rogerio.tabosa
@since 11/13/13
@version 1.0
/*/
Function PChkTabDup(cCodPad,cCodPro,cPadOri)
	Local cTerm 	:= ""
	Local nPosF	:= 0
	Local nI		:= 0
	Local lFound	:= .F.
	Local cOthPad	:= ""
	BR8->(DbSetOrder(1))
	If Type("aTabDup") <> 'U'
		If (nPosF := aScan( aTabDup,{|x|Upper(x[2]) == cCodPad} ) ) > 0	// quer dizer que possuo mais de uma tabela vinculada a essa terminlogia
			cTerm := aTabDup[nPosF,1]
			For nI := 1 To Len(aTabDup)
				BR8->(DbGoTop())
				cOthPad := aTabDup[nI,2]
				If (lFound := (BR8->(MSSEEK(XFILIAL('BR8')+cOthPad+CCODPRO)) .AND. BR8->BR8_BENUTL <> '0' .and. Alltrim(cPadOri) == Alltrim(aTabDup[nI,1]) )) // Se achou sai fora
					cCodPad := cOthPad // ATUALIZO SE FOR PASSADO POR PARAMETRO
					Exit
				EndIf
			Next nI
		EndIf
	EndIf
Return(lFound)

/*/{Protheus.doc} P973VLD91
Utilizado pela critica 091
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function P973VLD91()
	Local lRet				:= .T.
	Local cValor_senha	:= ""
	Local cValor_guia	:= ""
	Local nPos				:= aScan(aDados, {|x| UPPER(x[3]) == UPPER('nSeqGui='+Alltrim(Str(nSeqGui)))})
	Local aAreaBEA 		:= BEA->(GetArea())
	Local nFor				:= nPos
	Local lFoundAut		:=.F.
	Local lV1 := .F.
	Local lV2 := .F.

	For nFor:=nPos To Len(aDados)
		If !lv1 .AND. Upper(aDados[nfor,1])=="SENHA"
			cValor_senha := aDados[nfor,3]
			lV1 := .T.
		Endif

		If !lV2 .AND. Upper(aDados[nfor,1]) =='NUMEROGUIAOPERADORA'
			cValor_guia := aDados[nfor,3]
			lV2 := .T.
		Endif

		if lV1 .AND. lV2
			exit
		endif

		If 'nSeqGui=' $ aDados[nfor,3]
			If Val(Substr(aDados[nFor,3],(At("=",aDados[nFor,3])+1),10)) > nSeqGui
				Exit
			Endif
		Endif

	Next nI

	BEA->( DbSetOrder(14) )

	If !Empty(cValor_senha)
		lFoundAut:= BEA->( MsSeek(xFilial("BEA")+alltrim(cValor_senha)) )
	Endif

	if !lFoundAut .AND. !(empty(cValor_guia))
		BEA->(dbsetOrder(1))
		lFoundAut:= BEA->( MsSeek(xFilial("BEA")+alltrim(cValor_guia)) )
	endif

	If lFoundAut
		If cTipo == '2'
			lRet:= 	!((Alltrim(BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)) <> Alltrim(cMatric) .and. Alltrim(BEA->BEA_MATANT) <> Alltrim(cMatric))  .AND. (!Empty(cValor_senha) .OR. !empty(cValor_guia)))
		Endif
		If cTipo == '3'
			lRet:= 	!((AllTrim(BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)) <> AllTrim(CMatric) .and. AllTrim(BE4->BE4_MATANT) <> AllTrim(CMatric))  .AND. (!Empty(cValor_senha) .OR. !empty(cValor_guia)))
		Endif
	EndIf

	RestArea(aAreaBEA)

Return lRet
/*/{Protheus.doc} PlBCodSi
Retorna o codigo da sigla do conselho do medico de acordo com terminologia enviada
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PlBCodSi(xCodSigla)
	Local cRet := ""

	If xCodSigla $ 		'1/01'
		cRet := 'CRAS'
	Elseif xCodSigla $ 	'2/02'
		cRet := 'COREN'
	Elseif xCodSigla $ 	'3/03'
		cRet := 'CRF'
	ElseIf xCodSigla $ 	'4/04'
		cRet := 'CRFA'
	Elseif xCodSigla $ 	'5/05'
		cRet := 'CREFITO'
	ElseIf xCodSigla $ 	'6/06'
		cRet := 'CRM'
	ElseIf xCodSigla $ 	'7/07'
		cRet := 'CRN'
	ElseIf xCodSigla $ 	'8/08'
		cRet := 'CRO'
	ElseiF xCodSigla $ 	'9/09'
		cRet := 'CRP'
	Elseif xCodSigla $ 	'10'
		cRet := 'OUT'
	Endif

Return cRet

/*/{Protheus.doc} PXMLTISWS
Valida se o Lote Guia esta na versao TISS Online
@type function
@author TOTVS
@since 04/05/2015
@version 1.0
/*/
Function PXMLTISWS(aDados)
	Local lLoteTissOnline := .F.
	Local nI 		:= 1
	Default aDados := {}

	For nI := 1 To Len(aDados)
		//se palavra na TAG do ARRAY nao encontrou a tag no array
		If (At("LOTEGUIASWS", aDados[nI, 2]) > 0)
			//modifica o conteudo alterando as TAGS que possuam LOTEGUIASWS para MENSAGEMTISS
			aDados[nI, 2] := strTran( Upper(aDados[nI, 2]), "LOTEGUIASWS", "MENSAGEMTISS")

			lLoteTissOnline := .T.
		EndIf

		//se palavra na TAG do ARRAY nao encontrou a tag no array
		If (At("\MENSAGEMTISS\LOTEGUIAS\", aDados[nI, 2]) > 0)
			//modifica o conteudo alterando as TAGS que possuam LOTEGUIASWS para MENSAGEMTISS
			aDados[nI, 2] := strTran( Upper(aDados[nI, 2]), "\MENSAGEMTISS\LOTEGUIAS\", "\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\")
		EndIf

		//Na tiss ONLINE nao EXISTE epilogo
		If ( AllTrim(Upper(aDados[nI, 1])) == "HASH")
			//modifica o conteudo alterando as TAGS que possuam LOTEGUIASWS para MENSAGEMTISS
			aDados[nI, 2] := "\MENSAGEMTISS\EPILOGO\"
		EndIf
	Next

Return lLoteTissOnline

/*/{Protheus.doc} PXMLGLSWS
Adapta o xml do webservice para o TISS Online
@author Eduardo Bento
@since 23/07/2018
/*/
Function PXMLGLSWS(aDados)
	Local lRecursoGlosa := .F.
	Local nI 		:= 1
	Local cCodPeg	:= ""
	Default aDados 	:= {}

	For nI := 1 To Len(aDados)
		If (At("LOTERECURSOGLOSAWS", aDados[nI, 2]) > 0)
			aDados[nI, 2] := strTran( Upper(aDados[nI, 2]), "LOTERECURSOGLOSAWS", "MENSAGEMTISS")
			lRecursoGlosa := .T.
		EndIf

		If (At("\MENSAGEMTISS\LOTERECURSO\", aDados[nI, 2]) > 0)
			aDados[nI, 2] := strTran( Upper(aDados[nI, 2]), "\MENSAGEMTISS\LOTERECURSO\", "\MENSAGEMTISS\PRESTADORPARAOPERADORA\RECURSOGLOSA\")
		EndIf

		If ( AllTrim(Upper(aDados[nI, 1])) == "HASH")
			aDados[nI, 2] := "\MENSAGEMTISS\EPILOGO\"
		EndIf

		If ( AllTrim(Upper(aDados[nI, 1])) == "NUMEROPROTOCOLO")
			cCodPeg := aDados[nI, 3]
		Endif
	Next

Return cCodPeg

/*/{Protheus.doc} PlsVerVia
Valida a via de acesso de procedimentos clinicos
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PlsVerVia(cViaAcesso,CCODPAD,CCODPRO)
	Local lRet		:= .T.
	Local aAreaBD5 	:= BD5->(GetArea())
	Local aAreaBD6 	:= BD5->(GetArea())
	Local aAreaBE4	:= BD5->(GetArea())

	If BR8->BR8_TIPEVE $ "2#3" // somente procedimento clinicos ou ambos
		If cTipGui $ "01#02#04"
			BD5->(DbSetOrder(7))
			BD6->(DbSetOrder(13))

			If BD5->(DbSeek(xFilial("BD5")+cNumSen))
				If BD6->(DbSeek(xFilial("BD6")+	BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO+BD5_ANOPAG+BD5_MESPAG+" "+cCodPad+cCodPro)))
					If BD6->BD6_VIA <>cViaAcesso
						lRet		:= .F.
					Endif
				Endif
			Endif

		Else
			BE4->(DbSetOrder(7))
			BD6->(DbSetOrder(13))
			If BE4->(DbSeek(xFilial("BE4")+cNumSen))
				If BD6->(DbSeek(xFilial("BD6")+	BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO+BE4_ANOPAG+BE4_MESPAG+" "+cCodPad+cCodPro)))
					If BD6->BD6_VIA <>cViaAcesso
						lRet		:= .F.
					Endif
				Endif
			Endif

		Endif
	Endif
	RestArea(aAreaBD5)
	RestArea(aAreaBD6)
	RestArea(aAreaBE4)
Return lRet

/*/{Protheus.doc} PLVALUNIT
Utilizada pela critica X52
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PLVALUNIT(cValUnit)
	Local lRet		:= .T.

	If val(cValUnit) < 0
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} PLCLASERI
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PLCLASERI(cTipo)
	LOCAL aRet		:= {}

	dbSelectArea("BJE")
	dbSetOrder(4)

	If dbSeek(xFilial("BJE") + cTipo)
		While BJE->(BJE_FILIAL + BJE_TIPO) == xFilial("BJE") + cTipo
			AADD(aRet, BJE->BJE_CODIGO)
			BJE->(dbSkip())
		EndDo
	EndIf

Return aRet

/*/{Protheus.doc} PLVALPRSE
Utilizada pela critica X52
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PLVALPRSE(cCodPro,cCodPrest,cMatric, dDatPro, aClasProc, cTipo, cCodPad, lReemb)

	Local lRet		:= .T.
	Local cDadcomp	:= ALLTRIM(cCodPro) + "," + cCodPrest + "," + cMatric + "," + DTOS(dDatPro)

	//Quando o codigo do procedimento vem do portal, nao retorna o tamanho correto do campo, retornando false no seek.
	cCodPro += SPACE(16 - LEN(cCodPro))

	Default lReemb  := .F.

	//Se nao existir classes configuradas com o tipo tratamento seriado,
	//Todas as validações sao ignoradas
	If !LEN(aClasProc) == 0

		BR8->(dbSetOrder(3))
		If BR8->(dbSeek(xFilial("BR8") + cCodPro))

			//Verifica se a classe vinculada ao procedimento de procedimento seriado.
			If AScan(aClasProc,{|x|x == BR8->BR8_CLASSE} ) > 0

				//verifica se o procedimento
				If AScan(_aDadProc,{|x|x == cDadComp} ) > 0
					lRet := .F.
				Else
					If cTipo $ "1,2"

						BE2->(dbSetOrder(14))
						If BE2->(dbSeek(xFilial("BE2") + cTipo + cCodPad + cCodPro + cMatric + DTOS(dDatPro) + cCodPrest))

							While BE2->(BE2_FILIAL+BE2_TIPO+BE2_CODPAD+BE2_CODPRO+BE2_OPERDA+BE2_CODEMP+BE2_MATRIC+BE2_TIPREG+BE2_DIGITO+DTOS(BE2_DATPRO)+BE2_CODRDA) == xFilial("BJE") + cTipo + cCodPad + cCodPro + cMatric + DTOS(dDatPro) + cCodPrest

								If BE2->BE2_LIBERA <> "1"
									lRet := .F.
									Exit
								Endif

								BE2->(dbSkip())
							EndDo

						Else
							AADD(_aDadProc, cDadComp)
						EndIf

					ElseIf cTipo == "3"

						BE4->(dbSetOrder(18))
						If BE4->(dbSeek(xFilial("BE4") + cMatric + cCodPrest + DTOS(dDatPro)))

							BEJ->(dbSetOrder(2))
							If BEJ->(dbSeek(xFilial("BEJ") + BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT) + cCodPad + cCodPro))

								lRet := .F.
							Else
								AADD(_aDadProc, cDadComp)
							EndIf
						Else
							AADD(_aDadProc, cDadComp)
						EndIf

					ElseIf cTipo == "4" .AND. !lReemb

						AADD(_aDadProc, cDadComp)						

					ElseIf lReemb

						If SIX->(MsSeek("B454"))

							B45->(dbSetOrder(4))
							If B45->(MsSeek(xFilial("B45") + cMatric + cCodPad + cCodPro + DTOS(dDatPro) + M->B45_CODREF))

								lRet := .F.
							Else

								AADD(_aDadProc, cDadComp)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PLIMPAVAR
Limpa a variavel static usada na funcao PLVALPRSE
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PLIMPAVAR()
	_aDadProc := {}
Return

/*/{Protheus.doc} VLDQTDSER
Se a quantidade executada de um procedimento seriado for maior que 1, a critica 53 sera executada.
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function VLDQTDSER(cCodPro, nQtdPro,aClasProc, nQtdPerm)

	local lRet := .T.
	Default nQtdPerm := 99

	//Se nao existir classes configuradas com o tipo tratamento seriado,
	//Todas as validações sao ignoradas
	If !LEN(aClasProc) == 0

		BR8->(dbSetOrder(3))
		If BR8->(dbSeek(xFilial("BR8") + cCodPro))

			// verifica se o procedimento que esta sendo validado esta vinculado
			// com uma das classes configuradas com o tipo tratamento seriado
			If AScan(aClasProc,{|x|x == BR8->BR8_CLASSE} ) > 0
				If 	nQtdPro > nQtdPerm
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} VLDAPRXML
Verifica se o valor apresentado igual o valor contratado
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function VLDAPRXML(dData,cOpeMov,cCodRda,cCodLoc,cCdTbPd,cCodPro,nQtd,cHora,aDadUsr,cTipGui,cValApr,cHorFin)

	local lRet 		:= .T.
	Local aRetVldXml:= {}
	local cMes 		:= StrZero ( MONTH( dData ), 2, 0)
	Local cAno 		:= STR(YEAR(dData))
	local cHorIni	:= substr(cHora,1,2) + substr(cHora,4,2)
	local cHorFinal := ""
	local nValApr	:= VAL(cValApr)
	local aDadUsu   := If(EMPTY(aDadUsr),PLSGETUSR(),aDadUsr)
	local aBckRet	:= aclone(aRet)
	local nPac 		:= 0
	local aPacPro 	:= {}
	local aPacote 	:= {0, 0, {}, ""}
	local nVia 		:= 0
	local cViaAces  := ""
	local cVincVia 	:= ""
	local nViaAces  := 0
	local lCirurgico := .t.

	default cHorFin := ""

	cHorFinal := substr(cHorFin,1,2) + substr(cHorFin,4,2)

	//Esta critica deve somente funcionar na submissão do arquivo, na mudança de fase existe a 020.
	if (alltrim(BCT->BCT_CODGLO) == "54" .and. BCT->BCT_ENVCOX == "1") .or. BAU->BAU_TPCALC $ "1;3"
		return .t.
	endif

	// inserido bloco para valorar pacote, pois a composição era inserida antes da chamada do PLSCALCEVE
	// pesquisa as tabelas que possuem valores para pacote (BLY, B42, BLE)
	aPacPro := PlRetPac(cOpeMov,cCodRda,cCdTbPd,cCodPro,,dData)

	if len(aPacPro) > 1
		// como não temos BD6 e B43 neste momento, realizamos os processos abaixo:

		// como a via de acesso altera o valor final, é necessário verificar se existe no xml
		nVia 	 := aScan(aDadosUnic, {|x| x[1] == "VIAACESSO"})
		cViaAces := aDadosUnic[nVia,3]
		cVincVia := allTrim(PLSVARVINC('61', 'BGR', cViaAces))
		if !empty(cVincVia)
			cViaAces := cVincVia
		endif
		// caso encontrado, pegamos a porcentagem para aplicar no valor final
		if !empty(cViaAces)
			If BGR->(MsSeek(xFilial("BGR") + cOpeMov + cViaAces))
				nViaAces := BGR->BGR_PERC
			endif
		endif

		// repetimos bloco semelhante ao realizado no PLSA720EVE que chama o PLSCALCEVE
		// e preenche o aPacote
		for nPac := 1 to len(aPacPro)
			aadd(aPacote[3],{aPacPro[nPac][1],aPacPro[nPac][2],aPacPro[nPac][5],aPacPro[nPac][4],aPacPro[nPac][6],aPacPro[nPac][3]})

			aPacote[1] += aPacPro[nPac][5]
			aPacote[2] += aPacPro[nPac][4]
			aPacote[4] := aPacPro[nPac][10]
		next

		//calcula o valor contratado do pacote
		aRetVldXml := aclone( PLSCALCEVE( cCdTbPd, 	/*01*/ cCodPro,		  /*02*/ cMes, 	    /*03*/ cAno,	    /*04*/ ;
			cOpeMov, 	/*05*/ cCodRDA, 	  /*06*/ "",		/*07*/ "", 		    /*08*/ ;
			cCodLoc,  /*09*/ nQtd, 		  /*10*/ dData, 	/*11*/ IIF(len(aDadUsu)>=48,aDadUsu[48],""), 	/*12*/;
			"",  		/*13*/ "", 			  /*14*/ nValApr,   /*15*/ aDadUsr, 	/*16*/ ;
			"",		/*17*/ nil, 		  /*18*/ "", 		/*19*/ "",  	    /*20*/ ;
			nil, 		/*21*/ nil, 		  /*22*/ cHorIni,  /*23*/ {},		    /*24*/ ;
			.F., 		/*25*/ "", 			  /*26*/ 0,		    /*27*/ {},			/*28*/ ;
			.F.,		/*29*/ dData,		  /*30*/ cHorario,  /*31*/ {}, 		    /*32*/ ;
			cTipGui, 	/*33*/,,,,lCirurgico, /*38*/ nViaAces,  /*39*/ ,,,,aPacote  /*44*/;
			,,,,,,,,,,,,,,,,,cHorFinal /*61*/))
	else
		//Calcula o valor contratado do evento
		aRetVldXml := aclone(	PLSCALCEVE(	cCdTbPd,cCodPro,cMes,cAno,cOpeMov,cCodRDA,"","",cCodLoc,nQtd,dData,IIF(len(aDadUsu)>=48,aDadUsu[48],""),;
			"","",nValApr,aDadUsr,"",nil,"","",nil,nil,cHorIni,{},;
			.F.,"",0,{},.F.,dData,cHorario,{},cTipGui,,,,,,,,,,,,,,,,,,,,,,,,,,,,cHorFinal /*61*/) )
	endif
	//Recupera o valor do aRet
	aRet := aclone(aBckRet)

	If aRetVldXml[2]  == 0

		lRet := .F.

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Nao foi possivel calcular o valor contratado para o evento " + cCodPro + ", prestador codigo " + cCodRda , 0, 0, {})

	Else
		if val(cValApr) == 0 .or. val(cValApr) == aRetVldXml[2]
			lRet := .t.
		else
			lRet := .f.
		endif
	EndIf

Return lRet

/*/{Protheus.doc} PLVLRDACR
Função utilizada pela crítica "ZZZ - Valor Unitário X
Quantidade Solcicitada X Redução Acréscimo diferente do
valor Total
@type function
@author victor.silva
@since 02/09/2016
@version 1.0
@param cQtdPro, character
@param cValUnit, character
@param cValTot, character
@param cRedAcr, character
/*/
Function PLVLRDACR(cQtdPro, cValUnit, cValTot, cRedAcr)

	Local nQtdProd 		   := 0 //Val(PVLRTAGXML(aDados, "\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\QUANTIDADEEXECUTADA", nSeqGui))
	Local nValUnit 		   := 0 //Val(PVLRTAGXML(aDados, "\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\VALORUNITARIO", nSeqGui))
	Local nValTot  		   := 0 //Val(PVLRTAGXML(aDados, "\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\VALORTOTAL", nSeqGui))
	Local nValTotCalculado := 0
	Local nRedAcre 		   := 0 //Val(PVLRTAGXML(aDados, "\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\REDUCAOACRESCIMO", nSeqGui))

	if ValType(cQtdPro) <> "U"
		nQtdProd 		   := cQtdPro
	endif

	if ValType(cValUnit) <> "U"
		nValUnit 		   := val(cValUnit)
	endif

	if ValType(cValTot) <> "U"
		nValTot  		   := val(cValTot)
	endif

	if ValType(cRedAcr) <> "U"
		nRedAcre 		   := val(cRedAcr)
	endif

	nValTotCalculado := round((nQtdProd * nValUnit) * nRedAcre , 2)

Return nValTotCalculado

/*/{Protheus.doc} PL973RETLOC
Retorna o local de atendimento do prestador com base no CNES
@type function
@author TOTVS
@since 30/08/2016
@version 1.0
/*/
Function PL973RETLOC(cRda_,cCodOpe_,cCnes_)
	Local cLocal_ := ""
	Local cSql	:= ""

	iF !Empty(cCnes_)
		cSql += " SELECT BB8_CODLOC FROM "+RetSqlName("BB8")+" BB8 "
		cSql += "    WHERE BB8_FILIAL = '"+xFilial("BB8")+"' "
		cSql += "      AND BB8_CODIGO = '"+cRda_+"' "
		cSql += "      AND BB8_CODINT = '"+cCodOpe_+"' "
		cSql += "      AND BB8_CNES   = '"+cCnes_+"' "
		cSql += "      AND BB8_DATBLO   = ' '  "
		cSql += "      AND BB8.D_E_L_E_T_ = ' ' "

		PLSQuery(cSQL,"TrbBB8")
		//Retorna o primeiro, pois se tiver mais de um local com o mesmo CNES considera o primeiro que não estiver bloqueado
		iF !TrbBB8->(Eof())
			cLocal_ := TrbBB8->BB8_CODLOC
		EndIf
		TrbBB8->(DbCloseArea())
	EndIf

	If Empty(cLocal_)		//Se nao achar pelo CNES retorna o primeiro local (mantendo legado) // 2020 Alteração para pegar o primeiro local desbloqueado
		cSql := " "

		cSql += " SELECT BB8_CODLOC FROM "+RetSqlName("BB8")+" BB8 "
		cSql += "    WHERE BB8_FILIAL = '"+xFilial("BB8")+"' "
		cSql += "    AND BB8_CODIGO = '"+cRda_+"' "
		cSql += "    AND BB8_DATBLO   = ' '  "

		PLSQuery(cSQL,"TmpBB8")

		iF !TmpBB8->(Eof())
			cLocal_ := TmpBB8->BB8_CODLOC
		EndIf
		TmpBB8->(DbCloseArea())

	EndIf
Return cLocal_

/*/{Protheus.doc} PLS973VRDA
Retorna o codigo da RDA da Tag IDENTIFICACAOPRESTADOR, do cabecalho do XML
@author Oscar Zanin
@since 21/05/2016
@version P12
/*/
Function PLS973VRDA(cIdenPre)

	Local cCodRDA := AllTrim(Strtran(Strtran(cIdenPre, ".", ""), ",", ""))
	Local lCpf		:= Len(cCodRDA) == 11
	Local lCNPJ	:= Len(cCodRDA) == 14
	Local cRet		:= ""
	Local aArea	:= BAU->(GetArea())

	Default cIdenPre := ""

	If lCpf .OR. lCNPJ
		BAU->(DbSetOrder(4))
		If BAU->(MsSeek(xFilial("BAU") + cCodRDA))
			cRet := BAU->BAU_CODIGO
		EndIf
	else
		cRet := StrZero(Val(cIdenPre),6)
	EndIf

	RestArea(aArea)

Return cRet

/*/{Protheus.doc} PlCarCBOVar
Inicializa as variaveis dinamicas referente às TAGs de CBOS
e especialidade dos profissionais da guia

@type Function
@author victor.silva
@since 31/03/2016
@version 1.0
@param cTpDad, caracter, 	Indica variavel esta sendo carregada
							 		1 - CBOs do Solicitante
							 		2 - CBOs do Executante
							 		3 - Especialidade do Solicitante conforme De/Para
							 		4 - Especialidade do Executante conforme De/Para
							 		5 - Especialidade do Prestador contratado conforme regra definida
@param aDadXML, array, 	Recebe o endereco do ADADOSUNIC
@return cRet, caracter, String com o dado solicitado
/*/
Function PlCarCBOVar(cTpDad,aDadXML,cTagBus)
	Local cRet		:= ""
	Default cTagBus	:= "CBOS"

	/*
	Variaveis dinamicas utilizadas
	- CGUIA		: Tipo de Guia
	- _CCBOSOL	: CBOs do Solicitante
	- _CCBOEXE	: CBOs do Executante
	- _CESPEXE	: Especialidade do Executante
	- _LPLSCTES	: Indica o status do parametro MV_PLSCTES (Ativado/Desativado)
	- DDATPRO		: Data de execucao do procedimento
	- CRDAORI		: Codigo do Prestador
	- COPEMOV		: Codigo da operadora
	- CCODLOC		: Codigo do Local de Atendimento do Prestador
	*/

	//Case para definir o tipo de Guia (utiliza a variavel dinamica CGUIA)
	Do Case
		Case CGUIA $ "GUIACONSULTA,GUIACONSULTAREAPRESENTACAO"
			cTipGui	:= "01"
		Case CGUIA $ "GUIASP_SADT,GUIASP_SADTREAPRESENTACAO"
			cTipGui	:= "02"
		Case CGUIA $ "GUIARESUMOINTERNACAO,GUIARESUMOINTERNACAOREAPRESENTACAO"
			cTipGui	:= "05"
		Case CGUIA $ "GUIAHONORARIOINDIVIDUAL,GUIAHONORARIOINDIVIDUALREAPRESENTACAO,GUIAHONORARIOS"
			cTipGui	:= "06"
		Case "ODONTO" $ CGUIA
			cTipgui := "13"
	EndCase

	If cTagBus == "CBOS" .And. cTipGui	== "06"
		cTagBus := "CBO"
	EndIf

	//Case para retornar o dado conforme solicitado na variavel cTpDad
	Do Case
		//CBO do Solicitante
		Case cTpDad == "1"
			//A TAG referente ao CBO do solicitante so esta disponivel em guias SP_SADT
			If cTipGui <> "02"
				cRet:= ""
			Else
				cRet:= PVLRTAGXML(aDadXML,"\PROFISSIONALSOLICITANTE\" + cTagBus)
			EndIf

			//CBO do Executante
		Case cTpDad == "2"
			If cTipGui == "01"
				cRet:= PVLRTAGXML(aDadXML,"\PROFISSIONALEXECUTANTE\" + cTagBus)
			ElseIf cTipGui == "02"
				cRet:= PVLRTAGXML(aDadXML,"\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\EQUIPESADT\" + cTagBus)
			ElseIf cTipGui == "05"
				cRet:= PVLRTAGXML(aDadXML,"\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\IDENTEQUIPE\IDENTIFICACAOEQUIPE\" + cTagBus)
			ElseIf cTipGui == "06"
				cRet:= PVLRTAGXML(aDadXML,"\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\PROFISSIONAIS\" + cTagBus)
			ElseIf cTipgui == "13"
				cRet:= PVLRTAGXML(aDadXML,"\DADOSPROFISSIONAISRESPONSAVEIS\CBOSEXEC2") // + cTagBus)
			EndIf

			//Especialidade do Solicitante
		Case cTpDad == "3"
			cRet:= Iif(!Empty(_CCBOSOL),PLSVARVINC("24","BAQ",_CCBOSOL),"")

			//Especialidade do Executante
		Case cTpDad == "4"
			cRet:= Iif(!Empty(_CCBOEXE),PLSVARVINC("24","BAQ",_CCBOEXE),"")

			//Especialidade do Prestador Contratado
		Case cTpDad == "5"
			cRet := ""

	EndCase

Return cRet


/*/{Protheus.doc} PlTrCBOSUB
Funcao generica para validacao de criticas referentes ao CBOs enviados no arquivo.
As variaveis dinamicas ja alimentadas sao carregadas via parametro e validadas conforme
regras da critica sendo avaliada no momento.

*	Parametros correspondentes as variaveis privadas criada na tabela BVP.
SAO INFORMADOS APENAS PARA ATUALIZACAO DO VALOR DE ACORDO COM O ADADUNIC AO MUDAR A TAG

@type Function
@author victor.silva
@since 31/03/2016
@version 1.0
@param cCodGlo, caracter, Codigo da glosa vinculada a expressao da BVN que esta sendo analisada
@param cCboExe*, caracter, Codigo do CBO do Executante
@param cCboSol*, caracter, Codigo do CBO do Solicitante
@param cCodEsp*, caracter, Codigo da Especialidade do Prestador
@param cEspExe*, caracter, Codigo da Especialidade do Executante
@param cEspSol*, caracter, Codigo da Especialidade do Solicitante
@param aDadUser*, array, Array com os dados do usuario
@param aDadPres*, array, Array com os dados do usuario
@param cCdTpPd*, caracter, Codigo do procedimento em validacao
@param cCodPsa*, caracter, Codigo do procedimento em validacao
@return boolean, Retorno com a validacao da critica
/*/
Function PlTrCBOSUB(cCodGlo,cCboExe,cCboSol,cCodEsp,cEspExe,cEspSol,aDadUser,aDadPres,cCdTpPd,cCodPsa)
	Local lRet 			:= .F.	//Retorno
	Local cCboX			:= ""		//CBO do profissional (Solicitante ou Executante)
	Local cEspX			:= ""		//Especialidade do profissional (Solicitante ou Executante)
	Local cCodBB0			:= ""		//Codigo do profissional (Solicitante ou Executante)
	Local cTipPro 		:= ""		//Tipo do profissional (S-Solicitante, E-Executante)
	Local aRetPe			:= {}		//Retorno do ponto de entrada PLTISESP
	Local aRetExe			:= {}		//Retorno da funcao PLSTRATEXE
	Local xEsp				:= {}		//Caracter ou Array com a(s) Especialidade(s) encontrada(as) no Prestador com base na do Profissional
	Local lExecPE			:= .F.	//Indica que deve executar o ponto de entrada PLTISESP para alterar o retorno de validacoes do padrao (007,047,X25)
	Local nI				:= 0		//Controle de estrutura de repeticao
	Local cChvHash		:= ""		//Chave de busca do retorno da funcao PLSTratExe
	Local lGetHash		:= .F.	//Indica se encontrou o retorno da funcao PLSTratExe de acordo com a chave
	Local lGo				:= .T.	//Variavel de controle de erros
	Local cNomProf		:= ""		//Nome do profissional
	Local xRetExe		:= {}	//Array local com os retornos da funcao PLSTratExe
	Local cEspGen		:= getnewpar("MV_PESPPLA","'094','055'")	//Especialidade genérica

	Default aDadUser	:= {}
	Default aDadPres	:= {}
	Default cCodPsa		:= ""

	//Tipo de Prestador sendo validado
	If "SOLICITANTE" $ _cPathTag
		If cCodGlo $ "X55/X59/X60/X61"
			//Se for critica de bloqueio de especialidade ou procedimento, nao verifica para o solicitante
			Return .T.
		EndIf

		cCboX 	:= AllTrim(cCboSol)
		cEspX 	:= AllTrim(cEspSol)
		cTipPro	:= "S"
		cNomProf:= PlCarCBOVar("1",aDadosUnic,"NOMEPROFISSIONAL")
		cNomProf:= Iif(Empty(cNomProf),PlCarCBOVar("1",aDadosUnic,"NOMEPROF"),"")

	Else
		cCboX 	:= AllTrim(cCboExe)
		cEspX 	:= AllTrim(cEspExe)
		cTipPro	:= "E"
		cNomProf:= PlCarCBOVar("2",aDadosUnic,"NOMEPROFISSIONAL")
		cNomProf:= Iif(Empty(cNomProf),PlCarCBOVar("2",aDadosUnic,"NOMEPROF"),"")
	EndIf

	Do Case

		Case cCodglo == "X66"
			lRet := cCboExe <> "999999"
			CCOMPCRI := "O CBO do executante não pode ser informado 999999"

		Case cCodGlo == "X25" 						//Especialidade nao encontrada no sistema com base no CBOS informado no arquivo.

			//Ativa o ponto de entrada para manipular o retorno
			lExecPE := .T.

			/*
		Variaveis dinamicas utilizadas:
		- DDATPRO		: Data de execucao do procedimento
		- CRDAORI		: Codigo do Prestador
		- COPEMOV		: Codigo da operadora
		- CCRM			: CRM do Executante/Solicitante
		- CCODUF		: UF do Executante/Solicitante
		- CSIGLA		: Sigla do conselho do Executante/Solicitante
			*/

			//Localiza o profissional
			PLSIVPRO("",CSIGLA,CCRM,CCODUF,4,NIL,NIL,NIL,cCboX)

			If cTipPro == "S" //No sistema vai ter do contratado, não necessariamente do solicitante, não pdoemos validar solicitante nessa.
				lRet := .T.
			elseIf BB0->( found() )

				cCodBB0 := BB0->BB0_CODIGO
				//999999 - CBOs desconhecido ou nao informado pelo Profissional
				/*
			O codigo eh previsto na tabela de terminologia 24, caso o prestador envie este numero
			O sistema deve considerar a primeira especialidade valida
				*/

				If Alltrim(cCboX) == '999999'
					lRet := .T.
					BQ1->(dbSetOrder(1))
					If BQ1->(MsSeek(xFilial("BQ1")+cCodBB0))
						cEspX	:= BQ1->BQ1_CODESP
						lRet := .T.
					Endif
				Else
					//Buscando a especialidade no Profissional de Saude
					dbSelectArea("BQ1")
					BQ1->(dbSetOrder(1))//BQ1_FILIAL + BQ1_CODIGO + BQ1_CODESP
					If BQ1->(MsSeek(xFilial("BQ1")+cCodBB0+cEspX))
						lRet := .T.
					Else
						//Buscando a especialidade no Prestador
						dbSelectArea("BAX")
						BAX->(dbSetOrder(3))//BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO
						If  BAX->(MsSeek(xFilial("BAX") + COPEMOV + cEspX + CRDAORI))
							lRet := .T.
						else
							cSql := " SELECT BAX_CODESP, BAX_ESPPRI, R_E_C_N_O_ REC FROM "+RetSqlName("BAX")
							cSql += " WHERE BAX_CODINT = '"+COPEMOV+"' "
							cSql += " AND BAX_CODIGO   = '"+CRDAORI+"' "
							cSql += " AND BAX_CODESP IN ("+ cEspGen +") "
							cSql += " AND (BAX_DATBLO   = ' ')"
							cSql += " AND D_E_L_E_T_   = ' ' "

							PlsQuery(cSql,"BAXX25")
							lRet := BAXX25->(!(EoF()))
							BAXX25->(Dbclosearea())
						Endif
					Endif
				Endif
			Else
				//Buscando a especialidade na Rede de Atendimento
				dbSelectArea("BAX")
				BAX->(dbSetOrder(3))//BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO
				If  BAX->(MsSeek(xFilial("BAX") + COPEMOV + cEspX + CRDAORI))
					lRet := .T.
				else
					cSql := " SELECT BAX_CODESP, BAX_ESPPRI, R_E_C_N_O_ REC FROM "+RetSqlName("BAX")
					cSql += " WHERE BAX_CODINT = '"+COPEMOV+"' "
					cSql += " AND BAX_CODIGO   = '"+CRDAORI+"' "
					cSql += " AND BAX_CODESP IN ("+ cEspGen +") "
					cSql += " AND (BAX_DATBLO   = ' ')"
					cSql += " AND D_E_L_E_T_   = ' ' "

					PlsQuery(cSql,"BAXX25")
					lRet := BAXX25->(!(EoF()))
					BAXX25->(Dbclosearea())
				Endif
			Endif

			//Informacoes adicionais no complemento da critica
			If !lRet
				//			If cTipPro == "S"
				//				If !Empty(cNomProf)
				//					CCOMPCRI := "Prestador Solicitante: " + cNomProf + CRLF
				//				EndIf
				//				CCOMPCRI += "Especialidade: " + cEspX + CRLF
				//				CCOMPCRI += "CBOS: " + cCboX + CRLF
				//			Else
				If !Empty(cNomProf)
					CCOMPCRI := "Prestador Executante: " + cNomProf + CRLF
				EndIf
				CCOMPCRI += "Especialidade: " + cEspX + CRLF
				CCOMPCRI += "CBOS: " + cCboX + CRLF
				//			EndIf
			EndIf

		Case cCodGlo == "X55" //Procedimento bloqueado na especialidade da Rede de atendimento.

			//Ativa o ponto de entrada para manipular o retorno
			lExecPE := .T.

			//Retorna o array STATIC com os resultados da func PLSTratExe
			xRetExe := P974RetHx(1)

			//Retorna todas as especialidades
			xEsp := PlRtEspPre(COPEMOV,CRDAORI,_CESPEXE,DDATPRO,CCODLOC,_LPLSCTES,.F.,Iif(_LPLSCTES,"A","C"),.F.)

			lGo := (!Empty(xEsp) .And. Len(aDadUser) > 0 .And. Len(aDadPres) > 0)

			//Caso nao encontrou nenhuma das informacoes acima, nao ha necessidade de validar a critica
			If !lGo

				Iif(Len(aDadUser) > 0,nil,FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Erro ao validar critica X55 - Inconsistência nos dados do Beneficiário - " + cArqXML , 0, 0, {}) )
				Iif(Len(aDadPres) > 0,nil,FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Erro ao validar critica X55 - Inconsistência nos dados do Prestador - " + cArqXML , 0, 0, {}) )

				lRet := .T.

			EndIf

			//Verifica se deve percorrer todas as especialidades e se deve continuar
			If !_LPLSCTES .And. lGo
				//Se a especialidade estiver bloqueada nao valido
				If PlPreEspBl(CRDAORI,COPEMOV,CCODLOC,xEsp,DDATPRO)
					lRet := .T.
					Return lRet
				Else
					//Salva a chave para as proximas consultas
					cChvHash := AllTrim(CCODPAD)
					cChvHash += AllTrim(CCODPRO)
					cChvHash += AllTrim(xEsp)
					cChvHash += AllTrim(CRDAORI)
					PlArrToS(aDadPres,@cChvHash)
					PlArrToS(aDadUser,@cChvHash)
					cChvHash += AllTrim(CCODLOC)
					cChvHash += DtoS(DDATPRO)

					//Criptografa a chave para economia de espaco no Array
					cChvHash := MD5(cChvHash,2)

					//Faz a busca
					lGetHash := PLGetHash(cChvHash,@aRetExe,xRetExe)

					//Se nao achou, executa a rotina e salva o retorno
					If !lGetHash
						aRetExe := PLSTratExe(CCODPAD,CCODPRO,.T.,.T.,.F.,xEsp,CRDAORI,,aDadPres,aDadUser,,DDATPRO,xEsp,CCODLOC,,,,,xEsp,,.T.)
						lRet 		:= aRetExe[1]

						//Guarda o retorno
						PLSetHash(cChvHash,aRetExe,@xRetExe)

					Else
						lRet := aRetExe[1]
						If !lRet
							CNVCRIXML 	:= PL973PATH(aRetExe[2])
						EndIf
					EndIf
				EndIf

			ElseIf lGo .And. Len(xEsp) > 0

				For nI := 1 to Len(xEsp)

					//Se a especialidade estiver bloqueada nao valido
					If xEsp[nI][4] == "1"
						lRet := .T.
						loop
					Else
						//Salva a chave para as proximas consultas
						cChvHash := AllTrim(CCODPAD)
						cChvHash += AllTrim(CCODPRO)
						cChvHash += AllTrim(xEsp[nI][1])
						cChvHash += AllTrim(CRDAORI)
						PlArrToS(aDadPres,@cChvHash)
						PlArrToS(aDadUser,@cChvHash)
						cChvHash += AllTrim(CCODLOC)
						cChvHash += DtoS(DDATPRO)

						//Criptografa a chave para economia de espaco no Array
						cChvHash := MD5(cChvHash,2)

						//Faz a busca
						lGetHash := PLGetHash(cChvHash,@aRetExe,xRetExe)

						//Se nao achou, executa a rotina e salva o retorno
						If !lGetHash

							aRetExe := PLSTratExe(CCODPAD,CCODPRO,.T.,.T.,.F.,xEsp[nI][1],CRDAORI,,aDadPres,aDadUser,,DDATPRO,xEsp[nI][1],CCODLOC,,,,,xEsp[nI][1],,.T.)

							//Guarda o retorno
							PLSetHash(cChvHash,aRetExe,@xRetExe)

							lRet := aRetExe[1]

							If lRet
								Exit
							EndIf
						Else
							lRet := aRetExe[1]
							If lRet
								Exit
							EndIf
						EndIf
					EndIf
				Next
			EndIf

			//Informacoes adicionais no complemento da critica
			If !lRet
				CCOMPCRI := "Prestador Executante: " + cNomProf + CRLF
				CCOMPCRI += "Especialidade do Executante: " + cEspX + CRLF
				CCOMPCRI += "CBOS: " + cCboX
				If !_LPLSCTES
					CCOMPCRI += CRLF
					CCOMPCRI += "Especialidade do Prestador com base no CBOS enviado: " + xEsp + CRLF
					CCOMPCRI += "Local de atendimento: " + CCODLOC + CRLF
					CCOMPCRI += CNVCRIXML
				Else
					CCOMPCRI += CRLF
					CCOMPCRI += "Nao foi possivel localizar permissao para execucao do procedimento em nenhuma especialidade do Prestador" + CRLF
				EndIf
			EndIf

		Case cCodGlo == "X59" //Especialidade bloqueada para esta RDA.

			//Ativa o ponto de entrada para manipular o retorno
			lExecPE := .T.

			//Verifica se a especialidade foi encontrada e limpa a especialidade para validacao da proxima guia.
			If !(Empty(_CESPEXE))
				//Retorna novamente a especialidade caso esteja vazia.
				xEsp := PlRtEspPre(COPEMOV,CRDAORI,_CESPEXE,DDATPRO,CCODLOC,_LPLSCTES,.F.,Iif(_LPLSCTES,"A","C"),.F.)

				//Se estiver vazia, nao e necessario validar o bloqueio
				If Empty(xEsp)
					lRet := .T.
				ElseIf !_LPLSCTES
					//Buscando a especialidade na Rede de Atendimento
					If !PlPreEspBl(CRDAORI,COPEMOV,CCODLOC,xEsp,DDATPRO)
						lRet := .T.
					Endif
				Else
					//Se encontrou uma especialidade ativa, retorna verdadeiro
					If aScan(xEsp,{|x|(x[4]) == "0"}) > 0
						lRet := .T.
					EndIf
				EndIf

			Else
				//Se a especialidade do executante estiver vazia, nao valido a critica
				lRet := .T.
			EndIf

			//Informacoes adicionais no complemento da critica
			If !lRet
				CCOMPCRI := "Prestador Executante: " + cNomProf + CRLF
				CCOMPCRI += "Especialidade do Executante: " + cEspX + CRLF
				CCOMPCRI += "CBOS: " + cCboX
				If !_LPLSCTES
					CCOMPCRI += CRLF
					CCOMPCRI += "Especialidade do Prestador com base no CBOS enviado: " + xEsp + CRLF
					CCOMPCRI += "Local de atendimento: " + CCODLOC
				Else
					CCOMPCRI += CRLF
					CCOMPCRI += "Nao foi possivel localizar nenhuma especialidade ativa no cadastro do Prestador" + CRLF
				EndIf
			EndIf

			//Ponto de Entrada para realizar o vinculo de mais de um CBOs a uma Especialidade
		Case ExistBlock("PLTISESP") .And. !Empty(cCboX) .And. !Empty(cCodGlo)
			//Primeira chamada para criticas customizadas

			aRetPe := ExecBlock("PLTISESP",.F.,.F.,{"1",cTipPro,cNomProf,cCboX,cEspX,cCodGlo,lRet})
			If ValType(aRetPe) == "A"
				lRet		:= aRetPe[3]
			Endif

	EndCase

	//Ponto de Entrada para realizar o vinculo de mais de um CBOs a uma Especialidade
	If ExistBlock("PLTISESP") .And. !Empty(cCboX) .And. lExecPE
		//Segunda chamada para customizacao das criticas padrao

		aRetPe := ExecBlock("PLTISESP",.F.,.F.,{"1",cTipPro,cNomProf,cCboX,cEspX,cCodGlo,lRet})
		If ValType(aRetPe) == "A"
			lRet		:= aRetPe[3]
		Endif

	EndIf

Return lRet

/*/{Protheus.doc} P973LDCLI
Adiciona no array padrao as criticas de cliente

@type function
@author victor.silva
@since 27/07/2016
@version 1.0
/*/
function P973LDCLI()

	local cTipoGrv		:= "1"
	local cLocalExec	:= "5"
	local nI 				:= 0
	local nCont			:= 0
	local aCriCust		:= {}
	local lRet				:= .F.
	local cOpeMov			:= PLSIntPad()

	if Len(__aCriCust) == 0
		//Ordena por tipo de glosa
		DbSelectArea("BVN")
		BVN->(DbSetOrder(2))//BVN_FILIAL+BVN_CODOPE+BVN_PROPRI+BVN_CODGLO

		//Faz a busca por validacoes de cliente
		if BVN->(MsSeek(xFilial("BVN") + cOpeMov + "7"))
			//Define o array de criticas
			while ( BVN->(!Eof()) .And. BVN->BVN_PROPRI == "7")
				aAdd(aCriCust,{BVN->(BVN_PROPRI + BVN_CODGLO)})
				BVN->(dbSkip())
			enddo
		endif

		for nI:= 1 to Len(aCriCust)
			//Adiciona a critica no array padrao
			if PLSPOSGLO(cOpeMov,aCriCust[nI][1],"",cLocalExec,"1",cTipoGrv)
				nCont++
				lRet := .T.
				aAdd(__aCriCust,{aCriCust[nI][1],BCT->BCT_DESCRI})
				aAdd(__XACRITICAS,__aCriCust[nCont])
			endif
		next

		lRet := len(aCriCust) > 0
	endif

return lRet

/*/{Protheus.doc} PL973PATH
Formata o caminho da critica para exibir no log de criticas

@type function
@author victor.silva
@since 22/08/2016
@version 1.0
@param aCodCri, array , Array com as criticas do procedimento
@return cPath, caminho da critica
/*/
function PL973PATH(aCodCri)
	local cPath 	:= ''
	local nLen		:= Len(aCodCri)

	cPath := "Nivel: " 		+ SubStr(AllTrim(StrTran(aCodCri[nLen][2],'"','')),8) + CRLF
	cPath += "Caminho: " 	+ SubStr(AllTrim(StrTran(aCodCri[nLen][3],'"','')),6)

	PLSDelTra(@cPath)

return cPath

/*/{Protheus.doc} P973RDBL
Verifica se, na data do procedimento, a RDA estava contratada ou bloqueada
OBS: Está posicionado na BAU da RDA
@author Oscar Zanin
@since 20/09/2016
@version P12
/*/
function P973RDBL
return A973CHEBLO("BAU")

/*/{Protheus.doc} A973CHEBLO
Checa o bloqueio do Prestador/Profissional de Saude na data do procedimento
@type function
@author victor.silva
@since 29/09/2016
@version 1.0
/*/
function A973CHEBLO(cAlias)
	local lRet 	:= .F.
	local cTipPro	:= ""

	//temos que garantir o posicionamento na BAU
	IF cAlias == "BAU" .AND. BAU->BAU_CODIGO <> CRDAORI
		BAU->(DbSetOrder(1))
		BAU->(MSSeek(xfilial("BAU") + CRDAORI))
	EndIF

	//Tipo de Prestador sendo validado
	if "SOLICITANTE" $ _cPathTag
		cTipPro	:= "S"
	else
		cTipPro	:= "E"
	endif

	//Se for Profissional Solicitante nao checa o bloqueio
	if cTipPro == "S" .and. cAlias == "BB0"
		return .T.
	endif

	do case
		case cAlias == "BAU" //Prestador
			//Checa se o Prestador estava credenciado na data do atendimento
			if DDATPRO >= BAU->BAU_DTINCL
				//Caso verdadeiro, checa o historico de bloqueio
				lRet := A360CHEBLO(BAU->BAU_CODIGO,DDATPRO,.T.,CHORA)
			else
				lRet := .F.
			endif

		case cAlias == "BB0" //Profissional de Saude
			//Localiza o profissional
			PLSIVPRO(NIL,CSIGLA,CCRM,CCODUF,4)
			if BB0->( found() )
				lRet := A090CHEBLO(BB0->BB0_CODIGO,DDATPRO,.F.,,CHORA)
			else
				lRet := .T.
			endif
	endcase

	if !lRet
		CCOMPCRI := "Codigo do Procedimento: " + CCODPRO + CRLF
		CCOMPCRI += "Data de execucao: " + DtoC(DDATPRO)
	endif

return lRet

/*/{Protheus.doc} PLVLRDACRZ
Função utilizada pela crítica "X57 - Valor Unitário X
Quantidade Solcicitada X Redução Acréscimo diferente do
valor Total
@type function
@author Oscar Zanin
@since 07/11/2016
@version 1.0
/*/
Function PLVLRDACRZ(xRet)

	Local cCamTag				:= AllTrim(BVN->BVN_CAMTAG)
	Local nQtdProd 		   := Val(PVLRTAGXML(aDados, cCamTag + "QUANTIDADEEXECUTADA", nSeqGui))
	Local nValUnit 		   := Val(PVLRTAGXML(aDados, cCamTag + "VALORUNITARIO", nSeqGui))
	Local nValTot  		   := Val(PVLRTAGXML(aDados, cCamTag + "VALORTOTAL", nSeqGui))
	Local nValTotCalculado := 0
	Local nRedAcre 		   := Val(PVLRTAGXML(aDados, cCamTag + "REDUCAOACRESCIMO", nSeqGui))
	Default xRet := .F.

	If nRedAcre >= 100
		nRedAcre := nRedAcre / 100
	EndIf

	nValTotCalculado := round((nQtdProd * nValUnit) * nRedAcre , 2)

	if xret
		Return nValTotCalculado
	EndIf

Return nValTotCalculado == nValTot

/*/{Protheus.doc} PLCRIX57
Função para a mensagem auxiliar da crítica X57
@type function
@author Oscar Zanin
@since 11/11/2016
@version 1.0
/*/
Function PLCRIX57(nValid)
	Local cRet := ""

	If ValType(nValid) == "C"
		nValid := val(nValid)
	EndIf

	If nValid == 1
		cRet := 'Tabela: '+AllTrim(cSlvPad)+' - Codigo: '+AllTrim(cCodPro)+' - Descricao: '+AllTrim(Posicione('BR8',1,xFilial('BR8')+cCodPad+cCodPro,'BR8_DESCRI'))+' Quantidade Procedimento: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\QUANTIDADEEXECUTADA', nSeqGui))+' Valor Unitario: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\VALORUNITARIO', nSeqGui))+ ' Reducao Acrescimo: '+AllTrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\REDUCAOACRESCIMO', nSeqGui)) + ' Valor Total Informado: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\VALORTOTAL', nSeqGui)) + ' Valor Total Calculado: '+AllTrim(str(PLVLRDACRZ(.T.)))
	elseif nValid == 2
		cRet := 'Tabela: '+AllTrim(cSlvPad)+' - Codigo: '+AllTrim(cCodPro)+' - Descricao: '+AllTrim(Posicione('BR8',1,xFilial('BR8')+cCodPad+cCodPro,'BR8_DESCRI'))+' Quantidade Procedimento: '+alltrim(PVLRTAGXML(aDados, 'MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\QUANTIDADEEXECUTADA', nSeqGui))+' Valor Unitario: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\VALORUNITARIO', nSeqGui))+ ' Reducao Acrescimo: '+AllTrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\REDUCAOACRESCIMO', nSeqGui))
		cRet += ' Valor Total Informado: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIAHONORARIOS\PROCEDIMENTOSREALIZADOS\PROCEDIMENTOREALIZADO\VALORTOTAL', nSeqGui)) + ' Valor Total Calculado: '+AllTrim(str(PLVLRDACRZ(.T.)))
	elseif nValid == 3
		cRet := 'Tabela: '+AllTrim(cSlvPad)+' - Codigo: '+AllTrim(cCodPro)+' - Descricao: '+AllTrim(Posicione('BR8',1,xFilial('BR8')+cCodPad+cCodPro,'BR8_DESCRI'))+' Quantidade Procedimento: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIASP_SADT\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\QUANTIDADEEXECUTADA', nSeqGui))+' Valor Unitario: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIASP_SADT\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\VALORUNITARIO', nSeqGui))+ ' Reducao Acrescimo: '+AllTrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIASP_SADT\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\REDUCAOACRESCIMO', nSeqGui)) + ' Valor Total Informado: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIASP_SADT\PROCEDIMENTOSEXECUTADOS\PROCEDIMENTOEXECUTADO\VALORTOTAL', nSeqGui)) + ' Valor Total Calculado: '+AllTrim(str(PLVLRDACRZ(.T.)))
	elseif nValid == 4
		cRet := 'Tabela: '+AllTrim(cSlvPad)+' - Codigo: '+AllTrim(cCodPro)+' - Descricao: '+AllTrim(Posicione('BR8',1,xFilial('BR8')+cCodPad+cCodPro,'BR8_DESCRI'))+' Quantidade Procedimento: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS\QUANTIDADEEXECUTADA', nSeqGui))+' Valor Unitario: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS\VALORUNITARIO', nSeqGui))+ ' Reducao Acrescimo: '+AllTrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS\REDUCAOACRESCIMO', nSeqGui)) + ' Valor Total Informado: '+alltrim(PVLRTAGXML(aDados, '\MENSAGEMTISS\PRESTADORPARAOPERADORA\LOTEGUIAS\GUIASTISS\GUIARESUMOINTERNACAO\OUTRASDESPESAS\DESPESA\SERVICOSEXECUTADOS\VALORTOTAL', nSeqGui)) + ' Valor Total Calculado: '+AllTrim(str(PLVLRDACRZ(.T.)))
	EndIf

Return cRet

/*/{Protheus.doc} 973LTran
Executa varios STRTRAN limpando o conteudo que vai para o aDados
@type function
@author timoteo.bega
@since 28/10/2016
@version 1.0
/*/
Static Function A973LTran(cTexto,cTipo,aPrefixo,cTpGuias)
	Local nFor			:= 0
	Local nMax			:= 0
	Default cTexto 		:= ""
	Default cTipo		:= ""
	Default aPrefixo	:= {"_ANS_","_ANSTISS_","ANS:","ANSTISS:","_"}
	Default cTpGuias	:= ""

	If Len(aPrefixo) >= 5 .And. cTipo == "REALNAME"
		nMax := Len(aPrefixo) - 1
	Else
		nMax := Len(aPrefixo)
	EndIf

	For nFor := 1 TO nMax
		cTexto := StrTran(cTexto,aPrefixo[nFor],"")
		If cTexto $ cTpGuias
			Exit
		EndIf
	Next nFor

Return cTexto

/*/{Protheus.doc} P973TpGui
Retorna os possiveis tipos de arquivo XML TISS
@author victor.silva
@since 01/11/2016
@param cTissVer, caracter, Versao TISS
@return caracter, Tipos de arquivos XML
/*/
function P973TpGui(cTissVer)
	local cRet := ""

	default cTissVer := ""

	//Consulta
	cRet := "GUIACONSULTA,"
	cRet +=	"GUIACONSULTAREAPRESENTACAO,"

	//SADT
	cRet +=	"GUIASP_SADT,GUIASP-SADT,GUIASPSADT,"
	cRet +=	"GUIASP_SADTREAPRESENTACAO,"
	cRet +=	"GUIASOLICITACAOSADT,GUIASOLICITACAOSP-SADT,"
	cRet +=	"GUIASOLICITACAOSP_SADT,SOLICITACAOSP_SADT,"
	cRet +=	"SOLICITACAOSP-SADT,SOLICITACAOSPSADT,"

	//Internacao/Prorrog. Intern
	cRet +=	"GUIASOLICINTERNACAO,SOLICITACAOINTERNACAO,"
	cRet +=	"GUIASOLICITACAOPRORROGACAO,"
	cRet +=	"SOLICITACAOPRORROGACAO,"

	//Resumo de Internacao
	cRet +=	"GUIARESUMOINTERNACAO,"
	cRet +=	"GUIARESUMOINTERNACAOREAPRESENTACAO,"

	//Honorarios
	cRet +=	"GUIAHONORARIOINDIVIDUAL,GUIAHONORARIOS,"
	cRet +=	"GUIAHONORARIOINDIVIDUALREAPRESENTACAO,"

	//Recurso de Glosas/Reemb.
	cRet += "RECURSOGUIA,SOLICITACAOSTATUSRECURSOGLOSA,"
	cRet += "RECURSOPROTOCOLO,"

	//Pagamento
	cRet += "DEMONSTRATIVOANALISE,"
	cRet += "DEMONSTRATIVOPAGAMENTO,"
	cRet += "DEMONSTRATIVOPAGAMENTOODONTO,"

	//Elegibilidade
	cRet +=	"SOLICITASTATUSAUTORIZACAO,"
	cRet +=	"VERIFICAELEGIBILIDADE,"
	cRet +=	"CANCELAGUIA,"

	//TODO Odontologia
	cRet +=	"GUIAODONTOLOGIA,GUIAODONTO,"
	cRet +=	"GUIAODONTOLOGIAREAPRESENTACAO,"
	cRet +=	"GUIASOLICITACAOODONTOLOGIA,"
	cRet +=	"SOLICITACAOODONTOLOGIA,"

return cRet

/*/{Protheus.doc} P973VldLoc
Realiza validacao do local de atendimento informado na senha de liberacao de acordo com o enviado no XML
@author victor.silva
@since 17/01/2017
@param cCnesXml, caracter, Codigo do CNES do Local de Atendimento
/*/
//TODO - Retirei a parte que verificava o CNES da liberação, atualmente a função tratará somente CNES válido. Verificar a regra da liberação no futuro
function P973VldLoc(aDadXML, lOdonto)
	local lRet 		:= .T.
	local lFound	:= .F.
	local lNoCnes	:= .F.
	local cLocGui	:= ""
	local cLocXML	:= ""
	local cCnesGui	:= ""
	local cCnesXml	:= ""
	local dDatBlo	:= CtoD("")
	Local cRDAbus	:= CRDAORI

	Default lOdonto := .F.

	If !(lOdonto)

		//Posiciona na Guia de Solicitação de acordo com a Senha e retorna o local de atendimento e CNES de acordo com o tipo de guia e versao TISS
		do case
			case CTIPGUI == "01"

				//Retorna o numero da autorizacao da consulta
				cNumAut := AllTrim(PVLRTAGXML(aDadXML,"\NUMEROGUIAOPERADORA"))

				if !empty(cNumAut)
					//Busca pelo codigo do Protheus
					BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT
					if !BEA->(MsSeek(xFilial("BEA") + cNumAut))
						//Caso nao encontre busca pela senha
						BEA->(DbSetOrder(14))//BEA_FILIAL+BEA_SENHA
						if BEA->(MsSeek(xFilial("BEA") + cNumAut))
							//			cLocGui := BEA->BEA_CODLOC
						endif
					else
						//		cLocGui := BEA->BEA_CODLOC
					endif
				endif

				cCnesXml	:= PVLRTAGXML(aDadXML,"\CONTRATADOEXECUTANTE\CNES")

				//Se a variavel NRECNOAUT estiver maior que 0, significa que a tag <SENHA> esta presente no arquivo e a autorizacao foi localizada
			case CTIPGUI == "02"
				if NRECNOAUT > 0
					BEA->(DbGoTo(NRECNOAUT))
					//	cLocGui	:= BEA->BEA_CODLOC
				endif
				cCnesXml := PVLRTAGXML(aDadXML,"\DADOSEXECUTANTE\CNES")

			case CTIPGUI == "05"
				if NRECNOAUT > 0
					BE4->(DbGoTo(NRECNOAUT))
					//	cLocGui	:= BE4->BE4_CODLOC
				endif
				cCnesXml := PVLRTAGXML(aDadXML,"\DADOSEXECUTANTE\CNES")

			case CTIPGUI == "06"
				if NRECNOAUT > 0
					BE4->(DbGoTo(NRECNOAUT))
					//	cLocGui	:= BE4->BE4_CODLOC
				endif
				// Quando for GHI o CNES devera vir do executante pois é ele quem esta cobrando e não do contratante
				cCnesXml	:= PVLRTAGXML(aDadXML,"CNESCONTRATADOEXECUTANTE")
				If Empty(cCnesXml)
					cCnesXml := PVLRTAGXML(aDadXML,"\LOCALCONTRATADO\CNES")
				Endif
				cRDAbus := CCODRP
		endcase
	else
		cCnesXml	:= PVLRTAGXML(aDadXML,"CNESEXEC")
	endIf

	//Verifica se o CNES existe em algum local de atendimento do Prestador
	BB8->(DbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
	if BB8->(MsSeek(xFilial("BB8")+ cRDAbus + COPEMOV))
		While !BB8->(Eof()) .And. AllTrim(BB8->(BB8_CODIGO + BB8_CODINT)) == cRDAbus + COPEMOV

			lFound	:= AllTrim(BB8->BB8_CNES) == AllTrim(cCnesXml)
			lNoCnes	:= empty(BB8->BB8_CNES)
			cLocXML	:= AllTrim(BB8->BB8_CODLOC)
			dDatBlo	:= BB8->BB8_DATBLO

			BB8->(DbSkip())

			if lFound .Or. lNoCnes
				exit
			endif
		EndDo

		//Se encontrou algum local de atendimento vazio ou encontrou o informado, nao critica
		if (!lFound .And. !lNoCnes)
			lRet 		:= .F.
			CCOMPCRI 	+= "CNES não encontrado nos Locais de atendimento do Prestador" + CRLF
		endif
	endif

	if lRet .And. !empty(cLocGui)
		//Verifica se o local de atendimento da liberacao, nao possui CNES
		BB8->(DbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
		if BB8->(MsSeek(xFilial("BB8")+ cRDAbus + COPEMOV + cLocGui))

			dDatBlo	 := BB8->BB8_DATBLO
			cCnesGui := AllTrim(BB8->BB8_CNES)

			if !empty(cCnesGui)
				//Verifica se o codigo informado na liberacao e diferente do enviado no XML
				if cCnesGui <> AllTrim(cCnesXml)
					lRet 		:= .F.
					CCOMPCRI 	+= "CNES do Local de atendimento informado na Solicitacao: " + cCnesGui + CRLF
				endif

				//Verifica se o local de atendimento esta bloqueado na data da execucao
				if lRet .And. !empty(dDatBlo) .And. DDATPRO >= dDatBlo .And. !lNoCnes
					lRet 		:= .F.
					CCOMPCRI 	+= "Local de atendimento bloqueado na data de execucao do atendimento" + CRLF
					CCOMPCRI 	+= "Data de execucao	: " + DtoC(DDATPRO) + CRLF
					CCOMPCRI 	+= "Data do bloqueio	: " + DtoC(dDatBlo) + CRLF
				endif
			endif
		endif
	elseif lRet .And. empty(cLocGui)
		//Verifica somente o bloqueio
		if !empty(cCnesXml) .And. !empty(dDatBlo) .And. !lNoCnes
			if DDATPRO >= dDatBlo
				lRet 		:= .F.
				CCOMPCRI 	+= "Local de atendimento bloqueado na data de execucao do atendimento" + CRLF
				CCOMPCRI 	+= "Data de execucao	: " + DtoC(DDATPRO) + CRLF
				CCOMPCRI 	+= "Data do bloqueio	: " + DtoC(dDatBlo) + CRLF
			endif
		endif
	endif

return lRet


/*/{Protheus.doc} PLSVSENXML
Busca as TAGS para validacao da senha ou GUIA.
@author TOTVS
@since 10/10/2017
@param cMatXML, dDatpro
/*/

Function PLSCHGBL(cMatXML,dDatpro,cTipo)

	Local aNumSen		:= {}
	Local cMAut		:= ""
	Local cManAtAu	:= ""
	Local lRet			:= .F.
	Local nXi			:= 1
	Local x 			:= 0
	Local y			:= 0
	Local aAreOld	:= {BEA->(GetArea()),BE4->(GetArea()),GetArea()}

	Default cMatXML		:= AllTrim(aDadosUnic[(aScan( aDadosUnic, {|x| x[1]=="NUMEROCARTEIRA"})),3])
	Default dDatpro 	:= dDataBase
	Default cTipo 	:= '2'

	lFouNAut := .F.
	nReAut := 0

	x := Len(aMapGuia)
	While x > 0 //Tem que olhar de trás pra frente, pra fazer do outro jeito tem que olhar intervalos
		If nZaDados >= aMapGuia[x][1]
			//	lGuiaSen := aMapGuia[x][2]
			Exit
		EndIf
		x--
	EndDo

	//Pegamos esse do aDados pq estamos olhando uma Tag opcional e não sabemos se a do aDadosUnic é a da guia atual
	for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
		If aDados[y][1] == "SENHA"
			Aadd(aNumSen, aDados[y][3])
			Exit
		EndIf
	Next

	//Pegamos esse do aDados pq estamos olhando uma Tag opcional e não sabemos se a do aDadosUnic é a da guia atual
	for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
		If aDados[y][1] == "GUIASOLICINTERNACAO"
			Aadd(aNumSen, aDados[y][3])
			Exit
		EndIf
	Next

	//Pegamos esse do aDados pq estamos olhando uma Tag opcional e não sabemos se a do aDadosUnic é a da guia atual
	for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
		If aDados[y][1] == "NUMEROGUIASOLICITACAOINTERNACAO"
			Aadd(aNumSen, aDados[y][3])
			Exit
		EndIf
	Next

	for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
		If aDados[y][1] == "NUMEROGUIAPRESTADOR"
			Aadd(aNumSen, aDados[y][3])
			Exit
		EndIf
	Next

	//Pegamos esse do aDados pq estamos olhando uma Tag opcional e não sabemos se a do aDadosUnic é a da guia atual
	for y := aMapGuia[x][1] To IIF( x >= Len(aMapGuia), Len(aDados), aMapGuia[x+1][1])
		If aDados[y][1] == "NUMEROGUIAOPERADORA"
			Aadd(aNumSen, aDados[y][3])
			Exit
		EndIf
	Next

	//Verifica a senha na BEA ou BE4
	For nXi:= 1 To Len(aNumSen)
		If PLSVSENXML(aNumSen[nXi],cNumImp,cTipo,@cMAut,@cManAtAu)
			lFouNAut := .T.
			Exit
		EndIf
	Next

	//Encontrou a senha e a matricula é a mesma.
	If lFouNAut .And. (cMatXML == cMAut .Or. cMatXML == cManAtAu)
		lRet := .T.
	ElseIf !lFouNAut
		lRet := .F.
	EndIf

	AEval(aAreOld, {|x| RestArea(x) })
Return lRet

/*/{Protheus.doc} PLSVSENXML
Realiza validacao da senha. Funcao utilizada na critica X32
@author TOTVS
@since 10/10/2017
@param cNSen, cNumImp, cTipo cMAut, cManAtAu
/*/

Function PLSVSENXML(cNSen,cNumImp,cTipo,cMAut,cManAtAu)

	Local cAlsQry 	:= GetNextAlias()
	Local lFouNAut := .F.

	Default cNSen 	:= ""
	Default cNumImp 	:= ""
	Default cTipo		:= ""
	Default cMAut		:= ""
	Default cManAtAu	:= ""

	If cTipo $ '1/2'// Verifica BEA

		BEA->(dbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
		If !BEA->(MsSeek(xFilial('BEA')+PadR(AllTrim(cNSen),18)))

			BEA->(dbSetOrder(14))//BEA_FILIAL+BEA_SENHA
			If !BEA->(MsSeek(xFilial('BEA')+PADR(AllTrim(cNSen),9)))
				If BEA->(FieldPos("BEA_GUIPRE"))> 0
					BeginSql Alias cAlsQry
					SELECT
						BEA_OPEUSR,BEA_CODEMP,BEA_MATRIC,BEA_TIPREG,BEA_DIGITO,BEA_MATANT, R_E_C_N_O_
					FROM
						%table:BEA% BEA
					WHERE
						BEA_FILIAL = %exp:xFilial("BEA")%
						AND BEA_GUIPRE 	= %exp:cNumImp%
						AND BEA_STATUS = "1"
						AND BEA_CANCEL = "0"
						AND BEA.%NotDel%
					Endsql
					(cAlsQry)->(dbGoTop())
					If !(cAlsQry)->(Eof())
						lFouNAut := .T.
						nReAut := IIF( ValType((cAlsQry)->(R_E_C_N_O_)) == "N", (cAlsQry)->(R_E_C_N_O_), Val((cAlsQry)->(R_E_C_N_O_)) )
						cMAut	:= AllTrim((cAlsQry)->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO))
						cManAtAu	:= AllTrim((cAlsQry)->(BEA_MATANT))
					EndIf
				EndIf
			Else
				If BEA->BEA_STATUS == "1" .And. BEA->BEA_CANCEL == "0"
					lFouNAut 	:= .T.
					nReAut	:= BEA->(Recno())
					cAlsQry 	:=  "BEA"
				EndIf
			EndIf
		Else
			If BEA->BEA_STATUS == "1" .And. BEA->BEA_CANCEL == "0"
				lFouNAut 	:= .T.
				nReAut	:= BEA->(Recno())
				cAlsQry 	:=  "BEA"
			EndIf
		EndIf

		//Encontrou a autorização.
		If lFouNAut
			cMAut		:= AllTrim((cAlsQry)->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO))
			cManAtAu	:= AllTrim((cAlsQry)->(BEA_MATANT))
		EndIf
	EndIf

Return lFouNAut


/*/{Protheus.doc} PNewTabDup
função pra corrigir cCodTab da BVP quando tem o ATABDUP (relação de tabela TISS pra tabela operadora 1 x N)
na validação da Crítica X30
@author Oscar Zanin
@since 05/04/2018
/*/
function PNewTabDup(aTabDup, calias, cCdterm, cCdPadTISS)

	Local nCT := 1
	Local cRet := cCdPadTISS

	Default aTabDup := {}

	If ! Empty(aTabDup) // estrutura para que seja possivel verificar duas tabelas padroes vinculadas a uma unica terminologia
		For nCT := 1 to Len(aTabDup)

			If Alltrim(aTabDup[nCt,1]) == cCdPadTISS
				BTU->(DbSetOrder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
				If BTU->(MsSeek(_BTUFIlial+cCdPadTISS+cAlias+xfilial(calias)+padr(Alltrim(aTabDup[nCT,2]+cCdTerm), tamsx3("BTU_VLRSIS")[1])))

					cRet 	:= Alltrim(aTabDup[nCT,2])

					Exit

				EndIf

			EndIf

		Next nCT
	EndIf

Return cRet

/*/{Protheus.doc} PLSDtX58
função para definir se a data a ser usada como referência para a críica X58 será a data atual (dDataBase) ou o
conteúdo informado no pergunte na hora de realizar a submissão
@author Oscar Zanin
@since 21/08/2018
/*/
function PLSDtX58()

	Local dRet := dDataBase

	If Type("dDtBsBXX") == "D"
		dRet := dDtBsBXX
	EndIf

return dRet



/*/{Protheus.doc} PLSRTB2Z
valida se o procedimento consta na B2Z como pré-autorizada, caso seja usado o HAT.
@author Pls Team
@since 01/2019
/*/
function PLSRTB2Z(tOpeMov, tNumGuia, tMatric, tCodPad, tCodPro)
	local aTabDup 	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
	local cCodTbT		:= ""
	local cCodPrT		:= ""
	local aRet			:= {}
	local lRet			:= .f.
	local nQtdPre		:= 0
	local nRecB2Z		:= 0

	//Fazer o De/para do código da tabela e procedimento. HAT grava conforme terminologia TISS....
	if( !empty(tCodPad) .and. !empty(tCodPro) )
		cCodTbT := PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  tCodPad)
		cCodPrT := PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodTbT,  Alltrim(tCodPad + tCodPro), .F. ,aTabDup, @cCodTbT)
	endif

	B2Z->( dbGoTo(nRecnoAut) )

	if !empty(B2Z->B2Z_SENHA)
		tNumGuia 	:= B2Z->B2Z_SENHA
	else
		tNumGuia	:= B2Z->B2Z_NUMAUT
	endif

	nQtdPre	 := 0
	B2Z->(dbsetorder(7)) //B2Z_FILIAL + B2Z_OPEMOV + B2Z_SENHA  + B2Z_MATRIC + B2Z_CODPAD + B2Z_CODPRO
	If B2Z->(MsSeek(xFilial("B2Z") + tOPEMOV + tNumGuia + tMATRIC + alltrim(cCodTbT+cCodPrT)))
		nRecB2Z := 0
		while !B2Z->(Eof()) .and.  B2Z->(B2Z_FILIAL+B2Z_OPEMOV+B2Z_SENHA+B2Z_MATRIC+ alltrim(B2Z_CODPAD+B2Z_CODPRO)) == xFilial("B2Z")+tOPEMOV+tNumGuia+tMATRIC+Alltrim(cCodTbT+cCodPrT)
			nQtdPre += B2Z->B2Z_SALDO
			nRecB2Z := B2Z->(Recno())
			lRet	 := .t.
			B2Z->(DbSkip())
		Enddo
	else
		B2Z->(dbsetorder(8))//B2Z_FILIAL + B2Z_OPEMOV + B2Z_NUMAUT + B2Z_MATRIC + B2Z_CODPAD + B2Z_CODPRO
		if B2Z->(MsSeek(xFilial("B2Z") + tOPEMOV + tNumGuia + tMATRIC + alltrim(cCodTbT+cCodPrT)))
			while !B2Z->(Eof()) .and.  B2Z->(B2Z_FILIAL+B2Z_OPEMOV+B2Z_NUMAUT+B2Z_MATRIC+ alltrim(B2Z_CODPAD+B2Z_CODPRO)) == xFilial("B2Z")+tOPEMOV+tNumGuia+tMATRIC+Alltrim(cCodTbT+cCodPrT)
				nQtdPre += B2Z->B2Z_SALDO
				nRecB2Z := B2Z->(Recno())
				lRet	 := .t.
				B2Z->(DbSkip())
			enddo
		endif

	endif

	aRet := {lRet, nQtdPre, nRecB2Z}

Return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSASPAS
Remove aspas para evitar erro em query.

@author    Lucas Nonato
@version   V12
@since     06/06/2019
/*/
function PLSASPAS(cRet)

	cRet := strtran(cRet,"'","")
	cRet := strtran(cRet,'"',"")

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MontRetHAT
Monta e gera o retorno da submissão para arquivos que chegam pela integração com o HAT
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function MontRetHAT(aRet, cMsg, cCdCri, cDesCri, aauxZ, lflag)

	Local oRetJson      := JsonObject():new()
	Local nI			   := 1
	Local aCtTUSS			:= {"", ""}
	Local lTUSS := .F.
	Local cCodCri	:= ""
	Local cTUSS	:= ""
	Local cJson	:= ""
	Local cRegOpeANS := BuscaSUSEP()
	Local cMV_PHATURL := getnewPar('MV_PHATURL', '' )
	Local cUrlPUT := cMV_PHATURL + 'v1/batchesAuthorization/'
	Local cParamPut := '?codeSusep=' +  cRegOpeANS
	Local oRest	:= nil
	Local aHeader := {}
	Local cMV_PHATTOK	:= getNewPar('MV_PHATTOK', '')
	Local cMV_PHATIDT	:= alltrim(getNewPar('MV_PHATIDT', '1'))//Id Tenant
	Local cMV_PHATNMT	:= alltrim(getNewPar('MV_PHATNMT', 'tenant'))//Nome Tenant
	Local lRet := .f.
	Local cReqData := ""

	default aRet 	:= {}
	default cMsg 	:= ""
	default cCdCri  := "5012"
	default cDesCri := "Recebimento de mensagem não finalizado. Entre em contato com a Operadora"
	Default aauxZ	:= {}
	default lflag	:= .F.

	If lflag
		oretJson['codeSusep'] := cRegOpeANS
		oretJson['status'] := "1"
		oretJson['protocol'] := aauxZ[1]
		oretJson['batchNumber'] := aauxZ[2]
		oretJson['healthProviderId'] := aauxZ[3]
	elseif !empty(cMsg)
		oretJson['codeSusep'] := cRegOpeANS
		oretJson['status'] := "4"
		If empTy(aauxZ)
			oretJson['protocol'] := BXX->BXX_CODPEG
			oretJson['batchNumber'] := BXX->BXX_PLSHAT
			oretJson['healthProviderId'] := BXX->BXX_CODRDA
		else
			oretJson['protocol'] := aauxZ[1]
			oretJson['batchNumber'] := aauxZ[2]
			oretJson['healthProviderId'] := aauxZ[3]
		endIf
		oretJson['rejectionCauses'] := {}
		aadd(oretJson['rejectionCauses'], JsonObject():new())
		oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['code'] 		 		 := cCdCri
		oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['description'] 		 := cDesCri
		oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['detailedDescription'] := cMsg
	else
		If Len(aRet[3]) == 0
			oretJson['codeSusep'] := cRegOpeANS
			oretJson['status'] := "2"
			oretJson['protocol'] := BXX->BXX_CODPEG
			oretJson['batchNumber'] := BXX->BXX_PLSHAT
			oretJson['healthProviderId'] := BXX->BXX_CODRDA
		else
			oretJson['codeSusep'] := cRegOpeANS
			oretJson['status'] := "4"
			oretJson['protocol'] := BXX->BXX_CODPEG
			oretJson['batchNumber'] := BXX->BXX_PLSHAT
			oretJson['healthProviderId'] := BXX->BXX_CODRDA
			oretJson['rejectionCauses'] := {}
			for nI := 1 To Len(aret[3])

				If AT("** [", aret[3][nI]) > 0 .OR. AT("** ERRO", aret[3][nI]) > 0
					aadd(oretJson['rejectionCauses'], JsonObject():new())
					cCodCri := subStr(aRet[3][nI], AT("X", aRet[3][nI]), 3)
					oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['code'] := IIF(empTy(cCodCri), aRet[3][nI], cCodCri)
					nI++

					If At("Critica TUSS:", aret[3][nI]) > 0
						cTUSS := SubStr(aret[3][nI], AT(":", aret[3][nI]) + 1)
						aCtTUSS := Separa(cTUSS, "-")
						lTUSS := .T.
						nI++
					endIf
					oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['description'] := AllTrim(aRet[3][nI])
					nI++
					oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['detailedDescription'] := ''
					while nI <= Len(aret[3]) .AND. AT("** [", aret[3][nI]) == 0 .AND. AT("** ERRO", aret[3][nI]) == 0
						oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['detailedDescription'] += AllTrim(aRet[3][nI]) + Chr(13) + Chr(10)
						nI++
					endDo
					If lTUSS
						oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['code'] := aCtTUSS[1]
						oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['description'] := aCtTUSS[2]
						aCtTUSS := {"", ""}
						lTUSS   := .F.
					endIf
					If "*" $ oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['code']
						oretJson['rejectionCauses'][Len(oretJson['rejectionCauses'])]['code'] := 'ERRO'
					endIf
					nI--
				EndIf

			Next
		endIf
	endif
	cJson := FWJsonSerialize(oRetJson, .F., .F.)

	If empty(aauxZ)
		oRest := FWRest():New(cUrlPUT + BXX->BXX_PLSHAT)
	else
		oRest := FWRest():New(cUrlPUT + AllTrim(aauxZ[2]))
	endIf

	oRest:setPath(cParamPut)
	aadd(aHeader, 'Authorization: ' + cMV_PHATTOK)
	aadd(aHeader, 'idTenant: '  + cMV_PHATIDT)
	aadd(aHeader, 'tenantname: ' + cMV_PHATNMT)

	lRet := oRest:Put(aHeader, cJson)
	If !lRet
		cReqData := "URI: " + oRest:cHost + ". Path:" + oRest:cPath + ". aHeader: " + ArrTokStr(aHeader, ",") + " cJson: [" + cJson + "]. "
		cMsg := "Erro ao tentar atualizar lote no HAT: " + oRest:getHttpCode() + " - " + oRest:getLastError() + ". " + cReqData
		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
	EndIf
return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSxHATXML
Integração para verificação se há XML  disponível no HAT e, caos houver, gravar o BXX e buscar o aruqivo .xml
para processamento no PLS
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSxHATXML()

	Local cReqData  	:= ""
	Local cRetCode  	:= ""
	Local nTry      	:= 0
	Local nItem      	:= 1
	Local aHeader   	:= {}
	Local cRegOpeANS 	:= BuscaSUSEP()
	Local cMV_PHATURL 	:= getnewPar('MV_PHATURL', '' )
	Local cUrlIni   	:= cMV_PHATURL + 'v1/batchesAuthorization'
	Local cPathIni  	:= 'codeSusep=' + cRegOpeANS + '&pageSize=100' //&action=onlyUnread'
	Local cfilPath  	:= "&filter=(protocol eq '' and status eq 'P' and not(azureStorageFilePath eq '') and isDeleted eq '') or (status eq 'E' and not (isDeleted eq ''))"
	Local cfieldhat 	:= '&fields=status,batchDate,protocol,azureStorageFilePath,azureStorageSasToken,batchNumber,healthProviderId,authType'
	Local oRestClient 	:= FWRest():New(cUrlIni)
	Local cMV_PHATTOK	:= getNewPar('MV_PHATTOK', '') //master token do hat
	Local cMV_PHATIDT	:= alltrim(getNewPar('MV_PHATIDT', '1'))// Id Tenant
	Local cMV_PHATNMT	:= alltrim(getNewPar('MV_PHATNMT', 'tenant')) // Nome Tenant
	Local aArea 		:= GetArea()
	Local oJson			:= JsonObject():new()
	Local lOkGet		:= .F.
	Local lHasNext		:= .F.

	Local cnumB1R	:= ""

	//Parte de pegar as informações
	cfilPath := Strtran(cfilPath, ' ', '%20') //O FWRest não aceita o caractere espaço, então tme que converter ele
	oRestClient:setPath("?" + cPathIni + cfilPath + cfieldhat)
	aadd(aHeader, 'authorization: ' + cMV_PHATTOK)
	aadd(aHeader, 'idTenant: ' + cMV_PHATIDT)
	aadd(aHeader, 'tenantname: ' + cMV_PHATNMT)
	B1R->(dbselectarea("B1R"))
	while nTry < 10 .AND. !lOkGet
		Sleep(1000)
		lOkGet := oRestClient:get(aHeader)
		cRetCode := oRestClient:getHttpCode()
		lOkGet := lOkGet .OR. (cRetCode >= "200" .AND. cRetCode <= "299")
		nTry++
	endDo

	cReqData := "URI:" + oRestClient:cHost + "URI:" + cUrlIni + ". Path:" + oRestClient:cPath + ". aHeader: " + ArrTokStr(aHeader, ",") + ". Fiz " + Alltrim(Str(nTry)) + " tentativas. Codigo de retorno: " + cRetCode + ". "
	If lOkGet
		cParseError := oJson:fromJSON(oRestClient:GetResult())
		If Empty(cParseError)
			lHasNext	:= oJson['hasNext']

			for nItem := 1 to Len(oJson['items'])
				cnumB1R := GetSXeNum("B1R","B1R_PROTOC")

				B1R->(recLock("B1R", .T.))
				B1R->B1R_FILIAL := xfilial("B1R")
				B1R->B1R_PROTOC := cnumB1R // número do protocolo gerado pelo PLS para comunicação -> tamanho 12 caractere
				B1R->B1R_ORIGEM := oJson['items'][nItem]['healthProviderId'] //código da RDA que fez a soliciação que gerou o protocolo -> tamanho 6 caractere  ---> cCodRDA 	:= oJson['items'][1]['healthProviderId']
				B1R->B1R_PROTOG := oJson['items'][nItem]['batchNumber'] //número do protocolo/transação na origem -> tamanho 12 caractere
				B1R->B1R_HATARQ := oJson['items'][nItem]['azureStorageFilePath'] //campo específico para a integração PLS e HAT, conterá o caminho do arquivo disponibilizado ---> cURL		:= oJson['items'][1]['azureStorageFilePath']
				B1R->B1R_HATTOK := oJson['items'][nItem]['azureStorageSasToken'] //campo específico para a integração PLS e HAT, conterá a parte de validação de acesso pra buscar o arquivo ---> oJson['items'][1]['azureStorageSasToken']
				B1R->B1R_HATTIP := oJson['items'][nItem]['status'] //campo específico para a integração PLS e HAT, conterá o tipo de transação do registro ---> cType		:= oJson['items'][1]['status']
				B1R->B1R_STATUS := '' //campo combo para informar a situação do protocolo, se foi somente Recebido, em processamento, processado acatado, processado crticado
				B1R->(MsUnLock())

				If MontRetHAT(, , , , { B1R->B1R_PROTOC, B1R->B1R_PROTOG, B1R->B1R_ORIGEM}, .T.) //O put deu certo
					B1R->(RecLock("B1R", .F.))
					B1R->B1R_STATUS := '0' //Marca com 0 pro próximo robô enxergar
					B1R->(MsUnLock())
				else
					B1R->(RecLock("B1R", .F.))
					B1R->(Dbdelete()) //delete pq deu ruim, vai vir de novo na nova busca
					B1R->(MsUnLock())
				endif
			next
		Else
			cMsg := "Erro ao fazer parse do lote vindo do HAT:" + cParseError + ". " + cReqData
			FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', cMsg  , 0, 0, {})
		EndIf
	Else
		cMsg := "Erro ao solicitar lote para o HAT:" + oRestClient:getLastError() + ". " + cReqData
		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', cMsg , 0, 0, {})
	endif
	RestArea(aArea)
return lHasNext

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaSUSEP
Retorna o código na ANS da operadora padrão do sistema
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function BuscaSUSEP()

	Local cRet := ''
	Local cCodOpe := PLSINTPAD()

	BA0->(dbSetOrder(1))
	If BA0->(MsSeek(xfilial("BA0")+cCodOpe))
		cRet := BA0->BA0_SUSEP
	endIf

return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVLDDATI
valida se a data de procedimento esta no periodo da internacao

@author    Pablo Alipio
@version   V12
@since     26/07/2019
/*/
function PLSVLDDATI(dDatPro,dDatIni,dDatFim)
	local lRet := .T.

	if !empty(dDatPro) .and. !empty(dDatIni)
		if dDatPro < dDatIni .or. dDatPro > dDatFim
			lRet := .F.
		endif
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} excluiBXX
Exclui registro da BXX oriundo do HAT.
Na sua primeira versão serão excluido somente os lotes NÃO ACATADOS.

@author Lucas Nonato
@since  23/09/2019
@version P12
/*/
static function excluiBXX(cChave)
	local lRet as logical
	local cRet as char
	local cSql as char

	cSql := "SELECT R_E_C_N_O_ Recno FROM "+RetSqlName("BXX")
	cSql += " WHERE BXX_FILIAL	= '" + xFilial("BXX") + "' "
	cSql += " AND BXX_PLSHAT	= '" + cChave + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPBXX',.F.,.T.)

	if TMPBXX->(!eof())
		BXX->(dbgoto(TMPBXX->Recno))
		lRet := PLSMANBXX(/*cCodRda*/,/*cNomArq*/,/*cTipGui*/,/*cLotGui*/,/*nTotEve*/,/*nTotGui*/,/*nVlrTot*/,5/*K_Excluir*/,TMPBXX->Recno,/*lProcOk*/,/*aRet*/)
		if !lRet
			cRet := "Houve um erro na exclusão do lote."
		endif
	endif
	TMPBXX->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} procRecGlo
Aciona o processamento do recurso de glosa
@author Eduardo Bento
@since 29/07/2019
@version P12
/*/
//-------------------------------------------------------------------
function procRecGlo ( cSeqBXX )

	local cDirBkp 	:= ""
	local cRet		:= ""
	local lRemote	:= iif(alltrim(BXX->BXX_CODUSR)=="PLSRECGLOS",.T.,.F.)

	BXX->( DbSetOrder(7) )
	if BXX->( MsSeek( xFilial("BXX") + cSeqBXX ) )

		cDirBkp 	:= PLSMUDSIS( cDirRaiz+"UPLOAD\BACKUP\")
		cCodRDA := BXX->BXX_CODRDA
		cFilesU := allTrim( BXX->BXX_ARQIN )
		aRet := {}

		nTotEve		:= 0
		nTotGui		:= 0
		nValTot		:= 0
		cTipGui		:= "10"
		cLotGui		:= ""
		cTissVer	:= ""

		if File(cDirUpload+cFilesU )

			__CopyFile( cDirUpload+cFilesU , cDirBkp+cFilesU )
			aRet := PLSA973L(cDirUpload+cFilesU ,cCodRda,.T.,.F.,@cTipGui,@cLotGui,@nTotEve,@nTotGui,@nValTot,BXX->BXX_SEQUEN,,@cTissVer)
			cRet := PLSINALUP("", cCodRDA, .T., .F., cDirUpload+cFilesU,aRet)

		endIf

	endif

	if !lRemote
		cRet := "Upload terminado com SUCESSO"
	endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSvHATXML
Integração para verificação se há XML  disponível no HAT e, caos houver, gravar o BXX e buscar o aruqivo .xml
para processamento no PLS
@author Oscar Zanin
@since 03/12/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSvHATXML(lHasNext)
	Local nI			:= 1
	Local cURL			:= ""
	Local cPath			:= ""
	Local oRestClient	:= nil
	Local cChvHAT		:= ''
	Local cDirRaiz		:= PLSMUDSIS( GetNewPar("MV_TISSDIR","\TISS\") )
	Local cDirWeb		:= PLSMUDSIS( cDirRaiz+"UPLOAD\")
	Local cPartArq		:= ""
	Local cFileName		:= ""
	Local cFullName		:= ""
	Local nHandle		:= -1
	Local cCodRDA		:= ""
	Local cType			:= ""
	Local xret			:= ""
	Local lerro			:= .F.

	Default lHasNext	:= .T.

	cSql := " Select * from " + RetsqlName("B1R") + " B1R "
	cSql += " where "
	cSql += " B1R_FILIAL = '" + xFilial("B1R") + "' "
	cSql += " AND B1R_STATUS = '0' "
	cSql += " AND B1R_HATARQ <> ' ' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",TCGENQRY(,,cSql),"TRBHAT",.f.,.t.)

	//criar tabela B1R
	// Definições
	// - Campos
	// B1R_PROTOC -> número do protocolo gerado pelo PLS para comunicação -> tamanho 12 caractere
	// B1R_PROTOI -> número do protocolo interno (CODPEG) -> tamanho 8 caractere
	// B1R_ORIGEM -> código da RDA que fez a solicitação que gerou o protocolo -> tamanho 6 caractere  ---> cCodRDA 	:= oX['items'][1]['healthProviderId']
	// B1R_PROTOG -> número do protocolo/transação na origem -> tamanho 12 caractere
	// B1R_HATARQ -> campo específico para a integração PLS e HAT, conterá o caminho do arquivo disponibilizado ---> cURL		:= oX['items'][1]['azureStorageFilePath']
	// B1R_HATTOK -> campo específico para a integração PLS e HAT, conterá a parte de validação de acesso pra buscar o arquivo ---> oX['items'][1]['azureStorageSasToken']
	// B1R_HATTIP -> campo específico para a integração PLS e HAT, conterá o tipo de transação do registro ---> cType		:= oX['items'][1]['status']
	// B1R_STATUS -> campo para informar a situação do protocolo, se foi somente Recebido, em processamento, processado acatado, processado crticado
	//
	// - Indice
	// B1R_FILIAL + B1R_PROTOC + B1R_ORIGEM  -> chave única
	// B1R_FILIAL + B1R_PROTOG + B1R_ORIGEM
	// B1R_FILIAL + B1R_PROTOI + B1R_ORIGEM

	nQtd := 1
	maxThread := 1
	while !(TRBHAT->(EoF()))
		B1R->(dbGoTo(TRBHAT->R_E_C_N_O_))
		B1R->(recLock("B1R", .F.))
		B1R->B1R_STATUS := '1'
		B1R->(MsUnLock())
		lerro := .F.

		nQtd++

		cCodRDA 	:= TRBHAT->B1R_ORIGEM
		cURL		:= allTrim(TRBHAT->B1R_HATARQ)
		cPath 		:= Alltrim(TRBHAT->B1R_HATTOK)
		cChvHAT		:= allTrim(TRBHAT->B1R_PROTOG)
		cType		:= TRBHAT->B1R_HATTIP

		if cType <> "E"
			oRestClient := FWRest():New(cUrl)
			oRestClient:setPath(cPath)
			oRestClient:Get()

			nI := 0
			while nI < 10 .AND. empTy(oRestClient:GetResult())
				//	Sleep(600)
				oRestClient:Get()
				nI++
			endDo

			if empTy(oRestClient:GetResult())
				xret := 'Não foi possivel pegar o arquivo XML. ' + cURL
				MontRetHAT(, xret, , , { TRBHAT->B1R_PROTOC, cChvHAT, cCodRDA })
				logpls(xret, TRBHAT->B1R_PROTOC, cChvHAT, '2', 'PLSA417')
				B1R->(RecLock("B1R", .F.))
				B1R->B1R_STATUS := "Y"
				B1R->(msUnLock())
				lerro := .T.
			elseif 'PARENTNOTFOUND' $ upper(oRestClient:GetResult())
				xret := '[PARENTNOTFOUND] - Não foi possivel pegar o arquivo XML.'
				MontRetHAT(, xret, , , { TRBHAT->B1R_PROTOC, cChvHAT, cCodRDA })
				logpls(xret, TRBHAT->B1R_PROTOC, cChvHAT, '2', 'PLSA417')
				B1R->(RecLock("B1R", .F.))
				B1R->B1R_STATUS := "Z"
				B1R->(msUnLock())
				lerro := .T.
			else
				// Cria o arquivo
				cPartArq	:= "_" + DtoS(Date())
				cPartArq	+= "_" + cValToChar(int(Seconds()))
				cFileName	:= "_" + getLastItem(TRBHAT->B1R_HATARQ)
				cFullName	:= "IntHat_" + cCodRDA + cPartArq + iif(at(".xml",cFileName) > 0, cFileName, ".xml")
				nHandle		:= FCREATE(cDirWeb + cFullName)

				If nHandle > 0
					Fwrite(nHandle, oRestClient:GetResult())
				endIf
				FCLOSE(nHandle)
				xret := PLSINALUP('PLS_HAT', cCodRDA,.T.,.T.,cDirWeb + cFullName,nil ,cChvHAT )
				B1R->(RecLock("B1R", .F.))
				B1R->B1R_STATUS := "2"
				B1R->(msUnLock())
				logpls(xret, TRBHAT->B1R_PROTOC, cChvHAT, '1', 'PLSA417')
			endif

			if !lerro .AND. !empty(xret) .and. !("SUCESSO" $ upper(xret))
				MontRetHAT(, xret,,, { TRBHAT->B1R_PROTOC, cChvHAT, cCodRDA })
				PLSLogHAT("[PLSxHATXML]healthProviderId: "+ cCodRDA + " batchNumber: " + cChvHAT + " " + xret)
			endif

		else
			excluiBXX(cChvHAT)
		endIf
		TRBHAT->(dbSkip())

	endDo

	TRBHAT->(dbcloseArea())
return xret


//-------------------------------------------------------------------
/*/{Protheus.doc} PLtermVIG..
Verifica a vigência do termo
@author Oscar Zanin
@since 10/12/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLtermVIG(ccodPad, ccodPro, dDatPro)
	Local lret := .F.

	BTQ->(dbSetOrder(1))
	If BTQ->(MsSeek(xfilial("BTQ") + ccodPad + ccodPro))
		lRet := (empTy(BTQ->BTQ_VIGDE) .OR. dDatPro >= BTQ->BTQ_VIGDE) .AND. (empTy(BTQ->BTQ_VIGATE) .OR. dDatPro <= BTQ->BTQ_VIGATE)
	endIf
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getLastItem
Pega o ultimo arquivo
@author PLS TEAM
@since 12/06/2020
@version P12
/*/
static function getLastItem(cString, cToken)
	local aItens := {}
	local cReturn := ""
	local nLenItens := 0
	default cString := ""
	default cToken := "/"

	aItens := StrTokArr2(cString, cToken, .F.)
	nLenItens := len(aItens)
	cReturn := aItens[nLenItens]
	freeArr(@aItens)

return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} freeArr
Limpa array
@author PLS TEAM
@since 12/06/2020
@version P12
/*/
static function freeArr(aArray)
	aSize(aArray,0)
	aArray := Nil
	aArray := {}
return


//-------------------------------------------------------------------
/*/{Protheus.doc} VldX22
Verifica se o CID é valido se nao for entra na critica X22
@author Thiago
@since 04/01/2021
@version P12
/*/
static function VldX22()
	Local cCid := Alltrim(PVLRTAGXML(aDadosUnic, '\DADOSSAIDAINTERNACAO\DIAGNOSTICO'))
	local lret := .F.

	BA9->(dbsetOrder(1))
	lret := BA9->(MsSeek(xfilial("BA9") + cCid + Space(tamSX3("BA9_CODDOE")[1] - Len(cCid)),.T.))

return lret

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsDtExec
Verifica inconsistências nas datas de solicitação e execução do procedimento.
Verifica data de solicitação através da senha
Observação: nRECNOAUT e DDATPRO são variáveis BVP
@author Eduardo Bento
@since 05/01/2021
/*/
function PlsDtExec()

	local lOk 		:= .T.

	//nRECNOAUT é BVP usado para validação da autorização pela senha
	if nRECNOAUT == 0
		return .T.
	endif
	BEA->(dbGoTo(nRECNOAUT))

	//Comparo se a data enviada no XML é posterior ou igual a data da autorização
	lOk := dDATPRO >= BEA->BEA_DATPRO

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsDtExFtr
Verifica se a data de execução está de acordo com o intervalo de faturamento
@author Eduardo Bento
@since 08/02/2021
/*/
function PlsDtExFtr() 

	local lOk 		:= .T.

	//Comparo se a data é menor que a data início de faturamento ou maior que a fim
	if dDATPRO < dFATINI .or. dDATPRO > dFATFIM
		lOk := .F.
	endif

Return lOk

/*/{Protheus.doc} PLVALUNIT
Utilizada pela critica X70
@type function
@author TOTVS
@since 29/09/2022
@version 1.0
/*/
Function PLVALNZER(cValUnit)
	Local lRet		:= .T.

	If val(cValUnit) <= 0
		lRet := .F.
	EndIf
Return lRet
