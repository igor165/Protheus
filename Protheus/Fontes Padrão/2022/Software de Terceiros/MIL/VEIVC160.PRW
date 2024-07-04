///////////////
// Versao 08 //
///////////////

#INCLUDE "Protheus.ch"
#INCLUDE "VEIVC160.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VEIVC160 ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista notas fiscais de devolucao de venda de veiculos.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Solic ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VEIVC160()

Private dEmisDe     := CriaVar("F1_EMISSAO",.F.)
Private dEmisAte   	:= CriaVar("F1_EMISSAO",.F.)
Private cFornece    := CriaVar("A2_COD",.F.)
Private cLojaFor    := CriaVar("A2_LOJA",.F.)
Private cNomeFor    := CriaVar("A2_NOME",.F.)
Private cCliente    := CriaVar("A1_COD",.F.)
Private cLojaCli    := CriaVar("A1_LOJA",.F.)
Private cNomeCli    := CriaVar("A1_NOME",.F.)
Private cNfFor      := CriaVar("F1_DOC",.F.)
Private cSerieFor  	:= FGX_MILSNF("SF1", 5,"F1_SERIE",.F.)
Private cNfCli      := CriaVar("F2_DOC",.F.)
Private cSerieCli   := FGX_MILSNF("SF2", 5 ,"F2_SERIE",.F.)
Private nolBox1     := 1
Private aTela       := {}
Private aLinha      := {}
Private aColuna     := {}
Private aHeader     := {}
Private cTipoNF     := "V"
Private aItens      := {{CtoD(""),"",CtoD(""),"",""}}
Private altera      := .F.
Private cTitulo     := STR0001 //Consulta Devolucoes X Vendas Veiculos
Private oDlg, oGrp1, oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8, oSay9, oSay10,oEmisDe, oEmisAte
Private oFornece, oLojaFor, oNomeFor, oCliente, oLojaCli, oNomeCli, oNfFor, oSerieFor, oNfCli, oSerieCli
Private olBox1, oBtnFiltra, oBtnSair, oBtnConsE, oBtnConsS, oBtnImpE, oBtnImpS

//aTela := MsAdvSize(.F.)  // Pega as coordenadas maximas da tela
//aTela := { aTela[1]+100, aTela[2]+150, aTela[5]-150, aTela[6]-50 }  // contem X1,Y1 e X2,Y2 descontando as margens para nao colocar nas bordas
//
//AAdd(aLinha,	{20,35,65,80,110,125,180,330})
//AAdd(aLinha,	{20,45,70})
///AAdd(aColuna,	{10,85,165,250,550,605})
///
///aHeader :=	{"Data Dev.", "Nf Entrada"	, "Data Saida"	, "Nf Saida", "Chassi"	}
///AAdd(aItens,{""			, ""				, ""				, ""			, ""			})
dEmissaoD := ctod("   /   /   ")
dEmissaoA := ctod("   /   /   ")
cFornec   := space(6)
cLoja     := space(2)
cNFEntr   := space(9)
cSerie    := space(3)
cCliente  := space(6)
cLojaC    := space(2)
cNFSaida  := space(9)
cSerieC   := space(3)
nOpca     := 1
DEFINE MSDIALOG oDlgCON TITLE STR0001 FROM  01,01 TO 37,97 OF oMainWnd && Consulta Devolucao X Venda de Veiculo

@ 003,003 TO 076,235 LABEL OemtoAnsi("") OF oDlgCON PIXEL
@ 006,006 SAY STR0002 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE //Emissao De
@ 014,006 MSGET oEmissaoD VAR dEmissaoD PICTURE "@D" SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 006,050 SAY STR0003 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE //Emissao Ate
@ 014,050 MSGET oEmissaoA VAR dEmissaoA PICTURE "@D" SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE

@ 028,006 SAY STR0004 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE //Fornecedor
@ 036,006 MSGET oFornec VAR cFornec PICTURE "@!" VALID FS_VALIDFOR() F3 "SA2" SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 028,050 SAY STR0005 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE //Loja
@ 036,050 MSGET oLoja VAR cLoja PICTURE "@!" SIZE 20,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 028,090 SAY STR0006 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE	//NF Entrada
@ 036,090 MSGET oNFEntr VAR cNFEntr PICTURE "@!" F3 "SF1DEV" SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 028,140 SAY STR0007 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE //Serie
@ 036,140 MSGET oSerie VAR cSerie PICTURE "@!" SIZE 20,08 OF oDlgCON PIXEL COLOR CLR_BLUE

@ 049,006 SAY STR0008 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE 	//Cliente
@ 056,006 MSGET oCliente VAR cCliente PICTURE "@!" F3 "SA1" SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 049,050 SAY STR0005 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE 	//Loja
@ 056,050 MSGET oLojaC VAR cLojaC PICTURE "@!" SIZE 20,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 049,090 SAY STR0010 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE	//NF Saida
@ 056,090 MSGET oNFSaida VAR cNFSaida PICTURE "@!" F3 "SF2" SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 049,140 SAY STR0007 SIZE 40,08 OF oDlgCON PIXEL COLOR CLR_BLUE	//Serie
@ 056,140 MSGET oSerieC VAR cSerieC PICTURE "@!" SIZE 20,08 OF oDlgCON PIXEL COLOR CLR_BLUE
@ 035,175 BUTTON oPesquisar  PROMPT OemToAnsi(STR0012) OF oDlgCON SIZE 55,10 PIXEL  ACTION (FS_FILTRA()) //when !Empty(Alltrim())  // <<< Pesquisar >>>


@ 010,250 BUTTON oPesquisar  PROMPT OemToAnsi(STR0013) OF oDlgCON SIZE 110,10 PIXEL  ACTION (FS_NFDEVOL(aItens[oLbx1:nAt,2])) //when !Empty(Alltrim())	//<<< Consulta NF Devolucao >>>
@ 021,250 BUTTON oPesquisar  PROMPT OemToAnsi(STR0014) OF oDlgCON SIZE 110,10 PIXEL  ACTION (FS_NFSAIDA(aItens[oLbx1:nAt,4])) //when !Empty(Alltrim())	//<<<   Consulta NF Saida   >>>
@ 032,250 BUTTON oPesquisar  PROMPT OemToAnsi(STR0015) OF oDlgCON SIZE 110,10 PIXEL  ACTION (FS_IMPNFS()) //when !Empty(Alltrim()) 		//<<< Imprime somente NF Selecionada >>>
@ 043,250 BUTTON oPesquisar  PROMPT OemToAnsi(STR0016) OF oDlgCON SIZE 110,10 PIXEL  ACTION (FS_IMPNF()) //when !Empty(Alltrim())	//<<<     Imprime todas NF   >>>

