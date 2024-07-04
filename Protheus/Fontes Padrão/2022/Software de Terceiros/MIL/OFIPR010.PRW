// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "OFIPR010.CH"
#INCLUDE "protheus.ch"
#DEFINE DSugest  MV_PAR01
#DEFINE ClasCust MV_PAR02
#DEFINE TipPrc   MV_PAR03
#DEFINE ABCVend  MV_PAR04
#DEFINE Impot    MV_PAR05
#DEFINE GpDE     MV_PAR06
#DEFINE GpAte    MV_PAR07
#DEFINE cProdDe  MV_PAR08
#DEFINE cProdAte MV_PAR09
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIPR010 ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina p/ Cadastro de Sugestao de Compras                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIPR010()

PRIVATE lMSErroAuto := .F.
PRIVATE lMsHelpAuto := .F.
PRIVATE aSvAtela    := {{},{}}
PRIVATE aSvAGets    := {{},{}}
PRIVATE aTela       := {}
PRIVATE aGets       := {}
PRIVATE cOk         := GetMark()
PRIVATE nTipPrc     := SFJ->FJ_TIPPRC
PRIVATE nQtdGer     := 1
PRIVATE cSugegs     := ""
PRIVATE cDescForm   := ""
PRIVATE oEnc01
PRIVATE oEnc02
PRIVATE cCadastro   := OemToAnsi(STR0001) //"Sugestao de Compras"
PRIVATE aRotina     := MenuDef()

mBrowse( 6, 1,22,75,"SFJ",,"FJ_SOLICIT",20)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Inct³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada da Inclusao                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Inct(cAlias,nOpcao)

Local cAnoMes
Private lGerou2
Private lGrava2 :=.F.

IF !Pergunte("MTA297")
	Return
EndIF

IF Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIF

DbSelectArea("SBL")
DBSetOrder(2)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_ANO+BL_MES
IF !DbSeek(xFilial("SBL")+cAnoMes)
	Help(" ",1,"MTA297INC")
	Return .f.
EndIF

Processa({ || OFP010IncGt(cAlias,nOpcao) })
IF !lGrava2
	Help(" ",1,"MTA297NGER")
EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010IncGt³ Autor ³ Valdir F. Silva      ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao de Sugestao de Compras                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010IncGt(cAlias,nOpcao)

Local cAliasAnt := GetArea()
Local cABC      :=""
Local cCodigo   := CriaVar("FJ_CODIGO",.T.)
Local aSE       :={0,0,0}
Local nDiasRep  :=0
Local lGeraOutra:=.F.
Local lGrava    := .f.
Local nX
Local cImport
Local cTipCusto
Local cFormula
Local cAnoMes
Local ni		:= 0

Private aConsumo:={}
Private nAtual

If nOpcao == 9
	lGerou2 :=.t.
EndIf

IF Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIF

IF lGerou2
	Pergunte("MTA297",.f.)
	nQtdGer++
Else
	ProcRegua(SB1->(Reccount()))
EndIF

cImport   := IIf(Impot==1,STR0009,STR0010) //"S"###"N"
cTipCusto := Str(ClasCust,1)

If Alltrim(ABCVend) == "*"
	cABC:="AA/AB/AC/BA/BB/BC/CA/CB/CC/"
Else
	For nX:=1 to Len(AllTrim(ABCVend)) Step 2
		cABC:=cABC+Upper(SubStr(ABCVend,nX,2))+"/"
	Next
EndIf
SDF->(DbSetOrder(2))
SM4->(DbSetOrder(1))
DBSelectArea("SB1")
DbSetOrder(1) //SB1 Produtos		    ->B1_FILIAL+B1_COD

DBSelectArea("SBL")
DbSetOrder(2)  //Filial+Ano+Mes
DbSeek(xFilial("SBL")+cAnoMes)

nX:=1

While (SBL->BL_ANO+SBL->BL_MES == cAnoMes .and. xFilial("SBL")==SBL->BL_FILIAL .and. ! SBL->(Eof()))
	// Verifica a qunatidade de itens p/ nao estourar a getdados
	Incproc()
	IF nX > 4096
		lGeraOutra :=.t.
		Exit
	Else
		//Verifica produto de ate
		IF SBL->BL_PRODUTO < cProdDe .or. SBL->BL_PRODUTO > cProdAte
			DbSkip()
			Loop
		EndIF
		
		//Verifica Tipo custo 4=Todos
		IF cTipCusto # "4"
			IF SBL->BL_TIPCUST # cTipCusto
				DbSkip()
				Loop
			EndIF
		EndIF
		// Verifica ABC
		IF ! SBL->BL_ABCVEND+SBL->BL_ABCCUST+"/" $ cABC
			DbSkip()
			Loop
		EndIF
		//Procura o Produto se Nao achar vai p/ proximo SBL, Se Achar Verifica.
		IF ! SB1->(DbSeek(XFilial("SB1")+SBL->BL_PRODUTO))
			DbSkip()
			Loop
		Else
			IF SB1->B1_FLAGSUG # "1" .or. SB1->B1_CLASSVE # "1"
				DbSkip()
				Loop
			EndIF
			// Import 1=Sim 0=Nao
			IF  SB1->B1_IMPORT # cImport
				DbSkip()
				Loop
			EndIF
			// Verifica Grupo de e Grupo ate
			IF SB1->B1_GRUPO < GpDE .or. SB1->B1_GRUPO > GpAte
				DbSkip()
				Loop
			EndIF
		EndIF
		//Verifica SE EXISTE SUGESTAO EM ABERTO
		IF SDF->(DbSeek(xFilial("SDF")+"A"+SBL->BL_PRODUTO))
			DbSkip()
			Loop
		EndIF
		IF !Empty(SBL->BL_CODFORM)
			
			//Carregando aConsumo
			
			aConsumo := aConsumoSC(cAnoMes)
			nAtual   :=len(aConsumo) + 1
			//  + 1  p/pegar ULTIMA DEMANDA (ref ao mes imediatamente anterior)
			
			aSE      :=SaldoEst(SBL->BL_PRODUTO)
			If SBL->BL_CODFORM == "PES"
				cFormula := "aConsumo[nAtual-1]"
			ElseIf SBL->BL_CODFORM == "PME"
				cFormula := "(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3"
			ElseIf SBL->BL_CODFORM == "PTE"
				cFormula := "aConsumo[nAtual-1]+(aConsumo[nAtual-1]-aConsumo[nAtual-2])"
			ElseIf SBL->BL_CODFORM == "PSA"
				cFormula := "aConsumo[nAtual-12]*((aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/(aConsumo[nAtual-13]+aConsumo[nAtual-14]+aConsumo[nAtual-15]))"
			Else
				If SM4->(DbSeek(xFilial("SM4")+SBL->BL_CODFORM))
					cFormula := &(SM4->M4_FORMULA)
				Else
					SBL->(DbSkip())
					Loop
				EndIf
			EndIf
			
			// Verifica: qtde de ultimos meses a analizar X qtde de meses com demanda
			If (MV_PAR11 > 0) .and. (MV_PAR11 >= MV_PAR12)
				nMesDem := 0
				For ni:= 1 to MV_PAR11
					If aConsumo[nAtual-ni]>0
						nMesDem++
					EndIf
				Next
				If nMesDem < MV_PAR12
					DbSelectArea("SBL")
					DbSkip()
					Loop
				EndIf
			EndIf
			
			// Substitui Formula de TENDENCIA pela MEDIA 3 ULT.MESES
			If SBL->BL_CODFORM == "PTE"
				cFormula := "(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3"
				RecLock("SBL",.F.)
				SBL->BL_CODFORM := "PME"
				MsUnlock()
			endif
			
			// Substitui Formula de SAZONAL pela MEDIA 3 ULT.MESES
			
			If SBL->BL_CODFORM == "PSA"
				cFormula := "(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3"
				RecLock("SBL",.F.)
				SBL->BL_CODFORM := "PME"
				MsUnlock()
			endif
			
			nDiasRep:=0
			
			IF SB1->B1_TIPE == "H"
				nDiasRep:=MOD(SB1->B1_PE,24)
			ElseIF SB1->B1_TIPE == "D"
				nDiasRep:=SB1->B1_PE
			ElseIF SB1->B1_TIPE == "S"
				nDiasRep:=SB1->B1_PE*7
			ElseIF SB1->B1_TIPE == "M"
				nDiasRep:=SB1->B1_PE*30
			ElseIF SB1->B1_TIPE == "A"
				nDiasRep:=SB1->B1_PE*365
			EndIF
			
			// Grava SDF
			
			IF (&cFormula*(DSugest+nDiasRep)/30)-(aSE[1]+aSE[2]) > 0.49
				RecLock("SDF",.T.)
				SDF->DF_FILIAL  := xFilial("SDF")
				SDF->DF_CODIGO  := cCodigo
				SDF->DF_FLAG    := "A"
				SDF->DF_PRODUTO := SBL->BL_PRODUTO
				SDF->DF_QTDSUGM := &cFormula*(DSugest+nDiasRep)/30
				SDF->DF_QTDEST  := aSE[1]
				SDF->DF_QTDPC   := aSE[2]
				SDF->DF_QTDSUG  := SDF->DF_QTDSUGM-(SDF->DF_QTDEST+SDF->DF_QTDPC)
				If SDF->DF_QTDSUG < 1
					SDF->DF_QTDSUG := 1
				Endif
				
				IF SB1->B1_QE > 0
					If int(SDF->DF_QTDSUG/SB1->B1_QE) < (SDF->DF_QTDSUG/SB1->B1_QE)
						SDF->DF_QTDSUG := (int(SDF->DF_QTDSUG/SB1->B1_QE) + 1) * SB1->B1_QE
					Else
						SDF->DF_QTDSUG := int(SDF->DF_QTDSUG/SB1->B1_QE) * SB1->B1_QE
					EndIf
				EndIF
				
				IF TipPrc == 1
					SB5->(dbseek(xFilial("SB5")+SBL->BL_PRODUTO))
					If SDF->DF_QTDINF > 0
						SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB5->B5_PRV2)
					Else
						SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB5->B5_PRV2)
					EndIf
					
				ElseIF TipPrc == 2
					If SDF->DF_QTDINF > 0
						SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB1->B1_UPRC)
					Else
						SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB1->B1_UPRC)
					EndIf
				Else
					If SDF->DF_QTDINF > 0
						SDF->DF_VLRTOT  := (SDF->DF_QTDINF*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
					Else
						SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
					EndIf
					
				EndIF
				
				If SDF->DF_VLRTOT < 0.01
					SDF->DF_VLRTOT := 0.01
				Endif
				
				SDF->DF_QTDINF  := 0
				SDF->DF_M03     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3
				SDF->DF_M12     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3]+aConsumo[nAtual-4]+;
				aConsumo[nAtual-5]+aConsumo[nAtual-6]+aConsumo[nAtual-7]+aConsumo[nAtual-8]+;
				aConsumo[nAtual-9]+aConsumo[nAtual-10]+aConsumo[nAtual-11]+aConsumo[nAtual-12])/12
				SDF->DF_QE      :=SB1->B1_QE
				SDF->DF_D01     :=aConsumo[nAtual-1]
				SDF->DF_D02     :=aConsumo[nAtual-2]
				SDF->DF_D03     :=aConsumo[nAtual-3]
				SDF->DF_D04     :=aConsumo[nAtual-4]
				SDF->DF_D05     :=aConsumo[nAtual-5]
				SDF->DF_D06     :=aConsumo[nAtual-6]
				SDF->DF_D07     :=aConsumo[nAtual-7]
				SDF->DF_D08     :=aConsumo[nAtual-8]
				SDF->DF_D09     :=aConsumo[nAtual-9]
				SDF->DF_D10     :=aConsumo[nAtual-10]
				SDF->DF_D11     :=aConsumo[nAtual-11]
				SDF->DF_D12     :=aConsumo[nAtual-12]
				MsUnlock()
				DBSelectArea("SBL")
				lGrava:=.T.
				lGrava2:=.T.
				nX++
			EndIF
		EndIF
		DbSkip()
	EndIF
