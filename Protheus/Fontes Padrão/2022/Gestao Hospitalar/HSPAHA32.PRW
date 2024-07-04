#INCLUDE "HSPAHA32.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA32  º Autor ³ Manoel Filho       º Data ³  04/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE PRESTADORES                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA32()
Private cCadastro := OemToAnsi(STR0001) //"Cadastro de Prestador"
Private aRotina := {	{OemToAnsi(STR0002),	"AxPesqui", 		0, 1},; //"Pesquisar"
																					{OemToAnsi(STR0003),	"HS_A32ROTI",	0, 2},; 	//"Visualizar"
																					{OemToAnsi(STR0004),	"HS_A32ROTI",	0, 3},; //"Incluir"
																					{OemToAnsi(STR0005),	"HS_A32ROTI",	0, 4},; //"Alterar"
																					{OemToAnsi(STR0006),	"HS_A32ROTI",	0, 5},; //"Excluir"
																					{OemToAnsi(STR0007),	"HS_A32VLRP",	0, 4},; //"Vlr Plantão"
																					{OemToAnsi(STR0008),	"HS_A32PGTM",	0,	4}} 	//"Pgto Mínimo/Teto"

Private __cTpPic := "J" //Variavel utilizada para setar a mascara do campo GAZ_CGCPRE

DbSelectArea("GAZ")
DbSetOrder(1)

mBrowse(6, 1, 22, 75, "GAZ")

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_A32ROTI³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 12.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de prestadores                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_A32ROTI(cAlias, nReg, nOpc)
Local oDlg			:= NIL
Local lOk 			:= .F.
Local nCont		:= 0
Local bCampo	:= {|nCPO| Field(nCPO)}

Private aTela := {}
Private aGets := {}

DbSelectArea("GN4")
DbSelectArea("GAZ")
RegToMemory("GAZ", (nOpc == 3))

__cTpPic := IIF(!Empty(M->GAZ_TIPPRE),M->GAZ_TIPPRE,"J")

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd Pixel

 Enchoice("GAZ", nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,	{||lOk := Obrigatorio(aGets, aTela) .And. HS_VLDA32(2), IIf(lOk, oDlg:End(),)},;
																																																	{||oDlg:End()} )

If lOk .and. (nOpc == 3 .or. nOpc == 4)
	
	Begin Transaction
	
 	RecLock("GAZ", Inclui)
	  For nCont := 1 To FCount()
	  	If "FILIAL"$Field(nCont)
	  		FieldPut(nCont, xFilial("GAZ"))
	  	Else
	  		FieldPut(nCont, M->&(EVAL(bCampo,nCont)))
	  	Endif
	  Next nCont
		 GAZ->GAZ_LOGARQ := HS_LOGARQ()
	 MsUnLock()
	
	End Transaction
	
Endif

