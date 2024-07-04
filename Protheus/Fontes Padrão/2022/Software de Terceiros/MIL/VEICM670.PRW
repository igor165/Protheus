// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEICM670.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VEICM670³ Autor ³ Andre Luis Almeida       ³ Data ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Transferencia de Agendas CEV ( Vendedor / Data Agenda )     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM670()
Local nTam      := 0 
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lCEVOUT   := ( VAI->(FieldPos("VAI_CEVOUT")) <> 0 )
Local OXverme
Local OXverde
Private lTik    := .f.
Private oOkTik  := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik  := LoadBitmap( GetResources() , "LBNO" )
Private overde  := LoadBitmap( GetResources(), "BR_VERDE" )
Private overme  := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private cTipAge := " "
Private cCodVen := space(6)
Private cCodVenT:= space(6)
Private cCodCli := space(6)
Private cLojCli := "  "
Private cNomAge := space(100)
Private cNomVen := space(100)
Private cNomVenT:= space(100)
Private cNomCli := space(100)
Private dDtAgeI := ctod("")
Private dDtAgeF := (dDataBase+365)
Private dDtAgeT := ctod("")
Private aVetor  := {}
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek(xFilial("VAI")+__cUserID)
cCodVen := VAI->VAI_CODVEN
If !FS_VALVCM670("VD")
	cCodVen := space(6)
EndIf

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 54 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
aAdd( aObjects, { 0 , 12 , .T. , .F. } ) // Rodape
aPos := MsObjSize( aInfo, aObjects )

FS_FILTRAR(0)

DbSelectArea("VC1")
DEFINE MSDIALOG oDlgTranCEV TITLE STR0001 From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Transferencia de Agendas CEV
oDlgTranCEV:lEscClose := .F.

nTam := Int((aPos[1,4]/1.5))

@ aPos[1,1]+000,aPos[1,2]+000 TO aPos[2,1]-003,nTam LABEL "" OF oDlgTranCEV PIXEL
@ aPos[1,1]+005,aPos[1,2]+004+(nTam*0) SAY STR0002 SIZE 45,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Tp.Agenda
@ aPos[1,1]+004,aPos[1,2]+035+(nTam*0) MSGET oTipAge VAR cTipAge F3 "VC5" VALID FS_VALVCM670("TP") PICTURE X3Picture("VC1_TIPAGE") SIZE 20,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+005,aPos[1,2]+059+(nTam*0) SAY cNomAge SIZE 100,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+017,aPos[1,2]+004+(nTam*0) SAY STR0003 SIZE 45,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Vendedor
@ aPos[1,1]+016,aPos[1,2]+035+(nTam*0) MSGET oCodVen VAR cCodVen F3 "SA3" VALID FS_VALVCM670("VD") PICTURE X3Picture("A3_COD") SIZE 30,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE WHEN ( !lCEVOUT .or. VAI->VAI_CEVOUT=="1" )
@ aPos[1,1]+017,aPos[1,2]+071+(nTam*0) SAY cNomVen SIZE 100,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+029,aPos[1,2]+004+(nTam*0) SAY STR0004 SIZE 45,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Cliente
@ aPos[1,1]+028,aPos[1,2]+035+(nTam*0) MSGET oCodCli VAR cCodCli F3 "SA1" VALID FS_VALVCM670("CL") PICTURE X3Picture("A1_COD") SIZE 30,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+028,aPos[1,2]+070+(nTam*0) MSGET oLojCli VAR cLojCli VALID FS_VALVCM670("CL") PICTURE X3Picture("A1_LOJA") SIZE 10,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+029,aPos[1,2]+089+(nTam*0) SAY cNomCli SIZE 100,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+041,aPos[1,2]+004+(nTam*0) SAY STR0005 SIZE 45,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Dt.Agenda
@ aPos[1,1]+040,aPos[1,2]+035+(nTam*0) MSGET oDtAgeI VAR dDtAgeI PICTURE "@D" SIZE 40,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+041,aPos[1,2]+080+(nTam*0) SAY STR0006 SIZE 20,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // a
@ aPos[1,1]+040,aPos[1,2]+088+(nTam*0) MSGET oDtAgeF VAR dDtAgeF VALID(dDtAgeF>=dDtAgeI) PICTURE "@D" SIZE 40,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+040,(aPos[1,4]/1.5)-070 BUTTON oFiltrar PROMPT STR0007 OF oDlgTranCEV SIZE 55,10 PIXEL ACTION FS_FILTRAR(1) // Filtrar

