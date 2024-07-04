#INCLUDE "LOJA140.CH"
#INCLUDE "PROTHEUS.Ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWADAPTEREAI.CH"

Static lCanInteg := NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} LjBuscaLX
Função responsável por buscar a NFC-e a ser cancelada por substituição

@type	 Function
@param   cPDV 		Numero do PDV da NFC-e a ser cancelada
@param   cSerie 	Numero da Serie da NFC-e a ser cancelada
@param   cDoc 		Numero do Doc da NFC-e a ser cancelada
@param   cNumOrc 	Numero do Orçamento da NFC-e a ser cancelada
@author  Eduardo Sales
@since   15/05/2019
@version P12
/*/
//-------------------------------------------------------------------
Function LjBuscaLX(cPDV, cSerie, cDoc, cNumOrc)

Local lRet		:= .F.
Local cQryTemp	:= ""
Local cWhere	:= "%%"			//Expressão
Local oLOJCNFCE	:= Nil			//Constroi o objeto LOJCNFCE
Local cXml		:= ""
Local oXml		:= ""
Local cXMLProt	:= ""
Local oXMLProt	:= Nil
Local cProt		:= ""			//Numero do Protocolo
Local cChNfe	:= ""			//Chave NFC-e
Local cModelo	:= "65"
Local cCodRetNF	:= ""			//Codigo de Retorno SEFAZ

Default cNumOrc := ""

If ExistFunc("LjMonitora") //Verifica se a funcao existe no fonte LOJNFCE
	LjMonitora(cDoc, cSerie, cModelo, @cCodRetNF)
EndIf

/*--------------------------------------------------------------------------------------------
	Realiza o Cancelamento por Substituição somente quando a inutilização é rejeitada por 
	'Prazo de cancelamento superior ao previsto na Legislação'
--------------------------------------------------------------------------------------------*/
If cCodRetNF == "501"
	LjAtualSLX("X1")

	cQryTemp := GetNextAlias()

	cWhere := "%L1_PDV = '" + cPDV + "' "
	cWhere += " AND L1_SERIE = '" + cSerie + "' "
	cWhere += " AND L1_DOC <> '' "
	cWhere += " AND (L1_NUMORIG = '" + cNumOrc + "' OR L1_NUM = '" + cNumOrc + "') "
	cWhere += "%"

	BeginSql alias cQryTemp
		
		SELECT L1_PDV, L1_SERIE, L1_NUMORIG, L1_KEYNFCE, L1_DOC

		FROM %table:SL1% 

		WHERE L1_FILIAL = %xFilial:SL1%		AND 
				%exp:cWhere%				AND
				%notDel% 

	EndSql

	(cQryTemp)->(DbGoTop())
	
	If !(cQryTemp)->(Eof())
		// Retorna o XML com a chave da venda a ser cancelada
		LjNfceGet(@cXML, @cXMLProt, cDoc, cSerie)

		If !Empty(cXML)
			
			oXml := TXMLManager():New()
			
			If oXml:Parse(cXml)
				If oXml:XPathRegisterNS("ns", "http://www.portalfiscal.inf.br/nfe")
					cChNfe := oXML:XPathGetAtt( "/ns:NFe/ns:infNFe", "Id" )

					If Empty(cChNfe)
						LjGrvLog("ParseXML", "Não foi possível obter o atributo Id" )
					Else
						cChNfe := StrTran(cChNfe, "NFe")
					EndIf
				EndIf
			EndIf
		EndIf

		// Retorna o XML o Protocolo da Venda finalizada
		LjNfceGet(@cXML, @cXMLProt, (cQryTemp)->L1_DOC, (cQryTemp)->L1_SERIE)

		If !Empty(cXMLProt) .And. !Empty(cChNfe)

			oXMLProt := TXMLManager():New()
			
			If oXMLProt:Parse(cXMLProt)
				If oXMLProt:XPathRegisterNS("ns", "http://www.portalfiscal.inf.br/nfe")

					cProt := oXMLProt:XPathGetNodeValue("/ns:protNFe/ns:infProt/ns:nProt")

					oLOJCNFCE := LOJCNFCE():New()
					lRet := oLOJCNFCE:LjCancSbst(cChNfe, cProt, (cQryTemp)->L1_KEYNFCE)

				EndIf
			EndIf
		Else
			lRet := .F.
			LjGrvLog((cQryTemp)->L1_DOC, "A nota não possui Protocolo de Autorização ou Chave da NFC-e preenchida, portanto não será enviada para o Cancelamento por Substituição.")
		EndIf
	EndIf

	(cQryTemp)->(DbCloseArea())

	If lRet
		LjAtualSLX("X2")
	Else
		LjGrvLog(cNumOrc, "Número de orçamento não encontrado.")
		LjAtualSLX("X3")
	EndIf
EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Lj140CCanc
Função responsavel por realizar o "cancelamento" de uma venda que inicio o cancelamento porem foi rejeitada. 

@param   nRecSL1	 Número do Recno  para que seja posicionado
@author  Lucas Novais (lnovais)
@since   01/04/2019
@version P12
@return  Lógico, Indica se executou com sucesso
/*/
//----------------------------------------------------------------------

Function Lj140CCanc(nRecSL1)
Local lRet 			:= .T.
Local aArea 		:= GetArea()
Local aAreaSL1 		:= SL1->(GetArea())

Default nRecSL1 	:= ""

//-- Caso não esteja posicionado (Teste automatizado ou interface) posiciono no regitro
If !Empty(nRecSL1)
	
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1)) // -- L1_FILIAL+L1_NUM
	
	DbGoTo(nRecSL1)
	
	// -- Caso não seja possivel posicionar no recno passado.
	If EOF() 
		lRet := .F.

		If IsBlind()
			Conout("Não foi possivel posicionar no RECNO: " + cValToChar(nRecSL1))// -- "Não foi possivel posicionar no RECNO: "
		Else
			MsgAlert(STR0221 + cValToChar(nRecSL1))// -- "Não foi possivel posicionar no RECNO: "
		Endif

	EndIf 

EndIf 

If lRet
	// -- Somente libero para retorno venda que estão rejeitadas.
	If SL1->L1_SITUA == "X3"
		RecLock("SL1")
			Replace SL1->L1_SITUA with "OK"
		SL1->( MsUnlock() )
	Else
			
		If IsBlind()
			Conout("Não foi possivel desfazer a tentativa de cancelamento da venda, a venda não esta com status de rejeitada. (Tabela SL1, Campo L1_SITUA = 'X3')")// -- "Não foi possivel retornar venda, a venda não esta com status de rejeitada.(Tabela SL1, Campo L1_SITUA = 'X3')"
		Else
			MsgAlert(STR0220)// -- "Não foi possivel retornar venda, a venda não esta com status de rejeitada.(Tabela SL1, Campo L1_SITUA = 'X3')"
		Endif 
		
		lRet := .F.
	EndIf 
Endif

RestArea(aArea)
RestArea(aAreaSL1)

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjAtualSLX
Atualiza o status (LX_SITUA) da tabela SLX.

@type       Function
@author     Alberto Deviciente
@since      26/10/2018
@version    12
@param      cNewSitua, Caracter, Nova situacao  a ser gravada no campo LX_SITUA.
@return 	Nil
/*/
//---------------------------------------------------------------------------------------
Function LjAtualSLX( cNewSitua )
Local cOldSitua 	:= ""

/*
Definicao do Status do Campo LX_SITUA:
"OK" = Cancelamento/inutilização não iniciado ainda
"X0" = Marcado como iniciado o Cancelamento/Inutilização, porem nao enviada ainda ao TSS
"X1" = Documento enviado ao TSS para cancelamento/inutilização, aguardando retorno de autorizacao do SEFAZ
"X2" = Cancelamento/Inutilização autorizado pela SEFAZ, porém falta incluir o documento como cancelado no Protheus (SFT, SF3)
"X3" = Cancelamento/Inutilização nao autorizdo pelo SEFAZ
"  " = Documento cancelado no Protheus (SFT, SF3). Processo de Cancelamento/Inutilização concluído por completo.
"ER" = Ocorreu erro ao tentar Incluir a Documento e Cancelar nas tabelas do Protheus (SF2, SD2, SFT, SF3).
*/