@ 077,003 LISTBOX oLbx1 FIELDS HEADER  OemToAnsi(STR0017),OemToAnsi(STR0006),OemToAnsi(STR0009),OemToAnsi(STR0010),OemToAnsi(STR0011) COLSIZES 60,60,60,60,70 SIZE 375,178 OF oDlgCON PIXEL // ON DBLCLICK FS_CONSULTA()		//Data Dev ### NF Entrada ### Data Saida ### NF Saida ### Chassi ###
oLbx1:SetArray(aItens)
oLbx1:bLine := { || {  transform(aItens[oLbx1:nAt,1],"@D"),;
aItens[oLbx1:nAt,2],;
transform(aItens[oLbx1:nAt,3],"@D"),;
aItens[oLbx1:nAt,4],;
aItens[oLbx1:nAt,5]}}

DEFINE SBUTTON FROM 258,340 TYPE 2 ACTION ( nOpca := 0, oDlgCON:End() ) ENABLE OF oDlgCON
ACTIVATE MSDIALOG oDlgCON CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_FILTRA ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra notas fiscais										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRA()

Local cQuery  	:= ""
Local cQSF1SF2	:= "SQLSF1SF2" // SQLSB1
Local nPos
aItens := {}
aItens			:= {{CtoD(""),"",CtoD(""),"",""}}
If Vazio(dEmissaoD) .and. Vazio(dEmissaoA) .and. Vazio(cFornec) .and. Vazio(cLoja)	.and. Vazio(cNFEntr);
	.and. Vazio(cCliente) .and. Vazio(cLojaC) .and. Vazio(cSerieFor) .and. Vazio(cNFSaida)
	MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
	oEmissaod:SetFocus()
	oLbx1:SetArray(aItens)
	oLbx1:bLine := { || {  transform(aItens[oLbx1:nAt,1],"@D"),;
	aItens[oLbx1:nAt,2],;
	transform(aItens[oLbx1:nAt,3],"@D"),;
	aItens[oLbx1:nAt,4],;
	aItens[oLbx1:nAt,5]}}
	
	Return()
EndIf

//@ 035,175 BUTTON oPesquisar  PROMPT OemToAnsi(STR0012) OF oDlg SIZE 55,10 PIXEL  ACTION (FS_FILTRA()) //when !Empty(Alltrim())

cQuery := "SELECT SF1.F1_EMISSAO, SF1.F1_DOC, SF2.F2_EMISSAO, SF2.F2_DOC, VV1.VV1_CHASSI, SD1.D1_TIPO "
cQuery += "FROM "+RetSqlName("SF1")+ " SF1 "
cQuery += "JOIN "+RetSqlName("SD1")+ " SD1 ON SF1.F1_DOC=SD1.D1_DOC AND SD1.D1_FILIAL='"+xFilial("SD1")+"' "
cQuery += "JOIN "+RetSqlName("SF2")+ " SF2 ON SD1.D1_NFORI=SF2.F2_DOC AND SF2.F2_FILIAL='"+xFilial("SF2")+"' "
cQuery += "JOIN "+RetSqlName("SB1")+ " SB1 ON SD1.D1_COD=SB1.B1_COD AND SB1.B1_FILIAL='"+xFilial("SB1")+"' "
cQuery += "JOIN "+RetSqlName("VV1")+ " VV1 ON SB1.B1_CODITE=VV1.VV1_CHAINT AND VV1.VV1_FILIAL='"+xFilial("VV1")+"' "
cQuery += "JOIN "+RetSqlName("VV2")+ " VV2 ON VV1.VV1_MODVEI=VV2.VV2_MODVEI AND VV1.VV1_SEGMOD=VV2.VV2_SEGMOD AND VV2.VV2_FILIAL='"+xFilial("VV2")+"' "
cQuery += "WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND SD1.D1_TIPO='D' AND "
If !Empty(dEmissaoD) .or. !Empty(dEmissaoA)
	cQuery += "SF1.F1_EMISSAO>='"+dtos(dEmissaoD)+"' AND SF1.F1_EMISSAO<='"+DToS(dEmissaoA)+"' AND "
EndIf
If !Empty(cFornec+cLoja)
	cQuery += "SF1.F1_FORNECE='" + cFornec + "' AND SF1.F1_LOJA='"+cLoja+"' AND "
EndIf
If !Empty(cCliente+cLojaC)
	cQuery += "SF2.F2_CLIENTE='"+cCliente+"' AND SF2.F2_LOJA='"+cLojaC+"' AND "
EndIf
If !Empty(cNFEntr+cSerie)
	cQuery += "SD1.D1_DOC='"+cNFEntr+"' AND SF1.F1_SERIE LIKE '"+cSerie+"%' AND "
EndIf
If !Empty(cNFSaida+cSerieC)
	cQuery += "SF2.F2_DOC='"+cNFSaida+"' AND SF2.F2_SERIE LIKE '"+cSerieC+"%' AND "
EndIf
cQuery += "SF1.D_E_L_E_T_  = ' ' AND SD1.D_E_L_E_T_  = ' ' AND SF2.D_E_L_E_T_  = ' ' ORDER BY SF1.F1_DTDIGIT"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSF1SF2, .F., .T. )

If (cQSF1SF2)->(Eof())
	MsgInfo(STR0020,STR0018)//Nao foram encontrados registros para esta consulta! ### Atencao
	oEmissaod:SetFocus()
	(cQSF1SF2)->(DbCloseArea())
	oLbx1:SetArray(aItens)
	oLbx1:bLine := { || {  transform(aItens[oLbx1:nAt,1],"@D"),;
	aItens[oLbx1:nAt,2],;
	transform(aItens[oLbx1:nAt,3],"@D"),;
	aItens[oLbx1:nAt,4],;
	aItens[oLbx1:nAt,5]}}
	oLbx1:Refresh()
	Return ()
EndIf

aItens := {}
While !(cQSF1SF2)->(Eof())
	
	nPos := aScan(aItens,{|x| x[2] == (cQSF1SF2)->(F1_DOC)})
	if nPos == 0
		AAdd(aItens,{(cQSF1SF2)->(SToD(F1_EMISSAO)), (cQSF1SF2)->(F1_DOC), (cQSF1SF2)->(SToD(F2_EMISSAO)), (cQSF1SF2)->(F2_DOC), (cQSF1SF2)->(VV1_CHASSI)})
	Endif
	(cQSF1SF2)->(DbSkip())
EndDo
(cQSF1SF2)->(DbCloseArea())

oLbx1:SetArray(aItens)
oLbx1:bLine := { || {  transform(aItens[oLbx1:nAt,1],"@D"),;
aItens[oLbx1:nAt,2],;
transform(aItens[oLbx1:nAt,3],"@D"),;
aItens[oLbx1:nAt,4],;
aItens[oLbx1:nAt,5]}}
oLbx1:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_VALIDFOR³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao no fornecedor   								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALIDFOR()

