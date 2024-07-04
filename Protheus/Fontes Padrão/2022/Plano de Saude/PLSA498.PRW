#INCLUDE "PLSA498.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'MSOBJECT.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
 
#define K_RetFas     6
#define K_RevPag     7
#define K_Analise    7
#define K_RetCob     8
#define K_RetCP      9
#define K_AnaGlo   	 10
#DEFINE K_Estorno  12
#DEFINE K_BCOCON   13
#DEFINE K_Bloqueio 9
#DEFINE K_Desbloq  10
#DEFINE K_Ajuste   10
#DEFINE K_Fase     5
#DEFINE K_RetFas   6
#DEFINE K_Cancel   8

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"

#define RECBRANCO    " "
#define SEMRECURSO   "0"
#define RECPROTOCO   "1"
#define RECANALISE   "2"
#define RECAUTORIZ   "3"
#define RECNEGADO    "4"
#define RECAUTPARC   "5"

STATIC cFiltroBCI	:= ""
STATIC aMatGui		:= ""
STATIC cCodOpe    	:= ""
Static objCENFUNLGP := CENFUNLGP():New()
static cProces499	:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA498
Tela MVC com FWMarkBrowse no cadastro de PEGs.

@author Lucas Nonato
@since  09/08/2019
@version P12
/*/
function PLSA498(cProcesso, cPLSPFilt)
local cFilter		as char
private oMBrwBCI 	as object
private __aRet		:= {}
private cCadastro	:= STR0011 //"Digitacao de Contas Medicas - Selecione o PEG" // USADO EM ALGUM AXCADASTRO
private __nRecBE4	:= 0 //Manter o legado, utilizado para restarar o alias do BE4 após usar o F3 da solicitação de internação.
private aRotina  	:= menuDef(cProcesso) //compatibilidade não remover
default cProcesso	:= ""
default cPLSPFilt 	:= ""
cProces499 := iif( !empty(cProcesso), cProcesso, "" )

setKey(VK_F2 ,{|| cFilter :=  PLS498fil(.t.) })

if isPLSA600()
	oMBrwBCI:= FWMarkBrowse():New()
	oMBrwBCI:SetAlias("BCI")
	oMBrwBCI:SetDescription("Análise de Contas Medicas - Selecione o PEG" )//"Digitacao de Contas Medicas - Selecione o PEG" )
	oMBrwBCI:SetMenuDef("PLSA498")
	oMBrwBCI:AddLegend("BCI_TIPGUI == '01'", "RED",		"GUIA DE CONSULTA" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '02'", "BLUE",	"GUIA DE SP_SADT" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '03'", "YELLOW",	"GUIA DE SOL. INTERNACAO" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '04'", "ORANGE",	"GUIA DE REEMBOLSO" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '05'", "GREEN",	"GUIA DE RESUMO DE INTERNACAO" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '06'", "PINK",	"GUIA DE HONORARIOS" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '09'", "",	"ANEXO OPME" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '10'", "BROWN",	"GUIA DE RECURSO DE GLOSA" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '11'", "GRAY",	"GUIA DE SOL.PRORROGACAO DE INT" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '12'", "BLACK",	"GUIA DE OUTRAS DESPESAS" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '13'", "WHITE",	"GUIA DE ODONTOLOGIA" )
	oMBrwBCI:SetFieldMark( 'BCI_OK' )
	oMBrwBCI:SetAllMark({ ||  allMark() })
	oMBrwBCI:SetFilterDefault(PLS498fil())
	oMBrwBCI:ForceQuitButton()
	oMBrwBCI:Activate()
else
	oMBrwBCI:= FWMBrowse():New()
	oMBrwBCI:SetAlias("BCI")
	oMBrwBCI:SetDescription( STR0011 )//"Digitacao de Contas Medicas - Selecione o PEG" )
	oMBrwBCI:SetMenuDef("PLSA498")
	oMBrwBCI:AddLegend("BCI_TIPGUI == '01'", "RED",		"GUIA DE CONSULTA" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '02'", "BLUE",	"GUIA DE SP_SADT" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '03'", "YELLOW",	"GUIA DE SOL. INTERNACAO" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '04'", "ORANGE",	"GUIA DE REEMBOLSO" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '05'", "GREEN",	"GUIA DE RESUMO DE INTERNACAO" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '06'", "PINK",	"GUIA DE HONORARIOS" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '09'", "",	"ANEXO OPME" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '10'", "BROWN",	"GUIA DE RECURSO DE GLOSA" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '11'", "GRAY",	"GUIA DE SOL.PRORROGACAO DE INT" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '12'", "BLACK",	"GUIA DE OUTRAS DESPESAS" )
	oMBrwBCI:AddLegend("BCI_TIPGUI == '13'", "WHITE",	"GUIA DE ODONTOLOGIA" )
	oMBrwBCI:SetFilterDefault(iif(!empty(cPLSPFilt),cPLSPFilt,PLS498FIL()))
	oMBrwBCI:ForceQuitButton()
	oMBrwBCI:Activate()
endif
cProces499 := ""
return

/*/{Protheus.doc} PLSA498AUX
@description Recebe do mBrowse e chama a funcao correta...
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498AUX(cAlias,nReg,nOpc,cChavGui,lfiltra)
local lRet 		:= .F.
local nRec		:= BCI->(recno())
local cRdmake   := ""
local cAliasBrw := ""
default cChavGui:= ""
default lfiltra := .T.

//Alteração para atender os status da TISS
if BCI->BCI_STTISS < "2"
	BCI->(reclock("BCI",.F.))
		BCI->BCI_STTISS := "2"
	BCI->( MsUnlock() )
endIf

if PLSBCIxBXX()
	return
endIf


//Verifica se e o operador de gerenciamento

if !PLSVEROPE()
	return
endIf

//Posiciona no Tipo de Guia...

if valType(cChavGui) <> 'C'
	cChavGui := ""
endIf

//Posiciona no Tipo de Guia...

BCL->( dbSetOrder(1) ) //BCL_FILIAL + BCL_CODOPE + BCL_TIPGUI
if !BCL->( MsSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI) ) )
	Help("",1,"PLSA498BCL")
	return
endIf

cAliasBrw 	:= BCL->BCL_ALIAS

if existBlock("PLS498LC")
	lRet := execBlock("PLS498LC",.F.,.F., {nReg})
	if ! lRet
		return
	endIf
endIf

if nOpc == K_Visualizar
	nOpc := K_Alterar
endIf

//Tratamento das guias ( PLSA500 )

if BCL->BCL_TIPORD == "1"
	cRdMake   :=  "{ || "+allTrim(BCL->BCL_RDMAKE)+"(cAliasBrw,nReg,nOpc,cChavGui,lfiltra) } "
else
	cRdMake   := "{ || U_"+allTrim(BCL->BCL_RDMAKE)+"(cAliasBrw,nReg,nOpc,cChavGui,lfiltra) } "
endIf

eval(&cRdMake)

dbSelectArea("BCI")
BCI->(dbGoto(nRec))

return

/*/{Protheus.doc} PLSA498PES
@description Pesquisa
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498PES(cAlias,nReg,nOpc,lProcesso)
local nFor		:= 0
local nTipo 	:= 0
local nOrdBCI   := BCI->(indexOrd())
local cTipGui	:= ""
local oDlg		:= nil
local oCombGui  := nil
local oFolder	:= nil
local aAux		:= {}
local cCadastro := "Pesquisar"
local bOK       := {|| nTipo := oFolder:nOption,oDlg:End() }
local bCancel   := {|| oDlg:End() }
local cCodOpe   := PLSINTPAD()
local cCodLDP   := BCI->BCI_CODLDP
local nTamPEG   := tamSX3("BCI_CODPEG")[1]
local nTamRDA   := tamSX3("BCI_CODRDA")[1]
local cPEG      := space( tamSX3("BCI_CODPEG")[1] )
local cCodRDA   := space( tamSX3("BCI_CODRDA")[1] )
local cNomRDA   := space( tamSX3("BAU_NOME")  [1] )
local cNumGuia	:= space( tamSX3("BE4_NUMERO")[1] )
local cNumImp	:= space( tamSX3("BE4_NUMIMP")[1] )
local cNumSen	:= space( tamSX3("BE4_SENHA") [1] )
local cNuSeOp	:= space( tamSX3("BE4_NRAOPE")[1] )
local cNuNuAut	:= space( tamSX3("BEA_ANOAUT")[1]+tamSX3("BEA_MESAUT")[1]+tamSX3("BEA_NUMAUT")[1] )

default lProcesso:= .f.
if cvaltochar(lProcesso) <> ".T."
	lProcesso := .f.
endif
//se nao tem tipo de guia conforme filtro monta do bcl
if empty(aMatGui)

	PLSMCorCM(,aAux,"BCI")

   	aMatGui := {}
   	for nFor := 1 to len(aAux)
   		aadd(aMatGui, allTrim(str(val(aAux[nFor,3]))) + '=' + aAux[nFor,2] )
   	next
   	aAux := {}
   	
endIf

//Define dialogo...

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,008.3 TO 025,060 OF GetWnddefault()
oDlg:lEscClose := .F.
odlg:nwidth    := 603
odlg:ntop      := 155
odlg:nleft     := 100

SIX->(dbSetOrder(1))
if  SIX->(msSeek("BD59")) .And. SIX->(msSeek("BE49")) .And. SIX->(msSeek("BCI7"))

    @ 034,003 FOLDER oFolder SIZE 290,069 OF oDlg PIXEL PROMPTS  STR0012,; //"Numero do PEG <F5>"
                                                                  STR0013,; //"Codigo da Rede de Atendimento <F6>"
                                                                  STR0014,; //"Nome do Prestador <F7>"
                                                                  STR0015,;	 //"Numero da Guia <F8>"
                                                                  STR0016,;	 //"Numero Impresso <F9>"
                                                                  STR0017,;	 //"Senha <F10>"
                                                                  STR0018,; //"Nr Aut Operadora <F11>"
                                                                  STR0019 //"Nr Autor./Liber. <F12>"
	ofolder:nwidth := 580
else
    @ 034,003 FOLDER oFolder SIZE 196,069 OF oDlg PIXEL PROMPTS  STR0012,; //"Numero do PEG <F5>"
                                                                  STR0013,; //"Codigo da Rede de Atendimento <F6>"
                                                                  STR0014 //"Nome do Prestador <F7>"
endIf

//Configura Keys...

setKey(VK_F5 ,{|| oFolder:SetOption(1) })
setKey(VK_F6 ,{|| oFolder:SetOption(2) })
setKey(VK_F7 ,{|| oFolder:SetOption(3) })
setKey(VK_F8 ,{|| oFolder:SetOption(4) })
setKey(VK_F9 ,{|| oFolder:SetOption(5) })
setKey(VK_F10,{|| oFolder:SetOption(6) })
setKey(VK_F11,{|| oFolder:SetOption(7) })
setKey(VK_F12,{|| oFolder:SetOption(8) })

//Fonte

DEFINE FONT oFontAutor NAME "Currie" SIZE 000,-011

//1 - Numero do PEG <F5>

@ 005,005 SAY "Codigo Operadora      :" SIZE 100,010 PIXEL OF oFolder:aDialogs[1] FONT oFontAutor
@ 003,090 MSGET oPes03 VAR cCodOpe PICTURE "@R !.!!!" SIZE 010,010 PIXEL OF oFolder:aDialogs[1] F3 "BA0OPE" hasbutton

@ 020,005 SAY "Codigo local Digitacao:" SIZE 100,010 PIXEL OF oFolder:aDialogs[1] FONT oFontAutor
@ 018,090 MSGET oPes04 VAR cCodLDP PICTURE "@!" SIZE 010,010 PIXEL OF oFolder:aDialogs[1]

@ 035,005 SAY "Numero da PEG         :" SIZE 100,010 PIXEL OF oFolder:aDialogs[1] FONT oFontAutor
@ 032,090 MSGET oPes05 VAR cPEG PICTURE "@!"  SIZE 035,010 PIXEL OF oFolder:aDialogs[1]

//2 - Codigo da Rede de Atendimento <F6>

@ 005,005 SAY "Codigo Operadora      :" SIZE 100,010 PIXEL OF oFolder:aDialogs[2]  FONT oFontAutor
@ 003,090 MSGET oPes06 VAR cCodOpe PICTURE "@R !.!!!" SIZE 010,010 PIXEL OF oFolder:aDialogs[2] F3 "BA0OPE" hasbutton

@ 020,005 SAY "Codigo Rede Atend.    :" SIZE 100,010 PIXEL OF oFolder:aDialogs[2]  FONT oFontAutor
@ 018,090 MSGET oPes07 VAR cCodRDA PICTURE "@!"  SIZE 035,010 PIXEL OF oFolder:aDialogs[2]

//3 - Nome do Prestador <F7>

@ 005,005 SAY "Nome da Rede Atend.   :" SIZE 100,010 PIXEL OF oFolder:aDialogs[3]  FONT oFontAutor
@ 003,090 MSGET oPes08 VAR cNomRDA PICTURE "@!" SIZE 100,010 PIXEL OF oFolder:aDialogs[3]

//4 - Numero da Guia <F8>

@ 005,005 SAY "Tipo de Guia          :" PIXEL OF oFolder:aDialogs[4]  FONT oFontAutor
@ 003,090 MSCOMBOBOX oCombGui VAR cTipGui ITEMS aMatGui SIZE 150,010 PIXEL OF oFolder:aDialogs[4]

@ 020,005 SAY "Codigo local Digitacao:" SIZE 100,010 PIXEL OF oFolder:aDialogs[4] FONT oFontAutor
@ 018,090 MSGET oPes09 VAR cCodLDP PICTURE "@!" SIZE 010,010 PIXEL OF oFolder:aDialogs[4]

@ 035,005 SAY "Numero da Guia        :" SIZE 100,010 PIXEL OF oFolder:aDialogs[4] FONT oFontAutor
@ 032,090 MSGET oPes10 VAR cNumGuia PICTURE "@!"  SIZE 035,010 PIXEL OF oFolder:aDialogs[4]

//5 - Numero Impresso <F9>

@ 005,005 SAY "Numero Impresso:" SIZE 100,010 PIXEL OF oFolder:aDialogs[5] FONT oFontAutor
@ 003,063 MSGET oPes11 VAR cNumImp PICTURE "@!" SIZE 070,010 PIXEL OF oFolder:aDialogs[5]

//6 - Senha <F10>

@ 005,005 SAY "Senha:" SIZE 100,010 PIXEL OF oFolder:aDialogs[6] FONT oFontAutor
@ 003,030 MSGET oPes12 VAR cNumSen PICTURE "@!" SIZE 035,010 PIXEL OF oFolder:aDialogs[6]

//7 - Nr Aut Operadora <F11>

@ 005,005 SAY "Nr Autorizacao Operadora:" SIZE 100,010 PIXEL OF oFolder:aDialogs[7] FONT oFontAutor
@ 003,096 MSGET oPes13 VAR cNuSeOp PICTURE "@!" SIZE 035,010 PIXEL OF oFolder:aDialogs[7]

//8 - Nr Autor./Liber. <F12>

@ 005,005 SAY "Nr Autorizacao/Liberacao:" SIZE 100,010 PIXEL OF oFolder:aDialogs[8] FONT oFontAutor
@ 003,096 MSGET oPes14 VAR cNuNuAut PICTURE "@!" SIZE 100,010 PIXEL OF oFolder:aDialogs[8]

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

//Ativa dialogo...

ACTIVATE MSDIALOG oDlg ON INIT eval( {||enChoiceBar(oDlg,bOK,bCancel,.F.,{}) } ) CENTERED

//Desativa keys...

SET KEY VK_F5  TO
SET KEY VK_F6  TO
SET KEY VK_F7  TO
SET KEY VK_F8  TO
SET KEY VK_F9  TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO

//Opcao selecionada

if nTipo <> 0
	do case
	case nTipo == 1
		PLSA498LOC(cCodOpe,cCodLDP,nTamPEG,cPEG,"1",/*cCodRDA*/,/*cNomRDA*/,/*nTamRDA*/,/*cTipGui*/,/*cNumGuia*/,/*cNumImp*/,/*cNumSen*/,/*cNuSeOp*/,lProcesso)
	case nTipo == 2
		PLSA498LOC(cCodOpe,/*cCodLDP*/,/*nTamPEG*/,/*cPEG*/,"2",cCodRDA,/*cNomRDA*/,nTamRDA,/*cTipGui*/,/*cNumGuia*/,/*cNumImp*/,/*cNumSen*/,/*cNuSeOp*/,lProcesso)
	case nTipo == 3
		PLSA498LOC(/*cCodOpe*/,/*cCodLDP*/,/*nTamPEG*/,/*cPEG*/,"3",/*cCodRDA*/,cNomRDA,/*nTamRDA*/,/*cTipGui*/,/*cNumGuia*/,/*cNumImp*/,/*cNumSen*/,/*cNuSeOp*/,lProcesso)
	case nTipo == 4
		PLSA498LOC(cCodOpe,cCodLDP,/*nTamPEG*/,/*cPEG*/,"4",/*cCodRDA*/,/*cNomRDA*/,/*nTamRDA*/,cTipGui,cNumGuia,/*cNumImp*/,/*cNumSen*/,/*cNuSeOp*/,lProcesso)
	case nTipo == 5
		PLSA498LOC(cCodOpe,cCodLDP,/*nTamPEG*/,/*cPEG*/,"5",/*cCodRDA*/,/*cNomRDA*/,/*nTamRDA*/,/*cTipGui*/,/*cNumGuia*/,cNumImp,/*cNumSen*/,/*cNuSeOp*/,lProcesso)
	case nTipo == 6
		PLSA498LOC(cCodOpe,cCodLDP,/*nTamPEG*/,/*cPEG*/,"6",/*cCodRDA*/,/*cNomRDA*/,/*nTamRDA*/,/*cTipGui*/,/*cNumGuia*/,/*cNumImp*/,cNumSen,/*cNuSeOp*/,lProcesso)
	case nTipo == 7
		PLSA498LOC(cCodOpe,cCodLDP,/*nTamPEG*/,/*cPEG*/,"7",/*cCodRDA*/,/*cNomRDA*/,/*nTamRDA*/,/*cTipGui*/,/*cNumGuia*/,/*cNumImp*/,/*cNumSen*/,cNuSeOp,lProcesso)
	case nTipo == 8
		PLSA498LOC(cCodOpe,cCodLDP,/*nTamPEG*/,/*cPEG*/,"8",/*cCodRDA*/,/*cNomRDA*/,/*nTamRDA*/,/*cTipGui*/,/*cNumGuia*/,/*cNumImp*/,/*cNumSen*/,cNuNuAut,lProcesso)
	endCase
