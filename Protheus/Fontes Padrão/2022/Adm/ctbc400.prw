#Include "Ctbc400.ch"
#Include "PROTHEUS.Ch"
#Include "TCBrowse.ch"
#INCLUDE "DBINFO.CH"

Static _cAliQry := NIL
Static _aChvLct := NIL

// 17/08/2009 -- Filial com mais de 2 caracteres


//-------------------------------------------------------------------
/*{Protheus.doc} CTBC400
Consulta de contas cont beis ( raz„o )  

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBC400()

Private aSelFil	 := {} // Sera alimentada pela AdmGetFil

Private cCadastro  	:= STR0001  //"Consulta ú Raz„o Anal¡tico"
Private aRotina := MenuDef()

If _cAliQry == NIL
	_cAliQry := CriaTrab(,.F.)
EndIf

If !Pergunte( "CTC400" , .T.)
	Return
EndIf	

// Seleciona filiais
If mv_par16 == 1
	aSelFil := AdmGetFil()
	If Empty(aSelFil)
		Return
	EndIf
End	

SetKey(VK_F12, { || If(Pergunte( "CTC400" , .T. ), If( mv_par16 == 1, aSelFil := AdmGetFil(),aSelFil := {} ),NIL) })

mBrowse(06, 01, 22, 75, "CT1")

SetKey(VK_F12, Nil)

dbSelectarea("CT1")
dbSetOrder(1)
dbSelectarea("CT2")
dbSetOrder(1)

_cAliQry := NIL

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT400Con ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 19/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que monta o arquivo de trabalho com as   ³±±
±±³          ³ movimentacoes e mostra-o na tela                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT400Con()   

LOCAL nAlias
Local oDlg,oBrw,oCOl,aBrowse:={},ni, aCpos, nCpo
Local aSize		:= MsAdvSize(,.F.,430)
Local aSizeAut 	:= MsAdvSize(), cArqTmp
Local aEntCtb	:= {	{ "", "", nil, .F. },;	// Conta	
					 	{ "", "", nil, .T. },;	// Contra Partida
						{ "", "", nil, .T. },;	// Centro de Custo
						{ "", "", nil, .T. },;	// Item Contabil
						{ "", "", nil, .T. } }	// Classe de Valor
Local aObjects	:= {	{ 375,  70, .T., .T. },;
						{ 100, 750, .T., .T., .T. },;
						{ 100, 100, .T., .T. },;
						{ 100, 200, .T., .T. } }
Local aInfo   		:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
Local aPosObj 		:= MsObjSize( aInfo, aObjects, .T. ) , nSaldoAnterior := 0
Local nTotalDebito	:= nTotalCredito := nTotalSaldo := 0
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local aSetOfBook 	:= {}
Local nDecimais 	:= 0
Local lCusto 		:= .T.
Local lItem			:= .T.
Local lCLVL			:= .T.
Local aArea 		:= GetArea(), nTamanho        
Local cPictVal  	:= PesqPict("CT2","CT2_VALOR")
Local nX
Local cArq
Local cFiltro := ""
Local aButtons	:= {}
Local cxFilCT2  := xFilial("CT2")

If ExistBlock("CTB400FIL")								/// PONTO DE ENTRADA PARA A FILTRAGEM DO BROWSE
	cFiltro := ExecBlock("CTB400FIL", .F., .F.)
Endif

Pergunte( "CTC400" , .F.)

aSetOfBook 	:= CTBSetOf(mv_par05)
nDecimais 	:= CTbMoeda(mv_par03)[5]	// Recarrego as perguntas
lCusto 		:= Iif(mv_par06 == 1,.T.,.F.)
lItem		:= Iif(mv_par09 == 1,.T.,.F.)
lCLVL		:= Iif(mv_par12 == 1,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ( CTC400 )              ³
//³ mv_par01            // da data                               ³
//³ mv_par02            // Ate a data                            ³
//³ mv_par03            // Moeda			                     ³   
//³ mv_par04            // Saldos		                         ³   
//³ mv_par05            // Set Of Books                          ³
//³ mv_par06            // Imprime C.Custo?                      ³
//³ mv_par07            // Do Centro de Custo                    ³
//³ mv_par08            // At‚ o Centro de Custo                 ³
//³ mv_par09            // Imprime Item?	                     ³	
//³ mv_par10            // Do Item                               ³
//³ mv_par11            // Ate Item                              ³
//³ mv_par12            // Imprime Classe de Valor?              ³	
//³ mv_par13            // Da Classe de Valor                    ³
//³ mv_par14            // Ate a Classe de Valor                 ³
//³ mv_par15            // Descrição na moeda                    ³
//³ mv_par16            // Seleciona filiais ?                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ( CT1->CT1_CLASSE == "1" )
   Help ( " ", 1, "CC010SINTE" )
   Return ( .F. )
End                 

If Empty( mv_par03 )
    Help(" ",1,"NOMOEDA")
	Return(.F.)
EndIf

dbSelectArea("CTO")
dbSetOrder(1)
If !dbSeek(xFilial("CTO")+mv_par03,.F.)
    Help(" ",1,"NOMOEDA")
	Return(.F.)	
EndIf

nSaldoAnterior := 0
// Soma o saldo anterior da conta de todas as filiais
nSaldoAnterior := SaldoCT7Fil(CT1->CT1_CONTA,mv_par01,mv_par03,mv_par04,,,,aSelFil)[6]	 

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               

If lCusto .Or. lItem .Or. lCLVL
	// Mascara do Centro de Custo
	If Empty(aSetOfBook[6])
		cMascara2 := GetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                
	// Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		dbSelectArea("CTD")
		cMascara3 := ALLTRIM(STR(Len(CTD->CTD_ITEM)))
	Else
		cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf
	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		dbSelectArea("CTH")
		cMascara4 := ALLTRIM(STR(Len(CTH->CTH_CLVL)))
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

If Len(aSelFil) > 0 
	For nX := 1 TO Len(aSelFil)
		cxFilCT2 := xFilial("CT2", aSelFil[nX])
		CtbCtHis( cxFilCT2, CT1->CT1_CONTA, mv_par01, mv_par02 )
	Next
Else
	CtbCtHis( cxFilCT2, CT1->CT1_CONTA, mv_par01, mv_par02 )
EndIf

If !Empty(cFiltro)									/// SE A EXPRESSÃO RETORNADA NÃO ESTIVER VAZIA
	Set Filter To &(cFiltro)						/// ACIONA A EXPRESSÃO DE FILTRO NO CT1
Endif

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,CT1->CT1_CONTA,CT1->CT1_CONTA,;
							 mv_par07,mv_par08,mv_par10,mv_par11,;
							 mv_par13,mv_par14,mv_par03,mv_par01,mv_par02,;
							 CTBSetOf(""),.F.,mv_par04,.F.,"1",.T.,,,cFiltro,,aSelFil) },;
			STR0006,;		// "Criando Arquivo Tempor rio..."
			STR0005)		// "Emissao do Razao"

RestArea(aArea)


aCpos := (cArqTmp->(DbStruct()))

CTGerCplHis(@nSaldoAnterior, @nTotalSaldo, @nTotalDebito, @nTotalCredito)

cArqTmp->(DbGoTop())	
nAlias 	:= Select("cArqTmp")
	
If cArqTmp->(Eof()) .And. cArqTmp->(Bof()) .and. nSaldoAnterior == 0
   Help(" ", 1, "CC010SEMMO")
End

aBrowse := {	{STR0009,"DATAL"},;
				{STR0010,{ || cArqTmp->(LOTE+SUBLOTE+DOC)+'/'+cArqTmp->LINHA} },;
				{STR0011,{ || Alltrim(cArqTmp->HISTORICO) }},;	//"HISTORICO"
				{STR0012,{ || MascaraCTB(cArqTmp->XPARTIDA,cMascara1,,cSepara1) } },;
				{STR0013,"LANCDEB"},;
				{STR0014,"LANCCRD"},;
   				{STR0015,"SALDOSCR"},;
   				{STR0029,"TPSLDATU"},;
   				{"Filial","FILORI"}}    				
	
If lCusto
	Aadd(aBrowse, {CtbSayAPro("CTT"),{ || MascaraCTB(cArqTmp->CCUSTO,cMascara2,,cSepara2) } })
Endif
If lItem
	Aadd(aBrowse, {CtbSayAPro("CTD"),{ || MascaraCTB(cArqTmp->ITEM,cMascara3,,cSepara3) } })
Endif
If lCLVL
	Aadd(aBrowse, {CtbSayAPro("CTH"),{ || MascaraCTB(cArqTmp->CLVL,cMascara4,,cSepara4) } })
Endif
	
DEFINE 	MSDIALOG oDlg TITLE cCadastro;
		From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
SX3->(DbSetOrder(2))
SX3->(DbSeek("CT1_NORMAL"))
cCondA := Iif(nSaldoAnterior<0,"D","C")
@ 35, 04  SAY STR0018 + MascaraCTB(CT1->CT1_CONTA,cMascara1,,cSepara1) + " - " +;
AllTrim(Substr(&("CT1->CT1_DESC" + mv_par03),1,45)) +;
" - " + X3Titulo() + " - " + CT1->CT1_NORMAL PIXEL //"Conta - " 
@ 35,aPosObj[1][4] - 100 Say STR0026 +;
Transform(Abs(nSaldoAnterior),cPictVal) + " " + cCondA PIXEL //"Saldo Anterior "
SX3->(DbSetOrder(1))
@ 45,4 COLUMN BROWSE oBrw SIZE 	aPosObj[2][3],aPosObj[2][4] PIXEL OF oDlg
oBrw:lColDrag := .T.  // Permite a mudanca das ordens das colunas
oBrw:lMChange := .T.  // Permitir o ajuste do tamanho dos campos
For ni := 1 to Len(aBrowse)
	uCpo := aBrowse[ni][2]
	If ValType(uCpo) <> "B"
		nCpo := Ascan(aCpos, { |x| x[1] = aBrowse[ni][2]})
	Else
		nCpo := 0
	Endif
	If Len(aBrowse[ni]) > 2
		nTamanho := aBrowse[ni][3]
	Else
		If nCpo > 0
			nTamanho := aCpos[nCpo][3]
		Else
			nTamanho := 0
		Endif
	Endif
	If nCpo = 0
		DEFINE COLUMN oCol DATA { || "" };
		HEADER aBrowse[ni][1];
		SIZE CalcFieldSize("C",	If(nTamanho = 0, Len(Eval(uCpo)), nTamanho), 0,"",aBrowse[ni][1])
		oCol:bData := uCpo
	ElseIf ValType(&(aBrowse[ni][2])) != "N"
		DEFINE COLUMN oCol DATA FieldWBlock(aBrowse[ni][2], nAlias);
		HEADER aBrowse[ni][1];
		SIZE CalcFieldSize(aCpos[nCpo][2],nTamanho,aCpos[nCpo][4],"",aBrowse[ni][1]) -; 
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
oBrw:bChange := { || C400ChgBrw( mv_par03, @aEntCtb ) }

@ aPosObj[3][1], 002 TO aPosObj[3][3], aPosObj[3][4] LABEL STR0019 PIXEL
@aPosObj[3][1] + 8,005  Say STR0013 + Trans(nTotalDebito,tm(nTotalDebito,17,nDecimais)) PIXEL		//"D‚bito "
@aPosObj[3][1] + 8,170  Say STR0014 + Trans(nTotalCredito,tm(nTotalCredito,17,nDecimais)) PIXEL  	//"Cr‚dito "
cCondF := Iif(nTotalSaldo<0,"D","C")			
@ aPosObj[3][1] + 8,aPosObj[3][4] - 80 Say STR0020+ Transform(ABS(nTotalSaldo),cPictVal) + " " + cCondF Pixel //"Saldo "
                               
@ aPosObj[4][1], 002 TO aPosObj[4][3], aPosObj[4][4] LABEL STR0030 PIXEL	// "Descrições"
	
@ aPosObj[4][1]+8,005 SAY STR0012 PIXEL	// "Contra Partida"
@ aPosObj[4][1]+8,045 MSGET aEntCtb[2,3] VAR aEntCtb[2,2] WHEN .F. SIZE 150,08 PIXEL

@ aPosObj[4][1]+8,aPosObj[4][4] -185 SAY CtbSayAPro("CTT") PIXEL	// "Centro de Custo"
@ aPosObj[4][1]+8,aPosObj[4][4] -152 MSGET aEntCtb[3,3] VAR aEntCtb[3,2] WHEN .F. SIZE 150,08 PIXEL

@ aPosObj[4][1]+19,005 SAY CtbSayAPro("CTD") PIXEL	// Item Contabil
@ aPosObj[4][1]+19,045 MSGET aEntCtb[4,3] VAR aEntCtb[4,2] WHEN .F. SIZE 150,08 PIXEL
                     
@ aPosObj[4][1]+19,aPosObj[4][4] -185 SAY CtbSayAPro("CTH") PIXEL	// Classe de Valor
@ aPosObj[4][1]+19,aPosObj[4][4] -152 MSGET aEntCtb[5,3] VAR aEntCtb[5,2] WHEN .F. SIZE 150,08 PIXEL
	   
If ExistBlock("CT400CBT")
	aButtons	:= ExecBlock("CT400CBT", .F.,.F.)
	If ValType(aButtons) <> "A" 
		aButtons:={}
	Endif
Endif
	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) 


// Elimina arquivo de Trabalho
dbSelectArea("cArqTmp")
cArq := DbInfo(DBI_FULLPATH)
cArq := AllTrim(SubStr(cArq,Rat("\",cArq)+1))
DbCloseArea()
FErase(cArq)

//Limpa os arquivos temporários 
CtbRazClean()

_aChvLct := NIL

dbSelectArea("CT1")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT400Imp ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara a chamada para o relatorio CTBR400                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT400Imp()

Local aAreaCt1 := CT1->(GetArea())
Local aSelImp	:= {}

If ! Pergunte("CTC400", .T.)
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ( CTC400 )              ³
//³ mv_par01            // da data                               ³
//³ mv_par02            // Ate a data                            ³
//³ mv_par03            // Moeda			                     ³   
//³ mv_par04            // Saldos		                         ³   
//³ mv_par05            // Set Of Books                          ³
//³ mv_par06            // Imprime C.Custo?                      ³
//³ mv_par07            // Do Centro de Custo                    ³
//³ mv_par08            // At‚ o Centro de Custo                 ³
//³ mv_par09            // Imprime Item?	                     ³	
//³ mv_par10            // Do Item                               ³
//³ mv_par11            // Ate Item                              ³
//³ mv_par12            // Imprime Classe de Valor?              ³	
//³ mv_par13            // Da Classe de Valor                    ³
//³ mv_par14            // Ate a Classe de Valor                 ³
//³ mv_par15            // Descrição na moeda                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par16 == 1
	aSelImp := aClone(aSelFil)
EndIf  

CTBR400(CT1->CT1_CONTA, CT1->CT1_CONTA, mv_par01, mv_par02, mv_par03, mv_par04,;
		mv_par05, mv_par06=1, mv_par07, mv_par08, mv_par09=1, mv_par10, mv_par11,;
		mv_par12=1, mv_par13, mv_par14,, mv_par15,aSelImp)

Pergunte("CTC400", .F.)		
CT1->(RestArea(aAreaCt1))   

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTGerCplHis³ Autor ³ Wagner Mobile Costa  ³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que carrega o complemento do historico              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTGerCplHis(nSaldoAnterior, nTotalSaldo, nTotalDebito, nTotalCredito,;
					 lDocBranco)

Local nSALDOSCR  := nLANCDEB := nLANCCRD := 0.00
Local cConta, cCusto, cItem, cClVl, lCplHist := cArqTmp->(FieldPos("SEQLAN")) > 0
Local nSaldAnt 	:= nSaldoAnterior		// Armazena Saldo Anterior
Local nTotSld	:= 0  //Auxiliar utilizada para atualizar o saldo total
Local nRegTmp	:= 0
Local lTemMov   := .F.
Local cFilOld := cFilAnt
Local lContHis := .F.
Local aRecCT2Hs := {}
Local nX

dbSelectArea("cArqTmp")
cArqTmp->( DbGoTop() )
While cArqTmp->( ! Eof() )

	cFilAnt := cArqTmp->FILORI
	
	If lDocBranco # Nil .And. ! lDocBranco .And. Empty(cArqTmp->CT2KEY)
		cArqTmp->( DbDelete() )
		cArqTmp->( DbSkip() )
		Loop		
	Endif
	If cArqTmp->TIPO = "4" //Atualiza o Saldo Total      
	   	nTotSld := nSaldoAnterior + nTotalSaldo - cArqTmp->LANCDEB + cArqTmp->LANCCRD
		nTotalDebito 	+= cArqTmp->LANCDEB
		nTotalCredito	+= cArqTmp->LANCCRD
		nSaldoAnterior 	:= 0
		nTotalSaldo 	:= nTotSld
		Replace SALDOSCR With ABS(nTotSld )
		If nTotSld > 0 
			Replace TPSLDATU	With "C"				
		ElseIf nTotSld < 0                              
			Replace TPSLDATU	With "D"
		Else
			Replace TPSLDATU With " "
		EndIf            		
		cArqTmp->( DbSkip() )
		Loop
	Endif

 	If lCplHist
		nRegTmp := cArqTmp->( Recno() )
		// Procura pelo complemento de historico
		dbSelectArea("CT2")
		If _aChvLct != NIL
			lContHis := .F.
			If Len(_aChvLct) > 0  //ARRAY STATIC montado na funcao CtbCtHis()
				//procura ver se tem historico para o lancto
				lContHis := aScan( _aChvLct, cArqTMP->FILIAL+DTOS(cArqTMP->DATAL)+cArqTMP->LOTE+cArqTMP->SUBLOTE+cArqTMP->DOC+cArqTMP->SEQLAN+cArqTMP->EMPORI+cArqTMP->FILORI+'01') > 0
			EndIf
		Else
			lContHis := .T.
		EndIf
	Endif
	
	If 	lCplHist .And. lContHis  //somente entra se tem continuacao de historico para evitar dbseek e dbskip

		aRecCT2Hs := CtbHstRc()

		For nX := 1 TO Len(aRecCT2Hs)

			CT2->( dbGoto(aRecCT2Hs[nX]) )

			IF cArqTmp->TIPO == "4"

				nSALDOSCR 		  := cArqTmp->SALDOSCR
				nLANCDEB 		  := cArqTmp->LANCDEB
				nLANCCRD 		  := cArqTmp->LANCCRD
				cConta			  := cArqTmp->CONTA
				cCusto			  := cArqTmp->CCUSTO
				cItem 			  := cArqTmp->ITEM
				cClVl 			  := cArqTmp->CLVL
				cArqTmp->SALDOSCR := 0.00
				cArqTmp->LANCDEB  := 0.00
				cArqTmp->LANCCRD  := 0.00

			EndIf

			CtbGrvRAZ(.F.,mv_par03,mv_par04,CT2->CT2_DC,,"CT2")

			Replace CONTA With cConta, CCUSTO With cCusto, ITEM With cItem, CLVL With cClVl

			IF cArqTmp->TIPO == "4"

				cArqTmp->SALDOSCR := nSALDOSCR
				cArqTmp->LANCDEB  := nLANCDEB
				cArqTmp->LANCCRD  := nLANCCRD

			EndIf
		Next
		
		DbSelectArea("cArqTmp")
		DbGoTo(nRegTmp)
	Endif

	DbSelectArea("cArqTmp")
   
	//Atualiza o Saldo Total
	nSldTot := nSaldoAnterior + nTotalSaldo - cArqTmp->LANCDEB + cArqTmp->LANCCRD
	nTotalDebito 	+= cArqTmp->LANCDEB
	nTotalCredito	+= cArqTmp->LANCCRD
	nSaldoAnterior 	:= 0
	nTotalSaldo 	:= nSldTot
	Replace SALDOSCR With ABS(nSldTot )
	If nSldTot > 0 
		Replace TPSLDATU	With "C"				
	ElseIf nSldTot < 0                              
		Replace TPSLDATU	With "D"
	Else
		Replace TPSLDATU 	With " "
	EndIf            		
                      
	lTemMov := .T.
	
	cArqTmp->( DbSkip() )

EndDo

cFilAnt := cFilOld
nSaldoAnterior  := nSaldAnt				// Recupera Saldo Anterior

If !lTemMov
	nTotalSaldo := nSaldoAnterior
EndIf

cArqTmp->( DbGoTop() )

dbSelectArea("CT2")
DbSetOrder(1)	//a função CtbHstRc() muda para ordem 10 por isso neste ponto deve voltar para 1
DbSelectArea("cArqTmp")

Return .T.

//--------------------------------------------------
/*/{Protheus.doc} CtbHstRc()
Retorna array com os recnos de continuacao de historico do lancamento

