#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "msgraphi.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HSPPO030  ³ Autor ³ Rogerio Tabosa        ³ Data ³ 14/05/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo Comparativo            ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HSPPO030()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAMDI                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function HSPPO030(nCodInd, lImpressao)

Local aArea		:= GetArea()
Local cAliasGCY	:= "GBY"
Local aRet		:= {} 
Local aRet2		:= {} 

Local nJ		:= 0
Local cDtSai	:= '        '
Local nDiasAnt	:= 0
Local nSaidAnt	:= 0
Local nDiasAtu	:= 0
Local nSaidAtu	:= 0
Local nResAnt	:= 0
Local nResAtu	:= 0
Local aMeses	:= {}
Local aVetRet	:= {}
Local aDadosIn	:= {}

Private cMes		:= StrZero(Month(dDataBase),2)
Private cAno		:= Substr(DTOC(dDataBase),7,4)
Private cMesAnt		:= IIf(cMes == "01", "12", StrZero(Val(cMes)-1,2))
Private cAnoAnt		:= Iif(cMesAnt == "12",Str(Val(cAno)-1),cAno)                           
Private dDtIniDAn	:= CTOD("01/"+cMesAnt+"/"+cAnoAnt)
Private dDtFimDAn	:= CTOD(StrZero(F_ULTDIA(dDtIniDAn),2)+"/"+cMesAnt+"/"+cAnoAnt)
Private cDatIniAn	:= DTOS(dDtIniDAn)
Private cDatFimAn	:= DTOS(dDtFimDAn)


Private dDataIni	:= CTOD("01/"+cMes+"/"+cAno)
Private dDataFim	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)
Private dDataIniA	:= CTOD("01/01/"+cAno)
Private dDataFimA := CTOD("31/12/"+cAno)

Private dDataIniD	:= CTOD("01/"+cMes+"/"+cAno)
Private cDatIniD	:= DTOS(dDataIniD)
Private dDataFimD	:= CTOD(StrZero(F_ULTDIA(dDataBase),2)+"/"+cMes+"/"+cAno)

Default nCodInd 	:= 1
Default lImpressao  := .F.

 aAdd(aMeses, "JAN")  //"JANEIRO"
 aAdd(aMeses, "FEV")  //"FEVEREIRO"
 aAdd(aMeses, "MAR")  //"MARÇO"
 aAdd(aMeses, "ABR")  //"ABRIL"
 aAdd(aMeses, "MAI")  //"MAIO"
 aAdd(aMeses, "JUN")  //"JUNHO"
 aAdd(aMeses, "JUL")  //"JULHO"
 aAdd(aMeses, "AGO")  //"AGOSTO"
 aAdd(aMeses, "SET")  //"SETEMBRO"
 aAdd(aMeses, "OUT")  //"OUTUBRO"                                                  
 aAdd(aMeses, "NOV")  //"NOVEMBRO"
 aAdd(aMeses, "DEZ")  //"DEZEMBRO"

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', nCodInd , 0, 0, {})

DbSelectArea("GTA")
DbGoTop()
DbGoTo(nCodInd)
//cQryGTA := E_MSMM(GTA->GTA_QUERY)

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', GTA->GTA_CODIND , 0, 0, {})


If !Empty(GTA->GTA_CODIND)

	DbSelectArea("GTB")
	DbGoTop()
	DbSetOrder(1)
	If DbSeek(xFilial("GTB") + GTA->GTA_CODIND)
		While !GTB->(Eof()) .AND. GTB->GTB_CODIND == GTA->GTA_CODIND
			//                       1                     2                  3                 4                     5               6
			AADD(aDadosIn, {Alltrim(GTB->GTB_NOME), GTB->GTB_CODITE, GTB->GTB_COMBO,FS_COLOR(GTB->GTB_COLOR),GTB->GTB_FORMAT,GTB->GTB_QUERY})
			GTB->(DbSkip())
		End	
	EndIf
Else
	Return(Nil)
EndIf

