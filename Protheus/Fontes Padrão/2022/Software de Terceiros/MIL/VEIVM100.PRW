#Include "Protheus.ch"
#Include "VEIVM100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM100 ³ Autor ³  Manoel               ³ Data ³ 29/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza Itens de Campanha / Despesas do Veiculo Faturado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM100

Local bCampo  := { |nCPO| Field(nCPO) }
Local i, nCntFor, _ni
Local cQuery  := ""
Local cQAlVV0 := "SQLVV0" // VV0
Local cVVDUso	:= ""
Private aRotina := {{},{},{},{},{}}
Private cTipAva  := "1"   //Veiculos
Private cCpoDiv  := "    1"
Private cCadastro  := OemToAnsi(STR0001) //Atualiza Itens de Campanha / Despesas do Veiculo

M->VVD_TIPOPE := "0"

nDespes1 := 0
nDespes  := 0
nIteCam  := 0

Private aNewBot := {}
aadd(aNewBot,{"HISTORIC" ,"FS_AtuVZ7()",STR0002}) //Atualiza Itens de Campanha
aadd(aNewBot,{"LJPRECO" ,"FS_AtuVVD()" ,STR0003}) //Atualiza Despesas
For i:=1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next

if 1 == 2
	FS_AtuVZ7()
	FS_AtuVVD()
Endif

dbSelectArea("VV0")
Inclui := .f.

aRotina := {  {"","" , 0 , 1},;   	  // Pesquisar
	{"","", 0 , 2} ,; // Consultar
	{"","", 0 , 3} ,; // Incluir
	{"","", 0 , 4 },; // Alterar
	{"","", 0 , 5 } } // Excluir


nOpcE := 4
nOpcG := 4

Aheader := {}
nUsado:=0

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_MODVDA")
While !Eof().and.(x3_campo=="VV0_MODVDA")
	nUsado:=nUsado+1
	Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!",;
	x3_tamanho, x3_decimal,x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VVA_CHASSI")
While !Eof().and.(x3_campo=="VVA_CHASSI")
	nUsado:=nUsado+1
	Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!S19",;
	x3_tamanho, x3_decimal,x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VV0")
While !Eof().and.(x3_arquivo=="VV0")
	if Alltrim(x3_campo) $ "VV0_DATEMI#VV0_DATMOV#VV0_VALMOV"
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
	Endif
	DbSkip()
EndDo

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VV0_NUMTRA")
While !Eof().and.(x3_campo=="VV0_NUMTRA")
	nUsado:=nUsado+1
	Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!S10",;
	x3_tamanho, x3_decimal,x3_valid,;
	x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
	DbSkip()
EndDo

RegToMemory("VV0",.f.)
DbSelectArea("VV0")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

acols:={}
//DbSelectArea("VV0")
//DbSetOrder(2)
//DbSeek(xFilial("VV0")+"0")
//While !eof() .and. VV0->VV0_FILIAL == xFilial("VV0") .and. VV0->VV0_OPEMOV == "0"
//	If VV0->VV0_SITNFI == "1"

cPerg := "VVM100"
ValidPerg()
PERGUNTE(cPerg,.T.)



cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA, VV0.VV0_DATMOV FROM "+RetSqlName("VV0")+" VV0 WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_OPEMOV='0' AND VV0.VV0_SITNFI='1' "
cQuery += " AND VV0.VV0_DATMOV >='"+dtos(mv_par01)+"' AND VV0.VV0_DATMOV <= '"+dtos(mv_par02)+"' AND VV0.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0 , .F., .T. )
While !( cQAlVV0 )->( Eof() )
	
	////////////////////////////////////////////////
	DbSelectArea("VV0")
	DbSetOrder(1)
	DbSeek( ( cQAlVV0 )->( VV0_FILIAL ) + ( cQAlVV0 )->( VV0_NUMTRA ) )
	DbSelectArea("VVA")
	DbSetOrder(1)
	DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	AADD(acols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If _ni == 1 .or. _ni > 2
			DbSelectArea("VV0")
		Else
			DbSelectArea("VVA")
		Endif
		acols[Len(acols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
	Next
	acols[Len(acols),nUsado+1]:=.F.
	////////////////////////////////////////////////
	
	( cQAlVV0 )->( DbSkip() )
EndDo
( cQAlVV0 )->( dbCloseArea() )

//	Endif
//	dbSkip()
//Enddo

DbSelectArea("VV0")
DbSetOrder(2)

If Len(aCols) == 0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Endif

cTitulo    := OemToAnsi(STR0001) //Atualiza Itens de Campanha / Despesas do Veiculo
cAliasEnch := "VV0"
cLinOk     := "allwaysTrue()"
cTudoOk    := "AllwaysTrue()"
cFieldOk   := "allwaysTrue()"

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcG := If(nOpcG==Nil,3,nOpcG)
nOpca := 0
lVirtual := .f.
nLinhas:= 99
Inclui := .f.
Altera := .t.

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,98	of oMainWnd
oGetDados:= MsGetDados():New(15,1,143,386,nOpcG,cLinOk,cTudoOk,"",.T.,{},,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{||  oDlg:End()},{|| oDlg:End()},,aNewBot) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_AtuVVD ³ Autor ³  Manoel               ³ Data ³ 29/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Tela da Atualizacao das Despesas                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AtuVVD()

Local bCampo        := { |nCPO| Field(nCPO) }
Local lRet, nOpca6  := 0,cSaveMenuh,oDlg
Local nLin := 001
Local nCntFor,_ni

nOpcE   := 2
nOpcG   := 3
nOpcEs  := nOpcE
nOpcGs  := nOpcG

M->VV0_NUMTRA := aCols[n,FG_POSVAR("VV0_NUMTRA","aHeader")]
DbSelectArea("VV0")
DbSetOrder(1)
DbSeek(xFilial("VV0")+M->VV0_NUMTRA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados dos Eqptos Instalados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VVA")
DbSetOrder(1)
DbSeek(xFilial("VVA")+M->VV0_NUMTRA)

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)

DbSelectArea("VV1")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

nUsadoEq:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVD")
aHeaderEq:={}
While !Eof().And.(x3_arquivo=="VVD")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(x3_campo) $ [VVD_CHAINT/VVD_TRACPA/VVD_CODCLI/VVD_LOJACL/VVD_NOMCLI/VVD_TIPOPE]) .or. Alltrim(x3_campo) == "VVD_LOJA"
		nUsadoEq:=nUsadoEq+1
		Aadd(aHeaderEq,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		//      if inclui
		wVar  := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
		//      Endif
	Endif
	
	dbSkip()
End

aColsEq:={}
nDespes1 := 0
dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
		AADD(aColsEq,Array(nUsadoEq+1))
		For _ni:=1 to nUsadoEq
			aColsEq[Len(aColsEq),_ni]:=If(aHeaderEq[_ni,10] # "V",FieldGet(FieldPos(aHeaderEq[_ni,2])),CriaVar(aHeaderEq[_ni,2]))
		Next
		nDespes1 += VVD->VVD_VALOR
		aColsEq[Len(aColsEq),nUsadoEq+1]:=.F.
		dbSelectArea("VVD")
		dbSkip()
	Enddo
Endif

If Len(aColsEq) == 0
	aColsEq:={Array(nUsadoEq+1)}
	aColsEq[1,nUsadoEq+1]:=.F.
	For _ni:=1 to nUsadoEq
		aColsEq[1,_ni]:=CriaVar(aHeaderEq[_ni,2])
	Next
Endif

cAliasGetD6 := "VVD"
cAlias2     := "VVD"


dbSelectArea("VVD")
dbSetOrder(1)

If Len(aColsEq)>0
	
	nOpcaC := 0
	DEFINE MSDIALOG oDlgC TITLE cTitulo From 9,0 to 28,98	of oMainWnd
	nc          := 1
	nLinhas     := 99
	aHeaderSv   := aClone(aHeader)
	aHeader     := aClone(aHeaderEQ)
	aColsSv      := aClone(aCols)
	aCols       := aClone(aColsEQ)
	
	
	oGetCondicao:= MsGetDados():New(10,001,143,386,4,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,99,"AllwaysTrue()",,,,oDlgC)
	oGetCondicao:oBrowse:default()
	ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC,{||nOpcaC:=1,Fs_GravaDE(),oDlgC:End()},{||oDlgC:End()})
	
	aCols := aClone(aColsSv)
	aHeader := aClone(aHeaderSv)
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_AtuVZ7 ³ Autor ³  Manoel               ³ Data ³ 29/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Tela da Atualizacao das Campanhas                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AtuVZ7()

Local bCampo        := { |nCPO| Field(nCPO) }
Local lRet, nOpca6  := 0,cSaveMenuh,oDlg
Local nLin := 001
Local _ni
nOpcE   := 2
nOpcG   := 3
nOpcEs  := nOpcE
nOpcGs  := nOpcG

M->VV0_NUMTRA := aCols[n,FG_POSVAR("VV0_NUMTRA","aHeader")]
DbSelectArea("VV0")
DbSetOrder(1)
DbSeek(xFilial("VV0")+M->VV0_NUMTRA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados dos Eqptos Instalados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VVA")
DbSetOrder(1)
DbSeek(xFilial("VVA")+M->VV0_NUMTRA)

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)

///////////////////////////////////////////
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados dos Itens de Campanha       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoIC:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VZ7")
aHeaderIC:={}
While !Eof().And.(x3_arquivo=="VZ7")
	If Alltrim(x3_campo) $ [VZ7_CODACV/VZ7_ITECAM/VZ7_VALITE]
		nUsadoIC:=nUsadoIC+1
		Aadd(aHeaderIC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		wVar  := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
Enddo
dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("VZ7_NUMTRA")
nUsadoIC:=nUsadoIC+1
Aadd(aHeaderIC,{ "", x3_campo, x3_picture,;
x3_tamanho, x3_decimal ,x3_valid,;
x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )

aColsIC:= {}
DbSelectArea("VZ7")
DbSetOrder(1)
If dbSeek(xFilial("VZ7")+M->VV0_NUMTRA)
	While !eof() .and. VZ7->VZ7_FILIAL+VZ7->VZ7_NUMTRA == xFilial("VZ7")+M->VV0_NUMTRA
		AADD(aColsIC,Array(nUsadoIC+1))
		For _ni:=1 to nUsadoIC
			aColsIC[Len(aColsIC),_ni]:=If(aHeaderIC[_ni,10] # "V",FieldGet(FieldPos(aHeaderIC[_ni,2])),CriaVar(aHeaderIC[_ni,2]))
		Next
		aColsIC[Len(aColsIC),nUsadoIC+1]:=.F.
		dbskip()
	Enddo
Endif

If Len(aColsIC) == 0
	aColsIC:={Array(nUsadoIC+1)}
	aColsIC[1,nUsadoIC+1]:=.F.
	For _ni:=1 to nUsadoIC
		aColsIC[1,_ni]:=CriaVar(aHeaderIC[_ni,2])
	Next
Endif

dbSelectArea("VVD")
dbSetOrder(1)

cAliasGetD7 := "VZ7"
cAlias7     := "VZ7"
///////////////////////////////////////////


If Len(aColsIC)>0
	
	nOpcaC := 0
	DEFINE MSDIALOG oDlgC TITLE cTitulo From 9,0 to 28,98	of oMainWnd
	nc          := 1
	nLinhas     := 99
	aHeaderSv   := aClone(aHeader)
	aHeader     := aClone(aHeaderIC)
	aColsSv      := aClone(aCols)
	aCols       := aClone(aColsIC)
	
	
	oGetCondicao:= MsGetDados():New(10,001,143,386,4,"AllwaysTrue()","AllwaysTrue()","",.T.,,,,99,"AllwaysTrue()",,,,oDlgC)
	oGetCondicao:oBrowse:default()
	ACTIVATE MSDIALOG oDlgC CENTERED ON INIT EnchoiceBar(oDlgC,{||nOpcaC:=1,Fs_GravaIC(),oDlgC:End()},{||oDlgC:End()})
	
	aCols := aClone(aColsSv)
	aHeader := aClone(aHeaderSv)
	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GravaIC³ Autor ³  Manoel               ³ Data ³ 29/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Itens de Campanha                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GravaIC()

Local itc

nIteCam  := 0
DbSelectArea("VZ7")
for itc := 1 to Len(aCols)
	DbSeek(xFilial("VZ7")+M->VV0_NUMTRA+aCols[itc,FG_POSVAR('VZ7_CODACV',"aHeader")]+aCols[itc,FG_POSVAR('VZ7_ITECAM',"aHeader")])
	If Found()
		If acols[itc,len(acols[itc])]
			Reclock("VZ7",.f.,.t.)
			DbDelete()
			MsUnlock()
			WriteSx2("VZ7")
			Loop
		Else
			Reclock("VZ7",.f.)
		Endif
	Else
		If !acols[itc,len(acols[itc])]
			Reclock("VZ7",.t.)
		Else
			Loop
		Endif
	Endif
	VZ7->VZ7_FILIAL := xFilial("VZ7")
	VZ7->VZ7_NUMTRA := M->VV0_NUMTRA
	VZ7->VZ7_CODACV := aCols[itc,FG_POSVAR('VZ7_CODACV',"aHeader")]
	VZ7->VZ7_ITECAM := aCols[itc,FG_POSVAR('VZ7_ITECAM',"aHeader")]
	VZ7->VZ7_VALITE := aCols[itc,FG_POSVAR('VZ7_VALITE',"aHeader")]
	MsUnlock()
	nIteCam  += VZ7->VZ7_VALITE
Next

dbSelectArea("VVA")
dbSetOrder(1)
DbSeek(xFilial("VVA")+M->VV0_NUMTRA)
dbSelectArea("VV1")
dbSetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
RecLock("VVA",.f.)
VVA->VVA_DESCLI := nIteCam
MsUnlock()

M->VVA_COMVDE := VVA->VVA_COMVDE
M->VVA_COMGER := VVA->VVA_COMGER

If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
	ExecBlock("FS_COMVEI",.f.,.f.)
	RecLock("VVA",.f.)
	VVA->VVA_COMVDE := M->VVA_COMVDE
	VVA->VVA_CMFVDE := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMVDE}} )
	VVA->VVA_CMFGER := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMGER}} )
	VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_VALIRF-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT
	VVA->VVA_LMFLQ2 := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_LUCLQ2}} )
	MsUnlock()