If nOpc == 5 .and. lOk
	
	DbSelectArea("GAY")
	DbSetOrder(7)//GAY/7
	If !DbSeek(xFilial("GAY") + M->GAZ_CODPRE) //nao tem nos credenciamentos
		DbSelectArea("GA7")
		DbSetOrder(8)//GA7/8
		If !DbSeek(xFilial("GA7") + M->GAZ_CODPRE) //nao tem nos procedimentos
			//Deleta
			DbSelectArea("GEF")
			DbSetOrder(1)
			DbSeek(xFilial("GEF") + M->GAZ_CODPRE)
			
			Begin Transaction
			
 			Do While !Eof() .and.  GEF->(GEF_FILIAL + GEF_CODPRE) == xFilial("GEF") + M->GAZ_CODPRE
 				RecLock("GEF", .F.)
 			 	DbDelete()
 				MsUnLock()
				
	 			DbSkip()
	 		Enddo
			
		 	RecLock("GAZ", .F.)
		  	DbDelete()
			 MsUnLock()
			
			End Transaction
		Else
			HS_MsgInf(STR0013, STR0012, STR0006) //"Existe credenciamento cadastrado para este prestador. Exclusão não permitida!"###"Atenção"###"Excluir"
		Endif
	Else
		HS_MsgInf(STR0011, STR0012, STR0006) //"Existe esse prestador no Credenciamento. Impossivel Exclui-lo!"###"Atenção"###"Excluir"
	EndIf
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_A32PGTM³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 11.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra o piso dos prestadores                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_A32PGTM(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                   							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HSP                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_A32PGTM(cAlias, nReg, nOpc)

Local nOpcA    := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
Local nCntFor  := 1 , aCpoEnc := {"GAZ_CODPRE",	"GAZ_FANPRE","GAZ_CTLOCM","GAZ_VALMIN","GAZ_VLMIND","GAZ_VALMAX","GAZ_VLMAXD"}
Local aSize    := {},  aObjects := {},  aInfo := {}, aPObjs := ()
Local aCposAlt := {"GAZ_CTLOCM","GAZ_VALMIN","GAZ_VLMIND","GAZ_VALMAX","GAZ_VLMAXD"}

Private aTela  := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGEF	 := {}, aHGEF   := {}, nUGEF := 0, nLGEF := 0, oGEF
Private nGEFSTAREG := 0, nGEF_NumSeq:= 0, nGEF_CodLoc := 0, nGEF_ValMin := 0, nGEF_VlMinD := 0, nGEF_ValMax := 0, nGEF_VlMaxD := 0, nGEF_Vigenc := 0

DbSelectArea("GEF")

RegToMemory("GAZ", .F.)

Inclui := .F.

HS_BDados("GEF", @aHGEF, @aCGEF, @nUGEF, 1, M->GAZ_CODPRE, "'" + M->GAZ_CODPRE + "' == GEF->GEF_CODPRE",.T. )
nGEFSTAREG  := aScan(aHGEF, {| aVet | aVet[2] == "HSP_STAREG"})
nGEF_CodLoc := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_CODLOC" })
nGEF_Vigenc := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_DATVIG" })
nGEF_ValMin := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VALMIN" })
nGEF_VlMinD := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VLMIND" })
nGEF_ValMax := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VALMAX" })
nGEF_VlMaxD := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_VLMAXD" })
nGEF_NumSeq := aScan(aHGEF, {|x| AllTrim(x[2]) == "GEF_NUMSEQ" })

//numeracao sequencial do primeiro detalhe - preencher com zeros a esquerda
If Empty(aCGEF[1, nGEF_NumSeq])
	aCGEF[1, nGEF_NumSeq] := StrZero(1, Len(GEF->GEF_NUMSEQ))
EndIf

Inclui := .T.
DbSelectArea("GAZ")
nOpcA := 0

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd

 EnChoice("GAZ", nReg, nOpc,,,,aCpoEnc, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] }, aCposAlt, 3,,,,,, .F.,,,.T.)

 oGEF := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,"HS_DuplAC(oGEF:oBrowse:nAt, oGEF:aCols, { nGEF_CodLoc,nGEF_Vigenc})",,"+GEF_NUMSEQ",,,,,,, oDlg, aHGEF, aCGEF)
 oGEF:cFieldOk        := "HS_GDAtrib(oGEF, {{nGEFStaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)"
 oGEF:oBrowse:bDelete := {|| HS_GDAtrib(oGEF, {{nGEFStaReg, "BR_CINZA", "BR_VERDE"}}, 5), oGEF:DelLine()}

 oGEF:oBrowse:align := CONTROL_ALIGN_BOTTOM                             
 IIf( M->GAZ_CTLOCM == '1',oGEF:oBrowse:Enable(),oGEF:oBrowse:Disable())

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, FS_Vlda() .AND. IIf(oGEF:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0) } , ;
																																																	{|| nOpcA := 0, oDlg:End()})
Begin Transaction
 RecLock("GAZ", .F.)
  HS_GrvCpo("GAZ")
  GAZ->GAZ_LOGARQ := HS_LOGARQ()
 MsUnLock()
End Transaction

// Salva Setores
If nOpcA == 1 .And. M->GAZ_CTLOCM == "1"
	Begin Transaction
 	FS_GrvA32a()
	End Transaction
EndIf

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FS_GrvA32a³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gravação dos dados minimo/teto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvA32a()
Local   cAlias    := "GEF"
Local   nOrd      := 2
Local   cChave    := "M->GAZ_CODPRE+oGEF:aCols[pForaCols, nGEF_NumSeq]"
Local   oGrv      := oGEF
Local   nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local   cAliasOld := Alias(), lAchou := .F.
Private pForaCols := 0

