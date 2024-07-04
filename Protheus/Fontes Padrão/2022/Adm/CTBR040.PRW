#Include "Ctbr040.Ch"
#Include "PROTHEUS.Ch"
#Include "FWLIBVERSION.CH"

#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_SALDO_ANT    	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_VLR_DEBITO   	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_VLR_CREDITO  	10
#DEFINE 	COL_SEPARA6			11

#DEFINE 	COL_MOVIMENTO 		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_SALDO_ATU 		14
#DEFINE 	COL_SEPARA8			15
#DEFINE 	TAM_VALOR			20

Static cTpValor  := "D"
Static lLibVers  := FwLibVersion() >= "20211004"

//Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr040	³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbr040()                               			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctbr040()
Local lImpBalR4		:= TRepInUse()

Private titulo		:= ""
Private nomeprog	:= "CTBR040"

cTpValor := Alltrim(GetMV("MV_TPVALOR"))

If Select("cArqTmp") > 0
	cArqTmp->(dbCloseArea())
EndIf

If lImpBalR4
	CTBR040R4()
Else
//Informando que os relatórios R3 serão descontinuados
	DESCONTR3()
	CTBR040R3()
EndIf

//Limpa os arquivos temporários
CTBGerClean()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR040R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 01/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1 - R4                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR040R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR040R4(wnRel)
Local nQuadro		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aQuadro		:= { "","","","","","","",""}
Private aSelFil		:= {}
Private n_pagini	:= 0

Default wnRel		:= ""

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next

CtbCarTxt()

Pergunte("CTR040",.F.)

oReport := ReportDef(wnRel)

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf

	oReport:PrintDialog()
Endif

oReport := Nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 28/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(wnRel)
local aArea	   		:= GetArea()
Local CREPORT		:= "CTBR040"
Local CTITULO		:= STR0006				   			// "Emissao do Relat. Conf. Dig. "
Local CDESC			:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)			// "Este programa ira imprimir o Relatorio para Conferencia"
Local cPerg	   		:= "CTR040"
Local CCOLBAR		:= "|"
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= {40}
Local cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Local nDecimais		:= 0
Local cMascara		:= ""
Local cSeparador	:= ""
Local nTamConta		:= 20
Local aSetOfBook	:= {}
Local nMaskFator 	:= 1

Default wnRel		:= ""

// Efetua a pergunta antes de montar a configuração do relatorio, afim de poder definir o layout a ser impresso
Pergunte( "CTR040" , .T. )

If mv_par30 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		Return
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)	    	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! ct040Valid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf( mv_par06 )
Endif


cMascara := RetMasCtb( aSetOfBook[2], @cSeparador )

If ! Empty( cMascara )
	nTamConta := aTamConta[1] + ( Len( Alltrim( cMascara ) ) / 2 )
Else
	nTamConta := aTamConta[1]
EndIf

cPicture := PesqPict("CT2","CT2_VALOR")//aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport,Capital(CTITULO),cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport, wnRel ), oReport:CancelPrint(), .T. ) }, CDESC )
oReport:ParamReadOnly()

If lLibVers
	//Parametriza o TReport para alinhamento a direita 
	oReport:SetRightAlignPrinter(.T.)
EndIf

//Habilitado o parametro de personalização porém,
// não será permitido a alteração das sections
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1  := TRSection():New( oReport, STR0027, {"cArqTmp","CT1"},, .F., .F.,,,,,,,,,0 ) //"Plano de contas"


TRCell():New( oSection1, "CONTA"	,,STR0028/*Titulo*/	,/*Picture*/, min(nTamConta, 25) + 10	 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,.T.,/*"LEFT"*/,,5,.F.)
TRCell():New( oSection1, "DESCCTA"  ,,STR0029/*Titulo*/	,/*Picture*/, aTamDesc[1]/*Tamanho*/, /*lPixel*/,/*CodeBlock*/,  /*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)

TRCell():New( oSection1, "SALDOANT" ,,STR0030/*Titulo*/	,/*Picture*/, TAM_VALOR+5 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, If(lLibVers,"RIGHT",/*"RIGHT"*/),,"RIGHT",,,.F.)
TRCell():New( oSection1, "SALDODEB" ,,IIF(cPaisLoc == 'RUS',STR0031,AnsiToOEM(NoAcento(STR0031)))/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, If(lLibVers,"RIGHT",/*"RIGHT"*/),,"RIGHT",,,.F.)
TRCell():New( oSection1, "SALDOCRD" ,,IIF(cPaisLoc == 'RUS',STR0032,AnsiToOEM(NoAcento(STR0032)))/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, If(lLibVers,"RIGHT",/*"RIGHT"*/),,"RIGHT",,,.F.)
TRCell():New( oSection1, "MOVIMENTO",,STR0033/*Titulo*/	,/*Picture*/, TAM_VALOR+5 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, If(lLibVers,"RIGHT",/*"RIGHT"*/),,"RIGHT",,,.F.)
TRCell():New( oSection1, "SALDOATU" ,,STR0034/*Titulo*/	,/*Picture*/, TAM_VALOR+5 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, If(lLibVers,"RIGHT",/*"RIGHT"*/),,"RIGHT",,,.F.)

TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqTMP->CONTA })

oSection1:Cell("CONTA"):lHeaderSize		:= .F.
oSection1:Cell("DESCCTA"):lHeaderSize	:= .F.
oSection1:Cell("SALDOANT"):lHeaderSize	:= .F.
oSection1:Cell("SALDODEB"):lHeaderSize	:= .F.
oSection1:Cell("SALDOCRD"):lHeaderSize	:= .F.
oSection1:Cell("MOVIMENTO"):lHeaderSize	:= .F.
oSection1:Cell("SALDOATU"):lHeaderSize	:= .F.

oSection1:SetTotalInLine(.F.)
oSection1:SetTotalText('') //STR0011) //"T O T A I S  D O  P E R I O D O: "
oSection1:SetEdit(.F.)

Return( oReport )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius	³ Data ³ 28/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, wnRel )

