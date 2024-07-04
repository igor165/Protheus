#DEFINE CRLF chr( 13 ) + chr( 10 )

#Include "Plsmger.ch"
#Include "Colors.ch"
#Include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"

#DEFINE BASEINSSPF	1
#DEFINE INSSPF		2
#DEFINE BASEINSSPJ	3
#DEFINE INSSPJ		4
#DEFINE VLRFATURA	5
#DEFINE SALCONTRIB	6
#DEFINE PROLAB   	7
#DEFINE INSSPROLAB 	8

static cSemana := ""
static cPerRGB := ""
static lRGB_RES := getNewPar("MV_PLSRGB", .F.)//Parâmetro para manter a gravação no SRC para clientes que não utilizam o SIGAGPE, por motivo de legado
static cVerbaRES := ""
Static lINSSIR := getNewPar("MV_INSIRF","") == "1"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM240
Integração com o Gestão de Pessoal, Financeiro e TAF para geração do e-Social para os autonomos.
S-1200 - Remuneração de trabalhador vinculado ao Regime Geral de Previd. Social

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
function PLSM240() 
local oPanelMain	:= nil
private oBrwPrinc	:= nil
private aRet		:= {}	

BBC->(dbsetorder(1))
B5E->(dbsetorder(1))

if lRGB_RES
	RGB->(dbsetorder(1))
	if RGB->(FieldPos("RGB_LOTPLS")) <= 0 .or. RGB->(FieldPos("RGB_CODRDA")) <= 0
		Final("Necessário atualizar dicionário de dados. Campo(s): ", " [RGB_LOTPLS, RGB_CODRDA].")
	endif
endif 

//--< Browse Principal >---
oBrwPrinc := FWMBrowse():New()
oBrwPrinc:SetOwner( oPanelMain )
oBrwPrinc:SetDescription( "e-Social - Plano de Saúde" )
oBrwPrinc:SetAlias( "B5E" )
oBrwPrinc:SetMenuDef( "PLSM240" )
oBrwPrinc:DisableDetails()
oBrwPrinc:ForceQuitButton()
oBrwPrinc:SetProfileID( '0' )
oBrwPrinc:SetWalkthru( .F. )
oBrwPrinc:SetAmbiente( .F. )

oBrwPrinc:addLegend( "B5E_STATUS == '1'", "GREEN",	"Processado " )

oBrwPrinc:Activate()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function MenuDef()
local aRotina := {}
	
	ADD OPTION aRotina Title 'Processar '	Action 'PLSM240PRO()'	OPERATION MODEL_OPERATION_INSERT ACCESS 0	
	ADD OPTION aRotina Title 'Detalhar'		Action 'msgRun( "Abrindo janela de detalhes...","Processando, por favor aguarde",PLSM240Det()   )'	OPERATION MODEL_OPERATION_VIEW ACCESS 0	
	ADD OPTION aRotina Title 'Excluir'		Action 'Processa({||PLSM240EXC()},"e-Social - Exclusao","Processando...",.T.)'	OPERATION MODEL_OPERATION_DELETE ACCESS 0	
		
return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function ModelDef()
local oStruB5E := FWFormStruct( 1,'B5E',/*bAvalCampo*/,/*lViewUsado*/ )
local oModel

//--< DADOS DO LOTE >---
oModel := MPFormModel():New( 'e-Social - Plano de Saúde' )
oModel:AddFields( 'MODEL_B5E',,oStruB5E )
	
oModel:SetDescription( "e-Social - Plano de Saúde" )
oModel:GetModel( 'MODEL_B5E' ):SetDescription( ".:: e-Social - Plano de Saúde ::." )
oModel:SetPrimaryKey( { "B5E_FILIAL","B5E_SUSEP","B5E_CMPLOT","B5E_NUMLOT","B5E_NMAREN" } )

return oModel
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function ViewDef()
local oView     := nil
local oModel	:= FWLoadModel( 'PLSM240' )
	
oView := FWFormView():New()
oView:SetModel( oModel )
return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM240Det
Monta janela PLSM240Det - Detalhes do arquivo

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
function PLSM240Det

local oBrwMovim	
local oPanelMain 
local aSize		:= {}
local aObjects	:= {}
local aInfo		:= {}
local aPosObj	:= {}
Local acampos 	:= {}
local aCoors	:= FWGetDialogSize( oMainWnd )

private oDlgSec

Detalhe()

Define MsDialog  oDlgSec TITLE ".:: e-Social - Movimentos ::." FROM aCoors[ 1 ], aCoors[ 2 ] TO aCoors[ 3 ], aCoors[ 4 ] PIXEL

//--< Define tamanho das abas superiores >---
aSize := msAdvSize()

