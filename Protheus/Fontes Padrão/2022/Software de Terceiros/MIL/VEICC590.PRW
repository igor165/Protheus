// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 27     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "protheus.ch"
#Include "VEICC590.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VEICC590 ³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Consulta - Reg de Satisfacao / Insatisfacao do Cliente      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC590(xCodCli,xLojCli)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
Local nTam := 0
////////////////////////////////////////////////////////////////////////////////////////////
Private oTp0     := LoadBitmap( GetResources() , "qmt_no" )
Private oTp1     := LoadBitmap( GetResources() , "qmt_ok" )
Private oamarelo := LoadBitmap( GetResources() , "BR_amarelo" )
Private overde   := LoadBitmap( GetResources() , "BR_verde" )
Private ocinza   := LoadBitmap( GetResources() , "BR_cinza" )
Private olaranja := LoadBitmap( GetResources() , "BR_laranja" )
Private overmelho:= LoadBitmap( GetResources() , "BR_vermelho" )
Private oazull   := LoadBitmap( GetResources() , "BR_azul" )
Private cCodCli  := space(TamSX3("A1_COD")[1])
Private cLojCli  := space(TamSX3("A1_LOJA")[1])
Private cNomCli  := space(TamSX3("A1_NOME")[1])
Private dDtRecI  := ctod("01/"+strzero(month(dDatabase),2)+"/"+substr(strzero(year(dDatabase),4),3,2))
Private dDtRecF  := dDatabase
Private cUsuRec  := space(TamSX3("VAO_USUREC")[1])
Private cNomRec  := space(30)
Private cUsuRes  := space(TamSX3("VAO_USURES")[1])
Private cNomRes  := space(30)
Private dDtProI  := cTod("")
Private dDtProF  := dDatabase+365
Private dDtEncI  := cTod("")
Private dDtEncF  := dDatabase
Private cDepart  := space(TamSX3("VAO_DEPART")[1])
Private cNomDep  := space(TamSX3("VAP_DESDEP")[1])
Private aSituac  := {STR0002,STR0003,STR0004,STR0005}
Private cSituac  := STR0002
Private aStatus  := {STR0002,STR0006,STR0007}
Private cStatus  := STR0002
Private aOrdVet  := {STR0042,STR0043}
Private cOrdVet  := STR0042
Private aRegTp   := {"","1="+STR0040,"0="+STR0035}
Private cRegTp   := ""
Private cTipRec  := space(TamSX3("VAO_TIPREC")[1])
Private cNomTip  := space(TamSX3("VAQ_DESTIP")[1])
Private aTotCor  := {{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}
Private aVet     := {}
Private nDias    := 0
Private cSatisf  := "0"
Private cMemoObs := ""
Private lA1_IBGE := IIf(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Private oVCC590
Private o590LbVt
Default xCodCli  := cCodCli
Default xLojCli  := cLojCli
If !Empty(xCodCli)
	cCodCli := xCodCli // Parametros (Codigo Cliente)
	cLojCli := xLojCli // Parametros (Loja Cliente)
	SA1->(DbSetOrder(1))
	SA1->(DbSeek( xFilial("SA1") + xCodCli + xLojCli ))
	cNomCli := SA1->A1_NOME // Nome do Cliente
	dDtRecI := ctod("") // Total (datas)
EndIf

FS_VETOR()

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 75 , .T. , .F. } )  //Cabecalho
AAdd( aObjects, { 01, 10 , .T. , .T. } )  //list box superior
AAdd( aObjects, { 01, 78 , .T. , .F. } )  //list box inferior
// Fator de reducao de 0.95
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.95)
next
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oVCC590 TITLE STR0001 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

nTam := ( aPosObj[1,4] / 5 ) //varaivel que armazena o resutlado da divisao da tela.

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-080 LABEL ("") OF oVCC590 PIXEL

@ aPosObj[1,1]+006,005 SAY STR0008 SIZE 45,40 OF oVCC590  PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+005,049 MSGET o590CdCli VAR cCodCli F3 "SA1" VALID FS_VCC590("CL") PICTURE PesqPict("SA1","A1_COD") SIZE 20,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+005,082 MSGET o590LjCli VAR cLojCli VALID FS_VCC590("CL") PICTURE PesqPict("SA1","A1_LOJA") SIZE 8,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+005,0108 MSGET o590NmCli VAR cNomCli PICTURE "@!" SIZE (nTam*2.3)-105,8 OF oVCC590 PIXEL COLOR CLR_BLUE WHEN .f.
@ aPosObj[1,1]+006,aPosObj[1,2]+(nTam*2.3)+004 SAY STR0041 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+005,aPosObj[1,2]+(nTam*2.3)+053 MSCOMBOBOX o590OdVet VAR cOrdVet ITEMS aOrdVet SIZE 60,08 OF oVCC590 PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+017,005 SAY STR0009 SIZE 65,40 OF oVCC590  PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+016,049 MSGET o590DRcI VAR dDtRecI PICTURE "@D" SIZE 40,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+017,090 SAY STR0010 SIZE 45,40 OF oVCC590  PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+016,101 MSGET o590DRcF VAR dDtRecF VALID(dDtRecF>=dDtRecI) PICTURE "@D" SIZE 40,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+017,aPosObj[1,2]+(nTam*2.3)+004 SAY STR0011 SIZE 45,40 OF oVCC590  PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+016,aPosObj[1,2]+(nTam*2.3)+053 MSGET o590UsRc VAR cUsuRec PICTURE PesqPict("VAO","VAO_USUREC") F3 "USR" VALID FS_VCC590("UR") SIZE 30,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+016,aPosObj[1,2]+(nTam*2.3)+086 MSGET o590NmRc VAR cNomRec PICTURE "@!" SIZE 51,8 OF oVCC590 PIXEL COLOR CLR_BLUE WHEN .f.

@ aPosObj[1,1]+028,005 SAY STR0012 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+027,049 MSGET o590DPrI VAR dDtProI PICTURE "@D" SIZE 40,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+028,090 SAY STR0010 SIZE 45,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+027,101 MSGET o590DPrF VAR dDtProF VALID(dDtProF>=dDtProI) PICTURE "@D" SIZE 40,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+028,aPosObj[1,2]+(nTam*2.3)+004 SAY STR0014 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+027,aPosObj[1,2]+(nTam*2.3)+053 MSGET o590UsRs VAR cUsuRes PICTURE PesqPict("VAO","VAO_USURES") F3 "USR" VALID FS_VCC590("US") SIZE 30,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+027,aPosObj[1,2]+(nTam*2.3)+086 MSGET o590NmRs VAR cNomRes PICTURE "@!" SIZE 51,8 OF oVCC590 PIXEL COLOR CLR_BLUE WHEN .f.

@ aPosObj[1,1]+039,005 SAY STR0013 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+038,049 MSGET o590DEcI VAR dDtEncI PICTURE "@D" SIZE 40,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+039,090 SAY STR0010 SIZE 45,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+039,101 MSGET o590DEcF VAR dDtEncF VALID(dDtEncF>=dDtEncI) PICTURE "@D" SIZE 40,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+039,aPosObj[1,2]+(nTam*2.3)+004 SAY STR0017 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+038,aPosObj[1,2]+(nTam*2.3)+053 MSCOMBOBOX o590Sit VAR cSituac ITEMS aSituac SIZE 84,08 OF oVCC590 PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+050,005 SAY STR0015 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+049,049 MSGET o590Dep VAR cDepart F3 "VAP" VALID FS_VCC590("DP") PICTURE PesqPict("VAO","VAO_DEPART") SIZE 20,8 OF oVCC590 PIXEL COLOR CLR_BLUE


