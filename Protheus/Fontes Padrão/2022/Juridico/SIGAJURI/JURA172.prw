#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA172.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA172
Faz as importações de Publicações 

@author  André Spirigoni Pinto
@since 	 10/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA172(aCodCab)
Local lXML     := ""
Local lTOTVS   := .F.
Local lBaixa   := .T.
Local cLogin   := Nil
Local cEmpImp  := ""
Local cFilImp  := ""
Local cUser    := ""
Local aFiliais := {}

Default aCodCab := { Nil/*cLogin*/, '99', '01', '000000', '000004000001' }

	//valida o parâmetro recebido do schedule. Se for menor que 5, nenhum login foi informado, deve-se então usar o parãmetro de login da Kurier.
	if len(aCodCab) < 5
		cEmpImp := aCodCab[1]
		cFilImp := aCodCab[2]
		cUser   := aCodCab[3]
	else
		cLogin  := aCodCab[1]
		cEmpImp := aCodCab[2]
		cFilImp := aCodCab[3]
		cUser   := aCodCab[4]
		lBaixa  := aCodCab[5] != 'TESTE'
	Endif

	//Normalmente utiliza-se RPCSetType(3) para informar ao Server que a RPC não consumirá licenças
	RpcSetType(3)
	RPCSetEnv( cEmpImp, cFilImp, , , ,"JURA172")

	Private __CUSERID := cUser

	aFiliais := JURFILUSR( cUser, "NSZ" )
	lTOTVS 	 := SuperGetMV('MV_JPUBTOT',, '2') == '1'

	//Publicações via TOTVS
	if lTOTVS
		J172TOTVS(lBaixa,aFiliais,cUser)

	//Publicações via KURIER
	Else
		lXML := SuperGetMV('MV_JKURXML',, '2') == '1' //indica se a integração com a KURIER é via banco de dados ou eles mandam o XML pelo WebService

		If !lXML
			J172PrBase()
		Else
			While J172PrXML(,cLogin/*cLogin*/,aFiliais) //a Kurier limita em 50 as publicações. Então, executar enquanto houver publicações
				Sleep(1000)
			End
		Endif
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA172b()
Faz as importações de Distribuições

@author  Rafael Tenorio da Costa
@since 	 10/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA172b(aParams)

	Local lManual 	:= ( aParams == Nil )
	Local cLogin  	:= ""
	Local cEmpImp 	:= ""
	Local cFilImp 	:= ""
	Local lContinua	:= .F.
	Local cPwd		:= ""
	Local cEndPoint	:= ""
	Local cTipoDis	:= ""
	Local lTeste    := .F.

	If lManual
		lContinua := .T.
	Else

		VarInfo(STR0008 + "[aParams]", aParams)		//"Parâmetros do schedule de importação de distribuições: "

		If Len(aParams) >= 3
			lContinua	:= .T.
			cLogin  	:= aParams[1]
			cEmpImp		:= aParams[2]
			cFilImp 	:= aParams[3]
			cPwd  		:= aParams[4]
			cEndPoint	:= aParams[5]
			lTeste  	:= aParams[6]

			//Normalmente utiliza-se RPCSetType(3) para informar ao Server que a RPC não consumirá licenças
			RpcSetType(3)
			RPCSetEnv( cEmpImp, cFilImp, , , ,"JURA172b")
		Else

			JurConOut(STR0007, {JurTimeStamp()})	//"#1 - Aviso: Não foram passados corretamente os parâmetros para importação de distribuições."
		EndIf

	EndIf

	If lContinua

		cTipoDis := SuperGetMV('MV_JDISTOT', , '2')

		//Pega o usuario da distribuição do parâmetro caso não tenha sido passado
		If Empty(cLogin)
			cLogin := AllTrim( SuperGetMv("MV_JDISUSR", .T., "") )
		EndIf

		//Verifica se qual serviço de Distribuição está ativo. (1=Totvs, 2=Kurier, 3=Oito)
		Do Case

			//Distribuição da Totvs\Solucionari
			Case cTipoDis == '1'
				J172DisTot(lTeste)

			//Distribuição da Kurier
	     	Case cTipoDis == '2'
	     		While J172BxDis(cLogin)
	     			Sleep(1000)
			    End

			//Distribuição da Oito
	   		Case cTipoDis == '3'

	   			J172DisOito(cLogin, cPwd, cEndPoint, lTeste)

	     	OTherWise
	     		JurConOut(STR0024, {JurTimeStamp()})	//"# - Aviso: Valor inválido no parâmetro 'MV_JDISTOT' "
	    End Case

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J172CodSeq
Funcao para pegar o proximo código de sequência que deve ser utilizado
para a gravação do campo NR0_CODSEQ

@author André Spirigoni Pinto
@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J172CodSeq()
Local nRet     := 1
Local aArea    := GetArea()
Local cQry     := GetNextAlias()

BeginSql Alias cQry
		SELECT MAX(NR0_CODSEQ) NR0_CODSEQ
		FROM %Table:NR0% NR0
		WHERE NR0.NR0_CODIMP	= '    '
		AND NR0.NR0_FILIAL  = %xFilial:NR0%
		AND NR0.%notDEL%
EndSql
dbSelectArea(cQry)

While !(cQry)->( EOF() )
	nRet := val((cQry)->NR0_CODSEQ)
	(cQry)->( dbSkip() )
End

(cQry)->( dbCloseArea() )

RestArea( aArea )

Return nRet+1

