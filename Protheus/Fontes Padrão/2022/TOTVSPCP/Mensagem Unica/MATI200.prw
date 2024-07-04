#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "MATI200.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

Static __GhostSG1 := Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI200

Funcao de integracao com o adapter EAI para recebimento do  cadastro de
Estrutura (SG1) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@param   aRegDel       Registros deletados da Tree que não deverão retornar na query

@author  Lucas Konrad França
@version P118
@since   22/03/2016
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
        o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
        TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
        O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Function MATI200(cXml, nTypeTrans, cTypeMessage, aRegDel)
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local aRet        := {}

   Private lIntegPPI := .F.
   Private oXml      := Nil

   Default aRegDel   := {}
   //Verifica se está sendo executado para realizar a integração com o PPI.
   //Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
   //Variável é criada no fonte mata200.prw, na função mata200PPI().
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      /*
         Mensagem desenvolvida para integração com o PCFactory, não possui recebimento.
      */
   ElseIf nTypeTrans == TRANS_SEND
      If lIntegPPI
         aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml, aRegDel)
			lRet    := aRet[1]
			cXMLRet := aRet[2]
	   EndIf
   EndIf


Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para envio do  cadastro de
Estrutura (SG1) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@param   aRegDel       Registros deletados da Tree que não deverão retornar na query

