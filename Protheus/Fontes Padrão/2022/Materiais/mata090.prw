/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ DATA   ³ BOPS ³Prograd.³ALTERACAO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³26.03.98³14776A³Eduardo ³Acerto no erro bound Array acess na Proj.Infla.³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³22.11.99³META  ³Julio W.³Revisao do Fonte para Protheus 5.08            ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#INCLUDE "MATA090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA090  ³ Autor ³ Jorge Queiroz         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Moedas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void MATA090(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Mata090

Private aRotina 	:= MenuDef()

LimpaMoeda()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SM2",,,22)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090Inclui³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 06.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao de Moedas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A090Inclui(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao no Menu                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090Inclui(cAlias,nReg,nOpc)

Local nOpca

nOpca := AxInclui (cAlias,nReg,nOpc,,,,'If(dbSeek(M->M2_DATA),(Help(" ",1,"JAGRAVADO"),.F.),.T.)')

If nOpca == 1
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
	BEGIN TRANSACTION
	// Compatibilizacao com Arquivo de Moedas -> CTB
	If CtbInUse()
		GrvCTBCTP()
	EndIf	
	END TRANSACTION 	
EndIf	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090Altera³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 06.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Alteracao de Cotacao Moedas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void A090Altera(ExpC1,ExpN1,ExpN2)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao no Menu                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090Altera(cAlias,nReg,nOpc)

Local nOpca

nOpca := AxAltera (cAlias,nReg,nOpc)

If nOpca == 1
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
	BEGIN TRANSACTION
	// Compatibilizacao com Arquivo de Moedas -> CTB
	If CtbInUse()
		GrvCTBCTP()
	EndIf	
	END TRANSACTION 