if !Empty(cFornece)
	DbSelectArea("SA2")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA2")+cFornece)
		MsgInfo(STR0021,STR0018) //Fornecedor nao encontrado! ### Atencao
		Return (.f.)
	Else
		cLojaFor		:= SA2->SA2_NOME
	EndIf
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_NFDEVOL ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nota fiscal de devolucao   								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NFDEVOL(cT)

/*
If Vazio(dEmissaoD) .and. Vazio(dEmissaoA) .and. Vazio(cFornec) .and. Vazio(cLoja)	.and. Vazio(cNFEntr);
.and. Vazio(cCliente) .and. Vazio(cLojaC) .and. Vazio(cSerieFor) .and. Vazio(cNFSaida)
MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
oEmissaod:SetFocus()
Return()
EndIf
*/
If Empty(aItens[1,1])
	MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
	oEmissaod:SetFocus()
	Return()
EndIf
DbSelectArea("SF1")
DbSetOrder(1)
DbSeek( xFilial("SF1") + cT )
ImpNotaE(0,2,2) // Consultar NF

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_NFSAIDA ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Nota fiscal de Saida										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_NFSAIDA(cT)

/*
If Vazio(dEmissaoD) .and. Vazio(dEmissaoA) .and. Vazio(cFornec) .and. Vazio(cLoja)	.and. Vazio(cNFEntr);
.and. Vazio(cCliente) .and. Vazio(cLojaC) .and. Vazio(cSerieFor) .and. Vazio(cNFSaida)
MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
oEmissaod:SetFocus()
Return()
EndIf
*/
If Empty(aItens[1,1])
	MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
	oEmissaod:SetFocus()
	Return()
EndIf
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek( xFilial("SF2") + cT )
ImpNotaS(0,2,2) // Consultar NF

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpNotaE   ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime nota fiscal de entrada							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpNotaE(cAlias,nReg,nOpc)

Local bCampo := { |nCPO| Field(nCPO) }
Local aPages := {}, aVar:={}
Local nPar := 1
Local i := 0 , _ni := 0
Private aNewBot := {}

aadd(aNewBot,{"RELATORIO" ,"Mc090Cons(1,aPedidos)",STR0022}) 	//Consulta Pedido
if nModulo == 11
	aadd(aNewBot,{"NOVACELULA","FS_MEMO()"       ,STR0023})		//Consulta Observacao
Endif
aadd(aNewBot,{"PRECO"     ,"FS_AVALIACAO()"  ,STR0024})		//Avaliacao do Resultado

For i:=1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next

Private cFcBot
Private cCodVen
Private oLbEntIte
Private aTELA[0][0], aGETS[0], aHeader[0]
Private lConsulta   := .f.
Private cNumPed     := ""
Private aPedidos    := {}
Private nTotDes     := 0
Private nTotOrc     := 0
Private nTotPec     := 0
Private nTotSrv     := 0
Private nC          := 1
Private nNF         := 1
Private lPri        := .t.
Private aCabPV      := {}
Private aItePV      := {}
Private lAbortPrint := .f.
Private cNumIde	  := ""

aRotina := { { STR0025 ,"OFIOR370" , 0, 1},;      //Pesquisar
{ STR0026 ,"OFIOR370" , 0, 2}};      //Imprimir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo        := STR0027 //Consulta Nota Fiscal
cAliasEnchoice := "SF1"
cLinOk         := "AllwaysTrue()"
cTudoOk        := "AllwaysTrue()"
cFieldOk       := "FG_MEMVAR()"

if nOpc == 2
	lConsulta := .t.
Endif

nOpc :=2
nOpcE:=2
nOpcG:=2

nOpca:=0

lRefresh := .t.
Inclui   := .f.
lVirtual := .f.
nLinhas  := 99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no Tipos de Condicao de Pagamento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE4")
DbSeek(xFilial("SE4")+SF1->F1_COND)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no cliente/fornecedor                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SF1->F1_TIPO $ "BD"
	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
Else
	DbSelectArea("SA2")
	DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//   RegToMemory("SF2",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SF1")
While !Eof().and.(x3_arquivo=="SF1")
	If X3USO(x3_usado).and.x3_nivel>0  // .and. ( AllTrim(x3_campo) $ [F2_DOC#F2_SERIE#F2_CLIENTE#F2_LOJA#F2_EMISSAO#F2_VALBRUT])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+Alltrim(x3_campo)) := &("SF1->"+(x3_campo))
	dbSkip()
End

DbSelectArea("SF1")
For i:=1 to fCount()
	&("M->"+FieldName(i)) := &("SF1->"+FieldName(i))
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoNF:=0
nSB1 := 0
dbSelectArea("SX3")
dbSeek("SD1")
aHeaderNF:={}
While !Eof().And.(x3_arquivo=="SD1")
	If X3USO(x3_usado) // .and. ( AllTrim(SX3->X3_CAMPO) $ "D2_ITEM#D2_COD#D2_QUANT#D2_PRCVEN#D2_TOTAL#D2_TES#D2_PEDIDO#" )
		nUsadoNF++
		Aadd(aHeaderNF,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
		//		 If alltrim(x3_campo) == "D1_CODITE"
		//	        nUsadoNF++
		//	        nSB1 := nUsadoNF
		//		    dbSelectArea("SX3")
		//		    dbSetOrder(2)
		//		    dbSeek("B1_DESC")
		// 	        Aadd(aHeaderNF,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		//       	    x3_tamanho, x3_decimal,x3_valid,;
		//         	x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		//	        &("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
		//		    dbSelectArea("SX3")
		//		    dbSetOrder(2)
		//		    dbSeek("D1_CODITE")
		//		    dbSelectArea("SX3")
		//		    dbSetOrder(1)
		//		 EndIf
	Endif
	dbSkip()
EndDo

aColsNF := {}
cGrpCod := ""
DbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE)
While SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE == SF1->F1_SERIE .and. !eof()
	AADD(aColsNF,Array(nUsadoNF+1))
	For _ni:=1 to nUsadoNF
		If _ni # nSB1
			If _ni < nSB1
				If _ni == ( nSB1 - 2 ) // Grupo
					cGrpCod := If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
				EndIf
				If _ni == ( nSB1 - 1 ) // Codigo Item
					cGrpCod += If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
				EndIf
			EndIf
			aColsNF[Len(aColsNF),_ni]:=If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
		Else
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + cGrpCod )
			aColsNF[Len(aColsNF),_ni]:= SB1->B1_DESC
			cGrpCod := ""
			DbSelectArea("SD1")
		EndIf
	Next
	if aScan(aPedidos,SD1->D1_PEDIDO) = 0
		aAdd(aPedidos,SD1->D1_PEDIDO)
	Endif
	aColsNF[Len(aColsNF),nUsadoNF+1]:=.F.
	cNumPed := SD1->D1_PEDIDO
	DbSelectArea("SD1")
	DbSkip()