endIf

//Fim da Rotina...

if nTipo == 1 .And. FunName() == "PLSA175"
	BCI->(dbSetOrder(1))
else
	BCI->(dbSetOrder(nOrdBCI))
endIf

return

/*/{Protheus.doc} PLSA498LOC
@description localiza dados
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
static function PLSA498LOC(cCodOpe,cCodLDP,nTamPEG,cPEG,cTipo,cCodRDA,cNomRDA,nTamRDA,cTipGui,cNumGuia,cNumImp,cNumSen,cNuSeOp,lProcesso)
local nIdx		:= 0
local nIdxFixo 	:= 0
local lRet		:= .T.
local cCodPeg	:= ""
local cAlias	:= ""
local cChave	:= ""
local cNumAux	:= ""
local cNumero	:= ""
local cAliasPes	:= ""
local aMostra	:= {}
local aRet		:= {}
Local aAreaBCI := BCI->(GetArea())
Local lfiltra	:= .T.

default cNumGuia	:= ""
default cTipGui		:= ""
default cNumImp		:= ""
default cNumSen		:= ""
default cNuSeOp		:= ""
default lProcesso	:= .f.

//PEG...
if cTipo == "1" .And. !empty(cPEG)
	BCI->(dbSetOrder(1)) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
	lRet := BCI->( msSeek( xFilial("BCI") + cCodOpe + cCodLDP + strZero( val(cPEG),nTamPEG ) ) ) 
	
//Rda

elseIf cTipo == "2" .And. ! empty(cCodRda)
	BCI->(dbSetOrder(5)) //BCI_FILIAL+BCI_OPERDA+BCI_CODRDA+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
	lRet := BCI->(msSeek( xFilial("BCI") + cCodOpe + strZero( val(cCodRDA),nTamRDA ) ) ) 

//Nome Rda

elseIf cTipo == "3" .And. ! empty(cNomRDA)
	BCI->(dbSetOrder(6)) //BCI_FILIAL+BCI_NOMRDA+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
	lRet := BCI->( MsSeek(xFilial("BCI") + allTrim(cNomRDA) ) ) 

//Numero da Guia

elseIf cTipo == "4" .and. !empty(cNumGuia)

	if empty(cTipGui) .Or. empty(cNumGuia) .Or. empty(cCodLDP)
		aviso("Atenção","Necessário preencher todos os parâmetros",{"Ok"},1)
		return(.f.)
	endIf

	cTipGui  := strZero(val(cTipGui),2)
	cNumGuia := strZero(val(cNumGuia),len(cNumGuia))
	
	//Tipo de Guia ...
	
	BCL->(dbSetOrder(1)) //BCL_FILIAL + BCL_CODOPE + BCL_TIPGUI
	BCL->(msSeek(xFilial('BCL') + cCodOpe + cTipGui))

	cAlias := BCL->BCL_ALIAS

	if cAlias <> 'BD5'
		cChave := cCodOpe + cCodLDP + cNumGuia
	else
		cChave := cCodOpe + cCodLDP + cNumGuia + cTipGui
	endIf

	&( cAlias+'->( dbSetOrder(9) )' ) //XXX_FILIAL + XXX_CODOPE + XXX_CODLDP + XXX_NUMERO  + ( XXX_TIPGUI )
	&( cAlias+'->( MsSeek( xFilial("'+cAlias+'")+"'+cChave+'") )' )

	cCodPeg := &( cAlias+'->'+cAlias+'_CODPEG' )

	dbSelectArea("BCI")
	dbSetOrder(7) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_TIPGUI
	lRet := MsSeek( xFilial("BCI")+cCodOpe+cCodLDP+cCodPeg+cTipGui ) 

//Numero do Impresso
elseIf cTipo $ "5,6,7"
	   
	//Pega consulta															
	Do Case
		Case cTipo == "5"
			cCamPes	:= '_NUMIMP'
			cNumAux	:= cNumImp
			nIdx 	:= 6
			lfiltra := .F.
		Case cTipo == "6"
			cCamPes := '_SENHA'
			cNumAux	:= cNumSen
			nIdx	:= 7
			lfiltra := .F.
		Case cTipo == "7"
			cCamPes := '_NRAOPE'
			cNumAux	:= cNuSeOp
			nIdx	:= 8
			lfiltra := .F.
	EndCase
	
	//Msg se em branco
	
	if empty(cNumAux)
		aviso("Atenção","Necessário preencher o parâmetro",{"Ok"},1)
		return(.F.)
	endIf
	
	//Tipo de Guia ...
	
	BCL->(dbSetOrder(1)) //BCL_FILIAL + BCL_CODOPE + BCL_TIPGUI
	if !BCL->(msSeek(xFilial('BCL')+cCodOpe))
		aviso("Atenção",STR0031+cCodOpe,{"Ok"},1)
		return
	endIf
	
	//Procura todos os numeros de impressos iguais								
	
	cAliasPes := ""
	nIdxFixo  := nIdx
	
	while !BCL->(Eof()) .And. BCL->BCL_CODOPE == cCodOpe

		nRecBCL := BCL->( recno() )

		if !(BCL->BCL_ALIAS $ cAliasPes)

			cAlias := allTrim(BCL->BCL_ALIAS)

			if cAlias $ "B4A/B4D"
				BCL->(dbGoto(nRecBCL))
				BCL->(dbSkip())
				loop
			endIf
			
			if cAlias $ "B4Q"
				nIdx := 6
			else
				nIdx := nIdxFixo
			endIf

			cAliasPes += "," + cAlias
			(cAlias)->( dbSetOrder(nIdx) )

			if PlFoundImp(cAlias,cNumAux,nIdx,cTipo)

				while .T.

					aadd( aMostra,{	;
						Posicione("BCL",1,xFilial("BCL") + cCodOpe + (cAlias)->&( cAlias+'_TIPGUI' ),"BCL_DESCRI"),; 	//1
						(cAlias)->&( cAlias+'_OPEUSR + ' + cAlias+'_CODEMP + ' + cAlias+'_MATRIC + ' + cAlias+'_TIPREG' ),; //2
						(cAlias)->&( cAlias+'_MATANT' ),;                                                             	//3
						(cAlias)->&( cAlias+'_NOMUSR' ),;                                                              //4
						(cAlias)->&( cAlias+'_CODRDA' ) + ' - ' + (cAlias)->&( cAlias+'_NOMRDA' ),;                   //5
						(cAlias)->&( cAlias+'_CODOPE' ),;                                                              //6
						(cAlias)->&( cAlias+'_CODLDP' ),;                                                              //7
						(cAlias)->&( cAlias+'_CODPEG' ),;                                                              //8
						(cAlias)->&( cAlias+'_NUMERO' ),;                                                              //9
						(cAlias)->&( cAlias+'_SENHA'  ),;                                                              //10
						(cAlias)->&( cAlias+'_NRAOPE' ),;                                                              //11
						(cAlias)->&( cAlias+'_DTDIGI' ),;                                                              //12
						(cAlias)->&( cAlias+'_DATPRO' ),;                                                              //13
						(cAlias)->&( cAlias+'_TIPGUI' ) } )

					(cAlias)->( DbSkip() )

					if cNumAux <> (cAlias)->&( cAlias+cCamPes )
						Exit
					endIf
				endDo
			endIf
		endIf

		BCL->(dbGoto(nRecBCL))
		BCL->(dbSkip())
	endDo
	
	//Verifica se encontrou mais de um
	
	if len(aMostra) > 0
		if len(aMostra) > 1
			
			//Crigen
			
			aRet := PLSCRIGEN(aMostra,{	;
				{STR0032,"@C",60},; 	   		//1-"Tipo de Guia"
				{STR0033,__cPictUsr,70 },; 		//2-"Matricula"
				{STR0034,"@C",70 },; 			//3-"Matricula Ant."
				{STR0035,"@C",100 },; 	   		//4-"Usuario"
				{"RDA","@C",100 },;            //5-"Rda"
				{STR0036,"@C",40 },; 			//6-"Operadora"
				{STR0037,"@C",40 },; 			//7-"Cd local Dig"
				{STR0038,"@C",40 },; 			//8-"Codigo PEG"
				{STR0039,"@C",40 },; 			//9-"Guia"
				{STR0040,"@C",40 },; 			//10-"Senha"
				{STR0041,"@C",70 },; 			//11-"Nr. Aut. Operadora"
				{STR0042,"@C",50 },; 			//12-"Dt. Digitacao"
				{STR0043,"@C",50 } },STR0044) 	//13-"Dt. Evento"###"Selecione o registro desejado"
			
			//Resultado
			
			if aRet[1]
				cCodLDP := aMostra[aRet[2],7]
				cCodPeg := aMostra[aRet[2],8]
				cTipGui := aMostra[aRet[2],14]
				cNumero := aMostra[aRet[2],9]
			else
				return(aRet[1])
			endIf

		else
			cCodLDP := aMostra[1,7]
			cCodPeg := aMostra[1,8]
			cTipGui := aMostra[1,14]
			cNumero := aMostra[1,9]
		endIf
		
		//Posiciona no registro encontrado
		
		BCI->( dbSetOrder(7) ) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_TIPGUI
		lRet := BCI->( MsSeek( xFilial("BCI") + cCodOpe + cCodLDP + cCodPeg + cTipGui ) ) 
		if lRet
			PLSA498AUX("BCI",BCI->(recno()),K_Alterar, cCodOpe + cCodLDP + cCodPeg + cNumero,lFiltra)
		endIf
	else
		lRet := .F.
	endIf

//Numero da Autorizacao Operadora

elseIf cTipo $ "8"
	BEA->(dbSetOrder(1)) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT
	lRet := BEA->(msSeek( xFilial("BEA")+cCodOpe + allTrim(cNuSeOp) ) )

	if lRet
		cCodLDP := BEA->BEA_CODLDP
		cCodPeg := BEA->BEA_CODPEG
		cTipGui := BEA->BEA_TIPGUI
		cNumero := BEA->BEA_NUMGUI

		BCI->(dbSetOrder(7) ) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_TIPGUI
		If BCI->(msSeek( xFilial("BCI") + cCodOpe + cCodLDP + cCodPeg + cTipGui ) ) 
			PLSA498AUX("BCI",BCI->(recno()),K_Alterar, cCodOpe + cCodLDP + cCodPeg + cNumero )
		else
			lRet := .F.
		EndIf
	endIf
endIf

//processo

if lRet
	if lProcesso
		if !empty(BCI->BCI_PROCES)
			BRI->(dbSetOrder(1)) //BRI_FILIAL + BRI_CODOPE + BRI_CODIGO
			BRI->(msSeek(xFilial("BRI") + BCI->(BCI_CODOPE+BCI_PROCES)))
		else
			aviso("Atenção","PEG encontrado mais não esta vinculado a nenhum PROCESSO",{"Ok"},1)
		endIf
	endIf
else
	BCI->(RestArea(aAreaBCI))
	aviso("Atenção","PEG não encontrado com os parâmetro(s) informado(s)",{"Ok"},1)
endIf

//Fim da Rotina...

return(lRet)

/*/{Protheus.doc} PLS498FIL
Tela de seleção de filtros do proc contas.
@type function
@author PLS TEAM
@since 07/08/2019
@version V12
/*/
function PLS498FIL(lF2)
local oDlg 		:= nil
local oCombFase := nil
local oSay 		:= nil
local nOpca 	:= 0
local nFor 		:= 0
local nColIni 	:= 005
local nLinIni 	:= 010
local cFiltro 	:= ""
local cOpcFase 	:= ""
local xGrvChk	:= ""
local cNameChk	:= ""
local cProtDe 	:= space(8)
local cProtAte 	:= cProtDe
local dDatDe 	:= stod("")
local dDatAte 	:= stod("")
local aCombFase := { "","0=Não Faturada",STR0045,"2=Conferência",STR0046,STR0047 }  //"1=Em digitacao"###"3=Pronto"###"4=Faturada"
local bOK     	:= { || nOpca := 1, iif(valType(oDlg) == 'O',oDlg:End(),) }
local bCancel 	:= { || nOpca := 0, iif(valType(oDlg) == 'O',oDlg:End(),) }
local aCores 	:= {}
local aCdCores 	:= {} 
local aChk 		:= {}
local lAllCheck := .t.
local cTipGui	:= ""
local cPerg 	:= "PLS600"
local aPergAux	:= {}

private cRDADe	:= ""
private cRDAAt	:= ""
private cLocalDe:= ""
private cLocalAt:= ""
private cMesDe	:= ""
private cMesAt	:= ""
private cAnoDe	:= ""
private cAnoAt	:= ""
private _oCheckBox:= nil

default lF2 := .f.

Pergunte(cPerg, .f., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
cRDADe		:= substr(mv_par01 + space(6),1,6)
cRDAAt		:= substr(mv_par02 + space(6),1,6)
cLocalDe 	:= substr(mv_par03 + space(4),1,4)
cLocalAt 	:= substr(mv_par04 + space(4),1,4)
cMesDe		:= substr(mv_par05 + space(2),1,2)
cMesAt		:= substr(mv_par06 + space(2),1,2)
cAnoDe		:= substr(mv_par07 + space(4),1,4)
cAnoAt		:= substr(mv_par08 + space(4),1,4)
cProtDe		:= substr(mv_par09 + space(8),1,8)
cProtAte	:= substr(mv_par10 + space(8),1,8)
cChkGui		:= substr(mv_par11 + space(70),1,70)
cOpcFase	:= substr(mv_par12 + space(1),1,1)
dDatDe		:= stod(substr(mv_par13 + space(8),1,8))
dDatAte		:= stod(substr(mv_par14 + space(8),1,8))

//Define dialogo...
DEFINE MSDIALOG oDlg TITLE "Seleção de Dados" FROM 0015,0015 TO 039, 090 OF GetWnddefault()

//Busca propriedades de guias x cores...
PLSMCorCM(aCores,aCdCores,"BCI")

@ 045, 005  TO 170, 120 PIXEL OF oDlg LABEL 'Tipos de Guia'
@ 045, 123  TO 170, 280 PIXEL OF oDlg LABEL 'Filtros'

oScr := tScrollBox():new(oDlg,051,006,115,113,.t.,.t.,.f.)

for nFor := 1 to len(aCdCores)
	if aCdCores[nFor][3] $ "01,02,03,04,05,06,10,13"
		xGrvChk				:= "lChk" + strZero(nFor,2)
		&xGrvChk			:=	iif(empty(cOpcFase+cLocalAt+cAnoAt+cProtAte+cMesAt),.t.,iif(aCdCores[nFor,3] $ cChkGui, .t., .f.))	
		cNameChk 			:= "oChk" + strZero(nFor,2)
		&cNameChk			:= tCheckBox():create(oScr)
		&cNameChk:cCaption	:= aCdCores[nFor,2]
		&cNameChk:nTop 		:= nLinIni
		&cNameChk:nLeft	 	:= nColIni
		&cNameChk:nWidth 	:= 240
		&cNameChk:nHeight 	:= 009
		&cNameChk:bSetGet 	:= &( "{|u| iif( pCount() == 0, " + xGrvChk + "," + xGrvChk + " := u ) } " )    

		aadd(aChk, &('oChk' + strZero(nFor,2)) )

		nLinIni += 20
	endif
next

nLinIni := 56
@ nLinIni, 156 SAY  STR0049 PIXEL OF oDlg //"Mes de: "
@ nLinIni, 178 MSGET oSay VAR cMesDe SIZE 010,008 PIXEL OF oDlg
@ nLinIni, 211 SAY  STR0050 PIXEL  OF oDlg //"Mes ate: "
@ nLinIni, 234 MSGET oSay VAR cMesAt SIZE 010,008 PIXEL OF oDlg

nLinIni += 16
@ nLinIni, 156 SAY  STR0051 PIXEL OF oDlg //"Ano de: "
@ nLinIni, 178 MSGET oSay VAR cAnoDe SIZE 010,008 PIXEL OF oDlg
@ nLinIni, 211 SAY  STR0052 PIXEL  OF oDlg //"Ano ate: "
@ nLinIni, 234 MSGET oSay VAR cAnoAt SIZE 010,008 PIXEL OF oDlg

nLinIni += 16
@ nLinIni, 156 SAY  STR0053 PIXEL OF oDlg //"RDA de: "
@ nLinIni, 178 MSGET cRDADe F3 "BA0PLS" SIZE 010,008 PIXEL OF oDlg
@ nLinIni, 211 SAY  STR0054 PIXEL  OF oDlg //"RDA ate: "
@ nLinIni, 234 MSGET cRDAAt F3 "BA0PLS" SIZE 010,008 PIXEL OF oDlg

nLinIni += 16
@ nLinIni, 130 SAY  STR0055 PIXEL OF oDlg //"local Digitacao de:"
@ nLinIni, 178 MSGET cLocalDe F3 "B6GPLS" SIZE 010,008 PIXEL OF oDlg
@ nLinIni, 222 SAY  STR0056 PIXEL  OF oDlg //"Ate: "
@ nLinIni, 234 MSGET cLocalAt F3 "B6GPLS" SIZE 010,008 PIXEL OF oDlg

nLinIni += 16
@ nLinIni, 140 SAY  "Protocolo de:" PIXEL OF oDlg
@ nLinIni, 178 MSGET cProtDe F3 "BCI" SIZE 010,008 PIXEL OF oDlg
@ nLinIni, 222 SAY  " Ate:" PIXEL  OF oDlg
@ nLinIni, 234 MSGET cProtAte F3 "BCI" SIZE 010,008 PIXEL OF oDlg

nLinIni += 16
@ nLinIni, 156 SAY  "Data de:" PIXEL OF oDlg
@ nLinIni, 178 MSGET dDatDe SIZE 042,006 PIXEL OF oDlg  
@ nLinIni, 222 SAY  " Ate:" PIXEL  OF oDlg
@ nLinIni, 234 MSGET dDatAte SIZE 042,008 PIXEL OF oDlg

nLinIni += 16
@ nLinIni, 162 SAY  STR0057 PIXEL  OF oDlg //"Fase: "
@ nLinIni, 178 MSCOMBOBOX oCombFase VAR cOpcFase ITEMS aCombFase SIZE 060,008 PIXEL OF oDlg

//Checkbox marca e desmarca todos
_oCheckBox := TCheckBox():New(35,5,"Marca/Desmarca todos",{||lAllCheck},oDlg,100,09,,,,,,,,.T.)
_oCheckBox:bChange := {|| PLSCheckAll(aChk, @lAllCheck, aCdCores)}

//Ativa a dialogo...
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER

//Monta filtro dinamico...
if !empty(cMesDe)
	cMesDe   := strzero(val(cMesDe),2)
endIf

if !empty(cMesAt)
	cMesAt   := strzero(val(cMesAt),2)
endIf

if !empty(cRDADe)
	cRDADe   := strzero(val(cRDADe),6)
endIf

if !empty(cRDAAt)
	cRDAAt   := strzero(val(cRDAAt),6)
endIf

if !empty(cProtDe)
	cProtDe  := strzero(val(cProtDe),8)
endIf

if !empty(cProtAte)
	cProtAte := strzero(val(cProtAte),8)
endIf

//BCI_FILIAL+BCI_CODOPE+BCI_TIPGUI+BCI_MES+BCI_ANO+BCI_CODLDP+BCI_CODPEG+BCI_CODRDA   
cFiltro := "@BCI_FILIAL = '"+xFilial("BCI")+"' "
cFiltro += " AND BCI_CODOPE = '" + PlsIntPad() + "' "

if nOpca == K_OK

	for nFor := 1 to len(aCdCores)
		if aCdCores[nFor][3] $ "01,02,03,04,05,06,10,13"
			xGrvChk := "lChk" + strZero(nFor,2)

			if &xGrvChk
				cTipGui += "'"	 + aCdCores[nFor, 3] + "',"			
			endIf
		endif
	next
	
	cTipGui := left(cTipGui, len(cTipGui) - 1)
	                                                                            	
	if !empty(cMesDe) 
		cFiltro += " AND BCI_MES >= '" + allTrim(cMesDe) + "'		
	endIf

	if !empty(cMesAt)
		cFiltro += " AND BCI_MES <= '" + allTrim(cMesAt) + "'
	endIf
	
	if !empty(cAnoDe)
		cFiltro += " AND BCI_ANO >= '" + allTrim(cAnoDe) + "'		
	endIf

	if !empty(cAnoAt)		
		cFiltro += " AND BCI_ANO <= '" + allTrim(cAnoAt) + "'
	endIf
	
	if !empty(cLocalDe)
		cFiltro += " AND BCI_CODLDP >= '" + allTrim(cLocalDe) + "'		
	endIf

	if !empty(cLocalAt)		
		cFiltro += " AND BCI_CODLDP <= '" + allTrim(cLocalAt) + "'
	endIf

	if !empty(cProtDe)
		cFiltro += " AND BCI_CODPEG >= '" + allTrim(cProtDe) + "'		
	endIf

	if !empty(cProtAte)		
		cFiltro += " AND BCI_CODPEG <= '" + allTrim(cProtAte) + "'
	endIf

	if !empty(cRDADe)
		cFiltro += " AND BCI_CODRDA >= '" + allTrim(cRDADe) + "'
	endIf

	if !empty(cRDAAt)		
		cFiltro += " AND BCI_CODRDA <= '" + allTrim(cRDAAt) + "'
	endIf
	
	if !empty(cOpcFase)
		if cOpcFase == "0"
			cFiltro += " AND BCI_FASE != '4' "
		else
			cFiltro += " AND BCI_FASE = '" + allTrim(cOpcFase) + "'
		endif
	endIf

	if !empty(cTipGui)	
		cFiltro += " AND BCI_TIPGUI IN (" + allTrim(cTipGui) + ")"
	else
		cFiltro += " AND BCI_TIPGUI = '' "
	endif

	if !empty(dDatDe)
		cFiltro += " AND BCI_DTDIGI >= '" + dtos(dDatDe) + "'
	endIf

	if !empty(dDatAte)		
		cFiltro += " AND BCI_DTDIGI <= '" + dtos(dDatAte) + "'
	endIf

	if !empty(cProces499)
		cFiltro += " AND BCI_PROCES = '" + alltrim(cProces499) + "'
	endif

	mv_par01 :=  cRDADe	
	mv_par02 :=  cRDAAt	
	mv_par03 :=  cLocalDe 
	mv_par04 :=  cLocalAt 
	mv_par05 :=  cMesDe	
	mv_par06 :=  cMesAt	
	mv_par07 :=  cAnoDe	
	mv_par08 :=  cAnoAt	
	mv_par09 :=  cProtDe	
	mv_par10 :=  cProtAte
	mv_par11 :=  cTipGui	
	mv_par12 :=  cOpcFase
	mv_par13 :=  dtos(dDatDe)
	mv_par14 :=  dtos(dDatAte)

	//Salva os parâmetros selecionados no Profile do usuário
	__SaveParam(cPerg, aPergAux)
	
endIf

if ExistBlock("PLSFI498")
	cFiltro  := ExecBlock( "PLSFI498",.F.,.F., {cFiltro,cRDADe,cRDAAt,cLocalDe,cLocalAt,cMesDe,cMesAt,cAnoDe,cAnoAt,cTipGui,cOpcFase,dDatDe,dDatAte} )  
endif

if lF2
	oMBrwBCI:SetFilterDefault(cFiltro)
	oMBrwBCI:Refresh()
endif

return( cFiltro )

/*/{Protheus.doc} PLSA498TPG
@description Valida a inclusao do tipo de guia na inclusao da protocolo
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498TPG(cCodOpe,cTipGui)
local lRet 	:= .F.
local aArea	:= getArea()

