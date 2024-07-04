#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ AP6 IDE            º Data ³  06/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AGRAX03R()
Private cCadastro := "Alterar Pedidos nos Apontamentos"
Private aRotina   := { {"Pesquisar" ,"AxPesqui" ,0,1} ,;
                       {"Visualizar","AxVisual" ,0,2} ,;
                       {"Incluir"   ,""         ,0,3} ,;
                       {"Alterar"   ,"U_AGRX03R",0,4} ,;
                       {"Excluir"   ,""         ,0,5} }
Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

dbSelectArea("NPA")
dbSetOrder(1)

mBrowse( 6,1,22,75,"NPA")

Return()

User Function AGRX03R()
Local oDlg,oSay1,oGet1,oSay2,oGet2,oSBtn1,oSBtn2
Local cNumPed := IIf(Len(NPA->NPA_PVNUM)<6,Space(6),NPA->NPA_PVNUM)
Local cNumNF  := IIf(Len(NPA->NPA_NFSNUM)<6,Space(6),NPA->NPA_NFSNUM)
Local nOpc := 0

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := "Alterar Pedidos nos Apontamentos"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 290
oDlg:nHeight := 219
oDlg:lShowHint := .F.
oDlg:lCentered := .F.

oSay1 := TSAY():Create(oDlg)
oSay1:cName := "oSay1"
oSay1:cCaption := "Pedido"
oSay1:nLeft := 14
oSay1:nTop := 19
oSay1:nWidth := 65
oSay1:nHeight := 17
oSay1:lShowHint := .F.
oSay1:lReadOnly := .F.
oSay1:Align := 0
oSay1:lVisibleControl := .T.
oSay1:lWordWrap := .F.
oSay1:lTransparent := .F.

oGet1 := TGET():Create(oDlg)
oGet1:cName := "oGet1"
oGet1:nLeft := 85
oGet1:nTop := 16
oGet1:nWidth := 121
oGet1:nHeight := 21
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := "cNumPed"
oGet1:bSetGet := {|u| If(PCount()>0,cNumPed:=u,cNumPed) }
oGet1:lVisibleControl := .T.
oGet1:lPassword := .F.
oGet1:lHasButton := .F.

oSay2 := TSAY():Create(oDlg)
oSay2:cName := "oSay2"
oSay2:cCaption := "Nota Fiscal"
oSay2:nLeft := 14
oSay2:nTop := 39
oSay2:nWidth := 65
oSay2:nHeight := 17
oSay2:lShowHint := .F.
oSay2:lReadOnly := .F.
oSay2:Align := 0
oSay2:lVisibleControl := .T.
oSay2:lWordWrap := .F.
oSay2:lTransparent := .F.

oGet2 := TGET():Create(oDlg)
oGet2:cName := "oGet2"
oGet2:nLeft := 85
oGet2:nTop := 39
oGet2:nWidth := 121
oGet2:nHeight := 21
oGet2:lShowHint := .F.
oGet2:lReadOnly := .F.
oGet2:Align := 0
oGet2:cVariable := "cNumNF"
oGet2:bSetGet := {|u| If(PCount()>0,cNumNF:=u,cNumNF) }
oGet2:lVisibleControl := .T.
oGet2:lPassword := .F.
oGet2:lHasButton := .F.

oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "Confirmar"
oSBtn1:nLeft := 136
oSBtn1:nTop := 142
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 1
oSBtn1:bAction := {|| oDlg:End(), nOpc := 1 }

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "Cancelar"
oSBtn2:nLeft := 201
oSBtn2:nTop := 142
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 2
oSBtn2:bAction := {|| oDlg:End(), nOpc := 0 }

oDlg:Activate()

If nOpc = 1

	If RecLock("NPA",.f.)
		NPA->NPA_PVNUM := cNumPed
		NPA->NPA_NFSNUM := cNumNF
		msUnLock()
	EndIf

EndIf

Return()