Local oSection1 	:= oReport:Section(1)
Local lExterno		:= .F.
Local aSetOfBook	:= {}
Local dDataFim 		:= mv_par02
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lRet			:= .T.
Local lPrintZero	:= (mv_par18==1)
Local lPula			:= (mv_par17==1)
Local lNormal		:= (mv_par19==1)
Local lVlrZerado	:= (mv_par07==1)
Local lQbGrupo		:= (mv_par11==1)
Local lQbConta		:= (mv_par11==2)
Local l132			:= .T.
Local nDecimais		:= 0
Local nDivide		:= 1
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0
Local cSegAte   	:= mv_par21
Local nDigitAte		:= 0
Local lImpAntLP		:= (mv_par22 == 1)
Local dDataLP		:= mv_par23
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lRecDesp0		:= (mv_par25 == 1)
Local lImpMov		:= (mv_par16 == 1)
Local cRecDesp		:= mv_par26
Local dDtZeraRD		:= mv_par27
Local n				:= 0
Local oMeter		:= Nil
Local oText			:= Nil
Local oDlg			:= Nil
Local oBreak		:= Nil
Local lImpPaisgm	:= .F.
Local nMaxLin   	:= mv_par28
Local cMoedaDsc		:= mv_par29
Local aCtbMoeda		:= {}
Local aCtbMoedadsc	:= {}
Local CCOLBAR		:= "|"
Local cTipoAnt		:= ""
Local cGrupoAnt		:= ""
Local cArqTmp		:= ""
Local Tamanho		:= "M"
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local oTotGerDeb	:= Nil
Local oTotGerCrd	:= Nil
Local oTotGerMov	:= Nil
Local oTotGrpMov	:= Nil
Local cPicture		:= ""
Local cContaSint	:= ""
Local cBreak		:= "2"
Local cGrupo		:= ""
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotGerMov	:= 0
Local nCont			:= 0
Local cFilUser		:= ""
Local nMasc			:= 0
Local cMasc			:= ""
Local lEnd			:= .F.
Local dDataRef		:= Ctod("//")
Local lColDbCr 		:= .T. // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local lRedStorn  	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn
Local lPlanilha := .F.
Local nStart		:= 0

Private nLinReport	:= 9

Default wnRel		:= ""

//Iniciar telemetria - Tempo médio
If __lMetric
	nStart := Seconds()
EndIf
If oReport:nDevice == 4
	lPlanilha := .T.
EndIf

n_pagini 	  := MV_PAR09

If oReport:nDevice == 5 .OR. oReport:nDevice == 3
	oSection1:Cell("SALDOANT"):SetAlign("RIGHT")
	oSection1:Cell("SALDODEB"):SetAlign("RIGHT")
	oSection1:Cell("SALDOCRD"):SetAlign("RIGHT")
	oSection1:Cell("MOVIMENTO"):SetAlign("RIGHT")
	oSection1:Cell("SALDOATU"):SetAlign("RIGHT")
Endif 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)	    	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! ct040Valid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If mv_par20 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par20 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par20 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

aSetOfBook[9] := nDivide

If lRet
	aCtbMoeda := CtbMoeda( mv_par08 , nDivide )

	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
		Return lRet
	Endif

    // validação da descrição da moeda
	if lRet .And. ! Empty( mv_par29 ) .and. mv_par29 <> nil
		aCtbMoedadsc := CtbMoeda( mv_par29 , nDivide )

		If Empty( aCtbMoedadsc[1] )
    		Help( " " , 1 , "NOMOEDA")
	        lRet := .F.
    	    Return lRet
	    Endif
	Endif
Endif

If lRet
	If (mv_par25 == 1) .and. ( Empty(mv_par26) .or. Empty(mv_par27) )
		cMensagem	:= STR0025	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= STR0026	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,STR0035)	 //"Ignora Sl Ant.Rec/Des"
		lRet    	:= .F.
	    Return lRet
    EndIf
EndIf

aCtbMoeda  	:= CtbMoeda(mv_par08,nDivide)

If cPaisLoc == 'RUS'
	cDescMoeda 	:= Alltrim(aCtbMoeda[3])
Else
	cDescMoeda 	:= Alltrim(aCtbMoeda[2])
EndIf
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par08)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf

cPicture 		:= PesqPict("CT2","CT2_VALOR") //aSetOfBook[4]

lPrintZero	:= Iif(mv_par18==1,.T.,.F.)

If Upper( AllTrim( oReport:Title() ) ) == Upper( AllTrim( oReport:cRealTitle ) )
	IF mv_par05 == 1
		Titulo:=	OemToAnsi(STR0009)	//"BALANCETE DE VERIFICACAO SINTETICO DE "
	ElseIf mv_par05 == 2
		Titulo:=	OemToAnsi(STR0006)	//"BALANCETE DE VERIFICACAO ANALITICO DE "
	ElseIf mv_par05 == 3
		Titulo:=	OemToAnsi(STR0017)	//"BALANCETE DE VERIFICACAO DE "
	EndIf

If cPaisLoc == 'RUS'
	Titulo += 	", " + AllTrim(STR0057) + " " + DTOC(mv_par01) + " " + AllTrim(OemToAnsi(STR0007)) + " " + Dtoc(mv_par02) + ", " +;
			AllTrim(OemToAnsi(STR0008)) + " " + cDescMoeda + " " + CtbTitSaldo(mv_par10)
Else
	Titulo += DTOC(mv_par01) + " " + AllTrim(OemToAnsi(STR0007)) + " " + Dtoc(mv_par02) + ", " +;
				AllTrim(OemToAnsi(STR0008)) + " " + cDescMoeda + " " + CtbTitSaldo(mv_par10)
EndIf

Else
	Titulo := oReport:Title()
Endif

oReport:SetPageNumber( mv_par09 )
If cPaisLoc <> "BRA"
	If wnRel == "CTBR041"
		dDataRef := MV_PAR01
	Else
		dDataRef := MV_PAR02
	Endif
EndIf

dDataRef := dDataBase

oReport:SetCustomText( {|| nCtCGCCabTR(dDataFim,titulo,oReport,dDataRef)})

cFilUser := oSection1:GetAdvplExpr("CT1")
If Empty(cFilUser)
	cFilUser := ".T."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao			  		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



If lExterno  .or. IsBlind()
	CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)

Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
					mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi(STR0015)),;  //"Criando Arquivo Tempor rio..."
					OemToAnsi(STR0003))  				//"Balancete Verificacao"
EndIf

nCount := cArqTmp->(RecCount())

oReport:SetMeter(nCont)

lRet := !(nCount == 0 .And. !Empty(aSetOfBook[5]))