EndIf	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090Deleta³ Autor ³ Jorge Queiroz         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao de Moedas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void A090Deleta(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090Deleta(cAlias,nReg,nOpc)

Local nOpca

nOpca := AxDeleta(cAlias,nReg,nOpc)

If nOpca==1
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
EndIF

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090Projet³ Autor ³ Wagner Xavier         ³ Data ³ 23.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Projecao de Moedas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void A090Projet(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A090Projet(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Salva a integridade dos dados                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local i,lRegres,k,lInflacao,n:=0
Local nAvanco,oDlg,cSuf,nRegM2 := SM2->(Recno())
Local oGet01, oGet02 := 1
Local lValDias:=.T.
Local oGet            
Local aoGrRad := {}
Local nI        
Local lRefresh := .F.
Local anGrRad := {}

Private cMoeda,aMoedas:={},aMeses:={},nDias:=0,nDiasReg:=3
Private aHeader:={}, nNumMoedas := 0, nNumMeses := 1, cSeqMdProj:="01."
Private aAlter:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get no parametro MV_DIASPRO - no. de dias de projecao de moedas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDias:= GETMV("MV_DIASPRO")
n:=0
lRegres:=.F.
lInflacao:=.F.
AAdd(aoGrRad,"")

// 1a. coluna
AADD(aHeader,{STR0025,"MOEDA","@!",10,0,".t.","û","C","TRB"})

aMoedas := MontaMark(@anGrRad, @aoGrRad)

If ! Len(aMoedas) > 0
	Return
Endif

//2a. coluna em diante
For nI := 1 to Len(aMoedas)
	AADD(aHeader,{aMoedas[nI,1],"MOEDA" + aMoedas[nI,2],PesqPict("SM2","M2_TXMOED2"),5,2,".t.","û","N","TRB"})
	AADD(aAlter,"MOEDA" + aMoedas[nI,2])
Next

Private aCols[1][Len(aHeader)+1]

If Len(aMoedas) == 0
	Help(" ",1,"A090NMOEDA")
	Return .F.
EndIf

aCols[1][Len(aCols[1])] := .F.

// Monta a GetDados Zerada
aCols[1][1]:="_________"		//,0.0,0.0,0.0,0.0,.f.})

For nI:= 2 To Len(aMoedas)+1
	aCols[1][nI]:= 0.00
Next

DEFINE MSDIALOG oDlg FROM 74,07 TO 450,850 TITLE STR0007 OF oMainWnd PIXEL

@ 04, 04 SAY STR0021 SIZE 73, 8 OF oDlg PIXEL // No. de dias para projeçãoo"
@ 0.3, 12 MSGET oGet01 VAR nDias PICTURE "9999" SIZE 17,9 VALID (lValDias:=(nDias > 0 .and. nDias < 366),If(lValDias,A090GDbWhen(anGrRad,oGet),),lValDias) OF oDlg
@ 04, 160 SAY STR0022 SIZE 73, 8 OF oDlg PIXEL // "No. de dias para regressão"
@ 0.3,30 MSGET oGet02 VAR nDiasReg PICTURE "999" SIZE 17,9 WHEN A090DiasR(anGrRad) Valid nDiasReg > 0 OF oDlg

@ 17,03 MSPANEL oPanel PROMPT "" SIZE 185,170 OF oDlg //CENTERED RAISED //"Botoes"
oScroll := TScrollBox():New( oPanel, 000,175,85,08,.T.,.T.,.T.)
oScroll:Align := CONTROL_ALIGN_ALLCLIENT

@100,00 TO 100,550 OF oDlg PIXEL

oGet := MSGetDados():New(18,190,160,410,3,"AlwaysTrue","AlwaysTrue","",.T.,aAlter,,,1)

nRod := 1
For nI := 1 to Len(aMoedas) Step 2

	//inclui a moeda da coluna da esquerda
 	@ 03+((nRod-1)*42),03 TO 40+((nRod-1)*42), 079 LABEL GetMv("MV_MOEDA" + aMoedas[nI,2] ) OF oScroll  PIXEL

	aoGrRad[nI] := 	TRadMenu():New( 11+((nRod-1)*42), 06, {STR0023, STR0024},;
	&("{ | u | If( PCount() == 0,anGrRad["+cValToChar(nI)+"], anGrRad["+cValToChar(nI)+"] := u ) }") ,;
	oScroll,, { || A090GDbWhen(anGrRad,oGet) } ,,,,,,70,10,, .T., .T.,.T. )
 	
	If !Len(aMoedas) == 1 .And. nI < Len(aMoedas) 	
			@ 03+((nRod-1)*42),92 TO 40+((nRod-1)*42), 168 LABEL GetMv("MV_MOEDA" + aMoedas[nI + 1,2]) OF oScroll  PIXEL
		
			aoGrRad[nI+1] := TRadMenu():New( 11+((nRod-1)*42), 95, {STR0023, STR0024},;
			&("{ | u | If( PCount() == 0,anGrRad["+cValToChar(nI+1)+"], anGrRad["+cValToChar(nI+1)+"] := u ) }") ,;
			oScroll,, { || A090GDbWhen(anGrRad,oGet) },,,,,,70,10,, .T., .T.,.T. )
	Endif

	nRod ++
Next nI
nI:=1        

DEFINE SBUTTON FROM 170, 350 TYPE 1 ACTION (CursorWait(),lRefresh :=.t.,fc090Calc(anGrRad,oDlg:End())) ENABLE OF oDlg
DEFINE SBUTTON FROM 170, 380 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg ON INIT A090InitDLG(oDlg) CENTERED

If ! lRefresh
	Return
EndIf

CursorArrow()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o parametro MV_DIASPRO no arq. SX6                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetMv("MV_DIASPRO") != NIL
	PutMV("MV_DIASPRO",Str(nDias,3))
EndIf
SM2->(dbGoto(nRegM2))

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FUNCAO A090INITDLG                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function A090InitDLG(oAuxDlg)

Local nCnt01 := 0

For nCnt01 := 1 To Len(oAuxDlg:aControls)
	If (oAuxDlg:aControls[nCnt01]:cCaption != NIL) .And. ;
		("GRPM" $ oAuxDlg:aControls[nCnt01]:cCaption)
		oAuxDlg:aControls[nCnt01]:cTitle := Capital(Substr(GetMV("MV_MOEDA"+Right(oAuxDlg:aControls[nCnt01]:cCaption,1)),1,13))
	EndIf
Next
oAuxDlg:Refresh(.T.)

Return(NIL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FUNCAO A090DIASR                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function A090DiasR(anGrRad)

Local nI

lRet := .F.
For ni := 1 To Len(anGrRad)
	If anGrRad[nI] == 1
		lRet := .T.
	EndIf
Next

Return lRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FUNCAO A090DBWHEN                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function A090GDbWhen(anGrRad,oGet)

Local lProcess := .F.//:= (nGrRad01==2) .Or. (nGrRad02==2) .Or. (nGrRad03==2) .Or.(nGrRad04==2)
Local dDataIni, dDataFim, nMes, nMdBr:=0
Local aRadios := {}
Local nI
              
For nI:=1 To Len(anGrRad)
	Aadd(aRadios,anGrRad[nI])
	If anGrRad[nI] == 2
		lProcess := .T.
	End
Next

cSeqMdProj:="01."
If lProcess
	aCols := {}
	aAlter:= {}
	oGet:oBrowse:aAlter:={}
	nMdBr := Len(anGrRad)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta acols com Meses a serem indicados para projecao                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDataIni:=dDataBase+1
	dDataFim:=dDataBase+nDias
	nMes    :=Month(dDataIni)
	While nMes != Month(dDataFim)
		AADD(aCols,array(nMdBr+2))
		aCols[Len(aCols)][1] := Substr(cMonthNac(dDataIni),1,9)
		For ni := 1 to nMdBr
			aCols[Len(aCols)][ni+1] := 0
		Next
		aCols[Len(aCols)][nMdBr+2] := .f.
		nAvanco:=1+(Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni:=dDataIni+nAvanco
		nMes:=Month(dDataIni)
		IF nMes>12;nMes:=1;EndIF
		nNumMeses++
	EndDO

	AADD(aCols,array(nMdBr+2))
	aCols[Len(aCols)][1] := Substr(cMonthNac(dDataIni),1,9)
	For ni := 1 to nMdBr
		aCols[Len(aCols)][ni+1] := 0
	Next
	aCols[Len(aCols)][nMdBr+2] := .f.
	For nI := 1 to Len(aRadios)
		IF (aRadios[nI] == 2)
			Aadd(aAlter,"MOEDA" + aMoedas[nI,2] )
			cSeqMdProj := cSeqMdProj + strzero(Val(aMoedas[nI,2]),2)+'.' 
		Endif
	Next
	oGet:oBrowse:aAlter:=aClone(aAlter)
	oGet:ForceRefresh()
EndIf

Return(lProcess)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fc090Calc³ Autor ³ Wagner Xavier         ³ Data ³ 23.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avalia array para tipos de projecoes de moedas             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ fc090Calc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function fc090Calc(anGrRad)

Local n,lCalc:=.T., ni, nj
Local aRadios := {}

For nI:=1 To Len(anGrRad)
	Aadd(aRadios,anGrRad[nI])
Next

IF Len(cSeqMdProj) > 3 //1
	aTaxaMeses := Array(Len(aCols),Len(aHeader))
	For ni := 1 to Len(aHeader)
		For nj := 1 to Len(aCols)
			aTaxaMeses[nj][ni] := aCols[nj][ni]
		Next
	Next
Endif

For n:=1 To Len(aMoedas)

	If aRadios[n] == 1
		lCalc:=CalcLinear(Val(aMoedas[n,2]), anGrRad)
		If !lCalc
			Exit
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a funcao CalcInflac com o parametro de "P" (Projecao)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// transformar acols em ataxameses [ taxa x moeda]
		lCalc:=CalcInflac(Val(aMoedas[n,2]),"P")
		IF !lCalc
			Exit
		EndIF
	EndIF
Next

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalcLinear³ Autor ³ Wagner Xavier         ³ Data ³ 23.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula as Taxas em outras moedas pela formula de Regressao ³±±
±±³          ³Linear                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³CalcLinear(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = no. da moeda a ser calculada a projecao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function CalcLinear(nMoeda, anGrRad)

Local dAtual:=dDataBase
Local dPass :=dAtual-nDiasReg
Local aRet,Xi,Yi
Local nPosAtu:=0,nPosAnt:=0,nTotRegs:=0,nPosCnt:=0,nOpc:=0,cSavMenuh
Local lMa090Atu := ExistBlock("MA090ATU")
Local i,j
Local nValAnt := {}

cSuf:=cValToChar(nMoeda)
DbSelectArea("SM2")

If RecCount() < 2
	Help(" ",1,"NORECD")
	Return .F.
Endif

dbGoTop( )
Set Softseek on
dbSeek(dPass)
dPass := M2_DATA

If ! (dPass < dAtual)
	Help(" ",1,"NORECD")
	Set Softseek off
	Return .F.
EndIf

For i:=1 to Len(anGrRad)    
	SetPrvt( "ay"+LTrim(aMoedas[i,2]) )
	&("ay"+LTrim(aMoedas[i,2])) := {}
Next i

Set Softseek off
While dPass < dAtual
	dbSeek(dPass)
	IF Found()     
		For i:=1 to Len(anGrRad)    
			SetPrvt("nValAnt"+LTrim(Str(i+1)))
			nValAnt := &("m2_moeda" + aMoedas[i,2])
			AADD(&("ay" + aMoedas[i,2]), nValAnt )
		Next i
	Endif
	dPass++
EndDo

SetPrvt("aRet" + LTrim(Str(nMoeda)) )   
	
&("aRet"+LTrim(Str(nMoeda))) := RLinear( &("ay"+LTrim( Str( nMoeda ) ) ) )
SetPrvt("K1"+LTrim(Str(nMoeda)))
&("K1"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[1]
SetPrvt("K2"+LTrim(Str(nMoeda)))	
&("K2"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[2]
SetPrvt("Xm"+LTrim(Str(nMoeda)))		
&("Xm"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[3]
SetPrvt("Ym"+LTrim(Str(nMoeda)))			
&("Ym"+LTrim(Str(nMoeda))) := &("aRet"+LTrim(Str(nMoeda)))[4]
SetPrvt("Nx"+LTrim(Str(nMoeda)))		
&("Nx"+LTrim(Str(nMoeda))) := Len(&("ay"+LTrim( Str( nMoeda ) ) ) )	

Xi:=dAtual
Yi:=0

// Regua

For j:=1 To nDias		
	
 	Xi:=dPass+j
	nD:=(Xi-dAtual)+nx&cSuf
	Yi := (K2&cSuf*nD)+(Ym&cSuf-(K2&cSuf*Xm&cSuf))
	dbSeek(dPass+j)
	If Found() .and. M2_INFORM != "S"
		Reclock("SM2")
		nOpc := 4
	ElseIf M2_INFORM != "S"
		Reclock("SM2",.T.)
		nOpc := 3
	EndIf
	IF M2_INFORM != "S"
		Replace M2_DATA        With dPass+j
		Replace M2_MOEDA&cSuf  With Yi
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Qdo. o calculo e' por regressao linear e' gravado 0 na taxa. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nMoeda < 10
			Replace M2_TXMOED&cSuf With 0.00
		Else
			Replace M2_TXMOE&cSuf With 0.00
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
		If FindFunction("J170GRAVA")
			J170GRAVA("SM2", DToS(SM2->M2_DATA), Alltrim(Str(nOpc)))
		EndIf
	EndIf
	MsUnlock()
	If lMa090Atu
		ExecBlock("MA090ATU",.F.,.F.,{ 4 })
	EndIf
	// Compatibilizacao com Arquivo de Moedas -> CTB
	If CtbInUse()
		GrvCTBCTP()
	EndIf		
Next j

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalcInflac³ Autor ³ Wagner Xavier         ³ Data ³ 23.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula as Taxas em outras moedas pela Inflacao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³CalcInflac(ExpN1, ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = no. da moeda a ser calculada a projecao            ³±±
±±³          ³ ExpC1 = indica a origem da chamada: A - Abertura do Sistema³±±
±±³          ³                                     P - Projecao de Moedas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcInflac(nMoeda,cOrigem)

Local k,dData:=dDataBase,nUltVal,ay:={},nPriVal:=0,nFirst:=0,nDia:=0,nMes:=0
Local nPosAtu:=0,nPosAnt:=0,nTotRegs:=0,nPosCnt:=0,cSavMenuh
Local nPosMoeda, cCampo, nVlrCampo
Local lMa090Atu := ExistBlock("MA090ATU")

cOrigem := IIF(cOrigem==NIL,"P",cOrigem)

dbSelectArea("SM2")
cSuf:=cValToChar(nMoeda)
dbSeek(dData)
nPosMoeda := int( ( At(strzero(nMoeda,2),cSeqMdProj) - 1 ) / 3 ) + 1 

For k:=1 To Len(aTaxaMeses)
	AADD(ay,aTaxaMeses[k][nPosMoeda])
Next k

nIndiceMes	:= 0 // indice do mes
nUltVal 	:= 0

//Regua
For k:=1 To nDias
	
	dData:=dData+1
	If nFirst == 0
		nFirst := 1
		nMes   := Month(dData)
		nDia   := 0
		nPriVal:= M2_MOEDA&cSuf
		nIndiceMes++
	Endif
	IF Month(dData)!= nMes
		nFirst := 0
		k--
		dData:=dData-1
		dbSeek(dData)
		LOOP
	EndIf
	nDia++
	nPosCnt++
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a taxa = 0 e origem="A" (Abertura) nao executa projecao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nIndiceMes > 0 .and. nIndiceMes <= Len(ay)
		If ay[nIndiceMes] = 0 .and. cOrigem == "A"
			SM2->(dbSeek(dData))
			// Guarda o ultimo valor para repeti-lo nas datas posteriores que forem
			// criadas pela Abertura do sistema e cujo modulo de calculo anterior
			// foi pelo metodo da Regressao Linear
			//			If SM2->M2_MOEDA&cSuf != 0.000
			//				nUltVal:=SM2->M2_MOEDA&cSuf
			//				LOOP
			//			Endif
			cCampo:= "M2_MOEDA"+cSuf
			nVlrCampo:= SM2->( FieldGet( FieldPos( cCampo ) ) )
			If nVlrCampo!=0.000
				nUltVal:= nVlrCampo
			Endif
		Else
			nUltVal:=RInflac(ay,dData,nPriVal,nDia)
		EndIf
		SM2->(dbSeek(dData))
		If Found() .and. M2_INFORM != "S"
			Reclock("SM2")
		ElseIf M2_INFORM != "S"
			Reclock("SM2",.T.)
		EndIf
		IF M2_INFORM != "S"
			Replace M2_DATA         With dData
			Replace M2_MOEDA&cSuf   With nUltVal
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava a taxa de projecao de moeda                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nMoeda < 10
		 		Replace M2_TXMOED&cSuf With ay[nIndiceMes]
			Else
				Replace M2_TXMOE&cSuf With ay[nIndiceMes]
			EndIf
		EndIF
		MsUnlock()
		If lMa090Atu
			ExecBlock("MA090ATU",.F.,.F.,{ 4 })
		EndIf
		// Compatibilizacao com Arquivo de Moedas -> CTB
		If CtbInUse()
			GrvCTBCTP()
		EndIf	
	EndIf
NEXT k

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³cMonthNac ³ Autor ³ Wagner Xavier         ³ Data ³ 23.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica nome do mes em Portugues                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³cMonthNac(data)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function cMonthNac(dData)

			   //"Janeiro  Fevereiro Marco   Abril    Maio     Junho    Julho    Agosto   Setembro Outubro  Novembro Dezembro "	
LOCAL aMeses :=	{ STR0009, STR0010, STR0011, STR0012, STR0013, STR0014, STR0015, STR0016, STR0017, STR0018, STR0019, STR0020 }   
	
Return aMeses[Month(dData)]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RInflac  ³ Autor ³ Jorge Queiroz         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a equacao da projecao da moeda levando em conta a    ³±±
±±³          ³ distribuicao percentual da inflacao atribuida pelo usuario.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpN1 := RInflac(ExpA2,ExpA3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Devolve o valor da moeda estrangeira               ³±±
±±³          ³ ExpA1 = Array contendo os percentuais da inflacao          ³±±
±±³          ³ ExpD1 = Data a considerar a inflacao                       ³±±
±±³          ³ ExpN2 = Valor da moeda na data imediatamente anterior      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RInflac(ax,dData,nValor,nDia)

Local nMes,nBase,nAno,dUltMes,nM,nDiasMes,nValProj

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a data corrente e projeta para a data da inflacao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMes  := Month(dData)
nAno  := Year(dData)

If Day(dDataBase) = Day(LastDay(dDataBase))
	nBase := Month(M->dDataBase)+1
Else
	nBase := Month(M->dDataBase)
EndIf

nM := IIF(nMes >= nBase,nMes-nBase,(nMes+12)-nBase)
nM++
nMes++
IF nMes > 12;nMes:=1;nAno++;Endif
dUltMes:=CTOD("01/"+StrZero(nMes,2)+"/"+SubStr(Str(nAno,4),3,2),"ddmmyy")
dUltMes--
nDiasMes :=DAY(dUltMes)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a Projecao pela formula corrente                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVar := (ax[nM])/(nDiasMes*100)
nVar := nVar*10000
nVar := int(nVar)
nVar := nVar/10000
nValProj:=nValor*(1+(nVar)*nDia)

Return nValProj

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RLinear  ³ Autor ³ Jorge Queiroz         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a equacao normal de regressao linear de uma distri-  ³±±
±±³          ³ buicao de pontos utilizando o metodo dos minimos quadrados.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1 := RLinear(ExpA2,ExpA3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo K1,K1,Xm,Ym                         ³±±
±±³          ³ ExpA2 = Array contendo a distribuicao de "x"               ³±±
±±³          ³ ExpA3 = Array contendo a distribuicao de "y"               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function rlinear(ay)

Local Sxi:=0,Syi:=0,Sxy:=0,Sx2:=0,Sy2:=0,i,Xm:=0,Ym:=0,Sx,Sy,aForm:={},K1:=0,K2:=0

//ÚÄÄÄÄÄÄÄÄ _   _ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula X e Y (media de X e Y)                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FOR i:=1 To Len(ay)
	Sxi+=i
	Syi+=ay[i]
NEXT i

Xm=Sxi/Len(ay)
Ym=Syi/Len(ay)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo da distribuicao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FOR i:=1 TO Len(ay)
	Sxi := i-Xm
	Syi := ay[i]-Ym
	Sxy += (Sxi*Syi)
	Sx2 += (Sxi**2)
	Sy2 += (Syi**2)
NEXT i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula desvio Padrao de X (Sx) e de Y (Sy)                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Sx := ROUND(SQRT(Sx2/Len(ay)),2)
Sy := ROUND(SQRT(Sy2/Len(ay)),2)
If (Len(ay)*Sx*Sy) != 0
	Rxy := Sxy/(Len(ay)*Sx*Sy)
	K1  := Rxy*(Sx/Sy)
	K2  := Rxy*(Sy/Sx)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve array contendo as variaveis da formula de regressao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aForm,K1)
AADD(aForm,K2)
AADD(aForm,Xm)
AADD(aForm,Ym)

Return aForm

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Abert³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 18/05/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Projecao de moedas na Abertura do sistema                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ A090Abert(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Indica a origem da chamada: A - Abertura           ³±±
±±³          ³                                     P - Projecao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function A090Abert()

Local n
Private nNumMoedas:=4, nNumMeses:=1, nDias:=0, cSeqMdProj:="01.02.03.04.05."
Private aMeses := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Get no parametro MV_DIASPRO - no. de dias de projecao de moedas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDias:= GETMV("MV_DIASPRO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta array com Meses a serem indicados para projecao                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDataIni:=dDataBase+1
dDataFim:=dDataBase+nDias
nMes    :=Month(dDataIni)

While nMes != Month(dDataFim)
	AADD(aMeses,Substr(cMonthNac(dDataIni),1,9))
	nAvanco:=1+(Day(LastDay(dDataIni))-Day(dDataIni))
	dDataIni:=dDataIni+nAvanco
	nMes:=Month(dDataIni)
	IF nMes>12;nMes:=1;EndIF
	nNumMeses++
Enddo

AADD(aMeses,Substr(cMonthNac(dDataIni),1,9))

aHeader := ARRAY(nNumMoedas,3)
Private aTaxaMeses := ARRAY(nNumMeses,nNumMoedas+1)

dbSelectArea("SM2")
a090GTAXA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao CalcInflac c/parametro de "A" (Abertura), p/ as 4 moedas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For n:=1 To 4
	CalcInflac(n+1,"A")
Next

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A090GTAXA ³ Autor ³ Elizabeth A. Eguni    ³ Data ³ 16/05/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do array da taxa de projecao de moedas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ (VOID)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A090GTAXA()

Local cCampo
Local i

For i := 1 To nNumMeses
	aTaxaMeses[i][1] := aMeses[i]
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui ao array de taxas (aTaxaMeses) os valores gravados   ³
//³ no arquivo SM2 (campos M2_TXMOED?).                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 2 To nNumMoedas+1
	nCntMeses := 1
	nMes      :=Month(dDataBase+1)
	nTaxaAux  := 0
	nAno      := Year(dDataBase+1)
	While nMes != If((Month(dDataBase+nDias)+1)>12,1,(Month(dDataBase+nDias)+1))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for o primeiro mes do array pesquisa a data atual + 1 dia,³
		//³ caso contrario procura pelo primeiro dia do mes de pesquisa. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCntMeses == 1
			dDataSeek := dDataBase + 1
		Else
			dDataSeek := ctod("01/" + str(nMes,2) + "/" + str(nAno,4),"ddmmyy")
		Endif
		SM2 -> ( dbSeek(dDataSeek) )
		If SM2 -> ( !Eof() )
			cSufMoeda := Alltrim( str( val( Substr(cSeqMdProj,(i-1)*3,2) ) ) ) // Alltrim(Substr(cSeqMdProj,i,2))
			//nTaxaAux := SM2->M2_TXMOED&cSufMoeda
			cCampo:= If(nMoeda<10,"M2_TXMOED","M2_TXMOE")+cSufMoeda
			nTaxaAux:= SM2->( FieldGet( FieldPos( cCampo ) ) )
		Endif
		aTaxaMeses[nCntMeses][i] := nTaxaAux
		nCntMeses++
		nMes++
		IF nMes>12
			nMes:=1
			nAno++
		EndIF
	End
Next

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GRVCTBCTP ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 06/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava cotacao de moedas no SIGACTB                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GrvCTBCTP()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function GrvCTBCTP(nOpc)

Local aSaveArea := GetArea()
Local cVal
Local cBloq
Local nTaxa
Local nCont    
Local nQtas := iif( __nQuantas < 5 , 5 , __nQuantas )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Grava CTP -> quando estiver usando SIGACTB           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If ChkFile("CTP") .And. ChkFile("CTO")
	For nCont	:= 1 To nQtas
		cMoeda		:= StrZero(nCont,2)
		cVal		:= Alltrim( Str( nCont ))
		nTaxa		:= CriaVar("CTP_TAXA",.T.)
		cBloq		:= CriaVar("CTP_BLOQ",.T.)
		
		If ChkFile("CTO")
			dbSelectArea("CTO")
			dbSetOrder(1)
			If dbSeek( xFilial("CTO") + cMoeda )
				If ChkFile("CTP")
					dbSelectArea("CTP")
					dbSetOrder(1)
					If !dbSeek( xFilial("CTP") + DTOS(SM2->M2_DATA) + cMoeda )
						RecLock("CTP",.T.)
						Replace CTP_FILIAL		With xFilial("CTP")
						Replace CTP_DATA		With SM2->M2_DATA
						Replace CTP_MOEDA		With cMoeda
						Replace CTP_BLOQ		With cBloq				// Taxa Nao Bloqueada
					Else
						RecLock("CTP")
					EndIf
					If Empty(&("SM2->M2_MOEDA"+cVal))
						Replace CTP_TAXA	With nTaxa
					Else	
						Replace CTP_TAXA 	With &("SM2->M2_MOEDA"+cVal)
					EndIf	
					MsUnlock()
					dbCommit()
				EndIf	
			EndIf	
		EndIf	
	Next nCont
EndIf   

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³Rodrigo de A Sartorio  ³ Data ³15/04/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
    
Private	aRotina := {}
	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_VIEW   ACCESS 0	//Visualizar
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_INSERT ACCESS 0	//Incluir
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 	//Alterar
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.MATA090'	OPERATION MODEL_OPERATION_DELETE ACCESS 0	//Excluir
	ADD OPTION aRotina Title STR0006	Action 'A090Projet'			OPERATION 6	ACCESS 0						// "Projetar"
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA090MNU")
	ExecBlock("MTA090MNU",.F.,.F.)
EndIf

Return(aRotina) 

//-------------------------------------------------------------------
/*	Modelo de Dados
@autor  	Ramon Neves
@data 		16/05/2012
@return 		oModel Objeto do Modelo*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruSM2 := FWFormStruct( 1, "SM2")
Local oModel   := MPFormModel():New('MATA090',,, {|oModel|A090COMMIT(oModel)})   

oModel:AddFields( 'SM2MASTER',, oStruSM2)
oModel:GetModel( 'SM2MASTER' ):SetDescription(STR0007)  //"Atualiza‡„o de Moedas"
oModel:SetPrimaryKey( { "M2_DATA"} )

Return oModel

//-------------------------------------------------------------------
/*	Interface da aplicacao
@autor  	Ramon Neves
@data 		20/04/2012
@return 		oView Objeto da Interface*/
//-------------------------------------------------------------------

Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'MATA090' )
Local oStruSM2 := FWFormStruct( 2, 'SM2')
Local oView     

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SM2",oStruSM2,"SM2MASTER")

Return oView  

//-------------------------------------------------------------------
/*	Efetua o Commit
@autor  	Ramon Neves
@data 		20/04/2012
@return 		oView Objeto da Interface*/
//-------------------------------------------------------------------

Static Function A090COMMIT(oModel)

Local xCommit	:= FWFormCommit( oModel )
Local nOpc		:= IIf(oModel <> NIL, oModel:GetOperation(), )

If xCommit
	If ExistBlock("MA090ATU")
		ExecBlock("MA090ATU",.F.,.F.,{ nOpc })
	EndIf
	If nOpc == 3 .OR. nOpc == 4	    //Incluir .OR. Alterar
		BEGIN TRANSACTION
			// Compatibilizacao com Arquivo de Moedas -> CTB
			If CtbInUse()
				GrvCTBCTP()
			EndIf	
		END TRANSACTION 	
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
	If FindFunction("J170GRAVA")
		J170GRAVA("SM2", DToS(oModel:GetValue("SM2MASTER","M2_DATA")), Alltrim(Str(nOpc)))
	EndIf
EndIf 
                                 
Return(xCommit)                

/*/{Protheus.doc} MontaMark

Função monta tela Mark para seleção das moedas que deseja alterar.

@author francisco.carmo
@since 21/06/2018
@version 1.0
@return aRetMoe, Array com as moedas selecionadas 
@param anGrRad, array of numeric, Vetor com o numero de opção Radio para montagem de tela.
@param aoGrRad, array of object, Objeto com os dados marcados na opção Radio.
@type function
/*/
Static Function MontaMark(anGrRad, aoGrRad)

	Local aVetor	:= {}
	Local aRetMoe	:= {}
	Local lMark    	:= .F.
	Local nOpcA		:= 0
	Local oOk      	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Local oNo      	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Local nI
	Local cAuxMoeda := ""
	
	For nI := 2 To 99
		cAuxMoeda := GetNewPar( "MV_MOEDA" + Ltrim(Str(nI) ), "x" ) 
		If cAuxMoeda  <> "x" .And. !Empty( cAuxMoeda )
			aAdd( aVetor, {lMark, ALLTRIM(Capital(Substr( cAuxMoeda , 1 , 14))), Alltrim(Str(nI))  })
		Else
			Exit
		Endif
	Next nI 
	
	DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 300,600 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER " ", "Moeda" SIZE 280,105 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1])

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),	aVetor[oLbx:nAt,2]}}

	@ 125,250 BUTTON "&Ok"       				SIZE 40,20 PIXEL ACTION {|| nOpcA := 1,oDlg:End()} Message STR0028	of oDlg
	@ 125,200 BUTTON "&Cancelar" 				SIZE 40,20 PIXEL ACTION {|| nOpcA := 0,oDlg:End()} Message STR0029 	of oDlg
	@ 125,050 BUTTON "&Marcar/Iverter Seleção"	SIZE 70,20 PIXEL ACTION {|| MrkAll(@aVetor, oLbx)} Message STR0028	of oDlg

	ACTIVATE MSDIALOG oDlg CENTER
   
	If nOpcA == 1
		For nI := 1 To Len(aVetor)
			If aVetor[nI,1]
				Aadd(aRetMoe, {aVetor[nI,2], aVetor[nI,3] })
				Aadd(anGrRad,Nil)
				Aadd(aoGrRad,1)
			Endif
		Next nI
	Endif

Return aRetMoe

/*/{Protheus.doc} MrkAll
Função marca ou desmarca todos tela Mark para seleção das moedas que deseja alterar.
@author francisco.carmo
@since 25/06/2018
@version 1.0
@return ${return}, ${return_description}
@param aVetor, array, Vetor com as moedas a serem definidas para projeção ou regressão
@param oLbx, object, Objeto com informações de escolha feitas pelo usuario.
@type function
/*/
Static Function MrkAll(aVetor, oLbx)
	
	Local nI
	
	For nI := 1 To Len(aVetor)
		If aVetor[nI,1]
			aVetor[nI,1] := .F.
		Else
			aVetor[nI,1] := .T.
		Endif
	Next nI
	oLbx:Refresh()

Return


/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Felipe Raposo
@version P12.1.17
@since   10/07/2018
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return MATI090(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
