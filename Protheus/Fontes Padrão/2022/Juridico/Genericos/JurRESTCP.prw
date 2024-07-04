#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "JURRESTCP.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL JurRESTCP DESCRIPTION STR0001 // "Integração Contas a Pagar x PFS."

	WSDATA LEGALDESK  AS STRING
	WSDATA FIELDEMPTY AS STRING
	WSDATA TENANTID   AS STRING
	WSDATA PKSE2      AS STRING

	WSMETHOD POST   JCPCreate DESCRIPTION STR0002 // "Cria Contas a Pagar com desdobramentos."
	WSMETHOD PUT    JCPUpdate DESCRIPTION STR0003 PATH "{PKSE2}" // "Altera Contas a Pagar e seus desdobramentos."
	WSMETHOD GET    JCPGet    DESCRIPTION STR0004 PATH "{PKSE2}" // "Busca Contas a Pagar e seus desdobramentos."
	WSMETHOD DELETE JCPDelete DESCRIPTION STR0005 PATH "{PKSE2}" // "Deleta Contas a Pagar e seus desdobramentos."

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT JCPUpdate
Função para alterar Contas a pagar e seus Desdobramentos.

@param  PKSE2     , caracter, Parâmetro recebido pelo path como o valor da chave unica da SE2 com encode64.
@param  LEGALDESK , caracter ('true' ou 'false'), identifica se a chamada foi feita pelo legaldesk.
@param  FIELDEMPTY, caracter ('true' ou 'false'), identifica se o xml de resposta vai retorna os campos vazios.

@return lRet, lógico, Retorna se o serviço foi concluído com sucesso.

@author bruno.ritter/queizy.nascimento
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT JCPUpdate PATHPARAM PKSE2 HEADERPARAM LEGALDESK, FIELDEMPTY WSRESTFUL JurRESTCP
Local aChildSE2      := {}
Local aChildOHF      := {}
Local aChildOHG      := {}
Local aConvSE2       := {}
Local aAutoSE2       := {}
Local aErroModel     := {}
Local oModelOHG      := Nil
Local oModelOHF      := Nil
Local nTamChvSe2     := 0
Local cResponse      := ""
Local lLegalDesk     := .F.
Local lFieldEmpty    := .F.
Local lRet           := .T.
Local cFilAtu        := cFilAnt
Local cPath          := GetSrvProfString("Startpath","")
Local cFileLog       := Criatrab(,.f.)+".LOG"

	If !Empty(SELF:LEGALDESK)
		lLegalDesk := Upper(SELF:LEGALDESK) == "TRUE"
	EndIf

	If !Empty(SELF:FIELDEMPTY)
		lFieldEmpty := Upper(SELF:FIELDEMPTY) == "TRUE"
	EndIf

	JurSetURL(HTTPHeader("_URL_"))

	If lLegalDesk
		JurSetLD(lLegalDesk)

		nTamChvSe2 := JTamChvSE2() // Retorna o tamanho da chave da SE2
		cChaveSe2  := PADR(Decode64(SELF:PKSE2), nTamChvSe2)

		SE2->(DBSetOrder(1)) // SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
		If SE2->(DbSeek(cChaveSe2))
			cFilAnt := SE2->E2_FILIAL

			Begin Transaction
				// Transforma o xml em array com os dados
				lRet := JReadXML(Self, @aChildSE2, @aChildOHF, @aChildOHG)

				If lRet .And. !Empty(aChildSE2)
					aConvSE2 := JConvStruc("SE2", aChildSE2)
					aAutoSE2 := JIncluiChv(aConvSE2)

					lMsErroAuto := .F.
					MostraErro(cPath, cFileLog) // Limpa os erros da memória.
					MSExecAuto({|x,y,z| FINA050(x,y,z)}, aAutoSE2, Nil, 4)
					If lMsErroAuto
						lRet := .F.
						JRestMsgEr(400, STR0006 + CRLF + MostraErro(cPath, cFileLog)) // "Erro na Execução Automática."
						DisarmTransaction()
					EndIf
				EndIf

				If lRet .And. !Empty(aChildOHF)
					aErroModel := {}
					oModelOHF  := JCriaModel("JURA246", "OHF", aChildOHF, @aErroModel)

					If oModelOHF == Nil
						lRet := .F.
						JRestMsgEr(400, IIF(Len(aErroModel) >= 6, STR0011 + CRLF + aErroModel[6], STR0011)) // "Não foi possivel atualizar o(s) desdobramento(s)."
						DisarmTransaction()
					Else
						oModelOHF:CommitData()
					EndIf
				EndIf

				If lRet .And. !Empty(aChildOHG)
					aErroModel := {}
					oModelOHG  := JCriaModel("JURA247", "OHG", aChildOHG, @aErroModel)

					If oModelOHG == Nil
						lRet := .F.
						JRestMsgEr(400, IIF(Len(aErroModel) >= 6, STR0008+CRLF+aErroModel[6], STR0008)) // "Não foi possível atualizar o desdobramento pós-pagamento."
						DisarmTransaction()
					Else
						oModelOHG:CommitData()
					EndIf
				EndIf
			End Transaction

			If lRet
				cResponse := JGetRespXML(lFieldEmpty)
				Self:SetResponse(cResponse)
			EndIf
		Else
			lRet := .F.
			JRestMsgEr(404, STR0009) // "Chave primária inválida."
		EndIf
	EndIf

	JurSetURL("")
	lLegalDesk := .F.
	cFilAnt    := cFilAtu
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST JurCPCreate
Função para criar Contas a pagar com Desdobramento.

