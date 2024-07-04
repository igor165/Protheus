#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXPON.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ                 
ฑฑบPrograma    ณAjSXPON    บAutor    ณInova็ใo - RH       บ Data ณ  29/06/2015 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Fonte responsแvels pelos ajustas na versใo p12.               บฑฑ
ฑฑบ            ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ DATA      ณ Chamado     ณ  MOTIVO DA ALTERACAO                ณฑฑ
ฑฑบ            ณ           ณ             ณ                                     ณฑฑ
ฑฑบ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณOswaldo L   ณ27-04-17   ณDRHPONTP300  ณEntre os dias 24-04-17 e 26-04-17    ณฑฑ
ฑฑณ            ณ           ณ             ณbaixamos os fontes do TFS das pastas ณฑฑ
ฑฑณ            ณ           ณ             ณMAIN, 12.1.14 e 12.1.16. Conforme    ณฑฑ
ฑฑณ            ณ           ณ             ณsolicitado fizemos merge delas,depoisณฑฑ
ฑฑณ            ณ           ณ             ณremovemos alteracoes em SX           ณฑฑ
ฑฑณOswaldo L   ณ01-08-17   ณDRHPONTP-1415ณAjuste atributos campo R6_ABINTJ     ณฑฑ
ฑฑณOswaldo L   ณ15-08-17   ณDRHPONTP-1535ณAjuste novo atributos campo R6_ABINTJณฑฑ
ฑฑศออออออออออฯอออออออฑฑออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Main function PONLoad()
Local lRet   		:= .T.

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)