@ aPos[1,1]+000,nTam+002 TO aPos[2,1]-003,aPos[1,4] LABEL "" OF oDlgTranCEV PIXEL
@ aPos[1,1]+005,aPos[1,2]+004+(nTam*1) SAY STR0018 SIZE 200,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Transferir a(s) Agenda(s) selecionada(s) para:
@ aPos[1,1]+017,aPos[1,2]+014+(nTam*1) SAY STR0003 SIZE 45,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Vendedor
@ aPos[1,1]+016,aPos[1,2]+045+(nTam*1) MSGET oCodVenT VAR cCodVenT F3 "SA3" VALID FS_VALVCM670("VT") PICTURE X3Picture("A3_COD") SIZE 30,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE WHEN ( !lCEVOUT .or. VAI->VAI_CEVOUT=="1" )
@ aPos[1,1]+017,aPos[1,2]+081+(nTam*1) SAY cNomVenT SIZE 100,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE
@ aPos[1,1]+029,aPos[1,2]+014+(nTam*1) SAY STR0005 SIZE 45,08 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Dt.Agenda
@ aPos[1,1]+028,aPos[1,2]+045+(nTam*1) MSGET oDtAgeT VAR dDtAgeT PICTURE "@D" SIZE 40,08 OF oDlgTranCEV PIXEL COLOR CLR_BLUE
@ aPos[1,1]+040,aPos[1,2]+(aPos[1,4])-070 BUTTON oTransf PROMPT STR0012 OF oDlgTranCEV SIZE 55,10 PIXEL ACTION IIf(FS_TRANSF(),FS_FILTRAR(1),.t.) // Transferir

@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbTexto FIELDS HEADER "","",;  //
										STR0002,;  // Tp Agenda
										STR0005,;  // Dt Agenda
										STR0003,;  // Vendedor
										STR0004,;  // Cliente
										STR0008,;  // Fone
										STR0009;   // Cidade-UF
										COLSIZES 10,10,18,30,65,110,100,100 SIZE aPos[2,4]-3,aPos[2,3]-aPos[2,1] OF oDlgTranCEV PIXEL ON DBLCLICK FS_TIK(oLbTexto:nAt)

oLbTexto:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lTik := !lTik , FS_TIK(0) ) ,Nil) , }
oLbTexto:SetArray(aVetor)
oLbTexto:bLine := { || {IIf(aVetor[oLbTexto:nAt,10],oOkTik,oNoTik) ,;
						IIf(aVetor[oLbTexto:nAt,1]=="verd",overde,overme) ,;
						aVetor[oLbTexto:nAt,2] ,;
						aVetor[oLbTexto:nAt,3] ,;
						aVetor[oLbTexto:nAt,4]+" "+left(aVetor[oLbTexto:nAt,5],15) ,;
						aVetor[oLbTexto:nAt,6]+" "+left(aVetor[oLbTexto:nAt,7],25) ,;
						aVetor[oLbTexto:nAt,8] ,;
						aVetor[oLbTexto:nAt,9] }}
oLbTexto:SetFocus()

nTam := Int((aPos[3,4]/2))

