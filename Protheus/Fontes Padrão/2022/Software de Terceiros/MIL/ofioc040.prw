// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 15     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOC040.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  21/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007375_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC040 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta de Itens Mandatorios/Correlatos e Kit's           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC040(cGrupo, cCodigo, lBTImporta)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor   := 1
Local OXverde
Local OXvermelho
Local OXazull
Local OXcinza
Local cfocus  := "oLbxPec:SetFocus()"
Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVerm := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAzul := LoadBitmap( GetResources(), "BR_AZUL" )
Private oCinz := LoadBitmap( GetResources(), "BR_CINZA" )
Private oOk   := LoadBitmap( GetResources(), "LBTIK" )
Private oNo   := LoadBitmap( GetResources(), "LBNO" )
Private aPCK  := {}
Private aPec  := {}
Private aRet  := {}
Private cGruPec := IIf(cGrupo==Nil,space(TamSx3("B1_GRUPO")[1]),cGrupo)
Private cCodPec := IIf(cCodigo==Nil,space(TamSx3("B1_CODITE")[1]),cCodigo)
Private lMarcar := .t.
Private lImporta:= .f.
Private nVlrFor := 0
Private cInfTec := ""

Default lBTImporta := .t.

If lBTImporta
	cfocus := "oImportar:SetFocus()"
EndIf

if Empty(Alltrim(GetNewPar("MV_FMLPECA","")))
	MsgInfo(STR0036)
	return .f.
endif

If Type("ljaPerg") # "U"
	lImporta := ljaPerg
EndIf
Private cFormul := &(GetNewPar("MV_FMLKIT",""))
If Empty(cForMul)
	cFormul := &(GetMv("MV_FMLPECA"))
