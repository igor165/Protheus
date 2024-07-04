#INCLUDE "ACDV180.ch" 
#include "protheus.ch"
#include "apvt100.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ACDV180   ³ Autor ³ Sandro                ³ Data ³ 23/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao da caixa de entrada                           ³±±
±±³          ³ Mensagens Recebidas                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/       
Function ACDV180()
Local aTela:= VtSave()
Local aFields := {"CBF_DE","CBF_DATA","CBF_HORA","CBF_MSG","CBF_ROTINA","CBF_PENDEN"}
Local aSize   := {6,8,8,20,20,12}
Local aHeader := {STR0002,STR0003,STR0004,STR0005,STR0007,STR0008} //"De"###"Data"###"Hora"###"Assunto"###"Rotina"###"Pendencia"
Local cCodOpe := CBRetOpe()
Local cTop,cBottom
Local nRecno   
Local cRotMsg:=''

CBF->(dbSetOrder(3))
If CBF->(dbSeek(xFilial("CBF")+cCodOpe))
	nRecno := CBF->(Recno())
	ctop:="xfilial('CBF')+CB1->CB1_CODOPE"
	cBottom:="xfilial('CBF')+CB1->CB1_CODOPE"
	While .t.
		VtClear()
		If VTModelo()=="RF"
			@ 0,0 VTSay STR0001 //"Recebidas"
			nRecno := VTDBBrowse(1,0,VTMaxRow(),VTMaxCol(),"CBF",aHeader,aFields,aSize,,cTop,cBottom)
		Else
			nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxCol(),"CBF",aHeader,aFields,aSize,,cTop,cBottom)
		EndIf
		If VtLastkey() == 27
			Exit
		EndIf
		CBF->(RecLock("CBF"))
		CBF->CBF_STATUS:= '2'
		CBF->(MsUnlock())
		VtAlert(CBF->CBF_MSG,STR0006+CBF->CBF_DE,.T.) //"DE:"    
		If ! Empty(CBF->CBF_ROTINA) .AND. VtYesNo(STR0009,STR0010,.t.)//###"Deseja executar a tarefa agora?"###"Mensagem"
		 
			If ! Empty(CBF->CBF_KEYB)
				VTKeyBoard(Alltrim(CBF->CBF_KEYB))
			EndIf 
			cRotMsg := Alltrim(CBF->CBF_ROTINA) 
			cRotMsg +=If(Empty(at("(",cRotMsg)),"()","")
			VTAtuSem("SIGAACD",cRotMsg+" - ["+Alltrim(CBF->CBF_MSG)+']') //##"SIGAACD"
			If !(FindFunction(Alltrim(cRotMsg)))
			     VTAlert(STR0011+cRotMsG+STR0012,STR0013,.t.,4000) //##"Função"##" Não existe! Verifique o Controle de Tarefas"##"Atencao"
			     Exit
			Else     
				&(Alltrim(cRotMsg))                                             
			EndIf
			VTAtuSem("SIGAACD","")   
			CBF->(RecLock("CBF"))
			CBF->CBF_PENDEN:= ' '
			CBF->(MsUnlock())	
		EndIf
	End
EndIf
VTRestore(,,,,aTela)
Return
