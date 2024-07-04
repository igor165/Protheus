#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA600A
Classe interna implementando o FWModelEvent
@author Luis Fellipy Bett
@since 01/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class MDTA600A FROM FWModelEvent

	Method ModelPosVld()
    Method New() Constructor

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA600A
M�todo construtor da classe
@author Luis Fellipy Bett
@since 01/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class MDTA600A
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Valida��o do campo de data de validade inicial do model.
@author Luis Fellipy Bett
@since 01/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld( oModel, cModelId ) Class MDTA600A

	Local aAreaTNG	:= TNG->( GetArea() )
	Local nOpcx		:= oModel:GetOperation() // Opera��o de a��o sobre o Modelo // 3 - Insert ; 4 - Update ; 5 - Delete
	Local oModelTNG	:= oModel:GetModel( "TNGMASTER" )
	Local lRet		:= .T.

	If nOpcx <> MODEL_OPERATION_DELETE //Exclus�o
		lRet := MDTObriEsoc( "TNG", , oModelTNG ) //Verifica se campos obrigat�rios ao eSocial est�o preenchidos
	EndIf

	RestArea( aAreaTNG )

Return lRet
