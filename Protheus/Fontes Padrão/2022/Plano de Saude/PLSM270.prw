#DEFINE CRLF chr( 13 ) + chr( 10 )
#DEFINE THREADSLOCK iif(GetNewPar("MV_PLJOBMN", 5) > 15, 15, GetNewPar("MV_PLJOBMN", 5))
#DEFINE QTDMAXGUI	GetNewPar("MV_PLQTMON",10000)

#Include "Plsmger.ch"
#Include "Colors.ch"
#Include "TopConn.ch"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "FILEIO.CH"

#define K_Pesquisar			1   //   Pesquisar
#define K_Visualizar        2   //   Visualizar
#define K_Incluir           3   //   Incluir
#define K_Alterar           4   //   Alterar
#define K_Excluir           5   //   Excluir

#define PROCESSAR			1
#define REENVIAR			2
#define REPROCESSAR			3

#define DIGITACAO "1"
#define PAGAMENTO "2"
#define BAIXA 	  "3"
#define REEMBOLSO "4"
#define FORDIRETO "5"
#define ALTERACAO "6"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM270
Tela MVC com FWMarkBrowse no Monitoramento TISS 
@author Lucas Nonato
@since  11/08/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSM270()
private oMBrwB4M 
private __aRet		:= {}	

cFilter := PLSM270FIL(.f.)
setKey(VK_F2 ,{|| cFilter := PLSM270FIL(.t.) })

B4M->(dbsetorder(1))
B4N->(dbsetorder(1))
B4O->(dbsetorder(1))
B4P->(dbsetorder(1))
B4U->(dbsetorder(1))

oMBrwB4M:= FWMarkBrowse():New()
oMBrwB4M:SetAlias("B4M")
oMBrwB4M:SetDescription("Monitoramento TISS - Arquivos" )
oMBrwB4M:SetMenuDef("PLSM270")
oMBrwB4M:AddLegend("B4M_STATUS == '1'", "WHITE",	"Processado (sem críticas)" )
oMBrwB4M:AddLegend("B4M_STATUS == '2'", "PINK",		"Processado (criticado)" )
oMBrwB4M:AddLegend("B4M_STATUS == '3'", "BROWN",	"Arq. envio (sem críticas)" )
oMBrwB4M:AddLegend("B4M_STATUS == '4'", "BLACK",	"Arq. envio (criticado)" )
oMBrwB4M:AddLegend("B4M_STATUS == '5'", "BLUE",		"Arq. retorno (sem críticas)" )
oMBrwB4M:AddLegend("B4M_STATUS == '6'", "YELLOW",	"Arq. retorno (criticado)" )
oMBrwB4M:AddLegend("B4M_STATUS == '7'", "RED",		"Arq. qualidade (criticado)" )
oMBrwB4M:AddLegend("B4M_STATUS == '8'", "GREEN",	"Encerrado" )
oMBrwB4M:AddLegend("B4M_STATUS == '9'", "ORANGE",	"Encerrado (reprocessado)." )
oMBrwB4M:SetFieldMark( 'B4M_OK' )	
oMBrwB4M:SetAllMark({ ||  A270Inverte(@oMBrwB4M) })
oMBrwB4M:SetFilterDefault(cFilter)
oMBrwB4M:SetWalkThru(.F.)
oMBrwB4M:SetAmbiente(.F.)
oMBrwB4M:ForceQuitButton()
oMBrwB4M:Activate()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Jonatas Almeida
@version   1.xx
@since     11/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina Title 'Processar Envio'		Action 'staticCall( PLSM270,procEnvio )'		OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Gerar Arq. Envio'		Action 'PLSM270XTE'								OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Detalhar Arquivo'		Action 'msgRun( "Abrindo janela de detalhes...","Processando, por favor aguarde",{|| PLSM270Det() } )'	OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title 'Imp. Arq. Retorno'	Action 'PLSM270XTR'								OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Rel. Monitoramento'	Action 'PLSR270'								OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Excluir'				Action 'Processa({||P270DELETE()},"Monitoramento TISS - Exclusao","Processando...",.T.)'		OPERATION MODEL_OPERATION_DELETE ACCESS 0	
	ADD OPTION aRotina Title 'Reenvio Guias Criticadas' Action 'staticCall( PLSM270,envCritANS )'	OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Reprocessar Envio' 	Action 'staticCall( PLSM270,reprocMon )'		OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Validar Lote' 		Action 'Processa({||PLSM270VLD()},"Monitoramento TISS - Validação","Processando...",.T.)'		OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title "<F2> - Filtrar" 		Action 'PLSM270FIL(.t.)'    					OPERATION MODEL_OPERATION_INSERT ACCESS 0 
	ADD OPTION aRotina Title "Conf Pré-Envio" 		Action 'msgRun( "Abrindo janela de detalhes...","Processando, por favor aguarde",{|| PLSM270PRE() } )' OPERATION MODEL_OPERATION_INSERT ACCESS 0 
	ADD OPTION aRotina Title "Competencia x Guias" 	Action 'msgRun( "Abrindo janela de detalhes...","Processando, por favor aguarde",{|| PLSM27CMP() } )' OPERATION MODEL_OPERATION_INSERT ACCESS 0 
	ADD OPTION aRotina Title "Gerar sem movimento" 	Action 'PLSM270SMV' OPERATION MODEL_OPERATION_INSERT ACCESS 0 

	// Ponto Entrada para adicionar rotinas no menu
	If( existBlock( "PLSTMON4" ) )
		aRotina := execBlock( "PLSTMON4",.F.,.F.,{ aRotina } )
	EndIf	
return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Jonatas Almeida
@version   1.xx
@since     11/08/2016
/*/
//------------------------------------------------------------------------------------------
static function ModelDef()
	local oStruB4M := FWFormStruct( 1,'B4M',/*bAvalCampo*/,/*lViewUsado*/ )
	
	local oModel
	
	//--< DADOS DO LOTE >---
	oModel := MPFormModel():New( 'Monitoramento' )
	oModel:AddFields( 'MODEL_B4M',,oStruB4M )
		
	oModel:SetDescription( "Monitoramento TISS" )
	oModel:GetModel( 'MODEL_B4M' ):SetDescription( ".:: Monitoramento TISS ::." )
	oModel:SetPrimaryKey( { "B4M_FILIAL","B4M_SUSEP","B4M_CMPLOT","B4M_NUMLOT","B4M_NMAREN" } )

return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Jonatas Almeida
@version   1.xx
@since     11/08/2016
/*/
//------------------------------------------------------------------------------------------
static function ViewDef()
	Local oView     := nil
	Local oModel	:= FWLoadModel( 'PLSM270' )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM270JOB
Faz o processamento do Monitoramento em Job

@author  Lucas Nonato
@version P11
@since   07/04/2017
/*/
//-------------------------------------------------------------------
function PLSM270JOB(lEnd, nTipo, lAutomacao)
local nX		:= 1
local nZ		:= 1
local nQtdAnt	:= 0
local nQtdFull	:= 0
local nLoop		:= 0
local cLotGrv	:= ""
local cSqlName 	:= ""
local cSusep 	:= ""
local cAliBase	:= getNextAlias()
local cAlias	:= getNextAlias()
local cini		:= time()
local cfim		
local aLote		:= {}
local aLoteAnt	:= {}
local nTpDtRec	:= val(cvaltochar(__aRet[13]))
private oTmpBase	:= nil
private oTmpTable	:= nil

default lEnd 	:= .f.
default nTipo 	:= 1 //1=Processamento;2=Exclusão;3=Alteração
default lAutomacao := .F.

BA0->( dbSetOrder(1)) // BA0_FILIAL, BA0_CODIDE, BA0_CODINT
// Número do SUSEP
if BA0->(dbSeek(xFilial("BA0")+allTrim( __aRet[ 1 ])))
	cSusep := BA0->BA0_SUSEP 
endif

fCriaBase(cAliBase,@oTmpBase)
fCriaTmp(cAlias,@oTmpTable)

procLote( @aLote,, allTrim( __aRet[ 2 ] + __aRet[ 3 ] ) )

oProcess:SetRegua1( 8 ) //Alimenta a primeira barra de progresso
PLSBD5BASE(oTmpBase, aLote)
PLSBE4BASE(oTmpBase, aLote)

if __aRet[12] == "1"
	cSql := " DELETE FROM " + oTmpBase:getrealName() + " WHERE EXISTS (
	cSql += " SELECT 1 FROM " + RetSqlName("B4N") + " B4N "
	cSql += " WHERE B4N_FILIAL = '" + xFilial("B4N") + "' "
	cSql += " AND B4N_SUSEP = '" + cSusep + "' "
	cSql += " AND B4N_CMPLOT = '" + __aRet[ 2 ] + __aRet[ 3 ] + "' "
	cSql += " AND B4N_CODLDP = " + oTmpBase:getrealName() + ".CODLDP "
	cSql += " AND B4N_CODPEG = " + oTmpBase:getrealName() + ".CODPEG "
	cSql += " AND B4N_NUMERO = " + oTmpBase:getrealName() + ".NUMERO " 
	cSql += " AND B4N.D_E_L_E_T_ = ' ' )"
	PLSCOMMIT(cSql)
endif

if nTpDtRec == 1 // 1=Reconh/Emiss
	PLS270Dig(aLote)
endif

if nTpDtRec == 2
	PLS270Baixa(aLote)
	PLS270GlInt(aLote)
endif

PLS270pag(nTpDtRec, aLote)
PLS270Reemb(aLote)
PLS270Forn(aLote)
PLS270Alt(aLote)
PLS270RmbBx(aLote)

if nTipo == 2
	PLSZTCExc(aLote)
elseif nTipo == 3
	PLSZTCAlt(aLote)
endif
//ajuste de performance, as guias de resumo de internação estavam caindo todas em uma unica thread, no final da divisão serão separadas em todas.
hubGuias(.t.)

fErase("\logpls\"+dtos(date())+"\logMonit.log")

aLoteAnt := aclone(aLote)

cSql := "SELECT COUNT(*) QTD FROM " + oTmpTable:getrealName()
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
nQtd 	 := TrbFim->QTD
nQtdFull := TrbFim->QTD
TrbFim->(dbCloseArea())

if THREADSLOCK == 1
 	oProcess:SetRegua2( nQtdFull ) 
else
	oProcess:SetRegua2( -1 ) 
endif

cSqlName 	:= oTmpTable:getrealName()

if THREADSLOCK == 1 
	PLPROCMONIT( "01", cEmpAnt, cFilAnt, __aRet, @lEnd, oTmpTable:getrealName(),aLote, THREADSLOCK) 
else
	if substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" .or. Upper(TCGetDb()) =="POSTGRES"
		TcSqlEXEC("DROP TABLE TEMPMONIT1")
   		nRet := TcSqlEXEC(" CREATE TABLE TEMPMONIT1 AS SELECT * FROM " + oTmpTable:getrealName() )
		if nRet >= 0
			TcSqlEXEC("COMMIT") 
		endif
		cSqlName := 'TEMPMONIT1'		
	endif
	for nX := 1 to THREADSLOCK
	 	startJob("PLPROCMONIT",GetEnvServer(),.F.,strzero(nX,2), cEmpAnt, cFilAnt, __aRet, lEnd, cSqlName, aLote, THREADSLOCK)
	next
endif

while nQtd <> 0	
	nQtdAnt := nQtd
	cSql := "SELECT COUNT(*) QTD FROM " + cSqlName + " WHERE OK = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
	nQtd := TrbFim->QTD
	TrbFim->(dbCloseArea())
	if nQtd == nQtdAnt
		nLoop++
	else
		nLoop := 0
	endif 
	oProcess:IncRegua2( "[" + cvaltochar(nQtdFull - nQtd) +  "] de [" + cvaltochar(nQtdFull) + "]"  )
	if nQtd <> 0
		nZ++
		if nZ == 60
			nZ := 0
			monitorJobs(cEmpAnt, cFilAnt, __aRet, lEnd, cSqlName, aLote)
		else
			sleep(5000)
		endif
		
	endif
	if nLoop == 50
		exit
	endif
enddo

if nQtdFull > 0	
	BeginSQL Alias "TrbLot"
		SELECT B4M_NUMLOT, B4M_CMPLOT, B4M_QTRGPR
		FROM %table:B4M% B4M
		WHERE
		B4M_FILIAL = %xFilial:B4M% AND
		B4M_SUSEP  = %exp:aLoteAnt[3]% AND
		B4M_CMPLOT = %exp:aLoteAnt[2]% AND
		B4M_NUMLOT >= %exp:aLoteAnt[1]% AND		
		B4M.%notDel%
	EndSQL
	while !TrbLot->(eof())	
		if !(TrbLot->B4M_NUMLOT $ cLotGrv) .and. !excLotAlt(aLote)
			aLote[2] := TrbLot->B4M_CMPLOT
			aLote[1] := TrbLot->B4M_NUMLOT
			oProcess:IncRegua1( "Validando Lote: [" + aLote[2] + "] " + aLote[1]  ) 
			PLVLDMON( aLote )
			cLotGrv += "[" + TrbLot->B4M_CMPLOT + "] " + TrbLot->B4M_NUMLOT + CRLF			
		endif
		TrbLot->(dbskip())
	enddo
	TrbLot->(dbclosearea())		
endif

if empty(cLotGrv)
	excLotAlt(aLote)
endif

//chama regra do valor de Contrato Preestabelecido
//if !empty(GetNewPar("MV_PLIDCPR",""))
	PROVLRPREE(@cLotGrv)
//endif

cfim := time()	
if !empty(cLotGrv)
	PlsPtuLog("Lote(s) criado(s): " + CRLF + cLotGrv + CRLF + 'Inicio: ' + cvaltochar( cini ) + "  -  " + 'Fim: ' + cvaltochar( cfim ) + ' - Tempo: ' + ElapTime( cini, cfim ), "Monit.log")
	If !lAutomacao
		telaLog(cini,cfim,cLotGrv,cSqlName)
	EndIf
else
	If !lAutomacao
		msgAlert( "Nenhum registro encontrado ao processar o envio de dados!" )
	EndIf
	excLotAlt(aLote)
endif

(cAlias)->(dbclosearea())
(cAliBase)->(dbclosearea())

oTmpTable:Delete()
freeObj(oTmpTable)               
oTmpTable := nil

oTmpBase:Delete()
freeObj(oTmpBase)               
oTmpBase := nil

return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaBase
Cria tabela temporaria da base a ser processada.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
static function fCriaBase(cAlias,oTmpTable)
local aColumns	 := {}
	
if Select(cAlias) > 0
	if oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	endif 	
endif 

aAdd( aColumns, { "CODOPE"	,"C",04,00 })
aAdd( aColumns, { "CODLDP"	,"C",04,00 })
aAdd( aColumns, { "CODPEG"	,"C",08,00 })
aAdd( aColumns, { "NUMERO"	,"C",08,00 })
aAdd( aColumns, { "CODRDA"	,"C",06,00 })
aAdd( aColumns, { "TIPGUI"	,"C",02,00 })
aAdd( aColumns, { "DTDIGI"	,"C",08,00 })
aAdd( aColumns, { "DTPAGT"	,"C",08,00 })
aAdd( aColumns, { "DTANAL"	,"C",08,00 })
aAdd( aColumns, { "FASE"	,"C",01,00 })
aAdd( aColumns, { "LOTMOP"	,"C",18,00 })
aAdd( aColumns, { "LOTMOF"	,"C",18,00 })

oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aColumns )
oTmpTable:Create()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaBase
Cria tabela temporaria processada.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
static function fCriaTmp(cAlias,oTmpTable,lReenv)
local aColumns	 := {}
default lReenv   := .f.
	
If Select(cAlias) > 0
	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf 	
EndIf 

aAdd( aColumns, { "CODOPE"	,"C",04,00 })
aAdd( aColumns, { "CODLDP"	,"C",04,00 })
aAdd( aColumns, { "CODPEG"	,"C",08,00 })
aAdd( aColumns, { "NUMERO"	,"C",08,00 })
aAdd( aColumns, { "CODRDA"	,"C",06,00 })
aAdd( aColumns, { "DTDIGI"	,"C",08,00 })
aAdd( aColumns, { "DTPAGT"	,"C",08,00 })
aAdd( aColumns, { "TIPO"	,"C",01,00 })
aAdd( aColumns, { "TIPGUI"	,"C",02,00 })
aAdd( aColumns, { "FLAG"	,"C",02,00 })
aAdd( aColumns, { "OK"		,"C",01,00 })
if lReenv
	aAdd( aColumns, { "CMPLOT"		,"C",06,00 })
	aAdd( aColumns, { "NUMLOT"		,"C",12,00 })
endif
oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aColumns ) 
oTmpTable:Create() 

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBD5BASE
Query base da BD5
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSBD5BASE(oTmpBase,aLote)
local cSql 		:= ""

cSql += "  SELECT BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_CODRDA, BD5_TIPGUI, BD5_DTDIGI, BD5_DTPAGT, BD5_DTANAL, BD5_LOTMOP, BD5_LOTMOF, BD5_FASE "
cSql += " 	FROM " + RetSqlName("BD5") + " BD5 "
if allTrim( __aRet[ 11 ]) == '1'
	cSql += " INNER JOIN " + RetSqlName("BA1") + " BA1 "
	cSql += "  ON BA1_FILIAL = BD5_FILIAL "
	cSql += "  AND BA1_CODINT = BD5.BD5_OPEUSR "
	cSql += "  AND BA1_CODEMP = BD5.BD5_CODEMP "
	cSql += "  AND BA1_MATRIC = BD5.BD5_MATRIC "
	cSql += "  AND BA1_TIPREG = BD5.BD5_TIPREG "
	cSql += "  AND BA1_DIGITO = BD5.BD5_DIGITO "
	cSql += "  AND BA1_INFANS = '1' "
	cSql += "  AND BA1.D_E_L_E_T_ = ' ' "
endif
cSql += " WHERE BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += " 	AND BD5_CODOPE  = '" + __aRet[ 1 ] + "' "
cSql += " 	AND BD5_CODLDP IN " + __aRet[ 6 ] + " " //Local de Digitação de ? 
cSql += " 	AND BD5_CODPEG BETWEEN '" + __aRet[ 7 ] + "' AND '" + __aRet[ 8 ] + "' "  //Protocolo de ? 
if __aRet[ 15 ] == "1" //1-Guias ativas; 2-Guias diferente de canceladas (ativas e bloqueadas)
	cSql += " 	AND BD5_SITUAC <> '2' "//1=Ativa;2=Cancelada;3=Bloqueada
else
	cSql += " 	AND BD5_SITUAC = '1' "//1=Ativa;2=Cancelada;3=Bloqueada
endif
cSql += "  AND BD5_FASE IN ('3', '4')  " 
if !empty(__aRet[ 4 ])
	cSql += "  AND BD5_CODRDA BETWEEN '" + __aRet[ 4 ] + "' AND '" + __aRet[ 5 ] + "' " //RDA de ? RDA ate ?
endif

if substr(cValToChar(__aRet[9]),1,1) == '2' // Guia Estornada 1=Sim,2=Nao
	cSql += " AND BD5_GUESTO = ' '  " 
	cSql += " AND BD5_ESTORI = ' '  " 
endif
cSql += "  AND BD5.D_E_L_E_T_ = ' '"

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpBase:getrealName() + " (CODOPE, CODLDP, CODPEG, NUMERO, CODRDA, TIPGUI, DTDIGI, DTPAGT, DTANAL, LOTMOP, LOTMOF, FASE) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Base BD5" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBE4BASE
Query base da BE4
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSBE4BASE(oTmpBase,aLote)
local cSql 		:= ""

cSql += "  SELECT BE4_CODOPE, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO, BE4_CODRDA, BE4_TIPGUI, BE4_DTDIGI, BE4_DTPAGT, BE4_DTANAL, BE4_LOTMOP, BE4_LOTMOF, BE4_FASE "
cSql += " 	FROM " + RetSqlName("BE4") + " BE4 "
cSql += " INNER JOIN " + RetSqlName("BA1") + " BA1 "
cSql += "  ON BA1_FILIAL = BE4_FILIAL "
cSql += "  AND BA1_CODINT = BE4.BE4_OPEUSR "
cSql += "  AND BA1_CODEMP = BE4.BE4_CODEMP "
cSql += "  AND BA1_MATRIC = BE4.BE4_MATRIC "
cSql += "  AND BA1_TIPREG = BE4.BE4_TIPREG "
cSql += "  AND BA1_DIGITO = BE4.BE4_DIGITO "
cSql += iif(allTrim( __aRet[ 11 ]) == '2',""," AND BA1_INFANS = '1' " )
cSql += "  AND BA1.D_E_L_E_T_ = ' ' "
cSql += " WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
cSql += " 	AND BE4_CODOPE  = '" + __aRet[ 1 ] + "' "
cSql += " 	AND BE4_CODLDP IN " + __aRet[ 6 ] + " "                                   //Local de Digitação de ? 
cSql += " 	AND BE4_CODPEG BETWEEN '" + __aRet[ 7 ] + "' AND '" + __aRet[ 8 ] + "' "  //Protocolo de ? 
if __aRet[ 15 ] == "1" //1-Guias ativas; 2-Guias diferente de canceladas (ativas e bloqueadas)
	cSql += " 	AND BE4_SITUAC <> '2' "//1=Ativa;2=Cancelada;3=Bloqueada
else
	cSql += " 	AND BE4_SITUAC = '1' "//1=Ativa;2=Cancelada;3=Bloqueada
endif
if !empty(__aRet[ 4 ])
	cSql += "  AND BE4_CODRDA BETWEEN '" + __aRet[ 4 ] + "' AND '" + __aRet[ 5 ] + "' " //RDA de ? RDA ate ?
endif
if substr(cValToChar(__aRet[9]),1,1) == '2' // Guia Estornada 1=Sim,2=Nao
	cSql += " AND BE4_GUESTO = ' '  " 
	cSql += " AND BE4_ESTORI = ' '  " 
endif
cSql += "  AND BE4_FASE IN ('3', '4')  " 
cSql += "  AND BE4_TIPGUI = '05'  " 
cSql += "  AND BE4.D_E_L_E_T_ = ' '"

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpBase:getrealName() + " (CODOPE, CODLDP, CODPEG, NUMERO, CODRDA, TIPGUI, DTDIGI, DTPAGT, DTANAL, LOTMOP, LOTMOF, FASE) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Base BE4" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Dig
Query base para envio do reconhecimento baseado na data de digitação
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Dig(aLote)
local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += "SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '1' TIPO, TIPGUI, DTDIGI, '' DTPAGT FROM " + oTmpBase:getrealName()
cSql += " WHERE TIPGUI <> '04' "
cSql += "  AND DTDIGI BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += "  AND DTPAGT NOT BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += "  AND LOTMOP = ' ' "
cSql += "  AND LOTMOF = ' ' "
cSql += "  AND CODRDA <> '" + cRdaProp + "' "
cSql += "  AND TIPGUI <> '10' "
cSql += "  UNION "
cSql += "SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '1' TIPO, TIPGUI, DTDIGI, DTPAGT FROM " + oTmpBase:getrealName()
cSql += " WHERE TIPGUI <> '04' "
cSql += "  AND DTDIGI BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += "  AND DTPAGT BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += "  AND LOTMOP = ' ' "
cSql += "  AND LOTMOF = ' ' "
cSql += "  AND CODRDA <> '" + cRdaProp + "' "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTDIGI, DTPAGT) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Digitação" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Pag
Query base para envio do reconhecimento e pagamento dependendo do tipo de envio.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Pag(nTpDtRec,aLote)

