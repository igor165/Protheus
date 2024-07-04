// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 25     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#INCLUDE "Ofigm100.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM100 ³ Autor ³ Renata/Andre          ³ Data ³ 09/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ NF de entrada e saida de envio de peca para fabrica        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIGM100

Private nIndex     :=  0
Private lVG8       := .f.
Private aVG6S      := {}
Private cCgcFab    := ""
Private cCgcCli    := ""
Private aEnt1      := {}
Private cCodTransp := ""
Private cTipFrete  := ""
Private aSai1      := {}
Private aSai2      := {}
Private cCgcFor    := ""
Private cNome      := ""
Private cSerie     := " "
Private cCadastro  := OemToAnsi(STR0001)                     //Remessa de Peca p/ Fabrica // //"NF de Remessa(E/S) de Peca para Fabrica"
Private aRotina    := MenuDef()

DbSelectArea("VG8")

cDelFunc := ".T."

cMarca := GetMark()

aCamList := {{"VG8_OK",   ,"",OemToAnsi("")},;
{"VG8_NUMOSV","",OemToAnsi(STR0006)},; // //"NroOsv"
{"VG8_CODMAR","",OemToAnsi(STR0007)},; // //"Marca"
{"VG8_ANORRC","",OemToAnsi(STR0008)},; // //"Ano RR"
{"VG8_NUMRRC","",OemToAnsi(STR0009)},; // //"Numero RR"
{"VG8_CHAINT","",OemToAnsi(STR0010)},; // //"Chassi Int"
{"VG8_ABEGAR","",OemToAnsi(STR0011)},; // //"Ab. Garantia"
{"VG8_DATDIS","",OemToAnsi(STR0012)},; // //"Dt Disponib"
{"VG8_KILGAR","",OemToAnsi(STR0013)}} // //"Km Garantia"

lInverte := .F.

Markbrow("VG8","VG8_OK","OGM100BR()",,,cMarca)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM100M    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do listbox para marcar as pecas que serao enviadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM100M(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM100M(cAlias,nReg,nOpc)

Local aParamBox := {}
Local aTipoFre := X3CBOXAVET("C5_TPFRETE","1")
Local aRet := {}
Private oLbox, oDlg
Private oOk      := LoadBitmap( GetResources(), "LBOK" )
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private aStruLIB := {}                
                    
AjustaHelp()

aAdd(aParamBox,{2,RetTitle("C5_TPFRETE"),"",aTipoFre,80,"",.f.}) 
aAdd(aParamBox,{1,RetTitle("C5_TRANSP"),Space(TamSX3("C5_TRANSP")[1]),"@!","","SA4","",0,.f.}) 
If !ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
	Return(.f.)
EndIf

if Empty(aRet[1])
	MsgStop(STR0027)
	Return(.f.)
Endif
if Empty(aRet[2]) .and. Alltrim(aRet[1]) <> "S"
	MsgStop(STR0028)
	Return(.f.)
Endif
cTipFrete  := aRet[1]
cCodTransp := aRet[2]

// Selecionar a série e o número
If !SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"), "")
	Return .f.
EndIf

DbSelectArea("VG8")
DbSeek(xFilial("VG8"))
Do while !EOF() .and. xFilial("VG8") == VG8->VG8_FILIAL
	
	If !IsMark("VG8_OK",ThisMark(),ThisInv())
		DbSkip()
		Loop
	Endif
	
	if !Empty(VG8->VG8_NF1REM)
		Help(" ",1,"OFIGM10001")              //RR Possui Remessa
		DbSelectArea("VG8")
		RecLock("VG8",.F.) 
		VG8->VG8_OK := ""
		MsUnlock()
		DbSkip()
		Loop
	Endif
	                                            
	if VG8->VG8_TRANSM == "N"
		Help(" ",1,"OFIGM1000N")              //RR Nao Transmitida
		DbSelectArea("VG8")
		RecLock("VG8",.F.) 
		VG8->VG8_OK := ""
		MsUnlock()
		DbSkip()
		Loop
	Endif
	
	if !Empty(VG8->VG8_EXCLUI)
		Help(" ",1,"OFIGM10003")              //RR Excluida
		DbSelectArea("VG8")
		RecLock("VG8",.F.) 
		VG8->VG8_OK := ""
		MsUnlock()
		DbSkip()
		Loop
	Endif
	
	if !Empty(VG8->VG8_RRCNEW)
		Help(" ",1,"OFIGM10004")              //RR Reconsiderada
		DbSelectArea("VG8")
		RecLock("VG8",.F.) 
		VG8->VG8_OK := ""
		MsUnlock()
		DbSkip()
		Loop
	Endif
	
	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(xFilial("VO1")+VG8->VG8_NUMOSV)
	
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)
	
	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+VG8->VG8_CODCLI+VG8->VG8_LOJA)
	
	cConPag := VE4->VE4_PGTPED
	
	DbSelectArea("SA2")
	DbSetOrder(3)
	If !DbSeek(xFilial("SA2")+SA1->A1_CGC)
		FGX_SA1SA2(SA1->A1_COD,SA1->A1_LOJA,.t.) //Cadatrar o cliente como fornecedor
		//      Help(" ",1,"OFIGM10005")
		//      MATA020()
	Endif
	
	DbSelectArea("VG6")
	Dbsetorder(5)
	DbSeek(xFilial("VG6")+VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC)
	
	While !Eof() .And. VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC == VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC .and. VG6->VG6_FILIAL == xFilial("VG6")
		
		if Empty(VG6->VG6_EXCLUI) .And. VG6->VG6_TRANSM == "S" .And. !empty(VG6->VG6_PECINT)
			//         FG_SEEK("SB0","VG6->VG6_PECINT",1,.F.)
			DbSelectArea("SB1")
			Dbsetorder(7)
			DbSeek(xFilial("SB1")+VG6->VG6_GRUITE+VG6->VG6_CODITE)
			
			DbSelectArea("SB5")
			Dbsetorder(1)
			DbSeek(xFilial("SB5")+SB1->B1_COD)
			
			aAdd(aStruLIB,{.f.,VG6->VG6_CODMAR,VG6->VG6_NUMOSV,VG6->VG6_ANORRC,VG6->VG6_NUMRRC,VG6->VG6_GRUITE,VG6->VG6_CODITE,SB1->B1_DESC,VG6->VG6_NOSNUP,VG6->VG6_PECINT,FG_Formula(VE4->VE4_FOEXNF),VG6->VG6_QTDITE,VO1->VO1_PROVEI,VO1->VO1_LOJPRO,SA1->A1_CGC,VG8->VG8_CODCLI,VG8->VG8_LOJA,FG_Formula(VE4->VE4_FOIMNF)})
		Endif
		DbSelectArea("VG6")
		DbSkip()
	Enddo
	
	DbSelectArea("VG8")
	RecLock("VG8",.F.) 
	VG8->VG8_OK := ""
	MsUnlock()
	DbSkip()
	