BCL->( dbSetOrder(1) ) //BCL_FILIAL + BCL_CODOPE + BCL_TIPGUI
lRet := BCL->( MsSeek( xFilial("BCL") + cCodOpe + cTipGui ) )

if ! lRet
	Help("",1,"REGNOIS")
else
	lRet := BCL->BCL_PERINC == "1"

	if ! lRet
		Help("",1,"PLSA500NPI")
	endIf
endIf

restArea(aArea)

//Fim da Rotina...

return(lRet)

/*/{Protheus.doc} PL498DAT
@description alida o preenchimento do campo Data Pagto
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PL498DAT()
local lRet		:= .T.
local aFeriados	:= RetFeriados()
local cAlias    := subStr(ReadVar(),4,3)

//ReadVar

if ReadVar() == "M->"+cAlias+"_DATPAG"
	
	//Verifica se a data de pagemento eh sabado, domingo ou feriado.
	
	if allTrim( Str( Dow( &("M->"+cAlias+"_DATPAG") ) )  ) $ "7/1" .Or. ( aScan( aFeriados , DtoS(&("M->"+cAlias+"_DATPAG")) ) > 0 )
		Aviso('Aviso',"A data de pagamento não pode ser Sabado, Domingo ou Feriado",{"Ok"},2,"")
		lRet:=.F.
	endIf
	
	//Verifica se a data de pagamento eh maior que o mes da competencia.
	
	if &("M->"+cAlias+"_DATPAG") < dDataBase
	    Aviso('Aviso',"A data de pagamento não pode ser  menor que a Data Atual do Sistema",{"Ok"},2,"")
		lRet:=.F.
	endIf
endIf

//Fim da Rotina

return lRet

/*/{Protheus.doc} PLSA498MOV
@description Inclusao de peg/protocolo
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498MOV()

//Inclusao do procotolo

PLSA175MOV("BCI",0,K_Incluir)

//Fim da Rotina...

return


/*/{Protheus.doc} PLSA498VIS
@description Visualizar
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498VIS(cAlias,nReg,nOpc)
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
BCI->(AXVisual(cAlias,nReg,nOpc))
return

/*/{Protheus.doc} PlFoundImp
@description Pesquisa numero do impresso
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PlFoundImp(cAlias,cNumAux,nIdx,cTipo)
local lRet := .F.
local nDif := 0
local nTotZ:= 0
local nTot := 0
local nTam := iif((cAlias)->( fieldPos(cAlias+"_NUMIMP") ) > 0,tamSX3(cAlias+"_NUMIMP")[1],0)

lRet := &( cAlias + '->( MsSeek( xFilial("' + cAlias + '")+"' + cNumAux + '") )' )

if cTipo == '5'

	if ! lRet
		
		cNumAux := allTrim(cNumAux)

		nTotZ := nTam-(len(cNumAux))
		
		while nTot + len(cNumAux) <> SX3->X3_TAMANHO .And. !lRet

			nDif := nTotZ - (nTam-(len(cNumAux)))
		
			lRet := &( cAlias+'->( MsSeek( xFilial("' + cAlias + '")+"' + StrZero(0,nTam-(len(cNumAux) ) ) + cNumAux + Space(nDif) + '") )' )
		
			if lRet == .F.
				Exit
			endIf
			
			nTot++
			nTam--
		endDo
		
	endIf
	
endIf

return lRet

/*/{Protheus.doc} menuDef
@description Utilizacao de menu Funcional 
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
static function menuDef(cProcesso)
local aPtoEnt	:= {}
local oPMile 	:= nil
Local lUnimed := GetNewPar("MV_PLSUNI", "0") == "1"
Local lRegraAtv := GetNewPar("MV_PL7RDA", .F.)
local lHabilitThr := GetNewPar("MV_PLHBMFL",.f.) // ATENÇÃO! Ajuste temporário para retornar a solução que existia na V11 e foi retirada. NÃO remover!
local aRotRev1  := { 		{ STR0007					,'PLSPROCRGR',0,K_RevPag	 	,0,nil},;//"Revalor. Pagto"
							{ STR0008					,'PLSPROCRGR',0,K_RetCob	 	,0,nil},;//"Revalor. Cobr."
							{ STR0009					,'PLSPROCRGR',0,K_RetCP		 	,0,nil}} //"Rev.Cobr./Pagto" 
Private aRotina	:= {}

default cProcesso := ""

if isPLSA600()
	aadd(aRotina,{ "Processar"  			,'PLSA498PRC(.f.)'	,0,K_Alterar    ,0,nil})	
endif
aadd(aRotina,{ STR0001					,'PLSA498PES',0,K_Pesquisar		,0,.f.}) //"Pesquisar"
aadd(aRotina,{ STR0002  				,'PLSA498VIS',0,K_Visualizar	,0,nil}) //"Visualizar"

if !isPLSA600()
	if empty(cProcesso)
		aadd(aRotina,{ "Incluir"			,'PLSA498MOV',0,K_Incluir		,0,nil})
	else
		aadd(aRotina,{ "Vinc / Desv PEG"	,'PLSA499VIN',0,K_Incluir		,0,nil})
	endIf
endIf
aadd(aRotina,{ "Selecionar"				,'PLSA498AUX',0,K_Visualizar	,0,nil}) //"Selecionar"
//aadd(aRotina,{ "Roda Fila"				,'u_PLSSMFila',0,K_Visualizar	,0,nil})
If lUnimed .AND. !lRegraAtv .AND. findfunction("PLSA821")
	aadd(aRotina,{ "Separa Hon. Coop."		,'PLSA821(.T.)',0,K_Visualizar	,0,nil})
endIf

if isPLSA600()
	aadd(aRotina,{ "Revalorar"  		,aRotRev1		,0,0    		,0,nil}) 
else
	aadd(aRotina,{ STR0005  			,'PLSA175FAS',0,K_RetFas    	,0,nil}) //"Mudanca Fase"
	aadd(aRotina,{ STR0006  			,'PLSPROCRGR',0,K_RetFas	 	,0,nil}) //"Retorno Fase"
	aadd(aRotina,{ STR0007				,'PLSPROCRGR',0,K_RevPag	 	,0,nil}) //"Revalor. Pagto"
	aadd(aRotina,{ STR0008				,'PLSPROCRGR',0,K_RetCob	 	,0,nil}) //"Revalor. Cobr."
	aadd(aRotina,{ STR0009				,'PLSPROCRGR',0,K_RetCP		 	,0,nil}) //"Rev.Cobr./Pagto"
endif

aadd(aRotina,{ STR0059					,'PLSA498RPT',0,0			 	,0,nil}) //"Conf. Intern. Pag."
aadd(aRotina,{ "Status do Peg"			,'PLSA498STP',0,0		 		,0,nil})
aadd(aRotina,{ "Gerenciar Peg"			,'PLSA498RES',0,0		 		,0,nil})
aadd(aRotina,{ "Transferência Guia"		,'PLSA498TRA',0,0		 		,0,nil})

if !isPLSA600()
	aadd(aRotina,{ "Imp. Capa PEG"			,'PLSA498IMP',0,0 	 		 	,0,nil})
	aadd(aRotina,{'&Proc. Red. Custo','PLSM250',0,0,0,nil})
	aadd(aRotina,{ "Histórico GIH"			,'PLSGIH(BCI->(BCI_CODOPE+BCI_ANO+BCI_MES+BCI_CODPEG))' , 0 ,	K_Visualizar , 0, nil}) // Historico GIH
endif

aadd(aRotina,{ "Ret./Glos. PEG Integralmente",'PlsGloPeg(.T.)', 0, K_Analise,0,nil }) //Glosa manual
aadd(aRotina,{ "F2-Filtro",'PLS498Fil(.t.)', 0, 4,0,nil })

if !isPLSA600()
	if findFunction("PLSMILE")
		oPMile := PLSMILE():new('PLMOVMI',aRotina)
	endIf
endif
if isPLSA600()
	aadd(aRotina,{ "(re)Processar"  		,'PLSA498PRC(.t.)'		,0,K_Alterar    ,0,nil}) 
endif
if getNewPar("MV_STATISS",.f.)
	aadd(aRotina,{ "Liberar para pagamento", iif(!isPLSA600(), ' MsgRun("Processo em andamento...", "Aguarde",{|| PLRTGUPEG()})',;
		' Processa({|| PLoteLb600()})'), 0 ,K_Visualizar})
endIf

aadd(aRotina,{ "Cancelar PEG",'PLSSTCPG',0,0,0,nil})
aadd(aRotina,{ "Documentos",'plsDocBci',0,0,0,nil})

If lHabilitThr .and. !isPLSA600()
	If PLSMDFGRI(.F.)
		Aadd(aRotina,{ "Mudança Fase (LOTE)" 			,'Processa({||PLSA475FST(.T.,"PLS475    ",.T.,1)},"Processamento De Guias Por Lote","Processando Peg ... ",.T.)', 0 ,	K_Visualizar , 0, Nil})
	Else
		Aadd(aRotina,{ "Mudança Fase (LOTE)" 			,'PLSA475FST(.T.,"PLS475    ",.T.)'                     , 0 ,	K_Visualizar , 0, Nil})
	EndIf
EndIf
if isPLSA600()
	aadd(aRotina,{'Ver quantidade fila'		,'PLSRETGUQT',0,0		 		,0,nil})
endif
if existBlock("PLS498MN")

	aPtoEnt := execBlock("PLS498MN",.F.,.F.)

	if valType(aPtoEnt) <> "A"
		
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SIGAPLS - Retorno do ponto de entrada PLS498MN diferente de array por favor verifique." , 0, 0, {})
		
	else
		if len(aPtoEnt) >= 4
			aadd(aRotina,{aPtoEnt[1],aPtoEnt[2],aPtoEnt[3],aPtoEnt[4],0,nil})
		else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SIGAPLS - Retorno do ponto de entrada PLS498MN invalido." , 0, 0, {})	
		endIf
	endIf
endIf

return(aRotina)


/*/{Protheus.doc} PLSA498RPT
@description Chama o relatório de Conferencia interna de pagamento--
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498RPT()
local aPar := {}

