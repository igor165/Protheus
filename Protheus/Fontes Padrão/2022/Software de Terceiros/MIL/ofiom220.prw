// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 42     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Protheus.ch"
#include "Ofiom220.ch"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Rubens Takahashi
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007396_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM220 ³ Autor ³ Andre                 ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelamento da Venda de Pecas                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM220
Local cFiltro   := ""

Private aRotina := MenuDef()
Private cCadastro := STR0025  //Cancelamento de Nota Fiscal de Venda

DbSelectArea("SF2")
DbSetOrder(1)
cFiltro := " F2_PREFORI = '"+GetNewPar("MV_PREFBAL","BAL")+"' " // Filtra a nota fiscal de pecas

cFiltro += " AND EXISTS ( "
cFiltro += " SELECT VS1.VS1_NUMNFI FROM "+RetSQLName("VS1")+" VS1 "
cFiltro += " WHERE "
cFiltro += " VS1.VS1_FILIAL = F2_FILIAL AND "
cFiltro += " VS1.VS1_NUMNFI = F2_DOC    AND "
cFiltro += " VS1.VS1_SERNFI = F2_SERIE  AND "
cFiltro += " VS1.VS1_TIPORC = '1'       AND "
cFiltro += " VS1.D_E_L_E_T_=' ' ) "

mBrowse( 6, 1,22,75,"SF2",,,,,,,,,,,,,,cFiltro)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ExcNota  ³ Autor ³ Mil                   ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Excluir/Cancelamento Venda                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM220ExcNota()

Local bCampo   := { |nCPO| Field(nCPO) }
Local aPages:= {}, aVar:={}
Local nPar
Local i := 0
Local _ni := 0
Local cont
Private cPrefix := ""

Private aNewBot := {{"RELATORIO","Mc090Cons(1,aPedidos)",STR0006}} //Consulta Pedido

For i:=1 to Len(aNewBot)
	Private cFunc&(alltrim(Str(i))) := aNewBot[i,2]
Next
Private aPedidos := {}
Private cFcBot
Private cCodVen
Private cNota   := ""
Private cSerie  := ""
Private aTELA[0][0], aGETS[0], aHeader[0]
Private cTipoNF := "B"
Private nTotDes     := 0
Private nTotOrc     := 0
Private nTotPec     := 0
Private nTotSrv     := 0
Private nC          := 1
Private nNF         := 1
Private lPri        := .t.
Private aCabPV      := {}
Private aItePV      := {}
Private lAbortPrint := .f.
Private lMsHelpAuto := .t.
Private lMsErroAuto := .f. //Se retornar .t. deu erro
Private cPrefNF     := &(GetNewPar("MV_1DUPREF","cSerie"))
cPrefNF := cPrefNF+space(TamSx3("E1_PREFIXO")[1]-Len(cPrefNF))

aRotina := { { " " ," " , 0, 1},;      		//Pesquisar
{ " " ," " , 0, 2},;      	//Visualizar
{ " " ," " , 0, 3},;      	//Incluir
{ " " ," " , 0, 4},;   	//Alterar
{ " " ," " , 0, 5} }   	//Excluir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo        := STR0007 //Consulta Nota Fiscal
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
//³ Posciona no Arquivo de Orcamento                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VS1")
DbSetOrder(3)
DbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)

cPrefix := iif(VS1->VS1_SERNFI <> GetNewPar("MV_SERCUP","CUP"),&(GetNewPar("MV_1DUPREF","cSerie")),GetNewPar("MV_SERCUP","CUP"))

If VS1->VS1_CFNF == "2"	//Integrado com o Sigaloja ?
	MsgInfo(STR0026,STR0020)// Esta rotina so e utilizada qdo nao ha Integracao com o LOJA... ##Atencao
	Return .f.
Endif

if VS1->VS1_TIPORC == "3"
	MsgStop(STR0032) // Esta Nota Fiscal é de Transferência, portanto deve ser cancelada através da rotina de Transferências de Peças (OFIOM430).
	Return(.f.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no Tipos de Condicao de Pagamento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SE4")
DbSeek(xFilial("SE4")+SF2->F2_COND)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posciona no cliente                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA1")
DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SF2",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SF2")
While !Eof().and.(x3_arquivo=="SF2")
	If X3USO(x3_usado).and.x3_nivel > 0
		AADD(aCpoEnchoice,x3_campo)
	EndIf
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

dbSelectArea("SF2")
For cont := 1 TO FCount()
	M->&(EVAL(bCampo,cont)) := FieldGet(cont)
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoNF:=0
dbSelectArea("SX3")
dbSeek("SD2")
aHeaderNF:={}
While !Eof().And.(x3_arquivo=="SD2")
	If X3USO(x3_usado) // .and. ( AllTrim(SX3->X3_CAMPO) $ "D2_ITEM#D2_COD#D2_QUANT#D2_PRCVEN#D2_TOTAL#D2_TES#D2_PEDIDO#" )
		nUsadoNF++
		Aadd(aHeaderNF,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	EndIf
	dbSkip()
EndDo

aColsNF := {}
DbSelectArea("SD2")
dbSetOrder(3)
DbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE )
While !eof() .and. xFilial("SD2")== SD2->D2_FILIAL .and. SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE
	AADD(aColsNF,Array(nUsadoNF+1))
	For _ni:=1 to nUsadoNF
		aColsNF[Len(aColsNF),_ni]:=If(aHeaderNF[_ni,10] # "V",FieldGet(FieldPos(aHeaderNF[_ni,2])),CriaVar(aHeaderNF[_ni,2]))
	Next
	If aScan(aPedidos,SD2->D2_PEDIDO) = 0
		aAdd(aPedidos,SD2->D2_PEDIDO)
	EndIf
	aColsNF[Len(aColsNF),nUsadoNF+1]:=.F.
	dbSkip()
EndDo

If Len(aColsNF) == 0
	aColsNF:={Array(nUsadoNF+1)}
	aColsNF[1,nUsadoNF+1]:=.F.
	For _ni:=1 to nUsadoNF
		aColsNF[1,_ni]:=CriaVar(aHeaderNF[_ni,2])
	Next
EndIf

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

nTotPec := SF2->F2_VALBRUT+SF2->F2_DESCONT
nTotDes := SF2->F2_DESCONT
nTotOrc := SF2->F2_VALBRUT

cNota  := SF2->F2_DOC
cSerie := SF2->F2_SERIE

aEntrada := {}

DbSelectArea("SE1")
DbSeek(xFilial("SE1")+cPrefNF+cNota)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols e aHeader da Condicao de Pagamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	EndIf
	dbSkip()
EndDo

aColsC := {}
DbSelectarea("VS9")
DbSetOrder(1)
If DbSeek(xFilial("VS9")+VS1->VS1_NUMORC+" ")
	nPar := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. alltrim(VS9->VS9_NUMIDE) == alltrim(VS1->VS1_NUMORC) .and. VS9->VS9_TIPOPE == " "
		lOk := .f.
		DbSelectArea("SE1")
		If	DbSeek(xFilial("SE1")+cPrefNF+cNota+Str(nPar,1)+VSE->VSE_TIPPAG)
			If Empty(SE1->E1_BAIXA)
				lOk := .f.
			Else
				lOk := .t.
			EndIf
		EndIf
		DbSelectArea("VS9")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aColsC,Array(nUsadoC+1))
		aColsC[Len(aColsC),Len(aColsC[Len(aColsC)])] := lOk
		For _ni:=1 to nUsadoC
			aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
		Next
		nPar++
		DbSkip()
	Enddo