@ aPosObj[1,1]+049,079 MSGET o590NmDp VAR cNomDep PICTURE "@!" SIZE 63,8 OF oVCC590 PIXEL COLOR CLR_BLUE WHEN .f.
@ aPosObj[1,1]+050,aPosObj[1,2]+(nTam*2.3)+004 SAY STR0018 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+049,aPosObj[1,2]+(nTam*2.3)+053 MSCOMBOBOX o590Stat VAR cStatus ITEMS aStatus SIZE 84,08 OF oVCC590 PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+061,005 SAY STR0016 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+060,049 MSGET o590TpRc VAR cTipRec F3 "VAQ" VALID FS_VCC590("TP") PICTURE PesqPict("VAO","VAO_TIPREC") SIZE 20,8 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+060,079 MSGET o590NmTp VAR cNomTip PICTURE "@!" SIZE 63,8 OF oVCC590 PIXEL COLOR CLR_BLUE WHEN .f.
@ aPosObj[1,1]+061,aPosObj[1,2]+(nTam*2.3)+004 SAY STR0039 SIZE 65,40 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[1,1]+060,aPosObj[1,2]+(nTam*2.3)+053 MSCOMBOBOX o590RgTp VAR cRegTp ITEMS aRegTp SIZE 60,08 OF oVCC590 PIXEL COLOR CLR_BLUE

@ aPosObj[1,1]+011,aPosObj[1,4]-68 BUTTON o590Filt PROMPT (STR0019) OF oVCC590 SIZE 60,10 PIXEL  ACTION (FS_FILTRAR(),FS_OBSVC590())
@ aPosObj[1,1]+022,aPosObj[1,4]-68 BUTTON o590CM600 PROMPT (STR0020) OF oVCC590 SIZE 60,10 PIXEL  ACTION VEICM600()
@ aPosObj[1,1]+033,aPosObj[1,4]-68 BUTTON o590BAlt PROMPT (STR0074) OF oVCC590 SIZE 60,10 PIXEL  ACTION FS_ALTERAR()
@ aPosObj[1,1]+044,aPosObj[1,4]-68 BUTTON o590BVis PROMPT (STR0075) OF oVCC590 SIZE 60,10 PIXEL  ACTION FS_VISUAL()
@ aPosObj[1,1]+055,aPosObj[1,4]-68 BUTTON o590CM500 PROMPT (STR0021) OF oVCC590 SIZE 60,10 PIXEL  ACTION VEICM500()
@ aPosObj[1,1]+066,aPosObj[1,4]-68 BUTTON o590Impr PROMPT (STR0022) OF oVCC590 SIZE 60,10 PIXEL ACTION FS_IMPRIMIR(aVet[o590LbVt:nAt,10],aVet[o590LbVt:nAt,2],aVet[o590LbVt:nAt,19])
@ aPosObj[1,1]+000,aPosObj[1,4]-68 BUTTON o590Sair PROMPT  (STR0023) OF oVCC590 SIZE 60,10 PIXEL ACTION oVCC590:End()

@ aPosObj[2,1],aPosObj[2,2] LISTBOX o590LbVt FIELDS HEADER "","",STR0024,STR0025,STR0026,STR0027,STR0028,STR0029,STR0030,STR0031,STR0032,STR0078,STR0033,STR0034,STR0077 ;
									COLSIZES 10,10,30,30,30,30,53,50,40,40,30,110,70,35,90 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oVCC590 PIXEL ON CHANGE FS_OBSVC590()
o590LbVt:SetArray(aVet)
o590LbVt:bLine := { || {IIf(aVet[o590LbVt:nAt,15]<>"1",oTp0,oTp1),;
IIf(aVet[o590LbVt:nAt,1]=="la",olaranja,IIf(aVet[o590LbVt:nAt,1]=="vm",overmelho,IIf(aVet[o590LbVt:nAt,1]=="az",oazull,IIf(aVet[o590LbVt:nAt,1]=="cz",ocinza,IIf(aVet[o590LbVt:nAt,1]=="am",oamarelo,overde))))),;
aVet[o590LbVt:nAt,2] ,;
aVet[o590LbVt:nAt,3] ,;
aVet[o590LbVt:nAt,4] ,;
aVet[o590LbVt:nAt,5] ,;
aVet[o590LbVt:nAt,6] ,;
aVet[o590LbVt:nAt,7] ,;
aVet[o590LbVt:nAt,8] ,;
aVet[o590LbVt:nAt,9] ,;
aVet[o590LbVt:nAt,10]+" "+aVet[o590LbVt:nAt,11] ,;  
aVet[o590LbVt:nAt,18] ,;
aVet[o590LbVt:nAt,12] ,;
aVet[o590LbVt:nAt,13] ,;
aVet[o590LbVt:nAt,17] }}

@ aPosObj[3,1],aPosObj[3,2] GET oMemoObs VAR cMemoObs OF oVCC590 MEMO SIZE aPosObj[3,4]-300,aPosObj[3,3]-aPosObj[3,1] PIXEL READONLY MEMO

