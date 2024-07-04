#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLAUDAUTJB
 Schedule para job
Função que chama o Job de comunicação para atualizar o status do parecer da auditoria no novo autorizador
(criado novo fonte para criacao do SchedDef e o nome do fonte deve ser o mesmo do Job)

@author renan.almeida
@since 06/05/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLAUDAUTJB()
    PLJBAUDAUT()
	BE4->(dbSetOrder(1))
	if BE4->(FieldPos("BE4_COMAUT")) > 0
		PLJBINTAUT()
	endIf
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
 Schedule para job
 
@author renan.almeida
@since 06/05/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
	Local aOrd   := {}
	Local aParam := {}

	aParam := { 'P','PARAMDEF','',aOrd,'PLAUDAUTJB'}
    
Return aParam