EndIf

If Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
EndIf

Private aTitles  := {(STR0008),(STR0009)} //Venda###Pagamento
Private oSizePrinc
Private oSizeSup
Private oSizeInf

// Calcula Coordenadas dos objetos
OM220CalcSize()

DEFINE MSDIALOG oDlg220 TITLE cTitulo OF oMainWnd PIXEL;
	FROM oSizePrinc:aWindSize[1],oSizePrinc:aWindSize[2] TO oSizePrinc:aWindSize[3],oSizePrinc:aWindSize[4]

// Pagina 1

//Zero()                                                //{001,002,082,312}        // alterada posicao da enchoice para evidar o problema da rolagem
// ultrapassar invadindo a getdados - Antonio - FNC 23372 - 30/09/09

oGetMGet:= MsMGet():New("SF2",0,nOpcE,,,,aCpoEnchoice,oSizeSup:GetObjectArea("DET1"),,2,,,,oDlg220,,.T.,.F.)

aHeader  := aClone(aHeaderNF)
aCols    := aClone(aColsNF)                       //084,002,180,312             // idem acima - antonio
oGetPecas                       := MsGetDados():New(oSizeSup:GetObjectArea("DET2")[1],;
													oSizeSup:GetObjectArea("DET2")[2],;
													oSizeSup:GetObjectArea("DET2")[3],;
													oSizeSup:GetObjectArea("DET2")[4],;
													nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oDlg220)
oGetPecas:oBrowse:bDelete       := {|| .t. }
oGetPecas:oBrowse:default()
oGetPecas:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderNF),aCols := aClone(aColsNF),n := nNF, oGetPecas:oBrowse:SetFocus()}
oGetPecas:oBrowse:bLostFocus    := {|| aHeaderNF:= aClone(aHeader), aColsNF:= aClone(aCols), nNF:= n }

//
@ oSizeInf:GetObjectArea("ESQ")[1]+000,oSizeInf:GetObjectArea("ESQ")[2]+005 Say STR0010 SIZE 40,08 OF oDlg220 PIXEL COLOR CLR_BLUE //Cliente:
@ oSizeInf:GetObjectArea("ESQ")[1]+000,oSizeInf:GetObjectArea("ESQ")[2]+035 msget oA1_NOME VAR SA1->A1_NOME   SIZE oSizeInf:GetObjectArea("ESQ")[4]-40,08 OF oDlg220 PIXEL COLOR CLR_BLUE when .f.
@ oSizeInf:GetObjectArea("ESQ")[1]+011,oSizeInf:GetObjectArea("ESQ")[2]+005 Say STR0011 SIZE 40,08 OF oDlg220 PIXEL COLOR CLR_BLUE //Condicao:
@ oSizeInf:GetObjectArea("ESQ")[1]+011,oSizeInf:GetObjectArea("ESQ")[2]+035 msget oE4_DESC VAR SE4->E4_DESCRI SIZE oSizeInf:GetObjectArea("ESQ")[4]-40,08 OF oDlg220 PIXEL COLOR CLR_BLUE when .f.
//
@ oSizeInf:GetObjectArea("ESQ")[1]+023,oSizeInf:GetObjectArea("ESQ")[2]+005 Say STR0012 SIZE 50,08 OF oDlg220 PIXEL COLOR CLR_BLUE //Itens
@ oSizeInf:GetObjectArea("ESQ")[1]+023,oSizeInf:GetObjectArea("ESQ")[2]+035 msget oTotPec VAR nTotPec Picture "@E 999,999,999.99" SIZE oSizeInf:GetObjectArea("ESQ")[4]-40,08 OF oDlg220 PIXEL COLOR CLR_BLACK when .f.
@ oSizeInf:GetObjectArea("ESQ")[1]+034,oSizeInf:GetObjectArea("ESQ")[2]+005 Say STR0013 SIZE 50,08 OF oDlg220 PIXEL COLOR CLR_BLUE //Desconto
@ oSizeInf:GetObjectArea("ESQ")[1]+034,oSizeInf:GetObjectArea("ESQ")[2]+035 msget oTotDes VAR nTotDes Picture "@E 999,999,999.99" SIZE oSizeInf:GetObjectArea("ESQ")[4]-40,08 OF oDlg220 PIXEL COLOR CLR_BLACK when .f.
@ oSizeInf:GetObjectArea("ESQ")[1]+045,oSizeInf:GetObjectArea("ESQ")[2]+005 Say STR0014 SIZE 50,08 OF oDlg220 PIXEL COLOR CLR_BLUE //Total
@ oSizeInf:GetObjectArea("ESQ")[1]+045,oSizeInf:GetObjectArea("ESQ")[2]+035 msget oTotOrc VAR nTotOrc Picture "@E 999,999,999.99" SIZE oSizeInf:GetObjectArea("ESQ")[4]-40,08 OF oDlg220 PIXEL COLOR CLR_BLACK when .f.
//

aHeader  := aClone(aHeaderC)
aCols    := aClone(aColsC)
oEntrada                       := MsGetDados():New(	oSizeInf:GetObjectArea("DIR")[1],;
													oSizeInf:GetObjectArea("DIR")[2],;
													oSizeInf:GetObjectArea("DIR")[3],;
													oSizeInf:GetObjectArea("DIR")[4],;
													nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk,,,,oDlg220)
oEntrada:oBrowse:default()
oEntrada:oBrowse:bEditCol      := {|| .t. }
oEntrada:oBrowse:bDelete       := {|| .t. }
oEntrada:oBrowse:bGotFocus     := {|| aHeader := aClone(aHeaderC),aCols := aClone(aColsC),n := nC, oEntrada:oBrowse:SetFocus()}
oEntrada:oBrowse:bLostFocus    := {|| aHeaderC:= aClone(aHeader), aColsC:= aClone(aCols), nC:= n }

ACTIVATE MSDIALOG oDlg220 CENTER ON INIT (EnchoiceBar(oDlg220,{|| nOpca := 1, oDlg220:End()},{|| nOpca := 2,oDlg220:End()}) )

If nOpca == 1
	Processa( {|| OM220Cancela() } )
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM220Cancela ³ Autor ³ Andre             ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelamento da Venda de Pecas                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM220Cancela(cParSerie, cParNota, cParPrefixo )

