// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 09     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIVA270.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA270 ³ Autor ³  Manoel               ³ Data ³17/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza Valor e Vigencia por Modelo de Veiculo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA270

Local cQAlVV2 := "SQLVV2"

Local aObjects 	:= {}
Local aObjects1	:= {}
Local aSizeAut	:= MsAdvSize(,.F.,400)
Local bCampo	  := { |nCPO| Field(nCPO) }
Local nCntFor, nNew
Local nOpca := 0

Private	M->VAR_GRUMOD := ""

Private nPosLB

aRotina := { { ""  , "" , 0 , 1},;   //
{   ""  , "" , 0 , 2},;   //
{   ""  , "" , 0 , 3},;   //
{   ""  , "" , 0 , 2} }   //

nOpc    := 3

//
// MONTA ESPACAMENTO DAS TELAS
//

AAdd( aObjects, { 0,   40, .T., .F. } )		// TELA SUPERIOR (ENCHOICE) - TAMANHO VERTICAL FIXO
AAdd( aObjects, { 0,    275, .T., .T. } )	// TELA INFERIOR (FOLDER) - TAMANHO VERTICAL FIXO
AAdd( aObjects, { 0, 	110, .T., .F. } )	// TELA CENTRAL (GETDADOS) - TAMANHO VERTICAL VARIAVEL
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
// ESPACAMENTO DA TELA DE FOLDER - DIVIDIDA EM QUATRO LINHAS DE TAMANHO FIXO + UMA LINHA FINAL VARIAVEL
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 10, .T., .f. } )
AAdd( aObjects1, { 0, 0, .T., .T. } )
aAbaInt := { 0, 0, aPosObj[ 1,4 ] - aPosObj[ 1,2 ], aPosObj[ 1,3 ] - aPosObj[ 1,1 ] - 14 , 3, 3 }
aPosAba1 := MsObjSize( aAbaInt, aObjects1 )
//
INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5
//
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader da GetDados                            		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols   := {}
aHeader := {}
nUsado  :=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVP")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVP")
	If !(Alltrim(x3_campo) $ [VVP_CODMAR/VVP_DESMAR/VVP_MODVEI/VVP_SEGMOD/VVP_DESMOD/VVP_DATUSU]) .And. X3USO(x3_usado).And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
	if Inclui
		&("M->"+x3_campo) := CriaVar(x3_campo)
	endif
	DbSkip()
EndDo
dbSelectArea("VVP")
//ADHeadRec("VVP",aHeader)

If  VV2->(FieldPos("VV2_COMERC")) > 0
	cQuery := "SELECT * FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_COMERC ='1' AND VV2.D_E_L_E_T_=' '"
Else
	cQuery := "SELECT * FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.D_E_L_E_T_=' '"
Endif


dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV2, .F., .T. )

aVV2 := {}

If (cQAlVV2)->(!Eof())
	M->CODMAR := (cQAlVV2)->VV2_CODMAR
	M->GRUMOD := (cQAlVV2)->VV2_GRUMOD
	M->MODVEI := (cQAlVV2)->VV2_MODVEI
	M->SEGMOD := (cQAlVV2)->VV2_SEGMOD
	M->INIMOD := (cQAlVV2)->VV2_INIMOD
	M->FINMOD := (cQAlVV2)->VV2_FINMOD
	M->ANOMOD := Ctod("")
	M->VALORV := 0
	While (cQAlVV2)->(!Eof())
		VVB->(DbSeek(xFilial("VVB")+(cQAlVV2)->VV2_CATVEI))
		aadd(aVV2,{(cQAlVV2)->VV2_CODMAR,(cQAlVV2)->VV2_GRUMOD,(cQAlVV2)->VV2_MODVEI,(cQAlVV2)->VV2_DESMOD,(cQAlVV2)->VV2_SEGMOD,(cQAlVV2)->VV2_CATVEI,VVB->VVB_DESCRI})
		(cQAlVV2)->(DbSkip())
	Enddo
Else
	M->CODMAR := Space(Len((cQAlVV2)->VV2_CODMAR))
	M->GRUMOD := Space(Len((cQAlVV2)->VV2_GRUMOD))
	M->MODVEI := Space(Len((cQAlVV2)->VV2_MODVEI))
	M->SEGMOD := Space(Len((cQAlVV2)->VV2_SEGMOD))
	M->INIMOD := (cQAlVV2)->VV2_INIMOD
	M->FINMOD := (cQAlVV2)->VV2_FINMOD
	M->ANOMOD := Ctod("")
	M->VALORV := 0