//-------------------------------------------------------------------
/*/{Protheus.doc} J172GetValor(oObj, cTag, cTipo)
Função para retornar o valor da tag informada caso ela exista no XML.

@param oObj Objeto onde existem as propriedades que foram lidas do Web Service
@param cTag Nome da tag que está sendo procurada
@param cTipo Tipo da informação que deve ser retornada

@return oObj Informação de retorno, que acompanhará o tipo informado no campo cTipo

@author André Spirigoni Pinto
@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J172GetValor(oObj, cTag, cTipo)
Local oRet    := ''
Local nChave	  := 0
Local aTmpD   := {}

aTmpD := ClassDataArr(oObj)

//valida se o tipo de variável do array é um objeto e se a tag recebida existe no Xml.
If (nChave := aScan( aTmpD, { | x |  valType(x[2]) == 'O' .And. x[2]:REALNAME == cTag } )) > 0
	oRet := J172TrVal(aTmpD[nChave][2]:Text, cTipo)
Endif

//limpa o array
aSize(aTmpD,0)

Return oRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172PrBase()
Função que le o Web Service que manda informações encontradas na base de dados do cliente


@return oObj Informação de retorno, que acompanhará o tipo informado no campo cTipo

@author André Spirigoni Pinto
@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J172PrBase()
Local oWS
Local aDados    := {}
Local oDados
Local nCt       := 0
Local lRet      := .T.
Local nCodSeq   := 0
Local cSituac
Local cSvcError := ''

oWS      := TJurWSKurier():New()
nCodSeq  := J172CodSeq()

oWS:cLogin := SuperGetMv('MV_JKUSER',.T.,"")
oWS:cSenha := SuperGetMv('MV_JKPASS',.T.,"")

oWS:RecuperarPublicacao()

//valida se houve retorno do web service
If oWS:oWSRecuperarPublicacaoResult != Nil
	aDados := oWS:oWSRecuperarPublicacaoResult:_RECUPERARPUBLICACAORESULT:_DIFFGR_DIFFGRAM:_NewDataset:_table
Else

	cSvcError   := GetWSCError()  // Resumo do erro

	JA215SetLog(STR0004 + Iif(Empty(cSvcError),'', CRLF + CRLF + cSvcError), oWS:cLogin, Time()) //"Erro ao capturar publicação da kurier"

	lRet := .F.
	JurConOut(STR0001,{JurTimeStamp()}) //"#1 - Aviso: Nenhuma publicação retornada da Kurier."
Endif

If ValType(aDados) == "O"
	oDados := aDados
	aDados := { oDados }
EndIf

//Varre os itens recebidos da Kurier e inclui na NR0.
For nCt := 1 To len(aDados)

	RecLock("NR0",.T.)

	NR0->NR0_FILIAL := xFilial("NR0")
	NR0->NR0_CODIMP := '    '
	NR0->NR0_CODSEQ := StrZero(nCodSeq,TamSX3('NR0_CODSEQ')[1])
	NR0->NR0_DTPUBL := J172GetValor(aDados[nCt], 'NWQ_DTPUBL', TamSX3('NR0_DTPUBL')[3])
	NR0->NR0_FILPRO := J172GetValor(aDados[nCt], 'NWQ_FILIAL', TamSX3('NR0_FILPRO')[3])	//replica 11.8
	NR0->NR0_CAJURI := J172GetValor(aDados[nCt], 'NWQ_CAJURI', TamSX3('NR0_CAJURI')[3])
	NR0->NR0_NUMPRO := J172GetValor(aDados[nCt], 'NWQ_NUMPRO', TamSX3('NR0_NUMPRO')[3])
	NR0->NR0_TEORPB := J172GetValor(aDados[nCt], 'NWQ_TEXTO', TamSX3('NR0_TEORPB')[3])
	NR0->NR0_CAJURP := J172GetValor(aDados[nCt], 'NWQ_PROCPROVAVEL', TamSX3('NR0_CAJURP')[3])
	NR0->NR0_OBS    := J172GetValor(aDados[nCt], 'NWQ_OBSER', TamSX3('NR0_OBS')[3])
	NR0->NR0_CCLIEN := J172GetValor(aDados[nCt], 'NWQ_CCLIEN', TamSX3('NR0_CCLIEN')[3])
	NR0->NR0_DCLIEN := J172GetValor(aDados[nCt], 'NWQ_DCLIEN', TamSX3('NR0_DCLIEN')[3])
	NR0->NR0_PROCO  := J172GetValor(aDados[nCt], 'NWQ_PROCO', TamSX3('NR0_PROCO')[3])
	NR0->NR0_DADVOG := J172GetValor(aDados[nCt], 'NWQ_DADVOG', TamSX3('NR0_DADVOG')[3])
	NR0->NR0_NOMEPC := J172GetValor(aDados[nCt], 'NWQ_NOMEPC', TamSX3('NR0_NOMEPC')[3])
	NR0->NR0_DADVPC := J172GetValor(aDados[nCt], 'NWQ_DADVPC', TamSX3('NR0_DADVPC')[3])
	NR0->NR0_NOMEPI := J172GetValor(aDados[nCt], 'NWQ_NOMEPI', TamSX3('NR0_NOMEPI')[3])
	NR0->NR0_FONTE  := J172GetValor(aDados[nCt], 'NWQ_FONTE', TamSX3('NR0_FONTE')[3])
	NR0->NR0_DTCHEG := Date()
	NR0->NR0_SIGLA := J172GetValor(aDados[nCt], 'NWQ_SIGLA_ADVG', TamSX3('NR0_SIGLA')[3])

	//define o status como provável ou localizada.
	If Empty(NR0->NR0_CAJURP)
		cSituac := '1'
	Else
		cSituac := '6'
	Endif

	NR0->NR0_SITUAC := cSituac

	NR0->(MsUnlock())

	nCodSeq := nCodSeq + 1

	oWs:cIdCliente	:= J172GetValor(aDados[nCt], "NWQ_CCLIENKURIER", 'C')
	oWs:cCodigo		:= J172GetValor(aDados[nCt], "NWQ_CODIGO", 'C')
	oWs:cIdProcesso	:= J172GetValor(aDados[nCt], 'NWQ_CAJURI', TamSX3('NR0_CAJURI')[3])
	oWS:cLogin 		:= SuperGetMv('MV_JKUSER',.T.,"")
	oWS:cSenha 		:= SuperGetMv('MV_JKPASS',.T.,"")
	oWs:AtualizarPublicacaoEnviadaConfirmacao_Cliente()

	//valida se houve retorno do web service
	If oWS:lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult != Nil .and. !oWS:lAtualizarPublicacaoEnviadaConfirmacao_ClienteResult
		cSvcError   := GetWSCError()  // Resumo do erro
		JA215SetLog(STR0003 + CRLF + "Publicação ref. ao processo "+NR0->NR0_NUMPRO+" não foi confirmado o recebimento." + Iif(Empty(cSvcError),'', CRLF + CRLF + cSvcError), oWS:cLogin, Time()) // "Erro ao confirmar publicação da kurier"
		Conout("Publicação ref. ao processo "+NR0->NR0_NUMPRO+" não foi confirmado o recebimento.")
	EndIf

Next

If lRet
	JurConOut(STR0002,{JurTimeStamp(),len(aDados)}) //"#1 - Aviso: Foram importadas #2 publicações da Kurier."
	JA215SetLog(STR0009 + Str(len(aDados)) + STR0010, oWS:cLogin, Time()) // "Foram importadas"	... "publicações da Kurier."
Endif

aSize(aDados,0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172PrXML()
Função que le o Web Service que manda informações encontradas na base de dados do cliente

@param lBaixa indica se deve dar baixa após baixar sa publicações
@param nIdPub Parâmetro que indica o recebimento do id da publicação específica que deve
ser retornada. Se for informado 0, se mantém o comportamento padrão

@return oObj Informação de retorno, que acompanhará o tipo informado no campo cTipo

@author André Spirigoni Pinto
@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172PrXML(lBaixa, cLogin, aFiliais)
	Local oWS
	Local aDados         := {}
	Local oDados
	Local nCt            := 0
	Local lRet           := .T.
	Local cEstado        := ''
	Local cCodigo        := ''
	Local cNome          := ''
	Local cOrgao         := ''
	Local cPagina        := ''
	Local cProcesso      := ''
	Local cTexto         := ''
	Local cVara          := ''
	Local cCodRel        := ''
	Local cDiario        := ''
	Local nCodDiario     := 0
	Local nCodDivDiar    := 0
	Local nCodTermPesq   := 0
	Local cSvcError      := ''
	Local aDadXML        := {}
	Local nRet
	Local nQtd           := 0
	Local aBxPubl        := {}

	Default lBaixa       := .T.
	Default cLogin       := SuperGetMv('MV_JKUSER',.T.,"")

	//Atualiza tabela NZP
	AtuNZP("1", cLogin)

	//Trava a execução do login atual para evitar que mais de uma sessão faça a importação de publicações.
	if !LockByName("J172PrXML_" + cLogin,.T.,.T.)
		Return .F. //valida se pode executar ou se existe outra execução para o mesmo login
	Endif

	oWS        := JURA211():New()
	oWS:cLogin := cLogin
	oWS:CapturarPublicacoes()

	//valida se houve retorno do web service
	If oWS:oWSCapturarPublicacoesResult != Nil

		If XmlChildCount(oWS:oWSCapturarPublicacoesResult:_CAPTURARPUBLICACOESRESULT:_DIFFGR_DIFFGRAM:_CAPITALLOGIN) = 3
			aDados := oWS:oWSCapturarPublicacoesResult:_CAPTURARPUBLICACOESRESULT:_DIFFGR_DIFFGRAM:_CAPITALLOGIN:_PUBLICACOES
		Else
			lRet := .F.
			JurConOut(STR0001,{JurTimeStamp() + " ("+cLogin+")" }) //"#1 - Aviso: Nenhuma publicação retornada da Kurier."
			JA215SetLog(STR0011, cLogin, Time()) //Aviso: Nenhuma publicação retornada da Kurier.
		EndIf
	Else

		cSvcError   := GetWSCError()  // Resumo do erro

		JA215SetLog(STR0004 + Iif(Empty(cSvcError),'', CRLF + CRLF + cSvcError), cLogin, Time()) //"Erro ao capturar publicação da kurier"
		lRet := .F.
		JurConOut(STR0001,{JurTimeStamp() + " ("+cLogin+")" }) //"#1 - Aviso: Nenhuma publicação retornada da Kurier."

	Endif

	If lRet
		If ValType(aDados) == "O"
			oDados := aDados
			aDados := { oDados }
		EndIf

		//Varre os itens recebidos da Kurier e inclui na NR0.
		For nCt := 1 To len(aDados)

			cCodigo               := J172GetValor(aDados[nCt], 'Codigo', "C")
			dData                 := J172GetValor(aDados[nCt], 'Data', "D")
			cCodRel               := J172GetValor(aDados[nCt], 'idProcesso', "C")
			cNome                 := J172GetValor(aDados[nCt], 'Nome', "C")
			cProcesso             := J172GetValor(aDados[nCt], 'Processo', "C")
			cPagina               := J172GetValor(aDados[nCt], 'Pagina', "C")
			cDiario               := J172GetValor(aDados[nCt], 'Diario', "C")
			cTexto                := J172GetValor(aDados[nCt], 'Texto', "C")
			cVara                 := J172GetValor(aDados[nCt], 'Vara', "C")
			cOrgao                := J172GetValor(aDados[nCt], 'Forum', "C")
			cEstado               := J172GetValor(aDados[nCt], 'Estado', "C")
			nCodDiario            := J172GetValor(aDados[nCt], 'CodigoDiario', "N")
			nCodDivDiar           := J172GetValor(aDados[nCt], 'CodigoDivisaoDiario', "N")
			nCodTermPesq          := J172GetValor(aDados[nCt], 'CodigoTermoPesquisa', "N")

			//valida se a publicação ja existe
			if 	J172ExtNR0(cCodigo, cLogin)>0
				if (lBaixa)
					aAdd(aBxPubl,{cCodigo,nCodDiario,nCodDivDiar,nCodTermPesq,J172GetValor(aDados[nCt], 'Data', "C")})
				Endif

				Loop //Pula para o próximo item
			Endif

			aAdd(aDadXML,{cCodigo,dData," ",cProcesso,cTexto," ",cCodigo,CtoD("//")," ",cCodigo,cNome,cPagina,cDiario,"",cOrgao,cEstado,cVara,cLogin})

			//Processa as publicações
			nRet := J20ProcXML(aDadXML,,,,.T.,0,,aFiliais)

			//Limpa o array
			aSize(aDadXML,0)

			//valida se a publicação foi importada com sucesso
			if (nRet==1)
				nQtd := nQtd + 1

				if (lBaixa)
					aAdd(aBxPubl,{cCodigo,nCodDiario,nCodDivDiar,nCodTermPesq,J172GetValor(aDados[nCt], 'Data', "C")})
				Endif
			Endif

			//limpa os dados utilizados.
			FwFreeObj(aDados[nCt])

		Next
		//Valida Importação ou Baixa da Publicação
		J211AtuPub(aBxPubl)
		JurConOut(STR0002,{(JurTimeStamp() + " ("+cLogin+")"),nQtd}) //"#1 - Aviso: Foram importadas #2 publicações da Kurier."
		JA215SetLog(STR0009 + Str(nQtd) + STR0010, cLogin, Time()) // "Foram importadas"	... "publicações da Kurier."
	Endif

	//limpa array
	aSize(aDadXML,0)
	aSize(aBxPubl,0)
	cTexto := ""
	FwFreeObj(aDados)
	FwFreeObj(oWS:oXmlRet)
	FwFreeObj(oWS)

	//Libera a execução do login
	UnLockByName("J172PrXML_" + cLogin,.T.,.T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172ExtNR0
Função para validar se ja existe a publicação baixada na tabela NR0.

@author André Spirigoni Pinto
@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J172ExtNR0(cCodigo,cLogin)
Local nRet 	:= 0
Local cSql		:= ''
Local cLista  := GetNextAlias()

Default cLogin := ""

cSQL := "SELECT COUNT(*) QTD"
cSql += " FROM "+RetSqlName("NR0")+" NR0 " + CRLF
cSql += " WHERE NR0_FILIAL = '"+ xFilial("NR0")+"'" + CRLF
cSql += " AND NR0.D_E_L_E_T_ = ' ' " + CRLF
cSQL += " AND NR0.NR0_CODIMP = '" + PadL("",TamSX3("NR0_CODIMP")[1]) + "'" + CRLF
cSQL += " AND NR0.NR0_CODREL = '" + cCodigo + "'" + CRLF

if !Empty(cLogin) .And. FWAliasInDic("NZP")
	cSQL += " AND NR0.NR0_LOGIN = '" + cLogin + "'" + CRLF
Endif

cSQL := ChangeQuery(cSQL)

dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

If !(cLista)->( EOF() )
	While !(cLista)->( EOF() )
		nRet := (cLista)->QTD
		(cLista)->( dbSkip() )
	End
EndIf

(cLista)->( dbcloseArea() )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J172CorNum
Função para adequar a numeração de publicações da Kurier, quando usado
GetSxeNum para o campo NR0_CODSEQ.

@author André Spirigoni Pinto
@since 02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172CorNum(nNum)

While val(GetSxeNum("NR0","NR0_CODSEQ")) < nNum
	ConfirmSX8()
End

Return "OK"

//-------------------------------------------------------------------
/*/{Protheus.doc} J172mexec
Função para baixar as publicações da Kurier de forma manual, usando os
mesmos parâmetros do Schedule.

