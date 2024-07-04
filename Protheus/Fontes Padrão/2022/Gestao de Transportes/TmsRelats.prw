#INCLUDE "PROTHEUS.CH"

/*Fun��o para verificar se as RDMAKES est�o compiladas e caso estejam, sejam executadas,
quando chamadas pelo menu
Autor: Jo�o Venturini
03/03/2022
*/

/*Fun��o para verificar se o RDMAKE RTMSR01 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR01()
Local lR01        := ExistBlock("RTMSR01", , .T. )

If lR01
	ExecBlock("RTMSR01",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR05 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR05()
Local lR05        := ExistBlock("RTMSR05", , .T. )

If lR05
	ExecBlock("RTMSR05",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR06 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR06()
Local lR06        := ExistBlock("RTMSR06", , .T. )

If lR06
	ExecBlock("RTMSR06",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR07 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR07()
Local lR07        := ExistBlock("RTMSR07", , .T. )

If lR07
	ExecBlock("RTMSR07",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR08 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR08()
Local lR08        := ExistBlock("RTMSR08", , .T. )

If lR08
	ExecBlock("RTMSR08",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR10 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR10()
Local lR10        := ExistBlock("RTMSR10", , .T. )

If lR10
	ExecBlock("RTMSR10",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR15 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR15()
Local lR15        := ExistBlock("RTMSR15", , .T. )

If lR15
	ExecBlock("RTMSR15",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR16 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR16()
Local lR16        := ExistBlock("RTMSR16", , .T. )

If lR16
	ExecBlock("RTMSR16",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR24 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR24()
Local lR24        := ExistBlock("RTMSR24", , .T. )

If lR24
	ExecBlock("RTMSR24",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR33 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR33()
Local lR33        := ExistBlock("RTMSR33", , .T. )

If lR33
	ExecBlock("RTMSR33",.F.,.F.)
EndIf
Return

/*Fun��o para verificar se o RDMAKE RTMSR36 est� compilado e caso esteja, seja executado
quando chamado pelo menu
Autor: Jo�o Venturini
04/03/2022 */
Function RelTMSR36()
Local lR36        := ExistBlock("RTMSR36", , .T. )

If lR36
	ExecBlock("RTMSR36",.F.,.F.)
EndIf
Return