If lRet

	// Verifica Se existe filtragem Ate o Segmento
  	If ! Empty( cSegAte )

		//Efetua tratamento da mascara para consegui efetuar o controle do segmento
		For nMasc := 1 to Len( cMascara )

			cMasc += SubStr( cMascara,nMasc,1 )

		Next nMasc


		nDigitAte := CtbRelDig( cSegAte, cMasc )

		oSection1:SetFilter( 'Len(Alltrim(cArqTmp->CONTA)) <= ' + alltrim( Str( nDigitAte )) )
	EndIf

	cArqTmp->(dbGoTop())

	If lNormal
		oSection1:Cell("CONTA"):SetBlock( {|| EntidadeCTB(cArqTmp->CONTA,000,000,045,.F.,cMascara,cSeparador,,,.F.,,.F.,lNormal)} )
	Else
		oSection1:Cell("CONTA"):SetBlock( {|| EntidadeCTB(If(cArqTmp->TIPOCONTA == "2",cArqTmp->CTARES,cArqTmp->CONTA),000,000,045,.F.,,cSeparador,cAlias,,.F.,,.F.,lNormal)} )
	EndIf

	oSection1:Cell("DESCCTA"):SetBlock( { || oSection1:Cell("DESCCTA"):Llinebreak:= (Len(alltrim(cArqTMp->DESCCTA) ) > oSection1:Cell("DESCCTA"):Getsize()),cArqTMp->DESCCTA } )
	If !lLibVers //RETIRAR CONDIÇÃO DE NÃO ESTAR COM A LIB, QUANDO A MESMA ESTIVER EM TODAS AS VERSÕES SEM PRECISAR DE APLICAÇÃO (DAQUI ALGUNS ANOS)
		If cTpValor != "P" .Or. lPlanilha
			oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR+10,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,,,lPlanilha) } )
			oSection1:Cell("SALDODEB"):SetBlock( { || ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) } )
			oSection1:Cell("SALDOCRD"):SetBlock( { || ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) } )
			oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR+10,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,,,lPlanilha) } )
		Else
			oSection1:Cell("SALDOANT"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR+10,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR+5) } )
			oSection1:Cell("SALDODEB"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR) } )
			oSection1:Cell("SALDOCRD"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR) } )
			oSection1:Cell("SALDOATU"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR+10,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR+5) } )
		EndIf
    Else
		oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR+10,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,,,lPlanilha) } )
		oSection1:Cell("SALDODEB"):SetBlock( { || ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) } )
		oSection1:Cell("SALDOCRD"):SetBlock( { || ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) } )
		oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR+10,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.,,,lPlanilha) } )
	EndIf

	//	 Imprime Movimento
  	If !lImpMov
  		oSection1:Cell("MOVIMENTO"):SetSize(0)
 		oSection1:Cell("MOVIMENTO"):Disable()
 	ElseIf cTpValor != "P" .Or. lPlanilha
 		oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR+5,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,, lPrintZero,.F.,,,lPlanilha) } )
 	Else
		If !lLibVers //RETIRAR CONDIÇÃO DE NÃO ESTAR COM A LIB, QUANDO A MESMA ESTIVER EM TODAS AS VERSÕES SEM PRECISAR DE APLICAÇÃO (DAQUI ALGUNS ANOS)
 			oSection1:Cell("MOVIMENTO"):SetBlock( { || PadL(ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR+5,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,, lPrintZero,.F.,,,lPlanilha),TAM_VALOR+5) } )
		Else
			oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR+5,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,, lPrintZero,.F.,,,lPlanilha) } )
		EndIf 
 	EndIf

	If lQbGrupo

		//*********************************
		// Total por Grupo do relatorio   *
		//*********************************

		oBrkGrupo := TRBreak():New(oSection1, { || cArqTmp->GRUPO },{|| STR0020+" "+ RTrim( Upper(AllTrim(cGrupo) )) + " )" },,,.T.)	//	" T O T A I S "
	  	oBrkGrupo:OnBreak( { |x| cGrupo := x, If(cArqTmp->(Eof()),oBrkGrupo:lPageBreak := .F.,.T.)} )

		oTotGrpDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
		oTotGrpDeb:Disable()

		oTotGrpCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
		oTotGrpCrd:Disable()

		If cTpValor != "P" .Or. lPlanilha
			TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) },.F.,.F.,.F.,oSection1 )

			TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) },.F.,.F.,.F.,oSection1 )
		Else
			TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection1 )

			TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection1 )
		EndIf

	 	If !lImpMov
	 		If lRedStorn
		 	 	oTotGrpMov := TRFunction():New(oSection1:Cell("MOVIMENTO"),,"SUM", oBrkGrupo,/*Titulo*/,/*cPicture*/,;
				{ || RedStorTt(cArqTmp->SALDODEB,cArqTmp->SALDOCRD,cArqTmp->TIPOCONTA,cArqTmp->NORMAL,"T") },.F.,.F.,.F.,oSection1)
	 	 	Else
		 	 	oTotGrpMov := TRFunction():New(oSection1:Cell("MOVIMENTO"),,"SUM", oBrkGrupo,/*Titulo*/,/*cPicture*/,;
				{ || Iif(cArqTmp->TIPOCONTA="1",0,(cArqTmp->SALDOCRD - cArqTmp->SALDODEB)) },.F.,.F.,.F.,oSection1)
		   	Endif
		   	oTotGrpMov:Disable()

			If cTpValor != "P" .Or. lPlanilha
	 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 			{ || ValorCTB(oTotGrpMov:GetValue(),,,TAM_VALOR+5,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGrpMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.,,,lPlanilha)},.F.,.F.,.F.,oSection1)
	 		Else
	 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 			{ || PadL(ValorCTB(oTotGrpMov:GetValue(),,,TAM_VALOR+5,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGrpMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.,,,lPlanilha),TAM_VALOR)},.F.,.F.,.F.,oSection1)
	 		EndIf
		Endif
	EndIf

	//******************************
	// Total Geral do relatorio    *
	//******************************
	oBrkGeral := TRBreak():New(oSection1, { || cArqTmp->(!Eof()) },{|| STR0011 },,,.F.)	//	" T O T A I S "

	// Totaliza
	oTotGerDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
   	oTotGerDeb:Disable()

	oTotGerCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
   	oTotGerCrd:Disable()


	If cTpValor != "P" .Or. lPlanilha
	    TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha) },.F.,.F.,.F.,oSection1)

	 	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha)},.F.,.F.,.F.,oSection1)
	Else
	    TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || PadL(ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR) },.F.,.F.,.F.,oSection1)

	 	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || PadL(ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR)},.F.,.F.,.F.,oSection1)
	EndIf

 	If lImpMov
 		If lRedStorn
	 	 	oTotGerMov := TRFunction():New(oSection1:Cell("MOVIMENTO"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || RedStorTt(cArqTmp->SALDODEB,cArqTmp->SALDOCRD,cArqTmp->TIPOCONTA,cArqTmp->NORMAL,"T") },.F.,.F.,.F.,oSection1)
		Else
	 	 	oTotGerMov := TRFunction():New(oSection1:Cell("MOVIMENTO"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || Iif(cArqTmp->TIPOCONTA="1",0,(cArqTmp->SALDOCRD - cArqTmp->SALDODEB)) },.F.,.F.,.F.,oSection1)
		Endif
	   	oTotGerMov:Disable()

		If cTpValor != "P" .Or. lPlanilha
 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
 				{ || ValorCTB(oTotGerMov:GetValue(),,,TAM_VALOR+5,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGerMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha)},.F.,.F.,.F.,oSection1)
 		Else
 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
 				{ || Padl(ValorCTB(oTotGerMov:GetValue(),,,TAM_VALOR+5,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGerMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.,lColDbCr,,lPlanilha),TAM_VALOR)},.F.,.F.,.F.,oSection1)
 		EndIf
    Endif

	oSection1:OnPrintLine( {|| 	CTR040OnPrint( lPula, lQbConta, nMaxLin, @cTipoAnt, @nLinReport, @cGrupoAnt, lRecDesp0, lVlrZerado ) } )

	oSection1:Print()

	If mv_par24 ==1
	    oReport:Section(1):SetHeaderSection(.F.)
		ImpQuadro(Tamanho,X3USO("CT2_DCD"),dDataFim,mv_par08,aQuadro,cDescMoeda,oReport:ClassName(),(If (lImpAntLP,dDataLP,cTod(""))),cPicture,nDecimais,lPrintZero,mv_par10,oReport)
	EndIf

EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

If __lMetric
	CTR040Metrics("01" /*cEvent*/, nStart, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTR040OnPrint ºAutor ³ Gustavo Henrique º Data ³ 07/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa acoes especificadas nos parametros do relatorio,   º±±
±±º          ³ antes de imprimir cada linha.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPL1 - Indicar se deve saltar linha entre conta sintetica º±±
±±º          ³ EXPL2 - Indicar se deve quebrar pagina por conta           º±±
±±º          ³ EXPN3 - Informar o total de linhas por pagina do balancete º±±
±±º          ³ EXPC4 - Guardar o tipo da conta impressa (sint./analitica) º±±
±±º          ³ EXPN5 - Guardar linha atual do relatorio para validacao    º±±
±±º          ³         com o valor do parametro EXPN3.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPL1 - Indicar se deve imprimir a linha (.T.)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTR040OnPrint( lPula, lQbConta, nMaxLin, cTipoAnt, nLinReport, cGrupoAnt , lRecDesp0, lVlrZerado  )

Local lRet := .T.
Local dDataFim := mv_par02

//Ao voltar por referencia, pular primeira entidade (nivel1)
if lQbConta .And. cArqTmp->NIVEL1
	cTipoAnt := cArqTmp->TIPOCONTA
Endif

// Verifica quebra de pagina por conta (mv_par11)
If lQbConta .And. cArqTmp->NIVEL1
	oReport:EndPage()
	nLinReport := 9
	Return
EndIf

// Verifica numero maximo de linhas por pagina (mv_par28)
If ! Empty(nMaxLin)
	CTR040MaxL(nMaxLin,@nLinReport)
EndIf

If mv_par05 == 1		// Apenas sinteticas
	lRet := (cArqTmp->TIPOCONTA == "1")
	nCtCGCCabTR(dDataFim,titulo,oReport)
ElseIf mv_par05 == 2	// Apenas analiticas
	lRet := (cArqTmp->TIPOCONTA == "2")
	nCtCGCCabTR(dDataFim,titulo,oReport)
EndIf

//Se desconsiderar saldo anterior de contas de receita e despesas e não imprimir zeros
If cArqTmp->TIPOCONTA == "2"
	If !lVlrZerado  
		If cArqTmp->SALDOANT == 0 .And. cArqTmp->SALDODEB == 0  .And.  cArqTmp->SALDOCRD == 0 .And. cArqTmp->SALDOATU  == 0
			lRet := .F.
		EndIf
	EndIf
Else
	If lRecDesp0 .And. !lVlrZerado  //parada
	//Se não houver saldo na conta não imprimir a mesma, caso o saldo anterior seja desconsiderado lRecDesp0 (mv_par25)
		If cArqTmp->SALDOANT == 0 .And. cArqTmp->SALDODEB == 0  .And.  cArqTmp->SALDOCRD == 0 .And. cArqTmp->SALDOATU  == 0
			lRet := .F.
		EndIf
	EndIf
EndIf

// Verifica salto de linha para conta sintetica (mv_par17)
If lRet



	If lPula .And. (cTipoAnt == "1"  .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2"))
		oReport:SkipLine()
	//Quando a anterior for sintetica e a proxima for analitica(Subsequentes) da um espaco igual exemplo do pergunte	
	ElseIf lPula .And. (cArqTmp->TIPOCONTA == "2" .And. cTipoAnt == "1")
		oReport:SkipLine()
	EndIf
	cTipoAnt := cArqTmp->TIPOCONTA //Ao pular sintetica para analitica, quando o valor voltar por referencia
EndIf

Return lRet


/*
------------------------------------------------------------------------- RELEASE 3 -------------------------------------------------------------------------------
*/



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr040R3³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbr040()                               			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR040R3(wnRel)

Local aSetOfBook
Local aCtbMoeda	:= {}
LOCAL cDesc1 		:= OemToAnsi(STR0001)	//"Este programa ira imprimir o Balancete de Verificacao Modelo 1 (80 Colunas), a"
LOCAL cDesc2 		:= OemToansi(STR0002)   //"conta eh impressa limitando-se a 20 caracteres e sua descricao 30 caracteres,"
LOCAL cDesc3		:= OemToansi(STR0016)   //"os valores impressao sao saldo anterior, debito, credito e saldo atual do periodo."
LOCAL cString		:= "CT1"
Local cTitOrig		:= ""
Local lRet			:= .T.
Local nDivide		:= 1
Local lExterno 	:= .F.
Local nQuadro
Local lPerg			:= .T.
PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "CTR040"
PRIVATE aLinha		:= {}
PRIVATE nomeProg  	:= "CTBR040"
PRIVATE titulo 		:= OemToAnsi(STR0003) 	//"Balancete de Verificacao"
Private aSelFil		:= {}

Default wnRel := ""

lExterno := !Empty(wnRel)

If ! lExterno
	PRIVATE Tamanho		:= "M"
	PRIVATE aReturn 	:= { OemToAnsi(STR0013), 1,OemToAnsi(STR0014), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
EndIf

cTitOrig	:= titulo

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

li	:= 60 //80



Private aQuadro := { "","","","","","","",""}

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next

CtbCarTxt()

Pergunte("CTR040",.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros								  ³
//³ mv_par01				// Data Inicial                  	  		  ³
//³ mv_par02				// Data Final                        		  ³
//³ mv_par03				// Conta Inicial                         	  ³
//³ mv_par04				// Conta Final  							  ³
//³ mv_par05				// Imprime Contas: Sintet/Analit/Ambas   	  ³
//³ mv_par06				// Set Of Books				    		      ³
//³ mv_par07				// Saldos Zerados?			     		      ³
//³ mv_par08				// Moeda?          			     		      ³
//³ mv_par09				// Pagina Inicial  		     		    	  ³
//³ mv_par10				// Saldos? Reais / Orcados	/Gerenciais   	  ³
//³ mv_par11				// Quebra por Grupo Contabil?		    	  ³
//³ mv_par12				// Filtra Segmento?					    	  ³
//³ mv_par13				// Conteudo Inicial Segmento?		   		  ³
//³ mv_par14				// Conteudo Final Segmento?		    		  ³
//³ mv_par15				// Conteudo Contido em?				    	  ³
//³ mv_par16				// Imprime Coluna Mov ?				    	  ³
//³ mv_par17				// Salta linha sintetica ?			    	  ³
//³ mv_par18				// Imprime valor 0.00    ?			    	  ³
//³ mv_par19				// Imprimir Codigo? Normal / Reduzido  		  ³
//³ mv_par20				// Divide por ?                   			  ³
//³ mv_par21				// Imprimir Ate o segmento?			   		  ³
//³ mv_par22				// Posicao Ant. L/P? Sim / Nao         		  ³
//³ mv_par23				// Data Lucros/Perdas?                 		  ³
//³ mv_par24				// Imprime Quadros Contábeis?				  ³
//³ mv_par25				// Rec./Desp. Anterior Zeradas?				  ³
//³ mv_par26				// Grupo Receitas/Despesas?      			  ³
//³ mv_par27				// Data de Zeramento Receita/Despesas?		  ³
//³ mv_par28                // Num.linhas p/ o Balancete Modelo 1		  ³
//³ mv_par29				// Descricao na moeda?						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! lExterno
	Pergunte("CTR040",.T.)

	If mv_par30 == 1 .And. Len( aSelFil ) <= 0 .And. !IsBlind()
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf

	wnrel	:= "CTBR040"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

Endif

If wnRel == "CTBR110"
	If mv_par30 == 1 .And. Len( aSelFil ) <= 0 .And. !IsBlind()
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf
Endif

If nLastKey == 27
	Set Filter To
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par06)
	lRet := .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If mv_par20 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par20 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par20 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par08,nDivide)
	If Empty(aCtbMoeda[1])
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

If lRet
	If (mv_par25 == 1) .and. ( Empty(mv_par26) .or. Empty(mv_par27) )
		cMensagem	:= STR0025	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= STR0026	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,"Ignora Sl Ant.Rec/Des")
		lRet    	:= .F.
    EndIf
EndIf

If !lRet
	Set Filter To
	Return
EndIf


If !lExterno .And. ( mv_par16 == 1 .Or. ( mv_par16 == 2 .And.	aReturn[4] == 2 ))	//Se nao imprime coluna mov. e eh paisagem
	tamanho := "G"
EndIf

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| CTR040Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda,nDivide,lExterno,cTitorig)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTR040IMP ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relatorio -> Balancete Verificacao Modelo 1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR040Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd       - A‡ao do Codeblock                             ³±±
±±³          ³ WnRel      - T¡tulo do relat¢rio                           ³±±
±±³          ³ cString    - Mensagem                                      ³±±
±±³          ³ aSetOfBook - Matriz ref. Config. Relatorio                 ³±±
±±³          ³ aCtbMoeda  - Matriz ref. a moeda                           ³±±
±±³          ³ nDivide    - Valor para divisao de valores                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTR040Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda,nDivide,lExterno,cTitOrig)