EndDo
cNumPed := SF1->F1_DUPL // Devido a mudanca do numero do titulo se tornou o número da nota

if Len(aColsNF) == 0
	aColsNF:={Array(nUsadoNF+1)}
	aColsNF[1,nUsadoNF+1]:=.F.
	For _ni:=1 to nUsadoNF
		aColsNF[1,_ni]:=CriaVar(aHeaderNF[_ni,2])
	Next
Endif

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

nTotPec := SF1->F1_VALBRUT+SF1->F1_DESCONT
nTotDes := SF1->F1_DESCONT
nTotOrc := SF1->F1_VALBRUT

aEntrada := {}
aDescEnt := {}
aIteParc := {}

DbSelectarea("VS1")
DbSetOrder(3)
DbSeek(xFilial("VS1")+SF1->F1_DOC+SF1->F1_SERIE)
if cTipoNF == "T"
	if !VS1->( Found() )
		DbSelectarea("VV0")
		DbSetOrder(4)
		if !DbSeek(xFilial("VV0")+SF1->F1_DOC+SF1->F1_SERIE)
			DbSelectarea("VOO")
			DbSetOrder(4)
			if DbSeek(xFilial("VOO")+SF1->F1_DOC+SF1->F1_SERIE)
				DbSelectarea("SE1")
				DbSetOrder(1)
				DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+cNumPed)
				cNumIde := cNumPed+space(TamSx3("VS9_NUMIDE")[1]-Len(AllTrim(cNumPed)))
				cTipoNF := "O"
			Endif
		Else
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+VV0->VV0_NUMTRA)
			cNumIde := VV0->VV0_NUMTRA
			cTipoNF := "V"
		Endif
	Else
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+cNumPed)
		cNumIde := "OR"+VS1->VS1_NUMORC
		cTipoNF := "B"
	Endif
Elseif cTipoNF == "B"
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+cNumPed)
	cNumIde := "OR"+VS1->VS1_NUMORC
Elseif cTipoNF == "V"
	DbSelectArea("VV0")
	DbSetOrder(4)
	DbSeek(xFilial("VV0")+SF1->F1_DOC+SF1->F1_SERIE)
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+VV0->VV0_NUMTRA)
	cNumIde := VV0->VV0_NUMTRA
Else
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+cNumPed)
	cNumIde := cNumPed+space(TamSx3("VS9_NUMIDE")[1]-Len(AllTrim(cNumPed)))
Endif

&& Parcelas
DbSelectArea("SE1")
DbSetOrder(1)
Do While !EOF() .and. (E1_PREFIXO+Alltrim(E1_NUM) == SF1->F1_PREFIXO+cNumPed)
	if 	(cTipoNF =="B" .and. E1_PREFORI != GetNewPar("MV_PREFBAL","BAL")) .or.;
		(cTipoNF =="O" .and. E1_PREFORI != GetNewPar("MV_PREFOFI","OFI")) .or.;
		(cTipoNF =="V" .and. E1_PREFORI != GetNewPar("MV_PREFVEI","VEI"))
		DBSkip()
		loop
	endif
	if alltrim(SE1->E1_TIPO) $ "DP/CD"
		aadd(aIteParc,{E1_VENCREA,E1_VALOR})
	Endif
	DbSkip()
Enddo

if Len(aIteParc) == 0
	aadd(aIteParc,{cTod(""),0})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols e aHeader da Condicao de Pagamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
DbSelectArea("SX3")
DbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	//      If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
	If cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

aColsC := {}
DbSelectarea("VS9")
DbSetOrder(1)
if DbSeek(xFilial("VS9")+cNumIde+cTipoNF)
	nPar := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. alltrim(VS9->VS9_NUMIDE) == alltrim(cNumIde) .and. VS9->VS9_TIPOPE == cTipoNF
		lOk := .f.
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+SF1->F1_PREFIXO+cNumPed+Str(nPar,1)+VSE->VSE_TIPPAG)
		while E1_FILIAL+E1_PREFIXO+alltrim(E1_NUM)+E1_PARCELA+E1_TIPO == xFilial("SE1")+SF1->F1_PREFIXO+cNumPed+Str(nPar,1)+VSE->VSE_TIPPAG
			if E1_PREFORI == GetNewPar("MV_PREFBAL","BAL")
				if Empty(SE1->E1_BAIXA)
					lOk := .f.
				Else
					lOk := .t.
				Endif
				exit
			endif
			DBSkip()
		enddo
		
		DbSelectArea("VS9")
		if VS9->VS9_TIPPAG == "DP"
			DbSkip()
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aColsC,Array(nUsadoC+1))
		aColsC[Len(aColsC),Len(aColsC[Len(aColsC)])] := lOk
		For _ni:=1 to nUsadoC
			aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
		Next
		nPar++
		DbSkip()
	Enddo
Endif

if Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Else
	DbSelectArea("VSE")
	if DbSeek(xFilial("VSE")+cNumIde+cTipoNF+aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aColsC[1,FG_POSVAR("VS9_SEQUEN","aHeaderC")])
		Do While !Eof() .and. alltrim(VSE->VSE_NUMIDE) == Alltrim(cNumIde) .and. VSE->VSE_TIPOPE == cTipoNF .and. VSE->VSE_TIPPAG == aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")] .and. VSE->VSE_SEQUEN == aColsC[1,FG_POSVAR("VS9_SEQUEN","aHeaderC")]
			aadd(aDescEnt,{VSE->VSE_DESCCP,VSE->VSE_VALDIG})
			DbSkip()
		Enddo
	Endif
Endif

if Len(aDescEnt) == 0
	aadd(aDescEnt,{"",""})
Endif

Private aTitles  := {OemToAnsi(STR0028),OemToAnsi(STR0029)}    //vwenda / pagamento
Private oFolder

DEFINE MSDIALOG oDlg FROM 000,000 TO 034,080 TITLE cTitulo OF oMainWnd

@ 013,001 FOLDER oFolder SIZE 316,195 OF oDlg PROMPTS aTitles[1],aTitles[2] PIXEL

// Pagina 1

@ 216,002 Say OemToAnsi(STR0030) SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE		//Cliente:
@ 216,025 Say IIf(SF1->F1_TIPO$"BD",SA1->A1_NOME,SA2->A2_NOME) SIZE 55,08 OF oDlg PIXEL COLOR CLR_BLUE

@ 216,120 Say OemToAnsi(STR0031) SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE		//Condicao:
@ 216,145 Say SE4->E4_DESCRI SIZE 55,08 OF oDlg PIXEL COLOR CLR_BLUE

