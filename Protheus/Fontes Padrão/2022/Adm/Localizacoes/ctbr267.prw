#INCLUDE "ctbr267.ch"
#Include "PROTHEUS.Ch"

#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_COLUNA1       	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_COLUNA2       	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_COLUNA3       	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_COLUNA4   		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_COLUNA5   		14
#DEFINE 	COL_SEPARA8			15
#DEFINE 	COL_COLUNA6   		16
#DEFINE 	COL_SEPARA9			17
#DEFINE 	COL_COLUNA7			18
#DEFINE 	COL_SEPARA10		19
#DEFINE 	COL_COLUNA8			20
#DEFINE 	COL_SEPARA11		21
#DEFINE 	COL_COLUNA9			22
#DEFINE 	COL_SEPARA12		23
#DEFINE 	COL_COLUNA10		24
#DEFINE 	COL_SEPARA13		25
#DEFINE 	COL_COLUNA11		26
#DEFINE 	COL_SEPARA14		27
#DEFINE 	COL_COLUNA12		28
#DEFINE 	COL_SEPARA15		29

// 17/08/2009 -- Filial com mais de 2 caracteres
//Tradução PTG 20080721

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr267	³ Autor ³ Paulo Augusto       	³ Data ³ 23.01.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Comparativo de Movim. de Contas x 12 Colunas	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbr267()                               			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³25/06/15³PCREQ-4256³Se elimina las funciones CTR267SX1() y³±±
±±³            ³        ³          ³AjustaSX1()que modifican la tabla SX1 ³±±
±±³            ³        ³          ³por motivo de adecuacion a fuentes a  ³±±
±±³            ³        ³          ³nuevas estructuras SX para Version 12.³±±
±±³            ³        ³          ³                                      ³±±
±±³Jonathan Glz³09/10/15³PCREQ-4261³Merge v12.1.8                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctbr267()

