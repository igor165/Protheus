#INCLUDE "plsa770.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "Rwmake.ch"
#INCLUDE "Ap5Mail.ch"
#Include "MsOle.ch"
#include "fileio.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ PLSA770 ณ Autor ณ Tulio Cesar            ณ Data ณ 14.09.00 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Tratamento para bloqueio automatico de familias.           ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณSintaxe   ณ PLSA770()                                                  ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Uso      ณ Advanced Protheus                                          ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Alteracoes desde sua construcao inicial.                              ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ Data     ณ BOPS ณ Programador ณ Breve Descricao                       ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ05.02.2001ณ      ณ Guilherme   ณ Inclusao do parametro dDatFin         ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ06.02.2001ณ      ณ Michele     ณ Verifica se o usuario ja estava       ณฑฑฑ
ฑฑณ          ณ      ณ             ณ boloqueado                            ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ12.05.2004ณ      ณ Jota!       ณ reestruturacao da rotina para versao  ณฑฑฑ
ฑฑณ          ณ      ณ             ณ 8.11. Agora chama funcao generica.    ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณ12/12/2014ณ      ณ Renan       ณ criado op็ใo de enviar por e-mal ou   ณฑฑฑ
ฑฑณ          ณ      ณ             ณ carta usuแrios bloqueados 			    ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLSA770(cmv_par01, cmv_par02, cmv_par03, cmv_par04,;
cmv_par05, cmv_par06, cmv_par07, cmv_par08,;
cmv_par09, cmv_par10, cmv_par11, cmv_par12,;
cmv_par13, cmv_par14, cmv_par15, cmv_par16,;
cmv_par17, cmv_par18, cmv_par19,cmv_par20, cmv_par21, cmv_par22,lJob)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis dos parametros...                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cIntDe	:= cmv_par01
Private cIntAte	:= cmv_par02
Private cGruDe	:= cmv_par03
Private cGruAte	:= cmv_par04
Private cMatrDe	:= cmv_par05
Private cMatrAte	:= cmv_par06
Private nBloFin	:= cmv_par07
Private dRefFin	:= cmv_par08
Private cMotFin	:= cmv_par09
Private nBloLim	:= cmv_par10
Private cMotLim	:= cmv_par11
Private nBloMai	:= cmv_par12
Private cMotMai	:= cmv_par13
Private cGrauPa	:= cmv_par14
Private nIdaMai	:= cmv_par15
Private nIdaUni	:= cmv_par16
Private dDatDe	:= cmv_par17
Private dDatAte	:= cmv_par18
Private dDatBlo	:= cmv_par19
Private nAcao		:= cmv_par20
Private nBlqCasa	:= cmv_par21
Private cMotCasa	:= cmv_par22
Private cJobAtv	:= .F.
Private cA770ret:= ''
Private INCLUI	:= .T.

DEFAULT lJob := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca dados dos parametros...                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cMv_Par01 == Nil
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ajusta perguntas                                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	CriaSX1()

	If !Pergunte("PLA770",.T.)
		Return(.F.)
	Endif

	//Parametros cadastrais.
	cIntDe   := mv_par01
	cIntAte  := mv_par02
	cGruDe   := mv_par03
	cGruAte  := mv_par04
	cMatrDe  := mv_par05
	cMatrAte := mv_par06

	// Relativos ao financeiro
	nBloFin  := mv_par07
	dRefFin  := mv_par08
	cMotFin  := mv_par09

	// Limete de permanencia no plano apos demissao ou aposentadoria.
	nBloLim  := mv_par10
	cMotLim  := mv_par11

	// Relativos a maioridade.
	nBloMai  := mv_par12
	cMotMai  := mv_par13
	cGrauPa  := ALLTRIM(mv_par14)
	nIdaMai  := mv_par15
	nIdaUni  := mv_par16
	dDatDe   := mv_par17
	dDatAte  := mv_par18
	dDatBlo  := mv_par19

	If !lJob .And. Empty(nAcao) .And. !Empty(mv_par20)
		nAcao := mv_par20
	EndIf
	nBlqCasa	:= mv_par21
	cMotCasa	:= mv_par22
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa funcao que ira bloquear os contratos...                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lJob
	cJobAtv := lJob
	A770Blo(cIntDe,cIntAte,cGruDe,cGruAte,cMatrDe,cMatrAte,dDatBlo,cMv_Par15,cMv_Par16,lJob)
Else

	Processa( {|| A770Blo(cIntDe,cIntAte,cGruDe,cGruAte,cMatrDe,cMatrAte,dDatBlo,cMv_Par15,cMv_Par16) }, STR0001) //"Processando..."
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑฑ
ฑฑณFuncao    ณ A770BLO ณ Autor ณ Tulio Cesar            ณ Data ณ 14.09.00 ณฑฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑฑ
ฑฑณDescricao ณ Bloqueia familias automaticamente de acordo com regras.    ณฑฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function A770Blo(cIntDe,cIntAte,cGruDe,cGruAte,cMatrDe,cMatrAte,dDatBlo,cMv_Par15,cMv_Par16,lJob)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis...                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cInd    		:= CriaTrab(nil,.F.)
Local cOrdem    	:= ''
Local cFor			:= ""
Local nQtdMes 		:= 0
Local lBloqFam	 	:= .F.
Local nRecBA3		:= BA3->( Recno() )
Local nRecBA1		:= BA1->( Recno() )
Local cTitular 		:= SuperGetMv("MV_PLCDTIT")
Local nIdade		:= 0
Local aDadUsr		:= {}
Local aPosFin		:= {}
Local __cNivBlq		:= '0'
Local cMotBlo		:= ''
Local aRet			:= {}
Local aRetMaior		:= {}
Local nForLog 	:= 1
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณDefinicao de variaveis utilizadas no relatorio de emissao do LOGณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Local wnrel   	:= "PLSA770"			// Nome do Arquivo utilizado no Spool
Local Titulo 	:= STR0002 //"Relatorio de anแlise de bloqueio de Famํlia/Usuแrio"
Local cDesc1 	:= STR0003 //"Este programa irแ emitir uma rela็ใo famํlias e usuแrios encontradas"
Local cDesc2 	:= STR0004 //"no arquivo que atendam as regras dos parametros informados e"
Local cDesc3 	:= STR0005 //"serใo posteriormente bloqueados."
Local nomeprog	:= "PLSA770.PRW"		// nome do programa
Local cString 	:= ""					// Alias utilizado na Filtragem
Local lDic    	:= .F. 					// Habilita/Desabilita Dicionario
Local lComp   	:= .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro 	:= .F. 					// Habilita/Desabilita o Filtro
Local lGrav		:= .F.
Local aBenBlo	:= {}						//array de Beneficiแrios bloqueados
local aFMlBlo	:= {}						//array das familias bloqueadas
Local cTipCrt									//Como gerar carta: 1- Para beneficiแrio bloqueado / 2 - Para famํlia bloqueada
Local cTipCom	:= SuperGetMv("MV_PLSEMLT")
//Identifica se envia envia e-mail ou carta ou nใo executa : 1=Nao; 2=Email; 3=Carta; 4=Email_Carta
Local cEmlOp	:= SuperGetMv("MV_PLSEMLO")  //E-mail da operadora que irแ receber as c๓pias
Local nTy										//Para o la็o dos vetores aBenBlo e aFmlBlo
Local cJobEML	:= GETMV("MV_PLSEMJB")  //Envia e-mail para usuแrios em JOB ou apenas resumo operadora
Local nCont
Local cSQL		:= ""
LOCAL cTit
LOCAL cmat
Local nI
Local nReg
Local aFam		 := {}
Local nIdade     := 0  
Local aCodDoc	 := {}
Local nDoc		 := 0 
Local nLenCdDoc  := 0 
Local lLimite 	 := BA3->( FieldPos("BA3_LIMITE") ) > 0
Local lGrpFam  	 := BA3->(FieldPos("BA3_GRPFAM")) > 0
Local cRetBA3  := RetSQLName("BA3")
Local lGetDB 	:= AllTrim( TCGetDB() ) $ "ORACLE|POSTGRES"

Private cNomD									//Armazenar nome do dependente ao gerar e-mail
Private cPesqM								//Armazenar string de pesquisa para MSSeek
Private cFlag 	:= .F.
Private nConDoc	:= 0
Private cTelCen	:= GetNewPar( "MV_PLSRTCA" , "" )  //Telefone Principal da Operadora
Private cTelFax	:= GetNewPar( "MV_PLSRTFA" , "" )	//Fax da Operadora
Private cEmail	:= GetNewPar( "MV_PLSREMA" , "" )	//E-mail da Operadora
Private cMODEML	:= (GetSrvProfString("StartPath", "") + SuperGetMv("MV_PLSMEML"))			//Local do modelo de e-mail de Bloqueio *.htm
 //------------- Op็๕es da Carta