Endif
Aadd(aPCK,{ .f. , " " , " " , " " , " " , 0 , 0 , 0 , 0 , 0 , "" } )
Aadd(aPec,{ .f. , " " , " " , " " , 0 , 0 , 0 , 0 , "2" , .f. , "" , 0 , "" } )
FS_VERPCK("1")
If cGrupo==Nil .or. !Empty(Alltrim(aPCK[1,2]+aPCK[1,3]+aPCK[1,4]+aPCK[1,5]))
	//
	// Fator de reducao 90%
	for nCntFor := 1 to Len(aSizeHalf)
		aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.90)
	next   
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 0, 12, .T. , .f. } ) // Topo
	AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox1
	AAdd( aObjects, { 0, 10, .T. , .f. } ) // Central
	AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox2
	AAdd( aObjects, { 0, 19, .T. , .f. } ) // Rodape
	aPos := MsObjSize( aInfo, aObjects )
	//
	DEFINE MSDIALOG oPCK FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL
	If !Empty(cGruPec)
		@ aPos[1,1],aPos[1,4]-55 BUTTON oSair PROMPT STR0005 OF oPCK SIZE 55,10 PIXEL ACTION (oPCK:End())
	EndIf
	@ aPos[1,1],aPos[1,2]+005 SAY STR0002 SIZE 35,08 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[1,1],aPos[1,2]+025 MSGET oGruPec VAR cGruPec PICTURE "@!" F3 "BM2" VALID (Get_Grupo:=cGruPec) SIZE 20,4 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[1,1],aPos[1,2]+075 SAY STR0003 SIZE 35,08 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[1,1],aPos[1,2]+100 MSGET oCodPec VAR cCodPec PICTURE "@!" F3 "B11" SIZE 90,4 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[1,1],aPos[1,2]+220 BUTTON oPesquisar PROMPT STR0004 OF oPCK SIZE 55,10 PIXEL ACTION (FS_VERPCK("2"),FS_VERPEC(aPCK[oLbxPCK:nAt,3],aPCK[oLbxPCK:nAt,4],"2"),oLbxPec:SetFocus(),oLbxPCK:SetFocus())
	If Empty(cGruPec)
		@ aPos[1,1],aPos[1,4]-55 BUTTON oSair PROMPT STR0005 OF oPCK SIZE 55,10 PIXEL ACTION (oPCK:End())
	EndIf
	@ aPos[2,1],aPos[2,4]-146 GET oInfTec VAR cInfTec OF oPCK MEMO SIZE 150,aPos[5,3]-aPos[2,1] PIXEL READONLY MEMO
	@ aPos[2,1],aPos[2,2] LISTBOX oLbxPCK FIELDS HEADER " ",STR0006,STR0007+" - "+STR0008,STR0009,STR0010,STR0011,STR0029,STR0030 COLSIZES 10,19,60,100,40,40,40,40 SIZE aPos[2,4]-150,aPos[2,3]-aPos[2,1] OF oPCK;
		PIXEL ON CHANGE(FS_VERPEC(aPCK[oLbxPCK:nAt,3],aPCK[oLbxPCK:nAt,4],"2"),(oLbxPec:SetFocus(),oLbxPec:Refresh()),(oLbxPec:Refresh(),oLbxPCK:SetFocus())) ON DBLCLICK ( &(cfocus) ) //Disponivel ## Importar
	oLbxPCK:SetArray(aPCK)
	oLbxPCK:bLine := { || {	IIf(aPCK[oLbxPCK:nAt,1],oVerd,oVerm),;
							aPCK[oLbxPCK:nAt,2],;
							aPCK[oLbxPCK:nAt,3]+" "+aPCK[oLbxPCK:nAt,4],;
							aPCK[oLbxPCK:nAt,5],;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,6],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,7],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,9],"@E 999,999")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,10],"@E 999,999"))}}
	
	@ aPos[3,1]+02,aPos[3,2]+002 SAY STR0012 SIZE 65,08 OF oPCK PIXEL COLOR CLR_BLUE

	// Parâmetro novo (CI 008719) para mostrar ou não o botão de importação
	If lBTImporta
		@ aPos[5,1]+02,aPos[5,4]-210 BUTTON oImportar PROMPT STR0027 OF oPCK SIZE 55,15 PIXEL ACTION (IIf(FS_QTDIMP(oLbxPCK:nAt),(FS_IMPORTA(aPCK[oLbxPCK:nAt,10],aPCK[oLbxPCK:nAt,11]),oPCK:End()),.t.)) WHEN lImporta
	EndIf

	@ aPos[4,1],aPos[3,2] LISTBOX oLbxPec FIELDS HEADER " "," "," ",STR0013,STR0009,STR0014,STR0015,STR0016,STR0031 COLSIZES 10,10,10,60,100,40,40,40,40 SIZE aPos[4,4]-150,aPos[4,3]-aPos[4,1] OF oPCK PIXEL ON DBLCLICK (FS_MARCA() , FS_CALCULA() )//Estoq Atual
	oLbxPec:SetArray(aPec)
	oLbxPec:bLine := { || {	IIf(aPec[oLbxPec:nAt,10],oOk,oNo),;
							IIf(aPec[oLbxPec:nAt,1],oVerd,oVerm),;
							IIf(aPec[oLbxPec:nAt,9]=="1",oAzul,oCinz),;
							aPec[oLbxPec:nAt,2]+" "+aPec[oLbxPec:nAt,3],;
							aPec[oLbxPec:nAt,4],;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,5],"@E 99,999.99")),;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,6],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,7],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,8],VS3->(X3PICTURE("VS3_QTDITE")))) }}

	oLbxPec:bHeaderClick := {|oObj,nCol| ( lMarcar:=!lMarcar , IIf( FS_TIK( lMarcar ) , .t. , ( lMarcar:=!lMarcar , oMarcar:Refresh() ) ) ) , }
	 
	@ aPos[5,1]+008,aPos[5,2]+009 BITMAP OXverde RESOURCE "BR_VERDE" OF oPCK PIXEL NOBORDER SIZE 10,10 when .f.
	@ aPos[5,1]+008,aPos[5,2]+018 SAY STR0019 SIZE 50,10 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[5,1]+008,aPos[5,2]+078 BITMAP OXvermelho RESOURCE "BR_VERMELHO" OF oPCK PIXEL NOBORDER SIZE 10,10 when .f.
	@ aPos[5,1]+008,aPos[5,2]+087 SAY STR0020 SIZE 50,10 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[5,1],aPos[5,2]+000 TO aPos[5,3],aPos[5,2]+155 LABEL STR0018 OF oPCK PIXEL
	
	@ aPos[5,1]+008,aPos[5,2]+169 BITMAP OXazull RESOURCE "BR_AZUL" OF oPCK PIXEL NOBORDER SIZE 10,10 when .f.
	@ aPos[5,1]+008,aPos[5,2]+178 SAY STR0022 SIZE 50,10 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[5,1]+008,aPos[5,2]+238 BITMAP OXcinza RESOURCE "BR_CINZA" OF oPCK PIXEL NOBORDER SIZE 10,10 when .f.
	@ aPos[5,1]+008,aPos[5,2]+247 SAY STR0023 SIZE 50,10 OF oPCK PIXEL COLOR CLR_BLUE
	@ aPos[5,1],aPos[5,2]+160 TO aPos[5,3],aPos[5,2]+300 LABEL STR0021 OF oPCK PIXEL

	ACTIVATE MSDIALOG oPCK CENTER
	
EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CALCULA³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula Total aPCK[x,7]                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CALCULA()
If aPec[oLbxPec:nAt,10]
	aPCK[oLbxPCK:nAt,7] += aPec[oLbxPec:nAt,7]
Else
	aPCK[oLbxPCK:nAt,7] -= aPec[oLbxPec:nAt,7]
EndIf
oLbxPCK:SetArray(aPCK)
oLbxPCK:bLine := { || {	IIf(aPCK[oLbxPCK:nAt,1],oVerd,oVerm),;
						aPCK[oLbxPCK:nAt,2],;
						aPCK[oLbxPCK:nAt,3]+" "+aPCK[oLbxPCK:nAt,4],;
						aPCK[oLbxPCK:nAt,5],;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,6],"@E 999,999.99")),;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,7],"@E 999,999.99")),;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,9],"@E 999,999")),;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,10],"@E 999,999"))}}
oLbxPCK:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³  FS_TIK  ³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tik do Vetor aPCK                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK( lMarcar )
Local ni := 0
Default lMarcar := .t.
For ni := 1 to Len(aPec)
	dbSelectArea("VE8")
	dbSetOrder(2)
	dbSeek(xFilial("VE8")+aPec[ni,2]+aPec[ni,3])
	if VE8->VE8_TIPO <> "1"
		If lMarcar
			If !aPec[ni,10]
				aPec[ni,10] := .t.
				aPCK[oLbxPCK:nAt,7] += aPec[ni,7]
			EndIf
			Else
			If aPec[ni,10]
				aPec[ni,10] := .f.
				aPCK[oLbxPCK:nAt,7] -= aPec[ni,7]
			EndIf
		EndIf
    Endif
Next
oLbxPCK:SetArray(aPCK)
oLbxPCK:bLine := { || {	IIf(aPCK[oLbxPCK:nAt,1],oVerd,oVerm),;
						aPCK[oLbxPCK:nAt,2],;
						aPCK[oLbxPCK:nAt,3]+" "+aPCK[oLbxPCK:nAt,4],;
						aPCK[oLbxPCK:nAt,5],;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,6],"@E 999,999.99")),;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,7],"@E 999,999.99")),;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,9],"@E 999,999")),;
						FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,10],"@E 999,999"))}}
oLbxPCK:Refresh()
oLbxPec:SetArray(aPec)
oLbxPec:bLine := { || {	IIf(aPec[oLbxPec:nAt,10],oOk,oNo),;
						IIf(aPec[oLbxPec:nAt,1],oVerd,oVerm),;
						IIf(aPec[oLbxPec:nAt,9]=="1",oAzul,oCinz),;
						aPec[oLbxPec:nAt,2]+" "+aPec[oLbxPec:nAt,3],;
						aPec[oLbxPec:nAt,4],;
						FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,5],"@E 99,999.99")),;
						FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,6],"@E 999,999.99")),;
						FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,7],"@E 999,999.99")),;
						FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,8],VS3->(X3PICTURE("VS3_QTDITE")))) }}
