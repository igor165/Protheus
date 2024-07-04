// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 33     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "VEICM550.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM550 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta/Agendamento/Impressao Clientes por Regiao/Cidade  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM550()
Private aClientes := {}
Private aCidades  := {}
Private nREC      := 0
Private nRECT     := 0
Private oOk       := LoadBitmap( GetResources(), "LBTIK" )
Private oNo       := LoadBitmap( GetResources(), "LBNO" )
Private oVo       := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVe       := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private lMarcar   := .f.
Private nOK       := 0
Private cRegiao   := "   "
Private cTpAgenda := space(1)
Private dDtAgenda := ctod("  /  /  ")
Private cVdAgenda := space(6)
Private cVendedor := space(6)
Private aCEV      := {}
Private nCEV      := 0
Private cFcAgenda := STR0031
Private aItAgenda := {(STR0031),(STR0032)}
Private nTotCid   := 0
Private aResumo   := {}
Private aAgenda   := {}
Private cCodCli   := ""
Private aTipCli   := {"1: "+(STR0038),"2: "+(STR0039),"3: "+(STR0040)}
Private cTipCli   := "1: "+STR0038
Private cNomeCli  := space(30)
Private aTipPesq  := {(STR0086),(STR0087)}
Private cTipPesq  := STR0086
Private cNomeCid  := space(30)
Private nT        := 1
Private cT        := STR0038
Private lNroEnd   := (SA1->(FieldPos("A1_NUMERO"))>0)
Private cQuery    := ""
Private lA1_IBGE  := (SA1->(FieldPos("A1_IBGE"))>0)
Private cObjetiv  := ""
Processa( {|| FS_VEICM550() } )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VEICM550³ Autor ³  Andre Luis Almeida  ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta DIALOG das Cidades e dos Clientes                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VEICM550()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lVCF      := .f.
Local ni        := 0
Local ny        := 0
Local nPos      := 0
Local cMun      := "INICIAL"
Local aTemp     := {}
Local cPessoa   := ""
Local cPess     := STR0096
Local aPess     := {STR0096,STR0097,STR0098}
Local cCli      := STR0099
Local aCli      := {STR0099,STR0100,STR0101}
//Local cQAlVCF   := "SQLVCF"
Local cQAlSA1   := "SQLSA1"
Local lCliVCF   := .f.
Local lMudaVend := .t.
Local aVend     := {STR0099,STR0068,STR0085,STR0084}
Local aTipClass := {"",STR0068,STR0085,STR0084}
Local aCliClass := {"","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
Local lVCF_GRUECN := ( VCF->(FieldPos("VCF_GRUECN")) > 0 )
Local cGrupEcn    := Space(39)
Local lNewVend    := ( VCF->(FieldPos("VCF_VENVEU")) > 0 ) // Possui campos novos Vendedores
Private cVend     := STR0099
Private cTipClass := ""
Private cCliClass := ""
//
If lNewVend
	aVend     := {STR0099,STR0068,STR0085,STR0084,STR0109,STR0110,STR0114}
	aTipClass := {""     ,STR0068,STR0085,STR0084,STR0109,STR0110,STR0114}
EndIf
//
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
cVendedor := VAI->VAI_CODVEN
If ( VAI->(FieldPos("VAI_CEVOUT")) > 0 )
	If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
   		lMudaVend := .f.
	EndIf
EndIf

Aadd(aCidades,{ .f. , " " , " " , " " , " " } )

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 23 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox

aPos := MsObjSize( aInfo, aObjects )

FS_VAL_VCM550() // Levanta Todas as Cidades

DEFINE MSDIALOG oDlg1 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL

@ aPos[1,1]+000,aPos[1,2] TO aPos[2,3],150 LABEL "" OF oDlg1 PIXEL

@ aPos[1,1]+003,aPos[1,2]+006 SAY STR0002 SIZE 20,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+012,aPos[1,2]+006 MSGET oRegiao VAR cRegiao PICTURE "@!" F3 "VCB" VALID FS_VAL_VCM550("ATUAL") SIZE 20,08 OF oDlg1 PIXEL COLOR CLR_BLUE

@ aPos[1,1]+003,aPos[1,2]+040 SAY STR0088 SIZE 75,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+012,aPos[1,2]+040 MSGET oNomeCid VAR cNomeCid PICTURE "@!" SIZE 72,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+012,aPos[1,2]+117 BUTTON oPesqOK PROMPT (STR0090) OF oDlg1 SIZE 22,10 PIXEL ACTION (FS_PESQ_OK("Cid"))

@ aPos[2,1],aPos[2,2] LISTBOX oLbx1 FIELDS HEADER (" "),(STR0004),(STR0005),(STR0006) COLSIZES 10,110,20,20 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oDlg1 PIXEL ON DBLCLICK (aCidades[oLbx1:nAt,1] := !aCidades[oLbx1:nAt,1])
oLbx1:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcar:=!lMarcar , FS_TIK( "aCidades" , lMarcar ) ) ,Nil) , }
oLbx1:SetArray(aCidades)
oLbx1:bLine := { || {IIf(aCidades[oLbx1:nAt,1],oOk,oNo),;
aCidades[oLbx1:nAt,2],;
aCidades[oLbx1:nAt,3],;
aCidades[oLbx1:nAt,4]}}

@ aPos[1,1]+001,aPos[1,2]+160 SAY STR0008 SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+010,aPos[1,2]+160 MSCOMBOBOX oVend VAR cVend ITEMS aVend SIZE 48,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+010,aPos[1,2]+210 MSGET oVendedor VAR cVendedor PICTURE "@!" F3 "SA3" VALID FS_VAL_VCM550("EV") SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE WHEN lMudaVend

@ aPos[1,1]+001,aPos[1,2]+253 SAY STR0095 SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+010,aPos[1,2]+253 MSCOMBOBOX oPess VAR cPess ITEMS aPess SIZE 40,08 OF oDlg1 PIXEL COLOR CLR_BLUE

@ aPos[1,1]+001,aPos[1,2]+304 SAY STR0102 SIZE 50,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ aPos[1,1]+010,aPos[1,2]+304 MSCOMBOBOX oCli VAR cCli ITEMS aCli SIZE 85,08 OF oDlg1 PIXEL COLOR CLR_BLUE

If VCF->(FieldPos("VCF_CLAPEC")) > 0
	@ aPos[1,1]+001,aPos[1,2]+397 SAY STR0112 SIZE 80,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+010,aPos[1,2]+397 MSCOMBOBOX oTipClass VAR cTipClass ITEMS aTipClass SIZE 48,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+010,aPos[1,2]+447 MSCOMBOBOX oCliClass VAR cCliClass ITEMS aCliClass SIZE 22,08 OF oDlg1 PIXEL COLOR CLR_BLUE
EndIf

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{ || IIf(FS_VERCIDAD(),oDlg1:End(),nOk:=0) }, { || oDlg1:End() },,)