Endif
If Len(aVV2) <= 0
	aVV2 := { {Space(3),Space(6),Space(30),Space(30),Space(6),Space(30),Space(20)} }
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols:={}
dbSelectArea("VVP")
dbSetOrder(1)
dbSeek(xFilial("VVP")+M->CODMAR+M->MODVEI+M->SEGMOD)
While !eof() .and. VVP->VVP_FILIAL == xFilial("VVP") .and. VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == M->CODMAR+M->MODVEI+M->SEGMOD
	AADD(aCols,Array(nUsado+1))
	For nCntFor:=1 to nUsado
		aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		If aHeader[nCntFor,2]  <> "V"
			&("M->"+aHeader[nCntFor,2]) := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Endif
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSelectArea("VVP")
	DbSkip()
EndDo
If Len(aCols) == 0
	aCols := {Array(nUsado+1) }
	aCols[1,nUsado+1] := .F.
	For nCntFor:=1 to nUsado
		aCols[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
	Next
Else
	aSort(aCols,,,{|x,z| x[1] > z[1]})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta condicao de pagamento e dados da NF                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//

aColsS := aClone(aCols)

M->CODMAR  := Space(Len((cQAlVV2)->VV2_CODMAR))
M->GRUMOD  := Space(Len((cQAlVV2)->VV2_GRUMOD))
M->MODVEI  := Space(Len((cQAlVV2)->VV2_MODVEI))
M->SEGMOD  := Space(Len((cQAlVV2)->VV2_SEGMOD))
M->ANOMOD  := Ctod("")
M->VALORV  := 0
M->CODMAR2 := Space(Len((cQAlVV2)->VV2_CODMAR))
M->GRUMOD2 := Space(Len((cQAlVV2)->VV2_GRUMOD))
M->MODVEI2 := Space(Len((cQAlVV2)->VV2_MODVEI))
M->SEGMOD2 := Space(Len((cQAlVV2)->VV2_SEGMOD))
M->ANOMOD2 := Ctod("")
M->VALORV2 := 0

(cQAlVV2)->(DbCloseArea())

M->VV2_CODMAR := ""
M->VV2_MODVEI := ""
M->VV2_SEGMOD := ""
M->VVP_DATPRC := ctod("")

cLinOk        :="AllwaysTrue()"
cFieldOk      :="FG_MEMVAR(),Va270VerDat()"
cTudOk		  :="AllwaysTrue()"

// a tela foi feita em 1024 x 768
nDivTel := 1
If aSizeAut[5] < 1000 // 800 X 600
	nDivTel := 1.28
Endif

DEFINE MSDIALOG oDlg FROM aSizeAut[2],0 TO aSizeAut[6],aSizeAut[5] TITLE (STR0001) Of oMainWnd PIXEL

@ aPosObj[1,1],aPosObj[1,2] SAY (STR0002) SIZE 40/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1],aPosObj[1,2]+40 MSGET M->CODMAR   PICTURE "@!" F3 "VE1" VALID (M->CODMAR2:=M->CODMAR,Empty(M->CODMAR)) .or. VE1->(DbSeek(xFilial("VE1")+M->CODMAR)) OF oDlg PIXEL COLOR CLR_BLACK
@ aPosObj[1,1],aPosObj[1,2]+110 SAY (STR0003) SIZE 30/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1],aPosObj[1,2]+125 MSGET M->CODMAR2  PICTURE "@!" F3 "VE1" VALID Empty(M->CODMAR2) .or. VE1->(DbSeek(xFilial("VE1")+M->CODMAR2)) OF oDlg PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+14,aPosObj[1,2] SAY (STR0004) SIZE 40/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+14,aPosObj[1,2]+40 MSGET M->GRUMOD   PICTURE "@!" F3 "VVR" VALID FS_VLD(1) SIZE 40/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+14,aPosObj[1,2]+110 SAY (STR0003) SIZE 30/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+14,aPosObj[1,2]+125 MSGET M->GRUMOD2  PICTURE "@!" F3 "VVR" VALID FS_VLD(11) SIZE 40/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+28,aPosObj[1,2] SAY (STR0005) SIZE 40/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+28,aPosObj[1,2]+40 MSGET M->MODVEI   PICTURE "@!" F3 "MCU" VALID FS_VLD(2) SIZE 60/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLACK
@ aPosObj[1,1]+28,aPosObj[1,2]+110 SAY (STR0003) SIZE 30/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+28,aPosObj[1,2]+125 MSGET M->MODVEI2  PICTURE "@!" F3 "MCU"  VALID FS_VLD(21) SIZE 60/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLACK

@ aPosObj[1,1],aPosObj[1,2]+200 SAY (STR0006) SIZE 40/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1],aPosObj[1,2]+230 MSGET M->VALORV   PICTURE "@E 999,999,999.99" VALID FS_VLD(5) SIZE 60,8 OF oDlg PIXEL COLOR CLR_BLACK
@ aPosObj[1,1],aPosObj[1,2]+295 SAY (STR0003) SIZE 30/nDivTel,10/nDivTel OF oDlg PIXEL COLOR CLR_BLUE
@ aPosObj[1,1],aPosObj[1,2]+310 MSGET M->VALORV2  PICTURE "@E 999,999,999.99"  VALID FS_VLD(51) SIZE 60,8 OF oDlg PIXEL COLOR CLR_BLACK

@ aPosObj[1,1]+28,aPosObj[1,2]+200 BUTTON oFiltrar PROMPT (STR0007) OF oDlg SIZE 55/nDivTel,10/nDivTel PIXEL ACTION (FS_Filtra("B"))

@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLboxD FIELDS HEADER ;
(STR0008),;//"Marca"
(STR0009),;//"Grupo Modelo"
(STR0010),;//"Modelo"
(STR0011),;//"Descricao"
(STR0012),;//"Segmento"
(STR0013),;//"Categoria Veiculos"
(STR0014);//"Descricao da Categoria"
COLSIZES 20/nDivTel,30/nDivTel,50/nDivTel,50/nDivTel,50/nDivTel,40/nDivTel,50/nDivTel SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[2,1]+3 OF oDlg  PIXEL ON  CHANGE( FS_Filtra("L") )

oLboxD:SetArray(aVV2)
oLboxD:bLine := { || { aVV2[oLboxD:nAt,01],;
aVV2[oLboxD:nAt,02],;
aVV2[oLboxD:nAt,03],;
aVV2[oLboxD:nAt,04],;
aVV2[oLboxD:nAt,05],;
aVV2[oLboxD:nAt,06],;
aVV2[oLboxD:nAt,07] } }

oGetDados := MsGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],nOpc,cLinOK,cTudOk    ,""         ,.f.,,            ,,       ,cFieldOk,,,,oDlg)
FS_Filtra("L")
ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,Fs_Grava(oLboxD:nAt),oDlg:End() },{||nOpca := 0,oDlg:End()})


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Filtra³ Autor ³  Manoel               ³ Data ³17/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Tabela VV2                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Filtra(cOrig)

Local cQAlVV2 := "SQLVV2"
Local nCntFor, nNew, nForD
Local lDifer := .f.