@param  LEGALDESK , caracter ('true' ou 'false'), identifica se a chamada foi feita pelo legaldesk.
@param  FIELDEMPTY, caracter ('true' ou 'false'), identifica se o xml de resposta vai retorna os campos vazios.

@return lRet, lógico, Retorna se o serviço foi concluído com sucesso.

@author bruno.ritter/jorge.martins
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST JCPCreate HEADERPARAM LEGALDESK, FIELDEMPTY, TENANTID WSRESTFUL JurRESTCP

Local aChildSE2      := {}
Local aChildOHF      := {}
Local aAutoSE2       := {}
Local aErroModel     := {}
Local oModel         := Nil
Local cResponse      := ""
Local lLegalDesk     := .F.
Local lFieldEmpty    := .F.
Local lRet           := .T.
Local lDisarmOHF     := .F.
Local cEmpAtu        := cEmpAnt
Local cFilAtu        := cFilAnt
Local cEmpHeader     := ""
Local cFilHeader     := ""
Local cPath          := GetSrvProfString("Startpath","")
Local cFileLog       := Criatrab(,.f.)+".LOG"
Local nRecnoTit      := 0

	If !Empty(SELF:LEGALDESK)
		lLegalDesk := Upper(SELF:LEGALDESK) == "TRUE"
	EndIf

	If !Empty(SELF:FIELDEMPTY)
		lFieldEmpty := Upper(SELF:FIELDEMPTY) == "TRUE"
	EndIf

	If !Empty(SELF:TENANTID)
		cEmpHeader := Left(Upper(SELF:TENANTID), At(",",Upper(SELF:TENANTID))-1)
		cFilHeader := Substr(Upper(SELF:TENANTID), At(",",Upper(SELF:TENANTID))+1)
	EndIf

	cEmpAnt := cEmpHeader
	cFilAnt := cFilHeader
	JurSetURL(HTTPHeader("_URL_"))

	If lLegalDesk
		JurSetLD(lLegalDesk)
		// Transforma o xml em array com os dados
		lRet := JReadXML(Self, @aChildSE2, @aChildOHF)

		If lRet .And. !Empty(aChildSE2)
			aAutoSE2 := JConvStruc("SE2", aChildSE2)
			aAdd(aAutoSE2, {"E2_ORIGEM", "JURCTORC", Nil})

			Begin Transaction
				lMsErroAuto := .F.
				MostraErro(cPath, cFileLog) // Limpa os erros da memória.
				MSExecAuto({|x,y,z| FINA050(x,y,z)}, aAutoSE2, Nil, 3)

				If lMsErroAuto
					lRet := .F.
					JRestMsgEr(400, STR0006 + CRLF + MostraErro(cPath, cFileLog)) // "Erro na Execução Automática"
					DisarmTransaction()

				Else
					nRecnoTit := SE2->(Recno()) // Pega o Recno do título criado
					If !Empty(aChildOHF)
						oModel := JCriaModel("JURA246", "OHF", aChildOHF, @aErroModel)

						If oModel == Nil
							lRet := .F.
							JRestMsgEr(400, IIF(Len(aErroModel) >= 6, STR0007 + CRLF+aErroModel[6], STR0007)) // "Não foi possível incluir o desdobramento."
							DisarmTransaction()
							lDisarmOHF := .T.
						Else
							oModel:CommitData()
						EndIf
					EndIf
				EndIf

				If lRet
					cResponse := JGetRespXML(lFieldEmpty)
					Self:SetResponse(cResponse)
				EndIf
			End Transaction
		
			If lDisarmOHF .And. nRecnoTit == SE2->(Recno()) // Força a exclusão caso o DisarmTransaction não tenha excluído o título
				RecLock("SE2", .F.)
				SE2->(dbDelete())
				SE2->(MsUnLock())
			EndIf
		EndIf
	EndIf

	JurSetURL("")
	lLegalDesk := .F.
	cEmpAnt    := cEmpAtu
	cFilAnt    := cFilAtu
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET JCPGet
Função para criar Contas a pagar com Desdobramento.