aadd( aObjects,{ 100,100,.T.,.T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := msObjSize( aInfo,aObjects,.T. )

//--< Montagem da tela principal >---
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgSec,.F.,.T. )
oFWLayer:AddLine( 'LINE', 100, .F. )
oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
oPanelMain := oFWLayer:GetColPanel( 'COL', 'LINE' )

//--< Painel Superior - Contratos >---
oBrwMovim := FWMBrowse():New()
oBrwMovim:SetOwner( oPanelMain )
oBrwMovim:SetDescription( "Movimentos" )
oBrwMovim:SetAlias( "M240DET"  )

aadd(acampos, { "Matrícula" 		, "MATRICULA" })
aadd(acampos, { "Nome Funcionário" 	, "NOMMAT" })
aadd(acampos, { "Verba"   			, "VERBA"})
aadd(acampos, { "Descrição Verba  " , "DESVER"})
aadd(acampos, { "Valor Folha"		, "VALOR", ,"@E 9,999,999.99" })
aadd(acampos, { "Centro Custo"  	, "CCUSTO"})
aadd(acampos, { "Descrição C.Custo"	, "DESCUS"})
aadd(acampos, { "Semana"  			, "SEM"})
aadd(acampos, { "Período" 			, "PER"})
aadd(acampos, { "Processo"			, "PROCESSO"})
aadd(acampos, { "Roteiro" 			, "ROT"})
aadd(acampos, { "Alias"   			, "TABELA"})

oBrwMovim:setFields(acampos)
oBrwMovim:SetMenuDef( '' )
oBrwMovim:DisableDetails()
oBrwMovim:SetProfileID( '1' )
oBrwMovim:SetWalkthru( .F. )
oBrwMovim:SetAmbiente( .F. )
oBrwMovim:ForceQuitButton()
oBrwMovim:Activate()	

Activate MsDialog oDlgSec Center

M240DET->(dbcloseArea())
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grava
Grava os dados no padrão MVC

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function grava( nOpc,aCampos,cModel,cLoadModel )
local oAux
local oStruct
local oModel
local aAux
local aErro

local nI
local nPos

local lRet := .T.

oModel := FWLoadModel( cLoadModel )
oModel:setOperation( nOpc )
oModel:activate()

oAux	:= oModel:getModel( cModel )
oStruct	:= oAux:getStruct()
aAux	:= oStruct:getFields()

if( nOpc <> MODEL_OPERATION_DELETE )
	begin Transaction
		for nI := 1 to len( aCampos )
			if( nPos := aScan( aAux,{| x | AllTrim( x[ 3 ] ) == AllTrim( aCampos[ nI,1 ] ) } ) ) > 0
				if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
					aErro := oModel:getErrorMessage()						
					
						autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
						autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
						autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
						autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
						autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
						autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
					
						mostraErro()
					
					disarmTransaction()
					exit
				endif
			endif
		next nI
	end Transaction
endif		

if( lRet := oModel:vldData() )
	oModel:commitData()
else
	aErro := oModel:getErrorMessage()						
	
		autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
		autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
		autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
		autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
		autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
		autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
	
		mostraErro()	
	
	disarmTransaction()
endif

oModel:deActivate()
oModel:destroy()
freeObj( oModel )
oModel := nil
delClassInf()
return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM240PRO
Processa dados e-Social Plano de Saúde

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
function PLSM240PRO
local cTitulo	:= "Processa dados e-Social Plano de Saúde"
local cTexto	:= CRLF + CRLF + "Esta é a opção que irá efetuar a leitura das tabelas de impostos do PLS," + CRLF +;
								"processar as informações encontradas para a gravação das tabelas da" + CRLF +;
								"Folha com as informações a serem enviadas referente aos autonomos no e-Social."
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
local lEnd		:= .F.
local aRet		:= {}

private _oProc:= nil

if nOpc == 1 .And. pergEnvio(aRet)
	
	_oProc := MsNewProcess():New({|| PLESOCIAL( @lEnd, aRet ) },"Aguarde","Processando...",.F.)
    _oProc:Activate()
	
endif

return
	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pergEnvio
Perguntas para processamento

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function pergEnvio(aRet)
local lRet			:= .F.
local aPergs		:= {}
local aLocDig		:= {}
local cOperadora	:= space( 04 )
local cAno			:= space( 04 )
local cMes			:= space( 02 )
local cRDADe		:= space( 06 )
local cRDAAte		:= space( 06 )
local cProtDe		:= space( 08 )
local cProtAte		:= space( 08 )
local cFPAS			:= space( 03 )
local cTerFPAS		:= space( 04 )
local cLocNew		:= ""	
local nX			:= 1

private cLocDig		:= space( 250 ) // Necessário ser private pois eh utilizado no CONPAD1

aadd(/*01*/ aPergs,{ 1,"Operadora",cOperadora,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } )
aadd(/*02*/ aPergs,{ 1,"Ano Competência",cAno,"@R 9999",'.T.',,/*'.T.'*/,40,.T. } )
aadd(/*03*/ aPergs,{ 1,"Mês Competência",cMes,"@R 99",'.T.',,/*'.T.'*/,40,.T. } )
aadd(/*04*/ aPergs,{ 1,"RDA De",cRDADe,"@!",'.T.','BAUPLS',/*'.T.'*/,40,.F. } )
aadd(/*05*/ aPergs,{ 1,"RDA Até",cRDAAte,"@!",'.T.','BAUPLS',/*'.T.'*/,40,.T. } )
aadd(/*06*/ aPergs,{ 1,"Local Digit",cLocDig,"@!",'.T.','BCGMON',/*'.T.'*/,100,.T. } )
aadd(/*07*/ aPergs,{ 1,"Protocolo De",cProtDe,"@!",'.T.','BC1PLS',/*'.T.'*/,40,.F. } )
aadd(/*08*/ aPergs,{ 1,"Protocolo Até",cProtAte,"@!",'.T.','BC1PLS',/*'.T.'*/,40,.T. } )
aadd(/*09*/ aPergs,{ 1,"Código FPAS",cFPAS,"@!",'.T.','',/*'.T.'*/,40,.F. } )
aadd(/*10*/ aPergs,{ 1,"Cód. Terceiro FPAS",cTerFPAS,"@!",'.T.','',/*'.T.'*/,40,.F. } )
	
if( paramBox( aPergs,"Parâmetros - Processa arquivo de envio ANS",aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM240',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	if validPergEnvio( aRet ) 
		lRet := .T.
	else
		aRet := {}
		lRet := pergEnvio(aRet)
	endif

	if lRet .and. !Empty(aRet[6])
		aLocDig := strtokarr(AllTrim(aRet[6]),",")
		For nX = 1 To Len(aLocDig)
			cLocNew += "'" + aLocDig[nX] + "'"
			if nX <> Len(aLocDig)
				cLocNew += ","
			endif
		Next		
		aRet[6] := "( " + cLocNew + " )"
	endif
endif
	
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validPergEnvio
Valida perguntas para processamento

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function validPergEnvio( aRet )
local nX		:= 0
local lRet		:= .T.
local cMsgErro	:= "Corrija os itens abaixo antes de prosseguir:" + CRLF + CRLF
local aArea		:= {}
local cRoteiro  := "AUT"
local cPeriodo  := ""
local cProcesso := "00003"
local aPerAtual := {}
default aRet	:= {}
	
	for nX:=1 to len( aRet )
		if( nX == 1 )
			aArea := getArea()
			
			BA0->( dbsetorder( 1 ) )
			if!( BA0->( dbSeek( xFilial( "BA0" ) + AllTrim( aRet[ 1 ] ) ) ) )
				lRet		:= .F.
				cMsgErro += " - Parâmetro 'Operadora' não cadastrado;" + CRLF
			endif
			
			restArea( aArea )
		elseif( nX == 2 .and. !empty( aRet[ 2 ] ) .and. len( AllTrim( aRet[ 2 ] ) ) < 4 )
			lRet		:= .F.
			cMsgErro += " - Parâmetro 'Ano Competência' preenchido incorretamente;" + CRLF
		elseif( nX == 3 .and. !empty( aRet[ 3 ] ) .and. !AllTrim( strZero( val( aRet[ 3 ] ),2 ) ) $ "01|02|03|04|05|06|07|08|09|10|11|12" )
			lRet		:= .F.
			cMsgErro += " - Parâmetro 'Mês Competência' preenchido incorretamente;" + CRLF
		endif
	next nX
	
	// Encontra o periodo e verifica se esta ativo
	if fGetPerAtual(@aPerAtual, xFilial( "RCH" ), cProcesso, cRoteiro) .And. aPerAtual[1][1] >= (aRet[2]+aRet[3])
		cPeriodo	:= aPerAtual[1][1]
		cSemana		:= aPerAtual[1][2]
		dData 		:= aPerAtual[1][7]
		cPerRGB := cPeriodo
		// Verifica se o período não se encontra bloqueado
		if !fVldAccess(xFilial(B5E->B5E_ALIAS), dData, cSemana,.F., cRoteiro, "3", "V") 	
			cMsgErro += " -Período se encontra bloqueado;" + CRLF
			lRet		:= .F.
		endif
	else
		cMsgErro += " -Período informado não esta cadastrado ou já foi fechado;" + CRLF
		lRet		:= .F.
	endif
	
	BLR->(DbSetOrder(1))
	If !BLR->(MsSeek(xfilial("BLR") + PLSINTPAD() + "110")) .OR. empTy(BLR->BLR_VERBA)
		PLSCRIABLR(PLSINTPAD())
		cMsgerro += " - Não há verba vinculada ao tipo de lançamento 1 10 (sistema 10) " + CRLF
		cMsgErro += " Necessário atualizar o Cadastro de Tipo de Lançamento; " + CRLF
		lRet := .F.
	else
		cVerbaRES := BLR->BLR_VERBA
	endIf
	
	if( !lRet )
		alert( cMsgErro )
	endif
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLESOCIAL
Realiza o processamento das tabelas BMR, BAU e SRA

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
function PLESOCIAL(lEnd, aRet, lAutoma)
local cSql 		:= ""
local cNumLote	:= ""
local cVerba	:= ""
local cSqlBD7 	:= ""
local lPL240LAN	:= existblock("PL240LAN")
local cAliasBMR	:= GetNextAlias()
local nRegua	:= 0
local nRegPro	:= 0
local nQtd		:= 0
local nTot101	:= 0
local nL		:= 0
local aCriticas	:= {}
local aPerAber	:= {}
local aPerFech	:= {}
local aNvl		:= {}
local aValorProv := {}
local aValorDesc := {}
local cRDAant    := ""
local cVlLiqSRV	 := ""
local cInsSldSRV := ""
local cDtRef	 := ""
DEFAULT lAutoma	:= .F.

// Deleta itens da SEFIP para não haver divergencias
PLSA825DEL()

//--Retorna RV_COD - Liquido da Folha
cSql := " SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_FILIAL = '" + xFilial("SRV") + "' AND D_E_L_E_T_ = ' ' and RV_CODFOL = '0047' "
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"LiqSRV",.F.,.T.)
if ! LiqSRV->(EoF())
	cVlLiqSRV := LiqSRV->(RV_COD)	
else
	cVlLiqSRV := "751"
endif
LiqSRV->(dbCloseArea())

//--Retorna RV_COD - Insuficiencia da Saldo
cSql := " SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_FILIAL = '" + xFilial("SRV") + "' AND D_E_L_E_T_ = ' ' and RV_CODFOL = '0045' "
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PendSRV",.F.,.T.)
if ! PendSRV->(EoF())
	cInsSldSRV := PendSRV->(RV_COD)
else
	cInsSldSRV := "256"
endif
PendSRV->(dbCloseArea())

cSql := " SELECT BMR_OPERDA, BMR_CODRDA, BMR_CODLAN, BMR_VLRPAG, BMR.R_E_C_N_O_ Recno, BMR_LOTB5E, "
cSql += " BAU_NOME, BAU_INSS, BAU_COPCRE, BAU_FILFUN, BAU_MATFUN, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT, "
cSql += " RA_CC, RA_PROCES, BAU_CALIMP, BMR_DEBCRE, RA_ITEM, RA_CLVL, BMR_OPELOT, RA_CODFUNC, RA_DEMISSA " 
cSql += " FROM " + RetSqlName("BMR") + " BMR "
cSql += " INNER JOIN " + RetSQLName("BAU") + " BAU "
cSql += " ON  BAU_FILIAL = '" + xFilial("BAU") + "' "
cSql += " AND BAU_CODIGO = BMR_CODRDA "
cSql += " AND BAU.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSQLName("SRA") + " SRA "
cSql += " ON RA_FILIAL = BAU_FILFUN "
cSql += " AND SRA.D_E_L_E_T_ = ' ' "
cSql += " AND RA_MAT = BAU_MATFUN "
cSql += " WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
cSql += " AND (BMR_CODRDA >= '" + aRet[4] + "' "
cSql += " AND BMR_CODRDA <= '" 	+ aRet[5] + "') "
cSql += " AND BMR_ANOLOT = '" 	+ aRet[2] + "' "
cSql += " AND BMR_MESLOT = '" 	+ aRet[3] + "' "
cSql += " AND BMR_LOTB5E = ' ' "
cSql += " AND BMR.D_E_L_E_T_ = ' ' "
cSql += " Order By BMR_CODRDA "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasBMR,.F.,.T.)

nRegua := Contar(cAliasBMR,"!Eof()")
if !lAutoma
	_oProc:SetRegua1(nRegua)
endif
(cAliasBMR)->(dbGoTop())

if nRegua > 0	
	cNumLote	:= getNumLote(aRet[2]+aRet[3], aRet[1], @aPerAber, @aPerFech, (cAliasBMR)->RA_PROCES)
else	
	MsgAlert("Nenhum registro encontrado.")
endif

SE2->(dbsetorder(12))	// E2_FILIAL, E2_PLOPELT, E2_PLLOTE, E2_NOMFOR
BLR->(dbsetorder(1))
BLS->(dbsetorder(1))
BA3->(dbsetorder(1))	// BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB                                                                         
CTT->(dbsetorder(1))	// CTT_FILIAL+CTT_CUSTO                                                                        

while !(cAliasBMR)->(Eof())
	nRegPro++
	cVerba	:= ""
	if !lAutoma
		_oProc:IncRegua1(AllTrim(Str(nRegPro)) +"/"+ AllTrim(Str(nRegua)) + " registros processados ")
	endif
	if lEnd 		
		Alert( 'Execução cancelada pelo usuário.' )
		Exit
	endif
	if empty((cAliasBMR)->BMR_CODLAN) 
		aadd(aCriticas,{"Código de Lançamento não preenchido",(cAliasBMR)->BMR_CODRDA,(cAliasBMR)->BMR_CODLAN,(cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})
		loop
	endif	

	cRDAant 	:= (cAliasBMR)->BMR_CODRDA
	cProcSRV 	:= (cAliasBMR)->RA_PROCES 
 	cCenSRV		:= (cAliasBMR)->RA_CC
 	cFFunSRV	:= (cAliasBMR)->BAU_FILFUN
 	cMFunSRV	:= (cAliasBMR)->BAU_MATFUN
 	
	if SE2->(msseek(xfilial("SE2") + (cAliasBMR)->(BMR_OPELOT + BMR_ANOLOT + BMR_MESLOT + BMR_NUMLOT )))
		cDtRef := dtos(SE2->E2_VENCTO)
	elseif len(aPerFech) > 0 .and. valtype(aPerFech[1][6]) == 'D'
		cDtRef := dtos(aPerFech[1][6])
	endif

	Do Case
		// Producao Medica - Contas Médicas
		Case (cAliasBMR)->BMR_CODLAN == "101"		
			cVerba := getVerbaGen(cAliasBMR)
			If !(empTy(cVerba))
				gravaGPE(cVerba, (cAliasBMR)->BMR_VLRPAG, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef)
				fAddVal(cDtRef,(cAliasBMR)->BMR_VLRPAG, @aValorProv, @aValorDesc )			
			else
				aadd(aCriticas,{"Verba não cadastrada(Nivel [BLS][BLR])",(cAliasBMR)->BMR_CODRDA, (cAliasBMR)->BMR_CODLAN, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})
			endif		

		// Debitos mensais fixos - Cadastro da RDA
		Case (cAliasBMR)->BMR_CODLAN == "102"
			cSqlBGQ := "SELECT BGQ_CODLAN, BGQ_VALOR, BGQ_VERBA, BBB_VERBA "			
			cSqlBGQ += " FROM "+RetSQLName("BGQ")+" BGQ "
			cSqlBGQ += " INNER JOIN "+RetSQLName("BBB")+" BBB "
			cSqlBGQ += " ON BBB_FILIAL = BGQ_FILIAL "
			cSqlBGQ += " AND BBB_CODSER = BGQ_CODLAN "
			cSqlBGQ += " AND BBB_TIPSER = '1' " // Débitos
			cSqlBGQ += " AND BBB.D_E_L_E_T_ = ' '  "
			cSqlBGQ += " WHERE BGQ_FILIAL = '"+xFilial("BGQ")+"'   "
			cSqlBGQ += " AND BGQ_CODIGO = '"+(cAliasBMR)->BMR_CODRDA+"'   "
			cSqlBGQ += " AND BGQ_CODOPE = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_OPELOT = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_NUMLOT = '"+(cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)+"'  "
			cSqlBGQ += " AND BGQ_ATIVO <> '0' "
			cSqlBGQ += " AND BGQ_TIPO   = '1'  "		
			cSqlBGQ += " AND BGQ_NUMLAU = 'BBC" + Space(TamSX3("BGQ_NUMLAU")[1] - 3) + "' "	
			cSqlBGQ += " AND BGQ.D_E_L_E_T_ = ' '  "

			cSqlBGQ := ChangeQuery(cSqlBGQ)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBGQ),"TrbBGQ",.F.,.T.)

			while !TrbBGQ->(eof())
				if !empty(TrbBGQ->BGQ_VERBA)
					gravaGPE(TrbBGQ->BGQ_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)					
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorDesc, @aValorProv)	
				elseif !empty(TrbBGQ->BBB_VERBA)
					gravaGPE(TrbBGQ->BBB_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorDesc, @aValorProv)	
				else
					cVerba := getVerbaGen(cAliasBMR)
					if empty(cVerba)
						aadd(aCriticas,{"Verba não cadastrada(Nivel [BBB][BLS][BLR])",(cAliasBMR)->BMR_CODRDA, TrbBGQ->BGQ_CODLAN, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})	
					else
						gravaGPE(cVerba, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
						fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorDesc, @aValorProv)	
					endif						
				endif
				TrbBGQ->(dbskip())
			enddo
			TrbBGQ->(dbclosearea())

		// Créditos mensais fixos - Cadastro da RDA 
		Case (cAliasBMR)->BMR_CODLAN == "103"
			cSqlBGQ := "SELECT BGQ_CODLAN, BGQ_VALOR, BGQ_VERBA, BBB_VERBA "			
			cSqlBGQ += " FROM "+RetSQLName("BGQ")+" BGQ "
			cSqlBGQ += " INNER JOIN "+RetSQLName("BBB")+" BBB "
			cSqlBGQ += " ON BBB_FILIAL = BGQ_FILIAL "
			cSqlBGQ += " AND BBB_CODSER = BGQ_CODLAN "
			cSqlBGQ += " AND BBB_TIPSER = '2' " // Crédito
			cSqlBGQ += " AND BBB.D_E_L_E_T_ = ' '  "
			cSqlBGQ += " WHERE BGQ_FILIAL = '"+xFilial("BGQ")+"'   "
			cSqlBGQ += " AND BGQ_CODIGO = '"+(cAliasBMR)->BMR_CODRDA+"'   "	
			cSqlBGQ += " AND BGQ_CODOPE = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_OPELOT = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_NUMLOT = '"+(cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)+"'  "
			cSqlBGQ += " AND BGQ_ATIVO <> '0' "
			cSqlBGQ += " AND BGQ_TIPO   = '2'  "	
			cSqlBGQ += " AND BGQ_NUMLAU = 'BBC" + Space(TamSX3("BGQ_NUMLAU")[1] - 3) + "' "			
			cSqlBGQ += " AND BGQ.D_E_L_E_T_ = ' '  "

			cSqlBGQ := ChangeQuery(cSqlBGQ)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBGQ),"TrbBGQ",.F.,.T.)

			while !TrbBGQ->(eof())
				if !empty(TrbBGQ->BGQ_VERBA)
					gravaGPE(TrbBGQ->BGQ_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorProv, @aValorDesc )							
				elseif !empty(TrbBGQ->BBB_VERBA)
					gravaGPE(TrbBGQ->BBB_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .t.)
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorProv, @aValorDesc )			
				else
					cVerba := getVerbaGen(cAliasBMR)
					if empty(cVerba)
						aadd(aCriticas,{"Verba não cadastrada(Nivel [BBB][BLS][BLR])",(cAliasBMR)->BMR_CODRDA, TrbBGQ->BGQ_CODLAN, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})	
					else
						gravaGPE(cVerba, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .t.)
						fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorProv, @aValorDesc )			
					endif					
				endif		
				TrbBGQ->(dbskip())
			enddo	
			TrbBGQ->(dbclosearea())

		// Creditos Gerais
		Case (cAliasBMR)->BMR_CODLAN == "104"
			cSqlBGQ := "SELECT BGQ_CODLAN, BGQ_VALOR, BGQ_VERBA, BBB_VERBA "			
			cSqlBGQ += " FROM "+RetSQLName("BGQ")+" BGQ "
			cSqlBGQ += " INNER JOIN "+RetSQLName("BBB")+" BBB "
			cSqlBGQ += " ON BBB_FILIAL = BGQ_FILIAL "
			cSqlBGQ += " AND BBB_CODSER = BGQ_CODLAN "
			cSqlBGQ += " AND BBB_TIPSER = '2' " // Crédito
			cSqlBGQ += " AND BBB.D_E_L_E_T_ = ' '  "
			cSqlBGQ += " WHERE BGQ_FILIAL = '"+xFilial("BGQ")+"'   "
			cSqlBGQ += " AND BGQ_CODIGO = '"+(cAliasBMR)->BMR_CODRDA+"'   "	
			cSqlBGQ += " AND BGQ_CODOPE = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_OPELOT = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_NUMLOT = '"+(cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)+"'  "
			cSqlBGQ += " AND BGQ_ATIVO <> '0' "
			cSqlBGQ += " AND BGQ_TIPO   = '2'  "			
			cSqlBGQ += " AND BGQ_NUMLAU <> 'BBC" + Space(TamSX3("BGQ_NUMLAU")[1] - 3) + "' "		
			cSqlBGQ += " AND BGQ.D_E_L_E_T_ = ' '  "

			cSqlBGQ := ChangeQuery(cSqlBGQ)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBGQ),"TrbBGQ",.F.,.T.)

			while !TrbBGQ->(eof())
				if !empty(TrbBGQ->BGQ_VERBA)
					gravaGPE(TrbBGQ->BGQ_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .t.)
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorProv, @aValorDesc )			
				elseif !empty(TrbBGQ->BBB_VERBA)
					gravaGPE(TrbBGQ->BBB_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorProv, @aValorDesc )			
				else
					cVerba := getVerbaGen(cAliasBMR)
					if empty(cVerba)
						aadd(aCriticas,{"Verba não cadastrada(Nivel [BBB][BLS][BLR])",(cAliasBMR)->BMR_CODRDA, TrbBGQ->BGQ_CODLAN, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})	
					else
						gravaGPE(cVerba, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
						fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorProv, @aValorDesc )			
					endif						
				endif
				TrbBGQ->(dbskip())
			enddo
			TrbBGQ->(dbclosearea())

		// Debitos  Gerais
		Case (cAliasBMR)->BMR_CODLAN == "105"
			cSqlBGQ := "SELECT BGQ_CODLAN, BGQ_VALOR, BGQ_VERBA, BBB_VERBA "			
			cSqlBGQ += " FROM "+RetSQLName("BGQ")+" BGQ "
			cSqlBGQ += " INNER JOIN "+RetSQLName("BBB")+" BBB "
			cSqlBGQ += " ON BBB_FILIAL = BGQ_FILIAL "
			cSqlBGQ += " AND BBB_CODSER = BGQ_CODLAN "
			cSqlBGQ += " AND BBB_TIPSER = '1' " // Débito
			cSqlBGQ += " AND BBB.D_E_L_E_T_ = ' '  "
			cSqlBGQ += " WHERE BGQ_FILIAL = '"+xFilial("BGQ")+"'   "
			cSqlBGQ += " AND BGQ_CODIGO = '"+(cAliasBMR)->BMR_CODRDA+"'   "		
			cSqlBGQ += " AND BGQ_CODOPE = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_OPELOT = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBGQ += " AND BGQ_NUMLOT = '"+(cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)+"'  "
			cSqlBGQ += " AND BGQ_ATIVO <> '0' "
			cSqlBGQ += " AND BGQ_TIPO   = '1'  "	
			cSqlBGQ += " AND BGQ_NUMLAU <> 'BBC" + Space(TamSX3("BGQ_NUMLAU")[1] - 3) + "' "				
			cSqlBGQ += " AND BGQ.D_E_L_E_T_ = ' '  "

			cSqlBGQ := ChangeQuery(cSqlBGQ)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBGQ),"TrbBGQ",.F.,.T.)

			while !TrbBGQ->(eof())
				if !empty(TrbBGQ->BGQ_VERBA)
					gravaGPE(TrbBGQ->BGQ_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)					
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorDesc, @aValorProv)	
				elseif !empty(TrbBGQ->BBB_VERBA)
					gravaGPE(TrbBGQ->BBB_VERBA, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
					fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorDesc, @aValorProv)	
				else
					cVerba := getVerbaGen(cAliasBMR)
					if empty(cVerba)
						aadd(aCriticas,{"Verba não cadastrada(Nivel [BBB][BLS][BLR])",(cAliasBMR)->BMR_CODRDA, TrbBGQ->BGQ_CODLAN, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})	
					else
						gravaGPE(cVerba, TrbBGQ->BGQ_VALOR, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
						fAddVal(cDtRef, TrbBGQ->BGQ_VALOR, @aValorDesc, @aValorProv)	
					endif						
				endif
				TrbBGQ->(dbskip())
			enddo
			TrbBGQ->(dbclosearea())

		// Apontamentos de producao medica
		Case (cAliasBMR)->BMR_CODLAN == "106"
			cSqlBCE := "SELECT BCE_VERBA, BCE_CODPAG, BCE_VLRCAL, BBB_VERBA "						
			cSqlBCE += " FROM "+RetSQLName("BCE")+" BCE "
			cSqlBCE += " INNER JOIN "+RetSQLName("BBB")+" BBB "
			cSqlBCE += " ON BBB_FILIAL = BCE_FILIAL "
			cSqlBCE += " AND BBB_CODSER = BCE_CODPAG "
			cSqlBCE += " AND BBB.D_E_L_E_T_ = ' '  "
			cSqlBCE += " WHERE BCE_FILIAL = '"+xFilial("BCE")+"' "
			cSqlBCE += " AND BCE_CODIGO = '"+(cAliasBMR)->BMR_CODRDA+"' "
			cSqlBCE += " AND BCE_CODINT = '"+(cAliasBMR)->BMR_OPERDA+"' "
			cSqlBCE += " AND BCE_ANOPAG = '" + (cAliasBMR)->BMR_ANOLOT + "' " 	
			cSqlBCE += " AND BCE_MESPAG = '" + (cAliasBMR)->BMR_MESLOT + "' "			
			cSqlBCE += " AND BCE_OPELOT = '"+(cAliasBMR)->BMR_OPERDA+"'  "
			cSqlBCE += " AND BCE_NUMLOT = '"+(cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)+"'  "
			cSqlBCE += " AND BCE.D_E_L_E_T_ = ' '  "

			cSqlBCE := ChangeQuery(cSqlBCE)			
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBCE),"TrbBCE",.F.,.T.)

			while !TrbBCE->(eof())
				if !empty(TrbBCE->BCE_VERBA)
					gravaGPE(TrbBCE->BCE_VERBA, TrbBCE->BCE_VLRCAL, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
					if (cAliasBMR)->BMR_DEBCRE == "1"
						fAddVal(cDtRef, TrbBCE->BCE_VLRCAL, @aValorDesc, @aValorProv)							
					elseif (cAliasBMR)->BMR_DEBCRE =="2"
						fAddVal(cDtRef, TrbBCE->BCE_VLRCAL, @aValorProv, @aValorDesc )	
					endif
				elseif !empty(TrbBCE->BBB_VERBA)
					gravaGPE(TrbBCE->BBB_VERBA, TrbBCE->BCE_VLRCAL, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
					if (cAliasBMR)->BMR_DEBCRE == "1"
						fAddVal(cDtRef, TrbBCE->BCE_VLRCAL, @aValorDesc, @aValorProv)	
					elseif (cAliasBMR)->BMR_DEBCRE =="2"
						fAddVal(cDtRef, TrbBCE->BCE_VLRCAL, @aValorProv, @aValorDesc )	
					endif
				else
					cVerba := getVerbaGen(cAliasBMR)
					if empty(cVerba)
						aadd(aCriticas,{"Verba não cadastrada(Nivel [BCE][BLS][BLR])",(cAliasBMR)->BMR_CODRDA, TrbBCE->BCE_CODPAG, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})	
					else
						gravaGPE(cVerba, TrbBCE->BCE_VLRCAL, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef, , .T.)
						if (cAliasBMR)->BMR_DEBCRE == "1"
							fAddVal(cDtRef, TrbBCE->BCE_VLRCAL, @aValorDesc, @aValorProv)	
						elseif (cAliasBMR)->BMR_DEBCRE =="2"							
							fAddVal(cDtRef, TrbBCE->BCE_VLRCAL, @aValorProv, @aValorDesc )	
						endif
					endif
				endif
				TrbBCE->(dbskip())
			enddo

			TrbBCE->(dbCloseArea())

		// Faixa de Desconto
		//Case (cAliasBMR)->BMR_CODLAN == "107"
		// IR Retido Outras Fontes
		//Case (cAliasBMR)->BMR_CODLAN == "169"	
		// Sal Contrib Outras Empresas
		//Case (cAliasBMR)->BMR_CODLAN == "170"
		// Valor Base INSS
		//Case (cAliasBMR)->BMR_CODLAN == "182"
		// Valor Base ISS 
		//Case (cAliasBMR)->BMR_CODLAN == "184"
		// Valor Base PIS
		//Case (cAliasBMR)->BMR_CODLAN == "186"
		// Valor Base COFINS
		//Case (cAliasBMR)->BMR_CODLAN == "188"		
		// Valor Base CSLL
		//Case (cAliasBMR)->BMR_CODLAN == "190"
		// Valor Base INSS PF
		//Case (cAliasBMR)->BMR_CODLAN == "192"
		// Valor Base INSS PJ
		//Case (cAliasBMR)->BMR_CODLAN == "194"
		// Valor Base INSS PJ Filantropico
		//Case (cAliasBMR)->BMR_CODLAN == "196"
		// Valor Base Imposto de Renda		
		//Case (cAliasBMR)->BMR_CODLAN == "198"
		Otherwise
			if lPL240LAN
				cVerba := ExecBLock("PL240LAN",.F.,.F.,{cAliasBMR})
			endif

			// Sal Contrib Outras Empresas
			if (cAliasBMR)->BMR_CODLAN == "170"
				PlsMultVin(aRet,(cAliasBMR)->BMR_CODRDA,(cAliasBMR)->BAU_MATFUN)
			endif

			nValINSS := 0

			if (cAliasBMR)->BMR_CODLAN == "198"
				nValINSS := RetDescINSS( (cAliasBMR)->Recno )
			endif

			if empty(cVerba)
				cVerba := getVerbaGen(cAliasBMR)
			endif

			if empty(cVerba)
				aadd(aCriticas,{"Verba não cadastrada(Nivel [BLS][BLR])",(cAliasBMR)->BMR_CODRDA, (cAliasBMR)->BMR_CODLAN, (cAliasBMR)->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)})	
			else

				if (cAliasBMR)->BMR_CODLAN == "198" .AND. (cAliasBMR)->BMR_VLRPAG < 0
					//para casos em que a base de IR foi gravada negativa.
					//Ocorre em casos que a produção médica é menor que os abatimentos de base de IR, como dependentes
					//Rever na rotina de geração de lote de pagamento se é viável deixar de gravar negativo lá, caso seja, alterar
					//pra não gravar o BMR negativo e retirar esse if.
					gravaGPE(cVerba, 0, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef)
				else
					gravaGPE(cVerba, (cAliasBMR)->BMR_VLRPAG - nValINSS, cAliasBMR, aRet, cNumLote, @nQtd,,,,,,,aPerFech, cDtRef)
				endif
				
				if (cAliasBMR)->BMR_DEBCRE == "1"
					fAddVal(cDtRef, (cAliasBMR)->BMR_VLRPAG, @aValorDesc, @aValorProv)	
				elseif (cAliasBMR)->BMR_DEBCRE =="2"						
					fAddVal(cDtRef, (cAliasBMR)->BMR_VLRPAG, @aValorProv, @aValorDesc )	
				endif
			endif
		
	endCase

	(cAliasBMR)->(dbSkip())
	
	if (cAliasBMR)->(EoF()) .OR. cRDAant <> (cAliasBMR)->BMR_CODRDA
		If !lRGB_RES .or. B5E->B5E_ALIAS == "SRD"
			for nL := 1 to len(aValorDesc)
				if aValorProv[nL][2] - aValorDesc[nL][2] >= 0
					gravaGPE(cVlLiqSRV, aValorProv[nL][2] - aValorDesc[nL][2], cAliasBMR, aRet, cNumLote, @nQtd, .T., cProcSRV, cCenSRV, cFFunSRV, cMFunSRV, cRDAant, aPerFech, aValorDesc[nL][1])
				else
					gravaGPE(cVlLiqSRV, 0, cAliasBMR, aRet, cNumLote, @nQtd, .T., cProcSRV, cCenSRV, cFFunSRV, cMFunSRV, cRDAant, aPerFech, aValorDesc[nL][1])
					gravaGPE(cInsSldSRV, aValorDesc[nL][2] - aValorProv[nL][2], cAliasBMR, aRet, cNumLote, @nQtd, .T., cProcSRV, cCenSRV, cFFunSRV, cMFunSRV, cRDAant, aPerFech, aValorDesc[nL][1])
				endif
			next
		else
			//cVerbaRES := "401" //vai buscar do BLR 110 a verba associada
			for nL := 1 to len(aValorDesc)
				gravaGPE(cVerbaRES, (aValorProv[nL][2] - aValorDesc[nL][2]), cAliasBMR, aRet, cNumLote, @nQtd, .T., cProcSRV, cCenSRV, cFFunSRV, cMFunSRV, cRDAant, aPerFech, aValorDesc[nL][1], , .T.)
			Next
		endIf
		aValorProv := {}
		aValorDesc := {}
//		lRGB_RES := .F.
	endif
enddo	

if nQtd == 0 .and. nRegua > 0	
	if B5E->(MsSeek(xFilial('B5E') + aRet[2]+aRet[3] + cNumLote)) 
		B5E->(RecLock("B5E",.F.))
			B5E->(DbDelete())
		B5E->(MsUnLock())
	endif
	if len(aCriticas) == 0
		MsgAlert("Nenhum registro encontrado.")
	endif
endif

if len(aCriticas) > 0
	PLSCRIGEN(aCriticas,{ {"Descrição","@C",060},{"Código RDA","@C",010},{"Lançamento","@C",010},{"Lote de Pagamento","@C",015} }, "Criticas",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)	
endif

if nQtd > 0 .and. nRegua > 0
	Aviso( "Resumo","Periodo processado: " + aRet[3] + "/" + aRet[2] +  CRLF + 'Registros processados: ' + cvaltochar( nQtd ) ,{ "Ok" }, 2 )
endif
(cAliasBMR)->(dbCloseArea())

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaGPE
Grava os dados na tabela SRC ou SRD

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function gravaGPE(cCodPD, nVlrPag, cAlias, aRet, cNumLote, nQtd, lSRV, cProcSRV, cCenSRV, cFFunSRV, cMFunSRV, cRDASRV, aPerFech, cDtRef, cCC, lOkRGB)
local cProcesso := "" //(cAlias)->RA_PROCES 
local cCenCust	:= "" //(cAlias)->RA_CC
local cFilFun	:= "" //(cAlias)->BAU_FILFUN
local cMatFun	:= "" //(cAlias)->BAU_MATFUN
local cCodRDA	:= ""
local cSeqSRD	:= Space(tamSX3("RD_SEQ")[1])
local cAno		:= aRet[2]
local cMes		:= aRet[3]
local cRoteiro  := 'AUT'
local cLotPls	:= ""
local lNewSRD	:= .F.
Local lRescisao	:= .F.

default lSRV 		:= .F.
default aPerFech	:= {}
default cDtRef		:= ""
default cCC			:= ""
Default lOkRGB		:= .F. //variávle de controle pra RGB, aqui só vão os lançamentos normais, nada de base ou imposto, pq a folha vai fazer isso.
if lSRV
	cProcesso := cProcSRV
	cCenCust := cCenSRV
	cFilFun := cFFunSRV
	cMatFun := cMFunSRV
	cCodRDA := cRDASRV
else
	cProcesso 	:= (cAlias)->RA_PROCES 
 	if empty(cCC)
		cCenCust	:= (cAlias)->RA_CC
	else
		cCenCust	:= cCC
	endif
 	cFilFun		:= (cAlias)->BAU_FILFUN
 	cMatFun		:= (cAlias)->BAU_MATFUN
 	cCodRDA 	:= (cAlias)->BMR_CODRDA
endif

SRC->(dbsetorder(15))//RC_FILIAL, RC_PROCES, RC_MAT, RC_PERIODO, RC_SEMANA, RC_ROTEIR, RC_PD, RC_CC, RC_ITEM, RC_CLVL, RC_SEQ, RC_DTREF                                                                                                                                            
SRD->(dbsetorder(5)) //RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA

lRescisao := !(empty((cAlias)->(RA_DEMISSA))) //Apesar de não usar por enquanto, quando chegar a hora de tratar rescisão complementar

//V1 - O plano é alterar pra que grave o RGB sempre. (that's what V2 is for).
//Mantido o SRC por legado pra quem não usa o GPE
If lRGB_RES .AND. lOkRGB .and. B5E->B5E_ALIAS <> 'SRD'
	cSeqRGB   := NextRGB(cMatFun, cCodPD, cCenCust)
	nQtd++
	nIndice:= RetOrder("RGB", "RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_ITEM+RGB_CLVL+RGB_SEMANA+RGB_SEQ")
	RGB->(DbSetOrder(nIndice))
	If RGB->(MsSeek(xFilial('RGB')+ cMatFun + cCodPD +cCenCust))//RGB->(MsSeek(xFilial('RGB')+aSaldo[20][nCaLimp4][3]+aSaldo[20][nCaLimp4][1]+cCenCust))
		RecLock('RGB',.F.)
	Else                                                                                   
	  	RecLock('RGB',.T.)		
	EndIf   
	//FINA402A
	RGB->RGB_FILIAL := xFilial('RGB')
	RGB->RGB_MAT    := cMatFun
	RGB->RGB_PD     := cCodPD 
	RGB->RGB_TIPO1  := 'V'	
	RGB->RGB_QTDSEM	:= 0
	RGB->RGB_HORAS	:= 0
	RGB->RGB_VALOR  += nVlrPag
	RGB->RGB_CODFUN := (cAlias)->RA_CODFUNC 
	RGB->RGB_PERIOD := cPerRGB 
	RGB->RGB_SEMANA := cSemana 
	RGB->RGB_CC     := cCenCust
	RGB->RGB_PARCEL	:= 0
	RGB->RGB_TIPO2	:= 'G'
	RGB->RGB_SEQ	:= cSeqRGB
	RGB->RGB_PROCES := cProcesso
	RGB->RGB_ROTEIR := cRoteiro	
	RGB->RGB_CODRDA	:= cCodRDA
	RGB->RGB_LOTPLS	:= cAno + cMes + cNumLote
	RGB->(MsUnLock())

elseif B5E->B5E_ALIAS == "SRC" 
	if ! SRC->(MsSeek(cFilFun+cProcesso+cMatFun+cAno+cMes+cSemana+cRoteiro+cCodPD+cCenCust))
		nQtd++
		SRC->(RecLock(B5E->B5E_ALIAS, .T.))
		SRC->RC_FILIAL := cFilFun
		SRC->RC_MAT    := cMatFun
		SRC->RC_PD     := cCodPD
		SRC->RC_TIPO1  := "V"
		SRC->RC_CC     := cCenCust
		SRC->RC_TIPO2  := "G"
		SRC->RC_PERIODO:= cAno+cMes
		SRC->RC_ROTEIR := cRoteiro
		SRC->RC_PROCES := cProcesso
		SRC->RC_SEMANA := cSemana
		SRC->RC_LOTPLS := cAno + cMes + cNumLote
		SRC->RC_CODRDA := cCodRDA
	else
		cLotPls := SRC->RC_LOTPLS
		SRC->(RecLock(B5E->B5E_ALIAS, .F.))
	endif
	SRC->RC_VALOR  += nVlrPag
	SRC->(MsUnlock())
elseif B5E->B5E_ALIAS == "SRD"

	lNewSRD := SRDIsNew(cAno+cMes, cCodPD, @cSeqSRD, cAno+cMes, cRoteiro, cSemana, cDtRef, cCenCust, cAlias)	
	
	if lNewSRD
		nQtd++
		SRD->(RecLock(B5E->B5E_ALIAS, .T.))
		SRD->RD_FILIAL := cFilFun
		SRD->RD_MAT    := cMatFun
		SRD->RD_PD     := cCodPD
		SRD->RD_TIPO1  := "V"
		SRD->RD_CC     := cCenCust
		SRD->RD_TIPO2  := "G"
		SRD->RD_PERIODO:= cAno+cMes
		SRD->RD_ROTEIR := cRoteiro
		SRD->RD_PROCES := cProcesso
		SRD->RD_SEMANA := cSemana
		SRD->RD_LOTPLS := cAno + cMes + cNumLote
		SRD->RD_CODRDA := cCodRDA //(cAlias)->BMR_CODRDA
		SRD->RD_ITEM   := (cAlias)->RA_ITEM
		SRD->RD_CLVL   := (cAlias)->RA_CLVL	
		SRD->RD_SEQ    := cSeqSRD	
		SRD->RD_DATARQ := cAno+cMes		 
		SRD->RD_DTREF  := stod(cDtRef)
		SRD->RD_DATPGT := stod(cDtRef)		
	else
		SRD->(RecLock("SRD", .F.))
	endif
	cLotPls := SRD->RD_LOTPLS
	SRD->RD_VALOR  += nVlrPag	
	SRD->(MsUnlock())

endif

if empty(cLotPls)
	cLotPls := cAno+cMes+cNumLote
endif

if !lSRV
	flgBMR(cAlias, cLotPls)
endif

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} flgBMR
Grava o campo BMR_LOTB5E para marcar que ja foi processada para envio do e-Social

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function flgBMR(cAlias, cLoteSRC )

