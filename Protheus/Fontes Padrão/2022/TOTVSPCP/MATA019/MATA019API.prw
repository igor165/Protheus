#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A019APICnt para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A019APICnt
//Campos do Grupo (cabeçalho)
#DEFINE ARRAY_IND_PROD_POS_FILIAL   1
#DEFINE ARRAY_IND_PROD_POS_PROD	    2
#DEFINE ARRAY_IND_PROD_POS_LOCPAD   3
#DEFINE ARRAY_IND_PROD_POS_QE       4
#DEFINE ARRAY_IND_PROD_POS_EMIN	    5
#DEFINE ARRAY_IND_PROD_POS_ESTSEG   6
#DEFINE ARRAY_IND_PROD_POS_PE       7
#DEFINE ARRAY_IND_PROD_POS_TIPE	    8
#DEFINE ARRAY_IND_PROD_POS_LE       9
#DEFINE ARRAY_IND_PROD_POS_LM       10
#DEFINE ARRAY_IND_PROD_POS_TOLER    11
#DEFINE ARRAY_IND_PROD_POS_MRP	    12
#DEFINE ARRAY_IND_PROD_POS_REVATU   13
#DEFINE ARRAY_IND_PROD_POS_EMAX	    14
#DEFINE ARRAY_IND_PROD_POS_HORFIX   15
#DEFINE ARRAY_IND_PROD_POS_TPHFIX   16
#DEFINE ARRAY_IND_PROD_POS_IDREG    17
#DEFINE ARRAY_IND_PROD_POS_OPC      18
#DEFINE ARRAY_IND_PROD_POS_STR_OPC  19
#DEFINE ARRAY_IND_PROD_POS_SIZE     19

Static _lIntEstPA := FindFunction('MTA010G1PA')

/*/{Protheus.doc} A019APICnt
Recupera o valor das constantes utilizadas para auxiliar na montagem do array para integração

@type  Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A019APICnt(cInfo)
	Local nValue := ARRAY_IND_PROD_POS_SIZE
	Do Case
        Case cInfo == "ARRAY_IND_PROD_POS_FILIAL"
            nValue := ARRAY_IND_PROD_POS_FILIAL
        Case cInfo == "ARRAY_IND_PROD_POS_PROD"
            nValue := ARRAY_IND_PROD_POS_PROD
        Case cInfo == "ARRAY_IND_PROD_POS_LOCPAD"
            nValue := ARRAY_IND_PROD_POS_LOCPAD
        Case cInfo == "ARRAY_IND_PROD_POS_QE"
            nValue := ARRAY_IND_PROD_POS_QE
        Case cInfo == "ARRAY_IND_PROD_POS_EMIN"
            nValue := ARRAY_IND_PROD_POS_EMIN
        Case cInfo == "ARRAY_IND_PROD_POS_ESTSEG"
            nValue := ARRAY_IND_PROD_POS_ESTSEG
        Case cInfo == "ARRAY_IND_PROD_POS_PE"
            nValue := ARRAY_IND_PROD_POS_PE
        Case cInfo == "ARRAY_IND_PROD_POS_TIPE"
            nValue := ARRAY_IND_PROD_POS_TIPE
        Case cInfo == "ARRAY_IND_PROD_POS_LE"
            nValue := ARRAY_IND_PROD_POS_LE
        Case cInfo == "ARRAY_IND_PROD_POS_LM"
            nValue := ARRAY_IND_PROD_POS_LM
        Case cInfo == "ARRAY_IND_PROD_POS_TOLER"
            nValue := ARRAY_IND_PROD_POS_TOLER
        Case cInfo == "ARRAY_IND_PROD_POS_MRP"
            nValue := ARRAY_IND_PROD_POS_MRP
        Case cInfo == "ARRAY_IND_PROD_POS_REVATU"
            nValue := ARRAY_IND_PROD_POS_REVATU
        Case cInfo == "ARRAY_IND_PROD_POS_EMAX"
            nValue := ARRAY_IND_PROD_POS_EMAX
        Case cInfo == "ARRAY_IND_PROD_POS_HORFIX"
            nValue := ARRAY_IND_PROD_POS_HORFIX
        Case cInfo == "ARRAY_IND_PROD_POS_TPHFIX"
            nValue := ARRAY_IND_PROD_POS_TPHFIX
        Case cInfo == "ARRAY_IND_PROD_POS_IDREG"
            nValue := ARRAY_IND_PROD_POS_IDREG
        Case cInfo == "ARRAY_IND_PROD_POS_SIZE"
            nValue := ARRAY_IND_PROD_POS_SIZE
		Case cInfo == "ARRAY_IND_PROD_POS_OPC"
			nValue := ARRAY_IND_PROD_POS_OPC
		Case cInfo == "ARRAY_IND_PROD_POS_STR_OPC"
			nValue := ARRAY_IND_PROD_POS_STR_OPC
        Otherwise
            nValue := ARRAY_IND_PROD_POS_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} MATA019API
Eventos de integração do Cadastro de Indicadores de Produto

@author renan.roeder
@since 14/11/2019
@version P12.1.27
/*/
CLASS MATA019API FROM FWModelEvent

	DATA lIntegraMRP    AS LOGIC
	DATA lIntegraOnline AS LOGIC
	DATA oQtdBaseEst    AS OBJECT

	METHOD New() CONSTRUCTOR

	METHOD BeforeTTS(oModel, cModelId)
	METHOD AfterTTS(oModel, cModelId)