local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += "SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '2' TIPO, TIPGUI, DTPAGT FROM " + oTmpBase:getrealName()
cSql += " WHERE TIPGUI <> '04' "
cSql += "  AND DTPAGT BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
if nTpDtRec == 1 //1=Reconh/Emiss, 2=Anali/Baixa
	cSql += "  AND LOTMOP <> ' ' "
endif
cSql += "  AND LOTMOF = ' ' "
cSql += "  AND CODRDA <> '" + cRdaProp + "' "

if nTpDtRec == 1 //1=Reconh/Emiss, 2=Anali/Baixa
	cSql += "UNION "
	cSql += "SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '2' TIPO, TIPGUI, DTPAGT FROM " + oTmpBase:getrealName()
	cSql += " WHERE TIPGUI <> '04' "
	cSql += "  AND DTPAGT BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "	
	cSql += "  AND DTDIGI NOT BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
	cSql += "  AND LOTMOP = ' ' "
	cSql += "  AND CODRDA <> '" + cRdaProp + "' "
else
	cSql += "  AND CODPEG || NUMERO NOT IN (SELECT CODPEG || NUMERO FROM " +  oTmpTable:getrealName() + ") "
endif

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, " + iif(nTpDtRec == 1 , "DTPAGT", "DTDIGI") + ") " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Pagamento" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Baixa
Query base para envio do pagamento com base na data de baixa do titulo.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Baixa(aLote)
local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += " SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '3' TIPO, TIPGUI, E2_BAIXA DTPAGT FROM " + oTmpBase:getrealName()
cSql += " INNER JOIN( "
cSql += " 	SELECT BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,E2_BAIXA FROM " + RetSqlName("BD7") + " BD7 "
cSql += " 	INNER JOIN( "
cSql += " 		SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_CODRDA,E2_B.E2_BAIXA FROM " + RetSqlName("SE2") + " SE2 "
cSql += " 		INNER JOIN(  "
cSql += " 			SELECT E2_BAIXA,R_E_C_N_O_ FROM " + RetSqlName("SE2") + " SE2 "
cSql += " 			WHERE D_E_L_E_T_ = ' ') E2_B "
cSql += " 		ON E2_B.R_E_C_N_O_ = SE2.R_E_C_N_O_  "
cSql += " 		AND E2_B.E2_BAIXA BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += " 		AND SE2.E2_CODRDA <> ' ' ) E2_C "
cSql += " 	ON 	BD7_FILIAL = '" + xFilial("BD7") + "' "
cSql += " 	AND BD7_CHKSE2 = E2_C.E2_FILIAL || '|' || E2_C.E2_PREFIXO || '|' || E2_C.E2_NUM || '|' || E2_C.E2_PARCELA || '|' || E2_C.E2_TIPO || '|' || E2_C.E2_FORNECE || '|' || E2_C.E2_LOJA "
cSql += " 	AND BD7_CODRDA = E2_C.E2_CODRDA "
cSql += " 	AND BD7.D_E_L_E_T_ = ' ' ) BD72 " 
cSql += " ON  BD7_CODOPE = CODOPE  "
cSql += " AND BD7_CODLDP = CODLDP  "
cSql += " AND BD7_CODPEG = CODPEG  "
cSql += " AND BD7_NUMERO = NUMERO  "
cSql += " AND CODRDA <> '" + cRdaProp + "' "
cSql += " AND LOTMOF = ' ' "
cSql += " GROUP BY CODOPE,CODLDP,CODPEG,CODRDA,NUMERO,TIPGUI,E2_BAIXA "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTPAGT) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Baixa" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1] )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Reemb
Query base para envio do reconhecimento do reembolso
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Reemb(aLote)

local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += "SELECT TEMP3.CODOPE, TEMP3.CODLDP, TEMP3.CODPEG, TEMP3.CODRDA, TEMP3.NUMERO, '7' TIPO, '04' TIPGUI, TEMP3.DTDIGI FROM " + oTmpBase:getrealName() + " BASE "
cSql += " INNER JOIN ("
cSql += "	SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '4' TIPO, TIPGUI, DTDIGI FROM " + RetSqlName("SE2") + " SE2, ( "
cSql += "		SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '4' TIPO, TIPGUI, DTDIGI, PREFIX, NUM  FROM ("
cSql += "		 	SELECT B44_OPEMOV CODOPE, B44_CODLDP CODLDP, B44_CODPEG CODPEG, B44_NUMGUI NUMERO, '04' TIPGUI, BD5_CODRDA CODRDA, '  ' FLAG , "
cSql += "			BD5_LOTMOP LOTMOP, BD5_LOTMOF LOTMOF, B44_B.B44_DTLBFN DTDIGI, B44_B.B44_PREFIX PREFIX,B44_B.B44_NUM NUM   "
cSql += "		 	FROM " + RetSqlName("B44") + " B44 "
cSql += "		 	INNER JOIN ( 
cSql += "				SELECT B44_DTLBFN, R_E_C_N_O_ RECNO, B44_PREFIX, B44_NUM "
cSql += "		 		FROM " + RetSqlName("B44") + " B44 "
cSql += "		        WHERE B44.D_E_L_E_T_ = ' ') B44_B "
cSql += "		    ON B44_B.RECNO = B44.R_E_C_N_O_  "
cSql += "			AND B44_B.B44_DTLBFN BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += "		  	INNER JOIN " + RetSqlName("BD5") + " BD5 "
cSql += "		  	ON BD5_FILIAL  = '" + xFilial("BD5") + "' "
cSql += "		 	AND BD5_CODOPE = B44.B44_OPEMOV "
cSql += "		 	AND BD5_CODLDP = B44.B44_CODLDP "
cSql += "		 	AND BD5_CODPEG = B44.B44_CODPEG "
cSql += "		 	AND BD5_NUMERO = B44.B44_NUMGUI "
cSql += "		 	AND BD5.D_E_L_E_T_ = ' ' "
cSql += "		 ) TEMP "
cSql += "		 WHERE LOTMOP = ' ' "
cSql += "		 AND LOTMOF = ' ' ) TEMP2 "
cSql += "	 WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
cSql += "	 AND E2_PREFIXO = PREFIX  "
cSql += "	 AND E2_NUM = NUM "
cSql += "	 AND E2_BAIXA = ' ' "
cSql += "	 AND SE2.D_E_L_E_T_ = ' ') TEMP3 "
cSql += " ON  BASE.CODOPE = TEMP3.CODOPE  "
cSql += " AND BASE.CODLDP = TEMP3.CODLDP  "
cSql += " AND BASE.CODPEG = TEMP3.CODPEG  "
cSql += " AND BASE.NUMERO = TEMP3.NUMERO  "
cSql += " AND BASE.CODRDA <> '" + cRdaProp + "' "

cSql := changequery(cSql)

cSql := " Insert Into " + oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTDIGI) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Reembolso" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Forn
Query base para envio do fornecimento direto.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Forn(aLote)

local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += "SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '5' TIPO, TIPGUI, DTDIGI FROM (
cSql += "	SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPGUI, DTDIGI FROM " + oTmpBase:getrealName()
cSql += "	  WHERE TIPGUI <> '04' "
cSql += "	  AND CODRDA = '" + cRdaProp + "' "
cSql += "  	  AND DTDIGI BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' "
cSql += "	  AND LOTMOF = ' ' ) FORN "
cSql += " INNER JOIN " + RetSqlName("B19") + " B19 "		
cSql += " ON  B19_FILIAL               = '" + xFilial("B19") + "' "
cSql += " AND SUBSTRING(B19_GUIA,1,4)  = CODOPE "
cSql += " AND SUBSTRING(B19_GUIA,5,4)  = CODLDP "
cSql += " AND SUBSTRING(B19_GUIA,9,8)  = CODPEG "
cSql += " AND SUBSTRING(B19_GUIA,17,8) = NUMERO "
cSql += " AND B19.D_E_L_E_T_ = ' ' "
cSql += " GROUP BY CODOPE,CODLDP,CODPEG,CODRDA,NUMERO,TIPGUI,DTDIGI "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTDIGI) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Fornecimento Direto" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Alt
Query base para envio das guias de alteração.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Alt(aLote)
local cSql 		:= ""

cSql += " SELECT CODOPE,CODLDP,CODPEG,CODRDA,NUMERO,'6' TIPO,TIPGUI,DTDIGI,DTPAGT FROM (" 
cSql += " 	SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '6' TIPO, TIPGUI, B4N_DTPRGU DTDIGI, B4N_DTPAGT DTPAGT, "
cSql += " 	       B4N_FILIAL, B4N_SUSEP, B4N_CMPLOT, B4N_NUMLOT, DTANAL FROM " + oTmpBase:getrealName()
cSql += " 	INNER JOIN " + RetSqlName("B4N") + " B4N "
cSql += " 	ON B4N_FILIAL = '" + xFilial("B4N") + "' "
cSql += " 	AND B4N_CMPLOT = '" + __aRet[ 2 ] + __aRet[ 3 ] + "'"
cSql += " 	AND ( B4N_NUMLOT = SUBSTRING(LOTMOF, 7, 12) or B4N_NUMLOT = SUBSTRING(LOTMOP, 7, 12)) "
cSql += " 	AND B4N_CODPEG = CODPEG "
cSql += " 	AND B4N_NUMERO = NUMERO "
cSql += " 	AND B4N.D_E_L_E_T_ = ' ' "
cSql += " 	WHERE (LOTMOF <> ' ' AND SUBSTRING(LOTMOF, 1, 6) = '" + __aRet[ 2 ] + __aRet[ 3 ] + "' AND SUBSTRING(DTANAL, 1, 6) > LOTMOF ) "
cSql += " 	OR (LOTMOF = ' ' AND SUBSTRING(LOTMOP, 1, 6) = '" + __aRet[ 2 ] + __aRet[ 3 ] + "' AND SUBSTRING(DTANAL, 1, 6) > LOTMOP ) "
cSql += " 	AND CODRDA <> ' ' ) TMP "
cSql += " INNER JOIN " + RetSqlName("B4M") + " B4M "
cSql += " ON B4M_FILIAL = B4N_FILIAL "
cSql += " AND B4M_SUSEP = B4N_SUSEP "
cSql += " AND B4M_CMPLOT = B4N_CMPLOT "
cSql += " AND B4M_NUMLOT = B4N_NUMLOT  "
cSql += " AND B4M_NMAREN <> ' ' "
cSql += " AND B4M.D_E_L_E_T_ = ' ' "
cSql += " WHERE DTANAL > B4M_DTPREN "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTDIGI, DTPAGT) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Alterações" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270RmbBx
Query base para envio do pagamento das guias de reembolso.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270RmbBx(aLote)
local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += "SELECT TMP1.CODOPE, TMP1.CODLDP, TMP1.CODPEG, TMP1.CODRDA, TMP1.NUMERO, '7' TIPO, '04' TIPGUI, TMP1.DTPAGT FROM " + oTmpBase:getrealName() + " BASE "
cSql += " 	INNER JOIN ("
cSql += " 		SELECT B44_OPEMOV CODOPE, B44_CODLDP CODLDP, B44_CODPEG CODPEG, B44_CODRDA CODRDA, B44_NUMGUI NUMERO, E2_BAIXA DTPAGT FROM ( "
cSql += " 		  SELECT E2_BAIXA, E2_PLOPELT, E2_PLLOTE FROM " + RetSqlName("SE2") + " SE2 " 
cSql += " 		  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
cSql += " 		        AND E2_PREFIXO = '" + strtran(GetNewPar("MV_PLSPFRE",'RLE'),'"',"") + "' "
cSql += " 		        AND D_E_L_E_T_ = ' ' ) TMP  "
cSql += " 		INNER JOIN " + RetSqlName("B44") + " B44 " 
cSql += " 		ON B44_FILIAL = '" + xFilial("B44") + "' "
cSql += " 		AND B44_OPEMOV = '" + __aRet[ 1 ] + "' "
cSql += " 		AND B44_ANOAUT = E2_PLOPELT  "
cSql += " 		AND B44_MESAUT = SUBSTRING(E2_PLLOTE, 1, 2)  "
cSql += " 		AND B44_NUMAUT = SUBSTRING(E2_PLLOTE, 3, 8)  "
cSql += " 		AND B44.D_E_L_E_T_ = ' '  "
cSql += " 		WHERE E2_BAIXA BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31' ) TMP1 "
cSql += " ON  BASE.CODOPE = TMP1.CODOPE  "
cSql += " AND BASE.CODLDP = TMP1.CODLDP  "
cSql += " AND BASE.CODPEG = TMP1.CODPEG  "
cSql += " AND BASE.NUMERO = TMP1.NUMERO  "
cSql += " AND BASE.CODRDA <> '" + cRdaProp + "' "
cSql += " AND BASE.LOTMOF = ' ' "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTPAGT) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("Baixa Reembolso" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSZTCExc
Query base para envio guias de exclusão vindas da rotina de conferencia.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSZTCExc(aLote)
local cSql 		:= ""

cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
cSql += " BCI_TIPGUI TIPGUI, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI FROM(  " 
cSql += " 	SELECT B4V_FILIAL, B4V_SUSEP, B4V_CMPLOT, B4V_NMGOPE, B4V_CODRDA FROM" + RetSqlName("B4V") + " B4V "
cSql += " 	WHERE B4V_OK = '" + oBrwPrinc:cMark + "') TMP"
cSql += " INNER JOIN " + RetSqlName("B4N") + " B4N "
cSql += " ON B4V_FILIAL = B4N_FILIAL "
cSql += " AND B4V_SUSEP = B4N_SUSEP "
cSql += " AND B4V_CMPLOT = B4N_CMPLOT "
cSql += " AND B4V_NMGOPE = B4N_NMGOPE  "
csql += " inner Join "
cSql += RetsqlName("BCI") + " BCI "
csql += " On "
csql += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
cSql += " BCI_CODOPE = B4N_CODOPE AND "
cSql += " BCI_CODLDP = B4N_CODLDP AND "
csql += " BCI_CODPEG = B4N_CODPEG AND "
csql += " BCI.D_E_L_E_T_ = ' ' "
cSql += " WHERE B4N_LOTREP = ' ' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTPAGT, DTDIGI) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("ZTC - Exclusão" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSZTCAlt
Query base para envio guias de alteração vindas da rotina de conferencia.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLSZTCAlt(aLote)
local cSql 		:= ""

cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '6' TIPO, "
cSql += " BCI_TIPGUI TIPGUI, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI FROM(  " 
cSql += " 	SELECT B4V_FILIAL, B4V_SUSEP, B4V_CMPLOT, B4V_NMGOPE, B4V_CODRDA FROM" + RetSqlName("B4V") + " B4V "
cSql += " 	WHERE B4V_OK = '" + oBrwPrinc:cMark + "') TMP"
cSql += " INNER JOIN " + RetSqlName("B4N") + " B4N "
cSql += " ON B4V_FILIAL = B4N_FILIAL "
cSql += " AND B4V_SUSEP = B4N_SUSEP "
cSql += " AND B4V_CMPLOT = B4N_CMPLOT "
cSql += " AND B4V_NMGOPE = B4N_NMGOPE  "
csql += " inner Join "
cSql += RetsqlName("BCI") + " BCI "
csql += " On "
csql += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
cSql += " BCI_CODOPE = B4N_CODOPE AND "
cSql += " BCI_CODLDP = B4N_CODLDP AND "
csql += " BCI_CODPEG = B4N_CODPEG AND "
csql += " BCI.D_E_L_E_T_ = ' ' "
cSql += " WHERE B4N_LOTREP = ' ' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTPAGT, DTDIGI) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("ZTC - Alteração" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1]  )
PLSCOMMIT(cSql)

hubGuias()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270Det
Monta janela PLSM270Det - Detalhes do arquivo

@author    Jonatas Almeida
@version   1.xx
@since     11/08/2016
/*/
//------------------------------------------------------------------------------------------
function PLSM270Det
	local oLayerGuia, oReGuiaB4O, oReGuiaB4P	// variaveis para os relacionamentos da guia
	local oPnlUpGuia, oPnlLDGuia, oPnlRDGuia				// variaveis para os paineis da guia
	local oBrwUpGuia, oBrwLDGuia, oBrwRDGuia				// variaveis para os browsers da guia
	
	local oLayerQual, oReQualB4O, oReQualB4P	// variaveis para os relacionamentos da qualidade
	local oPnlUpQual, oPnlLDQual, oPnlRDQual				// variaveis para os paineis da qualidade
	local oBrwUpQual, oBrwLDQual, oBrwRDQual				// variaveis para os browsers da qualidade
	
	local oPnlUpCon, oLayerCon, oBrwUpCon
	local oReCriB8R, oPnlDCrit
	
	local aCoors	:= FWGetDialogSize( oMainWnd )
	local aSize		:= {}
	local aObjects	:= {}
	local aInfo		:= {}
	local aPosObj	:= {}
	
	local cAliasB4N	:= getNextAlias()
	local cAliasB4O	:= getNextAlias()
	local cAliasB4P	:= getNextAlias()
	local cAliasB8Q	:= getNextAlias()
	local cAliasB8R	:= getNextAlias()
	
	local lOpenB4N	:= .F.
	local lOpenB4O	:= .F.
	local lOpenB4P	:= .F.
	local lOpenB8Q  := .F.
	local lOpenB8R	:= .F.

	local aColB4N	:= {}
	local aColB4O	:= {}
	local aColB4P	:= {}
	local aColB8Q	:= {}
	local aColB8R	:= {}
	Local aB4MPos	:= {}
	
	private oDlgSec
	
	aB4MPos := {B4M->B4M_FILIAL, B4M->B4M_SUSEP, B4M->B4M_CMPLOT, B4M->B4M_NUMLOT}
	
	DEFINE MSDIALOG oDlgSec TITLE ".:: Monitoramento TISS - Arquivos ::." FROM aCoors[ 1 ], aCoors[ 2 ] TO aCoors[ 3 ], aCoors[ 4 ] PIXEL
	
	//--< Define tamanho das abas superiores >---
	aSize := msAdvSize()
	
	aadd( aObjects,{ 100,100,.T.,.T. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := msObjSize( aInfo,aObjects,.T. )

If B4M->(FieldPos("B4M_TIPENV")) > 0 .And. B4M->B4M_TIPENV == "4"
	//--< Cria as abas superiores >---
	aTFolder := { 'Contratos Preestabelecidos' }
	oTFolder := TFolder():New( 0,0,aTFolder,,oPnlUpCon,,,,.T.,,aPosObj[ 1 ][ 4 ],aPosObj[ 1 ][ 3 ] )

	//--< *** GUIAS *** >-------------------------------------------------------------------------------------------------
	//--< Divisao dos Flayers para as Guias >---
	oLayerCon := FWLayer():New()
	oLayerCon:Init( oTFolder:aDialogs[ 1 ],.F.,.T. )

	oLayerCon:AddLine( 'UP',60,.F. )
	oLayerCon:AddCollumn( 'ALLUP',100,.T.,'UP' )
	oPnlUpCon := oLayerCon:GetColPanel( 'ALLUP','UP' )
	
	oLayerCon:AddLine( 'DOWN',40,.F. )
	oLayerCon:AddCollumn( 'ALLDOWN',100,.T.,'DOWN' )
	oPnlDCrit := oLayerCon:getColPanel( 'ALLDOWN','DOWN' )
	
	//--< Painel Superior - Contratos >---
	oBrwUpCon := FWMBrowse():New()
	oBrwUpCon:SetOwner( oPnlUpCon )
	oBrwUpCon:SetDescription( "Contratos" )
	oBrwUpCon:SetAlias( "B8Q" )
	oBrwUpCon:SetMenuDef( '' )
	oBrwUpCon:SetfilterDefault("@ '" + xfilial("B8Q") + "' = B8Q_FILIAL AND '" + aB4MPos[2] + "' = B8Q_SUSEP AND '" + aB4MPos[3] + "' = B8Q_CMPLOT AND '" + aB4MPos[4] + "' = B8Q_NUMLOT ")
	oBrwUpCon:DisableDetails()
	oBrwUpCon:SetProfileID( '1' )
	oBrwUpCon:SetWalkthru( .F. )
	oBrwUpCon:SetAmbiente( .F. )
	oBrwUpCon:Activate()
	
	//--< Painel Inferior - Criticas >---
	oBrwDCrit := FWMBrowse():New()
	oBrwDCrit:SetOwner( oPnlDCrit )
	oBrwDCrit:SetDescription( "Criticas" )
	oBrwDCrit:SetAlias( "B8R" )
	oBrwDCrit:SetMenuDef( '' )
	oBrwDCrit:DisableDetails()
	oBrwDCrit:SetProfileID( '2' )
	oBrwDCrit:SetWalkthru( .F. )
	oBrwDCrit:SetAmbiente( .F. )
	oBrwDCrit:Activate()
	
	//--< Relacionamento: Contratos X Criticas >---
	oReCriB8R := FWBrwRelation():New()
	oReCriB8R:AddRelation( oBrwUpCon,oBrwDCrit, {;
		{ "B8R_FILIAL","B8Q_FILIAL"	},;
		{ "B8R_SUSEP","B8Q_SUSEP"	},;
		{ "B8R_CMPLOT","B8Q_CMPLOT"	},;
		{ "B8R_NUMLOT","B8Q_NUMLOT"	},;
		{ "B8R_IDEPRE","B8Q_IDEPRE"	},;
		{ "B8R_CPFCNP","B8Q_CPFCNP"	},;
		{ "B8R_IDCOPR","B8Q_IDCOPR"	} } )
	oReCriB8R:Activate()
	
	if( select( cAliasB8Q ) <= 0 )
		lOpenB8Q := chkFile( "B8Q",.F.,cAliasB8Q )
	endIf
	
	if( select( cAliasB8R ) <= 0 )
		lOpenB8R := chkFile( "B8R",.F.,cAliasB8R )
	endIf	

	aCpoB8Q	:= {}
	aColB8Q := getCPOs( @aCpoB8Q,"B8Q" )

	aCpoB8R	:= {}
	aColB8R := getCPOs( @aCpoB8R,"B8R" )

Else
	//--< Cria as abas superiores >---
	aTFolder := { 'Guias','Qualidade' }
	oTFolder := TFolder():New( 0,0,aTFolder,,oPnlUpGuia,,,,.T.,,aPosObj[ 1 ][ 4 ],aPosObj[ 1 ][ 3 ] )

	//--< *** GUIAS *** >--
	//--< Divisao dos Flayers para as Guias >---
	oLayerGuia := FWLayer():New()
	oLayerGuia:Init( oTFolder:aDialogs[ 1 ],.F.,.T. )

	oLayerGuia:AddLine( 'UP',50,.F. )
	oLayerGuia:AddCollumn( 'ALLUP',100,.T.,'UP' )
	oPnlUpGuia := oLayerGuia:GetColPanel( 'ALLUP','UP' )
	
	oLayerGuia:AddLine( 'DOWN',50,.F. )
	oLayerGuia:AddCollumn( 'LEFTDOWN',50,.T.,'DOWN' )
	oLayerGuia:AddCollumn( 'RIGHTDOWN',50,.T.,'DOWN' )
	
	oPnlLDGuia	:= oLayerGuia:getColPanel( 'LEFTDOWN','DOWN' )
	oPnlRDGuia	:= oLayerGuia:getColPanel( 'RIGHTDOWN','DOWN' )
	
	//--< Painel Superior - Guias >---
	oBrwUpGuia := FWMBrowse():New()
	oBrwUpGuia:SetOwner( oPnlUpGuia )
	oBrwUpGuia:SetDescription( "Guias" )
	oBrwUpGuia:SetAlias( "B4N" )
	oBrwUpGuia:SetMenuDef( 'PLSM270B4N' )
	oBrwUpGuia:DisableDetails()
	oBrwUpGuia:SetProfileID( '1' )
	oBrwUpGuia:SetWalkthru( .F. )
	oBrwUpGuia:SetAmbiente( .F. )
	oBrwUpGuia:SetfilterDefault("@ '" + xfilial("B4N") + "' = B4N_FILIAL AND '" + aB4MPos[2] + "' = B4N_SUSEP AND '" + aB4MPos[3] + "' = B4N_CMPLOT AND '" + aB4MPos[4] + "' = B4N_NUMLOT ") 
	oBrwUpGuia:AddLegend( "B4N_STATUS == '1'","GREEN","Não criticado" )
	oBrwUpGuia:AddLegend( "B4N_STATUS == '2' .AND. ( B4N_ORIERR == ' ' .OR. B4N_ORIERR == '1' )", "RED",	"Criticado pelo sistema" )
	oBrwUpGuia:AddLegend( "B4N_STATUS == '2' .AND. B4N_ORIERR == '2'", "ORANGE",	"Criticado pelo retorno" )
	oBrwUpGuia:AddLegend( "B4N_STATUS == '2' .AND. B4N_ORIERR == '3'", "YELLOW",	"Criticado pela Qualidade " )
	oBrwUpGuia:Activate()

	//--< Painel Inferior Esquerdo >---
	oBrwLDGuia := FWMBrowse():New()
	oBrwLDGuia:SetOwner( oPnlLDGuia )
	oBrwLDGuia:SetDescription( "Procedimentos" )
	oBrwLDGuia:SetMenuDef( "PLSM270B4O" )
	oBrwLDGuia:SetAlias( "B4O" )
	oBrwLDGuia:SetProfileID( "2" )
	oBrwLDGuia:DisableDetails()
	oBrwLDGuia:SetWalkthru( .F. )
	oBrwLDGuia:SetAmbiente( .F. )

	oBrwLDGuia:AddLegend( "B4O_STATUS == '1'", "GREEN",	"Não criticado" )
	oBrwLDGuia:AddLegend( "B4O_STATUS == '2' .AND. ( B4O_ORIERR == ' ' .OR. B4O_ORIERR == '1' )", "RED",	"Criticado pelo sistema" )
	oBrwLDGuia:AddLegend( "B4O_STATUS == '2' .AND. B4O_ORIERR == '2'", "ORANGE",	"Criticado pelo retorno" )
	oBrwLDGuia:AddLegend( "B4O_STATUS == '2' .AND. B4O_ORIERR == '3'", "YELLOW",	"Criticado pela Qualidade " )
	oBrwLDGuia:Activate()
	
	//--< Painel Inferior Direito >---
	oBrwRDGuia := FWMBrowse():New()
	oBrwRDGuia:SetOwner( oPnlRDGuia )
	oBrwRDGuia:SetDescription( "Críticas" )
	oBrwRDGuia:SetMenuDef( '' )
	oBrwRDGuia:DisableDetails()
	oBrwRDGuia:SetAlias( "B4P" )
	oBrwRDGuia:SetProfileID( '3' )
	oBrwRDGuia:SetWalkthru( .F. )
	oBrwRDGuia:SetAmbiente( .F. )
	oBrwRDGuia:ForceQuitButton()
	oBrwRDGuia:Activate()
	
	//--< Relacionamento: Guias X Itens >---
	oReGuiaB4O := FWBrwRelation():New()
	oReGuiaB4O:AddRelation( oBrwUpGuia,oBrwLDGuia, {;
		{ "B4O_FILIAL","B4N_FILIAL" },;
		{ "B4O_SUSEP" ,"B4N_SUSEP"	},;
		{ "B4O_CMPLOT","B4N_CMPLOT"	},;
		{ "B4O_NUMLOT","B4N_NUMLOT"	},;
		{ "B4O_NMGOPE","B4N_NMGOPE"	},;
		{ "B4O_CODRDA","B4N_CODRDA"	} } )
	oReGuiaB4O:Activate()
		
	//--< Relacionamento: Guias X Criticas >---
	oReGuiaB4P := FWBrwRelation():New()
	oReGuiaB4P:AddRelation( oBrwUpGuia,oBrwRDGuia, {;
		{ "B4P_FILIAL","B4N_FILIAL"	},;
		{ "B4P_SUSEP" ,"B4N_SUSEP"	},;
		{ "B4P_CMPLOT","B4N_CMPLOT"	},;	
		{ "B4P_NUMLOT","B4N_NUMLOT"	},;			
		{ "B4P_NMGOPE","B4N_NMGOPE"	} } ) 
	oReGuiaB4P:Activate()

	//--< *** QUALIDADE *** >--
	//--< Divisao dos Flayers para Qualidade >---
	oLayerQual := FWLayer():New()
	oLayerQual:Init( oTFolder:aDialogs[ 2 ],.F.,.T. )

	oLayerQual:AddLine( 'UP',50,.F. )
	oLayerQual:AddCollumn( 'ALLUP',100,.T.,'UP' )
	oPnlUpQual := oLayerQual:GetColPanel( 'ALLUP','UP' )
	
	oLayerQual:AddLine( 'DOWN',50,.F. )
	oLayerQual:AddCollumn( 'LEFTDOWN',50,.T.,'DOWN' )
	oLayerQual:AddCollumn( 'RIGHTDOWN',50,.T.,'DOWN' )
	
	oPnlLDQual	:= oLayerQual:getColPanel( 'LEFTDOWN','DOWN' )
	oPnlRDQual	:= oLayerQual:getColPanel( 'RIGHTDOWN','DOWN' )
	
	if( select( cAliasB4N ) <= 0 )
		lOpenB4N := chkFile( "B4N",.F.,cAliasB4N )
	endIf

	if( select( cAliasB4O ) <= 0 )
		lOpenB4O := chkFile( "B4O",.F.,cAliasB4O )
	endIf
	
	if( select( cAliasB4P ) <= 0 )
		lOpenB4P := chkFile( "B4P",.F.,cAliasB4P )
	endIf	

	aCpoB4N	:= {}
	aColB4N := getCPOs( @aCpoB4N,"B4N" )
	
	aCpoB4O	:= {}
	aColB4O := getCPOs( @aCpoB4O,"B4O" )
	
	aCpoB4P	:= {}
	aColB4P := getCPOs( @aCpoB4P,"B4P" )
	
	//--< Painel Superior - Qualidade >---
	oBrwUpQual := FWMBrowse():New()
	oBrwUpQual:SetOwner( oPnlUpQual )
	oBrwUpQual:SetDescription( "Qualidade" )
	oBrwUpQual:SetAlias( cAliasB4N )
	oBrwUpQual:SetMenuDef( '' )
	oBrwUpQual:DisableDetails()
	oBrwUpQual:SetFilterDefault( "@ '" + xfilial("B4N") + "' = B4N_FILIAL AND '" + aB4MPos[2] + "' = B4N_SUSEP AND '" + aB4MPos[3] + "' = B4N_CMPLOT AND '" + aB4MPos[4] + "' = B4N_NUMLOT AND B4N_ORIERR = '3'" )
	oBrwUpQual:SetProfileID( '4' )
	oBrwUpQual:AddLegend( "B4N_STATUS == '1'", "GREEN",	"Não criticado" )
	oBrwUpQual:AddLegend( "B4N_STATUS == '2' .AND. ( B4N_ORIERR == ' ' .OR. B4N_ORIERR == '1' )", "RED",	"Criticado pelo sistema" )
	oBrwUpQual:AddLegend( "B4N_STATUS == '2' .AND. B4N_ORIERR == '2'", "ORANGE",	"Criticado pelo retorno" )
	oBrwUpQual:AddLegend( "B4N_STATUS == '2' .AND. B4N_ORIERR == '3'", "YELLOW",	"Criticado pela Qualidade " )
	oBrwUpQual:SetColumns( aColB4N )
	oBrwUpQual:Activate()

	//--< Painel Inferior Esquerdo >---
	oBrwLDQual := FWMBrowse():New()
	oBrwLDQual:SetOwner( oPnlLDQual )
	oBrwLDQual:SetDescription( "Procedimentos" )
	oBrwLDQual:SetAlias( cAliasB4O )
	oBrwLDQual:SetMenuDef( "PLSM270B4O" )
	oBrwLDQual:DisableDetails()
	oBrwLDQual:SetProfileID( '5' )
	oBrwLDQual:AddLegend( "B4O_STATUS == '1'", "GREEN",	"Não criticado" )
	oBrwLDQual:AddLegend( "B4O_STATUS == '2' .AND. ( B4O_ORIERR == ' ' .OR. B4O_ORIERR == '1' )", "RED",	"Criticado pelo sistema" )
	oBrwLDQual:AddLegend( "B4O_STATUS == '2' .AND. B4O_ORIERR == '2'", "ORANGE",	"Criticado pelo retorno" )
	oBrwLDQual:AddLegend( "B4O_STATUS == '2' .AND. B4O_ORIERR == '3'", "YELLOW",	"Criticado pela Qualidade " )
	oBrwLDQual:SetColumns( aColB4O )
	oBrwLDQual:Activate()

	//--< Painel Inferior Direito >---
	oBrwRDQual := FWMBrowse():New()
	oBrwRDQual:SetOwner( oPnlRDQual )
	oBrwRDQual:SetDescription( "Críticas" )
	oBrwRDQual:SetAlias( cAliasB4P )
	oBrwRDQual:SetColumns( aColB4P )
	oBrwRDQual:SetMenuDef( '' )
	oBrwRDQual:DisableDetails()
	oBrwRDQual:SetFilterDefault( "('"+ cAliasB4P +"')->( B4P_ORIERR ) == '3'" )
	oBrwRDQual:SetProfileID( '6' )
	oBrwRDQual:SetWalkthru( .F. )
	oBrwRDQual:SetAmbiente( .F. )
	oBrwRDQual:Activate()
	
	//--< Relacionamento: Qualidade X Itens >---
	oReQualB4O := FWBrwRelation():New()
	oReQualB4O:AddRelation( oBrwUpQual,oBrwLDQual, {;
		{ "B4O_FILIAL","B4N_FILIAL" },;
		{ "B4O_SUSEP" ,"B4N_SUSEP"	},;
		{ "B4O_CMPLOT","B4N_CMPLOT"	},;
		{ "B4O_NUMLOT","B4N_NUMLOT"	},;
		{ "B4O_NMGOPE","B4N_NMGOPE"	},;
		{ "B4O_CODRDA","B4N_CODRDA"	} } )
	oReQualB4O:Activate()
	
	//--< Relacionamento: Qualidade X Criticas >---
	oReQualB4P := FWBrwRelation():New()
	oReQualB4P:AddRelation( oBrwUpQual,oBrwRDQual, {;
		{ "B4P_FILIAL","B4N_FILIAL"	},;
		{ "B4P_SUSEP" ,"B4N_SUSEP"	},;
		{ "B4P_NUMLOT","B4N_NUMLOT"	},;
		{ "B4P_CMPLOT","B4N_CMPLOT"	},;		
		{ "B4P_NMGOPE","B4N_NMGOPE"	} } )
	oReQualB4P:Activate()
EndIf	
	
	
activate MsDialog oDlgSec Center
	
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procEnvio
Processa arquivo de envio - TISS

@author    Jonatas Almeida
@version   1.xx
@since     15/08/2016
/*/
//------------------------------------------------------------------------------------------
static function procEnvio()

local cTitulo	:= "Processa arquivo de envio - TISS"
local cTexto	:= CRLF + CRLF + "Esta é a opção que irá efetuar a leitura das tabelas de contas médicas do PLS," + CRLF +;
	"processar as informações encontradas para a gravação das tabelas de" + CRLF +;
	"monitoramento com as informações a serem enviadas."
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
local nTipoEnvio := 1

Private oProcess

if B4M->(FieldPos("B4M_VERSAO")) <= 0 	
	Aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): B4M_VERSAO ",{ "Ok" }, 2 )
	return	