For nItem := 1 To Len(oGrv:aCols)
 If oGEF:aCols[nItem, nGEFStaReg] <> "BR_VERDE"
		pForaCols := nItem
		DbSelectArea(cAlias)
		DbSetOrder(nOrd)
		lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
		If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou /* exclusao */
			RecLock(cAlias, .F., .T.)
 			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		Else
			If Inclui .Or. Altera
				If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
					RecLock(cAlias, !lAchou)
	 				HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
	 				&(cPref + "_FILIAL") := xFilial(cAlias)
	 				&(cPref + "_CODPRE") := M->GAZ_CODPRE
	 				&(cPref + "_LOGARQ") := HS_LogArq()
					MsUnlock()
				Endif
			Endif
		EndIf
	Endif
Next

DbSelectArea(cAliasOld)
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FS_Vlda  ³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validação  dos dados minimo/teto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Vlda()
Local nPosDel	:= Len(aHGEF) + 1
Local nItem 				:= 0
Local nSetores  := 0 // Guarda quantidade de setores

If M->GAZ_CTLOCM == "0" // Se não for controle por Setor
	// Se não tiver valor minimo ou maximo cadastrado
	If M->GAZ_VALMIN == 0 .and. M->GAZ_VLMIND == 0 .And. M->GAZ_VALMAX == 0 .and. M->GAZ_VLMAXD == 0
		HS_MsgInf(STR0010, STR0012, STR0008) //"O campo "Controle setor" está informado como "Não", informe a seguir os valores a serem considerados para no pagamento mínimo/ teto"##"Atenção"###"Pagto Mínimo/Teto"
		return (.F.)
		
		// Se o valor minimo for maior que o maximo
	ElseIf !Empty(M->GAZ_VALMAX) .And. M->GAZ_VALMIN > M->GAZ_VALMAX
		HS_MsgInf(STR0016, STR0012, STR0008) //"Valor máximo tem que ser maior ou igual ao valor mínimo","Atenção"###"Pagto Mínimo/Teto"
		return (.F.)
		
		// Se o valor minimo diário for maior que o máximo diário
	ElseIf !Empty(M->GAZ_VLMAXD) .And. M->GAZ_VLMIND > M->GAZ_VLMAXD
		HS_MsgInf(STR0017, STR0012, STR0008) //"Valor máximo diário tem que ser maior ou igual ao valor mínimo diário"###"Atenção"###"Pagto Mínimo/Teto"
		return (.F.)
 Endif
ElseIf M->GAZ_CTLOCM == "1"
	// verifica se setor e valores estão preenchidos
	For nItem := 1 To Len(oGEF:aCols)
		
		If !oGEF:aCols[oGEF:nAt, nPosDel] // Linha nao deletada
				
			// Se não tiver valor minimo ou maximo cadastrado
			If !Empty(oGEF:aCols[oGEF:nAt, nGEF_CodLoc]) .and. oGEF:aCols[oGEF:nAt, nGEF_VALMIN] == 0 .and. oGEF:aCols[oGEF:nAt, nGEF_VLMIND] == 0 .And. oGEF:aCols[oGEF:nAt, nGEF_VALMAX] == 0 .and. oGEF:aCols[oGEF:nAt, nGEF_VLMAXD] == 0
				HS_MsgInf(STR0025, STR0012, STR0008) //"Por favor, informe os valores de pagamento mínimo/ teto para os setores"##"Atenção"###"Pagto Mínimo/Teto"
				return (.F.)
				
			// Se o valor minimo for maior que o maximo
			ElseIf !Empty(oGEF:aCols[oGEF:nAt, nGEF_VALMAX]) .And. oGEF:aCols[oGEF:nAt, nGEF_VALMIN] > oGEF:aCols[oGEF:nAt, nGEF_VALMAX]
				HS_MsgInf(STR0016, STR0012, STR0008) //"Valor máximo tem que ser maior ou igual ao valor mínimo"###"Atenção"###"Pagto Mínimo/Teto"
				return (.F.)
				
			// Se o valor minimo diário for maior que o máximo diário
			ElseIf !Empty(oGEF:aCols[oGEF:nAt, nGEF_VLMAXD]) .And. oGEF:aCols[oGEF:nAt, nGEF_VLMIND] > oGEF:aCols[oGEF:nAt, nGEF_VLMAXD]
				HS_MsgInf(STR0017, STR0012, STR0008) //"Valor máximo diário tem que ser maior ou igual ao valor mínimo diário"###"Atenção"###"Pagto Mínimo/Teto"
				return (.F.)
	
			// Se não tiver Setor
			ElseIf Empty(oGEF:aCols[oGEF:nAt, nGEF_CodLoc])
				HS_MsgInf(STR0018, STR0012, STR0008) //"Setor não pode estar em branco"###"Atenção"###"Pagto Mínimo/Teto"
				return (.F.)
			Endif
	 Endif
		nSetores += IIF(!Empty(oGEF:aCols[nItem, nGEF_CodLoc]),1,0) // Se tiver setor incrementa
	Next
	If nSetores < 1
		HS_MsgInf(STR0019,STR0012, STR0008)//"Com controle por setor, é necessário informar um Setor com todos os valores preenchidos."###"Atenção"###"Pagto Mínimo/Teto"
		return (.F.)
	Endif
