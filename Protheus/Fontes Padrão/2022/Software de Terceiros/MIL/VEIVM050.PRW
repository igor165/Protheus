#include "Protheus.ch"   
#Include "VEIVM050.ch"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM050 ³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno de Veiculo Consignado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM050

Inclui := .t.
Private cGruVei    := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private cSimVda    := "V"
Private cPrefix    := "VEI"
Private cSitVei    := "0"
Private cEstoque   := "S"
Private nAliIss    := GETMV("MV_TXISS")  / 100
Private nAliPis    := GETMV("MV_TXPIS")  / 100
Private nAliCof    := GETMV("MV_TXCOFIN")/ 100
Private lMsHelpAuto:= .f.
Private lMsErroAuto:= .f.
Private lAbortPrint:= .f.
Private aRotina    := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro  := STR0006 //Retorno de Veiculos Consignados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
cIndex    := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao :='VV0->VV0_OPEMOV $ "5"' // Veiculos Consignados
IndRegua("VV0",cIndex,cKey,,cCondicao,OemToAnsi(STR0007)) //Selecionando Registros...

dbSelectArea("VV0")
nIndexVV0 := RetIndex("VV0")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndexVV0+1)

aCores := {{'VV0->VV0_OPEMOV == "5" .AND. VV0->VV0_SITNFI == "1"','BR_VERDE'},;
           {'VV0->VV0_OPEMOV == "5" .AND. VV0->VV0_SITNFI <> "1"','BR_PRETO'}}

mBrowse( 6, 1,22,75,"VV0",,,,,,aCores)

dbSelectArea("VV0")
RetIndex()
dbsetOrder(1)

#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CONSIGN³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao Principal de Saida de Veiculo Consignado             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RETCONS()

Local nLin   := 14
Local nOpcOk := 0
Local aTipo  := {STR0008,STR0009}  //1-Formulario Proprio - 2-Formulario  do Cliente

//Variaveis de Tela
Private cCliente,cLoja,cNome,cVendedor,cNVendedor,cCodTes,cDTes,cCodTes2,cDTes2,cChave,cMarca,cModelo,cProprietario,cEstado,cCombustivel
Private nValVei,cAnoModelo,cCor,cNfiOri,cSerOri,cIteNFOri

Private cTipo   := " "
Private cNota   := ""
Private cSerie  := ""
Private lVisual := .t.
Private cTraEnt := ""
Private cObserv := E_MSMM(VVA->VVA_OBSMEM,68)

Inclui    := .t.
cCliente  := space(06)
cLoja     := space(02)
cNome     := space(30)
cVendedor := space(06)
cNVendedor:= space(30)
cCodTes   := space(03)
cDTes     := space(30)
cCodTes2  := space(03)
cDTes2    := space(30)
cChave    := space(25)
cAnoModelo:= space(09)
cCor      := space(20)
nValVei   := 0
cNfiOri   := ""
cSerOri   := ""
cIteNFOri := ""

if Empty(VV0->VV0_NUMTRA)
   MsgInfo(STR0045,STR0044)//Esta operacao nao pode ser executada ! - Atencao
   Return( .f. )
Endif   

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)

//FS_VLDCONS("TES",VVA->VVA_CODTES)
//FS_VLDCONS("Veiculo",VVA->VVA_CHASSI)
		   
cCliente  := VV0->VV0_CODCLI
cLoja     := VV0->VV0_LOJA
cNome     := SA1->A1_NOME
cVendedor := space(06)
cNVendedor:= space(30)
cCodTes   := VVA->VVA_CODTES
nValVei   := VVA->VVA_VALMOV
cChave    := VVA->VVA_CHASSI

dbSelectArea("SD2")
dbSetOrder(3)
if dbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA)
  cNfiOri   := VV0->VV0_NUMNFI
  cSerOri   := VV0->VV0_SERNFI
  cIteNFOri := SD2->D2_ITEM
Endif

DEFINE MSDIALOG oDlgConsignado TITLE cCadastro FROM  4.5,0 To 27,80 OF oMainWnd

@ nLin,004 SAY OemToAnsi(STR0012) OF oDlgConsignado PIXEL COLOR CLR_BLUE  //Cliente
@ nLin,050 SAY OemToAnsi(STR0013) OF oDlgConsignado PIXEL COLOR CLR_BLUE  //Loja
nLin+=10
@ nLin,004 MSGET oCliente VAR cCliente PICTURE "@!" F3 "VSC" VALID FS_VLDRETC("1",cCliente)    SIZE 40,4 OF oDlgConsignado PIXEL COLOR CLR_BLACK WHEN !lVisual
@ nLin,050 MSGET oLoja    VAR cLoja    PICTURE "@!"          VALID FS_VLDRETC("1",cCliente+cLoja) SIZE 20,4 OF oDlgConsignado PIXEL COLOR CLR_BLACK WHEN !lVisual
@ nLin,080 SAY oNome VAR cNome OF oDlgConsignado PIXEL SIZE 128,6 COLOR CLR_RED