BMR->(dbsetorder(1))
BMR->(dbGoTo((cAlias)->(Recno)))

BMR->(RecLock("BMR", .F.))
	BMR->BMR_LOTB5E	:= cLoteSRC
BMR->(MsUnlock())

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getNumLote
Pega o sequencial para o periodo selecionado.

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
static function getNumLote(cPeriodo, cCodOpe, aPerAber, aPerFech, cRoteiro)
local cAlias	:= getNextAlias()
local cNumLote	:= 0
local aCampos	:= {}
local cAliasGPE	:= ""
default cRoteiro := ""

BeginSQL Alias cAlias
	SELECT MAX( B5E_NUMLOT ) NUMLOT
	FROM %table:B5E% B5E
	WHERE
	B5E_FILIAL = %xFilial:B5E% AND
	B5E_PERIOD  = %exp:cPeriodo% AND	
	B5E.%notDel%
endSQL

if PLSFOLMES(cPeriodo, @aPerAber, @aPerFech, cRoteiro)
	If lRGB_RES
		cAliasGPE := "RGB"
	else
		cAliasGPE := "SRC"
	EndIf
else
	cAliasGPE := "SRD"
endif

( cAlias )->( dbGoTop() )
cNumLote :=  strZero( iif( !empty( ( cAlias )->( NUMLOT ) ),val( ( cAlias )->( NUMLOT ) ), 0 ) + 1, 4 )

