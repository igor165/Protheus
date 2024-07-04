#Include "PROTHEUS.CH"
#Include "VEIXX015.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX015 º Autor ³ Andre Luis Almeida º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Finame                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc (2-Visualizar/4-Alterar/3-Incluir)                    º±±
±±º          ³ aParFna (Parametros do Finame)                             º±±
±±º			 ³	 aParFna[01] = Nro do Atendimento                         º±±
±±º			 ³	 aParFna[02] = Codigo do Cliente                          º±±
±±º			 ³	 aParFna[03] = Loja do Cliente                            º±±
±±º			 ³	 aParFna[04] = Codigo do Finame                           º±±
±±º			 ³	 aParFna[05] = Nro. PAC do Finame                         º±±
±±º			 ³	 aParFna[06] = SE1 para 1=Cliente / 2=Financeira/Banco    º±±
±±º			 ³	 aParFna[07] = SE2 Valor Flat para Financeira/Banco       º±±
±±º			 ³	 aParFna[08] = SE2 Data Flat para Financeira/Banco        º±±
±±º			 ³	 aParFna[09] = SE2 Valor Risco para Financeira/Banco      º±±
±±º			 ³	 aParFna[10] = SE2 Data Risco para Financeira/Banco       º±±
±±º          ³ aVS9 (Pagamentos)                                          º±±
±±º			 ³	 aVS9[1] aHeader VS9                                      º±±
±±º          ³   aVS9[2] aCols VS9                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX015(nOpc,aParFna,aVS9)
Local aObjects    := {} , aPos := {} , aInfo := {} 
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lRet        := .f.
Local nCntFor     := 1
Local nLin        := 0
Local ni          := 0
Local nPos        := 0
Local cQuery      := ""
Local cQAlias     := "SQLALIAS"
Local cCdCli      := space( TamSx3('VV0_CLFINA')[1] )
Local cLjCli      := space( TamSx3('VV0_LJFINA')[1] )
Local cNome       := ""
Local cCdFin      := space( TamSx3('VV0_CFINAM')[1])
Local cNrPAC      := space( TamSx3('VV0_NFINAM')[1] )
Local nOpcao      := 0
Local lDblClick   := .f.
Local cTpPagFin   := ""
Local cTpPagCon   := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='3' ( Consorcio )
Local cTpFiname   := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='6' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='6' ( Finame )
Local dDtFiname   := ( dDataBase + FM_SQL("SELECT VSA.VSA_DIADEF FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+cTpFiname+"' AND VSA.D_E_L_E_T_=' '") )
Local nVlFiname   := 0
Local nVS9Finame  := 0
Local aCFFina     := X3CBOXAVET("VV0_CFFINA","0") // 1=Cliente / 2=Financeira/Banco
Local cCFFina     := "1"
Local nPFlat      := 0
Local nPRisc      := 0
Local nVlFlat     := 0
Local nVlRisc     := 0
Local dDtFlat     := dDtFiname 
Local dDtRisc     := dDtFiname 
Local aWhenSX3    := {}
Local aCposCust   := {}
Private aHeaderVS9 := aClone(aVS9[1])
Private cValPict    := GetSX3Cache("VS9_VALPAG","X3_PICTURE")

if empty(cValPict)
	cValPict := "@E 99,999,999.99"
endif

If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
	lDblClick := .t.
	If Empty(cTpFiname)
		MsgStop(STR0003,STR0002) // Impossivel continuar! Nao existe Tipo de Pagamento relacionado a Finame. / Atencao
		Return lRet
	EndIf
EndIf

If ExistBlock("VX015FNM") // Campos Customizados no Finame
	aCposCust := ExecBlock("VX015FNM",.f.,.f.)
EndIf

// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Finame 
aPos := MsObjSize( aInfo, aObjects )
// Levanta todos os Tipos de Pagamento para Financiamento / Leasing  ( VSA_TIPO='1' )
cQuery := "SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. ) 
Do While !( cQAlias )->( Eof() )
	cTpPagFin += ( cQAlias )->( VSA_TIPPAG )+"/"
  	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() ) 
For ni := 1 to len(aVS9[2]) // Selecionar o Finame ja utilizado neste Atendimento
	If !aVS9[2,ni,len(aVS9[2,ni])] .and. !Empty(aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")])
		If !Empty(cTpFiname)
			If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpFiname
				nVS9Finame := ni // Linhas do aCols do VS9
				nVlFiname  := aVS9[2,ni,FG_POSVAR("VS9_VALPAG","aHeaderVS9")]
				dDtFiname  := aVS9[2,ni,FG_POSVAR("VS9_DATPAG","aHeaderVS9")]
			EndIf
		EndIf
		If !Empty(cTpPagCon) // Verifica se ja existe Consorcio NAO quitado para o Atendimento
			If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpPagCon
				If left(aVS9[2,ni,FG_POSVAR("VS9_REFPAG","aHeaderVS9")],1) == "0" // Existe Consorcio NAO quitado - 
					MsgStop(STR0004,STR0002) // Ja existe Consorcio NAO quitado para este Atendimento. Impossivel incluir Finame! / Atencao
					Return lRet
				EndIf
			EndIf
		EndIf
		If !Empty(cTpPagFin) // Verifica se ja existe Financiamento para o Atendimento
			If (aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")]+"/") $ cTpPagFin
				MsgStop(STR0005,STR0002) // Ja existe Financiamento para este Atendimento. Impossivel incluir Finame! / Atencao
				Return lRet
			EndIf
		EndIf
	EndIf
Next
DbSelectArea("VV0")
DbSetOrder(1)
DbSeek(xFilial("VV0")+aParFna[01])
If nVlFiname == 0 .and. ( nOpc == 3 .or. nOpc == 4 ) // Nao tem Finame ainda, Executar RELACAO dos Campos
	cCdCli  := CriaVar("VV0_CLFINA") // Executar o relacao do SX3
	cLjCli  := CriaVar("VV0_LJFINA") // Executar o relacao do SX3
	cCdFin  := CriaVar("VV0_CFINAM") // Executar o relacao do SX3
	cNrPAC  := CriaVar("VV0_NFINAM") // Executar o relacao do SX3
	cCFFina := CriaVar("VV0_CFFINA") // Executar o relacao do SX3
Else
	cCdCli  := VV0->VV0_CLFINA
	cLjCli  := VV0->VV0_LJFINA
	cCdFin  := VV0->VV0_CFINAM
	cNrPAC  := VV0->VV0_NFINAM
	cCFFina := VV0->VV0_CFFINA
EndIf
FS_BANCO(@cCdCli,@cLjCli,@cNome)
If cCFFina == "2" // Financeira/Banco
	If nVlFiname == 0 .and. ( nOpc == 3 .or. nOpc == 4 ) // Nao tem Finame ainda, Executar RELACAO dos Campos
		nVlFlat := CriaVar("VV0_VFFINA") // Executar o relacao do SX3
		dDtFlat := CriaVar("VV0_DFFINA") // Executar o relacao do SX3
		nVlRisc := CriaVar("VV0_VRFINA") // Executar o relacao do SX3
		dDtRisc := CriaVar("VV0_DRFINA") // Executar o relacao do SX3
	Else
		nVlFlat := VV0->VV0_VFFINA
		dDtFlat := VV0->VV0_DFFINA
		nVlRisc := VV0->VV0_VRFINA
		dDtRisc := VV0->VV0_DRFINA
	EndIf
	nPFlat := ( nVlFlat / nVlFiname ) * 100
	nPRisc := ( nVlRisc / nVlFiname ) * 100
EndIf
aWhenSX3 := {	Alltrim(GetSx3Cache('VV0_CLFINA','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_LJFINA','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_CFINAM','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_NFINAM','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_CFFINA','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_VFFINA','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_DFFINA','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_VRFINA','X3_WHEN')) ,;
				Alltrim(GetSx3Cache('VV0_DRFINA','X3_WHEN'))  ;
			}
DEFINE MSDIALOG oTelaFiname TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Finame
	oTelaFiname:lEscClose := .F.
	//
	nLin := 18
	//
	@ aPos[1,1]+nLin-10,aPos[1,2] TO aPos[1,1]+nLin+54,aPos[1,4]+002 LABEL "" OF oTelaFiname PIXEL 
	@ aPos[1,1]+nLin+1,aPos[1,2]+008 SAY STR0006 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Cliente Banco Finame
	@ aPos[1,1]+nLin+0,aPos[1,2]+070 MSGET oFNCdCli VAR cCdCli PICTURE "@!" SIZE 45,08 F3 "VSA" VALID FS_BANCO(@cCdCli,@cLjCli,@cNome) OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 ) .and. IIf(!Empty(aWhenSX3[1]),&(aWhenSX3[1]),.t.)
	@ aPos[1,1]+nLin+0,aPos[1,2]+120 MSGET oFNLjCli VAR cLjCli PICTURE "@!" SIZE 25,08 VALID FS_BANCO(@cCdCli,@cLjCli,@cNome) OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 ) .and. IIf(!Empty(aWhenSX3[2]),&(aWhenSX3[2]),.t.)
	@ aPos[1,1]+nLin+0,aPos[1,2]+150 MSGET oFNNome VAR cNome PICTURE "@!" SIZE aPos[1,4]-160,8 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN .f.
	nLin += 18
	@ aPos[1,1]+nLin+1,aPos[1,2]+008 SAY STR0008 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Codigo Finame
	@ aPos[1,1]+nLin+0,aPos[1,2]+070 MSGET oFNCdFin VAR cCdFin PICTURE "@!" SIZE 80,08 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 ) .and. IIf(!Empty(aWhenSX3[3]),&(aWhenSX3[3]),.t.)
	nLin += 18
	@ aPos[1,1]+nLin+1,aPos[1,2]+008 SAY STR0009 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Numero PAC
	@ aPos[1,1]+nLin+0,aPos[1,2]+070 MSGET oFNNrPAC VAR cNrPAC PICTURE "@!" SIZE 80,08 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 ) .and. IIf(!Empty(aWhenSX3[4]),&(aWhenSX3[4]),.t.)
	nLin += 18
	//
	nLin += 18
	//
	@ aPos[1,1]+nLin-10,aPos[1,2] TO aPos[1,1]+nLin+18,aPos[1,4]+002 LABEL STR0010 OF oTelaFiname PIXEL // Titulo a Receber
	nCntFor	:= (aPos[1,4]/15)
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*1) MSCOMBOBOX oCFFina VAR cCFFina SIZE (nCntFor*3),08 ON CHANGE FS_VLFINAME(0,nVlFiname,cCFFina,@nPFlat,@nVlFlat,@nPRisc,@nVlRisc) ITEMS aCFFina OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 ) .and. IIf(!Empty(aWhenSX3[5]),&(aWhenSX3[5]),.t.)
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*5) SAY STR0007 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Valor
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*6) MSGET oFNVlFiname VAR nVlFiname PICTURE cValPict VALID ( nVlFiname >= 0 .and. FS_VLFINAME(1,nVlFiname,cCFFina,@nPFlat,@nVlFlat,@nPRisc,@nVlRisc) ) SIZE (nCntFor*3),8 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( nOpc == 3 .or. nOpc == 4 )
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*10) SAY STR0011 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Vencimento
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*12) MSGET oDtFiname VAR dDtFiname PICTURE "@D" VALID ( dDtFiname >= dDataBase ) SIZE (nCntFor*2),08 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	nLin += 18
	//
	nLin += 18
	//
	@ aPos[1,1]+nLin-10,aPos[1,2] TO aPos[1,1]+nLin+36,aPos[1,4]+002 LABEL STR0012 OF oTelaFiname PIXEL // Taxas Finame a Pagar
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*1) SAY STR0013 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Flat
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*2) MSGET oPFlat VAR nPFlat PICTURE "@E 999.99 %" VALID ( nPFlat >= 0 .and. nPFlat <= 100 .and. FS_VLFINAME(2,nVlFiname,cCFFina,@nPFlat,@nVlFlat,@nPRisc,@nVlRisc) ) SIZE (nCntFor*1),8 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. cCFFina == "2" ) .and. IIf(!Empty(aWhenSX3[6]),&(aWhenSX3[6]),.t.)
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*5) SAY STR0007 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Valor
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*6) MSGET oVlFlat VAR nVlFlat PICTURE cValPict VALID ( nVlFlat >= 0 .and. nVlFlat <= nVlFiname .and. FS_VLFINAME(3,nVlFiname,cCFFina,@nPFlat,@nVlFlat,@nPRisc,@nVlRisc) ) SIZE (nCntFor*3),8 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. cCFFina == "2" ) .and. IIf(!Empty(aWhenSX3[6]),&(aWhenSX3[6]),.t.)
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*10) SAY STR0011 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Vencimento
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*12) MSGET oDtFlat VAR dDtFlat PICTURE "@D" VALID ( dDtFlat >= dDataBase ) SIZE (nCntFor*2),08 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. cCFFina == "2" ) .and. IIf(!Empty(aWhenSX3[7]),&(aWhenSX3[7]),.t.)
	nLin += 18
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*1) SAY STR0014 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Risco
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*2) MSGET oPRisc VAR nPRisc PICTURE "@E 999.99 %" VALID ( nPRisc >= 0 .and. nPRisc <= 100 .and. FS_VLFINAME(2,nVlFiname,cCFFina,@nPFlat,@nVlFlat,@nPRisc,@nVlRisc) ) SIZE (nCntFor*1),8 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. cCFFina == "2" ) .and. IIf(!Empty(aWhenSX3[8]),&(aWhenSX3[8]),.t.)
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*5) SAY STR0007 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Valor
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*6) MSGET oVlRisc VAR nVlRisc PICTURE cValPict VALID ( nVlRisc >= 0 .and. nVlRisc <= nVlFiname .and. FS_VLFINAME(3,nVlFiname,cCFFina,@nPFlat,@nVlFlat,@nPRisc,@nVlRisc) ) SIZE (nCntFor*3),8 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. cCFFina == "2" ) .and. IIf(!Empty(aWhenSX3[8]),&(aWhenSX3[8]),.t.)
	@ aPos[1,1]+nLin+1,aPos[1,2]+(nCntFor*10) SAY STR0011 SIZE 100,8 OF oTelaFiname PIXEL COLOR CLR_BLUE // Vencimento
	@ aPos[1,1]+nLin+0,aPos[1,2]+(nCntFor*12) MSGET oDtRisc VAR dDtRisc PICTURE "@D" VALID ( dDtRisc >= dDataBase ) SIZE (nCntFor*2),08 OF oTelaFiname PIXEL COLOR CLR_BLACK WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. cCFFina == "2" ) .and. IIf(!Empty(aWhenSX3[9]),&(aWhenSX3[9]),.t.)
	nLin += 18
	//
	nLin += 18
	//
	If len(aCposCust) > 0
		aadd(aCposCust,"NOUSER") // NAO MOSTRAR CAMPOS CUSTOMIZADOS A MAIS - SOMENTE MOSTRAR OS CAMPOS QUE ESTAO NO VETOR <<< aCposCust >>>
		oCposCust := TScrollBox():New( oTelaFiname , aPos[1,1]+nLin-10 , aPos[1,2] , aPos[1,3] - ( aPos[1,1]+nLin- 10 ) , aPos[1,4] , .t. , , .t. )
		oEnchCust := MSMGet():New( "VV0", VV0->(RecNo()) , IIf(nOpc==3.or.nOpc==4,4,2) ,;
			/* aCRA */, /* cLetra */, /* cTexto */, aCposCust, {0,0,100,100}, aCposCust, 3,;
			/* nColMens */, /* cMensagem */, ".t." , oCposCust, .f., .t., .t. /* lColumn */ ,;
			"", .t. /* lNoFolder */, .f.)
		oEnchCust:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf

ACTIVATE MSDIALOG oTelaFiname CENTER ON INIT (EnchoiceBar(oTelaFiname,{|| nOpcao:=1 , oTelaFiname:End()},{ || oTelaFiname:End()},,))

If nOpcao == 1 // OK Tela
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		aParFna[02] := ""
		aParFna[03] := ""
		aParFna[04] := ""
		aParFna[05] := ""
		aParFna[06] := cCFFina
		aParFna[07] := 0
		aParFna[08] := ctod("")
		aParFna[09] := 0
		aParFna[10] := ctod("")
		If nVS9Finame > 0 // Exclui registro da aCols do VS9 ( Finame )
			aVS9[2,nVS9Finame,len(aVS9[2,nVS9Finame])] := .t.
		EndIf
		If nVlFiname > 0 // Incluir Financiamento se o Valor > 0
			aParFna[02] := cCdCli // Codigo do Cliente (Banco)
			aParFna[03] := cLjCli // Loja do Cliente (Banco)
			aParFna[04] := cCdFin // Codido do Finame
			aParFna[05] := cNrPAC // Nro. PAC Finame
			If cCFFina == "2" // Financeira/Banco
				aParFna[07] := nVlFlat
				aParFna[08] := dDtFlat
				aParFna[09] := nVlRisc
				aParFna[10] := dDtRisc
			EndIf
			If nVS9Finame > 0 // Reutiliza registro do VS9
				nPos := nVS9Finame
    		Else // Inclui na aCols do VS9
            	aAdd(aVS9[2],Array(len(aVS9[1])+1))
            	nPos := len(aVS9[2])
    		EndIf
			aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(aParFna[01],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
			aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
			aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := cTpFiname
			aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := dDtFiname
			aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := nVlFiname
			aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := ""
			aVS9[2,nPos,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := "01"
			aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_BANCO º Autor ³ Andre Luis Almeida º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega o nome do Banco                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BANCO(cCdCli,cLjCli,cNome)
Local lRet := .f.
SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+cCdCli+Alltrim(cLjCli)))
	lRet   := .t.
	cLjCli := SA1->A1_LOJA
	cNome  := SA1->A1_NOME
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VLFINAME º Autor ³ Andre Luis Almeida º Data ³ 29/05/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Limpar campos, calcular % e valores                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLFINAME(nTp,nVlFiname,cCFFina,nPFlat,nVlFlat,nPRisc,nVlRisc)
If nTp == 0 // Combo: 1=Cliente / 2=Financeira/Banco
	If cCFFina == "1" // Cliente
		nPFlat  := 0
		nPRisc  := 0
		nVlFlat := 0
		nVlRisc := 0
		oPFlat:Refresh()
		oPRisc:Refresh()
		oVlFlat:Refresh()
		oVlRisc:Refresh()
	EndIf