ElseIf empty(M->GAZ_CTLOCM)
		HS_MsgInf(STR0027,STR0012,STR0001)//"Por favor, informe o tipo de controle: se SIM com controle por setor, se NÂO sem controle por setor ou SEM CONTROLE para não gerar pagamento mínimo."###"Atenção"###"Cadastro de Prestador"
		return (.F.)
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_A32VLRPºAutor  ³MARCELO JOSE        º Data ³  30/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  RELACIONA PRESTADOR COM VALOR DO PLANTAO                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_A32VLRP(cAlias, nReg, nOpc)
Local nOpcA    := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE
Local nCntFor  := 1 , aCpoEnc := {"GAZ_CODPRE",	"GAZ_FANPRE","GAZ_CTRLOC","GAZ_VLRDIU","GAZ_VLRNOT","GAZ_VLRFER","GAZ_FATORH"}
Local aSize    := {},  aObjects := {},  aInfo := {}, aPObjs := ()
Local aCposAlt := {"GAZ_CTRLOC","GAZ_VLRDIU","GAZ_VLRNOT","GAZ_VLRFER","GAZ_FATORH"}

Private aTela  := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGEU	 := {}, aHGEU   := {}, nUGEU := 0, nLGEU := 0, oGEU
Private nGEUSTAREG  := 0, nGEU_NumSeq := 0, nGEU_CodLoc := 0, nGEU_VlrDiu := 0, nGEU_VlrNot := 0, nGEU_VlrFer := 0, nGEU_FatorH := 0, nGEU_Vigenc := 0

DbSelectArea("GEU")

RegToMemory("GAZ", .F.)

Inclui := .F.

HS_BDados("GEU", @aHGEU, @aCGEU, @nUGEU, 1, M->GAZ_CODPRE, "'" + M->GAZ_CODPRE + "' == GEU->GEU_CODPRE",.T. )
nGEUSTAREG  := aScan(aHGEU, {| aVet | aVet[2] == "HSP_STAREG"})
nGEU_CodLoc := aScan(aHGEU, {| aVet | aVet[2] == "GEU_CODLOC"})
nGEU_VlrMat := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VLRMAT"})
nGEU_VlrNot := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VLRNOT"})
nGEU_VlrFer := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VLRFER"})
nGEU_FatorH := aScan(aHGEU, {| aVet | aVet[2] == "GEU_FATORH"})
nGEU_Vigenc := aScan(aHGEU, {| aVet | aVet[2] == "GEU_VIGENC"})
nGEU_NumSeq := aScan(aHGEU, {| aVet | aVet[2] == "GEU_NUMSEQ"})

//numeracao sequencial do primeiro detalhe - preencher com zeros a esquerda
If Empty(aCGEU[1, nGEU_NumSeq])
	aCGEU[1, nGEU_NumSeq] := StrZero(1, Len(GEU->GEU_NUMSEQ))
EndIf