endIf

if( nOpc == 1 )
	if( pergEnvio(@nTipoEnvio) )
		//--< Cria registro no Monitoramento TISS - B4M >---
		If nTipoEnvio == 1//Guias monitoramento
			oProcess := msNewProcess():New( { | lEnd | PLSM270JOB( @lEnd ) } , "Processando" , "Aguarde..." , .F. )
			oProcess:Activate()
		ElseIf B4M->(FieldPos("B4M_TIPENV")) > 0 .And. nTipoEnvio == 4//Valor preestabelecido
			PROVLRPREE()
		Else
			MsgInfo("Ambiente desatualizado para a opção Valor Preestabelecido." + CRLF + "Execute o compatibilizador updplshu.")
		EndIf
	endIf
endIf

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pergEnvio
Perguntas para composicao do arquivo de envio

@author    Jonatas Almeida
@version   1.xx
@since     15/08/2016
/*/
//------------------------------------------------------------------------------------------
static function pergEnvio(nTipoEnvio)
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
	local cANS			:= "1"
	local cLocNew		:= ""
	local cSituac		:= "2"
	local nEstorno		:= 2
	local nExclusao		:= 2
	local nX			:= 1
	Private cLocDig		:= space( 250 ) // Necessário ser private pois eh utilizado no CONPAD1
	Default nTipoEnvio	:= 1//1-Guias monitoramento; 4-Valor preestabelecio; 3-Fornecimento Direto
	
	//====================================================================================
	//SEMPRE QUE ALTERAR ALGO AQUI, ALTERAR TAMBEM NA ROTINA pergCriANS() e PLSM270REP() 
	//====================================================================================
	aadd(/*01*/ aPergs,{ 1,"Operadora",cOperadora,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } )
	aadd(/*02*/ aPergs,{ 1,"Ano Competência",cAno,"@R 9999",'.T.',,/*'.T.'*/,40,.T. } )
	aadd(/*03*/ aPergs,{ 1,"Mês Competência",cMes,"@R 99",'.T.',,/*'.T.'*/,40,.T. } )
	aadd(/*04*/ aPergs,{ 1,"RDA De",cRDADe,"@!",'.T.','BAUPLS',/*'.T.'*/,40,.F. } )
	aadd(/*05*/ aPergs,{ 1,"RDA Até",cRDAAte,"@!",'.T.','BAUPLS',/*'.T.'*/,40,.T. } )
	aadd(/*06*/ aPergs,{ 1,"Local Digit",cLocDig,"@!",'.T.','BCGMON',/*'.T.'*/,100,.T. } )
	aadd(/*07*/ aPergs,{ 1,"Protocolo De",cProtDe,"@!",'.T.','BC1PLS',/*'.T.'*/,40,.F. } )
	aadd(/*08*/ aPergs,{ 1,"Protocolo Até",cProtAte,"@!",'.T.','BC1PLS',/*'.T.'*/,40,.T. } )
	aadd(/*09*/ aPergs,{ 2,"Considera Guias Estornadas",nEstorno,{ "1=Sim","2=Nao" },50,/*'.T.'*/,.T. } )
	aadd(/*10*/ aPergs,{ 2,"Gerar como Exclusão",nExclusao,{ "1=Sim","2=Nao" },50,/*'.T.'*/,.T. } )
	aadd(/*11*/ aPergs,{ 2,"Somente Us.Inf.ANS",cANS,{ "1=Sim","2=Nao" },50,/*'.T.'*/,.T. } )
	aadd(/*12*/ aPergs,{ 2,"Ignora Guias ja processadas",space(1),{ "1=Sim","2=Não" },50,/*'.T.'*/,.T. } )
	aadd(/*13*/ aPergs,{ 2,"Cons Data de Proces",space(1),{ "1=Reconh/Emiss","2=Anali/Baixa" },50,/*'.T.'*/,.T. } )
	aadd(/*14*/ aPergs,{ 2,"Tipo de processamento",nTipoEnvio,{ "1=Guias Monit."/*,"4=Vlr. Preestabelecido"*/ },60,/*'.T.'*/,.T. } )
	aadd(/*15*/ aPergs,{ 2,"Cons. Guia Bloq.",cSituac,{ "1=Sim","2=Nao" },50,/*'.T.'*/,.T. } )
	
	if( paramBox( aPergs,"Parâmetros - Processa arquivo de envio ANS",__aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
		if( validPergEnvio( __aRet ) )
			nTipoEnvio := Iif(valtype(__aRet[14])=="N",__aRet[14],Val(__aRet[14]))
			lRet := .T.
		else
			lRet := pergEnvio()
		endIf
	
		If !Empty(__aRet[6])
			aLocDig := strtokarr(AllTrim(__aRet[6]),",")
			For nX = 1 To Len(aLocDig)
				cLocNew += "'" + aLocDig[nX] + "'"
				If nX <> Len(aLocDig)
					cLocNew += ","
				EndIf
			Next		
			__aRet[6] := "( " + cLocNew + " )"
		EndIf
	endIf
	
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validPergEnvio
Validador de perguntas antes de processar o arquivo de envio

@author    Jonatas Almeida
@version   1.xx
@since     15/08/2016
/*/
//------------------------------------------------------------------------------------------
Static function validPergEnvio( __aRet )
	local nx
	local lRet		:= .T.
	local cMsgErro	:= "Corrija os itens abaixo antes de prosseguir:" + CRLF + CRLF
	local aArea
	Local cLDPSUS := GetNewPar("MV_CDLCSUS","5000")
	
	for nx:=1 to len( __aRet )
		if( nx == 1 )
			aArea := getArea()
			
			BA0->( dbSetOrder( 1 ) )
			if!( BA0->( dbSeek( xFilial( "BA0" ) + allTrim( __aRet[ 1 ] ) ) ) )
				lRet		:= .F.
				cMsgErro += " - Parâmetro 'Operadora' não cadastrado;" + CRLF
			endIf
			
			restArea( aArea )
		elseif( nx == 2 .and. !empty( __aRet[ 2 ] ) .and. len( allTrim( __aRet[ 2 ] ) ) < 4 )
			lRet		:= .F.
			cMsgErro += " - Parâmetro 'Ano Competência' preenchido incorretamente;" + CRLF
		elseif( nx == 3 .and. !empty( __aRet[ 3 ] ) .and. !allTrim( strZero( val( __aRet[ 3 ] ),2 ) ) $ "01|02|03|04|05|06|07|08|09|10|11|12" )
			lRet		:= .F.
			cMsgErro += " - Parâmetro 'Mês Competência' preenchido incorretamente;" + CRLF
		elseIf nX == 6 .and. (!empty(cLDPSUS) .and. cLDPSUS $ __aRet[ 6 ])
			lRet		:= .F.
			cMsgErro += " - Parâmetro 'Local digitação' contém o local de digitação de guias de ressarcimento ao SUS, porém estas guias não devem ser enviadas no monitoramento." + CRLF
			cMsgErro += "   Para prosseguir retire o local [" + cLDPSUS + "] do conteúdo do parâmetro. Caso este local não seja para ressarcimento ao SUS, verifique o conteúdo " + CRLF
			cMsgErro += "   do parâmetro do sistema MV_CDLCSUS; " + CRLF
		elseif( nx == 13 .And. Empty( __aRet[ 13 ]) )
			lRet		:= .F.
			cMsgErro += " - Parâmetro 'Cons Data de Proces' não foi preenchido;"
		endIf
	next nx
	
	if( !lRet )
		alert( cMsgErro )
	endIf
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} processaDados
Processa os dados da query.

@author    Jonatas Almeida
@version   1.xx
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
Static Function processaDados( cAliBase, lEnd, nTpProcess, aLote, cAliPri)	
local aUsuario	:= { .F.,{ },"" }
local aRDA		:= { .F.,{ } }
local lAtuProc := .F.
local lRet		:= .F.
local lRetGui	:= .F.
local lContinua	:= .T.
local cSequen	:= ""
local cGuia		:= ""
local cSusep	:= ""
local lPLSTMON1 := existBlock( "PLSTMON1" )
local cGuiaProc := ""
local aCampos   := {}
local nRecAux   := 0
local nTpDtProc := 1
local nRet		:= 0
local nTipoEnvio := 1
local lReenvio	:= nTpProcess == REENVIAR
local cAlias	:= GetNextAlias()
Local lAtuTiss4 := BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_TMREGA")) > 0//B4N->(fieldPos("B4N_REGATE")) > 0 .AND. B4N->(fieldPos("B4N_SAUOCU")) > 0 .AND. B4N->(fieldPos("B4N_CPFUSR")) > 0

private cHoraIni := time()

DEFAULT lEnd	:= .F.
DEFAULT nTpProcess := PROCESSAR
DEFAULT aLote  := {} 

BD5->(dbsetorder(1))
BE4->(dbsetorder(1))

If Len(__aRet) >= 13
	nTpDtProc := Iif(ValType(__aRet[13])=="N",__aRet[13],Val(__aRet[13]))
	nTipoEnvio := Iif(ValType(__aRet[14])=="N",__aRet[14],Val(__aRet[14]))
EndIf

BA0->( dbSetOrder(1)) // BA0_FILIAL, BA0_CODIDE, BA0_CODINT
// Número do SUSEP
If BA0->(dbSeek(xFilial("BA0")+allTrim( __aRet[ 1 ])))
	cSusep := BA0->BA0_SUSEP 
EndIf

while( ( cAliBase )->( !eof() ) ) .and. !KillApp()	    	                             
	if( lEnd )
		alert( 'Execução cancelada pelo usuário.' )
		exit
	endIf
	
	if ( cAliBase )->TIPGUI $ ("01,02,04,06,13")
		cSql := " SELECT BD6_CODRDA, BD5_TIPPRE, BD5_CODLOC, BD5_LOCAL, BD5_CODESP, BD6_CODESP, BD6_SEQIMP, BD5_LOTMOP, BD5_DTDIGI, "
		cSql += " BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_TIPGUI, BD5_TPGRV, BD5_TIPADM, BD5_TIPPRE, "
		cSql += " BD6_TPGRV, BD5_INDACI, BD5_TIPATE, BD5_DTPAGT, BD6_VLRAPR, BD6_VLRMAN, BD5_TIPCON, BD5_GUESTO, BD5_ESTORI, BD5_LOTMOE, "
		cSql += " BD5_DATSOL, BD5.R_E_C_N_O_ REG, BD6_OPEORI, BD6_VLRPAG, BD6_VLRGLO, BD6_BLOCPA, BD5_TIPFAT, BD5_LOTMOF, BD6_CODTAB, "
		cSql += " BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BD6_VLRTPF, BD6_DATPRO, BD6_VLRGLO, BD6_CODPAD, BD6_FADENT, "
		cSql += " BD6_VLRPAG, BD6_CODRDA, BD6_NFE, BD6_LIBERA, BD6_FASE, BD6_SITUAC, BD6_BLOPAG,BD5_DATPRO, BD6_VLRAPR, BD6_DATPRO, BD6_QTDPRO, "
		cSql += " BD6_OPELOT, BD6_NUMLOT, BD6_CODRDA , BD5_GUIINT, BD5_GUIPRI, BD6_VLRPF, BD6_VLRTPF, BD6_CODPRO, BD6_DENREG, BD5_NUMIMP, BD5_GUIORI, BD5_ATERNA, BD6_TABDES "
		cSql += iif(BD5->(fieldpos("BD5_TISVER")) > 0, ",BD5_TISVER TISVER ", " ,' ' TISVER")	
		if lAtuTiss4
			csql += " ,BD5_TMREGA, BD5_SAUOCU "
		endif
		cSql += " FROM " + RetSqlName("BD5") + " BD5 "  
		cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "  
		cSql += " ON BD6_FILIAL =  BD5_FILIAL " 
		cSql += " AND BD6_CODOPE = BD5_CODOPE " 
		cSql += " AND BD6_CODLDP = BD5_CODLDP " 
		cSql += " AND BD6_CODPEG = BD5_CODPEG " 
		cSql += " AND BD6_NUMERO = BD5_NUMERO " 
		cSql += " AND BD6_ORIMOV = BD5_ORIMOV " 
		cSql += " WHERE BD5.BD5_FILIAL = '" + xFilial("BD5") + "' "
		cSql += " AND BD5_CODOPE = '" + (cAliBase)->CODOPE + "'"
		cSql += " AND BD5_CODLDP = '" + (cAliBase)->CODLDP + "'"
		cSql += " AND BD5_CODPEG = '" + (cAliBase)->CODPEG + "'"
		cSql += " AND BD5_NUMERO = '" + (cAliBase)->NUMERO + "'"
		cSql += " AND BD5.D_E_L_E_T_ = ' ' "
		cSql += " AND BD6.D_E_L_E_T_ = ' ' "
	elseif ( cAliBase )->TIPGUI == "05"
		cSql := " SELECT BD6_VLRGLO, BD6_OPELOT, BD6_NUMLOT, BD6_CODRDA, BE4A.BE4_CODPEG, BE4A.BE4_CODLDP, BD6_OPEORI, BD6_BLOPAG, BD6_SITUAC, BD6_FASE, BD6_LIBERA, "
		cSql += " BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_TIPGUI, BE4A.BE4_TIPADM, BE4A.BE4_TIPPRE, BE4A.BE4_NUMIMP, BD6_SEQIMP, BD6_TPGRV,  "
		cSql += " BD6_VLRAPR, BD6_VLRMAN, BE4A.BE4_DTDIGI, BE4A.BE4_DTPAGT, BE4A.BE4_DTALTA, BE4A.BE4_CODOPE, BE4A.BE4_ANOINT, BE4A.BE4_MESINT, BE4A.BE4_NUMINT, "
		cSql += " BE4A.BE4_CID, BE4A.BE4_TIPALT, BE4A.BE4_ATERNA, BE4A.BE4_NRDCNV, BE4A.BE4_NRDCOB, BE4A.BE4_TIPFAT, BE4A.BE4_INDACI, BE4A.BE4_PRVINT, BD6_NFE, "
		cSql += " BE4A.BE4_NUMERO, BE4A.BE4_GUIINT, BE4A.BE4_GUESTO, BE4A.BE4_ESTORI, BE4A.BE4_LOTMOE, BE4A.BE4_LOTMOP, BE4A.BE4_LOTMOF, BE4A.R_E_C_N_O_ REG, "	
		cSql += " BE4B.BE4_DTDIGI DTSOLINT, BD6_CODRDA, BE4A.BE4_CODLOC, BE4A.BE4_LOCAL, BE4A.BE4_CODESP, BD6_CODESP, BD6_VLRPAG, BD6_VLRGLO, BD6_BLOCPA, "
		cSql += " BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BE4A.BE4_GRPINT, BE4A.BE4_REGINT, BE4A.BE4_CIDREA, BD6_CODRDA, BD6_VLRPAG, "	
		cSql += " BD6_CODPRO, BD6_QTDPRO, BD6_DATPRO, BD6_VLRAPR, BD6_DENREG, BD6_FADENT, BD6_CODPAD, BD6_CODTAB, BE4A.BE4_DTINIF, BE4A.BE4_DIASPR, "
		cSql += " BE4A.BE4_DATPRO, BD6_SEQUEN, BD6_DATPRO, BD6_VLRPF, BD6_VLRTPF, BD6_VLRTPF, BE4A.BE4_DTFIMF, BE4A.BE4_DIASIN, BD6_TABDES  "	
		cSql += iif(BE4->(fieldpos("BE4_TISVER")) > 0, ", BE4A.BE4_TISVER TISVER ", " ,' ' TISVER")		
		cSql += " FROM " + RetSqlName("BE4") + " BE4A " 
		cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "  
		cSql += " ON BD6_FILIAL =  BE4A.BE4_FILIAL " 
		cSql += " AND BD6_CODOPE = BE4A.BE4_CODOPE " 
		cSql += " AND BD6_CODLDP = BE4A.BE4_CODLDP " 
		cSql += " AND BD6_CODPEG = BE4A.BE4_CODPEG " 
		cSql += " AND BD6_NUMERO = BE4A.BE4_NUMERO " 
		cSql += " AND BD6_ORIMOV = BE4A.BE4_ORIMOV " 
		cSql += " LEFT JOIN " + RetSqlName("BE4") + " BE4B "
		cSql += " ON BE4B.BE4_FILIAL = BE4A.BE4_FILIAL "
		cSql += " AND BE4B.BE4_CODOPE = SUBSTRING(BE4A.BE4_GUIINT,01,4) "
		cSql += " AND BE4B.BE4_CODLDP = SUBSTRING(BE4A.BE4_GUIINT,05,4) "
		cSql += " AND BE4B.BE4_CODPEG = SUBSTRING(BE4A.BE4_GUIINT,09,8) "
		cSql += " AND BE4B.BE4_NUMERO = SUBSTRING(BE4A.BE4_GUIINT,17,8) "
		cSql += " AND BE4B.BE4_TIPGUI = '03' "
		cSql += " AND BE4B.D_E_L_E_T_ = ' '  "
		cSql += " WHERE BE4A.BE4_FILIAL = '" + xFilial("BE4") + "' "
		cSql += " AND BE4A.BE4_CODOPE = '" + (cAliBase)->CODOPE + "'"
		cSql += " AND BE4A.BE4_CODLDP = '" + (cAliBase)->CODLDP + "'"
		cSql += " AND BE4A.BE4_CODPEG = '" + (cAliBase)->CODPEG + "'"
		cSql += " AND BE4A.BE4_NUMERO = '" + (cAliBase)->NUMERO + "'"
		cSql += " AND BE4A.D_E_L_E_T_ = ' ' "
		cSql += " AND BD6.D_E_L_E_T_ = ' ' "
	elseif ( cAliBase )->TIPGUI == "10"
		cSql := CallQryGlo("1", (cAliBase)->CODOPE, (cAliBase)->CODLDP, (cAliBase)->CODPEG, (cAliBase)->NUMERO)
		cSql += " 	UNION	"
		cSql += CallQryGlo("2", (cAliBase)->CODOPE, (cAliBase)->CODLDP, (cAliBase)->CODPEG, (cAliBase)->NUMERO)
		cSql := PLSConSQL(cSql)
	endif

	if THREADSLOCK == 1
		oProcess:IncRegua2( "Processando guia: " + (cAliBase)->CODOPE + (cAliBase)->CODLDP + (cAliBase)->CODPEG + (cAliBase)->NUMERO ) 
	endif

	if select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	while( ( cAlias )->( !eof() ) )		
		if cGuiaProc <> (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO )			
			cGuiaProc := (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO )
			lNovaGuia := .t.
		else
			lNovaGuia := .f.
		endif

		if lNovaGuia
			nRet := TcSqlEXEC("UPDATE " + cAliPri + " SET OK = 'S' WHERE CODPEG = '" + (cAliBase)->CODPEG + "' AND NUMERO = '" + (cAliBase)->NUMERO + "'" )
			if nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
			   	nRet := TcSqlEXEC("COMMIT") 
			endif

			//Obrigatorio envio da guia original no recurso de glosa
			//Caso tenha o LOTMOF em branco, mas o valor de pagamento seja zero, foi uma glosa integral, então é pra seguir o processo
			If !lReenvio .And. ( cAlias )->BD6_TIPGUI == "10" .and. empty(( cAlias )->LOTMOFORI) .AND. ( cAlias )->VLRPAGORI > 0
				PlsPtuLog("Skip -> Obrigatorio envio da guia original para Recurso de Glosa - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "logMonit.log")			
				If GetNewPar("MV_PMONLOG",.F.) 
  					PlsPtuLog("Skip -> Obrigatorio envio da guia original para Recurso de Glosa - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "Monit.log")
  				EndIf
				( cAlias )->( dbSkip() )  
				Loop
			EndIf

			//Obrigatorio protocolo - regra do plsmpag
			If !lReenvio .And. PLSOBRPRDA((cAlias)->BD6_CODRDA) .And. (cAlias)->BD6_CODLDP == PLSRETLDP(9)
				PlsPtuLog("Skip -> Obrigatorio protocolo - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "logMonit.log")			
				If GetNewPar("MV_PMONLOG",.F.) 
  					PlsPtuLog("Skip -> Obrigatorio protocolo - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "Monit.log")
  				EndIf
				( cAlias )->( dbSkip() )  
				Loop
			EndIf

			//--< DADOS DO BENEFICIARIO >---
			if ( !aUsuario[ 1 ] .or. ( cAlias )->( BD6_OPEUSR ) + ( cAlias )->( BD6_CODEMP ) + ( cAlias )->( BD6_MATRIC ) + ( cAlias )->( BD6_TIPREG ) + ( cAlias )->( BD6_DIGITO ) <> aUsuario[ 2 ][ 1 ] + aUsuario[ 2 ][ 2 ] + aUsuario[ 2 ][ 3 ] + aUsuario[ 2 ][ 4 ] + aUsuario[ 2 ][ 5 ] )
				aUsuario := getUsuario( ( cAlias )->( BD6_OPEUSR ), ( cAlias )->( BD6_CODEMP ), ( cAlias )->( BD6_MATRIC ), ( cAlias )->( BD6_TIPREG ), ( cAlias )->( BD6_DIGITO ), STOD(( cAlias )->( BD6_DATPRO )) )
				lRet	:= aUsuario[1]
				if !lRet
					PlsPtuLog("Skip -> Benef não encontrado/Inf Ans = Não - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "logMonit.log")			
					if GetNewPar("MV_PMONLOG",.F.) 
  						PlsPtuLog("Skip -> Benef não encontrado/Inf Ans = Não - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "Monit.log")
  					endif
				endif
			endIf
			
			//--< DADOS DA REDE DE ATENDIMENTO >---
			if lRet .And. (!aRDA[ 1 ] .or. ( cAlias )->( BD6_CODRDA ) <> aRDA[ 2 ][ 1 ] )		
				aRDA 	:= getRDA( ( cAlias )->( BD6_CODRDA ) )
				lRet	:= aRDA[ 1 ]
				if !lRet
					PlsPtuLog("Skip -> RDA não encontrado - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "logMonit.log")			
					if GetNewPar("MV_PMONLOG",.F.) 
  						PlsPtuLog("Skip -> RDA não encontrado - Guia:" + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) , "Monit.log")
  					endif
				endif
			EndIf
			
			// Para guias de Reembolso, deve-se enviar o CPF/CNPJ (e o CBO, caso informado) do Prestador não referenciado.
			If lRet .And. (( cAlias )->( BD6_TIPGUI ) == '04')
				B44->(dbSetOrder(5)) // B44_FILIAL+B44_CODPEG+B44_NUMGUI
				B45->(DbSetOrder(1)) // B45_FILIAL+B45_OPEMOV+B45_ANOAUT+B45_MESAUT+B45_NUMAUT+B45_SEQUEN
				BK6->(DbSetOrder(4)) // BK6_FILIAL+BK6_CGC
				If B44->(MsSeek(xFilial("B44")+(cAlias)->(BD6_CODPEG + BD6_NUMERO)))
					If B45->(MsSeek(xFilial("B45")+B44->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)))
						aRda[2][5] := AllTrim(B45->B45_CODREF)
						aRda[2][4] := iif(len(aRda[2][5]) <> 11, "J","F")

						If BK6->(MsSeek(xFilial("BK6") + alltrim(B45->B45_CODREF)) )
							aadd(aRda, AllTrim(BK6->BK6_CODESP))
						EndIf
					EndIf
				EndIf  
			EndIf

			If !lReenvio .And. ( (cAliBase)->TIPO == ALTERACAO .and. nTpProcess == PROCESSAR )
				If !PL270ALT(cAlias, aLote, aUsuario, aRDA)							
					PlsPtuLog("Skip -> Guia reprocessada sem alteração - Guia: " + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO), "logMonit.log")
					If GetNewPar("MV_PMONLOG",.F.)       
			  			PlsPtuLog("Skip -> PL270ALT - Guia: " + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO), "Monit.log")
			  		EndIf
					( cAlias )->(dbSkip())	  
					Loop
				EndIf
			EndIf

			// Ponto Entrada para validar se processa guia.
			If lPLSTMON1 
				lContinua:= execBlock( "PLSTMON1",.F.,.F.,{ cAlias,( cAlias )->REG, 1 } )
				if( !lContinua )
					PlsPtuLog("Skip -> Ponto de Entrada  - Guia: " + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO), "logMonit.log")
					If GetNewPar("MV_PMONLOG",.F.)       
			  			PlsPtuLog("Skip -> Ponto de Entrada  - Guia: " + ( cAlias )->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO), "Monit.log")
			  		EndIf
					( cAlias )->( dbSkip() )  
					loop
				endif
			EndIf

			If cGuia <> (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO ) .Or. cSequen <> ( cAlias )->( BD6_SEQUEN )	
				cSequen := ( cAlias )->( BD6_SEQUEN )
				cGuia := (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO )
				lAtuProc := .T.
			Else
				lAtuProc := .F.
			EndIf
		endif
		//--< DADOS DA TABELA DE GUIAS DO MONITORAMENTO >---
		If lContinua .And. lRet 		 
			If PL270B4N( cAlias,aRDA,aUsuario,@aLote,lAtuProc,nTpProcess,cAliBase,cSusep )
				lRetGui := .T.            
				cGuiaProc := (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO ) 			

				If nTpProcess == REENVIAR
					nRecAux := B4N->(Recno())
					cAliasGui	:= PlRetAlias( ( cAlias )->( BD6_CODOPE ),( cAlias )->( BD6_TIPGUI ) )
					cNmGPre   := (cAlias)->&(cAliasGui + "_NUMIMP")
					B4N->(DbSetOrder(2))//B4N_FILIAL + B4N_CMPLOT+B4N_NUMLOT + B4N_NMGOPE + B4N_NMGPRE + B4N_CODRDA
					If B4N->(MsSeek(xFilial("B4N") + (cAliBase)->CMPLOT + (cAliBase)->NUMLOT + cGuiaProc + cNmGPre + (cAlias)->BD6_CODRDA ))   	
						B4N->(reclock("B4N",.F.))
						B4N->B4N_LOTREP	:= Iif(len(aLote)>0,__aRet[ 2 ]+__aRet[ 3 ]+aLote[1],"")
						B4N->(msunlock())	   				
					EndIf 
					B4N->(DbGoTo(nRecAux))
				EndIf			
			EndIf	    
		EndIf				

		( cAlias )->( dbSkip() )

		If cGuiaProc <> (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO ) .Or. (cAlias)->(Eof())
			TotalizaGuia(aLote,cGuiaProc)
		EndIf
	endDo
	(cAlias)->(dbclosearea())
	//Atualiza lote original com status de reprocessado
	if nTpProcess == REENVIAR 		
		B4M->(DbSetOrder(1))//B4M_FILIAL+B4M_SUSEP+B4M_CMPLOT+B4M_NUMLOT+B4M_NMAREN		
		if B4M->(MsSeek(xFilial("B4M") + cSusep + (cAliBase)->CMPLOT + (cAliBase)->NUMLOT))    
			aCampos := { }
			aadd( aCampos,{ "B4M_STATUS", "9" } )	// status    
			gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
			delClassInf()
		endif		
	endif	
	( cAliBase )->( dbSkip() )
endDo
	
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRDA
Obtem os dados da Rede de Atendimento

@author    Jonatas Almeida
@version   1.xx
@since     18/08/2016
/*/
//------------------------------------------------------------------------------------------
static function getRDA( cCodRDA )
	local aReturn	:= {}
	local cAlias	:= getNextAlias()
	local nTotReg	:= 0
	
	BeginSql Alias cAlias
		SELECT BAU_CODIGO, BAU_TISVER, BAU_MUN, BAU_TIPPE, BAU_CPFCGC
		FROM %table:BAU% BAU
		WHERE
		BAU.BAU_FILIAL = %xfilial:BAU% AND
		BAU.BAU_CODIGO = %exp:cCodRDA% AND
		BAU.%notDel%
	EndSql
	
	count to nTotReg
	( cAlias )->( dbGoTop() )
	
	if( nTotReg > 0 )
		aadd( aReturn,.T. )
		aadd( aReturn,{ ( cAlias )->( BAU_CODIGO ), ( cAlias )->( BAU_TISVER ), ( cAlias )->( BAU_MUN ),;
			 			( cAlias )->( BAU_TIPPE ), ( cAlias )->( BAU_CPFCGC ) } )
	else
		aadd( aReturn,.F. )
		aadd( aReturn,{ } )		
	endIf
	
	( cAlias )->( dbCloseArea() )
return aReturn

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaMonit
Grava os dados do Monitoramento TISS - Tabela B4M

@author    Jonatas Almeida
@version   1.xx
@since     16/08/2016
/*/
//------------------------------------------------------------------------------------------
function gravaMonit( nOpc,aCampos,cModel,cLoadModel,lNovaGuia,aLote,nTpProcess )
local oAux
local oStruct
local oModel
local aAux
local aErro
local nI			:= 0
local nPos			:= 0
local lRet 			:= .t.
DEFAULT lNovaGuia	:= .f.
DEFAULT aLote		:= {}
DEFAULT nTpProcess	:= 0

oModel := FWLoadModel( cLoadModel )
oModel:setOperation( nOpc )
oModel:activate()
oAux	:= oModel:getModel( cModel )
oStruct	:= oAux:getStruct()
aAux	:= oStruct:getFields()
if( nOpc <> MODEL_OPERATION_DELETE )
	//begin Transaction
		for nI := 1 to len( aCampos )
			if( nPos := aScan( aAux,{| x | allTrim( x[ 3 ] ) == allTrim( aCampos[ nI,1 ] ) } ) ) > 0
				if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
					aErro := oModel:getErrorMessage()
					If THREADSLOCK == 1
						autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
						autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
						autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
						autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
						autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
						autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
						mostraErro()
					Else
						PlsPtuLog("------------------------------------------------------------------", "Monit.log")
						PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "Monit.log")
						PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "Monit.log")
						PlsPtuLog("Conteudo do erro: " 			+ ' [' + AllToChar( aErro[ 9 ] ) + ']', "Monit.log")
						PlsPtuLog("------------------------------------------------------------------", "Monit.log")
					EndIf
					//disarmTransaction()
					exit
				endif
			endIf
		next nI
	//end Transaction
endIf		
if( lRet := oModel:vldData() )
	oModel:commitData()
else
	aErro := oModel:getErrorMessage()						
	If THREADSLOCK == 1
		autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
		autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
		autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
		autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
		autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
		autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
		mostraErro()
	Else
		PlsPtuLog("------------------------------------------------------------------", "Monit.log")
		PlsPtuLog("Id do campo de origem: " 	+ ' [' + AllToChar( aErro[ 2 ] ) + ']', "Monit.log")
		PlsPtuLog("Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']', "Monit.log")						
		PlsPtuLog("------------------------------------------------------------------", "Monit.log")
	EndIf		
	//disarmTransaction()
endif
oModel:deActivate()
oModel:destroy()
freeObj( oModel )
oModel := nil
delClassInf()

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCompLote
Obtem o numero do lote e competencia

@author    Jonatas Almeida
@version   1.xx
@since     16/08/2016
/*/
//------------------------------------------------------------------------------------------
static function getCompLote(cSusep, cCompet)
	local cAlias	:= getNextAlias()
	local cNumLote	:= 0
	Default cSusep	:= ""
	Default cCompet	:= allTrim( __aRet[ 2 ] + __aRet[ 3 ] )
	
	BeginSQL Alias cAlias
		SELECT MAX( B4M_NUMLOT ) NUMLOT
		FROM %table:B4M% B4M
		WHERE
		B4M_FILIAL = %xFilial:B4M% AND
		B4M_SUSEP  = %exp:cSusep% AND
		B4M_CMPLOT = %exp:cCompet% AND
		B4M.%notDel%
	EndSQL
	
	( cAlias )->( dbGoTop() )
	cNumLote :=  strZero( iif( !empty( ( cAlias )->( NUMLOT ) ),val( ( cAlias )->( NUMLOT ) ), 0 ) + 1, 12 )
	
	( cAlias )->( dbCloseArea() )
return { cNumLote,cCompet,cSusep }

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procLote
Preenchimento e gravacao dos dados do Monitoramento TISS (tabela B4M)

@author    Jonatas Almeida
@version   1.xx
@since     16/08/2016
/*/
//------------------------------------------------------------------------------------------
static function procLote( aLote,nTpProcess, cCompet, nTipoEnvio )
local aCampos	:= {}	
local lRet		:= .F.
local cModel	:= "MODEL_B4M"
local cSusep	:= ""	
default nTpProcess := 1
default nTipoEnvio	:= 1

BA0->( dbSetOrder( 1 ) )	// BA0_FILIAL, BA0_CODIDE, BA0_CODINT
BA0->( dbSeek( xFilial( "BA0" ) + allTrim( __aRet[ 1 ] ) ) )
cSusep := BA0->BA0_SUSEP	

aadd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )		// filial
aadd( aCampos,{ "B4M_SUSEP"		,cSusep } )					// operadora
aadd( aCampos,{ "B4M_STATUS"	,'1' } )					// Processamento
aadd( aCampos,{ "B4M_CODUSR"	,retCodUsr() } )			// codigo usuario corrente
aadd( aCampos,{ "B4M_TISVER"	,BA0->BA0_TISVER  } ) 		// versao TISS
aadd( aCampos,{ "B4M_VERSAO"	,P270RetVer(.F.) } ) 				// versao 
aadd( aCampos,{ "B4M_PRORET"	,'N' } )					// processado retorno	?
aLote := getCompLote(cSusep,cCompet)
aadd( aCampos,{ "B4M_NUMLOT"	,aLote[ 1 ] } )				// numero de lote
aadd( aCampos,{ "B4M_CMPLOT"	,aLote[ 2 ] } )				// competencia lote
If nTpProcess == REENVIAR
 	aadd( aCampos,{ "B4M_REENVI"	,"1" } )				// lote de reenvio
EndIf
aadd( aCampos,{ "B4M_TIPENV"	,AllTrim(Str(nTipoEnvio)) } )
	
lRet := gravaMonit( 3,aCampos,cModel,'PLSM270' )
delClassInf()
	
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getUsuario
Retorna os dados do usuario caso ele tenha que ser enviado no monitoramento

@author    Jonatas Almeida
@version   1.xx
@since     16/08/2016
/*/
//------------------------------------------------------------------------------------------
static function getUsuario( cCodInt,cCodEmp,cMatric,cTipReg,cDigito,dDatRef )

local cAliasBA1 := GetNextAlias()
local cAliasBI3 := GetNextAlias()
local cExpCod	:= ""
local cExpVer	:= ""
local cRegProd	:= ""
local cInfANS	:= ""
local lRet		:= .F.
local lPacInt	:= .F.
local aReturn	:= {}
Default dDatRef	:= dDataBase
	
if( allTrim( __aRet[ 11 ] ) == '2' )
	cInfANS := "%( '0','1' )%"
else
	cInfANS := "%( '1' )%"
endIf
	
BeginSql Alias cAliasBA1
	SELECT
	BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_CODPLA, BA1_VERSAO, BA1_CODMUN, 
	BA3_CODPLA, BA3_VERSAO,
	BTS_NRCRNA, BTS_SEXO, BTS_DATNAS, BTS_CODMUN, BTS_DENAVI, BA1_CPFUSR
		
	FROM
		//--< DADOS DO BENEFICIARIO >---
	%table:BA1% BA1 INNER JOIN
		
		//--< DADOS DA FAMILIA >---
	%table:BA3% BA3 ON
	BA3.BA3_FILIAL = BA1.BA1_FILIAL AND
	BA3.BA3_CODINT = BA1.BA1_CODINT AND
	BA3.BA3_CODEMP = BA1.BA1_CODEMP AND
	BA3.BA3_MATRIC = BA1.BA1_MATRIC AND
	BA3.%notDel% INNER JOIN
		
		//--< DADOS DA VIDA >---
	%table:BTS% BTS ON
	BTS.BTS_FILIAL = BA1.BA1_FILIAL AND
	BTS.BTS_MATVID = BA1_MATVID AND
	BTS.%notDel%
		
	WHERE
	BA1.BA1_FILIAL = %xfilial:BA1% AND
	BA1.BA1_CODINT = %exp:cCodInt% AND
	BA1.BA1_CODEMP = %exp:cCodEmp% AND
	BA1.BA1_MATRIC = %exp:cMatric% AND
	BA1.BA1_TIPREG = %exp:cTipReg% AND
	BA1.BA1_DIGITO = %exp:cDigito% AND
		
		//--< CRITERIOS DE EXCLUSAO PARA ENVIO DO MONITORAMENTO >---
	BA1.BA1_OPEDES = BA1_OPEORI AND
	BA1.BA1_INFANS in %exp:cInfANS% AND // 0-nao | 1-sim
	BA1.%notDel%
EndSql
( cAliasBA1 )->( dbGoTop() ) 

	//--< BI3_CODIGO e BI3_VERSAO vem de BA1_CODPLA, BA1_VERSAO ou BA3_CODPLA, BA3_VERSAO >---
if !empty((cAliasBA1)->BA1_CODPLA)
	cExpCod := (cAliasBA1)->BA1_CODPLA
	cExpVer := (cAliasBA1)->BA1_VERSAO
else
	cExpCod := (cAliasBA1)->BA3_CODPLA
	cExpVer := (cAliasBA1)->BA3_VERSAO
endIf
	
BeginSql Alias cAliasBI3
	SELECT BI3_SUSEP, BI3_SCPA, BI3_APOSRG
	FROM %table:BI3% BI3
	WHERE
	BI3.BI3_FILIAL = %xfilial:BI3% AND
	BI3.BI3_CODINT = %exp:(cAliasBA1)->BA1_CODINT% AND
	BI3.BI3_CODIGO = %exp:cExpCod% AND
	BI3.BI3_VERSAO = %exp:cExpVer% AND
	BI3.%notDel%
EndSql
( cAliasBI3 )->( dbGoTop() )

//--< MONTAGEM DA MATRIZ PARA RETORNO DA FUNCAO >---
if( ( cAliasBA1 )->( !eof() ) .and. !empty( ( cAliasBA1 )->( BA1_CODINT ) ) )
	lRet := .T.
		
	if !Empty((cAliasBI3)->BI3_SUSEP)  .And. (cAliasBI3)->BI3_APOSRG <> "0" 
		cRegProd := (cAliasBI3)->BI3_SUSEP
	elseIf !empty((cAliasBI3)->BI3_SCPA)
		cRegProd := (cAliasBI3)->BI3_SCPA
	else
		cRegProd := "999999"
	endIf
		
	lPacInt := PLSUSRINTE( ( cAliasBA1 )->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG ), dDatRef)[1]
		
	aadd( aReturn, lRet )								//[ 1 ]    - .T. Envia Beneficiario / .F. Nao envia
	aadd( aReturn, { ;
		( cAliasBA1 )->( BA1_CODINT ),;					//[ 2,01 ] - Operadora
		( cAliasBA1 )->( BA1_CODEMP ),;					//[ 2,02 ] - Codigo empresa
		( cAliasBA1 )->( BA1_MATRIC ),;					//[ 2,03 ] - Matricula
		( cAliasBA1 )->( BA1_TIPREG ),;					//[ 2,04 ] - Tipo registro
		( cAliasBA1 )->( BA1_DIGITO ),;					//[ 2,05 ] - Digito
		( cAliasBA1 )->( BA1_CODPLA ),;					//[ 2,06 ] - Codigo do plano (BA1)
		( cAliasBA1 )->( BA1_VERSAO ),;					//[ 2,07 ] - Versao do plano (BA1)
		( cAliasBA1 )->( BA3_CODPLA ),;					//[ 2,08 ] - Codigo do plano (BA3)
		( cAliasBA1 )->( BA3_VERSAO ),;					//[ 2,09 ] - Versao do plano (BA3)
		( cAliasBA1 )->( BTS_NRCRNA ),;					//[ 2,10 ] - Numero Cartao Nacional Saude
		iif( allTrim( ( cAliasBA1 )->( BTS_SEXO ) ) == "2","3","1" ),;	//[ 2,11 ] - Sexo ( 1=Masculino; 2=Feminino; )
		( cAliasBA1 )->( BTS_DATNAS ),;					//[ 2,12 ] - Data de nascimento ou fundacao
		iif(!empty((cAliasBA1)->BA1_CODMUN),(cAliasBA1)->BA1_CODMUN, (cAliasBA1)->BTS_CODMUN),;					//[ 2,13 ] - Codigo Municipio
		( cAliasBA1 )->( BTS_DENAVI ),; 				//[ 2,14 ] - Dcl. nascido vivo
		lPacInt,;										//[ 2,15 ] - Paciente Internaco .T./.F.
		( cAliasBA1 )->( BA1_CPFUSR )} )	 			//[ 2,16 ] - CPF
	aadd( aReturn, cRegProd )							//[ 3 ]    - BI3_SUSEP ou BI3_SCPA ou 999999 - numero de registro do produto
else
	lRet := .F.
	cRegProd := ""
	aadd( aReturn,lRet )
	aadd( aReturn,{} )
	aadd( aReturn,cRegProd )
endIf

( cAliasBI3 )->( dbCloseArea() )
( cAliasBA1 )->( dbCloseArea() )

return aReturn

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCPOs
Obtem os campos do dicionario para montar o grid de Qualidade

@author    Jonatas Almeida
@version   1.xx
@since     30/09/2016
/*/
//------------------------------------------------------------------------------------------
static function getCPOs( aCampos,cAlias )	
	Local nI 		:= 1
	Local nJ 		:= 1
	Local aArea		:= getArea()
	Local aAreaSX3	:= SX3->( getArea() )
	Local aColumns	:= { }	
	Local aCombo	:= { }
	Local cCombo	:= ""
	
	/*	Uso do SX3 necessário pois na tela de detalhamento criamos duas abas com o mesmo Alias mudando apenas o filtro,
		sem criar o alias temporario os registros não ficam filtrados.
	*/ 
	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder( 1 ) ) //X3_ARQUIVO
	
	if( SX3->( msSeek( cAlias ) ) )
		while( SX3->X3_ARQUIVO == cAlias )
		 	if( X3USO( SX3->X3_USADO ) .AND. cNivel >= SX3->X3_NIVEL .and. SX3->X3_BROWSE == "S" )
		 		aadd( aCampos,SX3->X3_CAMPO)
		 	endIf
			SX3->( dbSkip() )
		endDo

		SX3->( DbSetOrder( 2 ) ) // X3_CAMPO
		For	nI:=1 To Len( aCampos )
			If ( SX3->( msSeek( aCampos[nI] ) ) )
			
				aadd( aColumns, FWBrwColumn():New() )
				
				aColumns[ nJ ]:setTitle( X3Titulo() )
				aColumns[ nJ ]:setSize( SX3->X3_TAMANHO )
				aColumns[ nJ ]:setDecimal( SX3->X3_DECIMAL )
				aColumns[ nJ ]:setPicture( SX3->X3_PICTURE )
				aColumns[ nJ ]:setData( &( "{||" + aCampos[ nI ] + "}" ) )
				
				cCombo := X3CBox()
				if( ! empty( cCombo ) )
					aCombo := strToKarr( cCombo,";" )
					aColumns[ nJ ]:setOptions( aCombo )
				endIf
						
				nJ++
			endIf
		next nI
	endIf

	restArea( aAreaSX3 )
	restArea( aArea )