@ aPos[3,1]+000,aPos[3,2]+(nTam*0)+010 BITMAP OXverde RESOURCE "BR_verde"  OF oDlgTranCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+000,aPos[3,2]+(nTam*0)+020 SAY STR0010 SIZE 150,10 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Agendas nao realizadas e nao vencidas
@ aPos[3,1]+000,aPos[3,2]+(nTam*1)+010 BITMAP OXverme RESOURCE "BR_vermelho" OF oDlgTranCEV PIXEL NOBORDER SIZE 10,10 when .f.
@ aPos[3,1]+000,aPos[3,2]+(nTam*1)+020 SAY STR0011 SIZE 150,10 OF oDlgTranCEV  PIXEL COLOR CLR_BLUE // Agendas nao realizadas e vencidas

ACTIVATE MSDIALOG oDlgTranCEV ON INIT (EnchoiceBar(oDlgTranCEV,{|| oDlgTranCEV:End() }, {|| oDlgTranCEV:End() },,),)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³ Andre Luis Almeida   ³ Data ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK do ListBox                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(nLinha)
Local ni := 0
If len(aVetor) > 1 .or. !Empty(aVetor[1,2])
	If nLinha == 0 // Tik Total
		For ni := 1 to len(aVetor)
			aVetor[ni,10] := lTik
		Next
	Else
		aVetor[nLinha,10] := !aVetor[nLinha,10]
	EndIf
	oLbTexto:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_VALVCM670³ Autor ³ Andre Luis Almeida  ³ Data ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacao dos campos na TELA                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALVCM670(cTipo) // Validacao Campos TELA
Local lRet    := .f.
Local lCEVTPA := ( VAI->(FieldPos("VAI_CEVTPA")) <> 0 )
If cTipo == "TP"		// Verifica Tipo de Agenda
	cNomAge := space(100)
	If lCEVTPA .and. !Empty(VAI->VAI_CEVTPA) .and. !( cTipAge $ VAI->VAI_CEVTPA )
		Return(.f.)	
	EndIf	
	DbSelectArea("VC5")
	DbSetOrder(1)
	If DbSeek( xFilial("VC5") + Alltrim(cTipAge) , .f. )
		lRet := .t.
		If !Empty(cTipAge)
			cNomAge := VC5->VC5_DTPAGE
		EndIf
	EndIf
ElseIf cTipo == "VD"	// Verifica Vendedor para Agenda
	cNomVen := space(100)
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3") + Alltrim(cCodVen) , .f. )
		lRet := .t.
		If !Empty(cCodVen)
			cNomVen := SA3->A3_NOME
		EndIf
	EndIf
ElseIf cTipo == "VT"	// Verifica Vendedor para Agenda Transferida
	cNomVenT := space(100)
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek( xFilial("SA3") + Alltrim(cCodVenT) , .f. )
		lRet := .t.
		If !Empty(cCodVenT)
			cNomVenT := SA3->A3_NOME
		EndIf
	EndIf
ElseIf cTipo == "CL"	// Verifica Cliente+Loja
	cNomCli := space(100)
	lRet := .t.
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek( xFilial("SA1") + Alltrim(cCodCli+cLojCli) , .f. )
		If !Empty(cCodCli) .and. !Empty(cLojCli)
			cNomCli := SA1->A1_NOME
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida     ³ Data ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Filtra Contatos CEV                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(nTp) // Filtra Contatos
Local cQAlias  := "SQLVC1"
Local cQuery   := ""
Local ni       := 0
Local lA1IBGE  := ( SA1->(FieldPos("A1_IBGE")) <> 0 )
Local lCelular := ( SA1->(FieldPos("A1_CELULAR")) <> 0 )
Local lRESPST  := ( SA1->(FieldPos("A1_RESPST")) <> 0 )
Local lCEVTPA  := ( VAI->(FieldPos("VAI_CEVTPA")) <> 0 )
Local cCEVTPA  := ""
Local cAux     := ""
aVetor := {}
cQuery := "SELECT VC1.VC1_TIPAGE , VC1.VC1_DATAGE , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.VC1_CODVEN , VC1.VC1_ORIGEM , VC1.VC1_TIPORI , VC1.R_E_C_N_O_ AS RECVC1 , "
cQuery += "SA1.A1_NOME , SA1.A1_MUN , SA1.A1_EST , SA1.A1_TEL , "
If lCelular
	cQuery += "SA1.A1_CELULAR , "