Private lCopy1	:= .F.
Private lCopy2	:= .F.
Private lProc		:= .F.
Private lCriaDir	:= .T.
Private cPathArq	:= GetNewPar( "MV_PLSMCBQ" , "" )  //Local do modelo da carta de Bloqueio
Private cArqAgl	:= ""
Private cMensag	:= ""
Private cPathTMP	:= ""
Private aWord		:= {}
Private hWord		:= Nil
Private cArqDot	:= ""
//Local onde serแ salvo as cartas de bloqueio
Private cPathEst	:= IIF(lJob == .T., (GetSrvProfString("RootPath", "") + GetSrvProfString("StartPath", "") + cPathArq + "\"),;
                         (GetNewPar( "MV_PLSLOBQ" , "" )+"\"))
//------------------
Private Tamanho := "P"					// P/M/G
Private Limite  := 80					// 80/132/220
Private aReturn := { STR0006,;		//[1] Reservado para Formulario //"Zebrado"
  1,;				//[2] Reservado para Nง de Vias
	STR0007,;	//[3] Destinatario //"Administra็ใo"
	2,;				//[4] Formato => 1-Comprimido 2-Normal
	2,;	    	//[5] Midia   => 1-Disco 2-Impressora
	1,;				//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
	"",;			//[7] Expressao do Filtro
	1 } 			//[8] Ordem a ser selecionada
	 					//[9]..[10]..[n] Campos a Processar (se houver)
Private m_pag   := 1					// Contador de Paginas
Private nLastKey:= 0					// Controla o cancelamento da SetPrint e SetDefault
Private cPerg   := "PLA770"				// Pergunta do Relatorio
Private aOrdem  := {}					// Ordem do Relatorio
Private lenviado := .F.
Private ltexto := ""
Private aLogGrp260 := {}
Private aLog	:= {} 

DEFAULT lJob	  := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define ordem default no arquivo de contas a receber...              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SE1->(DbSetOrder(GETMV("MV_PLORDE1")))
BA1->(DbSetOrder(1))

cFor := "%BA3_MOTBLO = ' " + Space(Len(BA3->BA3_MOTBLO)) + " ' %"
cFor += Iif( ExistBlock("PLS770BL"), " AND " +  ExecBlock("PLS770BL",.F.,.F.), "")

BeginSql Alias "TrbDesbl"

	SELECT
	 	R_E_C_N_O_ rec
	FROM 
		 %table:BA3%
	WHERE 
		BA3_FILIAL = %XFilial:BA3%
		AND BA3_CODINT >= %Exp:cIntDe%  
		AND BA3_CODINT <= %Exp:cIntAte%
		AND	BA3_CODEMP >= %Exp:cGruDe% 
		AND BA3_CODEMP <= %Exp:cGruAte%
		AND BA3_MATRIC >= %Exp:cMatrDe%  
		AND BA3_MATRIC <= %Exp:cMatrAte%
		AND %Exp:cFor%
		AND %NotDel%
EndSql

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existem registros selecionados de acordo com parametro..ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If TrbDesbl->(Eof())
	Help("",1,"RECNO")
	TrbDesbl->(DBCloseArea())
	Return(.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Seleciona Area de Vidas (BTS)
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbselectArea("BTS")

BTS->(DbSetOrder(1))
BG9->(DbSetOrder(1))
BT5->( dbSetorder(1))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia a verificacao das familias selecionadas...                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
While ! TrbDesbl->(Eof())

	lGrav := .F.

	BA3->(DBGoTo(TrbDesbl->rec))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ IncProc																ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lJob
		IncProc( STR0008+Transform((BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC), __cPictFam) ) //"Analisando familia - "
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciona o grupo empresa...                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BG9->(DbSeek(xFilial("BG9")+BA3->BA3_CODEMP))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciono o contrato...                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(BA3->BA3_CONEMP)
		
		BT5->( dbSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON) )
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciono o sub contrato...                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(BA3->BA3_SUBCON)
		BQC->( dbSetorder(01) )
		BQC->( dbSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB) )
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Trata validade de usuarios demitidos / aposentados...               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nBloLim == 1
		If lLimite
			If BA3->BA3_TIPOUS == '2'
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica se houve desligamento do titular por demissao ou aposentadoria |
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If !Empty(BA3->BA3_LIMITE)
					If (dTos(BA3->BA3_LIMITE) >= dTos(dDatDe) .and.;
							dTos(BA3->BA3_LIMITE) <= dTos(dDatAte))

						lBloqFam  := .T.
						__cNivBlq := '1'
					Endif
				Endif
			Endif
		Endif
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida situacao financeira...                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If  nBloFin == 1 .and. !lBloqFam
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona o titular da familia...                                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BA1->( dbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Monta matriz padrao com os dados do usuario...                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aRet := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDataBase,nil,nil,nil)
		If aRet[1]
			aDadUsr := PLSGETUSR()
		Else
			TrbDesbl->(DbSkip())
			lBloqFam := .F.
			Loop
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Avalia a posicao financeira da familia usando funcao generia.       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aPosFin := PLSVLDFIN(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),dRefFin,'','','',aDadUsr)

		If !aPosFin[1]
			// Para indicar o bloqueio
			lBloqFam := .T.
			__cNivBlq := '2'
		Endif

	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica origem do bloqueio e posiciona o cadastro...               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If __cNivBlq == '1'
		cMotBlo := cMotLim
	Elseif __cNivBlq == '2'
		cMotBlo := cMotFin
	Endif
	BG1->( dbSetorder(01) )
	BG1->( MsSeek(xFilial("BG1")+cMotBlo) )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ A familia nao foi bloqueada, agora analiza regras individuais       ณ
	//ณ para ver se algum usuario sera bloqueado...                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If BA3->BA3_TIPOUS == '2' .AND. EMPTY(cTit)
		cTit := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
	EndIf

	If !lBloqFam

		If !EMPTY(BA3->BA3_GRPFAM)
			TrbDesbl->( DbSkip() )
			Loop
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Processa todos os usuarios da familia, exceto Titular.                     |
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If BA1->( MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
			While BA1->( !Eof() ) .AND.;
				BA1->BA1_FILIAL == xFilial("BA1")	.AND.;
				BA1->BA1_CODINT == BA3->BA3_CODINT	.AND.;
				BA1->BA1_CODEMP == BA3->BA3_CODEMP	.AND.;
				BA1->BA1_MATRIC == BA3->BA3_MATRIC
				If !Empty(BA1->BA1_DATBLO) .OR. !Empty(BA1->BA1_MOTBLO) .OR.  !(BA1->BA1_GRAUPA $ cGrauPa)  .OR. ;
					(BTS->(MsSeek(xFilial()+BA1->BA1_MATVID)) .and. BTS->BTS_INVALI = '1')
					BA1->( DbSkip() )
					Loop
				Endif
				
				//--------------------------------------------------------------------
				//Verifica se os documentos vinculados ao titular impede o bloqueio.
				//--------------------------------------------------------------------
				BCP->(DbSetOrder(1))	
				lDocImpBlo := .F.
				cTipRegAnt := ""
				
				//Verifica se existe documento entregue vinculado ao beneficiแrio
				If BCP->(DbSeek(xFilial("BCP")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG))
					
					//Caso tenha encontrado o documento, busca todos os documentos entregues para o mesmo beneficiario.
					BD2->(DbSetOrder(1))
					While (BCP->(!EOF()) 						.AND.;
							BCP->BCP_FILIAL == xFilial("BCP")	.AND.;
							BCP->BCP_CODOPE == BA1->BA1_CODINT	.AND.;
							BCP->BCP_CODEMP == BA1->BA1_CODEMP	.AND.;
							BCP->BCP_MATRIC == BA1->BA1_MATRIC .AND.;
							BCP->BCP_TIPREG == BA1->BA1_TIPREG)
													
						//Posiciona na BD2 (Documentos) o registro entregue e checa se o documento impede o bloqueio do usuario.
						If (BCP->BCP_ENTREG == "1" .AND. BD2->(DbSeek(xFilial("BD2")+BCP->BCP_CODDOC)) .AND. BD2->BD2_IMPBLO == "1") .AND. ; 
						   ((EMPTY(BCP->BCP_DATINC) .AND. EMPTY(BCP->BCP_DATVAL)) .OR.(BCP->BCP_DATINC <= dDatBlo .AND. EMPTY(BCP->BCP_DATVAL)) .OR.; 
 						   (BCP->BCP_DATINC <= dDatBlo .AND. BCP->BCP_DATVAL >= dDatBlo)) 
							
							//Foi encontrado documento vinculado ao beneficiario que impede o bloqueio.
							//Verifica-se se jแ foi criado log para este beneficiแrio e, caso positivo, s๓ inclui o documento na lista.
							//Caso contrแrio, inclui o nome do beneficiario e demais informa็๕es no log (registro inicial).
							if cTipRegAnt <> 	BCP->BCP_MATRIC+BCP->BCP_TIPREG
								
								//Armazena o registro atual para ser comparado na proxima itera็ใo.
								cTipRegAnt :=	BCP->BCP_MATRIC+BCP->BCP_TIPREG
								
								Aadd( aLog, STR0026) //" -----------> USUARIO POSSUI DOCUMENTO QUE IMPEDE BLOQUEIO"
								Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
								Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
								Aadd( aLog, STR0027 + BD2->BD2_DESCRI ) //" Documento--> "
								Aadd( aLog, "") 	
							else
								Aadd( aLog, STR0027 + BD2->BD2_DESCRI ) //" Documento--> "
							endif
															
							lDocImpBlo := .T.
							
							BCP->(DbSkip())
						else
							BCP->(DbSkip())
						endif			
					EndDo
					
					if lDocImpBlo
						BA1->( DbSkip() )
						Loop //Nใo ้ mais necessแrio fazer as verifica็๕es a partir desse ponto, visto que o beneficiario possui documento que impede o bloqueio.
					endif	
				EndIf

				// Regra 1 - Maioriadade. Caso seja considerado via perguntas.
				If nBloMai == 1

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Verifica se deve desconsiderar o bloqueio por maioridade de deficiente fํsico
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If BTS->BTS_DEFFIS == "1"
						If BQC->(FieldPos("BQC_BQDEFI")) > 0
							If BQC->BQC_BQDEFI == "1"
								BA1->( DbSkip() )
								Loop
							EndIf
						EndIf
					EndIf

					// Caso seja um dependente selecionado.
					If BA1->BA1_TIPUSU # cTitular .AND. BA1->BA1_GRAUPA $ cGrauPa
	                        // Trata a maioridade para universitarios...
						If nIdaUni == 0
							aRetMaior	:= Maioridade()
							nIdaUni		:= aRetMaior[1]
						ELSE
							nIdaUni := nIdaMai
						Endif
						If BA1->BA1_UNIVER == "1" .AND. nIdaUni > 0
							If	nIdaUni >= INT((dDatDe  - BA1->BA1_DATNAS) / 365.25, 3) .AND.;
									nIdaUni <= INT((dDatAte - BA1->BA1_DATNAS) / 365.25, 3)

								If Empty(dDatBlo)
									dDatBlo := BA1->BA1_DATNAS + INT(nIdaMai * 365.25, 3)
									If SubStr(DtoC(dDatBlo),1,5) == "31/12" .OR. CtoD(SubStr(DtoC(dDatBlo),1,6)+"2000") < CtoD(SubStr(DtoC(BA1->BA1_DATNAS),1,6)+"2000")
										dDatBlo+=1
									Else
										dDatBlo-=1
									Endif
									/*Adicionado retorno vetor de bloqueados */
									Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2
									If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
										Aadd( aLog, STR0009) //" -----------> BLOQUEIO POR MAIORIDADE UNIVERSITมRIA"
										Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
										Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
										Aadd( aLog, STR0012 + cMotMai ) //" Motivo-----> "
										Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) ) //" Nascimento-> "
										Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
										Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Hoje-> "
										Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Bloq-> "
										If Len(aRetMaior) > 0
											Aadd( aLog, STR0017 + aRetMaior[2] ) //" Nivel------> "
										Endif
										Aadd( aLog, " ")
									ElseIf lGrav .And. nAcao == 3
										Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
									Endif
									dDatBlo := CtoD("//")
								Else
									/*Adicionado retorno vetor de bloqueados */
									Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) //Efetua o bloqueio, caso nAcao == 2
									If lGrav .And. nAcao == 1 // Analisa e nao bloqueia
										Aadd( aLog, STR0009)//" -----------> BLOQUEIO POR MAIORIDADE UNIVERSITมRIA"
										Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//" Matricula--> "
										Aadd( aLog, STR0011 + BA1->BA1_NOMUSR )//" Nome-------> "
										Aadd( aLog, STR0012 + cMotMai )//" Motivo-----> "
										Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) )//" Nascimento-> "
										Aadd( aLog, STR0014 + DtoC(dDatBlo) )//" Bloqueio---> "
										Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Hoje-> "
										Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Bloq-> "
										If Len(aRetMaior) > 0
											Aadd( aLog, STR0017 + aRetMaior[2] )//" Nivel------> "
										Endif
										Aadd( aLog, " ")
									ElseIf lGrav .And. nAcao == 3
										Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
									Endif
								Endif
							Endif
							nIdaUni := IIF(cMv_Par16==Nil,Mv_Par16,cMv_Par16)
							
							
						Endif

						// Trata a maioridade quando nao universitarios...
						If nIdaMai == 0
							aRetMaior	:= Maioridade()
							nIdaMai		:= aRetMaior[1]
						Endif
						If BA1->BA1_UNIVER <> "1" .AND. nIdaMai > 0
							If	nIdaMai >= INT((dDatDe  - BA1->BA1_DATNAS) / 365.25, 3) .AND.;
									nIdaMai <= INT((dDatAte - BA1->BA1_DATNAS) / 365.25, 3)
								If Empty(dDatBlo)
									dDatBlo := BA1->BA1_DATNAS + INT(nIdaMai * 365.25, 3)
									If SubStr(DtoC(dDatBlo),1,5) == "31/12" .OR. CtoD(SubStr(DtoC(dDatBlo),1,6)+"2000") < CtoD(SubStr(DtoC(BA1->BA1_DATNAS),1,6)+"2000")
										dDatBlo+=1
									Else
										dDatBlo-=1
									Endif
									/*Adicionado retorno vetor de bloqueados */
									Aadd(aBenBlo, (PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.))) // Efetua o bloqueio, caso nAcao == 2
									If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
										Aadd( aLog, STR0018)//" -----------> BLOQUEIO POR MAIORIDADE"
										Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//" Matricula--> "
										Aadd( aLog, STR0011 + BA1->BA1_NOMUSR )//" Nome-------> "
										Aadd( aLog, STR0012 + cMotMai )//" Motivo-----> "
										Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) )//" Nascimento-> "
										Aadd( aLog, STR0014 + DtoC(dDatBlo) )//" Bloqueio---> "
										Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Hoje-> "
										Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Bloq-> "
										If Len(aRetMaior) > 0
											Aadd( aLog, " Nivel------> " + aRetMaior[2] )
										Endif
										Aadd( aLog, " ")
									ElseIf lGrav .And. nAcao == 3
										Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
									Endif
									dDatBlo := CtoD("//")
								Else
									/*Adicionado retorno vetor de bloqueados */
									Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2
									If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
										Aadd( aLog, STR0018) //" -----------> BLOQUEIO POR MAIORIDADE"
										Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
										Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
										Aadd( aLog, STR0012 + cMotMai ) //" Motivo-----> "
										Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) ) //" Nascimento-> "
										Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
										Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Hoje-> "
										Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Bloq-> "
										If Len(aRetMaior) > 0
											Aadd( aLog, STR0017 + aRetMaior[2] ) //" Nivel------> "
										Endif
										Aadd( aLog, " ")
									ElseIf lGrav .And. nAcao == 3
										Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
									Endif
								Endif
							Endif
							nIdaMai := IIF(cMv_Par15==Nil,Mv_Par15,cMv_Par15)
						Endif
					Endif
				ENDIF
				
				If BA1->BA1_UNIVER == "1"
				
					nIdade := Calc_Idade(dDataBase, BA1->BA1_DATNAS) 
								
					If nIdade > 24
						
						If EMPTY(BA1->BA1_DATBLO) .AND. EMPTY(BA1->BA1_MOTBLO) .OR. nAcao == 1
						
							BD2->(dbSetOrder(3))
							If BD2->(MsSeek(xFilial("BD2") + "1"))
								
								If EMPTY(aCodDoc)
									While BD2->(BD2_FILIAL + BD2_UNIVER) == xFilial("BD2") + "1"
										
										AADD(aCodDoc, {BD2->BD2_CODDOC, BD2->BD2_DESCRI})
										
										BD2->(dbSkip())
									EndDo
								EndIf
								
								nDoc := LEN(aCodDoc)
								
								BCP->(dbSetOrder(1))
								For nLenCdDoc := 1 To nDoc
								
									If BCP->(MsSeek(xFilial("BCP") + BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC) + BA1->BA1_TIPREG + aCodDoc[nLenCdDoc][1]))
										
										If BCP->BCP_DATVAL < dDatBlo
											
											cMotBlo := "100"
											
											Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotBlo,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) //Efetua o bloqueio, caso nAcao == 2
											If lGrav .And. nAcao == 1 // Analisa e nao bloqueia
												Aadd( aLog, STR0028)//"----------------------------> BLOQUEIO POR DOCUMENTAวรO INVมLIDA"
												Aadd( aLog, STR0029 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//"Matricula-------------------> "
												Aadd( aLog, STR0030 + BA1->BA1_NOMUSR )//"Nome------------------------> "
												Aadd( aLog, STR0031 + cMotBlo )//"Motivo----------------------> "
												Aadd( aLog, STR0032 + DtoC(dDatBlo) )//"Bloqueio--------------------> "
												Aadd( aLog, STR0033 + DTOC(BCP->BCP_DATVAL))//"vencimento do documento ----> "
												Aadd( aLog, STR0034 + aCodDoc[nLenCdDoc][1] + " - " + aCodDoc[nLenCdDoc][2])//"C๓d./Descr. do documento ---> "
												Aadd( aLog, " ")
											ElseIf lGrav .And. nAcao == 3
												Aadd( aLog, { "BA1", BA1->( Recno() ),cMotBlo,dDatBlo,BG1->BG1_BLOFAT } )
											Endif
										EndIf
									EndIf 
									
									If  !EMPTY(BA1->BA1_DATBLO)
										EXIT
									EndIf                                                     
								Next
							EndIf
						EndIf
					EndIf 
				EndIf
				
				If nBlqCasa == 1	//BLOQUEIO POR CASAMENTO
					If !Empty(BA1->BA1_DATCAS) .AND. BA1->BA1_GRAUPA $ MV_PAR14
						dDatBlo := BA1->BA1_DATCAS
						BG1->( MsSeek(xFilial("BG1")+cMotCasa) )
						/*Adicionado retorno vetor de bloqueados */
						Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotCasa,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2
						If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
							Aadd( aLog, STR0021) //" -----------> BLOQUEIO POR CASAMENTO"
							Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
							Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
							Aadd( aLog, STR0012 + cMotCasa ) //" Motivo-----> "
							Aadd( aLog, STR0022 + DtoC(BA1->BA1_DATCAS) ) //" Casamento-> "
							Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
							Aadd( aLog, " ")
						ElseIf lGrav .And. nAcao == 3
							Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
						EndIf
					EndIf
				Endif
				BA1->( dbSkip() )
			Enddo
		Endif
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Testa se a familia deve ser bloqueada...                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se a familia fizer parte de grupo familiar nใo efetua o bloqueio    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !EMPTY(BA3->BA3_GRPFAM)
			TrbDesbl->( DbSkip() )
			Loop
		EndIf

		//--------------------------------------------------------------------
		// Posiciona o titular da familia...
		//--------------------------------------------------------------------
		BA1->( MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
		
		//--------------------------------------------------------------------
		//Verifica se o documento vinculado ao titular impede o bloqueio.
		//--------------------------------------------------------------------
		BCP->(DbSetOrder(1))	
		lDocImpBlo := .F.
		cTipRegAnt := ""
		If BCP->(DbSeek(xFilial("BCP")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)))
			
			//Caso tenha encontrado o documento, busca em todos os documentos entregues para o mesmo beneficiario.
			BD2->(DbSetOrder(1))
			While (BCP->(!EOF()) 						.AND.;
					BCP->BCP_FILIAL == xFilial("BCP")	.AND.;
					BCP->BCP_CODOPE == BA1->BA1_CODINT	.AND.;
					BCP->BCP_CODEMP == BA1->BA1_CODEMP	.AND.;
					BCP->BCP_MATRIC == BA1->BA1_MATRIC .AND.;
					BCP->BCP_TIPREG == BA1->BA1_TIPREG)
				
				If BCP->BCP_DATVAL < dDatBlo 
				
					//Posiciona na BD2 (Documentos) o registro entregue e checa se o documento impede o bloqueio do usuario.
					if (BCP->BCP_ENTREG == "1" .and. BD2->(DbSeek(xFilial("BD2")+BCP->BCP_CODDOC)) .and. BD2->BD2_IMPBLO == "1") .and. ; 
					   (EMPTY(BCP->BCP_DATINC) .and. EMPTY(BCP->BCP_DATVAL) .or. BCP->BCP_DATINC < dDatBlo .and. BCP->BCP_DATVAL > dDatBlo) 
						
						//Foi encontrado documento vinculado ao beneficiario que impede o bloqueio.
						//Verifica-se se jแ foi criado log para este beneficiแrio e, caso positivo, s๓ inclui o documento na lista.
						//Caso contrแrio, inclui o nome do beneficiario e demais informa็๕es no log (registro inicial).
						if cTipRegAnt <> 	BCP->BCP_MATRIC+BCP->BCP_TIPREG
							
							//Armazena o registro atual para ser comparado na proxima itera็ใo.
							cTipRegAnt :=	BCP->BCP_MATRIC+BCP->BCP_TIPREG
							
							Aadd( aLog, STR0026) //" -----------> USUARIO POSSUI DOCUMENTO QUE IMPEDE BLOQUEIO"
							Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
							Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
							Aadd( aLog, STR0027 + BD2->BD2_DESCRI ) //" Documento--> "
							Aadd( aLog, "")		
						else
							Aadd( aLog, STR0027 + BD2->BD2_DESCRI ) //" Documento--> "
						endif
													
						lDocImpBlo := .T.
						
						BCP->(DbSkip())
					else
						BCP->(DbSkip())
					endif
				Else
					BCP->(DbSkip())	
				EndIf 		
			EndDo
			
			if lDocImpBlo
				TrbDesbl->( DbSkip() )
				Loop //Nใo ้ mais necessแrio fazer as verifica็๕es a partir desse ponto, visto que o beneficiario possui documento que impede o bloqueio.
			endif	
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Para cada familia lida verifico bloqueio...                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If Empty(dDatBlo)
			If __cNivBlq == '1'
				dDatBlo := BA3->BA3_LIMITE		// Limite DEMITIDOS / APOSENTADOS
			Elseif __cNivBlq == '2'
				dDatBlo := dDataBase			// Finaneiro
			Endif
			/*Adicionado retorno vetor de bloqueados */
			Aadd(aFMlBlo, PL260BLOCO("BA3",BA3->(RecNo()),4,.T.,cMotBlo,dDatBlo,BG1->BG1_BLOFAT,nAcao,aLog,@lGrav,.T.,.F.)) // Efetua o bloqueio, caso nAcao == 2
			If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
				If __cNivBlq == '1'
					Aadd( aLog, STR0019) //" -----------> BLOQUEIO DA FAMอLIA POR LIMITE DEMITIDOS/APOSENTADOS"
				Elseif __cNivBlq == '2'
					Aadd( aLog, STR0020) //" -----------> BLOQUEIO DA FAMอLIA POR MOTIVO FINANCEIRO"
				Endif
				Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
				Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
				Aadd( aLog, STR0012 + cMotMai ) //" Motivo-----> "
				Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) ) //" Nascimento-> "
				Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
				Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Hoje-> "
				Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Bloq-> "
				If Len(aRetMaior) > 0
					Aadd( aLog, STR0017 + aRetMaior[2] ) //" Nivel------> "
				Endif
				Aadd( aLog, " ")
			ElseIf lGrav .And. nAcao == 3
				Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
			Endif
			dDatBlo := CtoD("//")
		Else
			/*Adicionado retorno vetor de bloqueados */
			Aadd(aFMlBlo, PL260BLOCO("BA3",BA3->(RecNo()),4,.T.,cMotBlo,dDatBlo,BG1->BG1_BLOFAT,nAcao,aLog,@lGrav,.T.,.F.)) // Efetua o bloqueio, caso nAcao == 2
			If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
				If __cNivBlq == '1'
					Aadd( aLog, STR0019)//" -----------> BLOQUEIO DA FAMอLIA POR LIMITE DEMITIDOS/APOSENTADOS"
				Elseif __cNivBlq == '2'
					Aadd( aLog, STR0020)//" -----------> BLOQUEIO DA FAMอLIA POR MOTIVO FINANCEIRO"
				Endif
				Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//" Matricula--> "
				Aadd( aLog, STR0011 + BA1->BA1_NOMUSR )//" Nome-------> "
				Aadd( aLog, STR0012 + cMotMai )//" Motivo-----> "
				Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) )//" Nascimento-> "
				Aadd( aLog, STR0014 + DtoC(dDatBlo) )//" Bloqueio---> "
				Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Hoje-> "
				Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Bloq-> "
				If Len(aRetMaior) > 0
					Aadd( aLog, STR0017 + aRetMaior[2] )//" Nivel------> "
				Endif
				Aadd( aLog, " ")
			ElseIf lGrav .And. nAcao == 3
				Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
			Endif
		Endif
	Endif

	TrbDesbl->(DbSkip())
	lBloqFam := .F.
	cTit := ""