@author TOTVS
@since 09/10/2019
@version P12.1.17

@return array de recnos da continuacao de historico
/*/
//--------------------------------------------------
Static Function CtbHstRc()
Local aRecCT2 := {}
CT2->( dbSetOrder(10) ) //CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQHIS                                                    

If 	CT2->( dbSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.) )
	CT2->( dbSkip() )  //posicionou na partida dobrada ou credito ou debito avanca um registro para avaliar se tem contin.Historico
	
	If CT2->CT2_DC == "4"
		While CT2->( !Eof() ) .And. CT2->CT2_FILIAL 	== xFilial() 			.And.;
									DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)	.And.;
									CT2->CT2_LOTE 		== cArqTMP->LOTE 		.And.;
									CT2->CT2_SBLOTE 	== cArqTMP->SUBLOTE 	.And.;
									CT2->CT2_DOC 		== cArqTmp->DOC 		.And.;
									CT2->CT2_SEQLAN 	== cArqTmp->SEQLAN 		.And.;
									CT2->CT2_EMPORI 	== cArqTmp->EMPORI		.And.;
									CT2->CT2_FILORI 	== cArqTmp->FILORI		.And.;
									CT2->CT2_DC 		== "4" 

			aAdd(aRecCT2, CT2->( Recno() ) )
			CT2->( dbSkip() )
		EndDo
	EndIf
							
EndIf
										
Return( aRecCT2 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ C400ChgBrw ºAutor ³ Gustavo Henrique   º Data ³  01/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza descricoes da contra partida, centro de custo,     º±±
±±º          ³ item contabil e classe de valor.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cMoeda  - Codigo da moeda da consulta                       º±±
±±º          ³ aEntCtb - Array com codigo, descricao e objeto por entidade º±±
±±º          ³           aEntCtb[1] - Conta contabil                       º±±
±±º          ³                  [1,1] - Codigo da conta                    º±±
±±º          ³                  [1,2] - Descricao da conta                 º±±
±±º          ³                  [1,3] - Objeto GET para exibir a descricao º±±
±±º          ³                  [1,4] - Usado na consulta atual            º±±
±±º          ³           aEntCtb[2] - Contra Partida    				   º±±
±±º          ³           aEntCtb[3] - Centro de Custo                      º±±
±±º          ³           aEntCtb[4] - Item Contabil                        º±±
±±º          ³           aEntCtb[5] - Classe de Valor                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Consultas Razao por conta contabil                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C400ChgBrw( cMoeda, aEntCtb )

If aEntCtb[1,4] .And. (aEntCtb[1,1] # cArqTmp->CONTA)
	aEntCtb[1,1] := cArqTmp->CONTA
	aEntCtb[1,2] := CtbDescEnt( cArqTmp->CONTA, "CT1", cMoeda )
	aEntCtb[1,3]:Refresh()
EndIf

If aEntCtb[2,4] .And. (aEntCtb[2,1] # cArqTmp->XPARTIDA)
	aEntCtb[2,1] := cArqTmp->XPARTIDA
	aEntCtb[2,2] := CtbDescEnt( cArqTmp->XPARTIDA, "CT1", cMoeda )
	aEntCtb[2,3]:Refresh()
EndIf

If aEntCtb[3,4] .And. (aEntCtb[3,1] # cArqTmp->CCUSTO)
	aEntCtb[3,1] := cArqTmp->CCUSTO
	aEntCtb[3,2] := CtbDescEnt( cArqTmp->CCUSTO, "CTT", cMoeda )
	aEntCtb[3,3]:Refresh()
EndIf	

If aEntCtb[4,4] .And. (aEntCtb[4,1] # cArqTmp->ITEM)
	aEntCtb[4,1] := cArqTmp->ITEM
	aEntCtb[4,2] := CtbDescEnt( cArqTmp->ITEM, "CTD", cMoeda )
	aEntCtb[4,3]:Refresh()
EndIf	

If aEntCtb[5,4] .And. (aEntCtb[5,1] # cArqTmp->CLVL)
	aEntCtb[5,1] := cArqTmp->CLVL
	aEntCtb[5,2] := CtbDescEnt( cArqTmp->CLVL, "CTH", cMoeda )
	aEntCtb[5,3]:Refresh()
EndIf	

Return

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

Local nX			:=0
Local aCT400BUT		:={}
Local aRotina   	:= {	{STR0002,"AxPesqui",0,1},;  	//"Pesquisar"
                           	{STR0003,"CT400Con",0,2},;   	//"Visualizar"
                           	{STR0004,"CT400Imp",0,3}}    	//"Impressao"

If ExistBlock("CT400BUT")
	aCT400BUT	:= ExecBlock("CT400BUT", .F.,.F., aRotina)
	
	If ValType(aCT400BUT) == "A" .AND. Len(aCT400BUT) > 0
		For nX := 1 to len(aCT400BUT)
			aAdd(aRotina, aCT400BUT[nX])
		Next
	Endif
Endif

Return(aRotina)


//--------------------------------------------------
/*/{Protheus.doc} CtbCtHis( )
Retorna array com as chaves dos lancamentos que possuem continuacao de historico do lancamento