aCodCab := { cLogin,'T1', 'D MG 01 ', '000000', { '000001', 'T1', 'D MG 01 ' } }

@author André Spirigoni Pinto
@since 02/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172mexec(aCodCab, lBaixa)
Local lXML := ""

Default lBaixa := .T.

lXML := SuperGetMV('MV_JKURXML',, '2') == '1' //indica se a integração com a KURIER é via banco de dados ou eles mandam o XML pelo WebService

If !lXML
	J172PrBase()
else
	While J172PrXML(lBaixa,aCodCab[1]/*cLogin*/) //a Kurier limita em 50 as publicações. Então, executar enquanto houver publicações
		Sleep(1000)
	End
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNZP
Função para atualizar\criar registros na tabela NZP.

@param	cTipo 	- Indica o tipo de login 1=Publicação, 2=Distribuição, 3=Todos
@param	cLogin 	- Indica o login
@author Rafael Tenorio da Costa
@since 	16/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuNZP(cTipo, cLogin)

	Local aArea 	:= GetArea()

	If FWAliasInDic("NZP")

	 	DbSelectArea("NZP")
	 	NZP->( DbSetOrder(1) )	//NZP_FILIAL+NZP_LOGIN
	 	If NZP->( DbSeek(xFilial("NZP") + cLogin) )

	 		While !NZP->( Eof() ) .And. NZP->NZP_LOGIN == cLogin

	 			If NZP->NZP_TIPO <> cTipo
	 				NZP->NZP_TIPO := "3"	//3=Todos
	 			EndIf

	 			NZP->( DbSkip() )
	 		EndDo
		Else

			Reclock("NZP", .T.)
				NZP->NZP_FILIAL := xFilial("NZP")
				NZP->NZP_LOGIN	:= cLogin
				NZP->NZP_TIPO 	:= cTipo
			NZP->( MsUnlock() )
		EndIf
	Endif

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J172BxDis()
Função que le o WebService da Kurier que manda as distribuicoes.

@return lRet - Define se foram feitas as baixas das distribuições.