If SLX->LX_SITUA <> cNewSitua

	cOldSitua 	:= SLX->LX_SITUA

	If RecLock("SLX", .F.)
		SLX->LX_SITUA := cNewSitua
		SLX->( MsUnlock() )

		LjGrvLog( SLX->LX_CUPOM, "Atualizou o LX_SITUA. De: [" + cOldSitua + "] Para [" + cNewSitua + "]. DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] Modelo: [" + SLX->LX_MODDOC + "]." )
	Else
		LjGrvLog( SLX->LX_CUPOM, "Falha ao tentar atualizar o campo LX_SITUA. De: [" + cOldSitua + "] Para [" + cNewSitua + "]. DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] Modelo: [" + SLX->LX_MODDOC + "]." )
	EndIf

EndIf

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjFilterLX
Efetua o filtro e retorna a relacao de registros da tabela SLX de acordo com as situacoes passada por parametro.

@type       Function
@author     Alberto Deviciente
@since      23/10/2018
@version    12
@param      aSitua, array, Situações do campo LX_SITUA a ser filtrado.
@return 	array, Relacao de registros da tabela SLX de acordo com as situacoes passada por parametro.
/*/
//---------------------------------------------------------------------------------------
Function LjFilterLX( aSitua )
Local aRet 		:= {}
Local cQuery 	:= ""
Local cSituaIN 	:= ""
Local cAliasTmp := GetNextAlias()

//Fecha a tabela SLX e abre de novo para garantir que nao seja feita a leitura "suja" caso o recno retornado neste query seja o mesmo do registro ja posicionado (caso tenha apenas 1 registro retornado na query)
If Select("SLX") > 0
	SLX->(DbCloseArea())
EndIf
DbSelectArea("SLX")

aEval(aSitua, {|x| cSituaIN += "'" + x + "'," })
cSituaIN := SubStr(cSituaIN,1,Len(cSituaIN)-1)

cQuery := " SELECT R_E_C_N_O_ RECSLX"
cQuery += "   FROM " + RetSQLName("SLX")
cQuery += "  WHERE LX_FILIAL = '"+xFilial("SLX")+"'"
cQuery += "    AND LX_SITUA IN ("+cSituaIN+")"
If "X2" $ cSituaIN
	/*
	Quando filtar LX_SITUA = X2, considera somente registros ate 1 dia atras, pois mudou o conceito do status do LX_SITUA para inutilizacao de NFC-e.
	Antes o processo terminava em X2, porem com os novos ajustes na rotina de Inutilizacao, agora o processo quando concluido por completo, limpa o campo LX_SITUA (deixando em branco).
	Esse filtro foi necessário, para que agora com o novo comportamento não considerasse registros muito antigos de anos atrás, cujo comportamento do processo era finalizado quando o LX_SITUA = X2, 
	pois consideraria o processo como nao finalizado ainda.
	
	Com as mudancas, os status do campo LX_SITUA ficam assim definidos:
		"OK" = Cancelamento/inutilização não iniciado ainda
		"X0" = Marcado como iniciado o Cancelamento/Inutilização, porem nao enviada ainda ao TSS
		"X1" = Documento enviado ao TSS para cancelamento/inutilização, aguardando retorno de autorizacao do SEFAZ
		"X2" = Cancelamento/Inutilização autorizado pela SEFAZ, porém falta incluir o documento como cancelado no Protheus (SFT, SF3)
		"X3" = Cancelamento/Inutilização nao autorizdo pelo SEFAZ
		"  " = Documento cancelado no Protheus (SFT, SF3). Processo de Cancelamento/Inutilização concluído por completo.
		"ER" = Ocorreu erro ao tentar Incluir a Documento e Cancelar nas tabelas do Protheus (SF2, SD2, SFT, SF3).
	*/
	cQuery += "  AND LX_DTMOVTO >= '20181126'" //Proteção para não trazer muitos registros antes da alteração, retirar em dez/2019
EndIf
cQuery += "    AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
LjGrvLog("LOJA140A","[LjFilterLX] Query a ser executada ->", cQuery)
dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

While !(cAliasTmp)->(EoF())
	aAdd( aRet, (cAliasTmp)->RECSLX )
	(cAliasTmp)->(DbSkip())
End

(cAliasTmp)->(DbCloseArea())

Return aRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjVlParInu
Valida se as configuracoes estao tudo certo para executar a inutilizacao de Documento Eletronico