oLbxPec:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERPCK ³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra VEH e VE8                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERPCK(cTipo)
Local nKit := 999999
Local nTot := 0
Local cTip := ""
Local nTip := 0
Local ni   := 0
Local aAux := {}
Local lQtd := .t.
Local nQtd := 0
Local nVlr := 0
Local cQuery  := ""
Local cQAlVEH := "SQLVEH"
Local cQAlVE8 := "SQLVE8"
Local cQAlVEH8:= "SQLVEH8"
Local lVEH_MSBLQL := VEH->(FieldPos("VEH_MSBLQL")) > 0
lMarcar := .t.
aPCK := {}
If Empty(cGruPec+cCodPec)
	// Posiciona no VEH
	cQuery := "SELECT VEH.VEH_GRUKIT , VEH.VEH_CODKIT , VEH.VEH_DESKIT , VEH.VEH_VALKIT , VEH.VEH_PERDES "
	cQuery += "FROM "+RetSqlName("VEH")+" VEH WHERE "
	cQuery += "VEH.VEH_FILIAL='"+xFilial("VEH")+"' AND VEH.VEH_TIPO='2' AND VEH.D_E_L_E_T_=' '"

	If lVEH_MSBLQL
		cQuery += " AND VEH.VEH_MSBLQL <> '1' "
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVEH, .F., .T. )
	Do While !( cQAlVEH )->( Eof() )
		nTot := 0
		cTip := STR0025
		nTip := 2
		lQtd := .t.
		nKit := 999999
		nQtd := 0
		// Posiciona no VE8
		cQuery := "SELECT VE8.VE8_GRUITE , VE8.VE8_CODITE , VE8.VE8_QTDADE "
		cQuery += "FROM "+RetSqlName("VE8")+" VE8 WHERE "
		cQuery += "VE8.VE8_FILIAL='"+xFilial("VE8")+"' AND VE8.VE8_GRUKIT='"+( cQAlVEH )->( VEH_GRUKIT )+"' AND VE8.VE8_CODKIT='"+( cQAlVEH )->( VEH_CODKIT )+"' AND VE8.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVE8, .F., .T. )
		Do While !( cQAlVE8 )->( Eof() )
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + ( cQAlVE8 )->( VE8_GRUITE ) + ( cQAlVE8 )->( VE8_CODITE ) )
			If lQtd
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
				nQtd := SB2->B2_QATU
				If nQtd < ( cQAlVE8 )->( VE8_QTDADE )
					lQtd := .f.
					nKit := 0
				EndIf
			EndIf
			If Int(nQtd/( cQAlVE8 )->( VE8_QTDADE )) < nKit
				nKit := Int(nQtd/( cQAlVE8 )->( VE8_QTDADE ))
			EndIf
			nVlrFor := FG_FORMULA(cFormul)
			nTot += ( nVlrFor * ( cQAlVE8 )->( VE8_QTDADE ) )
			( cQAlVE8 )->( DbSkip() )
		EndDo
		( cQAlVE8 )->( dbCloseArea() )
		If nKit == 999999
			nKit := 0
		EndIf
		nQtd := nKit
		If ( cQAlVEH )->( VEH_VALKIT ) > 0
			nVlr :=  ( cQAlVEH )->( VEH_VALKIT ) 
		Else
			nVlr :=  nTot * (( cQAlVEH )->( VEH_PERDES )/100) 
		Endif
		Aadd(aPCK,{ lQtd , cTip , ( cQAlVEH )->( VEH_GRUKIT ) , ( cQAlVEH )->( VEH_CODKIT ) , left(( cQAlVEH )->( VEH_DESKIT ),25) , 0 , nTot , nTip , nQtd , 1 , space(TamSx3("VS3_OPER")[1]) } )
		( cQAlVEH )->( DbSkip() )
	EndDo
	( cQAlVEH )->( dbCloseArea() )
