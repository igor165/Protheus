#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ                 
ฑฑบPrograma    ณAjSXTCF    บAutor    ณInova็ใo - RH       บ Data ณ  29/06/2015 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Fonte responsแvels pelos ajustas na versใo p12.               บฑฑ
ฑฑบ            ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ DATA      ณ Chamado     ณ  MOTIVO DA ALTERACAO                ณฑฑ
ฑฑบMatheus M.  ณ01/07/2016 ณ TVHRQX      ณ  Ajuste no valid do campo AI8_VISAPVณฑฑ
ฑฑบ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณOswaldo L   ณ27-04-17   ณDRHPONTP300  ณ Entre os dias 24-04-17 e 26-04-17   ณฑฑ
ฑฑณ            ณ           ณ             ณ baixamos os fontes do TFS das pastas ณฑฑ
ฑฑณ            ณ           ณ             ณ MAIN, 12.1.14 e 12.1.16. Conforme    ณฑฑ
ฑฑณ            ณ           ณ             ณ solicitado fizemos merge delas,depoisณฑฑ
ฑฑณ            ณ           ณ             ณ removemos alteracoes em SX           ณฑฑ
ฑฑศออออออออออฯอออออออฑฑออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Main function TCFLoad()
Local lRet        := .T.

If FindFunction('fChkConv12')
   lRet := fChkConv12()
EndIf   

If !lRet
	Return
Endif

Return (.T.)
