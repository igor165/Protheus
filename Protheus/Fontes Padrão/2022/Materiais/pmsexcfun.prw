#include "PROTHEUS.CH"

#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

#DEFINE DTINICIAL           1
#DEFINE DTFINAL             2
#DEFINE PERIODO             3
#DEFINE PEDCOMPRA           4
#DEFINE DESPESAS            5
#DEFINE PEDVENDA            6
#DEFINE RECEITAS            7
#DEFINE SALDODIA            8
#DEFINE SAIDASACUM          9 
#DEFINE ENTRADASACUM        10 
#DEFINE SALDOACUM           11

//COTE
Static aHandCOTE
Static cHandCOTE
Static dHandCOTE


//RPROD
Static aHandRPROD
Static cHandRPROD
Static dHandRPROD


//CTR
Static aHandCTR
Static cHandCTR
Static dHandCTR
//FIN
Static aHandFin
Static cHandFin
Static dHandFin
Static nMoedaFin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcPrj ³ Autor ³ Edson Maricate         ³ Data ³ 10-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array contendo informacoes da estrutura do projeto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcPrj(cProjeto,cRevisa,nMinRet,cCodDe,cCodAte,cFilhos)
Local aRet := {}
DEFAULT nMinRet	:= 100
DEFAULT cCodDe	:= ""
DEFAULT cCodAte	:= "ZZZZZZZZZZZZZZZZZZ"
DEFAULT cFilhos := "AF8/AF9/AFC"
dbSelectArea("AF8")
dbSetOrder(1)              
If MsSeek(xFilial()+cProjeto)
	cRevisa := If(cRevisa==Nil,AF8->AF8_REVISA,cRevisa)
	If "AF8"$cFilhos
		aAdd(aRet,{"AF8",AF8->(RecNo())})
	EndIf
	dbSelectArea("AFC")
	dbSetOrder(3)
	MsSeek(xFilial()+AF8->AF8_PROJET+cRevisa+"001")
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
						AFC->AFC_NIVEL==xFilial("AFC")+AF8->AF8_PROJET+cRevisa+"001"
		AuxExcPrj(AFC->AFC_PROJET+AFC_REVISA+AFC_EDTPAI,@aRet,cRevisa,cCodDe,cCodAte,cFilhos)
		dbSkip()
	End
EndIf

If Empty(aRet)
	aRet := ARRay(nMinRet,2)
EndIf


Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | AuxExcPrj ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxExcPrj(cChave,aRet,cRevisa,cCodDe,cCodAte,cFilhos)
Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())


	If AFC->AFC_EDT >= cCodDe .And. AFC->AFC_EDT <= cCodAte
		If "AFC"$cFilhos
			aAdd(aRet,{"AFC",AFC->(RecNo())})
		EndIf
	EndIf
	
	dbSelectArea("AF9")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave)
	While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
						AF9->AF9_EDTPAI==xFilial("AF9")+cChave
		If AF9->AF9_TAREFA >= cCodDe .And. AF9->AF9_TAREFA <= cCodAte
			If "AF9"$cFilhos
				aAdd(aRet,{"AF9",AF9->(RecNo())})
			EndIf
			If "AFA"$cFilhos
				dbSelectArea("AFA")
				dbSetOrder(1)
				MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA
					aAdd(aRet,{"","AFA",AFA->(RecNo())})
					dbSkip()
				End
			EndIf
			If "AFB"$cFilhos
				dbSelectArea("AFB")
				dbSetOrder(1)
				MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
				While !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==;
									AFB_FILIAL+AFB_PROJET+AFB_REVISA+AFB_TAREFA
					aAdd(aRet,{"","AFB",AFB->(RecNo())})
					dbSkip()
				End
			EndIf
		EndIf
		dbSelectArea("AF9")
		dbSkip()
	End
	

dbSelectArea("AFC")
dbSetOrder(2)
MsSeek(xFilial()+cChave)
While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
			AFC->AFC_EDTPAI==xFilial("AFC")+cChave
	AuxExcPrj(AFC->AFC_PROJET+AFC_REVISA+AFC_EDT,aRet,cRevisa,cCodDe,cCodAte,cFilhos)
	dbSkip()
End



RestArea(aAreaAFC)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsExcStru ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcStru(cAlias,nRecNo)

If cAlias <> Nil.And. !Empty(cAlias) .And. nRecno<> Nil .And. !Empty(nRecNo)
	dbSelectArea(cAlias)
	MsGoto(nRecNo)
	If cAlias=="AFC"
		Return SPACE(VAL(AFC_NIVEL)*2)+(cAlias)->AFC_DESCRI
	ElseIf cAlias == "AF9"
		Return SPACE(VAL(AF9_NIVEL)*2)+(cAlias)->AF9_DESCRI
	EndIf
EndIf

Return ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcCod ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcCod(cAlias,nRecNo)

If cAlias <> Nil .And. !Empty(cAlias)
	dbSelectArea(cAlias)
	MsGoto(nRecNo)
	If cAlias=="AFC"
		Return AFC->AFC_EDT
	ElseIf cAlias == "AF9"
		Return AF9->AF9_TAREFA
	EndIf