nLin+=13

@ nLin,004 SAY OemToAnsi(STR0014) OF oDlgConsignado PIXEL COLOR CLR_BLUE //Vendedor
nLin+=10
@ nLin,004 MSGET oVendedor VAR cVendedor PICTURE "@!" F3 "SA3" VALID FS_VLDRETC("2",cVendedor) SIZE 40,4 OF oDlgConsignado PIXEL COLOR CLR_BLACK WHEN !lVisual
@ nLin,050 SAY oNVendedor VAR cNVendedor OF oDlgConsignado PIXEL SIZE 28,6 COLOR CLR_RED

nLin+=13

@ nLin,004 SAY OemToAnsi(STR0010) OF oDlgConsignado PIXEL COLOR CLR_BLUE    //TES
@ nLin,150 SAY OemToAnsi(STR0015) OF oDlgConsignado PIXEL COLOR CLR_BLUE   //TES Devolucao
nLin+=10
@ nLin,004 MSGET oCodTes VAR cCodTes PICTURE "@!S3" F3 "SF4" VALID FS_VLDRETC("3",cCodTes) SIZE 30,4  OF oDlgConsignado PIXEL  COLOR CLR_BLACK WHEN !lVisual
@ nLin,040 SAY oDTes VAR cDTes OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_RED
@ nLin,150 MSGET oCodTes2 VAR cCodTes2 PICTURE "@!S3" F3 "SF4" VALID FS_VLDRETC("4",cCodTes2) SIZE 30,4  OF oDlgConsignado PIXEL  COLOR CLR_BLACK
@ nLin,186 SAY oDTes2 VAR cDTes2 OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_RED

nLin+=13

@ nLin,004 SAY OemToAnsi(STR0017) OF oDlgConsignado PIXEL COLOR CLR_BLUE  //Identificacao do Veiculo
@ nLin,090 SAY OemToAnsi(STR0018) OF oDlgConsignado PIXEL COLOR CLR_BLUE  //Valor do Veiculo
@ nLin,150 SAY OemToAnsi(STR0019) OF oDlgConsignado PIXEL COLOR CLR_BLUE  //Tipo de Formulario
nLin+=10
@ nLin,004 MSGET oChave VAR cChave PICTURE "@!S25" F3 "V11" VALID FS_VLDRETC("5",cChave) SIZE 83,4 OF oDlgConsignado PIXEL  COLOR CLR_BLACK WHEN !lVisual
@ nLin,090 MSGET oValor VAR nValVei PICTURE "@E 999,999,999.99" VALID nValVei > 1 SIZE 45,4 OF oDlgConsignado PIXEL COLOR CLR_BLACK WHEN !lVisual
@ nLin,150 MSCOMBOBOX oTipo VAR cTipo SIZE 100,50 COLOR CLR_BLACK ITEMS aTipo OF oDlgConsignado PIXEL

nLin+=13

@ nLin,004 SAY STR0020  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Marca
@ nLin,030 SAY STR0021  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Modelo
@ nLin,120 SAY STR0022	OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Proprietario
@ nLin,230 SAY STR0023  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Estado
@ nLin,260 SAY STR0024  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Combustivel
nLin+=10
@ nLin,004 SAY oMarca         VAR cMarca        OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE
@ nLin,030 SAY oModelo        VAR cModelo       OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE
@ nLin,120 SAY oProprietario  VAR cProprietario OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE
@ nLin,230 SAY oEstado        VAR cEstado       OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE
@ nLin,260 SAY oCombustivel   VAR cCombustivel  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE

nLin+=13

@ nLin,004 SAY STR0025  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Ano/Modelo
@ nLin,040 SAY STR0026  OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_BLUE   //Cor
nLin+=10
@ nLin,004 SAY oAnoModelo     VAR cAnoModelo    PICTURE "@R 9999/9999" OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE
@ nLin,040 SAY oCor           VAR cCor          PICTURE "@!"           OF oDlgConsignado PIXEL SIZE 88,6 COLOR CLR_HBLUE

nLin+=13

@ nLin,004 BUTTON oBtnFoco PROMPT STR0027 OF oDlgConsignado ACTION (FS_MEMO050()) PIXEL  //Observacao

ACTIVATE MSDIALOG oDlgConsignado CENTER ON INIT (FG_EnchoiceBar(oDlgConsignado,{|| nOpcOk := 1,if(FS_TOKVM050(),oDlgConsignado:End(),.f.)},{|| nOpcOk := 2,oDlgConsignado:End()}))

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_VLDRETC³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Validacao dos Campos de Tela                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLDRETC(cCampo,cValor)

Local lRet := .t.