Local aColunas		:= {}
LOCAL CbTxt			:= Space(10)
Local CbCont		:= 0
LOCAL limite		:= 132
Local cabec1   	:= ""
Local cabec2   	:= ""
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda
Local cCodMasc
Local cMascara
Local cGrupo		:= ""
Local cArqTmp
Local dDataFim 	:= mv_par02
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lPrintZero	:= Iif(mv_par18==1,.T.,.F.)
Local lPula			:= Iif(mv_par17==1,.T.,.F.)
Local lNormal		:= Iif(mv_par19==1,.T.,.F.)
Local lVlrZerado	:= Iif(mv_par07==1,.T.,.F.)
Local l132			:= .T.
Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0
Local cSegAte   	:= mv_par21
Local nDigitAte	:= 0
Local lImpAntLP	:= Iif(mv_par22 == 1,.T.,.F.)
Local dDataLP		:= mv_par23
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lRecDesp0		:= Iif(mv_par25==1,.T.,.F.)
Local cRecDesp		:= mv_par26
Local dDtZeraRD		:= mv_par27
Local n
Local oMeter
Local oText
Local oDlg
Local lImpPaisgm	:= .F.
Local nMaxLin   	:= iif( mv_par28 > 58 , 58 , mv_par28 )
Local cMoedaDsc		:= mv_par29
Local nMasc			:= 0
Local cMasc			:= ""
Local dDataOld 		:= MsDate()
Local dDataBkp 		:= dDataBase
Local nStart		:= 0