@param  PKSE2     , caracter, Parâmetro recebido pelo path como o valor da chave unica da SE2 com encode64.
@param  LEGALDESK , caracter ('true' ou 'false'), identifica se a chamada foi feita pelo legaldesk.
@param  FIELDEMPTY, caracter ('true' ou 'false'), identifica se o xml de resposta vai retorna os campos vazios.

@return lRet, lógico, Retorna se o serviço foi concluído com sucesso.

@author bruno.ritter
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET JCPGet PATHPARAM PKSE2 HEADERPARAM LEGALDESK, FIELDEMPTY  WSRESTFUL JurRESTCP
Local nTamChvSe2     := ""
Local cResponse      := ""
Local lLegalDesk     := .F.
Local cChaveSe2      := ""
Local lFieldEmpty    := .F.
Local lRet           := .T.

	If !Empty(SELF:LEGALDESK)
		lLegalDesk := Upper(SELF:LEGALDESK) == "TRUE"
	EndIf

	If !Empty(SELF:FIELDEMPTY)
		lFieldEmpty := Upper(SELF:FIELDEMPTY) == "TRUE"
	EndIf

	JurSetURL(HTTPHeader("_URL_"))

	If lLegalDesk
		JurSetLD(lLegalDesk)

		nTamChvSe2 := JTamChvSE2()
		cChaveSe2 := PADR(Decode64(SELF:PKSE2), nTamChvSe2)

		SE2->(DBSetOrder(1)) // SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
		If SE2->(DbSeek(cChaveSe2))
			lRet := .T.
			cResponse := JGetRespXML(lFieldEmpty)
			Self:SetResponse(cResponse)

		Else
			lRet := .F.
			JRestMsgEr(404, STR0009) // "Chave primária inválida."
		EndIf
	EndIf

	lLegalDesk := .F.

	JurSetURL("")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE JCPDelete
Função para deletar Contas a pagar e seus Desdobramento.

@param  PKSE2     , caracter, Parâmetro recebido pelo path como o valor da chave unica da SE2 com encode64.
@param  LEGALDESK , caracter ('true' ou 'false'), identifica se a chamada foi feita pelo legaldesk.

@return lRet, lógico, Retorna se o serviço foi concluído com sucesso.

@author bruno.ritter/jorge.martins
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE JCPDelete PATHPARAM PKSE2 HEADERPARAM LEGALDESK WSRESTFUL JurRESTCP
Local aCampos        := {}
Local nTamChvSe2     := 0
Local cChaveSe2      := ""
Local lRet           := .T.
Local lLegalDesk     := .F.
Local cFilAtu        := cFilAnt
Local cPath          := GetSrvProfString("Startpath","")
Local cFileLog       := Criatrab(,.f.)+".LOG"

	If !Empty(SELF:LEGALDESK)
		lLegalDesk := Upper(SELF:LEGALDESK) == "TRUE"
	EndIf

	JurSetURL(HTTPHeader("_URL_"))

	If lLegalDesk
		JurSetLD(lLegalDesk)

		nTamChvSe2 := JTamChvSE2()
		cChaveSe2 := PADR(Decode64(SELF:PKSE2), nTamChvSe2)

		SE2->(DBSetOrder(1)) // SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
		If SE2->(DbSeek(cChaveSe2))
			cFilAnt := SE2->E2_FILIAL

			AAdd(aCampos, {"E2_FILIAL"  , SE2->E2_FILIAL  , Nil})
			AAdd(aCampos, {"E2_PREFIXO" , SE2->E2_PREFIXO , Nil})
			AAdd(aCampos, {"E2_NUM"     , SE2->E2_NUM     , Nil})
			AAdd(aCampos, {"E2_PARCELA" , SE2->E2_PARCELA , Nil})
			AAdd(aCampos, {"E2_TIPO"    , SE2->E2_TIPO    , Nil})
			AAdd(aCampos, {"E2_FORNECE" , SE2->E2_FORNECE , Nil})
			AAdd(aCampos, {"E2_LOJA"    , SE2->E2_LOJA    , Nil})

			lMsErroAuto := .F.
			MostraErro(cPath, cFileLog) // Limpar os erros da memória.
			MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos, Nil, 5)

			If lMsErroAuto
				lRet     := .F.
				JRestMsgEr(400, STR0006+CRLF+MostraErro(cPath, cFileLog)) // "Erro na Execução Automática"
			Else
				lRet := .T.
				Self:SetResponse("true")
			EndIf

		Else
			lRet := .F.
			JRestMsgEr(404, STR0009) // "Chave primária inválida."
		EndIf

	EndIf

	JurSetURL("")
	lLegalDesk := .F.
	cFilAnt    := cFilAtu
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCriaModel
Função para setar os valores dos campos no modelo da OHF ou OHB.