//
@ aPosObj[3,1]+001,aPosObj[3,4]-264 BITMAP O1XTit RESOURCE "qmt_ok" OF oVCC590 PIXEL NOBORDER SIZE 15,15 when .f.
@ aPosObj[3,1]+004,aPosObj[3,4]-248 SAY STR0040 SIZE 100,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+003,aPosObj[3,4]-209 MSGET o1Total VAR aTotCor[1,1] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
//
@ aPosObj[3,1]+022,aPosObj[3,4]-294 SAY STR0003 SIZE 40,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+021,aPosObj[3,4]-263 MSGET o1TotAb VAR aTotCor[1,2] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+017,aPosObj[3,4]-233 BITMAP O1Xazull RESOURCE "BR_azul" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+017,aPosObj[3,4]-224 SAY (STR0006) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+016,aPosObj[3,4]-177 MSGET o1azul VAR aTotCor[1,11] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+026,aPosObj[3,4]-233 BITMAP O1Xvermelho RESOURCE "BR_vermelho" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+026,aPosObj[3,4]-224 SAY (STR0007) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+025,aPosObj[3,4]-177 MSGET o1verm VAR aTotCor[1,12] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[3,1]+043,aPosObj[3,4]-294 SAY STR0004 SIZE 40,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+042,aPosObj[3,4]-263 MSGET o1TotPr VAR aTotCor[1,3] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+038,aPosObj[3,4]-233 BITMAP O1Xcinza RESOURCE "BR_cinza" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+038,aPosObj[3,4]-224 SAY (STR0006) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+037,aPosObj[3,4]-177 MSGET o1cinz VAR aTotCor[1,9] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+047,aPosObj[3,4]-233 BITMAP O1Xlaranja RESOURCE "BR_laranja" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+047,aPosObj[3,4]-224 SAY (STR0007) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+046,aPosObj[3,4]-177 MSGET o1lara VAR aTotCor[1,10] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[3,1]+064,aPosObj[3,4]-294 SAY STR0005 SIZE 40,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+063,aPosObj[3,4]-263 MSGET o1TotEn VAR aTotCor[1,4] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+059,aPosObj[3,4]-233 BITMAP O1Xverde RESOURCE "BR_verde" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+059,aPosObj[3,4]-224 SAY (STR0006) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+058,aPosObj[3,4]-177 MSGET o1verd VAR aTotCor[1,7] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+068,aPosObj[3,4]-233 BITMAP O1Xamarelo RESOURCE "BR_amarelo" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+068,aPosObj[3,4]-224 SAY (STR0007) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+067,aPosObj[3,4]-177 MSGET o1amar VAR aTotCor[1,8] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
//
@ aPosObj[3,1]+001,aPosObj[3,4]-115 BITMAP O2XTit RESOURCE "qmt_no" OF oVCC590 PIXEL NOBORDER SIZE 15,15 when .f.
@ aPosObj[3,1]+004,aPosObj[3,4]-099 SAY STR0035 SIZE 100,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+003,aPosObj[3,4]-060 MSGET o2Total VAR aTotCor[2,1] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
//
@ aPosObj[3,1]+022,aPosObj[3,4]-145 SAY STR0003 SIZE 40,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+021,aPosObj[3,4]-114 MSGET o2TotAb VAR aTotCor[2,2] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+017,aPosObj[3,4]-084 BITMAP O2Xazull RESOURCE "BR_azul" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+017,aPosObj[3,4]-075 SAY (STR0006) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+016,aPosObj[3,4]-028 MSGET o2azul VAR aTotCor[2,11] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+026,aPosObj[3,4]-084 BITMAP O2Xvermelho RESOURCE "BR_vermelho" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+026,aPosObj[3,4]-075 SAY (STR0007) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+025,aPosObj[3,4]-028 MSGET o2verm VAR aTotCor[2,12] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[3,1]+043,aPosObj[3,4]-145 SAY STR0004 SIZE 40,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+042,aPosObj[3,4]-114 MSGET o2TotPr VAR aTotCor[2,3] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+038,aPosObj[3,4]-084 BITMAP O2Xcinza RESOURCE "BR_cinza" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+038,aPosObj[3,4]-075 SAY (STR0006) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+037,aPosObj[3,4]-028 MSGET o2cinz VAR aTotCor[2,9] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+047,aPosObj[3,4]-084 BITMAP O2Xlaranja RESOURCE "BR_laranja" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+047,aPosObj[3,4]-075 SAY (STR0007) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+046,aPosObj[3,4]-028 MSGET o2lara VAR aTotCor[2,10] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[3,1]+064,aPosObj[3,4]-145 SAY STR0005 SIZE 40,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+063,aPosObj[3,4]-114 MSGET o2TotEn VAR aTotCor[2,4] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+059,aPosObj[3,4]-084 BITMAP O2Xverde RESOURCE "BR_verde" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+059,aPosObj[3,4]-075 SAY (STR0006) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+058,aPosObj[3,4]-028 MSGET o2verd VAR aTotCor[2,7] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.
@ aPosObj[3,1]+068,aPosObj[3,4]-084 BITMAP O2Xamarelo RESOURCE "BR_amarelo" OF oVCC590 PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[3,1]+068,aPosObj[3,4]-075 SAY (STR0007) SIZE 80,10 OF oVCC590 PIXEL COLOR CLR_BLUE
@ aPosObj[3,1]+067,aPosObj[3,4]-028 MSGET o2amar VAR aTotCor[2,8] PICTURE "@R 999999" SIZE 18,3 OF oVCC590 PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[3,1]+000,aPosObj[3,4]-297 TO aPosObj[3,1]+078,aPosObj[3,4]-149 LABEL "" OF oVCC590 PIXEL
@ aPosObj[3,1]+015,aPosObj[3,4]-297 TO aPosObj[3,1]+036,aPosObj[3,4]-149 LABEL "" OF oVCC590 PIXEL
@ aPosObj[3,1]+036,aPosObj[3,4]-297 TO aPosObj[3,1]+057,aPosObj[3,4]-149 LABEL "" OF oVCC590 PIXEL
@ aPosObj[3,1]+057,aPosObj[3,4]-297 TO aPosObj[3,1]+078,aPosObj[3,4]-149 LABEL "" OF oVCC590 PIXEL

@ aPosObj[3,1]+000,aPosObj[3,4]-148 TO aPosObj[3,1]+078,aPosObj[3,4]-000 LABEL "" OF oVCC590 PIXEL
@ aPosObj[3,1]+015,aPosObj[3,4]-148 TO aPosObj[3,1]+036,aPosObj[3,4]-000 LABEL "" OF oVCC590 PIXEL
@ aPosObj[3,1]+036,aPosObj[3,4]-148 TO aPosObj[3,1]+057,aPosObj[3,4]-000 LABEL "" OF oVCC590 PIXEL
@ aPosObj[3,1]+057,aPosObj[3,4]-148 TO aPosObj[3,1]+078,aPosObj[3,4]-000 LABEL "" OF oVCC590 PIXEL

ACTIVATE MSDIALOG oVCC590 CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_VETOR ³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Adiciona no Vetor de Satisfacao e Insatisfacao              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VETOR()
Local lOk         := .f.
Local nTp         := 0
Local dPz         := cTod("")
Local cTpCor      := ""
Local cCor        := ""


