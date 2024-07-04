// ษออออออออหออออออออป
// บ Versao บ 09     บ
// ศออออออออสออออออออผ

#Include "Protheus.ch"
#Include "OFIOC130.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  13/11/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007398_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOC130 ณ Autor ณ  Andre                ณ Data ณ 30/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Consulta Itens por Filial                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOC130

Local cFiltro     := ""
Local cGruVei     := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv     := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico

Private aRotina := MenuDef()
Private cCadastro := OemtoAnsi(STR0003) //"Consulta Itens por Filial"
Private lGruNov := (VE9->(FieldPos("VE9_GRUNOV"))>0)

cFiltro := "B1_GRUPO<>'"+cGruVei+"' AND B1_GRUPO<>'"+cGruSrv+"'"
mBrowse(06,01,22,75,"SB1",,,,,,,,,,,,,,cFiltro)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณCONSITEFILณ Autor ณ  Andre                ณ Data ณ 20/07/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณConsulta Itens por Filial                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CONSITEFIL()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
//
Local oDlgLayOut
Local oGetH
Local oGetD
Local oGetT
Local oLbHeader
Local oLbDetail
Local oLbTrail
Local oBarHeader
Local oBarDetail
Local oBarTrail
Local nHeader:=0
Local cMoeda1 := AllTrim(GetMv("MV_MOEDA1"))
Local cMoeda2 := AllTrim(GetMv("MV_MOEDA2"))
Local cMoeda3 := AllTrim(GetMv("MV_MOEDA3"))
Local cMoeda4 := AllTrim(GetMv("MV_MOEDA4"))
Local cMoeda5 := AllTrim(GetMv("MV_MOEDA5"))
Local cCodReduz := Space(10)
Local cMarca := ""
Local aDsCampo := {} , aSaldo := {}
Local Lin := 0 , Pos := 0
Local aFilAtu    := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Local cBkpFilAnt:= cFilAnt
Local nCont := 0 

aRotina := { { " " ," " , 0, 1},;   //Pesquisar
{ " " ," " , 0, 2},;   //Visualizar
{ " " ," " , 0, 3},;   //Incluir
{ " " ," " , 0, 4},;   //Alterar
{ " " ," " , 0, 5} }   //Excluir

Private lPri     := .t.
Private aItem    := {}
Private aEstoque := {}
Private oMonoAs  := TFont():New( "Mono AS", 6, 15 )
Private oMonoAs1 := TFont():New( "Mono AS", 7, 21 )
Private oOk      := LoadBitmap( GetResources(), "LBOK" )
Private oNo      := LoadBitmap( GetResources(), "LBNO" )

cGruIte  := SB1->B1_GRUPO
cCodIte  := SB1->B1_CODITE
cDesIte  := SB1->B1_DESC
cDesIte3 := SB1->B1_DATREF
cDesIte4 := SB1->B1_UCOM
cDesIte5 := SB1->B1_CUSTD
cMarca   := ""
cCodKit  := ""
cClaABC  := ""

//Grupo
DbSelectArea("SBM")
DbSetOrder(1)
if DbSeek(xFilial("SBM")+cGruIte)
	cMarca := SBM->BM_CODMAR
Endif

//Marca
DbSelectArea("VE1")
DbSetOrder(1)
if DbSeek(xFilial("VE1")+cMarca)
	cMarca := VE1->VE1_CODMAR
	//      cDesMar:= VE1->VE1_DESMAR
Else
	cMarca :=""
	//      cDesMar:=""
Endif

//C.A.I.
DbSelectArea("SB5")
DbSetOrder(1)
if DbSeek(xFilial("SB5")+SB1->B1_COD)
	DbSelectArea("VE2")
	DbSetOrder(1)
	if DbSeek(xFilial("VE2")+cMarca+SB5->B5_CODCAI)
		cCodCAI := SB5->B5_CODCAI
		cDesCAI := VE2->VE2_DESCAI
	Else
		cCodCAI := ""
		cDesCAI := ""
	Endif
Endif