@param cRotina   , caracter, Rotina do modelo.
@param cTab      , caracter, para inserir os dados.
@param aCpoAttXML, array   , Array com os campos/valores e atributos/valores recebidos pela requisição.
@param aErroModel, array   , Passar como referência se for necessário receber o erro em uma variável.

@author bruno.ritter/jorge.martins
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCriaModel(cRotina, cTab, aCpoAttXML, aErroModel)
Local aCpoConv   := {}
Local aSeek      := {}
Local aSeekNUM   := {}
Local aCampos    := {}
Local aAtributos := {}
Local aSetFields := {}
Local aChildNUM  := {}
Local aNUMCpos   := {}
Local oModel     := Nil
Local nItem      := 0
Local nRecno     := 0
Local nPosRecno  := 0
Local nPosName   := 1
Local nPosVal    := 2
Local nPosDelete := 0
Local nItemNUM   := 0
Local cItem      := ""
Local lItem      := .T.
Local cCpoSeekLn :=  cTab + "_CITEM"
Local cChaveLn   := ""
Local cIdDoc     := FINGRVFK7("SE2", SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)

Default aErroModel := {}

	// Pega o maior item do modelo.
	cItem := JurGetItem(cTab, xFilial(cTab), cCpoSeekLn, cIdDoc)

	For nItem := 1 To Len(aCpoAttXML)
		aCampos    := aCpoAttXML[nItem][1]
		aAtributos := aCpoAttXML[nItem][2]
		cCpoSeekLn := cTab + "_CITEM"
		cChaveLn   := ""
		aChildNUM  := Iif(Len(aCpoAttXML[nItem]) >= 3, aCpoAttXML[nItem][3], {})

		nPosRecno  := aScan(aAtributos, {|aAtt| Upper(aAtt[nPosName]) == "INTERNALID" })
		nPosDelete := aScan(aAtributos, {|aAtt| Upper(aAtt[nPosName]) == "DELETED" })

		If nPosRecno > 0
			nRecno := Val(aAtributos[nPosRecno][nPosVal])

			(cTab)->(dbGoTo(nRecno))
			If (cTab)->(Recno()) == nRecno .And. !Empty(cCpoSeekLn)
				aSeek    := {}
				cChaveLn := (cTab)->(FieldGet( FieldPos( cCpoSeekLn )))
				aAdd(aSeek, {cCpoSeekLn, cChaveLn})

				If nPosDelete > 0 .And. aAtributos[nPosDelete][nPosVal] == "1"
					// Limpa os campos/valores para a função JurGrModel() apagar a linha
					aCampos := {}

				ElseIf aScan(aCampos, {|aCpo| aCpo[1] == cCpoSeekLn}) == 0
					//Atribui ao menos um campo, para não deletar o item
					aAdd(aCampos, {cCpoSeekLn, cChaveLn})
				EndIf
			EndIf

		EndIf

		aCpoConv := JConvStruc(cTab, aCampos)
		lItem    := Empty(aSeek)

		JurFreeArr(@aCampos)
		JurFreeArr(@aAtributos)

		For nItemNUM := 1 To Len(aChildNUM)
			aCampos    := aChildNUM[nItemNUM][1]
			aAtributos := aChildNUM[nItemNUM][2]

			nPosRecno  := aScan(aAtributos, {|aAtt| Upper(aAtt[nPosName]) == "INTERNALID"})
			nPosDelete := aScan(aAtributos, {|aAtt| Upper(aAtt[nPosName]) == "DELETED" })

			If nPosRecno > 0
				nRecno := Val(aAtributos[nPosRecno][nPosVal])

				NUM->(dbGoTo(nRecno))
				If NUM->(Recno()) == nRecno
					cCpoSeekLn := "NUM_COD"
					cChaveLn   := NUM->(FieldGet(FieldPos(cCpoSeekLn)))
					aAdd(aSeekNUM, {cCpoSeekLn, cChaveLn})

					If nPosDelete > 0 .And. aAtributos[nPosDelete][nPosVal] == "1"
						// Limpa os campos/valores para a função JurGrModel() apagar a linha
						aCampos := {}

					ElseIf aScan(aCampos, {|aCpo| aCpo[1] == cCpoSeekLn}) == 0
						//Atribui ao menos um campo, para não deletar o item
						aAdd(aCampos, {cCpoSeekLn, cChaveLn})
					EndIf
				EndIf
			EndIf

			Aadd(aNUMCpos, {"NUMDETAIL", AClone(aSeekNUM), JConvStruc("NUM", aCampos), .F., ""})

			JurFreeArr(@aSeekNUM)
			JurFreeArr(@aCampos)
			JurFreeArr(@aAtributos)
		Next nItemNUM

		aAdd(aSetFields, {cTab+"DETAIL", aSeek, aCpoConv, lItem, cItem, AClone(aNUMCpos)})
		JurFreeArr(@aNUMCpos)
		aCpoConv := {}
		aSeek    := {}
	Next nItem

	oModel := JurGrModel(cRotina, 4, {}, aSetFields, @aErroModel)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JReadXML()