( cAlias )->( dbCloseArea() )

aAdd( aCampos,{ "B5E_FILIAL",	xFilial( "B5E" ) 	} )		// Filial
aAdd( aCampos,{ "B5E_CODINT",	cCodOpe 			} )		// Operadora
aAdd( aCampos,{ "B5E_NUMLOT",	cNumLote 			} )		// Lote
aAdd( aCampos,{ "B5E_STATUS",	'1' 				} )		// Status
aAdd( aCampos,{ "B5E_CODUSR",	retCodUsr() 		} )		// Codigo usuario corrente
aAdd( aCampos,{ "B5E_PERIOD",	cPeriodo 			} )		// Periodo
aAdd( aCampos,{ "B5E_DATPRO",	dDataBase 			} )		// Data Base
aAdd( aCampos,{ "B5E_HORPRO",	AllTrim( time() ) 	} )		// Horario base
aAdd( aCampos,{ "B5E_LOTSRC",	cPeriodo +cNumLote	} )		// RC_LOTPLS
aAdd( aCampos,{ "B5E_ALIAS"	,	cAliasGPE			} )		// Alias
grava( 3,aCampos,'MODEL_B5E','PLSM240' )

return cNumLote

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM240EXC
Realiza a exclusão do lote.

@author    Lucas Nonato
@version   V12
@since     15/01/2018
/*/
//------------------------------------------------------------------------------------------
function PLSM240EXC(cChave, lAutoma)
local cSql		:= ""
local nRet		:= 0

DEFAULT cChave	:= AllTrim( B5E->B5E_PERIOD ) + AllTrim( B5E->B5E_NUMLOT )
DEFAULT lAutoma	:= .F.

if !lAutoma 
	if !MsgYesNo("Confirma a exclusão de todos as movimentações do lote [" + B5E->B5E_PERIOD + "]" + AllTrim(B5E->B5E_NUMLOT) + " ? ")
		return
	endif
endif

SRC->(dbsetorder( RetOrder( "SRC", "RC_FILIAL+RC_LOTPLS" ) ))	// RC_FILIAL, RC_LOTPLS
SRD->(dbsetorder( RetOrder( "SRD", "RD_FILIAL+RD_LOTPLS" ) ))	// RD_FILIAL, RD_LOTPLS
RGB->(dbsetOrder( RetOrder( "RGB", "RGB_FILIAL+RGB_LOTPLS" ) ))
B5E->(dbsetorder( 1 )) 	// B5E_FILIAL, B5E_PERIOD
RAW->(dbsetorder( 1 ))  // RAW_FILIAL, RAW_MAT, RAW_FOLMES, RAW_TPFOL, RAW_PROCES, RAW_ROTEIR, RAW_SEMANA                                                                                        
RAZ->(dbsetorder( 1 ))  // RAZ_FILIAL, RAZ_MAT, RAZ_FOLMES, RAZ_TPFOL, RAZ_INSCR 
Begin Transaction

ProcRegua(-1)

cSql := " SELECT BAU_MATFUN FROM  " + RetSqlName('BMR') + " BMR " 
cSql += " INNER JOIN " + RetSQLName("BAU") + " BAU "
cSql += " ON  BAU_FILIAL = '" + xFilial("BAU") + "' "
cSql += " AND BAU_CODIGO = BMR_CODRDA "
cSql += " AND BAU.D_E_L_E_T_ = ' ' "
cSql += " WHERE BMR_FILIAL = '" + xFilial('BMR') + "' " 
cSql += " AND BMR_LOTB5E = '" + cChave  + "' " 
cSql += " AND BMR_CODLAN = '170' " 
cSql += " AND BMR.D_E_L_E_T_ = ' ' "
cSql += " GROUP BY BAU_MATFUN "
cSql := ChangeQuery(cSql)			
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbDEL",.F.,.T.) 

while !TrbDEL->(eof())
	// RAZ
	while RAZ->(MsSeek(xFilial('RAZ') + TrbDEL->BAU_MATFUN + B5E->B5E_PERIOD + '1' )) 		
		RAZ->(RecLock('RAZ',.F.))
			RAZ->(DbDelete())
		RAZ->(MsUnLock())
	enddo

	// RAW
	while RAW->(MsSeek(xFilial('RAW') + TrbDEL->BAU_MATFUN + B5E->B5E_PERIOD + '1' + '00003' + 'AUT' + '01')) 		
		RAW->(RecLock('RAW',.F.))
			RAW->(DbDelete())
		RAW->(MsUnLock())
	enddo
	TrbDEL->(dbskip())
enddo

TrbDEL->(dbclosearea())
// BMR
cSql := " UPDATE " + RetSqlName('BMR') + " SET BMR_LOTB5E = ' ' " 
cSql += " WHERE BMR_FILIAL = '" + xFilial('BMR') + "' " 
cSql += " AND BMR_LOTB5E = '" + cChave + "' " 
cSql += " AND D_E_L_E_T_ = ' ' "  

nRet := TcSqlEXEC(cSql) 
if nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
   	nRet := TcSqlEXEC("COMMIT") 
endif

// SRC
while SRC->(MsSeek(xFilial('SRC') + cChave)) 
	//IncProc("Excluindo registros " + Posicione("SRA", 1, xFilial("SRA")+ SRC->RC_MAT, "RA_NOME" ))
	SRC->(RecLock('SRC',.F.))
		SRC->(DbDelete())
	SRC->(MsUnLock())
enddo

// SRD
while SRD->(MsSeek(xFilial('SRD') + cChave)) 
	//IncProc("Excluindo registros " + Posicione("SRA", 1, xFilial("SRA")+ SRD->RD_MAT, "RA_NOME" ))
	SRD->(RecLock('SRD',.F.))
		SRD->(DbDelete())
	SRD->(MsUnLock())
enddo

while RGB->(MsSeek(xFilial('RGB') + cChave)) 
	//IncProc("Excluindo registros " + Posicione("SRA", 1, xFilial("SRA")+ SRC->RC_MAT, "RA_NOME" ))
	RGB->(RecLock('RGB',.F.))
		RGB->(DbDelete())
	RGB->(MsUnLock())
enddo

// B5E
if B5E->(MsSeek(xFilial('B5E') + cChave)) 
	B5E->(RecLock("B5E",.F.))
		B5E->(DbDelete())
	B5E->(MsUnLock())
endif

end Transaction

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getVerbaGen
Pega a verba nas tabelas BLS e BLR

@author    Lucas Nonato
@version   V12
@since     25/05/2018
/*/
//------------------------------------------------------------------------------------------
static function getVerbaGen(cAliasBMR, cTpUsr)
local cTipCalc	:= ""
local cVerba	:= ""
default cTpUsr 	:= ""