@type       Function
@author     Alberto Deviciente
@since      22/10/2018
@version    12
@return 	Lógico, Retorna se as configuracoes estao corretas para executar a inutilizacao de Documento Eletronico
/*/
//---------------------------------------------------------------------------------------
Function LjVlParInu()
Local lRet 		 := .T.
Local aArea 	 := GetArea()
Local aAreaAux 	 := {}
Local cMvInutCli := SuperGetMV("MV_INUTCLI", .F., "")
Local cMvInutPro := SuperGetMV("MV_INUTPRO", .F., "")
Local cMvInutTES := SuperGetMV("MV_INUTTES", .F., "")
Local cMvInutLoj := SuperGetMV("MV_INUTLOJ", .F., "")

LjGrvLog( Nil, "Configuracao do parametro MV_INUTCLI", cMvInutCli )
LjGrvLog( Nil, "Configuracao do parametro MV_INUTPRO", cMvInutPro )
LjGrvLog( Nil, "Configuracao do parametro MV_INUTTES", cMvInutTES )
LjGrvLog( Nil, "Configuracao do parametro MV_INUTLOJ", cMvInutLoj )

If Empty(cMvInutCli)
	lRet := .F.
	LjGrvLog( "Inutilizacao", "Configure o parametro MV_INUTCLI para efetuar o processo de Inutilização de Documento Eletronico" )
	COnout("Configure o parametro MV_INUTCLI para efetuar o processo de Inutilização de Documento Eletronico")
EndIf

If Empty(cMvInutPro)
	lRet := .F.
	LjGrvLog( "Inutilizacao", "Configure o parametro MV_INUTPRO para efetuar o processo de Inutilização de Documento Eletronico" )
	COnout("Configure o parametro MV_INUTPRO para efetuar o processo de Inutilização de Documento Eletronico")
EndIf

If Empty(cMvInutTES)
	lRet := .F.
	LjGrvLog( "Inutilizacao", "Configure o parametro MV_INUTTES para efetuar o processo de Inutilização de Documento Eletronico" )
	COnout("Configure o parametro MV_INUTTES para efetuar o processo de Inutilização de Documento Eletronico")
EndIf

If Empty(cMvInutLoj)
	If lRet
		cMvInutLoj := "01"
	Else
		lRet := .F.
		LjGrvLog( "Inutilizacao", "Configure o parametro MV_INUTLOJ para efetuar o processo de Inutilização de Documento Eletronico" )
		COnout("Configure o parametro MV_INUTLOJ para efetuar o processo de Inutilização de Documento Eletronico")
	EndIf
EndIf

If lRet

	cMvInutCli	:= PadR(cMvInutCli, TamSX3("A1_COD")[1])
	cMvInutPro	:= PadR(cMvInutPro, TamSX3("B1_COD")[1])
	cMvInutTES	:= PadR(cMvInutTES, TamSX3("F4_CODIGO")[1])
	cMvInutLoj	:= PadR(cMvInutLoj, TamSX3("A1_LOJA")[1])

	//Verifica se o CLIENTE usado na inutilizacao existe
	DbSelectArea("SA1")
	aAreaAux := SL1->(GetArea())
	SA1->( DbSetOrder(1) )
	If !SA1->( DbSeek(xFilial("SA1") + cMvInutCli + cMvInutLoj) )
		lRet := .F.	//to do - nao gera nota ou gera para o cliente padrao?
		LjGrvLog( Nil, "Cliente/Loja configurado para inutilizacao [MV_INUTCLI / MV_INUTLOJ] nao foi encontrado na base de dados:", cMvInutCli+"/"+cMvInutLoj )
	EndIf
	RestArea(aAreaAux)

	//Verifica se o PRODUTO usado na inutilizacao existe
	DbSelectArea("SB1")
	aAreaAux := SB1->(GetArea())
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial("SB1")+cMvInutPro))
		lRet := .F.
		LjGrvLog( Nil, "Produto configurado para inutilizacao [MV_INUTPRO] nao foi encontrado na base de dados:", cMvInutPro )
	EndIf
	RestArea(aAreaAux)
	
	//Verifica se a TES usada na inutilizacao existe
	DbSelectArea("SF4")
	aAreaAux := SF4->(GetArea())
	SF4->(DbSetOrder(1))
	If !SF4->(DbSeek(xFilial("SF4")+cMvInutTES))
		lRet := .F.
		LjGrvLog( Nil, "TES configurado para inutilizacao [MV_INUTTES] nao foi encontrado na base de dados:", cMvInutTES )
	EndIf
	RestArea(aAreaAux)

EndIf

RestArea(aArea)

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjVerCanOK
Verifica no TSS se a Inutilizacao foi autorizada.

@type       Function
@author     Alberto Deviciente
@since      23/10/2018
@version    12
@return 	Nil
/*/
//---------------------------------------------------------------------------------------
Function LjVerCanOK()
Local aRecnos 		:= {}
Local nX 			:= 0
Local lMonitora 	:= .F.
Local aNFCeID		:= {}								//vetor de NFEID (L1_SERIE+L1_DOC) que serao consultados no TSS
Local aNFCeDados	:= {}								//vetor retornado pelo TSS com o status de cada nota que foi consultado
Local lLJNFCESUB	:= SuperGetMV("MV_NFCESUB",,.F.) 	//Utiliza Cancelamento por Substituição?

