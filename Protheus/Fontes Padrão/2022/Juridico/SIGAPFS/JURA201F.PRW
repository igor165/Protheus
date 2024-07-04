#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201F.CH"

Static __xFilNX6 := xFilial("NX6")
Static __xFilNXQ := xFilial("NXQ")
Static __xFilCTP := xFilial("CTP")
Static __xFilNXR := xFilial("NXR")
Static __xFilNXF := xFilial("NXF")

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201FConv()
Rotina obter as taxas e o valor de conversão utilizadas no faturamento

@Param cMoeda1    Moeda do Faturamento
@Param cMoeda2    Moeda da Condição (Ex: moeda do lançamento a ser convertido)
@Param nVlOrig    Valor na Moeda de condição (valor à ser convertido)
@Param cTpExec    Tipo de Execução da Rotina de Faturamento:
                    1 - Pré-Fatura
                    2 - Regerar Pré
                    3 - Minuta de Pré
                    4 - Minuta da Fatura
                    5 - Fatura
                    6 - Reemitir Pré Fatura de fatura cancelada
                    7 - Conferência / Fatura
                    8 - Gerar Tittulo
                    9 - Fatura SISCOSERV
                    A - Utiliza a cotação enviada por parâmetro "nTaxaConv"
@Param dCotacao   Data da Cotação diária ou para cotação mensal
@Param cCodFImpr  Código da Fila de Impressão de Fatura (Conversão feita pelas cotações da Fila)
@Param cPreFt     Código da Pré-Fatura (Conversão feita pelas cotações da Pré-Fatura)
@Param cXFilial   Código da Filial usada para conversão
@Param cEscr      Código do Escritório da Fatura
@Param cFatura    Código da Fatura (Conversão feita pelas cotações da Fatura)
@Param cTipoConf  Ignora o parametro MV_JTPCONF e força a cotação '1' = Mesma da Fatura / '2' = Cotação Diária
@Param nDecimal   Controla a precisão de casas decimais que será feita a converção
@Param nTaxaConv  Taxa para conversão (cMoeda2) dos valores
@Param nTaxaMoe1  Taxa para conversão (cMoeda1) dos valores

@Return    aRet    [1] Valor Convertido
                    [2] Taxa 1 (Taxa do faturamento)
                    [3] Taxa 2 (Taxa da condição)
                    [4] Texto com o erro ao obter cotação
                    [5] fator de conversão com precisão de decimal de ponto fixo

@author David G. Fernandes
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201FConv(cMoeda1, cMoeda2, nVlOrig, cTpExec, ;
					dCotacao, cCodFImpr, cPreFt, cXFilial, ;
					cEscr, cFatura, cTipoConf, nDecimal, ;
					nTaxaConv, nTaxaMoe1 )
Local aArea       := GetArea()
Local aRet        := {}
Local cMoedaNac   := SuperGetMv('MV_JMOENAC',, '01')
Local cTipoConv   := SuperGetMv('MV_JTPCONV',, '1' )  // Cotação '1' = Diária / '2' = Mensal
Local nValorConv  := 0
Local nTaxa1      := 1.0
Local nTaxa2      := 1.0
Local lCotac1     := .F. // Busca a cotação do período
Local lCotac2     := .F.
Local lMensal     := .F.
Local cErro       := ""
Local pFatorConv  := DEC_CREATE('1', 64, 18) //Decimal de ponto fixo para aumentar a precisão da conversão
Local pValorConv  := DEC_CREATE('0', 64, 18) //Decimal de ponto fixo para aumentar a precisão da conversão
Local aCotac      := {}

Default cXFilial  := __xFilCTP
Default cTipoConf := SuperGetMv('MV_JTPCONF',, '1' )  // Cotação usada nos titulos '1' = Mesma da Fatura / '2' = Cotação Diária
Default nVlOrig   := 0
Default dCotacao  := Date()
Default nDecimal  := 18
Default nTaxaConv := 1
Default nTaxaMoe1 := 1

If Empty(__xFilCTP) //Verifica se a tabela é compartilhada
	cXFilial  := __xFilCTP
EndIf

If ((cMoeda1 == cMoeda2) .And. (cMoeda1 == cMoedaNac)) .Or. (nVlOrig == 0)
	
	aRet := {nVlOrig, nTaxa2, nTaxa1, cErro, pFatorConv}
	