Local cOrigem     := ""
Local cQuery      := ""
Local cSQLAlias   := "SQLALIAS"
Local lVAQ_TIPOSI := ( VAQ->(FieldPos("VAQ_TIPOSI")) > 0 )
Local lVAO_ORIGEM := ( VAO->(FieldPos("VAO_ORIGEM")) > 0 )
//
aVet    := {}
aTotCor := {{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}
//
cQuery := "SELECT VAO.R_E_C_N_O_ RECVAO "
cQuery += "FROM "+RetSQLName("VAO")+" VAO "
cQuery += "WHERE VAO.VAO_FILIAL='"+xFilial("VAO")+"' AND "
If !Empty(cCodCli+cLojCli)
	cQuery += "VAO.VAO_CODCLI='"+cCodCli+"' AND VAO.VAO_LOJCLI='"+cLojCli+"' AND "
EndIf
If !Empty(cUsuRec)
	cQuery += "VAO.VAO_USUREC='"+cUsuRec+"' AND "
EndIf
If !Empty(cUsuRes)
	cQuery += "VAO.VAO_USURES='"+cUsuRes+"' AND "
EndIf
If !Empty(cDepart)
	cQuery += "VAO.VAO_DEPART='"+cDepart+"' AND "
EndIf
If !Empty(cTipRec)
	cQuery += "VAO.VAO_TIPREC='"+cTipRec+"' AND "
EndIf
cQuery += "VAO.VAO_DATREC>='"+dtos(dDtRecI)+"' AND VAO.VAO_DATREC<='"+dtos(dDtRecF)+"' AND "
cQuery += "VAO.VAO_DATPRO>='"+dtos(dDtProI)+"' AND VAO.VAO_DATPRO<='"+dtos(dDtProF)+"' AND "
cQuery += "VAO.VAO_DATENC>='"+dtos(dDtEncI)+"' AND VAO.VAO_DATENC<='"+dtos(dDtEncF)+"' AND "
cQuery += "VAO.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	//
	DbSelectArea("VAO")
	DbGoTo( (cSQLAlias)->( RECVAO ) ) 
	//
	If Empty(cDepart)
		DbSelectArea("VAP")
		DbSetOrder(1)
		DbSeek( xFilial("VAP") + VAO->VAO_DEPART )
	EndIf
	cTpCor := ""
	nTp    := 2
	DbSelectArea("VAQ")
	DbSetOrder(1)
	DbSeek( xFilial("VAQ") + VAO->VAO_TIPREC )
	If lVAQ_TIPOSI
		If !Empty(cRegTp)
			If cRegTp == "1" .and. VAQ->VAQ_TIPOSI <> "1" // Escolheu: Satisfacao
				(cSQLAlias)->(dbSkip())
				Loop
			ElseIf cRegTp == "0" .and. VAQ->VAQ_TIPOSI == "1" // Escolheu: Insatisfacao
				(cSQLAlias)->(dbSkip())
				Loop
			EndIf
		EndIf
		cTpCor := VAQ->VAQ_TIPOSI
		If VAQ->VAQ_TIPOSI == "1"
			nTp := 1
		EndIf
	EndIf
	lOk   := .f.
	dPz   := cTod("")
	cCor  := ""
	nDias := VAP->VAP_PRARES
	If !Empty(VAO->VAO_DATENC)
		If cSituac == STR0002 .or. cSituac == STR0005
			If !Empty(VAO->VAO_DATPRO)
				dPz := VAO->VAO_DATPRO + nDias
				If VAO->VAO_DATENC <= dPz
					If cStatus == STR0002 .or. cStatus == STR0006 // Encerrado - Dentro do Prazo
						aTotCor[nTp,7]++
						lOk     := .t.
						cCor    := "vd" 
						cSatisf := "3"
					EndIf
				Else
					If cStatus == STR0002 .or. cStatus == STR0007 // Encerrado - Em Atraso
						aTotCor[nTp,8]++
						lOk     := .t.
						cCor    := "am"
						cSatisf := "3"
					EndIf
				EndIf
			Else
				dPz := VAO->VAO_DATREC + nDias
				If VAO->VAO_DATENC <= dPz
					If cStatus == STR0002 .or. cStatus == STR0006 // Encerrado - Dentro do Prazo
						aTotCor[nTp,7]++
						lOk     := .t.
						cCor    := "vd"
						cSatisf := "3"
					EndIf
				Else
					If cStatus == STR0002 .or. cStatus == STR0007 // Encerrado - Em Atraso
						aTotCor[nTp,8]++
						lOk     := .t.
						cCor    := "am"
						cSatisf := "3"
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf !Empty(VAO->VAO_DATPRO)
		If cSituac == STR0002 .or. cSituac == STR0004
			dPz := VAO->VAO_DATPRO + nDias
			If dDataBase <= dPz
				If cStatus == STR0002 .or. cStatus == STR0006  // Prorrogado - Dentro do Prazo
					aTotCor[nTp,9]++
					lOk     := .t.
					cCor    := "cz"
					cSatisf := "2"
				EndIf
			Else
				If cStatus == STR0002 .or. cStatus == STR0007 // Prorrogado - Em Atraso
					aTotCor[nTp,10]++
					lOk     := .t.
					cCor    := "la"
					cSatisf := "2"
				EndIf
			EndIf
		EndIf
	Else
		If cSituac == STR0002 .or. cSituac == STR0003
			dPz := VAO->VAO_DATREC + nDias
			If dDataBase <= dPz
				If cStatus == STR0002 .or. cStatus == STR0006 // Em Aberto - Dentro do Prazo
					aTotCor[nTp,11]++
					lOk     := .t.
					cCor    := "az"
					cSatisf := "1"
				EndIf
			Else
				If cStatus == STR0002 .or. cStatus == STR0007 // Em Aberto - Em Atraso
					aTotCor[nTp,12]++
					lOk     := .t.
					cCor    := "vm"
					cSatisf := "1"
				EndIf
			EndIf
		EndIf
	EndIf
	If lOk
		If Empty(cCodCli+cLojCli)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + VAO->VAO_CODCLI + VAO->VAO_LOJCLI )
			If lA1_IBGE
				DbSelectArea("VAM")
				DbSetOrder(1)
				DbSeek( xFilial("VAM") + SA1->A1_IBGE )
			EndIf
		EndIf
		cOrigem := ""
		If lVAO_ORIGEM .and. !Empty(VAO->VAO_ORIGEM)
			cOrigem := X3CBOXDESC("VAO_TIPORI",VAO->VAO_TIPORI)+" ( "+Alltrim(VAO->VAO_ORIGEM)+" )"
		EndIf   
		if SA1->(FieldPos("A1_CELULAR")) > 0  
			if !Empty(SA1->A1_CELULAR)
				cCelular := " / "+SA1->A1_CELULAR
			Else
				cCelular := ""
			Endif	
		Else
			cCelular := ""
		Endif	
		Aadd(aVet,{cCor,VAO->VAO_DATREC,VAO->VAO_DATPRO,dPz,VAO->VAO_DATENC,VAP->VAP_DESDEP,VAQ->VAQ_DESTIP,UsrRetName(VAO->VAO_USUREC),UsrRetName(VAO->VAO_USURES),VAO->VAO_CODCLI+"-"+VAO->VAO_LOJCLI,left(SA1->A1_NOME,35),IIf(lA1_IBGE,Alltrim(left(VAM->VAM_DESCID,25))+"-"+VAM->VAM_ESTADO,Alltrim(left(SA1->A1_MUN,25))+"-"+SA1->A1_EST),"("+SA1->A1_DDD+") "+Alltrim(SA1->A1_TEL)+cCelular,VAO->VAO_RECLAO,cTpCor,cSatisf,cOrigem,VAO->VAO_SEQUEN,VAO->(RECNO()),VAO->VAO_FILORI+VAO->VAO_ORIGEM,VAO->VAO_TIPORI,VAO->VAO_CMPASS,VAO->VAO_CORESP,VAO->VAO_CAUPRB,VAO->VAO_APOCOR})
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VAO")
For nTp := 1 to 2
	aTotCor[nTp,02] := aTotCor[nTp,11] + aTotCor[nTp,12]						// Aberto
	aTotCor[nTp,03] := aTotCor[nTp,09] + aTotCor[nTp,10]						// Prorrogado
	aTotCor[nTp,04] := aTotCor[nTp,07] + aTotCor[nTp,08]						// Encerrado
	aTotCor[nTp,05] := aTotCor[nTp,11] + aTotCor[nTp,09] + aTotCor[nTp,07]	// Dentro do Prazo
	aTotCor[nTp,06] := aTotCor[nTp,12] + aTotCor[nTp,10] + aTotCor[nTp,08]	// Em Atraso
	aTotCor[nTp,01] := aTotCor[nTp,05] + aTotCor[nTp,06]						// Total Geral
Next
If len(aVet) <= 0
	Aadd(aVet,{"",cTod(""),cTod(""),cTod(""),cTod(""),"","","","","","","","","","0","0","","",0,""})
