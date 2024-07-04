#INCLUDE "ACDV200.ch" 
#include "protheus.ch"
#include "apvt100.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ACDV200   ³ Autor ³ Sandro                ³ Data ³ 23/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao da caixa de entrada                           ³±±
±±³          ³ Novas Mensagens                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function ACDV200(xCodOpe)     
Local aTela:= VtSave()                
Local cCodOpe := Space(6)
Local cConteudo:= Space(100)
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If xCodOpe<>NIL       
	cCodOpe := xCodOpe
	VtKeyBoard(chr(13))
EndIf
While .t.
	vtclear()
	If VTModelo()=="RF" .and. !lVT100B //lVT100B = terminal 4 linhas por 20 colunas             
		@ 0,0 VTSay STR0001 //"Nova Mensagem"
		@ 1,0 VTSay STR0002  //"Para "
		@ 2,0 VTGet cCodOpe Pict "@!" F3 "CB1" Valid VldOpe(cCodOpe)
		@ 3,0 VTSay STR0003 //"Conteudo"
		@ 4,0 VTGet cConteudo Pict "@!"
		VtRead
	Else
		@ 0,0 VTSay STR0001 //"Nova Mensagem"
		@ 1,0 VTSay STR0002 VTGet cCodOpe Pict "@!" F3 "CB1" Valid VldOpe(cCodOpe) //"Para "
		VTRead     
		If VtLastKey() == 27
		   Exit
		EndIf  	
		VTClear()
		@ 0,0 VTSay STR0003 //"Conteudo"
		@ 1,0 VTGet cConteudo Pict "@!"
		VtRead	
	EndIf
	If VtLastKey() == 27
	   Exit
	EndIf  
	If VTYesNo(STR0004,STR0005,.t.) //"Confirma o envio desta mensagem"###"Aviso"
		CBSendMsg(cCodOpe,cConteudo)
		cCodOpe := Space(6)
		cConteudo:= Space(100)
	EndIf
	If xCodOpe<>NIL
	   Exit
	EndIf   
End
VTRestore(,,,,aTela)
Return                                          

Static Function VldOpe(cCodOpe)
If Empty(cCodOpe)
   VTKeyBoard(chr(23))
   Return .f.
EndIF
CB1->(DbSetOrder(1))
If ! CB1->(DBSeek(xFilial()+cCodOpe))
   VTAlert(STR0006, STR0005,.t.,3000,2) //"Operador nao cadastrado"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
Return .t.
 
