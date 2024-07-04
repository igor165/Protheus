#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAP30.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAP30
    Le arquivo de tarifas da ABCR
    @type Function
    @author Valdemar Roberto Mognon
    @since 07/01/2022
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAP30()
    (examples)
    @see (links_or_references)
*/
Function TMSAP30()
Local lRet := .T.
Local oTMSVIAFCL

oTMSVIAFCL := TMSBCAVIAFACIL():New()

FwMsgRun(,{|| lRet := oTMSVIAFCL:LoadABCR()},STR0001,STR0004 + " " + STR0003)	//-- "Processando" # "Lendo" # "Tarifas"

If lRet
	//-- Importa tarifas
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsTarifa()},STR0001,STR0002 + " " + STR0003)	//-- "Processando" # "Importando" # "Tarifas"
EndIf

Return lRet