EndIf
	
Return ""


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcGet ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor do campo, conforme o recno de busca            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcGet(cAlias,nRecNo,cCpo)

If cAlias <> Nil.And. !Empty(cAlias) .And. nRecno<> Nil .And. !Empty(nRecNo)
	dbSelectArea(cAlias)
	MsGoto(nRecNo)
	If (cAlias)->(FieldPos(cAlias+cCpo)) > 0
		Return (cAlias)->(&(cAlias+cCpo))
	Else
		Return ""
	EndIf
Else
	Return ""
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsExcSeek ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor do campo solicitado para busca                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcSeek(cAlias,nOrdem,cSeek,cCpo)

If cAlias <> Nil.And. !Empty(cAlias) .And. nOrdem<> Nil .And. !Empty(nOrdem) .And. cSeek <> Nil .And. !Empty(cSeek)
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	MsSeek(xFilial(cAlias)+cSeek)
	If (cAlias)->(FieldPos(cCpo)) > 0
		Return (cAlias)->(&(cCpo))
	Else
		Return ""
	EndIf
Else
	Return ""
EndIf

Return ""


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcQry ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcQry(cAlias,nOrdem,cSeek,cCondic,cFilter,nMinRet)
Local aRet       := {}
Local aArea      := GetArea()
Local aAreaAlias := (cAlias)->(GetArea())

DEFAULT nMinRet  := 100
DEFAULT cSeek    := ""
DEFAULT cCondic  := ".T."
DEFAULT cFilter  := ".T."
//Preparar para TOP
If cAlias <> Nil .And. !Empty(cAlias) .And. !Empty(cSeek)
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbSeek(xFilial()+cSeek)
	While !Eof() .And. xFilial(cAlias)==&(cAlias+"_FILIAL") .And. &cCondic
		If &(cFilter)
			aAdd(aRet,{cAlias,(cAlias)->(RecNo())})
		EndIf
		dbSkip()
	End
EndIf
	
If Empty(aRet)
	aRet := ARRay(nMinRet,2)
EndIf

RestArea(aAreaAlias)
RestArea(aArea)
Return aRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcCTR ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcCTR(cAlias,nRecNo,nMoeda,dDataRef)
Local nCusto   := ""
DEFAULT nMoeda := 1
If dDataRef == Nil .Or. Empty(dDataRef)
	dDataRef := CTOD("31/12/2025")
EndIf

If cAlias <> Nil .And. !Empty(cAlias) .And. nRecNo<>Nil .And. !Empty(nRecNo)
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		If aHandCTR==Nil .Or. AF9->AF9_PROJET <> cHandCTR .Or. dHandCTR <> dDataRef
			cHandCTR	:= AF9->AF9_PROJET			
			dHandCTR	:= dDataRef
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AF9->AF9_PROJET)
			aHandCTR := PmsIniCRTE(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataRef)
		EndIf
		nCusto := PmsRetCRTE(aHandCTR,1,AF9->AF9_TAREFA)[nMoeda]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		If aHandCTR==Nil .Or. AFC->AFC_PROJET <> cHandCTR .Or. dHandCTR <> dDataRef
			dHandCTR	:= dDataRef			
			cHandCTR	:= AFC->AFC_PROJET
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AFC->AFC_PROJET)
			aHandCTR := PmsIniCRTE(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataRef)
		EndIf
		nCusto := PmsRetCRTE(aHandCTR,2,AFC->AFC_EDT)[nMoeda]
	EndIf
EndIf
	

Return nCusto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcFin ³ Autor ³                        ³ Data ³   -  -     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz o Saldo do Valor Previsto PV ou PC, A Receber, A Pagar,   ³±±
±±³          ³ Recebido e Pago.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcFin(cAlias,nRecNo,nMoeda,dDataRef,nTpRet)
Local nRet     := ""
DEFAULT nMoeda := 1
If dDataRef == Nil .Or. Empty(dDataRef)
	dDataRef := CTOD("31/12/2025")
EndIf

If cAlias <> Nil .And. !Empty(cAlias) .And. nRecNo<>Nil .And. !Empty(nRecNo)
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		If aHandFin==Nil .Or. AF9->AF9_PROJET <> cHandFin .Or. dHandFin <> dDataRef .Or. nMoedaFin <> nMoeda
			cHandFin	:= AF9->AF9_PROJET
			dHandFin	:= dDataRef
			nMoedaFin	:= nMoeda
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AF9->AF9_PROJET)
			aHandFin := PmsIniFin(AF8->AF8_PROJET,AF8->AF8_REVISA,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),,nMoeda,dDataRef)
		EndIf
		nRet := PmsRetFinVal(aHandFin,1,AF9->AF9_TAREFA)[nTpRet]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		If aHandFin==Nil .Or. AF9->AF9_PROJET <> cHandFin .Or. dHandFin <> dDataRef .Or. nMoedaFin <> nMoeda
			cHandFIN	:= AFC->AFC_PROJET
			dHandFin	:= dDataRef
			nMoedaFin	:= nMoeda
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AFC->AFC_PROJET)
			aHandFin := PmsIniFin(AF8->AF8_PROJET,AF8->AF8_REVISA,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),,nMoeda,dDataRef)
		EndIf
		nRet := PmsRetFinVal(aHandFin,2,AFC->AFC_EDT)[nTpRet]
	EndIf