if BLS->(msseek(xfilial("BLS") + (cAliasBMR)->BMR_OPERDA + (cAliasBMR)->BMR_CODLAN)) 				
	if (cAliasBMR)->BAU_CALIMP $ "3,4" 
		cTipCalc := "1"
	else
		cTipCalc := "2"
	endif
	while !BLS->(eof()) .and. alltrim((cAliasBMR)->BMR_CODLAN) == alltrim(BLS->BLS_CODLAN) 
		if cTipCalc == BLS->BLS_CALIMP .and. (empty(cTpUsr) .or. (!empty(cTpUsr) .and. cTpUsr == BLS->BLS_TIPOCT))
			cVerba	:= BLS->BLS_VERBA
			exit
		endif
		BLS->(dbskip())
	enddo
endif	
if empty(cVerba) .and. BLR->(msseek(xfilial("BLR") + (cAliasBMR)->(BMR_OPERDA) + (cAliasBMR)->(BMR_CODLAN))) .and. !empty(BLR->BLR_VERBA)
	cVerba	:= BLR->BLR_VERBA
endif

return cVerba


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsMultVin
Cadastro nas tabelas de multiplos vinculos

@author    Lucas Nonato
@version   V12
@since     18/06/2018
/*/
//------------------------------------------------------------------------------------------
function PlsMultVin(aRet,cCodRda,cMatFun) 
local nTotCre 	:= 0   
local cSql		:= ""
local lret      := .T.
Local lRAZ_CIC := RAZ->(fieldPos("RAZ_CIC")) > 0
Local cCPFRDA 	:= ""
Local cTpIns := "1"

RAW->(dbsetorder(1)) // RAW_FILIAL, RAW_MAT, RAW_FOLMES, RAW_TPFOL
RAZ->(dbsetorder(1)) // RAZ_FILIAL, RAZ_MAT, RAZ_FOLMES, RAZ_TPFOL, RAZ_INSCR
SRA->(dbsetorder(1)) // RA_FILIAL, RA_MAT

//Para posicionar na RDA
BAU->(dbsetorder(1)) // BAU_FILIAL, BAU_CODIGO
BAU->(MsSeek(xFilial("BAU") + cCodRda))

cCPFRDA := retCPF()

//Para verificar os campos novos na flx
FLX->(DbSetOrder(1))
if FLX->(FieldPos("FLX_CATEFD")) > 0 .and. FLX->(FieldPos("FLX_TPREC")) > 0

	cSql := "select FILIAL,CNPJ,CATEFD,TPREC,TPINS,sum(VALOR) VALOR from ( "
	cSql += " select distinct FLX.FLX_FILIAL Filial,FLX.FLX_CNPJ CNPJ,FLX.FLX_CATEFD CATEFD,FLX.FLX_TPREC TPREC,FLX.FLX_BASE VALOR, FLX.FLX_TIPO TPINS "
	cSql += " FROM " + RetSQLName("FLX") + " FLX "
	cSql += " WHERE FLX.FLX_FILIAL = '"+xFilial("FLX") + "'  "
	cSql += " AND FLX.FLX_FORNEC = '" + BAU->BAU_CODSA2 + "'  "
	cSql += " AND FLX.FLX_LOJA = '" + BAU->BAU_LOJSA2 + "'  "
	cSql += " AND '" + aRet[2] + aRet[3] + "01' >= FLX_DTINI  "
	cSql += " AND ( '" + dtos(LastDay(ctod("01/" + aRet[3] + "/"+aRet[2]))) + "' <= FLX_DTFIM  OR  FLX_DTFIM = '        ' )  "
	cSql += " AND FLX.D_E_L_E_T_ = ' '  "
	cSql += " )FLX "
	cSql += " group by FILIAL,CNPJ,CATEFD,TPREC,TPINS  "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"Trbflx",.T.,.T.)
	nTotCre := 0
	while !Trbflx->(eof())
		nTotCre += Trbflx->VALOR
		
		//FLX_TIPO = 1 -> Física -> RAZ_TPINS = 2 -> CPF
		//FLX_TIPO = 2 -> Jurídica -> RAZ_TPINS = 1 -> CNPJ
		//Por isso aqui "inverte" o conteúdo
		if Trbflx->TPINS == "1"
			cTpIns := "2"
		elseif Trbflx->TPINS == "2"
			cTpIns := "1"
		endif

		gravaRAW(cMatFun,aRet, Trbflx->CNPJ, Trbflx->VALOR, Trbflx->CATEFD, Trbflx->TPREC, lRAZ_CIC, cCPFRDA, cTpIns)
		Trbflx->(dbskip())
		lret:= .F.
	enddo	
	Trbflx->(dbCloseArea())	
endif

return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaRAW
Gravação das tabelas do GPE RAW e RAZ responsaveis pelos multiplos vinculos no envio do e-Social.

@author    Lucas Nonato
@version   V12
@since     18/06/2018
/*/
//------------------------------------------------------------------------------------------
static function gravaRAW(cMatFun,aRet,cCnpjCPF,nTotCre,cCatEfd,cTpRec,lRAZ_CIC,cCPFRDA,cTpIns)
local lInclui	:= .t. 