If nOK == 1
	cQuery := " SELECT SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_CGC, SA1.A1_PESSOA, SA1.A1_NOME, SA1.A1_TEL, SA1.A1_END, "
	If lA1_IBGE
		cQuery += " SA1.A1_IBGE, "
	Endif
	if lNroEnd
		cQuery += " SA1.A1_NUMERO, "
	Endif
	cQuery += " SA1.A1_BAIRRO,SA1.A1_CEP, SA1.A1_EMAIL, "
	cQuery += " VCF.VCF_CODCLI , VCF.VCF_LOJCLI , VCF.VCF_BLOQAG, VCF.VCF_CODSEG, "
	If lVCF_GRUECN
		cQuery += " VCF.VCF_GRUECN, "
	Endif
	cQuery += " VCF.VCF_VENVEI,VCF.VCF_VENPEC,VCF.VCF_VENSRV,VCF.VCF_VENVEU,VCF.VCF_VENPNE,VCF.VCF_VENOUT,VCF.VCF_CONDIC, VCF.VCF_NIVIMP, VCF.VCF_DATCAD "
	cQuery += " FROM "+RetSqlName("SA1")+" SA1 "
	If !Empty(Alltrim(cVendedor)) .or. cCli == STR0100 .or. !Empty(Alltrim(cTipClass))
		cQuery += " INNER JOIN "+RetSqlName("VCF")+" VCF ON(VCF.VCF_FILIAL = '"+xFilial("VCF")+"' AND SA1.A1_COD = VCF.VCF_CODCLI AND SA1.A1_LOJA = VCF.VCF_LOJCLI AND VCF.D_E_L_E_T_=' ' ) "
		lCliVCF  := .t.
	Else
		cQuery += " LEFT JOIN "+RetSqlName("VCF")+" VCF ON(VCF.VCF_FILIAL = '"+xFilial("VCF")+"' AND SA1.A1_COD = VCF.VCF_CODCLI AND SA1.A1_LOJA = VCF.VCF_LOJCLI AND VCF.D_E_L_E_T_=' ' ) "
	Endif
	cQuery += " WHERE "
	If Alltrim(cVendedor) == "*"
		Do Case
			Case cVend == STR0099 // Todos
				If lNewVend
					cQuery += "( VCF.VCF_VENPEC<>' ' OR VCF.VCF_VENVEI<>' ' OR VCF.VCF_VENSRV<>' ' OR VCF.VCF_VENVEU<>' ' OR VCF.VCF_VENPNE<>' ' OR VCF.VCF_VENOUT<>' ' ) AND " 
				Else
					cQuery += "( VCF.VCF_VENPEC<>' ' OR VCF.VCF_VENVEI<>' ' OR VCF.VCF_VENSRV<>' ' ) AND "
				EndIf
			Case cVend == STR0068 // Pecas
				cQuery += "VCF.VCF_VENPEC<>' ' AND "
			Case cVend == STR0084 // Veic.Novos
				cQuery += "VCF.VCF_VENVEI<>' ' AND "
			Case cVend == STR0085 // Oficina
				cQuery += "VCF.VCF_VENSRV<>' ' AND "
			Case cVend == STR0109 // Veic.Usados
				cQuery += "VCF.VCF_VENVEU<>' ' AND "
			Case cVend == STR0110 // Pneus
				cQuery += "VCF.VCF_VENPNE<>' ' AND "
			Case cVend == STR0114 // Outros
				cQuery += "VCF.VCF_VENOUT<>' ' AND "
		EndCase
	ElseIf !Empty(cVendedor)
		Do Case
			Case cVend == STR0099 // Todos
				If lNewVend
					cQuery += "( VCF.VCF_VENPEC='"+cVendedor+"' OR VCF.VCF_VENVEI='"+cVendedor+"' OR VCF.VCF_VENSRV='"+cVendedor+"' OR VCF.VCF_VENVEU='"+cVendedor+"' OR VCF.VCF_VENPNE='"+cVendedor+"' OR VCF.VCF_VENOUT='"+cVendedor+"' ) AND " 
				Else
					cQuery += "( VCF.VCF_VENPEC='"+cVendedor+"' OR VCF.VCF_VENVEI='"+cVendedor+"' OR VCF.VCF_VENSRV='"+cVendedor+"' ) AND "
				EndIf
			Case cVend == STR0068 // Pecas
				cQuery += "VCF.VCF_VENPEC='"+cVendedor+"' AND "
			Case cVend == STR0084 // Veic.Novos
				cQuery += "VCF.VCF_VENVEI='"+cVendedor+"' AND "
			Case cVend == STR0085 // Oficina
				cQuery += "VCF.VCF_VENSRV='"+cVendedor+"' AND "
			Case cVend == STR0109 // Veic.Usados
				cQuery += "VCF.VCF_VENVEU='"+cVendedor+"' AND "
			Case cVend == STR0110 // Pneus
				cQuery += "VCF.VCF_VENPNE='"+cVendedor+"' AND "
			Case cVend == STR0114 // Outros
				cQuery += "VCF.VCF_VENOUT='"+cVendedor+"' AND "
		EndCase
	EndIf
	If !Empty(cTipClass)
		Do Case
			Case cTipClass == STR0068 // Pecas
				cQuery += "VCF.VCF_CLAPEC='"+cCliClass+"' AND "
			Case cTipClass == STR0084 // Veic.Novos
				cQuery += "VCF.VCF_CLAVEI='"+cCliClass+"' AND "
			Case cTipClass == STR0085 // Oficina
				cQuery += "VCF.VCF_CLASRV='"+cCliClass+"' AND "
			Case cTipClass == STR0109 // Veic.Usados
				cQuery += "VCF.VCF_CLAVEU='"+cCliClass+"' AND "
			Case cTipClass == STR0110 // Pneus
				cQuery += "VCF.VCF_CLAPNE='"+cCliClass+"' AND "
			Case cTipClass == STR0114 // Outros
				cQuery += "VCF.VCF_CLAOUT='"+cCliClass+"' AND "
		EndCase
	EndIf
	If cCli # STR0099
		If cCli == STR0100 
		cQuery += " VCF.VCF_BLOQAG IS NULL AND "
		ElseIf cCli == STR0101
		cQuery += " VCF.VCF_BLOQAG IS NOT NULL AND "
		EndIf
	EndIf
	cQuery += "SA1.D_E_L_E_T_=' ' "
	If cPess # STR0096
		If cPess == STR0097 // "Fisica"
			cQuery += " AND SA1.A1_PESSOA = 'F' "
		ElseIf cPess == STR0098  // "Juridica"
			cQuery += " AND SA1.A1_PESSOA = 'J' "
		EndIf
	EndIf
	cQuery += " ORDER BY 1, 2, 3 "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSA1 , .F., .T. )
	If !( cQAlSA1 )->( Eof() )
		
		Do While !( cQAlSA1 )->( Eof() )
			Aadd(aCEV,{ (cQAlSA1)->(A1_FILIAL),;// 1
				(cQAlSA1)->(A1_COD),;// 2
				(cQAlSA1)->(A1_LOJA),;// 3
				(cQAlSA1)->(A1_CGC),;// 4
				(cQAlSA1)->(A1_PESSOA),;// 5
				(cQAlSA1)->(A1_NOME),;// 6
				(cQAlSA1)->(A1_TEL),;// 7
				(cQAlSA1)->(A1_END),;// 8
				(cQAlSA1)->(A1_BAIRRO),;// 9
				(cQAlSA1)->(A1_CEP),;// 10
				(cQAlSA1)->(A1_EMAIL),;// 11
				IIf(lNroEnd ,(cQAlSA1)->(A1_NUMERO),""),;// 12
				IIf(lA1_IBGE,(cQAlSA1)->(A1_IBGE),""),;// 13
				(cQAlSA1)->(VCF_CODCLI),;// 14
				(cQAlSA1)->(VCF_LOJCLI),;// 15
				(cQAlSA1)->(VCF_BLOQAG),;// 16
				(cQAlSA1)->(VCF_CODSEG),;// 17
				IIf(lVCF_GRUECN,(cQAlSA1)->(VCF_GRUECN),""),;// 18
				(cQAlSA1)->(VCF_VENVEI),;// 19
				(cQAlSA1)->(VCF_VENPEC),;// 20
				(cQAlSA1)->(VCF_VENSRV),;// 21
				(cQAlSA1)->(VCF_VENVEU),;// 22
				(cQAlSA1)->(VCF_VENPNE),;// 23
				(cQAlSA1)->(VCF_VENOUT),;// 24
				(cQAlSA1)->(VCF_CONDIC),;// 25
				(cQAlSA1)->(VCF_NIVIMP),;// 26
				(cQAlSA1)->(VCF_DATCAD)})// 27
			( cQAlSA1 )->( DbSkip() )
		EndDo
	EndIf
	( cQAlSA1 )->( dbCloseArea() )
	nCEV := 0
	nREC := len(aCEV)

	nRECT := ( nREC / 25 )
	ProcRegua( 25 )
	nREC := 0
	lMarcar  := .f.

	For ni := 1 to Len(aCEV)
		If !Empty(aCEV[ni,1])
			////////////////////////////////////////////////////////////////////////////////////////////////////
			// Caso for Cliente VCF e esta no ultimo Cliente, limpar vetor aCEV para sair do While apos o FOR //
			////////////////////////////////////////////////////////////////////////////////////////////////////
			If lCliVCF .and. ni == len(aCEV)
				aCEV := {}
			EndIf
			////////////////////////////////////////////////////////////////////////////////////////////////////
		EndIf
		nREC++
		If nREC >= nRECT
			nREC := 0
			IncProc( ( STR0009 ) )
		EndIf
		If lA1_IBGE
			If cMun # Alltrim(aCEV[ni,13])
				cMun := Alltrim(aCEV[ni,13])
				nPos := 0
				nPos := aScan(aTemp,{|x| x[1] == cMun })
				If nPos > 0
					nPos := aTemp[nPos,2]
				Else
					nPos := 0
					nPos := aScan(aCidades,{|x| Alltrim(x[5]) == cMun })
					If nPos > 0
						Aadd(aTemp,{ cMun , nPos })
					EndIf
				EndIf
			EndIf
		EndIf
		If nPos > 0
			cNivImp := ""
			cSegCli := ""
			cGrupEcn:= ""
			lVCF := .f.
				cNivImp := aCEV[ni,26]
				VX5->(DbSeek(xFilial("VX5")+"033"+aCEV[ni,17]))
				cSegCli := aCEV[ni,17]+"-"+VX5->VX5_DESCRI
				lVCF := .t.
				cGrupEcn := Space(39)
				If lVCF_GRUECN
					VQK->(DbSeek(xFilial("VQK")+aCEV[ni,18]))
					cGrupEcn := left(VQK->VQK_CODIGO+" - "+VQK->VQK_DESCRI+space(39),39)
				Endif
			Aadd(aClientes,{ .f. ,;
							 .f. ,;
							 left(Transform(aCEV[ni,4],IIf(Len(Alltrim(aCEV[ni,4]))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+space(18),18) ,;
							 aCEV[ni,6] ,;
							 IIf(nPos>0,Alltrim(aCidades[nPos,2])+"-"+aCidades[nPos,3],"") ,;
							 left(IIf(nPos>0,aCidades[nPos,4]+" ","")+aCEV[ni,7]+space(13),13) ,;
							 left(Alltrim(aCEV[ni,8])+IIf(lNroEnd,", "+aCEV[ni,12],"")+space(42),42) ,;
							 aCEV[ni,9] ,;
							 Transform(aCEV[ni,10],"@R 99999-999") ,;
							 aCEV[ni,2] + aCEV[ni,3] ,;
							 lVCF ,;
							 left(cNivImp+" "+cSegCli+space(20),20) ,;
							 left(aCEV[ni,11]+space(42),42) ,;
							 IIf(lVCF,left(Transform(aCEV[ni,27],"@D"),6)+right(Transform(aCEV[ni,27],"@D"),2),space(8)) ,;
							 cGrupEcn ,;
							 aCEV[ni,19] ,;
							 aCEV[ni,20] ,;
							 aCEV[ni,21] ,;
							 IIf(lNewVend,aCEV[ni,22],"") ,;
							 IIf(lNewVend,aCEV[ni,23],"") ,;
							 IIf(lNewVend,aCEV[ni,24],"") ,;
							 IIf(!Empty(aCEV[ni,25]),left(X3CBOXDESC("VCF_CONDIC",aCEV[ni,25]),14),"") })
			For ny := 16 to 21
				If !Empty(aClientes[len(aClientes),ny])
					aClientes[len(aClientes),ny] += "-"+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+aClientes[len(aClientes),ny]+"' AND D_E_L_E_T_=' '"),20)
				EndIf
			Next
		EndIf
	Next

	DbSelectArea("SA1")
	DbSkip()
	If len(aClientes) == 0
		Aadd(aClientes,{ .f. , .f. , "" , "" , "" , "" , "" , "" , "" , "" , .f. , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" } )
	Else
		IncProc( ( STR0010 ) )
		aSort(aClientes,1,,{|x,y| x[5]+x[4] < y[5]+y[4] })
		cNomeCli := space(30)
	EndIf

	cVdAgenda := cVendedor

	aObjects := {}
	aAdd( aObjects, { 0 , 22 , .T. , .F. } ) // Topo
	aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
	aAdd( aObjects, { 0 , 80 , .T. , .F. } ) // Geracao de Agendas
	aPos := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg1 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0011+" ( "+STR0012+Alltrim(str(len(aClientes),9))+" )") OF oMainWnd PIXEL

	@ aPos[1,1]+001,aPos[1,2]+006 SAY STR0089 SIZE 75,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+010,aPos[1,2]+006 MSCOMBOBOX oTipPesq VAR cTipPesq ITEMS aTipPesq SIZE 35,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+010,aPos[1,2]+042 MSGET oNomeCli VAR cNomeCli PICTURE "@!" SIZE 55,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[1,1]+010,aPos[1,2]+098 BUTTON oPesqOK PROMPT (STR0090) OF oDlg1 SIZE 22,10 PIXEL ACTION (FS_PESQ_OK("Cli"))

	if VAI->(FieldPos("VAI_IMPCEV")) == 0 .or. VAI->VAI_IMPCEV <> "0" 
		@ aPos[1,1]+001,aPos[1,2]+134 SAY STR0091 SIZE 70,08 OF oDlg1 PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+010,aPos[1,2]+134 MSCOMBOBOX oTipCli VAR cTipCli ITEMS aTipCli SIZE 54,08 OF oDlg1 PIXEL COLOR CLR_BLUE
		@ aPos[1,1]+010,aPos[1,2]+190 BUTTON oImprRel PROMPT (STR0017) OF oDlg1 SIZE 36,10 PIXEL ACTION (VM5500018_imprime()) // Relatorio
		If ExistBlock("VCM550ETQ")
			@ aPos[1,1]+010,aPos[1,2]+230 BUTTON oImprEtq PROMPT (STR0018) OF oDlg1 SIZE 36,10 PIXEL ACTION ExecBlock("VCM550ETQ",.f.,.f.) // Etiquetas
		EndIf 
	Endif		
	
	@ aPos[2,1],aPos[2,2] LISTBOX oLbx1 FIELDS HEADER "1","2","3",STR0019,STR0020,(STR0021+IIf(cPess#STR0096," ( "+STR0095+": "+cPess+" )","")),STR0022,STR0023,STR0024,STR0025,STR0026,STR0113,STR0029+STR0108,STR0029+STR0085,STR0029+STR0084,STR0029+STR0109,STR0029+STR0110,STR0029+STR0114,RetTitle("VCF_CONDIC") COLSIZES 10,10,10,30,50,80,85,45,55,35,35,90,80,80,80,80,80,80,80 SIZE aPos[2,4]-2,aPos[2,3]-aPos[2,1] OF oDlg1 PIXEL ON DBLCLICK (aClientes[oLbx1:nAt,1] := !aClientes[oLbx1:nAt,1]) ON CHANGE(FS_CADAGEND(aClientes[oLbx1:nAt,10]),oLbx1:SetFocus())
	oLbx1:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcar:=!lMarcar , FS_TIK( "aClientes" , lMarcar ) ) ,Nil) , }
	oLbx1:SetArray(aClientes)
	oLbx1:bLine := { || {IIf(aClientes[oLbx1:nAt,1],oOk,oNo),;
	IIf(aClientes[oLbx1:nAt,2],oVo,oNo),;
	IIf(aClientes[oLbx1:nAt,11],oVe,oNo),;
	substr(aClientes[oLbx1:nAt,10],1,6)+"-"+substr(aClientes[oLbx1:nAt,10],7,2),;
	aClientes[oLbx1:nAt,3],;
	aClientes[oLbx1:nAt,4],;
	aClientes[oLbx1:nAt,5],;
	aClientes[oLbx1:nAt,6],;
	aClientes[oLbx1:nAt,7],;
	aClientes[oLbx1:nAt,8],;
	aClientes[oLbx1:nAt,9],;
	aClientes[oLbx1:nAt,15],;
	aClientes[oLbx1:nAt,17],;
	aClientes[oLbx1:nAt,18],;
	aClientes[oLbx1:nAt,16],;
	aClientes[oLbx1:nAt,19],;
	aClientes[oLbx1:nAt,20],;
	aClientes[oLbx1:nAt,21],;
	aClientes[oLbx1:nAt,22]}}
	
	@ aPos[3,1]+009,aPos[3,2]+007 SAY STR0027 SIZE 25,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[3,1]+008,aPos[3,2]+040 MSGET oTpAgenda VAR cTpAgenda PICTURE "!" F3 "VC5" VALID FS_VAL_VCM550("TP") SIZE 15,08 OF oDlg1 PIXEL COLOR CLR_BLUE

	@ aPos[3,1]+009,aPos[3,2]+102 SAY STR0028 SIZE 20,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[3,1]+008,aPos[3,2]+135 MSGET oDtAgenda VAR dDtAgenda PICTURE "@D" VALID FS_VAL_VCM550("DT") SIZE 42,08 OF oDlg1 PIXEL COLOR CLR_BLUE

	@ aPos[3,1]+020,aPos[3,2]+102 SAY STR0029 SIZE 27,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[3,1]+019,aPos[3,2]+135 MSGET oVdAgenda VAR cVdAgenda PICTURE "@!" F3 "SA3" VALID (cVendedor:=cVdAgenda,FS_VAL_VCM550("EV")) SIZE 42,08 OF oDlg1 PIXEL COLOR CLR_BLUE

	@ aPos[3,1]+022,aPos[3,2]+007 SAY STR0104 SIZE 27,08 OF oDlg1 PIXEL COLOR CLR_BLUE // Objetivo:
	@ aPos[3,1]+031,aPos[3,2]+004 GET oObjetiv VAR cObjetiv OF oDlg1 MEMO SIZE 182,030 PIXEL

	@ aPos[3,1]+065,aPos[3,2]+007 SAY STR0030 SIZE 35,08 OF oDlg1 PIXEL COLOR CLR_BLUE
	@ aPos[3,1]+064,aPos[3,2]+040 MSCOMBOBOX oFcAgenda VAR cFcAgenda ITEMS aItAgenda SIZE 23,08 OF oDlg1 PIXEL COLOR CLR_BLUE

	@ aPos[3,1]+064,aPos[3,2]+120 BUTTON oAgendar PROMPT STR0033 OF oDlg1 SIZE 55,10 PIXEL ACTION (FS_AGEND_GERA(),oLbx2:SetFocus(),oLbx1:SetFocus())

	@ aPos[3,1]+001,aPos[3,2]+195 LISTBOX oLbx2 FIELDS HEADER " ",STR0034,STR0035,STR0036,STR0037 COLSIZES 10,70,40,40,70 SIZE aPos[3,4]-197,077 OF oDlg1 PIXEL
	oLbx2:SetArray(aAgenda)
	oLbx2:bLine := { || {IIf(aAgenda[oLbx2:nAt,1],oVo,oVe),;
	aAgenda[oLbx2:nAt,2],;
	aAgenda[oLbx2:nAt,3],;
	aAgenda[oLbx2:nAt,4],;
	aAgenda[oLbx2:nAt,5]}}

	@ aPos[3,1]+000,aPos[3,2] TO aPos[3,1]+078,194 LABEL STR0033 OF oDlg1 PIXEL

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{ || oDlg1:End() }, { || oDlg1:End() },,)

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PESQ_OK³ Autor ³  Andre Luis Almeida  ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa pelo Nome da Cidade, do Cliente e Cod.Cliente     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQ_OK(cTp)
Local nPos := 0
If cTp == "Cid"
	nPos := aScan(aCidades,{|x| left(x[2],len(Alltrim(cNomeCid))) == Alltrim(cNomeCid) })