EndIf
	
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsExcFlx ³ Autor ³ Reynaldo T. Miyashita  ³ Data ³ 05.01.2005  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz os saldos no periodo do Valor Previsto PV ou PC, A Receber³±±
±±³          ³ ,A Pagar, Recebido e Pago.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcFlx( cProjeto ,nMoeda ,dDataIni ,nDiasTot ,nPeriodo )
Local nRet	  := 0
Local nCount  := 0
Local nX      := 0
Local nI      := 0
Local dData   := ctod("  /  /    ")
Local aFluxo  := {}
Local nTotRec   := 0
Local nTotDesp  := 0
Local nSaldo	  := 0
Local nSaldoAcm := 0
Local nSaldoDia := 0
Local aArrayFlx := {}
Local nSaidasAcum   := 0
Local nEntradasAcum := 0
Local nEntradasDia  := 0
Local nSaidasDia    := 0
Local nQtdePer := 0
Local nRestPer := 0
Local nDias    := 0
Local nReceitaIni   := 0
Local nDespesaIni   := 0
Local aRet := {}
Local aDias         := {1,7,10,15,30}
Local aArea := GetArea()

DEFAULT nMoeda   := 1    
DEFAULT nDiasTot := 0

nDias   := aDias[nPeriodo]

If ! (dDataIni == Nil .Or. Empty(dDataIni)) 

		dbSelectArea("AF8")
		dbSetOrder(1)
		If dbSeek(xFilial()+cProjeto)
		
			If aHandFin==Nil .Or. AF8->AF8_PROJET <> cHandFin .Or. nMoedaFin <> nMoeda
				cHandFIN	:= AF8->AF8_PROJET
				nMoedaFin	:= nMoeda
				dbSelectArea("AFC")
				dbSetOrder(1)
				dbSeek(xFilial()+AF8->AF8_PROJET)
				aHandFin := PmsIniFin(AF8->AF8_PROJET,AF8->AF8_REVISA,Padr(AF8->AF8_PROJET,len(AFC->AFC_EDT)),.T.,nMoeda)
	
			EndIf
			
			aFluxo := PmsRetFinVal(aHandFin,4,Padr(AF8->AF8_PROJET,len(AFC->AFC_EDT)))

			nTotRec   := 0
			nTotDesp  := 0
			nSaldo    := 0
			nSaldoAcm := 0
			nSaldoDia := 0
			aArrayFlx := {}
	
			nSaidasAcum   := 0
			nEntradasAcum := 0
			nEntradasDia  := 0
			nSaidasDia    := 0
		
			If (nPeriodo <> 5)  
				
				If nDiasTot < nDias
					nQtdePer := 0
					nDias    := nDiasTot
				Else
					nQtdePer := Int(nDiasTot / nDias)
				Endif
			
				// Gera os registros para todas as datas do periodo, inclusive a database
				dDataTrab := dDataIni
				For nX := 1 To nQtdePer
					If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
						Aadd(aArrayFlx, {dDataTrab,(dDataTrab + nDias - 1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0})
					Endif
			
					dDataTrab += nDias
				Next nX
				
			Else
				nQtdDias  := 0  
				dDataTrab := dDataIni
				nMes      := Month(dDataTrab)		
				For dData := dDataIni To dDataIni+nDiasTot
					If (nMes <> Month(dData))
						nQtdePer++
						nMes := Month(dData)
			      
						If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
							Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias-1),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0})
							dDataTrab+= nQtdDias
							nQtdDias:= 0
						EndIf
					EndIf
			
					nQtdDias++
				Next dData
				
				If (nQtdDias > 0)
					If (Ascan(aArrayFlx, {|e|e[DTINICIAL]==dDataTrab}) == 0)
						Aadd(aArrayFlx, {dDataTrab,(dDataTrab+nQtdDias),PMC100DescPer(dDataTrab, nDias),0,0,0,0,0,0,0,0})
					Endif
				EndIf
				
			EndIf

			dDataTrab := dDataIni
			
			// calcula o valor inicial
			// dos pedidos de compra
			For nI := 1 To Len(aFluxo[1])
				If aFluxo[1,nI,1] < dDataTrab
					nDespesaIni += aFluxo[1, nI, 2]		
				EndIf
			Next nI
			
			// calcula a despesa inicial
			For nI := 1 To Len(aFluxo[2])
				// calcula a despesa ate o
				// o primeiro dia do periodo (exclusive)
				If aFluxo[2,nI,1] < dDataTrab
					nDespesaIni += aFluxo[2, nI, 2]		
				EndIf
			Next nI
			
			// calcula o valor inicial
			// dos pedidos de venda
			For nI := 1 To Len(aFluxo[4])
				If aFluxo[4,nI,1] < dDataTrab
					nReceitaIni += aFluxo[4, nI, 2]		
				EndIf
			Next nI
			                             
			// calcula a receita inicial
			For nI := 1 To Len(aFluxo[5])
				// calcula a receita ate o
				// o primeiro dia do periodo (exclusive)
				If aFluxo[5,nI,1] < dDataTrab
					nReceitaIni += aFluxo[5, nI, 2]		
				EndIf
			Next nI
			
			// calcula o saldo inicial