@author TOTVS
@since 10/10/2019
@version P12.1.17

@return array de recnos da continuacao de historico
/*/
//--------------------------------------------------
Static Function CtbCtHis( cxFilCT2, cConta, dDataIni, dDataFim)
Local cQuery 	:= ""
Local cAliasQry := ""

If _aChvLct == NIL
	_aChvLct 	:= {}
EndIf

If _cAliQry == NIL
	_cAliQry := CriaTrab(,.F.)
EndIf

cAliasQry := _cAliQry  //artificio para nao ficar invocando criaTrab toda execucao desta funcao
                       //a variavel static _cAliQry e resetada na saida da consulta
//QUERY
cQuery 	:= " SELECT CT2DB.CT2_FILIAL CT2_FILIAL, CT2DB.CT2_DATA CT2_DATA, CT2DB.CT2_LOTE CT2_LOTE, CT2DB.CT2_SBLOTE CT2_SBLOTE, CT2DB.CT2_DOC CT2_DOC, CT2DB.CT2_SEQLAN CT2_SEQLAN, CT2DB.CT2_EMPORI CT2_EMPORI, CT2DB.CT2_FILORI CT2_FILORI, CT2DB.CT2_MOEDLC CT2_MOEDLC"
cQuery 	+= " FROM "+RetSqlName("CT2")+" CT2DB , "+RetSqlName("CT2")+" HISD "
cQuery 	+= " WHERE "
//condicao para lancamentos a DEBITO na conta informada
cQuery 	+= "     CT2DB.CT2_FILIAL 	= '"+cxFilCT2+"'"
cQuery 	+= " AND CT2DB.CT2_DC IN ('1', '3') "  //DEBITO E PARTIDA DOBRADA
cQuery 	+= " AND CT2DB.CT2_DEBITO 	= '"+cConta+"'"
cQuery 	+= " AND CT2DB.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"'"
cQuery 	+= " AND CT2DB.CT2_MOEDLC 	= '01'" //moeda eh sempre na 01
cQuery 	+= " AND CT2DB.D_E_L_E_T_ 	= ' '"
//link/join com tabela de lançamentos com continuacao de historico
cQuery 	+= " AND CT2DB.CT2_FILIAL	= HISD.CT2_FILIAL"
cQuery 	+= " AND CT2DB.CT2_DATA		= HISD.CT2_DATA"
cQuery 	+= " AND CT2DB.CT2_LOTE		= HISD.CT2_LOTE"
cQuery 	+= " AND CT2DB.CT2_SBLOTE	= HISD.CT2_SBLOTE"
cQuery 	+= " AND CT2DB.CT2_DOC		= HISD.CT2_DOC"
cQuery 	+= " AND CT2DB.CT2_SEQLAN	= HISD.CT2_SEQLAN"
cQuery 	+= " AND CT2DB.CT2_EMPORI	= HISD.CT2_EMPORI"
cQuery 	+= " AND CT2DB.CT2_FILORI	= HISD.CT2_FILORI"
cQuery 	+= " AND CT2DB.CT2_MOEDLC	= HISD.CT2_MOEDLC"
//condicao da continuacao de historico
cQuery 	+= " AND HISD.CT2_FILIAL 	= '"+cxFilCT2+"'"
cQuery 	+= " AND HISD.CT2_MOEDLC 	= '01' " //moeda eh sempre na 01
cQuery 	+= " AND HISD.CT2_DC 		= '4'" //4 = Continuacao de historico e as entidades contabeis estao em branco
cQuery 	+= " AND HISD.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"'"
cQuery 	+= " AND HISD.D_E_L_E_T_ 	= ' '"
cQuery 	+= " GROUP BY CT2DB.CT2_FILIAL, CT2DB.CT2_DATA, CT2DB.CT2_LOTE, CT2DB.CT2_SBLOTE, CT2DB.CT2_DOC, CT2DB.CT2_SEQLAN, CT2DB.CT2_EMPORI, CT2DB.CT2_FILORI, CT2DB.CT2_MOEDLC"

cQuery 	+= " UNION  "//Para nao apresentar chaves duplicadas

cQuery 	+= " SELECT CT2CR.CT2_FILIAL CT2_FILIAL, CT2CR.CT2_DATA CT2_DATA, CT2CR.CT2_LOTE CT2_LOTE, CT2CR.CT2_SBLOTE CT2_SBLOTE, CT2CR.CT2_DOC CT2_DOC, CT2CR.CT2_SEQLAN CT2_SEQLAN, CT2CR.CT2_EMPORI CT2_EMPORI, CT2CR.CT2_FILORI CT2_FILORI, CT2CR.CT2_MOEDLC CT2_MOEDLC"
cQuery 	+= " FROM "+RetSqlName("CT2")+" CT2CR , "+RetSqlName("CT2")+" HISC "
cQuery 	+= " WHERE "
//condicao para lancamentos a CREDITO na conta informada
cQuery 	+= " 	 CT2CR.CT2_FILIAL 	= '"+cxFilCT2+"'"
cQuery 	+= " AND CT2CR.CT2_DC IN ('2', '3')"  //CREDITO E PARTIDA DOBRADA
cQuery 	+= " AND CT2CR.CT2_CREDIT 	= '"+cConta+"'"
cQuery 	+= " AND CT2CR.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"'"
cQuery 	+= " AND CT2CR.CT2_MOEDLC 	= '01'" //moeda eh sempre na 01
cQuery 	+= " AND CT2CR.D_E_L_E_T_ 	= ' '"
//link/join com tabela de lançamentos com continuacao de historico
cQuery 	+= " AND CT2CR.CT2_FILIAL	= HISC.CT2_FILIAL"
cQuery 	+= " AND CT2CR.CT2_DATA		= HISC.CT2_DATA"
cQuery 	+= " AND CT2CR.CT2_LOTE		= HISC.CT2_LOTE"
cQuery 	+= " AND CT2CR.CT2_SBLOTE	= HISC.CT2_SBLOTE"
cQuery 	+= " AND CT2CR.CT2_DOC		= HISC.CT2_DOC"
cQuery 	+= " AND CT2CR.CT2_SEQLAN	= HISC.CT2_SEQLAN"
cQuery 	+= " AND CT2CR.CT2_EMPORI	= HISC.CT2_EMPORI"
cQuery 	+= " AND CT2CR.CT2_FILORI	= HISC.CT2_FILORI"
cQuery 	+= " AND CT2CR.CT2_MOEDLC	= HISC.CT2_MOEDLC"
//condicao da continuacao de historico
cQuery 	+= " AND HISC.CT2_FILIAL 	= '"+cxFilCT2+"'"
cQuery 	+= " AND HISC.CT2_MOEDLC 	= '01'" //moeda eh sempre na 01
cQuery 	+= " AND HISC.CT2_DC 		= '4'"  //4 = Continuacao de historico e as entidades contabeis estao em branco
cQuery 	+= " AND HISC.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"'"
cQuery 	+= " AND HISC.D_E_L_E_T_ 	= ' '"
cQuery 	+= " GROUP BY CT2CR.CT2_FILIAL, CT2CR.CT2_DATA, CT2CR.CT2_LOTE, CT2CR.CT2_SBLOTE, CT2CR.CT2_DOC, CT2CR.CT2_SEQLAN, CT2CR.CT2_EMPORI, CT2CR.CT2_FILORI, CT2CR.CT2_MOEDLC"
//Ordena pela chave do agrupamento
cQuery 	+= " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SEQLAN, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)
	
//laco para result da query
While (cAliasQry)->( ! Eof() )
    //a chave eh o proprio agrupamento da query e a data nao precisa ser feito tratamento com tcSetField pois ja retorna no formato caracter AAAAMMDD
	aAdd(_aChvLct, (cAliasQry)->CT2_FILIAL + (cAliasQry)->CT2_DATA + (cAliasQry)->CT2_LOTE + (cAliasQry)->CT2_SBLOTE + (cAliasQry)->CT2_DOC + (cAliasQry)->CT2_SEQLAN + (cAliasQry)->CT2_EMPORI + (cAliasQry)->CT2_FILORI + (cAliasQry)->CT2_MOEDLC )
	(cAliasQry)->( dbSkip() )

EndDo

(cAliasQry)->( dbCloseArea() )

Return