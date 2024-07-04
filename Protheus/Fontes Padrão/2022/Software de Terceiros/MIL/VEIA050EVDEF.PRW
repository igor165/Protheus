#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#DEFINE lDebug .f.

/*/{Protheus.doc} VEIA050EVDEF
//TODO Descrição auto-gerada.

Eventos padrões do Cadastro de Modelo de Veículos - MOD 2, as regras 
definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

@author Rubens
@since 02/12/2018
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
CLASS VEIA050EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR

	METHOD BeforeTTS() 

ENDCLASS

METHOD New() CLASS VEIA050EVDEF
RETURN

METHOD BeforeTTS(oModel, cModelID) CLASS VEIA050EVDEF
	Local oModelVV2Cab
	Local oModelVV2
	Local aAuxFields
	Local nPosField
	Local nLinha
	Local nOperation := oModel:GetOperation()
	Local aCpoCabIns := {}
	Local aCpoCabUpd := {}

	If nOperation <> MODEL_OPERATION_INSERT .and. nOperation <> MODEL_OPERATION_UPDATE
		Return .t.
	EndIf

	oModelVV2Cab := oModel:GetModel("MODEL_VV2CAB")
	oModelVV2 := oModel:GetModel("MODEL_VV2")

	aAuxFields := oModelVV2Cab:GetStruct():GetFields()
	nQtdLinha  := oModelVV2:Length()

	For nPosField := 1 to Len(aAuxFields)
		If aAuxFields[ nPosField , 14 ]
			Loop
		EndIf
		AADD( aCpoCabIns, { aAuxFields[ nPosField, 3 ]  , oModelVV2Cab:GetValue(aAuxFields[ nPosField, 3 ]) } )
		If oModelVV2Cab:IsFieldUpdated(aAuxFields[ nPosField, 3 ])
			AADD( aCpoCabUpd, { aAuxFields[ nPosField, 3 ]  , oModelVV2Cab:GetValue(aAuxFields[ nPosField, 3 ]) } )
		EndIf
	Next nPosField
	
	For nLinha := 1 to nQtdLinha
		oModelVV2:GoLine(nLinha)

		If oModelVV2:IsDeleted()
			Loop
		EndIf
		
		If oModelVV2:IsInserted()
			For nPosField := 1 to Len(aCpoCabIns)
				oModelVV2:LoadValue(aCpoCabIns[ nPosField, 1] , aCpoCabIns[ nPosField, 2 ])
			Next nPosField
			Loop
		EndIf

		For nPosField := 1 to Len(aCpoCabUpd)
			oModelVV2:LoadValue(aCpoCabUpd[ nPosField, 1] , aCpoCabUpd[ nPosField, 2 ])
		Next nPosField

	Next nLinha

	oModelVV2:GoLine(1)

RETURN .t.