Else

	If (cTipoConv == "2") .And. (cTpExec != "9")
		lMensal := .T.
	EndIf
	
	If (cTipoConf == "2") .And. (cTpExec == "8")
		lMensal := .F.
	
	ElseIf (cTpExec == "8") //Cotação da Fatura
		aCotac  := J201FCotFat(cMoeda1, cMoedaNac, cEscr, cFatura)
		nTaxa1  := aCotac[1]
		lCotac1 := aCotac[2]

		aCotac  := J201FCotFat(cMoeda2, cMoedaNac, cEscr, cFatura)
		nTaxa2  := aCotac[1]
		lCotac2 := aCotac[2]
	
	ElseIf !Empty(cCodFImpr) //Fila de Emissão de Fatura

		aCotac  := J201FCotFil(cMoeda1, cMoedaNac, cCodFImpr)
		nTaxa1  := aCotac[1]
		lCotac1 := aCotac[2]

		aCotac := J201FCotFil(cMoeda2, cMoedaNac, cCodFImpr)
		nTaxa2  := aCotac[1]
		lCotac2 := aCotac[2]
		
	ElseIf cTpExec $ "2|6" // Refazer  pré-fatura | Refazer  pré-fatura de Fatura cancelada 
		
		aCotac  := J201FCotPre(cMoeda1, cMoedaNac, cPreFt)
		nTaxa1  := aCotac[1]
		lCotac1 := aCotac[2]

		aCotac  := J201FCotPre(cMoeda2, cMoedaNac, cPreFt)
		nTaxa2  := aCotac[1]
		lCotac2 := aCotac[2]

	ElseIf cTpExec == "A" // Taxa Moeda 2 recebida por parâmetro
		nTaxa1  := nTaxaMoe1
		nTaxa2  := nTaxaConv
		lCotac1 := .T.
		lCotac2 := .T.
		
	Else //Força a busca pela cotação do periodo (diária / mensal)
		
		lCotac1 := .F.
		lCotac2 := .F.
		
	EndIf
	
	If !lCotac1 .Or. !lCotac2 //Se não localizou umas das cotações, faz a busca conforme o aparametro MV_JTPCONV
		If !lMensal
			If !lCotac1
				aCotac  := J201FCotDia(cMoeda1, cMoedaNac, dCotacao, cXFilial)
				nTaxa1  := aCotac[1]
				lCotac1 := aCotac[2]
				cErro   := aCotac[3]
			EndIf

			If !lCotac2
				aCotac  := J201FCotDia(cMoeda2, cMoedaNac, dCotacao, cXFilial)
				nTaxa2  := aCotac[1]
				lCotac2 := aCotac[2]
				cErro   += Iif(!Empty(aCotac[3]), +CRLF, "") + aCotac[3]
			EndIf
		Else
			If !lCotac1
				aCotac  := J201FCotMes(cMoeda1, cMoedaNac, dCotacao)
				nTaxa1  := aCotac[1]
				lCotac1 := aCotac[2]
				cErro   := aCotac[3]
			EndIf

			If !lCotac2
				aCotac  := J201FCotMes(cMoeda2, cMoedaNac, dCotacao)
				nTaxa2  := aCotac[1]
				lCotac2 := aCotac[2]
				cErro   += Iif(!Empty(aCotac[3]), + CRLF, "") + aCotac[3]
			EndIf
		EndIf
	EndIf
	
	If (lCotac1 .And. lCotac2)
		If (cMoeda1 == cMoeda2)
			nValorConv := nVlOrig
			
			If (cMoeda1 == cMoedaNac)
				nTaxa1 := 1.0
				nTaxa2 := 1.0
			Else
				nTaxa1 := IIf(nTaxa1 == 0, 1.0, nTaxa1)
				nTaxa2 := IIf(nTaxa2 == 0, 1.0, nTaxa2)
			EndIf
		Else
			If (nTaxa1 > 0) .And. (nTaxa2 > 0)
				pFatorConv := DEC_DIV(DEC_CREATE(cValToChar(nTaxa2), 64, nDecimal), DEC_CREATE(cValToChar(nTaxa1), 64, nDecimal))
				pValorConv := DEC_CREATE(cValToChar(nVlOrig), 64, nDecimal)
				nValorConv := Val(cValToChar(DEC_RESCALE(DEC_MUL(pFatorConv, pValorConv), nDecimal, 0)))
			Else //Sem Taxa
				nValorConv := nVlOrig
				nTaxa1 := 1.0
				nTaxa2 := 1.0
			EndIf
		EndIf
		
	Else
		nValorConv := nVlOrig
		nTaxa1     := 1.0
		nTaxa2     := 1.0
	EndIf
	
	aRet := {nValorConv, nTaxa2, nTaxa1, cErro, pFatorConv}
	
EndIf

RestArea( aArea )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotFat()
Rotina para buscar a cotação da moeda a partir das cotaçoes da fatura.