@author  Rafael Tenorio da Costa
@since 	 17/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172BxDis(cLoginDis)

	Local oWS		:= Nil
	Local aDados    := {}
	Local oDados	:= Nil
	Local nCt       := 0
	Local lRet      := .T.
	Local dDtDistri	:= CtoD("")
	Local cTermo    := ""
	Local cTribunal := ""
	Local cProcesso := ""
	Local cTipoOcor := ""
	Local cReu	    := ""
	Local cAutor	:= ""
	Local cForum	:= ""
	Local cVara     := ""
	Local cCidade   := ""
	Local cUF 	    := ""
	Local nVlrOcorr := 0
	Local cAdvAutor := ""
	Local aDadosRet := {}
	Local aDadosNZZ := {}
	Local aAux		:= {}

	Default cLoginDis	:= SuperGetMv("MV_JDISUSR", .T., "")

	cLoginDis := AllTrim(cLoginDis)

	//Atualiza tabela NZP
	AtuNZP("2", cLoginDis)

	//Trava a execução do login atual para evitar que mais de uma sessão faça a importação de publicações.
	if !LockByName("J172BxDis_" + cLoginDis, .T., .T.)
		Return .F. //valida se pode executar ou se existe outra execução para o mesmo login
	Endif

	oWS        := JURA220():New()
	oWS:clogin := cLoginDis
	If oWS:RecuperarNovaDistribuicao()

		//Valida se houve retorno do web service
		If oWS:oWSRecuperarNovaDistribuicaoResult:_RECUPERARNOVADISTRIBUICAORESULT:_DIFFGR_DIFFGRAM:_NEWDATASET <> Nil

			If Len( oWS:oWSRecuperarNovaDistribuicaoResult:_RECUPERARNOVADISTRIBUICAORESULT:_DIFFGR_DIFFGRAM:_NEWDATASET:_TABLE ) > 0
				aDados := oWS:oWSRecuperarNovaDistribuicaoResult:_RECUPERARNOVADISTRIBUICAORESULT:_DIFFGR_DIFFGRAM:_NEWDATASET:_TABLE
			Else
				lRet := .F.
				JurConOut(STR0005, {JurTimeStamp() + " ("+cLoginDis+")" }) //"#1 - Aviso: Nenhuma distribuição retornada da Kurier."
				JA215SetLog(STR0005, cLoginDis, Time())
			EndIf
		Else
			lRet := .F.
			JurConOut(STR0005,{JurTimeStamp() + " ("+cLoginDis+")" }) //""#1 - Aviso: Nenhuma distribuição retornada da Kurier."
			JA215SetLog(STR0005, cLoginDis, Time())
		Endif

		//Processa distribuições
		If lRet

			If ValType(aDados) == "O"
				oDados := aDados
				aDados := { oDados }
			EndIf

			//Varre os itens recebidos da Kurier e inclui na NZZ
			For nCt := 1 To len(aDados)

				//Carrega dados
				cEscrito	:= J172GetValor(aDados[nCt], "Escritorio"		, "C")
				dDtDistri	:= J172GetValor(aDados[nCt], "DataDistribuicao"	, "D")
				cTermo    	:= J172GetValor(aDados[nCt], "Termo"			, "C")
				cTribunal 	:= J172GetValor(aDados[nCt], "Tribunal"			, "C")
				cProcesso	:= J172GetValor(aDados[nCt], "NumeroProcesso"	, "C")
				cTipoOcor 	:= J172GetValor(aDados[nCt], "TipoOcorrencia"	, "C")
				cReu	    := J172GetValor(aDados[nCt], "Reu"				, "C")
				cAutor		:= J172GetValor(aDados[nCt], "Autor"			, "C")
				cForum		:= J172GetValor(aDados[nCt], "DescricaoForum"	, "C")
				cVara		:= J172GetValor(aDados[nCt], "DescricaoVara"	, "C")
				cCidade   	:= J172GetValor(aDados[nCt], "Cidade"			, "C")
				cUF 	    := J172GetValor(aDados[nCt], "UF"				, "C")
				nVlrOcorr 	:= J172GetValor(aDados[nCt], "ValorOcorrencia"	, "N")
				cAdvAutor 	:= J172GetValor(aDados[nCt], "AdvogadoAutor"	, "C")

				//Carrega registro para ser enviado como retorno ao webservice da kurier
				aAux := {}
				Aadd(aAux, {"Escritorio" 		, cEscrito 				} )
				Aadd(aAux, {"DataDistribuicao"	, DtoC(dDtDistri)		} )
				Aadd(aAux, {"Termo"				, cTermo   				} )
				Aadd(aAux, {"Tribunal"			, cTribunal				} )
				Aadd(aAux, {"NumeroProcesso"	, cProcesso				} )
				Aadd(aAux, {"TipoOcorrencia"	, cTipoOcor				} )
				Aadd(aAux, {"Reu"   			, cReu     				} )
				Aadd(aAux, {"Autor" 			, cAutor   				} )
				Aadd(aAux, {"DescricaoForum" 	, cForum   				} )
				Aadd(aAux, {"DescricaoVara"  	, cVara    				} )
				Aadd(aAux, {"Cidade"			, cCidade  				} )
				Aadd(aAux, {"UF"				, cUF      				} )
				Aadd(aAux, {"ValorOcorrencia" 	, cValToChar(nVlrOcorr)	} )
				Aadd(aAux, {"AdvogadoAutor"		, cAdvAutor				} )

				Aadd(aDadosRet, aClone(aAux))

				//Carrega dados que ainda não existem para gravar na tabela NZZ
				aAux := {}
				Aadd(aAux, {"NZZ_LOGIN" , cLoginDis} )
				Aadd(aAux, {"NZZ_ESCRI" , cEscrito } )
				Aadd(aAux, {"NZZ_DTDIST", dDtDistri} )
				Aadd(aAux, {"NZZ_TERMO" , cTermo   } )
				Aadd(aAux, {"NZZ_TRIBUN", cTribunal} )
				Aadd(aAux, {"NZZ_NUMPRO", AllTrim(cProcesso)} )
				Aadd(aAux, {"NZZ_OCORRE", cTipoOcor} )
				Aadd(aAux, {"NZZ_REU"   , cReu     } )
				Aadd(aAux, {"NZZ_AUTOR" , cAutor   } )
				Aadd(aAux, {"NZZ_FORUM" , cForum   } )
				Aadd(aAux, {"NZZ_VARA"  , cVara    } )
				Aadd(aAux, {"NZZ_CIDADE", cCidade  } )
				Aadd(aAux, {"NZZ_ESTADO", cUF      } )
				Aadd(aAux, {"NZZ_VALOR" , nVlrOcorr} )
				Aadd(aAux, {"NZZ_ADVOGA", cAdvAutor} )

				Aadd(aDadosNZZ, aClone(aAux))

				//limpa os dados utilizados.
				FwFreeObj(aDados[nCt])
			Next nCt

			//Grava as distribuicoes
			If Len(aDadosNZZ) > 0
				GravaDis(aDadosNZZ)
			EndIf

			//Confirma recebimento das distribuicoes para a kurier
			If Len(aDadosRet) > 0
				J220CfmDis(cLoginDis, aDadosRet)
			EndIf
		Endif
	Else
		lRet := .F.
	EndIf

	//Limpa arrays
	Asize(aAux, 0)
	Asize(aDadosRet, 0)
	Asize(aDadosNZZ, 0)

	FwFreeObj(aDados)
	FwFreeObj(oWS)

	//Libera a execução do login
	UnLockByName("J172BxDis_" + cLoginDis,.T.,.T.)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDis()
Faz a gravação das distribuições (NZZ)