Enddo
 
If Len(aStruLIB) == 0
	aadd(aStruLIB,{ .f.,"","","","","","","","","XXXXX",0,0,"","","","","",0})
Endif

nOpca := 1
DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0014) FROM  39,20 TO 54,84 OF oMainWnd // //"Pecas"

//Pecas da RR
//@ 12,.1 LISTBOX oLbox FIELDS HEADER   OemToAnsi(""),;            //Indicador de Relacionamento
@ 16,.1 LISTBOX oLbox FIELDS HEADER   OemToAnsi(""),;            //Indicador de Relacionamento
OemToAnsi(STR0007),;       //Marca // //"Marca"
OemtoAnsi(STR0015),;       //Ord.Serv // //"Ord. Servico"
OemToAnsi(STR0016),;       //Ano // //"Ano"
OemtoAnsi(STR0017),;       //Num.RR // //"Nro. RR"
OemtoAnsi(STR0018),;       //Grupo // //"Grupo"
OemToAnsi(STR0019),;       //Cod. Item // //"Cod. Item"
OemToAnsi(STR0020),;       //Desc Item // //"Descricao"
OemToAnsi(STR0021),;       //Val.Item // //"Valor"
OemToAnsi(STR0022),;        //Qtdade // //"Qtdade"
OemToAnsi("Vlr Ent");        //Valor Entrada
COLSIZES 10,20,30,20,30,40,40,40,40,40;
SIZE 254,101 OF Odlg PIXEL ON DBLCLICK (nPos:=oLbox:nAt,FS_Marca(),oLbox:Refresh(),oLbox:nAt:=nPos)

oLbox:SetArray(aStruLIB)
oLbox:bLine := { || { if(aStruLIB[oLbox:nAt,01] == .f.,oNo,oTik),;
aStruLIB[oLbox:nAt,02],;
aStruLIB[oLbox:nAt,03],;
aStruLIB[oLbox:nAt,04],;
aStruLIB[oLbox:nAt,05],;
aStruLIB[oLbox:nAt,06],;
aStruLIB[oLbox:nAt,07],;
aStruLIB[oLbox:nAt,08],;
Transform(aStruLIB[oLbox:nAt,11],"@E 999,999.99"),;
aStruLIB[oLbox:nAt,12],;
Transform(aStruLIB[oLbox:nAt,18],"@E 999,999.99")}}
oLbox:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, { || FS_SELITENS(), nOpca := 1, oDlg:End() } , { || nOpca := 2, oDlg:End() } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Marca ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do listbox para marcar as pecas que serao enviadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_Marca()