Do Case 

	Case cCampo == "1"  //Cliente           
	   dbSelectArea("SA1")
	   dbSetOrder(1)
	   if dbSeek(xFilial("SA1")+cValor)
	      cNome := SA1->A1_NOME
	   Else
	      lRet := .f.
	   Endif

	Case cCampo == "2" //Vendedor
	   dbSelectArea("SA3")
	   dbSetOrder(1)
	   if dbSeek(xFilial("SA3")+cValor)
	      cNVendedor := SA3->A3_NOME
	   Else
	      lRet := .f.
	   Endif 
	
	Case cCampo == "3" //TES
	   dbSelectArea("SF4")
	   dbSetOrder(1)
	   if dbSeek(xFilial("SF4")+cValor)
	     	cDTes := SF4->F4_TEXTO
	   Else
	      lRet := .f.
	   Endif 
	
	Case cCampo == "4" //TES2
	   dbSelectArea("SF4")
	   dbSetOrder(1)
	   if dbSeek(xFilial("SF4")+cValor)
	     	cDTes2 := SF4->F4_TEXTO
	   Else
	      lRet := .f.
	   Endif

	Case cCampo == "5" //Veiculo
	   dbSelectArea("VV1")
	   dbSetOrder(1)
	   lOk := dbSeek(xFilial("VV1")+cValor)
	   if !lOk
	      dbSetOrder(2)
	      lOk := dbSeek(xFilial("VV1")+cValor)
	   Endif   
	   if !lOk
	      dbSetOrder(9)
	      lOk := dbSeek(xFilial("VV1")+cValor)
	   Endif   
	   if lOk
	      dbSelectArea("SA1")
	      dbSetOrder(1)
	      dbSeek(xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU)
	
	      dbSelectArea("VV2")
	      dbSetOrder(1)
	      dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
	      
	      cTxtCom := ""
	      Do Case
	         Case VV1->VV1_COMVEI == "0"
	              cTxtCom := STR0028 	//Gasolina
	         Case VV1->VV1_COMVEI == "1"
	              cTxtCom := STR0029   	//Alcool
	         Case VV1->VV1_COMVEI == "2"
	              cTxtCom := STR0030   	//Diesel
	         Case VV1->VV1_COMVEI == "3"
	              cTxtCom := STR0031 	//Gas Natural
	         Case VV1->VV1_COMVEI == "9"
	              cTxtCom := STR0032  	//Sem Combustivel
	      EndCase
	      cMarca        := VV1->VV1_CODMAR
	      cModelo       := VV2->VV2_DESMOD
	      cProprietario := SA1->A1_NOME
	      cEstado       := if(VV1->VV1_ESTVEI=="0",STR0033,STR0034)   //Novo - Usado
	      cCombustivel  := cTxtCom
	      cAnoModelo    := VV1->VV1_FABMOD
	      cCor          := VV1->VV1_CORVEI
	   Else
	      lRet := .f.
	   Endif
EndCase         

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_TOKVM050 | Autor ³ ANDRE               ³ Data ³ 25/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Validacao do Programa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TOKVM050(cAlias, nReg, nOpc)

cTipo := SubStr(cTipo,1,1)
if cTipo == "2" //Formulario do Cliente
	
	cNumNota := Space(06)
	cSerNota := Space(03)
	
	DEFINE MSDIALOG oDlgNota TITLE OemtoAnsi(STR0035) FROM  02,04 TO 08,35 OF oMainWnd 	//Formulario do Cliente
	@ 016, 002 Say STR0036 OF oDlgNota PIXEL //Nota:
	@ 016, 030 MSGET oNumNota VAR cNumNota PICTURE "999999" VALID !EMPTY(cNumNota) SIZE 45,4  OF oDlgNota PIXEL  COLOR CLR_BLACK
	@ 028, 002 Say STR0037 OF oDlgNota PIXEL //Serie:
	@ 028, 030 MSGET oSerNota VAR cSerNota PICTURE "@!" SIZE 25,4  OF oDlgNota PIXEL  COLOR CLR_BLACK
	ACTIVATE MSDIALOG oDlgNota CENTER ON INIT (EnchoiceBar(oDlgNota,{|| oDlgNota:End()},{|| oDlgNota:End()}))
	
	cNota  := cNumNota
	cSerie := cSerNota
	
Endif

dbSelectArea("SD2")
dbSetOrder(3)
cIdeSB6 := space(6)
if dbSeek(xFilial("SD2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA)
   cIdeSB6 := SD2->D2_IDENTB6
Endif

Processa( { || lMsErroAuto := FS_PROC050() } )

Return( !lMsErroAuto )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_PROC050³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa o Retorno do Veiculo Consignado                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PROC050()

Local bCampo   := { |nCPO| Field(nCPO) }
Local _ni,nCntFor := 0
Local lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))#0,.t.,.f.)
Private bRefresh := { || .t. }

ProcRegua(4)
IncProc(OemToAnsi(STR0046)) //Fazendo a Devolucao do Veiculo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao dos Arquivos de ENTRADA                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cTipo == "1" //Formulario do Cliente
	cNota := NxtSx5Nota(cSerie, .T., GetNewPar("MV_TPNRNFS","1"))