EndDo
// Se tem registro no SBL Grava
IF lGrava
	IF ( __lSx8 )
		ConfirmSX8()
	EndIF
	DbSelectArea("SFJ")
	IF !DbSeek(xFilial("SFJ")+cCodigo)
		RecLock("SFJ",.T.)
		cSugegs         += IIf(cSugegs="",+cCodigo," / "+cCodigo)
		SFJ->FJ_FILIAL  := xFilial("SFJ")
		SFJ->FJ_CODIGO  := cCodigo
		SFJ->FJ_DATREF  := dDataBase
		SFJ->FJ_DIASSUG := DSugest
		SFJ->FJ_CUSUNIT := Str(ClasCust,1)
		SFJ->FJ_TIPPRC  := Str(TipPrc,1)
		SFJ->FJ_IMPORT  := Str(Impot,1)
		SFJ->FJ_CLASSIF := cABC
		SFJ->FJ_ANO     := SubStr(cAnoMes,1,4)
		SFJ->FJ_MES     := SubStr(cAnoMes,5,2)
		SFJ->FJ_GRUPODE := GpDE
		SFJ->FJ_GRUPOAT := GpAte
		SFJ->FJ_SOLICIT := ""
	EndIF
	MsUnlock()
Else
	RollBackSx8()
EndIF
SDF->(DbSetOrder(1))
IF lGeraOutra
	OFP010IncGt(cAlias,9)
	Return .t.
EndIF
IF lGerou2
	MsgInfo(STR0065+Str(nQtdGer,3)+STR0066+" --> "+cSugegs)
	nQtdGer := 1
	cSugegs := ""
EndIF
RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Vist³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualizacao de Sugestao de Compras                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Vist()
Local aAltEnChoice   := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI			 := 0
PRIVATE nOpca        := 2
PRIVATE aCols        := {}
PRIVATE aHeader      := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL"  ,"DF_CODIGO","DF_DESC"   ,"DF_M12",;
"DF_M03"     ,"DF_D01"   ,"DF_D02"    ,"DF_D03",;
"DF_D04"     ,"DF_D05"   ,"DF_D06"    ,"DF_D07",;
"DF_D08"     ,"DF_D09"   ,"DF_D10"    ,"DF_D11",;
"DF_D12"     ,"DF_QTDEST","DF_QTDPC"  ,"DF_QTDSUGM",;
"DF_PE"      ,"DF_FLAG"}  //CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM

PRIVATE aCpoEnChoice := {{"FJ_CODIGO" ,"FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC",;
"FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT",;
"FJ_CLASSIF","FJ_TIPGER","FJ_FORNECE","FJ_LOJA",;
"FJ_FILENT" ,"FJ_COND"} ,;
{"DF_DESC"   ,"DF_PE"    ,"DF_M12"    ,"DF_M03",;
"DF_QTDSUGM","DF_QTDEST","DF_QTDPC"  ,"DF_QE",;
"DF_D01"    ,"DF_D02"   ,"DF_D03"    ,"DF_D04",;
"DF_D05"    ,"DF_D06"   ,"DF_D07"    ,"DF_D08",;
"DF_D09"    ,"DF_D10"   ,"DF_D11"    ,"DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

PRIVATE nUsado := 0
For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
RegToMemory("SFJ",.F.)
MontaHead()
MontaCols()
lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,"OFP010Lit()","OFP010OKt()",2,4,,,,aAltEnchoice,"",aAltGetDados)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Exct³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao de Sugestao de Compras                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Exct()

Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI 	 := 0
PRIVATE nOpca   := 2
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC"  ,"DF_M12"  ,"DF_M03",;
"DF_D01"   ,"DF_D02"   ,"DF_D03"   ,"DF_D04"  ,"DF_D05",;
"DF_D06"   ,"DF_D07"   ,"DF_D08"   ,"DF_D09"  ,"DF_D10",;
"DF_D11"   ,"DF_D12"   ,"DF_QTDEST","DF_QTDPC","DF_QTDSUGM",;
"DF_PE"    ,"DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM

PRIVATE nUsado := 0
PRIVATE aCpoEnChoice := {{"FJ_CODIGO" ,"FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC",;
"FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT",;
"FJ_CLASSIF","FJ_TIPGER","FJ_FORNECE","FJ_LOJA",;
"FJ_FILENT" ,"FJ_COND"} ,;
{"DF_DESC"   ,"DF_PE"    ,"DF_M12"    ,"DF_M03",;
"DF_QTDSUGM","DF_QTDEST","DF_QTDPC"  ,"DF_QE" ,;
"DF_D01"    ,"DF_D02"   ,"DF_D03"    ,"DF_D04",;
"DF_D05"    ,"DF_D06"   ,"DF_D07"    ,"DF_D08",;
"DF_D09"    ,"DF_D10"   ,"DF_D11"    ,"DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF !Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297EXC")
Else
	RegToMemory("SFJ",.F.)
	MontaHead()
	MontaCols()
	lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,,"OFP010OKt()",5,4,,,,aAltEnchoice,"",aAltGetDados)
	IF lRet
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While SDF->DF_CODIGO==SFJ->FJ_CODIGO .and. SDF->DF_FILIAL==xFilial("SDF") .and. ! SDF->(Eof())
			SDF->(RecLock("SDF",.F.))
			SDF->(DbDelete())
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
		SFJ->(RecLock("SFJ",.F.))
		SFJ->(DbDelete())
		SFJ->(MsUnlock())
	EndIF
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Altt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao de Sugestao de Compras                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Altt()

Local aAltEnChoice   := {"FJ_TIPPRC","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet
Local nI
PRIVATE nOpca        := 4
PRIVATE aCols        := {}
PRIVATE aHeader      := {}
PRIVATE aAltGetDados := {"DF_QTDINF","DF_PRODUTO","DF_CODGRP","DF_CODITE"}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO" ,"DF_DESC"  ,"DF_M12"    ,;
"DF_M03"   ,"DF_D01"    ,"DF_D02"   ,"DF_D03"    ,;
"DF_D04"   ,"DF_D05"    ,"DF_D06"   ,"DF_D07"    ,;
"DF_D08"   ,"DF_D09"    ,"DF_D10"   ,"DF_D11"    ,;
"DF_D12"   ,"DF_QTDEST" ,"DF_QTDPC" ,"DF_QTDSUGM",;
"DF_PE"    ,"DF_FLAG"}  //CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE nUsado := 0
PRIVATE aCpoEnChoice := {{"FJ_CODIGO" ,"FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC" ,;
"FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE","FJ_GRUPOAT",;
"FJ_CLASSIF","FJ_TIPGER","FJ_FORNECE","FJ_LOJA"   ,;
"FJ_FILENT" ,"FJ_COND"} ,;
{"DF_DESC"   ,"DF_PE"    ,"DF_M12"    ,"DF_M03"    ,;
"DF_QTDSUGM","DF_QTDEST","DF_QTDPC"  ,"DF_QE"     ,;
"DF_D01"    ,"DF_D02"   ,"DF_D03"    ,"DF_D04"    ,;
"DF_D05"    ,"DF_D06"   ,"DF_D07"    ,"DF_D08"    ,;
"DF_D09"    ,"DF_D10"   ,"DF_D11"    ,"DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF Empty(SFJ->FJ_SOLICIT)
	nTipPrc := SFJ->FJ_TIPPRC
	RegToMemory("SFJ",.F.)
	MontaHead()
	MontaCols()
	lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,"OFP010Lit()","OFP010OKt()",4,4,,,,aAltEnchoice,"",aAltGetDados)
Else
	Help(" ",1,"MTA297GER")
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Impt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao de Sugestao de Compras                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Impt()

Local cAliasAnt := GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aOrd := {}
Local cDesc1       := STR0012 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0013 //"de acordo com os parametros informados pelo usuario."
Local cDesc3       := ""
Local nLin         := 220
Local Cabec1       := ""
Local Cabec2       := ""
Private li         := 0
Private nTamanho   := "G"
Private At_Prg     := "OFIPR010" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 15
Private aReturn    := {STR0014, 1, STR0015, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey   := 0
Private Titulo     := STR0001 //"Sugestao de Compras"
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "SugComp" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "SDF"
dbSelectArea("SDF")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,At_Prg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,nTamanho,,.T.)

IF nLastKey == 27
	Return
EndIF

SetDefault(aReturn,cString)

IF nLastKey == 27
	Return
EndIF
nTipo := IIf(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| OF010ImpRT() },Titulo)

RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Gert³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Geracao de Solicitacao/Pedido de Compras                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Gert(nViaTrans,cCodTrans,nPagto48h,cPedFab,cTipPed)

Local cAliasAnt:=GetArea()
Local nCont    :=1
Local aCab     :={}
Local aItem    :={}
Local cScAnt
Local cNumero

IF !Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297GER")
	Return
EndIF

IF M->FJ_TIPGER=="1"
	cNumero  :=CriaVar("C1_NUM",.T.)
	IF !(SC1->(dbSeek(xFilial("SC1")+cNumero)))
		cScAnt := NextNumero("SC1",1,"C1_NUM",.F.,cNumero)
		IF cScAnt # cNumero
			cNumero := cScAnt
		EndIF
	EndIF
	
	aCab := {{"C1_NUM"          ,cNumero   ,Nil},;
	{"C1_EMISSAO"      ,dDataBase ,Nil}}
	
	SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
		
		If (SDF->DF_QTDINF+SDF->DF_QTDSUG) > 0
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))
			AADD(aItem,{{"C1_ITEM"    ,StrZero(nCont,2) ,Nil },;
			{"C1_PRODUTO" ,SDF->DF_PRODUTO  ,Nil },;
			{"C1_UM"      ,SB1->B1_UM       ,Nil },;
			{"C1_QUANT"   ,IIf(SDF->DF_QTDINF > 0,SDF->DF_QTDINF,SDF->DF_QTDSUG),Nil },;
			{"C1_FORNECE" ,SB1->B1_PROC     ,Nil }})
			nCont++
		Endif
		SDF->(DbSkip())
		
	EndDo
	lMsErroAuto := .f.
	MSExecAuto({|x,y| MATA110(x,y)},aCab,aItem)
	IF !lMSErroAuto
		IF ( __lSx8 )
			ConfirmSX8()
		EndIF
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=cNumero
		SFJ->FJ_TIPGER :=M->FJ_TIPGER
		SFJ->(MsUnlock())
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			RecLock("SDF",.F.)
			SDF->DF_FLAG    := "F"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
	Else
		Help(" ",1,"MTA297GER1")
		RollBackSx8()
		DisarmTransaction()
		Break
	EndIF