EndDo

TrbDesbl->(dbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Bloqueio automแtico das familias que fazem parte do grupo familiar                |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//INICIO

If lGrpFam 
	cFor   := " SELECT * FROM " + RetSQLName("BA3")
	cFor   += " WHERE BA3_FILIAL = '"+xFilial("BA3")+"' "
	cFor   += " And BA3_CODINT >= '"+cIntDe+"' And BA3_CODINT <= '"+cIntAte+"'"
	cFor   += " And BA3_CODEMP >= '"+cGruDe+"' And BA3_CODEMP <= '"+cGruAte+"'"
	cFor   += " And BA3_MATRIC >= '"+cMatrDe+"' And BA3_MATRIC <= '"+cMatrAte+"'"
	cFor   += " And D_E_L_E_T_ = ''"
	cFor   += " ORDER BY BA3_CODEMP"
	cFor := ChangeQuery(cFor )
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFor),"TrbDe",.F.,.T.)

	TrbDe->(dbGotop())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existem registros selecionados de acordo com parametro..ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	While !TrbDe->(EOF())
		AaDd(aFam, TrbDe->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC))
		TrbDe->(dbSkip())
	EndDo

	TrbDe->(dbCloseArea())

	nReg := LEN(aFam)
	ProcRegua(nReg)
	For nI := 1 To nReg

		cFamPrin := aFam[nI]
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ IncProc																ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !lJob
			IncProc( STR0008+Transform(cFamPrin, __cPictFam) ) //"Analisando familia - "
		EndIf
		cSQL := "SELECT BA3_CODINT,BA3_CODEMP, BA3_MATRIC, BA3_GRPFAM, BA3_BLOFAT,R_E_C_N_O_ FROM " + cRetBA3 

		If lGetDB 
			cSQL  += " WHERE SUBSTR(BA3_GRPFAM,1,14) = '" + cFamPrin + "' AND D_E_L_E_T_ = ''"
			cSQL  += " OR BA3_CODINT || BA3_CODEMP || BA3_MATRIC = '"  + cFamPrin + "' AND D_E_L_E_T_ = ''"
		Else
			cSQL  += "  WHERE SUBSTRING(BA3_GRPFAM,1,14) = '" + cFamPrin + "' AND D_E_L_E_T_ = ''"
			cSQL  += " OR BA3_CODINT + BA3_CODEMP + BA3_MATRIC = '"  + cFamPrin + "' AND D_E_L_E_T_ = ''"
		Endif

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBL",.F.,.T.)

		//Recupera a quantidade de registros da TrbBL e armazena em nQuant
		Count To nQuant
		
		//Se houver registros, prossegue o processamento
		If nQuant > 1

			TrbBL->(dbGoTop())

			While !TrbBL->(EOF())
				If TrbBL->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC) == cFamPrin
					If !EMPTY(TrbBL->BA3_BLOFAT)
						lBloqFam := .T.
						EXIT
					EndIf
				EndIf

				TrbBL->(dbSkip())
			EndDo

			TrbBL->(dbGoTop())

			//---------------------------------------------------------------------------------------
			//  se no bloqueio automแtico a familia principal do grupo familiar nใo for bloqueada
			//  serแ feito o bloqueio por beneficiแrio de todos os beneficiแrio que fazem parte
			//  do grupo familiar de acordo com as regras
			//---------------------------------------------------------------------------------------
			If !lBloqFam

				If BG3->(FieldPos("BG3_BQGPFM")) > 0

					dbSelectArea("BG3")
					dbSetOrder(1)
					If dbSeek(xFilial("BG3")+cMotMai)

						//-----------------------------------------------------------------------------------------
						// Verifica se este motivo de bloqueio permite bloquear os beneficiแrios do grupo familiar
						//-----------------------------------------------------------------------------------------
						If BG3->BG3_BQGPFM == "1"

							For nCont := 1 To nQuant

								if BA1->( MsSeek(xFilial("BA1")+TrbBL->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
									While	BA1->(!Eof() )						.AND.;
										BA1->BA1_FILIAL == xFilial("BA1")		.AND.;
										BA1->BA1_CODINT == TrbBL->BA3_CODINT	.AND.;
										BA1->BA1_CODEMP == TrbBL->BA3_CODEMP	.AND.;
										BA1->BA1_MATRIC == TrbBL->BA3_MATRIC

										If 	(!Empty(BA1->BA1_DATBLO) .OR. !Empty(BA1->BA1_MOTBLO)) .OR.;
											(BTS->(MsSeek(xFilial()+BA1->BA1_MATVID)) .and. BTS->BTS_INVALI = '1')
											BA1->( DbSkip() )
											Loop
										Endif
										
										//--------------------------------------------------------------------
										//Verifica se os documentos vinculados ao titular impede o bloqueio.
										//--------------------------------------------------------------------
										BCP->(DbSetOrder(1))	
										lDocImpBlo := .F.
										cTipRegAnt := ""
										
										//Verifica se existe documento entregue vinculado ao beneficiแrio
										If BCP->(DbSeek(xFilial("BCP")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG))
											
											//Caso tenha encontrado o documento, busca todos os documentos entregues para o mesmo beneficiario.
											BD2->(DbSetOrder(1))
											While (BCP->(!EOF()) 						.AND.;
													BCP->BCP_FILIAL == xFilial("BCP")	.AND.;
													BCP->BCP_CODOPE == BA1->BA1_CODINT	.AND.;
													BCP->BCP_CODEMP == BA1->BA1_CODEMP	.AND.;
													BCP->BCP_MATRIC == BA1->BA1_MATRIC .AND.;
													BCP->BCP_TIPREG == BA1->BA1_TIPREG)
																			
												//Posiciona na BD2 (Documentos) o registro entregue e checa se o documento impede o bloqueio do usuario.
												if (BCP->BCP_ENTREG == "1" .and. BD2->(DbSeek(xFilial("BD2")+BCP->BCP_CODDOC)) .and. BD2->BD2_IMPBLO == "1") .and. ; 
					   							   (EMPTY(BCP->BCP_DATINC) .and. EMPTY(BCP->BCP_DATVAL) .or. BCP->BCP_DATINC < dDatBlo .and. BCP->BCP_DATVAL > dDatBlo) 
													
													//Foi encontrado documento vinculado ao beneficiario que impede o bloqueio.
													//Verifica-se se jแ foi criado log para este beneficiแrio e, caso positivo, s๓ inclui o documento na lista.
													//Caso contrแrio, inclui o nome do beneficiario e demais informa็๕es no log (registro inicial).
													if cTipRegAnt <> 	BCP->BCP_MATRIC+BCP->BCP_TIPREG
														
														//Armazena o registro atual para ser comparado na proxima itera็ใo.
														cTipRegAnt :=	BCP->BCP_MATRIC+BCP->BCP_TIPREG
														
												
														Aadd( aLog, STR0026) //" -----------> USUARIO POSSUI DOCUMENTO QUE IMPEDE BLOQUEIO"
														Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
														Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
														Aadd( aLog, STR0027 + BD2->BD2_DESCRI ) //" Documento--> "
														Aadd( aLog, "")	 
													else
														Aadd( aLog, STR0027 + BD2->BD2_DESCRI ) //" Documento--> "
													endif
																						
													lDocImpBlo := .T.
													
													BCP->(DbSkip())
												else
													BCP->(DbSkip())
												endif			
											EndDo
											
											if lDocImpBlo
												BA1->( DbSkip() )
												Loop //Nใo ้ mais necessแrio fazer as verifica็๕es a partir desse ponto, visto que o beneficiario possui documento que impede o bloqueio.
											endif	
										EndIf

										// Regra 1 - Maioriadade. Caso seja considerado via perguntas.
										If nBloMai == 1

											// Caso seja um dependente selecionado.
											If BA1->BA1_TIPUSU # cTitular .AND. BA1->BA1_GRAUPA $ cGrauPa
											    
											    // Trata a maioridade para universitarios...
												If nIdaUni == 0
													aRetMaior	:= Maioridade()
													nIdaUni		:= aRetMaior[1]
												ELSE
													nIdaUni := nIdaMai
												Endif

												//--------------------------------------------------------------------------------
												// Verifica se deve desconsiderar o bloqueio por maioridade de deficiente fํsico
												//--------------------------------------------------------------------------------
												If BTS->BTS_DEFFIS == "1"
													If BQC->(FieldPos("BQC_BQDEFI")) > 0
														If BQC->BQC_BQDEFI == "1"
															BA1->( DbSkip() )
															Loop
														EndIf
													EndIf
												EndIf

												If BA1->BA1_UNIVER == "1" .AND. nIdaUni > 0
													If	nIdaUni >= INT((dDatDe  - BA1->BA1_DATNAS) / 365.25, 3) .AND.;
															nIdaUni <= INT((dDatAte - BA1->BA1_DATNAS) / 365.25, 3)

														If Empty(dDatBlo)
															dDatBlo := BA1->BA1_DATNAS + INT(nIdaMai * 365.25, 3)
															If SubStr(DtoC(dDatBlo),1,5) == "31/12" .OR. CtoD(SubStr(DtoC(dDatBlo),1,6)+"2000") < CtoD(SubStr(DtoC(BA1->BA1_DATNAS),1,6)+"2000")
																dDatBlo+=1
															Else
																dDatBlo-=1
															Endif
															/*Adicionado retorno vetor de bloqueados */
															Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2
															If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
																Aadd( aLog, STR0009) //" -----------> BLOQUEIO POR MAIORIDADE UNIVERSITมRIA"
																Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
																Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
																Aadd( aLog, STR0012 + cMotMai ) //" Motivo-----> "
																Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) ) //" Nascimento-> "
																Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
																Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Hoje-> "
																Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Bloq-> "
																If Len(aRetMaior) > 0
																	Aadd( aLog, STR0017 + aRetMaior[2] ) //" Nivel------> "
																Endif
																Aadd( aLog, " ")
															ElseIf lGrav .And. nAcao == 3
																Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
															Endif
															dDatBlo := CtoD("//")
														Else
															/*Adicionado retorno vetor de bloqueados */
															Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) //Efetua o bloqueio, caso nAcao == 2
															If lGrav .And. nAcao == 1 // Analisa e nao bloqueia
																Aadd( aLog, STR0009)//" -----------> BLOQUEIO POR MAIORIDADE UNIVERSITมRIA"
																Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//" Matricula--> "
																Aadd( aLog, STR0011 + BA1->BA1_NOMUSR )//" Nome-------> "
																Aadd( aLog, STR0012 + cMotMai )//" Motivo-----> "
																Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) )//" Nascimento-> "
																Aadd( aLog, STR0014 + DtoC(dDatBlo) )//" Bloqueio---> "
																Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Hoje-> "
																Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Bloq-> "
																If Len(aRetMaior) > 0
																	Aadd( aLog, STR0017 + aRetMaior[2] )//" Nivel------> "
																Endif
																Aadd( aLog, " ")
															ElseIf lGrav .And. nAcao == 3
																Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
															Endif
														Endif
													Endif
													nIdaUni := IIF(cMv_Par16==Nil,Mv_Par16,cMv_Par16)
												Endif

												// Trata a maioridade quando nao universitarios...
												If nIdaMai == 0
													aRetMaior	:= Maioridade()
													nIdaMai		:= aRetMaior[1]
												Endif
												If BA1->BA1_UNIVER <> "1" .AND. nIdaMai > 0
													If	nIdaMai >= INT((dDatDe  - BA1->BA1_DATNAS) / 365.25, 3) .AND.;
															nIdaMai <= INT((dDatAte - BA1->BA1_DATNAS) / 365.25, 3)

														If Empty(dDatBlo)
															dDatBlo := BA1->BA1_DATNAS + INT(nIdaMai * 365.25, 3)
															If SubStr(DtoC(dDatBlo),1,5) == "31/12" .OR. CtoD(SubStr(DtoC(dDatBlo),1,6)+"2000") < CtoD(SubStr(DtoC(BA1->BA1_DATNAS),1,6)+"2000")
																dDatBlo+=1
															Else
																dDatBlo-=1
															Endif
															/*Adicionado retorno vetor de bloqueados */
															Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2
															If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
																Aadd( aLog, STR0018)//" -----------> BLOQUEIO POR MAIORIDADE"
																Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//" Matricula--> "
																Aadd( aLog, STR0011 + BA1->BA1_NOMUSR )//" Nome-------> "
																Aadd( aLog, STR0012 + cMotMai )//" Motivo-----> "
																Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) )//" Nascimento-> "
																Aadd( aLog, STR0014 + DtoC(dDatBlo) )//" Bloqueio---> "
																Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Hoje-> "
																Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Bloq-> "
																If Len(aRetMaior) > 0
																	Aadd( aLog, " Nivel------> " + aRetMaior[2] )
																Endif
																Aadd( aLog, " ")
															ElseIf lGrav .And. nAcao == 3
																Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
															Endif
															dDatBlo := CtoD("//")
														Else
															/*Adicionado retorno vetor de bloqueados */
															Aadd(aBenBlo,PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotMai,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2

															If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
																Aadd( aLog, STR0018) //" -----------> BLOQUEIO POR MAIORIDADE"
																Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
																Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
																Aadd( aLog, STR0012 + cMotMai ) //" Motivo-----> "
																Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) ) //" Nascimento-> "
																Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
																Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Hoje-> "
																Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Bloq-> "
																If Len(aRetMaior) > 0
																	Aadd( aLog, STR0017 + aRetMaior[2] ) //" Nivel------> "
																Endif
																Aadd( aLog, " ")
															ElseIf lGrav .And. nAcao == 3
																Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
															Endif
														Endif
													Endif
													nIdaMai := IIF(cMv_Par15==Nil,Mv_Par15,cMv_Par15)
												Endif
											Endif
											BA1->(dbSkip())
										ENDIF
										
										If BA1->BA1_UNIVER == "1"
											
											//Bloqueio por comprovante universitแrio vencido.
											nIdade := Calc_Idade(dDataBase, BA1->BA1_DATNAS) 
								
											If nIdade > 24
												
												If EMPTY(BA1->BA1_DATBLO) .AND. EMPTY(BA1->BA1_MOTBLO) .OR. nAcao == 1
													
													BD2->(dbSetOrder(3))
													If BD2->(MsSeek(xFilial("BD2") + "1"))
														
														If EMPTY(aCodDoc)
															While BD2->(BD2_FILIAL + BD2_UNIVER) == xFilial("BD2") + "1"
																
																AADD(aCodDoc, {BD2->BD2_CODDOC, BD2->BD2_DESCRI})
																
																BD2->(dbSkip())
															EndDo
														EndIf
														
														nDoc := LEN(aCodDoc)
														
														BCP->(dbSetOrder(1))
														For nLenCdDoc := 1 To nDoc
														
															If BCP->(MsSeek(xFilial("BCP") + BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC) + BA1->BA1_TIPREG + aCodDoc[nLenCdDoc][1]))
																
																If BCP->BCP_DATVAL < dDatBlo
																	
																	cMotBlo := "100"
																	
																	Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotBlo,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) //Efetua o bloqueio, caso nAcao == 2
																	If lGrav .And. nAcao == 1 // Analisa e nao bloqueia
																		Aadd( aLog, STR0028)//"----------------------------> BLOQUEIO POR DOCUMENTAวรO INVมLIDA"
																		Aadd( aLog, STR0029 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//"Matricula-------------------> "
																		Aadd( aLog, STR0030 + BA1->BA1_NOMUSR )//"Nome------------------------> "
																		Aadd( aLog, STR0031 + cMotBlo )//"Motivo----------------------> "
																		Aadd( aLog, STR0032 + DtoC(dDatBlo) )//"Bloqueio--------------------> "
																		Aadd( aLog, STR0033 + DTOC(BCP->BCP_DATVAL))//"vencimento do documento ----> "
																		Aadd( aLog, STR0034 + aCodDoc[nLenCdDoc][1] + " - " + aCodDoc[nLenCdDoc][2])//"C๓d./Descr. do documento ---> "
																		Aadd( aLog, " ")
																	ElseIf lGrav .And. nAcao == 3
																		Aadd( aLog, { "BA1", BA1->( Recno() ),cMotBlo,dDatBlo,BG1->BG1_BLOFAT } )
																	Endif
																EndIf
															EndIf 
															
															If  !EMPTY(BA1->BA1_DATBLO)
																EXIT
															EndIf                                                          
														Next
													EndIf
												EndIf
											EndIf 
										EndIf			
										
										If nBlqCasa == 1	//BLOQUEIO POR CASAMENTO
											If !Empty(BA1->BA1_DATCAS) .AND. BA1->BA1_GRAUPA  $ MV_PAR14
												dDatBlo := BA1->BA1_DATCAS
												BG1->( MsSeek(xFilial("BG1")+cMotCasa) )
												/*Adicionado retorno vetor de bloqueados */
												Aadd(aBenBlo, PL260BLOUS("BA1",BA1->( Recno() ),4,.T.,cMotCasa,dDatBlo,BG1->BG1_BLOFAT,Nil,nAcao,aLog,@lGrav,.F.)) // Efetua o bloqueio, caso nAcao == 2
												If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
													Aadd( aLog, STR0021) //" -----------> BLOQUEIO POR CASAMENTO"
													Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
													Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
													Aadd( aLog, STR0012 + cMotCasa ) //" Motivo-----> "
													Aadd( aLog, STR0022 + DtoC(BA1->BA1_DATCAS) ) //" Casamento-> "
													Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
													Aadd( aLog, " ")
												ElseIf lGrav .And. nAcao == 3
													Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
												EndIf
											EndIf
										Endif
									EndDo
									BA1->(dbSkip())
								EndIf
								TrbBL->(dbSkip())
							Next
						EndIf
					EndIf
				EndIf
			Else
				If BG3->(FieldPos("BG3_BQGPFM")) > 0
				
					dbSelectArea("BG3")
					dbSetOrder(1)
					If dbSeek(xFilial("BG3")+cMotMai)

						//---------------------------------------------------------------------------------------
						//Verifica se este motivo de bloqueio permite bloquear os beneficiแrios do grupo familiar
						//---------------------------------------------------------------------------------------
						If BG1->BG1_BQGPFM == "1"

							//---------------------------------------------------------------------------------------
							//  Se a familia principal do grupo familiar for bloqueda no bloqueio automแtico
							//  todos os os beneficiแrios de todas as familias que fazem parte do grupo familiar
							//  serใo bloqueados
							//---------------------------------------------------------------------------------------
							BA1->( MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)) )
							
							//---------------------------------------------------------------------------------------
							// Para cada familia lida verifico bloqueio...                         
							//---------------------------------------------------------------------------------------
							If Empty(dDatBlo)
								If __cNivBlq == '1'
									dDatBlo := BA3->BA3_LIMITE		// Limite DEMITIDOS / APOSENTADOS
								Elseif __cNivBlq == '2'
									dDatBlo := dDataBase			// Finaneiro
								Endif

								PlsGrpFam(.F.,.T.,cFamPrin)
								
								//Verifico 
								if Len(aLogGrp260) > 0
									for nForLog := 1 to Len(aLogGrp260)
										Aadd( aLog, aLogGrp260[nForLog] )									
									next
								endif

								If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
									If __cNivBlq == '1'
										Aadd( aLog, STR0019) //" -----------> BLOQUEIO DA FAMอLIA POR LIMITE DEMITIDOS/APOSENTADOS"
									Elseif __cNivBlq == '2'
										Aadd( aLog, STR0020) //" -----------> BLOQUEIO DA FAMอLIA POR MOTIVO FINANCEIRO"
									Endif
									Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) ) //" Matricula--> "
									Aadd( aLog, STR0011 + BA1->BA1_NOMUSR ) //" Nome-------> "
									Aadd( aLog, STR0012 + cMotMai ) //" Motivo-----> "
									Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) ) //" Nascimento-> "
									Aadd( aLog, STR0014 + DtoC(dDatBlo) ) //" Bloqueio---> "
									Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Hoje-> "
									Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) ) //" Idade Bloq-> "
									If Len(aRetMaior) > 0
										Aadd( aLog, STR0017 + aRetMaior[2] ) //" Nivel------> "
									Endif
									Aadd( aLog, " ")
								ElseIf lGrav .And. nAcao == 3
									Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
								Endif
								dDatBlo := CtoD("//")
							Else

								PlsGrpFam(.F.,.T.,cFamPrin)
								
								if Len(aLogGrp260) > 0
									for nForLog := 1 to Len(aLogGrp260)
										Aadd( aLog, aLogGrp260[nForLog] )									
									next
								endif

								If lGrav .And. nAcao == 1		// Analisa e nao bloqueia
									If __cNivBlq == '1'
										Aadd( aLog, STR0019)//" -----------> BLOQUEIO DA FAMอLIA POR LIMITE DEMITIDOS/APOSENTADOS"
									Elseif __cNivBlq == '2'
										Aadd( aLog, STR0020)//" -----------> BLOQUEIO DA FAMอLIA POR MOTIVO FINANCEIRO"
									Endif
									Aadd( aLog, STR0010 + BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) )//" Matricula--> "
									Aadd( aLog, STR0011 + BA1->BA1_NOMUSR )//" Nome-------> "
									Aadd( aLog, STR0012 + cMotMai )//" Motivo-----> "
									Aadd( aLog, STR0013 + DtoC(BA1->BA1_DATNAS) )//" Nascimento-> "
									Aadd( aLog, STR0014 + DtoC(dDatBlo) )//" Bloqueio---> "
									Aadd( aLog, STR0015 + AllTrim(StrZero( INT( (dDataBase - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Hoje-> "
									Aadd( aLog, STR0016 + AllTrim(StrZero( INT( (dDatBlo   - BA1->BA1_DATNAS) / 365.25 ),3)) )//" Idade Bloq-> "
									If Len(aRetMaior) > 0
										Aadd( aLog, STR0017 + aRetMaior[2] )//" Nivel------> "
									Endif
									Aadd( aLog, " ")
								ElseIf lGrav .And. nAcao == 3
									Aadd( aLog, { "BA1", BA1->( Recno() ),cMotMai,dDatBlo,BG1->BG1_BLOFAT } )
								Endif
							Endif
							
							aLogGrp260 := {}
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		TRBBL->(dbCloseArea())
		lBloqFam := .F.
	Next
EndIf
//FIM

BA3->(dbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza dados em disco...                                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BA3->( DbCommitAll())
BA3->( dbClearFilter() )
BA3->( dbGoto(nRecBA3) )
BA1->( DbCommitAll())
BA1->( dbGoto(nRecBA1) )
BE7->( DbCommitAll())

If nAcao == 1		// Apenas avaliacao
	Pergunte(cPerg, .F.)

	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)

	If (nLastKey <> 27)
		SetDefault(aReturn,cString)
	Endif

	RptStatus( {|lEnd| ImpLog(@lEnd,wnRel,cString,nomeprog,Titulo,aLog) }, Titulo)
Endif

If nAcao == 3		// Executa o rdmake de emissao do relatorio especifico
	If ExistBlock("PL770REL")
		ExecBlock("PL770REL", .F., .F., {aLog} )
	Endif
Endif


IF nAcao == 2 .OR. mv_par20 == 2 //Verifico se a a็ใo ้ Bloqueio
	IF cTipCom <> '1'  //e se envio cartas/e-mail

		DbSelectArea("BA1")
		//Aqui, verifico se o array dos beneficiแrios PL260BLOUS estแ preenchido. Rotinas para gerar
		//cartas e e-mail. cTipCrt := 1, para sinalizar que o arquivo ้ de  beneficiแrios bloqueados.
		if ((!Empty(aBenBlo)))
			cTipCrt := 1
			if !(PLSGRCT(cTipCrt))
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Problemas para gerar cartas. Elas nใo serใo geradas!" , 0, 0, {})
			EndIf

			FOR nTy:=1 TO Len(aBenBlo)
				cPesqM 	:= ""
				cNomD 		:= ""
				cPesqM 	:= ((xFilial("BA1") + (aBenBlo[nTy][1][2]) + (aBenBlo[nTy][1][3]) + (aBenBlo[nTy][1][4]))) //.AND. BA1->BA1_TIPUSU = "T")
				cNomD 		:= (aBenBlo[nTy][1][8])
				cTipCrt := 1

				IF (BA1->(MsSeek(xFilial("BA1") + (aBenBlo[nTy][1][2]) + (aBenBlo[nTy][1][3]) + (aBenBlo[nTy][1][4])) .AND. BA1->BA1_TIPUSU = "T")) //Procuro o titular do Plano
					IF ((!Empty(BA1->BA1_EMAIL)) .AND. (cTipCom == '2'))  //Verifico se ele possui e-mail e se o parametro ้ para envio de e-mail
						EnvMail(cEmlOp, BA1->BA1_EMAIL, (aBenBlo[nTy][1][8]), BA1->BA1_NOMUSR, cTipCrt)
						IF (!cJobEML) // Se via JOB e marcado como nใo enviar e-mail, gerar carta
							GeraWord(1, CtipCRT)
						ENDIF

					ELSEIF ((!Empty(BA1->BA1_EMAIL)) .AND. (cTipCom == '4'))  //ษ obrigat๓rio o envio de e-mail e gerar carta
						EnvMail(cEmlOp, BA1->BA1_EMAIL, (aBenBlo[nTy][1][8]), BA1->BA1_NOMUSR, cTipCrt)
						GeraWord(1, CtipCRT)

					ELSEIF ((!Empty(BA1->BA1_EMAIL)) .OR. (cTipCom == '3')) //Se nใo, vejo se o e-mail esta nulo ou o parametro ้ carta
						GeraWord(1, CtipCRT)

					ENDIF

				ENDIF
			NEXT
			PLSGRV(cTipCrt) //Rotina para gravar as cartas e gerar o Word ๚nico com todos os documentos.
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "E-mails e/ou cartas geradas com sucesso para usuแrios bloqueados!" , 0, 0, {}) //Exibir no console que tudo ocorreu bem.
		ELSE
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Nใo houve usuแrios bloqueados neste processamento!" , 0, 0, {})
		ENDIF

//Gera็ใo de E-mail. Para a famํlia, apenas titular recebe o e-mail
//Reseto as variaveis privates para gerar o relat๓rio:
		nConDoc	:= 0
		lCopy1		:= .F.
		lCopy2		:= .F.
		lProc		:= .F.
		lCriaDir	:= .T.
		cArqAgl	:= ""
		cMensag	:= ""
		cPathTMP	:= ""
		aWord		:= {}
		hWord		:= Nil
		cArqDot	:= ""

//Aqui, verifico se o array das famํlias PL260BLOCO estแ preenchidos. Rotinas para gerar
//cartas e e-mail. cTipCrt := 2, para sinalizar que o arquivo ้ de familias bloqueados.
		if ((!Empty(aFMlBlo)))
			cTipCrt := 2
			if !(PLSGRCT(cTipCrt))
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Problemas para gerar cartas. Elas nใo serใo geradas!" , 0, 0, {})
			EndIf

			For nTy:=1 TO Len(aFMlBlo) //Percorre o vetor com os dados dos familiares bloqueados
				cPesqM 	:= ""
				cNomD 		:= ""
				cPesqM 	:= ((xFilial("BA1") + (aFMlBlo[nTy][1][2]) + (aFMlBlo[nTy][1][3]) + (aFMlBlo[nTy][1][4]))) //.AND. BA1->BA1_TIPUSU = "T")

				IF (BA1->(MsSeek(xFilial("BA1") + (aFMlBlo[nTy][1][2]) + (aFMlBlo[nTy][1][3]) + (aFMlBlo[nTy][1][4])) .AND. BA1->BA1_TIPUSU = "T")) //Procuro o titular do Plano
					IF ((!Empty(BA1->BA1_EMAIL)) .AND. (cTipCom == '2'))  //Verifico se ele possui e-mail e se o parametro ้ para envio de e-mail
						EnvMail(cEmlOp, BA1->BA1_EMAIL, "", BA1->BA1_NOMUSR, cTipCrt)
						IF (!cJobEML) // Se via JOB e marcado como nใo enviar e-mail, gerar carta
							GeraWord(1, CtipCRT)
						ENDIF

					ELSEIF ((!Empty(BA1->BA1_EMAIL)) .AND. (cTipCom == '4'))  //ษ obrigat๓rio o envio de e-mail e gerar carta
						EnvMail(cEmlOp, BA1->BA1_EMAIL, "", BA1->BA1_NOMUSR, cTipCrt)
						GeraWord(1, CtipCRT)

					ELSEIF ((Empty(BA1->BA1_EMAIL)) .OR. (cTipCom == '3')) //Se nใo, vejo se o e-mail esta nulo ou o parametro ้ carta
						GeraWord(1, CtipCRT)
					ENDIF

				ENDIF
			Next
			PLSGRCT(cTipCrt)
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "E-mails e/ou cartas geradas com sucesso para bloqueio de famํlias!" , 0, 0, {})
		ELSE
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Nใo houve famํlias bloqueadas neste processamento!" , 0, 0, {})
		ENDIF

	ELSEIF cTipCom == '1' .AND. !cJobEML
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "A opcao de envio de e-mails ou geracao de cartas esta desativada! Parametro MV_PLSEMLT igual a 1" , 0, 0, {})
	ENDIF
//BA1->(DbCloseArea())
ENDIF

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณPLSAVERNIV  ณ Autor ณ Padua             ณ Data ณ 02.09.2002 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Esta funcao ira tratar o nivel de cobranca do usuario      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cCodInt - Codigo da Instituicao                            ณฑฑ
ฑฑณ          ณ cCodEmp - Codigo da Empresa                                ณฑฑ
ฑฑณ          ณ cMat    - Matricula do Usuarios                            ณฑฑ
ฑฑณ          ณ cTipCon - F = Fisica, J = Juridica                         ณฑฑ
ฑฑณ          ณ cNumCon - Numero do Contrato                               ณฑฑ
ฑฑณ          ณ cVerCon - Versao do Contrato                               ณฑฑ
ฑฑณ          ณ cSubCon - Sub Contrato                                     ณฑฑ
ฑฑณ          ณ cVerSub - Versao do Sub-Contrato                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRet[01] - Codigo do Cliente                               ณฑฑ
ฑฑณ          ณ aRet[02] - Loja do Cliente                                 ณฑฑ
ฑฑณ          ณ aRet[03] - Nome do Cliente                                 ณฑฑ
ฑฑณ          ณ aRet[04] - Endereco 										  ณฑฑ
ฑฑณ          ณ aRet[05] - Municipio 		    						  ณฑฑ
ฑฑณ          ณ aRet[06] - Estado    			    					  ณฑฑ
ฑฑณ          ณ aRet[07] - Natureza 										  ณฑฑ
ฑฑณ          ณ aRet[08] - Bairro 										  ณฑฑ
ฑฑณ          ณ aRet[09] - Estado 										  ณฑฑ
ฑฑณ          ณ aRet[10] - CEP 						    				  ณฑฑ
ฑฑณ          ณ aRet[11] - Telefone 										  ณฑฑ
ฑฑณ          ณ aRet[12] - CGC 							    			  ณฑฑ
ฑฑณ          ณ aRet[13] - Inscricao Estadual  				    		  ณฑฑ
ฑฑณ          ณ aRet[14] - Tipo da Cobranca (2 - Aberta,1 - Fechada)		  ณฑฑ
ฑฑณ          ณ aRet[15] - Tipo da Empresa  (1 - Fisica,2 - Juridica)	  ณฑฑ
ฑฑณ          ณ aRet[16] - Dia do Vencimento                            	  ณฑฑ
ฑฑณ          ณ aRet[17] - Tipo (1 - Cliente, 2 - Fornecedor)           	  ณฑฑ
ฑฑณ          ณ aRet[18] - Nivel(6/Operadora(Intercambio)5Usuario/4Familia ณฑฑ
ฑฑณ          ณ                  /3SubCon/2Contr/1Empresa)                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function PLS770NIV(cCodInt,cCodEmp,cMat,cTipCon,cNumCon,cVerCon,cSubCon,cVerSub,_nTipFam,lHelp)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis Locais...                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aCliFor := {{	"ZZZZZZ",	"ZZ","","",	"",	"",	"",	"",	"",	"",	"",	"",	"",	" "," ", 0, "1", 	"1", " "}}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define se e uma cobranca que vai ate o nivel de usuario...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFAULT  lHelp    := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz as Verificacoes de Niveis de acordo com o tipo de contrato...   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if cTipCon $ "F,1"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso a cobranca esteja no nivel da Familia...                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If BA3->BA3_COBNIV == "1"  .And. (!Empty(BA3->BA3_CODCLI) .OR. !Empty(BA3->BA3_CODFOR)) // Familia
		if !Empty(BA3->BA3_CODCLI)
			aCliFor := PLSAPGEND(BA3->BA3_CODCLI,BA3->BA3_LOJA,"2",BG9->BG9_TIPO,BA3->BA3_VENCTO,"4")
		Else
			aCliFor := PLSARCEND(BA3->BA3_CODFOR,BA3->BA3_LOJFOR,"2",BG9->BG9_TIPO,BA3->BA3_VENCTO,"4")
		Endif
	Else
		//If lHelp
			//Help("",1,"PLSVNPFI")
		//Endif
		Return(aCliFor)
	Endif

Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Caso a cobranca esteja no nivel da Familia...                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If BA3->BA3_COBNIV == "1"  .And. (!Empty(BA3->BA3_CODCLI) .Or. !Empty(BA3->BA3_CODFOR)) // Familia
		if !Empty(BA3->BA3_CODCLI)
			aCliFor := PLSAPGEND(BA3->BA3_CODCLI,BA3->BA3_LOJA,"1",BG9->BG9_TIPO,BA3->BA3_VENCTO,"4",BQC->BQC_GRATUI)
		Else
			aCliFor := PLSARCEND(BA3->BA3_CODFOR,BA3->BA3_LOJFOR,"1",BG9->BG9_TIPO,BA3->BA3_VENCTO,"4",BQC->BQC_GRATUI)
		Endif
	Elseif BQC->BQC_COBNIV == "1"  .And. (!Empty(BQC->BQC_CODCLI) .OR. !Empty(BQC->BQC_CODFOR)) //Sub-Conbtrato
		if !Empty(BQC->BQC_CODCLI)
			aCliFor := PLSAPGEND(BQC->BQC_CODCLI,BQC->BQC_LOJA,'',BG9->BG9_TIPO,BQC->BQC_VENCTO,"3",BQC->BQC_GRATUI)
		Else
			aCliFor := PLSARCEND(BQC->BQC_CODFOR,BQC->BQC_LOJFOR,'',BG9->BG9_TIPO,BQC->BQC_VENCTO,"3",BQC->BQC_GRATUI)
		Endif
	Elseif BT5->BT5_COBNIV == "1" .And. (!Empty(BT5->BT5_CODCLI) .Or. !Empty(BT5->BT5_CODFOR)) //Contrato
		if !Empty(BT5->BT5_CODCLI)
			aCliFor := PLSAPGEND(BT5->BT5_CODCLI,BT5->BT5_LOJA,'',BG9->BG9_TIPO,BT5->BT5_VENCTO,"2",BQC->BQC_GRATUI)
		Else
			aCliFor := PLSARCEND(BT5->BT5_CODFOR,BT5->BT5_LOJFOR,'',BG9->BG9_TIPO,BT5->BT5_VENCTO,"2",BQC->BQC_GRATUI)
		Endif
	Elseif (!Empty(BG9->BG9_CODCLI) .Or. !Empty(BG9->BG9_CODFOR))   //Empresa
		if !Empty(BG9->BG9_CODCLI)
			aCliFor := PLSAPGEND(BG9->BG9_CODCLI,BG9->BG9_LOJA,'',BG9->BG9_TIPO,BG9->BG9_VENCTO,"1",BQC->BQC_GRATUI)
		Else
			aCliFor := PLSARCEND(BG9->BG9_CODFOR,BG9->BG9_LOJA,'',BG9->BG9_TIPO,BG9->BG9_VENCTO,"1",BQC->BQC_GRATUI)
		Endif
	Endif
Endif

Return(aCliFor)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaSX1   บAutor  ณArmando M. Tessaroliบ Data ณ  09/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManutencao das perguntas do arquivo SX1.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaSX1()

Local aRegs	:=	{}
Local cPerg	:=	'PLA770'

Aadd(aRegs, { cPerg,"01","Operadora De        ","","","mv_ch1","C",04,0,0,"G","",                     "mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'B89PLS','B89'),"","",""})
Aadd(aRegs, { cPerg,"02","Operadora Ate       ","","","mv_ch2","C",04,0,0,"G","",                     "mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'B89PLS','B89'),"","",""})
Aadd(aRegs, { cPerg,"03","Grupo/Empresa De    ","","","mv_ch3","C",04,0,0,"G","",                     "mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'BJLPLS','BJL'),"","",""})
Aadd(aRegs, { cPerg,"04","Grupo/Empresa Ate   ","","","mv_ch4","C",04,0,0,"G","",                     "mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'BJLPLS','BJL'),"","",""})
Aadd(aRegs, { cPerg,"05","Matricula De        ","","","mv_ch5","C",06,0,0,"G","",                     "mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'B92PLS','B92'),"","",""})
Aadd(aRegs, { cPerg,"06","Matricula Ate       ","","","mv_ch6","C",06,0,0,"G","",                     "mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'B92PLS','B92'),"","",""})
Aadd(aRegs, { cPerg,"07","Bloqueia financeiro ","","","mv_ch7","N",01,0,0,"C","",                     "mv_par07","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"08","Data ref. financeiro","","","mv_ch8","D",08,0,0,"G","",                     "mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"09","Mot. bloq.financeiro","","","mv_ch9","C",03,0,0,"G","",                     "mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'BAEPLS','BAE'),"","",""})
Aadd(aRegs, { cPerg,"10","Consid. Data Limite ","","","mv_cha","N",01,0,0,"C","",                     "mv_par10","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"11","Mot. bloq. Limite   ","","","mv_chb","C",03,0,0,"G","",                     "mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'BAEPLS','BAE'),"","",""})
Aadd(aRegs, { cPerg,"12","Bloq.por Maioridade ","","","mv_chc","N",01,0,0,"C","",                     "mv_par12","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"13","Mot. bloq. Maiori   ","","","mv_chd","C",03,0,0,"G","",                     "mv_par13","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'BAEPLS','BAE'),"","",""})
Aadd(aRegs, { cPerg,"14","Parentesco Consider ","","","mv_che","C",20,0,0,"G","PL770F3GRP(@cA770ret)","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"15","<Idade Maioridade>  ","","","mv_chf","N",02,0,0,"G","",                     "mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"16","<Idade Universit.>  ","","","mv_chg","N",02,0,0,"G","",                     "mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"17","Data Ini, Lim/Maior ","","","mv_chh","D",08,0,0,"G","",                     "mv_par17","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"18","Data Fim, Lim/Maior ","","","mv_chi","D",08,0,0,"G","",                     "mv_par18","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"19","<Data Bloq. Geral>  ","","","mv_chj","D",08,0,0,"G","",                     "mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"20","A็ใo do Programa    ","","","mv_chk","N",01,0,1,"C","",                     "mv_par20","Analisa","","","","","Bloqueia","","","","","Relat๓rio","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"21","Bloq. por Casamento ","","","mv_chl","N",01,0,0,"C","",                     "mv_par21","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs, { cPerg,"22","Mot. bloq. Casamento","","","mv_chm","C",03,0,0,"G","If(MV_PAR21 == 1,NaoVazio() .AND. ExistCpo('BG3'),.T.)","mv_par22","","","","","","","","","","","","","","","","","","","","","","","","",If(PlsGetVersao() >= 8,'BAEPLS','BAE'),"","",""})
PlsVldPerg( aRegs )

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL770F3GRPบAutor  ณGeraldo Felix Juniorบ Data ณ  05/24/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina F3 com markbrowse para selecionar os tipo de depend.บฑฑ
ฑฑบ          ณ que serao considerados no bloq. por maioridade.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL770F3GRP(cString)

	Static objCENFUNLGP := CENFUNLGP():New()

Local aDados 	:= {}
Local nCnt
Local oDlgMar
Local oDados
Local bOk		:= {|| nOpca := 1, oDlgMar:End() }
Local bCancel	:= {|| nOpca := 2, oDlgMar:End() }
Local nOpca		:= 0

Default cString := ''

BRP->( dbSetorder(01) )
BRP->( MsSeek(xFilial("BRP")) )
BRP->( dbEval({|| Aadd(aDados, {.F., BRP_CODIGO, BRP_DESCRI, BRP_SEXO})},,;
							 	{|| BRP_FILIAL == xFilial("BRP")}) )
               
DEFINE MSDIALOG oDlgMar TITLE STR0023 FROM 018,005 TO 034, 100

oDados := TcBrowse():New( 035, 002, 372, 080,,,, oDlgMar,,,,,,,,,,,, .F.,, .T.,, .F., )
ADD COLUMN TO oDados BITMAP DATA IF(!aDados[oDados:nAt,1],LoadBitmap( GetResources(), "LBNO" ),;
	LoadBitmap( GetResources(), "LBOK" )) TITLE "" WIDTH 015 ALIGN CENTERED NOHILITE

oDados:AddColumn(TcColumn():New("Grau Parentesco",nil,;
	nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil))
oDados:ACOLUMNS[2]:BDATA     := {|| aDados[oDados:nAt,2] }

oDados:AddColumn(TcColumn():New("Descricao",nil,;
	nil,nil,nil,nil,115,.F.,.F.,nil,nil,nil,.F.,nil))
oDados:ACOLUMNS[3]:BDATA     := {|| aDados[oDados:nAt,3] }

oDados:AddColumn(TcColumn():New("Sexo",nil,;
	nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))
oDados:ACOLUMNS[4]:BDATA     := {|| X3COMBO("BRP_SEXO",aDados[oDados:nAt,4]) }

oDados:BLDBLCLICK := {|| (aDados[oDados:nAt][1] := Iif(aDados[oDados:nAt][1], .F., .T.),;
	oDados:SetArray(aDados), oDados:Refresh()) }

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"BRP_CODIGO", "BRP_DESCRI", "BRP_SEXO"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oDados:aObfuscatedCols := aBls
	endif

oDados:SetArray(aDados)
oDados:Refresh()

ACTIVATE MSDIALOG oDlgMar CENTER ON INIT Eval({||EnChoiceBar(oDlgMar,{||Eval(bOk)},{||Eval(bCancel)},.F.)} )

If nOpca == K_OK
	For nCnt := 1 To Len(aDados)
		If aDados[nCnt][1]
			cString += Alltrim(aDados[nCnt][2])+','
		Endif
	Next
	cString := Substr(cString, 1, (Len(Alltrim(cString))-1))
Endif

MV_PAR14 := cString
lRefresh := .T.

Return(cString)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMaioridadeบAutor  ณArmando M. Tessaroliบ Data ณ  09/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a idade limite de maioridade definida nos niveis dosบฑฑ
ฑฑบ          ณsub-contratos, contratos e grupo/empresa, obedecebdo esta orบฑฑ
ฑฑบ          ณdem de avaliacao.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Maioridade()

LOCAL aRet := {0, "Nใo parametrizado..."}	// Zero

// SubContrato
If BQC->( FieldPos("BQC_MAIORI") ) > 0
	BQC->( DbSetOrder(1) )		// BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
	BQC->( MsSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)) )
	If BQC->BQC_MAIORI <> 0		// Zero
		aRet := {BQC->BQC_MAIORI, "BQC"} 
	Endif

// Contrato
ELSEIf BT5->( FieldPos("BT5_MAIORI") ) > 0
	BT5->( DbSetOrder(1) )		// BT5_FILIAL + BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
	BT5->( MsSeek(xFilial("BT5")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)) )
	If BT5->BT5_MAIORI <> 0		// Zero
		aRet := {BT5->BT5_MAIORI, "BT5"} 
	Endif

// Grupo/Empresa
ELSEIf BG9->( FieldPos("BG9_MAIORI") ) > 0
	BG9->( DbSetOrder(1) )		// BG9_FILIAL + BG9_CODINT + BG9_CODIGO + BG9_TIPO
	BG9->( MsSeek(xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP)) )
	If BG9->BG9_MAIORI <> 0		// Zero
		aRet := {BG9->BG9_MAIORI, "BG9"} 
	Endif
Endif

Return(aRet)		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpLog    บAutor  ณArmando M. Tessaroliบ Data ณ  10/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que ira imprimir o arquivo de LOG.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณUnimed CI.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpLog(lEnd,wnrel,cString,nomeprog,Titulo,aLog)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao Do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local nLi		:= 0			// Linha a ser impressa
Local nMax		:= 58			// Maximo de linhas suportada pelo relatorio
Local cbCont	:= 0			// Numero de Registros Processados
Local cbText	:= SPACE(10)	// Mensagem do Rodape
Local cCabec1	:= "" 			// Label dos itens
Local cCabec2	:= "" 			// Label dos itens

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis especificas para este relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nI		:= 0			// Controle de laco

cCabec1 := STR0002 //"Relat๓rio de anแlise do bloqueio de famํlia e usuแrio"

SetRegua( Len(aLog) )

For nI := 1 To Len(aLog)

	IncRegua()

	If lEnd
		@Prow()+1,000 PSay "CANCELADO PELO OPERADOR..."
		Exit
	Endif

	IncLine(@nLi,1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi,000 PSay aLog[nI]

Next nI

If nLi == 0
	IncLine(@nLi,nMax+1,nMax,titulo,cCabec1,cCabec2,nomeprog,tamanho)
	@ nLi+1,000 PSay "Nใo hแ informa็๕es para imprimir este relat๓rio"
Endif

Roda(cbCont,cbText,Tamanho)

Set Device To Screen
If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncLine   บAutor  ณArmando M. Tessaroliบ Data ณ  06/02/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Incrementa o contador de linhas para impressใo nos relatoบฑฑ
ฑฑบ          ณrios e verifica se uma nova pagina sera iniciada.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nLi      - Numero da linha em que sera impresso            บฑฑ
ฑฑบ          ณ nInc     - Quantidade de linhas a serem incrementadas      บฑฑ
ฑฑบ          ณ nMax     - Numero maximo de linhas por pagina              บฑฑ
ฑฑบ          ณ Titulo   - Titulo do cabecalho do relatorio                บฑฑ
ฑฑบ          ณ cCabec1  - Primeira linha do lalbel do relatorio           บฑฑ
ฑฑบ          ณ cCabec2  - Segunda linha do label do relatorio             บฑฑ
ฑฑบ          ณ NomeProg - Nome do programa que sera impresso no cabecalho บฑฑ
ฑฑบ          ณ Tamanho  - Tamanho de colunas do relatorio                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Call Center                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncLine(nLi, nInc, nMax, Titulo, cCabec1, cCabec2, NomeProg, Tamanho)

Local nChrComp	:= IIF(aReturn[4]==1,15,18)		// Define se o caracter sera comprimido ou normal

nLi+=nInc
If nLi > nMax .or. nLi < 5
	nLi := Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nChrComp)
	nLi++
Endif

Return(.T.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EnvMail บ                           บ					         ฑฑ
ฑฑ				 Criado por: 	Renan Martins			  บ Data ณ 02/12/2014     ฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Receber variaveis para gera็ใo do e-mail para os titulares บฑฑ
ฑฑบ          ณ que estใo com familias ou dependentes bloqueados		    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//cEmlorig - E-mail operadora, cTPComun - Tipo comunica็ใo: Usuแrio ou Famํlia
Function EnvMail(cEmlorig, cEmlDest, cSubject, cTitular, cTPComun)
Local cTmp
Local aCposic		:= {}
Local cAutEml
Local lEnv			:= .F.
Local cNomDpeH	:= ""
Local cArqui
Local crecHtml	:= ""
Local cSMTPServer	:= GETMV("MV_PLSSMTP")	// "smtp.totvs.com.br"
Local cAccount   	:= GETMV("MV_PLSACCT") 	//"teste.teste"
Local cPassword 	:= GETMV("MV_PLSSMSE") 	//"xxxxxx"
Local cJobMail	:= GETMV("MV_PLSEMJB")	//Se quando JOB, resumo operadora ou e-mail clientes

//Dados do Assunto do E_mail
IF (cTPComun == 1)
	cTmp := cSubject
	cSubject := STR0024 + ' ' + cTmp // Bloqueio do Plano de Sa๚de do dependente:
ELSEIF(cTPComun == 2)
	cTmp := cSubject
	cSubject :=  STR0025 // Bloqueio do Plano de Sa๚de Familiar
	cNomDpeH := GERADPD(cTPComun)
ENDIF

//Base64 para c๓d. autenticidade (formalizar). Jun็ใo nome do beneficiแrio + data + hora da gera็ใo
cAutEml:= AllTrim(Encode64(AllTrim(cTitular) + AllTrim(DtoS(Date())) + Alltrim(Time())))

IF !(cJobAtv)	 //Se nใo for rotina Via JOB
	//Crio o array com os dados que serใo trocados no WFEmail - WORKFLOW
	IF (cTPComun == 1) //Tipo de carta/e-mail Usuแrio Bloqueado
		AAdd(aCposic, {"NOMTIT", cTitular})
		AAdd(aCposic, {"NOMEDEP", cTmp})
		AAdd(aCposic, {"MATRIC", cPesqM})
		AAdd(aCposic, {"CENTTEL", cTelCen})
		AAdd(aCposic, {"MAILOPE", cEmail})
		AAdd(aCposic, {"CODAUT", cAutEml})
	ELSEIF (cTPComun == 2) //Tipo de carta/e-mail para famํlia bloqueada
		AAdd(aCposic, {"NOMTIT", cTitular})
		AAdd(aCposic, {"NOMEDEP", cNomDpeH})
		AAdd(aCposic, {"MATRIC", ""/*cPesqM*/})
		AAdd(aCposic, {"CENTTEL", cTelCen})
		AAdd(aCposic, {"MAILOPE", cEmail})
		AAdd(aCposic, {"CODAUT", cAutEml})
	ENDIF
	//Envia E-mail Via PLSWFPROC - WorkFlow
	PlsWFProc("000080", "Processo Bloqueio", cSubject, "", cEmlDest, "", cEmlorig, cMODEML, aCposic, .F.,, @lEnv)

		//Vai usar rotina simplificada para o JOB, pois a PlsWFProc nใo funciona com JOB
ELSE
	CONNECT SMTP SERVER cSMTPServer ACCOUNT cAccount PASSWORD cPassword RESULT lEnviado
	lenviado := MailAuth(cAccount, cPassword)
	If !lenviado
		Get Mail Error cTmp
		alert ("Erro: " + cTMp )
	endif

	IF (cJobMail .AND. cTPComun == 1 .OR. cTPComun == 2) //Se .T., Clientes irใo receber e-mails normalmente
		cArqui := fopen(cMODEML)
		crecHtml:= FReadStr(cArqui, 600000 )
		crecHtml := StrTran(crecHtml, "%NOMTIT%", cTitular)
		crecHtml := IIF (cTPComun == 1, StrTran(crecHtml, "%NOMEDEP%", cTmp), IIF(cTPComun == 2, StrTran(crecHtml, "%NOMEDEP%", cNomDpeH), ""))
		crecHtml := StrTran(crecHtml, "%MATRIC%", cPesqM)
		crecHtml := StrTran(crecHtml, "%CENTTEL%", cTelCen)
		crecHtml := StrTran(crecHtml, "%MAILOPE%", cEmail)
		crecHtml := StrTran(crecHtml, "%CODAUT%", cAutEml)

		IF lenviado
			SEND MAIL FROM cEmlorig TO cEmlDest BCC cEmlorig SUBJECT cSubject ;
				BODY crecHtml FORMAT TEXT RESULT _lEnviado
		ENDIF

	ELSEIF ((!cJobMail) .AND. (cTPComun == 0))  //Enviar resumo para a operadora
		IF (lenviado)
			SEND MAIL FROM cEmlorig TO cEmlDest BCC "" SUBJECT "Resumo das Cartas de bloqueio" ;
				BODY "Cartas de Bloqueio em PDF" FORMAT TEXT  ATTACHMENT (cPathArq + "Cartas de Bloqueio.gz") ;
				RESULT _lEnviado
		ENDIF

	ENDIF
	DISCONNECT SMTP SERVER
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSGRCT  บ      บ	     		                    			 ฑฑ
ฑฑ				 Criado por: Alexandre Villar 		  บ Data ณ 22/08/2012     ฑฑ
ฑฑ				 Alterado por Renan Martins          บ Data ณ 27/11/2014     ฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao das Cartas de Bloqueio do Plano de Sa๚de         บฑฑ
ฑฑบ          ณ na rotina automแtica PLS770 via Microsoft Word 			    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSGRCT(nOpct)

If Empty(cPathArq)
	cPathArq := GetSrvProfString("StartPath", "")
Else
	If !(Substr(cPathArq,1,1) == "\" .OR. Substr(cPathArq,1,1) == "/")
		cPathTMP := GetSrvProfString("StartPath", "")
		cPathArq := IIF( Substr(cPathTMP,Len(cPathTMP),1) $ "\/", cPathTMP, cPathTMP+"\" ) + cPathArq
	EndIf
EndIf
cPathArq := IIF( Substr(cPathArq,Len(cPathArq),1) $ "\/", cPathArq, cPathArq+"\" )

If Empty(cPathEst)
	cPathEst := GetTempPath()
EndIf

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Inicia a Integracao com o Word											บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
IF (nOpct == 1)
	cArqDot 	:=  "Bloqueio_Usuario.dot"
	cArqAgl	:=  "Bloqueio_Usuarios.dot"

ELSE
	cArqDot 	:=  "Bloqueio_Familia.dot"
	cArqAgl	:=  "Bloqueio_Familias.dot"
ENDIF

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Se nao for alterado via parametro procura o arquivo na pasta "system"	บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
cPathDot := cPathArq + cArqDot
cPathAgl := cPathArq + cArqAgl

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Verifica a Existencia dos Arquivos DOT no StartPath do Protheus			บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If !File(cPathDot)
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "O arquivo de Modelo nใo foi encontrado. Arquivo nใo gerado." , 0, 0, {})
	Return()
EndIf

If !File(cPathAgl)
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "O arquivo de Modelo nใo foi encontrado. Arquivo nใo gerado." , 0, 0, {})
	Return()
EndIf

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Verifica Path do Temporแrio para grava็ใo na Estacao de Trabalho		บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If Substr(cPathEst,1,1) == "\" .OR. Substr(cPathEst,1,1) == "/"
	cMensag := "Nใo foi validado o diret๓rio temporแrio da Esta็ใo:"+CRLF+ cPathEst +CRLF+"Os arquivos temporแrios serใo gravados no diret๓rio:"+CRLF+GetTempPath()
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cMensag , 0, 0, {})
	cPathEst := GetTempPath()
EndIf

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Verifica Path para Armazenamento na Estacao de Trabalho					บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
MontaDir( cPathEst )

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Faz a copia dos arquivos do Servidor para o Remote						บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
if !(cJobAtv)
	lCopy1 := CpyS2T( cPathDot , cPathEst , .F. )
	lCopy2 := CpyS2T( cPathAgl , cPathEst , .F. )
EndIf

		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Verifica as Copias														บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
If ((!cJobAtv) .AND. (!lCopy1 .Or. !lCopy2))
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Processamento Cancelado" , "Houve um problema com a c๓pia dos arquivos de configura็ao:" + CRLF + cPathDot + CRLF + cPathEst , 0, 0, {})
	Return()
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PLSGRV   บ Autor ณ Alexandre Villar   บ Data ณ 24/08/2012  บฑฑ
ฑฑบ          ณ Alterado บ Renan Martins              บ Data ณ 04/12/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava todas as cartas em um ๚nico documento                บฑฑ
ฑฑบ          ณ Aglutina็ใo  					                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSGRV()
Local nI		:= 0
Local oArqCpc	:= ""

			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Fecha os Documentos														บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
For nI := 1 to nConDoc
	OLE_CloseFile( aWord[nConDoc] )
	OLE_CloseLink( aWord[nConDoc] )
Next

			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Cria Documento Unico para aglutinar os resultados						 บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
hWord := OLE_CreateLink()
OLE_NewFile( hWord , cPathEst + "\" + cArqAgl )
OLE_SetPropertie( hWord, oleWdVisible, .F. )

OLE_SetDocumentVar(hWord , 'nQtArqs' , nConDoc )
OLE_SetDocumentVar(hWord , 'nomeArquivo' , "\ImpCarta" )
OLE_SetDocumentVar(hWord , 'pastaDocs' , cPathEst )

OLE_UpdateFields( hWord )
OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )

OLE_ExecuteMacro( hWord , "JuntaTudo" )
OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )

IF (cJobAtv) //Exportar para pdf caso Job ativo
	OLE_ExecuteMacro(hWord, "vartypepdf" )
	oArqCpc := GzCompress(cPathArq + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".pdf", cPathArq + "Cartas de Bloqueio.gz")
	EnvMail(SuperGetMv("MV_PLSEMLO"),SuperGetMv("MV_PLSEMLO"),"","",0) //cTPComun apenas flag controle
ENDIF
			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Fecha os arquivos									บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_CloseFile( hWord )		// Fecha ultimo arquivo
OLE_CloseLink( hWord )		// Fecha link com Word

			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Apaga os Arquivos Temporarios											บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
For nI := 1 to nConDoc
	If File( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
		FErase( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
	EndIf
Next

			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Exclui os Arquivos Temporarios apos a utilizacao.						บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
if (!cJobAtv)
	If File( Lower( cPathEst + "\" + cArqDot ) )
		Ferase( Lower( cPathEst + "\" + cArqDot ) )
	EndIf

	If File( Lower( cPathEst + "\" + cArqAgl ) )
		Ferase( Lower( cPathEst + "\" + cArqAgl ) )
	EndIf
Endif
Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraWord บ Autor ณ Alexandre Villar   บ Data ณ 22/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que gera a pagina a ser impressa atraves do modelo. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraWord(nOption, nTpoCrt)
Private cNomDp	:= ""

If !( nOption == 1 .Or. nOption == 2 )
	Return(.F.)
EndIf
/*############## Carta para beneficiแrio Bloqueado #############*/
IF (nTpoCrt == 1)
	CriaNovo()
	ZeraCar()
	GravaCar( "", nOption, nTpoCrt )
	OLE_CloseFile( aWord[nConDoc] )
	OLE_CloseLink( aWord[nConDoc] )
ENDIF
/*############## Carta para famํlia Bloqueada #############*/
IF (nTpoCrt == 2)
	GERADPD(nTpoCrt)
	CriaNovo()
	ZeraCar()
	GravaCar( "" , nOption, nTpoCrt )
	OLE_CloseFile( aWord[nConDoc] )
	OLE_CloseLink( aWord[nConDoc] )
endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GeraDPD บ Autor ณ Renan Martins       บ Data ณ 04/12/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para gerar SQL com os nomes dos dependetes para     บฑฑ
ฑฑบ          ณ e-mail ou carta da rotina PLSA770                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GERADPD(nTpoCrt)
Local cSql			:= ''
Local cAlias		:= GetNextAlias()
Local cNomDpH		:= ""

/*############## Carta/E-mail para famํlia Bloqueada #############*/
IF (nTpoCrt == 2) //Se tipo carta/email ้ para famํlia
	IF (BA1->(MsSeek(cPesqM)))
		cSql := "SELECT" + CRLF
		cSql += "	BA1.BA1_NOMUSR AS DEPEND," + CRLF
		cSql += "	BA1.BA1_MATRIC AS MATRIC," + CRLF
		cSql += "	BA1.BA1_CODINT AS OPERADORA" + CRLF

		cSql += "FROM "+ RetSqlName("BA1") +" BA1 "

		cSql += "WHERE BA1.D_E_L_E_T_ = ''" + CRLF
		cSql +=   "AND BA1.BA1_FILIAL = '"+ xFilial("BA1") +"'" + CRLF
		cSql +=   "AND BA1.BA1_TIPUSU <> 'T'" + CRLF
		cSql +=   "AND BA1.BA1_CODINT = '" + BA1->BA1_CODINT +"'" + CRLF
		cSql +=   "AND BA1.BA1_CODEMP = '"+ BA1->BA1_CODEMP +"'" + CRLF
		cSql +=   "AND BA1.BA1_MATRIC = '"+ BA1->BA1_MATRIC +"'" + CRLF

		cSql := ChangeQuery(cSql)

		MemoWrite("\system\Query_CM.sql",cSql)
	EndIf

	If Select(cAlias) > 0
		(cAlias)->( DBCloseArea() )
	EndIf

	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )
	DBSelectArea(cAlias)

	(cAlias)->(DBGoTop())

	If (cAlias)->(Eof())
		(cAlias)->(DBCloseArea())
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Nใo foram encontrados dados para processar com essa parametriza็ใo" , 0, 0, {})
		Return(.F.)

	Else
		While (cAlias)->(!Eof())
			cNomDp		+= "Nome: " + Alltrim((cAlias)->Depend) + " Matrํcula: " + AllTrim(cPesqM) + "     " + CRLF
			cNomDpH	+= "Nome: " + Alltrim((cAlias)->Depend) + " Matrํcula: " + AllTrim(cPesqM) + "<br>"
			(cAlias)->(dbSkip())
		EndDo
		(cAlias)->(DBCloseArea())
	ENDIF
Endif

Return(cNomDpH)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaCar บ Autor ณ Alexandre Villar   บ Data ณ 24/08/2012  บฑฑ
ฑฑบ          ณ Alterado บ Renan Martins              บ Data ณ 04/12/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava dados na carta, de acordo com o tipo:                บฑฑ
ฑฑบ          ณ 1 - Carta para usuแrios 2 - Carta para a famํlia           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaCar( cAlias , nOption, nTPCar )
//Se carta para Beneficiแrios
IF (nTPCar == 1)
	IF ((BA1->(MsSeek(cPesqM)) .AND. BA1->BA1_TIPUSU = "T")) //Procuro o titular do Plano. cPesqM tem o valor da chave de procura
    	OLE_SetDocumentVar( aWord[nConDoc], "CIDADE"		, AllTrim(BA1->BA1_MUNICIP))
		OLE_SetDocumentVar( aWord[nConDoc], "UF"			, AllTrim(BA1->BA1_ESTADO))
		OLE_SetDocumentVar( aWord[nConDoc], "DATA"		, DtoC(Date()))
		OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENEF"	, AllTrim(BA1->BA1_NOMUSR))
		OLE_SetDocumentVar( aWord[nConDoc], "NOMEDEPEND"	, AllTrim(cNomD))
		OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL"	, IIf (Empty(cTelCen), "TELFONE" , AllTrim(cTelCen)))
		OLE_SetDocumentVar( aWord[nConDoc], "TELFAX"		, IIf (Empty(cTelFax), "FAX" , AllTrim(cTelFax)))
		OLE_SetDocumentVar( aWord[nConDoc], "EMAIL"		, IIf (Empty(cEmail)	, "EMAIL" , AllTrim(cEmail)))
		OLE_UpdateFields( aWord[nConDoc] )
		OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".DOC" ,,, .F. , oleWdFormatDocument )
	ENDIF
ENDIF

//Carta para a Familia, como remetente o titular
IF (nTPCar == 2)
	IF ((BA1->(MsSeek(cPesqM + "T")))) //Procuro o titular do Plano. cPesqM tem o valor da chave de procura
    	OLE_SetDocumentVar( aWord[nConDoc], "CIDADE"		, AllTrim(BA1->BA1_MUNICIP))
		OLE_SetDocumentVar( aWord[nConDoc], "UF"			, AllTrim(BA1->BA1_ESTADO))
		OLE_SetDocumentVar( aWord[nConDoc], "DATA"		, DtoC(Date()))
		OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENEF"	, AllTrim(BA1->BA1_NOMUSR) )
		OLE_SetDocumentVar( aWord[nConDoc], "NOMEDEPEND"	, cNomDp )
		OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL"	, IIf (Empty(cTelCen), "TELFONE" , AllTrim(cTelCen)))
		OLE_SetDocumentVar( aWord[nConDoc], "TELFAX"		, IIf (Empty(cTelFax), "FAX" , AllTrim(cTelFax)))
		OLE_SetDocumentVar( aWord[nConDoc], "EMAIL"		, IIf (Empty(cEmail)	, "EMAIL" , AllTrim(cEmail)))
		OLE_UpdateFields( aWord[nConDoc] )
		OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".DOC" ,,, .F. , oleWdFormatDocument )
	ENDIF
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZeraCar  บ Autor ณ Alexandre Villar   บ Data ณ 24/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Zera os controladores para geracao de nova Carta.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ZeraCar()

OLE_SetDocumentVar(aWord[nConDoc]	, "NOMEBENEF"	, "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "NOMEDEPEND"	, "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "MATRICULA"	, "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "DATADEZOITO"	, "" )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaNovo บ Autor ณ Alexandre Villar   บ Data ณ 24/08/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o novo arquivo para gravacao.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLS                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaNovo()

aAdd( aWord , 0 )
nConDoc++

aWord[nConDoc] := OLE_CreateLink()

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Cria o novo arquivo no Remote											บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_NewFile( aWord[nConDoc] , cPathEst + "\" + cArqDot )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Ajusta Propriedades do Arquivo											บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_SetPropertie( aWord[nConDoc] , oleWdVisible , .F. )

//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
//บ	Salva o arquivo com o novo nome no Remote								บ
//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc" ,,, .F. , oleWdFormatDocument )

Return()
