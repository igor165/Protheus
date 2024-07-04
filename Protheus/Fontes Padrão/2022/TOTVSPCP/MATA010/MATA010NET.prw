#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//DEFINES do array de dados
#DEFINE SB1_POS_ARMAZEM             1
#DEFINE SB1_POS_QTD_EMBALAGEM       2
#DEFINE SB1_POS_PONTO_PEDIDO        3
#DEFINE SB1_POS_ESTOQUE_SEGURANCA   4
#DEFINE SB1_POS_ESTOQUE_MAXIMO      5
#DEFINE SB1_POS_PRAZO_ENTREGA       6
#DEFINE SB1_POS_LOTE_ECONOMICO      7
#DEFINE SB1_POS_LOTE_MINIMO         8
#DEFINE SB1_POS_TOLERANCIA          9
#DEFINE SB1_POS_ENTRA_MRP           10
#DEFINE SB1_POS_BLOQUEIO            11
#DEFINE SB1_POS_FANTASMA            12
#DEFINE SB1_TAMANHO                 12

#DEFINE SVK_POS_HORIZONTE_FIXO      1
#DEFINE SVK_POS_TIPO_HORIZONTE      2
#DEFINE SVK_TAMANHO                 2

#DEFINE PRODUTO_POS_SB1             1
#DEFINE PRODUTO_POS_SVK             2

#DEFINE PRODUTO_POS_TABELA          1
#DEFINE PRODUTO_POS_COLUNA          2
#DEFINE PRODUTO_POS_VALOR           3

/*/{Protheus.doc} MATA010NET
Eventos de de atualização do Net Change

@author ricardo.prandi
@since 06/03/2020
@version P12.1.30
/*/
CLASS MATA010NET FROM FWModelEvent

	DATA aDados       AS ARRAY
	DATA lNetChangeOn AS CARACTER
	
	METHOD New() CONSTRUCTOR
	METHOD Activate(oModel, lCopy)
	METHOD InTTs(oModel, cModelId)
	
ENDCLASS

/*/{Protheus.doc} NEW
Método construtor do evento de atualização do Net Change

@author ricardo.prandi
@since 06/03/2020
@version P12.1.30
/*/
METHOD New() CLASS MATA010NET
	If FindFunction("netChAtivo")
		::lNetChangeOn := netChAtivo()
	EndIf
