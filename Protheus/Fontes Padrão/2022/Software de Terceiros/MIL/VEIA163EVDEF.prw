#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#DEFINE lDebug .f.

/*/{Protheus.doc} VEIA050EVDEF
//TODO Descrição auto-gerada.

@author Rubens
@since 02/12/2018
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
CLASS VEIA163EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR

	METHOD BeforeTTS() 

ENDCLASS

METHOD New() CLASS VEIA163EVDEF
RETURN

METHOD BeforeTTS(oModel, cModelID) CLASS VEIA163EVDEF
	Local oModelVQ1Cab
	Local oModelVQ1
	Local aAuxFields
	Local nPosField
	Local nLinha
	Local nOperation := oModel:GetOperation()
	Local aCpoCabIns := {}
	Local aCpoCabUpd := {}

	If nOperation <> MODEL_OPERATION_INSERT .and. nOperation <> MODEL_OPERATION_UPDATE
		Return .t.
	EndIf

	oModelVQ1Cab := oModel:GetModel("VQ1MASTER")
	oModelVQ1 := oModel:GetModel("VQ1DETAIL")

	cQuery := "SELECT MAX(VQ1_SEQUEN) "
	cQuery += "FROM " + RetSqlName("VQ1") + " VQ1 "
	cQuery += "WHERE VQ1.VQ1_FILIAL = '" + xFilial("VQ1") + "' "
	cQuery +=  " AND VQ1.VQ1_CODIGO = '" + oModelVQ1Cab:GetValue("VQ1_CODIGO") + "' "
	cQuery +=  " AND VQ1.D_E_L_E_T_ = ' '"

	nMaxSeq := FM_SQL(cQuery)
	
	aAuxFields := oModelVQ1Cab:GetStruct():GetFields()
	nQtdLinha  := oModelVQ1:Length()

	oModelVQ1Cab:GetValue(aAuxFields[ nPosField, 3 ])

	For nLinha := 1 to nQtdLinha
		oModelVQ1:GoLine(nLinha)

		If oModelVQ1:IsInserted()
			For nPosField := 1 to Len(aCpoCabIns)
				oModelVQ1:LoadValue("VQ1_SEQUEN", nMaxSeq++)
			Next nPosField
		EndIf

	Next nLinha

	oModelVQ1:GoLine(1)

RETURN .t.