ElseIf cTp == "Cli"
	If !Empty(Alltrim(cNomeCli))
		If cTipPesq == STR0086
			aSort(aClientes,1,,{|x,y| x[4] < y[4] }) // Ordenar pelo "Nome"
			nPos := aScan(aClientes,{|x| left(x[4],len(Alltrim(cNomeCli))) == Alltrim(cNomeCli) })
		Else
			aSort(aClientes,1,,{|x,y| x[10] < y[10] }) // Ordenar pelo "Codigo"
			nPos := aScan(aClientes,{|x| left(x[10],len(Alltrim(cNomeCli))) == Alltrim(cNomeCli) })
		EndIf
	Else
		aSort(aClientes,1,,{|x,y| x[5]+x[4] < y[5]+y[4] }) // Ordenar pela "Cidade + Nome"
		nPos := aScan(aClientes,{|x| left(x[4],len(Alltrim(cNomeCli))) == Alltrim(cNomeCli) })
	EndIf
EndIf
If nPos == 0
	nPos := 1
EndIf
oLbx1:nAt := nPos
oLbx1:SetFocus()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERCIDAD³ Autor ³  Andre Luis Almeida  ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta vetor com as cidades selecionadas p/carregar clientes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERCIDAD()
Local ni := 0
Local lRet := .f.
Local aTemp := {}
For ni := 1 to Len(aCidades)
	If aCidades[ni,1] .and. !Empty(Alltrim(aCidades[ni,2]))
		Aadd(aTemp,{ .t. , aCidades[ni,2] , aCidades[ni,3] , aCidades[ni,4] , aCidades[ni,5] } )
		lRet := .t.
	EndIf