//Substituicao
DbSelectArea("VE9")
DbSetOrder(5)
if DbSeek(xFilial("VE9")+cGruIte+cCodIte)
	if lGruNov
		cIteNew := VE9->VE9_GRUNOV + VE9->VE9_ITENOV
		cIteOld := VE9->VE9_GRUITE + VE9->VE9_ITEANT
	else
		cIteNew := VE9->VE9_ITENOV
		cIteOld := VE9->VE9_ITEANT
	endif
Else
	cIteNew := " "
	cIteOld := " "
Endif

//Kit
DbSelectArea("VE8")
DbSetOrder(2)
if DbSeek(xFilial("VE8")+cGruIte+cCodIte)
	cCodKit := VE8->VE8_CODKIT
Endif

//Custo Medio
DbSelectArea("SB2")
DbSetOrder(1)
if DbSeek(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
	cDesIte2:=SB2->B2_CM1
Else
	cDesIte2:=0
Endif

DbSelectArea("SBL")
DbSeek(xFilial("SBL")+SB1->B1_COD)
cClaABC := SBL->BL_ABCVEND+SBL->BL_ABCCUST

DbSelectArea("SX5")
DbGotop()
if DbSeek(xFilial("SX5")+"S0"+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_ORIGEM"))
	cCampo32 := X5_DESCRI
Else
	cCampo32 := Space(25)
Endif

DbSelectarea("SB1")

Lin := 008
Pos := 005

DEFINE FONT oFnt1 NAME "Arial" SIZE 09,14
DEFINE FONT oFnt2 NAME "Arial" SIZE 08,12
DEFINE FONT oFnt4 NAME "Times New Roman" BOLD

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 65 , .T. , .F. } ) 	//Cabecalho
AAdd( aObjects, { 01, 10 , .T. , .T. } )  	//list box superior
AAdd( aObjects, { 01, 10 , .T. , .T. } )  //list box inferior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0003) FROM aSizeAut[7],000 to aSizeAut[6],aSizeAut[5]	of oMainWnd PIXEL //"Consulta Itens por Filial"

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL ("") OF oDlg PIXEL

@ aPosObj[1,1]+005,aPosObj[1,2]+005 SAY   STR0004  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Grupo"
@ aPosObj[1,1]+014,aPosObj[1,2]+005 MSGET oGruIte VAR cGruIte PICTURE "@!" SIZE 18,08 OF oDlg PIXEL COLOR CLR_HBLUE FONT oFnt4 when .f.

@ aPosObj[1,1]+005,aPosObj[1,2]+045 SAY   STR0005 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Codigo"
@ aPosObj[1,1]+014,aPosObj[1,2]+045 MSGET oCodIte VAR cCodIte PICTURE "@!" SIZE 58,08 OF oDlg PIXEL COLOR CLR_HBLUE FONT oFnt4 when .f.
//descricao
@ aPosObj[1,1]+014,aPosObj[1,2]+105 MSGET oDesIte VAR cDesIte PICTURE "@!" SIZE 100,08 OF oDlg PIXEL COLOR CLR_HRED FONT oFnt4 when .f.

Lin := 020
Pos := 005

Lin := Lin + Pos + 2

@ aPosObj[1,1]+004,aPosObj[1,2]+215 SAY STR0006 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE 	//"Marca"
@ aPosObj[1,1]+014,aPosObj[1,2]+215 MSGET oMarca VAR cMarca PICTURE "@!" SIZE 25,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.

@ aPosObj[1,1]+004,aPosObj[1,2]+250 SAY STR0007 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE 	//"Class. ABC"
@ aPosObj[1,1]+014,aPosObj[1,2]+250 MSGET oClaABC VAR cClaABC PICTURE "@!" SIZE 25,08 OF oDlg PIXEL COLOR CLR_BLACK FONT oFnt2 when .f.


@ aPosObj[1,1]+004,aPosObj[1,2]+285 SAY STR0008 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE 	//"Kit"
@ aPosObj[1,1]+014,aPosObj[1,2]+285 MSGET oCodKit VAR cCodKit PICTURE "@!" SIZE 70,08 OF oDlg PIXEL COLOR CLR_BLACK FONT oFnt2 when .f.

DEFINE SBUTTON FROM aPosObj[1,1]+013.5,aPosObj[1,2]+365 TYPE 14 ACTION FS_PECRES( aItem[oLbHeader:nAt,1] ) ENABLE ONSTOP STR0015 OF oDlg PIXEL //"Itens reservados"