Local aOrcs      := {}
Local cQuery     := ""
Local cAlSQL     := "SQL_VS1"
Local i          := 0
Local cPrefix    := ""
Local cMVSERCUP  := GetNewPar("MV_SERCUP","CUP")
Local cMVPREFBAL := GetNewPar("MV_PREFBAL","BAL")
Local lCupom     := VS1->VS1_SERNFI == cMVSERCUP
Local cont       := 0
Local lNFeCancel := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(FieldPos("F2_STATUS")) > 0
Local lRet       := .t.
Local cNumPed

Default cParSerie := ""
Default cParNota := ""

lManual := .f.
If !Empty(cParSerie) .and. lNFeCancel
	cSerie := cParSerie
	cNota := cParNota
	cPrefix := cParPrefixo
	lManual := .t.
EndIf

If !lManual
	SF2->(DbSetOrder(1))
	If !SF2->(dbSeek(xFilial("SF2") + cNota + cSerie ))
		MsgInfo(STR0033) // "Nota Fiscal não encontrada."
		Return .f.
	EndIf
EndIf

if Empty(cPrefix)
	cPrefix := &(GetNewPar("MV_1DUPREF","cSerie"))
	if Empty(cPrefix)
		cPrefix := iif(VS1->VS1_SERNFI <> cMVSERCUP,VS1->VS1_SERNFI,cMVSERCUP)
	Endif
Endif

cPrefix := PadR( AllTrim(cPrefix) , TamSx3("E1_PREFIXO")[1] )

DbSelectArea("SE1")
DBSetOrder(1)
If SE1->(DBSeek(xFilial('SE1')+ cPrefix +cNota))
	While !Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO ==  cPrefix  .and. SE1->E1_NUM == cNota
		if VS1->VS1_SERNFI <> cMVSERCUP .and. SE1->E1_PREFORI != cMVPREFBAL
			DBSkip()
			loop
		endif
		If !Empty(SE1->E1_BAIXA) .or. SE1->E1_SALDO != SE1->E1_VALOR
			MsgInfo(STR0019,STR0020) //Ha titulos baixados referentes a esta Venda..###Atencao
			Return(.f.)
		EndIf
		DbSelectArea("SE1")
		DbSkip()
	Enddo
EndIf

if ( ExistBlock("OFM220AT") )
	lRet := ExecBlock("OFM220AT",.f.,.f.)
	if !lRet
		Return(.f.)
	Endif
EndIf

ProcRegua(4)
IncProc(STR0034) // "Excluindo nota fiscal."

// Transmite o Cancelamento para o SEFAZ automaticamente
If lNFeCancel .or. lManual
	//FS_DELNFI(cNumNfi,cSerie,cFatPar,cLoja,lNFeCancel)
	If !FS_DELNFI(VS1->VS1_NUMNFI, VS1->VS1_SERNFI, VS1->VS1_CLIFAT, VS1->VS1_LOJA, lNFeCancel)
		If lMsErroAuto
			MostraErro()
		EndIf
		MsUnlockAll()
		Return .f.
	Endif
EndIf

Begin Transaction

if ( ExistBlock("OFM220IN") )
	lRet := ExecBlock("OFM220IN",.f.,.f.)
	if !lRet
		DisarmTransaction()
		Break
		Return(.f.)
	Endif
EndIf

// Recuperar o Número do Pedido antes das transações que serão realizadas
cNumPed := OM220Pedido(VS1->VS1_NUMNFI, VS1->VS1_SERNFI, VS1->VS1_CLIFAT, VS1->VS1_LOJA, lNFeCancel)

If !lNFeCancel .and. !lManual
	If !FS_DELNFI(VS1->VS1_NUMNFI, VS1->VS1_SERNFI, VS1->VS1_CLIFAT, VS1->VS1_LOJA, lNFeCancel)
		If lMsErroAuto
			DisarmTransaction()
			Break
		EndIf
	EndIf
Endif

//Exclui Pedido
IncProc(STR0023) //Cancelando Pedido...

lMsErroAuto := .f.

dbSelectArea("SC5")
dbSetOrder(1)
if dbSeek(xFilial("SC5")+cNumPed)
	aMata410Cab   := {{"C5_NUM"      , cNumPed,Nil}}   //Numero do pedido SC5
	aMata410Itens := {{"C6_NUM"      , cNumPed,Nil}}   //Numero do Pedido SC6

	//Exclui Pedido
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9")+cNumPed))
	While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo

	MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
Endif

If lMsErroAuto == .t.
	DisarmTransaction()
	Break
EndIf


// Exclui os LOGS gerados no momento do faturamento 
cQuery := "DELETE FROM "+ RetSqlName("VQL")
cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
cQuery += "   AND VQL_AGROUP = 'OFIXX004' "
cQuery += "   AND VQL_FILORI = '" + VS1->VS1_FILIAL + "' "
cQuery += "   AND VQL_TIPO = 'VS1-" + VS1->VS1_NUMORC + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
TcSqlExec(cQuery)
//


// Inicio do Cancelamento dos Titulos a Receber
If Empty(VS1->VS1_CTCDCI)

	////////////////////
	// Excluir os VS9 //
	////////////////////
	aOrcs  := {}
	cQuery := " SELECT VS1.VS1_NUMORC FROM "+RetSQLName("VS1")+" VS1 "
	cQuery += " WHERE VS1.VS1_FILIAL = '"+VS1->VS1_FILIAL+"' "
	cQuery += "   AND VS1.VS1_NUMNFI = '"+VS1->VS1_NUMNFI+"' "
	cQuery += "   AND VS1.VS1_SERNFI = '"+VS1->VS1_SERNFI+"' "
	cQuery += "   AND VS1.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlSQL , .F., .T. )
	While !(( cAlSQL )->( Eof() ))
		aAdd(aOrcs,( cAlSQL )->( VS1_NUMORC ))
		( cAlSQL )->( DBSkip() )
	EndDo
	( cAlSQL )->( DbCloseArea() )
	If len(aOrcs) == 0
		aAdd(aOrcs,VS1->VS1_NUMORC)
	EndIf
	dbSelectArea("VS9")
	dbSetOrder(1)
	For i := 1 to len(aOrcs)
		If VS9->(dbSeek(xFilial("VS9")+aOrcs[i]))
			While !eof() .and. VS9->VS9_FILIAL == xFilial("VS9") .and. Alltrim(VS9->VS9_NUMIDE) == aOrcs[i]
				dbSelectArea("VS9")
				If !RecLock("VS9",.f.,.t.)
					DisarmTransaction()
					Break
				EndIf
				DbDelete()
				MsUnLock()
				DbSkip()
			EndDo
		EndIf
	Next
	//
	aParcelas := {}
	DbSelectArea("SE1")
	SE1->(DBSetOrder(1))
	If SE1->(DBSeek(xFilial('SE1')+ cPrefix +cNota))
		while ! Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO ==  cPrefix  .and. SE1->E1_NUM == cNota
			if VS1->VS1_SERNFI <> cMVSERCUP .and. SE1->E1_PREFORI != cMVPREFBAL
				DBSkip()
				loop
			endif

			AADD(aParcelas,{ ;
				{"E1_PREFIXO" , E1_PREFIXO , nil } ,;
				{"E1_NUM"     , E1_NUM     , nil } ,;
				{"E1_PARCELA" , E1_PARCELA , nil } ,;
				{"E1_TIPO"    , E1_TIPO    , nil } ,;
				{"E1_NATUREZA", E1_NATUREZA, nil } ,;
				{"E1_CLIENTE" , E1_CLIENTE , nil } ,;
				{"E1_LOJA"    , E1_LOJA    , nil } ,;
				{"E1_EMISSAO" , E1_EMISSAO , nil } ,;
				{"E1_VENCTO"  , E1_VENCTO  , nil } ,;
				{"E1_VENCREA" , E1_VENCREA , nil } ,;
				{"E1_VALOR"   , E1_VALOR   , nil } })

			DbSelectArea("SE1")
			DbSkip()
		Enddo

		IncProc(STR0024) //Excluindo Titulos...

		pergunte("FIN040",.F.)
		For i = 1 to len(aParcelas)
			MSExecAuto({|x,y| FINA040(x,y)},aParcelas[i],5)
			If  LMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			EndIf
		Next

		DbSelectArea("VSE")
		DbSetOrder(1)
		If DbSeek( xFilial("VSE") + "OR"+VS1->VS1_NUMORC + ' B' )
			while !eof() .and. xFilial("VSE") == VSE->VSE_FILIAL .and. VSE->VSE_NUMIDE+VSE->VSE_TIPOPE == "OR"+VS1->VS1_NUMORC+" B"
				If !RecLock("VSE",.f.,.t.)
					DisarmTransaction()
					Break
				EndIf
				DbDelete()
				MsUnlock()
				DbSkip()
			Enddo
		EndIf
	EndIf