If Len(aDadosIn) == 1
	cQryGTA := FS_INDRQry(aDadosIn[1,6])	
	cQryGTA := ChangeQuery(cQryGTA)
	TCQUERY cQryGTA NEW ALIAS "TMPGTA" 
		
	If Select("TMPGTA") > 0   //Verifica a existencia da coluna descricao no Alias
		DbSelectArea("TMPGTA")
		aStruInd := DbStruct()
		If (nPosStru := aScan(aStruInd, {| aVet | aVet[1] == "DESCRICAO" })) == 0
			lDescr := .F.
		EndIf
	EndIf
		 
	If !TMPGTA->(Eof())
		If lDescr .AND. !Empty(Alltrim(TMPGTA->DESCRICAO))
			While !TMPGTA->(Eof())
				Aadd( aVetRet, {Alltrim(TMPGTA->CONTADOR) + IIf(GTA->GTA_APREVL == 1," %",""), Alltrim(TMPGTA->DESCRICAO),aDadosIn[1,4],Nil,Val(TMPGTA->CONTADOR) })
				TMPGTA->(DbSkip())
			End
		Else 
			Aadd( aVetRet, {Alltrim(TMPGTA->CONTADOR) + IIf(GTA->GTA_APREVL == 1," %",""), aDadosIn[1,1],aDadosIn[1,4],Nil,Val(TMPGTA->CONTADOR) })
		EndIf
	EndIf	
	TMPGTA->(DbCloseArea())		
Else
	For nJ := 1 to Len(aDadosIn)					
		cQryGTA := FS_INDRQry(aDadosIn[nJ,6])	
		cQryGTA := ChangeQuery(cQryGTA)
		TCQUERY cQryGTA NEW ALIAS "TMPGTA"
		
		Aadd( aVetRet, {Alltrim(Transform(TMPGTA->CONTADOR,"@E 999.99")) + IIf(GTA->GTA_APREVL == "1","%",""), aDadosIn[nJ,1],aDadosIn[nJ,4],Nil,TMPGTA->CONTADOR })
		
		TMPGTA->(DbCloseArea())	
	Next nJ
EndIf

aRet := { "",GTA->GTA_VALINI,GTA->GTA_VALFIM, aVetRet} 

//aRet2 := { "",GTA->GTA_VALINI,GTA->GTA_VALFIM, {{ 0,"teste1", CLR_BLUE,Nil ,1 } ,	{ 0,"teste2", CLR_RED,Nil ,1 } 	}} 

RestArea(aArea)


Return aRet   

Static Function FS_COLOR(cColor)

//0=Preto;1=Vermelho;2-Verde;3-Azul

If Alltrim(cColor) == "0"
	Return(CLR_BLACK)
ElseIf	Alltrim(cColor) == "1"
	Return(CLR_RED)
ElseIf	Alltrim(cColor) == "2"
	Return(CLR_GREEN)
ElseIf	Alltrim(cColor) == "3"
	Return(CLR_BLUE)
EndIf
		
Return(CLR_BLACK)

Static Function FS_INDRQry(cQuery)
 Local cStr := "", xValor, cQryAux := ""

 While (nPos1 := At("[", cQuery)) > 0
  If (nPos2 := At("]", cQuery)) > 0
  
   cStr   := Substr(cQuery, nPos1 + 1 , nPos2 - nPos1 - 1 )
   xValor := &(cStr)  
   
   If ValType(xValor) == "C"
    cQryAux := xValor
   ElseIf ValType(xValor) == "N"
    cQryAux := Str(xValor)
   ElseIf ValType(xValor) == "D"
    cQryAux := "'" + DtoS(xValor) + "'"
   Else
    cQryAux := "'" + xValor + "'"
   EndIf
  
   cQuery := StrTran(cQuery, "[" + cStr, cQryAux,,1)
   cQuery := StrTran(cQuery, "]", "",,1)
   
   xValor := Nil
  Else
   HS_MsgInf("Sintaxe incorreta", "Atenção","Análise")
   Exit
  EndIf
 End

Return(cQuery)

  