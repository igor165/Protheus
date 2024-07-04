// º Versao º 72     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#include "VEIVM006.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007607_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIVM006 ³ Autor ³ Manoel/Andre          ³ Data ³ 06/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Conhecimento de Frete                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±                   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM006

Private nIndexFRT, cArqVVF
Private cEstFor, cLojFor, nOpcMnu, cChaInt, cChassi, cCodTes, nCusVei, nVBaIcm, nAliIcm, nTotIcm, cNota, cSerie , cFornece 
Private lAbortPrint := .f.
Private lFreteVei   := .f.                 //Variavel p/ saber o Frete e de Veiculo
Private nConFre     := 0
Private nFolAnt     := 1
Private aRotina     := MenuDef()
Private cCadastro   := (STR0001)  //Conhecimento de Frete
Private cFiltrFreS := "VVF_QTDVEI#VVF_FORPRO#VVF_OPEMOV#VVF_DATFAB#VVF_DESACE#VVF_DTHEMI#VVF_CODBCO#VVF_CODAGE#VVF_CODCOM#VVF_TOTSEG#VVF_TOTFRE#VVF_VBAIPI#VVF_ALIIPI#VVF_VALIPI#VVF_CONFRE#VVF_NUMPED#VVF_NUMTRA#VVF_TRACPA"
Private cOpeMov     := "6"                 //Conhecimento de Frete
Private aSTRUNFR    := {{.F.,"","",ctod(""),"","","","","",""}}
Private cBIcm0      := .t.
Private l103Auto    := .t.
Private cGruVei     := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private aIteVei     := {}
Private lA1_IBGE    := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE    := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)
Private nTotEntr    := 0
Private aColsRATCC  := {} // Rateio MATA103X -> MATA116
Private lAltParc    := .f.
Private M->A1_EST   := "" // esta variavel foi criada apenas com o intuito de fazer filtro na tabela CC2, sem a necessidade de criar outra consulta Padrao - Utilizando a CC2SA1 nos campos VVF_MUORIT e VVF_MUDEST

If !AMIIn(11) .or. !FMX_AMIIn({"VEIVM006"})
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a Funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
cArqVVF   := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao :='VVF->VVF_OPEMOV == "6"'
IndRegua("VVF",cArqVVF,"VVF_FILIAL+DtoS(VVF_DATMOV)",,cCondicao,(STR0024))  //Selecionando Registros...

dbSelectArea("VVF")
nIndexFRT := RetIndex("VVF")
#IFNDEF TOP
	dbSetIndex(cArqVVF+OrdBagExt())
#ENDIF
dbSetOrder(nIndexFRT+1)

mBrowse( 6, 1,22,75,"VVF")

RetIndex()

#IfNDEF TOP
	If File(cArqVVF+OrdBagExt())
		fErase(cArqVVF+OrdBagExt())
	EndIf
#ENDIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AFUNC06  ³ Autor ³  Manoel               ³ Data ³ 25/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de Conhecimento de Frete                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFUNC06(cAlias,nReg,nOpc)

Local oFont
Local oDlgFolder, ni
Local cPrimeiro  := ""
Local nRecno     := Recno()
Local nOrdem     := IndexOrd()
Local nControl	 := 0, nOk:=0
Local aPages     := {}
Local aVar       := {}
Local bCampo	 := { |nCPO| Field(nCPO) }
Local nCntFor	 := 0
//
Private lMSHelpAuto := .f.
Private lMSErroAuto := .f.
Private bRefresh    := { || FS_Refresh() }

//Zera as variaveis fiscais
MaFisEnd()

aTitles := {(STR0012),STR0060}//Como Pagar

dbSelectArea("VVF")
nRegVVF := VVF->(Recno())
dbSetOrder(1)
dbGoto(nRegVVF)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VVF")
aCpoFreS  := {}
While !Eof().and.(x3_arquivo=="VVF")
	if X3USO(x3_usado).and.cNivel>=x3_nivel .and. !alltrim(x3_Campo) $ cFiltrFreS
		AADD(acpoFreS,x3_campo)
	Endif
	if Inclui
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 08/12/2009                                                             ³
//³Cria variaveis de memoria para compatibilizacao com a funcao FS_CALPAR (VEIFUNC)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Inclui
	dbSelectArea("SX3")
	dbSetOrder(2)
	if dbSeek("VV0_VALFIN")
		&("M->"+x3_campo) := CriaVar(x3_campo)
	endif
	if dbSeek("VV0_VALTOT")
		&("M->"+x3_campo) := CriaVar(x3_campo)
	endif
endif

M->VVF_CONFRE := nConFre

if !Inclui
	RegToMemory("VVF",.f.)
	dbSelectArea("VVF")
	DbGoto(nRegVVF)
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

Do Case
	Case nOpc == 3 && Incluir
		nOpcE:=3
		nOpcG:=3
	Case nOpc == 2 && Visualizar
		nOpcE:=2
		nOpcG:=2
	Case nOpc == 1 && Pesquisar
		nOpcE:=1
		nOpcG:=1
	Otherwise && Cancelar
		nOpcE:=5
		nOpcG:=5
EndCase

Private oEnc01
Private oFolder
Private nOpcao   := nOpc
Private lOk      :=.F.
Private aSvAtela := {{}}
Private aSvAGets := {{}}
Private aTela    := {}
Private aGets    := {}

//Variaveis p/ a condicao de pagamento geral
Private aColsC   := {}
Private aIteParc := {{cTod(""),0}}
Private cCondic1 := ctod(" ")
Private cCondic2 := space(02)
Private cCondic3 := space(02)
Private cCondic4 := space(02)
Private cCondic5 := "1"
Private cTipOpe  := 4
Private cTipPag1 := "VVF_FORPAG"
Private cCodCDCI := space(3)

nOpca            := 0
cAliasEnchoice   :="VVF"
cAliasGetD       :="VVG"
cLinOk           :="FS_NpLinha(),CheckCols(n,aCols)"
cTudOk           :="FS_TudoOk()"
cFieldOk         :="FG_MEMVAR()"

M->VVF_OPEMOV := cOpeMov

Aadd(aPages,"HEADER 1")
nControl++

if !Inclui
	FS_TRAZNEG("F")
Endif

SETAPILHA()
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM  4,0 To 35,80 OF oMainWnd

oFolder := TFolder():New(1,0,aTitles,aPages,oDlgFolder,,,,.F.,.F.,345,280,)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT
oFolder:aDialogs[1]:oFont := oDlgFolder:oFont
oFolder:bChange    := {|x|  CalculaCond(x)    }       // Executa na mudanca da aba
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice 01	- Cabecalho da NF		                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
dbSelectArea("VVF")
Zero()
oEnc01:= MsMGet():New("VVF" ,nReg ,nOpcao,,,,aCpoFreS,{1,1,208,315},aCpoFreS,2,,,,oFolder:aDialogs[1],,,.F.,"aSvATela[1]")
oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
oEnc01:oBox:bGotFocus   := {|| AL_EntraEnc(1,"VVF")}
oEnc01:oBox:bLostFocus  := {|| AL_SaiEnc(1)}
aSvATela[1] := aClone(aTela)
aSvAGets[1] := aClone(aGets)


nLin := 1
@ nLin, 198 LISTBOX oLbParc FIELDS HEADER  (STR0095),(STR0093);  //data - Valor
COLSIZES 40,50;
SIZE 110,061 OF oFolder:aDialogs[2] PIXEL ON DBLCLICK Iif(lAltParc,FG_ALTFINAN(oLbParc:nAt),.f.)

oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;                   
Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}

@ nLin, 120 BUTTON oObserv PROMPT (STR0015) OF oFolder:aDialogs[2] SIZE 26,11 PIXEL  ACTION FS_FPGAUTO()
@ nLin, 150 BUTTON oObserv PROMPT (STR0016) OF oFolder:aDialogs[2] SIZE 26,11 PIXEL  ACTION FS_APAGAFP(.t.)

@ nLin,005 SAY STR0017 SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ nLin,045 msget oCondic1 VAR cCondic1 Picture "@!"  SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when lAltParc

@ nLin+13,005 SAY STR0018 SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ nLin+21,005 msget oCondic2 VAR cCondic2 Picture "@!"  SIZE 30,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when lAltParc

@ nLin+13,050 SAY STR0019     SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ nLin+21,050 msget oCondic3 VAR cCondic3 Picture "@!"  SIZE 30,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when lAltParc

@ nLin+13,105 SAY STR0020    SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ nLin+21,105 msget oCondic4 VAR cCondic4 Picture "@!"  SIZE 30,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when lAltParc

ACTIVATE MSDIALOG oDlgFolder CENTER ON INIT EnchoiceBar(oDlgFolder,{||Processa( {||nOpca:=1,If(!obrigatorio(aGets,aTela),nOpca := 2,if(FS_GRVFRETE(cAlias, nReg, nOpc),oDlgFolder:End(),nOpca := 2))}," "," ",.t.)},{||nOpca := 2,oDlgFolder:End()},,)
SETAPILHA()

DbSelectArea("VVF")
cArqVVF   := CriaTrab(nil,.f.)
cKey      := IndexKey()
cCondicao :='VVF->VVF_OPEMOV == "6"'
IndRegua("VVF",cArqVVF,"VVF_FILIAL+DtoS(VVF_DATMOV)",,cCondicao,(STR0024))  //Selecionando Registros...

DbSelectArea("VVF")
nIndexFRT := RetIndex("VVF")
#IFNDEF TOP
	DbSetIndex(cArqVVF+OrdBagExt())
#ENDIF
DbSetOrder(nIndexFRT+1)

dbSelectArea("VVF")
dbSetOrder(1)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GRVFRETE³ Autor ³  Manoel              ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao e Integracao de Conhecimentos de Frete             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRVFRETE(cAlias,nReg,nOpc)

Local cRatDesp  := GetMv("MV_RATDESP")
Local cTipFrete := SubStr(cRatDesp,At("FR=",cRatDesp)+3,1)
Local nDif      := 0
Local lRet      := .t.
Local nContd    := nDifFre := nValFreT := 0
Local bCampo    := { |nCPO| Field(nCPO) }
Local lpagvista := .f.
Local aParamBox := {}
Local nFr,nCntFor,ni_,ix_,i_,x_ := 0
Local cVVFTesFre:= ""
Local lMunUFTra := VVF->(FieldPos("VVF_MUDEST")) > 0
Local lVeiBloq  := .f.
Local oVeiculos := DMS_Veiculo():New()

Private aMemos  := {{"VVF_OBSMEM","VVF_OBSERV"}}
Private cParDup

//Valida campos obrigatorios
if Empty(M->VVF_NUMNFI)
	MsgInfo(STR0061,STR0009) //Numero da NOTA FISCAL nao informado! - Atencao
	Return .f.
Endif

if Empty(M->VVF_TESFRE)
	MsgInfo(STR0062 ,STR0009) //Numero do TES nao informado! - Atencao
	Return .f.
Endif

if nOpc == 3 // Inclusao do Frete
	If !FS_VLDCHVNFE(If(M->VVF_FORPRO == "0","N","S"),M->VVF_ESPECI,M->VVF_CHVNFE) // Validação da Chave NF em branco ( MV_DCHVNFE = .t. )
		Return .f.
	EndIf
EndIF

ProcRegua(2)