Else
	//Exclui Financiamento CDCI
	ExTitCDCI(VS1->VS1_CTCDCI)
	ExContCDCI(VS1->VS1_CTCDCI)
EndIf

cRecno := AllTrim(VS1->VS1_TITNCC)
cStr   := AllTrim(VS1->VS1_TITNCC)
nTot   := 0
if Len(AllTrim(VS1->VS1_TITNCC)) > 0
	For cont := 1 to Len(AllTrim(VS1->VS1_TITNCC))
		if substr(cStr,cont,1) == "/"
			nTot++
		Endif
	Next
	if nTot == 0
		nTot := 1
	Endif
Endif

For cont := 1 to nTot

	cRecno := substr(cStr,1,AT("/",cStr)-1)
	cStr   := substr(cStr,AT("/",cStr)+1)
	dbSelectArea("SE1")
	dbGoto(val(cRecno))

	aBaixa  := {;
		{"E1_PREFIXO"   , SE1->E1_PREFIXO ,Nil},;
		{"E1_NUM"	    , SE1->E1_NUM     ,Nil},;
		{"E1_PARCELA"   , SE1->E1_PARCELA ,Nil},;
		{"E1_TIPO"	    , "NCC"           ,Nil},;
		{"AUTMOTBX"	    , "NOR"           ,Nil},;
		{"AUTDTBAIXA"   , dDataBase       ,Nil},;
		{"AUTDTCREDITO" , dDataBase       ,Nil}}

	lMSHelpAuto := .f.
	lMsErroAuto := .f.
	MSExecAuto({|x,y| FINA070(x,y)},aBaixa,5)
	If lMsErroAuto
		lRet := .F.
		lError := .T.
		DisarmTransaction()
		MostraErro()
		Break
	EndIf
Next

//////////////////////////////////////////////////
// EXCLUIR ARQUIVOS ( VEC / VSG ) e ALTERAR VS1 //
//////////////////////////////////////////////////
IncProc(STR0035) // "Atualizando Orçamento"
FS_EXCLUIR(cNota,cSerie,1) // 1=Voltar Orcamento para Aberto
//////////////////////////////////////////////////

if lCupom
	//Imprime o cancelamento do Cupom Fiscal
	iRetorno   := 0
	cRetorno	  := ' '
	_lRetBema 	:= .T.
	_cPorta     := GetMv("MV_PORTFIS")
	_cImpressora:= GetMv("MV_IMPFIS")
	_nDesconto	:=	0
	_nTotal   	:=	0
	_nTotDesc 	:=	0
	_aIcms    	:=	{}
	_nRet		 	:=	""
	If Type("nHdlECF") == "U" .Or. nHdlEcf == -1
		//If !Type("nHdlECF") == "U" .Or. nHdlEcf <> -1
		Public nhdlecf
		nhdlecf := IFAbrir( _cImpressora,_cPorta )
	EndIf
	iRet := IFStatus( nhdlecf, '5', @cRetorno )
	//if iRet = 7
	iRet := IFCancCup( nhdlecf )
	Inkey(8)   // dá um tempo para a impressora fazer a impressao do cancelamento
	//Endif
Endif

if ( ExistBlock("OFM220FN") )
	lRet := ExecBlock("OFM220FN",.f.,.f.)
	if !lRet
		DisarmTransaction()
		Break
	Endif
EndIf

End Transaction

If lMsErroAuto
	MostraErro()
	Return .f.
EndIf

//Executa RdMake da Ordem de Cancelamento
if ExistBlock("ORDCANC")
	ExecBlock("ORDCANC",.f.,.f.)
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_EXCLUIR³ Autor ³ Andre                 ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ EXCLUIR ARQUIVOS ( VEC / VSG ) e ALTERAR VS1               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EXCLUIR(cNota,cSerie,nTp)
Local lStatusVS1S  := .f. // variavel nao estava declarada e esta dentro de um if ocasionando erro qdo entrava neste if
Local lVoltaStatus := .f.
Local cAuxData := Dtoc(dDataBase)

Local lVS3IMPRES := VS3->(FieldPos("VS3_IMPRES")) > 0
Local lVS3RESERV := VS3->(FieldPos("VS3_RESERV")) > 0

Default cNota  := ""
Default cSerie := ""

conout("OFIOM220 - FS_EXCLUIR - 01  "+ cAuxData +" - "+Time() + " - " + cSerie + " - " + cNota)

if VS1->(FieldPos("VS1_STATUS")) > 0
	lStatusVS1S := .t.
endif

If !Empty(cNota+cSerie)
	conout("OFIOM220 - FS_EXCLUIR - 02  "+ cAuxData +" - "+Time())
	DbSelectArea("VS1")
	DbSetOrder(3)
	DbSeek(xFilial("VS1")+cNota+cSerie)
	DbSelectArea("VEC")
	DbSetOrder(4)
	If DbSeek(xFilial("VEC")+cNota+cSerie)
		conout("OFIOM220 - FS_EXCLUIR - 03  "+ cAuxData +" - "+Time())
		while VEC->VEC_FILIAL+VEC->VEC_NUMNFI+VEC->VEC_SERNFI == xFilial("VEC")+cNota+cSerie .and. !Eof()
			if !RecLock("VEC",.f.,.t.)
				DisarmTransaction()
				lErro := .t.
				Break
			Endif
			conout("OFIOM220 - FS_EXCLUIR - 04  "+ cAuxData +" - "+Time())
			DbDelete()
			MsUnlock()
			DbSkip()
		Enddo
	Endif