return aColumns

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistCrit
Verifica se existe alguma critica de guia na B4P para o lote
@author    timoteo.bega
@since     10/01/2017
/*/
//------------------------------------------------------------------------------------------
Static Function ExistCrit(aLote)
Local cAliasC	:= GetNextAlias()
Local lRet		:= .F.
Default aLote	:= {"","",""}

BeginSql Alias cAliasC
		
	SELECT B4P_CDCMGU, B4P_DESERR, B4P_NMGOPE
  	FROM %table:B4P% B4P WHERE
	B4P_FILIAL = %xfilial:B4P% 	AND
	B4P_SUSEP = %exp:aLote[3]% AND
	B4P_CMPLOT = %exp:aLote[2]% AND
	B4P_NUMLOT = %exp:aLote[1]% AND
	B4P_NIVERR = %exp:'G'% AND
	B4P.%notDel%							
		
EndSql

If (( cAliasC )->( !eof() ) )
	lRet := .T.
EndIf

( cAliasC )->( dbCloseArea() )

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270EXC
Chama a funcao de exclusao atraves do processa

@author    timoteo.bega
@since     22/02/2017
/*/
//------------------------------------------------------------------------------------------
Static Function PLSM270EXC()

Processa({||PLSM270DEL()},"Monitoramento TISS - Exclusao","Processando...",.T.)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270DEL
Exclusao do monitoramento

