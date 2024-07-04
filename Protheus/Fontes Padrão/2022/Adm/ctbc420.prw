#Include "Ctbc420.ch"
#Include "PROTHEUS.Ch"
#Include "TCBrowse.ch"
#INCLUDE "DBINFO.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres


//-------------------------------------------------------------------
/*{Protheus.doc} CTBC420
Consulta de contas cont beis por Documento Fiscal

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBC420()
Local lGetFil	:= .F.

Private aSelFil	 := {} // Sera alimentada pela AdmGetFil

Private aRotina := MenuDef()
Private cCadastro  	:= STR0001  //"Consulta Razao por Doc. Fiscal"

If !Pergunte( "CTC420" , .T.)
	Return
EndIf	

// Seleciona filiais
If mv_par07 == 1
	aSelFil := AdmGetFil()
	If Empty(aSelFil)
		Return
	EndIf
End		

SetKey(VK_F12, { || If(Pergunte( "CTC420" , .T. ), If( mv_par07 == 1, aSelFil := AdmGetFil(),aSelFil := {} ),NIL) })
mBrowse(06, 01, 22, 75, "CT1")

SetKey(VK_F12, Nil)

dbSelectarea("CT1")
dbSetOrder(1)
dbSelectarea("CT2")
dbSetOrder(1)

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CT420Con
Envia para funcao que monta o arquivo de trabalho com as movimentacoes e mostra-o na tela  

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CT420Con()

Local aArea 	:= GetArea()
Local aSetOfBook:= CTBSetOf(mv_par05)
Local aBrowse	:={}
Local aCpos
Local aSize		:= MsAdvSize(,.F.,430)
Local aSizeAut 	:= MsAdvSize(), cArqTmp
Local aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 
Local aObjects	:= {	{ 375,  70, .T., .T. },;
						{ 100, 850, .T., .T., .T. },;
						{ 100, 100, .T., .T. } }
Local aPosObj 	:= MsObjSize( aInfo, aObjects, .T. )
Local cMascara1
Local cSepara1		:= ""
Local nAlias
Local nDecimais 	:= 0
Local nTotalDebito	:= 0
Local nTotalCredito := 0
Local nTotalSaldo	:= 0
Local nSaldoAnterior:= 0
Local nTamanho
Local ni
Local nCpo
Local oDlg
Local oBrw
Local oCOl 
Local cPictVal  := PesqPict("CT2","CT2_VALOR")
Local nX
Local cArq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ( CTC420 )              ³
//³ mv_par01            // da data                               ³
//³ mv_par02            // Ate a data                            ³
//³ mv_par03            // Moeda			                     	  ³   
//³ mv_par04            // Saldos		                          ³   
//³ mv_par05            // Set Of Books                          ³
//³ mv_par06            // Considera Doc Fiscal em Branco?       ³
//³ mv_par07            // Seleciona filiais ?                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par05) // Set Of Books
	Return(.F.)
EndIf 

If ( CT1->CT1_CLASSE == "1" )
   Help ( " ", 1, "CC010SINTE" )
   Return ( .F. )
End

//Validar se a moeda é Vazia ou Invalida
dbSelectArea("CTO")
dbSetOrder(1)
If Empty(mv_par03) .or. !dbSeek(xFilial("CTO")+mv_par03,.F.)
    Help(" ",1,"NOMOEDA")
	Return(.F.)
EndIf

nDecimais := CTbMoeda(mv_par03)[5]
nSaldoAnterior := SaldoCT7Fil(CT1->CT1_CONTA,mv_par01,mv_par03,mv_par04,,,,aSelFil)[6]	 

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTBR420Raz(	oMeter,oText,oDlg,lEnd,@cArqTmp,CT1->CT1_CONTA,CT1->CT1_CONTA,;
							mv_par03,mv_par01,mv_par02,CtbSetOf(""),.F.,mv_par04,"1",,,,,,,,,aSelFil)},;
							STR0006,;		// "Criando Arquivo Tempor rio..."
							STR0005)		// "Emissao do Razao"

RestArea(aArea)

aCpos := (cArqTmp->(DbStruct()))
If (cArqTmp->(Eof()))
   Help(" ", 1, "CC010SEMMO")
   //Nao colocar return falso pois após esse help inibe a tela mesmo vazia mas exibindo saldo das entidades, deve abrir a tela mesmo 
   //sem movimentos no periodo ou com saldo 0.
End

CTGerCplHis(@nSaldoAnterior, @nTotalSaldo, @nTotalDebito, @nTotalCredito,mv_par06 == 1)

cArqTmp->(DbSetOrder(0))
cArqTmp->(DbGoTop())
nAlias 	:= Select("cArqTmp")
aBrowse := {	{STR0007,"DATAL"},;
				{STR0008,	{ || cArqTmp->LOTE + cArqTmp->SUBLOTE + cArqTmp->DOC +;
							'/' + cArqTmp->LINHA } },;
				{RetTitle("CT2_KEY"), { || CT2KEY }, 10 },;
				{STR0009,"HISTORICO"},;
				{STR0010,"LANCDEB"},;
				{STR0011,"LANCCRD"},;
   				{STR0012,"SALDOSCR"},;
   				{STR0017,"TPSLDATU"},;
   				{"Filial","FILORI"}}

DEFINE 	MSDIALOG oDlg TITLE cCadastro;
		From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
SX3->(DbSetOrder(2))
SX3->(DbSeek("CT1_NORMAL"))
cCondA := Iif(nSaldoAnterior<0,"D","C")
@ 18, 04  SAY STR0013 + MascaraCTB(CT1->CT1_CONTA,cMascara1,,cSepara1) + " - " +;
AllTrim(Substr(&("CT1->CT1_DESC" + mv_par03),1,45)) +;
" - " + X3Titulo() + " - " + CT1->CT1_NORMAL PIXEL //"Conta - " 
@ 18,aPosObj[1][4] - 80 Say STR0014 +;
Transform(Abs(nSaldoAnterior),cPictVal) + " " + cCondA PIXEL //"Saldo Anterior "
SX3->(DbSetOrder(1))
@ 30,4 COLUMN BROWSE oBrw SIZE 	aPosObj[2][3],aPosObj[2][4] PIXEL OF oDlg
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

@aPosObj[3][1],04 Say STR0015	PIXEL   //"Totais da Conta"
@aPosObj[3][1] + 8,005  Say STR0013 + Trans(nTotalDebito,tm(nTotalDebito,17,nDecimais)) PIXEL		//"D‚bito "
@aPosObj[3][1] + 8,170  Say STR0014 + Trans(nTotalCredito,tm(nTotalCredito,17,nDecimais)) PIXEL  	//"Cr‚dito "
cCondF := Iif(nTotalSaldo<0,"D","C")			
@ aPosObj[3][1] + 8,aPosObj[1][4] - 60 Say STR0016+ Transform(ABS(nTotalSaldo),cPictVal) + " " + cCondF Pixel //"Saldo "
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

// Elimina arquivo de Trabalho
dbSelectArea("cArqTmp")
cArq := DbInfo(DBI_FULLPATH)
cArq := AllTrim(SubStr(cArq,Rat("\",cArq)+1))
DbCloseArea()
FErase(cArq)

dbSelectArea("CT1")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CT420Imp ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 28/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara a chamada para o relatorio CTBR400                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC400                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT420Imp()

Local aAreaCt1 := CT1->(GetArea())
Local aSelImp	:= {}

If ! Pergunte("CTC420", .T.)
	Return .F.
Endif

If mv_par07 == 1
	aSelImp := aClone(aSelFil)
EndIf  

CTBR420(CT1->CT1_CONTA, CT1->CT1_CONTA, mv_par01, mv_par02, mv_par03, mv_par04,;
		mv_par05,mv_par06,,aSelImp)
		
CT1->(RestArea(aAreaCt1))   
          
// Carrega novamente o grupo de perguntas utilizado na consulta
Pergunte("CTC420", .F.)

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
Private aRotina   	:= {	{STR0002,"AxPesqui",0,1},;  	//"Pesquisar"
                           	{STR0003,"CT420Con",0,2},;   	//"Visualizar"
                           	{STR0004,"CT420Imp",0,3}}    	//"Impressao"

Return(aRotina)