EndIf
If lRESPST 
	cQuery += "SA1.A1_RESPST , "
EndIf
If lA1IBGE
	cQuery += "VAM.VAM_DESCID , VAM.VAM_ESTADO , VAM.VAM_DDD , "
EndIf
cQuery += "SA3.A3_NOME "
cQuery += "FROM "+RetSqlName("VC1")+" VC1 "
cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON ( SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=VC1.VC1_CODCLI AND SA1.A1_LOJA=VC1.VC1_LOJA AND SA1.D_E_L_E_T_=' ' ) "
If lA1IBGE
	cQuery += "LEFT JOIN "+RetSqlName("VAM")+" VAM ON ( VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND VAM.VAM_IBGE=SA1.A1_IBGE AND VAM.D_E_L_E_T_=' ' ) "
EndIf
cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON ( SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VC1.VC1_CODVEN AND SA3.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
If !Empty(cTipAge)
	cQuery += "VC1.VC1_TIPAGE='"+cTipAge+"' AND "
EndIf
If lCEVTPA
	If !Empty(VAI->VAI_CEVTPA)
		cCEVTPA := ""
		cAux    := Alltrim(VAI->VAI_CEVTPA)
		While len(cAux) > 0
			cCEVTPA += "'"+substr(cAux,1,TamSX3("VC1_TIPAGE")[1])+"',"
			cAux := substr(cAux,TamSX3("VC1_TIPAGE")[1]+1)
		EndDo
		cCEVTPA := left(cCEVTPA,len(cCEVTPA)-1)
		cQuery += "VC1.VC1_TIPAGE IN ("+cCEVTPA+") AND "
	EndIf
EndIf
If !Empty(cCodVen)
	cQuery += "VC1.VC1_CODVEN='"+cCodVen+"' AND "
EndIf
If !Empty(cCodCli+cLojCli)
	cQuery += "VC1.VC1_CODCLI='"+cCodCli+"' AND VC1.VC1_LOJA='"+cLojCli+"' AND "
EndIf
cQuery += "VC1.VC1_DATAGE>='"+dtos(dDtAgeI)+"' AND VC1.VC1_DATAGE<='"+dtos(dDtAgeF)+"' AND "
cQuery += "VC1.VC1_DATVIS=' ' AND "
cQuery += "VC1.D_E_L_E_T_=' ' ORDER BY VC1.VC1_DATAGE , VC1.VC1_TIPAGE , VC1.VC1_CODVEN , VC1.VC1_CODCLI , VC1.VC1_LOJA "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
Do While !( cQAlias )->( Eof() )
	Aadd(aVetor,{"",;											// 01
				( cQAlias )->( VC1_TIPAGE ),;					// 02
				stod(( cQAlias )->( VC1_DATAGE )),;			// 03
				( cQAlias )->( VC1_CODVEN ),;					// 04
				( cQAlias )->( A3_NOME ),;						// 05
				( cQAlias )->( VC1_CODCLI )+"-"+( cQAlias )->( VC1_LOJA ),;	// 06
				left(IIf(lRESPST,Alltrim(( cQAlias )->( A1_RESPST ))+" - ","")+( cQAlias )->( A1_NOME ),30),;			// 07
				IIf(lA1IBGE,"("+( cQAlias )->( VAM_DDD )+") ","")+Alltrim(( cQAlias )->( A1_TEL ))+IIf(lCelular," / "+Alltrim(( cQAlias )->( A1_CELULAR )),"") ,;	// 08
				Alltrim(left(IIf(lA1IBGE,( cQAlias )->( VAM_DESCID ),( cQAlias )->( A1_MUN )),22))+"-"+IIf(lA1IBGE,( cQAlias )->( VAM_ESTADO ),( cQAlias )->( A1_EST )) ,; // 09
				.f. , ( cQAlias )->( RECVC1 ) })	// 10 / 11
	If Empty( ( cQAlias )->( VC1_CODCLI ) + ( cQAlias )->( VC1_LOJA ) ) // CEV gerado SEM cliente ( Codigo / Loja )
		If ( cQAlias )->( VC1_TIPORI ) == "V" // Origem: Veiculos
			VV9->(DbSetOrder(1))
			VV9->(MsSeek(xFilial("VV9")+left(( cQAlias )->( VC1_ORIGEM ),10)))
			aVetor[len(aVetor),07] := VV9->VV9_NOMVIS // Nome
			aVetor[len(aVetor),08] := VV9->VV9_TELVIS // Fone
		EndIf
	EndIf
	If stod(( cQAlias )->( VC1_DATAGE )) < ddatabase
		aVetor[len(aVetor),1] := "verm"
	Else
		aVetor[len(aVetor),1] := "verd"
	EndIf
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
lTik := .f.
If len(aVetor) <= 0
	Aadd(aVetor,{"","",cTod(" "),"","","","","","",.f.,0})
EndIf
If nTp > 0
	oLbTexto:nAt := 1
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || {IIf(aVetor[oLbTexto:nAt,10],oOkTik,oNoTik) ,;
							IIf(aVetor[oLbTexto:nAt,1]=="verd",overde,overme) ,;
							aVetor[oLbTexto:nAt,2] ,;
							aVetor[oLbTexto:nAt,3] ,;
							aVetor[oLbTexto:nAt,4]+" "+left(aVetor[oLbTexto:nAt,5],15) ,;
							aVetor[oLbTexto:nAt,6]+" "+left(aVetor[oLbTexto:nAt,7],25) ,;
							aVetor[oLbTexto:nAt,8] ,;
							aVetor[oLbTexto:nAt,9] }}
	oLbTexto:SetFocus()