Next
If lRet
	nOK := 1
	aCidades := {}
	aCidades := aClone(aTemp)
Else
	MsgAlert(STR0081,STR0082)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CADAGEND³ Autor ³  Andre Luis Almeida  ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta vetor com as cidades selecionadas p/carregar clientes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CADAGEND(cCodCli)
Local cQAlAge := "SQLVC1"
aAgenda:={}
cQuery := "SELECT VC1.VC1_DATVIS , VC1.VC1_TIPAGE , VC1.VC1_DATAGE , VC1.VC1_CODVEN , VC5.VC5_DTPAGE , SA3.A3_NOME "
cQuery += "FROM "+RetSqlName("VC1")+" VC1 , "+RetSqlName("VC5")+" VC5 , "+RetSqlName("SA3")+" SA3 "
cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_CODCLI='"+left(cCodCli,SA1->(TamSx3("A1_COD")[1]))+"' AND VC1.VC1_LOJA='"+right(cCodCli,SA1->(TamSx3("A1_LOJA")[1]))+"' AND "
cQuery += "VC5.VC5_FILIAL='"+xFilial("VC5")+"' AND VC1.VC1_TIPAGE=VC5.VC5_TIPAGE AND "
cQuery += "SA3.A3_FILIAL='"+xFilial("SA3")+"' AND VC1.VC1_CODVEN=SA3.A3_COD AND "
cQuery += "VC1.D_E_L_E_T_=' ' AND VC5.D_E_L_E_T_=' ' AND SA3.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAge , .F., .T. )
Do While !( cQAlAge )->( Eof() )
	Aadd(aAgenda,{ IIf(!Empty(( cQAlAge )->( VC1_DATVIS )),.t.,.f.) , ( cQAlAge )->( VC1_TIPAGE )+" - "+left(( cQAlAge )->( VC5_DTPAGE ),12) , left(Transform(stod(( cQAlAge )->( VC1_DATAGE )),"@D"),6)+right(Transform(stod(( cQAlAge )->( VC1_DATAGE )),"@D"),2) , left(Transform(stod(( cQAlAge )->( VC1_DATVIS )),"@D"),6)+right(Transform(stod(( cQAlAge )->( VC1_DATVIS )),"@D"),2) , ( cQAlAge )->( VC1_CODVEN )+" - "+( cQAlAge )->( A3_NOME ) } )
	( cQAlAge )->( DbSkip() )
EndDo
( cQAlAge )->( dbCloseArea() )
If Len(aAgenda) == 0
	Aadd(aAgenda,{ .f. , " " , "  /  /  " , "  /  /  " , " " } )