If aStruLIB[oLbox:nAt,10] <> "XXXXX"
	
	If aStruLIB[oLbox:nAt,1] == .f.
		aStruLIB[oLbox:nAt,1] := .t.
	Else
		aStruLIB[oLbox:nAt,1] := .f.
	Endif
	
	oLbox:SetArray(aStruLIB)
	oLbox:bLine := { || { if(aStruLIB[oLbox:nAt,01] == .f.,oNo,oTik),;
	aStruLIB[oLbox:nAt,02],;
	aStruLIB[oLbox:nAt,03],;
	aStruLIB[oLbox:nAt,04],;
	aStruLIB[oLbox:nAt,05],;
	aStruLIB[oLbox:nAt,06],;
	aStruLIB[oLbox:nAt,07],;
	aStruLIB[oLbox:nAt,08],;
	Transform(aStruLIB[oLbox:nAt,11],"@E 999,999.99"),;
	aStruLIB[oLbox:nAt,12],;
	Transform(aStruLIB[oLbox:nAt,18],"@E 999,999.99")}}
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_SELITENS³ Autor ³Renata                ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem dos vetores com as pecas marcadas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM100M(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SELITENS()

Local i    := 0
Local lVG8 := .f.
Local x	   := 0

Private nCont       := 1
Private aVG6Trb     := {}
Private cNumero     := ""
Private lFormul     := .t.
Private cCgcFor     := space(6)
Private cCgcCli     := space(6)
Private lMsHelpAuto := .t.
Private lMsErroAuto := .f.
Private lAbortPrint := .f.

DbSelectArea("SX5")
DbSetOrder(1)
DbSeek( xFilial("SX5") + "01" )

aVG6S := {}

aSort(aStruLib,1,,{|x,y| x[16]+x[17]+x[2]+x[3]+x[4]+x[5] <= y[16]+y[17]+y[2]+y[3]+y[4]+y[5]} )

For i:=1 to len(aStruLIB)
	cKey := aStruLIB[i,10]
	DbSelectArea("SB1")
	Dbsetorder(1)
	DbSeek(xFilial("SB1")+cKey)
	
	DbSelectArea("SB5")
	Dbsetorder(1)
	DbSeek(xFilial("SB5")+cKey)
	
	if aStruLIB[i,01]
		lVG8 := .t.
		DbSelectArea("VG6")
		DbSetorder(3)
		DbSeek(xFilial("VG6")+aStruLIB[i,02]+aStruLIB[i,03]+aStruLIB[i,10]+aStruLIB[i,04]+aStruLIB[i,05]) //marc+OS+cod.int.peca+ano+rr
		
		DbSelectArea("VG8")
		DbSetorder(1)
		DbSeek(xFilial("VG8")+VG6->VG6_FILIAL+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC) //marc+OS+cod.int.peca+ano+rr
		
		DbSelectArea("VG6")
		DbSetorder(3)
		
		nPos := aScan(aVG6S,{|x| x[14]+x[15]+x[1]+x[2]+x[3]+x[4]+x[5] == aStruLib[i,16]+ aStruLib[i,17]+ aStruLib[i,2]+ aStruLib[i,3]+ aStruLib[i,4]+ aStruLib[i,5]+aStruLib[i,10] },)
		
		if nPos ==0
			
			aAdd(aVG6S,{VG6->VG6_CODMAR,;
			VG6->VG6_NUMOSV,;
			VG6->VG6_ANORRC,;
			VG6->VG6_NUMRRC,;
			VG6->VG6_PECINT,;
			VG6->VG6_CODITE,;
			VG6->VG6_VALITE,;
			aStruLib[i,11],;
			VG6->VG6_QTDITE,;
			aStruLib[i,13],;
			aStruLib[i,14],;
			.f.,;
			aStruLib[i,15],;
			aStruLib[i,16],;
			aStruLib[i,17],;
			"",;
			aStruLib[i,18]})
		Endif
	Elseif !aStruLIB[i,01] .And. SB1->B1_ENVOBR = "S"
		Help(" ",1,"OFIGM10008")        //peca de envio obrigatorio nao marcada
	Endif
Next

if Len(aVG6S) = 0
	Help(" ",1,"OFIGM10009")           //nao existe pecas marcadas para emissao
	Return
EndIf

Begin Transaction

aSort(aVG6S,1,,{|x,y| x[14]+x[15]+x[2]+x[3]+x[4]+x[5] <= y[13]+y[14]+y[2]+y[3]+y[4]+y[5]} )

aVG6Trb := {}
cCliente:= ""
For x:=1 to Len(aVG6S)
	
	If Empty(cCliente)
		cCliente := aVG6S[x,14]+aVG6S[x,15]
	EndIf
	
	aadd(aVG6Trb,{aVG6S[x,1],aVG6S[x,2],aVG6S[x,3],aVG6S[x,4],aVG6S[x,5],;
	aVG6S[x,6],aVG6S[x,7],aVG6S[x,8],aVG6S[x,9],aVG6S[x,10],;
	aVG6S[x,11],aVG6S[x,12],aVG6S[x,13],aVG6S[x,14],aVG6S[x,15],aVG6S[x,16],aVG6S[x,17]})
	
	//NF Entrada - 10% do valor do preco de venda, Tributada
	If x==Len(aVG6S) .Or. cCliente # aVG6S[x+1,14]+aVG6S[x+1,15]
	
		cCgcFor := aVG6S[x,13]
	
		if !FS_ENTNOT(aVG6Trb)         
			DisarmTransaction()
			return
		endif

		aVG6Trb := {}

	EndIf
	cCliente := aVG6S[x,14]+aVG6S[x,15]
	
Next

/*
aVG6Trb := {}
cCliente:= ""
For x:=1 to Len(aVG6S)

If Empty(cCliente)
cCliente := aVG6S[x,14]+aVG6S[x,15]
EndIf

aadd(aVG6Trb,{aVG6S[x,1],aVG6S[x,2],aVG6S[x,3],aVG6S[x,4],aVG6S[x,5],;
aVG6S[x,6],aVG6S[x,7],aVG6S[x,8],aVG6S[x,9],aVG6S[x,10],;
aVG6S[x,11],aVG6S[x,12],aVG6S[x,13],aVG6S[x,14],aVG6S[x,15],aVG6S[x,16]})

//NF Entrada - 10% do valor do preco de venda, Tributada
If x==Len(aVG6S) .Or. cCliente # aVG6S[x+1,14]+aVG6S[x+1,15]
cCGCCLI := aVG6S[x,13]
FS_SAINOT(aVG6Trb)
aVG6Trb := {}
EndIf
cCliente := aVG6S[x,14]+aVG6S[x,15]

Next
*/

aVG6Trb := {}
For x:=1 to Len(aVG6S)
	
	aadd(aVG6Trb,{aVG6S[x,1],aVG6S[x,2],aVG6S[x,3],aVG6S[x,4],aVG6S[x,5],;
	aVG6S[x,6],aVG6S[x,7],aVG6S[x,8],aVG6S[x,9],aVG6S[x,10],;
	aVG6S[x,11],aVG6S[x,12],aVG6S[x,13],aVG6S[x,14],aVG6S[x,15],aVG6S[x,16],aVG6S[x,17]})
	
Next

        
if !FS_SAI1()         //nf saida - 10% do valor do preco de venda, tributada
	DisarmTransaction()
	return
endif

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

If lMsErroAuto
	MostraErro()
Else
	
	If ExistBlock("OGM100TEL")
		ExecBlock("OGM100TEL",.f.,.f.)
	EndIf
	
	
	//Executa RdMake da Nota Fiscal de Entrada
	For x:=1 to Len(aEnt1)
		
		If ExistBlock("NFENTPEC")
			ExecBlock("NFENTPEC",.f.,.f., { aEnt1[x,1] ,  aEnt1[x,2] , aEnt1[x,3] , aEnt1[x,4] } )
		EndIf
		
	Next
	
	//Executa RdMake da Nota Fiscal
	For x:=1 to Len(aSAI1)
		
		If ExistBlock("NFPECSER")
			ExecBlock("NFPECSER",.f.,.f., { aSAI1[x,1] , aSAI1[x,2] } )
		EndIf
		
	Next
	
	//	If MsgYesNo(STR0023 ,STR0024)
	//		IA140E("VG8",VG8->(Recno()),3)
	//	EndIf
	
	MSGSTOP(STR0025+cNumero)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ENTNOT ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do vetor para a chamda do MATA100                 ³±±
±±³          ³ nota fiscal de entrada tributada com 10% do valor do item  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_ENTNOT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ENTNOT()

Local aCabNFE     := {}
Local aIteTempNFE := {}
Local nValIcm := nBasIcm := 0, cCencus, cAlmPec, cFornec, cLojaF, lFim
Local nIcmRet := nValIte10 := 0 , cCont:="00"
Local i := 0
Local aIteNFE := {}

Private cTes

lFim    := .f.
nValTot := 0
nValIcm := 0
nBasIcm := 0
cLojaF  := space(2)
cCencus := space(9)
cAlmPec := space(2)

DbSelectArea("SA2")
Dbsetorder(3)
DbSeek(xFilial("SA2")+cCGCFOR)

cFornec := SA2->A2_COD
cLojaF  := SA2->A2_LOJA

If lFormul
	cNumero := NxtSX5Nota(cSerie)
EndIf

aAdd(aCabNFE,{"F1_TIPO"    ,"N"            ,Nil}) //
aAdd(aCabNFE,{"F1_FORMUL"  ,"S"            ,Nil}) //
aAdd(aCabNFE,{"F1_DOC"     ,cNumero        ,Nil}) //
aAdd(aCabNFE,{"F1_SERIE"   ,cSerie         ,Nil}) //
aAdd(aCabNFE,{"F1_EMISSAO" ,dDataBase      ,Nil}) //
aAdd(aCabNFE,{"F1_FORNECE" ,cFornec        ,Nil}) //
aAdd(aCabNFE,{"F1_LOJA"    ,cLojaF         ,Nil}) //
aAdd(aCabNFE,{"F1_COND"    ,cConPag        ,Nil}) //
aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
//aAdd(aCabNFE,{"F1_ESPECIE" ,"NF"           ,Nil}) //
aAdd(aCabNFE,{"F1_ICMSRET" ,nIcmRet        ,Nil}) //

lMSHelpAuto := .t.

For i:=1 to len(aVG6Trb)
	
	aIteTempNFE := {}
	
	nValIte10 := Round(aVG6Trb[i,17],2)
	
	cKey := aVG6Trb[i,5]
	
	DbSelectArea("SB1")
	Dbsetorder(1)
	DbSeek(xFilial("SB1")+cKey)
	
	//    cTes := FG_TABTRIB("09","SB1->B1_ORIGEM") //SIMPLES REMESSA
	//    cTes := FG_TABTRIB(VE4->VE4_CDOPEN,"SB1->B1_ORIGEM") //SIMPLES REMESSA
	SFM->(DBSetOrder(1))
	SFM->(DBSeek(xFilial("SFM")+VE4->VE4_CDOPEN))
	cTes := MaTesInt(1,VE4->VE4_CDOPEN,cFornec,cLojaF,"F",SB1->B1_COD)
	
	DbSelectArea("SF4")
	Dbsetorder(1)
	DbSeek(xFilial("SF4")+cTes)

	if Empty(cTes) .or. !found()
		MsgInfo(STR0026 + VE4->VE4_CDOPEN)
		return .f.
	endif
	
	cCont := Soma1(cCont,2)
	
	aAdd(aIteTempNFE,{"D1_ITEM"    ,cCont                       ,Nil})
	aAdd(aIteTempNFE,{"D1_COD"     ,aVG6Trb[i,5]                ,Nil})
	aAdd(aIteTempNFE,{"D1_UM"      ,"PC"                         ,Nil})
	aAdd(aIteTempNFE,{"D1_QUANT"   ,aVG6Trb[i,9]                ,Nil})
	aAdd(aIteTempNFE,{"D1_VUNIT"   ,nValIte10                    ,Nil})
	aAdd(aIteTempNFE,{"D1_TOTAL"   ,nValite10*aVG6Trb[i,9]      ,Nil})
	aAdd(aIteTempNFE,{"D1_VALIPI"  ,0                            ,Nil})
	aAdd(aIteTempNFE,{"D1_VALICM"  ,nValICM                      ,Nil})
	aAdd(aIteTempNFE,{"D1_BASEIPI" ,0                            ,Nil})
	aAdd(aIteTempNFE,{"D1_BASEICM" ,nBasIcm                      ,Nil})
	aAdd(aIteTempNFE,{"D1_TES"     ,cTES                         ,Nil})
	// Nao passar o CFOP para que o Sistema se vire no momento de tratar cliente de Outro Estado
	//    aAdd(aIteTempNFE,{"D1_CF"      ,SF4->F4_CF                   ,Nil})
	aAdd(aIteTempNFE,{"D1_CONTA"   ,SB1->B1_CONTA                ,Nil})
	aAdd(aIteTempNFE,{"D1_CC"      ,cCenCus                      ,Nil})
	aAdd(aIteTempNFE,{"D1_RATEIO"  ,"2"                          ,Nil})
	aAdd(aIteTempNFE,{"D1_LOCAL"   ,cAlmPec                      ,Nil})
	
	aadd(aIteNFE,aIteTempNFE)
	
Next

SB1->(DbSetOrder(1))
MsErroAuto := .f.
//MSExecAuto({|x,y| MATA100(x,y)},aCabNFE,aIteNFE)
MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,aIteNFE)
If lMsErroAuto
   return .F.