Else          
	if cOrdVet == STR0042 
		aSort(aVet,1,,{|x,y| Dtos(x[4])+Dtos(x[2])+x[8]+x[10] > Dtos(y[4])+Dtos(y[2])+y[8]+y[10] })
	Else
		aSort(aVet,1,,{|x,y| x[10]+Dtos(x[4])+Dtos(x[2])+x[8] < y[10]+Dtos(y[4])+Dtos(y[2])+y[8] })
	Endif	
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_FILTRAR³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Filtro - chama montagem do Vetor de Satisf. / Insatisf.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR()
cMemoObs := ""
oMemoObs:Refresh()
o590LbVt:nAt := 1
FS_VETOR()
o590LbVt:SetArray(aVet)
o590LbVt:bLine := { || {IIf(aVet[o590LbVt:nAt,15]<>"1",oTp0,oTp1),;
IIf(aVet[o590LbVt:nAt,1]=="la",olaranja,IIf(aVet[o590LbVt:nAt,1]=="vm",overmelho,IIf(aVet[o590LbVt:nAt,1]=="az",oazull,IIf(aVet[o590LbVt:nAt,1]=="cz",ocinza,IIf(aVet[o590LbVt:nAt,1]=="am",oamarelo,overde))))),;
aVet[o590LbVt:nAt,2] ,;
aVet[o590LbVt:nAt,3] ,;
aVet[o590LbVt:nAt,4] ,;
aVet[o590LbVt:nAt,5] ,;
aVet[o590LbVt:nAt,6] ,;
aVet[o590LbVt:nAt,7] ,;
aVet[o590LbVt:nAt,8] ,;
aVet[o590LbVt:nAt,9] ,;
aVet[o590LbVt:nAt,10]+" "+aVet[o590LbVt:nAt,11] ,;
aVet[o590LbVt:nAt,18] ,;
aVet[o590LbVt:nAt,12] ,;
aVet[o590LbVt:nAt,13] ,;
aVet[o590LbVt:nAt,17] }}
o590LbVt:SetFocus()
o590LbVt:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_VCC590 ³ Autor ³ Andre Luis Almeida     ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Validacoes da Tela VEICC590                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VCC590(cTipo)
Local lRet := .f.
If cTipo == "CL"	// Verifica Cliente+Loja
	cNomCli := space(TamSX3("A1_NOME")[1])
	If Empty(cCodCli)
		cLojCli := space(TamSX3("A1_LOJA")[1])
	EndIf
	If !Empty(cCodCli+cLojCli)
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek( xFilial("SA1") + Alltrim(cCodCli+cLojCli) , .f. )
			cNomCli := SA1->A1_NOME
			lRet := .t.
			If lA1_IBGE
				DbSelectArea("VAM")
				DbSetOrder(1)
				DbSeek( xFilial("VAM") + SA1->A1_IBGE )
			EndIf
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTipo == "DP"	// Verifica Departamento
	cNomDep := space(TamSX3("VAP_DESDEP")[1])
	If !Empty(cDepart)
		DbSelectArea("VAP")
		DbSetOrder(1)
		If DbSeek( xFilial("VAP") + cDepart , .f. )
			cNomDep := VAP->VAP_DESDEP
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTipo == "TP"	// Verifica Tipo de Reclamacao
	cNomTip := space(TamSX3("VAQ_DESTIP")[1])
	If !Empty(cTipRec)
		DbSelectArea("VAQ")
		DbSetOrder(1)
		If DbSeek( xFilial("VAQ") + cTipRec , .f. )
			cNomTip := VAQ->VAQ_DESTIP
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTipo == "UR"	// Nome do Usuario Reclamacao
	cNomRec := space(30)
	If !Empty(cUsuRec)
		If UsrExist(cUsuRec)
			cNomRec := UsrRetName(cUsuRec)
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
ElseIf cTipo == "US"	// Nome do Usuario Responsavel
	cNomRes := space(30)
	If !Empty(cUsuRes)
		If UsrExist(cUsuRes)
			cNomRes := UsrRetName(cUsuRes)
			lRet := .t.
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_OBSVC590³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Atualiza variaveis de Observacao na TELA                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSVC590()
o590LbVt:SetFocus()
cMemoObs:=MSMM(aVet[o590LbVt:nAt,14],47)
oMemoObs:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³FS_IMPRIMIR³ Autor ³ Andre Luis Almeida    ³ Data ³ 10/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Impressao da Lista Satisfacao / Insatisfacao do Cliente     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_IMPRIMIR(cCliente,dDatRec,cRecno) 

If ExistBlock("M_RAICESP") 
	If Aviso(STR0081,STR0076,{STR0079,STR0080},1,,1) == 1 // "Atenção" - "Deseja Imprimir o Relatório Padrão ou Especifico?" - "Padrão" - "Específico"
		FS_IMPREL(cCliente,dDatRec) // Versao anterior
	Else 
		ExecBlock("M_RAICESP",.f.,.f.,{cCliente,dDatRec,cRecno})
	Endif	
Else
	FS_IMPREL(cCliente,dDatRec) // Versao anterior
Endif	

Return(.t.)

Static Function FS_IMPREL(cCliente,dDatRec)
  
Local   cDesc1	 := ""
Local   cDesc2	 := ""
Local   cDesc3	 := ""
Local   cAlias	 := "VAO"

Local i := 0     

Local cFunAbe := ""
Local cNumOsv := ""
Local   ni      := 0
Local   nx      := 0
Local   nt      := 0
Local	nContRs	:= 0
Local	nContDep:= 0
Local	nContTp := 0

Local   lx      := .f.
Local cChassi  := ""
Local cCodMar  := ""
Local cDesMod  := ""
Local cDescri  := ""
Local cPlaVei  := ""
Local cFabMod  := ""
Local cCli     := ""
Local cFone    := ""
Private nLin 	 := 1
Private aReturn := {STR0036,1,STR0037,1,2,1,"",1}
Private cTamanho:= "G"           // P/M/G
Private Limite  := 220           // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := STR0001
Private cNomProg:= "VEICC590"
Private cNomeRel:= "VEICC590"
Private nLastKey:= 0
Private cabec1  := space(6)+STR0038
Private cabec2  := ""
Private nCaracter:=15
Private cbTxt   := Space(10)
Private cbCont  := 0
Private cString := "VAO"
Private Li      := 220
Private m_Pag   := 1
Private lAbortPrint := .f.
Private cPerg   :="VCC590"
Private nQtd	:= 0
Private nTotAber:= 0
Private nTotPror:= 0
Private nTotEnce:= 0
Private nRaicAbe:= 0
Private nRaicPro:= 0
Private nRaicEnc:= 0
Private aImpRes	:= {}
Private aDepPas	:= {}
Private cDepart	:= ""

CriaSX1()

Pergunte("VCC590",.f.)