EndIf
aSort(aAgenda,1,,{|x,y| ctod(x[4])+ctod(x[3]) < ctod(y[4])+ctod(y[3]) })
oLbx2:nAt := 1
oLbx2:SetArray(aAgenda)
oLbx2:bLine := { || {IIf(aAgenda[oLbx2:nAt,1],oVo,oVe),;
aAgenda[oLbx2:nAt,2],;
aAgenda[oLbx2:nAt,3],;
aAgenda[oLbx2:nAt,4],;
aAgenda[oLbx2:nAt,5]}}
oLbx2:SetFocus()
oLbx2:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VAL_VCM550³ Autor ³ Andre Luis Almeida ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes ( Tipo de Agenda / Vendedor / Data / Regiao )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VAL_VCM550(cTipo)
Local cQuery  := ""
Local cQAlVAM := "SQLVAM"
Local lRet := .f.
If cTipo == "TP"		// Verifica Tipo de Agenda
	DbSelectArea("VC5")
	DbSetOrder(1)
	If DbSeek( xFilial("VC5") + Alltrim(cTpAgenda) , .f. )
		lRet := .t.
	EndIf
ElseIf cTipo == "EV"	// Verifica Vendedor
	DbSelectArea("SA3")
	DbSetOrder(1)
	If Alltrim(cVendedor)=="*" .or. DbSeek( xFilial("SA3") + Alltrim(cVendedor) , .f. )
		lRet := .t.
	EndIf
ElseIf cTipo == "DT"	// Verifica Data da Agenda
	If dDtAgenda >= dDataBase .or. Empty(dDtAgenda)
		lRet := .t.
	EndIf
Else	// Verifica Regiao
	DbSelectArea("VCB")
	DbSetOrder(1)
	If DbSeek( xFilial("VCB") + cRegiao , .f. ) .or. Empty(Alltrim(cRegiao))
		lRet  := .t.
		aCidades := {}
		cQuery := "SELECT VAM.VAM_DESCID , VAM.VAM_ESTADO , VAM.VAM_DDD , VAM.VAM_IBGE FROM "+RetSqlName("VAM")+" VAM "
		cQuery += "WHERE VAM.VAM_FILIAL='"+xFilial("VAM")+"' AND "
		If !Empty(Alltrim(cRegiao))
			cQuery += "VAM.VAM_REGIAO='"+cRegiao+"' AND "
		EndIf
		cQuery += "VAM.D_E_L_E_T_=' ' ORDER BY VAM.VAM_DESCID , VAM.VAM_ESTADO "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAM , .F., .T. )
		While !( cQAlVAM )->( Eof() )
			Aadd(aCidades,{ lMarcar , ( cQAlVAM )->( VAM_DESCID ) , ( cQAlVAM )->( VAM_ESTADO ) , ( cQAlVAM )->( VAM_DDD ) , ( cQAlVAM )->( VAM_IBGE ) } )
			( cQAlVAM )->( DbSkip() )
		EndDo
		( cQAlVAM )->( dbCloseArea() )
		If len(aCidades) == 0
			Aadd(aCidades,{ .f. , " " , " " , " " , " " } )
		EndIf
		nTotCid:= len(aCidades)
		If cTipo == "ATUAL" // Atualiza vetor com as Cidades da(s) Regiao(oes)
			oLbx1:nAt := 1
			oLbx1:SetArray(aCidades)
			oLbx1:bLine := { || {IIf(aCidades[oLbx1:nAt,1],oOk,oNo),;
			aCidades[oLbx1:nAt,2],;
			aCidades[oLbx1:nAt,3],;
			aCidades[oLbx1:nAt,4]}}
			oLbx1:Refresh()
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AGEND_GERA³ Autor ³ Andre Luis Almeida ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de Agenda CEV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AGEND_GERA()
Local ni        := 0
Local lRet      := .f.
Local lRett     := .f.
Local cMensagem := STR0070+Transform(dDtAgenda,"@D")+", "+STR0071+cVdAgenda+STR0072
Local nTCodCli  := SA1->(TamSx3("A1_COD")[1])
Local nTLojCli  := SA1->(TamSx3("A1_LOJA")[1])
If !Empty(cTpAgenda)
	If !Empty(cVdAgenda)
		If !Empty(dDtAgenda)
			lRet:= .t.
		EndIf
	EndIf
EndIf
If lRet
	For ni := 1 to Len(aClientes)
		If aClientes[ni,1]
			lRett := .t.
		EndIf
	Next
	If lRett
		For ni := 1 to Len(aClientes)
			If aClientes[ni,1]
				// Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente //
				If VCM510VAL("1",cVdAgenda,cTpAgenda,left(aClientes[ni,10],nTCodCli),right(aClientes[ni,10],nTLojCli),dDataBase,"","")
					lRett := .t.
				Else
					If MsgYesNo(STR0106,STR0082) // Deseja desmarcar a Agenda não permitida? / Atencao
						aClientes[ni,1] := .f.
					EndIf
					lRett := .f.
					Exit
				EndIf
			EndIf
		Next
	Else
		MsgAlert(STR0074,STR0082)
		oTpAgenda:SetFocus()
	EndIf
	If lRett
		If MSGYESNO(cMensagem)
			For ni := 1 to Len(aClientes)
				If aClientes[ni,1]
					aClientes[ni,1] := .f.
					If ML500IVal(cTpAgenda,left(aClientes[ni,10],nTCodCli),right(aClientes[ni,10],nTLojCli))
						aClientes[ni,2] := .t.
						FS_AGENDA(cTpAgenda,dDtAgenda,cVdAgenda,left(aClientes[ni,10],nTCodCli),right(aClientes[ni,10],nTLojCli),"","",IIf(cFcAgenda==STR0031,"0","1"),cObjetiv,"","")
					EndIf
				EndIf
			Next
			cObjetiv := ""
			oObjetiv:Refresh()
			MsgInfo(STR0073,STR0082)
			FS_CADAGEND(aClientes[oLbx1:nAt,10])
			oLbx1:SetFocus()
		EndIf
	EndIf
Else
	MsgAlert(STR0075,STR0082)
	oTpAgenda:SetFocus()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK      ³ Autor ³ Andre Luis Almeida ³ Data ³ 17/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ TIK nos ListBox ( Cidades / Clientes )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK( cTipo , lMarcar )
Local ni := 0
Default lMarcar := .f.
If cTipo == "aCidades"
	For ni := 1 to Len(aCidades)
		If lMarcar
			aCidades[ni,1] := .t.
		Else
			aCidades[ni,1] := .f.
		EndIf
	Next
ElseIf cTipo == "aClientes"
	For ni := 1 to Len(aClientes)
		If lMarcar
			aClientes[ni,1] := .t.
		Else
			aClientes[ni,1] := .f.
		EndIf
	Next
