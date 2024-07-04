#include "Protheus.ch"
#include "Ofioa450.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OFIOA450  ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cadastro de pecas relacionados por modelo/servico           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³Autor    ³Descricao                                         ³±±
±±³          ³         ³                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias (SIGAPEC e SIGAOFI)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA450()

Local bCampo   := { |nCPO| Field(nCPO) } , _ni := 0 , nCntFor := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nOpc     := 3
Local cont

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private aSvAtela := {{},{}}
Private aSvAGets := {{},{}}
Private aTela    := {}
Private aGets    := {}
Private lRefresh := .f.
Private oGetMGet

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0001)
Private nOpcG:=nOpc
Private nOpcE:=nOpc
Private aCpoEnchoice :={}
Private nLenAcols    := 0


dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VZG")
aEnc := {}
While x3_arquivo == "VZG" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ [VZG_CODMAR/VZG_DESMAR/VZG_CODSER/VZG_DESSER]
		AADD(aEnc,x3_campo)
      wVar := "M->"+x3_campo
      &wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VSS")
aHeader:={}
While !Eof().And.(x3_arquivo=="VSS")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ "VSS_CODMAR/VSS_CODSER/VSS_SERMOD")
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
   Endif

   &("M->"+x3_campo) := CriaVar(x3_campo)
   
   dbSkip()
End

DbSelectArea("VSS")
DbSetOrder(1)
DbSeek(xFilial())

aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
    aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cAliasEnchoice:="VZG"
   cAliasGetD    :="VSS"
   cLinOk        :="AllwaysTrue()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="AllwaysTrue()"

   DEFINE MSDIALOG oDlg450 TITLE cTitulo From 9,0 to 28,80	of oMainWnd

	dbSelectArea("VZG")
	oGetMGet  := MsMGet():New("VZG",0,nOpcE,,,,aEnc,{015,002,072,314},,2,,,,oDlg450,,.T.,.F.,"aSvATela[1]")
   oGetMGet:oBox:bChange := {|| CarOA450() }
   oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
            
   ACTIVATE MSDIALOG oDlg450 ON INIT EnchoiceBar(oDlg450,{|| iIf(GrvOA450(),Limpa450(),.f.) },{|| oDlg450:End() })
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CarOA450  ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Carrega o relacionamento das pecas e servicos               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CarOA450()

Local _ni   

dbSelectArea("VO6")
dbSetOrder(2)
if dbSeek(xFilial("VO6")+M->VZG_CODMAR+M->VZG_CODSER)
   cSerMod := VO6->VO6_MODVEI+VO6->VO6_SEGMOD
   dbSelectArea("VZG")
 	dbSetOrder(1)
   if dbSeek(xFilial("VZG")+M->VZG_CODMAR+M->VZG_CODSER)
      cSerMod := VZG->VZG_SERIE
   Endif

	dbSelectArea("VSS")
	dbSetOrder(1)
	if dbSeek(xFilial("VSS")+M->VZG_CODMAR+M->VZG_CODSER+cSerMod)
	   While VSS->VSS_FILIAL == xFilial("VSS") .and. VSS->VSS_CODMAR+VSS_CODSER == M->VZG_CODMAR+M->VZG_CODSER .and. !eof()
         if !empty(aCols[1,1])
   	   	AADD(aCols,Array(nUsado+1))
   	   Endif	
	   	For _ni:=1 to nUsado
		   	aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	   	Next
			aCols[Len(aCols),nUsado+1]:=.F.
			M->VSS_GRUITE := VSS->VSS_GRUITE
			M->VSS_CODITE := VSS->VSS_CODITE
			CDPRO450(.f.)
			dbSkip()
		EndDo
		oGetDados:obrowse:Refresh()
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GrvOA450  ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Grava o relacionamento das pecas e servicos                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GrvOA450()

Local Cont            
Local lRet := .t.

if Empty(M->VZG_CODMAR)
   MsgInfo(STR0003,STR0002)
   lRet := .f.
Endif   

if lRet .and. Empty(M->VZG_CODSER)
   MsgInfo(STR0004,STR0002)
   lRet := .f.
Endif

if lRet
   dbSelectArea("VO6")
   dbSetOrder(2)
   if dbSeek(xFilial("VO6")+M->VZG_CODMAR+M->VZG_CODSER)
      cSerMod := VO6->VO6_MODVEI+VO6->VO6_SEGMOD
	   dbSelectArea("VZG")
   	dbSetOrder(1)
	   if dbSeek(xFilial("VZG")+M->VZG_CODMAR+M->VZG_CODSER)
         cSerMod := VZG->VZG_SERIE+Space(10)
      Endif

      dbSelectarea("VSS")
   	dbSetOrder(1)
   	For cont := 1 to Len(aCols)
		   lFound := dbSeek(xFilial("VSS")+M->VZG_CODMAR+M->VZG_CODSER+cSerMod+aCols[cont,1]+aCols[cont,2])
			if aCols[cont,Len(aCols[cont])] == .t.
			   if lFound
					if RecLock("VSS",.f.,.t.)
						VSS->(dbDelete())
						MsUnlock()
						WriteSx2("VSS")
					Endif	
				Endif	
   	   Else
   		   RecLock("VSS",!lFound)
   		   VSS->VSS_FILIAL := xFilial("VSS")
	   	   VSS->VSS_CODMAR := M->VZG_CODMAR
   		   VSS->VSS_CODSER := M->VZG_CODSER
   		   VSS->VSS_SERMOD := cSerMod
	   	   VSS->VSS_GRUITE := aCols[cont,1]
   		   VSS->VSS_CODITE := aCols[cont,2]
   		   VSS->VSS_QTDITE := aCols[cont,3]
      		MsUnlock()
      	Endif	
      Next
   Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias (SIGAPEC e SIGAOFI)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CDPRO450(lTela)

