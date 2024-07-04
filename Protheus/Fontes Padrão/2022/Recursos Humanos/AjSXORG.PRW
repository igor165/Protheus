#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ                 
ฑฑบPrograma    ณAjSXORG    บAutor    ณInova็ใo - RH       บ Data ณ  29/06/2015 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Fonte responsแvels pelos ajustas na versใo p12.               บฑฑ
ฑฑบ            ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ DATA      ณ Chamado     ณ  MOTIVO DA ALTERACAO                ณฑฑ
ฑฑบ            ณ           ณ             ณ                                     ณฑฑ
ฑฑบ            ณ           ณ             ณ                                     ณฑฑ
ฑฑณ            ณ           ณ             ณ                                     ณฑฑ
ฑฑบMatheus M.  ณ 02/02/2016ณ TUHNWS      ณ Ajuste para colocar os campos  -    ณฑฑ
ฑฑบ            ณ           ณ             ณ RCL_DFUNC e RCL_FUNCAO no browse    ณฑฑ
ฑฑบ            ณ           ณ             ณ e para que a descri็ใo da fun็ใo    ณฑฑ
ฑฑบ            ณ           ณ             ณ seja exibida.				       ณฑฑ
ฑฑบRenan Borgesณ 07/11/2016ณ TVTWG9      ณ Realizado a implementa็ใo da op็ใo  ณฑฑ
ฑฑบ            ณ           ณ             ณ 4 da solicita็ใo na rotina de Movi  ณฑฑ
ฑฑบ            ณ           ณ             ณ menta็ใo de Postos, destinada a re  ณฑฑ
ฑฑบ            ณ           ณ             ณ du็ใo da quantidade de postos.      ณฑฑ
ฑฑณOswaldo L   ณ27-04-17   ณDRHPONTP300  ณ Entre os dias 24-04-17 e 26-04-17   ณฑฑ
ฑฑณ            ณ           ณ             ณbaixamos os fontes do TFS das pastas ณฑฑ
ฑฑณ            ณ           ณ             ณMAIN, 12.1.14 e 12.1.16. Conforme    ณฑฑ
ฑฑณ            ณ           ณ             ณsolicitado fizemos merge delas,depoisณฑฑ
ฑฑณ            ณ           ณ             ณremovemos alteracoes em SX           ณฑฑ
ฑฑบIsabel N.   ณ 25/07/2017ณDRHPONTP-360 ณAjuste/Limpeza do fonte para 12.1.17.ณฑฑ
ฑฑศออออออออออฯอออออออฑฑออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Main function ORGLoad()
Local lRet := .T.

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)