Endif
If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
	ExecBlock("FS_COMVEI",.f.,.f.)
	RecLock("VVA",.f.)
	VVA->VVA_COMGER := M->VVA_COMGER
	MsUnlock()
Endif


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GravaDE³ Autor ³  Manoel               ³ Data ³ 29/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Despesas do Veiculo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GravaDE()
Local i

nDespes := 0
For i:=1 to len(aCols)
	If aCols[i,FG_POSVAR("VVD_VALOR","aHeader")] == 0 .or. Empty(aCols[i,FG_POSVAR("VVD_CODIGO","aHeader")])
		loop
	Endif
	DbSelectArea("VVD")
	wProcura := dbseek(xFilial("VVD")+M->VV1_TRACPA+M->VV1_CHAINT+"0"+aCols[i,FG_POSVAR("VVD_CODIGO",'aHeader')]+dtos(aCols[i,FG_POSVAR("VVD_DATADR",'aHeader')]))
	If nOpcG == 3 .or. nOpcg == 4
		If aCols[i,len(aCols[i])] .And. wProcura
			RecLock("VVD",.F.,.T.)
			DbDelete()
			MsUnlock()
			WriteSx2("VVD")
		Else
			RecLock("VVD",If(wProcura,.F.,.T.))
			FG_GRAVAR("VVD",aCols,aHeader,i)
			VVD->VVD_TIPOPE := "0"
			VVD->VVD_FILIAL := xFilial("VVD")
			VVD->VVD_CHAINT := VV1->VV1_CHAINT
			VVD->VVD_TRACPA := VV1->VV1_TRACPA
			VVD->VVD_EXPCPG := aCols[i,FG_POSVAR("VVD_EXPCPG","aHeader")] //'1'
			MsUnlock()
			nDespes := nDespes + VVD->VVD_VALOR
		Endif
	Endif
