#INCLUDE "PLSA790.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "JPEG.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TopConn.ch"

STATIC __cCodMedGen := GetNewPar("MV_PLMEDPT","")
STATIC __cCodMatGen := GetNewPar("MV_PLMATPT","")
STATIC __cCodTaxGen := GetNewPar("MV_PLTAXPT","")
STATIC __cCodOpmGen := GetNewPar("MV_PLOPMPT","")

#define K_Bloqueio 9
#define __aCdCri107 {"910","Processo de autorizacao On-Line (Cancelado)"}

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA790   ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  21-07-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Auditoria de contas                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA790()
PRIVATE aRotina  :=    MenuDef()

PRIVATE aCdCores  := { { 'BR_VERMELHO'	,STR0128 },;  //'Negado'
                        { 'BR_AZUL' 	,STR0129  },; //'Pendente nao lido'
                        { 'BR_AMARELO' 	,STR0130  },; //'Pendente ja  lido'
                        { 'BR_VERDE' 	,STR0131  }}  //'Liberado para ser Auditado'

PRIVATE aCores    := {	{ 'BVX_PARECE = "1"'                  ,aCdCores[1,1] },;//vermelho
						{ 'BVX_PARECE = "3" .AND.  BVX_LNOVO' ,aCdCores[2,1] },;//azul
                        { 'BVX_PARECE = "3" .and. !BVX_LNOVO' ,aCdCores[3,1] },;//amarelo
                        { 'BVX_PARECE = "0"'                  ,aCdCores[4,1] }} //verde

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define o cabecalho da tela de atualizacoes                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cAlias    := "BVX"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama mBrowse padrao...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BVX->(MsSeek(xFilial("BVX")))
BVX->(mBrowse(06,01,22,75,'BVX'    ,,,20,,,aCores))
Return
/*/

эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁPLS790MOV Ё Autor Ё Geraldo Felix Junior  Ё Data Ё 11.07.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Auditoria medica...                                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё                                                            Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            Ё        Ё      Ё                                          Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLS790MOV()

PRIVATE cUsu    	:= RetCodUsr()
PRIVATE cSetor  	:= ""
PRIVATE lInclAt 	:= .F.
PRIVATE lBaixAt 	:= .F.
PRIVATE lReabAt 	:= .F.
PRIVATE lExclAt 	:= .F.
PRIVATE lReslAt 	:= .F.
PRIVATE nQtd    	:= 0
PRIVATE cCodInt 	:= ""
PRIVATE cCodSub 	:= ""
PRIVATE cFiltro 	:= ""
PRIVATE aProAud 	:= {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPara controle dos inicializadores padroes -- Geraldo Felix JuniorЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Inclui := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama rotina de atendimento                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
A790Atend()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё A790AtendЁ Autor ЁGeraldo Felix Junior   Ё Data Ё 11.07.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Atendimento ao cliente                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function A790Atend()

LOCAL oDlg
LOCAL oBtt1
LOCAL oBtt2
LOCAL nFor
LOCAL bBlock
LOCAL cNomCre	:= ""
LOCAL cNomeExe	:= ""
LOCAL bOk 		:= {|| oDlg:End() }
LOCAL bCancel   := {|| oDlg:End() }
LOCAL aButtons	:= {}
LOCAL cCla 		:= ""
LOCAL aCla 		:= {}
LOCAL I	   		:= 1
LOCAL dDataDe	:= cTod('')
LOCAL dDataAte  := cTod('')
LOCAL cRDA		:= ""
LOCAL cOperad   := PLSRtCdUsr()
LOCAL cIntPad   := PlsIntPad()
LOCAL aPTBot	 := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,IIF(GetNewPar("MV_PLSUNI","0")=="1",.T.,.F.)}
LOCAL lEnvTds  := .F.

PRIVATE cAliProAud
PRIVATE cRecProAud
PRIVATE oButGuia
PRIVATE oRamo
PRIVATE oContr
PRIVATE oSegur
PRIVATE oConTec
PRIVATE oConCom
PRIVATE oOcorr
PRIVATE oSay99
PRIVATE oSay98
PRIVATE oSay97
PRIVATE oSay96
PRIVATE oSay95
PRIVATE oSay94
PRIVATE oSay93
PRIVATE oSay92
PRIVATE cSql
PRIVATE oFolCob
PRIVATE cStrFil
PRIVATE oPtoS01,oPtoS02,oPtoS03,oPtoS04,oPtoS05,oPtoS06,oPtoS07,oPtoS08,oPtoS09,oPtoS10,oPtoS11,oPtoS12 //VARIAVEIS QUE PODEM SER USADAS NO SAY VIA PTO DE ENTRADA

PRIVATE cCadastro	:= STR0132 //"Auditoria de contas"
PRIVATE bF7			:= {|| PlsPosGui(),MsDocument( cAliProAud , cRecProAud , 3 )}
PRIVATE	cRamo		:= ""
PRIVATE	cContr		:= ""
PRIVATE	cSegur		:= ""
PRIVATE	cConTec		:= ""
PRIVATE	cConCom		:= ""
PRIVATE lRefresh  	:= .T.
PRIVATE lPrim  	:= .T.
PRIVATE Aheader 	:= {}
PRIVATE aCols   	:= {}
PRIVATE aRotina	  	:= 	{ { STR0001  ,''   , 0 , 1 },; //"Pesquisar"
       			          { STR0002  ,''   , 0 , 2 },; //"Visualizar"
       			          { STR0008  ,''  , 0 , 3 } } //"Atualizar"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cApolice   	:= ""
PRIVATE cCestipul  	:= ""
PRIVATE cNestipul  	:= ""
PRIVATE cCsubest   	:= ""
PRIVATE cNsubest   	:= ""
PRIVATE cContato   	:= ""
PRIVATE cContCar   	:= ""
PRIVATE cNumCer    	:= ""
PRIVATE cNomSegur  	:= ""
PRIVATE ciApolice  	:= ""
PRIVATE ciNestipul 	:= ""
PRIVATE ciCsubest  	:= ""
PRIVATE ciNsubest  	:= ""
PRIVATE ciContato  	:= ""
PRIVATE ciContCar  	:= ""
PRIVATE ciNumCer   	:= ""
PRIVATE ciNomSegur 	:= ""
PRIVATE cFilBE2		:= ""
PRIVATE aProAud 	:= {}
PRIVATE aCdCorAu  	:= {  	{ 'BR_AZUL' 	,STR0202  },;//'Registro sendo auditado por outra operadora!'
                        	{ 'BR_AMARELO' 	,STR0203  },;//'Movimentos do procedimento'
                        	{ 'BR_VERDE' 	,STR0213  }} //"Liberado para ser Auditado"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida perguntas...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza as variaveis do pergunte...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! Pergunte("PLA790",.T.)
	Return
EndIF
dDataDe  := mv_par01
dDataAte := mv_par02
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Incrementa no filtro 													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BX4->(DbSetOrder(1))
If BX4->(MsSeek(xFilial("BX4")+cOperad+cIntPad))
	If  BX4->(FieldPos("BX4_AUDITO")) > 0 .And. BE2->(FieldPos("BE2_TIPPRE")) > 0
	     cRDA := AllTrim(BX4->BX4_CLARDA)
	     If BX4->BX4_AUDITO == "1" .And. !Empty(cRDA)
	     		cRDA 	:= StrTran(cRDA,",","','")
	     		cRDA 	:= "('" + cRDA + "')"
	     		cFilBE2 := " AND BE2_TIPPRE IN " + cRDA
	     EndIf
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё retorna string com filtro para restricao do operador					   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If FindFunction("PlsRestOp")
   cStrFil := PlsRestOp("A")
   If !Empty(cStrFil)
      cFilBE2 += " AND "+cStrFil
   EndIf
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta matriz															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLS790ATU()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tecla de atalho para chamar perguntas... << F12 >>                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetKey(VK_F11,	{|| AtualizaBr(oOcorr) })
SetKey(VK_F12,	{|| IIf(Pergunte("PLA790",.T.), (dDataDe := mv_par01, dDataAte := mv_par02,PLS790ATU()),Nil) } )
SetKey(VK_F7,	{|| Iif( Len(aProAud) > 0, Eval(bF7) , NIL) } )
SetKey(VK_F5 ,	{|| Iif( Len(aProAud) > 0, If(ValType(oButGuia)=="O",Eval(oButGuia:bAction),.t.) , NIL) } )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fonte																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE FONT oFnt	NAME "ARIAL" SIZE 6,11 BOLD  //Largura x Altura
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dialogo                                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 100, 100, .t., .t., .f. } )//bd6
AAdd( aObjects, { 100, 35, .t., .t., .f. } )//bd7


aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )


DEFINE MSDIALOG oDlg TITLE STR0009 FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel//GetWndDefault()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quadro identificacao                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 001,003 GROUP oIdent TO 050,aSize[ 3 ] PIXEL OF oDlg LABEL STR0010 //" Identificacao "

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria obj																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oOcorr := TcBrowse():New(060, 6, (aSize[ 3 ]*0.73), aSize[4]-80,,,, oDlg,,,,,,,,,,,,.F.,,.T.,,.F., )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se tiver registros														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 28, 50  Say oSay86 PROMPT Iif( Len(aProAud)<=0,STR0015,"")				SIZE  080, 7 of oDlg PIXEL COLOR CLR_HBLUE		 //"Nao ha registro para auditar."

@ 08, 06  Say oSay87 PROMPT Iif( Len(aProAud)>0,OemToAnsi(STR0011),"")						 			 SIZE  300, 7 of oDlg PIXEL //"Usuario "
@ 08, 50  Say oSay99 PROMPT Iif( Len(aProAud)>0,TransForm(PlsPtuGet( "MATRICULA",aProAud[oOcorr:nAt] ),"@R !!!!.!!!!.!!!!!!.!!-!"),"") SIZE  060, 7 of oDlg PIXEL COLOR CLR_HBLUE
@ 08, 110 Say oSay98 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "NOMUSR",aProAud[oOcorr:nAt] ),"") 	Picture "@!" SIZE  300, 7 of oDlg PIXEL COLOR CLR_HBLUE
@ 18, 06  Say oSay90 PROMPT Iif( Len(aProAud)>0,OemToAnsi(STR0012),"")						SIZE  300, 7 of oDlg PIXEL //"Solicitante "
@ 18, 50  Say oSay97 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "REGSOL",aProAud[oOcorr:nAt] ),"") 	 	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE
@ 18, 110 Say oSay96 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "NOMREGSOL",aProAud[oOcorr:nAt] ),"") 	SIZE  300, 7 oF oDlg PIXEL COLOR CLR_HBLUE

@ 28, 06  Say oSay89 PROMPT Iif( Len(aProAud)>0,OemToAnsi(STR0013),"") 						SIZE  300, 7 of oDlg PIXEL //"Executante "
@ 28, 50  Say oSay95 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "REGEXE",aProAud[oOcorr:nAt] ),"")	 	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE
@ 28, 110 Say oSay94 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "NOMREGEXE",aProAud[oOcorr:nAt] ),"") 	SIZE  300, 7 oF oDlg PIXEL COLOR CLR_HBLUE

@ 38, 06  Say oSay88 PROMPT Iif( Len(aProAud)>0,OemToAnsi(STR0014),"") 					SIZE  300, 7 of oDlg PIXEL //"Procedimento "
@ 38, 50  Say oSay93 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),"")	 	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE
@ 38, 110 Say oSay92 PROMPT Iif( Len(aProAud)>0,PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),"")    	SIZE  300, 7 of oDlg PIXEL COLOR CLR_HBLUE

If ExistBlock("P790BTOG")
	ExecBlock("P790BTOG",.F.,.F.,{'1',@oDlg})
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grupo																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

@ 050, 3 GROUP oOc  TO aSize[4]-10, (aSize[3]*0.75) PIXEL OF oDlg LABEL STR0016 //" Guias "

aObjects := {}
AAdd( aObjects, { 80, 100, .t., .f. } )
AAdd( aObjects, { 20, 100, .t., .t., .t. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё BitMap																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Add COLUMN TO oOcorr BITMAP DATA {|| Iif( Len(aProAud)>0, Iif( aProAud[oOcorr:nAt,PL790POS("PENDEN",aProAud),2 ] <> "1",;
															    Iif( !empty(aProAud[oOcorr:nAt,PL790POS("OPESOL",aProAud),2]) .and. aProAud[oOcorr:nAt,PL790POS("OPESOL",aProAud),2] == plsintpad(),;
															         LoadBitmap( GetResources(), "BR_AZUL" ),;
																     LoadBitmap( GetResources(), "BR_VERDE" ) ),;
															    	 LoadBitmap( GetResources(), "BR_AMARELO" ) ),;
															     )  } TITLE "" WIDTH 016 NOHILITE
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Colunas																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oOcorr:AddColumn(TcColumn():New("Bco.Conhec." 		,NIL,NIL,NIL,NIL,NIL,010,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Descr. Local"
oOcorr:ACOLUMNS[2]:BDATA := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("BCOCONH",aProAud),2],) }
oOcorr:AddColumn(TcColumn():New(STR0017			,NIL,NIL,NIL,NIL,NIL,015,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Ano"
oOcorr:ACOLUMNS[3]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("ANOAUTINT",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0018			,NIL,NIL,NIL,NIL,NIL,015,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Mes"
oOcorr:ACOLUMNS[4]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("MESAUTINT",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0019	,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Num.Autoriz."
oOcorr:ACOLUMNS[5]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("NUMAUT",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0133	,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Num.Internac."
oOcorr:ACOLUMNS[6]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("NUMINT",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0134	,NIL,NIL,NIL,NIL,NIL,035,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Prorrogacao"
oOcorr:ACOLUMNS[7]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("PRORRO",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0020  	,NIL,NIL,NIL,NIL,NIL,030,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Data Proc."
oOcorr:ACOLUMNS[8]:BDATA  := { || If(Len(aProAud)>0,StoD(aProAud[oOcorr:nAt,PL790POS("DATPRO",aProAud),2]),) }

oOcorr:AddColumn(TcColumn():New(STR0021			,NIL,NIL,NIL,NIL,NIL,015,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Qtd"
oOcorr:ACOLUMNS[9]:BDATA  := { || If(Len(aProAud)>0,TransForm(aProAud[oOcorr:nAt,PL790POS("QTDPRO",aProAud),2],"@E 9999.99"),) }

oOcorr:AddColumn(TcColumn():New(STR0022	,NIL,NIL,NIL,NIL,NIL,135,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Nome Usuario"
oOcorr:ACOLUMNS[10]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("NOMUSR",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0023		,NIL,NIL,NIL,NIL,NIL,150,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Nome RDA"
oOcorr:ACOLUMNS[11]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("NOMRDA",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0024	,NIL,NIL,NIL,NIL,NIL,065,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Mat. Antiga"
oOcorr:ACOLUMNS[12]:BDATA  := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("MATANT",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0135			,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"CID"
oOcorr:ACOLUMNS[13]:BDATA := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("CID",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0136			,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Cod. Local"
oOcorr:ACOLUMNS[14]:BDATA := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("CODLOC",aProAud),2],) }

oOcorr:AddColumn(TcColumn():New(STR0137			,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Descr. Local"
oOcorr:ACOLUMNS[15]:BDATA := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("DESLOC",aProAud),2],) }

If BE2->( FieldPos("BE2_NRTROL") ) > 0 .And. BQV->( FieldPos("BQV_NRTROL") ) > 0 .And. BE2->( FieldPos("BE2_NRTROL") ) > 0 .And. GetNewPar("MV_PLEVSAD","0") == "1"
    oOcorr:AddColumn(TcColumn():New("Nr. Tran Online"		,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Nr. Tran Online"
    oOcorr:ACOLUMNS[16]:BDATA := { || If(Len(aProAud)>0,aProAud[oOcorr:nAt,PL790POS("NRTROL",aProAud),2],) }
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Set Array																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oOcorr:SetArray(aProAud)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Duplo click																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oOcorr:BLDBLCLICK 	:= {|| PLSVLDCLI(lEnvTds) }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Change																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oOcorr:bChange		:= {|| 	oSay99:Refresh(), oSay98:Refresh(), oSay97:Refresh(),;
							oSay96:Refresh(), oSay95:Refresh(), oSay94:Refresh(),;
							oSay93:Refresh(), oSay92:Refresh(),;
							oSay90:Refresh(), oSay89:Refresh(), oSay87:Refresh(),;
							oSay86:Refresh(), oSay88:Refresh(),;
							if(ExistBlock("P790BTOG"),ExecBlock("P790BTOG",.F.,.F.,{'2',@oDlg}),nil),;
							Iif( Len(aProAud)>0,{|| cAliProAud := PlsPtuGet( "NOMALIAS",aProAud[oOcorr:nAt] ),cRecProAud := PlsPtuGet( "VALRECNO",aProAud[oOcorr:nAt] ) },NIL) }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё botoes                                                           		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para desabilitar BOTOES PARA um grupo de operadores	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLSBUTOP")
   aPTBot := ExecBlock("PLSBUTOP",.F.,.F.,{"PLSA790"})
Endif
nli := 60
aSize[3]+=20
If aPTBot[1]
	@ nli,(aSize[3]*0.77) BUTTON "&"+STR0139    		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790CON("2",PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Contrato"
Endif
If aPTBot[2]
	@ nli,(aSize[3]*0.85) BUTTON "&"+STR0140    			ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790CON("1",PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Familia"
Endif

nLi	+= 10
If aPTBot[3]
	@ nli,(aSize[3]*0.77) BUTTON "&"+"RDA" 	       		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790RDA('1',PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif
If aPTBot[4]
	@ nli,(aSize[3]*0.85) BUTTON "&"+STR0094    		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790RDA('2',PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Solicitante"
Endif

nLi += 10
If aPTBot[5]
	@ nli,(aSize[3]*0.77) BUTTON STR0030  		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790RDA('3',PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"E&xecutante"
Endif
If aPTBot[6]
	@ nli,(aSize[3]*0.85) BUTTON "&"+STR0039   	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790PRO( PlsPtuGet( "NIVCRI",aProAud[oOcorr:nAt] ),; //"Nivel da Critica"
																							PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "CHVNIV",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif


nLi	+= 10
If aPTBot[7]
	@ nli,(aSize[3]*0.77) BUTTON "&"+STR0142  		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790TAB()  ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Tabela Padrao"
Endif
If aPTBot[8]
	@ nli,(aSize[3]*0.85) BUTTON "&"+STR0143 		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790COB( PlsPtuGet( "MATRICULA",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Vlr. Cobranca"
Endif

nLi	+= 10
If aPTBot[9]
	@ nli,(aSize[3]*0.77) BUTTON "&"+STR0144 		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLHISMOV( PlsPtuGet( "MATRICULA",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Movimentacao"
Endif
If aPTBot[10]
	@ nli,(aSize[3]*0.85) BUTTON STR0035      	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLPOSFIN( PlsPtuGet( "OPEMATEMP",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"&Financeiro"
Endif

nLi += 10
If aPTBot[11]
	@ nli,(aSize[3]*0.77) BUTTON STR0036      		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790CRI( PlsPtuGet( "OPEMATEMP",aProAud[oOcorr:nAt] ),PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Cr&iticas "
Endif
If aPTBot[12]
	@ nli,(aSize[3]*0.85) BUTTON "&"+STR0145      	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLSMSGCA( PlsPtuGet( "MATRICULA",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Grupo Caren"
Endif

nLi += 10
If aPTBot[13]
	@ nli,(aSize[3]*0.77) BUTTON STR0038      	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLSVSCLACAR( PlsPtuGet( "MATRICULA",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"C&lasse Caren"
Endif
If aPTBot[14]
	@ nli,(aSize[3]*0.85) BUTTON STR0141      	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790CBT( PlsPtuGet( "MATRIC",aProAud[oOcorr:nAt] ),; //"C&oberturas"
																							PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "DATPRO",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "HORPRO",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "QTDPRO",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																							PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL

Endif
nLi	+= 10
If aPTBot[15]
	@ nli,(aSize[3]*0.77) BUTTON STR0040 		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLMOVGEN( '1',STR0203,dDataDe,dDataAte,,PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),; //"Movto Proced"  //'Movimentos do procedimento'
																																			   PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																																			   PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																																			   PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif
If aPTBot[16]
	@ nli,(aSize[3]*0.85) BUTTON STR0041			ACTION Eval( {|| Iif( Len(aProAud) > 0, PLMOVGEN( '3',STR0204,dDataDe,dDataAte,,PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),; //"Movto Prest" //'Movimentos do prestador'
																																			PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																																			PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																																			PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif

nLi	+= 10
If aPTBot[17]
	@ nli,(aSize[3]*0.77) BUTTON STR0042 			ACTION Eval( {|| Iif( Len(aProAud) > 0, PLMOVGEN( '2',STR0205,dDataDe,dDataAte,,PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),; //"Movto CID  " //'Movimentos do CID'
																																	  PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																																	  PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																																	  PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) )  ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif
If aPTBot[18]
	@ nli,(aSize[3]*0.85) BUTTON STR0043			ACTION Eval( {|| Iif( Len(aProAud) > 0, PLMOVGEN( '4',STR0206,dDataDe,dDataAte,,PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),; //"Movto Solic"  //'Movimentos do solicitante'
																															  			      PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																															  			      PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																															  				  PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif

nLi	+= 10
If aPTBot[19]
	@ nli,(aSize[3]*0.77) BUTTON STR0044			ACTION Eval( {|| Iif( Len(aProAud) > 0, PLMOVGEN( '5',STR0207,dDataDe,dDataAte,,PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),; //"Movto Exec " //'Movimentos do executante'
																													 						 PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																													 						 PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																													 						 PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif
If aPTBot[20]
	@ nli,(aSize[3]*0.85) BUTTON STR0045      	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLMOVGEN( '6',STR0208,dDataDe,dDataAte,,PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),; //"Custo/Receita"//'Custo/Receita'
																										  						  PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																										  						  PlsPtuGet( "DESPRO",aProAud[oOcorr:nAt] ),;
																										  						  PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL
Endif

nLi	+= 10
If aPTBot[21]
	@ nli,(aSize[3]*0.77) BUTTON STR0046      		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790LOC() ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Localizar"
Endif
If aPTBot[22]
	@ nli,(aSize[3]*0.85) BUTTON oButGuia Prompt STR0047	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLSA790GUIA( PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ), PlsPtuGet( "TIPO",aProAud[oOcorr:nAt] ) ) ,NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Guia"
Endif

nLi	+= 10
If aPTBot[23]
	@ nli,(aSize[3]*0.77) BUTTON STR0146      		ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790MAUD( PlsPtuGet( "OPEMOV",aProAud[oOcorr:nAt] ),;  //"Movto Aud."
																							 PlsPtuGet( "ANOAUTINT",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "MESAUTINT",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "NUMAUT",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "CODEMP",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "MATRIC",aProAud[oOcorr:nAt] ),;
																							 PlsPtuGet( "TIPREG",aProAud[oOcorr:nAt] ) ) ,Nil ),lPrim } ) SIZE 45, 11 OF oDlg PIXEL
Endif
If aPTBot[24]
	@ nli,(aSize[3]*0.85) BUTTON "Legenda"      		ACTION Eval( {|| PLS790Leg(1) } ) SIZE 45, 11 OF oDlg PIXEL
Endif

nLi	+= 10
If PLSALIASEX("BOZ")

	If aPTBot[25]
		@ nli,(aSize[3]*0.77) BUTTON "Hist. GIH "      		ACTION Eval( {|| If(!EMPTY(aProAud), PLSGIH(PlsPtuGet( "FILIAL",aProAud[oOcorr:nAt] )+;
																										  		  PlsPtuGet( "OPEUSR",aProAud[oOcorr:nAt] )+;
																										  		  PlsPtuGet( "ANOAUTINT",aProAud[oOcorr:nAt])+;
																										  		  PlsPtuGet( "MESAUTINT",aProAud[oOcorr:nAt] )+;
																										  		  PlsPtuGet( "NUMAUT",aProAud[oOcorr:nAt] )),"") } ) SIZE 45, 11 OF oDlg PIXEL
	Endif
EndIf

If aPTBot[26]
	@ nli,(aSize[3]*0.85) BUTTON oButCoPtu Prompt STR0245	ACTION Eval( {|| Iif( Len(aProAud) > 0, PLSVLDCLI(.T.),NIL ) } ) SIZE 45, 11 OF oDlg PIXEL //"Comunica Tds"
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Botoes extras para uso em campo.                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLi	+= 10
If ExistBlock("PL790BT1")
	if ExistBlock("PL790NOMEBT")
		aBt1:=ExecBlock("PL790NOMEBT")
		cNomeBT1:=aBT1[1]
	Else
		cNomeBT1:="Botao 1"
	Endif
	oBtt1 := TButton():New( nli, (aSize[3]*0.77), cNomeBT1, oDlg,{|| Iif( Len(aProAud) > 0, ExecBlock("PL790BT1",.F.,.F.,{oBtt1, 2} ) ,NIL ) }, 45, 11,,,,.T.)
	ExecBlock("PL790BT1",.F.,.F.,{oBtt1, 1})
Endif

If ExistBlock("PL790BT2")
	if ExistBlock("PL790NOMEBT") .AND. Len(aBt1:=ExecBlock("PL790NOMEBT"))>1
		cNomeBT2:=aBT1[2]
	Else
		cNomeBT2:="Botao 2"
	Endif

	oBtt2 := TButton():New( nli, (aSize[3]*0.85), cNomeBT2, oDlg,{|| Iif( Len(aProAud) > 0, ExecBlock("PL790BT2",.F.,.F.,{oBtt2, 2} ) ,NIL ) }, 45, 11,,,,.T.)
	ExecBlock("PL790BT2",.F.,.F.,{oBtt2, 1})
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Mensagem sobre F12                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oDlg:cCaption := oDlg:cCaption+" ["+"F5: "+STR0147+"] ["+"F7: "+STR0148+"] ["+"F11: "+STR0212+"] ["+"F12: "+STR0149+"] "

//@ 190, 5 	Say oSay91 PROMPT "F5: "+STR0147	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE	 //"Consulta Guia"
//@ 190, 70  	Say oSay91 PROMPT "F7: "+STR0148	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE	 //"Conhecimento"
//@ 190, 135 	Say oSay91 PROMPT "F11: "+STR0212	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE	 //"Atualizar"
//@ 190, 185	Say oSay91 PROMPT "F12: "+STR0149	SIZE  050, 7 of oDlg PIXEL COLOR CLR_HBLUE	 //"ParБmetros"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Botao																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLi	+= 15
@ nLi,(aSize[3]*0.85) BUTTON STR0150 ACTION oDlg:End() SIZE 45, 11 OF oDlg PIXEL //"Sair"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dialog e Ativa o timer de refresh do browse!							   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg  CENTER
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desliga key																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET KEY VK_F12 TO
SET KEY VK_F11 TO
SET KEY VK_F7  TO
SET KEY VK_F5  TO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁPLSA790GUIA Ё Autor Ё Alex                Ё Data Ё 12.05.05 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Exibe a guia completa                                      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA790GUIA(cChave,cTipoGuia) 
LOCAL BkpMvPar01 := MV_PAR01
LOCAL BkpMvPar02 := MV_PAR02
LOCAL cTipAnexo  := "" 

DEFAULT cTipoGuia := "" 
DEFAULT cChave    := "" 

cTipoGuia := ALLTRIM(cTipoGuia)

If !Empty(cChave) .AND. !EMPTY(cTipoGuia)
	
	If cTipoGuia $ "1,2,4" // liberaГЦo/execuГЦo SADT, OdontolСgico

	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
		
	If BEA->( MsSeek(xFilial("BEA")+cChave) )
	   If 	GetNewPar("MV_PLATIOD","0") == "1" .And. BEA->( FieldPos("BEA_TIPATO") ) > 0 .And. BEA->BEA_TIPO = '4'
		   		
		    PLS090OMov("BEA",BEA->( Recno() ),K_Visualizar)
	   ElseIf BEA->BEA_TIPO $ "1,2"
			  
	       PLSA090Mov("BEA",BEA->( Recno() ),K_Visualizar,,,BEA->BEA_ORIGEM)
	   ElseIf BEA->BEA_TIPO == "4"
			  
		   PLS090OMov("BEA",BEA->( Recno() ),K_Visualizar,,,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),BEA->BEA_ORIGEM)
	   Else
		   	   MsgStop(STR0050 + xFilial("BEA")+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
		   Endif
		Else
			MsgStop(STR0050 + xFilial("BEA")+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
		EndIf
	
	ElseIf cTipoGuia == "3" //InternaГЦo
	
		BE4->(DbSetOrder(2)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	     
		If BE4->(MsSeek(xFilial("BE4") + cChave))
			cCadastro := STR0248 //"SolicitaГЦo de InternacЦo"
			
			PLSA092Mov("BE4",BE4->(Recno()),K_Visualizar)
		Else
			MsgStop(STR0151+" ["+xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]")        //"Nao foi possivel localizar a guia de internacao com chave"
		Endif

	ElseIf cTipoGuia == "6" //Anexos ClМnicos
		
		B4A->(DbSetOrder(1))
		
		If B4A->( MsSeek(xFilial("B4A") + cChave) )
		   		                                         
		   		If B4A->B4A_TIPANE == "2" 	//2=Quimioterapia 
	   			cTipAnexo := "07"
		   			
		   		ElseIf B4A->B4A_TIPANE == "1"//1=Radioterapia
	   			cTipAnexo := "08"
		   			
		   		Else //3=OPME  
		   		cTipAnexo := "09"	
		   		EndIf
		   		
	   		PLS09AMov("B4A",B4A->(Recno()),K_Visualizar,.T.,cTipAnexo,B4A->B4A_TIPANE) 
		   	
		Else
			MsgStop(STR0050 + xFilial("B4A")+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
		EndIf
			
	ElseIf cTipoGuia == "11" //Guia de ProrrogaГЦo de internaГЦo
		
		cCadastro:= STR0249 //"ProrrogaГЦo de internaГЦo"  
				B4Q->(DbSetOrder(1))
	
				If B4Q->( MsSeek(xFilial("B4Q")+cChave) )		   		                                         
			
					PLS09PMov("B4Q",B4Q->(Recno()),K_Visualizar)
		Else
			MsgStop(STR0050 + xFilial("B4Q")+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
			    EndIf
			    
	ElseIf cTipoGuia == "5" //Guia de reembolso
		
		B44->(DbSetOrder(1))
	
		If B44->( MsSeek(xFilial("B44") + cChave) )
		   
		   cCadastro:= STR0214  //"AutorizaГЦo de reembolso"
		   PL001MOV("B44",B44->(Recno()),K_Visualizar)
		   
		Else
			MsgStop(STR0050 + xFilial("B44")+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
		EndIf
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tecla de atalho para chamar perguntas... << F12 >>                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetKey(VK_F11,	{|| AtualizaBr(oOcorr) })
SetKey(VK_F12,Iif( Len(aProAud) > 0, {|| Pergunte("PLA790",.T.), dDataDe := mv_par01, dDataAte := mv_par02,PLS790ATU() } , NIL) )
SetKey(VK_F7, {|| Iif( Len(aProAud) > 0, Eval(bF7) , NIL) } )
SetKey(VK_F5 ,{|| Iif( Len(aProAud) > 0, If(ValType(oButGuia)=="O",Eval(oButGuia:bAction),.t.) , NIL) } )


// Restaura estado original das variaveis.
MV_PAR01 := bkpMvPar01
MV_PAR02 := bkpMvPar02

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё A790Vip  Ё Autor Ё Angelo Sperandio      Ё Data Ё 23.08.02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Verifica se eh cliente VIP                                 Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function A790Vip()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se eh cliente VIP                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  ! empty(cNumCer)
    cCertif := BA1->BA1_NUMCER
    nPosBA1 := BA1->(RecNo())
    BA1->(dbSetOrder(8))
    BA1->(MsSeek(xFilial("BA1")+BJP->BJP_APOLIC+space(8)+cCertif))
    If  BA1->BA1_USRVIP == "1"
        MsgAlert(alltrim(getmv("MV_PLMSGRE")))
    Endif
    BA1->(dbGoTo(nPosBA1))
Endif

Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790CON ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  07-12-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Chama o contrato apartir do botao "contrato"               ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё                                                            ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790CON(cTipo,cChaveCab)

LOCAL cAliasCab
PRIVATE lJuridico := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no cabecalho													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
If BEA->( MsSeek( xFilial("BEA")+cChaveCab ) )
   If BEA->BEA_TIPO == "3"
       BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
       If !BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
          MsgAlert(STR0153+" ["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]")        //"Nao foi possivel localizar a guia de internacao com a chave"
		  Return
       Endif
       cAliasCab := 'BE4'
   Else
       cAliasCab := 'BEA'
   Endif
Else
   If PLSALIASEXI("B44")
   		B44->(DbSetOrder(1))
   		If B44->( MsSeek( xFilial("B44")+cChaveCab ) )
   			cAliasCab := 'B44'
   		Else
   			If PLSALIASEXI("B4A")
   				B4A->(DbSetOrder(1))
				If B4A->( MsSeek( xFilial("B4A")+cChaveCab ) )
   					cAliasCab := 'B4A'
	   			Else
		   			MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
			   		Return
	   			Endif
	   		Else
		   		MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
		   		Return
   			Endif
   		Endif
   Else
   		MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
   		Return
   Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Familia																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->( DbSetorder(1) )//BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
BA3->( MsSeek( xFilial("BA3")+&(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC)" ) ) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica o Tipo															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cTipo == "2" .And. BA3->BA3_TIPOUS == "2"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Empresa																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BG9->( DbSetorder(01) )//BG9_FILIAL + BG9_CODINT + BG9_CODIGO + BG9_TIPO
	BG9->( MsSeek( xFilial("BG9")+&(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP)") ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Contrato																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BT5->( DbSetorder(01) )//BT5_FILIAL + BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
	BT5->( MsSeek( xFilial("BT5")+&(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_CONEMP+"+cAliasCab+"_VERCON)") ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SubContrato																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BQC->( DbSetorder(01) )//BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
	BQC->( MsSeek( xFilial("BQC")+&(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_CONEMP+"+cAliasCab+"_VERCON+"+cAliasCab+"_SUBCON+"+cAliasCab+"_VERSUB)") ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Mostra																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLS660VAR("BQC",BQC->(Recno()),2)
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Usuariio																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    BA1->( DbClearFilter() )
	BA1->( DbSetorder(02) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	BA1->( MsSeek( xFilial("BA1")+&(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC+"+cAliasCab+"_TIPREG)")	) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Mostra																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLSA260MOV("BA1",BA1->( Recno() ),2)
Endif
SetKey(VK_F11,	{|| AtualizaBr(oOcorr) })
SetKey(VK_F12,Iif( Len(aProAud) > 0, {|| Pergunte("PLA790",.T.), dDataDe := mv_par01, dDataAte := mv_par02 } , NIL) )
SetKey(VK_F7, {|| Iif( Len(aProAud) > 0, Eval(bF7) , NIL) } )
SetKey(VK_F5 ,{|| Iif( Len(aProAud) > 0, If(ValType(oButGuia)=="O",Eval(oButGuia:bAction),.t.) , NIL) } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790RDA ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  14-07-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Chama a rotina de cadastro de RDA.                         ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790RDA(cTipoRDA,cChaveCab)

LOCAL cChave
LOCAL cAliasCab
LOCAL lAnexos := .t.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no cabecalho													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
If BEA->( MsSeek( xFilial("BEA")+cChaveCab ) )
   If BEA->BEA_TIPO == "3"
       BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
       If !BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
          MsgAlert(STR0153+" ["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]")        //"Nao foi possivel localizar a guia de internacao com a chave"
		  Return
       Endif
       cAliasCab := 'BE4'
   Else
       cAliasCab := 'BEA'
   Endif
Else
   If PLSALIASEXI("B44")
   		B44->( DbSetOrder(1) )
        If B44->( MsSeek( xFilial("B44")+cChaveCab ) )
           cAliasCab := 'B44'
        Else
	    	If PLSALIASEXI("B4A")
			   	B4A->( DbSetOrder(1) )
		        If B4A->( MsSeek( xFilial("B4A")+cChaveCab ) )
		           	MsgAlert('OpГЦo nЦo disponМvel para Anexos Clinicos.')
			   	    Return
	        	Else
		        	MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
			   	    Return
	        	Endif
	        Else
		       MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
		   	   Return
        	Endif
        Endif
   Else
	   MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
   	   Return
   Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Chave																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cChave := Iif(cTipoRDA=='2',&(cAliasCab+"->"+cAliasCab+"_CDPFSO"),&(cAliasCab+"->"+cAliasCab+"_CDPFRE") )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo RDA																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cTipoRDA == '1'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё RDA																		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BAU->( DbSetorder(01) ) //BAU_FILIAL + BAU_CODIGO
	If BAU->( MsSeek(xFilial("BAU")+&(cAliasCab+"->"+cAliasCab+"_CODRDA")) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Visualizar																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		PLSA360MNT("BAU",BAU->( Recno() ),2)
	Else
		MsgAlert(STR0051) //"A RDA informada no evente nao foi encontrada!"
	Endif
Else
	If Empty(cChave)
		MsgStop(STR0052+Iif(cTipoRDA=='2',STR0094,STR0096)+STR0055) //"Este evento nao possui "###"Solicitante"###"Executante"###" informado!"
		Return
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Profissional de Saude													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BB0->( DbSetorder(01) ) //BB0_FILIAL + BB0_CODIGO
	If BB0->( MsSeek(xFilial("BB0")+cChave) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Visualizar																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		PLSA960MOV("BB0",BB0->( Recno() ),K_Visualizar)
	Else
		MsgAlert(Iif(cTipoRDA=='2',STR0056,STR0057)+STR0058) //"O solicitante"###"O executante"###" informado no evente nao foi encontrada!"
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(NIL)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790PRO ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  14-07-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Chama o procedimento da tabela padrao...                   ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790PRO(cNivCri,cChaveCab,cChvNiv,cCodPad,cCodPro)
LOCAL cProduto
LOCAL cVerPro
LOCAL cCodRda
LOCAL cCodTab
LOCAL cCodGru
LOCAL cMsg
LOCAL cChaveBD6
LOCAL I__f 	   := 0
LOCAL cAlias   := cNivCri
LOCAL cChaveP  := ""
LOCAL cChave   := ""
LOCAL cFilX2   := SX2->(DbFilter())
LOCAL cAliasCab:= ""
PRIVATE cCadastro
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao tiver nivel sai fora												   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cAlias)
   cMsg := STR0155+" -> ("+cAlias+") "         //"Nao e possivel exibir o NIVEL DA CRITICA"
   MsgAlert(cMsg)
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no cabecalho													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If BEA->( MsSeek( xFilial("BEA")+cChaveCab ) )
	   cChaveBD6 := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)
	   If BEA->BEA_TIPO == "3"
	       BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	       If !BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
	          MsgAlert(STR0153+" ["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]")        //"Nao foi possivel localizar a guia de internacao com a chave"
			  Return
	       Endif
	       cAliasCab := 'BE4'
		   cChaveBD6 := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
	   Else
	       cAliasCab := 'BEA'
	   Endif
	Else
		If PLSALIASEXI("B44")
			B44->( DbSetOrder(1) )
			If B44->( MsSeek( xFilial("B44")+cChaveCab ) )
				cAliasCab := 'B44'
				cChaveBD6 := B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI+B44_ORIMOV)
			Else
				MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
	   			Return
			Endif
	    Else
	   		If PLSALIASEXI("B4A")
				B4A->(DbSetOrder(1))
				If B4A->( MsSeek( xFilial("B4A")+cChaveCab ) )
				 	cAliasCab := 'B4A'
				 	cChaveBD6 := str(len(BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
				Else
				 	MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
				   	Return
				Endif
			Else
				MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
				Return
			Endif
	    Endif
	Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na tabela BA1 (Usuario)										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->( DbSetorder(2) )	 //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
If BA1->( MsSeek( xFilial("BA1")+ &( cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC+"+cAliasCab+"_TIPREG)" ) ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega a chave do Produto													   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty( BA1->(BA1_CODPLA+BA1_VERSAO) )
	    cChaveP :=  BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona na tabela BA3 (Familia)										   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA3->( dbSetorder(1) )	 //BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
	    If BA3->( MsSeek( xFilial("BA3")+ &( cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC)" ) ) )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Pega a chave do Produto													   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty( BA3->(BA3_CODPLA+BA3_VERSAO) )
			   cChaveP :=  BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
			EndIf
		Else
		   MsgAlert(STR0156) //'Nao foi encontrado a Familia!'
		   Return
		EndIf
	EndIf
Else
   MsgAlert(STR0157) //'Nao foi encontrado o Usuario!'
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chavep																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cChaveP)
   MsgAlert(STR0158) //'Nao foi encontrado produto nesta FAMILIA/USUARIO'
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na tabela BI3 (Produtos)										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BI3->( DbSetOrder(1) )	//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
If !BI3->( MsSeek(xFilial("BI3")+cChaveP ) )
   MsgAlert(STR0159) //'Produto nao encontrado'
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Leva para a memory para o inicializador padrao dos niveis				   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Copy "BI3" TO MEMORY
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se e a critica e no nivel do produto								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cAlias == 'BI3'
	If BI3->BI3_TODOS == "0"  //0=NAO - 1=SIM
	   cAlias := "BR8"
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega produto e versao 													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(BA1->BA1_CODPLA)
   cProduto := BA3->BA3_CODPLA
   cVerPro  := BA3->BA3_VERSAO
Else
   cProduto := BA1->BA1_CODPLA
   cVerPro  := BA1->BA1_VERSAO
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o codigo do grupo													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodGru := SubString(AllTrim(cChvNiv),Len(AllTrim(cChvNiv))-2,3)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o cod. tab	do BD6											   		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BD6->( MsSeek( xFilial("BD6")+cChaveBD6) )
cCodTab := BD6->BD6_CODTAB
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o nome da tabela													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("SX2")
SX2->(DbClearFilter())
cCadastro := allTrim(Posicione("SX2",1,cAlias,"SX2->X2_NOME"))
Set Filter To &cFilX2
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chave																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC)")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica a tabela que tem os procedimentos								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Do Case
   Case cAlias == "BFG"
	    //BFG_FILIAL + BFG_CODINT + BFG_CODEMP + BFG_MATRIC + BFG_TIPREG + BFG_CODPAD + BFG_CODPSA + BFG_NIVEL
	    cChave += &(cAliasCab+"->"+cAliasCab+"_TIPREG")+cCodPad+cCodPro
   Case cAlias == "BFE"
        //BFE_FILIAL + BFE_CODINT + BFE_CODEMP + BFE_MATRIC + BFE_TIPREG + BFE_CODGRU
	    cChave += &(cAliasCab+"->"+cAliasCab+"_TIPREG")+cCodGru
   Case cAlias == "BV3"
        //BV3_FILIAL + BV3_CODINT + BV3_CODEMP + BV3_MATRIC + BV3_TIPREG + BV3_CODPRO + BV3_CODPSA + BV3_NIVEL
	    cChave += &(cAliasCab+"->"+cAliasCab+"_TIPREG")+cProduto+cCodPro
   Case cAlias == "BV0"
   		//BV0_FILIAL + BV0_CODINT + BV0_CODEMP + BV0_MATRIC + BV0_TIPREG + BV0_CODPRO + BV0_CODGRU
	    cChave += &(cAliasCab+"->"+cAliasCab+"_TIPREG")+cProduto+cCodPro
   Case cAlias == "BFD"
   		//BFD_FILIAL + BFD_CODINT + BFD_CODEMP + BFD_MATRIC + BFD_CODPAD + BFD_CODPSA + BFD_NIVEL
	    cChave += cCodPad+cCodPro
   Case cAlias == "BFC"
   		//BFC_FILIAL + BFC_CODINT + BFC_CODEMP + BFC_MATRIC + BFC_CODGRU
	    cChave += cCodGru
   Case cAlias == "BZQ"
   		//BZQ_FILIAL + BZQ_CODINT + BZQ_CODEMP + BZQ_MATRIC + BZQ_CODPRO + BZQ_CODPSA + BZQ_NIVEL
	    cChave += cProduto+cCodPro
   Case cAlias == "BZN"
   		//BZN_FILIAL + BZN_CODINT + BZN_CODEMP + BZN_MATRIC + BZN_CODPRO + BZN_CODGRU
	    cChave += cProduto+cCodGru
   Case cAlias == "BT8"
   		//BT8_FILIAL + BT8_CODINT + BT8_CODIGO + BT8_NUMCON + BT8_VERCON + BT8_SUBCON + BT8_VERSUB + BT8_CODPRO + BT8_CODPAD + BT8_CODPSA + BT8_NIVEL
	    cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_CONEMP+"+cAliasCab+"_VERCON+"+cAliasCab+"_SUBCON+"+cAliasCab+"_VERSUB)")+cProduto+cCodPad+cCodPro
   Case cAlias == "BT7"
   		//BT7_FILIAL + BT7_CODINT + BT7_CODIGO + BT7_NUMCON + BT7_VERCON + BT7_SUBCON + BT7_VERSUB + BT7_CODPRO
	    cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_CONEMP+"+cAliasCab+"_VERCON+"+cAliasCab+"_SUBCON+"+cAliasCab+"_VERSUB)")+cProduto
   Case cAlias == "BQC"
   		//BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
	    cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_CONEMP+"+cAliasCab+"_VERCON+"+cAliasCab+"_SUBCON+"+cAliasCab+"_VERSUB)")
   Case cAlias == "BB2"
   		//BB2_FILIAL + BB2_CODIGO + BB2_VERSAO + BB2_CODPAD + BB2_CODPSA + BB2_NIVEL
	    cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP)")+cVerPro+cCodPad+cCodPro
   Case cAlias == "BRV"
     	//BRV_FILIAL + BRV_CODPLA + BRV_VERSAO + BRV_CODGRU
	    cChave := &(cAliasCab+"->"+cAliasCab+"_OPEUSR")+cProduto+cVerPro+cCodGru
   Case cAlias == "BI3"
   		//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
	    cChave := &(cAliasCab+"->"+cAliasCab+"_OPEUSR")+cProduto+cVerPro
   Case cAlias == "BYK"
   		//BYK_FILIAL + BYK_CODIGO + BYK_VERSAO
	    cChave := cProduto+cVerPro
   Case cAlias == "BG8"
   		//BG8_FILIAL + BG8_CODINT + BG8_CODGRU + BG8_CODPAD+ BG8_CODPSA + BG8_NIVEL
	    cChave := &(cAliasCab+"->"+cAliasCab+"_OPEUSR")+cCodGru+cCodPad+cCodPro
   Case cAlias == "BC0"
   		//BC0_FILIAL + BC0_CODIGO + BC0_CODINT + BC0_CODLOC + BC0_CODESP + BC0_CODTAB + BC0_CODOPC
	    cChave := &(cAliasCab+"->("+cAliasCab+"_CODRDA+"+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODLOC+"+cAliasCab+"_CODESP)")+cCodTab+cCodPro
   Case cAlias == "BBM"
   		//BBM_FILIAL + BBM_CODINT + BBM_CODESP + BBM_CODPAD + BBM_CODPSA + BBM_NIVEL + BBM_TIPO + BBM_ATIVO + BBM_PERIOD + BBM_UNPER
	    cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODESP)")+cCodPad+cCodPro
   Case cAlias == "B1E"
   		//B1E_FILIAL + B1E_MATVID
	    cChave := &(cAliasCab+"->"+cAliasCab+"_MATRIC")
   Case cAlias == "BAX"
   		//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
	    cChave := &(cAliasCab+"->("+cAliasCab+"_CODRDA+"+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODLOC+"+cAliasCab+"_CODESP)")+"   "
   Case cAlias == "BBI"
   		//BBI_FILIAL + BBI_CODIGO + BBI_CODINT + BBI_CODLOC + BBI_CODESP + BBI_CODPRO
	    cChave := &(cAliasCab+"->("+cAliasCab+"_CODRDA+"+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODLOC+"+cAliasCab+"_CODESP)")+cProduto
   Case cAlias == "BBN"
   		//BBN_FILIAL + BBN_CODIGO + BBN_CODINT + BBN_CODLOC + BBN_CODESP + BBN_CODPAD + BBN_CODPSA + BBN_NIVEL
	    cChave := &(cAliasCab+"->("+cAliasCab+"_CODRDA+"+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODLOC+"+cAliasCab+"_CODESP)")+cCodPad+cCodPro
   Case cAlias == "BAQ"
   		//BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
	    cChave := &(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODESP)")
   Case cAlias == "BR8"
   		//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
	    cChave := cCodPad+cCodPro
   Case cAlias == "BYO"
   		//BYO_FILIAL + BYO_CODIGO
	    cChave := cChvNiv
   Case cAlias $ "INT,BA0,BYK,BVQ,BVN"
	    cMsg := STR0155+" -> ("+cAlias+") "         //"Nao e possivel exibir o NIVEL DA CRITICA"
		MsgAlert(cMsg)
EndCase
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona e Exibe														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cMsg)
	&(cAlias)->( DbSetOrder(01) )
	If &(cAlias)->( MsSeek(xFilial(cAlias)+cChave) )
		AXVISUAL(cAlias,&(cAlias)->( Recno() ),2)
	Else
	    cMsg := STR0155+" -> ("+cAlias+") "         //"Nao e possivel exibir o NIVEL DA CRITICA"
		MsgAlert(cMsg)
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(NIL)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790COB ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  07-14-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Chama funcao generica com o valor de cobranca da familia...╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790COB(cChave)

BA1->( DbSetorder(02) )//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
BA1->( MsSeek( xFilial("BA1")+cChave ) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vlr cob																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSVLRCOB(,,.T.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetKey(VK_F11,	{|| AtualizaBr(oOcorr) })
SetKey(VK_F12,Iif( Len(aProAud) > 0, {|| Pergunte("PLA790",.T.), dDataDe := mv_par01, dDataAte := mv_par02 } , NIL) )
SetKey(VK_F7, {|| Iif( Len(aProAud) > 0, Eval(bF7) , NIL) } )
SetKey(VK_F5 ,{|| Iif( Len(aProAud) > 0, If(ValType(oButGuia)=="O",Eval(oButGuia:bAction),.t.) , NIL) } )

Return(NIL)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790FIN  ╨Autor  ЁMicrosiga           ╨ Data Ё  07-15-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790FIN(cMatric)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Parametros: cMatric - Matricula do Usuario                          Ё
//Ё             lDlg    - .T. Exibir Sempre Dialogo com Historico       Ё
//Ё                       .F. Somente retorna .T. ou .F.                Ё
//Ё             lDebDlg - Exibir dialogo caso esteja em debito          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL oBotao01
LOCAL oBotao02

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oTreeUsr
PRIVATE oTreeCon
PRIVATE oDlgFin
PRIVATE aCabFin := PLSCPOSSE1("A")
PRIVATE aDadFin
PRIVATE oBrwFin
PRIVATE cTitulo := STR0065  //"Posicao Financeira"
PRIVATE lOK     := .T.
PRIVATE nOrdSE1 := GETMV("MV_PLORDE1")
PRIVATE nDiasDB := GETMV("MV_PLDIADB")
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE aVetTrab:= {}

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retina o digito verificador da matricula.                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cMatric := Subs(cMatric,1,14)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa funcao para validacao de usuario generica...                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! PLVLDUSU(cMatric)
   Return(.F.)
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta os arrays da GetDados do financeiro...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSMNTDAD(cMatric)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Classifica em ordem de data de vencimento...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPosDat := PLRETPOS("E1_VENCREA",aCabFin)
If nPosDat > 0 .And. ! Empty(aDadFin)
   aDadFin := aSort(aDadFin,,, { |x, y| x[nPosDat] > y[nPosDat] })
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Remonta titulo...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTitulo += IF(lOK,"",STR0066) //" - Em Debito"

//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Dados do Titular e Depedentes...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
PLDADUSR(cMatric,oDlgFin,oTreeUsr,oTreeCon)

//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Browse Financeiro...                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
If ValType(aDadFin) == "A"
   If Len(aDadFin) > 0
      TGroup():New(080,003,176,355,STR0160,, , ,.T.)  //"Parcela(s) em Aberto"
      oBrwFin := TPLSBESP():New(090,008,340,080,nil,oFolCob:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFin,aDadFin,.T.,"SE1",K_Visualizar,STR0067,{{"E1_SALDO","<=",0}}) //"Movimentacao Financeira"
   Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Botao de OK padrao...                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
oBotao01 := SButton():New(180, 150, 3, {|| PLSVLRCOB(oBrwFin:FieldGet("E1_ANOBASE"),oBrwFin:FieldGet("E1_MESBASE"),.T.) },oFolder:aDialogs[3],.T.)
oBotao01:cToolTip := STR0068 //"Composicao de Cobranca"

oBotao02 := SButton():New(180, 180, 4, {|| IF(ExistBlock("PLSBOLETO"),ExecBlock("PLSBOLETO",.F.,.F.),Help("",1,"PLSBOLETO")) },oFolder:aDialogs[3],.T.)
oBotao02:cToolTip := STR0069 //"Imprimir segunda via de boleto"

//зддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lOK)


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSMNTDAD ╨Autor  ЁGeraldo Felix Jr.   ╨ Data Ё  07-15-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Funcao auxilar para montar o array do financeiro           ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSMNTDAD(cMatric)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Reseta os arrays...                                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aDadFin := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica a qtde Dias Inadimplencia ou Num Titulos Abertos...             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nDiasDB:= PLSDIAIN("",cMatric)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se o cliente tem alguma parcela em aberto...               Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SE1->(DbSetOrder(nOrdSE1))
If SE1->(MsSeek(xFilial("SE1")+cMatric))
   While ! SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) == xFilial("SE1")+cMatric
         //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Depois do venciment e saldo com valor...                            Ё
         //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         nDiasVenc := dDataBase-SE1->E1_VENCREA

         If nDiasVenc >= nDiasDB .And. SE1->E1_SALDO > 0
            lOK := .F.
            Exit
         Endif
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acessa proximo registro...                                          Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   SE1->(DbSkip())
   Enddo
Else
   lOK := .T.
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aCols e aHeader dos Dados Financeiros...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If SE1->(MsSeek(xFilial("SE1")+cMatric))
   Store COLS "SE1" TO aDadFin FROM aCabFin While SE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) == xFilial("SE1")+cMatric
Endif

If Valtype(oBrwFin) == "O"
	oBrwFin:aCols := aClone(aDadFin)
	oBrwFin:Atualiza()
Endif

Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790DBCLICK ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  21-07-03   ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Parecer da auditoria medica...         	                      ╨╠╠
╠╠╨          Ё                                            	                  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                             ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790DBCLICK(cChave,lEnvTds)
LOCAL I__f 		:= 0
LOCAL aDados 	:= {}
LOCAL lReembolso:= .F.
LOCAL   nI          := 0
LOCAL   nJ          := 0
LOCAL   nH          := 0               
LOCAL cNumRec       :=""  
LOCAL nQtdAr        := 0
LOCAL ABVXGRV       := {}   
LOCAL cNomeAli      := ""
DEFAULT lEnvTds     := .F.
PRIVATE oDlgPar
PRIVATE oEncpar
PRIVATE cPrefixo
PRIVATE cNumTit
PRIVATE cTipTit
PRIVATE dvencto
PRIVATE nOpc
PRIVATE aRetSta
PRIVATE cStatus
PRIVATE nOpca 			:= 2
PRIVATE aCampos 		:= {}
PRIVATE lGerarTit 		:= .F.
PRIVATE lAnexos 		:= .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for internacao liga o campo qtd de dias de interncao...         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
BEA->( MsSeek( xFilial("BEA")+cChave ) )
If PLSALIASEXI("B44")
	B44->( DbSetOrder(1) )
	If B44->( MsSeek( xFilial("B44")+cChave ) )
		lReembolso:= .T.
		B45->(DbSetOrder(1))
		B45->(MsSeek(xFilial("B45")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))
	Endif
Endif
If !lReembolso
	BE2->(DbSetOrder(1))
	If !BE2->(MsSeek(xFilial("BE2")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))//SADT
		BEJ->(DbSetOrder(1))
		If !BEJ->(MsSeek(xFilial("BEJ")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))//internacao
			If PLSALIASEXI("B4A")
				B4A->(DbSetOrder(1))
				If B4A->(MsSeek(xFilial("B4C")+cChave))
					lAnexos := .T.
					B4C->(DbSetOrder(1))
					B4C->(MsSeek(xFilial("B4C")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))
				Endif
			Endif
		Endif
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for internacao..												   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lReembolso .and. BEA->BEA_TIPGUI == "03" .and. !lAnexos
	BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa as variaveis M->?? da vida...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Copy "BVX" To Memory Blank
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё aCampos															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BVX->( FieldPos("BVX_NOMAUD") ) > 0
	Aadd(aCampos, "BVX_NOMAUD")
Endif
Aadd(aCampos, "BVX_DATPAR")
Aadd(aCampos, "BVX_PARECE")
Aadd(aCampos, "BVX_MOTIVO")
Aadd(aCampos, "BVX_DESMOT")
If BVX->(FieldPos("BVX_MSG")) > 0
	Aadd(aCampos, "BVX_MSG")
Else
	Aadd(aCampos, "BVX_MSG01")
	Aadd(aCampos, "BVX_MSG02")
	Aadd(aCampos, "BVX_MSG03")
	Aadd(aCampos, "BVX_MSG04")
	Aadd(aCampos, "BVX_MSG05")
EndIf
If BVX->( FieldPos("BVX_SOLREV") ) > 0
	Aadd(aCampos, "BVX_SOLREV")
EndIf
If BVX->(FieldPos("BVX_QTDPRO")) > 0 .And. !lEnvTds
   Aadd(aCampos, "BVX_QTDPRO")
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se e guia de internacao											   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAnexos
	If !lReembolso .and. BEA->BEA_TIPGUI == "03"
		If BE4->( FieldPos("BE4_MSG04") ) > 0 .And. BVX->( FieldPos("BVX_SOLREV") ) > 0  .And. !Empty(BE4->BE4_MSG04)
		   M->BVX_SOLREV := BE4->BE4_MSG04
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Resposta da revisao												   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BE4->( FieldPos("BE4_MSG05") ) > 0 .And. !Empty(BE4->BE4_MSG05)
		    If BVX->(FieldPos("BVX_MSG")) > 0
		    	M->BVX_MSG  := AllTrim(BE4->BE4_MSG05)
	   		Else
			    M->BVX_MSG01  := SubStr(AllTrim(BE4->BE4_MSG05),1,64)
			    M->BVX_MSG02  := SubStr(AllTrim(BE4->BE4_MSG05),65,64)
		   	EndIf
		EndIf
	Elseif !lReembolso
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pega a msg de Revisao											   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BEA->( FieldPos("BEA_MSG04") ) > 0 .And. BVX->( FieldPos("BVX_SOLREV") ) > 0 .And. !Empty(BEA->BEA_MSG04)
		   M->BVX_SOLREV := BEA->BEA_MSG04
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Resposta da revisao												   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If  BEA->( FieldPos("BEA_MSG05") ) > 0 .And. !Empty(BEA->BEA_MSG05)
			If BVX->(FieldPos("BVX_MSG")) > 0
				M->BVX_MSG  := AllTrim(BEA->BEA_MSG05)
			Else
				M->BVX_MSG01  := SubStr(AllTrim(BEA->BEA_MSG05),1,64)
				M->BVX_MSG02  := SubStr(AllTrim(BEA->BEA_MSG05),65,64)
			EndIf
		EndIf
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quantidade														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BVX->( FieldPos("BVX_QTDPRO") ) > 0
   M->BVX_QTDPRO := aProAud[oOcorr:nAt,PL790POS("QTDPRO",aProAud),2]
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё sIZE															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSize    := MsAdvSize()
aSize[3] *= 0.50
aSize[4] *= 0.70
aSize[5] *= 0.50
aSize[6] *= 0.70
aObjects := {}

AAdd( aObjects, { aSize[3], aSize[4]-20, .T., .F.,.F. } )
AAdd( aObjects, { aSize[3], 40, .T., .T.,.F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dialog															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgPar TITLE STR0070 FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() pixel                       //"Parecer"

	If ExistBlock("PLS790CP")
	   aCampos := ExecBlock("PLS790CP",.F.,.F.,{aCampos})
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta Enchoice...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oEncPar := MsMGet():New("BVX" ,0 ,K_Incluir,,,,aCampos,{aPosObj[1][1],aPosObj[1][2],aPosObj[1][3]-30,aPosObj[1][4]},aCampos,,,,,oDlgPar,,,.T.,)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё BotЦo HistСrico     																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ /*nLinha*/aPosObj[2,1]-30,aPosObj[2,2]/*nColuna*/ BUTTON STR0240 SIZE /*nLargura*/80,10/*nAltura*/ Pixel OF oDlgPar ACTION Eval( {|| Iif( Len(aProAud) > 0, PLS790MAUD( PlsPtuGet( "OPEMOV",aProAud[oOcorr:nAt] ),;  //"HistСrico."
		PlsPtuGet( "ANOAUTINT",aProAud[oOcorr:nAt] ),PlsPtuGet( "MESAUTINT",aProAud[oOcorr:nAt] ),PlsPtuGet( "NUMAUT",aProAud[oOcorr:nAt] ),PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] ),PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] ),;
		PlsPtuGet( "CODEMP",aProAud[oOcorr:nAt] ),PlsPtuGet( "MATRIC",aProAud[oOcorr:nAt] ),PlsPtuGet( "TIPREG",aProAud[oOcorr:nAt] ) ,.T. ),Nil ) } )

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ReadOnly																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BVX->( FieldPos("BVX_SOLREV") ) > 0 .And. !Empty(M->BVX_SOLREV)
		oEncPar:AENTRYCTRLS[ Ascan( oEncPar:AENTRYCTRLS, {|o| o:CSX1HLP == "BVX_SOLREV" } ) ]:LREADONLY := .T.
	EndIf
	If BVX->( FieldPos("BVX_MSG") ) > 0 .And. !Empty(M->BVX_MSG01)
		oEncPar:AENTRYCTRLS[ Ascan( oEncPar:AENTRYCTRLS, {|o| o:CSX1HLP == "BVX_MSG" } ) ]:LREADONLY := .T.
	ElseIf BVX->(FieldPos("BVX_MSG")) = 0
		If BVX->( FieldPos("BVX_MSG01") ) > 0 .And. !Empty(M->BVX_MSG01)
			oEncPar:AENTRYCTRLS[ Ascan( oEncPar:AENTRYCTRLS, {|o| o:CSX1HLP == "BVX_MSG01" } ) ]:LREADONLY := .T.
		EndIf
		If BVX->( FieldPos("BVX_MSG02") ) > 0 .And. !Empty(M->BVX_MSG02)
			oEncPar:AENTRYCTRLS[ Ascan( oEncPar:AENTRYCTRLS, {|o| o:CSX1HLP == "BVX_MSG02" } ) ]:LREADONLY := .T.
		EndIf
	EndIf

ACTIVATE MSDIALOG oDlgPar Center ON INIT EnChoiceBar(oDlgPar,{|| Iif(M->BVX_PARECER=="3" .And. !Empty( PlsPtuGet( "RESREV",aProAud[oOcorr:nAt] ) ),;
																	Alert(STR0161),; //"A resposta da revisao ja foi fornecida, aguarde a conclusao ou outra solicitacao de revisao!"
																 	Iif(Obrigatorio(oEncPar:aGets,oEncPar:aTela).And. PlVerLock(aProAud[oOcorr:nAt]) .And. PlAudPtuOn(lEnvTds,M->BVX_PARECER),(nOpca:=1 ,oDlgPar:End()),nOpc:=2) ) },{||nOpca:=2,oDlgPar:End()},.F.,{})																 	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca ==  1     
	   If lEnvTds
	
		cNrtrol := PlsPtuGet("NRTROL",aProAud[oOcorr:nAt] )   
		cCdOpeS := PlsPtuGet("OPESOL",aProAud[oOcorr:nAt] )   

	    //nPos := (aProAud[ni,aScan(aProAud[ni],{|x| x[1] == "OPESOL"}),2] == cCdOpeS)
		If !Empty(cNrtrol) .And. !Empty(cCdOpeS)
            nQtdAr := 1
			
			For ni:=1 to Len(aProAud)
				For nj:= 1 to Len(aProAud[ni])
				
					If aProAud[ni,nj,1]="NRTROL" .And. !Empty(aProAud[ni,nj,2])
						
						cAchNrT:= aProAud[ni,nj,2]
						If cAchNrT == cNrtrol  
		
					    	nPos:= aScan(aProAud[ni],{|x| x[1] == "OPESOL"})
		 					If nPos > 0 .And. aProAud[ni,nPos,2] == cCdOpeS         //pode haver numero de transacao igual para operadora solicitante diferente. aqui verifico.
								Aadd(aBVXGrv,aProAud[ni],nQtdAr)
								
								cNumRec := PlsPtuGet("VALRECNO",aBVXGrv[nQtdAr] ) 
								cNomeAli:= PlsPtuGet("NOMALIAS",aBVXGrv[nQtdAr] ) 
								
								If !Empty(cNomeAli) .And. !Empty(cNumRec)
 
   									&(cNomeAli+"->(DbGoTo("+alltrim(str(cNumRec))+"))")

									PLSA790Pro("1" , PlsPtuGet( "CHKAUTINT",aBVXGrv[nQtdAr] ),PlsPtuGet( "NOMALCIC",aBVXGrv[nQtdAr] ),lReembolso,(M->BVX_PARECE = "3"),lAnexos,lEnvTds,aBVXGrv[nQtdAr])
								EndIf	
								nQtdAr ++
							EndIf	
						EndIf	
					Endif
				Next nj	
			Next ni
		EndIf  
   Else 
   		PLSA790Pro("1" , PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ),PlsPtuGet( "NOMALCIC",aProAud[oOcorr:nAt] ),lReembolso,(M->BVX_PARECE = "3"),lAnexos )
   	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ponto de entrada apos a gravacao das tabelas                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If  ExistBlock("PL790FIM")
        ExecBlock("PL790FIM",.F.,.F.)
    Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLS790ATU()
ElseIf nOpca ==  2
	AtualizaBr(oOcorr)
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790VIS ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  22-07-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁVisualizacao do movimento de auditoria                      ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790VIS()
Local I__f := 0
LOCAL oDlgVis
LOCAL aButtons 	:= {}
LOCAL aCampos	:= {}
LOCAL nOpca := 2
LOCAL aCabUsr
Local nCnt
PRIVATE oEncBA1
PRIVATE oEncBVX
PRIVATE aProAud	:= {}

BA1->( dbSetorder(02) )
BA1->( MsSeek(xFilial("BA1")+BVX->BVX_OPEMOV+BVX->BVX_CODEMP+BVX->BVX_MATRIC+BVX->BVX_TIPREG) )

Store Header "BA1" TO aCabUsr For (SX3->X3_CAMPO # "BA1_IMAGE")
For nCnt := 1 To Len(aCabUsr)
	Aadd(aCampos, aCabUsr[nCnt,2])
Next

Copy "BA1" To Memory

BEA->( dbSetorder(01) )
BEA->( MsSeek(xFilial("BEA")+BVX->BVX_OPEMOV+BVX->BVX_ANOAUT+BVX->BVX_MESAUT+BVX->BVX_NUMAUT) )

Copy "BVX" To Memory

Aadd( aButtons,{ STR0163 , {|| PLSA790GUIA( BVX->(BVX_OPEMOV+BVX_ANOAUT+BVX_MESAUT+BVX_NUMAUT) ) },STR0071,STR0047} ) //"PEDIDO"###"Visualizar a guia"###"Guia"

if Val(GetVersao(.F.)) >= 12 //Valida versЦo 12
	DEFINE MSDIALOG oDlgVis TITLE STR0072 FROM 003, 005 TO 33, 110.3 OF GetWndDefault()  //"Auditoria - Visualizar pra versЦo 12"
	@ 030,003 FOLDER oFolder SIZE 380,173 OF oDlgVis    PIXEL	PROMPTS	"&"+STR0164,"&"+STR0165 //"Usuario(s)"###"Movimento Auditoria"

	oEncBA1 := MsMGet():New("BA1" ,BA1->(Recno()),2,,,,aCampos,{005,003,153,360},aCampos,,,,,oFolder:aDialogs[1],,,.F.,)
	oEncBVX := MsMGet():New("BVX" ,BVX->(Recno()),2,,,,,{005,003,153,360},,,,,,oFolder:aDialogs[2],,,.F.,)
Else
	DEFINE MSDIALOG oDlgVis TITLE STR0072 FROM 08.2, 10.3 TO 33, 110.3 OF GetWndDefault()  //"Auditoria - Visualizar"
	@ 015,003 FOLDER oFolder SIZE 380,173 OF oDlgVis    PIXEL	PROMPTS	"&"+STR0164,"&"+STR0165 //"Usuario(s)"###"Movimento Auditoria"

	oEncBA1 := MsMGet():New("BA1" ,BA1->(Recno()),2,,,,aCampos,{005,003,153,360},aCampos,,,,,oFolder:aDialogs[1],,,.F.,)
	oEncBVX := MsMGet():New("BVX" ,BVX->(Recno()),2,,,,,{005,003,153,360},,,,,,oFolder:aDialogs[2],,,.F.,)
Endif

ACTIVATE MSDIALOG oDlgVis ON INIT EnchoiceBar(oDlgVis,{||nOpca:=1,oDlgVis:End()},{||nOpca:=2,oDlgVis:End()},.F.,aButtons)

If nOpca == 1 .And. BVX->BVX_PARECE == "3" .And. BVX->BVX_LNOVO
	If MsgYesNo(STR0166) //"Marcar como ja lido?"
		BVX->( RecLock("BVX",.F.) )
			BVX->BVX_LNOVO := .F.
		BVX->( msUnlock() )
	Endif
Endif
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790CBT ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09-01-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Coberturas do usuarios...                                  ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790CBT(cMatric,cCodPad,cCodPro,cChave,dDatPro,cHorPro,nQtdPro,cDesPro,cSequen)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao das variaveis...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cMvPLSMODA:= ''
LOCAL cGrpInt   := ''
LOCAL cRDAEDI	:= ''
LOCAL cOpeUsr 	:= ''
LOCAL cMatrUsr 	:= ''
LOCAL cHor		:= ''
LOCAL aHisCri	:= {}
LOCAL cAliCab := "BEA"
LOCAL cAliPro := "BE2"
LOCAL lAnexos := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vetor com dados genericos...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE aDadUsr  := {}
PRIVATE aDadRDA  := {}
PRIVATE __aNiveis:= PLSESPNIV(cCodPad)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca dados do parametro...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If GetNewPar("MV_PLSMODA","1") == "0"
   cMvPLSMODA := "0"
Else
   cMvPLSMODA := "1"
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se existe o procedimento...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BR8_DESCRI, R_E_C_N_O_ AS REGBR8 FROM "+RetSQLName("BR8")+" WHERE "
cSQL += "BR8_FILIAL = '"+xFilial("BR8")+"' AND "
cSQL += "BR8_CODPAD = '"+cCodPad+"' AND "
cSQL += "BR8_CODPSA = '"+cCodPro+"' AND "
cSQL += "D_E_L_E_T_ = '' AND BR8_ANASIN = '1'"
PLSQuery(cSQL,"PLSA090AUT")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё EOF																		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSA090AUT->(Eof())
	PLSA090AUT->(DbCloseArea())
   	Return(.F.)
Else
   	BR8->(DbGoTo(PLSA090AUT->REGBR8))
   	cDesPro := PLSA090AUT->BR8_DESCRI
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё CLOSEAREA																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSA090AUT->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o cabecalho da movimentacao...                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If PLSALIASEXI("B44")
	B44->( DbSetorder(01) )
	If B44->( MsSeek( xFilial("B44")+cChave ) )
		cAliCab := "B44"
		cAliPro := "B45"
	Else
		If PLSALIASEXI("B4A")
			B4A->( DbSetorder(01) )
			If B4A->( MsSeek( xFilial("B4A")+cChave ) )
				cAliCab := "B4A"
				cAliPro := "B4C"
				lAnexos := .T.
			Else
				BEA->( DbSetorder(01) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
				If !BEA->( MsSeek( xFilial("BEA")+cChave ) )
				   Alert(STR0216+cChave+")") //"Chave nao encontrada no BEA - ("
				   Return(.F.)
				EndIf
			Endif
		Else
			BEA->( DbSetorder(01) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
			If !BEA->( MsSeek( xFilial("BEA")+cChave ) )
			   Alert(STR0216+cChave+")") //"Chave nao encontrada no BEA - ("
			   Return(.F.)
			EndIf
		Endif
	Endif
Else
	If PLSALIASEXI("B4A")
		B4A->( DbSetorder(01) )
		If B4A->( MsSeek( xFilial("B4A")+cChave ) )
			cAliCab := "B4A"
			cAliPro := "B4C"
			lAnexos := .T.
		Else
			BEA->( DbSetorder(01) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
			If !BEA->( MsSeek( xFilial("BEA")+cChave ) )
			   Alert(STR0216+cChave+")") //"Chave nao encontrada no BEA - ("
			   Return(.F.)
			EndIf
		Endif
    Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados do usuario/pretador...                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cMat := &(cAliCab+"->("+cAliCab+"_OPEUSR+"+cAliCab+"_CODEMP+"+cAliCab+"_MATRIC+"+cAliCab+"_TIPREG+"+cAliCab+"_DIGITO)")
dDat := &(cAliCab+"->("+cAliCab+"_DATPRO)")
If !lAnexos
	cHor := &(cAliCab+"->("+cAliCab+"_HORPRO)")
Endif
PLSA090USR(cMat,dDat,cHor,cAliCab,.F.)

If !lAnexos
	PLSA090RDA(&(cAliCab+"->("+cAliCab+"_OPERDA)"),;
			   &(cAliCab+"->("+cAliCab+"_CODRDA)"),;
			   "1",;
			   &(cAliCab+"->("+cAliCab+"_DATPRO)"),;
			   &(cAliCab+"->("+cAliCab+"_OPEUSR+"+cAliCab+"_CODEMP+"+cAliCab+"_MATRIC+"+cAliCab+"_TIPREG)"),;
			   &(cAliCab+"->("+cAliCab+"_CODLOC+"+cAliCab+"_LOCAL)"),;
			   &(cAliCab+"->("+cAliCab+"_CODESP)"),;
			   cAliCab,;
			   .F.)
Endif
aDadUsr := PLSDADUSR(&(cAliCab+"->("+cAliCab+"_OPEUSR+"+cAliCab+"_CODEMP+"+cAliCab+"_MATRIC+"+cAliCab+"_TIPREG+"+cAliCab+"_DIGITO)"),;
					 "1",;
					 .T.,;
					 &(cAliCab+"->("+cAliCab+"_DATPRO)"))
If !aDadUsr[1]
	Return(.F.)
Endif

If !lAnexos
	aDadRda := PLSDADRDA(&(cAliCab+"->("+cAliCab+"_OPERDA)"),;
						 &(cAliCab+"->("+cAliCab+"_CODRDA)"),;
						 '1',;
						 &(cAliCab+"->("+cAliCab+"_DATPRO)"),;
						 &(cAliCab+"->("+cAliCab+"_CODLOC)"),;
						 &(cAliCab+"->("+cAliCab+"_CODESP)"),;
						 cCodPad,;
						 cCodPro)
	If !aDadRda[1]
		Return(.F.)
	Endif
Endif

If cRecProAud > 0
	&(cAliPro+"->(DbGoTo("+alltrim(str(cRecProAud))+"))")
Endif

If !lAnexos
	If &(cAliCab+"->("+cAliCab+"_TIPGUI)") == "03"
		BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
		cGrpInt := BE4->BE4_GRPINT+BE4->BE4_TIPINT
	Endif
Endif

If &( cAliCab+"->( FieldPos('"+cAliCab+"_RDAEDI"+"') )" ) > 0
	cRDAEDI := &(cAliCab+"->("+cAliCab+"_RDAEDI)")
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao gernerica de autorizacao de procedimentos...                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If FindFunction("PlLimpCCri")
     PlLimpCCri()
Endif
cOpeUsr 		:= Iif(Len(aDadUsr)>=37,aDadUsr[37],"")
cMatrUsr 		:= Iif(Len(aDadUsr)>=38,aDadUsr[38],"")
aRet := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCodPad,cCodPro,aDadUsr,;
                   SToD(dDatPro),cHorPro,cRecProAud,aDadRDA,If(!lAnexos,.T.,.F.),If(!lAnexos,&(cAliCab+"->("+cAliCab+"_CID)"),&(cAliCab+"->("+cAliCab+"_CIDPRI)")),nQtdPro,,If(!lAnexos,&(cAliCab+"->("+cAliCab+"_OPESOL)"),''),;
                   If(!lAnexos,&(cAliCab+"->("+cAliCab+"_CDPFSO)"),''),If(!lAnexos,&(cAliCab+"->("+cAliCab+"_NRAOPE)"),''),If(!lAnexos,&(cAliCab+"->("+cAliCab+"_NRAEMP)"),''),aDadUsr[11],aDadUsr[12],.T.,NIL,NIL,;
                   cSequen,NIL,NIL,NIL,cGrpInt,NIL,cRdaEDI,NIL,NIL,NIL)

lRet := aRet[1]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caso nao seja autorizada analiso o campo que trata se e permitido forcar Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

If !lRet
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta aHisCri...                                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aHisCri 	:= aClone(aRet[2])
	PLSMOVCRI("1",{cCodPad,cCodPro,cDesPro,cSequen},aHisCri,.F.)
Else
	aadd(aHisCri,{"XXX",STR0076,"","","",&(cAliPro+"->("+cAliPro+"_CODPAD)"),&(cAliPro+"->("+cAliPro+"_CODPRO)")}) //"Procedimento com cobertura contratual."
	PLSMOVCRI("1",{&(cAliPro+"->("+cAliPro+"_CODPAD)"),&(cAliPro+"->("+cAliPro+"_CODPRO)"),&(cAliPro+"->("+cAliPro+"_DESPRO)"),&(cAliPro+"->("+cAliPro+"_SEQUEN)")},aHisCri,.F.)
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790CRI ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09-01-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Exibe as criticas que o procedimento recebeu durante a     ╨╠╠
╠╠╨          Ёautorizacao.                                                ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790CRI(cMatric,cChave)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis genericas...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL oDlg
LOCAL cTipoGuia
LOCAL bOK       := {|| oDlg:End() }
LOCAL bCancel	:= {|| oDlg:End() }
LOCAL oSize

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados das criticas relacionadas aos eventos...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE oBrwCri
PRIVATE aDadCri  := {}
PRIVATE aCabCri  := {}
PRIVATE aTrbCri  := {}

oSize := FwDefSize():New( .T. )
oSize:AddObject( "ENCHOICE", 196, 440, .F., .F. ) 
oSize:lLateral     := .T.
oSize:aMargins 	:= { 3, 3, 3, 3 } 
oSize:Process()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ordem																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->( DbSetOrder(1) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
If BEA->( MsSeek(xFilial("BEA")+cChave) )
   If  BEA->BEA_TIPO $ "1,2,4"
       cTipoGuia := "S"
   Else
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Internacao																Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       BE4->( DbSetOrder(1) )//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
       BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
       cTipoGuia := "I"
       cChave 	 := BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Evolucao																	Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT
	   If BQV->( MsSeek( xFilial("BQV")+cChave ) )
	       cTipoGuia := "E"
	   EndIf
   Endif
Else
   If PLSALIASEXI("B4A")
	   B4A->(DbSetOrder(1))
	   If B4A->( MsSeek(xFilial("B4A")+cChave) )
	   		cTipoGuia := "S"
	   Else
	   		If PLSALIASEXI("B44")
			   B44->(DbSetOrder(1))
			   If B44->( MsSeek(xFilial("B44")+cChave) )
			   		cTipoGuia := "R"
			   Else
			   		MsgStop(STR0050+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
			   Endif
		   Else
		   		MsgStop(STR0050+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
		   Endif
	   Endif
   Else
   		If PLSALIASEXI("B44")
		   B44->(DbSetOrder(1))
		   If B44->( MsSeek(xFilial("B44")+cChave) )
		   		cTipoGuia := "R"
		   Else
		   		MsgStop(STR0050+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
		   Endif
	   Else
	   		MsgStop(STR0050+cChave+"]") //"Nao foi possivel localizar a guia de atendimento com chave ["
	   Endif
   Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo Sadt																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cTipoGuia == "S"

   Store Header "BEG" TO aCabCri For .T.

   BEG->(DbSetOrder(1))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
   If ! BEG->(MsSeek(xFilial("BEG")+cChave))
      Store COLS Blank "BEG" TO aDadCri FROM aCabCri
   Else
	  Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri While ;
  	  xFilial("BEG")+cChave == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
   Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo Internacao															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ElseIf cTipoGuia == "I"

   Store Header "BEL" TO aCabCri For .T.

   BEL->(DbSetOrder(1))//BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN
   If ! BEL->(MsSeek(xFilial("BEL")+cChave))
      Store COLS Blank "BEL" TO aDadCri FROM aCabCri
   Else
	  Store COLS "BEL" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("BEG")+cChave == BEL->(BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT)
   Endif
ElseIf cTipoGuia == "E"

   Store Header "BQZ" TO aCabCri For .T.

   BQZ->(DbSetOrder(1))//BQZ_FILIAL + BQZ_CODOPE + BQZ_ANOINT + BQZ_MESINT + BQZ_NUMINT + BQZ_SEQUEN
   If ! BQZ->(MsSeek(xFilial("BQZ")+cChave))
      Store COLS Blank "BQZ" TO aDadCri FROM aCabCri
   Else
	  Store COLS "BQZ" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("BQZ")+cChave == BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT)
   Endif
ElseIf cTipoGuia == "R"
   Store Header "B46" TO aCabCri For .T.

   B46->(DbSetOrder(1))//BQZ_FILIAL + BQZ_CODOPE + BQZ_ANOINT + BQZ_MESINT + BQZ_NUMINT + BQZ_SEQUEN
   If ! B46->(MsSeek(xFilial("B46")+cChave))
      Store COLS Blank "B46" TO aDadCri FROM aCabCri
   Else
	  Store COLS "B46" TO aDadCri FROM aCabCri VETTRAB aTrbCri While xFilial("B46")+cChave == B46->(B46_FILIAL+B46_OPEMOV+B46_ANOAUT+B46_MESAUT+B46_NUMAUT)
   Endif

Endif

If LEN(aDadCri) > 0

	DEFINE MSDIALOG oDlg TITLE STR0077 FROM  oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3] - 200,oSize:aWindSize[4] - 400 of oMainWnd Pixel //"Criticas da autorizacao"

	oBrwCri := TPLSBrw():New(oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),;
	                         oSize:GetDimension("ENCHOICE","COLEND"),nil  ,oDlg,nil,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,;
	                         aCabCri,aDadCri,.F.,Iif(cTipoGuia=="S","BEG",Iif(cTipoGuia=="I","BEL",Iif(cTipoGuia=="R","B46","BQZ")) ),;
	                         K_Visualizar,STR0077,nil,nil,nil,aTrbCri)        //"Criticas da Autorizacao"
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.F.,{},,,,,,.F.) } )
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLMOVGEN()╨Autor  ЁGeraldo Felix Jr.   ╨ Data Ё  17/05/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Retornar movimentacao...                                   ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
Tipo para cFuncao:
1 - Por procedimento
2 -
3 -
4 -
5 -
6 -
*/
Function PLMOVGEN(cFuncao,cTxt,dDataDe,dDataAte,cAlias,cCodPad,cCodPro,cDesPro,cChaveCab)
LOCAL 	cSql 		:= ''
LOCAL 	cTxtPad	:= ''
LOCAL 	cTxtFunc	:= ''
LOCAL 	cConteudo := ''
LOCAL 	cBD6Name  := RetSqlName("BD6")
LOCAL 	nProExec  := 0
LOCAL 	nCustos   := 0
LOCAL 	nEventos  := 0
LOCAL 	nMedia	:= 0
LOCAL 	nLiDep 	:= 0
LOCAL 	nSinTot	:= 0
LOCAL 	nTotUsr	:= 0
LOCAL 	nOrdem	:= 1
LOCAL 	nChave	:= 1
LOCAL 	lAnexos	  := .F.
Local 	cRdmake   := ""
Local 	aCab		:= {}
Local	cRodape	:= ''
Local	cAliasCab
Local	aDados	:= {}
Local   aButtons	:= {}
Local	aTipoCab  := {}
Local 	aDadosBx9	:={}

DEFAULT cFuncao := '1'
DEFAULT cAlias  := ''
DEFAULT cCodPad  := ''
DEFAULT cCodPro  := ''
DEFAULT cDesPro  := ''
DEFAULT cChaveCab  := ''

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no cabecalho													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
If BEA->( MsSeek( xFilial("BEA")+cChaveCab ) )
   If BEA->BEA_TIPO == "3"
       BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
       If !BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
          MsgAlert(STR0153+" ["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]")        //"Nao foi possivel localizar a guia de internacao com a chave"
		  Return
       Endif
       cAliasCab := 'BE4'
   Else
       cAliasCab := 'BEA'
   Endif
ElseIf PLSALIASEXI("B44")
	B44->(DbSetOrder(1))
	If B44->( MsSeek( xFilial("B44")+cChaveCab ) )
		cAliasCab := 'B44'
    Else
	   If PLSALIASEXI("B4A")
		   	B4A->(DbSetOrder(1))
			If B4A->( MsSeek( xFilial("B4A")+cChaveCab ) )
				cAliasCab := 'B4A'
				lAnexos	  := .T.
		   	Else
			   MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
			   Return
		   	Endif
	   Else
		   MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
		   Return
       Endif
    Endif
Else
   MsgAlert(STR0215+cChaveCab+"]")        //"Nao foi possivel localizar a guia com a chave ["
   Return
Endif

If cAliasCab == 'B4A' .AND. cFuncao $ '3,4,5'
   MsgAlert('OpГЦo nЦo disponМvel para Anexos Clinicos.')        //"Nao foi possivel localizar a guia com a chave ["
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While .T.
   If  cFuncao == '6' .And. !Empty(dDataDe)  .And. !Empty(dDataAte) .And. dDataDe <= dDataAte
       Exit
   Endif
   If  cFuncao <> '6' .And. !Empty(dDataAte) .And. dDataDe <= dDataAte
       Exit
   Endif
   MsgAlert(STR0078) //"Periodo informado invalido - verifique"
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Pergunte																	Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  Pergunte("PLA790",.T.)
       dDataDe  := mv_par01
       dDataAte := mv_par02
   Else
       Return()
   Endif
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё If Funcao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cFuncao <> '6'
	aCab	:=   { {STR0079      ,"@d",018},; //"  Data"
				   {STR0080      ,"@C",020},; //"Tabela"
				   {STR0089,"@C",040},; //"Procedimento"
				   {STR0082   ,"@C",100},; //"Descricao"
				   {STR0083	  ,"@N",018},; //"Quant."
				   {STR0084		  ,"@N",050},; //"Valor"
				   {STR0168 	  ,"@C",025},; //"RDA  "
				   {STR0092	  ,"@C",100},; //"Prestador"
				   {STR0169	  ,"@C",030},; //"COD. CID"
				   {STR0135      	  ,"@C",070},; //"CID"
				   {STR0086 ,"@C",030},; //"Cod. Solic."
				   {STR0094 ,"@C",100},; //"Solicitante"
				   {STR0087  ,"@C",030},; //"Cod. Exec."
				   {STR0096  ,"@C",600}} //"Executante"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Select																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSql := "SELECT * FROM "+cBD6Name+" BD6 WHERE BD6_FILIAL = '"+xFilial("BD6")+"' "
	cSql += "	AND (BD6_FASE = '3' OR BD6_FASE = '4') AND BD6_SITUAC = '1' "
	cSql += "	AND BD6.D_E_L_E_T_ <> '*' "
	cSql += "	AND BD6_OPEUSR = '"+&(cAliasCab+"->"+cAliasCab+"_OPEUSR")+"' "
	cSql += "	AND BD6_CODEMP = '"+&(cAliasCab+"->"+cAliasCab+"_CODEMP")+"' "
	cSql += "	AND BD6_MATRIC = '"+&(cAliasCab+"->"+cAliasCab+"_MATRIC")+"' "
	cSql += "	AND BD6_TIPREG = '"+&(cAliasCab+"->"+cAliasCab+"_TIPREG")+"' "
	cSql += "	AND BD6_DATPRO >= '"+dTos(dDataDe)+"' AND BD6_DATPRO <= '"+dTos(dDataAte)+"' "
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Funcao 1																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cFuncao == '1'
		If Empty(cCodPro)
			MsgStop(STR0088) //"Este evento nao possui um codigo de procedimento! Verifique!"
			Return()
		Endif
		cSql 	  += "AND BD6_CODPRO = '"+cCodPro+"' "
		cSql 	  += "AND BD6_CODPAD = '"+cCodpad+"' "
		nOrdem	  := 1
		nChave	  := 1
		cTxtFunc  := 'Procedimento'
		cConteudo := cCodPro+' - '+cDesPro
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Funcao 2																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Elseif cFuncao == '2'
		If !lAnexos
			If Empty( &(cAliasCab+"->"+cAliasCab+"_CID") )
				MsgStop(STR0090) //"Este evento nao possui CID!"
				Return()
			Endif
		Else
			If Empty( &(cAliasCab+"->"+cAliasCab+"_CIDPRI") )
				MsgStop(STR0090) //"Este evento nao possui CID!"
				Return()
			Endif
		Endif
		cSql 	  += "AND BD6_CID = '"+If(!lAnexos,&(cAliasCab+"->"+cAliasCab+"_CID"),&(cAliasCab+"->"+cAliasCab+"_CIDPRI"))+"' "
		nOrdem	  := 1
		nChave	  := 1
		cTxtFunc  := 'CID'
		cConteudo := If(!lAnexos,&(cAliasCab+"->"+cAliasCab+"_CID"),&(cAliasCab+"->"+cAliasCab+"_CIDPRI"))+" - "+Posicione("BA9",1,xFilial("BA9")+If(!lAnexos,&(cAliasCab+"->"+cAliasCab+"_CID"),&(cAliasCab+"->"+cAliasCab+"_CIDPRI")),"BA9_ABREVI" )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Funcao 3																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Elseif cFuncao == '3'
		If Empty( &(cAliasCab+"->"+cAliasCab+"_OPERDA") )
			MsgStop(STR0091) //"Este evento nao possui um prestador!"
			Return()
		Endif
		cSql      += "AND BD6_OPERDA = '"+&(cAliasCab+"->"+cAliasCab+"_OPERDA")+"' "
		cSql 	  += "AND BD6_CODRDA = '"+&(cAliasCab+"->"+cAliasCab+"_CODRDA")+"' "
		nOrdem	  := 1
		nChave	  := 1
		cTxtFunc  := 'Prestador'
		cConteudo := &(cAliasCab+"->"+cAliasCab+"_CODRDA")+" - "+Posicione("BAU",1,xFilial("BAU")+&(cAliasCab+"->"+cAliasCab+"_CODRDA"),"BAU_NOME")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Funcao 4																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Elseif cFuncao == '4'
		If Empty( &(cAliasCab+"->"+cAliasCab+"_CDPFSO") )
			MsgStop(STR0093) //"Este evento nao possui um solicitante!"
			Return()
		Endif
		cSql 	  += "AND BD6_CDPFSO = '"+&(cAliasCab+"->"+cAliasCab+"_CDPFSO")+"' "
		nOrdem	  := 1
		nChave	  := 1
		cTxtFunc  := 'Solicitante'
		cConteudo := &(cAliasCab+"->"+cAliasCab+"_CDPFSO")+" - "+Posicione("BB0",1,xFilial("BB0")+&(cAliasCab+"->"+cAliasCab+"_CDPFSO"),"BB0_NOME")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Funcao 5																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Elseif cFuncao == '5'
		If Empty( &(cAliasCab+"->"+cAliasCab+"_CDPFRE") )
			MsgStop(STR0095) //"Este evento nao possui um executante!"
			Return()
		Endif
		cSql 	  += "AND BD6_CDPFRE = '"+&(cAliasCab+"->"+cAliasCab+"_CDPFRE")+"' "
		nOrdem	  := 1
		nChave	  := 1
		cTxtFunc  := 'Executante'
		cConteudo := &(cAliasCab+"->"+cAliasCab+"_CDPFRE")+" - "+Posicione("BB0",1,xFilial("BB0")+&(cAliasCab+"->"+cAliasCab+"_CDPFRE"),"BB0_NOME")
	Endif
	cSql += "Order by BD6_DATPRO "
	PlsQuery(cSql, "TRB790")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё EOF																	 	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If TRB790->( Eof() )
		MsgStop(STR0097) //"Nao foi encontrado nenhum registro que atenda a esta opcao!"
		TRB790->( dbClosearea() )
		Return()
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё While																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !TRB790->( Eof() )
		nProExec += TRB790->BD6_QTDPRO
		nCustos  += TRB790->BD6_VLRPAG
		nEventos ++

		TRB790->( Aadd(aDados, {dToc(BD6_DATPRO), BD6_CODPAD, BD6_CODPRO, BD6_DESPRO,;
								Transform(BD6_QTDPRO,"@E 9999"),Transform(BD6_VLRPAG,"@E 999,999,999.99"),;
								BD6_CODRDA, Posicione("BAU",1,xFilial("BAU")+BD6_CODRDA,"BAU_NOME"),;
								BD6_CID   , Posicione("BA9",1,xFilial("BA9")+BD6_CID,"BA9_ABREVI" ),;
								BD6_CDPFSO, Posicione("BB0",1,xFilial("BB0")+BD6_CDPFSO,"BB0_NOME"),;
								BD6_CDPFRE, Posicione("BB0",1,xFilial("BB0")+BD6_CDPFRE,"BB0_NOME")} ) )
		TRB790->( DbSkip() )
	Enddo
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha area de trabalho...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TRB790->( dbCloseArea() )
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta array referencia...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aDadosBx9:=PLS790BX9(dDataDe,dDataAte,cAlias,cAliasCab)

	aDados		:=aDadosBx9[1]
	aCab		:=aDadosBx9[2]
	aTipoCab	:=aDadosBx9[3]
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao 6																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cFuncao <> '6'
	nMedia  := (nCustos/nProExec)
	cRodape := STR0170+" : "			+Alltrim(Transform(nEventos, "@E 9999"))+Space(3)	 //"Qtd Eventos"
	cRodape += STR0171+" : "	+Alltrim(Transform(nProExec, "@E 9999"))+Space(5) //"Qtd Procedimentos"
	cRodape += STR0172+" : "			+Alltrim(Transform(nCustos, "@E 999,999,999.99"))+Space(3) //"Custo Total"
	cRodape += STR0173+" : "			+Alltrim(Transform(nMedia, "@E 999,999.99")) //"Custo Medio"
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Botao do grafico..                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd(aButtons, {"GRAF3D",{ || PLSA795(aDados,aCab,cFuncao,{nOrdem,cTxtFunc,nChave,cConteudo} ) },STR0107,STR0174} )	 //"Visualizar Grafico"###"Grafico"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao 6 - Receita/Despesa												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  cFuncao == '6'
    If  ExistBlock("PLMVGENI")
        cRdmake := "PLMVGENI"
    Else
        cRdmake := ""
    Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё CriGen																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSCRIGEN(aDados,aCab,cTxt,nil,cRodape,Iif(cFuncao == '6',2,0),aButtons,{||nil},cRdmake,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.T.,.T.,aTipoCab)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790LOC ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09/23/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁFuncao de pesquisa para o browse de autidoria...            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790LOC()

LOCAL oDlgPesUsr
LOCAL oTipoPes
LOCAL oSayUsr
LOCAL oBrowUsr
LOCAL nReg
LOCAL oGetChave
LOCAL oChkChk
LOCAL cChave     := Space(100)
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"ENABLE","","",0,"","","","","",""} }
LOCAL bRefresh   := { || Iif(!Empty(cChave), PLS790PSQ( cTipoPes,cChave ), oGetChave:SetFocus() ) }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || oDlgPesUsr:End() }
LOCAL bCanc      := { || oDlgPesUsr:End() }
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
LOCAL lBloqueia	 := .F.
LOCAL cCodOpe  	 := PLSINTPAD()
PRIVATE aOpcoes  := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao tiver registro sai												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(aProAud)
   Return
EndIf

aBrowUsr := aClone(aVetPad)

BX8->(DBSetOrder(1))
If BX8->(MsSeek(xFilial("BX8")+'PLS790LOC'))
   While !BX8->(EOF()) .And. xFilial("BX8")+'PLS790LOC' == BX8->(BX8_FILIAL+AllTrim(BX8_RDMAKE))
         AaDd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+BX8->BX8_OPCAO)
         AaDd(aOpcoes,{AllTrim(BX8->BX8_CHAVE)})
         nOrdem ++
   BX8->(DBSkip())
   Enddo
Else
   aTipoPes   := {"1-"+STR0175,"2-"+STR0176,"3-"+STR0177,"4-"+STR0178} //"Nome do Usuario"###"Matricula"###"Matricula Antiga"###"Oper+Ano+Mes+Num. Autoriz."

   AaDd(aOpcoes,{"NOMUSR"} )
   AaDd(aOpcoes,{"MATRICULA"} )
   AaDd(aOpcoes,{"MATANT"} )
   AaDd(aOpcoes,{"NUMAUT"} )
   AaDd(aOpcoes,{""} )
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgPesUsr TITLE STR0179 FROM 08.2, 10.3 TO 017,110.3 OF GetWndDefault() //"Pesquisa"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta objeto que recebera o a chave de pesquisa  ...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oGetChave := TGet():New(040,103,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesUsr,280,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Browse...                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o Dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgPesUsr ON INIT Eval({ || EnChoiceBar(oDlgPesUsr,bOK,bCanc,.F.) }) CENTER
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorno da Funcao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(nOpca==K_OK)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790PSQ ╨Autor  ЁMicrosiga           ╨ Data Ё  09/23/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLS790PSQ( cTipoPes, cValor )

LOCAL nL
LOCAL nPos 	  := Val( Left(cTipoPes,1) )
LOCAL cNomCol := Iif(nPos <= Len(aOpcoes),aOpcoes[nPos,1],"" )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pesquisa																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nL := Ascan( aProAud, {|x| Left(AllTrim( x[ PL790POS(cNomCol,aProAud,'=='),2] ),Len(Alltrim(cValor))) $ AllTrim(cValor) } )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nL > 0
   oOcorr:nAt := nL
   oOcorr:Refresh()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Funcao															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLS790LEG  Ё Autor ЁGeraldo Felix Junior.Ё Data Ё 08.01.02 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Exibe a legenda...                                         Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLS790Leg(nTp)

If Valtype(nTp) <> 'N'
	nTp := 0
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verfica de onde veio													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTp == 0
	BrwLegenda(STR0112,STR0113 ,aCdCores) //"Movtos de Auditoria"###"Status"
Else
	BrwLegenda(STR0009,STR0113 ,aCdCorAu) //"Auditoria"###"Status"
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Funcao															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA790Pro╨Autor  ЁAlexander			 ╨ Data Ё  18/06/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     |Gravacao													  ╨╠╠
╠╠юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA790Pro(cForma,cChaveCab,cAliasCIC,lReembolso,lPendente,lAnexos,lEnvTds,aGrvPdA)
LOCAL cChaveBD6		:= ""
LOCAL lUmAut		:= .F.
LOCAL lIntern		:= .F.
LOCAL lEvolucao		:= .F.
LOCAL cChaveCabI	:= ""
LOCAL cAliasCab		:= SubStr(cAliasCIC,1,3)
LOCAL cAliasIte     := SubStr(cAliasCIC,4,3)
LOCAL cAliasCri     := SubStr(cAliasCIC,7,3)
LOCAL lQTDPRO 		:= BVX->( FieldPos("BVX_QTDPRO") ) > 0
LOCAL lVLRPRO		:= .F.
LOCAL cKeyPtuBD6    := ""
LOCAL lSenhaGrv     := .T.
LOCAL aRetUlt		:= {}
LOCAL lProrrog		:= cAliasCab == "B4Q"
DEFAULT lPendente   := .F.
DEFAULT lAnexos		:= .F.
DEFAULT aGrvPdA     := {}
DEFAULT lEnvTds     := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no cabecalho													   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAnexos .AND. !lProrrog
	BEA->( DbClearFilter() )
	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	If BEA->( MsSeek( xFilial("BEA")+cChaveCab ) )
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Chave no BD6																  Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   cChaveBD6 := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)
	   If BEA->BEA_TIPO == "3"
	       BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	       If !BE4->( MsSeek( xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
	          MsgAlert(STR0153+" ["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+"]")        //"Nao foi possivel localizar a guia de internacao com a chave"
			  Return
	       Endif
		   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Se e uma internacao														  Ё
		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	       lIntern := .T.
		   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Chave no BD6																  Ё
		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	       cChaveBD6  := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
		   cChaveCabI := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
		   
		   //Se e uma evolucao														  
	       If cAliasIte == "BQV"
		      lEvolucao := .T.
		      lIntern   := .F.
		      cChaveCab := cChaveCabI
	       EndIf
	   Else
	       //Se e uma evolucao SADT													 
	       If cAliasIte == "BQV"
		      lEvolucao := .T.
		   EndIf
	   Endif
	Else
	   If PLSALIASEXI("B44")
	        If B44->( MsSeek( xFilial("B44")+cChaveCab ) )
	        	cChaveBD6 := B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI+B44_ORIMOV)
	        Else
	        	MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	   	   		Return
	        Endif
	   Else
		   MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	   	   Return
	   Endif
	Endif
ElseIf lProrrog

	If PLSALIASEXI("B4Q")
		B4Q->(DbSetOrder(1))
		If B4Q->( MsSeek( xFilial("B4Q")+cChaveCab ) )
			BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
			if BE4->(msSeek(xFilial("BE4")+B4Q->B4Q_GUIREF))
	 			cChaveBD6 := str(len(BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
	 		else
	 			MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	   			Return 		
	 		endIf
		Else
	 		MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	   		Return
		Endif
	Else
		MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	 	Return
	Endif
	
Else
	If PLSALIASEXI("B4A")
		B4A->(DbSetOrder(1))
		If B4A->( MsSeek( xFilial("B4A")+cChaveCab ) )
	 		cChaveBD6 := str(len(BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
		Else
	 		MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	   		Return
		Endif
	Else
		MsgAlert(STR0215+cChaveCab+STR0218+cAliasCab+"]")        //"Nao foi possivel localizar a guia com a chave ["###"] na tabela ["
	 	Return
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama a rotina de ptu-online se for o ultimo procedimenta na guia		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAnexos .and. !lProrrog
	If !lReembolso .And. &(cAliasCab+"->( FieldPos('"+cAliasCab+"_NRTROL') )") > 0 .And. &(cAliasCab+"->( FieldPos('"+cAliasCab+"_COMUNI') )") > 0
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё numero da transacao														  Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   If !Empty( &(cAliasCab+"->"+cAliasCab+"_NRTROL") )
		   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   //Ё Se comunicou												   				  Ё
		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   If &(cAliasCab+"->"+cAliasCab+"_COMUNI") == '1' .And. GetNewPar("MV_PLSSOOL","1") == "1" .and. !lPendente
		        aRetUlt := PLSAUDON( cChaveCab,cAliasCab,cAliasIte,cAliasCri,M->BVX_PARECE,IIF(lEnvTds,PlsPtuGet( "CODPRO",aGrvPdA),PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] )),lEvolucao,IIF(lEnvTds,PlsPtuGet( "VALRECNO",aGrvPdA),PlsPtuGet( "VALRECNO",aProAud[oOcorr:nAt])),lEnvTds)
				If !aRetUlt[1]
				   MsgAlert(STR0114) //"Este procedimento so podera ser AUDITADO quando tiver resposta da outra operadora!"
				   Return
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		        //Ё Como e comunicacao Ptu Online, caso a guia nao seja de internacao, vai     Ё
		        //Ё manter a guia bloqueada para nao realizar o pagamento indevido			   Ё
		        //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If &( cAliasCab+"->( FieldPos('"+cAliasCab+"_TIPGUI"+"') )" ) > 0 .and. &(cAliasCab+"->"+cAliasCab+"_TIPGUI") <> "03"
				    cForma := "4"
				EndIf
		        lUmAut  := aRetUlt[2]
		        lSenhaGrv := .F.
		   EndIf
	   EndIf
	Elseif !lReembolso
	   Alert(STR0181+" ->( "+cAliasCab+"_COMUNI,"+cAliasCab+"_NRTROL )")  	 //"Verificar campos de comunicacao On-line"
	Endif
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё posiciona no item														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
&( cAliasIte+"->( MsSeek('"+ xFilial(cAliasIte)+cChaveCab+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )+"' ) )" )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se o item em auditoria veio de uma liberacao e ainda tem saldo	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If M->BVX_PARECE == "0" .Or. M->BVX_PARECE == "1"

	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_SALDO') )" ) > 0

		If (!Empty( Iif( &( cAliasIte+"->( FieldPos('"+cAliasIte+"_NRLBOR') )" ) > 0 ,&( cAliasIte+"->"+cAliasIte+"_NRLBOR" ),"") )) .or. lAnexos

		    If !lAnexos
				cGuiRef := &( cAliasIte+"->"+cAliasIte+"_NRLBOR" )
			Else                                                                              `
				//nos anexos o saldo esta na liberacao.. nao existe autorizacao de anexo
				cGuiRef := &( cAliasCab+"->"+cAliasCab+"_OPEMOV" )+&( cAliasCab+"->"+cAliasCab+"_ANOAUT" )+&( cAliasCab+"->"+cAliasCab+"_MESAUT" )+&( cAliasCab+"->"+cAliasCab+"_NUMAUT" )
			Endif
			If &( cAliasIte+"->( MsSeek('"+ xFilial(cAliasIte)+cGuiRef+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )+"' ) )" )

			    If M->BVX_PARECE == "`0"
					If &( cAliasIte+"->"+cAliasIte+"_SALDO" ) == 0
						MsgAlert(STR0221)//"O item nЦo tem mais saldo para liberaГЦo!"
						Return
					EndIf
					If M->BVX_QTDPRO > &( cAliasIte+"->"+cAliasIte+"_SALDO" )
						MsgAlert(STR0222)//"A quantidade nЦo pode ser maior que o saldo restante!"
						Return
					EndIf
				Else
   					M->BVX_QTDPRO := &( cAliasIte+"->"+cAliasIte+"_SALDO" )
				EndIf

	        EndIf
			&( cAliasIte+"->( MsSeek('"+ xFilial(cAliasIte)+cChaveCab+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )+"' ) )" )
		EndIf
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia transacao...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lEnvTds
	If BVX->( FieldPos("BVX_CODAUD") ) > 0
	   M->BVX_CODAUD := StrZero( Val( cUsu ),6)
	Endif
	
	M->BVX_MSG := PTURemChr(M->BVX_MSG)
	
	M->BVX_OPEMOV := PlsPtuGet("OPEMOV",aGrvPdA )
	M->BVX_CODEMP := PlsPtuGet("CODEMP",aGrvPdA )
	M->BVX_MATRIC := PlsPtuGet("MATRIC",aGrvPdA )
	M->BVX_TIPREG := PlsPtuGet("TIPREG",aGrvPdA )
	M->BVX_ANOAUT := PlsPtuGet("ANOAUTINT",aGrvPdA )
	M->BVX_MESAUT := PlsPtuGet("MESAUTINT",aGrvPdA )
	M->BVX_NUMAUT := PlsPtuGet("NUMAUT",aGrvPdA )
	M->BVX_SEQUEN := PlsPtuGet("SEQUEN",aGrvPdA )
	M->BVX_CODPAD := PlsPtuGet("CODPAD",aGrvPdA )
	M->BVX_CODPRO := PlsPtuGet("CODPRO",aGrvPdA )
	M->BVX_DESPRO := PlsPtuGet("DESPRO",aGrvPdA )
	M->BVX_OPERDA := PlsPtuGet("OPERDA",aGrvPdA )
	M->BVX_CODRDA := PlsPtuGet("CODRDA",aGrvPdA )
	M->BVX_QTDPRO := PlsPtuGet("QTDPRO",aGrvPdA )
	M->BVX_NOMRDA := PLSA460NRA()
	M->BVX_LNOVO  := .T.
		
	cRecBvx := PlsPtuGet( "VALRECNO",aGrvPdA )   

	If !Empty(cRecBvx) 
		&(cAliasIte+"->(DbGoTo("+alltrim(str(cRecBvx))+"))")
	Endif

	BVX->(dbSetOrder(4))//BVX_FILIAL, BVX_OPEMOV, BVX_ANOAUT, BVX_MESAUT, BVX_NUMAUT, BVX_CODPAD, BVX_CODPRO
		
	If !BVX->(MsSeek(xFilial("BVX")+M->BVX_OPEMOV+M->BVX_ANOAUT+M->BVX_MESAUT+M->BVX_NUMAUT+M->BVX_CODPAD+M->BVX_CODPRO))
		
		PLUPTENC("BVX",3)              
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё BVX_PARECE -> 0=Liberado;1=Negado;3=Pendente							   Ё
		//Ё nao esta pendente... portanto esta autorizada ou negada					   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		PLS790GVA(cAliasCab,cAliasIte,cAliasCri,lQTDPRO,lVLRPRO,lUmAut,lReembolso,lIntern,lEvolucao,cChaveCabI,cChaveCab,cChaveBD6,cForma,M->BVX_PARECE,M->BVX_SEQUEN,M->BVX_CODAUD,M->BVX_NOMAUD,M->BVX_QTDPRO,0,M->BVX_MOTIVO,lSenhaGrv,nil,nil,lAnexos,lProrrog,lEnvTds)
	EndIf

Else
	If BVX->( FieldPos("BVX_CODAUD") ) > 0
		M->BVX_CODAUD := StrZero( Val( cUsu ),6)
	Endif

	M->BVX_MSG := PTURemChr(M->BVX_MSG)
	
	M->BVX_OPEMOV := PlsPtuGet("OPEMOV",aProAud[oOcorr:nAt] )
	M->BVX_CODEMP := PlsPtuGet("CODEMP",aProAud[oOcorr:nAt] )
	M->BVX_MATRIC := PlsPtuGet("MATRIC",aProAud[oOcorr:nAt] )
	M->BVX_TIPREG := PlsPtuGet("TIPREG",aProAud[oOcorr:nAt] )
	M->BVX_ANOAUT := PlsPtuGet("ANOAUTINT",aProAud[oOcorr:nAt] )
	M->BVX_MESAUT := PlsPtuGet("MESAUTINT",aProAud[oOcorr:nAt] )
	M->BVX_NUMAUT := PlsPtuGet("NUMAUT",aProAud[oOcorr:nAt] )
	M->BVX_SEQUEN := PlsPtuGet("SEQUEN",aProAud[oOcorr:nAt] )
	M->BVX_CODPAD := PlsPtuGet("CODPAD",aProAud[oOcorr:nAt] )
	M->BVX_CODPRO := PlsPtuGet("CODPRO",aProAud[oOcorr:nAt] )
	M->BVX_DESPRO := PlsPtuGet("DESPRO",aProAud[oOcorr:nAt] )
	M->BVX_OPERDA := PlsPtuGet("OPERDA",aProAud[oOcorr:nAt] )
	M->BVX_CODRDA := PlsPtuGet("CODRDA",aProAud[oOcorr:nAt] )
	M->BVX_NOMRDA := PLSA460NRA()
	M->BVX_LNOVO  := .T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ENC																		   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLUPTENC("BVX",3)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё BVX_PARECE -> 0=Liberado;1=Negado;3=Pendente							   Ё
	//Ё nao esta pendente... portanto esta autorizada ou negada					   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLS790GVA(cAliasCab,cAliasIte,cAliasCri,lQTDPRO,lVLRPRO,lUmAut,lReembolso,lIntern,lEvolucao,cChaveCabI,cChaveCab,cChaveBD6,cForma,M->BVX_PARECE,M->BVX_SEQUEN,M->BVX_CODAUD,M->BVX_NOMAUD,M->BVX_QTDPRO,0,M->BVX_MOTIVO,lSenhaGrv,nil,nil,lAnexos, lProrrog,lEnvTds)
		
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790GVA ╨Autor  ЁAlexander			 ╨ Data Ё  18/06/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     |Validacoes e complementos da auditoria					  ╨╠╠
╠╠юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790GVA(cAliasCab,cAliasIte,cAliasCri,lQTDPRO,lVLRPRO,lUmAut,lReembolso,lIntern,lEvolucao,cChaveCabI,cChaveCab,cChaveBD6,cForma,cParecer,cSequen,cCodAud,cNomAud,nQtdPro,nVlrApr,cMotivo,lSenhaGrv,cVia,nPerVia,lAnexos,lProrrog,lEnvTds)
LOCAL aArea     	:= GetArea() 
LOCAL cChaveGui		:= ""
LOCAL cAliasIteO 	:= ""
LOCAL cAliasCriO 	:= ""
LOCAL cAlias 		:= ""
LOCAL cAliCab		:= ""
LOCAL cAliCri		:= ""
LOCAL cKeyPtuBD6    := ""
LOCAL lGerarTit		:= .F.
LOCAL lRevalorizar 	:= .F.
LOCAL aRet			:= {}
LOCAL aComEve  		:= {}
LOCAL lExcluirGuia  := .F.
Local aAreaBD6      := BD6->(GetArea())
Local cChvBE2       := ""
LOCAL nRegBD6		:= 0
LOCAL nRegBEA		:= 0
LOCAL nRegBE2		:= 0
LOCAL nNrtrol		:= NIL
LOCAL cStatusB00    := ""
LOCAL nProBQVAut    := 0
LOCAL nProBQVNeg    := 0
LOCAL lRn395        := GetNewPar("MV_PLRN395","0") == "1"
LOCAL nProAprov 	:= 0 
LOCAL nProNeg   	:= 0 
LOCAL lOldAudit     := (FunName() == "PLS790MOV")
DEFAULT lSenhaGrv   	:= .T.
DEFAULT cVia			:= ""
DEFAULT nPerVia		:= 0
DEFAULT lAnexos		:= .F.
DEFAULT lProrrog		:= .F.
DEFAULT lEnvTds     := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Incio da transacao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Begin Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё BVX_PARECE -> 0=Liberado;1=Negado;3=Pendente
//Ё nao esta pendente... portanto esta autorizada ou negada
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If cParecer <> "3"
	
	//Grava Itens
	If !lIntern
		PLSGRVITE(cAliasIte,cAliasCri,lQTDPRO,lVLRPRO,.f.,lEvolucao,lUmAut,cParecer,cCodAud,cNomAud,nQtdPro,nVlrApr,cMotivo,lSenhaGrv,cVia,nPerVia,cAliasCab,lProrrog)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Se for internacao..
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lIntern .And. !lEvolucao
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё INTERNACAO
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		cAliasIteO := cAliasIte
		cAliasCriO := cAliasCri
		cAliasIte  := "BEJ"
		cAliasCri  := "BEL"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Itens
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _CODOPE + _ANOINT + _MESINT + _NUMINT + _SEQUEN
		If &( cAliasIte+"->( MsSeek('"+xFilial(cAliasIte)+cChaveCabI+cSequen+"') )" )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Gravacao																   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			PLSGRVITE(cAliasIte,cAliasCri,lQTDPRO,lVLRPRO,lIntern,lEvolucao,lUmAut,cParecer,cCodAud,cNomAud,nQtdPro,nVlrApr,cMotivo,/*lSenhaGrv*/,cVia,nPerVia,cAliasCab, lProrrog)
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё INTERNACAO																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//		cAliasIte := cAliasIteO
		//		cAliasCri := cAliasCriO
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё BD6																		   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BD6->( DbSetOrder(1) )
	If BD6->( MsSeek( xFilial("BD6")+cChaveBD6+cSequen ) )
		cKeyPtuBD6 := BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV)
		nRegBD6 		:= BD6->(Recno())

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё AUTORIZOU															      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If &( cAliasIte+"->"+cAliasIte+"_STATUS" ) == "1"

			lRevalorizar 	:= (lQtdPro .And. BD6->BD6_QTDPRO <> nQtdPro) .and. !lReembolso
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё ATUALIZA BD6															     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BD6->(RecLock("BD6",.F.))
			If BD6->(FieldPos("BD6_AUDITA")) > 0
				BD6->BD6_AUDITA := "1"
			Endif
			BD6->BD6_NIVAUT := BD6->BD6_NIVCRI
			BD6->BD6_NIVCRI := ''
			BD6->BD6_STATUS := "1"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Via de acesso e percentual da via
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
  		   	BD6->BD6_VIA		:= cVia
  		   	BD6->BD6_PERVIA	:= nPerVia

			If lQTDPRO
				BD6->BD6_QTDPRO := nQtdPro
				BD6->BD6_SALDO  := nQtdPro
			Endif
			BD6->(MsUnLock())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Revaloriza																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lRevalorizar
				If BD6->BD6_TIPGUI $ "01,02,04,  "
					cAlias := "BD5"
					BD5->( DbSetOrder(1) ) //BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA, R_E_C_N_O_, D_E_L_E_T_
					BD5->( MsSeek( xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) )
				Else
					cAlias := "BE4"
					BE4->( DbSetOrder(1) ) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
					BE4->( MsSeek( xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ) )
				Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Chave																				 Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cChaveGui := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Find Function																		 Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If FindFunction("PLS720ZCB")
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Goto																				Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BD6->( DbGoTo(nRegBD6) )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё PLS720ZCB																		    Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PLS720ZCB("2",cChaveGui,cAlias,.T.)
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Goto																		Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BD6->( DbGoTo(nRegBD6) )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё PLSA720EVE																	Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aComEve := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)
				aRet 	 := PLSA720EVE(BD6->BD6_TIPGUI,"",.T.,BD6->BD6_ANOPAG,BD6->BD6_MESPAG,cAlias,cChaveGui,{},"1",nil,nil,nil,.T.,nil,nil,nil,nil,nil,.T.,aComEve)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Goto																		Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BD6->( DbGoTo(nRegBD6) )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se foi guia com pagamento no ato, atualiza valor da participacao financeiraЁ
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BEA->BEA_PAGATO == "1" .And. cParecer == "0"
					BE2->(RecLock("BE2",.F.))
					BE2->BE2_VLCOMP := BD6->BD6_VLRPF
					BE2->(MsUnLock())

					BEA->(RecLock("BEA",.F.))
					BEA->BEA_VALOR += BE2->BE2_VLCOMP
					BEA->(MsUnLock())
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Rd																			Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ExistBlock("PLSREVPC")
					ExecBlock("PLSREVPC",.F.,.F.,{BD6->BD6_TIPGUI,"1",.T.,.F.})
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё NAO AUTORIZOU															  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf &( cAliasIte+"->"+cAliasIte+"_STATUS" ) == "0"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё bd7																		  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BD7->( DbSetOrder(1) )
			If BD7->( MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
				While ! BD7->( Eof() ) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se Ptu Online, bloqueia o procedimento									   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !lReembolso .And. &(cAliasCab+"->( FieldPos('"+cAliasCab+"_NRTROL') )") > 0
						If !Empty( &(cAliasCab+"->"+cAliasCab+"_NRTROL") )
							PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])
							BD7->(RecLock("BD7",.F.))
							BD7->BD7_BLOPAG := "1"
							BD7->BD7_MOTBLO := __aCdCri107[1]
							BD7->BD7_DESBLO := PLSBCTDESC()
							BD7->(MsUnLock())
						Else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Exclui BD7																   Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							BD7->(RecLock("BD7",.F.))
							BD7->(DbDelete())
							BD7->(MsUnLock())
						EndIf
					Endif	
					BD7->(DbSkip())
				Enddo
			Endif

			If BD6->(Found())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Se Ptu Online, bloqueia o procedimento							   	       Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !lReembolso .And. &(cAliasCab+"->( FieldPos('"+cAliasCab+"_NRTROL') )") > 0
					If !Empty( &(cAliasCab+"->"+cAliasCab+"_NRTROL") )
						PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])
						BD6->(RecLock("BD6",.F.))
						BD6->BD6_BLOPAG := "1"
						BD6->BD6_MOTBPG := __aCdCri107[1]
						BD6->BD6_DESBPG := PLSBCTDESC()
						BD6->(MsUnLock())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Exclui BD6					        						       	       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Else
						BD6->(RecLock("BD6",.F.))
						BD6->(DbDelete())
						BD6->(MsUnLock())
					EndIf
				Endif	
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё BD6																	       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BD6->(DbSetOrder(1))
			If !BD6->(MsSeek(xFilial("BD6")+cChaveBD6) )
				lExcluirGuia := .T.
			Endif
		Endif
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Somente se nao for evolucao												   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lEvolucao
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё PLSGUIAAUD																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aRetSta := PLSGUIAAud(cChaveCab,nil,nil,cAliasIte,lEvolucao,lIntern,nil,nil, lProrrog,lEnvTds)
		cStatus := aRetSta[2]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !aRetSta[1]
			If cStatus $ "1,2" 	//autorizada, parcialmente ou nao
				cSituac := "1" 	//Ativo
			Else 				//nao autorizada
				cSituac := "3" 	//Bloqueado
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё BEA																		   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lAnexos
				cAliCab := "B4A"
				cAliPro := "B4C"
				cAliCri := "BEG"
			ElseIf lReembolso
				cAliCab := "B44"
				cAliPro := "B45"
				cAliCri := "B46"
			ElseIf lProrrog
				cAliCab := "B4Q"
				cAliPro := "BQV"
				cAliCri := "BQZ"	
			ElseIf lIntern 
				cAliCab := "BE4"
				cAliPro := "BEJ"
				cAliCri := "BEL"	
			Else
				cAliCab := "BEA"
				cAliPro := "BE2"
				cAliCri := "BEG"
			Endif

			DbSelectArea(cAliCab)
			&(cAliCab+"->(DbClearFilter())")
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё se a autorizacao veio de uma liberacao a GUIA tem q ficar BLOQUEADA mas o BEA ativo	Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If &( cAliCab+"->( FieldPos('"+cAliCab+"_LIBERA"+"') )" ) > 0 .and. ;
				&(cAliCab+"->"+cAliCab+"_LIBERA") == "1" .And. ;
				&(cAliCab+"->"+cAliCab+"_TIPGUI") <> "03"
				cForma := "4"
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё PLSSTAGUI																			Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

			//Se a guia for de anexos clinicos, o sistema apenas altera o status, 
			//nЦo faz as validaГУes e alteraГУes de valores que И necessАrio para os outros tipos de guia
			If !cAliCab $ ("B4A, B4Q, BE4") 
					If PLSSTAGUI(&(cAliCab+"->"+cAliCab+"_OPEMOV"),&(cAliCab+"->"+cAliCab+"_ANOAUT"),&(cAliCab+"->"+cAliCab+"_MESAUT"),&(cAliCab+"->"+cAliCab+"_NUMAUT"),;
								   cSituac,.F.,nil,.T.,nil,.F.,nil,nil,Iif(cForma == "4","3",cSituac),nil,nil,nil,cStatus,cAliCab,cAliPro,cAliCri,IIF(!lReembolso .And. !Empty(nNrtrol),.F.,.T.))
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Atualiza Status Bloqueio se Ptu Online											   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If !lAnexos .and.  !lReembolso .And. !Empty( nNrtrol)
							BD6->(DbSetOrder(1))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
							If BD6->(DbSeek(cKeyPtuBD6))
		
								While xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cKeyPtuBD6 .And. !BD6->(Eof())
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Procedimento negado bloqueia pagamento    										    Ё
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									If BD6->BD6_STATUS == "0"
										If BD7->( MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
											While ! BD7->( Eof() ) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
												xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
		
												PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])
												BD7->(RecLock("BD7",.F.))
												BD7->BD7_BLOPAG := "1"
												BD7->BD7_MOTBLO := __aCdCri107[1]
												BD7->BD7_DESBLO := PLSBCTDESC()
												BD7->(MsUnLock())
												BD7->(DbSkip())
											EndDo
										Endif
		
										BD6->(RecLock("BD6",.F.))
										BD6->BD6_BLOCPA := "1"
										BD6->BD6_MOTBPF := __aCdCri107[1]
										BD6->BD6_DESBPF := PLSBCTDESC()
		
										BD6->BD6_BLOPAG := "1"
										BD6->BD6_MOTBPG := __aCdCri107[1]
										BD6->BD6_DESBPG := PLSBCTDESC()
										BD6->(MsUnLock())
									Else
										//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Procedimento liberado desmarca bloqueio    										    Ё
										//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If BD7->( MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
											While ! BD7->( Eof() ) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
												xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
		
												PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])
												BD7->(RecLock("BD7",.F.))
												BD7->BD7_BLOPAG := "0"
												BD7->BD7_MOTBLO := ""
												BD7->BD7_DESBLO := ""
												BD7->(MsUnLock())
												BD7->(DbSkip())
											EndDo
										Endif
		
										BD6->(RecLock("BD6",.F.))
										BD6->BD6_BLOCPA := ""
										BD6->BD6_MOTBPF := ""
										BD6->BD6_DESBPF := ""
		
										BD6->BD6_BLOPAG := ""
										BD6->BD6_MOTBPG := ""
										BD6->BD6_DESBPG := ""
										BD6->(MsUnLock())
		
									EndIf
									BD6->(DbSkip())
								EndDo
							EndIf
						Endif
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё ATUALIZA BEA																		   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If nRegBD6<> 0
							BD6->( DbGoTo(nRegBD6) )
						Endif
						&(cAliCab+"->(RecLock('"+cAliCab+"',.F.))")
		
						If cAliCab != "B4A"
							&(cAliCab+"->(RecLock('"+cAliCab+"',.F.))")
		
							If &( cAliCab+"->( FieldPos('"+cAliCab+"_PAGATO"+"') )" ) > 0
								&(cAliCab+"->"+cAliCab+"_PAGATO") := BD6->BD6_PAGATO
							Endif
		              EndIf
		
						If !lAnexos
							nRegBEA := BEA->(Recno())
							nRegBE2 := BE2->(Recno())
							// Atualiza o cabe'calho
							dbSelectArea("BD6")
							dbSetOrder(6)//BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_CODPAD, BD6_CODPRO
							If BD6->( MsSeek( xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV) ) )
		
								dbSelectArea("BE2")
								dbSetOrder(1)//BE2_FILIAL, BE2_OPEMOV, BE2_ANOAUT, BE2_MESAUT, BE2_NUMAUT, BE2_SEQUEN
								If BE2->( MsSeek( xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ) )
									While !BE2->(EOF()) .And. (xFilial("BE2")+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) ==;
										(xFilial("BEA")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))
										cChvBE2 := BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO)
		
										dbSelectArea("BVX")
										dbSetOrder(4)//BVX_FILIAL, BVX_OPEMOV, BVX_ANOAUT, BVX_MESAUT, BVX_NUMAUT, BVX_CODPAD, BVX_CODPRO
		
										If BVX->( MsSeek( xFilial("BVX")+AllTrim(cChvBE2) ) ) .And. BVX->BVX_PARECE == "0"
											If BD6->( MsSeek( xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BE2->(BE2_CODPAD+BE2_CODPRO)))
												If BEA->BEA_PAGATO == "1"
													BE2->(RecLock("BE2",.F.))
													BE2->BE2_VLCOMP := BD6->BD6_VLRPF
													BE2->(MsUnLock())
		
													BEA->(RecLock("BEA",.F.))
													BEA->BEA_VALOR += BE2->BE2_VLCOMP
													BEA->(MsUnLock())
												EndIf
											EndIf
										EndIf
		
										BE2->(dbSkip())
									EndDo
								EndIf
							EndIf
			            Endif
			            If nRegBD6 <> 0
							BD6->( DbGoTo(nRegBD6) )
						Endif
						If nRegBEA <> 0
							BEA->( DbGoTo(nRegBEA) )
						Endif
						If nRegBE2 <> 0
							BE2->( DbGoTo(nRegBE2) )
						Endif
		
						IF !(cAliCab == "B4A")
							If &( cAliCab+"->( FieldPos('"+cAliCab+"_PAGATO"+"') )" ) > 0 .and. &(cAliCab+"->"+cAliCab+"_PAGATO") == "1"
		
								If cStatus $ "1,2"        						//autorizada, parcialmente ou nao
									&(cAliCab+"->"+cAliCab+"_STATUS") 	:= "5" 	//aguardando baixa
									lGerarTit := .T.
								Else
									&(cAliCab+"->"+cAliCab+"_STATUS") 	:= "3" 	//nao autorizada
								Endif
							Else
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё autorizada, parcialmente autorizado
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If cStatus $ "1,2"
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Reembolso
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									If lReembolso
		
										&(cAliCab+"->"+cAliCab+"_STATUS") := "1"
											lGerarTit := .T.

										//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё Atualizando os totais da Guia de Reembolso
										//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										
										If(B45->(DbSeek(&( cAliasCab+"->"+cAliasCab+"_FILIAL" )+&( cAliasCab+"->"+cAliasCab+"_OPEMOV" )+&( cAliasCab+"->"+cAliasCab+"_ANOAUT" )+&( cAliasCab+"->"+cAliasCab+"_MESAUT" )+&( cAliasCab+"->"+cAliasCab+"_NUMAUT" ))))
									
												&( cAliasCab+"->"+cAliasCab+"_VLRPAG" ):= 0
												&( cAliasCab+"->"+cAliasCab+"_VLRBPR" ):= 0
												&( cAliasCab+"->"+cAliasCab+"_VLRGLO" ):= 0
												&( cAliasCab+"->"+cAliasCab+"_VLRMAN" ):= 0
												&( cAliasCab+"->"+cAliasCab+"_VLABPF" ):= 0
					
										
											While B45->(!Eof()) .and. B44->(&( cAliasCab+"->"+cAliasCab+"_FILIAL" )+&( cAliasCab+"->"+cAliasCab+"_OPEMOV" )+&( cAliasCab+"->"+cAliasCab+"_ANOAUT" )+&( cAliasCab+"->"+cAliasCab+"_MESAUT" )+&( cAliasCab+"->"+cAliasCab+"_NUMAUT" ))== B45->(B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT) 								
									
												&( cAliasCab+"->"+cAliasCab+"_VLRPAG" ):= &( cAliasCab+"->"+cAliasCab+"_VLRPAG" )+  &( cAliasIte+"->"+cAliasIte+"_VLRPAG" )
												&( cAliasCab+"->"+cAliasCab+"_VLRBPR" ):= &( cAliasCab+"->"+cAliasCab+"_VLRBPR" )+  &( cAliasIte+"->"+cAliasIte+"_VLRBPR" )
												&( cAliasCab+"->"+cAliasCab+"_VLRGLO" ):= &( cAliasCab+"->"+cAliasCab+"_VLRGLO" )+  &( cAliasIte+"->"+cAliasIte+"_VLRGLO" )
												&( cAliasCab+"->"+cAliasCab+"_VLRMAN" ):= &( cAliasCab+"->"+cAliasCab+"_VLRMAN" )+  &( cAliasIte+"->"+cAliasIte+"_VLRMAN" )
												&( cAliasCab+"->"+cAliasCab+"_VLABPF" ):= &( cAliasCab+"->"+cAliasCab+"_VLABPF" )+  &( cAliasIte+"->"+cAliasIte+"_VLABPF" )
												B45->(DbSkip())
									
											Enddo	
										Endif
									Else
										&(cAliCab+"->"+cAliCab+"_STATUS") := cStatus
									EndIf
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё senha
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									If !lAnexos
										If (( &(cAliCab+"->"+cAliCab+"_TIPPRE") == GetNewPar("MV_PLSTPIN","OPE") ) .Or. ( GetNewPar("MV_PLSGSAL","0") == "1" .Or. (GetNewPar("MV_PLSGRSN","0") == "1" .and. !lIntern)  )) .And. lSenhaGrv .AND. !(lIntern .And. GetNewPar("MV_PL790NE","0") == "1")
											If ExistBlock("PLS090L1")
												&(cAliCab+"->"+cAliCab+"_SENHA")  := ExecBlock("PLS090L1",.F.,.F.,{iif(BEA->BEA_LIBERA == "1","2","1"),.T.,&(cAliCab+"->"+cAliCab+"_DATPRO")} )
											Else
												&(cAliCab+"->"+cAliCab+"_SENHA")  := PLSSenAut(&(cAliCab+"->"+cAliCab+"_DATPRO"))
											EndIf
										EndIf
									Else
										lGerSenha := .F.
										BA0->(DbSetOrder(1))
										If BA0->(MsSeek(xFilial('BA0')+	&(cAliCab+"->"+cAliCab+"_OPEMOV")))
											If 	&(cAliCab+"->"+cAliCab+"_TIPANE") == '1'
												lGerSenha := BA0->BA0_SENRAD == '1'
											ElseIf 	&(cAliCab+"->"+cAliCab+"_TIPANE") == '2'
												lGerSenha := BA0->BA0_SENQUI == '1'
											Elseif 	&(cAliCab+"->"+cAliCab+"_TIPANE") == '3'
												lGerSenha := BA0->BA0_SENOPM == '1'
											Endif
											If lGerSenha
												&(cAliCab+"->"+cAliCab+"_SENHA")  := PLSSenAut(&(cAliCab+"->"+cAliCab+"_DATPRO"))
											Endif
										Endif
									Endif
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё nao autorizada
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								Else
									&(cAliCab+"->"+cAliCab+"_STATUS") := "3"
								EndIf
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Parecer negado
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If lReembolso .And. cParecer == "1"
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Posiciona no item																	Ё
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
									&( cAliasIte+"->( MsSeek('"+ xFilial(cAliasIte) + cChaveCab + cSequen + "' ) )" )
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Atualizo os valores no cabeГalho													Ё
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									&(cAliasCab+"->"+cAliasCab+"_VLRPAG") -= &(cAliasIte+"->"+cAliasIte+"_VLRPAG")
									&(cAliasCab+"->"+cAliasCab+"_VLRMAN") -= &(cAliasIte+"->"+cAliasIte+"_VLRMAN")
									&(cAliasCab+"->"+cAliasCab+"_VLRGLO") -= &(cAliasIte+"->"+cAliasIte+"_VLRGLO")
									&(cAliasCab+"->"+cAliasCab+"_VLRBPR") -= &(cAliasIte+"->"+cAliasIte+"_VLRBPR")
									//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Atualiza o bd5
									//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									BD5->( DbSetOrder(1) ) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO
									If BD5->( MsSeek(xFilial("BD5")+B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI) ) )
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										//Ё ATUALIZA BE4
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										BD5->(RecLock("BD5",.F.))
										BD5->BD5_VLRPAG := &(cAliasCab+"->"+cAliasCab+"_VLRPAG")
										BD5->BD5_VLRMAN := &(cAliasCab+"->"+cAliasCab+"_VLRMAN")
										BD5->BD5_VLRGLO := &(cAliasCab+"->"+cAliasCab+"_VLRGLO")
										BD5->BD5_VLRBPR := &(cAliasCab+"->"+cAliasCab+"_VLRBPR")
										BD5->(MsUnlock())
									EndIf
									//Verifica se a guia esta vinculada a um protocolo de reembolso
									If  &( cAliCab+"->( FieldPos('"+cAliCab+"_PROTOC"+"') )" ) > 0 .AND.  !EMPTY(Alltrim(&(cAliasCab+"->"+cAliasCab+"_PROTOC") ) );
										.AND. PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX")
		
										DbSelectArea("BOW")
										BOW->(DbSetOrder(1))
										BOW->(DbSeek(xFilial(cAliasCab)+&(cAliasCab+"->"+cAliasCab+"_PROTOC")))
		
										//Altera o Status do Protocolo
										BOW->(RecLock('BOW',.F.))
											BOW->BOW_STATUS:='8' //8=Glosado
										BOW->( MsUnlock() )
		
										//Grava o histСrico
										PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, BOW->BOW_NUMAUT, /*cNumCC*/,;
												/*dDtBaix*/, /*cObs*/, BOW->BOW_LOCATE, BOW->BOW_CODPEG, BOW->BOW_ORIMOV)
									EndIf
								EndIf
							EndIf
		
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Se tiver uma autorizado ele fecha conclui										   Ё
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If cStatus $ "1,2" .And. &( cAliCab+"->( FieldPos('"+cAliCab+"_TRACON"+"') )" ) > 0  	//autorizada, parcialmente ou nao
								&(cAliCab+"->"+cAliCab+"_TRACON") ='1'
							EndIf
							
							//Atualiza o campo Situac. TISS
							&(cAliCab+"->"+cAliCab+"_STTISS") := PLSANLSTIG(cStatus )
							
							If cAliCab != "B44" 
								&(cAliCab+"->"+cAliCab+"_STATUS") := cStatus
							EndIf
							
						EndIf
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Se tiver uma autorizado ele fecha conclui										   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If cStatus $ "1,2" .And. &( cAliCab+"->( FieldPos('"+cAliCab+"_TRACON"+"') )" ) > 0  	//autorizada, parcialmente ou nao
							&(cAliCab+"->"+cAliCab+"_TRACON") = '1'
						EndIf
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Tira da auditoria																   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						&(cAliCab+"->"+cAliCab+"_AUDITO") := "0" 			//nao esta mais em auditoria
						&(cAliCab+"->( MsUnlock() )")
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Ajusta protocolo      															    Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lRn395 .And. &( cAliCab+"->( FieldPos('"+cAliCab+"_PROATE"+"') )" ) > 0 .And. cAliasCab $ "BEA/BE4" .And. cAliasIte <> "BQV"
							B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
							If B00->(DbSeek(xFilial("B00")+Alltrim(&(cAliCab+"->"+cAliCab+"_PROATE"))))  
							
							    If &(cAliCab+"->"+cAliCab+"_STATUS") $ "1/4/5"
							    	cStatusB00	 := "1" //1=Autorizada 	
							    ElseIf &(cAliCab+"->"+cAliCab+"_STATUS") == "2"
							    	cStatusB00 := "2" //2=Autorizada Parcialmente
							    ElseIf &(cAliCab+"->"+cAliCab+"_STATUS") == "3" 
							    	cStatusB00 := "3" //3=Nao Autorizada	 
							    EndIf
						    
								B00->(RecLock("B00",.F.))
								B00->B00_STATE := cStatusB00
					   			B00->(MsUnlock())
							EndIf
						EndIf       
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё GRAVACAO																			   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If ExistBlock("PLS790GR")
							ExecBlock("PLS790GR",.F.,.F.,{K_Incluir,.T.})
						Endif
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Se for internacao...																   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If !lAnexos
							If lIntern
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё BE4																				  Ё
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
								If BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) )
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё ATUALIZA BE4																	     Ё
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									BE4->(RecLock("BE4",.F.))
									If cStatus $ "1,2" 		//autorizada, parcialmente ou nao
										BE4->BE4_STATUS := cStatus 	//aguardando CONCLUSAO
										BE4->BE4_STTISS := PLSANLSTIG(cStatus)										
										If !Empty(BEA->BEA_SENHA)
											BE4->BE4_SENHA  := BEA->BEA_SENHA
										Endif
									Else
										BE4->BE4_STATUS := "3" 	//nao autorizada
									Endif
									BE4->BE4_AUDITO := "0" 	//nao esta mais em auditoria
									
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё Se tiver uma autorizado ele fecha conclui										     Ё
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									If cStatus $ "1,2" .And. BE4->( FieldPos("BE4_TRACON") ) > 0        	//autorizada, parcialmente ou nao
										BE4->BE4_TRACON = '1'
									EndIf   
									
									If !Empty(BE4->BE4_NRTROL) .And. BE4->BE4_OPESOL <> PlsIntPad() .And. GetNewPar("MV_PTUDAUD",0) <> 0
							   			BE4->BE4_DATVAL := dDataBase+GetNewPar("MV_PTUDAUD",0)  
									ElseIf GetNewPar("MV_PLALTDT",.T.) 
								   		BE4->BE4_DATVAL := dDatabase+GetNewPar("MV_PLPRZAI",30)
									Endif		
									//Posiciono o BE2 de acordo com o item que estА sendo auditado
									If ! BE2->(BE2_SEQUEN) == cSequen
										BE2->(DbSkip(Val(cSequen) -1))
									EndIf
									      
		                   		If B72->(FieldPos("B72_DIAAUT")) > 0 .and. M->B72_DIAAUT > 0 
		                   			
		                   			If M->B72_DIAAUT >= 0												
										BE4->BE4_DIASIN := M->B72_DIAAUT				
									EndIf
		                   			
		                   		ElseIf BR8->( MsSeek(xFilial("BR8")+BE2->BE2_CODPAD+BE2->BE2_CODPRO) )
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
										//Ё0=Procedimento							(0=AMB)						 		 |
										//Ё1=Material	    						(2=Material)				 		 |
										//Ё2=Medicamento							(3=Medicamento)				 		 |
										//Ё3=Taxas									(1=Hospitalar)				 		 |
										//Ё4=Diarias								(1=Hospitalar)				 		 |
										//Ё5=Ortese/Protese							(1=Hospitalar)				 		 |
										//Ё6=Pacote 								(1=Hospitalar)				 		 |
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
										If BR8->BR8_TPPROC=='4'
		
											If M->B72_DIAAUT >= 0
												
												If GetNewPar("MV_PL790NE","0") == "1" .And. B72->(FieldPos("B72_QTDAUT")) > 0 .And. !IsInCallStack("PLS790DBCLICK")
													BE4->BE4_DIASIN := M->B72_QTDAUT
												Else
													BE4->BE4_DIASIN := BE2->BE2_QTDPRO
												EndIf
											EndIf
		
											BE4->BE4_DIASSO := BE2->BE2_QTDSOL
										Endif
									Endif
		
									BE4->(MsUnlock())
									PLSA500RCP("BE4",BE4->(Recno()),K_Incluir,nil,.F.)
								Endif
							Else
								BD5->( DbSetOrder(1) ) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO
								If BD5->( MsSeek(xFilial("BD5")+BEA->(BEA_OPEPEG+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI) ) )
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
									//Ё ATUALIZA BE4																	     Ё
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
									BD5->(RecLock("BD5",.F.))
									If cStatus $ "1,2" 		//autorizada, parcialmente ou nao
										If !Empty(BEA->BEA_SENHA)
											BD5->BD5_SENHA  := BEA->BEA_SENHA
										Endif
									Endif
									BD5->(MsUnlock())
									PLSA500RCP("BD5",BD5->(Recno()),K_Incluir,nil,.F.)
								Endif
							Endif
						Endif
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica																			   Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If lExcluirGuia .And. &(cAliCab+"->"+cAliCab+"_TIPGUI") $ "01,02,04"
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё deleta bd5																	      Ё
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If !BD5->( Eof() )
								BD5->(RecLock("BD5",.F.))
								BD5->(DbDelete())
								BD5->(MsUnLock())
							EndIf
						Endif
					Else
						ConOut( "PLSA790 - "+cAliasCab+" - "+cAliasIte+STR0219+cChaveCab+"] "+Time() ) //" Chave ["
					Endif
					
			Else
				
				If cAliasCab == "B4Q" 
				
					BQV->(dbSetOrder(1)) 
					If BQV->(MsSeek(xFilial("BQV") + cChaveCab))
						
						While BQV->(BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT) == cChaveCab
							
							If BQV->BQV_STATUS == "1"
								nProAprov++
							ElseIf BQV->BQV_STATUS == "0" 
								nProNeg++
							EndIf
							
							If nProAprov > 0 .AND. nProNeg > 0
								cStatus := "2"
								
								EXIT
							EndIf 
							
							BQV->(DbSkip())
						EndDo	
						
						If nProAprov > 0 .AND. nProNeg == 0
							cStatus := "1"
						
						ElseIf nProAprov == 0 .AND. nProNeg > 0
							cStatus := "3"
						EndIf
					EndIf 
					
					BR8->(dbSetOrder(1))
						
					If B72->(FieldPos("B72_DIAAUT")) > 0 .and. M->B72_DIAAUT > 0 
					
						B4Q->( RecLock("B4Q",.F.) )						
							B4Q->B4Q_QTDADA := M->B72_DIAAUT		
						B4Q->( msUnlock() )
						
						BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
						
						If BE4->(msSeek(xFilial("BE4")+B4Q->B4Q_GUIREF))
							
							BE4->( RecLock("BE4",.F.) )					   		
				   				BE4->BE4_DIASPR := M->B72_QTDAUT
								
								If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"  
									If Empty(BE4->BE4_DTALTA)
										BE4->BE4_DTALTA := BE4->BE4_PRVINT+M->B72_DIAAUT
									Else
										BE4->BE4_DTALTA := BE4->BE4_DTALTA+M->B72_DIAAUT
									Endif	
								Endif
								
							BE4->( msUnlock() )
								
						EndIf
						
					ElseIf BR8->( MsSeek(xFilial("BR8")+BQV->BQV_CODPAD+BQV->BQV_CODPRO) )
				
						If BR8->BR8_TPPROC=='4'
							
							B4Q->( RecLock("B4Q",.F.) )							
								B4Q->B4Q_QTDADA := M->B72_QTDAUT								
							B4Q->( msUnlock() )
							
							BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
							If BE4->(msSeek(xFilial("BE4")+B4Q->B4Q_GUIREF))
								
								BE4->( RecLock("BE4",.F.) )
								
								If GetNewPar("MV_PL790NE","0") == "1" .And. B72->(FieldPos("B72_QTDAUT")) > 0
							   		
					   				BE4->BE4_DIASPR := M->B72_QTDAUT
									
									If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"  
										If Empty(BE4->BE4_DTALTA)
						 					BE4->BE4_DTALTA := BE4->BE4_PRVINT+M->B72_QTDAUT
										Else
											BE4->BE4_DTALTA := BE4->BE4_DTALTA+M->B72_QTDAUT
										Endif	
									Endif
		
								Else
									
									BE4->BE4_DIASPR := BQV->BQV_QTDPRO 
									If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"  
										If Empty(BE4->BE4_DTALTA)
						 					BE4->BE4_DTALTA:=BE4->BE4_PRVINT+BQV->BQV_QTDPRO
										Else
											BE4->BE4_DTALTA:=BE4->BE4_DTALTA+BQV->BQV_QTDPRO
										Endif	
									Endif
																		
								EndIf
								
								BE4->( msUnlock() )
								
							EndIf
	
						Endif
					Endif
				EndIf	
					
				&( cAliCab+"->( RecLock('"+cAliCab+"',.F.) )" ) 
					&(cAliCab+"->"+cAliCab+"_STATUS") 	:= cStatus 	
					&( cAliCab+"->"+cAliCab+"_AUDITO" ) := "0"
					
					If &( cAliasCab+"->( FieldPos('"+cAliasCab+"_STTISS"+"') )" ) > 0
						&( cAliCab+"->"+cAliCab+"_STTISS" ) := PLSANLSTIG(cStatus ) 
					EndIf
				&( cAliCab+"->( MsUnlock() )" ) 

				If cAliCab == "BE4" 
					
					BEA->(dbSetOrder(1))
					If BEA->(MsSeek(xFilial("BEA") + B53->B53_NUMGUI))

						BEA->( RecLock("BEA",.F.) )  
							BEA->BEA_STATUS := cStatus
							BEA->BEA_AUDITO := "0"
							
							If BEA->( FieldPos("BEA_STTISS") ) > 0
								BEA->BEA_STTISS := PLSANLSTIG(cStatus) 
							EndIf
						BEA->( MsUnlock() )
					EndIf
				EndIf 
			EndIf
		Else
			If lReembolso .And. cParecer == "1"
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Posiciona no item																	Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
				&( cAliasIte+"->( MsSeek('"+ xFilial(cAliasIte)+cChaveCab+cSequen+"' ) )" )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualizo os valores no cabeГalho													Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")
				&(cAliasCab+"->"+cAliasCab+"_VLRPAG") -= &(cAliasIte+"->"+cAliasIte+"_VLRPAG")
				&(cAliasCab+"->"+cAliasCab+"_VLRMAN") -= &(cAliasIte+"->"+cAliasIte+"_VLRMAN")
				&(cAliasCab+"->"+cAliasCab+"_VLRGLO") -= &(cAliasIte+"->"+cAliasIte+"_VLRGLO")
				&(cAliasCab+"->"+cAliasCab+"_VLRBPR") -= &(cAliasIte+"->"+cAliasIte+"_VLRBPR")
				&(cAliasCab+"->( MsUnlock() )")
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё ATUALIZA BD5
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				BD5->( DbSetOrder(1) ) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO
				If BD5->( MsSeek(xFilial("BD5")+B44->(B44_OPEMOV+B44_CODLDP+B44_CODPEG+B44_NUMGUI) ) )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё ATUALIZA BE4
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					BD5->(RecLock("BD5",.F.))
					BD5->BD5_VLRPAG := &(cAliasCab+"->"+cAliasCab+"_VLRPAG")
					BD5->BD5_VLRMAN := &(cAliasCab+"->"+cAliasCab+"_VLRMAN")
					BD5->BD5_VLRGLO := &(cAliasCab+"->"+cAliasCab+"_VLRGLO")
					BD5->BD5_VLRBPR := &(cAliasCab+"->"+cAliasCab+"_VLRBPR")
					BD5->(MsUnlock())
				EndIf
			
			Else
				
				If lIntern
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё BE4																				  Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
					If BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) )
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё ATUALIZA BE4																	     Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						BE4->(RecLock("BE4",.F.))
							If cStatus $ "1,2" 		//autorizada, parcialmente ou nao
								BE4->BE4_STATUS := cStatus 	//aguardando CONCLUSAO
							Else
								BE4->BE4_STATUS := "3" 	//nao autorizada
							Endif
							BE4->BE4_AUDITO := "0" 	//nao esta mais em auditoria

							//Posiciono o BE2 de acordo com o item que estА sendo auditado
							If ! BE2->(BE2_SEQUEN) == cSequen
								BE2->(DbSkip(Val(cSequen) -1))
							EndIf

							If !lOldAudit .And. B72->(FieldPos("B72_DIAAUT")) > 0 .and. M->B72_DIAAUT > 0 
		                   			
		                   		If M->B72_DIAAUT >= 0													
									BE4->BE4_DIASIN := M->B72_DIAAUT												
								EndIf
		                   			
		                  ElseIf BR8->( MsSeek(xFilial("BR8")+BE2->BE2_CODPAD+BE2->BE2_CODPRO) )
								If BR8->BR8_TPPROC=='4'

									If !lOldAudit .And. M->B72_DIAAUT >= 0		
							         	If GetNewPar("MV_PL790NE","0") == "1" .And. B72->(FieldPos("B72_QTDAUT")) > 0 .And. !IsInCallStack("PLS790DBCLICK")
											BE4->BE4_DIASIN := M->B72_QTDAUT
										Else
											BE4->BE4_DIASIN := BE2->BE2_QTDPRO
										EndIf
									EndIf

									BE4->BE4_DIASSO := BE2->BE2_QTDSOL
								Endif
							Endif
						BE4->(MsUnlock())
						PLSA500RCP("BE4",BE4->(Recno()),K_Incluir,nil,.F.)
					Endif
				Else
					if empty(cAliCab) 
					
						&( cAliasCab+"->( RecLock('"+cAliasCab+"',.F.) )" ) 
							If cStatus $ "1,2" 		//autorizada, parcialmente ou nao
								&( cAliasCab+"->"+cAliasCab+"_STATUS" ) := cStatus 	//aguardando CONCLUSAO
							Else
								&( cAliasCab+"->"+cAliasCab+"_STATUS" ) := "3" 	//nao autorizada
							Endif
						&( cAliasCab+"->( MsUnlock() )" ) 
						
					Else
						
						&( cAliCab+"->( RecLock('"+cAliCab+"',.F.) )" ) 
							If cStatus $ "1,2" 		//autorizada, parcialmente ou nao
								&( cAliCab+"->"+cAliCab+"_STATUS" ) := cStatus 	//aguardando CONCLUSAO
							Else
								&( cAliCab+"->"+cAliCab+"_STATUS" ) := "3" 	//nao autorizada
							Endif
						&( cAliCab+"->( MsUnlock() )" )
						 
					EndIf 
				Endif
			Endif
		Endif
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualizando Status InternaГЦo																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aRetSta := PLSGUIAAud(cChaveCab,nil,nil,cAliasIte,lEvolucao,lIntern)
		If aRetSta[3] == 0 // Se nao tiver mais Saldo
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Ajusta Protocolo															        Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды        
			If lRn395 .And. &( cAliasIte+"->( FieldPos('"+cAliasIte+"_PROATE"+"') )" ) > 0
				B00->(DbSetOrder(1))//B00_FILIAL+B00_COD+B00_NUMGUI
				If B00->(DbSeek(xFilial("B00")+Alltrim(&(cAliasIte+"->"+cAliasIte+"_PROATE" )))) 
				
					cSql := " SELECT BQV_STATUS FROM "+RetSQLName("BQV")
					cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' " 
					cSql += " AND BQV_CODOPE = '"+BQV->BQV_CODOPE+"' "
					cSql += " AND BQV_ANOINT = '"+BQV->BQV_ANOINT+"' "  
					cSql += " AND BQV_MESINT = '"+BQV->BQV_MESINT+"' "  
					cSql += " AND BQV_NUMINT = '"+BQV->BQV_NUMINT+"' "  
					cSql += " AND BQV_PROATE = '"+BQV->BQV_PROATE+"' "  
					cSql += " AND D_E_L_E_T_ <> '*' "  
					
					cSql := ChangeQuery(cSql)
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"B00Prot",.T.,.F.)

                    B00Prot->(DbGotop())
                    While !B00Prot->(Eof()) 
                    	If B00Prot->BQV_STATUS == "1"
                    		nProBQVAut ++
                    	ElseIf B00Prot->BQV_STATUS == "0" 
                    		nProBQVNeg ++	
                    	EndIf	
	                    B00Prot->(DbSkip())
                    EndDo
                    B00Prot->( dbClosearea() )   
                                       
					
  					If nProBQVAut > 0 .And. nProBQVNeg == 0
					   	cStatusB00	 := "1" //1=Autorizada 	
					ElseIf nProBQVAut > 0 .And. nProBQVNeg > 0
						cStatusB00 := "2" //2=Autorizada Parcialmente
					ElseIf nProBQVAut == 0 .And. nProBQVNeg > 0
						cStatusB00 := "3" //3=Nao Autorizada	 
					EndIf
							    
					B00->(RecLock("B00",.F.))
					B00->B00_STATE := cStatusB00
					B00->(MsUnlock())
				EndIf
			EndIf		
		Endif	
	Endif
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ATUALIZA ITEM																        Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	&( cAliasIte+"->( RecLock('"+cAliasIte+"',.F.) )" )
	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_PENDEN') )" ) > 0
		&( cAliasIte+"->"+cAliasIte+"_PENDEN" ) := "1" // Pendente!
	Endif

	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_CODAUD') )" ) > 0 .And. &( cAliasIte+"->( FieldPos('"+cAliasIte+"_NOMAUD') )" ) > 0
		&( cAliasIte+"->"+cAliasIte+"_CODAUD" ) := cCodAud
		&( cAliasIte+"->"+cAliasIte+"_NOMAUD" ) := cNomAud
	Endif
	&( cAliasIte+"->( MsUnlock() )" )
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Transacao																	Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction
///GravaГЦo dos titulos
If lGerarTit

	If !lReembolso
		cPrefixo 		:= GetNewPar("MV_PLSPRCP","CPP")
		cNumTit  		:= PLSE1NUM(cPrefixo)
		cTipTit  		:= GetNewPar("MV_PLSTPCP","FT")
		dvencto  		:= BEA->BEA_DATPRO+GetNewPar("MV_PLSVCGC",0)
		nOpc     		:= K_Incluir
		cParcTit 		:= Space( Len(SE1->E1_PARCELA))
		cTipoRotEsp	:= "2"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё plsgrvtcp																			  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPonto de entrada para customizaГЦo do usuarios antes de gerar o SE1Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BD5->(RecLock("BD5",.F.))
		If ExistBlock("PLSA790CRT")

			aRetGrvSe1 := ExecBlock("PLSA790CRT",.F.,.F.,{cPrefixo,cNumTit,cTipTit,dVencto,nOpc,cParcTit,cTipoRotEsp,BEA->BEA_CODCLI,BEA->BEA_LOJA})

			PLSGRVTCP(  aRetGrvSe1[1],aRetGrvSe1[2],aRetGrvSe1[8],aRetGrvSe1[9],aRetGrvSe1[3],aRetGrvSe1[4],;
						BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,aRetGrvSe1[5],BEA->BEA_VALOR,BEA->BEA_CONEMP,BEA->BEA_VERCON,;
						BEA->BEA_SUBCON,BEA->BEA_VERSUB )

		Else
			PLSGRVTCP(  cPrefixo,cNumTit,BEA->BEA_CODCLI,BEA->BEA_LOJA,cTipTit,dVencto,;
						BEA->BEA_OPEUSR,BEA->BEA_CODEMP,BEA->BEA_MATRIC,nOpc,BEA->BEA_VALOR,BEA->BEA_CONEMP,BEA->BEA_VERCON,;
						BEA->BEA_SUBCON,BEA->BEA_VERSUB )
		Endif
		BD5->(MsUnlock())
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё ATUALIZA BEA																		  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BEA->(RecLock("BEA",.F.))
		BEA->BEA_CHVSE1 := cPrefixo+cNumTit
		If BEA->( FieldPos("BEA_NUMTIT") ) > 0
			BEA->BEA_PREFIX := cPrefixo
			BEA->BEA_NUMTIT := cNumTit
			BEA->BEA_PARCEL := cParcTit
			BEA->BEA_TIPTIT := cTipTit
		EndIf

		BEA->(MsUnLock())
	Else

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Se a guia estiver vinculada a um protocolo irА alterar o status do protocolo
		//O lote de cobranГa entao serА gerado pela rotina "Aprovar Reembolso" dentro
		//da rotina de autorizaГЦo de reembolso
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		If  &( cAliCab+"->( FieldPos('"+cAliCab+"_PROTOC"+"') )" ) > 0 .AND.  !EMPTY(Alltrim(&(cAliasCab+"->"+cAliasCab+"_PROTOC") ) );
			.AND. PLSALIASEXI("BOW") .AND. PLSALIASEXI("BOX")

			DbSelectArea("BOW")
			BOW->(DbSetOrder(1))
			BOW->(DbSeek(xFilial(cAliasCab)+&(cAliasCab+"->"+cAliasCab+"_PROTOC")))

			//Altera o Status do Protocolo
			BOW->(RecLock('BOW',.F.))
				BOW->BOW_STATUS:='5' //5=Em digitaГЦo
			BOW->( MsUnlock() )

			//Grava o histСrico
			PLGRVBOX(BOW->BOW_PROTOC,BOW->BOW_MATRIC,BOW->BOW_STATUS, BOW->BOW_NUMAUT, /*cNumCC*/,;
					/*dDtBaix*/, /*cObs*/, BOW->BOW_LOCATE, BOW->BOW_CODPEG, BOW->BOW_ORIMOV)

		Else
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Caso nao tenha protocolo gera o lote de cobranГa
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			If &(cAliCab+"->"+cAliCab+"_FORPAG") <> '0'	
				If GetNewPar("MV_PLRESE1","1") == "1"
					cNat     := GetNewPar("MV_PLSNTRE",'"PLS"')
					cNat     := Eval({|| &cNat })
					cPrefixo := GetNewPar("MV_PLSPFRE",'"RLE"')
					cPrefixo := Eval({|| &cPrefixo })
					cNumTit  := PLSE1NUM(cPrefixo)
					cTipTit  := GetNewPar("MV_PLSNCRE","NCC")
					dVencto  := &(cAliCab+"->"+cAliCab+"_DATVEN")
					cCodCli  := &(cAliCab+"->"+cAliCab+"_CODCLI")
					cLoja    := &(cAliCab+"->"+cAliCab+"_LOJA")
					nVlrPag  := &(cAliCab+"->"+cAliCab+"_VLRPAG")
					cCodInt  := &(cAliCab+"->"+cAliCab+"_OPEUSR")
					cCodEmp  := &(cAliCab+"->"+cAliCab+"_CODEMP")
					cMatric  := &(cAliCab+"->"+cAliCab+"_MATRIC")
					cTipReg  := &(cAliCab+"->"+cAliCab+"_TIPREG")
					cConEmp  := &(cAliCab+"->"+cAliCab+"_CONEMP")
					cVerCon  := &(cAliCab+"->"+cAliCab+"_VERCON")
					cSubCon  := &(cAliCab+"->"+cAliCab+"_SUBCON")
					cVerSub  := &(cAliCab+"->"+cAliCab+"_VERSUB")
	
					If ExistBlock("PLS001CLI")
						aRetPto := ExecBlock("PLS001CLI",.F.,.F.,{cCodCli,cLoja,cNat,cPrefixo,cNumTit,cTipTit,dVencto})
						cCodCli := aRetPto[1]
						cLoja   := aRetPto[2]
						cNat    := aRetPto[3]
						cPrefixo:= aRetPto[4]
						cNumTit := aRetPto[5]
						cTipTit := aRetPto[6]
						dVencto := aRetPto[7]
					Endif
	
					PLSGRVREM(cPrefixo,cNumTit,cCodCli,cLoja,cTipTit,dVencto,cCodInt,;
					cCodEmp,cMatric,K_Incluir,nVlrPag,cConEmp,cVerCon,cSubCon,;
					cVerSub,cTipReg,cNat)
	
					&(cAliCab+"->(RecLock('"+cAliCab+"',.F.))")
					&(cAliCab+"->"+cAliCab+"_PREFIX"):= cPrefixo
					&(cAliCab+"->"+cAliCab+"_NUM")   := cNumTit
					&(cAliCab+"->"+cAliCab+"_PARCEL"):= ''
					&(cAliCab+"->"+cAliCab+"_TIPO")  := cTipTit
					&(cAliCab+"->( MsUnlock() )")
	
	          	Else
					cNat     := GetNewPar("MV_PLSNTRE",'"PLS"')
					cNat     := Eval({|| &cNat })
					cTipo    := GetNewPar("MV_PLSNCRE","NCC")
					cPrefixo := GetNewPar("MV_PLSPFRE",'"RLE"')
					cPrefixo := Eval({|| &cPrefixo })
					cNumTit  := PLSREMSE2(cPrefixo)
      				dVencto  := IIF(!Empty(dVencto),&(cAliasCab+"->"+cAliasCab+"_DATPAG"),dDataBase + GetNewPar("MV_PLSVCGC",0))
					cCodCli  := &(cAliasCab+"->"+cAliasCab+"_CODCLI")
					cLoja    := &(cAliasCab+"->"+cAliasCab+"_LOJA")
					cCodInt  := &(cAliCab+"->"+cAliCab+"_OPEUSR")
					cCodEmp  := &(cAliCab+"->"+cAliCab+"_CODEMP")
					cMatric  := &(cAliCab+"->"+cAliCab+"_MATRIC")
					cTipReg  := &(cAliCab+"->"+cAliCab+"_TIPREG")
					cConEmp  := &(cAliCab+"->"+cAliCab+"_CONEMP")
					cVerCon  := &(cAliCab+"->"+cAliCab+"_VERCON")
					cSubCon  := &(cAliCab+"->"+cAliCab+"_SUBCON")
					cVerSub  := &(cAliCab+"->"+cAliCab+"_VERSUB")
					cMesAut  := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
					cAnoAut  := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
                  cNumAut  := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
                    
					If &(cAliasCab+"->(FieldPos('"+cAliasCab+"_NROBCO'))") > 0
						cBanco   := &(cAliasCab+"->"+cAliasCab+"_NROBCO") //Numero Banco
						cAgencia := &(cAliasCab+"->"+cAliasCab+"_NROAGE") //Numero Agencia
						cConta   := &(cAliasCab+"->"+cAliasCab+"_NROCTA") //Numero Conta
					Else
						cBanco   := ""
						cAgencia := ""
						cConta   := ""
					Endif

				    //Armazenar Referencia Arquivo BA1 ...
                    nOrdBa1O  := BA1->(IndexOrd())
                    nRecBa1O  := BA1->(Recno())

				    //Forcar Buscar Registro Beneficiario Titular ...
					BA1->(DbSetOrder(2))
					BA1->(MsSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+GetNewPar("MV_PLTRTIT","00")))
 
                    //Setar Ordem Arquivo SA2 - Cadastro Fornecedores (SA2) ...
                    SA2->(DbSetOrder(3))

				    //Verifico Se Eh Beneficiario Titular ...
				    If AllTrim(BA1->BA1_TIPUSU) $ "T" // Titular ????
                       lFoundSA2 := (!Empty(BA1->BA1_CPFUSR) .And. SA2->(DbSeek(xFilial("SA2")+BA1->BA1_CPFUSR)))  //1a Vez .F. e na 2a Vez .T.
   				    Else //Se Nao Eh Titular
                       lFoundSA2 := .T. //Para nao acessar Area Criacao Cadastro SA2.
                   EndIf
						//pode ter cliente que quer usar a busca por nome
				    If GetNewPar("MV_PLRENOM","1") == "1"
				       SA2->(DbSetOrder(2))
				       lFoundSA2 := SA2->(dbSeek(xFilial("SA2")+SA2->A2_NOME))
				    Endif

				    //busco o banco caso nao tenha sido informado ainda
				    If !(lFoundSA2)
						If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta)

							BA3->(DbSetORder(1))
                        	BA3->(MsSeek(xFilial("BA3") + BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_CODEMP + BA1->BA1_CONEMP + BA1->BA1_VERCON + BA1->BA1_SUBCON + BA1->BA1_VERSUB))

                        	cBanco   := BA3->BA3_BCOCLI
                        	cAgencia := BA3->BA3_AGECLI
                        	cConta   := BA3->BA3_CTACLI
                    	EndIf

                    	SA2->(RecLock("SA2",.T.))
					    SA2->A2_FILIAL	 := xFilial("SA2")
					    SA2->A2_COD		 := GetSX8Num("SA2","A2_COD")
					    SA2->A2_LOJA	     := '01'
					    SA2->A2_NOME	     := BA1->BA1_NOMUSR
					    SA2->A2_CGC		 := BA1->BA1_CPFUSR
					    SA2->A2_TEL		 := BA1->BA1_TELEFO
					    SA2->A2_FAX       := BA1->BA1_TELEFO
					    SA2->A2_NREDUZ	 := BA1->BA1_NOMUSR
					    SA2->A2_BAIRRO	 := BA1->BA1_BAIRRO
				    	SA2->A2_MUN		 := BA1->BA1_MUNICI
					    SA2->A2_EST		 := BA1->BA1_ESTADO
					    SA2->A2_END		 := BA1->BA1_ENDERE
					    SA2->A2_TIPO 	     := "F"
					    SA2->A2_EMAIL     := BA1->BA1_EMAIL
					    SA2->A2_BANCO     := cBanco
					    SA2->A2_AGENCIA   := cAgencia
					    SA2->A2_NUMCON    := cConta
					    SA2->(MsUnlock())
					    SA2->(ConfirmSX8())
					EndIf
					//Atualizo Variaveis do Fornecedor ...
					cCodForn := SA2->A2_COD
  					cLoja    := SA2->A2_LOJA

					nVlrPag  := &(cAliasCab+"->"+cAliasCab+"_VLRPAG")

					If ExistBlock("PLS002FOR")
						aRetPto  := ExecBlock("PLS002FOR",.F.,.F.,{cCodForn,cLoja,cNat,cPrefixo,cNumTit,cTipo,dVencto,cCodInt,cCodEmp,cMatric})
						cCodForn := aRetPto[1]
						cLoja    := aRetPto[2]
						cNat     := aRetPto[3]
						cPrefixo := aRetPto[4]
						cNumTit  := aRetPto[5]
						cTipo    := aRetPto[6]
						dVencto  := aRetPto[7]
					EndIf

					aCampos :={	{"E2_FILIAL"    ,xFilial("SE2")     ,NIL},;
								{"E2_PREFIXO"	,cPrefixo           ,Nil},;
								{"E2_NUM"		,cNumTit            ,Nil},;
								{"E2_PARCELA"	,Space(Len(SE2->E2_PARCELA))           ,Nil},;
								{"E2_TIPO"		,cTipo              ,Nil},;
								{"E2_FORNECE"	,cCodForn           ,Nil},;
								{"E2_LOJA"		,cLoja              ,Nil},;
								{"E2_NOMFOR"    ,posicione("SA2",1,xFilial("SA2")+cCodForn+cLoja,"A2_NREDUZ"),Nil},;
								{"E2_EMISSAO"	,dDataBase          ,NIL},;
								{"E2_EMIS1"   ,dDataBase          ,NIL},;
								{"E2_VENCTO"	,dVencto            ,NIL},;
								{"E2_VENCREA"   ,DataValida(dVencto),NIL},;
								{"E2_VENCORI"   ,dVencto          ,NIL},;
								{"E2_MOEDA"     ,01                 ,NIL},;
								{"E2_VALOR"		,nVlrPag			,Nil},;
								{"E2_VLCRUZ"	,nVlrPag            ,Nil},;
								{"E2_SALDO"		,nVlrPag            ,Nil},;
								{"E2_DECRESC"   ,0		            ,NIL},;
								{"E2_ACRESC"    ,0		            ,NIL},;
								{"E2_PLLOTE"    ,cMesAut+cNumAut    ,NIL},;
								{"E2_PLOPELT"   ,cAnoAut            ,NIL},;
								{"E2_CODRDA"    ,""                 ,NIL},;
								{"E2_ANOBASE"   ,cAnoAut            ,NIL},;
								{"E2_MESBASE"   ,cMesAut            ,NIL},;
								{"E2_NATUREZ" 	,cNat				,NIL},;
								{"E2_DESDOBR" 	,"N"				,NIL},;
								{"E2_DIRF" 		,"2"				,NIL},;
								{"E2_HIST" 		,"PAGTO. REEMBOLSO"	,NIL},;
								{"E2_ORIGEM"	,"PLSA090"			,NIL}}

					lMsErroAuto := .F.
					MsExecAuto({ | a,b | Fina050(a,b) }, aCampos, 3)

					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
						lRetorno := .F.
					Else
						&(cAliasCab+"->(RecLock('"+cAliasCab+"',.F.))")
						&(cAliasCab+"->"+cAliasCab+"_PREFIX"):= cPrefixo
						&(cAliasCab+"->"+cAliasCab+"_NUM")   := cNumTit
						&(cAliasCab+"->"+cAliasCab+"_TIPO")  := cTipo
						&(cAliasCab+"->"+cAliasCab+"_PARCEL"):= ''
						&(cAliasCab+"->( MsUnlock() )")
						lRetorno := .T.
					Endif			
				EndIf
			Endif
       EndIf
	Endif
Endif


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Rest nas linhas do browse e na area
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSGRVITE ╨Autor  ЁAlexander			 ╨ Data Ё  18/06/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     |Gravacao													  ╨╠╠
╠╠юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSGRVITE(cAliasIte,cAliasCri,lQTDPRO,lVLRPRO,lIntern,lEvolucao,lUmAut,cParecer,cCodAud,cNomAud,nQtdPro,nVlrApr,cMotivo,lSenhaGrv,cVia,nPerVia,cAliasCab, lProrrog)
LOCAL nRec      := 0
LOCAL nI		:= 0
LOCAL nPos		:= 0
local nVlrBPR 	:= 0
local nVlrAPR	:= 0
local nPerCPF 	:= 0
LOCAL cChaveIte := ""
LOCAL cChaveAju	:= ""
LOCAL cChaveCri	:= ""
LOCAL aMatIte	:= {}
LOCAL lAchoUm 	:= .F.
LOCAL lOldAudit := (FunName() == "PLS790MOV")
DEFAULT lSenhaGrv 	:= .T.
DEFAULT cVia		:= ""
DEFAULT nPerVia		:= 0

//Se for interncacao
If lIntern .Or. lEvolucao .OR. lProrrog
	
	If !EMPTY(cMotivo)
		cChaveIte := cAliasIte+"->( "+cAliasIte+"_CODOPE+"+cAliasIte+"_ANOINT+"+cAliasIte+"_MESINT+"+cAliasIte+"_NUMINT+"+cAliasIte+"_SEQUEN )"
		cChaveCri := cAliasCri+"->( "+cAliasCri+"_CODOPE+"+cAliasCri+"_ANOINT+"+cAliasCri+"_MESINT+"+cAliasCri+"_NUMINT+"+cAliasCri+"_SEQUEN )"
		
	ElseIf cParecer == "0"
		
		cSql := " UPDATE " + RETSQLNAME(cAliasCri) + " SET D_E_L_E_T_ = '*' "
		cSql += " WHERE " + cAliasCri + "_FILIAL = '" + xFilial(cAliasCri) + "' AND " 
		cSql += cAliasCri+"->"+cAliasCri+"_CODOPE = '" + &(cAliasIte+"->"+cAliasIte+"_CODOPE") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_ANOINT = '" + &(cAliasIte+"->"+cAliasIte+"_ANOINT") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_MESINT = '" + &(cAliasIte+"->"+cAliasIte+"_MESINT") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_NUMINT = '" + &(cAliasIte+"->"+cAliasIte+"_NUMINT") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_SEQUEN = '" + &(cAliasIte+"->"+cAliasIte+"_SEQUEN") + "' AND "
		cSql += " AND D_E_L_E_T_ = ' ' "
	EndIf

	cChaveAju := cAliasIte+"->( "+cAliasIte+"_CODOPE+"+cAliasIte+"_ANOINT+"+cAliasIte+"_MESINT+"+cAliasIte+"_NUMINT )"
Else
	
	If !EMPTY(cMotivo)
		cChaveIte := cAliasIte+"->( "+cAliasIte+"_OPEMOV+"+cAliasIte+"_ANOAUT+"+cAliasIte+"_MESAUT+"+cAliasIte+"_NUMAUT+"+cAliasIte+"_SEQUEN )"
		cChaveCri := cAliasCri+"->( "+cAliasCri+"_OPEMOV+"+cAliasCri+"_ANOAUT+"+cAliasCri+"_MESAUT+"+cAliasCri+"_NUMAUT+"+cAliasCri+"_SEQUEN )"
	
	ElseIf cParecer == "0"

		cSql := " UPDATE " + RETSQLNAME(cAliasCri) + " SET D_E_L_E_T_ = '*' "
		cSql += " WHERE " + cAliasCri + "_FILIAL = '" + xFilial(cAliasCri) + "' AND " 
		cSql += cAliasCri+"->"+cAliasCri+"_OPEMOV = '" + &(cAliasIte+"->"+cAliasIte+"_OPEMOV") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_ANOAUT = '" + &(cAliasIte+"->"+cAliasIte+"_ANOAUT") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_MESAUT = '" + &(cAliasIte+"->"+cAliasIte+"_MESAUT") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_NUMAUT = '" + &(cAliasIte+"->"+cAliasIte+"_NUMAUT") + "' AND "
		cSql += cAliasCri+"->"+cAliasCri+"_SEQUEN = '" + &(cAliasIte+"->"+cAliasIte+"_SEQUEN") + "'"
		cSql += " AND D_E_L_E_T_ = ' ' "
	EndIf
EndIf 

(cAliasIte)->(DbClearFilter()) //Esse item se faz necessario devio logo abaixo o sistema esta mudando seu status assim ele sai do filtro e nЦo atualiza o saldo
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processo de gravacao																Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
&( cAliasIte+"->( RecLock('"+cAliasIte+"',.F.) )" )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Liberada
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If cParecer == "0"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Autorizada
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	&( cAliasIte+"->"+cAliasIte+"_STATUS" ) := "1"
	
	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_IMGSTA') )" ) > 0 
		&( cAliasIte+"->"+cAliasIte+"_IMGSTA" ) := "ENABLE"
	EndIf 

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza o nivel																	Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_NIVAUT') )" ) > 0 .And. &( cAliasIte+"->( FieldPos('"+cAliasIte+"_NIVCRI') )" ) > 0
		&( cAliasIte+"->"+cAliasIte+"_NIVAUT" ) := &( cAliasIte+"->"+cAliasIte+"_NIVCRI" )
		&( cAliasIte+"->"+cAliasIte+"_NIVCRI" ) := ''
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё gerando a nova valorizaГЦo										          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cAliasIte $ "BD6/B45"
		
		aDadUsr := PLSDADUSR(&(cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC+"+cAliasCab+"_TIPREG+"+cAliasCab+"_DIGITO)"),"1",.T., &(cAliasCab+"->("+cAliasCab+"_DATPRO)"))
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Busco os registros b47 jah no acols									 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aRdas := PLS720IBD7(nil,nil,&( cAliasIte+"->"+cAliasIte+"_CODPAD" ),&( cAliasIte+"->"+cAliasIte+"_CODPRO" ),&( cAliasIte+"->"+cAliasIte+"_ALIATB" ),&( cAliasIte+"->"+cAliasIte+"_OPEMOV" ),&( cAliasCab+"->"+cAliasCab+"_CODRDA" ),nil,;
							nil,nil,nil,&( cAliasCab+"->"+cAliasCab+"_CODESP" ),&( cAliasCab+"->"+cAliasCab+"_LOCATE" ),"3",&( cAliasIte+"->"+cAliasIte+"_SEQUEN" ),"1","04",;
							&( cAliasIte+"->"+cAliasIte+"_DATPRO" ),nil,nil,nil,nil)
		
		
		aUnd:={}
		
		aValor := PLSCALCEVE(&( cAliasIte+"->"+cAliasIte+"_CODPAD" ),&( cAliasIte+"->"+cAliasIte+"_CODPRO" ),&( cAliasCab+"->"+cAliasCab+"_MESPAG" ),&( cAliasCab+"->"+cAliasCab+"_ANOPAG" ),&( cAliasIte+"->"+cAliasIte+"_OPEMOV" ),&( cAliasCab+"->"+cAliasCab+"_CODRDA" ),&( cAliasCab+"->"+cAliasCab+"_CODESP" ),"",;
							&( cAliasCab+"->"+cAliasCab+"_LOCATE" ),&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ),&( cAliasIte+"->"+cAliasIte+"_DATPRO" ),aDadUsr[48],&( cAliasCab+"->"+cAliasCab+"_PADINT" ),&( cAliasCab+"->"+cAliasCab+"_REGINT" ),&( cAliasIte+"->"+cAliasIte+"_VLRAPR" ),aDadUsr,&( cAliasCab+"->"+cAliasCab+"_PADCON" ),;
							nil,&( cAliasIte+"->"+cAliasIte+"_CODTAB" ),&( cAliasIte+"->"+cAliasIte+"_ALIATB" ),nil,nil,&( cAliasIte+"->"+cAliasIte+"_HORPRO" ),IIf(EMPTY(aUnd),aRdas,aUnd),nil,&( cAliasIte+"->"+cAliasIte+"_PROREL" ),&( cAliasIte+"->"+cAliasIte+"_PRPRRL" ),;
							nil,.T.,&( cAliasIte+"->"+cAliasIte+"_DATPRO" ),&( cAliasIte+"->"+cAliasIte+"_HORPRO" ),nil,'04',.F.,0,nil,nil,;
							If(&(cAliasIte+"->"+cAliasIte+"_PROCCI")=="0",.F.,.T.),IIF(!lOldAudit,M->B72_PERVIA,&( cAliasIte+"->"+cAliasIte+"_PERVIA" )) ,nil,nil,&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ),,,,,,,&( cAliasCab+"->"+cAliasCab+"_REGINT" ),&( cAliasCab+"->"+cAliasCab+"_TIPPAC" ),,&( cAliasCab+"->"+cAliasCab+"_UFATE" ),&( cAliasIte+"->"+cAliasIte+"_CODMUN" )) 
		
		//Protecao para quando o cliente nao permitir valorar devido alguma acao no PLSRETCP
		If Len(aValor) > 2 .And. ValType(aValor[2]) == "N"
			
			aAux := aClone( aValor[1] )
			
			If PLSALIASEX("B1N")
				
				//Valorar considerando grau de participaГЦo
				If B1N->(FieldPos("B1N_CODREC")) > 0
					aUnd := {}
					
					If !EMPTY(&( cAliasIte+"->"+cAliasIte+"_GRAUPA" ))
						
						dbSetOrder(1)
						If dbSeek(xFilial("BD4") + PlsIntPad()+&( cAliasIte+"->"+cAliasIte+"_CODTAB" ) + &( cAliasIte+"->"+cAliasIte+"_CODPAD" ) + &( cAliasIte+"->"+cAliasIte+"_CODPRO" ))
							
							While BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4") + PlsIntPad()+ &( cAliasIte+"->"+cAliasIte+"_CODTAB" ) + &( cAliasIte+"->"+cAliasIte+"_CODPAD" ) + &( cAliasIte+"->"+cAliasIte+"_CODPRO" )
								If BD4->BD4_CODTPA ==  &( cAliasIte+"->"+cAliasIte+"_GRAUPA" )
									AADD(aUnd, aAux[aScan(aRdas,{|x| x[1] == BD4->BD4_CODIGO})])
								EndIf
								BD4->(DbSkip())
							EndDo
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se tem Fator de Reembolso
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			nFator := CalcFat(aDadUsr[11],aDadUsr[12],&( cAliasIte+"->"+cAliasIte+"_CODPAD" ),&( cAliasIte+"->"+cAliasIte+"_CODPRO" ),aDadUsr[37])
			
			lAneste:= If(Type(cAliasCab+"_REEANE") <> "U",If(&(cAliasIte+"->"+cAliasCab+"_REEANE")== "1",.T.,.F.),.F.)
			
			aRet := PlCalcReemb(IIf(EMPTY(aUnd),aAux,aUnd),"2",aValor[5],{},nFator,lAneste,&( cAliasIte+"->"+cAliasIte+"_VLRAPR" ),aDadUsr[2],&( cAliasIte+"->"+cAliasIte+"_DATPRO" ),&( cAliasIte+"->"+cAliasIte+"_HORPRO" ),&(cAliasCab+"->"+cAliasCab+"_NOMUSR"),nil,&( cAliasIte+"->"+cAliasIte+"_SEQUEN" ),&( cAliasIte+"->"+cAliasIte+"_CODPAD" ),&( cAliasIte+"->"+cAliasIte+"_CODPRO" ),&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ),&(cAliasCab+"->"+cAliasCab+"_NUMLIB"),&( cAliasIte+"->"+cAliasIte+"_CONSVL" ))
			
			//Valor da coparticipacao
			aCalCop := PLSCALCCOP(	&( cAliasIte+"->"+cAliasIte+"_CODPAD" ),&( cAliasIte+"->"+cAliasIte+"_CODPRO" ),&( cAliasCab+"->"+cAliasCab+"_MESPAG" ),&( cAliasCab+"->"+cAliasCab+"_ANOPAG" ),&( cAliasCab+"->"+cAliasCab+"_CODRDA" ),&( cAliasCab+"->"+cAliasCab+"_CODESP" ),"",&( cAliasCab+"->"+cAliasCab+"_CODLOC" ),&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ),;
									&( cAliasIte+"->"+cAliasIte+"_DATPRO" ),.F.,"2",0,&( cAliasCab+"->"+cAliasCab+"_GRPINT" ),aDadUsr,&( cAliasCab+"->"+cAliasCab+"_PADINT" ),&( cAliasCab+"->"+cAliasCab+"_PADCON" ),nil,'2',&( cAliasIte+"->"+cAliasIte+"_VLRAPR" ),.T.,.F.,&( cAliasIte+"->"+cAliasIte+"_HORPRO" ),aRdas,;
									&( cAliasCab+"->"+cAliasCab+"_OPERDA" ),&( cAliasCab+"->"+cAliasCab+"_TIPPRE" ),&( cAliasIte+"->"+cAliasIte+"_PROREL" ),&( cAliasIte+"->"+cAliasIte+"_PRPRRL" ),{},&( cAliasIte+"->"+cAliasIte+"_NIVAUT" ),&( cAliasIte+"->"+cAliasIte+"_CHVNIV" ),nil,nil,&( cAliasCab+"->"+cAliasCab+"_CID" ),nil,"04",,,,,,,,,,,,,,,,,&( cAliasCab+"->"+cAliasCab+"_REGINT" ),&( cAliasCab+"->"+cAliasCab+"_TIPPAC" ),aValor)
			
			
			nVlrBPR := aValor[2]
			nVlrAPR	:= &( cAliasIte+"->"+cAliasIte+"_VLRAPR" )
			nPerCPF := aCalCop[5]
			
			&( cAliasIte+"->"+cAliasIte+"_VLRBPR" ):= nVlrBPR
			&( cAliasIte+"->"+cAliasIte+"_PERCPF" ):= nPerCPF
			
			if empty(&( cAliasIte+"->"+cAliasIte+"_GRAUPA" ))
				
				//Cons.Vlr.Apr 0=NЦo;1=Sim
				if &( cAliasIte+"->"+cAliasIte+"_CONSVL" ) <> '1'
					
					nVlrBPR := Iif(nVlrAPR < nVlrBPR, nVlrAPR, nVlrBPR)
					
					&( cAliasIte+"->"+cAliasIte+"_VLRMAN" ):= nVlrBPR
					
					&( cAliasIte+"->"+cAliasIte+"_VLRGLO" ):= Iif(nVlrAPR > nVlrBPR,(nVlrAPR - nVlrBPR),0)
					
					&( cAliasIte+"->"+cAliasIte+"_VLRPAG" ):= nVlrBPR - round( (nVlrBPR * nPerCPF) / 100, 2 )
					
					&( cAliasIte+"->"+cAliasIte+"_VLRBPF" ):= nVlrBPR
					
					&( cAliasIte+"->"+cAliasIte+"_VLABPF" ):= round( (nVlrBPR * nPerCPF) / 100, 2)
					
					&( cAliasIte+"->"+cAliasIte+"_VLRTPF" ):= round( (nVlrBPR * nPerCPF) / 100, 2)
					
				else
					
					&( cAliasIte+"->"+cAliasIte+"_VLRMAN" ):= nVlrAPR
					
					&( cAliasIte+"->"+cAliasIte+"_VLRGLO" ):= 0
					
					&( cAliasIte+"->"+cAliasIte+"_VLRPAG" ):= nVlrAPR - round( ( nVlrAPR * nPerCPF) / 100, 2)
					
					&( cAliasIte+"->"+cAliasIte+"_VLRBPF" ):= nVlrAPR
					
					&( cAliasIte+"->"+cAliasIte+"_VLABPF" ):= round( (nVlrAPR * nPerCPF) / 100, 2)
					
					&( cAliasIte+"->"+cAliasIte+"_VLRTPF" ):= round( (nVlrAPR * nPerCPF) / 100, 2)
					
				endIf
				
			else
				
				&( cAliasIte+"->"+cAliasIte+"_VLRBPR" ):= aRet[2,5]
				
				&( cAliasIte+"->"+cAliasIte+"_VLRMAN" ):= aRet[2,1]
				
				&( cAliasIte+"->"+cAliasIte+"_VLRGLO" ):= aRet[2,3]
				
				&( cAliasIte+"->"+cAliasIte+"_VLRPAG" ):= aRet[2,1] - round( (aRet[2,1] * nPerCPF) / 100, 2)
				
				&( cAliasIte+"->"+cAliasIte+"_VLRBPF" ):= aRet[2,1]
				
				&( cAliasIte+"->"+cAliasIte+"_VLABPF" ):= round( (aRet[2,5] * nPerCPF) / 100, 2)
				
				&( cAliasIte+"->"+cAliasIte+"_VLRTPF" ):= round( (aRet[2,5] * nPerCPF) / 100, 2)
				
			endIf
			
		endIf
		
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se for evolucao																		Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lEvolucao .And. lSenhaGrv
		&( cAliasIte+"->"+cAliasIte+"_SENHA" ) := PLSSenAut( If( Empty(cAliasIte+"->"+cAliasIte+"_DATPRO"),dDataBase,cAliasIte+"->"+cAliasIte+"_DATPRO" ) )
	EndIf
	
	If !lEvolucao
		
		If (cAliasIte)->(FieldPos(cAliasIte+"_NRTROL")) > 0 .and. (cAliasCab)->(FieldPos(cAliasCab+"_NRTROL")) > 0    .and. (cAliasCab)->(FieldPos(cAliasCab+"_NRAOPE"))> 0 .and. (cAliasIte)->(FieldPos(cAliasIte+"_NRAOPE")) > 0
			
			If Len(&(cAliasIte+"->"+cAliasIte+"_NRTROL")) > 0 .And. Len(&(cAliasCab+"->"+cAliasCab+"_NRTROL")) > 0 .And. !Empty(&(cAliasIte+"->"+cAliasIte+"_NRTROL")) .And. !Empty(&(cAliasCab+"->"+cAliasCab+"_NRAOPE"))
				&( cAliasIte+"->"+cAliasIte+"_NRAOPE" ) := &(cAliasCab+"->"+cAliasCab+"_NRAOPE")
			EndIf
			
		Endif
		
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Negada
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Nao Autorizada
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	&( cAliasIte+"->"+cAliasIte+"_STATUS" ) := "0"
	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_SALDO') )" ) > 0
		&( cAliasIte+"->"+cAliasIte+"_SALDO" )  := 0
	EndIf

	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_IMGSTA') )" ) > 0 
		&( cAliasIte+"->"+cAliasIte+"_IMGSTA" ) := "DISABLE"
	EndIf 

	//Atualizando BE2 de Acordo com a BEJ	
	BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
	If lIntern .And. BE2->( MsSeek( xFilial("BE2")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )
		BE2->( RecLock("BE2",.F.) )													
			BE2->BE2_STATUS := "0"
			BE2->BE2_QTDPRO := BEJ->BEJ_QTDPRO
			BE2->BE2_AUDITO := "0"
		BE2->( msUnlock() )				
	EndIf

EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Nao esta mais em auditoria...
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
&( cAliasIte+"->"+cAliasIte+"_AUDITO" ) := "0"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё via e percentual de via
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_VIA') )" ) > 0 .AND. &( cAliasIte+"->( FieldPos('"+cAliasIte+"_PERVIA') )" ) > 0
	&( cAliasIte+"->"+cAliasIte+"_VIA" ) 		:= cVia
	&( cAliasIte+"->"+cAliasIte+"_PERVIA" )	:= nPerVia
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Nao esta mais em pendencia...
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_PENDEN') )" ) > 0
	&( cAliasIte+"->"+cAliasIte+"_PENDEN" ) := "0"
Endif

If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_CODAUD') )" ) > 0
	&( cAliasIte+"->"+cAliasIte+"_CODAUD" ) := cCodAud
	&( cAliasIte+"->"+cAliasIte+"_NOMAUD" ) := cNomAud
Endif
	
If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_VLRUNA') )" ) > 0
	&( cAliasIte+"->"+cAliasIte+"_VLRUNA" ) := nVlrApr
Endif

If lVLRPRO
	
	If cAliasIte != "B4C"
		&( cAliasIte+"->"+cAliasIte+"_VLRAPR" ) := nVlrApr
	EndIf
	
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se o campo bvx_qtdpro esta em memoria atualiza o conteudo dos campos
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lQTDPRO .And. cParecer == "0"
	
	If cAliasIte != "BE2"
		&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ) := nQtdPro
	Else
	
 		If ! lIntern .and. ! lEvolucao  
			&( cAliasIte+"->"+cAliasIte+"_QTDPRO" ) := nQtdPro
			&( cAliasIte+"->"+cAliasIte+"_SALDO" )  := nQtdPro
		EndIf
	
	EndIf
	
	If lIntern
		
		//Atualizando BE2 de Acordo com a BEJ	
		BE2->( DbSetOrder(1) ) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
		If BE2->( MsSeek( xFilial("BE2")+BEJ->(BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN) ) )
			BE2->( RecLock("BE2",.F.) )													
				BE2->BE2_STATUS := "1"
				BE2->BE2_QTDPRO := BEJ->BEJ_QTDPRO
				BE2->BE2_AUDITO := "0"
			BE2->( msUnlock() )				
		endif
		
		BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
		If BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) )
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё ATUALIZA BE4																	     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dbSelectArea("BR8")
			dbSetOrder(1)
			
			If !lOldAudit .And. B72->(FieldPos("B72_DIAAUT")) > 0 .and. M->B72_DIAAUT > 0
				
				If M->B72_DIAAUT >= 0
					BE4->( RecLock("BE4",.F.) )
					BE4->BE4_DIASIN := M->B72_DIAAUT
					BE4->( msUnlock() )
				EndIf
				
			ElseIf BR8->( MsSeek(xFilial("BR8")+BEJ->BEJ_CODPAD+BEJ->BEJ_CODPRO) )
				If BR8->BR8_TPPROC=='4'
					BE4->( RecLock("BE4",.F.) )
					If GetNewPar("MV_PL790NE","0") == "1" .And. B72->(FieldPos("B72_QTDAUT")) > 0 .And. !IsInCallStack("PLS790DBCLICK")
						BE4->BE4_DIASIN := M->B72_QTDAUT
					Else
						BE4->BE4_DIASIN := BEJ->BEJ_QTDPRO
					EndIf
					If !Empty(BE4->BE4_NRTROL) .And. BE4->BE4_OPESOL <> PlsIntPad() .And. GetNewPar("MV_PTUDAUD",0) <> 0
						BE4->BE4_DATVAL := dDataBase+GetNewPar("MV_PTUDAUD",0)
					ElseIf GetNewPar("MV_PLALTDT",.T.) 
						BE4->BE4_DATVAL := dDatabase+GetNewPar("MV_PLPRZAI",30)
					Endif
					BE4->BE4_DIASSO := BEJ->BEJ_QTDSOL
					BE4->( msUnlock() )
				Endif
			Endif
		Endif
		
	ElseIf lEvolucao
		
		BE4->( DbSetOrder(2) )//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
		If BE4->( MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT) ) )
			dbSelectArea("BR8")
			dbSetOrder(1)
			If BR8->( MsSeek(xFilial("BR8")+BQV->BQV_CODPAD+BQV->BQV_CODPRO) )
				If BR8->BR8_TPPROC=='4'
					BE4->( RecLock("BE4",.F.) )
					If GetNewPar("MV_PL790NE","0") == "1" .And. B72->(FieldPos("B72_QTDAUT")) > 0 .And. !IsInCallStack("PLS790DBCLICK")
						BE4->BE4_DIASPR := M->B72_QTDAUT
						If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"
							If Empty(BE4->BE4_DTALTA)
								BE4->BE4_DTALTA:=BE4->BE4_PRVINT+M->B72_QTDAUT
							Else
								BE4->BE4_DTALTA:=BE4->BE4_DTALTA+M->B72_QTDAUT
							Endif
						Endif
						
					Else
						BE4->BE4_DIASPR := BEJ->BEJ_QTDPRO
						If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"
							If Empty(BE4->BE4_DTALTA)
								BE4->BE4_DTALTA:=BE4->BE4_PRVINT+BEJ->BEJ_QTDPRO
							Else
								BE4->BE4_DTALTA:=BE4->BE4_DTALTA+BEJ->BEJ_QTDPRO
							Endif
						Endif
					EndIf
					BE4->( msUnlock() )
					
					
				Endif
			Endif
		Endif
		
	ElseIf lProrrog
		B4Q->( DbSetOrder(1) )//B4Q_FILIAL + B4Q_OPEMOV + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
		If B4Q->( MsSeek(xFilial("B4Q") + &(cChaveAju) ) ) 
			
			BR8->(dbSetOrder(1))
			If B72->(FieldPos("B72_DIAAUT")) > 0 .and. M->B72_DIAAUT > 0
				
				B4Q->( RecLock("B4Q",.F.) )
				B4Q->B4Q_QTDADA := M->B72_DIAAUT
				B4Q->( msUnlock() )
				
				BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
				If BE4->(msSeek(xFilial("BE4")+B4Q->B4Q_GUIREF))
					
					BE4->( RecLock("BE4",.F.) )
					
					BE4->BE4_DIASPR := M->B72_QTDAUT
					
					If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"
						If Empty(BE4->BE4_DTALTA)
							BE4->BE4_DTALTA := BE4->BE4_PRVINT+M->B72_DIAAUT
						Else
							BE4->BE4_DTALTA := BE4->BE4_DTALTA+M->B72_DIAAUT
						Endif
					Endif
					
					
					BE4->( msUnlock() )
					
				EndIf
				
			ElseIf BR8->( MsSeek(xFilial("BR8")+BQV->BQV_CODPAD+BQV->BQV_CODPRO) )
				If BR8->BR8_TPPROC=='4'
					
					B4Q->( RecLock("B4Q",.F.) )
					
					B4Q->B4Q_QTDADA := M->B72_QTDAUT
					
					B4Q->( msUnlock() )
					
					BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
					If BE4->(msSeek(xFilial("BE4")+B4Q->B4Q_GUIREF))
						
						BE4->( RecLock("BE4",.F.) )
						
						If GetNewPar("MV_PL790NE","0") == "1" .And. B72->(FieldPos("B72_QTDAUT")) > 0
							
							BE4->BE4_DIASPR := M->B72_QTDAUT
							
							If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"
								If Empty(BE4->BE4_DTALTA)
									BE4->BE4_DTALTA := BE4->BE4_PRVINT+M->B72_QTDAUT
								Else
									BE4->BE4_DTALTA := BE4->BE4_DTALTA+M->B72_QTDAUT
								Endif
							Endif
							
						Else
							
							BE4->BE4_DIASPR := BQV->BQV_QTDPRO
							If BAU->(FieldPos("BAU_GRALAU")) > 0  .AND.  BAU->BAU_GRALAU=="1"
								If Empty(BE4->BE4_DTALTA)
									BE4->BE4_DTALTA:=BE4->BE4_PRVINT+BQV->BQV_QTDPRO
								Else
									BE4->BE4_DTALTA:=BE4->BE4_DTALTA+BQV->BQV_QTDPRO
								Endif
							Endif
							
						EndIf
						
						BE4->( msUnlock() )
						
					EndIf
					
				Endif
			Endif
		Endif
		
	EndIf
	
EndIf

&( cAliasIte+"->( MsUnlock() )" )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se o campo bvx_qtdpro esta em memoria atualiza o conteudo dos campos
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lQTDPRO .And. cParecer == "0"
	If &( cAliasIte+"->( FieldPos('"+cAliasIte+"_SALDO') )" ) > 0 .And. &( cAliasIte+"->( FieldPos('"+cAliasIte+"_LIBERA') )" ) > 0 .And. &( cAliasIte+"->"+cAliasIte+"_LIBERA" ) == '1'
		PLSATUSS( nil,!(cAliasIte == "BE2" .AND. !lIntern .AND. !lEvolucao .AND. BEA->BEA_ORIGEM == "2"),.F.,nQtdPro,,,,,,(cAliasIte)->( Recno() ) )
	EndIf
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Para atualizar o saldo e o status da liberacao quando form execucao vinda de solicitacaoЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cAliasIte == 'BE2' .And. cParecer == "0"
	cNrLibOrinal 	:= Iif( BE2->( FieldPos('BE2_NRLBOR') ) > 0,BE2->BE2_NRLBOR,"")
	cSequen 	 	:= BE2->BE2_SEQUEN
	
	If !Empty( cNrLibOrinal )
		
		nRecBEA := BEA->( Recno() )
		nRecBE2 := BE2->( Recno() )
		
		BEA->( DbSetOrder(1) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
		If BEA->( MsSeek( xFilial("BEA")+cNrLibOrinal ) )
			BE2->( DbSetOrder(1) )//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
			If BE2->( MsSeek( xFilial("BE2")+cNrLibOrinal ) )
				
				While !BE2->( Eof() ) .And. cNrLibOrinal == BE2->(BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)
					AaDd( aMatIte,{ BE2->BE2_SEQUEN, BE2->( Recno() ) , BE2->BE2_SALDO } )
					BE2->( DbSkip() )
				EndDo
				
				If ( nPos := aScan(aMatIte,{ |x| x[1] == cSequen } ) ) > 0
					BE2->( DbGoTo( aMatIte[nPos,2] ) )
					
					If nQtdPro > BE2->BE2_SALDO
						nSaldo := 0
					Else
						nSaldo := BE2->BE2_SALDO - nQtdPro
					Endif
					
					cStaLib 		:= Iif(nSaldo==0,"2","1")
					aMatIte[nPos,3]	:= nSaldo
					cChvLib 		:= BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN )
					
					PLSATUSS(,,,nSaldo,cStaLib,,cChvLib)
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se tem algum item com saldo										   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				lStaCab := .T.
				For nI:=1 To Len(aMatIte)
					If aMatIte[nI,3] > 0
						lStaCab := .F.
						Exit
					EndIf
				Next
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o stalib do cabecalho												   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lStaCab
					PLSATUCS()
				EndIf
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Volta ao registro original													   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BE2->( DbGoTo(nRecBE2) )
		BEA->( DbGoTo(nRecBEA) )
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando e o ultimo procedimento auditado e existe um autorizado conclui 		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lUmAut .And. lEvolucao
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Salva o recno																   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nRec := &( cAliasIte+"->( Recno() )" )
	cCodTran := &( cAliasIte+"->"+cAliasIte+"_NRTROL" )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ajusta no primeiro															   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	&( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
	&( cAliasIte+"->( MsSeek('"+xFilial(cAliasIte)+&( cChaveAju )+"' ) )" )
	cChave := &( cChaveAju )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё conclui transacao															   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !&( cAliasIte+"->( Eof() )" ) .And. cChave == &( cChaveAju )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё ATUALIZA																   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If &(cAliasIte+"->( FieldPos('"+cAliasIte+"_TRACON') )") > 0 .And. &(cAliasIte+"->( FieldPos('"+cAliasIte+"_OLNAUD') )") > 0
			If &( cAliasIte+"->"+cAliasIte+"_TRACON" ) <> "1" .And. &( cAliasIte+"->"+cAliasIte+"_NRTROL" ) == cCodTran
				&( cAliasIte+"->( RecLock('"+cAliasIte+"',.F.) )" )
				&( cAliasIte+"->"+cAliasIte+"_TRACON" ) := "1" 	// Conclui
				&( cAliasIte+"->"+cAliasIte+"_OLNAUD" ) := "0" 	// Nao esta mais na auditoria
				&( cAliasIte+"->( MsUnlock() )" )
			EndIf
		EndIf
		&( cAliasIte+"->( DbSkip() )" )
	EndDo
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Retorna o recno																   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	&( cAliasIte+"->( DbGoTo("+Str(nRec)+") )" )
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se informado o motivo auditoria antiga se vazio auditoria nova
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !Empty(cMotivo)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё ATUALIZA CRITICA														   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	&( cAliasCri+"->( DbSetOrder(1) )" ) //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
	If &( cAliasCri+"->( MsSeek('"+xFilial(cAliasCri)+&( cChaveIte )+"' ) )" )
		While !&( cAliasCri+"->( Eof() )" ) .And. &( cChaveCri ) == &( cChaveIte )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё ATUALIZA																   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			&( cAliasCri+"->( RecLock('"+cAliasCri+"',.F.) )" )
			If M->BVX_PARECE == "0" .Or. Empty( &( cAliasCri+"->"+cAliasCri+"_CODGLO" ) )	 //Liberada
				&( cAliasCri+"->( DbDelete() )" )
			Else 					   													     //Negada
				If !lAchoUm
					lAchoUm := .T.
					If !Empty(M->BVX_MOTIVO)
						&( cAliasCri+"->"+cAliasCri+"_CODGLO" ) := M->BVX_MOTIVO
						&( cAliasCri+"->"+cAliasCri+"_DESGLO" ) := Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+M->BVX_MOTIVO,"BCT_DESCRI")
						&( cAliasCri+"->"+cAliasCri+"_INFGLO" ) := ""
						If !Empty(PlsPtuGet( "NRTROL",aProAud[oOcorr:nAt] )) .And. &(cAliasCri+'->( FieldPos("'+cAliasCri+'_CODEDI") ) > 0')
							&( cAliasCri+"->"+cAliasCri+"_CODEDI" )	 := Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+M->BVX_MOTIVO,"BCT_CODED2")
						EndIf
					EndIf
				Else
					&( cAliasCri+"->( DbDelete() )" )
				EndIf
			EndIf
			&( cAliasCri+"->( DbSkip() )" )
			&( cAliasCri+"->( MsUnlock() )" )
		EndDo
	EndIf

ElseIf cParecer == "0" 

	////////////////////////////////////////////////////////////////////////////////
	//Ё Autorizado																  //
	////////////////////////////////////////////////////////////////////////////////
	TCSQLEXEC(cSql)
EndIf 
		
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSAUDON  ╨Autor  ЁAlexander			 ╨ Data Ё  22/12/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     |Rotina para enviar e verificar o retorno de guias de interc.╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё PTU-ONLINE                                                 ╨╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSAUDON(cChave,cAliasCab,cAliasIte,cAliasCri,cParecer,cCodPro,lEvolucao,nRecno,lEnvTds)
LOCAL nI
LOCAL cTipo
LOCAL cOpeOri
LOCAL cTranOri
LOCAL cMsgLivre
LOCAL cOpeUsu
LOCAL nPosCri
LOCAL nJ
LOCAL TpTab
LOCAL cTpTran
LOCAL lUmAut		:= .F.
LOCAL cCodPad  		:= SubStr( GETMV("MV_PLSTBPD") ,1,2)
LOCAL cCodProIte	:= ""
LOCAL aRetOln       := {}
LOCAL lRet			:= .T.
LOCAL aDadSeq		:= {}
LOCAL aDados		:= {}
LOCAL aRet 			:= {}
LOCAL aProcAux		:= {}
LOCAL aProcTemp     := {}
Local aRetBTU       := {}
LOCAL cINSIST   	:= "0"
LOCAL cSolRev   	:= ""
LOCAL cSql          := ""
LOCAL cSenha        := ""
LOCAL cCodRDA 		:= &( cAliasCab+"->"+cAliasCab+"_CODRDA" )
LOCAL cCodESP 		:= &( cAliasCab+"->"+cAliasCab+"_CODESP" )
LOCAL cCDPFSO 		:= &( cAliasCab+"->"+cAliasCab+"_CDPFSO" )
LOCAL cCid    		:= &( cAliasCab+"->"+cAliasCab+"_CID" )
LOCAL dDataProc     := &( cAliasCab+"->"+cAliasCab+"_DATPRO" )
LOCAL cNrAutN 		:= Iif( Type( "'"+cAliasCab+"->"+cAliasCab+"_NRTROL"+"'" ) == "C",&( cAliasCab+"->"+cAliasCab+"_NRTROL" ),"0" )
LOCAL cMatric 		:= &( cAliasCab+"->("+cAliasCab+"_OPEUSR+"+cAliasCab+"_CODEMP+"+cAliasCab+"_MATRIC+"+cAliasCab+"_TIPREG+"+cAliasCab+"_DIGITO)" )
LOCAL cViaCartao	:= Iif( Type("'"+cAliasCab+"->"+cAliasCab+"_VIACAR"+"'") == "N" , AllTrim( Str( &( cAliasCab+"->"+cAliasCab+"_VIACAR" ) ) ) ,0 )
LOCAL aCritica		:= {}
LOCAL nRecBAU		:= BAU->( Recno() )
LOCAL nDiasAudit    := GetNewPar("MV_PTUDAUD",0)
LOCAL lEnviaVld     := .F.
LOCAL lConverProc   := GETMV("MV_PTUTAB2",.T.)
LOCAL cCodTab 		:= SubStr( GETMV("MV_PLSTBPD") ,1,2)
LOCAL cCodTab2		:= GetNewPar("MV_PTUTAB2","02")
LOCAL lTrocaTran    := .F.
LOCAL nCont         := 0
LOCAL lFindPact     := .F.
LOCAL cCodProPac    := ""
LOCAL cCodPadPac    := ""
LOCAL cIdent        := ""
LOCAL cOpeSol       := ""
LOCAL cDecItem      := ""
LOCAL cQtdItem      := ""
LOCAL cSenhaOp      := "" 
LOCAL cMsgXsdErr    := ""
LOCAL lPTUOn70      := Alltrim(GetNewPar("MV_PTUVEON","35")) >= "70"
LOCAL cMsg          := ""
LOCAL nX            := 0
LOCAL aRetWeb       := {}
LOCAL cCodTraPro    := ""
LOCAL cCodUniOri    := ""
DEFAULT nRecno      := 0
DEFAULT lEnvTds     := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega a operadora origem													 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->( DbSetOrder(1) )//BAU_FILIAL + BAU_CODIGO
BAU->( MsSeek( xFilial("BAU")+cCodRDA ) )
cOpeOri := BAU->BAU_CODOPE
BAU->( DbGoTo(nRecBAU) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Prepara para tratar a auditoria no ptu-online							 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cChave)
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se e uma transacao do ptu-online								|
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !Empty( cNrAutN )
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Posiciona no Item													       |
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  &( cAliasIte+"->( DbSetOrder(1) )" ) //_FILIAL + _?????? + _ANO??? + _MES??? + _NUM??? + _SEQUEN
	  If &( cAliasIte+"->( MsSeek( '"+xFilial(cAliasIte)+cChave+"' ) )")
	     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	     //Ё Retorna se o ultimo procedimento e a quantidade de procedimentos         |
	     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		 aRet := PLSGUIAAud( cChave ,cParecer, cCodPro, cAliasIte,lEvolucao,nil,nRecno,.T.,nil,lEnvTds )
	     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	     //Ё Verifica se e o ultimo item da guia									  |
	     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		 If aRet[1] .And. aRet[3] == 1
		    If (IIF (lEnvTds,.T.,Aviso(STR0115, STR0116,{ STR0117, STR0118 }, 2 ) == 1)) //"AtenГЦo"###"Ultimo procedimento da Guia de Intercambio, Deseja enviar RESPOSTA?"###"Sim"###"Nao"
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Verifica somente os procedimentos referente a ultima transacao    	    |
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   aArea := &(cAliasIte+'->(GetArea())')
			   &(cAliasIte)->( dbGoto(nRecno) )
			   For nCont := 1 to len(aRet[4])
			       If Alltrim(aRet[4][nCont][8]) == Alltrim(&(cAliasIte+"->"+cAliasIte+"_NRTROL"))
			           Aadd(aProcTemp,aRet[4][nCont])
			       EndIf
			   Next
			   aRet[4] := aProcTemp
			   RestArea(aArea)
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Pega a atransacao de origem e destino									|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   cTranOri := AllTrim( &( cAliasCab+"->"+cAliasCab+"_NRTROL" ) )
			   cOpeSol  := AllTrim( &( cAliasCab+"->"+cAliasCab+"_OPESOL" ) )
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Implementa as Matrizes												    |
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   aDadSeq := PlsGetBSA( cTranOri,cOpeSol )
			   aDados  := aClone(aDadSeq[1])
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Se evolucao de SADT troca transacao  								    |
			   //| DAHER - AGORA O TROCA TRANSACAO TAMBEM OCORRE QUANDO EH UM COMPLEMENTO DE|
			   //| AUDITORIA DE UMA INTERNACAO POR ISSO TEM O "BEA#BE4"						|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If cAliasCab $ "BEA#BE4" .And. cAliasIte == "BQV" .And. &(cAliasIte+'->( FieldPos("'+cAliasIte+'_NRTROL") ) > 0')
				  cTranOri := PlsPtuGet( "NRTROL",aProAud[oOcorr:nAt] )
				  lTrocaTran := .T.
			   EndIf
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Em caso de complemento, verifica a transacao do procedimento importado  	|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If &(cAliasIte+'->( FieldPos("'+cAliasIte+'_NRTROL") ) > 0')
			       aArea := &(cAliasIte+'->(GetArea())')
			       &(cAliasIte)->( dbGoto(nRecno) )
			       nPos := Ascan(aDados,{|x| x[1] == "NR_IDENT_O"})
			       If nPos > 0
			           aDados[nPos][2] := Alltrim(&(cAliasIte+'->'+cAliasIte+'_NRTROL'))
			       EndIf
			       If cAliasIte == "BE2"
			           DbSelectArea("BEA")
			           DbSetOrder(2)//BEA_FILIAL+BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
			           If BEA->(DbSeek(xFilial("BEA")+BE2->(BE2_OPEUSR+BE2_CODEMP+BE2_MATRIC+BE2_TIPREG+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)))
			               If ( &(cAliasCab+"->"+cAliasCab+"_TIPPRE") == GetNewPar("MV_PLSTPIN","OPE") ) .Or. ( GetNewPar("MV_PLSGSAL","0") == "1" )
						       BEA->( RecLock("BEA",.F.) )
						       If ExistBlock("PLS090L1") .And. &("Empty("+cAliasCab+"->"+cAliasCab+"_SENHA)")
							       &(cAliasCab+"->"+cAliasCab+"_SENHA")  := ExecBlock("PLS090L1",.F.,.F.,{iif(BEA->BEA_LIBERA == "1","2","1"),.T.,&(cAliasCab+"->"+cAliasCab+"_DATPRO")} )
							   ElseIf &("Empty("+cAliasCab+"->"+cAliasCab+"_SENHA)")
					     	       &(cAliasCab+"->"+cAliasCab+"_SENHA")  := PLSSenAut(&(cAliasCab+"->"+cAliasCab+"_DATPRO"))
							   Endif
							   If &("Empty("+cAliasCab+"->"+cAliasCab+"_NRAOPE)") .Or. AllTrim(&(cAliasCab+"->"+cAliasCab+"_NRAOPE")) == "0000000000"
					     	       &(cAliasCab+"->"+cAliasCab+"_NRAOPE")  := PLSNRAOPE()    
					     	       If cAliasCab == "BEA" .And. BEA->BEA_TIPGUI == "03"
					     	           BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
					     	           If BE4->(DbSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
					     	               BE4->( RecLock("BE4",.F.) )
			   			   				   BE4->BE4_NRAOPE := &(cAliasCab+"->"+cAliasCab+"_NRAOPE") 
			   				  			   BE4->( msUnlock() )	  	
					     	           EndIf
					     	       EndIf
							   Endif
							   BEA->( msUnlock() )
						   Endif
			           EndIf     
			           
			           cSenhaOP := &(cAliasCab+"->"+cAliasCab+"_NRAOPE")
			           BE2->(DbSetOrder(1))//BE2_FILIAL+BE2_OPEMOV, BE2_ANOAUT, BE2_MESAUT, BE2_NUMAUT, BE2_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
			           If BE2->(MsSeek(xFilial("BE2")+cChave))
					   	   While xFilial("BE2")+cChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) .And. !BE2->(Eof()) 
			   				   BE2->( RecLock("BE2",.F.) )
			   				   BE2->BE2_NRAOPE := cSenhaOP 
			   				   BE2->( msUnlock() )	  
			   				   			   	       
					   	       BE2->(DbSkip())	
					   	   EndDo	 		
			           EndIf    
			           If cAliasCab == "BE4" .Or. (cAliasCab == "BEA" .And. BEA->BEA_TIPGUI == "03")
			               BEJ->(DbSetOrder(1))//BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
			               If BEJ->(MsSeek(xFilial("BEJ")+cChave))
						   	   While xFilial("BEJ")+cChave == BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) .And. !BEJ->(Eof()) 
				   				   BEJ->( RecLock("BEJ",.F.) )
				   				   BEJ->BEJ_NRAOPE := cSenhaOP 
				   				   BEJ->( msUnlock() )	  
				   				   			   	       
						   	       BEJ->(DbSkip())	
						   	   EndDo	 		
			          	   EndIf    
			           EndIf
			           
			           PlsPtuPut("NR_IDENT_D",Strzero(Val(BEA->BEA_NRAOPE),10),aDados)
			       ElseIf cAliasIte == "BQV"
			           If M->BVX_PARECE == "0"
			               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			               //Ё Verifica se ja existe algum procedimento com a transacao informada      	|
			               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			               cSql := " SELECT BQV_SENHA,BQV_NRAOPE FROM "+RetSqlName("BQV")
			               cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
                           cSql += " AND BQV_NRTROL = '"+BQV->BQV_NRTROL+"' "
                           cSql += " AND BQV_NRAOPE NOT IN (' ','0000000000') "                           
                           cSql += " AND D_E_L_E_T_ <> '*' "

                           cSql := ChangeQuery(cSql)
                           dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

                           TmpEvol->(DbGotop())
                           If !TmpEvol->( Eof() )
                               cSenhaOP := Alltrim(TmpEvol->BQV_NRAOPE)
                               cSenha := Alltrim(TmpEvol->BQV_SENHA)
                           EndIf
                           TmpEvol->( dbClosearea() )
                           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			               //Ё Se existir senha informada utiliza, caso nao, gera uma nova senha       	|
			               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			               BQV->( RecLock("BQV",.F.) )
		                   If Empty(cSenhaOP)
		                       &( cAliasIte+"->"+cAliasIte+"_SENHA" ) := PLSSenAut( If( Empty(cAliasIte+"->"+cAliasIte+"_DATPRO"),dDataBase,cAliasIte+"->"+cAliasIte+"_DATPRO" ) )
		                       &( cAliasIte+"->"+cAliasIte+"_NRAOPE" ) := PLSNRAOPE()        
			               Else
			                   &( cAliasIte+"->"+cAliasIte+"_SENHA" ) := cSenha
			                   &( cAliasIte+"->"+cAliasIte+"_NRAOPE" ) := cSenhaOP
			               EndIf
			               BQV->( msUnlock() )

			               cSenhaOP :=  &( cAliasIte+"->"+cAliasIte+"_NRAOPE" )
			               cSenha :=  &( cAliasIte+"->"+cAliasIte+"_SENHA" )
			               
			               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			               //Ё Verifica se ja existe algum procedimento ja respondido sem a senha     	|
			               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			               cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("BQV")
			               cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
                           cSql += " AND BQV_NRTROL = '"+BQV->BQV_NRTROL+"' "
                           cSql += " AND BQV_NRAOPE IN (' ','0000000000') "
                           cSql += " AND BQV_STATUS = '1' "
                           cSql += " AND D_E_L_E_T_ <> '*' "

                           cSql := ChangeQuery(cSql)
                           dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

                           aArea := GetArea()
                           TmpEvol->(DbGotop())
                           While !TmpEvol->( Eof() )
                               BQV->(DbGoTo(TmpEvol->R_E_C_N_O_))
                               BQV->( RecLock("BQV",.F.) )
		                       BQV->BQV_NRAOPE := cSenhaOP
		                       BQV->BQV_SENHA := cSenha
			                   BQV->( msUnlock() )

			                   TmpEvol->(DbSkip())
                           EndDo
                           TmpEvol->( dbClosearea() )
                           RestArea(aArea)
                      Else
                           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		                   //Ё Mesmo negado, verifica se ha procedimento com senha preenchida        	|
    		               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                           cSql := " SELECT BQV_SENHA,BQV_NRAOPE FROM "+RetSqlName("BQV")
                           cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
                           cSql += " AND BQV_NRTROL = '"+BQV->BQV_NRTROL+"' "
                           cSql += " AND BQV_NRAOPE NOT IN (' ','0000000000') "
                           cSql += " AND BQV_STATUS = '1' "
                           cSql += " AND D_E_L_E_T_ <> '*' "

                           cSql := ChangeQuery(cSql)
                           dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

                           TmpEvol->(DbGotop())
                           If !TmpEvol->( Eof() )
                               cSenhaOp := Alltrim(TmpEvol->BQV_NRAOPE)
                               cSenha := Alltrim(TmpEvol->BQV_SENHA)
                           EndIf
                           TmpEvol->( dbClosearea() )
                           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			               //Ё Verifica procedimento liberado sem senha                                	|
			               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                           If Empty(cSenhaOp)
                               cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("BQV")
                               cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
                               cSql += " AND BQV_NRTROL = '"+BQV->BQV_NRTROL+"' "
                               cSql += " AND BQV_NRAOPE IN (' ','0000000000') "
                               cSql += " AND BQV_STATUS = '1' "
                               cSql += " AND D_E_L_E_T_ <> '*' "

                               cSql := ChangeQuery(cSql)
                               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

                               aArea := GetArea()
                               TmpEvol->(DbGotop())
                               If !TmpEvol->( Eof() )
                                   BQV->(DbGoTo(TmpEvol->R_E_C_N_O_))
                                   BQV->( RecLock("BQV",.F.) )
		                           BQV->BQV_SENHA := PLSSenAut( If( Empty(cAliasIte+"->"+cAliasIte+"_DATPRO"),dDataBase,cAliasIte+"->"+cAliasIte+"_DATPRO" ) )
		                           BQV->BQV_NRAOPE := PLSNRAOPE()
			                       BQV->( msUnlock() )
			                       cSenha := BQV->BQV_SENHA
			                       cSenhaOp := BQV->BQV_NRAOPE
                               Else
                                   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			                       //Ё Se nao achou, grava senha do mesmo jeito pois e a chave da transacao de resposta |
			                       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			                       BQV->( RecLock("BQV",.F.) )
		                           If Empty(cSenhaOP)
		                               &( cAliasIte+"->"+cAliasIte+"_SENHA" ) := PLSSenAut( If( Empty(cAliasIte+"->"+cAliasIte+"_DATPRO"),dDataBase,cAliasIte+"->"+cAliasIte+"_DATPRO" ) )
		                               cSenha := &( cAliasIte+"->"+cAliasIte+"_SENHA" )
		                               &( cAliasIte+"->"+cAliasIte+"_NRAOPE" ) := PLSNRAOPE()
		                               cSenhaOp := &( cAliasIte+"->"+cAliasIte+"_NRAOPE" )
		                           EndIf
			                       BQV->( msUnlock() )
                               EndIf
                               TmpEvol->( dbClosearea() )
                               RestArea(aArea)
                           EndIf
                           //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			               //Ё Verifica se ja existe algum procedimento ja respondido sem a senha e atualiza |
			               //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			               If !Empty(cSenhaOp)
			                   cSql := " SELECT R_E_C_N_O_ FROM "+RetSqlName("BQV")
                               cSql += " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
                               cSql += " AND BQV_NRTROL = '"+BQV->BQV_NRTROL+"' "
                               cSql += " AND BQV_NRAOPE  IN (' ','0000000000') "
                               cSql += " AND BQV_STATUS = '1' "
                               cSql += " AND D_E_L_E_T_ <> '*' "

                               cSql := ChangeQuery(cSql)
                               dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpEvol",.T.,.F.)

                               aArea := GetArea()
                               TmpEvol->(DbGotop())
                               While !TmpEvol->( Eof() )
                                   BQV->(DbGoTo(TmpEvol->R_E_C_N_O_))
                                   BQV->( RecLock("BQV",.F.) )
		                           BQV->BQV_NRAOPE := cSenhaOp //PLSNRAOPE()
			                       BQV->( msUnlock() )

			                       TmpEvol->(DbSkip())
                               EndDo
                               TmpEvol->( dbClosearea() )
                               RestArea(aArea)
                           EndIf
                       EndIf

			           PlsPtuPut("NR_IDENT_D",IIf(!Empty(cSenhaOp),cSenhaOp,Strzero(Val(BQV->BQV_NRAOPE),10)) ,aDados)
			       EndIf
			       RestArea(aArea)
			   Else
			       PlsPtuPut("NR_IDENT_D",cTranOri,aDados)
			   EndIf

			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Para o xmov																|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   PlsPtuPut("CTIPREQ","1",aDados)												//Nao gera o numero da transacao origem
		       PlsPtuPut("CUNIDOM",cOpeOri,aDados)							 				//Para qual operadora enviar
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Alimenta adados - Parecer	0=Liberado; 1=Negado; 3=Pendente			|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If BVX->( FieldPos("BVX_SOLREV") ) > 0
				   PlsPtuPut("CD_TRANS","00404",aDados) 									//Resposta da Auditoria.
			   EndIf
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Verifica se envia data de validade, envia somente se houver item autorizadoЁ
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   For nI := 1 to len(aRet[4])
			      If aRet[4,nI,5]=="1"
			          lEnviaVld := .T.
			          Exit
			      EndIf
			   Next
			   If lEnviaVld
			       dDataProc := dDataBase + nDiasAudit//dDataProc := dDataProc + nDiasAudit
			       PlsPtuPut("DT_VALIDAD",Dtos(dDataProc),aDados)  
			       
			       BEA->( RecLock("BEA",.F.) )
				   BEA->BEA_VALSEN := dDataProc
				   BEA->( msUnlock() )
			       
			       If BEA->BEA_TIPGUI == "03"
				       BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
				       If BE4->(MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT))) 
				           BE4->( RecLock("BE4",.F.) )
					       BE4->BE4_DATVAL := dDataProc
				 		   BE4->( msUnlock() )
				       EndIf
			       EndIf
			     
			   Else
			       PlsPtuPut("DT_VALIDAD",Space(8),aDados)
			   EndIf

		       PlsPtuPut("CD_UNI_ORI",cOpeOri,aDados)								     	//Codigo da Unimed Destino da transacao.
		       PlsPtuPut("CD_UNI_DES",PlsIntPad(),aDados)						 			//Codigo da Unimed Destino da transacao (OPERADORA QUE SOLICITOU A TRANSACAO DE ATENDIMENTO).
		       PlsPtuPut("TP_AUTORIZ",'1',aDados)								     	//TIPO DE AUTORIZACAO

		       if BVX->(FieldPos("BVX_MSG")) > 0
		       		cMsgLivre := allTrim(M->BVX_MSG)    
		       else
		       		cMsgLivre := allTrim(M->BVX_MSG01) + " " + allTrim(M->BVX_MSG02)
		       endIf
		       
		       cMsgLivre := subStr(PTURemChr(cMsgLivre),1,128)
		       
			   PlsPtuPut("DS_MENS_LI",cMsgLivre,aDados)										//Msg Livre.
			   
			   If BVX->(FieldPos("BVX_MSG")) > 0
			       PlsPtuPut("DS_LINHA_O",cMsgLivre,aDados)   			//Linha de dados da Unimed Origem.
			   Else
			   	   PlsPtuPut("DS_LINHA_O",PTURemChr(PadR(M->BVX_MSG03,40)),aDados)   						//Linha de dados da Unimed Origem.
			   Endif
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Mostra Log o tipo de transacao que esta chegando						 	Ё
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   PlsPtuLog("***********************************")
			   PlsPtuLog(STR0183) //"INICIO DA TRANSACAO"
			   PlsPtuLog("***********************************")
			   PlsPtuLog("CD_TRANS => "+Upper(PlsPtuGet("CD_TRANS",aDados)))
			   PlsPtuLog("TP_CLIENTE => "+PlsPtuGet("TP_CLIENTE",aDados))
			   PlsPtuLog("CD_UNI_ORI => "+PlsPtuGet("CD_UNI_ORI",aDados))
			   PlsPtuLog("CD_UNI_DES => "+PlsPtuGet("CD_UNI_DES",aDados))
			   PlsPtuLog("NR_IDENT_O => "+PlsPtuGet("NR_IDENT_O",aDados))
			   PlsPtuLog("CD_UNI => "+PlsPtuGet("CD_UNI",aDados))
			   PlsPtuLog("DT_VALIDAD => "+PlsPtuGet("DT_VALIDAD ",aDados))
			   PlsPtuLog("DS_MENS_LI => "+PlsPtuGet("DS_MENS_LI",aDados))
			   PlsPtuLog("***********************************")
			   PlsPtuLog(STR0184) //"PROCEDIMENTOS"
			   PlsPtuLog("***********************************")

			   //Ё Monta o array de procedimentos
			   // caso nao encontre na BR8 vai executar a query na B0T para cada evento.
			   For nI := 1 To Len(aRet[4])
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Procedimento																 |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			        cCodPad    := aRet[4,nI,1]
			        cCodProIte := aRet[4,nI,2]
			        dDatPro    := aRet[4,nI,10]
			        If Len(aRet[4,nI]) >= 11
			        	cDescCrit  := Padr(aRet[4,nI,11],500)
			        Else
			        	cDescCrit  := Padr('',500)
			        Endif
			        lFindPact  := .F.

					//Seek
					//**** verificar esse bloco
					If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodProIte) )
						//Ё0=Procedimento							(0=AMB)
						//Ё1=Material	    						(2=Material)
						//Ё2=Medicamento							(3=Medicamento)
						//Ё3=Taxas									(1=Hospitalar)
						//Ё4=Diarias								(1=Hospitalar)
						//Ё5=Ortese/Protese							(1=Hospitalar)
						//Ё6=Pacote 								(1=Hospitalar)
					    TpTab := Iif(BR8->BR8_TPPROC=='0' .or. Empty(BR8->BR8_TPPROC),'0',Iif(BR8->BR8_TPPROC $ '1/5','2',Iif(BR8->BR8_TPPROC=='2','3',Iif(BR8->BR8_TPPROC=='6','4','1') ) ) ) 
					Else
					
                        cIdent := ""
						cSql := " SELECT B0T_IDENT FROM "+RetSqlName("B0T")
				 		cSql += " WHERE B0T_FILIAL = '" +xFilial("B0T")+"' "
				 		cSql += " AND B0T_NUMSEQ = '"+Alltrim(PlsPtuGet("NR_IDENT_O",aDados))+"' "
                        cSql += " AND B0T_TIPTRA IN ('00600','00605') "
                        cSql += " AND B0T_OPESOL = '"+Alltrim(PlsPtuGet("CD_UNI_ORI",aDados))+"' "
                        cSql += " AND B0T_IDENT <> 'CAB' "
                        cSql += " AND B0T_VARIAV = 'CD_SERVICO' "
                        cSql += " AND B0T_CONTEU = '"+Alltrim(cCodProIte)+"' "
                        cSql += " AND D_E_L_E_T_ <> '*'

                        cSql := ChangeQuery(cSql)
                       	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

                       	TmpPac->(DbGotop())
                        cIdent := TmpPac->B0T_IDENT
                       	TmpPac->( dbClosearea() )

                       	If !Empty(cIdent)
					        cSql := " SELECT B0T_CONTEU FROM "+RetSqlName("B0T")
                            cSql += " WHERE B0T_FILIAL = '" +xFilial("B0T")+"' "
                            cSql += " AND B0T_NUMSEQ = '"+Alltrim(PlsPtuGet("NR_IDENT_O",aDados))+"' "
                            cSql += " AND B0T_TIPTRA IN ('00600','00605') "
                            cSql += " AND B0T_OPESOL = '"+Alltrim(PlsPtuGet("CD_UNI_ORI",aDados))+"' "
                            cSql += " AND B0T_IDENT = '"+cIdent+"' "
                            cSql += " AND B0T_VARIAV = 'TP_TABELA' "
                            cSql += " AND D_E_L_E_T_ <> '*'

                        	cSql := ChangeQuery(cSql)
                       		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

                       		TmpPac->(DbGotop())
                        	TpTab := TmpPac->B0T_CONTEU
                       		TmpPac->( dbClosearea() )
					    EndIf
					EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se troca codigo do pacote   									 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If TpTab == "4"
						cSql := " SELECT BLE_CODOPC, BLE_CPADOC  FROM "+RetSqlName("BLE")+	" BLE, "+RetSqlName("BLD")+" BLD WHERE "
						cSql += "     BLE_FILIAL = '"+xFilial("BLE")+"' "
                        cSql += " AND BLD_FILIAL = '"+xFilial("BLD")+"' "
						cSql += " AND BLD_CODPRO = BLE_CODPRO "
						cSql += " AND BLD_CODPRO = '"+Alltrim(BR8->BR8_CODPSA)+"' "
						cSql += " AND BLE_PRINCI = '1'"
                 		cSql += " AND BLD.D_E_L_E_T_ <> '*' "
                        cSql += " AND BLE.D_E_L_E_T_ <> '*' "

                        cSql := ChangeQuery(cSql)
                       	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

                       	TmpPac->(DbGotop())
                       	While !TmpPac->( Eof() )
                           cCodProPac := Alltrim(TmpPac->BLE_CODOPC)
                           cCodPadPac := Alltrim(TmpPac->BLE_CPADOC)
                           TmpPac->( dbSkip() )
                       	EndDo
                       	TmpPac->( dbClosearea() )

                       	If !Empty(cCodProPac) .And. BR8->( DbSeek(xFilial("BR8")+cCodPadPac+cCodProPac) )
                       		cCodProIte := BR8->BR8_CODPSA
                       		lFindPact  := .T.
                       	EndIf
                    EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Alimenta itens															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					AaDd( aProcAux,{} )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                    //Ё Posiciona no registro do item      				            	   Ё
                    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					&( cAliasIte+"->( DbGoTo("+cValToChar(aRet[4,nI,7])+") )" )
				    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                    //Ё Verifica o TP_TABELA              				            	   Ё
                    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If Alltrim(aRet[4,nI,2]) $ __cCodMedGen
					    PlsPtuPut( "TP_TABELA"	,"3",aProcAux[Len(aProcAux)] )  //Identifica o Tipo de Tabela utilizado no Servico Medico.
					ElseIf Alltrim(aRet[4,nI,2]) $ __cCodMatGen
					    PlsPtuPut( "TP_TABELA"	,"2",aProcAux[Len(aProcAux)] )	 //Identifica o Tipo de Tabela utilizado no Servico Medico.
					ElseIf Alltrim(aRet[4,nI,2]) $ __cCodTaxGen
					    PlsPtuPut( "TP_TABELA"	,"1",aProcAux[Len(aProcAux)] )	 //Identifica o Tipo de Tabela utilizado no Servico Medico.
					ElseIf Alltrim(aRet[4,nI,2]) $ __cCodOpmGen
					    PlsPtuPut( "TP_TABELA"	,"2",aProcAux[Len(aProcAux)] )	 //Identifica o Tipo de Tabela utilizado no Servico Medico.
					Else
					    PlsPtuPut( "TP_TABELA"	,TpTab,aProcAux[Len(aProcAux)] )//Identifica o Tipo de Tabela utilizado no Servico Medico.
					EndIf
                    PlsPtuPut( "DS_MENS_ES"	,Iif(aRet[4,nI,5]=="0",cDescCrit,Space(500)),aProcAux[Len(aProcAux)] )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Usa PE PLPTUITE para trocar codigos de procedimento						 |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If ExistBlock("PLPTUITE")
			            aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodProIte,"ENVSAI","",nil,cCodPad,AllTrim(cTranOri),nil})
     	                PlsPtuPut( "CD_SERVICO"	,aPlPtuIte[2],aProcAux[Len(aProcAux)] )                	//Codigo do Servico.
                    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                    //Ё Converte AMB/CBHPM                            					   Ё
                    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                    ElseIf lConverProc
                      	PLBusProTab(cCodProIte,.F.,,,lConverProc,,,cCodTab,cCodTab2)
					    If BR8->(Found())
					        PlsPtuPut( "CD_SERVICO"	,Alltrim(BR8->BR8_CODPSA),aProcAux[Len(aProcAux)] )	//Codigo do Servico.
						EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                    //Ё Realiza De/Para BR8_CODEDI ou tabela B1M       					   Ё
                    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					ElseIf GetNewPar("MV_PTDPION","0") == "1"
						cCodProIte := PLDeParINT(cCodPad,cCodProIte,dDatPro,,"E")
						PlsPtuPut( "CD_SERVICO"	,cCodProIte,aProcAux[Len(aProcAux)] )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
                    //Ё Realiza De/Para utilizando a tabela BTU       					   Ё
                    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					ElseIf GetNewPar("MV_PTDPION","0") == "2"
				    	aRetBTU := PTUDePaBTU(nil,cCodProIte,cCodPad,.F.,.T.)
				    	If len(aRetBTU) > 0
				    		cCodProIte := aRetBTU[2]
				    	EndIf
				    	PlsPtuPut( "CD_SERVICO"	,cCodProIte,aProcAux[Len(aProcAux)] )	   	   				//Codigo do Servico.
					Else
						PlsPtuPut( "CD_SERVICO"	,cCodProIte,aProcAux[Len(aProcAux)] )	   	   				//Codigo do Servico.
					EndIf

                    If !lFindPact
                        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				     	//Ё Usa PE PLPTUITE para trocar a descricao do procedimento - Normal    	 |
					    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                        If ExistBlock("PLPTUITE")
					          aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodProIte,"ENVDES",Padr(&(cAliasIte+"->"+cAliasIte+"_DESPRO"),80),nil,cCodPad,AllTrim(cTranOri),nil})
					          PlsPtuPut( "DS_SERVICO"	,aPlPtuIte[3],aProcAux[Len(aProcAux)] )	            	//Descricao do procedimento
					      Else
     	        		      PlsPtuPut( "DS_SERVICO"	,IIF((!Empty(&(cAliasIte+"->"+cAliasIte+"_DESPRO"))),Padr(&(cAliasIte+"->"+cAliasIte+"_DESPRO"),80),Padr(BR8->BR8_DESCRI,80)),aProcAux[Len(aProcAux)] )	  	//Descricao do procedimento
                        EndIf
					Else
					    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				     	//Ё Usa PE PLPTUITE para trocar a descricao do procedimento - Pacote    	 |
					    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                        If ExistBlock("PLPTUITE")
					        aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{cCodProIte,"ENVDES",Padr(BR8->BR8_DESCRI,80),nil,cCodPad,AllTrim(cTranOri),nil})
					        PlsPtuPut( "DS_SERVICO"	,aPlPtuIte[3],aProcAux[Len(aProcAux)] )	            	//Descricao do procedimento
					    Else
					        PlsPtuPut( "DS_SERVICO"	,Padr(BR8->BR8_DESCRI,80),aProcAux[Len(aProcAux)] )	  	//Descricao do procedimento
					    EndIf
					EndIf

				 	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se autorizado ou nao													 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   		    cAt := Iif( aRet[4,nI,5]=="1" , "2" , Iif(aRet[4,nI,5]=="0" , "1" , "4" ) )
		   		    
		   
					cDecItem := cValToChar(aRet[4,nI,iif(cAt=="2",6,3)] - Int(aRet[4,nI,iif(cAt=="2",6,3)])) 
					cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
					cQtdItem := cValtoChar(int(aRet[4,nI,iif(cAt=="2",6,3)]) )+"."+cDecItem	   		    
	   	            
	   	            If !lPTUOn70 .Or. (lPTUOn70 .And. cAt == "2") 
            			PlsPtuPut( "QT_SERVICO"	,cQtdItem,aProcAux[Len(aProcAux)] )					//Quantidade de um procedimento mзdico solicitado.
	   		        EndIf
	   		        PlsPtuPut( "QT_AUTORIZ"	,cQtdItem,aProcAux[Len(aProcAux)] )		   		        	
	   		       
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё So se nao for autorizado "2" autorizado "1" -(negado ou pendente)        Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		   		    If cAt <> '2'
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Define se vai pegar critica do procedimento na tabela de criticas		 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						nPosCri := aScan(aRet[5],{ |x| x[1] == aRet[4,nI,2]+aRet[4,nI,4] } )
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Alimenta criticas													     Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						If nPosCri > 0
							For nJ := 1 To 5
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Criticas do procedimento											     Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If nPosCri > 0
									PlsPtuPut( "CD_MENS_E"+AllTrim( Str(nJ) ),RetCodEdi( aRet[5,nPosCri,2] ),aProcAux[Len(aProcAux)] )	//Codigo da Critica
								EndIf
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Mostra o log															 Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If cAt <> "2"
									If !Empty( PlsPtuGet( "CD_MENS_E"+AllTrim( Str(nJ) ),aProcAux[Len(aProcAux)] ) )
										PlsPtuLog("SERVICO =>" + GETMV("MV_PLSTBPD") + '-' + AllTrim( PlsPtuGet( "CD_SERVICO",aProcAux[Len(aProcAux)] ) ) + " ( " + AllTrim( PlsPtuGet( "CD_MENS_E"+AllTrim( Str(nJ) ),aProcAux[Len(aProcAux)] ) ) + " - " + Upper( AllTrim( PlsPtuGet("DS_SERVICO",aProcAux[Len(aProcAux)] ) ) + " ) " ) )
									EndIf
								EndIf
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Altera o codigo do procedimento para nao pegar novamente				 Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If nPosCri > 0
									aRet[5,nPosCri,1] := aRet[5,nPosCri,1]+'*'
								EndIf
								//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
								//Ё Pega outra critica													     Ё
								//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
								If nPosCri > 0
								   nPosCri := aScan(aRet[5],{ |x| x[1] == aRet[4,nI,2]+aRet[4,nI,4] } )
								EndIf
							Next
						EndIf
					EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Se autorizou ou nao													     Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					PlsPtuPut("ID_AUTORIZ",cAt,aProcAux[Len(aProcAux)])
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Mostra log de Autorizacao											 	 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cAt == "2"
					   PlsPtuLog(STR0185+" =>" + GETMV("MV_PLSTBPD") + "-" + AllTrim( PlsPtuGet( "CD_SERVICO",aProcAux[Len(aProcAux)] ) ) + STR0186 ) //"SERVICO"###" - AUTORIZADO"
					   lUmAut := .T.
					ElseIf cAt == "4"  .And. nPosCri == 0
					   PlsPtuLog(STR0185+" =>" + GETMV("MV_PLSTBPD") + "-" + AllTrim( PlsPtuGet( "CD_SERVICO",aProcAux[Len(aProcAux)] ) ) + STR0187 ) //"SERVICO"###" - PENDENTE DE AUDITORIA"
					EndIf
		
				  	PlsPtuPut("SQ_ITEM",IIf(!Empty(aRet[4,nI,12]),aRet[4,nI,12],"99"),aProcAux[Len(aProcAux)])

			   Next
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё msg																		|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   PlsPtuLog("***********************************")
			   PlsPtuLog(STR0188) //"INICIO DO ENVIO DA RESPOSTA"
			   PlsPtuLog("***********************************")
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Faz o tratamento e envio dos registros									|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   aGrvTraPTU := {AllTrim(cTranOri),PlsPtuGet("CD_TRANS",aDados),PlsPtuGet("CD_UNI_ORI",aDados),PlsPtuGet("CD_UNI_DES",aDados),&( cAliasCab+"->"+cAliasCab+"_NOMUSR" ) }
               
			   MsAguarde( {|| aRetOln := PlsPtuOln(aDados,aProcAux,AllTrim(cTranOri)+"A."+Subs(PLSINTPAD(),2,3) ,,.F.,aGrvTraPTU,NIL,NIL,@cMsgXsdErr ) }, STR0220 , STR0125, .F.) //"Aguarde..." //'Comunicando'
	           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Retorno																	|
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   If Len(aRetOln) > 0 

			       If ValType(aRetOln[1]) == "A"  	

			           BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
			           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   			   //Ё 00310 - Erro Inesperado													|
			   		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
				       If PlsPtuGet( "CD_TRANS",aRetOln[1]) == "00310" 

				           If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
						       Aviso( STR0115, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
	                           lRet := .F.
	                       Else
	                           PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
						       Aviso( STR0115,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
				               lRet := .F.	  
				           EndIf
			           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   			   //Ё 00309 - Confirmacao - Guia Inexistente									|
			   		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	            
                       ElseIf PlsPtuGet( "CD_TRANS",aRetOln[1]) == "00309" .And. Alltrim(PlsPtuGet( "TP_IDENTIF",aRetOln[1])) == "2"  
                           Aviso( STR0115,"Guia nЦo processada - Guia inexistente",{ STR0231 }, 2 )
                           lRet := .F.
			           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		   			   //Ё 00309 - Confirmacao - Guia Confirmada									|
			   		   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	        
                       ElseIf PlsPtuGet( "CD_TRANS",aRetOln[1]) == "00309"  
                           lRet := .T.	 
                       EndIf
				       
				   Else
				       lRet := aRetOln[1]
				   EndIf    
				   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Se ok																	Ё
				   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			       If lRet
					  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					  //Ё Atualiza guia, se evolucao de SADT troca o codigo da transacao           Ё
					  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					  cTpTran  := PlsPtuGet("CD_TRANS",aDados)
					  cTranDes := PlsPtuGet("NR_IDENT_D",aDados)
					  If lTrocaTran
					      cTranOri := AllTrim( &( cAliasCab+"->"+cAliasCab+"_NRTROL" ) )
					  EndIf

					  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					  //Ё Retorno																   |
					  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 					  aRetPtu 	:= PLSACOMC(cTranOri,cTranDes,cMsgLivre,{},cTpTran,,,lEvolucao,cOpeSol)
					  cRet 		:= aRetPtu[1]
					  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					  //Ё Mostra no log														       Ё
					  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					  PlsPtuLog("")
					  If !Empty(cRet)
						 PlsPtuLog("***********************************")
					     PlsPtuLog(cRet)
						 PlsPtuLog("***********************************")
						 lRet := .F.
					  EndIf
					  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					  //Ё Exibe msg de retorno															    |
					  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					  PlsPtuLog("***********************************")
					  PlsPtuLog("TRANSACAO FINALIZADA COM SUCESSO!")
					  PlsPtuLog("***********************************")
					  MsgAlert("TRANSACAO FINALIZADA COM SUCESSO!")
					  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					  //Ё Encerra o protocolo de atendimento pendente	 							       |
					  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
					  If GetNewPar("MV_PL395WS","0") == "1"  
						  
						  cCodUniOri := Strzero(Val(PlsPtuGet("CD_UNI_ORI",aDados)),4)
					      B00->(DbSetOrder(5))//B00_FILIAL+B00_NRTROL+B00_OPESOL  
					      If B00->(DbSeek(xFilial("B00")+PlsPtuGet("NR_IDENT_O",aDados)+Space(TamSx3("B00_NRTROL")[1]-len(PlsPtuGet("NR_IDENT_O",aDados)))+cCodUniOri))
 
							  BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
							  BA0->(DbSeek(xFilial("BA0")+cCodUniOri))      
							  
							  cCodTraPro := PLB4JRegTr(PlsIntPad(),PlsPtuGet("CD_UNI_ORI",aDados),"005")		
					          MsAguarde( {|| aRetWeb := PLResAteRN(PlsIntPad(),PlsPtuGet("CD_UNI_ORI",aDados),"",B00->B00_TRAPRE,dDatabase,cUserName,;
					          Substr(B00->B00_MATRIC,1,4),Substr(B00->B00_MATRIC,5,13),B00->B00_COD,"3",B00->B00_NRTROL, cMsgLivre) }, 'Comunicando' , "Aguarde", .F.)  		
					    
					          If aRetWeb[1]
					              
					              cSql := " SELECT MAX(B4I_SEQUEN) SEQUEN FROM "+RetSqlName("B4I")
								  cSql += " WHERE B4I_PROTOC = '"+B00->B00_COD+"'"       
								  cSql += " AND D_E_L_E_T_ = ' ' "
								  cSql := ChangeQuery(cSql)
								    
								  DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , "TMP" , .F. , .T. )
								  DBSelectArea("TMP")
								  TMP->(DBGoTop())
								  If TMP->(!Eof())
								      B4I->(RecLock("B4I",.T.)) 
									  	B4I->B4I_FILIAL  := xFilial("B4I")        
									  	B4I->B4I_SEQUEN  := Soma1(TMP->SEQUEN)
									  	B4I->B4I_PROTOC  := B00->B00_COD
									  	B4I->B4I_MENSAG  := cMsgLivre
									  	B4I->B4I_STATUS  := "3"
									  	B4I->B4I_DATRES  := dDataBase
										B4I->B4I_HORRES  := StrTran(Time(),":","")  
									  	B4I->B4I_USUMAN  := cUserName
									  B4I->(MsUnLock())           
										
									  B00->(RecLock("B00",.F.)) 
									  B00->B00_STAINT  := "3"      
									  B00->(MsUnLock())
								  EndIf
								  TMP->(DbCloseArea())    
								  MsgInfo("Protocolo respondido com sucesso.") 
					          Else
					          	  cMsg   := "NЦo foi possМvel solicitar consultar o Status do Protocolo. CrМticas:"+Chr(10)+Chr(10)
							      For nX := 1 to len(aRetWeb[2])
							   	      cMsg += Alltrim(aRetWeb[2][nX][1])+"-"+Alltrim(aRetWeb[2][nX][2])+Chr(10)
						  		  Next   
						          MsgInfo(cMsg)
						      EndIf    
					      EndIf
					  EndIf
					  
				       
				   EndIf	   
			   Else
			       If !Empty(cMsgXsdErr) 
			   	       MsgInfo(cMsgXsdErr)		
			   	   Else	
				       PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
	                   Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
	               EndIf    
			       lRet := .F.
			   EndIf
			Else
			  lRet := .F.
			EndIf
	     EndIf
	  Else
	     MsgAlert(STR0189+" ("+cAliasIte+"):"+cChave+STR0209) //"Chave do"  //" nao encontrada!"
	  EndIf
   EndIf
Else
	MsgAlert( STR0189+" ("+cAliasIte+") "+STR0190 ) //"Chave do"###"esta em branco!"
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return({lRet,lUmAut})
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790ATU ╨Autor  ЁAlexander			 ╨ Data Ё  11/09/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     |Seleciona os procedimentos em auditoria (sadt,internacao e  ╨╠╠
╠╠╨		     |evolucao )												  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Auditoria                                                  ╨╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790ATU(cMatric,lExit,lPrim)
LOCAL aRet 		:= {}
LOCAL cSQL1 	:= ""
LOCAL cSQL2BEA 	:= ""
LOCAL cSQL3BEA 	:= ""
LOCAL cSQL2BE4	:= ""
LOCAL cSQL3BE4 	:= ""
LOCAL cSQL4 	:= ""
LOCAL cSQL5 	:= ""
LOCAL cSQL6 	:= ''
LOCAL cSQL7 	:= ''
LOCAL lEvoluSADT:= GetNewPar("MV_PLEVSAD","0") == "1"
LOCAL lNrTrol 	:= BE2->(FieldPos("BE2_NRTROL") ) > 0 .And. BQV->( FieldPos("BQV_NRTROL") ) > 0 .And. BE2->( FieldPos("BE2_NRTROL") ) > 0
LOCAL lSeqPTU 	:= BQV->(FieldPos("BQV_SEQPTU")) > 0
Default cMatric	:=""
Default lExit	:= .F.

//Caso os MV_PAR's nЦo estejam com as datas configuradas, reconfigura as variАveis
If Type("MV_PAR01") <> "D" .Or. Type("MV_PAR02") <> "D"
	Pergunte("PLA790",.F.)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Zera																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aProAud 	:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta Query para Alimentar matriz										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BE2_ANOAUT,BE2_MESAUT,BE2_NUMAUT,'Nao' AS PRORRO, "
cSQL += " BE2_OPEUSR AS OPEUSR,BE2_CODEMP AS CODEMP,BE2_MATRIC AS MATRIC,BE2_TIPREG AS TIPREG, "
cSQL += " BE2_DIGITO AS DIGITO,BE2_CODPAD AS CODPAD,BE2_CODPRO AS CODPRO,BE2_DESPRO AS DESPRO, '' AS GUIREF, "
cSQL += " BE2_SEQUEN AS SEQUEN,"+Iif( BE2->( FieldPos("BE2_SOLREV") ) > 0,"BE2_SOLREV","''")+" AS SOLREV,BE2_DATPRO AS DATPRO,BE2_HORPRO AS HORPRO, "
cSQL += " BE2_QTDPRO AS QTDPRO,"+Iif( BE2->( FieldPos("BE2_PENDEN") ) > 0,"BE2_PENDEN","'1'")+" AS PENDEN, "
cSQL += " BE2_NIVCRI AS NIVCRI,BE2_CHVNIV AS CHVNIV, "
cSQL += " 'BEABE2BEG' AS NOMALIAS,"+RetSQLName("BE2")+".R_E_C_N_O_ AS REC,BE2_MATANT AS MATANT,BE2_NOMUSR AS NOMUSR, "
cSQL += " BEA_TRACON AS TRACON,BEA_MSG05 AS RESREV,BEA_COMUNI AS COMUNI,"
cSQL += " BE2_OPEMOV AS OPEMOV,BE2_ANOAUT AS ANOAUTINT,BE2_MESAUT AS MESAUTINT,BE2_NUMAUT AS NUMAUT,BE2_NUMINT AS NUMINT, "
cSQL += " BE2_REGSOL AS REGSOL,BE2_ESTSOL AS ESTSOL,BE2_REGEXE AS REGEXE,BE2_ESTEXE AS ESTEXE, "
cSQL += " BE2_SIGLA  AS SIGLA,BE2_OPERDA AS OPERDA,BE2_CODRDA AS CODRDA,BE2_CID AS CID,BE2_NRAOPE NRAOPE, "
cSQL += " BE2_CODLOC  AS CODLOC, BE2_DESLOC AS DESLOC, BE2_DENREG AS DENTE, BE2_FADENT AS FACE, BEA_OPESOL AS OPESOL  "

If lNrTrol
    cSQL += ", BE2_NRTROL  AS NRTROL "
EndIf

If lSeqPTU
    cSQL += ", BE2_SEQPTU  AS SEQPTU "
EndIf 

cSQL += ", BEA_TIPO    AS TIPO "
cSQL += " FROM "+RetSQLName("BE2")+","+RetSQLName("BEA")

cSQL1 := " WHERE BE2_FILIAL 	= '"+xFilial("BE2")+"' "

If empty(cMatric)
	cSQL1 += "   AND BE2_AUDITO 	= '1' "
	cSQL1 += "   AND BE2_STATUS 	= '0' "
Endif

If !lPrim
	cSQL1 += "   AND BE2_DATPRO >='"+dtos(MV_PAR01)+"' AND BE2_DATPRO <='"+dtos(MV_PAR02)+"' " //dennis
Endif

//Filtra pela AutorizaГЦo
If !Empty (MV_PAR03) .and. !lExit
	cSQL1 += " AND BE2_OPEMOV = '"+Substr(MV_PAR03,01,4)+"'  "
	cSQL1 += " AND BE2_ANOAUT = '"+Substr(MV_PAR03,05,4)+"'  "
	cSQL1 += " AND BE2_MESAUT = '"+Substr(MV_PAR03,09,2)+"'  "
	cSQL1 += " AND BE2_NUMAUT = '"+Substr(MV_PAR03,11,8)+"'  "
Endif

//Filtra Pela Carteirina
If !Empty (MV_PAR04)
	cSQL1 += " AND BE2_OPEUSR = '"+ SubStr(MV_PAR04,1,4) +"'
	cSQL1 += " AND BE2_CODEMP = '"+ SubStr(MV_PAR04,5,4) +"'
	cSQL1 += " AND BE2_MATRIC = '"+ SubStr(MV_PAR04,9,6) +"'
	cSQL1 += " AND BE2_TIPREG = '"+ SubStr(MV_PAR04,15,2) +"'
ElseIf !empty(cMatric)
	cSQL1 += " AND BE2_OPEUSR = '"+ SubStr(cMatric,1,4) +"'
	cSQL1 += " AND BE2_CODEMP = '"+ SubStr(cMatric,5,4) +"'
	cSQL1 += " AND BE2_MATRIC = '"+ SubStr(cMatric,9,6) +"'
	cSQL1 += " AND BE2_TIPREG = '"+ SubStr(cMatric,15,2) +"'
Endif

//Filtra pelo Tipo de Guia
If !Empty (MV_PAR05)
	cSQL1 += " AND BE2_TIPGUI = '"+MV_PAR05+"'
Endif

//Filtra pela Tabela
If !Empty (MV_PAR06)
	cSQL1 += " AND BE2_CODPAD = '"+MV_PAR06+"'
Endif

cSQL1 += "   AND BEA_FILIAL 	= '"+xFilial("BEA")+"' "
cSQL1 += "   AND BEA_OPEMOV 	= BE2_OPEMOV "
cSQL1 += "   AND BEA_ANOAUT		= BE2_ANOAUT "
cSQL1 += "   AND BEA_MESAUT 	= BE2_MESAUT "
cSQL1 += "   AND BEA_NUMAUT 	= BE2_NUMAUT "
cSQL1 += "   AND BEA_CANCEL    <> '1' "
cSQL1 += "   AND "+RetSQLName("BE2")+".D_E_L_E_T_ = ' ' "
cSQL1 += "   AND "+RetSQLName("BEA")+".D_E_L_E_T_ = ' ' "

//Verifica se exibe somente registro referente a guia ptu-online
If GetNewPar("MV_PL790NE","0") == "1" 
	cSQL1 += "   AND BEA_COMUNI = '1' "
endIf

cSQL1 += cFilBE2

If  BQV->( FieldPos("BQV_STATUS") ) > 0 .And. BQV->( FieldPos("BQV_AUDITO") ) > 0

	//evolucao SADT
	If lEvoluSADT .and. ( empty(MV_PAR05) .or. MV_PAR05 == '02' )
	
		cSQL2BEA := " UNION "
		cSQL2BEA += " SELECT BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT,'Sim' AS PRORRO, "
		cSQL2BEA += " BQV_OPEUSR AS OPEUSR,BQV_CODEMP AS CODEMP,BQV_MATRIC AS MATRIC,BQV_TIPREG AS TIPREG, "
		cSQL2BEA += " BQV_DIGITO AS DIGITO,BQV_CODPAD AS CODPAD,BQV_CODPRO AS CODPRO,"+Iif( BQV->( FieldPos("BQV_DESPRO") ) > 0,"BQV_DESPRO","'---'")+" AS DESPRO, '' AS GUIREF, "
		cSQL2BEA += " BQV_SEQUEN AS SEQUEN,"+Iif( BQV->( FieldPos("BQV_SOLREV") ) > 0,"BQV_SOLREV","''")+" AS SOLREV,"+Iif( BQV->( FieldPos("BQV_DATPRO") ) > 0,"BQV_DATPRO","BQV_DTENTR")+" AS DATPRO,"+Iif( BQV->( FieldPos("BQV_HORPRO") ) > 0,"BQV_HORPRO","BQV_HRENTR")+" AS HORPRO, "
		cSQL2BEA += " BQV_QTDPRO AS QTDPRO,"+Iif( BQV->( FieldPos("BQV_PENDEN") ) > 0,"BQV_PENDEN","'1'")+" AS PENDEN, "
		
		cSQL2BEA += Iif( BQV->( FieldPos("BQV_NIVCRI") ) > 0,"BQV_NIVCRI","''")+" AS NIVCRI,"+Iif( BQV->( FieldPos("BQV_CHVNIV") ) > 0,"BQV_CHVNIV","''")+" AS CHVNIV, "
	    cSQL2BEA += " 'BEABQVBQZ' AS NOMALIAS, "
	    
		cSQL2BEA += RetSQLName("BQV")+".R_E_C_N_O_ AS REC,BEA_MATANT AS MATANT,BEA_NOMUSR AS NOMUSR, "
		cSQL2BEA += " BEA_TRACON AS TRACON,BEA_MSG05 AS RESREV,BEA_COMUNI AS COMUNI,"
		cSQL2BEA += " BEA_OPEMOV AS OPEMOV,BEA_ANOAUT AS ANOAUTINT,BEA_MESAUT AS MESAUTINT,BEA_NUMAUT AS NUMAUT,BEA_NUMINT AS NUMINT, "
		cSQL2BEA += " BEA_REGSOL AS REGSOL,BEA_ESTSOL AS ESTSOL,BEA_REGEXE AS REGEXE,BEA_ESTEXE AS ESTEXE, "
		cSQL2BEA += " BEA_SIGLA  AS SIGLA,BEA_OPERDA AS OPERDA,BEA_CODRDA AS CODRDA,BEA_CID AS CID,BEA_NRAOPE NRAOPE, "
		cSQL2BEA += " BEA_CODLOC  AS CODLOC, BEA_DESLOC AS DESLOC, '' AS DENTE, '' AS FACE, BEA_OPESOL AS OPESOL "
	    
		If lNrTrol
	        cSQL2BEA += ", BQV_NRTROL  AS NRTROL "
	    EndIf
	    
	    If lSeqPTU
   			cSQL2BEA += ", BQV_SEQPTU  AS SEQPTU "
		EndIf  
		
		cSQL2BEA += ", BEA_TIPO   AS TIPO "  
		cSQL2BEA += " FROM "+RetSQLName("BQV")+","+RetSQLName("BEA")
		
		cSQL3BEA := " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
		
		If empty(cMatric)
			cSQL3BEA += "   AND BQV_AUDITO = '1' "
			cSQL3BEA += "   AND BQV_STATUS = '0' "
		endIf
		
		If !lPrim
			If BQV->( FieldPos("BQV_DATPRO") ) > 0
				cSQL3BEA += "   AND BQV_DATPRO >='"+dtos(MV_PAR01)+"' AND BQV_DATPRO <='"+dtos(MV_PAR02)+"' "
			Else
				cSQL3BEA += "   AND BQV_DTENTR >='"+dtos(MV_PAR01)+"' AND BQV_DTENTR <='"+dtos(MV_PAR02)+"' "
			Endif
		endIf	

		//Filtra pela AutorizaГЦo
		If !Empty (MV_PAR03) .and. !lExit
			cSQL3BEA += " AND BQV_CODOPE = '"+Substr(MV_PAR03,01,4)+"'  "
			cSQL3BEA += " AND BQV_ANOINT = '"+Substr(MV_PAR03,05,4)+"'  "
			cSQL3BEA += " AND BQV_MESINT = '"+Substr(MV_PAR03,09,2)+"'  "
			cSQL3BEA += " AND BQV_NUMINT = '"+Substr(MV_PAR03,11,8)+"'  "
		Endif

	    //Filtra pela Carteirinha
		If !Empty (MV_PAR04)
			cSQL3BEA += " AND BQV_OPEUSR = '"+ SubStr(MV_PAR04,1,4) +"'"
			cSQL3BEA += " AND BQV_CODEMP = '"+ SubStr(MV_PAR04,5,4) +"'"
			cSQL3BEA += " AND BQV_MATRIC = '"+ SubStr(MV_PAR04,9,6) +"'"
			cSQL3BEA += " AND BQV_TIPREG = '"+ SubStr(MV_PAR04,15,2) +"'"
		ElseIf !empty(cMatric)
			cSQL3BEA += " AND BQV_OPEUSR = '"+ SubStr(cMatric,1,4) +"'"
			cSQL3BEA += " AND BQV_CODEMP = '"+ SubStr(cMatric,5,4) +"'"
			cSQL3BEA += " AND BQV_MATRIC = '"+ SubStr(cMatric,9,6) +"'"
			cSQL3BEA += " AND BQV_TIPREG = '"+ SubStr(cMatric,15,2) +"'"
		Endif
	
		//SADT
		cSQL3BEA += "   AND BEA_TIPGUI = '02' "
		cSQL3BEA += "   AND BEA_CANCEL <> '1' "

	    //Filtra pela Tabela
		If !Empty (MV_PAR06)
			cSQL3BEA += " AND BQV_CODPAD = '"+MV_PAR06+"'"
		Endif
		
		cSQL3BEA += "   AND BEA_FILIAL = '"+xFilial("BEA")+"' "
		cSQL3BEA += "   AND BEA_OPEMOV = BQV_CODOPE "
		cSQL3BEA += "   AND BQV_ANOINT = BEA_ANOAUT "
    	cSQL3BEA += "   AND BQV_MESINT = BEA_MESAUT "
		cSQL3BEA += "   AND BQV_NUMINT = BEA_NUMAUT "
		
		cSQL3BEA += "   AND "+RetSQLName("BQV")+".D_E_L_E_T_ = ' ' "
		cSQL3BEA += "   AND "+RetSQLName("BEA")+".D_E_L_E_T_ = ' ' "
		
		//Verifica se exibe somente registro referente a guia ptu-online
		If GetNewPar("MV_PL790NE","0") == "1"  
			cSQL3BEA += " AND BEA_COMUNI = '1' "
			
		EndIf
		
	EndIf
	
	//evolucao da internacao
	if empty(MV_PAR05) .or. MV_PAR05 == '03'
	
		cSQL2BE4 += " UNION "
		cSQL2BE4 += " SELECT BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT,'Sim' AS PRORRO, "
		cSQL2BE4 += " BQV_OPEUSR AS OPEUSR,BQV_CODEMP AS CODEMP,BQV_MATRIC AS MATRIC,BQV_TIPREG AS TIPREG, "
		cSQL2BE4 += " BQV_DIGITO AS DIGITO,BQV_CODPAD AS CODPAD,BQV_CODPRO AS CODPRO,"+Iif( BQV->( FieldPos("BQV_DESPRO") ) > 0,"BQV_DESPRO","'---'")+" AS DESPRO, '' AS GUIREF, "
		cSQL2BE4 += " BQV_SEQUEN AS SEQUEN,"+Iif( BQV->( FieldPos("BQV_SOLREV") ) > 0,"BQV_SOLREV","''")+" AS SOLREV,"+Iif( BQV->( FieldPos("BQV_DATPRO") ) > 0,"BQV_DATPRO","BQV_DTENTR")+" AS DATPRO,"+Iif( BQV->( FieldPos("BQV_HORPRO") ) > 0,"BQV_HORPRO","BQV_HRENTR")+" AS HORPRO, "
		cSQL2BE4 += " BQV_QTDPRO AS QTDPRO,"+Iif( BQV->( FieldPos("BQV_PENDEN") ) > 0,"BQV_PENDEN","'1'")+" AS PENDEN, "
		cSQL2BE4 += Iif( BQV->( FieldPos("BQV_NIVCRI") ) > 0,"BQV_NIVCRI","''")+" AS NIVCRI,"+Iif( BQV->( FieldPos("BQV_CHVNIV") ) > 0,"BQV_CHVNIV","''")+" AS CHVNIV, "
	    cSQL2BE4 += " 'BE4BQVBQZ' AS NOMALIAS,"
		
		cSQL2BE4 += RetSQLName("BQV")+".R_E_C_N_O_ AS REC,BEA_MATANT AS MATANT,BEA_NOMUSR AS NOMUSR, "
		cSQL2BE4 += " BEA_TRACON AS TRACON,BEA_MSG05 AS RESREV,BEA_COMUNI AS COMUNI,"
		cSQL2BE4 += " BEA_OPEMOV AS OPEMOV,BEA_ANOAUT AS ANOAUTINT,BEA_MESAUT AS MESAUTINT,BEA_NUMAUT AS NUMAUT,BEA_NUMINT AS NUMINT, "
		cSQL2BE4 += " BEA_REGSOL AS REGSOL,BEA_ESTSOL AS ESTSOL,BEA_REGEXE AS REGEXE,BEA_ESTEXE AS ESTEXE, "
		cSQL2BE4 += " BEA_SIGLA  AS SIGLA,BEA_OPERDA AS OPERDA,BEA_CODRDA AS CODRDA,BEA_CID AS CID,BEA_NRAOPE NRAOPE, "
		cSQL2BE4 += " BEA_CODLOC  AS CODLOC, BEA_DESLOC AS DESLOC, '' AS DENTE, '' AS FACE, BEA_OPESOL AS OPESOL "
		
		If lNrTrol
	        cSQL2BE4 += ", BQV_NRTROL  AS NRTROL "
	    EndIf
		
	    If lSeqPTU
   			cSQL2BE4 += ", BQV_SEQPTU  AS SEQPTU "
		EndIf  
		
		cSQL2BE4 += ", BEA_TIPO    AS TIPO "  
		cSQL2BE4 += " FROM "+RetSQLName("BQV")+","+RetSQLName("BEA")
		
		cSQL3BE4 := " WHERE BQV_FILIAL = '"+xFilial("BQV")+"' "
		
		If empty(cMatric)
			cSQL3BE4 += "   AND BQV_AUDITO = '1' "
			cSQL3BE4 += "   AND BQV_STATUS = '0' "
		endIf
		
		If !lPrim
			If BQV->( FieldPos("BQV_DATPRO") ) > 0
				cSQL3BE4 += "   AND BQV_DATPRO >='"+dtos(MV_PAR01)+"' AND BQV_DATPRO <='"+dtos(MV_PAR02)+"' "
			Else
				cSQL3BE4 += "   AND BQV_DTENTR >='"+dtos(MV_PAR01)+"' AND BQV_DTENTR <='"+dtos(MV_PAR02)+"' "
			Endif
		endIf	
		
		//Filtra pela AutorizaГЦo
		If !Empty (MV_PAR03) .and. !lExit
			cSQL3BE4 += " AND BQV_CODOPE = '"+Substr(MV_PAR03,01,4)+"'  "
			cSQL3BE4 += " AND BQV_ANOINT = '"+Substr(MV_PAR03,05,4)+"'  "
			cSQL3BE4 += " AND BQV_MESINT = '"+Substr(MV_PAR03,09,2)+"'  "
			cSQL3BE4 += " AND BQV_NUMINT = '"+Substr(MV_PAR03,11,8)+"'  "
		Endif
	    //Filtra pela Carteirinha
	
		If !Empty (MV_PAR04)
			cSQL3BE4 += " AND BQV_OPEUSR = '"+ SubStr(MV_PAR04,1,4) +"'"
			cSQL3BE4 += " AND BQV_CODEMP = '"+ SubStr(MV_PAR04,5,4) +"'"
			cSQL3BE4 += " AND BQV_MATRIC = '"+ SubStr(MV_PAR04,9,6) +"'"
			cSQL3BE4 += " AND BQV_TIPREG = '"+ SubStr(MV_PAR04,15,2) +"'"
		ElseIf !empty(cMatric)
			cSQL3BE4 += " AND BQV_OPEUSR = '"+ SubStr(cMatric,1,4) +"'"
			cSQL3BE4 += " AND BQV_CODEMP = '"+ SubStr(cMatric,5,4) +"'"
			cSQL3BE4 += " AND BQV_MATRIC = '"+ SubStr(cMatric,9,6) +"'"
			cSQL3BE4 += " AND BQV_TIPREG = '"+ SubStr(cMatric,15,2) +"'"
		Endif

		//internacao
		cSQL3BE4 += " AND BEA_TIPGUI = '03'"
		cSQL3BE4 += " AND BEA_CANCEL <> '1'"
			
	    //Filtra pela Tabela
		If !Empty (MV_PAR06)
			cSQL3BE4 += " AND BQV_CODPAD = '"+MV_PAR06+"'"
		Endif
	
		cSQL3BE4 += "   AND BEA_FILIAL = '"+xFilial("BEA")+"' "
		cSQL3BE4 += "   AND BEA_OPEMOV = BQV_CODOPE "
	    cSQL3BE4 += "   AND BEA_ANOINT	= BQV_ANOINT "
	    cSQL3BE4 += "   AND BEA_MESINT = BQV_MESINT "
	    cSQL3BE4 += "   AND BEA_NUMINT = BQV_NUMINT "
	    
		cSQL3BE4 += "   AND "+RetSQLName("BQV")+".D_E_L_E_T_ = ' ' "
		cSQL3BE4 += "   AND "+RetSQLName("BEA")+".D_E_L_E_T_ = ' ' "
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se exibe somente registro referente a guia ptu-online
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If GetNewPar("MV_PL790NE","0") == "1"  
			cSQL3BE4 += " AND BEA_COMUNI = '1' "
			
			
		endIf
		
	endIf
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Este parametro ativo somente lista guias do ptu-online
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If GetNewPar("MV_PL790NE","0") == "0"

	If  PLSALIASEXI("B45")
		cSQL4 := " UNION "
		cSQL4 += " SELECT B44_ANOAUT,B44_MESAUT,B44_NUMAUT,'Nao' AS PRORRO, "
		cSQL4 += " B44_OPEUSR AS OPEUSR,B44_CODEMP AS CODEMP,B44_MATRIC AS MATRIC,B44_TIPREG AS TIPREG, "
		cSQL4 += " B44_DIGITO AS DIGITO,B45_CODPAD AS CODPAD,B45_CODPRO AS CODPRO, BR8_DESCRI AS DESPRO, '' AS GUIREF, "
		cSQL4 += " B45_SEQUEN AS SEQUEN, '' AS SOLREV,B45_DATPRO AS DATPRO,B45_HORPRO AS HORPRO, "
		cSQL4 += " B45_QTDPRO AS QTDPRO, '1' AS PENDEN, "
		cSQL4 += " B45_NIVCRI AS NIVCRI,B45_CHVNIV AS CHVNIV, "
		cSQL4 += " 'B44B45B46' AS NOMALIAS,"+RetSQLName("B45")+".R_E_C_N_O_ AS REC,B44_MATANT AS MATANT,B44_NOMUSR AS NOMUSR,	"
		cSQL4 += " '' AS TRACON,'' AS RESREV, '0' AS COMUNI, "
		cSQL4 += " B45_OPEMOV AS OPEMOV,B45_ANOAUT AS ANOAUTINT,B45_MESAUT AS MESAUTINT,B45_NUMAUT AS NUMAUT,'' AS NUMINT, "
		cSQL4 += " B44_REGSOL AS REGSOL,B44_ESTSOL AS ESTSOL,B44_REGEXE AS REGEXE,B44_ESTEXE AS ESTEXE, "
		cSQL4 += " B44_SIGLA  AS SIGLA,B44_OPERDA AS OPERDA,B44_CODRDA AS CODRDA,B44_CID AS CID,'' NRAOPE, "
		cSQL4 += " B44_CODLOC  AS CODLOC, B44_DESLOC AS DESLOC, '' AS DENTE, '' AS FACE, B44_OPESOL AS OPESOL "
		
		If lNrTrol
	        cSQL4 += ", ' '  AS NRTROL "
	    EndIf
	    
	    If lSeqPTU
   			cSQL4 += ", ' '  AS SEQPTU "
		EndIf  
		
		cSQL4 += ", '4'    AS TIPO " 
		cSQL4 += " FROM "+RetSQLName("B44")+","+RetSQLName("B45")+','+RetSQLName("BR8")
		
		cSQL5 := " WHERE B45_FILIAL 	= '"+xFilial("B45")+"' "
		
		If empty(cMatric)
			cSQL5 += "   AND B45_AUDITO 	= '1'"
			cSQL5 += "   AND B45_STATUS 	= '0' "
		endIf
		
		If !lPrim
			cSQL5 += "   AND B45_DATPRO >='"+dtos(MV_PAR01)+"' AND B45_DATPRO <='"+dtos(MV_PAR02)+"' "
		endIf	
		
		If !Empty (MV_PAR03) .and. !lExit
			cSQL5 += " AND B45_OPEMOV = '"+Substr(MV_PAR03,01,4)+"'  "
			cSQL5 += " AND B45_ANOAUT = '"+Substr(MV_PAR03,05,4)+"'  "
			cSQL5 += " AND B45_MESAUT = '"+Substr(MV_PAR03,09,2)+"'  "
			cSQL5 += " AND B45_NUMAUT = '"+Substr(MV_PAR03,11,8)+"'  "
		Endif

		If !Empty (MV_PAR04)
			cSQL5 += " AND B44_OPEUSR = '"+ SubStr(MV_PAR04,1,4) +"'"
			cSQL5 += " AND B44_CODEMP = '"+ SubStr(MV_PAR04,5,4) +"'"
			cSQL5 += " AND B44_MATRIC = '"+ SubStr(MV_PAR04,9,6) +"'"
			cSQL5 += " AND B44_TIPREG = '"+ SubStr(MV_PAR04,15,2) +"'"
		ElseIf !empty(cMatric)
			cSQL5 += " AND B44_OPEUSR = '"+ SubStr(cMatric,1,4) +"'"
			cSQL5 += " AND B44_CODEMP = '"+ SubStr(cMatric,5,4) +"'"
			cSQL5 += " AND B44_MATRIC = '"+ SubStr(cMatric,9,6) +"'"
			cSQL5 += " AND B44_TIPREG = '"+ SubStr(cMatric,15,2) +"'"
		Endif

		If !Empty (MV_PAR05)
			cSQL5 += " AND B44_TIPGUI = '"+MV_PAR05+"'"
		Endif

		If !Empty (MV_PAR06)
			cSQL5 += " AND B45_CODPAD = '"+MV_PAR06+"'"
		Endif
		
		cSQL5 += "   AND B44_FILIAL 	= '"+xFilial("B44")+"' "
		cSQL5 += "   AND B44_OPEMOV 	= B45_OPEMOV "
		cSQL5 += "   AND B44_ANOAUT		= B45_ANOAUT "
		cSQL5 += "   AND B44_MESAUT 	= B45_MESAUT "
		cSQL5 += "   AND B44_NUMAUT 	= B45_NUMAUT "
		
		cSQL5 += "   AND BR8_FILIAL 	= '"+xFilial("BR8")+"' "
		cSQL5 += "   AND BR8_CODPAD 	= B45_CODPAD "
		cSQL5 += "   AND BR8_CODPSA 	= B45_CODPRO "
		
		cSQL5 += "   AND "+RetSQLName("B44")+".D_E_L_E_T_ = ' ' "
		cSQL5 += "   AND "+RetSQLName("B45")+".D_E_L_E_T_ = ' ' "
		cSQL5 += "   AND "+RetSQLName("BR8")+".D_E_L_E_T_ = ' ' "

	EndIf
EndIf

If  PLSALIASEXI("B4C")
		cSQL6 := " UNION "
		cSQL6 += " SELECT B4A_ANOAUT,B4A_MESAUT,B4A_NUMAUT,'Nao' AS PRORRO, "
		cSQL6 += " B4A_OPEUSR AS OPEUSR,B4A_CODEMP AS CODEMP,B4A_MATRIC AS MATRIC,B4A_TIPREG AS TIPREG, "
		cSQL6 += " B4A_DIGITO AS DIGITO,B4C_CODPAD AS CODPAD,B4C_CODPRO AS CODPRO, BR8_DESCRI AS DESPRO, B4A_GUIREF AS GUIREF, "
		cSQL6 += " B4C_SEQUEN AS SEQUEN, '' AS SOLREV,B4C_DATPRO AS DATPRO,'' AS HORPRO, "
		cSQL6 += " B4C_QTDPRO AS QTDPRO, '1' AS PENDEN, "
		cSQL6 += " B4C_NIVCRI AS NIVCRI,B4C_CHVNIV AS CHVNIV, "
		cSQL6 += " 'B4AB4CBEG' AS NOMALIAS,"+RetSQLName("B4C")+".R_E_C_N_O_ AS REC,B4A_MATANT AS MATANT,B4A_NOMUSR AS NOMUSR,	"
		cSQL6 += " '' AS TRACON,'' AS RESREV, '0' AS COMUNI, "
		cSQL6 += " B4C_OPEMOV AS OPEMOV,B4C_ANOAUT AS ANOAUTINT,B4C_MESAUT AS MESAUTINT,B4C_NUMAUT AS NUMAUT,'' AS NUMINT, "
		cSQL6 += " '' AS REGSOL,'' AS ESTSOL,'' AS REGEXE,'' AS ESTEXE, "
		cSQL6 += " ''  AS SIGLA,'' AS OPERDA,'' AS CODRDA,B4A_CIDPRI AS CID,'' NRAOPE, "
		cSQL6 += " ''  AS CODLOC, '' AS DESLOC, '' AS DENTE, '' AS FACE, '' AS OPESOL "
		
		If lNrTrol
	        cSQL6 += ", ' '  AS NRTROL "
	    EndIf 
	    
        If lSeqPTU
   			cSQL6 += ", ' '  AS SEQPTU "
		EndIf  
	    
	    cSQL6 += ", '6'    AS TIPO " 
		cSQL6 += " FROM "+RetSQLName("B4A")+","+RetSQLName("B4C")+','+RetSQLName("BR8")
		
		cSQL7 := " WHERE B4C_FILIAL 	= '"+xFilial("B4C")+"' "
		
		If empty(cMatric)
			cSQL7 += "   AND B4C_AUDITO = '1'"
			cSQL7 += "   AND B4C_STATUS = '0' "
		endIf
		
		If !lPrim
			cSQL7 += "   AND B4A_DATSOL >='"+dtos(MV_PAR01)+"' AND B4A_DATSOL <='"+dtos(MV_PAR02)+"' "
		endIf	
		
		If !Empty (MV_PAR05)
			cSQL7 += " AND B4A_TIPGUI = '"+MV_PAR05+"'
		Endif	
		
		If !Empty (MV_PAR03)   .and. !lExit
			cSQL7 += " AND B4C_OPEMOV = '"+Substr(MV_PAR03,01,4)+"'  "
			cSQL7 += " AND B4C_ANOAUT = '"+Substr(MV_PAR03,05,4)+"'  "
			cSQL7 += " AND B4C_MESAUT = '"+Substr(MV_PAR03,09,2)+"'  "
			cSQL7 += " AND B4C_NUMAUT = '"+Substr(MV_PAR03,11,8)+"'  "
		Endif

		If !Empty (MV_PAR04)
			cSQL7 += " AND B4A_OPEUSR = '"+ Substr(MV_PAR04,1,4) +"'"
			cSQL7 += " AND B4A_CODEMP = '"+ Substr(MV_PAR04,5,4) +"'"
			cSQL7 += " AND B4A_MATRIC = '"+ Substr(MV_PAR04,9,6) +"'"
			cSQL7 += " AND B4A_TIPREG = '"+ Substr(MV_PAR04,15,2) +"'"
		ElseIf !empty(cMatric)
			cSQL7 += " AND B4A_OPEUSR = '"+ Substr(cMatric,1,4) +"'"
			cSQL7 += " AND B4A_CODEMP = '"+ Substr(cMatric,5,4) +"'"
			cSQL7 += " AND B4A_MATRIC = '"+ Substr(cMatric,9,6) +"'"
			cSQL7 += " AND B4A_TIPREG = '"+ Substr(cMatric,15,2) +"'"
		Endif


		If !Empty (MV_PAR06)
			cSQL7 += " AND B4C_CODPAD = '"+MV_PAR06+"'"
		Endif
		cSQL7 += "   AND B4A_FILIAL = '"+xFilial("B4A")+"' "
		
		cSQL7 += "   AND B4A_OPEMOV = B4C_OPEMOV "
		cSQL7 += "   AND B4A_ANOAUT	= B4C_ANOAUT "
		cSQL7 += "   AND B4A_MESAUT = B4C_MESAUT "
		cSQL7 += "   AND B4A_NUMAUT = B4C_NUMAUT "
		
		cSQL7 += "   AND BR8_FILIAL = '"+xFilial("BR8")+"' "
		cSQL7 += "   AND BR8_CODPAD = B4C_CODPAD "
		cSQL7 += "   AND BR8_CODPSA = B4C_CODPRO "
		
		cSQL7 += "   AND "+RetSQLName("B4A")+".D_E_L_E_T_ = ' ' "
		cSQL7 += "   AND "+RetSQLName("B4C")+".D_E_L_E_T_ = ' ' "
		cSQL7 += "   AND "+RetSQLName("BR8")+".D_E_L_E_T_ = ' ' "

EndIf

If ExistBlock("PL790QRY")

	aRet :=	ExecBlock("PL790QRY",.F.,.F.,{ cSQL1,cSQL3BE4,cSQL5,cSQL7,cSQL3BEA } )

	cSQL += aRet[1] + cSQL2BE4 + aRet[2] + cSQL4 + aRet[3]

	if Len(aRet) >= 4
		cSQL += cSQL6 + aRet[4]
	endIf

	If Len(aRet) >= 5
		cSQL += cSQL2BEA + aRet[5]
	endIf
	
else
	cSQL += cSQL1 + cSQL2BEA + cSQL3BEA + cSQL2BE4 + cSQL3BE4 + cSQL4 + cSQL5 + cSQL6 + cSQL7
endIf

cSQL += "   ORDER BY 1,2,3 "

PLSQuery(cSQL,"PROAUD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While para alimentar a query											   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(DbSetOrder(2)) 
BAU->(DbSetOrder(1)) 

Do While !PROAUD->(Eof())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Matriz																	   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	cDesPro := AllTrim(PROAUD->DESPRO)

	if MV_PAR07 <> 1
			If BA1->(Msseek(xFilial('BA1')+PROAUD->OPEUSR+PROAUD->CODEMP+PROAUD->MATRIC+PROAUD->TIPREG))  
				If Empty(PROAUD->CODRDA) .or. !BAU->(MsSeek(xFilial('BAU')+PROAUD->CODRDA))
					If !PROAUD->NOMALIAS == 'B4AB4CBEG' .And. MV_PAR07 <> 3
			    		PROAUD->(DbSkip())
			    		loop
			    	Endif
		    	Endif
		    	//intercambio com usuario de outra operadora
		    	if MV_PAR07 == 2
		    		If BA1->BA1_OPEORI == PlsintPad()
		    		  	PROAUD->(DbSkip())
		    			loop
		    		Endif
		    	//intercambio com usuario da minha operadora
		    	elseif MV_PAR07 == 3
		    		If !(BA1->BA1_OPEORI == PlsintPad() .and. !Empty(BAU->BAU_CODOPE))   
		    			If PROAUD->NOMALIAS == 'B4AB4CBEG'  .And. !Empty (PROAUD->GUIREF) .And. BEA->(MsSeek( xFilial("BEA")+PROAUD->GUIREF ) )
		    				If BAU->(MsSeek(xFilial('BAU')+BEA->BEA_CODRDA)) 
		    					If Empty(BAU->BAU_CODOPE)  
				    		 	 	PROAUD->(DbSkip())
				    				loop		    			
				    			EndIf	
			    			Else
		    		 	 		PROAUD->(DbSkip())
		    					loop		    			
    					    EndIf
		    			Else	    		  
			    		  	PROAUD->(DbSkip())
			    			loop
		    			EndIf
		    		Endif
		    	Endif
		    Endif
    Endif
    
    If ! Empty(PROAUD->DENTE)
       cDesPro += Space(5)+STR0225+AllTrim(PROAUD->DENTE)+" ] " //"[ Dente "
    Endif

    If ! Empty(PROAUD->FACE)
       cDesPro += Space(5)+STR0226+AllTrim(PROAUD->FACE)+" ] " //"[ Face "
    Endif
   	AaDd(aProAud,{	{"MATRICULA",AllTrim(PROAUD->OPEUSR)+AllTrim(PROAUD->CODEMP)+AllTrim(PROAUD->MATRIC)+AllTrim(PROAUD->TIPREG)+AllTrim(PROAUD->DIGITO) },;
				   	{"OPEMATEMP",PROAUD->(OPEMOV+CODEMP+MATRIC) },;
					{"NOMUSR"	,PROAUD->NOMUSR },;
					{"OPEUSR"	,PROAUD->OPEUSR },;
					{"CODEMP"	,PROAUD->CODEMP },;
					{"MATRIC"	,PROAUD->MATRIC },;
					{"TIPREG"	,PROAUD->TIPREG },;
   					{"MATANT"	,PROAUD->MATANT },;
					{"REGSOL"	,PROAUD->REGSOL },;
					{"NOMREGSOL",Posicione("BB0",4,xFilial("BB0")+PROAUD->(ESTSOL+REGSOL+SIGLA),"BB0_NOME") },;
					{"REGEXE"	,PROAUD->REGEXE },;
					{"NOMREGEXE",Posicione("BB0",4,xFilial("BB0")+PROAUD->(ESTEXE+REGEXE+SIGLA),"BB0_NOME") },;
					{"CODPAD"	,PROAUD->CODPAD },;
					{"CODPRO"	,PROAUD->CODPRO },;
					{"DESPRO"	,cDesPro },;
   					{"CHKAUTINT",PROAUD->(OPEMOV+ANOAUTINT+MESAUTINT+NUMAUT) },;
   					{"OPEMOV"	,PROAUD->OPEMOV },;
   					{"ANOAUTINT",PROAUD->ANOAUTINT },;
   					{"MESAUTINT",PROAUD->MESAUTINT },;
   					{"NUMAUT"   ,PROAUD->NUMAUT },;
   					{"NUMINT"   ,PROAUD->NUMINT },;
					{"SEQUEN"	,PROAUD->SEQUEN },;
					{"SOLREV"	,PROAUD->SOLREV },;
   					{"DATPRO"	,PROAUD->DATPRO },;
					{"HORPRO"	,PROAUD->HORPRO },;
   					{"QTDPRO"	,PROAUD->QTDPRO },;
					{"OPERDA"	,PROAUD->OPERDA },;
					{"CODRDA"	,PROAUD->CODRDA },;
   					{"NOMRDA" 	,Posicione("BAU",1,xFilial("BAU")+PROAUD->CODRDA,"BAU_NOME") },;
   					{"CID"		,PROAUD->CID },;
   					{"PENDEN"	,PROAUD->PENDEN },;
					{"NOMALIAS"	,SubStr(PROAUD->NOMALIAS,4,3) },;
					{"NOMALCIC"	,PROAUD->NOMALIAS },;
					{"NIVCRI"	,PROAUD->NIVCRI },;
					{"CHVNIV"	,PROAUD->CHVNIV },;
					{"NRAOPE"	,PROAUD->NRAOPE },;
					{"TRACON"	,PROAUD->TRACON },;
					{"RESREV"	,PROAUD->RESREV },;
					{"PRORRO"	,PROAUD->PRORRO },;
					{"CODLOC"	,PROAUD->CODLOC },;
					{"DESLOC"	,PROAUD->DESLOC },;
					{"COMUNI"	,PROAUD->COMUNI },;
					{"NRTROL"	,iif(lNrTrol,PROAUD->NRTROL," ") },;
   					{"VALRECNO"	,PROAUD->REC } ,;
   					{"BCOCONH"  ,IIf(PL790VCONH("BE2",xFilial("BE2") + PROAUD->(OPEUSR+ANOAUTINT+MESAUTINT+NUMAUT+SEQUEN) ),"Sim","Nao") },; //BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN)
   					{"OPESOL"   ,PROAUD->OPESOL},; 
   					{"SEQPTU"   ,iif(lSeqPTU,PROAUD->SEQPTU," ")},;
   					{"TIPO"   ,PROAUD->TIPO}   } )       
PROAUD->(DbSkip())
EndDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha area																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PROAUD->( DbCloseArea() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Refresh																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Type("oOcorr") <> "U"
   oOcorr:SetArray(aProAud)
   oOcorr:Refresh()
   Eval(oOcorr:bChange)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias e Recno															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aProAud) > 0
	cAliProAud := PlsPtuGet( "NOMALIAS",aProAud[1] )
	cRecProAud := PlsPtuGet( "VALRECNO",aProAud[1] )
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PL790POS Ё Autor Ё Alexander             Ё Data Ё 12.09.06 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Retorna posicao em uma Matriz                              Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL790POS(cCampo,aHdr,cOp)

LOCAL nCol
DEFAULT cOp := '$'
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё aScan																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aHdr) > 0
	If cOp == '$'
		nCol := Ascan( aHdr[1] , { |a| a[1] $ cCampo } )
	Else
		nCol := Ascan( aHdr[1] , { |a| a[1] == cCampo } )
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(nCol)
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLS790MAUDЁ Autor Ё Alexander             Ё Data Ё 12.09.06 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Retorna Movimentacao do procedimento						  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790MAUD(cOpeMov,cAnoAut,cMesAut,cNumAut,cCodPad,cCodPro,cCodemp,cMatric,cTipreg,lMemo,lPrim)
LOCAL cSql		:= ""
LOCAL aMatDad 	:= {}
LOCAL aCab		:= {}
LOCAL cMsg		:= ""
LOCAL aArea	:= GetArea()
LOCAL cCarteira	:=	""

Default lMemo	:= .F.
Default lPrim	:= .T.


If BVX->( FieldPos("BVX_MSG")) > 0
	aCab :={   {STR0191     	,"@d",050},; //"Cod. Auditor"
			   {STR0192     	,"@C",090},; //"Nome Auditor"
			   {STR0193		,"@D",040},; //"Data Parecer"
			   {STR0070   	,"@C",050},; //"Parecer"
			   {STR0194	  	,"@N",020},; //"Motivo"
			   {STR0195		,"@N",200},; //"Descricao Motivo"
			   {STR0196 	  	,"@C",200},; //"Solicitacao Revisao"
			   {STR0197	  	,"@C",220}} //"Mensagem"
Else
	aCab :={   {STR0191     	,"@d",050},; //"Cod. Auditor"
			   {STR0192     	,"@C",090},; //"Nome Auditor"
			   {STR0193		,"@D",040},; //"Data Parecer"
			   {STR0070   	,"@C",050},; //"Parecer"
			   {STR0194	  	,"@N",020},; //"Motivo"
			   {STR0195		,"@N",200},; //"Descricao Motivo"
			   {STR0196 	  	,"@C",200},; //"Solicitacao Revisao"
			   {STR0197	  	,"@C",220},; //"Mensagem"
			   {STR0198 	  	,"@C",200},; //"Informacao"
			   {STR0199 		,"@C",220}}  //"Msg. Geral"
EndIf

If ExistBlock("P790MAUD")
	ExecBlock("P790MAUD",.F.,.F.,{cOpeMov,cAnoAut,cMesAut,cNumAut,cCodPad,cCodPro})
	Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona da mesma nota todo o historico do procedimento auditado		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql := " SELECT BVX_ANOAUT,BVX_MESAUT,BVX_NUMAUT,BVX_CODAUD,BVX_NOMAUD,BVX_DATPAR,BVX_PARECE, "
cSql += " 	     BVX_MOTIVO,BVX_DESMOT,"+Iif(BVX->( FieldPos("BVX_SOLREV") ) > 0,"BVX_SOLREV","''")+", R_E_C_N_O_"
If BVX->(FieldPos("BVX_MSG")) = 0
	cSql += ",BVX_MSG01,BVX_MSG02,BVX_MSG03,BVX_MSG04,BVX_MSG05"
Endif
cSql += " FROM "+RetSQLName("BVX")
cSql += " WHERE BVX_FILIAL  = '"+xFilial("BVX")+"'"
cSql += "   AND BVX_OPEMOV  = '"+cOpeMov+"'"
cSql += "   AND BVX_CODEMP  = '"+cCodemp+"'"
cSql += "   AND BVX_MATRIC  = '"+cMatric+"'"
cSql += "   AND BVX_TIPREG  = '"+cTipreg+"'"

cSql += "   AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY BVX_DATPAR, R_E_C_N_O_  "
PLSQuery(cSQL,"PLSMOVAUD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While para montar matriz exibir na crigen								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCarteira:=cOpeMov+cCodemp+cMatric+cTipreg
While !PLSMOVAUD->( Eof() )
    If BVX->(FieldPos("BVX_MSG")) > 0
    	AaDd(aMatDad,{PLSMOVAUD->BVX_CODAUD,PLSMOVAUD->BVX_NOMAUD,PLSMOVAUD->BVX_DATPAR,AllTrim(X3COMBO("BVX_PARECE",PLSMOVAUD->BVX_PARECE)),PLSMOVAUD->BVX_MOTIVO,PLSMOVAUD->BVX_DESMOT,"",""} )

    	//Retorna o campo MSG que И do tipo MEMO.
    	BVX->(DbGoto(PLSMOVAUD->R_E_C_N_O_))
    	
    	cMsg := PTURemChr(BVX->BVX_MSG)

    	AaDd(aMatDad,{"","","","","","",Iif(BVX->( FieldPos("BVX_SOLREV") ) > 0,PLSMOVAUD->BVX_SOLREV,''),AllTrim(cMsg)} )
    Else
    	AaDd(aMatDad,{PLSMOVAUD->BVX_CODAUD,PLSMOVAUD->BVX_NOMAUD,PLSMOVAUD->BVX_DATPAR,AllTrim(X3COMBO("BVX_PARECE",PLSMOVAUD->BVX_PARECE)),PLSMOVAUD->BVX_MOTIVO,PLSMOVAUD->BVX_DESMOT,"","","",""} )
    	AaDd(aMatDad,{"","","","","","",Iif(BVX->( FieldPos("BVX_SOLREV") ) > 0,PLSMOVAUD->BVX_SOLREV,''),AllTrim(PLSMOVAUD->BVX_MSG01)+" "+AllTrim(PLSMOVAUD->BVX_MSG02),AllTrim(PLSMOVAUD->BVX_MSG03),AllTrim(PLSMOVAUD->BVX_MSG04)+" "+AllTrim(PLSMOVAUD->BVX_MSG05)} )
    EndIf
	PLSMOVAUD->( DbSkip() )
EndDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSMOVAUD->( DbCloseArea() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Mostra os dados															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aMatDad) > 1
	PLSHISMOV(aMatDad,aCab,STR0126,.F.,cCarteira,cNumAut,lPrim)//"Movimentacao do Procedimento na Auditoria"
Else
    MsgAlert(STR0127) //"Nao existe movimentacao para este procedimento"
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea(aArea)
Return
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSVLDCLI Ё Autor Ё Alexander             Ё Data Ё 25.07.07 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Verifica a possibilidade de auditar						  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSVLDCLI(lEnvTds)
LOCAL lDbClick  := .T.
LOCAL lDecurso  := .F.
Local nRet
Local cSubDec   :=""
DEFAULT lEnvTds := .F.
If Len(aProAud) > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se outra operadora esta auditando a guia						   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  Alltrim(PlsPtuGet( "COMUNI",aProAud[oOcorr:nAt] )) == '1' .And. Alltrim(GetNewPar("MV_PLSSOOL","1")) == "1" .And. PlsPtuGet( "OPESOL",aProAud[oOcorr:nAt] ) == PlsIntPad() .And. ; 	
   		Alltrim(PlsPtuGet( "CODEMP",aProAud[oOcorr:nAt] )) == GetNewPar("MV_PLSGEIN","0050")

		If lEnvTds 
			MsgInfo(STR0246)			
			Return	
		EndIf

	   lDecurso := vldDecurso()	
        
       lDbClick := .f.
	   If lDecurso		  
			nRet := Aviso("Status TransaГЦo","Deseja Solicitar o Status da TransaГЦo ou Decurso de Prazo?",{"Status Sol.","Decurso","Cancelar"},2,cSubDec)

			If nRet == 1
	           PlStatTran()
			 
			ElseIf nRet == 2
	 			PlDecPrazo()	
			 
			Else
			
			 Return ()			 
			Endif
        ElseIf MsgYesNo(STR0232 )//"Registro sendo auditado por outra operadora, deseja solicitar o Status da TransaГЦo?"
	            PlStatTran()
        EndIf	
    EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Executa funcao															   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lDbClick
		If lEnvTds 
			If Empty(Alltrim(PlsPtuGet( "NRTROL",aProAud[oOcorr:nAt] ))) .And. PlsPtuGet( "OPESOL",aProAud[oOcorr:nAt] ) == PlsIntPad() 		
				MsgInfo(STR0246)			
				Return	
			EndIf
		EndIf
	
		PLS790DBCLICK( PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] ),lEnvTds )
    EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁAtualizaBrЁ Autor Ё Tulio		            Ё Data Ё 25.07.07 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Para atualizacao de grid									  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function AtualizaBr(oOcorr)
LOCAL bBlock := {|| PLS790ATU(),oOcorr:Refresh() }

Eval(bBlock)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/{Protheus.doc} vldDecurso
Decurso do prazo

@author Totvs
@since 30/06/2015
@version P11
/*/
static function vldDecurso
local cSequen 	:= PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )
local cCodPad 	:= PlsPtuGet( "CODPAD",aProAud[oOcorr:nAt] )
local cCodPro 	:= PlsPtuGet( "CODPRO",aProAud[oOcorr:nAt] )
local dBase 	:= stod(PlsPtuGet( "DATPRO",aProAud[oOcorr:nAt] ))
local cChaveAut := PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] )
local nDias		:= date()-dBase
local aFeriados := retFeriados()
local nDiasUteis:= 0
local lDecurso	:= .f.

BR8->( dbSetOrder(1) ) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
BR8->( msSeek( xFilial("BR8") + cCodPad + cCodPro ) )

cTpProc := BR8->BR8_TPPROC
			
//0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;6=Pacote;7=Gases Medicinais;8=Alugueis;9=Outros
if cTpProc $ '1,2,5,0' .Or. Empty(cTpProc)
	
	if cTpProc $ '1,2,5' .and. nDias > 10
       lDecurso := .t.
	elseIf (cTpProc == '0' .Or. Empty(cTpProc)).and. nDias >= 2
	
       	while nDias > 0
          	dBase++
          	
          	if ascan(aFeriados,dtos(dBase)) == 0 .and. dow(dBase) <> 1 .and. dow(dBase) <> 7
          		nDias--
          		nDiasUteis++
          		
          		if nDiasUteis >= 2
          			lDecurso := .t.
          			exit
          		endIf
          	endIf
          	
       	endDo
	
	endIf
	
endIf
			
//verifica se tem algum procedimento negado critica __aCdCri052.  (3 = Pendente para autorizaГЦo da empresa)
if !lDecurso

	BEG->( dbSetOrder(2) ) //BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN + BEG_CODGLO + BEG_DESGLO
	if BEG->( msSeek(xFilial("BEG") + cChaveAut + cSequen + __aCdCri052[1] ) )
		lDecurso := .t.
	else
		BEL->( dbSetOrder(2) ) //BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN + BEL_CODGLO + BEL_DESGLO
		if BEL->( msSeek(xFilial("BEL") +cChaveAut + cSequen + __aCdCri052[1] ) )
			lDecurso := .t.
		endIf
	endIf
		
endIf

return(lDecurso)

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPL001QTDP Ё Autor Ё Daher		            Ё Data Ё 25.07.07 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Para atualizacao de grid									  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL001QTDR(cTipo)
LOCAL cChave 	 := PlsPtuGet( "CHKAUTINT",aProAud[oOcorr:nAt] )
LOCAL lRet		 := .F.

If cTipo == "1" .and. PLSALIASEXI("B44")
	B44->( DbSetOrder(1) )
	If B44->( MsSeek( xFilial("B44")+cChave ) )
		B45->(DbSetOrder(1))
		If B45->(MsSeek(xFilial("B45")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))
			lRet := .T.
		EndIf
	EndIf
EndIf
If cTipo == "2"
	BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
	BEA->( MsSeek( xFilial("BEA")+cChave ) )
	BE2->(DbSetOrder(1))
	If !BE2->(MsSeek(xFilial("BE2")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))//SADT
		BEJ->(DbSetOrder(1))
		If BEJ->(MsSeek(xFilial("BEJ")+cChave+PlsPtuGet( "SEQUEN",aProAud[oOcorr:nAt] )))//internacao
			lRet := .T.
		Endif
	Else
		lRet := .T.
	Endif

EndIf

Return lRet


/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPlAudPtuOnЁ Autor Ё Microsiga	            Ё Data Ё 01.06.11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Verifica se a guia e proveniente de uma autorizacao online Ё╠╠╠
╠╠Ё          Ё e realiza as validacoes necessarias                        Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlAudPtuOn(lEnvTds,cParec)
Local lRet := .T.
DEFAULT cParec := ""

If BEA->BEA_COMUNI == '1' .And. GetNewPar("MV_PLSSOOL","1") == "1"
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Guia negada e necessario infomar o motivo								   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If M->BVX_PARECE == '1' .And. Empty(M->BVX_MOTIVO)
        Aviso( STR0115, STR0223,{ STR0231 }, 2 )//"Ao negar uma autorizaГЦo On-line И necessАrio indicar o Mot Parecer"
        lRet := .F.
    EndIf
    If M->BVX_QTDPRO=0
 		Aviso( STR0115, STR0242,{ STR0231 }, 2 ) //Nao e permitida a quantidade igual a zero
        lRet := .F.
    EndIf
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Obrigatorio informar mensagem para a outra operadora                	   Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If IIf(BVX->(FieldPos("BVX_MSG")) > 0,Empty(M->BVX_MSG),Empty(M->BVX_MSG03)) .and. M->BVX_PARECE <> '3'
        Aviso( STR0115, STR0224,{ STR0231 }, 2 )//"Ao confirmar uma autorizaГЦo On-line И necessАrio indicar uma observaГЦo a Unimed (Msg. Geral)"
        lRet := .F.
    EndIf

	If lEnvTds .And. PlVerReg(aProAud[oOcorr:nAt]) 
	
		Msginfo(STR0247)      
		lRet := .F.		
	EndIf
	
EndIf

Return(lRet)

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPlStatTranЁ Autor Ё Microsiga	            Ё Data Ё 21.03.12 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Faz a Solicitacao de transacao (00360) do Ptu Online       Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlStatTran()
LOCAL cTranOri   := ""
LOCAL cStatus    := ""
LOCAL cDtValid   := ""
LOCAL nI         := 0
LOCAL nX         := 0
LOCAL nFor       := 0
LOCAL nPos       := 0
LOCAL lAudit     := .F.
LOCAL aDados     := {}
LOCAL aDadosOri  := {}
LOCAL aProc      := {}
LOCAL aProcRes   := {}
LOCAL aRet       := {}
LOCAL aRetBTU    := {}
LOCAL aRetOln    := {}
LOCAL aIte       := {}
LOCAL cCodDePara := {}
LOCAL dDatPro
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica procedimentos da transacao do procedimento selecioanado           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTranOri := PlsPtuGet( "NRTROL",aProAud[oOcorr:nAt] )
For nX := 1 to Len(aProAud)
	If PlsPtuGet( "NRTROL",aProAud[nX] ) == cTranOri
		AaDd(aProc,{cValtoChar(PlsPtuGet( "QTDPRO",aProAud[nX] )),;
		Alltrim(PlsPtuGet( "CODPRO",aProAud[nX] )),;
		Alltrim(PlsPtuGet( "DESPRO",aProAud[nX] )),;
		"0",;
		Stod(PlsPtuGet("DATPRO",aProAud[nX])),;
		 Alltrim(PlsPtuGet("CODPAD",aProAud[nX] )) })

		dDatPro := Stod(PlsPtuGet("DATPRO",aProAud[nX]))
	EndIf
Next

aDadosOri := PlsGetBSA( Alltrim(cTranOri) )

PlsPtuPut("CD_TRANS","00360",aDados)
PlsPtuPut("TP_CLIENTE","UNIMED",aDados)
PlsPtuPut("CD_UNI_EXE",PlsIntPad(),aDados)
PlsPtuPut("CD_UNI_BEN",PlsPtuGet("CD_UNI_DES",aDadosOri[1] ),aDados)
PlsPtuPut("CUNIDOM",PlsPtuGet("CD_UNI_DES",aDadosOri[1] ),aDados)
PlsPtuPut("NR_IDENT_E",cTranOri,aDados)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe procedimentos que serao solicitados								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRet := PLSCRIGEN(aProc,{{STR0083,"@N",30}, {STR0119,"@C",50} , {"DescriГЦo","@C",90 } },"Procedimentos solicitados")//Quantidade ### CСdigo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se tem comunicacao											     |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If aRet[1]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza comunicacao com a outra operadora                       		 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3) ,.T.,.F.,nil ) }, STR0220 , STR0125, .F.) //"Aguarde..." //'Comunicando'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se houve retorno 00210/00310 (falha na transacao)       		 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
		BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
		If BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
			Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
		Else
			Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
		EndIf
		Return
	ElseIf Len(aRetOln) > 0 .And. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00361"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se todos os procedimentos estao na resposta					 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nX := 1 to Len(aRetOln[2])
		
			If allTrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen)

				If ExistBlock("PLPTUITE")
	                
	                aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])),"SOLENT","",nil,nil,AllTrim(cTranOri),nil})
                    
                    If ( nPos := aScan(aProc,{|x| x[2] == Alltrim(aPlPtuIte[2]) .And. Upper(x[3]) == Upper(Alltrim(PlsPtuGet("DS_SERVICO",aRetOln[2][nX]))) })) > 0
				       aProc[nPos][4] := "1" //1 - Procedimento analisado
					   Aadd(aProc[nPos],Alltrim(PlsPtuGet("ID_RESPOST",aRetOln[2][nX]))) //Adiciona o ID de resposta
				    EndIf
				    
                Else
                    If ( nPos := aScan(aProc,{|x| x[2] == Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])) .And. Upper(x[3]) == Upper(Alltrim(PlsPtuGet("DS_SERVICO",aRetOln[2][nX]))) .And.  AllTrim(x[4]) $  "0 " })) > 0
					    aProc[nPos][4] := "1" //1 - Procedimento analisado
					    Aadd(aProc[nPos],Alltrim(PlsPtuGet("ID_RESPOST",aRetOln[2][nX]))) //Adiciona o ID de resposta
				    EndIf
				EndIf
			Else
				If ExistBlock("PLPTUITE")
	                aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])),"SOLENT","",nil,nil,AllTrim(cTranOri),nil})
	                
	                If (nPos := aScan(aProc,{|x| x[2] == Alltrim(aPlPtuIte[2]) })) > 0
					    aProc[nPos][4] := "1" //1 - Procedimento analisado
					    Aadd(aProc[nPos],Alltrim(PlsPtuGet("ID_RESPOST",aRetOln[2][nX]))) //Adiciona o ID de resposta
				    EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   			//Ё Realiza De-Para PTU Online atraves da tabela B1M                         |
	  			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	            ElseIf GetNewPar("MV_PTDPION","0") == "1"
	            	
	            	PLBusProTab(Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])),.F.,,dDatPro,,,,,)
					
					If BR8->(Found())
						cCodDePara := BR8->BR8_CODPSA
					Else
						cCodDePara := Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX]))
					Endif
					
	                If (nPos := aScan(aProc,{|x| AllTrim (x[2]) == Alltrim(cCodDePara) .And.  AllTrim(x[4]) $  "0 " })) > 0 				    
					    aProc[nPos][4] := "1" //1 - Procedimento analisado
					    Aadd(aProc[nPos],Alltrim(PlsPtuGet("ID_RESPOST",aRetOln[2][nX]))) //Adiciona o ID de resposta
				    EndIf
			    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   			//Ё Realiza De-Para PTU Online atraves da tabela BTU                         |
	  			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	            ElseIf GetNewPar("MV_PTDPION","0") == "2"
	            	aRetBTU := PTUDePaBTU(PlsPtuGet("TP_TABELA",aRetOln[2][nX]),Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])),,.T.,)
					
					If len(aRetBTU) > 0
						cCodDePara := aRetBTU[2]
					Else
						cCodDePara := Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX]))
					Endif
					
	                If (nPos := aScan(aProc,{|x| AllTrim (x[2]) == Alltrim(cCodDePara) .And.  AllTrim(x[4]) $  "0 " })) > 0 				    
					    aProc[nPos][4] := "1" //1 - Procedimento analisado
					    Aadd(aProc[nPos],Alltrim(PlsPtuGet("ID_RESPOST",aRetOln[2][nX]))) //Adiciona o ID de resposta
				    EndIf

	            Else
	                If (nPos := aScan(aProc,{|x| AllTrim(x[2])  == Alltrim(PlsPtuGet("CD_SERVICO",aRetOln[2][nX])) .And.  AllTrim(x[4]) $  "0 " })) > 0 				    
					    aProc[nPos][4] := "1" //1 - Procedimento analisado
					    Aadd(aProc[nPos],Alltrim(PlsPtuGet("ID_RESPOST",aRetOln[2][nX]))) //Adiciona o ID de resposta
				    EndIf
				EndIf
			Endif
		Next
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё So continua a verificacao com todos os procedimentos pendentes no arquivo|
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If aScan(aProc,{|x|x[4] == "0"}) > 0
		    Aviso( STR0115, STR0233,{ STR0231 }, 2 )//"Atencao" ### "Arquivo de resposta esta incorreto, hА procedimentos pendentes sem resposta" ### "Ok"
		Else
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica os Ids de resposta		                                   		 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nX := 1 to Len(aProc)
			    If !aProc[nX][len(aProc[nX])] $ 	"12"
			        lAudit := .T.
			        Exit
			    EndIf
			Next
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se houver procedimentos pendentes, e exibida mensagem de pendente        |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		  	If lAudit
		  	    Aviso( STR0115, STR0234,{ STR0231 }, 2 )//"Atencao" ### "Os procedimentos solicitados ainda estЦo em estudo" ### "Ok"
			Else
                cTranDes := PlsPtuGet("NR_IDENT_B",aRetOln[1])
		        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		        //Ё Pega a Transacao original											     Ё
    		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    	    cResRev  := PlsPtuGet("DS_OBSERVA",aRetOln[1])
	    	    
		        aDadSeq  := PlsGetBSA(cTranOri)
		        
		        For nX := 1 To Len(aDadSeq[1])
		            If AllTrim(aDadSeq[1,nX,1]) <> "CD_TRANS"
			           PlsPtuPut(aDadSeq[1,nX,1],PlsPtuGet(aDadSeq[1,nX,1],aDadSeq[1]),aDados)
			        EndIf
		        Next

		        aIte := {}
		        For nI := 1 to Len(aRetOln[2])
			       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  			       //Ё Monta campos															    Ё
			       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			       cOldDesCri := ""
			       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			       //Ё Verifica se o registro enviado e do tipo pacote    					    Ё
			       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			       If PlsPtuGet("TP_TABELA",aRetOln[2][nI]) == "4"
			           cSql := " SELECT BLD_CODPRO FROM "+RetSqlName("BLD")+" BLD, "+RetSqlName("BLE")+" BLE WHERE "
                       cSql += "     BLD_FILIAL = '"+xFilial("BLD")+"'  "
                       cSql += " AND BLE_FILIAL = '"+xFilial("BLE")+"' "
                       cSql += " AND BLD_CODPRO = BLE_CODPRO "
                       cSql += " AND BLE_CODOPC = '"+PlsPtuGet("CD_SERVICO",aRetOln[2][nI])+ "' "
                       cSql += " AND BLE_PRINCI = '1' "
                       cSql += " AND BLD.D_E_L_E_T_ <> '*' "
                       cSql += " AND BLE.D_E_L_E_T_ <> '*' "

                       cSql := ChangeQuery(cSql)
                       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TmpPac",.T.,.F.)

                       TmpPac->(DbGotop())
                       While !TmpPac->( Eof() )
                           cCodPro := Alltrim(TmpPac->BLD_CODPRO)
                           TmpPac->( dbSkip() )
                       EndDo
                       TmpPac->( dbClosearea() )
			       Else
			           If ExistBlock("PLPTUITE")
	                       aPlPtuIte := ExecBlock("PLPTUITE",.F.,.F.,{PlsPtuGet("CD_SERVICO",aRetOln[2][nI]),"SOLENT","",nil,nil,AllTrim(cTranOri),nil})
	                       cCodPro := aPlPtuIte[2]
	                   Else
	                       cCodPro := PlsPtuGet("CD_SERVICO",aRetOln[2][nI])
	                   EndIf
		           EndIf
                   
        
                   nQtd 	  := val( PlsPtuGet("QT_AUTORIZ",aRetOln[2][nI] ) )		          
			       
			       cAutori    := PlsPtuGet("ID_RESPOST",aRetOln[2][nI])
			       cDtValid   := PlsPtuGet("DT_VALIDAD",aRetOln[2][nI])
			       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			       //Ё Nova Matriz para ajuste no be2										    Ё
			       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		           AaDd(aIte,{cCodPro,cAutori,nQtd,{},Alltrim(PlsPtuGet("DS_SERVICO",aRetOln[2][nI])),PlsPtuGet("TP_TABELA",aRetOln[2][nI]) , Alltrim(PlsPtuGet("DS_MENS_ES",aRetOln[2][nI])), Strzero(Val(PlsPtuGet("SQ_ITEM",aRetOln[2][nI])),2) } )    
			       //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			       //Ё Checa se nao foi autorizado											    Ё
			       //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		           If cAutori <> "2"
			          //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			          //Ё Mostra as criticas												       |
			          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			    	  For nFor := 1 To 5
				          //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				          //Ё Pendente Auditoria ou autorizacao empresa								   |
				          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				          If cAutori == "3" .Or. cAutori == "4"
	   				       	  If cAutori == "3"
			                      If PLSPOSGLO(PLSINTPAD(),__aCdCri052[1],__aCdCri052[2])
						              cCodCri := __aCdCri052[1]
		    		 			      cDesCri := PLSBCTDESC()
			     			      EndIf
			     			  Else
			                      If PLSPOSGLO(PLSINTPAD(),__aCdCri051[1],__aCdCri051[2])
				     			      cCodCri := __aCdCri051[1]
			 		    		      cDesCri := PLSBCTDESC()
			 		    	      EndIf
			 		    	  EndIf
					          //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					          //Ё Se a critica estiver disabled									      	   |
					          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			 			      If Empty(cCodCri)
			 				      cCodCri := "999"
			 				      cDesCri := "CRITICA DESABILITADA"
			 	    		  EndIf
				          //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				          //Ё Negado																   |
				          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    		              ElseIf cAutori == "1"
	                          cCodCri := PlsPtuGet("CD_MENS_E"+AllTrim(Str(nFor)),aRetOln[2][nI])
		                      cDesCri := ""
		                      If cCodCri <> "0000"
					    	      cDesCri := PlsRtcdCed(PlsIntPad(),cCodCri,3)
						     	  cCodCri := PlsRtcdCed(PlsIntPad(),cCodCri,4)
							      If !Empty(cDesCri)
								      PLSPtuLog( "CRITICA " + cDesCri )
    							  EndIf
	    					  EndIf
		    			  EndIf
			    	      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				          //Ё Implementa as criticas											 	   Ё
				          //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    				      If !Empty(cDesCri) .And. cDesCri <> cOldDesCri
	    				      AaDd( aIte[nI,4] ,{cCodCri,cDesCri,cAutori,PlsPtuGet("CD_MENS_E"+AllTrim(Str(nFor)),aRetOln[2][nI])} )
		    				  cOldDesCri := cDesCri
			    		  EndIf
				      Next
    		       EndIf
		        Next
		        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   			//Ё Realiza De-Para PTU Online atraves da tabela B1M                         |
	  			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		        If GetNewPar("MV_PTDPION","0") == "1"
		        	For nX := 1 to len(aIte)
			        	PLBusProTab(Alltrim(aIte[nX][1]),.F.,,dDatPro,,,,,)
						If BR8->(Found())
							aIte[nX][1] := Alltrim(BR8->BR8_CODPSA)
						Endif
					Next
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   			//Ё Realiza De-Para PTU Online atraves da tabela BTU                         |
	  			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
                If GetNewPar("MV_PTDPION","0") == "2"
		        	For nX := 1 to len(aIte)
		        		aRetBTU := PTUDePaBTU(Alltrim(aIte[nX][6]),Alltrim(aIte[nX][1]),,.T.,)
						If len(aRetBTU) > 0
					   		aIte[nX][1] := Alltrim(aRetBTU[2])
		                Endif
		   			Next
				EndIf

		        If cAutori == "2" .And. Empty(cDtValid) .And. LEN(aRetOln[1])>=1
			    	cDtValid   := PlsPtuGet("DT_VALIDAD",aRetOln[1])			       
			    EndIf
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		        //Ё Processa alteracao no cabecalho,item e critica da guia (bea,be2 e beg)   Ё
    		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	    	    cRet := PLSACOMP(Alltrim(cTranOri),Alltrim(cTranDes),cResRev,aIte,"00360",PlsIntPad(),cDtValid)
	    	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		        //Ё Monta tela com retorno                                                   Ё
    		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    		    For nX := 1 to len(aProc)
    		        Do Case
    		            Case aProc[nX][len(aProc[nX])] == "1"
    		                cStatus := "NEGADO"
    		            Case aProc[nX][len(aProc[nX])] == "2"
    		                cStatus := "AUTORIZADO"
    		            Case aProc[nX][len(aProc[nX])] == "3"
    		                cStatus := "PENDENTE EMPRESA"
    		            Case aProc[nX][len(aProc[nX])] == "4"
    		                cStatus := "PENDENTE AUDITORIA"
    		        EndCase

    		        nPos := aScan(aIte,{|x|x[1] == aProc[nX][2]})

    		        Aadd(aProcRes,{aProc[nX][2],aProc[nX][3],aIte[nPos][3],cStatus})//Codigo#Descricao#Quantidade#Status
    		    Next
	    	    PLSCRIGEN(aProcRes,{{"CСdigo","@C",50}, {"DescriГЦo","@C",90 }, {"Quantidade","@N",30}, {"Status","@C",90 }},"Procedimentos solicitados") //
		    EndIf
		    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		    //Ё Se houve movimentacao, atualiza browse                                   Ё
    		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		    PLS790ATU()
		EndIf
	Else
	    PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
	    Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
	EndIf
EndIf

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё20/03/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё	  1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0001	, 'AxPesqui'  , 0 , K_Pesquisar  , 0 , .F.},;  //"Pesquisar"
						{ STR0002	, 'PLS790VIS' , 0 , K_Visualizar , 0 , Nil},; //"Visualizar"
      					{ STR0003	, 'PLS790LEG' , 0 , K_Visualizar , 0 , .F.}} //"Legenda"
Return(aRotina)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790TAB ╨Autor  ЁMicrosiga            ╨ Data Ё  11-11-21   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Chama funcao generica com o valor de cobranca da familia...╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS790TAB()


PLSA940()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetKey(VK_F11,	{|| AtualizaBr(oOcorr) })
SetKey(VK_F12,Iif( Len(aProAud) > 0, {|| Pergunte("PLA790",.T.), dDataDe := mv_par01, dDataAte := mv_par02 } , NIL) )
SetKey(VK_F7, {|| Iif( Len(aProAud) > 0, Eval(bF7) , NIL) } )
SetKey(VK_F5 ,{|| Iif( Len(aProAud) > 0, If(ValType(oButGuia)=="O",Eval(oButGuia:bAction),.t.) , NIL) } )

Return(NIL)


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS790BX9   ╨Autor  ЁMicrosiga           ╨ Data Ё  12/20/11   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё  SerА Utilizado para ImpressЦo e de Relatorio              ╨╠╠
╠╠╨          Ё  de Sinistralidade                                         ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function PLS790BX9  (dDataDe,dDataAte,cAlias,cAliasCab,cCodOpe ,cCodEmp ,cConEmp ,cVerCon ,cSubCon ,cVerSub,cFamDe ,cTipreg,cAno ,cAnoAte ,cMes,cMesAte,lRel,nNiv,cSqlIn )
LOCAL n			:= 0
LOCAL j 		:= 0
LOCAL nNiveis	:= 0
LOCAL cSql		:= ""
LOCAL cAnoMes	:= ''
LOCAL cBX9Name	:= RetSqlName("BX9")
LOCAL nMeses	:= 0
LOCAL nLiRec 	:= 0
LOCAL nLiSin 	:= 0
LOCAL nPosCol 	:= 0
LOCAL nReceita 	:= 0
LOCAL nCusto	:= 0
LOCAL nSinistr 	:= 0
LOCAL nRecTot	:= 0
LOCAL nCusTot	:= 0
LOCAL nCusUsr	:= 0
LOCAL nRecUsr   := 0
LOCAL nLiUsr 	:= 0
LOCAL nLiURc 	:= 0
LOCAL nLiUCs 	:= 0
LOCAL nTotRUsr	:= 0
LOCAL nTotCUsr	:= 0
LOCAL nLastFor	:= 0
LOCAL nUsuarios	:= 0
LOCAL lVazio    :=.T.
LOCAL cMacro 	:= ''
LOCAL aMeses	:= {{'01','JAN'},;
					{'02','FEV'},;
					{'03','MAR'},;
					{'04','ABR'},;
					{'05','MAI'},;
					{'06','JUN'},;
					{'07','JUL'},;
					{'08','AGO'},;
					{'09','SET'},;
					{'10','OUT'},;
					{'11','NOV'},;
					{'12','DEZ'}}


LOCAL aColControl 	:= {}
LOCAL aCab			:= {}
LOCAL aTipoCab		:= {}
LOCAL aDados		:= {}
Local dDataFim
Local cAnoPara		:= ""


DEFAULT cCodEmp		:= ""
DEFAULT cConEmp		:= ""
DEFAULT cVerCon		:= ""
DEFAULT cSubCon		:= ""
DEFAULT cVerSub		:= ""
DEFAULT cAno		:= ''
DEFAULT cMes		:= ''
DEFAULT cMesAte		:= ''
DEFAULT dDataDe		:= cTod('')
DEFAULT dDataAte  	:= cTod('')
DEFAULT cCodOpe		:= ""
DEFAULT lRel		:= .F.  //Variavel que Define se Veio do Relatorio PLSR996 ou Portal
Default cFamDe		:= ""
Default cTipReg		:= ""
Default nNiv		:=	0
Default cSqlIn		:=""
//Default nTipo		:= 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta array referencia...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd(aColControl, 'cargo')
Aadd(aColControl, 'cargo')
Aadd(aColControl, 'cargo')
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria array do cabecalho...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd(aCab, {'Nivel','@C',40})
Aadd(aCab, {'Tipo' ,'@C',45})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta array do cabecalho... NIVEL!                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aCab, {'Filler', "@E 99", 07} )
cAnoPara:=cAno
cAnoMes := iif(Empty(cAno),Substr(dTos(dDataDe),1,6),cAno+""+cMes)
nMeses  := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta array com o tipos de dados que contemplam o relatorio              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aTipoCab,"C")//Nivel
aadd(aTipoCab,"C")//Tipo
aadd(aTipoCab,"N")//Filler
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nNiv>0
	If dDataAte>dDataBase
		dDataAte:=dDataBase
	Endif                 
Endif 
While (cAnoMes <= iif(dDataAte==cTod(''),cAnoAte+""+cMesAte,dTos(dDataAte)))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta array de controle...                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd( aColControl, cAnoMes )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta array do cabecalho...                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd( aCab, {Substr(cAnoMes,1,4)+"/"+aMeses[Val(Substr(cAnoMes,5,2))][2], "@E 999,999,999.99", 35} )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula e trata o periodo solicitado...                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cMes := StrZero((Val(Substr(cAnoMes,5,2)) + 1),2)
	cAno := Substr(cAnoMes,1,4)
	If cMes > '12'
		cMes := '01'
		cAno := Alltrim(Str(Val(Substr(cAnoMes,1,4))+1))
	Endif
	cAnoMes := cAno+cMes
	nMeses++

	aadd(aTipoCab,"N")//Adiciona Mes
Enddo
aadd(aTipoCab,"N")//Total
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Adiciona coluna de total no cabecalho do browse...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aCab, {"Total", "@E 999,999,999.99", 35} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё For																		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nNiveis := 1 To 5  // Nivel a Nivel...5
	IF !lRel
		If  !Empty(cAlias)
			If     cAlias == "BG9"
				cCodEmp := BG9->BG9_CODIGO
				If  nNiveis <> 1
					Loop
				Endif
			ElseIf cAlias == "BQC"
				cCodEmp := substr(BQC->BQC_CODIGO,5,4)
				cConEmp := BQC->BQC_NUMCON
				cVerCon := BQC->BQC_VERCON
				cSubCon := BQC->BQC_SUBCON
				cVerSub := BQC->BQC_VERSUB
				If  nNiveis > 3
					Loop
				Endif
			Else
				cCodEmp := BA1->BA1_CODEMP
				cConEmp := BA1->BA1_CONEMP
				cVerCon := BA1->BA1_VERCON
				cSubCon := BA1->BA1_SUBCON
				cVerSub := BA1->BA1_VERSUB
				cFamDe	:= BA1->BA1_MATRIC
				cTipReg := BA1->BA1_TIPREG
			Endif
		Else
			cCodEmp := &(cAliasCab+"->"+cAliasCab+"_CODEMP")
			cConEmp := &(cAliasCab+"->"+cAliasCab+"_CONEMP")
			cVerCon := &(cAliasCab+"->"+cAliasCab+"_VERCON")
			cSubCon := &(cAliasCab+"->"+cAliasCab+"_SUBCON")
			cVerSub := &(cAliasCab+"->"+cAliasCab+"_VERSUB")
			cFamDe  := &(cAliasCab+"->"+cAliasCab+"_MATRIC")
			cTipreg := &(cAliasCab+"->"+cAliasCab+"_TIPREG")
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Select																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cSql := "SELECT * FROM "+cBX9Name+" BX9 WHERE BX9_FILIAL = '"+xFilial("BX9")+"' "
	cSql += "AND BX9.D_E_L_E_T_ <> '*' "
	If dDataAte<>cTod('')
		cSql += "AND BX9_ANO >= '"+Substr(dTos(dDataDe),1,4)+"'  "
		cSql += "AND BX9_ANO <= '"+Substr(dTos(dDataAte),1,4)+"' "
	Else
		cSql += "AND BX9_ANO >= '"+cAnoPara+"'  "
		cSql += "AND BX9_ANO <= '"+cAnoAte+"' "

	Endif
    If nNiv>0
    	nNiveis:=nNiv
    Endif
	If nNiveis == 1
		cSql += "AND BX9_CODEMP = '"+cCodEmp+"' "
		cSql += "AND BX9_TIPO   = '1' "
		__cNivel := "Empresa"
	Elseif nNiveis == 2
		cSql += "AND BX9_CODEMP = '"+cCodEmp+"' "
		cSql += "AND BX9_CONEMP = '"+cConEmp+"' "
		cSql += "AND BX9_VERCON = '"+cVerCon+"' "
		cSql += "AND BX9_TIPO   = '2' "
		__cNivel := "Contrato"
	Elseif nNiveis == 3
		cSql += "AND BX9_CODEMP = '"+cCodEmp+"' "
		cSql += "AND BX9_CONEMP = '"+cConEmp+"' "
		cSql += "AND BX9_VERCON = '"+cVerCon+"' "
		cSql += "AND BX9_SUBCON = '"+cSubCon+"' "
		cSql += "AND BX9_VERSUB = '"+cVerSub+"' "
		cSql += "AND BX9_TIPO   = '3' "
		__cNivel := "Subcontrato"//STR0217 //"Sub Contrato"
	Elseif nNiveis == 4

		cSql += "AND BX9_CODEMP = '"+cCodEmp+"' "
		cSql += "AND BX9_CONEMP = '"+cConEmp+"' "
		cSql += "AND BX9_VERCON = '"+cVerCon+"' "
		cSql += "AND BX9_SUBCON = '"+cSubCon+"' "
		cSql += "AND BX9_VERSUB = '"+cVerSub+"' "
		cSql += "AND BX9_MATRIC = '"+cFamDe +"' "
		cSql += "AND BX9_TIPO   = '4' "
		__cNivel := STR0140 //"Familia"
	Elseif nNiveis == 5
			If Empty(cSqlIn)
		cSql += "AND BX9_CODEMP = '"+cCodEmp+"' "
		cSql += "AND BX9_CONEMP = '"+cConEmp+"' "
		cSql += "AND BX9_VERCON = '"+cVerCon+"' "
		cSql += "AND BX9_SUBCON = '"+cSubCon+"' "
		cSql += "AND BX9_VERSUB = '"+cVerSub+"' "
		cSql += "AND BX9_MATRIC = '"+cFamDe+"' "
		cSql += "AND BX9_TIPREG = '"+cTipReg+"' "
		cSql += "AND BX9_TIPO   = '5' "
			Else
				cSql +=	cSqlIn 
			Endif
		__cNivel := "BeneficiАrio"//STR0099 //"Usuario"
	Endif
	cSql += "Order by BX9_ANO"
	PlsQuery(cSql, "TRB790")

	IF TRB790->( Eof() )
		TRB790->( dbCloseArea() )
	Loop
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Insere as quatro linhas necessarios para apresentar os valores no array  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BX9->( FieldPos("BX9_USRJAN") ) > 0
		nLastFor := 6
	Else
		nLastFor := 4
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё For																		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For n := 1 To nLastFor
		Aadd(aDados, Array((nMeses+4)) )
	Next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula as linhas referencias relativas ao nivel a ser apresentado...    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BX9->( FieldPos("BX9_USRJAN") ) > 0
		nLiRec := Len(aDados)-5       //1
		nLiCus := Len(aDados)-4       //2
		nLiUsr := Len(aDados)-3	      //3
		nLiURc := Len(aDados)-2       //4
		nLiUCs := Len(aDados)-1		  //5
		nLiSin := Len(aDados)         //6
	Else
		nLiRec := Len(aDados)-3
		nLiCus := Len(aDados)-2
		nLiSin := Len(aDados)-1
	Endif
	lVazio:=.T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё While																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While !TRB790->( Eof() )
		lVazio:=.F.
		aDados[nLiRec][1] 		:= __cNivel
		aDados[nLiRec][2] 		:= 'Receitas'
		aDados[nLiRec][3]		:= nNiveis
		aDados[nLiCus][2] 		:= 'Custos'
		aDados[nLiCus][3]		:= nNiveis

		If BX9->( FieldPos("BX9_USRJAN") ) > 0
			aDados[nLiUsr][2] 		:= 'Beneficiarios'
			aDados[nLiUsr][3]		:= nNiveis
			aDados[nLiURc][2] 		:= 'Receita p/ Benefic'
			aDados[nLiURc][3]		:= nNiveis
			aDados[nLiUCs][2] 		:= 'Custo p/ Benefic'
			aDados[nLiUCs][3]		:= nNiveis
		Endif
		aDados[nLiSin][2] 		:= 'Sinistralidade % '
		aDados[nLiSin][3]		:= nNiveis
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Confirma intervalo de datas...                                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For j := 1 To Len(aMeses)
			If !((TRB790->BX9_ANO+aMeses[j][1]) >= iif(dDataAte<>cTod('') ,Substr(dTos(dDataDe),1,6),cAnoPara) .and.;
				(TRB790->BX9_ANO+aMeses[j][1]) <= iif(dDataAte<>cTod('') ,Substr(dTos(dDataAte),1,6),cAnoAte))
				Loop
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Encontra a posicao do array onde sera inseria a informacao...            Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If (nPosCol := Ascan(aColControl, (TRB790->BX9_ANO+aMeses[j][1]) )) == 0
				Loop
			Endif
			nReceita := &("TRB790->BX9_VRR"+aMeses[j][2])
			nRecTot  += &("TRB790->BX9_VRR"+aMeses[j][2])
			nCusto	 := &("TRB790->BX9_VRC"+aMeses[j][2])
			nCusTot  += &("TRB790->BX9_VRC"+aMeses[j][2])
			cMacro := "BX9_USR"+aMeses[j][2]
			If BX9->( FieldPos(cMacro) ) > 0
				cMacro := "TRB790->BX9_USR"+aMeses[j][2]
				nUsuarios := &cMacro
			Endif

			If nReceita > 0
				nSinistr := ((nCusto/nReceita)*100)
			Else
				nSinistr := GetNewPar("MV_PLSSDPD",1000)
			Endif

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Media mensal de custos / Receitas por usuario por mes.					 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nRecUsr := (nReceita/nUsuarios)
			nCusUsr := (nCusto/nUsuarios)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Media total de custo / receita por usuario no periodo.					 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nTotRUsr += nRecUsr
			nTotCUsr += nCusUsr
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava os valores referentes a receita...                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nReceita <> 0
				If Valtype(aDados[nLiRec][nPosCol]) <> 'N'
					aDados[nLiRec][nPosCol] := nReceita
				Else
					aDados[nLiRec][nPosCol] += nReceita
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava os valores referentes ao custo...                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nCusto <> 0
				If Valtype(aDados[nLiCus][nPosCol]) <> 'N'
					aDados[nLiCus][nPosCol] := nCusto
				Else
					aDados[nLiCus][nPosCol] += nCusto
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava os valores referentes a sinistralidade...                          Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nSinistr <> 0
				If Valtype(aDados[nLiSin][nPosCol]) <> 'N'
					aDados[nLiSin][nPosCol] := nSinistr
				Else
					aDados[nLiSin][nPosCol] += nSinistr
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava os valores referentes a analise por usuario...                     Ё
			//Ё Total de usuarios...													 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nUsuarios <> 0
				If Valtype(aDados[nLiUsr][nPosCol]) <> 'N'
					aDados[nLiUsr][nPosCol] := nUsuarios
				Else
					aDados[nLiUsr][nPosCol] += nUsuarios
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Receita media por usuarios...										 	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nRecUsr <> 0
				If Valtype(aDados[nLiURc][nPosCol]) <> 'N'
					aDados[nLiURc][nPosCol] := nRecUsr
				Else
					aDados[nLiURc][nPosCol] += nRecUsr
				Endif
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Custo medico por usuario												 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nCusUsr <> 0
				If Valtype(aDados[nLiUCs][nPosCol]) <> 'N'
					aDados[nLiUCs][nPosCol] := nCusUsr
				Else
					aDados[nLiUCs][nPosCol] += nCusUsr
				Endif
			Endif
		Next
		TRB790->( dbSkip() )
	Enddo
	If !lVazio
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Adicionando os totais...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aDados[nLiRec][Len(aDados[nLiRec])] := nRecTot
		aDados[nLiCus][Len(aDados[nLiCus])] := nCusTot
		aDados[nLiSin][Len(aDados[nLiSin])] := ((nCusTot/nRecTot)*100)
		If BX9->( FieldPos("BX9_USRJAN") ) > 0
			aDados[nLiURc][Len(aDados[nLiURc])] := nTotRUsr
			aDados[nLiUCs][Len(aDados[nLiUCs])] := nTotCUsr
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha area de trabalho...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nRecTot := 0
	nCusTot := 0
	nTotRUsr := 0
	nTotCUsr := 0
	TRB790->( dbCloseArea() )
Next

Return({aDados,aCab,aTipoCab})

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSHISMOV  Ё Autor ЁEverton M. Fernandes Ё Data Ё 19.12.12 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Exibe o historico de mov. da auditoria                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSHISMOV(aDados,aCabec,cTitulo,lret,cMatric,cNumAut,lPrim)

LOCAL nOpca		:= 0
LOCAL i			:= 0
LOCAL j			:= 0

Local cLin1		:= 0
Local cLin2		:= 0
Local cCol1		:= 0
Local cCol2		:= 0
Local cTexto		:= ""
Local cAux			:= ""
Local oGrid		:= Nil
Local nPos	:=0
Local nPos1	:=0
Local nNumt:=0
Local nPend:=0
Local ni		:=0
Local nProAud := 0 //Procedimentos auditados
Local nPosPri := 0 //Primeiro procedimento da guia
Local nPosPPe := 0 //Primeiro procedimento pendente
Local aBtnEnc	:= {}

Private oMemo	:= Nil
Private oDlg	:= Nil
Private oFont	:= Nil

Default aDados	:= {}
Default aCabec	:= {}
Default cTitulo	:= ""
Default cMatric	:= ""
Default lret	:=.F.
// Define fonte para alihar informacoes no plscrigen.
Define FONT oFont NAME "Courier New" Size 08,15 //BOLD


If Len(aDados) == 0
   Help("",1,"PLSCRIGEN")
   Return
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aSize    := MsAdvSize()
	aObjects := {}
AAdd( aObjects, { 100, 40, .t., .t.,.t. } )
AAdd( aObjects, { 100, 60, .t., .t.,.t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )

	cLin1 := aSize[7]
	cCol1 := 0
	cLin2 := aSize[6]
	cCol2 := aSize[5]

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2 of oMainWnd pixel


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza a informaГЦo da Grid Historico                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

PLS790ATU(cMatric,.T.,lPrim)

nNumt := PL790POS("NUMAUT",aProAud) //Posicao do numero da autorizacao da matriz
nPend := PL790POS("PENDEN",aProAud) //Posicao da indicacao de pendente(1) ou nao(0)

For nProAud := 1 TO Len(aProAud)

	If nPos > 0 .And. aProAud[nProAud][nNumt][2] <> cNumAut //Se ja tenho a guia e mudou a guia
		Exit
	EndIf

	nPosPri := aScan(aProAud[nProAud][nNumt], {| aVet | aVet == cNumAut })
	nPosPPe := aScan(aProAud[nProAud][nPend], {| aVet | aVet == "1" })

	If nPosPri > 0
		If nPos == 0 .Or. nPosPPe <> 0
			nPos := nProAud //Posicao da matriz que encontrei a procedimento da guia
		EndIf
	EndIf

Next nProAud

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria obj																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oGrid := TcBrowse():New(aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,,, oDlg,,,,,,,,,,,,.F.,,.T.,,.F., )
//Ё BitMap																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Add COLUMN TO oGrid BITMAP DATA {|| Iif( Len(aProAud)>0, Iif( aProAud[oGrid:nAt,PL790POS("PENDEN",aProAud),2 ] <> "1",;
															    Iif( aProAud[oGrid:nAt,PL790POS("SOLREV",aProAud),2 ] == "1" ,;
															         LoadBitmap( GetResources(), "BR_AZUL" ),;
																     LoadBitmap( GetResources(), "BR_VERDE" ) ),;
															    	 LoadBitmap( GetResources(), "BR_AMARELO" ) ),;
															     )  } TITLE "" WIDTH 015 NOHILITE
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Colunas																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oGrid:AddColumn(TcColumn():New(STR0017			,NIL,NIL,NIL,NIL,NIL,015,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Ano"
oGrid:ACOLUMNS[2]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt ,PL790POS("ANOAUTINT",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0018			,NIL,NIL,NIL,NIL,NIL,015,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Mes"
oGrid:ACOLUMNS[3]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("MESAUTINT",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0019	,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Num.Autoriz."
oGrid:ACOLUMNS[4]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("NUMAUT",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0133	,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Num.Internac."
oGrid:ACOLUMNS[5]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("NUMINT",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0134	,NIL,NIL,NIL,NIL,NIL,035,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Prorrogacao"
oGrid:ACOLUMNS[6]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("PRORRO",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0020  	,NIL,NIL,NIL,NIL,NIL,030,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Data Proc."
oGrid:ACOLUMNS[7]:BDATA  := { || If(Len(aProAud)>0,StoD(aProAud[oGrid:nAt,PL790POS("DATPRO",aProAud),2]),) }

oGrid:AddColumn(TcColumn():New(STR0021			,NIL,NIL,NIL,NIL,NIL,015,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Qtd"
oGrid:ACOLUMNS[8]:BDATA  := { || If(Len(aProAud)>0,TransForm(aProAud[oGrid:nAt,PL790POS("QTDPRO",aProAud),2],"@E 9999.99"),) }

oGrid:AddColumn(TcColumn():New("CСd. Tab."			,NIL,NIL,NIL,NIL,NIL,020,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Cod. Tab."
oGrid:ACOLUMNS[9]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("CODPAD",aProAud),2],) }

oGrid:AddColumn(TcColumn():New("CСd Proc."			,NIL,NIL,NIL,NIL,NIL,035,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Procedimento"
oGrid:ACOLUMNS[10]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("CODPRO",aProAud),2],) }

oGrid:AddColumn(TcColumn():New("Procedimento"			,NIL,NIL,NIL,NIL,NIL,150,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Procedimento"
oGrid:ACOLUMNS[11]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("DESPRO",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0135			,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"CID"
oGrid:ACOLUMNS[12]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("CID",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0022	,NIL,NIL,NIL,NIL,NIL,135,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Nome Usuario"
oGrid:ACOLUMNS[13]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("NOMUSR",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0023		,NIL,NIL,NIL,NIL,NIL,150,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Nome RDA"
oGrid:ACOLUMNS[14]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("NOMRDA",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0024	,NIL,NIL,NIL,NIL,NIL,060,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Mat. Antiga"
oGrid:ACOLUMNS[15]:BDATA  := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("MATANT",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0136			,NIL,NIL,NIL,NIL,NIL,030,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Cod. Local"
oGrid:ACOLUMNS[16]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("CODLOC",aProAud),2],) }

oGrid:AddColumn(TcColumn():New(STR0137			,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Descr. Local"
oGrid:ACOLUMNS[17]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("DESLOC",aProAud),2],) }

If BE2->( FieldPos("BE2_NRTROL") ) > 0 .And. BQV->( FieldPos("BQV_NRTROL") ) > 0 .And. BE2->( FieldPos("BE2_NRTROL") ) > 0 .And. GetNewPar("MV_PLEVSAD","0") == "1"
    oGrid:AddColumn(TcColumn():New("Nr. Tran Online"		,NIL,NIL,NIL,NIL,NIL,040,.F.,.F.,NIL,NIL,NIL,.F.,NIL)) //"Nr. Tran Online"
    oGrid:ACOLUMNS[18]:BDATA := { || If(Len(aProAud)>0,aProAud[oGrid:nAt,PL790POS("NRTROL",aProAud),2],) }
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Set Array																   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

oGrid:SetArray(aProAud)
oGrid:nAt:=npos

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё DBLCLICK																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oGrid:bChange		:= {|| PLSATUMM( PlsPtuGet( "OPEMOV",aProAud[oGrid:nAt] ),;  //"Movto Aud."
																							 PlsPtuGet( "ANOAUTINT",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "MESAUTINT",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "NUMAUT",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "CODPAD",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "CODPRO",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "CODEMP",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "MATRIC",aProAud[oGrid:nAt] ),;
																							 PlsPtuGet( "TIPREG",aProAud[oGrid:nAt] ),.t. ),oMemo:Refresh()  }






//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Prepara o texto para ser exibido                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

For i := 1 To Len(aDados) step 2
	For j := 1 To Len(aCabec)
		If j >= 7 //Processa os campos da segunda linha do array
			cTexto += aCabec[j,1] + ": " + aDados[i+1,j] + chr(13) + chr(10)
		Else	//Processa os campos da 1╙ linha
			If ValType(aDados[i,j]) = "D"
				cAux := DtoC(aDados[i,j])
			Else
				cAux := aDados[i,j]
			EndIf
			cTexto += aCabec[j,1] + ": " + cAux + chr(13) + chr(10)
		EndIf
	Next j
	cTexto += Replicate("-",30) + chr(13) + chr(10) + chr(13) + chr(10)
Next i


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o memo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

@ aPosObj[2][1], aPosObj[2][2] Get oMemo Var cTexto Memo Size aPosObj[2][3], aPosObj[2][4]*0.97 Of oDlg Pixel
oMemo:oFont     := oFont
oMemo:lReadOnly := .T.

aAdd(aBtnEnc,{'',{||PLS790LEG(1)},"Legenda"}) 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa dialogo....                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,{ ||nOpc := 0, PLS790ATU(,.F.),oDlg:End() },{ ||nOpc := 0, PLS790ATU(,.F.),oDlg:End() },.F.,aBtnEnc ) } ) Center

Return

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддбддддддддддддддддд©╠╠
╠╠ЁFuncao    Ё PlsPosGui  Ё Autor ЁVictor Ferreira e Silva Ё Data Ё 19.12.12 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддддддаддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Funcao utili. para posicionar a guia correta ao pressionar F7 Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlsPosGui()

cAliProAud := PlsPtuGet( "NOMALIAS",aProAud[oOcorr:nAt] )
cRecProAud := PlsPtuGet( "VALRECNO",aProAud[oOcorr:nAt] )

Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSATUMM   ╨Autor  ЁMicrosiga           ╨ Data Ё  04/18/13   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁAtualiza a Memo do historico Na Auditoria Procedimento      ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static function PLSATUMM(cOpeMov,cAnoAut,cMesAut,cNumAut,cCodPad,cCodPro)
LOCAL cSql		:= ""
LOCAL aMatDad 	:= {}
LOCAL aCab		:= {}
LOCAL cMsg		:= ""
LOCAL aArea	:= GetArea()
Local i, j:=0
Local cAux	:=""
Local cTexto:=""


If BVX->( FieldPos("BVX_MSG")) > 0
	aCab :={   {STR0191     	,"@d",050},; //"Cod. Auditor"
			   {STR0192     	,"@C",090},; //"Nome Auditor"
			   {STR0193		,"@D",040},; //"Data Parecer"
			   {STR0070   	,"@C",050},; //"Parecer"
			   {STR0194	  	,"@N",020},; //"Motivo"
			   {STR0195		,"@N",200},; //"Descricao Motivo"
			   {STR0196 	  	,"@C",200},; //"Solicitacao Revisao"
			   {STR0197	  	,"@C",220}} //"Mensagem"
Else
	aCab :={   {STR0191     	,"@d",050},; //"Cod. Auditor"
			   {STR0192     	,"@C",090},; //"Nome Auditor"
			   {STR0193		,"@D",040},; //"Data Parecer"
			   {STR0070   	,"@C",050},; //"Parecer"
			   {STR0194	  	,"@N",020},; //"Motivo"
			   {STR0195		,"@N",200},; //"Descricao Motivo"
			   {STR0196 	  	,"@C",200},; //"Solicitacao Revisao"
			   {STR0197	  	,"@C",220},; //"Mensagem"
			   {STR0198 	  	,"@C",200},; //"Informacao"
			   {STR0199 		,"@C",220}}  //"Msg. Geral"
EndIf

//If ExistBlock("P790MAUD")
//	ExecBlock("P790MAUD",.F.,.F.,{cOpeMov,cAnoAut,cMesAut,cNumAut,cCodPad,cCodPro})
//	Return
//Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona da mesma nota todo o historico do procedimento auditado		   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql := " SELECT BVX_ANOAUT,BVX_MESAUT,BVX_NUMAUT,BVX_CODAUD,BVX_NOMAUD,BVX_DATPAR,BVX_PARECE, "
cSql += " 	     BVX_MOTIVO,BVX_DESMOT,"+Iif(BVX->( FieldPos("BVX_SOLREV") ) > 0,"BVX_SOLREV","''")+", R_E_C_N_O_"
If BVX->(FieldPos("BVX_MSG")) = 0
	cSql += ",BVX_MSG01,BVX_MSG02,BVX_MSG03,BVX_MSG04,BVX_MSG05"
Endif
cSql += " FROM "+RetSQLName("BVX")
cSql += " WHERE BVX_FILIAL  = '"+xFilial("BVX")+"'"
cSql += "   AND BVX_OPEMOV  = '"+cOpeMov+"'"
cSql += "   AND BVX_ANOAUT  = '"+cAnoAut+"'"
cSql += "   AND BVX_MESAUT  = '"+cMesAut+"'"
cSql += "   AND BVX_NUMAUT  = '"+cNumAut+"'"
cSql += "   AND BVX_CODPAD  = '"+cCodPad+"'"
cSql += "   AND BVX_CODPRO  = '"+cCodPro+"'"
cSql += "   AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY BVX_DATPAR, R_E_C_N_O_  "
PLSQuery(cSQL,"PLSMOVAUD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While para montar matriz exibir na crigen								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

While !PLSMOVAUD->( Eof() )
    If BVX->(FieldPos("BVX_MSG")) > 0
    	AaDd(aMatDad,{PLSMOVAUD->BVX_CODAUD,PLSMOVAUD->BVX_NOMAUD,PLSMOVAUD->BVX_DATPAR,AllTrim(X3COMBO("BVX_PARECE",PLSMOVAUD->BVX_PARECE)),PLSMOVAUD->BVX_MOTIVO,PLSMOVAUD->BVX_DESMOT,"",""} )

    	//Retorna o campo MSG que И do tipo MEMO.
    	BVX->(DbGoto(PLSMOVAUD->R_E_C_N_O_))
    	
    	cMsg := PTURemChr(BVX->BVX_MSG)

    	AaDd(aMatDad,{"","","","","","",Iif(BVX->( FieldPos("BVX_SOLREV") ) > 0,PLSMOVAUD->BVX_SOLREV,''),AllTrim(cMsg)} )
    Else
    	AaDd(aMatDad,{PLSMOVAUD->BVX_CODAUD,PLSMOVAUD->BVX_NOMAUD,PLSMOVAUD->BVX_DATPAR,AllTrim(X3COMBO("BVX_PARECE",PLSMOVAUD->BVX_PARECE)),PLSMOVAUD->BVX_MOTIVO,PLSMOVAUD->BVX_DESMOT,"","","",""} )
    	AaDd(aMatDad,{"","","","","","",Iif(BVX->( FieldPos("BVX_SOLREV") ) > 0,PLSMOVAUD->BVX_SOLREV,''),AllTrim(PLSMOVAUD->BVX_MSG01)+" "+AllTrim(PLSMOVAUD->BVX_MSG02),AllTrim(PLSMOVAUD->BVX_MSG03),AllTrim(PLSMOVAUD->BVX_MSG04)+" "+AllTrim(PLSMOVAUD->BVX_MSG05)} )
    EndIf
	PLSMOVAUD->( DbSkip() )
EndDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha																	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSMOVAUD->( DbCloseArea() )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Prepara o texto para ser exibido                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

if len(aMatDad)>0
For i := 1 To Len(aMatDad) step 2
	For j := 1 To Len(aCab)
		If j >= 7 //Processa os campos da segunda linha do array
			cTexto += aCab[j,1] + ": " + aMatDad[i+1,j] + chr(13) + chr(10)
		Else	//Processa os campos da 1╙ linha
			If ValType(aMatDad[i,j]) = "D"
				cAux := DtoC(aMatDad[i,j])
			Else
				cAux := aMatDad[i,j]
			EndIf
			cTexto += aCab[j,1] + ": " + cAux + chr(13) + chr(10)
		EndIf
	Next j
	cTexto += Replicate("-",30) + chr(13) + chr(10) + chr(13) + chr(10)
Next i
Endif

@ aPosObj[2][1], aPosObj[2][2] Get oMemo Var cTexto Memo Size aPosObj[2][3], aPosObj[2][4]*0.97 Of oDlg Pixel
oMemo:oFont     := oFont
oMemo:lReadOnly := .T.

RestArea(aArea)

Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL790VCONH╨Autor  ЁMicrosiga           ╨ Data Ё  05/10/13   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Function PL790VCONH(cEntidade,cChvConh)
Local aArea := GetArea()
Local lRet := .T.
AC9->(DbSetOrder(2)) // // AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_
lRet := AC9->(MsSeek(xFilial("AC9") + cEntidade + xFilial(cEntidade) + cChvConh))
RestArea(aArea)
Return(lRet)

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPlDecPrazoЁ Autor Ё Microsiga	            Ё Data Ё 19.01.15 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Faz a Solicitacao de transacao (00360) do Ptu Online       Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlDecPrazo()
LOCAL cTranOri   := allTrim(PlsPtuGet( "NRTROL",aProAud[oOcorr:nAt] ))
LOCAL nI         := 0
LOCAL nX         := 0
LOCAL aDados     := {}
LOCAL aDadosOri  := {}
LOCAL aProc      := {}
LOCAL aRet       := {}
LOCAL aRetOln    := {}
LOCAL aIte       := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica procedimentos da transacao do procedimento selecioanado           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
for nX := 1 to Len(aProAud)

	if allTrim( PlsPtuGet( "NRTROL",aProAud[nX] ) ) == cTranOri
	
		AaDd(aProc,{cValtoChar(PlsPtuGet( "QTDPRO",aProAud[nX] )),;
					Alltrim(PlsPtuGet( "CODPRO",aProAud[nX] )),;
					Alltrim(PlsPtuGet( "DESPRO",aProAud[nX] )),;
					"0",;
					Stod(PlsPtuGet("DATPRO",aProAud[nX])),;
					Alltrim(PlsPtuGet("CODPAD",aProAud[nX])),;
					Alltrim(PlsPtuGet("SEQPTU",aProAud[nX])) })
				
	endIf
next

aDadosOri := PlsGetBSA( cTranOri, PlsIntPad() )

PlsPtuPut("CUNIDOM",PlsPtuGet("CD_UNI_DES",aDadosOri[1] ),aDados)

PlsPtuPut("CD_TRANS","00700",aDados)
PlsPtuPut("TP_CLIENTE","UNIMED",aDados)
PlsPtuPut("CD_UNI_ORI",PlsIntPad(),aDados)
PlsPtuPut("CD_UNI_DES",PlsPtuGet("CD_UNI_DES",aDadosOri[1] ),aDados)
PlsPtuPut("NR_IDENT_E",cTranOri,aDados)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe procedimentos que serao solicitados								   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRet := PLSCRIGEN(aProc,{{STR0083,"@N",30}, {STR0119,"@C",50} , {"DescriГЦo","@C",90 } },"Procedimentos solicitados")//Quantidade ### CСdigo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se tem comunicacao											     |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if aRet[1]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Realiza comunicacao com a outra operadora                       		 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	MsAguarde( {|| aRetOln := PlsPtuOln(aDados,nil,AllTrim(cTranOri)+"."+Subs(PLSINTPAD(),2,3) ,.T.,.F.,nil ) }, STR0220 , STR0125, .F.) //"Aguarde..." //'Comunicando'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se houve retorno 00210/00310 (falha na transacao)       		 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if Len(aRetOln) > 0 .and. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00310"
	
		BCT->(DbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
		if BCT->(DbSeek(xFilial("BCT")+PlsIntPad()+PlsPtuGet("CD_MENS_EX",aRetOln[1])))
			Aviso( STR0120, BCT->(BCT_PROPRI+BCT_CODGLO)+" - "+BCT->BCT_DESCRI,{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
		else
			Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
		endIf
		
		return 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se houve retorno 00210/00310 (falha na transacao)       		 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	elseIf len(aRetOln) > 0 .and. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00309" .and. PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "1"

		cTranDes := allTrim(PlsPtuGet("NR_IDENT_D",aRetOln[1]))
		
		for nI := 1 to len(aProc)
			aadd(aIte,{aProc[nI,2],'2',val(aProc[nI,1]),{},aProc[nI,3],nil,'',aProc[nI,7]})
		next
		
		PLSACOMP(cTranOri,cTranDes,'',aIte,"00700",plsIntPad(),dtos(date()+60),.t.)
		MsgInfo("TransaГЦo "+cTranOri+" atualizada com sucesso.")
	    //Se houve movimentacao, atualiza browse                                  
	    PLS790ATU()
	elseIf len(aRetOln) > 0 .and. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00309" .and. PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "2"
		MsgInfo("Guia Inexistente")
	elseIf len(aRetOln) > 0 .and. PlsPtuGet("CD_TRANS",aRetOln[1]) == "00309" .and. PlsPtuGet("TP_IDENTIF",aRetOln[1]) == "3"
		MsgInfo("SituaГЦo invАlida da autorizaГЦo")
	else
	    PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
	    Aviso( STR0120,__aCdCri065[1]+" - "+PLSBCTDESC(),{ STR0231 }, 2 )	//"Atencao" //"Time out.Operadora fora do Ar." //"Ok"
	EndIf
EndIf

Return
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPL790CRIPTЁ Autor Ё Microsiga	            Ё Data Ё 19.01.15 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Faz a Solicitacao de transacao (00360) do Ptu Online       Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/                          
Function PL790CRIPT()
Local lRet := .T.    

If !Empty(PlsPtuGet( "NRTROL",aProAud[oOcorr:nAt] )) .And. Empty(BCT->BCT_CODED2)
	lRet := .F.  
	MsgInfo("Para atendimento de intercБmbio eletrтnico, И necessАrio selecionar um motivo de crМtica com o CСdigo de Glosa parametrizado conforme manual de intercБmbio.")
EndIf

Return lRet

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPTURemChr Ё Autor Ё PLS TEAM	            Ё Data Ё31/07/2015Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Remove caracter acentuado, CR e LF                         Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/  
Function PTURemChr(cConteudo)

cConteudo := strTran(cConteudo,chr(13)+chr(10),'')    
cConteudo := strTran(cConteudo,chr(13),'') 
cConteudo := strTran(cConteudo,chr(10),'') 
cConteudo := strTran(cConteudo,"Г",'c')  
cConteudo := strTran(cConteudo,"г",'C')    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Caracteres especiais - verificar se e necessario remover                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cConteudo := StrTran(cConteudo,"-"," ")                                       
cConteudo := StrTran(cConteudo,"."," ")
cConteudo := StrTran(cConteudo,"╢"," ") 
cConteudo := StrTran(cConteudo,","," ") 
cConteudo := StrTran(cConteudo,"("," ") 
cConteudo := StrTran(cConteudo,")"," ") 
cConteudo := StrTran(cConteudo,"/"," ") 
cConteudo := StrTran(cConteudo,"\"," ") 
cConteudo := StrTran(cConteudo,":"," ") 
cConteudo := StrTran(cConteudo,"^"," ")
cConteudo := StrTran(cConteudo,"*"," ")
cConteudo := StrTran(cConteudo,"$"," ")
cConteudo := StrTran(cConteudo,"#"," ")
cConteudo := StrTran(cConteudo,"!"," ")
cConteudo := StrTran(cConteudo,"["," ")
cConteudo := StrTran(cConteudo,"]"," ")
cConteudo := StrTran(cConteudo,"?"," ")
cConteudo := StrTran(cConteudo,";"," ")
cConteudo := StrTran(cConteudo,"Г","c")
cConteudo := StrTran(cConteudo,"`"," ")
cConteudo := StrTran(cConteudo,Chr(166)," ")
cConteudo := StrTran(cConteudo,Chr(167)," ")
cConteudo := StrTran(cConteudo,"А","a")
cConteudo := StrTran(cConteudo,"Ц","a")                                     
cConteudo := StrTran(cConteudo,"Ю","a")
cConteudo := StrTran(cConteudo,"Б","a")
cConteudo := StrTran(cConteudo,"И","e")
cConteudo := StrTran(cConteudo,"Х","e")
cConteudo := StrTran(cConteudo,"Й","e")
cConteudo := StrTran(cConteudo,"М","i")
cConteudo := StrTran(cConteudo,"Л","i")
cConteudo := StrTran(cConteudo,"С","o")
cConteudo := StrTran(cConteudo,"Р","o")
cConteudo := StrTran(cConteudo,"У","o")
cConteudo := StrTran(cConteudo,"Т","o")
cConteudo := StrTran(cConteudo,"З","u")
cConteudo := StrTran(cConteudo,"Ы","u")
cConteudo := StrTran(cConteudo,"а","A")
cConteudo := StrTran(cConteudo,"ю","A")
cConteudo := StrTran(cConteudo,"б","A")
cConteudo := StrTran(cConteudo,"ц","A")
cConteudo := StrTran(cConteudo,"и","E")
cConteudo := StrTran(cConteudo,"х","E")
cConteudo := StrTran(cConteudo,"й","E")
cConteudo := StrTran(cConteudo,"м","I")
cConteudo := StrTran(cConteudo,"л","I")
cConteudo := StrTran(cConteudo,"с","O")
cConteudo := StrTran(cConteudo,"р","O")
cConteudo := StrTran(cConteudo,"у","O")
cConteudo := StrTran(cConteudo,"т","O")
cConteudo := StrTran(cConteudo,"з","U")
cConteudo := StrTran(cConteudo,"г","C")
cConteudo := StrTran(cConteudo,"@"," ")
cConteudo := StrTran(cConteudo,"%"," ")
cConteudo := StrTran(cConteudo,"~"," ")
cConteudo := StrTran(cConteudo,"╗"," ")
cConteudo := StrTran(cConteudo,"{"," ")
cConteudo := StrTran(cConteudo,"}"," ")
cConteudo := StrTran(cConteudo,"+"," ")
cConteudo := StrTran(cConteudo,"-"," ")
cConteudo := StrTran(cConteudo,"="," ")
cConteudo := StrTran(cConteudo,"_"," ")
cConteudo := StrTran(cConteudo,"<"," ")
cConteudo := StrTran(cConteudo,">"," ")
cConteudo := StrTran(cConteudo,"&"," ")
cConteudo := StrTran(cConteudo,"|"," ")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Remove acentuacao                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cConteudo := NoAcento(ansiToOem(cConteudo))    

return(cConteudo)   



/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPLSA001BD7Ё Autor Ё Daher		            Ё Data Ё 13.02.03 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Grava os valores do reembolso						      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PlCalcReemb(aAux,cLocalExec,nPercHEsp,aCri,nFator,lAneste,nVlrApr,cMatrUsr,dDatPro,cHorPro,cNomUsr,cMatAnt,cSequen,cCodPad,cCodPro,nQtdPro,cNrNumLib,cConsVl)


LOCAL nAux       := 0
LOCAL nInd       := 0
LOCAL cKeyAux    := ""
LOCAL lRet       := .T.
LOCAL nDesconto  := 0
LOCAL nAcrescimo := 0
LOCAL nQtdCH     := 0

LOCAL nUltimo  := 0
LOCAL nPercen  := 0
LOCAL nVlrPag  := 0  //Valor p/ Pagamento (nVlrMan-nVlrGlo)
LOCAL nVlrCon  := 0  //Valor contratado
LOCAL nVlrMan  := 0  //Valor Base p/ Pagamento
LOCAL nVlrGlo  := 0  //Valor da glosa

LOCAL nTTVlrPag := 0  //Valor p/ Pagamento (nVlrMan-nVlrGlo)
LOCAL nTTVlrCon := 0  //Valor contratado
LOCAL nTTVlrMan := 0  //Valor Base p/ Pagamento
LOCAL nTTVlrGlo := 0  //Valor Base p/ Pagamento
LOCAL nVlrPagPro:= 0
LOCAL nVlrManPro:= 0
LOCAL nVlrGloPro:= 0
LOCAL nVlrBprPro:= 0
LOCAL nVlrPagGui:= 0
LOCAL nVlrManGui:= 0
LOCAL nVlrGloGui:= 0
LOCAL nVlrBprGui:= 0
LOCAL cCodRDA 	:= ""
LOCAL cCodLoc 	:= ""
LOCAL cCodEsp 	:= ""
LOCAL cCdPfPr 	:= ""

LOCAL nVlrTot   := 0
LOCAL lExit		:= .F.
LOCAL cCodUnd
LOCAL nSomaPerc := 0
LOCAL nTotGlo   := 0
LOCAL nTotPag   := 0
LOCAL nTotMan   := 0
LOCAL lPagAlgum := .F.
LOCAL aUnid     := {}
LOCAL cSQL      := ""
LOCAL cTipoCon  := ""
DEFAULT nFator	:= 0
DEFAULT lAneste := .F.
DEFAULT nVlrApr  := 0 //Valor apresentado
DEFAULT cMatrUsr  := ""
DEFAULT dDatPro   := date()
DEFAULT cHorPro   := ""
DEFAULT cNomUsr   := ""
DEFAULT cMatAnt   := ""
DEFAULT cSequen 	:= ""
DEFAULT cCodPad   := ""
DEFAULT cCodPro	:= ""
DEFAULT nQtdPro	:= 0
DEFAULT cNrNumLib := "" //M->B44_NUMLIB



For nInd := 1 To Len(aAux)
    If AllTrim(aAux[nInd,1]) $ AllTrim(PLSCHMP())
       nQtdCH += aAux[nInd,9]
    Endif
Next


// RDS    08/12/2010
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁColeta informacoes para Busca do BD7 de origem, para utilizacao no reembolsoЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If B44->(FieldPos("B44_NUMLIB"))> 0 .And. !Empty(cNrNumLib)

	//Procuro a LiberaГЦo
	cSQL := "SELECT "+RetSQLName("BD7")+".BD7_CODUNM, "
	cSQL += +RetSQLName("BD7")+".BD7_MOTBLO "
	cSQL += "FROM "+RetSQLName("BE2")+", "+RetSQLName("BD7")+" "
	cSQL += "WHERE BE2_FILIAL = '"+xFilial("BE2")+"' AND "
	cSQL += "BE2_OPEMOV = '"+Substr(cNrNumLib,01,4)+"' AND "
	cSQL += "BE2_ANOAUT = '"+Substr(cNrNumLib,05,4)+"' AND "
	cSQL += "BE2_MESAUT = '"+Substr(cNrNumLib,09,2)+"' AND "
	cSQL += "BE2_NUMAUT = '"+Substr(cNrNumLib,11,8)+"' AND "
	cSQL += RetSQLName("BE2")+".D_E_L_E_T_ = ' ' AND "
	cSQL += "BE2_FILIAL = BD7_FILIAL AND "
	cSQL += "BE2_OPEMOV = BD7_CODOPE AND "
	cSQL += "BE2_CODLDP = BD7_CODLDP AND "
	cSQL += "BE2_CODPEG = BD7_CODPEG AND "
	cSQL += "BE2_NUMERO = BD7_NUMERO AND "
	cSQL += "BE2_CODPAD = BD7_CODPAD AND "
	cSQL += "BE2_CODPRO = BD7_CODPRO AND "
	cSQL += "BD7_BLOPAG = '1' AND "
	cSQL += "BD7_MOTBLO = '09F' AND "  // Codigo da Critica da Glosa.
	cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BD7NEG",.F.,.T.)

	Do While BD7NEG->(!Eof())
		If !(BD7NEG->BD7_CODUNM $ cTipoCon)
			cTipoCon += BD7NEG->BD7_CODUNM + ", "
		Endif
		BD7NEG->(DbSkip())
	EndDo
	BD7NEG->(DbCloseArea())
EndIf

For nAux := 1 To Len(aAux)

    //здддддддддддддддддддддддддддддддддддддддддддддддддддд©
 	//ЁVerifca Informacoes para ignorar composicao Reemb   Ё
 	//ЁCaso localize composicao na string, ignora  RDS     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
    If B44->(Fieldpos("B44_NUMLIB")) > 0 .And. !Empty(cNrNumLib) .AND. !Empty(cTipoCon)
        If !(aAux[nAux,1] $ cTipoCon)
            Loop
        EndIf
    EndIf
    For nInd := 1 To Len(aAux[nAux,5])

        cKeyAux := IF(aAux[nAux,1]==GetNewPar("MV_PLSCAUX","AUX"),StrZero(aAux[nAux,5,nInd,3],2),"")
        cCodUnd := aAux[nAux,1]
        	aadd(aUnid,cSequen+cCodUnd+cKeyAux)
        	cCodRDA := B44->B44_CODRDA
        	cCodLoc := subs(B44->B44_LOCATE,1,3)
        	cCodEsp := B44->B44_CODESP
        	cCdPfPr := B44->B44_CDPFRE
           //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Define valores default para os parametros...                        Ё
           //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           If Empty(aAux[nAux,4])

              nVlrPag := aAux[nAux,5,nInd,4]
			  nVlrCon := aAux[nAux,5,nInd,4]
              nVlrGlo := 0
              nVlrMan := aAux[nAux,5,nInd,4]

     		  If nFator > 0
	              If nVlrApr > nVlrCon .And. !lAneste
	                  nVlrPag := nVlrCon * nFator
	              Else
					  nVlrPag := (nVlrApr * nQtdPro) * nFator
	              Endif

	              nVlrMan := nVlrPag
			  EndIf

              //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
              //Ё Verifica se tem percentual de desconto p/ este corpo clinico...     Ё
              //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
              BC1->(DbSetOrder(1))
              IF BC1->(MsSeek(xFilial("BC1")+cCodRDA+cCodLoc+cCodEsp+cCdPfPr)) .And. BC1->BC1_PERDES > 0

				 If BC1->(FieldPos("BC1_DATBLO")) > 0 .And. !Empty(BC1->BC1_DATBLO) .And. BC1->BC1_DATBLO <= dDatPro
	                 Loop
                 Else
	                 nDesconto := BC1->BC1_PERDES
	                 nVlrPag   := round( (nVlrPag * nDesconto) / 100 ,2)
	                 nVlrMan   := nVlrPag
	                 nVlrCon   := nVlrPag
                 EndIf
              Else
                 nDesconto := 0
              Endif
              //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
              //Ё Verifica se tem percentual de acrescimo p/ este corpo clinico...    Ё
              //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
              BC1->(DbSetOrder(1))
              IF BC1->(FieldPos("BC1_PERACR")) > 0 .And. ;
                 BC1->(MsSeek(xFilial("BC1")+cCodRDA+cCodLoc+cCodEsp+cCdPfPr)) .And. BC1->BC1_PERACR > 0
                 nAcrescimo := BC1->BC1_PERACR
                 nVlrPag    := nVlrPag+round(((nVlrPag*nAcrescimo)/100),2)
                 nVlrMan    := nVlrPag
                 nVlrCon    := nVlrPag
              Else
                 nAcrescimo := 0
              Endif
              nVlrTot 	+= nVlrPag
              nTTVlrPag += nVlrPag
              nTTVlrCon += nVlrCon
              nTTVlrMan += nVlrMan
              nTTVlrGlo += nVlrGlo
           Endif
    Next
Next

//Valor Real Contratado
nVlrRCon    := nTTVlrCon
nSomaPerc   := 0

nPercen 	:= round( (nVlrApr / nVlrTot) * 100 ,2)
nSomaPerc 	+= nPercen
lPagAlgum 	:= .T.
nUltimo   	:= 1

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Minha margem de erro eh no maximo 1 porcento, mais que isso eh erro |
//Ё controlado															 |
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nSomaPerc > 99 .and. nSomaPerc < 100
	nSomaperc += (100-nSomaPerc)
Elseif nSomaPerc > 100 .and. nSomaPerc < 101
	nSomaperc -= (nSomaPerc-100)
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata o valor apresentado no subitem...                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nVlrApr > 0
   nVlrApr    := round(nVlrApr * nQtdPro, 2)
   nVlrCon    := nTTVlrCon
   nVlrMan    := nTTVlrMan
   nVlrGlo    := 0
   lExit      := .F.
   lAprMai    := .F.
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se o sistema bloqueou todas as unidades o valor contratado fica 0   Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  nVlrCon == 0 .and. nVlrApr <> 0
   		nVlrMan := nVlrApr
   		nVlrPag := 0
   		nVlrGlo := nVlrApr
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se o valor apresentado ja eh igual ao que estou pagando			   Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   ElseIf nVlrApr == nVlrCon .and. nVlrApr == nVlrPag
          lExit := .T.

   ElseIf nVlrApr < nVlrCon
          If nFator > 0
             nVlrApr := nVlrAPr * nFator
          Endif

          nVlrMan := nVlrApr
          nVlrPag := nVlrApr
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se o valor apresentado for maior q/ o contratado gloso a diferenca..Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   ElseIf (nVlrApr > nVlrCon)
   		If lAneste          
   		  nVlrGlo := 0
          If nFator > 0
             nVlrCon := nVlrCon * nFator
          Endif
          nVlrMan := nVlrApr
          nVlrPag := nVlrApr
   		Else
          nVlrGlo := round(nVlrApr - nVlrCon, 2)
          If nFator > 0
             nVlrCon := nVlrCon * nFator
          Endif
          nVlrMan := nVlrCon
          nVlrPag := nVlrCon
        End
        lAprMai := .T.
   Endif
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Le todos os BD7 de novo atualizando o valor de acordo com o apresen.Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nTotGlo := 0
   nUltimo := 0
   nTotPag := 0
   nTotMan := 0
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
   //Ё Tratamento do valor apresentado
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
   If !lExit
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	   //Ё Considera o valor apresentado como valor para pagamento sem glosa
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
       If nVlrApr > nVlrCon .and. B45->(FieldPos("B45_CONSVL")) > 0 .And. cConsVl == '1'
          If nFator > 0
             nVlrApr := nVlrApr * nFator
          Endif
          nVlrMan := nVlrApr
          nVlrPag := nVlrApr
          nVlrGlo := 0
          lAprMai := .T.
       EndIf
   Endif
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Tratamento de erros de arredondamento							   Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nTotGlo/nVlrGlo <> 1  .and. nTotGlo/nVlrGlo <> 0 .and. nUltimo <> 0
	   	If nTotGlo > nVlrGlo
			nTTVlrGlo		-= (nTotGlo - nVlrGlo)
			nTotGlo		    -= (nTotGlo - nVlrGlo)
	   	Else
			nTTVlrGlo		+= (nVlrGlo - nTotGlo)
			nTotGlo		    += (nVlrGlo - nTotGlo)
	   	Endif
   Elseif nTotGlo == 0 .and. nVlrGlo > 0 .and. nUltimo <> 0 .and. lAprMai
			nTTVlrGlo		+= (nVlrGlo - nTotGlo)
			nTotGlo		    += (nVlrGlo - nTotGlo)
   Endif
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Tratamento de erros de arredondamento											Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nTotPag/nVlrPag <> 1 .and. nTotPag/nVlrPag <> 0 .and. nUltimo <> 0
	   	If nTotPag > nVlrPag
			nTotPag	-= (nTotPag - nVlrPag)
	   	Else
			nTotPag	+= (nVlrPag - nTotPag)
	   	Endif
   Endif
   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Tratamento de erros de arredondamento							   Ё
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nTotMan/nVlrMan <> 1 .and. nTotMan/nVlrMan <> 0 .and. nUltimo <> 0
	   	If nTotMan > nVlrMan
			nTotMan -= (nTotMan - nVlrMan)
	   	Else
			nTotMan += (nVlrMan - nTotMan)
	   	Endif
   Endif

Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para o tratamento do valor da quia e dos procedimentosЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLS001VLRS")
	aRet := Execblock("PLS001VLRS",.F.,.F.,{lRet,{nVlrPagPro,nVlrManPro,nVlrGloPro,nVlrBprPro},{nVlrPagGui,nVlrManGui,nVlrGloGui,nVlrBprGui},cCodPro,cCodPad,cMatrUsr,cCodRDA,cCodEsp,aCri})
    If ValType(aRet[1])="L"
		lRet		:=aRet[1]
	Endif
	//зддддддддддддддддддддд©
	//ЁTotal do procedimentoЁ
	//юддддддддддддддддддддды
	If ValType(aRet[2])="A"
		nVlrPagPro	:=aRet[2,1]
		nVlrManPro	:=aRet[2,2]
		nVlrGloPro	:=aRet[2,3]
		nVlrBprPro  :=aRet[2,4]
	Endif
	//зддддддддддддддддддддд©
	//ЁTotal da Guia		Ё
	//юддддддддддддддддддддды
	If ValType(aRet[3])="A"
		nVlrPagGui	:=aRet[3,1]
		nVlrManGui	:=aRet[3,2]
		nVlrGloGui	:=aRet[3,3]
		nVlrBprGui	:=aRet[3,4]
	Endif

Endif


nVlrPagPro := nVlrPag
nVlrManPro := nVlrMan
nVlrGloPro := nVlrGlo
nVlrBprPro := nVlrPag


Return({lRet,{nVlrPagPro,nVlrManPro,nVlrGloPro,nVlrBprPro,nVlrRCon}})


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPlVerLockЁ Autor Ё TOTVS 		            Ё Data Ё 28.09.16Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Verifica se ja foi gravado o registro  					      Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PlVerLock(aProAtd)    

Local cOpMov       := aProAtd [4][2] 
Local cCodEmp      := aProAtd [5][2] 
Local cMatric      := aProAtd [6][2] 
Local cTipReg      := aProAtd [7][2]
Local cNumAut	     := aProAtd [20][2]
Local cCodPad      := aProAtd [13][2]
Local cCodPro      := aProAtd [14][2]
Local cSequen		   := aProAtd [22][2]
Local cDatPro      := Date()
Local lEncont      := .T.
Local cCodAud      := ""
Local cNomAud      := ""
Local nPos         := 0
Local lInsist      := .F.
Local cAno         := ""
Local cMes         := ""
Default aProAtd    := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifico se e um atendimento de PTU com Insistencia		   Ё     
//Ё (pode haver duas solicitacoes de analise para o mesmo dia) Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPos := aScan(aProAtd,{|x|x[1] == "NRTROL"})
If nPos > 0 .And. !Empty(aProAtd[nPos][2])
	
	nPos := aScan(aProAtd,{|x|x[1] == "ANOAUTINT"})
	IIf(nPos>0,cAno := aProAtd[nPos][2],cAno := "")
	
	nPos := aScan(aProAtd,{|x|x[1] == "MESAUTINT"})
	IIf(nPos>0,cMes := aProAtd[nPos][2],cMes := "")
	
	If !Empty(cMes) .And. !Empty (cAno) .And. !Empty(cNumAut)
		BEA->(DbSetOrder(1))//BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO    
		If BEA->(MsSeek(xFilial("BEA")+PlsIntPad()+cAno+cMes+cNumAut))
			//Verifica internacao
			If BEA->BEA_TIPGUI == "03"
				BE4->(DbSetOrder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
				If BE4->(MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) ))  .And. !Empty(BE4->BE4_MSG04)
					lInsist := .T.
				EndIf
			//Atendimento SADT
			ElseIf !Empty(BEA->BEA_MSG04)
				lInsist := .T.
			EndIf
		EndIf	
	EndIf	
EndIf

If !lInsist .And. BVX->(MsSeek(xFilial("BVX")+cOpMov+cCodEmp+cMatric+cTipReg+cNumAut+cCodPad+cCodPro+DTOS(cDatPro))) 
                  //BVX_FILIAL+BVX_OPEMOV+BVX_CODEMP+BVX_MATRIC+BVX_TIPREG+BVX_NUMAUT+BVX_CODPAD+BVX_CODPRO+DTOS(BVX_DATPAR)                      
	
	While !BVX->(EOF()) .AND. BVX->BVX_SEQUEN == cSequen  .And. cCodAud <> RetCodUsr()
		
		cCodAud:= BVX->BVX_CODAUD
		cNomAud:= BVX->BVX_NOMAUD

		If BVX->BVX_PARECE == "3"
			If MsgYesNo(STR0243 + cCodAud + " - " + cNomAud + STR0244) 
				lEncont := .T.
			Else
				lEncont := .F.
			Endif
		Else
			MsgAlert (STR0243 + cCodAud +" - " + cNomAud + STR0070 + ": " + BVX->BVX_PARECE)
			lEncont := .F.
		EndIf		
		BVX->(DbSkip())
		
	EndDo
			
EndIf

Return lEncont


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁPlVerReg  Ё Autor Ё TOTVS 		        Ё Data Ё 31.03.17 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Verifica se ha registro pendente na BVX antes de comunicar Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PlVerReg(aProReg)    
Local cChkAut      := PlsPtuGet( "CHKAUTINT",aProReg ) 
Local cOpMov       := SubStr((cChkAut),1,4)
Local cAnoAut      := SubStr((cChkAut),5,4) 
Local cMesAut      := SubStr((cChkAut),9,2)
Local cNumAut	   := SubStr((cChkAut),11,8)
Local lTemBvx      := .F.
Local cSQLBVX      := ""     
                                     																						
cSQLBVX   := "SELECT BVX_PARECE FROM " + RetSQLName("BVX") + " WHERE "						 
cSQLBVX   += "BVX_FILIAL = '"+xFilial("BVX")+"' AND "
cSQLBVX   += "BVX_OPEMOV = '"+cOpMov+"' AND "
cSQLBVX   += "BVX_ANOAUT = '"+cAnoAut+"' AND "
cSQLBVX   += "BVX_MESAUT = '"+cMesAut+"' AND "        
cSQLBVX   += "BVX_NUMAUT = '"+cNumAut+"' AND "        
cSQLBVX   += "D_E_L_E_T_ = ''"

cSQLBVX := ChangeQuery(cSQLBVX)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLBVX),"BVXPAR",.F.,.T.)

DbSelectArea("BVXPAR")

If ! BVXPAR->(Eof())
	While ! BVXPAR->(Eof())
	
		If BVXPAR->BVX_PARECE <> '0'
			lTemBvx:= .T.    
			Exit
		EndIf	    
		BVXPAR->(DbSkip())
    Enddo
Endif

BVXPAR->(DbCloseArea())

Return lTemBvx