cNomeRel := SetPrint(cAlias,cNomeRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf
SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

If MV_PAR02 == 3 //Resumido
	cabec1 := STR0060 + " " + DtoC(dDtRecI) + " " + STR0010 + " " + DtoC(dDtRecF)
EndIf
nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1

aSort(aVet,1,,{|x,y| x[15]+x[16]+x[1] > y[15]+y[16]+y[1] })
cSat    := ""
cStatus := ""
cSit    := ""

If MV_PAR02 == 3 //Resumido
	
	For nContRs := 1 to Len(aVet)
		
		nPos := aScan(aImpRes,{|x| x[2]+x[3]+x[8] == aVet[nContRs,6]+aVet[nContRs,7]+aVet[nContRs,15]})
		
		If nPos == 0
			nQtd 	:= 1
			If aVet[nContRs,16] == "1" //Em Aberto
				nRaicAbe := 1
			ElseIf aVet[nContRs,16] == "2" //Prorrogado
				nRaicPro := 1
			ElseIf aVet[nContRs,16] == "3" //Encerrado
				nRaicEnc := 1
			EndIf
			If aVet[nContRs,15] == "1" //Satisfação
				aadd(aImpRes,{STR0040+"  ",aVet[nContRs,6],aVet[nContRs,7],nQtd,nRaicAbe,nRaicPro,nRaicEnc,aVet[nContRs,15]})
			Else //Insatisfação
				aadd(aImpRes,{STR0035,aVet[nContRs,6],aVet[nContRs,7],nQtd,nRaicAbe,nRaicPro,nRaicEnc,aVet[nContRs,15]})
			EndIf
		Else
			aImpRes[nPos,4] += 1
			If aVet[nContRs,16] == "1" //Em Aberto
				aImpRes[nPos,5] += 1
			ElseIf aVet[nContRs,16] == "2" //Prorrogado
				aImpRes[nPos,6] += 1
			ElseIf aVet[nContRs,16] == "3" //Encerrado
				aImpRes[nPos,7] += 1
			EndIf
		EndIf
		
		nRaicAbe := 0
		nRaicPro := 0
		nRaicEnc := 0
		
	Next
	
	aSort(aImpRes,1,,{|x,y| x[2]+x[1] < y[2]+y[1] })
	
	For nContDep := 1 to Len(aImpRes)
		If nLin >= 58
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		
		cDepart := aImpRes[nContDep,2]
		
		nPos2 := aScan(aDepPas,{|x| x[1] == aImpRes[nContDep,2]})
		
		If nPos2 == 0
			
			@ nLin++,00 psay STR0015 + " " + aImpRes[nContDep,2]
			@ nLin++,27 psay STR0029 + space(18) + STR0058
			aadd(aDepPas,{aImpRes[nContDep,2]})
			
			For nContTp := 1 to Len(aImpRes)
				
				If aImpRes[nContTp,2] == cDepart
					@ nLin++,14 psay aImpRes[nContTp,1] + " " + Left(aImpRes[nContTp,3],20) + " " + Transform(aImpRes[nContTp,4],"99999")
					nTotAber += aImpRes[nContTp,5]
					nTotPror += aImpRes[nContTp,6]
					nTotEnce += aImpRes[nContTp,7]
				EndIf
				
			Next
			nLin++
			@ nLin++,14 psay STR0059
			@ nLin++,21 psay STR0003 + space(18) + Transform(nTotAber,"99999") //Total Em Aberto
			@ nLin++,21 psay STR0004 + space(17) + Transform(nTotPror,"99999") //Total Prorrogado
			@ nLin++,21 psay STR0005 + space(18) + Transform(nTotEnce,"99999") //Total Encerrado
			nLin++
			nLin++
		EndIf
		nTotAber := 0
		nTotPror := 0
		nTotEnce := 0
	Next
Else
	
	For ni:=1 to Len(aVet)
		If nLin >= 55
			nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		EndIf
		
		if aVet[ni,21] == "1" // Atendimento Veiculo
			dbSelectArea("VV0")
			dbSetOrder(1)
			dbSeek(aVet[ni,20]) 
			dbSelectArea("VVA")
			dbSetOrder(1)
			dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA) 
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+VVA->VVA_CHAINT) 
			FGX_VV2()
			dbSelectArea("VVC")
			dbSetOrder(1)
			dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
			cChassi  := VV1->VV1_CHASSI
			cCodMar  := VV1->VV1_CODMAR
			cDesMod  := VV2->VV2_DESMOD
			cDescri  := VVC->VVC_DESCRI
			cPlaVei  := VV1->VV1_PLAVEI
			cFabMod  := VV1->VV1_FABMOD
			cCli     := SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME
			if SA1->(FieldPos("A1_CELULAR")) > 0
				if !Empty(SA1->A1_CELULAR)
					cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL+"    "+"Celular - ("+SA1->A1_DDD+") "+SA1->A1_CELULAR
				Else
					cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL
				Endif	
	        Else
				cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL
	        Endif
			cFunAbe  := ""
			cNumOsv  := ""
		Elseif aVet[ni,21] == "2" // OS de Oficina
			dbSelectArea("VO1")
			dbSetOrder(1)
			dbSeek(aVet[ni,20]) 
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+VO1->VO1_CHAINT) 
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+VO1->VO1_CHAINT) 
			FGX_VV2()
			dbSelectArea("VVC")
			dbSetOrder(1)
			dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
			dbSelectArea("VAI")
			dbSetOrder(1)
			DbSeek( xFilial("VAI") + VO1->VO1_FUNABE )
			cChassi  := VV1->VV1_CHASSI
			cCodMar  := VV1->VV1_CODMAR
			cDesMod  := VV2->VV2_DESMOD
			cDescri  := VVC->VVC_DESCRI
			cPlaVei  := VV1->VV1_PLAVEI
			cFabMod  := VV1->VV1_FABMOD
			cCli     := SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME
			if SA1->(FieldPos("A1_CELULAR")) > 0
				if !Empty(SA1->A1_CELULAR)
					cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL+"    "+"Celular - ("+SA1->A1_DDD+") "+SA1->A1_CELULAR
				Else
					cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL
				Endif	
	        Else
				cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL
	        Endif
			cFunAbe := VO1->VO1_FUNABE+" - "+VAI->VAI_NOMTEC
			cNumOsv := VO1->VO1_NUMOSV
		Elseif aVet[ni,21] == "3" // Pecas Balcao
			DbSelectArea("VS1")
			DbSetOrder(1)
			DbSeek(aVet[ni,20])
			DbSelectArea("VV1")
			DbSetOrder(1)
			DbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
			FGX_VV2()
			dbSelectArea("VVC")
			dbSetOrder(1)
			dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
			cChassi  := VV1->VV1_CHASSI
			cCodMar  := VV1->VV1_CODMAR
			cDesMod  := VV2->VV2_DESMOD
			cDescri  := VVC->VVC_DESCRI
			cPlaVei  := VV1->VV1_PLAVEI
			cFabMod  := VV1->VV1_FABMOD
			cCli     := SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME 
			if SA1->(FieldPos("A1_CELULAR")) > 0
				if !Empty(SA1->A1_CELULAR)
					cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL+"    "+"Celular - ("+SA1->A1_DDD+") "+SA1->A1_CELULAR
				Else
					cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL
				Endif	
	        Else
				cFone    := "("+SA1->A1_DDD+")"+"  "+SA1->A1_TEL
	        Endif
			cFunAbe := SA3->A3_COD+" - "+SA3->A3_NOME
			cNumOsv := ""
        Else
			cChassi  := ""
			cCodMar  := ""
			cDesMod  := ""
			cDescri  := ""
			cPlaVei  := ""
			cFabMod  := ""
			cCli     := ""
			cFone    := ""       
			cNumOsv  := ""  
			cFunAbe  := ""
		Endif
		nLin++
		@ nLin++,00 psay STR0082
		nLin++
		@ nLin++,01 psay STR0083+cChassi
		@ nLin++,01 psay STR0084+cCodMar
		@ nLin++,01 psay STR0085+cDesMod
		@ nLin++,01 psay STR0086+cDescri
		@ nLin++,01 psay STR0087+cPlaVei
		@ nLin++,01 psay STR0088+cFabMod
		@ nLin++,01 psay STR0089+cCli 
		@ nLin++,01 psay STR0090+cFone
		nLin++
		@ nLin++,00 psay STR0091
		nLin++
		@ nLin++,01 psay STR0092+cNumOsv 
		@ nLin++,01 psay STR0093+cFunAbe

		if aVet[ni,21] == "2"
			DbSelectArea("SYP")
			DbSetOrder(1)
			If DbSeek( xFilial("SYP") + VO1->VO1_OBSMEM )
				nLin++
				@ nLin , 01 psay STR0094+"  "
				cObs := ""
				While !eof() .and. xFilial("SYP")+VO1->VO1_OBSMEM == SYP->YP_FILIAL+SYP->YP_CHAVE
					If nLin >= 55
						nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
					EndIf
					nPos := AT("\13\10",SYP->YP_TEXTO)
					if nPos > 0
						nPos -= 1
					Else
						nPos := Len(SYP->YP_TEXTO)
					Endif
					cObs := alltrim(Substr(SYP->YP_TEXTO,1,nPos))
					If !Empty(cObs)
						@ nLin , 18 psay "- " + cObs
						nlin++
					EndIf
					SYP->(DbSkip())
				Enddo
			EndIf
        Endif
		nLin++
		nLin++
		
		if (MV_PAR02 == 1 .or. MV_PAR02 == 2) .and. MV_PAR01 == 2
			if cSat <> aVet[ni,15]
				if aVet[ni,15] == "1"
					@ nLin++,00 psay STR0050+"("+transform(aTotCor[1,1],"99999")+")"
					nLin++
					nP := 1
				Else
					@ nLin++,00 psay STR0051+"("+transform(aTotCor[2,1],"99999")+")"
					cStatus := ""
					cSit    := ""
					nLin++
					nP := 2
				Endif
			Endif
			if cStatus <> aVet[ni,1]
				If aVet[ni,1]=="az" .or. aVet[ni,1]=="vm"
					if cSit <> aVet[ni,16]
						@ nLin++,02 psay STR0052+"("+transform(aTotCor[nP,2],"99999")+")"
						nLin++
					Endif
					if aVet[ni,1]=="az"
						@ nLin++,04 psay STR0053+"("+transform(aTotCor[nP,11],"99999")+")"
						nLin++
					Else
						@ nLin++,04 psay STR0054+"("+transform(aTotCor[nP,12],"99999")+")"
						nLin++
					Endif
				Endif
				If aVet[ni,1]=="cz" .or. aVet[ni,1]=="la"
					if cSit <> aVet[ni,16]
						@ nLin++,02 psay STR0055+"("+transform(aTotCor[nP,3],"99999")+")"
						nLin++
					Endif
					if aVet[ni,1]=="cz"
						@ nLin++,04 psay STR0053+"("+transform(aTotCor[nP,9],"99999")+")"
						nLin++
					Else
						@ nLin++,04 psay STR0054+"("+transform(aTotCor[nP,10],"99999")+")"
						nLin++
					Endif
				Endif
				If aVet[ni,1]=="vd" .or. aVet[ni,1]=="am"
					if cSit <> aVet[ni,16]
						@ nLin++,02 psay STR0056+"("+transform(aTotCor[nP,4],"99999")+")"
						nLin++
					Endif
					if aVet[ni,1]=="vd"
						@ nLin++,04 psay STR0053+"("+transform(aTotCor[nP,7],"99999")+")"
						nLin++
					Else
						@ nLin++,04 psay STR0054+"("+transform(aTotCor[nP,8],"99999")+")"
						nLin++
					Endif
				Endif
			Endif
		Endif
		if MV_PAR01 == 1 .and. (MV_PAR02 == 1 .or. MV_PAR02 == 2)
			if aVet[ni,15] == "1"
				@ nLin++,00 psay STR0050 +" "+ STR0078 + " " + aVet[ni,18]
				nLin++
				nP := 1
			Else
				@ nLin++,00 psay STR0051 +" "+ STR0078 + " " + aVet[ni,18]
				cStatus := ""
				cSit    := ""
				nLin++
				nP := 2
			Endif
			If aVet[ni,1]=="az" .or. aVet[ni,1]=="vm"
				@ nLin++,02 psay STR0052
				nLin++
				if aVet[ni,1]=="az"
					@ nLin++,04 psay STR0053
					nLin++
				Else
					@ nLin++,04 psay STR0054
					nLin++
				Endif
			Endif
			If aVet[ni,1]=="cz" .or. aVet[ni,1]=="la"
				@ nLin++,02 psay STR0055
				nLin++
				if aVet[ni,1]=="cz"
					@ nLin++,04 psay STR0053
					nLin++
				Else
					@ nLin++,04 psay STR0054
					nLin++
				Endif
			Endif
			If aVet[ni,1]=="vd" .or. aVet[ni,1]=="am"
				@ nLin++,02 psay STR0056
				nLin++
				if aVet[ni,1]=="vd"
					@ nLin++,04 psay STR0053
					nLin++
				Else
					@ nLin++,04 psay STR0054
					nLin++
				Endif
			Endif
		Endif
		@ nLin++,06 psay Left(Transform(aVet[ni,2],"@D")+SPACE(10),10)+" "+Left(Transform(aVet[ni,3],"@D")+SPACE(10),10)+" "+Left(Transform(aVet[ni,4],"@D")+SPACE(10),10)+" "+Left(Transform(aVet[ni,5],"@D")+SPACE(10),10)+" "+;
		left(aVet[ni,6]+space(18),18)+" "+left(aVet[ni,7]+space(18),18)+" "+left(aVet[ni,8]+SPACE(15),15)+" "+left(aVet[ni,9]+SPACE(15),15)+" "+;
		left(aVet[ni,10]+" "+aVet[ni,11]+space(43),43)+" "+left(aVet[ni,12]+space(28),28)+" "+aVet[ni,13]
		aDesc := {}
		nx := 1
		lx := .f.
		if MV_PAR02 == 1
			@ nLin++,011 psay repl("_",94)
			DbSelectArea("SYP")
			DbSetOrder(1)
			DbSeek( xFilial("SYP") + aVet[ni,14] )
			While !Eof() .and. SYP->YP_CHAVE == aVet[ni,14]
				lx := .f.
				cTexto := Alltrim(SYP->YP_TEXTO)
				nPos := AT("_____",cTexto)
				If nPos > 0
					nx := 1
					lx := .t.
				EndIf
				nPos := AT("*** ",cTexto)
				If nPos > 0
					nx := 1
				EndIf
				nPos := AT("\13\10",cTexto)
				If nPos > 0
					nPos--
				Else
					nPos := Len(cTexto)
				EndIf
				If nx == 1
					aAdd(aDesc,{Substr(cTexto,1,nPos)+If(lx,repl("_",47),"")})
					nx := 2
				Else
					aDesc[len(aDesc),1] += " "+Substr(cTexto,1,nPos)
					nx := 1
				EndIf
				DbSelectArea("SYP")
				DbSkip()
			EndDo
			For nt := 1 to len(aDesc)
				If !Empty(Alltrim(aDesc[nt,1]))
					If nLin >= 60
						nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
					EndIf
					@ nLin++,011 psay left(aDesc[nt,1],123)
				EndIf
			Next
			nLin++

			If !Empty(aVet[ni,22])			
				For i:= 1 to Len(aVet[ni,22]) Step 80
					@ nLin++,011 psay Subs(aVet[ni,22],i,80)
				Next
				nLin++
			EndIf
			If !Empty(aVet[ni,23])
				For i:= 1 to Len(aVet[ni,23]) Step 80
					@ nLin++,011 psay Subs(aVet[ni,23],i,80)
				Next
				nLin++
			EndIf
			If !Empty(aVet[ni,24])
				For i:= 1 to Len(aVet[ni,24]) Step 80
					@ nLin++,011 psay Subs(aVet[ni,24],i,80)
				Next
				nLin++
			EndIf
			If !Empty(aVet[ni,25])
				For i:= 1 to Len(aVet[ni,25]) Step 80
					@ nLin++,011 psay Subs(aVet[ni,25],i,80)
				Next
				nLin++
			EndIf	
		Endif
				
		if MV_PAR01 == 1
			if ni < Len(aVet)
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			Endif
		Endif
		cSat    := aVet[ni,15]
		cStatus := aVet[ni,1]
		cSit    := aVet[ni,16]
	Next
	
	If nLin >= 55 .or. MV_PAR01 == 1
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
	EndIf
	if MV_PAR02 == 1 .OR. MV_PAR02 == 2
		nLin+=3
		@ nLin++,08 psay STR0061
		nLin++
		@ nLin++,08 psay STR0062+transform(aTotCor[1,1],"@E 999,999,999.99")+space(20)+STR0063+transform(aTotCor[2,1],"@E 999,999,999.99")
		nLin++
		@ nLin++,10 psay STR0064+transform(aTotCor[1,2],"@E 999,999,999.99")+space(20)+STR0065+transform(aTotCor[2,2],"@E 999,999,999.99")
		nLin++
		@ nLin++,12 psay STR0066+transform(aTotCor[1,11],"@E 999,999,999.99")+space(20)+STR0067+transform(aTotCor[2,11],"@E 999,999,999.99")
		@ nLin++,12 psay STR0068+transform(aTotCor[1,12],"@E 999,999,999.99")+space(20)+STR0069+transform(aTotCor[2,12],"@E 999,999,999.99")
		nLin++
		@ nLin++,10 psay STR0070+transform(aTotCor[1,3],"@E 999,999,999.99")+space(20)+STR0071+transform(aTotCor[2,3],"@E 999,999,999.99")
		nLin++
		@ nLin++,12 psay STR0066+transform(aTotCor[1,9],"@E 999,999,999.99")+space(20)+STR0067+transform(aTotCor[2,9],"@E 999,999,999.99")
		@ nLin++,12 psay STR0068+transform(aTotCor[1,10],"@E 999,999,999.99")+space(20)+STR0069+transform(aTotCor[2,10],"@E 999,999,999.99")
		nLin++
		@ nLin++,10 psay STR0072+transform(aTotCor[1,4],"@E 999,999,999.99")+space(20)+STR0073+transform(aTotCor[2,4],"@E 999,999,999.99")
		nLin++
		@ nLin++,12 psay STR0066+transform(aTotCor[1,7],"@E 999,999,999.99")+space(20)+STR0067+transform(aTotCor[2,7],"@E 999,999,999.99")
		@ nLin++,12 psay STR0068+transform(aTotCor[1,8],"@E 999,999,999.99")+space(20)+STR0069+transform(aTotCor[2,8],"@E 999,999,999.99")
		nLin++
	Endif
	
