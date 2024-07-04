#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMSA411.CH"

Static lDUISEROUT	//-- TMS11R145 - Serie Outra UF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA411  ³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Wizard de Tributação                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA411(cAlias,nReg,nOpcx)
Local nSuperior := 0
Local nEsquerda := 0
Local nInferior := 0
Local nDireita  := 0
Local aAlter    := {}
Local aCpoGDa   := { "DUI_DOCTMS", "DUI_SERIE" }
Local nOpc      := GD_INSERT+GD_UPDATE+GD_DELETE
Local cLinOk    := "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aColsCfo
Local cTudoOk   := "AllwaysTrue"
Local nFreeze   := 000
Local nMax      := 999
Local cFieldOk  := "AllwaysTrue"
Local cSuperDel := ""
Local cDelOk    := "AllwaysTrue"

Local oCodTrib  := Nil
Local cCodTrib  := Space(TamSx3("DUF_REGTRIB")[1])

Local oDescTrib := Nil
Local cDescTrib := Space(TamSx3("DUF_DESCRI")[1])

Local oCombo    := Nil
Local cTipFrete := Space(TamSx3("DUF_TIPFRE")[1])
Local aSx3Box   := Sx3Box2Arr( "DUF_TIPFRE" )

Local cCliGen   := GetMV('MV_CLIGEN')

Local lR5       := GetRpoRelease() >= "R5" // Indica se o release e 11.5
Local nVersao   := Val(GetVersao(.F.))     // Indica a versao do Protheus

Private oWizard     := Nil

Private aConfTes    := {}

Private oNewCDoc    := Nil
Private aHeaderCDoc := {}
Private aColsCDoc   := {}

Private oNewTrib    := Nil
Private aHeaderTrib := {}
Private aColsTrib   := {}

Private oNewCF      := Nil
Private aHeaderCfo  := {}
Private aColsCfo    := {}

Private oNewAliq    := Nil
Private aHeaderAliq := {}
Private aColsAliq   := {}

Private oNewTCli    := Nil
Private aHeaderTCli := {}
Private aColsTCli   := {}

Private Inclui      := .T.
Private aMemSF4     := {}

Private lMsErroAuto := .F.

If !FindFunction('TMSChkVer') .And. !TMSChkVer('11','R5')
	Aviso(STR0019, STR0020 + Chr(10)+Chr(13) + STR0021, {STR0022}, 1) //"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
	Return
EndIf

If Empty(cCliGen)
	Help(" ",1,"TMSA41101") // ("O parametro MV_CLIGEN não está preenchido")
	Return()
EndIf

SA1->(dbSetOrder(1))
If !SA1->(dbSeek(xFilial('SA1') + cCliGen ))
	Help(" ",1,"TMSA41108") // ("O cliente informado para o parametro MV_CLIGEN, não está cadastrado no sistema!")
	Return()
EndIf

DEFINE WIZARD oWizard TITLE STR0001 HEADER STR0001 MESSAGE " "; // "Wizard Regra de Tributação"
TEXT STR0002 ; // "Este assistente permite o preenchimento de regra de tributação"
PANEL NEXT {|| .T.} FINISH {|| .T.}

// Painel 2
CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0003; // "Wizard Regra de Tributação" - "Informar Regra de Tributação e Documento de Transporte"
PANEL BACK {||.T.} NEXT {|| TMS411Vld(cCodTrib,@cDescTrib,cTipFrete,.T.) .And. TMA411VDoc()} FINISH {||.T.} EXEC {|| .T.}

@ 000,005 Say STR0004 Of oWizard:oMPanel[2] Pixel //"Regra Trib."
@ 008,005 MsGet oCodTrib var cCodTrib F3 "MC" Valid !Empty(Tabela("MC",cCodTrib,.F.)) .And. TMS411Vld(cCodTrib,@cDescTrib) Size 30,07 OF oWizard:oMPanel[2] Pixel

@ 000,050 Say STR0005 Of oWizard:oMPanel[2] Pixel // "Descrição"
@ 008,050 MsGet oDescTrib var cDescTrib When .F. Size 150,07 OF oWizard:oMPanel[2] Pixel

@ 020,005 Say STR0006 Of oWizard:oMPanel[2] Pixel // "Tipo de Frete"
@ 028,005 MsComboBox oCombo Var cTipFrete Items aSx3Box SIZE 106,50 OF oWizard:oMPanel[2] Pixel

nSuperior := C(035)
nEsquerda := C(005)
nInferior := C(105)
nDireita  := C(225)

lDUISEROUT := DUI->(FieldPos("DUI_SEROUT")) > 0 //TMS11R145 - Serie Outra UF
If lDUISEROUT
	aCpoGDa := { "DUI_DOCTMS", "DUI_SERIE", "DUI_SEROUT" }
EndIf
TMS411CDOC()
oNewCDoc := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,"TMA411VDoc",cTudoOk,,;
aCpoGDa,nFreeze,1,cFieldOk,cSuperDel,cDelOk,oWizard:oMPanel[2],aHeaderCDoc,aColsCDoc)

// Painel 3
CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0007; // "Wizard Regra de Tributação" - "Configuração do Imposto"  
PANEL BACK {||.T.} NEXT {|| TMA411VImp() } FINISH {|| .T.} EXEC {|| .T.}

nSuperior := C(001)
nEsquerda := C(001)
nInferior := C(105)
nDireita  := C(225)

TMS411Trib()
oNewTrib := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,"TMA411VImp()",cTudoOk,"+DUG_ITEM",;
{"TIPOIMP","CONFTES","CFGITEM","DUG_TES","DUG_CODPAS","DUG_ESTORI","DUG_ESTDEV","DUG_ESTDES","DUG_CODMSG","DUG_SATIV"},;
nFreeze,nMax,"TMA411VCpo()",cSuperDel,"TM411DlImp()"/*cDelOk*/,oWizard:oMPanel[3],aHeaderTrib,aColsTrib)

// Painel 4
CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0008; // "Wizard Regra de Tributação" - "Cadastramento CFOP x Segmento"  
PANEL BACK {||.T.} NEXT {|| TMA411VCf() } FINISH {|| .T.} EXEC {|| .T.}

nSuperior := C(001)
nEsquerda := C(001)
nInferior := C(105)
nDireita  := C(225)

TMS411Cfo()
oNewCF := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,"TMA411VCf",cTudoOk,,;
{"DY5_CF","DY5_SATIV"},nFreeze,nMax,"TMA411RgCf",cSuperDel,cDelOk,oWizard:oMPanel[4],aHeaderCfo,aColsCfo)