ElseIf nTp == 1 // Valor Geral Finame
	If cCFFina == "2" // Financeira/Banco
		If nPFlat > 0
			nVlFlat := ( nVlFiname * ( nPFlat / 100 ) )
			oVlFlat:Refresh()
		Else
			nPFlat := ( nVlFlat / nVlFiname ) * 100
			oPFlat:Refresh()
		EndIf
		If nPRisc > 0
			nVlRisc := ( nVlFiname * ( nPRisc / 100 ) )
			oVlRisc:Refresh()
		Else
			nPRisc := ( nVlRisc / nVlFiname ) * 100
			oPRisc:Refresh()
		EndIf
	EndIf
ElseIf nTp == 2 // % Taxas
	If cCFFina == "2" // Financeira/Banco
		nVlFlat := ( nVlFiname * ( nPFlat / 100 ) )
		nVlRisc := ( nVlFiname * ( nPRisc / 100 ) )
		oVlFlat:Refresh()
		oVlRisc:Refresh()
	EndIf
ElseIf nTp == 3 // Valor Taxas
	If cCFFina == "2" // Financeira/Banco
		nPFlat  := ( nVlFlat / nVlFiname ) * 100
		nPRisc  := ( nVlRisc / nVlFiname ) * 100
		oPFlat:Refresh()
		oPRisc:Refresh()
	EndIf
EndIf
Return .t.