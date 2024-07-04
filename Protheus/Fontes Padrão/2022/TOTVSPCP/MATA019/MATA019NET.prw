#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//DEFINES do array de dados
#DEFINE SBZ_POS_ARMAZEM             1
#DEFINE SBZ_POS_QTD_EMBALAGEM       2
#DEFINE SBZ_POS_PONTO_PEDIDO        3
#DEFINE SBZ_POS_ESTOQUE_SEGURANCA   4
#DEFINE SBZ_POS_ESTOQUE_MAXIMO      5
#DEFINE SBZ_POS_PRAZO_ENTREGA       6
#DEFINE SBZ_POS_LOTE_ECONOMICO      7
#DEFINE SBZ_POS_LOTE_MINIMO         8
#DEFINE SBZ_POS_TOLERANCIA          9
#DEFINE SBZ_POS_ENTRA_MRP           10
#DEFINE SBZ_POS_HORIZONTE_FIXO      11
#DEFINE SBZ_POS_TIPO_HORIZONTE      12
#DEFINE SBZ_POS_FANTASMA            13
#DEFINE SBZ_TAMANHO                 13

#DEFINE INDICADOR_POS_TABELA        1
#DEFINE INDICADOR_POS_COLUNA        2
#DEFINE INDICADOR_POS_VALOR         3

/*/{Protheus.doc} MATA019NET
Eventos de atualização do Net Change para indicadores de produto

@author ricardo.prandi
@since 11/03/2020
@version P12.1.30
/*/
CLASS MATA019NET FROM FWModelEvent

	DATA aDados       AS ARRAY
	DATA lNetChangeOn AS CARACTER
	
	METHOD New() CONSTRUCTOR
	METHOD Activate(oModel, lCopy)
	METHOD InTTs(oModel, cModelId)
	
ENDCLASS

/*/{Protheus.doc} NEW
Método construtor do evento de atualização do Net Change para indicadores de produto

@author ricardo.prandi
@since 11/03/2020
@version P12.1.30
/*/
METHOD New() CLASS MATA019NET
	
	If FindFunction("netChAtivo")
		::lNetChangeOn := netChAtivo()
	EndIf

Return Self

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author ricardo.prandi
@since 11/03/2020
@version P12.1.30
@param oModel, Object  , Modelo principal
@param lCopy , Lógico  , Informa se o model deve carregar os dados do registro posicionado em operações de inclusão.
@return Nil
/*/
METHOD Activate(oModel, lCopy) CLASS MATA019NET
	Local nIndex  := 0
	Local oMdlSBZ := oModel:GetModel("SBZDETAIL")
	
	::aDados = {}
	
	//Se for modificação, guarda os valores para comparar se houve alguma alteração nos campos
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ::lNetChangeOn == "1"
		For nIndex := 1 To oMdlSBZ:Length(.F.)
			//Adiciona os campos da SBZ
			aAdd(::aDados,{"SBZ",Array(SBZ_TAMANHO),Array(SBZ_TAMANHO)})
		
			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_ARMAZEM          ] := "BZ_LOCPAD"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_ARMAZEM          ] := oMdlSBZ:GetValue("BZ_LOCPAD",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_QTD_EMBALAGEM    ] := "BZ_QE"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_QTD_EMBALAGEM    ] := oMdlSBZ:GetValue("BZ_QE",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_PONTO_PEDIDO     ] := "BZ_EMIN"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_PONTO_PEDIDO     ] := oMdlSBZ:GetValue("BZ_EMIN",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_ESTOQUE_SEGURANCA] := "BZ_ESTSEG"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_ESTOQUE_SEGURANCA] := oMdlSBZ:GetValue("BZ_ESTSEG",nIndex)
		
			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_ESTOQUE_MAXIMO   ] := "BZ_EMAX"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_ESTOQUE_MAXIMO   ] := oMdlSBZ:GetValue("BZ_EMAX",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_PRAZO_ENTREGA    ] := "BZ_PE"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_PRAZO_ENTREGA    ] := oMdlSBZ:GetValue("BZ_PE",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_LOTE_ECONOMICO   ] := "BZ_LE"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_LOTE_ECONOMICO   ] := oMdlSBZ:GetValue("BZ_LE",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_LOTE_MINIMO      ] := "BZ_LM"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_LOTE_MINIMO      ] := oMdlSBZ:GetValue("BZ_LM",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_TOLERANCIA       ] := "BZ_TOLER"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_TOLERANCIA       ] := oMdlSBZ:GetValue("BZ_TOLER",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_ENTRA_MRP        ] := "BZ_MRP"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_ENTRA_MRP        ] := oMdlSBZ:GetValue("BZ_MRP",nIndex)
		
			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_FANTASMA         ] := "BZ_FANTASM"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_FANTASMA         ] := oMdlSBZ:GetValue("BZ_FANTASM",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_HORIZONTE_FIXO   ] := "BZ_HORFIX"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_HORIZONTE_FIXO   ] := oMdlSBZ:GetValue("BZ_HORFIX",nIndex)

			::aDados[nIndex][INDICADOR_POS_COLUNA][SBZ_POS_TIPO_HORIZONTE   ] := "BZ_TPHOFIX"
			::aDados[nIndex][INDICADOR_POS_VALOR ][SBZ_POS_TIPO_HORIZONTE   ] := oMdlSBZ:GetValue("BZ_TPHOFIX",nIndex)
		Next
	EndIf

	Return Nil

/*/{Protheus.doc} InTTs
Método que é chamado pelo MVC quando ocorrer as ações do commit, após as gravações, antes do final da transação. 
Esse evento ocorre uma vez no contexto do modelo principal.