@author  Rafael Tenorio da Costa
@since 	 20/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function GravaDis(aDadosNZZ)

	Local aArea     := GetArea()
	Local nRegistro := 0
	Local nCampos   := 0
	Local nPosLogin	:= Ascan(aDadosNZZ[1], {|x| x[1] == "NZZ_LOGIN"} )
	Local nPosNumPro:= Ascan(aDadosNZZ[1], {|x| x[1] == "NZZ_NUMPRO"})
	Local cLoginDis := ""
	Local cProcesso := ""
	Local nImporta  := 0
	Local getDate   := DTOS(Date())
	Local cDtReceb  := substr(getDate,7,2) + "/" + substr(getDate,5,2) + "/" + substr(getDate,1,4)
	Local nUsr      := 1
	Local aUsrNotif := {}

	DbSelectArea("NZZ")
	NZZ->( DbSetOrder(3) )	//NZZ_FILIAL + NZZ_LOGIN + NZZ_NUMPRO

	For nRegistro:=1 To Len(aDadosNZZ)

		cLoginDis := aDadosNZZ[nRegistro][nPosLogin][2]
		cProcesso := aDadosNZZ[nRegistro][nPosNumPro][2]

		//Verifica se ja existe o registro
		NZZ->( DbSetOrder(3) )	//NZZ_FILIAL + NZZ_LOGIN + NZZ_NUMPRO
		If !NZZ->( DbSeek(xFilial("NZZ") + PadR(cLoginDis, TamSx3("NZZ_LOGIN")[1]) + PadR(cProcesso, TamSx3("NZZ_NUMPRO")[1])) )

			Begin Transaction
				RecLock("NZZ", .T.)

					NZZ-> NZZ_FILIAL :=	xFilial("NZZ")
					NZZ-> NZZ_COD    := CriaVar("NZZ_COD", .T.)
					NZZ-> NZZ_STATUS :=	"1"						//1=Recebido
					NZZ-> NZZ_DTREC  := dDataBase

					For nCampos:=1 To Len(aDadosNZZ[nRegistro])
						If ColumnPos(aDadosNZZ[nRegistro][nCampos][1]) > 0
							If ValType( aDadosNZZ[nRegistro][nCampos][2] ) == "C" .And. !( aDadosNZZ[nRegistro][nCampos][1] $ "NZZ_LOGIN|NZZ_LINK" )
								NZZ->&(aDadosNZZ[nRegistro][nCampos][1]) := Upper( aDadosNZZ[nRegistro][nCampos][2] )
							Else
								NZZ->&(aDadosNZZ[nRegistro][nCampos][1]) := aDadosNZZ[nRegistro][nCampos][2]
							EndIf
						EndIf
					Next nCampos

				NZZ->( MsUnLock() )
				ConfirmSX8()
			End Transaction

			nImporta := nImporta + 1
		Endif

	Next nRegistro

	If nImporta > 0
		JurConOut(STR0006, {(JurTimeStamp() + " ("+cLoginDis+")"), nImporta}) //"#1 - Aviso: Foram importadas #2 distribuções."
		JA215SetLog(STR0012 + Str(nImporta) + STR0013, cLoginDis, Time())  //"Aviso: Foram importadas " //" distribuções."
		If FWAliasInDic("O12") //Gravação de notificações Totvs Jurídico
			aUsrNotif := GetUsrGrp()
			For nUsr := 1 To Len(aUsrNotif)
				If NotifDistr(aUsrNotif[nUsr][1]) // Busca as preferencias dos usuários sobre notificações de distribuicoes recebidas
					JA280Notify(;
						I18N(STR0027, {cValToChar(QtdDistrRec()),cDtReceb}) ,; // "Foram recebidas #1 distribuições no dia #2",;
						aUsrNotif[nUsr][1]                                  ,;
						"notification"                                      ,;
						"1"                                                 ,;
						"JURA172"                                           ,;
						""                                                  ,;
						.T.                                                 ;
					)
				EndIf
				
			Next nUsr
		EndIf
	EndIf

	RestArea( aArea )

Return (nImporta >= Len(aDadosNZZ))

//-------------------------------------------------------------------
/*/{Protheus.doc} J172PrVIS
Função que recebe as publicações e faz a importação das mesmas

@param lBaixa indica se deve dar baixa após baixar sa publicações
@param cNomeRel Indica o nome que deve ser usado para baixar as publicações
@param cToken indica a senha que deve ser utilizada
@param cGrupo indica o código do grupo que deve ser utilizado
@param cData1 indica a data inicial de consulta
@param cData2 indica a data final de consulta
@param cUrl indica a url do serviço

@return lRet Retorna se as publicações foram baixadas com sucesso e se o processo deve continuar

@author André Spirigoni Pinto
@since 29/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172PrVIS(lBaixa, cNomeRel, cToken, cGrupo, cData1, cData2, cUrl, cAgrupa, aFiliais)
Local oXml       := NIl
Local lRet       := .T.

Default lBaixa := .T.
Default aFiliais := Nil

//Atualiza tabela NZP
AtuNZP("1", cAgrupa)

//Trava a execução do login atual para evitar que mais de uma sessão faça a importação de publicações.
if !LockByName("J172PrVIS_" + cAgrupa,.T.,.T.)
	Return .F. //valida se pode executar ou se existe outra execução para o mesmo login
Endif

oXml := J227Captura(cNomeRel, cToken, cGrupo,cData1,cData2,cUrl,.F./*lEnvBaixa*/)

lRet:= J172ImpPub(oXml,lBaixa,cAgrupa,aFiliais, cNomeRel, cToken, cUrl)

//Libera a execução do login
UnLockByName("J172PrVIS_" + cAgrupa,.T.,.T.)

If !lBaixa
	lRet := lBaixa
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172TOTVS
Função que conecta na totvs para receber as informações de publicações.

@param lBaixa indica se deve dar baixa após baixar sa publicações
@param aFiliais Limita a busca de processos para processar as publicações
@param cUser indica o usuário para processamento das publicações

@return lRet Retorna se as publicações foram baixadas com sucesso e se o processo deve continuar

@author André Spirigoni Pinto
@since 29/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172TOTVS(lBaixa,aFiliais, cUser)
Local oWS        := JURA227():New()
Local nCt
Local cNomeRel
Local cToken
Local cGrupo
Local dData1 := STOD('19000101')
Local dData2 := Date() //hoje
Local cData1 := ""
Local cData2 := ""
Local cUrl
Local cAgrupa
Local lTombAut   := SupergetMV( "MV_JTOMAUT", .F., "2" ) == "1"
Local cCodAtoPub := SupergetMV( "MV_JATOPUB", .F., " " )

Default lBaixa   := .T.
Default cUser    := " "
Default aFiliais := JURFILUSR(cUser, "NSZ")

	//formato da data 2016-08-25
	cData1 := Year2Str(dData1) + "-" + Month2Str(dData1) + "-" + Day2Str(dData1)
	cData2 := Year2Str(dData2) + "-" + Month2Str(dData2) + "-" + Day2Str(dData2)

	oWS:cUSUARIO := SuperGetMV('MV_JINDUSR',, '')
	oWS:cSENHA := SuperGetMV('MV_JINDPSW',, '')

	//só tenta pegar as informações caso os parâmetro estejam preenchidos
	if !Empty(oWS:cUSUARIO) .And. !Empty(oWS:cSENHA)

		oWS:MTPUBLICACOES()

		//valida se houve retorno do web service
		If oWS:oWSMTPUBLICACOESRESULT != Nil
			For nCt := 1 to len(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB)
				cNomeRel := AllTrim(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB[nCt]:cNomeRelacional)
				cGrupo := AllTrim(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB[nCt]:cCodGrupo)
				cToken := AllTrim(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB[nCt]:cToken)
				cUrl := AllTrim(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB[nCt]:cURL)
				cAgrupa := AllTrim(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB[nCt]:cAGRUPADOR)

				//Baixamos lotes de 50 publicações
				While J172PrVIS(lBaixa,cNomeRel, cToken, cGrupo,cData1,cData2,cUrl,cAgrupa,aFiliais)
					Sleep(1000)
				End
			Next

			if len(oWS:oWSMTPUBLICACOESRESULT:oWSSTRUACESSOPUB)==0
				ConOut(STR0019) //"Serviço de publicações não encontrado na base da TOTVS. Entrar em contato com o suporte para normalização."
			else
				//-- Verifica se irá fazer tombamento automatico
				If lTombAut .AND. !Empty(cCodAtoPub)
					TombAutom(cUser)
				EndIf
			
			Endif
		Endif
	Else
		ConOut(STR0018) //"Para baixar publicações TOTVS, os parâmetros MV_JINDUSR e MV_JINDPSW devem estar preenchidos."
	Endif

	oWs:Reset()
	FwfreeObj(oWs)
	oWs := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J172TrVal
Função que recebe um valor do tipo caracter msa retorna o valor tipificado

@param cValue Valor original
@param cTipo Tipo da informação que deve ser retornada

@return oObj Informação de retorno, que acompanhará o tipo informado no campo cTipo