@author  Lucas Konrad França
@version P118
@since   24/03/2016
@return  aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml, aRegDel)
	Local lRet       := .T.
	Local lLog       := .T. //FindFunction("AdpLogEAI")
	Local lPCPREVATU := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
	Local cXMLRet    := ""
	Local cEvent     := ""
	Local cEntity    := "ItemStructure"
	Local cCodPai    := ""
	Local cFiltro    := ""
	Local cQuery     := ""
	Local cAliasG1   := GetNextAlias()
	Local cRevAtu    := ""
	Local aAreaAnt   := GetArea()
	Local aAreaSG1   := SG1->(GetArea())
	Local aAreaSB1   := SB1->(GetArea())
	Local nItemAmont := 0
	Local cRegs      := ''
	Local nI         := 0

	If !lIntegPPI
		IIf(lLog, AdpLogEAI(1, "MATI200", nTypeTrans, cTypeMessage, cXML), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
	EndIf

	If nTypeTrans == TRANS_RECEIVE
		/*
			Mensagem desenvolvida para integração com o PCFactory, e nao possui recebimento.
		*/
	ElseIf nTypeTrans == TRANS_SEND
		// Verifica se é uma exclusão
		If !Inclui .And. !Altera
			cEvent := 'delete'
		Else
			cEvent := 'upsert'
		EndIf

		cCodPai := SG1->G1_COD

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))

		If Type("nQtdBase") == "N" .And. nQtdBase != SB1->B1_QB
			If Type("cProduto") == "C" .And. AllTrim(cProduto) == AllTrim(SG1->G1_COD)
				nItemAmont := nQtdBase
			Else
				nItemAmont := SB1->B1_QB
			EndIf
		Else
			nItemAmont := SB1->B1_QB
		EndIf

		cRevAtu    := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)

		// Monta XML de envio de mensagem unica
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
		cXMLRet +=    '<Event>' + cEvent + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalID">' + IntEstrExt(/*Empresa*/, /*Filial*/, SG1->G1_COD, /*Versão*/)[2] + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<CompanyInternalId>'+cEmpAnt+'</CompanyInternalId>'
		cXMLRet +=    '<CompanyCode>'+cEmpAnt+"|"+cFilAnt+'</CompanyCode>'
		cXMLRet +=    '<ItemInternalId>'+cEmpAnt+"|"+cFilAnt+"|"+ RTrim(SG1->G1_COD)+'</ItemInternalId>'
		cXMLRet +=    '<ItemCode>'+ RTrim(SG1->G1_COD)+'</ItemCode>'
		cXMLRet +=    '<ItemAmount>'+cValToChar(nItemAmont)+'</ItemAmount>'
		If cEvent != 'delete'
			SG1->(dbSetOrder(1))
			SGF->(dbSetOrder(3))

			//Verifica se existe algum filtro para a tabela na SOE
			If lIntegPPI
				dbSelectArea("SOE")
				SOE->(dbSetOrder(1))
				If SOE->(dbSeek(xFilial("SOE")+"SG1"))
					cFiltro := SOE->OE_FILTRO
					//Troca as aspas duplas por simples.
					cFiltro := StrTran(cFiltro,'"',"'")
				EndIf
			EndIf

			cQuery := " SELECT SG1.R_E_C_N_O_ G1REC "
			cQuery +=   " FROM " + RetSqlName("SG1") + " SG1 "
			cQuery +=  " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
			cQuery +=    " AND SG1.D_E_L_E_T_ = ' '"
			cQuery +=    " AND SG1.G1_COD     = '" + SG1->G1_COD + "' "
			cQuery +=    " AND (SG1.G1_REVINI <= '"+cRevAtu+"' AND SG1.G1_REVFIM >= '"+cRevAtu+"') "
			If lIntegPPI .And. !Empty(cFiltro)
				cQuery += " AND " + cFiltro
			EndIf
			For nI := 1 to Len(aRegDel)
				If aRegDel[nI][2] == 2 //Só retirar o que foi deletado
					If !Empty(cRegs)
						cRegs += ", "
					EndIf
					cRegs += AllTrim(Str(aRegDel[nI][1]))
				EndIf
			Next nI
			If !Empty(cRegs)
				cQuery += " AND R_E_C_N_O_ NOT IN (" + cRegs + ")"
			EndIf

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasG1,.T.,.T.)

			//Se não encontrou registro.
			If (cAliasG1)->(Eof())
				cXMLRet += '<ListOfItensStructure />'
			Else
				cXMLRet += '<ListOfItensStructure>'
				While (cAliasG1)->(!Eof())
					SG1->(dbGoTo((cAliasG1)->(G1REC)))
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
					cXMLRet += '<ItemComponent>'
					cXMLRet +=    '<ItemSequence>'+SG1->G1_TRT+'</ItemSequence>'
					cXMLRet +=    '<ItemComponentCode>'+ RTrim(SG1->G1_COMP)+'</ItemComponentCode>'
					cXMLRet +=    '<ItemComponentInternalId>'+cEmpAnt+cFilAnt+ RTrim(SG1->G1_COMP)+'</ItemComponentInternalId>'
					cXMLRet +=    '<InitialDate>'+getDate(SG1->G1_INI)+'</InitialDate>'
					cXMLRet +=    '<FinalDate>'+getDate(SG1->G1_FIM)+'</FinalDate>'
					cXMLRet +=    '<IsGhostMaterial>'+IsGhost()+'</IsGhostMaterial>'
					cXMLRet +=    '<ItemComponentAmount>'+cValToChar(SG1->G1_QUANT)+'</ItemComponentAmount>'
					cXMLRet +=    '<ItemComponentProportion />'
					cXMLRet +=    '<LossFactor>'+cValToChar(SG1->G1_PERDA)+'</LossFactor>'
					If SGF->(dbSeek(xFilial("SGF")+SG1->(G1_COD+G1_COMP)))
						cXMLRet += '<ListOfScript>'
						While SGF->(!Eof()) .And. SGF->(GF_FILIAL+GF_PRODUTO+GF_COMP) == xFilial("SGF")+SG1->(G1_COD+G1_COMP)
							cXMLRet += '<Script>'
							cXMLRet +=    '<ScriptCode>'+SGF->GF_ROTEIRO+'</ScriptCode>'
							cXMLRet +=    '<ScriptAlternative />'
							cXMLRet +=    '<ActivityInternalID />'
							cXMLRet +=    '<ActivityCode>'+SGF->GF_OPERAC+'</ActivityCode>'
							cXMLRet +=    '<ActivityComponentSequence>'+SGF->GF_TRT+'</ActivityComponentSequence>'
							cXMLRet += '</Script>'
							SGF->(dbSkip())
						End
						cXMLRet += '</ListOfScript>'
					Else
						cXMLRet += '<ListOfScript />'
					EndIf
					cXMLRet += '</ItemComponent>'
					(cAliasG1)->(dbSkip())
				End
				cXMLRet += '</ListOfItensStructure>'
			EndIf
			(cAliasG1)->(dbCloseArea())
		Else
			cXMLRet += '<ListOfItensStructure />'
		EndIf

		cXmlRet += '</BusinessContent>'

		If lIntegPPI
			completXml(@cXMLRet)
		EndIf
	EndIf

	If !lIntegPPI
		IIf(lLog, AdpLogEAI(5, "MATI200", cXMLRet, lRet), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
	EndIf
	SG1->(RestArea(aAreaSG1))
	SB1->(RestArea(aAreaSB1))
	RestArea(aAreaAnt)
Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntEstrExt
Monta o InternalID da estrutura de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cProdPai   Código do Produto pai
@param   cVersao    Versão da mensagem única (Default 1.000)

@author  Lucas Konrad França
@version P118
@since   04/04/2016
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntEstrExt(,,'01') irá retornar {.T.,'01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntEstrExt(cEmpresa, cFil, cProdPai, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SG1')
   Default cVersao  := '1.001'

   If cVersao == '1.001'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cProdPai))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0005 + Chr(10) + STR0006) // "Versão do recurso não suportada." "As versões suportadas são: 1.001"
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   13/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
   Local cCabec     := ""
   Local cCloseTags := ""
   Local cGenerated := ""

   cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/ItemStructure_1_001.xsd">'
   cCabec +=     '<MessageInformation version="1.001">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>ItemStructure</Transaction>'
   cCabec +=         '<StandardVersion>1.0</StandardVersion>'
   cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
   cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
   cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
   cCabec +=         '<UserId>'+__cUserId+'</UserId>'
   cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
   cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
   cCabec +=         '<ContextName>PROTHEUS</ContextName>'
   cCabec +=         '<DeliveryType>Sync</DeliveryType>'
   cCabec +=     '</MessageInformation>'
   cCabec +=     '<BusinessMessage>'

   cCloseTags := '</BusinessMessage>'
   cCloseTags += '</TOTVSMessage>'

   cXML := cCabec + cXML + cCloseTags

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDate()
Formata uma data para o padrão enviado por XML (YYYY-MM-DD)