@param  cMoeCot   Moeda da cotação desejada
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  cEscr     Escritório da Fatura 
@param  cFatura   Código do escritório da fatura.

@Return aCotac    Array com cotação da aturas (NXF)
        aCotac[1] Valor da cotação da moeda cMoeCot
        aCotac[2] .F. Se não localizou a cotação e precisa buscar na diária ou mensal

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotFat(cMoeCot, cMoedaNac, cEscr, cFatura)
Local aCotac := {0, .F.}

If (cMoeCot != cMoedaNac)
	NXF->(DbSetOrder(2)) ///NXF_FILIAL+NXF_CFATUR+NXF_CESCR+NXF_CMOEDA
	If NXF->(DbSeek( __xFilNXF + cFatura + cEscr + cMoeCot))
		aCotac := {NXF->NXF_COTAC1, .T.}
	EndIf
Else
	aCotac := {1, .T.}
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotFil(cMoeCot, cMoedaNac, cFila)
Rotina buscar a cotação da moeda a partir da fila de emissão da fatura

@param  cMoeCot   Moeda da cotação desejada
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  cFila     Fila de emissão da fatura 


@Return aCotac    Array com cotação da aturas (NX6)
        aCotac[1] Valor da cotação da moeda cMoeCot
        aCotac[2] .F. Se não localizou a cotação e precisa buscar na diária ou mensal

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotFil(cMoeCot, cMoedaNac, cFila)
Local aCotac := {0, .F.}

If (cMoeCot != cMoedaNac)
	NX6->(DbSetOrder(1)) //NX6_FILIAL+NX6_CFILA+NX6_CMOEDA
	If NX6->(DbSeek( __xFilNX6 + cFila + cMoeCot))
		aCotac := {NX6->NX6_COTAC1, .T.}
	EndIf
Else
	aCotac := {1, .T.}
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotPre(cMoeCot, cMoedaNac, cPreFt)
Rotina buscar a cotação da moeda a partir das cotações da pré-fatura

@param  cMoeFat   Moeda da fatura
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  cPreFt    Código da pré-fatura 

@Return aCotac    Array com cotação da aturas (NXR)
        aCotac[1] Valor da cotação da moeda cMoeCot
        aCotac[2] .F. Se não localizou a cotação e precisa buscar na diária ou mensal

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotPre(cMoeCot, cMoedaNac, cPreFt)
Local aCotac := {0, .F.}

If (cMoeCot != cMoedaNac)
	NXR->(DbSetOrder(1)) //NXR_FILIAL+NXR_CPREFT+NXR_CMOEDA
	If NXR->(DbSeek( __xFilNXR + cPreFt + cMoeCot))
		aCotac := {NXR->NXR_COTAC, .T.}
	EndIf
Else
	aCotac := {1, .T.}
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotDia
Rotina buscar a cotação diária da moeda.

@param  cMoeCot   Moeda da cotação
@param  cMoedaNac Moeda Nacional (Moeda forte)
@param  dCotacao  Data da cotação
@param  cCTPFil   Filial da tabela de câmbio CTP

@Return aCotac    Array com cotação da aturas (NXF)
        aCotac[1] Valor da cotação da moeda cMoeCot
        aCotac[2] .F. Se busca retornou com algum erro
        aCotac[3] Mensagem de critica