Zero()
oGetMGet:= MsMGet():New("SF1",0,nOpcE,,,,aCpoEnchoice,{001,002,082,312},,2,,,,oFolder:aDialogs[1],,.T.,.F.)

@ 226,002 Say OemToAnsi(STR0032)    SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE	//Itens
@ 226,042 msget oTotPec VAR nTotPec Picture "999,999.99" SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 226,121 Say OemToAnsi(STR0033) SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE		//Desconto
@ 226,152 msget oTotDes VAR nTotDes Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 226,235 Say OemToAnsi(STR0034)    SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE	//Total
@ 226,263 msget oTotOrc VAR nTotOrc Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)
oGetPecas                       := MsGetDados():New(084,002,180,312,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[1])
oGetPecas:oBrowse:default()
oGetPecas:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderNF),aCols := aClone(aColsNF),n := nNF, oGetPecas:oBrowse:SetFocus()}
oGetPecas:oBrowse:bLostFocus    := {|| aHeaderNF:= aClone(aHeader), aColsNF:= aClone(aCols), nNF:= n }

// Pagina 2

aHeader  := aClone(aHeaderC)
aCols    := aClone(aColsC)
oEntrada                       := MsGetDados():New(001,001,089,312,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[2])
oEntrada:oBrowse:default()
oEntrada:oBrowse:bChange       := {|| FS_MUDATP(n,cTipoNF) }
oEntrada:oBrowse:bEditCol      := {|| .t. }
oEntrada:oBrowse:bDelete       := {|| .t. }
oEntrada:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderC),aCols := aClone(aColsC),n := nC, oEntrada:oBrowse:SetFocus()}
oEntrada:oBrowse:bLostFocus    := {|| aHeaderC:= aClone(aHeader), aColsC:= aClone(aCols), nC:= n }

@ 092,001 LISTBOX oLbEntIte FIELDS HEADER OemToAnsi(STR0035),;		//Descricao
OemToAnsi(STR0036);       //Valor
COLSIZES 60,100 ;
SIZE 200,088 OF oFolder:aDialogs[2] PIXEL

oLbEntIte:SetArray(aDescEnt)
oLbEntIte:bLine := { || { aDescEnt[oLbEntIte:nAt,1] ,;
aDescEnt[oLbEntIte:nAt,2] }}

@ 092,203 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0037),OemToAnsi(STR0038);  //Data # Valor
COLSIZES 40,50;
SIZE 110,088 OF oFolder:aDialogs[2] PIXEL

oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)

ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()},,aNewBot) )

if nOpca == 1 .and. !lConsulta
	Processa( {|| FS_IMPNOTPS() } )
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpNotaS   ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime nota fiscal de saida								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpNotaS(cAlias,nReg,nOpc)

Local bCampo := { |nCPO| Field(nCPO) }
Local aPages := {}, aVar:={}
Local nPar := 1
Local i := 0 , _ni := 0
Private aNewBot := {}

aadd(aNewBot,{"RELATORIO" ,"Mc090Cons(1,aPedidos)",STR0022}) 	//Consulta Pedido
if nModulo == 11
	aadd(aNewBot,{"NOVACELULA","FS_MEMO()"       ,STR0023})		//Consulta Observacao
Endif
aadd(aNewBot,{"PRECO"     ,"FS_AVALIACAO()"  ,STR0024})		//Avaliacao do Resultado

For i:=1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next

Private cFcBot
Private cCodVen
Private oLbEntIte
Private aTELA[0][0], aGETS[0], aHeader[0]
Private lConsulta   := .f.
Private cNumPed     := ""
Private aPedidos    := {}
Private nTotDes     := 0
Private nTotOrc     := 0
Private nTotPec     := 0
Private nTotSrv     := 0
Private nC          := 1
Private nNF         := 1
Private lPri        := .t.
Private aCabPV      := {}
Private aItePV      := {}
Private lAbortPrint := .f.
Private cNumIde	  := ""

aRotina := { { STR0025 ,"OFIOR370" , 0, 1},;      //Pesquisar
{ STR0026 ,"OFIOR370" , 0, 2}};      //Imprimir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo        := STR0027 //Consulta Nota Fiscal
cAliasEnchoice := "SF2"
cLinOk         := "AllwaysTrue()"
cTudoOk        := "AllwaysTrue()"
cFieldOk       := "FG_MEMVAR()"

if nOpc == 2
	lConsulta := .t.
Endif

nOpc :=2
nOpcE:=2
nOpcG:=2

nOpca:=0

lRefresh := .t.
Inclui   := .f.
lVirtual := .f.
nLinhas  := 99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no Tipos de Condicao de Pagamento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE4")
DbSeek(xFilial("SE4")+SF2->F2_COND)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no cliente                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SF2->F2_TIPO $ "BD"
	DbSelectArea("SA2")
	DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
Else
	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SF2",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SF2")
While !Eof().and.(x3_arquivo=="SF2")
	If X3USO(x3_usado).and.x3_nivel>0  // .and. ( AllTrim(x3_campo) $ [F2_DOC#F2_SERIE#F2_CLIENTE#F2_LOJA#F2_EMISSAO#F2_VALBRUT])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+Alltrim(x3_campo)) := &(x3_campo)
	dbSkip()
End