@author    Jonatas Almeida
@version   1.xx
@since     17/01/2016
/*/
//------------------------------------------------------------------------------------------
function PLSM270DEL(aAlias,cChaveOri,lReproc,cNumGui)
	local aCampos	:= {}
	
	local lRet		:= .T.
	local lProc		:= .T.

	local nx		:= 0
	
	local cSusep	:= "" //B4M->B4M_SUSEP
	local cCmpLote	:= "" //B4M->B4M_CMPLOT
	local cNumLote	:= "" //B4M->B4M_NUMLOT
	local cReenvio  := "" //B4M->B4M_REENVI  
	local cAlias	:= ""	
	local cMsg		:= ""
	Local cSql      := ""
	local cRet		:= ""

	DEFAULT aAlias	:= { "B4U","B4P","B4O","B4N","B4M" }
	DEFAULT cChaveOri := ""
	DEFAULT lReproc := .F.
	DEFAULT cNumGui := ""
	
	if !lReproc
		cSql := " SELECT B4M_FILIAL,B4M_NMAREN,B4M_SUSEP,B4M_CMPLOT,B4M_NUMLOT,B4M_REENVI " 
		cSql += " FROM " + RetSqlName("B4M") + " B4M "
		cSql += " WHERE B4M_FILIAL = '" + xFilial("B4M") + "' "
		cSql += " AND B4M_OK = '" + oMBrwB4M:cMark + "' "
		cSql += " AND B4M.D_E_L_E_T_ = ' '  "
	else
		cSql := " SELECT B4M_FILIAL,B4M_NMAREN,B4M_SUSEP,B4M_CMPLOT,B4M_NUMLOT,B4M_REENVI " 
		cSql += " FROM " + RetSqlName("B4M") + " B4M "
		cSql += " WHERE R_E_C_N_O_ = " + cvaltochar(B4M->(recno())) 	
	endif

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)	
	
	If B4M->(FieldPos("B4M_TIPENV")) > 0 .And. B4M->B4M_TIPENV == "4"
		aAlias := {"B8R","B8Q","B4M" }
	EndIf
	
	//--< CONFIRMA A EXCLUSAO COM O USUARIO >-----------
	if !lReproc
		cMsg := "Deseja excluir os registros marcados do monitoramento?" + CRLF + CRLF
		if(! msgYesNo( cMsg ) )
			lProc := .F.
		endIf
		
	endif
	
	while !PLEXC->(eof())
		//--< NAO PERMITE EXCLUSAO PARA ARQUIVOS ENVIADOS >-----------
		if( ! empty( PLEXC->B4M_NMAREN ) )
			cRet +=  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT + "- O arquivo não pode ser excluído!" + CRLF
			lProc := .F.
		endIf

		cSusep		:= PLEXC->B4M_SUSEP
		cCmpLote	:= PLEXC->B4M_CMPLOT
		cNumLote	:= PLEXC->B4M_NUMLOT
		cReenvio  	:= PLEXC->B4M_REENVI 

		if( lProc )			
			cRet +=  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT + " - Exclusão efetuada com sucesso!" + CRLF
			cChaveOri := cSusep + cCmpLote + cNumLote
			if lReproc
				cChaveOri += cNumGui
			endif
			ProcRegua(-1)					

			for nx := 1 to len( aAlias )
				cAlias := aAlias[ nx ]

				//B4M_FILIAL + B4M_SUSEP + B4M_CMPLOT + B4M_NUMLOT + B4M_NMAREN
				//B4N_FILIAL + B4N_SUSEP + B4N_CMPLOT + B4N_NUMLOT + B4N_NMGOPE + B4N_CODRDA
				//B4O_FILIAL + B4O_SUSEP + B4O_CMPLOT + B4O_NUMLOT + B4O_NMGOPE + B4O_CODGRU + B4O_CODTAB + B4O_CODPRO + B4O_CODRDA
				//B4P_FILIAL + B4P_SUSEP + B4P_CMPLOT + B4P_NUMLOT + B4P_NMGOPE + B4P_CODGRU + B4P_CODPAD + B4P_CODPRO + B4P_CDCMER
				//B4U_FILIAL + B4U_SUSEP + B4U_CMPLOT + B4U_NUMLOT + B4U_NMGOPE + B4U_CDTBPC + B4U_CDPRPC + B4U_CDTBIT + B4U_CDPRIT
				( cAlias )->( dbSetOrder( 1 ) )

				if( ( cAlias )->( msSeek( xFilial( cAlias ) + cChaveOri ) ) )
					while( ! ( cAlias )->( eof() ) .and. xFilial( cAlias ) + cChaveOri == xFilial( cAlias ) + ( cAlias )->&( cAlias + "_SUSEP" ) + ( cAlias )->&( cAlias + "_CMPLOT" ) + ( cAlias )->&( cAlias + "_NUMLOT" ) + Iif(lReproc, ( cAlias )->&( cAlias + "_NMGOPE" ), "" ))

						cRec := AllTrim(Str((cAlias)->(Recno())))					
						IncProc("Excluindo registros " + AllTrim(aAlias[nx]) + " - " + cRec )
						aCampos := { }

						aadd( aCampos,{ ( cAlias ) + "_FILIAL"	,xFilial( cAlias )	} )	// filial
						aadd( aCampos,{ ( cAlias ) + "_SUSEP"	,cSusep 			} ) // operadora
						aadd( aCampos,{ ( cAlias ) + "_CMPLOT"	,cCmpLote 			} )	// competencia lote
						aadd( aCampos,{ ( cAlias ) + "_NUMLOT"	,cNumLote 			} )	// numero de lote
						If lReproc .And. !Empty(cNumGui)
							aadd( aCampos,{ ( cAlias ) + "_NMGOPE"	,cNumGui 		} )	// numero de lote
						EndIf		
						lRet := gravaMonit( 5,aCampos,'MODEL_' + ( cAlias ),iif( ( cAlias ) == "B4M",'PLSM270','PLSM270' + ( cAlias ) ) )
						delClassInf()

						( cAlias )->( dbSkip() )
					endDo
				endIf
			next nx
		endIf

		//Ajusto lote original quando for excluido um lote de reenvio
		If lRet .And. cReenvio == "1"

			IncProc("Excluindo registros de reenvio")		
			//Ajusta o lote
			cSql := " SELECT B4N_CMPLOT, B4N_NUMLOT FROM " + RetSQLName("B4N")
			cSql += " WHERE B4N_FILIAL = '"+xFilial("B4N")+"' "
			cSql += " AND B4N_LOTREP = '"+ cCmpLote+cNumLote +"' "
			cSql += " AND D_E_L_E_T_ = '  ' " 
			cSql += " GROUP BY B4N_CMPLOT, B4N_NUMLOT "

   			cSql := ChangeQuery(cSql)
		    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLSGUIAS",.F.,.T.)

		    DbSelectArea("PLSGUIAS")   

			Do While !PLSGUIAS->(Eof())  

				If B4M->(MsSeek(xFilial("B4M")+cSusep+PLSGUIAS->B4N_CMPLOT + PLSGUIAS->B4N_NUMLOT))    
					aCampos := { }
					aadd( aCampos,{ "B4M_STATUS", "6" } )
					gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )   
					delClassInf()
    	        EndIf

				PLSGUIAS->(DbSkip())		
			EndDo

			PLSGUIAS->(DbCloseArea())

			//Ajusta guias na B4N
 			cSql := " UPDATE " + RetSqlName('B4N') + " SET B4N_LOTREP = ' ' " 
			cSql += " WHERE B4N_FILIAL = '" + xFilial('B4N') + "' " 
			cSql += " AND B4N_LOTREP = '" + cCmpLote+cNumLote + "' " 
			cSql += " AND D_E_L_E_T_ = ' ' "  

			nRet := TCSQLEXEC(cSql) 
			If nRet >= 0 .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
		    	nRet := TCSQLEXEC("COMMIT") 
			Endif

		EndIf
		PLEXC->(dbskip())
	enddo
	PLEXC->(DbCloseArea())
	If !lReproc
		if lRet .and. !empty(cRet)				
			msgInfo( cRet )
		endIf
	EndIf
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL270StBox
Retorna itens do campo B4M_STATUS

@author  PLS TEAM
@version P11
@since   08/02/17
/*/
//-------------------------------------------------------------------
Function PL270StBox()
	
Return("1-Processado (sem críticas);2-Processado (criticado);3-Arq. envio (sem críticas);4-Arq. envio (criticado);5-Arq. retorno (sem críticas);6-Arq. retorno (criticado);7-Arq. qualidade (criticado);8-Encerrado;9-Encerrado (reprocessado)")

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} envCritANS
Faz reenvio de guias criticadas pelo arquivo de retorno da ANS