Lê o xml e retorna o valores em array para o incluir/alterar o
contas a pagar SE2, OHF e OHG

@param oWsRestFul, objeto, Objeto do Rest 'WSRESTFUL'.
@param @aChildSE2, array , Array para receber os dados da SE2.
@param @aChildOHF, array , Array para receber os dados da OHF.
@param @aChildOHG, array , Array para receber os dados da OHG.

@Return lRet, lógico, Retorno se foi executado a função.

@author bruno.ritter/jorge.martins
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JReadXML(oWsRestFul, aChildSE2, aChildOHF, aChildOHG)
Local lRet        := .T.
Local lNext       := .T.
Local lTemFilho   := .T.
Local oXml        := TXmlManager():New()
Local cContent    := ""
Local cTpBody     := Upper(Substr(oWsRestFul:GetAccept(), At("/", oWsRestFul:GetAccept()) + 1)) 
Local nI          := 0
Local nItensNode  := 0
Local aChildNUM   := {}

Default aChildOHG := {}

	If cTpBody != "XML"
		lRet := .F.
		JRestMsgEr(400, STR0010) // "Não foi possível ler o Body, é apenas aceito XML."
	Else
		// Leitura do Body
		cContent  := oWsRestFul:GetContent()
	EndIf

	If lRet .And. !Empty(cContent)
		If oXML:Parse( cContent )
			cContent := DecodeUtf8(cContent)

			// Ignora tudo que estiver em cima da tag JUR-CP
			While lTemFilho .And. Upper(oXml:CNAME) != "JUR-CP"
				lTemFilho := oXML:DOMChildNode()
			EndDo

			If lTemFilho
				oXML:DOMChildNode()
				
				While lNext
					If Upper(oXml:CNAME) == "SE2MODEL"
						aChildSE2 := oXML:DOMGetChildArray()
					EndIf

					If Upper(oXml:CNAME) == "OHFDETAIL"
						If oXML:DOMChildNode() .And. Upper(oXml:CNAME) == "ITENS"
							If oXML:DOMChildNode() .And. Upper(oXml:CNAME) == "ITEM"
				
								nItensNode := oXML:DOMSiblingCount()
								For nI := 1 to nItensNode
									// Anexos
									aChildNUM := GetAnexNode(oXml)
									// Fim Anexos
									aAdd(aChildOHF, {oXML:DOMGetChildArray(), oXML:DOMGetAttArray(), aChildNUM})
									oXml:DOMNextNode()
								Next nI
								oXML:DOMParentNode()

							EndIf
							oXML:DOMParentNode()

						EndIf
					EndIf

					If Upper(oXml:CNAME) == "OHGDETAIL"
						If oXML:DOMChildNode() .And. Upper(oXml:CNAME) == "ITENS"
							If oXML:DOMChildNode() .And. Upper(oXml:CNAME) == "ITEM"
				
								nItensNode := oXML:DOMSiblingCount()
								For nI := 1 To nItensNode
									// Anexos
									aChildNUM := GetAnexNode(oXml)
									// Fim Anexos
									aAdd(aChildOHG, {oXML:DOMGetChildArray(), oXML:DOMGetAttArray(), aChildNUM})
									oXml:DOMNextNode()
								Next nI

								oXML:DOMParentNode()
							EndIf

							oXML:DOMParentNode()
						EndIf
					EndIf

					lNext := oXml:DOMNextNode()
				EndDo

			Else
				lRet := .F.
				JRestMsgEr(400, "XML inválido") // "XML inválido"
			EndIf
		Else
			lRet := .F.
			JRestMsgEr(400, "XML inválido") // "XML inválido"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JConvStruc