//Verifica se e o operador de gerenciamento
if !PLSVEROPE()
	return
endIf

aadd (aPar,{      	BCI->BCI_CODOPE  ,;   //	Operadora	                   	MV_PAR01
				    BCI->BCI_CODRDA  ,;   //	RDA De?	                   	MV_PAR02
				    BCI->BCI_CODRDA  ,;   //	RDA Até?	                   	MV_PAR03
				    BCI->BCI_ANO     ,;   //	Ano base?                    	MV_PAR04
				    BCI->BCI_MES     ,;   //	Mês Base?	                   	MV_PAR05
				    BCI->BCI_CODPEG  ,;   //	Peg De ?	                   	MV_PAR06
				    BCI->BCI_CODPEG  ,;   //	Peg Até?	                   	MV_PAR07
				    1           ,;   //	Tipo de Relatório? 			 	MV_PAR08 1=Analitico
				    4           ,;   //	Fase?			                	MV_PAR09 4=pronta e faturada
				    1           ,;   //	Imprimir?					      	MV_PAR10 1=Numero Guia
				    3           ,;   //	Imprimir Bloqueada?			  	MV_PAR11 4=Nenhuma
				    ""          ,;   //	Classes RDA?	               	MV_PAR12
				    ""          ,;   //	Numero Lote Pagamento?	      	MV_PAR13
				    1           ,;   //	Imprimir Valor Zero?	       	MV_PAR14 1=Sim
				    1           ,;   //	Listar 1. Resumo ?	          	MV_PAR15 1=Sim
				    1           ,;   //	Listar Títulos?	              MV_PAR16 1=Sim
				    1           ,; 	//	Imprimir Endereço? 		      	MV_PAR17 1=RDA
				    2           ,;   //	Somente Guias Cobradas?	       MV_PAR18 2=Não
				    1           ,;   //	Listar Fornecedor?	          	MV_PAR19 1=Sim
				    ""          ,;   //	local Atendimento De ?	       MV_PAR20
				    "ZZZ"       ,;   //	local Atendimento Ate?	       MV_PAR21
				    StoD(""),; // Data do Procedimento De ?	   			MV_PAR22
				    StoD("20501231"),; // Data do Proc Ate?		 		MV_PAR23
				    ""          ,;   //	Especialidade De?	           	MV_PAR24
				    "ZZZ"       ,;   //	Especialidade Até?	          	MV_PAR25
				    BCI->BCI_CODLDP          ,;   //	local Digitação De?	          	MV_PAR26
				    BCI->BCI_CODLDP      ,;   //	local Digitação Ate?	       	MV_PAR27
				    ""          ,;   //	Empresa De?	                 	MV_PAR28
				    "ZZZZ"      ,;   //	Empresa Até?	               	MV_PAR29
				    ""          ,;   //	Contrato De?	               	MV_PAR30
				    "ZZZZZZZZZZZZ",; //	Contrato Ate?	               	MV_PAR31
				    ""          ,;   //	Subcontrato De?	              MV_PAR32
				    "ZZZZZZZZZ" ,;   //	Subcontrato Ate?	           	MV_PAR33
				    ""          ,;   //	Plano De?	                   	MV_PAR34
				    "ZZZZ"      ,;   //	Plano Até?	                   	MV_PAR35
				    ""          ,;   //	Procedimento De?	           	MV_PAR36
				    "ZZZZZZZZ"  ,;   //	Procedimento Até?	           	MV_PAR37
				    1           ,;   //	Imp. Matricula? 				   	MV_PAR38 1=Utilizada
				    2           ,;   //	Imprimir Loc Requisição?	   		MV_PAR39 2=Não
				    1           ,;   //	Imprimir Co-Participação?	   	MV_PAR40 1=Sim
				    ""          ,;   //	Numero da Guia De?	          	MV_PAR41
				    "ZZZZZZZZ"  ,;   //	Numero de Guia Até? 	          	MV_PAR42
				    StoD(""),; // Data Digitação De ?	          			MV_PAR43
				    StoD("20501231"),; // Data Digitação Até?	   			MV_PAR44
				    "",;                                                             //45 NFSS
				    "",;                                                             //46 NFSS
				    1           ,;   //	Glosa Junto do Proc 			   	MV_PAR47 1=Sim
		})

if existBlock('PLSA49R')
	aPar := execBlock('PLSA49R',.F.,.F.,{aPar})
endIf

PLSR673(aPar)

return

/*/{Protheus.doc} PLSA498STP
@description Muda status do peg conforme status das guias
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498STP()

//Verifica se e o operador de gerenciamento
if !PLSVEROPE()
	return
endIf

//atualiza status peg
PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()),.t.,.t.)

//Alerta
msgAlert("Status atualizado!")

return

/*/{Protheus.doc} PLSA498RES
@description gerenciamento do peg	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498RES()
local cCodOpe := PLSRtCdUsr()

//se sou administrador e ja tem operador gerenciando
if ! empty(BCI->BCI_OPERES) .and. FWIsAdmin()
	if msgYesNo("PEG sendo gerenciado pelo operador [" + allTrim(usrRetName(BCI->BCI_OPERES)) + "], confirma a liberação?")		
		BCI->(reclock("BCI",.F.))
			BCI->BCI_OPERES	:= ""
		BCI->(msUnlock())		
	endIf

//e o mesmo operador que esta gerenciando
elseIf BCI->BCI_OPERES == cCodOpe
	if msgYesNo("Confirma a liberação do PEG numero [" + BCI->BCI_CODPEG + "]")		
		BCI->(reclock("BCI",.F.))
			BCI->BCI_OPERES	:= ""
		BCI->(msUnlock())		
	endIf

//vai pegar para gerenciamento
elseIf empty(BCI->BCI_OPERES)
	if msgYesNo("Confirma o gerenciamento do PEG numero [" + BCI->BCI_CODPEG + "]")		
		BCI->(reclock("BCI",.F.))
			BCI->BCI_OPERES	:= cCodOpe
		BCI->(msUnlock())		
	endIf
//nao e o operador do peg
else
	aviso("Atenção","Outro operador esta fazendo o gerenciamento do PEG [" + BCI->BCI_CODPEG + "]",{"Ok"},1)
endIf

return(nil)

/*/{Protheus.doc} PLSVEROPE
@description Verifica se o operador e o que esta gerenciando	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSVEROPE(lPeg, lHelp)
local cCodOpe 	:= PLSRtCdUsr()
local lRet		:= .t.
default lPeg	:= .t.
default lHelp	:= .t.

//verificar se e administrador do sistema
if lPeg		
	//se sou administrador e ja tem operador gerenciando
	if ! FWIsAdmin()
		
		if !empty(BCI->BCI_OPERES) .and. BCI->BCI_OPERES <> cCodOpe
			lRet := .f.
			if lHelp
				aviso("Atenção","PEG ["+BCI->BCI_CODPEG+"] sendo gerenciado pelo operador ["+allTrim(usrRetName(BCI->BCI_OPERES))+"]",{"Ok"},1)
			endif
		endIf
		
	endIf	
else	
	//se sou administrador e ja tem operador gerenciando
	if ! FWIsAdmin()
		if !empty(BRI->BRI_OPERES) .and. BRI->BRI_OPERES <> cCodOpe
			lRet := .f.
			if lHelp
				aviso("Atenção","PROCESSO ["+BRI->BRI_CODIGO+"] sendo gerenciado pelo operador ["+allTrim(usrRetName(BRI->BRI_OPERES))+"]",{"Ok"},1)
			endif
		endIf		
	endIf	
endIf

return(lRet)

/*/{Protheus.doc} PLSA498TRA
@description Transferencia de guia entre PEGs	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498TRA()

local aArea 	:= getArea()
local nI		:= 0
local nQtLin 	:= 0
local nQtdF		:= 0
local bCol		:= ""
local cPegDes	:= space(16)
local cTexTit	:= "Selecione a(s) guias(s) a serem transferidas"
local cTexChk	:= "Marca e Desmarca todos"
local lOk		:= .f.
local lCheck	:= .f.
local lMostra	:= .t.
local lChkQt	:= .f.
local bOK       := {|| lOk := PLSVLDOK(cPegDes,aMatLin),iif(lOk,oDlg:End(),nil) }
local bCancel   := {|| lOk := .f.,oDlg:End() }
local bBotao02  := {|| pFilTrGu(_cChkOri,@aMatLin,oObjGrid,.T.,.T.) }
local bBotao03	:= {|| PLSATRPES(aMatLin,oObjGrid) }
local oDlg		:= nil
local oObjGrid	:= nil
local oCheck	:= nil
local aMatLin	:= {}
local aMatCol	:= {}
local aButtons	:= {}
local aCampos	:= {}

private _cFilTra:= BCI->(BCI_CODRDA+BCI_TIPGUI+BCI_TIPSER) 
private _cChkOri:= BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)

//Verifica se e o operador de gerenciamento
if ! PLSVEROPE()
	return
endIf

//verifica se as guias do peg podem ser transferidas

if ! empty(BCI->BCI_ARQUIV)
	aviso("Atenção","Impossível mover as guias de um protocolo originado da importação XML!",{"Ok"},1)
	return
endIf

pFilTrGu(_cChkOri,@aMatLin,nil,.f.)

//verifica se tem alguma guia no peg

if len(aMatLin) == 0
	aviso("Atenção","Protocolo sem guia(s) a ser(em) transferida(s)!",{"Ok"},1)
	return
endIf

//Colunas do browse
oSize := FwDefSize():New()
oSize:AddObject( "TRAGUI" 	,  100, 100, .T., .T. ) // Totalmente dimensionave
oSize:lProp 	:= .T. // Proporcional
oSize:Process() 	   // Dispara os calculos


aadd( aMatCol,{"Situacao"			,'@!',040} )
aadd( aMatCol,{"Fase"				,'@!',040} )
aadd( aMatCol,{"Data"				,'@!',050} )
aadd( aMatCol,{"Guia"				,'@!',050} )
aadd( aMatCol,{"Liberação Origem"	,'@!',070} )
aadd( aMatCol,{"Matricula"			,'@!',070} )
aadd( aMatCol,{"Nome Beneficiario"	,'@!',200} )
aadd( aMatCol,{"Valor"				,'@!',200} )

//Inicia controle a ultima posicao sempre deve ser um valor logico		 

nQtLin := len(aMatLin[1])
aeval( aMatLin,{|x| iif( x[nQtLin],nQtdF++,0 ) } )

aadd(aButtons,{"FILTRAR",bBotao02,'Filtrar <F5>','Filtrar <F5>'})
setKey(VK_F5,bBotao02)

aadd(aButtons,{"PESQUISAR",bBotao03,'Pesquisar <F6>','Pesquisar <F6>'})
setKey(VK_F6,bBotao03)


//Definicao de tela
DEFINE MSDIALOG oDlg TITLE cTexTit FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] of oMainWnd PIXEL

 	nLinIni := oSize:GetDimension("TRAGUI","LININI")
 	nColIni := oSize:GetDimension("TRAGUI","COLINI")
	
	//Marca/Desmarca
	
	@ nLinIni+06,nColIni checkbox oCheck var lCheck PROMPT cTexChk of oDlg size 100,8
	oCheck:bChange := {|| msAguarde( {|| PLSMD(aMatLin,lCheck) ,oObjGrid:Refresh() } ) }
	
	//peg de origem
	
	cPedOri := BCI->(BCI_CODOPE+"-"+BCI_CODLDP+"-"+BCI_CODPEG)
   	@ nLinIni+06,nColIni+82 say oSay prompt "Origem: " + cPedOri size 180,010 of oDlg pixel
	
	//peg de destino
	
   	@ nLinIni+06,nColIni+205 say oSay prompt "Destino: " size 080,010 of oDlg pixel
   	@ nLinIni+03,nColIni+239 msGet cPegDes picture "@!" valid PLVLDPEG(cPegDes) size 090,010 f3 "BCWPLS" 	of oDlg pixel
	
	//Tabelas
	
	oObjGrid := tcBrowse():New( oSize:GetDimension("TRAGUI","LININI")+15,;
							    oSize:GetDimension("TRAGUI","COLINI"),;
							    oSize:GetDimension("TRAGUI","XSIZE"),;
							    oSize:GetDimension("TRAGUI","YSIZE");
							    ,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)

	oObjGrid:lHScroll := .F.
	oObjGrid:lVScroll := .T.

	oObjGrid:AddColumn(TcColumn():New(" ",iif(lMostra,{|| LoadBitmap( GetResources(), iif(aMatLin[oObjGrid:nAt,nQtLin],"LBOK","LBNO") ) },{||}),"@c",nil,nil,nil,010,.T.,.T.,nil,nil,nil,.T.,nil))

	for nI:=1 to len(aMatCol)
		bCol :=  "{|| oObjGrid:AddColumn(TcColumn():New(aMatCol["+allTrim(Str(nI))+",1],{||OemToAnsi( aMatLin[oObjGrid:nAt,"+allTrim(Str(nI))+"] )},+aMatCol["+allTrim(Str(nI))+",2],nil,nil,nil,aMatCol["+allTrim(Str(nI))+",3],.F.,.F.,nil,nil,nil,.F.,nil) ) }"
		eval( &bCol )
	next

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if  objCENFUNLGP:isLGPDAt()
			aCampos := {.F.,;
						"BD5_SITUAC",;
                        cAliLGPD +"FASE",;
                        cAliLGPD +"DATPRO",;
                        cAliLGPD +"NUMERO",;
                        IIf(cAliLGPD == "BD5_",cAliLGPD +"NRLBOR","BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT"),;
                        cAliLGPD +"OPEUSR+"+cAliLGPD+"CODEMP+"+cAliLGPD+"MATRIC+"+cAliLGPD+"TIPREG+"+cAliLGPD+"DIGITO",;
                        cAliLGPD +"NOMUSR",;
                        cAliLGPD +"VLRPAG"}
                        

		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oObjGrid:aObfuscatedCols := aBls//{.T., .T., .T., .T., .T., .T., .F., .T.}
		objCENFUNLGP:useLogUser()
	endif

	oObjGrid:SetArray(aMatLin)
	oObjGrid:GoTop()
	oObjGrid:Refresh()

	oObjGrid:bLDblClick := {|| aMatLin[oObjGrid:nAt,nQtLin] := iif( aMatLin[oObjGrid:nAt,nQtLin] ,eval( {|| nQtdF--,.F. } ), iif( lChkQt .And. nQtdF==(len(aMatLin)-1) ,.F., eval( {|| nQtdF++,.T. } )) ) }


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)
SET KEY VK_F5  TO
SET KEY VK_F6  TO

//Fim da Rotina...

restArea(aArea)
return(nil)

