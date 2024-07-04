#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
Fonte contendo o FWModelEvent de integra��es entre SIGAPFS e outros m�dulos
*/

//-------------------------------------------------------------------
/*/ { Protheus.doc } JurEvent - Function Dummy 
Fun��o que verifica se uma classe existe no fonte.

� necess�rio ajustar a vari�vel "cAllClass" a cada inclus�o de classe 
nesse fonte indicando o nome da classe, conforme o exemplo abaixo:

Foi adicionada a classe CTBA000EVPFS.
A vari�vel deve ser atualizada da seguinte forma:

Local cAllClass := "CTBA012EVPFS|CTBA000EVPFS"

� extremamente importante garantir que todas as classes existentes 
no fonte sejam indicadas nessa vari�vel.

@author Jorge Martins
@since 24/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurEvent(cClass)
Local lRet      := .F.
Local cAllClass := "CTBA012EVPFS"

Default cClass := ""

lRet := cClass $ cAllClass

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } CTBA012EVPFS
FWModelEvent da rotina de "Bloqueio de Processos" - CTBA012

@author Jorge Martins
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Class CTBA012EVPFS FROM FWModelEvent
	Method New()
	Method BeforeTTS()
End Class

Method New() Class CTBA012EVPFS
Return

Method BeforeTTS(oModel, cModelId) Class CTBA012EVPFS

	If FindFunction("JSyncCQD")
		JSyncCQD(oModel:GetModel())
	EndIf

Return