Else
	// Posiciona no VEH
	cQuery := "SELECT VEH.VEH_GRUKIT , VEH.VEH_CODKIT , VEH.VEH_DESKIT , VEH.VEH_TIPO , VEH.VEH_VALKIT , VEH.VEH_PERDES "
	cQuery += "FROM "+RetSqlName("VEH")+" VEH WHERE "
	cQuery += "VEH.VEH_FILIAL='"+xFilial("VEH")+"' AND VEH.VEH_GRUKIT='"+cGruPec+"' AND VEH.VEH_CODKIT='"+cCodPec+"' AND VEH.D_E_L_E_T_=' '"

	If lVEH_MSBLQL
		cQuery += " AND VEH.VEH_MSBLQL <> '1' "
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVEH, .F., .T. )
	Do While !( cQAlVEH )->( Eof() )
		nTot := 0
		lQtd := .t.
		nKit := 999999
		nQtd := 0
		// Posiciona no VE8
		cQuery := "SELECT VE8.VE8_GRUITE , VE8.VE8_CODITE , VE8.VE8_QTDADE "
		cQuery += "FROM "+RetSqlName("VE8")+" VE8 WHERE "
		cQuery += "VE8.VE8_FILIAL='"+xFilial("VE8")+"' AND VE8.VE8_GRUKIT='"+( cQAlVEH )->( VEH_GRUKIT )+"' AND VE8.VE8_CODKIT='"+( cQAlVEH )->( VEH_CODKIT )+"' AND VE8.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVE8, .F., .T. )
		Do While !( cQAlVE8 )->( Eof() )
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + ( cQAlVE8 )->( VE8_GRUITE ) + ( cQAlVE8 )->( VE8_CODITE ) )
			If lQtd
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
				nQtd := SB2->B2_QATU
				If nQtd < ( cQAlVE8 )->( VE8_QTDADE )
					lQtd := .f.
					If ( cQAlVEH )->( VEH_TIPO ) == "1" // "1" --> Item
						nKit := 0
					EndIf
				EndIf
			EndIf
			If ( cQAlVEH )->( VEH_TIPO ) == "1" // "1" --> Item
				If Int(nQtd/( cQAlVE8 )->( VE8_QTDADE )) < nKit
					nKit := Int(nQtd/( cQAlVE8 )->( VE8_QTDADE ))
				EndIf
			EndIf
			nVlrFor := FG_FORMULA(cFormul)
			nTot += ( nVlrFor * ( cQAlVE8 )->( VE8_QTDADE ) )
			( cQAlVE8 )->( DbSkip() )
		EndDo
		( cQAlVE8 )->( dbCloseArea() )
		If ( cQAlVEH )->( VEH_TIPO ) == "2" // "2" --> Kit
			cTip := STR0025
			nTip := 2
			nVlr := ( cQAlVEH )->( VEH_VALKIT )
			If nVlr == 0
				nVlr := nTot * (( cQAlVEH )->( VEH_PERDES ) / 100)
			Endif
			If nKit == 999999
				nKit := 0
			EndIf
			nQtd := nKit
		Else	// ( cQAlVEH )->( VEH_TIPO ) == "1" // "1" --> Item
			cTip := STR0024
			nTip := 1
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + ( cQAlVEH )->( VEH_GRUKIT ) + ( cQAlVEH )->( VEH_CODKIT ) )
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
			nVlrFor := FG_FORMULA(cFormul)
			nVlr := nVlrFor
			nQtd := SB2->B2_QATU
			lQtd := IIf(nQtd>0,.t.,.f.)
		EndIf
		Aadd(aPCK,{ lQtd , cTip , ( cQAlVEH )->( VEH_GRUKIT ) , ( cQAlVEH )->( VEH_CODKIT ) , left(( cQAlVEH )->( VEH_DESKIT ),25) , nVlr , nTot , nTip , nQtd , 1 , space(TamSx3("VS3_OPER")[1]) } )
		( cQAlVEH )->( DbSkip() )
	EndDo
	( cQAlVEH )->( dbCloseArea() )
	// Posiciona no VEH e VE8
	cQuery := "SELECT VEH.VEH_GRUKIT , VEH.VEH_CODKIT FROM "+RetSqlName("VEH")+" VEH "
	cQuery += "INNER JOIN "+RetSqlName("VE8")+" VE8 ON VE8.VE8_FILIAL='"+xFilial("VE8")+"' AND VEH.VEH_GRUKIT=VE8.VE8_GRUKIT AND VEH.VEH_CODKIT=VE8.VE8_CODKIT AND VE8.D_E_L_E_T_=' ' "
	cQuery += "WHERE VEH.VEH_FILIAL='"+xFilial("VEH")+"' AND VEH.VEH_TIPO='2' AND VE8.VE8_GRUITE='"+cGruPec+"' AND VE8.VE8_CODITE='"+cCodPec+"' AND VEH.D_E_L_E_T_=' '"

	If lVEH_MSBLQL
		cQuery += " AND VEH.VEH_MSBLQL <> '1' "
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVEH8, .F., .T. )
	Do While !( cQAlVEH8 )->( Eof() )
		Aadd(aAux,{ ( cQAlVEH8 )->( VEH_GRUKIT ) , ( cQAlVEH8 )->( VEH_CODKIT ) } )
		( cQAlVEH8 )->( DbSkip() )
	EndDo
	( cQAlVEH8 )->( dbCloseArea() )
	For ni := 1 to len(aAux)
		nTot := 0
		// Posiciona no VEH
		cQuery := "SELECT VEH.VEH_GRUKIT , VEH.VEH_CODKIT , VEH.VEH_DESKIT , VEH.VEH_VALKIT, VEH.VEH_PERDES "
		cQuery += "FROM "+RetSqlName("VEH")+" VEH WHERE "
		cQuery += "VEH.VEH_FILIAL='"+xFilial("VEH")+"' AND VEH.VEH_GRUKIT='"+aAux[ni,1]+"' AND VEH.VEH_CODKIT='"+aAux[ni,2]+"' AND VEH.D_E_L_E_T_=' '"

		If lVEH_MSBLQL
			cQuery += " AND VEH.VEH_MSBLQL <> '1' "
		EndIf

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVEH, .F., .T. )
		cTip := STR0025
		nTip := 2
		nVlr := ( cQAlVEH )->( VEH_VALKIT )
		lQtd := .t.
		nKit := 999999
		nQtd := 0
		// Posiciona no VE8
		cQuery := "SELECT VE8.VE8_GRUITE , VE8.VE8_CODITE , VE8.VE8_QTDADE "
		cQuery += "FROM "+RetSqlName("VE8")+" VE8 WHERE "
		cQuery += "VE8.VE8_FILIAL='"+xFilial("VE8")+"' AND VE8.VE8_GRUKIT='"+( cQAlVEH )->( VEH_GRUKIT )+"' AND VE8.VE8_CODKIT='"+( cQAlVEH )->( VEH_CODKIT )+"' AND VE8.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVE8, .F., .T. )
		Do While !( cQAlVE8 )->( Eof() )
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + ( cQAlVE8 )->( VE8_GRUITE ) + ( cQAlVE8 )->( VE8_CODITE ) )
			If lQtd
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
				nQtd := SB2->B2_QATU
				If nQtd < ( cQAlVE8 )->( VE8_QTDADE )
					lQtd := .f.
					nKit := 0
				EndIf
				If Int(nQtd/( cQAlVE8 )->( VE8_QTDADE )) < nKit
					nKit := Int(nQtd/( cQAlVE8 )->( VE8_QTDADE ))
				EndIf
			EndIf
			nVlrFor := FG_FORMULA(cFormul)
			nTot += ( nVlrFor * ( cQAlVE8 )->( VE8_QTDADE ) )
			( cQAlVE8 )->( DbSkip() )
		EndDo
		( cQAlVE8 )->( dbCloseArea() )
		If nKit == 999999
			nKit := 0
		EndIf
		nQtd := nKit
		If nVlr == 0
			nVlr := nTot * (( cQAlVEH )->( VEH_PERDES ) / 100)
		Endif
		Aadd(aPCK,{ lQtd , cTip , ( cQAlVEH )->( VEH_GRUKIT ) , ( cQAlVEH )->( VEH_CODKIT ) , left(( cQAlVEH )->( VEH_DESKIT ),25) , nVlr , nTot , nTip , nQtd , 1 , space(TamSx3("VS3_OPER")[1]) } )
		( cQAlVEH )->( dbCloseArea() )
	Next