/*/{Protheus.doc} PLSTRAGUI
@description Transferencia de guia entre PEGs	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSTRAGUI(cChaveOri,cChaveDes,aMatLin)
local nI		:= 0
local nTam		:= 0
local nQtdGuiT	:= 0
local cOpeOri	:= ""
local cLdpOri	:= ""
local cPegOri	:= ""
local cOpeDes	:= ""
local cLdpDes	:= ""
local cPegDes	:= ""
local cGuiOri	:= ""

//operadora Origem
nTam 		:= tamSX3("BCI_CODOPE")[1]
cOpeOri		:= left(cChaveOri,nTam)
cChaveOri 	:= subStr(cChaveOri,nTam+1,len(cChaveOri))

//local de origem
nTam 		:= tamSX3("BCI_CODLDP")[1]
cLdpOri		:= left(cChaveOri,nTam)
cChaveOri 	:= subStr(cChaveOri,nTam+1,len(cChaveOri))

//peg origem
nTam 		:= tamSX3("BCI_CODPEG")[1]
cPegOri		:= left(cChaveOri,nTam)

//operadora Destino
nTam 		:= tamSX3("BCI_CODOPE")[1]
cOpeDes		:= left(cChaveDes,nTam)
cChaveDes 	:= subStr(cChaveDes,nTam+1,len(cChaveDes))

//local Destino
nTam 		:= tamSX3("BCI_CODLDP")[1]
cLdpDes		:= left(cChaveDes,nTam)
cChaveDes 	:= subStr(cChaveDes,nTam+1,len(cChaveDes))

//local Destino
nTam 		:= tamSX3("BCI_CODPEG")[1]
cPegDes		:= left(cChaveDes,nTam)

procRegua(len(aMatLin))

nRecBCI := BCI->(recno())
nOrdBCI := BCI->(indexOrd())

BCI->(dbSetOrder(1))
if BCI->(MsSeek(xFilial('BCI')+cOpeDes+cLdpDes+cPegDes))
	
	if BCI->BCI_TIPGUI $ "03,05"
		cAliCab := "BE4"
	else
		cAliCab := "BD5"
	endIf
	
endIf

BCI->(dbSetOrder(nOrdBCI))
BCI->(dbGoto(nRecBCI))

//somente guias selecionadas
for nI := 1 to len(aMatLin)
	
	// somente a selecionada
	if aMatLin[nI,len(aMatLin[nI])]

		nQtdGuiT++
		cGuiOri := aMatLin[nI,4]
		incProc("Transferindo guia ["+cGuiOri+"]")

		// retira a guia do peg origem e colocar no destino (guia a guia)
		PLSATUPEG(cOpeOri,cLdpOri,cPegOri,cGuiOri,cOpeDes,cLdpDes,cPegDes,cAliCab)
		
	endIf
	
next

//atualiza quantidade de evento,valor apr e guias do peg
PLSATUPP(,,nQtdGuiT,.t.,cOpeDes,cLdpDes,cPegDes,(cOpeOri+cLdpOri+cPegOri))

msgAlert("Transferência concluída com sucesso")

return(nil)

/*/{Protheus.doc} PLSVLDOK
@description valida bok	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
static function PLSVLDOK(cPegDes,aMatLin)
local lRet 	:= .t.

//verifica se peg destino foi informado
if empty(cPegDes)
	aviso("Atenção","Necessário informar o protocolo de destino!",{"Ok"},1)
	lRet := .f.
endIf

//Verifica se alguma guia foi selecionada
if lRet
	if aScan(aMatLin,{|x| x[len(aMatLin[1])] == .t.}) == 0
		aviso("Atenção","Nenhuma guia selecionada!",{"Ok"},1)
		lRet := .f.
	endIf
endIf

//processa
if lRet
	if msgYesNo('Deseja mesmo transferir a(s) guia(s) do Protocolo ['+_cChkOri+'] para o Protocolo ['+cPegDes+'] ?')
		processa( {|| PLSTRAGUI(_cChkOri,cPegDes,aMatLin) }, "Transferencia", "Transferindo guias...", .T.)
	endIf
endIf

//Fim da Rotina...

return(lRet)

/*/{Protheus.doc} PLSA498IMP
@description Imprimi capa do PEG
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSA498IMP()

if msgYesNo("Confirma a impressão da capa de lote numero [ "+BCI->BCI_CODPEG+" ]")
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
	processa({|| PLSRCPRT(BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)) }, "Impressão", "Imprimindo capa de lote...", .t.)
endIf

//Fim da Rotina...

return(nil)

/*/{Protheus.doc} P498VRda
@description Imprimi capa do PEG		
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function P498VRda()
return Vazio() .or. PlsZero() .and. ExistCpo("BAU",M->BCI_CODRDA,1) .and. PLSVLDRDG(M->BCI_CODRDA)

/*/{Protheus.doc} PLS498prt
@description Validacao de campos autorizacao			
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLS498prt()
local cRet := "@#.T."
local cLocaL4 	:= PLSRETLDP(4) // 4=Digitação Offline 
local cLocal9 	:= PLSRETLDP(9) // 9=local Generico

if Type('_cChkOri') <> 'U'
	cRet := "@#BCI_FILIAL == '"+xFilial("BCI")+"' .AND. BCI_CODOPE == '"+PlsIntPad()+"' .AND. "
	cRet += "  BCI_TIPGUI == '"+subStr(_cFilTra,7,2)+"' .AND. "
	cRet += "  BCI_CODRDA == '"+subStr(_cFilTra,1,6)+"' .AND. "
	cRet += "  BCI_ARQUIV == '"+space(tamSX3("BCI_ARQUIV")[1])+"' .AND. "
	cRet += "  BCI_CODPEG <> '"+subStr(_cChkOri,9,17)+"' .AND. "
	cRet += "  BCI_FASE <> '4' .AND. "
	cRet += "  BCI_CODLDP <> '"+cLocaL4+"' .AND. BCI_CODLDP <> '"+cLocal9+"' "
else
	if !empty(cLocalAt)
		cRet := "@#BCI_FILIAL == '"+xFilial("BCI")+"' .AND. BCI_CODOPE == '"+PlsIntPad()+"' .AND. BCI_CODLDP >= '"+cLocalDe+"' .AND. BCI_CODLDP <= '"+cLocalAt+"' "

		if !empty(cRDAAt)
			cRet += " .AND. BCI_CODRDA >= '"+cRDADe+"' .AND. BCI_CODRDA <= '"+cRDAAt+"' "
		endIf

		if !empty(cAnoAt)
			cRet += " .AND. BCI_ANO >= '"+cAnoDe+"' .AND. BCI_ANO <= '"+cAnoAt+"' "
		endIf

		if !empty(cMesAt)
			cRet += " .AND. BCI_MES >= '"+cMesDe+"' .AND. BCI_MES <= '"+cMesAt+"' "
		endIf

	elseIf  !empty(cRDAAt)
		cRet := "@#BCI_FILIAL == '"+xFilial("BCI")+"' .AND. BCI_OPERDA == '"+PlsIntPad()+"' .AND. BCI_CODRDA >= '"+cRDADe+"' .AND. BCI_CODRDA <= '"+cRDAAt+"' "

		if !empty(cAnoAt)
			cRet += " .AND. BCI_ANO >= '"+cAnoDe+"' .AND. BCI_ANO <= '"+cAnoAt+"' "
		endIf

		if !empty(cMesAt)
			cRet += " .AND. BCI_MES >= '"+cMesDe+"' .AND. BCI_MES <= '"+cMesAt+"' "
		endIf

	elseIf !empty(cAnoAt)
		cRet := "@#BCI_FILIAL == '"+xFilial("BCI")+"' .AND. BCI_CODOPE == '"+PlsIntPad()+"' .AND. BCI_ANO >= '"+cAnoDe+"' .AND. BCI_ANO <= '"+cAnoAt+"' "

		if !empty(cMesAt)
			cRet += " .AND. BCI_MES >= '"+cMesDe+"' .AND. BCI_MES <= '"+cMesAt+"' "
		endIf

	endIf
endIf
cRet += " @#"

return cRet


/*/{Protheus.doc} PLS498fit
@description Validacao de campos autorizacao			
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLS498fit()
local cRet := "@#.T."
local cMatric := ''

if Type('M->BD5_USUARI') <> 'U' .and. ! empty(M->BD5_USUARI)
	cMatric := M->BD5_USUARI
	cRet 	:= "@#BE4_FILIAL == '"+xFilial("BE4")+"' .AND. BE4_CODOPE ==  '"+subStr(cMatric,1,4)+"' .AND. BE4_CODEMP == '"+subStr(cMatric,5,4)+"' .AND. BE4_MATRIC == '"+subStr(cMatric,9,6)+"' .AND. BE4_TIPREG == '"+subStr(cMatric,15,2)+"' .AND. BE4_TIPGUI == '03'"
endIf

if Type('M->BE4_USUARI') <> 'U' .and. ! empty(M->BE4_USUARI)
	cMatric := M->BE4_USUARI
	cRet 	:= "@#BE4_FILIAL == '"+xFilial("BE4")+"' .AND. BE4_CODOPE ==  '"+subStr(cMatric,1,4)+"' .AND. BE4_CODEMP == '"+subStr(cMatric,5,4)+"' .AND. BE4_MATRIC == '"+subStr(cMatric,9,6)+"' .AND. BE4_TIPREG == '"+subStr(cMatric,15,2)+"' .AND. BE4_TIPGUI == '03'"
endIf

if Type('M->BE4_GUIINT') <> 'U' .and. ! empty(M->BE4_USUARI)
	cMatric := M->BE4_USUARI 
	cRet 	:= "@#BE4_FILIAL == '"+xFilial("BE4")+"' .AND. BE4_CODOPE ==  '"+subStr(cMatric,1,4)+"' .AND. BE4_CODEMP == '"+subStr(cMatric,5,4)+"' .AND. BE4_MATRIC == '"+subStr(cMatric,9,6)+"' .AND. BE4_TIPREG == '"+subStr(cMatric,15,2)+"' .AND. BE4_TIPGUI == '03'"
endIf

cRet += " .AND. BE4_SITUAC == '1' "

if Type('M->BE4_GUIINT') <> 'U' .and. empty(M->BE4_USUARI)
	cRet := "@# .F. == .T. " //Por mais incrível que pareça, se deixar só .F. dá error.log...
endIf

cRet += " @#"

return cRet

/*/{Protheus.doc} PlReAl498
@description Função para validações para data de procedimento (BD6_DATPRO)
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PlReAl498()
local lRet		:= .T.
local cCodRda	:= ""
local lTypeBD5 	:= Type("M->BD5_DATPRO") <> 'U'
local lTypeBE4 	:= Type("M->BE4_DATPRO") <> 'U'
local dEvento  	:= stod("")

//Buscando a informação código RDA e Data do Evento/Internação
if lTypeBD5
	cCodRda := M->BD5_CODRDA
	dEvento := M->BD5_DATPRO
elseif lTypeBE4
	cCodRda := M->BE4_CODRDA
	dEvento := M->BE4_DATPRO
endIf

//Verifica se a data do procedimento ocorre depois da data de atendimento
if (lTypeBE4 .or. lTypeBD5) .and. !empty(M->BD6_DATPRO) .and. M->BD6_DATPRO < dEvento
	lRet := .F.
	msgInfo(STR0069)//"Não é possível infomar uma data de procedimento inferior a data de atendimento."
endif

//Verifica se a data do procedimento é inferior a data atual
IF !empty(M->BD6_DATPRO) .AND. lRet
	If lTypeBE4 .or. lTypeBD5
		lRet := M->BD6_DATPRO <= Date()
	endIf
	If !lRet
		msgInfo("Não é possível infomar uma data de procedimento posterior à Data atual.")
	endIf
endIf

//Verifica se a data do procedimento é inferior a data de reconhecimento da BCI - .
if lRet .and. M->BD6_DATPRO > BCI->BCI_DATREC
	lRet := .F.
	msgInfo("Não é possível infomar uma data de procedimento superior a data de Recebimento (" + dtoc(BCI->BCI_DATREC) + ")")
endif

if lRet .And. !empty(M->BD6_CODPRO)
	lRet := PlMonQtPer(M->BD6_SEQUEN,M->BD6_CODPAD,M->BD6_CODPRO,M->BD6_QTDPRO,.t.,nil,M->BD6_DATPRO,.t.) .AND. PLSVLDRDG(cCodRda)
endIf

return lRet

/*/{Protheus.doc} PLS498vls
@description Validacao de campos autorizacao			
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLS498vls(cConteudo)
local cCampo 	  := ReadVar()
local lFound 	  := .F.
local nForCpo 	  := 1
local cAlias  	  := subStr(cCampo,4,3)
local cCampoNG	  := ''
local lRet   	  := .T.
local nRecBE4 	  := 0
local nResBE4 	  := iif(__nRecBE4 <> 0,__nRecBE4,BE4->(recno()))
local nIndBE4 	  := BE4->(indexOrd())
local cRdaSol     := ''

cCampoNG += cCampo+","+cAlias+"_ANOPAG,"+cAlias+"_MESPAG,"+cAlias+"_USUARI,"+cAlias+"_RDAEDI,"+cAlias+"_DTPAGT,"+cAlias+"_DTANAL,"
cCampoNG += cAlias+"_OPELOT,"+cAlias+"_NUMLOT,"+cAlias+"_VLRPAG,"+cAlias+"_VLRMAN,"+cAlias+"_VLRGLO,"+cAlias+"_VLRPF,"+cAlias+"_VLRBPR,"
cCampoNG += cAlias+"_FASE,"+cAlias+"_NUMINT,"+cAlias+"_BLOPAG,"+cAlias+"_ANOINT,"+cAlias+"_MESINT"

//se for um honorario individual que esta sendo digitado o sistema nao gatilha o campo CODRDA e aqueles relacionados a ele
//pois sempre o honorario eh pago para uma RDA diferente da RDA da guia principal
//Estendendo o tratamento para a guia SADT
if BCI->BCI_TIPGUI $ G_SADT_ODON + '|' + G_HONORARIO
	cCampoNG += ","+cAlias+"_CODRDA,"+cAlias+"_LOCATE,"+cAlias+"_CODESP,"+cAlias+"_NOMRDA,"+cAlias+"_DESLOC,"+cAlias+"_CODLOC"
endIf

if existBlock("PLS498BT")
	cCampoNG := execBlock("PLS498BT",.F.,.F.,{cCampoNG})
endIf

if ! empty(cConteudo)

	BE4->(dbSetOrder(2))//BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
	if BE4->( msSeek( xFilial("BE4") + padr(cConteudo,18)))
	
		&cCampo   := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		cConteudo := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
	
		lFound 	  := .t.
		nRecBE4	  := BE4->(recno())
		cRdaSol   := BE4->BE4_CODRDA
		
	else
	
		BE4->( dbSetOrder(7) )//BE4_FILIAL + BE4_SENHA
		if BE4->( msSeek( xFilial("BE4") + padr(cConteudo,16)))
	
			&cCampo   := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		   	cConteudo := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
			lFound	  := .t.
			nRecBE4	  := BE4->(recno())
			cRdaSol   := BE4->BE4_CODRDA
			
		else
			BE4->(dbSetOrder(1))
			if BE4->( msSeek( xFilial("BE4") + strTran(cConteudo, ".", "")))
				&cCampo   := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
			   	cConteudo := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
				lFound	  := .t.
				nRecBE4	  := BE4->(recno())
				cRdaSol   := BE4->BE4_CODRDA			
			else
			    aviso(STR0061,STR0062,{STR0063},1)//"Atenção"###"Guia de Solicitacao de Internacao nao encontrada"###"Ok"
			    lFound := .F.
			    lRet   := .F.
			endIf
		endIf
		
	endIf
	
endIf

if lFound

	//se a solicitacao esta com data de alta significa que o paciente ja nao esta mais iternado e eu estou tentando incluir uma GRI
	if  BCI->BCI_TIPGUI == G_RES_INTER

		//se eu estiver em uma guia de resumo e a RDA da solicitacao for diferente da rda do BCI eu nao mexo nos dados da rda
		if	cRdaSol <> BCI->BCI_CODRDA
			cCampoNG += ","+cAlias+"_CODRDA,"+cAlias+"_LOCATE,"+cAlias+"_CODESP,"+cAlias+"_NOMRDA,"+cAlias+"_DESLOC,"+cAlias+"_CODLOC,"
		endIf

		cSql := " SELECT BE4_CODOPE || '.' || BE4_CODLDP || '.' || BE4_CODPEG || '.' || BE4_NUMERO GUIA, BE4_CODOPE CODOPE, BE4_TIPALT TIPALT "
		cSql += "   FROM " + retSqlName("BE4")
       	cSql += "  WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
       	cSql += "    AND BE4_GUIINT = '" + cConteudo + "' "
       	cSql += "    AND BE4_TIPFAT IN ('T','P','1','2','4') "
       	cSql += "    AND BE4_TIPGUI = '05' "
      	cSql += "    AND BE4_DTFIMF < '" + dtos(BE4->BE4_DTFIMF) + "' "
       	cSql += "    AND D_E_L_E_T_ =  ' ' "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"trbBe4y",.f.,.t.)

		while ! trbBe4y->(Eof())
		
			cTipAl1 := Posicione('BIY',1,xFilial('BIY')+trbBe4y->CODOPE+trbBe4y->TIPALT,'BIY_MOTSAI')
		
			if  allTrim(cTipAl1) <> '31' //tabela de dominio tipo de saida por transferencia para outro estabelecimento
		
				aviso(STR0061,STR0064+trbBe4y->GUIA+STR0065,{STR0063},1)//"Atenção"###"Já existe a GRI nro ["###"] vinculada a solicitação informada que está com tipo de faturamento total. Não será possível digitar uma nova GRI."###"Ok"
		
				lFound := .f.
				lRet   := .f.
				exit
			endIf
			trbBe4y->(Dbskip())
		endDo
		
		trbBe4y->(dbCloseArea())
	endIf
	