//Busca por registros LX_SITUA = "X1" (Doc enviado ao TSS para cancelamento/inutilização, aguardando autorizacao do SEFAZ)
aRecnos := LjFilterLX( {"X1"} )

LjGrvLog( "", "Quantidade de DOCs de Inutilizacao na tabela SLX (LX_SITUA = X1) aguardando autorizacao do SEFAZ: " + AllTrim(Str(Len(aRecnos))) )

For nX := 1 to Len(	aRecnos )
	lMonitora := .F.

	SLX->( DbGoTo(aRecnos[nX]) )
	
	LjGrvLog( SLX->LX_CUPOM, "INICIO - Verificao no TSS se o DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] Modelo: [" + SLX->LX_MODDOC + "] foi autorizada a inutilizacao." )

	aNFCeID := { SLX->LX_SERIE + SLX->LX_CUPOM }

	//Obtemos os status da nota no TSS
	aNFCeDados := LjNFCeGtID(aNFCeID, SLX->LX_MODDOC)

	LjGrvLog(SLX->LX_CUPOM, "Status do Documento no TSS: ", aNFCeDados)

	If Len(aNFCeDados) > 0

		Do Case
			// CANCELAMENTO PENDENTE - mantemos o valor do campo _SITUA
			Case aNFCeDados[1][4] == "7" .AND. aNFCeDados[1][5] == "1"
				
				LjGrvLog( SLX->LX_CUPOM, "Cancelamento/Inutilizacao DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] PENDENTE aguardando autorizacao do SEFAZ." )

				lMonitora := .T. //Indica que deve fazer o monitoramento do documento no TSS para atualizar o seu Status

			// CANCELAMENTO PROCESSADO - atualizamos o valor do campo _SITUA
			Case aNFCeDados[1][4] == "7" .AND. aNFCeDados[1][5] == "2"

				LjGrvLog( SLX->LX_CUPOM, "Cancelamento/Inutilizacao DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] AUTORIZADO pelo SEFAZ." )
				
				LjAtualSLX("X2") //Muda o Status como: Cancelamento/inutilização autorizado pelo SEFAZ

			// CANCELAMENTO REJEITADO - atualizamos o valor do campo _SITUA
			Case aNFCeDados[1][4] == "7" .AND. aNFCeDados[1][5] == "3"
				
				LjGrvLog( SLX->LX_CUPOM, "Cancelamento/Inutilizacao DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] NAO AUTORIZADO pelo SEFAZ. Verifique maiores detalhes do documento no TSS." )
				
				LjAtualSLX("X3") //Muda o Status como: Cancelamento NAO AUTORIZADO pela SEFAZ

				If lLJNFCESUB .And. SLX->LX_MODDOC == '65'
					If !Empty(SLX->LX_NUMORC)
						LjBuscaLX(SLX->LX_PDV, SLX->LX_SERIE, SLX->LX_CUPOM, SLX->LX_NUMORC)
					EndIf
				EndIf

			//Retornou STATUS e/ou STATUSCANC invalidos para cancelamento
			Otherwise

				LjGrvLog( SLX->LX_CUPOM, "Retorno INVALIDO para o cancelamento/inutilizacao DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] Modelo: [" + SLX->LX_MODDOC + "]", aNFCeDados )
				
		End Case

	Else
		lMonitora := .T. //Indica que deve fazer o monitoramento do documento no TSS para atualizar o seu Status
		LjGrvLog( SLX->LX_CUPOM, "Falha ao obter o status do Documento no TSS")
	EndIf

	If lMonitora
		//Faz o monitoramento do documento no TSS e atualiza o STATUS do documento nas tabelas do TSS.
		//Este procedimento ajuda a regularizar o status da tabela SPED050, caso esteja com algum problema.
		LjMonitDoc( SLX->LX_CUPOM, SLX->LX_SERIE, SLX->LX_MODDOC )
	EndIf

	LjGrvLog( SLX->LX_CUPOM, "FIM - Verificao no TSS se o DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE + "] Modelo: [" + SLX->LX_MODDOC + "] foi autorizada a inutilizacao." )

