#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/10/99
#include "sigawin.ch"        // incluido pelo assistente de conversao do AP5 IDE em 08/09/99
#include "co_nit.ch"

// Substituido pelo assistente de conversao do AP5 IDE em 29/10/99 ==> Function co_nit()        // incluido pelo assistente de conversao do AP5 IDE em 08/09/99
Function co_nit(cCampo)        // incluido pelo assistente de conversao do AP5 IDE em 08/09/99()

//+---------------------------------------------------------------------+
//¦ Declaracao de variaveis utilizadas no programa atraves da funcao    ¦
//¦ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ¦
//¦ identificando as variaveis publicas do sistema utilizadas no codigo ¦
//¦ Incluido pelo assistente de conversao do AP5 IDE                    ¦
//+---------------------------------------------------------------------+

SetPrvt("LRETORNO,CVAR,CNIT,_CALIASOLD,W_W,W_NRO_NIT,CTABELA")
SetPrvt("W_V_N0,W_V_N1,W_V_N2,W_V_N3,W_V_N4,W_V_N5")
SetPrvt("W_V_N6,W_V_N7,W_V_N8,W_V_N9,W_V_N10,W_V_N11")
SetPrvt("W_V_N12,W_V_N13,W_V_N14,W_V_INT,W_V_NR,W_V_NENT")
SetPrvt("W_V_ND,CHELP,_CALIASCUR,_CNOME,")

/*
_____________________________________________________________________________
ªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªª
ªª+-----------------------------------------------------------------------+ªª
ªªªFunþÓo    ª CO_NIT   ª Autor ª Denis Rodrigues       ª Data ª 08/09/99 ªªª
ªª+----------+------------------------------------------------------------ªªª
ªªªDescriþÓo ª Calcular el digito verificador del NIT  e validar a existe-ªªª
ªªª          ª ncia de NITS duplicados.                                   ªªª
ªª+-----------------------------------------------------------------------+ªª
ªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªªª
»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
*/
lRetorno := .T.

cVar  := Subs(ReadVar(),4,10)
cTabela := Substr(cVar,1,AT("_",cVar)-1)

If !Empty(cCampo)
	cNIt := &("M->"+cTabela+"_"+cCampo)
Else
	cNIT := &("M->"+cTabela+Iif(cTabela=="U5","_CPF","_CGC"))
EndIf

_cAliasOld := Alias()

//+-------------------------------------------------------------------+
//ª Toma el valor del campo leido.                                    ª
//+-------------------------------------------------------------------+


If Len(Alltrim(cNIT)) < 10
   	chelp := OemToAnsi(STR0001)  // "Numero de Digito Invalido"
    Help(OemToAnsi(STR0002),1,"NIT",,chelp,1,1)  //"Verifique "
    lRetorno := .F.
Endif

If !lRetorno
	Return(lRetorno)
Endif

w_nro_nit :=replicate("0",15 - Len(Alltrim(cNIT))) + Alltrim(cNIT)

w_v_dig := val(substr(w_nro_nit,15,1))

w_nro_nit := (stuff(w_nro_nit,15,1,""))

w_nro_nit :=replicate("0",15 - Len(Alltrim(w_nro_nit))) + Alltrim(w_nro_nit)

/*If Len(Alltrim(cNIT)) > 9
   w_v_dig := val(substr(w_nro_nit,15,1))
   cNIT := stuff(w_nro_nit,15,1,"")
   w_nro_nit :=replicate("0",15 - Len(Alltrim(cNIT))) + Alltrim(cNIT)
Endif

If Len(Alltrim(M->A1_CGC)) < 9
	chelp := "Numero de NIT Invalido"
    Help("Verifique ",1,"NIT",,chelp,1,1)
    lRetorno := .F.
Endif
*/

w_v_n0  := val(substr(w_nro_nit,1,1)) * 71
w_v_n1  := val(substr(w_nro_nit,2,1)) * 67
w_v_n2  := val(substr(w_nro_nit,3,1)) * 59
w_v_n3  := val(substr(w_nro_nit,4,1)) * 53
w_v_n4  := val(substr(w_nro_nit,5,1)) * 47
w_v_n5  := val(substr(w_nro_nit,6,1)) * 43
w_v_n6  := val(substr(w_nro_nit,7,1)) * 41
w_v_n7  := val(substr(w_nro_nit,8,1)) * 37
w_v_n8  := val(substr(w_nro_nit,9,1)) * 29
w_v_n9  := val(substr(w_nro_nit,10,1)) * 23
w_v_n10 := val(substr(w_nro_nit,11,1)) * 19
w_v_n11 := val(substr(w_nro_nit,12,1)) * 17
w_v_n12 := val(substr(w_nro_nit,13,1)) * 13
w_v_n13 := val(substr(w_nro_nit,14,1)) * 7
w_v_n14 := val(substr(w_nro_nit,15,1)) * 3


w_v_int :=(w_v_n0+w_v_n1+w_v_n2+w_v_n3+w_v_n4+w_v_n5+w_v_n6+w_v_n7+w_v_n8+w_v_n9+;
		  w_v_n10+w_v_n11+w_v_n12+w_v_n13+w_v_n14) // Obtem Acumulado

w_v_nr := (w_v_int) % 11 // Obtem parte inteira

w_v_nd := 11 - w_v_nr                // DIGITO VERIFICADOR

If w_v_nd > 9
   w_v_nd := 11 - w_v_nd
Endif
//+-------------------------------------------------------------------+
//ª Valida el digito ingresado...                                     ª
//+-------------------------------------------------------------------+

	If w_v_dig == w_v_nd
       lRetorno := .T.
    Else
       chelp := OemToAnsi(STR0003)  // "Numero de NIT Invalido"
       Help(OemToAnsi(STR0002),1,"NIT",,chelp,1,1)  //"Verifique "
       lRetorno := .F.
    Endif

/*If lRetorno .and. Len(Alltrim(cNIT)) <= 9
   M->A1_CGC := Alltrim(M->A1_CGC)+Str(w_v_nd,1)
Endif
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/10/99 ==> Return(lRetorno)  // Substituido pelo assistente de conversao do AP5 IDE em 08/09/99 ==> __Return(lretorno)
Return(lRetorno)  // Substituido pelo assistente de conversao do AP5 IDE em 08/09/99 ==> __Return(lretorno)        // incluido pelo assistente de conversao do AP5 IDE em 29/10/99