DbSelectArea("SF2")
For i:=1 to fCount()
	&("M->"+FieldName(i)) := &("SF2->"+FieldName(i))
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoNF:=0
nSB1 := 0
dbSelectArea("SX3")
dbSeek("SD2")
aHeaderNF:={}
While !Eof().And.(x3_arquivo=="SD2")
	If X3USO(x3_usado) // .and. ( AllTrim(SX3->X3_CAMPO) $ "D2_ITEM#D2_COD#D2_QUANT#D2_PRCVEN#D2_TOTAL#D2_TES#D2_PEDIDO#" )
		nUsadoNF++
		Aadd(aHeaderNF,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
		If alltrim(x3_campo) == "D2_CODITE"
			nUsadoNF++
			nSB1 := nUsadoNF
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek("B1_DESC")
			Aadd(aHeaderNF,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek("D2_CODITE")
			dbSelectArea("SX3")
			dbSetOrder(1)
		EndIf
	Endif
	dbSkip()
EndDo

aColsNF := {}
cGrpCod := ""
DbSelectArea("SD2")
dbSetOrder(3)
Fg_Seek("SD2","SF2->F2_DOC+SF2->F2_SERIE",3,.F.)
While SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE .and. !eof()
	AADD(aColsNF,Array(nUsadoNF+1))
	For _ni:=1 to nUsadoNF
		If _ni # nSB1
			If _ni < nSB1
				If _ni == ( nSB1 - 2 ) // Grupo
					cGrpCod := If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
				EndIf
				If _ni == ( nSB1 - 1 ) // Codigo Item
					cGrpCod += If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
				EndIf
			EndIf
			aColsNF[Len(aColsNF),_ni]:=If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
		Else
			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + cGrpCod )
			aColsNF[Len(aColsNF),_ni]:= SB1->B1_DESC
			cGrpCod := ""
			DbSelectArea("SD2")
		EndIf
	Next
	if aScan(aPedidos,SD2->D2_PEDIDO) = 0
		aAdd(aPedidos,SD2->D2_PEDIDO)
	Endif
	aColsNF[Len(aColsNF),nUsadoNF+1]:=.F.
	cNumPed := SD2->D2_PEDIDO
	DbSelectArea("SD2")
	DbSkip()
EndDo
cNumPed := SF2->F2_DUPL // Devido a mudanca do numero do titulo se tornou o número da nota

if Len(aColsNF) == 0
	aColsNF:={Array(nUsadoNF+1)}
	aColsNF[1,nUsadoNF+1]:=.F.
	For _ni:=1 to nUsadoNF
		aColsNF[1,_ni]:=CriaVar(aHeaderNF[_ni,2])
	Next
Endif

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

nTotPec := SF2->F2_VALBRUT+SF2->F2_DESCONT
nTotDes := SF2->F2_DESCONT
nTotOrc := SF2->F2_VALBRUT

aEntrada := {}
aDescEnt := {}
aIteParc := {}

DbSelectarea("VS1")
DbSetOrder(3)
DbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
if cTipoNF == "T"
	if !VS1->( Found() )
		DbSelectarea("VV0")
		DbSetOrder(4)
		if !DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
			DbSelectarea("VOO")
			DbSetOrder(4)
			if DbSeek(xFilial("VOO")+SF2->F2_DOC+SF2->F2_SERIE)
				DbSelectarea("SE1")
				DbSetOrder(1)
				DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
				cNumIde := cNumPed+space(TamSx3("VS9_NUMIDE")[1]-Len(AllTrim(cNumPed)))
				cTipoNF := "O"
			Endif
		Else
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+VV0->VV0_NUMTRA)
			cNumIde := VV0->VV0_NUMTRA
			cTipoNF := "V"
		Endif
	Else
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
		cNumIde := "OR"+VS1->VS1_NUMORC
		cTipoNF := "B"
	Endif
Elseif cTipoNF == "B"
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
	cNumIde := "OR"+VS1->VS1_NUMORC
Elseif cTipoNF == "V"
	DbSelectArea("VV0")
	DbSetOrder(4)
	DbSeek(xFilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE)
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+VV0->VV0_NUMTRA)
	cNumIde := VV0->VV0_NUMTRA
Else
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed)
	cNumIde := cNumPed+space(TamSx3("VS9_NUMIDE")[1]-Len(AllTrim(cNumPed)))
Endif

&& Parcelas
DbSelectArea("SE1")
DbSetOrder(1)
Do While !EOF() .and. (E1_PREFIXO+Alltrim(E1_NUM) == SF2->F2_PREFIXO+cNumPed)
	if 	(cTipoNF =="B" .and. E1_PREFORI != GetNewPar("MV_PREFBAL","BAL")) .or.;
		(cTipoNF =="O" .and. E1_PREFORI != GetNewPar("MV_PREFOFI","OFI")) .or.;
		(cTipoNF =="V" .and. E1_PREFORI != GetNewPar("MV_PREFVEI","VEI"))
		DBSkip()
		loop
	endif
	if alltrim(SE1->E1_TIPO) $ "DP/CD"
		aadd(aIteParc,{E1_VENCREA,E1_VALOR})
	Endif
	DbSkip()
Enddo

if Len(aIteParc) == 0
	aadd(aIteParc,{cTod(""),0})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols e aHeader da Condicao de Pagamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
DbSelectArea("SX3")
DbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	//      If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
	If cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

aColsC := {}
DbSelectarea("VS9")
DbSetOrder(1)
if DbSeek(xFilial("VS9")+cNumIde+cTipoNF)
	nPar := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. alltrim(VS9->VS9_NUMIDE) == alltrim(cNumIde) .and. VS9->VS9_TIPOPE == cTipoNF
		lOk := .f.
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+cNumPed+Str(nPar,1)+VSE->VSE_TIPPAG)
		while E1_FILIAL+E1_PREFIXO+alltrim(E1_NUM)+E1_PARCELA+E1_TIPO == xFilial("SE1")+SF2->F2_PREFIXO+cNumPed+Str(nPar,1)+VSE->VSE_TIPPAG
			if E1_PREFORI == GetNewPar("MV_PREFBAL","BAL")
				if Empty(SE1->E1_BAIXA)
					lOk := .f.
				Else
					lOk := .t.
				Endif
				exit
			endif
			DBSkip()
		enddo
		
		DbSelectArea("VS9")
		if VS9->VS9_TIPPAG == "DP"
			DbSkip()
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aColsC,Array(nUsadoC+1))
		aColsC[Len(aColsC),Len(aColsC[Len(aColsC)])] := lOk
		For _ni:=1 to nUsadoC
			aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
		Next
		nPar++
		DbSkip()
	Enddo
Endif

if Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Else
	DbSelectArea("VSE")
	if DbSeek(xFilial("VSE")+cNumIde+cTipoNF+aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aColsC[1,FG_POSVAR("VS9_SEQUEN","aHeaderC")])
		Do While !Eof() .and. alltrim(VSE->VSE_NUMIDE) == Alltrim(cNumIde) .and. VSE->VSE_TIPOPE == cTipoNF .and. VSE->VSE_TIPPAG == aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")] .and. VSE->VSE_SEQUEN == aColsC[1,FG_POSVAR("VS9_SEQUEN","aHeaderC")]
			aadd(aDescEnt,{VSE->VSE_DESCCP,VSE->VSE_VALDIG})
			DbSkip()
		Enddo
	Endif
Endif

if Len(aDescEnt) == 0
	aadd(aDescEnt,{"",""})
Endif

Private aTitles  := {OemToAnsi(STR0028),OemToAnsi(STR0029)} // venda ###  pagamento
Private oFolder

DEFINE MSDIALOG oDlg FROM 000,000 TO 034,080 TITLE cTitulo OF oMainWnd

@ 013,001 FOLDER oFolder SIZE 316,195 OF oDlg PROMPTS aTitles[1],aTitles[2] PIXEL

// Pagina 1

@ 216,002 Say OemToAnsi(STR0030) SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE		//Cliente:
@ 216,025 Say IIf(SF2->F2_TIPO$"BD",SA2->A2_NOME,SA1->A1_NOME) SIZE 55,08 OF oDlg PIXEL COLOR CLR_BLUE