Next nX

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjEnviaCan
Envia ao TSS os Documentos para Inutilizacao.

@type       Function
@author     Alberto Deviciente
@since      23/10/2018
@version    12
@return 	Nil
/*/
//---------------------------------------------------------------------------------------
Function LjEnviaCan()
Local aRecnos 	:= {}
Local aTipos	:= {"OK","X0"} //Busca por registros LX_SITUA = ("OK" ou "X0") (Inutilizacao ainda nao enviada ao TSS)	
Local nX 		:= 0
Local lEnviou 	:= .F.
Local lSituaIP	:= .F.

If lCanInteg
	Aadd(aTipos,"IN") //ajuste para Situa 'IN' assim não inutlizar cancelamento da Integração
EndIf

aRecnos := LjFilterLX( aTipos )
LjGrvLog( "", "Quantidade de DOCs de Inutilizacao na tabela SLX "+;
		"(LX_SITUA = OK/X0 ) ainda nao enviado ao TSS " +;
		IIf(lCanInteg," e pendentes de integração de cancelamento/inutilização (LX_SITUA = IP) :",":") +;
		cValToChar(Len(aRecnos)) )

For nX := 1 to Len(	aRecnos )
	SLX->( DbGoTo(aRecnos[nX]) )
	lEnviou  := .F.
	lSituaIP := SLX->LX_SITUA == "IN" //Ajuste para Situa 'IN' assim não inutlizar cancelamento da Integração
	
	If SLX->LX_SITUA == "OK"
		LjAtualSLX("X0") //Muda o Status como: iniciado o Cancelamento/Inutilização
		//Faz o monitoramento do documento no TSS e atualiza o STATUS do documento nas tabelas do TSS.
		//Este procedimento ajuda a regularizar o status da tabela SPED050, caso esteja com algum problema.
		LjMonitDoc( SLX->LX_CUPOM, SLX->LX_SERIE, SLX->LX_MODDOC )
	EndIf

	LjGrvLog( SLX->LX_CUPOM, "INICIO - Envio do DOC: [" + SLX->LX_CUPOM + "] Serie: [" +;
	 			SLX->LX_SERIE + "] Modelo: [" + SLX->LX_MODDOC + "] para inutilizacao." )
	
	If lSituaIP //Cancelamento provenientes da Integração
		lEnviou := .T.
	Else
		//Envia o Documento ao TSS para Cancelamento/Inutilizacao
		lEnviou := LjNFCeCanc( SLX->LX_SERIE, SLX->LX_CUPOM, ,SLX->LX_MODDOC )
	EndIf

	LjGrvLog( SLX->LX_CUPOM, "FIM - Envio do DOC: [" + SLX->LX_CUPOM + "] Serie: [" + SLX->LX_SERIE +;
	 		"] Modelo: [" + SLX->LX_MODDOC + "] para inutilizacao. Resultado do Envio: " + If(lEnviou,"Envio OK","Erro no Envio")  )
	
	If lSituaIP
		LjAtualSLX("X2") //Muda o Status como: Documento enviado pois já foi enviada cancelamento/inutilização pelo FrontEnd
	Else
		If lEnviou
			LjAtualSLX("X1") //Muda o Status como: Documento enviado ao TSS para Cancelamento/Inutilização, aguardando autorizacao do SEFAZ
		Else
			//Faz o monitoramento do documento no TSS e atualiza o STATUS do documento nas tabelas do TSS.
			//Este procedimento ajuda a regularizar o status da tabela SPED050, caso esteja com algum problema.
			LjMonitDoc( SLX->LX_CUPOM, SLX->LX_SERIE, SLX->LX_MODDOC )
		EndIf
	EndIf

Next nX

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjCanComLX
Faz o cancelamento/Inutilizacao da NFC-e ou NF-e com base na tabela SLX.

@type       Function
@author     Alberto Deviciente
@since      22/10/2018
@version    12
@return 	Nil, Nulo
/*/
//---------------------------------------------------------------------------------------
Function LjCanComLX()
Local lContinua := .T.