endIf

if lFound
	&("M->"+cAlias+"_GUIPRI") := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
endIf

//Caso informe a guia na alteração, ocorre erro de chave duplicada.
if INCLUI .and. lFound  .and.  BCI->BCI_TIPGUI == G_RES_INTER
	
	aCposPad := eval( { || dbSelectArea("BE4"), DbStruct() })
    
    BE4->(dbGoto(nRecBE4))
    dbSelectArea(cAlias)
	
	&("M->"+cAlias+"_USUARI")	:= BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
	&("M->"+cAlias+"_DATPRO")	:= BE4->BE4_DATPRO //Carregando a data da internação para o valid do usuário funcionar certo
	
	SX3->(dbSetOrder(2))
	SX3->(MsSeek(cAlias+"_USUARI"))

	if eval(&(" { || "+allTrim(SX3->X3_VALID)+" }"))

		if ExistTrigger(cAlias+'_USUARI')
			RunTrigger(1,nil,nil,,cAlias+'_USUARI')
		endIf

	 	For nForCpo := 1 To len(aCposPad)
	  		
	  		//não pode replicar o DTDIGI

	  		cMacro 	 := ("M->" + cAlias + "_" + Subs(aCposPad[nForCpo,1],5,10))
	    	cCampoSl := ("BE4->" + "BE4_" + Subs(aCposPad[nForCpo,1],5,10))

	  		If aCposPad[nForCpo][1] $ "BE4_DTDIGI/BD5_DTDIGI"
	  			cCampoSl := ("BCI->BCI_DTDIGI")
	  		EndIf
	  			
	    	if TYPE(cMacro) <> "U" .and. ! ( cAlias + "_" + Subs(aCposPad[nForCpo,1],5,10) $ cCampoNG )
	        
	            &cMacro := &cCampoSl
		    
		        if ExistTrigger(cAlias + "_" + Subs(aCposPad[nForCpo,1],5,10) )
		        	runTrigger(1,nil,nil,,cAlias + "_" + Subs(aCposPad[nForCpo,1],5,10))
		    	endIf
		    	
	     	endIf
	     	
	    Next
	    
	endIf
	
endIf

BE4->(dbGoto(nResBE4))
BE4->(dbSetOrder(nIndBE4)) 

//Zera o recno para que nao seja restaurado incorretamente caso o valid do campo seja acionado sem a consulta padrao
__nRecBE4 := 0

return lRet

/*/{Protheus.doc} pFilTrGu
@description Validacao de campos autorizacao			
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function pFilTrGu(_cChkOri,aMatLin,oObjGrid,lRefresh,lPergunte)
default oObjGrid  := nil
default lRefresh  := .T.
default lPergunte := .F.
public cAliLGPD	  := ""

//Inicia pergunta
if lPergunte .and. ! pergunte("PLSFIL498",.T.,"Parametros Filtragem")
	return
endIf

aMatLin := {}

//monta guias do peg selecionado
if ! (BCI->BCI_TIPGUI $ G_SOL_INTER + '|' + G_RES_INTER)

	BD5->(dbSetOrder(1)) //BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
	if BD5->(msSeek(xFilial("BD5")+_cChkOri))

		while !BD5->(eof()) .and. BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG) == xFilial("BCI")+_cChkOri
		
			if lPergunte .and. ! empty(MV_PAR02) .and. (BD5->BD5_DATPRO < MV_PAR01 .or. BD5->BD5_DATPRO > MV_PAR02)
				BD5->(dbSkip())
				loop
			endIf

			if BD5->BD5_FASE == '4'
				BD5->(dbSkip())
				loop
			endIf

			if lPergunte .and. !empty(MV_PAR03) .and. BD5->BD5_FASE <> allTrim(str(MV_PAR03)) .and. MV_PAR03 <> 4
				BD5->(dbSkip())
				loop
			endIf

			if lPergunte .and. !empty(MV_PAR04) .and. BD5->BD5_SITUAC <> allTrim(str(MV_PAR04)) .and. MV_PAR04 <> 4
				BD5->(dbSkip())
				loop
			endIf

			aadd(aMatLin,{RETCBOX("BD5_SITUAC",BD5->BD5_SITUAC),;
						  RETCBOX("BD5_FASE",BD5->BD5_FASE),;
						  DTOC(BD5->BD5_DATPRO),;
						  BD5->BD5_NUMERO,;
						  transForm(BD5->BD5_NRLBOR,PesqPict("BE1","BE1_NUMAUT")),;
						  transForm(BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO),"@R !!!!.!!!!.!!!!!!-!!.!"),;
						  allTrim(BD5->BD5_NOMUSR),;
						  transForm(BD5->BD5_VLRPAG,"@E 999,999,999.99"),;
						  .f.})
			cAliLGPD := "BD5_"
			BD5->(dbSkip())
		endDo

	endIf
else
	BE4->(dbSetOrder(1)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	if BE4->(msSeek(xFilial("BE4")+_cChkOri))

		while !BE4->(eof()) .and. BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG) == xFilial("BCI")+_cChkOri

			if lPergunte .and. ! empty(MV_PAR02) .and. (BE4->BE4_DATPRO < MV_PAR01 .or. BE4->BE4_DATPRO > MV_PAR02)
				BE4->(dbSkip())
				loop
			endIf

			if BD5->BD5_FASE == '4'
				BE4->(dbSkip())
				loop
			endIf

			if lPergunte .and. ! empty(MV_PAR03) .and. BE4->BE4_FASE <> allTrim(str(MV_PAR03)) .and. MV_PAR03 <> 4
				BE4->(dbSkip())
				loop
			endIf

			if lPergunte .and. ! empty(MV_PAR04) .and. BE4->BE4_SITUAC <> allTrim(str(MV_PAR04)) .and. MV_PAR04 <> 4
				BE4->(dbSkip())
				loop
			endIf

			xChave  := BE4->BE4_GUIINT//pego o nro da solicitacao que originou o resumo ou o honorario
			xChvOri := ""
			nRecBE4 := BE4->(recno())
			nOrdBE4 := BE4->(indexOrd())

			BE4->(dbSetOrder(1)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
			if BE4->(msSeek(xFilial("BE4")+xChave))
		    	xChvOri := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			endIf

			BE4->(dbSetOrder(nOrdBE4))
			BE4->(dbGoto(nRecBE4))

			aadd(aMatLin,{RETCBOX("BD5_SITUAC",BD5->BD5_SITUAC),;
						  RETCBOX("BE4_FASE",BE4->BE4_FASE),;
						  DTOC(BE4->BE4_DATPRO),;
						  BE4->BE4_NUMERO,;
						  transForm(xChvOri,PesqPict("BE1","BE1_NUMAUT")),;
						  transForm(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),"@R !!!!.!!!!.!!!!!!-!!.!"),;
						  allTrim(BE4->BE4_NOMUSR),;
						  transForm(BE4->BE4_VLRPAG,"@E 999,999,999,999.99"),;
						  .f.})
			cAliLGPD := "BE4_"
			BE4->(dbSkip())
		endDo

	endIf
endIf

if lRefresh
	oObjGrid:SetArray(aMatLin)
	oObjGrid:GoTop()
	oObjGrid:Refresh()
endIf

return

/*/{Protheus.doc} PLSATRPES
@description Pesquisa		
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSATRPES(aMatLin,oObjGrid)
local nTipo 	:= 0
local nOrdBCI   := BCI->(indexOrd())
local oDlg		:= nil
local oFolder	:= nil
local cCadastro := "Pesquisar"
local bOK       := {|| nTipo := oFolder:nOption,oDlg:End() }
local bCancel   := {|| oDlg:End() }
local nI		:= 0
local cMatric   := space( tamSX3("BA1_CODINT")[1]+tamSX3("BA1_CODEMP")[1]+tamSX3("BA1_MATRIC")[1]+tamSX3("BA1_TIPREG")[1]+tamSX3("BA1_DIGITO")[1] )
local cNome     := space( tamSX3("BA1_NOMUSR")[1] )
local cGuia     := space( tamSX3("BD5_NUMERO")[1] )
local cNumLib	:= space( tamSX3("BE1_NUMAUT")[1] )

//Define dialogo...

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,008.3 TO 025,060 OF GetWnddefault()
oDlg:lEscClose := .F.
odlg:nwidth    := 603
odlg:ntop      := 155
odlg:nleft     := 100

@ 034,003 FOLDER oFolder SIZE 296,59 OF oDlg PIXEL PROMPTS  'Nome Beneficiario <F7>',;
															 'Matricula Beneficiario <F8>',;
                                                             'Numero Guia <F9>',;
                                                             'Liberacao Origem <F10>'


setKey(VK_F7 ,{|| oFolder:SetOption(1) })
setKey(VK_F8 ,{|| oFolder:SetOption(2) })
setKey(VK_F9 ,{|| oFolder:SetOption(3) })
setKey(VK_F10,{|| oFolder:SetOption(4) })

DEFINE FONT oFontAutor NAME "Currie" SIZE 000,-011

@ 005,005 SAY "Nome Benef.     :" SIZE 100,010 PIXEL OF oFolder:aDialogs[1] FONT oFontAutor
@ 003,090 MSGET oPes03 VAR cNome PICTURE "@!" SIZE 100,010 PIXEL OF oFolder:aDialogs[1]

@ 005,005 SAY "Matricula       :" SIZE 100,010 PIXEL OF oFolder:aDialogs[2]  FONT oFontAutor
@ 003,090 MSGET oPes04 VAR cMatric PICTURE "@R !!!!.!!!!.!!!!!!-!!.!" SIZE 100,010 PIXEL OF oFolder:aDialogs[2]

@ 005,005 SAY "Nro Guia        :" SIZE 100,010 PIXEL OF oFolder:aDialogs[3]  FONT oFontAutor
@ 003,090 MSGET oPes05 VAR cGuia PICTURE "@!" SIZE 100,010 PIXEL OF oFolder:aDialogs[3]

@ 005,005 SAY "Nro Liberacao   :" PIXEL OF oFolder:aDialogs[4]  FONT oFontAutor
@ 003,090 MSGET oPes06 VAR cNumLib PICTURE	PesqPict("BE1","BE1_NUMAUT") SIZE 100,010 PIXEL OF oFolder:aDialogs[4]

ACTIVATE MSDIALOG oDlg ON INIT eval( {||enChoiceBar(oDlg,bOK,bCancel,.F.,{}) } ) CENTERED
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO

//Opcao selecionada
if nTipo <> 0
   do case
      case nTipo == 1
            nI:= aScan(aMatLin,{|x|  allTrim(cNome)$ allTrim(x[7])  })
      case nTipo == 2
      		cVar:= allTrim(transForm(cMatric,"@R !!!!.!!!!.!!!!!!-!!.!"))
      		nI  := aScan(aMatLin,{|x| allTrim(x[6]) == cVar })
      case nTipo == 3
      		cVar := strzero(val(cGuia),tamSX3("BD5_NUMERO")[1])
      		nI:= aScan(aMatLin,{|x| allTrim(x[4]) == cVar })
      case nTipo == 4
      		cVar:=allTrim(transForm(cNumLib,PesqPict("BE1","BE1_NUMAUT")))
      		nI:= aScan(aMatLin,{|x| allTrim(x[5]) == cVar })
   endCase
   if nI == 0
       msgAlert('Nenhum registro encontrado')
   else
       oObjGrid:nat:= nI
       oObjGrid:Refresh()
       eval(oObjGrid:bLDblClick)
       eval(oObjGrid:BCHANGE)
       oObjGrid:Refresh()
   endIf
endIf

BCI->(dbSetOrder(nOrdBCI))
return