EndIf
If Len(aPCK) == 0
	Aadd(aPCK,{ .f. , " " , " " , " " , " " , 0 , 0 , 0 , 0 , 0 , "" } )
	aPec := {}
	Aadd(aPec,{ .f. , " " , " " , " " , 0 , 0 , 0 , 0 , "2" , .f. , "" , 0 , "" } )
EndIf
aSort(aPCK,1,,{|x,y| str(x[8],1)+x[3]+x[4] < str(y[8],1)+y[3]+y[4] })
If cTipo == "2"
	oLbxPCK:nAt := 1
	oLbxPCK:SetArray(aPCK)
	oLbxPCK:bLine := { || {	IIf(aPCK[oLbxPCK:nAt,1],oVerd,oVerm),;
							aPCK[oLbxPCK:nAt,2],;
							aPCK[oLbxPCK:nAt,3]+" "+aPCK[oLbxPCK:nAt,4],;
							aPCK[oLbxPCK:nAt,5],;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,6],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,7],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,9],"@E 999,999")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,10],"@E 999,999"))}}
	oLbxPCK:SetFocus()
Else
	FS_VERPEC(aPCK[1,3],aPCK[1,4],"1")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERPEC ³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Pecas VE8                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERPEC(cGruPCK,cCodPCK,cTipo)