Private Titulo		:= ""
Private NomeProg	:= "CTBR267"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := ReportDef()
If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf
oReport :PrintDialog()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Paulo AUgusto     	³ Data ³ 23/12/07 ³±±
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
Static Function ReportDef()
Local cREPORT		:= "CTBR267"
Local cTITULO		:= Capital(STR0001)				 //"Este programa ira imprimir o Comparativo de Contas Contabeis."
Local cDESC			:= OemToAnsi(STR0001)+OemtoAnsi(STR0002) //"Este programa ira imprimir o Comparativo de Contas Contabeis."###"Os valores sao ref. a movimentacao do periodo solicitado. "
Local cPerg	   		:= "CTR267"
Local aTamConta		:= {20}	//	TAMSX3("CT1_CONTA")
Local aTamDesc		:= {20}
Local aTamVal		:= {12}
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
oReport	:= TReport():New( cReport,cTITULO,cPERG, { |oReport| ReportPrint( oReport ) }, cDESC )
oReport:SetLandScape(.T.)

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
oSection1  := TRSection():New( oReport, STR0003, {"cArqTmp","CT1"},, .F., .F. )         //"Conta ContaAbil"
TRCell():New( oSection1, "CONTA"   , ,STR0004/*Titulo*/,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/) //"CONCEITO"
TRCell():New( oSection1, "DESCCTA" , ,STR0005/*Titulo*/,/*Picture*/,aTamDesc[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/) //"Descricao"
TRCell():New( oSection1, "COLUNA1" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA2" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA3" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA4" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA5" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA6" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA7" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA8" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA9" , ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA10", ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA11", ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection1, "COLUNA12", ,       /*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)
//oSection1:SetTotalText(STR0011)	//	"T O T A I S  D O  P E R I O D O: "

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Paulo Augusto        ³ Data ³ 23/01/07 ³±±
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
Static Function ReportPrint( oReport )

Local oSection1 	:= oReport:Section(1)

Local oTotCol1, oTotCol2, oTotCol3, oTotCol4 , oTotCol5 , oTotCol6 ,;
      oTotCol7, oTotCol8, oTotCol9, oTotCol10, oTotCol11, oTotCol12
      
Local oTotGrp1,	oTotGrp2, oTotGrp3, oTotGrp4 , oTotGrp5 , oTotGrp6 ,;
      oTotGrp7,	oTotGrp8, oTotGrp9, oTotGrp10, oTotGrp11, oTotGrp12,;
      oTotGrpTot, oBreakGrp

Local aCtbMoeda		:= {}
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda
Local nDivide		:= 1
Local cString		:= "CT1"

Local cCodMasc		:= ""
Local cGrupo		:= ""
Local cArqTmp
Local dDataFim 		:= dDatabase
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lPrintZero	:= .T.
Local lPula			:= .T.
Local nDecimais
Local cSegFim		:= "zzzzzzzzzzzzzzz"
Local cSegAte   	:= "zzzzzzzzzzzzzzzzzzzzz"
Local nDigitAte		:= 0
Local aMeses		:= {}
Local aPeriodos
Local nMeses		:= 1
Local nCont			:= 0
Local nDigitos		:= 0
Local nVezes		:= 0
Local nPos			:= 0
Local cHeader 		:= ""
Local lAtSlBase		:= Iif(GETMV("MV_ATUSAL")== "S",.T.,.F.)
Local cFilter		:= ""
Local cTipoAnt		:= ""
Local aTamVal		:= {12}
Local cFilUser		:= ""
Local cDifZero		:= ""
Local cEspaco
Local bCond
Local nMes:=1

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra tela de aviso - processar exclusivo					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMensagem := STR0006+chr(13)   //"Caso nao atualize os saldos  basicos  na"
cMensagem += STR0007+chr(13) //"digitacao dos lancamentos (MV_ATUSAL='N'),"
cMensagem +=  STR0008+chr(13)  //"rodar a rotina de atualizacao de saldos "
cMensagem += STR0009+chr(13)  //"para todos os periodos solicitados nesse "
cMensagem += STR0010+chr(13)  	 //"relatorio."

IF !lAtSlBase
	IF !MsgYesNo(cMensagem,STR0011) //" ATENCAO "
		Return
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par04)
	Return
Else
   aSetOfBook := CTBSetOf(mv_par04)
Endif

aCtbMoeda  	:= CtbMoeda(mv_par05,nDivide)
If Empty(aCtbMoeda[1])
   Help(" ",1,"NOMOEDA")
   Return
Endif

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

If !Empty(aCtbMoeda[6])
	cDescMoeda += STR0012 + aCtbMoeda[6]			// Indica o divisor //" EM "
EndIf

nDecimais := DecimalCTB(aSetOfBook,mv_par05)
cPicture  := AllTrim( Right(AllTrim(aSetOfBook[4]),12) )

dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
dIni:=CTG->CTG_DTINI
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo


aPeriodos := ctbPeriodos(mv_par05, dIni, dDataFim, .T., .F.)
lPrim:=.T.
nMes:=1
For nCont := 1 to len(aPeriodos)
	//Se a Data do periodo eh maior ou igual a data inicial solicitada no relatorio.
	If lPrim
		nMes:=Month(aPeriodos[nCont][1])
		cDescMes:=MesExtenso(nMes)
		lPrim:=.F.
	Else
		nMes:=nMes+1
        If nMes> 12
        	nMes:=1
        EndIf
        cDescMes:=MesExtenso(nMes)
	EndIf
	
	If aPeriodos[nCont][1] >= dIni .And. aPeriodos[nCont][2] <= dDataFim
		If nMeses <= 12
			AADD(aMeses,{StrZero(nMeses,2),aPeriodos[nCont][1],aPeriodos[nCont][2],cDescMes})
			nMeses += 1
		EndIf
	EndIf
Next

If nMeses == 1
	cMensagem := STR0013 //"Por favor, verifique se o calend.contabil e a amarracao moeda/calendario "
	cMensagem += STR0014 //"foram cadastrados corretamente..."
	MsgAlert(cMensagem)
	Return
EndIf

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
	cCodMasc := ""
Else
	cCodmasc	:= aSetOfBook[2]
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf

If !Empty(cSegAte)
    nDigitAte	:= CtbRelDig(cSegAte,cMascara)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega titulo do relatorio: Analitico / Sintetico			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo:=STR0015 //"COMPARATIVO DE "


Titulo += 	DTOC(dIni) + STR0016 + Dtoc(aMeses[Len(aMeses)][3]) + ; //" ATE "
				STR0012 + cDescMoeda //" EM "

If mv_par06 > "1"
	Titulo += " (" + Tabela("SL", mv_par06, .F.) + ")"
Endif


oReport:SetCustomText( {||CTBR267CAB(dDataFim,oReport) } )

DbSelectArea("CT1")
cFilUser := oSection1:GetAdvplExp("CT1")

If Empty(cFilUser)
	cFilUser := ".T."
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerComp(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				dIni,dDataFim,"CT7","",mv_par02,mv_par03,,,,,,,mv_par05,;
				mv_par06,aSetOfBook,"","",cSegFim,"",;
				.F.,.F.,2,cHeader,.F.,,nDivide,"M",.F.,,.T.,aMeses,.T.,,,.T.,cString,cFilUser,,,,,,,,,.T.)},;
				STR0017, STR0018,)//"Criando Arquivo Tempor rio..."				 	//"Comparativo de Contas Contabeis " //"Criando Arquivo Temporario..."###"Comparativo de Contas Contabeis"

oReport:NoUserFilter()

If Select("cArqTmp") == 0
	Return
EndIf

oSection1:OnPrintLine( {|| ( IIf( lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2")), oReport:SkipLine(),NIL),;
								 cTipoAnt := cArqTmp->TIPOCONTA;
							)  })       

cDifZero := " (cArqTmp->COLUNA1  <> 0 .OR. cArqTmp->COLUNA2  <> 0 .OR. cArqTmp->COLUNA3  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA4  <> 0 .OR. cArqTmp->COLUNA5  <> 0 .OR. cArqTmp->COLUNA6  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA7  <> 0 .OR. cArqTmp->COLUNA8  <> 0 .OR. cArqTmp->COLUNA9  <> 0 .OR. "
cDifZero += "  cArqTmp->COLUNA10 <> 0 .OR. cArqTmp->COLUNA11 <> 0 .OR. cArqTmp->COLUNA12 <> 0)"
						           
oSection1:SetFilter( cFilter )

For nMes:= 1 to Len(aMeses)
	cColVal := "COLUNA"+Alltrim(Str(nMes))
	cDtCab := Strzero(Day(aMeses[nMes][2]),2)+"/"+Strzero(Month(aMeses[nMes][2]),2)+ " - "
	cDtCab += Strzero(Day(aMeses[nMes][3]),2)+"/"+Strzero(Month(aMeses[nMes][3]),2)

	oSection1:Cell(cColVal):SetTitle(aMeses[nMes][4])
Next
lFirst:=.T.
nMes:=1
For nCont:= Len(aMeses)+1 to 12
	If lFirst
		nMes:=month(aMeses[Len(aMeses)][2])+1
		lFirst:=.F.
	Else
		If nMes>12
			nMes:=1
		Else
			nMes:=nMes+1
		EndIf
		
	EndIf
	
	cColVal := "COLUNA"+Alltrim(Str(nCont))
	oSection1:Cell(cColVal):SetTitle(MesExtenso(nMes))
Next
                                  
//	23-Imprime coluna "Total Periodo" (totalizando por linha)	( 1-Sim )
//  24-Imprime a descricao da conta								( 2-Nao )

	oSection1:Cell("DESCCTA"):Disable()								//	Desabilita Descricao da Conta
	oSection1:Cell("CONTA"  ):SetBlock( {|| IF( cArqTmp->TIPOCONTA == "2" ,	cEspaco:=SPACE(02),	cEspaco:="" ),	/*Fazer um recuo nas contas analíticas em relação à sintética*/;
   		                                    cEspaco + cArqTmp->DESCCTA } )	//Conta Sintética