@author André Spirigoni Pinto
@since 25/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J172TrVal(cValue, cTipo)
Local oRet
//trata o tipo do campo conforme parâmetro cTipo e retorna a informação no tipo certo.
Do Case
	Case cTipo == 'C'
		oRet := cValue
	Case cTipo == 'D'
	  	if cValue!=Nil
	  		if At("-",cValue)>0
	  			oRet := SToD(STRTRAN(SubStr(cValue,1,10),'-',''))
	  		Elseif At("/",cValue)>0
	  			oRet := CToD(cValue)
	  		Endif
	  	Else
	  		oRet := ''
	  	Endif
  	Case cTipo == 'N'
  		oRet := val(cValue)
	OtherWise
		oRet := cValue
EndCase

Return oRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172DisTot()
Função que le o WebService da Totvs que manda as distribuicoes.

@return lRet - Define se foram feitas as baixas das distribuições.

@author  Rafael Tenorio da Costa
@since 	 17/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172DisTot(lTeste)
Local oWS		:= Nil
Local aDados    := {}
Local oDados	:= Nil
Local nCt       := 0
Local lRet      := .T.
Local cID		:= ""
Local dDtDistri	:= CtoD("")
Local cTermo    := ""
Local cTribunal := ""
Local cProcesso := ""
Local cTipoOcor := ""
Local cReu	    := ""
Local cAutor	:= ""
Local cForum	:= ""
Local cVara     := ""
Local cCidade   := ""
Local cUF 	    := ""
Local nVlrOcorr := 0
Local cAdvAutor := ""
Local cCodLogin	:= ""
Local aDadosRet := {}
Local aDadosNZZ := {}
Local aAux		:= {}
Local aDadAcDiTo:= {}
Local nLogin	:= 1
Local cLoginDis	:= ""
Local cAgrupador := ""
Local cCodEscri	:= ""
Local cUrl		:= ""
Local cToken	:= ""
Local dDtAudi   := cTod("  /  /  ") //Data da Audiência
Local cHrAud 	:= ""
Local cLinkDoc  := "" //Link dos documentos

Default lTeste	:= .F.

	//Valida se o cliente está habilitado para distribuições pelo servido da totvs
	aDadAcDiTo := J228AcDiTo()
	
	If Len(aDadAcDiTo) > 0

		For nLogin:=1 To Len(aDadAcDiTo)

			cLoginDis	:= AllTrim( aDadAcDiTo[nLogin][1] )
			cCodEscri	:= AllTrim( aDadAcDiTo[nLogin][2] )
			cToken		:= AllTrim( aDadAcDiTo[nLogin][3] )
			cAgrupador	:= AllTrim( aDadAcDiTo[nLogin][4] )
			cUrl		:= AllTrim( aDadAcDiTo[nLogin][5] )
			lRet		:= .T.

			//Atualiza tabela NZP
			AtuNZP("2", cAgrupador)

			//Trava a execução do login atual para evitar que mais de uma sessão faça a importação de publicações.
			If !LockByName("J172DisTot_" + cAgrupador, .T., .T.)
				Return .F. //valida se pode executar ou se existe outra execução para o mesmo login
			Endif

			oWS                 := JURA228():New()
			oWS:cnomeRelacional := cLoginDis
			oWS:ncodEscritorio  := Val(cCodEscri)
			oWS:ctoken          := cToken
			oWS:cURL            := LEFT(cUrl,At("?WSDL",cUrl)-1)

			While lRet

				If oWS:RecuperarNovaDistribuicao()

					//Inicilizando arrays
					aDados := {}

					//Valida se houve retorno do web service
					If 	oWS:oWSRecuperarNovaDistribuicaoResult <> Nil .And.;
						XmlChildEx(oWS:oWSRecuperarNovaDistribuicaoResult:_RECUPERARNOVADISTRIBUICAORESULT:_DIFFGR_DIFFGRAM, "_NEWDATASET") <> Nil

						aDados := oWS:oWSRecuperarNovaDistribuicaoResult:_RECUPERARNOVADISTRIBUICAORESULT:_DIFFGR_DIFFGRAM:_NEWDATASET:_TABLE
					Else
						lRet := .F.
						JurConOut(STR0023,{JurTimeStamp() + " ("+cAgrupador+")" }) //"#1 - Aviso: Nenhuma distribuição retornada da TOTVS."
						JA215SetLog(STR0023, cAgrupador, Time())
					Endif

					//Processa distribuições
					If lRet

						//Inicilizando arrays
						aDadosRet := {}
						aDadosNZZ := {}

						If ValType(aDados) == "O"
							oDados := aDados
							aDados := { oDados }
						EndIf

						//Varre os itens recebidos da Kurier e inclui na NR0.
						For nCt := 1 To len(aDados)

							//Carrega dados
							cID			:= J172GetValor(aDados[nCt], "ID"				, "C")
							//cEscrito	:= J172GetValor(aDados[nCt], "Escritorio"		, "C")
							dDtDistri	:= J172GetValor(aDados[nCt], "DataDistribuicao"	, "D")
							cTermo    	:= J172GetValor(aDados[nCt], "Termo"			, "C")
							cTribunal 	:= J172GetValor(aDados[nCt], "Tribunal"			, "C")
							cProcesso	:= J172GetValor(aDados[nCt], "NumeroProcesso"	, "C")
							cTipoOcor 	:= J172GetValor(aDados[nCt], "TipoOcorrencia"	, "C")
							cReu	    := J172GetValor(aDados[nCt], "Reu"				, "C")
							cAutor		:= J172GetValor(aDados[nCt], "Autor"			, "C")
							cForum		:= J172GetValor(aDados[nCt], "Forum"			, "C")
							cVara		:= J172GetValor(aDados[nCt], "Vara"				, "C")
							cCidade   	:= J172GetValor(aDados[nCt], "Cidade"			, "C")
							cUF 	    := J172GetValor(aDados[nCt], "UF"				, "C")
							nVlrOcorr 	:= J172GetValor(aDados[nCt], "ValorOcorrencia"	, "N")
							cAdvAutor 	:= J172GetValor(aDados[nCt], "AdvogadoAutor"	, "C")
							dDtAudi     := J172GetValor(aDados[nCt], "DataAudiencia"	, "D")
							cHrAud      := J172GetValor(aDados[nCt], "DataAudiencia"	, "C") // Data e Hora no formato UTC 2018-12-03T00:00:00-02:00
							cLinkDoc    := J172GetValor(aDados[nCt], "linkDocumentosIniciais", "C")

							cCodLogin 	:= J172GetValor(aDados[nCt], "codLogin"			, "C")

							//Carrega ID para ser enviado como confirmação ao webservice
							Aadd(aDadosRet, cID)

							//Carrega dados que ainda não existem para gravar na tabela NZZ
							aAux := {}
							Aadd(aAux, {"NZZ_LOGIN" , cAgrupador} )
							//Aadd(aAux, {"NZZ_ESCRI" , cEscrito } )
							Aadd(aAux, {"NZZ_DTDIST", dDtDistri} )
							Aadd(aAux, {"NZZ_TERMO" , cTermo   } )
							Aadd(aAux, {"NZZ_TRIBUN", cTribunal} )
							Aadd(aAux, {"NZZ_NUMPRO", AllTrim(cProcesso)} )
							Aadd(aAux, {"NZZ_OCORRE", cTipoOcor} )
							Aadd(aAux, {"NZZ_REU"   , cReu     } )
							Aadd(aAux, {"NZZ_AUTOR" , cAutor   } )
							Aadd(aAux, {"NZZ_FORUM" , cForum   } )
							Aadd(aAux, {"NZZ_VARA"  , cVara    } )
							Aadd(aAux, {"NZZ_CIDADE", cCidade  } )
							Aadd(aAux, {"NZZ_ESTADO", cUF      } )
							Aadd(aAux, {"NZZ_VALOR" , nVlrOcorr} )
							Aadd(aAux, {"NZZ_ADVOGA", cAdvAutor} )

							If Empty(dDtAudi)
								Aadd(aAux, {"NZZ_DTAUDI", cTod("  /  /  ")} )
							Else
								Aadd(aAux, {"NZZ_DTAUDI", dDtAudi})
							EndIf

							If Empty(cHrAud)
								Aadd(aAux, {"NZZ_HRAUDI", ''} )
							Else
								Aadd(aAux, {"NZZ_HRAUDI", substr(cHrAud,12,16)})
							EndIf

							Aadd(aAux, {"NZZ_LINK", cLinkDoc} )
							Aadd(aDadosNZZ, aClone(aAux))

							//limpa os dados utilizados.
							FwFreeObj(aDados[nCt])
						Next nCt

						//Grava as distribuicoes
						If Len(aDadosNZZ) > 0
							GravaDis(aDadosNZZ)
						EndIf
						//Confirma o recebimento apenas quando o parametro teste for falso
						If !lTeste
							//Confirma recebimento das distribuicoes na Totvs(Vista)
							If !( lRet := BaixaDis(oWs, aDadosRet) )
								Exit
							EndIf
						EndIf
						Exit
						If lRet
							JurConOut(STR0022, {(JurTimeStamp() + " ("+cAgrupador+")"), Len(aDadosRet)})		//"#1 - Aviso: Foram confirmadas #2 distribuções na TOTVS."
						EndIf
					Endif
				Else
					lRet := .F.
				EndIf

				Sleep(1000)
			EndDo

			//Limpa arrays
			Asize(aAux, 0)
			Asize(aDadosRet, 0)
			Asize(aDadosNZZ, 0)

			FwFreeObj(aDados)
			FwFreeObj(oWS)

			//Libera a execução do login
			UnLockByName("J172DisTot_" + cAgrupador,.T.,.T.)

		Next nLogin
	Else

		lRet := .F.
		JurMsgErro( STR0020 + CRLF +;	//"Cliente não esta habilitado a utilizar o serviço de distribuição TOTVS."
					STR0021)			//"Entre em contato com o suporte TOTVS."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J228CfDiTo
