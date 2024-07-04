#include "Protheus.ch"
#include "OFIPM040.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIPM040 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inventario de Pecas (Coordenacao/Digitacao)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPM040()
Private lCoorde    := .f. // Coordenador
Private lCancela   := .f.
Private lAltDiv    := .f. // Permissao para alterar as qtdes das Divergencias apos a Finalizacao do Inventario
Private lGeraNF    := .t. // Permissao para geracao de NF das divergencias ou lancamento SB7 apos a Finalizacao do Inventario
Private lMLF       := ( GetNewPar("MV_MIL0072","0")=="1" .and. SB5->(FieldPos("B5_MARPEC")) > 0 .and. SB5->(FieldPos("B5_CODLIN")) > 0 .and. SB5->(FieldPos("B5_CODFAM")) > 0 ) // Filtro por Marca/Linha/Familia
Private lFGS       := ( GetNewPar("MV_MIL0072","0")=="2" .and. SB1->(FieldPos("B1_FAMAPL")) > 0 .and. SB1->(FieldPos("B1_GRUAPL")) > 0 .and. SB1->(FieldPos("B1_SUBAPL")) > 0 ) // Filtro por Familia/Grupo/SubGrupo
Private lEnderecado:= ( GetMv("MV_LOCALIZ") == "S" ) // Trabalha com estoque Enderecado ?
Private cCadastro  := STR0001 // INVENTARIO
Private aRotina    := OPM040MENU()
Private aVPGData   := {} // será usada para guardar as chaves do VPG para que na hora de gerar a nota colocar no campo corretamente o numero, ja que agora vamos particionar a nota.
Private nMaxIteNf  := GetNewPar("MV_NUMITEN",9999999) // maximo de itens por nota
Private aCores     := {	{'VPE->VPE_FASE == "99"','BR_PRETO'},;     // Inventario Finalizado
						{'VPE->VPE_FASE == "XX"','BR_VERMELHO'},;  // Inventario Cancelado
						{'VPE->VPE_FASE<>"99".and.VPE->VPE_FASE<>"XX"','BR_VERDE'}}	// Inventario Em Andamento
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar o modulo de ( 14 - Oficina ) ou ( 41 - Auto Pecas ) //
///////////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIPM040"})
	Return()
EndIf
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If VAI->VAI_INVUSR == "1" // Coordenador
	lCoorde := .t.
EndIf
If VAI->VAI_INVDIV == "1" // Permissao para alterar as qtdes das Divergencias apos a Finalizacao do Inventario
	lAltDiv := .t.
EndIf
If ( VAI->(FieldPos("VAI_INVGNF")) > 0 )
	If VAI->VAI_INVGNF == "0" // Permissao para geracao de NF das divergencias ou lancamento SB7 apos a Finalizacao do Inventario
		lGeraNF := .f.
	EndIf
EndIf
//
DbSelectArea("VPE")
mBrowse( 6, 1,22,75,"VPE",,,,,,aCores,,,,,,,,)
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPM040EXE³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao/Digitacao Inventario                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040EXE()
Local i,j
Local nX            := 0
Local lOk           := .f.
Local lGrvMemo      := .f.
Local lOPM040EXE    := .f.
Local aRegs         := {}
Private cPictQTD    := SX3->(x3Picture("B2_QATU"))
Private nQtd        := 0
Private cFase       := "00"
Private cFaseX      := "00"
Private cTitulo     := ""
Private cAlmox      := ""
Private lSair       := .f.
Private cNroP       := strzero(1,6)
Private cNroI       := strzero(1,2)
Private cAgrup      := left(GetNewPar("MV_CONTAGR","N"),1)
Private cAgrAx      := ""
Private aVetInv     := {}
Private cObsInv     := ""
//
DEFINE FONT oTpFonte NAME "Arial" SIZE 10,14 BOLD
//
For nX := 1 to 25
	aAdd(aVetInv,{"","","",0}) // 25 linhas por pagina ( itens ) --> aVetInv[ Nro , Localizacao , Item , Qtde ]
Next
//

DbSelectArea("VPE")
cObsInv := VPE->VPE_OBSERV

DbSelectArea("VPF")
FS_FASE()

If lCoorde // Coordenacao

	DEFINE MSDIALOG oContagem FROM 000,000 TO 030,070 TITLE (STR0001) OF oMainWnd // "INVENTARIO"
	oContagem:lEscClose := .F.

	////////////////////////////////
	//   PARAMETROS / IMPRESSAO   //
	////////////////////////////////
	@ 013,015 TO 210,263 LABEL ("[ "+STR0002+" ]") OF oContagem PIXEL // "CONTROLE DO INVENTARIO"
	If cFase # "99" .and. cFase # "XX"
		lGrvMemo := .t.
		@ 026,024 SAY STR0003 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Nro.:"
		@ 026,060 SAY VPE->VPE_CODIGO SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte
		@ 039,024 SAY STR0004 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Inicio:"
		@ 039,060 SAY (Transform(VPE->VPE_DATINI,"@D")+" - "+Transform(VPE->VPE_HORINI,"@R 99:99")+" "+STR0014) SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte // "hs"
		@ 065,024 GET oParInv VAR VPE->VPE_PARINV OF oContagem MEMO SIZE 230,040 PIXEL READONLY MEMO
		@ 107,024 SAY (STR0151+":") SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE // "Observação"
		@ 115,024 GET oObsInv VAR cObsInv OF oContagem MEMO SIZE 230,040 PIXEL
		@ 025,185 BUTTON oSair PROMPT STR0155 OF oContagem SIZE 070,10 PIXEL ACTION (oContagem:End()) // "SAIR"
		@ 043,185 BUTTON oCanc PROMPT STR0009 OF oContagem SIZE 070,10 PIXEL ACTION (FS_CANCELAR(),lOPM040EXE:=.t.,oContagem:End()) // "CANCELA INVENTARIO"
	EndIf
	Do Case
		Case cFase == "99" // Contagem Finalizada
			@ 036,024 SAY STR0003 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Nro.:"
			@ 036,060 SAY VPE->VPE_CODIGO SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte
			@ 053,024 SAY STR0004 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Inicio:"
			@ 053,060 SAY (Transform(VPE->VPE_DATINI,"@D")+" - "+Transform(VPE->VPE_HORINI,"@R 99:99")+" "+STR0014) SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte // "hs"
			@ 070,024 SAY STR0005 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Fim:"
			@ 070,060 SAY (Transform(VPE->VPE_DATFIN,"@D")+" - "+Transform(VPE->VPE_HORFIN,"@R 99:99")+" "+STR0014) SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte // "hs"
			@ 030,185 BUTTON oSair PROMPT STR0155 OF oContagem SIZE 070,10 PIXEL ACTION (oContagem:End()) // "SAIR"
			@ 043,185 BUTTON oAltDiver PROMPT STR0140 OF oContagem SIZE 070,10 PIXEL ACTION (FS_ALTDIV(),lOPM040EXE:=.t.,oContagem:End()) WHEN (lAltDiv .and. VPE->VPE_GERAB7=="0") // "ALT. DIVERGENCIAS"
			@ 056,185 BUTTON oRelDiver PROMPT STR0015 OF oContagem SIZE 070,10 PIXEL ACTION OFIPR160(VPE->VPE_CODIGO) // "REL. DIVERGENCIAS"
			If GetNewPar("MV_MIL0071","1") == "1" // Gerar 1-SB7
 				If VPE->VPE_GERAB7 == "0"
					@ 069,185 BUTTON oGerB7NF PROMPT STR0017 OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| FS_GERAB7NF(1) } ),lOPM040EXE:=.t.,oContagem:End()) WHEN lGeraNF // "GERA LANC.INVENT."
				Else
					@ 069,185 BUTTON oVerB7NF PROMPT STR0195 OF oContagem SIZE 070,10 PIXEL ACTION OPM040011_VisualizaDocumentos(1) // "VISUAL.LANC.INVENT."
				EndIf
			Else // Gerar 2-NF
 				If VPE->VPE_GERAB7 == "0"
					@ 069,185 BUTTON oGerB7NF PROMPT STR0156 OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| FS_GERAB7NF(2) } ),lOPM040EXE:=.t.,oContagem:End()) WHEN lGeraNF // "GERA NF DIVERG."
				Else
					@ 069,185 BUTTON oVerB7NF PROMPT STR0196 OF oContagem SIZE 070,10 PIXEL ACTION OPM040011_VisualizaDocumentos(2) // "VISUAL. NF DIVERG."
				EndIf
			EndIf
			@ 092,024 SAY (STR0152+":") SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE // "Parametros do Inventario"
			@ 100,024 GET oParInv VAR VPE->VPE_PARINV OF oContagem MEMO SIZE 230,040 PIXEL READONLY MEMO
			@ 147,024 SAY (STR0151+":") SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE // "Observação"
			@ 155,024 GET oObsInv VAR cObsInv OF oContagem MEMO SIZE 230,040 PIXEL READONLY MEMO
		Case cFase == "XX" // Contagem Cancelada
			@ 036,024 SAY STR0003 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Nro.:"
			@ 036,080 SAY VPE->VPE_CODIGO SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte
			@ 053,024 SAY STR0004 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Inicio:"
			@ 053,080 SAY (Transform(VPE->VPE_DATINI,"@D")+" - "+Transform(VPE->VPE_HORINI,"@R 99:99")+" "+STR0014) SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte // "hs"
			@ 070,024 SAY STR0006 SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Cancelado:"
			@ 070,080 SAY (Transform(VPE->VPE_DATFIN,"@D")+" - "+Transform(VPE->VPE_HORFIN,"@R 99:99")+" "+STR0014) SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte // "hs"
			@ 030,185 BUTTON oSair PROMPT STR0155 OF oContagem SIZE 070,10 PIXEL ACTION (oContagem:End()) // "SAIR"
			@ 092,024 SAY (STR0152+":") SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE // "Parametros do Inventario"
			@ 100,024 GET oParInv VAR VPE->VPE_PARINV OF oContagem MEMO SIZE 230,040 PIXEL READONLY MEMO
			@ 147,024 SAY (STR0151+":") SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE // "Observação"
			@ 155,024 GET oObsInv VAR cObsInv OF oContagem MEMO SIZE 230,040 PIXEL READONLY MEMO
		Case ( VPE->VPE_QTDCON == "3" .and. cFase == "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase == "I6" ) // Todas as Contagens ja Digitadas
			@ 052,024 SAY STR0007 SIZE 100,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Fase:"
			@ 052,060 SAY cTitulo SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte
			@ 178,029 BUTTON oVoltaFas PROMPT STR0010 OF oContagem SIZE 070,10 PIXEL ACTION IIf(FS_AVANCAR("-"),(lOPM040EXE:=.t.,oContagem:End()),.t.) // "<<<  VOLTAR FASE"
			@ 178,104 BUTTON oImprimir PROMPT (STR0012+" "+VPE->VPE_QTDCON) OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| FS_IMPRIMIR() } ),lOPM040EXE:=.t.,oContagem:End()) // "IMPRIMIR DIGITACAO"
			@ 178,179 BUTTON oAvancar1 PROMPT STR0011 OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| FS_FINAL() } ),lOPM040EXE:=.t.,oContagem:End()) // "AVANCAR FASE  >>>"
			@ 191,104 BUTTON oImprDig  PROMPT STR0092 OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| OPM040ICTG("*") } )) // "Imprimir Digitacoes"
		Case cFase $ "I1/D1/I2/D2/I3/D3/I4/D4/I5/D5" // Impressao/Digitacao da (1/2/3/4/5) Contagem
			@ 052,024 SAY STR0007 SIZE 100,08 OF oContagem PIXEL COLOR CLR_BLUE FONT oTpFonte // "Fase:"
			@ 052,060 SAY cTitulo SIZE 150,08 OF oContagem PIXEL COLOR CLR_HBLUE FONT oTpFonte
			If cFase $ "D1/D2/D3/D4/D5"
				@ 178,029 BUTTON oImprimir PROMPT (STR0013+" "+right(cFase,1)) OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| FS_IMPRIMIR() } ),lOPM040EXE:=.t.,oContagem:End()) // "IMPRIMIR RELACAO"
				@ 178,104 BUTTON oPaginas PROMPT (STR0062+" "+right(cFase,1)) OF oContagem SIZE 070,10 PIXEL ACTION Processa( {|| FS_VERPERC("N") } ) // "% Digitacao"
				@ 178,179 BUTTON oAvancar1 PROMPT STR0011 OF oContagem SIZE 070,10 PIXEL ACTION IIf(FS_AVANCAR("+"),(lOPM040EXE:=.t.,oContagem:End()),.t.) // "AVANCAR FASE  >>>"
			Else
				@ 178,055 BUTTON oImprimir PROMPT (STR0013+" "+right(cFase,1)) OF oContagem SIZE 070,10 PIXEL ACTION (Processa( {|| FS_IMPRIMIR() } ),lOPM040EXE:=.t.,oContagem:End()) // "IMPRIMIR RELACAO"
				@ 178,153 BUTTON oAvancar1 PROMPT STR0011 OF oContagem SIZE 070,10 PIXEL ACTION IIf(FS_AVANCAR("+"),(lOPM040EXE:=.t.,oContagem:End()),.t.) WHEN .f. // "AVANCAR FASE  >>>"
			EndIf
			@ 191,104 BUTTON oImprDig PROMPT (STR0092) OF oContagem SIZE 070,10 PIXEL ACTION Processa( {|| OPM040ICTG("*") } ) WHEN cFase<>"I1" // "Imprimir Digitacoes"
	EndCase
	If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
		If cFase <> "99" .and. cFase <> "XX" // .and.  // Estatistica somente para a Contagem em Aberto
			@ 165,104 BUTTON oPerc PROMPT (STR0067) OF oContagem SIZE 070,10 PIXEL ACTION Processa( {|| FS_VERPERC("T") } ) WHEN cFase<>"I1" //<<< ESTATISTICA >>>
		EndIf
	EndIf
	ACTIVATE MSDIALOG oContagem CENTER

	If lGrvMemo
		FS_GRVOBS() // Grava Memo da Observacao do Inventario
	EndIf
	If lOPM040EXE
		OPM040EXE() // Manutencao - Chamar tela novamente
	EndIf