// Painel 5
CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0009; // "Wizard Regra de Tributação" - "Cadastramento dos produtos de cálculo com alíquotas internas"
PANEL BACK {||.T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice Cadastro de dados complementares  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSuperior := C(001)
nEsquerda := C(001)
nInferior := C(105)
nDireita  := C(225)

TMS411Aliq()
oNewAliq := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,GD_UPDATE,"TMA411VAlq",cTudoOk,,;
{"ALIQUOTA"},nFreeze,nMax,"TMA411VCpo",cSuperDel,cDelOk,oWizard:oMPanel[5],aHeaderAliq,aColsAliq)

// Painel 6
CREATE PANEL oWizard HEADER STR0001 MESSAGE STR0010; // "Wizard Regra de Tributação" - "Cadastramento da regra de tributação por cliente" 
PANEL BACK {||.T.} NEXT {||.T.} FINISH {|| TMA411Grv(cCodTrib, cTipFrete)} EXEC {||.T.}

nSuperior := C(001)
nEsquerda := C(001)
nInferior := C(105)
nDireita  := C(225)

TMS411Tcli()
oNewTCli := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,"TMA411Vcli",cTudoOk,,;
{"DV1_TIPNFC","DV1_CODPRO","DV1_DESPRO","DV1_TIPCLI"},nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWizard:oMPanel[6],aHeaderTCli,aColsTCli)

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMS411Cfo³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader e Acols para a tabela de CFOP x Segmento       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS411Cfo()
Local lRet      := .T.
Local nX        := 0
Local aCpoGDa   := { "DY5_CF", "DY5_SATIV", "DY5_DSATIV" }
Local cQry1     := ""
Local cAliasQry := GetNextAlias()
Local aSX5		:= {}
Local cChaveSx5 := ""

// Carrega aHead
aHeaderCfo := {}
aColsCfo   := {}

For nX := 1 to Len(aCpoGDa)
		Aadd(aHeaderCfo,{;
		AllTrim(getSx3Cache(aCpoGDa[nX],"X3_TITULO")),; // Titulo
		aCpoGDa[nX]                          ,; // X3_CAMPO
		getSx3Cache(aCpoGDa[nX],"X3_PICTURE"),; // X3_PICTURE
		getSx3Cache(aCpoGDa[nX],"X3_TAMANHO"),; // X3_TAMANHO
		getSx3Cache(aCpoGDa[nX],"X3_DECIMAL"),; // X3_DECIMAL
		""             ,;						// X3_VALID
		getSx3Cache(aCpoGDa[nX],"X3_USADO")  ,; // X3_USADO 
		getSx3Cache(aCpoGDa[nX],"X3_TIPO"   ),; // X3_TIPO
		getSx3Cache(aCpoGDa[nX],"X3_F3")     ,; // X3_F3
		getSx3Cache(aCpoGDa[nX],"X3_CONTEXT"),; // X3_CONTEXT
		getSx3Cache(aCpoGDa[nX],"X3_CBOX")   ,; // X3_CBOX
		getSx3Cache(aCpoGDa[nX],"X3_RELACAO")}) // X3_RELACAO

Next nX

aSX5 := FWGetSX5("T3")

cQry1 := CRLF + " SELECT DY5_CF, DY5_SATIV "
cQry1 += CRLF + "  FROM " +RetSqlName("DY5")+ " DY5 "
cQry1 += CRLF + " WHERE DY5.DY5_FILIAL = '" +xFilial("DY5")+"' "
cQry1 += CRLF + "  AND DY5.D_E_L_E_T_ = '' "
cQry1 += CRLF + " ORDER BY DY5_CF "

cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

// Carregar aqui as Colunas da GetDados.

If (cAliasQry)->( Eof() )
	Aadd(aColsCfo, {})
	For nX := 1 To Len(aHeaderCfo)
		Aadd(aColsCfo[Len(aColsCfo)],CriaVar(aHeaderCfo[nX,2]))
	Next nX
	Aadd(aColsCfo[Len(aColsCfo)],.F.)
EndIf

While (cAliasQry)->( !Eof() )
	If Ascan(aSX5,{|x| Alltrim(x[3]) == AllTrim((cAliasQry)->DY5_SATIV) }) > 0
		cChaveSx5 := Ascan(aSX5,{|x| Alltrim(x[3]) == AllTrim((cAliasQry)->DY5_SATIV) })
		Aadd(aColsCfo, { ;
		(cAliasQry)->DY5_CF    ,;
		(cAliasQry)->DY5_SATIV ,;
		aSX5[cChaveSx5,4] ,; 
		.F. })
	EndIf
	(cAliasQry)->( DbSkip() )
EndDo

(cAliasQry)->( DbCloseArea() )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS411Aliq³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader e aCols para a tela de aliquota interna        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS411Aliq()
Local lRet     := .T.
Local nX       := 0
Local aCpoGDa  := {}
Local aStruSm0 := SM0->(DbStruct())
Local nPos     := 0
Local aSm0     := FwLoadSm0()
Local nCount   := 0

Aadd(aCpoGDa,{ "M0_ESTCOB", STR0011			}) // "Estado"

// Carrega aHead
For nX := 1 to Len(aCpoGDa)
	nPos:= Ascan(aStruSm0,{|x| AllTrim(x[1]) == aCpoGDa[nX,1]})
	If nPos > 0
		Aadd(aHeaderAliq,{aCpoGDa[nX,2],aCpoGDa[nX,1],"@",aStruSm0[nPos,3],0,"","","","","V","",""})
	EndIf
Next nX

Aadd(aHeaderAliq,{STR0012,"ALIQUOTA","@E 99.99",5,2,"Positivo() .And. NaoVazio()","","N","","","",""}) // "% Aliquota"

For nCount := 1 To Len(aSm0)
	SM0->(DbGoto(aSm0[nCount, SM0_RECNO]))
	If aScan(aColsAliq, {|x| x[1] == SM0->M0_ESTENT} ) == 0 .And. aSm0[nCount, SM0_CODFIL] == cFilAnt
		Aadd(aColsAliq, { ;
		SM0->M0_ESTENT,;
		0,;
		.F. })
	EndIf
Next nCount

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS411Cdoc³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader e aCols para a tabela de Documento e Serie     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS411Cdoc()
Local lRet      := .T.
Local nX        := 0
Local aCpoGDa   := { "DUI_DOCTMS", "DUI_SERIE" }
Local cQry1     := ""
Local cAliasQry := GetNextAlias()