Local nQtd := 0
Local cQuery  := ""
Local cQAlVE8 := "SQLVE8"
lMarcar := .t.
If cTipo == "2"
	aPCK[oLbxPCK:nAt,7] := 0
EndIf
aPec := {}
cInfTec := STR0026+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Informações Técnicas:
If VEH->(FieldPos("VEH_INFTEC")) <> 0
	DbSelectArea("VEH")
	DbSetOrder(1) // VEH_GRUKIT + VEH_CODKIT
	If DbSeek(xFilial("VEH")+cGruPCK+cCodPCK)
		cInfTec += VEH->VEH_INFTEC // MEMO ( Informacoes Tecnicas do Cadastro de KIT )
	EndIf
EndIf
// Posiciona no VE8
cQuery := "SELECT VE8.VE8_GRUITE , VE8.VE8_CODITE , VE8.VE8_QTDADE , VE8.VE8_TIPO, VE8.VE8_PERPEC, VE8.VE8_GRUKIT, VE8.VE8_CODKIT "
cQuery += "FROM "+RetSqlName("VE8")+" VE8 WHERE "
cQuery += "VE8.VE8_FILIAL='"+xFilial("VE8")+"' AND VE8.VE8_GRUKIT='"+cGruPCK+"' AND VE8.VE8_CODKIT='"+cCodPCK+"' AND VE8.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVE8, .F., .T. )
Do While !( cQAlVE8 )->( Eof() )
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek( xFilial("SB1") + ( cQAlVE8 )->( VE8_GRUITE ) + ( cQAlVE8 )->( VE8_CODITE ) )
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + SB1->B1_COD + FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD") )
	nQtd := SB2->B2_QATU
	nVlrFor := FG_FORMULA(cFormul)
	Aadd(aPec,{ IIf(nQtd>=( cQAlVE8 )->( VE8_QTDADE ),.t.,.f.) ,;
				( cQAlVE8 )->( VE8_GRUITE ) ,;
				( cQAlVE8 )->( VE8_CODITE ) ,;
				left(SB1->B1_DESC,25) ,;
				( cQAlVE8 )->( VE8_QTDADE ) ,;
				nVlrFor ,;
				( nVlrFor * ( cQAlVE8 )->( VE8_QTDADE ) ) ,;
				nQtd ,;
				Iif(Empty(( cQAlVE8 )->( VE8_TIPO )), "2", ( cQAlVE8 )->( VE8_TIPO )) ,;
				.t. ,;
				FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS") ,;
				( cQAlVE8 )->( VE8_PERPEC) ,;
				( cQAlVE8 )->( VE8_GRUKIT )+( cQAlVE8 )->( VE8_CODKIT ) } )
	If cTipo == "2"
		aPCK[oLbxPCK:nAt,7] += ( nVlrFor * ( cQAlVE8 )->( VE8_QTDADE ) )
	EndIf
	( cQAlVE8 )->( DbSkip() )
EndDo
( cQAlVE8 )->( dbCloseArea() )
If Len(aPec) == 0
	Aadd(aPec,{ .f. , " " , " " , " " , 0 , 0 , 0 , 0 , "0" , .f. , "" , 0 , "" } )
EndIf
If cTipo == "2"
	oLbxPCK:SetArray(aPCK)
	oLbxPCK:bLine := { || {	IIf(aPCK[oLbxPCK:nAt,1],oVerd,oVerm),;
							aPCK[oLbxPCK:nAt,2],;
							aPCK[oLbxPCK:nAt,3]+" "+aPCK[oLbxPCK:nAt,4],;
							aPCK[oLbxPCK:nAt,5],;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,6],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,7],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,9],"@E 999,999")),;
							FG_AlinVlrs(Transform(aPCK[oLbxPCK:nAt,10],"@E 999,999"))}}
	oLbxPCK:Refresh()
	aSort(aPec,1,,{|x,y| x[9]+x[2]+x[3] < y[9]+y[2]+y[3] })
	oLbxPec:nAt := 1
	oLbxPec:SetArray(aPec)
	oLbxPec:bLine := { || {	IIf(aPec[oLbxPec:nAt,10],oOk,oNo),;
							IIf(aPec[oLbxPec:nAt,1],oVerd,oVerm),;
							IIf(aPec[oLbxPec:nAt,9]=="1",oAzul,oCinz),;
							aPec[oLbxPec:nAt,2]+" "+aPec[oLbxPec:nAt,3],;
							aPec[oLbxPec:nAt,4],;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,5],"@E 99,999.99")),;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,6],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,7],"@E 999,999.99")),;
							FG_AlinVlrs(Transform(aPec[oLbxPec:nAt,8],VS3->(X3PICTURE("VS3_QTDITE")))) }}
	oLbxPec:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPORTA³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta vetor de Retorno                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPORTA(nQtdImp,cTipOpe)