//			nSaldo := aFluxo[6] - aFluxo[3]
			nSaldoAcm := nReceitaIni-nDespesaIni
			
			// atualiza a despesa e receita acumuladas até a data.
			nSaidasAcum   := nDespesaIni
			nEntradasAcum := nReceitaIni

			For nX := 1 To Len(aArrayFlx)
				nSaldoDia := 0
	
				// processa os pedidos de compra
				For nI:= 1 To Len(aFluxo[1])
				    If (aFluxo[1,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[1,nI,1] <= aArrayFlx[nX,DTFINAL])
						aArrayFlx[nX,PEDCOMPRA] += aFluxo[1,nI,2]
						nTotDesp += aFluxo[1,nI,2]
						nSaldoAcm-= aFluxo[1,nI,2]
						nSaldoDia-= aFluxo[1,nI,2]
					EndIf                      
				Next nI
	
				// processa as despesas
				For nI:= 1 To Len(aFluxo[2])
				    If (aFluxo[2,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[2,nI,1] <= aArrayFlx[nX,DTFINAL])
						aArrayFlx[nX,DESPESAS] += aFluxo[2,nI,2]
						nTotDesp += aFluxo[2,nI,2]
						nSaldoAcm-= aFluxo[2,nI,2]
						nSaldoDia-= aFluxo[2,nI,2]
					EndIf                      
				Next nI
	
				// processa os pedidos de venda
				For nI:= 1 To Len(aFluxo[4])
				    If (aFluxo[4,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[4,nI,1] <= aArrayFlx[nX,DTFINAL])
						aArrayFlx[nX,PEDVENDA] += aFluxo[4,nI,2]
						nTotRec  += aFluxo[4,nI,2]
						nSaldoAcm+= aFluxo[4,nI,2]
						nSaldoDia+= aFluxo[4,nI,2]
					EndIf                      
				Next nI
	
				// processas as receitas
				For nI:= 1 To Len(aFluxo[5])
			    	If (aFluxo[5,nI,1] >= aArrayFlx[nX,DTINICIAL]) .And. (aFluxo[5,nI,1] <= aArrayFlx[nX,DTFINAL])
						aArrayFlx[nX,RECEITAS] += aFluxo[5,nI,2]
						nTotRec  += aFluxo[5,nI,2]
						nSaldoAcm+= aFluxo[5,nI,2]
						nSaldoDia+= aFluxo[5,nI,2]
					EndIf                      
				Next nI
			
				nSaidasDia    := aArrayFlx[nX,PEDCOMPRA] +  aArrayFlx[nX,DESPESAS]
				nEntradasDia  := aArrayFlx[nX,PEDVENDA] +  aArrayFlx[nX,RECEITAS]
				nSaidasAcum   += nSaidasDia
				nEntradasAcum += nEntradasDia
				
				aArrayFlx[nX,SALDODIA]     := nSaldoDia
				aArrayFlx[nX,SAIDASACUM]   := nSaidasAcum
				aArrayFlx[nX,ENTRADASACUM] := nEntradasAcum
				aArrayFlx[nX,SALDOACUM]    := nSaldoAcm
			Next nX
		
			aRet := {}
			For nI := 1 to len(aArrayflx)
				aAdd( aRet ,{aArrayFlx[nI,PERIODO]      ;
							,aArrayFlx[nI,PEDCOMPRA]    ; 
							,aArrayFlx[nI,DESPESAS]     ;
							,aArrayFlx[nI,PEDVENDA]     ;
							,aArrayFlx[nI,RECEITAS]     ;
							,aArrayFlx[nI,SALDODIA]     ;
							,aArrayFlx[nI,SAIDASACUM]   ;
							,aArrayFlx[nI,ENTRADASACUM] ;
							,aArrayFlx[nI,SALDOACUM]   };
				)
			Next nI
			
		EndIf         
EndIf

restArea(aArea)

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PmsExcImpl³ Autor ³ Reynaldo Miyashita     ³ Data ³ 12.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array contendo informacoes para o                   ³±±
±±³          ³ programa de implantacao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcImpl( cProjeto ,cRevisa ,nMoeda ,nPeriodo ,dInicio ,dFim ,cCodDe ,cCodAte )
Local aRetorno := {}
Local cFilhos  := "AF8/AF9/AFC"
Local nDias    := 0
Local aTmp     := {} 
Local aPeriodo := {1,7,10,15,30}
Local nCount   := 0  
Local dX 
Local dPerIni

DEFAULT dInicio  := dDatabase
DEFAULT dFim     := dDatabase
DEFAULT cRevisa  := ""
DEFAULT nPeriodo := 0
DEFAULT nMoeda   := 1
DEFAULT cCodDe   := ""
DEFAULT cCodAte  := replicate("Z" ,TamSX3("AF9_TAREFA")[1] )

If nPeriodo <= len(aPeriodo) .and. nPeriodo >0

	nDias := aPeriodo[nPeriodo]

	dbSelectArea("AF8")
	dbSetOrder(1)              
	If MsSeek(xFilial()+cProjeto)
		// caso nao seja informado assume a da tabela.
		cRevisa := If(empty(cRevisa),AF8->AF8_REVISA,cRevisa)
	
		cTrunca := AF8->AF8_TRUNCA
							
		//	
		aTmp := array(5)
		dX := dInicio
		dPerIni := dInicio
		For dX := dInicio To dFim
			nCount++
			
			If nDias == nCount
				If nPeriodo <> 1 
					aAdd( aTmp,dtoc( dPerIni ) + " a " + dtoc( dX ))
				Else
					aAdd( aTmp,dtoc( dX ))
				EndIf
				aAdd( aTmp,space(01))
				dPerIni := dX+1
				nCount := 0
			EndIf
			
		Next dX
		
		If nCount <> 0
			If nPeriodo <> 1 
				aAdd( aTmp,dtoc( dPerIni ) + " a " + dtoc( dFim ))
			Else
				aAdd( aTmp,dtoc( dFim ))
			EndIf
			aAdd( aTmp,space(01))
		EndIf                    
		
		aAdd( aRetorno ,aTmp )
		
		dbSelectArea("AFC")
		dbSetOrder(3)
		MsSeek(xFilial()+AF8->AF8_PROJET+cRevisa+"001")
		While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_NIVEL ;
		                == xFilial("AFC")+AF8->AF8_PROJET+cRevisa+"001"
			AuxExcImpl( AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT ,@aRetorno ,nMoeda ,cCodDe ,cCodAte ,dInicio ,dFim ,nDias ,cFilhos ,cTrunca )
			AFC->(dbSkip())
		End  
		
	EndIf
	
EndIf
	                     
If Empty(aRetorno)
	aRetorno := Array(1,2)
EndIf

Return aRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | AuxExcImpl³ Autor ³ Reynaldo Miyashita     ³ Data ³ 12.01.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array contendo informacoes para o                   ³±±
±±³          ³ programa de implantacao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxExcImpl( cChave ,aRetorno ,nMoeda ,cCodDe ,cCodAte ,dInicio ,dFim ,nDias ,cTrunca )

Local aArea		:= GetArea()
Local aAreaAFC	:= AFC->(GetArea())
Local nVlrCOTP  := 0
Local nVlrCRTE  := 0
Local nTotCOTP  := 0
Local nTotCRTE  := 0
Local dX        
Local aHandCRTE := {}  
Local aHandCOTP := {}
Local nCount    := 0

DEFAULT cTrunca := "1"

	If AFC->AFC_EDT >= cCodDe .And. AFC->AFC_EDT <= cCodAte

	  	aPeriodo := {}
		  
		aadd( aPeriodo ,"AFC" )
		aadd( aPeriodo ,AFC->AFC_EDT )
		aadd( aPeriodo ,PmsExcStru("AFC",AFC->(Recno())) )
		aadd( aPeriodo ,0 ) // custo previsto
		aadd( aPeriodo ,0 ) // custo realizado
		
		nCount := 0
		nTotCOTP  := 0
		nTotCRTE  := 0
		nVlrCOTP  := 0
		nVlrCRTE  := 0
		For dX := dInicio to dFim
		
			nCount++
			
			//COTP - Custo Orcado do Trabalho Previsto          
			aHandCOTP := PmsIniCOTP( AFC->AFC_PROJET ,AFC->AFC_REVISA ,dX ,,,.F. )
			nVlrCOTP += PmsRetCOTP(aHandCOTP,2,AFC->AFC_EDT)[nMoeda]
			
			//COTE - Custo Orcado do Trabalho Executado
			//aHandle	:= PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dx)
			//nValor := PmsRetCOTE(aHandle,2,AFC->AFC_EDT)[nMoeda]
			
			//CRTE - Custo Realizado do Trabalho Executado
			aHandCRTE := PmsIniCRTE( AFC->AFC_PROJET ,AFC->AFC_REVISA ,dX ,,,.F. )
			nVlrCRTE += PmsRetCRTE(aHandCRTE,2,AFC->AFC_EDT)[nMoeda]
		
			If nDias == nCount
				nTotCOTP  += nVlrCOTP
				nTotCRTE  += nVlrCRTE
				aAdd( aPeriodo ,nVlrCOTP )
				aAdd( aPeriodo ,nVlrCRTE )
				nVlrCOTP  := 0
				nVlrCRTE  := 0
				nCount := 0
			Endif
			
		Next dX                                       
		
		If nCount <> 0
			nTotCOTP  += nVlrCOTP
			nTotCRTE  += nVlrCRTE
			aAdd( aPeriodo ,nVlrCOTP )
			aAdd( aPeriodo ,nVlrCRTE )
		EndIf 
		
		aPeriodo[4] := nTotCOTP  // previsto, faz o calculo do ultimo 
		aPeriodo[5] := nTotCRTE  //executado
		aAdd( aRetorno ,aPeriodo )
		
	EndIf

	dbSelectArea("AF9")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave)
	While !Eof() .And. AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+;
						AF9->AF9_EDTPAI==xFilial("AF9")+cChave
		If AF9->AF9_TAREFA >= cCodDe .And. AF9->AF9_TAREFA <= cCodAte
			
		  	aPeriodo := {}
			  
			aadd( aPeriodo ,"AF9" )
			aadd( aPeriodo ,AF9->AF9_TAREFA )
			aadd( aPeriodo ,PmsExcStru("AF9",AF9->(Recno())) )
			aadd( aPeriodo ,0 ) // custo previsto
			aadd( aPeriodo ,0 ) // custo realizado
			
			nCount := 0
			nTotCOTP  := 0
			nTotCRTE  := 0
			nVlrCOTP  := 0
			nVlrCRTE  := 0
			For dX := dInicio to dFim
				
				nCount++

				//COTP - Custo Orcado do Trabalho Previsto          
				// recursos na tarefa
				aHandCOTP := PmsIniCOTP( AF9->AF9_PROJET ,AF9->AF9_REVISA ,dX ,,,.F. )
				nVlrCOTP += PmsRetCOTP(aHandCOTP,1,AF9->AF9_TAREFA)[nMoeda]
				
				//COTE - Custo Orcado do Trabalho Executado
				//aHandle	:= PmsIniCOTE(AFC->AFC_PROJET,AFC->AFC_REVISA,dx)
				//nValor := PmsRetCOTE(aHandle,2,AFC->AFC_EDT)[nMoeda]
				
				//CRTE - Custo Realizado do Trabalho Executado
				aHandCRTE := PmsIniCRTE( AF9->AF9_PROJET ,AF9->AF9_REVISA ,dX ,,,.F. )
				nVlrCRTE += PmsRetCRTE(aHandCRTE,1,AF9->AF9_TAREFA)[nMoeda]
				
				If nDias == nCount
					nTotCOTP  += nVlrCOTP
					nTotCRTE  += nVlrCRTE
					aAdd( aPeriodo ,nVlrCOTP )
					aAdd( aPeriodo ,nVlrCRTE )
					nVlrCOTP  := 0
					nVlrCRTE  := 0
					nCount := 0
				Endif
				
			Next dX
			
			If nCount <> 0
				nTotCOTP  += nVlrCOTP
				nTotCRTE  += nVlrCRTE
				aAdd( aPeriodo ,nVlrCOTP )
				aAdd( aPeriodo ,nVlrCRTE )
			EndIf 
			
			aPeriodo[4] := nTotCOTP  // previsto, faz o calculo do ultimo 
			aPeriodo[5] := nTotCRTE  //executado
			
			aAdd( aRetorno ,aPeriodo )
			
		EndIf
		dbSelectArea("AF9")
		dbSkip()
	End
	
	dbSelectArea("AFC")
	dbSetOrder(2)
	MsSeek(xFilial()+cChave )
	While !Eof() .And. AFC->AFC_FILIAL+AFC->AFC_PROJET+AFC->AFC_REVISA+;
			AFC->AFC_EDTPAI==xFilial("AFC")+cChave
		AuxExcImpl( AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT ,@aRetorno ,nMoeda ,cCodDe ,cCodAte ,dInicio ,dFim ,nDias ,cTrunca )
		AFC->(dbSkip())
	End

RestArea(aAreaAFC)
RestArea(aArea)

Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsExcRPROD³ Autor ³ Edson Maricate         ³ Data ³ 05-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o valor da receita produzida pela tarefa/EDT            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcRPROD(cAlias,nRecNo,nMoeda,dDataRef)

Local nCusto	:= ""
DEFAULT nMoeda	:= 1

If dDataRef == Nil .Or. Empty(dDataRef)
	dDataRef := dDataBase
EndIf

If cAlias <> Nil .And. !Empty(cAlias) .And. nRecNo<>Nil .And. !Empty(nRecNo)
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		If aHandRPROD==Nil .Or. AF9->AF9_PROJET <> cHandRPROD .Or. dHandRPROD <> dDataRef
			cHandRPROD	:= AF9->AF9_PROJET
			dHandRPROD	:= dDataRef
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AF9->AF9_PROJET)
			aHandRPROD := PmsIniRPROD(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataRef)
		EndIf
		nCusto := PmsRetRPROD(aHandRPROD,1,AF9->AF9_TAREFA)[nMoeda]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		If aHandRPROD==Nil .Or. AFC->AFC_PROJET <> cHandRPROD .Or. dHandRPROD <> dDataRef
			dHandRPROD	:= dDataRef			
			cHandRPROD	:= AFC->AFC_PROJET
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AFC->AFC_PROJET)
			aHandRPROD := PmsIniRPROD(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataRef)
		EndIf
		nCusto := PmsRetRPROD(aHandRPROD,2,AFC->AFC_EDT)[nMoeda]
	EndIf