// Carrega aHead
aHeaderCDoc := {}
aColsCDoc   := {}

If lDUISEROUT
	aCpoGDa := { "DUI_DOCTMS", "DUI_SERIE", "DUI_SEROUT" }
EndIf

For nX := 1 to Len(aCpoGDa)
		Aadd(aHeaderCDoc,{;
		AllTrim(getSx3Cache(aCpoGDa[nX],"X3_TITULO")),; // Titulo
		aCpoGDa[nX]                          ,; // X3_CAMPO
		getSx3Cache(aCpoGDa[nX],"X3_PICTURE"),; // X3_PICTURE
		getSx3Cache(aCpoGDa[nX],"X3_TAMANHO"),; // X3_TAMANHO
		getSx3Cache(aCpoGDa[nX],"X3_DECIMAL"),; // X3_DECIMAL
		getSx3Cache(aCpoGDa[nX],"X3_VALID"  ),; // X3_VALID
		getSx3Cache(aCpoGDa[nX],"X3_USADO")  ,; // X3_USADO 
		getSx3Cache(aCpoGDa[nX],"X3_TIPO")   ,; // X3_TIPO
		getSx3Cache(aCpoGDa[nX],"X3_F3")     ,; // X3_F3
		getSx3Cache(aCpoGDa[nX],"X3_CONTEXT"),; // X3_CONTEXT
		getSx3Cache(aCpoGDa[nX],"X3_CBOX")   ,; // X3_CBOX
		getSx3Cache(aCpoGDa[nX],"X3_RELACAO")}) // X3_RELACAO

Next nX

cQry1 := CRLF + " SELECT DUI_DOCTMS, DUI_SERIE" + Iif(lDUISEROUT,", DUI_SEROUT ","")
cQry1 += CRLF + "  FROM "+RetSqlName("DUI") + " DUI "
cQry1 += CRLF + "  WHERE DUI_FILIAL = '"+xFilial("DUI")+"' "
cQry1 += CRLF + "  AND D_E_L_E_T_ = '' "
cQry1 := ChangeQuery(cQry1)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

// Carregar aqui as Colunas da GetDados.

If (cAliasQry)->( Eof() )
	Aadd(aColsCDoc, {})
	For nX := 1 To Len(aHeaderCDoc)
		Aadd(aColsCDoc[Len(aColsCDoc)],CriaVar(aHeaderCDoc[nX,2]))
	Next nX
	Aadd(aColsCDoc[Len(aColsCDoc)],.F.)
EndIf

While (cAliasQry)->(!Eof())
	If lDUISEROUT
		Aadd(aColsCDoc, {	(cAliasQry)->DUI_DOCTMS,;
							(cAliasQry)->DUI_SERIE,;
							(cAliasQry)->DUI_SEROUT,;
							.F.} )
	Else
		Aadd(aColsCDoc, {	(cAliasQry)->DUI_DOCTMS,;
							(cAliasQry)->DUI_SERIE,;
							.F.} )
	EndIf
	(cAliasQry)->( DbSkip() )
EndDo

(cAliasQry)->( DbCloseArea() )

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS411Trib³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta aHeader e aCols para a tela de configuração de imposto  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS411Trib()
Local lRet    := .T.
Local nX      := 0
Local aCpoGDa := { "DUG_ITEM","TIPOIMP","CFGITEM","CONFTES","DUG_TES","DUG_CODPAS","DUG_ESTORI","DUG_ESTDEV","DUG_ESTDES","DUG_CODMSG","DUG_SATIV"}

// Carrega aHead
aHeaderTrib := {}
aColsTrib   := {}

For nX := 1 to Len(aCpoGDa)
	If !(aCpoGDa[nX] $ "TIPOIMP|CONFTES|CFGITEM|")

		Aadd(aHeaderTrib,{;
		AllTrim(getSx3Cache(aCpoGDa[nX],"X3_TITULO")),; // Titulo
		aCpoGDa[nX]                          ,; // X3_CAMPO
		getSx3Cache(aCpoGDa[nX],"X3_PICTURE"),; // X3_PICTURE
		getSx3Cache(aCpoGDa[nX],"X3_TAMANHO"),; // X3_TAMANHO
		getSx3Cache(aCpoGDa[nX],"X3_DECIMAL"),; // X3_DECIMAL
		getSx3Cache(aCpoGDa[nX],"X3_VALID"  ),; // X3_VALID
		getSx3Cache(aCpoGDa[nX],"X3_USADO"  ),; // X3_USADO 
		getSx3Cache(aCpoGDa[nX],"X3_TIPO"   ),; // X3_TIPO
		getSx3Cache(aCpoGDa[nX],"X3_F3"     ),; // X3_F3
		getSx3Cache(aCpoGDa[nX],"X3_CONTEXT"),; // X3_CONTEXT
		getSx3Cache(aCpoGDa[nX],"X3_CBOX"   ),; // X3_CBOX
		getSx3Cache(aCpoGDa[nX],"X3_RELACAO")}) // X3_RELACAO


	ElseIf aCpoGDa[nX] == "TIPOIMP"
		Aadd(aHeaderTrib,{	STR0013,; // "Tipo Imposto"
							"TIPOIMP",;
							"@!",;
							1   ,;
							0   ,;
							"TMA411VCpo()",;
							""  ,;
							"C" ,;
							""  ,;
							""  ,;
							STR0014 ,; // "1=Icms Normal;2=ICMS Diferido;3=Isento;4=Substituição Tributária;5=Iss;6=ICMS Outros;Z=Item Pré Config"
							""  ,;
							""})

	ElseIf aCpoGDa[nX] == "CONFTES"
		Aadd(aHeaderTrib,{	STR0015,; // "Config. TES"
							"CONFTES",;
							"@!" ,;
							13   ,;
							0    ,;
							""   ,;
							""   ,;
							"C"  ,;
							""   ,;
							"V"  ,;
							""   ,;
							"'<< Enter >>'",;
							"TMA411Whe()"})

	ElseIf aCpoGDa[nX] == "CFGITEM"
		Aadd(aHeaderTrib,{	STR0016,; // "Item Cfg Tes"
							"CFGITEM",;
							"@!",;
							TamSx3("DUG_ITEM")[1],;
							0   ,;
							""  ,;
							""  ,;
							"C" ,;
							""  ,;
							"V" ,;
							""  ,;
							""  ,;
							"TMA411Whe()"})
	EndIf
Next nX