EndIf
conout("OFIOM220 - FS_EXCLUIR - 05  "+ cAuxData +" - "+Time())
lVoltaStatus := !Empty(VS1->VS1_NUMNFI+VS1->VS1_SERNFI)
DbSelectArea("VS1")
DbSetOrder(3)
if Alltrim(cNota+cSerie) != ""
	conout("OFIOM220 - FS_EXCLUIR - 06  "+ cAuxData +" - "+Time())
	while DbSeek(xFilial("VS1")+cNota+cSerie)
		conout("OFIOM220 - FS_EXCLUIR - 07  "+ cAuxData +" - "+Time() + " - " + VS1->VS1_NUMORC)
		RecLock("VS1",.f.)
		VS1->VS1_NUMPED := ""
		VS1->VS1_NUMLIB := ""
		VS1->VS1_NUMNFI := ""
		VS1->VS1_SERNFI := ""
		VS1->VS1_CTCDCI := ""
		if lStatusVS1S
			If nTp == 1 // 1=Voltar Orcamento para Aberto
				VS1->VS1_STATUS := "0"
			EndIf
		endif
		MsUnlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0025 ) // Grava Data/Hora na Mudança de Status do Orçamento / Cancelamento de Nota Fiscal de Venda
		EndIf
		if lStatusVS1S .and. nTp == 1
			DBSelectArea("VS3")
			dbSetOrder(1)
			dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
			While !eof() .and. VS3->VS3_FILIAL == xFilial("VS3").and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
				RecLock("VS3",.f.)
				If lVS3RESERV
					VS3->VS3_RESERV := "0"
				EndIf
				If lVS3IMPRES
					VS3->VS3_IMPRES := "0"
				EndIf
				VS3->VS3_QTDCON := 0
				VS3->VS3_QTDRES := 0
				VS3->VS3_DOCSDB := ""
				msunlock()
				DBSkip()
			enddo
			// Excluir os Registros de Conferencia do Orcamento
			If FindFunction("OX0020171_ExcluirConferencia")
				OX0020171_ExcluirConferencia( VS1->VS1_NUMORC )
			EndIf
			//
			DbSelectArea("VS1")
			//
		endif
	enddo
endif
If FindFunction("OX001CEV")
	OX001CEV("D",VS1->VS1_NUMORC) // Deletar CEV gerado na Finalizacao do Orcamento que continua em aberto
EndIf
if lStatusVS1S
	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIF
EndIf

// Exclusao das comissoes
DbSelectArea("VSG")
DbSetOrder(1)
If DbSeek(xFilial("VSG")+VS1->VS1_NUMORC+"P"+VS1->VS1_CODVEN)
	while !eof() .and. VSG->VSG_NOSNUM == VS1->VS1_NUMORC .and. VSG->VSG_TIPCOM == "P" .and. VSG->VSG_CODVEN == VS1->VS1_CODVEN
		RecLock("VSG",.f.,.t.)
		dbDelete()
		MsUnlock()
		writeSx2("VSG")
		dbSkip()
	enddo
EndIf

Return()

/////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MenuDef   ³ Autor ³ Andre                 ³ Data ³ 23/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu											              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
	{ STR0001 ,"AxPesqui"       , 0 , 1 },; //"Pesquisar"
	{ STR0002 ,"OM220ExcNota"   , 0 , 2 },; //"Excluir"
	{ STR0036 ,"OM220ExcManual" , 0 , 2 },; //"Exclusão Manual
	{ STR0042 ,"OM220Refresh"   , 0 , 2 } } //"Refresh"

Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³OM220CANC º Autor ³ Andre Luis Almeida º Data ³  11/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Cancela Orcamento, atraves do Nro do Orcamento no Loja     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Loja -> Orcamento                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM220CANC(cOrcLoja,cNota)
Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local nCntFor2 := 0
Local cQuery  := ""
Local cAlCANC := "SQL_CANCEL"
Local nRecVS1 := 0
//Local lLimpOrcLj := .f.
Default cOrcLoja := ""
Default cNota := ""

conout("OM220CANC INICIO")

If !Empty(cOrcLoja)
	conout("OM220CANC cOrcLoja:"+cOrcLoja)
	cQuery := "SELECT VS1.R_E_C_N_O_ AS VS1REC FROM "+RetSQLName("VS1")+" VS1 WHERE "
	cQuery += "VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_PESQLJ='"+cOrcLoja+"' AND VS1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlCANC , .F., .T. )
	aRecsVS1 := {}
	WHILE !(( cAlCANC )->( Eof() ))
		aAdd(aRecsVS1,	( cAlCANC )->( VS1REC))
		( cAlCANC )->( DBSkip() )
	enddo
	( cAlCANC )->( DbCloseArea() )
	for nCntFor2 = 1 to Len(aRecsVS1)
		DbSelectArea("VS1")
		DbSetOrder(1)
		DbGoTo( aRecsVS1[nCntFor2] )
		For nCntFor := 1 TO FCount()
			&( "M->"+EVAL(bCampo,nCntFor) ) := FieldGet(nCntFor)
		Next
		//		If Empty(VS1->VS1_NUMNFI+VS1->VS1_SERNFI)
		//			lLimpOrcLj := .t.
		//		EndIf
		conout("OM220CANC FS_EXCLUIR ")
		FS_EXCLUIR(VS1->VS1_NUMNFI,VS1->VS1_SERNFI,2) // 2=Nao voltar Orcamento para Aberto
		If Empty(cNota) //lLimpOrcLj // Limpar Nro do Orcamento do Loja no Orcamento Fases
			DbSelectArea("VS1")
			DbSetOrder(1)
			DbGoTo( aRecsVS1[nCntFor2] )
			RecLock("VS1",.f.)
