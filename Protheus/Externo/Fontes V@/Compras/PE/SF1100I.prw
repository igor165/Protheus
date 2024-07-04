
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

//****************************************************************
//AP�S GRAVA��O DO CABE�ALHO DA NOTA FISCAL DE ENTRADA
//****************************************************************

User Function SF1100I 
	if Type("cObsMT103") <> "U" .and. !Empty(cObsMT103)
     	Reclock("SF1",.f.)
     		SF1->F1_MENNOTA   := cObsMT103
     	SF1->(MsUnLock())
	endif
Return