Aadd(aColsTrib, {})
Aadd(aColsTrib[Len(aColsTrib)],StrZero(1, TamSx3("DUG_ITEM")[1]))
Aadd(aColsTrib[Len(aColsTrib)],Space(1))
Aadd(aColsTrib[Len(aColsTrib)],Space(TamSx3("DUG_ITEM")[1]))
Aadd(aColsTrib[Len(aColsTrib)],"<< Enter >>")

For nX := 5 To Len(aHeaderTrib)
	Aadd(aColsTrib[Len(aColsTrib)],CriaVar(aHeaderTrib[nX,2]))
Next nX

Aadd(aColsTrib[Len(aColsTrib)],.F.)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS411TCli³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta aHeader e aCols para a tela de tributação de cliente    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS411TCli()
Local lRet    := .T.
Local nX      := 0
Local aCpoGDa := {"DV1_TIPNFC","DV1_CODPRO","DV1_DESPRO","DV1_TIPCLI"}

// Carrega aHead
aHeaderTCli := {}
aColsTCli   := {}

For nX := 1 to Len(aCpoGDa)

		Aadd(aHeaderTCli,{;
		AllTrim(getSx3Cache(aCpoGDa[nX],"X3_TITULO")),; // Titulo
		aCpoGDa[nX]                          ,; // X3_CAMPO
		getSx3Cache(aCpoGDa[nX],"X3_PICTURE"),; // X3_PICTURE
		getSx3Cache(aCpoGDa[nX],"X3_TAMANHO"),; // X3_TAMANHO
		getSx3Cache(aCpoGDa[nX],"X3_DECIMAL"),; // X3_DECIMAL
		getSx3Cache(aCpoGDa[nX],"X3_VALID"  ),; // X3_VALID
		getSx3Cache(aCpoGDa[nX],"X3_USADO")  ,; // X3_USADO 
		getSx3Cache(aCpoGDa[nX],"X3_TIPO"   ),; // X3_TIPO
		getSx3Cache(aCpoGDa[nX],"X3_F3")     ,; // X3_F3
		getSx3Cache(aCpoGDa[nX],"X3_CONTEXT"),; // X3_CONTEXT
		getSx3Cache(aCpoGDa[nX],"X3_CBOX")   ,; // X3_CBOX
		getSx3Cache(aCpoGDa[nX],"X3_RELACAO")}) // X3_RELACAO

Next nX

Aadd(aColsTCli, {})
For nX := 1 To Len(aHeaderTCli)
	Aadd(aColsTCli[Len(aColsTCli)],CriaVar(aHeaderTCli[nX,2]))
Next nX
Aadd(aColsTCli[Len(aColsTCli)],.F.)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMS411Vld ³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilha os campos Descrição                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMS411Vld(cCodTrib, cDescTrib, cTipFrete, lNext)
Local lRet := .T.

Default cCodTrib  := ""
Default cDescTrib := ""
Default cTipFrete := ""
Default lNext     := .F.

If !Empty(cCodTrib)
	If !Empty(Tabela("MC",cCodTrib,.F.))
		cDescTrib := Tabela("MC",cCodTrib,.F.)
	Else
		cDescTrib := Space(TamSx3("DUF_DESCRI")[1])
	EndIf
ElseIf Empty(cCodTrib) .And. lNext
	lRet := .F.
	cDescTrib := Space(TamSx3("DUF_DESCRI")[1])
EndIf

If Empty(cTipFrete) .And. lNext
	lRet := .F.
	NaoVazio()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMA411Grv ³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a gravação                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411Grv(cCodTrib, cTipFrete )
Local cCliGen   := GetMV('MV_CLIGEN')
Local cCliente  := ""
Local cLoja     := ""
Local nCount    := 0
Local nI        := 0
Local aProduto  := {}
Local aTes      := {}
Local cProduto  := ""
Local nItem     := 0
Local cItem     := ""
Local cTipoImp  := ""
Local cTes      := ""
Local cCodTes   := ""
Local lRet      := .T.
Local nPosMem   := 0
Local nCnt      := 0
Local cAliasQry := ""
Local cQry1     := ""
Local nPosCpo   := 0

lMsHelpAuto := .T.
lMsErroAuto := .F.

If !Empty(cCliGen)
	cCliente := Posicione("SA1",1,xFilial("SA1")+cCliGen,"A1_COD")
	cLoja    := SA1->A1_LOJA
EndIf

