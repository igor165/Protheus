#Include "Ctbc400.ch"
#Include "PROTHEUS.Ch"
#Include "TcBrowse.Ch"
#INCLUDE "DBINFO.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres

//-------------------------------------------------------------------
/*{Protheus.doc} CTBC440
Consulta de centro de custo ( raz„o ) 

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBC440
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para tela de atualiza‡“es ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro  	:= STR0001 + " - " + CtbSayAPro("CTT")  //"Consulta ú Raz„o Anal¡tico"
Private aRotina := MenuDef()
Private aSelFil	 := {} // Sera alimentada pela AdmGetFil

If !Pergunte( "CTC440" , .T.)
	Return
EndIf	

// Seleciona filiais
If mv_par14 == 1
	aSelFil := AdmGetFil()
	If Empty(aSelFil)
		Return
	EndIf
End	

SetKey(VK_F12, { || If(Pergunte( "CTC440" , .T. ), If( mv_par14 == 1, aSelFil := AdmGetFil(),aSelFil := {} ),NIL) })

mBrowse(06, 01, 22, 75, "CTT")

SetKey(VK_F12, Nil)

dbSelectarea("CTT")
dbSetOrder(1)
dbSelectarea("CT1")
dbSetOrder(1)
dbSelectarea("CT2")
dbSetOrder(1)

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} CT440Con
Envia para funcao que monta o arquivo de trabalho com as movimentacoes e mostra-o na tela

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CT440Con()

LOCAL nAlias
Local oDlg,oBrw,oCOl,aBrowse:={},ni, aCpos, nCpo
Local nDecimais := CTbMoeda(mv_par03)[5]
Local aSize		:= MsAdvSize(,.F.,430)
Local aSizeAut 	:= MsAdvSize(), cArqTmp
Local aEntCtb	:= {	{ "", "", nil, .T. },;	// Conta	
					 	{ "", "", nil, .T. },;	// Contra Partida
						{ "", "", nil, .F. },;	// Centro de Custo
						{ "", "", nil, .T. },;	// Item Contabil
						{ "", "", nil, .T. } }	// Classe de Valor
Local aObjects	:= {	{ 375,  70, .T., .T. },;
						{ 100, 750, .T., .T., .T. },;
						{ 100, 100, .T., .T. },;
						{ 100, 200, .T., .T. } }
Local aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
Local aPosObj 	:= MsObjSize( aInfo, aObjects, .T. ) , nSaldoAnterior := 0
Local nTotalDebito := nTotalCredito := nTotalSaldo := 0
Local nSALDOSCR  := nLANCDEB := nLANCCRD := 0.00
Local aSetOfBook := CTBSetOf(mv_par05)
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local lItem			:= Iif(mv_par08 == 1,.T.,.F.)
Local lCLVL			:= Iif(mv_par11 == 1,.T.,.F.)
Local aArea 		:= GetArea()   
Local cPictVal 		 := PesqPict("CT2","CT2_VALOR")
Local nX
Local cArq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ( CTC440 )              ³
//³ mv_par01            // da data                               ³
//³ mv_par02            // Ate a data                            ³
//³ mv_par03            // Moeda			                     ³   
//³ mv_par04            // Saldos		                         ³   
//³ mv_par05            // Set Of Books                          ³
//³ mv_par06            // Do Conta Contabil                     ³
//³ mv_par07            // At‚ a Conta Contabil                  ³
//³ mv_par08            // Imprime Item?	                     ³	
//³ mv_par09            // Do Item                               ³
//³ mv_par10            // Ate Item                              ³
//³ mv_par11            // Imprime Classe de Valor?              ³	
//³ mv_par12            // Da Classe de Valor                    ³
//³ mv_par13            // Ate a Classe de Valor                 ³
//³ mv_par14            // Seleciona filiais ?                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( CTT->CTT_CLASSE == "1" )
   Help ( " ", 1, "CC010SINTE" )
   Return ( .F. )
End              

//Validar se Moeda Existe ou esta em branco
dbSelectArea("CTO")
dbSetOrder(1)
If Empty(mv_par03) .or. !dbSeek(xFilial("CTO")+mv_par03,.F.) 
    Help(" ",1,"NOMOEDA")
	Return(.F.)
EndIf

nSaldoAnterior := SaldTotCT3(CTT->CTT_CUSTO,CTT->CTT_CUSTO,mv_par06,mv_par07,mv_par01,mv_par03,mv_par04,aSelFil)[6]

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               

// Mascara do Centro de Custo
If Empty(aSetOfBook[6])
	cMascara2 := GetMv("MV_MASCCUS")
Else
	cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
EndIf                                                
	
If lItem .Or. lCLVL
	// Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		cMascara3 := ""
	Else
		cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf
	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	


MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerRaz(	oMeter,oText,oDlg,lEnd,@cArqTmp,mv_par06,mv_par07,;
								CTT->CTT_CUSTO,CTT->CTT_CUSTO,mv_par09,mv_par10,;
								mv_par12,mv_par13,mv_par03,mv_par01,mv_par02,;
								aSetOfBook,.F.,mv_par04,.F.,"2",.T.,,,,,aSelFil) },;
				STR0006,;		// "Criando Arquivo Tempor rio..."
				STR0005)		// "Emissao do Razao"

RestArea(aArea)

aCpos := (cArqTmp->(DbStruct()))
If (cArqTmp->(Eof()))
   Help(" ", 1, "CC010SEMMO")
   //Nao colocar return falso pois após esse help inibe a tela mesmo vazia mas exibindo saldo das entidades, deve abrir a tela mesmo 
   //sem movimentos no periodo ou com saldo 0.
End

CTGerCplHis(@nSaldoAnterior, @nTotalSaldo, @nTotalDebito, @nTotalCredito)
nAlias 	:= Select("cArqTmp")
aBrowse := {	{STR0009,"DATAL"},;
				{STR0010,	{ || cArqTmp->LOTE + cArqTmp->SUBLOTE + cArqTmp->DOC +;
							'/' + cArqTmp->LINHA } },;
				{StrTran(STR0021, "-", ""),{ || MascaraCTB(cArqTmp->CONTA,cMascara1,,cSepara1) } },;
				{STR0012,{ || MascaraCTB(cArqTmp->XPARTIDA,cMascara1,,cSepara1) } },;
				{STR0011,"HISTORICO"},;
				{STR0013,"LANCDEB"},;
				{STR0014,"LANCCRD"},;
    			{STR0015,"SALDOSCR"},;
   				{STR0029,"TPSLDATU"},;
   				{"Filial","FILORI"}}

If lItem
	Aadd(aBrowse, {CtbSayAPro("CTD"),{ || MascaraCTB(cArqTmp->ITEM,cMascara3,,cSepara3) } })
Endif
If lCLVL
	Aadd(aBrowse, {CtbSayAPro("CTH"),{ || MascaraCTB(cArqTmp->CLVL,cMascara4,,cSepara4) } })
Endif

DEFINE 	MSDIALOG oDlg TITLE cCadastro;
		From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
cCondA := Iif(nSaldoAnterior<0,"D","C")
@ 35, 04  SAY CtbSayApro("CTT") + " " + MascaraCTB(CTT->CTT_CUSTO,cMascara2,,cSepara2) + " - " +;
AllTrim(Substr(&("CTT->CTT_DESC" + mv_par03),1,45)) PIXEL
@ 35,aPosObj[1][4] - 80 Say STR0026 +;
Transform(Abs(nSaldoAnterior),cPictVal) + " " + cCondA PIXEL //"Saldo Anterior "
@ 45,4 COLUMN BROWSE oBrw SIZE 	aPosObj[2][3],aPosObj[2][4] PIXEL OF oDlg
oBrw:lColDrag := .T.  // Permite a mudanca das ordens das colunas
oBrw:lMChange := .T.  // Permitir o ajuste do tamanho dos campos
oBrw:bChange := { || C400ChgBrw( mv_par03, @aEntCtb ) }
For ni := 1 to Len(aBrowse)
	uCpo := aBrowse[ni][2]
	If ValType(uCpo) <> "B"
		nCpo := Ascan(aCpos, { |x| x[1] = aBrowse[ni][2]})
	Else
		nCpo := 0
	Endif
	If nCpo = 0
		DEFINE COLUMN oCol DATA { || "" };
		HEADER aBrowse[ni][1];
		SIZE CalcFieldSize("C",	Len(Eval(uCpo)), 0,"",aBrowse[ni][1])
		oCol:bData := uCpo
	ElseIf ValType(&(aBrowse[ni][2])) != "N"
		If aBrowse[ni][2] == "HISTORICO"
			aCpos[nCpo][3] := TamSX3("CT2_HIST")[1]
		EndIf
		DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
		HEADER aBrowse[ni][1];
		SIZE CalcFieldSize(aCpos[nCpo][2],aCpos[nCpo][3],aCpos[nCpo][4],"",aBrowse[ni][1]) -; 
		If(ValType(&(aBrowse[ni][2])) = "D", 7, 0)
	Else
		uCpo := aBrowse[ni][2]
		DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
		PICTURE cPictVal;
		HEADER aBrowse[ni][1] SIZE CalcFieldSize(aCpos[nCpo][2],aCpos[nCpo][3],aCpos[nCpo][4],cPictVal,aBrowse[ni][1]) RIGHT
	Endif
	oBrw:ADDCOLUMN(oCol)
Next ni
DEFINE COLUMN oCol DATA { || Space(10) } HEADER " " SIZE 10 RIGHT
oBrw:ADDCOLUMN(oCol)

@ aPosObj[3][1], 002 TO aPosObj[3][3], aPosObj[3][4] LABEL STR0027 + CtbSayAPro("CTT") PIXEL
@aPosObj[3][1] + 8,005  Say STR0013 + Trans(nTotalDebito,tm(nTotalDebito,17,nDecimais)) PIXEL		//"D‚bito "
@aPosObj[3][1] + 8,170  Say STR0014 + Trans(nTotalCredito,tm(nTotalCredito,17,nDecimais)) PIXEL  	//"Cr‚dito "
cCondF := Iif(nTotalSaldo<0,"D","C")			
@ aPosObj[3][1] + 8,aPosObj[1][4] - 60 Say STR0020+ Transform(ABS(nTotalSaldo),cPictVal) + " " + cCondF Pixel //"Saldo "

@ aPosObj[4][1], 002 TO aPosObj[4][3], aPosObj[4][4] LABEL STR0030 PIXEL	// "Descrições"

@ aPosObj[4][1]+8,005 SAY StrTran(STR0021, "-", "") PIXEL	// Conta
@ aPosObj[4][1]+8,040 MSGET aEntCtb[1,3] VAR aEntCtb[1,2] WHEN .F. SIZE 150,08 PIXEL

@ aPosObj[4][1]+8,aPosObj[4][4] -190 SAY STR0012 PIXEL	// "Contra Partida"
@ aPosObj[4][1]+8,aPosObj[4][4] -152 MSGET aEntCtb[2,3] VAR aEntCtb[2,2] WHEN .F. SIZE 150,08 PIXEL

@ aPosObj[4][1]+19,005 SAY CtbSayAPro("CTD") PIXEL	// Item Contabil
@ aPosObj[4][1]+19,040 MSGET aEntCtb[4,3] VAR aEntCtb[4,2] WHEN .F. SIZE 150,08 PIXEL
                     
@ aPosObj[4][1]+19,aPosObj[4][4] -190 SAY CtbSayAPro("CTH") PIXEL	// Classe de Valor
@ aPosObj[4][1]+19,aPosObj[4][4] -152 MSGET aEntCtb[5,3] VAR aEntCtb[5,2] WHEN .F. SIZE 150,08 PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

// Elimina arquivo de Trabalho
dbSelectArea("cArqTmp")
cArq := DbInfo(DBI_FULLPATH)
cArq := AllTrim(SubStr(cArq,Rat("\",cArq)+1))
DbCloseArea()
FErase(cArq)

//Limpa os arquivos temporários 
CtbRazClean()

dbSelectArea("CTT")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT440Imp ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara a chamada para o relatorio CTBR440                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC440                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT440Imp()

Local aAreaCtt := CTT->(GetArea())
Local aSelImp	:= {}

If ! Pergunte("CTC440", .T.)
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ( CTC440 )              ³
//³ mv_par01            // da data                               ³
//³ mv_par02            // Ate a data                            ³
//³ mv_par03            // Moeda			                     ³   
//³ mv_par04            // Saldos		                         ³   
//³ mv_par05            // Set Of Books                          ³
//³ mv_par06            // Da Conta                              ³
//³ mv_par07            // Ate a Conta                           ³
//³ mv_par08            // Imprime Item?	                     ³	
//³ mv_par09            // Do Item                               ³
//³ mv_par10            // Ate Item                              ³
//³ mv_par11            // Imprime Classe de Valor?              ³	
//³ mv_par12            // Da Classe de Valor                    ³
//³ mv_par13            // Ate a Classe de Valor                 ³
//³ mv_par14            // Seleciona filiais ?                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par14 == 1
	aSelImp := aClone(aSelFil)
EndIf  

CTBR440(CTT->CTT_CUSTO, CTT->CTT_CUSTO, mv_par01, mv_par02, mv_par03, mv_par04,;
		mv_par05, mv_par06, mv_par07, mv_par08=1, mv_par09, mv_par10, mv_par11=1,;
		mv_par12, mv_par13,,aSelImp) 
		
Pergunte( "CTC440" , .F.)

CTT->(RestArea(aAreaCtt))
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³06/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina   	:= {	{STR0002,"AxPesqui",0,1},;  	//"Pesquisar"
                           	{STR0003,"CT440Con",0,2},;   	//"Visualizar"
                           	{STR0004,"CT440Imp",0,3}}    	//"Impressao"
Return(aRotina)