ENDCLASS

/*/{Protheus.doc} NEW
Método construtor do evento de integração das integrações do Cadastro de Indicadores de Produto

@author renan.roeder
@since 14/11/2019
@version P12.1.27
/*/
METHOD New() CLASS MATA019API

	::lIntegraMRP    := .F.
	::lIntegraOnline := .F.

	::lIntegraMRP := IntNewMRP("MRPPRODUCTINDICATOR", @::lIntegraOnline)

Return Self

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author marcelo.neumann
@since 12/11/2021
@version P12.1.27
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS MATA019API
	Local oMdlSBZ := oModel:GetModel("SBZDETAIL")
	Local cFilSBZ := cFilAnt
	Local nIndex  := 0

	::oQtdBaseEst := JsonObject():New()

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
		For nIndex := 1 To oMdlSBZ:Length()
			cFilSBZ := oMdlSBZ:GetValue("BZ_FILIAL", nIndex)
			::oQtdBaseEst[cFilSBZ] := Nil
			If oMdlSBZ:GetDataID(nIndex) > 0
				SBZ->(dbGoTo(oMdlSBZ:GetDataID(nIndex)))
				::oQtdBaseEst[cFilSBZ] := SBZ->BZ_QB
			EndIf
		Next nIndex
	EndIf

Return Nil

/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author renan.roeder
@since 04/11/2019
@version P12.1.27
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS MATA019API
	Local oMdlSB1 := oModel:GetModel("SB1MASTER")
	Local oMdlSBZ := oModel:GetModel("SBZDETAIL")
	Local cFilSBZ := cFilAnt
	Local cFilAux := cFilAnt
	Local nIndex  := 0

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .T. .And. ::lIntegraOnline == .T.
		intIndProd(oModel, Self)
	EndIf

	If ::lIntegraMRP .And. _lIntEstPA .And. SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
		For nIndex := 1 To oMdlSBZ:Length()
			cFilSBZ :=  oMdlSBZ:GetValue("BZ_FILIAL", nIndex)
			If oMdlSBZ:IsDeleted(nIndex) .Or. oMdlSBZ:GetValue("BZ_QB", nIndex) <> ::oQtdBaseEst[cFilSBZ]
				cFilAnt := cFilSBZ
				MTA010G1PA(oMdlSB1:GetValue("B1_COD"), oMdlSB1:GetValue("B1_MSBLQL"), cFilSBZ)
				cFilAnt := cFilAux
			EndIf
		Next nIndex
	EndIf
	FreeObj(::oQtdBaseEst)
Return Nil