//			VS1->VS1_PESQLJ := ""
			conout("OM220CANC STATUS ")
			If VS1->VS1_STATUS == "X" // Faturado
				VS1->VS1_STATUS := "F" // Liberado para Faturamento
			EndIf
			MsUnLock()
			If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
				OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0025 ) // Grava Data/Hora na Mudança de Status do Orçamento / Cancelamento de Nota Fiscal de Venda
			EndIf
			//
			OM220VS9(VS1->VS1_NUMORC)
			//
			// -----------------------------------------------
			// Gravação do STATUS DA RESERVA no VS1 (VS1_STARES)
			// -----------------------------------------------
			if VS1->(FieldPos("VS1_STARES")) > 0
				cAliasLD := GetNextAlias()
				cQuery := "SELECT R_E_C_N_O_ RECVS1 FROM "+RetSqlName("VS1")
				cQuery += " WHERE VS1_FILIAL ='"+xFilial("VS1")+"'"
				cQuery += " AND VS1_PESQLJ ='"+SL1->L1_NUM+"' AND D_E_L_E_T_ =  ' '"

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasLD, .F., .T. )
				//
				while !((cAliasLD)->(eof()))
					DBSelectArea("VS1")
					DBGoTo((cAliasLD)->(RECVS1))

					lTemResS := .f.
					lNTemRes := .f.

					DBSelectArea("VS3")
					DBSetOrder(1)
					DBSeek(xFilial("VS3")+ VS1->VS1_NUMORC)
					//
					cFaseOrc := OI001GETFASE(__cUserId,2)
					nPosR := At("R",cFaseOrc)
					//
					DBSelectArea("VS3")
					while !eof() .and. xFilial("VS3") + VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
						if 	Alltrim(VS3->VS3_RESERV) == "1"
							lTemResS := .t.
						else
							lNTemRes := .t.
						endif
						DBSkip()
					enddo
					reclock("VS1",.f.)
					if nPosR > 0
						VS1->VS1_STARES := "1"
					elseif lTemResS .and. lNTemRes
						VS1->VS1_STARES := "2"
					elseif lTemResS .and. !lNTemRes
						VS1->VS1_STARES := "1"
					else
						VS1->VS1_STARES := "3"
					endif
					VS1->VS1_PESQLJ := ""

					msunlock()
					(cAliasLD)->(DBSKip())
				enddo
				(cAliasLD)->(DBCloseArea())
			endif
			// -----------------------------------------------
			// Gravação do STATUS DA RESERVA no VS1 (VS1_STARES)
			// -----------------------------------------------
		EndIf

	next
EndIf
Return(.t.)


/*/{Protheus.doc} FS_DELNFI
Exclui Nota Fiscal de Saida
@author Rubens
@since 25/10/2017
@version 1.0
@param cNumNfi, characters, Numero da Nota Fiscal
@param cSerie, characters, Serie da Nota Fiscal
@param cFatPar, characters, Faturar Para
@param cLoja, characters, Loja Faturar Para
@param lNFeCancel, logical, Indica se utiliza JOB de Cancelamento
@type function
/*/
Static Function FS_DELNFI(cNumNfi,cSerie,cFatPar,cLoja,lNFeCancel)

	Local lAgendado := .f.
	Local cAuxData := Dtoc(dDataBase)

	Local aRegSD2     := {}
	Local aRegSE1     := {}
	Local aRegSE2     := {}

	CONOUT(" ")
	CONOUT("-------------------------------------------------------------------------")
	CONOUT(" ")
	conout("OFIOM220 - FS_DELFNI - INICIO PROCESSAMENTO: " + cAuxData + " - " + Time())

	If lNFeCancel .and. FGX_STATF2("D",cSerie,cNumNfi,cFatPar,cLoja,"S") // verifica se NF foi Deletada
		Return .t.
	EndIf

	If lNFeCancel
		lRetStatus := FGX_STATF2("J",cSerie,cNumNfi,cFatPar,cLoja,"S",@lAgendado) // verifica se NF esta na fila para transmissao
		If !lRetStatus .and. lAgendado
			Return .f.
		EndIf
	EndIf

	dbSelectArea("SF2")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o estorno do documento de saída pode ser feito     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	conout("OFIOM220 - FS_DELFNI - CHAMADA DA MACANDELF2:  "+ cAuxData +" - "+Time())
	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
		conout("OFIOM220 - FS_DELFNI - RETORNO POSITIVO DA MACANDELF2:  "+ cAuxData +" - "+Time())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna o documento de saida                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PERGUNTE("MTA521",.f.)
		If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
			lMsErroAuto:= .T.
			Return(.f.)
		Else
			conout("OFIOM220 - FS_DELFNI - RETORNO POSITIVO DA MADELNFS:  "+ cAuxData +" - "+Time())
		Endif

		conout("OFIOM220 - FS_DELFNI - CHAMADA FGX_STATF2:  "+ cAuxData +" - "+Time())
		If lNFeCancel .and. !FGX_STATF2("V",cSerie,cNumNfi,cFatPar,cLoja,"S") /// Verifica STATUS da NF no SEFAZ
			lMsErroAuto:= .T.
			Return .f.
		EndIf
	Else
		conout("OFIOM220 - FS_DELFNI - RETORNO NEGATIVO DA MACANDELF2:  "+ cAuxData +" - "+Time())
		lMsErroAuto:= .T.
		Return(.f.)
	EndIf

	conout("OFIOM220 - FS_DELFNI - FIM DO PROCESSAMENTO:  "+ cAuxData +" - "+Time())
	CONOUT(" ")
	CONOUT("-------------------------------------------------------------------------")
	CONOUT(" ")

Return(.t.)

