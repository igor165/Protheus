#INCLUDE "ofiia390.ch"                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA390 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exporta Catalogo GM                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA390()
	If MsgYesNo(STR0002,STR0001)//Deseja iniciar a geracao do Catalogo ? # Atencao
		Processa( {|| FS_IIA390() })
	EndIf
Return

Function FS_IIA390()
Local cStr := ""
Local nTotReg := 2
Local ni := 0
Outputfile := FCREATE("EDI\EXPORTA\PRECOS.TXT",0)
DbSelectArea("SB2")
DbSetOrder(1)
DbSelectArea("VE4")
DbSetOrder(1)
DbSeek( xFilial("VE4")+left(FG_MARCA("CHEVROLET",,.f.)+space(3),3))
cStr := "00"+STRZERO(YEAR(DDATABASE),4)+STRZERO(MONTH(DDATABASE),2)+STRZERO(DAY(DDATABASE),2)
cStr += SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)+"MICROSIGA "+"MP8.11    "
cStr += "PROTHEUS 8"+SPACE(20)+"MICROSIGA SOFTWARE S/A"+SPACE(28)+"017-21369792"+SPACE(8)
fwrite(outputfile,cStr+CHR(13)+CHR(10))
DbSelectArea("SB1")
DbSetOrder(7)
DbSeek( xFilial("SB1") + VE4->VE4_GRUITE )
ProcRegua((SB1->(RecCount())/1000))
Do While !Eof() .and. SB1->B1_FILIAL == xFilial("SB1") .and. SB1->B1_GRUPO == VE4->VE4_GRUITE
	ni++
	If ni == 1000
		IncProc(STR0003) //Gerando Catalogo...
		ni := 0
	EndIf
	If len(Alltrim(SB1->B1_CODITE)) == VE4->VE4_TAMCOD
		nTotReg++
		DbSelectArea("SB2")
		DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
		cStr := "01"+left(SB1->B1_CODITE,10)+strzero(int(SB2->B2_QATU),7)+strzero((SB1->B1_PRV1*100),9)+SB1->B1_GRUDES
		fwrite(outputfile,cStr+CHR(13)+CHR(10))
	EndIf
	dbselectArea("SB1")
	dbskip()                                        
EndDo
cStr := "99"+STRZERO((nTotReg),10)
fwrite(outputfile,cStr+CHR(13)+CHR(10))
FClose(outputfile)
Return()
