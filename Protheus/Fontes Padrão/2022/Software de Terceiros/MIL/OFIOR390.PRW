#INCLUDE "ofior390.ch"
#Include "protheus.ch"
#Include "FileIO.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOR390 ³ Autor ³  Andre                ³ Data ³ 27/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia do Bloqueto de Cobranca                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR390
Local nTamPref    := 0
Private cCadastro := OemToAnsi(STR0001)
Private cTipoNF   := ""
Private aRotina   := MenuDef()

aTipoNF  := {OemToAnsi(STR0002),OemToAnsi(STR0003),OemToAnsi(STR0004),STR0002+"+"+STR0003+"+"+STR0004,OemToAnsi(STR0005)} //"Pecas"###"Oficina"###"Veiculo"###"Pecas+Oficina+Veiculo"###"Todas"
nOpca    := 0

DEFINE FONT oFnt3 NAME "Arial" BOLD

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM  02,04 TO 08,28 OF oMainWnd && Tipo de Faturamento //"Tipo de Nota Fiscal"

@  02, 02 TO 22,091 LABEL OemtoAnsi("") OF oDlg PIXEL
@  07, 04 MSCOMBOBOX oTipoNF VAR cTipoNF SIZE 83,50 FONT oFnt3 ITEMS aTipoNF OF oDlg PIXEL

DEFINE SBUTTON FROM 27,26 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 27,57 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

If nOpca == 1
	
	DbSelectArea("SF2")
	nTamPref := TamSX3("F2_PREFORI")[1]
	cCond := ".t."
	
	Do Case
		
		Case cTipoNF == STR0002 //"Pecas"
			cCond := "SF2->F2_PREFORI=='"+left(GetNewPar("MV_PREFBAL","BAL")+space(nTamPref),nTamPref)+"'"
			
		Case cTipoNF == STR0003 //"Oficina"
			cCond := "SF2->F2_PREFORI=='"+left(GetNewPar("MV_PREFOFI","OFI")+space(nTamPref),nTamPref)+"'"
			
		Case cTipoNF == STR0004 //"Veiculo"
			cCond := "SF2->F2_PREFORI=='"+left(GetNewPar("MV_PREFVEI","VEI")+space(nTamPref),nTamPref)+"'"
			
		Case cTipoNF == STR0002+"+"+STR0003+"+"+STR0004
			cCond := "SF2->F2_PREFORI $ ('"+left(GetNewPar("MV_PREFBAL","BAL")+space(nTamPref),nTamPref)+"/"+left(GetNewPar("MV_PREFOFI","OFI")+space(nTamPref),nTamPref)+"/"+left(GetNewPar("MV_PREFVEI","VEI")+space(nTamPref),nTamPref)+"')"
			
		Case cTipoNF == STR0005 //"Todas"
			cCond := ".t."
			
	EndCase
	
Else
	
	Return .t.
	
EndIf

*** Deve ser utilizado uma IndRegua
cIndSF2 := CriaTrab(Nil, .F.)
cChave  := "F2_FILIAL+F2_DOC+F2_SERIE"

IndRegua("SF2",cIndSF2,cChave,,cCond,OemToAnsi(STR0007) ) //"Nota Fiscal"

mBrowse( 6, 1,22,75,"SF2")

DbSelectArea("SF2")
RetIndex()

#IFNDEF TOP
	If File(cIndSF2+OrdBagExt())
		fErase(cIndSF2+OrdBagExt())
	Endif
#ENDIF

Return


Function ImpBLQ()
*****************

Local bCampo   := { |nCPO| Field(nCPO) }
Local aPages:= {}, aVar:={}
Local i := 0
Local _ni := 0

Private aTELA[0][0], aGETS[0], aHeader[0]
Private nTotDes := 0
Private nTotOrc := 0
Private nTotPec := 0
Private nTotSrv := 0
Private nP := 1
Private oLbEntIte
Private lPri := .t.
Private aCabPV  := {}
Private aItePV  := {}
Private cCodVen
Private lAbortPrint := .f.

aRotina := { { " " ," " , 0, 1},;   //Pesquisar
{ " " ," " , 0, 2},;   //Visualizar
{ " " ," " , 0, 3},;   //Incluir
{ " " ," " , 0, 4},;   //Alterar
{ " " ," " , 0, 5} }   //Excluir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo        := STR0008 //"Consulta Nota Fiscal"
cAliasEnchoice := "SF2"
cLinOk         := "AllwaysTrue()"
cTudoOk        := "AllwaysTrue()"
cFieldOk       := "FG_MEMVAR()"