@author    Renan Sakai
@version   1.xx
@since     13/02/2017
/*/
//------------------------------------------------------------------------------------------
static function envCritANS()

local cTitulo	:= "Processa Reenvio Guias Criticadas pela ANS - TISS"
local cTexto	:= CRLF + CRLF +;
	"Esta é a opção que irá efetuar a leitura das tabelas do Monitoramento," + CRLF +;
	" e reprocessar as informações encontradas de guias que foram criticadas" + CRLF +;
	" pelo arquivo de Retorno da ANS." + CRLF + CRLF +;
	" Guias com Critica 1308 - Guia já apresentada não entrarão no novo lote. "
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )

Private oProcess

if B4M->(FieldPos("B4M_VERSAO")) <= 0 	
	Aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): B4M_VERSAO ",{ "Ok" }, 2 )
	return	
endIf

if nOpc == 1
	if pergCriANS()
		//--< Cria registro no Monitoramento TISS - B4M >---
		oProcess := msNewProcess():New( { | lEnd | procReenv( @lEnd ) } , "Processando" , "Aguarde..." , .F. )
		oProcess:Activate()
	endIf
endIf

return            

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} pergCriANS
Perguntas para composicao do arquivo de envio

@author    Renan Sakai
@version   1.xx
@since     15/08/2016
/*/
//------------------------------------------------------------------------------------------
static function pergCriANS()
	local lRet			:= .F.
	local aPergs		:= {}
	local cOperadora	:= space( 04 )
	local cAno			:= space( 04 )
	local cMes			:= space( 02 )
	local cLoteDe		:= space( 12 )
	local cLoteAte		:= space( 12 )
	
	aadd(/*01*/ aPergs,{ 1,"Operadora",cOperadora,"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } )
	aadd(/*02*/ aPergs,{ 1,"Ano Competência",cAno,"@R 9999",'.T.',,/*'.T.'*/,40,.T. } )
	aadd(/*03*/ aPergs,{ 1,"Mês Competência",cMes,"@R 99",'.T.',,/*'.T.'*/,40,.T. } )
	aadd(/*04*/ aPergs,{ 1,"Lote De" ,cLoteDe ,"@!",'.T.','',/*'.T.'*/,60,.F. } )
	aadd(/*05*/ aPergs,{ 1,"Lote Ate",cLoteAte,"@!",'.T.','',/*'.T.'*/,60,.T. } )
	
	if( paramBox( aPergs,"Parâmetros - Processa arquivo de envio ANS",__aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270REP',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
		//Vou ajustar o array de perguntas para o padrao da rotina
		Aadd(/*06*/__aRet,"")//Local de Digitação
		Aadd(/*07*/__aRet,"")//Protocolo De
		Aadd(/*08*/__aRet,"")//Protocolo Ate
		Aadd(/*09*/__aRet,"2")//Considera Guias Estornadas -> 2-Nao
		Aadd(/*10*/__aRet,"2")//Gerar como exclusao -> 2-Nao
		Aadd(/*11*/__aRet,"2")//Somente Us.Inf.ANS -> 2-Nao
		Aadd(/*12*/__aRet,"1")//Considera Guias Processadas -> 1-Sim
		Aadd(/*13*/__aRet,"1")//Cons Data de Process
		Aadd(/*14*/__aRet,1)//Tipo de envio
		Aadd(/*15*/__aRet,"1")//Situacao da guia
		  
		if( validPergEnvio( __aRet ) )
			lRet := .T.
		else
			lRet := pergEnvio()
		endIf
	endIf    
	
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL270ALT
Verifica as alterações comparando Data de Mudança de Fase com Data de envio do Monitoramento.

@author  Lucas Nonato
@version P11
@since   15/02/17
/*/
//-------------------------------------------------------------------
static function PL270ALT(cAlias, aLote, aUsuario, aRda)
local lRet 		:= .F.
local cChave	:= Iif(Empty((cAlias)->BD5_LOTMOF),(cAlias)->BD5_LOTMOP,(cAlias)->BD5_LOTMOF)
local cAlter	:= ""
local cAliasGui := PlRetAlias( ( cAlias )->( BD6_CODOPE ),( cAlias )->( BD6_TIPGUI ) )
local cCodCID	:= ""
local cCodMunEx	:= ""
local cCNES		:= ""
local cTpEvt	:= ""
local cSql 		:= ""
local cTpAdm	:= ""

B4N->(dbSetOrder(1)) 	// B4N_FILIAL, B4N_SUSEP, B4N_CMPLOT, B4N_NUMLOT, B4N_NMGOPE, B4N_CODRDA
BR8->( dbSetOrder(1))  	// BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN   

// Verifica se a guia já não foi enviada no lote.
If !B4N->(MsSeek(xFilial("B4N") + aLote[3] + aLote[2] + aLote[1] + (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ))
	
	// Verifica se encontrou o lote que esta gravado no BD5/BE4
	If B4N->(MsSeek(xFilial("B4N") + aLote[3] + cChave +  (cAlias)->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) ))
		// 	Código Nacional de Estabelecimento de Saúde
		BR8->(dbSeek(xFilial("BR8") + ((cAlias)->(BD6_CODPAD))+ ((cAlias)->(BD6_CODPRO) )))
		If BB8->( dbSeek( xFilial("BB8")+(cAlias)->(BD6_CODRDA+BD6_CODOPE+ &(cAliasGui + "_CODLOC") ) ))
			If !Empty(BB8->BB8_CNES)
				cCNES		:= BB8->BB8_CNES
			EndIf
			cCodMunEx	:= Iif( !Empty( BB8->BB8_CODMUN ),BB8->BB8_CODMUN,aRda[2,3] )
		EndIf

		cTpAdm 	:=  AllTrim(PLSGETVINC("BTU_CDTERM", "BDR", .F., "23", (cAlias)->(&(cAliasGui+"_TIPADM")), .F.))

		cSql := "SELECT COUNT(*) QTD FROM " + RetSqlName("B4O") + " B4O "
		cSql += " WHERE B4O_FILIAL 		= '" + xFilial("B4O") + "' "	
		cSql += " AND B4O_SUSEP		= '" + B4N->B4N_SUSEP + "' "	
		cSql += " AND B4O_CMPLOT	= '" + B4N->B4N_CMPLOT + "' " 
		cSql += " AND B4O_NUMLOT	= '" + B4N->B4N_NUMLOT + "' " 
		cSql += " AND B4O_NMGOPE	= '" + B4N->B4N_NMGOPE + "' "
		cSql += " AND B4O_CBOS = '999999' "
		cSql += " AND B4O.D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbQtd",.F.,.T.)
		
		if TrbQtd->QTD > 0
			cAlter += "X"
		endif
		TrbQtd->(dbCloseArea())

		// 	Tipo de evento atenção
		cTpEvt		:= PLTPEVAT((cAlias)->(BD6_TIPGUI), (cAlias)->(&(cAliasGui+"_TIPPRE")), Alltrim((cAlias)->(BD6_CODPAD)),Alltrim((cAlias)->(BD6_CODPRO)))
		
		cAlter += IIf( alltrim(B4N->B4N_TPEVAT) == cTpEvt  		,"", "B4N_TPEVAT;")
		cAlter += IIf( B4N->B4N_CNES   == cCNES  				,"", "B4N_CNES;")
		cAlter += IIf( B4N->B4N_CDMNEX == cCodMunEx  			,"", "B4N_CDMNEX;")
		cAlter += IIf( B4N->B4N_NUMCNS == aUsuario[2,10]  		,"", "B4N_NUMCNS;")
		cAlter += IIf( B4N->B4N_SEXO   == aUsuario[2,11]  		,"", "B4N_SEXO;")
		cAlter += IIf( B4N->B4N_DATNAS == STOD(aUsuario[2,12])  ,"", "B4N_DATNAS;")
		cAlter += IIf( B4N->B4N_CDMNRS == aUsuario[2,13]  		,"", "B4N_CDMNRS;")
		cAlter += IIf( AllTrim(B4N->B4N_SCPRPS) == AllTrim(aUsuario[3]) 		,"", "B4N_SCPRPS;")
		cAlter += IIf( B4N->B4N_FORENV == (cAlias)->BD6_TPGRV 	,"", "B4N_FORENV;")
		cAlter += IIf( B4N->B4N_CODRDA == (cAlias)->BD6_CODRDA  ,"", "B4N_CODRDA;")
		cAlter += IIf( alltrim(B4N->B4N_TIPADM) == cTpAdm  				,"", "B4N_TIPADM;")
		
		If cAliasGui == 'BD5'
			cAlter += IIf( B4N->B4N_INDACI == (cAlias)->BD5_INDACI ,"", "B4N_INDACI;")
			cAlter += IIf( B4N->B4N_TIPATE == (cAlias)->BD5_TIPATE ,"", "B4N_TIPATE;")
			
		Else
			
			//CID
			If !Empty( (cAlias)->BE4_CIDREA )
				cCodCID := AllTrim((cAlias)->BE4_CIDREA)
			Else
				cCodCID := AllTrim((cAlias)->BE4_CID)
			EndIf
			
			cAlter += IIf( B4N->B4N_TIPINT == (cAlias)->BE4_GRPINT  	,"", "B4N_TIPINT;")
			cAlter += IIf( B4N->B4N_REGINT == (cAlias)->BE4_REGINT  	,"", "B4N_REGINT;")
			cAlter += IIf( B4N->B4N_MOTSAI == PLSGETVINC("BTU_CDTERM", "BIY", .F., "39", (cAlias)->BE4_TIPALT, .F.)  	,"", "B4N_MOTSAI;")
			cAlter += IIf( B4N->B4N_INAVIV == Iif((cAlias)->BE4_ATERNA == "0", "N","S")  ,"", "B4N_INAVIV;")
			cAlter += IIf( B4N->B4N_NRDCNV == (cAlias)->BE4_NRDCNV  	,"", "B4N_NRDCNV;")
			cAlter += IIf( B4N->B4N_NRDCOB == (cAlias)->BE4_NRDCOB  	,"", "B4N_NRDCOB;")
			cAlter += IIf( B4N->B4N_TIPFAT == (cAlias)->BE4_TIPFAT  	,"", "B4N_TIPFAT;")
			cAlter += IIf( B4N->B4N_DIAACP == alltrim(BR8->BR8_TIPDIA)  ,"", "B4N_DIAACP;")
			cAlter += IIf( B4N->B4N_INDACI == (cAlias)->BE4_INDACI  	,"", "B4N_INDACI;")
			
		EndIf
	EndIf
EndIf

If !Empty(cAlter)
	lRet := .T.
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} excLotAlt
Exclui lote vazio criado por meio de busca de guias alteradas

@author  Lucas Nonato
@version P11
@since   17/02/17
/*/
//-------------------------------------------------------------------
Static Function excLotAlt(aLote)
	Local aCampos := {}
	Local lRet	  := .F.
	
	B4N->( dbSetOrder( 1 ) ) //B4N_FILIAL + B4N_SUSEP + B4N_CMPLOT + B4N_NUMLOT + B4N_NMGOPE + B4N_CODRDA
	if( ! B4N->( dbSeek( xFilial( "B4N" ) + aLote[3] + aLote[2] + aLote[1] ) )  )
		aCampos := { }
		aadd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )	// filial
		aadd( aCampos,{ "B4M_SUSEP"		,B4M->B4M_SUSEP } )		// operadora
		aadd( aCampos,{ "B4M_CMPLOT"	,B4M->B4M_CMPLOT } )	// competencia lote
		aadd( aCampos,{ "B4M_NUMLOT"	,B4M->B4M_NUMLOT } )	// numero de lote
		
		if( gravaMonit( 5,aCampos,'MODEL_B4M','PLSM270' ) )
			lRet := .T.
		endIf
	endIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procReenv
Envio do reprocessamento das criticas realizadas pela ANS

@author    Renan Sakai
@version   1.xx
@since     16/02/2017

/*/
//------------------------------------------------------------------------------------------
Static Function procReenv( lEnd )
local aLote	    := {}
local aCampos	:= {}
local aGuias	:= {}
local aG1308	:= {}
local cSusep    := ""
local cSql		:= ""
local cSqlName 	:= ""
local cini		:= time()
local cfim		
local cAlias	:= getNextAlias()
local nX		:= 1
local nLoop		:= 0
local nZ		:= 1
private oTmpTable := nil

B4P->( dbSetOrder(1))	// B4P_FILIAL, B4P_SUSEP, B4P_CMPLOT, B4P_NUMLOT, B4P_NMGOPE
B4M->( dbSetOrder(1))	// B4M_FILIAL, B4M_SUSEP, B4M_CMPLOT, B4M_NUMLOT, B4M_NMAREN
BA0->( dbSetOrder(1))	// BA0_FILIAL, BA0_CODIDE, BA0_CODINT
BA0->( dbSeek( xFilial( "BA0" ) + allTrim( __aRet[ 1 ] ) ) )
cSusep := BA0->BA0_SUSEP	
   
//Busca lote com guias criticadas
cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
cSql += " BCI_TIPGUI TIPGUI, B4N_CMPLOT CMPLOT, B4N_NUMLOT NUMLOT, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI  " 
cSql += " FROM ( SELECT B4P_FILIAL, B4P_SUSEP, B4P_CMPLOT, B4P_NUMLOT, B4P_NMGOPE "
cSql += " FROM " + RetSqlName('B4P') + " B4P " 
cSql += " WHERE B4P_FILIAL = '" + xFilial('B4P') + "' " 
cSql += " AND B4P_SUSEP = '" + cSusep + "' "
cSql += " AND B4P_CMPLOT = '" + __aRet[ 2 ] + __aRet[ 3 ] + "' "
cSql += " AND B4P_NUMLOT >= '" + __aRet[ 4 ] + "' "
cSql += " AND B4P_NUMLOT <= '" + __aRet[ 5 ] + "' "
cSql += " AND B4P.D_E_L_E_T_ = ' ' "
cSql += " AND B4P_ORIERR = '2' "
cSql += " AND B4P_CDCMER <> '1308' "
cSql += " GROUP BY B4P_FILIAL, B4P_SUSEP, B4P_CMPLOT, B4P_NUMLOT, B4P_NMGOPE ) B4P2"
cSql += " INNER JOIN " + RetSqlName("B4N")+ " B4N "
cSql += " ON  B4N_FILIAL = B4P_FILIAL "
cSql += " AND B4N_SUSEP  = B4P_SUSEP "
cSql += " AND B4N_CMPLOT = B4P_CMPLOT "
cSql += " AND B4N_NUMLOT = B4P_NUMLOT "
cSql += " AND B4N_NMGOPE = B4P_NMGOPE "
cSql += " AND B4N_LOTREP = ' ' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' " 
csql += " inner Join "
cSql += RetsqlName("BCI") + " BCI "
csql += " On "
csql += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
cSql += " BCI_CODOPE = B4N_CODOPE AND "
cSql += " BCI_CODLDP = B4N_CODLDP AND "
csql += " BCI_CODPEG = B4N_CODPEG AND "
csql += " BCI.D_E_L_E_T_ = ' ' "

//Busca lote totalmente criticado
cSql += " UNION SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
cSql += " BCI_TIPGUI TIPGUI, B4N_CMPLOT CMPLOT, B4N_NUMLOT NUMLOT, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI  " 
cSql += " FROM " + RetSqlName('B4N') + " B4N "
csql += " inner Join "
cSql += RetsqlName("BCI") + " BCI "
csql += " On "
csql += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
cSql += " BCI_CODOPE = B4N_CODOPE AND "
cSql += " BCI_CODLDP = B4N_CODLDP AND "
csql += " BCI_CODPEG = B4N_CODPEG AND "
csql += " BCI.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName("B4M")+ " B4M "
cSql += " ON B4M_FILIAL = '" + xFilial('B4M') + "' " 
cSql += " AND B4M_SUSEP = B4N_SUSEP "
cSql += " AND B4M_CMPLOT = B4N_CMPLOT "
cSql += " AND B4M_NUMLOT = B4N_NUMLOT "
cSql += " AND B4M.D_E_L_E_T_ = ' ' "     
cSql += " WHERE B4N_FILIAL =  '" + xFilial('B4N') + "' " 
cSql += " AND B4N_SUSEP  = '" + cSusep + "' "
cSql += " AND B4N_CMPLOT = '" + __aRet[ 2 ] + __aRet[ 3 ] + "' "
cSql += " AND B4N_NUMLOT >= '" + __aRet[ 4 ] + "' "
cSql += " AND B4N_NUMLOT <= '" + __aRet[ 5 ] + "' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "
cSql += " AND B4M_STATUS = '6' "
cSql += " AND B4M_CODREJ <> ' ' " 

cSql := ChangeQuery(cSql)

If GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("-----------------------------------------------", "Monit.log")
	PlsPtuLog("procReenv", "Monit.log")    
	PlsPtuLog(cSql, "Monit.log")
	PlsPtuLog("-----------------------------------------------", "Monit.log")
EndIf

If Select("TrbR") > 0
	TrbR->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbR",.F.,.T.)

If TrbR->(Eof())
	// Ajustar
	alert("Não foram encontrados registros para a competencia selecionada.")
	TrbR->(dbCloseArea())
	Return
EndIf

TrbR->(dbCloseArea())

fCriaTmp(cAlias,@oTmpTable, .t.)
cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, CMPLOT, NUMLOT, DTPAGT, DTDIGI ) " + cSql
PLSCOMMIT(cSql)
hubGuias(.t.)

procLote( @aLote, 2, allTrim( __aRet[ 2 ] + __aRet[ 3 ] ) )
oProcess:IncRegua1( "Reenvio ... Lote: [" + aLote[2] + "] " + aLote[1]  )

cSql := "SELECT COUNT(*) QTD FROM " + oTmpTable:getrealName() 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
nQtd 	 := TrbFim->QTD
nQtdFull := TrbFim->QTD
TrbFim->(dbCloseArea())

if THREADSLOCK == 1
 	oProcess:SetRegua2( nQtdFull ) 
else
	oProcess:SetRegua2( -1 ) 
endif

cSqlName 	:= oTmpTable:getrealName()

if THREADSLOCK == 1
	PLPROCMONIT( "01", cEmpAnt, cFilAnt, __aRet, lEnd, oTmpTable:getrealName(),aLote,THREADSLOCK,2) 
else	
	if substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" .or. Upper(TCGetDb()) == "POSTGRES"
		TcSqlEXEC("DROP TABLE TEMPMONIT1")
   		nRet := TcSqlEXEC(" CREATE TABLE TEMPMONIT1 AS SELECT * FROM " + oTmpTable:getrealName() )
		if nRet >= 0
			TcSqlEXEC("COMMIT") 
		endif
		cSqlName := 'TEMPMONIT1'		
	endif
	for nX := 1 to THREADSLOCK	
	 	startJob("PLPROCMONIT",GetEnvServer(),.F.,strzero(nX,2), cEmpAnt, cFilAnt, __aRet, lEnd, cSqlName,aLote,THREADSLOCK,2)
	next
endif

while nQtd <> 0
	nQtdAnt := nQtd
	cSql := "SELECT COUNT(*) QTD FROM " + cSqlName + " WHERE OK = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
	nQtd := TrbFim->QTD
	TrbFim->(dbCloseArea())
	if nQtd == nQtdAnt
		nLoop++
	else
		nLoop := 0
	endif 
	oProcess:IncRegua2( "[" + cvaltochar(nQtdFull - nQtd) +  "] de [" + cvaltochar(nQtdFull) + "]"  )
	if nQtd <> 0
		sleep(5000)
	endif
	if nLoop == 50
		exit
	endif		
enddo

If !excLotAlt(aLote)
	PLVLDMON( aLote )
	cfim := time()
	Aviso( "Resumo","Lote(s) reprocessado(s) " + CRLF + cValToChar(nQtdFull) + " Guia(s) Reprocessada(s)" + " Guia(s) Reprocessada(s)" + CRLF + 'Inicio: ' + cvaltochar( cini ) + "  -  " + 'Fim: ' + cvaltochar( cfim ) ,{ "Ok" }, 2 )
	B4P->( dbSetOrder( 1 ) ) // B4P_FILIAL + B4P_SUSEP + B4P_CMPLOT + B4P_NUMLOT + B4P_NMGOPE + B4P_CODPAD + B4P_CODPRO + B4P_CDCMER
	If( B4P->( dbSeek( xFilial( "B4P" ) + B4M->B4M_SUSEP + B4M->B4M_CMPLOT + B4M->B4M_NUMLOT ) ) )
		cStatus := "2" // Processado (criticado)
	Else
		cStatus := "1" // Processado (sem Criticas)
	EndIf

	aCampos := { }
	aAdd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )	// filial
	aAdd( aCampos,{ "B4M_SUSEP"		,B4M->B4M_SUSEP } )		// operadora
	aAdd( aCampos,{ "B4M_CMPLOT"	,B4M->B4M_CMPLOT } )	// competencia lote
	aAdd( aCampos,{ "B4M_NUMLOT"	,B4M->B4M_NUMLOT } )	// numero de lote
	aAdd( aCampos,{ "B4M_STATUS"	,cStatus } )			// status
	gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
	delClassInf()
EndIf

cfim := time()

// Se o lote for criticado apenas por guias duplicadas encerro ele
For nZ := 1 To Len(aG1308) 
	If Len(aGuias[1]) == 0 .And. B4M->(MsSeek(xFilial("B4M")+ aG1308[nZ][1] + aG1308[nZ][2] + aG1308[nZ][3]))
		aCampos := { }
		aadd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )	// filial
		aadd( aCampos,{ "B4M_SUSEP"		,aG1308[nZ][1] } )		// operadora
		aadd( aCampos,{ "B4M_CMPLOT"	,aG1308[nZ][2] } )		// competencia lote
		aadd( aCampos,{ "B4M_NUMLOT"	,aG1308[nZ][3] } )		// numero de lote
		aadd( aCampos,{ "B4M_STATUS"	,"8" } )				// status
		gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
		delClassInf()
	Endif
Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL270LocDg
F3 da listagem dos locais de atendimento

@author  Lucas Nonato
@version P11
@since   30/03/17
/*/
//-------------------------------------------------------------------
Function PL270LocDg(cDado)

	Static objCENFUNLGP := CENFUNLGP():New()

Local oDlg		:= Nil
Local cSql		:= ""
Local aConjunto	:= {}
Local nFor		:= 0
Local nOpc		:= 0
Local bOK		:= { || nOpc := 1, oDlg:End() }
Local bCancel	:= { || oDlg:End() }
Default cDado	:= ''

cSql := " SELECT BCG_CODLDP, BCG_DESCRI"
cSql += "   FROM "+ RetSQLName("BCG")
cSql += "  WHERE BCG_FILIAL = '" + xFilial("BCG") + "' "
cSql += "  	 AND D_E_L_E_T_ <> '*' ORDER BY BCG_CODLDP"

cStm := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cStm),"TRB",.F.,.T.)

While !TRB->( Eof() )
	aAdd( aConjunto , { TRB->BCG_CODLDP,TRB->BCG_DESCRI,.F. } )
	TRB->( DbSkip() )
EndDo
TRB->( DbCloseArea() )

DEFINE MSDIALOG oDlg TITLE 'Locais a processar' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
@ 020,012 SAY oSay PROMPT 'Selecione os locais a serem procesados' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))     
oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     
oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))     

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {.F.,"BCG_CODLDP","BCG_DESCRI"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oConjunto:aObfuscatedCols := aBls
	endif

oConjunto:SetArray(aConjunto)         
oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 50 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpc == 1
                  
   cDado := ""
   For nFor := 1 To Len(aConjunto)
       If aConjunto[nFor,3]
          cDado += aConjunto[nFor,1]+","
       Endif 
   Next

Endif
                                  
//Tira a virgula do final
If Subs(cDado,Len(cDado),1) == ","
	cDado := Subs(cDado,1,Len(cDado)-1)
EndIf 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TotalizaGuia
Atualiza os campos da tabela B4N de acordo com os itens na B4O

@author  timoteo.bega
@version P11
@since   06/04/2017
/*/
//-------------------------------------------------------------------
Static Function TotalizaGuia(aLote,cGuiaProc)
Local cSql				:= ""
Local nB4N_VLTPRO		:= 0
Local aCampos			:= {}
Local lGrvMonit		:= .F.
Default aLote			:= {}
Default	cGuiaProc	:= ""

If Len(aLote) >= 0 .And. !Empty(cGuiaProc)

	cSql := "SELECT B4N.R_E_C_N_O_ RECB4N, SUM(B4O_VLRINF) B4O_VLRINF, SUM(B4O_VLPGPR) B4O_VLPGPR, SUM(B4O_VLRPGF) B4O_VLRPGF , SUM(B4O_VLRCOP) B4O_VLRCOP "
	cSql += "FROM " + RetSqlName("B4O") + " B4O, " + RetSqlName("B4N") + " B4N "
	cSql += "WHERE B4O_FILIAL	= B4N_FILIAL AND B4O_SUSEP	= B4N_SUSEP AND B4O_CMPLOT	= B4N_CMPLOT AND B4O_NUMLOT = B4N_NUMLOT AND B4O_NMGOPE	= B4N_NMGOPE AND B4O_CODRDA = B4N_CODRDA "
	cSql += "AND B4O_FILIAL = '" + xFilial("B4O") + "' "	
	cSql += "AND B4O_SUSEP	= '" + aLote[3] + "' "	
	cSql += "AND B4O_CMPLOT	= '" + aLote[2] + "' " 
	cSql += "AND B4O_NUMLOT	= '" + aLote[1] + "' " 
	cSql += "AND B4O_NMGOPE	= '" + cGuiaProc + "' "
	cSql += "AND B4O.D_E_L_E_T_=' ' AND B4N.D_E_L_E_T_=' ' "
	cSql += "GROUP BY B4N.R_E_C_N_O_ "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TB4O",.F.,.T.)
	
	If !TB4O->(Eof())

		B4N->(dbSetOrder(1))
		B4N->(dbGoTo(TB4O->RECB4N))
		nB4N_VLTPRO := TB4O->B4O_VLRINF - B4N->B4N_VLTGLO
		aAdd( aCampos,{ "B4N_VLTINF", TB4O->B4O_VLRINF							} )//Valor total informado
		aAdd( aCampos,{ "B4N_VLTFOR", TB4O->B4O_VLRPGF							} )//Valor pago fornecedores
		aAdd( aCampos,{ "B4N_VLTCOP", TB4O->B4O_VLRCOP							} )//Valor total coparticipacao
		aAdd( aCampos,{ "B4N_VLTPRO", nB4N_VLTPRO								} )//Valor processado
		lGrvMonit := gravaMonit( 4,aCampos,'MODEL_B4N','PLSM270B4N' )
		delClassInf()
		If !lGrvMonit
			lGrvMonit := lGrvMonit
		EndIf

	EndIf
	
	TB4O->(dbCloseArea())

EndIf

Return

/*/{Protheus.doc} PLSCOMMIT
Commit na tabela temporaria.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
function PLSCOMMIT(cSql)

nRet := tcSqlExec(cSql) 

if nRet < 0
    
    userException("Erro na execução do update PLSCOMMIT -> [ " + tcSqlERROR() + "]")

elseIf tcIsconnected() .and. ( "ORACLE" $ upper(TCGetDb()) )
    
    tcSqlExec("COMMIT")

endIf

return (nRet >= 0)

//-------------------------------------------------------------------
/*/{Protheus.doc} hubGuias
Quebra as guias de acordo com a quantidade de JOBS.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
static function hubGuias(lAll)
local cSql 	:= ""
local nQtd 	:= 0
local nX	:= 0
default lAll := .f.

cSql += " SELECT COUNT(*) QTD FROM " +  oTmpTable:getrealName()
cSql += " WHERE FLAG = ' ' "

lOracle :=  SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
lPOSTGRES :=  SubStr(Alltrim(Upper(TCGetDb())),1,8) == "POSTGRES" 
lDB2 :=  SubStr(Alltrim(Upper(TCGetDb())),1,3) == "DB2" 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbQtd",.F.,.T.)
nQtd := int(TrbQtd->QTD/THREADSLOCK)
if nQtd == 0
	nQtd := TrbQtd->QTD
endif
TrbQtd->(dbCloseArea())

for nX := 1 to THREADSLOCK

	if nX == THREADSLOCK 
		cSql := " UPDATE " + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "'  WHERE FLAG = ' ' " + iif(lAll, "", " AND TIPGUI <> '05' ")
	else
		if lOracle .Or. lDB2
			cSql := " UPDATE " + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "' "
			cSql += " WHERE R_E_C_N_O_ IN (  SELECT R_E_C_N_O_ FROM ( "
			cSql += "	SELECT R_E_C_N_O_, FLAG FROM " + oTmpTable:getrealName() + " ORDER BY R_E_C_N_O_) q1 " 
			cSql += " 		WHERE FLAG = ' ' " + iif(lAll, "", " AND TIPGUI <> '05' ") + " AND ROWNUM <= " + cvaltochar(nQtd) + " ) "
		elseif lPOSTGRES
			cSql := " UPDATE " + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "' "
			cSql += " WHERE R_E_C_N_O_ IN (  SELECT R_E_C_N_O_ FROM ( "
			cSql += " SELECT R_E_C_N_O_, FLAG FROM " + oTmpTable:getrealName() + " ORDER BY R_E_C_N_O_) q1 " 
			cSql += " WHERE FLAG = ' ' " + iif(lAll, "", " AND TIPGUI <> '05' ") + " 
			cSql += " LIMIT " + cvaltochar(nQtd) + " ) "
		else	
			cSql := " UPDATE TOP(" + cvaltochar(nQtd) + ")" + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "' WHERE FLAG = ' ' " + iif(lAll, "", "AND TIPGUI <> '05'")
		endif
	endif

	PLSCOMMIT(cSql)
	/*cSql := " SELECT COUNT(*) QTD FROM " +  oTmpTable:getrealName()
	cSql += " WHERE FLAG = '" + strzero(nX,2) + "'"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbQtd",.F.,.T.)	
	TrbQtd->(dbCloseArea())*/
next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLPROCMONIT
Dispara a chamada da rotina de processamento de dados

@author  Lucas Nonato
@version P11
@since   07/04/2017
/*/
//-------------------------------------------------------------------
 
Function PLPROCMONIT( cFlag, cEmpAnt, cFilAnt, aRet, lEnd, cAliPri, aLoteOri, nThreads, nTpProcess )

local cSql		:= ""
local cAlias	:= GetNextAlias()
private __aRet 	:= aClone(aRet)
private aLote	:= aClone(aLoteOri)

default nTpProcess	:= 1

if nThreads > 1
	ptInternal(1,"[Monitoramento TISS] JOB: " + cFlag ) 
	rpcSetType(3)    
	rpcSetEnv( cEmpAnt, cFilAnt,,,'PLS',, )   
endif 

if GetNewPar("MV_PMONLOG",.F.) .and. cFlag = '01'
	PlsPtuLog("-----------------------------------------------", "Monit.log")
	PlsPtuLog("Alias temporario: " + cAliPri, "Monit.log")
	cSql := " SELECT COUNT(*) QTD FROM " +  cAliPri
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbQtd2",.F.,.T.)		
	PlsPtuLog("Quantidade de registros a serem processados: " + cvaltochar(TrbQtd2->QTD), "Monit.log")
	TrbQtd2->(dbCloseArea())
endif

//cSql := " SELECT COUNT(*) QTD FROM " +  cAliPri + " WHERE FLAG = '" + cFlag + "' AND OK = ' ' "
//dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbQtd2",.F.,.T.)
//PlsPtuLog("["+cFlag+"] Quantidade de registros a serem processados: " + cvaltochar(TrbQtd2->QTD), "Monit2.log")
//TrbQtd2->(dbCloseArea())

cSql := " SELECT * FROM " + cAliPri + " WHERE FLAG = '" + cFlag + "' AND OK = ' ' ORDER BY CODPEG, NUMERO "
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

processaDados( cAlias, @lEnd, nTpProcess, aLote, cAliPri )

(cAlias)->(dbclosearea())

if nThreads > 1
	rpcClearEnv()
endif

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270QRY
Funcao criada para executar o ChangeQuery e abrir a area de trabalho para as querys

@param		cSql		Instrucao sql a ser executada
@param		cAliSql		Nome da area de trabalho a ser criada
@author		timoteo.bega
@since		15/04/2017
/*/
//------------------------------------------------------------------------------------------
Function PLSM270QRY(cSql,cAliSql)
Local lRet	:= .F.

If !Empty(cSql) .And. !Empty(cAliSql)

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliSql,.F.,.T.)
	
	If !(cAliSql)->(Eof())
		lRet := .T.
	EndIf
	
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} reprocMon
Reprocessa um lote criticado pelo sistema