EndIf
DbSelectArea("VC1")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TRANSF ³ Autor ³ Andre Luis Almeida   ³ Data ³ 14/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transferir as Agendas (VC1)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TRANSF()
Local ni   := 0
Local lRet := .f.
If !Empty(cCodVenT) .or. !Empty(dDtAgeT)
	For ni := 1 to len(aVetor)
		If aVetor[ni,10]
			lRet := .t.
			Exit
		EndIf
	Next
	If lRet
		lRet := .f.
		If MsgYesNo(STR0014,STR0013) // Deseja transferir a(s) Agenda(s) selecionada(s)? / Atencao
			lRet := .t.
			For ni := 1 to len(aVetor)
				If aVetor[ni,10] .and. aVetor[ni,11] > 0
					DbSelectArea("VC1")
					DbGoTo(aVetor[ni,11])
					RecLock("VC1",.f.)
					If !Empty(cCodVenT)
						VC1->VC1_CODVEN := cCodVenT // Codigo do Vendedor
					EndIf					
					If !Empty(dDtAgeT)
						VC1->VC1_DATAGE := dDtAgeT // Data da Agenda
					EndIf
					MsUnLock()
				EndIf
			Next
			MsgInfo(STR0017,STR0013) // Agenda(s) transferida(s) com sucesso! / Atencao
		EndIf
	Else
		MsgStop(STR0015,STR0013) // Favor selecionar uma ou mais Agendas para realizar a transferencia! / Atencao
	EndIf
Else
	MsgStop(STR0016,STR0013) // Favor preencher o Vendedor e/ou a Data da Agenda para realizar a transferencia! / Atencao
EndIf
Return(lRet)