@author ricardo.prandi
@since 11/03/2020
@version P12.1.30
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTs(oModel, cModelId) CLASS MATA019NET
	Local cCampo    := ""
	Local cFilProd  := ""
	Local lIntegra  := .F.
	Local nInd      := 0
	Local nIndDados := 0
	Local nTamDados := 0
	Local nTamModel := 0
	Local oMdlSBZ   := oModel:GetModel("SBZDETAIL")
	Local oMdlSB1   := oModel:GetModel("SB1MASTER")

	//Encontra o tamanho do array gravado no Activate
	nTamDados := Len(::aDados)

	//Encontra o tamanho do model
	nTamModel := oMdlSBZ:Length(.F.)
	
	For nInd = 1 to nTamModel
		//Verifica a filial. Se tabela é compartilhada, considera a filial logada
		If !FWModeAccess("SBZ",1) == "C" .Or. !FWModeAccess("SBZ",2) == "C" .Or. !FWModeAccess("SBZ",3) == "C"
			cFilProd := oMdlSBZ:GetValue("BZ_FILIAL",nInd)
		Else
			cFilProd := cFilAnt
		EndIf
		
		//Se for exclusão, grava registro no Net Change
		If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. ::lNetChangeOn == "1"
			gravaHWJ(oMdlSB1:GetValue("B1_COD"),"2","8",cFilProd) //Evento 2 - Exclusão / Origem 8 - Indicadores de Produto
		EndIf
	
		//Se for modificação, verifica se os campos pré-determinados foram alterados
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ::lNetChangeOn == "1"
			//Se excluiu a linha, registra diretamente na HWJ
			If oMdlSBZ:IsDeleted(nInd)
				gravaHWJ(oMdlSB1:GetValue("B1_COD"),"2","8",cFilProd)  //Evento 2 - Exclusão / Origem 8 - Indicadores de Produto
			ElseIf nTamModel > nTamDados  //Se o model é maior que o array, registra diretamente, pois foi incluída uma linha nova
				gravaHWJ(oMdlSB1:GetValue("B1_COD"),"1","8",cFilProd)  //Evento 1 - Inclusão / Origem 8 - Indicadores de Produto
			Else
				//Percorre os dados da SBZ
				If ::aDados[nInd][INDICADOR_POS_TABELA] = "SBZ"
					For nIndDados = 1 to SBZ_TAMANHO
						cCampo := ::aDados[nInd][INDICADOR_POS_COLUNA][nIndDados]
						If ::aDados[nInd][INDICADOR_POS_VALOR][nIndDados] != oMdlSBZ:GetValue(cCampo,nInd)
							lIntegra := .T.
							Exit
						EndIf
					Next
				EndIf

				If lIntegra
					gravaHWJ(oMdlSB1:GetValue("B1_COD"),"1","8",cFilProd)  //Evento 1 - Modificação / Origem 8 - Indicadores de Produto
				EndIf
			EndIf
		EndIf
	Next

Return Nil