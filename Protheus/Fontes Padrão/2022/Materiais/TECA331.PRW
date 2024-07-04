#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"       
#INCLUDE "TECA331.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA331
Alocação Automatica dos Atendentes 

@sample 	TECA331(cNumContr, cNumOrcS) 

@author		Bruno O. Rosa
@since		10/05/2013       
@version	P12   
@param		ExpC1,	Numero do Contrato
@param		ExpC2, Código Orçamento de Serviços	
	
@return		ExpL	Verdadeiro
/*/         
//------------------------------------------------------------------------------
Function TECA331(cNumContr,cNumOrcS)
	MsgInfo(STR0057) //"Alocação Automatica dos Atendentes: Rotina Descontinuada!"
Return (.T.) 