default cCnpjCPF 	:= ""
default cCatEfd	:= ""
default cTpRec	:= "1"
Default lRAZ_CIC := .F.
Default cCPFRDA := ""
Default cTpIns	:= "1"

if RAW->(msseek(xfilial("RAW") + cMatFun + aRet[2]+aRet[3])) 
	lInclui := .f.
endif

RAW->(RecLock("RAW",lInclui))
	RAW->RAW_FILIAL := xFilial( "RAW" ) 	
	RAW->RAW_MAT	:= cMatFun				
	RAW->RAW_FOLMES := aRet[2]+aRet[3] 		
	RAW->RAW_TPFOL 	:= '1' 				// 1=Folha Pagto Mensal
	RAW->RAW_TPREC 	:= cTpRec			// 1=Sobre remu. por ele informada;2=Sobre a dif. entre o l.Máx do sal e a rem. de outra empresa(s);3=Não realiza desc do segurado.	
	RAW->RAW_PROCES := '00003' 			// Contribuinte individual mensal
	RAW->RAW_SEMANA := '01' 				
	RAW->RAW_ROTEIR := 'AUT' 				
RAW->(msunlock())

if RAZ->(msseek(xfilial("RAW") + cMatFun + aRet[2]+aRet[3] + '1' + cCnpjCPF))
	lInclui := .f.
else
	lInclui := .t.
endif
//RAZ_FILIAL, RAZ_MAT, RAZ_FOLMES, RAZ_TPFOL, RAZ_INSCR
RAZ->(RecLock("RAZ",lInclui))
	RAZ->RAZ_FILIAL := xFilial( "RAZ" ) 	
	RAZ->RAZ_MAT 	:= cMatFun 			
	RAZ->RAZ_FOLMES := aRet[2]+aRet[3] 	
	RAZ->RAZ_TPFOL 	:= '1'  	// 1=Folha Pagto Mensal			
	RAZ->RAZ_TPINS 	:= cTpIns
	RAZ->RAZ_INSCR 	:= cCnpjCPF 				
	RAZ->RAZ_VALOR 	:= nTotCre 	
	RAZ->RAZ_CATEG  := cCatEfd	
	if lRAZ_CIC
		RAZ->RAZ_CIC := cCPFRDA
	endif