Converte os campos conforme o dbStruc para o execAuto.

@param cTab    -> Tabela para usar o dbStruc.
@param aCampos -> Array com um subArray dos campos e valores
                  aCampos[1]
                  aCampos[1][1] "E2_FILIAL"
                  aCampos[1][2] "M SP 01"

@author bruno.ritter/jorge.martins
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JConvStruc(cTab, aCampos)
Local aStruct    := (cTab)->(DBStruct())
Local aConvCpo   := {}
Local nI         := 1
Local nY         := 1
Local xValor     := Nil
Local cCampo     := ""
Local cCpoStruct := ""
Local cTipoCpo   := ""
Local cValorCpo  := ""

	For nI := 1 To Len(aCampos)
		cCampo    := aCampos[nI][1]
		cValorCpo := aCampos[nI][2]

		For nY := 1 To Len(aStruct)
			cCpoStruct := aStruct[nY][1]
			cTipoCpo   := aStruct[nY][2]

			If cCampo == cCpoStruct
				Do Case
					Case cTipoCpo == 'N'
						xValor := Val(cValorCpo)

					Case cTipoCpo == 'D'
						xValor := SToD(cValorCpo)

					Otherwise
						xValor := cValorCpo
				EndCase

				aAdd(aConvCpo, {cCampo, xValor, Nil} )
			EndIf
		Next nY
	Next nI

Return aConvCpo

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetRespXML
Retorna Xml com os dados do contas a pagar e desdobramentos com base na SE2 posicionada

@param lFieldEmpty, lógico, identifica se o xml de resposta vai retorna os campos vazios.