default lTela := .t.     

FG_MEMVAR()
dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("VSS")+M->VSS_GRUITE+M->VSS_CODITE)
	dbSelectArea("SBL")
	dbSetOrder(1)
	dbSeek(xFilial("SBL")+SB1->B1_COD)
	While !eof() .and. SBL->BL_PRODUTO == SB1->B1_COD
	   M->VSS_ABCITE := SBL->BL_ABCVEND+SBL->BL_ABCCUST
	   aCols[n,FG_POSVAR("VSS_ABCITE")] := M->VSS_ABCITE
	   dbSkip()
	Enddo   
Endif

if lTela
	//Carrega itens relacionados
	CARREL450()
Endif	

dbSelectArea("VSS")

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CARREL450 ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Carrega itens relacionados para selecao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CARREL450()

Local aRet := {}
Local cont, _ni

dbSelectArea("VPD")
dbSetOrder(1)
if dbSeek(xFilial("VPD")+SB1->B1_COD)
   SB1->(dbSetOrder(1))
	dbSelectArea("VPD")
   while !EOF() .and. VPD->VPD_COD == SB1->B1_COD
	   if SB1->(dbSeek(xFilial("SB1")+VPD->VPD_CODREL))
			Aadd(aRet,{.t.,SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC})
		Endif	
		dbSelectArea("VPD")
		dbSkip()
	EndDo
Endif	

if Len(aRet) > 0
   nOpca := 0
   DEFINE MSDIALOG oSel450 TITLE STR0005 From 9,0 to 23,60	of oMainWnd

		@ 014,001 LISTBOX oLbItem FIELDS HEADER  OemToAnsi(""),;
		OemToAnsi(STR0006),;
		OemToAnsi(STR0007),;
		OemToAnsi(STR0008);
		COLSIZES 10,30,80,120;
		SIZE 250,092 OF oSel450 ON DBLCLICK ((aRet[oLbItem:nAt,1] := !aRet[oLbItem:nAt,1]),oLbItem:Refresh()) PIXEL

		oLbItem:SetArray(aRet)
		oLbItem:bLine := { || { If(aRet[oLbItem:nAt,1],oOk,oNo) ,;
		aRet[oLbItem:nAt,2] ,;
		aRet[oLbItem:nAt,3] ,;
		aRet[oLbItem:nAt,4] }}
            
   ACTIVATE MSDIALOG oSel450 ON INIT EnchoiceBar(oSel450,{|| nOpca := 1, oSel450:End() },{|| nOpca := 2, oSel450:End() })
   
   if nOpca == 1
      For cont := 1 to Len(aRet)
         if aRet[cont,1]
          
			   dbSelectArea("VO6")
			   dbSetOrder(2)
			   if dbSeek(xFilial("VO6")+M->VZG_CODMAR+M->VZG_CODSER)
			      cSerMod := VO6->VO6_MODVEI+VO6->VO6_SEGMOD
				   dbSelectArea("VZG")
		   		dbSetOrder(1)
				   if dbSeek(xFilial("VZG")+M->VZG_CODMAR+M->VZG_CODSER)
			         cSerMod := VZG->VZG_SERIE
			      Endif
			      dbSelectarea("VSS")
			   	dbSetOrder(1)
				   lFound := dbSeek(xFilial("VSS")+M->VZG_CODMAR+M->VZG_CODSER+cSerMod+aRet[cont,2]+aRet[cont,3])
		   	   RecLock("VSS",!lFound)
		   	   VSS->VSS_FILIAL := xFilial("VSS")
		   	   VSS->VSS_CODMAR := M->VZG_CODMAR
		   	   VSS->VSS_CODSER := M->VZG_CODSER
   			   VSS->VSS_SERMOD := cSerMod
		   	   VSS->VSS_GRUITE := aRet[cont,2]
   			   VSS->VSS_CODITE := aRet[cont,3]
		   	   VSS->VSS_QTDITE := 1
		      	MsUnlock()
		      	
	   	   	AADD(aCols,Array(nUsado+1))
			   	For _ni:=1 to nUsado
				   	aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			   	Next
					aCols[Len(aCols),nUsado+1]:=.F.
	      	
		      Endif	
		   Endif

      Next
		oGetDados:obrowse:Refresh()
   Endif
Endif

Return(aRet)
              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Limpa450  ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Limpa as variaveis                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Limpa450()

Local _ni

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VZG")
While !Eof().And.(x3_arquivo=="VZG")
   &("M->"+x3_campo) := CriaVar(x3_campo)
   dbSkip()
EndDo

dbSelectArea("SX3")
dbSeek("VSS")
While !Eof().And.(x3_arquivo=="VSS")
   &("M->"+x3_campo) := CriaVar(x3_campo)
   dbSkip()
EndDo

DbSelectArea("VSS")
DbSetOrder(1)
DbSeek(xFilial())

aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
    aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next
    
oGetDados:obrowse:Refresh()
oGetMGet:aEntryCtrls[1]:SetFocus()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Andre                 ³ Data ³ 02/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias (SIGAPEC e SIGAOFI)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { "" ,"axPesqui", 0 , 1},;    //Pesquisar
                     { "" ,"OA450", 0 , 2} ,;    //Visualizar
                     { "" ,"OA450", 0 , 3} ,;    //Incluir
                     { "" ,"OA450", 0 , 4} ,;    //Alterar
                     { "" ,"OA450", 0 , 5} }     //Excluir
Return aRotina