/*/{Protheus.doc} intIndProd
Integra dados com a API

@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param oModel, Object, Modelo principal
@param Self  , objeto, instancia atual desta classe
@return Nil
/*/
Static Function intIndProd(oModel, Self)
	Local aDadosDel      := {}
	Local aDadosInc      := {}
	Local nPos           := 0
	Local oMdlSBZ        := oModel:GetModel("SBZDETAIL")
	Local oMdlSB1        := oModel:GetModel("SB1MASTER")
	Local nIndex         := 0
	Local nX             := 0

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		For nIndex := 1 To oMdlSBZ:Length(.F.)

			//Adiciona todas as datas que devem ser deletadas
			aAdd(aDadosDel,Array(ARRAY_IND_PROD_POS_SIZE))
			nPos  := Len(aDadosDel)

			//Adiciona as informações no array de exclusão
			aDadosDel[nPos][ARRAY_IND_PROD_POS_FILIAL] := oMdlSBZ:GetValue("BZ_FILIAL",nIndex)
			aDadosDel[nPos][ARRAY_IND_PROD_POS_PROD  ] := oMdlSB1:GetValue("B1_COD")
			aDadosDel[nPos][ARRAY_IND_PROD_POS_IDREG] := oMdlSBZ:GetValue("BZ_FILIAL",nIndex)+oMdlSB1:GetValue("B1_COD",nIndex)
		Next nIndex
	Else
		For nIndex := 1 To oMdlSBZ:Length(.F.)
			If !oMdlSBZ:IsUpdated(nIndex)
				Loop
			EndIf

			If oMdlSBZ:IsDeleted(nIndex)
				If !Empty(oMdlSBZ:GetValue("BZ_FILIAL",nIndex)) .And. !Empty(oMdlSBZ:GetValue("BZ_LOCPAD",nIndex))
					aAdd(aDadosDel,Array(ARRAY_IND_PROD_POS_SIZE))
					nPos  := Len(aDadosDel)

					//Adiciona as informações no array de exclusão
					aDadosDel[nPos][ARRAY_IND_PROD_POS_FILIAL] := oMdlSBZ:GetValue("BZ_FILIAL",nIndex)
					aDadosDel[nPos][ARRAY_IND_PROD_POS_PROD  ] := oMdlSB1:GetValue("B1_COD")
					aDadosDel[nPos][ARRAY_IND_PROD_POS_IDREG]  := oMdlSBZ:GetValue("BZ_FILIAL",nIndex)+oMdlSB1:GetValue("B1_COD",nIndex)
				EndIf
				Loop
			EndIf

			//Adiciona nova linha no array de inclusão/atualização.
			aAdd(aDadosInc,Array(ARRAY_IND_PROD_POS_SIZE))
			nPos := Len(aDadosInc)

			//Adiciona as informações no array de inclusão/atualização.
			aDadosInc[nPos][ARRAY_IND_PROD_POS_FILIAL	] := oMdlSBZ:GetValue("BZ_FILIAL",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_PROD		] := oMdlSB1:GetValue("B1_COD")
			aDadosInc[nPos][ARRAY_IND_PROD_POS_LOCPAD 	] := oMdlSBZ:GetValue("BZ_LOCPAD",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_QE 		] := oMdlSBZ:GetValue("BZ_QE",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_EMIN		] := oMdlSBZ:GetValue("BZ_EMIN",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_ESTSEG 	] := oMdlSBZ:GetValue("BZ_ESTSEG",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_PE 		] := oMdlSBZ:GetValue("BZ_PE",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_TIPE		] := RetTpPrazo(oMdlSBZ:GetValue("BZ_TIPE",nIndex))
			aDadosInc[nPos][ARRAY_IND_PROD_POS_LE 		] := oMdlSBZ:GetValue("BZ_LE",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_LM		] := oMdlSBZ:GetValue("BZ_LM",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_TOLER	] := oMdlSBZ:GetValue("BZ_TOLER",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_MRP		] := RetMrp(oMdlSBZ:GetValue("BZ_MRP",nIndex))
			aDadosInc[nPos][ARRAY_IND_PROD_POS_REVATU	] := oMdlSBZ:GetValue("BZ_REVATU",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_EMAX		] := oMdlSBZ:GetValue("BZ_EMAX",nIndex)

			aDadosInc[nPos][ARRAY_IND_PROD_POS_HORFIX 	] := oMdlSBZ:GetValue("BZ_HORFIX",nIndex)
			aDadosInc[nPos][ARRAY_IND_PROD_POS_TPHFIX 	] := oMdlSBZ:GetValue("BZ_TPHOFIX",nIndex)

			aDadosInc[nPos][ARRAY_IND_PROD_POS_IDREG	] := oMdlSBZ:GetValue("BZ_FILIAL",nIndex)+oMdlSB1:GetValue("B1_COD",nIndex)

			//Tratativa para enviar a filial correta.
			If Empty(aDadosInc[nPos][ARRAY_IND_PROD_POS_FILIAL])
				//Quando é uma linha que foi incluída na grid, o modelo ainda não possui o valor da filial.
				aDadosInc[nPos][ARRAY_IND_PROD_POS_FILIAL] := xFilial("SBZ")
			EndIf
		Next nIndex

		If Len(aDadosDel) > 0
			For nX := 1 To Len(aDadosInc)
				nPos := aScan(aDadosDel,{|x| x[1] == aDadosInc[nX][1]})
				If nPos > 0
					aDel(aDadosDel,nPos)
					ASize(aDadosDel,Len(aDadosDel)-1)
				EndIf
			Next nX
		EndIf

	EndIf

	If Len(aDadosDel) > 0
		MATA019INT("DELETE", aDadosDel)
	EndIf

	If Len(aDadosInc) > 0
		MATA019INT("INSERT", aDadosInc)
	EndIf

