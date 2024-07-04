#INCLUDE "PLSA500.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "tcBrowse.CH"
#INCLUDE "JPEG.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

STATIC __lManunt 	:= .f.
STATIC __aFilesLay 	:= {}
STATIC __cCodTab	:= ""
STATIC oBrwPro 		:= nil
STATIC oBrwGlo 		:= nil
STATIC cGMLcodGlo   := ""
STATIC lUnimed		:= allTrim(getNewPar("MV_PLSUNI","0")) == "1"
Static objCENFUNLGP := CENFUNLGP():New()

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

Static lRDAValida := .T.
Static aCritRDA   := {}

#DEFINE K_Fase     5
#DEFINE K_RetFas   6
#DEFINE K_Analise  7
#DEFINE K_Cancel   8
#DEFINE K_Bloqueio 9
#DEFINE K_Desbloq  10
#DEFINE K_Ajuste   10
#DEFINE K_Estorno  12
#DEFINE K_BCOCON   13
#DEFINE Fir_Node   '1'
#DEFINE Sec_Node   '2'
#DEFINE Thi_Node   '3'

#DEFINE DIGITACAO 	"1"
#DEFINE CONFERENC 	"2"
#DEFINE PRONTA 		"3"
#DEFINE FATURADA 	"4"

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

#DEFINE PLSMONEY "@E 99,999,999,999.99"
#DEFINE __aCdCri055 {"026",STR0002} //"Procedimento informado nao existe na tabela padrao."
#DEFINE __aCdCri112 {"546",STR0001} //"Valor total da participacao financeira de um mesmo procedimento divergentes entre as guias."
#DEFINE __aCdCri113 {"547",STR0002} //"Valor de pagamento, do subitem de um mesmo procedimento para a mesma R.D.A, divergentes entre as guias."
#DEFINE __aCdCri114 {"548",STR0003} //"Codigo da R.D.A para pagamento de um mesmo subitem divergentes entre as guias."
#DEFINE __aCdCri116 {"550",STR0004} //"Nao foi possivel localizar o nivel de cobranca."
#DEFINE __aCdCri117 {"542",STR0005} //"Matriculas dos usuarios divergentes entre as duas guias."
#DEFINE __aCdCri119 {"544",STR0006} //"Procedimento nao encontrado na guia clonada."
#DEFINE __aCdCri120 {"545",STR0007} //"Codigos de procedimentos divergentes entre as duas guias."
#DEFINE __aCdCri121 {"551",STR0008} //"Procedimento nao encontrado na guia estornada."
#DEFINE __aCdCri149 {"557",STR0241}  //"Subitem nao localizado na guia clonada."
#DEFINE __aCdCri150 {"558",STR0242}  //"Bloqueio de cobranca divergente entre os procedimentos."
#DEFINE __aCdCri151 {"559",STR0243}  //"Bloqueio de pagamento divergente entre os procedimentos."
#DEFINE __aCdCri159 {"088",STR0075}//"Matricula não existe ou invalida, criado usuário genérico."
#DEFINE __aCdCri198 {"09Q",STR0093}//"Habilita checagem DE/PARA TUSS!"


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA500.
Tela MVC de análise de contas.

@author Lucas Nonato
@since  01/04/2019
@version P12
/*/
function PLSA500(cAlias,nReg,nOpc,cChavGui,lfiltra)
local aCoors 		as array
local aRetFun		as array
local oBrowseUp		as object
local cFiltro 		as char
local cCodPEG   	as char
Local nRecPos		:= 0
Local lPosGuia		:= .F.

private _cAlias 	:= cAlias
private oCab 		:= P600GETBCM(cAlias)
private oBD6 		:= P600GETBCM("BD6")
private oBD7 		:= P600GETBCM("BD7")
private aHBD7  		as array

default cChavGui  := ""
default lfiltra	  := .T.

if oBD7 <> nil
	HMList(oBD7, aHBD7)
endif

aRotina := {}
aCoors 		:= FWGetDialogSize( oMainWnd )
cCodPEG   := BCI->BCI_CODPEG
//Monta filtro. Se nIdx == 0 indica que veio da rotina padrao por peg
cFiltro := retFiltro(cAlias,"BCI")
cFiltro := Substr(cFiltro,2,len(cFiltro))

aRetFun := PLSDADRDA(BCI->BCI_OPERDA,BCI->BCI_CODRDA,"1",dDataBase,,,,,,,,,,,.T.)

//alimentamos as static para validar na chamada da tela, pois se barrar aqui, o cara nem 
//consegue ver o que tem dentro do PEG
lRDAValida := aRetFun[1]
aCritRDA   := aclone(aRetFun[2])

//Ponto de entrada para o usuario customizar o filtro da mbrowse
if existBlock("PLS500FILT")
	cFiltro := execBlock("PLS500FILT",.f.,.f., {cFiltro})
endIf 

if !empty(cChavGui) .and. len(cChavGui) >= 10
	If lfiltra
		cFiltro := cAlias+"_FILIAL = '" + xfilial(cAlias) + "' "
		cFiltro += " AND "+cAlias+"_CODOPE = '" + substr(cChavGui, 1, 4) + "' "
		cFiltro += " AND "+cAlias+"_CODLDP = '" + substr(cChavGui, 5, 4) + "' "
		cFiltro += " AND "+cAlias+"_CODPEG = '" + substr(cChavGui, 9, 8) + "' "
		cFiltro += " AND "+cAlias+"_NUMERO = '" + substr(cChavGui, 17, 8) + "' "
	else
		lPosGuia := .T.
	endIf
	(cAlias)->(DbSetOrder(1))
	If (cAlias)->( msSeek( xFilial(cAlias) + cChavGui) )
		nRecPos := (cAlias)->(Recno())
	endIf
endif
// FWmBrowse Superior Candidatos
oBrowseUp:= FWmBrowse():New()
// Aqui se associa o browse ao componente de tela
//oBrowseUp:SetOwner( oPanelUp )
if isPLSA600()
	oBrowseUp:SetDescription( "Análise de Contas - "+" ["+allTrim(BCL->BCL_DESCRI)+"]    "+STR0011+" [ "+cCodPeg+" ] ")
else
	oBrowseUp:SetDescription( "Digitação de Contas - "+" ["+allTrim(BCL->BCL_DESCRI)+"]    "+STR0011+" [ "+cCodPeg+" ] ")
endif
oBrowseUp:SetAlias( cAlias )
// Define de onde virao os botoes deste browse
oBrowseUp:SetMenuDef( 'PLSA500' )
oBrowseUp:SetProfileID( cAlias )
oBrowseUp:setMainProc("PLSA500") 
oBrowseUp:ForceQuitButton()
oBrowseUp:SetFilterDefault("@"+cFiltro)
oBrowseUp:AddLegend( cAlias+"->"+cAlias+"_FASE == '1' .AND. " + cAlias+"->"+cAlias+"_ERRO == '1'"	, "ORANGE"	, "Erro Controlado")
oBrowseUp:AddLegend( cAlias+"->"+cAlias+"_SITUAC <> '1'"	, "WHITE"	, "Bloqueada")
oBrowseUp:AddLegend( cAlias+"->"+cAlias+"_FASE == '1' .AND. " + cAlias+"->"+cAlias+"_ERRO <> '1'"	, "YELLOW"	, STR0237)
oBrowseUp:AddLegend( cAlias+"->"+cAlias+"_FASE == '2'"	, "GRAY"	, STR0238)
oBrowseUp:AddLegend( cAlias+"->"+cAlias+"_FASE == '3'"	, "GREEN"	, STR0239)
oBrowseUp:AddLegend( cAlias+"->"+cAlias+"_FASE == '4'"	, "RED"		, STR0240)
oBrowseUp:DisableDetails()

If lPosGuia
	oBrowseUp:bChange := { || PL500F9POS(@lPosGuia, @oBrowseUp, nRecPos)}
endIf

oBrowseUp:Activate()

lRDAValida := .T.
aCritRDA   := {}

return

/*/{Protheus.doc} PLSA500
Movimentacao
@type function
@author plsteam
@since 07.09.2002
@version 1.0
/*/
function PLSA500MOV(cAlias,nReg,nOpc,aNil,lCancePeg)
local nPosBD6		:= 0
local nCntFor		:= 0
local nPosBRW		:= 0
local nOpcA       	:= 0
local nFor        	:= 0
local nAux        	:= 0
local nControl    	:= 0
local nH            := 0
local nForCpo		:= 0
local n         	:= 1
local nOpcEnc		:= 0
local nPos			:= 0
local nPosPasta		:= 0
local nLinAux		:= 0
local cAliasAux    	:= ""
local cCC           := ""
local cMacro        := ""
local cCodProSel  	:= ""
local cChavLib		:= ""
local cObjEnc		:= ""
local cFilAli   	:= ""
local cSemGuia  	:= ""
local cFunBOk 		:= if(findFunction("PL720BOk"),"PL720BOk()","")
local cCodPro 		:= space(30)
local cChavePes   	:= &(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")
local cFase       	:= &(cAlias+"->"+cAlias+"_FASE")
local cSituac     	:= &(cAlias+"->"+cAlias+"_SITUAC")
local cNumGuia    	:= &(cAlias+"->"+cAlias+"_NUMERO")
local aFiles    	:= {}
local aFilesGRV 	:= {}
local cAliasCab		:= BCL->BCL_ALIAS
local cFunINI   	:= BCL->BCL_FUNINI
local cTipINI   	:= BCL->BCL_TIPINI
local cFunBOT   	:= BCL->BCL_FUNBTO
local cTipBOT   	:= BCL->BCL_TIPFBT
local cFunSAI   	:= BCL->BCL_FUNSAI
local cTipSAI  	 	:= BCL->BCL_TIPSAI
local cFunEDT   	:= BCL->BCL_FUNEDT
local cTipEDT   	:= BCL->BCL_TIPEDT
local cFunGRV   	:= BCL->BCL_FUNGRV
local cTipGRV   	:= BCL->BCL_TIPGRV
local cPerInc   	:= BCL->BCL_PERINC
local nQtdFol  	 	:= BCL->BCL_QTDFOL
local cCodPEG   	:= BCI->BCI_CODPEG
LOCAL cCdOrIt   	:= IIF( &(cAlias+"->"+cAlias+"_ORIMOV") == '5', '5', BCL->BCL_CDORIT) //5 = digitação offline  
local cTipoGuia 	:= BCL->BCL_TIPGUI
local cGuiRel   	:= BCL->BCL_GUIREL
local cCodOpe   	:= BCL->BCL_CODOPE
local cCodLDP   	:= BCI->BCI_CODLDP
local cCodRda   	:= BCI->BCI_CODRDA
local bBotaoVFam  	:= {|| PLSA500FAM(cAlias,nReg,nOpc) }
LOCAL bOK       	:= {|| nOpca := 1,If(PLSA500BOK(aFiles,&("M->"+cAlias+"_CODRDA"),&("M->"+cAlias+"_CID"),nOpc,cCodOpe,cCodLDP,cCodPEG,cFunSai,cTipSAI,cTipoGuia,cGuiRel,oGetBZC),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
local bCancel   	:= {|| oDlg:end() }
local aChave      	:= {}
local aAux        	:= {}
local aButtons    	:= {}
local aBotAux       := {}
local aCampos  	  	:= {}
local aRetAux	  	:= {}
local aFolders  	:= {}
local aPages    	:= {}
local aTitles   	:= {}
local aCols     	:= {}
local aHeader   	:= {}
local aCmpLei		:= {}
local aPar          := {}
local aArea			:= {}
local aAreaBD6		:= {}
local aRet			:= {}
local aRecAlt		:= {}
local aDadUsr   	:= PLSGETUSR()
local lInternado	:= .f.
local lBotaoIte 	:= .f.
local lCreate		:= .t.
local lMemoria 		:= .t.
local lCabAltered	:= .f.
local cMatrUsr  	:= (cAlias)->&( cAlias + "_OPEUSR" ) + (cAlias)->&( cAlias + "_CODEMP ") + (cAlias)->&( cAlias + "_MATRIC" ) + (cAlias)->&( cAlias + "_TIPREG" ) + (cAlias)->&( cAlias + "_DIGITO" )
local oDlg			:= nil
local oFolder      	:= nil
local aCamposOrd	:= nil
local aFolder		:= nil
local oFontAutor	:= nil
local cTpGui		:= ''
local l090Can		:= .f.
local cMacroGui     := "" 
local cSequen		:= "" 
local aChBZC        := {}
local cChvBzc       := ""
local cCampos		:= ""
local cKey			:= ""
local lNewBCM		:= BCM->(FieldPos("BCM_ALTREP")) > 0

//Variaveis de posicionamento
local nPosSeqBX6 := 0
local nBX6CodPad := 0
local nBX6CodPro := 0
local nPosSeqBD6 := 0
local nBD6CodPad := 0
local nBD6CodPro := 0
local isPLSA502	 := isInCallStack("PLSA502")
local aAreaCabec := (cAlias)->(getArea())
local aCmpAlt	 := {}

default lCancePeg   := .f.

private nOpcBot 	:= nOpc
private cObjBrw    	:= "oBrwBD6"
private aHeaderDF  	:= {}
private aColsDF    	:= {}
private aVetTrabDF 	:= {}

private aHeaderBX6 	:= {}
private aColsBX6   	:= {}
private aVetTraBX6 	:= {}

private aTela 	   	:= {}
private oGetB11 	:= nil
private oP500S1,oP500S2,oP500S3,oP500S4,oP500S5 //VARIAVEIS QUE PODEM SER USADAS NO say VIA PTO DE ENTRADA
private oGetBZC     := nil

static cCodigPeg := ""

if !lRDAValida .AND. nOpc <> K_Visualizar
	if len(aCritRDA) > 0
		PLSMOVCRI("3",{},aCritRDA)
	endIf
	return
endif

BCL->(dbSetOrder(1))
if BCL->(msSeek( xFilial("BCL") + BCI->(BCI_CODOPE+BCI_TIPGUI) ) )
	aFiles    	:= PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI,, nOpc, cFase )
	aFilesGRV 	:= PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI,"2", nOpc, cFase)	
endIf

DEFINE FONT oFontAutor NAME "Arial" size 000,-009 BOLD

__lManunt := .t.

if isPLSA502
	cAlias := cAliasCab
endIf

//Verifica se a PEG esta disponivel para edicao
if ! lCancePeg .and. ! isPLSA502

	if ! PLSA500EDT(nOpc,cAlias)
		return 
	endIf
	
endIf	

if nOpc == K_Cancel
	if IIF( FindFunction("PLchkQuebr"), !PLchkQuebr(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO")), .F. )
		return
	endIf
endIf

//Se for bloqueio ou cancelamento não permite se ja foi cobrada custo ope.
if nOpc == K_Cancel
	
	if PLSVERCCBG(&(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),&(cAlias+"->"+cAlias+"_SEQPF"))
		
		if ! lCancePeg
			
			Help("",1,"PLSA500001")
			
		else
			
			if cCodigPeg != cCodPEG
				msgAlert("As guias com cobrança de custo Operacional/co-participação geradas não foram canceladas.", STR0285)
				cCodigPeg := cCodPEG
			endIf
			
		endIf
		
		return
	endIf
	
	if &(cAlias+"->"+cAlias+"_FASE") == FATURADA
		
		if !lCancePeg
			
			Help("",1,"PLSA500002")
			
		else
			
			if cCodigPeg != cCodPEG
				msgAlert("As guias com pagamentos gerados não foram canceladas.", STR0285)
				cCodigPeg := cCodPEG
			endIf
			
		endIf
		
		return
	endIf
	
	if ! lCancePeg
	
		BEA->(dbSetOrder(12))//BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV
		
		l090Can := .f.
		
		if BEA->( msSeek( xFilial('BEA') + cChavePes ) ) .and. BEA->BEA_CANCEL == '0'
			
			l090Can := .t.
			cMsg 	:= PLSA090CAN(.t.,,BEA->(recno()))
			
			if ! empty(cMsg)
				msgAlert(cMsg, STR0285)
				return
			endIf
			
		endIf
		
	endIf	
	
	//exclui movimento contabil se existir
	if ! lCancePeg .and. ! PLSEXMCTB( "T", cChavePes )
		return
	endIf	
	
endIf

//Verifica se para este tipo de guia e permitido incluir registros
if nOpc == K_Incluir .and. cPerInc <> "1" .and. ! isPLSA502
	Help("",1,"PLSA500NPI")
	return
endIf

//Verifica o status da PEG
if ( BCI->BCI_SITUAC <> "1" ) .and. nOpc <> K_Visualizar  .and. !isPLSA502
	Help("",1,"PLSA500NDI")
	return
endIf

//Valida calendario pagto
if nOpc == K_Incluir  .and. ! isPLSA502

	//atualiza status do peg	
 	PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))
	
	//verifica se e um peg de importacao e nao permite inclusão
	if ! empty(BCI->BCI_ARQUIV)
		Aviso( STR0333, STR0334, { "Ok" }, 2 ) // "Validação do PEG" ## "Não e permitido incluir guia manualmente em um PEG gerado pela importação XML"
		return
	endIf
	
	//não permite incluir guia onde o PEG esteja com um dos status abaixo.
	if BCI->BCI_STTISS == "3"
		
		Aviso( STR0333, STR0335, { "Ok" }, 2 ) //"Validação do PEG" ## "Não é permitido incluir guia manualmente em um PEG liberado para pagamento."
		return
		
	elseIf BCI->BCI_STTISS == "4"
		
		Aviso( STR0333, STR0336, { "Ok" }, 2 ) //"Validação do PEG" ## "Não é permitido incluir guia manualmente em um PEG cancelado."
		return
		
	endIf
	
elseIf nOpc == K_Incluir .and. isPLSA502
	
	msgAlert("Não é possível incluir utilizando esta opção, para adicionar itens, é necessário utilizar a alteração da guia")
	return
		
else
	
		aDadUsr := PLSDADUSR(cMatrUsr, "1", .f., dDataBase)				
		
endIf

//Executa funcao de validacao da edicao dos dados
if ! empty(cFunEDT)
	
	aPar := {nOpc}
	
	if cTipEDT == "1"
	
		cMacro := allTrim(cFunEDT)
		if ! &(cMacro)(aPar,,,)
			return
		endIf
		
	else
		
		if ! execBlock(cFunEDT,.f.,.f.,aPar)
			return
		endIf
		
	endIf
	
endIf

//Ponto de entrada para checagen da guia.
if existBlock("PLS500LC")
	lRet := execBlock("PLS500LC",.f.,.f., {nOpc,cAlias})
	if ! lRet
		return
	endIf
endIf

aSize := msAdvSize()
aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }

aObjects := {}

aadd( aObjects, { 100, 100, .t., .t., .f. } )//bd6
aadd( aObjects, { 100, 35, .t., .t., .f. } )//bd7

aPosObj := msObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE "Processamento de Contas" FROM aSize[7], 0 To aSize[6], aSize[5] of oMainWnd PIXEL

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

//Monta informacoes para na frente cria os folders
for nFor := 1 to nQtdFol
	aadd(aFolders,{allTrim(OemtoAnsi(aFiles[nFor,2])),aFiles[nFor,1]})
	aadd(aTitles,allTrim(aFiles[nFor,2])+" <"+aFiles[nFor,5]+"> " )
	aadd(aPages,"HEADER " + trim(str(nFor,2)))
	nControl++
next

//Cria os folder												//col		//lin
oFolder := TFolder():new(030,001,aTitles,aPages,oDlg,,,,.t.,.f.,aSize[3], aSize[4])

oFolder:bChange := {|nFolder| 	iIf(type("oDlgSay") == "O",;
									iIf(oDlgSay:className() == "MSDIALOG",;
										iIf(nFolder == 2 .and. type("oSay1") == "O" .and. type("oSay2") == "O" .and. type("oSay3") == "O" .and. type("oSay4") == "O",;
											(oSay1:Hide(),oSay2:Hide(),oSay3:Hide(),oSay4:Hide()),;
											(oSay1:Show(),oSay2:Show(),oSay3:Show(),oSay4:Show())),),nil) }
if nOpc == K_Cancel
	nOpcEnc := K_Visualizar
elseIf nOpc == K_Ajuste
	nOpcEnc := K_Alterar
else
	nOpcEnc := nOpc
endIf

if nOpc <> K_Incluir

	if cTipoGuia $ ( G_SOL_INTER + "|" + G_RES_INTER )
		lInternado := .t.
	else
		lInternado := (cAlias)->&( cAlias + "_REGATE" ) == '1'
	endIf
	
	if valType(oDlg) == "O"
		oDlg:cCaption := oDlg:cCaption + " [" + STR0020 + " - " + iIf(lInternado,STR0021,STR0022) + "] " //Regime de Atendimento##Internacao##Ambulatorial
	endIf
	
endIf

//Monta os Objetos
for nFor := 1 to len(aFiles)
	// parametro usado para adicionar apenas campos selecionados no tipos de guias 
	aadd(aFiles[nFor,4], "NOUSER")
	
	cAliasAux := aFiles[nFor,1]
	
	//Configura keys
	if nFor == 1
		setKey(Eval( { || ( nPos := ascan(__aKeys,{|x| x[1] == aFiles[nFor,5] })  )  , __aKeys[nFor,2] } ) ,{|| oFolder:SetOption(1) })
	elseIf nFor == 2
		setKey(Eval( { || ( nPos := ascan(__aKeys,{|x| x[1] == aFiles[nFor,5] })  )  , __aKeys[nFor,2] } ) ,{|| oFolder:SetOption(2) })
	elseIf nFor == 3
		setKey(Eval( { || ( nPos := ascan(__aKeys,{|x| x[1] == aFiles[nFor,5] })  )  , __aKeys[nFor,2] } ) ,{|| oFolder:SetOption(3) })
	elseIf nFor == 4
		setKey(Eval( { || ( nPos := ascan(__aKeys,{|x| x[1] == aFiles[nFor,5] })  )  , __aKeys[nFor,2] } ) ,{|| oFolder:SetOption(4) })
	endIf
	
	if aFiles[nFor,3] == "2"
		
		//Monta RegToMemory
		regToMemory(cAliasAux,nOpc == K_Incluir)
		
		//Majoracao
		if (cAliasAux)->(fieldPos(cAliasAux+"_TIPMAJ")) > 0
			
			dbSelectArea("BAU")
			
			if (Posicione("BAU",1,xFilial("BAU")+M->&(cAliasAux+"_CODRDA"),"BAU->BAU_TIPPRE") <> getNewPar("MV_PLSTPIN","OPE"))
				M->&(cAliasAux+"_TIPMAJ") := iIf(BAU->BAU_TIPPE == "F","1",iIf(BAU->BAU_TIPPE == "J","2",""))
			else
				M->&(cAliasAux+"_TIPMAJ") := ""
			endIf
			
		endIf
		
		//Monta matriz de campos ja ordenados
		aRetAux    	:= PLSORDFIE(cAliasAux, aFiles[nFor,4], iIf(nOpc <> K_Ajuste, aFiles[nFor,9], aCampos), .f.)
		aCamposOrd 	:= aRetAux[1]
		aFolder	  	:= aRetAux[2]
		
		//Monta Objeto Enchoice																						                              //Linha		      //Coluna//Linha   //Coluna
		&("oEnc"+cAliasAux) := msmGet():new(cAliasAux, nReg, iIf(isPLSA502,K_Visualizar,nOpcEnc),/*aCRA*/,/*cLetras*/,/*cTexto*/,aFiles[nFor,4],{ aFiles[nFor,11] + 5, 0, aSize[4] - 50, aSize[3] },if(nOpc <> K_Ajuste,aFiles[nFor,9],aCampos),/*nModelo*/,/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oFolder:aDialogs[ val(aFiles[nFor,10]) ],/*lF3*/,lMemoria  ,/*lColumn*/,/*caTela*/,/*lNoFolder*/,/*lProperty*/,aCamposOrd,aFolder ,lCreate,/*lNoMDIStretch*/,/*cTela*/) 
		
		cObjEnc := ("oEnc"+cAliasAux)
		
	else
		
		aCampos := aClone(aFiles[nFor,4])
		
		for nAux := 1 to len(aCampos)
			cCampos += aCampos[nAux] + iIf( len(aCampos) >= nAux,',','')
		next
			
		aCmpLei := iIf( len(aFiles[nFor]) >= 17, aClone(aFiles[nFor,17]),{})
		
		&("aCols"   + cAliasAux) := {}
		&("aHeader" + cAliasAux) := {}
		&("aVetTrab"+ cAliasAux) := {}
		
		STORE HEADER cAliasAux TO &("aHeader"+cAliasAux) For (allTrim(SX3->X3_CAMPO) $ cCampos) 
		
		if nOpc == K_Incluir
			store COLS blank cAliasAux to &("aCols"+cAliasAux) FROM &("aHeader"+cAliasAux)
		else
		
			cSequen   := BD6->BD6_SEQUEN
			cChavePes := xFilial(cAlias) + (cAlias)->&( '(' + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG + " + cAlias + "_NUMERO ) " ) + cCdOrIt + iIf(isPLSA502,cSequen,"") 
					
			aArea := (cAliasAux)->(getArea())
			
			cKey := cAliasAux + '->( ' + cAliasAux + '_FILIAL + ' +  cAliasAux + '_CODOPE + ' +  cAliasAux + '_CODLDP + ' + cAliasAux + '_CODPEG + ' + cAliasAux + '_NUMERO + ' + cAliasAux + '_ORIMOV'
			cKey += iIf(isPLSA502, ' + ' + cAliasAux + '_SEQUEN )', ' )' )
			
			plMontACols(cAliasAux, 1, &("aHeader"+cAliasAux), @&("aCols"+cAliasAux), @&("aVetTrab"+cAliasAux), cChavePes, cKey )
			
			(cAliasAux)->(restArea(aArea))
				
		endIf
		
		//Se for um botao que esta localizado no item eu nao monto o browse
		if len(aFiles[nFor]) >= 16
			lBotaoIte := aFiles[nFor][16] == '1' .Or. (len(aFiles[nFor]) > 17 .and. aFiles[nFor][18] == "01" .and. aFiles[nFor,1] == "B43" .and. FunName() $ "PLSA498;PLSA600")
		endIf
		
		if !lBotaoIte
			
			//neste caso eu nao tenho que dimensionar o browse
			if aFiles[nFor,12] + aFiles[nFor,11] + aFiles[nFor,13] + aFiles[nFor,14] == 0 
				
				//new(                                 nRow,nCol ,nWidth   ,nHeig    ,bLine ,oWnd                                    ,bChange  ,blDblClick,bRClick   ,oFont  ,cMsg ,lUpdate,bWhen  ,lDesign,bValid,aHeaderBrw            ,aColsBrw            ,lSemafaro,cAlias    ,nOpc   ,cTitulo              ,aExpSem,cFunIni,bAdd,aVetTrab                ,cVldLine,cVldDel                                                          ,bFilter,bAfterEdit       ,aButEsp ,bMultaCols,bAftCancel   ,bBeforeDialog,lOrdColED,lConsFold,aFieldRO,lSx3User,aDifSize)
				&("oBrw" + cAliasAux) := TPLSBrw():new(0   , 0   , aSize[3], aSize[4], nil  ,oFolder:aDialogs[ val(aFiles[nFor,10]) ], nil     , nil      ,nil       ,nil    ,nil  ,.t.    ,nil    ,.t.    ,nil   ,&("aHeader"+cAliasAux),&("aCols"+cAliasAux),.f.      ,cAliasAux ,nOpcEnc,PLSRetTit(cAliasAux) ,nil    ,nil    ,nil ,&("aVetTrab"+cAliasAux) ,cFunBok ,iIf(cAliasAux=='BD6', "VLDDEL('" + cTipoGuia + "')", "VLDDEL()") , nil   ,{||PL500GrFac() },nil     ,nil       ,nil          ,nil          ,.f.      ,.f.      ,aCmpLei ,.t.)

			else
			
				nPosPasta := nFor - 1
				
				if nPosPasta > len(aPosObj)
					nPosPasta := Val(aFiles[nFor,10])
				endIf
				
				nLinAux := 0
				if nPosPasta == 1
					
					if nOpc <> K_Incluir 
						nLinAux := -15
					else
						nLinAux := -30
					endIf
					
				endIf
					
				//new(                                nRow                         ,nCol                 ,nWidth               ,nHeigth                                        ,bLine ,oWnd                                    ,bChange  ,blDblClick,bRClick   ,oFont  ,cMsg ,lUpdate,bWhen  ,lDesign,bValid,aHeaderBrw            ,aColsBrw            ,lSemafaro,cAlias    ,nOpc   ,cTitulo             ,aExpSem ,cFunIni,bAdd,aVetTrab                ,cVldLine ,cVldDel                                                         ,bFilter ,bAfterEdit       ,aButEsp ,bMultaCols,bAftCancel   ,bBeforeDialog,lOrdColED,lConsFold,aFieldRO,lSx3User,aDifSize)
				&("oBrw"+cAliasAux) := TPLSBrw():new(aPosObj[nPosPasta,1] + nLinAux, aPosObj[nPosPasta,2], aPosObj[nPosPasta,4], aPosObj[nPosPasta][3] + iIf(nFor == 3, -45, 0), nil  ,oFolder:aDialogs[ val(aFiles[nFor,10]) ], nil     , nil      ,nil       ,nil    ,nil  ,.t.    ,nil    ,.t.    ,nil   ,&("aHeader"+cAliasAux),&("aCols"+cAliasAux),.f.      ,cAliasAux ,nOpcEnc,PLSRetTit(cAliasAux) ,nil    ,nil    ,nil ,&("aVetTrab"+cAliasAux) ,cFunBok ,iIf(cAliasAux=='BD6', "VLDDEL('" + cTipoGuia + "')", "VLDDEL()") , nil    ,{||PL500GrFac() },nil     ,nil       ,nil          ,nil          ,.f.      ,.f.      ,aCmpLei ,.t.)

			endIf
			
			if cAliasAux == 'BD6' .and. cTipoGuia == G_CONSULTA
				oBrwBD6:bBeforeAdd	:= {|| oBrwBD6:lAddLine := iIf( empty( oBrwBD6:fieldGet('BD6_SEQUEN') ) ,.t.,.f.) }
			endIf
			
		endIf
		
		if ! empty(allTrim(aFiles[nFor,15])) .and. existBlock(allTrim(aFiles[nFor,15]))
			execBlock(allTrim(aFiles[nFor,15]),.f.,.f.,{cAliasAux,cTipoGuia,nOpc})
		endIf
		
	endIf
	
next

if nOpc <> K_Incluir .and. type("oBrwBD6") == "O"

	@ 005,003 say STR0271 size 60,010 PIXEL of oFolder:aDialogs[2] //Consultar Item :
	@ 002,041 MSGET oConPro VAR cCodPro PICTURE "@!" size 055,008 PIXEL of oFolder:aDialogs[2]
	
	oConPro:bChange := {|| nPosBRW := 0 }
	
	@ 002,193 BTNBMP oBotao RESOURCE "PMSSETAUP" size 025,025 of oFolder:aDialogs[2] PIXEL MESSAGE STR0273 ACTION plsConPro(oBrwBD6,cCodPro,'A',@nPosBRW) //Anterior
	@ 002,218 BTNBMP oBotao RESOURCE "PMSSETADOWN" size 025,025 of oFolder:aDialogs[2] PIXEL MESSAGE STR0274 ACTION plsConPro(oBrwBD6,cCodPro,'P',@nPosBRW) //Próximo
	@ 005,120 say oSayRes PROMPT STR0272 size 60,010 of oFolder:aDialogs[2] PIXEL COLOR CLR_HRED FONT oFontAutor //Não encontrado
	
	oSayRes:Hide()
	
endIf

cChaveBX6 := (cAlias)->&( '(' + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG + " + cAlias + "_NUMERO + " + cAlias + "_ORIMOV ) " )
store Header "BX6" to aHeaderBX6 for .t.

BX6->(dbSetOrder(1))

if nOpc <> K_Incluir .and. BX6->(msSeek(xFilial("BX6")+cChaveBX6))
	store COLS "BX6" to aColsBX6 FROM aHeaderBX6 VETTRAB aVetTraBX6 while xFilial("BX6")+cChaveBX6 == BX6->(BX6_FILIAL + BX6_CODOPE + BX6_CODLDP + BX6_CODPEG + BX6_NUMERO + BX6_ORIMOV)
else
	aVetTraBX6 := {}
	aColsBX6   := {}
endIf
	
//Executa funcao de inicializacao de dados
if ! empty(cFunINI)
	
	aPar := {cTipoGuia,cGuiRel,"1",nOpc,oFolder:aDialogs[1]}
	
	if cTipINI == "1"
		cMacro := allTrim(cFunINI)
		&(cMacro)(aPar,,,)
	else
		execBlock(cFunINI,.f.,.f.,aPar)
	endIf
	
endIf

aadd(aButtons,{"GROUP",bBotaoVFam,STR0014+" - <F5>",STR0015}) //"Visualizar dados da familia"###"Familia"
aadd(aButtons,{"S4WB007N",{ || PLSA500UOI(cAlias) },STR0016+" - <F6>",STR0244}) //"Usuarios de Outros Intercâmbios" //"Interc."
aadd(aButtons,{"RELATORIO",{ || PLSA500LMV(&("M->"+cAlias+"_USUARI"))  },STR0017,STR0245}) //"Visualiza movimentacao do usuario" //"Movto."

if cTipoGuia <> "01"
	aadd(aButtons,{ "S4WB011N", { || GdSeek(&(cObjBrw+":oBrowse"),OemtoAnsi("Busca Grid"),&(cObjBrw+":aHeader"),&(cObjBrw+":aCols"),.f.), /*LGPD*/objCENFUNLGP:useLogUser('PLSBUSPROD') }, OemtoAnsi("Busca")} ) //"Busca Produto"
endIf

if findFunction('PLS500GLM') .and. nOpc <> K_Visualizar
	aadd(aButtons,{"SIMULACA",{|| PLS500GLM(nOpc,cObjBrw) },"Glosas Manuais","Glosas Manuais"})
endIf

if lUnimed .And. BCI->BCI_TIPGUI $ "03|02|01" 
	aadd(aButtons,{"MSGCOMINT",{|| MSGCOMINT(IIF(Inclui,{},),"2",nOpc,&("M->"+cAlias+"_USUARI"),IIF(Inclui,"", IIF(BCI->BCI_TIPGUI=="03","BE4","BD5")), IIF(BCI->BCI_TIPGUI=="03",BE4->(RecNo()),BD5->(RecNo())),@oGetBZC)},STR0341,STR0341})
endIf 

store Header "BYT" to aHeaderDF for .t.

BYT->( dbSetOrder(1) )
if nOpc <> K_Incluir
	
	if BYT->(msSeek(xFilial("BYT")+&(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO)")))
		store COLS "BYT" to aColsDF FROM aHeaderDF VETTRAB aVetTrabDF while BYT->(BYT_FILIAL+BYT_CODOPE+BYT_CODLDP+BYT_CODPEG+BYT_NUMERO) == xFilial("BD6")+&(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO)")
	else
		store COLS blank "BYT" to aColsDF FROM aHeaderDF
	endIf
else
	store COLS blank "BYT" to aColsDF FROM aHeaderDF
endIf
	
setKey(VK_F5,bBotaoVFam)
setKey(VK_F6,{|| PLSA500UOI(cAlias) })

//Trata a possibilidade de incluir botoes na enchoicebar
if ! empty(cFunBOT)
	
	if cTipBOT == "1"
		aBotAux := &(allTrim(cFunBOT) + "()")
	else
		aBotAux := execBlock(cFunBOT,.f.,.f.)
	endIf
	
	for nFor := 1 to len(aBotAux)
		aadd(aButtons,aBotAux[nFor])
	next
	
endIf

// Criação do ponto de entrada para inclusão de botoes na alteração de guias no proc contas
if  existBlock("P500INCBT")
	aButtons := aClone(execBlock("P500INCBT",.f.,.f.,{aButtons} ))
endIf

// Ponto de Entrada na montagem, na inclusão e na exclusão de registros do Browser da BD6, caso ele exista.
// Pode ser utilizado, por exmplo, para exibição de valores totais digitados na Guia.
if type("oBrwBD6") == "O"

	if existBlock("P500BTOG")

		execBlock("P500BTOG",.f.,.f.,{'1',@oDlg})

		bBrwAdd := oBrwBD6:bAfterAdd
		bBrwDel := oBrwBD6:oBrowse:oBrowse:bDelete

		oBrwBD6:bAfterAdd					:= {||iIf(ValType(bBrwAdd)=="B",Eval(bBrwAdd),),execBlock("P500BTOG",.f.,.f.,{'2',@oDlg})}
		oBrwBD6:oBrowse:oBrowse:bDelete		:= {||iIf(ValType(bBrwDel)=="B",Eval(bBrwDel),),execBlock("P500BTOG",.f.,.f.,{'3',@oDlg})}	 

	endIf

endIf

//para o cancelamento de todas as guias da PEG
if !lCancePeg
	&(cObjEnc + ":SetFocus()") 
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.f.,aButtons) })
else
	nOpcA := 1
endIf

//Se for cancelamento verifica se existe registro na auditoria
if nOpc == K_Cancel
	
	cTpGui := BCI->BCI_TIPGUI
	cChave := ""
	
	do case
	
		case cTpGui $ "01/02/04/06/10"
		
			B53->(dbSetOrder(3))//B53_FILIAL + B53_CODOPE + B53_CODLDP + B53_CODPEG + B53_NUMERO + B53_ORIMOV
			cChave := BD5->(BD5_FILIAL+BD5_OPEMOV+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)
			
		case cTpGui $ "03/05/11"
		
			B53->(dbSetOrder(3))//B53_FILIAL + B53_CODOPE + B53_CODLDP + B53_CODPEG + B53_NUMERO + B53_ORIMOV
			cChave := BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
			
		case cTpGui $ "07/08/09"
		
			B53->(dbSetOrder(1))//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
			cChave := B4A->(B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT+B4A_ORIMOV)
			
	endCase
	
	if !(empty(cChave)) .AND. B53->(msSeek(cChave))
		
		B53->(recLock("B53",.f.))
			B53->B53_STATUS := '6'
		B53->(msUnLock())
		
	endIf
	
	B53->(dbCloseArea())

	//cancela as guias de anexos vinculados a guia principal cancelada 

	If cTpGui $ "01/02/03"
	
		If cTpGui $ "01/02"
			cMacroGui := "xFilial('BD5') + BD5->(BD5_OPEMOV + BD5_ANOAUT + BD5_MESAUT + BD5_NUMAUT)"
		elseIf cTpGui == "03"
			cMacroGui := "xFilial('BE4') + BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)"
		endIf
		
		B4A->(dbSetOrder(4))
		B53->(dbSetOrder(1))
		
	 	if B4A->(MsSeek(&(cMacroGui)))
	 		
	 		begin Transaction
	 		
		 		while !B4A->(EOF()) .AND. (xFilial("B4A") + B4A->B4A_GUIREF) == &(cMacroGui)
		 			
		 			B4A->(Reclock("B4A",.F.))
					B4A->B4A_CANCEL := '1'
					B4A->B4A_STATUS := '3'
					B4A->B4A_STTISS := '6'  //Cancelada
					B4A->(MsUnlock())
		 			
		 			//Cancela na auditoria caso o anexo esteja em análise
		 			If B53->(MsSeek(xFilial("B4A") + B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)))
		 				B53->(Reclock("B53",.F.)) 
						B53->B53_STATUS := '6'
						B53->(MsUnlock())
		 			endIf
		 			
		 		B4A->(dbSkip())
		 		endDo
		 		
	 		end Transaction
	 		
	 	endIf
	 	
	endIf
	
endIf

//Tratamento para atualizacoes
if nOpcA == K_OK
	
	//Trata a exclusao não podendo haver modificacoes
	if nOpc <> K_Visualizar
		
		//Controle para evitar duplicacao de registros
		if nOpc == K_Incluir
		
			cSemGuia := cCodOpe + cCodLdp + cCodPeg
			nH       := PLSAbreSem(cSemGuia+".SMF")
			
			DbSelectArea(cAlias)
			cFilAli  := RetFiltro(cAlias,"BCI")
			dbClearFilter()
			
			cNumGuia := PLSA500NUM(cAlias, cCodOpe, cCodLDP, cCodPEG)
			
			DbSelectArea(cAlias)
			dbSetFilter({||&cFilAli},cFilAli)
			
		endIf
		
		cMatrUsr	:= M->&(cAlias + "_USUARI")
		cCC        	:= PLSUSRCC(cMatrUsr)
		
		//Inicia a transacao
		begin transaction
		
			If lUnimed .And. cAlias $ "BD5|BE4" 
      			
		   	 	 cChvBzc := xFilial(cAlias) + cCodOpe + cCodLDP + cCodPEG + cNumGuia
				 BZC->(DbSetOrder(1))
				
		         if valType(oGetBZC) == "O" 
		 			
		 			if len(oGetBZC:aCols[1][2]) > 0
		 			 
				        aadd(aChBZC,{"BZC_FILIAL",xFilial("BZC")})	
						aadd(aChBZC,{"BZC_CHVGUI",cChvBzc})	
						aadd(aChBZC,{"BZC_ALIAS ",cAlias})	
              	
						oGetBZC:Grava(aChBZC,.t.)
						
					endIf
					 																
				 endIf
				 
			endIf
			
			//Monta os Objetivos
			for nFor := 1 to len(aFilesGRV)
				
				cAliasAux := aFilesGRV[nFor,1]
				
				//Se for um botao eu nao gravo ele neste ponto
				if (len(aFilesGRV) >= 16 .and. aFilesGRV[nFor][16] == '1') .Or. (len(aFiles[nFor]) > 17 .and. aFiles[nFor][18] == "01" .and. aFiles[nFor,1] == "B43" .and. FunName() $ "PLSA498;PLSA600")
					loop
				endIf
				
				//Segue processo normal
				if aFilesGRV[nFor,3] == "2" .and. aFilesGRV[nFor,6] == "0"
					
					//Monta RegToMemory
					if nOpc == K_Incluir .Or. nOpc == K_Alterar
						
						M->&(cAliasAux + "_CODOPE") := cCodOPE
						M->&(cAliasAux + "_CODLDP") := cCodLDP
						M->&(cAliasAux + "_CODPEG") := cCodPEG
						M->&(cAliasAux + "_NUMERO") := cNumGuia
						M->&(cAliasAux + "_TIPGUI") := cTipoGuia
						M->&(cAliasAux + "_ORIMOV") := cCdOrIt
						M->&(cAliasAux + "_CC")     := cCC
						
						If nOpc == K_Alterar // Garantindo o reposcionamento
							(cAlias)->(restArea(aAreaCabec))
						Endif
						

						//grava
						lCabAltered := PLUPTENC(cAliasAux,nOpc,,,@aCmpAlt)
						
					endIf
					
				else
					
					if nOpc == K_Incluir .or. nOpc == K_Alterar
					
						if len(&("oBrw"+cAliasAux):aCols) > 0 .and. empty( &("oBrw"+cAliasAux):fieldGet(cAliasAux+'_SEQUEN') )
							loop
						endIf
						
						aChave := {}
						aadd(aChave,{cAliasAux+"_CODOPE",cCodOPE})
						aadd(aChave,{cAliasAux+"_CODLDP",cCodLDP})
						aadd(aChave,{cAliasAux+"_CODPEG",cCodPEG})
						aadd(aChave,{cAliasAux+"_NUMERO",cNumGuia})
						aadd(aChave,{cAliasAux+"_TIPGUI",cTipoGuia})
						aadd(aChave,{cAliasAux+"_ORIMOV",cCdOrIt})
						aadd(aChave,{cAliasAux+"_TPGRV","1"})
						aadd(aChave,{cAliasAux+"_CC",cCC})
						
                        //nao retirar este metodo daqui, ele serve para tirar o filtro do objeto, caso ele esteja filtrado
						&("oBrw"+cAliasAux):retaCols()
						&("oBrw"+cAliasAux):grava(aChave,.f.)
						
						//aRecAlt controle as linhas que foram alteradas
						&("oBrw"+cAliasAux):retRAlt(aRecAlt,lCabAltered)
						
						//Importante qualquer mudanca neste processo deve ser alterado
						//no PLSA720GRV (FUNGRV) como pontos de entrada e campos default
						
						//Se existente, grava campos da tabela BX6 (complemento do evento)
						if cAliasAux == "BD6"
						
							nPosSeqBX6 := ascan(aHeaderBX6,{|x|x[2] == "BX6_SEQUEN"})
							nBX6CodPad := ascan(aHeaderBX6,{|x|x[2] == "BX6_CODPAD"})
							nBX6CodPro := ascan(aHeaderBX6,{|x|x[2] == "BX6_CODPRO"})
							
							nPosSeqBD6 := ascan(oBrwBD6:aHeader,{|x|x[2] == "BD6_SEQUEN"})
							nBD6CodPad := ascan(oBrwBD6:aHeader,{|x|x[2] == "BD6_CODPAD"})
							nBD6CodPro := ascan(oBrwBD6:aHeader,{|x|x[2] == "BD6_CODPRO"})
							
							//Este for e necessario para ajustar o codigo do evento caso o usuario
							//altere o mesmo depois de incluir o complemento na BX6
							for nForCpo := 1 to len(aColsBX6)
							
								if (nPosBD6 := ascan(oBrwBD6:aCols,{|x|x[nPosSeqBD6] == aColsBX6[nForCpo][nPosSeqBX6]}) ) > 0 .AND. nForCpo <= Len(oBrwBD6:aCols)
							
									aColsBX6[nForCpo][nBX6CodPad] := oBrwBD6:aCols[nForCpo][nBD6CodPad]
									aColsBX6[nForCpo][nBX6CodPro] := oBrwBD6:aCols[nForCpo][nBD6CodPro]
							
								endIf
								
							next
							
							if len(aColsBX6) > 0
							
								aChave := {}
								aadd(aChave,{"BX6_CODOPE",cCodOPE})
								aadd(aChave,{"BX6_CODLDP",cCodLDP})
								aadd(aChave,{"BX6_CODPEG",cCodPEG})
								aadd(aChave,{"BX6_NUMERO",cNumGuia})
								aadd(aChave,{"BX6_ORIMOV",cCdOrIt})
								
								PLUPTCOLS("BX6",aColsBX6,aHeaderBX6,aVetTraBX6,nOpc,aChave,nil)
								
							endIf
							
						endIf
						
					endIf
					
				endIf
				
			next
			
			aArea 	 := (cAlias)->(getArea())
			aAreaBD6 := BD6->(getArea())
			
			//Executa funcao de gravacao dos dados
			if ! empty(cFunGRV)
				
				aPar := { 	nOpc,; 		//01
							cCodOpe,;	//02
							cCodLDP,; 	//03
							cCodPEG,; 	//04
							cNumGuia,; 	//05
							.f.,; 		//06
							cAlias,; 	//07
							cTipoGuia,;	//08
							cGuiRel,;	//09
						  	cCdOrIt,; 	//10
						  	{},; 		//11
						  	{},; 		//12
						  	aColsDF,; 	//13
						  	aHeaderDF,;	//14
						  	{},; 		//15
						  	{},; 		//16
						  	BD6->BD6_MOTBPG,; 		//17
						  	BD6->BD6_DESBPG,; 		//18
						  	BD6->BD6_MOTBPG,; 		//19
						  	{},; 		//20	
						  	{},; 		//21
						  	'',; 		//22
						  	aRecAlt }	//23
				
				if cTipGRV == "1"
					cMacro := allTrim(cFunGRV)
					&(cMacro)(aPar,,,)
				else
					execBlock(cFunGRV,.f.,.f.,aPar)
				endIf
				
			endIf
			
			(cAlias)->(restArea(aArea))
			BD6->(restArea(aAreaBD6))
			(cAlias)->(restArea(aAreaCabec))

			if nOpc == K_Incluir .AND. PLSALIASEX("B6B")
				PLAgruCri(BD6->BD6_CODRDA, BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO)
			endIf
		end transaction
		
		if existBlock("PLS500GR")
			execBlock("PLS500GR",.f.,.f.,{cTipoGuia,nOpc})
		endIf
		
	endIf

	//Controle para evitar duplicacao de registros
	if nOpc == K_Incluir
		PLSFechaSem(nH,cSemGuia+".SMF")
	endIf
	
else
	
	//Gravacao de glosa manual
	B11->( dbSetOrder(1) )//B11_FILIAL + B11_CODOPE + B11_CODLDP + B11_CODPEG + B11_NUMERO + B11_ORIMOV + B11_SEQUEN + B11_CODGLO + B11_CODTPA
	if B11->( msSeek(xFilial("B11")+cCodOPE+cCodLDP+cCodPEG+Space(TamSX3("B11_NUMERO")[1]) ) )
		
		while !B11->(eof()) .and. B11->(B11_FILIAL+B11_CODOPE+B11_CODLDP+B11_CODPEG+B11_NUMERO) == xFilial("B11")+cCodOPE+cCodLDP+cCodPEG+Space(TamSX3("B11_NUMERO")[1])
			B11->(recLock("B11",.f.))
			B11->(DbDelete())
			B11->(msUnLock())
			B11->(dbSkip())
		endDo
		
	endIf
	
endIf

SET KEY VK_F8 to
SET KEY VK_F9 to
SET KEY VK_F10 to
SET KEY VK_F11 to

//chama mudanca de fase por item.
if isPLSA502 .and. nOpcA == K_OK .and. nOpc <> K_Visualizar
	PLSA500FAS(cAlias,nReg,nOpc,aNil,.t.,.f.,.f.,.t.)
endIf	

if nOpcA == K_OK .and. lNewBCM .and. nOpc == K_Alterar .and. cFase $ '2,3'
	if (oBrwBD6:lAltered .or. oBrwBD7:lAltered) .or. (lCabAltered .and. len(aCmpAlt) >= 1 .and. isAltRep(aCmpAlt))
		msginfo("Foi identificada uma alteração que pode impactar na valoração desta guia e a mesma foi adicionada novamente a fila de processamento!")
		PLSA500PRC(.f.)
	endif
endif

return(nOpca)

/*/{Protheus.doc} plMontACols
Monta o aCols browse
@type function
@author plsteam
@since  05.03.2008
@version 1.0
/*/
static function plMontACols(cAlias, nIdx, aHeader, aCols, aVetTrab, cChavePes, cKey, cValid )
local aColsAux 	:= {}
local nI		:= 0
local nTam		:= 0
local nTamHeader:= len(aHeader[1])
local lValid 	:= .F.
local nTPA		:= 0
local lPLS500VI := existBlock("PLS500VI")
default cValid := ".t."

dbSelectArea(cAlias)

(cAlias)->(dbSetOrder(nIdx))

if (cAlias)->(msSeek(cChavePes))
	
	store COLS blank cAlias to aColsAux FROM aHeader
	
	while ! (cAlias)->(eof()) .and. cChavePes == &cKey
		
		if &cValid
			lValid := .T.
			aadd(aCols,aClone(aColsAux[1]))
			
			nTam++
			
			for nI := 1 to len(aHeader)
			
				cField := allTrim(aHeader[nI,2])
				
				if aHeader[nI,nTamHeader] <> 'V'
					aCols[nTam,nI] := &cField
				elseIf cAlias == "BD7" .AND. cField == "BD7_DESTPA" //Pra carregar o campo virtual corretamente na alteração/visualização
					If !(empty(nTPA := aScan(aHeader, {|x| x[2] == "BD7_CODTPA"})))
						aCols[nTam,nI] := BWT->(Posicione("BWT",1,xFilial("BWT")+ PlsIntPad() + aCols[nTam][nTPA] ,"BWT_DESCRI"))
					elseIf cAlias == "BD6" .AND. lPLS500VI //Pra carregar o campo virtual corretamente na alteração/visualização
						aCols[nTam,nI]:= execBlock("PLS500VI",.f.,.f.,{aHeader,aCols,cField,nTam}) //retorno conteudo
					endIf
				endIf	
				
			next
			
			aadd(aVetTrab,(cAlias)->(recno()) )
			
		endIf	
		
	(cAlias)->(dbSkip())
	endDo
	if !lValid
		store COLS blank cAlias to aColsAux FROM aHeader
		aadd(aCols,aClone(aColsAux[1]))
	EndIf
else
	store COLS blank cAlias to aColsAux FROM aHeader
	aadd(aCols,aClone(aColsAux[1]))
endIf	

return

/*/{Protheus.doc} plsConPro
Consulta procedimentos na browse itens
@type function
@author plsteam
@since  05.03.2008
@version 1.0
/*/
static function plsConPro(oObj,cCodPro,cTipo,nPosBRW)
local nPos		:= 0
local nPosAux   := 0
default cTipo	:= 'P' //P-Proximo,A-Anterior
default nPosBRW	:= 0

//Esconde o result

oSayRes:Hide()

//Verifica se vai para o proximo ou anterior

if Upper(cTipo) == 'P'
	nPosAux := ascan(oObj:aCols,{|x| allTrim( x[plRetPos("BD6_CODPRO",oObj:aHeader)] ) == allTrim(cCodPro) },nPosBRW+1 )
	if nPosAux > 0
		nPosBRW := nPosAux
	endIf
else
	while ( nPos := ascan(oObj:aCols,{|x| allTrim( x[plRetPos("BD6_CODPRO",oObj:aHeader)] ) == allTrim(cCodPro) },nPos+1 ) ) > 0 .and. nPos<=(nPosBRW-1)
		nPosAux := nPos
	endDo
	nPosBRW := nPosAux
endIf

//Posiciona no item

if nPosBRW > 0
	oObj:Refresh()
	oObj:setPos(nPosBRW)
	eval(oObj:bChange)
else
	oSayRes:Show()
endIf

return( nPosBRW )

/*/{Protheus.doc} PLSA500BOK
Valida a digitacao de todos os campos
@type function
@author plsteam
@since   07.09.2002
@version 1.0
/*/
Function PLSA500BOK(aFiles,cCodRDA,cCid,nOpc,cCodOpe,cCodLDP,cCodPEG,cFunSai,cTipSai,cTipoGuia,cGuiRel,oGetBZC)
local aAreaBE4	 := {}
local nFor		 := 0
local nL         := 1
local lRet       := .t.
local lUnimeds   := lUnimed
local cMacro	 := ""
local aPar		 := {}
local aColAux 	 := {}
local aColRea 	 := {}
local cAlias	 := ""
local cGuiInt 	 := ""
local cTipFat	 := ""
local oPai		 := nil
local nfieldPos  := 0
local nFieldBD7  := 0
local nlinha     := 0
local nI 		 := 1
local dDatPro 	 := ctod("")
local cHorPro 	 := ""
local dVigAte 	 := ctod("")
local cHorAte 	 := ""
local lTrtDtAl   := .f.
local nFieldDat  := 0
local nFieldHor	 := 0
local nFieldPro  := 0
local nFieldSeq	 := 0
local dVigDe 	 := ctod("")
local cHorDe 	 := ""
local aColsCab	 := {}
Local aColsPE	 := {{},{},{},{}}
Local aHeadPE	 := {{},{},{},{}}
Local nBrw		 := 0
Local nAliFile	:= 0
default oGetBZC  := nil

//Ponto de entrada apos clicar no botao ok

if existBlock("PLS500OK")

	for nBrw := 1 to len(aFiles)

		if TYPE("oBrw"+aFiles[nBrw,1]) == "O"

			if aFiles[nBrw,1] == "BD5"
			
				aColsPE[1]:= oBrwBD5:aCols
				aHeadPE[1]:= oBrwBD5:aHeader
				
			elseIf aFiles[nBrw,1] == "BD6"
			
				aColsPE[2]:= oBrwBD6:aCols
				aHeadPE[2]:= oBrwBD6:aHeader
				
			elseIf aFiles[nBrw,1] == "BD7"
			
				aColsPE[3]:= oBrwBD7:aCols
				aHeadPE[3]:= oBrwBD7:aHeader
				
			elseIf aFiles[nBrw,1] == "BE4"
			
				aColsPE[4]:= oBrwBE4:aCols
				aHeadPE[4]:= oBrwBE4:aHeader
				
			endIf
			
		endIf
		
	next nBrw
	
	if ! execBlock("PLS500OK",.f.,.f.,{cTipoGuia,nOpc,aHeadPE,aColsPE})
		return(.f.)
	endIf
	
endIf

//Trata cid obrigatorio de acordo com parametrizacao

if ! PLSVLDCID(cCodRDA,cCid)
	return(.f.)
endIf

if len(aFiles[1]) > 1

	cAlias := aFiles[1][1]
	
	if  type("M->"+cAlias+"_DATPRO") <> 'U' .and. type("M->"+cAlias+"_HORPRO") <> 'U' .and. type("M->"+cAlias+"_DTALTA") <> 'U' .and. type("M->"+cAlias+"_HRALTA") <> 'U'
		
		dVigDe   := &("M->"+cAlias+"_DATPRO")
		cHorDe   := &("M->"+cAlias+"_HORPRO")
		dVigAte  := &("M->"+cAlias+"_DTALTA")
		cHorAte  := &("M->"+cAlias+"_HRALTA")
		
		if ! empty(dVigDe) .and. ! empty(dVigAte)
			lTrtDtAl := .t.
		endIf
		
		//verifica se ja foi informado anteriormente resumo total
		if cAlias == 'BE4' .and. cTipoGuia == '05'
		
			cGuiInt := &("M->" + cAlias + "_GUIINT")
			cTipFat	:= &("M->" + cAlias + "_TIPFAT")
			
			if cTipFat == 'T' .and. ! empty(cGuiInt)
				
				aAreaBE4 := BE4->(getArea())
				
				BE4->(dbSetOrder(1))
				if BE4->( msSeek( xFilial("BE4") + cGuiInt ) ) .and. BE4->BE4_TIPFAT == 'T'
				
					aviso('Atenção','A Solicitação de Internação já se encontra com faturamento total [' + cGuiInt + ']',{"OK"})
	
					BE4->(restArea(aAreaBE4))
	
					return(.f.) 
				endIf
				
				BE4->(restArea(aAreaBE4))
				
			endIf
			
		endIf
				
	endIf
	
endIf

//Testa campos obrigatorios
if lRet .and. ( nOpc == K_Incluir .Or. nOpc == K_Alterar )

	for nFor := 1 to len(aFiles)
		
		//Se for um botao de um item, eu nao faco a checagem neste ponto
		if (len(aFiles[nFor]) >= 16 .and. aFiles[nFor][16] == '1') .Or. (len(aFiles[nFor]) > 17 .and. aFiles[nFor][18] == "01" .and. aFiles[nFor,1] == "B43" .and. FunName() $ "PLSA498;PLSA600")
			loop
		endIf
		
		if aFiles[nFor,3] == "2" .and. aFiles[nFor,8] == "1"
		
			lRet := Obrigatorio(&("oEnc"+aFiles[nFor,1]):aGets,&("oEnc"+aFiles[nFor,1]):aTela)
			
			if ! lRet
				exit
			endIf
			
		elseIf aFiles[nFor,8] == "1"
			
			nL 	:= 1
			oPai:= &("oBrw"+aFiles[nFor,1]):oPai
			
			if valtype(oPai) <> 'U' .and. nFor <> 1
			
				//se o aCols esta filtrado
				if len(&("oBrw"+aFiles[nFor,1]):aColsNofil) > 0
			
					aColRea := aClone(&("oBrw"+aFiles[nFor,1]):aColsNoFil)
					aColAux := aClone(&("oBrw"+aFiles[nFor,1]):aCols)
			
					//se faz necessario pois em algumas situacoes quando se deleta o acols que esta filtrado o acolnofil nao eh deletado
					for nI := 1 to len(&("oBrw"+aFiles[nFor,1]):aItColDel)
						aDel(aColRea,&("oBrw"+aFiles[nFor,1]):aItColDel[nI]-nI+1)
					next
			
					aSize(aColRea,len(aColRea)-len(&("oBrw"+aFiles[nFor,1]):aItColDel))
			
					for nI := 1 to len(aColAux)
						aadd(aColRea,aClone(aColAux[nI]))
					next
			
				else
					aColRea := aClone(&("oBrw"+aFiles[nFor,1]):aCols)
				endIf
			
				while lRet .and. nL <= len(aColRea)
			
					//se o registro nao esta deletado
					if !aColRea[nL][len(aColRea[nL])]
			
						//bd7 vai sempre entrar aqui
						nfieldPos  := GdfieldPos(aFiles[nFor-1,1]+"_SEQUEN",oPai:aHeader)
						nFieldBD7  := GdfieldPos(aFiles[nFor,1]+"_SEQUEN",&("oBrw"+aFiles[nFor,1]):aHeader)
			
						if nfieldPos > 0 .and. nFieldBD7 > 0
			
							nlinha := ascan( oPai:aCols,{|x| x[nfieldPos] == aColRea[nL][nFieldBD7] })
			
							if nlinha > 0 .and. !oPai:IsDeleted(nlinha)
								lRet :=  &("oBrw"+aFiles[nFor,1]):linhaOK(.t.,nL,aColRea)
							endIf
			
						else
							lRet := &("oBrw"+aFiles[nFor,1]):linhaOK(.t.,nL,aColRea)
						endIf
			
					endIf
			
					nL++
				endDo
				
			else
				
				//o bd6 sempre entra aqui
				lRet     := &("oBrw"+aFiles[nFor,1]):tudoOK(.t.)
				aColsCab := &("oBrw"+aFiles[nFor,1]):aCols
				
				if lRet .and. lTrtDtAl
				
					nFieldDat  := GdfieldPos(aFiles[nFor,1]+"_DATPRO",&("oBrw"+aFiles[nFor,1]):aHeader)
					nFieldHor  := GdfieldPos(aFiles[nFor,1]+"_HORPRO",&("oBrw"+aFiles[nFor,1]):aHeader)
					nFieldPro  := GdfieldPos(aFiles[nFor,1]+"_CODPRO",&("oBrw"+aFiles[nFor,1]):aHeader)
					nFieldSeq  := GdfieldPos(aFiles[nFor,1]+"_SEQUEN",&("oBrw"+aFiles[nFor,1]):aHeader)
					cProcedim  := CHR(13)+CHR(10)
					
					if nFieldDat > 0 .and. nFieldHor > 0
					
						for nL := 1 to len(aColsCab)
							//se a linha nao esta deletada
							if !(aColsCab[nL][len(aColsCab[nL])])
							  
								dDatPro := aColsCab[nL][nFieldDat]
								cHorPro := aColsCab[nL][nFieldHor]
								
								if  !empty(dDatPro) .and. !empty(cHorPro) .and. !(((dtos(dDatPro) + cHorPro) >= (dtos(dVigDe) + cHorDe)) .or. ((dtos(dDatPro) + cHorPro) <= (dtos(dVigAte) + cHorAte)))
									
									cProcedim  += "["+aColsCab[nL][nFieldSeq]+"] "+aColsCab[nL][nFieldPro]+CHR(13)+CHR(10)
									lRet := .f.
									
								elseIf  !empty(dDatPro) .and. !(((dtos(dDatPro) ) >= (dtos(dVigDe))) .and. ((dtos(dDatPro) ) <= (dtos(dVigAte))))
									
									cProcedim  += "["+aColsCab[nL][nFieldSeq]+"] "+aColsCab[nL][nFieldPro]+CHR(13)+CHR(10)
									lRet := .f.
								endIf
								
							endIf
							
						next
						
						if !lRet
							Aviso(STR0275,STR0276+cProcedim,{"OK"})
						endIf
						
					endIf
					
				endIf
				
				//Delete b11
				
				if len(aColsCab) > 0 .and. aFiles[nFor,1] == 'BD6'
					
					for nL := 1 to len(aColsCab)
					
						if (aColsCab[nL][len(aColsCab[nL])])  //Se a linha estiver deletada
					
							nFieldSeq := GdfieldPos(aFiles[nFor,1]+"_SEQUEN",&("oBrw"+aFiles[nFor,1]):aHeader)
					
							if (nFieldSeq > 0 .and. nFieldSeq <= len(aColsCab[nL]))
								PlsDelB11( aColsCab[nL,nFieldSeq] )
							endIf
							
						endIf
						
					next
					
				endIf
				
			endIf
			
			if ! lRet
				exit
			endIf
			
		endIf
		
	next
	
	/*Caso guia de honorário, devo validar se o campo GUIINT está preenchido. Pela ANS, guia de honorário é vinculada apenas a Internação, logo, é obrigatório informar o número
	da guia de Solicitação de Internação no campo BD5_GUIINT, não devendo ser vazio.*/	
	if ( (BCL->BCL_TIPGUI == G_RES_INTER .and. Empty(M->BE4_GUIINT)) .or. (cTipoGuia == G_HONORARIO .and. empty(M->BD5_GUIINT)) )
		Aviso(STR0342,; //"Número de Internação"
			  STR0343,; //"Informe o número da Solicitação de Internação."
			  {"OK"})
		lRet := .f.
	endif

	if BCL->BCL_TIPGUI == G_RES_INTER .and. empty(M->BE4_TIPFAT)
		Aviso("Tipo de Faturamento",; 
			  "Informe o tipo de faturamento.",; 
			  {"OK"})
		lRet := .f.
	endif
	
endIf

//Validacao de majoracao
if nOpc == K_Incluir .and. getNewPar("MV_PLSMAJ",.f.) .and. &(cAlias)->(fieldPos(cAlias+"_TIPMAJ")) > 0

	DbSelectArea("BAU")
	if (Posicione("BAU",1,xFilial("BAU")+&("M->"+cAlias+"_CODRDA"),"BAU->BAU_TIPPRE") == getNewPar("MV_PLSTPIN","OPE")) .and. empty(&("M->"+cAlias+"_TIPMAJ"))
		Help( ,, 'HELP',,"Para RDA de convenio de reciprocidade o Tipo de Majoração é obrigatório!!", 1, 0)
		return(.f.)
	endIf
	
endIf

if ! lRet
	return(.f.)
endIf

//Verifica se a guia podera ser atualizada na base de dados
if ! PLSA500ANA(nOpc,cCodOpe,cCodLDP,cCodPEG)
	return(.f.)
endIf

//Preenchimento do indicacao clinica
if lUnimeds .and. len(aFiles[1]) > 1

	cAlias := aFiles[1,1]

	if type("M->"+cAlias+"_INDCLI") <> 'U' .and. type("M->"+cAlias+"_INDCL2") <> 'U' .and. type("M->"+cAlias+"_TIPATE") <> 'U'

		if empty( &("M->"+cAlias+"_INDCLI")+&("M->"+cAlias+"_INDCL2") ) .and. ( &("M->"+cAlias+"_TIPATE") $ "02,03,08,09,10" )
			Help("",1,"PLSA500IND")
			return(.f.)
		endIf
		
	endIf
	
endIf

if cAlias == "BD5"
	PLSVLEBSBD5()
endIf

If cAlias == "BE4"
	nAliFile := aScan(aFiles, {|x|, x[1] == "BE4"})
	If aScan(aFiles[nAliFile][4], "BE4_NRDCOB") > 0
		If Alltrim(M->BE4_TIPALT) == "41" .AND. EmpTy(M->BE4_NRDCOB)
			Msgalert("Para o motivo de saída 41 - [ " + AllTrim(Posicione("BIY", 1, xfilial("BIY") + PLSINTPAD() + Alltrim(M->BE4_TIPALT), "BIY_DESCRI")) + " ] é obrigatório o preenchimento do número da declaração de óbito", "Atenção!")
			lRet := .F.
			Return lret
		EndIf		
	EndIf
EndIf

//Executa funcao de inicializacao de dados
if ! empty(cFunSAI)

	aPar := {cTipoGuia,cGuiRel,aFiles,nOpc}

	if cTipSAI == "1"
		cMacro := allTrim(cFunSAI)
		lRet := &(cMacro)(aPar,,,)
	else
		lRet := execBlock(cFunSAI,.f.,.f.,aPar)
	endIf
	
endIf

return(lRet)

/*/{Protheus.doc} PLSA500NUM
Busca o numero da proxima movimentacao contas medicas
@type function
@author plsteam
@since  08.01.02
@version 1.0
/*/
function PLSA500NUM(cAlias,cCodOpe,cCodLDP,cCodPEG)
LOCAL nH		:= 0
LOCAL nOrd		:= 0
LOCAL nRec		:= 0
LOCAL __cIndex	:= ''
LOCAL cChave    := ''     	          
LOCAL cChvMvt  	:= xFilial(cAlias) + cCodOpe + cCodLDP + cCodPEG
LOCAL cDataBase	:= allTrim(TCGetDB())
LOCAL nRet    	:= 0   
LOCAL aRetPr	:= {"",.F.}
LOCAL nTam    	:= eval({ || DbSelectArea(cAlias), Len(&(cAlias+"_NUMERO"))})

//P.E. para controlar o numero da proxima movimentacao do contas medicas   
if existBlock("PLS500NM")
   nRet := execBlock("PLS500NM",.F.,.F.,{cAlias,cCodOpe,cCodLDP,cCodPEG})
   return(nRet)
endIf

//Parametro que ativa o controle do numero da proxima movimentacao do contas medicas via procedure   
if getNewPar("MV_PLPRB0Y","0") == "1"

	aRetPr := PLSPRNB0Y(cAlias, cCodOpe, cCodLDP, cCodPEG)

	if aRetPr[2]
		return(aRetPr[1])
	endIf
	
endIf

//Busca o proximo codigo...                                                
if getNewPar("MV_PLSNNUM","1") == "1"

	nRet := PLSB0YNUM( cAlias + "_NUMERO", cCodOpe + cCodLDP + cCodPEG, cAlias, cCodOpe, cCodLDP, cCodPEG )

else

	//Abre semaforo															 
	nH := PLSAbreSem("PLSA500N.SMF")

	If cDataBase <> "ORACLE"
	
	   nOrd := eval( { || (cAlias)->(IndexOrd()) } )
	   nRec := eval( { || (cAlias)->(recno()) } )
	
	   (cAlias)->( dbSetOrder(1) )
	   (cAlias)->( msSeek( cChvMvt + replicate("9",nTam),.t.) )
	   
	   (cAlias)->( dbSkip(-1) )
	                                                           
	   __cIndex := Eval( { ||(cAlias)->(IndexKey()) } )
	   cChave   := (cAlias)->&(__cIndex)
	   
	   if Subs(cChave,1,len(cChvMvt)) <> cChvMvt
	      nRet := strZero(1,nTam)
	   else
	      nRet := strZero( val( (cAlias)->&(cAlias + "_NUMERO") ) + 1, nTam )
	   endIf
	      
	   (cAlias)->(dbSetOrder(nOrd))
	   (cAlias)->(dbGoTo(nRec))
	   
	else
	
	   cSQL := "SELECT MAX( " + cAlias + "_NUMERO ) NUM FROM " + retSQLName(cAlias) + " WHERE "
	   cSQL += cAlias + "_FILIAL = '" + xFilial(cAlias) + "' AND "
	   cSQL += cAlias + "_CODOPE = '" + cCodOpe + "' AND "
	   cSQL += cAlias + "_CODLDP = '" + cCodLDP + "' AND "
	   cSQL += cAlias + "_CODPEG = '" + cCodPEG + "' AND "
	   cSQL += "D_E_L_E_T_ = ' ' "        
	   
	   dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"Trb500Num",.f.,.t.)         
	   
	   nRet := strZero( val(Trb500Num->NUM) + 1, nTam)
	   
	   Trb500Num->(dbCloseArea())
	   
	endIf                         
	 
	PLSFechaSem(nH,"PLSA500N.SMF")
	
endIf

return(nRet)

/*/{Protheus.doc} PLSA500VLD
Validacao generica dos campos..
@type function
@author plsteam
@since  08.01.02
@version 1.0
/*/
function PLSA500VLD()
local cCampo    := Subs(Readvar(),4,10)
local lRet      := .t.
local cTipoGuia := BCL->BCL_TIPGUI

//Executa execBlock para validacoes genericas

if existBlock("PLS500VL")
	lRet := execBlock("PLS500VL",.f.,.f.,{cCampo,cTipoGuia})
endIf
	
return(lRet)

/*/{Protheus.doc} PLSA500ANA
Analisa se PEG se encontra disponivel para digitacao
@type function
@author plsteam
@since  08.01.02
@version 1.0
/*/
function PLSA500ANA(nOpc,cCodOpe,cCodLDP,cCodPEG)
local lAtuBCI := .f.
local lRet    := .f.

if cCodOpe+cCodLDP+cCodPEG <> BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)
	
	BCI->(dbSetOrder(1))
	if BCI->(msSeek(xFilial("BCI")+cCodOpe+cCodLDP+cCodPEG))
		lAtuBCI := .t.
	endIf
	
else
	lAtuBCI := .t.
endIf

if lAtuBCI
	if BCI->BCI_SITUAC $ "2,3"
		Help("",1,"PLSA500PND")
	else
		lRet := .t.
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSA500ANA
Bloqueio e desbloqueia de uma guia
@type function
@author plsteam
@since  15.08.2002
@version 1.0
/*/
function PLSA500STA(cFase,cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov,aFiles,cFunGRV,nOpc,cTipGRV,cAliasBCL,cMotBlo)
local lRet       := .t.

default cMotBlo := ""

begin transaction
	
	if ! empty(cFunGRV) .and. lRet
		
		if cTipGRV == "1"
		
			aPar   := {	nOpc,;				//1
						cCodOpe,;        	//2
						cCodLDP,;        	//3
						cCodPEG,;        	//4
						cNumero,;        	//5
						.f.,;            	//6
						cAliasBCL,;      	//7
						BCL->BCL_TIPGUI,;	//8
						BCL->BCL_GUIREL,;	//9
						cOriMov,;        	//10
						{},;        		//11
						{},;        		//12
						{},;        		//13
						{},;       			//14
						{},;        		//15
						{},;        		//16
						'',;        		//17
						'',;        		//18
						cMotBlo }       	//19
			
			cMacro := allTrim(cFunGRV)
			&(cMacro)(aPar,,,)
			
		else
			execBlock(cFunGRV,.f.,.f.,{nOpc})
		endIf
	endIf
	
end transaction



return(lRet)

/*/{Protheus.doc} PLSA500BLO
Bloqueia ou desbloqueia uma guia..
@type function
@author plsteam
@since  15.08.2002
@version 1.0
/*/
function PLSA500BLO(cAlias,nReg,nOpc)
Local aArea		:= (cAlias)->(getArea())
local lRet		:= .f.
local cSQL		:= ""
local oDlg		:= nil
local cTitBtn	:= ""
local cDesBlo	:= ""
local lMsgPerg	:= .t.
local nOpca   	:= 0
local cCpoSta 	:= &(cAlias+"->"+cAlias+"_FASE")
local cCpoSit 	:= &(cAlias+"->"+cAlias+"_SITUAC")
local cCodLDP 	:= &(cAlias+"->"+cAlias+"_CODLDP")
local cCodPEG 	:= &(cAlias+"->"+cAlias+"_CODPEG")
local cCodOpe 	:= &(cAlias+"->"+cAlias+"_CODOPE")
local cNumGuia	:= &(cAlias+"->"+cAlias+"_NUMERO")
local cOriMov 	:= &(cAlias+"->"+cAlias+"_ORIMOV")
local bOK     	:= {|| nOpca := 1,if(nOpca==1,oDlg:end(),.f.) }
local cFunGrv 	:= BCL->BCL_FUNGRV
local cTipGrv 	:= BCL->BCL_TIPGRV
local aFiles  	:= PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI)
local aRet    	:= {}
local cMotBlo 	:= ""
local nLin	  	:= 30
local lAllBlo 	:= .f.
local lProAud 	:= .f.

//Ponto de Entrada para permitir que o sistema desbloqueie
//guias provenientes da liberação.

local lBlLiber	:= iIf( existBlock("PL500LIB"), execBlock("PL500LIB",.f.,.f.), .f. )
default lMsgPerg := .t.

if !lBlLiber
	if cCpoSit == '3' .and. &(cAlias+"->(fieldPos('"+cAlias+"_LIBERA'))") > 0 .and. &(cAlias+"->"+cAlias+"_LIBERA") == "1"
		Aviso(STR0234,STR0267,{"Ok"},2)
		return
	endIf
endIf


//Verifica se trava desbloqueio de guia negada via PTU Online

cMatricUsu := &(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG")+&(cAlias+"->"+cAlias+"_DIGITO")
BA1->(dbSetOrder(2))
if BA1->( msSeek(xFilial("BA1")+cMatricUsu) ) .and. getNewPar("MV_PTUDESG","1") == "0"

	aDadUsr := PLSDADUSR(cMatricUsu,"1", .f., dDataBase)
	
	if cAlias == "BD5"
		BEA->(dbSetOrder(12))//BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV
		
		if BEA->(msSeek(xFilial("BEA")+BD5->(BD5_OPEMOV+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV))) .and. cCpoSit == "3" .and. aDadUsr[45] <> PlsIntPad() .and. BEA->BEA_OPESOL == PlsIntPad()
			
			BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
			
			if BD6->(msSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
				lAllBlo := .t.
				while xFilial("BD5")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV) == xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) .and. !BD6->(eof()) .and. lAllBlo
					if BD6->BD6_STATUS == "1"
						lAllBlo := .f.
					endIf
					BD6->(dbSkip())
				endDo
			endIf
		endIf
	endIf
	
	//Se todos itens negados nega desbloqueio
	if lAllBlo
		Aviso(STR0234,STR0301,{STR0292},2) //"Atencao"###"Não é possível desbloquear guia negada via solicitação PTU Online."###"Ok"
		return
	endIf
endIf

//Checa se existe algum procedimento em auditoria.
if cAlias == "BD5"
	BEA->(dbSetOrder(12))//BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV
	if BEA->(msSeek(xFilial("BEA")+BD5->(BD5_OPEMOV+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV))) .and. cCpoSit == "3"
		BE2->(dbSetOrder(1))//BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
		if BE2->(msSeek(xFilial("BE2")+BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)))
			lProAud := .f.
			while xFilial("BEA")+BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT) == xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) .and. !BE2->(eof()) .and. !lProAud
				if BE2->BE2_STATUS == "0"
					BE2->(dbSetOrder(2))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN + BEG_CODGLO
					if BEG->(msSeek(xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) + "025"))
						lProAud := .t.
					endIf
				endIf
				BE2->(dbSkip())
			endDo
		endIf
	endIf
endIf

if lProAud
	Aviso(STR0234,STR0327,{STR0292},2)//"Atencao"###""Não foi possivel desbloquear a guia, existe um ou mais procedimentos em análise da Auditoria.""###"Ok"
	return
endIf


//Checa se existe o campo e muda a tela

if &(cAlias+"->(fieldPos('"+cAlias+"_MOTBLO'))") == 0
	lMsgPerg := .f.
	nLin		:= 15
endIf


if PLSVERCCBG(&(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+;
		&(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),&(cAlias+"->"+cAlias+"_SEQPF"))
	Help("",1,"PLSA500001")
	return
endIf
__lManunt := .t.

//Testa PEG faturado

if cCpoSta == "4"
	Help("",1,"PLSA500FEC")
	return
endIf

if nOpc == K_Desbloq
	aRet := PLSXVLDCAL(dDataBase,PLSINTPAD(),.t.,"","")
	if aRet[4] == ''
		Help("",1,"PLSA500STA")
		return
	endIf
endIf


//Abre dialog para seleciona opcao desejada

DEFINE MSDIALOG oDlg TITLE STR0248 FROM 008.2,010.3 to 014,045 of GetWndDefault() //"(Des)Bloqueio"


//Mostra botao deacordo com a situacao
//Alexander 30/05/2005

if cCpoSit <> '3'
	cTitBtn := 'Bloquear'
else
	cTitBtn := 'Desbloquear'
endIf

if lMsgPerg
	
	//Motivo do bloqueio
	
	cMotBlo := &(cAlias+"->"+cAlias+"_MOTBLO")
	@ 05,10 say  STR0031  PIXEL of oDlg		 //"Motivo do Bloqueio"
	
	//Checa tipo de bloqueio
	
	if cCpoSit <> '3'
		cMotBlo := Space(03)
		@ 15,10 MsGet cMotBlo Picture "999999"  size 20,08  PIXEL of oDlg F3 "BW" HASBUTTON Valid ValidaTabelaBW(cMotBlo,@cDesBlo)
	else
		cDesBlo := Posicione("SX5",1,xFilial("SX5")+"BW"+cMotBlo,"X5_DESCRI")
		@ 15,10 MsGet cMotBlo Picture "999999"  size 20,08  PIXEL of oDlg When .f.
	endIf
	@ 15,46 MsGet cDesBlo Picture "@!" size 80,08.5  PIXEL of oDlg When .f.
endIf

//Cria Botao

TButton():new(nLin,40, cTitBtn  ,,{ || nOpc := K_Desbloq , oDlg:end(), Eval(bOK) } , 052, 010 ,,,,.t.)

ACTIVATE MSDIALOG oDlg CENTERED

if nOpca <> K_OK
	return
endIf

nOpca := 0

//Testa bloqueio

if ( nOpc == K_Desbloq ) .and. ( cCpoSit == "1" )
	
	if !PLSA500STA("3",cCodOpe,cCodLDP,cCodPEG,cNumGuia,cOriMov,aFiles,cFunGRV,K_Bloqueio,cTipGrv,BCL->BCL_ALIAS,cMotBlo)
		Help("",1,"PLSA500STA")
	endIf
	
elseIf  ( nOpc == K_Desbloq ) .and. ( cCpoSit == "3" )
	
	if !PLSA500STA("1",cCodOpe,cCodLDP,cCodPEG,cNumGuia,cOriMov,aFiles,cFunGRV,K_Desbloq,cTipGRV,BCL->BCL_ALIAS,"")
		Help("",1,"PLSA500STA")
	endIf
	
elseIf  ( nOpc == K_Desbloq ) .and. ( cCpoSit == "2" )
	
	Help("",1,"PLSA500BLO")
	
endIf

if existBlock("PLS500BLO")
	execBlock("PLS500BLO",.f.,.f.,{cCodOpe,cCodLDP,cCodPEG,cNumGuia,cOriMov,cCpoSit,cAlias,nReg,nOpc})
endIf

(cAlias)->(restArea(aArea))

return

/*/{Protheus.doc} PLSA500EDT
Verifica se uma guia pode ser editada
@type function
@author plsteam
@since  15.08.2002
@version 1.0
/*/
function PLSA500EDT(nOpc,cAlias)
local lRet    := .t.
local cCpoSta := &(cAlias+"->"+cAlias+"_FASE")
local cCpoSit := &(cAlias+"->"+cAlias+"_SITUAC")

If nOpc <> K_Visualizar
	//Se eu estiver na guia clonada eu nao tenho q checar o status da PEG
	if &(cAlias)->(fieldPos(cAlias+"_GUESTO")) > 0 .and. &(cAlias)->(fieldPos(cAlias+"_ESTORI")) > 0 .and. !empty(&(cAlias+"->"+cAlias+"_GUESTO")) .and. &(cAlias+"->"+cAlias+"_ESTORI") == '0'
		
		if (cCpoSit <> "1" .and. nOpc <> K_Incluir )
			lRet := .f.
			Help("",1,"PLSA500GND")
		endIf
		
		if nOpc == K_Alterar .and. (cCpoSta == '4' .or. (cCpoSta $ "2,3" .and. !isPLSA600()) )
			lRet := .f.
			Help("",1,"PLSA500PRO")
		endIf
		
	else

		if ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar ) .Or. ( nOpc == K_Cancel )
			
			//Tem que olhar a BCI, se olhar o BD5/BE4 não dá pra incluir guias
			if BCI->BCI_SITUAC <> "1" 
				
				lRet := .f.
				Help("",1,"PLSA500NDI")
				
			elseIf BCI->BCI_FASE == "4" 
				
				lRet := .f.
				Help("",1,"PLSA500FAT")
				
			elseIf cCpoSit <> "1" .and. nOpc <> K_Incluir		
			
				lRet := .f.		
				if nOpc == K_Cancel
					Help("",1,"PLSA500NDI")
				else
					Help("",1,"PLSA500GND")
				endIf
				
			endIf
			
		endIf
		
		if nOpc == K_Alterar .and. (cCpoSta == '4' .or. (cCpoSta $ "2,3" .and. !isPLSA600()))
			lRet := .f.
			Help("",1,"PLSA500PRO")
		endIf
		
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSA500FIL
Retorna dados de um tipo de guia
@type function
@author plsteam
@since  15.08.2002
@version 1.0
/*/
function PLSA500FIL(cCodOpe,cTipGui,cTipo,nOpc,cCpoSta)
local aFiles     := {}
local nCont      := 0
local aCamposLei := {}
local aCamposVis := {}
local aCamposEdt := {}
local nPos		 := 0
local cSQL		 := ""
local cChave	 := ""
local cAlias     := ""
local cNameBCM	 := retSQLName("BCM")
local lBCMExist	 := BCM->(fieldpos("BCM_PERALT ")) > 0

default cTipo 	:= "1"
default nOpc	:= 0
default cCpoSta	:= ""

cChave := cCodOpe + cTipGui + cTipo + cvaltochar(nOpc)
nPos   := ascan(__aFilesLay, { |x| x[1] == cChave })

if nPos == 0 .or. isPLSA600()
	
	if cTipo == "1"
		BCS->(dbSetOrder(2))//BCS_FILIAL+BCS_CODOPE+BCS_TIPGUI+BCS_ORDMON
	else
		BCS->(dbSetOrder(3))//BCS_FILIAL+BCS_CODOPE+BCS_TIPGUI+BCS_ORDGRV
	endIf
	
	BCS->(msSeek(xFilial("BCS")+cCodOpe+cTipGui))
	
	while ! BCS->(eof()) .and. BCS->(BCS_FILIAL+BCS_CODOPE+BCS_TIPGUI) == xFilial("BCS")+cCodOpe+cTipGui
		
		if ! empty(BCS->BCS_EXPF) .and. BCS->BCS_ORDFOL <> '03' .and. BCS->(BCS_LININI+BCS_COLINI+BCS_LINFIN+BCS_COLFIN) == 0
			BCS->(dbSkip())
			loop
		endIf
		
		nCont ++
		
		aCamposVis := {}
		aCamposEdt := {}
		aCamposLei := {}
		
		SX3->(dbSetOrder(2))
		
		cSQL := "  SELECT R_E_C_N_O_ REC "
		cSQL += "    FROM " + cNameBCM
		cSQL += "   WHERE BCM_FILIAL = '" + xFilial("BCM") + "' "
		cSQL += "     AND BCM_CODOPE = '" + BCS->BCS_CODOPE + "' "
		cSQL += "     AND BCM_ALIAS  = '" + BCS->BCS_ALIAS  + "' "
		cSQL += "     AND BCM_TIPGUI = '" + BCS->BCS_TIPGUI + "' "		
		cSQL += "     AND D_E_L_E_T_ = ' '  "
		cSQL += " ORDER BY BCM_FILIAL,BCM_CODOPE,BCM_TIPGUI,BCM_ALIAS,BCM_ORDEM "
		
		dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TRBBCM",.F.,.T.)
	
		while ! TRBBCM->(eof())
		
			BCM->(dbGoTo(TRBBCM->REC))
			
			if ! SX3->( msSeek( BCM->BCM_CAMPO ) )
				TRBBCM->(dbSkip())
				loop
			endIf
			
			aadd(aCamposVis,BCM->BCM_CAMPO)
			if nOpc == K_Alterar .and. ( cCpoSta $ "2,3,4" )
				if lBCMExist .and. BCM->BCM_PERALT 
					aadd(aCamposEdt,BCM->BCM_CAMPO)
				else
					aadd(aCamposLei,BCM->BCM_CAMPO)
				endIf
			else
				if BCM->BCM_SOMLEI == "0"
					aadd(aCamposEdt,BCM->BCM_CAMPO)
				else
					aadd(aCamposLei,BCM->BCM_CAMPO)
				endIf
			endif
			
		TRBBCM->(dbSkip())
		endDo
		
		TRBBCM->(dbCloseArea())
		
		BCQ->(msSeek(xFilial("BCQ")+BCS->BCS_CODOPE+BCS->BCS_ALIAS))		
		
		cAlias := BCS->BCS_ALIAS		
		
		//Matriz de arquivos e registros		
		aadd(aFiles,{BCS->BCS_ALIAS,PLSRETTIT(cAlias),BCS->BCS_TIPO,aCamposVis,;
					allTrim(BCS->BCS_CKEY),BCS->BCS_SOMLEI,BCS->BCS_GRVAUT,BCS->BCS_OBRIG,aCamposEdt,;
					BCS->BCS_ORDFOL,BCS->BCS_LININI,BCS->BCS_COLINI,BCS->BCS_LINFIN,BCS->BCS_COLFIN,;
					BCS->BCS_EXPF,BCS->BCS_GEROBJ,aCamposLei,BCS->BCS_TIPGUI})
		
	BCS->(dbSkip())
	endDo
	
	aadd(__aFilesLay,{cChave,aFiles})
	
else
	aFiles := __aFilesLay[nPos,2]
endIf

return(aFiles)

/*/{Protheus.doc} PLSA500FAS
Trata a mudanca de fase..
@type function
@author plsteam
@since  15.08.2002
@version 1.0
/*/
function PLSA500FAS(cAlias,nReg,nOpc,lFila,lPergunt,lIntEnv,lAutori,isPLSA502)
local cFase   		:= &(cAlias+"->"+cAlias+"_FASE")
local cSituac 		:= &(cAlias+"->"+cAlias+"_SITUAC")
local dDatPro 		:= &(cAlias+"->"+cAlias+"_DATPRO")
local aRet			:= {}
local aFiles   		:= {}
local cMotBlo 		:= ""
local lGloMan		:= getNewPar("MV_PLSCGMA",.f.)
local lRecuGlo		:= getNewPar("MV_PLRECUG",.f.)
local aDadc			:= {}
local aSequen		:= {}
local nCont			:= 0
local aItensGlo		:= {}
local aChvAtu		:= {}
local dDatCtbChk	:= StoD("")
local oFila			:= filaPContas():New()
local lGo			:= .T.
local lReapre       := iif(lUnimed,PlVerReap(BCI->BCI_CODOPE,RIGHT(BCI->BCI_LOTEDI,8)),.f.) //Verifica se é uma reapresentação para não fazer o bloqueio após análise da glosa

default lPergunt    := .t.
default lIntEnv 	:= .f.
default isPLSA502	:= .f.
default lAutori		:= .f.
default cAlias		:= .f.

//alimenta variavel usada na PLSPOSGLO
setCTRVAr("BYPGLOFAS")

dDatCtbChk := PLRtDtCTB(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO"), .F.)

if PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lPergunt) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	
	BCL->(dbSetOrder(1))
	BCL->(msSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
	if BCL->BCL_MUDFAS == '0'
		
		if lPergunt 
			msgStop('Mudança de fase bloqueada para este tipo de guia.')
		endIf

		return
	endIf

	if PLSVERCCBG(&(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+;
				  &(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),&(cAlias+"->"+cAlias+"_SEQPF"))
		
		if lPergunt
			Help(NIL, NIL, "PLSA500001", NIL, "Já gerada a cobrança de custo operacional/co-participação.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Não será possível a exclusão."})
		endIf
		
		return
	endIf
	
	__lManunt := .t.
	
	//Veririfica se registro a valida para mudanca de fase..
	if ! ( ( cFase $ "1" ) .and. ( cSituac == "1" ) ) .and. !isPLSA502
		
		if lPergunt
			Help(NIL, NIL, "PLSA500FS1", NIL, "Não é possível utilizar a opção Mudança de fase para esta guia", 1, 0, NIL, NIL, NIL, NIL, NIL, {"A mudança de fase somente está disponível para guias na fase EM DIGITAÇÃO"})
		endIf
		
		return
	endIf
	
	//Veririfica se registro a valida para mudanca de fase
	if empty(dDatPro)
		
		if lPergunt
			Help(NIL, NIL, "PLSA500DAT", NIL, "data do procedimento inválida", 1, 0, NIL, NIL, NIL, NIL, NIL, {"verifique o preenchimento da data de procedimento da guia"})
		endIf
		
		return
	endIf

	if &(cAlias)->(fieldPos(cAlias+"_TIPGUI")) > 0 .and. &(cAlias+"->"+cAlias+"_TIPGUI") == G_SOL_INTER 
		
		if &(cAlias)->(fieldPos(cAlias+"_DTALTA")) > 0 .and. empty(&(cAlias+"->"+cAlias+"_DTALTA"))
			
			if lPergunt
				Help(NIL, NIL, "PLSA500DAT", NIL, "data do procedimento inválida", 1, 0, NIL, NIL, NIL, NIL, NIL, {"verifique o preenchimento da data da alta"})
			endIf

			return
		endIf
		
	endIf
	if !isPLSA600()
		//Confirma a mudanca de fase
		if lPergunt .and.  ! msgYesNo(STR0033) //"Confirma a Mudanca de Fase"
			return
		endif
	endif
	oFila:setTipGui(BCI->BCI_TIPGUI)
	oFila:setCodLdp(BCI->BCI_CODLDP)
	oFila:setCodPeg(BCI->BCI_CODPEG)
	oFila:setNumGui((cAlias)->&( cAlias + "_NUMERO" ))
	oFila:setPriority()
   	If !oFila:chkfimfila()
   		MsgInfo("O PEG ja se encontra na fila de processamento, por favor aguarde")
   		lGo := .F.
    endIf	
	
	If lGo
		PLconvRDA7( (cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_NUMERO" ))
		If !lFila
			//Se for alteracao habilita botao mudanca de fase
			aChvAtu := { (cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_NUMERO" ), (cAlias)->&( cAlias + "_ORIMOV" ) }
			
		    aRet := PLSXMUDFAS(cAlias,"1",BCL->BCL_CODOPE,BCL->BCL_TIPGUI,dDatPro,lAutori,nil,nil,nil,lPergunt,nil,;
								nil,nil,lIntEnv,nil,nil,nil,nil,nil,nil,nil,;
								nil,nil,nil,nil,nil,nil,nil, nil, nil, isPLSA502)
			
			//Para guias estornadas, a mudanca de fase bloqueia a mesma após o termino
			if &(cAlias)->(fieldPos(cAlias+"_GUESTO")) > 0 .and. ! empty( (cAlias)->&( cAlias + "_GUESTO" )) .and. (cAlias)->&( cAlias + "_FASE" ) <> '2' .and. !lReapre
				
				BCL->(dbSetOrder(1))
				
				if BCL->(msSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
					aFiles := PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI)
				endIf
				
				PLSA500STA("3",(cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_NUMERO" ),(cAlias)->&( cAlias + "_ORIMOV" ),aFiles,BCL->BCL_FUNGRV,K_Bloqueio,BCL->BCL_TIPGRV,BCL->BCL_ALIAS,getNewPar("MV_PLGUIES","123"))
				
			endIf
			
			if lPergunt
				
				PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))
				
				//caso o parâmetro MV_PLSCGMA esteja habilitado deve verificar se teve glosa manual anterior e deve "resgatar"
				if lGloMan .and. lRecuGlo
					
					aDadc := PLSA500CRI( (cAlias)->&( cAlias + "_CODOPE" ), (cAlias)->&( cAlias + "_CODLDP" ),;
										 (cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_NUMERO" ),;
										 (cAlias)->&( cAlias + "_ORIMOV" ), nil, nil, nil, lGloMan, lRecuGlo)
		
					for nCont := 1 to len(aDadc)
					
						BDX->(dbGoto(aDadc[nCont,36]))
						
						if BDX->(deleted())           		//se o registro está deletado
							BDX->(recLock("BDX",.f.))
							BDX->(dbRecall())               //restaura os registro removidos
							BDX->BDX_REGREC := ""
							BDX->(msUnLock())
						endIf
						
						if aScan(aSequen, {|x| x == BDX->BDX_SEQUEN } ) == 0		
							aadd(aSequen, BDX->BDX_SEQUEN )			
						endIf
		
						if aScan(aItensGlo, {|x| x[1] + x[12] == BDX->(BDX_SEQUEN + BDX_CODGLO) } ) == 0		
		
							aadd(aItensGlo,{BDX->BDX_SEQUEN,;												//01
											BDX->BDX_VLRMAN,;												//02
											BDX->BDX_VLRGLO,;												//03
											BDX->BDX_ACAOTX,;						 						//04
											BDX->BDX_VLRGTX,; 							                    //05
											BDX->BDX_TIPGLO,; 												//06
											iIf(empty(BDX->BDX_ACAO), BDX->BDX_GLACAO, BDX->BDX_ACAO),;		//07
											iIf(empty(BDX->BDX_ACAO), "2", "1"),;							//08 //Parametro novo que indica se foi analisado pela crítica (1-Procedimento 2-Crítica)
											BDX->BDX_CODTPA,; 												//09
											BDX->BDX_QTDGLO,; 	   											//10
											BDX->BDX_TIPREG,;												//11
											BDX->BDX_CODGLO,;												//12
											BDX->BDX_VLRPAG,;												//13
											BDX->BDX_PERGLO,;												//14
											BDX->BDX_VLTXPG,;												//15
											iIf(BDX->BDX_TIPGLO == '3',.t.,.f.)})							//16
						endIf
						
					next nCont
					
					if len(aItensGlo) > 0
						
						aRet := PLSXMUDFAS(cAlias,"3","",BCL->BCL_TIPGUI,ctod(""),.f.,"3",nil,nil,.t.,aItensGlo,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,aSequen)
									   
					endIf				   
					
				endIf
				
				If Len(aRet) >= 1 .And. aRet[1]
					msgInfo(STR0034) //"Mudanca de Fase concluida com sucesso !!!"
				EndIf
			endIf
			//Trecho pra gerar query de conferência, apagar isso depois
			BD6->(DbSetOrder(1))
			BD6->(MsSeek( xfilial("BD6") + aChvAtu[1] + aChvAtu[2] + aChvAtu[3] + aChvAtu[4] + aChvAtu[5]))
			
			//Trecho pra gerar query de conferência, apagar isso depois
		else
			
			addFilaPLS((cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_CODLDP" ), (cAlias)->&( cAlias + "_TIPGUI" ), (cAlias)->&( cAlias + "_NUMERO" ), , )
			if isPLSA600()
				msgInfo("Guia enviada para a fila de processamento")
			endif
		endIf
	endIf
endIf							  

return

/*/{Protheus.doc} PLSA500ACT
Trata a analise da conta medica
@type function
@author PLS TEAM
@since 04.12.2002
@version 1.0
/*/
function PLSA500ACT(cAlias, nReg, nOpc)
local aArea 		:= BD5->(getArea())
local aAreaBDX 		:= {}
local nPosCri		:= 0
local nInd			:= 0
local nPosSITE		:= 0
local nOpca			:= 0
local nRecBD6  		:= 0
local nRecBA1  		:= 0
local nRecBDX  		:= 0
local nRecAli  		:= 0
local nOrdBD6  		:= 0
local nOrdBA1  		:= 0
local nOrdBDX  		:= 0
local nOrdAli  		:= 0
local nLinAntIte	:= 0
local nLinAnt 		:= 0
local nVlrGlo		:= 0
local nVlGlTx		:= 0
local nVlTxPg		:= 0
local nValAux		:= 0
local nVlrBase		:= 0
local nY			:= 0
local nRegBCI       := BCI->(recno())

local bFilter		:= ""
local bOK      		:= {|| oDlg:end() }
local bCancel  		:= {|| oDlg:end() }
local bBotao01 		:= {|| BA1->(dbSetOrder(2)), BA1->(msSeek(xFilial("BA1")+cMatric)), Eval(bAliVar) ,if(BA1->(Found()),PLSA260MOV("BA1",BA1->(recno()),K_Visualizar),Help("",1,"PLSA090USR")),Eval(bRest) }
local bBotao02 		:= {|| BA1->(dbSetOrder(2)), BA1->(msSeek(xFilial("BA1")+cMatric)), Eval(bAliVar) ,if(BA1->(Found()),AxVisual("BA1",BA1->(recno()),K_Visualizar),Help("",1,"PLSA090USR")),Eval(bRest) }
local bBotao03 		:= {|| BA1->(dbSetOrder(2)), BA1->(msSeek(xFilial("BA1")+cMatric)), Eval(bAliVar) ,if(BA1->(Found()),PLSA500LMV(),Help("",1,"PLSA090USR")),Eval(bRest) }
local bBotao04 		:= {|| BA1->(dbSetOrder(2)), BA1->(msSeek(xFilial("BA1")+cMatric)), Eval(bAliVar) ,if(BA1->(Found()),PLSA090("1"),Help("",1,"PLSA090USR")),Eval(bRest) }
local bBotao05 		:= {|| BA1->(dbSetOrder(2)), BA1->(msSeek(xFilial("BA1")+cMatric)), Eval(bAliVar) ,if(BA1->(Found()),PLSA090("2"),Help("",1,"PLSA090USR")),Eval(bRest) }
local bBotao06 		:= {|| BA1->(dbSetOrder(2)), BA1->(msSeek(xFilial("BA1")+cMatric)), Eval(bAliVar) ,if(BA1->(Found()),PLSA092(),Help("",1,"PLSA090USR")),Eval(bRest) }
local bAfterEdtI	:= {|a,b,c,d| PLSA500COR(a,b,c,d,oBrwCri)}
local bMultaCIte	:= {|| oBrwIte:Refresh(),Eval(oBrwIte:bGotFocus)}
local bDblCliIte	:= {|| oBrwIte:EditRecord("BDX",K_Alterar,cTitulo,oBrwIte:linha(),oBrwIte:aCols,oBrwIte:aHeader,bAfterEdtI,bMultaCIte) }//"Analise de glosa não permitida no cabeçalho!"
local bAfterEdtC	:= {|a,b| PLSA500Coc(a,b,oBrwIte,oBrwCri)}
local bMultaCCri	:= {|| oBrwCri:refresh(),Eval(oBrwCri:bGotFocus)}
local bDblCliCri	:= {|| PLSDBCli(oBrwIte,oBrwCri,cTitulo,bAfterEdtC,bMultaCCri) }

local bAliVar  		:= {|| 	nRecBD6  := BD6->(recno()),;
							nRecBA1  := BA1->(recno()),;
							nRecBDX  := BDX->(recno()),;
							nRecAli  := &(cAlias+"->(recno())"),;
							nOrdBD6  := BD6->(IndexOrd()),;
							nOrdBA1  := BA1->(IndexOrd()),;
							nOrdBDX  := BDX->(IndexOrd()),;
							nOrdAli  := &(cAlias+"->(IndexOrd())")}
							
local bRest := {|| if(	cFilAli<>"###", if(cAlias == "BD5", ;
						BD5->(dbSetFilter({||&cFilAli},cFilAli)) , ;
						BE4->(dbSetFilter({||&cFilAli},cFilAli))),nil) ,;
						BA1->(dbSetOrder(nOrdBA1)),;
						BA1->(dbGoto(nRecBA1))    ,;
						BD6->(dbSetOrder(nOrdBD6)),;
						BD6->(dbGoto(nRecBD6))    ,;
						BDX->(dbSetOrder(nOrdBDX)),;
						BDX->(dbGoto(nRecBDX))    ,;
						&(cAlias+"->(dbSetOrder("+allTrim(str(nOrdAli))+"))"),;
						&(cAlias+"->(dbGoto("+allTrim(str(nRecAli))+"))") }

local aButtons 		:= {}
local aHeaderIte	:= {}
local aDadosIte 	:= {}
local aHeaderCri	:= {}
local aDadosCri 	:= {}
local aChave    	:= {}
local aItensGlo 	:= {}
local aFiles    	:= {}
local aSequen 		:= {}

local oSay			:= nil
local oBmp			:= nil
local oDlg			:= nil

local cSequen		:= "" 
local cFilAli  		:= iIf(findFunction("tcSqlFilter"),iIf(Funname()=="PLSA501","###",&(cAlias+"->(tcSqlFilter())")),"###")
local cCadastro 	:= STR0036 //"Analise de Glosas"
local cTitulo  		:= STR0035 //"Analise das Contas Medicas"
local cChave		:= &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local cMatric  		:= &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODEMP+"+cAlias+"_MATRIC+"+cAlias+"_TIPREG+"+cAlias+"_DIGITO)")
local cCodOpe  		:= &(cAlias+"->"+cAlias+"_CODOPE")
local cCodLDP  		:= &(cAlias+"->"+cAlias+"_CODLDP")
local cCodPEG  		:= &(cAlias+"->"+cAlias+"_CODPEG")
local cNumero  		:= &(cAlias+"->"+cAlias+"_NUMERO")
local cOriMov  		:= &(cAlias+"->"+cAlias+"_ORIMOV")
local cFase	   		:= &(cAlias+"->"+cAlias+"_FASE")
local cSituac  		:= &(cAlias+"->"+cAlias+"_SITUAC")

local cCpoBDX 		:= '"'+	",BDX_CODTPA"+;
							",BDX_VLRBP2"+;
							",BDX_VLRGL2"+;
							",BDX_VLRGT2"+;
							",BDX_VLRMA2"+;
							",BDX_VLRPA2"+;
							",BDX_VLTXA2"+;
							",BDX_PERGL2"+;
							",BDX_VLRAPR"+;
							",BDX_QTDAPR"+;
							",BDX_QTDINF"+;
							",BDX_VLRINF"+;
							",BDX_VLGREA"+;
							",BDX_VLRREC"+;
							",BDX_QTDREC"+;
							iIf( getNewPar("MV_PLSDTPG",.f.),",BDX_RESPAL","")+;
							",BDX_VLRAP2"+;
							",BDX_GLACAO"+;
							",BDX_QTDGLO"+;
							",BDX_QTDPRO"+'"'
							
local Inclui    	:= .f.
local lHouveAcao	:= .f.
local lAnaGloCP 	:= .f.
local lGloAuto		:= .f.
local lPLS500AG 	:= existBlock("PLS500AG")
local lGloMan		:= getNewPar("MV_PLSCGMA",.f.)
local lRecuGlo		:= getNewPar("MV_PLRECUG",.f.) 
Local nInd2			:= 1
Local nPosBrwCri	:= 1
local nGlo 			:= 1
local lReapre       := iif(lUnimed,PlVerReap(BCI->BCI_CODOPE,RIGHT(BCI->BCI_LOTEDI,8)),.f.)//Verifica se é uma reapresentação

private lAnaliAll	:= .f.
private oBrwIte		:= nil
private oBrwCri		:= nil
private aVetIte    	:= {}
private aVetCri   	:= {}
private cCodProSel	:= ""
private cChaveACT  	:= cCodOpe + cCodLDP + cCodPEG + cNumero + cOriMov

default aVetIte 	:= {}

//analise de glosa pela critica
if getNewPar("MV_PLSDTPG",.f.)

	bOK := {|| nOpca := 1,iIf(PLSA500VAG(oBrwIte,oBrwCri,@lAnaliAll),iIf(Aviso(STR0312,STR0313,{STR0314, STR0315},2) == 1,; //"Análise Glosa" "Todas as Glosas estão analisadas.Confirmar a Análise ?" "Sim" "Não"
			   nil,(nOpca := 2,oDlg:end())),iIf(Aviso(STR0312,STR0316,{ STR0314, STR0315},2) == 1,(nOpca:=2,oDlg:end()),nOpca:=2)),iIf(nOpca==1,oDlg:end(),.f.) } //"Existem Glosas ainda NÃO Analisadas. Fechar a Analise ?"

else

	bOK := {|| nOpca := 1, iIf(PLSA500VAG(oBrwIte,oBrwCri,@lAnaliAll), oDlg:end(), nOpca := 2 ),iIf( nOpca == 1, oDlg:end(), .f.) }

endIf

__lManunt := .t.

if ( ! ( cSituac == "1" .and. cFase == "2" ) )
	Help("",1,"PLSA500ANA")
	return
endIf

//Verifica se já teve análise antes
if ! lRecuGlo .and. cFase == "2" .And. cSituac == "1"
	PLSA500MTA(cCodOpe,cCodLDP,cCodPEG,cNumero,lGloMan)
endIf

BDX->(dbSetOrder(3))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_TIPGLO
if ! BDX->(msSeek(xFilial("BDX")+cChave))
	Help("",1,"PLSA500AC2")
	return
else
	cCodProSel := BDX->BDX_SEQUEN
endIf

aAreaBDX := BDX->(getArea())

//Monta dados dos itens
store Header "BDX" to aHeaderIte for ! ( allTrim(SX3->X3_CAMPO) $  "BDX_TIPREG,BDX_IMGCRI,BDX_NIVEL,BDX_CODGLO,BDX_GLOSIS,BDX_DESGLO,BDX_INFGLO" + cCpoBDX )

nPosSITE := plRetPos("BDX_SEQUEN",aHeaderIte)

cChavePes := xFilial("BDX") + cChave
cKey 	  := 'BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV)' 

ACTcols20("BDX", 4, aHeaderIte, @aDadosIte, @aVetIte, cChavePes, cKey, "BDX->BDX_TIPGLO <> '3' .and. BDX->BDX_TIPREG == '1' .and. ! empty(BDX->BDX_NIVEL) .and. aScan(aCols,{|x| x[" + cValToChar(nPosSITE) + "] == BDX->BDX_SEQUEN } ) == 0", "BDX->BDX_TIPGLO <> '3' .and. BDX->BDX_TIPREG == '1' .and. ! empty(BDX->BDX_NIVEL) .AND. BDX->BDX_CODGLO == '020' .and. aScan(aCols,{|x| x[" + cValToChar(nPosSITE) + "] == BDX->BDX_SEQUEN } ) == 0" )

//Monta dados das criticas
store Header "BDX" to aHeaderCri for ! ( allTrim(SX3->X3_CAMPO) $ "BDX_RESPAL,BDX_GLOSIS,BDX_IMGSTA,BDX_CODPAD,BDX_CODPRO,BDX_DESPRO,BDX_VLRAPR,BDX_VLRBPR,BDX_PERGTX" + cCpoBDX)

plMontACols("BDX", 4, aHeaderCri, @aDadosCri, @aVetCri, cChavePes, cKey, "BDX->BDX_TIPGLO <> '3' .and. BDX->BDX_TIPREG $ '1,2, '" )

BDX->(restArea(aAreaBDX))

aadd(aButtons,{"GROUP",bBotao01,STR0037+" - <F9>",STR0015}) //"Dados da Familia"###"Familia"
setKey(VK_F9,bBotao01)

aadd(aButtons,{"RESPONSA",bBotao02,STR0038+" - <F10>",STR0039}) //"Dados do Usuario"###"Usuario"
setKey(VK_F10,bBotao02)

aadd(aButtons,{"RELATORIO",bBotao03,STR0040+" - <F11>",STR0245}) //"Movimentacao do Usuario" //"Movto."
setKey(VK_F11,bBotao03)

aadd(aButtons,{"RELATORIO",bBotao04,STR0041,STR0249}) //"Autorizacao SADT" //"Autori."

aadd(aButtons,{"RELATORIO",bBotao05,STR0042,STR0250}) //"Liberacao" //"Liber."

aadd(aButtons,{"RELATORIO",bBotao06,STR0043,STR0251}) //"Autorizacao Int." //"Intern."

aSize 		:= msAdvSize()
aObjects 	:= {}
aadd( aObjects, { 100, 50 , .t., .f., .f. } )
aadd( aObjects, { 100, 100, .t., .t., .f. } )
aadd( aObjects, { 100, 10 , .t., .f., .f. } )
aadd( aObjects, { 100, 100, .t., .t., .f. } )

aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := msObjSize( aInfo, aObjects )

//Define dialogo
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] of GetWndDefault() Pixel

@ aPosObj[1,1]+005,aPosObj[1,2]+005 say oSay PROMPT STR0044   size 220,010 of oDlg PIXEL  //"Usuario     "
@ aPosObj[1,1]+005,aPosObj[1,2]+040 say oSay PROMPT if(nOpc==K_Incluir,&("M->"+BCL->BCL_ALIAS+"_NOMUSR"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_NOMUSR")) size 205,010 of oDlg PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+015,aPosObj[1,2]+005 say oSay PROMPT STR0045   size 220,010 of oDlg PIXEL  //"Prestador   "
@ aPosObj[1,1]+015,aPosObj[1,2]+040 say oSay PROMPT if(nOpc==K_Incluir,&("M->"+BCL->BCL_ALIAS+"_NOMRDA"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_NOMRDA")) size 205,010 of oDlg PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+025,aPosObj[1,2]+005 say oSay PROMPT STR0046   size 220,010 of oDlg PIXEL  //"Data Evento "
@ aPosObj[1,1]+025,aPosObj[1,2]+040 say oSay PROMPT if(nOpc==K_Incluir,&("M->"+BCL->BCL_ALIAS+"_DATPRO"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_DATPRO")) size 205,010 of oDlg PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+005,aPosObj[1,2]+200 say oSay PROMPT STR0047   size 220,010 of oDlg PIXEL  //"Solicitante "
@ aPosObj[1,1]+005,aPosObj[1,2]+235 say oSay PROMPT if(nOpc==K_Incluir,&("M->"+BCL->BCL_ALIAS+"_NOMSOL"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_NOMSOL")) size 205,010 of oDlg PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+015,aPosObj[1,2]+200 say oSay PROMPT STR0048   size 220,010 of oDlg PIXEL  //"Senha Autor."
@ aPosObj[1,1]+015,aPosObj[1,2]+235 say oSay PROMPT if(nOpc==K_Incluir,&("M->"+BCL->BCL_ALIAS+"_SENHA"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_SENHA")) size 205,010 of oDlg PIXEL COLOR CLR_HBLUE

@ aPosObj[1,1]+025,aPosObj[1,2]+200 say oSay PROMPT "CID         "   size 220,010 of oDlg PIXEL
@ aPosObj[1,1]+025,aPosObj[1,2]+235 say oSay PROMPT if(nOpc==K_Incluir,&("M->"+BCL->BCL_ALIAS+"_CID"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_CID"))     size 205,010 of oDlg PIXEL COLOR CLR_HBLUE

//Ativa o dialogo
@ aPosObj[1,1]+040,aPosObj[1,2]+005 BITMAP oBmp RESNAME "BR_AZUL"	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+040,aPosObj[1,2]+020 say oSay PROMPT "Sem Analise" size 100,010 of oDlg PIXEL //"Sem Analise"

@ aPosObj[1,1]+040,aPosObj[1,2]+090 BITMAP oBmp RESNAME "BR_AMARELO" 	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+040,aPosObj[1,2]+105 say oSay PROMPT STR0050 size 100,010 of oDlg PIXEL //"Glosada Parcialmente"

@ aPosObj[1,1]+040,aPosObj[1,2]+180 BITMAP oBmp RESNAME "BR_VERMELHO"	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+040,aPosObj[1,2]+195 say oSay PROMPT STR0049 size 100,010 of oDlg PIXEL //"Glosada Integralmente"

@ aPosObj[1,1]+040,aPosObj[1,2]+270 BITMAP oBmp RESNAME "BR_VERDE"   	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+040,aPosObj[1,2]+285 say oSay PROMPT STR0051 size 100,010 of oDlg PIXEL //"Reconsiderada"

//Exibe itens
oBrwIte 		   	:= TPLSBrw():new(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3],nil,oDlg,nil,bDblCliIte,nil,nil,nil,.t.,nil,.t.,nil,aHeaderIte,aDadosIte,.f.,"BDX",K_Alterar,STR0052,nil,nil,nil,aVetIte,"PLVLDBDX('1')","AllwaysFalse()",nil,nil) //"Analise de Contas"
oBrwIte:bLostFocus 	:= { || cCodProSel := oBrwIte:aCols[oBrwIte:linha(),oBrwIte:plRetPos("BDX_SEQUEN")], BDX->( dbGoto( aVetIte[oBrwIte:linha()] ) ),nLinAntIte := oBrwIte:linha() }
oBrwIte:bGotFocus 	:= { || oBrwIte:setPos(nLinAntIte),Eval(oBrwIte:bChange)}
oBrwIte:bChange    	:= { || Eval(oBrwIte:bLostFocus),oBrwCri:forceRefresh(oBrwIte) }
oBrwIte:lAddLine   	:= .f.
	
@ aPosObj[3,1],aPosObj[3,2]+005 BITMAP oBmp RESNAME "BR_AZUL"	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[3,1],aPosObj[3,2]+020 say oSay PROMPT "Sem Analise" size 100,010 of oDlg PIXEL //"Sem Analise"

@ aPosObj[3,1],aPosObj[3,2]+090 BITMAP oBmp RESNAME "BR_VERMELHO"	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[3,1],aPosObj[3,2]+105 say oSay PROMPT "Glosada" size 100,010 of oDlg PIXEL //"Glosada"

@ aPosObj[3,1],aPosObj[3,2]+180 BITMAP oBmp RESNAME "BR_VERDE"   	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[3,1],aPosObj[3,2]+195 say oSay PROMPT STR0051 size 100,010 of oDlg PIXEL //"Reconsiderada"

//Exibe criticas (itens)
bFilter  			:= {|nLine,aCols,aHeader| aCols[nLine,GdfieldPos("BDX_SEQUEN",aHeader)] == cCodProSel }
oBrwCri 			:= TPLSBrw():new(aPosObj[4,1],aPosObj[4,2],aPosObj[4,4],aPosObj[4,3],nil,oDlg,nil,bDblCliCri,nil,nil,nil,.t.,nil,.t.,nil,aHeaderCri,aDadosCri,.f.,"BDX",K_Alterar,STR0056,nil,nil,nil,aVetCri,"PLVLDBDX('2')","AllwaysFalse()",bFilter,nil) //"Criticas"
oBrwCri:bLostFocus	:= { || BDX->( dbGoto( aVetCri[oBrwCri:linha()] ) ),nLinAnt := oBrwCri:linha() }
oBrwCri:bGotFocus	:= { || oBrwCri:setPos(nLinAnt),eval(oBrwCri:bChange)}
oBrwCri:bChange    	:= { || eval(oBrwCri:bLostFocus)}
oBrwCri:oPai    	:= oBrwIte
oBrwCri:aOrigem 	:= {"BDX_SEQUEN"}
oBrwCri:aRelac  	:= {"BDX_SEQUEN"}
oBrwCri:lAddLine   	:= .f.

if len(oBrwCri:aCols) > 0

	PLSA500Coc(oBrwIte,oBrwCri)
	
	eval(oBrwIte:bLostFocus)
	
	oBrwIte:refresh()
	oBrwCri:forceRefresh(oBrwIte)
	
endIf

// P.E. utilizado para adicionar itens no Menu da mBrowse
if ExistBlock("P500BTAG")
	aRotAna := ExecBlock("P500BTAG",.F.,.F.,{oBrwIte,oBrwCri})
	if valtype(aRotAna) == "A"
		aeval(aRotAna,{|x| AAdd(aButtons,x)})
	endif
endif

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.f.,aButtons)

if nOpca == K_OK  .and. nOpc <> K_Visualizar
	
	lAnaGloCP := .t.
	
	//Verifica se houve alguma acao em algum item para que seja grava
	for nInd := 1 to len(oBrwIte:aCols)
		
		if ! empty(oBrwIte:fieldGet("BDX_ACAO",nInd)) .and. oBrwIte:fieldGet("BDX_CRIANA",nInd) == '1'
			lHouveAcao 	:= .t.
			exit
		endIf
		
	next
	
	if lHouveAcao
					
		aadd(aChave,{"BDX_DTACAO",dDataBase})
		
		// grava os registros da critica no banco.
		aadd(aChave,{"BDX_CODOPE",cCodOpe})
		aadd(aChave,{"BDX_CODLDP",cCodLDP})
		aadd(aChave,{"BDX_CODPEG",cCodPEG})
		aadd(aChave,{"BDX_NUMERO",cNumero})
		aadd(aChave,{"BDX_ORIMOV",cOriMov})

		nSeqCri := ascan(oBrwCri:aHeader, { |x| x[2] == "BDX_SEQUEN"})
		nTipReg := ascan(oBrwCri:aHeader, { |x| x[2] == "BDX_TIPREG"})

		For nInd := 1 To Len(oBrwIte:aCols)
							
			cSeq	:= oBrwIte:fieldGet("BDX_SEQUEN",nInd)
			//Atualiza o oBRWCri com o BrwIte, se não ele vai conter valores de glosa diferentes pros BDX principais diferentes
			while ascan(oBrwCri:aCols, { |x| x[nTipReg] == "1" .AND. x[nSeqCri] == cSeq}, nInd2) > 0
				
				nPosBrwCri := ascan(oBrwCri:aCols, { |x| x[nTipReg] == "1" .AND. x[nSeqCri] == cSeq}, nInd2)
				
				oBrwCri:fieldPut("BDX_PERGLO", oBrwIte:fieldGet("BDX_PERGLO",nInd), nPosBrwCri)
				oBrwCri:fieldPut("BDX_VLRGLO", oBrwIte:fieldGet("BDX_VLRGLO",nInd), nPosBrwCri)
				oBrwCri:fieldPut("BDX_PERGLO", oBrwIte:fieldGet("BDX_PERGLO",nInd), nPosBrwCri)
				oBrwCri:fieldPut("BDX_VLRMAN", oBrwIte:fieldGet("BDX_VLRMAN",nInd), nPosBrwCri)
				oBrwCri:fieldPut("BDX_VLRPAG", oBrwIte:fieldGet("BDX_VLRPAG",nInd), nPosBrwCri)
				oBrwCri:fieldPut("BDX_PERGTX", oBrwIte:fieldGet("BDX_PERGTX",nInd), nPosBrwCri)
				oBrwCri:fieldPut("BDX_VLRGTX", oBrwIte:fieldGet("BDX_VLRGTX",nInd), nPosBrwCri)
				
				nInd2 := ascan(oBrwCri:aCols, { |x| x[nTipReg] == "1" .AND. x[nSeqCri] == cSeq}, nInd2) + 1
			endDo
		Next
		
		begin transaction
					
			oBrwCri:grava(aChave)
			oBrwIte:grava(aChave)
			
			BDX->(dbSetOrder(3))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_TIPGLO+BDX_SEQUEN
			
			for nInd := 1 to len(oBrwIte:aCols)
				
				nVlrGlo := 0
				nVlGlTx := 0
				nVlTxPg	:= 0
				nValAux := 0
				
				if oBrwIte:fieldGet("BDX_CRIANA",nInd) == '1' .and. ! empty( oBrwIte:fieldGet("BDX_ACAO",nInd) )

					nPosCri := aScan(oBrwCri:aCols,{|x| x[oBrwCri:plRetPos("BDX_SEQUEN")] == oBrwIte:fieldGet("BDX_SEQUEN",nInd) })
					
					if nPosCri > 0
						
						if aScan(aItensGlo,{|x| x[1] == oBrwIte:fieldGet("BDX_SEQUEN",nInd) }) == 0
							
							cSequen := oBrwIte:fieldGet("BDX_SEQUEN",nInd)
							
							//soma o valor de glosa manual recuperada
							for nY := nPosCri to len(oBrwCri:aCols)
							
								if oBrwCri:fieldGet("BDX_SEQUEN",nY) == cSequen  
									
									//glosa manual
									if oBrwCri:fieldGet("BDX_TIPGLO",nY) == '2' .and. oBrwCri:fieldGet("BDX_ACAO",nY) == '1'
										
										nVlGlTx := oBrwCri:fieldGet("BDX_VLRGTX",nY)
										nVlTxPg := oBrwCri:fieldGet("BDX_VLTXPG",nY)

										nVlrGlo += oBrwCri:fieldGet("BDX_VLRGLO",nY)
										nValAux := oBrwIte:fieldGet("BDX_VLRGLO",nInd) + nVlrGlo
										
										//para garantir que caso o total de glosa manual nao tenha passado o valor da glosa do evento
										if nValAux > oBrwIte:fieldGet("BDX_VLRMAN",nInd)
											
											nVlrGlo := oBrwIte:fieldGet("BDX_VLRMAN",nInd)
											exit
											
										endIf
										
									endIf	
									
								else
									exit
								endIf
									
							next	 
							
							if nVlrGlo > 0
								
								nVlrBase := oBrwIte:fieldGet("BDX_VLRMAN",nInd)
								nVlrBase -= nVlrGlo
								
								oBrwIte:fieldPut("BDX_VLRMAN", nVlrBase, nInd)
								oBrwIte:fieldPut("BDX_VLTXPG", nVlTxPg, nInd)
								oBrwIte:fieldPut("BDX_VLRGTX", nVlGlTx, nInd)
								
								oBrwIte:fieldPut("BDX_VLRPAG", oBrwIte:fieldGet("BDX_VLRMAN", nInd) + oBrwIte:fieldGet("BDX_VLTXPG", nInd), nInd)
									
							endIf
								
							//para ser usado na mudanca de fase evitando passar por todos os itens
							aadd(aSequen, cSequen)
							
							//verifica se teve glosa automatica 			
							lGloAuto := BDX->( msSeek(xFilial("BDX") + cCodOpe + cCodLDP + cCodPEG + cNumero + cOriMov + "3" + cSequen))
						
							if ( !lPLS500AG ) .Or. ( lPLS500AG .And. ExecBlock("PLS500AG",.F.,.F.,{oBrwIte:FieldGet("BDX_ACAO",nInd),oBrwIte:FieldGet("BDX_SEQUEN",nInd)}) )
 
								aadd(aItensGlo,{cSequen,; 											//01
												oBrwIte:fieldGet("BDX_VLRMAN",nInd),;				//02
												oBrwIte:fieldGet("BDX_VLRGLO",nInd) + nVlrGlo,;		//03
												oBrwIte:fieldGet("BDX_ACAOTX",nInd),;				//04
												oBrwIte:fieldGet("BDX_VLRGTX",nInd),; 				//05
												oBrwIte:fieldGet("BDX_TIPGLO",nInd),;				//06
												oBrwIte:fieldGet("BDX_ACAO",nInd),;					//07
												"1",;												//08
												oBrwCri:fieldGet("BDX_CODTPA",nPosCri),;			//09
												oBrwCri:fieldGet("BDX_QTDGLO",nPosCri),; 			//10
												oBrwCri:fieldGet("BDX_TIPREG",nPosCri),;			//11
												oBrwCri:fieldGet("BDX_CODGLO",nPosCri),;			//12
												oBrwIte:fieldGet("BDX_VLRPAG",nInd),;				//13
												oBrwIte:fieldGet("BDX_PERGLO",nInd),;				//14
												oBrwIte:fieldGet("BDX_VLTXPG",nInd),;				//15
												lGloAuto })											//16
							endif
						
						endIf
													
					endIf																			
										
				endIf
				
			next
			
			// Todos analisados muda fase
			if lAnaliAll
				BD6->(dbSetOrder(1)) // BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
				// percorremos os itens glosados para verificar quais foram reconsiderados (BDX_ACAO = "2")
				// em caso positivo, desbloqueia o BD6
				for nGlo := 1 to len(aItensGlo)
					if BD6->( msSeek(xFilial("BD6") + cCodOpe + cCodLDP + cCodPEG + cNumero + cOriMov + aItensGlo[nGlo,1]))
						if BD6->BD6_ENVCON == "1" .and. aItensGlo[nGlo,7] == "2"
							BD6->(recLock("BD6",.f.))
							PLBLOPC('BD6', .f., aItensGlo[nGlo,12], , .t., .t.)
							BD6->(msUnLock())
						endif
					endif
					
					//Métrica do PLS - Quantidade de ações por tipo de glosa
					if lHabMetric .and. lLibSupFw .and. lVrsAppSw 
						plsTelRecGlo(aItensGlo[nGlo,6],aItensGlo[nGlo,7])
					endif

				next
				RestArea(aArea)
				
				PLSXMUDFAS(cAlias,"3","",BCL->BCL_TIPGUI,ctod(""),.f.,"3",nil,nil,.t.,aItensGlo,nil,nil,nil,oBrwIte,;
						   nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,aSequen)
						   
			endIf

			//Para guias estornadas, a mudanca de fase bloqueia a mesma após o termino
			if &(cAlias)->( fieldPos(cAlias + "_GUESTO") ) > 0 .and. &(cAlias)->( fieldPos(cAlias + "_ESTORI") ) > 0 .and. ! empty( (cAlias)->&( cAlias + "_GUESTO" ) ) .and. (cAlias)->&( cAlias + "_ESTORI" ) == '0' .and. !lReapre
				
				BCL->(dbSetOrder(1))
				if BCL->(msSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
					aFiles := PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI)
				endIf
				
				PLSA500STA("3",(cAlias)->&(cAlias + "_CODOPE"), (cAlias)->&(cAlias + "_CODLDP"), (cAlias)->&(cAlias + "_CODPEG"), (cAlias)->&(cAlias + "_NUMERO"),(cAlias)->&(cAlias + "_ORIMOV"),aFiles,BCL->BCL_FUNGRV,K_Bloqueio,BCL->BCL_TIPGRV,BCL->BCL_ALIAS,getNewPar("MV_PLGUIES","123"))
				
			endIf

			if nRegBCI <> 0
				PLSM190Pro(,,,,,,,,,,,.f.,.t.,nRegBCI,,.F.)//cPerg,lPerg,cCodOpe,cCodLDPDe,cCodLDPAte,cCodPEGDe,cCodPEGAte,cAnoDe,cMesDe,cAnoAte,cMesAte,lJob,lAuto,nRecCor,lChkBaixa, lStTiss
			endIf

			// chama o recalculo de coparticipação
			PLSA500RCB(cAlias,nReg,nOpc,/*aFields*/,.f.)
			
		end transaction
		
	endIf
	
	if existBlock("PL500ACF")
		execBlock("PL500ACF",.f.,.f.,{ BCL->BCL_TIPGUI, cCodOpe + cCodLDP + cCodPEG + cNumero + cOriMov, cAlias } )
	endIf
	
endIf

restArea(aArea)

SET KEY VK_F8 to
SET KEY VK_F9 to
SET KEY VK_F10 to
SET KEY VK_F11 to

return

/*/{Protheus.doc} PlsVlTxAP
Retorna o valor da taxa administrativa apresentada para pagamento (usado no RELACAO do campo BDX_VLTXAP)
@type function
@author tuliocesar
@since 02.12.05
@version 1.0
/*/
function PlsVlTxAP()
local nValor := 0

nValor := BD6->( posicione("BD6",1,xFilial("BD6")+BDX->(BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO),"BD6_VLTXAP") )
	
return(nValor)

/*/{Protheus.doc} PlsVlTxPG
Retorna o valor da taxa administrativa de pagamento (usado no RELACAO do campo BDX_VLTXPG)
@type function
@author PLSTEAM
@since 02.12.05
@version 1.0
/*/
function PlsVlTxPG()
local nValor := 0
	
if xFilial("BD6") + BDX->(BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO + BDX_ORIMOV + BDX_SEQUEN + BDX_CODPAD + BDX_CODPRO) <>;
		BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO)
	
	nValor := BD6->(Posicione("BD6",1,xFilial("BD6")+BDX->(BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO),"BD6_VLTXPG") )
	
else
	nValor := BD6->BD6_VLTXPG
endIf

return(nValor)

/*/{Protheus.doc} PLSA500COC
Muda a cor do browse de criticas de acordo com a linha do browse analise de glosa
@type function
@author plsteam
@since  08.07.05
@version 1.0
/*/
static function PLSA500Coc(oBrwIte,oBrwCri)
local cSta 		:= ""
local nI		:= 0

for nI := 1 to len(oBrwCri:aCols)
	
	cSta := ""
	
	if allTrim(oBrwCri:fieldGet("BDX_ACAO",nI)) == '' .and. ! empty(oBrwCri:fieldGet("BDX_NIVEL",nI)) 
		cSta := "BR_AZUL"
	endIf	
	
	if oBrwCri:fieldGet("BDX_ACAO",nI) == '1'
	
		cSta := "BR_VERMELHO"
		
	elseIf oBrwCri:fieldGet("BDX_ACAO",nI) == '2'

		cSta := "BR_VERDE"
		
	endIf

	oBrwCri:fieldPut("BDX_IMGCRI",cSta,nI)
	
next	

cSta := ""

for nI := 1 to len(oBrwIte:aCols)

	if allTrim(oBrwIte:fieldGet("BDX_ACAO",nI)) == '' 
	
		cSta := "BR_AZUL"
		
	elseIf oBrwIte:fieldGet("BDX_PERGLO",nI) == 100 .and. allTrim(oBrwIte:fieldGet("BDX_ACAO",nI)) == '1'
	
		cSta := "BR_VERMELHO"
	
	elseIf oBrwIte:fieldGet("BDX_VLRGLO",nI) == 0
	
		cSta := "BR_VERDE"
	
	else
	
		cSta := "BR_AMARELO"
	
	endIf
		
	oBrwIte:fieldPut("BDX_IMGSTA",cSta,nI)
	
next

return

/*/{Protheus.doc} PLSA500COR
Muda a cor do browse de acordo com a linha do browse e críticas com analise
@type function
@author plsteam
@since  13.06.00
@Update 19.11.14
@version 2.0
/*/
static function PLSA500Cor(nlinha,aHeaderEd,aColsEd,oBrwIte,oBrwCri)
local nPos		:= plRetPos("BDX_IMGSTA",aHeaderEd)
local cSta 		:= ""
local nI		:= 0
local nVlrGlo   := 0
local nVlrBase	:= 0
local nPerGlo 	:= 0
local nPerGtx	:= 0
local nVlrBaseTx:= 0
local nVlrTxPgAP:= 0
local lExistCrt20:= .F.

//Glosado integral
if M->BDX_PERGLO == 100 .and. allTrim(M->BDX_ACAO) == "1"

	cSta := "BR_VERMELHO"

//Reconsiderado	
elseIf M->BDX_VLRGLO == 0

	cSta := "BR_VERDE"
	
//Sem analise
elseIf allTrim(M->BDX_ACAO) == ""
	cSta := "BR_AZUL"
	
//Glosado Parcialmente	
else	
	cSta := "BR_AMARELO"
endIf

if ! empty(cSta)
	aColsEd[nlinha,nPos] := cSta
endIf

M->BDX_CRIANA := '1'

for nI := 1 to len(oBrwCri:aCols)
	
	if oBrwCri:fieldGet("BDX_SEQUEN",nI) == oBrwIte:fieldGet("BDX_SEQUEN",nlinha) 
		
		if M->BDX_ACAO == '1'

			cSta := "BR_VERMELHO"
	
		elseIf M->BDX_ACAO == '2'

			cSta := "BR_VERDE"

		else

			cSta := "BR_AZUL"

		endIf

		//Bloco para preencher grid de críticas _Inicio
		nPerGlo := M->BDX_PERGLO
		nPerGtx := M->BDX_PERGTX
		oBrwCri:fieldPut("BDX_PERGLO", nPerGlo, nI)
		oBrwCri:fieldPut("BDX_CRIANA", "1", nI)
		oBrwCri:fieldPut("BDX_ACAO",M->BDX_ACAO,nI)
		oBrwCri:fieldPut("BDX_ACAOTX",M->BDX_ACAOTX,nI)
		oBrwCri:fieldPut("BDX_IMGCRI",cSta,nI)

		nVlrBase := oBrwCri:fieldGet("BDX_VLRMAN", nI) + oBrwCri:fieldGet("BDX_VLRGLO", nI)

		if M->BDX_ACAO == '2'
			nVlrGlo := 0
		else
			nVlrGlo := (nVlrBase * nPerGlo ) / 100					
		endIf
		nVlrBase -= nVlrGlo
		oBrwCri:fieldPut("BDX_VLRGLO", nVlrGlo, nI)
		oBrwCri:fieldPut("BDX_VLRMAN", nVlrBase, nI)

		if oBrwCri:fieldGet("BDX_TIPGLO", nI) == "3"
			lExistCrt20 := .T.
		endif

		nVlrBase := oBrwCri:fieldGet("BDX_VLRMAN", nI) + oBrwCri:fieldGet("BDX_VLRGLO", nI)

		If !lExistCrt20
			nVlrBaseTx 	:= oBrwCri:fieldGet("BDX_VLTXPG", nI) + oBrwCri:fieldGet("BDX_VLRGTX", nI)
		else
			nVlrBaseTx 	:= oBrwCri:fieldGet("BDX_VLTXPG", nI)
		EndIf

		If oBrwCri:fieldGet("BDX_VLTXAP", nI) == 0 .OR. lExistCrt20
			nVlrTxPgAP := oBrwCri:fieldGet("BDX_VLTXPG", nI)
		else
			nVlrTxPgAP := oBrwCri:fieldGet("BDX_VLTXAP", nI)
		endIf

		if oBrwCri:fieldGet("BDX_ACAO", nI) == "1"
			oBrwCri:fieldPut("BDX_VLTXPG", (nVlrTxPgAP * (100 - nPerGtx) / 100), nI)
			oBrwCri:fieldPut("BDX_VLRGTX", (nVlrTxPgAP * nPerGtx / 100), nI)
		Elseif !lExistCrt20
				oBrwCri:fieldPut("BDX_VLRGTX", 0, nI)
				oBrwCri:fieldPut("BDX_VLTXPG", nVlrBaseTx, nI)
				oBrwCri:fieldPut("BDX_VLTXPG", iif(nVlrTxPgAP>0 .and. oBrwCri:fieldGet("BDX_VLTXPG", nI)==0 .and. oBrwCri:fieldGet("BDX_ACAOTX", nI)=="2",nVlrTxPgAP, oBrwCri:fieldGet("BDX_VLTXPG", nI)), nI)
		Endif

		nVlrBase := oBrwCri:fieldGet("BDX_VLTXPG", nI) + oBrwCri:fieldGet("BDX_VLRGTX", nI)

		if M->BDX_ACAOTX == '2'
								
			If oBrwCri:fieldGet("BDX_VLRGTX", nI) > 0
				nVlrBase := oBrwCri:fieldGet("BDX_VLTXPG", nI) + oBrwCri:fieldGet("BDX_VLRGTX", nI)
				nVlrGlo := 0
			else
				nVlrGlo := 0
			EndIf
		else	
			nVlrGlo := (nVlrBase * nPerGtx ) / 100
			nVlrBase -= nVlrGlo
		endIf	

		oBrwCri:fieldPut("BDX_VLTXPG", nVlrBase, nI)
		oBrwCri:fieldPut("BDX_VLRGTX", nVlrGlo, nI)
		oBrwCri:fieldPut("BDX_VLRPAG", oBrwCri:fieldGet("BDX_VLRMAN", nI) + oBrwCri:fieldGet("BDX_VLTXPG", nI) , nI)
		//Bloco para preencher grid de críticas - Fim

	endIf
	
next nI

return

/*/{Protheus.doc} PLSA500WHE
Exibe os detalhes da glosa
@type function
@author plsteam
@since  13.06.00
@version 1.0
/*/
function PLSA500WHE(cTipo)
local lRet

lRet := M->BDX_ACAO == "2" .or. M->BDX_TIPGLO == "2"

return(lRet)

/*/{Protheus.doc} PLSA500RFS
Retorno de fase
@type function
@author plsteam
@since  13.06.00
@version 1.0
/*/
function PLSA500RFS(cAlias,nReg,nOpc,cNil,lAllPeg,lWeb,lCtb,lMsg)
local aArea		:= getArea() 
local aAreaBDH	:= {} 
local cFase     := &(cAlias+"->"+cAlias+"_FASE")
local cSituac   := &(cAlias+"->"+cAlias+"_SITUAC")
local dDatPro   := &(cAlias+"->"+cAlias+"_DATPRO")
local cCodOpe   := &(cAlias+"->"+cAlias+"_CODOPE")
local cCodLDP   := &(cAlias+"->"+cAlias+"_CODLDP")
local cCodPEG   := &(cAlias+"->"+cAlias+"_CODPEG")
local cNumero   := &(cAlias+"->"+cAlias+"_NUMERO")
local cOriMov   := &(cAlias+"->"+cAlias+"_ORIMOV")
local cChaveBDH := ""
local cChave	:= ""
local nRegBCI   := BCI->(recno())
local lRet		:= .t.
Local dDatCtbChk	:= StoD("")

default lAllPeg := .f.
default lWeb	:= .f.  //Se Mudança de Fase pela Digitação de Guias pelo Portal Prestador
default lCtb	:= .t.	
default lMsg 	:= .t.

if ! lAllPeg
	
	dDatCtbChk := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, cNumero, .T.)
	//se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	lRet := PLVLDBLQCO(dDatCtbChk, {"PLS005"}, .t.)
	
	//Se Ok, verifica se não há contabilização do custo, pois isso também deve impedir a ação
	If lRet
		dDatCtbChk := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, cNumero, .F.)
		lRet := PLVLDBLQCO(dDatCtbChk, {"PLS005"}, .t.)
	EndIf
	
endIf

if lWeb .or. lRet 

	BCL->(DbSetOrder(1))
	BCL->(MsSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
	
	if PLSVERCCBG(&(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC") + &(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),&(cAlias+"->"+cAlias+"_SEQPF"))
		
		if ! lAllPeg
			Help("",1,"PLSA500001")
		endIf
		
		return(.f.)
	endIf
	
	__lManunt := .t.
	
	//Verifica se é permitido retorno de fase Guia de reembolso
	if cFase <> '4' .and. &(cAlias)->(fieldPos(cAlias+"_TIPGUI")) > 0 .and. &(cAlias+"->"+cAlias+"_TIPGUI") == "04"
	
		if ! lAllPeg
			Help( ,, 'HELP',,"Nao é permitido retorno de fase de Guia de Reembolso, já faturada!", 1, 0)
		endIf
			
		return(.f.)
	endIf
	
	//Veririfica se registro a valida para mudanca de fase
	if ! ( cFase $ "2,3,5" .and. cSituac $ "1" ) 
		
		if ! lAllPeg .and. !isPLSA600()
			Help(NIL, NIL, "PLSA500FS2", NIL, "Não é possível retornar a fase de guias com fase EM DIGITAÇÃO", 1, 0, NIL, NIL, NIL, NIL, NIL, {"a opção de retorno de fase somente pode ser utilizada em guias com fase PRONTA ou CONFERENCIA"})
		endIf
		
		return(.f.)
	endIf
	
	if &(cAlias)->(fieldPos(cAlias+"_SEQEST")) > 0 .and. !empty( &(cAlias+"->"+cAlias+"_SEQEST") )
		
		if ! lAllPeg
			Help("",1,"PLSA500024")
		endIf
		
		return(.f.)
	endIf
	
	if &(cAlias)->(fieldPos(cAlias+"_PODRFS")) > 0 .and. &(cAlias+"->"+cAlias+"_PODRFS") == '0'
		
		if ! lAllPeg
			Help("",1,"PLSA500033")
		endIf
		
		return(.f.)
	endIf

	//Guia de Recurso de Glosa, gerada pela Análise de Recurso de Glosa (PLSRECGLO3), não pode ter fase retornada
	if &(cAlias+"->"+cAlias+"_TIPGUI") == G_REC_GLOSA .and. !PlGuiRcGl3(cCodLDP, cCodPEG, cNumero)
		if ! lAllPeg
			Help(NIL, NIL, STR0290, NIL, STR0352, 1, 0, NIL, NIL, NIL, NIL, NIL, {""}) //Atenção / A guia não pode ter sua fase retornada, por ser originária do Recurso de Glosa
		endIf
		return(.f.)
	endIf	
	
	//Confirma a mudanca de fase
	if cFase $ "2,3,5" .and. iIf(lAllPeg .or. lWeb .or. isPLSA600(),.t.,msgYesNo(STR0057)) //"Confirma o retorno de fase para 'Digitacao'"
	
		//Ponto de Entrada antes do retorno de fase
		if existBlock("PLS500ARF")
			
			lRet := execBlock("PLS500ARF",.f.,.f.,{BCL->BCL_TIPGUI,cAlias,cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov})
			
			if !lRet
				return(.t.)
			endIf
			
		endIf
		
		//verifica se ja existe movimento contabil e exclui
		if lCtb
		
			lCtb := .f.
			
			cChave 	:= (cAlias)->&( cAlias + "_CODOPE+" + cAlias + "_CODLDP+" + cAlias + "_CODPEG" )
			
			if ! lAllPeg
				cChave 	+= (cAlias)->&( cAlias + "_NUMERO+" + cAlias + "_ORIMOV" )
			endIf	
	
			//exclui movimento contabil
			lRet := PLSEXMCTB("A", cChave, !lMsg )
			
		endIf
		
		//Fase
		PLSXMUDFAS(cAlias,"3","",BCL->BCL_TIPGUI,ctod(""),.f.,"1",nil,nil,iIf(lAllPeg,.f.,.t.))
		
		BDU->(dbSetOrder(2))
		while BDU->(msSeek(xFilial("BDU")+cCodOpe+cCodLDP+cCodPEG+cNumero+cOriMov))
			BDU->(recLock("BDU",.f.))
			BDU->(dbDelete())
			BDU->(msUnLock())
		endDo
		
		BDX->(dbSetOrder(3))
		while BDX->(msSeek(xFilial("BDX")+cCodOpe+cCodLDP+cCodPEG+cNumero+cOriMov))
			BDX->(recLock("BDX",.f.))
			BDX->(dbDelete())
			BDX->(msUnLock())
		endDo
		
		cChaveBDH := &(cAlias + "->" + cAlias + "_OPEUSR") + &(cAlias + "->" + cAlias + "_CODEMP") +;
					 &(cAlias + "->" + cAlias + "_MATRIC") + &(cAlias + "->" + cAlias + "_TIPREG") +;
					 &(cAlias + "->" + cAlias + "_ANOPAG") + &(cAlias + "->" + cAlias + "_MESPAG") +;
					 &(cAlias + "->" + cAlias + "_SEQPF")
		
		aAreaBDH :=  BDH->(getArea())
		
		BDH->(dbSetOrder(3))
		if BDH->(msSeek(xFilial("BDH")+cChaveBDH))
			
			//Se esta consolidado exclui todos as ligacoes de eventos relativos a esta consolidacao
			PLSM180Del()
			
			//Exclui a consolidacao referente a guia atual e a outras que estajam ligadas
			BDH->(recLock("BDH",.f.)) 
				BDH->(DbDelete())
			BDH->(msUnLock())
			
		endIf
		
		BDH->(restArea(aAreaBDH))
		
		if existBlock("PLS500RF")
			execBlock("PLS500RF",.f.,.f.,{BCL->BCL_TIPGUI,cAlias,cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov})
		endIf
		
	endIf
	
	restArea(aArea)
	
	if nRegBCI <> 0 .and. ! lAllPeg
		PLSM190Pro(,,,,,,,,,,,.f.,.t.,nRegBCI)
	endIf
	
endIf

return(lRet)

/*/{Protheus.doc} PLSA500GVR
Gatilho do campo BD6_VLRMAN
@type function
@author plsteam
@since  15.03.2003
@version 1.0
/*/
function PLSA500GVR
return(.t.)

/*/{Protheus.doc} PLSA500VDD

@type function
@author plsteam
@since  15.03.2003
@version 1.0
/*/
function PLSA500VDD
return(.t.)


/*/{Protheus.doc} PLSA500PES
Pesquisa um guia dentro de um PEG
@type function
@author plsteam
@since   18.09.2003
@version 1.0
/*/
function PLSA500PES(cAlias,nReg,nOpc)
local oDlg
local cCadastro := STR0058                                                           //"Pesquisar uma Guia"
local bOK       := {|| oDlg:end() }
local bCancel   := {|| oDlg:end() }
local cNumGuia	:= Space( TamSX3("BE4_NUMERO")[1] )
local cNomUsr   := Space( TamSX3("BA1_NOMUSR")[1] )
local cNumImp	:= Space( TamSX3("BE4_NUMIMP")[1] )
local cNuNuAut	:= Space( TamSX3("BEA_ANOAUT")[1]+TamSX3("BEA_MESAUT")[1]+TamSX3("BEA_NUMAUT")[1] )
local _cSenha   := Space(len(&(cAlias+"->"+cAlias+"_SENHA")))
local oPesquisa
local oNil
local cNil := ""
local oFolder

//Define dialogo

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,008.3 to 023,060 of GetWndDefault()
odlg:nwidth    := 603
odlg:ntop      := 217
odlg:nleft     := 100

@ 034,003 FOLDER oFolder size 290,069 of oDlg PIXEL PROMPTS  STR0059+" <F5>",; //"Numero da Guia"
STR0060+" <F6>",; //"Nome do usuario"
STR0061+" <F7>",; //"Senha da Guia"
STR0062+" <F8>",; //"Numero Impresso"
STR0063+" <F12>" //"Nr Autor./Liber."
ofolder:nwidth := 580

//Configura Keys

setKey(VK_F5, {|| oFolder:SetOption(1) })
setKey(VK_F6, {|| oFolder:SetOption(2) })
setKey(VK_F7, {|| oFolder:SetOption(3) })
setKey(VK_F8, {|| oFolder:SetOption(4) })
setKey(VK_F12,{|| oFolder:SetOption(5) })

//Folder Numero da Movimentacao

@ 015,005 say STR0064 size 100,010 PIXEL of oFolder:aDialogs[1] //"Numero da Guia      :"
@ 013,075 MSGET oPes01 VAR cNumGuia PICTURE "@!" VALID PLSA500LOC("1",cAlias,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,cNumGuia,nil) size 035,010 PIXEL of oFolder:aDialogs[1]

//Folder Numero da Movimentacao

@ 015,005 say STR0065 size 100,010 PIXEL of oFolder:aDialogs[2] //"Nome do Usuario     :"
@ 013,075 MSGET oPes01 VAR cNomUsr PICTURE "@!" VALID PLSA500LOC("2",cAlias,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,nil,cNomUsr,nil) size 100,010 PIXEL of oFolder:aDialogs[2]

//Folder Senha

@ 015,005 say STR0066 size 100,010 PIXEL of oFolder:aDialogs[3] //"Senha               :"
@ 003,075 MSGET oPes01 VAR _cSenha  PICTURE "@!" VALID PLSA500LOC("3",cAlias,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,nil,nil,_cSenha) size 035,010 PIXEL of oFolder:aDialogs[3]

//Folder Numero do Impresso

@ 015,005  say STR0067 size 100,010 PIXEL of oFolder:aDialogs[4] //"Numero do Impresso  :"
@ 013,075 MSGET oPes01 VAR cNumImp  PICTURE "@!" VALID PLSA500LOC("4",cAlias,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,nil,nil,nil,cNumImp) size 070,010 PIXEL of oFolder:aDialogs[4]

//Pesquisa de autorizacao

@ 015,005 say 	STR0068 size 100,010 PIXEL of oFolder:aDialogs[5] //"Nr Autorizacao/Liberacao :"
@ 013,075 MSGET oPes12 VAR cNuNuAut PICTURE "@!"  VALID PLSA500LOC("5",cAlias,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG,nil,nil,nil,cNuNuAut) size 100,010 PIXEL of oFolder:aDialogs[5]

//Ativa dialogo

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.f.,{}) })

//Desativa keys

SET KEY VK_F5 to
SET KEY VK_F6 to
SET KEY VK_F7 to
SET KEY VK_F8 to
SET KEY VK_F12 to

return

/*/{Protheus.doc} PLSA500LOC
Localiza o PEG
@type function
@author plsteam
@since   15.08.2002
@version 1.0
/*/
static function PLSA500LOC(cTipo,cAlias,cCodOpe,cCodLDP,cCodPEG,cNumGuia,cNomUsr,_cSenha,cNumImp)
local lRet    := .t.
local cSQL    := ""
local cTipGui := ""
local cNumero := ""

//numero da guia

if     cTipo == "1" .and. ! empty(cNumGuia)
	if cTipo == "1"
		cNumGuia := StrZero(Val(cNumGuia),len(cNumGuia))
	endIf
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	lRet := msSeek(xFilial(cAlias)+cCodOpe+cCodLDP+cCodPeg+cNumGuia)
	
	if ! lRet
		Help("",1,"PLSA500LOC")
	endIf
	
	//nome do usuario
	
elseIf cTipo == "2" .and. ! empty(cNomUsr)
	
	cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName(cAlias)+" WHERE "
	cSQL += cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "
	cSQL += cAlias+"_CODOPE = '"+cCodOpe+"' AND "
	cSQL += cAlias+"_CODLDP = '"+cCodLDP+"' AND "
	cSQL += cAlias+"_CODPEG = '"+cCodPeg+"' AND "
	cSQL += cAlias+"_NOMUSR LIKE '"+allTrim(cNomUsr)+"%' AND "
	cSQL += "D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSQL)),"PLSA500LOC",.f.,.t.)

	if ! PLSA500LOC->(eof())
		lRet := .t.
		DbSelectArea(cAlias)
		dbGoto(PLSA500LOC->REG)
	else
		lRet := .f.
		Help("",1,"PLSA500LOC")
	endIf
	
	PLSA500LOC->(DbCloseArea())
	
	//senha
	
elseIf cTipo == "3" .and. ! empty(_cSenha)

	cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName(cAlias)+" WHERE "
	cSQL += cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "
	cSQL += cAlias+"_CODOPE = '"+cCodOpe+"' AND "
	cSQL += cAlias+"_CODLDP = '"+cCodLDP+"' AND "
	cSQL += cAlias+"_CODPEG = '"+cCodPeg+"' AND "
	cSQL += "( "+cAlias+"_SENHA = '"+_cSenha+"' OR "+cAlias+"_NRAOPE = '"+_cSenha+"' ) AND "
	cSQL += "D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSQL)),"PLSA500LOC",.f.,.t.)

	if ! PLSA500LOC->(eof())
		lRet := .t.
		DbSelectArea(cAlias)
		dbGoto(PLSA500LOC->REG)
	else
		lRet := .f.
		Help("",1,"PLSA500LOC")
	endIf
	
	PLSA500LOC->(DbCloseArea())
	
	//numero impresso
	
elseIf cTipo == "4" .and. ! empty(cNumImp)
	cSQL := "SELECT R_E_C_N_O_ AS REG FROM "+RetSQLName(cAlias)+" WHERE "
	cSQL += cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "
	cSQL += cAlias+"_CODOPE = '"+cCodOpe+"' AND "
	cSQL += cAlias+"_CODLDP = '"+cCodLDP+"' AND "
	cSQL += cAlias+"_CODPEG = '"+cCodPeg+"' AND "
	cSQL += " ( "+cAlias+"_NUMIMP = '"+StrZero(val(cNumImp),len(cNumImp))
	cSQL +=   "' OR "+cAlias+"_NUMIMP = '"+cNumImp+"' OR "+cAlias+"_NUMIMP LIKE '%"+allTrim(cNumImp)+"%' ) AND "
	cSQL += "D_E_L_E_T_ = ' ' "
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSQL)),"PLSA500LOC",.f.,.t.)

	if ! PLSA500LOC->(eof())
		lRet := .t.
		DbSelectArea(cAlias)
		dbGoto(PLSA500LOC->REG)
	else
		lRet := .f.
		Help("",1,"PLSA500LOC")
	endIf
	
	PLSA500LOC->(DbCloseArea())
	
	//numero impresso
	
elseIf cTipo == "5" .and. ! empty(cNumImp)
	
	BEA->(dbSetOrder(1)) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT
	lRet := BEA->(msSeek( xFilial("BEA")+cCodOpe+allTrim(cNumImp)))
	if lRet
		cCodLDP := BEA->BEA_CODLDP
		cCodPEG := BEA->BEA_CODPEG
		cTipGui := BEA->BEA_TIPGUI
		cNumero := BEA->BEA_NUMGUI
		
		DbSelectArea(cAlias)
		dbSetOrder(1)
		if !msSeek( xFilial(cAlias)+cCodOpe+cCodLDP+cCodPEG+cNumero )
			Help("",1,"PLSA500LOC")
			lRet := .f.
		endIf
	else
		Help("",1,"PLSA500LOC")
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSA500FAM

@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500FAM(cAlias,nReg,nOpc)
local cMatricUsr := ""
local nRecBA1    := BA1->(recno())
local nOrdBA1    := BA1->(IndexOrd())
local nRecBA3    := BA3->(recno())
local nOrdBA3    := BA3->(IndexOrd())
local bRest      := { || BA1->(dbSetOrder(nOrdBA1)), BA1->(dbGoto(nRecBA1)), BA3->(dbSetOrder(nOrdBA3)), BA3->(dbGoto(nRecBA3)) }

if Type("M->"+cAlias+"_USUARI") <> "C"
	cMatricUsr := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
else
	cMatricUsr := &("M->"+cAlias+"_USUARI")
endIf

BA1->(dbSetOrder(2))
if BA1->(msSeek(xFilial("BA1")+cMatricUsr))
	PLSA260MOV("BA1",BA1->(recno()),K_Visualizar)
else
	Help("",1,"PLSA500007")
endIf

Eval(bRest)

return

/*/{Protheus.doc} PLSA500UOI

@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500UOI(cAlias)
local aRetIntEve := PLSA235(.f.,"",.t.)
local dDatPro    := &("M->"+cAlias+"_DATPRO")

if empty(dDatPro)
	dDatPro := dDataBase
endIf

if aRetIntEve[1]
	&("M->"+cAlias+"_USUARI") := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	
	PLSA090USR(&("M->"+cAlias+"_USUARI"),dDatPro,&("M->"+cAlias+"_HORPRO"),cAlias)
	lRefresh := .t.
else
	if len(aRetIntEve) >= 2 .and. len(aRetIntEve[2]) > 0
		PLSMOVCRI("2",{},aRetIntEve[2])
	endIf
endIf

return

/*/{Protheus.doc} PLSA500RPG
Revaloriza o pagamento para uma guia ja faturada.
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500RPG(cAlias,nReg,nOpc,aFileds,lMsg,nDifUs,nVlrDifUs,lAllPeg,lCtb)
local cChaveGui  := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local cChave	 := ""
local cLocalExec := "2" //processamento de contas
local aRet		 := {}
local lRet       := .f.
local lExec		 := .t.
local lExsRC	 := .f.
local aAreaBDH	:= {} 
local cFase     := &(cAlias+"->"+cAlias+"_FASE")
local cSituac   := &(cAlias+"->"+cAlias+"_SITUAC")
local dDatPro   := &(cAlias+"->"+cAlias+"_DATPRO")
local cCodOpe   := &(cAlias+"->"+cAlias+"_CODOPE")
local cCodLDP   := &(cAlias+"->"+cAlias+"_CODLDP")
local cCodPEG   := &(cAlias+"->"+cAlias+"_CODPEG")
local cNumero   := &(cAlias+"->"+cAlias+"_NUMERO")
local cOriMov   := &(cAlias+"->"+cAlias+"_ORIMOV")
local cChaveBDH := ""
Local dDatCtbChk	:= StoD("")

default nDifUs   := 0
default nVlrDifUs:= 0
default lMsg     := .t.
default lAllPeg  := .f.
default lCtb	 := .t.
default aFileds  := {}

dDatCtbChk := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, cNumero, .F.)

if PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lMsg) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	
	if existBlock("PLSREVAL")
		lExec := execBlock("PLSREVAL",.f.,.f.,{'2',cChaveGui,cAlias})
	endIf
	
	if lExec .and. &(cAlias+"->"+cAlias+"_FASE") <> "3" .Or. &(cAlias+"->"+cAlias+"_SITUAC") <> "1"
		
		if lMsg
			Help("",1,"PLSA500008")
		endIf
		
	else
		
		//Tenho que verificar se na BD7 tenho algum procedimento com redução de custo aplicado, pois hoje, o sistema revalora, mas não apaga BD7_REDCUS
		lExsRC := iIf ( ! IsInCallStack('PLSA175RGR'), PLSVRDRPY(cChaveGui,"1", .f.), .f.)
		
		//Pede confirmacao
		if lExec .and. ! lMsg .Or. msgYesNo(STR0070) //"Deseja revalorizar pagamento ?"
			
			if lExsRC
			
				cMsg := STR0285 + CRLF
				cMsg += STR0338
				cMsg += STR0339 + CRLF
				cMsg += STR0340
				
				if !(msgYesNo(cMsg))
					return (lRet := .f.)
				endIf
				
			endIf
			
			//A rotina somente pode ser executada se a guia ja estiver faturada
			if findFunction("PLS720ZCB")
				PLS720ZCB("2",cChaveGui,cAlias)
			endIf
			
			//verifica se ja existe movimento contabil e exclui
			if lCtb
				
				lCtb := .f.
				
				cChave := (cAlias)->&( cAlias + "_CODOPE+" + cAlias + "_CODLDP+" + cAlias + "_CODPEG" )
				
				if ! lAllPeg
					cChave += (cAlias)->&( cAlias + "_NUMERO+" + cAlias + "_ORIMOV" )
				endIf	
		
				//exclui movimento contabil
				lRet := PLSEXMCTB("A", cChave,!lMsg )
				
			endIf	
			
			aRet := PLSA720EVE(BCL->BCL_TIPGUI,BCL->BCL_GUIREL,lMsg,;
								&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_ANOPAG"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_MESPAG"),;
								BCL->BCL_ALIAS,cChaveGui,{},cLocalExec,{},.f.,.t.,nil,nil,.t.,nDifUs,nVlrDifUs)
			
			if existBlock("PLSREVPC")
				execBlock("PLSREVPC",.f.,.f.,{BCL->BCL_TIPGUI,cLocalExec,.t.,.f.})
			endIf
			
			//Atualizo o BD7_RedCus para vazio, para que possa ser reduzido novamente o seu custo
			PLSVRDRPY(cChaveGui, "2", IsInCallStack('PLSA175RGR'))
			PLSGRGLREV(aRet[3], cChaveGui)
			
			if aRet[1]
				
				//atualiza totais do peg
				PLPEGTOT()

				lRet := .t.
				
				if lMsg
					msgInfo(STR0071) //"Revalorizacao de pagamento concluida."
				endIf
				
			elseif !(GetNewPar("MV_PLREVGL", .F.))
				//se a revaloração der erro, e o cliente optou por o usuário realizar a mudança de fase da guia novamente, roda o retorno de fase aqui
				//pra todos os eventos e composições ficarem com a mesma fase
				
				//Ponto de Entrada antes do retorno de fase
				if existBlock("PLS500ARF")
					
					lRet := execBlock("PLS500ARF",.f.,.f.,{BCL->BCL_TIPGUI,cAlias,cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov})
					
					if !lRet
						return(.t.)
					endIf
					
				endIf
				
				//verifica se ja existe movimento contabil e exclui
				if lCtb
				
					lCtb := .f.
					
					cChave 	:= (cAlias)->&( cAlias + "_CODOPE+" + cAlias + "_CODLDP+" + cAlias + "_CODPEG" )
					
					if ! lAllPeg
						cChave 	+= (cAlias)->&( cAlias + "_NUMERO+" + cAlias + "_ORIMOV" )
					endIf	
			
					//exclui movimento contabil
					lRet := PLSEXMCTB("A", cChave )
					
				endIf
				
				//Fase
				PLSXMUDFAS(cAlias,"3","",BCL->BCL_TIPGUI,ctod(""),.f.,"1",nil,nil,iIf(lAllPeg,.f.,.t.))
				
				BDU->(dbSetOrder(2))
				while BDU->(msSeek(xFilial("BDU")+cCodOpe+cCodLDP+cCodPEG+cNumero+cOriMov))
					BDU->(recLock("BDU",.f.))
					BDU->(dbDelete())
					BDU->(msUnLock())
				endDo
				
				BDX->(dbSetOrder(3))
				while BDX->(msSeek(xFilial("BDX")+cCodOpe+cCodLDP+cCodPEG+cNumero+cOriMov))
					BDX->(recLock("BDX",.f.))
					BDX->(dbDelete())
					BDX->(msUnLock())
				endDo
				
				cChaveBDH := &(cAlias + "->" + cAlias + "_OPEUSR") + &(cAlias + "->" + cAlias + "_CODEMP") +;
							 &(cAlias + "->" + cAlias + "_MATRIC") + &(cAlias + "->" + cAlias + "_TIPREG") +;
							 &(cAlias + "->" + cAlias + "_ANOPAG") + &(cAlias + "->" + cAlias + "_MESPAG") +;
							 &(cAlias + "->" + cAlias + "_SEQPF")
				
				aAreaBDH :=  BDH->(getArea())
				
				BDH->(dbSetOrder(3))
				if BDH->(msSeek(xFilial("BDH")+cChaveBDH))
					
					//Se esta consolidado exclui todos as ligacoes de eventos relativos a esta consolidacao
					PLSM180Del()
					
					//Exclui a consolidacao referente a guia atual e a outras que estajam ligadas
					BDH->(recLock("BDH",.f.)) 
						BDH->(DbDelete())
					BDH->(msUnLock())
					
				endIf
				
				BDH->(restArea(aAreaBDH))
				
				if existBlock("PLS500RF")
					execBlock("PLS500RF",.f.,.f.,{BCL->BCL_TIPGUI,cAlias,cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov})
				endIf

				iF lMsg
      				msgStop("Ocorreu um erro na revaloração, é necessário mudar a fase da guia novamente")
      			EndIf

			endIf
			
		endIf
		
	endIf
	
else
	
	lRet := .f.
	
endIf

return(lRet)

/*/{Protheus.doc} PLSA500RCB
Revaloriza a cobrança para uma guia ja paga
@type function
@author PLS TEAM
@since 13.05.2005
@version 1.0
/*/
function PLSA500RCB(cAlias,nReg,nOpc,aFields,lMsg,lAnaGloCP,lAllPeg,lCtb,aSequen)
local cChaveGui  := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local cChave	 := ""
local cLocalExec := "2" //processamento de contas
local aRet       := {}
local lRet 		 := .f.
local lExec		 := .t.
local cChaveLib  := ""
local cNumLib	 := ""
local lGuiHoRe   := .f.
Local nIz := 1
Local dDatCtbChk := StoD("")

default lMsg     := .t.
default lAllPeg  := .f.
default lCtb	 := .t.
default aFields  := {}
default aSequen	 := {}

dDatCtbChk := PLRtDtCTB(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO"), .F.)
//se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
if PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lMsg)
	
	if existBlock("PLSREVAL")
		lExec := execBlock("PLSREVAL",.f.,.f.,{'1',cChaveGui,cAlias})
	endIf
	
	if 	lExec .and. ! &(cAlias+"->"+cAlias+"_FASE") $ "3,4" .Or. &(cAlias+"->"+cAlias+"_SITUAC") <> "1" .or. PLSVERCCBG(&(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),&(cAlias+"->"+cAlias+"_SEQPF"))
		
		if lMsg
			Help("",1,"PLSA500009")
		endIf
		
	else
		
		//Pede confirmacao
		if lExec .and. ! lMsg .or. msgYesNo(STR0072) //"Deseja revalorizar cobrança ?"
			
			//Monta o numero da liberacao com base na guia
			if cAlias == 'BE4'
				lGuiHoRe := .t.
			endIf
			
			if (cAlias)->(fieldPos(cAlias+"_NRLBOR")) > 0
				cNumLib := (cAlias)->&(cAlias+"_NRLBOR")
			endIf

			//Retorna chave da liberacao
			cChaveLib := PLSCTLIB( cNumLib, lGuiHoRe )
			
			//verifica se ja existe movimento contabil e exclui
			if lCtb
				
				lCtb := .f.
				
				cChave := (cAlias)->&( cAlias + "_CODOPE+" + cAlias + "_CODLDP+" + cAlias + "_CODPEG" )
			
				if !lAllPeg
					cChave += (cAlias)->&( cAlias + "_NUMERO+" + cAlias + "_ORIMOV" )
				endIf	
		
				//exclui movimento contabil
				lRet := PLSEXMCTB("A", cChave,!lMsg )
				
			endIf	
			
			if empty(asequen)

				PLS720ZCB("1",cChaveGui,cAlias)

				aRet := PLSA720EVE(	BCL->BCL_TIPGUI,BCL->BCL_GUIREL,lMsg,;
									&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_ANOPAG"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_MESPAG"),;
									BCL->BCL_ALIAS,cChaveGui,{},cLocalExec,{},.t.,.f.,nil,nil,.t.,,,,,,,,cChaveLib,,,,lAnaGloCP)
			else

				for nIz := 1 To Len(aSequen)
			
					BD6->(dbGoTo(aSequen[nIz]))
			
					PLS720ZCB("1",cChaveGui,cAlias,.T.)
					
					aRet := PLSA720EVE(	BCL->BCL_TIPGUI,BCL->BCL_GUIREL,lMsg,;
										&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_ANOPAG"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_MESPAG"),;
										BCL->BCL_ALIAS,cChaveGui,{},cLocalExec,{},.t.,.f.,.T. /*Indica que só aplica no BD6 posicionado*/,;
										nil,.t.,,,,,,,,cChaveLib,,,,lAnaGloCP)				
				
				next

			endIf
			if existBlock("PLSREVPC")
				execBlock("PLSREVPC",.f.,.f.,{BCL->BCL_TIPGUI,cLocalExec,.f.,.t.})
			endIf
			
			if aRet[1]

				//atualiza totais do peg
				PLPEGTOT()
				
				lRet := .t.

				if lMsg
					msgInfo(STR0073) //"Revalorizacao de cobrança concluida."
				endIf

			endIf
			
		endIf
		
	endIf
	
else
	
	lRet := .f.
	
endIf

return(lRet)

/*/{Protheus.doc} ValidaTabelaBW

@type function
@author plsteam
@since   16.05.2005
@version 1.0
/*/
static function ValidaTabelaBW(cMotBlo,cDesBlo)
local lRet := .f.

SX5->(dbSetOrder(1))
lRet := SX5->(msSeek(xFilial("SX5")+"BW"+cMotBlo))

if lRet
	cDesBlo := X5Descri()
else
	Help("",1,"recno")
endIf

return(lRet)

/*/{Protheus.doc} PLSA500VAG
Verifica se todos os itens criticados foram analisados
@type function
@author plsteam
@since   16.05.2005
@version 1.0
/*/
function PLSA500VAG(oBrwIte, oBrwCri, lAllOk)
local nFor		:= 0
local lOK 		:= .t.
local nPosAca  	:= plRetPos("BDX_GLACAO",oBrwCri:aHeader)
local nPosSeq	:= plRetPos("BDX_SEQUEN",oBrwCri:aHeader)
local nPosNiv	:= plRetPos("BDX_NIVEL" ,oBrwCri:aHeader)
local cBlqScan	:= '{|x| empty(x[nPosAca])  .and. x[nPosSeq]==oBrwIte:fieldGet("BDX_SEQUEN",nFor) .and. !empty(x[nPosNiv]) }'
local nOkAn		:= 0

default lAllOk	:= .t.

lAllOk := .t.

//Macro conforme a existencia de campos
if nPosAca == 0
	cBlqScan := '{|x| x[nPosSeq]==oBrwIte:fieldGet("BDX_SEQUEN",nFor) .and. !empty(x[nPosNiv]) }'
endIf

if nPosSeq == 0
	cBlqScan := '{|x| !empty(x[nPosNiv]) }'
endIf

if nPosNiv == 0
	cBlqScan := '{|x| }'
endIf

//Validacao
if nPosSeq > 0

	for nFor := 1 to len(oBrwIte:aCols)
	
		lOK := .t.
	
		if empty(oBrwIte:fieldGet("BDX_ACAO",nFor))
			
			if aScan(oBrwCri:aCols, {|x| x[nPosSeq] == oBrwIte:fieldGet("BDX_SEQUEN",nFor) }) > 0
			
				lOK := aScan( oBrwCri:aCols, &cBlqScan ) == 0
			
			else
			
				lOK := aScan( oBrwCri:aColsNoFil, &cBlqScan ) == 0
			
			endIf
			
		endIf
		
		if !lOK
			lAllOk := .f.
		else
			nOkAn++
		endIf
		
	next
	
endIf

// caso nenhuma tenha sido analisada nao deixa salvar, apenas uma analisada, 
// eu posso fazer a pergunta se deseja salvar e continuar posteriormente
if nOkAn == 0 

	Help("",1,"PLSA500034")
	lOK := .f.
	
// se nao foram todos analisados pergunto se quer salvar para concluir posteriormente sem mudar de fase
elseIf !lAllOk
 	
 	//"Não foram analisados todos os itens, deseja salvar para continuar posteriormente?"
	if !msgYesNo(STR0317) 
		lOK := .f.
	else
		lOK := .t.
	endIf
	
endIf

return(lOK)

/*/{Protheus.doc} PLSA500RCP
Revaloriza a cobrança e pagto de uma guia
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLSA500RCP(cAlias,nReg,nOpc,aFileds,lMsg,lRevPag,lWeb,lAllPeg,lCtb)
local cChaveGui  := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local cChave	 := ''
local cLocalExec := "2" //processamento de contas
local aRet       := {}
local lRet 		 := .f.
local lExec		 := .t. //Executa revalorizacao ? .t. Sim, .f. Nao
local cChaveLib  := ""
local cNumLib	 := ""
local lGuiHoRe   := .f.
local lExsRC 	 := .f.
local cMsg		 := ""
Local dDatCtbChk := StoD("")

default lMsg     := .t.
default lRevPag  := .t.
default lWeb	 := .f.
default lAllPeg	 := .f.
default lCtb	 := .t.
default aFileds	 := {}

dDatCtbChk := PLRtDtCTB(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO"), .F.)
//se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
if lWeb .or. PLVLDBLQCO(dDatCtbChk, {"PLS005"}, lMsg) 
	
	if existBlock("PLSREVAL")
		lExec := execBlock("PLSREVAL",.f.,.f.,{'0',cChaveGui,cAlias})
	endIf
	
	if lExec .and. &(cAlias+"->"+cAlias+"_FASE") <> "3" .Or. &(cAlias+"->"+cAlias+"_SITUAC") <> "1" .Or. ;
		PLSVERCCBG(	&(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+;
					&(cAlias+"->"+cAlias+"_TIPREG"),&(cAlias+"->"+cAlias+"_ANOPAG"),&(cAlias+"->"+cAlias+"_MESPAG"),;
					&(cAlias+"->"+cAlias+"_SEQPF"))
		
		if lMsg
			Help("",1,"PLSA500011")
		endIf
		
	else
	
		lExsRC := iIf (!IsInCallStack('PLSA175RGR'), PLSVRDRPY(cChaveGui,"1", .f.), .f.) //Verifico se em algumas das BD7 tenho Reduçãod e custo, para alertar
		
		//Pede confirmacao
		if lExec .and. ! lMsg .Or. msgYesNo(STR0074) //"Deseja revalorizar cobrança e pagamento ?"
			
			if lExsRC
			
				cMsg := STR0285 + CRLF
				cMsg += STR0338
				cMsg += STR0339 + CRLF
				cMsg += STR0340
			
				if !(msgYesNo(cMsg))//Atenção! Nesta guia tem procedimentos que estão com Redução de Custo. Ao revalorar, voltarão aos valores padrões e será necessário reaplicar a Redução de Custos. Deseja Continuar?"))
					return lRet
				endIf
				
			endIf
			
			//Monta o numero da liberacao com base na guia
			
			if cAlias == 'BE4'
				lGuiHoRe := .t.
			endIf
			
			if (cAlias)->(fieldPos(cAlias+"_NRLBOR")) > 0
				cNumLib := (cAlias)->&(cAlias+"_NRLBOR")
			else

				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Campo nao encontrado ["+cAlias+"_NRLBOR]" , 0, 0, {})
				
			endIf
			
			//Retorna chave da liberacao
			cChaveLib := PLSCTLIB( cNumLib,lGuiHoRe )
			
			//A rotina somente pode ser executada se a guia ja estiver paga
			if findFunction("PLS720ZCB")
				PLS720ZCB("3",cChaveGui,cAlias)
			endIf
			
			//verifica se ja existe movimento contabil e exclui
			if lCtb
			
				lCtb := .f.
				
				cChave := (cAlias)->&( cAlias + "_CODOPE+" + cAlias + "_CODLDP+" + cAlias + "_CODPEG" )
			
				if !lAllPeg
					cChave += (cAlias)->&( cAlias + "_NUMERO+" + cAlias + "_ORIMOV" )
				endIf	
		
				//exclui movimento contabil
				lRet := PLSEXMCTB("A", cChave,!lMsg )
				
			endIf
			
			aRet := PLSA720EVE(BCL->BCL_TIPGUI,BCL->BCL_GUIREL,lMsg,;
								&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_ANOPAG"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_MESPAG"),;
								BCL->BCL_ALIAS,cChaveGui,{},cLocalExec,{},.t.,lRevPag,nil,nil,.t.,,,,,,,,cChaveLib)
			
			if existBlock("PLSREVPC")
				execBlock("PLSREVPC",.f.,.f.,{BCL->BCL_TIPGUI,cLocalExec,.t.,.t.})
			endIf
			
			//Após, atualizo BD7_REDCUS para vazio, para que possa ser considerado na redução de custo
			PLSVRDRPY(cChaveGui,"2", IsInCallStack('PLSA175RGR'))
			PLSGRGLREV(aRet[3], cChaveGui)
			
			if aRet[1]

				//atualiza totais do peg
				PLPEGTOT()
		
				lRet := .t.

				if lMsg .and. ! lWeb
					msgInfo(STR0075) //"Revalorizacao de cobrança e pagamento concluida."
				endIf
		
			endIf
					
		endIf
		
	endIf
	
else
	
	lRet := .f.
	
endIf

return(lRet)

/*/{Protheus.doc} PLSA500LMV

@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLSA500LMV(cMatric)
local aRet := PLSA730FAS()

default cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)

if aRet[1]
	PLHISMOV(cMatric, aRet[2],aRet[3])
endIf
	
return

/*/{Protheus.doc} PLSA500ORD

@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLSA500ORD(cAlias,nReg,nOpc)
local aOrdens := {}
local aRet

SIX->(dbSetOrder(1))
if SIX->(msSeek(cAlias))
	while ! SIX->(eof()) .and. SIX->INDICE == cAlias
		
		if SIX->SHOWPESQ <> "0" 
			if Asc(SIX->ORDEM) < 65
				aadd(aOrdens,{val(SIX->ORDEM),SIX->DESCRICAO})
			else
				aadd(aOrdens,{Asc(SIX->ORDEM)-55,SIX->DESCRICAO})
			endIf
		endIf
		//Depois tratar outros idiomas
		SIX->(dbSkip())
	endDo
endIf

aRet := PLSCRIGEN(aOrdens,{ {STR0076,"99",040},{STR0077,"@C",300}  }, STR0078) //"Ordem"###"Descricao"###"  Ordens Disponíveis "

if aRet[1]
	DbSelectArea(cAlias)
	dbSetOrder(aOrdens[aRet[2],1])
endIf

return

/*/{Protheus.doc} PLSA500REC

@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLSA500REC(cAlias,nReg,nOpc)
local cChavePes   := &(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+;
					 &(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG")+&(cAlias+"->"+cAlias+"_ANOPAG")+&(cAlias+"->"+cAlias+"_MESPAG")+&(cAlias+"->"+cAlias+"_SEQPF")
local cFiltro := RetFiltro(cAlias,"BCI")

if !empty(cFiltro)
	DbSelectArea(cAlias)
	dbSetOrder(1)
	dbClearFilter()
endIf
BDH->(dbSetOrder(3))
if BDH->(msSeek(xFilial("BDH")+cChavePes))
	BDH->(PLSM220Pro("BDH",BDH->(recno()),K_Incluir))
else
	Help("",1,"PLSA500012")
endIf

if !empty(cFiltro)
	DbSelectArea(cAlias)
	dbSetOrder(1)
	SET FILTER to &cFiltro
endIf

return

/*/{Protheus.doc} RetFiltro

@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
static function RetFiltro(cAlias,cAliasAnt)
local cFiltro := ""
local cCodOpe := &(cAliasAnt+"->"+cAliasAnt+"_CODOPE")
local cCodLDP := &(cAliasAnt+"->"+cAliasAnt+"_CODLDP")
local cCodPEG := &(cAliasAnt+"->"+cAliasAnt+"_CODPEG")

cFiltro := "@"+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' AND "+cAlias+"_CODOPE = '"+cCodOpe+"' AND "
cFiltro += cAlias+"_CODLDP = '"+cCodLDP+"' AND "+cAlias+"_CODPEG = '"+cCodPEG+"'  "
cFiltro += " AND D_E_L_E_T_ = ' ' "

return cFiltro


/*/{Protheus.doc} PLE500F12
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLE500F12(cAlias,nReg,nOpc)

execBlock('PL500F12',.f.,.f.,{'2',cAlias,nReg,nOpc})

return

/*/{Protheus.doc} PlGetDadGui
Dada uma guia e o header dos campos, retorna o conteudo dela
aRet[1] - Cabecalho
aRet[2] - Itens
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PlGetDadGui(cChaveGui,aCabec,aItens,aSubItens,cAlias)
local aRet 		 := {{},{}}
local nCnt 		 := 0
local nRecAli    := &(cAlias+"->(recno())")
local nOrdAli    := &(cAlias+"->(IndexOrd())")
local xConteudo  := nil
local cFiltAli	 := ""
local bRest      := { || &(cAlias+"->(dbSetOrder("+allTrim(str(nOrdAli))+"))"), &(cAlias+"->(dbGoto("+allTrim(str(nRecAli))+"))") }

if findFunction("tcSqlFilter()")//teoricamente sempre tem q entrar aqui
	cFiltAli := &(cAlias+"->(tcSqlFilter())")
else
	cFiltAli := RetFiltro(cAlias,"BCI")
endIf
&(cAlias+"->(dbClearFilter())")

&(cAlias+"->(dbSetOrder(1))")
if ! &(cAlias+"->(msSeek('"+xFilial(cAlias)+subs(cChaveGui,1,24)+"'))")
	Help("",1,"PLSA500015")
	if !empty(cFiltAli)
		DbSelectArea(cAlias)
		dbSetFilter({||&cFiltAli},cFiltAli)
	endIf
	Eval(bRest)
	return
endIf

for nCnt := 1 to len(aCabec[2])
	xConteudo 	:= &(aCabec[1]+"->"+aCabec[2][nCnt][1])
	aadd(aRet[1],xConteudo)
next

if BD6->(msSeek(xFilial("BD6")+cChaveGui))
	while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == ;
			xFilial("BD6")+cChaveGui
		
		aadd(aRet[2],{ {} , {} })
		//aRet[2][1] - Dados do item
		//aRet[2][2] - Dados dos subitens
		for nCnt := 1 to len(aItens)
			xConteudo 	:= &("BD6->"+aItens[nCnt][1])
			aadd(aRet[2][len(aRet[2])][1],xConteudo)
		next
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				aadd(aRet[2][len(aRet[2])][2],{})
				for nCnt := 1 to len(aSubItens)
					xConteudo 	:= &("BD7->"+aSubItens[nCnt][1])
					aadd(aRet[2][len(aRet[2])][2][len(aRet[2][len(aRet[2])][2])],xConteudo)
				next
				
				BD7->(dbSkip())
			endDo
		endIf
		BD6->(dbSkip())
	endDo
endIf
if !empty(cFiltAli)
	DbSelectArea(cAlias)
	dbSetFilter({||&cFiltAli},cFiltAli)
endIf
Eval(bRest)

return aRet

/*/{Protheus.doc} PLSA500AND
Analisa as divergencias entre duas guias
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLSA500AND(cAlias,nReg,nOpc,aFields,lMsg)
local cChaveGui := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local aCabec    := {cAlias,&(cAlias+"->(DbStruct())")}
local aItens    := BD6->(DbStruct())
local aSubItens := BD7->(DbStruct())
local aGuiaOri  := {} // sempre eh a guia que deu origem ao clone
local aGuiaAtu  := {} // sempre eh a guia que foi gerada depois da clonagem
local aAcoes	:= {}
local aDiverg	:= {}
local aRetTab	:= {}
local aArea		:= getArea()
local aFiles    := {} 
local oDlg
local nOpca	    := 0
local nTrb 		:= 115
local nH756		:= 0
local lFatal    := .f.
local cChaveAtu := "" //chave do clone
local cChaveOri := "" //chave da guia origem
local bOK       := {|| nOpca := 1 , if(PLVLDBLQCO(dDataBase, {"PLS006"}, .t.) .and. PlValidEst(cAlias,aGuiaOri,aGuiaAtu,aCabec,aItens,aSubItens,@lFatal) .and. msgYesNo(STR0082),oDlg:end() ,nOpca:=0), if(nOpca==0 .and. !lFatal,oDlg:end(),.f.) } //"Deseja proceder as ações de estorno listadas?"
local bCancel   := {|| oDlg:end() }
local cFiltAli	:= ""
default aFields := nil
default lMsg    := .t.

BCL->(dbSetOrder(1))
if BCL->( msSeek( xFilial("BCL") + BCI->(BCI_CODOPE+BCI_TIPGUI) ) )
	aFiles := PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI)
endIf	

//O compatibilizador tem que ter sido executado
if &(cAlias+"->(fieldPos('"+cAlias+"_GUESTO'))") == 0
	if lMsg
		Help("",1,"PLSA500028")
	endIf
	restArea(aArea)
	return
endIf

//Verifico se a análise de divergência já nao foi executada

if !empty(&(cAlias+"->"+cAlias+"_SEQEST"))
	if lMsg
		Help("",1,"PLSA500027")
	endIf
	restArea(aArea)
	return
endIf

//Vejo aonde o usuário esta posicionado

if &(cAlias+"->"+cAlias+"_ESTORI") == '0'//estou posicionado no clone
	cChaveAtu := cChaveGui //chave do clone
	cChaveOri := allTrim(&(cAlias+"->"+cAlias+"_GUESTO"))//chave da guia origem
else
	cChaveAtu := allTrim(&(cAlias+"->"+cAlias+"_GUESTO"))       //chave do clone
	cChaveOri := cChaveGui//chave da guia origem
endIf
if findFunction("tcSqlFilter()")//teoricamente sempre tem q entrar aqui
	cFiltAli := &(cAlias+"->(tcSqlFilter())")
else
	cFiltAli := RetFiltro(cAlias,"BCI")
endIf
&(cAlias+"->(dbClearFilter())")

//A guia tem q ter sido clonada

if empty(&(cAlias+"->"+cAlias+"_GUESTO"))
	if lMsg
		Help("",1,"PLSA500029")
	endIf
	restArea(aArea)
	if !empty(cFiltAli)
		DbSelectArea(cAlias)
		dbSetFilter({||&cFiltAli},cFiltAli)
	endIf
	return
endIf

//Posiciono no clone

DbSelectArea(cAlias)
dbSetOrder(1)
msSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))

//O clone tem que estar com a fase pronta

if ! &(cAlias+"->"+cAlias+"_FASE") $ "3"
	if lMsg
		Help("",1,"PLSA500017")
	endIf
	if !empty(cFiltAli)
		DbSelectArea(cAlias)
		dbSetFilter({||&cFiltAli},cFiltAli)
	endIf
	restArea(aArea)
	return
endIf

//Montei em um array os dados da guia que estou posicionado

aGuiaAtu := PlGetDadGui(cChaveAtu,aCabec,aItens,aSubItens,cAlias)
aGuiaOri := PlGetDadGui(cChaveOri,aCabec,aItens,aSubItens,cAlias)

//Dado dois arrays eu listo as diferencas entre eles

PlGetDiverg(aGuiaOri,aGuiaAtu,aCabec,aItens,aSubItens,aAcoes,aDiverg)

//Depois que jah analisei monto a arvore de divergências

if len(aDiverg) <> 0
	DEFINE MSDIALOG oDlg TITLE STR0083 FROM 008.2,010.3 to 034.4,100.3 of GetWndDefault() //"Divergências entre guias"
	oTree := DbTree():new(030,010,180,345,oDlg,nil,nil,.t.,nil)
	oTree:BuildTrb(nTrb,2)
	oTree:BeginUpdate()
	oTree:SetEnable()
	PlPriDiverg(@oTree,aDiverg,aRetTab,.f.,cChaveOri)

	//-------------------------------------------------------------------
	//  LGPD
	//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.f.,{}) })
	
	//Depois que eu exibo as criticas tomo as acoes
	
	if nOpca == 1
		
		//Se eu tive acao de estorno eu certamente vou ter debito credito a
		//se gerar logo ativo semaforo do debito credito de usuario		
		
		nH756  := PLSAbreSem("PL756PAR.SMF")
		
		//Inicio da transacao
		
		begin transaction
			
			//Busco o sequencial do estorno
			
			cSeqEst := B35->(GetSx8Num("B35","B35_SEQEST"))
			B35->(ConfirmSx8())			
			
			//Vou gravar os B35			
			PlPriDiverg(nil,nil,aRetTab,.t.,cChaveOri,cSeqEst)
			
			//Posiciono na guia orgiem
			
			DbSelectArea(cAlias)
			dbSetOrder(1)
			msSeek(xFilial(cAlias)+subs(cChaveOri,1,24))
			recLock(cAlias,.f.)
			&(cAlias+"_SEQEST") := cSeqEst
			msUnLock()
			
			//Garanto que o clone esta posicionado
			
			msSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))
			recLock(cAlias,.f.)
			&(cAlias+"_SEQEST") := cSeqEst
			msUnLock()
			
			//Desbloqueio o clone
			
			if  &(cAlias+"->"+cAlias+"_SITUAC") == '3'
				PLSA500STA("1",&(cAlias+"->"+cAlias+"_CODOPE"),&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),&(cAlias+"->"+cAlias+"_ORIMOV"),aFiles,BCL->BCL_FUNGRV,K_Desbloq,BCL->BCL_TIPGRV,BCL->BCL_ALIAS,"")
			endIf
			
			//Dada uma lista de acoes e as duas guias eu tomo as acoes
			
			Proc2BarGauge({|| PLAcaoEstor(aAcoes,aGuiaOri,aGuiaAtu,aCabec,aItens,aSubItens,cSeqEst,cAlias,cChaveOri,cChaveAtu) }, STR0084) //"Ações de Estorno"
			
			//Fim da transacao
			
		end transaction
		PLSFechaSem(nH756,"PL756PAR.SMF")
		if lMsg
			msgInfo(STR0085) //"Ações de estorno concluidas com sucesso !!!"
		endIf
	endIf
else
	
	//Posiciono no clone
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	msSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))
	if &(cAlias+"->"+cAlias+"_SITUAC") == '3'
		if lMsg .and. msgYesNo(STR0086)			 //"Não existem divergências entre as guias, deseja desbloquear a guia clonada?"
			
			//Desbloqueio o clone
			
			begin transaction
				PLSA500STA("1",&(cAlias+"->"+cAlias+"_CODOPE"),&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),&(cAlias+"->"+cAlias+"_ORIMOV"),aFiles,BCL->BCL_FUNGRV,K_Desbloq,BCL->BCL_TIPGRV,BCL->BCL_ALIAS,"")
			end transaction
		endIf
	else
		if lMsg
			Aviso(STR0087,STR0088,{"Ok"},2) //"Análise de Divergências"###"Não existem divergências entre as guias."
		endIf
	endIf
endIf
if !empty(cFiltAli)
	DbSelectArea(cAlias)
	dbSetFilter({||&cFiltAli},cFiltAli)
endIf
restArea(aArea)

return

/*/{Protheus.doc} PLSA500AND
Dada duas guias retorna as diferenças entre elas
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PlGetDiverg(aGuiaOri,aGuiaAtu,aCabec,aItens,aSubItens,aAcoes,aRet)
local nI         := 0
local nJ         := 0
local nK         := 0
local nT 	     := 0
local cAlias     := aCabec[1]
local cAliIte    := "BD6"
local cAliSIe    := "BD7"
local cGuiOri    := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]+'.'+aGuiaOri[1][GetField(cAlias+"_CODLDP",aCabec)]+'.'+aGuiaOri[1][GetField(cAlias+"_CODPEG",aCabec)]+'.'+aGuiaOri[1][GetField(cAlias+"_NUMERO",aCabec)]
local cGuiAtu    := aGuiaAtu[1][GetField(cAlias+"_CODOPE",aCabec)]+'.'+aGuiaAtu[1][GetField(cAlias+"_CODLDP",aCabec)]+'.'+aGuiaAtu[1][GetField(cAlias+"_CODPEG",aCabec)]+'.'+aGuiaAtu[1][GetField(cAlias+"_NUMERO",aCabec)]
local cMatOri    := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]+aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]+aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]+aGuiaOri[1][GetField(cAlias+"_TIPREG",aCabec)]+aGuiaOri[1][GetField(cAlias+"_DIGITO",aCabec)]
local cMatAtu 	 := aGuiaAtu[1][GetField(cAlias+"_OPEUSR",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_CODEMP",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_MATRIC",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_TIPREG",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_DIGITO",aCabec)]
local cChavOri   := StrTran(cGuiOri,'.','')+aGuiaOri[1][GetField(cAlias+"_ORIMOV",aCabec)]
local cChavAtu   := StrTran(cGuiAtu,'.','')+aGuiaAtu[1][GetField(cAlias+"_ORIMOV",aCabec)]
local cSequenOri := ""
local cCodProOri := ""
local cCodPadOri := ""
local cCodRdaOri := ""
local cSequenAtu := ""
local cCodProAtu := ""
local cCodPadAtu := ""
local cCodRdaAtu := ""
local cCampoOri  := ""
local cNLancAtu  := ""
local cNLancOri	 := ""
local xDadoOri   := nil
local xDadoAtu   := nil
local lMatDif	 := .f.
local lRDA		 := .f.
local aSlvItens  := {}
local aSlvSubIt  := {}

//Varro o cabecalho da guia

for nI := 1 to len(aCabec[2])
	cCampoOri  := aCabec[2][nI][1]
	xDadoOri   := aGuiaOri[1][nI]
	xDadoAtu   := aGuiaAtu[1][nI]
	
	if xDadoOri <> xDadoAtu
		
		//542 - Matriculas dos usuários divergêntes entre as duas guias
		
		if cAlias+"_MATRIC" $ cCampoOri
			PLSPOSGLO(PLSINTPAD(),__aCdCri117[1],__aCdCri117[2],"1")
			aadd(aRet,{Fir_Node,__aCdCri117[1],PLSBCTDESC(),"PCOFXCANCEL"})
			aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
			aadd(aRet,{Thi_Node,"",transform(cMatOri,__cPictUsr)+' - '+ allTrim(aGuiaOri[1][GetField(cAlias+"_NOMUSR",aCabec)])})
			aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
			aadd(aRet,{Thi_Node,"",transform(cMatAtu,__cPictUsr)+' - '+allTrim(aGuiaAtu[1][GetField(cAlias+"_NOMUSR",aCabec)])})
			aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})   		         				   				  //"Acao de Estorno"
			aadd(aRet,{Thi_Node,"",STR0092})     		         				   				  //"Efetuar lancamentos de credito ao usuario da guia estornada no valor da PF de cada subitem de cada procedimento."
			aadd(aRet,{Thi_Node,"",STR0093}) //"Marcar os procedimentos da guia estornada com a opcao de estorno de cobranca."
			aadd(aRet,{Thi_Node,"",STR0094}) //"Marcar os procedimentos da guia clonada como liberado para cobranca."
			aadd(aAcoes,{__aCdCri117[1]})
			lMatDif := .t.
		endIf
	endIf
next

//Vou varrer cada evento da guia origem

for nI := 1 to len(aGuiaOri[2])
	cSequenOri := aGuiaOri[2][nI][1][GetField(cAliIte+"_SEQUEN",aItens)]
	cCodProOri := aGuiaOri[2][nI][1][GetField(cAliIte+"_CODPRO",aItens)]
	cCodPadOri := aGuiaOri[2][nI][1][GetField(cAliIte+"_CODPAD",aItens)]
	cCodRdaOri := aGuiaOri[2][nI][1][GetField(cAliIte+"_CODRDA",aItens)]
	
	//Vou procurar o evento com esta sequencia na guia clonada
	
	if (nT:=ascan(aGuiaAtu[2],{|x| x[1][GetField(cAliIte+"_SEQUEN",aItens)]+x[1][GetField(cAliIte+"_CODPRO",aItens)] == cSequenOri+cCodProOri })) == 0
		
		//544 - Procedimento Nao encontrado na guia clonada
		
		if (nT:=ascan(aGuiaAtu[2],{|x| x[1][GetField(cAliIte+"_SEQUEN",aItens)] == cSequenOri })) == 0
			
			PLSPOSGLO(PLSINTPAD(),__aCdCri119[1],__aCdCri119[2],"1")
			aadd(aRet,{Fir_Node,__aCdCri119[1],PLSBCTDESC(),"PCOFXCANCEL"})
			aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
			aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
			aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
			aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,"")+' - '+STR0095})     		         				   				  //" Nao encontrado"
			aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})  //"Acao de Estorno"
			aadd(aRet,{Thi_Node,"",STR0096}) //"Efetuar lancamentos de credito ao usuario da guia estornada no valor da PF de cada subitem do procedimento."
			aadd(aRet,{Thi_Node,"",STR0097}) //"Efetuar lancamentos de debito a R.D.A da guia estornada no valor de pagamento de cada subitem do procedimento."
			aadd(aRet,{Thi_Node,"",STR0098}) //"Marcar o procedimento da guia estornada com a opcao de estorno de cobranca e pagamento."
			aadd(aAcoes,{__aCdCri119[1],cChavOri+cSequenOri+cCodPadOri+cCodProOri})
		else
			
			//545 - A operadora do sistema digitou o código procedimento errado na guia
			
			cCodProAtu := aGuiaAtu[2][nT][1][GetField(cAliIte+"_CODPRO",aItens)]
			cCodPadAtu := aGuiaAtu[2][nT][1][GetField(cAliIte+"_CODPAD",aItens)]
			cSequenAtu := aGuiaAtu[2][nT][1][GetField(cAliIte+"_SEQUEN",aItens)]
			
			PLSPOSGLO(PLSINTPAD(),__aCdCri120[1],__aCdCri120[2],"1")
			aadd(aRet,{Fir_Node,__aCdCri120[1],PLSBCTDESC(),"PCOFXCANCEL"})
			aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
			aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
			aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
			aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
			aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"}) //"Acao de Estorno"
			aadd(aRet,{Thi_Node,"",STR0096})     		         				   				  //"Efetuar lancamentos de credito ao usuario da guia estornada no valor da PF de cada subitem do procedimento."
			aadd(aRet,{Thi_Node,"",STR0097})     		         				   				  //"Efetuar lancamentos de debito a R.D.A da guia estornada no valor de pagamento de cada subitem do procedimento."
			aadd(aRet,{Thi_Node,"",STR0098})				 //"Marcar o procedimento da guia estornada com a opcao de estorno de cobranca e pagamento."
			aadd(aRet,{Thi_Node,"",STR0099}) //"Marcar o procedimento da guia clonada como liberado para cobranca e pagamento."
			aadd(aAcoes,{__aCdCri120[1],cChavOri+cSequenOri,cChavAtu+cSequenAtu})
		endIf
	else
		cSequenAtu := aGuiaAtu[2][nT][1][GetField(cAliIte+"_SEQUEN",aItens)]
		cCodProAtu := aGuiaAtu[2][nT][1][GetField(cAliIte+"_CODPRO",aItens)]
		cCodPadAtu := aGuiaAtu[2][nT][1][GetField(cAliIte+"_CODPAD",aItens)]
		
		
		//Varro os itens
		
		aSlvItens := aClone(aItens)
		
		aItens    := {{cAliIte+"_VLRTPF"},{cAliIte+"_BLOCPA"}}
		
		for nK := 1 to len(aItens)
			cCampoOri  := aItens[nK][1]
			xDadoOri   := aGuiaOri[2][nI][1][GetField(cCampoOri,aSlvItens)]
			xDadoAtu   := aGuiaAtu[2][nT][1][GetField(cCampoOri,aSlvItens)]
			lVlrCob    := .f.
			if  xDadoOri <> xDadoAtu
				
				//546 - Valor total da participacao entre os procedimentos divergentes
				
				if cAliIte+"_VLRTPF" $ cCampoOri .and. !lMatDif
					
					PLSPOSGLO(PLSINTPAD(),__aCdCri112[1],__aCdCri112[2],"1")
					aadd(aRet,{Fir_Node,__aCdCri112[1],PLSBCTDESC(),"PCOFXCANCEL"})
					aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
					aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
					aadd(aRet,{Thi_Node,"",'R$ '+transform(xDadoOri,PLSMONEY)})
					aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
					aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
					aadd(aRet,{Thi_Node,"",'R$ '+transform(xDadoAtu,PLSMONEY)})
					aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                                      //"Acao de Estorno"
					aadd(aRet,{Thi_Node,"",STR0096}) //"Efetuar lancamentos de credito ao usuario da guia estornada no valor da PF de cada subitem do procedimento."
					aadd(aRet,{Thi_Node,"",STR0100}) //"Marcar o procedimento da guia estornada com a opcao de estorno de cobranca."
					aadd(aRet,{Thi_Node,"",STR0101}) //"Marcar o procedimento da guia clonada como liberado para cobranca."
					aadd(aAcoes,{__aCdCri112[1],cChavOri+cSequenOri+cCodPadOri+cCodProOri,cChavAtu+cSequenAtu+cCodPadAtu+cCodProAtu})
					lVlrCob := .t.
				endIf
				
				//558 - Bloqueio de cobranca divergente entre os procedimentos.
				
				if cAliIte+"_BLOCPA" $ cCampoOri .and. !lVlrCob .and. !lMatDif .and. (val(xDadoAtu) <> val(xDadoOri))//tratamento de campo vazio
					if val(xDadoOri) == 1
						PLSPOSGLO(PLSINTPAD(),__aCdCri150[1],__aCdCri150[2],"1")
						aadd(aRet,{Fir_Node,__aCdCri150[1],PLSBCTDESC(),"PCOFXCANCEL"})
						aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
						aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
						aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliIte+"_BLOCPA",xDadoOri)})
						aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
						aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
						aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliIte+"_BLOCPA",xDadoAtu)})
						aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                                      //"Acao de Estorno"
						aadd(aRet,{Thi_Node,"",STR0101})  //"Marcar o procedimento da guia clonada como liberado para cobranca."
						aadd(aAcoes,{__aCdCri150[1],cChavOri+cSequenOri+cCodPadOri+cCodProOri,cChavAtu+cSequenAtu+cCodPadAtu+cCodProAtu,'1'})
					else
						PLSPOSGLO(PLSINTPAD(),__aCdCri150[1],__aCdCri150[2],"1")
						aadd(aRet,{Fir_Node,__aCdCri150[1],PLSBCTDESC(),"PCOFXCANCEL"})
						aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
						aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
						aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliIte+"_BLOCPA",xDadoOri)})
						aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
						aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
						aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliIte+"_BLOCPA",xDadoAtu)})
						aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                                      //
						aadd(aRet,{Thi_Node,"",STR0096})  //"Efetuar lancamentos de credito ao usuario da guia estornada no valor da PF de cada subitem do procedimento."
						aadd(aRet,{Thi_Node,"",STR0100})  //"Marcar o procedimento da guia estornada com a opcao de estorno de cobranca."
						aadd(aAcoes,{__aCdCri150[1],cChavOri+cSequenOri+cCodPadOri+cCodProOri,cChavAtu+cSequenAtu+cCodPadAtu+cCodProAtu,'2'})
					endIf
				endIf
			endIf
		next
		aItens := aClone(aSlvItens)
		
		//Vou varrer cada unidade deste evento
		
		for nJ := 1 to len(aGuiaOri[2][nI][2])
			//o usuario pode deletar uma unidade qualquer
			if (nY:=ascan(aGuiaAtu[2][nT][2],{|x| x[GetField(cAliSIe+"_CODUNM",aSubItens)]+x[GetField(cAliSIe+"_NLANC",aSubItens)] == ;
					aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_CODUNM",aSubItens)]+aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_NLANC",aSubItens)] })) == 0
				cCodUniOri := aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_CODUNM",aSubItens)]
				cRdaOri    := aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_NOMRDA",aSubItens)]
				cNLancOri  := aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_NLANC",aSubItens)]
				
				//557 - Subitem nao localizado na guia clonada.
				
				PLSPOSGLO(PLSINTPAD(),__aCdCri149[1],__aCdCri149[2],"1")
				aadd(aRet,{Fir_Node,__aCdCri149[1],PLSBCTDESC(),"PCOFXCANCEL"})
				aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
				aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
				aadd(aRet,{Thi_Node,"",cCodUniOri+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniOri,"BD3_DESCRI"))})
				aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
				aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
				aadd(aRet,{Thi_Node,"",'N/A'})
				aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                             //"Acao de Estorno"
				aadd(aRet,{Thi_Node,"",STR0254}) //"Efetuar lancamento de debito a R.D.A da guia estornada no valor de pagamento do subitem do procedimento." //"Efetuar lancamento de debito a R.D.A da guia estornada no valor de pagamento do subitem nao localizado."
				aadd(aRet,{Thi_Node,"",STR0103})  //"Marcar o subitem do procedimento da guia estornada com a opcao de estorno de pagamento."
				aadd(aAcoes,{__aCdCri149[1],cChavOri+cSequenOri+cCodUniOri+cNLancOri})
				Loop
			else
				cCodUniOri := aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_CODUNM",aSubItens)]
				cCodUniAtu := aGuiaAtu[2][nT][2][nY][GetField(cAliSIe+"_CODUNM",aSubItens)]
				cRdaOri    := aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_NOMRDA",aSubItens)]
				cRdaAtu    := aGuiaAtu[2][nT][2][nY][GetField(cAliSIe+"_NOMRDA",aSubItens)]
				cNLancOri  := aGuiaOri[2][nI][2][nJ][GetField(cAliSIe+"_NLANC",aSubItens)]
				cNLancAtu  := aGuiaAtu[2][nT][2][nY][GetField(cAliSIe+"_NLANC",aSubItens)]
				lRDA	   := .f.
				lVlrPag    := .f.
				aSlvSubIt  := aClone(aSubItens)
				aSubItens  := {{cAliSIe+"_CODRDA"},{cAliSIe+"_VLRPAG"},{cAliSIe+"_BLOPAG"}}
				for nK := 1 to len(aSubItens)
					cCampoOri  := aSubItens[nK][1]
					xDadoOri   := aGuiaOri[2][nI][2][nJ][GetField(cCampoOri,aSlvSubIt)]
					xDadoAtu	  := aGuiaAtu[2][nT][2][nY][GetField(cCampoOri,aSlvSubIt)]
					
					if  xDadoOri <> xDadoAtu
						
						//548 - O sistema pagou o subitem de um procedimento para a RDA errada.
						
						if cAliSIe+"_CODRDA" $ cCampoOri
							
							PLSPOSGLO(PLSINTPAD(),__aCdCri114[1],__aCdCri114[2],"1")
							aadd(aRet,{Fir_Node,__aCdCri114[1],PLSBCTDESC(),"PCOFXCANCEL"})
							aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
							aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
							aadd(aRet,{Thi_Node,"",cCodUniOri+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniOri,"BD3_DESCRI"))})
							aadd(aRet,{Thi_Node,"",xDadoOri  +' - '+allTrim(cRdaOri) })
							aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
							aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
							aadd(aRet,{Thi_Node,"",cCodUniAtu+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniAtu,"BD3_DESCRI"))})
							aadd(aRet,{Thi_Node,"",xDadoAtu  +' - '+allTrim(cRdaAtu) })
							aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                             //"Acao de Estorno"
							aadd(aRet,{Thi_Node,"",STR0102}) //"Efetuar lancamento de debito a R.D.A da guia estornada no valor de pagamento do subitem do procedimento."
							aadd(aRet,{Thi_Node,"",STR0103}) //"Marcar o subitem do procedimento da guia estornada com a opcao de estorno de pagamento."
							aadd(aRet,{Thi_Node,"",STR0104}) //"Marcar o subitem do procedimento da guia clonada como liberado para pagamento."
							aadd(aAcoes,{__aCdCri114[1],cChavOri+cSequenOri+cCodUniOri+cNLancOri,cChavAtu+cSequenAtu+cCodUniAtu+cNLancAtu})
							lRDA := .t.
						endIf
						
						//547 - Valor de pagamento, do subitem de um mesmo procedimento para a
						//mesma R.D.A, divergentes entre as duas guias.
						
						if cAliSIe+"_VLRPAG" $ cCampoOri .and. !lRDA
							
							PLSPOSGLO(PLSINTPAD(),__aCdCri113[1],__aCdCri113[2],"1")
							aadd(aRet,{Fir_Node,__aCdCri113[1],PLSBCTDESC(),"PCOFXCANCEL"})
							aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
							aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
							aadd(aRet,{Thi_Node,"",cCodUniOri+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniOri,"BD3_DESCRI"))})
							aadd(aRet,{Thi_Node,"",'R$ '+allTrim(transform(xDadoOri,PLSMONEY))})
							aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
							aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
							aadd(aRet,{Thi_Node,"",cCodUniAtu+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniAtu,"BD3_DESCRI"))})
							aadd(aRet,{Thi_Node,"",'R$ '+allTrim(transform(xDadoAtu,PLSMONEY))})
							aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                                  //"Acao de Estorno"
							aadd(aRet,{Thi_Node,"",STR0105}) //"Efetuar lancamento de debito R.D.A da guia estornada no valor de pagamento do subitem do procedimento."
							aadd(aRet,{Thi_Node,"",STR0103}) //"Marcar o subitem do procedimento da guia estornada com a opcao de estorno de pagamento."
							aadd(aRet,{Thi_Node,"",STR0104}) //"Marcar o subitem do procedimento da guia clonada como liberado para pagamento."
							aadd(aAcoes,{__aCdCri113[1],cChavOri+cSequenOri+cCodUniOri+cNLancOri,cChavAtu+cSequenAtu+cCodUniAtu+cNLancAtu})
							lVlrPag := .t.
						endIf
						
						if cAliSIe+"_BLOPAG" $ cCampoOri .and. !lRDA .and. !lVlrPag .and. val(xDadoOri) <> val(xDadoAtu)
							if Val(xDadoOri) == 1
								PLSPOSGLO(PLSINTPAD(),__aCdCri151[1],__aCdCri151[2],"1")
								aadd(aRet,{Fir_Node,__aCdCri151[1],PLSBCTDESC(),"PCOFXCANCEL"})
								aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
								aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
								aadd(aRet,{Thi_Node,"",cCodUniOri+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniOri,"BD3_DESCRI"))})
								aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliSIe+"_BLOPAG",xDadoOri)})
								aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
								aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
								aadd(aRet,{Thi_Node,"",cCodUniAtu+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniAtu,"BD3_DESCRI"))})
								aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliSIe+"_BLOPAG",xDadoAtu)})
								aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                                  //"Acao de Estorno"
								aadd(aRet,{Thi_Node,"",STR0104})  //"Marcar o subitem do procedimento da guia clonada como liberado para pagamento."
								aadd(aAcoes,{__aCdCri151[1],cChavOri+cSequenOri+cCodUniOri+cNLancOri,cChavAtu+cSequenAtu+cCodUniAtu+cNLancAtu,'1'})
							else
								PLSPOSGLO(PLSINTPAD(),__aCdCri151[1],__aCdCri151[2],"1")
								aadd(aRet,{Fir_Node,__aCdCri151[1],PLSBCTDESC(),"PCOFXCANCEL"})
								aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
								aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,cCodProOri)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadOri+cCodProOri,"BR8_DESCRI")})
								aadd(aRet,{Thi_Node,"",cCodUniOri+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniOri,"BD3_DESCRI"))})
								aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliSIe+"_BLOPAG",xDadoOri)})
								aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
								aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
								aadd(aRet,{Thi_Node,"",cCodUniAtu+' - '+allTrim(Posicione("BD3",1,xFilial("BD3")+cCodUniAtu,"BD3_DESCRI"))})
								aadd(aRet,{Thi_Node,"",'Bloqueio - '+X3COMBO(cAliSIe+"_BLOPAG",xDadoAtu)})
								aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"})                                                  //"Acao de Estorno"
								aadd(aRet,{Thi_Node,"",STR0105})  //"Efetuar lancamento de debito R.D.A da guia estornada no valor de pagamento do subitem do procedimento."
								aadd(aRet,{Thi_Node,"",STR0103})  //"Marcar o subitem do procedimento da guia estornada com a opcao de estorno de pagamento."
								aadd(aAcoes,{__aCdCri151[1],cChavOri+cSequenOri+cCodUniOri+cNLancOri,cChavAtu+cSequenAtu+cCodUniAtu+cNLancAtu,'2'})
							endIf
						endIf
					endIf
				next
				aSubItens := aClone(aSlvSubIt)
			endIf
		next
	endIf
next

//Vou varrer cada evento da guia clonada

for nI := 1 to len(aGuiaAtu[2])
	cSequenAtu := aGuiaAtu[2][nI][1][GetField(cAliIte+"_SEQUEN",aItens)]
	cCodProAtu := aGuiaAtu[2][nI][1][GetField(cAliIte+"_CODPRO",aItens)]
	cCodPadAtu := aGuiaAtu[2][nI][1][GetField(cAliIte+"_CODPAD",aItens)]
	cCodRdaAtu := aGuiaAtu[2][nI][1][GetField(cAliIte+"_CODRDA",aItens)]
	
	//Vou procurar o evento com esta sequencia na guia clonada
	
	if (nT:=ascan(aGuiaOri[2],{|x| x[1][GetField(cAliIte+"_SEQUEN",aItens)] == cSequenAtu })) == 0
		
		//546 - Procedimento Nao encontrado na guia estornada
		
		PLSPOSGLO(PLSINTPAD(),__aCdCri121[1],__aCdCri121[2],"1")
		aadd(aRet,{Fir_Node,__aCdCri121[1],PLSBCTDESC(),"PCOFXCANCEL"})
		aadd(aRet,{Sec_Node,"",STR0089+"  ["+cGuiOri+"]","PCOFXCANCEL"}) //"Guia Estornada"
		aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadOri,"")+' - '+STR0095})     //" Nao encontrado"
		aadd(aRet,{Sec_Node,"",STR0090+"    ["+cGuiAtu+"]","PCOFXOK"}) //"Guia Clonada"
		aadd(aRet,{Thi_Node,"",PLSPICPRO(cCodPadAtu,cCodProAtu)+' - '+ Posicione("BR8",1,xFilial("BR8")+cCodPadAtu+cCodProAtu,"BR8_DESCRI")})
		aadd(aRet,{Sec_Node,"",STR0091,"ACAO.BMP"}) //"Acao de Estorno"
		aadd(aRet,{Thi_Node,"",STR0099}) //"Marcar o procedimento da guia clonada como liberado para cobranca e pagamento."
		aadd(aAcoes,{__aCdCri121[1],cChavAtu+cSequenAtu+cCodPadAtu+cCodProAtu})
	endIf
next

return aRet

/*/{Protheus.doc} GetField
Dada um campo, retorna se deve ser considerado nas divergenc
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
static function GetField(cCampo,aCabec)
local nRet := 0

if ValType(aCabec[1]) <> 'C'
	nRet := ascan(aCabec,{|x| allTrim(x[1]) == allTrim(cCampo)})
else
	nRet := ascan(aCabec[2],{|x| allTrim(x[1]) == allTrim(cCampo)})
endIf
if nRet == 0
	msgStop(STR0106+" ["+cCampo+"] "+STR0107) //"Erro na busca do campo"###"na rotina de estorno."
endIf

return nRet

/*/{Protheus.doc} GetLocal
Dado um campo, retorno se ele deve ser desconsiderado
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
static function GetLocal(cAlias)
local aRet    := {}
local nJ      :=1
local nI      :=1
local aEstrut := {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM"}
local oDlg,oSBtn1,oGrp2,oGet3,oGet4,oGet5,oSay6,oSay7,oSay8
local nOrdBCI := BCI->(IndexOrd())
local nRecBCI := BCI->(recno())
local bValid  := {|| M->BCI_CODOPE := cOpeClo, ExistCpo("BCG",cLocClo,1)}
local bVali2  := {|| M->BCI_CODOPE := cOpeClo, ExistCpo("BA0",cOpeClo,1)}
local bVali3  := {|| BCI->(dbSetOrder(1)),if(BCI->(msSeek(xFilial("BCI")+cOpeClo+cLocClo+cPegClo)), iIf(BCI->BCI_TIPGUI == cTipGui,.t.,Eval({|| Help("",1,"PLSA500032"),.f.})) ,Eval({|| Help("",1,"PLSA500031"),.f.})) }
cOpeClo := &(cAlias+"->("+cAlias+"_CODOPE)")
cLocClo := &(cAlias+"->("+cAlias+"_CODLDP)")
cPegClo := &(cAlias+"->("+cAlias+"_CODPEG)")
cTipGui := &(cAlias+"->("+cAlias+"_TIPGUI)")
M->BCI_CODOPE := cOpeClo //necessario para o f3 funcionar

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := STR0259 //"Informe aonde deve ser criada a guia clonada."
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 286
oDlg:nHeight := 193

oGrp2 := TGROUP():Create(oDlg)
oGrp2:cName := "oGrp2"
oGrp2:cCaption := ""
oGrp2:nLeft := 11
oGrp2:nTop := 6
oGrp2:nWidth := 257
oGrp2:nHeight := 151

@ 14,61 MSGET oGet3 VAR cOpeClo PICTURE "@R !.!!!"  size 010,010 VALID iIf(!empty(cOpeClo),Eval(bVali2),.t.) PIXEL of oDlg F3 "B89PLS" hasbutton
@ 30,61 MSGET oGet4 VAR cLocClo PICTURE "@!"        size 010,010 VALID iIf(!empty(cLocClo),Eval(bValid),.t.) PIXEL of oDlg F3 "BCGPLS" hasbutton
@ 46,61 MSGET oGet5 VAR cPegClo PICTURE "@!"        size 025,010 VALID iIf(!empty(cPegClo),Eval(bVali3),.t.) PIXEL of oDlg F3 "B1IPLS" hasbutton

oSay6 := TSAY():Create(oDlg)
oSay6:cName := "oSay6"
oSay6:cCaption := STR0260 //"Operadora :"
oSay6:nLeft := 23
oSay6:nTop := 31
oSay6:nWidth := 65
oSay6:nHeight := 17

oSay7 := TSAY():Create(oDlg)
oSay7:cName := "oSay7"
oSay7:cCaption := STR0261 //"local Digitação :"
oSay7:nLeft := 23
oSay7:nTop := 65
oSay7:nWidth := 89
oSay7:nHeight := 17

oSay8 := TSAY():Create(oDlg)
oSay8:cName := "oSay8"
oSay8:cCaption := "PEG : "
oSay8:nLeft := 23
oSay8:nTop := 95
oSay8:nWidth := 65
oSay8:nHeight := 17

oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "OK"
oSBtn1:nLeft := 207
oSBtn1:nTop := 120
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:bAction := {|| iIf(Eval(bValid) .and. Eval(bVali2) .and. Eval(bVali3),oDlg:end(),.f.) }

ACTIVATE MSDIALOG oDlg CENTERED

if Eval(bValid) .and. Eval(bVali2) .and. Eval(bVali3)
	aRet := {.t.,cOpeClo,cLocClo,cPegClo,BCI->BCI_CODRDA}
else
	aRet := {.f.}
endIf
BCI->(dbSetOrder(nOrdBCI))
BCI->(dbGoto(nRecBCI))

return aRet

/*/{Protheus.doc} DesField
Dado um campo, retorno se ele deve ser desconsiderado
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
static function DesField(cAliCp,cCampo)
local lRet    := .f.
local aFields := {"_DTGRCP","_INTFAT","_STAFAT","_NUMFAT","_OPEFAT","_NUMSE1",;
	"_NUMLOT","_OPELOT","_SEQPF","_PERCEN","_VLRTPF","_VLRPAG",;
	"_PERPF"}
local nI	  := 0

for nI:= 1 to len(aFields)
	if cAliCp+aFields[nI] == allTrim(cCampo)
		lRet := .t.
		exit
	endIf
next

return lRet

/*/{Protheus.doc} PLAcaoEstor
Dada uma lista de acoes eu tomo as acoes
aGuiaAtu - guia clone
aGuiaOri - guia estornada
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLAcaoEstor(aAcoes,aGuiaOri,aGuiaAtu,aCabec,aItens,aSubItens,cSeqEst,cAlias,cGuiOri,cGuiAtu)
local nI 		:= 0
local nVlrTPf   := 0
local nVlrPag	:= 0
local nVlrOri   := 0
local nVlrAtu   := 0
local _cNivel    := ""
local cChaveGui  := ""
local cChaveOri  := ""
local cChaveAtu  := ""
local lBD7ConPag := .f.
local lBD7ConMrd := .f.
local lBD7ConCob := .f.
local lBD7ConMus := .f.
local cCodSeq    := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")
local aCliente   := {}
local aLanPag	 := {}
local aLanCob	 := {}
local aRetAux	 := {}
local nOrdBA1	 := BA1->(IndexOrd())
local nRecBA1	 := BA1->(recno())
local nOrdBD6	 := BD6->(IndexOrd())
local nRecBD6	 := BD6->(recno())
local nOrdBD7	 := BD7->(IndexOrd())
local nRecBD7	 := BD7->(recno())
local nOrdBGQ	 := BGQ->(IndexOrd())
local nRecBGQ	 := BGQ->(recno())
local nOrdBSQ	 := BSQ->(IndexOrd())
local nRecBSQ	 := BSQ->(recno())
local bRest      := {|| BA1->(dbSetOrder(nOrdBA1)),BA1->(dbGoto(nRecBA1)),;
						BD6->(dbSetOrder(nOrdBD6)),BD6->(dbGoto(nRecBD6)),;
						BD7->(dbSetOrder(nOrdBD7)),BD7->(dbGoto(nRecBD7)),;
						BGQ->(dbSetOrder(nOrdBGQ)),BGQ->(dbGoto(nRecBGQ)),;
						BSQ->(dbSetOrder(nOrdBSQ)),BSQ->(dbGoto(nRecBSQ))}

BA1->(dbSetOrder(2))
BA1->(msSeek(xFilial("BA1")+aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]+aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]+aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]+aGuiaOri[1][GetField(cAlias+"_TIPREG",aCabec)]))

aCliente := PLSRETNCB(aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)],aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)],aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)],BA1->BA1_OPEORI)

aRetAux := PLSXVLDCAL(dDataBase,aGuiaAtu[1][GetField(cAlias+"_CODOPE",aCabec)],.t.,"","")

if aCliente[1]
	_cNivel := aCliente[5]
endIf

BarGauge1Set(len(aAcoes))
for nI:=1 to len(aAcoes)
	
	PLSPOSGLO(PLSINTPAD(),aAcoes[nI][1],nil,"1")
	
	//Acao - 542
	//nesta acao de estorno eu vou marcar os bd6 e bd7 da guia antiga como 
	//estornada a cobranca e vou gerar um credito para o usuario da guia   
	//estornada																 |
	
	if aAcoes[nI][1] == __aCdCri117[1]
		
		IncProcG1(STR0109+" [ "+allTrim(__aCdCri117[1])+" - "+ allTrim(PLSBCTDESC())+" ]")

		cChaveGui := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]+aGuiaOri[1][GetField(cAlias+"_CODLDP",aCabec)]+;
					 aGuiaOri[1][GetField(cAlias+"_CODPEG",aCabec)]+aGuiaOri[1][GetField(cAlias+"_NUMERO",aCabec)]+;
					 aGuiaOri[1][GetField(cAlias+"_ORIMOV",aCabec)]
		
		
		cChaveAtu := aGuiaAtu[1][GetField(cAlias+"_CODOPE",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_CODLDP",aCabec)]+;
					 aGuiaAtu[1][GetField(cAlias+"_CODPEG",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_NUMERO",aCabec)]+;
					 aGuiaAtu[1][GetField(cAlias+"_ORIMOV",aCabec)]
		
		BarGauge2Set(len(aGuiaOri[2])+len(aGuiaAtu[2]))
		
		//Aqui estou na guia origem										
		
		BD6->(dbSetOrder(1))
		if BD6->(msSeek(xFilial("BD6")+cChaveGui))
		
			while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cChaveGui
				
				IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
				
				//Se eu jah estornei a cobranca deste cara eu nao posso estornar denovo															
				if BD6->BD6_TPESTO == '3' .or. BD6->BD6_TPESTO == '4'
					
					//[1] XXX_CONCOB [2] XXX_CONPAG [3] XXX_CONMUS [4] XXX_CONMRD		
					//Cons.Cob? - Considera o registro na hora de gerar a cobrança ?  
					//Cons.Pag? - Considera o registro na hora de gerar o pagamento ? 
					//Cons.M.U? - Considera o registro como movimento do usuario?     
					//Cons.M.R? - Considera o registro como movimento da RDA?			
					
					BD6->(recLock("BD6",.f.))
					BD6->BD6_CONMUS := '0'
					BD6->(msUnLock())
					
					BD6->(dbSkip())
					loop
				endIf
				
				//1 - Nenhum                                                      
				//2 - Estorno Pagamento                                           
				//3 - Estorno Cobranca                                            
				//4 - Ambos														
				
				BD6->(recLock("BD6",.f.))
				if BD6->BD6_TPESTO == '2'
					BD6->BD6_TPESTO := '4'
				elseIf BD6->BD6_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
					BD6->BD6_TPESTO := '3'
				endIf
				BD6->BD6_CONCOB := '0'
				BD6->BD6_CONMUS := '0'
				BD6->(msUnLock())
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						//Busco o valor de participacao do usuario
						
						nVlrTPf := BD7->BD7_VLRTPF
						
						if nVlrTPf > 0 .and. BD7->BD7_TPESTO <> '3' .and. BD7->BD7_TPESTO <> '4'
							
							//Busco o lancamento de credito
							
							aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'2')
							
							//Se teve participacao eu gravo o credito para o usuario da guia  
							//estornada
							
							BSQ->(recLock("BSQ",.t.))
							BSQ->BSQ_FILIAL := xFilial("BSQ")
							BSQ->BSQ_CODSEQ	:= cCodSeq
							
							//Quando eh usuario de intercambio eu so gravo a operadora
							
							if BD6->BD6_OPEORI <> PlsIntPad()
								BSQ->BSQ_CODINT := BD6->BD6_OPEORI
							else
								BSQ->BSQ_CODINT := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]
								BSQ->BSQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
								BSQ->BSQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
								BSQ->BSQ_VERCON := aGuiaOri[1][GetField(cAlias+"_VERCON",aCabec)]
								BSQ->BSQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
								BSQ->BSQ_VERSUB := aGuiaOri[1][GetField(cAlias+"_VERSUB",aCabec)]
								BSQ->BSQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
								BSQ->BSQ_USUARI := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_TIPREG",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_DIGITO",aCabec)]
							endIf
							BSQ->BSQ_ANO    := aGuiaOri[1][GetField(cAlias+"_ANOPAG",aCabec)]
							BSQ->BSQ_MES    := aGuiaOri[1][GetField(cAlias+"_MESPAG",aCabec)]
							BSQ->BSQ_CODLAN := aCobPag[1][2][1]
							BSQ->BSQ_COMISS := aCobPag[1][2][6]
							BSQ->BSQ_ATOCOO := aCobPag[1][2][7]
							BSQ->BSQ_INCIR  := aCobPag[1][2][8]
							BSQ->BSQ_REGCIR := aCobPag[1][2][9]
							BSQ->BSQ_INCISS := aCobPag[1][2][10]
							BSQ->BSQ_TIPO   := aCobPag[1][2][4]
							BSQ->BSQ_REGCIS := aCobPag[1][2][11]
							BSQ->BSQ_INCCON := aCobPag[1][2][12]
							BSQ->BSQ_REGCCO := aCobPag[1][2][13]
							BSQ->BSQ_INCPIS := aCobPag[1][2][14]
							BSQ->BSQ_REGCPI := aCobPag[1][2][15]
							BSQ->BSQ_INCCSL := aCobPag[1][2][16]
							BSQ->BSQ_REGCCS := aCobPag[1][2][17]
							BSQ->BSQ_INCINS := aCobPag[1][2][18]
							BSQ->BSQ_REGCIN := aCobPag[1][2][19]
							BSQ->BSQ_REGCI1 := aCobPag[1][2][20]
							BSQ->BSQ_VALOR  := nVlrTPf
							BSQ->BSQ_AUTOMA := '1'
							BSQ->BSQ_COBNIV := _cNivel
							BSQ->BSQ_SEQEST := cSeqEst
							BSQ->BSQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
							BSQ->BSQ_COPCRE := aCobPag[1][2][22]
							BSQ->BSQ_TIPPE  := aCobPag[1][2][21]
							
							BSQ->(msUnLock())
							cCodSeq  := Soma1(cCodSeq)
						endIf
						
						//1 - Nenhum                                                      
						//2 - Estorno Pagamento                                           
						//3 - Estorno Cobranca                                            
						//4 - Ambos														
						
						BD7->(recLock("BD7",.f.))
						if BD7->BD7_TPESTO == '2'
							BD7->BD7_TPESTO := '4'
						elseIf BD7->BD7_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
							BD7->BD7_TPESTO := '3'
						endIf
						BD7->BD7_CONCOB := '0'
						BD7->BD7_CONMUS := '0'
						
						BD7->(msUnLock())
						
						BD7->(dbSkip())
					endDo
				endIf
				BD6->(dbSkip())
			endDo
		endIf
		
		//Aqui estou na guia clonada										
		
		BD6->(dbSetOrder(1))
		if BD6->(msSeek(xFilial("BD6")+cChaveAtu))
			while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cChaveAtu
				
				IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
				
				BD6->(recLock("BD6",.f.))
				BD6->BD6_CONCOB := '1'
				BD6->BD6_CONMUS := '1'
				BD6->(msUnLock())
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						BD7->(recLock("BD7",.f.))
						BD7->BD7_CONCOB := '1'
						BD7->BD7_CONMUS := '1'
						BD7->(msUnLock())
						
						BD7->(dbSkip())
					endDo
				endIf
				BD6->(dbSkip())
			endDo
		endIf
		
		//544 - Procedimento nao encontrado na guia clonada.              
		//545 - Codigos de procedimentos divergentes entre as duas guias. 
		
	elseIf aAcoes[nI][1] == __aCdCri119[1] .or. aAcoes[nI][1] == __aCdCri120[1]
		
		IncProcG1(STR0109+" [ "+allTrim(aAcoes[nI][1])+" - "+ allTrim(PLSBCTDESC())+" ]") //"Analisando critica"
		cChavePro := aAcoes[nI][2]
		
		//Aqui estouna guia que foi estornada								
		
		BarGauge2Set(1)
		BD6->(dbSetOrder(1))
		if BD6->(msSeek(xFilial("BD6")+cChavePro))
			
			IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
			
			//Se eu jah estornei a COBRANCA/PAGAMENTO deste cara eu nao 	    
			//posso estornar denovo											
			//1 - Nenhum                                                      
			//2 - Estorno Pagamento                                           
			//3 - Estorno Cobranca                                            
			//4 - Ambos														
			
			if BD6->BD6_TPESTO <> '4'
				
				BD6->(recLock("BD6",.f.))
				BD6->BD6_TPESTO := '4'
				BD6->BD6_CONCOB := '0'
				BD6->BD6_CONPAG := '0'
				BD6->BD6_CONMUS := '0'
				BD6->BD6_CONMRD := '0'
				BD6->(msUnLock())
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						//Busco o valor de participacao do usuario
						//Busco o valor de pagamento do prestador
						
						nVlrTPf := BD7->BD7_VLRTPF
						nVlrPag := BD7->BD7_VLRPAG
						
						if nVlrTPf > 0 .and. BD7->BD7_TPESTO <> '3' .and. BD7->BD7_TPESTO <> '4'
							
							//Busco o lancamento de credito
							
							aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'2')
							
							//Se teve participacao eu gravo o credito para o usuario da guia  
							//estornada
							
							BSQ->(recLock("BSQ",.t.))
							BSQ->BSQ_FILIAL := xFilial("BSQ")
							BSQ->BSQ_CODSEQ	:= cCodSeq
							
							//Quando eh usuario de intercambio eu so gravo a operadora
							
							if BD6->BD6_OPEORI <> PlsIntPad()
								BSQ->BSQ_CODINT := BD6->BD6_OPEORI
							else
								BSQ->BSQ_CODINT := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]
								BSQ->BSQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
								BSQ->BSQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
								BSQ->BSQ_VERCON := aGuiaOri[1][GetField(cAlias+"_VERCON",aCabec)]
								BSQ->BSQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
								BSQ->BSQ_VERSUB := aGuiaOri[1][GetField(cAlias+"_VERSUB",aCabec)]
								BSQ->BSQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
								BSQ->BSQ_USUARI := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_TIPREG",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_DIGITO",aCabec)]
							endIf
							BSQ->BSQ_ANO    := aRetAux[4]
							BSQ->BSQ_MES    := aRetAux[5]
							BSQ->BSQ_CODLAN := aCobPag[1][2][1]
							BSQ->BSQ_COMISS := aCobPag[1][2][6]
							BSQ->BSQ_ATOCOO := aCobPag[1][2][7]
							BSQ->BSQ_INCIR  := aCobPag[1][2][8]
							BSQ->BSQ_TIPO   := aCobPag[1][2][4]
							BSQ->BSQ_REGCIR := aCobPag[1][2][9]
							BSQ->BSQ_INCISS := aCobPag[1][2][10]
							BSQ->BSQ_REGCIS := aCobPag[1][2][11]
							BSQ->BSQ_INCCON := aCobPag[1][2][12]
							BSQ->BSQ_REGCCO := aCobPag[1][2][13]
							BSQ->BSQ_INCPIS := aCobPag[1][2][14]
							BSQ->BSQ_REGCPI := aCobPag[1][2][15]
							BSQ->BSQ_INCCSL := aCobPag[1][2][16]
							BSQ->BSQ_REGCCS := aCobPag[1][2][17]
							BSQ->BSQ_INCINS := aCobPag[1][2][18]
							BSQ->BSQ_REGCIN := aCobPag[1][2][19]
							BSQ->BSQ_REGCI1 := aCobPag[1][2][20]
							BSQ->BSQ_VALOR  := nVlrTPf
							BSQ->BSQ_AUTOMA := '1'
							BSQ->BSQ_COBNIV := _cNivel
							BSQ->BSQ_SEQEST := cSeqEst
							BSQ->BSQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
							BSQ->BSQ_COPCRE := aCobPag[1][2][22]
							BSQ->BSQ_TIPPE  := aCobPag[1][2][21]
							
							BSQ->(msUnLock())
							cCodSeq  := Soma1(cCodSeq)
						endIf
						
						if nVlrPag > 0 .and. BD7->BD7_TPESTO <> '2' .and. BD7->BD7_TPESTO <> '4'
							
							//Busco o lancamento de debito
							
							aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'1')
							
							//Se teve participacao eu gravo o debito para a rda do bd7	      
							
							
							BGQ->(recLock("BGQ",.t.))
							BGQ->BGQ_FILIAL := xFilial("BGQ")
							BGQ->BGQ_CODSEQ := BGQ->(GETSX8NUM("BGQ","BGQ_CODSEQ"));BGQ->(Confirmsx8())
							BGQ->BGQ_CODIGO := BD7->BD7_CODRDA
							BGQ->BGQ_NOME   := BD7->BD7_NOMRDA
							BGQ->BGQ_ANO    := aRetAux[4]
							BGQ->BGQ_MES    := aRetAux[5]
							BGQ->BGQ_CODLAN := aCobPag[2][2][1]
							BGQ->BGQ_TIPO   := '1'
							BGQ->BGQ_LANAUT := '1'
							BGQ->BGQ_VALOR  := nVlrPag
							BGQ->BGQ_TIPOCT := aCobPag[2][2][6]
							BGQ->BGQ_QTDCH  := aCobPag[2][2][4]
							BGQ->BGQ_INCIR  := aCobPag[2][2][7]
							BGQ->BGQ_INCINS := aCobPag[2][2][8]
							BGQ->BGQ_INCPIS := aCobPag[2][2][9]
							BGQ->BGQ_INCCOF := aCobPag[2][2][10]
							BGQ->BGQ_INCCSL := aCobPag[2][2][11]
							BGQ->BGQ_VERBA	:= aCobPag[2][2][12]
							BGQ->BGQ_CODOPE := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]
							BGQ->BGQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
							BGQ->BGQ_CONMFT := aCobPag[2][2][16]
							BGQ->BGQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
							BGQ->BGQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
							BGQ->BGQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
							BGQ->BGQ_SEQEST := cSeqEst
							BGQ->BGQ_COPCRE := aCobPag[2][2][19]
							BGQ->BGQ_TIPPE  := aCobPag[2][2][18]
							BGQ->BGQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
							BGQ->BGQ_INTERC := BD7->BD7_INTERC
							if len(aCobPag[2][2]) >= 20
								BGQ->BGQ_INCISS := aCobPag[2][2][20]
							endIf
							BGQ->(msUnLock())
						endIf
						
						//1 - Nenhum                                                      
						//2 - Estorno Pagamento                                           
						//3 - Estorno Cobranca                                            
						//4 - Ambos														
						
						BD7->(recLock("BD7",.f.))
						BD7->BD7_TPESTO := '4'
						BD7->BD7_CONCOB := '0'
						BD7->BD7_CONPAG := '0'
						BD7->BD7_CONMUS := '0'
						BD7->BD7_CONMRD := '0'
						
						BD7->(msUnLock())
						
						BD7->(dbSkip())
					endDo
				endIf
			endIf
		endIf
		
		//Agora estou na guia clonada										
		
		if aAcoes[nI][1] == __aCdCri120[1]
			cChavePro := aAcoes[nI][3]
			BD6->(dbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+cChavePro))
				
				IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
				BD6->(recLock("BD6",.f.))
				BD6->BD6_CONCOB := '1'
				BD6->BD6_CONPAG := '1'
				BD6->BD6_CONMUS := '1'
				BD6->BD6_CONMRD := '1'
				BD6->(msUnLock())
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						BD7->(recLock("BD7",.f.))
						BD7->BD7_CONCOB := '1'
						BD7->BD7_CONPAG := '1'
						BD7->BD7_CONMUS := '1'
						BD7->BD7_CONMRD := '1'
						BD7->(msUnLock())
						BD7->(dbSkip())
					endDo
				endIf
			endIf
		endIf
		
		//	546 - Valores divergentes entre os BD6_VLRTPF de duas guias		
		
	elseIf aAcoes[nI][1] == __aCdCri112[1]
		
		IncProcG1(STR0109+" [ "+allTrim(aAcoes[nI][1])+" - "+ allTrim(PLSBCTDESC())+" ]") //"Analisando critica"
		
		cChaveOri := aAcoes[nI][2]
		cChaveAtu := aAcoes[nI][3]
		
		BarGauge2Set(2)
		BD6->(dbSetOrder(1))
		if BD6->(msSeek(xFilial("BD6")+cChaveOri))
			
			IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
			
			BD6->(recLock("BD6",.f.))
			BD6->BD6_CONCOB := '0'
			BD6->BD6_CONMUS := '0'
			BD6->(msUnLock())
			
			if BD6->BD6_TPESTO <> '4' .and. BD6->BD6_TPESTO <> '3'
				
				
				//1 - Nenhum                                                      
				//2 - Estorno Pagamento                                           
				//3 - Estorno Cobranca                                            
				//4 - Ambos														
				
				BD6->(recLock("BD6",.f.))
				if BD6->BD6_TPESTO == '2'
					BD6->BD6_TPESTO := '4'
				elseIf BD6->BD6_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
					BD6->BD6_TPESTO := '3'
				endIf
				BD6->(msUnLock())
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						//Busco o valor de participacao do usuario
						
						nVlrTPf := BD7->BD7_VLRTPF
						
						if nVlrTPf > 0 .and. BD7->BD7_TPESTO <> '3' .and. BD7->BD7_TPESTO <> '4'
							
							//Busco o lancamento de credito
							
							aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'2')
							
							//Se teve participacao eu gravo o credito para o usuario da guia  
							//estornada
							
							BSQ->(recLock("BSQ",.t.))
							BSQ->BSQ_FILIAL := xFilial("BSQ")
							BSQ->BSQ_CODSEQ	:= cCodSeq
							
							//Quando eh usuario de intercambio eu so gravo a operadora
							
							if BD6->BD6_OPEORI <> PlsIntPad()
								BSQ->BSQ_CODINT := BD6->BD6_OPEORI
							else
								BSQ->BSQ_CODINT := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]
								BSQ->BSQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
								BSQ->BSQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
								BSQ->BSQ_VERCON := aGuiaOri[1][GetField(cAlias+"_VERCON",aCabec)]
								BSQ->BSQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
								BSQ->BSQ_VERSUB := aGuiaOri[1][GetField(cAlias+"_VERSUB",aCabec)]
								BSQ->BSQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
								BSQ->BSQ_USUARI := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_TIPREG",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_DIGITO",aCabec)]
							endIf
							BSQ->BSQ_ANO    := aRetAux[4]
							BSQ->BSQ_MES    := aRetAux[5]
							BSQ->BSQ_CODLAN := aCobPag[1][2][1]
							BSQ->BSQ_TIPO   := aCobPag[1][2][4]
							BSQ->BSQ_COMISS := aCobPag[1][2][6]
							BSQ->BSQ_ATOCOO := aCobPag[1][2][7]
							BSQ->BSQ_INCIR  := aCobPag[1][2][8]
							BSQ->BSQ_REGCIR := aCobPag[1][2][9]
							BSQ->BSQ_INCISS := aCobPag[1][2][10]
							BSQ->BSQ_REGCIS := aCobPag[1][2][11]
							BSQ->BSQ_INCCON := aCobPag[1][2][12]
							BSQ->BSQ_REGCCO := aCobPag[1][2][13]
							BSQ->BSQ_INCPIS := aCobPag[1][2][14]
							BSQ->BSQ_REGCPI := aCobPag[1][2][15]
							BSQ->BSQ_INCCSL := aCobPag[1][2][16]
							BSQ->BSQ_REGCCS := aCobPag[1][2][17]
							BSQ->BSQ_INCINS := aCobPag[1][2][18]
							BSQ->BSQ_REGCIN := aCobPag[1][2][19]
							BSQ->BSQ_REGCI1 := aCobPag[1][2][20]
							BSQ->BSQ_VALOR  := nVlrTPf
							BSQ->BSQ_AUTOMA := '1'
							BSQ->BSQ_COBNIV := _cNivel
							BSQ->BSQ_SEQEST := cSeqEst
							BSQ->BSQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
							BSQ->BSQ_COPCRE := aCobPag[1][2][22]
							BSQ->BSQ_TIPPE  := aCobPag[1][2][21]
							
							BSQ->(msUnLock())
							cCodSeq  := Soma1(cCodSeq)
						endIf
						
						//1 - Nenhum                                                      
						//2 - Estorno Pagamento                                           
						//3 - Estorno Cobranca                                            
						//4 - Ambos														
						
						BD7->(recLock("BD7",.f.))
						if BD7->BD7_TPESTO == '2'
							BD7->BD7_TPESTO := '4'
						elseIf BD7->BD7_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
							BD7->BD7_TPESTO := '3'
						endIf
						BD7->BD7_CONCOB := '0'
						BD7->BD7_CONMUS := '0'
						BD7->(msUnLock())
						
						BD7->(dbSkip())
					endDo
				endIf
			endIf
		endIf
		
		BD6->(dbSetOrder(1))
		if BD6->(msSeek(xFilial("BD6")+cChaveAtu))
			
			IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
			
			BD6->(recLock("BD6",.f.))
			BD6->BD6_CONCOB := '1'
			BD6->BD6_CONMUS := '1'
			BD6->(msUnLock())
			
			BD7->(dbSetOrder(1))
			if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
					
					BD7->(recLock("BD7",.f.))
					BD7->BD7_CONCOB := '1'
					BD7->BD7_CONMUS := '1'
					BD7->(msUnLock())
					
					BD7->(dbSkip())
				endDo
			endIf
		endIf
		
		//	548 - Codigo da R.D.A para pagamento de um mesmo subitem divergentes|
		//entre as guias													
		//547 - Valor de pagamento, do subitem de um mesmo procedimento para  |
		//a mesma R.D.A, divergentes entre as guias						
		
	elseIf aAcoes[nI][1] == __aCdCri114[1] .or. aAcoes[nI][1] == __aCdCri113[1]
		
		IncProcG1(STR0109+" [ "+allTrim(aAcoes[nI][1])+" - "+ allTrim(PLSBCTDESC())+" ]") //"Analisando critica"
		
		cChaveOri := aAcoes[nI][2]
		cChaveAtu := aAcoes[nI][3]
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+cChaveOri))
			
			//Busco o valor de participacao do usuario
			
			nVlrPag := BD7->BD7_VLRPAG
			
			if nVlrPag > 0 .and. BD7->BD7_TPESTO <> '2' .and. BD7->BD7_TPESTO <> '4'
				
				//Busco o lancamento de dbedito
				
				aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'1')
				
				BGQ->(recLock("BGQ",.t.))
				BGQ->BGQ_FILIAL := xFilial("BGQ")
				BGQ->BGQ_CODSEQ := BGQ->(GETSX8NUM("BGQ","BGQ_CODSEQ"));BGQ->(Confirmsx8())
				BGQ->BGQ_CODIGO := BD7->BD7_CODRDA
				BGQ->BGQ_NOME   := BD7->BD7_NOMRDA
				BGQ->BGQ_ANO    := aRetAux[4]
				BGQ->BGQ_MES    := aRetAux[5]
				BGQ->BGQ_CODLAN := aCobPag[2][2][1]
				BGQ->BGQ_TIPO   := '1'
				BGQ->BGQ_LANAUT := '1'
				BGQ->BGQ_VALOR  := nVlrPag
				BGQ->BGQ_TIPOCT := aCobPag[2][2][6]
				BGQ->BGQ_QTDCH  := aCobPag[2][2][4]
				BGQ->BGQ_INCIR  := aCobPag[2][2][7]
				BGQ->BGQ_INCINS := aCobPag[2][2][8]
				BGQ->BGQ_INCPIS := aCobPag[2][2][9]
				BGQ->BGQ_INCCOF := aCobPag[2][2][10]
				BGQ->BGQ_INCCSL := aCobPag[2][2][11]
				BGQ->BGQ_VERBA  := aCobPag[2][2][12]
				BGQ->BGQ_CODOPE := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]
				BGQ->BGQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
				BGQ->BGQ_CONMFT := aCobPag[2][2][16]
				BGQ->BGQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
				BGQ->BGQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
				BGQ->BGQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
				BGQ->BGQ_SEQEST := cSeqEst
				BGQ->BGQ_COPCRE := aCobPag[2][2][19]
				BGQ->BGQ_TIPPE  := aCobPag[2][2][18]
				BGQ->BGQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
				BGQ->BGQ_INTERC := BD7->BD7_INTERC
				if len(aCobPag[2][2]) >= 20
					BGQ->BGQ_INCISS := aCobPag[2][2][20]
				endIf
				BGQ->(msUnLock())
			endIf
			
			//1 - Nenhum                                                      
			//2 - Estorno Pagamento                                           
			//3 - Estorno Cobranca                                            
			//4 - Ambos														
			
			BD7->(recLock("BD7",.f.))
			if BD7->BD7_TPESTO == '3'
				BD7->BD7_TPESTO := '4'
			elseIf BD7->BD7_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
				BD7->BD7_TPESTO := '2'
			endIf
			BD7->BD7_CONPAG := '0'
			BD7->BD7_CONMRD := '0'
			BD7->(msUnLock())
		endIf
		BD7->(dbSetOrder(1))
		
		//Agora estou na guia estornada									
		
		if BD7->(msSeek(xFilial("BD7")+cChaveAtu))
			BD7->(recLock("BD7",.f.))
			BD7->BD7_CONPAG := '1'
			BD7->BD7_CONMRD := '1'
			BD7->(msUnLock())
		endIf
		
		//	546 - Procedimento nao encontrado na guia estornada				
		
	elseIf aAcoes[nI][1] == __aCdCri121[1]
		
		IncProcG1(STR0109+" [ "+allTrim(aAcoes[nI][1])+" - "+ allTrim(PLSBCTDESC())+" ]") //"Analisando critica"
		
		cChaveAtu := aAcoes[nI][2]
		
		BD6->(dbSetOrder(1))
		if BD6->(msSeek(xFilial("BD6")+cChaveAtu))
			
			BD6->(recLock("BD6",.f.))
			BD6->BD6_CONCOB := '1'
			BD6->BD6_CONMUS := '1'
			BD6->BD6_CONPAG := '1'
			BD6->BD6_CONMRD := '1'
			BD6->(msUnLock())
			
			BD7->(dbSetOrder(1))
			if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
					
					BD7->(recLock("BD7",.f.))
					BD7->BD7_CONCOB := '1'
					BD7->BD7_CONMUS := '1'
					BD7->BD7_CONPAG := '1'
					BD7->BD7_CONMRD := '1'
					BD7->(msUnLock())
					
					BD7->(dbSkip())
				endDo
			endIf
		endIf
		
		//	557 - Subitem nao localizado na guia clonada.					
		
	elseIf aAcoes[nI][1] == __aCdCri149[1]

		IncProcG1(STR0109+" [ "+allTrim(__aCdCri149[1])+" - "+ allTrim(PLSBCTDESC())+" ]")
		
		cChaveOri := aAcoes[nI][2]
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+cChaveOri))
			
			nVlrPag := BD7->BD7_VLRPAG
			
			if nVlrPag > 0 .and. BD7->BD7_TPESTO <> '2' .and. BD7->BD7_TPESTO <> '4'
				
				//Busco o lancamento de dbedito
				
				aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'1')
				
				BGQ->(recLock("BGQ",.t.))
				BGQ->BGQ_FILIAL := xFilial("BGQ")
				BGQ->BGQ_CODSEQ := BGQ->(GETSX8NUM("BGQ","BGQ_CODSEQ"));BGQ->(Confirmsx8())
				BGQ->BGQ_CODIGO := BD7->BD7_CODRDA
				BGQ->BGQ_NOME   := BD7->BD7_NOMRDA
				BGQ->BGQ_ANO    := aRetAux[4]
				BGQ->BGQ_MES    := aRetAux[5]
				BGQ->BGQ_CODLAN := aCobPag[2][2][1]
				BGQ->BGQ_TIPO   := '1'
				BGQ->BGQ_LANAUT := '1'
				BGQ->BGQ_VALOR  := nVlrPag
				BGQ->BGQ_TIPOCT := aCobPag[2][2][6]
				BGQ->BGQ_QTDCH  := aCobPag[2][2][4]
				BGQ->BGQ_INCIR  := aCobPag[2][2][7]
				BGQ->BGQ_INCINS := aCobPag[2][2][8]
				BGQ->BGQ_INCPIS := aCobPag[2][2][9]
				BGQ->BGQ_INCCOF := aCobPag[2][2][10]
				BGQ->BGQ_INCCSL := aCobPag[2][2][11]
				BGQ->BGQ_VERBA  := aCobPag[2][2][12]
				BGQ->BGQ_CODOPE := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]
				BGQ->BGQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
				BGQ->BGQ_CONMFT := aCobPag[2][2][16]
				BGQ->BGQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
				BGQ->BGQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
				BGQ->BGQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
				BGQ->BGQ_SEQEST := cSeqEst
				BGQ->BGQ_COPCRE := aCobPag[2][2][19]
				BGQ->BGQ_TIPPE  := aCobPag[2][2][18]
				BGQ->BGQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
				BGQ->BGQ_INTERC := BD7->BD7_INTERC
				if  len(aCobPag[2][2]) >= 20
					BGQ->BGQ_INCISS := aCobPag[2][2][20]
				endIf
				BGQ->(msUnLock())
			endIf
			
			//1 - Nenhum                                                      
			//2 - Estorno Pagamento                                           
			//3 - Estorno Cobranca                                            
			//4 - Ambos														
			
			BD7->(recLock("BD7",.f.))
			if BD7->BD7_TPESTO == '3'
				BD7->BD7_TPESTO := '4'
			elseIf BD7->BD7_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
				BD7->BD7_TPESTO := '2'
			endIf
			BD7->BD7_CONPAG := '0'
			BD7->BD7_CONMRD := '0'
			BD7->(msUnLock())
		endIf
		
		//	558 - Bloqueio de cobranca divergente entre os procedimentos.	
		
	elseIf aAcoes[nI][1] == __aCdCri150[1]

		IncProcG1(STR0109+" [ "+allTrim(aAcoes[nI][1])+" - "+ allTrim(PLSBCTDESC())+" ]") //"Analisando critica"
		
		if  aAcoes[nI][4] == '1' //tipo um
			
			BD6->(dbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+aAcoes[nI][3]))
				
				BD6->(recLock("BD6",.f.))
				BD6->BD6_CONCOB := '1'
				BD6->BD6_CONMUS := '1'
				BD6->(msUnLock())
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						BD7->(recLock("BD7",.f.))
						BD7->BD7_CONCOB := '1'
						BD7->BD7_CONMUS := '1'
						BD7->(msUnLock())
						
						BD7->(dbSkip())
					endDo
				endIf
			endIf
			
		else
			BD6->(dbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+aAcoes[nI][2]))
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						
						//Busco o valor de participacao do usuario
						
						nVlrTPf := BD7->BD7_VLRTPF
						
						if nVlrTPf > 0 .and. BD7->BD7_TPESTO <> '3' .and. BD7->BD7_TPESTO <> '4'
							
							//Busco o lancamento de credito
							
							aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'2')
							
							//Se teve participacao eu gravo o credito para o usuario da guia  
							//estornada
							
							BSQ->(recLock("BSQ",.t.))
							BSQ->BSQ_FILIAL := xFilial("BSQ")
							BSQ->BSQ_CODSEQ	:= cCodSeq
							
							//Quando eh usuario de intercambio eu so gravo a operadora
							
							if BD6->BD6_OPEORI <> PlsIntPad()
								BSQ->BSQ_CODINT := BD6->BD6_OPEORI
							else
								BSQ->BSQ_CODINT := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]
								BSQ->BSQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
								BSQ->BSQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
								BSQ->BSQ_VERCON := aGuiaOri[1][GetField(cAlias+"_VERCON",aCabec)]
								BSQ->BSQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
								BSQ->BSQ_VERSUB := aGuiaOri[1][GetField(cAlias+"_VERSUB",aCabec)]
								BSQ->BSQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
								BSQ->BSQ_USUARI := aGuiaOri[1][GetField(cAlias+"_OPEUSR",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_TIPREG",aCabec)]+;
									aGuiaOri[1][GetField(cAlias+"_DIGITO",aCabec)]
							endIf
							BSQ->BSQ_ANO    := aRetAux[4]
							BSQ->BSQ_MES    := aRetAux[5]
							BSQ->BSQ_CODLAN := aCobPag[1][2][1]
							BSQ->BSQ_TIPO   := aCobPag[1][2][4]
							BSQ->BSQ_COMISS := aCobPag[1][2][6]
							BSQ->BSQ_ATOCOO := aCobPag[1][2][7]
							BSQ->BSQ_INCIR  := aCobPag[1][2][8]
							BSQ->BSQ_REGCIR := aCobPag[1][2][9]
							BSQ->BSQ_INCISS := aCobPag[1][2][10]
							BSQ->BSQ_REGCIS := aCobPag[1][2][11]
							BSQ->BSQ_INCCON := aCobPag[1][2][12]
							BSQ->BSQ_REGCCO := aCobPag[1][2][13]
							BSQ->BSQ_INCPIS := aCobPag[1][2][14]
							BSQ->BSQ_REGCPI := aCobPag[1][2][15]
							BSQ->BSQ_INCCSL := aCobPag[1][2][16]
							BSQ->BSQ_REGCCS := aCobPag[1][2][17]
							BSQ->BSQ_INCINS := aCobPag[1][2][18]
							BSQ->BSQ_REGCIN := aCobPag[1][2][19]
							BSQ->BSQ_REGCI1 := aCobPag[1][2][20]
							BSQ->BSQ_VALOR  := nVlrTPf
							BSQ->BSQ_AUTOMA := '1'
							BSQ->BSQ_COBNIV := _cNivel
							BSQ->BSQ_SEQEST := cSeqEst
							BSQ->BSQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
							BSQ->BSQ_COPCRE := aCobPag[1][2][22]
							BSQ->BSQ_TIPPE  := aCobPag[1][2][21]
							
							BSQ->(msUnLock())
							cCodSeq  := Soma1(cCodSeq)
							
							//1 - Nenhum                                                      
							//2 - Estorno Pagamento                                           
							//3 - Estorno Cobranca                                            
							//4 - Ambos															  |
							
							BD7->(recLock("BD7",.f.))
							if BD7->BD7_TPESTO == '2'
								BD7->BD7_TPESTO := '4'
							elseIf BD7->BD7_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
								BD7->BD7_TPESTO := '3'
							endIf
							BD7->BD7_CONCOB := '0'
							BD7->BD7_CONMUS := '0'
							BD7->(msUnLock())
							
						endIf
						BD7->(dbSkip())
					endDo
				endIf
			endIf
			//vou lah no clone
			BD6->(dbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+aAcoes[nI][3]))
				
				BD6->(recLock("BD6",.f.))
				BD6->BD6_CONCOB := '1'
				BD6->BD6_CONMUS := '1'
				BD6->(msUnLock())
				
				BD7->(dbSetOrder(1))
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
						
						BD7->(recLock("BD7",.f.))
						BD7->BD7_CONCOB := '1'
						BD7->BD7_CONMUS := '1'
						BD7->(msUnLock())
						
						BD7->(dbSkip())
					endDo
				endIf
			endIf
			
		endIf
		
		//	559 - Bloqueio de pagamento divergente entre os procedimentos.	
		
	elseIf aAcoes[nI][1]  == __aCdCri151[1]
		if aAcoes[nI][4] == '1'
			BD7->(dbSetOrder(1))
			if BD7->(msSeek(xFilial("BD7")+aAcoes[nI][3]))
				BD7->(recLock("BD7",.f.))
				BD7->BD7_CONPAG := '1'
				BD7->BD7_CONMRD := '1'
				BD7->(msUnLock())
			endIf
		else
			BD7->(dbSetOrder(1))
			if BD7->(msSeek(xFilial("BD7")+aAcoes[nI][2]))
				
				//Busco o valor de participacao do usuario
				
				nVlrPag := BD7->BD7_VLRPAG
				
				if nVlrPag > 0 .and. BD7->BD7_TPESTO <> '2' .and. BD7->BD7_TPESTO <> '4'
					
					//Busco o lancamento de dbedito
					
					aCobPag := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'1')
					
					BGQ->(recLock("BGQ",.t.))
					BGQ->BGQ_FILIAL := xFilial("BGQ")
					BGQ->BGQ_CODSEQ := BGQ->(GETSX8NUM("BGQ","BGQ_CODSEQ"));BGQ->(Confirmsx8())
					BGQ->BGQ_CODIGO := BD7->BD7_CODRDA
					BGQ->BGQ_NOME   := BD7->BD7_NOMRDA
					BGQ->BGQ_ANO    := aRetAux[4]
					BGQ->BGQ_MES    := aRetAux[5]
					BGQ->BGQ_CODLAN := aCobPag[2][2][1]
					BGQ->BGQ_TIPO   := '1'
					BGQ->BGQ_LANAUT := '1'
					BGQ->BGQ_VALOR  := nVlrPag
					BGQ->BGQ_TIPOCT := aCobPag[2][2][6]
					BGQ->BGQ_QTDCH  := aCobPag[2][2][4]
					BGQ->BGQ_INCIR  := aCobPag[2][2][7]
					BGQ->BGQ_INCINS := aCobPag[2][2][8]
					BGQ->BGQ_INCPIS := aCobPag[2][2][9]
					BGQ->BGQ_INCCOF := aCobPag[2][2][10]
					BGQ->BGQ_INCCSL := aCobPag[2][2][11]
					BGQ->BGQ_VERBA  := aCobPag[2][2][12]
					BGQ->BGQ_CODOPE := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]
					BGQ->BGQ_CODEMP := aGuiaOri[1][GetField(cAlias+"_CODEMP",aCabec)]
					BGQ->BGQ_CONMFT := aCobPag[2][2][16]
					BGQ->BGQ_MATRIC := aGuiaOri[1][GetField(cAlias+"_MATRIC",aCabec)]
					BGQ->BGQ_CONEMP := aGuiaOri[1][GetField(cAlias+"_CONEMP",aCabec)]
					BGQ->BGQ_SUBCON := aGuiaOri[1][GetField(cAlias+"_SUBCON",aCabec)]
					BGQ->BGQ_SEQEST := cSeqEst
					BGQ->BGQ_COPCRE := aCobPag[2][2][19]
					BGQ->BGQ_TIPPE  := aCobPag[2][2][18]
					BGQ->BGQ_CHVEST := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC)
					BGQ->BGQ_INTERC := BD7->BD7_INTERC
					if  len(aCobPag[2][2]) >= 20
						BGQ->BGQ_INCISS := aCobPag[2][2][20]
					endIf
					BGQ->(msUnLock())
				endIf
				
				//1 - Nenhum                                                      
				//2 - Estorno Pagamento                                           
				//3 - Estorno Cobranca                                            
				//4 - Ambos														
				
				BD7->(recLock("BD7",.f.))
				if BD7->BD7_TPESTO == '3'
					BD7->BD7_TPESTO := '4'
				elseIf BD7->BD7_TPESTO == '1' .or. empty(BD7->BD7_TPESTO)
					BD7->BD7_TPESTO := '2'
				endIf
				BD7->BD7_CONPAG := '0'
				BD7->BD7_CONMRD := '0'
				BD7->(msUnLock())
			endIf
			
			//vou lah no clone
			BD7->(dbSetOrder(1))
			if BD7->(msSeek(xFilial("BD7")+aAcoes[nI][3]))
				BD7->(recLock("BD7",.f.))
				BD7->BD7_CONPAG := '1'
				BD7->BD7_CONMRD := '1'
				BD7->(msUnLock())
			endIf
		endIf
	endIf
next

BarGauge1Set(2)
IncProcG1(STR0110) //"Atualizações finais na guia estornada"

//Atualizacoes finais guia estornada								

BD6->(dbSetOrder(1))
if BD6->(msSeek(xFilial("BD6")+cGuiOri))
	while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cGuiOri
		
		IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
		
		lBD7ConPag := .f.
		lBD7ConMrd := .f.
		lBD7ConCob := .f.
		lBD7ConMus := .f.
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				if BD7->BD7_CONPAG == '0'
					lBD7ConPag := .t.
				endIf
				if BD7->BD7_CONMRD == '0'
					lBD7ConMrd := .t.
				endIf
				if BD7->BD7_CONCOB == '0'
					lBD7ConCob := .t.
				endIf
				if BD7->BD7_CONMUS == '0'
					lBD7ConMus := .t.
				endIf
				BD7->(dbSkip())
			endDo
		endIf
		
		BD6->(recLock("BD6",.f.))
		if !lBD7ConPag
			BD6->BD6_CONPAG := '1'
		endIf
		if !lBD7ConMrd
			BD6->BD6_CONMRD := '1'
		endIf
		if !lBD7ConCob
			BD6->BD6_CONCOB := '1'
		endIf
		if !lBD7ConMus
			BD6->BD6_CONMUS := '1'
		endIf
		BD6->(msUnLock())
		
		BD6->(dbSkip())
	endDo
endIf

//Atualizacoes finais guia clonada									

IncProcG1(STR0111) //"Atualizações finais na guia clonada"

BD6->(dbSetOrder(1))
if BD6->(msSeek(xFilial("BD6")+cGuiAtu))
	while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cGuiAtu
		
		IncProcG2(STR0108+" [ "+allTrim(BD6->BD6_CODPRO)+" - "+ subs(BD6->BD6_DESPRO,1,40)+" ]") //"Analisando procedimento"
		
		lBD7ConPag := .f.
		lBD7ConMrd := .f.
		lBD7ConCob := .f.
		lBD7ConMus := .f.
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				if BD7->BD7_CONPAG == '0'
					lBD7ConPag := .t.
				endIf
				if BD7->BD7_CONMRD == '0'
					lBD7ConMrd := .t.
				endIf
				if BD7->BD7_CONCOB == '0'
					lBD7ConCob := .t.
				endIf
				if BD7->BD7_CONMUS == '0'
					lBD7ConMus := .t.
				endIf
				
				BD7->(dbSkip())
			endDo
		endIf
		
		BD6->(recLock("BD6",.f.))
		if !lBD7ConPag
			BD6->BD6_CONPAG := '1'
		endIf
		if !lBD7ConMrd
			BD6->BD6_CONMRD := '1'
		endIf
		if !lBD7ConCob
			BD6->BD6_CONCOB := '1'
		endIf
		if !lBD7ConMus
			BD6->BD6_CONMUS := '1'
		endIf
		BD6->(msUnLock())
		
		BD6->(dbSkip())
		
	endDo
endIf

Eval(bRest)

return

/*/{Protheus.doc} PLSA500CAN
Vou cancelar o estorno
@type function
@author plsteam
@since   1 13.05.2005
@version 1.0
/*/
function PLSA500CAN(cAlias,nReg,nOpc,aFields,lMsg)
local cChaveGui := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local cChaveAtu := "" //chave do clone
local cChaveOri := ""//chave da guia origem
local cSeqEst   := ""
local cFiltAli  := ""
local aRegBSQ   := {}
local aRegBGQ   := {}
local aRegB35	:= {}
local lErrBSQ   := .f.
local lErrBGQ   := .f.
local dDatCtbChk:= StoD("")
local nI		:= 0
local aArea		:= getArea()
local aFiles	:= {}
default aFields := nil
default lMsg    := .t.

dDatCtbChk := PLRtDtCTB(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO"), .F.)

if PLVLDBLQCO(dDatCtbChk, {"PLS011"}, lMsg) //verifica se a database está no periodo contabil e se estiver não pode cancelar o estorno
	
	//Compatibilizador tem q ter sido executado
	if &(cAlias+"->(fieldPos('"+cAlias+"_GUESTO'))") == 0
		if lMsg
			Help("",1,"PLSA500028")
		endIf
		restArea(aArea)
		return
	endIf
	
	//Verifico aonde o usuario esta posicionado
	
	if &(cAlias+"->"+cAlias+"_ESTORI") == '0'//estou posicionado no clone
		cChaveAtu := cChaveGui //chave do clone
		cChaveOri := allTrim(&(cAlias+"->"+cAlias+"_GUESTO"))//chave da guia origem
	else
		cChaveAtu := allTrim(&(cAlias+"->"+cAlias+"_GUESTO"))       //chave do clone
		cChaveOri := cChaveGui//chave da guia origem
	endIf
	
	//Posiciono no clone
	
	if findFunction("tcSqlFilter()")//teoricamente sempre tem q entrar aqui
		cFiltAli := &(cAlias+"->(tcSqlFilter())")
	else
		cFiltAli := RetFiltro(cAlias,"BCI")
	endIf
	&(cAlias+"->(dbClearFilter())")
	
	DbSelectArea(cAlias)
	dbSetOrder(1)
	msSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))
	
	//Validacoes iniciais
	
	if empty(&(cAlias+"->"+cAlias+"_SEQEST"))
		if lMsg
			help("",1,"PLSA500022")
		endIf
		if !empty(cFiltAli)
			DbSelectArea(cAlias)
			dbSetFilter({||&cFiltAli},cFiltAli)
		endIf
		restArea(aArea)
		return
	endIf
	if &(cAlias+"->"+cAlias+"_FASE") <> '3'
		if lMsg
			help("",1,"PLSA500023")
		endIf
		if !empty(cFiltAli)
			DbSelectArea(cAlias)
			dbSetFilter({||&cFiltAli},cFiltAli)
		endIf
		restArea(aArea)
		return
	endIf
	cSeqEst := &(cAlias+"->"+cAlias+"_SEQEST")
	
	//Varro os lancamentos de debito/credito ref ao estorno
	
	BSQ->(dbSetOrder(7))
	if BSQ->(msSeek(xFilial("BSQ")+cSeqEst))
		while !BSQ->(eof()) .and. BSQ->(BSQ_FILIAL+BSQ_SEQEST) == xFilial("BSQ")+cSeqEst
			aadd(aRegBSQ,BSQ->(recno()))
			if !empty(BSQ->BSQ_NUMCOB)
				lErrBSQ := .t.
			endIf
			BSQ->(dbSkip())
		endDo
	endIf
	
	//Varro os lancamentos de debito/credito ref ao estorno
	
	BGQ->(dbSetOrder(6))
	if BGQ->(msSeek(xFilial("BGQ")+cSeqEst))
		while !BGQ->(eof()) .and. BGQ->(BGQ_FILIAL+BGQ_SEQEST) == xFilial("BGQ")+cSeqEst
			aadd(aRegBGQ,BGQ->(recno()))
			if !empty(BGQ->BGQ_NUMLOT)
				lErrBGQ := .t.
			endIf
			BGQ->(dbSkip())
		endDo
	endIf
	
	//Adiciono os B35 ref ao lancamento em um array
	
	B35->(dbSetOrder(1))
	if B35->(msSeek(xFilial("B35")+cChaveOri))
		while !B35->(eof()) .and. B35->(B35_FILIAL+B35_CODOPE+B35_CODLDP+B35_CODPEG+B35_NUMERO+B35_ORIMOV) == xFilial("B35")+cChaveOri
			aadd(aRegB35,B35->(recno()))
			B35->(dbSkip())
		endDo
	endIf
	
	//Se existem erros na tabela BSQ ou BGQ ja faturados eu nao posso cancelar
	
	if lErrBSQ .or. lErrBGQ
		if lMsg
			help("",1,"PLSA500025")
		endIf
		if !empty(cFiltAli)
			DbSelectArea(cAlias)
			dbSetFilter({||&cFiltAli},cFiltAli)
		endIf
		
		restArea(aArea)
		return
	else
		if lMsg .and. !msgYesNo(STR0114) //"Deseja desfazer as ações de estorno já realizadas?"
			if !empty(cFiltAli)
				DbSelectArea(cAlias)
				dbSetFilter({||&cFiltAli},cFiltAli)
			endIf
			restArea(aArea)
			return
		endIf
		begin transaction
			
			//Excluo os BGQ referentes ao estorno
			for nI := 1 to len(aRegBGQ)
				BGQ->(dbGoto(aRegBGQ[nI]))
				BGQ->(recLock("BGQ",.f.))
				BGQ->(DbDelete())
				BGQ->(msUnLock())
			next
			
			//Excluo os BSQ referentes ao estorno
			for nI:=1 to len(aRegBSQ)
				BSQ->(dbGoto(aRegBSQ[nI]))
				BSQ->(recLock("BSQ",.f.))
				BSQ->(DbDelete())
				BSQ->(msUnLock())
			next
			
			//Excluo os B35 referentes ao estorno
			for nI:=1 to len(aRegB35)
				B35->(dbGoto(aRegB35[nI]))
				B35->(recLock("B35",.f.))
				B35->(DbDelete())
				B35->(msUnLock())
			next
			
			//Posiciono na guia origem para limpar os campos
			DbSelectArea(cAlias)
			dbSetOrder(1)
			if msSeek(xFilial(cAlias)+subs(cChaveOri,1,24))
				recLock(cAlias,.f.)
				&(cAlias+"_SEQEST") := ''
				msUnLock()
			endIf
			
			//Limpo os campos do BD6 da guia origem
			BD6->(dbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+cChaveOri))
				while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) ==  xFilial("BD6")+cChaveOri
					
					BD7->(dbSetOrder(1))
					if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					
						while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
													xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
							
							BD7->(recLock("BD7",.f.))
							BD7->BD7_TPESTO := '1'
							
							//[1] XXX_CONCOB [2] XXX_CONPAG [3] XXX_CONMUS [4] XXX_CONMRD		
							//Cons.Cob? - Considera o registro na hora de gerar a cobrança ?  
							//Cons.Pag? - Considera o registro na hora de gerar o pagamento ? 
							//Cons.M.U? - Considera o registro como movimento do usuario?     
							//Cons.M.R? - Considera o registro como movimento da RDA?			
							
							BD7->BD7_CONCOB  := '1'
							BD7->BD7_CONPAG  := '1'
							BD7->BD7_CONMUS  := '1'
							BD7->BD7_CONMRD  := '1'
							BD7->(msUnLock())
							
							BD7->(dbSkip())
						endDo
					endIf
					
					BD6->(recLock("BD6",.f.))
					BD6->BD6_TPESTO := '1'
					
					//[1] XXX_CONCOB [2] XXX_CONPAG [3] XXX_CONMUS [4] XXX_CONMRD		
					//Cons.Cob? - Considera o registro na hora de gerar a cobrança ?  
					//Cons.Pag? - Considera o registro na hora de gerar o pagamento ? 
					//Cons.M.U? - Considera o registro como movimento do usuario?     
					//Cons.M.R? - Considera o registro como movimento da RDA?			
					
					BD6->BD6_CONCOB  := '1'
					BD6->BD6_CONPAG  := '1'
					BD6->BD6_CONMUS  := '1'
					BD6->BD6_CONMRD  := '1'
					BD6->(msUnLock())
					
					BD6->(dbSkip())
				endDo
			endIf
			
			//Posiciono na guia clonada para limpar os campos
			
			DbSelectArea(cAlias)
			dbSetOrder(1)
			if msSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))
				recLock(cAlias,.f.)
				&(cAlias+"_SEQEST") := ''
				msUnLock()
			endIf
			
			//Limpo os campos do BD6 da guia clonada
			
			BD6->(dbSetOrder(1))
			if BD6->(msSeek(xFilial("BD6")+cChaveAtu))
				while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
						xFilial("BD6")+cChaveAtu
					BD7->(dbSetOrder(1))
					if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
						while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
								xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
							
							BD7->(recLock("BD7",.f.))
							BD7->BD7_TPESTO  := '1'
							
							//[1] XXX_CONCOB [2] XXX_CONPAG [3] XXX_CONMUS [4] XXX_CONMRD		
							//Cons.Cob? - Considera o registro na hora de gerar a cobrança ?  
							//Cons.Pag? - Considera o registro na hora de gerar o pagamento ? 
							//Cons.M.U? - Considera o registro como movimento do usuario?     
							//Cons.M.R? - Considera o registro como movimento da RDA?			
							
							BD7->BD7_CONCOB  := '0'
							BD7->BD7_CONPAG  := '0'
							BD7->BD7_CONMUS  := '0'
							BD7->BD7_CONMRD  := '0'
							BD7->(msUnLock())
							
							BD7->(dbSkip())
						endDo
					endIf
					
					BD6->(recLock("BD6",.f.))
					BD6->BD6_TPESTO := '1'
					
					//[1] XXX_CONCOB [2] XXX_CONPAG [3] XXX_CONMUS [4] XXX_CONMRD		
					//Cons.Cob? - Considera o registro na hora de gerar a cobrança ?  
					//Cons.Pag? - Considera o registro na hora de gerar o pagamento ? 
					//Cons.M.U? - Considera o registro como movimento do usuario?     
					//Cons.M.R? - Considera o registro como movimento da RDA?			
					
					BD6->BD6_CONCOB  := '0'
					BD6->BD6_CONPAG  := '0'
					BD6->BD6_CONMUS  := '0'
					BD6->BD6_CONMRD  := '0'
					BD6->(msUnLock())
					
					BD6->(dbSkip())
				endDo
			endIf
		end transaction
		
		if lMsg
			msgInfo(STR0115) //"Cancelamento concluido com sucesso !!!"
		endIf
		
		//bloqueia a guia após o cancelamento
		BCL->(dbSetOrder(1))
		if BCL->(msSeek(xFilial("BCL")+BCI->(BCI_CODOPE+BCI_TIPGUI)))
			aFiles  := PLSA500Fil(BCL->BCL_CODOPE,BCL->BCL_TIPGUI)
		endIf	
		
		PLSA500STA("3",&(cAlias+"->"+cAlias+"_CODOPE"),&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),&(cAlias+"->"+cAlias+"_ORIMOV"),aFiles,BCL->BCL_FUNGRV,K_Bloqueio,BCL->BCL_TIPGRV,BCL->BCL_ALIAS,getNewPar("MV_PLGUIES","123"))
		
	endIf
	if !empty(cFiltAli)
		DbSelectArea(cAlias)
		dbSetFilter({||&cFiltAli},cFiltAli)
	endIf
	
endIf

restArea(aArea)

return

/*/{Protheus.doc} PlValidEst

@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PlValidEst(cAlias,aGuiaOri,aGuiaAtu,aCabec,aItens,aSubItens,lFatal)
local cChaveOri := aGuiaOri[1][GetField(cAlias+"_CODOPE",aCabec)]+aGuiaOri[1][GetField(cAlias+"_CODLDP",aCabec)]+;
	aGuiaOri[1][GetField(cAlias+"_CODPEG",aCabec)]+aGuiaOri[1][GetField(cAlias+"_NUMERO",aCabec)]+;
	aGuiaOri[1][GetField(cAlias+"_ORIMOV",aCabec)]

local cChaveAtu := aGuiaAtu[1][GetField(cAlias+"_CODOPE",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_CODLDP",aCabec)]+;
	aGuiaAtu[1][GetField(cAlias+"_CODPEG",aCabec)]+aGuiaAtu[1][GetField(cAlias+"_NUMERO",aCabec)]+;
	aGuiaAtu[1][GetField(cAlias+"_ORIMOV",aCabec)]
local aLanPag	 := {}
local aLanCob	 := {}
local aLanCre	 := {}
local aLanDeb	 := {}
local aCriticas  := {}
local aCliente	 := {}
local aRetAux	 := {}
local lRet 		 := .t.
local nRecBD6	 := BD6->(recno())
local nOrdBD6    := BD6->(IndexOrd())
local nRecBD7    := BD7->(recno())
local nOrdBD7    := BD7->(IndexOrd())
local bRest      := { || BD6->(dbSetOrder(nOrdBD6)), BD6->(dbGoto(nRecBD6)),;
	BD7->(dbSetOrder(nOrdBD7)), BD7->(dbGoto(nRecBD7)) }
local nI		 := 1
local nJ 		 := 1


aRetAux := PLSXVLDCAL(dDataBase,aGuiaAtu[1][GetField(cAlias+"_CODOPE",aCabec)],.f.,"","")

if ! aRetAux[1]
	aadd(aCriticas,aRetAux[2])
endIf

BD6->(dbSetOrder(1))
if BD6->(msSeek(xFilial("BD6")+cChaveOri))
	
	aCliente := PLSRETNCB(BD6->BD6_OPEUSR,BD6->BD6_CODEMP,BD6->BD6_MATRIC,BD6->BD6_OPEORI)

	if !aCliente[1]

		aadd(aCriticas,{{__aCdCri116[1],__aCdCri116[2],'','','',''},;
						{'',STR0198,allTrim(BD6->BD6_NOMUSR),'','',''},; //"Nome do Usuário"
						{'',STR0199,allTrim(BD6->(BD6_OPEUSR+'.'+BD6_CODEMP+'.'+BD6_MATRIC+'.'+BD6_TIPREG+'-'+BD6_DIGITO)),'','',''}})		 //"Matrícula do usuário"
	endIf
	
	while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cChaveOri
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		
			while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				
				aLanCre := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'2')
				aLanDeb := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'1')
				
				if len(aLanCre[1][3]) > 0
					aadd(aCriticas,aLanCre[1][3])
				endIf
				if len(aLanCre[2][3]) > 0
					aadd(aCriticas,aLanCre[2][3])
				endIf
				if len(aLanDeb[1][3]) > 0
					aadd(aCriticas,aLanDeb[1][3])
				endIf
				if len(aLanDeb[2][3]) > 0
					aadd(aCriticas,aLanDeb[2][3])
				endIf
				
				BD7->(dbSkip())
			endDo
		endIf
		BD6->(dbSkip())
	endDo
endIf

BD6->(dbSetOrder(1))
if BD6->(msSeek(xFilial("BD6")+cChaveAtu))
	
	aCliente := PLSRETNCB(BD6->BD6_OPEUSR,BD6->BD6_CODEMP,BD6->BD6_MATRIC,BD6->BD6_OPEORI)
	if !aCliente[1]
		aadd(aCriticas,{{__aCdCri116[1],__aCdCri116[2],'','','',''},;
			            {'',STR0198,allTrim(BD6->BD6_NOMUSR),'','',''},; //"Nome do Usuário"
		                {'',STR0199,allTrim(BD6->(BD6_OPEUSR+'.'+BD6_CODEMP+'.'+BD6_MATRIC+'.'+BD6_TIPREG+'-'+BD6_DIGITO)),'','',''}})		 //"Matrícula do usuário"
	endIf
	
	while !BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
			xFilial("BD6")+cChaveAtu
		
		BD7->(dbSetOrder(1))
		if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				
				aLanCre := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'2')
				aLanDeb := PlRetDeCre(BD7->BD7_CODRDA,BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG),aLanPag,aLanCob,'1')
				
				if len(aLanCre[1][3]) > 0
					aadd(aCriticas,aLanCre[1][3])
				endIf
				if len(aLanCre[2][3]) > 0
					aadd(aCriticas,aLanCre[2][3])
				endIf
				if len(aLanDeb[1][3]) > 0
					aadd(aCriticas,aLanDeb[1][3])
				endIf
				if len(aLanDeb[2][3]) > 0
					aadd(aCriticas,aLanDeb[2][3])
				endIf
				
				BD7->(dbSkip())
			endDo
		endIf
		BD6->(dbSkip())
	endDo
endIf


Eval(bRest)

if len(aCriticas) > 0
	lRet := .f.
	aAux := {}
	for nI := 1 to len(aCriticas)
		for nJ := 1 to len(aCriticas[nI])
			aadd(aAux,aCriticas[nI][nJ])
		next
	next
	PLSCRIGEN(aAux,{ {"Cód.","@C",15},{STR0200,"@C",140},{STR0201,"@C",110},{STR0201,"@C",50},{STR0201,"@C",50},{STR0201,"@C",110} },STR0202) //"Descrição"###"Complemento"###"Complemento"###"Complemento"###"Complemento"###"Nao será possivel proceder as ações de estorno devido às críticas fatais."
	lFatal := .t.
endIf

return lRet


/*/{Protheus.doc} PlPriDiverg
Mostra as divergencias em tela ou grava nova tabela
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PlPriDiverg(oTree,aDiverg,aRetTab,lGrava,cChaveOri,cSeqEst)
local cCargo   := "000"
local nI	   := 0
default oTree  := nil
default aDiverg:= {}
default cSeqEst:= ""

if len(aDiverg) > 0
	for nI := 1 to len(aDiverg)
		
		cCargo := Soma1(cCargo)
		
		if aDiverg[nI][1] == Fir_Node
			oTree:AddTree(' ['+aDiverg[nI][2]+'] - '+aDiverg[nI][3],.t.,aDiverg[nI][4],nil,aDiverg[nI][4],nil,cCargo)
			aadd(aRetTab,{cCargo,aDiverg[nI][1],aDiverg[nI][2],aDiverg[nI][3],aDiverg[nI][4]})
		endIf
		
		if aDiverg[nI][1] == Sec_Node
			oTree:AddTree(aDiverg[nI][3],.t.,aDiverg[nI][4],nil,aDiverg[nI][4],nil,cCargo)
			aadd(aRetTab,{cCargo,aDiverg[nI][1],'',aDiverg[nI][3],aDiverg[nI][4]})
			
			if nI < len(aDiverg) .and. aDiverg[nI+1][1] == Fir_Node
				oTree:EndTree();oTree:EndTree()
			endIf
			
		endIf
		
		if aDiverg[nI][1] == Thi_Node
			oTree:AddTreeItem(aDiverg[nI][3],'','',cCargo)
			aadd(aRetTab,{cCargo,aDiverg[nI][1],'',aDiverg[nI][3],''})
			
			if nI < len(aDiverg) .and. aDiverg[nI+1][1] == Sec_Node
				oTree:EndTree()
			endIf
			
			if nI < len(aDiverg) .and. aDiverg[nI+1][1] == Fir_Node
				oTree:EndTree();oTree:EndTree();oTree:EndTree()
			endIf
		endIf
		oTree:EndUpdate()
	next
endIf

//A chave que eu gravo eh sempre ref. a guia estornada

if lGrava
	for nI:=1 to len(aRetTab)
		B35->(recLock("B35",.t.))
		B35->B35_FILIAL := xFilial("B35")
		B35->B35_CODOPE := subs(cChaveOri,1,4)
		B35->B35_CODLDP := subs(cChaveOri,5,4)
		B35->B35_CODPEG := subs(cChaveOri,9,8)
		B35->B35_NUMERO := subs(cChaveOri,17,8)
		B35->B35_ORIMOV := subs(cChaveOri,25,1)
		B35->B35_CODDVG := aRetTab[nI][3]
		B35->B35_DESCR1 := aRetTab[nI][4]
		B35->B35_TPREGI := aRetTab[nI][2]
		B35->B35_CCARGO := aRetTab[nI][1]
		B35->B35_CIMAGE := aRetTab[nI][5]		
		B35->B35_SEQEST := cSeqEst		
		B35->(msUnLock())
	next
endIf

return

/*/{Protheus.doc} PLSA500VID
Visualiza acoes de estorno
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500VID(cAlias,nReg,nOpc,aFields,lMsg)
local cChaveGui := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
local cChaveAtu := "" //chave do clone
local cChaveOri := ""//chave da guia origem
local cSeqEst   := ""
local cFiltAli  := ""
local aRegBSQ   := {}
local aRegBGQ   := {}
local aRegB35	:= {}
local aFiles	:= {}
local aDiverg	:= {}
local aLanBSQ	:= {}
local aLanBGQ   := {}
local aButtons  := {}
local lErrBSQ   := .f.
local lErrBGQ   := .f.
local nI		:= 0
local aArea		:= getArea()
local oDlg
local bOK		:= {||oDlg:end()}
local bCancel   := {||oDlg:end()}
local nTrb		:= 115
default aFields := nil
default lMsg    := .t.

//Compatibilizador tem q ter sido executado

if &(cAlias+"->(fieldPos('"+cAlias+"_GUESTO'))") == 0
	if lMsg
		Help("",1,"PLSA500028")
	endIf
	restArea(aArea)
	return
endIf

//Verifico aonde o usuario esta posicionado

if &(cAlias+"->"+cAlias+"_ESTORI") == '0'//estou posicionado no clone
	cChaveAtu := cChaveGui //chave do clone
	cChaveOri := allTrim(&(cAlias+"->"+cAlias+"_GUESTO"))//chave da guia origem
else
	cChaveAtu := allTrim(&(cAlias+"->"+cAlias+"_GUESTO"))       //chave do clone
	cChaveOri := cChaveGui//chave da guia origem
endIf

if findFunction("tcSqlFilter()")//teoricamente sempre tem q entrar aqui
	cFiltAli := &(cAlias+"->(tcSqlFilter())")
else
	cFiltAli := RetFiltro(cAlias,"BCI")
endIf
&(cAlias+"->(dbClearFilter())")


//Validacoes iniciais

if empty(&(cAlias+"->"+cAlias+"_SEQEST"))
	if lMsg
		help("",1,"PLSA500030")
	endIf
	if !empty(cFiltAli)
		DbSelectArea(cAlias)
		dbSetFilter({||&cFiltAli},cFiltAli)
	endIf
	restArea(aArea)
	return
endIf

//Busco as divergencias que foram gravadas na base

B35->(dbSetOrder(1))
if B35->(msSeek(xFilial("B35")+cChaveOri))
	while !B35->(eof()) .and. B35->(B35_FILIAL+B35_CODOPE+B35_CODLDP+B35_CODPEG+B35_NUMERO+B35_ORIMOV) == xFilial("B35")+cChaveOri
		aadd(aDiverg,{B35->B35_TPREGI,B35->B35_CODDVG,B35->B35_DESCR1,B35->B35_CIMAGE})
		B35->(dbSkip())
	endDo
endIf

//Busco os lancamentos para prestadores

BGQ->(dbSetOrder(6))
if BGQ->(msSeek(xFilial("BGQ")+&(cAlias+"->"+cAlias+"_SEQEST")))
	while !BGQ->(eof()) .and. BGQ->(BGQ_FILIAL+BGQ_SEQEST) == xFilial("BGQ")+&(cAlias+"->"+cAlias+"_SEQEST")
		aadd(aLanBGQ,{BGQ->BGQ_CODIGO,BGQ->BGQ_NOME,BGQ->BGQ_ANO,BGQ->BGQ_MES,BGQ->BGQ_TIPO,BGQ->BGQ_VALOR,BGQ->BGQ_CHVEST,BGQ->BGQ_CODLAN})
		BGQ->(dbSkip())
	endDo
endIf

//Busco os lancamentos para usuario

BSQ->(dbSetOrder(7))
if BSQ->(msSeek(xFilial("BSQ")+&(cAlias+"->"+cAlias+"_SEQEST")))
	while !BSQ->(eof()) .and. BSQ->(BSQ_FILIAL+BSQ_SEQEST) == xFilial("BSQ")+&(cAlias+"->"+cAlias+"_SEQEST")
		aadd(aLanBSQ,{BSQ->BSQ_USUARI,BSQ->BSQ_ANO,BSQ->BSQ_MES,BSQ->BSQ_VALOR,BSQ->BSQ_CODLAN,BSQ->BSQ_TIPO,BSQ->BSQ_CHVEST})
		BSQ->(dbSkip())
	endDo
endIf


aadd(aButtons, {"RELATORIO",{ || PlImpRelEs(cAlias,aLanBGQ,aLanBSQ) },"Déb./Créd."} )

DEFINE MSDIALOG oDlg TITLE STR0083 FROM 008.2,010.3 to 034.4,100.3 of GetWndDefault() //"Divergências entre guias"
oTree := DbTree():new(030,010,180,345,oDlg,nil,nil,.t.,nil)
oTree:BuildTrb(nTrb,2)
oTree:BeginUpdate()
oTree:SetEnable()

PlPriDiverg(@oTree,aDiverg,{},.f.,cChaveOri,&(cAlias+"->"+cAlias+"_SEQEST"))

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
objCENFUNLGP:useLogUser()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.f.,aButtons) })


if !empty(cFiltAli)
	DbSelectArea(cAlias)
	dbSetFilter({||&cFiltAli},cFiltAli)
endIf
restArea(aArea)

return

/*/{Protheus.doc} PlImpRelEs
Relatorio do estorno
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PlImpRelEs(cAlias,aLanBGQ,aLanBSQ)
local nFor
local cDado
local cCodRDA   	:= ""
local cChavePro 	:= ""
local clinha		:= ""
local nTotal 		:= 0
local lFirst		:= .t.
private nQtdLin     := 58       // Qtd de linhas Por Pagina
private nLimite     := 132       // Limite de Colunas
private cTamanho    := "M"       // P=Pequeno;M=Medio;G=Grande -> P=80;M=132;G=220 (colunas)
private cTitulo     := STR0203 //"Listagem dos lançamentos de estorno"
private cDesc1      := cTitulo // Descritivo para o usuario
private cDesc2      := "" // Descritivo para o usuario
private cDesc3      := ""
private cPerg       := nil // Pergunta padrao (SX1) dos parametros
private cRel        := "PLIMPEST" // Nome do Relatorio
private nli         := 01   // Variavel padrao para controlar numero de linha
private nQtdini     := nli  // Variavel para controlar numero de linha inicial
private m_pag       := 1    // Variavel padrao para contar numero da pagina
private lCompres    := .f. // nao mude e padrao
private lDicion     := .f. // nao mude e padrao
private lFiltro     := .f. // Habilitar o filtro ou nao
private lCrystal    := .f. // nao mudar controle do crystal reports
private aOrderns    := {}
private aReturn     := { "", 1,"", 1, 1, 1, "",1 } // padrao nao mude
private lAbortPrint := .f. // Controle para abortar (sempre como esta aqui)
private cCabec1     := "" // Primeira linha do cabecalho ;
private cCabec2     := "" // utilizado pela funcao cabec
private cCabec3     := ""
private nColuna     := 03 // Numero da coluna que sera impresso as colunas
private cTpRel     := "M"
private nTmRel     := 132

cCabec1 := STR0204 //"Código  Nome Prestador"
cCabec2 := "         "+STR0205  //"Seq. Procedimento"
cCabec3 := "                    "+STR0206+"                                 "+STR0207+"              "+STR0208 //"Unidade"###"Lançamento de Débito/Crédito"###"Valor"

nLimite     := nTmRel
cTamanho    := cTpRel

//Chama SetPrint (padrao)

cRel  := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)

//Verifica se foi cancelada a operacao (padrao)

if nLastKey  == 27 // Verifica o cancelamento
	return
endIf

//Configura impressora (padrao)

SetDefault(aReturn,cAlias)

//Lancamentos para o prestador

if len(aLanBGQ) > 0
	
	//ordeno por prestador
	aLanBGQ := AClone(ASort(aLanBGQ,,, { |x,y| x[1]+x[7] < y[1]+y[7] }))
	
	R500linha('',0,0,.t.)
	
	for nFor := 1 to len(aLanBGQ)
		
		BD7->(dbSetOrder(1))
		BD7->(msSeek(xFilial("BD7")+aLanBGQ[nFor][7]))
		
		if empty(cCodRDA) .or. cCodRDA <> aLanBGQ[nFor][1]
			if nTotal > 0
				clinha := space(96)+"Total "+allTrim(transform(nTotal,PLSMONEY))
				R500linha(clinha,1,0)
			endIf
			clinha := aLanBGQ[nFor][1] + space(2) + aLanBGQ[nFor][2]
			R500linha(clinha,1,0)
			cCodRDA := aLanBGQ[nFor][1]
			nTotal := 0
		endIf
		
		if  empty(cChavePro) .or. cChavePro <> subs(aLanBGQ[nFor][7],1,28)
			
			clinha :=  space(10)+;
				BD7->BD7_SEQUEN+;
				space(1)+;
				PLSPICPRO(BD7->BD7_CODPAD,BD7->BD7_CODPRO)+;
				space(1)+;
				padr(Posicione("BD6",1,xFilial("BD6")+subs(aLanBGQ[nFor][7],1,28),"BD6_DESPRO"),80)
			R500linha(clinha,1,0)
			cChavePro := subs(aLanBGQ[nFor][7],1,28)
		endIf
		
		clinha := space(20)+;
			padr(subs(aLanBGQ[nFor][7],29,3)+" "+allTrim(Posicione("BD3",1,xFilial("BD3")+BD7->BD7_CODUNM,"BD3_DESCRI")),40)+;
			space(1)+;
			padr(Posicione("BBB",1,xFilial("BBB")+aLanBGQ[nFor][8],"BBB_DESCRI"),40)+;
			space(1)+allTrim(transform(aLanBGQ[nFor][6],PLSMONEY))
		nTotal += aLanBGQ[nFor][6]
		R500linha(clinha,1,0)
		
	next
endIf
if nTotal > 0
	clinha := space(96)+STR0209+allTrim(transform(nTotal,PLSMONEY))  //"Total "
	R500linha(clinha,1,0)
endIf

cCabec1   := STR0210 //"Matrícula  Nome Usuário"
cCabec2   := "         "+STR0205  //"Seq. Procedimento"
cCabec3   := "                    "+STR0206+"                                 "+STR0207+"              "+STR0208 //"Unidade"###"Lançamento de Débito/Crédito"###"Valor"
nTotal    := 0
cChavePro := ""
if len(aLanBSQ) > 0
	
	//ordeno por prestador
	aLanBSQ := AClone(ASort(aLanBSQ,,, { |x,y| x[7] < y[7] }))
	R500linha('',0,0,.t.)
	
	for nFor := 1 to len(aLanBSQ)
		
		BD7->(dbSetOrder(1))
		BD7->(msSeek(xFilial("BD7")+aLanBSQ[nFor][7]))
		
		if lFirst
			clinha := transform(aLanBSQ[nFor][1],"@R !!!!.!!!!.!!!!!!.!!-!") + space(2) + Posicione("BA1",2,xFilial("BA1")+aLanBSQ[nFor][1],"BA1_NOMUSR")
			R500linha(clinha,1,0)
			lFirst := .f.
		endIf
		
		if  empty(cChavePro) .or. cChavePro <> subs(aLanBSQ[nFor][7],1,28)
			
			clinha :=  space(10)+;
				BD7->BD7_SEQUEN+;
				space(1)+;
				PLSPICPRO(BD7->BD7_CODPAD,BD7->BD7_CODPRO)+;
				space(1)+;
				padr(Posicione("BD6",1,xFilial("BD6")+subs(aLanBSQ[nFor][7],1,28),"BD6_DESPRO"),80)
			R500linha(clinha,1,0)
			cChavePro := subs(aLanBSQ[nFor][7],1,28)
		endIf
		
		clinha := space(20)+;
			padr(subs(aLanBSQ[nFor][7],29,3)+" "+allTrim(Posicione("BD3",1,xFilial("BD3")+BD7->BD7_CODUNM,"BD3_DESCRI")),40)+;
			space(1)+;
			padr(Posicione("BSP",1,xFilial("BSP")+aLanBSQ[nFor][5],"BSP_DESCRI"),40)+;
			space(1)+allTrim(transform(aLanBSQ[nFor][4],PLSMONEY))
		nTotal += aLanBSQ[nFor][4]
		R500linha(clinha,1,0)
		
	next
endIf
if nTotal > 0
	clinha := space(96)+"Total "+allTrim(transform(nTotal,PLSMONEY))
	R500linha(clinha,1,0)
endIf

if  aReturn[5] == 1
	Set Printer to
	Ourspool(cRel)
endIf

return

/*/{Protheus.doc} R500linha
Imprime linha de detalhe
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function R500linha(clinha,nAntes,nApos,lCabec)
local i
local nLiRDA := nLi
default lCabec := .f.

//Salta linhas antes

lTemLot := .t.

//Salta linhas antes

for i := 1 to nAntes
	nli++
next

//Imprime cabecalho

if  nli > 68  .or. lCabec
	nli := Cabec(cTitulo,'','',cRel,cTamanho,15)
	nli++
	
	if nLiRDA <> 999
		@ nLi, 0 pSay cCabec1
		nli++
		@ nLi, 0 pSay cCabec2
		nli++
		@ nLi, 0 pSay cCabec3
		nli++
		@ nli,0 PSAY Replicate('_',nLimite)
		nli++
	endIf
	
endIf

//Imprime linha de detalhe

@ nLi, 0 pSay clinha

//Salta linhas apos

for i := 1 to nApos
	nli++
next

return

/*/{Protheus.doc} PLSA500OPC
Abre dialogo com opcoes de uma
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500OPC(cAlias,nReg,nOpc)
local oDlg
local cDescri := ""
local aPlSyO  := {}
local nLin    := 17
local nCol	  := 20

DEFINE MSDIALOG oDlg TITLE " " FROM 10, 10 to 27, 58 of GetWndDefault()
//lin,col
@ 004, 010  to 125, 180 PIXEL of oDlg LABEL 'Outras opcoes'

@ nLin,nCol BUTTON STR0211    ACTION Eval( {|| PLSA500RCB(cAlias,nReg,nOpc,.t.) } )	size 150, 10 of oDlg PIXEL                         //"Revalorizar &Cobranca"
nLin+=15
@ nLin,nCol BUTTON STR0212 ACTION Eval( {|| PLSA500RPG(cAlias,nReg,nOpc) } )	size 150, 10 of oDlg PIXEL                         //"Revalorizar &Pagamento"
nLin+=15
@ nLin,nCol BUTTON "&"+STR0213 ACTION Eval( {|| PLSA500RCP(cAlias,nReg,nOpc) } )	size 150, 10 of oDlg PIXEL                         //"Revalorizar Pagamento e Cobranca"
nLin+=15
@ nLin,nCol BUTTON "&"+STR0214 ACTION Eval( {|| PLSA500ORD(cAlias,nReg,nOpc) } )	size 150, 10 of oDlg PIXEL                         //"Alterar Ordem"
nLin+=15
@ nLin,nCol BUTTON "&"+STR0215 ACTION Eval( {|| PLSA500REC(cAlias,nReg,nOpc) } )	size 150, 10 of oDlg PIXEL                         //"Reconsolidar"
nLin+=15
if (getNewPar("MV_PLSTISS","1")=="1") .and. (BCI->BCI_TIPGUI $ "03#05")
	@ nLin,nCol BUTTON "&"+STR0216 ACTION Eval( {|| PLSR420N(2) } )	size 150, 10 of oDlg PIXEL                         //"Imprime Resumo Internação"
	nLin+=15
endIf
if (getNewPar("MV_PLSTISS","1")=="1") .and. (getNewPar("MV_PLATIOD","0") == '1').and. !(BCI->BCI_TIPGUI $ "03#05")
	@ nLin,nCol BUTTON "&"+STR0217 ACTION Eval( {|| PLSR431N({"2"}) } )	size 150, 10 of oDlg PIXEL                         //"Imprime Guia Cobrança Odontológica"
	nLin+=15
endIf

if existBlock("PL500F12")
	
	//aPlSyO := {nil,nil,"Parcelamento Odont.",nil,nil}						 |
	//Na cetesb este pto de entrada eh usado no parcelamento odontologico		 |
	
	aPlSyO := execBlock("PL500F12",.f.,.f.,{'1',cAlias,nReg,nOpc})
	if len(aPlSyO) >= 5
		@ nLin,nCol BUTTON aPlSyO[3] ACTION Eval( {|| execBlock("PL500F12",.f.,.f.,{'2',cAlias,nReg,nOpc}) } )	size 150, 10 of oDlg PIXEL
		nLin+=15
	endIf
endIf

ACTIVATE MSDIALOG oDlg CENTERED

return

/*/{Protheus.doc} PL500GrFac

@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PL500GrFac()
local nI	   := 1
local aDadRda  := PLSGETRDA()

if type('M->BD6_SEQUEN')  <> 'U'//se eu estou no bd6

	for nI := 1 to len(aColsDF)
		
		if aColsDF[nI][GdfieldPos("BYT_SEQUEN",aHeaderDF)] == M->BD6_SEQUEN
			aColsDF[nI][len(aColsDF[len(aColsDF)])] := .t.
		endIf
		
	next
	
	if Type("M->BD6_DENREG") <> 'U' .and. Type("M->BD6_FADENT") <> 'U'
	
		DbSelectArea("B04")
		dbSetOrder(1)
		
		if B04->(msSeek(xFilial("B04")+M->BD6_DENREG))
		
			aadd(aColsDF,array(len(aHeaderDF)+1))
			
			//campos desta tabela sao caracteres
			for nI := 1 to len(aColsDF[len(aColsDF)])-1
				aColsDF[len(aColsDF)][nI] := ''
			next
			
			aColsDF[len(aColsDF)][GdfieldPos("BYT_CODOPE",aHeaderDF)] := BCI->BCI_CODOPE
			aColsDF[len(aColsDF)][GdfieldPos("BYT_CODLDP",aHeaderDF)] := BCI->BCI_CODLDP
			aColsDF[len(aColsDF)][GdfieldPos("BYT_CODPEG",aHeaderDF)] := BCI->BCI_CODPEG
			aColsDF[len(aColsDF)][GdfieldPos("BYT_CODPSA",aHeaderDF)] := M->BD6_CODPRO
			aColsDF[len(aColsDF)][GdfieldPos("BYT_CODPAD",aHeaderDF)] := M->BD6_CODPAD
			aColsDF[len(aColsDF)][GdfieldPos("BYT_CODIGO",aHeaderDF)] := M->BD6_DENREG
			aColsDF[len(aColsDF)][GdfieldPos("BYT_DESCRI",aHeaderDF)] := B04->B04_DESCRI
			aColsDF[len(aColsDF)][GdfieldPos("BYT_TIPO",aHeaderDF)]   := B04->B04_TIPO
			aColsDF[len(aColsDF)][GdfieldPos("BYT_SEGMEN",aHeaderDF)] := B04->B04_SEGMEN
			aColsDF[len(aColsDF)][GdfieldPos("BYT_DESSEG",aHeaderDF)] := B04->B04_DESSEG
			aColsDF[len(aColsDF)][GdfieldPos("BYT_M_ARCO",aHeaderDF)] := B04->B04_M_ARCO
			aColsDF[len(aColsDF)][GdfieldPos("BYT_DESARC",aHeaderDF)] := B04->B04_DESARC
			aColsDF[len(aColsDF)][GdfieldPos("BYT_SEQUEN",aHeaderDF)] := M->BD6_SEQUEN
			aColsDF[len(aColsDF)][GdfieldPos("BYT_FACES" ,aHeaderDF)] := M->BD6_FADENT
			aColsDF[len(aColsDF)][len(aColsDF[len(aColsDF)])] := .f.
			
		endIf
		
	endIf
	
endIf

if len(aDadRda) > 0 .and. aDadRda[1]

	if BAU->BAU_CODIGO <> aDadRda[2]

		BAU->(dbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+aDadRda[2]))

		if  Type('M->BD5_LOCATE') <> 'U' .and. Type('M->BD5_CODESP') <> 'U' .and. Type('M->BD5_OPERDA') <> 'U'
			BB8->(dbSetOrder(1))
			BB8->(msSeek(xFilial("BB8")+aDadRda[2]+M->BD5_OPERDA+M->BD5_LOCATE))
			BAQ->(dbSetOrder(1))
			BAQ->(msSeek(xFilial("BAQ")+M->BD5_OPERDA+M->BD5_CODESP))
		endIf
		
		if Type('M->BE4_OPERDA') <> 'U' .and. Type('M->BE4_LOCAL') <> 'U' .and. Type('M->BE4_CODLOC') <> 'U' .and. Type('M->BE4_CODESP') <> 'U'
			BB8->(dbSetOrder(1))
			BB8->(msSeek(xFilial("BB8")+aDadRda[2]+M->BE4_OPERDA+subs(M->BE4_CODLOC,1,3)+subs(M->BE4_LOCAL,1,3)))
			BAQ->(dbSetOrder(1))
			BAQ->(msSeek(xFilial("BAQ")+M->BE4_OPERDA+M->BE4_CODESP))
		endIf
		
	endIf
	
endIf

return

/*/{Protheus.doc} MenuDef
MenuDef
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function MenuDef()
local aPlSyO	  := {}
private aSubRot2  := {}
private aRotina   := {}
private aSubRot1  := { 		{ STR0218	,'PLSA500CLO(Alias(),Recno(),3,nil)'  , 0, K_Estorno },;  	//"Clonar Guia"
							{ STR0219	,'PLSA500EXC(Alias(),Recno(),3,nil)'  , 0, K_Excluir },;  	//"Excluir Guia Clonada"
							{ STR0220	,'PLSA500AND(Alias(),recno(),3,nil)'  , 0, K_Estorno },; 	//"Ana&lisar Divergências"
							{ STR0221   ,'PLSA500CAN(Alias(),recno(),3,nil)'  , 0, K_Estorno },; 	//"Cancelar Ações de Estorno"
							{ STR0222	,'PLSA500VID(Alias(),recno(),3,nil)'  , 0, K_Estorno }}  	//"Visualizar Divergências"

aSubRot2 := { 	{ STR0223+" &"+STR0224	,'PLSA500RCB(Alias(),recno(),10,nil)'  	, 0, K_Ajuste },;  			//"Revalorizar"###"Cobrança"
				{ STR0212				,'PLSA500RPG(Alias(),recno(),10,nil)'  	, 0, K_Ajuste },; 			//"Revalorizar &Pagamento"
				{ "&"+STR0225			,'PLSA500RCP(Alias(),recno(),10,nil)'  	, 0, K_Ajuste },;  			//"Revalorizar Pagamento e Cobrança"
				{ STR0215				,'PLSA500REC'  							, 0, K_Ajuste },; 			//"Reconsolidar"
				{ STR0299				,'PLSA500RPT(Alias())' 					, 0, K_Incluir, 0, nil} }	//"Conf. Intern. Pag."

if (getNewPar("MV_PLSTISS","1")=="1") .and. (BCI->BCI_TIPGUI $ "03#05") .and. !isPLSA600()
	aadd(aSubRot2,{ "&"+STR0216 				,'PLSA500OPC(Alias(),recno(),10,nil)'  , 0, K_Ajuste}) //"Imprime Resumo Internação"
endIf

if (getNewPar("MV_PLSTISS","1")=="1") .and. (getNewPar("MV_PLATIOD","0") == '1').and. !(BCI->BCI_TIPGUI $ "03#05") .and. !isPLSA600()
	aadd(aSubRot2,{ "&"+STR0217		,'PLSA500OPC(Alias(),recno(),10,nil)'  , 0, K_Ajuste}) //"Imprime Guia Cobrança Odontológica"
endIf

//Para Unimeds inclui opcao para informar medico/enfermeiro auditor
if lUnimed .and. BCI->BCI_TIPGUI $ "03#05" .and. !isPLSA600() //Ver se da pra melhorar essa rotina	
	aadd(aSubRot2,{ "&"+STR0302		,'PLInfAudIn'  , 0, K_Ajuste}) //"Informar Auditores"	
endIf

if existBlock("PL500F12")
	
	//aPlSyO := {nil,nil,"Parcelamento Odont.",nil,nil}
	//Na cetesb este pto de entrada eh usado no parcelamento odontologico
	aPlSyO := execBlock('PL500F12',.f.,.f.,{'1',BCL->BCL_ALIAS,recno(),K_Ajuste})
	
	if len(aPlSyO) >= 5
		aadd(aSubRot2,{ aPlSyO[3] , 'PLE500F12' , 0, K_Ajuste })
	endIf	
endIf

aadd(aRotina,{ STR0226  	,'PLSA500PES'  	, 0 , K_Pesquisar  		}) 		//"Pesquisar"
aadd(aRotina,{ STR0227 		,'PLSA500MOV'  	, 0 , K_Visualizar 		}) 		//"Visualizar"

if !isPLSA600()
	aadd(aRotina,{ STR0228 	,'PLSA500MOV'  	, 0 , K_Incluir    	}) 		//"Incluir"
else
	if oBD7 <> nil .and. aHBD7 <> nil
		aadd(aRotina,{ "Analisar" , "midPLSA600()" , 0, 4 })	
		while Len(aHBD7) > 0
			aDel(aHBD7,len(aHBD7))
			aSize(aHBD7, len(aHBD7)-1)	
		enddo
	else
		aadd(aRotina,{ "Analisar" , 'PLSNOFIELD()' , 0, K_Visualizar })
	endif

endif
aadd(aRotina,{ STR0229 		,'PLSA500MOV'  	, 0 , K_Alterar    		}) 		//"Alterar"
if !isPLSA600()
	aadd(aRotina,{ STR0230 		,'PLSA500FAS'  	, 0 , K_Alterar    	}) 		//"Mudança Fase"
	aadd(aRotina,{ STR0231 		,'PLSA500RFS'  	, 0 , K_RetFas     	})		//"Retorno Fase"
	aadd(aRotina,{ STR0232		,'PLSA500ACT'  	, 0 , K_Analise    	})   	//"Analisar Glosas"
else
	aadd(aRotina,{ "Processar"	,'PLSA500PRC'  	, 0 , K_Alterar	}) 	
endif
aadd(aRotina,{ STR0233	,'PLSA500MOV'  	, 0 , K_Cancel     }) 				//"Cancelar" SulCapixaba usa
aadd(aRotina,{ STR0234  	,'PLSA500BLO'  	, 0 , K_Bloqueio   	}) 			//"(Des)Bloquear 
if !isPLSA600()
	aadd(aRotina,{ "Incluir glosa manual",'PLSA500GML', 0, K_Analise })		//"Incluir glosa manual"
endif
aadd(aRotina,{ STR0235   	,aSubRot2      	, 0 , K_Ajuste     	}) 			//"Outras Opções"
aadd(aRotina,{ STR0236		,aSubRot1	   	, 3 , K_Alterar	   	}) 			//"Estorno"
aadd(aRotina,{ STR0288		,'Plsa500Bco'	, 0 , K_BCOCON		})			//"Conhecimento"
aadd(aRotina,{ "Documentos"	,'plsDocumentos', 0 , K_Visualizar})			//"Documentos"
if !isPLSA600()
	aadd(aRotina,{ '&Proc. Red. Custo','PLSM250',0	,0 				})			//Proc. Red. custo
endif
aadd(aRotina,{ "Ret./Glos. Guia Inteira",'PlsGloPeg(.f.)', 0, K_Analise }) 		//Glosa manual

aadd(aRotina,{STR0297,'PLSA500AUD(Alias())',0,K_Alterar			}) 			//"Reg. Auditoria"
aadd(aRotina,{'Hist. de Glosa' ,'PLSGLOHIS(Alias())',0,K_Visualizar}) 		//"Historico de Glosa"
if PLSALIASEX("B6A")
	aadd(aRotina,{'Exibe Erro Cont','PLSA500ERC()',0,K_Visualizar}) 	
endif
if isPLSA600()
	aadd(aRotina,{'Ver quantidade fila','PLSRETEVQT',0,K_Visualizar}) 
endif
//aadd(aRotina,{ "Roda Fila"				,'u_PLSSMFila',0,K_Visualizar	,0,nil})
//P.E. utilizado para adicionar itens no Menu da mBrowse
if existBlock("PLS500BRW")
	aRotAdic := execBlock("PLS500BRW",.f.,.f.,{aRotina})
	if ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| aadd(aRotina,x)})
	endIf
endIf

return aRotina

/*/{Protheus.doc} PLSA500ODO
nao retirar esta funcao daqui, pois alguns clientes possuem ela em seu dicionario na validacao do campo BD6_CODPRO
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500ODO()
return .t.

/*/{Protheus.doc} Plsa500Bco
Chama a rotina do Banco do Conhecimento.
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
Function Plsa500Bco(cAlias,nReg,nOpc,aNil)
Local aArea		:= GetArea()
Local aAreaBEA	:= BEA->(GetArea())
Local aAreaBE2	:= BE2->(GetArea())
Local aAreaBD6	:= BD6->(GetArea())
Local aRotBack  := aRotina
Local cQuery	:= ""
Local cIndex	:= ""
LOCAL cCodOpe	:= &(cAlias+"->"+cAlias+"_CODOPE")
LOCAL cCodLdp   := &(cAlias+"->"+cAlias+"_CODLDP")
LOCAL cCodPEG   := &(cAlias+"->"+cAlias+"_CODPEG")
LOCAL cNumGui   := &(cAlias+"->"+cAlias+"_NUMERO")"
LOCAL cOriMov   := &(cAlias+"->"+cAlias+"_ORIMOV")"
LOCAL lFound    := .F.
local nIndex	  := 1

aRotina := {{STR0288,'MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"

If cAlias == "BD5"
   BEA->(DbSetOrder(12)) //BEA_FILIAL, BEA_OPEMOV, BEA_CODLDP, BEA_CODPEG, BEA_NUMGUI, BEA_ORIMOV
   If BEA->(DbSeek(xFilial("BEA")+cCodOpe+cCodLdp+cCodPeg+cNumGui+cOriMov))
      //DbSelectArea("BE2")
      nIndex := BE2->(IndexOrd())	
      cIndex := CriaTrab(NIL,.F.)
      cQuery := "BE2_FILIAL == '" + xFilial("BE2") + "' "
      cQuery += " .And. BE2_OPEMOV == '" + BEA->BEA_OPEMOV + "'"
      cQuery += " .And. BE2_ANOAUT == '" + BEA->BEA_ANOAUT + "'"
      cQuery += " .And. BE2_MESAUT == '" + BEA->BEA_MESAUT + "'"
      cQuery += " .And. BE2_NUMAUT == '" + BEA->BEA_NUMAUT + "'"
      IndRegua("BE2",cIndex,BE2->(IndexKey()),,cQuery)

      If BE2->(!Eof())
	  	
		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()
   	     MaWndBrowse(0,0,300,600,STR0289,"BE2",,aRotina,,,,.T.,,,,,,.F.) //"Conhecimento - Proc. Contas"
      EndIf
      
      FErase( cIndex+OrdBagExt() )

      aRotina := aRotBack

      BE2->(dbSelectArea("BE2"))
      BE2->(dbSetOrder(nIndex))

      lFound := .T.
   Endif
Endif

If ! lFound
   //DbSelectArea("BD6")
   nIndex := BD6->(IndexOrd())
   cIndex := CriaTrab(NIL,.F.)
   cQuery := "BD6_FILIAL == '" + xFilial("BD6") + "' "
   cQuery += " .And. BD6_CODOPE == '" + cCodOpe + "'"
   cQuery += " .And. BD6_CODLDP == '" + cCodLdp + "'"
   cQuery += " .And. BD6_CODPEG == '" + cCodPeg + "'"
   cQuery += " .And. BD6_NUMERO == '" + cNumGui + "'"
   cQuery += " .And. BD6_ORIMOV == '" + cOriMov + "'"
   IndRegua("BD6",cIndex,BD6->(IndexKey()),,cQuery)

   If BD6->(!Eof())
		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		objCENFUNLGP:useLogUser()
      MaWndBrowse(0,0,300,600,STR0289,"BD6",,aRotina,,,,.T.,,,,,,.F.) //"Conhecimento - Proc. Contas"
   EndIf
   
   FErase( cIndex+OrdBagExt() )

   aRotina := aRotBack

   //dbSelectArea("BD6")
   BD6->(dbSetOrder(nIndex))
Endif

RestArea(aArea)
RestArea(aAreaBEA)
RestArea(aAreaBD6)
RestArea(aAreaBE2)

Return .T.

/*/{Protheus.doc} PLS500GLM
Motivos de glosa manual.
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLS500GLM(nOpc,cBrowse)
local I__f 		:= 0
local aArea 	:= getArea()
local oDlg      := nil
local nOpca 	:= 0
local bOk 		:= {|| (oDlg:end(),nOpca := 1) }
local bCancel 	:= {|| oDlg:end() }
local cAlias    := iIf(BCI->BCI_TIPGUI$"03#05","BE4","BD5")
local cCodOpe   := BCI->BCI_CODOPE
local cCodLDP   := BCI->BCI_CODLDP
local cCodPEG   := BCI->BCI_CODPEG
local cNumGui 	:= iIf(nOpc==K_Incluir,Space(TamSX3("B11_NUMERO")[1]),&(cAlias+"->"+cAlias+"_NUMERO"))
local cOriMov 	:= iIf(nOpc==K_Incluir,Space(TamSX3("B11_ORIMOV")[1]),&(cAlias+"->"+cAlias+"_ORIMOV"))
local cSequen 	:= PLSGLSEQ()
local cChave	:= xFilial("B11")+cCodOpe+cCodLdp+cCodPeg+cNumGui+cSequen
local aChave	:= {}
local aHeader 	:= {}
local aCols 	:= {}
local aTrab     := {}
default nOpc	:= 2 //Visualizar

if nOpc == K_Incluir
	Copy "B11" to Memory blank
else
	Copy "B11" to Memory
endIf

store Header "B11" to aHeader for .t.

B11->(dbSetOrder(1))
if ! B11->(msSeek(cChave))
	store COLS blank "B11" to aCols FROM aHeader
else
	store COLS "B11" to aCols FROM aHeader VETTRAB aTrab while B11->(B11_FILIAL+B11_CODOPE+B11_CODLDP+B11_CODPEG+B11_NUMERO+B11_SEQUEN) == cChave
endIf

DEFINE MSDIALOG oDlg TITLE STR0295 FROM 008.2,010.3 to 034.4,100.3 of GetWndDefault()            //"Glosa Manual"

oGetB11 			:= TPLSBrw():new(015,001,355,190,nil,oDLG,nil,nil,nil,nil,nil,.t.,nil,.t.,nil,aHeader,aCols,.f.,'B11',nOpc,"Glosa Manual",nil,nil,nil,aTrab)
oGetB11:bLostFocus 	:= {|| lRefresh := .t. }
oGetB11:bChange    	:= {|| Eval(oGetB11:bLostFocus)}
oGetB11:cVldLine   	:= "PLSGLMOK()"

if nOpc == K_Visualizar .Or. nOpc == K_Excluir
	oGetB11:LUPDATE := .f.
	oGetB11:LINSERT := .f.
endIf

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOK,bCancel,.f.,{}) })

//Gravacao de glosa manual

restArea(aArea)

//Gravacao de glosa manual

if nOpca== 1 .and. (nOpc == K_Incluir .Or. nOpc == K_Alterar)
	aChave := {}
	aadd(aChave,{"B11_CODOPE",cCodOPE})
	aadd(aChave,{"B11_CODLDP",cCodLDP})
	aadd(aChave,{"B11_CODPEG",cCodPEG})
	aadd(aChave,{"B11_NUMERO",cNumGui})
	aadd(aChave,{"B11_ORIMOV",cOriMov})
	oGetB11:grava(aChave)
endIf

return

/*/{Protheus.doc} PLSGLSEQ
Retorna a Sequencia do Evento.
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSGLSEQ()
local cRet

if Type("oBrwBD6") == "O"
	cRet := oBrwBD6:fieldGet("BD6_SEQUEN")
else
	cRet := "001"
endIf

return(cRet)

/*/{Protheus.doc} PLSGLMOK
Validação TudoOK da tela Motivos de glosa manual.
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSGLMOK()
local aArea		:= getArea()
local lRet 		:= .t.
local nI	 	:= 0
local nJ		:= 0
local cTexto 	:= ""
local aColsAux	:= {}
local aColsB11	:= oGetB11:aCols
local aHeadB11	:= oGetB11:aHeader

if ValType(oGetB11) == "O"
	
	//Se foi informado glosa ou quantidade
	
	if M->B11_VLRGLO == 0 .and. M->B11_QTDGLO == 0
		
		if lRet
			cTexto += STR0296 //"Para continuar é necessário preencher a quantidade ou o valor da glosa"
		endIf
		
		cTexto	+= CHR(10)+CHR(13)+" * linha "+StrZero(nI,3)
		lRet 	:= .f.
	endIf
	
	if !lRet
		Aviso(STR0290,cTexto,{STR0292},2) //"Atenção"###'Para continuar é necessário preencher a quantidade ou o valor da glosa'###'Ok'
	endIf
endIf

for nI:=1 to len(aColsB11)
	if nI <> n
		aadd(aColsAux,aColsB11[nI])
	endIf
next

//Se exsite registro duplicado para participacao igual

if lRet
	if ascan(aColsAux,{|x| !x[len(x)] .and.;
			x[plRetPos("B11_SEQUEN",aHeadB11)] == M->B11_SEQUEN .and.;
			x[plRetPos("B11_CODGLO",aHeadB11)] == M->B11_CODGLO .and.;
			x[plRetPos("B11_CODTPA",aHeadB11)] == M->B11_CODTPA } ) > 0
		lRet := .f.
		Help(" ",1,"JAGRAVADO")
	endIf
endIf

restArea(aArea)

return lRet

/*/{Protheus.doc} PlVldBDX
Atualiza as cores da legenda da getdados
@type function
@author PLS TEAM
@since 13.06.00
@version 1.0
/*/
function PlVldBDX(cTipo)
local lRet 		:= .t.
local aCodGloCri:= {}
local cSeqCritic:= ""
local cGloAux	:= ""
local nVlrGlo   := 0
local nVlrBase	:= 0
local lAnalisAll:= getNewPar("MV_PLGLOST",.f.)
local i			:= 0
local cSequenc	:= ""
local aSeqLib	:= {}
local nPerGlo 	:= 0
local nPerGtx	:= 0
local nOpcPerg	:= 0
local nVlrBaseTx:= 0
local nVlrTxPgAP:= 0
local aMemSelec := {}	//Array para guardar as informacoes da linha selecionada
local aAuxPercTX:= {}	//Array para guardar as informações de porcentagem de glosa da taxa, poruqe o rodape não tem essa info
local aParSeqPer:= {}	//Par [Sequencial/PercentualGlosaTX]
local lReplica	:= .F.	//Desvio para replicar valores
local lExistCrt20:= .F. //Tipo de glosa = 3 (.T.)
local nIM		:= 0	//Contador para alocar valores M->
local nIp		:= 0	//Comtador para guardar percglotx 
local lTudo := .F.

default cTipo 	:= ""

if lRet .and. M->BDX_ACAO == '1' .and. M->BDX_PERGLO == 0 
	aviso("Atenção",'Informe um percentual de glosa!',{"Ok"},1)
	lRet := .f.
endIf

if lRet .and. lAnalisAll
	
	//Caso o parametro esteja ativado o sistema deverá  analisar
	//outros procedimentos com as mesmas criticas para que no momento
	//da analise ao inves de liberar para um irá libera para todos
	//que tenham a mesma critica.
	
	cSequenc := oBrwIte:fieldGet("BDX_SEQUEN",oBrwIte:oBrowse:nAt)
	
	for i := 1 to len(oBrwCri:aCols)
		
		if oBrwCri:fieldGet("BDX_SEQUEN",i) == cSequenc .and. oBrwCri:fieldGet("BDX_CODGLO",i) <> cGloAux
			
			cGloAux := oBrwCri:fieldGet("BDX_CODGLO",i)
			
			if BCT->(msSeek(xFilial("BCT") + PLSINTPAD() + oBrwCri:fieldGet("BDX_CODGLO",i)))
				
				if BCT->BCT_RECGER == "1"
					
					aadd(aCodGloCri,oBrwCri:fieldGet("BDX_CODGLO",i))
					
				endIf
				
			endIf
			
		endIf
		
	next i
	
	if len(aCodGloCri) > 0
		
		cSeqCritic := cSequenc
		
		for i := 1 to len(oBrwCri:aCols)			
			// verifica se o codigo do item é diferente do selecionado ou se já foi inserido no array aSeqLib
			if cSeqCritic <> oBrwCri:fieldGet("BDX_SEQUEN",i) .AND. cSequenc <> oBrwCri:fieldGet("BDX_SEQUEN",i)
				// verifica se o codigo da critica é o mesmo do item selecionado
				if ! empty( oBrwCri:fieldGet("BDX_CODGLO",i) ) .and. aScan(aCodGloCri, oBrwCri:fieldGet("BDX_CODGLO",i) ) > 0 
					// verifica se já não foi setado uma ação nesse item, evitando sobrescrever dados
					if empty( oBrwCri:fieldGet("BDX_ACAO",i) )
						aadd(aSeqLib,oBrwCri:fieldGet("BDX_SEQUEN",i))
						
						cSeqCritic := oBrwCri:fieldGet("BDX_SEQUEN",i)
					endif
				endIf
				
			endIf
			
		next i
		
	endIf

	if M->BDX_ACAOTX=="1" //TroubleShot -> Quando o 100% da glosa da taxa não é alterado, não é acionado o gatilho e o valor fica errado.
		RunTrigger(1,,,,"BDX_PERGTX")
	endif	

	if len(aSeqLib) > 0
		
		If allTrim(M->BDX_ACAO) == '1'
			nOpcPerg := Aviso(STR0346, STR0347 + CRLF + CRLF + ; // 346 - Replicar análise / 347 - É possivel replicar esta ação para os demais itens da guia que contenham a mesma critica. Para isso temos duas opções:
			                   STR0344 + cValToChar(M->BDX_PERGLO) + CRLF + CRLF + ; // 344 - Opção 1: Para todos os itens usar porcentagem de glosa: 
			                   STR0345,{ STR0348, STR0349, STR0350 }, 2) // 345 - Opção 2: Usar porcentagem de glosa de cada item / 348 - Opção 1 / 349 - Opção 2 / 350 - Não replicar
		Else
			nOpcPerg := iif( msgYesNo( STR0300),1,3) //"Deseja replicar essa análise a outros procedimentos com as mesmas criticas"
			lTudo := .T.
		endIf

		lReplica := iif( nOpcPerg==1,.T.,.F.)

		if nOpcPerg <> 3 

			for nIM := 2 to len(oBrwIte:AHEADER) //Grava informações em M->
				aadd(aMemSelec, M->&(oBrwIte:AHEADER[nIM][2]) )
			next
			
			//Aplicando a regra a outros itens com a mesmas criticas cabeçalho
			for i := 1 to len(oBrwIte:aCols)
				
				if aScan(aSeqLib,oBrwIte:fieldGet("BDX_SEQUEN",i)) > 0

					if( lReplica) .OR. nOpcPerg == 2
						BDX->(dbGoto(oBrwIte:ARECALT[i][3]))
						
						M->BDX_CODOPE := BDX->BDX_CODOPE
						M->BDX_CODLDP := BDX->BDX_CODLDP
						M->BDX_CODPEG := BDX->BDX_CODPEG
						M->BDX_NUMERO := BDX->BDX_NUMERO
						M->BDX_ORIMOV := BDX->BDX_ORIMOV
						M->BDX_CODPAD := BDX->BDX_CODPAD
						M->BDX_CODPRO := BDX->BDX_CODPRO
						M->BDX_SEQUEN := BDX->BDX_SEQUEN
						
					EndIf
					
					// utiliza a porcentagem dos itens separadamente
					if nOpcPerg <> 2
						nPerGlo := M->BDX_PERGLO
						nPerGtx := M->BDX_PERGTX			
					endif
					
					oBrwIte:FieldPut("BDX_RESPAL", M->BDX_RESPAL, i)
					If nOpcPerg <> 2
						oBrwIte:fieldPut("BDX_PERGLO", nPerGlo, i)
						oBrwIte:fieldPut("BDX_PERGTX", nPerGtx, i)
					endif
					oBrwIte:fieldPut("BDX_CRIANA", "1", i)
		
					oBrwIte:fieldPut("BDX_ACAO", M->BDX_ACAO,i)
					oBrwIte:fieldPut("BDX_ACAOTX", M->BDX_ACAOTX,i)

					//Se a ação foi reconsiderar, acaba aqui, só colocamos os valores de memória no objeto e vamos pro próximo
					if lTudo
						RunTrigger(1,,,,"BDX_ACAO")
						oBrwIte:fieldPut("BDX_VLRGLO", M->BDX_VLRGLO, i)
						oBrwIte:fieldPut("BDX_VLRMAN", M->BDX_VLRMAN, i)
						oBrwIte:fieldPut("BDX_VLRPAG", M->BDX_VLRPAG, i)
						oBrwIte:fieldPut("BDX_VLTXPG", M->BDX_VLTXPG ,i)
						oBrwIte:fieldPut("BDX_VLRGTX", M->BDX_VLRGTX ,i)
						oBrwIte:fieldPut("BDX_IMGSTA", 'BR_VERDE',i)
						loop
					endif

					if nOpcPerg == 2
						RunTrigger(1,,,,"BDX_ACAO")
						RunTrigger(1,,,,"BDX_PERGLO")
						oBrwIte:fieldPut("BDX_PERGLO", M->BDX_PERGLO, i) //Sempre glosar. sempre. sempre.
						oBrwIte:fieldPut("BDX_PERGTX", M->BDX_PERGTX, i)
						oBrwIte:fieldPut("BDX_VLRGLO", M->BDX_VLRGLO, i)
						oBrwIte:fieldPut("BDX_VLRMAN", M->BDX_VLRMAN, i)
					endIF
					
					nVlrBase := oBrwIte:fieldGet("BDX_VLRMAN", i) + oBrwIte:fieldGet("BDX_VLRGLO", i)

					if M->BDX_ACAO == '2'
						nVlrGlo := 0
						oBrwIte:fieldPut("BDX_VLRGLO", nVlrGlo, i)
					else
						if nOpcPerg == 2
						//	nVlrGlo := oBrwIte:fieldGet("BDX_VLRGLO", i)
						else
							nVlrGlo := (nVlrBase * nPerGlo ) / 100		
							nVlrBase -= nVlrGlo
							oBrwIte:fieldPut("BDX_VLRGLO", nVlrGlo, i)
							oBrwIte:fieldPut("BDX_VLRMAN", nVlrBase, i)
						endif
					endIf

					if lReplica .OR. nOpcPerg == 2
						if lReplica .AND. M->BDX_ACAOTX <> "2" //Em caso de opção 1 usamos a perc. selecionada em tela 
						//	oBrwIte:fieldPut("BDX_PERGTX", M->BDX_PERGTX ,i)
						endif
							
						M->BDX_CODPAD := oBrwIte:fieldGet("BDX_CODPAD", i)
						M->BDX_CODPRO := oBrwIte:fieldGet("BDX_CODPRO", i) 
						M->BDX_SEQUEN := oBrwIte:fieldGet("BDX_SEQUEN", i)
						
						RunTrigger(1,,,,"BDX_ACAOTX")
						If M->BDX_ACAOTX <> "2"
						//	oBrwIte:fieldPut("BDX_PERGTX", M->BDX_PERGTX, i)
							M->BDX_PERGTX := oBrwIte:fieldGet("BDX_PERGTX", i)
							RunTrigger(1,,,,"BDX_PERGTX")
						endIf
						oBrwIte:fieldPut("BDX_VLTXPG", M->BDX_VLTXPG ,i)
						oBrwIte:fieldPut("BDX_VLRGTX", M->BDX_VLRGTX ,i)
					EndIf
					
					nVlrBase := oBrwIte:fieldGet("BDX_VLTXPG", i) + oBrwIte:fieldGet("BDX_VLRGTX", i)
					
					oBrwIte:fieldPut("BDX_VLRPAG", oBrwIte:fieldGet("BDX_VLRMAN", i) + oBrwIte:fieldGet("BDX_VLTXPG", i) , i)
				endIf

				//Atualiza o status
				if oBrwIte:fieldGet("BDX_PERGLO",i) == 100 .and. allTrim(M->BDX_ACAO) == '1'				
					oBrwIte:fieldPut("BDX_IMGSTA", 'BR_VERMELHO',i)
				elseIf oBrwIte:fieldGet("BDX_VLRGLO",i) == 0
					oBrwIte:fieldPut("BDX_IMGSTA", 'BR_VERDE',i)
				else
					oBrwIte:fieldPut("BDX_IMGSTA", 'BR_AMARELO',i)
				endIf

				//Guarda a porc. de glosa da taxa para calcular o valor de glosa da taxa no grid de críticas
				if aScan(aAuxPercTX,oBrwIte:fieldGet("BDX_SEQUEN",i)) == 0
					aadd(aParSeqPer,oBrwIte:fieldGet("BDX_SEQUEN",i))
					aadd(aParSeqPer,oBrwIte:fieldGet("BDX_PERGTX",i))
					aadd(aAuxPercTX,aParSeqPer)
				endif

			next i
			
			//Aplicando a regra a outros itens com a mesmas criticas rodape 
			for i := 1 to len(oBrwCri:aCols)
				
				if aScan(aSeqLib,oBrwCri:fieldGet("BDX_SEQUEN",i)) > 0
					
					//Resgata porcentagem de glosa da taxa automarica para opção 2
					if nOpcPerg == 2
						nPerGlo := oBrwCri:fieldGet("BDX_PERGLO", i)
						for nIp := 1 to len(aAuxPercTX)
							if oBrwCri:fieldGet("BDX_SEQUEN", i) == aAuxPercTX[nIp][1]
								nPerGtx := aAuxPercTX[nIp][2]
								Exit
							endif
						next nIp
					else
						nPerGlo := M->BDX_PERGLO
						nPerGtx := M->BDX_PERGTX			
					endif

					oBrwCri:fieldPut("BDX_PERGLO", nPerGlo, i)
					oBrwCri:fieldPut("BDX_CRIANA", "1", i)
					oBrwCri:fieldPut("BDX_ACAO",M->BDX_ACAO,i)
					oBrwCri:fieldPut("BDX_ACAOTX",M->BDX_ACAOTX,i)
					nVlrBase := oBrwCri:fieldGet("BDX_VLRMAN", i) + oBrwCri:fieldGet("BDX_VLRGLO", i)

					if M->BDX_ACAO == '2'
						nVlrGlo := 0
					else
						if nOpcPerg == 2
							nVlrGlo := oBrwCri:fieldGet("BDX_VLRGLO", i)
						else
							nVlrGlo := (nVlrBase * nPerGlo ) / 100							
						endif
					endIf
					nVlrBase -= nVlrGlo

					oBrwCri:fieldPut("BDX_VLRGLO", nVlrGlo, i)
					oBrwCri:fieldPut("BDX_VLRMAN", nVlrBase, i)

					if oBrwCri:fieldGet("BDX_TIPGLO", i) == "3"
						lExistCrt20 := .T.
					endif

					nVlrBase := oBrwCri:fieldGet("BDX_VLRMAN", i) + oBrwCri:fieldGet("BDX_VLRGLO", i)

					If !lExistCrt20
						nVlrBaseTx 	:= oBrwCri:fieldGet("BDX_VLTXPG", i) + oBrwCri:fieldGet("BDX_VLRGTX", i)
					else
						nVlrBaseTx 	:= oBrwCri:fieldGet("BDX_VLTXPG", i)
					EndIf

					If oBrwCri:fieldGet("BDX_VLTXAP", i) == 0 .OR. lExistCrt20
						nVlrTxPgAP := oBrwCri:fieldGet("BDX_VLTXPG", i)
					else
						nVlrTxPgAP := oBrwCri:fieldGet("BDX_VLTXAP", i)
					endIf

					if oBrwCri:fieldGet("BDX_ACAO", i) == "1"
						oBrwCri:fieldPut("BDX_VLTXPG", (nVlrTxPgAP * (100 - nPerGtx) / 100), i)
						oBrwCri:fieldPut("BDX_VLRGTX", (nVlrTxPgAP * nPerGtx / 100), i)
					Elseif !lExistCrt20
						oBrwCri:fieldPut("BDX_VLRGTX", 0, i)
						oBrwCri:fieldPut("BDX_VLTXPG", nVlrBaseTx, i)
						oBrwCri:fieldPut("BDX_VLTXPG", iif(nVlrTxPgAP>0 .and. oBrwCri:fieldGet("BDX_VLTXPG", i)==0 .and. oBrwCri:fieldGet("BDX_ACAOTX", i)=="2",nVlrTxPgAP, oBrwCri:fieldGet("BDX_VLTXPG", i)), i)
					Endif

					nVlrBase := oBrwCri:fieldGet("BDX_VLTXPG", i) + oBrwCri:fieldGet("BDX_VLRGTX", i)

					if M->BDX_ACAOTX == '2'
											
						If oBrwCri:fieldGet("BDX_VLRGTX", i) > 0
							nVlrBase := oBrwCri:fieldGet("BDX_VLTXPG", i) + oBrwCri:fieldGet("BDX_VLRGTX", i)
							nVlrGlo := 0
						else
							nVlrGlo := 0
						EndIf
					else	
						nVlrGlo := (nVlrBase * nPerGtx ) / 100
						nVlrBase -= nVlrGlo
					endIf	

					oBrwCri:fieldPut("BDX_VLTXPG", nVlrBase, i)
					oBrwCri:fieldPut("BDX_VLRGTX", nVlrGlo, i)

					oBrwCri:fieldPut("BDX_VLRPAG", oBrwCri:fieldGet("BDX_VLRMAN", i) + oBrwCri:fieldGet("BDX_VLTXPG", i) , i)
						
					if oBrwCri:fieldGet("BDX_ACAO",i) == "1"						
						oBrwCri:fieldPut("BDX_IMGCRI", 'BR_VERMELHO',i)
					elseIf oBrwCri:fieldGet("BDX_ACAO",i) == "2" 
						oBrwCri:fieldPut("BDX_IMGCRI", 'BR_VERDE',i)
					else
						oBrwCri:fieldPut("BDX_IMGCRI", 'BR_AZUL',i)
					endIf

				endIf
				
			next i
			
		endIf
		
	endIf
	
endIf

if lReplica .or. nOpcPerg == 2 //Recupera valores para M->
					
	for nIM:= 1 to (len(oBrwIte:AHEADER)-1) //Retoma valores M->
			M->&(oBrwIte:AHEADER[nIM+1][2]) := aMemSelec[nIM]
	next
	lReplica := .F.
endif

return lRet

/*/{Protheus.doc} PlsDelB11
Atualiza as cores da legenda da getdados
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PlsDelB11(cSequen)
local aArea 	:= getArea()
local cAlias    := iIf(BCI->BCI_TIPGUI$"03#05","BE4","BD5")
local cChvGui 	:= BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)
local cNumGui	:= &(cAlias+"->"+cAlias+"_NUMERO")
local cOriMov	:= &(cAlias+"->"+cAlias+"_ORIMOV")

B11->( dbSetOrder(1) )//B11_FILIAL + B11_CODOPE + B11_CODLDP + B11_CODPEG + B11_NUMERO + B11_ORIMOV + B11_SEQUEN + B11_CODGLO + B11_CODTPA
if B11->(msSeek(xFilial("B11")+cChvGui+cNumGui+cOriMov+cSequen))
	while !B11->(eof()) .and. B11->(B11_FILIAL+B11_CODOPE+B11_CODLDP+B11_CODPEG+B11_NUMERO+B11_ORIMOV+B11_SEQUEN) == xFilial("B11")+cChvGui+cNumGui+cOriMov+cSequen
		B11->(recLock("B11",.f.))
		B11->(dbDelete())
		B11->(msUnLock())
		B11->(dbSkip())
	endDo
endIf

restArea(aArea)

return

/*/{Protheus.doc} PLSA500AUD
Chama a rotina de auditoria
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500AUD(cAlias)
Pl500NwAud( (cAlias)->&( "( " + cAlias+"_CODOPE + " + cAlias+"_CODLDP + " + cAlias+"_CODPEG + " + cAlias+"_NUMERO + " + cAlias+"_ORIMOV)" ), (cAlias)->&( cAlias+"_TIPGUI"), .f. )
return

/*/{Protheus.doc} PLS500VGL
Valid Campos Analise Glosa
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLS500VGL()
local cCampo 	:= ReadVar()
local lRet   	:= .t.

//regra por compo utilizado
if cCampo == "M->BDX_VLRREC"
	
	if M->BDX_VLRREC <= M->BDX_VLRGL2
		M->BDX_GLACAO := iIf(M->BDX_VLRREC > 0,'2','1')
		M->BDX_PERGL2 := iIf(M->BDX_VLRREC == 0,100, (100 - ( M->BDX_VLRREC * 100 ) / M->BDX_VLRGL2 ) )		
		M->BDX_VLGREA := M->BDX_VLRGL2 - M->BDX_VLRREC		
		M->BDX_VLRPA2 := M->BDX_VLRMA2 - M->BDX_VLGREA
	else
		M->BDX_VLRREC := 0
	endIf
	
elseIf cCampo == "M->BDX_QTDREC" //OK - Testado
	
	if M->BDX_QTDREC <= M->BDX_QTDGLO
		M->BDX_GLACAO := iIf(M->BDX_QTDREC > 0,'2','1')
		M->BDX_PERGL2 := iIf(M->BDX_QTDREC == 0,100, (100 - (M->BDX_QTDREC * 100) / M->BDX_QTDGLO) )
		M->BDX_VLRREC := M->BDX_VLRGL2*((100-M->BDX_PERGL2)/100)		
		M->BDX_VLGREA := M->BDX_VLRGL2 - M->BDX_VLRREC		
		M->BDX_VLRPA2 := M->BDX_VLRMA2 - M->BDX_VLGREA
	else
		M->BDX_QTDREC := 0
	endIf
endIf

return lRet

/*/{Protheus.doc} PLDBCli
Valid Campos Analise Glosa
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function PLSDBCli(oBrwIte,oBrwCri,cTitulo,bAfterEdtC,bMultaCCri)
	
//aviso(STR0290,STR0294,{STR0292},1) //"Atenção"###"Não é possível analisar o detalhe da glosa."###"Ok"
	
return

/*/{Protheus.doc} PosNewRda
Posiciona array para nova RDA
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function PosNewRda(cCodOpe,cCodLocDig,cCodPEG,cCodRda)
local aAreaBAU	:= BAU->(getArea())
local aAreaBAX	:= BAX->(getArea())
local aAreaBAQ	:= BAQ->(getArea())
local aAreaBB8	:= BB8->(getArea())

BAU->(dbSetOrder(1))
BAU->(msSeek(xFilial("BAU")+cCodRda))

aNewRDA := {{"_CODRDA",BAU->BAU_CODIGO},;
			{"_CODBB0",BAU->BAU_CODBB0},;
			{"_NOMRDA",BAU->BAU_NOME},;
			{"_NREDUZ",BAU->BAU_NREDUZ},;
			{"_TIPRDA",BAU->BAU_TIPPE},;
			{"_DATBLO",BAU->BAU_DATBLO},;
			{"_CODBLO",BAU->BAU_CODBLO},;
			{"_CODESP",GetEspPri()},;
			{"_DESESP",Posicione("BAQ",1,xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP),"BAQ_DESCRI")},;
			{"_SUBESP",BAX->BAX_CODSUB},;
			{"_DESSUB",Posicione("BFN",1,xFilial("BFN")+BAX->(BAX_CODINT+BAX_CODESP+BAX_CODSUB),"BFN_DESCRI")},;
			{"_LOCATE",Posicione("BB8",1,xFilial("BB8")+BAU->BAU_CODIGO,"BB8_CODLOC+BB8_LOCAL")},;
			{"_LOCAL",BB8->BB8_LOCAL},;
			{"_ENDLOC",allTrim(BB8->BB8_END)+"+"+allTrim(BB8->BB8_NR_END)+"-"+allTrim(BB8->BB8_COMEND)+"-"+allTrim(BB8->BB8_BAIRRO)},;
			{"_CODLOC",BB8->BB8_CODLOC},;
			{"_DESLOC",BB8->BB8_DESLOC},;
			{"_CPFRDA",BAU->BAU_CPFCGC},;
			{"_CATHOS",BAU->BAU_CATHOS},;
			{"_TIPPRE",BAU->BAU_TIPPRE},;
			{"_OPERDA",cCodOpe},;
			{"_ALTCUS",BAU->BAU_ALTCUS},;
			{"_SIGLCR",BAU->BAU_SIGLCR},;
			{"_CONREG",BAU->BAU_CONREG}}

BAU->(restArea(aAreaBAU))
BAX->(restArea(aAreaBAX))
BAQ->(restArea(aAreaBAQ))
BB8->(restArea(aAreaBB8))

return

/*/{Protheus.doc} TraField
Dado um campo, retorno se ele deve ser tratado
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function TraField(cAliCp, cCampo, aCabec)
local xRet    := nil
local aFields := {	"_CODRDA","_NOMRDA","_OPERDA","_TIPRDA","_ENDLOC","_SUBESP",;
					"_DESSUB","_CPFRDA","_TIPPRE","_CODLOC","_LOCAL","_DESLOC",;
					"_CODESP","_LOCATE","_DESESP" }
local nI	  := 0
local nPos	  := 0

for nI:= 1 to len(aFields)
	if cAliCp+aFields[nI] == allTrim(cCampo)
		if (nPos := ascan(aNewRDA,{|x| x[1] $ cCampo})) > 0
			xRet := aNewRDA[nPos][2]
		endIf
		exit
	endIf
next

return xRet

/*/{Protheus.doc} GetEspPri
Pega especialidade principal
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function GetEspPri()
local cCodEsp := ""

BAX->(dbSetOrder(1))
BAX->(msSeek(xFilial("BAX")+BAU->BAU_CODIGO))

while (! BAX->(eof())) .and. BAX->BAX_CODIGO == BAU->BAU_CODIGO
	
	if BAX->BAX_ESPPRI == "1"
		cCodEsp := BAX->BAX_CODESP
		exit
	endIf
	BAX->(dbSkip())
endDo

return cCodEsp

/*/{Protheus.doc} PLSA500RPT
Chama o relatório de Conferencia interna de pagamento
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500RPT(cAlias)
local aPar			:= {}
default cAlias 	:= "BD5"

aadd (aPar,{	&(cAlias + "_CODOPE") ,;   //	Operadora	          	MV_PAR01
				&(cAlias + "_CODRDA") ,;   //	RDA De?	          	MV_PAR02
				&(cAlias + "_CODRDA") ,;   //	RDA Até?	          	MV_PAR03
				&(cAlias + "_ANOPAG") ,;   //	Ano base?        		MV_PAR04
				&(cAlias + "_MESPAG") ,;   //	Mês Base?	       	MV_PAR05
				&(cAlias + "_CODPEG") ,;   //	Peg De ?	          	MV_PAR06
				&(cAlias + "_CODPEG") ,;   //	Peg Até?	          	MV_PAR07
				1           ,;   //	Tipo de Relatório? 			 	MV_PAR08 1=Analitico
				4           ,;   //	Fase?			                	MV_PAR09 4=Todos
				1           ,;   //	Imprimir?					      	MV_PAR10 1=Numero Guia
				3           ,;   //	Imprimir Bloqueada?			  	MV_PAR11 3=Todos
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
				""          ,;   //	local Digitação De?	          	MV_PAR26
				"ZZZZ"      ,;   //	local Digitação Ate?	       	MV_PAR27
				&(cAlias + "_CODEMP"),;//	Empresa De?	      		MV_PAR28
				&(cAlias + "_CODEMP"),;//	Empresa Até?	      		MV_PAR29
				&(cAlias + "_CONEMP"),;//	Contrato De?	      		MV_PAR30
				&(cAlias + "_CONEMP"),;//	Contrato Ate?	          	MV_PAR31
				&(cAlias + "_SUBCON"),;//	Subcontrato De?	       MV_PAR32
				&(cAlias + "_SUBCON"),;//	Subcontrato Ate?	      	MV_PAR33
				""          ,;   //	Plano De?	                   	MV_PAR34
				"ZZZZ"      ,;   //	Plano Até?	                   	MV_PAR35
				""          ,;   //	Procedimento De?	           	MV_PAR36
				"ZZZZZZZZ"  ,;   //	Procedimento Até?	           	MV_PAR37
				1           ,;   //	Imp. Matricula? 				   	MV_PAR38 1=Utilizada
				2           ,;   //	Imprimir Loc Requisição?	   		MV_PAR39 2=Não
				1           ,;   //	Imprimir Co-Participação?	   	MV_PAR40 1=Sim
				&(cAlias + "_NUMERO"),;//	Numero da Guia De?	   	MV_PAR41
				&(cAlias + "_NUMERO"),;   //	Numero de Guia Até? 	          	MV_PAR42
				&(cAlias + "_DTDIGI"),;// Data Digitação De ?	   	MV_PAR43
				&(cAlias + "_DTDIGI"),;// Data Digitação Até?	   	MV_PAR44
				"",;                                                             //45 NFSS
				"",;                                                             //46 NFSS
				1,;   															 //	Glosa Junto do Proc 			   	MV_PAR45 1=Sim
				})

PLSR673(aPar)

return

/*/{Protheus.doc} PLSA500GML 
Trata a analise da conta medica glosa manual.
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500GML(cAlias,nReg,nOpc)
local oDlg		:= nil
local nOpca		:= 0
local cTitulo  	:= STR0035 //"Analise das Contas Medicas"
local cChave	:= ""

local cMatric  	:= iIf(cAlias == "BCI","",&(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODEMP+"+cAlias+"_MATRIC+"+cAlias+"_TIPREG+"+cAlias+"_DIGITO)"))
local bOK      	:= {|| oDlg:end() }
local bCancel  	:= {|| oDlg:end() }
local aButtons 	:= {}

local nRecBD6  	:= 0
local nRecBA1  	:= 0
local nRecAli  	:= 0
local nOrdBD6  	:= 0
local nOrdBA1  	:= 0
local nOrdAli  	:= 0
local cFilAli  	:= iIf(findFunction("tcSqlFilter"),&(cAlias+"->(tcSqlFilter())"),"###")

local cCodOpe  	:= &(cAlias+"->"+cAlias+"_CODOPE")
local cCodLDP  	:= &(cAlias+"->"+cAlias+"_CODLDP")
local cCodPEG  	:= &(cAlias+"->"+cAlias+"_CODPEG")
local cNumero  	:= iIf(cAlias=="BCI",CriaVar("BD6_NUMERO"),&(cAlias+"->"+cAlias+"_NUMERO"))
local cOriMov  	:= iIf(cAlias=="BCI",CriaVar("BD6_NUMERO"),&(cAlias+"->"+cAlias+"_ORIMOV"))
local cFase		:= &(cAlias+"->"+cAlias+"_FASE")
local cSituac  	:= &(cAlias+"->"+cAlias+"_SITUAC")
local nPosSeq	:= 0
local aHeaderCri:= {}
local aDadosCri := {}
local aVetCri   := {}
local aChave    := {}
local nPos		:= 0
local nInd		:= 0
local aItensGlo := {}
local aFiles    := {}
local Inclui    := .f.
local cCadastro := STR0036 //"Analise de Glosas"
local oSay		:= nil
local bFilter	:= nil
local oBmp		:= nil

local bAfterEdtI	:= {|a,b,c,d| PLSA500COR(a,b,c,d,oBrwGlo)}
local bMultaCIte	:= {|| oBrwPro:refresh(),Eval(oBrwPro:bGotFocus)}
local bDblCliIte	:= {|| PlsIncGlo(.f.) }//"Analise de glosa não permitida no cabeçalho!"

local bIrParaEvento := {|| if( lExecPesq, A500IREvento(oBrwPro,oBrwGlo,cField,@nPosIrEvento,@lExecPesq), nil ) }

local nPosIrEvento  := 0
local lExecPesq		:= .T.
local nLinAnt 		:= 0
local nY			:= 0
local oFont			:= nil
local cField     	:= space(tamSX3("BR8_DESCRI")[1])
local lGloAnt    	:= .t.

local aCampos  	  	:= {}
local aColsBD6		:= {}
local aHeaderBD6 	:= {}
local aVetTrabBD6	:= {}
local aSequen		:= {}
local cAliasAux		:= ''
local nAux			:= 0
local nCntFor		:= 0
local nColImg 		:= 0
local nColPag 		:= 0
local nColSeq 		:= 0
local nColGlo 		:= 0

local cChavePes 	:= ""
local cKey 	  		:= "" 
local nLarg 		:= ""
local nTop 			:= ""
local nLeft			:= ""
local nBottom 		:= ""
local cCampos		:= ""
local oMemo			:= nil
local cTexto		:= 0

local cMatricUsr 	:= ""
local lInter 		:= .f.
local lMV_PLSREGL	:= getNewPar("MV_PLSREGL",.f.)

local dData 		:=  ctod("")

local dDatCtbChk as date

private cCodProSel	:= ""
private nVlrMan 	:= 0
private nVlrPag 	:= 0

cAliCab := PlRetAlias( BCI->BCI_CODOPE, BCI->BCI_TIPGUI )
	
dDatCtbChk := PLRtDtCTB(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, iif(cAlias == "BCI","",&(cAliCab+"->"+cAliCab+"_NUMERO")), .F.)

if !PLVLDBLQCO(dDatCtbChk, {"PLS014"}, .t.) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	return .f.
endif

if cAlias == "BCI"
	cChave := cCodOpe + cCodLDP + cCodPEG + cNumero + cOriMov
else
	cChave := (cAlias)->&( "(" + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG + " + cAlias + "_NUMERO + " + cAlias + "_ORIMOV ) " )
endIf

//exclui movimento contabil
if ! PLSEXMCTB("A",cChave)
	return
endIf

setKey(VK_F6,{|| oBrwPro:oBrowse:oBrowse:SetFocus() })
setKey(VK_F7,{|| oBrwGlo:oBrowse:oBrowse:SetFocus() })

setKey(VK_F8,{|| plsIncGlo(.t.) })
setKey(VK_F9,{|| oGetChave:setFocus() })
SetKey(VK_F10, bIrParaEvento )
setKey(VK_F11,{|| if(lExecPesq, A500IREvento(oBrwPro,oBrwGlo,cField,@nPosIrEvento,@lExecPesq,2), nil ) } )

// Redefine variaveis estaticas.
oBrwPro := nil
oBrwGlo := nil

if cFase <> "3"
	msgAlert("Somente guias ativas e prontas poderão incluir glosas manuais.")
	return .F.
endIf

DEFINE FONT oFont NAME "Arial" size 0,-12 BOLD

bOK     	:= {|| (nOpca := 1,oDlg:end()) }
__lManunt 	:= .t.

//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada - 1=Ativo;2=Cancelado;3=Bloqueado
if ( ! ( cSituac == "1" .And. (cFase == "3")) )
	
	help("",1,"PLSA500AGM")	
	
	SET KEY VK_F6 to
	SET KEY VK_F7 to
	SET KEY VK_F8 to
	SET KEY VK_F9 to
	SET KEY VK_F11 TO
	return
endIf

BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO

if BD6->( msSeek( xFilial("BD6") + cChave ) )

	cCodProSel 	:= BD6->BD6_SEQUEN
	cMatricUsr 	:= BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
	dData 		:= BD6->BD6_DATPRO
		
	if BD6->BD6_TIPGUI $ ( G_SOL_INTER + "|" + G_RES_INTER )
		lInter := .t.
	else
		lInter := (BD5->BD5_REGATE == '1')
	endIf

else

	msgAlert("Não foram localizados eventos para esta guia.")
	return .f.

endIf

aCampos := { "BD6_IMGSTA","BD6_SEQUEN","BD6_CODPAD","BD6_CODPRO","BD6_DESPRO","BD6_DENREG","BD6_FADENT","BD6_VLRBPR",;
			 "BD6_VLRMAN","BD6_VLRGLO","BD6_VLRPAG","BD6_VLRAPR","BD6_VALORI","BD6_VLTXAP","BD6_VLTXPG","BD6_PRTXPG",;
			 "BD6_VLRGTX", "BD6_DATPRO","BD6_QTDSOL","BD6_QTDPRO", "BD6_CODRDA", "BD6_SEQIMP"}


for nAux := 1 to len(aCampos)
	cCampos += aCampos[nAux] + iIf( len(aCampos) >= nAux,',','')
next

store Header "BD6" to aHeaderBD6 for ( allTrim(SX3->X3_CAMPO) $ cCampos) 

cChavePes := xFilial("BD6") + cChave
cKey 	  := 'BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)' 

plMontACols("BD6", 1, aHeaderBD6, @aColsBD6, @aVetTrabBD6, cChavePes, cKey )

store Header "BDX" to aHeaderCri for ( allTrim(SX3->X3_CAMPO) $ "BDX_CODPAD,BDX_CODPRO,BDX_CODGLO,BDX_DESGLO,BDX_OBS,BDX_VLRGL2,BDX_PERGL2,BDX_SEQUEN,BDX_ACAO,BDX_NIVEL,BDX_GLACAO,BDX_VLRMAN,BDX_VLRGLO,BDX_ACAOTX,BDX_VLRGTX,BDX_VLTXPG,BDX_VLRREC,BDX_QTDPRO,BDX_TIPGLO,BDX_CODTPA,BDX_QTDGLO,BDX_TIPREG,BDX_VLRPAG,BDX_PERGLO,BDX_PERGTX,BDX_CRIANA,BDX_DESPRO,BDX_DATPRO,BDX_GLOSIS" )

cChavePes := xFilial("BDX") + cChave
cKey 	  := 'BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV)' 

plMontACols("BDX", 4, aHeaderCri, @aDadosCri, @aVetCri, cChavePes, cKey, "BDX->BDX_TIPREG $ '" + iIf(lMV_PLSREGL, '1,2', '1') + "' .and. ! empty(BDX->BDX_NIVEL) " )

	
//Verifica se houve houve influencia da Glosa antiga, não permitindo utilizar a nova.
for nCntFor := 1 to len(aDadosCri)
	
	if aDadosCri[nCntFor][plRetPos("BDX_ACAO",aHeaderCri)]  $ "2,3" .and. empty(aDadosCri[nCntFor][plRetPos("BDX_VLRREC",aHeaderCri)])
		
		// Determina que mesmo depois da analise de glosa podera ser feita a inclusao da glosa manual.
		lGloAnt := iIf(getNewPar("MV_PLLIBGL",.f.),.t.,.f.)
		exit
		
	else
		lGloAnt := .t.
	endIf
	
next

if ! lGloAnt
	msgAlert("Esta guia foi analisada pela rotina Analisar Glosas, é necessário retornar a fase e mudar a fase da guia, para que possa utilizar a rotina Incluir glosa manual.")
	return .f.
endIf

aSize 		:= msAdvSize()
aObjects 	:= {}

aadd( aObjects, { 100, 50 , .t., .f., .f. } )
aadd( aObjects, { 100, 100, .t., .t., .f. } )
aadd( aObjects, { 100, 100 , .t., .f., .f. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

// Atualiza o status dos eventos da guia, de acordo com a glosas que sofreram.
for nCntFor := 1 to len(aColsBD6)
	
	nColImg := plRetPos("BD6_IMGSTA",aHeaderBD6)
	nColPag := plRetPos("BD6_VLRPAG",aHeaderBD6)
	nColSeq := plRetPos("BD6_SEQUEN",aHeaderBD6)
	nColGlo := plRetPos("BD6_VLRGLO",aHeaderBD6)
	
	if ( nPos := aScan(aDadosCri, {|x| x[ plRetPos("BDX_SEQUEN",aHeaderCri) ] == aColsBD6[nCntFor][nColSeq] }) ) > 0
		
		//Valor pago zero glosada integral		
		if aColsBD6[nCntFor][nColPag] == 0 .AND. aColsBD6[nCntFor][nColGlo] > 0
			
			aColsBD6[nCntFor][nColImg] := "BR_VERMELHO"
		
		//valor de glosa zero reconsiderado
		elseIf aColsBD6[nCntFor][nColGlo] == 0

			aColsBD6[nCntFor][nColImg] := "BR_VERDE"
		
		//glosado parcialmente				
		else
			
			aColsBD6[nCntFor][nColImg] := "BR_AMARELO"
			
		endIf
		
	else
		
		aColsBD6[nCntFor][nColImg] := "BR_VERDE"
		
	endIf
	
next

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] of GetWndDefault() Pixel

// Atribui legenda.
oButIni := TButton():new( 005, 005, "F8 - Glosar Todos"	, oDlg, {|| PlsIncGlo(.t.)}, 70, 20,,oFont, .f., .t., .f.,, .f.,,, .f. )

@ 30,010 Say oSay PROMPT "F9 - Pesquisar:" FONT oFont SIZE 100,010 OF oDlg PIXEL
oGetChave := TGet():New(  040, 005,{ | U | IF( PCOUNT() == 0, cField, cField := U ) },oDlg,150,010 ,"@!",nil,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cField)

@ 53,010 Say oSay PROMPT "Formas de busca:" FONT oFont SIZE 150,010 OF oDlg PIXEL
@ 64,010 Say oSay PROMPT "F10 - Pesquisar por Código do Procedimento" FONT oFont SIZE 150,010 OF oDlg PIXEL
@ 76,010 Say oSay PROMPT "F11 - Pesquisar por Descrição Procedimento" FONT oFont SIZE 150,010 OF oDlg PIXEL

//Legenda referente aos procedimentos
@ aPosObj[1,1]+10,aPosObj[1,2]+180 BITMAP oBmp RESNAME "BR_VERMELHO"	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+10,aPosObj[1,2]+195 say oSay PROMPT STR0049 size 100,010 of oDlg PIXEL //"Glosada Integralmente"

@ aPosObj[1,1]+20,aPosObj[1,2]+180 BITMAP oBmp RESNAME "BR_AMARELO" 	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+20,aPosObj[1,2]+195 say oSay PROMPT STR0050 size 100,010 of oDlg PIXEL //"Glosada Parcialmente"

@ aPosObj[1,1]+30,aPosObj[1,2]+180 BITMAP oBmp RESNAME "BR_VERDE"   	of oDlg size 20,20 NOBORDER WHEN .f. PIXEL
@ aPosObj[1,1]+30,aPosObj[1,2]+195 say oSay PROMPT "Sem glosa" size 100,010 of oDlg PIXEL 

@ aPosObj[1,1]+010,aPosObj[1,2]+300 say oSay PROMPT "F6 - Grid de Eventos"   		size 220,010 of oDlg PIXEL
@ aPosObj[1,1]+010,aPosObj[1,2]+380 say oSay PROMPT "F7 - Grid de Críticas"   		size 220,010 of oDlg PIXEL

@ aPosObj[1,1]+020,aPosObj[1,2]+300 SAY oSay PROMPT "F8 - Glosar Todos"   	SIZE 220,010 OF oDlg PIXEL

//Exibe itens
oBrwPro 		   	:= TPLSBrw():new(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3] - 5,nil,oDlg,nil,bDblCliIte,nil,nil,nil,.t.,nil,.t.,nil,aHeaderBD6,aColsBD6,.f.,"BD6",K_Alterar,"Inclusão manual de glosas",nil,nil,nil,aVetTrabBD6,nil,nil,nil,nil) //"Analise de Contas"
oBrwPro:bLostFocus 	:= { || cCodProSel := A500Chave(oBrwPro,oBrwGlo),BD6->( dbGoto( aVetTrabBD6[oBrwPro:linha()] ) ),nLinAnt := oBrwPro:linha(),PLBDXCNG(@cTexto, oMemo, oBrwGlo) }
oBrwPro:bGotFocus 	:= { || oBrwPro:setPos(oBrwPro:linha()),Eval(oBrwPro:bChange)}
oBrwPro:bChange    	:= { || Eval(oBrwPro:bLostFocus),oBrwGlo:forceRefresh(oBrwPro),PLBDXCNG(@cTexto, oMemo, oBrwGlo)}
oBrwPro:lAddLine   	:= .f.

//Exibe criticas (itens)
nTop 				:= aPosObj[3,1]
nLeft 				:= aPosObj[3,2]

nLarg 				:= aPosObj[3,4] * 0.8
nBottom				:= aPosObj[3,3]

bFilter  			:= {|nLine,aCols,aHeader| aCols[nLine,GdfieldPos("BDX_SEQUEN",aHeader)] == cCodProSel }

oBrwGlo 			:= TPLSBrw():new(nTop, nLeft, nLarg, nBottom, nil,oDlg,nil,{||PlsIncRec()},nil,nil,nil,.t.,nil,.t.,nil,aHeaderCri,aDadosCri,.f.,"BDX",K_Alterar,STR0056,nil,nil,nil,aVetCri,"PLVLDBDX('2')","A500VDEL()",bFilter,nil) //"Criticas"
oBrwGlo:bLostFocus	:= { || BDX->( dbGoto(oBrwGlo:aVetTrab[oBrwGlo:linha()]) ), nLinAnt := oBrwGlo:linha(), cTexto := oBrwGlo:fieldGet("BDX_OBS", oBrwGlo:linha()), PLBDXCNG(@cTexto, oMemo, oBrwGlo) }

oBrwGlo:bGotFocus	:= { || oBrwGlo:setPos(nLinAnt),eval(oBrwGlo:bChange)}
oBrwGlo:bChange    	:= { || eval(oBrwGlo:bLostFocus),PLBDXCNG(@cTexto, oMemo, oBrwGlo) }
oBrwGlo:oPai    	:= oBrwPro
oBrwGlo:aOrigem 	:= {"BD6_SEQUEN"}
oBrwGlo:aRelac  	:= {"BDX_SEQUEN"}
oBrwGlo:lAddLine   	:= .f.

//Ajusta a posiçao e tamanho do MEMO
@ aPosObj[1,1] + 285, aPosObj[1,2] + 484 say oSay PROMPT "Observação:" size 220,010 of oDlg PIXEL

nLeft 	+= nLarg
nLarg 	:= aPosObj[2,4] * 0.19
nBottom *= 0.25

//Cria o Memo
@ nTop, nLeft Get oMemo Var cTexto Memo When .f. size nLarg, nBottom of oDlg Pixel

//Seta a função para alterar dinâmicamente o Memo
eval(oBrwPro:bLostFocus)
eval(oBrwGlo:bLostFocus)

oBrwGlo:forceRefresh(oBrwPro)
oBrwPro:refresh()

// P.E. utilizado para adicionar itens no Menu da mBrowse
if ExistBlock("P500BTAG")
	aRotAna := ExecBlock("P500BTAG",.F.,.F.,{oBrwPro,oBrwGlo})
	if ValType(aRotAna) == "A"
		AEval(aRotAna,{|x| AAdd(aButtons,x)})
	endif
endif

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	objCENFUNLGP:useLogUser()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.f.,aButtons)

if nOpca == K_OK  .and. nOpc <> K_Visualizar
	
	begin transaction
		
		for nInd := 1 to len(oBrwPro:aCols)
		
			nPos := aScan(oBrwGlo:aCols,{|x| x[oBrwGlo:plRetPos("BDX_SEQUEN")] == oBrwPro:fieldGet("BD6_SEQUEN",nInd) .and.;
				  							 x[oBrwGlo:plRetPos("BDX_CRIANA")] <> '1' .and.;
				  							 x[oBrwGlo:plRetPos("BDX_TIPGLO")] == '2' .and.;
				  							 ! empty(x[oBrwGlo:plRetPos("BDX_CODGLO")]) })
				  						
			if nPos > 0 
					
					aadd(aSequen, oBrwPro:fieldGet("BD6_SEQUEN",nInd) )
			
					aadd(aItensGlo,{oBrwPro:fieldGet("BD6_SEQUEN",nInd),;//01
									oBrwPro:fieldGet("BD6_VLRMAN",nInd),;//02
									oBrwPro:fieldGet("BD6_VLRGLO",nInd),;//03
									oBrwGlo:fieldGet("BDX_ACAOTX",nPos),;//04
									oBrwPro:fieldGet("BD6_VLRGTX",nInd),;//05
									oBrwGlo:fieldGet("BDX_TIPGLO",nPos),;//06
									oBrwGlo:fieldGet("BDX_ACAO",nPos),;	 //07
									"1",;								 //08
									oBrwGlo:fieldGet("BDX_CODTPA",nPos),;//09
									oBrwGlo:fieldGet("BDX_QTDGLO",nPos),;//10
									oBrwGlo:fieldGet("BDX_TIPREG",nPos),;//11
									oBrwGlo:fieldGet("BDX_CODGLO",nPos),;//12
									oBrwPro:fieldGet("BD6_VLRPAG",nInd),;//13
									oBrwGlo:fieldGet("BDX_PERGLO",nPos),;//14
									oBrwPro:fieldGet("BD6_VLTXPG",nInd),;//15
									.f.})								 //16
				
				for nY := nPos to len(oBrwGlo:aCols)
					
					if oBrwGlo:fieldGet("BDX_CRIANA",nY) <> '1' .and. oBrwPro:fieldGet("BD6_SEQUEN",nInd) == oBrwGlo:fieldGet("BDX_SEQUEN",nY)
						oBrwGlo:fieldPut("BDX_CRIANA","1",nY)
					endIf
						
				next
										
			endIf
			
		next
		
		// grava os registros da critica no banco.
		aadd(aChave,{"BDX_TIPREG","1"})
		aadd(aChave,{"BDX_TIPGLO","2"})
		aadd(aChave,{"BDX_DTACAO",dDataBase})

		aadd(aChave,{"BDX_CODOPE",cCodOpe})
		aadd(aChave,{"BDX_CODLDP",cCodLDP})
		aadd(aChave,{"BDX_CODPEG",cCodPEG})
		aadd(aChave,{"BDX_NUMERO",cNumero})
		aadd(aChave,{"BDX_ORIMOV",cOriMov})
		
		PLUPTCOLS("BDX",oBrwGlo:aCols,aHeaderCri,aVetCri,4,aChave,nil)
		
		if len(aItensGlo) > 0

			PLSXMUDFAS(cAlias,"3","",BCL->BCL_TIPGUI,ctod(""),.f.,"3",nil,nil,.t.,aItensGlo,nil,nil,nil,oBrwPro,;
						   nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,aSequen)
			
		endIf	
		
	end transaction
	
endIf

cRecsd	:= .F.

SET KEY VK_F6 to
SET KEY VK_F7 to
SET KEY VK_F8 to
SET KEY VK_F9 to
SET KEY VK_F10 to
SET KEY VK_F11 to

return

/*/{Protheus.doc} PlsIncGlo

@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function plsIncGlo(lTodos)
local __nValor		:= 0
local __nQuant		:= 0
local nVlrBpr		:= 0
local nVlrGlo		:= 0
local nVlrMan 		:= 0
local nVlrApr 		:= 0
local nPerGlo		:= 0
local nVlrOriginal  := 0
local nVlrJaGlosado := 0
local nVlrSaldo	  	:= 0
local nVlrAprOri	:= 0
local nVlrUnit		:= 0

local nFor			:= 0
local cTitulo		:= ""
local cTexto		:= ""
local cAlert		:= ""
local cAuxGlo		:= getNewPar("MV_PLSCGPD","")
local cCodGlo		:= space(5)
local cDesGlo		:= space(50)
local cObs			:= space(500)
local cProc 		:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_CODPRO")]
local cDesc 		:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_DESPRO")]

local oVlrBpr		:= nil
local oVlrGlo		:= nil
local oVlrMan		:= nil
local oVlrApr		:= nil
local oPerGlo		:= nil
local oCodGlo		:= nil
local oDesGlo		:= nil
local oVlrOriginal	:= nil
local oVlrUnit		:= nil


local oAlert		:= nil
local oTimerBrw		:= nil
local oDlg			:= nil
local oFont			:= nil
local oButIni		:= nil
local oGetChave		:= nil
local oMemo			:= nil

local bOK      		:= {|| oDlg:end() }
local bCancel  		:= {|| oDlg:end() }
local lreturn		:= .f.

Local nQtdProX := 0
Local nVlrUniX := 0

local bAdd		:= {|nOpcao| PlsVldGl(nOpcao, @cCodGlo, @cDesGlo, @cAlert, @cObs, @nVlrGlo, @nVlrJaGlosado, @__nValor, @nVlrMan, nVlrBpr,;
									 @nPerGlo, nVlrApr, oAlert, oTimerBrw, oObs, oValor, oVlrGlo, oVlrMan, oPerGlo,;
									 oCodGlo, oDesGlo, lTodos, ,@nVlrSaldo, @nVlrUniX, @nVlrUnit, nQtdProX, oVlrUnit) }

local bAddAll	:= {|| A500AddAll(2, @cCodGlo, @cDesGlo, @cObs, @cAlert,;
								 oCodGlo, oDesGlo, oDlg, oValor, @oTimerBrw, oObs, oAlert, oVlrGlo, oPerGlo, oVlrMan,;
								 @nVlrBpr,  @nVlrGlo, @nVlrJaGlosado, @__nValor, @nPerGlo, nVlrApr, nVlrMan, lTodos)}

Local oSayZ   := Nil
Local oFont1  := Nil

Local cCodXPro := cProc
Local cDesXPro := cDesc

STATIC cRecsd    := .F.

if ! empty(cAuxGlo)
	
	BCT->( dbSetOrder(1) )
	
	if BCT->( msSeek(xFilial("BCT") + PlsIntPad() + cAuxGlo) )
		
		if BCT->BCT_ATIVO == "1"
			
			cCodGlo := cAuxGlo
			cDesGlo := BCT->BCT_DESCRI
			
		endIf
		
	endIf
	
endIf

// lTodos .t. veio do botão Glosar Todos.
if lTodos

	if ascan(oBrwGlo:aCols,{|x| x[oBrwGlo:plRetPos("BDX_CRIANA")] == '0' .and. x[oBrwGlo:plRetPos("BDX_ACAO")] == '2' }) > 0
		msgAlert("É necessário confirmar a(s) glosa(s) reconsiderada(s) antes de glosar todos os procedimentos.")
		return
	endIf
	
	for nFor := 1 to len(oBrwPro:aCols)
	
		nVlrOriginal  += oBrwPro:aCols[nFor][oBrwPro:FieldPos("BD6_VLRBPR")]
		nVlrJaGlosado += oBrwPro:aCols[nFor][oBrwPro:FieldPos("BD6_VLRGLO")]
		nVlrSaldo	  += oBrwPro:aCols[nFor][oBrwPro:FieldPos("BD6_VLRMAN")]
		nQtdProX 	  += oBrwPro:aCols[nFor][oBrwPro:FieldPos("BD6_QTDPRO")]
		
		nVlrBpr	+= oBrwPro:aCols[nFor][oBrwPro:fieldPos("BD6_VLRBPR")]
		nVlrGlo	+= oBrwPro:aCols[nFor][oBrwPro:fieldPos("BD6_VLRGLO")]
		nVlrMan	+= oBrwPro:aCols[nFor][oBrwPro:fieldPos("BD6_VLRMAN")]
		nVlrApr	+= oBrwPro:aCols[nFor][oBrwPro:fieldPos("BD6_VALORI")]
		
	next
	
	if nVlrMan == 0
		msgAlert("Não existe saldo em nenhum dos eventos.")
		return
	endIf
	
	nVlrUniX := 0
	nVlrUnit := 0
	
else

	nVlrOriginal	:= oBrwPro:aCols[oBrwPro:Linha()][oBrwPro:FieldPos("BD6_VLRBPR")]
	nVlrJaGlosado	:= oBrwPro:aCols[oBrwPro:Linha()][oBrwPro:FieldPos("BD6_VLRGLO")]
	nVlrSaldo		:= oBrwPro:aCols[oBrwPro:Linha()][oBrwPro:FieldPos("BD6_VLRMAN")]
	nVlrAprOri		:= oBrwPro:aCols[oBrwPro:Linha()][oBrwPro:FieldPos("BD6_VALORI")]
	nQtdProX 		:= oBrwPro:aCols[oBrwPro:Linha()][oBrwPro:FieldPos("BD6_QTDPRO")]
	
	nVlrBpr	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRBPR")]
	nVlrGlo	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRGLO")]
	nVlrMan	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRMAN")]
	nVlrApr	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VALORI")]
	
	if nVlrMan == 0
		msgAlert("Não existe saldo neste evento.")
		return
	endIf
	
	nVlrUniX := nVlrMan
	nVlrUnit := round( (nVlrUniX / nQtdProX), PLGetDec('BD6_VLRAPR'))
	
endIf

// Facilitador: O valor a glosa é sempre o saldo.
__nValor := nVlrMan

// calcula o percentual de glosa:
if nVlrGlo > 0
	
	//Percentual de glosa ja efetuada.
	nPerGlo :=  ( nVlrGlo / ( nVlrMan + nVlrGlo ) ) * 100
	
endIf

// Regra do botão glosar todos: Glosa 100% para todos os eventos.
if lTodos
	
	cTitulo 	:= "Incluir Glosa para todos os eventos"
	nPerGlo 	:= 100
	nVlrMan 	:= 0
	
else
	cTitulo := "Incluir Glosa - " + allTrim(cProc) + " - " + allTrim(cDesc)
endIf

DEFINE FONT oFont1 NAME "Arial" size 0,-15 BOLD
DEFINE FONT oFont  NAME "Arial" size 0,-12 BOLD

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 60,200 TO 540,800 OF GetWndDefault() Pixel

@ 032,015 Say oSay Prompt "Código Procedimento"		Size 220,010 of oDlg Pixel
@ 042,015 MsGet oCodGlo Var cCodXPro				Size 050,010 of oDlg Pixel Picture "@!" WHEN .f.

@ 032,070 Say oSay Prompt "Descrição" 	 			Size 220,010 of oDlg Pixel
@ 042,070 MsGet oDesGlo Var cDesXPro				Size 220,010 of oDlg Pixel Picture "@!" WHEN .f.

@ 055,015 Say oSay Prompt "Código Glosa" 		 	Size 220,010 of oDlg Pixel
@ 065,015 MsGet oCodGlo Var cCodGlo				 	Size 050,010 of oDlg Pixel Picture "@!" F3 "BCTPLS" HASBUTTON Valid PLINCDGL(bAdd, cCodGlo) 

@ 055,070 Say oSay Prompt "Descrição Glosa" 		Size 220,010 of oDlg Pixel
@ 065,070 MsGet oDesGlo Var cDesGlo				 	Size 220,010 of oDlg Pixel Picture "@!" WHEN .f.

@ 080,005 Say oSay Prompt "Quantidade a Glosar" 	Size 220,010 of oDlg Pixel
@ 090,005 MsGet oQuant  Var __nQuant				Size 050,010 of oDlg Pixel WHEN ! lTodos .and. ! empty(cCodGlo) Picture "@E 99999.99" Valid __nQuant >= 0 .and. PLINQTGM(@__nValor, nQtdProX, nVlrSaldo, __nQuant, nVlrOriginal, nVlrJaGlosado, oBrwPro, oBrwGlo) .and. Eval(bAdd,3) .and. atuLbl(oSayZ)

@ 080,070 Say oSay Prompt "Valor Unitário"	 	 	Size 50,010 of oDlg Pixel
@ 090,070 MsGet oVlrUnit  Var nVlrUnit			 	Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99"

@ 080,130 Say oSay Prompt "Quantidade Original" 	Size 050,010 of oDlg Pixel
@ 090,130 MsGet oValor  Var nQtdProX				Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

@ 080,190 Say oSay Prompt "Valor Contratado" 	 	Size 50,010 of oDlg Pixel
@ 090,190 MsGet oVlrOriginal  Var nVlrOriginal		Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99"

@ 080,240 Say oSay Prompt "Valor Apresentado"  		Size 050,010 of oDlg Pixel
@ 090,240 MsGet oValor  Var nVlrAprOri				Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

@ 105,005 Say oSay Prompt "Valor da Glosa" 		 	Size 050,010 of oDlg Pixel

// Regra do botão glosar todos: Glosa 100% para todos os eventos.
if lTodos 
	__nValor := nVlrSaldo
endif

@ 115,005 MsGet oValor  Var __nValor				 Size 050,010 of oDlg Pixel When ! lTodos .and. ! empty(cCodGlo) Picture "@E 99,999,999.99" Valid __nValor >= 0 .and. PLINGLO(@__nQuant) .and. eval(bAdd,3) .and. atuLbl(oSayZ)

@ 105,130 Say oSay Prompt "Valor Já glosado" 	 	 Size 50,010 of oDlg Pixel

// Regra do botão glosar todos: Glosa 100% para todos os eventos.
if lTodos 
	nVlrJaGlosado := nVlrJaGlosado
endif

@ 115,130 MsGet oVlrGlo  Var nVlrJaGlosado			 Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .T.

@ 105,070 Say oSay Prompt "% de Glosa" 	 		 	 Size 50,010 of oDlg Pixel

// Regra do botão glosar todos: Glosa 100% para todos os eventos.
if lTodos 
	nPerGlo := 100
endif

@ 115,070 MsGet oPerGlo  Var nPerGlo				 Size 040,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .T.

@ 105,190 Say oSay Prompt "Valor Base Pgto."  		 Size 050,010 of oDlg Pixel
@ 115,190 MsGet oValor  Var nVlrUniX				 Size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

@ 105,240 Say oSay Prompt "Saldo a Pagar" 	 	 	 Size 220,010 of oDlg Pixel

// Regra do botão glosar todos: Glosa 100% para todos os eventos.
if lTodos 
	nVlrMan := 0
endif

@ 115,240 MsGet oVlrMan  Var nVlrMan			 	Size 050,010 of oDlg Pixel WHEN ! lTodos .and. ! empty(cCodGlo) Picture "@E 99,999,999.99" Valid nVlrMan >= 0 .and. PLINVLGM(@__nValor, @__nQuant, nVlrSaldo, nVlrMan, nVlrUniX ) .and. eval(bAdd,3) .and. AtuLbl(oSayZ)

@ 130,005 Say oSay Prompt "Observação" 			 	Size 220,010 of oDlg Pixel
@ 140,005  GET oObs  VAR cObs MEMO SIZE 280,70 OF oDlg PIXEL Pixel

oButIni := TButton():New( 220, 005, "Adicionar a Glosa"	, oDlg, iIf(lTodos, bAddAll, bAdd ) , 70, 15,,oFont, .F., .T., .F.,, .F.,,, .F. )
oButIni := TButton():New( 220, 086, "ESC - Fechar esta janela"	, oDlg, {|| oDlg:End() }, 90, 15,,oFont, .F., .T., .F.,, .F.,,, .F. )

@ 220,005 MsGet oAlert Var cAlert				 Size 280,010 of oDlg Pixel Picture "@!" WHEN .F.
oTimerBrw 	:= TTimer():New( 5*900 , {|| Iif(!Empty(cAlert),(cAlert:="", oAlert:Hide(), oTimerBrw:DeActivate()),nil)} ,oDlg)

@ 215, 190 Say oSayZ Prompt "Valor de Glosa" SIZE 220,010 OF oDlg PIXEL FONT oFont1 COLOR CLR_HRED
@ 225, 190 Say oSayZ Prompt "R$ " + transForm( iIf(empty(cCodGlo), 0, __nValor), "@E 99,999,999.99") SIZE 110,010 OF oDlg PIXEL FONT oFont1 COLOR CLR_HRED

@ 215, 250 Say oSayZ Prompt "Saldo a Pagar" SIZE 220,010 OF oDlg PIXEL FONT oFont1 COLOR CLR_HBLUE
@ 225, 250 Say oSayZ Prompt "R$ " + transForm( iIf(empty(cCodGlo), 0, nVlrMan), "@E 99,999,999.99") SIZE 110,010 OF oDlg PIXEL FONT oFont1 COLOR CLR_HBLUE

if empty(cAlert)
	oAlert:hide()
endIf

ACTIVATE MSDIALOG oDlg ON INIT (EnChoiceBar(oDlg,bOK,bCancel,.f.,{})) CENTER

oBrwGlo:oBrowse:oBrowse:setFocus()
oBrwPro:oBrowse:oBrowse:setFocus()

nlinha := oBrwPro:linha()
oBrwPro:setPos(nlinha)
cGMLcodGlo := ""

return()

/*/{Protheus.doc} A500AddAll
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function A500AddAll(nTipo, cCodGlo, cDesGlo, cObs, cAlert,;
					oCodGlo, oDesGlo, oDlg, oValor, oTimerBrw, oObs, oAlert, oVlrGlo, oPerGlo, oVlrMan,;
					nVlrBpr, nVlrGlo, nVlrJaGlosado, nValor, nPerGlo, nVlrApr, nVlrMan, lTodos)
local nFor	:= 0
local lMsg 	:= .f.

if lTodos
	
	if empty(cCodGlo) .and. nValor > 0
		
		// Apresenta um lembrete apenas.
		cAlert := "Informe o código da glosa para adicioná-la ao evento."
		oAlert:show()
		oAlert:refresh()
		lMsg := .t.
		
	elseIf empty(cCodGlo) .and. nValor == 0
		
		// Apresenta um lembrete apenas.
		cAlert := "Informe o código da glosa e o valor para adicioná-la ao evento."
		oAlert:show()
		oAlert:refresh()
		lMsg := .t.
		
	endIf
	
endIf

for nFor := 1 to len(oBrwPro:aCols)
	
	oBrwPro:setPos(nFor)
	
	PlsVldGl(nTipo, cCodGlo, cDesGlo, cAlert, cObs, nVlrGlo, nVlrJaGlosado, nValor, nVlrMan, nVlrBpr, nPerGlo, nVlrApr,;
			oAlert, oTimerBrw, oObs, oValor, oVlrGlo, oVlrMan, oPerGlo, oCodGlo, oDesGlo, lTodos)
			
next

//Para mostrar a primeira linha no GRID após glosar todos os eventos.
oBrwPro:setPos(1)

if !lMsg
	oDlg:end()
endIf

return

/*/{Protheus.doc} PlsVldGl
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function PlsVldGl(nTipo, cCodGlo, cDesGlo,  cAlert, cObs, nVlrGlo, nVlrJaGlosado, nValor, nVlrMan, nVlrBpr, nPerGlo, nVlrApr,;
				  oAlert, oTimerBrw, oObs, oValor, oVlrGlo, oVlrMan, oPerGlo, oCodGlo, oDesGlo, lTodos, lGloPeg, nVlrSaldo,;
				  nVlrUniX, nVlrUnit, nQtdProX, oVlrUnit )
local lRet 		:= .t.
local nFor		:= 0
local nNvBCT	:= 0
local nValBPR	:= 0
local nValGLO 	:= 0
local nValPAG	:= 0
local nValMAN	:= 0
local nValAPR	:= 0

default lGloPeg		:= .f.
default nVlrSaldo 	:= 0
default nVlrUniX	:= 0
default nVlrUnit	:= 0
default nQtdProX	:= 0
default oVlrUnit	:= nil

if valType(nTipo) <> "N"
	nTipo := 2
endIf

if ! lGloPeg
	
	// Posciona o BD6 do eveto clicado.
	if oBrwPro:linha() <= len(oBrwPro:aVetTrab)
		
		BD6->(dbGoto(oBrwPro:aVetTrab[oBrwPro:linha()]))
		
		if BD6->(eof())
			
			msgAlert("Não foi possivel posicionar o Evento")
			return(.f.)
			
		endIf
		
	else
		
		msgAlert("Problema para posicionar o Evento")
		return(.f.)
		
	endIf
	
	nValBPR	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRBPR")]
	nValGLO	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRGLO")]
	nValPAG	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRPAG")]
	nValMAN	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRMAN")]
	nValAPR	:= oBrwPro:aCols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VALORI")]
	
endIf

if nTipo == 1
	
	if ! empty(cCodGlo)
		
		if !lGloPeg
			
			for nFor := 1 to len(oBrwGlo:aCols)
				
				if empty(oBrwGlo:aCols[nFor][oBrwGlo:fieldPos("BDX_CODPRO")])
					
					loop
					
				elseIf oBrwGlo:fieldGet("BDX_SEQUEN",nFor) == oBrwPro:fieldGet("BD6_SEQUEN",oBrwPro:linha()) .and.;
						allTrim(oBrwGlo:fieldGet("BDX_CODGLO",nFor)) == allTrim(cCodGlo) .and.;
						oBrwGlo:fieldGet("BDX_IMGSTA",nFor) != 'BR_VERDE' .and. !lTodos .and. !oBrwGlo:aCols[nFor,len(oBrwGlo:aCols[nFor])]
					
					msgAlert("O evento já possui esta glosa", "Atenção!")
					
					exit
					
				endIf
				
			next
			
		endIf
		
		if lRet
			
			if existCpo('BCT',PLSINTPAD() + cCodGlo,1)
				
				cDesGlo := BCT->(Posicione("BCT",1,xFilial("BCT") + PlsIntPad() + cCodGlo,"BCT_DESCRI"))
				
			else
				lRet 	:= .f.
				cDesGlo := space(50)
			endIf
			
		endIf
	else
		cDesGlo := space(50)
	endIf
	
elseIf nTipo == 2
	
	if empty(cCodGlo) .and. nValor > 0
		
		// Apresenta um lembrete apenas.
		cAlert := "Informe o código da glosa para adicioná-la ao evento."
		oAlert:show()
		oAlert:refresh()
		oTimerBrw:activate()
		
	elseIf empty(cCodGlo) .and. nValor == 0
		
		// Apresenta um lembrete apenas.
		cAlert := "Informe o código da glosa e o valor para adicioná-la ao evento."
		oAlert:show()
		oAlert:refresh()
		oTimerBrw:Activate()
		
	elseIf !empty(cCodGlo)
		
		// Refaz a validação por garantia.
		if ! existCpo('BCT',PLSINTPAD() + cCodGlo,1)
			return(.f.)
		endIf
		
		// Somente Obri
		if nValor > 0
			
			if lGloPeg .or. oBrwPro:acols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRMAN")] > 0
				
				nNvBCT := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+cCodGlo,"BCT_NIVEL"))
				
				if ( !lGloPeg )
					
					AddGlosaInGrid(cCodGlo,cDesGlo,nValor,0,cObs,nVlrGlo,lTodos,nVlrMan,nNvBCT)
					
				endIf
				
				cCodGlo := space(05)
				cDesGlo := space(50)
				cObs    := space(250)
				cGMLcodGlo	:= ""
				nValor  	:= nVlrMan
				nVlrSaldo 	:= nValor
				
				nVlrUniX 	:= nVlrMan
				nVlrUnit 	:= round( (nVlrUniX / nQtdProX), PLGetDec('BD6_VLRAPR'))
				
			else
				oAlert:refresh()
				oTimerBrw:Activate()
			endIf
			
		else
			cAlert := "Para adicionar a glosa você deve informar um valor."
			oAlert:show()
			oAlert:refresh()
			oTimerBrw:activate()
		endIf
		
	endIf
	
	nVlrJaGlosado := nVlrGlo
	oVlrGlo:refresh()
	
	oValor:refresh()
	oDesGlo:refresh()
	
	if valType(oVlrUnit) != 'U'
		oVlrUnit:refresh()
	endIf	
	
	oCodGlo:setFocus()
	
elseIf nTipo == 3 .or. nTipo == 4
	
	if nValor >= 0 .and. ! empty(cCodGlo) .and. ! lTodos
		
		// Isto existe porque o valor limite para a glosa é o próprio saldo.
		if nValor > nValMan
			
			if lTodos
				nValor := nValor - oBrwPro:acols[oBrwPro:linha()][oBrwPro:fieldPos("BD6_VLRMAN")]
			else
				nValor := nVlrMan
			endIf
			
			nVlrSaldo := nValor
			
			if !lTodos
				cAlert := "O valor da glosa não pode ser maior que o saldo."
				oAlert:show()
				oAlert:refresh()
				oTimerBrw:activate()
				return
			endIf
			
		endIf
		
		// Valor ja glosado
		nVlrGlo := nValGLO + nValor
		oVlrGlo:refresh()
		
		nPerGlo := ( nVlrGlo / ( nValMan + nValGLO ) ) * 100
		
		oPerGlo:refresh()
		
		// Valor base para pagamento
		nVlrMan := nValMan - nValor
		oVlrMan:refresh()
		
	endIf
	
endIf

return(lRet)

/*/{Protheus.doc} AddGlosaInGrid
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function AddGlosaInGrid(cCodGlo,cDesGlo,nValor,nQuant,cObs,nVlrGlo,lTodos,nVlrMan,nNivel)
local nFor			:= 0
local nlinha 		:= 0
local nlinhaDoItem 	:= oBrwPro:linha()
local nPerGlo 		:= 0
local nVlrTx		:= 0
local nVlrGtx 		:= 0

for nFor := 1 to len(oBrwGlo:aCols)
	
	if oBrwGlo:fieldGet("BDX_SEQUEN",nFor) == oBrwPro:fieldGet("BD6_SEQUEN",nlinhaDoItem) .and. empty(oBrwGlo:fieldGet("BDX_CODGLO",nFor))
		nlinha := nFor
		exit
	endIf
	
next

// Se não achaou uma linha vazia, que pudesse ser aproveitada, cria uma nova.
if nlinha == 0
	oBrwGlo:addBlank()
	nlinha := len(oBrwGlo:aCols)
endIf

//glosa
oBrwGlo:fieldPut("BDX_IMGSTA","BR_AMARELO",nlinha)
oBrwGlo:fieldPut("BDX_NIVEL",nNivel,nlinha)
oBrwGlo:fieldPut("BDX_TIPGLO","2",nlinha)
oBrwGlo:fieldPut("BDX_CRIANA","0",nlinha)

oBrwGlo:fieldPut("BDX_ACAO", "1",nlinha)
oBrwGlo:fieldPut("BDX_GLACAO","1",nlinha)
oBrwGlo:fieldPut("BDX_ACAOTX","",nlinha)

oBrwGlo:fieldPut("BDX_SEQUEN",oBrwPro:fieldGet("BD6_SEQUEN",nlinhaDoItem),nlinha)
oBrwGlo:fieldPut("BDX_CODPAD",oBrwPro:fieldGet("BD6_CODPAD",nlinhaDoItem),nlinha)
oBrwGlo:fieldPut("BDX_CODPRO",oBrwPro:fieldGet("BD6_CODPRO",nlinhaDoItem),nlinha)
oBrwGlo:fieldPut("BDX_DESPRO",oBrwPro:fieldGet("BD6_DESPRO",nlinhaDoItem),nlinha)
oBrwGlo:fieldPut("BDX_DATPRO",oBrwPro:fieldGet("BD6_DATPRO",nlinhaDoItem),nlinha)

oBrwGlo:fieldPut("BDX_GLOSIS",allTrim(cCodGlo),nlinha)
oBrwGlo:fieldPut("BDX_CODGLO",allTrim(cCodGlo),nlinha)
oBrwGlo:fieldPut("BDX_DESGLO",allTrim(cDesGlo),nlinha)

oBrwGlo:fieldPut("BDX_OBS",cObs,nlinha)

//Qual e o percentual do valor glosado sobre o valor total ( 100 % e a somatoria dos percentuais do browse oBrwGlo)
if ! lTodos
	nPerGlo := ( nValor / oBrwPro:fieldGet("BD6_VLRMAN",nlinhaDoItem) ) * 100
else
	nPerGlo := 100
	nValor  := oBrwPro:fieldGet("BD6_VLRMAN",nlinhaDoItem)
	nVlrGlo := nValor + oBrwPro:fieldGet("BD6_VLRGLO",nlinhaDoItem)
endIf	

oBrwGlo:fieldPut("BDX_PERGL2",nPerGlo,nlinha)
oBrwGlo:fieldPut("BDX_VLRGL2",nValor,nlinha)
oBrwGlo:fieldPut("BDX_VLRMA2",nVlrMan,nlinha)
oBrwGlo:fieldPut("BDX_VLRAP2",oBrwPro:fieldGet("BD6_VALORI",nlinhaDoItem),nlinha)
oBrwGlo:fieldPut("BDX_VLRBP2",oBrwPro:fieldGet("BD6_VLRBPR",nlinhaDoItem),nlinha)

oBrwGlo:fieldPut("BDX_PERGLO",nPerGlo,nlinha)
oBrwGlo:fieldPut("BDX_VLRGLO",nValor,nlinha)
oBrwGlo:fieldPut("BDX_VLRMAN",nVlrMan,nlinha)
oBrwGlo:fieldPut("BDX_TIPREG","1",nlinha)
oBrwGlo:fieldPut("BDX_QTDGLO",1,nlinha)

//procedimentos
oBrwPro:fieldPut("BD6_VLRGLO",nVlrGlo,nlinhaDoItem)
oBrwPro:fieldPut("BD6_VLRMAN",nVlrMan,nlinhaDoItem)

nVlrGtx := round(( oBrwPro:fieldGet("BD6_VLTXPG",nlinhaDoItem) * nPerGlo ) /100 , 2)
nVlrTx	:= oBrwPro:fieldGet("BD6_VLTXPG",nlinhaDoItem) - nVlrGtx

oBrwPro:fieldPut("BD6_VLTXPG", nVlrTx, nlinhaDoItem)
oBrwPro:fieldPut("BD6_VLRGTX", oBrwPro:fieldGet("BD6_VLRGTX",nlinhaDoItem) + nVlrGtx, nlinhaDoItem)
oBrwPro:fieldPut("BD6_VLRPAG", nVlrMan + nVlrTx, nlinhaDoItem)

//glosa apos atualizar com o novo valor de pagamento no browse.
oBrwGlo:fieldPut("BDX_VLRPAG",oBrwPro:fieldGet("BD6_VLRPAG",nlinhaDoItem), nlinha)
oBrwGlo:fieldPut("BDX_VLTXPG",oBrwPro:fieldGet("BD6_VLTXPG",nlinhaDoItem), nlinha)
oBrwGlo:fieldPut("BDX_VLTXAP",oBrwPro:fieldGet("BD6_VLTXAP",nlinhaDoItem), nlinha)
oBrwGlo:fieldPut("BDX_VLRGTX",nVlrGtx, nlinha)
oBrwGlo:fieldPut("BDX_PERGTX",( oBrwPro:fieldGet("BD6_VLRGTX",nlinhaDoItem) / ( oBrwPro:fieldGet("BD6_VLTXPG",nlinhaDoItem) + oBrwPro:fieldGet("BD6_VLRGTX",nlinhaDoItem) ) ) * 100, nlinha)

if lTodos
	
	// Atualiza os valores no grid do evento.
	oBrwPro:fieldPut("BD6_IMGSTA","BR_VERMELHO",nlinhaDoItem)
	
else
	
	// Atualiza o Status da guia.
	if nVlrMan == 0 .and. allTrim(oBrwGlo:fieldget("BDX_ACAO",nlinha)) == '1'
		oBrwPro:fieldPut("BD6_IMGSTA","BR_VERMELHO",nlinhaDoItem)
	elseIf nVlrGlo == 0
		oBrwPro:fieldPut("BD6_IMGSTA","BR_VERDE",nlinhaDoItem)
	else
		oBrwPro:fieldPut("BD6_IMGSTA","BR_AMARELO",nlinhaDoItem)
	endIf
	
endIf

// Atualiza o grid.
oBrwPro:refresh()

// Restaura a linha do grid.
oBrwPro:setPos(nlinhaDoItem)

// Atualiza o grid de criticas.
oBrwGlo:forceRefresh(oBrwPro)

return(.f.)

/*/{Protheus.doc} A500Chave
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function A500Chave()
return(oBrwPro:aCols[oBrwPro:linha(),oBrwPro:plRetPos("BD6_SEQUEN")])

/*/{Protheus.doc} A500VDEL
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function A500VDEL()
local lRet 			:= .f.
local nVlrGtx 		:= 0 
local nValorGlosa 	:= 0
local nLinha		:= oBrwGlo:linha()
local nLinhaDoItem 	:= oBrwPro:linha()

// Só pode excluir se a glosa não estiver gravada no banco.
if nlinhaDoItem <= len(oBrwGlo:aVetTrab)
	
	if oBrwGlo:aVetTrab[nLinha] == 0
		
		if msgYesNo("Deseja realmente excluir esta glosa ?")
			
			// Atualiza os valores no grid do evento.
			nValorGlosa := oBrwGlo:fieldGet("BDX_VLRGL2", nLinha)
			nVlrGtx		:= oBrwGlo:fieldGet("BDX_VLRGTX", nLinha)
			
			if ! oBrwGlo:acols[nLinha][len(oBrwGlo:aHeader)+1]
				oBrwPro:fieldPut("BD6_VLRGLO",(oBrwPro:fieldGet("BD6_VLRGLO",nLinhaDoItem) - nValorGlosa),nLinhaDoItem)
				oBrwPro:fieldPut("BD6_VLRGTX",(oBrwPro:fieldGet("BD6_VLRGTX",nLinhaDoItem) - nVlrGtx), nLinhaDoItem)
				oBrwPro:fieldPut("BD6_VLRMAN",(oBrwPro:fieldGet("BD6_VLRMAN",nLinhaDoItem) + nValorGlosa),nLinhaDoItem)
				oBrwPro:fieldPut("BD6_VLTXPG",(oBrwPro:fieldGet("BD6_VLTXPG",nLinhaDoItem) + nVlrGtx),nLinhaDoItem)
			else
				oBrwPro:fieldPut("BD6_VLRGLO",(oBrwPro:fieldGet("BD6_VLRGLO",nLinhaDoItem) + nValorGlosa),nLinhaDoItem)
				oBrwPro:fieldPut("BD6_VLRGTX",(oBrwPro:fieldGet("BD6_VLRGTX",nLinhaDoItem) + nVlrGtx), nLinhaDoItem)
				oBrwPro:fieldPut("BD6_VLRMAN",(oBrwPro:fieldGet("BD6_VLRMAN",nLinhaDoItem) - nValorGlosa),nLinhaDoItem)
				oBrwPro:fieldPut("BD6_VLTXPG",(oBrwPro:fieldGet("BD6_VLTXPG",nLinhaDoItem) - nVlrGtx),nLinhaDoItem)
			endIf

			oBrwPro:fieldPut("BD6_VLRPAG", oBrwPro:fieldGet("BD6_VLRMAN",nLinhaDoItem) + oBrwPro:fieldGet("BD6_VLTXPG",nLinhaDoItem), nLinhaDoItem)
			
			//glosa
			oBrwGlo:fieldPut("BDX_VLTXPG", oBrwPro:fieldGet("BD6_VLTXPG",nLinhaDoItem), nLinha)
			oBrwGlo:fieldPut("BDX_VLTXAP", oBrwPro:fieldGet("BD6_VLTXAP",nLinhaDoItem), nLinha)
			oBrwGlo:fieldPut("BDX_VLRGTX", oBrwPro:fieldGet("BD6_VLRGTX",nLinhaDoItem), nLinha)
			
			lRet := .t.
		endIf
		
	else
		
		if allTrim(oBrwGlo:fieldGet("BDX_IMGSTA", nLinha)) == 'BR_VERDE'
			msgInfo("Esta glosa não pode ser excluída pois já foi totalmente reconsiderada!")
		else
			msgInfo("Esta glosa não pode ser excluída porque já foi gravada no banco de dados. Reconsidere totalmente a glosa do evento!")
		endIf
		
	endIf
	
endIf

return(lRet)

/*/{Protheus.doc} A500IREvento
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function A500IREvento(oBrwPro,oBrwGlo,cField,nPosIrEvento,lExecPesq,nTp)
local nx		:= 0
local nPosFind 	:= 1
local lFind 	:= .f.
local nPosAtuEvento:= nPosIrEvento

default nTp	:= 1

lExecPesq := .f.

if ( nPosIrEvento <= 0 )
	nPosIrEvento := 1
else
    
	if ( nPosIrEvento == len(oBrwPro:aCols) )
          nPosIrEvento := 1
    else
          nPosIrEvento := nPosIrEvento + 1
    endIf
    
endIf

if nTp == 1
	nPosFind := aScan(oBrwPro:aCols, {|x| allTrim( x[oBrwPro:fieldPos("BD6_CODPRO")] ) == allTrim(cField) })
	If nPosAtuEvento >= nPosFind   // Se ja exitir valores irem para o proximo registro
		nx := 0
		nPosAtuEvento++
		For nx:=nPosAtuEvento to Len(oBrwPro:aCols)
			If Alltrim(oBrwPro:aCols[nx,oBrwPro:fieldPos("BD6_CODPRO")]) == allTrim(cField)
				nPosFind := nx
				exit
			Endif
		Next nx
	
	Endif
else	
	nPosFind := aScan(oBrwPro:aCols, {|x| allTrim( allTrim(cField) $ x[oBrwPro:fieldPos("BD6_DESPRO")] ) })
	If nPosAtuEvento >= nPosFind   // Se ja exitir valores irem para o proximo registro
		nx := 0
		nPosAtuEvento++
		For nx:=nPosAtuEvento to Len(oBrwPro:aCols)
			If allTrim(cField) $ Alltrim(oBrwPro:aCols[nx,oBrwPro:fieldPos("BD6_DESPRO")])
				nPosFind := nx
				exit
			Endif
		Next nx
	endIf
endIf	

if nPosFind > 0        
	lFind := .t.
	nPosIrEvento := nPosFind
endif

if lFind
  oBrwPro:setPos(nPosFind)
  eval(oBrwPro:bChange)
else
   msgAlert("Evento não localizado!")
endIf

lExecPesq := .t.

return

/*/{Protheus.doc} PlsIncRec
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function PlsIncRec()
local oDlg			:= nil
local bOK      		:= {|| Eval(bAdd),oDlg:end() }
local bCancel  		:= {|| oDlg:end() }
local oFont			:= nil
local cObs			:= Space(500)
local cAlert		:= ""
local oAlert		:= nil
local oTimerBrw		:= nil
local nLinhaDoItem 	:= oBrwPro:linha()
local nLinha		:= oBrwGlo:linha()

local bAdd		:= {|nOpcao| PlsAddRec(@__nValor, @cObs, @nVlrGlosa, oBrwGlo, oBrwPro, oCombo:nAt) }
local bVld 		:= {|| PlsAddRec(@__nValor, @cObs, @nVlrGlosa, oBrwGlo, oBrwPro, oCombo:nAt) }

local oVlrBpr	:= nil
local nVlrBpr	:= oBrwPro:fieldGet("BD6_VLRBPR",nLinhaDoItem)

local nAuxVlrGlo:= 0
local nVlrGlosa	:= oBrwGlo:fieldGet("BDX_VLRGLO",nLinha)

local oPerGlo	:= nil
local nAuxPerGlo:= 0
local nPerGlo	:= oBrwGlo:fieldGet("BDX_PERGLO",nLinha)

local oVlrPag	:= nil
local nVlrPag	:= oBrwPro:fieldGet("BD6_VLRPAG",nLinhaDoItem)

local oCodGlo	:= nil
local cCodGlo 	:= oBrwGlo:fieldGet("BDX_CODGLO",nLinha)

local oDesGlo	:= nil
local cDesGlo 	:= oBrwGlo:fieldGet("BDX_DESGLO",nLinha)

local cProc 	:= oBrwPro:fieldGet("BD6_CODPRO",nLinhaDoItem)
local cDesc 	:= oBrwPro:fieldGet("BD6_DESPRO",nLinhaDoItem)

local cTitulo	:= ""
local oCombo	:= nil
local cOpcCob	:= ""

local oValor	:= nil
local __nValor	:= 0

if oBrwGlo:fieldGet("BDX_TIPGLO",nLinha) != '2'
	msgStop("Não é possivel continuar porque esta glosa não é glosa Manual")
	return()
endIf

if empty(cCodGlo)
	msgStop("Não existe glosa para reconsiderar.")
	return()
endIf

if len(oBrwGlo:aVetTrab) < nLinha .or. oBrwGlo:aVetTrab[nLinha] == 0
	msgStop("Não é possivel continuar porque esta glosa não está gravada. Exclua caso não queira gravá-la.")
	return()
endIf

if nVlrGlosa == 0
	msgStop("Não é possivel continuar porque esta glosa já foi totalmente reconsiderada.")
	return()
endIf

// Facilitador: O valor a glosa é sempre o saldo.
__nValor 	:= nVlrGlosa
nAuxVlrGlo	:= nVlrGlosa
nAuxPerGlo	:= nPerGlo

cTitulo 	:= "Reconsiderar Glosa do Evento - " + allTrim(cProc) + " - " + allTrim(cDesc)

DEFINE FONT oFont NAME "Arial" size 0,-12 BOLD
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 100,200 to 510,800 of GetWndDefault() Pixel

@ 005,005 say oSay Prompt "Código Glosa" 		 	size 220,010 of oDlg Pixel
@ 015,005 MsGet oCodGlo Var cCodGlo				   	size 050,010 of oDlg Pixel Picture "@!" WHEN .f.

@ 005,070 say oSay Prompt "Descrição Glosa" 	 	size 220,010 of oDlg Pixel
@ 015,070 MsGet oDesGlo Var cDesGlo				   	size 220,010 of oDlg Pixel Picture "@!" WHEN .f.

@ 035,005 say oSay Prompt "Reconsiderar Todos ?"    size 060,010 of oDlg Pixel
@ 043,005 COMBOBOX oCombo Var cOpcCob ITEMS {"Sim","Não"} size 050,010 of oDlg PIXEL Valid eval({|| iIf(oCombo:nAt == 1, eval( {||__nValor := 0, nVlrPag := nVlrGlosa, nVlrGlosa:= 0, nPerGlo := 0} ), eval( {||nVlrGlosa := nAuxVlrGlo, __nValor := nAuxVlrGlo, nVlrPag -= nVlrGlosa, nPerGlo := nAuxPerGlo } ) ) })
oCombo:nAt := 2

@ 060,005 say oSay Prompt "Valor a Reconsiderar"    size 80,010 of oDlg Pixel
@ 070,005 MsGet oValor  Var __nValor				size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99"

@ 060,070 say oSay Prompt "Valor Contratado" 	 	size 50,010 of oDlg Pixel
@ 070,070 MsGet oVlrBpr  Var nVlrBpr	   			size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99"

@ 060,130 say oSay Prompt "Valor da glosa" 		   	size 50,010 of oDlg Pixel
@ 070,130 MsGet oVlrGlo  Var nVlrGlosa	 	   		size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

@ 060,190 say oSay Prompt "% de Glosa" 	 		   	size 50,010 of oDlg Pixel
@ 070,190 MsGet oPerGlo  Var nPerGlo				size 040,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

@ 060,240 say oSay Prompt "Saldo a Pagar" 	 	   	size 220,010 of oDlg Pixel
@ 070,240 MsGet oVlrPag  Var nVlrPag			   	size 050,010 of oDlg Pixel WHEN .f. Picture "@E 99,999,999.99" Valid .t.

cObs :=  oBrwGlo:fieldGet("BDX_OBS", nLinha)

@ 085,005 say oSay Prompt "Observação" 			 	size 220,010 of oDlg Pixel
@ 095,005  GET oObs  VAR cObs MEMO size 280,70 of oDlg PIXEL Pixel

@ 130,005 MsGet oAlert Var cAlert				 	size 280,010 of oDlg Pixel Picture "@!" WHEN .f.

oTimerBrw 	:= TTimer():new( 5 * 900 , {|| iIf(!empty(cAlert),(cAlert:="", oAlert:Hide(), oTimerBrw:DeActivate()),nil)} ,oDlg)
if empty(cAlert)
	oAlert:hide()
endIf

ACTIVATE MSDIALOG oDlg ON INIT (EnChoiceBar(oDlg,bOK,bCancel,.f.,{}),oValor:SetFocus())

return()

/*/{Protheus.doc} PlsAddRec
reconsiderar glosa
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
function PlsAddRec(nValor, cObs, nVlrGlosa, oBrwGlo, oBrwPro, nOpcao)
local nlinhaBDX := iIf(nOpcao == 2, oBrwGlo:linha(), 1)
local nlinhaBD6	:= iIf(nOpcao == 2, oBrwPro:linha(), 1)
local nPerGlo 	:= 0
local nCnt 		:= 0
local nI		:= 0
local nVlrGlo 	:= 0
local cGloAtual	:= ""
local nVlrGtx 	:= 0

if nOpcao != 2
	cGloAtual := oBrwGlo:fieldGet("BDX_CODGLO", oBrwGlo:linha())
	eval(oBrwPro:bChange)
endIf

for nI := nlinhaBD6 to len(oBrwPro:aCols)
	
	for nCnt := nlinhaBDX to len(oBrwGlo:aCols)
		
		if nOpcao != 2
			
			if oBrwGlo:fieldGet("BDX_SEQUEN",nCnt) <> oBrwPro:fieldGet("BD6_SEQUEN",nI)
				loop
			endIf
			
			// Só reconsidera os itens com o mesmo codigo de glosa.
			if oBrwGlo:fieldGet("BDX_CODGLO", nCnt) <> cGloAtual
				loop
			endIf
			
			// Ignora as glosas que ja foram 100% reconsideradas.
			if oBrwGlo:fieldGet("BDX_VLRGLO", nCnt) == 0
				loop
			endIf
			
			//diferente de glosa manual
			if oBrwGlo:fieldGet("BDX_TIPGLO", nCnt) != '2'
				loop
			endIf
			
		endIf
				
		//para reconsiderar a critica tem que estar gravada e analisada 
		//esta sendo retirado para que possa ser considerada como uma analise nova
		//agravacao sera feita na funcao PLSA500GML
		 
		oBrwGlo:fieldPut("BDX_CRIANA","0",nCnt)
		oBrwGlo:fieldPut("BDX_OBS",cObs,nCnt)
		
		nVlrGlo := oBrwGlo:fieldGet("BDX_VLRGLO",nCnt)
		nVlrGtx := oBrwGlo:fieldGet("BDX_VLRGTX",nCnt)
		
		if nOpcao != 2
			nValor := nVlrGlo
		endIf
		
		oBrwGlo:fieldPut("BDX_VLRGLO",(nVlrGlo - nValor),nCnt)
		oBrwGlo:fieldPut("BDX_VLRGL2",oBrwGlo:fieldGet("BDX_VLRGLO",nCnt),nCnt)
		
		nPerGlo := 100
		
		oBrwGlo:fieldPut("BDX_PERGLO",nPerGlo,nCnt)
		oBrwGlo:fieldPut("BDX_PERGL2",nPerGlo,nCnt)
		oBrwGlo:fieldPut("BDX_PERGTX",nPerGlo,nCnt)
		
		oBrwGlo:fieldPut("BDX_VLRMAN",(oBrwGlo:fieldGet("BDX_VLRMAN",nCnt) + nValor),nCnt)
		oBrwGlo:fieldPut("BDX_VLRPAG",(oBrwGlo:fieldGet("BDX_VLRPAG",nCnt) + nValor),nCnt)
		oBrwGlo:fieldPut("BDX_VLRREC",(oBrwGlo:fieldGet("BDX_VLRREC",nCnt) + nValor),nCnt)
		
		oBrwGlo:fieldPut("BDX_ACAO",'2',nCnt)
		oBrwGlo:fieldPut("BDX_ACAOTX",'2',nCnt)
		oBrwGlo:fieldPut("BDX_GLACAO",oBrwGlo:fieldGet("BDX_ACAO",nCnt),nCnt)
		
		oBrwGlo:fieldPut("BDX_VLRMA2",oBrwPro:fieldGet("BD6_VLRMAN",nI) + nValor,nCnt)
		oBrwGlo:fieldPut("BDX_VLRAP2",oBrwPro:fieldGet("BD6_VALORI",nI),nCnt)
		oBrwGlo:fieldPut("BDX_VLRBP2",oBrwPro:fieldGet("BD6_VLRBPR",nI),nCnt)

		oBrwGlo:fieldPut("BDX_QTDGLO",1,nCnt)
		
		//procedimentos
		oBrwPro:fieldPut("BD6_VLRMAN",(oBrwPro:fieldGet("BD6_VLRMAN",nI) + nValor),nI)
		oBrwPro:fieldPut("BD6_VLTXPG",(oBrwPro:fieldGet("BD6_VLTXPG",nI) + nVlrGtx),nI)
		
		oBrwPro:fieldPut("BD6_VLRGLO",(oBrwPro:fieldGet("BD6_VLRGLO",nI) - nValor),nI)
		oBrwPro:fieldPut("BD6_VLRGTX",(oBrwPro:fieldGet("BD6_VLRGTX",nI) - nVlrGtx),nI)
		
		oBrwPro:fieldPut("BD6_VLRPAG",oBrwPro:fieldGet("BD6_VLRMAN",nI) + oBrwPro:fieldGet("BD6_VLTXPG",nI), nI)

		//glosa
		oBrwGlo:fieldPut("BDX_VLTXPG",oBrwPro:fieldGet("BD6_VLTXPG",nI), nCnt)
		oBrwGlo:fieldPut("BDX_VLTXAP",oBrwPro:fieldGet("BD6_VLTXAP",nI), nCnt)
		oBrwGlo:fieldPut("BDX_VLRGTX",oBrwPro:fieldGet("BD6_VLRGTX",nI), nCnt)
		
		if oBrwPro:fieldGet("BD6_VLRMAN",nI) == 0 .and. allTrim(oBrwGlo:fieldGet("BDX_ACAO",nCnt)) == '1'
			
			oBrwPro:fieldPut("BD6_IMGSTA","BR_VERMELHO",nI)
			
		elseIf oBrwPro:fieldGet("BD6_VLRGLO",nI) == 0
			
			oBrwPro:fieldPut("BD6_IMGSTA","BR_VERDE",nI)
			
		else
			oBrwPro:fieldPut("BD6_IMGSTA","BR_AMARELO",nI)
		endIf
		
		if nOpcao == 2
			exit
		endIf	
			
	next
	
	if nOpcao == 2
		exit
	endIf
	
next

// Atualiza o grid de criticas.
oBrwGlo:forceRefresh()
oBrwPro:forceRefresh()

return(.t.)

/*/{Protheus.doc} PLBDXCNG
@type function
@author PLS TEAM
@since 18/11/2016
@version 1.0
/*/
static function PLBDXCNG(cTexto, oObj, oGet)
local nPosObs := 0

if len(oGet:aCols) > 0
	
	nPosObs := GDfieldPos("BDX_OBS",oGet:aHeader)
	
	if ValType(oObj) <> 'U' .and. nPosObs > 0
		cTexto := oGet:aCols[oGet:linha()][nPosObs]
		oObj:Refresh()
	endIf
endIf

return nil


/*/{Protheus.doc} VLDDEL

@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function VLDDEL(cTipoGuia)
local lRet := .t.
default cTipoGuia := ""

if cTipoGuia == G_CONSULTA
	return .f.
endIf 

if !empty(cTipoGuia) .and. lUnimed 
	lRet := PLS500B6S()
endif 

if existBlock("PL500VLDEL")
	lRet := execBlock("PL500VLDEL",.f.,.f.,{nOpcBot, lRet})
endIf

return(lRet)

/*/{Protheus.doc} PLInfAudIn
Exibe Dialog para informar medico e enfermeiros auditores
Utilizado em Unimeds que trabalham com Intercambio Eventua
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLInfAudIn()
local cTitulo   := STR0303//"Médico/Enfermeiro Auditor"
local cNomMed   := BE4->BE4_NMAUDI
local cRegMed   := BE4->BE4_RMAUDI
local cNomEnf   := BE4->BE4_NEAUDI
local cRegEnf   := BE4->BE4_REAUDI
local cUFMed    := ""
local cUfEnf    := ""
local bOKFor    := {|| nOpca := 1, oDlg:end() }
local bCancel   := {|| nOpca := 0, oDlg:end() }
local nOpca     := 0
local lWhen     := empty(BE4->BE4_SEQIMP)
DEFINE FONT oFontTit NAME "Arial" size 000,-011

//Verifica existencia de campos

cUFMed := BE4->BE4_UMAUDI
cUfEnf := BE4->BE4_UEAUDI

//Define dialogo
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.0,010.3 to 031,070

@ 020,005 say oSay PROMPT STR0304  size 330,010 of oDlg PIXEL  COLOR CLR_RED //"Informe o médico e enfermeiro auditor:"

@ 050,005 say oSay PROMPT STR0305  size 080,010 of oDlg PIXEL COLOR CLR_RED//"Registro do Médico"
@ 050,100 MSGET cRegMed size 080,006 of oDlg PIXEL FONT oFontTit COLOR CLR_BLACK F3 "BTYPLS" VALID NomProfInt(@cNomMed,cRegMed,@cUFMed) WHEN {||lWhen}

@ 065,005 say oSay PROMPT STR0310  size 080,010 of oDlg PIXEL COLOR CLR_RED //"UF do Médico"
@ 065,100 MSGET cUFMed size 080,006 of oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||.f. }

@ 080,005 say oSay PROMPT STR0306  size 080,010 of oDlg PIXEL COLOR CLR_RED //"Nome do Médico
@ 080,100 MSGET cNomMed size 080,006 of oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||.f. }

@ 105,005 say oSay PROMPT STR0307  size 080,010 of oDlg PIXEL COLOR CLR_RED //"Registro do Enfermeiro"
@ 105,100 MSGET cRegEnf size 080,006 of oDlg PIXEL FONT oFontTit COLOR CLR_BLACK  F3 "BTYPLS" VALID NomProfInt(@cNomEnf,cRegEnf,@cUFEnf)  WHEN {||lWhen}

@ 120,005 say oSay PROMPT STR0311  size 080,010 of oDlg PIXEL COLOR CLR_RED //"UF do Enfermeiro"
@ 120,100 MSGET cUFEnf size 080,006 of oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||.f. }

@ 135,005 say oSay PROMPT STR0308  size 080,010 of oDlg PIXEL COLOR CLR_RED //"Nome do Enfermeiro"
@ 135,100 MSGET cNomEnf size 080,006 of oDlg PIXEL FONT oFontTit COLOR CLR_BLACK WHEN {||.f. }


//Ativa dialogo.

ACTIVATE MSDIALOG oDlg CENTERED ON INIT Eval( { || EnChoiceBar(oDlg,bOKFor,bCancel,.f.) } )

if nOpca == 1
	BE4->(recLock("BE4",.f.))
	BE4->BE4_NMAUDI := cNomMed
	BE4->BE4_RMAUDI := cRegMed
	BE4->BE4_UMAUDI := cUFMed
	BE4->BE4_NEAUDI := cNomEnf
	BE4->BE4_REAUDI := cRegEnf
	BE4->BE4_UEAUDI := cUFEnf
	BE4->(msUnLock())
endIf

return

/*/{Protheus.doc} NomProfIntºAutor
Retorna nome do auditor para a funcao PLInfAudIn
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
static function NomProfInt(cRet,cRegistro,cUf)
local lRet := .f.

if !empty(cRegistro)
	BB0->(dbSetOrder(4))//BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
	if BB0->(msSeek(xFilial("BB0")+iIf(!empty(BB0->BB0_ESTADO),BB0->BB0_ESTADO,cUf)+cRegistro))
		cRet := BB0->BB0_NOME
		cUf  := BB0->BB0_ESTADO
		lRet := .t.
	endIf
else
	lRet := .t.
	cRet := Space(15)
	cUf  := Space(2)
endIf

return lRet


/*/{Protheus.doc} PlsGloPeg
Faz a glosa integral da Guia ou do PEG
@type function
@author victor.silva
@since 27/09/2016
@param lGuiPeg, boolean, informa se é PEG
@param cAlias, alias da Guia
/*/
function PlsGloPeg(lGuiPeg, lAutoma)
local aAreaBD5		:= BD5->(getArea())
local aAreaBE4		:= BE4->(getArea())
local aAreaBD6		:= BD6->(getArea())
local bOK      		:= {|| nOpca := 1, oDlg:end() }
local bCancel  		:= {|| nOpca := 0,oDlg:end(), lFound := .f.}
local cCodGlo		:= space(5)
local cDesGlo		:= space(50)
local cObs			:= space(500)
local cAuxGlo		:= getNewPar("MV_PLSCGPD","")
local cTitulo		:= ""
local cAlias		:= ""
local cFase			:= ""
local cChave		:= ""
local cAlert    	:= ""
local nRecGUI		:= 0
local __nValor		:= 0
local nOpca			:= 0
local nVlrBpr		:= 0
local nVlrMan 		:= 0
local nVlrApr		:= 0
local nVlrGlo		:= 0
local nPerGlo		:= 0
local nFor			:= 0
local lRet			:= .f.
local lFound		:= .f.
local aItensGlo		:= {}
local aRetAux		:= {}
local aRecGUI		:= {}

local oDlg      	:= nil
local oFont     	:= nil
Local nrecBCIZ := 0

local oVlrBpr		:= nil
local oAlert    	:= nil
local oTimerBrw 	:= nil
local oObs			:= nil
local oValor		:= nil
local oVlrGlo		:= nil
local oVlrMan		:= nil
local oPerGlo		:= nil
local oCodGlo		:= nil
local bAdd			:= {|nOpcao| PlsVldGl(nOpcao, @cCodGlo, @cDesGlo, @cAlert, @cObs, @nVlrGlo, @nVlrGlo, @__nValor, @nVlrMan, nVlrBpr,;
										  @nPerGlo, nVlrApr, oAlert, oTimerBrw, oObs, oValor, oVlrGlo, oVlrMan, oPerGlo, oCodGlo,;
										  oDesGlo, .t., .t.) }
local csqlchk2 	:= ""
local lGloallgui := .F.
local dDatCtbChk as date
local lPerg   := .f.

default lGuiPeg := .f.
default lAutoma := .f.

cAlias      := PlRetAlias( BCI->BCI_CODOPE, BCI->BCI_TIPGUI )
dDatCtbChk  := PLRtDtCTB(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, iif(lGuiPeg,"",&(cAlias+"->"+cAlias+"_NUMERO")), .F.)

if existBlock("PLSGLOTO")
	if !(execBlock("PLSGLOTO",.f.,.f., {lGuiPeg}))
		return .f.
	endif
endIf 

if !PLVLDBLQCO(dDatCtbChk, {"PLS013"}, .t.) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	return .f.
endif

if !(Empty(BCI->BCI_CODGLO)) .and. lGuiPeg
	if !lAutoma
		lPerg := MsgYesNo("Deseja retornar a glosa integral da PEG?")
	endif

	if lAutoma .or. lPerg
		B4D->(DbSetOrder(5)) // B4D_FILIAL+B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT
		if B4D->(MsSeek(xFilial("B4D")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			msgInfo("Existem registros da rotina de recurso de glosa vinculados a este PEG.")
		else
			attFase("3")
			// limpamos os campos referentes a glosa integral
			BCI->(RecLock("BCI", .F.))
			BCI->BCI_STTISS := ""
			BCI->BCI_CODGLO := ""
			BCI->(MsUnlock())
			// retorna a fase da peg
			PLSA175RGR("BCI",BCI->(recno()),1,.t.,.f.,,,,,,,"1")
		endif
	endif

elseif (Empty(BCI->BCI_CODGLO)) .and. BCI->BCI_FASE <> "4" .and. !lGuiPeg .AND. IIF(cAlias == "BD5", !(empTy(BD5->BD5_CODGLO)), !(empTy(BE4->BE4_CODGLO)) )
	if !lAutoma
		lPerg := MsgYesNo("Deseja retornar a glosa integral da Guia?")
	endif

	if lAutoma .or. lPerg
		B4D->(DbSetOrder(5)) // B4D_FILIAL+B4D_OPEMOV+B4D_CODLDP+B4D_CODPEG+B4D_NUMAUT
		if B4D->(MsSeek(xFilial("B4D")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) +IIF(cAlias == "BD5", BD5->BD5_NUMERO, BE4->BE4_NUMERO) ))
			msgInfo("Existem registros da rotina de recurso de glosa vinculados a esta Guia.")
		else
		//	attFase("3")
		//	// limpamos os campos referentes a glosa integral
		//	BCI->(RecLock("BCI", .F.))
		//	BCI->BCI_STTISS := ""
		///	BCI->BCI_CODGLO := ""
			//BCI->(MsUnlock())
			If cAlias == "BD5"
				BD5->(RecLock("BD5",.F.))
					BD5->BD5_CODGLO := ""
					BD5->BD5_FASE := "3"
				BD5->(MsUnLock())
				PLSA500RFS(cAlias,BD5->(Recno()),1,,,.T.,)
			else
				BE4->(RecLock("BE4",.F.))
					BE4->BE4_CODGLO := ""
					BE4->BE4_FASE := "3"
				BE4->(MsUnLock())
				PLSA500RFS(cAlias,BE4->(Recno()),1,,,.T.,)
			endIf
			
		endif
	endif

elseif (lGuiPeg .AND. EmpTy(BCI->BCI_CODGLO)) .OR. (!lGuiPeg .AND. IIF(cAlias == "BD5", (empTy(BD5->BD5_CODGLO)), (empTy(BE4->BE4_CODGLO)) ))

	nrecBCIZ := BCI->(Recno())

	if !empty(cAuxGlo)

		BCT->( dbSetOrder(1) )
		if BCT->( msSeek(xFilial("BCT") + PlsIntPad() + cAuxGlo) )

			if BCT->BCT_ATIVO == "1"
				cCodGlo := cAuxGlo
				cDesGlo := BCT->BCT_DESCRI
			endIf
			
		endIf
		
	endIf

	//valida guias e retorna os valores
	aRetAux := getVldGUI(lGuiPeg)

	nVlrBpr	 := aRetAux[1]
	nVlrMan	 := aRetAux[2]
	nVlrApr	 := aRetAux[3]
	nVlrGlo	 := aRetAux[4]
	aRecGUI	 := aRetAux[5]

	if nVlrMan <= 0 .or. len(aRecGUI) == 0
				
		msgAlert("Não foi encontrado guia para efetuar Glosa!")
		return
				
	endIf

	// Facilitador: O valor a glosa é sempre o saldo.
	__nValor := nVlrMan

	//Percentual de glosa ja efetuada.
	if nVlrGlo > 0
		
		nPerGlo := ( nVlrGlo / ( nVlrMan + nVlrGlo ) ) * 100
		
	endIf

	cTitulo := "Glosar " + iIf(lGuiPeg, "PEG inteiro", "GUIA inteira")
	nPerGlo := 100

	if !lAutoma
		DEFINE FONT oFont NAME "Arial" size 0,-12 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 100,200 to 540,800 of getWndDefault() pixel

		@ 045,005 say oSay prompt "Código Glosa" 		size 220,010 of oDlg pixel
		@ 055,005 msGet oCodGlo Var cCodGlo				size 050,010 of oDlg pixel picture "@!" F3 "BCTPLS" HASBUTTON Valid Eval(bAdd,1)

		@ 045,065 say oSay prompt "Descrição Glosa" 	size 220,010 of oDlg pixel
		@ 055,065 msGet oDesGlo Var cDesGlo				size 220,010 of oDlg pixel picture "@!" when .f.

		@ 070,005 say oSay prompt "Glosa" 				size 050,010 of oDlg pixel
		@ 080,005 msGet oValor  Var __nValor			size 050,010 of oDlg pixel when .f. picture "@E 99,999,999.99" 

		@ 070,065 say oSay prompt "Contratado" 	 		size 050,010 of oDlg pixel
		@ 080,065 msGet oVlrBpr  Var nVlrBpr			size 050,010 of oDlg pixel when .f. picture "@E 99,999,999.99"

		@ 070,120 say oSay prompt "Apresentado"			size 050,010 of oDlg pixel
		@ 080,120 msGet oVlrApr  Var nVlrApr			size 050,010 of oDlg pixel when .f. picture "@E 99,999,999.99"

		@ 070,175 say oSay prompt "Já glosado" 			size 050,010 of oDlg pixel
		@ 080,175 msGet oVlrGlo  Var nVlrGlo			size 050,010 of oDlg pixel when .f. picture "@E 99,999,999.99"

		@ 105,005 say oSay prompt "Observação" 			size 220,010 of oDlg pixel
		@ 115,005 get oObs  VAR cObs MEMO size 280,70 of oDlg pixel 

		@ 190,005 msGet oAlert Var cAlert				 size 280,010 of oDlg pixel picture "@!" when .f.

		oTimerBrw := TTimer():new( 5 * 900 , {|| iIf(!empty(cAlert),(cAlert:="", oAlert:Hide(), oTimerBrw:DeActivate()),nil)} ,oDlg)

		if empty(cAlert)
			oAlert:hide()
		endIf

		ACTIVATE MSDIALOG oDlg ON INIT (enChoiceBar(oDlg,bOK,bCancel,.f.,{})) CENTER
	else
		cCodGlo  := "001"
		cDesGlo  := "IDADE DO USUARIO INCOMPATIVEL COM A IDADE LIMITE PARA O PROCEDIMENTO."
		__nValor := 76.40
		nVlrBpr  := 76.40
		nVlrApr  := 0
		nVlrGlo  := 0
		cObs	 := "Teste"
	endif

	if lAutoma .or. (nOpca == K_OK .and. !empty(cCodGlo))
		
		begin transaction
			
			for nFor := 1 to len(aRecGUI)
			
				cAlias  := aRecGUI[nFor,1]
				nRecGUI	:= aRecGUI[nFor,2]
				
				(cAlias)->(dbGoTo(nRecGUI))
				
				//Inicializa variaveis de auxilo
				cChaveGui := (cAlias)->&( cAlias + "_CODOPE+" + cAlias + "_CODLDP+" + cAlias + "_CODPEG+" + cAlias + "_NUMERO+" + cAlias+"_ORIMOV" )
				
				//Faz a gravação da glosa na BD6/BDX e totaliza os valores por guia
				PlsGloBD6(cCodGlo,cDesGlo,cChaveGui,cObs,@aItensGlo)
				
				//Muda a fase da guia para pronta
				PLSXMUDFAS(cAlias,"3","",BCL->BCL_TIPGUI,ctod(""),.f.,"3",nil,nil,.f.,aItensGlo)
				
				//Verifica se e o operador de gerenciamento
				if PLSVEROPE()
					// Muda a fase da peg para pronta
					PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()),.t.,.t.)
				endIf
				
				
				//Libera a memoria do array dos itens glosados
				plsFreArr(@aItensGlo)
				
				PLCABGTOT(cChaveGui, (cAlias)->&( cAlias + "_TIPGUI" ))
				
			next 
			
			PLPEGTOT()
			
			If lGuiPeg
				BCI->(recLock("BCI"))
					BCI->BCI_CODGLO := cCodGlo
				BCI->(MsUnLock())
			else
				If BCI->BCI_TIPGUI == "05"
					BE4->(recLock("BE4"))
						BE4->BE4_CODGLO := cCodGlo
					BE4->(MsUnLock())
				else
					BD5->(recLock("BD5"))
						BD5->BD5_CODGLO := cCodGlo
					BD5->(MsUnLock())
				endIf
			EndIf
		end transaction

		If !lGuiPeg
			If BCI->BCI_TIPGUI == "05"
				csqlchk2 += " Select Count(1) GUIA_N_GLOSA from " + RetsqlName("BE4")
				csqlchk2 += " Where "
				csqlchk2 += " BE4_FILIAL = '" + xfilial("BE4") + "' AND "
				csqlchk2 += " BE4_CODOPE = '" + BCI->BCI_CODOPE + "' AND "
				csqlchk2 += " BE4_CODLDP = '" + BCI->BCI_CODLDP + "' AND "
				csqlchk2 += " BE4_CODPEG = '" + BCI->BCI_CODPEG + "' AND "
				csqlchk2 += " BE4_CODGLO = ' ' AND "		
				csqlchk2 += " D_E_L_E_T_ =  ' ' "
			else
				csqlchk2 += " Select Count(1) GUIA_N_GLOSA from " + RetsqlName("BD5")
				csqlchk2 += " Where "
				csqlchk2 += " BD5_FILIAL = '" + xfilial("BD5") + "' AND "
				csqlchk2 += " BD5_CODOPE = '" + BCI->BCI_CODOPE + "' AND "
				csqlchk2 += " BD5_CODLDP = '" + BCI->BCI_CODLDP + "' AND "
				csqlchk2 += " BD5_CODPEG = '" + BCI->BCI_CODPEG + "' AND "
				csqlchk2 += " BD5_CODGLO = ' ' AND "	
				csqlchk2 += " D_E_L_E_T_ =  ' ' "
			EndIf
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,csqlchk2),"ChkGuiglo",.F.,.T.)
			
			If ChkGuiglo->GUIA_N_GLOSA == 0
				lGloallgui := .T.
			EndIf
			ChkGuiglo->(DbCloseArea())
		EndIf

		If lGuiPeg .AND. nrecBCIZ > 0
			
			If nrecBCIZ <> BCI->(Recno())
				BCI->(dbgoTo(nrecBCIZ))
			endIf
			
			aFase 	:= PLSMDVFA(BCI->(Recno()), .F.)
			cFase 	:= aFase[1] 
			lBaixa	:= aFase[2] //vai vir sempre .F. aqui, pq não tem como ter nada pago
		
			cStaTIss := "4"
			
			BCI->(RecLock("BCI", .F.))
				BCI->BCI_STTISS := cStaTiss
			BCI->(MsUnLock())

			If GetNewPar("MV_PLSHAT","0") == "1"  
				PLHATINTFAT(BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
			EndIf
				
		endIf
			
		If (lGloallgui .OR. lGuiPeg)
			If lGloallgui
				BCI->(RecLock("BCI",.F.))
					BCI->BCI_CODGLO := cCodGlo
				BCI->(MsUnLock())
			endIF
			attFase("4")			
		endIf
		
		msgInfo("Processo concluído com sucesso.") //"Processo concluído com sucesso."
		
	elseIf nOpca == K_Cancel

		msgInfo("Processo cancelado.") //"Processo concluído com sucesso."
		
	endIf
endif

BD5->(restArea(aAreaBD5))
BE4->(restArea(aAreaBE4))
BD6->(restArea(aAreaBD6))

return
//-------------------------------------------------------------------
/*/{Protheus.doc} attFase
Atualiza a fase.

@author Lucas Nonato
@since  18/02/2020
/*/
function attFase(cFase)
local cSql as char
// retornamos a fase de todos os itens da peg
Begin Transaction	

BCI->(RecLock("BCI", .F.))
	BCI->BCI_FASE := cFase
BCI->(MsUnLock())

if BCI->BCI_TIPGUI <> "05"
	cSql := " UPDATE " + RetsqlName("BD5") 
	cSql += " SET BD5_FASE = '" + cFase + "' "
	cSql += " WHERE BD5_FILIAL = '" + xfilial("BD5") + "' "
	cSql += " AND BD5_CODOPE = '" + BCI->BCI_CODOPE + "' "
	cSql += " AND BD5_CODLDP = '" + BCI->BCI_CODLDP + "' "
	cSql += " AND BD5_CODPEG = '" + BCI->BCI_CODPEG + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
else
	cSql := " UPDATE " + RetsqlName("BE4") 
	cSql += " SET BE4_FASE = '" + cFase + "' "
	cSql += " WHERE BE4_FILIAL = '" + xfilial("BE4") + "' "
	cSql += " AND BE4_CODOPE = '" + BCI->BCI_CODOPE + "' "
	cSql += " AND BE4_CODLDP = '" + BCI->BCI_CODLDP + "' "
	cSql += " AND BE4_CODPEG = '" + BCI->BCI_CODPEG + "' "
	cSql += " AND D_E_L_E_T_ = ' ' "
endIf

PLSCOMMIT(cSql)

cSql := " UPDATE " + RetsqlName("BD6") 
cSql += " SET BD6_FASE = '" + cFase + "' "
cSql += " WHERE BD6_FILIAL = '" + xfilial("BD6") + "' "
cSql += " AND BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += " AND BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += " AND BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

PLSCOMMIT(cSql)

cSql := " UPDATE " + RetsqlName("BD7") 
cSql += " SET BD7_FASE = '" + cFase + "' "
cSql += " WHERE BD7_FILIAL = '" + xfilial("BD7") + "' "
cSql += " AND BD7_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += " AND BD7_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += " AND BD7_CODPEG = '" + BCI->BCI_CODPEG + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

PLSCOMMIT(cSql)

BRJ->(dbSetOrder(1))
if lUnimed .and. BRJ->(fieldpos("BRJ_GLOSA")) > 0
	cSql := " UPDATE " + RetsqlName("BRJ")
	cSql += " SET BRJ_GLOSA = '" + iif(cFase=="4","1","0") + "' "
	cSql += " WHERE BRJ_FILIAL = '" + xfilial("BRJ") + "' "
	cSql += " AND BRJ_CODIGO IN ("
	cSql += " SELECT BD6_SEQIMP FROM " + RetsqlName("BD6")
	cSql += " WHERE BD6_FILIAL = '" + xfilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
	cSql += " AND BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
	cSql += " AND BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
	cSql += " AND BD6_SEQIMP <> ' ' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY BD6_SEQIMP )"
	cSql += " AND D_E_L_E_T_ = ' ' "

	PLSCOMMIT(cSql)
endif

end Transaction

return

/*/{Protheus.doc} getVldGUI
verifica guias a serem glosadas e retorna o valor total
@type function
@author victor.silva
@since 27/09/2016
/*/
static function getVldGUI(lGuiPeg)
local cAlias 	:= ""
local cFase 	:= ""
local cChavePeg	:= ""
local cChaveGui	:= ""
local cOpeGui 	:= ""
local cAnoGui 	:= ""
local cMesGui 	:= ""
local cNumGui 	:= ""
local cDatGui	:= ""
local nVlrBpr	:= 0
local nVlrMan	:= 0
local nVlrApr	:= 0
local nVlrGlo	:= 0
local lRet		:= .t.
local aRetAux	:= {}
local aRecGUI	:= {}

BCL->( dbSetOrder(1) ) //BCL_FILIAL+BCL_CODOPE+BCL_TIPGUI
if BCL->( msSeek( xFilial("BCL") + BCI->(BCI_CODOPE + BCI_TIPGUI) ) )
	cAlias := BCL->BCL_ALIAS
endIf

if lGuiPeg
	
	//Chave da PEG
	cChavePeg := BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)
	(cAlias)->(dbSetOrder(1))
	
	//exclui movimento contabil
	lRet := PLSEXMCTB("A",cChavePeg)
		
	do case
	case cAlias == "BE4"
		
		if lRet .and. BE4->(msSeek(xFilial(cAlias) + cChavePeg) )
			
			while !(BE4->(eof())) .and.	BE4->(BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG) == xFilial(cAlias) + cChavePeg
				
				//Inicializa variaveis de auxilo
				cFase 		:= BE4->BE4_FASE		//Fase
				cOpeGui 	:= BE4->BE4_CODOPE		//Operadora
				cAnoGui 	:= BE4->BE4_ANOPAG		//Ano
				cMesGui 	:= BE4->BE4_MESPAG		//Mes
				cNumGui 	:= BE4->BE4_NUMERO		//Numero
				cDatGui		:= BE4->BE4_DATPRO		//Data da Guia
				cChaveGui	:= BE4->(BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO) //Chave
				
				//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
				if cFase $ '2|3'
				
					aadd(aRecGUI,{ 'BE4', BE4->(recno()) } )
				
					//Libera a memoria do aArray Auxiliar
					PlsFreArr(@aRetAux)
					
					//Busca Valores da Guia no BD6 da guia
					aRetAux := RetVlGlGui(cAlias,cChaveGui)
					
					//Alimenta variaveis de valor
					nVlrBpr	+= aRetAux[1]
					nVlrMan	+= aRetAux[2]
					nVlrApr	+= aRetAux[3]
					nVlrGlo	+= aRetAux[4]
					
					//Libera a memoria do aArray Auxiliar
					PlsFreArr(@aRetAux)
					
				endIf
				
			BE4->(dbSkip())
			endDo
			
		endIf
		
	case cAlias == "BD5"
		
		if lRet .and. BD5->(msSeek(xFilial(cAlias) + cChavePeg) )
			
			while !(BD5->(eof())) .and.	BD5->(BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG) == xFilial(cAlias) + cChavePeg
				
				//Inicializa variaveis de auxilo
				cFase 		:= BD5->BD5_FASE		//Fase
				cOpeGui 	:= BD5->BD5_CODOPE		//Operadora
				cAnoGui 	:= BD5->BD5_ANOPAG		//Ano
				cMesGui 	:= BD5->BD5_MESPAG		//Mes
				cNumGui 	:= BD5->BD5_NUMERO		//Numero
				cDatGui		:= BD5->BD5_DATPRO		//Data da Guia
				cChaveGui	:= BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO) //Chave
				
				//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
				if cFase $ '2|3'
					
					aadd(aRecGUI,{ 'BD5', BD5->(recno()) } )
					
					//Libera a memoria do aArray Auxiliar
					PlsFreArr(@aRetAux)
					
					//Busca Valores da Guia no BD6 da guia
					aRetAux := RetVlGlGui(cAlias,cChaveGui)
					
					//Alimenta variaveis de valor
					nVlrBpr	+= aRetAux[1]
					nVlrMan	+= aRetAux[2]
					nVlrApr	+= aRetAux[3]
					nVlrGlo	+= aRetAux[4]
					
					//Libera a memoria do aArray Auxiliar
					PlsFreArr(@aRetAux)
					
				endIf
				
			BD5->(dbSkip())
			endDo
			
		endIf
		
	endcase

//guia	
else
	
	do case
	case cAlias == "BE4"
		
		//Inicializa variaveis de auxilo
		cFase 		:= BE4->BE4_FASE		//Fase
		cOpeGui 	:= BE4->BE4_CODOPE		//Operadora
		cAnoGui 	:= BE4->BE4_ANOPAG		//Ano
		cMesGui 	:= BE4->BE4_MESPAG		//Mes
		cNumGui 	:= BE4->BE4_NUMERO		//Numero
		cDatGui		:= BE4->BE4_DATPRO		//Data da Guia
		cChaveGui	:= BE4->(BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO) //Chave

		//exclui movimento contabil
		lRet := PLSEXMCTB("A", cChaveGui + BE4->BE4_ORIMOV)

		//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
		if lRet .and. cFase $ '2|3'
			
			aadd(aRecGUI,{ 'BE4', BE4->(recno()) } )
		
			//Libera a memoria do aArray Auxiliar
			PlsFreArr(@aRetAux)
			
			//Busca Valores da Guia no BD6 da guia
			aRetAux := RetVlGlGui(cAlias,cChaveGui)
			
			//Alimenta variaveis de valor
			nVlrBpr	+= aRetAux[1]
			nVlrMan	+= aRetAux[2]
			nVlrApr	+= aRetAux[3]
			nVlrGlo	+= aRetAux[4]
			
			//Libera a memoria do aArray Auxiliar
			PlsFreArr(@aRetAux)
			
		endIf
		
	case cAlias == "BD5"
		
		//Inicializa variaveis de auxilo
		cFase 		:= BD5->BD5_FASE		//Fase
		cOpeGui 	:= BD5->BD5_CODOPE		//Operadora
		cAnoGui 	:= BD5->BD5_ANOPAG		//Ano
		cMesGui 	:= BD5->BD5_MESPAG		//Mes
		cNumGui 	:= BD5->BD5_NUMERO		//Numero
		cDatGui		:= BD5->BD5_DATPRO		//Data da Guia
		cChaveGui	:= BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO) //Chave
		
		//exclui movimento contabil
		lRet := PLSEXMCTB("A", cChaveGui + BD5->BD5_ORIMOV)
		
		//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
		if lRet .and. cFase $ '2|3'
			
			aadd(aRecGUI,{ 'BD5', BD5->(recno()) } )
		
			//Libera a memoria do aArray Auxiliar
			PlsFreArr(@aRetAux)
			
			//Busca Valores da Guia no BD6 da guia
			aRetAux := RetVlGlGui(cAlias,cChaveGui)
			
			//Alimenta variaveis de valor
			nVlrBpr	+= aRetAux[1]
			nVlrMan	+= aRetAux[2]
			nVlrApr	+= aRetAux[3]
			nVlrGlo	+= aRetAux[4]
			
			//Libera a memoria do aArray Auxiliar
			PlsFreArr(@aRetAux)
			
		endIf
		
	endcase
	
endIf

return( { nVlrBpr, nVlrMan, nVlrApr, nVlrGlo, aRecGUI } )

/*/{Protheus.doc} RetVlGlGui
Retorna os valores da guia para glosa integral
@type function
@author victor.silva
@since 27/09/2016
/*/
static function RetVlGlGui(cAlias,cChaveGui,cFase)
local nVlrApr 	:= 0
local nVlrGlo 	:= 0
local nVlrMan 	:= 0
local nVlrBpr 	:= 0

if BD6->(msSeek(xFilial("BD6") + cChaveGui))
	
	while !BD6->(eof()) .and. 	BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) == xFilial("BD6") + cChaveGui
		
		nVlrApr += BD6->BD6_VALORI
		nVlrGlo += BD6->BD6_VLRGLO
		nVlrMan	+= BD6->BD6_VLRMAN
		nVlrBpr	+= BD6->BD6_VLRBPR
		
	BD6->(dbSkip())
	endDo
endIf

return( {nVlrBpr, nVlrMan, nVlrApr, nVlrGlo} )

/*/{Protheus.doc} PlsGloBD6
Inclui a glosa integral na Guia
@type function
@author victor.silva
@since 27/09/2016
/*/
static function PlsGloBD6(cCodGlo,cDesGlo,cChaveGui,cObs,aItensGlo)
local lGloTx		:= .f.
local nVlrGlo		:= 0
local nVlrGtx		:= 0
local nNivel		:= BCT->(Posicione("BCT",1,xFilial("BCT") + PlsIntPad() + cCodGlo,"BCT_NIVEL"))

default aItensGlo	:= {}

if BD6->(msSeek(xFilial("BD6") + cChaveGui))
	
	while !BD6->(eof()) .and. BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV) == xFilial("BD6") + cChaveGui
		
		//Valida se o item esta 1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
		if BD6->BD6_FASE $ "2,3"
			
			nVlrGlo	:= BD6->BD6_VLRMAN 
			nVlrGtx := BD6->BD6_VLTXPG
			
			lGloTx := .f.
			if BD6->BD6_VLTXPG > 0
				lGloTx := .t.
			endIf
			
			//Alimenta o array para mudanca de fase da opcao de glosar todos os eventos.
			aadd(aItensGlo,{BD6->BD6_SEQUEN,;						//01
							0,;										//02
							nVlrGlo,;								//03
							iIf(lGloTx,"1",""),;					//04
							nVlrGtx,; 								//05
							BDX->BDX_TIPGLO,;						//06
							"1",;									//07
							"1",;									//08 
							"",; 									//09
							0,; 	   								//10
							"1",;									//11
							"",;									//12
							0,;										//13
							100,;									//14
							0,;										//15
							.t.})									//16
			
			BDX->(recLock("BDX",.t.))
			
			BDX->BDX_FILIAL := xFilial("BDX")
			BDX->BDX_IMGSTA := "BR_VERMELHO"
			
			BDX->BDX_CODOPE := BD6->BD6_CODOPE
			BDX->BDX_CODLDP := BD6->BD6_CODLDP
			BDX->BDX_CODPEG := BD6->BD6_CODPEG
			BDX->BDX_NUMERO := BD6->BD6_NUMERO
			BDX->BDX_ORIMOV := BD6->BD6_ORIMOV
			
			BDX->BDX_CODPAD := BD6->BD6_CODPAD
			BDX->BDX_CODPRO := BD6->BD6_CODPRO
			BDX->BDX_DESPRO := BD6->BD6_DESPRO
			BDX->BDX_SEQUEN := BD6->BD6_SEQUEN
			BDX->BDX_CODGLO := cCodGlo
			BDX->BDX_GLOSIS := cCodGlo
			BDX->BDX_DESGLO := cDesGlo
			BDX->BDX_INFGLO := ""
			BDX->BDX_NIVEL  := nNivel
			BDX->BDX_TIPREG := "1"
			BDX->BDX_TIPGLO := "2"
			
			BDX->BDX_PERGLO := 100
			BDX->BDX_VLRGLO := nVlrGlo
			BDX->BDX_VLRGTX := nVlrGtx
			BDX->BDX_PERGTX	:= 100
			
			BDX->BDX_VLRPAG := 0
			BDX->BDX_VLRMAN := 0
			BDX->BDX_VLRBPR := BD6->BD6_VLRBPR
			BDX->BDX_VLRAPR := BD6->BD6_VALORI
			
			BDX->BDX_RESPAL := cObs			
			BDX->BDX_OBS := cObs

			BDX->BDX_DTACAO := dDataBase
			
			BDX->BDX_CRIANA := '1'
			BDX->BDX_ACAO 	:= '1'
			BDX->BDX_ACAOTX := iIf(lGloTx, '1', '' )			
			BDX->BDX_GLACAO := BDX->BDX_ACAO			
			BDX->BDX_QTDPRO := BD6->BD6_QTDPRO			
			BDX->BDX_DATPRO := BD6->BD6_DATPRO			
			
			if getNewPar("MV_PLSREGL",.f.)
				
				if ! empty(BDX->BDX_NIVEL)
					BDX->BDX_VLRAP2 := BDX->BDX_VLRAPR
					BDX->BDX_PERGL2 := BDX->BDX_PERGLO
					BDX->BDX_VLRGL2 := BDX->BDX_VLRGLO
				endIf
				
			endIf
			
			BDX->(msUnLock())
			
		endIf
		
	BD6->(dbSkip())
	endDo
	
endIf

return

/*/{Protheus.doc} PLSA500BX6
Exibe tabela complemento da BD6
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PLSA500BX6(nOpc)
local aAreaBD6   := BD6->(getArea())
local oDlgBX6
local oBrwBX6
local nOpca      := 0
local aCampos    := {}
local nPos       := 0
local nPosSequen := 0
local nCont

//Adicionar aqui campos que nao serao exibidos na MsMget
local cCmpNaoUsa := "BX6_FILIAL/BX6_CODOPE/BX6_CODLDP/BX6_CODPEG/BX6_NUMERO/BX6_ORIMOV/BX6_SEQUEN/BX6_CODPAD/BX6_CODPRO"

//Carrega os campos que serao apresentadas na MsmGet

SX3->(dbSetOrder(1))
if SX3->(msSeek("BX6"))
	while SX3->X3_ARQUIVO == "BX6" .and. !SX3->(eof())
		if !SX3->X3_CAMPO $ cCmpNaoUsa
			aadd(aCampos,SX3->X3_CAMPO)
		endIf
		SX3->(dbSkip())
	endDo
endIf

if nOpc == 2 //Visualizar
	BX6->(dbSetOrder(1))//BX6_FILIAL + BX6_CODOPE + BX6_CODLDP + BX6_CODPEG + BX6_NUMERO + BX6_ORIMOV + BX6_SEQUEN + BX6_CODPAD + BX6_CODPRO
	if! BX6->(msSeek(xFilial("BX6")+cChaveBX6+M->BD6_SEQUEN))
		msgInfo(STR0326)//"Não foram encontradas informações complementares para este registro."
		return
	endIf
else
	cSequenBD6 := M->BD6_SEQUEN
	nPosSequen := ascan(aHeaderBX6,{|x|x[2] == "BX6_SEQUEN"})
	
	RegToMemory("BX6",.t.)
	if (nPosBX6 := ascan(aColsBX6,{|x|x[nPosSequen] == cSequenBD6})) > 0
		for nCont := 1 to len(aHeaderBX6)
			&("M->"+aHeaderBX6[nCont][2]) := aColsBX6[nPosBX6][nCont]
		next
	endIf
	
	M->BX6_CODPAD := M->BD6_CODPAD
	M->BX6_CODPRO := M->BD6_CODPRO
endIf

DEFINE MSDIALOG oDlgBX6 TITLE STR0325 FROM 8.2,10.3 to 36,100.3 of GetWndDefault() //"Complemento Evento"
oDlgBX6:lEscClose := .f.


//Monta o Browse dos Procedimentos

oBrwBX6 := MSMGet():new("BX6",,nOpc,,,,aCampos,{32,1,197,355},/*aCampos*/,,,,,oDlgBX6,,,.t.,,,.t.)

ACTIVATE DIALOG oDlgBX6 CENTERED ON INIT ( EnchoiceBar(oDlgBX6, {|| nOpca := 1,oDlgBX6:end()},{|| nOpca:= 0,oDlgBX6:end()} ))

if nOpca == 1
	
	//Atualiza aCols com as informacoes digitadas
	
	if nOpc <> 2
		if nPosBX6 > 0
			for nCont := 1 to len(aHeaderBX6)
				if aHeaderBX6[nCont][2] == "BX6_SEQUEN"
					aColsBX6[nPosBX6][nCont] := cSequenBD6
				else
					aColsBX6[nPosBX6][nCont] := &("M->"+aHeaderBX6[nCont][2])
				endIf
			next
		else
			aadd(aColsBX6,{})
			for nCont := 1 to len(aHeaderBX6)
				if aHeaderBX6[nCont][2] == "BX6_SEQUEN"
					aadd(aColsBX6[len(aColsBX6)],cSequenBD6)
				else
					aadd(aColsBX6[len(aColsBX6)],&("M->"+aHeaderBX6[nCont][2]))
				endIf
			next
			aadd(aColsBX6[len(aColsBX6)],.f.)//Adiciona o Delete
		endIf
	endIf
endIf

restArea(aAreaBD6)

return


/*/{Protheus.doc} PL500EVGEN
Verifica se o evento e um OPME para digitacao de dados de intercambio
@type function
@author plsteam
@since   13.05.2005
@version 1.0
/*/
function PL500EVGEN()
local lRet := .f.
local aArea := BR8->(getArea())

//Verifica se e um OPME definido na BR8
BR8->(dbSetOrder(1))//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
if BR8->(msSeek(xFilial("BR8")+M->BD6_CODPAD+M->BD6_CODPRO)) .and. BR8->BR8_TPPROC == '5'
	lRet := .t.
endIf

//Verifica se e um OPME generico
if !lRet .and. P090PTUGEN('2')
	lRet := .t.
endIf

restArea(aArea)

return lRet

/*/{Protheus.doc} PLCANCPEG

Cancela todas as guias da PEG

@author Thiago Guilherme
@since 07/2016
@version P12
/*/
function PLCANCPEG()
local cFiltro  	:= ""
local cCodOpe  	:= BCI->BCI_CODOPE
local cCodLDP  	:= BCI->BCI_CODLDP
local cCodPEG  	:= BCI->BCI_CODPEG
local cCodRDA  	:= BCI->BCI_CODRDA
local cFase		:= BCI->BCI_FASE
local cSql		:= ""
local cAlias   := IIF(BCI->BCI_TIPGUI $ "03,05", "BE4", IIF (BCI->BCI_TIPGUI $ "07,08,09", "B4A", "BD5"))
local aAliasIt := {"BD6", "BD7"}
local cAliasBD := RetSqlName(cAlias)
local cDados	 := ""
local aDadCan	 := {}
local cDadNum	 := ""
local cDadOri	 := ""
local nI		 := 1
Local dDatCtbChk := StoD("")
Local lQuebra	:= IIF( findfunction("PLchkQuebr"), PLchkQuebr(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG), .T.)

dDatCtbChk := PLRtDtCTB(cCodOpe, cCodLDP, cCodPEG, , .f.)

if lQuebra .AND. PLVLDBLQCO(dDatCtbChk, {"PLS003"}, .t.) //se a data do sistema esta no periodo bloqueado pela contabilidade, não pode executar a ação
	
	if BCI->BCI_STTISS == "4"
		
		msgAlert(STR0329,STR0290) //"Este PEG já foi cancelado." # "Atenção"
		
	elseIf BCI->BCI_FASE == "4"
		
		Help("",1,"PLSA500FAT")
		
	else
		
		//TODO - alex rever
		
		cSql := " SELECT " + cAliasBD + ".R_E_C_N_O_ RECNO, "
		if cAlias $ "BD5"
			cSql += cAlias + "_FILIAL FILIAL, " + cAlias + "_OPEMOV OPEMOV, " + cAlias + "_CODLDP CODLDP, " + cAlias + "_CODPEG CODPEG, " + cAlias + "_NUMERO NUMERO, " + cAlias + "_ORIMOV ORIMOV, "
			cSql += cAlias + "_ANOAUT ANOAUT, " + cAlias + "_MESAUT MESAUT, " + cAlias + "_NUMAUT NUMAUT "
		elseIf cAlias $ "BE4" 
			cSql += cAlias + "_FILIAL FILIAL, " + cAlias + "_CODOPE OPEMOV, " + cAlias + "_CODLDP CODLDP, " + cAlias + "_CODPEG CODPEG, " + cAlias + "_NUMERO NUMERO, " + cAlias + "_ORIMOV ORIMOV, "
			cSql += cAlias + "_ANOINT ANOAUT, " + cAlias + "_MESINT MESAUT, " + cAlias + "_NUMINT NUMAUT "
		else
			cSql += cAlias + "_FILIAL FILIAL, " + cAlias + "_OPEMOV OPEMOV, " + cAlias + "_ANOAUT CODLDP, " + cAlias + "_MESAUT CODPEG, " + cAlias + "_NUMAUT NUMERO, " + cAlias + "_ORIMOV ORIMOV, "
			cSql += " '' ANOAUT, '' MESAUT, '' NUMAUT "
		endIf	
		
		cSql += " FROM " + cAliasBD
		cSql += " WHERE "
		cSql += cAlias + "_FILIAL = '" + xFilial(cAlias)  + "' AND "
		cSql += cAlias + "_CODOPE = '" + alltrim(cCodOpe) + "' AND "
		cSql += cAlias + "_CODLDP = '" + alltrim(cCodLDP) + "' AND "
		cSql += cAlias + "_CODPEG = '" + alltrim(cCodPEG) + "' AND "
		cSql += cAlias + "_CODRDA = '" + alltrim(cCodRda) + "'"
		
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbCanc",.F.,.T.)
		
		if !(TrbCanc->(EOF()))
	
			if msgYesNo(STR0330) .and. PLSEXMCTB( "T", (cCodOpe + cCodLDP + cCodPEG))  //"Tem certeza que deseja cancelar o PEG? O processo não poderá ser desfeito." //13-07
				
				begin Transaction
					
					//Progress Bar ADVPL -> 3 etapas
					procRegua(5)			
	
					while !(TrbCanc->(eof()))
					
						cDados +=  str(TrbCanc->RECNO) + ','	
						
						aAdd(aDadCan, {TrbCanc->FILIAL, TrbCanc->OPEMOV, TrbCanc->CODLDP, TrbCanc->CODPEG, TrbCanc->NUMERO, TrbCanc->ORIMOV, TrbCanc->ANOAUT, TrbCanc->MESAUT, TrbCanc->NUMAUT } )
						
						cDadNum += "'" + TrbCanc->NUMERO + "'" + ',' 
						
						cDadOri += iIf(TrbCanc->ORIMOV $ cDadOri, '', "'" + TrbCanc->ORIMOV + "'" + ',' )
						
						TrbCanc->(dbSkip())
						
					endDo
					
					cDados := left(cDados, len(cDados)-1)
					cDadNum := iIf(right(cDadNum, 1) $ ",", left(cDadNum, len(cDadNum)-1), "")
					cDadOri := iIf(right(cDadOri, 1) $ ",", left(cDadOri, len(cDadOri)-1), "")
					TrbCanc->(dbCloseArea())
												
					IncProc()  //1º Incremento
				
					//Atualizo o cabeçalho
					cSql := " UPDATE " + cAliasBD + " SET "
					cSql += cAlias + "_SITUAC = '2' WHERE "  //2 -cancelado
					cSql += cAliasBD + ".R_E_C_N_O_ IN ( " + cDados + ")
					
					TCSqlExec(cSql)
	
					IncProc()  //2º Incremento	
							
					//Atualizo BD6/BD7 relacionadas
					for nI := 1 to len(aAliasIt)
						
						cSql := " UPDATE " + retSqlName(aAliasIt[nI]) + " SET "
						
						cSql += aAliasIt[nI]+"_SITUAC = '2' WHERE "  //2 -cancelado
						cSql += aAliasIt[nI]+"_FILIAL = '" + xFilial(aAliasIt[nI]) + "' AND " + aAliasIt[nI]+"_CODOPE = '" + cCodOpe + "' AND " + aAliasIt[nI]+"_CODLDP = '" + cCodLDP + "' AND "
						cSql += aAliasIt[nI]+"_CODPEG = '" + cCodPeg + "' AND " + aAliasIt[nI]+"_NUMERO IN (" + cDadNum + ") AND " + aAliasIt[nI]+"_ORIMOV IN (" + cDadori + ")"
						
						TCSqlExec(cSql)
						
					Next	
													
					IncProc()  //3º Incremento

					//Atualizo a B53 - Auditoria, caso tenha guias que passaram pela auditoria.
					if cAlias <> "B4A"
					
						cSql := " UPDATE " + RetSqlName("B53") + " SET "
						cSql += " B53_STATUS = '6'  WHERE "  //6 -cancelado
						cSql += " B53_FILIAL = '" + xFilial("B53") + "' AND B53_CODOPE = '" + cCodOpe + "' AND B53_CODLDP = '" + cCodLDP + "' "
						cSql += " AND B53_CODPEG = '" + cCodPeg + "' AND B53_NUMERO IN (" + cDadNum + ") AND B53_ORIMOV IN (" + cDadori + ")"
						cSql += " AND B53_CODRDA = '" + cCodRDA + "'"                                                                           
					
						TCSqlExec(cSql)
						
					endIf
	
					IncProc()  //4º Incremento
						
					//Chamo função para verificar se entre essas guias tem anexos e se algum anexo passou em auditoria.
					PlCanAdAnM(aDadCan, BCI->BCI_TIPGUI)	
												
					IncProc()  //5º Incremento
					
					//Gravo na BCI a situação de Cancelado e atualizo o BCI_STTISS
					BCI->(RecLock("BCI", .F.))
						BCI->BCI_SITUAC := '2'
						BCI->BCI_STTISS := '4'
					BCI->(Msunlock())
					
					//atualiza totais do peg
					PLPEGTOT()
												
				end Transaction
				
				MsgInfo(STR0331) //"Cancelamento concluído!"
				
			endIf
	
		else
			MsgAlert(STR0332, STR0290) //"Esta PEG não possui guias." # "Atenção"
			TrbCanc->(dbCloseArea())
			return
		endIf
		
		if select("TrbCanc") > 0
			TrbCanc->(dbCloseArea())
		endIf
		
	endIf
	
endIf

return

/*/{Protheus.doc} PLSA500MTA
Monta a tela com os dados retornados da query

@author PLSTEAM
@since 07/2016
@version P12
/*/
function PLSA500MTA(cCodOpe,cCodLDP,cCodPeg,cNumero,lGloMan)
local oDlg			:= nil
local oChk			:= nil
local oListEve		:= nil
local oListCrit		:= nil
local cCadastro		:= "Análise de Glosa"
local cQuery		:= ""
local aDadProc		:= {}
local aDadC			:= {}
local aSize			:= {}
local aRet			:= {}
local aAux			:= {}
local nlinhaIni		:= 0
local nColunaIni	:= 0
local lCheck		:= .f.
local nOpca			:= 0
local nCont			:= 0
local nPos			:= 0
local nReg			:= 0
local aSel 			:= {}

//variaveis lgpd
local aCamposCen   := {}
local aBls 	   	   := {}

default lGloMan := getNewPar("MV_PLSCGMA",.f.)

cQuery := "SELECT BDXDELETADO.R_E_C_N_O_ REC "
cQuery += "  FROM " + retSQLName("BDX") + " BDXDELETADO " 
cQuery += " WHERE BDXDELETADO.BDX_FILIAL = '" + xFilial("BDX") + "' "
cQuery += "   AND BDXDELETADO.BDX_CODOPE = '" + cCodOpe + "' "
cQuery += "   AND BDXDELETADO.BDX_CODLDP = '" + cCodLDP + "' "
cQuery += "   AND BDXDELETADO.BDX_CODPEG = '" + cCodPeg + "' "
cQuery += "   AND BDXDELETADO.BDX_NUMERO = '" + cNumero + "' "

if lGloMan
	cQuery += " AND BDXDELETADO.BDX_TIPGLO IN('1','2') "
else
	cQuery += " AND BDXDELETADO.BDX_TIPGLO = '1' "
endIf

cQuery += " AND BDXDELETADO.BDX_REGREC <> 'S' "
cQuery += " AND BDXDELETADO.BDX_ACAO   <> ' ' "
cQuery += " AND BDXDELETADO.BDX_CRIANA = '1' "
cQuery += " AND BDXDELETADO.BDX_TIPREG = '1' "
cQuery += " AND BDXDELETADO.D_E_L_E_T_ = '*' "

cQuery += " AND EXISTS ( SELECT BDXATIVO.R_E_C_N_O_ RECNO "
cQuery += "                FROM " + retSQLName("BDX") + " BDXATIVO "
cQuery += "               WHERE BDXATIVO.BDX_FILIAL = '" + xFilial("BDX") + "' "
cQuery += "                 AND BDXATIVO.BDX_CODOPE = BDXDELETADO.BDX_CODOPE "  
cQuery += "                 AND BDXATIVO.BDX_CODLDP = BDXDELETADO.BDX_CODLDP "
cQuery += "                 AND BDXATIVO.BDX_CODPEG = BDXDELETADO.BDX_CODPEG "
cQuery += "                 AND BDXATIVO.BDX_NUMERO = BDXDELETADO.BDX_NUMERO "
cQuery += "                 AND BDXATIVO.BDX_ORIMOV = BDXDELETADO.BDX_ORIMOV "
cQuery += "                 AND BDXATIVO.BDX_SEQUEN = BDXDELETADO.BDX_SEQUEN "
cQuery += "                 AND BDXATIVO.BDX_CODPAD = BDXDELETADO.BDX_CODPAD " 
cQuery += "                 AND BDXATIVO.BDX_CODPRO = BDXDELETADO.BDX_CODPRO " 
cQuery += "                 AND BDXATIVO.BDX_CODGLO = BDXDELETADO.BDX_CODGLO " 
cQuery += "                 AND BDXATIVO.BDX_TIPGLO = BDXDELETADO.BDX_TIPGLO "
cQuery += "                 AND BDXATIVO.D_E_L_E_T_ = ' ') "

cQuery += "ORDER BY BDXDELETADO.BDX_SEQUEN, BDXDELETADO.BDX_CODGLO, BDXDELETADO.R_E_C_N_O_ DESC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cQuery)),"PLSA500AGA",.f.,.t.)

if PLSA500AGA->(eof()) .or. ! msgYesNo("Existem análises realizadas nessa guia anteriormente, deseja avaliá-las?")
	
	BDX->( dbGoTo(PLSA500AGA->REC) )
	
	cSql := "UPDATE " + retSQLName("BDX") + " SET BDX_REGREC = 'S' "
	cSql += "WHERE BDX_FILIAL = '" + xFilial("BDX") + "' "
	cSql += "  AND BDX_CODOPE = '" + BDX->BDX_CODOPE + "' "
	cSql += "  AND BDX_CODLDP = '" + BDX->BDX_CODLDP + "' "
	cSql += "  AND BDX_CODPEG = '" + BDX->BDX_CODPEG + "' "
	cSql += "  AND BDX_NUMERO = '" + BDX->BDX_NUMERO + "' "
	cSql += "  AND BDX_ORIMOV = '" + BDX->BDX_ORIMOV + "' "
	cSql += "  AND BDX_TIPGLO = '2' "
	cSql += "  AND D_E_L_E_T_ = '*' "
	
	TCSqlExec(cSql)
		
	PLSA500AGA->(dbCloseArea())
	return({})
	
endIf

plsTField("PLSA500AGA",.f.,{ "BDX_VLRGLO","BDX_PERGLO" } )

while ! PLSA500AGA->(eof())
	
	BDX->( dbGoTo(PLSA500AGA->REC) )
	
	if aScan(aDadProc,{|x| x[1]+x[11]+x[2] == BDX->(BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO) }) == 0
		
		aadd(aDadProc, {BDX->BDX_SEQUEN, BDX->BDX_CODPRO, BDX->BDX_DESPRO, BDX->BDX_VLRGLO,; //4
						BDX->BDX_PERGLO, BDX->BDX_CODOPE, BDX->BDX_CODLDP, BDX->BDX_CODPEG,; //8
						BDX->BDX_NUMERO, BDX->BDX_ORIMOV, BDX->BDX_CODPAD, BDX->BDX_IMGSTA,; //12
						BDX->BDX_ACAO  , BDX->BDX_CODGLO, .f.})
		
	endIf
	
PLSA500AGA->(dbSkip())
endDo

PLSA500AGA->(dbCloseArea())

//Em algumas situações o aDadProc não estava sendo atualizado gerando error.log na montagem do dialogo
if len(aDadProc) == 0

   msgStop("Não existem criticas a serem analisadas.")
    
   return({})
   
endIf   

aSize := msAdvSize()

nlinhaIni 	:= aSize[1]  + 005 //005
nColunaIni 	:= aSize[2]  + 005 //035

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

@ nColunaIni, nlinhaIni say "Eventos" size 100,010 PIXEL of oDlg

oListEve := tcBrowse():new(nColunaIni + 010,nlinhaIni, aSize[5] * 0.49, aSize[3]*0.16, ,	{}, {}, oDlg,,,,, {||},, ,,,,,.f.,,.t.,,.f.,,, )

ADD COLUMN to oListEve BitMap Data { || LoadBitMap( GetResources(), iIf(!aDadProc[oListEve:nAt,len(aDadProc[oListEve:nAt])] ,EVal({|| lCheck := .f.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 ALIGN CENTERED NOHILITE
oListEve:addColumn(tcColumn():new('Item',{ || aDadProc[oListEve:nAt, 1] },"@C",nil,nil,nil,025,.f.,.f.,nil,nil,nil,.f.,nil))
oListEve:addColumn(tcColumn():new('Código Evento',{ || aDadProc[oListEve:nAt, 2] },"@C",nil,nil,nil,050,.f.,.f.,nil,nil,nil,.f.,nil))
oListEve:addColumn(tcColumn():new('Descrição',{ || aDadProc[oListEve:nAt, 3] },"@C",nil,nil,nil,200,.f.,.f.,nil,nil,nil,.f.,nil))
oListEve:addColumn(tcColumn():new('Valor Glosa'  ,{ || transform(aDadProc[oListEve:nAt, 4], "@R 999,999,999.99") },"@C",nil,nil,nil,050,.f.,.f.,nil,nil,nil,.f.,nil))
oListEve:addColumn(tcColumn():new('%',{ || transform(aDadProc[oListEve:nAt, 5], "@R 999.99") },"@C",nil,nil,nil,035,.f.,.f.,nil,nil,nil,.f.,nil))

oListEve:setArray(aDadProc)

oListEve:BLDBLCLICK := { || marcaLinha(oListEve:nAt,aDadProc,lCheck), plsSelDad(aSel,aDadProc[oListEve:nAt]), oListEve:refresh() }

if objCENFUNLGP:isLGPDAt()
	aCamposCen := {.f., "BDX_SEQUEN", "BDX_CODPRO","BDX_DESPRO",.f.,.f.}
	aBls := objCENFUNLGP:getTcBrw(aCamposCen)

	oListEve:aObfuscatedCols := aBls
endif

@ ( ( aSize[3] * 0.16) + 050 ), 10 CHECKBOX oChk VAR lCheck PROMPT "Marca e Desmarca todos" of oDlg size 100,8 //"Marca e Desmarca todos"
oChk:bChange := {|| marcaLinha('',aDadProc,lCheck), plsSelDad(aSel,aDadProc, .t.), oListEve:refresh() }

@ nColunaIni + 160, nlinhaIni say "Críticas" size 100,010 PIXEL of oDlg

oListCrit := tcBrowse():new(nColunaIni + 175,nlinhaIni,aSize[5]*0.49 ,aSize[3]*0.16 ,,{},{}, oDlg,,,,, {||},, ,,,,,.f.,,.t.,,.f.,,, )

oListCrit:addColumn(tcColumn():new('Item'		,{ || aDadC[oListCrit:nAt, 1] },"@C",nil,nil,nil,025,.f.,.f.,nil,nil,nil,.f.,nil))
oListCrit:addColumn(tcColumn():new('Cód. Glosa'	,{ || aDadC[oListCrit:nAt, 2] },"@C",nil,nil,nil,050,.f.,.f.,nil,nil,nil,.f.,nil))
oListCrit:addColumn(tcColumn():new('Descrição'	,{ || aDadC[oListCrit:nAt, 3] },"@C",nil,nil,nil,300,.f.,.f.,nil,nil,nil,.f.,nil))
oListCrit:addColumn(tcColumn():new('Ação'		,{ || aDadC[oListCrit:nAt, 4] },"@C",nil,nil,nil,050,.f.,.f.,nil,nil,nil,.f.,nil))

oListEve:bChange := {|| aDadC := PLSA500CRI(aDadProc[oListEve:nAt, 6], aDadProc[oListEve:nAt,  7], aDadProc[oListEve:nAt,  8],;
											aDadProc[oListEve:nAt, 9], aDadProc[oListEve:nAt, 10], aDadProc[oListEve:nAt, 11],;
											aDadProc[oListEve:nAt, 1], aDadProc[oListEve:nAt,  2], lGloMan),;
											oListCrit:setArray(aDadC), oListCrit:Refresh()}

if objCENFUNLGP:isLGPDAt()
	aCamposCen := {"BDX_SEQUEN", "BDX_CODGLO","BDX_DESGLO","BDX_ACAO"}
	aBls := objCENFUNLGP:getTcBrw(aCamposCen)

	oListCrit:aObfuscatedCols := aBls
endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := 1, iIf(PLSA500SEL(aDadProc),oDlg:end(),nOpca := 2)}, {||nOpca := 0, oDlg:end()}) Centered

if  nOpca == 1
	
	BDX->(dbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO
	
	for nReg := 1 to len(aSel)
		
		cGloAux := ''
		cCodOpe := aSel[nReg][6]
		cCodLdp := aSel[nReg][7]
		cCodPeg := aSel[nReg][8]
		cNumero := aSel[nReg][9]
		cOriMov := aSel[nReg][10]
		cCodPad := aSel[nReg][11]
		cCodPro := aSel[nReg][2]
		cSequen := aSel[nReg][1]
		
		aDadC 	:= PLSA500CRI(cCodOpe, cCodLdp, cCodPeg, cNumero, cOriMov, cCodPad, cSequen, cCodPro, lGloMan)

		//olhando glosa por glosa se existe na nova analise
		for nCont := 1 to len(aDadC)
			
			cCodGlo := aDadC[nCont,2]
			
			if cCodGlo <> cGloAux 
			
				cGloAux := cCodGlo
				
				if BDX->(msSeek(xFilial("BDX") + cCodOpe + cCodLdp + cCodPeg + cNumero + cOriMov + cCodPad + cCodPro + cSequen + cCodGlo))
					
					while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO) == xFilial("BDX") + cCodOpe + cCodLdp + cCodPeg + cNumero + cOriMov + cCodPad + cCodPro + cSequen + cCodGlo
					  
						BDX->(recLock("BDX", .f.))
						BDX->BDX_REGREC := "S"
						BDX->(dbdelete())
						BDX->(msUnLock())
						
					BDX->(dbSkip())
					endDo
							
				endIf
				
			endIf
			
			BDX->(dbGoTo(aDadc[nCont,36]))
			
			//pega o registro que foi analisado e esta deletado e recupera
			if BDX->(deleted())           	
				BDX->(recLock("BDX",.f.))
				BDX->(dbRecall())			
				BDX->BDX_REGREC := ""
				BDX->(msUnLock())
			endIf
			
		next
		
	next
	
endIf

return

/*/{Protheus.doc} plsSelDad
Seleciona dados do grid

@author PLSTEAM
@since 07/2016
@version P12
/*/
static function plsSelDad(aSel, aDad, lAll)
local nTam := 0
local nPos := 0 

default lAll := .f.

if lAll
	aSel := aClone(aDad)
else
	
	nPos := aScan(aSel,{|x| x[11] + x[2] + x[14] == aDad[11] + aDad[2] + aDad[14] })

	if nPos == 0
		aadd(aSel, aClone(aDad))
	else
		nTam := len(aSel)
		aDel(aSel,nPos)
		aSize(aSel,nTam-1)
	endIf
	
endIf	
	
return

/*/{Protheus.doc} PLSA500CRI
Carrega as críticas de acordo com o evento selecionado
@author PLSTEAM
@since 07/2016
@version P12
/*/
function PLSA500CRI(cCodOpe, cCodLDP, cCodPeg, cNumero, cOrimov, cCodPad, cSequen, cCodPro, lGloMan, lRecuGlo)
local nPos		:= 0
local aRet 		:= retSx3Box( X3CBox( Posicione('SX3',2,'BDX_ACAO','X3_CBOX') ),,,1 )
local cDesAcao	:= ""
local cQuery	:= ""
local aDadC		:= {}

default lGloMan  := getNewPar("MV_PLSCGMA",.f.)
default lRecuGlo := getNewPar("MV_PLRECUG",.t.)
default cCodPad  := ""
default cCodPro  := ""
default cSequen  := ""

cQuery := " SELECT BDXDELETADO.R_E_C_N_O_ REC "

if ! empty( cCodPad + cSequen + cCodPro )
	
	cQuery += "  FROM " + retSQLName("BDX") + " BDXDELETADO WHERE "

	cQuery += iIf( lGloMan, " ( ","" ) 
	cQuery += "  EXISTS ( SELECT BDXATIVO.R_E_C_N_O_ RECNO "
	cQuery += "             FROM " + retSQLName("BDX") + " BDXATIVO "
	cQuery += "             WHERE BDXATIVO.BDX_FILIAL = '" + xFilial("BDX") + "' "
	cQuery += "               AND BDXATIVO.BDX_CODOPE = BDXDELETADO.BDX_CODOPE "  
	cQuery += "               AND BDXATIVO.BDX_CODLDP = BDXDELETADO.BDX_CODLDP "
	cQuery += "               AND BDXATIVO.BDX_CODPEG = BDXDELETADO.BDX_CODPEG "
	cQuery += "               AND BDXATIVO.BDX_NUMERO = BDXDELETADO.BDX_NUMERO "
	cQuery += "               AND BDXATIVO.BDX_ORIMOV = BDXDELETADO.BDX_ORIMOV "
	cQuery += "               AND BDXATIVO.BDX_SEQUEN = BDXDELETADO.BDX_SEQUEN "
	cQuery += "               AND BDXATIVO.BDX_CODPAD = BDXDELETADO.BDX_CODPAD " 
	cQuery += "               AND BDXATIVO.BDX_CODPRO = BDXDELETADO.BDX_CODPRO " 
	cQuery += "               AND BDXATIVO.BDX_CODGLO = BDXDELETADO.BDX_CODGLO " 
	cQuery += "               AND BDXATIVO.BDX_TIPGLO = BDXDELETADO.BDX_TIPGLO "
	cQuery += "               AND BDXATIVO.BDX_REGREC = ' ' " 
	cQuery += "               AND BDXATIVO.D_E_L_E_T_ = ' ' ) "
	cQuery += iIf(lGloMan, " OR BDXDELETADO.BDX_TIPGLO = '2' AND BDXDELETADO.BDX_ACAO = '1' ) AND ", " AND " )
	
else
	cQuery += "  FROM " + retSQLName("BDX") + " BDXDELETADO, " + retSqlName("BD6") + " BD6 "
	cQuery += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND "
endIf

cQuery += " BDXDELETADO.BDX_FILIAL = '" + xFilial("BDX") + "' AND "
cQuery += " BDXDELETADO.BDX_CODOPE = '" + cCodOpe + "' AND "
cQuery += " BDXDELETADO.BDX_CODLDP = '" + cCodLDP + "' AND "
cQuery += " BDXDELETADO.BDX_CODPEG = '" + cCodPeg + "' AND "

if ! empty(cNumero)
	cQuery += " BDXDELETADO.BDX_NUMERO = '" + cNumero + "' AND "
endIf	

if ! empty(cOrimov)
	cQuery += " BDXDELETADO.BDX_ORIMOV = '" + cOrimov + "' AND "
endIf

if ! empty( cSequen + cCodPad + cCodPro )
	
	cQuery += " BDXDELETADO.BDX_SEQUEN = '" + cSequen + "' AND "
	cQuery += " BDXDELETADO.BDX_CODPAD = '" + cCodPad + "' AND "
	cQuery += " BDXDELETADO.BDX_CODPRO = '" + cCodPro + "' AND "
	
else

	cQuery += " BD6_CODOPE = BDXDELETADO.BDX_CODOPE AND "
	cQuery += " BD6_CODLDP = BDXDELETADO.BDX_CODLDP AND "
	cQuery += " BD6_CODPEG = BDXDELETADO.BDX_CODPEG AND "
	cQuery += " BD6_NUMERO = BDXDELETADO.BDX_NUMERO AND "
	cQuery += " BD6_ORIMOV = BDXDELETADO.BDX_ORIMOV AND "
	cQuery += " BD6_CODPAD = BDXDELETADO.BDX_CODPAD AND "
	cQuery += " BD6_CODPRO = BDXDELETADO.BDX_CODPRO AND "
	cQuery += " BD6_SEQUEN = BDXDELETADO.BDX_SEQUEN AND "
	cQuery += " BD6.D_E_L_E_T_ = ' ' AND "
	
endIf

//Somente glosa manual
if lRecuGlo .and. lGloMan
	
	cQuery += " BDXDELETADO.BDX_TIPGLO = '2' AND " 

//Glosa manual e eletronica	
elseIf lGloMan

	cQuery += " BDXDELETADO.BDX_TIPGLO IN('1','2') AND "
	
//Somente glosa eletronica	
else

	cQuery += " BDXDELETADO.BDX_TIPGLO = '1' AND "
	
endIf

cQuery += " BDXDELETADO.BDX_CRIANA = '1' AND "
cQuery += " BDXDELETADO.BDX_REGREC <> 'S' AND "
cQuery += " BDXDELETADO.D_E_L_E_T_ = '*' "

cQuery += " ORDER BY BDXDELETADO.BDX_TIPGLO,BDXDELETADO.BDX_CODGLO, BDXDELETADO.BDX_TIPREG, BDXDELETADO.R_E_C_N_O_ DESC "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cQuery)),"PLSA500CRI",.f.,.t.)

if ! PLSA500CRI->(eof())

	plsTField("PLSA500CRI",.f.,{ "BDX_VLRAP2","BDX_VLRBP2","BDX_VLRGL2","BDX_VLRMA2","BDX_VLRPA2","BDX_QTDINF","BDX_VLRINF",;
								 "BDX_VLGREA", "BDX_PERGL2", "BDX_QTDPRO", "BDX_QTDGLO", "BDX_QTDREC", "BDX_VLRREC" } )
endIf

while ! PLSA500CRI->(eof())
	
	BDX->( dbGoto(PLSA500CRI->REC) )
	
	if aScan(aDadC,{|x| x[38] == BDX->(BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO+BDX_CODGLO+BDX_DESGLO) }) == 0
		
		nPos := aScan(aRet,{|x,y| x[2] == BDX->BDX_ACAO})
		
		cDesAcao := ""
		
		if nPos > 0
			cDesAcao := aRet[nPos,3]
		endIf
		
		aadd(aDadC, {BDX->BDX_SEQUEN, BDX->BDX_CODGLO, BDX->BDX_DESGLO,cDesAcao,;
			 		 BDX->BDX_CODOPE, BDX->BDX_CODLDP, BDX->BDX_CODPEG, BDX->BDX_NUMERO, BDX->BDX_ORIMOV,;
			 		 BDX->BDX_CODPAD, BDX->BDX_CODPRO, BDX->BDX_SEQUEN, BDX->BDX_NIVEL, BDX->BDX_CRIANA,;
			 		 BDX->BDX_INFGLO, BDX->BDX_TIPREG, BDX->BDX_TIPGLO, BDX->BDX_CODTPA, BDX->BDX_VLRAP2,;
					 BDX->BDX_VLRBP2, BDX->BDX_VLRGL2, BDX->BDX_VLRMA2, BDX->BDX_VLRPA2, BDX->BDX_QTDINF,;
					 BDX->BDX_VLRINF, BDX->BDX_GLACAO, BDX->BDX_VLGREA, BDX->BDX_PERGL2, BDX->BDX_QTDPRO,;
			 		 BDX->BDX_QTDGLO, BDX->BDX_QTDREC, BDX->BDX_VLRREC, BDX->BDX_DATPRO, '',;
			 		 BDX->BDX_IMGSTA, PLSA500CRI->REC, BDX->BDX_ACAO,;
			 		 BDX->(BDX_SEQUEN+BDX_CODPAD+BDX_CODPRO+BDX_CODGLO+BDX_DESGLO)})
	
	endIf
			 
PLSA500CRI->(dbSkip())
endDo

PLSA500CRI->(dbCloseArea())

return aDadC

/*/{Protheus.doc} PLSA500SEL

Checa se alguma linha foi selecionada.

@author Fábio Siqueira dos Santos
@since 07/2016
@version P12
/*/
Static Function PLSA500SEL(aArray)
Local nFor			:= 0
Local lSelecionado	:= .f.

For nFor := 1 To Len(aArray)

	If aArray[nFor, len(aArray[nFor])] //Campo que verifica se foi marcado
		lSelecionado := .T.
		Exit
	EndIf

Next nFor

If !lSelecionado
	MsgAlert('É necessário selecionar pelo menos um procedimento.')
EndIf

return(lSelecionado)

/*/{Protheus.doc} PLSVRDRPY

Verifica se algum procedimento da PEG/Guia selecionada tem redução de custo aplicada e alerta o usuário, quando revalorar o pagamento
cTipoAt: "1" - Apenas verifica se existe redução de custo / "2" - Realiza atualização no campo BD7_REDCUS
@author Renan Martins
@since 09/2016
@version P12
/*/
function PLSVRDRPY(cChave, cTipoAt, lMFPeg)
local aArea7 		:= BD7->(getArea())
local lRet			:= .f.
local cChavPes		:= ""
default cChave		:= ""
default lMFPeg		:= .f.

if (lMFPeg)
	cChave 	:= left(cChave,16)
	cChavPes	:= 'BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG)'
else
	cChavPes	:= 'BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)'
endIf

BD7->(dbSetOrder(1))

if (BD7->(msSeek(xFilial("BD7") + cChave)))
	
	if (cTipoAt == "1")
		while (!BD7->(eof()) .and. &(cChavpes) == xFilial("BD7")+cChave )
			if (BD7->BD7_REDCUS == "1")
				lRet := .t.  //Se encontrou algum, pode sair do laço
				exit
			endIf
			BD7->(dbSkip())
		endDo
		
	else
		while (!BD7->(eof()) .and. &(cChavpes) == xFilial("BD7")+cChave )
			BD7->(recLock("BD7", .f.))
			BD7->BD7_REDCUS := ""
			BD7->(msUnLock())
			BD7->(dbSkip())
		endDo
	endIf
endIf
BD7->(restArea(aArea7))

return(lRet)

/*/{Protheus.doc} PLSVLEBSBD5
Função para replicar o código do beneficiário da BD5 para a BD6.
Função semelhante à que ajusta o código da especialidade em caso de troca.
@type function
@author Oscar Zanin
@since 21/12/2016
@version 12
/*/
function PLSVLEBSBD5()
local lRet 		:= .t.
local aArea		:= BD6->(getArea())

if BD5->BD5_TIPGUI == "01" .and. !INCLUI
	
	if M->BD5_OPEUSR + M->BD5_CODEMP + M->BD5_MATRIC + M->BD5_TIPREG + M->BD5_DIGITO <> BD5->BD5_OPEUSR + BD5->BD5_CODEMP + BD5->BD5_MATRIC + BD5->BD5_TIPREG + BD5->BD5_DIGITO
		BD6->(dbSetOrder(1))
		
		if BD6->(msSeek(xFilial("BD6")+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO))
			
			BD6->(recLock("BD6", .f.))
			BD6->BD6_OPEUSR := M->BD5_OPEUSR
			BD6->BD6_CODEMP := M->BD5_CODEMP
			BD6->BD6_MATRIC := M->BD5_MATRIC
			BD6->BD6_TIPREG := M->BD5_TIPREG
			BD6->BD6_DIGITO := M->BD5_DIGITO
			BD6->BD6_NOMUSR := M->BD5_NOMUSR
			BD6->(msUnLock())
			
		endIf
		
	endIf
	
endIf

BD6->(restArea(aArea))

return(lRet)

/*/{Protheus.doc} 
Função para cancelar guias que estão em auditoria ou possuem anexos quando a opção Cancelar PEG for ativada.
@author Renan Martins
@since 06/2017
@version 12
/*/
Function PlCanAdAnM (aDadCan, cTipGui)	
Local nI		:= 1
Local cChaveG	:= ""

Begin Transaction	

	For nI := 1 TO Len(ADadCan)
	
		If cTipGui $ "01/02/03"
	
			B4A->(dbSetOrder(4))
			B53->(dbSetOrder(1))
	
			cChaveG := ADadCan[nI,1] + ADadCan[nI,2] + ADadCan[nI,7] + ADadCan[nI,8] + ADadCan[nI,9]  //Montagem da chave de Guia principal: FILIAL + OPEMOV + ANOAUT + MESAUT + NUMAUT 

			If ( B4A->(msSeek(cChaveG)) )
	
				While !B4A->(EOF()) .AND. (xFilial("B4A") + B4A->B4A_GUIREF) == cChaveG
	
					B4A->(Reclock("B4A",.F.))
						B4A->B4A_CANCEL := '1'
						B4A->B4A_STATUS := '3'
						B4A->B4A_STTISS := '6'  //Cancelada
					B4A->(MsUnlock())
	
					//Cancelo os Anexos na Auditoria
					If B53->(MsSeek(xFilial("B4A") + B4A->(B4A_OPEMOV + B4A_ANOAUT + B4A_MESAUT + B4A_NUMAUT)))
		 				B53->(Reclock("B53",.F.)) 
						B53->B53_STATUS := '6'
						B53->(MsUnlock())
		 			EndIf
		 		B4A->(dbSkip())
		 		EndDo
		 		
		 	EndIf
		 	
		 EndIf
		 
	Next
	
End Transaction

Return

/*/{Protheus.doc} PLINVLGM
Valid do campo Saldo a pagar (glosa manual)
Possibilita o uso da glosa manual informando o valor à pagar
@type Static function
@author Oscar Zanin
@since 22/05/2017
@version 12
/*/
static function PLINVLGM(__nValor, __nQuant, nVlrSaldo, nVlrMan, nVlrUniX )
local nBkp := __nValor
local lRet := .t.

__nValor := nVlrSaldo - nVlrMan

if __nValor < 0
	__nValor := nBkp
	lRet 	 := .f.
endIf

if lRet
	__nQuant := 0
endIf

return lRet

/*/{Protheus.doc} PLINQTGM
Valid do campo Quantidade à glosar (glosa manual)
Possibilita o uso da glosa manual informando a quantidade à glosar
@type Static function
@author PLSTEAM
@since 22/05/2017
@version 12
/*/
static function PLINQTGM(__nValor, nQtdProX, nValSaldo, __nQuant, nVlrOriginal, nVlrJaGlosado, oBrwPosic, oBrwGlo)
local nBkp	 	:= __nValor
local nAux 		:= 0
local lRet 		:= .t.
Local nQtdGloant:= GetQtdglo(oBrwPosic, oBrwGlo)
local nDecimal 	:= PLGetDec('BD6_VLRAPR')

if __nQuant > 0
	
	nAux := round( ( nValSaldo / (nQtdProX - nQtdGloant)), nDecimal)
	
	if nAux > round(__nQuant * nAux, nDecimal)
		__nValor := nAux - round(__nQuant * nAux, nDecimal)
	else
		__nValor := round(__nQuant * nAux, nDecimal)
	endIf	
	
	if __nValor < 0 .or. __nQuant > nQtdProX
		__nValor := nBkp
		lRet := .F.
	endIf
	
endIf

return lRet

/*/{Protheus.doc} PLINGLO
Valid do campo Valor de glosa (glosa manual)
Para ajustar com as novas possibilidades de glosa
@type Static function
@author Oscar Zanin
@since 22/05/2017
@version 12
/*/
Static function PLINGLO(__nQuant)

__nQuant := 0

Return .T.

/*/{Protheus.doc} PLINCDGL
Valid do campo do código de glosa (glosa manual)
Para ajustar com as novas possibilidades de glosa
@type Static function
@author Oscar Zanin
@since 22/05/2017
@version 12
/*/
Static function PLINCDGL(bAdd, cCodGlo)
Local lRet := .T.

if empty(cGMLcodGlo) .or. cGMLcodGlo <> cCodGlo
	cGMLcodGlo := cCodGlo
	lRet := eval(bAdd,1) .AND. eval(bAdd,3)
endIf

return lRet

/*/{Protheus.doc} PLSGLVLPAG
Valid para o campo BDX_VLRPAG
Possibilitará a informação do valor à pagar na rotina de análise de glosa
@type function
@author Oscar Zanin
@since 22/05/2017
@version 12
/*/
function PLSGLVLPAG()

Local lRet := .T.

If M->BDX_VLRPAG <= M->BDX_VLRMAN
	M->BDX_VLRGLO := M->BDX_VLRMAN - M->BDX_VLRPAG
	RunTrigger(1,,,,"BDX_VLRGLO")
else
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} AtuLbl
Função para atualizar o valor dos labels de valor de glosa e saldo à pagar
@type Static function
@author Oscar Zanin
@since 22/05/2017
@version 12
/*/
Static Function AtuLbl(oSayZ)

oSayZ:Refresh()

return .T.

/*/{Protheus.doc} GetQtdglo
Verifica se já teve quantidade glosada
@type Static function
@author Oscar Zanin
@since 29/01/2018
@version 12
/*/
static function GetQtdglo(oBrwPosic, oBrwGlo)

Local nRet	:= 0
Local nI		:= 1

For nI := 1 to Len(oBrwGlo:aCols)
	If oBrwPosic:aCols[oBrwPosic:linha()][oBrwPosic:fieldPos("BD6_SEQUEN")] == oBrwglo:aCols[nI][oBrwglo:FieldPos("BDX_SEQUEN")]
		nRet += oBrwglo:aCols[nI][oBrwglo:FieldPos("BDX_QTDGLO")]
	EndIf
Next

return nRet


/*/{Protheus.doc} ACTcols20
Monta o aCols do cabeçalho da tela de análise de glosa.
Isso foi feito devido o comportamento quando havia a crítica 020 sozinho era um e
quando tinha a 020 + outra era outro.. como a 020 é a única crítica de glosa parcial,
ela ganha a prioridade no browse
@type function
@author Oscar Zanin
@since  14.03.2018
@version 1.0
/*/
static function ACTcols20(cAlias, nIdx, aHeader, aCols, aVetTrab, cChavePes, cKey, cValid, cValidZ )
local aColsAux 	:= {}
local nI		:= 0
local nTam		:= 0
local nTamHeader:= len(aHeader[1])
Local lValid := .F.
Local aArea	:= BDX->(GetArea())
Local lVal020	:= .F.
Local lValAll	:= .F.
Local nRecnoSeek	:= 0
default cValid := ".t."

dbSelectArea(cAlias)

(cAlias)->(dbSetOrder(nIdx))

if (cAlias)->(msSeek(cChavePes))
	
	nRecnoSeek :=(cAlias)->(Recno())
	
	store COLS blank cAlias to aColsAux FROM aHeader
	
	If !(empTy(cValidZ))
		while ! (cAlias)->(eof()) .and. cChavePes == &cKey
			
			if &cValidZ
				lVal020 := .T.
				aadd(aCols,aClone(aColsAux[1]))
				
				nTam++
				
				for nI := 1 to len(aHeader)
				
					cField := allTrim(aHeader[nI,2])
					
					if aHeader[nI,nTamHeader] <> 'V'
						aCols[nTam,nI] := &cField
					endIf	
					
				next
				
				aadd(aVetTrab,(cAlias)->(recno()) )
				
			endIf	
			
		(cAlias)->(dbSkip())
		endDo
	EndIf
	
	(cAlias)->(DbGoTo(nRecnoSeek))
	
	If !lValid
		restArea(aArea)
		while ! (cAlias)->(eof()) .and. cChavePes == &cKey
			
			if &cValid .AND. aScan(aVetTrab, (cAlias)->(recno())) == 0
				lValAll := .T.
				aadd(aCols,aClone(aColsAux[1]))
				
				nTam++
				
				for nI := 1 to len(aHeader)
				
					cField := allTrim(aHeader[nI,2])
					
					if aHeader[nI,nTamHeader] <> 'V'
						aCols[nTam,nI] := &cField
					endIf	
					
				next
				
				aadd(aVetTrab,(cAlias)->(recno()) )
				
			endIf	
			
		(cAlias)->(dbSkip())
		endDo
	EndIf
	
	lValid := lValAll .OR. lVal020

	if !lValid
		store COLS blank cAlias to aColsAux FROM aHeader
		aadd(aCols,aClone(aColsAux[1]))
	EndIf
else
	store COLS blank cAlias to aColsAux FROM aHeader
	aadd(aCols,aClone(aColsAux[1]))
endIf	

return


/*/{Protheus.doc} PLSGRGLREV
@description Grava/Atualiza glosas automaticas na revalorização de pagamento e pagamento e cobrança (RPG e RCP)
@author Oscar
@since 26/11/2018
@version P12
/*/
function PLSGRGLREV(aBDXSeAnGl, cChaveGui)

Local nInd := 1
Local aAreaBD6 := BD6->(getArea())
Local cCodGlo	:= ""
Local cCodPad := ""
Local cCodPro := ""
Local cSequen := ""
Local cDesPro := ""
Local lExclui := .f.

Default aBDXSeAnGl := {.T., {}}
default cChaveGui := ""

BDX->(DbSetOrder(1))
BD6->(DbsetOrder(1))

if !(empTy(aBDXSeAnGl)) .AND. ! aBDXSeAnGl[1] .AND. !(empTy(aBDXSeAnGl[2]))

	for nInd := 1 to len(aBDXSeAnGl[2])

		if ! empty(aBDXSeAnGl[2][nInd][1]) .and. aBDXSeAnGl[2][nInd][1] <> cCodGlo
			cCodGlo := aBDXSeAnGl[2][nInd][1]
			lExclui := .T.
		endIf
		
		cCodPad := aBDXSeAnGl[2][nInd][6]
		cCodPro := aBDXSeAnGl[2][nInd][7]

		if len(aBDXSeAnGl[2][nInd]) >= 8
			cSequen := aBDXSeAnGl[2][nInd][8]
		else
			cSequen := ""
		endIf
		
		if BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) + iIf( ! empty(cSequen), BD6->BD6_SEQUEN, ""  ) <> cChaveGui + cSequen
			BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
			BD6->(msSeek(xFilial('BD6') + cChaveGui + cSequen))
		endIf

		if len(aBDXSeAnGl[2][nInd]) >= 9
			cDesPro := aBDXSeAnGl[2][nInd][9]
		else
			cDesPro := BR8->(Posicione("BR8",1,xFilial("BR8")+cCodPad+cCodPro,"BR8_DESCRI"))
		endIf
		
		If lExclui .AND. BDX->(MsSeek(xfilial("BDX") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN) + cCodGlo))
			while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO) == xFilial("BDX") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN) + cCodGlo
				
				BDX->(recLock("BDX",.f.))
					BDX->(DbDelete())
				BDX->(msUnLock())
				
				BDX->(dbSkip())
			endDo
			lExclui := .F.
		EndIf
		
		BDX->(recLock("BDX",.t.))
		
			BDX->BDX_FILIAL := xFilial("BDX")
			BDX->BDX_IMGSTA := "BR_VERMELHO"

			BDX->BDX_CODOPE := BD6->BD6_CODOPE // (cAlias)->&( cAlias + "_CODOPE" )
			BDX->BDX_CODLDP := BD6->BD6_CODLDP // (cAlias)->&( cAlias + "_CODLDP" )
			BDX->BDX_CODPEG := BD6->BD6_CODPEG // (cAlias)->&( cAlias + "_CODPEG" )
			BDX->BDX_NUMERO := BD6->BD6_NUMERO // (cAlias)->&( cAlias + "_NUMERO" )
			BDX->BDX_ORIMOV := BD6->BD6_ORIMOV // cOriMov

			BDX->BDX_NIVEL  := iIf( ! empty(aBDXSeAnGl[2][nInd][1]),'1','')
			BDX->BDX_CODPAD := iIf( empty(cCodPad), BD6->BD6_CODPAD, cCodPad)
			BDX->BDX_CODPRO := iIf( empty(cCodPro), BD6->BD6_CODPRO, cCodPro)
			BDX->BDX_DESPRO := iIf( empty(cDesPro), BD6->BD6_DESPRO, cDesPro)
			BDX->BDX_SEQUEN := iIf( empty(cSequen), BD6->BD6_SEQUEN, cSequen)
			BDX->BDX_CODGLO := cCodGlo
			BDX->BDX_GLOSIS := cCodGlo
			BDX->BDX_DESGLO := aBDXSeAnGl[2][nInd][2]
			BDX->BDX_INFGLO := aBDXSeAnGl[2][nInd][3]
			
			//1=Eletronica;2=Manual;3=Automatica
			BDX->BDX_TIPGLO := '3'
			BDX->BDX_DTACAO := date()
			
			//1=Principal;2=Descritivos
			BDX->BDX_TIPREG := iIf( empty(BDX->BDX_NIVEL), '2', '1')
			
			if BDX->BDX_TIPREG == '1'
			
				BDX->BDX_PERGLO := ( BD6->BD6_VLRGLO / ( BD6->BD6_VLRMAN + BD6->BD6_VLRGLO ) ) * 100
				BDX->BDX_VLRGLO := BD6->BD6_VLRGLO
				BDX->BDX_PERGTX := ( BD6->BD6_VLRGTX / ( BD6->BD6_VLTXPG + BD6->BD6_VLRGTX ) ) * 100
				BDX->BDX_VLRGTX := BD6->BD6_VLRGTX
				BDX->BDX_VLTXPG := BD6->BD6_VLTXPG
				BDX->BDX_VLTXAP := BD6->BD6_VLTXAP
				
				BDX->BDX_RESPAL := ""

				BDX->BDX_VLRPAG := BD6->BD6_VLRPAG
				BDX->BDX_VLRMAN := BD6->BD6_VLRMAN
				BDX->BDX_VLRBPR := BD6->BD6_VLRBPR
				BDX->BDX_VLRAPR := BD6->BD6_VALORI
				BDX->BDX_QTDPRO := BD6->BD6_QTDPRO
				BDX->BDX_DATPRO := BD6->BD6_DATPRO
				
			endIf
			
			BDX->BDX_ACAO 	:= iIf( BDX->BDX_PERGLO == 100 .and. BDX->BDX_VLRGLO == 0, '2', '1' )
			BDX->BDX_ACAOTX := iIf( BDX->BDX_PERGTX == 100 .and. BDX->BDX_VLRGTX == 0, '2', '1' )
			BDX->BDX_CRIANA	:= '1'
			
			if getNewPar("MV_PLSREGL",.f.)
			
				if BDX->BDX_TIPREG == '1'
					BDX->BDX_VLRAP2 := BDX->BDX_VLRAPR
					BDX->BDX_PERGL2 := BDX->BDX_PERGLO
					BDX->BDX_VLRGL2 := BDX->BDX_VLRGLO
				endIf
				
			endIf
			
		BDX->(msUnLock())
	next
	
	aBDXSeAnGl[1] := .f.
	aBDXSeAnGl[2] := {}
	
else

	If BD6->(msSeek(xFilial('BD6') + cChaveGui))
		While !(BD6->(eoF())) .AND. xFilial('BD6') + cChaveGui == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
			If BDX->(MsSeek(xfilial("BDX") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN) + "020"))
				while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO) == xFilial("BDX") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN) + "020"
					
					BDX->(recLock("BDX",.f.))
						BDX->(DbDelete())
					BDX->(msUnLock())
		
					BDX->(dbSkip())
				endDo
			EndIf
			BD6->(Dbskip())
		EndDo
	EndIf
endIf

BD6->(restArea(aAreaBD6))

return

//--------------------------------------------------------------
/*/{Protheus.doc} PLSGLOHIS

@author    PLS TEAM
@version   V12
@since     08/12/2005
/*/
function PLSGLOHIS(cAlias)

local oDlg		:= nil
local cChave	:= ""

local aHeaderCri:= {}
local aDadosCri := {}
local aVetCri   := {}
local cCadastro := STR0096 //"Historico de Glosa"
local oSay		:= nil

local bDblCliIte	:= {||}

local oFont			:= nil

local cChavePes 	:= ""
local cKey 	  		:= "" 
local nLarg 		:= ""
local nTop 			:= ""
local nLeft			:= ""
local oMemo			:= nil
local cTexto		:= 0

local lMV_PLSREGL	:= getNewPar("MV_PLSREGL",.f.)

private cCodProSel	:= ""

cChave := (cAlias)->&( "(" + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG + " + cAlias + "_NUMERO + " + cAlias + "_ORIMOV ) " )

// Redefine variaveis estaticas.
oBrwGlo := nil

DEFINE FONT oFont NAME "Arial" size 0,-12 BOLD

BDX->(dbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO

if BDX->( msSeek( xFilial("BDX") + cChave ) )
	cCodProSel 	:= BDX->BDX_SEQUEN
else
	msgAlert("Não foram localizados glosas para esta guia.")
	return .f.
endIf

store Header "BDX" to aHeaderCri for ( allTrim(SX3->X3_CAMPO) $ "BDX_CODPAD,BDX_CODPRO,BDX_CODGLO,BDX_DESGLO,BDX_OBS,BDX_VLRGL2,BDX_PERGL2,BDX_SEQUEN,BDX_ACAO,BDX_NIVEL,BDX_GLACAO,BDX_VLRMAN,BDX_VLRGLO,BDX_ACAOTX,BDX_VLRGTX,BDX_VLTXPG,BDX_VLRREC,BDX_QTDPRO,BDX_TIPGLO,BDX_CODTPA,BDX_QTDGLO,BDX_TIPREG,BDX_VLRPAG,BDX_PERGLO,BDX_PERGTX,BDX_CRIANA,BDX_DESPRO,BDX_DATPRO,BDX_GLOSIS" )

cChavePes := xFilial("BDX") + cChave
cKey 	  := 'BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV)' 

plMontACols("BDX", 4, aHeaderCri, @aDadosCri, @aVetCri, cChavePes, cKey, "BDX->BDX_TIPREG $ '" + iIf(lMV_PLSREGL, '1,2', '1') + "' .and. ! empty(BDX->BDX_NIVEL) " )

aSize 		:= msAdvSize()
aObjects 	:= {}

aadd( aObjects, { 100, 50 , .t., .f., .f. } )
aadd( aObjects, { 100, 100, .t., .t., .f. } )
aadd( aObjects, { 100, 50 , .t., .t., .f. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] of GetWndDefault() Pixel

//Exibe criticas (itens)
nTop 				:= aPosObj[2,1] - 50
nLeft 				:= aPosObj[2,2]
nHeight				:= aPosObj[2,3]
nLarg 				:= aPosObj[2,4]

// botao fechar
@ 5, aPosObj[1,4] - 40 BUTTON "Fechar" SIZE 40, 20 PIXEL OF oDlg ACTION oDlg:end()

oBrwGlo 			:= TPLSBrw():new(nTop, nLeft, nLarg, nHeight, nil,oDlg,nil,bDblCliIte,nil,nil,nil,.t.,nil,.t.,nil,aHeaderCri,aDadosCri,.f.,"BDX",K_Visualizar,STR0097,nil,nil,nil,aVetCri,"PLVLDBDX('2')","A500VDEL()",nil,nil) //"Criticas"
oBrwGlo:bChange    	:= { || PLBDXCNG(@cTexto, oMemo, oBrwGlo) }
oBrwGlo:lAddLine   	:= .f.

//Ajusta a posiçao e tamanho do MEMO
@ aPosObj[3,1], aPosObj[3,2] say oSay PROMPT "Observação:" size 220,010 of oDlg PIXEL

//Cria o Memo
@ aPosObj[3,1] + 10, aPosObj[3,2] Get oMemo Var cTexto SIZE aPosObj[3,4] - 3, nHeight *0.50 of oDlg MULTILINE HSCROLL PIXEL READONLY

//atualiza o campo observação com o valor do BDX_OBS do primeiro item do grid 
PLBDXCNG(@cTexto, oMemo, oBrwGlo)

//permitir fechar a tela utilizando a tecla ESC
oDlg:lEscClose     := .T. 

ACTIVATE MSDIALOG oDlg CENTERED

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA500CLO ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Selecionada uma guia o sistema clona a mesma				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA500CLO(cAlias,nReg,nOpc,aFields,lMsg,lReap)

LOCAL cChaveGui:= &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO)")
LOCAL aCabec   := {cAlias,&(cAlias+"->(DbStruct())")}
LOCAL aItens   := BD6->(DbStruct())
LOCAL aSubItens:= BD7->(DbStruct())
LOCAL nH       := 0
LOCAL nI	   := 0
LOCAL nJ	   := 0
LOCAL nK	   := 0
LOCAL dDatCtbChk:= stod('')
LOCAL cNumero   := ""
LOCAL cCodOpe   := ""
LOCAL cCodLdp   := ""
LOCAL cCodPeg   := ""
LOCAL cSemGuia  := ""
LOCAL cFiltAli  := ""
LOCAL aLocClo	:= {}

PRIVATE aNewRDA	:= {}
DEFAULT aFields := nil
DEFAULT lMsg    := .T.
Default lReap := .F.

dDatCtbChk := PLRtDtCTB(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO"), .F.)

if PLVLDBLQCO(dDatCtbChk, {"PLS007"}, lMsg) //verifica se a database está no periodo contabil e se estiver não pode clonar a guia

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O compatibilizador tem que ter sido aplicado							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If &(cAlias+"->(FieldPos('"+cAlias+"_GUESTO'))") == 0
		If lMsg
			Help("",1,"PLSA500013")
		Endif
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O conteudo do parametro tem q estar na BW								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX5->(DbSetOrder(1))
	If !SX5->(MsSeek(xFilial("SX5")+"BW"+alltrim(GetNewPar("MV_PLGUIES","123"))))
		If lMsg
			Help("",1,"PLSA500026")
		Endif
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ So posso clonar se a guia estiver pronta/faturada, desbloqueada			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! &(cAlias+"->"+cAlias+"_FASE") $ "3,4" .Or. &(cAlias+"->"+cAlias+"_SITUAC") <> "1" .or. !Empty(&(cAlias+"->"+cAlias+"_GUESTO"))
	     If lMsg
	        Help("",1,"PLSA500014")
	     Endif
	     Return
	Else
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Pede confirmacao...                                                      ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If ! lMsg .Or. MsgYesNo(STR0080)       //"Deseja clonar a guia ?"
	
		if lReap
		   aLocClo :=  PtuReaLoc(cAlias)
		else 
			aLocClo := GetLocal(cAlias)
			while !aLocClo[1]
				aLocClo := GetLocal(cAlias)
			enddo
		endif	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Antes de qualquer coisa eu vou marcar os campos de controle na guia      |
		//| que vai ser clonada													 	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BD6->(MsSeek(xFilial("BD6")+cChaveGui))
			   While !BD6->(Eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == ;
			   							 xFilial("BD6")+cChaveGui
	
				   	BD6->(Reclock("BD6",.F.))
				   		BD6->BD6_TPESTO := '1'//nenhum
				    	BD6->BD6_CONCOB := '1'//sim
				    	BD6->BD6_CONPAG := '1'//sim
				    	BD6->BD6_CONMUS := '1'//sim
				    	BD6->BD6_CONMRD := '1'//sim
				   	BD6->(MsUnlock())
	
					BD7->(DbSetOrder(1))
			    	If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			    		While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
			     									xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
		
						   	BD7->(Reclock("BD7",.F.))
						   			BD7->BD7_TPESTO := '1'//nenhum
						   			BD7->BD7_CONCOB := '1'//sim
							    	BD7->BD7_CONPAG := '1'//sim
							    	BD7->BD7_CONMUS := '1'//sim
							    	BD7->BD7_CONMRD := '1'//sim
						   	BD7->(MsUnlock())
	
			     			BD7->(DbSkip())
			     		Enddo
					Endif
					BD6->(DbSkip())
				Enddo
		Endif
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ A guia a ser estornada agora esta toda dentro deste array				 ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    aGuiaOri := PlGetDadGui(cChaveGui,aCabec,aItens,aSubItens,cAlias)
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Garanto o BCI posicionado												 ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	    cCodOpe  := &(cAlias+"->"+cAlias+"_CODOPE")
	    cCodLdp  := &(cAlias+"->"+cAlias+"_CODLDP")
	    cCodPeg  := &(cAlias+"->"+cAlias+"_CODPEG")
	    cSemGuia := cCodOpe+cCodLdp+cCodPeg
		nH       := PLSAbreSem(cSemGuia+".SMF")
	    Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Garanto o BCI posicionado												 ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BCI->(DbSetOrder(1))
	    BCI->(MsSeek(xFilial("BCI")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Busco o proximo numero da guia											 ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FindFunction("TcSqlFilter()")//teoricamente sempre tem q entrar aqui
			cFiltAli := &(cAlias+"->(TcSqlFilter())")
		Else
			cFiltAli := RetFiltro(cAlias,"BCI")
		Endif
		&(cAlias+"->(DbClearFilter())")
	
		cNumero  := PLSA500NUM(cAlias,aLocClo[2],aLocClo[3],aLocClo[4])
	
	    DbSelectArea(aCabec[1])
	    Reclock(aCabec[1],.F.)
	    	&(aCabec[1]+"_GUESTO") := aLocClo[2]+aLocClo[3]+aLocClo[4]+cNumero+&(cAlias+"->"+cAlias+"_ORIMOV")
	    	&(aCabec[1]+"_ESTORI") := '1'
	    MsUnlock()
	
	    PosNewRda(aLocClo[2],aLocClo[3],aLocClo[4],aLocClo[5]) // Posiciona na nova RDA
	
	    Reclock(aCabec[1],.T.)
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Gravo o cabecalho da guia												 ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    For nI := 1 to Len(aCabec[2])
	    	cCampo  := aCabec[2][nI][1]
	    	cAliCp  := subs(cCampo,1,3)
	    	If cAliCp+"_CODOPE" == alltrim(cCampo)
	    		&cCampo := aLocClo[2]
	    	ElseIf cAliCp+"_CODLDP" == alltrim(cCampo)
	    		&cCampo := aLocClo[3]
	    	ElseIf cAliCp+"_CODPEG" == alltrim(cCampo)
	    		&cCampo := aLocClo[4]
	    	ElseIf cAliCp+"_NUMERO" == alltrim(cCampo)
	    		&cCampo := cNumero
	    	ElseIf cAliCp+"_FASE" == alltrim(cCampo)
	    		&cCampo := "1"
	    	ElseIf cAliCp+"_GUESTO" == alltrim(cCampo)
	    		&cCampo := cChaveGui
	    	ElseIf cAliCp+"_ESTORI" == alltrim(cCampo)
	    		&cCampo := '0'
			ElseIf cAliCp+"_LA" == alltrim(cCampo)
	    		&cCampo := ' '
	    	ElseIf DesField(cAliCp,cCampo)
	    		loop
	    	ElseIf ValType((xRet := TraField(cAliCp,cCampo,aCabec))) <> "U"
		    		//fiz esse tratamento pois tem alguns campos que não preenchia nessa função
		    		//um exemplo era o BD5_CODESP pois pega o aNewRDA que preenche só quando tem BAX_ESPPRI == '1'
		    		//ai no momento de analisar as divergencias da guia dava varios erros
		    		If empty(xRet) .and. !empty(aGuiaOri[1][nI])
		    			&cCampo := aGuiaOri[1][nI]
		    		Else
	    		&cCampo := xRet
		    		EndIf
		    		
	    		xRet := Nil
	    	Else
	    		&cCampo := aGuiaOri[1][nI]
	    	Endif
	    Next
	    MsUnlock()
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Vou varrer cada evento da guia											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    For nI := 1 to Len(aGuiaOri[2])
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³ Gravo o cabecalho do evento												 ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    DbSelectArea("BD6")
	    	Reclock("BD6",.T.)
		    For nK := 1 to Len(aItens)
		    	cCampo  := aItens[nK][1]
		    	cAliCp  := subs(cCampo,1,3)
		    	If cAliCp+"_CODOPE" == alltrim(cCampo)
	    			&cCampo := aLocClo[2]
		    	ElseIf cAliCp+"_CODLDP" == alltrim(cCampo)
		    		&cCampo := aLocClo[3]
		    	ElseIf cAliCp+"_CODPEG" == alltrim(cCampo)
		    		&cCampo := aLocClo[4]
		    	ElseIf cAliCp+"_NUMERO" == alltrim(cCampo)
		    		&cCampo := cNumero
		    	ElseIf cAliCp+"_FASE" == alltrim(cCampo)
	    			&cCampo := "1"
		    	ElseIf cAliCp+"_TPESTO" == alltrim(cCampo)
	    			&cCampo := "1"
	    		ElseIf cAliCp+"_GUESTO" == alltrim(cCampo)
	    			&cCampo := cChaveGui
		    	ElseIf cAliCp+"_CONCOB" == alltrim(cCampo)
		    		&cCampo := '0'
		    	ElseIf cAliCp+"_CONPAG" == alltrim(cCampo)
		    		&cCampo := '0'
		    	ElseIf cAliCp+"_CONMUS" == alltrim(cCampo)
		    		&cCampo := '0'
		    	ElseIf cAliCp+"_CONMRD" == alltrim(cCampo)
		    		&cCampo := '0'
				ElseIf cAliCp+"_LAPRO" == alltrim(cCampo)
		    		&cCampo := ''
				ElseIf cAliCp+"_LA" == alltrim(cCampo)
		    		&cCampo := ''
				ElseIf cAliCp+"_DTPRO" == alltrim(cCampo)
		    		&cCampo := CTOD('  /  /  ')
		       	ElseIf DesField(cAliCp,cCampo)
		    		loop
		    	ElseIf ValType((xRet := TraField(cAliCp,cCampo,aCabec))) <> "U"
			    		//fiz esse tratamento pois tem alguns campos que não preenchia nessa função
		    			//um exemplo era o BD5_CODESP pois pega o aNewRDA que preenche só quando tem BAX_ESPPRI == '1'
			    		//ai no momento de analisar as divergencias da guia dava varios erros
			    		If empty(xRet) .and. !empty(aGuiaOri[2][nI][1][nK] )
			    			&cCampo := aGuiaOri[2][nI][1][nK] 
			    		Else
		    		&cCampo := xRet
			    		EndIf
			    		
		    		xRet := Nil
		    	Else
		    		&cCampo := aGuiaOri[2][nI][1][nK]
		    	Endif
	    	Next
		    MsUnlock()
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³ Vou gravar cada unidade deste evento									 ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    	For nJ := 1 to Len(aGuiaOri[2][nI][2])
	    		DbSelectArea("BD7")
	    		Reclock("BD7",.T.)
	    		For nK := 1 to Len(aSubItens)
				   cCampo  := aSubItens[nK][1]
				   cAliCp  := subs(cCampo,1,3)
		    	   If cAliCp+"_CODOPE" == alltrim(cCampo)
			    		&cCampo := aLocClo[2]
			       ElseIf cAliCp+"_CODLDP" == alltrim(cCampo)
			    		&cCampo := aLocClo[3]
			       ElseIf cAliCp+"_CODPEG" == alltrim(cCampo)
			    		&cCampo := aLocClo[4]
			       ElseIf cAliCp+"_NUMERO" == alltrim(cCampo)
				   		&cCampo := cNumero
				   ElseIf cAliCp+"_FASE" == alltrim(cCampo)
	    				&cCampo := "1"
				   ElseIf cAliCp+"_GUESTO" == alltrim(cCampo)
	    				&cCampo := cChaveGui
				   ElseIf cAliCp+"_TPESTO" == alltrim(cCampo)
	    				&cCampo := "1"
				   ElseIf cAliCp+"_CONCOB" == alltrim(cCampo)
			    		&cCampo := '0'
			       ElseIf cAliCp+"_CONPAG" == alltrim(cCampo)
			    		&cCampo := '0'
			       ElseIf cAliCp+"_CONMUS" == alltrim(cCampo)
			    		&cCampo := '0'
			       ElseIf cAliCp+"_CONMRD" == alltrim(cCampo)
			    		&cCampo := '0'
			       ElseIf cAliCp+"_CODRDA" == alltrim(cCampo)
			    		&cCampo := aGuiaOri[2][nI][2][nJ][nK]
			       ElseIf cAliCp+"_NOMRDA" == alltrim(cCampo)
			    		&cCampo := aGuiaOri[2][nI][2][nJ][nK]
			       ElseIf cAliCp+"_LA" == alltrim(cCampo)
			       		&cCampo :=" "
			       ElseIf cAliCp+"_LAPRV" == alltrim(cCampo)
			       		&cCampo :=" "
			       ElseIf cAliCp+"_LAREV" == alltrim(cCampo)
			       		&cCampo :=" "
			       ElseIf cAliCp+"_DTPRV" == alltrim(cCampo)
			       		&cCampo :=Ctod("  /  /  ")
			       ElseIf cAliCp+"_DTREV" == alltrim(cCampo)
			       		&cCampo :=Ctod("  /  /  ")
		           ElseIf cAliCp+"_DTPRO" == alltrim(cCampo)
			       		&cCampo :=Ctod("  /  /  ")
			       ElseIf cAliCp+"_COMPCT" == alltrim(cCampo)
			       		&cCampo :="    "
	  		       ElseIf cAliCp+"_VLPRV" == alltrim(cCampo)
			       		&cCampo :=0
			       ElseIf DesField(cAliCp,cCampo)
				   		loop
				   ElseIf ValType((xRet := TraField(cAliCp,cCampo,aCabec))) <> "U"
							//fiz esse tratamento pois tem alguns campos que não preenchia nessa função
		    				//um exemplo era o BD5_CODESP pois pega o aNewRDA que preenche só quando tem BAX_ESPPRI == '1'
		    				//ai no momento de analisar as divergencias da guia dava varios erros
		    				If empty(xRet) .and. !empty(aGuiaOri[2][nI][2][nJ][nK])
		    					&cCampo := aGuiaOri[2][nI][2][nJ][nK] 
		    				Else
						&cCampo := xRet
							EndIf
							
						xRet := Nil
				   Else
				   		&cCampo := aGuiaOri[2][nI][2][nJ][nK]
				   Endif
			    Next
			    MsUnlock()
	    	Next
	    Next
	    End Transaction
		PLSFechaSem(nH,cSemGuia+".SMF")
		&(cAlias+"->(MsSeek('"+xFilial(cAlias)+cChaveGui+"'))")//depois da clonagem eu deixo posicionado na guia origem
		If !Empty(cFiltAli)
			DbSelectArea(cAlias)
			DbSetFilter({||&cFiltAli},cFiltAli)
		Endif
		If lMsg
			//-------------------------------------------------------------------
			//  LGPD
			//-------------------------------------------------------------------
			objCENFUNLGP:useLogUser()
			MsgInfo(STR0081+"     " +Chr(13)+Chr(10)+  STR0253+aLocClo[2]+'.'+aLocClo[3]+'.'+aLocClo[4]+'.'+cNumero+"]") //"Clonagem de guia concluida com sucesso !!!" //"Chave da guia clonada ["
		Endif
	   Endif
	Endif

EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA500EXC ³ Autor ³ Daher		        | Data ³ 08.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Vou excluir a guia clonada								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA500EXC(cAlias,nReg,nOpc,aFields,lMsg)
LOCAL cChaveGui := &(cAlias+"->("+cAlias+"_CODOPE+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV)")
LOCAL cChaveAtu := "" //chave do clone
LOCAL cChaveOri := ""//chave da guia origem
LOCAL aArea		:= GetArea()
LOCAL dDatCtbChk := PLRtDtCTB(&(cAlias+"->"+cAlias+"_CODOPE"), &(cAlias+"->"+cAlias+"_CODLDP"), &(cAlias+"->"+cAlias+"_CODPEG"), &(cAlias+"->"+cAlias+"_NUMERO"), .F.)

DEFAULT lMsg    := .T.

if PLVLDBLQCO(dDatCtbChk, {"PLS011"}, lMsg) //verifica se a database está no periodo contabil e se estiver não pode excluir a guia
	If &(cAlias+"->(FieldPos('"+cAlias+"_GUESTO'))") == 0
		If lMsg
	 		Help("",1,"PLSA500028")
		Endif
		Restarea(aArea)
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Com essa critica eu garanto a integridade								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Empty(&(cAlias+"->"+cAlias+"_GUESTO"))
		If lMsg
			Help("",1,"PLSA500019")
		Endif
		Restarea(aArea)
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico aonde o usuario esta posicionado								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If &(cAlias+"->"+cAlias+"_ESTORI") == '0'//estou posicionado no clone
	    	cChaveAtu := cChaveGui //chave do clone
	    	cChaveOri := alltrim(&(cAlias+"->"+cAlias+"_GUESTO"))//chave da guia origem
	Else
	    	cChaveAtu := alltrim(&(cAlias+"->"+cAlias+"_GUESTO"))       //chave do clone
	    	cChaveOri := cChaveGui//chave da guia origem
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciono no clone														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("TcSqlFilter()")//teoricamente sempre tem q entrar aqui
		cFiltAli := &(cAlias+"->(TcSqlFilter())")
	Else
		cFiltAli := RetFiltro(cAlias,"BCI")
	Endif
	&(cAlias+"->(DbClearFilter())")
	
	DbSelectArea(cAlias)
	DbSetOrder(1)
	MsSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Com essa critica eu garanto a integridade								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If &(cAlias+"_FASE") <> '1'
		If lMsg
			Help("",1,"PLSA500020")
		Endif
		If !Empty(cFiltAli)
			DbSelectArea(cAlias)
			DbSetFilter({||&cFiltAli},cFiltAli)
		Endif
		Restarea(aArea)
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ja foi analisada a divergencia entre as duas guias nao se pode excluir³
	//| o clone																	 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(&(cAlias+"->"+cAlias+"_SEQEST"))
		If lMsg
			Help("",1,"PLSA500021")
		Endif
		If !Empty(cFiltAli)
			DbSelectArea(cAlias)
			DbSetFilter({||&cFiltAli},cFiltAli)
		Endif
		Restarea(aArea)
		Return
	Endif
	If lMsg .and. !MsgYesNo(STR0112) //"Deseja realmente excluir a guia?"
		If !Empty(cFiltAli)
			DbSelectArea(cAlias)
			DbSetFilter({||&cFiltAli},cFiltAli)
		Endif
		Restarea(aArea)
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da transacao													     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpo os campos da guia origem											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MsSeek(xFilial(cAlias)+subs(cChaveOri,1,24))
		Reclock(cAlias,.F.)
			&(cAlias+"_GUESTO") := ''
			&(cAlias+"_ESTORI") := ''
		MsUnlock()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpo os campos do BD6 da guia origem									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BD6->(DbSetOrder(1))
	If BD6->(MsSeek(xFilial("BD6")+cChaveOri))
		While !BD6->(Eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
			   							 xFilial("BD6")+cChaveOri
					BD7->(DbSetOrder(1))
			    	If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			    		While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
			     									xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
	
				            BD7->(Reclock("BD7",.F.))
								BD7->BD7_TPESTO := '1'
								BD7->BD7_CONCOB := '1'
								BD7->BD7_CONPAG := '1'
							BD7->(MsUnlock())
	
			     			BD7->(DbSkip())
			     		Enddo
					Endif
	
					BD6->(Reclock("BD6",.F.))
						BD6->BD6_TPESTO := '1'
						BD6->BD6_CONCOB := '1'
						BD6->BD6_CONPAG := '1'
					BD6->(MsUnlock())
	
					BD6->(DbSkip())
		Enddo
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciono no clone														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias)
	DbSetOrder(1)
	MsSeek(xFilial(cAlias)+subs(cChaveAtu,1,24))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpo os BD6 do clone													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BD6->(DbSetOrder(1))
	If BD6->(MsSeek(xFilial("BD6")+cChaveAtu))
		While !BD6->(Eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
			   							 xFilial("BD6")+cChaveAtu
					BD7->(DbSetOrder(1))
			    	If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			    		While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
			     									xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
	
				            BD7->(Reclock("BD7",.F.))
							BD7->(DbDelete())
							BD7->(MsUnlock())
	
			     			BD7->(DbSkip())
			     		Enddo
					Endif
	
					BD6->(Reclock("BD6",.F.))
					BD6->(DbDelete())
					BD6->(MsUnlock())
	
					BD6->(DbSkip())
		Enddo
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleto o clone															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reclock(cAlias,.F.)
		DbDelete()
	MsUnlock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Final da transacao													     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	End Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciono na guia origem												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias)
	DbSetOrder(1)
	MsSeek(xFilial(cAlias)+subs(cChaveOri,1,24))
	If !Empty(cFiltAli)
		DbSelectArea(cAlias)
		DbSetFilter({||&cFiltAli},cFiltAli)
	Endif
	If lMsg
		MsgInfo(STR0113) //"Exclusão concluida com sucesso !!!"
	Endif
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS500B6S
Verifica se o procedimento já foi processado no PTU A520, caso já foi não é permitida a exclusão.

@author Lucas Nonato
@since  21/05/2019
/*/
//-------------------------------------------------------------------
function PLS500B6S()
local cSql as char
local lRet as logical

BD6->(dbgoto(oBrwBD6:aVetTrab[oBrwBD6:linha()]))

cSql := "SELECT 1 FROM " + RetSqlName("B6S") + " B6S "
cSql += " WHERE B6S_FILIAL = '" + xFilial("B6S") + "' "
cSql += " AND B6S_CODOPE = '" + BD6->BD6_CODOPE + "' "
cSql += " AND B6S_CODLDP = '" + BD6->BD6_CODLDP + "' "
cSql += " AND B6S_CODPEG = '" + BD6->BD6_CODPEG + "' "
cSql += " AND B6S_NUMERO = '" + BD6->BD6_NUMERO + "' "
cSql += " AND B6S_SEQUEN = '" + BD6->BD6_SEQUEN + "' "
cSql += " AND B6S.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)

if PLEXC->(eof())
	lRet := .t.
else
	lRet := .f.
	Aviso( "Deletar",; 
	"Não é permitido excluir eventos que já foram avisados para a Unimed Origem pelo PTU A520.",; //
	{ "Ok" }, 2 )
endif

PLEXC->(dbclosearea())

return lRet

//--------------------------------------------------------------
/*/{Protheus.doc} PLSA500PRC

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
function PLSA500PRC(lMsg)
default lMsg := .t.

if cvaltochar(lMsg) <> ".F."
	lMsg := .T.
endif

if !lMsg
	PLSA500RFS(_cAlias)
	PLSA500FAS(_cAlias,,,.t.)
elseif msgYesNo("Confirma o processamento da guia?") 
	PLSA500RFS(_cAlias)
    PLSA500FAS(_cAlias,,,.t.)

	//u_PLSSMFila()
endif

return

//--------------------------------------------------------------
/*/{Protheus.doc} isAltRep

@author    Lucas Nonato
@version   V12
@since     07/08/2019
/*/
static function isAltRep(aCmpAlt)
local nX 	as numeric
local cSql	as char
local lRet  as logical

lRet := .f.

cSql := " SELECT * FROM " + RetSqlName("BCM") + " BCM "
cSql += " WHERE BCM_FILIAL = '" + xFilial("BCM") + "' "
cSql += " AND BCM_CODOPE = '" + BCI->BCI_CODOPE + "' " 
cSql += " AND BCM_TIPGUI = '" + BCI->BCI_TIPGUI + "' " 
cSql += " AND BCM_ALIAS = '" + _cAlias + "' " 
cSql += " AND BCM_ALTREP = 'T' "
cSql += " AND ( "	

for nX := 1 to len(aCmpAlt)
	if nX > 1 
		cSql += " OR "	
	endif
	cSql += " BCM_ALIAS = '" + aCmpAlt[nX] + "' " 
next
cSql += " ) AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPALTREP",.F.,.T.)
if TMPALTREP->(!eof())
	lRet := .t.
endif
TMPALTREP->(dbclosearea())

return lRet

//--------------------------------------------------------------
/*/{Protheus.doc} PLSA500ERC
Cria tela de consulta de erro controlado
@author    Lucas Nonato
@version   V12
@since     21/10/2019
/*/
function PLSA500ERC()
local cSql 		as char
local cCodPro	as char
local cAlias 	:= PlRetAlias(BCI->BCI_CODOPE,BCI->BCI_TIPGUI)
local aCrit 	:= {}

//B6A_FILIAL+B6A_CODOPE+B6A_CODLDP+B6A_CODPEG+B6A_NUMERO+B6A_SEQUEN+B6A_CODUNM+B6A_CODCRI+B6A_DESCRI                                                              
cSql := " SELECT B6A_CODCRI, B6A_DESCRI, B6A_SEQUEN, B6A_CODPAD, B6A_CODPRO, B6A_CODUNM FROM " + RetSqlName("B6A") + " B6A "
//cSql += " WHERE B6A_FILIAL = '" + xFilial("B6A") + "' "
//cSql += " AND B6A_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += " WHERE B6A_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += " AND B6A_CODPEG = '" + BCI->BCI_CODPEG + "' "
cSql += " AND B6A_NUMERO = '" + (cAlias)->&(cAlias+"_NUMERO") + "' "
cSql += " AND B6A.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbERC",.F.,.T.)

while !TrbERC->(eof())
	cCodPro := iif(!empty(TrbERC->B6A_CODPAD),TrbERC->B6A_CODPAD+"-"+TrbERC->B6A_CODPRO, "")
	aadd(aCrit, {TrbERC->B6A_CODCRI, TrbERC->B6A_DESCRI, TrbERC->B6A_SEQUEN, cCodPro, TrbERC->B6A_CODUNM})
	TrbERC->(dbskip())
enddo

if len(aCrit) > 0
	PLSCRIGEN(aCrit,{{"Codigo","@!",3},{"Descrição","@!",100},{"Sequencia","@!",3},{"Procedimento","@!",25},{"Unidade","@!",3}},"Log de geração",nil,nil)
else
	msgInfo("Guia não possui criticas de erro controlado.")
endif

TrbERC->(dbclosearea())

return

//--------------------------------------------------------------
/*/{Protheus.doc} PLSRETEVQT
Quantidade de eventos da guia na fila
@author    Lucas Nonato
@version   V12
@since     21/10/2019
/*/
function PLSRETEVQT()
local cSql 		:= ""
local cAlias 	:= PlRetAlias(BCI->BCI_CODOPE,BCI->BCI_TIPGUI)
Local cTabEve	:= "TABEVE"+cEmpAnt

if cAlias == "BD5"
	cSql := "SELECT COUNT(*) QTD FROM " + cTabEve + " WHERE CODPEG = '"+BCI->BCI_CODPEG+"' AND NUMGUI = '"+BD5->BD5_NUMERO+"' AND STATUS <> '3'"
else
	cSql := "SELECT COUNT(*) QTD FROM " + cTabEve + " WHERE CODPEG = '"+BCI->BCI_CODPEG+"' AND NUMGUI = '"+BE4->BE4_NUMERO+"' AND STATUS <> '3'"
endif
dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"QTDFILA",.f.,.t.)
nQtd := QTDFILA->QTD
QTDFILA->(dbclosearea())

if nQtd == 0
	msginfo("Os eventos desta guia ainda não foram adicionados na Fila de processamento. Verifique o funcionamento do Robô.")
else
	msginfo("Restam " + cvaltochar(nQtd) + " evento(s) na Fila de processamento.")
endif

return

//--------------------------------------------------------------
/*/{Protheus.doc} PLSNOFIELD
alerta quando não há campos para serem exibidos (BCM_ANALIC) na tela de análise de contas
@author    Pablo Alipio
@version   V12
@since     01/2020
/*/
function PLSNOFIELD()

	msgAlert("Não há campos para exibir na tela de análise de contas (BCM_ANALIC)", STR0290)

return

//Função para posicionar uma guia quando vier das pesquisas F9,F10 e F11
//Como isso está no bloco do OnChange, só deve executar uma vez, na abertura do browse
//Isso ficou desse jeito pq aparentemente o activate da classe tem um goTop, ou equivalente
//daí colocar essa condição antes do activate não tem efeito
static function PL500F9POS(lPos, oBrw, nPos)
If lPos
	oBrw:goTo(nPos)
endIf
lPos := .F.
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} Pl500NwAud
Auditorias realizadas na própria guia e sua liberação
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
function Pl500NwAud(cChaveGui, cTipGuia, lAuto)
local aDados 	:= {}
Local aGetRotBkp := aRotina
local aAreBD6	:= BD6->(getarea())
local aCmpQry 	:= { {"BD5_FILIAL ='", "BD5_OPEMOV ='", "BD5_ANOAUT ='", "BD5_MESAUT ='", "BD5_NUMAUT ='"}, ;
		    	   	 {"BE4_FILIAL ='", "BE4_CODOPE ='", "BE4_ANOINT ='", "BE4_MESINT ='", "BE4_NUMINT ='"} } 
local cAlias 	:= Alias() 
local cChavLib	:= ""
local cGuiInt	:= (cAlias)->&( cAlias + "_GUIINT")
local cSql 		:= ""
local cSql2 	:= ""
local cSqlJnt	:= ""
local cParecAud := " - "
local cCodOpeL 	:= "" 		
local cCodLdpL 	:= ""
local cCodPegL 	:= ""
local cNumeroL 	:= ""
local cOriMovL 	:= ""
local cGuiRelc	:= ""
local cFil		:= ""
LOCAL lExiDUT   := BRW->(FieldPos("BRW_TABDUT")) > 0 .And. BRW->(FieldPos("BRW_CODDUT")) > 0
local nLocQry 	:= iif(cAlias == "BE4", 2, 1)
local oGetMemo	:= nil
default lAuto	:= .f.

//Achar liberação, se houver
BD6->(dbsetorder(1))
BD6->( msSeek( xFilial("BD6") + cChaveGui ) )
plGetLib(cTipGuia, @cChavLib)

RestArea(aAreBD6)

if !empty(cChavLib)
	cSql := " SELECT " + cAlias+"_CODOPE CODOPE, " + cAlias+"_CODLDP CODLDP, " + cAlias+"_CODPEG CODPEG, " + cAlias+"_NUMERO NUMERO, "
	cSql += 	cAlias+"_ORIMOV ORIMOV, " + cAlias+"_TIPGUI TIPGUI "
	cSql += "   FROM " + RetSQLName(cAlias) 
	cSQL += " 	WHERE " + aCmpQry[nLocQry,1] + xFilial("BD5") + "' AND " + aCmpQry[nLocQry,2] + substr(cChavLib, 1, 4) + "' "
	cSql += "     AND " + aCmpQry[nLocQry,3] + substr(cChavLib, 5, 4) + "' AND " + aCmpQry[nLocQry,4] + substr(cChavLib, 9, 2) + "' "
	cSql += "     AND " + aCmpQry[nLocQry,5] + substr(cChavLib, 11, 8) + "' AND D_E_L_E_T_ = ' ' "
endif 

if !empty(cGuiInt)
	cSql2 := " SELECT INT.BE4_CODOPE CODOPE, INT.BE4_CODLDP CODLDP, INT.BE4_CODPEG CODPEG, INT.BE4_NUMERO NUMERO, INT.BE4_ORIMOV ORIMOV, INT.BE4_TIPGUI TIPGUI "
	cSql2 += "   FROM " + RetSQLName("BE4") + " INT "
	cSQL2 += " 	WHERE INT.BE4_FILIAL = '" + xFilial("BE4") + "' AND INT.BE4_CODOPE = '" + substr(cGuiInt, 1, 4) + "' "
	cSql2 += "    AND INT.BE4_CODLDP = '" + substr(cGuiInt, 5, 4) + "' AND INT.BE4_CODPEG = '" + substr(cGuiInt, 9, 8) + "' "
	cSql2 += "    AND INT.BE4_NUMERO = '" + substr(cGuiInt, 17, 8) + "' AND INT.D_E_L_E_T_ = ' ' "
endif 

if !empty(cSql) .and. !empty(cSql2)
	cSqlJnt := cSql + " UNION " + cSql2
else
	cSqlJnt := iif(!empty(cSql), cSql, cSql2)
endif	

if !empty(cSqlJnt)
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(cSqlJnt)),"TRBLIBG",.f.,.t.)
	while ! TRBLIBG->(eof()) 
		cCodOpeL += alltrim( iif( !(TRBLIBG->CODOPE $ cCodOpeL), TRBLIBG->CODOPE + "|", '' ) )
		cCodLdpL += alltrim( iif( !(TRBLIBG->CODLDP $ cCodLdpL), TRBLIBG->CODLDP + "|", '' ) )
		cCodPegL += alltrim( iif( !(TRBLIBG->CODPEG $ cCodPegL), TRBLIBG->CODPEG + "|", '' ) )
		cNumeroL += alltrim( iif( !(TRBLIBG->NUMERO $ cNumeroL), TRBLIBG->NUMERO + "|", '' ) )
		cOriMovL += alltrim( iif( !(TRBLIBG->ORIMOV $ cOriMovL), TRBLIBG->ORIMOV + "|", '' ) )
		TRBLIBG->(dbSkip())
	enddo
	TRBLIBG->(dbCloseArea())

	cCodOpeL := substr(cCodOpeL, 1, len(cCodOpeL)-1) 		
	cCodLdpL := substr(cCodLdpL, 1, len(cCodLdpL)-1)
	cCodPegL := substr(cCodPegL, 1, len(cCodPegL)-1)
	cNumeroL := substr(cNumeroL, 1, len(cNumeroL)-1)
	cOriMovL := substr(cOriMovL, 1, len(cOriMovL)-1)
endif

cGuiRelc := cGuiRelAud(cChavLib, cTipGuia)

cFil := "@(B53_FILIAL = '" + xFilial('B53') + "' .and. " + ;
		" B53_CODOPE IN " + formatIn( ( cAlias )->&( cAlias + "_CODOPE" ) + iif(!empty(cCodOpeL), + "|" + cCodOpeL,""), "|") + " .and. " + ;
		" B53_CODPEG IN " + formatIn( ( cAlias )->&( cAlias + "_CODPEG" ) + iif(!empty(cCodPegL), + "|" + cCodPegL,""), "|") + " .and. " + ;
		" B53_NUMERO IN " + formatIn( ( cAlias )->&( cAlias + "_NUMERO" ) + iif(!empty(cNUMEROL), + "|" + cNUMEROL,""), "|") + " .and. " + ;
		" B53_ORIMOV IN " + formatIn( ( cAlias )->&( cAlias + "_ORIMOV" ) + iif(!empty(cOriMovL), + "|" + cOriMovL,""), "|") 
		if !empty(cGuiRelc)
			cFil +=	" .or. B53_NUMGUI IN " + formatIn( cGuiRelc, "|") 
		endif
		cFil +=	") "

cFil := strtran(cFil, '.', '') 
aRotina:={}

oPrinWnd := FWDialogModal():New()
oPrinWnd:SetBackground(.t.)
oPrinWnd:SetTitle('Registros de Auditoria')
oPrinWnd:SetFreeArea(600,280)
oPrinWnd:EnableFormBar(.f.)
oPrinWnd:SetEscClose(.t.)
oPrinWnd:CreateDialog()

oPainel := oPrinWnd:getPanelMain()

oFwCamada := FwLayer():New()
oFwCamada:init(oPainel,.F.) 
oFwCamada:AddLine( "LINSUP",50, .F.)
oFwCamada:AddLine( "LININF",50, .F.)
oFwCamada:AddCollumn( 'COLESQ', 70, .T., 'LININF' )
oFwCamada:AddCollumn( 'COLDIR', 30, .T., 'LININF' )

oLINSUP  := oFwCamada:GetLinePanel("LINSUP")
oLININFR := oFwCamada:GetColPanel( 'COLDIR', 'LININF' )
oLININFL := oFwCamada:GetColPanel( 'COLESQ', 'LININF' )

oGetMemo := tMultiget():new(005,005,{ |u| if( pCount() > 0, cParecAud := u, cParecAud )},oLININFR,173,133,,,,,,.T.,nil,nil,{||},nil,nil,.T.,{||},nil,nil,.t.,.t.)

oGridB53 := FWmBrowse():New()
oGridB53:setOwner(oLINSUP)
oGridB53:setProfileID('0')
oGridB53:setAlias("B53") 
oGridB53:setDescription('Guias Auditadas')
oGridB53:disableDetails()  
oGridB53:SetMenuDef('') 
oGridB53:disableReport()  
if lExiDUT
	oGridB53:AddButton("DUT", { || PL790DUT(B72->B72_CODPAD, B72->B72_CODPRO) })     
endif          
oGridB53:setFilterDefault(cFil)
if !lAuto
	oGridB53:activate()
endif
oGridB53:SetChange({|| PLRETOBSAUD(@cParecAud, oGetMemo, oGridB72, lAuto)})

//Grid da tabela de Procedimentos - B72															 
oGridB72 := FWmBrowse():New()
oGridB72:setOwner(oLININFL)
oGridB72:setProfileID('1')
oGridB72:setAlias("B72")
oGridB72:setDescription('Parecer')
oGridB72:SetMenuDef('') 
oGridB72:disableDetails()  
oGridB72:forceQuitButton()
oGridB72:disableReport()  

aadd(aDados, {"Data do Movimento", {|| B72->B72_DATMOV} })   
aadd(aDados, {"Auditor", {|| USRRETNAME(B72->B72_OPERAD)} }) 
aadd(aDados, {"Parecer", {|| RETCBOX("B72_PARECE",B72->B72_PARECE)} })  
aadd(aDados, {"Ação", {|| RETCBOX("B72_ACOTOD",B72->B72_ACOTOD)} })  
aadd(aDados, {"Cód. Tabela", {|| B72->B72_CODPAD} })  
aadd(aDados, {"Cód. Procedimento", {|| B72->B72_CODPRO} })  
aadd(aDados, {"Descrição", {|| PadR(Posicione("BR8",1,xFilial("BR8")+B72->(B72_CODPAD+B72_CODPRO),"BR8_DESCRI"),80)} }) 
aadd(aDados, {"Descrição Glosa", {|| B72->B72_CODGLO + " - " + Posicione("BCT",1,xFilial("BCT")+B53->B53_CODOPE+B72->B72_CODGLO,"BCT_DESCRI")} })  
aadd(aDados, {"Motivo", {|| B72->B72_MOTIVO + " - " + Posicione("SX5",1, xFilial("SX5") + "BU" + B72->B72_MOTIVO,"X5DESCRI()")} })  
aadd(aDados, {"Valor Autorizado", {|| B72->B72_VLRAUT} })
aadd(aDados, {"Qtd. Autorizada", {|| B72->B72_QTDAUT} })
aadd(aDados, {"Observações", {|| B72->B72_OBSANA}})
if lExiDUT
	aadd(aDados, {"Código DUT", {|| CampDutBRW(lAuto, lExiDUT, "1") }})
	Aadd(aDados, {"DUT Subitem ", {|| CampDutBRW(lAuto, lExiDUT, "2") }})
endif

oGridB72:setFields(aDados)
oGridB72:SetOnlyFields( { 'B72_OBSANA'} )
							
OGridRelac := FWBrwRelation():new()       
OGridRelac:addRelation( oGridB53, oGridB72, { { 'B72_FILIAL', 'xFilial( "B72" )' } , ;
								{ 'B72_ALIMOV', 'B53_ALIMOV' }        , ;
								{ 'B72_RECMOV', 'B53_RECMOV' } }  )	
OGridRelac:Activate()								   
if !lAuto		
	oGridB72:activate()
endif
oGridB72:SetChange({||PLRETOBSAUD(@cParecAud, oGetMemo, oGridB72, lAuto)})

PLRETOBSAUD(@cParecAud, oGetMemo, oGridB72, lAuto)
													
if !lAuto
	oPrinWnd:Activate() 
endif
aRotina := aGetRotBkp
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLRETOBSAUD
Atualiza campo da observação do auditor
@since 07/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function PLRETOBSAUD(cParecAud, oObj, oGet, lAuto)
if oGet:logiclen() > 0
	cParecAud := upper(B72->B72_OBSANA)
	iif( !lAuto, oObj:Refresh(), "")
endIf
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} CampDutBRW
Carregar os campos do DUT, caso existam na base
@since 07/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function CampDutBRW(lAuto, lExiDUT, cTipCmp)
if lExiDUT
	BRW->(DbSetOrder(1))//BRW_FILIAL+BRW_CODROL
	if BRW->(MsSeek(xFilial("BRW")+B72->B72_CODPRO)) .And. !Empty(BRW->BRW_TABDUT) .And. !Empty(BRW->BRW_CODDUT)
		cDutInf := BRW->BRW_CODDUT
		cSubDut := BRW->BRW_DUTSUB
	endif
endif
return iif( cTipCmp == "1", BRW->BRW_CODDUT, BRW->BRW_DUTSUB )


//-------------------------------------------------------------------
/*/ {Protheus.doc} cGuiRelAud
Guias relacionadas a auditoria
@since 07/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function cGuiRelAud(cChavLib, cTipGuia)
local cSql := ""
local cGuias := ""
local cChavGuia := iif( !(cTipGuia $ G_RES_INTER + '|' + G_HONORARIO), BD5->(BD5_CODOPE + BD5_ANOAUT + BD5_MESAUT + BD5_NUMAUT), "")

if !empty(cChavLib)
	cSql += " SELECT B4A.B4A_OPEMOV CODOPE, B4A.B4A_ANOAUT ANOAUT, B4A.B4A_MESAUT MESAUT, B4A.B4A_NUMAUT NUMAUT "
	cSql += "   FROM " + retSqlName('B4A') + " B4A "
	cSql += "   WHERE B4A.B4A_FILIAL = '" + xFilial('B4A') + "' AND B4A.B4A_GUIREF = '" + cChavLib + "' "
	if (!empty(cChavGuia))
		cSql += " OR B4A.B4A_GUIREF = '" + cChavGuia + "' "	
	endif	
	cSql += "    AND B4A.D_E_L_E_T_ = ' ' "
	
	if cTipGuia $ G_RES_INTER + '|' + G_HONORARIO
		cSql += " UNION ALL "
		
		cSql += " SELECT B4Q.B4Q_OPEMOV CODOPE, B4Q.B4Q_ANOAUT ANOAUT, B4Q.B4Q_MESAUT MESAUT, B4Q.B4Q_NUMAUT NUMAUT "
		cSql += "   FROM " + retSqlName('B4Q') + " B4Q "		
		cSql += " WHERE B4Q.B4Q_FILIAL = '" + xFilial('B4Q') + "' AND B4Q.B4Q_GUIREF = '" + cChavLib + "' "
		cSql += "   AND B4Q.D_E_L_E_T_ = ' ' "			
	endIf	

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(cSql)),"TABRELAUD",.f.,.t.)

	while ! TABRELAUD->(eof()) 
		cGuias += alltrim( iif( !(TABRELAUD->(CODOPE + ANOAUT + MESAUT + NUMAUT) $ cGuias), TABRELAUD->(CODOPE + ANOAUT + MESAUT + NUMAUT) + "|", '' ) ) 
		TABRELAUD->(dbskip())
	enddo
	TABRELAUD->(dbCloseArea())

	cGuias := substr(cGuias, 1, len(cGuias)-1)
endif
return cGuias


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlGuiRcGl3
Verifica se a guia de recurso de glosa foi gerada pela Análise do Recurso de Glosa (PLSRECGLO3). Se sim, não pode retornar a fase e fazer alterações 
@since 06/2021
@version P12 
/*/
//-------------------------------------------------------------------
static function PlGuiRcGl3(cCodLDP, cCodPEG, cNumero)
local cSql		:= ""
local lGlo3 	:= .f.

cSql := " SELECT B4D.B4D_DCDDLP CODLDP, B4D.B4D_DCDPEG CODPEG, B4D.B4D_DNUMER NUMERO, B4D.B4D_OBJREC TIPO"
cSql += "   FROM " + retSqlName('B4D') + " B4D "
cSql += "   WHERE B4D.B4D_FILIAL = '" + xFilial('B4D') + "' "
cSql += "     AND B4D.B4D_DCDDLP = '" + cCodLDP + "' "
cSql += "     AND B4D.B4D_DCDPEG = '" + cCodPEG + "' "
cSql += "     AND B4D.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(cSql)),"RCGLO3",.f.,.t.)

if RCGLO3->(eof()) 
	lGlo3 := .t.
elseif !RCGLO3->TIPO == "1" //PEG totalmente glosada
	lGlo3 := .t.
	while !RCGLO3->(eof()) 
		if RCGLO3->NUMERO == cNumero
			lGlo3 := .f.
			exit
		endif
		RCGLO3->(dbSkip())
	enddo	
endif
RCGLO3->(dbCloseArea())

return lGlo3

//-------------------------------------------------------------------
/*/ {Protheus.doc} PlsTelRecGlo
Chamada para telemetria da quantidade de ação (glosar e reconsiderar) por tipo de glosa
Atenção:
1) Para a métrica funcionar com a classe FwMetrics, a lib deve estar na versão igual ou maior que 20200727;
2) Além de verificar a versão da Lib, existe o parâmetro "secreto" MV_PHBMETR, que vai ficar ativo como default. Caso ocorra lentidão em 
algum cliente em produção - visto que até 05/2021, nenhum cliente da base tem os requisitos para rodar a métrica e testar em produção - basta
citar a criação deste parâmetro (Métrica PLS Ativa? 0 - Não / 1 - Sim) e colocar o valor como "0" (desligado).
3) No futuro, vamos usar o FwCustomMetrics, mas demanda lib superior e outros requisitos...
4) As variáveis estão declaradas como estáticas no fonte:
//métrica ação recurso glosa por tipo de glosa
@since 09/2021
@version P12 
/*/
//-------------------------------------------------------------------
function PlsTelRecGlo(cTipoGlosa,cAcao)

local cSubRotGuia	:= ""

default cTipoGlosa	:= ""
default cAcao		:= ""

if cTipoGlosa == "1" .and. cAcao == "1"
	cSubRotGuia := "ELETRONICA GLOSADA"
elseif cTipoGlosa == "1" .and. cAcao == "2"
	cSubRotGuia := "ELETRONICA RECONSIDERADA"
elseif cTipoGlosa == "2" .and. cAcao == "1"
	cSubRotGuia := "MANUAL GLOSADA"
elseif cTipoGlosa == "2" .and. cAcao == "2"
	cSubRotGuia := "MANUAL RECONSIDERADA"
elseif cTipoGlosa == "3" .and. cAcao == "1"
	cSubRotGuia := "AUTOMATICA GLOSADA"
elseif cTipoGlosa == "3" .and. cAcao == "2"
	cSubRotGuia := "AUTOMATICA RECONSIDERADA"
endif

if !empty(cSubRotGuia)
	FWMetrics():addMetrics(cSubRotGuia, {{"totvs-saude-planos-protheus_acoes-por-glosa_total", 1 }} )
endif

return

//-------------------------------------------------------------------
/*/ {Protheus.doc} plsDocumento
Visualizar documentos vinculados a BD5 ou a BE4
@since 04/2022
@version P12 
/*/
//-------------------------------------------------------------------

function plsDocumento()

	local cAlias := ""

	if BCI->BCI_TIPGUI <> "05"
		cAlias := "BD5"
	else
		cAlias := "BE4"
	endif

	MsDocument( cAlias, (cAlias)->( recno() ), 3 )

return

/*/{Protheus.doc} PtuReaLoc()
	Retorna dados necessários para criação da guia clone
	@type  Static Function
	@author Thiago Rodrigues
	@since 08/09/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PtuReaLoc(cAlias)
local aRet := {}
local cCodLDP := getNewPar("MV_PLSREAP","0107")
local cTipGui := &(cAlias+"->("+cAlias+"_TIPGUI)")
local cCodOpe := &(cAlias+"->("+cAlias+"_CODOPE)")
local cCodRda := &(cAlias+"->("+cAlias+"_CODRDA)")
local cOpeRda := BCI->BCI_OPERDA
local cAnoBCI := substr(Dtos(dDatabase),1,4)
local cMesBCI := SubStr(Dtos(dDataBase),5,2)
local cSituac := '1' //Ativo


// Cria peg
PLSIPP(cCodOpe,cCodLDP,cOpeRda,cCodRda,cMesBCI,cAnoBCI,dDataBase,cTipGui,"",{},"1",,,,,,cSituac,  date())

aRet := {.t.,cCodOpe,cCodLDP,BCI->BCI_CODPEG,BCI->BCI_CODRDA}

Return aRet

/*/{Protheus.doc} PlVerReap
	(Verifica se a guia se trata de uma reapresentação)
	@type  Function
	@author Thiago Rodrigues
	@since 21/09/2022
	/*/
Function PlVerReap(cCodope,cLote)
local lRet := .f.

Default cCodope := plsintpad()
Default cLote   := ""

BTO->(DbSetOrder(1))

if BTO->(fieldPos("BTO_REAPRE")) > 0
	if BTO->(MsSeek(xFilial("BTO")+cCodope+cLote))
		lRet := BTO->BTO_REAPRE =='1'
	endif
endif

BTO->(DbCloseArea())
Return lRet
