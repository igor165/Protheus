#include "protheus.ch"

#define MB_ICONASTERISK             64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVV002()
Valida digitacao de Placa2 Carreta
Adaptação da função TDCVV002
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLVV002()
Local _aArea  := GetArea()
Local cMens   := ""
Local lRet    := .T.
Local cTipo1  := ""

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return 
Endif

DBSELECTAREA("DHA")
DBSETORDER(1)
DHA->(DBSEEK(XFILIAL("DHA")+M->C5_PLACA1))
cTipo1 := DHA->DHA_TIPO
// VALIDA PLACA TRUCK/CARRETA
IF EMPTY(M->C5_PLACA1)
	cMens+="Placa Truck/Cavalo Deve ser informada"+chr(13)
	lRet    := .F.
ELSEIF ! DHA->(DBSEEK(XFILIAL("DHA")+M->C5_PLACA2))
	cMens+="Placa Informada Nao cadastrada"+chr(13)
	lRet    := .F.
ELSEIF DHA->DHA_TIPO == "CV"
	cMens+="Placa Deve Pertencer Carreta ou Truck "+CHR(13)
	lRet    := .F.
ELSEIF cTipo1 == "TR" .AND. M->C5_PLACA1<>M->C5_PLACA2
	cMens+="Se Primeira Placa For Truck  -> Segunda Placa deve ser a mesma "+CHR(13)
	lRet    := .F.
ELSEIF cTipo1 == "CV" .AND. DHA->DHA_TIPO <> "CR"
	cMens+="Se Primeira Placa For veiculo Cavalo  -> Segunda deve Ser carreta "+CHR(13)
	lRet    := .F.
ELSE
	IF ! EMPTY(DHA->DHA_ITEMDE)
	   IF DHA->DHA_DTLIMI >= DDATABASE .and. !empty(DHA->DHA_DTLIMI) 
			cMens+="Carreta com Itens Pendentes - Data Limite : "+ substr(DTOS(DHA->DHA_DTLIMI),7,2)+"/"+substr(DTOS(DHA->DHA_DTLIMI),5,2)+"/"+substr(DTOS(DHA->DHA_DTLIMI),1,4)+CHR(13)
            lRet    := .T.
	   ELSE
		cMens+="Carreta com Vistoria Pendente"+CHR(13)
		lRet    := .F.
	ENDIF
	ENDIF
	IF DHA->DHA_PRXVIS < DDATABASE
		cMens+="Carreta com Vistoria Vencida"+CHR(13)
		lRet    := .F.
	ENDIF
	IF DHA->DHA_VLAFER < DDATABASE
		cMens+="Carreta com Data da Afericao Vencida"+CHR(13)
		lRet    := .F.
	ENDIF
ENDIF
IF ! lRet
	MessageBox(cMens,"informacao",MB_ICONASTERISK)
    IF cTipo1 <> "TR"
       M->C5_PLACA2:=SPACE(7)
    ELSE
       M->C5_PLACA2:=M->C5_PLACA1
    ENDIF
    lRet:=.T.
ELSEIF !empty(cMens)
	MessageBox(cMens,"informacao",MB_ICONASTERISK)
ENDIF
RestArea(_aArea)
Return(lRet)