EndIf

Aadd(aEnt1 , { cNumero , cSerie , cFornec , cLojaF } )

&& Grava relacionamento do arquivos SF1/SD1=VG8/VG6
For i:=1 to Len(aVG6trb)
	DbSelectArea("VG8")
	DbSetOrder(1)
	If DbSeek(xFilial("VG8")+aVG6trb[i,1]+aVG6trb[i,2]+aVG6trb[i,3]+aVG6trb[i,4])
		RecLock("VG8",.F.)
		VG8->VG8_NFIENT := cNumero
		VG8->VG8_SERENT := cSerie
		MsUnLock()
	EndIf
	DbSelectArea("VG6")
	DbSetOrder(3)
	If DbSeek(xFilial("VG6")+aVG6trb[i,1]+aVG6trb[i,2]+aVG6trb[i,5]+aVG6trb[i,3]+aVG6trb[i,4])
		RecLock("VG6",.F.)
		VG6->VG6_NFIENT := cNumero
		VG6->VG6_SERENT := cSerie
		MsUnLock()
	EndIf
Next

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SAI1  ³ Autor ³Andre                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do vetor para a chamda do MATA410                 ³±±
±±³          ³ nota fiscal de saida tributada c/ 10% do valor do item     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_SAI1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SAI1()

Local aIteTempPV := {} , aPvlNfs := {}
Local nValIte10 := 0 , cCont:="00"
Local i			:= 0