if FS_NFSREL(nOpc)
	
	Begin  Transaction
	
	if nOpc == 2
		DisarmTransaction()
		Break
	Endif
	
	dbSelectArea("SF1")
	Set Filter To
	RetIndex()
	
	dbSelectArea("VVF")
	Set Filter To
	RetIndex()
	
	if nOpc == 5 // Cancelamento do Frete
		
		FS_CANFRETE()
		
	Else
		nQtd := 0
		aIteVei := {}
		For nFr := 1 to Len(aStruNFR)
			if aStruNFR[nFR,1]
				aVetor := FS_SELVEI(aStruNFR[nFr,8],aStruNFR[nFr,3],aStruNFR[nFr,2],substr(aStruNFR[nFr,5],1,TamSX3("A1_COD")[1]),substr(aStruNFR[nFr,5],TamSX3("A1_COD")[1]+1,TamSX3("A1_LOJA")[1]))
				nQtd++

				// Chassi Bloqueado
				If oVeiculos:Bloqueado("", aStruNFR[nFr,8])
					lVeiBloq := .t. // A mensagem já é exibida dentro da função Bloqueado()
				EndIf
			Endif
		Next
		if nQtd == 0 .Or. lVeiBloq
			DisarmTransaction()
			Break
		Else
			aRetorn := FS_SELVEI1()
			if Len(aRetorn) == 0
				DisarmTransaction()
				Break
			Endif
		Endif
		
		if Empty(aIteParc[1,1]) .or. Empty(aIteParc[1,2])
			FS_FPGAUTO()
		Endif

		IncProc(STR0007) //"Gerando NF de Conhecimento de Frete..."
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao do VVF                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lConFre := .t.
		dbSelectArea("VVF")
		If Inclui
			M->VVF_TRACPA := GetSxENum("VVF","VVF_TRACPA")
			ConfirmSx8()
		Else
			M->VVF_TRACPA := VVF->VVF_TRACPA
		EndIf
		RecLock("VVF",IIf(Inclui,.t.,.f.))
		FG_GRAVAR("VVF")
		VVF->VVF_FILIAL := xFilial("VVF")
		VVF->VVF_SITNFI := "1" && Valida
		VVF->VVF_OPEMOV := cOpeMov
		VVF->VVF_NUMPED := ""
		VVF->VVF_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
		VVF->VVF_CONFRE := 0 
		//
		aMemos   := {{"VVF_OBSMEM","VVF_OBSERV"}}
		MSMM(,TamSx3("VVF_OBSERV")[1],,&(aMemos[1][2]),1,,,"VVF","VVF_OBSMEM")
		aMemos   := {{"VVF_OBSMNF","VVF_OBSENF"}}
		MSMM(,TamSx3("VVF_OBSENF")[1],,&("VVF_OBSENF"),1,,,"VVF","VVF_OBSMNF")
		//
		MsUnlock()
		
		nRecFre    := VVF->(Recno())
		nConFre    := VVF->VVF_VALMOV
		nIcmFre    := VVF->VVF_TOTICM
		nTraCpaFre := VVF->VVF_TRACPA
		aItensNFR  := {}

		aPerRat := {}
		aPesoVVG := {}
		VV1->(DbSetOrder(2))
		For nFr := 1 to Len(aStruNFR)
			if aStruNFR[nFr,1]
				// Parametro 1 = Numero da Transacao
				// Parametro 2 = Valor VCNVEI ou Peso 
				// Parametro 3 = Valor Proporcional para o Rateio					
				// Parametro 4 = Chassi Interno
				VV1->(DbSeek(xFilial("VV1")+aStruNFR[nFr,8]))
				if cTipFrete == "1"  // rateio por valor
					aadd(aPerRat,{aStruNFR[nFr,7],0,0,VV1->VV1_CHAINT})
					DbSelectArea("VVG")
					DbSetOrder(1)
					if DbSeek(xFilial("VVG")+aStruNFR[nFr,7]+VV1->VV1_CHAINT)
						while !Eof() .and. VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_TRACPA == aStruNFR[nFr,7] .and. VVG->VVG_CHAINT == VV1->VV1_CHAINT
							aPerRat[len(aPerRat),2] += VVG->VVG_VCNVEI
							aadd(aPesoVVG,{aStruNFR[nFr,7],VV1->VV1_CHAINT,VVG->VVG_VCNVEI})
							VVG->(DbSkip())
						Enddo
					Endif
				Elseif cTipFrete == "2"  // rateio por peso
					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
					aadd(aPerRat ,{aStruNFR[nFr,7],SB1->B1_PESBRU,0,VV1->VV1_CHAINT})
					aadd(aPesoVVG,{aStruNFR[nFr,7],VV1->VV1_CHAINT,SB1->B1_PESBRU})
				Endif
			Endif
		Next
		DbSelectArea("SB1")
		DbSetOrder(1)
		
		nPesoTotal := 0
		For ni_ := 1 to Len(aPerRat)
			nPesoTotal += aPerRat[ni_,2]
		Next			
		For ni_ := 1 to Len(aPerRat)
			aPerRat[ni_,3] := (nConFre * ((aPerRat[ni_,2] / nPesoTotal) * 100)) / 100
		Next
		
		For ix_ := 1 to Len(aPerRat)
			
			cSeekNFr := aPerRat[ix_,1]

			DbSelectArea("VVF")
			DbSetOrder(1)
			DbSeek(xFilial("VVF")+cSeekNfr)

			aAdd(aItensNFR,{{"AUTNOTA",VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA,nil}})

			DbSelectArea("VVF")
			RecLock("VVF",.f.)
			VVF->VVF_NUMTRA := nTraCpaFre
			MsUnlock()
		Next
		
		DbSelectArea("VVF")
		DbGoto(nRecFre)
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next
		
		cCodForMer := VVF->VVF_CODFOR
		cLojForMer := VVF->VVF_LOJA
		
		If lConFre
			
			IncProc(STR0007) //"Gerando NF de Conhecimento de Frete..."
			If lAbortPrint
				If MsgYesNo((STR0008),(STR0009)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
					Help("  ",1,"M160PROABO")
					lRet := .f.
					DisarmTransaction()
					Break
				Else
					lAbortPrint := .F.
				EndIf
			EndIf
			
			DbSelectArea("VVF")
			DbGoto(nRecFre)
			For nCntFor := 1 TO FCount()
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Next
			cNumtra := VVF_TRACPA
			nConFre := VVF_VALMOV - VVF_TOTICM

			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			if lA2_IBGE .and. !Empty(SA2->A2_IBGE)
				DbSelectArea("VAM")
				DbSetOrder(1)
				DbSeek(xFilial("VAM")+SA2->A2_IBGE)
			endif
			
			DbSelectArea("VVF")
			//Cria Vetor do Cabecalho da NF para o MATA116 (Conhecimento de Frete)
			aCabNFR := {}
			aAdd(aCabNFR,{"MV_PAR11"  ,dDataBase-99999,nil})
			aAdd(aCabNFR,{"MV_PAR12"  ,dDataBase    ,nil})
			aAdd(aCabNFR,{"MV_PAR13"  ,2            ,nil})
			aAdd(aCabNFR,{"MV_PAR14"  ,"      "     ,nil})
			aAdd(aCabNFR,{"MV_PAR15"  ,"  "         ,nil})
			aAdd(aCabNFR,{"MV_PAR16"  ,1            ,nil})
			aAdd(aCabNFR,{"MV_PAR17"  ,2            ,nil})
			if lA2_IBGE .and. !Empty(SA2->A2_IBGE) .and. !Empty(VAM->VAM_ESTADO)
				aAdd(aCabNFR,{"MV_PAR18"  ,VAM->VAM_ESTADO,nil})
			else
				aAdd(aCabNFR,{"MV_PAR18"  ,SA2->A2_EST,nil})
			endif
			aAdd(aCabNFR,{"MV_PAR21"  ,VVF_VALMOV   ,nil})
			aAdd(aCabNFR,{"MV_PAR22"  ,1            ,nil}) // Formulario Proprio 2=Sim 1=Nao
			aAdd(aCabNFR,{"MV_PAR23"  ,VVF_NUMNFI   ,nil})
			aAdd(aCabNFR,{"MV_PAR24"  ,VVF_SERNFI   ,nil})
			aAdd(aCabNFR,{"MV_PAR25"  ,VVF_CODFOR   ,nil})
			aAdd(aCabNFR,{"MV_PAR26"  ,VVF_LOJA     ,nil})
			aAdd(aCabNFR,{"MV_PAR27"  ,aretorn[1,7] ,nil})
			aAdd(aCabNFR,{"MV_PAR28"  ,if(VVF_ICMRET>0,VVF_VBAICM,0),nil})
			aAdd(aCabNFR,{"MV_PAR29"  ,VVF_ICMRET   ,nil})
			aAdd(aCabNFR,{"MV_PAR31"  ,RetCondVei() ,nil})
			aAdd(aCabNFR,{"Emissao"   ,VVF_DATEMI   ,nil})
			aAdd(aCabNFR,{"F1_ESPECIE",VVF_ESPECI   ,nil})
			aAdd(aCabNFR,{"E2_NATUREZ",VVF_NATURE,   nil})
			aAdd(aCabNFR,{"F1_CHVNFE" ,VVF_CHVNFE   ,nil})			
			If lMunUFTra
				aAdd(aCabNFR,{"F1_UFORITR",VVF_UFORIT   ,nil})			
				aAdd(aCabNFR,{"F1_MUORITR",VVF_MUORIT   ,nil})			
				aAdd(aCabNFR,{"F1_UFDESTR",VVF_UFDEST   ,nil})			
				aAdd(aCabNFR,{"F1_MUDESTR",VVF_MUDEST   ,nil})			
			Endif
			//
			nAnt := MAFISSAVE()
			MAFISEND()
			lMSHelpAuto := .t.
			lMSErroAuto := .f.
			MsExecAuto({|x,y,z,w,r| MATA116(x,y,z,w,r)},aCabNFR,aItensNFR,,,aColsRATCC)
			if lMsErroAuto
				DisarmTransaction()
				Break
			Endif
			MAFISRESTORE(nAnt)

			nRecFre    := VVF->(Recno())

			DbselectArea("VVF")
			DbSetOrder(1)
			
			DbselectArea("VVG")
			DbSetOrder(1)
			
			DbSelectArea("SB1")
			DbSetOrder(7)
			
			dbSelectArea("SD1")
			dbSetOrder(1)

			For ix_ := 1 to Len(aPerRat)
			
				cSeekNFr := aPerRat[ix_,1]

				VVF->(DbSeek(xFilial("VVF")+cSeekNfr))
				VVG->(DbSeek(xFilial("VVG")+VVF->VVF_TRACPA))

				nValorFre := 0
				
				While VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !VVG->(Eof())

					SB1->(DbSeek(xFilial("SB1")+cGruVei+VVG->VVG_CHAINT))
					SD1->(dbSeek(xfilial("SD1")+M->VVF_NUMNFI+M->VVF_SERNFI+M->VVF_CODFOR+M->VVF_LOJA+SB1->B1_COD))

					DbSelectArea("VVG")
					RecLock("VVG",.f.)
					VVG->VVG_VALFRE := SD1->D1_TOTAL
					MsUnlock()
					
					nValorFre += VVG->VVG_VALFRE
					
					VVG->(DbSkip())
				Enddo

				DbSelectArea("VVF")
				RecLock("VVF",.f.)
				VVF->VVF_CONFRE := nValorFre
				MsUnlock()
			Next

			VVF->(DbGoto(nRecFre))
			cVVFTesFre := VVF->VVF_TESFRE //Salva o VVF_TESFRE para ser usado no posicionamento no SF4.

			For x_:=1 to Len(aStruNFR)
				
				if !aStruNfr[x_,1]
					Loop
				Endif
				
				//Posicionamento p/ calcular o Custo do Veiculo
				VVF->(dbSetOrder(1))
				VVF->(dbSeek(xFilial("VVF")+aStruNfr[x_,7] ))
				VVG->(dbSetOrder(1))
				VVG->(dbSeek(xFilial("VVG")+VVF->VVF_TRACPA))
				
				dbSelectArea("VVF")
				While VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !Eof()
					
					VV1->(dbSeek(xFilial("VV1")+VVG->VVG_CHAINT))
					VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
					VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))

					DbSelectArea("SB1")
					DbSetOrder(7)
					DbSeek(xFilial("SB1")+cGruVei+VVG->VVG_CHAINT)

					dbSelectArea("VVF")
					For nCntFor := 1 TO FCount()
						M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
					Next
					
					dbSelectArea("VVG")
					For nCntFor := 1 TO FCount()
						M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
					Next
					
					nCustoVeiculo := 0
					if VVG->VVG_ESTVEI == "0" //Novo
						DbSelectArea("VVG")
						If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
							nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
						ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
							nCustoVeiculo := FG_FORMULA(VE4->VE4_FORCTB)
						Endif
					Else
						cFor := GetMv("MV_VUCCTB")
						if !Empty(cFor)
							nCustoVeiculo := FG_FORMULA(cFor)
						Endif
					Endif

					if nCustoVeiculo == Nil .or. nCustoVeiculo <= 0
						dbSelectArea("SD1")
						dbSetOrder(1)
						If dbSeek(xfilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
							nCustoVeiculo := SD1->D1_CUSTO
						EndIf
					Endif
					
					dbSelectArea("VVG")
					RecLock("VVG",.f.)
					VVG->VVG_VCNVEI := nCustoVeiculo
					MsUnlock()

					dbSelectArea("VVG")
					dbSkip()
					
				Enddo
				
			Next
			
			//Frete
			VVF->(dbSetOrder(1))
			VVF->(dbSeek(xFilial("VVF")+nTraCpaFre))
			dbSelectArea("VVF")
			For nCntFor := 1 TO FCount()
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Next
		
			DbSelectArea("SF1")
			dbclearfilter()
			DbSetOrder(1)
			if DbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
				if VVF->(FieldPos("VVF_RECSF1")) > 0
					dbSelectArea("VVF")
					RecLock("VVF",.f.)
					VVF->VVF_RECSF1 := SF1->(Recno())
            	    MsUnlock()
				Endif
				dbSelectArea("SF1")
				RecLock("SF1",.f.)
				SF1->F1_DOC    := M->VVF_NUMNFI
				SF1->F1_SERIE  := M->VVF_SERNFI
				if FieldPos("F1_SDOC") > 0
					SF1->F1_SDOC := M->VVF_SDOC
				EndIf
				SF1->F1_COND   := M->VVF_FORPAG
				SF1->F1_CHVNFE := M->VVF_CHVNFE
				SF1->F1_DUPL   := M->VVF_NUMNFI
				If VVF->(FieldPos("VVF_PLIQUI")) > 0
					SF1->F1_PLIQUI := M->VVF_PLIQUI
					SF1->F1_PBRUTO := M->VVF_PBRUTO
				Endif
				if VVF->(FieldPos("VVF_TRANSP")) > 0
					if !Empty(VVF->VVF_TRANSP)
						SF1->F1_TRANSP := M->VVF_TRANSP
					Endif
				Endif
				if VVF->(FieldPos("VVF_ESPEC1")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_ESPECI1 := M->VVF_ESPEC1
					Endif
				Endif
				if VVF->(FieldPos("VVF_VOLUM1")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_VOLUME1 := M->VVF_VOLUM1
					Endif
				Endif
				if VVF->(FieldPos("VVF_ESPEC2")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_ESPECI2 := M->VVF_ESPEC2
					Endif
				Endif
				if VVF->(FieldPos("VVF_VOLUM2")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_VOLUME2 := M->VVF_VOLUM2
					Endif
				Endif
				if VVF->(FieldPos("VVF_ESPEC3")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_ESPECI3 := M->VVF_ESPEC3
					Endif
				Endif
				if VVF->(FieldPos("VVF_VOLUM3")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_VOLUME3 := M->VVF_VOLUM3
					Endif
				Endif
				if VVF->(FieldPos("VVF_ESPEC4")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_ESPECI4 := M->VVF_ESPEC4
					Endif
				Endif
				if VVF->(FieldPos("VVF_VOLUM4")) > 0
					if !Empty(VVF->VVF_ESPEC1)
						SF1->F1_VOLUME4 := M->VVF_VOLUM4
					Endif
				Endif
				MsUnlock()
			Endif
			
			//Gravacao das parcelas do ComoPagar
			FS_GRAVANEG("F")
			
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+M->VVF_CODFOR+M->VVF_LOJA)
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+M->VVF_TESFRE)
			
			If SF4->F4_DUPLIC == "S"
				For i_ := 1 to Len(aIteParc)
					aVetDesp := {}
					aAdd(aVetDesp,{"E2_PREFIXO", M->VVF_SERNFI                    , Nil})
					aAdd(aVetDesp,{"E2_NUM"    , M->VVF_NUMNFI                    , Nil})
					aAdd(aVetDesp,{"E2_TIPO"   , PadR("DP", TamSX3("E2_TIPO")[1]) , Nil})
					aAdd(aVetDesp,{"E2_NATUREZ", M->VVF_NATURE                    , Nil})
					aAdd(aVetDesp,{"E2_PARCELA", PadR(i_, TamSX3("E2_PARCELA")[1]), Nil})
					aAdd(aVetDesp,{"E2_FORNECE", M->VVF_CODFOR                    , Nil})
					aAdd(aVetDesp,{"E2_LOJA"   , M->VVF_LOJA                      , Nil})
					aAdd(aVetDesp,{"E2_EMISSAO", dDataBase                        , Nil})
					aAdd(aVetDesp,{"E2_VENCTO" , aIteParc[i_, 1]                  , Nil})
					aAdd(aVetDesp,{"E2_VALOR"  , aIteParc[i_, 2]                  , Nil})
					aAdd(aVetDesp,{"E2_VLCRUZ" , aIteParc[i_, 2]                  , Nil})
					pergunte("FIN050",.F.)
					lMsHelpAuto := .t.
					lMsErroAuto := .f.
					MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
					if lMsErroAuto
						DisarmTransaction()
						Break
					Endif
				Next
			Endif
			
		Endif
		
	Endif
	
	End Transaction
	
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	if !lMsErroAuto
		If ExistBlock("VM006DNF")
			ExecBlock("VM006DNF",.f.,.f.)
		EndIf
	Endif
	
Else
	
	MsgInfo(STR0025,STR0023)
	
	lRet := .f.
	
Endif

Altera := .t.

if lMsErroAuto
	MostraErro()
	lRet := .f.
Endif

MAFISEND()

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_NFSREL     ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Seleciona NF's relacionadas ao Conhecimento de Frete via ListBox³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_NFSREL(nOpc)

Local lRetur     := .t.
Local ix         := 0
Local aIndVVF    := {}
Local cAliasVVF  := "VVFTemp"
Local cQuery     := ""
Local aComboPesq := {}
Local cComboPesq := ""
Local nSavReg    := Recno()
Local aNewBot    := {}
Local cRatDesp   := GetMv("MV_RATDESP")
Local cTipFrete  := SubStr(cRatDesp,At("FR=",cRatDesp)+3,1)

////////////
aAdd(aNewBot,{"S4WB013N",{|| FS_RATEIO() }, STR0163 }) // Rateio por Centro de Custo
////////////

if nOpc <> 3
	#IFDEF TOP
		If Select(cAliasVVF) > 0
			dbSelectArea(cAliasVVF)
			dbCloseArea()
		EndIf
		
		nNUMTRA := len(VVF->VVF_NUMTRA)
		cQuery := "SELECT VVF.VVF_FILIAL , VVF.VVF_NUMTRA , VVF.VVF_SITNFI , VVF.VVF_DATMOV , VVF.VVF_SERNFI , VVF.VVF_NUMNFI , VVF.VVF_CODFOR , VVF.VVF_LOJA , VVF.VVF_TRACPA  , VVF.VVF_OPEMOV  FROM "+RetSqlName("VVF")+" VVF  WHERE "
		cQuery += "VVF.VVF_NUMTRA='"+space(nNUMTRA)+"' AND VVF.VVF_SITNFI='1' AND VVF.VVF_DATMOV ='"+dtos(M->VVF_DATMOV)+"' AND VVF.VVF_NUMNFI = '"+M->VVF_NUMNFI+"' AND VVF.VVF_SERNFI LIKE '"+M->VVF_SERNFI+"%' AND VVF.D_E_L_E_T_ = ' '"
				
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVVF,.T.,.T.)
	#ENDIF
	aStruNFR := {}
	aSTRUNFR    := {{.F.,"","",ctod(""),"","","","","",""}}
	
	cTraCpa := M->VVF_TRACPA
	dbSelectArea(cAliasVVF)
	While !Eof() .and. (cAliasVVF)->VVF_FILIAL == xFilial("VVF") .and. (cAliasVVF)->VVF_TRACPA == cTraCpa
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+(cAliasVVF)->VVF_CODFOR+(cAliasVVF)->VVF_LOJA)
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+(cAliasVVF)->VVF_TRACPA)
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+VVG->VVG_CHAINT)
		Do Case
			Case (cAliasVVF)->VVF_OPEMOV == "0"
				cOpeMovT := STR0063 //Normal
			Case (cAliasVVF)->VVF_OPEMOV == "1"
				cOpeMovT := STR0064 //Ped.Fabrica
			Case (cAliasVVF)->VVF_OPEMOV == "2"
				cOpeMovT := STR0065 //Remessa
			Case (cAliasVVF)->VVF_OPEMOV == "3"
				cOpeMovT := STR0066 //Transferencia
			Case (cAliasVVF)->VVF_OPEMOV == "4"
				cOpeMovT := STR0067 //Consignacao
			Case (cAliasVVF)->VVF_OPEMOV == "5"
				cOpeMovT := STR0068 //Devolucao
			Case (cAliasVVF)->VVF_OPEMOV == "6"
				cOpeMovT := STR0069 //Frete
			Case (cAliasVVF)->VVF_OPEMOV == "7"
				cOpeMovT := STR0070 //Retorno de Remessa
			Case (cAliasVVF)->VVF_OPEMOV == "8"
				cOpeMovT := STR0071 //Retorno de Consignacao
		EndCase		
		if Len(aStruNFR) == 1 .and. Empty(aStruNFR[1,3])
			aStruNFR := {}
		Endif
		aAdd(aStruNFR,{ .t.,(cAliasVVF)->VVF_SERNFI,(cAliasVVF)->VVF_NUMNFI,StoD((cAliasVVF)->VVF_DATMOV),(cAliasVVF)->VVF_CODFOR+(cAliasVVF)->VVF_LOJA,SA2->A2_NOME,(cAliasVVF)->VVF_TRACPA,VV1->VV1_CHASSI,cOpeMovT})
		dbSelectArea(cAliasVVF)
		DbSkip()
	Enddo
Else
	#IFDEF TOP
		If Select(cAliasVVF) > 0
			dbSelectArea(cAliasVVF)
			dbCloseArea()
		EndIf
		
		nNUMTRA := len(VVF->VVF_NUMTRA)
		cQuery := "SELECT VVF.VVF_FILIAL , VVF.VVF_NUMTRA , VVF.VVF_SITNFI , VVF.VVF_DATMOV , VVF.VVF_SERNFI , VVF.VVF_NUMNFI , VVF.VVF_CODFOR , VVF.VVF_LOJA , VVF.VVF_TRACPA  , VVF.VVF_OPEMOV , VV1.VV1_CHASSI "
		cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
		cQuery += "JOIN "+RetSqlName("VVG")+" VVG ON VVG.VVG_FILIAL = '"+xFilial("VVG")+ "' AND VVG.VVG_CHAINT = VV1.VV1_CHAINT AND VVG.D_E_L_E_T_ = ' ' "
		cQuery += "JOIN "+RetSqlName("VVF")+" VVF ON VVF.VVF_FILIAL = '"+xFilial("VVF")+ "' AND VVF.VVF_NUMTRA = '"+space(nNUMTRA)+"' AND VVF.VVF_SITNFI = '1' AND VVF.VVF_DATMOV <= '"+dtos(M->VVF_DATMOV)+"' AND VVF.VVF_OPEMOV <> '6' AND VVF.VVF_TRACPA = VVG.VVG_TRACPA AND VVF.D_E_L_E_T_ = ' ' "
		cQuery += "JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL = '"+xFilial("SF1")+ "' AND SF1.F1_DOC = VVF.VVF_NUMNFI AND SF1.F1_SERIE = VVF.VVF_SERNFI AND SF1.F1_FORNECE = VVF.VVF_CODFOR AND SF1.F1_LOJA = VVF.VVF_LOJA AND SF1.F1_TIPO = 'N' AND SF1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE VV1.VV1_SITVEI = '0' "
		cQuery += "AND VV1.VV1_FILIAL = '"+xFilial("VV1")+ "' "
		cQuery += "AND VV1.D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVVF,.T.,.T.)
	#ENDIF
	aStruNFR := {}
	aSTRUNFR    := {{.F.,"","",ctod(""),"","","","","",""}}
	dbSelectArea(cAliasVVF)
	While !Eof() .and. !(cAliasVVF)->(EOF())
		Do Case
			Case (cAliasVVF)->VVF_OPEMOV == "0"
				cOpeMovT := STR0063 //Normal
			Case (cAliasVVF)->VVF_OPEMOV == "1"
				cOpeMovT := STR0064 //Ped.Fabrica
			Case (cAliasVVF)->VVF_OPEMOV == "2"
				cOpeMovT := STR0065 //Remessa
			Case (cAliasVVF)->VVF_OPEMOV == "3"
				cOpeMovT := STR0066 //Transferencia
			Case (cAliasVVF)->VVF_OPEMOV == "4"
				cOpeMovT := STR0067 //Consignacao
			Case (cAliasVVF)->VVF_OPEMOV == "5"
				cOpeMovT := STR0068 //Devolucao
			Case (cAliasVVF)->VVF_OPEMOV == "6"
				cOpeMovT := STR0069 //Frete
			Case (cAliasVVF)->VVF_OPEMOV == "7"
				cOpeMovT := STR0070 //Retorno de Remessa
			Case (cAliasVVF)->VVF_OPEMOV == "8"
				cOpeMovT := STR0071 //Retorno de Consignacao
		EndCase
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+(cAliasVVF)->VVF_CODFOR+(cAliasVVF)->VVF_LOJA)
		aAdd(aStruNFR,{ .f.,(cAliasVVF)->VVF_SERNFI,(cAliasVVF)->VVF_NUMNFI,StoD((cAliasVVF)->VVF_DATMOV),(cAliasVVF)->VVF_CODFOR+(cAliasVVF)->VVF_LOJA,SA2->A2_NOME,(cAliasVVF)->VVF_TRACPA,(cAliasVVF)->VV1_CHASSI,cOpeMovT})
		dbSelectArea(cAliasVVF)
		DbSkip()
	Enddo
Endif

if Len(aStruNFR) == 0
	aAdd(aStruNFR,{ .f.,space(3),space(9),ctod(""),space(8),space(20),Space(6),space(27),space(2)})
Endif

DbGoto(nSavReg)

Private oLbox
Private oOk    := LoadBitmap( GetResources(), "LBOK" )
Private oNo    := LoadBitmap( GetResources(), "LBNO" )
Private oTik   := LoadBitmap( GetResources(), "LBTIK" )
Private cCPesq := space(30)

aadd(aComboPesq,STR0072)	//NF + Serie
aadd(aComboPesq,STR0073)	//Cod. Fornecedor + Loja
aadd(aComboPesq,STR0074)	//Chassi Veiculo
cComboPesq := STR0072	//NF + Serie
aSort(aStruNFR,1,,{|x,y| x[3]+x[2] < y[3]+y[2] })

if Len(aStruNFR) == 0
	return .f.
endif

DEFINE MSDIALOG oDlg TITLE (STR0059) FROM  00,05 TO 31,69 OF oMainWnd

@ 017,006 SAY STR0076 SIZE 30,08 OF oDlg PIXEL COLOR CLR_BLUE //Tipo:
@ 017,130 SAY STR0077 SIZE 30,08 OF oDlg PIXEL COLOR CLR_BLUE //Pesquisa:
@ 016,160 MSGET oCPesq VAR cCPesq VALID FS_COMBOPESQ(cComboPesq) PICTURE "@!" SIZE 75,06 OF oDlg PIXEL COLOR CLR_BLACK
@ 016,022 MSCOMBOBOX oComboPesq VAR cComboPesq VALID FS_COMBOPESQ(cComboPesq) SIZE 75,50 COLOR CLR_BLACK ITEMS aComboPesq OF oDlg PIXEL

@ 30,01 LISTBOX oLbox FIELDS HEADER   (""),; // Indicador de Relacionamento
(STR0078),;	//Serie
(STR0079),;	//Numero
(STR0080),;	//Chassi
(STR0056),;
(STR0057),;
(STR0058),;
(STR0081);		//Oper.do Movimento
COLSIZES 10,20,40,45,30,40,100,100;
SIZE 252,202 OF oDlg PIXEL ON DBLCLICK (if(nOpc ==3,(nPos:=oLbox:nAt,FS_FilLB000(cTipFrete),oLbox:Refresh(),oLbox:nAt:=nPos),.t.))

oLbox:SetArray(aStruNFR)
oLbox:bLine := { || { IIf(!aStruNFR[oLbox:nAt,01],oNo,oTik),;
FGX_UFSNF(aStruNFR[oLbox:nAt,02]),;
aStruNFR[oLbox:nAt,03],;
aStruNFR[oLbox:nAt,08],;
dtoc(aStruNFR[oLbox:nAt,04]),;
left(aStruNFR[oLbox:nAt,05],6)+"-"+right(aStruNFR[oLbox:nAt,05],2),;
aStruNFR[oLbox:nAt,06],;
aStruNFR[oLbox:nAt,09] } }
nOpca := 0

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 2,oDlg:End()},,aNewBot)

If nOpca == 1
	lRetur := .t.
	if Len(aStruNFR) == 0
		lRetur := .f.
	Endif
	lOk := .f.
	For ix:=1 to Len(aStruNFR)
		if aStruNfr[ix,1]
			lOk := .t.
		Endif
	Next
	if !lOk
		lReturn := .f.
	Endif
Else
	aStruNFR := {}
	lRetur := .f.
Endif

dbSelectArea("VVF")

Return(lRetur)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_COMBOPESQ  ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pesquisa no combo												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMBOPESQ(cCombo)
Local ni := 0
Local lOk := .f.
If cCombo == STR0072 //NF + Serie
	aSort(aStruNFR,1,,{|x,y| x[3]+x[2] < y[3]+y[2] })
ElseIf cCombo == STR0073 //"Cod. Fornecedor + Loja
	aSort(aStruNFR,1,,{|x,y| x[5]+x[3]+x[2] < y[5]+y[3]+y[2] })
Else // "Chassi Veiculo"
	FG_POSVEI("cCPesq",)
	oCPesq:Refresh()
	dbSelectArea("VVF")
	aSort(aStruNFR,1,,{|x,y| x[8]+x[3]+x[2] < y[8]+y[3]+y[2] })
EndIf
For ni := 1 to len(aStruNFR)
	If cCombo == STR0072 //NF + Serie
		If Alltrim(cCPesq) == left(Alltrim(aStruNFR[ni,3]+aStruNFR[ni,2]),len(Alltrim(cCPesq)))
			lOk := .t.
			oLbox:nAt := ni
			Exit
		EndIf
	ElseIf cCombo == STR0073 //"Cod. Fornecedor + Loja
		If Alltrim(cCPesq) == left(Alltrim(aStruNFR[ni,5]),len(Alltrim(cCPesq)))
			lOk := .t.
			oLbox:nAt := ni
			Exit
		EndIf
	Else // "Chassi Veiculo"
		If Alltrim(cCPesq) == left(Alltrim(aStruNFR[ni,8]),len(Alltrim(cCPesq)))
			lOk := .t.
			oLbox:nAt := ni
			Exit
		EndIf
	EndIf
Next
If !lOk
	oLbox:nAt := 1
	MsgAlert(STR0082 ,STR0009) //Pesquisa nao encontrada! - Atencao
EndIf
oLbox:SetFocus()
oLbox:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AL_EntraEnc   ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Clona arrays   												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AL_EntraEnc(nE,cAlias)
aTela := AClone(aSvAtela[nE])
aGets := AClone(aSvaGets[nE])
dbSelectArea(cAlias)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Al_Saienc     ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Clona arrays   												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Al_Saienc(nE)
aSvATela[nE] := aClone(aTela)
aSvAGets[nE] := aClone(aGets)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_FilLB000   ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca no ListBox as NF's Relacionadas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FilLB000(cTipFrete)
Local lOk := .t.
If cTipFrete == "2"  // rateio por peso
	VV1->(DbSetOrder(2))
	If VV1->(DbSeek(xFilial("VV1")+aStruNFR[oLbox:nAt,8]))
		SB1->(DbSetOrder(7))
		If SB1->(DbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)) .and. SB1->B1_PESBRU <= 0
			If VV1->VV1_PESBRU <= 0
				MsgStop("Veiculo sem Peso Bruto cadastrado. Impossivel continuar.","Atenção")
				lOk := .f.
			Else
				DbSelectArea("SB1")
				RecLock("SB1",.f.)
					SB1->B1_PESBRU := VV1->VV1_PESBRU
					If SB1->B1_PESO <= 0 .and. VV1->VV1_PESLIQ > 0
						SB1->B1_PESO := VV1->VV1_PESLIQ
					EndIf
				MsUnLock()
			EndIf
		EndIf
	EndIf
EndIf
If lOk
	aStruNFR[oLbox:nAt,1] := !aStruNFR[oLbox:nAt,1]
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalculaCond   ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula na forma de pagamento  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalculaCond(nAba)

if nAba == 2
	lAltParc := .f.
	dbSelectArea("SF4")
	dbSetOrder(1)
	If dbSeek(xFilial("SF4")+M->VVF_TESFRE)
		If SF4->F4_DUPLIC == "S"
			lAltParc := .t.
		Endif
		oFolder:refresh()
	Endif
	if !Empty(M->VVF_FORPAG)
		FS_FPGAUTO()
	Endif
Endif

Return(.t.)

//////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AFunFrt       ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula na forma de pagamento  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AFunFrt()

AxPesqui()

DbSelectArea("VVF")

Return


////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_TESFRE     ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gravacao dos totais           								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TESFRE()

if SF4->F4_ICM == "N"
	M->VVF_VBAICM := 0
	M->VVF_ALIICM := 0
	M->VVF_TOTICM := 0
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CANFRETE ³ Autor ³ Andre               ³ Data ³ 10/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancelamento do Conhecimento de Frete                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANFRETE()

Local bCampo	:= { |nCPO| Field(nCPO) }
Local nCntFor,i_   := 0

lMsErroAuto := .f.
lMsHelpAuto := .t.