Return Self

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author ricardo.prandi
@since 06/03/2020
@version P12.1.30
@param oModel, Object  , Modelo principal
@param lCopy , Lógico  , Informa se o model deve carregar os dados do registro posicionado em operações de inclusão.
@return Nil
/*/
METHOD Activate(oModel, lCopy) CLASS MATA010NET
	Local oMdlSB1   := oModel:GetModel("SB1MASTER")
	Local oMdlSVK   := oModel:GetModel("SVKDETAIL")

	::aDados = {}
	
	//Se for modificação, guarda os valores para comparar se houve alguma alteração nos campos
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ::lNetChangeOn == "1"
		//Adiciona os campos da SB1
		aAdd(::aDados,{"SB1",Array(SB1_TAMANHO),Array(SB1_TAMANHO)})
		
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_ARMAZEM          ] := "B1_LOCPAD"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_ARMAZEM          ] := oMdlSB1:GetValue("B1_LOCPAD")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_QTD_EMBALAGEM    ] := "B1_QE"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_QTD_EMBALAGEM    ] := oMdlSB1:GetValue("B1_QE")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_PONTO_PEDIDO     ] := "B1_EMIN"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_PONTO_PEDIDO     ] := oMdlSB1:GetValue("B1_EMIN")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_ESTOQUE_SEGURANCA] := "B1_ESTSEG"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_ESTOQUE_SEGURANCA] := oMdlSB1:GetValue("B1_ESTSEG")
		
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_ESTOQUE_MAXIMO   ] := "B1_EMAX"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_ESTOQUE_MAXIMO   ] := oMdlSB1:GetValue("B1_EMAX")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_PRAZO_ENTREGA    ] := "B1_PE"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_PRAZO_ENTREGA    ] := oMdlSB1:GetValue("B1_PE")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_LOTE_ECONOMICO   ] := "B1_LE"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_LOTE_ECONOMICO   ] := oMdlSB1:GetValue("B1_LE")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_LOTE_MINIMO      ] := "B1_LM"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_LOTE_MINIMO      ] := oMdlSB1:GetValue("B1_LM")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_TOLERANCIA       ] := "B1_TOLER"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_TOLERANCIA       ] := oMdlSB1:GetValue("B1_TOLER")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_ENTRA_MRP        ] := "B1_MRP"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_ENTRA_MRP        ] := oMdlSB1:GetValue("B1_MRP")
		
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_BLOQUEIO         ] := "B1_MSBLQL"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_BLOQUEIO         ] := oMdlSB1:GetValue("B1_MSBLQL")

		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_COLUNA][SB1_POS_FANTASMA         ] := "B1_FANTASM"
		::aDados[PRODUTO_POS_SB1][PRODUTO_POS_VALOR ][SB1_POS_FANTASMA         ] := oMdlSB1:GetValue("B1_FANTASM")

		//Adiciona os campos da SVK
		If !Empty(oMdlSVK)
			aAdd(::aDados,{"SVK",Array(SVK_TAMANHO),Array(SVK_TAMANHO)})

			::aDados[PRODUTO_POS_SVK][PRODUTO_POS_COLUNA][SVK_POS_HORIZONTE_FIXO] := "VK_HORFIX"
			::aDados[PRODUTO_POS_SVK][PRODUTO_POS_VALOR ][SVK_POS_HORIZONTE_FIXO] := oMdlSVK:GetValue("VK_HORFIX")

			::aDados[PRODUTO_POS_SVK][PRODUTO_POS_COLUNA][SVK_POS_TIPO_HORIZONTE] := "VK_TPHOFIX"
			::aDados[PRODUTO_POS_SVK][PRODUTO_POS_VALOR ][SVK_POS_TIPO_HORIZONTE] := oMdlSVK:GetValue("VK_TPHOFIX")
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author ricardo.prandi
@since 06/03/2020
@version P12.1.30
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTs(oModel, cModelId) CLASS MATA010NET
	Local cCampo    := ""
	Local lIntegra  := .F.
	Local nInd      := 0
	Local nIndDados := 0
	Local nTamDados := Len(::aDados)
	Local oMdlSB1   := oModel:GetModel("SB1MASTER")
	Local oMdlSVK   := oModel:GetModel("SVKDETAIL")
	

	//Se for exclusão, grava registro no Net Change
	If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. ::lNetChangeOn == "1"
		gravaHWJ(oMdlSB1:GetValue("B1_COD"),"2","1") //Evento 2 - Exclusão / Origem 1 - Produto
	EndIf
	
	//Se for modificação, verifica se os campos pré-determinados foram alterados
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ::lNetChangeOn == "1"
		For nInd = 1 to nTamDados
			//Percorre os dados da SB1
			If ::aDados[nInd][PRODUTO_POS_TABELA] = "SB1"
				For nIndDados = 1 to SB1_TAMANHO
					cCampo := ::aDados[nInd][PRODUTO_POS_COLUNA][nIndDados]
					If ::aDados[nInd][PRODUTO_POS_VALOR][nIndDados] != oMdlSB1:GetValue(cCampo)
						lIntegra := .T.
						Exit
					EndIf
				Next
			EndIf

			//Se encontrou alguma diferença, não precisa mais conferir o restante dos dados
			If lIntegra
				Exit
			EndIf

			//Percorre dados da SVK
			If ::aDados[nInd][PRODUTO_POS_TABELA] = "SVK"
				For nIndDados = 1 to SVK_TAMANHO
					cCampo := ::aDados[nInd][PRODUTO_POS_COLUNA][nIndDados]
					If ::aDados[nInd][PRODUTO_POS_VALOR][nIndDados] != oMdlSVK:GetValue(cCampo)
						lIntegra := .T.
						Exit
					EndIf
				Next
			End If
		Next

		If lIntegra
			gravaHWJ(oMdlSB1:GetValue("B1_COD"),"1","1")  //Evento 1 - Modificação / Origem 1 - Produto
		EndIf
	EndIf

Return Nil