@ 216,120 Say OemToAnsi(STR0031) SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE		//Condicao:
@ 216,145 Say SE4->E4_DESCRI SIZE 55,08 OF oDlg PIXEL COLOR CLR_BLUE

Zero()
oGetMGet:= MsMGet():New("SF2",0,nOpcE,,,,aCpoEnchoice,{001,002,082,312},,2,,,,oFolder:aDialogs[1],,.T.,.F.)

@ 226,002 Say OemToAnsi(STR0032)    SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE	//Itens
@ 226,042 msget oTotPec VAR nTotPec Picture "999,999.99" SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 226,121 Say OemToAnsi(STR0033) SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE		//Desconto
@ 226,152 msget oTotDes VAR nTotDes Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 226,235 Say OemToAnsi(STR0034)    SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE	//Total
@ 226,263 msget oTotOrc VAR nTotOrc Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)
oGetPecas                       := MsGetDados():New(084,002,180,312,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[1])
oGetPecas:oBrowse:default()
oGetPecas:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderNF),aCols := aClone(aColsNF),n := nNF, oGetPecas:oBrowse:SetFocus()}
oGetPecas:oBrowse:bLostFocus    := {|| aHeaderNF:= aClone(aHeader), aColsNF:= aClone(aCols), nNF:= n }

// Pagina 2

aHeader  := aClone(aHeaderC)
aCols    := aClone(aColsC)
oEntrada                       := MsGetDados():New(001,001,089,312,nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oFolder:aDialogs[2])
oEntrada:oBrowse:default()
oEntrada:oBrowse:bChange       := {|| FS_MUDATP(n,cTipoNF) }
oEntrada:oBrowse:bEditCol      := {|| .t. }
oEntrada:oBrowse:bDelete       := {|| .t. }
oEntrada:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderC),aCols := aClone(aColsC),n := nC, oEntrada:oBrowse:SetFocus()}
oEntrada:oBrowse:bLostFocus    := {|| aHeaderC:= aClone(aHeader), aColsC:= aClone(aCols), nC:= n }

@ 092,001 LISTBOX oLbEntIte FIELDS HEADER OemToAnsi(STR0035),;		//Descricao
OemToAnsi(STR0036);       //Valor
COLSIZES 60,100 ;
SIZE 200,088 OF oFolder:aDialogs[2] PIXEL

oLbEntIte:SetArray(aDescEnt)
oLbEntIte:bLine := { || { aDescEnt[oLbEntIte:nAt,1] ,;
aDescEnt[oLbEntIte:nAt,2] }}

@ 092,203 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0037),OemToAnsi(STR0038);  //Data # Valor
COLSIZES 40,50;
SIZE 110,088 OF oFolder:aDialogs[2] PIXEL

oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)

ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()},,aNewBot) )

if nOpca == 1 .and. !lConsulta
	Processa( {|| FS_IMPNOTPS() } )
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_IMPNFS  ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime nota fiscal de saida								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPNFS()

/*
If Vazio(dEmissaoD) .and. Vazio(dEmissaoA) .and. Vazio(cFornec) .and. Vazio(cLoja)	.and. Vazio(cNFEntr);
.and. Vazio(cCliente) .and. Vazio(cLojaC) .and. Vazio(cSerieFor) .and. Vazio(cNFSaida)
MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
oEmissaod:SetFocus()
Return()
EndIf
*/
If Empty(aItens[1,1])
	MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
	oEmissaod:SetFocus()
	Return()
EndIf
Private cDesc1 := cDesc2 := cDesc3 := ""
Private cAlias	 := "SF1"
Private nLin 	 := 1
Private m_Pag   := 1
Private aReturn := { STR0039, 1,STR0040, 2, 2, 1, "",1 }  //Zebrado", 1,"Administracao
Private cTamanho:= "G"           // P/M/G
Private nCaracter:=15
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0041 //Imprime Devolucao X Venda de Veiculo
Private cNomProg:= "VEIVC160"
Private cNomeRel:= "VEIVC160"
Private nLastKey:= 0
Private cVendInt:= ""
Private nVECLucBru := nVECValPis := nVECValCof := nVECJurEst := nVECDesvar := nVECComVen := nVECComGer := nVECLucLiq  := nVECDesFix  := nVECCusFix  := nVECResFin  := nVECValDes := 0

cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| Imp_VEIVC160(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Imp_VEIVC160³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime dados da nota fiscal		    					    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Imp_VEIVC160(lEnd,wNRel,cAlias)

Local cAliasSF1 := "SQLSF1"
Local cForn := ""
Local cClnt := ""
cQuery := "SELECT SF1.F1_DOC,SF1.F1_FORNECE,SF1.F1_SERIE,SF2.F2_SERIE,SF1.F1_LOJA,SF1.F1_EMISSAO,SF1.F1_DTDIGIT,SF1.F1_VALBRUT,SD1.D1_NFORI,SF2.F2_DOC,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_VALBRUT,SF2.F2_EMISSAO,SD1.D1_COD, "
cQuery += FGX_MILSNF("SF1", 3, "F1_SERIE") + ", " + FGX_MILSNF("SF2", 3, "F2_SERIE") + " ,SF1.F1_TIPO, SF2.F2_TIPO "
cQuery += "FROM "+RetSqlName("SF1")+" SF1 , "+RetSqlName("SD1")+" SD1 ,"+RetSqlName("SF2")+" SF2 WHERE SF1.F1_FILIAL='"+xFilial("SF1")+"' AND "
cQuery += "SF1.F1_DOC='"+aItens[oLbx1:nAt,2]+"' AND SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SF1.F1_DOC=SD1.D1_DOC AND SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SD1.D1_NFORI=SF2.F2_DOC AND SF1.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSF1, .T., .T. )

nLin := 1
nLin := cabec(ctitulo,cDesc1,cDesc1,cNomProg,cTamanho,nCaracter)+2

@ nLin++, 001 pSay STR0042    //Dados NF Devolucao ###Dados NF Saida
@ nLin++ , 00 psay Repl("-",100)+"        "+Repl("-",100)

@ nLin++, 001 pSay STR0043 //Num.NF    Serie  Chassi               Fornecedor                     Emissao   Dt. Digit       Valor        Num.NF    Serie  Chassi               Cliente                        Emissao         Valor"
nLin++
dbSelectArea("SA2")
dbSetOrder(1)
dbSelectArea("SA1")
dbSetOrder(1)
dbSelectArea("VV1")
dbSetOrder(1)
dbSelectArea("SB1")
dbSetOrder(1)
Do While !( cAliasSF1 )->( Eof() )
	
	If ( cAliasSF1 )->F1_TIPO $ "BD"
		SA1->(dbSeek(xFilial("SA1")+( cAliasSF1 )->F1_FORNECE+( cAliasSF1 )->F1_LOJA))
		cForn := SA1->A1_NOME
	Else
		SA2->(dbSeek(xFilial("SA2")+( cAliasSF1 )->F1_FORNECE+( cAliasSF1 )->F1_LOJA))
		cForn := SA2->A2_NOME
	EndIf

	If ( cAliasSF1 )->F2_TIPO $ "BD"
		SA2->(dbSeek(xFilial("SA2")+( cAliasSF1 )->F2_CLIENTE+( cAliasSF1 )->F2_LOJA))
		cClnt := SA2->A2_NOME
	Else
		SA1->(dbSeek(xFilial("SA1")+( cAliasSF1 )->F2_CLIENTE+( cAliasSF1 )->F2_LOJA))
		cClnt := SA1->A1_NOME
	EndIf

	SB1->(dbSeek(xFilial("SB1")+( cAliasSF1 )->D1_COD))
	VV1->(dbSeek(xFilial("VV1")+SB1->B1_CODITE))
	
	@ nLin++, 001 pSay ( cAliasSF1 )->F1_DOC+"   "+ FGX_MILSNF( cAliasSF1, 2, "F1_SERIE" )+"  "+substr(VV1->VV1_CHASSI,1,20)+"  "+( cAliasSF1 )->F1_FORNECE+" - "+substr(cForn,1,20)+"  "+transform(stod(( cAliasSF1 )->F1_EMISSAO),"@D")+"  "+transform(stod(( cAliasSF1 )->F1_DTDIGIT),"@D")+"   "+transform(( cAliasSF1 )->F1_VALBRUT,"@E 999,999.99")+"       "+( cAliasSF1 )->F2_DOC+"   "+ FGX_MILSNF( cAliasSF1, 2, "F2_SERIE" ) +"  "+substr(VV1->VV1_CHASSI,1,20)+" "+( cAliasSF1 )->F2_CLIENTE+" - "+substr(cClnt,1,20)+"  "+transform(stod(( cAliasSF1 )->F2_EMISSAO),"@D")+"   "+transform(( cAliasSF1 )->F2_VALBRUT,"@E 999,999.99")
	dbSelectArea(cAliasSF1)
	(cAliasSF1)->(dbSkip())
	
Enddo
(cAliasSF1)->(DBCloseArea())
Ms_Flush()
Set Printer to
Set Device  to Screen

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_IMPNF    ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime nota fiscal		    							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPNF()   
/*
If Vazio(dEmissaoD) .and. Vazio(dEmissaoA) .and. Vazio(cFornec) .and. Vazio(cLoja)	.and. Vazio(cNFEntr);
.and. Vazio(cCliente) .and. Vazio(cLojaC) .and. Vazio(cSerieFor) .and. Vazio(cNFSaida)
MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
oEmissaod:SetFocus()
Return()
EndIf
*/
If Empty(aItens[1,1])
	MsgInfo(STR0019,STR0018)  //  Preencha os Dados da Consulta para realizar a pesquisa! ### Atencao!
	oEmissaod:SetFocus()
	Return()
EndIf
Private cDesc1 := cDesc2 := cDesc3 := ""
Private cAlias	 := "SF1"
Private nLin 	 := 1
Private m_Pag   := 1
Private aReturn := { STR0039, 1,STR0040, 2, 2, 1, "",1 }//zebrado - Administracao
Private cTamanho:= "G"           // P/M/G
Private nCaracter:=15
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}           // Ordem do Relatorio
Private cTitulo := STR0041 //Imprime Devolucao X Venda de Veiculo
Private cNomProg:= "VEIVC160"
Private cNomeRel:= "VEIVC160"
Private nLastKey:= 0
Private cVendInt:= ""
Private nVECLucBru := nVECValPis := nVECValCof := nVECJurEst := nVECDesvar := nVECComVen := nVECComGer := nVECLucLiq  := nVECDesFix  := nVECCusFix  := nVECResFin  := nVECValDes := 0

cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)

If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
RptStatus( { |lEnd| Imp_VC160T(@lEnd,cNomeRel,cAlias) } , cTitulo )
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Imp_VC160T  ³ Autor ³ Otavio / Thiago       ³ Data ³ 28/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Dados NF Devolucao ## Dados NF Saida						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Imp_VC160T(lEnd,wNRel,cAlias)

Local i := 0
Local cFornece := ""
Local cCliente := ""

nLin := 1
nLin := cabec(ctitulo,cDesc1,cDesc1,cNomProg,cTamanho,nCaracter)+2

@ nLin++, 001 pSay STR0042 	 // Dados NF Devolucao ## Dados NF Saida
@ nLin++ , 00 psay Repl("-",100)+"        "+Repl("-",100)

@ nLin++, 001 pSay STR0043 //Num.NF    Serie  Chassi               Fornecedor                     Emissao   Dt. Digit       Valor        Num.NF    Serie  Chassi               Cliente                        Emissao         Valor"
nLin++
For i := 1 to Len(aItens)
	
	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek(xFilial("SF1")+aItens[i,2])
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+aItens[i,2])
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SD1->D1_COD)
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+SB1->B1_CODITE)
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSeek(xFilial("SF2")+aItens[i,4])

	If SF1->F1_TIPO $ "BD"
		DbSelectArea("SA1")
		dbSetOrder(1)
		DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA) 
		cFornece := SA1->A1_NOME
	Else
		DbSelectArea("SA2")
		dbSetOrder(1)
		DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
		cFornece := SA2->A2_NOME
	EndIf

	If SF2->F2_TIPO $ "BD"
		DbSelectArea("SA2")
		dbSetOrder(1)
		DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		cCliente := SA2->A2_NOME
	Else
		DbSelectArea("SA1")
		dbSetOrder(1)
		DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		cCliente := SA1->A1_NOME
	Endif
	@ nLin++, 001 pSay SF1->F1_DOC+"   "+ FGX_MILSNF("SF1", 2, "F1_SERIE")+"  "+substr(VV1->VV1_CHASSI,1,20)+" "+SF1->F1_FORNECE+" - "+substr(cFornece,1,20)+"  "+transform(SF1->F1_EMISSAO,"@D")+"  "+transform(SF1->F1_DTDIGIT,"@D")+"   "+transform(SF1->F1_VALBRUT,"@E 999,999.99")+"        "+SF2->F2_DOC+"   "+ FGX_MILSNF("SF2",2,"F2_SERIE") +"  "+substr(VV1->VV1_CHASSI,1,20)+" "+SF2->F2_CLIENTE+" - "+substr(cCliente,1,20)+"  "+transform(SF2->F2_EMISSAO,"@D")+"   "+transform(SF2->F2_VALBRUT,"@E 999,999.99")
	
Next
Ms_Flush()
Set Printer to
Set Device  to Screen
Return(.t.)