ElseIF M->FJ_TIPGER=="2"
	If Empty(M->FJ_FORNECE) .or. Empty(M->FJ_LOJA) .or. Empty(M->FJ_COND)
		Help(" ",1,"MTA297GER2")
		Return
	EndIF
	cNumero  :=CriaVar("C7_NUM",.T.)
	SA2->(dbSeek(xFilial("SA2")+M->FJ_FORNECE+M->FJ_LOJA))
	
	aCab:={{"C7_NUM"     ,cNumero          ,Nil},; // Numero do Pedido
	{"C7_EMISSAO" ,dDataBase        ,Nil},; // Data de Emissao
	{"C7_FORNECE" ,M->FJ_FORNECE    ,Nil},; // Fornecedor
	{"C7_LOJA"    ,M->FJ_LOJA       ,Nil},; // Loja do Fornecedor
	{"C7_COND"    ,M->FJ_COND       ,Nil},; // Condicao de pagamento
	{"C7_CONTATO" ,"               ",Nil},; // Contato
	{"C7_FILENT"  ,M->FJ_FILENT     ,Nil}}  // Filial Entrega
	
	SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
	cCodMar:=Traz_Marca(SDF->DF_PRODUTO)
	
	While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
		
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))
		If (SDF->DF_QTDINF+SDF->DF_QTDSUG) > 0
			aadd(aItem,{{"C7_ITEM"   ,StrZero(nCont,2) ,Nil},; //Numero do Item
			{"C7_PRODUTO",SDF->DF_PRODUTO  ,Nil},; //Codigo do Produto
			{"C7_UM"     ,SB1->B1_UM       ,Nil},; //Unidade de Medida
			{"C7_QUANT"  ,IIf(SDF->DF_QTDINF > 0,SDF->DF_QTDINF,SDF->DF_QTDSUG),Nil},; //Quantidade
			{"C7_PRECO"  ,(SDF->DF_VLRTOT/IIf(SDF->DF_QTDINF > 0,SDF->DF_QTDINF,SDF->DF_QTDSUG)),Nil},; //Preco
			{"C7_DATPRF" ,dDataBase        ,Nil},; //Data De Entrega
			{"C7_FLUXO"  ,"S"              ,Nil},; //Fluxo de Caixa (S/N)
			{"C7_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil}}) //Localizacao
			nCont++
		EndIf
		SDF->(DbSkip())
		
	EndDo
	lMsErroAuto := .f.
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,3)
	IF !lMSErroAuto
		IF ( __lSx8 )
			ConfirmSX8()
		EndIF
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=cNumero
		SFJ->FJ_FORNECE:=M->FJ_FORNECE
		SFJ->FJ_LOJA   :=M->FJ_LOJA
		SFJ->FJ_TIPGER :=M->FJ_TIPGER
		SFJ->FJ_FILENT :=M->FJ_FILENT
		SFJ->FJ_COND   :=M->FJ_COND
		SFJ->(MsUnlock())
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			RecLock("SDF",.F.)
			SDF->DF_FLAG := "F"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
		//Gravar Pedido da MIL aqui
		If GetMV("MV_VEICULO") == "S"
			VE4->(dbseek(xFilial("VE4")+cCodMar))
			If !("VEI"$cFopened)
				ChkFile("VEI",.F.)
			EndIf
			RecLock("VEI",.T.)
			VEI->VEI_FILIAL :=xFilial("VEI")
			VEI->VEI_CODMAR :=cCodMar
			VEI->VEI_NUM    :=cNumero
			VEI->VEI_PEDFAB :=IIf(VE4->VE4_PEDINI>0,StrZero(val(cPedFab),13),space(13-len(alltrim(cPedFab)))+alltrim(cPedFab))
			VEI->VEI_TIPPED :=cTipPed
			VEI->VEI_VIATRA :=Str(nViaTrans,1)
			VEI->VEI_TRANSP :=cCodTrans
			VEI->VEI_PGT48H :=Str(nPagto48h,1)
			VEI->VEI_DATSC7 :=dDataBase
			VEI->VEI_HORSC7 :=Val(Substr(Time(),1,2)+Substr(Time(),4,2))
			VEI->(MsUnlock())
		EndIF
	Else
		Help(" ",1,"MTA297GER1")
		RollBackSx8()
		DisarmTransaction()
		Break
	EndIF
EndIF

RestArea(cAliasAnt)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OFP010Cant³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelamento de Solicitacao/Pedido de Compras              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Cant()
Local aCpoEnChoice := {{"FJ_CODIGO","FJ_DATREF","FJ_DIASSUG","FJ_TIPPRC","FJ_CUSUNIT","FJ_IMPORT","FJ_GRUPODE",;
"FJ_GRUPOAT","FJ_CLASSIF","FJ_TIPGER","FJ_FORNECE","FJ_LOJA","FJ_FILENT","FJ_COND"},;
{"DF_DESC","DF_PE","DF_M12","DF_M03","DF_QTDSUGM","DF_QTDEST","DF_QTDPC","DF_QE",;
"DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

Local aAltEnChoice := {}//CAMPOS P/ ALTERAR NA ENCHOICE
Local lRet , cSolicit:=""
Local aCab      :={}
Local aItem     :={}
Local nI		:= 0
PRIVATE nOpca   := 5
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aAltGetDados := {}// CAMPO P/ ATERAR NO GETDADOS/ITEM
PRIVATE aCpoGetDados := {"DF_FILIAL","DF_CODIGO","DF_DESC","DF_M12","DF_M03","DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12","DF_QTDEST","DF_QTDPC","DF_QTDSUGM","DF_PE","DF_FLAG"}//CAMPO P/ NAO MOSTAR NO GETDADOS/ITEM
PRIVATE nUsado := 0
For nI := 1 to Len(aCpoGetDados)
	aCpoGetDados[nI] := Padr(aCpoGetDados[nI],10)
Next
IF Empty(SFJ->FJ_SOLICIT)
	Help(" ",1,"MTA297CAN")
Else
	RegToMemory("SFJ",.F.)
	MontaHead()
	MontaCols()
	lRet:=Modelo3(cCadastro,"SFJ","SDF",aCpoEnChoice,,"OFP010OKt()",5,4,,,,aAltEnchoice,"",aAltGetDados)
	lMshelpAuto := .t.
	Begin Transaction
	IF lRet .and. M->FJ_TIPGER=="1" //Cancela Solicitacao de Compra
		SC1->(DbSetOrder(1))
		If SC1->(DbSeek(xFilial("SC1")+SFJ->FJ_SOLICIT))
			AADD(aCab ,{"C1_NUM"	,SFJ->FJ_SOLICIT ,Nil})
			AADD(aItem,{{"C1_NUM"	,SFJ->FJ_SOLICIT ,Nil}})
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| MATA110(x,y,z)},aCab,aItem,5)
		EndIf
	ElseIF lRet .and. M->FJ_TIPGER=="2" //Cancela Pedido de Compra
		SC7->(DbSetOrder(1))
		If SC7->(DbSeek(xFilial("SC7")+SFJ->FJ_SOLICIT))
			AADD(aCab ,{"C7_NUM"	,SFJ->FJ_SOLICIT ,Nil})
			AADD(aItem,{{"C7_NUM"	,SFJ->FJ_SOLICIT ,Nil}})
			lMsErroAuto := .f.
			MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItem,5)
		EndIf
	EndIF
	IF lRet .and. !lMSErroAuto
		
		cSolicit := SFJ->FJ_SOLICIT
		
		RecLock("SFJ",.F.)
		SFJ->FJ_SOLICIT:=""
		SFJ->FJ_FORNECE:=""
		SFJ->FJ_LOJA   :=""
		SFJ->FJ_FILENT :=""
		SFJ->FJ_TIPGER :=""
		SFJ->FJ_COND   :=""
		MsUnlock()
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO))
		While (SDF->DF_CODIGO == SFJ->FJ_CODIGO) .and. xFilial("SDF")==SDF->DF_FILIAL .and. ! SDF->(Eof())
			
			//Gravar Pedido da MIL aqui
			If GetMV("MV_VEICULO") == "S"
				If !("VEI"$cFopened)
					ChkFile("VEI",.F.)
				EndIf
				DbSelectArea("VEI")
				DbSetOrder(1)
				If DbSeek(xFilial("VEI")+Traz_Marca(SDF->DF_PRODUTO)+cSolicit)
					RecLock("VEI",.F.,.T.)
					dbdelete()
					MsUnlock()
					WriteSx2("VEI")
				EndIf
			EndIF
			
			DbSelectArea("SDF")
			RecLock("SDF",.F.)
			SDF->DF_FLAG    := "A"
			SDF->(MsUnlock())
			SDF->(DbSkip())
		EndDo
	Else
		If lRet
			Help(" ",1,"MTA297CAN1")
			DisarmTransaction()
			Break
		EndIf
	EndIF
	End Transaction
	IF lMsErroAuto
		MostraErro()
	EndIF
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OF010ImpRT³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao de Sugestao de Compras                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OF010ImpRT()
Local cText
Local nCont
Local nValor:=0
dbSelectArea(cString)
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(RecCount())
WCABEC0 := 4
WCABEC1 :=STR0016+SFJ->FJ_CODIGO+STR0017+DtoC(SFJ->FJ_DATREF)+STR0018+Str(SFJ->FJ_DIASSUG,2) //"Numero : "###"     Referencia : "###"     Sugestao p/ "
WCABEC1 :=WCABEC1+STR0021 //"     Tipo de Preco : "
WCABEC1 :=WCABEC1+IIF(SFJ->FJ_TIPPRC="1",STR0022,IIF(SFJ->FJ_TIPPRC="2",STR0023,STR0024)) //"Custo Medio"###"Reposicao"###"Preco de Venda"
WCABEC1 :=WCABEC1+STR0025+IIF(SFJ->FJ_CUSUNIT="1",STR0026,IIF(SFJ->FJ_CUSUNIT="2",STR0027,IIF(SFJ->FJ_CUSUNIT="3",STR0028,STR0064))) //"     Custo Unitario : "###"Alto"###"Medio"###"Baixo"## Todos
WCABEC1 :=WCABEC1+STR0029+IIf(SFJ->FJ_IMPORT="1",STR0030,STR0031)+STR0032+SFJ->FJ_CLASSIF+IIf(!Empty(SFJ->FJ_SOLICIT),IIf(SFJ->FJ_TIPGER == "1",STR0072,STR0073),"")+SFJ->FJ_SOLICIT   //"     Importado : "###"Sim"###"Nao"###"     ClassIFicacao : " //"  N. Solicitacao: "###"  N. Pedido: "
WCABEC2 :=Replicate("-",IIF(nTamanho=="P",80,IIF(nTamanho=="G",220,132)))
WCABEC3 :=Space(80)+STR0033+STR0034+STR0035+STR0036+STR0037+STR0038+STR0039 //"Ultima                      "###"Media   "###"Media    "###"Media       "###"A      "###"Qtd. "###"------------------------------- Demanda -------------------------------"
WCABEC4 :=STR0040+STR0041+STR0042+STR0043+STR0044+STR0045+STR0046+STR0047+STR0048+STR0049+STR0050+STR0051+STR0052 //"Gir/Fin "###"Codigo               "###"Descricao                   "###"G.D Sugestao  "###"Pedido   "###"Compra       "###"Preco Total "###"12 Meses "###"3 Meses "###"p/ Calc. "###"Disp. "###"Receb. "###"Emb. "
For nCont:=1 to 12
	WCABEC4:=WCABEC4+StrZero(Month(SToD("15/"+SFJ->FJ_MES+"/"+SFJ->FJ_ANO,"dd/mm/yy")-365+(nCont*30)),2)+"/"
	WCABEC4:=WCABEC4+SubStr(StrZero(Year(SToD("15/"+SFJ->FJ_MES+"/"+SFJ->FJ_ANO,"dd/mm/yy")-365+(nCont*30)),4),3,2)+Space(1)