@author  Luciano Pereira dos Santos
@since   12/11/2018
/*/
//-------------------------------------------------------------------
Function J201FCotDia(cMoeCot, cMoedaNac, dCotacao, cCTPFil)
Local cDtCotac := DtoS(dCotacao)
Local aCotac   := {}

	CTP->(DbSetOrder(1)) //CTP_FILIAL+DTOS(CTP_DATA)+CTP_MOEDA
	If CTP->(DbSeek( cCTPFil + cDtCotac + cMoeCot))
		If CTP->CTP_BLOQ == "2"
			aCotac := {CTP->CTP_TAXA, .T., ""}
		Else
			aCotac := {1, .F., I18n(STR0006, {cMoeCot}) } //# "A moeda '#1' está bloqueada."
		EndIf
	Else
		If (cMoeCot == cMoedaNac)
			aCotac := {1, .T., ""}
		Else
			aCotac := {1, .F., I18n(STR0007, {cMoeCot, DtoC(dCotacao)}) } //# "Não existe cotação diária na moeda '#1' para a data '#2'."
		EndIf
	EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FCotMes(cMoeCot, cMoedaNac, dCotacao)
Rotina buscar a cotação diária da moeda.

@param  cMoeCot   Moeda da cotação
@param  cMoedaNac  Moeda Nacional (Moeda forte)
@param  dCotacao  Data da cotação 

@return aCotac    Array com cotação da aturas (NXF)
        aCotac[1]  Valor da cotação da moeda cMoeCot
        aCotac[2]  .F. Se busca retornou com algum erro
        aCotac[3]  Mensagem de critica

@author  Luciano Pereira dos Santos
@since   12/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201FCotMes(cMoeCot, cMoedaNac, dCotacao)
Local cAnoMes := SubStr(DtoS(dCotacao), 1, 6)
Local aCotac  := {}

NXQ->(DbSetOrder(1)) // NXQ_FILIAL + NXQ_ANOMES + NXQ_CMOEDA
If NXQ->(DbSeek( __xFilNXQ + cAnoMes + cMoeCot))
	aCotac := {NXQ->NXQ_COTAC, .T., ""}
Else
	If (cMoeCot == cMoedaNac)
		aCotac := {1, .T., ""}
	Else
		aCotac := {1, .F., I18n(STR0008, {cMoeCot, Transform(cAnoMes, PesqPict("NXQ", "NXQ_ANOMES"))}) } //# "Não existe cotação mensal na moeda '#1' para o ano-mês '#2'."
	EndIf
EndIf

Return aCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J201FVlCot
Rotina que retorna se há cotação cadastrada para a moeda e data.

@param  cMoeda      Moeda da cotação
@param  dCotacao    Data da cotação
@param  lExibeErro  Indica se devem ser exibidas mensagens 

@return lRet        .T. se houver cotação cadastrada

@author  Jorge Martins
@since   16/12/2019
/*/
//-------------------------------------------------------------------
Function J201FVlCot(cMoeda, dCotacao, lExibeErro)
	Local lRet         := .T.
	Local cTipoConv    := SuperGetMv('MV_JTPCONV',, '1' ) // Cotação '1' = Diária / '2' = Mensal
	Local nCotac       := 0
	Local cProblema    := ""
	Local cSolucao     := ""
	Local cCampo       := ""
	Local aCotac       := {}

	Default dCotacao   := Date()
	Default lExibeErro := .T.

	If cTipoConv == '1'
		
		aCotac := JurGetDados("CTP", 1, xFilial("CTP") + DtoS(dCotacao) + cMoeda, {"CTP_BLOQ", "CTP_TAXA"})
		
		If Empty(aCotac)
			cProblema := I18n(STR0007, {cMoeda, DtoC(dCotacao)}) //# "Não existe cotação diária na moeda '#1' para a data '#2'."
			lRet      := .F.
			
		ElseIf Len(aCotac) == 2
			If aCotac[1] == "1"
				cProblema := I18n(STR0006, {cMoeCot}) //# "A moeda '#1' está bloqueada."
				lRet      := .F.
			
			ElseIf aCotac[2] == 1
			
				// Verifica se a cotação é 1 também na SM2, ou se está zerada
				cCampo := "M2_MOEDA" + SubStr(cMoeda, 2, 1)
				nCotac := JurGetDados("SM2", 1, DtoS(dCotacao), cCampo)
				
				If nCotac == 0
					cProblema := I18n(STR0010, {DToC(dCotacao), cMoeda}) //"A cotação do dia #1 para a moeda #2 está com valor zerado."
					lRet      := .F.
				EndIf
			Else
				nCotac := aCotac[2]
			EndIf
		EndIf

	ElseIf cTipoConv == '2'
		aCotac := JurGetDados("NXQ", 1, xFilial("NXQ") + AnoMes(dCotacao) + cMoeda, {"NXQ_COTAC", "NXQ_CMOEDA"})

		If Empty(aCotac)
			cProblema := I18n(STR0012, {MesExtenso(Month(dCotacao)), cValToChar(Year(dCotacao)), cMoeda}) // "Cotação do mês de #1 de #2 para a moeda #3 não existe."
			lRet      := .F.
		ElseIf Len(aCotac) == 2 
			nCotac := aCotac[1]
			If nCotac == 0
				cProblema := I18n(STR0013, {MesExtenso(Month(dCotacao)), cValToChar(Year(dCotacao)), cMoeda}) // "Cotação do mês de #1 de #2 para a moeda #3 está com valor zerado."
				lRet      := .F.
			EndIf
		EndIf

	EndIf

	If !Empty(cProblema)
		lRet     := .F.
		cSolucao := STR0011 // "Indique uma cotação válida para a moeda e data indicadas, e realize a operação novamente."
	EndIf

	If !lRet .And. lExibeErro
		JurMsgErro(cProblema, , cSolucao)
	EndIf

Return {lRet, nCotac}