Begin Transaction

	SB1->(DbSetOrder(1))
	For nCount := 1 To Len(oNewAliq:aCols)
		If !GdDeleted(nCount, oNewAliq:aHeader, oNewAliq:aCols ) .And. oNewAliq:aCols[nCount, GdFieldPos("ALIQUOTA",oNewAliq:aHeader)] <> 0
			cProduto := "999999" + AllTrim(STR(oNewAliq:aCols[nCount, GdFieldPos("ALIQUOTA",oNewAliq:aHeader)]))
			If !SB1->(MsSeek(xFilial("SB1")+cProduto ))

				aProduto := {}
				Aadd(aProduto,{"B1_COD",cProduto,NIL})
				Aadd(aProduto,{"B1_DESC",STR0017 + AllTrim(STR(oNewAliq:aCols[nCount, GdFieldPos("ALIQUOTA",oNewAliq:aHeader)])),NIL})
				Aadd(aProduto,{"B1_TIPO","PA",NIL})
				Aadd(aProduto,{"B1_UM","CX",NIL})
				Aadd(aProduto,{"B1_LOCPAD","01",NIL})
				Aadd(aProduto,{"B1_PICM", oNewAliq:aCols[nCount, GdFieldPos("ALIQUOTA",oNewAliq:aHeader)],NIL})

				MSExecAuto({|x| mata010(x)},aProduto,3)

				If lMsErroAuto
					MostraErro()
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nCount

	DUI->(DbSetOrder(1))
	For nCount := 1 To Len(oNewCDoc:aCols)
		If !GdDeleted(nCount, oNewCDoc:aHeader, oNewCDoc:aCols)
			If !DUI->(MsSeek(xFilial("DUI")+oNewCDoc:aCols[nCount, GdFieldPos("DUI_DOCTMS",oNewCDoc:aHeader)]))
				RecLock("DUI",.T.)
				DUI->DUI_FILIAL := xFilial("DUI")
				DUI->DUI_DOCTMS := oNewCDoc:aCols[nCount, GdFieldPos("DUI_DOCTMS",oNewCDoc:aHeader)]
				DUI->DUI_SERIE  := oNewCDoc:aCols[nCount, GdFieldPos("DUI_SERIE" ,oNewCDoc:aHeader)]
				If lDUISEROUT
					DUI->DUI_SEROUT := oNewCDoc:aCols[nCount, GdFieldPos("DUI_SEROUT",oNewCDoc:aHeader)]
				EndIf
				DUI->DUI_CODPRO := SB1->B1_COD
				MsUnLock()
			EndIf
		EndIf
	Next nCount

	DUF->(DbSetOrder(1))
	If !DUF->(MsSeek(xFilial("DUF")+cCodTrib+cTipFrete))
		RecLock("DUF",.T.)
		DUF->DUF_FILIAL  := xFilial("DUF")
		DUF->DUF_REGTRIB := cCodTrib
		DUF->DUF_TIPFRE  := cTipFrete
		MsUnLock()
	EndIf

	DUG->(DbSetOrder(2))
	oNewTrib:aCols := aSort(oNewTrib:aCols,,,{|x,y| x[GdFieldPos("TIPOIMP",oNewTrib:aHeader)]+x[GdFieldPos("DUG_ITEM",oNewTrib:aHeader)] < y[GdFieldPos("TIPOIMP",oNewTrib:aHeader)]+y[GdFieldPos("DUG_ITEM",oNewTrib:aHeader)]} )
	For nCount:= 1 To Len(oNewTrib:aCols)
		If !GdDeleted(nCount, oNewTrib:aHeader, oNewTrib:aCols)
			If !DUG->(MsSeek(xFilial("DUG")+cCodTrib+cTipFrete+oNewTrib:aCols[nCount, GdFieldPos("DUG_CODPAS",oNewTrib:aHeader)]+;
				oNewTrib:aCols[nCount, GdFieldPos("DUG_ESTORI",oNewTrib:aHeader)]+	;
				oNewTrib:aCols[nCount, GdFieldPos("DUG_ESTDEV",oNewTrib:aHeader)]+;
				oNewTrib:aCols[nCount, GdFieldPos("DUG_ESTDES",oNewTrib:aHeader)]+;
				oNewTrib:aCols[nCount, GdFieldPos("DUG_SATIV",oNewTrib:aHeader)]+;
				Padr("3", TamSx3("DUG_CONSIG")[1]) ))

				cTipoImp := oNewTrib:aCols[nCount, GdFieldPos("TIPOIMP",oNewTrib:aHeader)]
				cTes     := oNewTrib:aCols[nCount, GdFieldPos("DUG_TES",oNewTrib:aHeader)]

				oNewTrib:nAt := nCount
				cItem    := StrZero(oNewTrib:nAt,3)
				aTes     := {}

				If !Empty(cTipoImp) .And. cTipoImp <> "Z" .And. Empty(cTes)

					nPosMem := Ascan(aMemSF4,{ | e | e[1] == cItem+cTipoImp })
					If nPosMem == 0
						aTes := aClone(TM411CgTes(cTipoImp))
					Else
						For nCnt := 1 To Len(aMemSF4[nPosMem,2])
							Aadd(aTes,{AllTrim(aMemSF4[nPosMem,2,nCnt,1]), aMemSF4[nPosMem,2,nCnt,2], Nil})
						Next nCnt
					EndIf

					nPosCpo := Ascan(aTes,{ |x| x[1] == "F4_CODIGO" })

					cAliasQry := GetNextAlias()
					cQry1 := CRLF + "SELECT MAX(F4_CODIGO) AS CODIGO "
					cQry1 += CRLF + "FROM " + RetSqlName("SF4") + " SF4 "
					cQry1 += CRLF + "WHERE F4_FILIAL = '"+xFilial("SF4")+"' "
					cQry1 += CRLF + "AND F4_TIPO = 'S' "
					cQry1 += CRLF + "AND D_E_L_E_T_ = '' "

					cQry1 := ChangeQuery(cQry1)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry1),cAliasQry, .F., .T.)

					If !Empty((cAliasQry)->CODIGO)
						cCodTes := AllTrim( Str( (Val((cAliasQry)->CODIGO) + oNewTrib:nAt) ) )
					Else
						cCodTes := "501"
					EndIf

					(cAliasQry)->(DbCloseArea())

					aTes[nPosCpo,2] := cCodTes

					MSExecAuto({|x,y| mata080(x,y)},aTes,3)
					If lMsErroAuto
						MostraErro()
						lRet := .F.
						Exit
					Else
						oNewTrib:aCols[nCount, GdFieldPos("DUG_TES",oNewTrib:aHeader)] := cCodTes
					EndIf

				ElseIf !Empty(cTes)
					cCodTes := cTes
				ElseIf cTipoImp == "Z"
					nPosCpo := aScan(oNewTrib:aCols,{|x| x[GdFieldPos("DUG_ITEM",oNewTrib:aHeader)] == oNewTrib:aCols[nCount, GdFieldPos("CFGITEM",oNewTrib:aHeader)]})
					If nPosCpo > 0
						cCodTes := oNewTrib:aCols[nPosCpo, GdFieldPos("DUG_TES",oNewTrib:aHeader)] 
					EndIf
				EndIf

				//-- Obtem o proximo item
				cAliasQry  := GetNextAlias()
				cQuery := "SELECT MAX(DUG_ITEM) DUG_ITEM"
				cQuery += "  FROM " + RetSQLTab('DUG')
				cQuery += " WHERE DUG_FILIAL = '" + xFilial('DUG') + "'"
				cQuery += "   AND DUG_REGTRI = '" + cCodTrib       + "'"
				cQuery += "   AND DUG_TIPFRE = '" + cTipFrete      + "'"
				cQuery += "   AND D_E_L_E_T_ = ''"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				If (cAliasQry)->(!Eof())
					cItem := Soma1((cAliasQry)->DUG_ITEM)
				Else
					cItem := StrZero(1,Len(DUG->DUG_ITEM))
				EndIf
				(cAliasQry)->(dbCloseArea())

				RecLock("DUG",.T.)
				DUG->DUG_FILIAL := xFilial("DUG")
				DUG->DUG_REGTRI := cCodTrib
				DUG->DUG_TIPFRE := cTipFrete
				DUG->DUG_ITEM   := cItem
				DUG->DUG_TES    := cCodTes
				DUG->DUG_CODPAS := oNewTrib:aCols[nCount, GdFieldPos("DUG_CODPAS",oNewTrib:aHeader)]
				DUG->DUG_ESTORI := oNewTrib:aCols[nCount, GdFieldPos("DUG_ESTORI",oNewTrib:aHeader)]
				DUG->DUG_ESTDEV := oNewTrib:aCols[nCount, GdFieldPos("DUG_ESTDEV",oNewTrib:aHeader)]
				DUG->DUG_ESTDES := oNewTrib:aCols[nCount, GdFieldPos("DUG_ESTDES",oNewTrib:aHeader)]
				DUG->DUG_SATIV  := oNewTrib:aCols[nCount, GdFieldPos("DUG_SATIV" ,oNewTrib:aHeader)]
				DUG->DUG_CONSIG := Padr("3", TamSx3("DUG_CONSIG")[1])
				MsUnLock()
			EndIf
		EndIf
	Next nCount

	DY5->(DbSetOrder(1))
	For nCount := 1 To Len(oNewCF:aCols)
		If !GdDeleted(nCount, oNewCF:aHeader, oNewCF:aCols)
			If !DY5->(MsSeek(xFilial("DY5")+oNewCF:aCols[nCount, GdFieldPos("DY5_CF",oNewCF:aHeader)]+;
						oNewCF:aCols[nCount, GdFieldPos("DY5_SATIV",oNewCF:aHeader)]))
				RecLock("DY5",.T.)
				DY5->DY5_FILIAL := xFilial("DY5")
				DY5->DY5_CF     := oNewCF:aCols[nCount, GdFieldPos("DY5_CF",oNewCF:aHeader)]
				DY5->DY5_SATIV  := oNewCF:aCols[nCount, GdFieldPos("DY5_SATIV",oNewCF:aHeader)]
				MsUnLock()
			EndIf
		EndIf
	Next nCount

	DV1->(DbSetOrder(1))
	For nCount := 1 To Len(oNewTCli:aCols)
		If !GdDeleted(nCount, oNewTCli:aHeader, oNewTCli:aCols)
			For nI := 1 To Len(oNewCDoc:aCols)
				If !GdDeleted(nI, oNewCDoc:aHeader, oNewCDoc:aCols)
					If !DV1->(MsSeek(xFilial("DV1")+cCliente+cloja+oNewCDoc:aCols[nI, GdFieldPos("DUI_DOCTMS",oNewCDoc:aHeader)]+;
					oNewTCli:aCols[nCount, GdFieldPos("DV1_CODPRO",oNewTCli:aHeader)]+;
					oNewTCli:aCols[nCount, GdFieldPos("DV1_TIPNFC",oNewTCli:aHeader)]+;
					PADR(oNewTCli:aCols[nCount, GdFieldPos("DV1_TIPCLI",oNewTCli:aHeader)],Len(DV1->DV1_TIPCLI))+;
					Space(TamSx3("DV1_SEQINS")[1])+cCodTrib))

						RecLock("DV1",.T.)
						DV1->DV1_FILIAL := xFilial("DV1")
						DV1->DV1_TIPNFC := oNewTCli:aCols[nCount, GdFieldPos("DV1_TIPNFC",oNewTCli:aHeader)]
						DV1->DV1_CODPRO := oNewTCli:aCols[nCount, GdFieldPos("DV1_CODPRO",oNewTCli:aHeader)]
						DV1->DV1_TIPCLI := oNewTCli:aCols[nCount, GdFieldPos("DV1_TIPCLI",oNewTCli:aHeader)]
						DV1->DV1_CODCLI := cCliente
						DV1->DV1_LOJCLI := cLoja
						DV1->DV1_DOCTMS := oNewCDoc:aCols[nI, GdFieldPos("DUI_DOCTMS",oNewCDoc:aHeader)]
						DV1->DV1_REGTRI := cCodTrib
						MsUnLock()
						
					EndIf
				EndIf
			Next nI
		EndIf
	Next nCount
	If !lRet
		DisarmTransaction()
		Break
	EndIf
