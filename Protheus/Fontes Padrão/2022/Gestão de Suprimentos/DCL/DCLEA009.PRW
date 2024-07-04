#INCLUDE "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA009
Cadastro Itens de faturamento para cessionarias       

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function DCLEA009()  

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

AxCadastro("D38","Itens de faturamento Cessionarias","A009EXCLUSAO()","A009ALTERACAO()")
Return(nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ALTERACAO

@author TOTVS
@since 09/02/2017
@version P12AD
/*/
//------------------------------------------------------------------- 
Function A009ALTERACAO()
Local aAreaD38	:= D38->(GetArea()) 
SetPrvt("LRET,_MENS,")
lRet := .t.
_Mens := ""

IF M->D38_DATA <= GETMV("MV_ULMES")
   _Mens := " Data " + DTOC(M->D38_DATA) + " Anterior a do Ultimo Fechamento " + DTOC(GETMV("MV_ULMES"))
   lRet := .f.
ENDIF
IF M->D38_TIPO == "A"
   _Mens := " Tipo de Lancamento Automatico Nao Pode Ser alterado "
   lRet := .f.
ENDIF
IF ! lRet
   MsgAlert(_Mens,"Processo Abortado")
ENDIF

RestArea(aAreaD38)

Return(lRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEA001

@author TOTVS
@since 09/02/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function A009EXCLUSAO() 
SetPrvt("LRET,_MENS,")
lRet := .t.
_Mens := ""
IF D38->D38_DATA <= GETMV("MV_ULMES")
   _Mens := " Data " + DTOC(D38->D38_DATA) + " Anterior a do Ultimo Fechamento " + DTOC(GETMV("MV_ULMES"))
   MsgAlert(_Mens,"Processo Abortado")
   lRet := .f.
ENDIF
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl009CdIt
Retorna o próximo numero de controle do campo D38_CODITE
@author jose.eulalio
@since 21/03/2017
@version P12
/*/
//------------------------------------------------------------------- 
Function Dcl009CdIt() 
Local cRet := GetSxeNum("D38","D38_CODITE") 
Return cRet

