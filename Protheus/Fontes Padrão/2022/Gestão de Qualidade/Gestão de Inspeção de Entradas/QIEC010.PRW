#INCLUDE "TOTVS.CH"
#INCLUDE "QIEC010.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEC010  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consultas - Entradas a Inspecionar ( sem laudo )           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³15/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
±±³Vera        ³18/02/00³------³ Filtra Entradas pelo campo QEK_VERIFI = 1³±±
±±³Paulo Emidio³24/01/01³------³ Correcao na abertura dos indices tempora ³±±
±±³			   ³	    ³	   ³ rio atraves da funcao IndRegua.		  ³±±
±±³Paulo Emidio³11/06/01³META  ³ Incluida a opcao par selecionar o tipo de³±±
±±³       	   ³		³	   ³ Entrada a ser considera,se a mesma sera: ³±±
±±³       	   ³		³	   ³ 1)Normal 2)Beneficiamento 3)Devolucao 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef()

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"	,	0 , 1},; //"Pesquisar"
					 {OemToAnsi(STR0002),"A010IMP"	,	0 , 1}}	  //"Imprimir"

Return aRotina

Function QIEC010
Local cFiltro := " "

Private Inclui := .T.
Private cLaborQEL := Space(TamSX3("QEL_LABOR")[1])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o desenho padrao de atualizacoes                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemToAnsi(STR0003) //"Entradas a Inspecionar"

Pergunte("QEC010",.F.)
If !(Pergunte("QEC010",.T.))
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as Entradas de acordo com os parametros selecionados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro += 'QEK_FILIAL == "'+xFilial("QEK")+'"'+' .And. '
If mv_par03 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
ElseIf mv_par03 == 2
	cFiltro += 'QEK_TIPONF == "B"'
ElseIf mv_par03 == 3
	cFiltro += 'QEK_TIPONF == "D"'
EndIf
cFiltro += ' .And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
cFiltro += ' .And. Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"'
cFiltro += ' .And. QEK_VERIFI == 1'
cFiltro += ' .And. (QEK_SITENT == "1" .Or. QEK_SITENT == "7" .Or. QEK_SITENT == "8")'   

cFiltro += ' .And. QEK_PRODUT >= "'+mv_par04+'"'                         
cFiltro += ' .And. QEK_PRODUT <= "'+mv_par05+'"'                         

cFiltro += ' .And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par06+mv_par07+'"'                         
cFiltro += ' .And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par08+mv_par09+'"'                         


If ExistBlock("QEC10FIL") 
	cFiltro := ExecBlock("QEC10FIL",.F.,.F.,{cFiltro}) 
EndIF

QEL->(DbSetOrder(3))
DbSelectArea("QEK")
DbSetOrder(1)                         
Set Filter to &cFiltro

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")                         
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse(06,01,22,75,"QEK")
EndIf          

dbSelectArea("QEK") 
Set Filter To

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010IMP  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao da consulta obtida                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010IMP()
Local cTitulo  :=OemToAnsi(STR0005)		//"ENTRADAS A INSPECIONAR"
Local cDesc1   :=OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta das Entradas a"
Local cDesc2   :=OemToAnsi(STR0007)		//"inspecionar."
Local cDesc3   :=""
Local wnrel    :="QIEC010"

LOCAL cString   :="QEK"
Local cIndQEK   := QEK->(IndexKey())
PRIVATE cPerg   :="      "
PRIVATE aReturn := {OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:=0
PRIVATE cTamanho := "M"
wnrel:= SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.,,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| C010Imp(@lEnd,ctitulo,wnRel)},ctitulo)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C010Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C010Imp(lEnd,ctitulo,wnRel)
Local aAreas   := {QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}
Local cbcont   := 0  
Local cbTxt    := SPACE(10)
Local cCabec1  := ''
Local cNomeProg:= "QIEC010"
Local cSeek    := ""
Local nMV_COMP  := SUPERGETMV("MV_COMP", .T., 15)

cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(4)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(08) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT")                                           //Tam. Lote 

Li    := 80
m_pag := 1

dbSelectArea("QEK")
QEK->(dbGoTop())
SetRegua(QEK->(RecCount())) //Total de Elementos da Regua

While !QEK->(Eof())
	// Se tiver laudo, desconsidera a Entrada
	QEL->(DbSetOrder(3))
	cSeek := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)+;
	Space(TamSX3("QEL_LABOR")[1])

	If	QEL->(dbSeek(xFilial("QEL")+cSeek))
		If !Empty(QEL->QEL_LAUDO)
			QEL->(dbSkip())
			Loop
		EndIf
	EndIf		

	IncRegua()
	If Li > 58
		Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nMV_COMP,,.F.)
	EndIf
	@Li,000 PSAY QEK->QEK_FORNEC + " - " + QEK->QEK_LOJFOR
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR	
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,085 PSAY IIF(QEK->QEK_VERIFI == 1,STR0011,STR0012) //"Ins"###"Cer"
	@Li,100 PSAY QEK->QEK_PEDIDO
	@Li,118 PSAY QEK->QEK_TAMLOT PICTURE PesqPict("QEK","QEK_TAMLOT")
	Li++
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QEK->(QEK_FORNEC+QEK_LOJFOR)))
		@Li,000 PSAY SA2->A2_NREDUZ
	EndIf	
	QE6->(dbSetOrder(1))
	If QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT))
		@Li,021 PSAY QE6->QE6_DESCPO
	EndIf
	@Li,064 PSAY QEK->QEK_DOCENT
	Li+=2
	QEK->(dbSkip())
EndDo

If Li != 80 
	Roda(cbcont,cbtxt)
EndIf

Set Device To Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourSpool(wnrel)
EndIf

MS_FLUSH()

aEval(aAreas, {|x| RestArea(x)})

Return .T.