Lin := Lin + 12

@ aPosObj[1,1]+027,aPosObj[1,2]+002 TO aPosObj[1,3]-002,aPosObj[1,2]+180 LABEL (" "+STR0009+" ") OF oDlg PIXEL 			// Substituicao

@ aPosObj[1,1]+035,aPosObj[1,2]+020 SAY STR0010 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Nova"
@ aPosObj[1,1]+045,aPosObj[1,2]+020 MSGET oIteNew VAR cIteNew PICTURE "@!" SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLACK FONT oFnt4 when .f.

@ aPosObj[1,1]+035,aPosObj[1,2]+100 SAY STR0011 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Velha"
@ aPosObj[1,1]+045,aPosObj[1,2]+100 MSGET oIteOld VAR cIteOld PICTURE "@!" SIZE 60,08 OF oDlg PIXEL COLOR CLR_BLACK FONT oFnt4 when .f.

Lin := Lin + 12

@ aPosObj[1,1]+035,aPosObj[1,2]+190 SAY STR0012 SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Ult. Entrada"
@ aPosObj[1,1]+035,aPosObj[1,2]+264 SAY STR0013  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Ult. Compra"
@ aPosObj[1,1]+035,aPosObj[1,2]+337 SAY STR0014  SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Custo Medio"

Lin := Lin + Pos + 4

@ aPosObj[1,1]+045,aPosObj[1,2]+190 MSGET oCampo23 VAR cDesIte3 PICTURE "@D" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK When .f.
@ aPosObj[1,1]+045,aPosObj[1,2]+264 MSGET oCampo24 VAR cDesIte4 PICTURE "@D" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK When .f.
@ aPosObj[1,1]+045,aPosObj[1,2]+337 MSGET oCampo25 VAR cDesIte5 PICTURE "@E 999,999,999.99" SIZE 55,10 OF oDlg PIXEL COLOR CLR_BLACK When .f.

Lin := Lin + Pos + 09

aItem := {}

For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu := FWArrFilAtu(cEmpAnt,cFilAnt)
	aadd(aItem,{Alltrim(cFilAnt),aFilAtu[5],FWFilialName()})
Next
cFilAnt := cBkpFilAnt

DbSelectArea("SB1")

@ aPosObj[2,1]+002,aPosObj[2,2]+001 LISTBOX oLbHeader FIELDS HEADER OemToAnsi(STR0016),; //"Filial"
OemToAnsi(STR0017),; //"Nome"
OemToAnsi(STR0018);  //"Nome Completo"
COLSIZES 30,50,120;
SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oDlg PIXEL ON CHANGE(FS_MUDAEMP(oLbHeader:nAt))

oLbHeader:SetArray(aItem)
oLbheader:bLine := { || { aItem[oLbHeader:nAt,1] ,;
aItem[oLbHeader:nAt,2] ,;
aItem[oLbHeader:nAt,3]}}
Lin := Lin + 61

aSaldo   := {}
aEstoque := {}

DbSelectArea("NNR")
DbSeek(xFilial("NNR"))
Do While !EOF() .and. NNR->NNR_FILIAL == xFilial("NNR") .and. Substr(NNR_CODIGO,1,1) $ "0123456789" .and. Substr(NNR_CODIGO,2,1) $ "0123456789"
	
	//aSaldo := CalcEst(SB1->B1_COD,NNR->NNR_CODIGO,dDataBase+1)
	DbSelectArea("SB2")
	DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO)
	nQTD := SaldoSB2()
	AADD(aEstoque,{Substr(NNR->NNR_DESCRI,1,15), nQTD," ", 0," ", 0})
	DbSelectArea("NNR")
	DbSkip()
	
	
	if Substr(NNR_CODIGO,1,1) $ "0123456789" .and. Substr(NNR_CODIGO,2,1) $ "0123456789"
		aEstoque[Len(aEstoque),3] := Substr(NNR->NNR_DESCRI,1,15)
		DbSelectArea("SB2")
		DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO)
		nQTD := SaldoSB2()
		aEstoque[Len(aEstoque),4] := nQTD
		DbSelectArea("NNR")
	Endif
	DbSkip()
	if Substr(NNR_CODIGO,1,1) $ "0123456789" .and. Substr(NNR_CODIGO,2,1) $ "0123456789"
		DbSelectArea("SB2")
		DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO)
		nQTD := SaldoSB2()
		aEstoque[Len(aEstoque),5] := Substr(NNR->NNR_DESCRI,1,15)
		//aSaldo := CalcEst(SB1->B1_COD,NNR->NNR_CODIGO,dDataBase+1)
		aEstoque[Len(aEstoque),6] := nQTD
		DbSelectArea("NNR")
	Endif
	DbSkip()