Private aCabPv := {}
Private aItePv := {}

Private cNumped

//lFormul := Sx5NumNota()
//cSerie  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao e Liberacao dos Pedidos de Venda                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VAI")
Dbsetorder(4)
DbSeek(xFilial("VAI")+__cUserID)

DbSelectArea("SA3")
Dbsetorder(1)
DbSeek(xFilial("SA3")+VAI->VAI_CODVEN)

DbSelectArea("SA1")
Dbsetorder(3)
DbSeek(xFilial("SA1")+VE4->VE4_CGCFAB)

cNumped  := CriaVar("C5_NUM")

//Cabecalho
aAdd(aCabPV,{"C5_NUM"    ,cNumped          ,Nil}) // Numero do pedido
aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD      ,Nil}) // Codigo do cliente
aAdd(aCabPV,{"C5_LOJAENT",SA1->A1_LOJA     ,Nil}) // Loja para entrada
aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA     ,Nil}) // Loja do cliente
aAdd(aCabPV,{"C5_TIPO"   ,"N"              ,Nil}) // Tipo de pedido
aAdd(aCabPV,{"C5_CONDPAG",cConPag          ,Nil}) // Codigo da condicao de pagamanto - SE4
aAdd(aCabPV,{"C5_VEND1"  ,SA3->A3_COD     ,Nil}) // Codigo do vendedor - SA3
aAdd(aCabPV,{"C5_EMISSAO",dDataBase        ,Nil}) // Data de emissao
//aAdd(aCabPV,{"C5_TABELA" ,"1"              ,Nil}) // Codigo da Tabela de Preco
aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO     ,Nil}) // Tipo do Cliente
aAdd(aCabPV,{"C5_DESC1"  ,0                ,Nil}) // Percentual de Desconto
aAdd(aCabPV,{"C5_INCISS" ,"N"              ,Nil}) // ISS Incluso
aAdd(aCabPV,{"C5_TIPLIB" ,"2"              ,Nil}) //
aAdd(aCabPV,{"C5_MOEDA"  ,1                ,Nil}) // Moeda
aAdd(aCabPV,{"C5_LIBEROK","S"              ,Nil}) // Liberacao Total
aAdd(aCabPV,{"C5_COMIS1" ,0                ,Nil}) // Percentual de Comissao
aAdd(aCabPV,{"C5_TRANSP" ,cCodTransp  	,Nil})  // Transportadora
aadd(aCabPV,{"C5_TPFRETE",cTipFrete   ,Nil})    // Tipo de Frete
If SC5->(FieldPos("C5_INDPRES")) > 0 
	aAdd(aCabPV,{"C5_INDPRES"  ,'0'	,Nil}) 	// Presenca do Comprador