Endif

Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VV1                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectArea("VV1")
dbsetOrder(2)
dbSeek(xFilial("VV1")+cChave)

if VV1->VV1_ESTVEI == "0" //Veiculo Novo
   cAlmVei := GetMv("MV_LOCVEIN")
Else
   cAlmVei := GetMv("MV_LOCVEIU")
Endif

RecLock("VV1",.f.)
VV1->VV1_SITVEI := "0"  // Em Estoque
FG_Seek("SA1","SM0->M0_CGC",3,.f.)
cConces := SA1->A1_COD
FG_Seek("VE4","VV1->VV1_CODMAR")
cCodFab := VE4->VE4_CODFAB+VE4->VE4_LOJA
FG_Seek("SA1","cCodFab",1,.f.)
cNomFab := SA1->A1_NREDUZ
VV1->VV1_NOMANT := SA1->A1_NOME
VV1->VV1_ENDANT := SA1->A1_END
If lA1_IBGE
	FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
	VV1->VV1_CIDANT := VAM->VAM_DESCID
	VV1->VV1_ESTANT := VAM->VAM_ESTADO
Else
	VV1->VV1_CIDANT := SA1->A1_MUN
	VV1->VV1_ESTANT := SA1->A1_EST
EndIf
VV1->VV1_CEPANT := SA1->A1_CEP
VV1->VV1_DOCIND := SA1->A1_CGC
VV1->VV1_LOCPAD := cAlmVei
MsUnlock()

If !MaFisFound('NF')
	If !Empty(cLoja)
		MaFisIni(cCliente,cLoja,'F','N','R',MaFisRelImp("VEIVM050",{"VVF","VVG"}))
	EndIf
EndIf

n:=1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVG")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVG")
	if ( X3USO(x3_usado).And.cNivel>=x3_nivel )
		nUsado:=nUsado+1
		aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
  	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aCols da GetDados                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
    aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next         

MaFisRef("IT_PRODUTO","VVG00",VV1->VV1_CHAINT)
MaFisRef("IT_TES","VVG00",cCodTes2)
MaFisRef("IT_VALMERC","VVG00",VV0->VV0_VALMOV)

MaFisRef("IT_BASEICM","VVG00",VV0->VV0_VBAICM)
MaFisRef("IT_ALIQICM","VVG00",VV0->VV0_ALIICM)

nBaseIcm := MaFisRet(1,"IT_BASEICM")
nAliqIcm := MaFisRet(1,"IT_ALIQICM")
nValoIcm	:= MaFisRet(1,"IT_VALICM")

nBaseIpi := MaFisRet(1,"IT_BASEIPI")
nAliqIpi := MaFisRet(1,"IT_ALIQIPI")
nValoIpi	:= MaFisRet(1,"IT_VALIPI")

cTraCpa  := GetSxENum("VVF","VVF_TRACPA")
dDataTmp := dDataBase

IncProc(OemToAnsi(STR0047)) //Gravando Registros da Entrada

dbSelectArea("VVF")
RecLock("VVF",.t.)
VVF->VVF_FILIAL := xFilial("VVF")
FG_GRAVAR("VVF")
VVF->VVF_SITNFI := "1"  //Valida
VVF->VVF_NUMPED := ""
VVF->VVF_OPEMOV := "8"  //Retorno de Consignado
VVF->VVF_QTDVEI := 1
VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
VVF->VVF_NUMTRA := VV0->VV0_NUMTRA
VVF->VVF_FORPRO := if(cTipo=="1","0","1")
VVF->VVF_TRACPA := cTraCpa
VVF->VVF_DATMOV := dDataBase
VVF->VVF_DATFAB := dDataTmp
VVF->VVF_DATEMI := dDataTmp
VVF->VVF_CODFOR := cCliente
VVF->VVF_LOJA   := cLoja
VVF->VVF_NUMNFI := cNota
VVF->VVF_SERNFI := SF2->F2_SERIE
If FieldPos('VVF_SDOC') > 0
	VVF->VVF_SDOC := SF2->F2_SDOC
EndIf