Função para dar baixa\confirmar as distribuicoes recebidas da Totvs(Vista)
Uso JURA172.

@param 	 cUrl 		- Objeto do web service que foi utilizado para baixar as distribuições
@param	 aID 		- IDs da distribuição que será confirmada
@return  lRet   	- Define se a distribuição foi confirmada com sucesso
@author	 Rafael Tenorio da Costa
@since	 06/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function baixaDis(oWs, aID)
Local lRet      := .F.
Local nID		:= 0

For nID:=1 To Len(aID)

	oWs:nID := val(aID[nID])
	oWs:lbaixado := .T.

	lRet := oWs:ConfirmaDistribuicaoEnviada()

    If !lRet
        cMensagem := I18n(STR0006, {aID[nID], STR0005})	//"Distribuição ID #1 não foi baixada. Retorno WS: #2"
        Break
        Exit
    EndIf

Next nID

If !lRet
    ConOut("baixaDis: " + STR0005 + cMensagem)		//"Erro ao dar baixa na distribuição TOTVS: "
    lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172ImpPub
Importação de Publicações
Uso JURA172.

@return  lRet   	- Define se a distribuição foi confirmada com sucesso
@author	 Marcelo Dente
@since	 06/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172ImpPub(oXml,lBaixa,cAgrupa,aFiliais, cNomeRel, cToken, cUrl)
Local nCt       := 0
Local lRet      := .T.
Local cEstado   := ''
Local cCodigo   := ''
Local cNome     := ''
Local cOrgao    := ''
Local cPagina   := ''
Local cProcesso := ''
Local cTexto    := ''
Local cVara     := ''
Local cCodRel   := ''
Local cDiario   := ''
Local aDadXML   := {}
Local nRet
Local nQtd      := 0
Local nPub     := 0 //quantidade de publicações recebidas do web service
Local cPath    := "/SOAP-ENV:Envelope/SOAP-ENV:Body/ns1:getPublicacoesTodosComQuantidadeLimitadaResponse/return" //caminho das publicações

	//valida se houve retorno do web service 
	If oXml != Nil
		nPub := oXML:XPathChildCount( cPath ) //obtem a quantidade de publicações

		If nPub <= 0
			oXML:XPathRegisterNs( "ns1", ("http://acessows.sytes.net:9090/recorte/webservice/personalizado/" + cNomeRel + "/webservice.php") )
			nPub := oXML:XPathChildCount( cPath ) //obtem a quantidade de publicações
		EndIf

		If nPub <= 0
			lRet := .F.
			JurConOut(STR0017,{JurTimeStamp() + " ("+cAgrupa+")" }) //"#1 - Aviso: Nenhuma publicação retornada da TOTVS."
			JA215SetLog(STR0016, cAgrupa, Time()) //"Aviso: Nenhuma publicação retornada da TOTVS."
		EndIf
	Else
		lRet := .F.
		JurConOut(STR0017, {JurTimeStamp() + " ("+cAgrupa+")"} ) //"#1 - Aviso: Nenhuma publicação retornada da TOTVS."
	Endif

	If lRet
		//Varre os itens recebidos da Kurier e inclui na NR0.
		For nCt := 1 To nPub

			cCodigo   := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/codPublicacao",{nCt}) ), "C")
			dData     := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/dataPublicacao",{nCt}) ), "D")
			cCodRel   := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/codPublicacao",{nCt}) ), "C")
			cNome     := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/nomeVinculo",{nCt}) ), "C")
			cProcesso := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/numeroProcesso",{nCt}) ), "C")
			cPagina   := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/paginaInicial",{nCt}) ), "C")
			cDiario   := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/descricaoDiario",{nCt}) ), "C")
			cTexto    := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/processoPublicacao",{nCt}) ), "C")
			cVara     := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/varaDescricao",{nCt}) ), "C")
			cOrgao    := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/orgaoDescricao",{nCt}) ), "C")
			cEstado   := J172TrVal(oXML:XPathGetNodeValue( cPath + I18n("/item[#1]/descricaoUF",{nCt}) ), "C")

			//valida se a publicação ja existe
			if 	J172ExtNR0(cCodRel, cAgrupa)>0

				if (lBaixa)
					J227AtuPub(cNomeRel, cToken, cCodRel, cUrl)				
				Endif

				Loop //Pula para o próximo item	

			Endif

			aAdd(aDadXML,{cCodigo,dData," ",cProcesso,cTexto," ",cCodigo,CtoD("//")," ",cCodRel,cNome,cPagina,cDiario,"",cOrgao,cEstado,cVara,cAgrupa})

			//Processa as publicações
			nRet := J20ProcXML(aDadXML,,,,.T.,0,,aFiliais)

			//Limpa o array
			aSize(aDadXML,0)

			//valida se a publicação foi importada com sucesso
			if (nRet==1)
				nQtd := nQtd + 1

				if (lBaixa)
					J227AtuPub(cNomeRel, cToken, cCodRel, cUrl)
				Endif
			Endif
		Next

		JurConOut(STR0014,{(JurTimeStamp() + " ("+cAgrupa+")"),nQtd}) //"#1 - Aviso: Foram importadas #2 publicações da TOTVS."
		JA215SetLog(STR0009 + Str(nQtd) + STR0015, cAgrupa, Time()) // "Foram importadas"	... "publicações da TOTVS."
	Endif

	//limpa array
	aSize(aDadXML,0)
	cTexto := ""
	FwFreeObj(oXml)
	oXML := NIl

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J172DisOito()
Faz o controle da importação da distribuições da OITO