RAZ->(msunlock())

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSFOLMES
Função para retornar o periodo aberto
@type function
@author Lucas Nonato
@since  13/08/2018
@version 1.0
/*/
//------------------------------------------------------------------------------------------
function PLSFOLMES(cANOMES, aPerAber, aPerFech, cRoteiro)
local cPeriodo 	:= ""
local cNrPagto 	:= ""
local cAno     	:= ""
local cMes     	:= ""
local xDtRef
local dDtRef	:= SToD("")
local lPerAtual	:= .F.
default cRoteiro := SRA->RA_ROTEIRO

if !Empty(cANOMES)
    cAno := SubStr(cANOMES,1,4)
    cMes := SubStr(cANOMES,5,2)
else
	xDtRef 	:= DDATABASE
	dDtRef 	:= AnoMes(xDtRef)
	cAno 	:= SubStr(dDtRef,1,4)
	cMes 	:= SubStr(dDtRef,5,2)
endif

fRetPerComp(cMes , cAno , NIL , cRoteiro, NIL, @aPerAber, @aPerFech)

asort( aPerAber,,, { |x,y| x[1] + x[2] < y[1] + y[2] } )
asort( aPerFech,,, { |x,y| x[1] + x[2] < y[1] + y[2] } )

if !empty(aPerAber)
	cPeriodo := aPerAber[1,1]
	cNrPagto := aPerAber[1,2]
	lPerAtual := .T.
elseif !empty(aPerFech)
	cPeriodo := aPerFech[1,1]
	cNrPagto := aPerFech[1,2]
endif

return lPerAtual
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fFindSeqSRD
Incrementa a sequencia da tabela SRD.

@author Lucas Nonato
@since  13/08/2018
@version P12
@param cFilialArq, character, (Descrição do parâmetro)
@param cPdAux, character, (Descrição do parâmetro)
@param cMatAux, character, (Descrição do parâmetro)

/*/
//------------------------------------------------------------------------------------------
static function fFindSeqSRD(cFilialArq,cPdAux,cMatAux)
local cAliasAux := "QTABAUX"
local cWhere	:= ''
local nRet 		:= 0

cWhere += "%"
cWhere += " SRD.RD_FILIAL     = 	'" + cFilialArq    + "' "
cWhere += " AND SRD.RD_PD     = 	'" + cPdAux     + "' "
cWhere += " AND SRD.RD_MAT    = 	'" + cMatAux    + "' "	
cWhere += "%"

BeginSql alias cAliasAux
	SELECT MAX(RD_SEQ) SEQMAX
	FROM %table:SRD% SRD
	WHERE 		%exp:cWhere% AND
	SRD.%NotDel%
endSql

if Val((cAliasAux)->SEQMAX) > 0
	nRet := Val((cAliasAux)->SEQMAX) + 1
else
	nRet := 1
endif

(cAliasAux)->(DbCloseArea())

return nRet

/*/{Protheus.doc} SRDIsNew
(long_description)
@author philipe.pompeu
@since 12/01/2017
@version P11
@param cDataArqv, character, (Descrição do parâmetro)
@param cVerbImp, character, (Descrição do parâmetro)
@param cSeq, character, (Descrição do parâmetro)
@param cPeriodo, character, (Descrição do parâmetro)
@param cRotFol, character, (Descrição do parâmetro)
@param cSeman, character, (Descrição do parâmetro)
@param cDtRef, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*/
static function SRDIsNew(cDataArqv, cVerbImp, cSeq, cPeriodo, cRotFol, cSeman, cDtRef, cCC, cAlias)
	local lIsNew := .T.
	local cChave := ''
	local cChav2 := ''
	local cChav3 := ''
	local nI := 1
	
	Default cDataArqv := Space(TamSx3("RD_DATARQ")[1])
	Default cCC		  := ""
	
	SRD->(dbsetorder(1))	
	cChave := xFilial('SRD') + (cAlias)->BAU_MATFUN + cDataArqv
	
	if(SRD->(dbSeek(cChave)))		
		SRD->(dbsetorder(RetOrder("SRD","RD_FILIAL+RD_MAT+RD_CC+RD_ITEM+RD_CLVL+RD_DATARQ+RD_PD+RD_SEQ+RD_PERIODO+RD_SEMANA+RD_ROTEIR+DTOS(RD_DTREF)")))
		
		cChav2 := xFilial('SRD') + (cAlias)->BAU_MATFUN 
		cChav2 += cCC + (cAlias)->(RA_ITEM + RA_CLVL)
		cChav2 += cDataArqv + cVerbImp		
		cChav3 := cPeriodo + cSeman + cRotFol + cDtRef

		cChave := cChav2 + cSeq + cChav3
		
		For nI := 1 To 10
			lIsNew := !(SRD->(dbSeek(cChave)))
			if !lIsNew .AND. nI < 10 .AND. empTy(SRD->RD_LOTPLS)
				cSeq := AllTrim(Str(nI))
				cChave := cChav2 + cSeq + cChav3
			else
				Exit
			endif
		Next
	endif
	
return lIsNew

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fGr_CTT
Grava tabela de Centro de Custo

@author Lucas Nonato
@since  13/08/2018
@version P12

/*/
//------------------------------------------------------------------------------------------
static function fGr_CTT(cChaveSA2, aDadosSA2, aRet)

/*

Se for prestador pessoa física cooperado (o único tipo que conta pra rotina),
caso ele esteja executnado o serviço por conta (prórpio consultório), o centro
de custo será baseado na própria operadora (cooperativa). Se ele estiver executando o serviço
em outro estabelecimento (Hospital da cooperativa, por exemplo), o centro de custo
associado é o do estabelecimento em que foi executado o trabalho

*/
local lOper := .F.

if  (aDadosSA2[9] == "F" .or. Empty(aDadosSA2[9]))
	lOper := .T.
endif
if  aDadosSA2[7] == BA0->BA0_CGC
	lOper := .T.
endif
if  fInterc(aDadosSA2[7])
	lOper := .T.
endif

if lOper
	aDadosSA2[1] := BA0->BA0_NOMINT
	aDadosSA2[2] := BA0->BA0_END
	aDadosSA2[3] := BA0->BA0_BAIRRO
	aDadosSA2[4] := BA0->BA0_CEP
	aDadosSA2[5] := BA0->BA0_CIDADE
	aDadosSA2[6] := BA0->BA0_EST
	aDadosSA2[7] := BA0->BA0_CGC
	aDadosSA2[8] := ""
	aDadosSA2[10] := BA0->BA0_CODMUN
	cChaveSA2    := "OPERADORA"
endif

CTT->(dbsetorder(1))
if ! CTT->(MsSeek(xFilial("CTT")+PadR(cChaveSA2, 9), .F.))
	CTT->(RecLock("CTT", .T.))
	CTT->CTT_FILIAL  := xFilial("SI3")
	CTT->CTT_CUSTO   := cChaveSA2
	CTT->CTT_DESC01  := "CC PLS"
	CTT->CTT_NOME    := aDadosSA2[1]
	CTT->CTT_ENDER   := aDadosSA2[2]
	CTT->CTT_BAIRRO  := aDadosSA2[3]
	CTT->CTT_CEP     := aDadosSA2[4]
	CTT->CTT_MUNIC   := aDadosSA2[5]
	CTT->CTT_ESTADO  := aDadosSA2[6]
	CTT->CTT_TIPO    := Iif(Empty(aDadosSA2[8]), "1", "2") // 1-CNPJ , 2-CEI
	CTT->CTT_CEI     := Iif(Empty(aDadosSA2[8]), aDadosSA2[7], PadL(AllTrim(aDadosSA2[8]), 14, "0"))
	CTT->CTT_TIPO2   := "1"
	CTT->CTT_CEI2    := aDadosSA2[7]
	CTT->CTT_CLASSE  := "2"
	CTT->CTT_TPLOT   := "05"
	CTT->CTT_FPAS    := aRet[9]
	CTT->CTT_CODTER  := aRet[10]
	CTT->(MsUnlock())
else
	//caso ja exista e foi criado pela rotina da SEFIP arrumo o campo do eSocial
	CTT->(RecLock("CTT", .f.))
	if empty(CTT->CTT_TIPO2)
		CTT->CTT_TIPO2   := iif(len(aDadosSA2[7]) <= 11,"2","1")
	endif
	if empty(CTT->CTT_CEI2)
		CTT->CTT_CEI2    := aDadosSA2[7]
	endif
	if empty(CTT->CTT_CLASSE)
		CTT->CTT_CLASSE  := "2"
	endif
	if empty(CTT->CTT_TPLOT)
		CTT->CTT_TPLOT   := "05"
	endif
	if empty(CTT->CTT_FPAS)
		CTT->CTT_FPAS    := aRet[9]
	endif
	if empty(CTT->CTT_CODTER)
		CTT->CTT_CODTER  := aRet[10]
	endif
	CTT->(MsUnlock())
endif
	
return CTT->CTT_CUSTO 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fInterc
Verifica se é intercambio

@author Lucas Nonato
@since  13/08/2018
@version P12

/*/
//------------------------------------------------------------------------------------------
static function fInterc(cCGC)
	
local lRet    := .F.
local nPosBA0 := BA0->(Recno())

SIX->(dbsetorder(1))
BA0->(dbsetorder(4))
if  BA0->(msSeek(xFilial("BA0")+cCGC))
	lRet := .T.
endif
BA0->(dbsetorder(1))
BA0->(dbGoTo(nPosBA0))
	
return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fAddVal
Aumenta o valor liquido para operadoras que pagam 2x no mês

@author Lucas Nonato
@since  30/01/2019
@version P12

/*/
//------------------------------------------------------------------------------------------
static function fAddVal(cData,nValor,aArray1,aArray2)
local nPosVal	:= 0

nPosVal := aScan(aArray1,{|x| alltrim(x[1]) == cData})
if nPosVal == 0
	aadd(aArray1, {cData, nValor}) 
	aadd(aArray2, {cData, 0}) 
else
	aArray1[nPosVal][2] += nValor
endif	

return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSGetTom
Retorna o fornecedor do tomador de serviço.
Regra:
- Para cooperados, o tomador é o "onde" ele executou o serviço, ex:
O Cooperado X atende em seu consultório e no hospital da unimed, quando ele atender no hospital
(com base no CNES e CNPJ do BB8 + 'RDA dona da guia' (quem consta no cabeçalho) ), o tomador é 
com base no fornecedor do hospital (vai ir pra um centro de custo), quando ele atender no
consultório, o tomador é com base no fornecedor ele mesmo.
- Tem essa diferenciação por conta de encargos variáveis que cada empresa tem, o RAT/SAT (indice
vinculado à risco de acidente de trabalho)