Return

/*/{Protheus.doc} MATA019INT
Função que executa a integração de Indicadores do Produto com o MRP.
@type  Function
@author renan.roeder
@since 14/11/2019
@version P12.1.27
@param cOperation, Caracter, Operação que será executada ('DELETE' ou 'INSERT')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSuccess  , Array   , Carrega os registros que foram integrados com sucesso
@param aError    , Array   , Carrega os registros que não foram integrados por erro
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param cUUID     , Caracter, Identificador do processo para buscar os dados na tabela T4R.
@param   lBuffer , Logic   , Define a sincronização em processo de buffer.

@return Nil
/*/
Function MATA019INT(cOperation, aDados, aSuccess, aError, lOnlyDel, cUUID, lBuffer)
	Local aReturn   := {}
	Local lAllError := .F.
	Local nIndex    := 0
	Local nIndIncl  := 0
	Local nIndExcl  := 0
	Local nTotal    := 0
	Local oJsonIncl := Nil
	Local oJsonExcl := Nil
	Local cApi      := "MRPPRODUCTINDICATOR"

	Default aSuccess := {}
	Default aError   := {}
	Default lOnlyDel := .F.
	Default cUUID    := ""
	Default lBuffer  := .F.

	nTotal := Len(aDados)
	oJsonIncl := JsonObject():New()
	oJsonIncl["items"] := {}

	oJsonExcl := JsonObject():New()
	oJsonExcl["items"] := {}

	For nIndex := 1 To nTotal

		If cOperation $ "|INSERT|SYNC|"
			nIndIncl++
			AAdd(oJsonIncl["items"], JsonObject():New())

			oJsonIncl["items"][nIndIncl]["branchId"] := aDados[nIndex][ARRAY_IND_PROD_POS_FILIAL]

			If ! (lOnlyDel .And. cOperation == "SYNC")
				oJsonIncl["items"][nIndIncl]["code"                         ] := aDados[nIndex][ARRAY_IND_PROD_POS_FILIAL] + aDados[nIndex][ARRAY_IND_PROD_POS_PROD]
				oJsonIncl["items"][nIndIncl]["product"                      ] := aDados[nIndex][ARRAY_IND_PROD_POS_PROD]
				oJsonIncl["items"][nIndIncl]["warehouse"                    ] := aDados[nIndex][ARRAY_IND_PROD_POS_LOCPAD]
				oJsonIncl["items"][nIndIncl]["packingQuantity"              ] := aDados[nIndex][ARRAY_IND_PROD_POS_QE]
				oJsonIncl["items"][nIndIncl]["orderPoint"                   ] := aDados[nIndex][ARRAY_IND_PROD_POS_EMIN]
				oJsonIncl["items"][nIndIncl]["safetyStock"                  ] := aDados[nIndex][ARRAY_IND_PROD_POS_ESTSEG]
				oJsonIncl["items"][nIndIncl]["deliveryLeadTime"             ] := aDados[nIndex][ARRAY_IND_PROD_POS_PE]
				oJsonIncl["items"][nIndIncl]["typeDeliveryLeadTime"         ] := aDados[nIndex][ARRAY_IND_PROD_POS_TIPE]
				oJsonIncl["items"][nIndIncl]["economicLotSize"              ] := aDados[nIndex][ARRAY_IND_PROD_POS_LE]
				oJsonIncl["items"][nIndIncl]["minimumLotSize"               ] := aDados[nIndex][ARRAY_IND_PROD_POS_LM]
				oJsonIncl["items"][nIndIncl]["tolerance"                    ] := aDados[nIndex][ARRAY_IND_PROD_POS_TOLER]
				oJsonIncl["items"][nIndIncl]["enterMRP"                     ] := aDados[nIndex][ARRAY_IND_PROD_POS_MRP]
				oJsonIncl["items"][nIndIncl]["currentBillOfMaterialRevision"] := aDados[nIndex][ARRAY_IND_PROD_POS_REVATU]
				oJsonIncl["items"][nIndIncl]["maximumStock"                 ] := aDados[nIndex][ARRAY_IND_PROD_POS_EMAX]
				oJsonIncl["items"][nIndIncl]["fixedHorizon"                 ] := aDados[nIndex][ARRAY_IND_PROD_POS_HORFIX]
				oJsonIncl["items"][nIndIncl]["fixedHorizonType"             ] := aDados[nIndex][ARRAY_IND_PROD_POS_TPHFIX]
				//Faz a soma de +1 na quantidade do ponto de pedido.
				If oJsonIncl["items"][nIndIncl]["orderPoint"] <> 0
					oJsonIncl["items"][nIndIncl]["orderPoint"]++
				EndIf

				If Empty(aDados[nIndex][ARRAY_IND_PROD_POS_OPC])
					oJsonIncl["items"][nIndIncl]["erpMemoOptional"] := Nil
					oJsonIncl["items"][nIndIncl]["optional"]        := Nil
				Else
					oJsonIncl["items"][nIndIncl]["erpMemoOptional"] := aDados[nIndex][ARRAY_IND_PROD_POS_OPC]
					oJsonIncl["items"][nIndIncl]["optional"]        := MOpcToJson(aDados[nIndex][ARRAY_IND_PROD_POS_OPC], 2)
				EndIf

				If Empty(aDados[nIndex][ARRAY_IND_PROD_POS_STR_OPC])
					oJsonIncl["items"][nIndIncl]["erpStringOptional"] := Nil
				Else
					oJsonIncl["items"][nIndIncl]["erpStringOptional"] := aDados[nIndex][ARRAY_IND_PROD_POS_STR_OPC]
				EndIf
			EndIf
		Else
			nIndExcl++
			AAdd(oJsonExcl["items"], JsonObject():New())

			oJsonExcl["items"][nIndExcl]["branchId"] := aDados[nIndex][ARRAY_IND_PROD_POS_FILIAL]
			oJsonExcl["items"][nIndExcl]["product" ] := aDados[nIndex][ARRAY_IND_PROD_POS_PROD]
			oJsonExcl["items"][nIndExcl]["code"    ] := aDados[nIndex][ARRAY_IND_PROD_POS_IDREG]

		EndIf
	Next nIndex

	If nIndIncl > 0 .or. cOperation == "SYNC"
		If cOperation == "INSERT"
			aReturn := MrpIPrPost(oJsonIncl)
		Else
			aReturn := MrpIPrSync(oJsonIncl,lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonIncl, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
	EndIf

	If nIndExcl > 0
		aReturn := MrpIPrDel(oJsonExcl)
		PrcPendMRP(aReturn, cApi, oJsonExcl, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
	EndIf

	FreeObj(oJsonIncl)
	oJsonIncl := Nil
	FreeObj(oJsonExcl)
	oJsonExcl := Nil

Return Nil

/*/{Protheus.doc} RetTpPrazo
Retorna o código do tipo de prazo de entrega
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cPrazp, Caracter, Tipo de prazo (H=Horas;D=Dias;S=Semana;M=Mês;A=Ano)
@return cRet, Caracter,  1=Horas; 2=Dias; 3=Semana; 4=Mês; 5=Ano
/*/
Static Function RetTpPrazo(cPrazo)

    Do Case
        Case cPrazo == 'H'//Hora
            Return '1'
        Case cPrazo == 'D'//Dia
            Return '2'
        Case cPrazo == 'S'//Semana
            Return '3'
        Case cPrazo == 'M'//Mes
            Return '4'
        Case cPrazo == 'A'//Ano
            Return '5'
    EndCase

Return

/*/{Protheus.doc} RetMrp
Retorna o código do tipo rastro
@type  Function
@author douglas.heydt
@since 07/10/2019
@version P12
@param cTipo, Caracter, Tipo de decimal (D=Sim; I=Não; E=Especial)
@return Caracter,  1=Sim; 2=Não;
/*/
Static Function RetMrp(cTipo)

    If cTipo == 'S'//Sim
        Return '1'
    ElseIf cTipo == 'N'//Não
        Return '2'
    ElseIf cTipo == 'E'//Especial
        Return '2'
    EndIf

Return

/*/{Protheus.doc} M019CnvFld
Retorna o campo convertido no formato a ser enviado para a API (chamada pelo PCPA140)
@type  Function
@author renan.roeder
@since 19/11/2019
@version P12
@param 01 cField, Caracter, campo (coluna da SBZ) a ser convertida
@param 02 cValue, Caracter, valor a ser convertido
@return cValue  , Caracter, valor convertido no formato da API
/*/
Function M019CnvFld(cField, cValue)

    Do Case
        Case cField == "BZ_TIPE"
            cValue := RetTpPrazo(cValue)
        Case cField == "BZ_MRP"
            cValue := RetMrp(cValue)
    EndCase

Return cValue