Endif

For i = 1 to len(aVG6trb)
	
	aIteTempPV := {}
	
	//Items
	DbSelectArea("SB1")
	Dbsetorder(1)
	DbSeek(xFilial("SB1")+aVG6trb[I,5])
	
	//   cTes := FG_TABTRIB("10","SB1->B1_ORIGEM") //SIMPLES REMESSA
	//   cTes := FG_TABTRIB(VE4->VE4_CDOPSA,"SB1->B1_ORIGEM") //SIMPLES REMESSA
	SFM->(DBSetOrder(1))
	//	 SFM->(DBSeek(xFilial("SFM")+VE4->VE4_CDOPSA))
	SFM->(DBSeek(xFilial("SFM")+VE4->VE4_CDOPEN)) //COM O TES INTELIGENTE SO PRECISO DE UMA OPERACAO QUE TRATA AS DUAS SITUACOES
	cTes := MaTesInt(2,VE4->VE4_CDOPSA,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
	
	DbSelectArea("SF4")
	Dbsetorder(1)
	DbSeek(xFilial("SF4")+cTes)
	
	if Empty(cTes) .or. !found()
		MsgInfo(STR0026 + VE4->VE4_CDOPEN)
		return .f.
	endif
	
	DbSelectArea("SB5")
	Dbsetorder(1)
	DbSeek(xFilial("SB5")+SB1->B1_COD)
	
	DbSelectArea("SB2")
	Dbsetorder(1)
	DbSeek(xFilial("SB2")+SB1->B1_COD)
	
	/* Valor de 10% do preco do item */
	nValIte10 := round(aVG6trb[i,8],2)
	
	cCont := Soma1( cCont , 2 )
	
	aVG6trb[i,15] := cCont
	
	aAdd(aIteTempPV,{"C6_NUM"    ,cNUMPED               ,Nil}) // Numero do Pedido
	aAdd(aIteTempPV,{"C6_ITEM"   ,cCont                 ,Nil}) // Numero do Item no Pedido
	aAdd(aIteTempPV,{"C6_PRODUTO",aVG6trb[i,5]           ,Nil}) // Codigo do Produto
	aAdd(aIteTempPV,{"C6_QTDVEN" ,aVG6trb[i,9]           ,Nil}) // Quantidade Vendida
	aAdd(aIteTempPV,{"C6_PRUNIT" ,nValIte10              ,Nil}) // Preco Unitario Garantia
	aAdd(aIteTempPV,{"C6_PRCVEN" ,nValIte10              ,Nil}) // Preco Unitario Liquido
	aAdd(aIteTempPV,{"C6_VALOR"  ,nValIte10*aVG6trb[i,9] ,Nil}) // Valor Total do Item
	aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase             ,Nil}) // Data da Entrega
	aAdd(aIteTempPV,{"C6_UM"     ,"PC"                  ,Nil}) // Unidade de Medida Primar.
	aAdd(aIteTempPV,{"C6_TES"    ,cTes                  ,Nil}) // Tipo de Entrada/Saida do Item
	aAdd(aIteTempPV,{"C6_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil}) // Almoxarifado
	// Nao passar o CFOP para que o Sistema se vire no momento de tratar cliente de Outro Estado
	//   aAdd(aIteTempPV,{"C6_CF"     ,SF4->F4_CF            ,Nil}) // CFO
	//   aAdd(aIteTempPV,{"C6_VALDESC",0                     ,Nil}) // Valor do Desconto
	//   aAdd(aIteTempPV,{"C6_COMIS1" ,0                     ,Nil}) // Comissao Vendedor
	aAdd(aIteTempPV,{"C6_DESCRI" ,SB1->B1_DESC          ,Nil}) // Descricao do Produto
	aAdd(aIteTempPV,{"C6_CLI"    ,SA1->A1_COD           ,Nil}) // Cliente
	aAdd(aIteTempPV,{"C6_LOJA"   ,SA1->A1_LOJA          ,Nil}) // Loja do Cliente
	If GetVersao(.f.) == "P10"                 
		aAdd(aIteTempPV,{"C6_QTDEMP" ,aVG6trb[i,9]            ,Nil}) // Quantidade Empenhada
	Endif	
	aAdd(aIteTempPV,{"C6_QTDLIB" ,aVG6trb[i,9]            ,Nil}) // Quantidade Liberada
	
	aAdd(aItePv,aIteTempPV)
	
Next

If ExistBlock("OGM100PED")
	ExecBlock("OGM100PED",.f.,.f.)
EndIf

lMSHelpAuto := .t.
lMsErroAuto := .f.
FG_X3ORD("C",,aCabPv)
FG_X3ORD("I",,aItePv)
MsExecAuto({|x,y,z| mata410(x,y,z)},aCabPV,aItePv,3)
If lMsErroAuto
   return .F.
EndIf

DbSelectArea("SC9")
Dbsetorder(1)
DbSeek(xFilial("SC9")+cNumPed+"01")

While !Eof() .And. SC9->C9_FILIAL+SC9->C9_PEDIDO == xFilial("SC9")+cNumPed
	
	If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
		
		FG_Seek("SB1","SC9->C9_PRODUTO",1)
		FG_Seek("SC5","SC9->C9_PEDIDO",1,.F.)
		FG_Seek("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
		FG_Seek("SB5","SB1->B1_COD")
		FG_Seek("SB2","SB1->B1_COD")
		FG_Seek("SE4","cConPag",1)
		
		aAdd(aPvlNfs,{C9_PEDIDO,;
		C9_ITEM,;
		C9_SEQUEN,;
		C9_QTDLIB,;
		C9_PRCVEN,;
		C9_PRODUTO,;
		SF4->F4_ISS=="S",;
		SC9->(RecNo()),;
		SC5->(RecNo()),;
		SC6->(RecNo()),;
		SE4->(RecNo()),;
		SB1->(RecNo()),;
		SB2->(RecNo()),;
		SF4->(RecNo())})
	Else
		FG_X3ORD("C",,aCabPv)
		FG_X3ORD("I",,aItePv)
		MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItePv,5)
		If lMsErroAuto
			return .F.
		EndIf
	EndIf
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumero := MaPvlNfs(aPvlNfs,cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)

aadd(aSAI1,{cNumero,cSerie})

&& Grava relacionamento do arquivos SF2/SD2=VG8/VG6
For i:=1 to Len(aVG6trb)
	
	DbSelectArea("VG8")
	DbSetOrder(1)
	If DbSeek(xFilial("VG8")+aVG6trb[i,1]+aVG6trb[i,2]+aVG6trb[i,3]+aVG6trb[i,4])
		
		RecLock("VG8",.F.)
		VG8->VG8_NF1REM := cNumero
		//	   VG8->VG8_NF2REM := cSerie
		VG8->VG8_SERNFI := cSerie
		VG8->VG8_DATNFI := ddatabase
		MsUnLock()
		
	EndIf
	
	DbSelectArea("VG6")
	DbSetOrder(3)
	If DbSeek(xFilial("VG6")+aVG6trb[i,1]+aVG6trb[i,2]+aVG6trb[i,5]+aVG6trb[i,3]+aVG6trb[i,4])
		
		RecLock("VG6",.F.)
		VG6->VG6_RENNF1 := cNumero
		//		VG6->VG6_RENNF2 := cSerie
		VG6->VG6_SERNFI := cSerie
		VG6->VG6_ITEMNF := aVG6trb[i,15]
		MsUnLock()
		
	EndIf
	
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM100V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza dados do VG8/VG6 modelo 3                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM100V(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM100V(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk

Private Inclui := .f.
Private aRotina := { { "" ,"", 0, 1},;
{ "" ,"", 0 , 2},;    //VISUALIZAR
{ "" ,"", 0 , 4},;   //LIBERAR
{ "","",  0,  4}}
Private aCols := {} , aHeader := {} , aCpoEnchoice := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VG8",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VG8")

While !Eof().And.(x3_arquivo=="VG8")
	
	if X3USO(x3_usado).And.cNivel>=x3_nivel.And.!( Alltrim(x3_campo) $ [VG8_TRANSM/VG8_EXCLUI/VG8_CODSER/VG8_SERINT/VG8_EXPGAR])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	
	&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
	
	dbSkip()
	
End

If !(Inclui)
	DbSelectArea("VG8")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

if nOpc == 3   //ALTERAR
	nOpcE := 4
	nOpcG := 4
elseif nOpc == 2  //VISUALIZAR
	nOpcE := 2
	nOpcG := 2
else
	nOpcE := 5      //EXCLUIR
	nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0

dbSelectArea("SX3")
dbgotop()
dbSeek("VG6")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG6")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!( Alltrim(x3_campo) $ [VG6_TRANSM/VG6_EXCLUI/VG6_NOSNUP/VG6_NOSNUS])
		
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		
		&( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
		
	Endif
	
	dbSkip()
	
End

If Inclui
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	
Else
	
	aCols:={}
	dbSelectArea("VG6")
	dbSetOrder(5)
	dbSeek(xFilial()+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)
	
	While !Eof() .And. M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC == VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC ;
		.And. VG6->VG6_FILIAL == xFilial("VG6")
		
		AADD(aCols,Array(nUsado+1))
		
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
		Next
		
		aCols[Len(aCols),nUsado+1]:=.F.
		
		dbSkip()
		
	End
	
	dbsetorder(1)
	
Endif

If Len(aCols)>0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo       :=STR0001    //"Exclui Garantia"
	cAliasEnchoice:="VG8"
	cAliasGetD    :="VG6"
	cLinOk        :="FG_OBRIGAT()"
	cTudOk        :="AlwaysTrue()"
	cFieldOk      :="FG_MEMVAR()"
	
	Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OGM100BR  ³ Autor ³Luis Delorme           ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro para markbrow                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OGM100BR()

Local nRec   := 0
Local cQuery := ""
Local lRet   := .f.

cQuery := "SELECT R_E_C_N_O_ AS RECVG8 FROM "+RetSqlName("VG8")
cQuery += " WHERE "
cQuery += " VG8_FILIAL = '" + VG8->VG8_FILIAL + "' AND "
cQuery += " VG8_CODMAR = '" + VG8->VG8_CODMAR + "' AND "
cQuery += " VG8_NUMOSV = '" + VG8->VG8_NUMOSV + "' AND "
cQuery += " VG8_ANORRC = '" + VG8->VG8_ANORRC + "' AND "
cQuery += " VG8_NUMRRC = '" + VG8->VG8_NUMRRC + "' AND "
cQuery += " VG8_EXCLUI = ' ' AND VG8_RRCNEW = ' ' AND VG8_RRCNEW = 'N' AND VG8_NF1REM = ' ' AND D_E_L_E_T_ = ' ' "

nRec := FM_SQL(cQuery)
If nRec > 0
	lRet := .t.
EndIf

DbSelectArea("VG8")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef   ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Menu									                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {{ STR0002 ,"axPesqui", 0 , 1},; 	//Pesquisar
{ STR0003 ,"GM100V"  , 0 , 2},;	//Visualizar
{ STR0004 ,"GM100M"  , 0 , 4}}	//Emitir
Return aRotina


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaHelp ³ Autor ³ Rubens Takahashi     ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajuta help da Rotina                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHelp()

Local aHelpEng, aHelpSpa, aHelpPor

aHelpPor := { STR0029 }
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("POFIGM1000N",aHelpPor,aHelpEng,aHelpSpa,.f.)

Return