Next
SBL->(DbSetOrder(1))
DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO)
While SDF->DF_FILIAL==xFilial("SDF") .and. SDF->DF_CODIGO == SFJ->FJ_CODIGO .and. !EOF()
	//LOCALIZA O SBL
	SBL->(DbSeek(xFilial("SBL")+SDF->DF_PRODUTO+SFJ->FJ_ANO+SFJ->FJ_MES))
	//LOCALIZA O PRODUTO
	SB1->(DbSeek(xFilial("SB1")+SDF->DF_PRODUTO))

	cText:=SBL->BL_ABCVEND+"/"+SBL->BL_ABCCUST+" "   // ABC Giro / Finaceiro
	cTExt:=cText+SB1->B1_GRUPO+" "+SubStr(SB1->B1_CODITE,1,25)+SubStr(SB1->B1_DESC,1,27)
	cTExt:=cText+Transform(SDF->DF_QTDSUG,"99999999")+" >"+Transform(SDF->DF_QTDINF,"999999")+"< "
	
	cTExt:=cText+DToC(SB1->B1_UCOM)+Space(2)
	If SDF->DF_QTDINF > 0
		cTExt:=cText+Transform((SDF->DF_VLRTOT/IIf(Empty(SDF->DF_QTDSUG),1,SDF->DF_QTDSUG))*SDF->DF_QTDINF,"@E 9999,999,999.99")
	Else
		cTExt:=cText+Transform(SDF->DF_VLRTOT,"@E 9999,999,999.99")
	EndIf
	cTExt:=cText+Transform(SDF->DF_M12,"999999999")
	cTExt:=cText+Transform(SDF->DF_M03,"99999999")+Transform(SDF->DF_QTDSUGM,"999999999")
	cTExt:=cText+Transform(SDF->DF_QTDEST,"999999")+Transform(SDF->DF_QTDPC,"9999999")+Transform(SDF->DF_QE,"99999")
	//Demanda dos ultimos 12 Meses
	cTExt:=cText+IIf(SDF->DF_D12 >0,Transform(SDF->DF_D12,"999999"),"     -")+IIf(SDF->DF_D11 >0,Transform(SDF->DF_D11,"999999"),"     -")
	cTExt:=cText+IIf(SDF->DF_D10 >0,Transform(SDF->DF_D10,"999999"),"     -")+IIf(SDF->DF_D09 >0,Transform(SDF->DF_D09,"999999"),"     -")
	cTExt:=cText+IIf(SDF->DF_D08 >0,Transform(SDF->DF_D08,"999999"),"     -")+IIf(SDF->DF_D07 >0,Transform(SDF->DF_D07,"999999"),"     -")
	cTExt:=cText+IIf(SDF->DF_D06 >0,Transform(SDF->DF_D06,"999999"),"     -")+IIf(SDF->DF_D05 >0,Transform(SDF->DF_D05,"999999"),"     -")
	cTExt:=cText+IIf(SDF->DF_D04 >0,Transform(SDF->DF_D04,"999999"),"     -")+IIf(SDF->DF_D03 >0,Transform(SDF->DF_D03,"999999"),"     -")
	cTExt:=cText+IIf(SDF->DF_D02 >0,Transform(SDF->DF_D02,"999999"),"     -")+IIf(SDF->DF_D01 >0,Transform(SDF->DF_D01,"999999"),"     -")
	Impr(cText,"C")
	
	If SDF->DF_QTDINF > 0
		nValor += ((SDF->DF_VLRTOT/IIf(Empty(SDF->DF_QTDSUG),1,SDF->DF_QTDSUG))*SDF->DF_QTDINF)
	Else
		nValor += SDF->DF_VLRTOT
	EndIf

	SDF->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo
//Totais
Impr(Space(87)+"----------------","C")
Impr(Space(89)+Transform(nValor,"@E 999,999,999.99"),"C")
Impr("","F")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIF

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFP010Lit ³ Autor ³ Valdir F. Silva      ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Muda de Linha                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010Lit()
Local nx
Local lRet := .T.
Local lDeleted := .F.

If ValType(aCols[n,Len(aCols[n])]) == "L"
	lDeleted := aCols[n,Len(aCols[n])]      // Verifica se esta Deletado
EndIf
If !lDeleted
	For nx := 1 To Len(aCols)
		If Mod(aCols[nx,ProcH('DF_QTDINF')],IIf(aCols[nx,ProcH('DF_QE')] > 0,aCols[nx,ProcH('DF_QE')],1)  ) > 0
			Help(" ",1,"MTA297LIN")
			lRet := .f.
		EndIf
		If !lRet
			Exit
		EndIf
	Next nx
EndIf

If lRet
	lRet := FG_OBRIGAT()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFP010OKt³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tudo Ok                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFP010OKt()
Local lRet := .T.
Local nX
Local lDeleted := .F.
Local lContinua := .f.
IF nOpca == 4 //Alterar
	IF M->FJ_TIPGER == "2"
		If Empty(M->FJ_FORNECE) .or. Empty(M->FJ_LOJA) .or. Empty(M->FJ_FILENT) .or. Empty(M->FJ_COND)
			lMshelpAuto := .f.
			Help(" ",1,"MTA297PED")
			Return .F.
		EndIf
		lContinua:=MsgYesNo(STR0071,STR0062) //"Confirma a Geracao do Pedido de Compra"
		If lContinua .and. GetMV("MV_VEICULO") == "S"
			If !Pergunte("MT297A",.T.)
				Return .F.
			EndIF
		EndIF
		
	ElseIF M->FJ_TIPGER == "1"
		lContinua:=MsgYesNo(STR0070,STR0062) //"Confirma a Geracao da Solicitacao de Compras"
	EndIf
	lMshelpAuto := .t.
	Begin Transaction
	For nX:=1 to Len(aCols)
		IF ValType(aCols[nX,Len(aCols[nX])]) == "L"
			lDeleted := aCols[nX,Len(aCols[nX])]      // Verfiica se esta Deletado
		EndIF
		
		DbSelectArea("SDF")
		DbSetOrder(1)
		
		SDF->(DbSeek(xFilial("SDF")+SFJ->FJ_CODIGO+aCols[nX,ProcH('DF_PRODUTO')]))
		
		IF ! lDeleted
			
			SDF->(RecLock("SDF",!SDF->(Found())))
			
			FG_GRAVAR("SDF",aCols,aHeader,nX)
			
			SDF->DF_FILIAL := xFilial("SDF")
			SDF->DF_CODIGO := SFJ->FJ_CODIGO
			
			SDF->(MsUnlock())
			
		Else
			
			If Found()
				SDF->(RecLock("SDF",.F.))
				SDF->(DbDelete())
				SDF->(MsUnlock())
			EndIF
			
		EndIF
		
	Next
	IF M->FJ_TIPPRC # nTipPrc
		SFJ->(RecLock("SFJ",.F.))
		SFJ->FJ_TIPPRC := M->FJ_TIPPRC
		SFJ->(MsUnlock())
	EndIF
	If lContinua
		OFP010Gert(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05)
	EndIF
	End Transaction
	IF lMsErroAuto
		MostraErro()
		lRet := .F.
	EndIF
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
EndIF
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SaldoEst ³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ SaldoEst                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCod = Codigo do Produto ( B1_COD )                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SaldoEst(cCod)
Local cAlias :=GetArea()
Local nSaldo :=0
Local nPend  :=0
Local nVezes :=0
Local nCustoM:=0
DbSelectArea("SB2")
DBSetOrder(1)  //SB2 Acum.Sugest.Compra	->B2_FILIAL+B2_COD+B2_LOCAL
DbSeek(xFilial("SB2")+cCod)
While ! eof() .and. B2_FILIAL == xFilial("SB2") .and. B2_COD == cCod
	If Trim(GetMV("MV_VEICULO")) == "S" .and. B2_LOCAL > '50'
		DbSkip()
		Loop
	EndIf
	nVezes++
	nSaldo  += B2_QATU
	nPend   += B2_SALPEDI
	nCustoM += B2_CM1
	DbSkip()
EndDo
RestArea(cAlias)
IF nVezes > 0
	nCustoM := (nCustoM/nVezes)