/*/{Protheus.doc} PLS498EML
@description Realiza o envio de email		
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLS498EML(cStatus, nRegBVO, lPortal)
local cRemet	:= ""
local cDestino	:= ""
local cAssunto	:= "Recurso de Glosa nº "
local cBody		:= ""
local cNome		:= ""
local lEnvEmail := GetNewPar("MV_PLEMAIG",.T.)
Local aAreaB4D	:= B4D->(GetArea())

default cStatus	:= ""
default nRegBVO	:= 0
default lPortal	:= .F.

if nRegBVO > 0

	//Posiciona na tabela de Recurso de Glosa
	BVO->(dbGoto(nRegBVO))

	cRec 	 := BVO->BVO_NGLOPE
	cAssunto += cRec + " Seq. " + BVO->BVO_SEQREC

	B4D->(dbSetOrder(6))
	if B4D->(MsSeek(xFilial("B4D")+BVO->BVO_SEQB4D) )
		
		//Posiciona na tabela de RDA e retonar o email do prestador
		BAU->(dbSetOrder(1))
		if BAU->(MsSeek(xFilial("BAU") + B4D->B4D_CODRDA) )
			cNome 	 :=	allTrim(BAU->BAU_NOME)
			cDestino := allTrim(BAU->BAU_EMAIL)
		endIf

	endIf	

	//Posiciona na tabela da Operadora e retorna o email da operadora
	BA0->(dbSetOrder(1))
	if BA0->(MsSeek(xFilial("BA0") + PlsIntPad()) )
		cRemet := allTrim(BA0->BA0_EMAIL)
	endIf

	if lEnvEmail

		if cDestino <> ""
	
			Do Case

				Case cStatus == "1"

					cBody := STR0145 + cNome + "<br>" //"Prezado prestador "
					cBody += STR0146 + cRec + "</strong>.<br>" //"Foi realizado a solicitação de um Recurso de Glosa registrado com o número <strong>"
					cBody += STR0147 //"O recurso será encaminhado para análise.<br>"

				Case cStatus == "2"
					cBody := STR0145 + cNome + "<br>" //"Prezado prestador "
					cBody += STR0148 + cRec + STR0149 //"O recurso de glosa número <strong>"##"</strong> foi encaminhado para análise.<br>"

				Case cStatus == "3"
					cBody := STR0145 + cNome + "<br>" //"Prezado prestador "
					cBody += STR0148 + cRec + STR0150 //"O recurso de glosa número <strong>"##"</strong> foi deferido pela análise.<br>"
				Case cStatus == "4"
					cBody := STR0145 + cNome + "<br>" //"Prezado prestador "
					cBody += STR0148 + cRec + STR0151 //"O recurso de glosa número <strong>"##"</strong> foi indeferido pela análise.<br>"
				Case cStatus == "5"
					cBody := STR0145 + cNome + "<br>" //"Prezado prestador "
					cBody += STR0148 + cRec + STR0152	//"O recurso de glosa número <strong>"##"</strong> foi deferido parcialmente.<br>"

			EndCase

			if !empty(BVO->BVO_DESPRO)
				cBody += STR0153 + allTrim(BVO->BVO_DESPRO) + " <br> " //"Item: "
			endIf

			cBody += STR0154 //"<br>Observações:<br>"
			cBody += "<pre>" + STR0141 + BVO->BVO_JUSRDA + CRLF + STR0142 + BVO->BVO_JUSOPE + "</pre>" //"Justificativa do prestador: " ##"Justificativa da operadora: "
			aCposEDataWF := {{"TEXTO",cBody}}

			PlsWFProc( "000001", STR0155 , cAssunto, "", cDestino,"" ,getNewPar("MV_RSPCMAIL","") ,"\workflow\WfRecGloPadrao.htm" , aCposEDataWF , , ) //"WF - Recurso de glosa"

		else
			
			if !lPortal
				msgAlert(STR0156 + Chr(13) + Chr(10) + STR0157) //"Não foi possível enviar o e-mail. " ## "Verifique se a operadora e o prestador possuem emails válidos!"
			else
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0156 + Chr(13) + Chr(10) + STR0157 + " [" + cNome + "]" , 0, 0, {})//"Não foi possível enviar o e-mail. " ## "Verifique se a operadora e o prestador possuem emails válidos!"
			endIf

		endIf

	endIf

endIf

B4D->( RestArea(aAreaB4D) )

return lEnvEmail

/*/{Protheus.doc} PL498MANT
Ajusta valores na analise de critica
@type function
@author PLS TEAM
@since 24/07/13
@version 1.0
/*/
function PL498MANT(cTp)
local aAreaBD6 		:= {}
Local aRetTx		:= {}
local nRet  		:= 0
local nPrTxPg		:= 0
local nVlrBase		:= 0
local nVlrBaseTX	:= 0
local lTaxa			:= .f. 
local lBD6Found		:= .t.
local lBD6_PRTXPG 	:= BD6->(fieldPos("BD6_PRTXPG")) > 0 
Local nVlrTxPgAP	:= 0
Local lExistCrt20	:= .F. //Tratamento para caso exista a critica 020 nãp podera ser posicionada no momento da analise de glosa
Local n20TxFixo	:= 0

BDX->(dbsetorder(1))
if BDX->(msseek(xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN ) + "020"))
	if BDX->BDX_TIPGLO == "3"
		lExistCrt20 := .T.
	endif
endif
BDX->(msseek(xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN )))
While !(BDX->(eoF())) .AND.  xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN ) == BDX->(BDX_FILIAL + BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN )
	If BDX->BDX_TIPGLO <> "3" .AND. BDX->BDX_TIPREG == "1"
		Exit
	EndIf
	BDX->(dbskip())
EndDo
//preciso saber se tem percentual de taxa e nao e guia PTU
if lBD6_PRTXPG

	if xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV + BDX_SEQUEN + BDX_CODPAD + BDX_CODPRO) !=;
	   BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO) 
		
		aAreaBD6 := BD6->(getArea())
		
		BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
		lBD6Found := BD6->( msSeek( xFilial("BD6") + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV + BDX_SEQUEN + BDX_CODPAD + BDX_CODPRO)))
		 
	endIf
	
	if lBD6Found
		aRetTx := getValTPC(BD6->BD6_VLTXPG, BD6->BD6_VLTXAP, nil, .T.)
		If aRetTx[01]+aRetTx[02] > 0
			nPrTxPg 	:= BD6->BD6_PRTXPG
		EndIf
	endIf
		
	if len(aAreaBD6) > 0
		BD6->(restArea(aAreaBD6))
	endIf	
	
endIf	

nVlrBase 	:= ( BDX->BDX_VLRMAN + BDX->BDX_VLRGLO )
If !lExistCrt20
	nVlrBaseTx 	:= ( BDX->BDX_VLTXPG + BDX->BDX_VLRGTX )
else
	nVlrBaseTx 	:= ( BDX->BDX_VLTXPG)
EndIf
If BDX->BDX_VLTXAP == 0 .OR. lExistCrt20
	nVlrTxPgAP := BDX->BDX_VLTXPG
	n20TxFixo	:= BDX->BDX_VLRGTX
else
	nVlrTxPgAP := BDX->BDX_VLTXAP
endIf
	
	
//Gatilho campo BDX_ACAO //BDX_PERGLO
if cTp == '1' 
	M->BDX_ACAOTX := M->BDX_ACAO

	//1=Glosar; 2=Reconsiderar;
	if empty(M->BDX_ACAO) .or. M->BDX_ACAO == "1"
	
		nRet := 100
		if ! empty(BDX->BDX_PERGLO)
			nRet := BDX->BDX_PERGLO
		endIf

		M->BDX_VLRGLO := nRet * BDX->BDX_VLRMAN / 100
		
		if ! empTy(BDX->BDX_VLRGLO)
			M->BDX_VLRGLO := BDX->BDX_VLRGLO
		endIf
		
		if M->BDX_PERGTX == 0
			M->BDX_PERGTX := nRet
			M->BDX_VLTXPG := nVlrTxPgAP * (100 - M->BDX_PERGTX) / 100
			M->BDX_VLRGTX := nVlrTxPgAP * M->BDX_PERGTX / 100 + n20TxFixo
		endIf

	else
	
		nRet 		  := 100
		M->BDX_VLRMAN := nVlrBase
		M->BDX_VLRGLO := 0

		M->BDX_PERGTX := 100
		
		If !lExistCrt20
			M->BDX_VLRGTX := 0
			M->BDX_VLTXPG := nVlrBaseTx
			M->BDX_VLTXPG := iif(nVlrTxPgAP>0.and.M->BDX_VLTXPG==0.and.M->BDX_ACAOTX=="2",nVlrTxPgAP,M->BDX_VLTXPG)
		else
			M->BDX_VLTXPG := (BDX->BDX_VLTXPG )
			M->BDX_VLRGTX := BDX->BDX_VLRGTX
		EndIf

	endIf

//Gatilho campo BDX_ACAOTX //BDX_PERGTX
elseIf cTp == '2'
	lTaxa := .t.
	
	//1=Glosar Tx; 2=Reconsiderar Tx
	if empty(M->BDX_ACAOTX) .or. M->BDX_ACAOTX == "1"
		
		nRet 		  := BDX->BDX_PERGTX
		M->BDX_VLTXPG := nVlrTxPgAP * (100 - nRet) / 100
		M->BDX_VLRGTX := nVlrTxPgAP * nRet / 100 + n20TxFixo
		
	else
	
		nRet 		  := 100
		If !lExistCrt20
			M->BDX_VLTXPG := (BDX->BDX_VLTXPG + BDX->BDX_VLRGTX)
			M->BDX_VLTXPG := iif(nVlrTxPgAP>0.and.M->BDX_VLTXPG==0.and.M->BDX_ACAOTX=="2",nVlrTxPgAP,M->BDX_VLTXPG)
			M->BDX_VLRGTX := 0
		else
			M->BDX_VLTXPG := (BDX->BDX_VLTXPG )
			M->BDX_VLRGTX := BDX->BDX_VLRGTX
		endIf	
			
	endIf
	
endIf
	

//Atencao:
//Reconsiderar - E possivel aumentar o valor da glosa ou diminir.  
//Glosar - Vai glosar o valor 100%
//Os percentuais da funcionalidade reconsiderar sao apenas informativos
//Ex.: 100% reconsidera nao glosa nada. valor de glosa ZERO
//	   10%  reconsiderar paga 10% e glosa 90% do valor 
//     O percentual em tela sera 10% mais ao gravar deve ser ajustado para seguir o padrao de glosa
//     sera ajustado para 90% glosado.  

//gatilho do campo BDX_PERGLO para BDX_VLRGLO	
if cTp == '3'
	if M->BDX_ACAO == "2"
		M->BDX_PERGLO := 0
	endif
	nRet 			:= ( nVlrBase * M->BDX_PERGLO ) / 100
	M->BDX_VLRGLO 	:= nRet
	
//gatilho do campo BDX_VLRGLO para BDX_PERGLO
elseIf cTp == '4'
	nRet := round( ( M->BDX_VLRGLO / nVlrBase ) * 100, getSX3Cache("BDX_PERGLO", "X3_DECIMAL") ) //BDX_PERGLO
	 
//gatilho do campo BDX_PERGTX para BDX_VLRGTX	
elseIf cTp == '5' 
	lTaxa 		  := .t.
	nRet 		  := round( ( nVlrTxPgAP * M->BDX_PERGTX ) / 100,2)
	M->BDX_VLRGTX := nRet + n20TxFixo
	M->BDX_VLTXPG := nVlrTxPgAP - nRet
	nRet	:= nRet + n20TxFixo
//gatilho do campo BDX_VLRGTX para BDX_PERGTX 	
elseIf cTp == '6' 
	lTaxa 	:= .t.
	nRet := round( ( M->BDX_VLRGTX / (nVlrTxPgAP + n20TxFixo) ) * 100, getSX3Cache("BDX_PERGTX", "X3_DECIMAL")) //BDX_PERGLO

endIf

M->BDX_VLRMAN := (nVlrBase - round(M->BDX_VLRGLO, 2) )

//se nao for referente a taxa de pagamento ajusta o valor + percentual
if ! lTaxa
	
	//conforme mudanca do  BDX_VLRGLO ou BDX_PERGLO ajusta valor,glosa e percentual da taxa de pagamento
	if nPrTxPg > 0
	
		//novo valor de glosa
		if M->BDX_ACAOTX == '1'

			//novo valor
			M->BDX_VLTXPG := ( M->BDX_VLRMAN * nPrTxPg ) / 100
			M->BDX_VLRGTX := ( nVlrTxPgAP - M->BDX_VLTXPG ) + n20TxFixo
		
			//novo percentual de glosa
			if M->BDX_VLRGTX > 0
				M->BDX_PERGTX := ( M->BDX_VLRGTX / (nVlrTxPgAP + n20TxFixo) ) * 100
			endIf
			
		endIf		
		
	endIf

endIf

//valor de pagamento bruto	
M->BDX_VLRPAG := M->BDX_VLRMAN + M->BDX_VLTXPG
return(nRet)

/*/{Protheus.doc} PL498BLO
Bloqueio
@type function
@author PLS TEAM
@since 24/07/13
@version 1.0
/*/
function PL498BLO()

if (Posicione("BAU",1,xFilial("BAU")+M->BD7_CODRDA,"BAU_DATBLO")) <> CTOD("")
	msgInfo(STR0068)
	return(.F.)
else
	return(.T.)
endIf
return()

/*/{Protheus.doc} PLSCheckAll
Marcar/Desmarcar todos os CheckBox de Guias
@type function
@author PLS TEAM
@since 15.08.02
@version 1.0
/*/
function PLSCheckAll(aChk, lAllCheck, aCdCores)
local n 	:= 1

lAllCheck := !lAllCheck

for n := 1 to len(aCdCores)
	&('lChk' + strZero(n,2)) := lAllCheck
next

for n := 1 to len(aChk)
	aChk[n]:refresh()
next

return(nil)

/*/{Protheus.doc} PLSDIARET
@description Retorna os dias Retroativos de uma RDA e a permissão de Digitação das guias no Portal 	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PLSDIARET(cCodInt,cCodRda,cCodloc,ccUsr,dDatAtd)
local aArea		:= getArea()
local cRet			:= ""
local dDataLim	:= CTOD("")

BSO->(dbSetOrder(1)) //BSO_FILIAL, BSO_CODUSR, BSO_CODIGO, BSO_CODLOC, BSO_CODINT
if BSO->(MsSeek(xFilial("BSO")+ccUsr+cCodRda+cCodloc+cCodInt))

	if BSO->BSO_GUIRET = '1'

		//Calcula a data retroativa limite para digitação da guia no portal
		SET CENTURY ON
		dDataLim := DaySub(dDataBase, BSO->BSO_DIARET)
		if (dDataLim > (CtoD(dDatAtd)) )
			cRet := "false|Data de Atendimento é anterior ao limite de dias permitido para digitação de guias do Prestador."
		elseIf (CtoD(dDatAtd) > dDatabase)
			cRet:= "false|Data de Atendimento inserida é maior que a data atual!"
		else
			cRet := DTOC(dDataLim)
			SET CENTURY OFF
		endIf
	else
		cRet := "false|Sem permissão para digitar guias para esse prestador"
	endIf
endIf

restArea(aArea)

return(cRet)

/*/{Protheus.doc} PLBAXINTSXB
@description Executa a consulta padrao (Especialidades)	
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function PL498BAXSXB()
local cSql 		:= ""
local lRet 		:= .f.
local aHeader 	:= {}
local aIndices 	:= {}
local oConsulta := nil
local aArea 	:= getArea()

//Monta a query da consulta padrao
cSql := " SELECT BAX_CODESP, BAQ_DESCRI "
cSql += "   FROM " + retSqlName("BAX") + " BAX, " + retSqlName("BAQ") + " BAQ "
cSql += "  WHERE BAX.BAX_FILIAL = '" + xFilial('BAX') + "' "
cSql += "    AND BAX_CODIGO = '" + M->BD5_CODRDA + "' "
cSql += "    AND BAX_CODINT = '" + M->BD5_OPERDA + "' "
cSql += "    AND BAX_CODLOC = '" + subStr(M->BD5_LOCATE,1,3) + "' "
cSql += "    AND BAX.D_E_L_E_T_ = ' ' "
cSql += "    AND BAQ.BAQ_FILIAL = '" + xFilial('BAQ') + "' "
cSql += "    AND BAQ_CODINT = BAX_CODINT "
cSql += "    AND BAQ_CODESP = BAX_CODESP "
cSql += "    AND BAQ.D_E_L_E_T_ = ' ' "

cSql := changeQuery(cSql)

//Monta a aHeader da consulta
SX3->(dbSetOrder(2))
if SX3->(msSeek("BAX_CODESP", .F.))
	SX3->(aadd(aHeader, {X3_TITULO, 'BAX_CODESP', X3_PICTURE, X3_TAMANHO, X3_DECIMAL, "AlwaysTrue()", X3_USADO, "C", "", "V"}))
	SX3->(aadd(aIndices, {"BAX_CODESP", X3_TITULO}))
endIf

if SX3->(msSeek("BAQ_DESCRI", .F.))
	SX3->(aadd(aHeader, {X3_TITULO, 'BAQ_DESCRI', X3_PICTURE, X3_TAMANHO, X3_DECIMAL, "AlwaysTrue()", X3_USADO, "C", "", "V"}))
endIf

//Monta a consulta padrao
oConsulta:=PlsIntSxb():New()
oConsulta:cTitle := "Especialidades" //Titulo da Consulta
oConsulta:cQuery := cSql             //Query dos dados a serem apresentados
oConsulta:aIndex := aIndices         //Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader := aHeader         //Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:areturn := {'BAX_CODESP'}  //Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM := .T.         //Indica se a query eh executada na base do protheus ou da RM
oConsulta:show()

//Coleta o retorno
if len(oConsulta:aRetSXB) > 0
	VAR_IXB := oConsulta:aRetSXB[1]
	lRet :=.t.
endIf
restArea(aArea)

return lRet

/*/{Protheus.doc} PLRTGUPEG
Libera para pagamento de acordo com os status da TISS
@author PLSTEAM
@since 07/2016
@version P12.
/*/
function PLRTGUPEG(lInfAdic, lExibeMsg)
local cCodOpe  		:= BCI->BCI_CODOPE
local cCodLDP  		:= BCI->BCI_CODLDP
local cCodPEG  		:= BCI->BCI_CODPEG
local cInfAdic		:= CRLF + BCI->BCI_CODRDA + " - " + alltrim(BCI->BCI_NOMRDA) + " - PEG: " + BCI->BCI_CODPEG
local dDatCtbChk	:= PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, , .f.)
local lAltStat 		:= .T.
local cSql	   		:= ''
local AliasTMP 		:= getNextAlias()
local cAlias   		:= "BD7"
local nVlrBD7		:= 0
local aRetFun		:= {.t., ''} //retorno - texto
local lExsPELib		:= ExistBlock("PL498LIBPG")
default lInfAdic	:= .f. //Mais informações da RDA e PEG, para quando liberar vários
default lExibeMsg	:= .t.

if PLVLDBLQCO(dDatCtbChk, {"PLS001"}, .T.) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação

	if BCI->BCI_STTISS == "3"
		iif( lExibeMsg, msgAlert(STR0171, STR0061), "" )
		//msgAlert(STR0171, STR0061) //"Este PEG já foi liberada para pagamento." # "Atenção"
		aRetFun := {.f., STR0171 + cInfAdic}

	elseIf BCI->BCI_SITUAC == "2" //O que define o PEG cancelado é o SITUAC e não o STTISS
		iif( lExibeMsg, msgAlert(STR0176, STR0061), "" )
		//msgAlert(STR0176, STR0061) //"Não é possível liberar para pagamento PEGs que foram cancelados." # "Atenção"
		aRetFun := {.f., STR0176 + cInfAdic}

	else

		cSql += " SELECT "+cAlias+"_FASE FASE, "+cAlias+"_SITUAC SITUAC, COUNT(1), SUM("+cAlias+"_VLRPAG) AS VLRPAG   FROM "+retSqlName(cAlias)+" "+cAlias
		cSql += " WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "
		cSql += "   AND "+cAlias+"_CODOPE = '"+cCodOpe+"' "
		cSql += "   AND "+cAlias+"_CODLDP = '"+cCodLDP+"' "
		cSql += "   AND "+cAlias+"_CODPEG = '"+cCodPEG+"' "
		cSql += "   AND "+cAlias+".D_E_L_E_T_ = ' ' "
		cSql += " GROUP BY "+cAlias+"_FASE, "+cAlias+"_SITUAC "
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),AliasTMP,.F.,.T.)
		
		//Se é final de arquivo, significa que não achou nenhuma guia nas condições acima
		if !(AliasTMP)->(eof())

			while !(AliasTMP)->(eof())

				//SITUAC - 1=Ativa;2=Cancelada;3=Bloqueada
				//FASE - 1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
				//Critérios para Liberar para pagamento
				//   FASE           SITUACAO    - LIBERA?
				//1-Digitação                     1-Ativa - Não
				//1-Digitação                     2-cancelada - Sim
				//1-Digitação                     3-bloqueada - Sim
				//2-Conferência              1-Ativa - Não
				//2-Conferência              2-Cancelada - Sim
				//2-Conferência              3-bloqueada - Sim
				//3-pronta                         1-ativa - Sim
				//3-pronta                         2-cancelada - Sim
				//3-pronta                         3-bloqueada - Sim
				
				if (AliasTMP)->(FASE) $ "12" .And. (AliasTMP)->(SITUAC) == "1" 
					lAltStat := .F.
					EXIT
				endIf
				nVlrBD7 += (AliasTMP)->(VLRPAG)
				(AliasTMP)->(dbSkip())
			endDo

			if lAltStat
			
				if lExsPELib
					aRetFun := ExecBlock("PL498LIBPG", .f., .f., {lInfAdic, lExibeMsg, cInfAdic})
					aRetFun := iif(valtype(aRetFun) != "A", {.t., ''}, aRetFun)
					iif( (!aRetFun[1] .and. lExibeMsg .and. !empty(aRetFun[2])), msgalert(aRetFun[2], STR0061), "")
				endif
				
				if aRetFun[1]
					if nVlrBD7 <= 0

						if  ( lInfAdic .or. msgYesNo( STR0184, STR0185 )  ) //"Por não ter valor a ser pago, este protocolo será encerrado com o status '4 - Encerrado sem pagamento'. Deseja Continuar? " ### "Status Protocolo"
							
							//Funcao definida no plsa500
							attFase("4")

							AtuStaTiss("4", lExibeMsg)
							aRetFun := {.t., cInfAdic}
						EndIf

					Elseif ( lInfAdic .or. msgYesNo( STR0172 ) ) //"Tem certeza que deseja liberar para pagamento? O processo não poderá ser desfeito."

						AtuStaTiss("3", lExibeMsg)
						aRetFun := {.t., cInfAdic}
					endIf
				endif
			else
				iif( lExibeMsg, msgAlert(STR0174, STR0061), "" ) //"Não será possível liberar para pagamento! Todas as guias devem estar com a fase pronta." # "Atenção"
				aRetFun := {.f., STR0174 + cInfAdic}
			endIf

		else
			iif( lExibeMsg, msgAlert(STR0175, STR0061), "") //"Esta PEG não possui guias." # "Atenção"
			aRetFun := {.f., STR0175 + cInfAdic}
		endIf
		
		(AliasTMP)->(dbCloseArea())
		
	endIf
	
endIf

return aRetFun

/*
//Alteração para atender os status da TISS
*/
static function AtuStaTiss(cStatiss, lExibeMsg)
default lExibeMsg	:= .t.