Inclui := .T.
DbSelectArea("GAZ")
nOpcA := 0

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd

 EnChoice("GAZ", nReg, nOpc,,,,aCpoEnc, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] }, aCposAlt, 3,,,,,, .F.,,,.T.)

 oGEU := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,"HS_DuplAC(oGEU:oBrowse:nAt, oGEU:aCols, { nGEU_CodLoc,nGEU_Vigenc})",,"+GEU_NUMSEQ",,,,,,, oDlg, aHGEU, aCGEU)
 oGEU:cFieldOk           := "HS_GDAtrib(oGEU, {{nGEUStaReg, 'BR_AMARELO', 'BR_VERDE'}}, 4)"
 oGEU:oBrowse:bDelete := {|| HS_GDAtrib(oGEU, {{nGEUStaReg, "BR_CINZA", "BR_VERDE"}}, 5), oGEU:DelLine()}
 oGEU:oBrowse:align := CONTROL_ALIGN_BOTTOM
 IIf( M->GAZ_CTRLOC == '1',oGEU:oBrowse:Enable(),oGEU:oBrowse:Disable())

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, FS_Vld() .AND. IIf(oGEU:TudoOk() .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0) } , ;
																																																	{|| nOpcA := 0, oDlg:End()})

Begin Transaction
 RecLock("GAZ", .F.)
  HS_GrvCpo("GAZ")
  GAZ->GAZ_LOGARQ := HS_LOGARQ()
 MsUnLock()
End Transaction

// Salva Setores
If nOpcA == 1 .And. M->GAZ_CTRLOC == "1"
	Begin Transaction
 	FS_GrvA32()
	End Transaction
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FS_GrvA32³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gravação dos dados Plantão                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvA32()
Local   cAlias    := "GEU"
Local   nOrd      := 2
Local   cChave    := "M->GAZ_CODPRE+oGEU:aCols[pForaCols, nGEU_NumSeq]"
Local   oGrv      := oGEU
Local   nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
Local   cAliasOld := Alias(), lAchou := .F.
Private pForaCols := 0

For nItem := 1 To Len(oGrv:aCols)
 If oGEU:aCols[nItem, nGEUStaReg] <> "BR_VERDE"
		pForaCols := nItem
		DbSelectArea(cAlias)
		DbSetOrder(nOrd)//GEU_CODPRE+GEU_NUMSEQ
		lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
		If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou /* exclusao */
			RecLock(cAlias, .F., .T.)
		 	DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		Else
			If Inclui .Or. Altera
				If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
					RecLock(cAlias, !lAchou)
		 			HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
		 			&(cPref + "_FILIAL") := xFilial(cAlias)
		 			&(cPref + "_CODPRE") := M->GAZ_CODPRE
		 			&(cPref + "_LOGARQ") := HS_LogArq()
					MsUnlock()
				Endif
			Endif
		EndIf
	Endif
Next

DbSelectArea(cAliasOld)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FS_Vld   ³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validação  dos dados Plantão                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Vld()
Local   oGrv      := oGEU
Local   nItem 				:= 0
Local   nSetores  := 0 // Guarda quantidade de setores
If M->GAZ_CTRLOC == "0"
	If Empty(M->GAZ_VLRDIU) .OR. 	Empty(M->GAZ_VLRNOT) .OR. Empty(M->GAZ_VLRFER) .OR. Empty(M->GAZ_FATORH)
		HS_MsgInf(STR0020,STR0012,STR0001)//"Sem controle por setor, é necessário preencher todos campos de valores."###"Atenção"###"Cadastro de Prestador"
		return (.F.)
	Endif
ElseIf M->GAZ_CTRLOC == "1"
	// verifica se setor e valores estão preenchidos
	For nItem := 1 To Len(oGrv:aCols)
		
		// Se tiver Setor tem que ter todos os valores preenchidos
		if (!Empty(oGrv:aCols[nItem, nGEU_CodLoc])) .AND. (Empty(oGrv:aCols[nItem, nGEU_VlrMat]) .OR. Empty(oGrv:aCols[nItem, nGEU_VlrNot]) .OR. Empty(oGrv:aCols[nItem, nGEU_VlrFer]) .OR. Empty(oGrv:aCols[nItem, nGEU_FatorH]))
			HS_MsgInf(STR0021,STR0012,STR0001)//"Todos os valores de um Setor deverão ser preenchidos."###"Atenção"###"Cadastro de Prestador"
			return (.F.)
		Endif
		nSetores += IIF(!Empty(oGrv:aCols[nItem, nGEU_CodLoc]),1,0) // Se tiver setor incrementa
	Next
	If nSetores < 1
		HS_MsgInf(STR0022,STR0012,STR0001)//"Com controle por setor, é necessário informar um Setor com todos os valores preenchidos."###"Atenção"###"Cadastro de Prestador"
		return (.F.)
	Endif