EndIF
Return {nSaldo,nPend,nCustoM}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaHead³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aHeader                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaHead()
local npos:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SDF")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aHeader para a GetDados()                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .And. (X3_ARQUIVO == "SDF")
	nPos := Ascan(aCpoGetDados,X3_CAMPO)
	IF X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. Empty(nPos)
		nUsado:=nUsado+1
		AADD(aHeader,{ Trim(X3Titulo()),;
		X3_CAMPO,;
		X3_PICTURE,;
		X3_TAMANHO,;
		X3_DECIMAL,;
		X3_VALID,;
		X3_USADO,;
		X3_TIPO,;
		X3_ARQUIVO,;
		X3_CONTEXT,;
		X3_RELACAO,;
		X3_RESERV  } )
		
	EndIF
	dbSkip()
Enddo
Return
//Monta Cols
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MontaCols³ Autor ³ Valdir F. Silva       ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aCols                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaCols()
Local _ni 	:= 0
aCols       := {}
DbSelectArea("SDF")
DbSetOrder(1)
DbSeek( xFilial("SDF")+SFJ->FJ_CODIGO )
While !Eof() .And. DF_CODIGO==SFJ->FJ_CODIGO .and. xFilial("SDF")==SDF->DF_FILIAL
	
	AADD(aCols,Array(nUsado+1))
	
	For _ni:=1 to nUsado
		If ( aHeader[_ni][10] != "V")
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Else
			aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2],.t.)
		EndIf
	Next
	
	aCols[Len(aCols),nUsado+1]:=.F.
	
	dbSkip()
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Modelo3	  ³ Autor ³ Wilson		        ³ Data ³ 17/03/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice e GetDados									  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk, 	  ³±±
±±³			 ³cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice  ³±±
±±³			 ³  ,nFreeze,aAlter)                                          ³±±
±±³			 ³lRet=Retorno .T. Confirma / .F. Abandona			  		  ³±±
±±³			 ³cTitulo=Titulo da Janela 									  ³±±
±±³			 ³cAlias1=Alias da Enchoice									  ³±±
±±³			 ³cAlias2=Alias da GetDados									  ³±±
±±³			 ³aMyEncho=Array com campos da Enchoice						  ³±±
±±³			 ³cLinOk=LinOk 											 	  ³±±
±±³			 ³cTudOk=TudOk 											 	  ³±±
±±³			 ³nOpcE=nOpc da Enchoice								 	  ³±±
±±³			 ³nOpcG=nOpc da GetDados								 	  ³±±
±±³			 ³cFieldOk=validacao para todos os campos da GetDados 		  ³±±
±±³			 ³lVirtual=Permite visualizar campos virtuais na enchoice	  ³±±
±±³			 ³nLinhas=Numero Maximo de linhas na getdados			  	  ³±±
±±³			 ³aAltEnchoice=Array com campos da Enchoice Alteraveis		  ³±±
±±³			 ³nFreeze=Congelamento das colunas.                           ³±±
±±³			 ³aAlter =Campos do GetDados a serem alterados.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFP010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³         nAtualIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Valdir F. Sil³11/05/00³XXXXXX³Colocar campos alteraveis no GetDados    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,aAlter)
Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno()),oDlg
Local aCpoAlt:={} , nX:=0
Local i := 0
Private Altera:=.t.,Inclui:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
Private oDesc
Private cDesc := " "
Private M
Private ameses:= {STR0074,STR0075,STR0076,STR0077,STR0078,STR0079,STR0080,STR0081,STR0082,STR0083,STR0084,STR0085}
Private aMesAno:={"","","","","","","","","","","",""}
Private naColsDados := Len(aCols)

For nX:=1 to Len(aAlter)
	If !( aAlter[nX] $ "DF_CODGRP/DF_CODITE" )
		Aadd( aCpoAlt , aAlter[nX] )
	EndIf
Next

IF Month(dDataBase)==1
	cAnoMes := StrZero(Year(dDataBase)-1,4)+"12"
Else
	cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)
EndIF

nOpcE    := IIf(nOpcE==Nil,3,nOpcE)
nOpcG    := IIf(nOpcG==Nil,3,nOpcG)
lVirtual := IIF(lVirtual==Nil,.F.,lVirtual)
nLinhas  := IIF(nLinhas==Nil,3000,nLinhas)
DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 35,80  of oMainWnd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice 01							                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
dbSelectArea("SFJ")
RegToMemory("SFJ")
Zero()
oEnc01:= MsMGet():New("SFJ" ,nReg ,nOpcE,,,,aMyEncho[1],{15,1,65,317},aAltEnchoice,3,,,,oDLG,,,lVirtual,"aSvATela[1]")
oEnc01:oBox:bGotFocus  := {|| AL_EntraEnc(1,"SFJ")}
oEnc01:oBox:bLostFocus := {|| AL_SaiEnc(1)}
aSvATela[1] := aClone(aTela)
aSvAGets[1] := aClone(aGets)

//  "DF_D01","DF_D02","DF_D03","DF_D04","DF_D05","DF_D06","DF_D07","DF_D08","DF_D09","DF_D10","DF_D11","DF_D12"}}  //CAMPOS P/ MOSTRA NA ENCHOICE

If len(aCols) > 0 .and. !Empty(aCols[1,ProcH('DF_PRODUTO')])
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xfilial("SB1")+aCols[1,ProcH('DF_PRODUTO')])
	
Endif

@ 153, 004 SAY STR0086    SIZE 100,08 					OF ODLG PIXEL
@ 160, 004 SAY oProd VAR SB1->B1_DESC SIZE 100,08 				OF ODLG PIXEL COLOR CLR_HBLUE
@ 153, 080 SAY STR0087                     					OF ODLG PIXEL
@ 160, 095 SAY OBJ01 VAR Transf(SDF->DF_M12,[@E 99,999.9])  	OF ODLG PIXEL COLOR CLR_HBLUE
@ 153, 125 SAY STR0088                     					OF ODLG PIXEL
@ 160, 140 SAY OBJ02 VAR Transf(SDF->DF_M03,[@E 99,999.9])  	OF ODLG PIXEL COLOR CLR_HBLUE
@ 153, 169 SAY STR0089                       					OF ODLG PIXEL
@ 160, 179 SAY OBJ03 VAR Transf(SDF->DF_QTDEST,[@E 99,999])  OF ODLG PIXEL COLOR CLR_HRED
@ 153, 201 SAY STR0090                         					OF ODLG PIXEL
@ 160, 210 SAY OBJ04 VAR Transf(SDF->DF_QTDPC,[@E 99,999])   OF ODLG PIXEL COLOR CLR_HRED
@ 153, 232 SAY STR0091                    					OF ODLG PIXEL
@ 160, 255 SAY OBJ06 VAR SB1->B1_PE               					OF ODLG PIXEL COLOR CLR_HBLUE
@ 153, 274 SAY STR0092                                                              OF ODLG PIXEL
@ 160, 276 SAY OBJ07 VAR Transf(SDF->DF_QTDSUGM,[@E 99,999.9]) OF ODLG PIXEL COLOR CLR_HBLUE
@ 153, 304 SAY STR0093                              					OF ODLG PIXEL
@ 160, 305 SAY OBJ08 VAR SBL->BL_ABCVEND          					OF ODLG PIXEL COLOR CLR_HBLUE
@ 160, 310 SAY OBJ09 VAR SBL->BL_ABCCUST          					OF ODLG PIXEL COLOR CLR_HBLUE

For i := 1 to 12
	m := month(SFJ->FJ_DATREF) - i
	m := IIf(m<1, m + 12, m)
	aMesAno[i] :=aMeses[m]+"/"+ IIf(m<month(SFJ->FJ_DATREF),str(year(SFJ->FJ_DATREF),4),str(year(SFJ->FJ_DATREF)-1,4))
Next

@ 170, 01*26 - 22 SAY aMesAno[01]            OF ODLG PIXEL
@ 170, 02*26 - 22 SAY aMesAno[02]            OF ODLG PIXEL
@ 170, 03*26 - 22 SAY aMesAno[03]            OF ODLG PIXEL
@ 170, 04*26 - 22 SAY aMesAno[04]            OF ODLG PIXEL
@ 170, 05*26 - 22 SAY aMesAno[05]            OF ODLG PIXEL
@ 170, 06*26 - 22 SAY aMesAno[06]            OF ODLG PIXEL
@ 170, 07*26 - 22 SAY aMesAno[07]            OF ODLG PIXEL
@ 170, 08*26 - 22 SAY aMesAno[08]            OF ODLG PIXEL
@ 170, 09*26 - 22 SAY aMesAno[09]            OF ODLG PIXEL
@ 170, 10*26 - 22 SAY aMesAno[10]            OF ODLG PIXEL
@ 170, 11*26 - 22 SAY aMesAno[11]            OF ODLG PIXEL
@ 170, 12*26 - 22 SAY aMesAno[12]            OF ODLG PIXEL

