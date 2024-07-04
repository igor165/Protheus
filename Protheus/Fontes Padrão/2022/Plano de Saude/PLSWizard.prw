#INCLUDE "TOTVS.CH"  
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PLSWIZARD.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} plsWizard
Wizard do modulo plano de saude

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
function plsWizard(lAtu,lAuto)
local nI		:= 0
local oWizard	:= nil
local lGood		:= .t.
local cTitulo 	:= STR0001//"Preparação do modulo plano de saúde."
local cHeader	:= STR0002//"Carga de dados iniciais"
local cText		:= STR0003 + CRLF + STR0004 + CRLF + STR0005//"Bem vindo ao assistente de configuração do plano de saude,"+ CRLF +"após alguns passos o modulo estará pronto para utilização."+ CRLF +"Clique em Avançar para prosseguir."
local cRet		:= ""
local aOpePri	:= {}
local aFilAux	:= {}
local aPLTab 	:= {'B04','B07','B09','B18','B0F','B20','BA0','BA2','BA7','BAB','BAG','BAH','BAP','BAQ','BAR','BAS',;
					'BAT','BAU','BBB','BBF','BBL','BCG','BCJ','BCL','BCM','BCQ','BCS','BCT','BD1','BD2','BD3','BDL',;
					'BDR','BE5','BE8','BEU','BEW','BF7','BFM','BFQ','BG1','BG3','BG7','BG9','BGR','BGY','BH7','BI3',;
					'BI4','BI5','BI6','BI7','BIG','BIH','BII','BIL','BIM','BIY','BJ0','BJ1','BJ2','BJ3','BJ9','BJE',;
					'BK3','BK4','BL9','BLM','BLR','BN5','BP1','BP8','BPX','BQL','BQR','BQS','BQU','BR4','BR7','BRP',;
					'BRY','BSD','BSP','BBF','BT2','BTJ','BTY','BTZ','BW4','BWS','BWT','BX4','DE0','DE1','DE3','DE9',;
					'BAX','BB8','BDT','BF2','BF7','BJX','BKF','BAW','BKC','B7A','B7B','BVV','BVP','BVN',"BVR" }
	
private __WIZFILE 		:= PLSMUDSIS("\plswizard")
private __logWizard		:= "plswizard"+strTran(time(),':','')+'.log'
private __nLinBrw		:= 1
private __aDad			:= {{}}
private __cCodOpe		:= space(4)
private __cNomOpe		:= space(60)
private __cCNPJ			:= space(14)
private __cRegAns		:= space(6)

private __cAbrange		:= space(30)
private __cModOpe		:= space(30)
private __lOdonto		:= .f.
private __lTiss			:= .f.
private __lPortal		:= .f.
private __lDemo			:= .f.
private __lExec			:= .f.
private __lAtu			:= .t.
private __lNewOpe		:= .t.
private __lUpdateBase 	:= .f.

private __aMatAbr		:= {}
private __aMatMod		:= {}
private __aRecnoSM0		:= {}
private __aMatOpe		:= {}
private __aMatBase		:= {}
private __aChkFile		:= {}

private oProcess:= nil
private _lEnd	:= .f.

default lAtu := .t.
default lAuto:= .f.

//verifica se o diretorio existe se nao cria
if !existDir(__WIZFILE)
	if makeDir(__WIZFILE) <> 0
		if lAuto
			cRet := STR0006 //'Impossivel criar diretorio plswizard'
		else
			msgAlert(STR0006)//'Impossivel criar diretorio plswizard'
		endif
		return cRet
	endIf
endIf

//chamada para atualizacao de tabelas
if lAtu
	cTitulo := STR0007//'Atualização do modulo plano de saúde.'
	cHeader	:= STR0008//'Atualização de dados'
	cText	:= STR0009 + CRLF + STR0010 + CRLF + STR0011 //"Bem vindo ao assistente de atualização do plano de saude," + CRLF + "após alguns passos a atualização estará pronta."+ CRLF +"Clique em Avançar para prosseguir."
endIf

//se e uma atualizacao ou base nova.
__lAtu	:= lAtu