Enddo

@ aPosObj[3,1]+002,aPosObj[3,2]+001 LISTBOX oLbEstoque FIELDS HEADER	OemToAnsi(STR0019),; //"Almoxarifado"
OemToAnsi(STR0020),; //"Qtdade"
OemToAnsi(STR0019),; //"Almoxarifado"
OemToAnsi(STR0020),; //"Qtdade"
OemToAnsi(STR0019),; //"Almoxarifado"
OemToAnsi(STR0020);  //"Qtdade"
COLSIZES 65,23,46,46,46,46,46;
SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[2,3]-002 OF oDlg PIXEL

if Len(aEstoque) = 0
	AADD(aEstoque,{"", 0," ", 0," ", 0})
Endif

oLbEstoque:SetArray(aEstoque)
oLbEstoque:bLine := { || {	aEstoque[oLbEstoque:nAt,1] ,;
aEstoque[oLbEstoque:nAt,2] ,;
aEstoque[oLbEstoque:nAt,3] ,;
aEstoque[oLbEstoque:nAt,4] ,;
aEstoque[oLbEstoque:nAt,5] ,;
aEstoque[oLbEstoque:nAt,6]}}

//ACTIVATE MSDIALOG oDlg ON INIT (FG_EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()},1))
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MUDAEMPบAutor  ณAndre               บ Data ณ  10/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Muda empresa                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_MUDAEMP(nLin)

Local aSaldo := {}
Local cFilBkp := cFilAnt

if !lPri
	
	aEstoque := {}
	DbSelectArea("NNR")
	DbSeek(aItem[nLin,1])
	cFilAnt := aItem[nLin,1]
	Do While !EOF() .and. NNR->NNR_FILIAL == xFilial("NNR") .and. Substr(NNR_CODIGO,1,1) $ "0123456789" .and. Substr(NNR_CODIGO,2,1) $ "0123456789"
		
		// aSaldo := CalcEst(SB1->B1_COD,NNR->NNR_CODIGO,dDataBase+1)
		DbSelectArea("SB2")
		DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO)
		nQTD := SaldoSB2()
		AADD(aEstoque,{Substr(NNR->NNR_DESCRI,1,15), nQTD," ", 0," ", 0})
		DbSelectArea("NNR")
		DbSkip()
		if Substr(NNR_CODIGO,1,1) $ "0123456789" .and. Substr(NNR_CODIGO,2,1) $ "0123456789"
			aEstoque[Len(aEstoque),3] := Substr(NNR->NNR_DESCRI,1,15)
			//aSaldo := CalcEst(SB1->B1_COD,NNR->NNR_CODIGO,dDataBase+1)
			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO)
			nQTD := SaldoSB2()
			aEstoque[Len(aEstoque),4] := nQTD
			DbSelectArea("NNR")
		Endif
		DbSkip()
		if Substr(NNR_CODIGO,1,1) $ "0123456789" .and. Substr(NNR_CODIGO,2,1) $ "0123456789"
			aEstoque[Len(aEstoque),5] := Substr(NNR->NNR_DESCRI,1,15)
			//aSaldo := CalcEst(SB1->B1_COD,NNR->NNR_CODIGO,dDataBase+1)
			DbSelectArea("SB2")
			DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO)
			nQTD := SaldoSB2()
			aEstoque[Len(aEstoque),6] := nQTD
			DbSelectArea("NNR")
		Endif
		DbSkip()
	Enddo
	
	if Len(aEstoque) = 0
		AADD(aEstoque,{"", 0," ", 0," ", 0})
	Endif
	oLbEstoque:nAt := 1
	oLbEstoque:SetArray(aEstoque)
	oLbEstoque:bLine := { || {	aEstoque[oLbEstoque:nAt,1] ,;
	aEstoque[oLbEstoque:nAt,2] ,;
	aEstoque[oLbEstoque:nAt,3] ,;
	aEstoque[oLbEstoque:nAt,4] ,;
	aEstoque[oLbEstoque:nAt,5] ,;
	aEstoque[oLbEstoque:nAt,6]}}
	oLbEstoque:Refresh()
	
	lPri := .f.