@param   dDate  - Data que será transformada para String

@author  Lucas Konrad França
@version P12
@since   04/04/2016
@return  cDate
/*/
//-------------------------------------------------------------------
Static Function getDate(dDate)
   Local cDate     := ""

   If !Empty(dDate)
      cDate := DtoS(dDate)
      cDate := SubStr(cDate, 1, 4) + '-' + SubStr(cDate, 5, 2) + '-' + SubStr(cDate, 7, 2)
   EndIf
Return cDate

/*/{Protheus.doc} IsGhost()
Verifica se o produto é fanstasma
@author  Marcelo Neumann
@version P12
@since   14/05/2020
@return  cFantasma, caracter, indica se o produto é fantasma ("TRUE") ou não ("FALSE")
/*/
Static Function IsGhost()

	Local cFantasma := ""

	If __GhostSG1 == Nil
		__GhostSG1 := SG1->(FieldPos("G1_FANTASM")) > 0
	EndIf

	If __GhostSG1
		If SG1->G1_FANTASM == '1'
			cFantasma := "TRUE"
	    ElseIf SG1->G1_FANTASM <> ' '
			cFantasma := "FALSE"
		EndIf
	EndIf

	If Empty(cFantasma)
		If SB1->B1_FANTASM == "S"
			cFantasma := "TRUE"
		Else
			cFantasma := "FALSE"
		End
	EndIf

Return cFantasma