VVF->VVF_FORPAG := RetCondVei()
VVF->VVF_VALMOV := VV0->VV0_VALMOV
VVF->VVF_QTDVEI := 1
VVF->VVF_DTHEMI := Dtoc(dDataBase) + [/] + Time()
VVF->VVF_NUMTRA := VV0->VV0_NUMTRA
VVF->VVF_CONFRE := 0
VVF->VVF_TOTFRE := 0
VVF->VVF_TOTSEG := 0
VVF->VVF_ICMRET := 0
//ICM
VVF->VVF_VBAICM := nBaseIcm
VVF->VVF_ALIICM := nAliqIcm
VVF->VVF_TOTICM := nValoIcm
//IPI
VVF->VVF_VBAIPI := nBaseIpi
VVF->VVF_ALIIPI := nAliqIpi
VVF->VVF_VALIPI := nValoIpi
MSMM(,TamSx3("VVF_OBSERV")[1],,cObserv,1,,,"VVF","VVF_OBSMEM")
ConfirmSx8("VVF")
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VVG                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbselectArea("VVG")
RecLock("VVG",.t.)
VVG->VVG_FILIAL := xFilial("VVG")
VVG->VVG_TRACPA := VVF->VVF_TRACPA
VVG->VVG_CHAINT := VV1->VV1_CHAINT
VVG->VVG_CHASSI := VV1->VV1_CHASSI
VVG->VVG_CODTES := cCodTes2
VVG->VVG_REDCUS := VVA->VVA_REDCUS
VVG->VVG_VCNVEI := 0
VVG->VVG_SEGVIA := 0
VVG->VVG_VALASS := 0
VVG->VVG_VALREV := 0
VVG->VVG_VALFRE := 0
VVG->VVG_ASSIMP := VVA->VVA_ASSIMP
VVG->VVG_ESTVEI := VVA->VVA_ESTVEI
VVG->VVG_CODIND := VVA->VVA_CODIND
VVG->VVG_CODORI := VVA->VVA_CODORI
VVG->VVG_VALUNI := VVA->VVA_VALVDA
VVG->VVG_LOCPAD := cAlmVei
//ICM
VVG->VVG_VBAICM := nBaseIcm
VVG->VVG_ALIICM := nAliqIcm
VVG->VVG_ICMCOM := nValoIcm
//IPI
VVG->VVG_VBAIPI := nBaseIpi
VVG->VVG_ALIIPI := nAliqIpi
VVG->VVG_VALIPI := nValoIpi
MsUnlock()

//Posicionamento p/ calcular o Custo do Veiculo
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))

VVF->(dbSetOrder(1))
VVF->(dbSeek(xFilial("VVF")+VV1->VV1_TRACPA ))
VVG->(dbSetOrder(1))
VVG->(dbSeek(xFilial("VVG")+VVF->VVF_TRACPA+VV1->VV1_CHAINT ))

dbSelectArea("VVF")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("VVG")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

nValFre := VVG->VVG_VALFRE

nCustoVeiculo := 0
if VVG->VVG_ESTVEI == "0" //Novo
	DbSelectArea("VVG")
	If !Empty(VV2->VV2_FORCTB)       //Modelo do Veiculo
		nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCTB)
	ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
		nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
	Endif
Else                                
   cFor := GetMv("MV_VUCCTB")
   if !Empty(cFor)
		nCustoVeiculo := FG_FORMULA(cFor)
	Endif
Endif	
if nCustoVeiculo <= 0
   nCustoVeiculo := VVG->VVG_VALUNI
Endif

dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
   while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
      if VVD->VVD_ATUCUS=="1"
      	nCustoVeiculo += VVD->VVD_VALOR
      Endif
      dbSelectArea("VVD")
      dbSkip()
  	Enddo
Endif

VVF->(dbSetOrder(1))
VVF->(dbSeek(xFilial("VVF")+cTraCpa ))
VVG->(dbSetOrder(1))
VVG->(dbSeek(xFilial("VVG")+cTraCpa+VV1->VV1_CHAINT ))

dbSelectArea("VVF")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("VVG")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Arquivo de Produtos < SB1 >                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectArea("SB1")
dbSetOrder(7)
if !dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	DisarmTransaction()
	Break
Endif
dbSetOrder(1)

SF4->(DbGoTop())
SF4->(DbSeek(xFilial("SF4")+VVG->VVG_CODTES))

IncProc(OemtoAnsi(STR0048))  //Gerando Arquivo de Nota Fiscal de Entrada...

// Cria Vetor de Itens para o MATA100 (Nota Fiscal de Entrada)
aIteTempNFE := {}
aCabNfe     := {}