if VVF->VVF_OPEMOV == "6" // Conhecimento de Frete
	
	Private l103Auto    := .t.
	
	ProcRegua(2)
	IncProc(STR0083 )//Cancelando NF Conhecimento de Frete...
	
	If lAbortPrint
		If MsgYesNo((STR0084),(STR0009)) //Tem certeza que deseja abortar esta operacao? - Atencao
			Help("  ",1,"M160PROABO")
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .F.
		EndIf
	EndIf
	
	dbSelectArea("VVF")
	If VVF->VVF_SITNFI # "1" //Valida
		Help(" ",1,"NFINVCANCE")
		DisarmTransaction()
		Break
	Endif
	
	dbSelectArea("VVF")
	nSavReg   := Recno()
	cTraCpa   := VVF->VVF_TRACPA
	
	aItensNFR := {}
	dbSelectArea("VVF")
	dbSetOrder(5)
	if dbSeek(xFilial("VVF")+cTraCpa)
		While VVF->VVF_FILIAL == xFilial("VVF") .and. VVF->VVF_NUMTRA == cTraCpa
			if VVF->VVF_SITNFI == "1" //Nota nao cancelada
				dbSelectArea("VVG")
				dbSetOrder(1)
				dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
				dbSelectArea("VV1")
				dbSetOrder(1)
				dbSeek(xFilial("VV1")+VVG->VVG_CHAINT)
				//Veiculo ja foi Vendido
				if VV1->VV1_SITVEI <> "0"
					Help(" ",1,"VEICSNESTQ")
					DisarmTransaction()
					Break
				Endif
				dbSelectArea("VVF")
				aAdd(aItensNFR,{{"AUTNOTA",VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA,nil}})
			Endif
			dbSkip()
		Enddo
	Else
		MsgInfo(STR0085 ,STR0009) //Frete sem nenhuma NF relacionada - Atencao
		DisarmTransaction()
		Break
	Endif
	
	dbSelectArea("VVF")
	dbSetOrder(5)
	if dbSeek(xFilial("VVF")+cTraCpa)
		While VVF->VVF_FILIAL == xFilial("VVF") .and. VVF->VVF_NUMTRA == cTraCpa
			RecLock("VVF",.f.)
			VVF->VVF_CONFRE := 0
			VVF->VVF_NUMTRA := Space(10)
			MsUnlock()
			
			dbSelectArea("VVF")
			For nCntFor := 1 TO FCount()
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Next
			
			dbSelectArea("VVG")
			dbSetOrder(1)
			if dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
				While !EOF() .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
					RecLock("VVG",.f.)
					VVG->VVG_VALFRE := 0
					MsUnlock()
					DbSkip()
				EndDo
			Endif
			dbSelectArea("VVF")
			//dbSeek ao invez de dbskip pois o campo da chave 5 foi zerado
			dbSeek(xFilial("VVF")+cTraCpa)
		EndDo
	Endif
	
	dbSelectArea("VVF")
	DbGoto(nSavReg)
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	if lA2_IBGE .and. !Empty(SA2->A2_IBGE)
		DbSelectArea("VAM")
		DbSetOrder(1)
		DbSeek(xFilial("VAM")+SA2->A2_IBGE)
	endif
	
	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI)
	
	//Cria Vetor do Cabecalho da NF para o MATA116 (Conhecimento de Frete)
	aCabNFR := {}
	aadd(aCabNFR,{"MV_PAR11",dDataBase-100,Nil})
	aadd(aCabNFR,{"MV_PAR12",dDataBase    ,Nil})
	aadd(aCabNFR,{"MV_PAR13",1            ,Nil})
	aadd(aCabNFR,{"MV_PAR14","      "     ,Nil})
	aadd(aCabNFR,{"MV_PAR15","  "         ,Nil})
	aadd(aCabNFR,{"MV_PAR16",1            ,Nil})
	aadd(aCabNFR,{"MV_PAR17",2            ,Nil})
	if lA2_IBGE .and. !Empty(SA2->A2_IBGE) .and. !Empty(VAM->VAM_ESTADO)
		aadd(aCabNFR,{"MV_PAR18",VAM->VAM_ESTADO ,Nil})
	else
		aadd(aCabNFR,{"MV_PAR18",SA2->A2_EST ,Nil})
	endif
	aadd(aCabNFR,{"MV_PAR21",VVF_VALMOV   ,Nil})
	aadd(aCabNFR,{"MV_PAR22",2            ,Nil})
	aadd(aCabNFR,{"MV_PAR23",VVF_NUMNFI   ,Nil})
	aadd(aCabNFR,{"MV_PAR24",VVF_SERNFI   ,Nil})
	aadd(aCabNFR,{"MV_PAR25",VVF_CODFOR   ,Nil})
	aadd(aCabNFR,{"MV_PAR26",VVF_LOJA     ,Nil})
	aadd(aCabNFR,{"MV_PAR27",VVF_TESFRE   ,Nil})
	aadd(aCabNFR,{"MV_PAR28",if(VVF_ICMRET>0,VVF_VBAICM,0),Nil})
	aadd(aCabNFR,{"MV_PAR29",VVF_ICMRET   ,Nil})
	aadd(aCabNFR,{"MV_PAR31",VVF_FORPAG   ,Nil})
	
	dbSelectArea("SF4")
	dbSetOrder(1)
	if dbSeek(xFilial("SF4")+M->VVF_TESFRE)
		cParDup := SF4->F4_DUPLIC
		RecLock("SF4",.f.)
		SF4->F4_DUPLIC := "N"
		MsUnlock()
	Endif
	
	nAnt := MAFISSAVE()
	MAFISEND()
	lMSHelpAuto := .t.
	lMSErroAuto := .f.
	MsExecAuto({|x,y,z,w,r| MATA116(x,y,z,w,r)},aCabNFR,aItensNFR,,,aColsRATCC)
	MAFISRESTORE(nAnt)
	
	dbSelectArea("SF4")
	dbSetOrder(1)
	if dbSeek(xFilial("SF4")+VVF->VVF_TESFRE)
		RecLock("SF4",.f.)
		SF4->F4_DUPLIC := cParDup
		MsUnlock()
	Endif
	
	if lMsErroAuto
		Help(" ",1,"ERROCONFRE")   //Erro no Conhecimento de Frete
		DisarmTransaction()
		Break
	Endif
	
	// Traz Negociacao de Pagamento do Frete
	FS_TRAZNEG("F")
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+M->VVF_CODFOR+M->VVF_LOJA)
	
	For i_ := 1 to Len(aIteParc)
		if Empty(aIteParc[i_,1]) .and. aIteParc[i_,2] == 0
			Loop
		Endif
		dbSelectArea("SE2")
		dbSetOrder(1)
		if !dbSeek(xFilial("SE2") + M->VVF_SERNFI + M->VVF_NUMNFI + PadR(i_, TamSX3("E2_PARCELA")[1]) + PadR("DP", TamSX3("E2_TIPO")[1]) + M->VVF_CODFOR + M->VVF_LOJA)
			Loop
		Endif

		aVetDesp := {}
		aAdd(aVetDesp,{"E2_PREFIXO", M->VVF_SERNFI                    , Nil})
		aAdd(aVetDesp,{"E2_NUM"    , M->VVF_NUMNFI                    , Nil})
		aAdd(aVetDesp,{"E2_TIPO"   , PadR("DP", TamSX3("E2_TIPO")[1]) , Nil})
		aAdd(aVetDesp,{"E2_NATUREZ", SE2->E2_NATUREZ                  , Nil})
		aAdd(aVetDesp,{"E2_PARCELA", PadR(i_, TamSX3("E2_PARCELA")[1]), Nil})
		aAdd(aVetDesp,{"E2_FORNECE", M->VVF_CODFOR                    , Nil})
		aAdd(aVetDesp,{"E2_LOJA"   , M->VVF_LOJA                      , Nil})
		aAdd(aVetDesp,{"E2_EMISSAO", M->VVF_DATEMI                    , Nil})
		aAdd(aVetDesp,{"E2_VENCTO" , aIteParc[i_, 1]                  , Nil})
		aAdd(aVetDesp,{"E2_VALOR"  , aIteParc[i_, 2]                  , Nil})
		aAdd(aVetDesp,{"E2_VLCRUZ" , aIteParc[i_, 2]                  , Nil})
		pergunte("FIN050",.F.)
		MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
	Next
	
	dbSelectArea("VVF")
	DbGoto(nSavReg)
	WriteSX2("VVF")
	RecLock("VVF",.f.,.t.)
	DbDelete()
	MsUnlock()
	
Endif

Return( lMsErroAuto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef       ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criacao do menu               								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {{ STR0002 ,"AFunFrt", 0 , 1},;   && Pesquisar
{ STR0003 , "VM006V" , 0 , 2},;   && Vizualizar
{ STR0013 , "VM006I" , 0 , 3},;   && Incluir
{ STR0014 , "VM006C" , 0 , 4},; && Cancelar
{ STR0086 , "VM006_LVEI" , 0 , 1}}   //Pesquisa Chassi
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VM006V  ³ Autor ³  Manoel               ³ Data ³ 26/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM006V(cAlias,nReg,nOpc)
AFUNC06(cAlias,nReg,2)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VM006I  ³ Autor ³  Manoel               ³ Data ³ 26/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM006I(cAlias,nReg,nOpc)
aColsRATCC := {}
AFUNC06(cAlias,nReg,3)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VM006C  ³ Autor ³  Manoel               ³ Data ³ 26/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancela                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM006C(cAlias,nReg,nOpc)
AFUNC06(cAlias,nReg,5)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM006_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM006_LVEI()
Local nOpca := 0
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt //Salvar cFilAnt
Local nCont     := 0
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,""}}
Private cLevChas := space(TamSX3("VV1_CHASSI")[1])
nOpc := 1
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu   := FWArrFilAtu()
	aAdd( aEmpAtu , { cFilAnt , aFilAtu[5] } )
Next

cFilAnt := ""
Do While Empty(cFilAnt) //Nao sai da tela enquanto nao escolher uma filial
	cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt) //Escolher a filial que deseja trabalhar
EndDo

DEFINE MSDIALOG oLevPesq TITLE (STR0087) FROM  01,05 TO 17,70 OF oMainWnd  //Pesquisa Chassi
@ 003,004 SAY STR0088 SIZE 80,7 OF oLevPesq PIXEL COLOR CLR_BLUE //Veiculo:
@ 002,025 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL
@ 002,212 BUTTON oNo PROMPT (STR0089) OF oLevPesq SIZE 43,11 PIXEL ACTION (nOpca := 0, oLevPesq:End()) //SAIR
@ 015,002 LISTBOX oLbLevPesq FIELDS HEADER 	STR0090,; 	// Filial
											STR0091,; 	// Dt.Movimento
											STR0092,;	// NF/Serie
											STR0093,; 	// Valor
											STR0094;	// Fornecedor
											COLSIZES 35,35,25,40,150 SIZE 253,104 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || { 	aLevPesq[oLbLevPesq:nAt,03],;
							Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
							aLevPesq[oLbLevPesq:nAt,05],;
							FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
							aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
dbSelectArea("VVF")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	DbSetOrder(1)//TRACPA
	DbSeek(left(aLevPesq[nOpca,3],FWSizeFilial())+ aLevPesq[nOpca,1])
endif
cFilAnt := cBkpFilAnt // Voltar cFilAnt
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_LEVVEI     ³ Autor ³ Manoel                ³ Data ³ 22/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Levantamento do veiculo no VVF   								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVVEI()
Local cEmpAtu  := ""
Local nEmpAtu  := 0
Local lOk      := .t.
Local cQuery   := ""
Local cQAlVVF  := "SQLVVF"
Local cQAlVVFa := "SQLVVF2"
Local aSM0     := {}
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
If !Empty(cLevChas)
	aLevPesq := {}
	cQuery := "SELECT DISTINCT VVF.VVF_FILIAL , VVF.VVF_NUMTRA "
	cQuery += "FROM "+RetSqlName("VVF")+" VVF "
	cQuery += "JOIN "+RetSqlName("VVG")+" VVG ON ( VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVG.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE "
	cQuery += "VVG.VVG_CHASSI='"+Alltrim(cLevChas)+"' AND "
	cQuery += "VVF.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
	Do While !( cQAlVVF )->( Eof() )
		cQuery1 := "SELECT VVF.VVF_SITNFI , VVF.VVF_DATMOV , VVF.VVF_NUMNFI , VVF.VVF_SERNFI , VVF.VVF_VALMOV , VVF.VVF_CODFOR , VVF.VVF_LOJA , SA2.A2_NOME "
		cQuery1 += "FROM "+RetSqlName("VVF")+" VVF "
		cQuery1 += "JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=VVF.VVF_CODFOR AND SA2.A2_LOJA=VVF.VVF_LOJA AND SA2.D_E_L_E_T_=' ' ) "
		cQuery1 += "WHERE "
		cQuery1 += "VVF.VVF_FILIAL='"+( cQAlVVF )->VVF_FILIAL+"' AND "
		cQuery1 += "VVF.VVF_TRACPA='"+( cQAlVVF )->VVF_NUMTRA+"' AND "
		cQuery1 += "VVF.VVF_OPEMOV='6' AND "
		cQuery1 += "VVF.D_E_L_E_T_=' ' "
		cQuery1 += "ORDER BY VVF.VVF_DATMOV "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery1 ), cQAlVVFa, .F., .T. )
		Do While !( cQAlVVFa )->( Eof() )
			cEmpAtu := ""
			nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVVF )->( VVF_FILIAL ) })
			If nEmpAtu > 0
				cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
			EndIf
			aAdd(aLevPesq,{ ( cQAlVVF )->( VVF_NUMTRA ) , ( cQAlVVFa )->( VVF_SITNFI ) , ( cQAlVVF )->( VVF_FILIAL )+"-"+cEmpAtu , stod(( cQAlVVFa )->( VVF_DATMOV )) , ( cQAlVVFa )->( VVF_NUMNFI )+"-"+ FGX_UFSNF(( cQAlVVFa )->( VVF_SERNFI )) , ( cQAlVVFa )->( VVF_VALMOV ) , ( cQAlVVFa )->( VVF_CODFOR )+"-"+( cQAlVVFa )->( VVF_LOJA )+" "+( cQAlVVFa )->( A2_NOME ) })
			( cQAlVVFa )->( DbSkip() )
		EndDo
		( cQAlVVFa )->( dbCloseArea() )
		
		( cQAlVVF )->( DbSkip() )
	EndDo
	( cQAlVVF )->( dbCloseArea() )
	If len(aLevPesq) <= 0
		MsgAlert(STR0096 +" "+cLevChas,STR0009) //Nenhum Conhecimento de Frete encontrada para o Chassi - Atencao
		aLevPesq := {{"","","",ctod(""),"",0,""}}
		lOk := .f.
	EndIf
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	   	aLevPesq[oLbLevPesq:nAt,03],;
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±                                                                                                                             ±±±±
±±±±                                                                                                                             ±±±±
±±±±   F U N C O E S   Q U E   S A O   U T I L I Z A D A S   N O   V E I V M 0 0 6   E   E S T A V A M   N O   V E I V M 0 0 0   ±±±±
±±±±                                                                                                                             ±±±±
±±±±                                                                                                                             ±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_TudoOk ³ Autor ³  Manoel               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao e Integracao de Veiculos Normais                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TudoOk(nOpc)
Local cNatureza := ""
Local cFPG
Local lNFEntVei := ExistBlock("NFENTVEI")
Local i		    := 0
Local nRecSM0   := SM0->(Recno())
Local cEmpres   := SM0->M0_CODIGO
Local aFil      := {}
Private cChave  := ""
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	If cEmpres == SM0->M0_CODIGO
		aAdd( aFil , { SM0->M0_CODFIL , SM0->M0_CGC })
	EndIf
	DbSkip()
EndDo
DbGoTo(nRecSM0)

If ExistBlock("VEM000TOK")
	lRet := ExecBlock("VEM000TOK",.F.,.F.)
	if !lRet
		return .f.
	endif
Endif

nTotIte := 0
nTotipi := 0
nToticm := 0

cQAlVV0A := "SQLVV0A" // VV0/VVA

cQuery := "SELECT VV0.VV0_OPEMOV , SA1.A1_CGC , VV0.VV0_DTHEMI , VV0.VV0_DATMOV , VV0.VV0_FILIAL , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV "
cQuery += "FROM "+RetSqlName("VVA")+" VVA , "+RetSqlName("VV0")+" VV0 , "+RetSqlName("SA1")+" SA1 "
cQuery += "WHERE VVA.VVA_CHASSI='"+VV1->VV1_CHASSI+"' AND VVA.VVA_NUMTRA='"+VV1->VV1_NUMTRA+"' AND "
cQuery += "VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VVA.VVA_FILIAL=VV0.VV0_FILIAL AND "
cQuery += "VV0.VV0_SITNFI<>'0' AND VV0.VV0_CODCLI=SA1.A1_COD AND VV0.VV0_LOJA=SA1.A1_LOJA AND "
cQuery += "VVA.D_E_L_E_T_=' ' AND VV0.D_E_L_E_T_=' ' AND SA1.D_E_L_E_T_=' ' ORDER BY VV0.VV0_DATMOV DESC"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0A , .F., .T. )


aQuery := {}
while !((cQAlVV0A)->(eof()))
	aAdd(aQuery, {(cQAlVV0A)->(VV0_DATMOV),Subs((cQAlVV0A)->(VV0_DTHEMI),10,8),(cQAlVV0A)->(VV0_OPEMOV),(cQAlVV0A)->(A1_CGC),(cQAlVV0A)->(VV0_FILIAL),(cQAlVV0A)->(VV0_NUMNFI),(cQAlVV0A)->(VV0_SERNFI),(cQAlVV0A)->(VV0_VALMOV)})
	DBSkip()
enddo
aSort(aQuery,,,{|x,y| x[1]+x[2] > y[1]+y[2] })
if Len(aQuery) == 0
	cCGCSQL   := ""
	cUltOpMov := ""
	cNumNfi   := ""
	cSerNfi   := ""
else
	cUltOpMov := aQuery[1,3]
	cCGCSQL   := aQuery[1,4]
	cNumNfi   := aQuery[1,6]
	cSerNfi   := aQuery[1,7]
	If cParPrg == "3"
		i := aScan(aFil,{|x| x[1] == aQuery[1,5] })
		If i > 0
			cCGCSQL := aFil[i,2]
		EndIf
	EndIf
endif
( cQAlVV0A )->( dbCloseArea() )
DBSelectArea("VV0")

FG_VALIDA(,"SA2TM->VVF_CODFOR*")

If nOpc != 4
	if Empty(M->VVG_LOCPAD)
		MsgInfo(STR0116 ,STR0009) //Favor informar o Local Padrao do veiculo. Impossivel continuar. - Atencao
		return .f.
	endif
	
	if Empty(M->VVG_SITTRI)         //Antonio - 25/09/09 - fnc 22500
		if nOpc <> 2
			MsgInfo(STR0158, STR0009) //"Favor Informar a Situação Tributária do Veículo. Impossível Continuar."###"Atencao"
			return .f.
		Endif
	endif
	
	If nOpc == 3
		if !Empty(M->VVF_NATURE)
			cNatureza :=  M->VVF_NATURE
		Else
			cNatureza :=  SA2->A2_NATUREZ
		Endif
		If Empty(cNatureza)
			If X3Obrigat("E1_NATUREZ")
				Help(" ",1,"OBRIGAT2",,RetTitle("E1_NATUREZ"),4,1 )
				Return(.f.)
			EndIf
		EndIf
	EndIf
	
	if cParPrg == "1"
		if !(cUltOpMov $ "0467") .and. cUltOpMov != ""
			if GetNewPar("MV_VLDCGC0","S") == "S"
				MsgInfo(STR0117 ,STR0009) //A ultima saida do veiculo nao permite essa entrada por compra. Impossivel continuar. - Atencao
				return .f.
			endif
		endif
	endif
	if cParPrg == "2"
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+M->VVG_CODTES)
			if SF4->F4_PODER3 == "N"
				if !MsgYesNo(STR0118,STR0009) //O TES escolhido nao controla poder de terceiros. Deseja realizar essa remessa? - Atencao
					return .f.
				endif
			endif
		endif
		if !(cUltOpMov $ "02467") .and. cUltOpMov != ""
			if !(cUltOpMov == "3")// .and. cCGCSQL == SM0->M0_CGC) Rafael FNC 16830 - impossibilitava a emtrada por remessa originada de outras empresas - Manoel, Alexandre e Rafael
				if GetNewPar("MV_VLDCGC0","S") == "S"
					MsgInfo(STR0119,STR0009) //A ultima saida do veiculo nao permite entrada por remessa. Impossivel continuar - Atencao
					return .f.
				endif
			endif
		endif
	endif
	if cParPrg == "3"
		if cUltOpMov != "2"  .and. cUltOpMov != ""
			MsgInfo(STR0120 ,STR0009) //Veiculo nao esta em processo de transferencia. Impossivel continuar. - Atencao
			return .f.
		endif
		if GetNewPar("MV_VLDCGC0","S") == "S"
			if Alltrim(SA2->A2_CGC) != Alltrim(cCGCSQL)
				MsgInfo(STR0121,STR0009) //O fornecedor escolhido nao corresponde a filial que realizou a transferencia - Atencao
			endif
			r := aScan(aQuery,{|x| x[6]+x[7] == M->VVF_NUMNFI+M->VVF_SERNFI})
			if r == 0
				MsgInfo(STR0155,STR0009)
				return .f.
			endif
			r := aScan(aQuery,{|x| x[8] == M->VVF_VALMOV})
			if r == 0
				MsgInfo(STR0156,STR0009)
				return .f.
			Endif
			if !(Alltrim(cCGCSQL) == Alltrim(SM0->M0_CGC) )  //.AND. Right(Alltrim(cCGCSQL),6) != Right(Alltrim(SM0->M0_CGC),6))
				MsgInfo(STR0122,STR0009) //Nao e possivel efetuar transferencias entre empresas que nao pertencem ao mesmo grupo - Atencao
			endif
		endif
	endif
	if cParPrg == "4"
		if SF4->F4_PODER3 == "N"
			if !MsgYesNo(STR0118,STR0009) //O TES escolhido nao controla poder de terceiros. Deseja realizar essa remessa? - Atencao
				return .f.
			endif
		endif
		if cUltOpMov $ "35"
			if GetNewPar("MV_VLDCGC0","S") == "S"
				MsgInfo(STR0124,STR0009) //A ultima saida do veiculo nao permite entrada por consignacao. Impossivel continuar - Atencao
				return .f.
			endif
		endif
	endif
	if cParPrg == "5"
		if  cUltOpMov != ""
			MsgInfo(STR0123,STR0009) //Ja existe movimentacao para esse veiculo. Impossivel continuar - Atencao
			return .f.
		endif
	endif
endif

If nOpc == 2
	Return .t.
Endif

AL_InicioEnc()

If !l000Auto .and. cOpeMov $ ("0/6")   // 0=Normal / 6=Transferencia
	FS_TrataAba(1)
	cFPG := M->VVF_FORPAG
	oEnc01:oBox:SetFocus()
Endif

If !l000Auto .and. !Obrigatorio(aGets,aTela)
	oFolder00:nOption := 1
	Return .f.
Endif

If !FG_OBRIGAT()
	Return .f.
Endif

if cOpeMov # Substr((STR0101),1,1)  // Pedidos Fabrica
	For i:=1 to len(aCols)
		if !aCols[i,len(aCols[i])]
			dbSelectArea("SF4")
			dbSetOrder(1)
			if !dbSeek(xFilial("SF4")+aCols[i,FG_POSVAR('VVG_CODTES')])
				MsgStop(STR0159) //TES nao informado! ,verifique.
				Return .f.
			Else
				if !Val(aCols[i,FG_POSVAR("VVG_CODTES")]) < 500
					Help(" ",1,"TESINVM000")
					Return .f.
				Endif
			Endif
		Endif
	Next
Endif

if cParPrg == "4" .or. cParPrg == "2" // Consignado ou Remessa
	For i:=1 to len(aCols)
		if !aCols[i,len(aCols[i])]
			dbSelectArea("SF4")
			dbSetOrder(1)
			if !dbSeek(xFilial("SF4")+aCols[i,FG_POSVAR('VVG_CODTES')])
				// Verifica se controla Poder de Terceiro, deve controlar na Remessa
				if SF4->F4_PODER3 <> "R" // Remessa
					if !MsgYesNo(STR0118,STR0009) //"O TES escolhido nao controla poder de terceiros. Deseja realizar essa remessa? - Atencao
						return .f.
					endif
				Endif
			Endif
		Endif
	Next
Endif

For i:=1 to len(aCols)
	if aCols[i,len(aCols[i])]
		Loop
	Endif
	if Empty(aCols[i,FG_POSVAR("VVG_CODTES")])
		MsgInfo(STR0125 +" < "+aCols[i,FG_POSVAR("VVG_CHASSI")]+" > "+ STR0126,STR0009) //Tes do Veiculo/ esta Incorreto, ou nao foi informado!- Atencao
		Return .f.
	Endif
Next

if cParPrg == "5"
	if Empty(M->VVG_ATDFTD)
		MsgInfo(STR0127,STR0009) //E necessario informar qual o atendimento VDI/Frotista referente a este veiculo! - Atencao
		Return(.f.)
	Endif
	if M->VVG_ESTVEI <> "0"
		MsgInfo(STR0128,STR0009) //Veiculo para VDI/Frotista somente pode ser novo! - Atencao
		Return(.f.)
	Endif
Endif

if nOpc == 3
	cTexto := (STR0106)
Else
	cTexto := (STR0107)
Endif

if M->VVF_FORPRO <> "1" //Formulario Proprio = Sim
	if Empty(M->VVF_NUMNFI)
		MsgInfo(STR0132,STR0009) //Numero da NF nao foi informado! - Atencao
		Return .f.
	Endif
	if Inclui .and. FM_PESQSF1(,M->VVF_NUMNFI,M->VVF_SERNFI,M->VVF_CODFOR,M->VVF_LOJA,1)
		MsgInfo(STR0115,STR0009) //Nf de entrada ja se encontra cadastrada - \atencao
		DbSelectArea("VVF")
		Return .f.
	Endif
	DbSelectArea("VVF")
Endif

if l000Auto .or. MsgYesNo((STR0108)+cTexto,(STR0009))
	
	lCriaVVF := .f.
	if nOpc <> 4 .and. M->VVF_FORPRO <> "1" //Cancelamento da Nota Fiscal de Entrada
		dbSelectArea("VVF")
		dbSetOrder(6)
		if dbSeek(xFilial("VVF")+M->VVF_NUMNFI+M->VVF_SERNFI+M->VVF_CODFOR+M->VVF_LOJA)
			if VVF->VVF_SITNFI == "1"
				MsgInfo(STR0129 +" "+M->VVF_NUMNFI+" / "+ FGX_UFSNF(M->VVF_SERNFI) +CHR(13)+CHR(10)+ STR0130 +" "+M->VVF_CODFOR+" / "+M->VVF_LOJA+" "+ STR0131,STR0009) //Nota Fiscal - do Fornecedor - ja existe no arquivo! - Atencao
				dbSetOrder(1)
				Return(.f.)
			Else
				lCriaVVF := .t.
			Endif
		Endif
		dbSetOrder(1)
	Endif
	
	// Ponto de Entrada Antes da Gravacao da Nota Fiscal
	If ExistBlock("VM000ANF")
		ExecBlock("VM000ANF",.f.,.f.)
	EndIf
	
	// Gera Nota Fiscal de Entrada
	Processa( {|| lMsErroAuto := FS_GRVENT(nOpc) } )
	
	// Ponto de Entrada Depois da Gravacao da Nota Fiscal
	If ExistBlock("VM000DNF")
		ExecBlock("VM000DNF",.f.,.f.)
	EndIf
	
	if !lMsErroAuto
		dbSelectArea("VVF")
		If VVF->VVF_FORPRO == "1" .and. nOpc <> 4 .and. nOpc <> 5 // Formulario Proprio
			If lNFEntVei
				//Impressao da Nota Fiscal de Entrada
				ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF->VVF_CODFOR,VVF->VVF_LOJA})
			Endif
		Endif
	Else
		mostraErro()
		Return .f.
	Endif
Else
	Return .f.
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_GRVENT ³ Autor ³  Manoel               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gravacao e Integracao de Veiculos Normais                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos  (Modelo3)                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRVENT(nopc)