/*/{Protheus.doc} OM220ExcManual
Monta tela com as notas que foram cancelandas pelo FATJOBNFE e que ainda possuem referencia no DMS
@author Rubens
@since 25/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OM220ExcManual()

	Local oSizePrinc
	Local oSizeFiltro
	Local oInterfHelper := DMS_InterfaceHelper():New()

	Private oOk := LoadBitmap( GetResources(), "LBTIK" )
	Private oNo := LoadBitmap( GetResources(), "LBNO" )

	Private oSQLHelper := DMS_SQLHelper():New()

	oInterfHelper:nOpc := 3

	oSizePrinc := oInterfHelper:CreateDefSize(;
		.t. ,;
		{ { "GET"    ,100,035,.T.,.F.} ,;
		  { "LISTBOX",100,100,.T.,.T.} },;
		,;
		,;
		.70 )
	oSizePrinc:Process()

	oInterfHelper:SetDefSize(oSizePrinc)
	oOM220ExcManual := oInterfHelper:CreateDialog(STR0037) // "Exclusão manual de Nota Fiscal"

	oInterfHelper:SetDefSize(oSizePrinc,"GET")

	oInterfHelper:SetOwnerPvt("OM220ExcManual")
	oInterfHelper:SetPrefixo("PAR")
	oInterfHelper:AddMGet( "VS1_SERNFI" , { { "X3_VISUAL" , "A" } , { "X3_VALID" , "OM220Valid()" } } )
	oInterfHelper:AddMGet( "VS1_NUMNFI" , { { "X3_VISUAL" , "A" } , { "X3_VALID" , "OM220Valid()" } } )

	oEnchParam := oInterfHelper:CreateMSMGet(.f.)

	oInterfHelper:Clean()
	oInterfHelper:SetDefSize(oSizePrinc,"LISTBOX")
	oInterfHelper:AddColLBox( { { "SELECAO" , .t. } , { "SELECAO_UNICO" , .t. } , { "VALIDACAO" , "OM220Valid('LISTBOX')"}} )
	oInterfHelper:AddColLBox( { { "X3" , "F3_SERIE"   } } )
	oInterfHelper:AddColLBox( { { "X3" , "F3_NFISCAL" } } )
	oInterfHelper:AddColLBox( { { "X3" , "F3_DTCANC"  } } )
	oInterfHelper:AddColLBox( { { "X3" , "VS1_NUMORC" } } )

	oLBoxNFExcl := oInterfHelper:CreateLBox( "oLBoxNFExcl" )
	oLBoxNFExcl:SetArray( OM220LBoxNFCanc() )
	oLBoxNFExcl:Refresh()

	ACTIVATE MSDIALOG oOM220ExcManual CENTER ON INIT ;
		EnchoiceBar(oOM220ExcManual,{ || IIf( OM220ProcExcManual() , oOM220ExcManual:End() , ) }, { || oOM220ExcManual:End() } )

Return

/*/{Protheus.doc} OM220ProcExcManual
Processa cancelamento manual de nota fiscal de venda balcao
@author Rubens
@since 25/10/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OM220ProcExcManual()

	Local nPosLBox
	Local cParNota
	Local cParSerie
	Local cParPrefixo
	Local lRetorno := .f.

	nPosLBox := aScan(oLBoxNFExcl:aArray, { |x| x[1] == .t. })

	If nPosLBox == 0 .and. (Empty(M->PAR_SERNFI) .or. Empty(M->PAR_NUMNFI))
		MsgInfo(STR0038,STR0020) // "Selecione uma nota fiscal para cancelamento."
		Return .f.
	EndIf

	If nPosLBox <> 0
		cParSerie := oLBoxNFExcl:aArray[ nPosLBox , 2]
		cParNota  := oLBoxNFExcl:aArray[ nPosLBox , 3]
	Else
		cParSerie := M->PAR_SERNFI
		cParNota  := M->PAR_NUMNFI
	EndIf

	If MsgYesNo(STR0039 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + RetTitle("VS1_NUMNFI") + ": " + cParSerie + "-" + cParNota)

		cParPrefixo := oSQLHelper:GetSelectArray( OM220QueryExcl(cParSerie, cParNota) , 5)[1,5]

		DbSelectArea("VS1")
		DbSetOrder(3)
		If !DbSeek(xFilial("VS1") + cParNota + cParSerie)
			Help(" ",1,"REGNOIS",,RetTitle("VS1_NUMNFI") + ": " + cParSerie + "-" + cParNota ,4,1)
			Return .f.
		EndIf

		Processa( {|| lRetorno := OM220Cancela( cParSerie , cParNota , cParPrefixo ) } )

	EndIf

Return lRetorno

/*/{Protheus.doc} OM220LBoxNFCanc
Array para popular o listbox de notas fiscais que foram canceladas no Backoffice e que possuem renferencia no DMS
@author Rubens
@since 25/10/2017
@version 1.0
@return aRetorno , array , Dados para atualizar listbox

@type function
/*/
Static Function OM220LBoxNFCanc()

	Local cSQL
	Local cAliasNFS := "TNFSCANC"
	Local aRetorno := {}

	cSQL := OM220QueryExcl()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasNFS, .F., .T. )
	TCSetField( cAliasNFS, "F3_DTCANC", "D" )
	(cAliasNFS)->(dbEval( { || ;
			AADD( aRetorno , { ;
				.f. ,;
				(cAliasNFS)->F3_SERIE   ,;
				(cAliasNFS)->F3_NFISCAL ,;
				(cAliasNFS)->F3_DTCANC  ,;
				(cAliasNFS)->VS1_NUMORC ;
			} );
		} ))
	(cAliasNFS)->(dbCloseArea())
	dbSelectArea("SF2")

Return aRetorno

/*/{Protheus.doc} OM220Valid
Valid para MGETS da janela de parametro de nota fiscal para ser cancelada no DMS e que foram cancelas no FATJOBNFE
@author Rubens
@since 25/10/2017
@version 1.0
@return lRetorno, boolean
@param cReadVar, characters, ReadVar
@type function
/*/
Static Function OM220Valid(cReadVar)

	Local lRetorno := .t.
	Local lAtuLBox := .t.

	Default cReadVar := ReadVar()

	Do Case
	Case cReadVar == "LISTBOX"
		M->PAR_SERNFI := Space(TamSX3("VS1_SERNFI")[1])
		M->PAR_NUMNFI := Space(TamSX3("VS1_NUMNFI")[1])
		oEnchParam:Refresh()
		lAtuLBox := .f.
	Case cReadVar == "M->PAR_SERNFI"
	Case cReadVar == "M->PAR_NUMNFI"
		If !Empty(M->PAR_NUMNFI)
			aRetSQL := oSQLHelper:GetSelectArray( OM220QueryExcl(M->PAR_SERNFI, M->PAR_NUMNFI) , 5)
			If Len(aRetSQL) == 0
				MsgInfo(STR0040 + CHR(13) + CHR(10) + ;
						STR0041) // "Nota fiscal informada não foi encontrada ou não está cancelada." # "Para utilizar essa opção, é necessário informar uma nota fiscal que foi cancelada através do JOB de Cancelamento."
				lRetorno := .f.
			EndIf
		EndIf
	EndCase

	If lAtuLBox
		aEval( oLBoxNFExcl:aArray , { |x| x[1] := .f. })
		oLBoxNFExcl:Refresh()
	EndIf

Return lRetorno

/*/{Protheus.doc} OM220QueryExcl
Retorna Query para verificar as notas fiscais que foram canceladas através do FATJOBNFE e que ainda possuem referencia na tabela de Orcamento
@author Rubens
@since 25/10/2017
@version 1.0
@return cSQL, characters, Query para
@param cSerie, characters, Serie
@param cNota, characters, Nota
@type function
/*/
Static Function OM220QueryExcl(cSerie, cNota)

	Local cSQL

	Default cSerie := ""
	Default cNota := ""

	cSQL := ;
		"SELECT DISTINCT SF3.F3_SERIE, SF3.F3_NFISCAL, SF3.F3_DTCANC, VS1.VS1_NUMORC " + ;
						  ", SF2.F2_PREFIXO " +;
		 " FROM " + RetSQLName("SF3") + " SF3 " + ;
				" JOIN " + RetSQLName("VS1") + " VS1 ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "' " + ;
						" AND VS1.VS1_SERNFI = SF3.F3_SERIE " + ;
						" AND VS1.VS1_NUMNFI = SF3.F3_NFISCAL " + ;
						" AND VS1.D_E_L_E_T_ = ' ' " +;
				" JOIN " + RetSQLName("SF2") + " SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' " +;
						" AND SF2.F2_SERIE = SF3.F3_SERIE " +;
						" AND SF2.F2_DOC = SF3.F3_NFISCAL " +;
						" AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR " +;
						" AND SF2.F2_LOJA = SF3.F3_LOJA " +;
						" AND SF2.D_E_L_E_T_ = '*'" +; // Obrigatorio que a Nota Fiscal Esteja DELETADA na base de Dados
				" JOIN " + RetSQLName("SD2") + "  SD2 ON SD2.D2_FILIAL = '" + xFilial("SD2") + "' " +;
						" AND SD2.D2_SERIE = SF2.F2_SERIE " +;
						" AND SD2.D2_DOC = SF2.F2_DOC " +;
						" AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " +;
						" AND SD2.D2_LOJA = SF2.F2_LOJA " +;
						" AND SD2.D_E_L_E_T_ = '*'" +; // Obrigatorio que a Nota Fiscal Esteja DELETADA na base de Dados
		" WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' " +;
		  " AND SF3.F3_DTCANC <> '        ' " +;
		  " AND SF3.F3_ESPECIE = 'SPED' " +;
		  IIf( !Empty(cSerie) , " AND SF3.F3_SERIE   = '" + cSerie + "'" , "" ) +;
		  IIf( !Empty(cNota)  , " AND SF3.F3_NFISCAL = '" + cNota  + "'" , "" ) +;
		  " AND SF3.F3_CHVNFE <> ' ' " +;
		  " AND SF3.D_E_L_E_T_ = ' ' " +;
		  " AND SF2.F2_STATUS = '015'" // Status de Cancelada no SEFAZ

