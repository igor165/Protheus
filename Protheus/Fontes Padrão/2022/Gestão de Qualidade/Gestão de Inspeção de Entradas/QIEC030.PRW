#Include "QIEC030.CH"
#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Qiec030  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consultas - Entradas Inspecionadas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qiec030                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³19/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
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
					 {OemToAnsi(STR0002),"a030IMP"	,	0 , 1}}	  //"Imprimir"

Return aRotina

Function qiec030
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFiltro := " "             			
Private Inclui  := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o desenho padrao de atualizacoes                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemToAnsi(STR0003)		//"Entradas inspecionadas"

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
PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        // Data inicial                              ³
//³ mv_par02        // Data final                                ³
//³ mv_par03        // Considera Nota Fiscal 1) Normal			 ³
//³ 										 2) Beneficiamento   ³
//³ 										 3) Devolucao        ³
//³ mv_par04        // Considera Lotes a Vencer					 ³
//³ mv_par05        // Dias p/ os lotes a Vencer				 ³
//³ mv_par06        // Produto De  		                 		 ³
//³ mv_par07        // Produto Ate				                 ³
//³ mv_par08        // Fornecedor De                   			 ³
//³ mv_par09        // Loja De                         			 ³
//³ mv_par10        // Fornecedor Ate                  			 ³
//³ mv_par11        // Loja Ate                        			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("QEC030",.F.)
If !(Pergunte("QEC030",.T.))
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o filtro das Entradas Inspecionadas 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
If mv_par03 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
ElseIf mv_par03 == 2                                   
	cFiltro += 'QEK_TIPONF == "B"'
ElseIf mv_par03 == 3
	cFiltro += 'QEK_TIPONF == "D"'
EndIf

cFiltro += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"'                         

cFiltro += '.And. QEK_PRODUT >= "'+mv_par06+'"'                         
cFiltro += '.And. QEK_PRODUT <= "'+mv_par07+'"'                         

cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR >= "'+mv_par08+mv_par09+'"'                         
cFiltro += '.And. QEK_FORNEC+QEK_LOJFOR <= "'+mv_par10+mv_par11+'"'                         

cFiltro += '.And. QEK_VERIFI == 1 .And. QEK_SITENT # "1" .And. QEK_SITENT # "4" .And. QEK_SITENT # "7" .And. QEK_SITENT # "8"'
cFiltro += '.And. C030PosLau()'
If mv_par04 == 1
	cFiltro += '.And. Dtos(QEL->QEL_DTVAL) <= "'+Dtos(dDataBase+mv_par05)+'"'
EndIf

If ExistBlock("QEC30FIL") 
	cFiltro := ExecBlock("QEC30FIL",.F.,.F.,{cFiltro}) 
EndIF

dbSelectArea("QEK")
dbSetOrder(2)                                                    

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")   
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse(6,1,22,75,"QEK",,,,,,,,,,,,,,,,,,cFiltro)                                     
EndIf	        


dbSelectArea("QEK") 
Set Filter To

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a030IMP  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao da consulta obtida                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qiec030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a030IMP()
LOCAL cTitulo := OemToAnsi(STR0005)		//"ENTRADAS INSPECIONADAS"
LOCAL cDesc1  := OemToAnsi(STR0006)		//"Este programa ira imprimir a Consulta das Entradas"
LOCAL cDesc2  := OemToAnsi(STR0007)		//"Inspecionadas."
LOCAL cDesc3  := ""
LOCAL wnrel   := "QIEC030"
LOCAL cString := "QEK"

PRIVATE cPerg   := " "
PRIVATE aReturn := { OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
PRIVATE cTamanho:= "M"

wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.) 

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| c030Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ c030Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qiec030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function c030Imp(lEnd,ctitulo,wnRel)
Local aAreas   := {QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}

Local cCabec1  := ""
Local cNomeProg:= "QIEC030"
Local cbTxt    := SPACE(10)
Local cbcont   := 0
Local nTipo    := 15


cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(4)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(08) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT") + Space(4)

  

Li    := 80
m_pag := 1

dbSelectArea("QEK")
dbGoTop()
SetRegua(RecCount()) //Total de Elementos da Regua

While !Eof()
				
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nTipo,,.F.)
	EndIf
	@Li,000 PSAY QEK->QEK_FORNEC	+ " - " + QEK_LOJFOR
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,086 PSAY IIF(QEK->QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,103 PSAY QEK->QEK_PEDIDO
	@Li,120 PSAY QEK->QEK_TAMLOT
	@Li,129 PSAY QEL->QEL_LAUDO

	Li++
	SA2->(dbSetOrder(1))
	If SA2->(dbSeek(xFilial("SA2")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR))
		@Li,000 PSAY SA2->A2_NREDUZ
	EndIf	
	QE6->(dbSetOrder(1))
	If QE6->(dbSeek(xFilial("QE6")+QEK->QEK_PRODUT))
		@Li,021 PSAY QE6->QE6_DESCPO
	EndIf
	@Li,064 PSAY QEK->QEK_DOCENT
	Li+=2
	dbSkip()
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

dbSelectArea("QEK")
dbGoTop() 
MS_FLUSH()             
aEval(aAreas, {|x| RestArea(x)})

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C030Laudo³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apresenta o Laudo do QEL.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C030Laudo()
Local cRet	 :=""
Local cSeek  := ""

QEL->(DbSetOrder(3))
cSeek := QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE+;
Space(TamSX3("QEL_LABOR")[1])

QEL->(dbSetOrder(1))
If	QEL->(dbSeek(xFilial("QEL")+cSeek))
	cRet := QEL->QEL_LAUDO
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C030PosLau³ Autor ³ Paulo Emidio de Barros³ Data ³28/11/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona No Laudo Final da Entrada Inspecionada           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C030PosLau() 

QEL->(dbSetOrder(3))
QEL->(MsSeek(xFilial("QEL")+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE+Space(TamSx3("QEL_LABOR")[1])))

Return(.T.)
