#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145DEF.ch"

//Variaveis para converter os valores nos tamanhos do Protheus
Static _nTamProd := GetSX3Cache("VF_COMP" , "X3_TAMANHO")
Static _nTamLoc  := GetSX3Cache("VF_LOCAL", "X3_TAMANHO")
Static _nTamTRT  := GetSX3Cache("VF_TRT"  , "X3_TAMANHO")

/*/{Protheus.doc} PCPA145Sub
Função para geração das ordens de substituição

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param oProcesso , Object, Instância da classe ProcessaDocumentos
@param aDados    , Array , Array com as informações do rastreio que serão processados.
                           As posições deste array são acessadas através das constantes iniciadas
                           com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param aDocPaiERP, Array , Lista dos documentos gerados pelo Protheus
                           Estrutura do array:
                           aDocPaiERP[nIndex][1] - Documento gerado no ERP Protheus
                           aDocPaiERP[nIndex][2] - Quantidade de empenho necessário para o documento
@return Nil
/*/
Function PCPA145Sub(oProcesso, aDados, aDocPaiERP)

	Local aSVF      := {}
	Local aSVJ      := {}
	Local aT4I		:= {}
	Local cChave    := aDados[RASTREIO_POS_CHAVE_SUBST]
	Local cDocPai   := aDados[RASTREIO_POS_DOCPAI]
	Local cOpOrigem := ' '
	Local cTicket   := oProcesso:cTicket
	Local lAglutina := oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
	Local nIndexDoc := 0
	Local nTotalDoc := Len(aDocPaiERP)
	Local aRegs     := {}
	Local oJson     := JsonObject():New()

	aRegs :=  MrpOrdSubs(cTicket, cChave, cDocPai, oProcesso:utilizaMultiEmpresa())
	If aRegs[1]
		oJson:FromJson(aRegs[2])

		If Len(oJson["items"]) > 0
			If lAglutina .Or. Empty(oJson["items"][1]['childDocument'] )
				cOpOrigem := ' '
			Else
				cOpOrigem := oProcesso:getDocumentoDePara(oJson["items"][1]['childDocument'], cFilAnt)[2]
			EndIf
			
			For nIndexDoc := 1 To nTotalDoc
				//Monta o array com as informações referente ao produto original que foi trocado.
				aSVF := {xFilial("SVF")                                				,;		//01-01: VF_FILIAL	- Filial do empenho anterior;
						aDocPaiERP[nIndexDoc][1]                      				,;		//01-02: VF_OP		- OP do empenho anterior;
						PadR(oJson["items"][1]['componentCode']       , _nTamProd) ,;		//01-03: VF_COMP	- Componente do empenho anterior;
						PadR(oJson["items"][1]['consumptionLocation'] , _nTamLoc ) ,;		//01-04: VF_LOCAL	- Local do empenho anterior;
						PadR(oJson["items"][1]['sequenceInStructure'] , _nTamTRT ) ,;		//01-05: VF_TRT		- TRT do empenho anterior;
						""                                            				,;		//01-06: VF_SEQ		- Sequencia do empenho anterior;
						cOpOrigem                                  				,;		//01-07: VF_OPORIG	- OP Origem do empenho anterior;
						""                                         				,;		//01-08: VF_LOTE	- Lote do empenho anterior;
						""                                         				,;		//01-09: VF_SUBLOTE	- SubLote do empenho anterior;
						""                                         				,;		//01-10: VF_ORDEM	- Ordem do empenho anterior;
						aDocPaiERP[nIndexDoc][2]}				      		//01-11: VF_QTDEORI	- Quantidade do empenho anterior;

				aAdd(aSVJ, {xFilial("SVJ")              ,;		//03-nX-01: VJ_FILIAL	- Filial do empenho novo;
							aDados[RASTREIO_POS_PRODUTO],;		//03-nX-02: VJ_ALTERN	- Componente do empenho novo - ALTERNATIVO;
							aDados[RASTREIO_POS_LOCAL  ],;		//03-nX-03: VJ_LOCAL	- Local do empenho novo;
							aDados[RASTREIO_POS_TRT    ],;		//03-nX-04: VJ_TRT		- TRT do empenho novo;
							""                          ,;		//03-nX-05: VJ_SEQ		- Sequencia do empenho novo;
							""                          ,;		//03-nX-06: VJ_OPORIG	- OP Origem do empenho novo;
							""                          ,;		//03-nX-07: VJ_LOTE		- Lote do empenho novo;
							""                          ,;		//03-nX-08: VJ_SUBLOTE	- SubLote do empenho novo;
							""                          ,;		//03-nX-09: VJ_ORDEM	- Ordem do empenho novo;
							aDocPaiERP[nIndexDoc][2]    ,;		//03-nX-10: VJ_QUANT	- Quantidade do empenho novo
							""                          ,;		//03-nX-11: VJ_LOCALIZ 	- Localizacao do empenho novo;
							""})	                            //03-nX-12: VJ_NUMSERI 	- Numero de serie do empenho novo

				geraOrdSub(aSVF, aT4I, aSVJ, .F., .T.)

				aSize(aSVF, 0)
				aSize(aSVJ, 0)
				aSize(aT4I, 0)
			Next nIndexDoc
		EndIf

		aSize(oJson["items"],0)
	EndIf
	FreeObj(oJson)
Return