If cOrig == "L" // Veio do ListBox - Escolha do Modelo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houva alteracao no Acols                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCols) != Len(aColsS)
		lDifer := .t.
	Endif
	If lDifer
		If MsgYesNo(STR0015)
			FS_Grava(nPosLB)
		Endif
	Else
		For nCntFor := 1 to Len(aColsS)
			for nForD := 1 to Len(aHeader)
				If aCols[nCntFor,nForD] != aColsS[nCntFor,nForD]
					If MsgYesNo(STR0015)
						FS_Grava(nPosLB)
						nForD := Len(aHeader)
						exit
					Endif
				Endif
			Next
		Next
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols:={}
	dbSelectArea("VVP")
	dbgotop()
	dbSeek(xFilial("VVP")+aVV2[oLboxD:nAt,01]+aVV2[oLboxD:nAt,03]+Alltrim(aVV2[oLboxD:nAt,05]))
	While !eof() .and. VVP->VVP_FILIAL == xFilial("VVP") .and. VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == aVV2[oLboxD:nAt,01]+aVV2[oLboxD:nAt,03]+aVV2[oLboxD:nAt,05]
		If  M->VALORV2 > 0
			If !(VVP->VVP_VALTAB >= M->VALORV .and. VVP->VVP_VALTAB <= M->VALORV2)
				DbSkip()
				Loop
			Endif
		Endif
		AADD(aCols,Array(nUsado+1))
		For nCntFor:=1 to nUsado
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
			If aHeader[nCntFor,2]  <> "V"
				&("M->"+aHeader[nCntFor,2]) := FieldGet(FieldPos(aHeader[nCntFor,2]))
			Endif
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		DbSkip()
	EndDo
	If Len(aCols) == 0
		Aadd(aCols, Array( nUsado+1 ) )
		aCols[Len(aCols),nUsado+1]:=.F.
		For nCntFor:=1 to nUsado
			aCols[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
		Next
	Else
		aSort(aCols,,,{|x,z| x[1] > z[1]})
	Endif
	
Else
	
	
	If  VV2->(FieldPos("VV2_COMERC")) > 0
		If M->VALORV2 > 0
			cQuery := "SELECT * FROM "+RetSqlName("VV2")+" VV2,"+RetSqlName("VVP")+" VVP WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_COMERC ='1' AND "
			cQuery += "VV2.VV2_CODMAR = VVP.VVP_CODMAR AND VV2.VV2_MODVEI = VVP.VVP_MODVEI AND VV2.VV2_SEGMOD = VVP.VVP_SEGMOD AND VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND "
			cQuery += "VVP.VVP_VALTAB >= "+STR(M->VALORV)+" AND VVP.VVP_VALTAB <= "+STR(M->VALORV2)+" AND VVP.D_E_L_E_T_=' ' AND "
		Else
			cQuery := "SELECT * FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_COMERC ='1' AND "
		Endif
	Else
		cQuery := "SELECT * FROM "+RetSqlName("VV2")+" VV2 WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND "
	Endif
	If !Empty(M->CODMAR)
		cQuery += "VV2.VV2_CODMAR >= '"+M->CODMAR+"' AND "
	Endif
	If !Empty(M->CODMAR2)
		cQuery += "VV2.VV2_CODMAR <= '"+M->CODMAR2+"' AND "
	Endif
	If !Empty(M->GRUMOD)
		cQuery += "VV2.VV2_GRUMOD >= '"+M->GRUMOD+"' AND "
	Endif
	If !Empty(M->GRUMOD2)
		cQuery += "VV2.VV2_GRUMOD <= '"+M->GRUMOD2+"' AND "
	Endif
	If !Empty(M->MODVEI)
		cQuery += "VV2.VV2_MODVEI >= '"+M->MODVEI+"' AND "
	Endif
	If !Empty(M->MODVEI2)
		cQuery += "VV2.VV2_MODVEI <= '"+M->MODVEI2+"' AND "
	Endif
	If !Empty(M->SEGMOD)
		cQuery += "VV2.VV2_SEGMOD >= '"+M->SEGMOD+"' AND "
	Endif
	If !Empty(M->SEGMOD2)
		cQuery += "VV2.VV2_SEGMOD <= '"+M->SEGMOD2+"' AND "
	Endif
	If !Empty(M->ANOMOD)
		cQuery += "VV2.VV2_INIMOD >= '"+Dtos(M->ANOMOD)+"' AND "
	Endif
	If !Empty(M->ANOMOD2)
		cQuery += "VV2.VV2_FINMOD >= '"+Dtos(M->ANOMOD2)+"' AND "
	Endif
	cQuery += "VV2.D_E_L_E_T_=' ' "
	
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV2, .F., .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols:={}
	dbSelectArea("VVP")
	dbgotop()
	dbSeek(xFilial("VVP")+(cQAlVV2)->VV2_CODMAR+(cQAlVV2)->VV2_MODVEI+(cQAlVV2)->VV2_SEGMOD)
	While !eof() .and. VVP->VVP_FILIAL == xFilial("VVP") .and. VVP->VVP_CODMAR+VVP->VVP_MODVEI+VVP->VVP_SEGMOD == (cQAlVV2)->VV2_CODMAR+(cQAlVV2)->VV2_MODVEI+(cQAlVV2)->VV2_SEGMOD
		AADD(aCols,Array(nUsado+1))
		For nCntFor:=1 to nUsado
			aCols[Len(aCols),nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
			If aHeader[nCntFor,2]  <> "V"
				&("M->"+aHeader[nCntFor,2]) := FieldGet(FieldPos(aHeader[nCntFor,2]))
			Endif
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSelectArea("VVP")
		DbSkip()
	EndDo
	If Len(aCols) == 0
		Aadd(aCols, Array( nUsado+1 ) )
		aCols[Len(aCols),nUsado+1]:=.F.
		For nCntFor:=1 to nUsado
			aCols[1,nCntFor]:=CriaVar(aHeader[nCntFor,2])
		Next
	Else
		aSort(aCols,,,{|x,z| x[1] > z[1]})
	Endif
	
	aVV2 := {}
	(cQAlVV2)->(DbgoTop())
	While (cQAlVV2)->(!Eof())
		VVB->(DbSeek(xFilial("VVB")+(cQAlVV2)->VV2_CATVEI))
		aadd(aVV2,{(cQAlVV2)->VV2_CODMAR,(cQAlVV2)->VV2_GRUMOD,(cQAlVV2)->VV2_MODVEI,(cQAlVV2)->VV2_DESMOD,(cQAlVV2)->VV2_SEGMOD,(cQAlVV2)->VV2_CATVEI,VVB->VVB_DESCRI})
		(cQAlVV2)->(DbSkip())
	Enddo
	If Len(aVV2) <= 0
		aVV2 := { {Space(3),Space(6),Space(30),Space(30),Space(6),Space(30),Space(30)} }
	Endif
	
	(cQAlVV2)->(DbCloseArea())
	
Endif

aColsS := aClone(aCols)

oLboxD:SetArray(aVV2)
oLboxD:bLine := { || { aVV2[oLboxD:nAt,01],;
aVV2[oLboxD:nAt,02],;
aVV2[oLboxD:nAt,03],;
aVV2[oLboxD:nAt,04],;
aVV2[oLboxD:nAt,05],;
aVV2[oLboxD:nAt,06],;
aVV2[oLboxD:nAt,07] } }
oLBoxD:Refresh()
oGetDados:oBrowse:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VLD   ³ Autor ³  Manoel               ³ Data ³17/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao dos Gets do Filtro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLD(cPar)

If cPar == 1
	M->GRUMOD2 := M->GRUMOD
	M->VAR_GRUMOD := M->GRUMOD
	If !Empty(M->CODMAR) .and. !Empty(M->GRUMOD)
		VVR->(DbSetOrder(2))
		VVR->(DbSeek(xFilial("VVR")+M->CODMAR+M->GRUMOD))
		Return VVR->(found())
	Endif
ElseIf cPar == 11
	If !Empty(M->CODMAR) .and. !Empty(M->GRUMOD2)
		VVR->(DbSetOrder(2))
		VVR->(DbSeek(xFilial("VVR")+M->CODMAR+M->GRUMOD2))
		Return VVR->(found())
	Endif
ElseIf cPar == 2
	M->MODVEI2 := M->MODVEI
	If !Empty(M->CODMAR) .and. !Empty(M->MODVEI)
		VV2->(DbSetOrder(1))
		VV2->(DbSeek(xFilial("VV2")+M->CODMAR+M->MODVEI))
		Return VV2->(found())
	Endif
ElseIf cPar == 21
	If !Empty(M->CODMAR) .and. !Empty(M->MODVEI2)
		VV2->(DbSetOrder(1))
		VV2->(DbSeek(xFilial("VV2")+M->CODMAR+M->MODVEI2))
		Return VV2->(found())
	Endif
ElseIf cPar == 3
	M->SEGMOD:=M->SEGMOD
	If !Empty(M->SEGMOD)
		VJB->(DbSeek(xFilial("VJB")+M->SEGMOD))
		Return VJB->(found())
	Endif
ElseIf cPar == 31
	If !Empty(M->SEGMOD2)
		VJB->(DbSeek(xFilial("VJB")+M->SEGMOD2))
		Return VJB->(found())
	Endif
ElseIf cPar == 4
	M->ANOMOD2:=M->ANOMOD
	If Dtos(M->ANOMOD) > "19000101" .or. Empty(M->ANOMOD)
		Return .t.
	Else
		Return .f.
	Endif
ElseIf cPar == 41
	If Dtos(M->ANOMOD2) > "19000101" .and. M->ANOMOD2 <= M->ANOMOD
		Return .t.
	Else
		Return .f.
	Endif
ElseIf cPar == 5
	Return .t.
ElseIf cPar == 51
	If M->VALORV2 >= M->VALORV
		Return .t.
	Else
		Return .f.
	Endif
Endif

return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Grava ³ Autor ³  Manoel               ³ Data ³17/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ faz a Gravacao no VVP                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Grava(nPosi)

Local ifor

DbSelectArea("VVP")
DbSetOrder(1)

for ifor := 1 to Len(aCols)
	
	If !aCols[ifor,Len(aHeader)+1]
		
		DbSeek(xFilial("VVP")+aVV2[nPosi,01]+aVV2[nPosi,03]+aVV2[nPosi,05]+Dtos(aCols[ifor,FG_POSVAR("VVP_DATPRC")]))
		
		RecLock("VVP",!Found())
		FG_GRAVAR("VVP",aCols,aHeader,ifor)
		VVP->VVP_FILIAL := xFilial("VVP")
		VVP->VVP_CODMAR := aVV2[nPosi,01]
		VVP->VVP_MODVEI := aVV2[nPosi,03]
		VVP->VVP_SEGMOD := aVV2[nPosi,05]
		VVP->VVP_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
		
	Endif
	
Next


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Va270VerDat³ Autor ³  Manoel               ³ Data ³17/12/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida data de Validade                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Va270VerDat()

nPosLB := oLboxD:nAt
If Readvar() == "M->VVP_DATPRC"
	If M->VVP_DATPRC < dDataBase
		MsgStop(STR0016)
		Return .f.
	Endif
Endif

Return .t.