EndIf
oLbx1:SetFocus()
oLbx1:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    VM5500018_imprime Autor ³ Matheus Teixeira ³ Data ³ 10/12/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao dos Clientes                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VM5500018_imprime()
	Local cAlias	 := "SA1"
	Local lOk      := .f.
	Private cCEPIni  := space(8)
	Private cCEPFin  := "99999999"
	Private lNomCli  := .t.
	Private lEndCli  := .f.
	Private lPerCli  := .f.
	Private lConCli  := .f.
	Private lFroCli  := .f.
	Private lAgeCli  := .f.
	Private nLin 	 := 1
	Private aReturn  := { STR0093 , 1 , STR0094 , 1 , 2 , 1 , "" , 1 }
	Private cTamanho := "G"           // P/M/G
	Private Limite   := 220            // 80/132/220
	Private aOrdem   := {}            // Ordem do Relatorio
	Private cTitulo  := STR0041
	Private cNomProg := "VEICM550"
	Private cNomeRel := "VEICM550"
	Private nLastKey := 0
	Private cabec1   := STR0083
	Private cabec2   := ""
	Private nCaracter:=15
	Private m_Pag    := 1
	Private lAbortPrint := .f.
	Private nTotFroC := 0
	Private nTotFroT := 0
	Private nTotCli  := 0
	Private aOrdRel  := {(STR0042),(STR0043),(STR0092)}
	Private cOrdRel  := (STR0042)
	Private cAgendas  := space(30)
	//
	nT := val(left(cTipCli,1))
	If nT == 3
		nT := 11
	EndIf
	cT	:= IIf(nT==1,STR0038,IIf(nT==2,STR0039,STR0040))
	//
	ProcRegua( 3 )
	IncProc( ( STR0044 ) )

	aResumo := {}

	DEFINE MSDIALOG oDlg3 FROM 000,000 TO 017,044 TITLE STR0045+cT OF oMainWnd
	DEFINE SBUTTON FROM 030,135 TYPE 1 ACTION (lOk:=.t.,oDlg3:End()) ENABLE OF oDlg3
	@ 014,010 CHECKBOX oNomCli VAR lNomCli PROMPT STR0046 OF oDlg3 SIZE 150,08 PIXEL COLOR CLR_BLUE WHEN .f.
	@ 024,010 CHECKBOX oEndCli VAR lEndCli PROMPT STR0047 OF oDlg3 SIZE 130,08 PIXEL COLOR CLR_BLUE
	@ 034,010 CHECKBOX oAgeCli VAR lAgeCli PROMPT STR0048 OF oDlg3 SIZE 130,08 PIXEL COLOR CLR_BLUE
	@ 044,010 CHECKBOX oFroCli VAR lFroCli PROMPT STR0049 OF oDlg3 SIZE 130,08 PIXEL COLOR CLR_BLUE
	@ 054,010 CHECKBOX oConCli VAR lConCli PROMPT STR0105 OF oDlg3 SIZE 130,08 PIXEL COLOR CLR_BLUE // Pessoas de Contato
	@ 064,010 CHECKBOX oPerCli VAR lPerCli PROMPT (STR0107+" / "+STR0037) OF oDlg3 SIZE 130,08 PIXEL COLOR CLR_BLUE // Periodicidade  /  Vendedor
	@ 078,010 SAY STR0050 OF oDlg3 SIZE 30,10 PIXEL COLOR CLR_BLUE
	@ 077,036 MSCOMBOBOX oOrdRel VAR cOrdRel ITEMS aOrdRel SIZE 110,08 OF oDlg3 PIXEL COLOR CLR_BLUE
	@ 091,010 SAY (STR0078+" "+STR0079) OF oDlg3 SIZE 30,10 PIXEL COLOR CLR_BLUE
	@ 090,036 MSGET oCEPIni VAR cCEPIni PICTURE "@R 99999-999" SIZE 20,08 OF oDlg3 PIXEL COLOR CLR_BLUE
	@ 091,080 SAY STR0080 OF oDlg3 SIZE 30,10 PIXEL COLOR CLR_BLUE
	@ 090,095 MSGET oCEPFin VAR cCEPFin PICTURE "@R 99999-999" SIZE 20,08 OF oDlg3 PIXEL COLOR CLR_BLUE
	@ 104,010 SAY (STR0103) OF oDlg3 SIZE 150,10 PIXEL COLOR CLR_BLUE // Tipos de Agenda da Ultima Visita/Abordagem
	@ 103,120 MSGET oAgendas VAR cAgendas PICTURE "@!" SIZE 45,08 OF oDlg3 PIXEL COLOR CLR_BLUE
	@ 004,005 TO 122,171 LABEL STR0051+cT OF oDlg3 PIXEL
	ACTIVATE MSDIALOG oDlg3 CENTER

	If lOk

		cCEPIni := Transform(cCEPIni,"@R 99999-999")
		cCEPFin := Transform(cCEPFin,"@R 99999-999")

		If cOrdRel == STR0042
			aSort(aClientes,1,,{|x,y| x[5]+x[4] < y[5]+y[4] }) // "Cidade + Nome"
		ElseIf cOrdRel == STR0043
			aSort(aClientes,1,,{|x,y| x[5]+x[9]+x[7] < y[5]+y[9]+y[7] }) // "Cidade + CEP + Endereco"
		Else
			aSort(aClientes,1,,{|x,y| x[5]+x[8]+x[7] < y[5]+y[8]+y[7] }) // "Cidade + Bairro + Endereco"
		EndIf

		If ExistBlock("VCM550IC") // IMPRESSAO CUSTOMIZADA
			ExecBlock("VCM550IC",.f.,.f.,{ cT })
		Else
			IncProc( ( STR0052+cT+"..." ) )
			oReport := ReportDef(cT)
		EndIf
		
		If cOrdRel # STR0042
			aSort(aClientes,1,,{|x,y| x[5]+x[4] < y[5]+y[4] }) // Voltar Ordem para: "Cidade + Nome"
		EndIf

	EndIf

Return

Static Function ReportDef(cTitulo)
	Local oReport
	oReport := TReport():New("VEICM550", cTitulo,, {|oReport| PrintReport(oReport)}, STR0041)

	oSection:= TRSection():New(oReport, "DADOS CLIENTE" , {"SA1"}, NIL, .F., .T.,,.F.,,,,,,.F.)
	TRCell():New(oSection,"CLIENTE"   	,"",STR0115	   	,"@!",60,/*lPixel*/, /*bBlock*/,"LEFT" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )
	TRCell():New(oSection,"CPF_CNPJ"   	,"",STR0116     ,"@!",30,/*lPixel*/,/*bBlock*/,"CENTER" ,/*lLineBreak*/ ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )
	TRCell():New(oSection,"CIDADE_UF" 	,"",STR0117     ,"@!",30,/*lPixel*/, /*bBlock*/,"CENTER" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. ) 
	TRCell():New(oSection,"ULT_VISIT" 	,"",STR0118		,"@!",60,/*lPixel*/, /*bBlock*/,"CENTER" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )
	TRCell():New(oSection,"FONE" 		,"",STR0119     ,"@!",20,/*lPixel*/, /*bBlock*/,"CENTER" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )
	TRCell():New(oSection,"NI_SEGMENTO" ,"",STR0120     ,"@!",10,/*lPixel*/, /*bBlock*/,"CENTER" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )
	TRCell():New(oSection,"EMAIL" 		,"",STR0121     ,"@!",20,/*lPixel*/, /*bBlock*/,"CENTER" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )
	TRCell():New(oSection,"CAD_ABD" 	,"",STR0122     ,"@!",10,/*lPixel*/, /*bBlock*/,"CENTER" ,.T. ,/*cHeaderAlign*/ ,/*lCellBreak*/ ,/*nColSpace*/ ,.T. )              

	oReport:PrintDialog()			// Mostra Tela para Configuração do Relatório

Return(oReport)