End Transaction

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMA411Whe³  Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Habilita ou não os campos temporarios                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411Whe()
Local lRet   := .F.
Local cCampo := ReadVar()

If cCampo == "M->CONFTES"
	If oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("TIPOIMP",oNewTrib:aHeader)] <> "Z" .And.;
		Empty(oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("DUG_TES",oNewTrib:aHeader)])
		TMA411CfgI()
	EndIf
ElseIf cCampo == "M->CFGITEM"
	If oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("TIPOIMP",oNewTrib:aHeader)] == "Z" .And.;
		Empty(oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("DUG_TES",oNewTrib:aHeader)])
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMA411CfgI Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre janela para configuração do imposto                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411CfgI()
Local oDlg     := Nil
Local oEncSf4  := Nil
Local lOk      := .F.
Local cItem    := StrZero(oNewTrib:nAt,3)
Local cTipoImp := oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("TIPOIMP",oNewTrib:aHeader)]
Local cTes     := oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("DUG_TES",oNewTrib:aHeader)]
Local nPosMem  := 0
Local cCpoSF4  := ''
Local nPosSX3  := 0
Local cCpoSX3  := ''
Local nCnt     := 0
Local aTes     := {}
Local oSF4Stru := FwFormStruct(2,"SF4")
Local nX       := 1

Private aTELA[0][0]
Private aGETS[0]

If !Empty(cTipoImp) .And. Empty(cTes)

	DEFINE MSDIALOG oDlg FROM 00,00 TO 390,650 PIXEL TITLE STR0018	// -- "Configuração do Imposto"

	RegToMemory("SF4",.T.)
	nPosMem := Ascan(aMemSF4,{ | e | e[1] == cItem+cTipoImp })
	If nPosMem > 0
		For nCnt := 1 To Len(aMemSF4[nPosMem,2])
			cCpoSF4 := aMemSF4[nPosMem,2,nCnt,1]
			M->&(cCpoSF4) := aMemSF4[nPosMem,2,nCnt,2]
		Next nCnt
	Else
		aTes := aClone(TM411CgTes(cTipoImp))
		For nCnt := 1 To Len(aTes)
			M->&(aTes[nCnt,1]) := Padr(aTes[nCnt,2], TAMSX3(aTes[nCnt,1])[1])
		Next nCnt
	EndIf

	oEncSf4 := MsMGet():New("SF4",0,4,,,,,{13,0,197,327},,,,,,oDlg)

	ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| lOk := .T.,;
			Iif(Obrigatorio(oEncSf4:aGets,oEncSf4:aTela),oDlg:End(),lOk := .F.)},;
			{|| oDlg:End()},,))

	If lOk
		If nPosMem == 0
			Aadd(aMemSF4,{ cItem+cTipoImp, {} })
			nPosMem := Len(aMemSF4)
		EndIf

		//-- Carrega o array aMemSF4 com FwFormStruct
		While nX <= Len(oSF4Stru:aFields)
			cCpoSX3 := oSF4Stru:aFields[nX,1]
			nPosSX3 := Ascan(aMemSF4[nPosMem,2],{ | e | e[1] == cCpoSX3 })
			If nPosSX3 == 0
				Aadd(aMemSF4[nPosMem,2],{ cCpoSX3, M->&(cCpoSX3) })
			Else
				aMemSF4[nPosMem,2,nPosSX3,2] := M->&(cCpoSX3)
			EndIf
			nX++
		EndDo
	EndIf