EndIf
	

Return nCusto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsIniRPROD³ Autor ³ Edson Maricate       ³ Data ³ 05-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa as funcoes de calculo do valor de receiras produzi.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PmsIniRPROD(cProjeto,cRevisa,dDataRef,cTrfDe,cTrfAte)


Local aArea		:= GetArea()
Local aAreaAF9	:= AF9->(GetArea())
Local aArrayTrb	:= {}
Local nRProd

DEFAULT cTrfDe		:= ""
DEFAULT cTrfAte		:= "ZZZZZZZZZZZZ"

AF8->(dbSetOrder(1))
AF8->(MsSeek(xFilial()+cProjeto))
cRevisa	:= AF8->AF8_REVISA


dbSelectArea("AF9")
dbSeek(xFilial()+cProjeto+cRevisa+cTrfDe,.T.)
While !Eof() .And. xFilial()+cProjeto+cRevisa==AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA .And. AF9->AF9_TAREFA <= cTrfAte
	nRProd := AF9->AF9_TOTAL*PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef,AF9->AF9_QUANT)/100
	aAdd(aArrayTrb,{AF9->AF9_TAREFA,,{nRProd,0,0,0,0}})
	AddRPRODEDT(@aArrayTrb,{nRProd,;
							0,;
							0,;
							0,;
							0};
							,cProjeto,cRevisa,AF9->AF9_EDTPAI)
 		
	dbSelectArea("AF9")
	dbSkip()