@author bruno.ritter/queizy.nascimento
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetRespXML(lFieldEmpty)
Local cXml       := ""
Local cChave     := SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
Local cIdDoc     := FINGRVFK7("SE2", SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)
Local lWorkSite  := AllTrim( SuperGetMv("MV_JDOCUME", , "1")) == "1"
Local lJurClass  := FindFunction("JurHasClas") .And. JurHasClas()
Local nIndexNUM  := IIF(lJurClass, 5, 3)
Local cPk        := ""

	cPk    := Encode64(cChave)

	cXml := "<?xml version='1.0' encoding='UTF-8'?>"
	cXml += "<result>"
	cXml +=     "<resources>"
	cXml +=         "<JUR-CP pk='"+ cPk +"'>"
	cXml +=             "<SE2MODEL>"
	cXml +=                 JGetDados("SE2", lFieldEmpty)
	cXml +=             "</SE2MODEL>"

	OHF->(DBSetOrder(1)) // OHF_FILIAL + OHF_IDDOC + OHF_CITEM
	
	NUM->(DBSetOrder(nIndexNUM)) // 5 - NUM_FILIAL + NUM_ENTIDA + NUM_FILENT + NUM_CENTID ## 3 - NUM_FILIAL + NUM_ENTIDA + NUM_CENTID

	If OHF->(DbSeek(SE2->E2_FILIAL + cIdDoc))
		cXml +=             "<OHFDETAIL>"
		cXml +=                 "<itens>"
		While OHF->OHF_FILIAL == SE2->E2_FILIAL .And. OHF->OHF_IDDOC == cIdDoc
			cXml +=                 "<item internalId='"+ cValToChar(OHF->(Recno())) +"' deleted='0'>"
			cXml +=                      JGetDados("OHF", lFieldEmpty)
			// Inicio Anexos
			If NUM->(DbSeek(xFilial("NUM") + "OHF" + OHF->OHF_FILIAL + cIdDoc + OHF->OHF_CITEM))
				cXml +=             "<NUMDETAIL>"
				cXml +=                 "<itens>"
				While NUM->NUM_FILIAL == xFilial("NUM") .And. NUM->NUM_ENTIDA == "OHF" .And. NUM->NUM_FILENT == OHF->OHF_FILIAL .And.;
				      NUM->NUM_CENTID == PadR(IIF(lJurClass .Or. lWorkSite, "", OHF->OHF_FILIAL) + cIdDoc + OHF->OHF_CITEM, TamSX3('NUM_CENTID')[1])
					cXml +=                 "<item internalId='"+ cValToChar(NUM->(Recno())) +"' deleted='0'>"
					cXml +=                      JGetDados("NUM", lFieldEmpty)
					cXml +=                 "</item>"
					NUM->( dbSkip() )
				EndDo
				cXml +=                 "</itens>"
				cXml +=             "</NUMDETAIL>"
			EndIf
			// Fim Anexos
			cXml +=                 "</item>"
			OHF->( dbSkip() )
		EndDo
		cXml +=                 "</itens>"
		cXml +=             "</OHFDETAIL>"
	EndIf

	OHG->(DBSetOrder(1)) // OHG_FILIAL + OHG_IDDOC + OHG_CITEM
	If OHG->(DbSeek(SE2->E2_FILIAL + cIdDoc))
		cXml +=             "<OHGDETAIL>"
		cXml +=                 "<itens>"
		While OHG->OHG_FILIAL == SE2->E2_FILIAL .And. OHG->OHG_IDDOC == cIdDoc
			cXml +=                 "<item internalId='"+ cValToChar(OHG->(Recno())) +"' deleted='0'>"
			cXml +=                      JGetDados("OHG", lFieldEmpty)
			// Inicio Anexos
			If NUM->(DbSeek(xFilial("NUM") + "OHG" + OHG->OHG_FILIAL + cIdDoc + OHG->OHG_CITEM))
				cXml +=             "<NUMDETAIL>"
				cXml +=                 "<itens>"
				While NUM->NUM_FILIAL == xFilial("NUM") .And. NUM->NUM_ENTIDA == "OHG" .And. NUM->NUM_FILENT == OHG->OHG_FILIAL .And.;
				      NUM->NUM_CENTID == PadR(IIF(lJurClass .Or. lWorkSite, "", OHG->OHG_FILIAL) + cIdDoc + OHG->OHG_CITEM, TamSX3('NUM_CENTID')[1])
					cXml +=                 "<item internalId='"+ cValToChar(NUM->(Recno())) +"' deleted='0'>"
					cXml +=                      JGetDados("NUM", lFieldEmpty)
					cXml +=                 "</item>"
					NUM->( dbSkip() )
				EndDo
				cXml +=                 "</itens>"
				cXml +=             "</NUMDETAIL>"
			EndIf
			// Fim Anexos
			cXml +=                 "</item>"
			OHG->( dbSkip() )
		EndDo
		cXml +=                 "</itens>"
		cXml +=             "</OHGDETAIL>"
	EndIf

	cXml +=         "</JUR-CP>"
	cXml +=     "</resources>"
	cXml += "</result>"

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetDados
Retorna Xml com os dados da tabela

@param lFieldEmpty, lógico, identifica se o xml de resposta vai retorna os campos vazios.

@author bruno.ritter/queizy.nascimento
@since 11/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGetDados(cTab, lFieldEmpty)
Local aStruct  := (cTab)->(DBStruct())
Local nCpo     := 0 
Local cValConv := ""
Local cCampo   := ""
Local cXml     := ""
Local cTipoCpo := ""
Local xValue   := Nil

	For nCpo := 1 To Len(aStruct)
		cCampo   := aStruct[nCpo][1]
		cTipoCpo := aStruct[nCpo][2]
		xValue   := (cTab)->(FieldGet( FieldPos( cCampo )))
		
		If !Empty(xValue)
			If cTipoCpo == "D"
				cValConv := DToS( xValue )
			Else
				cValConv := cValToChar(xValue )
			EndIf
		Else
			cValConv := ""
		EndIf

		If lFieldEmpty .Or. !Empty(cValConv)
			cXml += "<"+ cCampo +">"+ EncodeUTF8(AllTrim(cValConv)) +"</"+ cCampo +">"
		EndIf
	Next nCpo