EndIf


cStatus  := STR0002

if cOrdVet == STR0042
	aSort(aVet,1,,{|x,y|Dtos(x[4])+Dtos(x[2])+x[8]+x[10] > Dtos(y[4])+Dtos(y[2])+y[8]+y[10] })
Else
	aSort(aVet,1,,{|x,y| x[10]+Dtos(x[4])+Dtos(x[2])+x[8] < y[10]+Dtos(y[4])+Dtos(y[2])+y[8] })
Endif
Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf

Return()


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1	  | Autor | Thiago                | Data | 19/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Criacao das perguntes.								        |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.
//Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE


aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME","X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

DbSelectArea("SX1")
DbSetOrder(1)
If dbSeek(Left(Alltrim(cPerg)+SPACE(100),Len(SX1->X1_GRUPO))+"02")
	If Empty(SX1->X1_DEF03)
		RecLock("SX1",.F.,.T.)
  			dbdelete()   
  		MsUnlock()
	endif
EndIf	

aAdd(aSX1,{cPerg,"01",STR0044,"","","MV_CH1","N",1,0,0,"C","","mv_par01",STR0045,STR0045,STR0045,"","",STR0046,STR0046,STR0046,"","","","","","","","","","","","","","","","","","","S"})
aAdd(aSX1,{cPerg,"02",STR0047,"","","MV_CH2","N",1,0,0,"C","","mv_par02",STR0048,STR0048,STR0048,"","",STR0049,STR0049,STR0049,"","",STR0057,STR0057,STR0057,"","","","","","","","","","","","","","S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_ALTERAR | Autor | Thiago                | Data | 30/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Botao alterar.										        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function FS_ALTERAR()
Local cBkpUsu := cUsuRes
Local cBkpDep := cDepart
Local cBkpTip := cTipRec
//
dbSelectArea("VAO")
dbGoto(aVet[o590LbVt:nAt,19])
cAlias := "VAO"
nReg := recno()
nOpc := 4
VC590A(cAlias,nReg,nOpc)
//
if ExistBlock("VC590ALT")
	ExecBlock("VC590ALT",.f.,.f.)
endIf
//
cUsuRes := cBkpUsu
cDepart := cBkpDep
cTipRec := cBkpTip
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | FS_VISUAL  | Autor | Thiago                | Data | 30/05/14 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrição | Botao visualizar.									        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function FS_VISUAL()
Local cBkpUsu := cUsuRes
Local cBkpDep := cDepart
Local cBkpTip := cTipRec
//
dbSelectArea("VAO")
dbGoto(aVet[o590LbVt:nAt,19])
cAlias := "VAO"
nReg := recno()
nOpc := 2
VC590A(cAlias,nReg,nOpc)
//
cUsuRes := cBkpUsu
cDepart := cBkpDep
cTipRec := cBkpTip
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VC590A   ³ Autor ³ Andre Luis Almeida    ³ Data ³ 05/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alterar - Registro de Satisfacao / Insatisfacao do Cliente ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VC590A(cAlias,nReg,nOpc)
Private aCampos := {}           
Private cCadastro := STR0001
Private inclui := .f.
Private cReclam := ""
cUsuRes := ""
dDatPro := cTod("")
cDepart := ""
cTipRec := ""
dDatEnc := cTod("")
cUsuRes := VAO->VAO_USURES
dDatPro := VAO->VAO_DATPRO
cDepart := VAO->VAO_DEPART
cTipRec := VAO->VAO_TIPREC
dDatEnc := VAO->VAO_DATENC
cTudOK := "ML600AVal()"
CAMPOM600()
DbSelectArea("VAO")
AxAltera(cAlias,nReg,nOpc,aCampos,,,,cTudOK)
Return