LjGrvLog( Nil, "INICIO - Processo de Inutilizacao dos documentos eletronicos com base na tabela SLX." )

DbSelectArea("SLX")

//Valida se as configuracoes estao corretas para executar a inutilizacao de NFC-e e NF-e.
lContinua := LjVlParInu()

If lContinua
	LjCanInteg( NIL )
	
	LjGrvLog( "Inutilizacao", "Envia ao TSS os Documentos para Inutilizacao" )
	//------------------------------------------------------------
	//* PASSO 1: Envia ao TSS os Documentos para Inutilizacao
	//------------------------------------------------------------
	LjEnviaCan()
	
	LjGrvLog( "Inutilizacao", "Verifica no TSS se a Inutilizacao foi autorizada" )
	//------------------------------------------------------------
	//* PASSO 2: Verifica no TSS se a Inutilizacao foi autorizada
	//------------------------------------------------------------
	LjVerCanOK()
	
	LjGrvLog( "Inutilizacao", "Inclui o DOC no Protheus como 'Cancelado'" )
	//------------------------------------------------------------
	//* PASSO 3: Inclui o DOC no Protheus como "Cancelado"
	//------------------------------------------------------------
	LjIncDocCan()
	
	LjCanInteg( .F. ) //Desativa a parte de cancelamento de venda da integração

Else
	LjGrvLog( "Inutilizacao", "Processamento de inutilizacao pela tabela SLX nao esta " +;
			" implementado ou parâmetros de Inutilização não existentes ou não preenchidos" )
EndIf	

LjGrvLog( Nil, "FIM - Processo de Inutilizacao dos documentos eletronicos com base na tabela SLX." )

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} LjCanInteg
Verifica se efetua o cancelamento se for integração

@type       Function
@author     Julio Nery
@since      05/11/2020
@version    12
@return 	lCanInteg, lógico, é Integracao de Canc/Inut?
/*/
//---------------------------------------------------------------------------------------
Function LjCanInteg(lValue)
Local cQry := ""
Local lLXUUID := SLX->(ColumnPos("LX_UUID")) > 0

Default lValue := NIL

LjGrvLog("LOJA140A","Validação se existe SLX - recepcionada via Integração")

If (lCanInteg == NIL .Or. lValue == NIL) .And. lLXUUID
	cQry := "SELECT"
	cQry += " LX_CUPOM "
	cQry += " FROM " + RetSQLName("SLX")
	cQry += " WHERE "	
	cQry += " LX_UUID <> '' AND "
	cQry += " LX_MODDOC='65' AND LX_SITUA ='IN'" //Ajuste para não buscar IP e inutilizar Cancelamento
	cQry := ChangeQuery(cQry)
	LjGrvLog("LOJA140A","[LjCanInteg] Query a ser executada ->",cQry)
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "INTCANC", .T., .F. )
	
	lCanInteg := !("INTCANC")->(Eof())
	("INTCANC")->(DbCloseArea())
Else
	If lLXUUID
		lCanInteg := lValue
	Else
		LjGrvLog("LOJA140A", "Campo LX_UUID portanto processo de cancelamento/inutilização da SLX Integrada" +;
							" não pode ser executado ! ")
		lCanInteg := .F.
	EndIf	
EndIf

LjGrvLog("LOJA140A","Retorno da validação se existe SLX de venda recepcionada via Integração - Tem dado para cancelar ?",lCanInteg)

Return lCanInteg 