nOpc :=2
nOpcE:=2
nOpcG:=2

nOpca:=0

lRefresh := .t.
Inclui   := .f.
lVirtual := .f.
nLinhas  := 99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     &
RegToMemory("SF2",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SF2")
While !Eof().and.(x3_arquivo=="SF2")
	If X3USO(x3_usado).and.cNivel>=x3_nivel .and. ( AllTrim(x3_campo) $ [F2_DOC#F2_SERIE#F2_CLIENTE#F2_LOJA#F2_EMISSAO#F2_VALBRUT])
		AADD(aCpoEnchoice,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= &(x3_campo)
	dbSkip()
End

DbSelectArea("SF2")
For i:=1 to Len(aCpoEnchoice)
	wVar := "M->"+aCpoEnchoice[i]
	&wVar:= &("SF2->"+aCpoenchoice[i])
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("SD2")
aHeader:={}
While !Eof().And.(x3_arquivo=="SD2")
	If X3USO(x3_usado) .and. ( AllTrim(SX3->X3_CAMPO) $ "D2_ITEM#D2_COD#D2_QUANT#D2_PRCVEN#D2_TOTAL#D2_TES#D2_PEDIDO#" )
		nUsado++
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

aCols:={Array(nUsado+1)}
aCols[1,nUsado+1]:=.F.
For _ni:=1 to nUsado
	aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next

aCols := {}
DbSelectArea("SD2")
dbSetOrder(3)
Fg_Seek("SD2","SF2->F2_DOC+SF2->F2_SERIE",3,.F.)
While SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE .and. !eof()
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
EndDo

if Len(aCols) == 0
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Endif

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

nTotPec := SF2->F2_VALBRUT
nTotDes := SF2->F2_DESCONT
nTotOrc := SF2->F2_VALBRUT-SF2->F2_DESCONT

DEFINE MSDIALOG oDlg FROM 000,000 TO 027,080 TITLE cTitulo OF oMainWnd

// Folder 1

Zero()
oGetMGet:= MsMGet():New("SF2",0,nOpcE,,,,aCpoEnchoice,{014,002,084,312},,2,,,,oDlg,,.T.,.F.)

@ 180,002 Say OemToAnsi(STR0009)    SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLUE //"Pecas/Servicos"
@ 180,042 msget oTotPec VAR nTotPec Picture "999,999.99" SIZE 40,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 180,121 Say OemToAnsi(STR0013) SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE //Desconto
@ 180,152 msget oTotDes VAR nTotDes Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.
@ 180,228 Say OemToAnsi(STR0010)    SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLUE //"Total"
@ 180,263 msget oTotOrc VAR nTotOrc Picture "999,999.99" SIZE 50,08 OF oDlg PIXEL COLOR CLR_BLACK when .f.

aHeader  := aClone(aHeader)
aCols    := aClone(aCols)
oGetPecas                       := MsGetDados():New(089,002,176,312,nOpcG,cLinOk,cTudoOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oDlg)
oGetPecas:oBrowse:default()

ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()}) )

if nOpca == 1
	Processa( {|| IMPBLQRDM() } )
Endif

Return

Function IMPBLQRDM()
********************

FG_SEEK("SD2","SF2->F2_DOC+SF2->F2_SERIE",3,.F.)
FG_SEEK("SC5","SD2->D2_PEDIDO",1,.F.)
FG_SEEK("SA6","SC5->C5_BANCO",1,.F.)

cObs1 := Substr(SA6->A6_MENSAGE,001,40)
cObs2 := Substr(SA6->A6_MENSAGE,041,40)
cObs3 := Substr(SA6->A6_MENSAGE,081,40)

cPrefixo := SF2->F2_PREFIXO

If ExistBlock("BLQCOB")
	ExecBlock("BLQCOB",.f.,.f.,{SF2->F2_DUPL,,,,cPrefixo,"1",cObs1,cObs2,cObs3,SC5->C5_BANCO})
else
	Help(1," ","NOWINDOWS",,STR0014,4,1)  //O Nome do RDMAKE padrao eh BLQCOB
Endif

Return

Static Function MenuDef()
Local aRotina := {{OemToAnsi(STR0006),"AxPesqui",0,1},;
{OemToAnsi(STR0007),"ImpBLQ"  ,0,2}}
Return aRotina