oSection1:Cell("COLUNA1"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA1) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA2"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA2) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA3"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA3) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA4"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA4) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA5"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA5) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA6"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA6) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA7"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA7) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA8"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA8) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA9"):SetBlock ( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA9) ,,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA10"):SetBlock( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA10),,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA11"):SetBlock( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA11),,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
oSection1:Cell("COLUNA12"):SetBlock( { || ValorCTB(Iif(cArqTmp->COLVISAO==1,MV_PAR08,cArqTmp->COLUNA12),,,aTamVal[1],Iif(cArqTmp->COLVISAO==1,4,nDecimais),.F.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
           
oSection1:Print()

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

Return
              

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³³CtCGCCabTR³ Autor ³ PAULO AUGUSTO        ³ Data ³ 23/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Monta Cabecalho do relatorio                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³CtCGCCabTR(Titulo,oReport)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Arg1  = dATA                              				   ³±±
±±³           ³Arg2 = Objeto do oReport                   				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CTBR267CAB(dDataFim,oReport)
Local aCab:={}
aCabec:= {	"__LOGOEMP__",;
		".          " + AllTrim(SM0->M0_NOMECOM) + "       ." + RptFolha+ TRANSFORM(oReport:Page(),'999999'),;
           ".          " + STR0019 + "       ." ,; //"CALCULO DE PAGAMENTOS PROVISORIOS DE ISR"
		".          " + "       ." ,;            
           "SIGA /" + NomeProg + "/v." + cVersao + "   " + "           .",;
           RptHora + " " + time() + "     " + RptEmiss + " " + Dtoc(dDataBase) }

SX3->(DbSetOrder(2))
SX3->(MsSeek("A1_CGC",.t.))

If SM0->(Eof())
	SM0->(MsSeek(cEmpAnt+cFilAnt,.T.))
Endif

Aadd(aCab,AllTrim(SM0->M0_NOMECOM))
Aadd(aCab,AllTrim(titulo))
Aadd(aCab,Transform(Alltrim(SM0->M0_CGC),alltrim(SX3->X3_PICTURE)))

Return aCabec