//Iniciar telemetria - Tempo médio
If __lMetric
	nStart := Seconds()
EndIf

If cPaisLoc == 'RUS'
	cDescMoeda 	:= Alltrim(aCtbMoeda[3])
Else
	cDescMoeda 	:= Alltrim(aCtbMoeda[2])
EndIf
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par08)

if lExterno // Chamado THZFJJ - Se não for chado por outro relatorio trocar a data
	dDataBase := dDataFim
endif

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

If mv_par16 == 2 .And. !lExterno .And. 	aReturn[4] == 2	//Se nao imprime coluna mov. e eh paisagem
	lImpPaisgm	:= .T.
	limite		:= 220
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega titulo do relatorio: Analitico / Sintetico			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Upper(Alltrim(Titulo)) == Upper(Alltrim(cTitorig)) // Se o titulo do relatorio nao foi alterado pelo usuario
	IF mv_par05 == 1
		Titulo:=	OemToAnsi(STR0009)	//"BALANCETE DE VERIFICACAO SINTETICO DE "
	ElseIf mv_par05 == 2
		Titulo:=	OemToAnsi(STR0006)	//"BALANCETE DE VERIFICACAO ANALITICO DE "
	ElseIf mv_par05 == 3
		Titulo:=	OemToAnsi(STR0017)	//"BALANCETE DE VERIFICACAO DE "
	EndIf
EndIf
If cPaisLoc == 'RUS'
	Titulo += 	", " + AllTrim(STR0057) + " " + DTOC(mv_par01) + " " + AllTrim(OemToAnsi(STR0007)) + " " + Dtoc(mv_par02) + ", " +;
			AllTrim(OemToAnsi(STR0008)) + " " + cDescMoeda + " " + CtbTitSaldo(mv_par10)
Else
	Titulo += DTOC(mv_par01) + " " + AllTrim(OemToAnsi(STR0007)) + " " + Dtoc(mv_par02) + ", " +;
				AllTrim(OemToAnsi(STR0008)) + " " + cDescMoeda + " " + CtbTitSaldo(mv_par10)
EndIf

If nDivide > 1
	Titulo += " (" + OemToAnsi(STR0021) + Alltrim(Str(nDivide)) + ")"
EndIf

If mv_par16 == 1 .And. ! lExterno		// Se imprime saldo movimento do periodo
	cabec1 := OemToAnsi(STR0004)  //"|  CODIGO              |   D  E  S  C  R  I  C  A  O    |   SALDO ANTERIOR  |    DEBITO     |    CREDITO   | MOVIMENTO DO PERIODO |   SALDO ATUAL    |"
	tamanho := "G"
	limite	:= 220
	l132	:= .F.
Else
	If lImpPaisgm		//Se imprime em formato paisagem
		cabec1 := OemToAnsi(STR0022)  //"|  CODIGO                     |      D E S C R I C A O                          |        SALDO ANTERIOR             |           DEBITO             |            CREDITO                |         SALDO ATUAL               |"
	Else
		cabec1 := OemToAnsi(STR0005)  //"|  CODIGO               |   D  E  S  C  R  I  C  A  O    |   SALDO ANTERIOR  |      DEBITO    |      CREDITO   |   SALDO ATUAL     |"
	EndIf
Endif

If ! lExterno
	SetDefault(aReturn,cString,,,Tamanho,If(Tamanho="G",2,1))
Endif

If l132
	If lImpPaisgm
		aColunas := { 000,001, 030, 032, 080,086, 116, 118, 147, 151, 183, , ,187,219}
	Else
		aColunas := { 000,001, 024, 025, 057,058, 077, 078, 094, 095, 111, , , 112, 131 }
	EndIf
Else
	aColunas := { 000,001, 030, 032, 080,082, 112, 114, 131, 133, 151, 153, 183,185,219}
Endif

If !lExterno
	m_pag := mv_par09
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExterno  .or. IsBlind()
	CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,aReturn[7],lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
					mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,aReturn[7],lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi(STR0015)),;  //"Criando Arquivo Tempor rio..."
					OemToAnsi(STR0003))  				//"Balancete Verificacao"
EndIf

// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)

	//Efetua tratamento da mascara para consegui efetuar o controle do segmento
	For nMasc := 1 to Len( cMascara )

		cMasc += SubStr( cMascara,nMasc,1 )

	Next nMasc


	nDigitAte := CtbRelDig(cSegAte,cMasc)

EndIf

dbSelectArea("cArqTmp")
dbGoTop()

SetRegua(RecCount())

cGrupo := GRUPO