EndDo
	                                         
RestArea(aAreaAF9)
RestArea(aArea)
Return aArrayTrb


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AddRPRODEDT³ Autor ³ Edson Maricate       ³ Data ³ 05-03-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona o custo na EDT do Arquivo de trabalho especificado.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AddRPRODEDT(aArrayTrb,aCusto,cProjeto,cRevisa,cEDT)
Local aArea
Local aAreaAFC
Local nPosEDT	:= aScan(aArrayTrb,{|x|x[2]==cEDT})

If nPosEDT > 0
	aArrayTrb[nPosEDT][3][1] += aCusto[1]
	aArrayTrb[nPosEDT][3][2] += aCusto[2]
	aArrayTrb[nPosEDT][3][3] += aCusto[3]
	aArrayTrb[nPosEDT][3][4] += aCusto[4]
	aArrayTrb[nPosEDT][3][5] += aCusto[5]
Else
	aArea		:= GetArea()
	aAreaAFC	:= AFC->(GetArea())
	dbSelectArea("AFC")
	dbSetOrder(1)
	MsSeek(xFilial()+cProjeto+cRevisa+cEDT)
	aAdd(aArrayTrb,{,cEDT,{0,0,0,0,0},AFC_EDTPAI})
	nPosEDT	:= Len(aArrayTrb)
	aArrayTrb[nPosEDT][3][1] := aCusto[1]
	aArrayTrb[nPosEDT][3][2] := aCusto[2]
	aArrayTrb[nPosEDT][3][3] := aCusto[3]
	aArrayTrb[nPosEDT][3][4] := aCusto[4]
	aArrayTrb[nPosEDT][3][5] := aCusto[5]
	RestArea(aAreaAFC)
	RestArea(aArea)