Isso tem que retornar o fornecedor e loja
@author Oscar Zanin
@since  25/09/2019
@version P12
/*/
//------------------------------------------------------------------------------------------
//				  PLSGetTom(TrbTOM->BD7_CODRDA, TrbTOM->BD7_CODOPE, TrbTOM->BD7_CODLOC, TrbTOM->BD7_CODLDP, TrbTOM->BD7_CODPEG, TrbTOM->BD7_NUMERO, TrbTOM->BD7_TIPGUI)
static function PLSGetTom(cCodRDA, cCodOpe, cLocAte, cCodLdp, cCodPEG, cNumero, cTipgui)

Local lBE4	:= .F.
Local aAreaBE4 := BE4->(getArea())
Local aAreaBD5 := BD5->(getArea())
Local aAreaBAU := BAU->(getArea())
Local aAreaSA2 := SA2->(getArea())
Local lRDAdif	 := .F.
Local cRDATom	 := ""
Local aRet		 := {.F., "", "", ""}
//Primeiro, checa se a RDA do BD7 é igual à do cabeçalho.. por conta de ainda deixarmos fazer isso..
//com sorte um dia essa checagem ficará obsoleta

//Verifica tipo de guia pra chegar no cabeçalho
If cTipgui == "05"
	lBE4 := .T.
EndIf

//BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_NUMERO+BD5_TIPGUI - índice 9
//BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE  - índice 1

If lBE4
	BE4->(dbSetOrder(1))
	BE4->(MsSeek(xfilial("BE4") + cCodOpe + cCodLdp + cCodPEG + cNumero))
	If BE4->BE4_CODRDA <> cCodRDA
		lRDADif := .T.
		cRDATom := BE4->BE4_CODRDA
	endIf
else
	BD5->(dbsetOrder(1))
	BD5->(MsSeek(xfilial("BD5") + cCodOpe + cCodLdp + cCodPEG + cNumero))
	If BD5->BD5_CODRDA <> cCodRDA
		lRDADif := .T.
		cRDATom := BD5->BD5_CODRDA
	endIf
endIf

//se for RDA diferente, vamos no fornecedor dela
If lRDADif
	BAU->(dbSetOrder(1))
	If BAU->(MsSeek(xfilial("BAU") + cRDATom))
		aRet[1] := .T.
		aRet[2] := BAU->BAU_CODSA2
		aRet[3] := BAU->BAU_LOJSA2
		aRet[4] := BAU->BAU_CC
	endIf
else
	BAU->(dbSetOrder(1))
	BAU->(MsSeek(xfilial("BAU") + cCodRDA))
	BB8->(dbsetOrder(1))
	BB8->(MsSeek(xfilial("BB8") + cCodRDA + cCodOpe + cLocAte))
	If !(EmpTy(BB8->BB8_CPFCGC)) .AND. BAU->BAU_CPFCGC <> BB8->BB8_CPFCGC
		BAU->(dbsetOrder(4))
		If BAU->(MsSeek(xfilial("BAU") + BB8->BB8_CPFCGC))
			aRet[1] := .T.
			aRet[2] := BAU->BAU_CODSA2
			aRet[3] := BAU->BAU_LOJSA2
			aRet[4] := BAU->BAU_CC
		endIf
	endIF
endIF

restArea(aAreaBE4)
restArea(aAreaBD5)
restArea(aAreaBAU)
restArea(aAreaSA2)

return aret

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Detalhe
Essa função é um mero detalhe
@author Oscar Zanin
@since  08/10/2019
@version P12
/*/
//------------------------------------------------------------------------------------------
static function Detalhe()
Local cSql := ""
Local aStruc := {}

aadd(aStruc, { "MATRICULA","C",TamSX3("RC_MAT")[1],0})
aadd(aStruc, { "NOMMAT","C",30,0})
aadd(aStruc, { "VERBA","C",TamSX3("RC_PD")[1],0})
aadd(aStruc, { "DESVER","C",20,0})
aadd(aStruc, { "VALOR", "N", 16, 2})
aadd(aStruc, { "CCUSTO","C",20,0})
aadd(aStruc, { "DESCUS","C",50,0})
aadd(aStruc, { "SEM","C",TamSX3("RC_SEMANA")[1],0})
aadd(aStruc, { "PER","C",TamSX3("RC_PERIODO")[1],0})
aadd(aStruc, { "PROCESSO","C",TamSX3("RC_PROCES")[1],0})
aadd(aStruc, { "ROT","C",TamSX3("RC_ROTEIR")[1],0})
aadd(aStruc, { "TABELA","C",3,0})
	
oTempTable := FWTemporaryTable():New( "M240DET" )
oTemptable:SetFields( aStruc )
oTempTable:Create()

cSql += " SELECT MATRICULA, RA_NOME, VERBA, RV_DESC, VALOR, CCUSTO, CTT_DESC01, SEM, PER, PROCESSO, ROT, TABELA FROM ("
cSql += " Select RC_MAT MATRICULA, RC_PD VERBA, RC_VALOR VALOR, RC_SEMANA SEM, RC_PERIODO PER, RC_PROCES PROCESSO, RC_ROTEIR ROT, 'SRC' TABELA, RC_CC CCUSTO from "
cSql += retSqlName("SRC") + " SRC "
cSql += " WHERE "
cSql += " RC_FILIAL = '" + xfilial("SRC") + "' "
cSql += " AND RC_LOTPLS = '" + B5E->B5E_LOTSRC + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " Union "
cSql += " Select RD_MAT MATRICULA, RD_PD VERBA, RD_VALOR VALOR, RD_SEMANA SEM, RD_PERIODO PER, RD_PROCES PROCESSO, RD_ROTEIR ROT, 'SRD' TABELA, RD_CC CCUSTO from "
cSql += retSqlName("SRD") + " SRD "
cSql += " WHERE "
cSql += " RD_FILIAL = '" + xfilial("SRD") + "' "
cSql += " AND RD_LOTPLS = '" + B5E->B5E_LOTSRC + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " Union "
cSql += " Select RGB_MAT MATRICULA, RGB_PD VERBA, RGB_VALOR VALOR, RGB_SEMANA SEM, RGB_PERIOD PER, RGB_PROCES PROCESSO, RGB_ROTEIR ROT, 'RGB' TABELA, RGB_CC CCUSTO from "
cSql += retSqlName("RGB") + " RGB "
cSql += " WHERE "
cSql += " RGB_FILIAL = '" + xfilial("RGB") + "' "
cSql += " AND RGB_LOTPLS = '" + B5E->B5E_LOTSRC + "' "
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " ) TMP "
cSql += " LEFT JOIN " + retSqlName("SRV") + " RV "
cSql += " ON RV_FILIAL = '" + xfilial("SRV") + "' "
cSql += " AND RV_COD = VERBA "
cSql += " AND RV.D_E_L_E_T_ = ' ' "
cSql += " LEFT JOIN " + retSqlName("SRA") + " RA "
cSql += " ON RA_FILIAL = '" + xfilial("SRA") + "' "
cSql += " AND RA_MAT = MATRICULA "
cSql += " AND RA.D_E_L_E_T_ = ' ' "
cSql += " LEFT JOIN " + retSqlName("CTT") + " CTT "
cSql += " ON CTT_FILIAL = '" + xfilial("CTT") + "' "
cSql += " AND CTT_CUSTO = CCUSTO "
cSql += " AND CTT.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY MATRICULA, VERBA "

cSql := " Insert Into " +  oTempTable:getrealName() + " (MATRICULA, NOMMAT, VERBA, DESVER, VALOR, CCUSTO, DESCUS, SEM, PER, PROCESSO, ROT, TABELA ) " + cSql 
PLSCOMMIT(cSql)

M240DET->(dbselectarea("M240DET"))

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} NextRGB
O correto para geração da integração é que seja um periodo/semana somente para os lançamentos do PLS.
Mas caso a semana do GPE esteja aberta com registros do GPE não irá misturar o que é do PLS com o que é do GPE.

@author    Lucas Nonato
@version   V12
@since     05/12/2019
/*/
static function NextRGB(cMAT, cCodPD, cCenCust)
Local cSeqRGB := "1"
	
RGB->(dbSetOrder(1))
RGB->(dbSeek(xFilial("RGB")+cMAT))

//a RGB é totalmente limpa a cada fechamento de folha
if RGB->(eof())
	cSeqRGB := "1"
else
	If RGB->(msSeek(RGB->RGB_FILIAL+cMAT+cCodPD+cCenCust+RGB->RGB_SEMANA+cSeqRGB))
		cSeqRGB := RGB->RGB_SEQ
		while (RGB->(RGB_FILIAL+RGB_MAT+RGB_PD+RGB_CC+RGB_SEMANA+RGB_SEQ)) == (RGB->RGB_FILIAL + cMAT + cCodPD + cCenCust + RGB->RGB_SEMANA + cSeqRGB)
			cSeqRGB := soma1(cSeqRGB,Len(cSeqRGB))
			RGB->(dbskip())
		enddo
	endif
endif

return alltrim(cSeqRGB)

//retorna o CPF, só é uma função separada pra caso precisemos ir na SRA em algum momento futuro
static function retCPF()
local cRet := ""

cret := BAU->BAU_CPFCGC

return cRet

//Retorna o valor de desconto de INSS do lote de pagamento para a RDA
static function RetDescINSS( nRecno )
Local nRet := 0
Local aArea := BMR->(getarea())
Local aBAUArea := BAU->(getarea())
Local lAbate := .F.

BMR->(dbgoto(nRecno))

//Essa condição foi adicionada por existir na geração do lote de pagamento
//com CALIMP 3 e o MV com 1, o Valor do INSS é abatido antes da base para cálculo do imposto
//Nas demais situações, a base é gravada sem abater o INSS e precisa abater nesse momento
BAU->(dbsetOrder(1))
If lINSSIR .AND. BAU->(MsSeek(xFilial("BAU") + BMR->(BMR_CODRDA)))
	lAbate := BAU->BAU_CALIMP <> "3"
endif

if lAbate
	BMR->(dbsetOrder(1))
	//Busca o INSS dentro do mesmo lote pra mesma RDA (183 = Desconto INSS)
	if BMR->(MsSeek( xFilial("BMR") + BMR->(BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "183" ))
		nRet := BMR->BMR_VLRPAG
	endif
endif
restArea(aArea)
restArea(aBAUArea)

return nRet
