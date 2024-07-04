#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "msgraphi.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HSPPO020  ³ Autor ³ Rogerio Tabosa        ³ Data ³ 14/05/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array para Painel de Gestao Tipo Grafico e barra        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³HSPPO020()                                                    ³±±
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

 Function HSPPO020(nCodInd, lImpressao)

Local aArea		:= GetArea()
Local aRet		:= {} 

Local cQryGTA	:= ""
Local aEixoX	:= {}
Local aValores	:= {}
Local aImpresao	:= {}
Local nJ,nCor	:= 0 
Local aDadosIn	:= {} 
Local aStruInd	:= {}
Local nPosStru	:= 0
Local lDescr	:= .T. 
Local aCores	:= {CLR_HBLUE,CLR_CYAN,CLR_MAGENTA,CLR_HGREEN,CLR_HRED,CLR_BLACK,CLR_BROWN,CLR_YELLOW,CLR_GRAY}
Local lImpHelp	:= .F.
Local lUniCor	:= .F.
Local nUniCor	:= 0
Local nTipGraf	:= 0 
Local nMais		:= 0
Local nMenos	:= 0

Private cAno		:= Substr(DTOC(dDataBase),7,4)
Private cMes		:= StrZero(Month(dDataBase),2)
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

Private nAteCancM	:= 0
Private nAteCancD	:= 0
Private nAteCancA	:= 0


Default nCodInd 	:= 1  
Default lImpressao  := .F.

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', nCodInd , 0, 0, {})

If lImpressao
	If !Pergunte("HSPGON",.T.)
		return
	endif

	lUniCor		:= (MV_PAR01 == 2)
	lImpHelp 	:= (MV_PAR04 == 2)
	If lUniCor
		nUniCor := IIf(MV_PAR02 == 1, CLR_RED,IIf(MV_PAR02 == 2, CLR_GREEN,IIf(MV_PAR02 == 3, CLR_HBLUE,CLR_YELLOW)))
		nMais  := IIf(MV_PAR02 == 1, 50,IIf(MV_PAR02 == 2, 60,IIf(MV_PAR02 == 3, 0,0)))		
		nMenos := IIf(MV_PAR02 == 1, 0,IIf(MV_PAR02 == 2, 0,IIf(MV_PAR02 == 3, 65,40)))				
	EndIf	
	nTipGraf := IIf(MV_PAR03 == 1,GRP_PIE,GRP_BAR)
EndIf

DbSelectArea("GTA")
DbGoTop()
DbGoTo(nCodInd)

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
				nCor ++ 
				If nCor > Len(aCores)
					nCor := 1
				EndIf
				Aadd( aEixoX, TMPGTA->DESCRICAO )
				Aadd( aValores, If(TMPGTA->(Eof()),0,TMPGTA->CONTADOR) )
				Aadd( aImpresao, {Alltrim(TMPGTA->DESCRICAO),If(TMPGTA->(Eof()),0,TMPGTA->CONTADOR),IIf( lUniCor,nUniCor ,aCores[nCor])})				
				TMPGTA->(DbSkip())
				nUniCor += nMais
				nUniCor -= nMenos
			End                                              
		Else                                                 
			Aadd( aEixoX, aDadosIn[1,1] )
			Aadd( aValores, If(TMPGTA->(Eof()),0,TMPGTA->CONTADOR) )
			Aadd( aImpresao, {aDadosIn[1,1],If(TMPGTA->(Eof()),0,TMPGTA->CONTADOR),aCores[1]})							
		EndIf
	EndIf	
	TMPGTA->(DbCloseArea())		
Else
	For nJ := 1 to Len(aDadosIn)
		nCor ++ 
		If nCor > Len(aCores)
			nCor := 1
		EndIf					
		cQryGTA := FS_INDRQry(aDadosIn[nJ,6])	
		cQryGTA := ChangeQuery(cQryGTA)
		TCQUERY cQryGTA NEW ALIAS "TMPGTA"
		
		Aadd( aEixoX, aDadosIn[nJ,1] )
		Aadd( aValores, If(TMPGTA->(Eof()),0,TMPGTA->CONTADOR) )
		Aadd( aImpresao, {aDadosIn[nJ,1],If(TMPGTA->(Eof()),0,TMPGTA->CONTADOR),IIf( lUniCor,nUniCor ,aCores[nCor])})
		nUniCor += nMais
		nUniCor -= nMenos
		TMPGTA->(DbCloseArea())	
	Next nJ
EndIf

aRet := 	{IIf(GTA->GTA_TIPOIN=="2",GRP_PIE,GRP_BAR),;
				{},;
				{aEixoX},;
				{""},;
				{aValores},;
				"",""}

If lImpressao
	HS_Grphpg(GTA->GTA_TITULO, aImpresao, IIf(nTipGraf == 0, IIf(GTA->GTA_TIPOIN=="2",GRP_PIE,GRP_BAR),nTipGraf),IIf(lImpHelp,"Objetivo: " + Alltrim(GTA->GTA_HELPIN),""))
EndIf	

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |FS_INDRQry³ Autor ³ Rogerio Tabosa        ³ Data ³ 14/04/2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validade Sintaxe da query criada pelo usuário                 ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
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


                   