aAdd(aIteTempNFE,{"D1_ITEM"    ,"01",Nil})
aAdd(aIteTempNFE,{"D1_NFORI"   ,VV0->VV0_NUMNFI,Nil})
aAdd(aIteTempNFE,{"D1_SERIORI" ,VV0->VV0_SERNFI,Nil})
aAdd(aIteTempNFE,{"D1_COD"     ,SB1->B1_COD,Nil})
aAdd(aIteTempNFE,{"D1_UM"      ,"UN",Nil})
aAdd(aIteTempNFE,{"D1_QUANT"   ,1,Nil})
aAdd(aIteTempNFE,{"D1_VUNIT"   ,VVG->VVG_VALUNI,Nil})
aAdd(aIteTempNFE,{"D1_TOTAL"   ,VVG->VVG_VALUNI,Nil})
aAdd(aIteTempNFE,{"D1_VALIPI"  ,nValoIpi,Nil})
aAdd(aIteTempNFE,{"D1_PICM"    ,VVG->VVG_ALIICM,Nil})
aAdd(aIteTempNFE,{"D1_VALICM"  ,nValoIcm,Nil})
aAdd(aIteTempNFE,{"D1_BASEIPI" ,nBaseIpi,Nil})
aAdd(aIteTempNFE,{"D1_BASEICM" ,nBaseIcm,Nil})
aAdd(aIteTempNFE,{"D1_CUSTO"   ,nCustoVeiculo  ,Nil})
aAdd(aIteTempNFE,{"D1_TES"     ,cCodTes2,Nil})
aAdd(aIteTempNFE,{"D1_CF"      ,SF4->F4_CF,Nil})
aAdd(aIteTempNFE,{"D1_CC"      ,VVG->VVG_CENCUS,Nil})
aAdd(aIteTempNFE,{"D1_LOCAL"   ,cAlmVei,Nil})
aAdd(aIteTempNFE,{"D1_LOCPAD"  ,cAlmVei,Nil})
aAdd(aIteTempNFE,{"D1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
aAdd(aIteTempNFE,{"D1_DTDIGIT" ,VVF->VVF_DATMOV,Nil})
aAdd(aIteTempNFE,{"D1_IDENTB6" ,cIdeSB6,Nil})

cTipoN := "D" // Devolucao

if cTipo <> "1" //Formulario Proprio = Nao
	cFormul := "N"
Else
	cFormul := "S"
Endif

nTotal := VVG->VVG_VALUNI

SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA))

aAdd(aCabNFE,{"F1_TIPO"    ,"D"            ,Nil})
aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
//aAdd(aCabNFE,{"F1_ESPECIE" ,"NF"           ,Nil})
aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
aAdd(aCabNFE,{"F1_DOC"     ,VVF->VVF_NUMNFI,Nil})
aAdd(aCabNFE,{"F1_SERIE"   ,VVF->VVF_SERNFI,Nil})
aAdd(aCabNFE,{"F1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
aAdd(aCabNFE,{"F1_DTDIGIT" ,VVF->VVF_DATMOV,Nil})
aAdd(aCabNFE,{"F1_RECBMTO" ,VVF->VVF_DATMOV,Nil})
aAdd(aCabNFE,{"F1_FORNECE" ,cCliente       ,Nil})
aAdd(aCabNFE,{"F1_LOJA   " ,cLoja          ,Nil})
aAdd(aCabNFE,{"F1_COND"    ,VVF->VVF_FORPAG,Nil})
aAdd(aCabNFE,{"F1_ICMSRET" ,VVF->VVF_ICMRET,Nil})
aAdd(aCabNFE,{"F1_VALMERC" ,nTotal         ,Nil})
aAdd(aCabNFE,{"F1_VALBRUT" ,nTotal         ,Nil})
aAdd(aCabNFE,{"F1_EST"     ,SA2->A2_EST    ,Nil})	

//Chamada do MATA103 (Nota Fiscal de Entrada)
lMsHelpAuto := .t.
lMsErroAuto := .f.

lInclui := inclui
inclui  := .t.
nAnt    := MAFISSAVE()
MAFISEND()
MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,{aIteTempNFE},3)
MAFISRESTORE(nAnt)
inclui := lInclui

if lMsErroAuto
	DisarmTransaction()
	Break
Endif

// Ponto de Entrada Depois da Gravacao da Nota Fiscal
If ExistBlock("VM050DNF")
   ExecBlock("VM050DNF",.f.,.f.)
EndIf

DbSelectarea("SF1")
DbSetOrder(1)
if DbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
   SF1->F1_VALMERC := nTotal
   SF1->F1_VALBRUT := nTotal
Endif   

IncProc(OemToAnsi(STR0049)) //Gravando os  Valores de Referencia

//Regrava o custo do Veiculo
dbSelectArea("VVG")
RecLock("VVG",.f.)
VVG->VVG_VCNVEI := nCustoVeiculo
VVG->VVG_VALFRE := nValFre
MsUnlock()

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+GetMv("MV_GRUVEI")+VVG->VVG_CHAINT)
dbSelectArea("SB2")
dbSetOrder(1)
if dbSeek(xFilial("SB2")+SB1->B1_COD)
	RecLock("SB2",.f.)
	SB2->B2_CM1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SB2->B2_CM2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SB2->B2_CM3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SB2->B2_CM4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SB2->B2_CM5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif

dbSelectarea("SD1")
dbSetOrder(1)
if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+VVG->VVG_CHAINT)
	RecLock("SD1",.f.)
	SD1->D1_CUSTO  := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SD1->D1_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SD1->D1_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SD1->D1_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SD1->D1_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif

dbSelectArea("SB6")
dbSetOrder(3)
if dbSeek(xFilial("SB6")+SD1->D1_IDENTB6+VVG->VVG_CHAINT+space(9))
	RecLock("SB6",.f.)
	SB6->B6_CUSTO1 := xMoeda(nCustoVeiculo+nValFre,1,1,dDataBase)
	SB6->B6_CUSTO2 := xMoeda(nCustoVeiculo+nValFre,1,2,dDataBase)
	SB6->B6_CUSTO3 := xMoeda(nCustoVeiculo+nValFre,1,3,dDataBase)
	SB6->B6_CUSTO4 := xMoeda(nCustoVeiculo+nValFre,1,4,dDataBase)
	SB6->B6_CUSTO5 := xMoeda(nCustoVeiculo+nValFre,1,5,dDataBase)
	MsUnlock()
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do VV0                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Marca Nota de Saida como devolvida
dbSelectArea("VV0")
RecLock("VV0",.f.)
VV0->VV0_SITNFI := "2" && Devolucao
VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
VV0->VV0_TRADEV := VVF->VVF_TRACPA
MsUnlock()

End Transaction

// Destrava a Numneracao de Nota Fiscal
SX5->(MsRUnLock())

if !lMsErroAuto
   if cTipo == "1" //Formulario Proprio
		if ExistBlock("NFENTVEI")
			IncProc(OemtoAnsi(STR0039)) //Imprimindo Nota Fiscal...
  		ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI, iif(fieldpos("VVF_SDOC") > 0, VVF->VVF_SDOC, VVF->VVF_SERNFI) , VVF->VVF_CODFOR,VVF->VVF_LOJA})
		Endif
	Endif
Else
	MostraErro()
Endif

Return( lMsErroAuto )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_CUSTOVEIC| Autor ³ ANDRE               ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o Custo do Veiculo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function FS_CUSTOVEIC()
                
Local nCustoVeiculo := 0

if VV1->VV1_ESTVEI == "0"
	If !Empty(VV2->VV2_FORCTB)       //Modelo do Veiculo
		nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCTB)
	ElseIf !Empty(VE4->VE4_FORCUS)   //Parametros da Montadora
		nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
	Endif
	if ValType(nCustoVeiculo) <> "N"
	   nCustoVeiculo := 0
	Endif   
Else                                
   cFor := GetMv("MV_VUCGER")
   if !Empty(cFor)
		nCustoVeiculo := FG_FORMULA(cFor)
		if ValType(nCustoVeiculo) <> "N"
		   nCustoVeiculo := 0
		Endif   
	Endif
Endif

if nCustoVeiculo <= 0
   dbSelectArea("VV1")
   dbSetOrder(1)
   if dbSeek(xFilial("VV1")+M->VVA_CHAINT)
   	dbSelectArea("VVG")
   	dbSetOrder(1)
 	 	if DbSeek(xFilial("VVG")+VV1->VV1_TRACPA+M->VVA_CHAINT)
 	 	   nCustoVeiculo := VVG->VVG_VCNVEI
 	 	Endif
 	Endif 	   
Endif 	

dbSelectArea("VVA")

Return( nCustoVeiculo )
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_MEMO050³ Autor ³ ANDRE                 ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³MEMO p/ Observacao                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MEMO050()

DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0027) FROM  02,04 TO 14,56 OF oMainWnd  //Observacao

	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1

	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL WHEN !lVisual
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()
	
ACTIVATE MSDIALOG oDlg1 CENTER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_V050LEG | Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Legenda para MBrowse                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_V050LEG()

Local aLegenda := {}

alegenda := {{'BR_VERDE',STR0040},;  	//Remessa
             {'BR_PRETO',STR0042}} 		//Veiculo de Remessa Normal Retornado
              
//				{'BR_AMARELO','Retorno da Entrada de Remessa'}

BrwLegenda(cCadastro,STR0005 ,aLegenda) //Legenda

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |FS_CANRETC | Autor ³ ANDRE                ³ Data ³ 26/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao de Cancelamento de Consignado                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANRETC()

Local lRet := .t.
Private cNumTit := ""
Private lMsHelpAuto := .t.
Private lMsErroAuto := .f.

if !MsgYesNo(STR0043,STR0044) //Confirma Cancelamento do Retorno da Consignacao ? - Atencao!
   lRet := .f.
Endif
   