While !Eof()

	If lEnd
		@Prow()+1,0 PSAY OemToAnsi(STR0010)   //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF

	IncRegua()

	******************** "FILTRAGEM" PARA IMPRESSAO *************************

	//Se desconsiderar saldo anterior de contas de receita e despesas e não imprimir zeros

	If lRecDesp0 .And. !lVlrZerado
		//Se não houver saldo na conta não imprimir a mesma, caso o saldo anterior seja desconsiderado lRecDesp0 (mv_par25)
		If SALDOANT == 0 .And. SALDODEB == 0  .And. SALDOCRD == 0 .And. SALDOATU  == 0
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par05 == 1					// So imprime Sinteticas
		If TIPOCONTA == "2"
			dbSkip()
			Loop
		EndIf
	ElseIf mv_par05 == 2				// So imprime Analiticas
		If TIPOCONTA == "1"
			dbSkip()
			Loop
		EndIf
	EndIf

	//Filtragem ate o Segmento ( antigo nivel do SIGACON)
	If !Empty(cSegAte)
		If Len(Alltrim(CONTA)) > nDigitAte
			dbSkip()
			Loop
		Endif
	EndIf


	************************* ROTINA DE IMPRESSAO *************************

	If mv_par11 == 1 							// Grupo Diferente - Totaliza e Quebra
		If cGrupo != GRUPO
			@li,00 PSAY REPLICATE("-",limite)
			li+=2
			@li,00 PSAY REPLICATE("-",limite)
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,39 PSAY OemToAnsi(STR0020) + cGrupo + ") : "  		//"T O T A I S  D O  G R U P O: "
			@li,aColunas[COL_SEPARA4] PSAY "|"
			ValorCTB(nGrpDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA5] PSAY "|"
			ValorCTB(nGrpCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA6] PSAY "|"
			@li,aColunas[COL_SEPARA8] PSAY "|"
			li++
			li		:= 60
			cGrupo	:= GRUPO
			nGrpDeb	:= 0
			nGrpCrd	:= 0
		EndIf

	ElseIf  mv_par11 == 2
		If NIVEL1				// Sintetica de 1o. grupo
			li := 60
		EndIf
	EndIf

	IF li > nMaxLin
		If !lFirstPage
			@Prow()+1,00 PSAY	Replicate("-",limite)
		EndIf
		CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho,,dDataOld)
		lFirstPage := .F.
	EndIf

	@ li,aColunas[COL_SEPARA1] 		PSAY "|"
	If lNormal
		If TIPOCONTA == "2" 		// Analitica -> Desloca 2 posicoes
			If l132 .AND. lImpPaisgm
				EntidadeCTB(CONTA,li,aColunas[COL_CONTA]+2,21+6,.F.,cMascara,cSeparador)
			ElseIf l132
				EntidadeCTB(CONTA,li,aColunas[COL_CONTA]+2,21,.F.,cMascara,cSeparador)
			Else
				EntidadeCTB(CONTA,li,aColunas[COL_CONTA]+2,27,.F.,cMascara,cSeparador)
			EndIf
		Else
			If l132
				EntidadeCTB(CONTA,li,aColunas[COL_CONTA],23,.F.,cMascara,cSeparador)
			Else
				EntidadeCTB(CONTA,li,aColunas[COL_CONTA],29,.F.,cMascara,cSeparador)
			EndIf
		EndIf
	Else
		If TIPOCONTA == "2"		// Analitica -> Desloca 2 posicoes
			@li,aColunas[COL_CONTA] PSAY Alltrim(CTARES)
		Else
			@li,aColunas[COL_CONTA] PSAY Alltrim(CONTA)
		EndIf
	EndIf

	@ li,aColunas[COL_SEPARA2] 		PSAY "|"

	If !l132
		@ li,aColunas[COL_DESCRICAO] 	PSAY Substr(DESCCTA,1,48)
	Else
		@ li,aColunas[COL_DESCRICAO] 	PSAY Substr(DESCCTA,1,30)
	Endif

	@ li,aColunas[COL_SEPARA3]		PSAY "|"
	ValorCTB(SALDOANT,li,aColunas[COL_SALDO_ANT],17,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)

	@ li,aColunas[COL_SEPARA4]		PSAY "|"
	ValorCTB(SALDODEB,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,NORMAL, , , , , ,lPrintZero)

	@ li,aColunas[COL_SEPARA5]		PSAY "|"
	ValorCTB(SALDOCRD,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,NORMAL, , , , , ,lPrintZero)
	
	@ li,aColunas[COL_SEPARA6]		PSAY "|"

	If !l132
		ValorCTB(MOVIMENTO,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA7] PSAY "|"	
	Endif
	ValorCTB(SALDOATU,li,aColunas[COL_SALDO_ATU],17,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)

	@ li,aColunas[COL_SEPARA8] PSAY "|"

	lJaPulou := .F.

	If lPula .And. TIPOCONTA == "1"				// Pula linha entre sinteticas
		li++
		@ li,aColunas[COL_SEPARA1] PSAY "|"
		@ li,aColunas[COL_SEPARA2] PSAY "|"
		@ li,aColunas[COL_SEPARA3] PSAY "|"
		@ li,aColunas[COL_SEPARA4] PSAY "|"
		@ li,aColunas[COL_SEPARA5] PSAY "|"
		@ li,aColunas[COL_SEPARA6] PSAY "|"
		If !l132
			@ li,aColunas[COL_SEPARA7] PSAY "|"
			@ li,aColunas[COL_SEPARA8] PSAY "|"
		Else
			@ li,aColunas[COL_SEPARA8] PSAY "|"
		EndIf
		li++
		lJaPulou := .T.
	Else
		li++
	EndIf

	************************* FIM   DA  IMPRESSAO *************************

	If mv_par05 == 1					// So imprime Sinteticas - Soma Sinteticas
		If TIPOCONTA == "1"
			If NIVEL1
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
				nGrpDeb += SALDODEB
				nGrpCrd += SALDOCRD
			EndIf
		EndIf
	Else									// Soma Analiticas
		If Empty(cSegAte)				//Se nao tiver filtragem ate o nivel
			If TIPOCONTA == "2"
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
				nGrpDeb += SALDODEB
				nGrpCrd += SALDOCRD
			EndIf
		Else							//Se tiver filtragem, somo somente as sinteticas
			If TIPOCONTA == "1"
				If NIVEL1
					nTotDeb += SALDODEB
					nTotCrd += SALDOCRD
					nGrpDeb += SALDODEB
					nGrpCrd += SALDOCRD
				EndIf
			EndIf
    	Endif
	EndIf

	dbSkip()
	If lPula .And. TIPOCONTA == "1" 			// Pula linha entre sinteticas
		If !lJaPulou
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_SEPARA2] PSAY "|"
			@ li,aColunas[COL_SEPARA3] PSAY "|"
			@ li,aColunas[COL_SEPARA4] PSAY "|"
			@ li,aColunas[COL_SEPARA5] PSAY "|"
			@ li,aColunas[COL_SEPARA6] PSAY "|"
			If !l132
				@ li,aColunas[COL_SEPARA7] PSAY "|"
				@ li,aColunas[COL_SEPARA8] PSAY "|"
			Else
				@ li,aColunas[COL_SEPARA8] PSAY "|"
			EndIf
			li++
		EndIf
	EndIf
EndDO

