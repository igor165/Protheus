#include "protheus.ch"

#define MB_ICONASTERISK             64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVV003()
Valida digitacao do codigo do Motorista
Adaptação da função TDCVV003
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLVV003()
Local _aArea  := GetArea()
Local cMens   := ""
Local lRet    := .T.

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return 
EndIf

If GETMV("MV_BLMOPE")=="S" .AND. DHB->DHB_VENCTO < DDATABASE 
   cMens += " Curso Mope do Motorista Vencido" + CHR(13)
   lRet:=.F.
ENDIf
If GETMV("MV_BLEXMED")=="S" .AND. DHB->DHB_DTVALE < DDATABASE 
   cMens += " Exame medico Motorista vencido" + CHR(13)
   lRet:=.F.
ENDIf

If GETMV("MV_VISTOMO")=="S"
   If DHB->DHB_DTVIST < DDATABASE
      cMens += " Motorista com Data de Vistoria Vencida" + CHR(13)
      lRet:=.F.
   ENDIf
   If ! EMPTY(DHB->DHB_ITEMDE)
      cMens += " Motorista com Itens em Desacordo" + CHR(13)
      lRet:=.F.
   ENDIf
ENDIf
If ! lRet
	MessageBox(cMens,"informacao",MB_ICONASTERISK)
ENDIf
RestArea(_aArea)
Return(lRet)