Local ni        := 0
Local nMult     := 1
Default nQtdImp := 1
Default cTipOpe := ""
aRet := {}
For ni := 1 to len(aPec)
	If !aPec[ni,10]
		nMult := 0
	endif
next
For ni := 1 to len(aPec)
	If aPec[ni,10]
		Aadd(aRet,{ aPec[ni,2] ,              ; // VE8_GRUITE
					aPec[ni,3] ,              ; // VE8_CODITE
					aPec[ni,11] ,             ; // B1_COD / B1_TS
					( aPec[ni,5] * nQtdImp ) ,; // VE8_QTDADE
					aPec[ni,6] ,              ; // Valor da Fórmula
					( aPec[ni,12] * nMult ) , ; // VE8_PERPEC
					aPec[ni,13] ,             ; // VE8_GRUKIT + VE8_CODKIT
					nQtdImp ,                 ; // Quantidade
					cTipOpe,                  ; // Tipo de Operação
					aPec[ni,9] })               // VE8_TIPO
	EndIf
Next
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_QTDIMP ³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Quantidade a Importar                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_QTDIMP(ni)
Local lOk := .f.
Private cTipOpe := aPCK[ni,11]
DEFINE MSDIALOG oQtdImp FROM 000,000 TO 010,030 TITLE STR0032 OF oMainWnd     //Qtde. de KITS a Importar
@ 010,018 SAY STR0033 SIZE 55,08 OF oQtdImp PIXEL COLOR CLR_BLUE              //Kits disponiveis:
@ 009,065 MSGET oEstoque VAR aPCK[ni,9] PICTURE "@E 999,999" SIZE 30,08 OF oQtdImp PIXEL COLOR CLR_BLUE WHEN .f.
@ 023,018 SAY STR0034 SIZE 55,08 OF oQtdImp PIXEL COLOR CLR_BLUE              //Qtde. a Importar:
@ 022,065 MSGET oQtdItem VAR aPCK[ni,10] VALID ( aPCK[ni,10] > 0 ) PICTURE "@E 999,999" SIZE 30,08 OF oQtdImp PIXEL COLOR CLR_BLUE
@ 036,065 MSGET oTipOpe VAR cTipOpe VALID ( VAZIO() .or. Existcpo("SX5","DJ"+cTipOpe) ) PICTURE "@!" F3 "DJ" SIZE 30,08 OF oQtdImp PIXEL COLOR CLR_BLUE
@ 035,018 SAY RetTitle("VS3_OPER") SIZE 55,08 OF oQtdImp PIXEL COLOR CLR_BLUE // Tipo de Operacao
@ 052,038 BUTTON oOkQtdImp PROMPT "OK" OF oQtdImp SIZE 50,10 PIXEL ACTION (lOk:=.t.,oQtdImp:End())
ACTIVATE MSDIALOG oQtdImp CENTER
If lOk
	aPCK[ni,11] := cTipOpe
EndIf
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MARCA ³ Autor ³  Thiago			    ³ Data ³ 20/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca itens.			                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MARCA()
   
dbSelectArea("VE8")
dbSetOrder(2)
dbSeek(xFilial("VE8")+aPec[oLbxPec:nAt,2]+aPec[oLbxPec:nAt,3])
if VE8->VE8_TIPO <> "1"
	if aPec[oLbxPec:nAt,10] 
		aPec[oLbxPec:nAt,10] := .f.
	Else
		aPec[oLbxPec:nAt,10] := .t.
	Endif	
Else 
   MsgInfo(STR0035)
   Return(.f.)
Endif
Return(.t.)