Local nCustoVeiculo := 0
Local cNatureza     := ""
Local nPICM         := 0
Local i             := 0
Local ix_           := 0
Local i_            := 0
Local yi_           := 0
Local nX            := 0
Local cTexto        := ""

Local cQuery        := ""
Local cQAlVAZ       := "SQLVAZ"
Local cQAlVS9       := "SQLVS9"
Local cQAlSE1       := "SQLSE1"
Local cMsgVAZ       := ""
Local c9Parcel      := ""
Local c9TipPag      := ""
Local cNumTit       := ""
Local nRecNoVS9     := 0
Local nRecNoVAZ     := 0
Local lBaixarSE1    := .f.
Local cDMSPrefOri   := GetNewPar("MV_PREFVEI","VEI")

Local lRet          := .t.
Local aVetSB1       := {}
Local oVeiculos     := DMS_Veiculo():New()

Private lMsHelpAuto := .t.
Private lMsErroAuto := .f.

Private lLivreDebito:= .f.		// Indica se sera gerado titulo (avaliacao de veiculos)

If Type("l000Auto") == "U"
	l000Auto	:= .F.
EndIf

aCabNFE    := {}
aItensNFR  := {}

if nOpc == 4 //Cancelamento da Nota Fiscal de Entrada
	FS_CANCENT()