Else
	Help(" ",1,"TMSA41102") // ("Não foi possivel completar a operaçao. Campo TES já preenchido!")
EndIf

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TM411CgTes Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Array com informaçoes Default por tipo de imposto    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TM411CgTes(cTipoImp)
Local aTes    := {}
Local aTxtTES := StrTokArr(SuperGetMv("MV_TXTTES",.F.,"1=SERV.TRANSPORTE;2=SERV.TRANSPORTE;3=SERV.TRANSPORTE ST;4=NF DE SERVICO"),";")
Local cTxtTES := ""
Local nPosTxt := 0

Default cTipoImp := ''

nPosTxt := Ascan(aTxtTES,{|x| Substr(x,1,1) == cTipoImp })
If nPosTxt > 0
	cTxtTES := Substr(aTxtTES[nPosTxt],3)
Endif

Aadd(aTes,{"F4_CODIGO" ,Replicate("X",TamSX3('F4_CODIGO')[1]),Nil})
Aadd(aTes,{"F4_TIPO"   ,"S"    ,Nil})
Aadd(aTes,{"F4_CREDICM","N"    ,Nil})
Aadd(aTes,{"F4_CREDIPI","N"    ,Nil})
Aadd(aTes,{"F4_DUPLIC" ,"S"    ,Nil})
Aadd(aTes,{"F4_ESTOQUE","N"    ,Nil})
Aadd(aTes,{"F4_PODER3" ,"N"    ,Nil})
Aadd(aTes,{"F4_IPI"    ,"N"    ,Nil})
Aadd(aTes,{"F4_CF"     ,"99943",Nil})
Aadd(aTes,{"F4_TEXTO"  ,cTxtTES,Nil})
Aadd(aTes,{"F4_LFIPI"  ,"N"    ,Nil})
Aadd(aTes,{"F4_DESTACA","N"    ,Nil})
Aadd(aTes,{"F4_INCIDE" ,"N"    ,Nil})
Aadd(aTes,{"F4_COMPL"  ,"N"    ,Nil})