@ 177, 01*26 - 17 SAY OBJ10 VAR Transf(SDF->DF_D01,[@E 99,999])     OF ODLG PIXEL  COLOR CLR_HBLUE
@ 177, 02*26 - 17 SAY OBJ11 VAR Transf(SDF->DF_D02,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 03*26 - 17 SAY OBJ12 VAR Transf(SDF->DF_D03,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 04*26 - 17 SAY OBJ13 VAR Transf(SDF->DF_D04,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 05*26 - 17 SAY OBJ14 VAR Transf(SDF->DF_D05,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 06*26 - 17 SAY OBJ15 VAR Transf(SDF->DF_D06,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 07*26 - 17 SAY OBJ16 VAR Transf(SDF->DF_D07,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 08*26 - 17 SAY OBJ17 VAR Transf(SDF->DF_D08,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 09*26 - 17 SAY OBJ18 VAR Transf(SDF->DF_D09,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 10*26 - 17 SAY OBJ19 VAR Transf(SDF->DF_D10,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 11*26 - 17 SAY OBJ20 VAR Transf(SDF->DF_D11,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE
@ 177, 12*26 - 17 SAY OBJ21 VAR Transf(SDF->DF_D12,[@E 99,999])     OF ODLG PIXEL COLOR CLR_HBLUE

@ 187, 004 SAY OBJ05 VAR STR0094 + SBL->BL_CODFORM + "  =  " + cDescForm        OF ODLG PIXEL COLOR CLR_HBLUE

oGetDados := MsGetDados():New(70,1,150,317,nOpcG,cLinOk,cTudoOk,"",IIf(nOpcE==4,.t.,.f.),aAlter,nFreeze,,nLinhas,cFieldOk)
oGetDados:oBrowse:bDrawSelect := {|| OFP010ATt()}
oGetDados:oBrowse:bEditCol    := {|| FS_TRATAQTD() }
oGetDados:oBrowse:bChange     := {|| oGetDados:aAlter := oGetDados:oBrowse:aAlter := IIf( n <= naColsDados , aCpoAlt , aAlter ) }

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,IIf(oGetDados:TudoOk(),IIf(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},AL_InicioEnc()) CENTERED
lRet := (nOpca==1)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Impr		³ Autor ³           			³ Data ³ 16.02.95      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controle de Linhas de Impressao e Cabecalho			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 															  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IMPR(Detalhe,Fimfolha,Pos_cabec)
LOCAL Colunas,nLin:=0, aDriver := LEDriver()
LOCAL X_IMPR,XTMP := 0
Colunas := IIF(nTamanho=="P",80,IIF(nTamanho=="G",220,132))

IF FIMFOLHA = "F"
	@ 61 ,000		 PSAY REPLICATE("*",COLUNAS)
	RETURN Nil
EndIF
IF FIMFOLHA = "P" .OR. LI >= 60
	@ LI,00 PSAY REPLICATE("*",COLUNAS)
	LI := 00
	IF FIMFOLHA = "P"
		RETURN Nil
	EndIF
EndIF
IF LI=00
	IF aReturn[4] == 1  // Comprimido
		@ 0,0 PSAY &(IIf(nTamanho=="P",aDriver[1],IIf(nTamanho=="G",aDriver[5],aDriver[3])))
	Else					  // Normal
		@ 0,0 PSAY &(IIf(nTamanho=="P",aDriver[2],IIf(nTamanho=="G",aDriver[6],aDriver[4])))
	EndIF
	
	@ 00,000 PSAY REPLICATE("*",COLUNAS)
	@ 01,000 PSAY "*" + SM0->m0_Nome
	COL_AUX = IIf(COLUNAS==220,210,COLUNAS)
	WCOL	  = INT((COL_AUX - (LEN(TRIM(TITULO))))/2)
	WPAGINA = SUBSTR(STR(CONTFL+100000,6),2,5)
	IF TYPE("POS_CABEC")= "U"
		@ 01,COLUNAS-20 PSAY STR0053 + WPAGINA + "*" //"Folha:        "
	Else
		@ 01,COLUNAS-26 PSAY "*"
	EndIF
	@ 02,000 PSAY "*" + CHR(83) + CHR(46) + CHR(73) + CHR(46) + CHR(71) + CHR(46) + CHR(65) + CHR(46) + " / "  + AT_PRG
	@ 02,WCOL		 PSAY TRIM(TITULO)
	IF TYPE("POS_CABEC")= "U"
		@ 02,COLUNAS-20 PSAY STR0054 //"DT.Ref.:"
		@ 02,COLUNAS-11 PSAY PADL(dDataBase,10)
		@ 02,COLUNAS-01 PSAY "*"
	Else
		@ 02,COLUNAS-26 PSAY "*"
	EndIF
	@ 03,000 PSAY STR0055 + TIME() //"*Hora...: "
	IF TYPE("POS_CABEC")= "U"
		@ 03,COLUNAS-20 PSAY STR0056 //"Emissao:"
		@ 03,COLUNAS-11 PSAY PADL(DATE(),10)
		@ 03,COLUNAS-01 PSAY "*"
	Else
		@ 03,COLUNAS-26 PSAY "*"
	EndIF
	@ 04,000 PSAY REPLICATE("*",IIF(TYPE("POS_CABEC")="U",COLUNAS,COLUNAS-25))
	IF TYPE("POS_CABEC") # "U"
		@ 05,00 PSAY "*"
		@ 05,COLUNAS-26 PSAY "*"
		LI_WCABEC = 6
	Else
		LI_WCABEC = 5
	EndIF
	IF WCABEC0 == 0
		IF TYPE("POS_CABEC") # "U"
			@ 06,00 PSAY STR0057 + WPAGINA //"*Folha:       "
			@ 06,COLUNAS-26 PSAY "*"
			@ 07,00 PSAY STR0058 //"*DT.Ref.:  "
			@ 07,14 PSAY dDataBase
			@ 07,COLUNAS-26 PSAY "*"
			@ 08,00 PSAY STR0059 //"*Emissao:"
			@ 08,14 PSAY DATE()
			@ 08,COLUNAS-26 PSAY "*"
			@ 09,00 PSAY "*"
			@ 09,COLUNAS-26 PSAY "*"
			LI_WCABEC = 10
		EndIF
		@ LI_WCABEC,000 PSAY REPLICATE("*",COLUNAS)
	EndIF
	IF WCABEC0 # 0
		FOR X_IMPR := 1 TO WCABEC0
			IF TYPE("POS_CABEC") # "U"
				IF X_IMPR == 1
					@ LI_WCABEC,00 PSAY STR0057 + WPAGINA //"*Folha:       "
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				ElseIF X_IMPR == 2
					@ LI_WCABEC,00 PSAY STR0058 //"*DT.Ref.:  "
					@ LI_WCABEC,14 PSAY dDataBase
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				ElseIF X_IMPR == 3
					@ LI_WCABEC,00 PSAY STR0059 //"*Emissao:"
					@ LI_WCABEC,14 PSAY DATE()
					@ LI_WCABEC,COLUNAS-26 PSAY "*"
				EndIF
			EndIF
			AUX_IMPR := "WCABEC" + ALLTRIM(STR(X_IMPR))
			IF X_IMPR <= 3
				@ LI_WCABEC,IIF(TYPE("POS_CABEC")="U",000,025) PSAY &AUX_IMPR
			Else
				@ LI_WCABEC,000 PSAY &AUX_IMPR
			EndIF
			LI_WCABEC := LI_WCABEC + 1
		NEXT
		IF TYPE("POS_CABEC") # "U"
			IF X_IMPR <=3
				FOR XTMP := X_IMPR-1 TO 3
					IF XTMP == 2
						@ LI_WCABEC,00 PSAY STR0058 //"*DT.Ref.:  "
						@ LI_WCABEC,14 PSAY dDataBAse
						@ LI_WCABEC,COLUNAS-26 PSAY "*"
					Else
						@ LI_WCABEC,00 PSAY STR0059 //"*Emissao:"
						@ LI_WCABEC,14 PSAY DATE()
						@ LI_WCABEC,COLUNAS-26 PSAY "*"
					EndIF
					LI_WCABEC := LI_WCABEC + 1
				NEXT
			EndIF
		EndIF
		@ LI_WCABEC,000 PSAY REPLICATE("*",COLUNAS)
	EndIF
	LI 	   := LI_WCABEC+1
	CONTFL := CONTFL+1
	
	__LogPages()
	
EndIF
@ LI,00 PSAY DETALHE
LI = LI+1
RETURN Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LEDriver	³ Autor ³ Tecnologi          	  |Data  ³ 16.02.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Controlar o Tipo de Impressora e Impressao    		    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³LEDriver(Void)										            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Acionada pela Funcao Impr									  		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LEDriver()
Local aSettings := {}
Local cStr, cLine, i

IF !File(__DRIVER)
	aSettings := {"CHR(15)","CHR(18)","CHR(15)","CHR(18)","CHR(15)","CHR(15)"}
Else
	cStr := MemoRead(__DRIVER)
	For i:= 2 to 7
		cLine := AllTrim(MemoLine(cStr,254,i))
		AADD(aSettings,SubStr(cLine,7))
	Next
EndIF
Return aSettings

//
Static Function AL_InicioEnc()
aTela := aClone(aSvATela[1])
aGets := aClone(aSvAGets[1])
dbSelectArea("SFJ")
Return .F.
//
Static Function AL_EntraEnc(nE,cAlias)
aTela := AClone(aSvAtela[nE])
aGets := AClone(aSvaGets[nE])
dbSelectArea(cAlias)
Return

//
Static Function Al_Saienc(nE)
aSvATela[nE]	:= aClone(aTela)
aSvAGets[nE] 	:= aClone(aGets)
Return

Static Function Traz_Marca(cProduto)
Local cMarca := ""
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+cProduto))
SBM->(dbSetOrder(1))
SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
cMarca := SBM->BM_CODMAR
Return cMarca
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³O010FilEnt ³ Autor ³ Valdir F. Silva      ³ Data ³25.08.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verif. existencia da Filial para Entrega do Pedido em SM0. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 010FilEnt(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Codigo da Filial de Entrega                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIPR010                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
STATIC Function O010FilEnt(cFilialEnt)
Local aArea		:= GetArea()
Local lRet 		:= .T.
Local aAreaSM0  := SM0->(GetArea())
If M->FJ_TIPGER == "2"
If !Empty(cFilialEnt).And.Empty(xFilial("SFJ"))
Help(" ",1,"FILENTC")
lRet := .T.
ElseIF Empty(cFilialEnt).And.!Empty(xFilial("SFJ"))
Help(" ",1,"FILENTE")
lRet := .F.
Else
dbSelectArea("SM0")
dbSetOrder(1)
If !dbSeek(SUBS(cNumEmp,1,2)+cFilialEnt)	// Procura pelo Numero da Empresa e Filial para Entrega.
Help(" ",1,"C7_FILENT")
lRet := .F.
EndIf
EndIf
EndIf
RestArea(aAreaSM0)
RestArea(aArea)
Return lRet
*/


//Atualiza a acols
Static Function OFP010ATt()
SDF->(DbSetOrder(1))
SDF->(DbSeek( xFilial("SDF")+SFJ->FJ_CODIGO+aCols[n,ProcH('DF_PRODUTO')]))
//RegToMemory("SDF",.F.)

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xfilial("SB1")+aCols[n,ProcH('DF_PRODUTO')])

SBL->(DbSetOrder(1))  //Filial+Ano+Mes
SBL->(DbSeek(xFilial("SBL")+aCols[n,ProcH('DF_PRODUTO')]+cAnoMes))

Do Case
	Case SBL->BL_CODFORM == [PES]
		cDescForm := "D[m-1]"
	Case SBL->BL_CODFORM == [PME]
		cDescForm := "( D[m-1] + D[m-2] + D[m-3] ) / 3"
	Case SBL->BL_CODFORM == [PTE]
		cDescForm := "D[m-1] + ( D[m-1] - D[m-2] )"
	Case SBL->BL_CODFORM == [PSA]
		cDescForm := " D[m-12] * ( (D[m-1] + D[m-2] + D[m-3]) / (D[m-13] + D[m-14] + D[m-15]) )"
EndCase

oProd:Refresh()
Obj01:refresh()
Obj02:refresh()
Obj03:refresh()
Obj04:refresh()
Obj05:refresh()
Obj06:refresh()
Obj07:refresh()
Obj08:refresh()
Obj09:refresh()
Obj10:refresh()
Obj11:refresh()
Obj12:refresh()
Obj13:refresh()
Obj14:refresh()
Obj15:refresh()
Obj15:refresh()
Obj16:refresh()
Obj17:refresh()
Obj18:refresh()
Obj19:refresh()
Obj20:refresh()
Obj21:refresh()

//oEnc02:EnchRefreshAll()
oEnc01:EnchRefreshAll()

Return
//Valida e atualiza os totais
Function OFP010VLDt()
Local lRet := .T.
Local aSE  := {}
Local nX
For nX:=1 to Len(aCols)
	
	aSE      :=SaldoEst(aCols[nX,ProcH('DF_PRODUTO')])
	
	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+aCols[nX,ProcH('DF_PRODUTO')]))
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aCols[nX,ProcH('DF_PRODUTO')]))
	
	nQtdSug:=aCols[nX,ProcH('DF_QTDSUG')]
	
	If Empty(nQtdSug)
		nQtdSug:=1
	EndIf
	
	IF M->FJ_TIPPRC == "1"
		aCols[nX,ProcH('DF_VLRTOT')] := nQtdSug*SB1->B1_UPRC
	ElseIF M->FJ_TIPPRC == "2"
		aCols[nX,ProcH('DF_VLRTOT')] := nQtdSug*SB5->B5_PRV2
	Else
		aCols[nX,ProcH('DF_VLRTOT')] := nQtdSug*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1")
	EndIF
	
	aCols[nX,ProcH('DF_QE')] := SB1->B1_QE
	
Next
Return lRet

Static Function ProcH(cCampo)
Return aScan(aHeader,{|x|Trim(x[2])== cCampo })

Static Function FS_TRATAQTD()

&& Trata recalculo dos itens
If oGetDados:oBrowse:nColPos == (ProcH('DF_CODGRP') + 1) ;
	.Or. oGetDados:oBrowse:nColPos == (ProcH('DF_CODITE') + 1)
	
	OFP010VLDt()
	
EndIf

&& Trata linha/coluna da quantidade
If oGetDados:oBrowse:nColPos == (ProcH('DF_QTDINF') + 1) ;
	.And. oGetDados:LinhaOk()
	
	If oGetDados:oBrowse:nAt + 1 <= Len(aCols)
		
		n := ( oGetDados:oBrowse:nAt += 1 )
		oGetDados:oBrowse:nColPos  := ProcH('DF_QTDINF')
		
		Eval( oGetDados:oBrowse:bDrawSelect )
		
		oGetDados:oBrowse:Refresh()
		
	EndIf
	
EndIf

Return

Static Function MenuDef()
Local aRotina := 			{{STR0002  ,"AxPesqui",   0 , 1},; //"Pesquisar"
{STR0003  ,"OFP010Vist", 0 , 2},; //"Visualizar"
{STR0067  ,"OFP010Inct", 0 , 3},; //"Incluir"
{STR0068  ,"OFP010Altt", 0 , 4},; //"Efetivar"
{STR0069  ,"OFP010Cant", 0 , 5},; //"Cancelar Efet."
{STR0007  ,"OFP010Impt", 0 , 5},; //"Imprimir"
{STR0008  ,"OFP010Exct", 0 , 5}}  //"Excluir"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³aConsumoSC³ Autor ³ Alex Sandro Valario   ³ Data ³ 14/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumula no Array aConsumo a demanda dos produtos			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ aConsumoSC							 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata295                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function aConsumoSC(cAnoMes)
Local nX,nLen
Local nRecnoSBL :=SBL->(Recno())
Local nOrdemSBL :=SBL->(IndexOrd())
Local cPAnoMes:=""
Local aConsumo :={}
SBL->(DBSetOrder(1))
SBL->(DBSeek(xFilial("SBL")+SB1->B1_COD))
While !SBL->(Eof()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->BL_PRODUTO==SB1->B1_COD .and. SBL->BL_ANO+SBL->BL_MES <= cAnoMes
	Aadd(aConsumo,SBL->BL_DEMANDA)
	cPAnoMes := SBL->(BL_ANO+BL_MES)
	SBL->(DbSkip())
	If ! SBL->(Eof()) .and. SBL->BL_PRODUTO ==SB1->B1_COD
		IF Right(cPAnoMes,2)=="12"
			cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
		Else
			cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
		Endif
		While cPAnoMes < SBL->(BL_ANO+BL_MES)
			Aadd(aConsumo,0 )
			IF Right(cPAnoMes,2)=="12"
				cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
			Else
				cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
			EndIf
		End
	EndIf
End
SBL->(DbSetOrder(nOrdemSBL))
SBL->(DbGoto(nRecnoSBL))
nLen :=len(aConsumo)
If Len(aConsumo) < 120
	For nX := 1 to 120-nLen
		aadd(aConsumo,0)
		aIns(aConsumo,1)
		aConsumo[1] := 0
	Next
EndIf
Return aConsumo