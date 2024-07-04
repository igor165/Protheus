#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ                 
ฑฑบPrograma    ณAjSXAPD    บAutor    ณInova็ใo - RH       บ Data ณ  29/06/2015 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.       ณ Fonte responsแvels pelos ajustas na versใo p12.               บฑฑ
ฑฑบ            ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador ณ DATA      ณ Chamado     ณ  MOTIVO DA ALTERACAO                ณฑฑ
ฑฑบMatheus M.  ณ 20/09/2016ณ TVWCPN      ณ Ajustes para a descri็ใo do browse  ณฑฑ
ฑฑบ            ณ           ณ             ณ na tabela de QUESTีES nใo duplicar  ณฑฑ
ฑฑบ            ณ           ณ             ณ os campos.                          ณฑฑ
ฑฑบ Isabel N.  ณ 25/04/2017ณ DRHPONTP-96 ณAjuste no campo RD8_HABIL p/ trazer aณฑฑ
ฑฑบ            ณ           ณ             ณRBJ ao inv้s da RBG na Cons.Padrใo.  ณฑฑ
ฑฑบ Willian U. ณ 08/06/2017ณ DRHPONTP-59 ณTratamento da mแscara de senha       ณฑฑ
ฑฑบ            ณ           ณ             ณ(DRHPONTP-334) transferido para o fonณฑฑ
ฑฑบ            ณ           ณ             ณte AjSXAPD.PRW por se tratar de alte ณฑฑ
ฑฑบ            ณ           ณ             ณra็ใo do dicionแrio e altera็ใo na   ณฑฑ
ฑฑบ            ณ           ณ             ณvalida็ใo do campo RD0_PERMAD para   ณฑฑ
ฑฑบ            ณ           ณ             ณaceitar vazio.                       ณฑฑ
ฑฑบ Willian U. ณ 10/07/2017ณ DRHPONTP-29 ณAjuste no inicializador padrใo e no  ณฑฑ
ฑฑบ            ณ           ณ             ณinicializador do browser do campo    ณฑฑ
ฑฑบ            ณ           ณ             ณQO_MEMO (Descri็ใo Detalhada).       ณฑฑ
ฑฑบIsabel N.   ณ 25/07/2017ณDRHPONTP-360 ณAjuste/Limpeza do fonte para 12.1.17.ณฑฑ
ฑฑบIsabel N.   ณ 02/08/2017ณDRHPONTP-1214ณAjuste nos inicializadores do campo  ณฑฑ
ฑฑบ            ณ           ณ             ณRBJ_DHABIL p/considerar filial certa.ณฑฑ
ฑฑศออออออออออฯอออออออฑฑออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Main function APDLoad()
Local lRet := .T.

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)