If cTipoImp == '1' //-- ICMS Normal
	Aadd(aTes,{"F4_ICM"    ,"S"     ,Nil})
	Aadd(aTes,{"F4_LFICM"  ,"T"     ,Nil})
	Aadd(aTes,{"F4_SITTRIB","00"    ,Nil})
	Aadd(aTes,{"F4_AGREG"  ,"I"     ,Nil})
	Aadd(aTes,{"F4_ISS"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFISS"  ,"N"     ,Nil})
ElseIf cTipoImp == '2' //-- ICMS Diferido
	Aadd(aTes,{"F4_ICM"    ,"S"     ,Nil})
	Aadd(aTes,{"F4_LFICM"  ,"T"     ,Nil})
	Aadd(aTes,{"F4_SITTRIB","00"    ,Nil})
	Aadd(aTes,{"F4_AGREG"  ,"I"     ,Nil})
	Aadd(aTes,{"F4_ISS"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFISS"  ,"N"     ,Nil})
ElseIf cTipoImp == '3' //-- Isento
	Aadd(aTes,{"F4_ICM"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFICM"  ,"N"     ,Nil})
	Aadd(aTes,{"F4_SITTRIB","40"    ,Nil})
	Aadd(aTes,{"F4_AGREG"  ,"S"     ,Nil})
	Aadd(aTes,{"F4_ISS"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFISS"  ,"N"     ,Nil})
ElseIf cTipoImp == '4' //-- Substituição
	Aadd(aTes,{"F4_ICM"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFICM"  ,"T"     ,Nil})
	Aadd(aTes,{"F4_SITTRIB","10"    ,Nil})
	Aadd(aTes,{"F4_AGREG"  ,"I"     ,Nil})
	Aadd(aTes,{"F4_ISS"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFISS"  ,"N"     ,Nil})
	Aadd(aTes,{"F4_INCSOL" ,"D"     ,Nil})
	Aadd(aTes,{"F4_ICMSST" ,"S"     ,Nil})
ElseIf cTipoImp == '5' //-- ISS
	Aadd(aTes,{"F4_ICM"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFICM"  ,"N"     ,Nil})
	Aadd(aTes,{"F4_SITTRIB","90"    ,Nil})
	Aadd(aTes,{"F4_AGREG"  ,"S"     ,Nil})
	Aadd(aTes,{"F4_ISS"    ,"S"     ,Nil})
	Aadd(aTes,{"F4_LFISS"  ,"T"     ,Nil})
ElseIf cTipoImp == '6' //-- ICMS Outros
	Aadd(aTes,{"F4_ICM"    ,"S"     ,Nil})
	Aadd(aTes,{"F4_LFICM"  ,"O"     ,Nil})
	Aadd(aTes,{"F4_SITTRIB","00"    ,Nil})
	Aadd(aTes,{"F4_AGREG"  ,"I"     ,Nil})
	Aadd(aTes,{"F4_ISS"    ,"N"     ,Nil})
	Aadd(aTes,{"F4_LFISS"  ,"N"     ,Nil})
EndIf

Return(aTes)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMA411VDoc Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Linha do GRID Documentos de Transporte                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411VDoc()
Local lRet := .T.

aHeader := oNewCDoc:aHeader
aCols   := oNewCDoc:aCols
n       := oNewCDoc:nAt

If !GDdeleted(n)
	lRet := GDCheckKey( {"DUI_DOCTMS","DUI_SERIE"}, 4 )
	If lRet .And. ( Empty(aCols[n, GdFieldPos("DUI_DOCTMS")]) .Or. Empty(aCols[n, GdFieldPos("DUI_SERIE")]) )
		lRet := .F.
		NaoVazio()
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMA411VImp Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Linha do GRID Tributação                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411VImp()

Local lRet := .T.
Local nPos := 0

aHeader := oNewTrib:aHeader
aCols   := oNewTrib:aCols
n       := oNewTrib:nAt

If !GDdeleted(n)

	lRet := GDCheckKey( { "TIPOIMP", "CFGITEM", "DUG_CODPAS","DUG_ESTORI","DUG_ESTDEV","DUG_ESTDES","DUG_CODMSG","DUG_SATIV"}, 4 )

	If lRet .And. ( Empty(aCols[n, GdFieldPos("TIPOIMP")]) .And. Empty(aCols[n, GdFieldPos("DUG_TES")]) )
		lRet := .F.
		NaoVazio()
	ElseIf lRet .And. !Empty(aCols[n, GdFieldPos("DUG_TES")])
		If Val(aCols[n, GdFieldPos("DUG_TES")]) <= 500
			lRet := .F.
			Help(" ",1,"F4_TIPO")
		EndIf
	ElseIf aCols[n, GdFieldPos("TIPOIMP")] == "Z"
		If Empty(aCols[n, GdFieldPos("CFGITEM")])
			lRet := .F.
			NaoVazio()
		ElseIf aCols[n, GdFieldPos("CFGITEM")] == aCols[n, GdFieldPos("DUG_ITEM")]
			lRet := .F.
			Help(" ",1,"TMSA41103") // ("Item nao é valido para cópia")
		Else
			nPos := aScan(aCols,{|x| x[(GdFieldPos("DUG_ITEM"))] == aCols[n, GdFieldPos("CFGITEM")] })
			If nPos > 0
				If aCols[nPos, GdFieldPos("TIPOIMP")] == "Z"
					lRet := .F.
					Help(" ",1,"TMSA41103")  // ("Item nao é valido para cópia")
				EndIf
			Else
				lRet := .F.
				Help(" ",1,"TMSA41103") // ("Item nao é valido para cópia")
			EndIf
		EndIf
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMA411VCpo Autor ³Marcelo Corrêa Coutinho ³ Data ³08.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campos                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411VCpo()
Local lRet   := .T.
Local cCampo := ReadVar()

If cCampo == "M->TIPOIMP"
	If Len( aCols ) == 1 .And. &cCampo == 'Z'
		&cCampo := Space( Len( &cCampo ) )
		lRet    := .F.
	EndIf
	If !Empty(&cCampo)
		oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("DUG_TES",oNewTrib:aHeader)] := Space(TamSx3("DUG_TES")[1])
		If oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("TIPOIMP",oNewTrib:aHeader)] == "Z"
			oNewTrib:aCols[oNewTrib:nAt, GdFieldPos("CFGITEM",oNewTrib:aHeader)] := Space(TamSx3("DUG_ITEM")[1])
		EndIf
	EndIf

ElseIf cCampo == "M->DUG_TES"
	If !GDdeleted(n)
		If Val(&cCampo) <= 500
			lRet := .F.
			Help(" ",1,"TMSA41105")
		EndIf
	EndIf

ElseIf cCampo == "M->CFGITEM"
	lRet := GDCheckKey( { "TIPOIMP", "CFGITEM"}, 4 )
	If Empty( &cCampo )
		lRet := .f.
		NaoVazio()
	EndIf

	If Val( &cCampo ) > Len( aCols )
		&cCampo := Space( Len( &cCampo ) )
		lRet    := .F.
	EndIf

	If lRet .And. aCols[ Val( &cCampo ), GdFieldPos("TIPOIMP")] == 'Z'
		lRet := .F.
		Help(" ",1,"TMSA41107") //-- Não é possível apontar um Item Pré-Configurado, para outro Item Pré-Configurado.
	EndIf
ElseIf cCampo == "M->ALIQUOTA"

	If !( lRet := VldAliqIcm( M->ALIQUOTA ) )
		Help(" ",1,"B1_PICM")
	EndIf

EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TM411DlImp Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o item no GRID Tributação pode ser excluido        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TM411DlImp()
Local lRet := .T.

nPos := aScan(aCols,{|x| x[(GdFieldPos("CFGITEM"))] == aCols[n, GdFieldPos("DUG_ITEM")] })
If nPos > 0
	lRet := .F.
	Help(" ",1,"TMSA41104") // ("Item não pode ser excluído, pois está relacionado para cópia!")
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMA411VCf ³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Linha do GRID CFOP x Segmento                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411VCf()
Local lRet := .T.

aHeader := oNewCF:aHeader
aCols   := oNewCF:aCols
n       := oNewCF:nAt

If !GDdeleted(n)
	lRet := GDCheckKey( {"DY5_CF","DY5_SATIV"}, 4 )
	If lRet .And. ( Empty(aCols[n, GdFieldPos("DY5_CF")]) .Or. Empty(aCols[n, GdFieldPos("DY5_SATIV")]) )
		lRet := .F.
		NaoVazio()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMA411RgCf  Autor ³Marcelo Corrêa Coutinho³ Data ³08.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Campo CFOP e Seguimento                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411RgCf()
Local lRet      := .T.
Local cCampo    := ReadVar()

aHeader := oNewCF:aHeader
aCols   := oNewCF:aCols

If !GDdeleted(n)

	If Empty(&cCampo)
		lRet := .F.
		NaoVazio()
	EndIf

	If lRet
		If cCampo == "M->DY5_CF"
			lRet := !Empty(Tabela("13",&cCampo,.F.))
			If lRet .And. ! SubStr( &cCampo, 1, 1 ) $ '5;6;7'
				lRet := .F.
				Help(" ",1,"TMSA41109") //-- Não é permitido CFOP de Entrada. Informe CFOP de Saída.
			EndIf

		ElseIf cCampo == "M->DY5_SATIV"
			lRet := !Empty(tabela("T3",&cCampo,.F.))
			If lRet
				lRet := ( Ascan( aCols, { |x| x[ GdFieldPos( "DY5_SATIV" ) ] == &cCampo } ) == 0 )
				If !lRet
					lRet := .f.
					Help(" ",1,"TMSA41106") //-- Não é possível configurar o Segmento informado, para mais de uma CFOP´s.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMA411VAlq Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Linha do GRID Aliquota interna                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411VAlq()
Local lRet := .T.

aHeader := oNewAliq:aHeader
aCols   := oNewAliq:aCols
n       := oNewAliq:nAt

If aCols[n, GdFieldPos("ALIQUOTA")] <= 0
	lRet := .F.
	NaoVazio()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMA411VCli³ Autor ³Jefferson Tomaz        ³ Data ³08.02.2011  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Linha do GRID Tributação por cliente                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA411VCli()
Local lRet := .T.

aHeader := oNewTCli:aHeader
aCols   := oNewTCli:aCols
n       := oNewTCli:nAt

If !GDdeleted(n)
	lRet := GDCheckKey( {"DV1_TIPNFC","DV1_CODPRO","DV1_TIPCLI"}, 4 )
EndIf

Return lRet