@author    Lucas Nonato
@version   1.xx
@since     25/04/2017

/*/
//------------------------------------------------------------------------------------------
Static Function reprocMon()
local lEnd := .F.
local cTitulo	:= "Reprocessa arquivo de envio - TISS"
local cTexto	:= CRLF + CRLF + "Esta é a opção que irá reprocessar apenas os itens criticados pelo sistema dentro do lote."
	
local aOpcoes	:= { "Processar","Cancelar" }
local nTaman	:= 3
local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )

Private oProcess

if B4M->(FieldPos("B4M_VERSAO")) <= 0 	
	Aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): B4M_VERSAO ",{ "Ok" }, 2 )
	return	
endIf

if nOpc == 1
	oProcess := msNewProcess():New( { | lEnd | PLSM270REP( @lEnd ) } , "Reprocessando" , "Aguarde..." , .F. )
	oProcess:Activate()
endif

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270REP
Reprocessa um lote criticado pelo sistema

@author    Lucas Nonato
@version   1.xx
@since     25/04/2017

/*/
//------------------------------------------------------------------------------------------
Function PLSM270REP( lEnd )
local aLote	    := {}
local aCampos	:= {}
local aLoteAnt	:= {}
local aAlias 	:= {"B4U","B4P","B4O","B4N"}
local cSql		:= ""
local cAlias	:= getNextAlias()
local cini		:= time()
local cfim		
local cSqlName 	:= ""
local nX		:= 1
local nLoop		:= 0
local nQtdAnt	:= 0
local nQtdFull	:= 0
private oTmpTable := nil

If B4M->B4M_STATUS <> '2'
	Alert("Lote não criticado pelo sistema.")
	Return .F.
EndIf

fCriaTmp(cAlias,@oTmpTable)

//Busca lote com guias criticadas
cSql += " SELECT B4N_CODOPE CODOPE, B4N_CODLDP CODLDP, B4N_CODPEG CODPEG, B4N_CODRDA CODRDA, B4N_NUMERO NUMERO, '0' TIPO, "
cSql += " BCI_TIPGUI TIPGUI, B4N_DTPAGT DTPAGT, B4N_DTPRGU DTDIGI  " 
cSql += " FROM " + RetSqlName('B4N') + " B4N "
csql += " inner Join "
cSql += RetsqlName("BCI") + " BCI "
csql += " On "
csql += " BCI_FILIAL = '" + xfilial("BCI") + "' AND "
cSql += " BCI_CODOPE = B4N_CODOPE AND "
cSql += " BCI_CODLDP = B4N_CODLDP AND "
csql += " BCI_CODPEG = B4N_CODPEG AND "
csql += " BCI.D_E_L_E_T_ = ' ' "
cSql += " WHERE B4N_FILIAL =  '" + xFilial('B4N') + "' " 
cSql += " AND B4N_SUSEP  = '" + B4M->B4M_SUSEP + "' "
cSql += " AND B4N_CMPLOT = '" + B4M->B4M_CMPLOT + "' "
cSql += " AND B4N_NUMLOT = '" + B4M->B4M_NUMLOT + "' "
cSql += " AND B4N_STATUS <> '1' "
cSql += " AND B4N.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)

If Select("TrbRp") > 0
	TrbR->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbRp",.F.,.T.)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTPAGT, DTDIGI) " + cSql

PLSCOMMIT(cSql)

hubGuias(.t.)

If GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("-----------------------------------------------", "Monit.log")
	PlsPtuLog("reprocMon", "Monit.log")    
	PlsPtuLog(cSql, "Monit.log")
	PlsPtuLog("-----------------------------------------------", "Monit.log")
EndIf

If TrbRp->(Eof())
	alert("Não foram encontrados registros para a competencia selecionada.")
	TrbRp->(dbCloseArea())
	Return
EndIf

//Vou ajustar o array de perguntas para o padrao da rotina
aAdd(/*01*/__aRet,plsintpad())	//Operadora
aAdd(/*02*/__aRet,SubStr(B4M->B4M_CMPLOT,1,4))	//Ano Competência
aAdd(/*03*/__aRet,SubStr(B4M->B4M_CMPLOT,5,2))	//Mês Competência
aAdd(/*04*/__aRet,B4M->B4M_NUMLOT)//Lote De
aAdd(/*05*/__aRet,B4M->B4M_NUMLOT)//Lote Ate		
aAdd(/*06*/__aRet,"")//Local de Digitação
aAdd(/*07*/__aRet,"")//Protocolo De
aAdd(/*08*/__aRet,"")//Protocolo Ate
aAdd(/*09*/__aRet,"2")//Considera Guias Estornadas -> 2-Nao
aAdd(/*10*/__aRet,"2")//Gerar como exclusao -> 2-Nao
aAdd(/*11*/__aRet,"2")//Somente Us.Inf.ANS -> 2-Nao
aAdd(/*12*/__aRet,"1")//Considera Guias Processadas -> Sim
aAdd(/*13*/__aRet,"1")//Cons Data de Process
aAdd(/*14*/__aRet,"1")//Tipo de envio
aAdd(/*15*/__aRet,"1")//Situacao da guia

aAdd(aLote, B4M->B4M_NUMLOT) // cNumLote,cCompet,cSusep
aAdd(aLote, B4M->B4M_CMPLOT)
aAdd(aLote, B4M->B4M_SUSEP)

oProcess:IncRegua1( "Reprocessando... Lote: [" + aLote[2] + "] " + aLote[1]  )

While !TrbRp->(Eof())	
	aCampos	:= {}
	aAdd( aCampos,{ "B4M_QTDCRI"	,0 					} )	// quantidade de criticas
	aAdd( aCampos,{ "B4M_QTRGPR"	,B4M->B4M_QTRGPR - 1} )	// quantidade de registros
	gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
	delClassInf()
	//Exclui guia
	PLSM270DEL(aAlias, B4M->B4M_SUSEP+B4M->B4M_CMPLOT+B4M->B4M_NUMLOT+TrbRp->( CODLDP + CODPEG + NUMERO), .T.,TrbRp->(CODLDP + CODPEG + NUMERO) ) 	
	TrbRp->(dbSkip())
EndDo

TrbRp->(dbCloseArea())

cSqlName 	:= oTmpTable:getrealName()
aLoteAnt := aclone(aLote)
if THREADSLOCK == 1
	PLPROCMONIT( "01", cEmpAnt, cFilAnt, __aRet, lEnd, oTmpTable:getrealName(),aLote,THREADSLOCK,3) 
else
	if substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" .or. Upper(TCGetDb()) == "POSTGRES"
		TcSqlEXEC("DROP TABLE TEMPMONIT1")
   		nRet := TcSqlEXEC(" CREATE TABLE TEMPMONIT1 AS SELECT * FROM " + oTmpTable:getrealName() )
		if nRet >= 0
			TcSqlEXEC("COMMIT") 
		endif
		cSqlName := 'TEMPMONIT1'		
	endif
	for nX := 1 to THREADSLOCK
	 	startJob("PLPROCMONIT",GetEnvServer(),.F.,strzero(nX,2), cEmpAnt, cFilAnt, __aRet, lEnd, cSqlName, aLote, THREADSLOCK,3)
	next
endif
cSql := "SELECT COUNT(*) QTD FROM " + cSqlName 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
nQtd 	 := TrbFim->QTD
nQtdFull := TrbFim->QTD
TrbFim->(dbCloseArea())

if THREADSLOCK == 1
 	oProcess:SetRegua2( nQtdFull ) 
else
	oProcess:SetRegua2( -1 ) 
endif

while nQtd <> 0
	nQtdAnt := nQtd
	cSql := "SELECT COUNT(*) QTD FROM " + oTmpTable:getrealName() + " WHERE OK = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbFim",.F.,.T.)
	nQtd := TrbFim->QTD
	TrbFim->(dbCloseArea())
	if nQtd == nQtdAnt
		nLoop++
	else
		nLoop := 0
	endif 
	oProcess:IncRegua2( "[" + cvaltochar(nQtdFull - nQtd) +  "] de [" + cvaltochar(nQtdFull) + "]"  )
	if nQtd <> 0
		sleep(5000)
	endif
	if nLoop == 50
		exit
	endif		
enddo

If !excLotAlt(aLote)
	PLVLDMON( aLote )
	cfim := time()
	Aviso( "Resumo","Lote(s) reprocessado(s) " + CRLF + cValToChar(nQtdFull) + " Guia(s) Reprocessada(s)" + CRLF + 'Inicio: ' + cvaltochar( cini ) + "  -  " + 'Fim: ' + cvaltochar( cfim ) ,{ "Ok" }, 2 )
	B4P->( dbSetOrder( 1 ) ) // B4P_FILIAL + B4P_SUSEP + B4P_CMPLOT + B4P_NUMLOT + B4P_NMGOPE + B4P_CODPAD + B4P_CODPRO + B4P_CDCMER
	If( B4P->( dbSeek( xFilial( "B4P" ) + B4M->B4M_SUSEP + B4M->B4M_CMPLOT + B4M->B4M_NUMLOT ) ) )
		cStatus := "2" // Processado (criticado)
	Else
		cStatus := "1" // Processado (sem Criticas)
	EndIf

	aCampos := { }
	aAdd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )	// filial
	aAdd( aCampos,{ "B4M_SUSEP"		,B4M->B4M_SUSEP } )		// operadora
	aAdd( aCampos,{ "B4M_CMPLOT"	,B4M->B4M_CMPLOT } )	// competencia lote
	aAdd( aCampos,{ "B4M_NUMLOT"	,B4M->B4M_NUMLOT } )	// numero de lote
	aAdd( aCampos,{ "B4M_STATUS"	,cStatus } )			// status
	gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
	delClassInf()
EndIf

(cAlias)->(dbclosearea())

cfim := time()

Return

function P270CTMP(cAlias,oTmpTable,lReenv)
fCriaTmp(cAlias,@oTmpTable,lReenv)
return

function P270hubguias(lTipo)
hubGuias(lTipo)
return

function P270excAlt(aLote)
return excLotAlt(aLote)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PROVLRPREE
Consulta os contratos preestabelecidos cadastrados e chama a gravacao da B8Q

@author    timoteo.bega
@since     04/05/2017
/*/
//------------------------------------------------------------------------------------------
Static Function PROVLRPREE(cLoteInf)
Local aLote			:= {}
Local cCompet		:= allTrim( __aRet[ 2 ] + __aRet[ 3 ] )
Local cCodInt		:= allTrim( __aRet[ 1 ] )
Local cRdaDe		:= allTrim( __aRet[ 4 ] )
Local cRdaAte		:= allTrim( __aRet[ 5 ] )
Local cNumLot		:= ""
Local cSql			:= ""
Local cAliSql		:= GetNextAlias()
Local cSusep		:= ""
Local lGravouB8Q	:= .F.
Local cSqlRepetido	:= ''
Local lJaTinha		:= .F.
default cLoteInf	:= ""

cSql := "SELECT BAU_CNES, BAU_MUN, BAU_CPFCGC, B8O_IDCOPR, B8O_VLRCON, B8O_VIGINI, B8O_VIGFIM, BAU_NREDUZ, BAU_CODIGO FROM " + RetSqlName("B8O") + " B8O INNER JOIN " + RetSqlName("BAW") + " BAW ON "
cSql += "BAW_FILIAL = '" + xFilial("BAW") + "' AND BAW_CODINT = '" + cCodInt + "' AND BAW_CODIGO = B8O_CODRDA AND BAW.D_E_L_E_T_ = ' ' "
cSql += "INNER JOIN " + RetSqlName("BAU") + " BAU ON BAU_FILIAL = '" + xFilial('BAU') + "' AND BAU_CODIGO BETWEEN '" + cRdaDe + "' AND '" + cRdaAte + "' AND BAU.D_E_L_E_T_ = ' ' WHERE "
cSql += "B8O_FILIAL = '" + xFilial('B8O') + "' AND B8O_CODINT = BAW_CODINT AND B8O_CODRDA = BAU_CODIGO "
cSql += "AND B8O_VIGINI <= '" + cCompet + "31' AND (B8O_VIGFIM <= '" + cCompet + "31' OR B8O_VIGFIM = ' ') AND B8O_ENVMON <> '1' AND B8O.D_E_L_E_T_ = ' ' "
cSql += " Order By B8O_IDCOPR, BAU_CPFCGC "
If PLSM270QRY(cSql,cAliSql)

	If procLote( aLote,1, cCompet, 4 )
		cNumLot := aLote[1]
	EndIf

	If BA0->(dbSeek(xFilial("BA0")+cCodInt))
		cSusep := BA0->BA0_SUSEP 
	EndIf
	
	cIdePre := Iif(Len(AllTrim((cAliSql)->BAU_CPFCGC))==14,"1","2")
	
	While !(cAliSql)->(Eof())

		cSqlRepetido := " Select 1 From " + RetSQLName("B8Q")
		cSqlRepetido += " Where "
		cSqlRepetido += " B8Q_FILIAL = '" + xfilial('B8Q') + "' AND "
		cSqlRepetido += " B8Q_SUSEP  = '" + cSusep  + "' AND "
		cSqlRepetido += " B8Q_CMPLOT = '" + cCompet + "' AND "
		cSqlRepetido += " B8Q_IDCOPR = '" + (cAliSql)->B8O_IDCOPR + "' AND "
		cSqlRepetido += " B8Q_CPFCNP = '" + (cAliSql)->BAU_CPFCGC + "' AND "
		cSqlRepetido += " D_E_L_E_T_ = ' ' "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSqlRepetido),"B8QREP",.f.,.t.)
		lJaTinha := !(B8QREP->(EoF()))
		B8QREP->(dbcloseArea())

		if lJaTinha
			(cAliSql)->(dbSkip())
			loop
		endif

		if PLSM270B8Q(cAliSql,cSusep,cCompet,cNumLot)
			lGravouB8Q := .T.
		endif

		(cAliSql)->(dbSkip())
	EndDo
	if lGravouB8Q
		cLoteInf +=  "[" + aLote[2] + "] " + aLote[1] + CRLF
	else
		//Se não gravou nenhum B8Q, deletamos o registro do lote na B4M, pra não ficar lote vazio
		excLotAlt(aLote)
	endif
EndIf

(cAliSql)->(dbclosearea())

Return 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A270Inverte
Função para marcar e desmarcar todos os itens da MarkBrowse

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
Function A270Inverte(oMBrw, cAlias)
local nReg 	 as numeric
default cAlias := "B4M"

nReg 	 := (cAlias)->(Recno())

(cAlias)->( dbgotop() )

While !(cAlias)->(Eof())
	// Marca ou desmarca. Este metodo respeita o controle de semaphoro.
	oMBrw:MarkRec()
	(cAlias)->(dbSkip())
Enddo

(cAlias)->(dbGoto(nReg))
oMBrw:oBrowse:Refresh(.t.)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} lckGrvMon
Controle de semaforo para a gravação de uma nova guia

@author    Lucas Nonato
@version   V12
@since     25/09/2018
/*/
//------------------------------------------------------------------------------------------
static function lckGrvMon(lLibera, cName)
local lOk := .t.
if THREADSLOCK > 1
	if !lLibera
		while lOk 
			if LockByName(cName, .T., .T.)
				lOk := .f.
			endif
		enddo
	else
		UnlockByName(cName, .T., .T.)
	endif
endif
Return .T.

function PLTime(cOpc)
	cHoraFim := TIME() 
    cElapsed := ElapTime( cHoraIni, cHoraFim ) 
	cHoraIni := cHoraFim
	PlsPtuLog(cOpc + " -> " + cElapsed , "Monit2.log")
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270Lote
Quebra das 10.000 guias.
@author Lucas Nonato
@since  01/02/2019
@version P12
/*/
//-------------------------------------------------------------------
function PLS270Lote(aLote, nTpProcess, cTipo)
local nTipEnv	:= 1
local lForce	:= .f.
default cTipo 	:= "1"

B4M->(dbsetorder(1))
B4M->(msseek(xfilial("B4M") + aLote[3] + aLote[2] + aLote[1] )) 

if cTipo == FORDIRETO .and. B4M->B4M_TIPENV <> '2'
	nTipEnv := 2
	if B4M->B4M_QTRGPR == 0 .and. LockByName("forndireto", .T., .T.)
		B4M->(reclock("B4M",.F.))
		B4M->B4M_TIPENV := "2"
		B4M->(msunlock())
		UnlockByName("forndireto", .T., .T.)
	elseif B4M->B4M_QTRGPR > 0 
		lForce := .t.
	endif
elseif cTipo <> FORDIRETO .and. B4M->B4M_TIPENV == '2'
	lForce := .t.
endif

if nTpProcess <> REPROCESSAR 	
	if B4M->B4M_QTRGPR >= QTDMAXGUI - THREADSLOCK .or. lForce
		//Procuro se alguma thread ja criou o novo lote e verifico se ele já não está cheio também.
		if lckGrvMon(.f.,"getLote")	
			BeginSQL Alias "TrbLot"
				SELECT B4M_NUMLOT, B4M_CMPLOT, B4M_QTRGPR 
				FROM %table:B4M% B4M
				WHERE
				B4M_FILIAL = %xFilial:B4M% AND
				B4M_SUSEP  = %exp:aLote[3]% AND
				B4M_CMPLOT = %exp:aLote[2]% AND
				B4M_NUMLOT > %exp:aLote[1]% AND
				(B4M_STATUS = %exp:'1'% OR B4M_STATUS = %exp:'2'% ) AND	
				B4M_QTRGPR < %exp:B4M->B4M_QTRGPR% AND		
				B4M.%notDel%
			EndSQL
			if !TrbLot->(eof())	
				aLote := {TrbLot->B4M_NUMLOT,TrbLot->B4M_CMPLOT,aLote[3]}			
			else			
				procLote(@aLote,,aLote[2],nTipEnv)			
			endif
			TrbLot->(dbclosearea())

			//B4M_FILIAL, B4M_SUSEP, B4M_CMPLOT, B4M_NUMLOT, B4M_NMAREN
			B4M->(msseek(xfilial("B4M") + aLote[3] + aLote[2] + aLote[1] ))
			lckGrvMon(.t.,"getLote")
		endif	
	endif
endif
B4M->(reclock("B4M",.F.,,.t.))
B4M->B4M_QTRGPR += 1
B4M->(msunlock())

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520FIL
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
function PLSM270FIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter 	:= ""
local cComp		:= space(6)
local cStatus	:= space(1)
default lF2  	:= .f.
aAdd( aPergs,{ 1, "A partir de:" , 	cComp	, "@R 9999/99", "", ""		, "", 50, .f.})
aadd( aPergs,{ 2, "Status:"		 , 	cStatus,{ "0=Todas","1=Pendentes","2=Encerradas"},100,/*'.T.'*/,.t. } )

BA0->( dbSetOrder( 1 ) )	// BA0_FILIAL, BA0_CODIDE, BA0_CODINT
BA0->( dbSeek( xFilial( "BA0" ) + allTrim( plsintpad() ) ) )
cSusep := BA0->BA0_SUSEP	

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270C',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	cFilter += "@B4M_FILIAL = '" + xfilial("B4M") + "'"	
	cFilter += " AND B4M_SUSEP = '" + cSusep + "'"	
	cFilter += " AND B4M_CMPLOT >= '" + aFilter[1] + "'"	
	if aFilter[2] <> "0"
		if aFilter[2] == "1"
			cFilter += " AND B4M_STATUS IN ('1','2','4','6','7')"	
		else
			cFilter += " AND B4M_STATUS IN ('3','5','8','9')"
		endif
	endif
endIf

//OK = 3,5,8,9
//Pendente = 1,2,4,6,7

if lF2
	oMBrwB4M:SetFilterDefault(cFilter)
	oMBrwB4M:Refresh()
endif
//"1-Processado (sem críticas);2-Processado (criticado);3-Arq. envio (sem críticas);4-Arq. envio (criticado);5-Arq. retorno (sem críticas);6-Arq. retorno (criticado);7-Arq. qualidade (criticado);8-Encerrado;9-Encerrado (reprocessado)")