EndIf

If !Empty(aArrayTrb[nPosEDT,4])
	AddRPRODEDT(aArrayTrb,aCusto,cProjeto,cRevisa,aArrayTrb[nPosEDT,4])
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsRetRPROD³ Autor ³ Edson Maricate       ³ Data ³ 04-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna os custos da tarefa,EDT ou Bloco de Trabalho          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsRetRPROD(aArrayTrb,nTipo,cCodigo)
Local aCusto := {0,0,0,0,0}

Do Case
	Case nTipo == 1
		nPosSeek := aScan(aArrayTrb,{|x|x[1]==cCodigo})
		If nPosSeek>0
			aCusto := aArrayTrb[nPosSeek][3]
		EndIf
	Case nTipo == 2
		nPosSeek := aScan(aArrayTrb,{|x|x[2]==cCodigo})
		If nPosSeek>0
			aCusto := aArrayTrb[nPosSeek][3]
		EndIf
EndCase

Return aCusto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |PmsExcEDT1 ³ Autor ³ Edson Maricate         ³ Data ³ 10-08-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna um array contendo informacoes do 1o nivel do projeto   ³±±
±±³          ³ EDT Pai do nivel 001                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PmsExcEDT1(cProjeto,cRevisa)
Local aRet := {}
Local nMinRet	:= 1

dbSelectArea("AF8")
dbSetOrder(1)
If MsSeek(xFilial()+cProjeto)
	cRevisa := If(cRevisa==Nil,AF8->AF8_REVISA,cRevisa)
	dbSelectArea("AFC")
	dbSetOrder(3)
	If MsSeek(xFilial()+AF8->AF8_PROJET+cRevisa+"001")
		aAdd(aRet,{"AFC",AFC->(RecNo())})
	EndIf
EndIf

If Empty(aRet)
	aRet := ARRay(nMinRet,2)
EndIf


Return aRet



Function PmsExcCOTE(cAlias,nRecNo,nMoeda,dDataRef)
Local nCusto	:= ""
DEFAULT nMoeda	:= 1
If dDataRef == Nil .Or. Empty(dDataRef)
	dDataRef := CTOD("31/12/2025")
EndIf