Return cXml

//-------------------------------------------------------------------
/*/{Protheus.doc} JIncluiChv
Inclui a chave única no array para exec auto da Fina050.

@param aCpoExcAut, array, Com os campos/valores do ExecAuto da fina050

@obs Utiliza os valores da tabela SE2 posicionada.

@author bruno.ritter/queizy.nascimento
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JIncluiChv(aCpoExcAut)
Local aChvUnica  := {"E2_FILIAL", "E2_PREFIXO", "E2_NUM", "E2_PARCELA", "E2_TIPO", "E2_FORNECE", "E2_LOJA"}
Local nCpo       := 0
Local nPosCpoChv := 0
Local xValue     := ""

	For nCpo := 1 To Len(aChvUnica)
		xValue     := SE2->(FieldGet( FieldPos(aChvUnica[nCpo])))
		nPosCpoChv := aScan(aCpoExcAut, {|aCampo| aCampo[1] == aChvUnica[nCpo] })

		If nPosCpoChv > 0
			aCpoExcAut[nPosCpoChv][2] := xValue
		Else
			aAdd(aCpoExcAut, {aChvUnica[nCpo], xValue, Nil})
		EndIf
	Next nCpo

Return aCpoExcAut

//-------------------------------------------------------------------
/*/{Protheus.doc} JRestMsgEr
Inclui uma mensagem de erro no resto

nCode   , numérico, Código de erro da API REST
cMessage, caracter, Mensagem de erro da API REST.

@author bruno.ritter/queizy.nascimento
@since 13/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRestMsgEr(nCode, cMessage)
Default nCode     := 400
Default cMessage  := ""

	SetRestFault(nCode, EncodeUTF8(cMessage))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTamChvSE2
Retorna o tamanho da chava da SE2

@author bruno.ritter/queizy.nascimento
@since 13/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTamChvSE2()
Local nTamChvSe2 := 0

	nTamChvSe2 := TamSx3("E2_FILIAL")[1]
	nTamChvSe2 += TamSx3("E2_PREFIXO")[1]
	nTamChvSe2 += TamSx3("E2_NUM")[1]
	nTamChvSe2 += TamSx3("E2_PARCELA")[1]
	nTamChvSe2 += TamSx3("E2_TIPO")[1]
	nTamChvSe2 += TamSx3("E2_FORNECE")[1]
	nTamChvSe2 += TamSx3("E2_LOJA")[1]

Return nTamChvSe2
//-------------------------------------------------------------------
/*/{Protheus.doc} GetAnexNode
Percorre o XML buscando os anexos dos desdobramentos 

@param oXml      , objeto  , Objeto do XML

@Return aChildNUM, array   , Retorna as linhas de anexo do XML

@author Jonatas Martins
@since 05/07/2019
/*/
//-------------------------------------------------------------------
Static Function GetAnexNode(oXml)
	Local aChildNUM  := {}
	Local nItensAnex := 0
	Local nAnex      := 0
	Local lExistNUM  := .F.
	Local lContinue  := .T.

	If oXML:DOMChildNode() //Primeiro campo da OHF ou OHG

		lExistNUM := Upper(oXml:CNAME) == "NUMDETAIL"

		While !lExistNUM .And. lContinue
			lContinue := oXml:DOMNextNode()
			lExistNUM := Upper(oXml:CNAME) == "NUMDETAIL"
		EndDo
		
		If lExistNUM
			// Verificar se existe itens de anexos
			If oXML:DOMChildNode() .And. Upper(oXml:CNAME) == "ITENS" // NUMDETAIL/ITENS
				// Percorre os itens de anexos
				If oXML:DOMChildNode() .And. Upper(oXml:CNAME) == "ITEM" // NUMDETAIL/ITENS/ITEM
					nItensAnex := oXML:DOMSiblingCount()
					For nAnex := 1 to nItensAnex
						aAdd(aChildNUM, {oXML:DOMGetChildArray(), oXML:DOMGetAttArray()})
						oXml:DOMNextNode()
					Next nAnex
					oXML:DOMParentNode()
				EndIf
				oXML:DOMParentNode()
			EndIf
			
			// Retorna ao nó "item" da OHF ou OHG
			oXML:DOMParentNode()
		Else
			oXML:DOMParentNode()
		EndIf
	EndIf
Return (aChildNUM)