Else
	ProcRegua(5)
	If M->VVF_FORPRO == "1" // Formulario Proprio
		
		If FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
			return .t.
		Endif
		
	Else
		if Empty(M->VVF_NUMNFI)
			MsgInfo(STR0132,STR0009) //Numero da NF nao foi informado - Atencao
			Return .t.
		Endif
		cNota  := M->VVF_NUMNFI
		cSerie := M->VVF_SERNFI
	Endif
	
	if Empty(M->VVF_FORPAG)
		MsgInfo((STR0109),(STR0009))
		Return( .t. )
	Else
		if SE4->(dbSeek(xFilial("SE4")+M->VVF_FORPAG))
			if AllTrim(SE4->E4_COND) == "0" .and. SE4->E4_TIPO # "A" .and. !l000Auto
				FS_APAGAFP()
			ElseIf !l000Auto
				FS_FPGAUTO()
			Endif
		Endif
	Endif
	
	if !l000Auto
		dbSelectArea("VV2")
		dbSetOrder(1)
		if !VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			MsgInfo(STR0133 +":"+ Alltrim(VV1->VV1_CODMAR)+"/"+Alltrim(VV1->VV1_MODVEI)+ " "+STR0080+":"+Alltrim(VV1->VV1_CHASSI) )  //Modelo de veiculo nao cadastrado!
		Endif
	endif

	Begin  Transaction
	
	IncProc(STR0110)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao do VVF                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VVF")
	if Inclui
		M->VVF_TRACPA := GetSxENum("VVF","VVF_TRACPA")
		If M->VVF_FORPRO == "1"
			
			If FM_NRNFFP(2) // 2a Chamada da tela que verifica NF quando Formulario Proprio
				return .t.
			Endif
			
			M->VVF_NUMNFI := cNota
			M->VVF_SERNFI := cSerie
			
		Endif
	Endif
	
	dbSelectArea("VVF")
	dbSetOrder(6)
	cSeek  := ( VVF->(dbSeek(xFilial("VVF")+cNota+cSerie)) .and. !lCriaVVF )
	
	if l000Auto
		if cSeek
			M->VVF_TRACPA := VVF->VVF_TRACPA
		Endif
	Endif
	
	For i := 1 to len(aCols)
		If !aCols[i,len(aCols[i])]
			M->VVF_QTDVEI := M->VVF_QTDVEI + 1
		Endif
	Next
	
	if !RecLock("VVF",!cSeek)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 17/03/2010                                  ³
	//³Gravar o VVF_ESPECI se o usuario nao especificar nada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if VVF->(FieldPos("VVF_ESPECI")) <> 0 .and. Empty(M->VVF_ESPECI)
		M->VVF_ESPECI := GetNewPar("MV_ESPECNF","NF")
	endif
	//
	
	VVF->VVF_FILIAL := xFilial("VVF")
	FG_GRAVAR("VVF")
	VVF->VVF_SITNFI    := "1" && Valida
	Do Case
		Case cParPrg == "1"
			VVF->VVF_OPEMOV := "0"
		Case cParPrg == "2"
			VVF->VVF_OPEMOV := "2"
		Case cParPrg == "3"
			VVF->VVF_OPEMOV := "3"
		Case cParPrg == "4"
			VVF->VVF_OPEMOV := "4"
		Case cParPrg == "5"
			VVF->VVF_OPEMOV := "5"
	EndCase
	VVF->VVF_QTDVEI := M->VVF_QTDVEI
	VVF->VVF_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
	if VVF->(FieldPos("VVF_OBSMEM")) <> 0 .and. VVF->(FieldPos("VVF_OBSERV")) <> 0 .And. VVF->(FieldPos("VVF_OBSMNF")) <> 0
		aMemos   := {{"VVF_OBSMEM","VVF_OBSERV"}}
		MSMM(,TamSx3("VVF_OBSERV")[1],,&(aMemos[1][2]),1,,,"VVF","VVF_OBSMEM")
		aMemos   := {{"VVF_OBSMNF","VVF_OBSENF"}}
		MSMM(,TamSx3("VVF_OBSENF")[1],,&("VVF_OBSENF"),1,,,"VVF","VVF_OBSMNF")
	Endif
	ConfirmSx8()
	MsUnlock()
	nRecNF     := Recno()
	aIteTmpNfe := {}
	
	nSlv := n
	ltit := .t.
	nVTotDsp := 0
	nVTotFre := 0
	nVTotSeg := 0
	For ix_ := 1 to len(acols)
		
		n:=ix_
		
		if aCols[ix_,len(aHeader)+1]
			loop
		Endif
		
		IncProc(STR0111)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao do VV1                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VV1")
		dbSetOrder(2)
		if l000Auto .and. !VV1->(dbSeek(xFilial("VV1")+ltrim(aCols[ix_,FG_POSVAR("VVG_CHASSI")])))
			RecLock("VV1",.t.)
			For nX := 1 to Len(aAutoVeic)
				if !Empty(aAutoVeic[nX,2])
					&("VV1->"+aAutoVeic[nX,1]) := aAutoVeic[nX,2]
				Else
					if Type("M->"+aAutoVeic[nX,1]) <> "U"
						&("VV1->"+aAutoVeic[nX,1]) := &("M->"+aAutoVeic[nX,1])
					Endif
				Endif
			Next
			MsUnlock()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao do VVG                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VV1")
		dbSetOrder(2)
		dbSeek(xFilial("VV1")+ltrim(aCols[ix_,FG_POSVAR("VVG_CHASSI")]))
		
		dbSelectArea("VVG")
		cSeek  := VVG->(dbSeek(xFilial("VVG")+M->VVF_TRACPA+VV1->VV1_CHAINT))
		RecLock("VVG",!cSeek)
		FG_GRAVAR("VVG",aCols,aHeader,ix_)
		VVG->VVG_FILIAL := xFilial("VVG")
		VVG->VVG_TRACPA := VVF->VVF_TRACPA
		VVG->VVG_CHAINT := VV1->VV1_CHAINT
		MsUnlock()
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
		
		IncProc(STR0111)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao do VV1                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VV1")
		dbSetOrder(2)
		RecLock("VV1",.f.)
		
		if cParPrg == "1" .or. Empty(VV1->VV1_TRACPA)
			VV1->VV1_FILIAL  := xFilial("VV1")
			VV1->VV1_TRACPA  := VVF->VVF_TRACPA
			VV1->VV1_ESTVEI  := aCols[ix_,FG_POSVAR("VVG_ESTVEI")]
			if VV1->VV1_CODORI == "3"
				VV1->VV1_CODORI := "0"
			else
				VV1->VV1_CODORI  := aCols[ix_,FG_POSVAR("VVG_CODORI")]
			endif
			VV1->VV1_LOCPAD  := aCols[ix_,FG_POSVAR("VVG_LOCPAD")]
		Endif
		
		//Atualiza situacao do veiculo
		if cParPrg == "1"  //Compra
			If SF4->F4_ESTOQUE == "S"
				VV1->VV1_SITVEI := "0" //Estoque
			Endif
		Endif
		
		if cParPrg == "2"  //Remessa
			If SF4->F4_ESTOQUE == "S"
				VV1->VV1_SITVEI := "3" //Remessa
			Endif
		Endif
		
		if cParPrg == "3"  //Transferencia
			If SF4->F4_ESTOQUE == "S"
				VV1->VV1_SITVEI := "0" //Estoque
			Endif
			VV1->VV1_STATUS := VVG->VVG_FILIAL
		Endif
		
		if cParPrg == "4"  //Consignado
			If SF4->F4_ESTOQUE == "S"
				VV1->VV1_SITVEI := "4" //Consignado
			Endif
		Endif
		
		if cParPrg == "5"  //Venda direta
			VV1->VV1_SITVEI := "1" //Vendido
		Endif
		
		VV1->VV1_TIPENT := StrZero(Val(cParPrg)-1,1)  //FNC 22988/2010 - BOBY - 19/10/10
		
		cConces := ""
		cLojCon := ""
		SM0->(DBGoto(nEmpAtuSM0))
		SA1->(dbSetOrder(3))
		if !(SA1->(dbSeek(xFilial("SA1")+SM0->M0_CGC)))
			MsgInfo(STR0134 +" ["+SM0->M0_CGC+"] "+ STR0135)    //A empresa com CNPJ nro - nao esta cadastrada corretamente no cadastro de clientes. CNPJ nao encontrado
		Else
			cConces := SA1->A1_COD
			cLojCon := SA1->A1_LOJA
		Endif
		
		FG_Seek("VE4","VV1->VV1_CODMAR")
		cCodFab := VE4->VE4_CODFAB+VE4->VE4_LOJA
		cNomFab := ""
		if !Empty(cCodFab) .and. FG_Seek("SA1","cCodFab",1,.f.)
			cNomFab := SA1->A1_NREDUZ
			if lA1_IBGE .and. !Empty(SA1->A1_IBGE) .and. FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
				VV1->VV1_CIDANT := VAM->VAM_DESCID
				VV1->VV1_ESTANT := VAM->VAM_ESTADO
			else
				VV1->VV1_CIDANT := SA1->A1_MUN
				VV1->VV1_ESTANT := SA1->A1_EST
			endif
		Endif
		
		if cParPrg == "1"
			VV1->VV1_PROATU := cConces
			VV1->VV1_LJPATU := cLojCon
		Endif
		VV1->VV1_NOMANT := SA2->A2_NOME
		VV1->VV1_ENDANT := SA2->A2_END
		VV1->VV1_CEPANT := SA2->A2_CEP
		VV1->VV1_DOCIND := SA2->A2_CGC
		if cParPrg == "3"
			VV1->VV1_PROANT := VV1->VV1_PROATU
			VV1->VV1_PROATU := VE4->VE4_CODFAB
		endif
		MsUnlock()
		
		IncProc(STR0097) //"Atualizando o Cadastro de Veiculos..."
		If lAbortPrint
			If MsgYesNo((STR0098),(STR0009)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
				Help("  ",1,"M160PROABO")
				lRet := .f.
				DisarmTransaction()
				Break
			Else
				lAbortPrint := .F.
			EndIf
		EndIf
		
		cCodSB1 := ""
		if VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			if VV8->(dbSeek(xFilial("VV8")+VV2->VV2_TIPVEI))
				if M->VVG_ESTVEI == "0" //Novo
					nPICM := VV8->VV8_ALINOV
				Else
					nPICM := VV8->VV8_ALIUSA
				Endif
			Endif
			dbSelectArea("SB1")
			dbSetOrder(7)
			if dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
				cCodSB1 := SB1->B1_COD
			Endif
		Else
			//MsgInfo("Modelo de veiculo nao cadastrado!")
			lRet := .f.
			DisarmTransaction()
			Break
		Endif
		DBSelectArea("SB1")
		DBSetOrder(7)
		IF !(DBSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
			VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			if VV8->(dbSeek(xFilial("VV8")+VV2->VV2_TIPVEI))
				if M->VVG_ESTVEI == "0" //Novo
					nPICM := VV8->VV8_ALINOV
				Else
					nPICM := VV8->VV8_ALIUSA
				Endif
			Endif
			
			cCodSB1 := oVeiculos:GetB1_COD(VV1->VV1_CHAINT) // Inclui SB1 do Veiculo
			//
			aVetSB1 := {}
			aAdd(aVetSB1,{"B1_LOCPAD"  ,VVG->VVG_LOCPAD })
			aAdd(aVetSB1,{"B1_PICM"    ,nPICM           })
			aAdd(aVetSB1,{"B1_IPI"     ,VVG->VVG_ALIIPI })
			aAdd(aVetSB1,{"B1_TE"      ,VVG->VVG_CODTES })
			aAdd(aVetSB1,{"B1_CONTA"   ,VVG->VVG_CONTA  })
			aAdd(aVetSB1,{"B1_CC"      ,VVG->VVG_CENCUS })
			aAdd(aVetSB1,{"B1_FABRIC"  ,cNomFab         })
			aAdd(aVetSB1,{"B1_ORIGEM"  ,VVG->VVG_SITTRI })
			//
			lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,3,aVetSB1,"") // Inclui SB1 do Veiculo
			If !lRet
				MostraErro()
				Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo
				DisarmTransaction()
				Break
			Endif
			
			if !( SB1->(EOF()) )
				DBSelectArea("SB1")
				RecLock("SB1",.f.)
				ConfirmSx8()
				Msunlock()
			endif
			
			//Ponto de Entrada p/ Atualizar o Cadastro de Veiculos
			If ExistBlock("VA010DPGR")
				ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,3,0})
			EndIf
			
		Else
			
			cCodSb1 := SB1->B1_COD
			VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			if VV8->(dbSeek(xFilial("VV8")+VV2->VV2_TIPVEI))
				if M->VVG_ESTVEI == "0" //Novo
					nPICM := VV8->VV8_ALINOV
				Else
					nPICM := VV8->VV8_ALIUSA
				Endif
			Endif
			
			dbSelectArea("SB1")
			aVetSB1 := {}
			aAdd(aVetSB1,{"B1_LOCPAD"  ,VVG->VVG_LOCPAD })
			aAdd(aVetSB1,{"B1_PICM"    ,nPICM           })
			aAdd(aVetSB1,{"B1_IPI"     ,VVG->VVG_ALIIPI })
			aAdd(aVetSB1,{"B1_TE"      ,VVG->VVG_CODTES })
			aAdd(aVetSB1,{"B1_PRV1"    ,VV1->VV1_SUGVDA })
			aAdd(aVetSB1,{"B1_CONTA"   ,VVG->VVG_CONTA  })
			aAdd(aVetSB1,{"B1_CC"      ,VVG->VVG_CENCUS })
			aAdd(aVetSB1,{"B1_FABRIC"  ,cNomFab         })
			aAdd(aVetSB1,{"B1_ORIGEM"  ,VVG->VVG_SITTRI })
			//
			lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,4,aVetSB1,"") // Altera SB1 do Veiculo
			If !lRet
				MostraErro()
				Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo
				DisarmTransaction()
				Break
			Endif

			// Ponto de Entrada apos gravacao do SB1
			If ExistBlock("VM000AGB1")
				ExecBlock("VM000AGB1",.f.,.f.)
			EndIf
		Endif

		SF4->(DbGoTop())
		SF4->(dbSeek(xFilial("SF4")+VVG->VVG_CODTES))
		nVTotSeg += VVG->VVG_TOTSEG
		nVTotFre += VVG->VVG_TOTFRE
		nVTotDsp += VVG->VVG_DESACE
		//Cria Vetor de Itens para o MATA100 (Nota Fiscal de Entrada)
		// nVTotDsp := (VVF->VVF_TOTSEG + VVF->VVF_TOTFRE + VVF->VVF_DESACE) / M->VVF_QTDVEI
		
		//Posicionamento p/ calcular o Custo do Veiculo
		VV1->(dbSetOrder(1))
		VV1->(dbSeek(xFilial("VV1")+VVG->VVG_CHAINT))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		VE4->(dbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
		FG_Seek("VVH","VVG->VVG_CODIND",1,.f.)
		
		FG_MEMVAR()
		
		nCustoVeiculo := 0
		if M->VVG_ESTVEI == "0" //Novo
			dbSelectArea("VVG")
			If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
				nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
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
			if MaFisFound('NF')
				nCustoVeiculo := MaFisRet(ix_,"IT_TOTAL")
			Else
				nCustoVeiculo := VVG->VVG_VALUNI
			Endif
		Endif
		
		DBSelectArea("SB1")
		DBSetOrder(7)
		IF !(DBSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
			Help(" ",1,"ERROCADPRO") // Erro no Cadastro do Veiculo
			DisarmTransaction()
			Break
		endif
		cCFO := ""
		If !MaFisFound('NF')
			FS_INIIMP(VVF->VVF_CODFOR,VVF->VVF_LOJA)
			If MaFisFound('NF')
				MaFisRef("IT_PRODUTO",cProg,SB1->B1_COD)
			Endif
		Endif
		cCFO := FG_CLAFIS(VVG->VVG_CODTES)
		
		dbSelectArea("SB1")
		RecLock("SB1",.f.)
		SB1->B1_UPRC := nCustoVeiculo
		MsUnlock()
		
		nAliqIPI := VVG->VVG_ALIIPI
		if Empty(VVG->VVG_ALIIPI) .and. !Empty(VVG->VVG_VALIPI)
			nAliqIPI := Round((VVG->VVG_VALIPI / VVG->VVG_VALUNI) * 100,2)
		Endif
		
		cClasFis := Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB
		
		dbSelectArea("VV1")
		aItensNFR := {}
		aAdd(aItensNFR,{"D1_DOC"     ,VVF->VVF_NUMNFI		   ,Nil})
		aAdd(aItensNFR,{"D1_SERIE"   ,VVF->VVF_SERNFI		   ,Nil})
		aAdd(aItensNFR,{"D1_ITEM"    ,strzero(ix_,2)           ,Nil})
		aAdd(aItensNFR,{"D1_COD"     ,cCodSB1                  ,Nil})
		aAdd(aItensNFR,{"D1_UM"      ,"UN"                     ,Nil})
		aAdd(aItensNFR,{"D1_QUANT"   ,1                        ,Nil})
		aAdd(aItensNFR,{"D1_VUNIT"   ,VVG->VVG_VALUNI		   ,Nil})
		aAdd(aItensNFR,{"D1_VALFRE"  ,VVG->VVG_TOTFRE          ,Nil})
		aAdd(aItensNFR,{"D1_DESPESA"   ,VVG->VVG_DESACE		   ,Nil})
		aAdd(aItensNFR,{"D1_SEGURO"   ,VVG->VVG_TOTSEG		   ,Nil})
		aAdd(aItensNFR,{"D1_TOTAL"   ,VVG->VVG_VALUNI		   ,Nil})
		aAdd(aItensNFR,{"D1_EMISSAO" ,VVF->VVF_DATEMI          ,Nil})
		aAdd(aItensNFR,{"D1_TES"     ,VVG->VVG_CODTES          ,Nil})
		aAdd(aItensNFR,{"D1_CF"      ,cCFO                     ,Nil})
		aAdd(aItensNFR,{"D1_CLASFIS" ,cClasFis                 ,Nil})
		aAdd(aItensNFR,{"D1_VALFRE"  ,VVG->VVG_TOTFRE          ,Nil})
		aAdd(aItensNFR,{"D1_PESO"    ,SB1->B1_PESBRU           ,Nil})
		aAdd(aItensNFR,{"D1_IPI"     ,nAliqIPI                 ,Nil})
		aAdd(aItensNFR,{"D1_BASEIPI" ,VVG->VVG_VBAIPI 		   ,Nil})
		aAdd(aItensNFR,{"D1_VALIPI"  ,VVG->VVG_VALIPI 		   ,Nil})
		aAdd(aItensNFR,{"D1_PICM"    ,VVG->VVG_ALIICM          ,Nil})
		aAdd(aItensNFR,{"D1_BRICMS"  ,VVG->VVG_VBICRT          ,Nil})
		aAdd(aItensNFR,{"D1_ICMSRET" ,VVG->VVG_ICMRET          ,Nil})
		aAdd(aItensNFR,{"D1_BASEICM" ,VVG->VVG_VBAICM 		   ,Nil})
		aAdd(aItensNFR,{"D1_VALICM"  ,VVG->VVG_ICMCOM 		   ,Nil})
		aAdd(aItensNFR,{"D1_CONTA"   ,VVG->VVG_CONTA           ,Nil})
		aAdd(aItensNFR,{"D1_CC"      ,VVG->VVG_CENCUS          ,Nil})
		aAdd(aItensNFR,{"D1_RATEIO"  ,'2'                      ,Nil})
		aAdd(aItensNFR,{"D1_LOCAL"   ,VVG->VVG_LOCPAD          ,Nil})
		if M->VVG_ESTVEI == "0" .or. ( M->VVG_ESTVEI == "1" .and. !Empty(cFor) )
			aAdd(aItensNFR,{"D1_CUSTO"   ,nCustoVeiculo        ,Nil})
		EndIf
		aAdd(aIte,aclone(aItensNFR))
				
		lLivreDebito := .f.
		
		
		If VS9->(FieldPos("VS9_PARCEL"))>0
			
			dbSelectArea("VV1")
			dbSetOrder(2)
			if VV1->(dbSeek(xFilial("VV1")+ltrim(aCols[ix_,FG_POSVAR("VVG_CHASSI")])))
				cMsgVAZ := ""
				lBaixarSE1 := .f.
				////////////////////////////////////////////////////
				// Utilizar somente a ultima AVALIACAO do Veiculo //
				////////////////////////////////////////////////////
				cQuery := "SELECT VAZ.R_E_C_N_O_ VAZRECNO , VAZ.VAZ_CODIGO , VAZ.VAZ_TIPAVA , VAZ.VAZ_APROVA FROM "+RetSqlName("VAZ")+" VAZ WHERE "
				cQuery += "VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CHASSI='"+VV1->VV1_CHASSI+"' AND VAZ.D_E_L_E_T_=' '"
				cQuery += "ORDER BY VAZ.VAZ_REVISA DESC"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAZ, .F., .T. )
				If !( cQAlVAZ )->( Eof() )
					If ( cQAlVAZ )->( VAZ_APROVA ) == "0" // Avaliacao nao Aprovada
						cMsgVAZ := "Existe avaliação não aprovada para o chassi "+VV1->VV1_CHASSI+". Impossivel continuar."
					Else
						If ( cQAlVAZ )->( VAZ_TIPAVA ) == "1" // Troca
							///////////////////////////
							// Verificar Atendimento //
							///////////////////////////
							cQuery := "SELECT VV9.VV9_STATUS , VV9.VV9_NUMATE , VV0.VV0_NUMNFI , VS9.R_E_C_N_O_ VS9RECNO , VS9.VS9_PARCEL , VS9.VS9_DATBAI , VS9.VS9_TIPPAG FROM "+RetSqlName("VS9")+" VS9 "
							cQuery += "INNER JOIN "+RetSQLName("VV0")+" VV0 ON 	( VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA=VS9.VS9_NUMIDE AND VV0.D_E_L_E_T_=' ' ) "
							cQuery += "INNER JOIN "+RetSQLName("VV9")+" VV9 ON 	( VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV9.D_E_L_E_T_=' ' ) "
							cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_REFPAG='"+( cQAlVAZ )->( VAZ_CODIGO )+"' AND VS9.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS9, .F., .T. )
							If !( cQAlVS9 )->( Eof() )
								////////////////////////////////////////////////////////////////
								// Verificar se o Atendimento esta 'Aprovado' ou 'Finalizado' //
								////////////////////////////////////////////////////////////////
								If !( ( cQAlVS9 )->( VV9_STATUS ) $ "L/F" )
									cMsgVAZ := "Existe atendimento ( "+( cQAlVS9 )->( VV9_NUMATE )+" ) não aprovado para o chassi "+VV1->VV1_CHASSI+". Impossivel continuar."
								Else
									/////////////////////////////////////////////////////////////////////
									// Baixar automaticamente o Titulo correspondente ao Veiculo Usado //
									/////////////////////////////////////////////////////////////////////
									If Empty(( cQAlVS9 )->( VS9_DATBAI ))
										cNumTit := "V"+Right(( cQAlVS9 )->( VV9_NUMATE ),TamSx3("E1_NUM")[1]-1)
										If GetNewPar("MV_TITATEN","0") == "0" // Gera Titulo na Finalizacao
											If !Empty(( cQAlVS9 )->( VV0_NUMNFI ))
												cNumTit := ( cQAlVS9 )->( VV0_NUMNFI )
											EndIf
										EndIf
										c9Parcel   := ( cQAlVS9 )->( VS9_PARCEL )
										c9TipPag   := ( cQAlVS9 )->( VS9_TIPPAG )
										nRecNoVS9  := ( cQAlVS9 )->( VS9RECNO )
										nRecNoVAZ  := ( cQAlVAZ )->( VAZRECNO )
										lBaixarSE1 := .t.
									EndIf
								EndIf
							Else
								cMsgVAZ := "Nao existe atendimento para o chassi "+VV1->VV1_CHASSI+". Impossivel continuar."
							EndIf
							( cQAlVS9 )->( dbCloseArea() )
						EndIf
					EndIf
				EndIf
				( cQAlVAZ )->( dbCloseArea() )
				DbSelectArea("VAZ")
				If !Empty(cMsgVAZ)
					MsgStop(cMsgVAZ,"Atencao")
					lRet := .f.
					DisarmTransaction()
					Return(.f.)
					//					Break
				EndIf
				If lBaixarSE1
					//
					DBSelectArea("SF4")
					DBSetOrder(1)
					DBSeek(xFilial("SF4")+aCols[ix_,FG_POSVAR("VVG_CODTES")])
					if Alltrim(SF4->F4_DUPLIC) == "S"
						MsgStop("Para compra de veiculos envolvidos em troca utilize um T.E.S. que não gere titulos. Impossivel continuar.","Atencao")
						lRet := .f.
						DisarmTransaction()
						Return(.f.)
						//						Break
					Endif
					//
					lLivreDebito := .t.
					//
					///////////////////////////////////////////////////////////////////
					// Baixar Titulo no SE1 - Titulo correspondente ao Veiculo Usado //
					///////////////////////////////////////////////////////////////////
					cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM " + RetSQLName("SE1") + " SE1 WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "' AND SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_PREFORI='"+cDMSPrefOri+"' AND "
					cQuery += "SE1.E1_PARCELA='"+Alltrim(c9Parcel)+"' AND SE1.E1_TIPO='"+Alltrim(c9TipPag)+"' AND SE1.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSE1, .F., .T. )
					While !( cQAlSE1 )->(Eof())
						DbSelectArea("SE1")
						DbGoTo(( cQAlSE1 )->RECSE1)
						aBaixa  := {{"E1_PREFIXO" ,E1_PREFIXO         ,Nil } ,;
						{"E1_NUM"	   ,E1_NUM             ,Nil } ,;
						{"E1_PARCELA"  ,E1_PARCELA         ,Nil } ,;
						{"E1_TIPO"	   ,E1_TIPO            ,Nil } ,;
						{"AUTMOTBX"	   ,"NOR"              ,Nil } ,;
						{"AUTDTBAIXA"  ,dDataBase          ,Nil } ,;
						{"AUTDTCREDITO",dDataBase          ,Nil } ,;
						{"AUTHIST"	  ,"BAIXA VEIC USADO"  ,Nil } ,;
						{"AUTVALREC"   ,SE1->E1_VALOR      ,Nil }}
						MSExecAuto({|x| FINA070(x)},aBaixa)
						If lMsErroAuto
							lRet := .f.
							( cQAlSE1 )->( dbCloseArea() )
							DbSelectArea("SE1")
							DisarmTransaction()
							//							Break
							Return(.f.)
						Else
							//////////////////////////
							// Atualiza arquivo VS9 //
							//////////////////////////
							DbSelectArea("VS9")
							DbGoto(nRecNoVS9)
							RecLock("VS9",.f.)
							VS9->VS9_DATBAI := ddatabase
							MsUnLock()
							//////////////////////////
							// Atualiza arquivo VAZ //
							//////////////////////////
							DbSelectArea("VAZ")
							DbGoto(nRecNoVAZ)
							RecLock("VAZ",.f.)
							VAZ->VAZ_TRACPA := VVF->VVF_TRACPA
							VAZ->VAZ_FILENT := VVF->VVF_FILIAL
							MsUnLock()
						EndIf
						( cQAlSE1 )->(dbSkip())
					EndDo
					( cQAlSE1 )->( dbCloseArea() )
					DbSelectArea("SE1")
				endif
			endif
		endif
		
	Next
	n:=nSlv
	
	cFormul := "S"
	If VVF->VVF_FORPRO == "0" //Formulario Proprio = Nao
		cFormul := "N"
	Endif
	
	if !Empty(M->VVF_NATURE)
		cNatureza :=  M->VVF_NATURE
	Else
		cNatureza :=  SA2->A2_NATUREZ
	Endif
	
	SA2->(DbGoTop())
	SA2->(dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA))
	aAdd(aCabNFE,{"F1_TIPO"    ,"N"            ,Nil})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 17/03/2010                                  ³
	//³Gravar o VVF_ESPECI se o usuario nao especificar nada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if VVF->(FieldPos("VVF_ESPECI")) <> 0 .and. !Empty(VVF->VVF_ESPECI)
		aAdd(aCabNFE,{"F1_ESPECIE" , VVF->VVF_ESPECI ,Nil})
	else
		aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
	endif
	aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
	aAdd(aCabNFE,{"F1_DOC"     ,VVF->VVF_NUMNFI,Nil})
	aAdd(aCabNFE,{"F1_SERIE"   ,VVF->VVF_SERNFI,Nil})
	aAdd(aCabNFE,{"F1_COND"    ,RetCondVei()   ,Nil})
	aAdd(aCabNFE,{"F1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
	aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
	aAdd(aCabNFE,{"F1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
	aAdd(aCabNFE,{"F1_BRICMS"  ,VVG->VVG_VBICRT,Nil})
	aAdd(aCabNFE,{"F1_ICMSRET" ,VVF->VVF_ICMRET,Nil})
	aAdd(aCabNFE,{"F1_SEGURO"  ,nVTotseg       ,Nil})
	aAdd(aCabNFE,{"F1_FRETE"   ,nVTotfre       ,Nil})
	aAdd(aCabNFE,{"F1_DESPESA" ,nVTotDsp       ,Nil})
	aAdd(aCabNFE,{"F1_VALMERC" ,VVF->VVF_VALMOV,Nil})
	aAdd(aCabNFE,{"F1_VALBRUT" ,VVF->VVF_VALMOV,Nil})
	aAdd(aCabNFE,{"F1_BASEICM" ,VVF->VVF_VBAICM,Nil})
	aAdd(aCabNFE,{"F1_VALICM"  ,VVF->VVF_TOTICM,Nil})
	aAdd(aCabNFE,{"F1_BASEIPI" ,VVF->VVF_VBAIPI,Nil})
	aAdd(aCabNFE,{"F1_VALIPI"  ,VVF->VVF_VALIPI,Nil})
	aAdd(aCabNFE,{"F1_EST"     ,SA2->A2_EST    ,Nil})
	If VVF->(FieldPos("VVF_PLIQUI")) > 0
		aAdd(aCabNFE,{"F1_PLIQUI"		,VVF->VVF_PLIQUI   ,Nil})
		aAdd(aCabNFE,{"F1_PBRUTO"		,VVF->VVF_PBRUTO   ,Nil})
	endif	
	if VVF->(FieldPos("VVF_TRANSP")) > 0 .and. !Empty(VVF->VVF_TRANSP)
		aAdd(aCabNFE,{"F1_TRANSP"  ,VVF->VVF_TRANSP  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_ESPEC1")) > 0 .and. !Empty(VVF->VVF_ESPEC1)
		aAdd(aCabNFE,{"F1_ESPECI1",VVF->VVF_ESPEC1  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_VOLUM1")) > 0 .and. !Empty(VVF->VVF_VOLUM1)
		aAdd(aCabNFE,{"F1_VOLUME1" ,VVF->VVF_VOLUM1  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_ESPEC2")) > 0 .and. !Empty(VVF->VVF_ESPEC2)
		aAdd(aCabNFE,{"F1_ESPECI2",VVF->VVF_ESPEC2  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_VOLUM2")) > 0 .and. !Empty(VVF->VVF_VOLUM2)
		aAdd(aCabNFE,{"F1_VOLUME2" ,VVF->VVF_VOLUM2  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_ESPEC3")) > 0 .and. !Empty(VVF->VVF_ESPEC3)
		aAdd(aCabNFE,{"F1_ESPECI3",VVF->VVF_ESPEC3  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_VOLUM3")) > 0 .and. !Empty(VVF->VVF_VOLUM3)
		aAdd(aCabNFE,{"F1_VOLUME3" ,VVF->VVF_VOLUM3  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_ESPEC4")) > 0 .and. !Empty(VVF->VVF_ESPEC4)
		aAdd(aCabNFE,{"F1_ESPECI4",VVF->VVF_ESPEC4  ,Nil})
	Endif
	if VVF->(FieldPos("VVF_VOLUM4")) > 0 .and. !Empty(VVF->VVF_VOLUM4)
		aAdd(aCabNFE,{"F1_VOLUME4" ,VVF->VVF_VOLUM4  ,Nil})
	Endif
	aAdd(aCabNFE,{"E2_NATUREZ",cNatureza    ,Nil})
	
	IncProc(STR0099) //"Gerando Nota Fiscal de Entrada..."
	If lAbortPrint
		If MsgYesNo((STR0098),(STR0009)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
			Help("  ",1,"M160PROABO")
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .F.
		EndIf
	EndIf
	
	SF1->(dbSetOrder(1))
	SD1->(dbSetOrder(1))
	
	lMsHelpAuto := .t.
	lMsErroAuto := .f.
	
	lInclui := inclui
	inclui  := .t.
	nAnt    := MAFISSAVE()
	MAFISEND()
	FG_X3ORD("C",,aCabNFE)
	FG_X3ORD("I",,aIte)
	SB1->(dbSetOrder(1))
	
	MSExecAuto({|x,y,z,w,r,s,t,u| MATA103(x,y,z,w,r,s,t,u)},aCabNFE,aIte,,,,,,aColsRATCC)
	MAFISRESTORE(nAnt)
	inclui := lInclui
	//
	if lMsErroAuto
		MostraErro()
		DisarmTransaction()
		Break
	Endif
	//
	if TCCanOpen(RetSQLName("VZL"))
		DBSelectArea("SB1")
		reclock("SB1",.f.)
		SB1->B1_LOCPAD := VVG->VVG_LOCPAD
		msunlock()
		//
		DBSelectArea("SB5")
		DBSetOrder(1)
		if !DBSeek(xFilial("SB5")+SB1->B1_COD)
			reclock("SB5",.t.)
			SB5->B5_FILIAL := xFilial("SB5")
			SB5->B5_COD := SB1->B1_COD
			SB5->B5_LOCALI2 := VVG->VVG_LOCALI
			msunlock()
		else
			reclock("SB5",.f.)
			SB5->B5_LOCALI2 := VVG->VVG_LOCALI
			msunlock()
		endif
	endif
	
	lGeraTitulo:= .t.
	cCond := M->VVF_FORPAG
	if Len(aIteParc) == 0
		lGeraTitulo := .f.
	Endif
	
	dbSelectArea("SF1")
	RecLock("SF1",.f.)
	SF1->F1_COND    := cCond
	SF1->F1_DUPL    := SF1->F1_DOC
	SF1->F1_PREFIXO := &(GetNewPar("MV_2DUPREF","cSerie"))
	MsUnlock()
	
	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->VVF_NUMNFI := SF1->F1_DOC
	VVF->VVF_SERNFI := SF1->F1_SERIE
	if FieldPos("F1_SDOC") > 0
		VVF->VVF_SDOC := SF1->F1_SDOC
	EndIf
	if VVF->(FieldPos("VVF_RECSF1")) > 0
		VVF->VVF_RECSF1 := SF1->(Recno())
	Endif
	MsUnlock("VVF")
	
	IncProc(STR0136)    //Gravando Negociacao de Pagamento...
	if lGeraTitulo .and. lTit .and. !lLivreDebito
		
		cCodBco2 := M->VVF_CODBCO
		cNumBord2:= ""
		dDatBord2:= cTod("")
		FG_Seek("SA6","cCodBco2",1,.f.)
		if SA6->A6_BORD == "0"
			cNumBord2 := "BCO"+SA6->A6_COD
			dDatBord2 := dDataBase
		Endif
		
		lTit := .f.
		
		if !Empty(M->VVF_NATURE)
			cNatureza :=  M->VVF_NATURE
		Else
			cNatureza :=  SA2->A2_NATUREZ
		Endif
		
		//Gravacao das parcelas do ComoPagar
		FS_GRAVANEG("N")
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+M->VVG_CODTES) .and. SF4->F4_DUPLIC == "S"
			For i_ := 1 to Len(aIteParc)
				aVetDesp := {}
				aAdd(aVetDesp,{"E2_PREFIXO"  ,&(GetNewPar("MV_2DUPREF","cSerie")) ,Nil})
				aAdd(aVetDesp,{"E2_NUM"      ,VVF->VVF_NUMNFI    ,Nil})
				aAdd(aVetDesp,{"E2_TIPO"     ,"DP "              ,Nil})
				aAdd(aVetDesp,{"E2_NATUREZ"  ,cNatureza          ,Nil})
				aAdd(aVetDesp,{"E2_PARCELA"  ,Strzero(i_,len(SE2->E2_PARCELA))          ,Nil})
				aAdd(aVetDesp,{"E2_FORNECE"  ,M->VVF_CODFOR      ,Nil})
				aAdd(aVetDesp,{"E2_LOJA"     ,M->VVF_LOJA        ,Nil})
				aAdd(aVetDesp,{"E2_EMISSAO"  ,dDataBase   	    ,Nil})
				aAdd(aVetDesp,{"E2_VENCTO"   ,aIteParc[i_,1]     ,Nil})
				aAdd(aVetDesp,{"E2_VALOR"    ,aIteParc[i_,2]     ,Nil})
				aAdd(aVetDesp,{"E2_VLCRUZ"   ,aIteParc[i_,2]     ,Nil})
				aAdd(aVetDesp,{"E2_NUMBOR"   ,cNumBord2          ,Nil})
				aAdd(aVetDesp,{"E2_PORTADO"  ,cCodBco2           ,Nil})
				pergunte("FIN050",.F.)
				lMsHelpAuto := .t.
				lMsErroAuto := .f.
				MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
				if lMsErroAuto
					MostraErro()
					DisarmTransaction()
					Break
				Endif
				cAliAntG := alias()
				DbSelectArea("SE2")
				reclock("SE2",.f.)
				SE2->E2_ORIGEM := "MATA100"
				SE2->E2_LA := "S"
				msunlock()
				DBSelectArea(cAliAntG)
			Next
		Endif
	Endif
	
	ny:=n
	For yi_ := 1 to len(acols)
		
		if aCols[yi_,len(aHeader)+1]
			loop
		Endif
		n:=yi_
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao do VVG                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VV1")
		dbSetOrder(2)
		dbSeek(xFilial("VV1")+ltrim(aCols[yi_,FG_POSVAR("VVG_CHASSI")]))
		
		dbSelectArea("VVG")
		dbsetorder(1)
		dbSeek(xFilial("VVG")+M->VVF_TRACPA+VV1->VV1_CHAINT)
		FG_MEMVAR()
		
		nCustoVeiculo := 0
		if M->VVG_ESTVEI == "0" //Novo
			dbSelectArea("VVG")
			If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
				nCustoVeiculo := FG_FORMULA(VV2->VV2_FORCUS)
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
			if MaFisFound('NF')
				nCustoVeiculo := MaFisRet(n,"IT_TOTAL")
			Else
				nCustoVeiculo := VVG->VVG_VALUNI
			Endif
		Endif
		
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
		
		dbSelectArea("SD1")
		dbSetOrder(1)
		if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
			nSvRcD1 := Recno()
			//   	   SD1->D1_DESCRI  := SB1->B1_DESC
			/* Grava valor de Pis e Cofins no SD1, pois o calculo para veiculos e diferente do padrao */
			if VVG->VVG_PICOSB == "1" // Tem Pis/Cofins de Substituicao
				nBasePC := VVG->VVG_VALUNI + VVG->VVG_VALDES + VVG->VVG_TOTSEG + VVG->VVG_DESACE + VVG->VVG_TOTFRE + VVG->VVG_VALIPI
			Else
				nBasePC := 0
			Endif
			FG_SEEK("SF4","VVG->VVG_CODTES",1,.f.)
			if !(VVG->VVG_PISENT+VVG->VVG_COFENT > 0)
				aPisCof := CalcPisCofEnt(nBasePC)
				GrvPisCof(nBasePc,aPiscof,"E")
			Endif
			Dbgoto(nSvRcD1)
			If M->VVG_ESTVEI == "1" .and. empty(cFor)
				nCustoVeiculo := SD1->D1_CUSTO
			Else
				RecLock("SD1",.f.)
					SD1->D1_CUSTO := nCustoVeiculo
				MsUnlock()
			EndIf
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		if dbSeek(xFilial("SB1")+SD1->D1_COD)
			RecLock("SB1",.f.)
			SB1->B1_UPRC := nCustoVeiculo
			MsUnlock()
		Endif
		
		dbSelectArea("VVG")
		dbsetorder(1)
		if dbSeek(xFilial("VVG")+M->VVF_TRACPA+VV1->VV1_CHAINT)
			RecLock("VVG",.f.)
			VVG->VVG_VCNVEI := SD1->D1_CUSTO
			MsUnlock()
		Endif
		
		dbSelectArea("VV1")
		dbSetOrder(1)
		if dbSeek(xFilial("VV1")+M->VV1_CHAINT)
			RecLock("VV1",.f.)
			if M->VVG_ESTVEI <> "0" //Novo
				VV1->VV1_GRTRIB := " "
			Endif
			VV1->VV1_LOCPAD := VVG->VVG_LOCPAD
			MsUnlock()
		Endif
		
		dbSelectArea("SB2")
		dbSetOrder(1)
		if dbSeek(xFilial("SB2")+SD1->D1_COD)
			RecLock("SB2",.f.)
			If SB2->B2_QATU > 0
				SB2->B2_CM1   := xMoeda(nCustoVeiculo,1,1,dDataBase)
				SB2->B2_CM2   := xMoeda(nCustoVeiculo,1,2,dDataBase)
				SB2->B2_CM3   := xMoeda(nCustoVeiculo,1,3,dDataBase)
				SB2->B2_CM4   := xMoeda(nCustoVeiculo,1,4,dDataBase)
				SB2->B2_CM5   := xMoeda(nCustoVeiculo,1,5,dDataBase)
				SB2->B2_VATU1 := xMoeda(nCustoVeiculo,1,1,dDataBase)
				SB2->B2_VATU2 := xMoeda(nCustoVeiculo,1,2,dDataBase)
				SB2->B2_VATU3 := xMoeda(nCustoVeiculo,1,3,dDataBase)
				SB2->B2_VATU4 := xMoeda(nCustoVeiculo,1,4,dDataBase)
				SB2->B2_VATU5 := xMoeda(nCustoVeiculo,1,5,dDataBase)
			Endif
			MsUnlock()
		Endif
	Next
	n:=ny
	
	If ExistBlock("VEI000_A")
		ExecBlock("VEI000_A",.f.,.f.)
	EndIf
	
	IncProc(STR0100) //"Emitindo Nota Fiscal..."
	
	MAFISEND()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desposicionar, para considerar em SELECT no meio da transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VVF->(dbGoTo(VVF->(Recno())))
	
	// Tratamento para ver se veiculo esta em transito e registrar
	VVG->(DBSEEK(xFilial("VVG")+VVF->VVF_TRACPA))
	
	While !VVG->(Eof()) .and. VVG->VVG_FILIAL == xFilial("VVG") .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
		
		VV1->(dbSetOrder(1))
		VV1->(DBSEEK(xFilial("VV1")+VVG->VVG_CHAINT))
		If GetNewPar("MV_PERGVTR","N") == "S" .and. VV1->VV1_SITVEI == "0"
			// Declaracao da ParamBox
			aRet := {}
			aParamBox := {}
			aCombo := {"0-"+(STR0160),"2-"+(STR0161)}
			aAdd(aParamBox,{2,(STR0162),1,aCombo,70,"",.F.}) // Tipo caractere
			//
			While !(ParamBox(aParamBox,"",@aRet))
				
			Enddo
			//
			if valtype(aRet[1])=="C"
				cSitVei := Left(aRet[1],1)
			else
				cSitVei := Iif(aRet[1]==1,"0","2")
			endif
			
			If cSitVei == "2"
				
				RecLock("VV1",.f.)
				VV1->VV1_SITVEI := cSitVei
				MsUnlock()
				If VV1->VV1_SITVEI == "2"
					DbSelectArea("VZK")
					RecLock("VZK",.t.)
					VZK_FILIAL := xFilial("VZK")
					VZK_CHASSI := VV1->VV1_CHASSI
					VZK_NUMNFI := VVF->VVF_NUMNFI
					VZK_SERNFI := VVF->VVF_SERNFI
					if FieldPos("VZK_SDOC") > 0
						VZK_SDOC := FGX_MILSNF("VVF", 2, 'VVF_SERNFI')
					EndIf
					VZK_CODFOR := VVF->VVF_CODFOR
					VZK_LOJA   := VVF->VVF_LOJA
					VZK_DATENT := dDataBase // Data de Entrada do Veiculo em Transito
					MsUnlock()
				Endif
				
			Endif
			
		Endif
		
		if TCCanOpen(RetSQLName("VZL"))
			FM_LOCVZL(1)
			DBSelectArea("VVG")
			reclock("VVG",.f.)
			VVG->VVG_LOCPAD := SB1->B1_LOCPAD
			VVG->VVG_LOCALI := SB5->B5_LOCALI2
			msunlock()
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VVG->(dbGoTo(VVG->(Recno())))
		
		FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
		If FindFunction("VXX04REVJ1")
			VXX04REVJ1(VV1->VV1_CHASSI,"","1")//realiza a reserva do veiculo - VEIXX004
		EndIf
		
		VVG->(dbSkip())
	Enddo
	
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX6")
	MsRUnLock()
	
Endif

if cTexto <> ""
	MsgStop(cTexto)
Endif

if lMsErroAuto
	MostraErro()
Endif

dbSelectArea("VVF")

Return(lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ve000Inc ³ Autor ³ Andre/Manoel          ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Inclusao de Veiculos atraves da Entrada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  Ve000Inc(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ve000Inc(cAlias,nReg,nOpc)

Local oDlg,lInclui
Local nOpca     := 0
Local lRetFunc  := .f.
Local lAchou    := .f.
Local cArea     := GetArea()
Local bCampo    := { |nCPO| Field(nCPO) }
Local nCntFor   := 0
Local nPICM     := 0
Local vv	    := 0
Local cTipoMov  := "N"
Local lRet      := .t.
Local aVetSB1   := {}
Local oVeiculos := DMS_Veiculo():New()

if Type("lVX000Auto") != "U"
	if lVX000Auto
		return .t.
	endif
endif

Do Case
	Case cParPrg == "1"
		cTipoMov := "N"
	Case cParPrg == "2"
		cTipoMov := "R"
	Case cParPrg == "3"
		cTipoMov := "T"
	Case cParPrg == "4"
		cTipoMov := "C"
EndCase

if Empty(M->VVG_CHASSI)
	Return( .f. )
Endif

lAchou := FG_Seek("VV1","M->VVG_CHASSI",2,.f.)

if !Inclui
	M->VVG_CHASSI := VV1->VV1_CHASSI
Endif

Do Case
	Case VV1->VV1_SITVEI == "0"        //Estoque
		Help(" ",1,"VEJACDM010")
		Return .f.
	Case VV1->VV1_SITVEI == "3"    //Em Remessa
		if MsgYesNo(STR0137 ,STR0009) //Essa entrada e um retorno de remessa? - Atencao
			Aviso( (STR0112) , (STR0113) , { (STR0114) } )
			Return .f.
		endif
	Case VV1->VV1_SITVEI == "4"    //Consignado
		Aviso( STR0138  , STR0139 , { STR0114 } )  //Veiculo Consignado - Antes de fazer a Entrada deste Veiculo e' necessario usar a opcao SAIDA DE CONSIGNADOS (Retorno da Entrada de Veiculo Consignado - ok
		Return .f.
	Case empty(M->VVG_CHASSI)
		Return .f.
EndCase
if VV1->VV1_CODORI == "3" .and. cParPrg # "1"
	Aviso( STR0140 , STR0141 , { STR0114 } ) //Veiculo Virtual - Apenas e' possivel realizar a Entrada deste Veiculo por ENTRADA NORMAL - OK
	RETURN .F.
endif

acols[n,FG_POSVAR("VVG_ESTVEI")] := VV1->VV1_ESTVEI // Usado
M->VVG_ESTVEI := VV1->VV1_ESTVEI // Usado
acols[n,FG_POSVAR("VVG_CODORI")] := VV1->VV1_CODORI // Usado
M->VVG_CODORI := VV1->VV1_CODORI // Usado

FS_AlmVei()

dbSelectArea("VV1")
For vv := 1 to fcount()
	&("M->"+fieldname(VV)) := fieldget(VV)
Next
lChaTemp  := .t.
//MaFisRef("IT_PRODUTO","VVG00",VV1->VV1_CHAINT)
MaFisRef("IT_PRODUTO",cProg,SB1->B1_COD)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega matriz com campos que serao alterados neste cadastro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSeek("VV1")
While !EOF() .And. (X3_ARQUIVO == cAlias)
	if !lAchou
		wVar := "M->"+x3_campo
		if x3_campo <> "VV1_CHAINT"
			&wVar:= CriaVar(x3_campo)
		Else
			&wVar:= Space(TamSx3("VV1_CHAINT")[1])
		Endif
	Endif
	DbSkip()
EndDO

if lAchou
	M->VVG_CHAINT := VV1->VV1_CHAINT
	
	// Atualiza aCols com Chassi Interno do Veiculo
	aCols[n,FG_POSVAR("VVG_CHAINT")] := VV1->VV1_CHAINT
	RegToMemory("VV1",.F.)
	If ExistBlock("VA010DPGR")
		ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,3,0})
	EndIf
	
	// Atualiza aCols com Situacao Tributaria
	SB1->(DBSetOrder(7))
	IF SB1->(DBSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)) .and. !Empty(SB1->B1_ORIGEM)
		aCols[n,FG_POSVAR("VVG_SITTRI")] := M->VVG_SITTRI := SB1->B1_ORIGEM
	else
		if VV1->VV1_PROVEI == "1"
			aCols[n,FG_POSVAR("VVG_SITTRI")] := M->VVG_SITTRI := "0"
		endif
	endif
	//
	
	ATEND000()
	Return( .t. )
Endif

dbSelectArea(cAlias)
Private aTELA[0][0],aGETS[0]

wChassi := M->VVG_CHASSI

lInclui := Inclui
Inclui  := .t.
aMemosSlv := aClone(aMemos)
aMemos   := {{"VV1_OBSMEM","VV1_OBSERV"}}
nOpca   := AxInclui(cAlias,nReg,nOpc,aCampoVV1,"GRAVAVV1",,"VEIVA600().and.FS_VAL000()")
aMemos := aClone(aMemosSlv)
if nOpca <> 1
	Return .f.
Endif
aCols[n,FG_POSVAR("VVG_CHASSI")] := M->VVG_CHASSI := VV1->VV1_CHASSI

ConfirmSx8()
Inclui  := lInclui

//MaFisRef("IT_PRODUTO","VVG00",VV1->VV1_CHAINT)
MaFisRef("IT_PRODUTO",cProg,SB1->B1_COD)

If nOpca == 1
	lRetFunc := .t.
EndIf

VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
if VV8->(dbSeek(xFilial("VV8")+VV2->VV2_TIPVEI))
	if M->VVG_ESTVEI == "0" //Novo
		nPICM := VV8->VV8_ALINOV
	Else
		nPICM := VV8->VV8_ALIUSA
	Endif
Endif

// Atualiza aCols com Situacao Tributaria
if VV1->VV1_PROVEI == "1"
	aCols[n,FG_POSVAR("VVG_SITTRI")] := M->VVG_SITTRI := "0"
endif
//

DBSelectArea("SB1")
DBSetOrder(7)
IF !(DBSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
	
	FG_Seek("VE4","VV1->VV1_CODMAR")
	cCodFab := VE4->VE4_CODFAB+VE4->VE4_LOJA
	FG_Seek("SA1","cCodFab",1,.f.)
	cNomFab := SA1->A1_NREDUZ

	aVetSB1 := {}
	aAdd(aVetSB1,{"B1_LOCPAD"  ,IIf(!Empty(M->VVG_LOCPAD),M->VVG_LOCPAD,VV1->VV1_LOCPAD) })
	aAdd(aVetSB1,{"B1_PICM"    ,nPICM             })
	aAdd(aVetSB1,{"B1_IPI"     ,M->VVG_ALIIPI     })
	aAdd(aVetSB1,{"B1_TE"      ,M->VVG_CODTES     })
	aAdd(aVetSB1,{"B1_CONTA"   ,M->VVG_CONTA      })
	aAdd(aVetSB1,{"B1_CC"      ,M->VVG_CENCUS     })
	aAdd(aVetSB1,{"B1_FABRIC"  ,cNomFab           })
	aAdd(aVetSB1,{"B1_CODBAR"  ,M->VVG_CHAINT     })
	aAdd(aVetSB1,{"B1_ORIGEM"  ,M->VVG_SITTRI     })
	//
	lRet := oVeiculos:CriaPeca(VV1->VV1_CHAINT,3,aVetSB1,"VA010AB1") // Inclui SB1 do Veiculo
	If !lRet
		MostraErro()
		Return .f.
	EndIf
	
	if !( SB1->(EOF()) )
		RecLock("SB1",.f.)
		ConfirmSx8()
		Msunlock()
	endif
EndIf

//Ponto de Entrada p/ Atualizar o Cadastro de Veiculos
If ExistBlock("VA010DPGR")
	ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,3,0})
EndIf

dbSelectArea("VVG")

lChaTemp  := .t.
M->VVG_CHASSI := wChassi
M->VVG_CHAINT := VV1->VV1_CHAINT

// Atualiza aCols com Chassi Interno do Veiculo
aCols[n,FG_POSVAR("VVG_CHAINT")] := VV1->VV1_CHAINT

RegToMemory("VV1",.F.)
ATEND000()

acols[n,FG_POSVAR("VVG_ESTVEI")] := VV1->VV1_ESTVEI // Usado
M->VVG_ESTVEI := VV1->VV1_ESTVEI // Usado
acols[n,FG_POSVAR("VVG_CODORI")] := VV1->VV1_CODORI // Usado
M->VVG_CODORI := VV1->VV1_CODORI // Usado

if Empty(M->VVG_LOCPAD) .and. !Empty(VV1->VV1_LOCPAD)
	acols[n,FG_POSVAR("VVG_LOCPAD")] := M->VVG_LOCPAD := VV1->VV1_LOCPAD
endif

Keyboard CHR(13)

Return lRetFunc

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Function ATEND000()
Local aAtend := {}
Local cAtend := ""
Local cQAlVV0 := "SQLVV0"
Local cQuery := ""
Local cSavAlias := alias()
SA1->(dbSetOrder(1))
VV2->(dbSetOrder(1))
VVC->(dbSetOrder(1))
VVC->(dbSeek( xFilial("VVC") + M->VV1_CODMAR + M->VV1_CORVEI ))
cQuery := "SELECT VV0.VV0_NUMTRA , VV0.VV0_DATMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VV0.VV0_MODVEI FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VVA")+" VVA WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND "
cQuery += "VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VVA.VVA_CHASSI=' ' AND VV0.VV0_TIPFAT='3' AND VV0.VV0_MODVEI='"+M->VV1_MODVEI+"' AND ( VV0.VV0_CORVEI='"+M->VV1_CORVEI+"' OR VV0.VV0_CORVEI=' ' ) AND VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0 , .F., .T. )
Do While !( cQAlVV0 )->( Eof() )
	SA1->(dbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) ))
	VV2->(dbSeek( xFilial("VV2") + M->VV1_CODMAR + ( cQAlVV0 )->( VV0_MODVEI ) ))
	aadd(aAtend,{ ( cQAlVV0 )->( VV0_NUMTRA ) , stod(( cQAlVV0 )->( VV0_DATMOV )) , ( cQAlVV0 )->( VV0_CODCLI ) , ( cQAlVV0 )->( VV0_LOJA ) , SA1->A1_NOME , VV2->VV2_DESMOD , VVC->VVC_DESCRI })
	( cQAlVV0 )->( DbSkip() )
EndDo
( cQAlVV0 )->( dbCloseArea() )
if Len(aAtend) > 0
	nOpca := 0
	DEFINE MSDIALOG oJanela TITLE STR0142 From 10,5 to 29,82 of oMainWnd //Atendimentos
	
	@ 012, 001 LISTBOX oLbLista FIELDS HEADER	(STR0143),;//Atendimento
	(STR0144),;//Data
	(STR0145),;//Cliente
	(STR0146),;//Loja
	(STR0147),;//Nome
	(STR0148),;//Modelo
	(STR0149);//Cor
	COLSIZES 30,30,30,10,60,60,30 SIZE 305,131 OF oJanela PIXEL
	
	oLbLista:SetArray(aAtend)
	oLbLista:bLine := { || { aAtend[oLbLista:nAt,1] ,;
	aAtend[oLbLista:nAt,2] ,;
	aAtend[oLbLista:nAt,3] ,;
	aAtend[oLbLista:nAt,4] ,;
	aAtend[oLbLista:nAt,5] ,;
	aAtend[oLbLista:nAt,6] ,;
	aAtend[oLbLista:nAt,7] }}
	
	ACTIVATE MSDIALOG oJanela ON INIT (EnChoiceBar(oJanela,{|| cAtend := aAtend[oLbLista:nAt,1], nOpca :=1, oJanela:End()},{|| nOpca :=2, oJanela:End()})) CENTER
	if nOpca == 1
		if Type("aCols") <> "U" .and. FG_POSVAR("VVG_ATDFTD") > 0
			aCols[n,FG_POSVAR("VVG_ATDFTD")] := cAtend
		Endif
		M->VVG_ATDFTD := cAtend
		//Pesquisa o Atendimento selecionado para gravar o chassi
		dbSelectArea("VVA")
		dbSetOrder(1)
		if dbSeek(xFilial("VVA")+cAtend)
			RecLock("VVA",.f.)
			if Type("aCols") <> "U" .and. FG_POSVAR("VVG_ATDFTD") > 0
				VVA->VVA_CHASSI := M->VVG_CHASSI
				VVA->VVA_CHAINT := M->VVG_CHAINT
			else
				VVA->VVA_CHASSI := M->VV1_CHASSI
				VVA->VVA_CHAINT := M->VV1_CHAINT
			Endif
			MsUnlock()
			
			M->VV1_RESERV := "1" //Reservado
			M->VV1_DTHRES := Dtoc(dDataBase) + [/] + Time()
			
			nHora := (val(substr(Time(),1,2))+GetNewPar("MV_NMHORRV",2))
			dData := dDataBase + int(nHora/24)
			if nHora > 24
				nHora := (int(nHora/24)*24)-nHora
			Endif
			M->VV1_DTHVAL := Dtoc(dData) + "/" + alltrim(Str(nHora))+substr(Time(),4,2)
			
			dbSelectArea("VV0")
			dbSetOrder(1)
			if dbSeek(xFilial("VV0")+cAtend)
				RecLock("VV0",.f.)
				VV0->VV0_RESERV := M->VV1_RESERV
				VV0->VV0_DATVAL := dData
				VV0->VV0_HORVAL := alltrim(Str(nHora))+substr(Time(),4,2)
				MsUnlock()
			Endif
			
			dbSelectArea("VV1")
			dbSetOrder(1)
			if dbSeek(xFilial("VV1")+M->VV1_CHAINT)
				RecLock("VV1",.f.)
				VV1->VV1_RESERV := M->VV1_RESERV
				VV1->VV1_DTHRES := M->VV1_DTHRES
				VV1->VV1_DTHVAL := M->VV1_DTHVAL
				MsUnlock()
			Endif
			
			//Avisa por e-mail o vendedor que o veiculo do atendimento chegou
			If ExistBlock("AVIVEI000")
				ExecBlock("AVIVEI000",.f.,.f.)
			Endif
			
		Endif
	Endif
Endif
DbSelectArea(cSavAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GRAVAVV1 ³ Autor ³ Manoel                ³ Data ³ 19/07/99 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRAVAVV1()
M->VV1_CHASSI := M->VVG_CHASSI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_VAL000³ Autor ³ Manoel                ³ Data ³ 19/07/99 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VAL000()
if M->VV1_ESTVEI == "1"
	if Empty(M->VV1_PLAVEI)
		MsgInfo(STR0150 ,STR0009) //Necessario informar a placa do veiculo - Atencao
		Return( .f. )
	Endif
Endif
Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fs_NpLinha³ Autor ³ Manoel                ³ Data ³ 19/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ So permite criacao de linha na GetDados em uma INCLUSAO    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_NpLinha()
if !Inclui
	Return .f.
Endif
Return .t.

///////////////////////
Function AL_InicioEnc()
aTela := aClone(aSvATela[1])
aGets := aClone(aSvAGets[1])
dbSelectArea("VVF")
Return(.t.)

//////////////////////////
Function FS_TrataAba(cAba)
Local i := 0
lReturn := .f.
If cAba == 1
	nFolAnt := 1
	oEnc01:oBox:SetFocus()
	lReturn := .t.
ElseIf cAba == 2 .and. nOpcE # 4
	If !empty(M->VVG_CHASSI)
		lReturn := .t.
	Endif
	M->VV1_CHASSI := ltrim(aCols[n,FG_POSVAR("VVG_CHASSI")])
	dbSelectArea("VV1")
	dbSetOrder(2)
	if !dbSeek(xFilial("VV1")+ltrim(aCols[n,FG_POSVAR("VVG_CHASSI")]))
		Return(.f.)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Dados do Veiculos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VV1")
	aCampoVV1 := {}
	While !EOF() .And. (X3_ARQUIVO == "VV1")
		if X3USO(X3_USADO) .and. cNivel >= X3_NIVEL .and. X3_CONTEXT <> "V" .and. !x3_campo $ "VV1_CHASSI#VV1_ESTVEI#VV1_NOMANT#VV1_ENDANT#VV1_CIDANT#VV1_ESTANT#VV1_CEPANT#VV1_DOCIND#VV1_LJPATU#VV1_OBSERV"
			AADD(aCampoVV1,X3_CAMPO)
		Endif
		dbSkip()
	EndDO
	dbSelectarea("VV1")
	For i:=1 to Len(aCampoVV1)
		&("M->"+aCampoVV1[i]) := &(aCampoVV1[i])
	Next
	RegToMemory("VV1",.F.)
	oEnc03:EnchRefreshAll()
Else
	if !Empty(M->VVF_FORPAG)
		FS_FPGAUTO()
	Else
		FS_APAGAFP()
	Endif
	lReturn := .t.
Endif
Return( lReturn )

/////////////////////////////////
Function FS_INIIMP(cCodFor,cLoja)
if Type("aCols") == "U"
	Return(.t.)
Endif
If !MaFisFound('NF')
	If !Empty(cLoja)
		MaFisIni(cCodFor,cLoja,'F','N','R',MaFisRelImp("VEIVM000",{"VVF","VVG"}))
	EndIf
Else
	MaFisRef("NF_CODCLIFOR","VVG00",cCodFor)
	If !Empty(cLoja)
		MaFisRef("NF_LOJA","VVG00",cLoja)
	EndIf
EndIf
Return(.t.)

/////////////////////
Function FS_REFRESH()
Local x_y := 0
If nFolAnt == 1
	If MaFisFound('NF')
		M->VVF_VALMOV := MaFisRet(,"NF_TOTAL")-MAFISRET(1,"IT_DESCZF")
		M->VVF_VBAIPI := 0
		M->VVF_VALIPI := 0
		M->VVF_VBAICM := 0
		M->VVF_TOTICM := 0
		M->VVF_TOTSEG := 0
		M->VVF_TOTFRE := 0
		M->VVF_ICMRET := 0
		M->VVF_DESACE := 0
		For x_y:=1 to Len(aCols)
			if aCols[x_y,Len(aCols[x_y])] .or. Empty(aCols[x_y,FG_POSVAR("VVG_CHASSI")])
				Loop
			Endif
			M->VVF_VBAIPI += MaFisRet(x_y,"IT_BASEIPI")
			M->VVF_VALIPI += MaFisRet(x_y,"IT_VALIPI")
			M->VVF_VBAICM += MaFisRet(x_y,"IT_BASEICM")
			M->VVF_TOTICM += MaFisRet(x_y,"IT_VALICM")
			M->VVF_TOTSEG += MaFisRet(x_y,"IT_SEGURO")
			M->VVF_TOTFRE += MaFisRet(x_y,"IT_FRETE")
			M->VVF_ICMRET += MaFisRet(x_y,"IT_VALSOL")
			M->VVF_DESACE += MaFisRet(x_y,"IT_DESPESA")
		Next
		M->VVF_ALIICM := round((M->VVF_TOTICM/M->VVF_VBAICM)*100,2)
		M->VVF_ALIIPI := round((M->VVF_VALIPI/M->VVF_VBAIPI)*100,2)
		oEnc02:EnchRefreshAll()
		nTotEnt := M->VVF_VALMOV
		cTipPag := M->VVF_FORPAG
		cDesPag := M->VVF_DESFPG
	EndIf
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_CANCENT³ Autor ³  Manoel               ³ Data ³ 31/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cancela Nota Fiscal de Entrada                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCENT()

Local nSavReg, nRecSE2
Local bCampo	:= { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local i_	  := 0
Local cPrefixo := VVF->VVF_SERNFI

if VVF->VVF_OPEMOV == "1" // Pedidos a Fabrica
	
	Begin Transaction
	
	dbSelectArea("VV1")
	FG_Seek("VV1","VVG->VVG_CHAINT",1,.f.)
	While VV1->VV1_CHAINT == VVG->VVG_CHAINT .and. !eof() .and. VV1->VV1_FILIAL == xFilial("VV1")
		WriteSX2("VV1")
		if !RecLock("VV1",.f.,.t.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		DbDelete()
		MsUnlock()
		DbSkip()
	Enddo
	
	dbSelectArea("VVG")
	FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
		WriteSX2("VVG")
		if !RecLock("VVG",.f.,.t.)
			Help("  ",1,"REGNLOCK")
			DisarmTransaction()
			Break
		Endif
		DbDelete()
		MsUnlock()
		DbSkip()
	Enddo
	
	dbSelectArea("VVF")
	WriteSX2("VVF")
	if !RecLock("VVF",.f.,.t.)
		Help("  ",1,"REGNLOCK")
		DisarmTransaction()
		Break
	Endif
	DbDelete()
	MsUnlock()
	
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX6")
	MsRUnLock()
	
Elseif VVF->VVF_OPEMOV $ "03" //Normal
	
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
	
	If !VVF->VVF_SITNFI $ "12"   //Valida/Devolvida
		MsgInfo(STR0151,STR0009) //Nota Fiscal esta cancelada... - Atencao
		Return(.f.)
	Endif
	
	if VVF->VVF_SITNFI == "1"
		ProcRegua(3)
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+VVG->VVG_CHAINT)
		While VV1->VV1_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VV1->VV1_FILIAL == xFilial("VV1")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houve alguma movimentacao deste veiculo nao cancela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if !Empty(VV1->VV1_NUMTRA)
				DbSelectArea("VV0")
				DbSetOrder(1)
				DbSeek(xFilial("VV0")+VV1->VV1_NUMTRA)
				If !VV0->VV0_OPEMOV $ "6.7" // Retorno de Remessa / Retorno de Consignacao
					//FNC- 24537 - Rafael
					IF ((ctod(Left(VVF->VVF_DTHEMI,8)) <= ctod(Left(VV0->VV0_DTHEMI,8))) .and. (Substr(VVF->VVF_DTHEMI,10,8) < Substr(VV0->VV0_DTHEMI,10,8)))
						MsgInfo(STR0152 ,STR0009) //Ja houve movimentacao deste veiculo... - Atencao
						Return(.f.)
					EndIF
				Endif
				
			Endif
			// return .f.
			dbSelectArea("VVG")
			dbSetOrder(1)
			dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			
			dbSelectArea("VV1")
			
			if cParPrg == "1"  //Compra
				if VV1->VV1_SITVEI <> "0" //Estoque
					If SF4->F4_ESTOQUE == "S"
						MsgInfo(STR0153 ,STR0009) //Veiculo nao esta no estoque... - Atencao
						Return(.f.)
					Endif
				Endif
			Endif
			
			if cParPrg == "2"  //Remessa
				if VV1->VV1_SITVEI <> "3" //Remessa
					If SF4->F4_ESTOQUE == "S"
						MsgInfo( STR0153 ,STR0009) //Veiculo nao esta no estoque... - Atencao
						Return(.f.)
					Endif
				Endif
			Endif
			
			if cParPrg == "3"  //Transferencia
				if !VV1->VV1_SITVEI $ "0/5"  //Transferido
					If SF4->F4_ESTOQUE == "S"
						MsgInfo(STR0153	,STR0009) //Veiculo nao esta no estoque...  - Atencao
						Return(.f.)
					Endif
				Endif
			Endif
			
			if cParPrg == "4"  //Consignado
				if VV1->VV1_SITVEI <> "4" //Consignado
					If SF4->F4_ESTOQUE == "S"
						MsgInfo(STR0153,STR0009) //Veiculo nao esta no estoque...  - Atencao
						Return(.f.)
					Endif
				Endif
			Endif
			
			//Veiculo possui conhecimento de frete
			if !FG_Seek("VVG","VV1->VV1_CHAINT",2,.f.)
				Help(" ",1,"ARQITEINCO")
				Return(.f.)
			Endif
			DbSkip()
		Enddo
		
		// Se existir Frete para a NF a ser cancelada, deve-se excluir o Conhecimento para
		// so depois cancelar a NF Entrada. Caso haja mais NF's referente ao Conhecimento,
		// deve-se incluir novamente este Conhecimento para ratear novamente seu valor as
		// NF's restantes
		If !Empty(VVF->VVF_NUMTRA) .and. VVF->VVF_OPEMOV <> "2" // Remessa
			
			lFaz := .t.
			cTraOld := VVF->VVF_TRACPA
			cNumTra := VVF->VVF_NUMTRA
			dbSelectArea("VVF")
			dbSetOrder(1)
			if dbSeek(xFilial("VVF")+cNumTra)
				MsgInfo(STR0102+VVF->VVF_NUMNFI+"-"+ FGX_UFSNF(VVF->VVF_SERNFI) +STR0103,STR0009) //"NF possui frete, o nro do frete e( "###" ) e necessario exclui-lo antes de excluir a NF... caso exista mais NFs sera necessario incluir o frete novamente..."###"Atencao!"
				if MsgYesNo(STR0104,STR0009) // - Atencao //"Cancela o Frete?"
					FS_CANFRETE()
				Else
					lFaz := .f.
				Endif
			Endif
			cTraCpa := cTraOld
			dbSelectArea("VVF")
			dbSetOrder(1)
			dbSeek(xFilial("VVF")+cTraCpa)
			dbSelectArea("VVF")
			For nCntFor := 1 TO FCount()
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Next
			
			dbSelectArea("VVG")
			dbSetOrder(1)
			dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
			dbSelectArea("VVG")
			For nCntFor := 1 TO FCount()
				M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
			Next
			
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+VVG->VVG_CHAINT)
			
			if !lFaz
				Return(.f.)
			Endif
		Endif
		
		Begin Transaction
		
		FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
		
		aCabNFE   := {}
		aIte      := {}
		
		dbSelectArea("VVG")
		FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
		ix_:=1
		While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
			
			FG_Seek("SB1","cGruVei+VVG->VVG_CHAINT",7,.f.)
			
			aItensNFR := {}
			aAdd(aItensNFR,{"D1_DOC"     ,VVF->VVF_NUMNFI,Nil})
			aAdd(aItensNFR,{"D1_SERIE"   ,VVF->VVF_SERNFI,Nil})
			aAdd(aItensNFR,{"D1_FORNECE" ,VVF->VVF_CODFOR,Nil})
			aAdd(aItensNFR,{"D1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
			aAdd(aItensNFR,{"D1_COD"     ,SB1->B1_COD    ,Nil})
			aAdd(aItensNFR,{"D1_ITEM"    ,strzero(ix_,2) ,Nil})
			
			aAdd(aIte,aclone(aItensNFR))
			DbSkip()
			ix_++
			
		Enddo
		
		dbSelectArea("SF1")
		dbSetOrder(1)
		if !dbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			lMsErroAuto := .t.
			
			DisarmTransaction()
			Break
		Endif
		
		//Chave de Pesquisa
		aAdd(aCabNFE,{"F1_DOC"     ,VVF->VVF_NUMNFI,Nil})
		aAdd(aCabNFE,{"F1_SERIE"   ,VVF->VVF_SERNFI,Nil})
		aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
		aAdd(aCabNFE,{"F1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
		
		//Outros Dados da NF
		aAdd(aCabNFE,{"F1_TIPO   " ,SF1->F1_TIPO   ,Nil})
		aAdd(aCabNFE,{"F1_FORMUL " ,SF1->F1_FORMUL ,Nil})
		aAdd(aCabNFE,{"F1_EMISSAO" ,SF1->F1_EMISSAO,Nil})
		aAdd(aCabNFE,{"F1_ESPECIE" ,SF1->F1_ESPECIE,Nil})
		aAdd(aCabNFE,{"F1_COND   " ,RetCondVei()   ,Nil})
		aAdd(aCabNFE,{"F1_EST"     ,SA2->A2_EST    ,Nil})
		
		IncProc(STR0105) //"Cancelando NF de Entrada..."
		If lAbortPrint
			If MsgYesNo((STR0098),(STR0009)) //"Tem certeza que deseja abortar esta operacao ?"###"Atencao"
				Help("  ",1,"M160PROABO")
				lRet := .f.
				DisarmTransaction()
				Break
			Else
				lAbortPrint := .F.
			EndIf
		EndIf
		
		cPrefixo := &(GetNewPar("MV_2DUPREF","cSerie"))
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			cParDup := SF4->F4_DUPLIC
			RecLock("SF4",.f.)
			SF4->F4_DUPLIC := "N"
			MsUnlock()
		Endif
		//
		lMSHelpAuto := .t.
		lMSErroAuto := .f.
		MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIte,5)
		//
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			RecLock("SF4",.f.)
			SF4->F4_DUPLIC := cParDup
			MsUnlock()
		Endif
		
		if lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Break
		Endif
		//
		
		If VVF->VVF_OPEMOV == "0" .and. VS9->(FieldPos("VS9_PARCEL"))>0 //cancelamento de Entrada por Compra
			cQryAl001 := GetNextAlias()
			cQuery := "SELECT VS9.VS9_PARCEL, VS9.VS9_TIPPAG, VS9.VS9_NUMIDE, VS9.R_E_C_N_O_ VS9RECNO, VAZ.R_E_C_N_O_ VAZRECNO FROM "+RetSqlName("VAZ")+" VAZ, "+RetSqlName("VS9")+" VS9"
			cQuery += " WHERE VAZ.VAZ_FILIAL ='"+xFilial("VAZ")+"' AND VAZ.VAZ_TRACPA='" + VVF->VVF_TRACPA + "' AND VAZ.VAZ_FILENT='" + VVF->VVF_FILIAL + "' AND "
			cQuery += " VS9.VS9_FILIAL ='"+xFilial("VS9")+"' AND VS9.VS9_REFPAG = VAZ.VAZ_CODIGO AND"
			cQuery += " VS9.D_E_L_E_T_=' ' AND VAZ.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
			// se o atendimento possui avaliação de usado possivelmente ele foi utilizado como entrada em um atendimento.
			// nesse caso precisamos cancelar a baxa do título a pagar referente ao veiculo
			DBSelectArea("VV0")
			DBSetOrder(1)
			DBSeek(xFilial("VV0") + (cQryAl001)->(VS9_NUMIDE))
			//
			DBSelectArea("SF2")
			DBSetOrder(1)
			if DBSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI)
				while !(cQryAl001)->(eof())
					DBSelectArea("SE1")
					DBSetOrder(1)
					if DBSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL+(cQryAl001)->(VS9_PARCEL)+(cQryAl001)->(VS9_TIPPAG)) .and. !Empty(SE1->E1_BAIXA)
						aBaixa  := {{"E1_PREFIXO"  ,E1_PREFIXO,Nil } ,;
						{"E1_NUM"	  ,E1_NUM                 ,Nil } ,;
						{"E1_PARCELA" ,E1_PARCELA             ,Nil } ,;
						{"E1_TIPO"	  ,E1_TIPO                ,Nil } ,;
						{"AUTMOTBX"	  ,"NOR"                  ,Nil } ,;
						{"AUTDTBAIXA"  ,dDataBase             ,Nil } ,;
						{"AUTDTCREDITO",dDataBase             ,Nil }}
						//
						MSExecAuto({|x,y| FINA070(x,y)},aBaixa,5)
						//
						If lMsErroAuto
							(cQryAl001)->(dbCloseArea())
							DisarmTransaction()
							MostraErro()
							Return .f.
						else
							DBSelectArea("VS9")
							DBGoto((cQryAl001)->(VS9RECNO))
							reclock("VS9",.f.)
							VS9->VS9_DATBAI := ctod("00/00/00")
							msunlock()
							DBSelectArea("VAZ")
							DBGoto((cQryAl001)->(VAZRECNO))
							reclock("VAZ",.f.)
							VAZ->VAZ_TRACPA := ""
							VAZ->VAZ_FILENT := ""
							msunlock()
						EndIf
					endif
					(cQryAl001)->(DBSkip())
				enddo
			endif
			(cQryAl001)->(dbCloseArea())
		Endif
		
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		
		do While !VVG->(Eof()) .and. VVG->VVG_FILIAL == VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
			
			FG_Seek("SB1","cGruVei+VVG->VVG_CHAINT",7,.f.)
			
			FM_LOCVZL(2)
			
			VVG->(dbSkip())
		end
		
		// Traz Negociacao de Pagamento da Venda de Veiculo
		FS_TRAZNEG("N")
		if Len(aIteParc) == 0 .or. (Len(aIteParc)=1 .and. Empty(aIteParc[1,1]))
			aIteParc[1,1] := dDataBase
			aIteParc[1,2] := M->VVF_VALMOV
		Endif
		
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+M->VVF_CODFOR+M->VVF_LOJA)
		
		For i_ := 1 to Len(aIteParc)
			if Empty(aIteParc[i_,1]) .and. aIteParc[i_,2] == 0
				Loop
			Endif
			dbSelectArea("SE2")
			dbSetOrder(1)
			if !dbSeek(xFilial("SE2")+cPrefixo+M->VVF_NUMNFI+Strzero(i_,len(SE2->E2_PARCELA))+"DP "+M->VVF_CODFOR+M->VVF_LOJA)
				Loop
			Endif
			
			// Ponto de Entrada p/ excluir outros titulos
			if ExistBlock("VM000EXC")
				nRecSE2 := Recno()
				ExecBlock("VM000EXC",.f.,.f.)
				dbSelectArea("SE2")
				dbSetOrder(1)
				DbGoto(nRecSE2)
			EndIf
			
			aVetDesp := {}
			aAdd(aVetDesp,{"E2_PREFIXO"  ,cPrefixo,Nil})
			aAdd(aVetDesp,{"E2_NUM"      ,M->VVF_NUMNFI    ,Nil})
			aAdd(aVetDesp,{"E2_TIPO"     ,"DP "               ,Nil})
			aAdd(aVetDesp,{"E2_NATUREZ"  ,SE2->E2_NATUREZ     ,Nil})
			aAdd(aVetDesp,{"E2_PARCELA"  ,Strzero(i_,len(SE2->E2_PARCELA))          ,Nil})
			aAdd(aVetDesp,{"E2_FORNECE"  ,M->VVF_CODFOR      ,Nil})
			aAdd(aVetDesp,{"E2_LOJA"     ,M->VVF_LOJA        ,Nil})
			aAdd(aVetDesp,{"E2_EMISSAO"  ,M->VVF_DATEMI      ,Nil})
			aAdd(aVetDesp,{"E2_VENCTO"   ,aIteParc[i_,1]     ,Nil})
			aAdd(aVetDesp,{"E2_VALOR"    ,aIteParc[i_,2]     ,Nil})
			aAdd(aVetDesp,{"E2_VLCRUZ"   ,aIteParc[i_,2]     ,Nil})
			pergunte("FIN050",.F.)
			lMsHelpAuto := .t.
			lMsErroAuto := .f.
			MSExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp,,5)
			if lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			Endif
		Next
		
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		
		While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
			
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			
			IncProc(STR0105)         //Cancelando NF de Entrada...
			dbSelectArea("VV1")
			FG_Seek("VV1","M->VVG_CHASSI",2,.f.)
			if Type("cTipSai") <> "U"
				if cTipSai == "3"
					RecLock("VV1",.f.)
					If SF4->F4_ESTOQUE == "S"
						VV1->VV1_SITVEI := "3"   //Veiculo em Remessa
					Endif
					MsUnlock()
					RecLock("VV0",.f.)
					VV0->VV0_SITNFI := "1"    // Valida
					VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
					MsUnlock()
				Endif
			Endif
			aQUltMovS := FM_VEIUMOV( VVG->VVG_CHASSI , "S" )
			cUltSitVei := " "
			if Len(aQUltMovS) > 0
				Do Case
					Case aQUltMovS[4]=="0"
						cUltSitVei := "1"
					Case aQUltMovS[4]=="1"
						cUltSitVei := "0"
					Case aQUltMovS[4]=="2"
						cUltSitVei := "2"
					Case aQUltMovS[4]=="3"
						cUltSitVei := "3"
					Case aQUltMovS[4]=="4"
						cUltSitVei := " "
					Case aQUltMovS[4]=="5"
						cUltSitVei := "4"
					Case aQUltMovS[4]=="6"
						cUltSitVei := "7"
					Case aQUltMovS[4]=="7"
						cUltSitVei := "8"
				EndCase
			endif
			
			if Type("cTipSai") == "U"
				FG_Seek("VV1","VVG->VVG_CHASSI",2,.f.)
				dbSelectArea("VV1")
				RecLock("VV1",.f.)
				VV1->VV1_TRACPA := Space(10)
				VV1->VV1_SITVEI := cUltSitVei   // Veiculo somente no cadastro
				VV1->VV1_TIPENT := " "   		// Apaga Tipo de Entrada
				MsUnlock()
			Endif
			
			dbSelectArea("VVG")
			DbSkip()
		Enddo
		
		dbSelectArea("VVF")
		WriteSX2("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_SITNFI := "0"
		MsUnlock()
		
		IncProc(STR0105) //"Cancelando NF de Entrada..."
		
		End Transaction
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX6")
		MsRUnLock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualizando Ultima Mov. do Veiculo                                                               ³
		//³OBS: Esta fora da Transacao pois senao o VVF_SITNFI fica com '1' quando esta no meio da transacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		Do While !VVG->(Eof()) .and. VVG->VVG_FILIAL == VVF->VVF_FILIAL .and. VVG->VVG_TRACPA == VVF->VVF_TRACPA
			FGX_AMOVVEI(xFilial("VV1"),VVG->VVG_CHASSI)
			If FindFunction("VXX04REVJ1")
				VXX04REVJ1(VVG->VVG_CHASSI,"","0")//realiza o cancelamento da reserva do veiculo
			EndIf
			VVG->(dbSkip())
		end
		
		
	endif
Elseif VVF->VVF_OPEMOV == "5" //Devolucao
	
	ProcRegua(2)
	
	dbSelectArea("SD1")
	dbSetOrder(1)
	cIdeSB6 := space(6)
	if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
		cIdeSB6 := SD1->D1_IDENTB6
	Endif
	
	FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	FG_Seek("VV1","VVG->VVG_CHAINT",1,.f.)
	
	//Veiculo ja foi Vendido
	if VV1->VV1_SITVEI <> "0"
		Help(" ",1,"VEICSNESTQ")
		DisarmTransaction()
		Break
	Endif
	FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
	
	
	Begin Transaction
	
	
	FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	FG_Seek("VV1","VVG->VVG_CHAINT",1,.f.)
	
	//Veiculo ja foi Vendido
	if VV1->VV1_SITVEI <> "0"
		Help(" ",1,"VEICSNESTQ")
		DisarmTransaction()
		Break
	Endif
	FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
	
	aCabNFE   := {}
	aIte      := {}
	
	
	dbSelectArea("VVG")
	FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	FG_Seek("SB1","cGruVei+VV1->VV1_CHAINT",7,.f.)
	FG_Seek("SF4","VVG->VVG_CODTES",1,.f.)
	ix_:=1
	While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
		aItensNFR := {}
		aAdd(aItensNFR,{"D1_DOC"     ,VVF->VVF_NUMNFI,Nil})
		aAdd(aItensNFR,{"D1_SERIE"   ,VVF->VVF_SERNFI,Nil})
		aAdd(aItensNFR,{"D1_FORNECE" ,VVF->VVF_CODFOR,Nil})
		aAdd(aItensNFR,{"D1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
		aAdd(aItensNFR,{"D1_COD"     ,SB1->B1_COD    ,Nil})
		aAdd(aItensNFR,{"D1_ITEM"    ,strzero(ix_,2) ,Nil})
		if SF4->F4_PODER3 == "D"
			dbSelectArea("SB6")
			dbSetOrder(3)
			if dbSeek(xFilial("SB6")+cIdeSB6+VVG->VVG_CHAINT+space(9))
				aAdd(aItensNFR,{"D1_IDENTB6" ,SB6->B6_IDENT,Nil})
			Endif
			dbSelectArea("VVG")
		Endif
		
		aAdd(aIte,aclone(aItensNFR))
		dbSkip()
		ix_++
	Enddo
	
	cFormul := "N"  //if(VVF->VVF_FORPRO == "1","S","N")
	
	aAdd(aCabNFE,{"F1_DOC"     ,VVF->VVF_NUMNFI,Nil})
	aAdd(aCabNFE,{"F1_SERIE"   ,VVF->VVF_SERNFI,Nil})
	aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
	aAdd(aCabNFE,{"F1_LOJA"    ,VVF->VVF_LOJA  ,Nil})
	aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
	aAdd(aCabNFE,{"F1_COND"    ,RetCondVei()   ,Nil})
	aAdd(aCabNFE,{"F1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
	aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
	aAdd(aCabNFE,{"F1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
	If VVF->(FieldPos("VVF_TRANSP")) > 0
		If !Empty(VVF->VVF_TRANSP)
			aAdd(aCabNFE,{"F1_TRANSP"  ,VVF->VVF_TRANSP  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_ESPEC1")) > 0
		If !Empty(VVF->VVF_ESPEC1)
			aAdd(aCabNFE,{"F1_ESPECI1",VVF->VVF_ESPEC1  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_VOLUM1")) > 0
		If !Empty(VVF->VVF_VOLUM1)
			aAdd(aCabNFE,{"F1_VOLUME1" ,VVF->VVF_VOLUM1  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_ESPEC2")) > 0
		If !Empty(VVF->VVF_ESPEC2)
			aAdd(aCabNFE,{"F1_ESPECI2",VVF->VVF_ESPEC2  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_VOLUM2")) > 0
		If !Empty(VVF->VVF_VOLUM2)
			aAdd(aCabNFE,{"F1_VOLUME2" ,VVF->VVF_VOLUM2  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_ESPEC3")) > 0
		If !Empty(VVF->VVF_ESPEC3)
			aAdd(aCabNFE,{"F1_ESPECI3",VVF->VVF_ESPEC3  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_VOLUM3")) > 0
		If !Empty(VVF->VVF_VOLUM3)
			aAdd(aCabNFE,{"F1_VOLUME3" ,VVF->VVF_VOLUM3  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_ESPEC4")) > 0
		If !Empty(VVF->VVF_ESPEC4)
			aAdd(aCabNFE,{"F1_ESPECI4",VVF->VVF_ESPEC4  ,Nil})
		EndIf
	EndIf
	If VVF->(FieldPos("VVF_VOLUM4")) > 0
		If !Empty(VVF->VVF_VOLUM4)
			aAdd(aCabNFE,{"F1_VOLUME4" ,VVF->VVF_VOLUM4  ,Nil})
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 17/03/2010                                  ³
	//³Gravar o VVF_ESPECI se o usuario nao especificar nada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if VVF->(FieldPos("VVF_ESPECI")) <> 0 .and. !Empty(VVF->VVF_ESPECI)
		aAdd(aCabNFE,{"F1_ESPECIE" , VVF->VVF_ESPECI ,Nil})
	else
		aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
	endif
	aAdd(aCabNFE,{"F1_EST"     ,SA2->A2_EST    ,Nil})
	
	if Type("cTipSai") <> "U" .and. cTipSai == "3"
		aAdd(aCabNFE,{"F1_TIPO","D",Nil})
	Else
		aAdd(aCabNFE,{"F1_TIPO","D",Nil})
	Endif
	
	IncProc(STR0105)   // Cancelando NF de Entrada...
	If lAbortPrint
		if MsgYesNo((STR0098),(STR0009))   // Tem certeza que deseja abortar esta operacao ?
			Help("  ",1,"M160PROABO")
			lRet := .f.
			DisarmTransaction()
			Break
		Else
			lAbortPrint := .F.
		EndIf
	EndIf
	
	dbSelectArea("SF4")
	dbSetOrder(1)
	if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
		cParDup := SF4->F4_DUPLIC
		RecLock("SF4",.f.)
		SF4->F4_DUPLIC := "N"
		MsUnlock()
	Endif
	lMSHelpAuto := .t.
	lMSErroAuto := .f.
	MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIte,5)
	
	dbSelectArea("SF4")
	dbSetOrder(1)
	if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
		RecLock("SF4",.f.)
		SF4->F4_DUPLIC := cParDup
		MsUnlock()
	Endif
	
	if lMsErroAuto
		MostraErro()
		DisarmTransaction()
		Break
	Endif
	/* Grava valor de Pis e Cofins no SD1, pois o calculo para veiculos e diferente do padrao */
	FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
	dbSelectArea("VVG")
	FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	
	While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
		
		FG_Seek("SB1","cGruVei+VVG->VVG_CHAINT",7,.f.)
		
		// Atualiza Localizacao de Veiculo
		FM_LOCVZL(2)
		
		dbSelectArea("SD1")
		dbSetOrder(1)
		if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
			RecLock("SD1",.f.)
			if VVG->VVG_PICOSB == "1" // Tem Pis/Cofins de Substituicao
				nBasePC := VVG->VVG_VALUNI + VVG->VVG_VALDES + VVG->VVG_TOTSEG + VVG->VVG_DESACE + VVG->VVG_TOTFRE + VVG->VVG_VALIPI
			Else
				nBasePC := 0
			Endif
			FG_SEEK("SF4","VVG->VVG_CODTES",1,.f.)
			if !(VVG->VVG_PISENT+VVG->VVG_COFENT > 0)
				aPisCof := CalcPisCofEnt(nBasePC)
				GrvPisCof(nBasePc,aPiscof,"E")
			Endif
			MsUnlock()
		EndIF
		VVG->(DbSkip())
	EndDo
	/*-----------------------------------------------------------------------------------------*/
	
	dbSelectArea("VVF")
	RecLock("VVF",.f.)
	VVF->VVF_SITNFI := "0"    // Cancelada
	VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
	MsUnlock()
	
	FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
	if FG_Seek("VV1","VVG->VVG_CHAINT",1,.f.)
		RecLock("VV1",.f.)
		VV1->VV1_FILIAL := xFilial("VV1")
		VV1->VV1_SITVEI := "1"   // Vendido
		MsUnlock()
	Endif
	
	if Type("cTipSai") <> "U"
		if cTipSai == "3"
			RecLock("VV1",.f.)
			If SF4->F4_ESTOQUE == "S"
				VV1->VV1_SITVEI := "3"   //Veiculo em Remessa
			Endif
			MsUnlock()
			RecLock("VV0",.f.)
			VV0->VV0_SITNFI := "1"    // Valida
			VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
			MsUnlock()
		Endif
	Endif
	
	RecLock("VV0",.f.)
	VV0->VV0_SITNFI := "1"    // Valida
	VV0->VV0_DATUSU := Dtos(dDataBase)+"-"+__cUserID
	VV0->VV0_TRADEV := ""
	MsUnlock()
	
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX6")
	MsRUnLock()
	
	// Atualiza Ultima Movimentacao do Veiculo e Proprietario Atual
	// Fora da transacao propositalmente, pois dentro da transacao
	// o SELECT nao considerava o movimento com o valor de VVF_SITNFI = 0
	FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
	If FindFunction("VXX04REVJ1")
		VXX04REVJ1(VVG->VVG_CHASSI,"","0")//realiza o cancelamento da reserva do veiculo
	EndIf
	
Elseif VVF->VVF_OPEMOV $ "24" //Remessa e Consignado
	
	Begin Transaction
	
	If !VVF->VVF_SITNFI $ "12"   //Valida/Devolvida
		MsgInfo(STR0151,STR0009) //Nota Fiscal esta cancelada... - Atencao
		Return(.f.)
	Endif
	
	dbSelectArea("VVG")
	dbSetOrder(1)
	if !dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
		DisarmTransaction()
		Break
	Endif
	
	if VVF->VVF_SITNFI == "1"
		
		dbSelectArea("SD1")
		dbSetOrder(1)
		cIdeSB6 := space(6)
		if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
			cIdeSB6 := SD1->D1_IDENTB6
		Endif
		
		FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
		FG_Seek("VV1","VVG->VVG_CHAINT",1,.f.)
		FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
		FG_Seek("SB1","cGruVei+VV1->VV1_CHAINT",7,.f.)
		FG_Seek("SF4","VVG->VVG_CODTES",1,.f.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Significa que o veiculo nao esta na situacao correta  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		if !VV1->VV1_SITVEI $ "34"
			If SF4->F4_ESTOQUE == "S"
				MsgInfo(STR0153 ,STR0009) //Veiculo nao esta no estoque... - Atencao
				DisarmTransaction()
				Break
			Endif
		Endif
		
		aCabNFE   := {}
		aIte      := {}
		
		dbSelectArea("VVG")
		ix_:=1
		While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
			aItensNFR := {}
			aAdd(aItensNFR,{"D1_DOC"     ,VVF->VVF_NUMNFI,Nil})
			aAdd(aItensNFR,{"D1_SERIE"   ,VVF->VVF_SERNFI,Nil})
			aAdd(aItensNFR,{"D1_FORNECE" ,VVF->VVF_CODFOR,Nil})
			aAdd(aItensNFR,{"D1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
			aAdd(aItensNFR,{"D1_COD"     ,SB1->B1_COD    ,Nil})
			aAdd(aItensNFR,{"D1_ITEM"    ,strzero(ix_,2) ,Nil})
			aAdd(aItensNFR,{"D1_IDENTB6" ,cIdeSB6        ,Nil})
			aAdd(aIte,aclone(aItensNFR))
			dbSkip()
			ix_++
		Enddo
		SF1->(dbSetOrder(1))
		If VVF->VVF_FORPRO == "0" //Formulario Proprio = Nao
			cFormul := "N"
		Else
			cFormul := "S"
		Endif
		if ! SF1->(dbSeek(xFilial("SF1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA))
			aAdd(aCabNFE,{"F1_TIPO"    ,"D"            ,Nil})
		Else
			aAdd(aCabNFE,{"F1_TIPO"    ,SF1->F1_TIPO   ,Nil})
		Endif
		aAdd(aCabNFE,{"F1_DOC"     ,VVF->VVF_NUMNFI,Nil})
		aAdd(aCabNFE,{"F1_SERIE"   ,VVF->VVF_SERNFI,Nil})
		aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
		aAdd(aCabNFE,{"F1_LOJA"    ,VVF->VVF_LOJA  ,Nil})
		aAdd(aCabNFE,{"F1_FORMUL"  ,cFormul        ,Nil})
		aAdd(aCabNFE,{"F1_COND"    ,RetCondVei()   ,Nil})
		aAdd(aCabNFE,{"F1_EMISSAO" ,VVF->VVF_DATEMI,Nil})
		aAdd(aCabNFE,{"F1_FORNECE" ,VVF->VVF_CODFOR,Nil})
		aAdd(aCabNFE,{"F1_LOJA   " ,VVF->VVF_LOJA  ,Nil})
		if VVF->(FieldPos("VVF_TRANSP")) > 0
			if !Empty(VVF->VVF_TRANSP)
				aAdd(aCabNFE,{"F1_TRANSP"  ,M->VVF_TRANSP  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_ESPEC1")) > 0
			if !Empty(M->VVF_ESPEC1)
				aAdd(aCabNFE,{"F1_ESPECI1",M->VVF_ESPEC1  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_VOLUM1")) > 0
			if !Empty(M->VVF_VOLUM1)
				aAdd(aCabNFE,{"F1_VOLUME1" ,M->VVF_VOLUM1  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_ESPEC2")) > 0
			if !Empty(M->VVF_ESPEC2)
				aAdd(aCabNFE,{"F1_ESPECI2",M->VVF_ESPEC2  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_VOLUM2")) > 0
			if !Empty(M->VVF_VOLUM2)
				aAdd(aCabNFE,{"F1_VOLUME2" ,M->VVF_VOLUM2  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_ESPEC3")) > 0
			if !Empty(M->VVF_ESPEC3)
				aAdd(aCabNFE,{"F1_ESPECI3",M->VVF_ESPEC3  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_VOLUM3")) > 0
			if !Empty(M->VVF_VOLUM3)
				aAdd(aCabNFE,{"F1_VOLUME3" ,M->VVF_VOLUM3  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_ESPEC4")) > 0
			if !Empty(M->VVF_ESPEC4)
				aAdd(aCabNFE,{"F1_ESPECI4",M->VVF_ESPEC4  ,Nil})
			Endif
		Endif
		if VVF->(FieldPos("VVF_VOLUM4")) > 0
			if !Empty(M->VVF_VOLUM4)
				aAdd(aCabNFE,{"F1_VOLUME4" ,M->VVF_VOLUM4  ,Nil})
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 17/03/2010                                  ³
		//³Gravar o VVF_ESPECI se o usuario nao especificar nada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if VVF->(FieldPos("VVF_ESPECI")) <> 0 .and. !Empty(VVF->VVF_ESPECI)
			aAdd(aCabNFE,{"F1_ESPECIE" , VVF->VVF_ESPECI ,Nil})
		else
			aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
		endif
		aAdd(aCabNFE,{"F1_EST"     ,SA2->A2_EST    ,Nil})
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			cParDup := SF4->F4_DUPLIC
			RecLock("SF4",.f.)
			SF4->F4_DUPLIC := "N"
			MsUnlock()
		Endif
		lMSHelpAuto := .t.
		lMSErroAuto := .f.
		MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIte,5)
		
		dbSelectArea("SF4")
		dbSetOrder(1)
		if dbSeek(xFilial("SF4")+VVG->VVG_CODTES)
			RecLock("SF4",.f.)
			SF4->F4_DUPLIC := cParDup
			MsUnlock()
		Endif
		
		if lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Break
		Endif
		
		/* Grava valor de Pis e Cofins no SD1, pois o calculo para veiculos e diferente do padrao */
		FG_Seek("SA2","VVF->VVF_CODFOR+VVF->VVF_LOJA",1,.f.)
		dbSelectArea("VVG")
		FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
		
		While VVG->VVG_TRACPA == VVF->VVF_TRACPA .and. !eof() .and. VVG->VVG_FILIAL == xFilial("VVG")
			
			FG_Seek("SB1","cGruVei+VVG->VVG_CHAINT",7,.f.)
			
			dbSelectArea("SD1")
			dbSetOrder(1)
			if dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
				RecLock("SD1",.f.)
				if VVG->VVG_PICOSB == "1" // Tem Pis/Cofins de Substituicao
					nBasePC := VVG->VVG_VALUNI + VVG->VVG_VALDES + VVG->VVG_TOTSEG + VVG->VVG_DESACE + VVG->VVG_TOTFRE + VVG->VVG_VALIPI
				Else
					nBasePC := 0
				Endif
				FG_SEEK("SF4","VVG->VVG_CODTES",1,.f.)
				if !(VVG->VVG_PISENT+VVG->VVG_COFENT > 0)
					aPisCof := CalcPisCofEnt(nBasePC)
					GrvPisCof(nBasePc,aPiscof,"E")
				Endif
				MsUnlock()
			EndIF
			VVG->(DbSkip())
		EndDo
		/*-----------------------------------------------------------------------------------------*/
		
		
		dbSelectArea("VVF")
		RecLock("VVF",.f.)
		VVF->VVF_SITNFI := "0" //Cancelada
		VVF->VVF_DATUSU := Dtos(dDataBase)+"-"+__cUserID
		MsUnlock()
		
		FG_Seek("VVG","VVF->VVF_TRACPA",1,.f.)
		FG_Seek("VV1","VVG->VVG_CHAINT",1,.f.)
		FG_SEEK("SF4","VVG->VVG_CODTES",1,.f.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui Cabecalho da Nota de Retorno                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VVF")
		//		RecLock("VVF",.f.,.t.)
		//		dbDelete()
		//		MsUnlock()
		reclock("VVF",.f.)
		VVF->VVF_SITNFI := "0"
		msunlock()
		WriteSx2("VVF")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exclui Item da Nota de Retorno                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VVG")
		//		RecLock("VVG",.f.,.t.)
		//		dbDelete()
		//		MsUnlock()
		//		WriteSx2("VVG")
		
		RecLock("VV1",.f.)
		If SF4->F4_ESTOQUE == "S"
			VV1->VV1_SITVEI := " "
		Endif
		VV1->VV1_TRACPA := Space(10)
		MsUnlock()
		
	Endif
	
	End Transaction
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX6")
	MsRUnLock()
	
	if lMsErroAuto
		MostraErro()
	Endif
	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_AlmVei ³ Autor ³  Manoel               ³ Data ³ 27/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Oferece Almoxarifado do Veiculo                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AlmVei()
Local lTesvazio

if Type("lVX000Auto") != "U"
	if lVX000Auto
		return .t.
	endif
endif

lTesvazio := Empty(M->VVG_CODTES)
if cParPrg $ "1235"
	if M->VVG_ESTVEI == "0" .and. Trim(GETMV("MV_LOCVEIN")) <> ""
		M->VVG_LOCPAD := GETMV("MV_LOCVEIN")
	Elseif  M->VVG_ESTVEI == "1" .and. Trim(GETMV("MV_LOCVEIU")) <> ""
		M->VVG_LOCPAD := GETMV("MV_LOCVEIU")
	Else
		M->VVG_LOCPAD := "  "
	Endif
	If lTesvazio
		Do Case
			Case cParPrg $ "1"
				M->VVG_CODTES := "   "//"011"
			Case cParPrg $ "2"
				M->VVG_CODTES := "   "
			Case cParPrg $ "3"
				M->VVG_CODTES := "   "//"023"
		EndCase
	Endif
Elseif cParPrg == "4"
	if !Empty(GETMV("MV_LOCVEIC"))
		M->VVG_LOCPAD := GETMV("MV_LOCVEIC")
	Endif
	If lTesVazio
		M->VVG_CODTES := "   " //"007"
	Endif
Endif
If !Empty(VV1->VV1_LOCPAD)
	M->VVG_LOCPAD := VV1->VV1_LOCPAD
EndIf
DbSelectArea("NNR")
DbSetOrder(1)
DbSeek(xFilial("NNR")+M->VVG_LOCPAD)
aCols[n,FG_POSVAR("VVG_LOCPAD")] := M->VVG_LOCPAD
aCols[n,FG_POSVAR("VVG_CODTES")] := M->VVG_CODTES
oGetDados:oBrowse:Refresh(.t.)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GRAVANEG   ³ Autor ³ Andre                 ³ Data ³ 30/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as parcelas da negociacao                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Function FS_GRAVANEG(cTipo)
Local i := 0
dbSelectArea("VS9")
dbSetOrder(1)
For i:=1 to Len(aIteParc)
	if Empty(aIteParc[i,1])
		Exit
	Endif
	lAcha := dbSeek(xfilial("VS9")+M->VVF_TRACPA+cTipo+'DP')
	RecLock("VS9",!lAcha)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := M->VVF_TRACPA
	VS9->VS9_TIPOPE := cTipo
	VS9->VS9_SEQUEN := StrZero(i,2)
	VS9->VS9_TIPPAG := "DP"
	//	VS9->VS9_DESPAG := "DUPLICATA"
	VS9->VS9_DATPAG := DataValida(aIteParc[i,1])
	VS9->VS9_VALPAG := aIteParc[i,2]
	if !Empty(cCondic1) .and. !Empty(cCondic3)
		VS9->VS9_REFPAG := alltrim(dtoc(cCondic1))+strzero(val(cCondic2),2)+strzero(val(cCondic3),2)+strzero(val(cCondic4),2)
	Endif
	MsUnlock()
Next
if Len(aIteParc) == 0 .or. (Len(aIteParc)=1 .and. Empty(aIteParc[1,1]))
	aIteParc[1,1] := dDataBase
	aIteParc[1,2] := M->VVF_VALMOV
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_TRAZNEG    ³ Autor ³ Andre                 ³ Data ³ 30/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz as parcelas da negociacao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TRAZNEG(cTipo)
Local nTamDat := len(Transform(dDataBase,"@D"))
aIteParc := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array de Financiamento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xfilial("VS9")+Left(M->VVF_TRACPA+Space(20),len(VS9->VS9_NUMIDE))+cTipo+'DP')
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. VS9->VS9_NUMIDE == Left(M->VVF_TRACPA+Space(20),len(VS9->VS9_NUMIDE)) .and. VS9->VS9_TIPOPE == cTipo
		If VS9->VS9_TIPPAG == "DP"  //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG) .and. inclui
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,nTamDat))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,02)
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
			aAdd(aIteParc,{VS9->VS9_DATPAG,VS9->VS9_VALPAG})
		Endif
		DbSkip()
	Enddo
Endif
if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif
Return

/////////////////////
Function FS_FPGAUTO()
Local nValor
If inclui
	if MaFisFound('NF')
		nValor := MaFisRet(,"NF_TOTAL")-MAFISRET(,"NF_DESCZF")
	Else
		nValor := M->VVF_VALMOV
	Endif
	lSalvou := .f.
	if Empty(M->VVF_FORPAG)
		if !Empty(cCondic1) .and. !Empty(cCondic3) .and. !Empty(cCondic4)
			M->VVF_FORPAG := RetCondVei()
		Endif
	Endif
	If Empty(cCondic1)
		cCondic1 := M->VVF_DATEMI
	Endif
	FG_Condicao(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,cTipPag1,nValor,cTipOpe)
Endif
Return(.t.)

///////////////////////////
Function FS_APAGAFP(lApaga)
lSalvou := .f.
FG_DesfPag()
cCondic1:=ctod(" ")
cCondic2:=space(02)
cCondic3:=space(02)
cCondic4:=space(02)
if lApaga <> Nil
	M->VVF_FORPAG := Space(3)
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM000VERNF³Autor³ Andre Luis Almeida          ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Verifica se NF existe para determinado Fornecedor            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM000VERNF(cPesq)
Local nRecSM0 := SM0->(Recno())
Local cEmpres := SM0->M0_CODIGO
Local aFil    := {}
Local lRet := .t.
Local ni   := 0
aAdd( aFil , { "  " , "" })
DbSelectArea("SM0")
DbGoTop()
Do While !Eof()
	If cEmpres == SM0->M0_CODIGO
		aAdd( aFil , { SM0->M0_CODFIL , SM0->M0_FILIAL })
	EndIf
	DbSkip()
EndDo
DbGoTo(nRecSM0)
dbSelectArea("SF1")
dbSetOrder(1)
For ni := 1 to Len(aFil)
	if dbSeek(aFil[ni,1]+cPesq)
		MsgInfo(STR0154,STR0009) //"NF de Entrada ja existe para este fornecedor! - Atencao
		lRet := .f.
		Exit
	Endif
Next
Return(lRet)

////////////////////////////////////////////
Function VM000TE()
If M->VVG_CODTES <> SF4->F4_CODIGO
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+M->VVG_CODTES)
Endif
If SF4->F4_ESTOQUE <> "S"
	If !MsgYesNo(STR0157,STR0009)
		Return .f.
	Endif
Endif
If left(Funname(),5) == "VEIVM" // Manoel - 19/05/2010 - o VEIX estava chamando esta funcao atraves do X3_VALID
	FS_REFRESH()
Endif
Return .t.

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VM000DCAR³ Autor ³ Boby                  ³ Data ³ 18/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preencher conteudo do campo VVG_DIACAR atraves do campo    ³±±
±±³          ³ VVG_CODIND - FNC 16963                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function VM000DCAR()
LOCAL aArea := GetArea()
Local lRet  := .T.
//FNC 16963 - BOBY - Implementacao do campo VVG_DIACAR na 11 e preencher o campo ao informar o VVG_CODIND - 18/08/2010
DbSelectArea("VVG")
DbSetOrder(1)
if VVG->(FieldPos("VVG_DIACAR")) > 0
	aCols[n,FG_POSVAR("VVG_DIACAR")] := M->VVG_DIACAR := Posicione("VVH",1,xFilial("VVH")+M->VVG_CODIND,"VVH_DIACAR")
Endif
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FS_RATEIO³Autor³ Andre Luis Almeida          ³Data³ 26/06/15 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Rateio por Centro de Custo                                   ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RATEIO()
Local aHeadSDE  := {}
Local aColsSDE  := {}
Local ni        := 0
Local ny        := 0
//
Private aCols	:= {}
Private aHeader := {}
Private n       := 1
//
l103Auto    := .F.				// MATA103X
cSerie      := M->VVF_SERNFI	// MATA103X
cNFiscal    := M->VVF_NUMNFI	// MATA103X
cTipo       := ""				// MATA103X
l116Inclui	:= .T.
l103Visual	:= .F.
INCLUI      := .T.
ALTERA      := .F.
//
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SD1")
While !Eof() .And. (SX3->X3_ARQUIVO == "SD1")
	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. AllTrim(SX3->X3_CAMPO) <> "D1_GERAPV" .And. AllTrim(SX3->X3_CAMPO) <> "D1_ITEMMED"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CAT83 - Nao adiciona campo ao aCols se parametro estiver desligado  | 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Trim(SX3->X3_CAMPO)="D1_CODLAN" .And. !SuperGetMv("MV_CAT8309",.F.,.F.) 		
			dbSelectArea("SX3")
			dbSkip()
			Loop
		EndIF
		aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo
//
DbSelectArea("VV1")
DbSetOrder(2) // VV1_FILIAL+VV1_CHASSI
//
DbSelectArea("SD1")
DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
//
ADHeadRec("SD1",aHeader)
For ni := 1 to len(aStruNFR)
	If aStruNFR[ni,1] // NF Selecionada
		aadd(aCols,	Array(Len(aHeader)+1))
		VV1->(DbSeek(xFilial("VV1")+ltrim(aStruNFR[ni,8])))
		SD1->(DbSeek(xFilial("SD1")+aStruNFR[ni,3]+aStruNFR[ni,2]+aStruNFR[ni,5]+cGruVei+"_"+VV1->VV1_CHAINT))
		For ny := 1 to len(aHeader)
			If aHeader[nY,10] <> "V"
				aCols[len(aCols),ny] := &("SD1->"+aHeader[ny,2])
			EndIf
		Next
		aCols[len(aCols),len(aHeader)+1] := .f.
	EndIf
Next
//
If Len(aCols) > 0
	NfeRatCC(aHeadSDE,aColsSDE,.T.)
	aColsRATCC := aClone(aColsSDE)
Else
	MsgInfo(STR0176 ,STR0009) 
Endif
//
l103Auto := .T. // MATA103X
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ FS_SELVEIº Autor ³ Thiago				        º Data ³ 05/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Selecao dos Veiculos.											           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_SELVEI(cChassi,cNota,cSerie,cFornece,cLoja)
Local cSQLAlias := "SQLVVF"  
Local cGruVei  := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))

nNUMTRA := len(VVF->VVF_NUMTRA)
cQuery := "SELECT VV1.VV1_CHAINT , VV1.VV1_CHASSI , VVF.VVF_NUMNFI, VVF.VVF_SERNFI , VVF.VVF_CODFOR , VVF.VVF_LOJA , VVG.VVG_CODTES , SA2.A2_NOME "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
cQuery += "JOIN "+RetSqlName("VVG")+" VVG ON VVG.VVG_FILIAL = '"+xFilial("VVG")+ "' AND VVG.VVG_CHAINT = VV1.VV1_CHAINT AND VVG.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+RetSqlName("VVF")+" VVF ON VVF.VVF_FILIAL = '"+xFilial("VVF")+ "' AND VVF.VVF_NUMTRA = '"+space(nNUMTRA)+"' AND VVF.VVF_NUMNFI='"+cNota+ "' AND VVF.VVF_SERNFI = '"+cSerie+"' AND VVF.VVF_CODFOR = '"+cFornece+"' AND VVF.VVF_LOJA = '"+cLoja+"' AND VVF.VVF_SITNFI = '1' AND VVF.VVF_DATMOV <= '"+dtos(M->VVF_DATMOV)+"' AND VVF.VVF_OPEMOV <> '6' AND VVF.VVF_TRACPA = VVG.VVG_TRACPA AND VVF.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL = '"+xFilial("SF1")+ "' AND SF1.F1_DOC = VVF.VVF_NUMNFI AND SF1.F1_SERIE = VVF.VVF_SERNFI AND SF1.F1_FORNECE = VVF.VVF_CODFOR AND SF1.F1_LOJA = VVF.VVF_LOJA AND SF1.F1_TIPO = 'N' AND SF1.D_E_L_E_T_ = ' ' "
cQuery += "JOIN "+RetSQLName("SA2")+" SA2 ON  SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND SA2.A2_COD = VVF.VVF_CODFOR AND SA2.A2_LOJA = VVF.VVF_LOJA AND SA2.D_E_L_E_T_=' ' "
cQuery += "WHERE VV1.VV1_SITVEI = '0' "
cQuery += "AND VV1.VV1_FILIAL = '"+xFilial("VV1")+ "' AND VV1.VV1_CHASSI = '"+Alltrim(cChassi)+"' "
cQuery += "AND VV1.D_E_L_E_T_ = ' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !( cSQLAlias )->( Eof() )
	aadd(aIteVei,{ ( cSQLAlias )->( VV1_CHAINT ) , ( cSQLAlias )->( VV1_CHASSI ) , ( cSQLAlias )->( VVF_NUMNFI ) , ( cSQLAlias )->( VVF_SERNFI ) , ( cSQLAlias )->( VVF_CODFOR )+"/"+( cSQLAlias )->( VVF_LOJA )+" - "+( cSQLAlias )->( A2_NOME ),space(TamSX3("VVG_OPER")[1]),M->VVF_TESFRE,cGruVei,M->VVF_ALIICM} )
	( cSQLAlias )->( dbSkip() )
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("VVF")
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ FS_SELVEIº Autor ³ Thiago				        º Data ³ 05/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Selecao dos Veiculos.											           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_SELVEI1()
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, {  0 ,  0 , .T. , .T. } ) // ListBox Veiculos
aPos := MsObjSize( aInfo, aObjects )
If len(aIteVei) > 0
	DEFINE MSDIALOG oDlgSELVEI TITLE STR0164 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL
	@ aPos[1,1]+000,aPos[1,2]+000 LISTBOX oLbIteVei FIELDS HEADER STR0165,STR0166,STR0167,STR0168,STR0172,STR0169,RetTitle("VVF_ALIICM") COLSIZES 30,80,120,40,60,60,60 SIZE aPos[1,4]-aPos[1,2],aPos[1,3]-aPos[1,1] OF oDlgSELVEI PIXEL ON DBLCLICK FS_OPER(aIteVei[oLbIteVei:nAt,6],aIteVei[oLbIteVei:nAt,7],aIteVei[oLbIteVei:nAt,5],aIteVei[oLbIteVei:nAt,1],oLbIteVei:nAt,aIteVei[oLbIteVei:nAt,9])
	oLbIteVei:SetArray(aIteVei)
	oLbIteVei:bLine := { || { aIteVei[oLbIteVei:nAt,1],;
									  aIteVei[oLbIteVei:nAt,2],;
									  aIteVei[oLbIteVei:nAt,3]+"/"+aIteVei[oLbIteVei:nAt,4],;
									  aIteVei[oLbIteVei:nAt,5],;
									  aIteVei[oLbIteVei:nAt,6],;
									  aIteVei[oLbIteVei:nAt,7],;
									  Transform(aIteVei[oLbIteVei:nAt,9],X3Picture("VVF_ALIICM"))}}

	ACTIVATE MSDIALOG oDlgSELVEI CENTER ON INIT EnchoiceBar(oDlgSELVEI, { || nOpca := 1, oDlgSELVEI:End() } , { || nOpca := 2, oDlgSELVEI:End() } )
	If nOpca == 1 // OK Tela
		aRetorno := aClone(aIteVei)
	Else
		aRetorno := {}
	EndIf
Else
	MsgStop(STR0170,STR0023) // Nenhum veiculo encontrado! / Atencao
	aRetorno := {}
EndIf

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ FS_OPER  º Autor ³ Thiago				        º Data ³ 05/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Parambox com Operação de TES.								           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function FS_OPER(cOper,cTes,cFornece,cChaint,nLin,nALIICM)
Local aParambox    := {} 
Local _i           := 0
Private aRet       := {}  
Private cForn      := cFornece
Private cCodChaint := cChaint
Private nLinha := nLin     

AADD(aParambox,{1,RetTitle("VVG_OPER"),cOper,"","VM006OPER(MV_PAR01,cForn,cCodChaint)","DJ",".T.",50,.F.})
AADD(aParambox,{1,RetTitle("VVG_CODTES"),cTes,"","VM006TES(MV_PAR02)","SF4",".T.",50,.F.})
AADD(aParambox,{1,RetTitle("VVF_ALIICM"),nALIICM,X3Picture( "VVF_ALIICM" ),"","",".T.",50,.F.})
If !ParamBox(aParamBox,STR0171,@aRet,,,,,,,,.f.)
	Return .f.
EndIf  
if nLinha == 1
	For _i :=1 to Len(aIteVei)
		if Empty(aIteVei[_i,7])
			aIteVei[_i,6] := MV_PAR01
			aIteVei[_i,7] := MV_PAR02
		Endif
	Next
Endif
aIteVei[nLinha,6] := MV_PAR01
aIteVei[nLinha,7] := MV_PAR02
aIteVei[nLinha,9] := MV_PAR03
//
oLbIteVei:SetArray(aIteVei)
oLbIteVei:bLine := { || { aIteVei[oLbIteVei:nAt,1],;
								  aIteVei[oLbIteVei:nAt,2],;
								  aIteVei[oLbIteVei:nAt,3]+"/"+aIteVei[oLbIteVei:nAt,4],;
								  aIteVei[oLbIteVei:nAt,5],;
								  aIteVei[oLbIteVei:nAt,6],;
								  aIteVei[oLbIteVei:nAt,7],;
								  Transform(aIteVei[oLbIteVei:nAt,9],X3Picture("VVF_ALIICM"))}}

oLbIteVei:Refresh()

Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ VM006OPER º Autor ³ Thiago				        º Data ³ 05/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Validacao da Operação.										           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VM006OPER(cOper,cFornece,cChaint)
Local cCod  := substr(cFornece,1,TamSX3("A2_COD")[1])
Local cLoja := substr(cFornece,TamSX3("A2_COD")[1]+2,TamSX3("A2_LOJA")[1]) 
Local cGruVei  := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
dbSelectArea("SB1")
DbSetOrder(7)             
DbSeek(xFilial("SB1")+cGruVei+cChaint)
cTES := MaTesInt(1,MV_PAR01,cCod,cLoja,"C",SB1->B1_COD) 
MV_PAR02 := cTES              
if !Empty(MV_PAR01)
	DbSelectArea("SX5")
	DbSetOrder(1)
	if !DbSeek(xFilial("SX5")+"DJ"+MV_PAR01)     
			MsgInfo(STR0173)
		Return .f.
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ VM006OPER º Autor ³ Thiago				        º Data ³ 05/05/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Validacao da Operação.										           º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VM006TES(cTes)
Local lRet := .t.

if !Empty(cTes)
	if cTes < "500"
		dbSelectArea("SF4")
		DbSetOrder(1)             
		if !DbSeek(xFilial("SF4")+cTes)     
			MsgInfo(STR0174)
			lRet := .f.
		Endif	
	Else
		MsgInfo(STR0175)
		lRet := .f.
	Endif
Endif
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEIVM006  ºAutor  ³Renato Vinicius     º Data ³  13/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validaçao da chave quando o parametro MV_DCHVNFE esta habi º±±
±±º          ³ litado                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VLDCHVNFE(cFormul,cEspecie,cChvNfe)

Local lDigChv := GetNewPar("MV_DCHVNFE",.F.)
Local lRetorno 	  := .T.

Default cFormul := ""
Default cEspecie := ""
Default cChvNfe := ""

DbselectArea("SX3")
DbSetOrder(2)
     
If lDigChv
	If SF1->(FieldPos("F1_CHVNFE"))>0  
		If 	(cFormul == "N" .and. AllTrim(cEspecie) == "SPED") .or.;
		 	(cFormul == "N" .and. AllTrim(cEspecie) == "CTE") .or.;
			(cFormul == "N" .and. AllTrim(cEspecie) == "NFCE")
			If SX3->(dbSeek("F1_CHVNFE") .And. SX3->X3_VISUAL == "V")
			 	Help(" ",1,"CHVALTERAR")
	   			lRetorno := .F.
	   		ElseIf Empty(cChvNfe)
				Help(" ",1,"DCHVNFE")
				lRetorno := .F.
			ElseIf len(Alltrim(cChvNfe)) < 44
				Help(" ",1,"CHVMENOR")
				lRetorno := .F.
			EndIf
         EndIf
	EndIf
EndIf

Return lRetorno


/*/{Protheus.doc} VM006FldOK
Funcao responsavel por validar digitações do Conhecimento de Frete
@author Manoel
@since 23/03/2018
@version 1.0
/*/
Function VM006FldOK()
Local lRet := .t.

If ReadVar() == "M->VVF_UFORIT"
	M->A1_EST := M->VVF_UFORIT
Endif

If ReadVar() == "M->VVF_UFDEST"
	M->A1_EST := M->VVF_UFDEST
Endif

Return lRet