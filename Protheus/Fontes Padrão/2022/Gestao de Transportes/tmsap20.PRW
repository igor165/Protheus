#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAP20.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAP20
    Le arquivo de conciliação
    @type Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAP20()
    (examples)
    @see (links_or_references)
*/
Function TMSAP20()
Local lRet := .T.
Local oTMSVIAFCL

oTMSVIAFCL := TMSBCAVIAFACIL():New()

lRet := oTMSVIAFCL:LoadParams()

If lRet
	//-- Importa praças de pedágio
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsPedagio()},STR0004,STR0005 + " " + STR0007)	//-- "Processando" # "Importando" # "Pedágio"
	If lRet
		FwMsgRun(,{|| oTMSVIAFCL:ConcSemParar("DMJ")},STR0004,STR0006 + " " + STR0007)	//-- "Processando" # "Conciliando" # "Pedágio"
	EndIf

	//-- Importa Estacionamento
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsEstacionamento()},STR0004,STR0005 + " " + STR0008)	//-- "Processando" # "Importando" # "Estacionamento"
    If lRet
		FwMsgRun(,{|| oTMSVIAFCL:ConcSemParar("DMK")},STR0004,STR0006 + " " + STR0008)	//-- "Processando" # "Conciliando" # "Estacionamento"
    EndIf

	//-- Importa Mensalidades
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsMensali()},STR0004,STR0005 + " " + STR0009)	//-- "Processando" # "Importando" # "Mensalidade"
    If lRet
		FwMsgRun(,{|| oTMSVIAFCL:ConcMensalidade()},STR0004,STR0006 + " " + STR0009)	//-- "Processando" # "Conciliando" # "Mensalidade"
    EndIf

	//-- Importa Créditos
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsCredito()},STR0004,STR0005 + " " + STR0010)	//-- "Processando" # "Importando" # "Crédito"
    If lRet
		  FwMsgRun(,{|| oTMSVIAFCL:ConcCredito()},STR0004,STR0006 + " " + STR0010)	//-- "Processando" # "Conciliando" # "Credito"
    EndIf

	//-- Importa Adesao
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsAdesao()},STR0004,STR0005 + " " + STR0011)	//-- "Processando" # "Importando" # "Adesão"
    If lRet
		  FwMsgRun(,{|| oTMSVIAFCL:ConcAdesoes()},STR0004,STR0006 + " " + STR0011)	//-- "Processando" # "Conciliando" # "Adosoes"
    EndIf

	//-- Importa Abastecimento
	FwMsgRun(,{|| lRet := oTMSVIAFCL:InsAbast()},STR0004,STR0005 + " " + STR0012)	//-- "Processando" # "Importando" # "Abastecimento"
    If lRet
		FwMsgRun(,{|| oTMSVIAFCL:ConcSemParar("DMT")},STR0004,STR0006 + " " + STR0012)	//-- "Processando" # "Conciliando" # "Abastecimento"
    EndIf

	//-- Fecha Conciliação
	FwMsgRun(,{|| oTMSVIAFCL:FechaConc()},STR0004,STR0013)	//-- "Processando" # "Fechando Conciliação"
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSAP20Dir()
Abre a tela para leitura das pastas

@author     Felipe Barbiere
@since      31/08/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Function TMSAP20Dir(cCpo)
Local cRet := ""

cRet := cGetFile(,STR0001,,"",.T., GETF_LOCALHARD+GETF_RETDIRECTORY)

&(cCpo) := cRet

Return (!Empty(cRet))

/*{Protheus.doc} TMSAP20Vld
    Valida Campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 02/09/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAP20()
    (examples)
    @see (links_or_references)
*/
Function TMSAP20Vld(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If (Val(SubStr(&(cCampo),1,2))) < 1 .Or. (Val(SubStr(&(cCampo),1,2))) > 12
	Help("",1,"TMSAP2001")	//-- "Mês inválido"
    lRet := .F.
EndIf

Return lRet