Next

// ?????????????? COMO FICA O VVA_VCAVEI. PODEMOS JOGAR OS ITENS DE CAMPANHA NELE.

dbSelectArea("VVA")
dbSetOrder(1)
DbSeek(xFilial("VVA")+M->VV0_NUMTRA)
//nCusVei:= VVA->VVA_VCAVEI - nDespes1 + nDesPes
dbSelectArea("VV1")
dbSetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
M->VVA_DESVEI := FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"D")

dbSelectArea("VVA")
RecLock("VVA",.f.)
VVA->VVA_DESVEI := M->VVA_DESVEI
//VVA->VVA_VCAVEI := nCusVei
MsUnlock()



M->VVA_COMVDE := VVA->VVA_COMVDE
M->VVA_COMGER := VVA->VVA_COMGER

If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
	ExecBlock("FS_COMVEI",.f.,.f.)
	RecLock("VVA",.f.)
	VVA->VVA_COMVDE := M->VVA_COMVDE
	VVA->VVA_CMFVDE := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMVDE}} )
	VVA->VVA_CMFGER := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_COMGER}} )
	VVA->VVA_LUCLQ2 := VVA->VVA_LUCLQ1-VVA->VVA_VALIRF-VVA->VVA_COMVDE-VVA->VVA_COMGER-VVA->VVA_COMPAT
	VVA->VVA_LMFLQ2 := FG_CalcMF(  {{VV0->VV0_DATMOV,VVA->VVA_LUCLQ2}} )
	MsUnlock()
Endif
If ExistBlock("FS_COMVEI")   // Se existir este PRW, entao ele sera usado
	ExecBlock("FS_COMVEI",.f.,.f.)
	RecLock("VVA",.f.)
	VVA->VVA_COMGER := M->VVA_COMGER
	MsUnlock()
Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VALIDPERG ³ Autor ³ Andre Delorme         ³ Data ³ 09.06.06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
local _sAlias := Alias()
local aRegs := {}
local i,j
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01",STR0004,"","","mv_ch1","D",8,0,0,"G","","mv_par1","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02",STR0005,"","","mv_ch2","D",8,0,0,"G","","mv_par2","","","","","","","","","","","","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	lSk := dbSeek(cPerg+aRegs[i,2])
	RecLock("SX1",!lSk)
	For j:=1 to FCount()
		If j <= Len(aRegs[i])
			if !lSk .or. !(FieldName(j) $ "X1_CNT01.X1_CNT02.X1_CNT03.X1_CNT04.X1_CNT05.X1_PRESEL")
				&(FieldName(j)) := aRegs[i,j]
			endif
		Endif
	Next
	MsUnlock()
Next
dbSelectArea(_sAlias)
Return