Else
		HS_MsgInf(STR0026,STR0012,STR0001)//"Por favor,informe o tipo de controle: se SIM com controle por setor ou NÂO sem controle por setor."###"Atenção"###"Cadastro de Prestador"
		return (.F.)
Endif

return (.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³HS_VldHA32³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldHA32(cHora)
Local lRet := .T.

cHora := StrTran(cHora, ":", "")
If Empty(cHora)
	lRet := .F.
Elseif !(SubStr(cHora, 3, 2) >= '00' .and. SubStr(cHora, 3, 2) <= '59')
	lRet := .F.
ElseIf !(SubStr(cHora, 1, 2) >= '00' .and. SubStr(cHora, 1, 2) <= '23')
	lRet := .F.
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HS_VLDA32³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VLDA32(nVld)
Local lRet := .T.

If nVld == 1
	lRet := HS_SeekRet("SA2","M->GAZ_CODFOR",1,.F.,"GAZ_NREDUZ","A2_NREDUZ")
ElseIf nVld == 2
	If !Empty(M->GAZ_CGCPRE)
		If !( LEN(AllTrim(M->GAZ_CGCPRE)) == IIF(M->GAZ_TIPPRE == "J",14,11) )
			HS_MSGINF(STR0015,STR0012,STR0014)
			lRet := .F.
		ElseIf ( !CGC(M->GAZ_CGCPRE,"M->GAZ_CGCPRE") .AND. EXISTCHAV("GAZ",M->GAZ_CGCPRE,3,"GAZ_CGCPRE") )
			lRet := .F.
		EndIf
	EndIf
ElseIf nVld == 3
	If !Empty(M->GAZ_TIPPRE)
		__cTpPic := M->GAZ_TIPPRE
	EndIf
ElseIf nVld == 4
	If !(lRet :=HS_SeekRet("GCS","M->GEF_CODLOC",1,.F.,"GEF_NOMLOC","GCS_NOMLOC"))
		HS_MSGINF(STR0023,STR0012,STR0024)//"Setor não encontrado"###"Atenção"###"Validação Setor"
	Endif
ElseIf nVld == 5
	If !(lRet :=HS_SeekRet("GCS","M->GEU_CODLOC",1,.F.,"GEU_NOMLOC","GCS_NOMLOC"))
		HS_MSGINF(STR0023,STR0012,STR0024)//"Setor não encontrado"###"Atenção"###"Validação Setor"
	Endif
EndIf

Return(lRet)          

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PicT     ³ Autor ³ MICROSIGA               ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para tratamento da Picture do Cadastro de Prestadores ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PicT(cTipPes)
Local cPict := ""  

if cTipPes == "F"
	cPict := "@R 999.999.999-99"
else
	cPict := "@R 99.999.999/9999-99"
endif
cPict := cPict + "%C"
Return cPict

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HSHA32VLD³ Autor ³ MICROSIGA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para tratamento do Valid dos campos da rotina HSPAHA32³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSPAHA32                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSHA32VLD (cCampo)
Local lRet := .T.

Do Case 
	Case cCampo == "GAZ_CTLOCM"
		If IsInCallStack("HS_A32PGTM")
			If M->GAZ_CTLOCM == '1'
				oGEF:oBrowse:Enable()
			Else
				oGEF:oBrowse:Disable()
			Endif
		Endif
	
	Case cCampo == "GAZ_CTRLOC"
		If IsInCallStack("HS_A32VLRP")
			If M->GAZ_CTRLOC == '1'
				oGEU:oBrowse:Enable()
			Else
				oGEU:oBrowse:Disable()
			Endif
		Endif
EndCase

Return lRet