Else

	////////////////////////////////
	//   DIGITACAO                //
	////////////////////////////////

	If cFase $ "D1/D2/D3/D4/D5"

		DEFINE MSDIALOG oContagem FROM 000,000 TO 033,070 TITLE (STR0001+" "+VPE->VPE_CODIGO+" - "+Transform(VPE->VPE_DATINI,"@D")+" "+Transform(VPE->VPE_HORINI,"@R 99:99")+" - "+cTitulo) OF oMainWnd // "INVENTARIO"

		@ 001,001 TO 015,277 LABEL "" OF oContagem PIXEL COLOR CLR_BLUE

		@ 005,230 SAY cAlmox SIZE 150,08 OF oContagem PIXEL COLOR CLR_BLUE

		@ 005,005 SAY STR0018 SIZE 40,08 OF oContagem PIXEL COLOR CLR_BLUE // "Nro.Pag./Seq.:"
		@ 003,043 MSGET oNroP VAR cNroP PICTURE "999999" VALID (cNroP:=strzero(val(cNroP),6),oNroP:Refresh(),cNroI:="01",oNroI:Refresh(),FS_PESQ(),oQtd01:SetFocus()) SIZE 25,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !lSair
		@ 003,068 MSGET oNroI VAR cNroI PICTURE "99" VALID (oQtd01:SetFocus()) SIZE 08,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !lSair
		@ 003,078 BUTTON oPerc PROMPT ("?") OF oContagem SIZE 10,10 PIXEL ACTION (Processa( {|| FS_VERPERC("N") } ),oQtd01:SetFocus()) WHEN !lSair

		@ 016,002 SAY STR0019 SIZE 50,08 OF oContagem PIXEL COLOR CLR_RED // "Locacao"
		@ 016,050 SAY STR0020 SIZE 50,08 OF oContagem PIXEL COLOR CLR_RED // "Descricao"
		@ 016,139 SAY STR0021 SIZE 50,08 OF oContagem PIXEL COLOR CLR_RED // "Item"
		@ 016,237 SAY STR0022 SIZE 50,08 OF oContagem PIXEL COLOR CLR_RED // "Qtde"

		nX := 23
		@ nX,268 MSGET oSeq01 VAR strzero(01,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc01 VAR aVetInv[01,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes01 VAR substr(aVetInv[01,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte01 VAR left(aVetInv[01,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd01 VAR aVetInv[01,4] PICTURE cPictQTD VALID FS_QTD(1) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[01,1]) .and. !lSair
		oQtd01:bGotFocus := {|| cNroI := "01" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq02 VAR strzero(02,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc02 VAR aVetInv[02,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes02 VAR substr(aVetInv[02,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte02 VAR left(aVetInv[02,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd02 VAR aVetInv[02,4] PICTURE cPictQTD VALID FS_QTD(2) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[02,1]) .and. !lSair
		oQtd02:bGotFocus := {|| cNroI := "02" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq03 VAR strzero(03,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc03 VAR aVetInv[03,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes03 VAR substr(aVetInv[03,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte03 VAR left(aVetInv[03,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd03 VAR aVetInv[03,4] PICTURE cPictQTD VALID FS_QTD(3) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[03,1]) .and. !lSair
		oQtd03:bGotFocus := {|| cNroI := "03" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq04 VAR strzero(04,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc04 VAR aVetInv[04,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes04 VAR substr(aVetInv[04,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte04 VAR left(aVetInv[04,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd04 VAR aVetInv[04,4] PICTURE cPictQTD VALID FS_QTD(4) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[04,1]) .and. !lSair
		oQtd04:bGotFocus := {|| cNroI := "04" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq05 VAR strzero(05,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc05 VAR aVetInv[05,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes05 VAR substr(aVetInv[05,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte05 VAR left(aVetInv[05,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd05 VAR aVetInv[05,4] PICTURE cPictQTD VALID FS_QTD(5) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[05,1]) .and. !lSair
		oQtd05:bGotFocus := {|| cNroI := "05" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq06 VAR strzero(06,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc06 VAR aVetInv[06,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes06 VAR substr(aVetInv[06,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte06 VAR left(aVetInv[06,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd06 VAR aVetInv[06,4] PICTURE cPictQTD VALID FS_QTD(6) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[06,1]) .and. !lSair
		oQtd06:bGotFocus := {|| cNroI := "06" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq07 VAR strzero(07,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc07 VAR aVetInv[07,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes07 VAR substr(aVetInv[07,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte07 VAR left(aVetInv[07,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd07 VAR aVetInv[07,4] PICTURE cPictQTD VALID FS_QTD(7) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[07,1]) .and. !lSair
		oQtd07:bGotFocus := {|| cNroI := "07" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq08 VAR strzero(08,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc08 VAR aVetInv[08,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes08 VAR substr(aVetInv[08,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte08 VAR left(aVetInv[08,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd08 VAR aVetInv[08,4] PICTURE cPictQTD VALID FS_QTD(8) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[08,1]) .and. !lSair
		oQtd08:bGotFocus := {|| cNroI := "08" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq09 VAR strzero(09,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc09 VAR aVetInv[09,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes09 VAR substr(aVetInv[09,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte09 VAR left(aVetInv[09,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd09 VAR aVetInv[09,4] PICTURE cPictQTD VALID FS_QTD(9) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[09,1]) .and. !lSair
		oQtd09:bGotFocus := {|| cNroI := "09" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq10 VAR strzero(10,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc10 VAR aVetInv[10,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes10 VAR substr(aVetInv[10,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte10 VAR left(aVetInv[10,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd10 VAR aVetInv[10,4] PICTURE cPictQTD VALID FS_QTD(10) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[10,1]) .and. !lSair
		oQtd10:bGotFocus := {|| cNroI := "10" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq11 VAR strzero(11,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc11 VAR aVetInv[11,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes11 VAR substr(aVetInv[11,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte11 VAR left(aVetInv[11,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd11 VAR aVetInv[11,4] PICTURE cPictQTD VALID FS_QTD(11) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[11,1]) .and. !lSair
		oQtd11:bGotFocus := {|| cNroI := "11" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq12 VAR strzero(12,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc12 VAR aVetInv[12,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes12 VAR substr(aVetInv[12,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte12 VAR left(aVetInv[12,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd12 VAR aVetInv[12,4] PICTURE cPictQTD VALID FS_QTD(12) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[12,1]) .and. !lSair
		oQtd12:bGotFocus := {|| cNroI := "12" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq13 VAR strzero(13,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc13 VAR aVetInv[13,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes13 VAR substr(aVetInv[13,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte13 VAR left(aVetInv[13,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd13 VAR aVetInv[13,4] PICTURE cPictQTD VALID FS_QTD(13) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[13,1]) .and. !lSair
		oQtd13:bGotFocus := {|| cNroI := "13" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq14 VAR strzero(14,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc14 VAR aVetInv[14,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes14 VAR substr(aVetInv[14,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte14 VAR left(aVetInv[14,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd14 VAR aVetInv[14,4] PICTURE cPictQTD VALID FS_QTD(14) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[14,1]) .and. !lSair
		oQtd14:bGotFocus := {|| cNroI := "14" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq15 VAR strzero(15,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc15 VAR aVetInv[15,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes15 VAR substr(aVetInv[15,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte15 VAR left(aVetInv[15,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd15 VAR aVetInv[15,4] PICTURE cPictQTD VALID FS_QTD(15) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[15,1]) .and. !lSair
		oQtd15:bGotFocus := {|| cNroI := "15" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq16 VAR strzero(16,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc16 VAR aVetInv[16,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes16 VAR substr(aVetInv[16,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte16 VAR left(aVetInv[16,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd16 VAR aVetInv[16,4] PICTURE cPictQTD VALID FS_QTD(16) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[16,1]) .and. !lSair
		oQtd16:bGotFocus := {|| cNroI := "16" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq17 VAR strzero(17,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc17 VAR aVetInv[17,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes17 VAR substr(aVetInv[17,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte17 VAR left(aVetInv[17,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd17 VAR aVetInv[17,4] PICTURE cPictQTD VALID FS_QTD(17) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[17,1]) .and. !lSair
		oQtd17:bGotFocus := {|| cNroI := "17" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq18 VAR strzero(18,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc18 VAR aVetInv[18,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes18 VAR substr(aVetInv[18,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte18 VAR left(aVetInv[18,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd18 VAR aVetInv[18,4] PICTURE cPictQTD VALID FS_QTD(18) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[18,1]) .and. !lSair
		oQtd18:bGotFocus := {|| cNroI := "18" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq19 VAR strzero(19,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc19 VAR aVetInv[19,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes19 VAR substr(aVetInv[19,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte19 VAR left(aVetInv[19,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd19 VAR aVetInv[19,4] PICTURE cPictQTD VALID FS_QTD(19) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[19,1]) .and. !lSair
		oQtd19:bGotFocus := {|| cNroI := "19" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq20 VAR strzero(20,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc20 VAR aVetInv[20,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes20 VAR substr(aVetInv[20,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte20 VAR left(aVetInv[20,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd20 VAR aVetInv[20,4] PICTURE cPictQTD VALID FS_QTD(20) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[20,1]) .and. !lSair
		oQtd20:bGotFocus := {|| cNroI := "20" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq21 VAR strzero(21,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc21 VAR aVetInv[21,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes21 VAR substr(aVetInv[21,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte21 VAR left(aVetInv[21,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd21 VAR aVetInv[21,4] PICTURE cPictQTD VALID FS_QTD(21) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[21,1]) .and. !lSair
		oQtd21:bGotFocus := {|| cNroI := "21" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq22 VAR strzero(22,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc22 VAR aVetInv[22,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes22 VAR substr(aVetInv[22,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte22 VAR left(aVetInv[22,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd22 VAR aVetInv[22,4] PICTURE cPictQTD VALID FS_QTD(22) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[22,1]) .and. !lSair
		oQtd22:bGotFocus := {|| cNroI := "22" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq23 VAR strzero(23,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc23 VAR aVetInv[23,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes23 VAR substr(aVetInv[23,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte23 VAR left(aVetInv[23,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd23 VAR aVetInv[23,4] PICTURE cPictQTD VALID FS_QTD(23) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[23,1]) .and. !lSair
		oQtd23:bGotFocus := {|| cNroI := "23" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq24 VAR strzero(24,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc24 VAR aVetInv[24,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes24 VAR substr(aVetInv[24,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte24 VAR left(aVetInv[24,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd24 VAR aVetInv[24,4] PICTURE cPictQTD VALID FS_QTD(24) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[24,1]) .and. !lSair
		oQtd24:bGotFocus := {|| cNroI := "24" , oNroI:Refresh() }

		nX += 9
		@ nX,268 MSGET oSeq25 VAR strzero(25,2) SIZE 10,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,001 MSGET oLoc25 VAR aVetInv[25,2] SIZE 48,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,049 MSGET oDes25 VAR substr(aVetInv[25,3],33) SIZE 89,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,138 MSGET oIte25 VAR left(aVetInv[25,3],32) SIZE 80,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN .f.
		@ nX,218 MSGET oQtd25 VAR aVetInv[25,4] PICTURE cPictQTD VALID FS_QTD(25) SIZE 50,08 OF oContagem PIXEL COLOR CLR_BLUE WHEN !Empty(aVetInv[25,1]) .and. !lSair
		oQtd25:bGotFocus := {|| cNroI := "25" , oNroI:Refresh() }

		ACTIVATE MSDIALOG oContagem CENTER

	Else

		If cFase == "99" .and. lAltDiv .and. VPE->VPE_GERAB7 == "0" // Contagem Finalizada e o usuario tem permissao para Alterar Divergencias e ainda nao gerou NF/SB7
			FS_ALTDIV()
		Else
			MsgAlert(STR0024,STR0023) // Digitacao do Inventario NAO autorizada! / Atencao
		EndIf

	EndIf

EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRVOBS³ Autor ³  Andre Luis Almeida   ³ Data ³ 05/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravar o MEMO de Observacao do Inventario                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVOBS()
DbSelectArea("VPE")
RecLock("VPE",.f.)
	VPE->VPE_OBSERV := cObsInv
MsUnLock()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INICIAR³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Iniciar Inventario                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040INI()
Local lOk := .f.
If lCoorde
	Processa( {|| lOk := FS_INICIAR() } )
	If lOk
		OPM040EXE() // Manutencao
	EndIf
EndIf
Return()

////////////////////////////////////////////////
// Inventario de Pecas - Iniciar Inventario   //
////////////////////////////////////////////////
Static Function FS_INICIAR()
Local cArmRes := left(GetMV("MV_RESITE")+space(10),len(SB2->B2_LOCAL))
Local cArmBlq := left(GetMV("MV_BLQITE")+space(10),len(SB2->B2_LOCAL))
Local lSBZ    := ( SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" )
Local lOk     := .t.
Local ni      := 0
Local nTotSB1 := 0
Local nRecSB1 := 0
Local cAux    := ""
Local aAux    := {}
Local aMovSB1 := {}
Local aVlrSB1 := {}
Local aTotSB1 := {}
Local aIntCab := {}
//
Local cParInv := ""
Local cQuery  := ""
Local cQAlias := "SQLs"
//
Local cFilSB1 := xFilial("SB1")
Local cFilSBM := xFilial("SBM")
Local cFilSB2 := xFilial("SB2")
Local cFilSBE := xFilial("SBE")
Local cFilSBF := xFilial("SBF")
Local cFilSB5 := xFilial("SB5")
Local cFilSBZ := IIf(lSBZ,xFilial("SBZ"),"")
Local cFilSD1 := xFilial("SD1")
Local cFilSD2 := xFilial("SD2")
Local cFilSF4 := xFilial("SF4")
Local cFilVPE := xFilial("VPE")
Local cFilVPF := xFilial("VPF")
Local cFilVO2 := xFilial("VO2")
Local cFilVO3 := xFilial("VO3")
Local cFilVOI := xFilial("VOI")
//
Local cNamSB1 := RetSqlName("SB1")
Local cNamSBM := RetSqlName("SBM")
Local cNamSB2 := RetSqlName("SB2")
Local cNamSBE := RetSqlName("SBE")
Local cNamSBF := RetSqlName("SBF")
Local cNamSB5 := RetSqlName("SB5")
Local cNamSBZ := IIf(lSBZ,RetSqlName("SBZ"),"")
Local cNamSD1 := RetSqlName("SD1")
Local cNamSD2 := RetSqlName("SD2")
Local cNamSF4 := RetSqlName("SF4")
Local cNamVPE := RetSqlName("VPE")
Local cNamVPF := RetSqlName("VPF")
Local cNamVO2 := RetSqlName("VO2")
Local cNamVO3 := RetSqlName("VO3")
Local cNamVOI := RetSqlName("VOI")
//
Local cNAlias := ""
//
Local cMV_PAR03 := ""
Local cMV_PAR04 := ""
Local cMV_PAR05 := ""
Local cMV_PAR10 := ""
//
Local cErroInsert  := "" // Erro no Insert do Inventario - Cancelar Automaticamente o Inventario
//
Local aVetProb     := {}
//
Local lBZ_MARPEC   := ( lSBZ .and. SBZ->(FieldPos("BZ_MARPEC")) > 0 )
Local lBZ_CODLIN   := ( lSBZ .and. SBZ->(FieldPos("BZ_CODLIN")) > 0 )
Local lBZ_CODFAM   := ( lSBZ .and. SBZ->(FieldPos("BZ_CODFAM")) > 0 )
Local lBZ_CODCAI   := ( lSBZ .and. SBZ->(FieldPos("BZ_CODCAI")) > 0 )
Local lBZ_LOCALIZ  := ( lSBZ .and. SBZ->(FieldPos("BZ_LOCALIZ")) > 0 )
Local lBZ_LOCALI2  := ( lSBZ .and. SBZ->(FieldPos("BZ_LOCALI2")) > 0 )
Local lLocSoSBZ    := ( lSBZ .and. GetNewPar("MV_MIL0096","S") == "N" ) // A locação da peça também deve ser considerada na tabela SB5 quando o parâmetro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=Não Considera )
//
Local cSQLFilt1T   := "" // Filtro SQL 1 com .T.
Local cSQLFilt1F   := "" // Filtro SQL 1 com .F.
Local cSQLFilt2F   := "" // Filtro SQL 2 com .F.
//
Local lAddSB1      := .t.
Local cLocPad      := ""
//
Private aParamInv  := {} // Retorno dos Parametros do Inventario
Private oArHelper  := Dms_ArrayHelper():New()
Private oSqlHelper := Dms_SqlHelper():New()
//
Private cPictQTD     := SX3->(x3Picture("B2_QATU"))
//
If FS_PARAM() // Parametros do Inventario
	// ponto de entrada Antes do Inventario
	if ExistBlock("OPM040AI")   //
		if !ExecBlock("OPM040AI",.f.,.f.)
			Return(.f.)
		Endif
	Endif
	//
	If GetNewPar("MV_MIL0070","0") == "1" // Validar Intervalo de Localizacao
		///////////////////////////////////////////////////////////////////
		// Verificar Intervalo de Localizacao para Inventarios Em Aberto //
		///////////////////////////////////////////////////////////////////
		cQuery := "SELECT VPE.R_E_C_N_O_ RECVPE FROM "+cNamVPE+" VPE "
		cQuery += "WHERE VPE.VPE_FILIAL='"+cFilVPE+"' AND VPE.VPE_FASE NOT IN ('XX','99') AND ( "
		cQuery += "( '"+aParamInv[8,1]+"'<=VPE.VPE_LOCALI AND '"+aParamInv[9,1]+"'>=VPE.VPE_LOCALF ) OR "
		cQuery += "( '"+aParamInv[8,1]+"'>=VPE.VPE_LOCALI AND '"+aParamInv[9,1]+"'<=VPE.VPE_LOCALF ) OR "
		cQuery += "( '"+aParamInv[8,1]+"'<=VPE.VPE_LOCALI AND '"+aParamInv[9,1]+"'>=VPE.VPE_LOCALI ) OR "
		cQuery += "( '"+aParamInv[8,1]+"'<=VPE.VPE_LOCALF AND '"+aParamInv[9,1]+"'>=VPE.VPE_LOCALF ) "
		cQuery += ") AND VPE.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			MsgStop(STR0150,STR0023) // Existe(m) Inventário(s) Em Aberto no mesmo intervalo de Localização. Impossível continuar! / Atencao
			Return(.f.)
		EndIf
	EndIf
	//
	If len(aParamInv[03,1]) > 1 .and. right(aParamInv[03,1],1) == "/"
		aParamInv[03,1] := left(aParamInv[03,1],len(aParamInv[03,1])-1)
	EndIf
	If len(aParamInv[04,1]) > 1 .and. right(aParamInv[04,1],1) == "/"
		aParamInv[04,1] := left(aParamInv[04,1],len(aParamInv[04,1])-1)
	EndIf
	If len(aParamInv[05,1]) > 1 .and. right(aParamInv[05,1],1) == "/"
		aParamInv[05,1] := left(aParamInv[05,1],len(aParamInv[05,1])-1)
	EndIf
	If len(aParamInv[10,1]) > 1 .and. right(aParamInv[10,1],1) == "/"
		aParamInv[10,1] := left(aParamInv[10,1],len(aParamInv[10,1])-1)
	EndIf
	//
	cMV_PAR03 := IIf(!Empty(aParamInv[03,1]),FormatIN(Alltrim(aParamInv[03,1]),"/"),"")
	cMV_PAR04 := IIf(!Empty(aParamInv[04,1]),FormatIN(Alltrim(aParamInv[04,1]),"/"),"")
	cMV_PAR05 := IIf(!Empty(aParamInv[05,1]),FormatIN(Alltrim(aParamInv[05,1]),"/"),"")
	cMV_PAR10 := IIf(!Empty(aParamInv[10,1]),FormatIN(Alltrim(aParamInv[10,1]),"/"),"")
	//
	DbSelectArea("SB1")
	DbSelectArea("SB5")
	//
	cSQLFilt1T := FS_FILTROSQL(1,cFilSB1,cMV_PAR04,cMV_PAR05,cMV_PAR10,lBZ_MARPEC,lBZ_CODLIN,lBZ_CODFAM,lBZ_LOCALI2,lLocSoSBZ,lBZ_CODCAI,.T.) // Filtro SQL 1 com .T.
	cSQLFilt1F := FS_FILTROSQL(1,cFilSB1,cMV_PAR04,cMV_PAR05,cMV_PAR10,lBZ_MARPEC,lBZ_CODLIN,lBZ_CODFAM,lBZ_LOCALI2,lLocSoSBZ,lBZ_CODCAI,.F.) // Filtro SQL 1 com .F.
	cSQLFilt2F := FS_FILTROSQL(2,cFilSB1,cMV_PAR04,cMV_PAR05,cMV_PAR10,lBZ_MARPEC,lBZ_CODLIN,lBZ_CODFAM,lBZ_LOCALI2,lLocSoSBZ,lBZ_CODCAI,.F.) // Filtro SQL 2 com .F.
	//
	// Verificar Itens Reservados e/ou Bloqueados //
	If aParamInv[21,1] != "1"
		cQuery := "SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , COUNT(SB1.B1_COD) AS QTDE FROM "+cNamSB1+" SB1 "
		cQuery += "JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
		cQuery += "JOIN "+cNamSB2+" SB2 ON (SB2.B2_FILIAL='"+cFilSB2+"' AND SB1.B1_COD=SB2.B2_COD AND SB2.B2_LOCAL IN ('"+cArmRes+"','"+cArmBlq+"') AND SB2.B2_QATU>0 AND SB2.D_E_L_E_T_=' ') "
		cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
		If lSBZ
			cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
		EndIf
		If lEnderecado // Estoque esta Enderecado //
			cQuery += "LEFT JOIN "+cNamSBF+" SBF ON (SBF.BF_FILIAL='"+cFilSBF+"' AND SB1.B1_COD=SBF.BF_PRODUTO AND SBF.BF_LOCAL=SB2.B2_LOCAL AND SBF.D_E_L_E_T_=' ') "
		EndIf
		cQuery += cSQLFilt1T
		If !Empty(aParamInv[31,1])
			cQuery += "SB2.B2_DINVENT<'"+DTOS(aParamInv[31,1])+"' AND "
		EndIf
		cQuery += cSQLFilt2F
		cQuery += "GROUP BY SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC HAVING COUNT(SB1.B1_COD) > 0"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If !( cQAlias )->( Eof() )
			lOk := .f.
			Do While !( cQAlias )->( Eof() )
				aAdd(aVetProb,{ ( cQAlias )->( B1_GRUPO ) , ( cQAlias )->( B1_CODITE ) , ( cQAlias )->( B1_DESC ) , STR0184+" "+STR0185+" '"+cArmRes+"' / '"+cArmBlq+"'" }) // O Item esta Reservado/Bloqueado. Verifique os LOCAIS:
				( cQAlias )->( DbSkip() )
			EndDo
		EndIf
		( cQAlias )->( dbCloseArea() )
	EndIf

	               /////////////////////////////
	If lEnderecado // Estoque esta Enderecado //
	               /////////////////////////////

		// Verificar a existencia de divergencia entre a quantidade do SB2 e do SBF //
		cQuery := "SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SB2.B2_LOCAL , SB2.B2_QATU , SUM(SBF.BF_QUANT) AS BFQTD FROM "+cNamSB1+" SB1 "
		cQuery += "JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
		cQuery += "JOIN "+cNamSB2+" SB2 ON (SB2.B2_FILIAL='"+cFilSB2+"' AND SB1.B1_COD=SB2.B2_COD AND SB2.B2_LOCAL>='"+aParamInv[1,1]+"' AND SB2.B2_LOCAL<='"+aParamInv[2,1]+"' AND SB2.D_E_L_E_T_=' ') "
		cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
		If lSBZ
			cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
		EndIf
		cQuery += "LEFT JOIN "+cNamSBF+" SBF ON (SBF.BF_FILIAL='"+cFilSBF+"' AND SB1.B1_COD=SBF.BF_PRODUTO AND SBF.BF_LOCAL=SB2.B2_LOCAL AND SBF.D_E_L_E_T_=' ') "
		cQuery += cSQLFilt1T
		If !Empty(cMV_PAR03)
			cQuery += "SB2.B2_LOCAL NOT IN "+cMV_PAR03+" AND "
		EndIf
		If !Empty(aParamInv[31,1])
			cQuery += "SB2.B2_DINVENT<'"+DTOS(aParamInv[31,1])+"' AND "
		EndIf
		cQuery += cSQLFilt2F
		If lBZ_LOCALIZ
			cQuery += " AND ( SBZ.BZ_LOCALIZ = 'S' OR ( SBZ.BZ_LOCALIZ IS NULL AND SB1.B1_LOCALIZ = 'S' ) ) "
		Else
			cQuery += " AND SB1.B1_LOCALIZ = 'S' "
		EndIf
		//
		cQuery += "GROUP BY SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SB2.B2_LOCAL , SB2.B2_QATU HAVING SB2.B2_QATU > 0 AND SB2.B2_QATU <> SUM(SBF.BF_QUANT) "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If !( cQAlias )->( Eof() )
			lOk := .f.
			Do While !( cQAlias )->( Eof() )
				aAdd(aVetProb,{ ( cQAlias )->( B1_GRUPO ) , ( cQAlias )->( B1_CODITE ) , ( cQAlias )->( B1_DESC ) , STR0186+" "+( cQAlias )->( B2_LOCAL )+" - SB2 ( "+FG_AlinVlrs(Transform(( cQAlias )->( B2_QATU ),cPictQTD))+" ) x SBF ( "+FG_AlinVlrs(Transform(( cQAlias )->( BFQTD ),cPictQTD))+" )" }) // Divergencia na quantidade do Item Enderecado: Local
				( cQAlias )->( DbSkip() )
			EndDo
		EndIf
		( cQAlias )->( dbCloseArea() )
	EndIf

	// Verificar o preenchimento da LOCACAO dos Itens //
	cQuery := "SELECT SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SUM(SB2.B2_QATU) AS QTDE FROM "+cNamSB1+" SB1 "
	cQuery += "JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
	cQuery += "JOIN "+cNamSB2+" SB2 ON (SB2.B2_FILIAL='"+cFilSB2+"' AND SB1.B1_COD=SB2.B2_COD AND SB2.B2_LOCAL>='"+aParamInv[1,1]+"' AND SB2.B2_LOCAL<='"+aParamInv[2,1]+"' AND SB2.B2_QATU>0 AND SB2.D_E_L_E_T_=' ') "
	cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
	If lSBZ
		cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
	EndIf
	cQuery += cSQLFilt1T
	If !Empty(cMV_PAR03)
		cQuery += "SB2.B2_LOCAL NOT IN "+cMV_PAR03+" AND "
	EndIf
	If !Empty(aParamInv[31,1])
		cQuery += "SB2.B2_DINVENT<'"+DTOS(aParamInv[31,1])+"' AND "
	EndIf
	If lBZ_LOCALI2
		If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
			cQuery += "( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND "
		Else
			cQuery += "( ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND SB5.B5_LOCALI2=' ' ) AND "
		EndIf
	Else
		cQuery += "SB5.B5_LOCALI2=' ' AND "
	EndIf
	If lBZ_CODCAI
		cQuery += "( ( SBZ.BZ_CODCAI>='"+aParamInv[6,1]+"' AND SBZ.BZ_CODCAI<='"+aParamInv[7,1]+"' ) OR "+;
				"( ( SBZ.BZ_CODCAI IS NULL OR SBZ.BZ_CODCAI=' ' ) AND ( SB5.B5_COD IS NULL OR ( SB5.B5_CODCAI>='"+aParamInv[6,1]+"' AND SB5.B5_CODCAI<='"+aParamInv[7,1]+"' ) ) ) ) "
	Else
		cQuery += "( SB5.B5_COD IS NULL OR ( SB5.B5_CODCAI>='"+aParamInv[6,1]+"' AND SB5.B5_CODCAI<='"+aParamInv[7,1]+"' ) ) "
	EndIf
	// Se o estoque estiver ENDERECADO, essa checagem so pode ser feita com pecas que
	// nao serao ENDERECADAS
	If lEnderecado
		If lBZ_LOCALIZ
			cQuery += " AND ( SBZ.BZ_LOCALIZ IN ('N',' ') OR ( SBZ.BZ_LOCALIZ IS NULL AND SB1.B1_LOCALIZ IN ('N',' ') ) ) "
		Else
			cQuery += " AND SB1.B1_LOCALIZ IN ('N',' ') "
		EndIf
	EndIf
	//
	cQuery += "GROUP BY SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC HAVING SUM(SB2.B2_QATU) > 0"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	If !( cQAlias )->( Eof() )
		lOk := .f.
		Do While !( cQAlias )->( Eof() )
			aAdd(aVetProb,{ ( cQAlias )->( B1_GRUPO ) , ( cQAlias )->( B1_CODITE ) , ( cQAlias )->( B1_DESC ) , STR0187+" "+FG_AlinVlrs(Transform(( cQAlias )->( QTDE ),cPictQTD)) }) // O Item possui quantidade em estoque e esta sem localização. Quantidade:
			( cQAlias )->( DbSkip() )
		EndDo
	EndIf
	( cQAlias )->( dbCloseArea() )


Else
	lOk := .f.
EndIf
If lOk

	//
	DbSelectArea("VPE")
	cParInv := STR0152+" - "+UPPER(UsrRetName(__CUSERID))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0099+CHR(13)+CHR(10)
	cParInv += aParamInv[01,1]+" "+STR0153+" "+aParamInv[02,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	If !Empty(aParamInv[03,1])
		cParInv += STR0101+CHR(13)+CHR(10)
		cParInv += aParamInv[03,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	EndIf
	If !Empty(aParamInv[04,1])
		cParInv += STR0102+CHR(13)+CHR(10)
		cParInv += aParamInv[04,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	EndIf
	If !Empty(aParamInv[05,1])
		cParInv += STR0103+CHR(13)+CHR(10)
		cParInv += aParamInv[05,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	EndIf
	cParInv += STR0104+CHR(13)+CHR(10)
	cParInv += aParamInv[06,1]+" "+STR0153+" "+aParamInv[07,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0106+CHR(13)+CHR(10)
	cParInv += aParamInv[08,1]+" "+STR0153+" "+aParamInv[09,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	If !Empty(aParamInv[10,1])
		cParInv += STR0133+CHR(13)+CHR(10)
		cParInv += aParamInv[10,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	EndIf
	cParInv += STR0108+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[11,1]=="1",STR0114,IIf(aParamInv[11,1]=="2",STR0115,STR0116))+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0109+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[12,1]=="3",STR0117,STR0118)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0110+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[13,1]=="1",STR0112,STR0113)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0111+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[14,1]=="1",STR0112,STR0113)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	If aParamInv[15,1] <> "1"
		cParInv += STR0119+" "
		cParInv += Transform(aParamInv[16,1],"@D")+" "+STR0153+" "+Transform(aParamInv[17,1],"@D")+CHR(13)+CHR(10)
		cParInv += IIf(aParamInv[15,1]=="2",STR0121,IIf(aParamInv[15,1]=="3",STR0122,STR0123))
		cParInv += " - "+STR0099+" "+aParamInv[32,1]+" "+STR0153+" "+aParamInv[33,1]
	Else
		cParInv += STR0119+CHR(13)+CHR(10)
		cParInv += STR0120
	EndIf	
	cParInv += CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0126+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[18,1]=="1",STR0120,IIf(aParamInv[18,1]=="2",STR0127,STR0128))
	If aParamInv[18,1] <> "1"
		cParInv += " - "+Transform(aParamInv[19,1],"@E 999,999,999.99")+" "+STR0153+" "+Transform(aParamInv[20,1],"@E 999,999,999.99")
	EndIf
	cParInv += CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0131+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[21,1]=="1",STR0112,STR0113)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0132+CHR(13)+CHR(10)
	cParInv += IIf(aParamInv[22,1]=="1",STR0112,STR0113)+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	If lMLF // Possui Filtro por Marca/Linha/Familia
		cParInv += STR0135+" / "+STR0136+" / "+STR0137+CHR(13)+CHR(10)
		cParInv += aParamInv[23,1]+" / "+aParamInv[24,1]+" / "+aParamInv[25,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	ElseIf lFGS  // Possui Filtro por Familia/Grupo/SubGrupo
		cParInv += STR0173+" / "+STR0174+" / "+STR0175+CHR(13)+CHR(10)
		cParInv += aParamInv[26,1]+" / "+aParamInv[27,1]+" / "+aParamInv[28,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	EndIf
	cParInv += STR0181+": "+Transform(aParamInv[31,1],"@D")+CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cParInv += STR0178+": "+Transform(aParamInv[29,1],"@D") // Previsao de Termino
 	//
	DbSelectArea("VPE")
	RecLock("VPE",.t.)
	VPE->VPE_FILIAL := cFilVPE
	VPE->VPE_CODIGO := GetSx8Num("VPE","VPE_CODIGO")
	VPE->VPE_FASE   := "I1"
	VPE->VPE_DATINI := dDataBase
	VPE->VPE_HORINI := val(left(time(),2)+substr(time(),4,2))
	VPE->VPE_GERAB7 := "0"
	VPE->VPE_VALEST := aParamInv[11,1] // Valida contagens com estoque ? 1=Todas / 2=Apenas a 1a. / 3=Nao valida
	VPE->VPE_QTDCON := aParamInv[12,1] // Qtde. maxima de contagens ? 3 = 3 contagens / 5 = 5 contagens
	VPE->VPE_BLOQB1 := IIf(aParamInv[14,1]=="1","1","0") // Bloqueia Itens a inventariar ?
	VPE->VPE_SDOATU := IIf(aParamInv[22,1]=="1","1","0") // Atualiza saldo atual na digitacao ?
	VPE->VPE_LOCALI := aParamInv[8,1] // Localizacao Inicial
	VPE->VPE_LOCALF := aParamInv[9,1] // Localizacao Final
	VPE->VPE_PARINV := cParInv // Parametros do Inventario
	VPE->VPE_OBSERV := aParamInv[30,1] // Observacao
	MsUnLock()
	ConfirmSX8()
	//
	DbSelectArea("VPF")
	ProcRegua(3)
	IncProc(STR0028) // "Reutilizando registros..."
	//////////////////////////////////////////////////////////////////////////////////
	// Reutilizar tabela intermediaria se Inventario ja foi Finalizado ou Cancelado //
	//////////////////////////////////////////////////////////////////////////////////
	cQuery := "DELETE FROM "+cNamVPF+" WHERE VPF_FILIAL='"+cFilVPF+"' AND VPF_CODIGO IN "
	cQuery += "( SELECT VPE.VPE_CODIGO FROM "+cNamVPE+ " VPE WHERE VPE.VPE_FILIAL='" +cFilVPE+ "' AND VPE.VPE_FASE IN ('XX','99') AND VPE.D_E_L_E_T_=' ' )"
	TCSqlExec(cQuery)
	//
	IncProc(STR0053) // "Gerando Relacao dos Itens..."
	//
	If aParamInv[15,1] <> "1" // Movimentacoes
		For ni := 1 to 6
			cQuery := ""
			Do Case
				Case aParamInv[15,1] == "2" // Todas Movimentacoes ( 1/2=TRANSFERENCIAS / 3=REQUISICOES / 4=VENDAS / 5=DEVOLUCOES / 6=COMPRAS )
					cQuery := "SELECT DISTINCT SB1.B1_COD "
					If ni == 3 // Requisicoes/Devolucoes
						cQuery += " , VOI.VOI_CODALM , SB1.R_E_C_N_O_ RECSB1 "
					EndIf
				Case aParamInv[15,1] == "3" .and. ( ni == 4 .or. ni == 5 ) // 4=VENDAS / 5=DEVOLUCOES
					cQuery := "SELECT DISTINCT SB1.B1_COD "
				Case aParamInv[15,1] == "4" .and. ni == 6 // 6=COMPRAS
					cQuery := "SELECT DISTINCT SB1.B1_COD "
			EndCase
			If !Empty(cQuery)
				cQuery += "FROM "+cNamSB1+" SB1 "
				cQuery += "JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
				Do Case
					Case ni == 1 // Transferencia SAIDA
						cQuery += "JOIN "+cNamSD2+" SD2 ON ("
						cQuery += "    SD2.D2_FILIAL='"+cFilSD2+"' AND "
						cQuery += "    SD2.D2_EMISSAO>='"+dtos(aParamInv[16,1])+"' AND SD2.D2_EMISSAO<='"+dtos(aParamInv[17,1])+"' AND "
						cQuery += "    SD2.D2_COD=SB1.B1_COD AND "
						cQuery += "    SD2.D2_LOCAL>='"+aParamInv[32,1]+"' AND SD2.D2_LOCAL<='"+aParamInv[33,1]+"' AND "
						cQuery += "    SD2.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamSF4+" SF4 ON ("
						cQuery += "    SF4.F4_FILIAL='"+cFilSF4+"' AND "
						cQuery += "    SF4.F4_CODIGO=SD2.D2_TES AND "
						cQuery += "    SF4.F4_OPEMOV='03' AND "
						cQuery += "    SF4.D_E_L_E_T_=' ') "
					Case ni == 2 // Transferencia ENTRADA
						cQuery += "JOIN "+cNamSD1+" SD1 ON ("
						cQuery += "    SD1.D1_FILIAL='"+cFilSD1+"' AND "
						cQuery += "    SD1.D1_DTDIGIT>='"+dtos(aParamInv[16,1])+"' AND SD1.D1_DTDIGIT<='"+dtos(aParamInv[17,1])+"' AND "
						cQuery += "    SD1.D1_COD=SB1.B1_COD AND "
						cQuery += "    SD1.D1_LOCAL>='"+aParamInv[32,1]+"' AND SD1.D1_LOCAL<='"+aParamInv[33,1]+"' AND "
						cQuery += "    SD1.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamSF4+" SF4 ON ("
						cQuery += "    SF4.F4_FILIAL='"+cFilSF4+"' AND "
						cQuery += "    SF4.F4_CODIGO=SD1.D1_TES AND "
						cQuery += "    SF4.F4_OPEMOV='03' AND "
						cQuery += "    SF4.D_E_L_E_T_=' ') "
					Case ni == 3 // Requisicoes/Devoluções PECAS Oficina
						cQuery += "JOIN "+cNamVO3+" VO3 ON ("
						cQuery += "    VO3.VO3_FILIAL='"+cFilVO3+"' AND "
						cQuery += "    VO3.VO3_GRUITE=SB1.B1_GRUPO AND "
						cQuery += "    VO3.VO3_CODITE=SB1.B1_CODITE AND "
						cQuery += "    VO3.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamVOI+" VOI ON ("
						cQuery += "    VOI.VOI_FILIAL='"+cFilVOI+"' AND "
						cQuery += "    VOI.VOI_TIPTEM=VO3.VO3_TIPTEM AND "
						cQuery += "    VOI.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamVO2+" VO2 ON ("
						cQuery += "    VO2.VO2_FILIAL='"+cFilVO2+"' AND "
						cQuery += "    VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND "
						cQuery += "    VO2.VO2_DATREQ>='"+dtos(aParamInv[16,1])+"' AND VO2.VO2_DATREQ<='"+dtos(aParamInv[17,1])+"' AND "
						cQuery += "    VO2.D_E_L_E_T_=' ') "
					Case ni == 4 // VENDA
						cQuery += "JOIN "+cNamSD2+" SD2 ON ("
						cQuery += "    SD2.D2_FILIAL='"+cFilSD2+"' AND "
						cQuery += "    SD2.D2_EMISSAO>='"+dtos(aParamInv[16,1])+"' AND SD2.D2_EMISSAO<='"+dtos(aParamInv[17,1])+"' AND "
						cQuery += "    SD2.D2_COD=SB1.B1_COD AND "
						cQuery += "    SD2.D2_LOCAL>='"+aParamInv[32,1]+"' AND SD2.D2_LOCAL<='"+aParamInv[33,1]+"' AND "
						cQuery += "    SD2.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamSF4+" SF4 ON ("
						cQuery += "    SF4.F4_FILIAL='"+cFilSF4+"' AND "
						cQuery += "    SF4.F4_CODIGO=SD2.D2_TES AND "
						cQuery += "    SF4.F4_OPEMOV='05' AND "
						cQuery += "    SF4.D_E_L_E_T_=' ') "
					Case ni == 5 // DEVOLUCAO
						cQuery += "JOIN "+cNamSD1+" SD1 ON ("
						cQuery += "    SD1.D1_FILIAL='"+cFilSD1+"' AND "
						cQuery += "    SD1.D1_DTDIGIT>='"+dtos(aParamInv[16,1])+"' AND SD1.D1_DTDIGIT<='"+dtos(aParamInv[17,1])+"' AND "
						cQuery += "    SD1.D1_COD=SB1.B1_COD AND "
						cQuery += "    SD1.D1_LOCAL>='"+aParamInv[32,1]+"' AND SD1.D1_LOCAL<='"+aParamInv[33,1]+"' AND "
						cQuery += "    SD1.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamSF4+" SF4 ON ("
						cQuery += "    SF4.F4_FILIAL='"+cFilSF4+"' AND "
						cQuery += "    SF4.F4_CODIGO=SD1.D1_TES AND "
						cQuery += "    SF4.F4_OPEMOV='09' AND "
						cQuery += "    SF4.D_E_L_E_T_=' ') "
					Case ni == 6 // COMPRA
						cQuery += "JOIN "+cNamSD1+" SD1 ON ("
						cQuery += "    SD1.D1_FILIAL='"+cFilSD1+"' AND "
						cQuery += "    SD1.D1_DTDIGIT>='"+dtos(aParamInv[16,1])+"' AND SD1.D1_DTDIGIT<='"+dtos(aParamInv[17,1])+"' AND "
						cQuery += "    SD1.D1_COD=SB1.B1_COD AND "
						cQuery += "    SD1.D1_LOCAL>='"+aParamInv[32,1]+"' AND SD1.D1_LOCAL<='"+aParamInv[33,1]+"' AND "
						cQuery += "    SD1.D_E_L_E_T_=' ') "
						cQuery += "JOIN "+cNamSF4+" SF4 ON ("
						cQuery += "    SF4.F4_FILIAL='"+cFilSF4+"' AND "
						cQuery += "    SF4.F4_CODIGO=SD1.D1_TES AND "
						cQuery += "    SF4.F4_OPEMOV='01' AND "
						cQuery += "    SF4.D_E_L_E_T_=' ') "
				EndCase
				cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
				If lSBZ
					cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
				EndIf
				If lEnderecado // Estoque esta Enderecado //
					cQuery += "LEFT JOIN "+cNamSBF+" SBF ON (SBF.BF_FILIAL='"+cFilSBF+"' AND SBF.BF_PRODUTO=SB1.B1_COD AND "
					cQuery += "SBF.BF_LOCAL>='"+aParamInv[1,1]+"' AND SBF.BF_LOCAL<='"+aParamInv[2,1]+"' AND "
					If !Empty(cMV_PAR03)
						cQuery += "SBF.BF_LOCAL NOT IN "+cMV_PAR03+" AND "
					EndIf
					cQuery += "SBF.D_E_L_E_T_=' ') "
				EndIf
				lAddSB1 := .t.
				cQuery += cSQLFilt1T
				cQuery += cSQLFilt2F
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
				Do While !( cQAlias )->( Eof() )
					If ni == 3 // Requisicoes/Devolucoes PECAS Oficina
						lAddSB1 := .f.
						If ( cQAlias )->( VOI_CODALM ) >= aParamInv[32,1] .and. ( cQAlias )->( VOI_CODALM ) <= aParamInv[33,1]
							lAddSB1 := .t.
						Else
							SB1->(DbGoTo(( cQAlias )->( RECSB1 )))
							cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
							If cLocPad >= aParamInv[32,1] .and. cLocPad <= aParamInv[33,1]
								lAddSB1 := .t.
							EndIf
						EndIf
					EndIf
					If lAddSB1
						aAdd(aMovSB1,( cQAlias )->( B1_COD ))
					EndIf
					( cQAlias )->( DbSkip() )
				EndDo
				( cQAlias )->( dbCloseArea() )
			EndIf
		Next
		//
		aAux := {}
		cAux := ""
		aSort(aMovSB1)
		For ni := 1 to len(aMovSB1)
			If cAux <> aMovSB1[ni]
				aAdd(aAux,aMovSB1[ni])
				cAux := aMovSB1[ni]
			EndIf
		Next
		aMovSB1 := aClone(aAux)
		//
	EndIf
	//
	If aParamInv[18,1] <> "1"
		For ni := 1 to 2
			cQuery := ""
			If aParamInv[18,1] == "2" .and. ni == 1 // Valor de Venda
				cQuery := "SELECT DISTINCT SB1.B1_COD "
			ElseIf aParamInv[18,1] == "3" .and. ni == 2 // Valor de Custo
				cQuery := "SELECT DISTINCT SB1.R_E_C_N_O_ RECSB1 , SB2.B2_LOCAL "
			EndIf
			If !Empty(cQuery)
				cQuery += "FROM "+cNamSB1+" SB1 "
				cQuery += "JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
				If ni == 2 // Valor de Custo
					cQuery += "JOIN "+cNamSB2+" SB2 ON (SB2.B2_FILIAL='"+cFilSB2+"' AND SB2.B2_COD=SB1.B1_COD AND SB2.B2_CM1>="+str(aParamInv[19,1])+" AND SB2.B2_CM1<="+str(aParamInv[20,1])+" AND SB2.D_E_L_E_T_=' ') "
				EndIf
				cQuery += "LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB1.B1_COD=SB5.B5_COD AND SB5.D_E_L_E_T_=' ') "
				If lSBZ
					cQuery += "LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SB1.B1_COD=SBZ.BZ_COD AND SBZ.D_E_L_E_T_=' ') "
    			Endif
				If lEnderecado // Estoque esta Enderecado //
					cQuery += "LEFT JOIN "+cNamSBF+" SBF ON (SBF.BF_FILIAL='"+cFilSBF+"' AND SBF.BF_PRODUTO=SB1.B1_COD AND "
					cQuery += "SBF.BF_LOCAL>='"+aParamInv[1,1]+"' AND SBF.BF_LOCAL<='"+aParamInv[2,1]+"' AND "
					If !Empty(cMV_PAR03)
						cQuery += "SBF.BF_LOCAL NOT IN "+cMV_PAR03+" AND "
					EndIf
					cQuery += "SBF.D_E_L_E_T_=' ') "
				EndIf
				cQuery += cSQLFilt1F
				If ni == 1 // Valor de Venda
					cQuery += "AND SB1.B1_PRV1>="+str(aParamInv[19,1])+" AND SB1.B1_PRV1<="+str(aParamInv[20,1])
				ElseIf ni == 2 // Valor de Custo
					If !Empty(aParamInv[31,1])
						cQuery += " AND SB2.B2_DINVENT<'"+DTOS(aParamInv[31,1])+"'"
					EndIf
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
				If ni == 1 // Valor de Venda
					Do While !( cQAlias )->( Eof() )
						aAdd(aVlrSB1,( cQAlias )->( B1_COD ))
						( cQAlias )->( DbSkip() )
					EndDo
				ElseIf ni == 2 // Valor de Custo
					Do While !( cQAlias )->( Eof() )
						SB1->(DbGoTo(( cQAlias )->( RECSB1 )))
						If ( cQAlias )->( B2_LOCAL ) == FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
							aAdd(aVlrSB1,SB1->B1_COD)
						EndIf
						( cQAlias )->( DbSkip() )
					EndDo
				EndIf
				( cQAlias )->( dbCloseArea() )
			EndIf
		Next
	EndIf
	//
	Do Case
		Case aParamInv[15,1] <> "1" .and. aParamInv[18,1] <> "1" // SB1 especificos ( por Movimentacoes e Valores )
			For ni := 1 to len(aMovSB1)
				If ascan(aVlrSB1,aMovSB1[ni]) > 0 .and. ascan(aTotSB1,aMovSB1[ni]) <= 0 // Verifica se existe o mesmo Item por Valores
					aAdd(aTotSB1,aMovSB1[ni])
				EndIf
			Next
			For ni := 1 to len(aVlrSB1)
				If ascan(aMovSB1,aVlrSB1[ni]) > 0 .and. ascan(aTotSB1,aVlrSB1[ni]) <= 0 // Verifica se existe o mesmo Item por Movimentacoes
					aAdd(aTotSB1,aVlrSB1[ni])
				EndIf
			Next
		Case aParamInv[15,1] <> "1" // SB1 especificos ( somente por Movimentacoes )
			aTotSB1 := aClone(aMovSB1)
		Case aParamInv[18,1] <> "1" // SB1 especificos ( somente por Valores )
			aTotSB1 := aClone(aVlrSB1)
	EndCase
	//
	If aParamInv[15,1] <> "1" .or. aParamInv[18,1] <> "1" // SB1 especificos por Movimentacoes ou Valores
		If len(aTotSB1) <= 0
			Return(.f.) // 'SEM_ITENS_A_INVENTARIAR' Desconsiderar Inventario quando nao existir SB1 com Movimentacoes e/ou Valores
		EndIf
		nTotSB1 := 0
		aAux := {}
		For ni := 1 to len(aTotSB1)
			If nTotSB1 == 0
				aAdd(aAux,{})
			EndIf
			aAdd(aAux[len(aAux)],Alltrim(aTotSB1[ni]))
			nTotSB1++
			If nTotSB1 == 100 // Agrupar a cada 100 Pecas
				nTotSB1 := 0
			EndIf
		Next
		aTotSB1 := aClone(aAux)
	Else
		aAdd(aTotSB1,{}) // Nao filtrar SB1 por Movimentacoes ou Valores - trazer todos SB1
	EndIf
	//

	cQuery := ""
	cQuery += " SELECT DISTINCT * FROM ( "
	cQuery +=	"SELECT '" + cFilVPF + "' C1, '"+VPE->VPE_CODIGO+"' CODVPE, TEMP.B2_LOCAL C2, "
	If lEnderecado
		cQuery += 		" CASE "
		cQuery += 			" WHEN TEMP.ENDERECAMENTO = 'S' THEN COALESCE( SBF.BF_LOCALIZ , ' ' ) "
		If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
			cQuery += 			" ELSE COALESCE(TEMP.BZ_LOCALI2,' ') "
		Else
			cQuery += 			" ELSE COALESCE(TEMP.BZ_LOCALI2,TEMP.B5_LOCALI2,' ') "
		EndIf
		cQuery += 		" END LOCALIZACAO, "
	Else
		If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
			cQuery += 		" COALESCE(TEMP.BZ_LOCALI2,' ') LOCALIZACAO, "
		Else
			cQuery += 		" CASE "
			cQuery += 			" WHEN TEMP.BZ_LOCALI2 IS NULL OR TEMP.BZ_LOCALI2 = ' ' THEN TEMP.B5_LOCALI2 "
			cQuery += 			" ELSE TEMP.BZ_LOCALI2 "
			cQuery += 		" END LOCALIZACAO, "
		EndIf
	EndIf
	cQuery += 			"' ' c3, TEMP.B1_GRUPO c4, TEMP.B1_CODITE c5, TEMP.B2_QATU c6, 0 c7,0 c8,0 c9,0 c10,0 c11, '0' c12,'0' c13, "
	If lEnderecado
		cQuery += 			" CASE "
		cQuery += 				" WHEN TEMP.ENDERECAMENTO = 'S' AND SBE.BE_DTINV <> ' ' THEN '0' "
		cQuery += 				" WHEN TEMP.ENDERECAMENTO = 'N' AND TEMP.B2_DTINV <> ' ' THEN '0' "
		cQuery += 				" ELSE '1' "
		cQuery += 			" END C14 "
	Else
		cQuery += 			" CASE "
		cQuery += 				" WHEN TEMP.B2_DTINV <> ' ' THEN '0' "
		cQuery += 				" ELSE '1' "
		cQuery += 			" END C14 "
	EndIf
	If lEnderecado
		cQuery += 		" , "
		cQuery += 		" CASE "
		cQuery += 			" WHEN TEMP.ENDERECAMENTO = 'S' THEN COALESCE(SBF.BF_QUANT, 0) "
		cQuery += 			" ELSE 0 "
		cQuery += 		" END C15 "
		cQuery += 		" , "
		cQuery += 		" CASE "
		cQuery += 			" WHEN TEMP.ENDERECAMENTO = 'S' THEN '1' " // Item Enderecado
		cQuery += 			" ELSE '0' " // Não Enderecado
		cQuery += 		" END C16 "
	Else
		cQuery += 		" , 0 C15 "
		cQuery += 		" , '0' C16 " // Não Enderecado
	EndIf
	cQuery += 	" FROM "
	cQuery += 		" ( SELECT B1_COD, B1_GRUPO, B1_CODITE, "
	cQuery += 				 " B2_LOCAL, B2_QATU, B2_DINVFIM, B2_DTINV, "
	If lEnderecado
		If lBZ_LOCALIZ
			cQuery +=		 " CASE "
			cQuery +=			 " WHEN BZ_LOCALIZ <> ' ' THEN BZ_LOCALIZ "
			cQuery +=			 " ELSE B1_LOCALIZ "
			cQuery +=		 " END ENDERECAMENTO, "
		Else
			cQuery +=		 " B1_LOCALIZ ENDERECAMENTO, "
		EndIf
	Else
		cQuery += 			 " 'N' ENDERECAMENTO, "
	EndIf
	cQuery += IIF( !lBZ_LOCALI2 , " NULL AS " , "" ) + " BZ_LOCALI2, "
	If lBZ_CODCAI
		cQuery +=			 " CASE "
		cQuery +=				 " WHEN BZ_CODCAI <> ' ' THEN BZ_CODCAI "
		cQuery +=				 " ELSE B5_CODCAI "
		cQuery +=			 " END CODCAI, "
	Else
		cQuery +=			 " B5_CODCAI CODCAI, "
	EndIf
	cQuery +=				 " B5_LOCALI2 "
	cQuery += 			" FROM "+cNamSB1+" SB1 "
	cQuery += 				"JOIN "+cNamSBM+" SBM ON (SBM.BM_FILIAL='"+cFilSBM+"' AND SBM.BM_GRUPO=SB1.B1_GRUPO AND SBM.BM_TIPGRU NOT IN ('4','7') AND SBM.D_E_L_E_T_=' ') " // Nao mostrar SB1 de 4-SERVICOS e 7-VEICULOS
	cQuery += 				"JOIN "+cNamSB2+" SB2 ON (SB2.B2_FILIAL='"+cFilSB2+"' AND SB2.B2_COD=SB1.B1_COD AND SB2.D_E_L_E_T_=' ') "
	If lSBZ
		cQuery +=			"LEFT JOIN "+cNamSBZ+" SBZ ON (SBZ.BZ_FILIAL='"+cFilSBZ+"' AND SBZ.BZ_COD=SB1.B1_COD AND SBZ.D_E_L_E_T_=' ') "
	EndIf
	cQuery += 				"LEFT JOIN "+cNamSB5+" SB5 ON (SB5.B5_FILIAL='"+cFilSB5+"' AND SB5.B5_COD=SB1.B1_COD AND SB5.D_E_L_E_T_=' ') "
	cQuery += 			cSQLFilt1T

	cQuery += " ( "
	If aParamInv[13,1] == "1" // 1=Sim 2=Nao ( Listar Itens com Estoque zerado ? )
		cQuery += " SB2.B2_COD IS NULL OR "
	EndIf
	cQuery += " ( "
	cQuery += 			"SB2.B2_LOCAL >= '"+aParamInv[1,1]+"' AND SB2.B2_LOCAL <= '"+aParamInv[2,1]+"' "
	If !Empty(cMV_PAR03)
		cQuery +=		"AND SB2.B2_LOCAL NOT IN " + cMV_PAR03 + " "
	EndIf
	If !Empty(aParamInv[31,1])
		cQuery += 		"AND SB2.B2_DINVENT < '"+DTOS(aParamInv[31,1])+"' "
	EndIf
	If aParamInv[13,1] <> "1" // 1=Sim 2=Nao ( Listar Itens com Estoque zerado ? )
		cQuery += 		"AND SB2.B2_QATU <> 0 "
	EndIf
	cQuery += " ) ) "
	If lBZ_CODCAI
		cQuery += "AND ( ( SBZ.BZ_CODCAI>='"+aParamInv[6,1]+"' AND SBZ.BZ_CODCAI<='"+aParamInv[7,1]+"' ) OR "+;
				    "( ( SBZ.BZ_CODCAI IS NULL OR SBZ.BZ_CODCAI=' ' ) AND ( SB5.B5_COD IS NULL OR ( SB5.B5_CODCAI>='"+aParamInv[6,1]+"' AND SB5.B5_CODCAI<='"+aParamInv[7,1]+"' ) ) ) )"
	Else
		cQuery += "AND ( SB5.B5_COD IS NULL OR ( SB5.B5_CODCAI>='"+aParamInv[6,1]+"' AND SB5.B5_CODCAI<='"+aParamInv[7,1]+"' ) )"
	EndIf
	cQuery += " ) TEMP "
	If lEnderecado
		cQuery += "LEFT JOIN "+cNamSBF+" SBF ON (SBF.BF_FILIAL = '" + cFilSBF + "' AND SBF.BF_LOCAL = TEMP.B2_LOCAL AND SBF.BF_PRODUTO = TEMP.B1_COD AND SBF.D_E_L_E_T_=' ') "
		cQuery += "LEFT JOIN "+cNamSBE+" SBE ON (SBE.BE_FILIAL = '" + cFilSBE + "' AND SBE.BE_LOCAL = SBF.BF_LOCAL AND SBE.BE_LOCALIZ = SBF.BF_LOCALIZ AND SBF.D_E_L_E_T_ = ' ')"
	EndIf
	cQuery += " ) TEMP2 "
	cQuery += "WHERE LOCALIZACAO>='"+IIf(!Empty(aParamInv[8,1]),aParamInv[8,1],space(len(SB5->B5_LOCALI2)-1)+"0")+"'"
	cQuery +=  " AND LOCALIZACAO<='"+aParamInv[9,1]+"' "
	if !Empty(cMV_PAR10)
		cQuery += "AND LOCALIZACAO NOT IN "+cMV_PAR10+""
	Endif
	//
	For nTotSB1 := 1 to len(aTotSB1)
		cQueryInsert := cQuery
		If aParamInv[15,1] <> "1" .or. aParamInv[18,1] <> "1" // SB1 especificos por Movimentacoes ou Valores
			If len(aTotSB1[nTotSB1]) > 0 // Filtrar SB1
				cQueryInsert += " AND "+oSqlHelper:Concat({"c4","c5"})+" IN ( SELECT "+oSqlHelper:Concat({"SB1A.B1_GRUPO","SB1A.B1_CODITE"})+;
																			  " FROM "+cNamSB1+" SB1A " + ;
																			"WHERE SB1A.B1_FILIAL='"+cFilSB1+"'" + ;
																			   " AND SB1A.D_E_L_E_T_=' ' " + ;
																			   " AND SB1A.B1_COD IN ('" + oArHelper:Join( aTotSB1[nTotSB1] , "','" ) + "') ) "
			Else
				cQueryInsert += " AND c5 = 'SEM_ITENS_A_INVENTARIAR' " // Desconsiderar Levantamento TOTAL
			EndIf
		EndIf
		// Sintaxe que cria registros a partir de um select, os 2 selects acima deve retornar o
		// mesmo numero de colunas se B5 ou BZ para criacao de registros sem erros
		// E possivel adicionar mais campos porém deve-se atualiza-los abaixo tambem
		// RowCountFunc vai retornar um sequencial no select
		cQueryInsert := oSqlHelper:RowCountFunc(cQueryInsert, " (ORDER BY C1) ", " (SELECT COALESCE(MAX(R_E_C_N_O_), 0) FROM "+RetSQLName("VPF")+") + ")
		cQueryInsert := "INSERT INTO " +RetSQLName("VPF")+ ;
			" ( R_E_C_N_O_ , VPF_FILIAL , VPF_CODIGO " +;
			" , VPF_ALMOX  , VPF_LOCAC  , VPF_NROREL " +;
			" , VPF_GRUITE , VPF_CODITE , VPF_QTDEST " +;
			" , VPF_CONTA1 , VPF_CONTA2 , VPF_CONTA3 , VPF_CONTA4 , VPF_CONTA5 " +;
			" , VPF_OK     , VPF_OKDIG  , VPF_ITEBLO " +;
			" , VPF_QTDEND , VPF_ITEEND ) " +;
			cQueryInsert
		//
		nStatus := TCSqlExec( cQueryInsert )
		If ( nStatus < 0 )
			cErroInsert := STR0183+CHR(13)+CHR(10)+CHR(13)+CHR(10)+TCSQLError() // O banco de dados apresentou o erro abaixo. Favor entrar em contato com o administrador do sistema.
			MsgStop(cErroInsert,STR0023) // Atencao
			lOk := .f.
		EndIf
	Next
	//
	If lOk .and. VPE->VPE_BLOQB1 == "1" // Bloquear Item para Inventariar
		// SBE //
		cQuery := "SELECT DISTINCT SBE.R_E_C_N_O_ AS RECSBE FROM "+cNamVPF+" VPF "
		cQuery += "JOIN "+cNamSBE+" SBE ON SBE.BE_FILIAL='"+cFilSBE+"' AND SBE.BE_LOCAL=VPF.VPF_ALMOX  AND SBE.BE_LOCALIZ=VPF.VPF_LOCAC AND SBE.D_E_L_E_T_=' ' "
		cQuery += "WHERE VPF.VPF_FILIAL='"+cFilVPF+"' "+;
					"AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"' "+;
					"AND VPF.VPF_ITEBLO='1' "+;
					"AND VPF.VPF_ITEEND='1' "+;
					"AND VPF.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		Do While !( cQAlias )->( Eof() )
			DbSelectArea("SBE")
			DbGoto(( cQAlias )->( RECSBE ))
			RecLock("SBE",.f.)
				SBE->BE_DTINV := dDataBase
			MsUnLock()
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
		// SB2 //
		cQuery := "SELECT DISTINCT SB2.R_E_C_N_O_ AS RECSB2 FROM "+cNamVPF+" VPF "
		cQuery += "JOIN "+cNamSB1+" SB1 ON SB1.B1_FILIAL='"+cFilSB1+"' AND SB1.B1_GRUPO=VPF.VPF_GRUITE AND SB1.B1_CODITE=VPF.VPF_CODITE AND SB1.D_E_L_E_T_=' ' "
		cQuery += "JOIN "+cNamSB2+" SB2 ON SB2.B2_FILIAL='"+cFilSB2+"' AND SB2.B2_LOCAL=VPF.VPF_ALMOX  AND SB2.B2_COD=SB1.B1_COD        AND SB2.D_E_L_E_T_=' ' "
		cQuery += "WHERE VPF.VPF_FILIAL='"+cFilVPF+"' "+;
					"AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"' "+;
					"AND VPF.VPF_ITEBLO='1' "+;
					"AND VPF.VPF_ITEEND<>'1' "+;
					"AND VPF.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		Do While !( cQAlias )->( Eof() )
			DbSelectArea("SB2")
			DbGoto(( cQAlias )->( RECSB2 ))
			RecLock("SB2",.f.)
				SB2->B2_DTINV   := dDataBase // Data Atual
				SB2->B2_DINVFIM := aParamInv[29,1] // Data Prevista para Termino
			MsUnLock()
			( cQAlias )->( DbSkip() )
		EndDo
		( cQAlias )->( dbCloseArea() )
	EndIf
	//
	DbSelectArea("VPE")
	//
EndIf
If !lOk
	If len(aVetProb) > 0
		If MsgYesNo(STR0188+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0189,STR0023) // Impossivel continuar! / Existe(m) inconsistência(s) no Estoque. Deseja visualizar? / Atencao
			aAdd(aIntCab,{ RetTitle("B1_GRUPO") , "C" ,  20 , "@!" })
			aAdd(aIntCab,{ RetTitle("B1_CODITE"), "C" ,  50 , "@!" })
			aAdd(aIntCab,{ RetTitle("B1_DESC")  , "C" , 100 , "@!" })
			aAdd(aIntCab,{ STR0191              , "C" , 350 , "@!" }) // Inconsistência
			aSort(aVetProb,1,,{|x,y| x[1]+x[2] < y[1]+y[2] })
			FGX_VISINT( "OFIPM040" , STR0190 , aIntCab , aVetProb , .t. ) // Inconsistência(s) ao Iniciar o Inventário
		EndIf
	EndIf
	If !Empty(cErroInsert) // Erro no Insert do Inventario - Cancelar Automaticamente o Inventario
		DbSelectArea("VPE")
		RecLock("VPE",.f.)
		VPE->VPE_FASE   := "XX"
		VPE->VPE_DATFIN := dDataBase
		VPE->VPE_HORFIN := val(left(time(),2)+substr(time(),4,2))
		VPE->VPE_OBSERV := IIf(!Empty(VPE->VPE_OBSERV),VPE->VPE_OBSERV+CHR(13)+CHR(10)+CHR(13)+CHR(10),"")+STR0182+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cErroInsert // CANCELADO AUTOMATICAMENTE
		MsUnLock()
	EndIf
EndIf
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTROSQL³ Autor ³  Andre Luis Almeida ³ Data ³ 17/01/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Filtros no SB1 que sao utilizados em varios SQLs     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTROSQL(nTp,cFilSB1,cMV_PAR04,cMV_PAR05,cMV_PAR10,lBZ_MARPEC,lBZ_CODLIN,lBZ_CODFAM,lBZ_LOCALI2,lLocSoSBZ,lBZ_CODCAI,lAND_FIM)
Local cRetQuery := ""
//////////////////////////////
If nTp == 1
//////////////////////////////
	cRetQuery += "WHERE SB1.B1_FILIAL='"+cFilSB1+"' AND "
	If !Empty(cMV_PAR04)
		cRetQuery += "SB1.B1_GRUPO IN "+cMV_PAR04+" AND "
	EndIf
	If !Empty(cMV_PAR05)
		cRetQuery += "SB1.B1_GRUPO NOT IN "+cMV_PAR05+" AND "
	EndIf
	If lMLF // Filtro por Marca/Linha/Familia
		If !Empty(aParamInv[23,1])
			If lBZ_MARPEC
				cRetQuery += "(( SBZ.BZ_MARPEC='"+aParamInv[23,1]+"' ) OR "+;
							"( ( SBZ.BZ_MARPEC IS NULL OR SBZ.BZ_MARPEC=' ' ) AND SB5.B5_MARPEC='"+aParamInv[23,1]+"' ) ) AND "
			Else
				cRetQuery += "SB5.B5_MARPEC='"+aParamInv[23,1]+"' AND "
			EndIf
		EndIf
		If !Empty(aParamInv[24,1])
			If lBZ_CODLIN
				cRetQuery += "(( SBZ.BZ_CODLIN='"+aParamInv[24,1]+"' ) OR "+;
							"( ( SBZ.BZ_CODLIN IS NULL OR SBZ.BZ_CODLIN=' ' ) AND SB5.B5_CODLIN='"+aParamInv[24,1]+"' ) ) AND "
			Else
				cRetQuery += "SB5.B5_CODLIN='"+aParamInv[24,1]+"' AND "
			EndIf
		EndIf
		If !Empty(aParamInv[25,1])
			If lBZ_CODFAM
				cRetQuery += "(( SBZ.BZ_CODFAM='"+aParamInv[25,1]+"' ) OR "+;
							"( ( SBZ.BZ_CODFAM IS NULL OR SBZ.BZ_CODFAM=' ' ) AND SB5.B5_CODFAM='"+aParamInv[25,1]+"' ) ) AND "
			Else
				cRetQuery += "SB5.B5_CODFAM='"+aParamInv[25,1]+"' AND "
			EndIf
		EndIf
	ElseIf lFGS // Filtro por Familia/Grupo/SubGrupo
		If !Empty(aParamInv[26,1])
			cRetQuery += "SB1.B1_FAMAPL='"+aParamInv[26,1]+"' AND "
		EndIf
		If !Empty(aParamInv[27,1])
			cRetQuery += "SB1.B1_GRUAPL='"+aParamInv[27,1]+"' AND "
		EndIf
		If !Empty(aParamInv[28,1])
			cRetQuery += "SB1.B1_SUBAPL='"+aParamInv[28,1]+"' AND "
		EndIf
	EndIf
	cRetQuery += "SB1.D_E_L_E_T_=' '"
//////////////////////////////
ElseIf nTp == 2
//////////////////////////////
	//
	If lEnderecado // Estoque esta Enderecado //
		If lBZ_LOCALI2
			If !Empty(aParamInv[8,1])
				If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
					cRetQuery += "(( SBF.BF_LOCALIZ >= '"+aParamInv[8,1]+"' AND SBF.BF_LOCALIZ<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SBZ.BZ_LOCALI2 >= '"+aParamInv[8,1]+"' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
				Else
					cRetQuery += "(( SBF.BF_LOCALIZ >= '"+aParamInv[8,1]+"' AND SBF.BF_LOCALIZ<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SBZ.BZ_LOCALI2 >= '"+aParamInv[8,1]+"' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND SB5.B5_LOCALI2>='"+aParamInv[8,1]+"' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
				EndIf
			Else
				If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
					cRetQuery += "(( SBF.BF_LOCALIZ > ' ' AND SBF.BF_LOCALIZ<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SBZ.BZ_LOCALI2 > ' ' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
				Else
					cRetQuery += "(( SBF.BF_LOCALIZ > ' ' AND SBF.BF_LOCALIZ<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SBZ.BZ_LOCALI2 > ' ' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND SB5.B5_LOCALI2>' ' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
				EndIf
			EndIf
			If !Empty(cMV_PAR10)
				If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
					cRetQuery += "(( SBF.BF_LOCALIZ NOT IN "+cMV_PAR10+" ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SBZ.BZ_LOCALI2 NOT IN "+cMV_PAR10+" ) ) AND "
				Else
					cRetQuery += "(( SBF.BF_LOCALIZ NOT IN "+cMV_PAR10+" ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SBZ.BZ_LOCALI2 NOT IN "+cMV_PAR10+" ) OR "+;
								"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND SB5.B5_LOCALI2 NOT IN "+cMV_PAR10+" ) ) AND "
				EndIf
			EndIf
		Else
			If !Empty(aParamInv[8,1])
				cRetQuery += "(( SBF.BF_LOCALIZ >= '"+aParamInv[8,1]+"' AND SBF.BF_LOCALIZ<='"+aParamInv[9,1]+"' ) OR "+;
							"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SB5.B5_LOCALI2>='"+aParamInv[8,1]+"' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
			Else
				cRetQuery += "(( SBF.BF_LOCALIZ > ' ' AND SBF.BF_LOCALIZ<='"+aParamInv[9,1]+"' ) OR "+;
							"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SB5.B5_LOCALI2>' ' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
			EndIf
			If !Empty(cMV_PAR10)
				cRetQuery += "(( SBF.BF_LOCALIZ NOT IN "+cMV_PAR10+" ) OR "+;
							"( ( SBF.BF_LOCALIZ IS NULL OR SBF.BF_LOCALIZ=' ' ) AND SB5.B5_LOCALI2 NOT IN "+cMV_PAR10+" ) ) AND "
			EndIf
		EndIf
	Else // Estoque NAO esta Enderecado //
		If lBZ_LOCALI2
			If !Empty(aParamInv[8,1])
				If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
					cRetQuery += "SBZ.BZ_LOCALI2>='"+aParamInv[8,1]+"' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' AND "
				Else
					cRetQuery += "(( SBZ.BZ_LOCALI2>='"+aParamInv[8,1]+"' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND SB5.B5_LOCALI2>='"+aParamInv[8,1]+"' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
				EndIf
			Else
				If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
					cRetQuery += "SBZ.BZ_LOCALI2>' ' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' AND "
				Else
					cRetQuery += "(( SBZ.BZ_LOCALI2>' ' AND SBZ.BZ_LOCALI2<='"+aParamInv[9,1]+"' ) OR "+;
								"( ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND  SB5.B5_LOCALI2>' ' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' ) ) AND "
				EndIf
			EndIf
			If !Empty(cMV_PAR10)
				If lLocSoSBZ // Trabalha somente com a LOCACAO no SBZ ?
					cRetQuery += "SBZ.BZ_LOCALI2 NOT IN "+cMV_PAR10+" AND "
				Else
					cRetQuery += "(( SBZ.BZ_LOCALI2 NOT IN "+cMV_PAR10+" ) OR "+;
								"( ( SBZ.BZ_LOCALI2 IS NULL OR SBZ.BZ_LOCALI2=' ' ) AND SB5.B5_LOCALI2 NOT IN "+cMV_PAR10+" ) ) AND "
				EndIf
			EndIf
		Else
			If !Empty(aParamInv[8,1])
				cRetQuery += "SB5.B5_LOCALI2>='"+aParamInv[8,1]+"' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' AND "
			Else
				cRetQuery += "SB5.B5_LOCALI2>' ' AND SB5.B5_LOCALI2<='"+aParamInv[9,1]+"' AND "
			EndIf
			If !Empty(cMV_PAR10)
				cRetQuery += "SB5.B5_LOCALI2 NOT IN "+cMV_PAR10+" AND "
			EndIf
		EndIf
	EndIf
	If lBZ_CODCAI
		cRetQuery += "(( SBZ.BZ_CODCAI>='"+aParamInv[6,1]+"' AND SBZ.BZ_CODCAI<='"+aParamInv[7,1]+"' ) OR "+;
					"( ( SBZ.BZ_CODCAI IS NULL OR SBZ.BZ_CODCAI=' ' ) AND ( SB5.B5_COD IS NULL OR ( SB5.B5_CODCAI>='"+aParamInv[6,1]+"' AND SB5.B5_CODCAI<='"+aParamInv[7,1]+"' ) ) ) )"
	Else
		cRetQuery += "( SB5.B5_COD IS NULL OR ( SB5.B5_CODCAI>='"+aParamInv[6,1]+"' AND SB5.B5_CODCAI<='"+aParamInv[7,1]+"' ) )"
	EndIf
//////////////////////////////
EndIf
//////////////////////////////
cRetQuery += IIf(lAND_FIM," AND "," ")
Return(cRetQuery)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AVANCAR³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avanca / Volta Fase do Inventario                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AVANCAR(cTipo)
Local cQuery    := ""
Local cFaseNova := cFase
Local lRet      := .t.
If cTipo == "+" // Avancar Fase
	Do Case
		Case cFase == "00" // Inicia
			cFaseNova := "I1"
		Case ( VPE->VPE_QTDCON == "3" .and. cFase == "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase == "I6" ) // Impressao Final
			lRet := .f.
			If MsgYesNo(STR0040,STR0023) // "Deseja realmente ENCERRAR o Inventario?" / "Atencao"
				lRet := .t.
				cFaseNova := "99" // Finaliza a Contagem
				lCancela  := .f.
				FS_DESBLOQIT() // Desbloquear Itens
			EndIf
		Case left(cFase,1)=="I" // Impressoes (1/2/3/4/5)
			cFaseNova := "D"+right(cFase,1)
		Case cFase == "D1" // 1 Digitacao
			lRet := .f.
			If FS_VERDIG() .and. MsgYesNo(STR0032,STR0023) // "Deseja realmente ENCERRAR a Digitacao da 1a. Contagem?" / "Atencao"
				lRet := .t.
				cFaseNova := "I2"
			EndIf
		Case cFase == "D2" // 2 Digitacao
			lRet := .f.
			If FS_VERDIG() .and. MsgYesNo(STR0035,STR0023) // "Deseja realmente ENCERRAR a Digitacao da 2a. Contagem?" / "Atencao"
				lRet := .t.
				cFaseNova := "I3"
			EndIf
		Case cFase == "D3" // 3 Digitacao
			lRet := .f.
			If VPE->VPE_QTDCON == "3" .or. FS_VERDIG()
				If FS_VERDIG() .and. MsgYesNo(STR0038,STR0023) // "Deseja realmente ENCERRAR a Digitacao da 3a. Contagem?" / "Atencao"
					lRet := .t.
					cFaseNova := "I4"
				EndIf
			EndIf
		Case cFase == "D4" // 4 Digitacao
			lRet := .f.
			If FS_VERDIG() .and. MsgYesNo(STR0080,STR0023) // "Deseja realmente ENCERRAR a Digitacao da 4a. Contagem?" / "Atencao"
				lRet := .t.
				cFaseNova := "I5"
			EndIf
		Case cFase == "D5" // 5 Digitacao
			lRet := .f.
			If FS_VERDIG() .and. MsgYesNo(STR0083,STR0023) // "Deseja realmente ENCERRAR a Digitacao da 5a. Contagem?" / "Atencao"
				lRet := .t.
				cFaseNova := "I6"
			EndIf
	EndCase
Else // Voltar Fase
	If	VPE->VPE_QTDCON == "3" // Maximo 3 contagens
		If cFase == "I4" // 4 Impressao
			cFaseNova := "D3"
		EndIf
	Else // Maximo 5 contagens
		If cFase == "I6" // 6 Impressao
			cFaseNova := "D5"
		EndIf
	EndIf
EndIf
If lRet
	DbSelectArea("VPE")
	RecLock("VPE",.f.)
	VPE->VPE_FASE := cFaseNova
	MsUnLock()
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VERDIG³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verificando digitacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERDIG()
Local lOk := .t.
Local ni  := 0
DbSelectArea("VPF")
DbSetOrder(4) // VPF_FILIAL+VPF_CODIGO+VPF_NROREL
If DbSeek(xFilial("VPF")+VPE->VPE_CODIGO+"00000101")
	ProcRegua(RecCount()/800)
	While !Eof() .and. xFilial("VPF") == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO .and. lOk
		ni++
		If ni == 800
			ni := 0
			IncProc(STR0041) // "Verificando Qtde. Digitada..."
		EndIf
		If VPF->VPF_OKDIG == "0"
			MsgAlert(STR0042+left(VPF->VPF_NROREL,6)+" - "+right(VPF->VPF_NROREL,2),STR0023) // "Ha Itens SEM a Digitacao! Pagina/Item: " / "Atencao"
			lOk := .f.
		EndIf
		DbSelectArea("VPF")
		DbSkip()
	EndDo
EndIf
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FINAL ³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finalizar Inventario                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FINAL()
Local lOk      := .t.
Local nDiv     := 0
Local ni       := 0
Local nQtdEstq := 0
If FS_VERDIG()
	lOk := .f.
	If FS_AVANCAR("+")
		DbSelectArea("VPE")
		RecLock("VPE",.f.)
		VPE->VPE_DATFIN := dDataBase
		VPE->VPE_HORFIN := val(left(time(),2)+substr(time(),4,2))
		MsUnLock()
		DbSelectArea("VPF")
		DbSetOrder(4)
		DbSeek(xFilial("VPF")+VPE->VPE_CODIGO)
		ProcRegua(RecCount()/800)
		While !Eof() .and. xFilial("VPF") == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO
			ni++
			If ni == 800
				ni := 0
				IncProc(STR0043) // "Gerando Arquivo de Divergencias de Itens..."
			EndIf
			lOk      := .f.
			nDiv     := 0
			nQtdEstq := IIf(VPF->VPF_ITEEND=="1",VPF->VPF_QTDEND,VPF->VPF_QTDEST) // Item Enderecado? 1=Sim (SBF=QTD.ENDERECO) / 0=Nao (SB2=QTD.ESTOQUE)
			Do Case
				Case VPF->VPF_OK == "2"
					If VPF->VPF_CONTA2 <> nQtdEstq
						lOk := .t.
						nDiv := ( VPF->VPF_CONTA2 - nQtdEstq )
					EndIf
				Case VPF->VPF_OK == "3"
					If VPF->VPF_CONTA3 <> nQtdEstq
						lOk := .t.
						nDiv := ( VPF->VPF_CONTA3 - nQtdEstq )
					EndIf
				Case VPF->VPF_OK == "4"
					If VPF->VPF_CONTA4 <> nQtdEstq
						lOk := .t.
						nDiv := ( VPF->VPF_CONTA4 - nQtdEstq )
					EndIf
				Case VPF->VPF_OK == "5"
					If VPF->VPF_CONTA5 <> nQtdEstq
						lOk := .t.
						nDiv := ( VPF->VPF_CONTA5 - nQtdEstq )
					EndIf
			EndCase
			If lOk
				DbSelectArea("SB1")
				DbSetOrder(7)
				DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek(xFilial("SB2") + SB1->B1_COD + VPF->VPF_ALMOX )
				DbSelectArea("VPG")
				RecLock("VPG",.t.)
				VPG->VPG_FILIAL := xFilial("VPG")
				VPG->VPG_CODIGO := VPE->VPE_CODIGO
				VPG->VPG_GRUITE := VPF->VPF_GRUITE
				VPG->VPG_CODITE := VPF->VPF_CODITE
				VPG->VPG_ALMOX  := VPF->VPF_ALMOX
				VPG->VPG_LOCAC  := VPF->VPF_LOCAC
				VPG->VPG_ITEEND := VPF->VPF_ITEEND
				VPG->VPG_QTDEND := VPF->VPF_QTDEND
				VPG->VPG_QTDEST := VPF->VPF_QTDEST
				VPG->VPG_CONTA  := &("VPF->VPF_CONTA"+VPF->VPF_OK)
				VPG->VPG_DIVERG := nDiv
				VPG->VPG_CUSTO  := Round(( nDiv * SB2->B2_CM1 ),TamSx3("VPG_CUSTO")[2])
				MsUnLock()
			EndIf
			DbSelectArea("VPF")
			DbSkip()
		EndDo
	EndIf
Else
	FS_AVANCAR("-")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CANCELAR³ Autor ³  Andre Luis Almeida  ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar / Abortar Inventario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CANCELAR()
If MsgYesNo(STR0044,STR0023) // Deseja realmente CANCELAR o Inventario? / Atencao
	lCancela := .t.
	FS_DESBLOQIT()
	DbSelectArea("VPE")
	RecLock("VPE",.f.)
	VPE->VPE_FASE   := "XX"
	VPE->VPE_DATFIN := dDataBase
	VPE->VPE_HORFIN := val(left(time(),2)+substr(time(),4,2))
	MsUnLock()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_IMPRIMIR³ Autor ³  Andre Luis Almeida  ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir Fases (1/2/3/4/5) do Inventario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR()
Local lOk       := .f.
Local nTCodIte  := 0
Local ni        := 0
Local niF       := 0
Local niI       := 0
Local cAlm      := "INICIAL"
Local cNroRelI  := "000001"
Local cNroRelF  := "999999"
Local cImprSeq  := ""
Local cImprimir := ""
Local nImprimir := 0
Local lAgrupou  := .f.
Local cFilVPF   := xFilial("VPF")
Local cQuery    := ""
Local cQAlias   := "SQLs"
Private cDesc1  := STR0001 // "INVENTARIO"
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "P"
Private limite  := 80
Private cString := "VPF"
Private titulo  := STR0001+" ( "+VPE->VPE_CODIGO+" )" // "INVENTARIO"
Private cabec1  := ""
Private cabec2  := STR0052 // "Locacao         Item                                                    Qtde. Sq"
Private aReturn := {STR0050,1,STR0051,1,2,1,"",1} // "Zebrado" / "Administracao"
Private nomeprog:= "OFIPM040_"+right(cFase,1)
Private aLinha  := { },nLastKey := 0
Private cPerg   := nil
If !(( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" ))
	nomeprog := left(nomeprog,len(nomeprog)-1)+"D"
EndIf
cAgrAx := ""
If left(cFase,1) == "I" .and. ( ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" ) )
	DbSelectArea("VPF")
	ProcRegua(RecCount()/800)
	cQuery := "SELECT VPF.R_E_C_N_O_ RECVPF FROM "+RetSqlName("VPF")+" VPF "
	cQuery += "WHERE VPF.VPF_FILIAL='"+cFilVPF+"' AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"' AND VPF.VPF_CODITE<>' ' AND VPF.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY VPF.VPF_ALMOX , VPF.VPF_LOCAC , VPF.VPF_CODITE "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() ) //
		ni++
		If ni == 800
			ni := 0
			IncProc(STR0053) // "Gerando Relacao dos Itens..."
		EndIf
		VPF->(DbGoTo(( cQAlias )->( RECVPF )))
		If VPF->VPF_OK == "0" .and. !Empty(VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_GRUITE+VPF->VPF_CODITE)
			If cAgrup == "S"
				If cAgrAx <> VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_CODITE
					cAgrAx := VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_CODITE
				Else
					niI--
				EndIf
			EndIf
			niI++
			If niI > 25 .or. cAlm <> VPF->VPF_ALMOX
				cAlm :=  VPF->VPF_ALMOX
				niI := 1
				niF++
			EndIf
			DbSelectArea("VPF")
			RecLock("VPF",.f.)
			VPF->VPF_NROREL := strzero(niF,6)+strzero(niI,2)
			VPF->VPF_OKDIG  := "0"
			MsUnlock()
		Else
			DbSelectArea("VPF")
			RecLock("VPF",.f.)
			VPF->VPF_NROREL := " "
			VPF->VPF_OKDIG  := "0"
			MsUnlock()
		EndIf
		//
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	//
	////////////////////////////////////////////////////////////////////////////////////////
	// PE utilizado para manipular/gravar a sequencia dos Pecas para a Contagem           //
	// Ordem Default: VPF_ALMOX (Local) + VPF_LOCAC (Endereco) + VPF_CODITE (Cod.Item)    //
	////////////////////////////////////////////////////////////////////////////////////////
	// ATENCAO - Alterar somente os registros que possuem conteudo no VPF->VPF_NROREL     //
    // Campo a ser gravado: VPF->VPF_NROREL - Caracter 8 - Prencher com: NNNNNNII         //
    //       NNNNNN = Numero da Folha (de 000001 a 999999)                                //
	//       II     = Sequencia do Item na Folha (de 01 a 25 por folha)                   //
	////////////////////////////////////////////////////////////////////////////////////////
	// RecLock("VPF",.f.)                                                                 //
	//     VPF->VPF_NROREL := NNNNNNII                                                    //
	// MsUnLock()                                                                         //
	////////////////////////////////////////////////////////////////////////////////////////
	If ExistBlock("OPM040SEQ")                                                            //
		ExecBlock("OPM040SEQ",.f.,.f.,{VPE->VPE_CODIGO})                                  //
	EndIf                                                                                 //
	////////////////////////////////////////////////////////////////////////////////////////
	//
EndIf
//
cQuery := "SELECT MAX(VPF_NROREL)"
cQuery += "  FROM "+RetSQLName("VPF")
cQuery += " WHERE VPF_FILIAL = '" + xFilial("VPF")  + "'"
cQuery += "   AND VPF_CODIGO = '" + VPE->VPE_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cAux := FM_SQL(cQuery) // Pegar ultimo registro da Filial/Inventario
//
nTCodIte := OPM040TCOD() // Pegar tamanho maximo de caracteres gravados no campo VPF_CODITE
//
DbSelectArea("VPF")
DbSetOrder(4)
DbSeek(xFilial("VPF")+VPE->VPE_CODIGO+cAux)
If Empty(VPF->VPF_NROREL)
	MsgStop(STR0054,STR0023) // "NAO existe Itens para a Impressao!" / "Atencao"
	If cFase <> "I1"
		If VPE->VPE_QTDCON == "3" // Maximo 3 contagens
			cFase := "I4"
		Else // Maximo 5 contagens
			cFase := "I6"
		EndIf
		FS_FINAL() // Finalizar Inventario
	EndIf
Else
	If left(cFase,1) == "I" .and. ( ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" ) )
		FS_AVANCAR("+")
	EndIf
	cNroRelF := left(VPF->VPF_NROREL,6)
	If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
		DEFINE MSDIALOG oNroRel FROM 000,000 TO 008,030 TITLE STR0055 OF oMainWnd // "Paginas para Impressao"
		@ 011,035 SAY STR0056 SIZE 100,08 OF oNroRel PIXEL COLOR CLR_BLUE // "Inicial:"
		@ 010,055 MSGET oNroRelI VAR cNroRelI PICTURE "999999" VALID (cNroRelI:=strzero(val(cNroRelI),6)) SIZE 20,08 OF oNroRel PIXEL COLOR CLR_BLUE
		@ 023,035 SAY STR0057 SIZE 100,08 OF oNroRel PIXEL COLOR CLR_BLUE // "Final:"
		@ 022,055 MSGET oNroRelF VAR cNroRelF PICTURE "999999" VALID (cNroRelF:=strzero(val(cNroRelF),6)) SIZE 20,08 OF oNroRel PIXEL COLOR CLR_BLUE
		@ 040,020 BUTTON oOK PROMPT STR0058 OF oNroRel SIZE 080,10 PIXEL ACTION (lOk:=.t.,oNroRel:End()) // "<<<    OK    >>>"
		ACTIVATE MSDIALOG oNroRel CENTER
	Else
		lOk := .t.
	EndIf
	If lOk
		If ExistBlock("OPM040R") // Relatorio dos Itens a serem contados
			ExecBlock("OPM040R",.f.,.f.,{cNroRelI,cNroRelF})
		Else
			nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
			If nLastKey == 27
				Return
			EndIf
			SetDefault(aReturn,cString)
			nLin  := 0
			m_pag := 1
			Set Printer to &nomeprog
			Set Printer On
			Set Device  to Printer
			DbSelectArea("VPE")
			cabec1 := left(cTitulo+space(10)+Transform(VPE->VPE_DATINI,"@D")+space(46),56)
			cAlm := "INICIAL"
			niF := 0
			niI := 0
			cAgrAx := ""
			DbSelectArea("VPF")
			DbSetOrder(4)
			DbSeek(cFilVPF+VPE->VPE_CODIGO+cNroRelI+"01")
			ProcRegua(RecCount()/800)
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
			If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
				cImprimir := left(	VPF->VPF_LOCAC+" "+;
									VPF->VPF_GRUITE+" "+;
									left(VPF->VPF_CODITE,nTCodIte)+" "+;
									SB1->B1_DESC+;
									space(69),69)+" "
			Else
				cImprimir := left(	VPF->VPF_LOCAC+" "+;
									VPF->VPF_GRUITE+" "+;
									left(VPF->VPF_CODITE,nTCodIte)+" "+;
									SB1->B1_DESC+;
									space(60),60)
			EndIf
			cImprSeq  := right(VPF->VPF_NROREL,2)
			nImprimir := IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5) // Maximo 3 ou 5 contagens
			cAgrAx := ""
			DbSelectArea("VPF")
			While !Eof() .and. cFilVPF == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO .and. (VPF->VPF_NROREL <= cNroRelF+"25")
				ni++
				If ni == 800
					ni := 0
					IncProc(STR0059) // "Imprimindo Itens..."
				EndIf
				If VPF->VPF_OK == "0" .or. ( VPE->VPE_QTDCON == "3" .and. VPF->VPF_OK == "3" ) .or. ( VPE->VPE_QTDCON == "5" .and. VPF->VPF_OK == "5" )
					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
					If cAgrup == "S"
						If cAgrAx <> VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_CODITE
							If !lAgrupou
								If !Empty(cAgrAx)
									If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
										@ nLin++, 00 PSAY cImprimir+"_______ "+cImprSeq
									Else
										@ nLin++, 00 PSAY cImprimir+right(Transform(nImprimir,cPictQTD),17)+" "+cImprSeq
									EndIf
									nLin++
								EndIf
							EndIf
							If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
								cImprimir := left(	VPF->VPF_LOCAC+" "+;
													VPF->VPF_GRUITE+" "+;
													left(VPF->VPF_CODITE,nTCodIte)+" "+;
													SB1->B1_DESC+;
													space(69),69)+" "
							Else
								cImprimir := left(	VPF->VPF_LOCAC+" "+;
													VPF->VPF_GRUITE+" "+;
													left(VPF->VPF_CODITE,nTCodIte)+" "+;
													SB1->B1_DESC+;
													space(60),60)
							EndIf
							cImprSeq  := right(VPF->VPF_NROREL,2)
							nImprimir := IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5) // Maximo 3 ou 5 contagens
							lAgrupou := .f.
						Else
							nImprimir := IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5) // Maximo 3 ou 5 contagens
							If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
								@ nLin++, 00 PSAY left(cImprimir,16)+"****"+substr(cImprimir,21)+"_______ "+cImprSeq
							Else
								@ nLin++, 00 PSAY left(cImprimir,16)+"****"+substr(cImprimir,21)+right(Transform(nImprimir,cPictQTD),17)+" "+cImprSeq
							EndIf
							nLin++
							lAgrupou  := .t.
						EndIf
						cAgrAx := VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_CODITE
						If cAlm <> VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
							If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
								If cAlm <> "INICIAL"
									@ nLin++, 00 PSAY STR0060 // "Contado por ________________________       Digitado por ________________________"
								EndIf
							EndIf
							cAlm := VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
							m_pag := val(left(VPF->VPF_NROREL,6))
							cabec1 := left(cabec1,55)+" "+STR0049+VPF->VPF_ALMOX+"  "+Alltrim(STR0061)+left(VPF->VPF_NROREL,6) // "Armazem: " / "Pag.:"
							nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
						EndIf
					Else
						If cAlm <> VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
							If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
								If cAlm <> "INICIAL"
									@ nLin++, 00 PSAY STR0060 // "Contado por ________________________       Digitado por ________________________"
								EndIf
							EndIf
							cAlm := VPF->VPF_ALMOX+left(VPF->VPF_NROREL,6)
							m_pag := val(left(VPF->VPF_NROREL,6))
							cabec1 := left(cabec1,55)+" "+STR0049+VPF->VPF_ALMOX+"  "+Alltrim(STR0061)+left(VPF->VPF_NROREL,6) // "Armazem: " / "Pag.:"
							nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
						EndIf
						If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
							@ nLin++, 00 PSAY left(	VPF->VPF_LOCAC+" "+;
													VPF->VPF_GRUITE+" "+;
													left(VPF->VPF_CODITE,nTCodIte)+" "+;
													SB1->B1_DESC+;
													space(69),69)+" "+;
													"_______ "+;
													right(VPF->VPF_NROREL,2)
						Else
							@ nLin++, 00 PSAY left(	VPF->VPF_LOCAC+" "+;
													VPF->VPF_GRUITE+" "+;
													left(VPF->VPF_CODITE,nTCodIte)+" "+;
													SB1->B1_DESC+;
													space(60),60)+;
													right(Transform(IIf(VPE->VPE_QTDCON=="3",VPF->VPF_CONTA3,VPF->VPF_CONTA5),cPictQTD),17)+" "+;
													right(VPF->VPF_NROREL,2)
						EndIf
						nLin++
					EndIf
				EndIf
				DbSelectArea("VPF")
				DbSkip()
			EndDo
			If cAgrup == "S"
				If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
					@ nLin++, 00 PSAY cImprimir+"_______ "+cImprSeq
				Else
					@ nLin++, 00 PSAY cImprimir+right(Transform(nImprimir,cPictQTD),17)+" "+cImprSeq
				EndIf
				nLin++
			EndIf
			If ( VPE->VPE_QTDCON == "3" .and. cFase <> "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase <> "I6" )
				If cAlm <> "INICIAL"
					@ nLin++, 00 PSAY STR0060 // "Contado por ________________________       Digitado por ________________________"
				EndIf
			EndIf
			Set Printer to
			Set Device to Screen
			If aReturn[5] == 1
				OurSpool( nomeprog )
			EndIf
			MS_Flush()
		EndIf
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PESQ  ³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa Pagina/Itens para Digitacao (1/2/3/4/5)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQ()
Local ni      := 0
Local cFilVPF := xFilial("VPF")
cAlmox := ""
cAgrAx := ""
For ni := 1 to 25
	&("aVetInv["+strzero(ni,2)+",1]") := " "
	&("aVetInv["+strzero(ni,2)+",2]") := " "
	&("aVetInv["+strzero(ni,2)+",3]") := " "
	&("aVetInv["+strzero(ni,2)+",4]") := 0
Next
ni := 0
DbSelectArea("VPF")
DbSetOrder(4)
If DbSeek(cFilVPF+VPE->VPE_CODIGO+cNroP+"01")
	While !Eof() .and. cFilVPF == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO .and. left(VPF->VPF_NROREL,6) == cNroP .and. ni <= 25
		cAlmox := STR0049+VPF->VPF_ALMOX  // "Armazem: "
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+VPF->VPF_GRUITE+VPF->VPF_CODITE)
		nQtd := 0
		Do Case
			Case cFase == "D1"
				nQtd := VPF->VPF_CONTA1
			Case cFase == "D2"
				nQtd := VPF->VPF_CONTA2
			Case cFase == "D3"
				nQtd := VPF->VPF_CONTA3
			Case cFase == "D4"
				nQtd := VPF->VPF_CONTA4
			Case cFase == "D5"
				nQtd := VPF->VPF_CONTA5
		EndCase
		ni++
		&("aVetInv["+strzero(ni,2)+",1]") := left(VPF->VPF_NROREL,6)+"-"+right(VPF->VPF_NROREL,2)
		&("aVetInv["+strzero(ni,2)+",2]") := VPF->VPF_LOCAC
		&("aVetInv["+strzero(ni,2)+",3]") := VPF->VPF_GRUITE+" "+VPF->VPF_CODITE+SB1->B1_DESC
		&("aVetInv["+strzero(ni,2)+",4]") := nQtd
		cAgrAx := VPF->VPF_CODIGO+VPF->VPF_NROREL
		DbSelectArea("VPF")
		DbSkip()
		If cAgrup == "S"
			While cAgrAx == VPF->VPF_CODIGO+VPF->VPF_NROREL
				Do Case
					Case cFase == "D1"
						nQtd += VPF->VPF_CONTA1
					Case cFase == "D2"
						nQtd += VPF->VPF_CONTA2
					Case cFase == "D3"
						nQtd += VPF->VPF_CONTA3
					Case cFase == "D4"
						nQtd += VPF->VPF_CONTA4
					Case cFase == "D5"
						nQtd += VPF->VPF_CONTA5
				EndCase
				&("aVetInv["+strzero(ni,2)+",3]") := "**** "+VPF->VPF_CODITE+SB1->B1_DESC
				&("aVetInv["+strzero(ni,2)+",4]") := nQtd
				DbSelectArea("VPF")
				DbSkip()
			EndDo
		EndIf
	EndDo
	ni := 0
	For ni := 1 to 25
		&("oLoc"+strzero(ni,2)):Refresh()
		&("oDes"+strzero(ni,2)):Refresh()
		&("oIte"+strzero(ni,2)):Refresh()
		&("oQtd"+strzero(ni,2)):Refresh()
	Next
Else
	cNroP := "000001"
	cNroI := "01"
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FASE  ³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica a Fase do Inventario                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FASE()
Local lRet := .t.
If Empty(VPE->VPE_DATFIN) .and. VPE->(RecCount())>0
	cFase := VPE->VPE_FASE
	If cFaseX <> "00" .and. cFaseX <> cFase
		lRet := .f.
	ElseIf cFaseX == "00"
		cFaseX  := cFase
	EndIf
Else
	If !Empty(VPE->VPE_FASE)
		cFase := VPE->VPE_FASE
	EndIf
EndIf
cTitulo := ""
Do Case
	Case cFase == "I1"
		cTitulo := STR0030 // "Impressao para 1a. Contagem"
	Case cFase == "D1"
		cTitulo := STR0031 // "Digitacao da 1a. Contagem"
	Case cFase == "I2"
		cTitulo := STR0033 // "Impressao para 2a. Contagem"
	Case cFase == "D2"
		cTitulo := STR0034 // "Digitacao da 2a. Contagem"
	Case cFase == "I3"
		cTitulo := STR0036 // "Impressao para 3a. Contagem"
	Case cFase == "D3"
		cTitulo := STR0037 // "Digitacao da 3a. Contagem"
	Case cFase == "I4"
		If VPE->VPE_QTDCON == "3" // Maximo 3 contagens
			cTitulo := STR0039 // "3a. Contagem - Qtde Digitada"
		Else // Maximo 5 contagens
			cTitulo := STR0078 // "Impressao para 4a. Contagem"
		EndIf
	Case cFase == "D4"
		cTitulo := STR0079 // "Digitacao da 4a. Contagem"
	Case cFase == "I5"
		cTitulo := STR0081 // "Impressao para 5a. Contagem"
	Case cFase == "D5"
		cTitulo := STR0082 // "Digitacao da 5a. Contagem"
	Case cFase == "I6"
		cTitulo := STR0084 // "5a. Contagem - Qtde Digitada"
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_QTD   ³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera Qtde da Contagem do Item                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_QTD(ni)
Local lRet     := .t.
Local cAux     := ""
If !Empty(&("aVetInv["+strzero(ni,2)+",1]"))
	If FS_FASE()
		nQtd := &("aVetInv["+strzero(ni,2)+",4]")
		DbSelectArea("VPF")
		DbSetOrder(4)
		If DbSeek(xFilial("VPF")+VPE->VPE_CODIGO+left(&("aVetInv["+strzero(ni,2)+",1]"),6)+right(&("aVetInv["+strzero(ni,2)+",1]"),2))
			//
			OPM040QTD( nQtd , 0 , cFase , cAgrup ) // Grava Qtde Digitada no VPF
			//
		EndIf
		If ni == 25 .or. Empty(&("aVetInv["+strzero(ni+1,2)+",1]")) // Quando ultimo item da pagina/folha, comeca no 1o.item da proxima pagina
			cNroP := strzero(val(cNroP)+1,6)
			cNroI := "01"
			FS_PESQ()
			oQtd01:SetFocus()
		EndIf
	Else
		lSair := .t.
		MsgAlert(STR0045,STR0023) // "O Inventario mudou de Fase!" / "Atencao"
		lRet  := .f.
		cNroI := strzero(ni,2)
		oNroI:Refresh()
	EndIf
Else
	oNroP:SetFocus()
	nQtd := 0
EndIf
cAux := FM_SQL("SELECT MAX(VPF_NROREL) FROM "+RetSQLName("VPF")+" WHERE VPF_FILIAL='"+xFilial("VPF")+"' AND VPF_CODIGO='"+VPE->VPE_CODIGO+"' AND D_E_L_E_T_=' '") // Pegar ultimo registro da Filial/Inventario
DbSelectArea("VPF")
DbSetOrder(4)
DbSeek(xFilial("VPF")+VPE->VPE_CODIGO+cAux)
If left(&("aVetInv["+strzero(ni,2)+",1]"),6)+right(&("aVetInv["+strzero(ni,2)+",1]"),2) == VPF->VPF_NROREL
	cNroP := "000000"
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPM040QTD³ Autor ³  Andre Luis Almeida   ³ Data ³ 10/01/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava Qtde da Contagem do Item ( VPF posicionado )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040QTD( _nQtd , _RecVPF , _cFase , _cAgrup )
Local nQtdEstq  := 0
Default _RecVPF := 0
Default _cFase  := VPE->VPE_FASE // Foi necessario declarar a Variavel cFase pois a funcao é chamada de outro fonte
Default _cAgrup := left(GetNewPar("MV_CONTAGR","N"),1) // Foi necessario declarar a Variavel cAgrup pois a funcao é chamada de outro fonte
If _RecVPF > 0
	DbSelectArea("VPF")
	DbGoTo(_RecVPF)
EndIf
//////////////////////////////////////////////////////////
// Atualiza SALDO ATUAL da PECA no momento da digitacao //
//////////////////////////////////////////////////////////
If VPE->VPE_SDOATU == "1"
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2") + SB1->B1_COD + VPF->VPF_ALMOX )
	DbSelectArea("VPF")
	RecLock("VPF",.f.)
	VPF->VPF_QTDEST := SB2->B2_QATU // Atualiza o SALDO ATUAL da PECA
	If VPF->VPF_ITEEND == "1"  // Item Enderecado? 1=Sim / 0=Nao
		VPF->VPF_QTDEND := FM_SQL("SELECT BF_QUANT FROM "+RetSQLName("SBF")+" WHERE BF_FILIAL='"+xFilial("SBF")+"' AND BF_LOCAL='"+VPF->VPF_ALMOX+"' AND BF_LOCALIZ='"+VPF->VPF_LOCAC+"' AND BF_PRODUTO='"+SB1->B1_COD+"' AND D_E_L_E_T_=' '")
	EndIf
	MsUnLock()
EndIf
//////////////////////////////////////////////////////////
If _cAgrup == "S"
	RecLock("VPF",.f.)
	Do Case
		Case _cFase == "D1"
			VPF->VPF_CONTA1 := _nQtd
		Case _cFase == "D2"
			VPF->VPF_CONTA2 := _nQtd
		Case _cFase == "D3"
			VPF->VPF_CONTA3 := _nQtd
		Case _cFase == "D4"
			VPF->VPF_CONTA4 := _nQtd
		Case _cFase == "D5"
			VPF->VPF_CONTA5 := _nQtd
	EndCase
	MsUnLock()
	FS_AGRUPA(VPF->VPF_NROREL,_cFase)
Else
	nQtdEstq := IIf(VPF->VPF_ITEEND=="1",VPF->VPF_QTDEND,VPF->VPF_QTDEST) // Item Enderecado? 1=Sim (SBF=QTD.ENDERECO) / 0=Nao (SB2=QTD.ESTOQUE)
	RecLock("VPF",.f.)
	Do Case
		Case _cFase == "D1"
			VPF->VPF_CONTA1 := _nQtd
			If VPE->VPE_VALEST <> "3" .and. nQtdEstq == _nQtd // Valida com a Qtde de Estoque ( 1-Todas / 2-Apenas a 1a. / 3-Nao Valida )
				VPF->VPF_OK  := "1"
			Else
				VPF->VPF_OK  := "0"
			EndIf
		Case _cFase == "D2"
			VPF->VPF_CONTA2 := _nQtd
			If ( VPE->VPE_VALEST == "1" .and. nQtdEstq == _nQtd ) .or. VPF->VPF_CONTA1 == _nQtd // Valida com a Qtde de Estoque ou com a Qtde digitada na 1a.Contagem
				VPF->VPF_OK  := "2"
			Else
				VPF->VPF_OK  := "0"
			EndIf
		Case _cFase == "D3"
			VPF->VPF_CONTA3 := _nQtd
			If VPE->VPE_QTDCON == "3" // Maximo 3 contagens
				VPF->VPF_OK  := "3"
			Else // Maximo 5 contagens
				If ( VPE->VPE_VALEST == "1" .and. nQtdEstq == _nQtd ) .or. VPF->VPF_CONTA1 == _nQtd .or. VPF->VPF_CONTA2 == _nQtd // Valida com a Qtde de Estoque ou com a Qtde digitada na 1a/2a.Contagem
					VPF->VPF_OK  := "3"
				Else
					VPF->VPF_OK  := "0"
				EndIf
			EndIf
		Case _cFase == "D4"
			VPF->VPF_CONTA4 := _nQtd
			If ( VPE->VPE_VALEST == "1" .and. nQtdEstq == _nQtd ) .or. VPF->VPF_CONTA1 == _nQtd .or. VPF->VPF_CONTA2 == _nQtd .or. VPF->VPF_CONTA3 == _nQtd // Valida com a Qtde de Estoque ou com a Qtde digitada na 1a/2a/3a.Contagem
				VPF->VPF_OK  := "4"
			Else
				VPF->VPF_OK  := "0"
			EndIf
		Case _cFase == "D5"
			VPF->VPF_CONTA5 := _nQtd
			VPF->VPF_OK     := "5"
	EndCase
	VPF->VPF_OKDIG := "1"
	MsUnLock()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERPERC³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Nros das paginas ja Digitadas e as que faltam Digitacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERPERC(cTp)
Local OXamar
Local OXlara
Local OXverm
Local oamar    := LoadBitmap( GetResources(), "BR_amarelo")
Local olara    := LoadBitmap( GetResources(), "BR_laranja")
Local overm    := LoadBitmap( GetResources(), "BR_vermelho")
Local cFilVPF  := xFilial("VPF")
Local lListBox := .t.
Local aPagOK   := {}
Local aPagNO   := {}
Local aPerc    := {}
Local aPend    := {}
Local nNroPag  := 0
Local nx       := 0
Local ni       := 0
Local nPos     := 0
Local nPos2    := 0
Local cPerOK   := "0 %"
Local cPerNO   := "0 %"
Local nQtdEstq := 0
If cTp == "N"
	DbSelectArea("VPF")
	DbSetOrder(4)
	If DbSeek(cFilVPF+VPE->VPE_CODIGO+"00000101")
		ProcRegua(RecCount()/IIf(lCoorde,400,800))
		While !Eof() .and. cFilVPF == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO
			ni++
			If ni == 800
				ni := 0
				IncProc(STR0063) // "Verificando % de Digitacao..."
			EndIf
			If VPF->VPF_OKDIG == "0"
				If len(aPagNO)==0 .or. aPagNO[len(aPagNO),1] <> left(VPF->VPF_NROREL,6)
					aadd(aPagNO,{ left(VPF->VPF_NROREL,6) })
				EndIf
			EndIf
			nNroPag := val(left(VPF->VPF_NROREL,6))
			DbSelectArea("VPF")
			DbSkip()
		EndDo
	EndIf
	For ni := 1 to nNroPag
		nPos := aScan(aPagNO,{|x| x[1] == strzero(ni,6) })
		If nPos == 0
			aadd(aPagOK,{ strzero(ni,6) })
		EndIf
	Next
	cPerOK := Transform((len(aPagOK)/nNroPag)*100,"@E 999.99")+" % (" + Transform(len(aPagOK),"@E 999999")+" "+STR0064+" )" // "pagina(s)"
	cPerNO := Transform((len(aPagNO)/nNroPag)*100,"@E 999.99")+" % (" + Transform(len(aPagNO),"@E 999999")+" "+STR0064+" )" // "pagina(s)"
	If len(aPagOK) == 0
		aadd(aPagOK,{ " " })
	Else
		aSort(aPagOK,1,,{|x,y| x[1] < y[1] })
	EndIf
	If len(aPagNO) == 0
		aadd(aPagNO,{ " " })
	Else
		aSort(aPagNO,1,,{|x,y| x[1] < y[1] })
	EndIf
EndIf
If lCoorde // Coordenacao
	aadd(aPerc,{ 0 , 0 , 0 , 0 , 0 , 0 , STR0068     })  // "Total"
	aadd(aPerc,{ 0 , 0 , 0 , 0 , 0 , 0 , STR0069     })  // "OK"
	aadd(aPerc,{ 0 , 0 , 0 , 0 , 0 , 0 , STR0070     })  // "Pendentes"
	DbSelectArea("VPF")
	DbSetOrder(4)
	DbSeek(cFilVPF+VPE->VPE_CODIGO)
	While !Eof() .and. cFilVPF == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO
		ni++
		If ni == 800
			ni := 0
			IncProc(STR0063) // "Verificando % de Digitacao..."
		EndIf
		If !Empty(VPF->VPF_ALMOX+VPF->VPF_LOCAC+VPF->VPF_GRUITE+VPF->VPF_CODITE)
			nQtdEstq := IIf(VPF->VPF_ITEEND=="1",VPF->VPF_QTDEND,VPF->VPF_QTDEST) // Item Enderecado? 1=Sim (SBF=QTD.ENDERECO) / 0=Nao (SB2=QTD.ESTOQUE)
			nPos     := 1 // Amarelo - Falta Digitacao
			nPos2    := 2 // Laranja - Proxima FASE
			If VPF->VPF_OKDIG <> "0"
				nPos := 2 // Laranja - Divergencia com o Estoque COM possibilidade de digitacao
			EndIf
			aPerc[1,1]++ // Total de Itens da 1a.Contagem
			Do Case
				Case VPF->VPF_OK == "1"
					aPerc[2,1]++ // Itens OK na 1a.Contagem
					nPos := 0
				Case VPF->VPF_OK == "2"
					aPerc[2,2]++ // Itens OK na 2a.Contagem
					If nQtdEstq == VPF->VPF_CONTA2
						nPos := 0
					EndIf
				Case VPF->VPF_OK == "3"
					aPerc[2,3]++ // Itens OK na 3a.Contagem
					If nQtdEstq == VPF->VPF_CONTA3
						nPos := 0
					EndIf
				Case VPF->VPF_OK == "4"
					aPerc[2,4]++ // Itens OK na 4a.Contagem
					If nQtdEstq == VPF->VPF_CONTA4
						nPos := 0
					EndIf
				Case VPF->VPF_OK == "5"
					aPerc[2,5]++ // Itens OK na 5a.Contagem
					If nQtdEstq == VPF->VPF_CONTA5
						nPos := 0
					EndIf
				Otherwise
					If left(cFase,1) == "D"
						DbSelectArea("SB1")
						DbSetOrder(7)
						DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
						aadd(aPend,{ nPos , IIf(nPos<>1,nPos2,nPos) , ++nx , Transform(VPF->VPF_NROREL,"@R 999999-99") , VPF->VPF_ALMOX , VPF->VPF_LOCAC , VPF->VPF_GRUITE , VPF->VPF_CODITE , left(SB1->B1_DESC,25) , nQtdEstq , VPF->VPF_CONTA1 , VPF->VPF_CONTA2 , VPF->VPF_CONTA3 , VPF->VPF_CONTA4 , VPF->VPF_CONTA5 })
						nPos := 0
					EndIf
			EndCase
			If left(cFase,1) == "D" .and. nPos > 0
				If right(cFase,1) <> VPF->VPF_OK
					nPos  := 3 // Vermelho - Divergencia com o Estoque SEM possibilidade de digitacao
					nPos2 := 3 // Vermelho - Proxima FASE
				EndIf
				If nPos == 2 .and. VPF->VPF_OK<>"0"
					nPos2 := 3 // Vermelho - Proxima FASE
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(7)
				DbSeek(xFilial("SB1") + VPF->VPF_GRUITE + VPF->VPF_CODITE )
				aadd(aPend,{ nPos , IIf(nPos<>1,nPos2,nPos) , ++nx , IIf(nPos==2,Transform(VPF->VPF_NROREL,"@R 999999-99"),"") , VPF->VPF_ALMOX , VPF->VPF_LOCAC , VPF->VPF_GRUITE , VPF->VPF_CODITE , left(SB1->B1_DESC,25) , nQtdEstq , VPF->VPF_CONTA1 , VPF->VPF_CONTA2 , VPF->VPF_CONTA3 , VPF->VPF_CONTA4 , VPF->VPF_CONTA5 })
			EndIf
		EndIf
		DbSelectArea("VPF")
		DbSkip()
	EndDo
	aPerc[3,1] := ( aPerc[1,1] - aPerc[2,1] ) // Itens Pendentes na 1a.Contagem
	aPerc[1,2] := aPerc[3,1] // Total de Itens da 2a.Contagem
	aPerc[3,2] := ( aPerc[1,2] - aPerc[2,2] ) // Itens Pendentes na 2a.Contagem
	aPerc[1,3] := aPerc[3,2] // Total de Itens da 3a.Contagem
	aPerc[3,3] := ( aPerc[1,3] - aPerc[2,3] ) // Itens Pendentes na 3a.Contagem
	aPerc[1,4] := aPerc[3,3] // Total de Itens da 4a.Contagem
	aPerc[3,4] := ( aPerc[1,4] - aPerc[2,4] ) // Itens Pendentes na 4a.Contagem
	aPerc[1,5] := aPerc[3,4] // Total de Itens da 5a.Contagem
	aPerc[3,5] := ( aPerc[1,5] - aPerc[2,5] ) // Itens Pendentes na 5a.Contagem
EndIf
DEFINE MSDIALOG oVerPag FROM 000,000 TO 030,110 TITLE (IIf(cTp=="N","% ",STR0071+": ")+cTitulo) OF oMainWnd  // "Estatistica - Fase atual"
If !lCoorde // Digitacao
	@ 003,003 LISTBOX oVerPagLxOK FIELDS HEADER (STR0065+" "+cPerOK) 213 SIZE 213,220 OF oVerPag PIXEL ON DBLCLICK IIf(!Empty(aPagOK[oVerPagLxOK:nAt,1]),(cNroP:=aPagOK[oVerPagLxOK:nAt,1],cNroI:="01",oVerPag:End(),FS_PESQ()),oVerPag:End()) // "Digitadas"
	oVerPagLxOK:SetArray(aPagOK)
	oVerPagLxOK:bLine := { || { aPagOK[oVerPagLxOK:nAt,1] }}
	@ 003,220 LISTBOX oVerPagLxNO FIELDS HEADER (STR0066+" "+cPerNO) 213 SIZE 213,220 OF oVerPag PIXEL ON DBLCLICK IIf(!Empty(aPagNO[oVerPagLxNO:nAt,1]),(cNroP:=aPagNO[oVerPagLxNO:nAt,1],cNroI:="01",oVerPag:End(),FS_PESQ()),oVerPag:End()) // "NAO Digitadas"
	oVerPagLxNO:SetArray(aPagNO)
	oVerPagLxNO:bLine := { || { aPagNO[oVerPagLxNO:nAt,1] }}
Else // Coordenacao
	If cTp == "N"
		@ 003,003 LISTBOX oVerPagLxOK FIELDS HEADER (STR0065+" "+cPerOK) 213 SIZE 213,170 OF oVerPag PIXEL ON DBLCLICK oVerPag:End() // "Digitadas"
		oVerPagLxOK:SetArray(aPagOK)
		oVerPagLxOK:bLine := { || { aPagOK[oVerPagLxOK:nAt,1] }}
		@ 003,220 LISTBOX oVerPagLxNO FIELDS HEADER (STR0066+" "+cPerNO) 213 SIZE 213,170 OF oVerPag PIXEL ON DBLCLICK oVerPag:End() // "NAO Digitadas"
		oVerPagLxNO:SetArray(aPagNO)
		oVerPagLxNO:bLine := { || { aPagNO[oVerPagLxNO:nAt,1] }}
	EndIf
	If VPE->VPE_QTDCON == "3" // Maximo 3 contagens
		@ IIf(cTp=="N",177,003),003 LISTBOX oVerPercLx FIELDS HEADER STR0072,STR0073,STR0074,STR0075 COLSIZES 80,110,110,110 SIZE 430,46 OF oVerPag PIXEL ON DBLCLICK oVerPag:End() WHEN .f. // // "Itens" / "<<< 1a. >>> %Contag %Total" / "<<< 2a. >>> %Contag %Total" / "<<< 3a. >>> %Contag %Total"
		oVerPercLx:SetArray(aPerc)
		oVerPercLx:bLine := { || { aPerc[oVerPercLx:nAt,7] , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,1],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,1]/aPerc[1,1])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,1]/aPerc[1,1])*100,"@E 9999")+"%" , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,2],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,2]/aPerc[1,2])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,2]/aPerc[1,1])*100,"@E 9999")+"%" , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,3],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,3]/aPerc[1,3])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,3]/aPerc[1,1])*100,"@E 9999")+"%" }}
	Else // Maximo 5 contagens
		@ IIf(cTp=="N",177,003),003 LISTBOX oVerPercLx FIELDS HEADER STR0072,STR0073,STR0074,STR0075,STR0076,STR0077 COLSIZES 30,77,77,77,77,77 SIZE 430,46 OF oVerPag PIXEL ON DBLCLICK oVerPag:End() WHEN .f. // // "Itens" / "<<< 1a. >>> %Contag %Total" / "<<< 2a. >>> %Contag %Total" / "<<< 3a. >>> %Contag %Total" / "<<< 4a. >>> %Contag %Total" / "<<< 5a. >>> %Contag %Total"
		oVerPercLx:SetArray(aPerc)
		oVerPercLx:bLine := { || { aPerc[oVerPercLx:nAt,7] , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,1],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,1]/aPerc[1,1])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,1]/aPerc[1,1])*100,"@E 9999")+"%" , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,2],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,2]/aPerc[1,2])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,2]/aPerc[1,1])*100,"@E 9999")+"%" , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,3],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,3]/aPerc[1,3])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,3]/aPerc[1,1])*100,"@E 9999")+"%" , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,4],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,4]/aPerc[1,4])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,4]/aPerc[1,1])*100,"@E 9999")+"%" , ;
		FG_AlinVlrs(Transform(aPerc[oVerPercLx:nAt,5],"@E 9999,999"))+"  "+Transform((aPerc[oVerPercLx:nAt,5]/aPerc[1,5])*100,"@E 9999")+"% "+Transform((aPerc[oVerPercLx:nAt,5]/aPerc[1,1])*100,"@E 9999")+"%" }}
	EndIf
	If cTp <> "N"
		If len(aPend) <= 0
			aadd(aPend,{ 1 , 1 , 0 , "" , "" , "" , "" , "" , "" , 0 , 0 , 0 , 0 , 0 , 0 })
			lListBox := .f.
		EndIf
		aSort(aPend,1,,{|x,y| x[4]+x[5]+x[6]+x[7]+x[8] < y[4]+y[5]+y[6]+y[7]+y[8] })
		@ 052,003 LISTBOX oVerPendLx FIELDS HEADER right(cFASE,1)+CHR(170),CHR(187),STR0085,STR0018,STR0049,STR0019,STR0021,STR0020 COLSIZES 10,10,35,45,35,60,85,85 SIZE 430,150 OF oVerPag PIXEL ON DBLCLICK oVerPag:End() // "Diverg.Estoque" / "Nro.Pag./Seq.:" / "Armazem: " / "Locacao" / "Item" / "Descricao"
		oVerPendLx:SetArray(aPend)
		oVerPendLx:bLine := { || { IIf(lListBox,(IIf(aPend[oVerPendLx:nAt,1]==1,oamar,IIf(aPend[oVerPendLx:nAt,1]==2,olara,overm))),"") , ;
		IIf(lListBox,(IIf(aPend[oVerPendLx:nAt,2]==1,oamar,IIf(aPend[oVerPendLx:nAt,2]==2,olara,overm))),"") , ;
		IIf(lListBox,(FG_AlinVlrs(Transform(oVerPendLx:nAt,"@E 999,999,999"))),"") , ;
		aPend[oVerPendLx:nAt,4] , ;
		aPend[oVerPendLx:nAt,5] , ;
		aPend[oVerPendLx:nAt,6] , ;
		aPend[oVerPendLx:nAt,7]+" "+aPend[oVerPendLx:nAt,8] , ;
		aPend[oVerPendLx:nAt,9] }}
		@ 205,007 BITMAP OXamar RESOURCE "BR_amarelo"  OF oVerPag PIXEL NOBORDER SIZE 10,10 when .f.
		@ 205,018 SAY STR0086 SIZE 160,08 OF oVerPag PIXEL COLOR CLR_BLUE // Falta Digitacao
		@ 205,082 BITMAP OXlara RESOURCE "BR_laranja"  OF oVerPag PIXEL NOBORDER SIZE 10,10 when .f.
		@ 205,093 SAY STR0087 SIZE 160,08 OF oVerPag PIXEL COLOR CLR_BLUE // Divergencia com o Estoque COM possibilidade de digitacao
		@ 205,259 BITMAP OXverm RESOURCE "BR_vermelho" OF oVerPag PIXEL NOBORDER SIZE 10,10 when .f.
		@ 205,270 SAY STR0088 SIZE 160,08 OF oVerPag PIXEL COLOR CLR_BLUE // Divergencia com o Estoque SEM possibilidade de digitacao
		@ 215,018 BUTTON oImpCont PROMPT (STR0098) OF oVerPag SIZE 220,09 PIXEL ACTION Processa( {|| FS_IMPDIV(0,aClone(aPend)) } ) // Imprimir Itens que ainda possuem divergencia com o estoque ou entre as contagens
		@ 215,270 BUTTON oImpVerm PROMPT (STR0093+" [ "+CHR(187)+" ]") OF oVerPag SIZE 145,09 PIXEL ACTION Processa( {|| FS_IMPDIV(3,aClone(aPend)) } )
	EndIf
EndIf
ACTIVATE MSDIALOG oVerPag CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_IMPDIV³ Autor ³  Andre Luis Almeida   ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os Itens com divergencia com o Estoque            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPDIV(nTp,aItens)
Local ni        := 0
Local nj        := 0
Local cAlm      := "INICIAL"
Private cDesc1  := STR0001 // "INVENTARIO"
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "M"
Private limite  := 132
Private cString := "VPF"
Private titulo  := STR0001+" ( "+VPE->VPE_CODIGO+" )" // "INVENTARIO"
Private cabec1  := IIf(nTp==3,(STR0094+" -> "+STR0088),STR0098) // Proxima Fase -> Divergencia com o Estoque SEM possibilidade de digitacao / Imprimir Itens que ainda possuem divergencia com o estoque ou entre as contagens
Private cabec2  := STR0095 // "Locacao         Item                                                                                                  Custo Unitario"
Private aReturn := {STR0050,1,STR0051,1,2,1,"",1} // "Zebrado" / "Administracao"
Private nomeprog:= "OFIPM040DIV"
Private nLastKey:= 0
Private cPerg   := nil
aSort(aItens,1,,{|x,y| x[5]+x[6]+x[7]+x[8] < y[5]+y[6]+y[7]+y[8] })
If nTp == 3 .and. ExistBlock("OPM040DV")
	ExecBlock("OPM040DV",.f.,.f.,{nTp,aClone(aItens)})
Else
	nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
	If nLastKey == 27
		Return
	EndIf
	SetDefault(aReturn,cString)
	nLin  := 0
	m_pag := 1
	Set Printer to &nomeprog
	Set Printer On
	Set Device  to Printer
	ProcRegua((len(aItens)/50))
	For ni := 1 to len(aItens)
		If ( nTp == 3 .and. aItens[ni,2] == 3 ) .or. ( nTp <> 3 .and. aItens[ni,2] <> 3 )
			If nj == 50
				nj := 0
				IncProc(STR0053) // "Gerando Relacao dos Itens..."
			EndIf
			If cAlm <> aItens[ni,5] .or. nLin > 60
				cAlm := aItens[ni,5]
				nLin := cabec(Alltrim(titulo)+" - "+STR0049+cAlm,cabec1,cabec2,nomeprog,tamanho,15) + 1 // "Armazem: "
			EndIf
			SB1->(DbSetOrder(7))
			SB1->(DbSeek(xFilial("SB1") + aItens[ni,7] + aItens[ni,8] ))
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + aItens[ni,5] ))
			@ nLin++,00 PSAY left(aItens[ni,6]+" "+aItens[ni,7]+" "+aItens[ni,8]+" "+aItens[ni,9]+space(115),115)+Transform(SB2->B2_CM1,"@E 99,999,999,999.99")
		EndIf
	Next
	DbSelectArea("VPF")
	Set Printer to
	Set Device to Screen
	If aReturn[5] == 1
		OurSpool( nomeprog )
	EndIf
	MS_Flush()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GERAB7NF³ Autor ³  Andre Luis Almeida  ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 1 - Geracao do SB7 - Lancamentos do Inventario             ³±±
±±³          ³ 2 - Geracao da NF Entrada e/ou Saida                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GERAB7NF(nTp)
Local cQAlVPG    :="SQLVPG"
Local lRet       := .t.
Local cDOC       := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local ni         := 0
Local nQtdEstq   := 0
Local lVPE_DOCSB7:= ( VPE->(FieldPos("VPE_DOCSB7")) > 0 )
Local cVPE_DOCSB7:= ""
Local dB7_DATA   := VPE->VPE_DATINI
Local aDatSB7    := {"1="+Transform(VPE->VPE_DATINI,"@D")+" ( "+Alltrim(RetTitle("VPE_DATINI"))+" )"}
Local aParamBox  := {}
Local aRet       := {}
Private aSF1     := {}
Private aSF2     := {}
Private aRetPar  := {}
Private aRetParC := {}
Private cNumero  := ""
Private cSerie   := ""
If nTp == 1 // Gerar 1-SB7
	If VPE->VPE_DATINI <> VPE->VPE_DATFIN
		aAdd(aDatSB7,"2="+Transform(VPE->VPE_DATFIN,"@D")+" ( "+Alltrim(RetTitle("VPE_DATFIN"))+" )")
	EndIf
	aParamBox := {}
	aRet      := {}
	aAdd(aParamBox,{2,STR0172,"1",aDatSB7,80,"",.F.}) // Lançamento do Inventário em
	If ParamBox(aParamBox,STR0046,@aRet,,,,,,,,.F.) // Gerar os Lancamentos do Inventario?
		If aRet[1] == "2"
			dB7_DATA := VPE->VPE_DATFIN
		EndIf
		If ExistBlock("OPM040B7")
			lRet := ExecBlock("OPM040B7",.f.,.f.,{})
		EndIf
		If lRet
			//
			ni := FM_SQL("SELECT COUNT(DISTINCT SB7.B7_DOC) AS QTDE FROM "+RetSQLName("SB7")+" SB7 WHERE SB7.B7_FILIAL='"+xFilial("SB7")+"' AND SB7.B7_DOC>='"+dtos(dB7_DATA)+"0' AND SB7.B7_DOC<='"+dtos(dB7_DATA)+"Z' AND SB7.D_E_L_E_T_=' '")
			ni++
			cVPE_DOCSB7 := dtos(dB7_DATA)+substr(cDOC,ni,1)
			//
			DbSelectArea("VPE")
			RecLock("VPE",.f.)
			VPE->VPE_GERAB7 := "1"
			If lVPE_DOCSB7
				VPE->VPE_DOCSB7 := cVPE_DOCSB7
			EndIf
			MsUnLock()
			DbSelectArea("VPG")
			DbSetOrder(1)
			DbSeek(xFilial("VPG")+VPE->VPE_CODIGO)
			ProcRegua(RecCount())
			While !Eof() .and. xFilial("VPG") == VPG->VPG_FILIAL .and. ( VPG->VPG_CODIGO == VPE->VPE_CODIGO )
				IncProc(STR0047) // "Gerando Lancamentos do Inventario..."
				DbSelectArea("SB1")
				DbSetOrder(7)
				DbSeek(xFilial("SB1")+VPG->VPG_GRUITE+VPG->VPG_CODITE)
				DbSelectArea("SB7")
				RecLock("SB7",.t.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_LOCAL   := VPG->VPG_ALMOX
				SB7->B7_TIPO    := SB1->B1_TIPO
				SB7->B7_DOC     := cVPE_DOCSB7
				SB7->B7_QUANT   := VPG->VPG_CONTA
				SB7->B7_QTSEGUM := ( VPG->VPG_CONTA / SB1->B1_CONV )
				SB7->B7_DATA    := dB7_DATA
				SB7->B7_LOTECTL := ""
				SB7->B7_NUMLOTE := ""
				SB7->B7_DTVALID := dDataBase
				SB7->B7_LOCALIZ := IIf(VPG->VPG_ITEEND=="1",VPG->VPG_LOCAC,"")
				SB7->B7_NUMSERI := ""
				SB7->B7_COD     := SB1->B1_COD
				SB7->B7_CONTAGE := strzero(1,len(SB7->B7_CONTAGE))
				MsUnLock()
				DbSelectArea("SB2")
				DbSetOrder(1)
				If DbSeek(xFilial("SB2")+SB1->B1_COD+VPG->VPG_ALMOX)
					RecLock("SB2",.f.)
					SB2->B2_DINVFIM := dB7_DATA // Muda Data Prevista para Termino
					MsUnLock()
				EndIf
				DbSelectArea("VPG")
				DbSkip()
			EndDo
			MsgInfo(STR0096+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0097+": "+cVPE_DOCSB7,STR0023) // Lancamentos do Inventario gerados com sucesso! / Documento / Atencao
		EndIf
	EndIf
Else
	If MsgYesNo(STR0154,STR0023) // "Deseja realmente Gerar NF das divergencias do Inventario?" / "Atencao"
		cQuery := "SELECT VPG.R_E_C_N_O_ RECNO, VPG.VPG_ITEEND , VPG.VPG_QTDEND , VPG.VPG_QTDEST , VPG.VPG_DIVERG , VPG.VPG_CUSTO , VPG.VPG_GRUITE , VPG.VPG_CODITE , VPG.VPG_ALMOX , VPG.VPG_LOCAC "
		cQuery += "  FROM "+RetSqlName("VPG")+" VPG "
		cQuery += " WHERE VPG.VPG_FILIAL='"+xFilial("VPG")+"' AND VPG.VPG_CODIGO='"+VPE->VPE_CODIGO+"' "
		cQuery += "   AND VPG.D_E_L_E_T_=' ' "
		cQuery += " ORDER BY VPG.VPG_GRUITE , VPG.VPG_CODITE "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPG, .F., .T. )
		While !( cQAlVPG )->( Eof() )
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek(xFilial("SB1") + ( cQAlVPG )->VPG_GRUITE+( cQAlVPG )->VPG_CODITE )
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2") + SB1->B1_COD + ( cQAlVPG )->VPG_ALMOX )
			nQtdEstq := IIf(( cQAlVPG )->VPG_ITEEND=="1",( cQAlVPG )->VPG_QTDEND,( cQAlVPG )->VPG_QTDEST) // Item Enderecado? 1=Sim (SBF=QTD.ENDERECO) / 0=Nao (SB2=QTD.ESTOQUE)
			//////////////////////////////////////////
			// DIVERGENCIA = ( CONTAGEM - ESTOQUE ) //
			//////////////////////////////////////////
			AADD(aVPGData, {(cQAlVPG)->RECNO, (cQAlVPG)->VPG_GRUITE, (cQAlVPG)->VPG_CODITE, (cQAlVPG)->VPG_ALMOX, (cQAlVPG)->VPG_LOCAC})

			If ( cQAlVPG )->VPG_DIVERG < 0
				aadd(aSF2,{( cQAlVPG )->VPG_GRUITE,( cQAlVPG )->VPG_CODITE,( cQAlVPG )->VPG_ALMOX,( cQAlVPG )->VPG_LOCAC,SB1->B1_DESC, nQtdEstq ,( cQAlVPG )->VPG_DIVERG*(-1),SB2->B2_CM1})
			ElseIf ( cQAlVPG )->VPG_DIVERG > 0
				aadd(aSF1,{( cQAlVPG )->VPG_GRUITE,( cQAlVPG )->VPG_CODITE,( cQAlVPG )->VPG_ALMOX,( cQAlVPG )->VPG_LOCAC,SB1->B1_DESC, nQtdEstq ,( cQAlVPG )->VPG_DIVERG,SB2->B2_CM1})
			EndIf
			//
			( cQAlVPG )-> (DbSkip())
		EndDo
		(cQAlVPG)->(dbCloseArea())
		// NF Entrada
		IF Len(aSF1) > 0
			aParamBox := {}
			aRet      := {}
			aAdd(aParamBox,{1,STR0157,Space(TamSX3("A2_COD")[1]),"@!","OPM040VFOR()","SA2","",0,.T.})
			aAdd(aParamBox,{1,STR0158,Space(TamSX3("A2_LOJA")[1]),"@!","","","",0,.T.})
			aAdd(aParamBox,{1,STR0160,Space(TamSX3("E4_CODIGO")[1]),"@!","","SE4","",0,.T.})
			aAdd(aParamBox,{1,STR0161,Space(TamSX3("F1_ESPECIE")[1]),"@!","","42","",0,.T.})
			If !ParamBox(aParamBox,STR0162,@aRet,,,,,,,,.f.)
				Return .f.
			Else
				aadd(aRetPar,{aRet[1],aRet[2],aRet[3],aRet[4]})
			EndIf
		Endif
		// NF Saida
		IF Len(aSF2) > 0
			aParamBox := {}
			aRet      := {}
			aAdd(aParamBox,{1,STR0163,Space(TamSX3("A1_COD")[1]),"@!","","SA1","",0,.T.})
			aAdd(aParamBox,{1,STR0158,Space(TamSX3("A1_LOJA")[1]),"@!","","","",0,.T.})
			aAdd(aParamBox,{1,STR0164,Space(TamSX3("FM_TIPO")[1]),"@!","","DJ","",0,.T.})
			aAdd(aParamBox,{1,STR0165,Space(TamSX3("E4_CODIGO")[1]),"@!","","SE4","",0,.T.})
			aAdd(aParamBox,{1,STR0166,Space(TamSX3("F2_VEND1")[1]),"@!","","SA3","",0,.T.})
			If !ParamBox(aParamBox,STR0167,@aRet,,,,,,,,.f.)
				Return .f.
			Else
				aadd(aRetParC,{aRet[1],aRet[2],aRet[3],aRet[4],aRet[5]})
			EndIf
		EndIf
		If Len(aSF1) > 0
			lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
			if !lRet
			   Return(.f.)
			Endif
		EndIf
		Begin Transaction
		If FS_GERANF()
			DbSelectArea("VPE")
			RecLock("VPE",.f.)
			VPE->VPE_GERAB7 := "2"
			MsUnLock()
		Else
			DisarmTransaction()
		EndIf
		End Transaction
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_AGRUPA ³ Autor ³  Andre Luis Almeida  ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agrupa ALMOX + LOCACAO + COD.ITEM                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AGRUPA(cRel,_cFase)
Local cFilVPF  := xFilial("VPF")
Local ni       := 0
Local nResto   := 0
Local nQtdTot  := 0
Local nQtdEstq := 0
Local nConta1  := 0
Local nConta2  := 0
Local nConta3  := 0
Local nConta4  := 0
Local nConta5  := 0
Local aIteCont := {}
Default _cFase := VPE->VPE_FASE
DbSelectArea("VPF")
DbSetOrder(4)
DbSeek(cFilVPF+VPE->VPE_CODIGO+cRel)
nConta1 := VPF->VPF_CONTA1
nConta2 := VPF->VPF_CONTA2
nConta3 := VPF->VPF_CONTA3
nConta4 := VPF->VPF_CONTA4
nConta5 := VPF->VPF_CONTA5
While !Eof() .and. cFilVPF == VPF->VPF_FILIAL .and. VPF->VPF_CODIGO == VPE->VPE_CODIGO .and. VPF->VPF_NROREL == cRel
	nQtdEstq := IIf(VPF->VPF_ITEEND=="1",VPF->VPF_QTDEND,VPF->VPF_QTDEST) // Item Enderecado? 1=Sim (SBF=QTD.ENDERECO) / 0=Nao (SB2=QTD.ESTOQUE)
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek( xFilial("SB1") )
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + SB1->B1_COD + VPF->VPF_ALMOX )
	aadd(aIteCont,{VPF->(RecNo()),SB2->B2_CM1})
	nQtdTot += nQtdEstq
	If len(aIteCont) > 1
		DbSelectArea("VPF")
		RecLock("VPF",.f.)
		VPF->VPF_CONTA1 := 0
		VPF->VPF_CONTA2 := 0
		VPF->VPF_CONTA3 := 0
		VPF->VPF_CONTA4 := 0
		VPF->VPF_CONTA5 := 0
		MsUnLock()
	EndIf
	DbSelectArea("VPF")
	DbSkip()
EndDo
Do Case
	Case _cFase == "D1"
		nResto := nConta1
	Case _cFase == "D2"
		nResto := nConta2
	Case _cFase == "D3"
		nResto := nConta3
	Case _cFase == "D4"
		nResto := nConta4
	Case _cFase == "D5"
		nResto := nConta5
EndCase
aSort(aIteCont,1,,{|x,y| x[2] > y[2]})
For ni := 1 to len(aIteCont)
	DbSelectArea("VPF")
	DbGoTo(aIteCont[ni,1])
	nQtdEstq := IIf(VPF->VPF_ITEEND=="1",VPF->VPF_QTDEND,VPF->VPF_QTDEST) // Item Enderecado? 1=Sim (SBF=QTD.ENDERECO) / 0=Nao (SB2=QTD.ESTOQUE)
	RecLock("VPF",.f.)
	Do Case
		Case _cFase == "D1" // Digitacao 1
			If VPE->VPE_VALEST <> "3" .and. nQtdTot == nConta1
				VPF->VPF_OK := "1"
				VPF->VPF_CONTA1 := nQtdEstq
			Else
				VPF->VPF_OK  := "0"
			EndIf
		Case _cFase == "D2" // Digitacao 2
			If VPE->VPE_VALEST == "1" .and. nQtdTot == nConta2
				VPF->VPF_OK  := "2"
				VPF->VPF_CONTA2 := nQtdEstq
			ElseIf nConta1 == nConta2
				If ni == len(aIteCont) .or. nResto <= nQtdEstq
					VPF->VPF_CONTA2 := nResto
					nResto := 0
				Else
					VPF->VPF_CONTA2 := nQtdEstq
					nResto -= nQtdEstq
				EndIf
				VPF->VPF_OK  := "2"
			Else
				VPF->VPF_OK  := "0"
			EndIf
		Case _cFase == "D3" // Digitacao 3
			If VPE->VPE_QTDCON == "3" // Maximo 3 contagens
				VPF->VPF_OK := "3"
				If ni == len(aIteCont) .or. nResto <= nQtdEstq
					VPF->VPF_CONTA3 := nResto
					nResto := 0
				Else
					VPF->VPF_CONTA3 := nQtdEstq
					nResto -= nQtdEstq
				EndIf
			Else // Maximo 5 contagens
				If VPE->VPE_VALEST == "1" .and. nQtdTot == nConta3
					VPF->VPF_OK  := "3"
					VPF->VPF_CONTA3 := nQtdEstq
				ElseIf nConta1 == nConta3 .or. nConta2 == nConta3
					If ni == len(aIteCont) .or. nResto <= nQtdEstq
						VPF->VPF_CONTA3 := nResto
						nResto := 0
					Else
						VPF->VPF_CONTA3 := nQtdEstq
						nResto -= nQtdEstq
					EndIf
					VPF->VPF_OK  := "3"
				Else
					VPF->VPF_OK  := "0"
				EndIf
			EndIf
		Case _cFase == "D4" // Digitacao 4
			If VPE->VPE_VALEST == "1" .and. nQtdTot == nConta4
				VPF->VPF_OK  := "4"
				VPF->VPF_CONTA4 := nQtdEstq
			ElseIf nConta1 == nConta4 .or. nConta2 == nConta4 .or. nConta3 == nConta4
				If ni == len(aIteCont) .or. nResto <= nQtdEstq
					VPF->VPF_CONTA4 := nResto
					nResto := 0
				Else
					VPF->VPF_CONTA4 := nQtdEstq
					nResto -= nQtdEstq
				EndIf
				VPF->VPF_OK  := "4"
			Else
				VPF->VPF_OK  := "0"
			EndIf
		Case _cFase == "D5" // Digitacao 5
			VPF->VPF_OK := "5"
			If ni == len(aIteCont) .or. nResto <= nQtdEstq
				VPF->VPF_CONTA5 := nResto
				nResto := 0
			Else
				VPF->VPF_CONTA5 := nQtdEstq
				nResto -= nQtdEstq
			EndIf
	EndCase
	VPF->VPF_OKDIG := "1"
	MsUnLock()
Next
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DESBLOQIT³ Autor ³ Andre Luis Almeida  ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Desbloqueia Itens da Contagem                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DESBLOQIT()
Local cQuery  := ""
Local cQAlias := "SQLs"
If lEnderecado
	cQuery := "SELECT DISTINCT SBE.R_E_C_N_O_ AS RECSBE , SB2.R_E_C_N_O_ AS RECSB2 , VPF.R_E_C_N_O_ AS RECVPF , VPF.VPF_ITEBLO FROM "+RetSqlName("VPF")+" VPF "
	cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VPF.VPF_GRUITE AND SB1.B1_CODITE=VPF.VPF_CODITE AND SB1.D_E_L_E_T_=' ' "
	cQuery += "JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_LOCAL=VPF.VPF_ALMOX  AND SB2.B2_COD=SB1.B1_COD        AND SB2.D_E_L_E_T_=' ' "
	cQuery += "JOIN "+RetSqlName("SBE")+" SBE ON SBE.BE_FILIAL='"+xFilial("SBE")+"' AND SBE.BE_LOCAL=VPF.VPF_ALMOX  AND SBE.BE_LOCALIZ=VPF.VPF_LOCAC AND SBE.D_E_L_E_T_=' ' "
	cQuery += "WHERE VPF.VPF_FILIAL='"+xFilial("VPF")+"' AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"' AND VPF.VPF_ITEEND='1' AND VPF.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	While !( cQAlias )->( Eof() )
		If ( cQAlias )->VPF_ITEBLO=='1' .and. VPE->VPE_BLOQB1 == "1" // Desbloquear Item no SB1
			DbSelectArea("SBE")
			DbGoto(( cQAlias )->( RECSBE ))
			If !Empty(SBE->BE_DTINV)
				RecLock("SBE",.f.)
				SBE->BE_DTINV := StoD("")
				MsUnLock()
			EndIf
			DbSelectArea("VPF")
			DbGoto(( cQAlias )->( RECVPF ))
			RecLock("VPF",.f.)
			VPF->VPF_ITEBLO := "0" // Desbloqueia Item
			MsUnLock()
		Endif
		If !lCancela
			DbSelectArea("SB2")
			DbGoto(( cQAlias )->( RECSB2 ))
			If SB2->B2_DINVENT <> dDataBase
				RecLock("SB2",.f.)
				SB2->B2_DINVENT := dDataBase // Data do Inventário
				MsUnLock()
			EndIf
		EndIf

		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
cQuery := "SELECT DISTINCT SB2.R_E_C_N_O_ AS RECSB2 , VPF.R_E_C_N_O_ AS RECVPF , VPF.VPF_ITEBLO FROM "+RetSqlName("VPF")+" VPF "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VPF.VPF_GRUITE AND SB1.B1_CODITE=VPF.VPF_CODITE AND SB1.D_E_L_E_T_=' ' "
cQuery += "JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL='"+xFilial("SB2")+"' AND SB2.B2_LOCAL=VPF.VPF_ALMOX  AND SB2.B2_COD=SB1.B1_COD        AND SB2.D_E_L_E_T_=' ' "
cQuery += "WHERE VPF.VPF_FILIAL='"+xFilial("VPF")+"' AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"' AND VPF.VPF_ITEEND<>'1' AND VPF.D_E_L_E_T_=' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	DbSelectArea("SB2")
	DbGoto(( cQAlias )->( RECSB2 ))
	RecLock("SB2",.f.)
	If ( cQAlias )->VPF_ITEBLO=='1' .and. VPE->VPE_BLOQB1 == "1" // Desbloquear Item no SB1
		SB2->B2_DTINV   := StoD("")
		SB2->B2_DINVFIM := StoD("") // Data de previsão de termino do inventário
	Endif
	if !lCancela .and. SB2->B2_DINVENT <> dDataBase
		SB2->B2_DINVENT := dDataBase // Data do inventário
	Endif
	MsUnLock()
	If ( cQAlias )->VPF_ITEBLO=='1' .and. VPE->VPE_BLOQB1 == "1" // Desbloquear Item no SB1
		DbSelectArea("VPF")
		DbGoto(( cQAlias )->( RECVPF ))
		RecLock("VPF",.f.)
			VPF->VPF_ITEBLO := "0" // Desbloqueia Item
		MsUnLock()
	Endif
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
DbSelectArea("VPF")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ALTDIV  ³ Autor ³ Andre Luis Almeida  ³ Data ³ 21/01/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera Divergencias dos Itens do Inventario                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALTDIV()
Local ni        := 0
Local nDiv      := 0
Local lOk       := .f.
Local cQuery    := ""
Local cQAlias   := "SQLVPG"
Private aDiverg := {}
Private cGruI   := Space(TamSX3("B1_GRUPO")[1])
Private cCodI   := Space(TamSX3("B1_CODITE")[1])
//
cQuery := "SELECT VPG.* , VPG.R_E_C_N_O_ RECVPG , SB1.B1_DESC FROM "+RetSqlName("VPG")+" VPG "
cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VPG.VPG_GRUITE AND SB1.B1_CODITE=VPG.VPG_CODITE AND SB1.D_E_L_E_T_=' ') "
cQuery += "WHERE VPG.VPG_FILIAL='"+xFilial("VPG")+"' AND VPG.VPG_CODIGO='"+VPE->VPE_CODIGO+"' AND VPG.D_E_L_E_T_=' ' "
cQuery += "ORDER BY VPG.VPG_LOCAC,VPG.VPG_GRUITE,VPG.VPG_CODITE"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	aAdd(aDiverg,{	( cQAlias )->( VPG_ALMOX ) ,;
					( cQAlias )->( VPG_LOCAC ) ,;
					( cQAlias )->( VPG_GRUITE ) ,;
					( cQAlias )->( VPG_CODITE ) ,;
					( cQAlias )->( B1_DESC ) ,;
					( cQAlias )->( VPG_CONTA ) ,;
					IIf(( cQAlias )->( VPG_ITEEND )=="1",( cQAlias )->( VPG_QTDEND ),( cQAlias )->( VPG_QTDEST )) ,;
					( cQAlias )->( VPG_CUSTO )/( cQAlias )->( VPG_DIVERG ) ,;
					( cQAlias )->( RECVPG ) })
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

//
If len(aDiverg) > 0
	DEFINE MSDIALOG oAltDiv FROM 000,000 TO 030,110 TITLE (STR0141+" "+VPE->VPE_CODIGO) OF oMainWnd  // Altera a Qtde dos Itens com Divergencia do Inventario
	@ 003,003 LISTBOX oDiverg FIELDS HEADER STR0049,STR0019,STR0138,STR0021,STR0020,STR0022 COLSIZES 20,50,30,70,100,50 SIZE 430,203 OF oAltDiv PIXEL ON DBLCLICK FS_ALTQTD(oDiverg:nAt)
	oDiverg:SetArray(aDiverg)
	oDiverg:bLine := { || {	aDiverg[oDiverg:nAt,1] , ;
							aDiverg[oDiverg:nAt,2] , ;
							aDiverg[oDiverg:nAt,3] , ;
							aDiverg[oDiverg:nAt,4] , ;
							aDiverg[oDiverg:nAt,5] , ;
							FG_AlinVlrs(Transform(aDiverg[oDiverg:nAt,6],cPictQTD)) }}
	DEFINE SBUTTON FROM 213,370 TYPE 1 ACTION (lOk:=.t.,oAltDiv:End()) ENABLE OF oAltDiv
	DEFINE SBUTTON FROM 213,400 TYPE 2 ACTION (oAltDiv:End()) ENABLE OF oAltDiv

	@ 207, 011 TO 225,251 LABEL STR0176 OF oAltDiv PIXEL  // Pesquisa

	@ 213,027 SAY STR0138 OF oAltDiv SIZE 55,10 PIXEL COLOR CLR_BLACK
	@ 213,046 MSGET oGrp VAR cGruI PICTURE "@!" F3 "SBM" SIZE 35,4 OF oAltDiv  PIXEL COLOR CLR_BLACK

	@ 213,087 SAY STR0177 OF oAltDiv SIZE 55,10 PIXEL COLOR CLR_BLACK
	@ 213,116 MSGET oCodIte VAR cCodI VALID vazio() .or. (FG_POSSB1("cCodI","SB1->B1_CODITE","cGruI") .and. FS_VALCODITE(cGruI,cCodI)) PICTURE "@!" F3 "B16" SIZE 65,4 OF oAltDiv PIXEL COLOR CLR_BLACK

	ACTIVATE MSDIALOG oAltDiv CENTER
EndIf
//
If lOk
	For ni := 1 to len(aDiverg)
		//Verifico se o custo esta zerado eu gravo novamente para gerar o relatorio corretamente
		If aDiverg[ni,8] == 0 
			SB1->(DBSetOrder(7))
			SB1->(DBSeek(xFilial("SB1") + aDiverg[ni,3] + aDiverg[ni,4] ))
			SB2->(DBSetOrder(1))
			SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + VPF->VPF_ALMOX ))
			aDiverg[ni,8] := SB2->B2_CM1
		EndIf
		
		nDiv := ( aDiverg[ni,6] - aDiverg[ni,7] )
		DbSelectArea("VPG")
		DbGoTo(aDiverg[ni,9]) // RECNO VPG
		RecLock("VPG",.f.)
			VPG->VPG_CONTA  := aDiverg[ni,6] // Qtde Informada/Digitada
			VPG->VPG_DIVERG := nDiv
			VPG->VPG_CUSTO  := ( nDiv * aDiverg[ni,8] )
		MsUnLock()
	Next
EndIf
//
Return()

///////////////////////////
// Parambox Alterar Qtde //
///////////////////////////
Static Function FS_ALTQTD(nLinha)
Private aParamQTD := {}
Private aRetQTD   := {}
aAdd(aParamQTD,{1,STR0049,aDiverg[nLinha,1],"@!","","",".f.",20,.F.})
aAdd(aParamQTD,{1,STR0019,aDiverg[nLinha,2],"@!","","",".f.",50,.F.})
aAdd(aParamQTD,{1,STR0138,aDiverg[nLinha,3],"@!","","",".f.",30,.F.})
aAdd(aParamQTD,{1,STR0021,aDiverg[nLinha,4],"@!","","",".f.",70,.F.})
aAdd(aParamQTD,{1,STR0020,aDiverg[nLinha,5],"@!","","",".f.",100,.F.})
aAdd(aParamQTD,{1,STR0022,aDiverg[nLinha,6],cPictQTD,"MV_PAR06>=0","","",70,.F.})
If ParamBox(aParamQTD,STR0139,@aRetQTD,,,,,,,,.f.,) // Alterar Qtde
	aDiverg[nLinha,6] := aRetQTD[6]
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPM040ICTG ³ Autor ³ Andre Luis Almeida  ³ Data ³ 02/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir Digitacoes de Todas as Contagens                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040ICTG(cTipo)
Local ni        := 0
Local nCont1    := 0
Local nCont2    := 0
Local nCont3    := 0
Local nCont4    := 0
Local nCont5    := 0
Local nTCodIte  := 0
Local cAlm      := "INICIAL"
Local cAgrAx    := ""
Local cQuery    := ""
Local cQAlVPF   := "SQLVPF"
Local cQAlQTD   := "SQLQTD"
Local cImprimir := ""
Private cDesc1  := STR0001 // "INVENTARIO"
Private cDesc2  := ""
Private cDesc3  := ""
Private tamanho := "M"
Private limite  := 132
Private cString := "VPF"
Private titulo  := STR0001+" ( "+VPE->VPE_CODIGO+" ) "+STR0090 // "INVENTARIO" / "Digitacoes"
Private cabec1  := STR0091 // "Locacao         Item                                            1a.Digitacao  2a.Digitacao  3a.Digitacao  4a.Digitacao  5a.Digitacao"
Private cabec2  := ""
Private aReturn := {STR0050,1,STR0051,1,2,1,"",1} // "Zebrado" / "Administracao"
Private nomeprog:= "OFIPM040DIG"
Private aLinha  := { },nLastKey := 0
Private cAgrup  := left(GetNewPar("MV_CONTAGR","N"),1)
Private cPictQTD:= SX3->(x3Picture("B2_QATU"))
Private cPerg   := nil
Default cTipo   := ""
//
If cTipo <> "*"
	cFase := VPE->VPE_FASE // Chamada pelo Browse ou por fora - Carregar variavel de validacao ( cFase )
EndIf
If !( cFase $ "I1/D1/I2/D2/I3/D3/I4/D4/I5/D5/I6/" ) // Validar se o Inventario esta nas Fases Permitidas
	MsgStop(STR0192,STR0023) // O Inventario esta em uma fase que nao permite impressao. / Atencao
	Return
EndIf
//
nomeprog := SetPrint(cString,nomeprog,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,tamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cString)
nLin  := 0
m_pag := 1
Set Printer to &nomeprog
Set Printer On
Set Device  to Printer
//
nTCodIte := OPM040TCOD() // Pegar tamanho maximo de caracteres gravados no campo VPF_CODITE
//
If VPE->VPE_QTDCON == "3" // Maximo: 3 Contagens
	cabec1  := left(STR0091,104) // "Locacao         Item                                            1a.Digitacao  2a.Digitacao  3a.Digitacao"
EndIf
//
DbSelectArea("VPF")
cQuery := "SELECT VPF.* , SB1.B1_DESC"
cQuery += "  FROM "+RetSqlName("VPF")+" VPF "
cQuery += "  JOIN "+RetSqlName("SB1")+" SB1 ON ( SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO=VPF.VPF_GRUITE AND SB1.B1_CODITE=VPF.VPF_CODITE AND SB1.D_E_L_E_T_=' ' ) "
cQuery += " WHERE VPF.VPF_FILIAL='"+xFilial("VPF")+"'"
cQuery += "   AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"'"
cQuery += "   AND VPF.D_E_L_E_T_=' '"
cQuery += "   AND ( VPF.VPF_ALMOX<>' ' OR VPF.VPF_LOCAC<>' ' OR VPF.VPF_GRUITE<>' ' OR VPF.VPF_CODITE<>' ' ) "
cQuery += "ORDER BY VPF.VPF_ALMOX , VPF.VPF_LOCAC , VPF.VPF_CODITE"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPF, .F., .T. )
ProcRegua(RecCount()/800)
While !( cQAlVPF )->( Eof() )
	ni++
	If ni == 800
		ni := 0
		IncProc(STR0053) // "Gerando Relacao dos Itens..."
	EndIf
	nCont1 := 0
	nCont2 := 0
	nCont3 := 0
	nCont4 := 0
	nCont5 := 0
	If cAgrup == "S"
		If cAgrAx == ( cQAlVPF )->( VPF_ALMOX )+( cQAlVPF )->( VPF_LOCAC )+( cQAlVPF )->( VPF_CODITE )
			( cQAlVPF )->( DbSkip() )
			Loop
		Else
			cAgrAx := ( cQAlVPF )->( VPF_ALMOX )+( cQAlVPF )->( VPF_LOCAC )+( cQAlVPF )->( VPF_CODITE )
			cQuery := "SELECT SUM(VPF.VPF_CONTA1) AS VPF_CONTA1 , SUM(VPF.VPF_CONTA2) AS VPF_CONTA2 , SUM(VPF.VPF_CONTA3) AS VPF_CONTA3 , SUM(VPF.VPF_CONTA4) AS VPF_CONTA4 , SUM(VPF.VPF_CONTA5) AS VPF_CONTA5 FROM "+RetSqlName("VPF")+" VPF WHERE VPF.VPF_FILIAL='"+( cQAlVPF )->( VPF_FILIAL )+"' AND VPF.VPF_CODIGO='"+VPE->VPE_CODIGO+"' AND VPF.VPF_ALMOX='"+( cQAlVPF )->( VPF_ALMOX )+"' AND VPF.VPF_LOCAC='"+( cQAlVPF )->( VPF_LOCAC )+"' AND VPF.VPF_CODITE='"+( cQAlVPF )->( VPF_CODITE )+"' AND VPF.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlQTD, .F., .T. )
			If !( cQAlQTD )->( Eof() )
				nCont1 := ( cQAlQTD )->( VPF_CONTA1 )
				nCont2 := ( cQAlQTD )->( VPF_CONTA2 )
				nCont3 := ( cQAlQTD )->( VPF_CONTA3 )
				nCont4 := ( cQAlQTD )->( VPF_CONTA4 )
				nCont5 := ( cQAlQTD )->( VPF_CONTA5 )
			EndIf
			( cQAlQTD )->( dbCloseArea() )
		EndIf
	Else
		nCont1 := ( cQAlVPF )->( VPF_CONTA1 )
		nCont2 := ( cQAlVPF )->( VPF_CONTA2 )
		nCont3 := ( cQAlVPF )->( VPF_CONTA3 )
		nCont4 := ( cQAlVPF )->( VPF_CONTA4 )
		nCont5 := ( cQAlVPF )->( VPF_CONTA5 )
	EndIf
	cImprimir := ""
	If ( VPE->VPE_QTDCON == "3" .and. cFase == "I4" ) .or. ( VPE->VPE_QTDCON == "5" .and. cFase == "I6" )
		If ( cQAlVPF )->( VPF_OK ) >= "1"
			cImprimir += right(Transform(nCont1,cPictQTD),14)
		EndIf
		If ( cQAlVPF )->( VPF_OK ) >= "2"
			cImprimir += right(Transform(nCont2,cPictQTD),14)
		EndIf
		If ( cQAlVPF )->( VPF_OK ) >= "3"
			cImprimir += right(Transform(nCont3,cPictQTD),14)
		EndIf
		If VPE->VPE_QTDCON == "5"
			If ( cQAlVPF )->( VPF_OK ) >= "4"
				cImprimir += right(Transform(nCont4,cPictQTD),14)
			EndIf
			If ( cQAlVPF )->( VPF_OK ) >= "5"
				cImprimir += right(Transform(nCont5,cPictQTD),14)
			EndIf
		EndIf
	Else
		If ( cQAlVPF )->( VPF_OK ) >= "1" .or. ( cFase == "D1" .and. ( cQAlVPF )->( VPF_OKDIG ) == "1" ) .or. ( nCont1 > 0 .and. ( cFase $ "I2/D2/I3/D3/I4/D4/I5/D5" ) )
			cImprimir += right(Transform(nCont1,cPictQTD),14)
		EndIf
		If ( cQAlVPF )->( VPF_OK ) >= "2" .or. ( cFase == "D2" .and. ( cQAlVPF )->( VPF_OKDIG ) == "1" ) .or. ( nCont2 > 0 .and. ( cFase $ "I3/D3/I4/D4/I5/D5" ) )
			cImprimir += right(Transform(nCont2,cPictQTD),14)
		EndIf
		If ( cQAlVPF )->( VPF_OK ) >= "3" .or. ( cFase == "D3" .and. ( cQAlVPF )->( VPF_OKDIG ) == "1" ) .or. ( nCont3 > 0 .and. ( cFase $ "I4/D4/I5/D5" ) )
			cImprimir += right(Transform(nCont3,cPictQTD),14)
		EndIf
		If VPE->VPE_QTDCON == "5"
			If ( cQAlVPF )->( VPF_OK ) >= "4" .or. ( cFase == "D4" .and. ( cQAlVPF )->( VPF_OKDIG ) == "1" ) .or. ( nCont4 > 0 .and. ( cFase $ "I5/D5" ) )
				cImprimir += right(Transform(nCont4,cPictQTD),14)
			EndIf
			If ( cQAlVPF )->( VPF_OK ) >= "5" .or. ( cFase == "D5" .and. ( cQAlVPF )->( VPF_OKDIG ) == "1" )
				cImprimir += right(Transform(nCont5,cPictQTD),14)
			EndIf
		EndIf
	EndIf
	If cAlm <> ( cQAlVPF )->( VPF_ALMOX ) .or. nLin > 60
		cAlm := ( cQAlVPF )->( VPF_ALMOX )
		nLin := cabec(Alltrim(titulo)+" - "+STR0049+cAlm,cabec1,cabec2,nomeprog,tamanho,15) + 1 // "Armazem: "
	EndIf
	@ nLin++,00 PSAY left(	( cQAlVPF )->( VPF_LOCAC )+" "+;
							( cQAlVPF )->( VPF_GRUITE )+" "+;
							left(( cQAlVPF )->( VPF_CODITE ),nTCodIte)+" "+;
							( cQAlVPF )->( B1_DESC )+;
							space(62),62)+;
							cImprimir
	( cQAlVPF )->( DbSkip() )
EndDo
( cQAlVPF )->( dbCloseArea() )
DbSelectArea("VPF")
Set Printer to
Set Device to Screen
If aReturn[5] == 1
	OurSpool( nomeprog )
EndIf
MS_Flush()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PARAM ³ Autor ³ Andre Luis Almeida                ³ Data ³ 02/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Parametros do Inventario                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PARAM()
//
Local oIHelp    := DMS_InterfaceHelper():New()
//
Local aObjects   := {}
Local lRet       := .f.
//
//
M->VQQ_CODFAM := "" // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
M->VQQ_CODGRU := "" // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
//
aParamInv := {}
aAdd(aParamInv,{Space(TamSX3("B2_LOCAL")[1]),"C",TamSX3("B2_LOCAL")[1]}) 		// Armazem Inicial  		 	[01]
aAdd(aParamInv,{Space(TamSX3("B2_LOCAL")[1]),"C",TamSX3("B2_LOCAL")[1]}) 		// Armazem Final  			 	[02]
aAdd(aParamInv,{Space(90),"C",90})					 							// Exceto Armazens 			 	[03]
aAdd(aParamInv,{Space(90),"C",90})					 							// Grupos a Considerar		 	[04]
aAdd(aParamInv,{Space(90),"C",90})					 							// Exceto Grupos 			 	[05]
aAdd(aParamInv,{Space(TamSX3("B5_CODCAI")[1]),"C",TamSX3("B5_CODCAI")[1]}) 		// Codigo CAI inicial		 	[06]
aAdd(aParamInv,{Space(TamSX3("B5_CODCAI")[1]),"C",TamSX3("B5_CODCAI")[1]}) 		// Codigo CAI final   		 	[07]
aAdd(aParamInv,{Space(TamSX3("B5_LOCALI2")[1]),"C",TamSX3("B5_LOCALI2")[1]})	// Localizacao inicial   	 	[08]
aAdd(aParamInv,{Space(TamSX3("B5_LOCALI2")[1]),"C",TamSX3("B5_LOCALI2")[1]})	// Localizacao Final	   	 	[09]
aAdd(aParamInv,{Space(90),"C",90})					 							// Exceto Localizacao      	 	[10]
aAdd(aParamInv,{"1","C",1})														// Valida contagens com estoque	[11]
aAdd(aParamInv,{"3","C",1})														// Qtde maxima de contagens		[12]
aAdd(aParamInv,{"1","C",1})														// Lista Itens com saldo zerado	[13]
aAdd(aParamInv,{"1","C",1})														// Bloqueia Itens a inventariar	[14]
aAdd(aParamInv,{"1","C",1})														// Tipo Movimentacao			[15]
aAdd(aParamInv,{ctod(""),"D",8})												// Dt.Mov. inicial				[16]
aAdd(aParamInv,{ctod(""),"D",8})												// Dt.Mov. final				[17]
aAdd(aParamInv,{"1","C",1})														// Valores						[18]
aAdd(aParamInv,{0,"N",12})														// Valor inicial				[19]
aAdd(aParamInv,{0,"N",12})														// Valor final					[20]
aAdd(aParamInv,{"1","C",1})														// Aglutina Bloq./Res.      	[21]
aAdd(aParamInv,{"1","C",1})					 									// Atualiza saldo atual na digit[22]
If lMLF
	aAdd(aParamInv,{space(TamSX3("B5_MARPEC")[1]),"C",TamSX3("B5_MARPEC")[1]})	// Marca da Peca				[23]
	aAdd(aParamInv,{space(TamSX3("B5_CODLIN")[1]),"C",TamSX3("B5_CODLIN")[1]}) 	// Linha da Peca				[24]
	aAdd(aParamInv,{space(TamSX3("B5_CODFAM")[1]),"C",TamSX3("B5_CODFAM")[1]}) 	// Familia da Peca				[25]
Else
	aAdd(aParamInv,{" ","C",1})													// Marca da Peca				[23]
	aAdd(aParamInv,{" ","C",1}) 												// Linha da Peca				[24]
	aAdd(aParamInv,{" ","C",1}) 												// Familia da Peca				[25]
EndIf
If lFGS
	aAdd(aParamInv,{space(TamSX3("B1_FAMAPL")[1]),"C",TamSX3("B1_FAMAPL")[1]})	// Familia Aplicacao			[26]
	aAdd(aParamInv,{space(TamSX3("B1_GRUAPL")[1]),"C",TamSX3("B1_GRUAPL")[1]})	// Grupo Aplicacao				[27]
	aAdd(aParamInv,{space(TamSX3("B1_SUBAPL")[1]),"C",TamSX3("B1_SUBAPL")[1]})	// SubGrupo Aplicacao			[28]
Else
	aAdd(aParamInv,{" ","C",1})													// Familia Aplicacao			[26]
	aAdd(aParamInv,{" ","C",1})													// Grupo Aplicacao				[27]
	aAdd(aParamInv,{" ","C",1})													// SubGrupo Aplicacao			[28]
EndIf
aAdd(aParamInv,{dDataBase,"D",8})												// Data de Previsão de Termino	[29]
aAdd(aParamInv,{"","M",47})														// Observacao					[30]
aAdd(aParamInv,{ctod(""),"D",8})												// Itens s/Inventário Desde		[31]
aAdd(aParamInv,{Space(TamSX3("B2_LOCAL")[1]),"C",TamSX3("B2_LOCAL")[1]}) 		// Armazem Inicial Movimentacao [32]
aAdd(aParamInv,{Space(TamSX3("B2_LOCAL")[1]),"C",TamSX3("B2_LOCAL")[1]}) 		// Armazem Final Movimentacao   [33]

FS_PROFILE(1) // Trazer conteudo dos parametros utilizando o Profile

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { "QUADRO_1" , 100 , 40 , .T. , .T. } ) // 40%
AAdd( aObjects, { "QUADRO_2" , 100 , 25 , .T. , .T. } ) // 25%
AAdd( aObjects, { "QUADRO_3" , 100 , 35 , .T. , .T. } ) // 35%
//
oSizePri := oIHelp:CreateDefSize(.t., aObjects )
oSizePri:Process()
//
oIHelp:SetDefSize(oSizePri)
oOFP040PAR := oIHelp:CreateDialog(STR0001+" - "+STR0134)
oIHelp:SetDialog(oOFP040PAR) // ACTIVATE
oIHelp:SetOwnerPvt("OFIPM040")
oIHelp:nOpc := 4
oOFP040PAR:lEscClose := .F.
//
oIHelp:Clean()
oIHelp:SetDefSize(oSizePri, "QUADRO_1")
oPainel_1 := oIHelp:CreateMGroup({{"TEXTO",""}})
oIHelp:setDialog(oPainel_1)
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[01,2] },;
	{'X3_TAMANHO' , aParamInv[01,3] },;
	{'X3_CAMPO'   , 'MV_PAR01'      },;
	{'X3_TITULO'  , STR0099         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[01,1] },;
	{'X3_F3'      , "NNR"           } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[02,2] },;
	{'X3_TAMANHO' , aParamInv[02,3] },;
	{'X3_CAMPO'   , 'MV_PAR02'      },;
	{'X3_TITULO'  , STR0100         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[02,1] },;
	{'X3_F3'      , "NNR"           } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[03,2] },;
	{'X3_TAMANHO' , aParamInv[03,3] },;
	{'X3_CAMPO'   , 'MV_PAR03'      },;
	{'X3_TITULO'  , STR0101         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[03,1] };
})
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[08,2] },;
	{'X3_TAMANHO' , aParamInv[08,3] },;
	{'X3_CAMPO'   , 'MV_PAR08'      },;
	{'X3_TITULO'  , STR0106         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[08,1] },;
	{'X3_F3'      , "SB5LOC"        } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[09,2] },;
	{'X3_TAMANHO' , aParamInv[09,3] },;
	{'X3_CAMPO'   , 'MV_PAR09'      },;
	{'X3_TITULO'  , STR0107         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[09,1] },;
	{'X3_F3'      , "SB5LOC"        } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[10,2] },;
	{'X3_TAMANHO' , aParamInv[10,3] },;
	{'X3_CAMPO'   , 'MV_PAR10'      },;
	{'X3_TITULO'  , STR0133         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[10,1] };
})
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[04,2] },;
	{'X3_TAMANHO' , aParamInv[04,3] },;
	{'X3_CAMPO'   , 'MV_PAR04'      },;
	{'X3_TITULO'  , STR0102         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[04,1] };
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[05,2] },;
	{'X3_TAMANHO' , aParamInv[05,3] },;
	{'X3_CAMPO'   , 'MV_PAR05'      },;
	{'X3_TITULO'  , STR0103         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[05,1] };
})
//
If lMLF // Filtro por Marca/Linha/Familia
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , aParamInv[23,2] },;
		{'X3_TAMANHO' , aParamInv[23,3] },;
		{'X3_CAMPO'   , 'MV_PAR23'      },;
		{'X3_TITULO'  , STR0135         },;
		{'X3_PICTURE' , "@!"            },;
		{'X3_RELACAO' , aParamInv[23,1] },;
		{'X3_F3'      , "VQS"           } ;
	})
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , aParamInv[24,2] },;
		{'X3_TAMANHO' , aParamInv[24,3] },;
		{'X3_CAMPO'   , 'MV_PAR24'      },;
		{'X3_TITULO'  , STR0136         },;
		{'X3_PICTURE' , "@!"            },;
		{'X3_RELACAO' , aParamInv[24,1] },;
		{'X3_F3'      , "0A"           } ;
	})
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , aParamInv[25,2] },;
		{'X3_TAMANHO' , aParamInv[25,3] },;
		{'X3_CAMPO'   , 'MV_PAR25'      },;
		{'X3_TITULO'  , STR0137         },;
		{'X3_PICTURE' , "@!"            },;
		{'X3_RELACAO' , aParamInv[25,1] },;
		{'X3_F3'      , "0B"           } ;
	})
ElseIf lFGS // Filtro por Familia/Grupo/SubGrupo
	M->VQQ_CODFAM := aParamInv[26,1] // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
	M->VQQ_CODGRU := aParamInv[27,1] // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , aParamInv[26,2] },;
		{'X3_TAMANHO' , aParamInv[26,3] },;
		{'X3_CAMPO'   , 'MV_PAR26'      },;
		{'X3_TITULO'  , STR0173         },;
		{'X3_PICTURE' , "@!"            },;
		{'X3_VALID'   , "OPM040VLD(1)"  },;
		{'X3_RELACAO' , aParamInv[26,1] },;
		{'X3_F3'      , "VQO"           } ;
	})
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , aParamInv[27,2] },;
		{'X3_TAMANHO' , aParamInv[27,3] },;
		{'X3_CAMPO'   , 'MV_PAR27'      },;
		{'X3_TITULO'  , STR0174         },;
		{'X3_PICTURE' , "@!"            },;
		{'X3_VALID'   , "OPM040VLD(2)"  },;
		{'X3_RELACAO' , aParamInv[27,1] },;
		{'X3_WHEN'    , { || .f. }      },;
		{'X3_F3'      , "VQP"           } ;
	})
	oIHelp:AddMGetTipo({;
		{'X3_TIPO'    , aParamInv[28,2] },;
		{'X3_TAMANHO' , aParamInv[28,3] },;
		{'X3_CAMPO'   , 'MV_PAR28'      },;
		{'X3_TITULO'  , STR0175         },;
		{'X3_PICTURE' , "@!"            },;
		{'X3_VALID'   , "OPM040VLD(3)"  },;
		{'X3_RELACAO' , aParamInv[28,1] },;
		{'X3_F3'      , "VQP2"          } ;
	})
EndIf
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[06,2] },;
	{'X3_TAMANHO' , aParamInv[06,3] },;
	{'X3_CAMPO'   , 'MV_PAR06'      },;
	{'X3_TITULO'  , STR0104         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[06,1] },;
	{'X3_F3'      , "E2V"           } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[07,2] },;
	{'X3_TAMANHO' , aParamInv[07,3] },;
	{'X3_CAMPO'   , 'MV_PAR07'      },;
	{'X3_TITULO'  , STR0105         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[07,1] },;
	{'X3_F3'      , "E2V"           } ;
})
//
oEnch1 := oIHelp:CreateMSMGet(.f., { { "ALINHAMENTO" , CONTROL_ALIGN_ALLCLIENT } } )
//
oIHelp:Clean()
oIHelp:SetDialog(oOFP040PAR)
oIHelp:SetDefSize(oSizePri, "QUADRO_2")
oPainel_2 := oIHelp:CreateMGroup({{"TEXTO",""}})
oIHelp:setDialog(oPainel_2)
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[15,2] },;
	{'X3_TAMANHO' , aParamInv[15,3] },;
	{'X3_CAMPO'   , 'MV_PAR15'      },;
	{'X3_TITULO'  , STR0119         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("1234") .and. OPM040VLD(4)' },;
	{'X3_RELACAO' , aParamInv[15,1] },;
	{'X3_CBOX'    , "1="+STR0120+";2="+STR0121+";3="+STR0122+";4="+STR0123 } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[16,2] },;
	{'X3_TAMANHO' , aParamInv[16,3] },;
	{'X3_CAMPO'   , 'MV_PAR16'      },;
	{'X3_TITULO'  , STR0124         },;
	{'X3_PICTURE' , "@D"            },;
	{'X3_RELACAO' , aParamInv[16,1] },;
	{'X3_WHEN'    , { || M->MV_PAR15 <> "1" } } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[17,2] },;
	{'X3_TAMANHO' , aParamInv[17,3] },;
	{'X3_CAMPO'   , 'MV_PAR17'      },;
	{'X3_TITULO'  , STR0125         },;
	{'X3_PICTURE' , "@D"            },;
	{'X3_RELACAO' , aParamInv[17,1] },;
	{'X3_WHEN'    , { || M->MV_PAR15 <> "1" } } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[32,2] },;
	{'X3_TAMANHO' , aParamInv[32,3] },;
	{'X3_CAMPO'   , 'MV_PAR32'      },;
	{'X3_TITULO'  , STR0193         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[32,1] },;
	{'X3_F3'      , "NNR"           },;
	{'X3_WHEN'    , { || M->MV_PAR15 <> "1" } } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[33,2] },;
	{'X3_TAMANHO' , aParamInv[33,3] },;
	{'X3_CAMPO'   , 'MV_PAR33'      },;
	{'X3_TITULO'  , STR0194         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[33,1] },;
	{'X3_F3'      , "NNR"           },;
	{'X3_WHEN'    , { || M->MV_PAR15 <> "1" } } ;
})
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[18,2] },;
	{'X3_TAMANHO' , aParamInv[18,3] },;
	{'X3_CAMPO'   , 'MV_PAR18'      },;
	{'X3_TITULO'  , STR0126         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("123") .and. OPM040VLD(5)' },;
	{'X3_RELACAO' , aParamInv[18,1] },;
	{'X3_CBOX'    , "1="+STR0120+";2="+STR0127+";3="+STR0128 } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[19,2] },;
	{'X3_TAMANHO' , aParamInv[19,3] },;
	{'X3_DECIMAL' , 2               },;
	{'X3_CAMPO'   , 'MV_PAR19'      },;
	{'X3_TITULO'  , STR0129         },;
	{'X3_PICTURE' , "@E 999,999,999.99" },;
	{'X3_VALID'   , 'Positivo()' },;
	{'X3_RELACAO' , aParamInv[19,1] },;
	{'X3_WHEN'    , { || M->MV_PAR18 <> "1" } } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[20,2] },;
	{'X3_TAMANHO' , aParamInv[20,3] },;
	{'X3_DECIMAL' , 2               },;
	{'X3_CAMPO'   , 'MV_PAR20'      },;
	{'X3_TITULO'  , STR0130         },;
	{'X3_PICTURE' , "@E 999,999,999.99" },;
	{'X3_VALID'   , 'Positivo()' },;
	{'X3_RELACAO' , aParamInv[20,1] },;
	{'X3_WHEN'    , { || M->MV_PAR18 <> "1" } } ;
})
//
oEnch2 := oIHelp:CreateMSMGet(.f., { { "ALINHAMENTO" , CONTROL_ALIGN_ALLCLIENT } } )
//
oIHelp:Clean()
oIHelp:SetDialog(oOFP040PAR)
oIHelp:SetDefSize(oSizePri, "QUADRO_3")
oPainel_3 := oIHelp:CreateMGroup({{"TEXTO",""}})
oIHelp:setDialog(oPainel_3)
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[31,2] },;
	{'X3_TAMANHO' , aParamInv[31,3] },;
	{'X3_CAMPO'   , 'MV_PAR31'      },;
	{'X3_TITULO'  , STR0181         },;
	{'X3_PICTURE' , "@D"            },;
	{'X3_RELACAO' , aParamInv[31,1] } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[13,2] },;
	{'X3_TAMANHO' , aParamInv[13,3] },;
	{'X3_CAMPO'   , 'MV_PAR13'      },;
	{'X3_TITULO'  , STR0110         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("12")' },;
	{'X3_RELACAO' , aParamInv[13,1] },;
	{'X3_CBOX'    , "1="+STR0112+";2="+STR0113 } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[14,2] },;
	{'X3_TAMANHO' , aParamInv[14,3] },;
	{'X3_CAMPO'   , 'MV_PAR14'      },;
	{'X3_TITULO'  , STR0111         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("12")' },;
	{'X3_RELACAO' , aParamInv[14,1] },;
	{'X3_CBOX'    , "1="+STR0112+";2="+STR0113 } ;
})
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[21,2] },;
	{'X3_TAMANHO' , aParamInv[21,3] },;
	{'X3_CAMPO'   , 'MV_PAR21'      },;
	{'X3_TITULO'  , STR0131         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("12")' },;
	{'X3_RELACAO' , aParamInv[21,1] },;
	{'X3_CBOX'    , "1="+STR0112+";2="+STR0113 } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[11,2] },;
	{'X3_TAMANHO' , aParamInv[11,3] },;
	{'X3_CAMPO'   , 'MV_PAR11'      },;
	{'X3_TITULO'  , STR0108         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("123")' },;
	{'X3_RELACAO' , aParamInv[11,1] },;
	{'X3_CBOX'    , "1="+STR0114+";2="+STR0115+";3="+STR0116 } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[22,2] },;
	{'X3_TAMANHO' , aParamInv[22,3] },;
	{'X3_CAMPO'   , 'MV_PAR22'      },;
	{'X3_TITULO'  , STR0132         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("12")' },;
	{'X3_RELACAO' , aParamInv[22,1] },;
	{'X3_CBOX'    , "1="+STR0112+";2="+STR0113 } ;
})
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[12,2] },;
	{'X3_TAMANHO' , aParamInv[12,3] },;
	{'X3_CAMPO'   , 'MV_PAR12'      },;
	{'X3_TITULO'  , STR0109         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_VALID'   , 'Pertence("35")' },;
	{'X3_RELACAO' , aParamInv[12,1] },;
	{'X3_CBOX'    , "3="+STR0117+";5="+STR0118 } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[29,2] },;
	{'X3_TAMANHO' , aParamInv[29,3] },;
	{'X3_CAMPO'   , 'MV_PAR29'      },;
	{'X3_TITULO'  , STR0178         },;
	{'X3_PICTURE' , "@D"            },;
	{'X3_VALID'   , 'vazio() .or. M->MV_PAR29>=dDataBase' },;
	{'X3_RELACAO' , aParamInv[29,1] } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , aParamInv[30,2] },;
	{'X3_TAMANHO' , aParamInv[30,3] },;
	{'X3_CAMPO'   , 'MV_PAR30'      },;
	{'X3_TITULO'  , STR0151         },;
	{'X3_PICTURE' , "@!"            },;
	{'X3_RELACAO' , aParamInv[30,1] } ;
})
//
oEnch3 := oIHelp:CreateMSMGet(.f., { { "ALINHAMENTO" , CONTROL_ALIGN_ALLCLIENT } } )
//
ACTIVATE MSDIALOG oOFP040PAR ON INIT EnchoiceBar(oOFP040PAR,{|| IIf(OPM040VLD(0),(lRet:=.t.,oOFP040PAR:End()),.t.) },{|| oOFP040PAR:End() } )

If lRet
	FS_PROFILE(2) // Gravar conteudo dos parametros utilizando o Profile
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPM040VLD³ Autor ³ Andre Luis Almeida                ³ Data ³ 15/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao nos parametros do Inventario                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040VLD(nTp)
Local lRet := .t.
Do Case
	Case nTp == 0 // Tudo OK na tela de Parametros
		If Empty(M->MV_PAR01+M->MV_PAR01)
			MsgInfo(STR0179+' " '+STR0099+' / '+STR0100+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR08+M->MV_PAR09)
			MsgInfo(STR0179+' " '+STR0106+' / '+STR0107+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR06+M->MV_PAR07)
			MsgInfo(STR0179+' " '+STR0104+' / '+STR0105+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR15)
			MsgInfo(STR0179+' " '+STR0119+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR18)
			MsgInfo(STR0179+' " '+STR0126+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR13)
			MsgInfo(STR0179+' " '+STR0110+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR14)
			MsgInfo(STR0179+' " '+STR0111+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR21)
			MsgInfo(STR0179+' " '+STR0131+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR11)
			MsgInfo(STR0179+' " '+STR0108+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR22)
			MsgInfo(STR0179+' " '+STR0132+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If Empty(M->MV_PAR12)
			MsgInfo(STR0179+' " '+STR0109+' " ',STR0023)// Favor informar o parâmetro
			lRet := .f.
        EndIf
		If M->MV_PAR14 == "1"
			If Empty(M->MV_PAR29)
				MsgInfo(STR0179+' " '+STR0178+' " ',STR0023)// Favor informar o parâmetro
				lRet := .f.
			ElseIf M->MV_PAR29 < dDatabase
				MsgInfo(STR0180+' " '+STR0178+' " ',STR0023)// Favor informar uma data igual ou superior a data atual no parâmetro
				lRet := .f.
			EndIf
		EndIf
	Case nTp == 1 // Familia
		M->VQQ_CODFAM := M->MV_PAR26 // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
		If !Empty(M->MV_PAR28)
			VQP->(DbSetOrder(2)) // VQP_FILIAL+VQP_SUBGRU+VQP_CODGRU+VQP_CODFAM
			VQP->(DbSeek(xFilial("VQP")+M->MV_PAR28))
			If M->VQQ_CODFAM <> VQP->VQP_CODFAM .or. M->MV_PAR27 <> VQP->VQP_CODGRU
				M->VQQ_CODGRU := M->MV_PAR27 := space(TamSX3("B1_GRUAPL")[1]) // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
				M->MV_PAR28 := space(TamSX3("B1_SUBAPL")[1])
			EndIf
		EndIf
	Case nTp == 2 // Grupo
		M->VQQ_CODGRU := M->MV_PAR27 // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
		M->MV_PAR28 := space(TamSX3("B1_SUBAPL")[1])
	Case nTp == 3 // SubGrupo
		If !Empty(M->MV_PAR28)
			VQP->(DbSetOrder(2)) // VQP_FILIAL+VQP_SUBGRU+VQP_CODGRU+VQP_CODFAM
			If VQP->(DbSeek(xFilial("VQP")+M->MV_PAR28))
				M->VQQ_CODFAM := M->MV_PAR26 := VQP->VQP_CODFAM // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
				M->VQQ_CODGRU := M->MV_PAR27 := VQP->VQP_CODGRU // M->VQQ_ variavel utilizada no Filtro do F3 do VQP/VQP2
			Else
				lRet := .f.
			EndIf
		EndIf
	Case nTp == 4 // Tipo de Movimentacao
		If M->MV_PAR15 == "1" // Nao considerar
			M->MV_PAR16 := ctod("")
			M->MV_PAR17 := ctod("")
			M->MV_PAR32 := space(aParamInv[32,3])
			M->MV_PAR33 := space(aParamInv[33,3])
		EndIf
	Case nTp == 5 // Valores
		If M->MV_PAR18 == "1" // Nao considerar
			M->MV_PAR19 := 0
			M->MV_PAR20 := 0
		EndIf                            
EndCase
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OPM040MENU³ Autor ³ Andre Luis Almeida                ³ Data ³ 22/01/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Inventario                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040MENU()
Local aRotina := {}
Local aRotUsr := {}
Local ni      := 0
DbSelectArea("VAI")
DbSetOrder(4)
MsSeek(xFilial("VAI")+__cUserID)
If VAI->VAI_INVUSR == "1" // Coordenador
	aRotina := {	{STR0146,"AxPesqui"	,0,1},; 	   	// Pesquisar
					{STR0147,"OPM040INI",0,3},; 		// Incluir
					{STR0148,"OPM040EXE",0,4},;   		// Manutencao
					{STR0145,"OPM040LEG",0,4,2,.f.}} 	// Legenda
Else
	aRotina := MenuDef() // Chamada Padrao
EndIf
//
If ( ExistBlock("OPM040AR") )
	aRotUsr := ExecBlock("OPM040AR",.f.,.f.) // NOVAS opcoes customizadas no Acoes Relacionadas da rotina de Inventario
	For ni := 1 to len(aRotUsr)
		aAdd(aRotina,aClone(aRotUsr[ni]))
	Next
EndIf
//
DbSelectArea("VPE")
Return aRotina

Static Function MenuDef()
Local	aRotina := {{STR0146,"AxPesqui"	,0,1},; 		// Pesquisar
					{STR0149,"OPM040EXE",0,2},;   		// Digitar
					{STR0145,"OPM040LEG",0,4,2,.f.}} 	// Legenda
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OPM040LEG ³ Autor ³ Andre Luis Almeida                ³ Data ³ 22/01/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - INVENTARIO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040LEG()
Local aLegenda := {	{'BR_PRETO'   , STR0142 },; // Finalizado
					{'BR_VERMELHO', STR0143 },; // Cancelado
					{'BR_VERDE'   , STR0144 }}  // Em Andamento
BrwLegenda(cCadastro,STR0145,aLegenda) // Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GERANF³ Autor ³  Thiago					  ³ Data ³ 10/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geração de NF.						                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GERANF()
Local lRet := .t.
Private cProxNum := ""
if Len(aSF1) > 0  .and. lRet
	Processa({ || lRet := GeraNFE(aRetPar) })
Endif
IF Len(aSF2) > 0  .and. lRet
	Processa({ || lRet := GeraPedido(aRetParC) })
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraNFE³ Autor ³  Thiago					  ³ Data ³ 10/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geração de NF de Entrada. 		                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraNFE(aRet)
	Local aCabec  := {}
	Local aItens  := {}
	Local _ni     := 1
	Local nItem   := 0
	Local nX      := 1
	Local nIdx    := 0
	Local cNotas  := ""

	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+aRet[1,1]+aRet[1,2])

	aCabec   := {}
	aadd(aCabec,{"F1_TIPO"   	,"N"})
	aadd(aCabec,{"F1_FORMUL" 	,"S"})
	aadd(aCabec,{"F1_DOC"    	,""})
	aadd(aCabec,{"F1_SERIE"  	,cSerie})
	aadd(aCabec,{"F1_EMISSAO"	,dDataBase})
	aadd(aCabec,{"F1_FORNECE"	,aRet[1,1]})
	aadd(aCabec,{"F1_LOJA"   	,aRet[1,2]})
	aadd(aCabec,{"F1_ESPECIE"	,aRet[1,4]})
	aadd(aCabec,{"F1_COND"		,aRet[1,3]})
	aadd(aCabec,{"F1_EST"		,SA2->A2_EST}) // Alteraçao realizada pois estava gravando incorretamente quando transferencia entre estado - MAQNELSON

	For _ni := 1 to Len(aSF1)

		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+aSF1[_ni,1]+aSF1[_ni,2])
		dbSetOrder(1)

		nItem += 1

		Aadd(aItens , {	;
		{"D1_ITEM"		, Strzero(nItem,4)								  		,NIL},;
		{"D1_COD"		, SB1->B1_COD                    						,NIL},;
		{"D1_UM"    	, SB1->B1_UM			              					,NIL},;
		{"D1_QUANT"		, aSF1[_ni,7]		                 					,NIL},;
		{"D1_VUNIT"		, aSF1[_ni,8]							 				,NIL},;
		{"D1_TOTAL"		, Round(aSF1[_ni,8] *aSF1[_ni,7],TamSx3("D1_TOTAL")[2])	,NIL},;
		{"D1_LOCAL"		, FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")  		  	,NIL}})


		// verificar se alcançou numero max de itens ou se o loop acabou e tem itens

		if len(aItens) == nMaxIteNf .or. _ni == len(aSF1)
			lMsErroAuto := .f.
			// Caso tenha itens e cabecalho definidos
			If Len(aItens) > 0 .And. Len(aCabec) > 0
				cProxNum := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
				aCabec[3,2] := cProxNum
				If ExistBlock("OPM040NFE")
					ExecBlock("OPM040NFE",.f.,.f.,{aCabec,aItens,aRet[1,1],aRet[1,2]})
				Else
					// Inclui pre-nota
					MATA140(aCabec,aItens,3)
				Endif

				// Checa erro de rotina automatica
				If lMsErroAuto
					lMostraErro	:=.T.
					MostraErro()
					RollBAckSx8()
					Return(.f.)
				EndIf
			Endif

			// Gravacao da nota de entrada
			for nX := nX to _ni
				// registro do VPG
				nIdx := ascan(aVPGData, {|x| x[2] + x[3] + x[4] + x[5] == aSF1[nX, 1] + aSF1[nX, 2] + aSF1[nX, 3] + aSF1[nX, 4] })
				dbSelectArea('VPG')
				dbSetOrder(1)
				dbGoTo(aVPGData[nIdx, 1])
				reclock("VPG", .f.)
				VPG->VPG_NFIENT := aCabec[3,2] // F1_DOC
				VPG->VPG_SERENT := cSerie
				VPG->VPG_FORNEC := aRet[1,1]
				VPG->VPG_LOJA   := aRet[1,2]
				msunlock()
			next
			cNotas += CRLF + aCabec[3,2] + "/" + cSerie

			// zerando os caches/variaveis para proxima nota caso exista
			aItens := {}
			nItem  := 0
		endif 
	Next

	MsgInfo(STR0168 + CRLF + CRLF + STR0169 + cNotas)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraPedido³ Autor ³  Thiago					  ³ Data ³ 10/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geração do Pedido de Venda. 	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraPedido(aRet)
	Local _niS     := 0
	Local aCabecS  := {}
	Local aIteSai  := {}
	Local cNumIte  := "00"
	Local nX       := 1
	Local nIdx     := 0
	Local cPedidos := ""

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+aRet[1,1]+aRet[1,2])

	aadd(aCabecS,{"C5_TIPO"	,"N"				,Nil})
	aadd(aCabecS,{"C5_CLIENTE",aRet[1,1] 	,Nil})
	aadd(aCabecS,{"C5_LOJACLI",aRet[1,2]	,Nil})
	aadd(aCabecS,{"C5_LOJAENT",aRet[1,2]	,Nil})
	aadd(aCabecS,{"C5_CONDPAG",aRet[1,4]	,Nil})
	aadd(aCabecS,{"C5_VEND1",aRet[1,5]		,Nil})
	aAdd(aCabecS,{"C5_TIPOCLI",SA1->A1_TIPO ,Nil}) // Tipo do Cliente
	aadd(aCabecS,{"C5_TPFRETE","S"		,Nil}) // Tipo Frete			->	S = Sem Frete
	aAdd(aCabecS,{"C5_INDPRES","0" ,Nil}) // Indice de presença   ->  0 = Não se Aplica

	lMsErroAuto := .f.

	For _niS := 1 to Len(aSF2)

		 dbSelectArea("SB1")
		 dbSetOrder(7)
		 dbSeek(xFilial("SB1")+aSF2[_niS,1]+aSF2[_niS,2])
	 	 dbSetOrder(1)

		 cTESSai := MaTesInt(2,aRet[1,3],SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
		 cNumIte := SOMA1(cNumIte)

		 aLinha := {}
		 aadd(aLinha,{"C6_ITEM"   	,cNumIte								,Nil})
		 aadd(aLinha,{"C6_PRODUTO"	,SB1->B1_COD							,Nil})
		 aadd(aLinha,{"C6_LOCAL"  	,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil})
		 aadd(aLinha,{"C6_QTDVEN" 	,aSF2[_niS,7]							,Nil})
		 aadd(aLinha,{"C6_PRCVEN"	,Round(aSF2[_niS,8],2)					,Nil})
		 aadd(aLinha,{"C6_PRUNIT" 	,Round(aSF2[_niS,8],2)					,Nil})
		 aadd(aLinha,{"C6_VALOR"  	,Round(aSF2[_niS,8],2)*aSF2[_niS,7]		,Nil})
		 aadd(aLinha,{"C6_QTDLIB" 	,0             							,Nil})
		 aadd(aLinha,{"C6_TES"   	,Alltrim(cTESSai)						,Nil})
 		 aadd(aIteSai, aLinha)

		if len(aIteSai) == nMaxIteNf .or. _niS == len(aSF2)
			//Ponto de Entrada p/ inclusao de campos (SC5 e SC6) na integração com o pedido de venda (MATA410)
			If ExistBlock("OPM040CPO")
				aVet := ExecBlock("OPM040CPO",.f.,.f.,{aCabecS,aIteSai})
				aCabecS := aVet[1]
				aIteSai := aVet[2]
			EndIf

		   // Inclusao do pedido
			MsExecAuto({|x,y,z| mata410(x,y,z)},aCabecS,aIteSai,3)
		   // Checa erro de rotina automatica
		   If lMsErroAuto
		  		Mostraerro()
				RollBAckSx8()
				Return(.f.)
			Endif

			// Gravacao da nota de entrada
			for nX := nX to _niS
				// registro do VPG
				nIdx := ascan(aVPGData, {|x| x[2] + x[3] + x[4] + x[5] == aSF2[nX, 1] + aSF2[nX, 2] + aSF2[nX, 3] + aSF2[nX, 4] })
				dbSelectArea('VPG')
				dbSetOrder(1)
				dbGoTo(aVPGData[nIdx, 1])
				reclock("VPG", .f.)
				VPG->VPG_NUMPED := SC5->C5_NUM
				msunlock()
			next
			cPedidos += CRLF + SC5->C5_NUM

			// zerando os caches/variaveis para proxima nota caso exista
			aIteSai := {}
			cNumIte := "00"
		endif

 	Next

	MsgInfo(STR0170 + CRLF + CRLF + STR0171 + cPedidos)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OPM040VFOR³ Autor ³  Thiago			    ³ Data ³ 10/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validaçao do parametro fornecedor.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPM040VFOR()

MV_PAR02 := SA2->A2_LOJA

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALCODITE³ Autor ³ Thiago				³ Data ³ 27/04/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validaçao do campo codigo item.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALCODITE(cGruIte,cCodIte)

if !Empty(cCodIte)
	oDiverg:nAt := aScan(aDiverg,{|x| x[3]+x[4] == cGruIte+cCodIte })
	if oDiverg:nAt > 0
		oDiverg:SetArray(aDiverg)
		oDiverg:bLine := { || {	aDiverg[oDiverg:nAt,1] , ;
								aDiverg[oDiverg:nAt,2] , ;
								aDiverg[oDiverg:nAt,3] , ;
								aDiverg[oDiverg:nAt,4] , ;
								aDiverg[oDiverg:nAt,5] , ;
								FG_AlinVlrs(Transform(aDiverg[oDiverg:nAt,6],cPictQTD)) }}
								oDiverg:Refresh()
	Else
		oDiverg:nAt := 1
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PROFILE³ Autor ³ Andre Luis Almeida	³ Data ³ 27/04/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Conteudo dos Parametros - Profile do USUARIO               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PROFILE(nTp)
Local ni := 0
Local xAux
Local oProfile
If nTp == 1 // Trazer conteudo do Profile do Usuario
	oProfile := NIL
	oProfile := FWProfile():New()
	oProfile:SetTask("OFIPM040")
	For ni := 1 to len(aParamInv)
		oProfile:SetType("MV_PAR"+strzero(ni,2))
		oProfile:Load()
		xAux := oProfile:GetStringProfile()
		Do Case
			Case aParamInv[ni,2] == "C" // Caracter
				aParamInv[ni,1] := Padr(xAux,aParamInv[ni,3])
			Case aParamInv[ni,2] == "D" // Data
				aParamInv[ni,1] := stod(xAux)
			Case aParamInv[ni,2] == "N" // Numerico
		   		aParamInv[ni,1] := val(xAux)
			Case aParamInv[ni,2] == "M" // Memo
		   		aParamInv[ni,1] := xAux
	 	EndCase
	Next
Else // Gravar conteudo no Profile do Usuario
	oProfile := FWProfile():New()
	oProfile:SetTask("OFIPM040")
	For ni := 1 to len(aParamInv)
		oProfile:SetType("MV_PAR"+strzero(ni,2))
		Do Case
			Case aParamInv[ni,2] == "C" // Caracter
				xAux := Padr(&("M->MV_PAR"+strzero(ni,2)),aParamInv[ni,3])
			Case aParamInv[ni,2] == "D" // Data
				xAux := dtos(&("M->MV_PAR"+strzero(ni,2)))
			Case aParamInv[ni,2] == "N" // Numerico
		   		xAux := Transform(&("M->MV_PAR"+strzero(ni,2)),"@E 999999999.99")
			Case aParamInv[ni,2] == "M" // Memo
		   		xAux := &("M->MV_PAR"+strzero(ni,2))
	 	EndCase
	 	aParamInv[ni,1] := &("M->MV_PAR"+strzero(ni,2))
		oProfile:SetStringProfile(xAux)
		oProfile:Save()
	Next
	oProfile:Destroy()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OPM040TCOD³ Autor ³ Andre Luis Almeida	³ Data ³ 18/12/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tamanho maximo de caracteres gravados no campo VPF_CODITE  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OPM040TCOD()
Local oSqlHelp  := Dms_SqlHelper():New()
Local cQuery    := ""
Local nTCodIte  := 0
//
cQuery := "SELECT MAX(" + oSqlHelp:CompatFunc('LEN') + "(" + oSqlHelp:CompatFunc('TRIM') + "(VPF_CODITE)))"
cQuery += "  FROM "+RetSQLName("VPF")
cQuery += " WHERE VPF_FILIAL = '" + xFilial("VPF")  + "'"
cQuery += "   AND VPF_CODIGO = '" + VPE->VPE_CODIGO + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
nTCodIte := FM_SQL(cQuery) + 1 // Tamanho maximo de caracteres gravados no campo VPF_CODITE
//
Return nTCodIte


/*/{Protheus.doc} OPM040011_VisualizaDocumentos()

Visualiza Documentos de Entrada / Saida / SB7

@author Andre Luis Almeida
@since 28/06/2019
@version undefined
@param nTp numerico, Tipo 1-SB7 / 2-NF
@type function
/*/
Static Function OPM040011_VisualizaDocumentos(nTp)
//
Local cTitulo := ""
Local cQuery  := ""
Local cQAlias := "SQLVPG"
Local aIntCab := {} // Cabeçalhos da função FGX_VISINT
Local aIntIte := {} // Itens da função FGX_VISINT
Local lVPE_DOCSB7 := ( VPE->(FieldPos("VPE_DOCSB7")) > 0 )
//
If nTp == 1 // SB7
	//
	If lVPE_DOCSB7
		cTitulo := STR0197 // Documento do Lançamento do Inventário
		//
		aAdd(aIntCab,{RetTitle("VPE_FILIAL"),"C",60,"@!"})			//01 - Filial
		aAdd(aIntCab,{RetTitle("VPE_CODIGO"),"C",40,"@!"})			//02 - Cod.Inventario
		aAdd(aIntCab,{RetTitle("VPE_DATINI"),"D",30,"@D"})			//03 - Data Inicial
		aAdd(aIntCab,{RetTitle("VPE_HORINI"),"N",20,"@R 99:99"})	//04 - Hora Inicial
		aAdd(aIntCab,{RetTitle("VPE_DATFIN"),"D",30,"@D"})			//05 - Data Final
		aAdd(aIntCab,{RetTitle("VPE_HORFIN"),"N",20,"@R 99:99"})	//06 - Data Final
		aAdd(aIntCab,{RetTitle("VPE_DOCSB7"),"C",50,"@!"})			//07 - Documento SB7
		//
		aAdd(aIntIte,{	VPE->VPE_FILIAL,;
						VPE->VPE_CODIGO,;
						VPE->VPE_DATINI,;
						VPE->VPE_HORINI,;
						VPE->VPE_DATFIN,;
						VPE->VPE_HORFIN,;
						VPE->VPE_DOCSB7})
	EndIf
	//
Else // NF
	//
	cTitulo := STR0198 // Notas Fiscais de Divergências do Inventário
	//
	aAdd(aIntCab,{RetTitle("VPE_FILIAL"),"C",60,"@!"})			//01 - Filial
	aAdd(aIntCab,{STR0199,"C",50,"@!"})							//02 - Tipo NF
	aAdd(aIntCab,{RetTitle("C5_NOTA"),"C",50,"@!"})				//03 - Numero NF
	aAdd(aIntCab,{RetTitle("C5_SERIE"),"C",40,"@!"})			//04 - Serie NF
	aAdd(aIntCab,{STR0157+"/"+STR0163,"C",60,"@!"})				//05 - Fornecedor/Cliente
	aAdd(aIntCab,{STR0158,"C",40,"@!"})							//06 - Loja
	aAdd(aIntCab,{RetTitle("A1_NOME") ,"C",100,"@!"})			//07 - Nome
	//
	cQuery := "SELECT DISTINCT "
	cQuery += "       VPG.VPG_NFIENT , VPG.VPG_SERENT , VPG.VPG_FORNEC , VPG.VPG_LOJA   , SA2.A2_NOME ,"
	cQuery += "       SC5.C5_NOTA    , SC5.C5_SERIE   , SC5.C5_CLIENTE , SC5.C5_LOJACLI , SA1.A1_NOME  "
	cQuery += "  FROM "+RetSQLName("VPG")+" VPG "
	cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD = VPG.VPG_FORNEC AND SA2.A2_LOJA = VPG.VPG_LOJA AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN "+RetSqlName("SC5")+" SC5 ON SC5.C5_FILIAL='"+xFilial("SC5")+"' AND SC5.C5_NUM = VPG.VPG_NUMPED AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VPG.VPG_FILIAL = '"+xFilial("VPG")+"'"
	cQuery += "   AND VPG.VPG_CODIGO = '"+VPE->VPE_CODIGO+"'"
	cQuery += "   AND VPG.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		If !Empty( ( cQAlias )->( VPG_NFIENT ) ) // NF Entrada
			aAdd(aIntIte,{	VPE->VPE_FILIAL,;
							STR0200 ,;
							( cQAlias )->( VPG_NFIENT ) ,;
							( cQAlias )->( VPG_SERENT ) ,;
							( cQAlias )->( VPG_FORNEC ) ,;
							( cQAlias )->( VPG_LOJA )   ,;
							( cQAlias )->( A2_NOME )    })
		Else // NF Saida
			aAdd(aIntIte,{	VPE->VPE_FILIAL,;
							STR0201 ,;
							( cQAlias )->( C5_NOTA )    ,;
							( cQAlias )->( C5_SERIE )   ,;
							( cQAlias )->( C5_CLIENTE ) ,;
							( cQAlias )->( C5_LOJACLI ) ,;
							( cQAlias )->( A1_NOME )    })
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
	//
EndIf
//
DbSelectArea("VPE")
//
If len(aIntIte) > 0
	FGX_VISINT( "OFIPM040_DOCTOS" , cTitulo , aIntCab , aIntIte )
EndIf
//
Return


/*/{Protheus.doc} OPM0400015_F3Endereco()
    Consulta F3 do campo Localização ( browse em SQL )

    @author Renato Vinicius
    @since  22/11/2021
/*/
Function OPM0400015_F3Endereco()

Local aSize := FWGetDialogSize(oMainWnd)
Local oF3Opc
Local oBrowseDet
Local lRet := .f.
Local cQuery := ""

Private cReadVar:= ReadVar()
Private aRotina := {}

DbSelectArea("SB5")
DbSelectArea("SBZ")

cQuery += "SELECT * FROM ("
cQuery += 		"SELECT DISTINCT (LOC.B5_LOCALI2) AS LOCALI2 FROM "+RetSQLName("SB5")+" LOC WHERE LOC.B5_FILIAL = '" +xFilial("SB5")+ "' AND LOC.B5_LOCALI2 <> ' ' AND LOC.D_E_L_E_T_ = ' '"
cQuery += 		"UNION "
cQuery += 		"SELECT DISTINCT (LOC.BZ_LOCALI2) AS LOCALI2 FROM "+RetSQLName("SBZ")+" LOC WHERE LOC.BZ_FILIAL = '" +xFilial("SBZ")+ "' AND LOC.BZ_LOCALI2 <> ' ' AND LOC.D_E_L_E_T_ = ' '"
cQuery += ") TEMP ORDER BY 1"

oF3Opc := MSDialog():New( aSize[1]/2, aSize[2]/2, aSize[3]/2, aSize[4]/2, STR0019 , , , , , , , , , .T., , , , .F. )

oFWLayerMAS := FWLayer():New()
oFWLayerMAS:Init( oF3Opc, .F., .T.)
oFWLayerMAS:AddLine( 'TOP' , 100, .F.)

oPnlTop := oFWLayerMAS:GetLinePanel ('TOP')

oBrowseDet:= FWMBrowse():New()
oBrowseDet:SetOwner(oPnlTop)
oBrowseDet:SetDescription(STR0019)
oBrowseDet:SetDataQuery(.T.)
oBrowseDet:SetAlias("SQLEND")
oBrowseDet:SetQuery(cQuery)
oBrowseDet:SetUseFilter()
oBrowseDet:SetMenuDef("")
oBrowseDet:SetColumns(OPM0400025_ColunasBrowse())
oBrowseDet:SetDoubleClick( {|| lRet := .t., &(cReadVar):= Alltrim(SQLEND->LOCALI2) , oF3Opc:End() } )
oBrowseDet:AddButton("OK", {|| lRet := .t., &(cReadVar) := Alltrim(SQLEND->LOCALI2) , oF3Opc:End() },,2,2)
oBrowseDet:DisableDetails()
oBrowseDet:SetAmbiente(.F.)
oBrowseDet:SetWalkthru(.F.)
oBrowseDet:ForceQuitButton(.T.)
oBrowseDet:Activate()

oF3Opc:Activate( , , ,.t., , , ) //ativa a janela

oEnch1:Refresh()

Return lRet

/*/{Protheus.doc} OPM0400025_ColunasBrowse()
    Retorna as Colunas do Browse de Detalhes ( browse em SQL )

    @author Renato Vinicius
    @since  22/11/2021
/*/
Static Function OPM0400025_ColunasBrowse()
Local aColumns := {}

AAdd(aColumns,FWBrwColumn():New())
    aColumns[1]:SetData( &("{|| LOCALI2 }") ) 
    aColumns[1]:SetTitle(STR0019) // Localização
    aColumns[1]:SetSize(70) // 70 %
Return aColumns

/*/{Protheus.doc} OPM0400035_RetEndereco()
    Retorno Consulta F3 do campo Localização ( browse em SQL )

    @author Renato Vinicius
    @since  22/11/2021
/*/
Function OPM0400035_RetEndereco()

Return &(cReadVar)