Static Function PrintReport(oReport)
	Local oSection 	:= oReport:Section(1)
	Local ni       := 0
	Local cDtVisit := ""

	For ni:=1 to Len(aClientes)
		If aClientes[ni,nT] .and. ( aClientes[ni,9] >= cCEPIni .and. aClientes[ni,9] <= cCEPFin )
			nTotCli++
			cDtVisit := space(39)
			DbSelectArea("VC1")
			DbSetOrder(7)
			DbSeek(xFilial("VC1")+ aClientes[ni,10] + "9999" ,.T.)
			If !Bof() .and. ( VC1->VC1_CODCLI+VC1->VC1_LOJA # aClientes[ni,10] )
				DbSelectArea("VC1")
				DbSkip(-1)
			EndIf
			
			While !Bof() .and. VC1->VC1_FILIAL == xFilial("VC1") .and. ( VC1->VC1_CODCLI+VC1->VC1_LOJA == aClientes[ni,10] )
				If Empty(cAgendas) .or. VC1->VC1_TIPAGE $ cAgendas
					If !Empty(VC1->VC1_DATVIS)
						cDtVisit := left(Transform(VC1->VC1_DATVIS,"@D"),6)+right(Transform(VC1->VC1_DATVIS,"@D"),2)
						cDtVisit += " "+Transform(dDataBase-VC1->VC1_DATVIS,"@E 99999")
						SA3->(DbSetOrder(1))
						SA3->(MsSeek(xFilial("SA3")+VC1->VC1_CODVEN))
						cDtVisit += " "+VC1->VC1_CODVEN+"-"+left(SA3->A3_NOME,17)
						Exit
					EndIf
				EndIf
				DbSelectArea("VC1")
				DbSkip(-1)
			EndDo
			
			oSection:Init()
			oSection:Cell("CLIENTE"):SetValue(IIf(aClientes[ni,11],"* ","  ")+left(left(aClientes[ni,10],SA1->(TamSx3("A1_COD")[1]))+"-"+right(aClientes[ni,10],SA1->(TamSx3("A1_LOJA")[1]))+" "+aClientes[ni,4],40))   
			oSection:Cell("CPF_CNPJ"):SetValue(aClientes[ni,03])
			oSection:Cell("CIDADE_UF"):SetValue(aClientes[ni,05])
			oSection:Cell("ULT_VISIT"):SetValue(cDtVisit)
			oSection:Cell("FONE"):SetValue(aClientes[ni,06])
			oSection:Cell("NI_SEGMENTO"):SetValue(aClientes[ni,12])
			oSection:Cell("EMAIL"):SetValue(aClientes[ni,13])
			oSection:Cell("CAD_ABD"):SetValue(aClientes[ni,14])
			oSection:Printline()

			If lAgeCli
				VM5500038_imprimeAgenda(aClientes[ni,10],oReport)
				oReport:SkipLine()
			EndIf
			If lFroCli
				VM5500048_imprimeFrota(aClientes[ni,10],oReport)
				oReport:SkipLine()
			EndIf
			oReport:SkipLine()
			If lConCli
				VM5500058_imprimeConta(aClientes[ni,10],oReport)
				oReport:SkipLine()
			EndIf
			If lPerCli
				VM5500068_imprimePeriodicidade(aClientes[ni,10],oReport)
				oReport:SkipLine()
			EndIf
			oReport:SkipLine()
			oReport:ThinLine()
			oReport:SkipLine()
		EndIf
	Next
		oSection:Finish()	
		IncProc( ( STR0054+cT+"..." ) )
		
		oReport:SkipLine()
		oReport:PrintText(STR0055,oReport:Row(),0200)
		
		If !Empty(Alltrim(cRegiao))
			oReport:SkipLine()
			oReport:PrintText(STR0056+cRegiao+"..............................................:" + str(nTotCid,8),oReport:Row(),0270)
		Else
			oReport:SkipLine()
			oReport:PrintText(STR0057+"..............................................:" + str(nTotCid,8),oReport:Row(),0270)
		EndIf

		oReport:SkipLine()
		oReport:PrintText(STR0058 + str(len(aCidades),8),oReport:Row(),0270)
		oReport:SkipLine()
		oReport:PrintText(STR0059 + str(len(aClientes),8),oReport:Row(),0270)
		oReport:SkipLine()
		oReport:PrintText(STR0060 + left(cT+repl(".",13),13)+".............................................:" + str(nTotCli,8),oReport:Row(),0270)
		oReport:SkipLine()
		oReport:PrintText( STR0060 + left(cT+STR0061+repl(".",23),23)+"...................................:" + Str(nTotFroC,8),oReport:Row(),0270)
		oReport:SkipLine()
		oReport:PrintText(STR0062 + left(cT+repl(".",13),13)+"...................................:" + Str(nTotFroT,8),oReport:Row(),0270)

		If lFroCli .and. Len(aResumo) > 0
			aSort(aResumo,1,,{|x,y| x[2]+x[1] < y[2]+y[1] })
			For ni:=1 to Len(aResumo)
				oReport:SkipLine()
				oReport:PrintText(aResumo[ni,1]+aResumo[ni,2]+" "+str(aResumo[ni,3],8),oReport:Row(),0320)
			Next
		EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao VM5500038_imprimeAgenda Autor ³Matheus Teixeira ³ Data ³ 10/12/20³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao agenda        			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VM5500038_imprimeAgenda(cSeek,oReport)
Local lImpCab := .t.
Local cQAlAge := "SQLVC1"
cQuery := "SELECT VC1.VC1_DATVIS , VC1.VC1_TIPAGE , VC1.VC1_DATAGE , VC1.VC1_CODVEN , VC5.VC5_DTPAGE , SA3.A3_NOME "
cQuery += "FROM "+RetSqlName("VC1")+" VC1 , "+RetSqlName("VC5")+" VC5 , "+RetSqlName("SA3")+" SA3 "
cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND VC1.VC1_CODCLI='"+left(cSeek,SA1->(TamSx3("A1_COD")[1]))+"' AND VC1.VC1_LOJA='"+right(cSeek,SA1->(TamSx3("A1_LOJA")[1]))+"' AND "
cQuery += "VC5.VC5_FILIAL='"+xFilial("VC5")+"' AND VC1.VC1_TIPAGE=VC5.VC5_TIPAGE AND "
cQuery += "SA3.A3_FILIAL='"+xFilial("SA3")+"' AND VC1.VC1_CODVEN=SA3.A3_COD AND "
cQuery += "VC1.D_E_L_E_T_=' ' AND VC5.D_E_L_E_T_=' ' AND SA3.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAge , .F., .T. )
Do While !( cQAlAge )->( Eof() )
	If lImpCab
		lImpCab := .f.
		oReport:SkipLine()
		oReport:PrintText(STR0063,oReport:Row(),0440)
	EndIf
	If Empty(( cQAlAge )->( VC1_DATVIS ))
		oReport:SkipLine()
		oReport:PrintText(( cQAlAge )->( VC1_TIPAGE ) +" - "+ left(( cQAlAge )->( VC5_DTPAGE ),12)+"  "+left(Transform(stod(( cQAlAge )->( VC1_DATAGE )),"@D"),6)+right(Transform(stod(( cQAlAge )->( VC1_DATAGE )),"@D"),2)+"   "+( cQAlAge )->( VC1_CODVEN)+" - "+( cQAlAge )->( A3_NOME ),oReport:Row(),0520)
	EndIf
	( cQAlAge )->( DbSkip() )
EndDo
( cQAlAge )->( dbCloseArea() )
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao VM5500048_imprimeFrota Autor ³Matheus Teixeira ³ Data ³ 10/12/20³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao FROTA        			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VM5500048_imprimeFrota(cSeek,oReport)
Local nPos := 0
Local cQAlFro := "SQLVC3"
Local lImpCab := .T.
cQuery := "SELECT VC3.VC3_QTDFRO , VC3.VC3_CODMAR , VC3.VC3_MODVEI , VC3.VC3_FABMOD, VC3.VC3_DATATU FROM "+RetSqlName("VC3")+" VC3 "
cQuery += "WHERE VC3.VC3_FILIAL='"+xFilial("VC3")+"' AND VC3.VC3_CODCLI='"+substr(cSeek,1,6)+"' AND VC3.VC3_LOJA='"+substr(cSeek,7,2)+"' AND VC3.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlFro , .F., .T. )
If !( cQAlFro )->( Eof() )
	nFroCli := 0
	Do While !( cQAlFro )->( Eof() )
		If lImpCab
			lImpCab := .f.
			oReport:SkipLine()
			oReport:PrintText(STR0064,oReport:Row(),0440)
		EndIf
		If lFroCli
			oReport:SkipLine()
			oReport:PrintText(Str(( cQAlFro )->( VC3_QTDFRO ),3)+" "+( cQAlFro )->( VC3_CODMAR )+" "+substr(( cQAlFro )->( VC3_MODVEI ),1,20)+" "+Posicione("VV2",1,xFilial("VV2")+( cQAlFro )->( VC3_CODMAR )+( cQAlFro )->( VC3_MODVEI ),"VV2_DESMOD")+" "+Transform(( cQAlFro )->( VC3_FABMOD ),"@R 9999/9999")+" "+DtoC(Stod(( cQAlFro )->( VC3_DATATU ))),oReport:Row(),0520)
			nPos := 0
			nPos := ascan(aResumo,{|x| x[1]+x[2] ==  ( cQAlFro )->( VC3_CODMAR )+" "+substr(( cQAlFro )->( VC3_MODVEI ),1,20)+" "+VV2->VV2_DESMOD+" "+Transform(( cQAlFro )->( VC3_FABMOD ),"@R 9999/9999") })
			If nPos == 0
				Aadd(aResumo,{ ( cQAlFro )->( VC3_CODMAR )+" "+substr(( cQAlFro )->( VC3_MODVEI ),1,20)+" "+VV2->VV2_DESMOD+" " , Transform(( cQAlFro )->( VC3_FABMOD ),"@R 9999/9999") , ( cQAlFro )->( VC3_QTDFRO ) } )
			Else
				aResumo[nPos,3] += ( cQAlFro )->( VC3_QTDFRO )
			Endif
		EndIf
		nFroCli += ( cQAlFro )->( VC3_QTDFRO )
		( cQAlFro )->( DbSkip() )
	EndDo
	nTotFroC++
	nTotFroT += nFroCli
	If lFroCli
		oReport:SkipLine()
		oReport:PrintText(STR0065 + Str(nFroCli,4),oReport:Row(),0440)		
	EndIf
EndIf
( cQAlFro )->( dbCloseArea() )
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao VM5500058_imprimeConta Autor ³Matheus Teixeira ³ Data ³ 10/12/20³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao conta        			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VM5500058_imprimeConta(cSeek,oReport)
Local cQAlCon := "SQLVC2"
Local cImpres := left(STR0105+":"+space(22),22)
cQuery := "SELECT VC2.VC2_NOMCON , VC2.VC2_CARCON , VC2.VC2_ASSUNT , VC2.VC2_DDDCEL , VC2.VC2_TELCEL , VC2.VC2_EMAILC FROM "+RetSqlName("VC2")+" VC2 "
cQuery += "WHERE VC2.VC2_FILIAL='"+xFilial("VC2")+"' AND VC2.VC2_CODCLI='"+left(cSeek,SA1->(TamSx3("A1_COD")[1]))+"' AND VC2.VC2_LOJA='"+right(cSeek,SA1->(TamSx3("A1_LOJA")[1]))+"' AND VC2.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlCon , .F., .T. )
If !( cQAlCon )->( Eof() )
	Do While !( cQAlCon )->( Eof() )
		oReport:SkipLine()
		oReport:PrintText(cImpres+( cQAlCon )->( VC2_NOMCON )+"  -  "+( cQAlCon )->( VC2_CARCON )+space(8)+" ( "+left(X3CBOXDESC("VC2_ASSUNT",( cQAlCon )->( VC2_ASSUNT ))+" ) "+space(30),30)+"  "+left(Alltrim(( cQAlCon )->( VC2_DDDCEL ))+" "+( cQAlCon )->( VC2_TELCEL )+space(40),40)+( cQAlCon )->( VC2_EMAILC ),oReport:Row(),0120)
		cImpres := space(22)
		( cQAlCon )->( DbSkip() )
	EndDo
EndIf
( cQAlCon )->( dbCloseArea() )
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao VM5500068_imprimePeriodicidade Autor ³Matheus Teixeira ³ Data ³ 10/12/20³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Impressao periodicidade			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VM5500068_imprimePeriodicidade(cSeek,oReport)
Local lNewVend := ( VCF->(FieldPos("VCF_VENVEU")) > 0 ) // Possui campos novos Vendedores
Local cQAlPer  := "SQLVCF"
Local cImpres  := left(STR0107+":"+space(18),18)
cQuery := "SELECT VCF.VCF_VENPEC , VCF.VCF_DIAPEP , VCF.VCF_VENVEI , VCF.VCF_DIAPER , VCF.VCF_VENSRV , VCF.VCF_DIAPES "
If lNewVend
	cQuery += " , VCF.VCF_VENVEU , VCF.VCF_DIAVEU  , VCF.VCF_VENPNE , VCF.VCF_DIAPNE  , VCF.VCF_VENOUT , VCF.VCF_DIAOUT "
EndIf
cQuery += "FROM "+RetSqlName("VCF")+" VCF "
cQuery += "WHERE VCF.VCF_FILIAL='"+xFilial("VCF")+"' AND VCF.VCF_CODCLI='"+left(cSeek,SA1->(TamSx3("A1_COD")[1]))+"' AND VCF.VCF_LOJCLI='"+right(cSeek,SA1->(TamSx3("A1_LOJA")[1]))+"' AND VCF.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlPer , .F., .T. )
If !( cQAlPer )->( Eof() )
	If cVend == STR0099 .or. cVend == STR0085 // Todos ou Oficina
		If ( cQAlPer )->( VCF_DIAPES ) > 0 .or. !Empty(( cQAlPer )->( VCF_VENSRV ))
			oReport:SkipLine()
			oReport:PrintText(cImpres+left(STR0085+space(13),13)+" "+right(str(( cQAlPer )->( VCF_DIAPES )),3)+" "+STR0111+"  "+STR0037+": "+( cQAlPer )->( VCF_VENSRV )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlPer )->( VCF_VENSRV )+"' AND D_E_L_E_T_=' '"),20),oReport:Row(),0100)
		EndIf
	EndIf
	If cVend == STR0099 .or. cVend == STR0068 // Todos ou Pecas
		If ( cQAlPer )->( VCF_DIAPEP ) > 0 .or. !Empty(( cQAlPer )->( VCF_VENPEC ))
			oReport:SkipLine()
			oReport:PrintText(cImpres+left(STR0108+space(13),13)+" "+right(str(( cQAlPer )->( VCF_DIAPEP )),3)+" "+STR0111+"  "+STR0037+": "+( cQAlPer )->( VCF_VENPEC )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlPer )->( VCF_VENPEC )+"' AND D_E_L_E_T_=' '"),20),oReport:Row(),0100)
			cImpres := space(18)
		EndIf
    EndIf
	If cVend == STR0099 .or. cVend == STR0084 // Todos ou Veic.Novos
		If ( cQAlPer )->( VCF_DIAPER ) > 0 .or. !Empty(( cQAlPer )->( VCF_VENVEI ))
			oReport:SkipLine()
			oReport:PrintText(cImpres+left(STR0084+space(13),13)+" "+right(str(( cQAlPer )->( VCF_DIAPER )),3)+" "+STR0111+"  "+STR0037+": "+( cQAlPer )->( VCF_VENVEI )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlPer )->( VCF_VENVEI )+"' AND D_E_L_E_T_=' '"),20),oReport:Row(),0100)
			cImpres := space(18)
		EndIf
	EndIf
	If lNewVend
		If cVend == STR0099 .or. cVend == STR0109 // Todos ou Veic.Usados
			If ( cQAlPer )->( VCF_DIAVEU ) > 0 .or. !Empty(( cQAlPer )->( VCF_VENVEU ))
				oReport:SkipLine()
				oReport:PrintText(cImpres+left(STR0109+space(13),13)+" "+right(str(( cQAlPer )->( VCF_DIAVEU )),3)+" "+STR0111+"  "+STR0037+": "+( cQAlPer )->( VCF_VENVEU )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlPer )->( VCF_VENVEU )+"' AND D_E_L_E_T_=' '"),20),oReport:Row(),0100)
				cImpres := space(18)
			EndIf
		EndIf
		If cVend == STR0099 .or. cVend == STR0110 // Todos ou Pneus
			If ( cQAlPer )->( VCF_DIAPNE ) > 0 .or. !Empty(( cQAlPer )->( VCF_VENPNE ))
				oReport:SkipLine()
				oReport:PrintText(cImpres+left(STR0110+space(13),13)+" "+right(str(( cQAlPer )->( VCF_DIAPNE )),3)+" "+STR0111+"  "+STR0037+": "+( cQAlPer )->( VCF_VENPNE )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlPer )->( VCF_VENPNE )+"' AND D_E_L_E_T_=' '"),20),oReport:Row(),0100)
				cImpres := space(18)
			EndIf
		EndIf
		If cVend == STR0099 .or. cVend == STR0114 // Todos ou Outros
			If ( cQAlPer )->( VCF_DIAOUT ) > 0 .or. !Empty(( cQAlPer )->( VCF_VENOUT ))
				oReport:SkipLine()
				oReport:PrintText(cImpres+left(STR0114+space(13),13)+" "+right(str(( cQAlPer )->( VCF_DIAOUT )),3)+" "+STR0111+"  "+STR0037+": "+( cQAlPer )->( VCF_VENOUT )+" - "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+( cQAlPer )->( VCF_VENOUT )+"' AND D_E_L_E_T_=' '"),20),oReport:Row(),0100)
				cImpres := space(18)
			EndIf
		EndIf
	EndIf
EndIf
( cQAlPer )->( dbCloseArea() )
Return 