Return cSQL


/*/{Protheus.doc} OM220Pedido
Retorna o numero do pedido que deverá ser cancelado

@author Rubens
@since 25/10/2017
@version 1.0
@param cNumNFI, characters, descricao
@param cSerieNFI, characters, descricao
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param lNFeCancel, logical, descricao
@type function
/*/
Static Function OM220Pedido(cNumNFI , cSerieNFI , cCliente, cLoja , lNFeCancel)

	Local cRetorno := ""

	cSQL := "SELECT D2_PEDIDO "
	cSQL +=  " FROM " + RetSQLName("SD2") + " SD2 "
	cSQL += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cSQL +=   " AND SD2.D2_DOC = '" + cNumNFI + "'"
	cSQL +=   " AND SD2.D2_SERIE = '" + cSerieNFI + "'"
	cSQL +=   " AND SD2.D2_CLIENTE = '" + cCliente + "'"
	cSQL +=   " AND SD2.D2_LOJA = '" + cLoja + "'"
	cSQL +=   " AND SD2.D_E_L_E_T_ = ' '"
	cRetorno := FM_SQL(cSQL)

	// Se não encontrar o pedido e o cliente utilizar o JOB de Cancelamento (MV_CANCNFE)
	// procura o ultimo pedido com nota fiscal deletada
	If Empty(cRetorno) .and. lNFeCancel
		cSQL := "SELECT MAX(D2_PEDIDO) "
		cSQL +=  " FROM " + RetSQLName("SD2") + " SD2 "
		cSQL +=  " JOIN " + RetSQLName("SC5") + " SC5 "
		cSQL +=    " ON SC5.C5_FILIAL = '" + xFilial("SC5") + "'"
		cSQL +=   " AND SC5.C5_NUM = SD2.D2_PEDIDO "
		cSQL +=   " AND SC5.D_E_L_E_T_ = ' ' "
		cSQL += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cSQL +=   " AND SD2.D2_DOC = '" + cNumNFI + "'"
		cSQL +=   " AND SD2.D2_SERIE = '" + cSerieNFI + "'"
		cSQL +=   " AND SD2.D2_CLIENTE = '" + cCliente + "'"
		cSQL +=   " AND SD2.D2_LOJA = '" + cLoja + "'"
		cSQL +=   " AND SD2.D_E_L_E_T_ = '*'"
		cRetorno := FM_SQL(cSQL)
	EndIf
	//
Return cRetorno

/*/{Protheus.doc} OM220CalcSize
Calcula o Tamanho dos Objetos na Tela

@author Andre Luis Almeida
@since 19/12/2017
@type function
/*/
Static Function OM220CalcSize()

	oSizePrinc := FwDefSize():New(.t.)
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	oSizePrinc:AddObject("SUP" , 100 , 100 , .T. , .T. ) // Superior
	oSizePrinc:AddObject("INF" , 100 ,  60 , .T. , .F. ) // Inferior
	oSizePrinc:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizePrinc:Process()	// Calcula Coordenadas

	oSizeSup := FWDefSize():New(.f.)
	oSizeSup:aWorkArea := oSizePrinc:GetNextCallArea("SUP") // Superior
	oSizeSup:aMargins := { 2 , 2 , 2 , 2 }
	oSizeSup:AddObject("DET1" , 100 , 100 , .T. , .T. ) // Detalhes 1
	oSizeSup:AddObject("DET2" , 100 , 100 , .T. , .T. ) // Detalhes 2
	oSizeSup:lLateral := .f.	// Calcula em colunas
	oSizeSup:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeSup:Process()

	oSizeInf := FWDefSize():New(.f.)
	oSizeInf:aWorkArea := oSizePrinc:GetNextCallArea("INF") // Inferior
	oSizeInf:aMargins := { 2 , 2 , 2 , 2 }
	oSizeInf:AddObject("ESQ"    , 20, 20,.t.,.t.) // 20% Esquerda
	oSizeInf:AddObject("DIR"    , 80, 80,.t.,.t.) // 80% Direita
	oSizeInf:lLateral := .t.	// Calcula em colunas
	oSizeInf:lProp    := .t.	// Mantem proporcao entre objetos redimensionaveis
	oSizeInf:Process()

Return


/*/{Protheus.doc} OM220VS9
Exclusao da negociacao de um determinado orcamento
@author Rubens
@since 10/04/2018
@version 1.0

@param cNumOrc, characters, descricao
@type function
/*/
Static Function OM220VS9(cNumOrc)

	Local cAliasVS9 := "TVS9"
	Local cSQL := ""

	If Empty(cNumOrc)
		Return .t.
	EndIf

	cSQL := "SELECT R_E_C_N_O_ RECVS9 "
	cSQL += "  FROM " + RetSQLName("VS9") + " VS9"
	cSQL += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
	cSQL += "   AND VS9.VS9_TIPOPE = ' '"
	cSQL += "   AND VS9.VS9_NUMIDE = '" + cNumOrc + "'"
	cSQL += "   AND VS9.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS9 , .F., .T. )
	dbSelectArea("VS9")
	While !( (cAliasVS9)->( Eof() ))
		dbGoTo( (cAliasVS9)->RECVS9 )
		If RecLock("VS9",.f.,.t.)
			DbDelete()
			MsUnLock()
		EndIf
		(cAliasVS9)->(DbSkip())
	EndDo
	//

	(cAliasVS9)->(dbCloseArea())
	dbSelectArea("VS1")
Return .t.

/*/{Protheus.doc} OM220Refresh
Exclusao da negociacao de um determinado orcamento
@author Rubens
@since 10/04/2018
@version 1.0

@param cNumOrc, characters, descricao
@type function
/*/
Function OM220Refresh()

	FatJobNFe()

Return