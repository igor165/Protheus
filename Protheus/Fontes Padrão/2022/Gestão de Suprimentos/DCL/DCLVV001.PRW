#include "protheus.ch"

#define MB_ICONASTERISK             64

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLVV001()
Valida digitacao de Placa1 Truck/Cavalo
Adaptação da função TDCVV001
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLVV001()
Local _aArea  := GetArea()
Local cMens   := ""
Local lRet    := .T.

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

If !SuperGetMv("MV_DCLNEW",.F.,.F.)
	Return 
Endif

DBSELECTAREA("DHA")
DBSETORDER(1)
IF DHA->(DBSEEK(XFILIAL("DHA")+M->C5_PLACA1))
	IF DHA->DHA_TIPO == "CR"
		cMens+="Placa Deve Pertencer a Truck ou Cavalo"+CHR(13)
        lRet    := .F.
	ELSE
		IF DHA->DHA_TIPO == "TR"
			M->C5_PLACA2:=DHA->DHA_PLACA
		ELSE
			M->C5_PLACA2:=SPACE(7)
		ENDIF
		IF ! EMPTY(DHA->DHA_ITEMDE)
		   IF DHA->DHA_DTLIMI >= DDATABASE .and. !empty(DHA->DHA_DTLIMI) 
				cMens+="Veiculo com Itens Pendentes - Data Limite : "+ substr(DTOS(DHA->DHA_DTLIMI),7,2)+"/"+substr(DTOS(DHA->DHA_DTLIMI),5,2)+"/"+substr(DTOS(DHA->DHA_DTLIMI),1,4)+CHR(13)
	            lRet    := .T.
		   ELSE
			cMens+="Veiculo com Vistoria Pendente"+CHR(13)
            lRet    := .F.
    	   ENDIF     
		ENDIF
		IF DHA->DHA_PRXVIS < DDATABASE
			cMens+="Veiculo com Vistoria Vencida"+CHR(13)
            lRet    := .F.
		ENDIF
		IF DHA->DHA_VLAFER < DDATABASE
			cMens+="Veiculo com Data da Afericao Vencida"+CHR(13)
            lRet    := .F.
		ENDIF
		cTipo1:=DHA->DHA_TIPO
	ENDIF
ELSE
	cMens+="Placa Informada Nao cadastrada"+chr(13)
    lRet    := .F.
ENDIF
IF ! lRet
	MessageBox(cMens,"informacao",MB_ICONASTERISK)
    M->C5_PLACA1:=SPACE(7)
    lRet:=.T.
ELSEIF !empty(cMens)
	MessageBox(cMens,"informacao",MB_ICONASTERISK)
ENDIF
RestArea(_aArea)
Return(lRet)