BCI->(reclock("BCI",.F.))
	BCI->BCI_STTISS := cStatiss					
	BCI->BCI_USRLIB	:= __cuserid
	BCI->BCI_DTHRLB	:= Dtos(dDatabase) + " - " + Time()					
BCI->(MsUnlock())

if existBlock( "PLS498OK" )
	execBlock("PLS498OK",.F.,.F.)
endIf
iif( lExibeMsg, msgInfo(STR0173), "" ) //"Concluído com sucesso!"

Return

/*/{Protheus.doc} PLBE4USUAR
//Função para o X3_VALID do campo BE4_USUARI, para que se comporte diferente no proc contas (Resumo) e no atendimento (Solicitação)
@author PLSTEAM
@since 12/04/2017
/*/
function PLBE4USUAR()
local lRet := .F.

if empty(M->BE4_USUARI)
	lRet := .t.
else

	if IsInCallStack("PLSA500")
		lRet := (PLSA090USR(M->BE4_USUARI,iif(empty(M->BE4_DATPRO), M->BE4_DTDIGI, M->BE4_DATPRO),M->BE4_HORPRO,"BE4",,,,,,,,,,,,,,,,,,,.T.))
	else
		lRet := (PLSA090USR(M->BE4_USUARI,M->BE4_DTDIGI,M->BE4_HORPRO,"BE4",,,,,,,,,,,,,,,,,,,.T.))                      
	endIf

endIf

return lRet

/*/{Protheus.doc} PLSBCIxBXX
Função para verificar se o XML referente à geração de um PEG foi completamente importado
lRet = .T. = Arquivo não importado totalmente
Tem que estar posicionado no BCI!!
@author PLSTEAM
@since 12/04/2017
/*/
function PLSBCIxBXX(lHelp)
local lRet := .F.
default lHelp := .T.

if BCI->BCI_CODLDP == PLSRetLdp(2)
	
	if !(empty(BCI->(BCI_IDXML)))
		
		BXX->(dbSetOrder(8))
		
		if BXX->(MsSeek(xFilial("BXX") + BCI->(BCI_CODOPE+BCI_CODRDA+BCI_IDXML))) .AND. BXX->BXX_STATUS <> '3'
		
			if lHelp
				msgStop("O arquivo referente à este Protocolo ainda não foi Importado ou sua importação foi incompleta. Somente será possível prosseguir após a importação completa do arquivo", "Alerta")
			else

				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', BCI->( BCI_CODOPE + BCI_CODLDP + BCI_CODPEG) + ": O arquivo referente à este Protocolo ainda não foi Importado ou sua importação foi incompleta. Somente será possível prosseguir após a importação completa do arquivo" , 0, 0, {})
				
			endIf
		
			lRet := .T.
		
		endIf
		
	else
	
		BXX->(dbSetOrder(2))
		if BXX->(MsSeek(xFilial("BXX") + BCI->(BCI_CODOPE+BCI_CODRDA+BCI_CODPEG))) .AND. BXX->BXX_STATUS <> '3'
			
			if lHelp
				msgStop("O arquivo referente à este Protocolo ainda não foi Importado ou sua importação foi incompleta. Somente será possível prosseguir após a importação completa do arquivo", "Alerta")
			else

				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', BCI->( BCI_CODOPE + BCI_CODLDP + BCI_CODPEG) + ": O arquivo referente à este Protocolo ainda não foi Importado ou sua importação foi incompleta. Somente será possível prosseguir após a importação completa do arquivo" , 0, 0, {})
				
			endIf
			
			lRet := .T.	
		endIf
		
	endIf
	
endIf

return lRet

/*/{Protheus.doc} PLSSTCPG
Função para a chamada do botão de cancelar PEG.
Necessária para verificação se o arquivo XML foi completamente imprtado.
@author PLSTEAM
@since 25/04/2017
/*/
function PLSSTCPG()
local xRet := nil

if !(PLSBCIxBXX())
	xRet := Processa({|| PLCANCPEG()}, "Aguarde")
endIf

return xRet

/*/{Protheus.doc} PLVLDPEG
Valida a PEG destino informada na transferência de guias.
Não pode estar Faturada e nem estar nos locais: Dig.Offline e Generico.
@author PLSTEAM
@since 28/03/2018
/*/
function PLVLDPEG(cPegDes)
local lRet := .T.
local aArea := BCI->(GetArea())
local cLocais := (PLSRETLDP(9) + '|' + PLSRETLDP(4) ) // 4=Digitação Offline; 9=local Generico

default cPegDes := ""

If !existCpo("BCI",cPegDes,1)
  lRet := .F.
Else
	BCI->(dbSetOrder(1)) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
	if BCI->( msSeek( xFilial("BCI") + cPegDes ) )
	   If BCI->BCI_FASE == "4" .OR. (BCI->BCI_CODLDP $ cLocais)
	      lRet := .F.
	      MsgAlert(STR0183)
	   EndIf
	EndIf
Endif

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLS498BEA
Filtro de liberação de acordo com o beneficiário informado.

@author    Lucas Nonato
@version   V12
@since     05/06/2018
/*/
//------------------------------------------------------------------------------------------
function PLS498BEA()
local cRet := "@#.T."
local cMatric := ''

if Type('M->BD5_USUARI') <> 'U' .and. !empty(M->BD5_USUARI)
	cMatric := M->BD5_USUARI
	cRet 	:= "@#BEA_FILIAL == '"+xFilial("BEA")+"' .AND. BEA_OPEUSR ==  '"+subStr(cMatric,1,4)+"' .AND. BEA_CODEMP == '"+subStr(cMatric,5,4)+"' .AND. BEA_MATRIC == '"+subStr(cMatric,9,6)+"' .AND. BEA_TIPREG == '"+subStr(cMatric,15,2)+"' "
endIf

cRet += " @#"

return cRet

//--------------------------------------------------------------
/*/{Protheus.doc} PLSA498PRC

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
function PLSA498PRC(lRep)
local aMsg  	as array
local cAliTmp 	as char
local cMsg		as char
local cRep		:= ""
default lRep := .t.
aMsg := {}
if lRep
	cRep := "(re)"
endif
//Só faz a validação do calendario contabil uma vez pra otimizar o processo.
if !PLVLDBLQCO(dDataBase, {"PLS005"}, .t.) 
	return
endif

if !msgYesNo("Confirma o "+cRep+"processamento dos itens selecionados?") 
	return
endif

cAliTmp := getChecked()

if (cAliTmp)->(eof())
	msgInfo("Nenhum item selecionado.")
endif

while (cAliTmp)->(!eof())	
	BCI->(dbgoto((cAliTmp)->RECNO))
	if lRep
		PLSPROCRGR("BCI",BCI->(recno()),K_RetFas,"1",.f.)
	endif
	cMsg := PLSA175FAS("BCI",BCI->(recno()),K_Alterar,.t.,.f.)
	aadd(aMsg, {BCI->BCI_CODPEG, alltrim(BCI->BCI_NOMRDA), cMsg})
	(cAliTmp)->(dbskip())
enddo
(cAliTmp)->(dbclosearea())

if len(aMsg) > 0 
	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()
	PLSCRIGEN(aMsg,{{"Protocolo","@C",6},{"Prestador","@C",30},{"Resumo","@C",80}},"Resumo do processamento",nil,nil)
endif

return

//--------------------------------------------------------------
/*/{Protheus.doc} getChecked
Pega os itens marcados

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
static function getChecked()
local cSql  	as char
local cMark 	as char
local cFiltro 	as char
local cAlias 	as char

cAlias := getNextAlias()
cMark := oMBrwBCI:cMark
cFiltro := strtran(oMBrwBCI:GetFilterDefault(),"@","")

cSql := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("BCI") + " BCI "
cSql += " WHERE " + cFiltro 
cSql += " AND BCI_OK = '" + cMark + "'" 
cSql += " AND BCI.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

return cAlias

//--------------------------------------------------------------
/*/{Protheus.doc} allMark
Função para marcar e desmarcar todos os itens da MarkBrowse

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
static function allMark()
local cWhere := strtran(oMBrwBCI:GetFilterDefault(),"@","")
local cMark := oMBrwBCI:cMark

cSql := "UPDATE " + RetSqlName("BCI") + " SET BCI_OK = CASE " 
cSql += " WHEN BCI_OK = '" + cMark + "' THEN '  ' "  
cSql += " WHEN BCI_OK <> '" + cMark + "' THEN '" + cMark + "' END" 
cSql += " WHERE " + cWhere

PLSCOMMIT(cSql)

oMBrwBCI:oBrowse:Refresh(.t.)

return .T.

//--------------------------------------------------------------
/*/{Protheus.doc} PLSSMFila
Simula a fila, boa para usar em debugs

@author    Lucas Nonato
@version   V12
@since     21/10/2019
/*/
user function PLSSMFila()
u_fRoboPeg()	
u_fRoboGuia()
u_fRoboEve()
u_fRoboGuia()
u_fRoboPeg()
return

//--------------------------------------------------------------
/*/{Protheus.doc} PLSRETGUQT
Retornar a quantidade de guias na fila

@author    Lucas Nonato
@version   V12
@since     21/10/2019
/*/
function PLSRETGUQT()
local cSql 		:= ""
local cCodPeg	:= ""
Local cTabGuia  := "TABGUI"+cEmpAnt

cAliTmp := getChecked()
if (cAliTmp)->(eof())
	cCodPeg := "'"+BCI->BCI_CODPEG+"'"
else
	while (cAliTmp)->(!eof())	
		BCI->(dbgoto((cAliTmp)->RECNO))
		cCodPeg += iif(!empty(cCodPeg),",","")+"'"+BCI->BCI_CODPEG+"'"
		(cAliTmp)->(dbskip())
	enddo
endif

(cAliTmp)->(dbclosearea())

cSql := " SELECT * FROM "
cSql += " (SELECT COUNT(1) QTDSELEC FROM " + cTabGuia + " WHERE CODPEG IN ("+cCodPeg+")) A, "
cSql += " (SELECT COUNT(1) QTDSFALT FROM " + cTabGuia + " WHERE CODPEG IN ("+cCodPeg+") AND STATUS <> '3') B, "
cSql += " (SELECT COUNT(1) QTDNPROC FROM " + cTabGuia + " WHERE STATUS <> '3') C, "
cSql += " (SELECT COUNT(1) QTDTOTAL FROM " + cTabGuia + ") D "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"QTDFILA2",.f.,.t.)
nQtdSel 	:= QTDFILA2->QTDSELEC
nQtdSFal 	:= QTDFILA2->QTDSFALT
nQtdNPro 	:= QTDFILA2->QTDNPROC
nQtdTot 	:= QTDFILA2->QTDTOTAL
QTDFILA2->(dbclosearea())

Aviso( "Robôs de Processamento","Para a(s) PEG(s) selecionada(s) restam: " + cvaltochar(nQtdSFal) + " de "+ cvaltochar(nQtdSel) +  CRLF +"Total de itens pendentes na Fila de processamento: " + cvaltochar(nQtdNPro) + " de " + cvaltochar(nQtdTot)  ,{ "Ok" }, 2 )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSVLGTX
função que valida o valor do campo Vlr. Glo. Tx.
@author Pablo Alipio
@since 27/08/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSVLGTX()
local lExistCrt20 := .F.
local lRet 		  := .F.

BDX->(dbsetorder(1))
if BDX->(msseek(xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN )+ "020"))
	if BDX->BDX_TIPGLO == "3"
		lExistCrt20 := .T.
	endif
endif

BDX->(msseek(xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN )))
While !(BDX->(eoF())) .AND.  xFilial('BDX') + M->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN ) == BDX->(BDX_FILIAL + BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV +  BDX_CODPAD + BDX_CODPRO + BDX_SEQUEN )
	If BDX->BDX_TIPGLO <> "3" .AND. BDX->BDX_TIPREG == "1"
		Exit
	EndIf
	BDX->(dbskip())
EndDo

if lExistCrt20
	lRet := iif( M->BDX_VLRGTX <= BDX->BDX_VLTXPG, .T., .F.)
else
	lRet := iif( M->BDX_VLRGTX <= (BDX->BDX_VLTXPG + BDX->BDX_VLRGTX), .T., .F.) 
	if !lRet
		lRet := iif( M->BDX_VLRGTX <= (BDX->BDX_VLTXAP + BDX->BDX_VLRGTX), .T., .F.)
	endif
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLValx3LDP
valid do campo BCI_CODPEG
@author Oscar Zanin
@since 18/12/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLValx3LDP()
Local cnaopode := PLSRETLDP(2) + "|" + PLSRETLDP(3) + "|" + PLSRETLDP(4) + "|" + PLSRETLDP(5) + "|" + PLSRETLDP(6) + "|" + PLSRETLDP(7) + "|" + PLSRETLDP(9)
return ExistCpo("BCG",M->BCI_CODLDP,1) .and. !( M->BCI_CODLDP $ cnaopode )

//-------------------------------------------------------------------
/*/{Protheus.doc} PlExistUsu
Função para permitir validação nos campos BE4_USUARI e BD5_USUARI quando bloqueados, mas que passaram em atendimento
Resolução para chamado DSAUPC-11359
Alteração para atender o chamado DSAUPC-12328 (26/05/2020)
@author Eduardo Bento
@since 18/02/2020
@version   V12.
/*/
//-------------------------------------------------------------------
function PlExistUsu(cMatExist,lValide9)
//function PlExistUsu(cMatExist)
Local lExiste	:= .F.
Default cMatExist := ""
Default lValide9 := .T. //Retirar após alteração no dicic

If lValide9 //Retirar após alteração no dicic
	Return lExiste //Retirar após alteração no dicic
Else //Retirar após alteração no dicic
	If empty(cMatExist) //Se o input estiver vazio, estará liberado
		lExiste := .T.
	Else
		If IsInCallStack("PLSA500MOV")
			BA1->(dbSetOrder(2))
			If BA1->(msSeek(xFilial("BA1")+cMatExist)) .and. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) == alltrim(cMatExist) //[Verifica se existe com seek] .and. [Verifica se é exatamente o mesmo número]
				lExiste := .T.
			Endif
		Endif
	Endif
Endif //Retirar após alteração no dicic

Return lExiste

/*/{Protheus doc} DescrGen
Function do X3_WHEN BD6_DESPRO 
@author PLSTEAM
@since 14.04.2012
@version P12
/*/
function DescrGen()
local cCodMedGen := getNewPar("MV_PLMEDPT","")
local cCodMatGen := getNewPar("MV_PLMATPT","")
local cCodTaxGen := getNewPar("MV_PLTAXPT","")
local cCodOpmGen := getNewPar("MV_PLOPMPT","")

if allTrim(M->BD6_CODPRO) $(cCodMedGen+"-"+ cCodMatGen+"-"+ cCodTaxGen+"-"+ cCodOpmGen) //Verifica eventos genericos
	return (.T.)
endIf

return (.f.)

/*/{Protheus doc} plsDocBCI
Visualizar documentos vinculados a PEG
@author PLSTEAM
@since 04/2022
@version P12
/*/

function plsDocBCI()

	local aEntidade := MsRelation()

	if len(aEntidade)>103 //BCI fica na posição [104] quando dll está presente no RPO
		iif( aScan(aEntidade[104],"BCI") > 0 , MsDocument( "BCI", BCI->( recno() ), 3 ) , aviso("Atenção","Não existe banco de conhecimento para a tabela BCI",{"Ok"},1))
	endif

return