return cFilter

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM27CMP
Guias x Competencia

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
//------------------------------------------------------------------------------------------
function PLSM27CMP
local aPergs	:= {}
local aFilter   := {}
local cComp		:= space(6)
local oBrowse 

aAdd( aPergs,{ 1, "Competencia" , 	cComp	, "@R 9999/99", "", ""		, "", 50, .t.})

if( !paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270PRE',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	return
endIf

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "B4N" )
oBrowse:SetDescription( "Competencia x Guias" ) 
oBrowse:SetFilterDefault( "@B4N_CMPLOT = '"+ aFilter[1] +"' AND B4N_LOTREP = ' ' " ) 
oBrowse:SetAttach( .T. ) //habilita a visão
oBrowse:AddLegend( "B4N_STATUS == '1'","GREEN","Não criticado" )
oBrowse:AddLegend( "B4N_STATUS == '2' .AND. ( B4N_ORIERR == ' ' .OR. B4N_ORIERR == '1' )", "RED",	"Criticado pelo sistema" )
oBrowse:AddLegend( "B4N_STATUS == '2' .AND. B4N_ORIERR == '2'", "ORANGE",	"Criticado pelo retorno" )
oBrowse:AddLegend( "B4N_STATUS == '2' .AND. B4N_ORIERR == '3'", "YELLOW",	"Criticado pela Qualidade " )
oBrowse:SetOpenChart( .f. ) //Define se o gráfico virá aberto ou oculto no carregamento do browse 
oBrowse:SetMenuDef("PLSM270B4P")
oBrowse:Activate()
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} telaLog
Tela do Log

@author Lucas Nonato
@since  23/04/2019
@version P12
/*/
static function telaLog(cIni,cFim,cLote,cSqlName)
local cAux 	:= ""
local cFile	:= ""
local cFileLog:= ""
local oMemo	:= Nil
local oDlg	:= Nil
local cQtd	:= ""

dbUseArea(.T.,"TOPCONN",TCGENQRY(,," SELECT COUNT(*) QTD FROM " +  cSqlName),"TrbQtd2",.F.,.T.)		
cQtd := cvaltochar(TrbQtd2->QTD)
TrbQtd2->(dbCloseArea())

cAux += Replicate( " ", 128 ) + CRLF
cAux += "Lote(s) criado(s):" + CRLF
cAux += cLote + CRLF
cAux += CRLF
cAux += "Hora Inicio.:" + cvaltochar( cIni )  + CRLF
cAux += "Hora Fim....:" + cvaltochar( cFim )  + CRLF
cAux += "Quantidade de registros a serem processados: " + cQtd + CRLF
cAux += CRLF
cAux += "Guias ignoradas: " + CRLF
cAux += getLogMonit()
cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cAux )

Define Font oFont Name "Mono AS" Size 6, 12

Define MsDialog oDlg Title "Resumo" From 3, 0 to 340, 417 Pixel

@ 5, 5 Get oMemo Var cAux Memo Size 200, 145 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel
Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( "*.txt", "" ), if( cFile == "", .T., ;
MemoWrite( cFile, cAux ) ) ) Enable Of oDlg Pixel

Activate MsDialog oDlg Center

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getLogMonit
Le o arquivo de log e escreve na tela

@author Lucas Nonato
@since  23/04/2019
@version P12
/*/
static function getLogMonit()
local oFileRead as object
local cAux 		as char
oFileRead := FWFileReader():New( "\logpls\"+dtos(date())+"\logMonit.log" )

cAux := ""

if oFileRead:Open()
	while (oFileRead:hasLine())
		cAux += oFileRead:GetLine() + CRLF
	enddo
	oFileRead:Close()
endif

FWFreeVar( @oFileRead ) 

return cAux

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM270VLD
Validação de Lotes marcados
@author Lucas Nonato
@since  11/08/2018
@version P12
/*/
function PLSM270VLD
local cAlias 	:= getNextAlias()
local cSql		:= ""
local aLote 	:= array(3)
local aRet		:= {}

cSql := " SELECT B4M_FILIAL,B4M_NMAREN,B4M_SUSEP,B4M_CMPLOT,B4M_NUMLOT,B4M_REENVI " 
cSql += " FROM " + RetSqlName("B4M") + " B4M "
cSql += " WHERE B4M_FILIAL = '" + xFilial("B4M") + "' "
cSql += " AND B4M_OK = '" + oMBrwB4M:cMark + "' "
cSql += " AND B4M.D_E_L_E_T_ = ' '  "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)	

if (cAlias)->(eof())
	msgAlert("Nenhum lote selecionado.")
endif

while !(cAlias)->(eof())
	if( !empty( (cAlias)->B4M_NMAREN ) )
		aadd(aRet,{ "[" + (cAlias)->B4M_CMPLOT + "]" + (cAlias)->B4M_NUMLOT , " - Lote ja enviado para ANS, não validado." })		
	else
		ProcRegua(-1)
		aLote[1] := (cAlias)->B4M_NUMLOT
		aLote[2] := (cAlias)->B4M_CMPLOT
		aLote[3] := (cAlias)->B4M_SUSEP
		//oProcess:IncRegua1( "Validando Lote: [" + aLote[2] + "] " + aLote[1]  ) 
		PLVLDMON( aLote )
		B4P->( dbSetOrder( 1 ) ) // B4P_FILIAL + B4P_SUSEP + B4P_CMPLOT + B4P_NUMLOT + B4P_NMGOPE + B4P_CODPAD + B4P_CODPRO + B4P_CDCMER
		if( B4P->( dbSeek( xFilial( "B4P" ) + (cAlias)->B4M_SUSEP + (cAlias)->B4M_CMPLOT + (cAlias)->B4M_NUMLOT ) ) )
			cStatus := "2" // Processado (criticado)
		else
			cStatus := "1" // Processado (sem Criticas)
		endif

		B4M->(DbSetOrder(1))//B4M_FILIAL+B4M_SUSEP+B4M_CMPLOT+B4M_NUMLOT+B4M_NMAREN		
		B4M->(MsSeek(xFilial("B4M") + (cAlias)->B4M_SUSEP + (cAlias)->B4M_CMPLOT + (cAlias)->B4M_NUMLOT))

		aCampos := { }
		aAdd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )		// filial
		aAdd( aCampos,{ "B4M_SUSEP"		,(cAlias)->B4M_SUSEP } )	// operadora
		aAdd( aCampos,{ "B4M_CMPLOT"	,(cAlias)->B4M_CMPLOT } )	// competencia lote
		aAdd( aCampos,{ "B4M_NUMLOT"	,(cAlias)->B4M_NUMLOT } )	// numero de lote
		aAdd( aCampos,{ "B4M_STATUS"	,cStatus } )				// status
		gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
		aadd(aRet,{ "[" + (cAlias)->B4M_CMPLOT + "]" + (cAlias)->B4M_NUMLOT , "Validação Concluida." })		
		
	endif
	(cAlias)->(dbskip())
enddo
(cAlias)->(dbclosearea())	
if len(aRet) > 0
	PLSCRIGEN(aRet,{{"Lote","@!",20},{"Mensagem","@!",120}},"Log de validação",nil,nil)
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} monitorJobs
Sobe os Jobs novamente caso eles caiam misteriosamente.
@author Lucas Nonato
@since  27/05/2019
@version P12
/*/
static function monitorJobs(cEmpAnt, cFilAnt, __aRet, lEnd, cSqlName, aLote)
local aInfo := {}
local nX	:= 1
local cSql	:= ""

if THREADSLOCK > 1
	aInfo := GetUserInfoArray()
	for nX := 1 to THREADSLOCK
		if ascan(aInfo,{|x| "[Monitoramento TISS] JOB: "+strzero(nX,2) $ alltrim(x[11]) }) == 0
			cSql := "SELECT COUNT(*) QTD FROM " + cSqlName + " WHERE OK = ' ' AND FLAG = '" + strzero(nX,2) + "' "
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbJob",.F.,.T.)
			if TrbJob->QTD > 0
				if monitorGuia(TrbJob->QTD, cSql)
					//PlsPtuLog("Lancei a thread: " + strzero(nX,2), "Monit.log")
					startJob("PLPROCMONIT",GetEnvServer(),.F.,strzero(nX,2), cEmpAnt, cFilAnt, __aRet, lEnd, cSqlName, aLote, THREADSLOCK)
				endif
			endif
			TrbJob->(dbCloseArea())			
		endif
	next
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} P270DELETE
Exclusão performatica feita em query.
@author Lucas Nonato
@since  27/05/2019
@version P12
/*/
function P270DELETE()
local lProc		:= .T.
local nx		:= 0
local cAlias	:= ""	
local cMsg		:= ""
local cSql      := ""
local cRet		:= ""
local aAlias	:= { "B4U","B4P","B4O","B4N","B4M","B8Q","B8R" }

cSql := " SELECT B4M_FILIAL,B4M_NMAREN,B4M_SUSEP,B4M_CMPLOT,B4M_NUMLOT,B4M_REENVI " 
cSql += " FROM " + RetSqlName("B4M") + " B4M "
cSql += " WHERE B4M_FILIAL = '" + xFilial("B4M") + "' "
cSql += " AND B4M_OK = '" + oMBrwB4M:cMark + "' "
cSql += " AND B4M.D_E_L_E_T_ = ' '  "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)	

cMsg := "Deseja excluir os registros marcados do monitoramento?" + CRLF + CRLF
if(! msgYesNo( cMsg ) )
	lProc := .F.
endIf

if PLEXC->(eof())
	msgAlert("Nenhum lote selecionado.")
endif

while !PLEXC->(eof())

	if( ! empty( PLEXC->B4M_NMAREN ) )
		cRet +=  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT + "- O arquivo não pode ser excluído!" + CRLF
		lProc := .F.
	endif

	if( lProc )			
		cRet +=  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT + " - Exclusão efetuada com sucesso!" + CRLF

		ProcRegua(-1)
		IncProc("Excluindo lote " + "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT )				
		for nx := 1 to len( aAlias )
			cAlias := aAlias[ nx ]			
			//B4M_FILIAL + B4M_SUSEP + B4M_CMPLOT + B4M_NUMLOT + B4M_NMAREN
			//B4N_FILIAL + B4N_SUSEP + B4N_CMPLOT + B4N_NUMLOT + B4N_NMGOPE + B4N_CODRDA
			//B4O_FILIAL + B4O_SUSEP + B4O_CMPLOT + B4O_NUMLOT + B4O_NMGOPE + B4O_CODGRU + B4O_CODTAB + B4O_CODPRO + B4O_CODRDA
			//B4P_FILIAL + B4P_SUSEP + B4P_CMPLOT + B4P_NUMLOT + B4P_NMGOPE + B4P_CODGRU + B4P_CODPAD + B4P_CODPRO + B4P_CDCMER
			//B4U_FILIAL + B4U_SUSEP + B4U_CMPLOT + B4U_NUMLOT + B4U_NMGOPE + B4U_CDTBPC + B4U_CDPRPC + B4U_CDTBIT + B4U_CDPRIT
			cSql := " DELETE FROM " + RetSqlName(cAlias)
			cSql += " WHERE "+cAlias+"_FILIAL = '" + xFilial(cAlias) + "' "
			cSql += " AND "+cAlias+"_SUSEP = '" +  PLEXC->B4M_SUSEP + "' "
			cSql += " AND "+cAlias+"_CMPLOT = '" + PLEXC->B4M_CMPLOT + "' "
			cSql += " AND "+cAlias+"_NUMLOT = '" + PLEXC->B4M_NUMLOT + "' "
			PLSCOMMIT(cSql)			
		next nx
	endIf
	PLEXC->(dbskip())
enddo

PLEXC->(dbclosearea())
if !empty(cRet)				
	msgInfo( cRet )
endIf

return 
//-------------------------------------------------------------------
/*/{Protheus.doc} monitorGuia
Verifica se a thread caiu de verdade
@author Lucas Nonato
@since  29/05/2019
@version P12
/*/
static function monitorGuia(nQtdIni, cSql)
local nx	as numeric

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbJB2",.F.,.T.)

if TrbJB2->QTD <> nQtdIni
	TrbJB2->(dbclosearea())
	return .f.
endif

TrbJB2->(dbclosearea())

for nX := 1 to 5
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbJB2",.F.,.T.)
	if TrbJB2->QTD <> nQtdIni
		TrbJB2->(dbclosearea())
		return .f.
	endif
	sleep(3000)
	TrbJB2->(dbclosearea())
next

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSM270SMV
Processa lote sem guias
@author Lucas Nonato
@since  31/10/2019
@version P12
/*/
function PLSM270SMV()

local aPergs	:= {}
local aLote		:= {}
local lRet 		:= .f.
private __aRet	:= {}

aadd( aPergs,{ 1,"Operadora"	  ,space(4),"@!",'.T.','B39PLS',/*'.T.'*/,40,.T. } )
aadd( aPergs,{ 1,"Ano Competência",space(4),"@R 9999",'.T.',,/*'.T.'*/,40,.T. } )
aadd( aPergs,{ 1,"Mês Competência",space(2),"@R 99",'.T.',,/*'.T.'*/,40,.T. } )
	
if( paramBox( aPergs,"Parâmetros - Processa arquivo de envio ANS",__aRet,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM2701',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	lRet := procLote( @aLote, 1, allTrim( __aRet[ 2 ] + __aRet[ 3 ] ) )	
	if lRet 
		Aviso( "Resumo","Lote criado: " + CRLF + "[" + B4M->B4M_CMPLOT + "] " + B4M->B4M_NUMLOT ,{ "Ok" }, 2 )				
	endif
endif
	
return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CallQryGlo
Função para retonar a query de glosa, retornando dados da guia atual e os itens que estão na original
@since  10/2021
@version P12
/*/
static function CallQryGlo(cTipo, cCodOpe, cCodLdp, cCodPeg, cNumero)
local cSql 	:= ""
local cTab	:= iif(cTipo == "1", "A.", "B.")
Local lAtuTiss4 := BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_TMREGA")) > 0//B4N->(fieldPos("B4N_REGATE")) > 0 .AND. B4N->(fieldPos("B4N_SAUOCU")) > 0 .AND. B4N->(fieldPos("B4N_CPFUSR")) > 0

cSql := " SELECT '" + iif(cTipo == "1", 'GLO', 'ORI') + "' TPGUIS "
cSql += "    , " + cTab +"BD6_CODRDA, C.BD5_TIPPRE, C.BD5_CODLOC, C.BD5_LOCAL, C.BD5_CODESP, " + cTab +"BD6_CODESP, " + cTab +"BD6_SEQIMP"
cSql += "    , C.BD5_LOTMOP, C.BD5_DTDIGI, " + cTab +"BD6_CODOPE, " + cTab +"BD6_CODLDP, " + cTab +"BD6_CODPEG, " + cTab +"BD6_NUMERO, " + cTab +"BD6_ORIMOV"
cSql += "    , " + cTab +"BD6_SEQUEN, A.BD6_TIPGUI, D.BD5_TPGRV 		 , C.BD5_TIPADM, C.BD5_TIPPRE, B.BD6_TPGRV, C.BD5_INDACI"
cSql += "    , C.BD5_TIPATE, C.BD5_DTPAGT, C.BD5_ATERNA, " + cTab +"BD6_VLRMAN, C.BD5_TIPCON, C.BD5_GUESTO, C.BD5_ESTORI"
cSql += "    , C.BD5_LOTMOE, C.BD5_DATSOL, C.R_E_C_N_O_ C_REG, " + cTab +"BD6_OPEORI, " + cTab +"BD6_VLRGLO, " + cTab +"BD6_BLOCPA, C.BD5_TIPFAT"
cSql += "    , C.BD5_LOTMOF, " + cTab +"BD6_CODTAB, " + cTab +"BD6_OPEUSR, " + cTab +"BD6_CODEMP, " + cTab +"BD6_MATRIC, " + cTab +"BD6_TIPREG, " + cTab +"BD6_DIGITO"
cSql += "    , " + cTab +"BD6_VLRTPF, " + cTab +"BD6_DATPRO, " + cTab +"BD6_CODPAD, " + cTab +"BD6_FADENT, " + cTab +"BD6_VLRPAG, " + cTab +"BD6_CODRDA, " + cTab +"BD6_NFE"
cSql += "    , " + cTab +"BD6_LIBERA, " + cTab +"BD6_FASE  , " + cTab +"BD6_SITUAC, " + cTab +"BD6_BLOPAG, C.BD5_DATPRO, " + cTab +"BD6_VLRAPR, " + cTab +"BD6_DATPRO"
cSql += "    , " + cTab +"BD6_QTDPRO, " + cTab +"BD6_OPELOT, " + cTab +"BD6_NUMLOT, " + cTab +"BD6_CODRDA, C.BD5_GUIINT, C.BD5_GUIPRI, " + cTab +"BD6_VLRPF "
cSql += "    , B.BD6_VLRTPF VLRTPFORI, " + cTab +"BD6_CODPRO, " + cTab +"BD6_DENREG, C.BD5_NUMIMP, C.BD5_GUIORI"
cSql += "    , B.BD6_VLRAPR VLRAPRORI, B.BD6_VLRPAG VLRPAGORI, B.BD6_VLRGLO VLRGLOORI, D.BD5_LOTMOF LOTMOFORI, " + cTab + "BD6_TABDES "
cSql += iif(BD5->(fieldpos("BD5_TISVER")) > 0, ",C.BD5_TISVER TISVER ", " ,' ' TISVER")
if lAtuTiss4
	cSql += " , C.BD5_TMREGA, C.BD5_SAUOCU "
endif
cSql += " FROM " + RetSqlName("BD5") + " C "  
cSql += "   INNER JOIN " + RetSqlName("BD5") + " D "  
cSql += "     ON  D.BD5_FILIAL = C.BD5_FILIAL " 
cSql += " 	      AND D.BD5_CODOPE = SUBSTRING(C.BD5_GUIORI,01,4) " 
cSql += " 	      AND D.BD5_CODLDP = SUBSTRING(C.BD5_GUIORI,05,4) " 
cSql += " 	      AND D.BD5_CODPEG = SUBSTRING(C.BD5_GUIORI,09,8) " 
cSql += " 	      AND D.BD5_NUMERO = SUBSTRING(C.BD5_GUIORI,17,8) " 
cSql += "   INNER JOIN " + RetSqlName("BD6") + " A "  
cSql += "     ON  A.BD6_FILIAL = C.BD5_FILIAL " 
cSql += "         AND A.BD6_CODOPE = C.BD5_CODOPE " 
cSql += "         AND A.BD6_CODLDP = C.BD5_CODLDP " 
cSql += "         AND A.BD6_CODPEG = C.BD5_CODPEG " 
cSql += "         AND A.BD6_NUMERO = C.BD5_NUMERO " 
cSql += "   INNER JOIN " + RetSqlName("BD6") + " B "  
cSql += "     ON  B.BD6_FILIAL = C.BD5_FILIAL " 
cSql += " 		  AND B.BD6_CODOPE = D.BD5_CODOPE " 
cSql += " 		  AND B.BD6_CODLDP = D.BD5_CODLDP " 
cSql += " 		  AND B.BD6_CODPEG = D.BD5_CODPEG " 
cSql += " 		  AND B.BD6_NUMERO = D.BD5_NUMERO " 
if cTipo == "1"
	cSql += " 	  AND B.BD6_SEQUEN = A.BD6_SEQUEN " 
	cSql += " 	  AND B.BD6_CODPAD = A.BD6_CODPAD " 
	cSql += " 	  AND B.BD6_CODPRO = A.BD6_CODPRO " 
endif
cSql += " WHERE C.BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += " 	AND C.BD5_CODOPE = '" + cCodOpe + "'"
cSql += " 	AND C.BD5_CODLDP = '" + cCodLdp + "'"
cSql += " 	AND C.BD5_CODPEG = '" + cCodPeg + "'"
cSql += " 	AND C.BD5_NUMERO = '" + cNumero + "'"
cSql += " 	AND A.D_E_L_E_T_ = ' ' "
cSql += " 	AND B.D_E_L_E_T_ = ' ' "
cSql += " 	AND C.D_E_L_E_T_ = ' ' "
cSql += " 	AND D.D_E_L_E_T_ = ' ' "	
if cTipo != "1"
	cSql +=	" AND NOT EXISTS (SELECT BD6_FILIAL FROM " + RetSqlName("BD6") + " XX WHERE "
	cSql += " 					XX.BD6_FILIAL     = C.BD5_FILIAL 	"
	cSql += " 					AND XX.BD6_CODOPE = C.BD5_CODOPE 	"
	cSql += " 					AND XX.BD6_CODLDP = C.BD5_CODLDP 	"
	cSql += " 					AND XX.BD6_CODPEG = C.BD5_CODPEG 	"
	cSql += " 					AND XX.BD6_NUMERO = C.BD5_NUMERO 	"
	cSql += " 					AND XX.BD6_SEQUEN = B.BD6_SEQUEN 	"
	cSql += " 					AND XX.BD6_CODPAD = B.BD6_CODPAD) 	"
endif 

return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS270GlInt
Query base para envio das guias com glosa integral
@since  04/2022
/*/
//-------------------------------------------------------------------
function PLS270GlInt(aLote)
local cSql 		:= ""
local cRdaProp	:= GetNewPar("MV_RDAPROP","")

cSql += " SELECT CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, '9' TIPO, TIPGUI, DTANAL FROM " + oTmpBase:getrealName()
cSql += " INNER JOIN " + RetSqlName("BCI") 
cSql += " ON BCI_FILIAL = '" + xfilial("BCI") + "'"
cSql += " AND BCI_CODOPE = CODOPE AND BCI_CODLDP = CODLDP AND BCI_CODPEG = CODPEG"
cSql += " AND BCI_STTISS = '4' "
cSql += " AND (BCI_FASE = '3' OR BCI_FASE = '4') "
cSql += " AND (BCI_MES = '" + __aRet[ 3 ] + "' AND BCI_ANO = '" + __aRet[ 2 ] + "')"
cSql += " WHERE TIPGUI <> '04' "
cSql += " AND DTANAL BETWEEN '" + __aRet[ 2 ] + __aRet[ 3 ] + "01' AND '" + __aRet[ 2 ] + __aRet[ 3 ] + "31'"
cSql += " AND LOTMOP = ' ' "
cSql += " AND LOTMOF = ' ' "
cSql += " AND CODRDA <> '" + cRdaProp + "' "
cSql += " AND DTPAGT = ''

cSql := changequery(cSql)

cSql := " Insert Into " +  oTmpTable:getrealName() + " (CODOPE, CODLDP, CODPEG, CODRDA, NUMERO, TIPO, TIPGUI, DTDIGI) " + cSql

if GetNewPar("MV_PMONLOG",.F.)
	PlsPtuLog("------------------------------------------" , "Monit.log")
	PlsPtuLog("GlosaIntegral" , "Monit.log")
	PlsPtuLog(cSql , "Monit.log")
endif

oProcess:IncRegua1( "Carregando dados... Lote: [" + aLote[2] + "] " + aLote[1] )
PLSCOMMIT(cSql)

hubGuias()

return

//função para centralizar os tratamentos de versão por conta da versão 
//1.03.00 ter sido adiada a entrada em vigencia
function P270RetVer(lCampo)
Local cRet := ""
Default lCampo := .T. //Define se o valor base será o B4M_VERSAO (.T.) ou valor fixo (.F.)

if lCampo
	cRet := B4M->B4M_VERSAO
	if dDataBase < CtoD("01/03/2023")  //Data início de vigência da 1.03.00
		cRet := "1.01.00"
	endif
else
	cRet := "1.03.00"
	if dDataBase < CtoD("01/03/2023")  //Data início de vigência da 1.03.00
		cRet := "1.01.00"
	endif
endif

return cret