Else
	lPri := .f.
Endif
cFilAnt := cFilBkp
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PECRES บAutor  ณFabio               บ Data ณ  04/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPecas Reservadas para orcamento                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PECRES(cFilRes)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.F.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
//
Local cIndex , cChave , cCond
Local aSaldo   := {} , aEstReserv := {} , aArea := {}
Private cFilialR := cFilRes

aArea := sGetArea(aArea,Alias())
aArea := sGetArea(aArea,"VSJ")
aArea := sGetArea(aArea,"SB1")
aArea := sGetArea(aArea,"NNR")

dbSelectArea("VSJ")

cIndex  := CriaTrab(nil,.f.)
cChave  :="VSJ_FILIAL+VSJ_GRUITE+VSJ_CODITE+VSJ_NUMORC"
cCond   := 'VSJ_FILIAL == cFilialR .And. VSJ_GRUITE == SB1->B1_GRUPO .And. VSJ_CODITE == SB1->B1_CODITE .And. VSJ_RESPEC == "1"'
IndRegua("VSJ",cIndex,cChave,,cCond,STR0021) //"Levantando pecas reservadas"

DbGoTop()

Do While !EOF()
	
	AADD(aEstReserv,{VSJ->VSJ_NUMOSV,VSJ->VSJ_NUMORC,VSJ->VSJ_QTDITE})
	
	aSaldo := CalcEst(SB1->B1_COD,GetMv("MV_RESITE"),dDataBase+1)
	
	If VSJ->VSJ_QTDITE > aSaldo[1]
		
		aEstReserv[Len(aEstReserv),3] := aSaldo[1]
		
	EndIf
	
	DbSelectArea("VSJ")
	DbSkip()
	
Enddo

If Len(aEstReserv) # 0
	
	DbSelectArea("NNR")
	DbSetOrder(1)
	DbSeek( xFilial("NNR") + GetMv("MV_RESITE") )

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 65 , .T. , .T. } ) 	//Cabecalho
	AAdd( aObjects, { 01, 15 , .T. , .F. } )  	//list box superior
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oDlgRes TITLE OemtoAnsi(STR0022+SB1->B1_DESC+" - "+NNR->NNR_DESCRI ) FROM  01,05 TO aSizeAut[6],450 OF oMainWnd PIXEL //"Itens reservados - "
	
	@ aPosObj[1,1]+002, 002 LISTBOX oLbEst FIELDS HEADER	OemToAnsi(STR0023),; //"Nro OS"
	OemToAnsi(STR0024),; //"Nro Orcamento"
	OemToAnsi(STR0020); //"Qtdade"
	COLSIZES 40,40,40;
	SIZE 221,aPosObj[1,3] OF oDlgRes PIXEL
	
	oLbEst:SetArray(aEstReserv)
	oLbEst:bLine := { || { aEstReserv[oLbEst:nAt,1] ,;
	aEstReserv[oLbEst:nAt,2] ,;
	aEstReserv[oLbEst:nAt,3]}}
	
	DEFINE SBUTTON FROM aPosObj[2,1]+008,180 TYPE 2 ACTION oDlgRes:End() ENABLE OF oDlgRes PIXEL
	
	ACTIVATE MSDIALOG oDlgRes
else
	msgInfo(STR0025,STR0026) //"Esta Item nao esta reservado para nenhuma Ordem de Servico."###"Atencao"
	
EndIf

DbSelectArea("VSJ")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ENDIF

&& Volta posicoes originais
sRestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณFabio               บ Data ณ  04/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMenu								                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {{STR0001,"AxPesqui"  ,0,1},; //"Pesquisar"
{STR0002,"CONSITEFIL",0,2}} //"Consultar"
Return aRotina