//IF li != 80 .And. !lEnd
IF li <= 58 .OR. li >= 58 .And. !lEnd
	IF li > nMaxLin
		@Prow()+1,00 PSAY	Replicate("-",limite)
		CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho,,dDataOld)
		li++
	End
	If mv_par11 == 1							// Grupo Diferente - Totaliza e Quebra
		If cGrupo != GRUPO .Or. Eof()
			@li,00 PSAY REPLICATE("-",limite)
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,39 PSAY OemToAnsi(STR0020) + cGrupo + ") : "  		//"T O T A I S  D O  G R U P O: "
			@li,aColunas[COL_SEPARA4] PSAY "|"
			ValorCTB(nGrpDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA5] PSAY "|"
			ValorCTB(nGrpCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA6] PSAY "|"
			If !l132
				nTotMov := nTotMov + (nGrpCrd - nGrpDeb)
				If Round(NoRound(nTotMov,3),2) < 0
					ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
				ElseIf Round(NoRound(nTotMov,3),2) > 0
					ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
                EndIf
				@ li,aColunas[COL_SEPARA7] PSAY "|"
			Endif
			@li,aColunas[COL_SEPARA8] PSAY "|"
			li++
			@li,00 PSAY REPLICATE("-",limite)
			li+=2
		EndIf
	EndIf

	@li,00 PSAY REPLICATE("-",limite)
	li++
	@li,aColunas[COL_SEPARA1] PSAY "|"
	@li,39 PSAY OemToAnsi(STR0011)  		//"T O T A I S  D O  M E S : "
	@li,aColunas[COL_SEPARA4] PSAY "|"
	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
	@li,aColunas[COL_SEPARA5] PSAY "|"
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
	@li,aColunas[COL_SEPARA6] PSAY "|"
 	If !l132
		nTotMov := nTotMov + (nTotCrd - nTotDeb)
		If Round(NoRound(nTotMov,3),2) < 0
			ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
		ElseIf Round(NoRound(nTotMov,3),2) > 0
			ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
		EndIf
		@li,aColunas[COL_SEPARA7] PSAY "|"
	EndIf
	@li,aColunas[COL_SEPARA8] PSAY "|"
	li++
	@li,00 PSAY REPLICATE("-",limite)
	li++
	@li,0 PSAY " "

	IF lExterno
		If (li + 3) < 60
			@57,00 PSAY __PrtfatLine()
  		  	@58,01 Psay STR0023   //  "Microsiga Software S/A"
 		   	If Tamanho == "M"
   		 		@58,100 Psay STR0024 + " " + Time()      //"Hora Termino: "
   	 		ElseIf Tamanho == "G"
	   		 	@58,190 Psay STR0024 + " "+ Time()  //"Hora Termino: "
    		Else
	    		@58,050 Psay STR0024 + " "+ Time()	   //"Hora Termino: "
			EndIf
			@59,00 PSAY __PrtfatLine()
		EndIf
	Endif
	Set Filter To
EndIF

If mv_par24 ==1
	ImpQuadro(Tamanho,X3USO("CT2_DCD"),dDataFim,mv_par08,aQuadro,cDescMoeda,nomeprog,(If (lImpAntLP,dDataLP,cTod(""))),cPicture,nDecimais,lPrintZero,mv_par10)
EndIf

If aReturn[5] = 1 .And. ! lExterno
	Set Printer To
	Commit
	Ourspool(wnrel)
EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF
dbselectArea("CT2")

If ! lExterno
	MS_FLUSH()
Endif

dDataBase := dDataBkp

If __lMetric
	CTR040Metrics("01" /*cEvent*/, nStart, "002" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT040Valid³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Perguntas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct040Valid(cSetOfBook)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Config. Relatorio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct040Valid(cSetOfBook)

Local aSaveArea:= GetArea()
Local lRet		:= .T.

If !Empty(cSetOfBook)
	dbSelectArea("CTN")
	dbSetOrder(1)
	If !dbSeek(xfilial()+cSetOfBook)
		aSetOfBook := ("","",0,"","")
		Help(" ",1,"NOSETOF")
		lRet := .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTR040MAXL ºAutor ³ Eduardo Nunes Cirqueira º Data ³  31/01/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baseado no parametro MV_PAR28 ("Num.linhas p/ o Balancete      º±±
±±º          ³ Modelo 1"), cujo conteudo esta na variavel "nMaxLin", controla º±±
±±º          ³ a quebra de pagina no TReport                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTR040MaxL(nMaxLin,nLinReport)

nLinReport++

If nLinReport > nMaxLin
	oReport:EndPage()
	nLinReport := 10
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ nCtCGCCabTR  º Autor ³ Fabio Jadao Caires      º Data ³ 31/01/07º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a funcao padrao CtCGCCabTR reiniciando o contador de      º±±
±±º          ³ linhas para o controle do relatorio.                            º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION nCtCGCCabTR(dDataFim,titulo,oReport,dDataRef)
Local dDataold		:= Ctod("//")
Local cTexto		:= ""

Default dDataRef	:= dDataBase

nLinReport := 10
oReport:SetPageNumber(n_pagini)

oReport:OnPageBreak({|| n_pagini += 1})
nLinReport := 10

dDataOld := dDataBase
dDataBase := dDataRef


cTexto := CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport,,,,,,,,,,MV_PAR01)
dDataBase := dDataOld
Return(cTexto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTBR040  º Autor ³ Gustavo.campos      º Data ³ 30/10/19º        ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função com help para ser chamada quando for R3, sinalizando     º±±
±±º          ³ que serão descontinuados ao decorrer dos proximos releases.     º±±
±±º          ³														           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DESCONTR3()

//DESCONTR3 - HELP PARA DESCONTINUAÇÃO DOS RELATÓRIOS R3, INFORMANDO NOS OFICIAIS.
Help(NIL, NIL, "DESCONTR3", NIL, STR0058;
				, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0059})

Return



/*/{Protheus.doc} CTB400Metrics
	
	CTB400Metrics - Funç?o utilizada para metricas no CTBR400

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTR040Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("") 
Local nLapTime := 0
Local cTotal := ""

Default cEvent := ""
Default nStart := Seconds()
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a vers?o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo médio

		
		If cSubEvent == '001' .Or. cSubEvent == '002' // 001 = R4 - 002 = R3
			
			cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCCTBR040",cFunBkp)
			SetFunName(cFunMet)

			nFim := Seconds() - nStart // Capturar tempo final | Diferença com o tempo inicial
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_relatorio-balancete-mod1-tempo-total_seconds"
			dDateSend := LastDay( Date() )
			nLapTime := nFim
			cTotal	:=	"1"

			// Metrica
			FWCustomMetrics():SetMetric(cSubRoutine, cIdMetric, cTotal, dDateSend, nLapTime)

		EndIf

	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 
