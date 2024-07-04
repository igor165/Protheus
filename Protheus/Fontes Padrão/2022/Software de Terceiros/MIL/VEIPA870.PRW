#include "Veipa870.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ VEIPA870 ³ Autor ³  Andre                ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controle dos Processos da Contemplacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos - VIP                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPA870

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006)   // Controle dos Processos da Contemplacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP9")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CPC870   ³ Autor ³  Andre                ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Controle dos Processos da Contemplacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos - VIP                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPC870(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Private nOpcx := nOpc
Private aTELA:=Array(0,0) , aGets:=Array(0) , aCpoEnchoice  :={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VP9",Inclui)

if nOpc == 3
	nOpcE := 3
	nOpcG := 3
elseif nOpc == 4
	nOpcE := 4
	nOpcG := 4
elseif nOpc == 5
	nOpcE := 2
	nOpcG := 5
else
	nOpcE := 2
	nOpcG := 2
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VPA")
aHeader:={}
While !Eof().And.(x3_arquivo=="VPA")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VPA_CODGRU/VPA_NUMCOT])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		Private &wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
End

dbSelectArea("VPA")
dbSetOrder(1)
dbSeek(xFilial("VPA")+M->VP9_CODGRU+M->VP9_NUMCOT)
aCols:={}
While !eof() .And. VPA->VPA_FILIAL == xFilial("VPA") .and. VPA->VPA_CODGRU+VPA->VPA_NUMCOT == M->VP9_CODGRU+M->VP9_NUMCOT
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
End
If nOpc == 3 .or. Len(aCols) == 0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo       :=STR0006 
cAliasEnchoice:="VP9"
cAliasGetD    :="VPA"
cLinOk        :="VP870LINOK()"
cTudOk        :="FS_VALOK(nOpcx)"
cFieldOk      :="FG_MEMVAR()"
aCpoEnchoice  :={}

dbSelectArea("SX3")
dbSeek("VP9")
While !Eof().and.(x3_arquivo=="VP9")
	if X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	if Inclui
		wVar := "M->"+x3_campo
		Private &wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
End
dbSelectArea("VP9")

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
EnChoice("VP9", nReg, nOpcE, , , ,aCpoEnchoice,{012,002,080,318})
oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudOk,"",.T.,,,,99,cFieldOk)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk(),oDlg:End(),.t.) },{||oDlg:End()})

if nOpc == 5
	FS_VALOK(nOpc)
Endif

Return


////////////////////////
Function FS_VALOK(nOpc)

Local lRet := .t.
Local nwnk 
Local i := 0

For nwnk := 1 To Len(aCols)
	If !VP870LINOK(nwnk)
		Return .F.
	Endif	
Next
// Coloca os deletados primeiro para fazer as inclusoes depois
Asort(aCols,,,{|x,y| x[len(x)] > y[len(y)] })
Begin Transaction

DbSelectArea("VP9")                                   

RecLock("VP9",If(Inclui,.t.,.f.))
FG_GRAVAR("VP9")
VP9_FILIAL := xFilial("VP9")
VP9_CODGRU := M->VP9_CODGRU
VP9_NUMCOT := M->VP9_NUMCOT
MsUnlock()

&& Grava arquivo filho

For i:=1 to len(aCols)
	
	If nOpc == 3 .or. nOpc == 4

		DbSelectArea("VPA")
		lKey := DbSeek(xFilial("VPA")+M->VP9_CODGRU+M->VP9_NUMCOT+aCols[i,FG_POSVAR("VPA_CODDOC","aHeader")])

		if aCols[i,Len(aCols[i])] .and. lKey
			RecLock("VPA",.F.)
			dbdelete()
			MsUnlock()
			WriteSx2("VPA")
		Else
			If aCols[i,Len(aCols[i])]
				Loop
			Endif	
   		RecLock("VPA",!lKey)
	   	FG_GRAVAR("VPA",aCols,aHeader,i)
   		VPA->VPA_FILIAL := xFilial("VPA")
	   	VPA->VPA_CODGRU := M->VP9_CODGRU
   		VPA->VPA_NUMCOT := M->VP9_NUMCOT
	   	MsUnlock()
	   Endif	
		
	Elseif nOpc == 5
		
		DbSelectArea("VPA")
		If DbSeek(xFilial("VPA")+VP9->VP9_CODGRU+VP9->VP9_NUMCOT)
			While !EOF() .and. (VPA->VPA_CODGRU+VPA->VPA_NUMCOT == VP9->VP9_CODGRU+VP9->VP9_NUMCOT)
				If !RecLock("VPA",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				dbdelete()
				MsUnlock()
				WriteSx2("VPA")
				
				DbSkip()
			Enddo
		EndIf
		RecLock("VP9",.f.,.t.)
		DbDelete()
		MsUnlock()
		WriteSx2("VP9")
		
	Endif
	
Next

End Transaction

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLDDOC ºAutor  ³Andre Luis          º Data ³  21/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o documento foi duplicado na getdados          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina / Veiculos / Pecas                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLDDOC()

Local ix1     := 0
Local ix2     := 0

FG_MEMVAR()

For ix1 := 1 to len(aCols)
	
	If aCols[ix1,nUsado+1]
		loop
	EndIf
	If aCols[ix1,FG_POSVAR("VPA_CODDOC")] == M->VPA_CODDOC
		ix2 ++
		If ix2 > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VP870LINOK        ³Ricardo Farinelli   º Data ³  11/26/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validacao da GetDados                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VP870LINOK(nx)
Local nPosCod := FG_POSVAR("VPA_CODDOC")
Local nwnk

Default nx := n
n := nx

If nOpcX == 2 .or. nOpcX == 5 .or. aCols[nx,Len(aCols[nx])]
	Return (.T.)
Endif	

For nwnk := 1  To Len(aCols)
	If aCols[nwnk,Len(aCols[nwnk])]
		Loop
	Endif
	If aCols[nwnk,nPosCod] == aCols[n,nPosCod] .and. nwnk <> n .and. !aCols[n,Len(aCols[n])]
		Help(" ",1,"EXISTCHAV")
		Return .F.
	Endif
	If !FG_OBRIGAT()
		Return .F.
	Endif	
Next

Return .T.

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0, 1},;     	//Pesquisar
						{ STR0002 ,"CPC870"  , 0, 2},;  //Visualizar
						{ STR0003 ,"CPC870"  , 0, 3},;  //Incluir
						{ STR0004 ,"CPC870"  , 0, 4},;  //Alterar
						{ STR0005 ,"CPC870"  , 0, 5} }  //Excluir
Return aRotina