if lRet
	Begin Transaction
	
	   dbSelectArea("VVA")
	   dbSetOrder(1)
	   dbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)

	   dbSelectArea("VV1")
	   dbSetOrder(1)
	   dbSeek(xFilial("VV1")+VVA->VVA_CHAINT)

		//Exclusao da Nota Fiscal
		aMata520Cab   := {{"F2_DOC"  ,VV0->VV0_NUMNFI ,Nil},; //Numero da nota
                        {"F2_SERIE",VV0->VV0_SERNFI ,Nil}}  //Serie

		MSExecAuto({|x| Mata520(x)},aMata520Cab)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		//Cancela a Liberacao
		SC9->(DbSetOrder(1))
		SC9->(DbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
		While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
			SC9->(a460Estorna())
			SC9->(dbSkip())
		EndDo
		
		//Exclusao do Pedido
		aMata410Cab   := {{"C5_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do pedido SC5
		aMata410Itens := {{"C6_NUM"      , VV0->VV0_NUMPED,Nil}}   // Numero do Pedido SC6

		MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif

		dbSelectArea("VV1")
		RecLock("VV1",.f.)
		VV1->VV1_SITVEI := "4"
		VV1->VV1_NUMTRA := Space(10)
		MsUnlock()

      // Volta Estado Anterior da NF de Entrada Qdo Devolucao
  		dbSelectArea("VVF")
		dbSetOrder(5)
		dbSeek(xFilial("VVF")+VV0->VV0_NUMTRA)
		RecLock("VVF",.f.)
		VVF->VVF_SITNFI := "1"    //Valida
		VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
	
      // Atualiza Arquivo da Saida de Consignacao de Veiculos
		dbSelectArea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "0" //Cancelada
		VV0->VV0_DATUSU := DtoS(dDataBase)+"-"+__cUserID
		VV0->VV0_NUMPED := ""
		VV0->VV0_NUMNFI := ""
		VV0->VV0_SERNFI := ""
		if FieldPos("VV0_SDOC") > 0
			VV0->VV0_SDOC := ""
		EndIf
		MsUnlock()

		dbSelectArea("VVA")
		RecLock("VVA",.f.)
		VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
		MsUnlock()
		
	End Transaction
Endif	

If lMsErroAuto
	MostraErro()
Endif

Return

Static Function MenuDef()
Local aRotina := {{OemtoAnsi(STR0001),"FS_PESQ30", 0 ,1},;					//Pesquisar
						{OemtoAnsi(STR0002),"FS_RETCONS", 0, 2},;			//Consultar
						{OemtoAnsi(STR0050) ,"FS_RETCONS", 0, 3},;			//Retorna
						{OemtoAnsi(STR0004) ,"FS_CANRETC", 0, 4},;			//Cancelar
						{OemtoAnsi(STR0005)  ,"FS_V050LEG", 0, 0 ,2,.f.},; 	//Legenda
						{ STR0051  ,"VM050_LVEI" , 0 , 2}}   	   			//Pesquisa Chassi
Return aRotina
                                                                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM050_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM050_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private overd := LoadBitmap( GetResources() , "BR_VERDE" )
Private opret := LoadBitmap( GetResources() , "BR_PRETO" )
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
EndDo
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0052) FROM  01,05 TO 17,70 OF oMainWnd //Pesquisa Chassi
	@ 003,004 SAY STR0053 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE  //Veiculo:
  	@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
 	@ 002,212 BUTTON oNo PROMPT OemToAnsi(STR0054) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
	@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
																OemToAnsi(STR0055),;	//Filial
																OemToAnsi(STR0056),;	//Dt.Movimento
																OemToAnsi(STR0057),;	//NF-Serie
																OemToAnsi(STR0058),;	//Vlr Venda
																OemToAnsi(STR0012); 	//Cliente
																COLSIZES 10,35,35,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]<>"51",oVerd,opret),;
	  							   	aLevPesq[oLbLevPesq:nAt,03],;
	  							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	  							   	aLevPesq[oLbLevPesq:nAt,05],;
	 									FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	  							   	aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VV0")   
if nOpca > 0 .and. Len(aLevPesq) >= nOpca 
  	//posiciona no registro
  	dbSetOrder(1)//NUMTRA
  	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif       
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local lOk := .t.
Local cQuery := ""
Local cQAlVV0 := "SQLVV0"
Local cFilLibs := ""
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_SITNFI , VV0.VV0_OPEMOV , VV0.VV0_FILIAL , VV0.VV0_DATMOV , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VV0.VV0_NUMNFI , "+ FGX_MILSNF("VV0", 3, "VV0_SERNFI") +" , VV0.VV0_SERNFI FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE "
	cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VV0.VV0_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	
	cQuery += "VV0.VV0_OPEMOV='5' AND VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV "

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
	Do While !( cQAlVV0 )->( Eof() )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
	   If nEmpAtu > 0 
	      cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
	   EndIf
		aAdd(aLevPesq,{ ( cQAlVV0 )->( VV0_NUMTRA ) , ( cQAlVV0 )->( VV0_OPEMOV ) + ( cQAlVV0 )->( VV0_SITNFI ) , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_NUMNFI )+"-"+ (cQAlVV0)->&(FGX_MILSNF("VV0", 3, "VV0_SERNFI")) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME })
		( cQAlVV0 )->( DbSkip() )
	EndDo
	( cQAlVV0 )->( dbCloseArea() )

	If len(aLevPesq) <= 0
		MsgAlert(STR0059+" "+cLevChas,STR0044 ) //Nenhuma Saida de Veiculo Consignado para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="51",oVerd,opret),;
	  							   	aLevPesq[oLbLevPesq:nAt,03],;
	  							   	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	  							   	aLevPesq[oLbLevPesq:nAt,05],;
	 									FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	  							   	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	If !lOk
		oLevChas:SetFocus()
	EndIf
EndIf
Return