If cAlias <> Nil .And. !Empty(cAlias) .And. nRecNo<>Nil .And. !Empty(nRecNo)
	If cAlias=="AF9"
		AF9->(MsGoto(nRecNo))
		If aHandCOTE==Nil .Or. AF9->AF9_PROJET <> cHandCOTE .Or. dHandCOTE <> dDataRef
			cHandCOTE	:= AF9->AF9_PROJET			
			dHandCOTE	:= dDataRef
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AF9->AF9_PROJET)
			aHandCOTE := PmsIniCOTE(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataRef)
		EndIf
		nCusto := PmsRetCOTE(aHandCOTE,1,AF9->AF9_TAREFA)[nMoeda]
	ElseIf cAlias=="AFC"
		AFC->(MsGoto(nRecNo))
		If aHandCOTE==Nil .Or. AFC->AFC_PROJET <> cHandCOTE .Or. dHandCOTE <> dDataRef
			dHandCOTE	:= dDataRef			
			cHandCOTE	:= AFC->AFC_PROJET
			dbSelectArea("AF8")
			dbSetOrder(1)
			dbSeek(xFilial()+AFC->AFC_PROJET)
			aHandCOTE := PmsIniCOTE(AF8->AF8_PROJET,AF8->AF8_REVISA,dDataRef)
		EndIf
		nCusto := PmsRetCOTE(aHandCOTE,2,AFC->AFC_EDT)[nMoeda]
	EndIf
EndIf
	

Return nCusto



Function PmsExcQR(cAlias,nRecNo,dDataRef)
Local nRet := ""

Default dDataRef := dDataBase

If cAlias=="AF9"
	AF9->(MsGoto(nRecNo))
	nRet := PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)*AF9->AF9_QUANT/100
ElseIf cAlias=="AFC"
	AFC->(MsGoto(nRecNo))
	nRet := PmsPOCAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,dDataRef)*AFC->AFC_QUANT/100
EndIf

Return nRet


Function PmsExcQP(cAlias,nRecNo,dDataRef)
Local nRet := ""
Default dDataRef := dDataBase

If cAlias=="AF9"
	AF9->(MsGoto(nRecNo))
	nRet := (PMSPrvAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataRef)/AF9->AF9_HUTEIS)*AF9->AF9_QUANT
ElseIf cAlias=="AFC"
	AFC->(MsGoto(nRecNo))
	nRet := (PMSPrvAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT,dDataRef)/AFC->AFC_HUTEIS)*AFC->AFC_QUANT
EndIf

Return nRet

Static Function PMSSplit(cCode, cSep)
	Local nAt := At(cSep, cCode)
	Local aSplit := {}

	While nAt > 0
		Aadd(aSplit, Left(cCode, nAt - 1))
		cCode := Substr(cCode, nAt + Len(cSep))
		nAt := At(cSep, cCode)
	End
		
	Aadd(aSplit, cCode)
Return aSplit

Static Function XLSplit(cCode)
	
	Local aParam := PMSSplit(cCode, ":")
	
	If Len(aParam) > 1
		aParam[2] := Val(aParam[2])
	Else
		Aadd(aParam, Nil)	
	EndIf
Return aParam

Function PmsXLCode(cCode)
	Local aParam := XLSplit(cCode)
Return PmsExcCod(aParam[1], aParam[2])

Function PmsXLStru(cCode)
	Local aParam := XLSplit(cCode)
Return PmsExcStru(aParam[1], aParam[2])

Function PmsXLGet(cCode, cCpo)
	Local aParam := XLSplit(cCode)
Return PmsExcGet(aParam[1], aParam[2], cCpo)

Function PmsXLQP(cCode, dDataRef)
	Local aParam := XLSplit(cCode)
Return PmsExcQP(aParam[1], aParam[2], dDataRef)

Function PmsXLQR(cCode, dDataRef)
	Local aParam := XLSplit(cCode)
Return PmsExcQR(aParam[1], aParam[2], dDataRef)

Function PmsXLRPROD(cCode, nMoeda, dDataRef)
	Local aParam := XLSplit(cCode)
Return PmsExcRPROD(aParam[1], aParam[2], nMoeda, dDataRef)

Function PmsXLCTR(cCode, nMoeda, dDataRef)
	Local aParam := XLSplit(cCode)
Return PmsExcCTR(aParam[1], aParam[2], nMoeda, dDataRef)

Function PmsXLCOTE(cCode, nMoeda, dDataRef)
	Local aParam := XLSplit(cCode)
Return PmsExcCOTE(aParam[1], aParam[2], nMoeda, dDataRef)

Function PmsExcEDT2(cProjeto, cRevisa)
	Local aRet := {}
	Local nMinRet	:= 1
	
	dbSelectArea("AF8")
	dbSetOrder(1)
	If MsSeek(xFilial()+cProjeto)
		cRevisa := If(cRevisa==Nil,AF8->AF8_REVISA,cRevisa)
		dbSelectArea("AFC")
		dbSetOrder(3)
		If MsSeek(xFilial()+AF8->AF8_PROJET+cRevisa+"001")
			aAdd(aRet,{"AFC:" + AllTrim(Str(AFC->(RecNo()))) } )
		EndIf
	EndIf
	
	If Empty(aRet)
		aRet := ARRay(nMinRet)
	EndIf
Return aRet


