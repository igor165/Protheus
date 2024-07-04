#Include "protheus.ch"
#Include "OFIIC000.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIIC000  ºAutor  ³Fabio               º Data ³  07/17/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta pedido de peca na montadora                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIC000()

Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0003) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VIE")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"VIE")
                                                    
Return                  

Function IC000(cAlias,nReg,nOpc)
         
Local nUsado:=0 , _ni := 0 , aArea := {}
Local nPosRec := 0
Private aCols := {} , aHeader := {} , cCodMar := VIE->VIE_CODMAR , cCodPedido := VIE->VIE_NPEDDN
                                        
aArea := sGetArea(aArea , Alias())
      
nOpcE := 2
nOpcG := 2
                                                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VIE")
aHeader:={}
While !Eof().And.(x3_arquivo=="VIE")
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	dbSkip()
End               

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VIE")
ADHeadRec("VIE",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VIE")
dbSetOrder(2)
dbSeek(xFilial()+cCodMar+cCodPedido)

aCols:={}
While !eof() .And. VIE->VIE_FILIAL+VIE->VIE_CODMAR+VIE->VIE_NPEDDN == xFilial("VIE")+cCodMar+cCodPedido
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := VIE->(RecNo())
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VIE"
		Else
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		EndIf	
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
End

If Len(aCols) == 0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VIE"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
EndIf

cAliasGetD    :="VIE"
cLinOk        :="AllwaysTrue()"
cFieldOk      :="FG_MEMVAR()"
cTudOk		  :="AllwaysTrue()"

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 to 28,80	of oMainWnd

	@ 020,010 SAY STR0004 OF oDlg   PIXEL COLOR CLR_BLUE 
	@ 020,050 MSGET oPedido VAR cCodPedido PICTURE "@!" OF oDlg PIXEL COLOR CLR_BLACK When .f.

   oGetDados := MsGetDados():New(40,1,143,315,nOpcG,cLinOK,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 0,oDlg:End()})
      
sRestArea(aArea)

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;    //"Pesquisar"
                 { STR0002,"IC000",0,2}}
Return aRotina