@author  Rafael Tenorio da Costa
@since 	 07/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J172DisOito(cLogin, cPwd, cEndPoint, lTeste)

	Local aDadosNZZ := {}

	Default cLogin		:= AllTrim(SuperGetMv("MV_JDISUSR", .T., ""))	//Usuário Teste 'distribuicao'
	Default cPwd      	:= AllTrim(SuperGetMv("MV_JDISPWD", .T., ""))	//Senha teste:  'jkl_&mx%v@2018'
	Default cEndPoint  	:= AllTrim(SuperGetMv("MV_JDISURL", .T., "")) 	//'https://solucaojuridica.oito.srv.br/'
	Default lTeste 		:= .F.

	//Trava a execução do login atual para evitar que mais de uma sessão faça a importação de publicações.
	If !LockByName("JURA262_" + cLogin, .T., .T.)
		Return Nil
	EndIf

	//Busca as Distribuições na OITO
	aDadosNZZ := Jura262(cLogin, cPwd, cEndPoint, '1', , lTeste)

	If Len(aDadosNZZ) > 0

		//Grava as Distribuições recebidas na NZZ
		If GravaDis(aDadosNZZ)

			//Confirma o Recebimento das Distribuições na OITO
			Jura262(cLogin, cPwd, cEndPoint, '2', aDadosNZZ, lTeste)
		EndIf
	EndIf

	//Libera a execução do login
	UnLockByName("JURA262_" + cLogin, .T., .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TombAutom()
Realiza o tombamento automático de publicações

@Param  cUser Usuário  de inclusão do andamento
@param cDtCheg Data da chegada, vinda quando é automação
@param aCajuri array de cajuris para busca, vinda quando é automação

@Return .T.
@since  20/01/2020
/*/
//-------------------------------------------------------------------
Function TombAutom(cUser, cDtCheg, cCajuri)
Local aArea      := GetArea()
Local aAreaNR0   := NR0->(GetArea())
Local cQry       := ""
Local cCodAto    := ""
Local oModel     := Nil
Local lRet       := .F.
Local cAlias     := GetNextAlias()
Local aPalavraCh := J020Palavr()

Default cDtCheg  := DTOS( Date() )
Default cCajuri  := ""

	//-- Busca todas as publicações com status localizadas, com a data atual
	cQry := " SELECT NR0_DTCHEG, "
	cQry +=        " NR0_CODSEQ, "
	cQry +=        " NR0_SITUAC "
	cQry += " FROM "  + RetSqlName("NR0")  + " NR0 "
	cQry += " WHERE NR0.NR0_SITUAC = '1' "
	cQry +=       " AND NR0.NR0_DTCHEG >= '" + cDtCheg + "' "
	cQry +=       " AND NR0.D_E_L_E_T_ = ' ' "

	If !Empty(cCajuri)
		cQry +=   " AND NR0.NR0_CAJURI = '" + cCajuri + "' "
	EndIf

	cQry := ChangeQuery(cQry)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), cAlias, .F., .F. )

	DbSelectArea("NR0")
	NR0->(DbSetOrder(6)) //-- NR0_FILIAL + NR0_DTCHEG + NR0_CODSEQ + NR0_SITUAC

	While (cAlias)->( !EOF() )

		//-- Posiciona na publicação 
		If NR0->(DbSeek( xFilial("NR0") + (cAlias)->NR0_DTCHEG + (cAlias)->NR0_CODSEQ + (cAlias)->NR0_SITUAC))

			//-- Busca Ato
			cCodAto := J20RetAto(NR0->NR0_TEORPB, aPalavraCh)

			If Empty(cCodAto) 
				cCodAto := SuperGetMV("MV_JATOPUB",.F., "")
			EndIf

			//-- Inlcui andamento 
			oModel := FWLoadModel("JURA100")
			oModel:SetOperation(3)
			oModel:Activate()

			oModel:SetValue("NT4MASTER", "NT4_FILIAL", NR0->NR0_FILPRO )
			oModel:SetValue("NT4MASTER", "NT4_CAJURI", NR0->NR0_CAJURI )
			oModel:SetValue("NT4MASTER", "NT4_CATO"  , cCodAto )
			oModel:SetValue("NT4MASTER", "NT4_DTANDA", NR0->NR0_DTPUBL )
			oModel:SetValue("NT4MASTER", "NT4_DESC"  , NR0->NR0_TEORPB )
			oModel:SetValue("NT4MASTER", "NT4_USUINC", cUser )
			oModel:SetValue("NT4MASTER", "NT4_USUALT", cUser )

			lRet := oModel:VldData()

			If lRet
				lRet := oModel:CommitData()
			EndIf

			//-- Alterar a situação para Importada
			If lRet
				NR0->( RecLock("NR0", .F. ) )
				NR0->NR0_SITUAC := "5"
				NR0->( MSUnlock() )
			EndIf
		EndIf

		(cAlias)->(dbSkip())
	EndDo

	NR0->(DbCloseArea())
	(cAlias)->(DbCloseArea())

	RestArea(aAreaNR0)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdDistrRec
Consulta a quantidade de distribuições importadas no database

@return nRet     quantidade de distribuições importadas no database

@since 15/07/2020
/*/
//-------------------------------------------------------------------
Static Function QtdDistrRec()

Local nRet       := 0
Local cQuery     := ""
Local cAlias     := GetNextAlias()

	cQuery += "SELECT COUNT(NZZ_COD) QTD_DISTR FROM " + RetSqlName("NZZ")
	cQuery += " WHERE NZZ_DTREC = '"+DToS(dDataBase)+"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " AND NZZ_FILIAL = '"+xFilial("NZZ")+"' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If (cAlias)->(!EOF())
		nRet := (cAlias)->QTD_DISTR
	EndIf

	(cAlias)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUsrGrp
Consulta os usuários pertencentes aos grupos do tipo Matriz

@return aRet     Usuários dos grupos

@since 15/07/2020
/*/
//-------------------------------------------------------------------
Static Function GetUsrGrp()
Local aRet       := {}
Local cQuery     := ""

	cQuery += " SELECT DISTINCT "
	cQuery += "     NZY_CUSER AS CODUSER "
	cQuery += " FROM " + RetSqlName("NZX") + " NZX "
	cQuery += "     INNER JOIN " + RetSqlName("NZY") + " NZY ON "
	cQuery += "         NZY.NZY_FILIAL = NZX.NZX_FILIAL "
	cQuery += "         AND NZY.D_E_L_E_T_ = ' ' "
	cQuery += "         AND NZY.NZY_CGRUP = NZX.NZX_COD "
	cQuery += " WHERE  "
	cQuery += "     NZX.NZX_FILIAL = '"+xFilial('NZX')+"' "
	cQuery += "     AND NZX.D_E_L_E_T_ = ' ' "
	cQuery += "     AND NZX_TIPOA = '1' "

	cQuery += " union "

	cQuery += " SELECT DISTINCT "
	cQuery += "     NVK.NVK_CUSER AS CODUSER "
	cQuery += " FROM " + RetSqlName("NVK") + " NVK "
	cQuery += " WHERE "
	cQuery += "    NVK.NVK_FILIAL = '"+xFilial('NVK')+"' "
	cQuery += "    AND NVK.D_E_L_E_T_ = ' ' "
	cQuery += "    AND NVK.NVK_TIPOA = '1' "
	cQuery += "    AND NVK.NVK_CUSER > '' "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	aRet := JurSQL(cQuery,'*')

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NotifDistr
Função que valida se o usuário deseja receber notificações de 
distribuições recebidas, de acordo com a tabela de preferencias dos 
usuários do TOTVS Legal

@param  cUsuario - Código do usuário
@return lRecebeNot - .T./.F. - Deseja receber notificações de distr recebidas?

@since 26/02/2021
/*/
//-------------------------------------------------------------------
Static Function NotifDistr(cUsuario)

Local lRecebeNot := .T.
Local cConfig    := ""
Local oConfig    := JsonObject():new()

	If FWAliasInDic("O16") .AND. !Empty(cUsuario)
		cConfig  := Alltrim( JurGetDados("O16", 1, xFilial("O16") + cUsuario + "2", "O16_JSON") )

		If !Empty(cConfig)
			FWJsonDeserialize(cConfig, @oConfig)

			If VALTYPE(oConfig[1]:DISTRIBUICOES) <> "U"
				lRecebeNot := oConfig[1]:DISTRIBUICOES
			Else
				lRecebeNot := .F.
			EndIf
		Else
			lRecebeNot := .F.
		EndIf
	EndIf

Return lRecebeNot