//inclui barra no final
__WIZFILE := PLSMUDSIS(__WIZFILE + '\')

//verifica se existe arquivos CSV
__aChkFile := PlArqCSVT(__WIZFILE, "*.csv") //directory( __WIZFILE + "*.csv")

//verifica se existe arquivo csv na pasta.
if len(__aChkFile) == 0
	lAtu  := .f.
	lGood := .f.
else

	 //se alguma tabela nao existir no diretorio nao deixa incluir uma nova operadora
	 for nI:=1 to len(aPLTab)

	 	if aScan(__aChkFile,{|x| upper(aPLTab[1]) $ upper(x[1]) } ) == 0
	 		lGood := .f.
	 		exit
	 	endIf

	 next

endIf

//se e base vazia e nao tem os arquivos necessarios exibe mensagem.
if !lAtu .and. !lGood
	if lAuto
		cRet := STR0095 + __WIZFILE + ']' //'Favor descompactar o arquivo PLSWIZARD na pasta ['
		return cRet
	endif
	
elseIf lAtu .and. !lGood
	__lNewOpe := .f.
endIf

//monta matriz usado no combo
__aMatAbr := getConField('BF7','BF7_DESORI')
__aMatMod := getConField('BTZ','BTZ_DESCRI')

//verifica se existe ao menos uma operadora
__lExec := getBA0(lAuto)

if !lAuto

	//wizard
	DEFINE WIZARD oWizard;
			TITLE cTitulo;
			HEADER cHeader;
			TEXT cText;
			PANEL

	//Identificação do negocio - panel 2
	PLWPassoIN(@oWizard)

	//Complementacao abrangencia, modalidade etc - panel 3
	PLWPassoAM(@oWizard)

	//Portal - panel 4
	PLWPassoPO(@oWizard)

	//Portal - panel 5
	PLWPassoCF(@oWizard)

	//Filial - panel 6
	PLWPassoFI(@oWizard)

	//Conclusao - panel 7
	PLWPassoCC(@oWizard)

	ACTIVATE WIZARD oWizard CENTERED VALID {|| iIf(__lExec,.t., getVld() ) }

else

	//Mantem desabilitado
	__lUpdateBase	:= .t.

	aFilAux := fWLoadSM0()

	//Seta nI para Filial logada
	For nI := 1 to len(aFilAux)
		If aFilAux[nI][2] == cFilAnt
			Exit
		endif
	Next

	aadd(__aRecnoSM0,{aFilAux[nI][1],aFilAux[nI][6],aFilAux[nI][2],aFilAux[nI][3],aFilAux[nI][4],aFilAux[nI][5],aFilAux[nI][7],allTrim(cValToChar(aFilAux[nI][12])),.t.})

	__aMatOpe:={}

	Aadd(aOpePri, getCon('CODOPE') )
	Aadd(aOpePri, getCon('NOMINT') )
	Aadd(aOpePri, getCon('CNPJ') )
	Aadd(aOpePri, getCon('REGISTROANS') )

	Aadd(aOpePri, getCon('ABRANGENCIA') )
	Aadd(aOpePri, getCon('MODALIDADEOPERADORA') )

	Aadd(aOpePri, getCon('ODONTO') == STR0057 )//'SIM'
	Aadd(aOpePri, getCon('TISS') == STR0057 )//'SIM'
	Aadd(aOpePri, getCon('PORTAL') == STR0057 )//'SIM'
	Aadd(aOpePri, getCon('DEMO') == STR0057 )//'SIM'	

	Aadd(aOpePri, .T. )

	Aadd(__aMatOpe, aOpePri )	

	//Grava dados
	oProcess := msNewProcess():new( {|_lEnd| __lExec := gravaDad() },STR0050,STR0051,.t.) //'Aguarde..'##'Processando'
	oProcess:activate()

endif

return cRet

//---------------------------------------------------------------------------------
/*/{Protheus.doc} PLWPassoIN
Painel para identificação do negocio
@param oWizard	Objeto onde os componentes serão criados

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//---------------------------------------------------------------------------------
static function PLWPassoIN(oWizard)
local oPanel := nil
local cInfo	 := STR0014 + CRLF + STR0015 + CRLF + STR0016 //"Atenção!!!" + CRLF + "Ao selecionar esta opção o registro encontrado na base de dados será alterado pelo conteúdo do arquivo CSV que está sendo importado!" + CRLF + "A busca é realizada pelo primeiro índice da tabela!"
local oFont	 := TFont():New('Courier New',,16,.t.)

//Panel
CREATE PANEL oWizard;
		HEADER STR0017; //"Identificação"
		MESSAGE CRLF + STR0018; //"Informações da Operadora."
		BACK {||.t.};
		NEXT {|| showNextParam(oWizard) };
		PANEL

	oPanel := oWizard:getPanel(oWizard:nTPanel)

	@ 010, 005 SAY STR0019 OF oPanel SIZE 150, 008 PIXEL //'Código'
	@ 018, 005 msGet __cCodOpe OF oPanel SIZE 10, 9 PIXEL Picture "@R !.!!!" VALID !(len(alltrim(__cCodOpe)) <> 4) WHEN getAltera()

	@ 030, 005 SAY STR0020 OF oPanel SIZE 150, 008 PIXEL //'Nome'
	@ 038, 005 msGet __cNomOpe OF oPanel SIZE 250, 9 PIXEL WHEN getAltera()

	@ 050, 005 SAY STR0021 OF oPanel SIZE 150, 008 PIXEL //'CNPJ'
	@ 058, 005 msGet __cCNPJ OF oPanel SIZE 150, 9 PIXEL Picture "@R 99.999.999/9999-99" VALID !(len(alltrim(__cCNPJ)) <> 14) WHEN getAltera()

	@ 070, 005 SAY STR0022 OF oPanel SIZE 150, 008 PIXEL //'Registro ANS'
	@ 078, 005 msGet __cRegAns OF oPanel SIZE 50, 9 PIXEL Picture "999999" WHEN getAltera()

	oUpdReg := TCheckBox():New(100,005,STR0023,,oPanel, 250,009,,,oFont,,,,,.T.,,,) //'Habilitar alteração de registro existente?'
	oUpdReg:bLClicked := {|| __lUpdateBase := !__lUpdateBase, __lUpdateBase := iif( __lUpdateBase,msgYesNo(cInfo),__lUpdateBase) }
	oUpdReg:bSetGet	  := {|| __lUpdateBase }

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLWPassoAM
Informacoes complementares

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function PLWPassoAM(oWizard)
local oPanel	:= nil
local oOdonto	:= nil
local oTiss		:= nil
local oPortal	:= nil
local oDemo		:= nil

//Panel
CREATE PANEL oWizard;
		HEADER STR0024;//"Informações complementares"
		MESSAGE CRLF + STR0025; //"Informações complementares"
		BACK {||.t.};
		NEXT {|| showNextParam(oWizard) };
		PANEL

	oPanel := oWizard:getPanel(oWizard:nTPanel)

	@ 010, 005 SAY STR0026 OF oPanel SIZE 150, 008 PIXEL //'Abrangência'
	@ 018, 005 msCombobox __cAbrange ITEMS __aMatAbr SIZE 200, 9 OF oPanel PIXEL WHEN getAltera()

	@ 030, 005 SAY STR0027 OF oPanel SIZE 150, 008 PIXEL
	@ 038, 005 msCombobox __cModOpe ITEMS __aMatMod SIZE 250, 9 OF oPanel ON CHANGE __lOdonto := at(upper('ODONTO'),upper(__cModOpe))>0 PIXEL WHEN getAltera()

	@ 055, 005 CHECKBOX oOdonto VAR __lOdonto PROMPT STR0028 OF oPanel SIZE 250, 009 PIXEL WHEN {|| __lNewOpe } //'Comercializa plano Odontológico?'

	@ 065, 005 CHECKBOX oTiss VAR __lTiss PROMPT STR0029 OF oPanel SIZE 250, 009 PIXEL WHEN {|| __lNewOpe } //'Digitação de guias ou recebimento de arquivos TISS?'

	@ 075, 005 CHECKBOX oPortal VAR __lPortal PROMPT STR0030 OF oPanel SIZE 250, 009 PIXEL WHEN {|| __lNewOpe } //'Utilizará Portal Autorizador?'

	@ 085, 005 CHECKBOX oDemo VAR __lDemo PROMPT STR0031 OF oPanel SIZE 250, 009 PIXEL WHEN {|| __lNewOpe } //'Popular tabelas para demonstração?'

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLWPassoPO
Portal

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function PLWPassoPO(oWizard)
local oPanel	:= nil
local oConf		:= nil
local cIni 		:= ''

//Panel
CREATE PANEL oWizard;
		HEADER STR0032; //"Configuração"
		MESSAGE CRLF + STR0033; //"Exemplo de configuração para utilização do Portal e Robo XML"
		BACK {|| .t. };
		NEXT {|| .t. };
		EXEC {|| cIni := carIni() };
		PANEL

//montra browse
oPanel := oWizard:GetPanel(oWizard:nTPanel)

@ 010,010 GET oConf VAR cIni SIZE 285,125 OF oPanel MULTILINE HSCROLL Pixel READONLY
oConf:bRClicked := {||allWaysTrue()}
oConf:oFont		:= TFont():New("Courier New",0,16)

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLWPassoCF
Permite ao usuário indicar um local com arquivos csv, na máquina local ou servidor, para copiar na pasta PLSWIZARD
@version P12
@since   10/2021
/*/
//-------------------------------------------------------------------
static function PLWPassoCF(oWizard)
local aDimTGet	:= {35, 110, 09} //ncoluna, nlagura, naltura
local aDimTSay	:= {05, 25, 11} //ncoluna, nlagura, naltura  
local cCamSel	:= space(60)
local cDirDisp	:= cvaltochar(GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
local cDirOri	:= "{|| cCamSel := cGetFile('Arquivos CSV |*.csv|','" + STR0101 + "',,'',.T.," + cDirDisp + ")}"  //'Selecione o diretório dos arquivos .csv'
local cTextExp	:= STR0122 + __WIZFILE + "." + CRLF + STR0123 //No campo Diretório, informe a pasta que contêm um ou mais arquivos do tipo *.csv, para copiar na pasta: - " "Todos os arquivos do tipo .*csv do diretório selecionado serão importados, facilitando o processo de cópia.
local oFontExb	:= TFont():New('Arial',,15,.t.)
local oPanel	:= nil

//Panel
CREATE PANEL oWizard;
		HEADER STR0098;//"Copiar arquivos complementares"
		MESSAGE CRLF + STR0099;//"Desejar copiar outros arquivos para a pasta PLSWIZARD?"; 
		BACK {|| showPrevParam(oWizard) };
		NEXT {|| showNextParam(oWizard) };
		PANEL

oPanel := oWizard:getPanel(oWizard:nTPanel)

//O usuário escolhe o caminho desejado:
TSay():New(21, aDimTSay[1], {||STR0100},oPanel,,oFontExb,,,,.T.,,,aDimTSay[2],aDimTSay[3])//Diretório
TGet():New(20, aDimTGet[1], {|u| If( PCount() == 0, cCamSel , cCamSel := u ) }, oPanel,aDimTGet[2],aDimTGet[3],"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cCamSel,,,,.t.,,,,,) 
TButton():New(20,150, STR0102, oPanel, &(cDirOri), 29, 12, , oPanel:oFont, ,.T.,.F.,,.T., ,, .F.) //Caminho

//Caminho padrão de Destino - para a pasta Wizard
TSay():New(41, aDimTSay[1], {||STR0103},oPanel,,oFontExb,,,,.T.,,,aDimTSay[2],aDimTSay[3]) //Destino:
TGet():New(40, aDimTGet[1], {|u| If( PCount() == 0, __WIZFILE , __WIZFILE := u ) }, oPanel,aDimTGet[2],aDimTGet[3],"@!",,0,/*10*/,,.F.,,.T.,,.F.,,.F.,.F.,/*20*/,.t.,.F.,,__WIZFILE,,,,.t.,,,,,) 

//Botão que efetua a cópia para a pasta PLSWIZARD
TButton():New(65,100, STR0120, oPanel, {||CopyFile(0, cCamSel, __WIZFILE)}, 40, 12, , oPanel:oFont, ,.T.,.F.,,.T., ,, .F.) //Copiar

//Texto explicativo sobre a funcionalidade:
TSay():New(90, aDimTSay[1], {||cTextExp},oPanel,,,,,,.T.,,,280,30)
return



//-------------------------------------------------------------------
/*/{Protheus.doc} PLWPassoFI
Filial

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function PLWPassoFI(oWizard)
local nI			:= 0
local oBrwFil		:= nil
local oPanel		:= nil
local aMatCab		:= {}
local aRecSM0		:= {}

//Panel
CREATE PANEL oWizard;
		HEADER STR0034; //"Registro de empresa e filial"
		MESSAGE CRLF + STR0035; //"Empresa e Filial"
		BACK {|| showPrevParam(oWizard) };
		NEXT {|| showNextParam(oWizard) };
		PANEL

oPanel := oWizard:GetPanel(oWizard:nTPanel)

aRecSM0 := fWLoadSM0()

for nI:=1 to  len(aRecSM0)
	if FWGrpCompany() == aRecSM0[nI,1]
		aadd(__aRecnoSM0,{aRecSM0[nI][1],aRecSM0[nI][6],aRecSM0[nI][2],aRecSM0[nI][3],aRecSM0[nI][4],aRecSM0[nI][5],aRecSM0[nI][7],allTrim(cValToChar(aRecSM0[nI][12])),.f.})
	endIf
next nI

//Monta a tela para usuario visualizar consulta
if len(__aRecnoSM0)>0
	aadd(aMatCab,{STR0036,"@!",050}) //"Grupo Emp"
	aadd(aMatCab,{STR0037,"@!",100}) //"Descrição"
	aadd(aMatCab,{STR0038,"@!",030}) //"Código"
	aadd(aMatCab,{STR0039,"@!",030}) //"Empresa"
	aadd(aMatCab,{STR0040,"@!",030}) //"Unidade"
	aadd(aMatCab,{STR0041,"@!",030}) //"Filial"
	aadd(aMatCab,{STR0042,"@!",100}) //"Descrição"
	aadd(aMatCab,{STR0043,"@!",030}) //"Recno"
endIf

oBrwFil := PLSSELOPT("",STR0096,__aRecnoSM0,aMatCab,3,.t.,.t.,.f.,oPanel,000,010,115,294)//"Marca e Desmarca todos"

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLWPassoCC
Conclusao

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function PLWPassoCC(oWizard)
local oPanel := nil

//Panel
CREATE PANEL oWizard;
		HEADER STR0044; //"Registro da Operadora"
		MESSAGE CRLF + STR0045; //"Operadora(s)"
		BACK {|| showPrevParam(oWizard) };
		FINISH {|| showFinish(@oWizard) };
		EXEC {|| carDad(oPanel) };
		PANEL

oPanel := oWizard:getPanel(oWizard:nTPanel)

//Browse de operadora carrega no EXEC

@ 125,005 BUTTON STR0046 ACTION eval( {|| setNew(@oWizard) } ) SIZE 60, 11 OF oPanel PIXEL WHEN {|| __lNewOpe } //"Incluir outra Operadora"

return

//-------------------------------------------------------------------
/*/{Protheus.doc} showFinish
Move para o fim dos parametros

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function showFinish(oWizard)
local lRet := .t.

//private oProcess:= nil
//private _lEnd	:= .f.

//verifica se ao menos uma operadora foi selecionada
lRet := aScan(__aMatOpe,{|x| x[len(__aMatOpe[1])] == .t.})>0

if !lRet
	msgAlert(STR0047) //'Selecione ao menos uma Operadora.'
else
	if msgYesNo(STR0048,STR0049) //"Confirma a atualização dos dados?"##"Atenção"
		oProcess := msNewProcess():new( {|_lEnd| __lExec := gravaDad() },STR0050,STR0051,.t.) //'Aguarde..'##'Processando'
		oProcess:activate()
	endIf
	oWizard:setFinish()
endIf

return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} showNextParam
Validacao do paniel se passa para o proximo ou nao

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function showNextParam(oWizard)
local lRet := .t.

do case
	//Identificacao do Negocio - PLWPassoIN
	case oWizard:nPanel == 2

		if empty(__cCodOpe) .or. empty(__cNomOpe)
			lRet := .f.
		endIf

		if !lRet
			msgAlert(STR0097)//'Informe código e nome da operadora.'
		else
			setCon('CODOPE',__cCodOpe,STR0019,"@R !.!!!",030)//"Código"
			setCon('NOMINT',__cNomOpe,STR0020,"@C",160) //"Nome"
			setCon('CNPJ',__cCNPJ,STR0021,"@R 99.999.999/9999-99",070) //"CNPJ"
			setCon('REGISTROANS',__cRegAns,STR0022,"999999",050) //"Registro ANS"
		endIf

	//Abrangencia e Modalidade - PLWPassoAM
	case oWizard:nPanel == 3

		setCon('ABRANGENCIA',__cAbrange,STR0026,"@C",080) //"Abrangência"
		setCon('MODALIDADEOPERADORA',__cModOpe,STR0027,"@C",100) //"Modalidade"
		setCon('ODONTO',iif(__lOdonto,STR0057,STR0058),STR0053,"@!",040) //"Odontologia"##'SIM'##'NAO'
		setCon('TISS',iif(__lTiss,STR0057,STR0058),STR0054,"@!",040) //"Tiss/Guias"##'SIM'##'NAO'
		setCon('PORTAL',iif(__lPortal,STR0057,STR0058),STR0055,"@!",040) //"Portal"##'SIM'##'NAO'
		setCon('DEMO',iif(__lDemo,STR0057,STR0058),STR0056,"@!",040) //"Demonstração"##'SIM'##'NAO'

		//verifica se exibe o Passo - ini de configuracao
		if getCon('PORTAL')!= STR0057//'SIM'
			oWizard:nPanel := 4
		endIf

	//Copia de Arquivos - PLWPassoCF
	case oWizard:nPanel == 5
		
		__aChkFile := PlArqCSVT(__WIZFILE, "*.csv")
		lRet := !(len( __aChkFile ) == 0)
		if !lRet
			msgAlert(STR0124, STR0049) //"Nenhum arquivo .CSV na pasta Wizard. Coloque o(s) arquivo(s) na pasta ou utilize a rotina de copiar arquivos. Caso contrário, finalize a rotina."
		endif

	//Filial - PLWPassoFI
	case oWizard:nPanel == 6

		lRet := aScan(__aRecnoSM0,{|x| x[len(__aRecnoSM0[1])] == .t.})>0

		if !lRet
			msgAlert(STR0059) //'Selecione ao menos uma Empresa/Filial.'
		endIf

endCase

return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} showPrevParam
Validacao do paniel se volta ou nao

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function showPrevParam(oWizard)

do case
	//Filial - PLWPassoFI
	case oWizard:nPanel == 5

		//verifica se exibe o Portal - PLWPassoPO
		if getCon('PORTAL') != STR0057//'SIM'
			oWizard:nPanel := 4
		endIf

	//Conclusao - PLWPassoCC
	case oWizard:nPanel == 7
		//atualiza variaveis
		__cCodOpe 	:= getCon('CODOPE')
		__cNomOpe 	:= getCon('NOMINT')
		__cCNPJ 	:= getCon('CNPJ')
		__cRegAns 	:= getCon('REGISTROANS')

		__cAbrange	:= getCon('ABRANGENCIA')
		__cModOpe	:= getCon('MODALIDADEOPERADORA')

		__lOdonto	:= getCon('ODONTO') == STR0057//'SIM'
		__lTiss		:= getCon('TISS') 	== STR0057//'SIM'
		__lPortal	:= getCon('PORTAL') == STR0057//'SIM'
		__lDemo		:= getCon('DEMO')	== STR0057//'SIM'

endCase

return(.t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNew
Novo registro

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function setNew(oWizard,lMudPN,lAtuV)
default oWizard	:= nil
default lMudPN 	:= .t.
default lAtuV	:= .t.

__nLinBrw := len(__aDad) + 1

if __nLinBrw > len(__aDad)
	aadd(__aDad,{})
endIf

if lAtuV
	__cCodOpe	:= space(4)
	__cNomOpe	:= space(60)
	__cCNPJ		:= space(14)
	__cRegAns	:= space(6)

	__cAbrange	:= iIf(len(__aMatAbr)>1,__aMatAbr[1],space(30))
	__cModOpe	:= iIf(len(__aMatMod)>1,__aMatMod[1],space(30))

	__lOdonto		:= .f.
	__lTiss			:= .f.
	__lPortal		:= .f.
	__lDemo			:= .f.
	__lAtu			:= .f.
	__lUpdateBase	:= .f.
endIf

if lMudPN
	oWizard:getPanel(2)
	oWizard:setPanel(2)
	oWizard:refreshButtons()
endIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} carDad
Carrega browse das operadora

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function carDad(oPanel)
local nFor,nI	:= 0
local cMacro	:= ''
local lCab		:= .t.
local aMatCab	:= {}
local aDad		:= {}
local oBrwWiz	:= nil

__aMatOpe := {}

//monta cabecalho e corpo do browse
for nI:=1 to len(__aDad)

	aDad := __aDad[nI]

	cMacro := '{||aadd(__aMatOpe,{'

	for nFor:=1 to len(aDad)
		if lCab			
			aadd(aMatCab,{aDad[nFor,1],aDad[nFor,2],aDad[nFor,3]})
		endIf

		cMacro += ' "' + aDad[nFor,5] + '"'+ iif(len(aDad)!=nFor,',','')
	next

	cMacro += ',.f.})}'

	cMacro := StrTran(cMacro,"'","")

	eval(&cMacro)
	lCab := .f.
next

oBrwWiz := PLSSELOPT("",STR0060,__aMatOpe,aMatCab,3,.t.,.t.,.f.,oPanel,000,010,100,294) //"Marca e Desmarca todos"

oBrwWiz:bChange := {|| __nLinBrw := oBrwWiz:nAt }

__nLinBrw := oBrwWiz:nAt
return

//-------------------------------------------------------------------
/*/{Protheus.doc} retCol
retorna o conteudo da coluna

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function retCol(oBrwWiz,nFor)
local aMatDad := oBrwWiz:aArray

cRet := OemToAnsi( iIf(oBrwWiz:nAt<=len(aMatDad),aMatDad[oBrwWiz:nAt,nFor],'') )

return cRet

/*/{Protheus.doc} getCon
Retorna conteudo conforme campo

@author Alexander Santos
@since 25/09/14
@version 1.0
/*/
static function getCon(cCampo,lPos)
local xConteudo := ''
local nPos		:= 0
default lPos	:= .f.

if (nPos := exisCon(cCampo))>0
	xConteudo := iIf(lPos,nPos,__aDad[__nLinBrw,nPos,5])
endIf

return(xConteudo)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCon
set conteudo na matriz de dados

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function setCon(cCampo,cConteudo,cDescri,cPic,cTam)
local nPos := 0

if (nPos := exisCon(cCampo))==0
	aadd(__aDad[__nLinBrw],{cDescri,cPic,cTam,cCampo,cConteudo})
else
	__aDad[__nLinBrw,nPos,5] := cConteudo
endIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} exisCon
verifica se o registro ja existe

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function exisCon(cCampo)
local nPos := 0

nPos := aScan(__aDad[__nLinBrw],{|x| upper(x[4]) == upper(cCampo)})

return(nPos)

//-------------------------------------------------------------------
/*/{Protheus.doc} getConField
Retorna o conteudo de campos de um arquivo

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function getConField(cFile,cCampo)
local nH	 	:= 0
local nQtdReg	:= 0
local nPos		:= 0
local cSeparador:= ';'
local cLine		:= ''
local aMatCab	:= {}
local aMatLine	:= {}
local aMatDad	:= {}

//procura o arquivo no diretorio e retorna o nome completo.
if (nPos := aScan(__aChkFile,{|x| upper(cFile) $ upper(x[1]) })) > 0

	cFile := allTrim(__aChkFile[nPos,1])

	nH := ft_fUse( allTrim(__WIZFILE) + cFile )

	ft_fGotop()
	while (!ft_fEof())

		cLine := ""

		//Tratamento para quebra de linha de arquivo maior que 1023 caracteres - F?io Consentino 02/06/16
		While .T.

			cLine += FT_fReadLn()

          //Verifica se encontrou o final da linha para gravar
          If Len(FT_fReadLn()) < 1023
            	Exit
          Else
              Ft_fSkip()
          EndIf
		EndDo


		if empty(cLine)
			ft_fSkip()
			loop
		endIf

		nQtdReg++

		if nQtdReg==1
			aMatCab := strToKarr(cLine,cSeparador)

			if (nPos := aScan(aMatCab,{|x| x == upper(cCampo)}))==0
				plslogfil(STR0061 + cCampo + STR0062 + cFile + "]",__logWizard) //"Campo ["##"] nao encontrado no arquivo ["
				exit
			endIf
			ft_fSkip()
			loop
		else
			aMatLine := strToKarr(cLine,cSeparador)
		endIf
		//inclui o conteudo do arquivo na matriz
		if nPos>0
			aadd(aMatDad,aMatLine[nPos])
		endIf

	ft_fSkip()
	endDo

	ft_fUse()
	nH := nil
else
	plslogfil(STR0063 +__WIZFILE + cFile + STR0064,__logWizard)	 //"Arquivo ["##"] nao encontrado!"
endIf

return(aMatDad)


//-------------------------------------------------------------------
/*/{Protheus.doc} getMat
Montra matriz para tratamento de operadora odonto ou de saude

@author Alexander Santos
@since 25/09/14
@version 1.0
/*/
//-------------------------------------------------------------------
static function getMat(aMatRel,aMatTiss,aTabOdo,aMatOdo,aNTabOdo,aMatRetO,aMatFicO,aMatNVld)

//#1010-De/Para do cabeçalho das tabelas TISS disponibilizadas pela ANS
aadd(aMatRel,{'CODIGO DO TERMO','BTQ_CDTERM'})
aadd(aMatRel,{'CODIGO TUSS','BTQ_CDTERM'})
aadd(aMatRel,{'CODIGO DA TABELA','BTQ_CDTERM'})
aadd(aMatRel,{'CODIGO','BTQ_CDTERM'})
aadd(aMatRel,{'TERMO','BTQ_DESTER'})
aadd(aMatRel,{'DESCRICAO DO GRUPO','BTQ_DESTER'})
aadd(aMatRel,{'DESCRICAO','BTQ_DESTER'})
aadd(aMatRel,{'GRUPO','BTQ_DESTER'})
aadd(aMatRel,{'REGISTRO ANVISA','BTQ_DSCDET'})
aadd(aMatRel,{'CLASSE DE RISCO','BTQ_DSCDET'})
aadd(aMatRel,{'DESCRICAO DETALHADA DO TERMO','BTQ_DSCDET'})
aadd(aMatRel,{'BRANCO','BTQ_DSCDET'})
aadd(aMatRel,{'DATA DE INICIO DE VIGENCIA','BTQ_VIGDE'})
aadd(aMatRel,{'DATA DE FIM DE VIGENCIA','BTQ_VIGATE'})
aadd(aMatRel,{'DATA DE FIM DE IMPLANTACAO','BTQ_DATFIM'})
aadd(aMatRel,{'CODIGO DO GRUPO','BTQ_CODGRU'})
aadd(aMatRel,{'DESCRICAO DO GRUPO','BTQ_DESGRU'})
aadd(aMatRel,{'FORMA DE ENVIO','BTQ_FENVIO'})
aadd(aMatRel,{'SIGLA','BTQ_SIGLA'})
aadd(aMatRel,{'APRESENTACAO','BTQ_APRESE'})
aadd(aMatRel,{'LABORATORIO','BQT_LABORA'})
aadd(aMatRel,{'REFERENCIA NO FABRICANTE','BTQ_REFFAB'})
aadd(aMatRel,{'FABRICANTE','BTQ_FABRIC'})

//#1020-Arquivos relacionados ao processo TISS
aadd(aMatTiss,'BTP')
aadd(aMatTiss,'BTU')
aadd(aMatTiss,'BTQ')
aadd(aMatTiss,'B7A')
aadd(aMatTiss,'B7B')
aadd(aMatTiss,'B7C')
aadd(aMatTiss,'BCL')
aadd(aMatTiss,'BCM')
aadd(aMatTiss,'BCQ')
aadd(aMatTiss,'BCS')
aadd(aMatTiss,'BVN')
aadd(aMatTiss,'BVP')
aadd(aMatTiss,'BVR')
aadd(aMatTiss,'BVV')

//#1030-Arquivos exclusivos da operadora odontologia
aadd(aTabOdo,'BA9-CID_OE')
aadd(aTabOdo,'BTQ-TAB28')
aadd(aTabOdo,'BTQ-TAB32')
aadd(aTabOdo,'BTQ-TAB42')
aadd(aTabOdo,'BTQ-TAB44')
aadd(aTabOdo,'BTQ-TAB51')
aadd(aTabOdo,'B04')
aadd(aTabOdo,'B09')

//#1040-Termos relacionados a operadora odontologia
aadd(aMatOdo,'ODONTOLOGICO')
aadd(aMatOdo,'ODONTOLOGIA')
aadd(aMatOdo,'ODONTOLOGICAS')
aadd(aMatOdo,'Cirurgiao dentista')
aadd(aMatOdo,'Emissao de Guia Odontologica')
aadd(aMatOdo,'DENTISTAS')

//#1050-Arquivos exclusivos da operadora de saúde
aadd(aNTabOdo,'BA9-CID_10')
aadd(aNTabOdo,'BWS')
aadd(aNTabOdo,'BTQ-TAB18')
aadd(aNTabOdo,'BTQ-TAB19')
aadd(aNTabOdo,'BTQ-TAB29')
aadd(aNTabOdo,'BTQ-TAB58')

//#1060-Termos relacionados a operadora de saúde que serão retirados quando for somente operadora odontológica
aadd(aMatRetO,'MEDICO')
aadd(aMatRetO,'CLINICA MEDICA')
aadd(aMatRetO,'CLASSE MEDICA')
aadd(aMatRetO,'MEDICAS')
aadd(aMatRetO,'AUDITORIA MEDICA')
aadd(aMatRetO,'PERICIA MEDICA')
aadd(aMatRetO,'CONSULTA MEDICA')
aadd(aMatRetO,'INSTRUMENTADOR')
aadd(aMatRetO,'PERFUSIONISTA')
aadd(aMatRetO,'PEDIATRA')
aadd(aMatRetO,'INTENSIVISTA')
aadd(aMatRetO,'BERCARIO')
aadd(aMatRetO,'NEONATAL')
aadd(aMatRetO,'UTSI')
aadd(aMatRetO,'OBITO')
aadd(aMatRetO,'ANESTESISTA')
aadd(aMatRetO,'GENETICISTA')
aadd(aMatRetO,'BIOLOGIA')
aadd(aMatRetO,'BIOLOGOG')
aadd(aMatRetO,'CARDIACOS')
aadd(aMatRetO,'PROCEDIMENTOS OBSTETRICOS')
aadd(aMatRetO,'VASCULAR')

//#1070-Tabela e Termos relacionados a operadora odontológica que ficam quando for somente operadora odontológica
aadd(aMatFicO,'BAH;CRO;OCS')
aadd(aMatFicO,'BAQ;DENTISTA;DESCONHECIDO')
aadd(aMatFicO,'B0X;DENTISTA;DESCONHECIDO')
aadd(aMatFicO,'BI6;ODONTOLOGICO')
aadd(aMatFicO,'BDL;PANORAMICO;URGENCIA;CONSULTAS;EXAMES')
aadd(aMatFicO,'BKC;REA;USO')
aadd(aMatFicO,'BGY;CIRURGIA;AMBULATORIO;CONSULTA;DOMICILIAR;INTERNACAO;SOCORRO')
aadd(aMatFicO,'BH7;PROCEDIMENTOS ESTETICOS;ORTODON;ODONTOLOGI;BUCO;HOSPITAL;DENTISTICA;ENDODONTIA;HOME CARE;PERIODONTIA;PRONTO ATENDIMENTO;PRONTO SOCORRO;ALUGUEL;FARMACIA;INTERNACOES;REPARADORA;DISTAL')
aadd(aMatFicO,'BSD;ESPECIALIDADE')
aadd(aMatFicO,'BEW;NAO INFORMADO')
aadd(aMatFicO,'BF0;ODONTOLOG;DENTE;GENGIVAL;DENTARIO;PERMANEN;ENDODONTICO;EXAMES;CLINICA;HOSPITALAR;REGIME DE INTERNACAO')
aadd(aMatFicO,'BQR;CLINICA')

//#1080-Tabelas que não sao verificadas pelas regras 1040,1060 e 1070
aadd(aMatNVld,'BCT')
aadd(aMatNVld,'B7A')
aadd(aMatNVld,'B7B')
aadd(aMatNVld,'B7C')
aadd(aMatNVld,'BVN')
aadd(aMatNVld,'BVP')

return

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaDad
Grava dados

@author Alexander Santos
@since 25/09/14
@version 1.0
/*/
//-------------------------------------------------------------------
static function gravaDad()
local nI,nX		:= 0
local nH,nOpe	:= 0
local nPos		:= 0
local nQtdLin	:= 0
local nQtdReg	:= 0
local nPosCP 	:= 0
local nPosNP 	:= 0
local nHoraBase := seconds()
local cHoraBase := time()
local cFile		:= ''
local cLine		:= ''
local cDesCmp	:= ''
local cAlias	:= ''
local cModOpe	:= ''
local cFileTxt  := 'exmplo-ini-portal-tissonline-roboxml.txt'
local nQtdFile 	:= len(__aChkFile)
local cSeparador:= ';'
local lFWI		:= .t.

local aMatLine	:= {}
local aMatCab	:= {}
local aMatRel	:= {}
local aMatTiss	:= {}
local aTabOdo	:= {}
local aMatOdo	:= {}
local aNTabOdo	:= {}
local aMatRetO	:= {}
local aMatFicO	:= {}
local aMatNVld	:= {}

local aMatUsr	:= {}
local aMatTro	:= {}
local aTabNP	:= {}
local aAux		:= {}
local aMatSix	:= {}
local lTiss 	:= .f.
local lOdonto	:= .f.
local lDemo		:= .f.
local lOnlyOd	:= .f.

//montra matriz para tratamento entre operadora odonto e de saude
getMat(aMatRel,aMatTiss,aTabOdo,aMatOdo,aNTabOdo,aMatRetO,aMatFicO,aMatNVld)

//Quantidade de operadoras
for nOpe := 1 to len(__aMatOpe)

	if __aMatOpe[nOpe,len(__aMatOpe[nOpe])]

		// Processamento
		oProcess:setRegua1(nQtdFile)

		__nLinBrw := nOpe

		//pega dados da operadora que esta sendo processada
		cModOpe	:= getCon('MODALIDADEOPERADORA')
		lTiss 	:= getCon('TISS') == STR0057//'SIM'
		lOdonto	:= getCon('ODONTO') == STR0057//'SIM'
		lDemo	:= getCon('DEMO') == STR0057//'SIM'
		lOnlyOd	:= at('ODONTO',getCon('MODALIDADEOPERADORA'))>0

		//Quantidade de arquivos
		for nI := 1 to nQtdFile
			cFile 	:= allTrim(__aChkFile[nI,1])
			cAlias	:= left(cFile,3)
			nQtdReg	:= 0
			aMatTro	:= {}
			aMatSix	:= {}

			if !plsAliasExi(cAlias)
				//deleta arquivo processado
				fErase(allTrim(__WIZFILE) + cFile)
				loop
			endIf
			// abre a area
			dbSelectArea(cAlias)

			//verifica se a tabela e de demonstracao
			if !lDemo .and. at('DEMONSTRACAO',upper(cFile))>1
				//deleta arquivo processado
				fErase(allTrim(__WIZFILE) + cFile)
				loop
			endIf

			//Tabelas do questionario que nao serao processadoas serve para combo de opcao
			if !lFWI .and. cAlias == 'BTQ'
				loop
			endIf

			//odontologia - 1050
			if lOnlyOd
				if aScan(aNTabOdo,{|x| upper(x) $ upper(cFile) })>0
					plslogfil(STR0066+cFile+']',__logWizard) //'regra 1050 - Tabela ['
					loop
				endIf
				lOdonto := .t.
			endIf

		   //se nao for odontologia - 1030
			if !lOdonto
				if aScan(aTabOdo,{|x| upper(x) $ upper(cFile) })>0
					plslogfil(STR0067+cFile+']',__logWizard)//'regra 1030 - Tabela ['
					loop
				endIf
			endIf

			//TISS - 1020
			if !lTiss
				if aScan(aMatTiss,{|x| upper(x) $ upper(cFile) })>0
					plslogfil(STR0068+cFile+']',__logWizard)//'regra 1020 - Tabela ['
					loop
				endIf
			endIf

			//abre o arquivo
			nH 		:= ft_fUse(allTrim(__WIZFILE)+cFile)
			nQtdLin := ft_fLastRec()

			//se for BX4 pega usuario do configuradora
			if 'BX4' == cAlias

				//Carrega usuarios do configurado
				aAux := allUsers()

				for nX:=1 to len(aAux)

					//Verifica se o usuario do configurador pertence ao modulo pls
					if aScan(aAux[nX,3],{|x| "335" $ x })>0
						aadd(aMatUsr,{aAux[nX,1,1],aAux[nX,1,2]})
					endIf
				next

				nQtdLin := len(aMatUsr)
			endIf

			// seta barra
			oProcess:incRegua1(STR0069 + left(cFile,30) )//'Arquivo: '
			oProcess:setRegua2(nQtdLin)
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Importando -> " + cFile , 0, 0, {})

			// transacao
			BEGIN TRANSACTION

			// lendo arquivo                           FSW
			ft_fGotop()
			while (!ft_fEof())

				cLine := ""

				//Tratamento para quebra de linha de arquivo maior que 1023 caracteres - F?io Consentino 02/06/16
				While .T.

					cLine += FT_fReadLn()

		          //Verifica se encontrou o final da linha para gravar
		          If Len(FT_fReadLn()) < 1023
		            	Exit
		          Else
		              Ft_fSkip()
		          EndIf
				EndDo


				if empty(cLine)
					ft_fSkip()
					loop
				endIf

				nQtdReg++

				if nQtdReg==1
					if at('$',cLine)>0
						cSeparador := '$'
					elseif at('~',cLine)>0
						cSeparador := '~'
					else
						cSeparador := ';'
					endIf
				endIf

				cLine := strTran(cLine,cSeparador,cSeparador+" ")

				if left(cLine,1) == cSeparador
					cLine := " " + cLine
				endIf

				//cabecalho
				if nQtdReg==1

					aMatCab := strToKarr(cLine,cSeparador)

					//Se nao for a a primeira operadora so deixa passar para tabelas que tem codint ou codope
					if !lFWI
						if aScan(aMatCab,{|x| '_CODINT' $ x }) == 0 .and. aScan(aMatCab,{|x| '_CODOPE' $ x }) == 0
							exit
						endIf
					endIf

					//ajusta cabecalho das tabelas TISS TAB?? - 1010
					if cAlias == 'BTQ'

						for nX:=1 to len(aMatCab)
							cDesCmp := FwNoAccent(allTrim(aMatCab[nX]))

							if empty(cDesCmp)
								cDesCmp := 'BRANCO'
							endIf

							if (nPos := aScan(aMatRel,{|x| upper(cDesCmp) == upper(x[1]) }))>0
								aMatCab[nX] := aMatRel[nPos,2]
							endIf
						next
						aadd(aMatCab,'BTQ_CODTAB')
					endIf

					//verifica a opcao e troca o conteudo do arquivo por dados do questionario
					if cAlias == 'BA0'
						setTro(aMatTro,aMatCab,'BA0_CODIDE',left(getCon('CODOPE'),1))
						setTro(aMatTro,aMatCab,'BA0_CODINT',right(getCon('CODOPE'),3))
						setTro(aMatTro,aMatCab,'BA0_NOMINT',getCon('NOMINT'))
						setTro(aMatTro,aMatCab,'BA0_CGC',getCon('CNPJ'))
						setTro(aMatTro,aMatCab,'BA0_SUSEP',getCon('REGISTROANS'))
						setTro(aMatTro,aMatCab,'BA0_GRUOPE',getPGM(__aMatAbr,getCon('ABRANGENCIA')) )
						setTro(aMatTro,aMatCab,'BA0_MODOPE',getPGM(__aMatMod,getCon('MODALIDADEOPERADORA')) )

					//posicao inicial do codigo e a operadora
					elseIf cAlias $ 'BJ3,BJ9,BIL'
						setTro(aMatTro,aMatCab,'_CODIGO',getCon('CODOPE'),'*')
					else
						if cAlias != 'BX4'
							setTro(aMatTro,aMatCab,'_CODOPE',getCon('CODOPE'))
						endIf
						setTro(aMatTro,aMatCab,'_CODINT',getCon('CODOPE'))
						setTro(aMatTro,aMatCab,'_NOMINT',getCon('NOMINT'))
						setTro(aMatTro,aMatCab,'_ABRANG',getPGM(__aMatAbr,getCon('ABRANGENCIA')))
					endIf

					ft_fSkip()
					loop
				else
					oProcess:incRegua2(STR0070 + cValtoChar(nQtdReg) + STR0071 + cValToChar(nQtdLin)) //'Registro: '##' de '

					//somente se nao tiver na regra - 1080
					if aScan(aMatNVld,{|x| upper(x) == upper(cAlias) })==0

						//Verifica modalidade
						if cAlias == 'BTZ' .and. !(upper(allTrim(cModOpe)) $ cLine)
							ft_fSkip()
							loop
						endIf

						//se nao for odontologia - 1040
						if !lOdonto
							if aScan(aMatOdo,{|x| upper(x) $ cLine })>0
								plslogfil(STR0072+cFile+STR0073+cLine+']',__logWizard) //'regra 1040 - Tabela ['##'] conteudo da linha ['
								ft_fSkip()
								loop
							endIf
						endIf

						//somente odonto - 1060
						if lOnlyOd .and.  !('ODONTO' $ cLine)

							//somente tabelas que nao sao do processo odonto - 1030
							if aScan(aTabOdo,{|x| upper(x) $ upper(cFile) }) == 0

								//termos retirados quando e somente odonto - 1060
								if aScan(aMatRetO,{|x| upper(x) $ cLine })>0
									plslogfil(STR0074+cFile+STR0073+cLine+']',__logWizard)//'regra 1060 - Tabela ['##'] conteudo da linha ['
									ft_fSkip()
									loop
								endIf

								//termos que ficam quando e somente odontologico o restante retira - 1070
								if (nPos := aScan(aMatFicO,{|x| cAlias $ upper(x) }))>0

									aAux := strToKarr(right(aMatFicO[nPos],len(aMatFicO[nPos])-4),';')

									//se nao pertence retira
									if aScan(aAux,{|x| upper(x) $ cLine })==0
										plslogfil(STR0075+cFile+STR0073+cLine+']',__logWizard)//'regra 1070 - Tabela ['##'] conteudo da linha ['
										ft_fSkip()
										loop
									endIf
								endIf
							endIf
						endIf
					endIf

					aMatLine := strToKarr(cLine,cSeparador)

					if cAlias == 'BTQ'
						aadd(aMatLine,subStr(cFile,8,2))
					endIf
				endIf

				//verifica colunas cabecalho x conteudo
				if len(aMatCab) <> len(aMatLine)

					plslogfil(replicate('*',30),__logWizard)
					plslogfil(STR0076+cFile+']',__logWizard) //'Arquivo ['
					plslogfil(STR0077+cAlias+']',__logWizard) //'Verifique a tabela ['
					plslogfil(STR0078+cValToChar(nQtdReg)+']',__logWizard) //'conteudo da linha ['
					plslogfil(STR0079+cValtoChar(len(aMatCab))+']',__logWizard) //'Quantidade no cabelho ['
					plslogfil(STR0080+cValtoChar(len(aMatLine))+']',__logWizard)//'Quantidade na linha   ['

					aadd(aTabNP,{cAlias,nQtdReg,len(aMatCab),len(aMatLine),cFile} )
					exit
				endIf

				//carregamento integrado BX4 - usuarios do CFG (configurador)
				if cAlias == 'BX4'

					nPosCP := aScan(aMatCab,{|x| allTrim(x) == 'BX4_CODOPE'})
					nPosNP := aScan(aMatCab,{|x| allTrim(x) == 'BX4_NOMOPE'})

					if nPosCP>0 .and. nPosNP>0

						//Carrega usuarios do configurado
						for nX:=1 to len(aMatUsr)

							oProcess:incRegua2(STR0070 + cValtoChar(nX) + STR0071 + cValToChar(nQtdLin)) //'Registro: '##' de '

							aMatLine[nPosCP] := aMatUsr[nX,1]
							aMatLine[nPosNP] := aMatUsr[nX,2]

							//grava registro
							recDad(cAlias,aMatCab,aMatLine,aMatTro,aMatSix)
						next
						exit
					else
						plslogfil(STR0081,__logWizard) //'Campos BX4_CODOPE ou BX4_NOMOPE não estao presentes no layout da tabela BX4'
					endIf
					exit
				else
					//grava conteudo na tabela
					recDad(cAlias,aMatCab,aMatLine,aMatTro,aMatSix)
				endIf

				//proxima linha
				ft_fSkip()
			endDo
			dbCommitAll()

			END TRANSACTION

			ft_fUse()
			nH := nil
		next

		lFWI:=.F.

	endIf
next

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0082 + cHoraBase + STR0083 + allTrim(str((seconds()-nHoraBase)/60,12,3)) + STR0084 , 0, 0, {}) //"inicio ["##"] duracao ["## "] minutos"

//deleta arquivo processado
for nI := 1 to nQtdFile
	fErase(__WIZFILE + allTrim(__aChkFile[nI,1]) )
next

if 	file(__WIZFILE + cFileTxt)
	fErase(__WIZFILE + cFileTxt)
endIf

if !empty(aTabNP)
 	PLSCRIGEN(aTabNP,{ {STR0085,"@C",30},{STR0086,"@C",50},{STR0087,"@!",70},{STR0088,"@!",70},{STR0089,"@C",110} },STR0090) //'Tabela'##'Linha'##'Qtd. Coluna CAB.'##'Qtd. Coluna LINHA'##'Arquivo'##'Verifique as tabelas não processadas'
endIf

return(.t.)

/*/{Protheus.doc} retCHK
Retorna a chave do alias

@author Alexander Santos
@since 25/09/14
@version 1.0
/*/
static function retCHK(cAlias,aMatCab,aMatLine,aMatSix,cCmpFil)
local nX,nPos,i	:= 0
local nPosI		:= 0
local cChave	:= ''
local cCampo	:= ''
local cConteudo := ''
local nPosIni   := 0
default aMatSix := {}

if len(aMatSix)==0
	SIX->(dbSetOrder(1))
	if SIX->(msSeek(cAlias+iif(cAlias$"B7B;BCM","2","1")))
		aMatSix := strToKarr(SIX->CHAVE,'+')
	else
		plslogfil(STR0091+cAlias+"]",__logWizard)//"Indice 1 não encontrado na tabela ["
	endIf
endIf

for i := 1 to len(aMatSix)
	//aMatSix[i] := StrTran(aMatSix[i], "STR(", "")
	//aMatSix[i] := StrTran(aMatSix[i], ")", "")

	nPosIni := AT("(", aMatSix[i])

	if nPosIni > 0
		aMatSix[i] := SUBSTR(aMatSix[i], nPosIni + 1, len(alltrim(aMatSix[i])) - (nPosIni + 1))
	endif
next i

for nX:=1 to len(aMatSix)

	cCampo := upper(allTrim(aMatSix[nX]))

	if cCampo <> cCmpFil

		cCampo := strTran(strTran(strTran(cCampo,'DTOS',''),')',''),'(','')

		if (nPos := aScan(aMatCab,{|x| allTrim(x) = cCampo }))>0

			if (nPosI := (cAlias)->(fieldPos(cCampo)))>0

				cConteudo := retType(cAlias,nPosI,allTrim(aMatLine[nPos]),.t.)

				cChave += cConteudo + space( (cAlias)->(tamSx3(cCampo)[1])-len(cConteudo) )
			endIf
		else
			exit
		endIf

	endIf
next

return(cChave)


/*/{Protheus.doc} setTro
Inclui registro na matriz de troca

@author Alexander Santos
@since 25/09/14
@version 1.0
/*/
static function setTro(aMatTro,aMatCab,cCampo,cConteudo,cConCat)
local nPos := 0
default cConCat := ''

if (nPos := aScan(aMatCab,{|x| upper(cCampo) $ x }))>0
	aadd(aMatTro,{nPos,cConteudo,cConCat})
endIf

return


/*/{Protheus.doc} recDad
Gravacao dos dados no alias correspondete

@author Alexander Santos
@since 25/09/14
@version 1.0
/*/
static function recDad(cAlias,aMatCab,aMatLine,aMatTro,aMatSix)
local nI,nX		:= 0
local nPos		:= 0
local cAuxCmp	:= ''
local cCampo	:= ''
local cConteudo	:= ''
local cFilTab	:= ''
local cFilOld	:= nil
local cCmpFil 	:= iIf(left(cAlias,1) == 'S',right(cAlias,2)+"_FILIAL",cAlias+"_FILIAL")
local cChaveIdx	:= ''

//troca conteudo
for nI:=1 to len(aMatTro)
	if aMatTro[nI,1]>0
		//parte inicial do codigo e a operadora
		if !empty(aMatTro[nI,3])
			aMatLine[aMatTro[nI,1]] := aMatTro[nI,2] + right(aMatLine[aMatTro[nI,1]],4)
		else
			aMatLine[aMatTro[nI,1]] := aMatTro[nI,2]
		endIf
	endIf
next

//Retorna chave do idx 1
cChaveIdx := retCHK(cAlias,aMatCab,aMatLine,aMatSix,cCmpFil)

//inclui o registro para as filiais
for nI:=1 to len(__aRecnoSM0)

	//pega a filial selecionada
	if __aRecnoSM0[nI,len(__aRecnoSM0[nI])]

		cFilTab := xFilial(cAlias,__aRecnoSM0[nI,3])

		//para garantir que a filial selecionada nao e compartilhada
		if cFilTab == cFilOld
			loop
		else
			cFilOld := cFilTab
		endIf

	else
		loop
	endIf

	//verifica se o registro existe
	(cAlias)->(dbSetOrder(Iif(cAlias$"B7B;BCM",2,1)))
	lFound := (cAlias)->(msSeek(cFilTab+cChaveIdx))
	
	if __lUpdateBase .or. !lFound
		//gravacao dos dados
		(cAlias)->(recLock( cAlias, !lFound ) )

			//Filial
			if (nPos := (cAlias)->(fieldPos(cCmpFil)))>0
				(cAlias)->(fieldPut(nPos,cFilTab))
			endIf
			//Outros Campos
			for nX:=1 to len(aMatCab)
				cCampo := allTrim(aMatCab[nX])

				//tratamento para campos concatenados
				if cCampo != cAuxCmp
					cAuxCmp 	:= cCampo
					cConteudo 	:= allTrim(aMatLine[nX])
				else
					cConteudo 	+= ', ' + allTrim(aMatLine[nX])
				endIf

				if !empty(cConteudo)

					//seta campo
					if (nPos := (cAlias)->(fieldPos(cCampo)))>0

						cConteudo := retType(cAlias,nPos,cConteudo)

						(cAlias)->(fieldPut(nPos,cConteudo))
					endIf
				endIf
			next
		(cAlias)->(msUnlock())
	endIf
next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} retType
Converte conteudo conforme o type

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function retType(cAlias,nPos,cConteudo,lString)
local xConteudo := ''
default lString := .f.

if valType((cAlias)->(fieldGet(nPos))) == 'N'
	xConteudo :=  iIf(!lString,val(cConteudo),cConteudo)
elseIf	 valType((cAlias)->(fieldGet(nPos))) == 'D' .and. at('/',cConteudo)>0
	xConteudo := dtos(cTod(cConteudo))
elseIf	 valType((cAlias)->(fieldGet(nPos))) == 'L'
	xConteudo := iIf(cConteudo=='TRUE' .or. cConteudo=='VERDADEIRO' ,.t.,.f.)
elseIf !empty(cConteudo)
	xConteudo := decodeUTF8(cConteudo)

	//DecodeUTF8 retornou nil
	if xConteudo == nil .or. empty(xConteudo)
		xConteudo := FwNoAccent(cConteudo)
	else
		xConteudo := FwNoAccent(xConteudo)
	endIf

endIf

return(xConteudo)

//-------------------------------------------------------------------
/*/{Protheus.doc} carIni
Carrega ini exemplo

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function carIni()
local nH		:= 0
local nTamanho	:= 0
local cFile		:= 'exmplo-ini-portal-tissonline-roboxml.txt'
local cIni		:= STR0092//'Arquivo indisponivel no momento'

//abre arquivo de ini
if file(__WIZFILE+cFile)
   if (nH := fOpen(__WIZFILE+cFile) ) != -1
		nTamanho := fSeek(nH,0,2)

		fSeek(nH,0,0)
		fRead(nH, @cIni, nTamanho)
   endIf
   fClose(nH)
endIf

return(cIni)

//-------------------------------------------------------------------
/*/{Protheus.doc} getBA0
Verifica se existe operadora e carrega

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function getBA0(lAuto)
local nPos 		:= 0
local lRet 		:= .f.
local cOldReg	:= ''
local cSql		:= ''
Local cOpePAD	:= PLSINTPAD() //Pegamos a operadora padrão do usuário
Local aOpePAD	:= {}	//Array para guardar os dados da operadora padrão
default lAuto	:= .F.

cSql := " SELECT * FROM " + BA0->(RetSQLName("BA0"))
cSql += "  WHERE "
cSql += " BA0_FILIAL = '" + xFilial("BA0") + "' AND "
cSql += " D_E_L_E_T_ = ' ' "
if lAuto
	cSql += " AND BA0_CODIDE+BA0_CODINT = '" + cOpePAD + "'"
endif
cSql += " ORDER BY BA0_CODIDE,BA0_CODINT "

cSql := PLSConSQL(cSql)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbBA0",.F.,.T.)   

if !TrbBA0->( TrbBA0->( eof() ) )

	lRet := .t.
	while !TrbBA0->(eof())

		//alimenta dados da BA0
		__cCodOpe	:= TrbBA0->(BA0_CODIDE+BA0_CODINT)
		__cNomOpe	:= TrbBA0->BA0_NOMINT
		__cCNPJ		:= TrbBA0->BA0_CGC
		__cRegAns	:= TrbBA0->BA0_SUSEP

		//nao existe o arquivo csv de abrangencia
		if len(__aMatAbr) == 0
			BA2->(dbSetOrder(1))//BA2_FILIAL+BA2_GRUOPE
			if BA2->(msSeek(xFilial('BA2')+TrbBA0->BA0_GRUOPE))
				aadd(__aMatAbr,allTrim(BA2->BA2_DESCRI))
			endIf
		endIf

		//nao existe o arquivo de modalidade
		if len(__aMatMod) == 0
			BTZ->(dbSetOrder(1))//BTZ_FILIAL+BTZ_CODIGO
			if BTZ->(msSeek(xFilial('BTZ')+TrbBA0->BA0_MODOPE))
				aadd(__aMatMod,allTrim(BTZ->BTZ_DESCRI))
			endIf
		endIf

		nPos := val(TrbBA0->BA0_GRUOPE)

		if nPos>0 .and. nPos <= len(__aMatAbr)
			__cAbrange	:= __aMatAbr[nPos]
		endIf

		nPos := val(TrbBA0->BA0_MODOPE)

		if nPos>0 .and. nPos <= len(__aMatMod)
			__cModOpe	:= __aMatMod[nPos]

			if 'ODONTO' $ upper(__cModOpe)
				__lOdonto := .t.
			endIf
		endIf

		if !__lOdonto

			BCJ->(dbSetOrder(1))//BCJ_FILIAL+BCJ_CODOPE+BCJ_TIPSER

			__lOdonto := BCJ->(msSeek(xFilial('BCJ')+__cCodOpe+'02'))

		endIf

		if !__lTiss

			BTP->(dbSetOrder(1))//BTP_FILIAL+BTP_CODTAB

			__lTiss := BTP->(msSeek(xFilial('BTP')))

		endIf


		//verifica se nao e mesma operadora com filial diferente
		if !empty(cOldReg)

			if __cCodOpe+__cNomOpe+__cCNPJ+__cRegAns+__cAbrange+__cModOpe+iif(__lOdonto,STR0057,STR0058)+;
				iif(__lTiss,STR0057,STR0058)+iif(__lPortal,STR0057,STR0058)+iif(__lDemo,STR0057,STR0058) == cOldReg

				TrbBA0->(dbSkip())
				loop
			endIf

			setNew(nil,.f.,.f.)
		endIf

		cOldReg := __cCodOpe+__cNomOpe+__cCNPJ+__cRegAns+__cAbrange+__cModOpe+iif(__lOdonto,STR0057,STR0058)+iif(__lTiss,STR0057,STR0058)+iif(__lPortal,STR0057,STR0058)+iif(__lDemo,STR0057,STR0058)

		setCon('CODOPE',__cCodOpe,STR0019,"@R !.!!!",030) //"Código"
		setCon('NOMINT',__cNomOpe,STR0020,"@C",160)//"Nome"
		setCon('CNPJ',__cCNPJ,STR0021,"@R 99.999.999/9999-99",070) //"CNPJ"
		setCon('REGISTROANS',__cRegAns,STR0022,"999999",050) //"Registro ANS"
		setCon('ABRANGENCIA',__cAbrange,STR0026,"@C",080)//"Abrangência"
		setCon('MODALIDADEOPERADORA',__cModOpe,STR0027,"@C",100)//"Modalidade"
		setCon('ODONTO',iif(__lOdonto,STR0057,STR0058),STR0053,"@!",040) //"Odontologia"##'SIM'##'NAO'
		setCon('TISS',iif(__lTiss,STR0057,STR0058),STR0054,"@!",040) //"Tiss/Guias"##'SIM'##'NAO'
		setCon('PORTAL',iif(__lPortal,STR0057,STR0058),STR0055,"@!",040) //"Portal"##'SIM'##'NAO'
		setCon('DEMO',iif(__lDemo,STR0057,STR0058),STR0056,"@!",040) //"Demonstração"##'SIM'##'NAO'

		//para verificar se pode ou nao alterar os dados
		aadd(__aMatBase,__cCodOpe)
		
		If !(EmpTy(cOpePAD)) .AND. __cCodOpe == cOpePAD //Se for a operadora padrão, guardamos os dados

			Aadd(aOpePad, getCon('CODOPE') )
			Aadd(aOpePad, getCon('NOMINT') )
			Aadd(aOpePad, getCon('CNPJ') )
			Aadd(aOpePad, getCon('REGISTROANS') )
		
			Aadd(aOpePad, getCon('ABRANGENCIA') )
			Aadd(aOpePad, getCon('MODALIDADEOPERADORA') )
		
			Aadd(aOpePad, getCon('ODONTO') == STR0057 )//'SIM'
			Aadd(aOpePad, getCon('TISS') == STR0057 )//'SIM'
			Aadd(aOpePad, getCon('PORTAL') == STR0057 )//'SIM'
			Aadd(aOpePad, getCon('DEMO') == STR0057 )//'SIM'		
		
		EndIf

	TrbBA0->(dbSkip())
	endDo

	__nLinBrw	:= 1
	If !EmpTy(aOpePad) //Se guardamos os dados, usamos eles pra apresentar a operadora do cara na primeira tela
		__cCodOpe 	:= aOpePad[1]
		__cNomOpe 	:= aOpePad[2]
		__cCNPJ 	:= aOpePad[3]
		__cRegAns 	:= aOpePad[4]
	
		__cAbrange	:= aOpePad[5]
		__cModOpe	:= aOpePad[6]
	
		__lOdonto	:= aOpePad[7]
		__lTiss	:= aOpePad[8]
		__lPortal	:= aOpePad[9]
		__lDemo	:= aOpePad[10]	
	else
		__cCodOpe 	:= getCon('CODOPE')
		__cNomOpe 	:= getCon('NOMINT')
		__cCNPJ 	:= getCon('CNPJ')
		__cRegAns 	:= getCon('REGISTROANS')
	
		__cAbrange	:= getCon('ABRANGENCIA')
		__cModOpe	:= getCon('MODALIDADEOPERADORA')
	
		__lOdonto	:= getCon('ODONTO') == STR0057 //'SIM'
		__lTiss		:= getCon('TISS') == STR0057 //'SIM'
		__lPortal	:= getCon('PORTAL') == STR0057 //'SIM'
		__lDemo		:= getCon('DEMO') == STR0057 //'SIM'
	EndIf

endIf

TrbBA0->( dbCloseArea() )

return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} getPGM
Retorna a pocisao do combo comforme o conteudo. abrangencia e modalidade

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function getPGM(aMat,cConteudo)
local cRet := ''

cRet := strZero(aScan(aMat,{|x| upper(x) == upper(cConteudo)}),2)

return(cRet)

//---------------------------------------------------------------------------------
/*/{Protheus.doc} getMSGVld
Retorna mensagem e nao deixa fechar a tela

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//---------------------------------------------------------------------------------
static function getVld()

msgAlert(STR0093) //'Necessário concluir o processo do WIZARD para que todas as tabelas do modulo sejam populadas !'

return(__lExec)


//-------------------------------------------------------------------
/*/{Protheus.doc} getAltera()
Verifica se pode alterar os dados

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function getAltera()
local lRet := (aScan(__aMatBase,{|x| x == __cCodOpe}))==0

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} isNumeric
Funcao para verificar que uma string contém somente números

@author  PLS TEAM
@version P11
@since   25/08/2014
/*/
//-------------------------------------------------------------------
static function isNumeric(xValue)
local nInd := 0
local cAux := ''
local lRet := .t.

if !(valtype(xValue) == "N")
	for nInd := 1 to len(xValue)

		cAux := substr(xValue, nInd, 1)

		if !isDigit(cAux)
			lRet := .f.
			exit
		endif
	next
endIf

if !lRet
	apMsgStop(STR0094)//'Conteudo não é numerico'
endIf

return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PLCOPYCS
Rotina para copiar arquivos do cliente para o servidor e vice versa.

@author  Romulo Ferrari
@version P12
@since   03/03/2011
/*/
//-------------------------------------------------------------------
Function PLCOPYCS
LOCAL oRadio
LOCAL oDlg
LOCAL nRadio	:= 1
LOCAL nOpca		:= 0
Local aRet		:= {}

DEFINE MSDIALOG oDlg FROM 0,0 TO 80,227 PIXEL TITLE STR0108 //"Copiar arquivos..."
@ 001,003 TO 040,080 LABEL STR0117 OF oDlg PIXEL //"Copiar do..."
@ 008,008 RADIO oRadio VAR nRadio 3D SIZE 160,009 ITEMS STR0109,STR0110 PIXEL OF oDlg //"Terminal para Servidor" - "Servidor para Terminal"

DEFINE SBUTTON FROM 003,084 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
DEFINE SBUTTON FROM 020,084 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

If nOpca == 1
	aRet	:= CopyFile(nRadio)
	If aRet[1]
		MsgAlert(STR0111 + CRLF+ ; //Arquivo(s) copiado(s) com sucesso!
				 STR0118 + CRLF +; //De:
				 aRet[2] + CRLF + ;  
				 STR0119 + CRLF + ; //Para:
				 aRet[3] )
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CopyFile
Realiza a cópia dos arquivos
@version P12
@since   03/2011
/*/
//-------------------------------------------------------------------
Static Function CopyFile(nRadio, cOrigem, cDestino)
local aArqDir	:= {}
local cNomeArq	:= ""
local cArqOri 	:= cOrigem
local cArqDes 	:= cDestino
local lOk 		:= .T.
local lLogFile	:= iif(nRadio == 1, .f., .t.)
local lImpWiz	:= iif( (nRadio == 0 .and. !empty(cDestino) ), .t., .f.)
local nFor		:= 0
local nTamArq	:= 0

if nRadio != 0
	cArqOri := cGetFile(STR0104, STR0105,0,"",.T., GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD, lLogFile)//"Todos Arquivos|*.*|"
	cArqDes := cGetFile(STR0104, STR0106,0,"",.F., GETF_RETDIRECTORY + iif(lLogFile, GETF_LOCALHARD, 0), !lLogFile)
endif

If !lImpWiz .and. Empty(cArqDes) .Or. Empty(cArqOri)
	If MakeDir( cArqDes ) <> 0
		MsgStop(STR0100 + cArqDes + STR0107) //Diretório / não encontrado e não foi possível criá-lo.
		lOk := .F.
	Endif
EndIf

if !lImpWiz .and. lOK
	if !( __CopyFile( cArqOri , cArqDes + substr(cArqOri, rat(PLSMUDSIS("\"), cArqOri), len(cArqOri)) ) )
		MsgStop(STR0112 + cArqOri + STR0116 + cArqDes + "]") //"Não foi possível copiar o arquivo de [" - "] para ["
		lOk := .F.
	endif
endif

if lImpWiz
	if empty(cArqOri)
		MsgAlert(STR0121, STR0049) //Atenção - Informe o local de origem, onde estão os arquivos .csv para cópia.     			
	elseif msgYesNo(STR0125 + cArqDes + " ?") //"Deseja mesmo copiar o(s) arquivo(s) para a pasta "
		aArqDir := PlArqCSVT(cArqOri, "*.csv", @nTamArq)

		if nTamArq > 0
			for nFor := 1 to nTamArq
				Processa( { || lOk := __CopyFile( cArqOri + aArqDir[nFor,1], cArqDes + aArqDir[nFor,1] ) }, STR0113, STR0114, .F. )	//Realizando cópia.... - Aguarde o processo finalizar
				cNomeArq += aArqDir[nFor,1] + iif(!lOk, " - *" + STR0115 + cvaltochar(ferror()), "") + CRLF //Erro:
			next
			MsgAlert(cNomeArq, STR0111) //Arquivo(s) copiado(s) com sucesso!
		else
			MsgAlert(STR0126, STR0049) //"Não existe(m) arquivo(s) .csv na pasta indicada. Verifique ou informe outro diretório." 	
		endif
	endif
endif

Return {lOk,cArqOri,cArqDes}


static function PlArqCSVT(cCaminho, cTipoArq, nTamRef)
local aArqDir		:= {}
default nTamRef		:= 0
default cCaminho 	:= ""
default cTipoArq	:= "*.csv"

aArqDir := directory(cCaminho + cTipoArq)
nTamRef := len(aArqDir)

return aArqDir
