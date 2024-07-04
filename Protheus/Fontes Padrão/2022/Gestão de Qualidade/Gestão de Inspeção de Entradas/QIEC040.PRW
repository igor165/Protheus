#Include "QIEC040.CH"
#Include "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Qiec040  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consultas - Entradas por Documento de Entrada              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Qiec040                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³19/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
±±³Vera        ³18/02/00³------³ Filtra Entradas pela Filial tambem       ³±±
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

Local aRotina := {{OemToAnsi(STR0001),"AxPesqui"	,0,1},;	//"Pesquisar"
					 {OemToAnsi(STR0002),"a040IMP"	,0,1}}		//"Imprimir"

Return aRotina

Function qiec040
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFiltro := ""

Private Inclui	:=.T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o desenho padrao de atualizacoes                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemToAnsi(STR0003)		//"Docum. Entrada"

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
//³ mv_par01        // Do Docum. Entrada                         ³
//³ mv_par02        // At‚ Docum. Entrada                        ³
//³ mv_par03        // Data inicial                              ³
//³ mv_par04        // Data final                                ³
//³ mv_par05        // Considera Nota Fiscal 1)Normal			 ³
//³											 2)Beneficiamento    ³
//³ 										 3)Devolucao         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("QEC040",.F.)
If !(Pergunte("QEC040",.T.))
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o filtro por documento de Entrada   				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro += 'QEK_FILIAL == "'+xFilial("QEK")+'"'+'.And.'
If mv_par05 == 1
	cFiltro += '(QEK_TIPONF == " " .Or. QEK_TIPONF == "N")'
ElseIf mv_par05 == 2                                 
	cFiltro += 'QEK_TIPONF == "B"'
ElseIf mv_par05 == 3           
	cFiltro += 'QEk_TIPONF == "D"'
EndIf
cFiltro += '.And. QEK_DOCENT >= "'+mv_par01+'"'
cFiltro += '.And.QEK_DOCENT <= "'+mv_par02+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) >= "'+Dtos(mv_par03)+'"'
cFiltro += '.And.Dtos(QEK_DTENTR) <= "'+Dtos(mv_par04)+'"'  

If ExistBlock("QEC40FIL") 
	cFiltro := ExecBlock("QEC40FIL",.F.,.F.,{cFiltro}) 
EndIF

dbSelectArea("QEK")
dbSetOrder(4)              
MsgRun(STR0015,STR0016,{||dbSetFilter({||&cFiltro},cFiltro)}) //"Selecionando as Entradas..."###"Aguarde..."

dbGoTop()
If Eof()
	Help(" ",1,"RECNO")    
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"QEK")
EndIf	

dbSelectArea("QEK") 
Set Filter To                          

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a040IMP  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao da consulta obtida                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qiec040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a040IMP()
LOCAL cTitulo :=OemToAnsi(STR0005)		//"Documento de Entrada"
LOCAL cDesc1  := ""
LOCAL cDesc2  :=""
LOCAL cDesc3  :=""
LOCAL wnrel   :="QIEC040"
LOCAL cString :="QEL"

PRIVATE cPerg   :="      "
PRIVATE aReturn := { OemToAnsi(STR0008), 1,OemToAnsi(STR0009), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:=0
PRIVATE cTamanho:= "M"

wnrel:= SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| c040Imp(@lEnd,ctitulo,wnRel)},ctitulo)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ c040Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ qiec040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function c040Imp(lEnd,ctitulo,wnRel)
Local aAreas    :={QE6->(GetArea()), QEK->(GetArea()), QEL->(GetArea()), SA2->(GetArea())}
Local cbcont    := 0
Local cbTxt     := SPACE(10)
Local cCabec1   := ""
Local cNomeProg := "QIEC040"
Local nTipo     := 15

cCabec1 := PADR(FwX3Titulo("QEK_FORNEC"),TAMSX3('A2_NREDUZ')[1]) + Space(1)   //Fornecedor
cCabec1 += PADR(FwX3Titulo("QEK_PRODUT"),TAMSX3('QE6_DESCPO')[1] - 9)         //Produto
cCabec1 += PADR(FwX3Titulo("QEK_DTENTR"),TAMSX3('QEK_DTENTR')[1]) + Space(4)  //Dt Entr.
cCabec1 += PADR(AllTrim(FwX3Titulo("QEK_LOTE"))+'/'+AllTrim(FwX3Titulo("QEK_DOCENT")),  TAMSX3('D1_LOTEFOR')[1]) + Space(2)  //Lote-Lote Fornec.
cCabec1 += FwX3Titulo("QEK_VERIFI")  + Space(3)                               // I/C
cCabec1 += PADR(FwX3Titulo("QEK_PEDIDO"),TAMSX3('QEK_PEDIDO')[1]) + Space(5) //No. Pedido
cCabec1 += FwX3Titulo("QEK_TAMLOT") + Space(1)
cCabec1 += FwX3Titulo("QEL_LAUDO") + Space(4)

Li    := 80
m_pag := 1

DbSelectArea("QEK")
QEK->(dbGoTop())
SetRegua(RecCount()) //Total de Elementos da Regua

While QEK->(!Eof())
	IncRegua()
	If Li > 58 
		Cabec(cTitulo,cCabec1,"",cNomeProg,cTamanho,nTipo,,.F.)
	EndIf

	@Li,000 PSAY QEK->(QEK_FORNEC + " - " + QEK->QEK_LOJFOR)
	@Li,021 PSAY QEK->QEK_PRODUT	
	@Li,052 PSAY QEK->QEK_DTENTR	
	@Li,064 PSAY QEK->QEK_LOTE
	@Li,086 PSAY IIF(QEK->QEK_VERIFI == 1,STR0011,STR0012)		//"Ins"###"Cer"
	@Li,099 PSAY QEK->QEK_PEDIDO
	@Li,116 PSAY QEK->QEK_TAMLOT

	QEL->(dbSetOrder(3))
	If	QEL->(dbSeek(xFilial("QEL")+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+Dtos(QEK_DTENTR)+QEK_LOTE)+Space(TamSx3("QEL_LABOR")[1])))
		@Li,129 PSAY QEL->QEL_LAUDO
	Endif	        

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

QEK->(dbGoTop())
aEval(aAreas, {|x| RestArea(x)})
Return .T.
